(*@CES
Name=KS_FB_AxisEnCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7961db84-caed-4243-9b52-56f0bd4c7e60
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisEnCtl
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpGearMotion_Num: INT;
	i_aiGrpGearMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStMotorParam_Vel: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
END_VAR
VAR_OUTPUT
	o_iAxisId_Master: INT;
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	iTypeId: INT;
	iUnitId: INT;
	iCoreId: INT;
	iGroupId : INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	
	iAdjAxisId : INT;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_iGrpUnitNum_Pu>=1 AND i_iGrpUnitNum_Pu<=MAX_UNIT_NUM AND
		i_iGrpGearMotion_Num>=1 AND i_iGrpGearMotion_Num<= MAX_STATION_NUM AND
		i_pstStSysParam<>0 AND
		i_pastStAxisIdListInf<>0 AND
		i_pastStMotorParam_Vel<>0 AND
		i_pstStSysStationInf <> 0 THEN
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		FOR iN:=1 TO i_iGrpGearMotion_Num BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_aiGrpGearMotion_StdList[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);	
			KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiGrpGearMotion_StdList[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);	
			CASE iTypeId OF
			TYPE_MASTER_I,TYPE_MASTER_II:
				o_iAxisId_Master:= iAxisId;
			TYPE_CENTRAL_I,TYPE_CENTRAL_II:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= pstStGrpParam_UnSave^.xFlag_Print;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= pstStGrpParam_UnSave^.xMotRev_CentralDrum;
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= TRUE;
			TYPE_UNWIND_A_I,TYPE_UNWIND_A_II:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= pstStGrpParam_UnSave^.xAxisAForeward_Uw;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= pstStGrpParam_UnSave^.xMotRev_AxisA_Uw;
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= FALSE;
			TYPE_UNWIND_B_I,TYPE_UNWIND_B_II:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= pstStGrpParam_UnSave^.xAxisBForeward_Uw;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= pstStGrpParam_UnSave^.xMotRev_AxisB_Uw;				
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= FALSE;
			TYPE_REWIND_A_I,TYPE_REWIND_A_II:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= pstStGrpParam_UnSave^.xAxisAForeward_Rw;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= pstStGrpParam_UnSave^.xMotRev_AxisA_Rw;	
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= FALSE;
			TYPE_REWIND_B_I,TYPE_REWIND_B_II:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= pstStGrpParam_UnSave^.xAxisBForeward_Rw;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= pstStGrpParam_UnSave^.xMotRev_AxisB_Rw;			
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= FALSE;
			TYPE_INFEED_I,TYPE_INFEED_II:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= pstStGrpParam_UnSave^.xFlag_Print OR pstStGrpParam_UnSave^.xFlag_Ink OR i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= pstStGrpParam_UnSave^.xMotRev_If;			
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= TRUE;
			TYPE_OUTFEED_I,TYPE_OUTFEED_II:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= pstStGrpParam_UnSave^.xFlag_Print OR pstStGrpParam_UnSave^.xFlag_Ink OR i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= pstStGrpParam_UnSave^.xMotRev_Of;			
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= TRUE;
			TYPE_UNIT_PRN:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_PrnRoller;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller;			
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= TRUE;
			TYPE_UNIT_BOTTOM:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_BottomRoller;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_BottomRoller;							
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= TRUE;
			TYPE_UNIT_NET:
				i_pastStMotorParam_Vel^[iN].xMoveEn:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_NetRoller;
				i_pastStMotorParam_Vel^[iN].xMoveRev:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller;							
				i_pastStMotorParam_Vel^[iN].xMoveVelMode:= TRUE;
			END_CASE
		END_FOR
	END_IF
ELSE
	;
END_IF