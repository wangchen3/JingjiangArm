(*@CES
Name=Action_VelToVol
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=047c1489-70c6-4e84-a017-39e588907b30
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
fbKS_FB_VelocityToVoltage(
	i_xEn:= TRUE, 
	i_xCurAxisIsA:= xCutAxisA_In_Out, 
	i_xCut_end:= xFlag_Cut_end_Out, 
	i_uiNum:= uiNum_In, 
	i_uiDen:= uiDen_In, 
	i_rRatedRpm:= rRatedRpm_In, 
	i_rRatedFreq:= rRatedFreq_In, 
	i_rUpperFreq:= rUpperFreq_In, 
	i_rCoef_AxisA:= 1, 
	i_rCoef_AxisB:= 1, 
	i_xIsUpCut:= io_xCutOnTop, 
	i_xInch:= xInch, 
	i_xMachine_Rev:= i_xMachineRev, 
	i_prUwRwA_Feq:= ADR(rAxisAFreq_Out), 
	i_prUwRwB_Feq:= ADR(rAxisBFreq_Out), 
	i_rDiam_New:= o_rDiam_NewVol, 
	i_rVel_UwRw:= rVel_CalcVolt, 
	i_rVel_PreDrv:= rVel_Predrv_Out, 
	i_xAxisDebugEn:= xAxisDebugEn_In_Out,//wAxisDebug_UwRw_In_Out.8, 
	i_rAxisAVelDebug:= rDebugCurVelmpmAxisA_In_Out, 
	i_rAxisAGirthDebug:= iDebugGirthmm_AxisA_In_Out, 
	i_rAxisBVelDebug:= rDebugCurVelmpmAxisB_In_Out, 
	i_rAxisBGirthDebug:= iDebugGirthmm_AxisB_In_Out, 
	i_xRevInch:= FALSE, 
	i_xPseudoRandomTsting:= xPseudoRandomTsting_In AND byPseudoRandomId_In=2, 
	i_rPseudoRandomRoundAmplitude_Cur:= rPseudoRandomRoundAmplitude_Cur_In, 
	i_rDiam_Cut:= io_rDiamCurAxis,// REAL;//当前卷径用于计算单运行速度
	i_rVel_Inch_Print:= rVel_Inch_In,// REAL;//单运行速度2026.04.10.224012	
	o_xEno=> , 
	o_rVolt_AxisA=> rAxisAVolByVel_Out, 
	o_rVolt_AxisB=> rAxisBVolByVel_Out, 
	o_rAxisAVel_RPM=> rAxisAVel_RPM_Out, 
	o_rAxisBVel_RPM=> rAxisBVel_RPM_Out
);