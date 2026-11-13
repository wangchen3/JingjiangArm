(*@CES
Name=KS_FB_CheckServeOnDone_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d3768567-e4db-4539-97ab-c25a5fceb7f7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CheckServeOnDone_GantryTrap
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpGantryTrapGroup_Num : INT;
	i_iGrpGantryTrapMotion_Num: INT;
	i_aiGrpGantryTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pastStMotorParam_GantryTrap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
	i_xFlag_StopOrEStop : BOOL;
END_VAR
VAR_OUTPUT
	o_xEn : BOOL;
	o_xDone : BOOL;
	o_iErrNo : INT;
	o_iErrAxisId : INT;
	o_iErrTypeId : INT;
	o_iErrUnitId : INT;
	o_iErrCoreId : INT;
	o_iErrGroupId : INT;
END_VAR
VAR
	iN : INT;
	aiErrServoOn_Cnt : ARRAY [1..128] OF INT;
	iServoOnNum : INT;
	iNotNeedServoOnNum : INT;
END_VAR


{IMPLEMENTATION}
o_xEn := i_xEn;
o_iErrNo := 0;
o_iErrAxisId := 0;
o_iErrTypeId := 0;
o_iErrUnitId := 0;
o_iErrCoreId := 0;
iServoOnNum := 0;
iNotNeedServoOnNum := 0;
IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND
		i_pastStAxisIdListInf <> 0 AND
		i_pastStGetMotionSts <> 0 AND
		i_pastStMotorParam_GantryTrap <> 0 THEN
		FOR iN := 1 TO i_iGrpGantryTrapGroup_Num BY 1 DO
			IF i_pastStMotorParam_GantryTrap^[iN].xMoveEn THEN
				IF (*i_pastStGetMotionSts^[(i_pastStMotorParam_GantryTrap^[iN].iCoreId -1) * gc_ResCount_Profile + i_pastStMotorParam_GantryTrap^[iN].iAxisId].dwDriverSts.1 AND *)
					i_pastStGetMotionSts^[(i_pastStMotorParam_GantryTrap^[iN].iCoreId -1) * gc_ResCount_Profile + i_pastStMotorParam_GantryTrap^[iN].iAxisId].dwMotionSts.9 THEN
					iServoOnNum := iServoOnNum + 1;
					
					aiErrServoOn_Cnt[iN] := 0;
				ELSE
					aiErrServoOn_Cnt[iN] := aiErrServoOn_Cnt[iN] + 1;
					IF aiErrServoOn_Cnt[iN] > 10*1000/gc_TENSION_TSK_CYCLE_TIME THEN
						aiErrServoOn_Cnt[iN] := aiErrServoOn_Cnt[iN] -1;
// 						KS_HY_GetAxisIdForMotByStation(
// 							i_aiGrpGantryTrapMotion_StdList[iN],
// 							ADR(o_iErrAxisId),
// 							ADR(o_iErrTypeId),
// 							ADR(o_iErrUnitId),
// 							ADR(o_iErrCoreId),
// 							ADR(o_iErrGroupId),
// 							i_pastStAxisIdListInf);
						o_iErrAxisId := i_pastStMotorParam_GantryTrap^[iN].iAxisId;
						o_iErrTypeId := i_pastStMotorParam_GantryTrap^[iN].iTypeId;
						o_iErrUnitId := i_pastStMotorParam_GantryTrap^[iN].iUnitId;
						o_iErrCoreId := i_pastStMotorParam_GantryTrap^[iN].iCoreId;
						o_iErrGroupId := i_pastStMotorParam_GantryTrap^[iN].iGroupId;;
						o_iErrNo := -1;
					END_IF
					o_xDone := FALSE;
					EXIT;
				END_IF
			ELSE
				iNotNeedServoOnNum := iNotNeedServoOnNum + 1;
			END_IF
		END_FOR

		IF iServoOnNum = (i_iGrpGantryTrapGroup_Num - iNotNeedServoOnNum) THEN
			o_xDone := TRUE;
		END_IF
	END_IF
ELSE
	;
END_IF