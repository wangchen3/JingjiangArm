(*@CES
Name=KS_FB_CalGirthLogic_Coating
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e8f75550-8c47-4eed-8c0f-4881fe2307b6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CalGirthLogic_Coating
VAR_INPUT
	i_xEn:BOOL;
	i_xAdjNewWay:BOOL;(*调整算法新方法使能标志，在计算完成后直接进行周长自增自减调整*)
	i_xGirthAdj:BOOL;(*新算法中周长调整使能*)(*2019.8.9.155755修改为直接启动周长自增自减标志*)
	i_xCompensate_Dir:BOOL;
	(*模拟量输入和中位差值与料膜松紧关系标志：FALSE： 差值大于0代表料松，小于0代表料紧、TRUE ：差值大于0代表料紧，小于0代表料松*)
	i_iCycleTime:INT;(*程序执行周期*)
	i_lrAnalog:LREAL;(*模拟量值，摆臂位置*)
	i_rAnalogLimit:REAL;(*模拟量有效值限值*)
	i_lrFilmVel:LREAL;(*料膜速度*)
	i_lrVel:LREAL;(*实际速度*)
	i_lrActualGirth:LREAL;(*默认周长*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xGirthCalFinish:BOOL;(*计算完成标志有效了 就不在进行调整*)
	o_lrUsingGirth:LREAL;
END_VAR
VAR
	fbKS_FB_CalGirthByVel: KS_FB_CalGirthByVel;
	xGirthCaled: BOOL;
	lrGirthTemp: LREAL;
	xCalGirthEn: BOOL;(*计算周长使能标志*)
	xEvenning: BOOL;(*匀速标志*)
	lrPreCurVel: LREAL;
	xPreGirthCalFinish: BOOL;
	xInit: BOOL;

	lrAnalog_Aver: LREAL:=0;
	lrPreAnalog_Aver: LREAL;
(*	rGirthStep:REAL:=0.01;(*周长变化步进量*)*)
	rGirthStep:REAL:=0.02; (* 2020.7.13.094914|重现调整数值 *)

	lrAnalog_Sum: LREAL;
	xCalAverDone: BOOL;
	rThreshold: REAL;
	iCycleCount:INT;
	iCoeff: INT;
	iCalGirthCount: INT;
	xConditionDone: BOOL;
	lrGirthStep_Temp: LREAL;
	iThreshold: INT:=5;(*计算出的的牵引周长有效范围单位%*)
END_VAR
VAR CONSTANT
	(*2020.4.22.101241|新增|*)
	c_lrAIBoundage_Axis: LREAL := 0.8;
END_VAR

{IMPLEMENTATION}
(*稳速时候才能进行周长计算*)
xEvenning:=FALSE;
IF i_lrFilmVel=lrPreCurVel AND i_lrFilmVel>=10  THEN(*速度大于一定值，并且处于匀速*)
	xEvenning:=TRUE;
END_IF


xConditionDone:=FALSE;
IF xEvenning THEN(*进入匀速状态之后 等待一段时间在进入计算周长状态*)
	iCalGirthCount:=iCalGirthCount+1;
	IF iCalGirthCount>=500 THEN (*延迟500个周期 进入计算周长状态*)
		iCalGirthCount:=iCalGirthCount-1;
		xConditionDone:=TRUE;
	END_IF
ELSE
	iCalGirthCount:=0;
END_IF



xCalGirthEn:=FALSE;
IF xConditionDone AND (NOT o_xGirthCalFinish) AND i_xAdjNewWay(*g_xInFeedAndOutFeed_AdjNewWay *)THEN
	xCalGirthEn:=TRUE;
END_IF

fbKS_FB_CalGirthByVel(
	i_xEn:=xCalGirthEn ,
	i_iCycleTime:=i_iCycleTime ,
	i_lrAnalog:=i_lrAnalog ,
	i_rAnalogLimit:=i_rAnalogLimit ,
	i_lrFilmVel:=i_lrFilmVel ,
	i_lrVel:=i_lrVel ,
	i_lrUsingGirth:= o_lrUsingGirth,
	i_rAnalogSumLimit:=,
	o_xEn=> ,
	o_xGirthCaled=> xGirthCaled,
	o_lrGirth=>lrGirthTemp );


IF xGirthCaled THEN
	o_xGirthCalFinish:=TRUE;(*该标志有效则可以认为我们可以进入非调整状态了*)
END_IF


IF o_xGirthCalFinish AND ABS(i_lrAnalog)>c_lrAIBoundage_Axis THEN(*2020.4.22.101215_|0.3--->>>c_lrAIBoundage_Axis|*)
	o_xGirthCalFinish:=FALSE;
END_IF

IF o_xGirthCalFinish AND (NOT xPreGirthCalFinish)  THEN(*将计算出来的值赋给输出值*)
	IF lrGirthTemp<=i_lrActualGirth*(1+iThreshold/100.0) AND lrGirthTemp>=i_lrActualGirth*(1-iThreshold/100.0) THEN
		o_lrUsingGirth:=lrGirthTemp;
	ELSE
		o_xGirthCalFinish:=FALSE;
	END_IF
END_IF


IF   i_lrFilmVel=0 THEN(*不走料的时候版周长为默认值*)
	(*IF   NOT xInit THEN*)
		o_xGirthCalFinish:=FALSE;
		o_lrUsingGirth:=i_lrActualGirth;
		xInit:=TRUE;
(*	END_IF*)
ELSE
	xInit:=FALSE;
END_IF


(*当已经进入到不再调整逻辑中的时候，我们对牵引的周长进行微调*)(*2018.5.7.153458*)

(*求摆臂的位置的平均值*)
xCalAverDone:=FALSE;
iCycleCount:=iCycleCount+1;
lrAnalog_Sum:=lrAnalog_Sum+i_lrAnalog;
IF iCycleCount>=50 THEN
	xCalAverDone:=TRUE;
	(*lrPreAnalog_Aver:=lrAnalog_Aver;*)
	lrAnalog_Aver:=lrAnalog_Sum/iCycleCount;
	lrAnalog_Sum:=0;
	iCycleCount:=0;
ELSE;
END_IF

IF o_xGirthCalFinish AND (NOT xPreGirthCalFinish)  THEN(*计算完成后初始化上个周期平均模拟量值*)
	lrPreAnalog_Aver:=lrAnalog_Aver;
END_IF

lrGirthTemp:=0;
lrGirthStep_Temp:=rGirthStep;
IF (o_xGirthCalFinish OR i_xGirthAdj(*g_xGirthAdj  *)) AND xCalAverDone THEN
	IF ABS(lrAnalog_Aver)>0.1 THEN
		rThreshold:=0;
	ELSE
		rThreshold:=0.001;
	END_IF

	IF NOT  i_xCompensate_Dir THEN(*对于补偿方向取反*)
		iCoeff:=1;
	ELSE
		iCoeff:=-1;
	END_IF

	IF  lrAnalog_Aver >0.01 THEN
		IF  lrAnalog_Aver>lrPreAnalog_Aver+rThreshold THEN(*位置值越来越大了*)
			lrGirthTemp:=iCoeff*lrGirthStep_Temp;
			lrPreAnalog_Aver:=lrAnalog_Aver;
		END_IF
	ELSIF  lrAnalog_Aver <-0.01  THEN
		IF  lrAnalog_Aver+rThreshold<lrPreAnalog_Aver THEN(*位置值越来越小了*)
			lrGirthTemp:=-iCoeff*lrGirthStep_Temp;
			lrPreAnalog_Aver:=lrAnalog_Aver;
		END_IF
	ELSE
		lrPreAnalog_Aver:=lrAnalog_Aver;
	END_IF
ELSE;
END_IF


o_lrUsingGirth:=o_lrUsingGirth+lrGirthTemp;


lrPreCurVel:=i_lrFilmVel;
xPreGirthCalFinish:=o_xGirthCalFinish;
o_xEn:=i_xEn;