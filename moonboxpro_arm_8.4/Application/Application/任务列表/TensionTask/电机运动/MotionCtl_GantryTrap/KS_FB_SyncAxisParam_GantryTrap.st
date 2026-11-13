(*@CES
Name=KS_FB_SyncAxisParam_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=bc95b75c-ad95-47a1-add9-a43b5df52185
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SyncAxisParam_GantryTrap
	VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpGantryTrapGroup_Num: INT;
	i_iGrpGantryTrapMotion_Num: INT;
	i_aiGrpGantryTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStMotorParam_GantryTrap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf : POINTER TO StSysGantryAxisInf;
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
	iGantryAxisCount : INT;
	aiTargetStation : ARRAY [1..MAX_STATION_NUM] OF INT;//压力电机站列表
	aliABSEncPos : ARRAY [1..MAX_STATION_NUM] OF LINT;//零位绝对编码器位置
	axAxisRev : ARRAY [1..MAX_STATION_NUM] OF BOOL;//零位绝对编码器位置
	
	//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
	axGantryAxisIsRev : ARRAY [1..20,1..2] OF BOOL;//最大20组龙门，每组龙门两个轴 
	

END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam<>0 AND i_pastStAxisIdListInf<>0 AND i_pastStMotorParam_GantryTrap <> 0 AND
		i_pstStSysStationInf <> 0 AND i_pstStSysGantryAxisInf <> 0  THEN
		Action_Sync_Gantry();
		
		FOR iN:=1 TO i_iGrpGantryTrapMotion_Num BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_aiGrpGantryTrapMotion_StdList[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);
			
			KS_GetAxisIdForMotByStation_Gantry(
				i_iStationId:= i_aiGrpGantryTrapMotion_StdList[iN],
				i_piAxisId:= ADR(iAxisId), 
				i_piTypeId:= ADR(iTypeId), 
				i_piUnitId:= ADR(iUnitId), 
				i_piCoreId:= ADR(iCoreId), 
				i_piGroupId:= ADR(iGroupId), 
				i_piAdjAxisId:= ADR(iAdjAxisId), 
				i_pstStSysStationInf:= i_pstStSysStationInf,
				i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf);	
		
			CASE iTypeId OF
			TYPE_UNIT_PRN_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId := iAxisId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId := iCoreId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iStationId := i_aiGrpGantryTrapMotion_StdList[iN];
				i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId := iUnitId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iTypeId := iTypeId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver := iAxisId + 10;
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual := iAdjAxisId;
				i_pastStMotorParam_GantryTrap^[iGroupId].diSyncErrorLimit := g_diSyncErrorLimit;
				i_pastStMotorParam_GantryTrap^[iGroupId].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller_Pressure;
				i_pastStMotorParam_GantryTrap^[iGroupId].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller_Pressure;
				i_pastStMotorParam_GantryTrap^[iGroupId].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_PrnRoller_Pressure;

				i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId := iGroupId;
// 			TYPE_UNIT_PRN_PRESS_M:
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_PrnRoller_Pressure;
// 			TYPE_UNIT_PRN_PRESS_G:
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_PrnRoller_Pressure;
				
			TYPE_UNIT_NET_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId := iAxisId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId := iCoreId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iStationId := i_aiGrpGantryTrapMotion_StdList[iN];
				i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId := iUnitId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iTypeId := iTypeId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver := iAxisId + 10;
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual := iAdjAxisId;
				i_pastStMotorParam_GantryTrap^[iGroupId].diSyncErrorLimit := g_diSyncErrorLimit;
				i_pastStMotorParam_GantryTrap^[iGroupId].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller_Pressure;
				i_pastStMotorParam_GantryTrap^[iGroupId].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller_Pressure;
				i_pastStMotorParam_GantryTrap^[iGroupId].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_NetRoller_Pressure;

				i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId := iGroupId;
// 			TYPE_UNIT_NET_PRESS_M:
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_NetRoller_Pressure;
// 			TYPE_UNIT_NET_PRESS_G:
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_NetRoller_Pressure;
				
			TYPE_UNIT_STR_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId := iAxisId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId := iCoreId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iStationId := i_aiGrpGantryTrapMotion_StdList[iN];
				i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId := iUnitId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId := iGroupId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iTypeId := iTypeId;
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver := iAxisId + 10;
				i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual := iAxisId + 20;
				i_pastStMotorParam_GantryTrap^[iGroupId].diSyncErrorLimit := g_diSyncErrorLimit;
				i_pastStMotorParam_GantryTrap^[iGroupId].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_StrRoller_Pressure;
				i_pastStMotorParam_GantryTrap^[iGroupId].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_StrRoller_Pressure;
				i_pastStMotorParam_GantryTrap^[iGroupId].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_StrRoller_Pressure;
				
// 			TYPE_UNIT_STR_PRESS_M:
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_StrRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_StrRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_StrRoller_Pressure;
// 			TYPE_UNIT_STR_PRESS_G:
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisNum := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_StrRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].uiAxisDen := i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_StrRoller_Pressure;
// 				i_pastStMotorParam_GantryTrap^[iN].rScrewPitch_ := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_StrRoller_Pressure;
			END_CASE
		END_FOR
		
		IF NOT g_xInit_TrapPoint THEN
			//2025.12.19.113411 | 龙门相关
			iGantryAxisCount := 0;
			FOR iN := 1 TO  g_stStStationInfo_KS.iStationNum BY 1 DO
// 				KS_HY_GetAxisIdForMotByStation(
// 						g_stStStationInfo_KS.aiStationId_List[iN],
// 						ADR(iAxisId),
// 						ADR(iTypeId),
// 						ADR(iUnitId),
// 						ADR(iCoreId),
// 						ADR(iGroupId),
// 						ADR(iAdjAxisId),
// 						ADR(g_astStAxisIdListInf));	
				KS_GetAxisIdForMotByStation_Gantry(
					i_iStationId:=g_stStStationInfo_KS.aiStationId_List[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf,
					i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf);		
				
					
				IF iTypeId= TYPE_UNIT_PRN_PRESS_MASTER THEN
					iGantryAxisCount := iGantryAxisCount + 1;
					aiTargetStation[iGantryAxisCount] := (g_stStStationInfo_KS.aiStationId_List[iN]);
					aliABSEncPos[iGantryAxisCount]:= g_stStSysParam.astStUnitParam_Save[iUnitId].liABSPos_Prn_M;
					axAxisRev[iGantryAxisCount]:=g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_M;
					
					//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
					axGantryAxisIsRev[iGroupId,1] := axAxisRev[iGantryAxisCount];
				ELSIF iTypeId= TYPE_UNIT_PRN_PRESS_G THEN
					iGantryAxisCount := iGantryAxisCount + 1;
					aiTargetStation[iGantryAxisCount] :=  (g_stStStationInfo_KS.aiStationId_List[iN]);
					aliABSEncPos[iGantryAxisCount]:=g_stStSysParam.astStUnitParam_Save[iUnitId].liABSPos_Prn_G;
					axAxisRev[iGantryAxisCount]:=g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_G;
					
					//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
					axGantryAxisIsRev[iGroupId,2] := axAxisRev[iGantryAxisCount];
				ELSIF iTypeId= TYPE_UNIT_NET_PRESS_MASTER THEN
					iGantryAxisCount := iGantryAxisCount + 1;
					aiTargetStation[iGantryAxisCount] :=  (g_stStStationInfo_KS.aiStationId_List[iN]);
					aliABSEncPos[iGantryAxisCount]:= g_stStSysParam.astStUnitParam_Save[iUnitId].liABSPos_Net_M;
					axAxisRev[iGantryAxisCount]:=g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_M;
					
					//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
					axGantryAxisIsRev[iGroupId,1] := axAxisRev[iGantryAxisCount];
				ELSIF iTypeId= TYPE_UNIT_NET_PRESS_G THEN
					iGantryAxisCount := iGantryAxisCount + 1;
					aiTargetStation[iGantryAxisCount] :=  (g_stStStationInfo_KS.aiStationId_List[iN]);
					aliABSEncPos[iGantryAxisCount]:= g_stStSysParam.astStUnitParam_Save[iUnitId].liABSPos_Net_G;
					axAxisRev[iGantryAxisCount]:=g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_G;
					
					//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
					axGantryAxisIsRev[iGroupId,2] := axAxisRev[iGantryAxisCount];
				ELSIF iTypeId= TYPE_UNIT_STR_PRESS_MASTER THEN
					iGantryAxisCount := iGantryAxisCount + 1;
					aiTargetStation[iGantryAxisCount] :=  (g_stStStationInfo_KS.aiStationId_List[iN]);
					aliABSEncPos[iGantryAxisCount]:= g_stStSysParam.astStUnitParam_Save[iUnitId].liABSPos_Str_M;
					axAxisRev[iGantryAxisCount]:=g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_M;
					
					//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
					axGantryAxisIsRev[iGroupId,1] := axAxisRev[iGantryAxisCount];
				ELSIF iTypeId= TYPE_UNIT_STR_PRESS_G THEN
					iGantryAxisCount := iGantryAxisCount + 1;
					aiTargetStation[iGantryAxisCount] :=  (g_stStStationInfo_KS.aiStationId_List[iN]);
					aliABSEncPos[iGantryAxisCount]:= g_stStSysParam.astStUnitParam_Save[iUnitId].liABSPos_Str_G;
					axAxisRev[iGantryAxisCount]:=g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_G;
					
					//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
					axGantryAxisIsRev[iGroupId,2] := axAxisRev[iGantryAxisCount];
				END_IF
				
				
				//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
				IF  iTypeId= TYPE_UNIT_PRN_PRESS_G OR iTypeId= TYPE_UNIT_NET_PRESS_G OR iTypeId= TYPE_UNIT_STR_PRESS_G THEN
					iRtn := KS_SetTrapDir(
						i_xEn:= TRUE, 
						i_iAxisId:= iAxisId, 
						i_iCoreId:= iCoreId,
						i_xRevDir:= axGantryAxisIsRev[iGroupId,1] XOR axGantryAxisIsRev[iGroupId,2]);
				END_IF
// 				IF iTypeId= TYPE_UNIT_PRN_PRESS_MASTER OR iTypeId= TYPE_UNIT_PRN_PRESS_G OR
// 					iTypeId= TYPE_UNIT_NET_PRESS_MASTER OR iTypeId= TYPE_UNIT_NET_PRESS_G OR
// 					iTypeId= TYPE_UNIT_STR_PRESS_MASTER OR iTypeId= TYPE_UNIT_STR_PRESS_G THEN
// 					iRtn := KS_SetTrapDir(
// 						i_xEn:= TRUE, 
// 						i_iAxisId:= iAxisId, 
// 						i_iCoreId:= iCoreId,
// 						i_xRevDir:= axAxisRev[iGantryAxisCount]);
// 				END_IF
			END_FOR
			g_xInit_TrapPoint:= TRUE;
		END_IF	
		IF NOT xInit_TrapPoint THEN
			
			//2024.11.26.215136 | 在这里设置压力电机的零位，也就是合压位
			//iRtn := GT_RN_SetTrapCoordinate(targetNum:= byGantryAxisCount, targetStation:= ADR(abytargetStation), targetAxis:= ADR(aliABSEncPos));
			iRtn := KS_SetTrapCoordinate(
									i_xEn:= TRUE, 
									i_iTarget_Num:= iGantryAxisCount, 
									i_paiTargetStationList:= ADR(aiTargetStation), 
									i_paliABSEncPos:= ADR(aliABSEncPos), 
									i_paxAxisRev:= ADR(axAxisRev), 
									i_pastStAxisIdListInf:= ADR(g_astStAxisIdListInf), 
									i_pastStGetMotionSts:= ADR(g_astStGetMotionSts),
									i_pstStSysStationInf := i_pstStSysStationInf,
									i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
									ADR(g_alrCurrentAbsPos_Init)
									);
		
		
			xInit_TrapPoint := TRUE;
		END_IF
	ELSE;
	END_IF
ELSE
	;
END_IF