(*@CES
Name=Time_Variaition_PILQR
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=72ca66b0-1667-4547-85f7-d4b61b3bde5a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Time_Variaition_PILQR : REAL
VAR_INPUT
	i_xUseWfValue:BOOL;(*使用估计的转速值到电机|不使用的时候清除估计转速输出*)
(*输入变量*)
	i_rVt:REAL;(*牵引线速度m/min*)
	i_rWu:REAL;(*放料转速(RPM)*)
	i_rY:REAL;(*张力摆臂反馈*)
	i_rKc: REAL;		(*调整增益*)
(*输出变量指针*)
	i_piK:POINTER TO INT;(*拍数计数*)
	i_prWf:POINTER TO REAL;(*转速补偿量r/min*)
	i_prCNT:POINTER TO REAL;(*LQR迭代次数*)
(*结构体*)
	i_stInvariant_Parameters1:Invariant_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
	i_stTime_Varying_Parameters1:Time_Varying_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
	i_stKalman_Status_Estimation_And_Feedback1:Kalman_Status_Estimation_And_Feedback;(*2024.05.07.105319 修改接口名by Liu*)
	i_stPI_Parameters1:PI_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
	i_pCached_Array_Pointers1: POINTER TO Cached_Array_Pointers;
END_VAR

VAR
	(*2024.05.07.105252 增加局部变量by Liu*)
	Invariant_Parameters1:Invariant_Parameters;
	Time_Varying_Parameters1:Time_Varying_Parameters;
	Kalman_Status_Estimation_And_Feedback1:Kalman_Status_Estimation_And_Feedback;
	PI_Parameters1:PI_Parameters;
	iMaxIterateNum: INT:=30;(*最大迭代次数值@2024.05.10.123127+*)
(*基本参数*)
	rVt:REAL;			(*牵引线速度,(m/s)*)
	rWu:REAL;			(*控制器输出转速r/min*)
	rY:REAL;			(*摆臂反馈量*)

	rWf:REAL;			(*转速补偿量r/min*)
(*计算过程中间变量*)
	rT:REAL;		 	(*转速r/min-线速度转换m/s*)
	rVr:REAL;			(*稳态工作点线速度,(m/s)*)
	rDeltaV:REAL;		(*控制器相对线速度输出(m/s)*)
	rVc:REAL;			(*线速度计算量m/s*)

	rWc:REAL;			(*转速计算量r/min*)
	rVk:REAL;			(*第k拍控制器输出的线速度 m/s*)

(*内部变量*)
	rLim:REAL:=0;		(*转速补偿量限幅幅值*)


(*系统状态空间*)
	alrA:ARRAY [1..4,1..4] OF LREAL;
	alrAd:ARRAY [1..4,1..4] OF LREAL;
	alrAdT:ARRAY [1..4,1..4] OF LREAL;
	byRow_Ad:BYTE :=4;
	byCol_Ad:BYTE :=4;
	alrB:ARRAY [1..4] OF LREAL;
	alrBd:ARRAY [1..4] OF LREAL;
	byRow_Bd:BYTE :=4;
	byCol_Bd:BYTE :=1;
	alrC:ARRAY [1..4] OF LREAL;
	alrCd:ARRAY [1..4] OF LREAL;
	byRow_Cd:BYTE :=1;
	byCol_Cd:BYTE :=4;
(*Invariant_Parameters*)
	rTs: REAL;		(*采样时间Ts*)
	rRange: REAL;    	(*输出最大量程*)
	rTheta: REAL;	(*摆臂偏角范围*)
	rK_adj: REAL;		(*模型调整增益*)
(*Time_Varying_Parameters*)
	rEST_R:REAL;(*估计的卷半径m*)
	a0:REAL;
	b1:REAL;
	Beta:REAL;
	Wn:REAL;
	l:REAL;
(*其他*)
	Ku:REAL;(*传感器输出增益  电位器最大量程（V）/摆臂最大摆动角度（rad）*)
(*运算的中间变量*)
	alrA2:ARRAY [1..4,1..4] OF LREAL;        (*A矩阵的2次方*)
(*单位矩阵*)
	alrI:ARRAY [1..4,1..4] OF LREAL;
	byRow_I:BYTE:=4;
	byCol_I:BYTE:=4;
(*计算过程中的临时变量/矩阵*)
	alrCalValue:ARRAY [1..MATRIX_ELEMENT_MAX] OF LREAL;(*计算出的值按一维数组存放*)
	alrCalValue_Mat:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF LREAL;(*一个MATRIX_ROW_MAX x MATRIX_COLUMN_MAX的矩阵|用于存放计算后的数据|AxB*)
	byCalValue_Row:BYTE;(*行数|计算后*)
	byCalValue_Column:BYTE;(*列|计算后*)
(*离散缓存矩阵*)
	alrTsA:ARRAY[1..4,1..4] OF LREAL;
	alrTs2A2:ARRAY[1..4,1..4] OF LREAL;
	alrTempAd:ARRAY[1..4,1..4] OF LREAL;

	alrAB:ARRAY[1..4] OF LREAL;
	alrA2B:ARRAY[1..4] OF LREAL;
	alrTsB:ARRAY[1..4] OF LREAL;
	alrTs2AB:ARRAY[1..4] OF LREAL;
	alrTs3A2B:ARRAY[1..4] OF LREAL;
	alrTempBd:ARRAY[1..4] OF LREAL;
(*Kalman计算相关*)
	(*初始误差矩阵*)
	alrP0:ARRAY [1..4,1..4] OF LREAL;(*初始为0矩阵*)
	byRow_P:BYTE:=4;
	byCol_P:BYTE:=4;
	(*R Q 矩阵*)
	rR:REAL;
	alrQ:ARRAY [1..4,1..4] OF LREAL;
	byRow_Q:BYTE:=4;
	byCol_Q:BYTE:=4;
	(*初始状态*)
	alrX0:ARRAY[1..4] OF LREAL;
	byRow_X:BYTE:=4;
	byCol_X:BYTE:=1;
	(*拍数计数*)
	iK:INT:=0;
	(*第一拍的摆臂输入*)
	rY0:REAL;
	(*卡尔曼增益K*)
	alrK: ARRAY [1..4] OF LREAL;
	byRow_K:BYTE:=4;
	byCol_K:BYTE:=1;
	(*先验状态估计和先验误差协方差矩阵*)
	alrXh:ARRAY[1..4] OF LREAL;
	alrPh:ARRAY[1..4,1..4] OF LREAL;
	(*后验状态估计和后验误差协方差矩阵*)
	alrX:ARRAY[1..4] OF LREAL;
	alrP:ARRAY[1..4,1..4] OF LREAL;
	(*计算过程中的临时变量/矩阵*)
	lrTemp:LREAL;

	alrX_Temp1:ARRAY[1..4] OF LREAL;
	alrX_Temp2:ARRAY[1..4] OF LREAL;
	alrX_Temp3:ARRAY[1..4] OF LREAL;

	alrP_Temp1:ARRAY[1..4,1..4] OF LREAL;
	alrP_Temp2:ARRAY[1..4,1..4] OF LREAL;
	alrP_Temp3:ARRAY[1..4,1..4] OF LREAL;

	alrK_Temp1:ARRAY[1..4] OF LREAL;

(*LQR计算*)
	rCNT:REAL;
	rN_LQR:REAL;
	alrKf:ARRAY [1..4] OF LREAL;(*设置的Kf*)
	alrKf_Cal:ARRAY [1..4] OF LREAL;(*计算的Kf*)
	byRow_Kf:BYTE:=1;
	byCol_Kf:BYTE:=4;

	alrX_DARE:ARRAY [1..4,1..4] OF LREAL;(*上一个周期已经迭代收敛的值X_Dare*)
	byRow_X_DARE:BYTE:=4;
	byCol_X_DARE:BYTE:=4;
	(*中间变量和矩阵*)
	alrKidare:ARRAY [1..4] OF LREAL;
	byRow_Kidare:BYTE:=4;
	byCol_Kidare:BYTE:=1;
	alrKidare_old:ARRAY [1..4] OF LREAL;
	lrQ_LQR_4_4:LREAL;
	alrX_LQR:ARRAY [1..4,1..4] OF LREAL;
	byRow_X_LQR:BYTE:=4;
	byCol_X_LQR:BYTE:=4;

	alrX_DARE_B:ARRAY [1..4] OF LREAL;
	alrBT_X_DARE:ARRAY [1..4] OF LREAL;

	alrKidare_BT:ARRAY [1..4,1..4] OF LREAL;
	alrI_Kidare_BT:ARRAY [1..4,1..4] OF LREAL;
	byRow_I_Kidare_BT:BYTE:=4;
	byCol_I_Kidare_BT:BYTE:=4;
	alrP_LQR:ARRAY [1..4,1..4] OF LREAL;
	byRow_P_LQR:BYTE:=4;
	byCol_P_LQR:BYTE:=4;

	lrTemp_LQR1:LREAL;
	alrTemp_X1:ARRAY [1..4,1..4] OF LREAL;
	alrTemp_X2:ARRAY [1..4,1..4] OF LREAL;

	lrD:LREAL;(*计算两个向量的欧式距离*)
	lrD_Temp:LREAL;
	alrKf_Temp:ARRAY [1..4] OF LREAL;
(*PI控制器输出*)
	rPI:REAL;
	rK_PI:REAL;(*系统参数K*)
	ra:REAL;(*系统参数a*)
	rb:REAL;(*系统参数b*)
	arUk_PI:ARRAY [1..2] OF REAL;(*输入寄存器*)
	arYk_PI:ARRAY [1..2] OF REAL;(*输出寄存器*)
(*FOR循环计数*)
	iN:INT;
	iM:INT;
	iJ:INT;
	iI:INT;
(*离散*)
	rFactorial_k:LREAL;
	alrA_POWER:ARRAY[1..4,1..4] OF LREAL;
	alrA_POWERTemP:ARRAY[1..4,1..4] OF LREAL;
	alrAdTemp:ARRAY [1..4,1..4] OF LREAL;
	alrBdTemp:ARRAY [1..4,1..4] OF LREAL;
END_VAR
{IMPLEMENTATION}
	(*2024.05.07.105445+by Liu*)
	Invariant_Parameters1:=i_stInvariant_Parameters1;
	Time_Varying_Parameters1:=i_stTime_Varying_Parameters1;
	Kalman_Status_Estimation_And_Feedback1:=i_stKalman_Status_Estimation_And_Feedback1;
	PI_Parameters1:=i_stPI_Parameters1;


(*Time_Varying_Parameters*)
	rEST_R := Time_Varying_Parameters1.EST_R;
	a0 := Time_Varying_Parameters1.a0;
	l := Time_Varying_Parameters1.l;
	b1 := Time_Varying_Parameters1.b1;
	Beta := Time_Varying_Parameters1.Beta;
	Wn := Time_Varying_Parameters1.Wn;

(*Invariant_Parameters*)
	rTs := Invariant_Parameters1.Ts;
	rRange := Invariant_Parameters1.Range;
	rTheta := Invariant_Parameters1.Theta;
	rK_adj := Invariant_Parameters1.K_adj;
(*Ad,Bd,Cd计算*)
	(*传感器输出增益计算*)
	Ku := LREAL_TO_REAL(rRange/(rTheta*gc_lrPi/180.0));
	
	(*线速度到摆臂*)
	(*单位矩阵*)
	alrI[1,1] := 1.0;	alrI[2,2] := 1.0;	alrI[3,3] := 1.0;	alrI[4,4] := 1.0;
	
	(*A矩阵*)
	alrA[1,1] := -1.0/b1;  			alrA[1,2] := 0.0;			alrA[1,3] := 0.0; 			 alrA[1,4] := 0.0;
	alrA[2,1] := 1.0;  				alrA[2,2] := 0.0; 			alrA[2,3] := -1.0; 			 alrA[2,4] := 0.0;
	alrA[3,1] := 2.0*l*Beta*Wn;  		alrA[3,2] := Wn*Wn;		alrA[3,3] := -2.0*Beta*Wn;	 alrA[3,4] := 0.0;
	alrA[4,1] := 0.0; 				alrA[4,2] := 0.0; 			alrA[4,3] := rK_adj; 		 alrA[4,4] := -a0;
	(*B矩阵*)
	alrB[1] := 1/b1;				alrB[2] := 0.0;			alrB[3] := 0.0;			alrB[4] := 0.0;
	(*C矩阵*)
	alrC[1] := 0.0;				alrC[2] := 0.0;			alrC[3] := 0.0;			alrC[4] := Ku;

(*离散化*)
(*Ad Bd*)
	(*arA_POWER单位矩阵*)
	alrA_POWER[1,1] := 1.0;	alrA_POWER[2,2] := 1.0;	alrA_POWER[3,3] := 1.0;	alrA_POWER[4,4] := 1.0;
	alrAd[1,1] := 1.0;			alrAd[2,2] := 1.0;			alrAd[3,3] := 1.0;			alrAd[4,4] := 1.0;
	alrBdTemp[1,1] := rTs;			alrBdTemp[2,2] := rTs;			alrBdTemp[3,3] := rTs;			alrBdTemp[4,4] := rTs;
	rFactorial_k :=1;

	FOR iI:=1 TO 50 BY 1 DO
		(*A_power = A_power * A * Ts*)
		(*A_POWER = A_POWER*A *)
			KS_MatrixMul_L(byRow_Ad,byCol_Ad,ADR(alrA_POWER),byRow_Ad,byCol_Ad,ADR(alrA),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
			KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrA_POWER),ADR(alrCalValue));
		(*A_POWER = A_POWER*Ts *)
			FOR iN:=1 TO byRow_Ad BY 1 DO(*A矩阵的行*)
				FOR iM:=1 TO byCol_Ad BY 1 DO(*A矩阵的列*)
					alrA_POWER[iN,iM]:= alrA_POWER[iN,iM]*rTs;
				END_FOR
			END_FOR
		(*k!*)
		rFactorial_k:=rFactorial_k*iI;
		(* Ad = Ad + A_power / factorial_k*)
		(*arA_POWERTemP = A_power / factorial_k*)
		FOR iN:=1 TO byRow_Ad BY 1 DO(*A矩阵的行*)
			FOR iM:=1 TO byCol_Ad BY 1 DO(*A矩阵的列*)
				alrA_POWERTemP[iN,iM]:= alrA_POWER[iN,iM]/rFactorial_k;
			END_FOR
		END_FOR
		(* Ad = Ad + arA_POWERTemP*)
		KS_MatrixAdd_L(byRow_Ad,byCol_Ad,ADR(alrAd),byRow_Ad,byCol_Ad,ADR(alrA_POWERTemP),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrAd),ADR(alrCalValue));

		(*Bd = Bd + (A_power / (factorial_k*(k+1))) * Ts;*)
		FOR iN:=1 TO byRow_Ad BY 1 DO(*A矩阵的行*)
			FOR iM:=1 TO byCol_Ad BY 1 DO(*A矩阵的列*)
				alrAdTemp[iN,iM]:= alrA_POWER[iN,iM]/(rFactorial_k*(iI+1))*rTs;
			END_FOR
		END_FOR
		KS_MatrixAdd_L(byRow_Ad,byCol_Ad,ADR(alrBdTemp),byRow_Ad,byCol_Ad,ADR(alrAdTemp),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrBdTemp),ADR(alrCalValue));
	END_FOR

	(*AdT*)
	FOR iN:=1 TO byRow_Ad BY 1 DO(*A矩阵的行*)
		FOR iM:=1 TO byCol_Ad BY 1 DO(*A矩阵的列*)
			alrAdT[iN,iM]:= alrAd[iM,iN];
		END_FOR
	END_FOR
(*Bd = Bd * B;*)
	KS_MatrixMul_L(byRow_Ad,byCol_Ad,ADR(alrBdTemp),byRow_Bd,byCol_Bd,ADR(alrB),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrBd),ADR(alrCalValue));

	(*Cd = C*)
	alrCd := alrC;
(*Kalman滤波*)
	(*输入变量传给函数内部变量*)
	rWu := i_rWu;			(*放料转速(RPM)*)
	rY := i_rY;				(*张力摆臂反馈*)
	iK := i_piK^;			(*拍数计数*)

	(*速度*)
	rVt := i_rVt/60.0;			(*牵引线速度,(m/s)*)
	rVr := rVt;				(*稳态工作点线速度,(m/s)*)
	(*rVr:=rVt-0.0015;(**稳态工作点线速度,(m/s)*)*)

	rT := LREAL_TO_REAL(2.0*gc_lrPi*rEST_R/60.0); (*转速r/min-线速度转换m/s*)
	rDeltaV:=rWu*rT-rVr;		(*稳态下线速度控制量*)

	(*R Q I 矩阵赋值*)
	(*Kalman_Status_Estimation_And_Feedback*)
	rR := Kalman_Status_Estimation_And_Feedback1.R_K;
	alrQ := Kalman_Status_Estimation_And_Feedback1.alrQ;
	alrP0 := Kalman_Status_Estimation_And_Feedback1.alrP0;

	alrPh := i_pCached_Array_Pointers1^.alrPh;		(*上一个周期的先验状态误差协方差矩阵*)
	alrXh := i_pCached_Array_Pointers1^.alrXh;		(*上一个周期估计状态向量Xh指针*)
(*LQR Kf*)
	(*N_LQR*)
	rN_LQR := Kalman_Status_Estimation_And_Feedback1.N_LQR;
	(*固定的Kf*)
	alrKf := Kalman_Status_Estimation_And_Feedback1.alrKf;
	(*LQR迭代求解DARE*)
	alrX_DARE := i_pCached_Array_Pointers1^.alrX_DARE;(*上一个周期已经迭代收敛的值X_Dare*)
	(*中间变量和矩阵*)
(*PI控制器*)
	rK_PI := PI_Parameters1.K_PI;
	ra := PI_Parameters1.a;
	rb := PI_Parameters1.b;
	arUk_PI := i_pCached_Array_Pointers1^.arUk_PI;
	arYk_PI := i_pCached_Array_Pointers1^.arYk_PI;
(*Kalman计算*)
IF iK=0 THEN (*判断第一拍*)
	rY0 := rY;
	(*初始状态赋值    在接料扰动中需要特别设置，对于周期扰动可以全部取0 *)
	alrX0[1] := 0 ; alrX0[2] := 0; alrX0[3] := 0; alrX0[4] := rY0/alrCd[4];
(*计算Xh Ph*)
(*Xh=Ad*X0+Bd*DeltaV*)
	KS_MatrixMul_L(byRow_Ad,byCol_Ad,ADR(alrAd),byRow_X,byCol_X,ADR(alrX0),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrX_Temp1),ADR(alrCalValue));

	alrX_Temp2[1]:=alrBd[1]*rDeltaV;alrX_Temp2[2]:=alrBd[2]*rDeltaV;
	alrX_Temp2[3]:=alrBd[3]*rDeltaV;alrX_Temp2[4]:=alrBd[4]*rDeltaV;

	KS_MatrixAdd_L(byRow_X,byCol_X,ADR(alrX_Temp1),byRow_X,byCol_X,ADR(alrX_Temp2),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrX_Temp3),ADR(alrCalValue));
	alrXh:=alrX_Temp3;
(*Ph=Ad*P0*AdT+Q*)
	KS_MatrixMul_L(byRow_Ad,byCol_Ad,ADR(alrAd),byRow_P,byCol_P,ADR(alrP0),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp1),ADR(alrCalValue));

	KS_MatrixMul_L(byRow_P,byCol_P,ADR(alrP_Temp1),byRow_Ad,byCol_Ad,ADR(alrAdT),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp2),ADR(alrCalValue));

	KS_MatrixAdd_L(byRow_P,byCol_P,ADR(alrP_Temp2),byRow_Q,byCol_Q,ADR(alrQ),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp3),ADR(alrCalValue));
	alrPh:=alrP_Temp3;

	rWf:=0; (*刚切换那一拍不起作用*)
	i_piK^:=i_piK^+1;(*更新拍数*)
ELSE (*第k拍(k>1)*)
(*计算Kalman增益 K=P_Fhat_k*CdT/(Cd*Ph*CdT+R)*)
	KS_MatrixMul_L(byRow_P,byCol_P,ADR(alrPh),byCol_Cd,byRow_Cd,ADR(alrCd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrK_Temp1),ADR(alrCalValue));

	lrTemp := alrCd[4]*alrCd[4]*alrPh[4,4] + rR ; (*因为C的前面均为0*)

	alrK[1]:=alrK_Temp1[1]/lrTemp;	alrK[2]:=alrK_Temp1[2]/lrTemp;
	alrK[3]:=alrK_Temp1[3]/lrTemp;	alrK[4]:=alrK_Temp1[4]/lrTemp;
(*计算后验状态估计X=Xh+K*(Y-Cd*Xh)*)
	lrTemp:=rY-alrCd[4]*alrXh[4];(*因为C的前面均为0*)
	alrX[1]:=alrXh[1]+alrK[1]*lrTemp;	alrX[2]:=alrXh[2]+alrK[2]*lrTemp;
	alrX[3]:=alrXh[3]+alrK[3]*lrTemp;	alrX[4]:=alrXh[4]+alrK[4]*lrTemp;
(*计算后验误差协方差矩阵P=(I-K*Cd)*Ph  *)
	KS_MatrixMul_L(byRow_X,byCol_X,ADR(alrK),byRow_Cd,byCol_Cd,ADR(alrCd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp1),ADR(alrCalValue));

	FOR iJ:=1 TO byCalValue_Row BY +1 DO
		FOR iM:=1 TO byCalValue_Column BY+1 DO
			alrP_Temp1[iJ,iM]:=-1.0*alrP_Temp1[iJ,iM];
		END_FOR
	END_FOR

	KS_MatrixAdd_L(byRow_I,byCol_I,ADR(alrI),byRow_P,byCol_P,ADR(alrP_Temp1),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp2),ADR(alrCalValue));

	KS_MatrixMul_L(byRow_P,byCol_P,ADR(alrP_Temp2),byRow_P,byCol_P,ADR(alrPh),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp3),ADR(alrCalValue));
	alrP:=alrP_Temp3;
(*计算线速度控制量Vdesign=-Kf*X_Bhat_k;  m/s*)
	(**LQR在线迭代*)
	(*arKidare = arX_DARE*arBd/(arBd'*arX_DARE*arBd+1); *)
	KS_MatrixMul_L(byRow_X_DARE,byCol_X_DARE,ADR(alrX_DARE),byRow_Bd,byCol_Bd,ADR(alrBd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrX_DARE_B),ADR(alrCalValue));

	KS_MatrixMul_L(byCol_Bd,byRow_Bd,ADR(alrBd),byRow_X_DARE,byCol_X_DARE,ADR(alrX_DARE),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrBT_X_DARE),ADR(alrCalValue));

	lrTemp_LQR1 := alrBT_X_DARE[1]*alrBd[1]+alrBT_X_DARE[2]*alrBd[2]+alrBT_X_DARE[3]*alrBd[3]+alrBT_X_DARE[4]*alrBd[4]+1.0;(**)
	alrKidare[1]  := alrX_DARE_B[1]/lrTemp_LQR1; 	alrKidare[2]  := alrX_DARE_B[2]/lrTemp_LQR1;	alrKidare[3]  := alrX_DARE_B[3]/lrTemp_LQR1;	alrKidare[4]  := alrX_DARE_B[4]/lrTemp_LQR1;

	alrKidare_old := alrKidare;

	rCNT := 1;
	(*开始迭代*)
	FOR iJ:=1 TO iMaxIterateNum BY +1 DO
		(*P_LQR=(I-Kidare*Bd')*arX_DARE;  *)
		KS_MatrixMul_L(byRow_Kidare,byCol_Kidare,ADR(alrKidare),byCol_Bd,byRow_Bd,ADR(alrBd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrKidare_BT),ADR(alrCalValue));

		alrI_Kidare_BT[1,1] := 1.0-1.0*alrKidare_BT[1,1];		alrI_Kidare_BT[1,2] := -1.0*alrKidare_BT[1,2];		alrI_Kidare_BT[1,3] := -1.0*alrKidare_BT[1,3];		alrI_Kidare_BT[1,4] := -1.0*alrKidare_BT[1,4];
		alrI_Kidare_BT[2,1] := -1.0*alrKidare_BT[2,1];		alrI_Kidare_BT[2,2] := 1.0-1.0*alrKidare_BT[2,2];		alrI_Kidare_BT[2,3] := -1.0*alrKidare_BT[2,3];		alrI_Kidare_BT[2,4] := -1.0*alrKidare_BT[2,4];
		alrI_Kidare_BT[3,1] := -1.0*alrKidare_BT[3,1];		alrI_Kidare_BT[3,2] := -1.0*alrKidare_BT[3,2];		alrI_Kidare_BT[3,3] :=1.0-1.0*alrKidare_BT[3,3];		alrI_Kidare_BT[3,4] := -1.0*alrKidare_BT[3,4];
		alrI_Kidare_BT[4,1] := -1.0*alrKidare_BT[4,1];		alrI_Kidare_BT[4,2] := -1.0*alrKidare_BT[4,2];		alrI_Kidare_BT[4,3] := -1.0*alrKidare_BT[4,3];		alrI_Kidare_BT[4,4] :=1.0 -1.0*alrKidare_BT[4,4];

		KS_MatrixMul_L(byRow_I_Kidare_BT,byCol_I_Kidare_BT,ADR(alrI_Kidare_BT),byRow_X_DARE,byCol_X_DARE,ADR(alrX_DARE),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_LQR),ADR(alrCalValue));

		(*X_DARE=Ad'*P_LQR*Ad+Q_LQR; *)
		KS_MatrixMul_L(byRow_Ad,byCol_Ad,ADR(alrAdT),byRow_P_LQR,byCol_P_LQR,ADR(alrP_LQR),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrTemp_X1),ADR(alrCalValue));
	
		KS_MatrixMul_L(byRow_X_DARE,byCol_X_DARE,ADR(alrTemp_X1),byRow_Ad,byCol_Ad,ADR(alrAd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrTemp_X2),ADR(alrCalValue));

		lrQ_LQR_4_4 := rN_LQR*rN_LQR*alrCd[4]*alrCd[4];
		alrTemp_X2[4,4] := alrTemp_X2[4,4]+lrQ_LQR_4_4; (*Q_LQR只有[4,4]不为0*)
		alrX_DARE := alrTemp_X2;

		(* Kidare=X_DARE*Bd/(Bd'*X_DARE*Bd+1);  *)
		KS_MatrixMul_L(byRow_X_DARE,byCol_X_DARE,ADR(alrX_DARE),byRow_Bd,byCol_Bd,ADR(alrBd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrX_DARE_B),ADR(alrCalValue));
	
		KS_MatrixMul_L(byCol_Bd,byRow_Bd,ADR(alrBd),byRow_X_DARE,byCol_X_DARE,ADR(alrX_DARE),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
		KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrBT_X_DARE),ADR(alrCalValue));

		lrTemp_LQR1 := alrBT_X_DARE[1]*alrBd[1]+alrBT_X_DARE[2]*alrBd[2]+alrBT_X_DARE[3]*alrBd[3]+alrBT_X_DARE[4]*alrBd[4]+1.0;(**)
		alrKidare[1]  := alrX_DARE_B[1]/lrTemp_LQR1; 	alrKidare[2]  := alrX_DARE_B[2]/lrTemp_LQR1;	alrKidare[3]  := alrX_DARE_B[3]/lrTemp_LQR1;	alrKidare[4]  := alrX_DARE_B[4]/lrTemp_LQR1;

		(*计算欧式距离*)
		lrD_Temp := (alrKidare_old[1]-alrKidare[1])*(alrKidare_old[1]-alrKidare[1])+(alrKidare_old[2]-alrKidare[2])*(alrKidare_old[2]-alrKidare[2])+
				(alrKidare_old[3]-alrKidare[3])*(alrKidare_old[3]-alrKidare[3])+(alrKidare_old[4]-alrKidare[4])*(alrKidare_old[4]-alrKidare[4]);
		lrD:= SQRT(lrD_Temp);
		IF lrD< 0.01 THEN
			i_pCached_Array_Pointers1^.alrX_DARE := alrX_DARE;
			EXIT;
		END_IF
		alrKidare_old := alrKidare;
		rCNT := rCNT +1;
	END_FOR

	(*2024.05.10.123500+*)
	IF rCNT>i_pCached_Array_Pointers1^.iMaxIterateCnt_LQR THEN
		i_pCached_Array_Pointers1^.iMaxIterateCnt_LQR:=REAL_TO_INT(rCNT);
	END_IF
(*Kf = -Kidare'*Ad;*)
	KS_MatrixMul_L(byCol_Kidare,byRow_Kidare,ADR(alrKidare),byRow_Ad,byCol_Ad,ADR(alrAd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrKf_Temp),ADR(alrCalValue));
	alrKf_Cal[1] := -1.0*alrKf_Temp[1];	alrKf_Cal[2] := -1.0*alrKf_Temp[2];	alrKf_Cal[3] := -1.0*alrKf_Temp[3];	alrKf_Cal[4] := -1.0*alrKf_Temp[4];

(*默认使用计算的Kf*)
	(*Kf*X_Bhat_k*)
	rVc := LREAL_TO_REAL(alrKf_Cal[1]*alrX[1]+alrKf_Cal[2]*alrX[2]+alrKf_Cal[3]*alrX[3]+alrKf_Cal[4]*alrX[4]);(*m/s*)
(*%Youla结构中的PI控制器*)
(*差分方程*)
	arUk_PI[1]:=rK_PI*(-i_rY);
	arYk_PI[1]:=1.0/(rb*rTs+2.0)*(-(rb*rTs-2.0)*arYk_PI[2]+(ra*rTs+2.0)*arUk_PI[1]+(ra*rTs-2.0)*arUk_PI[2]);

(*更新PI寄存器*)
	arYk_PI[2]:=arYk_PI[1];
	arUk_PI[2]:=arUk_PI[1];
(*输出*)
	rPI:=arYk_PI[1];

(*计算转速补偿量Wf r/min*)
	rWc:=(rVc+rPI)*i_rKc/rT;
	rWf:=rWc-rDeltaV/rT;

	IF rLim<>0 THEN(*<>0限制*)
		IF rWf<=-rLim THEN
			rWf:=-rLim;
		END_IF
		IF rWf>=rLim THEN
			rWf:=rLim;
		END_IF
	ELSE;(*=0不限制*)
	END_IF
	(*2023.09.08.164641*)
	IF i_xUseWfValue THEN(*使用估计的转速值到电机*);
	ELSE(*否则清零转速输出*)
		rWf:=0;(*只估计扰动不做补偿*)
	END_IF
(*计算下一拍的先验估计*)
	rVk:=rVc+rPI;   (* %注意这里没有Kc Kc是后续对纯时延的一个补偿*)
(*Xh=Ad*X+Bd*Vk*)
	KS_MatrixMul_L(byRow_Ad,byCol_Ad,ADR(alrAd),byRow_X,byCol_X,ADR(alrX),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrX_Temp1),ADR(alrCalValue));

	alrX_Temp2[1]:=alrBd[1]*rVk; alrX_Temp2[2]:=alrBd[2]*rVk;
	alrX_Temp2[3]:=alrBd[3]*rVk; alrX_Temp2[4]:=alrBd[4]*rVk;

	KS_MatrixAdd_L(byRow_X,byCol_X,ADR(alrX_Temp1),byRow_X,byCol_X,ADR(alrX_Temp2),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrX_Temp3),ADR(alrCalValue));
	alrXh:=alrX_Temp3;
(*Ph=Ad*P*AdT+Q*)
	KS_MatrixMul_L(byRow_Ad,byCol_Ad,ADR(alrAd),byRow_P,byCol_P,ADR(alrP),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp1),ADR(alrCalValue));

	KS_MatrixMul_L(byRow_P,byCol_P,ADR(alrP_Temp1),byRow_Ad,byCol_Ad,ADR(alrAdT),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp2),ADR(alrCalValue));

	KS_MatrixAdd_L(byRow_P,byCol_P,ADR(alrP_Temp2),byRow_Q,byCol_Q,ADR(alrQ),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(alrCalValue),ADR(alrCalValue_Mat));
	KS_Array2Mat_L(byCalValue_Row,byCalValue_Column,ADR(alrP_Temp3),ADR(alrCalValue));
	alrPh:=alrP_Temp3;

	i_piK^:=i_piK^+1;(*更新拍数*)
	iK:=i_piK^;
	IF iK>=1000 THEN
		i_piK^:=1000;(*更新拍数*)
	END_IF
END_IF

(*更新存储区的Uk_PI Yk_PI Xh Ph Wf *)
i_pCached_Array_Pointers1^.arUk_PI := arUk_PI;
i_pCached_Array_Pointers1^.arYk_PI := arYk_PI;

i_pCached_Array_Pointers1^.alrXh:=alrXh;
i_pCached_Array_Pointers1^.alrPh:=alrPh;

i_prWf^:=rWf;
i_prCNT^:= rCNT;