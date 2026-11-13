(*@CES
Name=Action_LampAndAlarmBell
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=0d232518-e1b5-4256-8c37-2942bed79b31
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
afbKS_FB_GrpAlarmBellControl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pastStIOMap_AxisBasic:= ADR(g_astStIOMap_Axis_FE), 
	i_pastStIOMap_Main:= ADR(g_astStIOMap_Main_FE), 
	i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
	i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
	i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
	i_xKeepAlarm_NoMaterial:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xKeepAlarm_NoMaterial,//g_axKeepAlarm_NoMaterial[iGrp], 
	i_xAlarm_CutDne_Uw:= g_xAlarm_CutDne_Uw, 
	i_xAlarm_AccOrDecing:= g_axAlarm_AccOrDecing[iGrp], 
	i_xAlarm_CutFinish_Uw:= g_axAlarm_CutFinish_Uw[iGrp], 
	i_xAlarm_CutFinish_Rw:= g_axAlarm_CutFinish_Rw[iGrp], 
	i_xAlarm_VolDiamAlarm_Uw:= g_axAlarm_VolDiamAlarm_Uw[iGrp], 
	i_xAlarmBell_Uw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xAlarmBell_Uw, 
	i_xAlarmBell_Rw:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xAlarmBell_Rw OR g_xAtleastOneUnitOverTemp OR g_xAutoPrintMasterAlarm[iGrp], 

	i_axFlag_AdjValid_V:= (*g_stStSysParam.astStUnitParam_Save[iUnitId].dwFlag_Sts.0*), (*待完善*)
	i_axThisUnitEna:= ,(*待完善*) 
	o_xEno=> , 
	o_iErNo=> , 
	o_xPrnRollerLoose_AtLeast1=> g_stStSysParam.astStGrpParam_Save[iGrp].xPrnRollerLoose_AtLeast1, 
	o_xLostPressure=> g_stStSysParam.astStGrpParam_Save[iGrp].xLostPressure, 
	o_xbrakeResistanceTempHigh_AtLeast1=> g_stStSysParam.astStGrpParam_Save[iGrp].xbrakeResistanceTempHigh_AtLeast1);
		
afbKS_FB_GrpIndicatorLampCtrl[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iCustomerNameId:= g_stStSysParam.stStSysParam_Save.iCustomerId, 
	i_iGrpAxisNum_PU:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:=aiGrpAxisList , 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pastStIOMap_AxisBasic:= ADR(g_astStIOMap_Axis_FE), 
	i_pastStIOMap_Main:= ADR(g_astStIOMap_Main_FE), 
	i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
	i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
	o_xEno=> , 
	o_iErNo=> );		