(*@CES
Name=Action_SysAlarmFlag
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=7c8d6d99-57ae-4d28-9f0b-ad56e7c7449b
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
CASE iTypeId OF 		
	TYPE_CENTRAL_I,TYPE_CENTRAL_II:
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_CENTRAL:= axAlarmFlag[iN];
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_CENTRAL:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNWIND_A_I,TYPE_UNWIND_A_II:
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_UW_A:= axAlarmFlag[iN];		
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_UW_A:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNWIND_B_I,TYPE_UNWIND_B_II:
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_UW_B:= axAlarmFlag[iN];					
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_UW_B:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_REWIND_A_I,TYPE_REWIND_A_II:
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_RW_A:= axAlarmFlag[iN];						
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_RW_A:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_REWIND_B_I,TYPE_REWIND_B_II:
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_RW_B:= axAlarmFlag[iN];			
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_RW_B:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_INFEED_I,TYPE_INFEED_II:
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_If:= axAlarmFlag[iN];			
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_If:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_OUTFEED_I,TYPE_OUTFEED_II:
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_Of:= axAlarmFlag[iN];	
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_Of:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_PRN:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_PrnRoller:= axAlarmFlag[iN];	
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Prn:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_BOTTOM:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_BottomRoller:= axAlarmFlag[iN];		
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Bottom:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_NET:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_NetRoller:= axAlarmFlag[iN];	
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Net:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_PRN_PRESS_MASTER:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Prn_Pressure_M:= axAlarmFlag[iN];		
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Prn_M:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_PRN_PRESS_G:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Prn_Pressure_G:= axAlarmFlag[iN];			
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Prn_G:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_NET_PRESS_MASTER:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Net_Pressure_M:= axAlarmFlag[iN];			
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Net_M:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_NET_PRESS_G:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Net_Pressure_G:= axAlarmFlag[iN];			
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Net_G:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_STR_PRESS_MASTER:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Str_Pressure_M:= axAlarmFlag[iN];			
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Str_M:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_STR_PRESS_G:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Str_Pressure_G:= axAlarmFlag[iN];			
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Str_G:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
	TYPE_UNIT_HORIZ:
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Horz:= axAlarmFlag[iN];		
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwAlarmDetail_Horz:= i_pastStGetMotionSts^[iAxisId].dwAlarmDetail;
END_CASE
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iStationId_Alarm:= i_aiStationList[iN];