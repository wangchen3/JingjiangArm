(*@CES
Name=Action_Normal_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=e4567cca-491b-451a-80b5-4091a5a89d9f
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*在这里获取一些需要的输入*)
(*1.弧面信号输入处理*)
(*主要针对IO输入处理*)
(*获取IO输入*)
(*绝对值编码器*)
aliTime[1] := LTIME();
fbKS_AbsEncModule_IODeal(
	i_xInputEn:= TRUE, 
	i_xOutPutEn:= FALSE, 
	i_pdwAbsEncSinglePos_Uw:= ADR(g_dwAbsEncSinglePos_Uw), 
	i_pwAbsEncMultiPos_Uw:= ADR(g_wAbsEncMultiPos_Uw), 
	i_pdwAbsEncSinglePos_Rw:= ADR(g_dwAbsEncSinglePos_Rw), 
	i_pwAbsEncMultiPos_Rw:=ADR(g_wAbsEncMultiPos_Rw),
	i_pstStAbsEncIOModule_Uw:=ADR(g_stStAbsEncIOModule_Uw),
	i_pstStAbsEncIOModule_Rw:=ADR(g_stStAbsEncIOModule_Rw)
	);
	
g_stStSysParam.astStGrpParam_UnSave[1].dwAbsEncSinglePos_Uw := g_dwAbsEncSinglePos_Uw;
g_stStSysParam.astStGrpParam_UnSave[1].dwAbsEncSinglePos_Rw := g_dwAbsEncSinglePos_Rw;

//临时测试	

aliTime[2] := LTIME();	
// fbKS_FB_GNS_IOCtl(
// 	i_xEn:= TRUE, 
// 	i_xUseIO_FromGNS_Enable:= g_xUseIO_FromGNS_Enable, 
// 	i_xRdEn:= TRUE, 
// 	i_xWrEn:= FALSE, 
// 	i_padiGNSIO_Input:= ADR(adiGNSIO_Input), 
// 	i_pdiGNSIO_Output:= ADR(g_dwOutput_IO_GNS_P5P7), 
// 	o_xEn=> , 
// 	o_iErNo=>
// 	);
// g_dwInput_IO_GNS_P6P8:= DINT_TO_DWORD(adiGNSIO_Input[1]);
// g_dwInput_IO_GNS_P4P3:= DINT_TO_DWORD(adiGNSIO_Input[2]);
// 	
	
fbKS_FB_IOConfig(
	i_xEn:= TRUE, 
	i_xRdInput:= TRUE, 
	i_xWrOutput:= FALSE, 
//	i_iCustomerId:=2066, //g_stStSysParam.stStSysParam_Save.iCustomerId, 
	i_pstStSysParam := ADR(g_stStSysParam),
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
	i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
	i_pastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
	i_pastStIOMap_UwRw_FE_Uw:= ADR(g_astStIOMap_UwRw_FE_Uw), 
	i_pastStIOMap_UwRw_FE_Rw:= ADR(g_astStIOMap_UwRw_FE_Rw), 
	
	i_pastStProgMonitoring := ADR(g_astStProgMonitoring),
	i_dwInput_IO_GNS_P6P8:= g_dwInput_IO_GNS_P6P8,
	i_dwInput_IO_GNS_P4P3:= g_dwInput_IO_GNS_P4P3,
	
	o_xEno=> , 
	o_iErNo=> ,
	o_dwOutput_IO_GNS_P5P7=> g_dwOutput_IO_GNS_P5P7 );
aliTime[3] := LTIME();	
(*分解IO输入*)
//IF g_xDebug_IO THEN
(*2.套色误差获取及处理*)
FOR iN:= 1 TO MAX_UNIT_NUM BY 1 DO
	aiAlarm_V[iN]:= REAL_TO_INT(g_stStSysParam.astStUnitParam_Save[iN].rAlr_V*100);
	aiAlarm_H[iN]:= REAL_TO_INT(g_stStSysParam.astStUnitParam_Save[iN].rAlr_H*100);
	aiAdj_V[iN]:= REAL_TO_INT(g_stStSysParam.astStUnitParam_Save[iN].rAdj_V*100);
	aiAdj_H[iN]:= REAL_TO_INT(g_stStSysParam.astStUnitParam_Save[iN].rAdj_H*100);
	abyAverageNum_V[iN]:= g_stStSysParam.astStUnitParam_Save[iN].byAvg_V;
	abyAverageNum_H[iN]:= g_stStSysParam.astStUnitParam_Save[iN].byAvg_H;
	//2026.4.11.151301+
	abyAverageNum_Display[iN]:= g_stStSysParam.astStUnitParam_Save[iN].byAve_v_extra;
END_FOR
fbKS_FB_GetError_Arc(	
	i_xEn:= TRUE, 
	i_iUnitMax:= g_stStSysParam.stStSysParam_Save.iUnitMaxNum,
	i_byGetErrMode:= 2, 
	i_aiAlarm_V:= aiAlarm_V, 
	i_aiAlarm_H:= aiAlarm_H, 
	i_aiAdjust_V:= aiAdj_V, 
	i_aiAdjust_H:= aiAdj_H, 
	i_abyAverageNum_V:= abyAverageNum_V, 
	i_abyAverageNum_H:= abyAverageNum_H, 
	//2026.4.11.150236 误差显示平均
	i_abyAverageNum_V_Display:=abyAverageNum_Display,
	i_abyAverageNum_H_Display:=abyAverageNum_Display,
	i_pstStSysParam := ADR(g_stStSysParam),
	o_xEn=> , 
	o_iNoEr=> , 
	o_astStErrParam_Use=> astStErrParam_Use);
	
	
(*先屏蔽需要合并程序
//2026.5.12.202007读取相机误差
fbKS_FB_GetError_Arc(	
	i_xEn:= TRUE, 
	i_iUnitMax:= g_stStSysParam.stStSysParam_Save.iUnitMaxNum,
	i_byGetErrMode:= 16#3(*2*), 

	i_aiAlarm_V:= aiAlarm_V, 
	i_aiAlarm_H:= aiAlarm_H, 
	i_aiAdjust_V:= aiAdj_V, 
	i_aiAdjust_H:= aiAdj_H, 
	i_abyAverageNum_V:= abyAverageNum_V, 
	i_abyAverageNum_H:= abyAverageNum_H, 
	o_xEno=> , 
	o_iErNo=> , 

	o_astStErrParam_Use=> astStErrParam_Use);
*)	
aliTime[4] := LTIME();