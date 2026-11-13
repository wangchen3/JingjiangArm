(*@CES
Name=KS_FB_MotionCtl_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fc0caa18-3e5f-4c0a-bc8f-f82105ab037a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_MotionCtl_GantryTrap
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
	i_pastStSetPrm					:POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pastStMotorParam_GantryTrap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
	i_pastStTrapAxisParam_Gantray : POINTER TO ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF StTrapAxisParam_Gantray;
	
	i_pastStHandWheel: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StHandWheel;
	i_pastStHandWheel_BtnCtl: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StHandWheel_BtnCtl;
	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf : POINTER TO StSysGantryAxisInf;
	i_pstStEvtReq: POINTER TO StEvtReq;(* 动作提取 *)
	
END_VAR
VAR_OUTPUT
END_VAR
VAR_IN_OUT
END_VAR
VAR		
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	dwRtn : DWORD;
	iRtn : INT;
	astStSetPrm_Pre				: ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	stStGetPrm				: TMultiMcFunctionReadPrm;
	iMaxRetryTimes: INT := 3;
	aiRetryCount: ARRAY [1..MAX_STATION_NUM] OF INT := [0];
	iWaitedCycleCount: INT := 0;
	xForceAxisOff: BOOL;(*强制下伺服标志*)

		
	afbTRIG_Start_Servo: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	afbTRIG_Stop_Servo: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	axServoOn: ARRAY [1..MAX_STATION_NUM] OF BOOL;
	
	//iN: INT;
	lrTemp: LREAL;
	iAxisId_T: INT;
	iCoreId_T: INT;
	iTypeId_T: INT;
	iUnitId_T: INT;
	
	fbKS_FB_AxisEnCtl_GantryTrap : KS_FB_AxisEnCtl_GantryTrap;
	fbKS_FB_SyncAxisParam_GantryTrap : KS_FB_SyncAxisParam_GantryTrap;
	fbKS_FB_AxisPosCtl_GantryTrap : KS_FB_AxisPosCtl_GantryTrap;
	fbKS_FB_McMultiFunCtl_GantryTrap : KS_FB_McMultiFunCtl_GantryTrap;
	iGroupId : INT;
	
	aiWaitingModalChange : ARRAY [1..MAX_STATION_NUM] OF INT;
	
	fbKS_FB_GantryTrap : KS_FB_Act_GantryTrap;
	
	arvel_UnitPressure_Prn:  ARRAY [1..MAX_UNIT_NUM] OF REAL;
	arvel_UnitPressure_Net:  ARRAY [1..MAX_UNIT_NUM] OF REAL;

	alrTargetPos_Prn:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Prn_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Prn_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Net:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Net_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Net_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	xNeedMoveUp_Stop_Or_Estop_Valid: BOOL;
	fbTRIG_ResetEstop:R_TRIG;
	
	lrPos1 : LREAL;
	lrPos2: LREAL;
	//test 2026.04.10.193425
	iN:INT;
	iUnitId: INT;
	iAxisId: INT;
	iTypeId:INT;
	iCoreId:INT;
	iAdjAxisId:INT;
END_VAR



{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam<>0 AND i_pastStAxisIdListInf<>0 AND i_pastStSetPrm <> 0 AND i_pastStGetMotionSts <> 0 AND
		i_iGrpGantryTrapGroup_Num > 0 AND i_pastStMotorParam_GantryTrap <> 0 AND i_pstStHYLogFifo <> 0 AND i_pastStIOMap_Main_FE <> 0 AND 
		i_pastStIOMap_Axis_FE <> 0 AND i_pastStHandWheel <> 0 AND i_pastStTrapAxisParam_Gantray <> 0 AND
		i_pastStHandWheel_BtnCtl <> 0 THEN			

		pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		fbKS_FB_SyncAxisParam_GantryTrap(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpGantryTrapGroup_Num := i_iGrpGantryTrapGroup_Num,
			i_iGrpGantryTrapMotion_Num:= i_iGrpGantryTrapMotion_Num, 
			i_aiGrpGantryTrapMotion_StdList:= i_aiGrpGantryTrapMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf,
			i_pastStMotorParam_GantryTrap := i_pastStMotorParam_GantryTrap,
			i_pstStSysStationInf := i_pstStSysStationInf,
			i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf
		);
			
		fbKS_FB_AxisEnCtl_GantryTrap(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpGantryTrapGroup_Num := i_iGrpGantryTrapGroup_Num,
			i_iGrpGantryTrapMotion_Num:= i_iGrpGantryTrapMotion_Num, 
			i_aiGrpGantryTrapMotion_StdList:= i_aiGrpGantryTrapMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_pastStMotorParam_GantryTrap:= i_pastStMotorParam_GantryTrap
		);	
		
xNeedMoveUp_Stop_Or_Estop_Valid:= FALSE;
fbTRIG_ResetEstop(CLK:= (NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop) AND
							 (NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping));
xNeedMoveUp_Stop_Or_Estop_Valid:= i_pstStEvtReq^.xReqEstop OR i_pstStEvtReq^.xReqStop OR 
								i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_LinkageAxisAlarm;

		fbKS_FB_GantryTrap(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId,  
			i_pstStSysParam:= i_pstStSysParam, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpGantryTrapGroup_Num:= i_iGrpGantryTrapGroup_Num, 
			i_iGrpGantryTrapMotion_Num:= i_iGrpGantryTrapMotion_Num, 
			i_aiGrpGantryTrapMotion_StdList:= i_aiGrpGantryTrapMotion_StdList, 
			i_pastStGetMotionSts:= i_pastStGetMotionSts, 
			i_xFlag_Stop:= pstStGrpParam_UnSave^.xFlag_Stop, 
			i_xFlag_Estop:= pstStGrpParam_UnSave^.xFlag_EStop OR pstStGrpParam_UnSave^.xFlag_EStoping, 
			i_xDebugMode:= pstStGrpParam_UnSave^.xIsDebugMode_Machine, 
			i_axFlag_Alarm_Pressure:= , 
			i_pastStTrapAxisParam_Gantray:= i_pastStTrapAxisParam_Gantray, 
			i_xStopOrEstop_Valid:= xNeedMoveUp_Stop_Or_Estop_Valid,
			i_byCycle_PrnRoller_MoveUp:= 3, 
			i_ReqResetEstop:= fbTRIG_ResetEstop.Q, //2026.05.07.135149 新＋ 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_pastStMotorParam_GantryTrap:= i_pastStMotorParam_GantryTrap, 
			i_pastStHandWheel:=i_pastStHandWheel,
			i_pastStHandWheel_BtnCtl := i_pastStHandWheel_BtnCtl,
			i_pstStSysStationInf := i_pstStSysStationInf,
			i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
			o_xEn=> , 
			o_iErNo=> , 
			o_arVel_Prn=> arvel_UnitPressure_Prn, 
			o_arVel_Net=> arvel_UnitPressure_Net, 
			o_alrTargetPos_Prn=> alrTargetPos_Prn, 
			o_alrTargetPos_Prn_M=> alrTargetPos_Prn_M, 
			o_alrTargetPos_Prn_G=> alrTargetPos_Prn_G, 
			o_alrTargetPos_Net=> alrTargetPos_Net, 
			o_alrTargetPos_Net_M=> alrTargetPos_Net_M, 
			o_alrTargetPos_Net_G=> alrTargetPos_Net_G
		);
// 				g_stStSysParam.astStGrpParam_Save[1].rStep_Fast :=1;
// 				g_stStSysParam.astStGrpParam_Save[1].rVel_Press_Prn := 1;
		//2026.04.10.184313 //超旭增加一些保存 //Hou.N
		FOR iN := 1 TO  i_iGrpGantryTrapMotion_Num BY 1 DO	
				KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiGrpGantryTrapMotion_StdList[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);	
	
	
				IF iTypeId= TYPE_UNIT_PRN_PRESS_MASTER THEN
					g_alrGantryTrapM_EncPos[iUnitId]:= i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Enc;
					g_alrGantryTrap_PrfPos[iUnitId]:= i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Prf;
				END_IF	
				IF iTypeId= TYPE_UNIT_PRN_PRESS_M THEN
					g_alrGantryTrapM_PrfPos[iUnitId]:= i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Prf;
				END_IF
				IF iTypeId= TYPE_UNIT_PRN_PRESS_G THEN
					g_alrGantryTrapG_EncPos[iUnitId]:= i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Enc;
					g_alrGantryTrapG_PrfPos[iUnitId]:= i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Prf;
				END_IF			
			END_FOR	

		fbKS_FB_AxisPosCtl_GantryTrap(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu,
			i_iGrpGantryTrapGroup_Num:= i_iGrpGantryTrapGroup_Num, 
			i_iGrpGantryTrapMotion_Num:= i_iGrpGantryTrapMotion_Num, 
			i_aiGrpGantryTrapMotion_StdList:= i_aiGrpGantryTrapMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_pastStMotorParam_GantryTrap:= i_pastStMotorParam_GantryTrap,
			i_arvel_UnitPressure_Prn:= arvel_UnitPressure_Prn,//:  ARRAY [1..MAX_UNIT_NUM] OF REAL;
			i_arvel_UnitPressure_Net:= arvel_UnitPressure_Net,//:  ARRAY [1..MAX_UNIT_NUM] OF REAL;
			i_alrTargetPos_Prn:= alrTargetPos_Prn,//:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
			i_alrTargetPos_Prn_M := alrTargetPos_Prn_M,//:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
			i_alrTargetPos_Prn_G := alrTargetPos_Prn_G,//:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
			i_alrTargetPos_Net := alrTargetPos_Net,//:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
			i_alrTargetPos_Net_M := alrTargetPos_Net_M,//:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
			i_alrTargetPos_Net_G := alrTargetPos_Net_G//:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
		);
		
		
		FOR iGroupId:=1 TO i_iGrpGantryTrapGroup_Num BY 1 DO
			afbTRIG_Start_Servo[iGroupId](CLK:= i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn);
			afbTRIG_Stop_Servo[iGroupId](CLK:= NOT i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn);	
			IF afbTRIG_Start_Servo[iGroupId].Q THEN
				IF i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep= MOTION_STEP_Nothing THEN
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
				ELSE;
				END_IF
			END_IF
			IF afbTRIG_Stop_Servo[iGroupId].Q THEN
				IF i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep= MOTION_STEP_Nothing OR
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
					;
				ELSE
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
				END_IF
			END_IF
			
			CASE i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep OF
			MOTION_STEP_Nothing:
				;
			MOTIONCTL_STEP_AXISOFF:
				iRtn:= KS_SetMotionServoOff_GantryTrap(
					i_iAxisId:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId, 
					i_iGroupId:= i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId, 
					i_iStationId:= i_pastStMotorParam_GantryTrap^[iGroupId].iStationId, 
					i_iAxisSlaver:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver,
					i_iAxisMasterVirtual:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual,
					i_xForceAxisOff := FALSE,
					i_pxServoOn := ADR(axServoOn[iGroupId]),
					i_dwMotionSts:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) +i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId].dwMotionSts, 
					i_dwDriverSts:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) +i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId].dwDriverSts,
					i_dwMotionSts_Slaver:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) +i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver].dwMotionSts, 
					i_dwDriverSts_Slaver:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) +i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver].dwDriverSts,
					i_pstStHYLogFifo:= i_pstStHYLogFifo);

				IF iRtn<>0 THEN
					IF aiRetryCount[iGroupId]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iGroupId]:= aiRetryCount[iGroupId]+1;
					END_IF
				ELSE
					aiRetryCount[iGroupId]:= 0;
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTION_STEP_Nothing;
				END_IF	
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.axis_ctrl := 2;		
			MOTIONCTL_STEP_SETMOTIONMODE:
				iRtn := KS_SetMotionMode_GantryTrap(
					i_iAxisId:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId, 
					i_iGroupId:= i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId, 
					i_iStationId:= i_pastStMotorParam_GantryTrap^[iGroupId].iStationId, 
					i_iAxisSlaver:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver,
					i_iAxisMasterVirtual:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual, 
					i_diSyncErrorLimit:= i_pastStMotorParam_GantryTrap^[iGroupId].diSyncErrorLimit, 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iGroupId]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iGroupId]:= aiRetryCount[iGroupId]+1;
					END_IF
				ELSE
					aiRetryCount[iGroupId]:= 0;
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_CLRSTS;
				END_IF				
			MOTIONCTL_STEP_CLRSTS:
				iRtn:= KS_SetMotionClrSts_GantryTrap(
					i_iAxisId:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId, 
					i_iGroupId:= i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId, 
					i_iStationId:= i_pastStMotorParam_GantryTrap^[iGroupId].iStationId, 
					i_iAxisSlaver:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver,
					i_iAxisMasterVirtual:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual,
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iGroupId]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iGroupId]:= aiRetryCount[iGroupId]+1;
					END_IF
				ELSE
					aiRetryCount[iGroupId]:= 0;
					//龙门点位不清位置，直接上伺服
					//i_pastStMotorParam_GantryTrap^[iN].iMoveStep:= MOTIONCTL_STEP_ZEROPOS;
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_AXISON;
				END_IF
(*
			MOTIONCTL_STEP_ZEROPOS:	
				iRtn:= KS_SetMotionZeroPos(
					i_iAxisId:= i_pastStMotorParam_GantryTrap^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_GantryTrap^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_GantryTrap^[iN].iStationId, 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_GantryTrap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_GantryTrap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISON;
				END_IF
*)			
			MOTIONCTL_STEP_AXISON:
				iRtn:= KS_SetMotionServoOn_GantryTrap(
					i_iAxisId:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId, 
					i_iGroupId:= i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId, 
					i_iStationId:= i_pastStMotorParam_GantryTrap^[iGroupId].iStationId, 
					i_iAxisSlaver:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver,
					i_iAxisMasterVirtual:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual,
					i_pxMoveEn := ADR(i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn),
					i_pxServoOn := ADR(axServoOn[iGroupId]),
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iGroupId]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iGroupId]:= aiRetryCount[iGroupId]+1;
					END_IF
				ELSE
					aiRetryCount[iGroupId]:= 0;
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_WaitingModalChanged;
				END_IF
			MOTIONCTL_STEP_WaitingModalChanged:
				aiWaitingModalChange[iGroupId] := aiWaitingModalChange[iGroupId] + 1;
				IF aiWaitingModalChange[iGroupId] > 50 THEN
					aiWaitingModalChange[iGroupId] := 0;
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_CHECKAXISON;
				END_IF			
			MOTIONCTL_STEP_CHECKAXISON:
				iRtn:= KS_SetMotionCheckServoOn_GantryTrap(
					i_iAxisId:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId, 
					i_iGroupId:= i_pastStMotorParam_GantryTrap^[iGroupId].iGroupId, 
					i_iStationId:= i_pastStMotorParam_GantryTrap^[iGroupId].iStationId, 
					i_iAxisSlaver:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver,
					i_iAxisMasterVirtual:= i_pastStMotorParam_GantryTrap^[iGroupId].iAxisMasterVirtual,
					i_pxMoveEn := ADR(i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn),
					i_pxServoOn := ADR(axServoOn[iGroupId]),
					i_dwMotionSts:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) + i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId].dwMotionSts, 
					i_dwDriverSts:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) +i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId].dwDriverSts,
					i_dwMotionSts_Slaver:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) +i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver].dwMotionSts, 
					i_dwDriverSts_Slaver:= i_pastStGetMotionSts^[gc_ResCount_Profile*(i_pastStMotorParam_GantryTrap^[iGroupId].iCoreId - 1) +i_pastStMotorParam_GantryTrap^[iGroupId].iAxisSlaver].dwDriverSts,
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iGroupId]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						axServoOn[iGroupId] := FALSE;
					ELSE
						aiRetryCount[iGroupId]:= aiRetryCount[iGroupId]+1;
					END_IF
				ELSE
					aiRetryCount[iGroupId]:= 0;
					i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep:= MOTIONCTL_STEP_WRITEDATA_Run;
				END_IF		
			MOTIONCTL_STEP_WRITEDATA_Run:
				IF i_pastStMotorParam_GantryTrap^[iGroupId].xMoveEn THEN
					i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.axis_ctrl := 3;
				ELSE
					i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.axis_ctrl := 2;
				END_IF
				
				IF i_pastStMotorParam_GantryTrap^[iGroupId].diMax_Vel = 0 THEN
					i_pastStMotorParam_GantryTrap^[iGroupId].diMax_Vel := 1;
				END_IF
				
				i_pastStSetPrm^[iGroupId].profileMode := 4;                     
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.axis_id := INT_TO_UINT(i_pastStMotorParam_GantryTrap^[iGroupId].iAxisId);          
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.axis_mode:=4;            
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.reserve:=0;            
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.target_pos:=i_pastStMotorParam_GantryTrap^[iGroupId].liTarget_Pos_All;
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.max_vel:=DINT_TO_UDINT(i_pastStMotorParam_GantryTrap^[iGroupId].diMax_Vel);      
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.main_axis_shift:= i_pastStMotorParam_GantryTrap^[iGroupId].diMain_Axis_Shift;   
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.second_axis_shift:= i_pastStMotorParam_GantryTrap^[iGroupId].diSecond_Axis_Shift; 
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.reserve2[1]:=0;        
				i_pastStSetPrm^[iGroupId].prm.gantrayTrapPrm.reserve2[2]:=0;
			END_CASE
		END_FOR 
		
		fbKS_FB_McMultiFunCtl_GantryTrap(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpGantryTrapGroup_Num:= i_iGrpGantryTrapGroup_Num, 
			i_iGrpGantryTrapMotion_Num:= i_iGrpGantryTrapMotion_Num, 
			i_aiGrpGantryTrapMotion_StdList:= i_aiGrpGantryTrapMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_pastStSetPrm:= i_pastStSetPrm, 
			i_pastStGetMotionSts:= i_pastStGetMotionSts, 
			i_pastStMotorParam_GantryTrap:= i_pastStMotorParam_GantryTrap, 
			i_pstStHYLogFifo:= i_pstStHYLogFifo
			);	
	ELSE;
	END_IF
ELSE
	;
END_IF
// 
// 	iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:= 113, encoder:= 1, pPos:= ADR(lrPos1));
// 	iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:= 129, encoder:= 1, pPos:= ADR(lrPos2));