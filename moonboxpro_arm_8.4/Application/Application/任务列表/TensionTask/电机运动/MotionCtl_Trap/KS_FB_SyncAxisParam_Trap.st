(*@CES
Name=KS_FB_SyncAxisParam_Trap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6588b639-e838-4495-9484-0472b9b3fcb8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SyncAxisParam_Trap
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpTrapMotion_Num: INT;
	i_aiGrpTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStMotorParam_Trap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Trap;
	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf : POINTER TO StSysGantryAxisInf;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_palrTarp_EncPos		:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;//横向点位轴的编码器位置

END_VAR
VAR_OUTPUT
END_VAR
VAR
	iRtn : INT;
	iN: INT;
	iUnitId: INT;
	iTypeId: INT;
	iCoreId: INT;
	iAxisId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	
	xInit_TrapPoint : BOOL;
	iAxisCount : INT;
	aiTargetStation : ARRAY [1..MAX_STATION_NUM] OF INT;//压力电机站列表
	aliABSEncPos : ARRAY [1..MAX_STATION_NUM] OF LINT;//零位绝对编码器位置
	axAxisRev : ARRAY [1..MAX_STATION_NUM] OF BOOL;//零位绝对编码器位置
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam<>0 AND i_pastStMotorParam_Trap <> 0 AND
		i_pstStSysStationInf <> 0 AND i_pstStSysGantryAxisInf <> 0 THEN
		
		FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
			iUnitId:= i_aiGrpUnitList[iN];
		(*横向电机方向*)	
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_Horiz_:=
					i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_HORIZ_[iUnitId].dwAxisProf.1;	
		(*横向减速比*)							
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_Horz:=			
					i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_Horz;
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_Horz:=			
					i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_Horz;
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_Horz:=
					i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rScrewPitch_Horz;		
		END_FOR
		
		FOR iN:=1 TO i_iGrpTrapMotion_Num BY 1 DO
			KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiGrpTrapMotion_StdList[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);	
		
			CASE iTypeId OF
			TYPE_UNIT_HORIZ:
				i_pastStMotorParam_Trap^[iUnitId].iAxisId := iAxisId;
				i_pastStMotorParam_Trap^[iUnitId].iCoreId := iCoreId;
				i_pastStMotorParam_Trap^[iUnitId].iStationId := i_aiGrpTrapMotion_StdList[iN];
				i_pastStMotorParam_Trap^[iUnitId].iUnitId := iUnitId;
				i_pastStMotorParam_Trap^[iUnitId].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_Horiz_;
				i_pastStMotorParam_Trap^[iUnitId].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller_Pressure;
				i_pastStMotorParam_Trap^[iUnitId].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller_Pressure;
				i_pastStMotorParam_Trap^[iUnitId].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_PrnRoller_Pressure;
				i_pastStMotorParam_Trap^[iUnitId].xMoveEn := g_xMoveEnTrap;//2026.01.28.115155 | + | 点位运动一直维持使能，后续还是要增加标志
				
				i_palrTarp_EncPos^[iUnitId] := i_pastStGetMotionSts^[iAxisId].lrPos_Enc;
			END_CASE
		END_FOR
		
		
		IF NOT xInit_TrapPoint THEN
			FOR iN := 1 TO  i_iGrpTrapMotion_Num BY 1 DO	
				KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiGrpTrapMotion_StdList[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);		
					
				IF iTypeId= TYPE_UNIT_HORIZ THEN
					iAxisCount := iAxisCount + 1;
					aiTargetStation[iAxisCount] := (i_aiGrpTrapMotion_StdList[iN]);
					aliABSEncPos[iAxisCount]:= i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].liABSPos_Trap;//g_aliABSPos_Horiz[iUnitId];
					axAxisRev[iAxisCount]:=i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_Horiz_;
					
					iRtn := KS_SetTrapDir(
						i_xEn:= TRUE, 
						i_iAxisId:= iAxisId, 
						i_iCoreId:= iCoreId,
						i_xRevDir:= axAxisRev[iAxisCount]);
				END_IF
			END_FOR
			
			iRtn := KS_SetTrapCoordinate(
						i_xEn:= TRUE, 
						i_iTarget_Num:= iAxisCount, 
						i_paiTargetStationList:= ADR(aiTargetStation), 
						i_paliABSEncPos:= ADR(aliABSEncPos), 
						i_paxAxisRev:= ADR(axAxisRev), 
						i_pastStAxisIdListInf:= ADR(g_astStAxisIdListInf), 
						i_pastStGetMotionSts:= ADR(g_astStGetMotionSts),
						i_pstStSysStationInf := i_pstStSysStationInf,
						i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
						ADR(g_alrCurrentAbsPos_Trap));		
			xInit_TrapPoint := TRUE;
		END_IF
	ELSE;
	END_IF
ELSE
	;
END_IF