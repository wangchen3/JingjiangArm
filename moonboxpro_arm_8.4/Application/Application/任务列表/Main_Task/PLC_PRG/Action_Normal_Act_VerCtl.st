(*@CES
Name=Action_Normal_Act_VerCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=0710a5fd-dabe-41d7-bf2d-e0689ef24792
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

FOR iGrp:=1 TO 2 BY 1 DO	
	IF iGrp=2 THEN EXIT; END_IF
	afbKS_FB_VertAdjustCtrl[iGrp](
		i_xEn:= (g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Print OR (g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Ink AND g_stStSysParam.astStGrpParam_UnSave[iGrp].xIsDebugMode_Machine)) AND 
										(NOT g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_EStoping) AND
										(NOT g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Stoping) AND
										(NOT g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_FastStoping), 
		i_iGrpId:= iGrp, 
		i_iGrpAxisNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu,
		i_iGrpAxisTotalNum:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu, 
		i_abyGrpAxisList:= g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpAxisList,
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
		i_pastStRegAdjMana:= ADR(g_astStRegAdjMana), 
		i_pastStAxisRapidAdjProf_V:= ADR(g_astStAxisRapidAdjProf_V), 
		i_iCycleTime_Motion:= 10, 
		i_iCycleTime_PlcTask:= 10, 
		i_byLamp_3_Mode:= g_byArcLampDisWay, 
		i_byLinkage_Lamp_3_Color:= g_byLinkage_Lamp_3_Color, 
		i_xAutoAdjustbyRapidAdjust:= g_axStartAutoFind[iGrp], 
		i_byCouplingType:= g_stStSysParam.stStSysParam_Save.byCouplingType, 
		i_iRemaindPartCouplingPos:= g_stStSysParam.stStSysParam_Save.iRemaindPartCouplingPos, 
		i_iGrpArcAxisNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpArcAxisNum, 
		i_abyGrpArcAxisList:= g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpArcAxisList, 
		i_awVirtualCnt:= g_awVirtualCnt, 
		i_iAxisId_StepTest_V:= g_stStSysParam.astStGrpParam_UnSave[iGrp].iAxisId_StepTest_V, 
		i_iMicron_StepTest1_V:= g_stStSysParam.astStGrpParam_UnSave[iGrp].iMicron_StepTest1_V, 
		i_iMicron_StepTest2_V:= g_stStSysParam.astStGrpParam_UnSave[iGrp].iMicron_StepTest2_V, 
		i_iInterval_StepTest12:= g_stStSysParam.astStGrpParam_UnSave[iGrp].iInterval_StepTest12, 
		i_byType_StepTest:= g_byTypeStepTest, 
		i_pstStDeCoupleCoeff:= ADR(g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff), 
		i_pabyVerManuTrigButton:= ADR(g_abyVerManuTrigButton), 
		o_xEno=> , 
		o_iErNo=> , 
		io_xStepTest_V:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xBtn_StepTest_V
	);
	
	//增加横向处理逻辑
	Action_Normal_Act_Horz();
END_FOR