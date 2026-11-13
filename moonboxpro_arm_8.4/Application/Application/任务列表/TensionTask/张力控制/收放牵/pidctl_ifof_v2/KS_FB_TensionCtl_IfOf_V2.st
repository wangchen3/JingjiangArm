(*@CES
Name=KS_FB_TensionCtl_IfOf_V2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ab5fd7e7-80cb-46c4-92b8-2bc3802dc9a3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_TensionCtl_IfOf_V2
(*摆臂负值-料膜为松弛状态|负值输出减速|反之加速*)
(*2021.10.23.093343  新增的张力控制模块|主要用于收放牵控制*)
VAR_INPUT
	i_xEn: BOOL;(*张力模块使能@压辊信号等*)
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
	
	
	
	(*公用*)
	xCacelSmooth: BOOL;(*取消平滑*)
	rAiCoeff: REAL;(*模拟量系数@用于切换控制方向*)
	xPrevAdjEn: BOOL;(*切换为周长标志备份值*)
	rPrevFilmVel:REAL;
	xPrevPidType:BOOL;(*pid方式备份值*)
	rVelByHNPid:REAL;(*新pid方式的速度*)
	rPValue: REAL;(*pi调整量*)
	rVelTmp:REAL;
	rVelByKsPid:REAL;(*原pid方式的速度*)
	byPidType: BYTE;(*pid类型@=0 不调整| =1 原pid方式 | =2 新pid方式*)
	rDeltaMainVel: REAL;(*前馈量*)
END_VAR
{IMPLEMENTATION}
rMaxDelVel:=0.3;(*=300/20/50 20S加速到300m/min的时候一个周期速度的变化量*)(*2018.5.22.115216 增加调整量限值*)
rPIValueLimit_Zero:=0.03;(*0速时调整量限值*)

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


(*2024.12.3.110816+正余弦扰动*)
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
	NOT i_xCanAdjEn OR(*未pid调整*)
	NOT xCtlEn THEN(*未使能也先清除了吧*)
	rVel_Disturbance:=0;
END_IF

(*************************************逻辑控制@2026.3.18.092444+***************************)
(*控制总使能处理*)
xCtlEn:=i_xEn AND i_rVel_Film>0;(*总使能*)
xCtlEn := xCtlEn AND i_xCanAdjEn;(*调整使能了@不使能则按照料膜速度输出(i_xAdjEn_If控制了pi和周长切换)*)

(*控制条件满足*)
IF NOT i_xMachineRev THEN
	rAiCoeff:=1;
ELSE(*反向走料*)
	rAiCoeff:=-1;
END_IF

(*再次取反@2026.4.9.195338+*)
IF i_xNegative_PiValue THEN
	rAiCoeff:=-rAiCoeff;
END_IF

(*平滑使能标志处理*)
xCacelSmooth:=FALSE;
IF (NOT i_xCanAdjEn AND xPrevAdjEn) OR(*从pi方式切换为了周长方式时输出标志|控制速度平滑输出取消*)
	i_rVel_Film<>rPrevFilmVel THEN(*料膜速度变化的时候也不要平滑*)
	xCacelSmooth:=TRUE;
END_IF
xPrevAdjEn:=i_xCanAdjEn;

(*初始化*)
IF xCtlEn THEN(*控制使能了*)
	IF i_xPidType AND NOT xPrevPidType THEN(*使用新算法初始化*)
		rVelByHNPid:=0;
		rVelTmp:=0;
		rYI:=0;
		rYD:=0;
		SysMemSet(ADR(arEk),0,SIZEOF(arEk));
		byPidType := 2;
	ELSIF NOT i_xPidType AND xPrevPidType THEN(*切换为原算法初始化*)
		rVelByKsPid:=o_rVel;(*初始化当前输出的速度*)
		byPidType := 1;
	END_IF
	xPrevPidType:=i_xPidType;
ELSE
	byPidType := 0;
	xPrevPidType:=NOT i_xPidType;(*保证进入使能会初始化一次*)
END_IF


(*pid*)
IF byPidType=2 THEN(*新pid方式*)
	PID_ANTI(
		rAI_cur*rAiCoeff(*i_rU*),
		(*调整量使用临时值处理@2025.1.12.152843*)
		ADR(rVelByHNPid)(*i_prYout*),
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

	(*对输出调整量做平滑*)
	rVelTmp:=KS_A2B_SmoothDeal(rVelTmp,rVelByHNPid,rMaxDelVel);
	o_rVel:=i_rVel_Film+rVelTmp;(*输出的调整速度*)
	o_rVel:=o_rVel+rPseudoRandomRoundAmplitude_Cur * BOOL_TO_REAL(i_xPseudoRandomId);(*叠加伪随机值*)

	(*监控*)
	o_rPi_Value:=rVelTmp;(*控制量输出用于存储*)
	o_rForwardStep:=0;(*前馈值用于存储*)
ELSIF byPidType = 1 THEN(*原pid方式*)
	KS_PIDCTL(
		TRUE(*i_xCtlEn*),
		i_xFilmAccDecDone(*i_xFeedForwardEn*),
		rAI_cur*rAiCoeff(*i_rE*),
		arVolt[iNum_Old]*rAiCoeff(*i_rPrevE*),
		rKd/100(*i_rKp*),(*输入的变量和以前保持一致*)
		rKp/1000(*i_Ki*),(*输入的变量和以前保持一致*)
		rPseudoRandomAmplitude_Delta + rVel_Disturbance(*i_rAddVel*),
		iVelocityLimit(*i_rMaxAdjVel*),
		i_rVel_Film(*i_rMainVel*),
		rMaxDelVel(*i_rMaxDelVel*),
		rPIValueLimit_Zero(*i_rMaxDelVel_Zero*),
		ADR(rPrevFilmVel)(*i_prPrevMainVel*),
		ADR(rVelByKsPid)(*i_prVel*),
		ADR(rPValue)(*i_prPiValue*),
		ADR(rDeltaMainVel)(*i_prDeltaMainVel*));
	(*2026.3.27.162345+ bug修复@原来写成收牵速度输出了*)
	o_rVel:=rVelByKsPid;(*直接输出*)
	(*监控*)
	o_rPi_Value:=rPValue;(*控制量输出用于存储*)
	o_rForwardStep:=rDeltaMainVel;(*前馈值用于存储*)
ELSE
	(*对调整量输出做平滑处理@变化增加限值*)
	IF xCacelSmooth THEN(*不平滑@pi和周长切换时不需要*)
		o_rVel:=i_rVel_Film;
	ELSE(*平滑到料膜速度*)
		o_rVel:=KS_A2B_SmoothDeal(o_rVel,i_rVel_Film,rMaxDelVel);
	END_IF
	(*监控*)
	o_rPi_Value:=0;
	o_rForwardStep:=0;
END_IF
rPrevFilmVel:=i_rVel_Film;(*当前速度*)

(*输出监控*)
IF i_rUsingGirth<>0 THEN
	o_rVel_rpm:=o_rVel/i_rUsingGirth*1000;(*R/MIN*)
ELSE
	o_rVel_rpm:=0;
END_IF
o_rVel_rpm:=ABS(o_rVel_rpm);
