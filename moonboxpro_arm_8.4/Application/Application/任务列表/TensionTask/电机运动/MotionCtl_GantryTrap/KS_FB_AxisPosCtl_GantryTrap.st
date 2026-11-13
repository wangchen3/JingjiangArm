(*@CES
Name=KS_FB_AxisPosCtl_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=58bb9038-ba9b-45e2-97ef-dcb3af1a4c94
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisPosCtl_GantryTrap
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_iGrpGantryTrapGroup_Num: INT;
	i_iGrpGantryTrapMotion_Num: INT;
	i_aiGrpGantryTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStMotorParam_GantryTrap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
	
	i_arvel_UnitPressure_Prn:  ARRAY [1..MAX_UNIT_NUM] OF REAL;
	i_arvel_UnitPressure_Net:  ARRAY [1..MAX_UNIT_NUM] OF REAL;
	i_alrTargetPos_Prn:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	i_alrTargetPos_Prn_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	i_alrTargetPos_Prn_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	i_alrTargetPos_Net:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	i_alrTargetPos_Net_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	i_alrTargetPos_Net_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
END_VAR
VAR_OUTPUT
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
		i_iGrpGantryTrapGroup_Num > 0 AND
		i_pstStSysParam<>0 AND
		i_pastStAxisIdListInf<>0 AND
		i_pastStMotorParam_GantryTrap<>0 THEN
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		
		
		FOR iGroupId := 1 TO i_iGrpUnitNum_Pu BY 1 DO
			i_pastStMotorParam_GantryTrap^[iGroupId].diMax_Vel :=REAL_TO_DINT(i_arvel_UnitPressure_Prn[iGroupId]);
			i_pastStMotorParam_GantryTrap^[iGroupId].liTarget_Pos_All := LREAL_TO_LINT(i_alrTargetPos_Prn[iGroupId]);
			i_pastStMotorParam_GantryTrap^[iGroupId].diMain_Axis_Shift := LREAL_TO_DINT(i_alrTargetPos_Prn_M[iGroupId]);
			i_pastStMotorParam_GantryTrap^[iGroupId].diSecond_Axis_Shift := LREAL_TO_DINT(i_alrTargetPos_Prn_G[iGroupId]);
			
			i_pastStMotorParam_GantryTrap^[iGroupId+i_iGrpUnitNum_Pu].diMax_Vel :=REAL_TO_DINT(i_arvel_UnitPressure_Net[iGroupId]);
			i_pastStMotorParam_GantryTrap^[iGroupId+i_iGrpUnitNum_Pu].liTarget_Pos_All := LREAL_TO_LINT(i_alrTargetPos_Net[iGroupId]);
			i_pastStMotorParam_GantryTrap^[iGroupId+i_iGrpUnitNum_Pu].diMain_Axis_Shift := LREAL_TO_DINT(i_alrTargetPos_Net_M[iGroupId]);
			i_pastStMotorParam_GantryTrap^[iGroupId+i_iGrpUnitNum_Pu].diSecond_Axis_Shift := LREAL_TO_DINT(i_alrTargetPos_Net_G[iGroupId]);
		END_FOR
		
		
// 		FOR iGroupId:=1 TO i_iGrpGantryTrapGroup_Num BY 1 DO
// 			i_pastStMotorParam_GantryTrap^[iGroupId].diMax_Vel :=100;
// 			i_pastStMotorParam_GantryTrap^[iGroupId].liTarget_Pos_All := 1000000;
// 			i_pastStMotorParam_GantryTrap^[iGroupId].diMain_Axis_Shift := 500000;
// 			i_pastStMotorParam_GantryTrap^[iGroupId].diSecond_Axis_Shift := 100000;
// 		END_FOR	
	END_IF
ELSE
	;
END_IF