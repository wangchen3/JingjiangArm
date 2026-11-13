(*@CES
Name=Action_Of
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=5d360f2c-2916-4f39-8393-74011a3acb10
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
fbKS_FB_Func_Of(
	i_xEn:= TRUE, 
	i_iGrpId:= i_iGrpId, 
	i_rAi_Swing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Of, 
	i_xIsDebugMode:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebugMode_Machine, 
	i_xMachineRev:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMachineRev, 
	i_rVel_Film:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film, 
	i_rVel_Max:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Max, 
	i_iCycleTime_Plc:= gc_TENSION_TSK_CYCLE_TIME, 
	i_iIndex_MainIO_Of:= i_iIndex_MainIO_Of,
	i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE,
	i_pstStSysParam:= i_pstStSysParam
);	