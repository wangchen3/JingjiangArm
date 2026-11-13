(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=97f1eda9-c9e2-49cd-872f-7c0d5c7c621e
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_abyGrpAxisList[iN];
	pstStRSV_UnitParam_Save:= ADR(i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId]);
	pstStRSV_UnitParam_UnSave:= ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId]);
	pstStRSV_UnitParam_UnSave^.byFiberMoveMode:=g_astStFiberMoveStepDriver[iUnitId].byFiberMoveMode;
	pstStRSV_UnitParam_UnSave^.byFiberMoveDir:=g_astStFiberMoveStepDriver[iUnitId].byFiberMoveDir;
	pstStRSV_UnitParam_UnSave^.rFiberMoveVel:=g_astStFiberMoveStepDriver[iUnitId].rFiberMoveVel;
	pstStRSV_UnitParam_UnSave^.rFiberMoveDistanceOut:=g_astStFiberMoveStepDriver[iUnitId].rFiberMoveDistanceOut;
	pstStRSV_UnitParam_UnSave^.wState_FiberMove.8:=g_astStFiberMoveStepDriver[iUnitId].xFiberMoveSyncDone;
	pstStRSV_UnitParam_UnSave^.wState_FiberMove.9:=g_astStFiberMoveStepDriver[iUnitId].xFiberMoveIsSyncing;
//	pstStRSV_UnitParam_UnSave^.xFiberMoveIdle:=(g_astStFiberMoveStepDriver[iUnitId].iFiberMoveState=0) AND (NOT pstStRSV_UnitParam_UnSave^.wState_FiberMove.0);
	pstStRSV_UnitParam_UnSave^.xFiberMoveIdle:=(g_astStFiberMoveStepDriver[iUnitId].iFiberMoveState=0) AND (NOT g_astStFiberMoveStepDriver[iUnitId].xFiberMoveMotorRunning);
	//Save
	pstStRSV_UnitParam_Save^.rFiberMoveAdjust:=g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust;
	pstStRSV_UnitParam_Save^.rFiberMoveAdjust_ByOnlie:=g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust_ByOnline;
	
	//2026.05.27.171111
	pstStRSV_UnitParam_UnSave^.wState_FiberMove.10:=i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xFiberMove_DebugMode;//光纤行走调试模式
	
END_FOR