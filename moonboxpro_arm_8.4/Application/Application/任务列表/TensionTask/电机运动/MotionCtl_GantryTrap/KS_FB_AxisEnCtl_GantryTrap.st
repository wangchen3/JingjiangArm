(*@CES
Name=KS_FB_AxisEnCtl_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6adbed21-caa4-496e-a20b-968a8a51526d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisEnCtl_GantryTrap
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpGantryTrapGroup_Num: INT;
	i_iGrpGantryTrapMotion_Num: INT;
	i_aiGrpGantryTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStMotorParam_GantryTrap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
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
	
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_iGrpGantryTrapGroup_Num >0 AND
		i_pstStSysParam<>0 AND
		i_pastStAxisIdListInf<>0 AND
		i_pastStMotorParam_GantryTrap<>0 THEN
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		FOR iGroupId:=1 TO i_iGrpGantryTrapGroup_Num BY 1 DO
			CASE i_pastStMotorParam_GantryTrap^[iGroupId].iTypeId OF
			TYPE_UNIT_PRN_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn := pstStGrpParam_Save^.wCtl_Pressure_Up_Dn.5;//g_axEn_Motor_Gantry[i_iGrpId];
							//i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].byEn_Motor_Pressure.0;
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_M := 
									i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].xMotRev_PrnRoller_Pressure_M;
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_G := 
									i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].xMotRev_PrnRoller_Pressure_G;
				
			TYPE_UNIT_NET_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn := pstStGrpParam_Save^.wCtl_Pressure_Up_Dn.5;
							//i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].byEn_Motor_Pressure.1;
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_M := 
									i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].xMotRev_NetRoller_Pressure_M;
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_G := 
									i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].xMotRev_NetRoller_Pressure_G;
			TYPE_UNIT_STR_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn := pstStGrpParam_Save^.wCtl_Pressure_Up_Dn.5;
							//i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].byEn_Motor_Pressure.2;
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_M := 
									i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].xMotRev_StrRoller_Pressure_M;
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_G := 
									i_pstStSysParam^.astStUnitParam_UnSave[i_pastStMotorParam_GantryTrap^[iGroupId].iUnitId].xMotRev_StrRoller_Pressure_G;
					
			END_CASE
			
(*			
			KS_HY_GetAxisIdForMotByStation(
				i_aiGrpGantryTrapMotion_StdList[iN],
				ADR(iAxisId),
				ADR(iTypeId),
				ADR(iUnitId),
				ADR(iCoreId),
				i_pastStAxisIdListInf);		
			CASE iTypeId OF
			TYPE_UNIT_PRN_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.0;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_M;
			TYPE_UNIT_PRN_PRESS_M:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.0;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_M;
			TYPE_UNIT_PRN_PRESS_G:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.1;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_G;
			TYPE_UNIT_NET_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.2;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_M;
			TYPE_UNIT_NET_PRESS_M:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.2;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_M;
			TYPE_UNIT_NET_PRESS_G:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.3;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_G;
			TYPE_UNIT_STR_PRESS_MASTER:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.4;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_M;
			TYPE_UNIT_STR_PRESS_M:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.4;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_M;
			TYPE_UNIT_STR_PRESS_G:
				i_pastStMotorParam_GantryTrap^[iN].xMoveEn := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byEn_Motor_Pressure.5;
				i_pastStMotorParam_GantryTrap^[iN].xMoveRev := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_G;
			END_CASE
*)
		END_FOR
	END_IF
ELSE
	;
END_IF