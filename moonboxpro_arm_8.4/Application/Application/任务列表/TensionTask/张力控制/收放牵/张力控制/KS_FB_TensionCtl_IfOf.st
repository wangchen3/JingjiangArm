(*@CES
Name=KS_FB_TensionCtl_IfOf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b7b8bc31-4f35-42b3-88de-f6b214f8ce5f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_TensionCtl_IfOf
(*摆臂负值-料膜为松弛状态|负值输出减速|反之加速*)
(*2021.10.23.093343  新增的张力控制模块|主要用于收放牵控制*)
VAR_INPUT
	i_xEn: BOOL;(*张力模块使能*)
	i_xCanAdjEn: BOOL;(*调整和非调整切换标志|算法需要*)
	i_xIsDebugMode:BOOL;(*调试模式*)
	i_xNegative_PiValue:BOOL;(*pi取反*)
	i_xMachineRev:BOOL;(*反向走料信号*)
	i_rAI_Swing: REAL; (*摆臂模拟量*)
	i_rVel_Film:REAL;(*当前料膜速度*)
//	i_iPiVelLimit:INT;(*pi限值-最大调整10M/MIN*)
	i_xFilmAccDecDone:BOOL;(*料膜加速完成标志*)
	i_iTimeTo0WhenDisEn:INT:=1;(*当前速度在取消使能时到0速的规划时间|s-写0则不规划*)
	i_iCycleTime_Plc:INT;(*程序执行周期*)
	i_rKp:REAL;
	i_rKi:REAL;
	i_rKd:REAL;
	i_byVelLimit_PerCent:BYTE;(*速度限制百分比%*)	
	i_xFeedlimitWarnFlag:BOOL;(*牵引速度限制提示开关*)
	i_iFeedLimitWarnCoff: INT;(*牵引限制系数*)
	i_rUsingGirth:REAL;(*调整后的周长返回值*)
	i_xAdjustMode:BOOL;(*调整开关*)
	i_rGirth_Input:REAL;(*界面输入周长*)
	i_iVel_Max:INT;(*主机最大速度|2021.2.2.110402 增加|调整else的时候使用最大速度计算加速度*)	

	i_uiMaxVel_UseCalcAcc:UINT;(*最大速度,用于计算最大加减速@2024.04.12.165352*)

	(*2024.05.24.110325+*)
	i_xPseudoRandomId					:BOOL;(*=True*)
	i_xPseudoRandomEn					:BOOL;(*伪随机使能|功能使能*)
	i_xPseudoRandomTsting				:BOOL;(*伪随机使能了*)
	i_rPseudoRandomRoundAmplitude_Cur	:REAL;
	i_pbySetTestPid						:POINTER TO BYTE;(*设置测试的pid*)
	i_iPseudoRandomRound_Kp_1			:INT;
	i_iPseudoRandomRound_Kd_1			:INT;
	i_iPseudoRandomRound_Kp_2			:INT;
	i_iPseudoRandomRound_Kd_2			:INT;
	i_iPseudoRandomRound_Kp_3			:INT;
	i_iPseudoRandomRound_Kd_3			:INT;

	i_xPidType						:BOOL;(*false=原来方式\true=新的*)

	i_xUseAntiNotch					:BOOL;(*输入使用陷波*)
	i_prWn							:POINTER TO REAL;
	i_prBw							:POINTER TO REAL;
	i_prDp							:POINTER TO REAL;

	(*扰动输出的控制输入参数@2024.12.3.102359*)
	i_xEn_Disturbance:BOOL;(*扰动使能@需要常有效*)
	i_rFreq_Disturbance:REAL;(*扰动频率@hz*)
	i_rAmplitude_Disturbance:REAL;(*扰动幅值*)
	i_uiTotalTime_Disturbance:UINT;(*扰动输出的总时间|=0 代表一直输出@s*)
	
	i_xRollerSts_Pu: BOOL;
END_VAR
VAR_OUTPUT
	o_xEno :BOOL;
	o_iErNo: INT;	
	o_rVel: REAL;
	o_rPi_Value:REAL;
	o_rForwardStep:REAL;
	o_rVel_rpm:REAL;(*转速@r/min*)
	o_xOuting_sin:BOOL;(*正弦输出中@2024.12.3.110839*)
	o_rResult_sin:REAL;(*正弦输出值@2024.12.3.110839*)	
END_VAR
VAR
	iN: INT;
	rKp : REAL; (*P值*)
	rKi : REAL; (*I值*)
	rKd: REAL;(*D值*)

	iVoltTotalTimes: INT := 0;
	iVoltAverageMaxTimes: INT := 20; (*模拟采集平均次数*)
	arVolt: ARRAY [1..20] OF REAL := [20(0)]; (*历史模拟量列表*)
	rVoltSum: REAL; (*模拟量累计*)
	rFormulaResult: REAL; (*PID运算后的放牵调整值*)
	rVoltFinal: REAL; (*最终用的模拟量*)
	rTempResult: REAL; (*临时的输出结果*)
	rMaxDelVel: REAL;
	rForwardStep: REAL;(*前馈步进值*)
	rPreFilmVelocity: REAL;
	rPIValueLimit_Zero: REAL:=0.02;(*0速最大调整量*)
	iVelocityLimit: INT:=2;(*零速最大调整速度限值*)
	iNum_Old: INT := 5;
	iTimeTo0WhenDisEn:INT:=1;(*当前速度在取消使能时到0速的规划时间|s*)
	lrVel_Acceleration: LREAL:=0;(*速度规划到0加速度*)
	xFilmDecFlag: BOOL:=FALSE;(*料膜减速标志*)
	rTempVel: REAL;(*临时速度*)
	xIsDebugging: BOOL;(*调试中标志*)
	arAntiNotchU_Uk: ARRAY [1..3] OF REAL;
	arAntiNotchU_Yk: ARRAY [1..3] OF REAL;
	rAntiNotch_Out: REAL;	
	rAI_cur: REAL;
	bySetTestPid: BYTE;(*设置伪随机pid*)	
	rDeltaTmp: REAL;
	rPseudoRandomRoundAmplitude_Cur: REAL;(*伪随机当前值*)
	rPseudoRandomRoundAmplitude_Cur_Last: REAL;
	rPseudoRandomAmplitude_Delta: REAL;
	(*2024.05.25.104740*)
	rYI: REAL;(*积分控制输出寄存器*)
	rYD: REAL;(*微分控制输出寄存器*)
	rYout: REAL;
	arEk:ARRAY [1..2] OF REAL;(*误差寄存器 [e(k);e(k-1)]*)
	(*2025.1.12.152712+*)
	rYout_Tmp: REAL;
	xCtlEn: BOOL;(*控制使能*)
	xCtlEn_Last: BOOL;
	lrX_sin:LREAL;(*正弦的时间轴*)
	rResult_sin:REAL;(*正弦值*)	
	rVel_Disturbance: REAL;(*放牵扰动值*)	
	rTmp: REAL;
	rDelt: REAL;
	lrTempVel: LREAL;
END_VAR
{IMPLEMENTATION}
rMaxDelVel:=0.3;(*=300/20/50 20S加速到300m/min的时候一个周期速度的变化量*)(*2018.5.22.115216 增加调整量限值*)
rPIValueLimit_Zero:=0.03;(*0速时调整量限值*)
//iVelocityLimit:=i_iPiVelLimit;

(*2022.9.20.143232 速度限制使用%|最小2m/min 最大10m/min*)
IF i_byVelLimit_PerCent<>0 THEN
	iVelocityLimit:=LREAL_TO_INT(i_byVelLimit_PerCent*i_rVel_Film/100);
ELSE(*等于0按照10m/min限制-以前一直使用该值*)
	iVelocityLimit:=10;
END_IF

IF iVelocityLimit<2 THEN
	iVelocityLimit:=2;
ELSIF iVelocityLimit>10 THEN
	iVelocityLimit:=10;
END_IF

IF i_rVel_Film=0 THEN(*料膜速度为0速的时候，调整牵引到中位。对速度进行限值*)(*2018.7.11.223054*)
	iVelocityLimit:=2;
END_IF
(*2025.3.7.100539*)
(*参数初始化*)
IF i_prWn<>0 AND i_prBw<>0 AND i_prDp <>0 THEN
	IF i_prWn^=0 THEN
		i_prWn^:=1;
	END_IF
	IF i_prBw^=0 THEN
		i_prBw^:=2;
	END_IF
	IF i_prDp^=0 THEN
		i_prDp^:=20;
	END_IF
END_IF

IF i_xEn AND i_rVel_Film>0 THEN
	(*放牵*)
	IF i_prWn<>0 AND i_prBw<>0 AND i_prDp <>0 THEN
		AntiNotch(
			i_rAI_Swing(*i_rU*),
			ADR(rAntiNotch_Out)(*i_prYout*),
			i_prWn^(*i_rWn*),
			i_prBw^(*i_rBw*),
			i_prDp^(*i_rDp*),
			INT_TO_REAL(i_iCycleTime_Plc)/1000.0(*i_rTs*),
			ADR(arAntiNotchU_Uk)(*i_prUk*),
			ADR(arAntiNotchU_Yk)(*i_prYk*));
	END_IF
ELSE
	SysMemSet(ADR(arAntiNotchU_Uk),0,SIZEOF(arAntiNotchU_Uk));
	SysMemSet(ADR(arAntiNotchU_Yk),0,SIZEOF(arAntiNotchU_Yk));
END_IF


IF i_xUseAntiNotch THEN
	rAI_cur:=rAntiNotch_Out;
ELSE
	rAI_cur:=i_rAI_Swing;
END_IF

(*han.dp@2017-08-13 15:49:11
/.重新对要使用的模拟量进行一个简单的滤波
/.*)
FOR iN:=iVoltAverageMaxTimes TO 2 BY -1 DO
	arVolt[iN]:= arVolt[iN-1];
END_FOR
arVolt[1]:= rAI_cur;

(*求累计*)
rVoltSum:= 0;
FOR iN:=iVoltAverageMaxTimes TO 1 BY -1 DO
	rVoltSum:= rVoltSum + arVolt[iN];
END_FOR


IF iVoltTotalTimes<iVoltAverageMaxTimes THEN
	(*不足平均的次数就去当前值*)
	iVoltTotalTimes:= iVoltTotalTimes+1;
	rVoltFinal:= arVolt[1];
ELSE
	(*取平均值*)
	rVoltFinal:= rVoltSum/iVoltAverageMaxTimes;
END_IF


(*伪随机测试@2024.05.24.130600*)
(*PID值处理---------------------------------------start*)
IF i_pbySetTestPid<>0 THEN
	bySetTestPid:=i_pbySetTestPid^;
END_IF
IF i_xPseudoRandomId THEN(*收牵伪随机*)
	IF i_xPseudoRandomEn THEN(*伪随机使能了*)
		(*pid界面按钮修改*)
		IF bySetTestPid=1 THEN(*第一组pid*)
			IF i_xPseudoRandomId THEN(*放牵伪随机*)
				rKp:=i_iPseudoRandomRound_Kp_1;
				rKd:=i_iPseudoRandomRound_Kd_1;
			END_IF
		ELSIF bySetTestPid=2 THEN(*第二组pid*)
			IF i_xPseudoRandomId THEN(*放牵伪随机*)
				rKp:=i_iPseudoRandomRound_Kp_2;
				rKd:=i_iPseudoRandomRound_Kd_2;
			END_IF
		ELSIF bySetTestPid=3 THEN(*第三组pid*)
			IF i_xPseudoRandomId THEN(*放牵伪随机*)
				rKp:=i_iPseudoRandomRound_Kp_3;
				rKd:=i_iPseudoRandomRound_Kd_3;
			END_IF
		ELSIF bySetTestPid=4 THEN(*第4组pid@0*)
			IF i_xPseudoRandomId THEN(*放牵伪随机*)
				rKp:=0;
				rKd:=0;
			END_IF
		END_IF
	END_IF
END_IF
bySetTestPid:=0;

(*非伪随机\使用界面pid@2024.05.24.112400*)
IF (NOT i_xPseudoRandomId) OR(*未选择牵引*)
	(NOT i_xPseudoRandomEn) THEN(*未使能*)
	rKp:= i_rKp;
	rKi:= i_rKi;
	rKd:= i_rKd;
END_IF


IF i_pbySetTestPid<>0 THEN
	i_pbySetTestPid^:=bySetTestPid;
END_IF
(*PID值处理---------------------------------------end*)

(*伪随机值处理------------------------------------start*)
(*取变化的增量值*)
IF i_xPseudoRandomId THEN(*伪随机*)
	rPseudoRandomRoundAmplitude_Cur:=i_rPseudoRandomRoundAmplitude_Cur;
ELSE
	rPseudoRandomRoundAmplitude_Cur:=0;
END_IF
rDeltaTmp:=rPseudoRandomRoundAmplitude_Cur-rPseudoRandomRoundAmplitude_Cur_Last;
rPseudoRandomRoundAmplitude_Cur_Last:=rPseudoRandomRoundAmplitude_Cur;

rPseudoRandomAmplitude_Delta:=0;
IF i_xPseudoRandomTsting THEN(*伪随机中*)
	IF i_xPseudoRandomId THEN(*放牵*)
		rPseudoRandomAmplitude_Delta:=rDeltaTmp;
	END_IF
ELSE
	IF rDeltaTmp<>0 THEN
		IF i_xPseudoRandomId THEN(*放牵*)
			rPseudoRandomAmplitude_Delta:=rDeltaTmp;
		END_IF
	END_IF
END_IF


(*2024.05.25.105317*)
xCtlEn:=i_xEn AND i_rVel_Film>0;
IF (xCtlEn AND NOT xCtlEn_Last)THEN(*初始化*)
	rYout:=0;
	rYout_Tmp:=0;
	rYI:=0;
	rYD:=0;
	SysMemSet(ADR(arEk),0,SIZEOF(arEk));
END_IF
xCtlEn_Last:=xCtlEn;


(*放牵pid*)
PID_ANTI(
	rAI_cur(*i_rU*),
	(*调整量使用临时值处理@2025.1.12.152843*)
	ADR(rYout_Tmp)(*i_prYout*),
	rKp*6.3/30(*i_rP*),
	rKI*7/50(*i_rI*),
	0(*i_rD*),
	0(*i_rN*),
	INT_TO_REAL(i_iCycleTime_Plc)/1000.0(*i_rTs*),
	INT_TO_REAL(iVelocityLimit)(*i_rLim*),
	1(*i_rAntiWindup*),
	ADR(rYI)(*i_prYI*),
	ADR(rYD)(*i_prYD*),
	ADR(arEk)(*i_parEk*));
(*对调整量输出做平滑处理@变化增加限值*)
rYout:=KS_A2B_SmoothDeal(rYout,rYout_Tmp,rMaxDelVel);


(*2024.12.3.110816+*)
KS_SIG_SIN(
	i_xEn_Disturbance(*i_xEn*),
	i_rFreq_Disturbance(*i_rFreq*),
	i_rAmplitude_Disturbance(*i_rAmplitude*),
	i_uiTotalTime_Disturbance(*i_uiTotalTime*),
	i_iCycleTime_Plc(*i_iCycleTime_Plc*),
	ADR(o_xOuting_sin)(*i_pxOuting*),
	ADR(lrX_sin)(*i_plrX*),
	ADR(o_rResult_sin)(*i_prResult*));

rVel_Disturbance:=o_rResult_sin;
IF NOT i_xAdjustMode OR(*放牵周长调整方式下|不能叠加扰动*)
	NOT i_xCanAdjEn OR(*放牵未pid调整*)
	NOT xCtlEn THEN(*未使能也先清除了吧*)
	rVel_Disturbance:=0;
END_IF

IF xCtlEn(*i_xEn AND i_lrVel_Film>0*) THEN(*2024.05.25.105235*)
	rForwardStep:=0;
	IF i_xFilmAccDecDone THEN(*料膜加速完成了，才使用前馈*)
		IF i_rVel_Film<>rPreFilmVelocity AND rPreFilmVelocity<>0  THEN (*速度发生了变化*)
			rForwardStep:=(i_rVel_Film-rPreFilmVelocity);
		ELSE;
		END_IF
	END_IF

	IF NOT i_xMachineRev THEN
	(*放牵速度控制*)
		IF i_xCanAdjEn (*AND i_xImpressFlag_Pu*) THEN (*放牵合压*)
							(*2018.10.6.122439 取消色组压辊合压放牵才调整逻辑by liu.yt*)

			rFormulaResult:= rKp * rAI_cur/1000 +rKd/100*(arVolt[1]-arVolt[iNum_Old]); (*/100是为了输入Kp和Ki时放大了100倍*)
			IF  ABS(rFormulaResult)>rMaxDelVel THEN
				rFormulaResult:=rMaxDelVel*(rFormulaResult)/ABS(rFormulaResult);
			ELSE
				;
			END_IF

			IF i_rVel_Film=0 THEN(*料膜速度为0速的时候，调整牵引到中位。对pi调整量进行限值*)(*2018.7.11.223054*)
				IF ABS(rFormulaResult)>rPIValueLimit_Zero THEN
					rFormulaResult:=rPIValueLimit_Zero*rFormulaResult/ABS(rFormulaResult);
				END_IF
			END_IF

			(*pi输出取反*)
			IF i_xNegative_PiValue THEN
				rFormulaResult:=-rFormulaResult;
			END_IF
			
			
			IF o_rVel+rFormulaResult+rForwardStep<0 THEN
				IF i_rVel_Film=0 THEN
					o_rVel:=o_rVel+rFormulaResult+rForwardStep;
				ELSE
					o_rVel:=0;
				END_IF
			ELSE
				o_rVel:=o_rVel+rFormulaResult+rForwardStep;
			END_IF


			IF i_xCanAdjEn THEN (*调整标志有效*);
			ELSE(*不调整状态*)
				o_rVel:=i_rVel_Film;
			END_IF


	(*对输出的收放牵速度进行限值*)
			IF o_rVel >INT_TO_REAL(iVelocityLimit)+i_rVel_Film THEN
				o_rVel:=INT_TO_REAL(iVelocityLimit)+i_rVel_Film ;
			ELSIF o_rVel <-INT_TO_REAL(iVelocityLimit)+i_rVel_Film  THEN
				o_rVel:=-INT_TO_REAL(iVelocityLimit)+i_rVel_Film ;
			ELSE
				;
			END_IF
		ELSE
			o_rVel:=i_rVel_Film;
		END_IF
	ELSE(*反向走料调整取反*)
		IF i_xCanAdjEn AND i_xRollerSts_Pu THEN (*放牵合压*)
							(*2018.10.6.122439 取消色组压辊合压放牵才调整逻辑by liu.yt*)
	
			rFormulaResult:= rKp * (-rAI_cur)/1000 -rKd/100*(arVolt[1]-arVolt[iNum_Old]); (*/100是为了输入Kp和Ki时放大了100倍*)
	(*	lrFeedPI_Value:=i_lrFeed_lrP/1000*(i_Analog.lrAnalogInput_Feed)+i_lrFeed_lrD/100*(lrFeed_Voltage_Sum[1]-lrFeed_Voltage_Sum[iNum_Old]);*)

			IF  ABS(rFormulaResult)>rMaxDelVel THEN
				rFormulaResult:=rMaxDelVel*(rFormulaResult)/ABS(rFormulaResult);
			ELSE
				;
			END_IF
	
	
			IF i_rVel_Film=0 THEN(*料膜速度为0速的时候，调整牵引到中位。对pi调整量进行限值*)(*2018.7.11.223054*)
				IF ABS(rFormulaResult)>rPIValueLimit_Zero THEN
					rFormulaResult:=rPIValueLimit_Zero*rFormulaResult/ABS(rFormulaResult);
				END_IF
			END_IF
	
			(*pi输出取反*)
			IF i_xNegative_PiValue THEN
				rFormulaResult:=-rFormulaResult;
			END_IF

			IF o_rVel+rFormulaResult+rForwardStep<0 THEN
				IF i_rVel_Film=0 THEN
					o_rVel:=o_rVel+rFormulaResult+rForwardStep;
				ELSE
					o_rVel:=0;
				END_IF
			ELSE
				o_rVel:=o_rVel+rFormulaResult+rForwardStep;
			END_IF
	

			IF i_xCanAdjEn THEN (*调整标志有效*)
				;
			ELSE(*不调整状态*)
				o_rVel:=i_rVel_Film;
			END_IF


	(*对输出的收放牵速度进行限值*)
			IF o_rVel >INT_TO_REAL(iVelocityLimit)+i_rVel_Film THEN
				o_rVel:=INT_TO_REAL(iVelocityLimit)+i_rVel_Film ;
			ELSIF o_rVel <-INT_TO_REAL(iVelocityLimit)+i_rVel_Film  THEN
				o_rVel:=-INT_TO_REAL(iVelocityLimit)+i_rVel_Film ;
			ELSE
				;
			END_IF
		ELSE
			o_rVel:=i_rVel_Film;
		END_IF	
	END_IF


	IF NOT i_xAdjustMode THEN(*放牵调整开关@打开了不能使用pid*)
		i_xPidType:=FALSE;
	END_IF

	(*2024.05.25.110051*)
	rTmp:=i_rVel_Film+rYout;
	IF i_xPidType THEN(*放牵使用新方式*)
		o_rVel:=rTmp-rDelt;
		IF o_rVel<0 THEN
			o_rVel:=0;
		END_IF
	ELSE(*原来方式*)
		rDelt:=rTmp-o_rVel;
	END_IF




	IF i_xPidType THEN(*放牵使用新方式*)
		o_rPi_Value:= rYout;
	ELSE
		o_rPi_Value:= rFormulaResult;
	END_IF

	o_rVel:=o_rVel+rPseudoRandomAmplitude_Delta;
	(*2024.12.3.084749 叠加一个速度扰动*)
	o_rVel:=o_rVel+rVel_Disturbance;
	o_rForwardStep:= rForwardStep;

	o_xEno:= TRUE;
	xFilmDecFlag:= FALSE;
ELSE
	o_xEno:= FALSE;
	(*2019.10.12.164013|niu.j|牵引料膜速度减速时加规划，防止速度直接突跳到0*)
	(*2021.2.2.110746 调整了下|Liu.yt*)
	IF NOT xFilmDecFlag  THEN
		lrVel_Acceleration:= UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)/2/1000.0; (*加速度单位: m/min/ms*)
		xFilmDecFlag:= TRUE;
	END_IF
	IF lrVel_Acceleration<>0 THEN
		lrTempVel:= o_rVel-lrVel_Acceleration * i_iCycleTime_Plc;
	ELSE
		lrTempVel:= i_rVel_Film;
	END_IF

	IF lrTempVel>0 THEN
		o_rVel:= LREAL_TO_REAL(lrTempVel);
	ELSE
		o_rVel:= 0;
		xFilmDecFlag:= FALSE;
	END_IF

	rDelt:=0;
END_IF
rPreFilmVelocity:= i_rVel_Film;

IF i_rUsingGirth<>0 THEN
	o_rVel_rpm:=o_rVel/i_rUsingGirth*1000;(*R/MIN*)
ELSE
	IF i_rGirth_Input<>0 THEN
		o_rVel_rpm:=o_rVel/i_rGirth_Input*1000;(*R/MIN*)
	ELSE
		o_rVel_rpm:=0;(*R/MIN*)
	END_IF
END_IF
o_rVel_rpm:=ABS(o_rVel_rpm);
