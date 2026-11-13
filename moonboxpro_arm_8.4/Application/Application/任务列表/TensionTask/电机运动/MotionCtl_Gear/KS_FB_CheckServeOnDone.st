(*@CES
Name=KS_FB_CheckServeOnDone
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4accf54a-639d-49b8-ab4c-ff599b501e0c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CheckServeOnDone
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpGearMotion_Num: INT;
	i_aiGrpGearMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pastStMotorParam_Vel: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	i_xFlag_StopOrEStop : BOOL;
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
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
	o_iErrAdjAxisId : INT;
	o_iMoveErrCode: INT; (* 初始化错误代码
												0-正常
												1-使能异常
												2-模态0设置异常
												3-模态1设置异常
												4-规划器启动异常
												5-PT模式设置异常
												6-伺服打开超时
												7-PT规划异常 *)
	
END_VAR
VAR
	iN : INT;
	aiErrServoOn_Cnt : ARRAY [1..128] OF INT;
	iServoOnNum : INT;
	iNotNeedServoOnNum : INT;
	iNeedServoOnNum : INT;	
	iNeedServoOnNum_Pre : INT;
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
iNeedServoOnNum := 0;
o_iMoveErrCode := 0;
IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND
		i_pastStAxisIdListInf <> 0 AND
		i_pastStGetMotionSts <> 0 AND
		i_pastStMotorParam_Vel <> 0 AND i_pstStSysStationInf <> 0 THEN
		FOR iN := 1 TO i_iGrpGearMotion_Num BY 1 DO
			IF i_pastStMotorParam_Vel^[iN].xMoveEn THEN
				iNeedServoOnNum := iNeedServoOnNum + 1;
				IF (*i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwDriverSts.1 AND*) 
					i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwMotionSts.9 AND
					//2026.1.20.103746 | + | 运动流程达到写数据的流程
					(i_pastStMotorParam_Vel^[iN].iMoveStep = MOTIONCTL_STEP_WRITEDATA_Run OR
						i_pastStMotorParam_Vel^[iN].iMoveStep = MOTIONCTL_STEP_WRITEDATA_Inch OR
						i_pastStMotorParam_Vel^[iN].iMoveStep = MOTIONCTL_STEP_WRITEDATA_Preg OR
						i_pastStMotorParam_Vel^[iN].iMoveStep = MOTIONCTL_STEP_WRITEDATA_Jog) THEN
					iServoOnNum := iServoOnNum + 1;
					
					aiErrServoOn_Cnt[iN] := 0;
				ELSE
					aiErrServoOn_Cnt[iN] := aiErrServoOn_Cnt[iN] + 1;
					//2026.1.14.165203 | 伺服等待时间增加到15秒，因为经常出现私服打开超时不知道原因
					IF aiErrServoOn_Cnt[iN] > 15*1000/gc_TENSION_TSK_CYCLE_TIME THEN
						aiErrServoOn_Cnt[iN] := aiErrServoOn_Cnt[iN] -1;
// 						KS_HY_GetAxisIdForMotByStation(
// 							i_aiGrpGearMotion_StdList[iN],
// 							ADR(o_iErrAxisId),
// 							ADR(o_iErrTypeId),
// 							ADR(o_iErrUnitId),
// 							ADR(o_iErrCoreId),
// 							ADR(o_iErrGroupId),
// 							ADR(o_iErrAdjAxisId),
// 							i_pastStAxisIdListInf);
						KS_GetAxisIdForMotByStation_V2(
							i_iStationId:= i_aiGrpGearMotion_StdList[iN],
							i_piAxisId:= ADR(o_iErrAxisId), 
							i_piTypeId:= ADR(o_iErrTypeId), 
							i_piUnitId:= ADR(o_iErrUnitId), 
							i_piCoreId:= ADR(o_iErrCoreId), 
							i_piGroupId:= ADR(o_iErrGroupId), 
							i_piAdjAxisId:= ADR(o_iErrAdjAxisId), 
							i_pstStSysStationInf:= i_pstStSysStationInf);
						o_iMoveErrCode := 6;
						o_iErrNo := -1;
					END_IF
					o_xDone := FALSE;
					EXIT;
				END_IF
			ELSE
				iNotNeedServoOnNum := iNotNeedServoOnNum + 1;
			END_IF
		END_FOR

		IF iServoOnNum = iNeedServoOnNum(*(i_iGrpGearMotion_Num - iNotNeedServoOnNum)*) THEN
			o_xDone := TRUE;
		END_IF
		IF iNeedServoOnNum_Pre <> iNeedServoOnNum THEN
			FOR iN := 1 TO i_iGrpGearMotion_Num BY 1 DO
				aiErrServoOn_Cnt[iN] := 0;
			END_FOR
		END_IF
		iNeedServoOnNum_Pre := iNeedServoOnNum;
	END_IF
ELSE
	IF i_xFlag_StopOrEStop THEN
		o_xDone := FALSE;
	END_IF
END_IF