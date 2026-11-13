(*@CES
Name=KS_FB_MotionCtl_Trap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=91bb1670-7a0e-427e-a57a-b27b647b87fa
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_MotionCtl_Trap
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpTrapMotion_Num: INT;
	i_aiGrpTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStSetPrm					:POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pastStMotorParam_Trap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Trap;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf : POINTER TO StSysGantryAxisInf;
	
	i_xHorManuCtrl:BOOL;(*界面横向手动修正功能*)
	i_pastStAxisRapidAdjProf_H				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;(*纵向快速对版|*)
	
	i_paxLimit_Left_Wr 						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
 	i_paxLimit_Right_Wr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxLimit_Left_WrClr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
 	i_paxLimit_Right_WrClr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_pastStAxisIdListInf 			:POINTER TO ARRAY [1..128] OF StAxisIdListInf;
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
	xFlag_AllInchRun_ing: BOOL;
	iMotionModePrn : INT;//版辊运动模式
						//0、电子齿轮
						//1、点位 --恢复相位等
						//2、Jog模式
	astStTStGearParam: ARRAY [1..MAX_STATION_NUM] OF TStGearParam;
	fbKS_FB_SyncAxisParam_Trap : KS_FB_SyncAxisParam_Trap;
	xKeepServo: BOOL;//保持伺服标志
		
	afbTRIG_Start_Servo: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	afbTRIG_Stop_Servo: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	axServoOn: ARRAY [1..MAX_STATION_NUM] OF BOOL;
	
	iN: INT;	
	
	iRtn_McMulFun : INT ;
	iRtn_McMulFun_Pre : INT ;
	sTMultiMcFunctionReadPrm : TMultiMcFunctionReadPrm;
	alrVarValue : ARRAY [1..80] OF LREAL;	
	
	//2026.01.28.173520 | + | 横向伺服控制
	fbKS_FB_AxisPosCtl_Trap : KS_FB_AxisPosCtl_Trap;
	alrTarp_EncPos						: ARRAY [1..MAX_UNIT_NUM] OF LREAL;//横向点位轴的编码器位置
	
	aiWaitingModalChange : ARRAY [1..MAX_STATION_NUM] OF INT;
	
	
	//2026.04.02.91845 新增
	
	iUnitId: INT;
	iTypeId: INT;
	iCoreId: INT;
	iAxisId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
END_VAR


{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam<>0 AND i_pastStSetPrm <> 0 AND i_pastStGetMotionSts <> 0 AND
		i_pastStMotorParam_Trap <> 0 AND i_pstStHYLogFifo <> 0 AND i_pastStIOMap_Main_FE <> 0 AND i_pastStIOMap_Axis_FE <> 0 THEN			
(*这里作为同步使能、速度等参数*)
		
		fbKS_FB_SyncAxisParam_Trap(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpTrapMotion_Num:= i_iGrpTrapMotion_Num, 
			i_aiGrpTrapMotion_StdList:= i_aiGrpTrapMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStMotorParam_Trap := i_pastStMotorParam_Trap,
			i_pstStSysStationInf := i_pstStSysStationInf,
			i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
			i_pastStGetMotionSts := i_pastStGetMotionSts,
			i_palrTarp_EncPos := ADR(alrTarp_EncPos)
		);
		
		fbKS_FB_AxisPosCtl_Trap(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpTrapMotion_Num:= i_iGrpTrapMotion_Num, 
			i_aiGrpTrapMotion_StdList:= i_aiGrpTrapMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStMotorParam_Trap:= i_pastStMotorParam_Trap, 
			i_xHorManuCtrl:= i_xHorManuCtrl, 
			i_alrTarp_EncPos:= alrTarp_EncPos, 
			i_pastStIOMap_AxisBasic:= i_pastStIOMap_Axis_FE, 
			i_pastStAxisRapidAdjProf_H:= i_pastStAxisRapidAdjProf_H,
			i_paxLimit_Left_Wr:= i_paxLimit_Left_Wr,
			i_paxLimit_Right_Wr:= i_paxLimit_Right_Wr,
			i_paxLimit_Left_WrClr:= i_paxLimit_Left_WrClr,
			i_paxLimit_Right_WrClr:= i_paxLimit_Right_WrClr,
			i_pastStGetMotionSts:=i_pastStGetMotionSts,
			i_pstStSysStationInf:=i_pstStSysStationInf,
			i_pstStSysGantryAxisInf :=i_pstStSysGantryAxisInf,
			i_pastStAxisIdListInf :=i_pastStAxisIdListInf,
);

		pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		FOR iN:=1 TO i_iGrpTrapMotion_Num BY 1 DO
			afbTRIG_Start_Servo[iN](CLK:= i_pastStMotorParam_Trap^[iN].xMoveEn);
			afbTRIG_Stop_Servo[iN](CLK:= NOT i_pastStMotorParam_Trap^[iN].xMoveEn);	
				
			IF afbTRIG_Start_Servo[iN].Q THEN
				IF i_pastStMotorParam_Trap^[iN].iMoveStep= MOTION_STEP_Nothing THEN
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
				ELSE;
				END_IF
			END_IF
			IF afbTRIG_Stop_Servo[iN].Q THEN
				IF i_pastStMotorParam_Trap^[iN].iMoveStep= MOTION_STEP_Nothing OR
					i_pastStMotorParam_Trap^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
					;
				ELSE
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
				END_IF
			END_IF	
			
			
			CASE i_pastStMotorParam_Trap^[iN].iMoveStep OF
			MOTION_STEP_Nothing:
				;
			MOTIONCTL_STEP_AXISOFF:
				iRtn:= KS_SetMotionServoOff(
					i_iAxisId:= i_pastStMotorParam_Trap^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Trap^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Trap^[iN].iStationId, 
					i_xForceAxisOff:= FALSE, 
					i_dwMotionSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Trap^[iN].iAxisId].dwMotionSts, 
					i_dwDriverSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Trap^[iN].iAxisId].dwDriverSts, 
					i_pxServoOn:= ADR(axServoOn[iN]), 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);

				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTION_STEP_Nothing;
				END_IF	

				//2025.10.27.164954 | bai.zy | 
				i_pastStSetPrm^[i_pastStMotorParam_Trap^[iN].iAxisId].prm.trapPrm.axis_ctrl:= 2;							
			MOTIONCTL_STEP_SETMOTIONMODE:
				iRtn:= KS_SetMotionMode(
					i_iAxisId:= i_pastStMotorParam_Trap^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Trap^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Trap^[iN].iStationId, 
					i_iMoveMode:= 2, 
					i_iAxisId_Master:= 64, 
					i_xMasterType := FALSE,
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_CLRSTS;
				END_IF				
			MOTIONCTL_STEP_CLRSTS:
				iRtn:= KS_SetMotionClrSts(
					i_iAxisId:= i_pastStMotorParam_Trap^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Trap^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Trap^[iN].iStationId, 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISON;
				END_IF		
			MOTIONCTL_STEP_AXISON:
				iRtn:= KS_SetMotionServoOn(
					i_iAxisId:= i_pastStMotorParam_Trap^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Trap^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Trap^[iN].iStationId, 
					i_pxMoveEn := ADR(i_pastStMotorParam_Trap^[iN].xMoveEn),
					i_pxServoOn:= ADR(axServoOn[iN]), 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_WaitingModalChanged;
				END_IF

			MOTIONCTL_STEP_WaitingModalChanged:
				aiWaitingModalChange[iN] := aiWaitingModalChange[iN] + 1;
				IF aiWaitingModalChange[iN] > 50 THEN
					aiWaitingModalChange[iN] := 0;
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_CHECKAXISON;
				END_IF			
			MOTIONCTL_STEP_CHECKAXISON:
				iRtn:= KS_SetMotionCheckServoOn(
					i_iAxisId:= i_pastStMotorParam_Trap^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Trap^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Trap^[iN].iStationId, 
					i_pxMoveEn := ADR(i_pastStMotorParam_Trap^[iN].xMoveEn),
					i_dwMotionSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Trap^[iN].iAxisId].dwMotionSts, 
					i_dwDriverSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Trap^[iN].iAxisId].dwDriverSts, 
					i_pxServoOn:= ADR(axServoOn[iN]),
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						axServoOn[iN] := FALSE;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Trap^[iN].iMoveStep:= MOTIONCTL_STEP_WRITEDATA_Run;
				END_IF
			MOTIONCTL_STEP_WRITEDATA_Run:
				i_pastStSetPrm^[iN].profileMode := 1;
				i_pastStSetPrm^[iN].prm.trapPrm.axis_ctrl:= 3;
				i_pastStSetPrm^[iN].prm.trapPrm.axis_id:= INT_TO_UINT(i_pastStMotorParam_Trap^[iN].iAxisId);
				i_pastStSetPrm^[iN].prm.trapPrm.axis_mode:= 1;
				i_pastStSetPrm^[iN].prm.trapPrm.reserve:= 0;
				i_pastStSetPrm^[iN].prm.trapPrm.reserve2[1]:= 0;
				i_pastStSetPrm^[iN].prm.trapPrm.reserve2[2]:= 0;
				i_pastStSetPrm^[iN].prm.trapPrm.target_pos:= i_pastStMotorParam_Trap^[iN].liTargetPos;
				i_pastStSetPrm^[iN].prm.trapPrm.max_vel:= i_pastStMotorParam_Trap^[iN].udiTargetVel;
			END_CASE
		END_FOR 
				
		(*2.大指令写*)
		sTMultiMcFunctionReadPrm.readCommandVarTableIndex := 1;
		sTMultiMcFunctionReadPrm.readCount := 0;
		sTMultiMcFunctionReadPrm.pVarValue := ADR(alrVarValue);
		dwRtn:= SysMemCmp(i_pastStSetPrm,ADR(astStSetPrm_Pre),SIZEOF(astStSetPrm_Pre));
		IF dwRtn<>0 THEN
			iRtn_McMulFun:=GTN_StartMcMultiFunction(1,INT_TO_UINT(i_iGrpTrapMotion_Num),1,i_pastStSetPrm,ADR(sTMultiMcFunctionReadPrm));
			IF iRtn_McMulFun <> 0 AND iRtn_McMulFun_Pre <> iRtn_McMulFun THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'GTN_StartMcMultiFunction Trap Err!', INT_TO_STRING(iRtn_McMulFun));
			END_IF
			iRtn_McMulFun_Pre := iRtn_McMulFun;
		END_IF
		SysMemCpy(ADR(astStSetPrm_Pre),i_pastStSetPrm,SIZEOF(i_pastStSetPrm^));
		
		//2026.04.02.92001 新增拿横向编码器 Hou.N
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
					g_alrTrap_EncPos[iUnitId]	:= i_pastStGetMotionSts^[iAxisId].lrPos_Enc;
					g_arTrapPos_mm[iUnitId]:=	g_alrTrap_EncPos[iUnitId]*
												i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_Horz*
												UINT_TO_REAL(i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_Horz)
												/GC_LRMOTORPPR_TRAP/UINT_TO_REAL(i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_Horz);
				END_IF		
			END_FOR
			
	ELSE;
	END_IF
ELSE
	;
END_IF