(*@CES
Name=Time_Variaition_PIMinBeat
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6bc5a795-796d-4607-9aa3-64e6bf4d9322
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Time_Variaition_PIMinBeat : REAL
(*2024.05.07.105727 调整接口名by Liu*)
VAR_INPUT
(*	i_xFilmToBig:BOOL;(*TRUE:料膜变大；FALSE:料膜变小*)*)
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
	i_stKalman_Status_Estimation_And_Feedback_MinBeat1:Kalman_Status_Estimation_And_Feedback_MinBeat;(*2024.05.07.105319 修改接口名by Liu*)
	i_stPI_Parameters1:PI_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
	i_pCached_Array_Pointers1: POINTER TO Cached_Array_Pointers;
END_VAR

VAR
	Invariant_Parameters1:Invariant_Parameters;
	Time_Varying_Parameters1:Time_Varying_Parameters;
	Kalman_Status_Estimation_And_Feedback_MinBeat1:Kalman_Status_Estimation_And_Feedback_MinBeat;
	PI_Parameters1:PI_Parameters;
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
	arA:ARRAY [1..4,1..4] OF REAL;
	arAd:ARRAY [1..4,1..4] OF REAL;
	arAdT:ARRAY [1..4,1..4] OF REAL;
	byRow_Ad:BYTE :=4;
	byCol_Ad:BYTE :=4;
	arB:ARRAY [1..4] OF REAL;
	arBd:ARRAY [1..4] OF REAL;
	byRow_Bd:BYTE :=4;
	byCol_Bd:BYTE :=1;
	arC:ARRAY [1..4] OF REAL;
	arCd:ARRAY [1..4] OF REAL;
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
	arA2:ARRAY [1..4,1..4] OF REAL;        (*A矩阵的2次方*)
(*单位矩阵*)
	arI:ARRAY [1..4,1..4] OF REAL;
	byRow_I:BYTE:=4;
	byCol_I:BYTE:=4;
(*计算过程中的临时变量/矩阵*)
	arCalValue:ARRAY [1..MATRIX_ELEMENT_MAX] OF REAL;(*计算出的值按一维数组存放*)
	arCalValue_Mat:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*一个MATRIX_ROW_MAX x MATRIX_COLUMN_MAX的矩阵|用于存放计算后的数据|AxB*)
	byCalValue_Row:BYTE;(*行数|计算后*)
	byCalValue_Column:BYTE;(*列|计算后*)
(*离散缓存矩阵*)
	arTsA:ARRAY[1..4,1..4] OF REAL;
	arTs2A2:ARRAY[1..4,1..4] OF REAL;
	arTempAd:ARRAY[1..4,1..4] OF REAL;

	arAB:ARRAY[1..4] OF REAL;
	arA2B:ARRAY[1..4] OF REAL;
	arTsB:ARRAY[1..4] OF REAL;
	arTs2AB:ARRAY[1..4] OF REAL;
	arTs3A2B:ARRAY[1..4] OF REAL;
	arTempBd:ARRAY[1..4] OF REAL;
(*Kalman计算相关*)
	(*初始误差矩阵*)
	arP0:ARRAY [1..4,1..4] OF REAL;(*初始为0矩阵*)
	byRow_P:BYTE:=4;
	byCol_P:BYTE:=4;
	(*R Q 矩阵*)
	rR:REAL;
	arQ:ARRAY [1..4,1..4] OF REAL;
	byRow_Q:BYTE:=4;
	byCol_Q:BYTE:=4;
	(*初始状态*)
	arX0:ARRAY[1..4] OF REAL;
	byRow_X:BYTE:=4;
	byCol_X:BYTE:=1;
	(*拍数计数*)
	iK:INT:=0;
	(*第一拍的摆臂输入*)
	rY0:REAL;
	(*卡尔曼增益K*)
	arK: ARRAY [1..4] OF REAL;
(*
	byRow_K:BYTE:=4;
	byCol_K:BYTE:=1;
*)
	(*先验状态估计和先验误差协方差矩阵*)
	arXh:ARRAY[1..4] OF REAL;
	arPh:ARRAY[1..4,1..4] OF REAL;
	(*后验状态估计和后验误差协方差矩阵*)
	arX:ARRAY[1..4] OF REAL;
	arP:ARRAY[1..4,1..4] OF REAL;
	(*计算过程中的临时变量/矩阵*)
	rTemp:REAL;

	arX_Temp1:ARRAY[1..4] OF REAL;
	arX_Temp2:ARRAY[1..4] OF REAL;
	arX_Temp3:ARRAY[1..4] OF REAL;

	arP_Temp1:ARRAY[1..4,1..4] OF REAL;
	arP_Temp2:ARRAY[1..4,1..4] OF REAL;
	arP_Temp3:ARRAY[1..4,1..4] OF REAL;

	arAn_Temp:ARRAY[1..4,1..4] OF REAL;
	arAn_1_Temp:ARRAY[1..4,1..4] OF REAL;

	arAX_Temp1:ARRAY[1..4] OF REAL;
	rCAX_Temp1:REAL;
	arAB_Temp1:ARRAY[1..4] OF REAL;
	rCAB_Temp1:REAL;

	arK_Temp1:ARRAY[1..4] OF REAL;

(*LQR计算*)
	rCNT:REAL;
(*	iN_LQR:INT;
	iN_LQR_1:INT;*)
	iN_MinBeat:INT;
	iN_MinBeat_1:INT;
	arKf:ARRAY [1..4] OF REAL;(*设置的Kf*)
(*
	arKf_Cal:ARRAY [1..4] OF REAL;(*计算的Kf*)
	byRow_Kf:BYTE:=1;
	byCol_Kf:BYTE:=4;

*)
	arX_DARE:ARRAY [1..4,1..4] OF REAL;(*上一个周期已经迭代收敛的值X_Dare*)
(*
	byRow_X_DARE:BYTE:=4;
	byCol_X_DARE:BYTE:=4;
	(*中间变量和矩阵*)
	arKidare:ARRAY [1..4] OF REAL;
	byRow_Kidare:BYTE:=4;
	byCol_Kidare:BYTE:=1;
	arKidare_old:ARRAY [1..4] OF REAL;
	rQ_LQR_4_4:REAL;
	arX_LQR:ARRAY [1..4,1..4] OF REAL;
	byRow_X_LQR:BYTE:=4;
	byCol_X_LQR:BYTE:=4;

	arX_DARE_B:ARRAY [1..4] OF REAL;
	arBT_X_DARE:ARRAY [1..4] OF REAL;

	arKidare_BT:ARRAY [1..4,1..4] OF REAL;
	arI_Kidare_BT:ARRAY [1..4,1..4] OF REAL;
	byRow_I_Kidare_BT:BYTE:=4;
	byCol_I_Kidare_BT:BYTE:=4;
	arP_LQR:ARRAY [1..4,1..4] OF REAL;
	byRow_P_LQR:BYTE:=4;
	byCol_P_LQR:BYTE:=4;

	rTemp_LQR1:REAL;

	arTemp_X1:ARRAY [1..4,1..4] OF REAL;
	arTemp_X2:ARRAY [1..4,1..4] OF REAL;


	rD:REAL;(*计算两个向量的欧式距离*)
	rD_Temp:REAL;
	arKf_Temp:ARRAY [1..4] OF REAL;
*)

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
	iMaxIterateNum: INT:=100;(*最大迭代次数值@2024.05.10.123127+*)
END_VAR
{IMPLEMENTATION}
(*	i_rKc:=ABS(i_rKc);
	IF i_xFilmToBig THEN(*收料使用大值*);
	ELSE(*放料@使用负值*)
		i_rKc:=-i_rKc;
	END_IF
*)
	(*2024.05.07.105445+by Liu*)
	Invariant_Parameters1:=i_stInvariant_Parameters1;
	Time_Varying_Parameters1:=i_stTime_Varying_Parameters1;
	Kalman_Status_Estimation_And_Feedback_MinBeat1:=i_stKalman_Status_Estimation_And_Feedback_MinBeat1;
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
	arI[1,1] := 1.0;	arI[2,2] := 1.0;	arI[3,3] := 1.0;	arI[4,4] := 1.0;

	(*A矩阵*)
	arA[1,1] := -1.0/b1;  			arA[1,2] := 0.0;			arA[1,3] := 0.0; 			 arA[1,4] := 0.0;
	arA[2,1] := 1.0;  				arA[2,2] := 0.0; 			arA[2,3] := -1.0; 			 arA[2,4] := 0.0;
	arA[3,1] := 2.0*l*Beta*Wn;  		arA[3,2] := Wn*Wn;		arA[3,3] := -2.0*Beta*Wn;	 arA[3,4] := 0.0;
	arA[4,1] := 0.0; 				arA[4,2] := 0.0; 			arA[4,3] := rK_adj; 		 arA[4,4] := -a0;
	(*B矩阵*)
	arB[1] := 1/b1;				arB[2] := 0.0;			arB[3] := 0.0;			arB[4] := 0.0;
	(*C矩阵*)
	arC[1] := 0.0;				arC[2] := 0.0;			arC[3] := 0.0;			arC[4] := Ku;

	(*离散化*)
	(*A^2*)
		KS_Matrix_N(byRow_Ad,byCol_Ad,2,ADR(arA),0,0,ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byRow_Ad,byCol_Ad,ADR(arA2),ADR(arCalValue));
	(*Ad =  I+Ts*A+Ts^2/2*A2; *)
	(*arTsA = Ts*A  arTs2A2=Ts *)
		FOR iN:=1 TO byRow_Ad BY 1 DO(*A矩阵的行*)
			FOR iM:=1 TO byCol_Ad BY 1 DO(*A矩阵的列*)
				arTsA[iN,iM]:= arA[iN,iM]*rTs;
				arTs2A2[iN,iM]:= arA2[iN,iM]*rTs*rTs/2.0;
			END_FOR
		END_FOR
	(*相加*)
	(*I+Ts*A*)
	arTempAd := arTsA;
	arTempAd[1,1] :=arTempAd[1,1]+1.0;	arTempAd[2,2] :=arTempAd[2,2]+1.0;  arTempAd[3,3] :=arTempAd[3,3]+1.0;  arTempAd[4,4] :=arTempAd[4,4]+1.0;
	(* I+Ts*A+Ts^2/2*A2 *)
	KS_MatrixAdd(byRow_Ad,byCol_Ad,ADR(arTempAd),byRow_Ad,byCol_Ad,ADR(arTs2A2),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arAd),ADR(arCalValue));
	
	(*arAdT*)
		FOR iN:=1 TO byRow_Ad BY 1 DO(*A矩阵的行*)
			FOR iM:=1 TO byCol_Ad BY 1 DO(*A矩阵的列*)
				arAdT[iN,iM]:= arAd[iM,iN];
			END_FOR
		END_FOR
	
	(*Bd =  Ts*B+Ts^2/2*A*B+Ts^3/6*A2*B *)
	(* A*B *)
		KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arA),byRow_Bd,byCol_Bd,ADR(arB),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arAB),ADR(arCalValue));
	(* A2*B *)
		KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arA2),byRow_Bd,byCol_Bd,ADR(arB),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arA2B),ADR(arCalValue));
	(*Ts*B ; Ts^2/2*A*B ; Ts^3/6*A2*B *)
		FOR iN:=1 TO byRow_Bd BY 1 DO(*B矩阵的行*)
			arTsB[iN]:= arB[iN]*rTs;
			arTs2AB[iN]:= arAB[iN]*rTs*rTs/2.0;
			arTs3A2B[iN]:= arA2B[iN]*rTs*rTs*rTs/6.0;
		END_FOR
	(*相加*)
		KS_MatrixAdd(byRow_Bd,byCol_Bd,ADR(arTsB),byRow_Bd,byCol_Bd,ADR(arTs2AB),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arTempBd),ADR(arCalValue));
	
		KS_MatrixAdd(byRow_Bd,byCol_Bd,ADR(arTempBd),byRow_Bd,byCol_Bd,ADR(arTs3A2B),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arBd),ADR(arCalValue));
	(*Cd = C*)
		arCd := arC;
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
	rR := Kalman_Status_Estimation_And_Feedback_MinBeat1.R_K;
	arQ := Kalman_Status_Estimation_And_Feedback_MinBeat1.Q;
	arP0 := Kalman_Status_Estimation_And_Feedback_MinBeat1.P0;

	arPh := i_pCached_Array_Pointers1^.arPh;		(*上一个周期的先验状态误差协方差矩阵*)
	arXh := i_pCached_Array_Pointers1^.arXh;		(*上一个周期估计状态向量Xh指针*)
(*LQR Kf*)
	(*iN_MinBeat*)
	iN_MinBeat := Kalman_Status_Estimation_And_Feedback_MinBeat1.N_MinBeat;
	(*固定的Kf*)
	arKf := Kalman_Status_Estimation_And_Feedback_MinBeat1.Kf;
	(*LQR迭代求解DARE*)
	arX_DARE := i_pCached_Array_Pointers1^.arX_DARE;(*上一个周期已经迭代收敛的值X_Dare*)
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
	arX0[1] := 0 ; arX0[2] := 0; arX0[3] := 0; arX0[4] := rY0/arCd[4];
(*计算Xh Ph*)
(*Xh=Ad*X0+Bd*DeltaV*)
	KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arAd),byRow_X,byCol_X,ADR(arX0),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arX_Temp1),ADR(arCalValue));

	arX_Temp2[1]:=arBd[1]*rDeltaV;arX_Temp2[2]:=arBd[2]*rDeltaV;
	arX_Temp2[3]:=arBd[3]*rDeltaV;

	KS_MatrixAdd(byRow_X,byCol_X,ADR(arX_Temp1),byRow_X,byCol_X,ADR(arX_Temp2),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arX_Temp3),ADR(arCalValue));
	arXh:=arX_Temp3;
(*Ph=Ad*P0*AdT+Q*)
	KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arAd),byRow_P,byCol_P,ADR(arP0),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp1),ADR(arCalValue));

	KS_MatrixMul(byRow_P,byCol_P,ADR(arP_Temp1),byRow_Ad,byCol_Ad,ADR(arAdT),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp2),ADR(arCalValue));

	KS_MatrixAdd(byRow_P,byCol_P,ADR(arP_Temp2),byRow_Q,byCol_Q,ADR(arQ),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp3),ADR(arCalValue));
	arPh:=arP_Temp3;

	rWf:=0; (*刚切换那一拍不起作用*)
	i_piK^:=i_piK^+1;(*更新拍数*)
ELSE (*第k拍(k>1)*)
(*计算Kalman增益 K=P_Fhat_k*CdT/(Cd*Ph*CdT+R)*)
	KS_MatrixMul(byRow_P,byCol_P,ADR(arPh),byCol_Cd,byRow_Cd,ADR(arCd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arK_Temp1),ADR(arCalValue));

	rTemp := arCd[4]*arCd[4]*arPh[4,4] + rR ; (*因为C的前面均为0*)

	arK[1]:=arK_Temp1[1]/rTemp;	arK[2]:=arK_Temp1[2]/rTemp;
	arK[3]:=arK_Temp1[3]/rTemp;	arK[4]:=arK_Temp1[4]/rTemp;
(*计算后验状态估计X=Xh+K*(Y-Cd*Xh)*)
	rTemp:=rY-arCd[4]*arXh[4];(*因为C的前面均为0*)
	arX[1]:=arXh[1]+arK[1]*rTemp;	arX[2]:=arXh[2]+arK[2]*rTemp;
	arX[3]:=arXh[3]+arK[3]*rTemp;	arX[4]:=arXh[4]+arK[4]*rTemp;
(*计算后验误差协方差矩阵P=(I-K*Cd)*Ph  *)
	KS_MatrixMul(byRow_X,byCol_X,ADR(arK),byRow_Cd,byCol_Cd,ADR(arCd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp1),ADR(arCalValue));

	FOR iJ:=1 TO byCalValue_Row BY +1 DO
		FOR iM:=1 TO byCalValue_Column BY+1 DO
			arP_Temp1[iJ,iM]:=-1.0*arP_Temp1[iJ,iM];
		END_FOR
	END_FOR

	KS_MatrixAdd(byRow_I,byCol_I,ADR(arI),byRow_P,byCol_P,ADR(arP_Temp1),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp2),ADR(arCalValue));

	KS_MatrixMul(byRow_P,byCol_P,ADR(arP_Temp2),byRow_P,byCol_P,ADR(arPh),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp3),ADR(arCalValue));
	arP:=arP_Temp3;
(*计算线速度控制量Vdesign=-Kf*X_Bhat_k;  m/s*)

(*计算线速度控制量Vdesign=-(Ckd*(Akd^n)*X_Bhat_k)/(Ckd*(Akd^(n-1))*Bkd);  m/s*)
iN_MinBeat_1 := iN_MinBeat -1;
(*Akd^n*)
	KS_Matrix_N(byRow_Ad,byCol_Ad,iN_MinBeat,ADR(arAd),0,0,ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byRow_Ad,byCol_Ad,ADR(arAn_Temp),ADR(arCalValue));
(*Akd^(n-1)*)
	KS_Matrix_N(byRow_Ad,byCol_Ad,iN_MinBeat_1,ADR(arAd),0,0,ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byRow_Ad,byCol_Ad,ADR(arAn_1_Temp),ADR(arCalValue));
(*Akd^n*X_Bhat_k *)
	KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arAn_Temp),byRow_X,byCol_X,ADR(arX),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arAX_Temp1),ADR(arCalValue));
(*-Ckd*Akd^n*X_Bhat_k *)
	rCAX_Temp1:=-(arCd[1]*arAX_Temp1[1]+arCd[2]*arAX_Temp1[2]
	       +arCd[3]*arAX_Temp1[3] +arCd[4]*arAX_Temp1[4]);
(*(Akd^(n-1))*Bkd*)
	KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arAn_1_Temp),byRow_Bd,byCol_Bd,ADR(arBd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arAB_Temp1),ADR(arCalValue));
(*Ckd*(Akd^(n-1))*Bkd*)
	rCAB_Temp1:=(arCd[1]*arAB_Temp1[1]+arCd[2]*arAB_Temp1[2]
	       +arCd[3]*arAB_Temp1[3]+arCd[4]*arAB_Temp1[4]);

	rVc:=rCAX_Temp1/rCAB_Temp1;(*m/s*)
(*
	(**LQR在线迭代*)
	(*arKidare = arX_DARE*arBd/(arBd'*arX_DARE*arBd+1); *)
	KS_MatrixMul(byRow_X_DARE,byCol_X_DARE,ADR(arX_DARE),byRow_Bd,byCol_Bd,ADR(arBd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arX_DARE_B),ADR(arCalValue));

	KS_MatrixMul(byCol_Bd,byRow_Bd,ADR(arBd),byRow_X_DARE,byCol_X_DARE,ADR(arX_DARE),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arBT_X_DARE),ADR(arCalValue));

	rTemp_LQR1 := arBT_X_DARE[1]*arBd[1]+arBT_X_DARE[2]*arBd[2]+arBT_X_DARE[3]*arBd[3]+arBT_X_DARE[4]*arBd[4]+1.0;(**)
	arKidare[1]  := arX_DARE_B[1]/rTemp_LQR1; 	arKidare[2]  := arX_DARE_B[2]/rTemp_LQR1;	arKidare[3]  := arX_DARE_B[3]/rTemp_LQR1;	arKidare[4]  := arX_DARE_B[4]/rTemp_LQR1;

	arKidare_old := arKidare;

	rCNT := 1;
	(*开始迭代*)
	FOR iJ:=1 TO iMaxIterateNum BY +1 DO
		(*P_LQR=(I-Kidare*Bd')*arX_DARE;  *)
		KS_MatrixMul(byRow_Kidare,byCol_Kidare,ADR(arKidare),byCol_Bd,byRow_Bd,ADR(arBd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arKidare_BT),ADR(arCalValue));
	
		arI_Kidare_BT[1,1] := 1.0-1.0*arKidare_BT[1,1];		arI_Kidare_BT[1,2] := -1.0*arKidare_BT[1,2];		arI_Kidare_BT[1,3] := -1.0*arKidare_BT[1,3];		arI_Kidare_BT[1,4] := -1.0*arKidare_BT[1,4];
		arI_Kidare_BT[2,1] := -1.0*arKidare_BT[2,1];		arI_Kidare_BT[2,2] := 1.0-1.0*arKidare_BT[2,2];		arI_Kidare_BT[2,3] := -1.0*arKidare_BT[2,3];		arI_Kidare_BT[2,4] := -1.0*arKidare_BT[2,4];
		arI_Kidare_BT[3,1] := -1.0*arKidare_BT[3,1];		arI_Kidare_BT[3,2] := -1.0*arKidare_BT[3,2];		arI_Kidare_BT[3,3] :=1.0-1.0*arKidare_BT[3,3];		arI_Kidare_BT[3,4] := -1.0*arKidare_BT[3,4];
		arI_Kidare_BT[4,1] := -1.0*arKidare_BT[4,1];		arI_Kidare_BT[4,2] := -1.0*arKidare_BT[4,2];		arI_Kidare_BT[4,3] := -1.0*arKidare_BT[4,3];		arI_Kidare_BT[4,4] :=1.0 -1.0*arKidare_BT[4,4];
	
		KS_MatrixMul(byRow_I_Kidare_BT,byCol_I_Kidare_BT,ADR(arI_Kidare_BT),byRow_X_DARE,byCol_X_DARE,ADR(arX_DARE),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_LQR),ADR(arCalValue));
	
		(*X_DARE=Ad'*P_LQR*Ad+Q_LQR; *)
		KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arAdT),byRow_P_LQR,byCol_P_LQR,ADR(arP_LQR),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arTemp_X1),ADR(arCalValue));
	
		KS_MatrixMul(byRow_X_DARE,byCol_X_DARE,ADR(arTemp_X1),byRow_Ad,byCol_Ad,ADR(arAd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arTemp_X2),ADR(arCalValue));
	
		rQ_LQR_4_4 := rN_LQR*rN_LQR*arCd[4]*arCd[4];
		arTemp_X2[4,4] := arTemp_X2[4,4]+rQ_LQR_4_4; (*Q_LQR只有[4,4]不为0*)
		arX_DARE := arTemp_X2;

		(* Kidare=X_DARE*Bd/(Bd'*X_DARE*Bd+1);  *)
		KS_MatrixMul(byRow_X_DARE,byCol_X_DARE,ADR(arX_DARE),byRow_Bd,byCol_Bd,ADR(arBd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arX_DARE_B),ADR(arCalValue));
	
		KS_MatrixMul(byCol_Bd,byRow_Bd,ADR(arBd),byRow_X_DARE,byCol_X_DARE,ADR(arX_DARE),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
		KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arBT_X_DARE),ADR(arCalValue));

		rTemp_LQR1 := arBT_X_DARE[1]*arBd[1]+arBT_X_DARE[2]*arBd[2]+arBT_X_DARE[3]*arBd[3]+arBT_X_DARE[4]*arBd[4]+1.0;(**)
		arKidare[1]  := arX_DARE_B[1]/rTemp_LQR1; 	arKidare[2]  := arX_DARE_B[2]/rTemp_LQR1;	arKidare[3]  := arX_DARE_B[3]/rTemp_LQR1;	arKidare[4]  := arX_DARE_B[4]/rTemp_LQR1;

		rD_Temp := (arKidare_old[1]-arKidare[1])*(arKidare_old[1]-arKidare[1])+(arKidare_old[2]-arKidare[2])*(arKidare_old[2]-arKidare[2])+
				(arKidare_old[3]-arKidare[3])*(arKidare_old[3]-arKidare[3])+(arKidare_old[4]-arKidare[4])*(arKidare_old[4]-arKidare[4]);
		rD:= SQRT(rD_Temp);
		IF rD< 0.01 THEN
			i_pCached_Array_Pointers1^.arX_DARE := arX_DARE;
			EXIT;
		END_IF
		arKidare_old := arKidare;
		rCNT := rCNT +1;
	END_FOR
(*Kf = -Kidare'*Ad;*)
	KS_MatrixMul(byCol_Kidare,byRow_Kidare,ADR(arKidare),byRow_Ad,byCol_Ad,ADR(arAd),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arKf_Temp),ADR(arCalValue));
	arKf_Cal[1] := -1.0*arKf_Temp[1];	arKf_Cal[2] := -1.0*arKf_Temp[2];	arKf_Cal[3] := -1.0*arKf_Temp[3];	arKf_Cal[4] := -1.0*arKf_Temp[4];

(*默认使用计算的Kf*)
	(*Kf*X_Bhat_k*)
	rVc := arKf_Cal[1]*arX[1]+arKf_Cal[2]*arX[2]+arKf_Cal[3]*arX[3]+arKf_Cal[4]*arX[4];(*m/s*)
*)
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
	KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arAd),byRow_X,byCol_X,ADR(arX),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arX_Temp1),ADR(arCalValue));

	arX_Temp2[1]:=arBd[1]*rVk; arX_Temp2[2]:=arBd[2]*rVk;
	arX_Temp2[3]:=arBd[3]*rVk; arX_Temp2[4]:=arBd[4]*rVk;

	KS_MatrixAdd(byRow_X,byCol_X,ADR(arX_Temp1),byRow_X,byCol_X,ADR(arX_Temp2),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arX_Temp3),ADR(arCalValue));
	arXh:=arX_Temp3;
(*Ph=Ad*P*AdT+Q*)
	KS_MatrixMul(byRow_Ad,byCol_Ad,ADR(arAd),byRow_P,byCol_P,ADR(arP),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp1),ADR(arCalValue));

	KS_MatrixMul(byRow_P,byCol_P,ADR(arP_Temp1),byRow_Ad,byCol_Ad,ADR(arAdT),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp2),ADR(arCalValue));

	KS_MatrixAdd(byRow_P,byCol_P,ADR(arP_Temp2),byRow_Q,byCol_Q,ADR(arQ),ADR(byCalValue_Row),ADR(byCalValue_Column),ADR(arCalValue),ADR(arCalValue_Mat));
	KS_Array2Mat(byCalValue_Row,byCalValue_Column,ADR(arP_Temp3),ADR(arCalValue));
	arPh:=arP_Temp3;

	i_piK^:=i_piK^+1;(*更新拍数*)
	iK:=i_piK^;
	IF iK>=1000 THEN
		i_piK^:=1000;(*更新拍数*)
	END_IF
(*
	IF iK<=5 THEN(*2024.05.14.192812+*)
		rWf:=0; (*前5拍先写0*)
	END_IF
*)
END_IF

(*更新存储区的Uk_PI Yk_PI Xh Ph Wf *)
	 i_pCached_Array_Pointers1^.arUk_PI := arUk_PI;
	 i_pCached_Array_Pointers1^.arYk_PI := arYk_PI;

	i_pCached_Array_Pointers1^.arXh:=arXh;
	i_pCached_Array_Pointers1^.arPh:=arPh;

	i_prWf^:=rWf;
	i_prCNT^:= rCNT;