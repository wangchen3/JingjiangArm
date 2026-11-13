(*@CES
Name=Action_Process
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=b3d9979d-3f90-4095-87a2-6655659bf29e
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*刮刀处理*)
afbKS_FB_GrpScraperCtrl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_iAxisId_If:= aiIOGrpIdx_If[iGrp],  
	i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
	i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
	i_pastStIOMap_AxisExtra:= ADR(g_astStIOMap_Axis_Extra_FE), 
	o_xEno=> , 
	o_iErNo=> 
);
(*递磨辊处理*)
afbKS_FB_GrpInkRollerCtrl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
	i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),  
	i_pastStIOMap_AxisExtra:= ADR(g_astStIOMap_Axis_Extra_FE),
	o_xEno=> , 
	o_iErNo=> );
(*排风*)
	afbKS_FB_GrpAirExhaustCtrl[iGrp](
		i_xEn:= TRUE, 
		i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
		i_iGrpId:= iGrp, 
		i_iAxisId_If:= aiIOGrpIdx_If[iGrp],
		i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp],
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
		i_xStopAirExhaustWhenEstop:= g_xStopAirExhaustWhenEstop, 
		i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME, 
		i_iGrpLinkageAxisNum_Pu:= 6, 
		i_xFlag_Estop:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Estop, 
		i_iDelayMsec_ExhPowerMode:= g_stStSysParam.astStGrpParam_Save[iGrp].iDelayMsec_ExhPowerMode, 
		i_iDelayMsec_HeatBlower:= g_stStSysParam.astStGrpParam_Save[iGrp].iDelayMsec_HeatBlower, 
		i_rVel_Max:= g_stStSysParam.astStGrpParam_Save[iGrp].rVel_Max, 
		i_rVel_Cur:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rVel_Cur, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),
		o_xEno=> , 
		o_iErNo=> , 
		o_xAirExhaustFinishFlag=>xAirExhaustFinishFlag 
	);
	

(*冷风*)
afbKS_FB_GrpCoolBlowerCtrl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
	i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
	i_xCoolBlowerByKnob:= g_xCoolBlowerOpenByKnob, 
	i_xStopCoolBlowerWhenEstop:= g_xStopCoolBlowerWhenEstop, 
	i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME, 
	i_PastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
	o_xEno=> , 
	o_iErNo=> , 
	o_xCoolBlowerFlag=> xCoolBlowerFlag
	);
	
(*热风*)
afbKS_FB_GrpAirHotCtrl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
	i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
	i_iGrpId:= iGrp, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
	i_xHotBlowerByKnob:= g_xHotBlowerOpenByKnob, 
	i_xAirExhaustFinishFlag:= xAirExhaustFinishFlag, 
	i_xAirExhaustLimit:= g_stStSysParam.stStSysParam_Save.xAirExhaustLimit, 
	i_xStopHotBlowerWhenEstop:= g_xStopHotBlowerWhenEstop, 
	i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_PastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
	o_xEno=> , 
	o_iErNo=> , 
	o_xHotBlowerFlag=> xAirHotFlag, 
	o_xFlag_HotBlowerStopping=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_HotBlowerStopDelay, 
	o_axHotBlowerEn=> , 
	o_axHotBlowerEn_Act=> axHotBlowerEn_Act
	);
(*加热*)
afbKS_FB_GrpHeatingCtrl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_iGrpId:= iGrp, 
	i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
	i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
	i_xAirHotFlag:= xAirHotFlag, 
	i_paxHotBlowerEn:= ADR(axHotBlowerEn_Act), 
	i_byHeatingOutWay_III:= g_stStSysParam.stStSysParam_Save.byHeatingOutWay_III, 
	i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_PastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
	o_xEno=> , 
	o_iErNo=> , 
	o_xHeatingFlag=> xHeatingFlag
	);
(*预加热*)
afbKS_FB_GrpPreHotBlowerCtrl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
	i_xUseButton_PreHotBlower:= g_xUseButton_PreHotBlower, 
	i_xUseButton_PreHeating:= g_xUseButton_PreHeating, 
	i_xflag_Estop:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Estop, 
	i_xflag_print:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Print, 
	i_xMachineRev:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xMachineRev, 
	i_xflag_printPreHeating:= g_xflag_printPreHeating, 
	i_PastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
	o_xEno=> , 
	o_iErNo=> );
(*风门*)
afbKS_FB_WindDoorCtl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_PastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
	o_xEn=> );
