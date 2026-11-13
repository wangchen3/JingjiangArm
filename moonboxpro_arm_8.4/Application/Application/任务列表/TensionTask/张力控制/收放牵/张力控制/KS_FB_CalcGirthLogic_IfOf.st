(*@CES
Name=KS_FB_CalcGirthLogic_IfOf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2fd058fe-87b7-4e24-a0c2-a6df17a2c853
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CalcGirthLogic_IfOf
(*2021.10.28.100152 收放牵分开*)
(*默认调整方向|在摆臂越来越大时候即越来越紧|周长是加大方向也就是减速方向|
放牵调整方向需要取反|
收牵不需要*)
(*再切换算法后直接退出周长模式@2026.4.9.195445+*)
VAR_INPUT
	i_xEn:BOOL;
	i_xMachineRev:BOOL;(*反向走料时调整方向取反*)
	i_xNegative:BOOL;(*调整取反*)
	i_rVel_Film:REAL;(*当前料膜速度*)
	i_iCycleTime_Plc:INT;(*程序执行周期*)
	i_rAnalogLimit:REAL;(*模拟量有效值限值*)
	i_rAxisVel_Cur:REAL;(*当前轴速度*)
	i_rAi_Swing: REAL; (*摆臂当前值*)
	i_rActualGirth:REAL;(*默认周长*)
	i_xRollerPressDone: BOOL;
	i_xSwitchTension:BOOL;(*张力算法控制开关*)
	i_xAccing:BOOL;
	i_xDecing:BOOL;	
	i_xCompensateWhenAccing:BOOL;(*2025.3.7.092457*)
	i_rCompensateGirthWhenAccing:REAL;(*补偿的值|mm*)
	i_iCycleNum_Delay: INT:= 500;
	i_iCycleNum_AI_Ave: INT:=50;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;	
	o_xGirthCalFinish: BOOL;
	o_rUsingGirth: REAL;
END_VAR
VAR
	fbKS_FB_CalcGirthByVel: KS_FB_CalcGirthByVel_IfOf;
	xEvenning:BOOL;		(*稳速标志*)
	xAccing: BOOL;
	xDecing: BOOL;
	xConditionDone: BOOL;
	xCalGirthEn: BOOL;(*周长计算使能标志*)
	xGirthCaled:BOOL;(*计算好了*)
	xPreGirthCalFinish: BOOL;(*上个周期周长计算完成*)
	rGirthTemp: REAL;(*计算的周长值*)
	rPreCurVel: REAL;(*上个周期当前速度值*)
	iCalGirthCount: INT;(*周期计数值*)
	iGirthStep: INT:= 2;
	rGirthStep_Temp: REAL;
	iThreshold: INT:=5;(*计算出的的牵引周长有效范围单位%*)
	rAnalog_Sum: REAL;
	iCycleCount:INT;(*调整计时*)
	rAnalog_Aver:REAL;(*平均模拟量*)
	rPreAnalog_Aver: REAL;(*上次计算后的平均模拟量*)
	xCalAverDone: BOOL;(*平均值计算完成标志*)
	rThreshold: REAL;(*调整阈值*)
	iCoeff: INT;
	iCompensateGirthWhenAccing:INT;(*补偿的值|丝*)
END_VAR
VAR CONSTANT
	(*2020.4.22.101010_|新增|*)
	c_lrAIBoundage: LREAL := 0.5;
END_VAR
{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	(*稳速时候才能进行周长计算*)
	xEvenning:=NOT i_xAccing AND NOT i_xDecing AND i_rVel_Film>=9.9;(*编码器计算的速度,精度问题10m/min的时候回事9.99m/min*)
	xAccing:=i_xAccing;
	xDecing:=i_xDecing;

	xConditionDone:=FALSE;
	IF i_iCycleNum_Delay=0 THEN
		i_iCycleNum_Delay:= 500;
	END_IF
	IF xEvenning THEN(*进入匀速状态之后 等待一段时间在进入计算周长状态*)
		iCalGirthCount:=iCalGirthCount+1;
		IF iCalGirthCount>=i_iCycleNum_Delay THEN (*延迟500个周期 进入计算周长状态*)
			iCalGirthCount:=iCalGirthCount-1;
			xConditionDone:=TRUE;
		END_IF
	ELSE
		iCalGirthCount:=0;
	END_IF


	xCalGirthEn:=FALSE;
	IF xConditionDone AND NOT o_xGirthCalFinish  THEN
		xCalGirthEn:=TRUE;
	END_IF

	(*2018.08.16.81201 | niu.j |*)
	(*计算版周长使能取消，使用默认周长，一直调整*)
	IF i_xSwitchTension OR (NOT i_xRollerPressDone) THEN
		xCalGirthEn:= FALSE;
	END_IF
	(*------------------------------------------*)

	fbKS_FB_CalcGirthByVel(
		i_xEn:= TRUE,
		i_xCalcGirthEn:= xCalGirthEn,
		i_rVel_Film:= i_rVel_Film,
		i_iCycleTime_Plc:= i_iCycleTime_Plc,
		i_rAnalogLimit:= i_rAnalogLimit,
		i_rUsingGirth:= o_rUsingGirth,
		i_rAnalogSumLimit:= ,
		i_rAxisVel_Cur:= i_rAxisVel_Cur,
		i_rAi_Swing:= i_rAi_Swing,
		o_xEno=> ,
		o_xGirthCaled=> xGirthCaled,
		o_rGirth=> rGirthTemp);


	IF xGirthCaled THEN
		o_xGirthCalFinish:=TRUE;(*该标志有效则可以认为我们可以进入非调整状态了*)
	END_IF


	IF o_xGirthCalFinish AND ABS(i_rAi_Swing)>c_lrAIBoundage OR
		(NOT i_xRollerPressDone) OR(*2021.10.27.112505 压辊抬起来了就取消周长调整模式*)
		i_xSwitchTension THEN(*取消周长方式@直接进入pi方式@2026.3.18.140545+*)(*2026.4.9.194300同步*)
		o_xGirthCalFinish:=FALSE;
	END_IF


	IF o_xGirthCalFinish AND (NOT xPreGirthCalFinish) THEN(*将计算出来的值赋给输出值*)
		IF rGirthTemp<=i_rActualGirth*(1+iThreshold/100.0) AND rGirthTemp>=i_rActualGirth*(1-iThreshold/100.0) THEN
			o_rUsingGirth:=rGirthTemp;
		ELSE
			o_xGirthCalFinish:=FALSE;
		END_IF
	END_IF



	IF i_rVel_Film<=0.01 THEN(*不走料的时候版周长为默认值*)
		o_xGirthCalFinish:=FALSE;
		o_rUsingGirth:= i_rActualGirth;
	END_IF

	(*当已经进入到不再调整逻辑中的时候，我们对牵引的周长进行微调*)(*2018.5.7.153458*)

	(*求摆臂的位置的平均值*)
	xCalAverDone:=FALSE;
	iCycleCount:=iCycleCount+1;
	rAnalog_Sum:=rAnalog_Sum+i_rAi_Swing;
	IF i_iCycleNum_AI_Ave=0 THEN
		i_iCycleNum_AI_Ave:= 50;
	END_IF
	IF iCycleCount>=i_iCycleNum_AI_Ave THEN
		xCalAverDone:=TRUE;
		rAnalog_Aver:=rAnalog_Sum/iCycleCount;
		rAnalog_Sum:=0;
		iCycleCount:=0;
	ELSE;
	END_IF

	IF o_xGirthCalFinish AND NOT xPreGirthCalFinish  THEN(*计算完成后初始化上个周期平均模拟量值*)
		rPreAnalog_Aver:=rAnalog_Aver;
	END_IF


	rGirthTemp:=0;
(*2022.8.11.093253更新版周长调整当量--变速时是2丝--稳速1丝||liu&chen&niu*)
	IF xEvenning THEN
		rGirthStep_Temp:= 1;
	ELSIF (xDecing OR xAccing) AND i_rVel_Film>=10 THEN
		rGirthStep_Temp:= INT_TO_REAL(iGirthStep);
	ELSE
		rGirthStep_Temp:= 1;
	END_IF
	
	rGirthStep_Temp:=rGirthStep_Temp/100.0;
	IF o_xGirthCalFinish AND xCalAverDone  THEN
		IF ABS(rAnalog_Aver)>0.1 THEN
			rThreshold:=0;
		ELSE
			rThreshold:=0.001;
		END_IF

		IF NOT i_xMachineRev THEN
			iCoeff:=1;
		ELSE
			iCoeff:=-1;
		END_IF
		(*调整取反|同样变化趋势补偿方向不同*)
		IF i_xNegative THEN
			iCoeff:=-iCoeff;
		END_IF

		IF  rAnalog_Aver >0.01 THEN
			IF  rAnalog_Aver>rPreAnalog_Aver+rThreshold THEN(*位置值越来越大了*)
				rGirthTemp:=iCoeff*rGirthStep_Temp;
				rPreAnalog_Aver:=rAnalog_Aver;
			END_IF
		ELSIF  rAnalog_Aver <-0.01  THEN
			IF  rAnalog_Aver+rThreshold<rPreAnalog_Aver THEN(*位置值越来越小了*)
				rGirthTemp:=-iCoeff*rGirthStep_Temp;
				rPreAnalog_Aver:=rAnalog_Aver;
			END_IF
		ELSE
			rPreAnalog_Aver:=rAnalog_Aver;
		END_IF
	ELSE;
	END_IF
	(*放料升速开始周长补偿值处理*)
	IF i_xAccing THEN
		IF i_xCompensateWhenAccing THEN
			IF iCompensateGirthWhenAccing>0 THEN
				IF iCompensateGirthWhenAccing-rGirthStep_Temp*100<0 THEN
					rGirthTemp:=rGirthTemp+INT_TO_REAL(iCompensateGirthWhenAccing)/100;
					iCompensateGirthWhenAccing:=0;
				ELSE
					rGirthTemp:=rGirthTemp+rGirthStep_Temp;
					iCompensateGirthWhenAccing:=LREAL_TO_INT(iCompensateGirthWhenAccing-rGirthStep_Temp*100);
				END_IF
			ELSIF iCompensateGirthWhenAccing<0 THEN
				IF iCompensateGirthWhenAccing+rGirthStep_Temp*100>0 THEN
					rGirthTemp:=rGirthTemp-INT_TO_REAL(iCompensateGirthWhenAccing)/100;
					iCompensateGirthWhenAccing:=0;
				ELSE
					rGirthTemp:=rGirthTemp-rGirthStep_Temp;
					iCompensateGirthWhenAccing:=LREAL_TO_INT(iCompensateGirthWhenAccing+rGirthStep_Temp*100);
				END_IF
			ELSE;
			END_IF
		END_IF
	ELSE
		iCompensateGirthWhenAccing:=REAL_TO_INT(i_rCompensateGirthWhenAccing*100);
	END_IF
	
	
	o_rUsingGirth:=o_rUsingGirth+rGirthTemp;

	rPreCurVel:=i_rVel_Film;
	xPreGirthCalFinish:=o_xGirthCalFinish;
ELSE
	IF o_rUsingGirth=0 THEN
		o_rUsingGirth:= i_rActualGirth;
	END_IF
END_IF