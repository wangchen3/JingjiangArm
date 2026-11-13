(*@CES
Name=Action_If
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=fd8aec44-2792-43c8-9dce-e312cd6a1dbf
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*放牵张力*)
fbKS_FB_Func_If(
	i_xEn:= TRUE, 
	i_iGrpId:= i_iGrpId, 
	i_rAi_Swing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_If, 
	i_xIsDebugMode:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebugMode_Machine, 
	i_xMachineRev:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMachineRev, 
	i_rVel_Film:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film, 
	i_rVel_Max:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Max, 
	i_iCycleTime_Plc:= gc_TENSION_TSK_CYCLE_TIME, 
	i_iIndex_MainIO_If:= i_iIndex_MainIO_If,
	i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE,
	i_pstStSysParam:= i_pstStSysParam
);	
	
	