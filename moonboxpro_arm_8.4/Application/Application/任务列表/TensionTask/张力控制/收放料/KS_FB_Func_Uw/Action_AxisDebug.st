(*@CES
Name=Action_AxisDebug
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ce9619c1-a69e-44d3-ab77-8005628c8fe8
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(**************************2021.9.2.085749调试模式互斥处理******************************************************************)
	(*2021.9.1.151329  增加放料绝对值编码器标定和卷径测量标定调试模式的互斥|
	因为他们使用了同一个同步指示灯作为标识|*)
	(*2021.9.2.085303 增加放料轴速度调试模式的互斥*)
afbDebug_UwRw[1](CLK:= xDebug_Enc_In_Out_UwRw);
afbDebug_UwRw[2](CLK:= xIsDebug_DiaMeasure_In);
afbDebug_UwRw[3](CLK:= xAxisDebugEn_In_Out);(*放料轴速度调试模式开关*)
IF afbDebug_UwRw[1].Q THEN(*绝对值编码器调试|*)
	xIsDebug_DiaMeasure_In:=FALSE;(*清除卷径标定调试*)
	xAxisDebugEn_In_Out:=FALSE;(*清除放料轴速度调试模式开关*)
ELSIF afbDebug_UwRw[2].Q THEN(*卷径标定调试*)
	xDebug_Enc_In_Out_UwRw:=FALSE;(*清除绝对值编码器标定调试*)
	xAxisDebugEn_In_Out:=FALSE;(*清除放料轴速度调试模式开关*)
ELSIF afbDebug_UwRw[3].Q THEN(*放料轴速度调试模式开关*)
	xIsDebug_DiaMeasure_In:=FALSE;(*清除卷径标定调试*)
	xDebug_Enc_In_Out_UwRw:=FALSE;(*清除绝对值编码器标定调试*)
END_IF

fbKS_FB_AxisDebug(
	i_xEn:= TRUE, 
	i_xEstopBtn:= i_xEstop_Input, 
	i_xFlag_Estop:= i_xFlag_Estop, 
	i_xFlag_Tension:= i_xFlag_Tension, 
	i_xFlag_Print:= i_xFlag_Print, 
	i_xCurAxisA:= xCutAxisA_In_Out, 
	i_rVel_Max:= i_rVel_Max, 
	i_xFuncBtn:= i_pstStEvtReq^.xEvt_Cut, 
	i_xPreCutBtn:= xBtnPreCut, 
	i_xCutCancelBtn:= xBtnCut_Cancel, 
	i_xCutBtn:= i_pstStEvtReq^.xEvt_Cut, 
	i_xStsPreCut:= o_xSts_PreCutting, 
	i_iDebugVelmpm_AxisA:= iDebugVelmpm_AxisA_In_Out, 
	i_iDebugGirthmm_AxisA:= iDebugGirthmm_AxisA_In_Out, 
	i_iDebugVelmpm_AxisB:= iDebugVelmpm_Axisb_In_Out, 
	i_iDebugGirthmm_AxisB:= iDebugGirthmm_Axisb_In_Out, 
	i_iCycleTime_Plc:= i_iCycleTime_Plc,
	o_xEn=> , 
	o_xLampFlick_Debug=> xLampFlick_AxisVelDebug, 
	o_xPreCut_Debug=> xBtnPreCut_Debug, 
	o_xCutCancel_Debug=> xBtnCut_Cancel_Debug, 
	o_xCut_Debug=> xBtnCut_Debug, 
	o_xLamp_PreDrive_Debug=> xLamp_PreDrive_Debug, 
	io_xAxisDebugEn				:= xAxisDebugEn_In_Out	,		
	io_xAxisADebugRun			:= xAxisADebugRun_In_Out,		 
	io_xAxisBDebugRun			:= xAxisBDebugRun_In_Out		, 
	io_xAxisADebugRunning		:= xAxisADebugRunning_In_Out	, 
	io_xAxisBDebugRunning		:= xAxisBDebugRunning_In_Out	, 
	io_xAxisADebugAutoAccDec	:= xAxisADebugAutoAccDec_In_Out, 
	io_xAxisBDebugAutoAccDec	:= xAxisBDebugAutoAccDec_In_Out, 
 
	io_rDebugCurVelmpmAxisA:= rDebugCurVelmpmAxisA_In_Out, 
	io_rDebugCurVelmpmAxisB:= rDebugCurVelmpmAxisB_In_Out, 
	io_rDebugCurVelrpmAxisA:= rDebugCurVelrpmAxisA_In_Out, 
	io_rDebugCurVelrpmAxisB:= rDebugCurVelrpmAxisB_In_Out);