(*@CES
Name=KS_FB_Act_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=72c8476a-c306-4b90-a2c1-f4f2ee9240ad
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Act_GantryTrap
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_pstStSysParam: POINTER TO StSysParam;(* 系统参数地址 *)	
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpGantryTrapGroup_Num: INT;
	i_iGrpGantryTrapMotion_Num: INT;
	i_aiGrpGantryTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_xFlag_Stop: BOOL;//停机状态
	i_xFlag_Estop: BOOL;
	i_xDebugMode: BOOL;//调试模式
	i_axFlag_Alarm_Pressure: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	//某色压力报警
	i_pastStTrapAxisParam_Gantray : POINTER TO ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF StTrapAxisParam_Gantray;	
	i_xStopOrEstop_Valid:BOOL;//停机离压信号
	i_byCycle_PrnRoller_MoveUp: BYTE;//停机离压版辊延时圈数
	i_ReqResetEstop: BOOL;//急停复位
	
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStMotorParam_GantryTrap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
	
	i_pastStHandWheel: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StHandWheel;
	i_pastStHandWheel_BtnCtl: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StHandWheel_BtnCtl;
	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf 		:POINTER TO StSysGantryAxisInf;
	//2026.02.07.152127 新加步进量
	i_rStep_HMI_Use: REAL;
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
	o_arVel_Prn: ARRAY [1..MAX_UNIT_NUM] OF REAL;//运行速度
	o_arVel_Net: ARRAY [1..MAX_UNIT_NUM] OF REAL;//运行速度
	o_alrTargetPos_Prn:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	o_alrTargetPos_Prn_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	o_alrTargetPos_Prn_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	o_alrTargetPos_Net:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	o_alrTargetPos_Net_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	o_alrTargetPos_Net_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;	
	
END_VAR
VAR
	iN: INT;
	iM: INT;
	iRtn : INT;
	iUnitId: INT;
	abyUnitId_Ctl: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	axNeedZeroPos: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axFlag_Mode_Calid: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//手持器标定标值
	axFlag_LockHandwheel: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//手持器锁定标值
	axFlag_Ctl_Prn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xFlag_Alarm_Pressure: BOOL;//至少一个压力电机报警
	sTemp: STRING;
	xTemp: BOOL;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;	
	afbRTrig_HmiBtn_New:ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM,0..15] OF R_TRIG;
	axMoveForward_New:ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM,1..2] OF BOOL;(*前进标志|靠近底辊*)	
	axMoveReversal_New:ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM,1..2] OF BOOL;(*后退标志|远离底辊*)	
	axRollerMoveForward_New:ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM,1..2] OF BOOL;(*前进标志|靠近底辊-1:版辊	*)
	axRollerMoveReversal_New:ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM,1..2] OF BOOL;(*后退标志|远离底辊-1:版辊	*)	
 	axFlag_Move_For_Long: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;	
 	axFlag_Move_Rev_Long: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;
	afKS_FB_CalcuHypotenuse:ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CalcuHypotenuse;
	afKS_FB_CalcuDisplayT_M:ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CalcuDisplayT;
	afKS_FB_CalcuDisplayT_G:ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CalcuDisplayT;
	
	afKS_FB_CalcustepPr:ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CalcuHypotenuse;
	afKS_FB_CalcustepNr:ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CalcuHypotenuse;
	afbKS_FB_GantryTrap_Calc_TargetPos_Prn: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_GantryTrap_Calc_TargetPos;
	afbKS_FB_GantryTrap_Calc_TargetPos_Net: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_GantryTrap_Calc_TargetPos;
	alrTargetPos_Prn:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Prn_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Prn_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Net:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Net_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Net_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Str:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Str_M:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTargetPos_Str_G:   ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	afbTRIG_Move_To_Tar: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM,1..3] OF R_TRIG; 
	abySts_HandWheel: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BYTE;

	axTRIG_Confirm_load_unload: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF R_TRIG;
	axTRIG_Confirm_PressUp: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF R_TRIG;
	axTRIG_Confirm_PressDn: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF R_TRIG;	
	
	axMoveEn_Prn_M:  ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axMoveEn_Prn_G:  ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axMoveEn_Net_M:  ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axMoveEn_Net_G:  ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axMoveEn_Str_M:  ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axMoveEn_Str_G:  ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axConfirm_Adjust_PressDn:  ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;		
	xNeedMoveUp_Stop_Prn: BOOL;
	xNeedMoveUp_Stop_Prn_Finished: BOOL;
	xNeedMoveUp_Stop_Net: BOOL;
	xNeedMoveUp_Stop_Net_Finished: BOOL;
	xNeedMoveUp_Stop_Str: BOOL;
	iMoveUp_Stop_Cnt: INT;
	xMoveUp_Stop_Delay:BOOL;
	rTemp: REAL;
	rTemp_RunLength: REAL;
	dwTemp: DWORD;
	//fbKS_FB_Avoidance_Ctl: KS_FB_Avoidance_Ctl;
	//fbKS_FB_Avoidance_Prn_Ctl: KS_FB_Avoidance_Prn_Ctl;
	//fbKS_FB_Avoidance_Net_Ctl: KS_FB_Avoidance_Net_Ctl;(*网辊避让功能*)
	afbTRIG_Avoidance_MoveUp: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbTRIG_Avoidance_MoveDn: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	(*2023.12.17.132937||xi.hy||网辊避让时的合压离压*)
	afbTRIG_Avoidance_MoveUp_Net: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbTRIG_Avoidance_MoveDn_Net: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	fbTRIG_Avoidance_Ctl: r_trig;
	afbTRIG_Ink_Unit: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	axInk_Unit : ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	iCnt_Test_Move: INT;
	iCnt_:INT;
	xMoveEN:BOOL;
	axAutoConfirm_Adjust_PressDn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	fb_AutoConfirm_Pos_Dn: R_TRIG;
	lrposConfirm_Dn_Press_Temp_M:LREAL;//合压位标定；
	lrposConfirm_Up_Press_Temp_M:LREAL;//离压位标定；
	lrposConfirm_Load_Unload_Press_Temp_M:LREAL;//换版位标定；
	lrposConfirm_Dn_Press_Temp_G:LREAL;//合压位标定；
	lrposConfirm_Up_Press_Temp_G:LREAL;//离压位标定；
	lrposConfirm_Load_Unload_Press_Temp_G:LREAL;//换版位标定；		
	lrTemp:LREAL;
	
	iLenHandDisplay2_HMI : INT;
	iBlankNumHandDisplay2_HMI : INT;
	iCountAddBlankNum : INT;
	rGirth_PrnRoller_Mem : REAL;
	
	alrCenterDistance_Min : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrCenterDistance_InFact : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrHeight_InFact : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrHeight_Err : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	aiHetght_ErrCalCycle : ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiHeight_ErrCalCnt : ARRAY [1..MAX_UNIT_NUM] OF INT;
	axFinishConfirm_Adjust_PressDn : ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	
	axTRIG_ResetFlag_FinishCalid: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	
	aitargetStation : ARRAY [1..MAX_STATION_NUM] OF INT;//压力电机站列表
	aliABSEncPos : ARRAY [1..MAX_STATION_NUM] OF LINT;//零位绝对编码器位置
	
	rD1 : REAL;	
	rD2 : REAL;
	rD3 : REAL;
	rR1 : REAL;
	rR2 : REAL;
	rA1 : REAL;
	rA2 : REAL;
	rA3 : REAL;
	rA4 : REAL;
	rLen : REAL;
	
	alrDnToCurEncOffset_M : ARRAY[1..MAX_UNIT_NUM] OF LREAL;
	alrDnToCurEncOffset_G : ARRAY[1..MAX_UNIT_NUM] OF LREAL;
	alrHeightOffset_M : ARRAY[1..MAX_UNIT_NUM] OF LREAL;
	alrHeightOffset_G : ARRAY[1..MAX_UNIT_NUM] OF LREAL;
	
	
	arAdjustDistance_Str : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	
	
	axFlag_PressDebugModeFor  : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;
	axFlag_PressDebugModeRev  : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;
	axFlag_PressDebugModeForing  : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;
	axFlag_PressDebugModeReving  : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;
	aiCount_Debug_Move_Tol : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF INT;
	aiCount_Debug_Move : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF INT;
	iCount_Debug_Move_Time : INT := 4500;
	
	//手持器开关
	axEn_HandWheel: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	aiCountNeetStop : ARRAY [1..MAX_UNIT_NUM] OF INT;
	
// 	rDistanceForAvoidPrnGear : REAL := 10;
// 	lrDistanceForAvoidPrnGear : LREAL;
// 	lrTemp_100um_pos:LREAL:=167772;
// 	iTemp : INT;
	
	alrTemp_Len_Up_Pos_Prn : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTemp_Len_Load_Unload_Pos_Prn : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTemp_Len_Up_Pos_Net : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrTemp_Len_Load_Unload_Pos_Net : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	
	axAdjust_Auto_V : ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axAdjust_Auto_H : ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	
	axConfirmPressPosFromSlave : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;
	aiConfirmPressPosFromSlave_Count : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF INT;
	
	axAcc_UnitId : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	iAxisId : INT;
	iTypeId : INT;
	iCoreId : INT;
	iGroupId : INT;
	
	iAxisId_M : INT;
	iAxisId_G : INT;
	
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	iAdjAxisId : INT;
	
	fbKS_FB_HandWheelRd : KS_FB_HandWheelRd;
	fbKS_FB_HandWheelRd_Wr : KS_FB_HandWheelRd_Wr;
	fbKS_FB_HandwheelCtl: KS_FB_HandWheelCtl;
	
	cnt:int;

	lrAbsPos_M : LREAL;
	lrAbsPos_G : LREAL;
	xtest: BOOL;
	
	
	alrAbsPos : ARRAY [1..MAX_STATION_NUM] OF LREAL;
	lrAbsPos1 : LREAL;
	lrAbsPos2 : LREAL;
	lrAbsPos3 : LREAL;
	lrAbsPos4 : LREAL;
	lrAbsPos5 : LREAL;
	lrAbsPos6 : LREAL;
	lrAbsPos7 : LREAL;
	lrAbsPos8 : LREAL;
	
	axAxisRev: ARRAY [1..MAX_STATION_NUM] OF BOOL;
	xTest1: BOOL;
	rStep_HMI_Use_Prn: REAL;
		//2026.02.08.135719 | + | 步进量处理
	arProportion : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	afKS_FB_CalcuHypotenuse_V2:ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CalcuHypotenuse_V2;
	ax_PreInflatable: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	aiTempCnt : ARRAY [1..MAX_UNIT_NUM] OF INT;
	axTemp1: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	afKS_FB_CacuHypotenuse_V3:ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CacuHypotenuse_V3;
	rPosdiff_Dnpress:REAL;
	lrTemp1:REAL;	
	rFilmdiff:REAL;
	afKS_FB_CalcuHypotenuse_FilmThick :ARRAY [1..MAX_UNIT_NUM] OF KS_FB_CalcuHypotenuse_V2;
	rFilmThickdiff:REAL;
	rProportion1:REAL;
	
//处理开机自动合压问题2026.4.9.221523	
	afbTRIG_AutoPress_Run: ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF R_TRIG;
	xtest3:BOOL;
	xtest2:BOOL:=FALSE;
	xtest4:BOOL;
	fbTRIG_ResetEstop:R_TRIG;
	
	rMaxErr : REAL := 3.0;




END_VAR 





{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN	(* 启动 *)
	IF i_pstStSysParam <> 0 AND i_pastStGetMotionSts <> 0 AND i_pastStTrapAxisParam_Gantray <>0 AND
		i_pastStAxisIdListInf <> 0 AND i_pastStMotorParam_GantryTrap <> 0 AND i_pastStHandWheel <> 0 AND
		i_pastStHandWheel_BtnCtl <> 0 AND i_pstStSysStationInf <> 0 AND i_pstStSysGantryAxisInf <> 0 THEN
		;
	ELSE
		RETURN;
	END_IF

	pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
	pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
//	wCtl_Pressure_Up_Dn							: WORD;	
												(*
												bit0：自动合压-进入印刷状态后自动合压
												bit1：急停直接离压/FALSE急停不动作，复位离压
												bit2：裁切避让胶带使能
												bit3：裁切避让胶带外触发标志/内触发需要计算裁切切点到1色料长
											*)	
				
	FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
		axEn_HandWheel[iN] := i_pstStSysParam^.astStUnitParam_Save[iN].wFlag_PressFun.0;
		axAdjust_Auto_V[iN] := i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_sts.0;
		axAdjust_Auto_H[iN] := i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_sts.1;
	END_FOR
axEn_HandWheel[1] := TRUE;
							
	//1.手轮处理
	fbKS_FB_HandWheelRd(i_xEn:= TRUE, i_pastStHandWheel:= i_pastStHandWheel);
	fbKS_FB_HandWheelRd_Wr(i_xEn:= TRUE, i_pastStHandWheel:= i_pastStHandWheel);										
	fbKS_FB_HandwheelCtl(
		i_xEn:= TRUE, 
		i_byUnitNumMax:= INT_TO_BYTE(i_iGrpUnitNum_Pu), 
		i_pastStHandWheel:= i_pastStHandWheel, 
		i_pastStHandWheel_BtnCtl:= i_pastStHandWheel_BtnCtl, 
		i_pabyUnitId_Ctl:= ADR(abyUnitId_Ctl), 
		i_xFlag_Stop:= pstStGrpParam_UnSave^.xFlag_Stop, 
		i_xDebugMode:= pstStGrpParam_UnSave^.xIsDebugMode_Machine, 
		i_paxNeedZeroPos:= ADR(axNeedZeroPos), 
		i_paxFlag_Mode_Calid:= ADR(axFlag_Mode_Calid), 
		i_paxFlag_LockHandwheel:= ADR(axFlag_LockHandwheel), 
		i_paxEn_HandWheel := ADR(axEn_HandWheel),
		i_paxAdjust_Auto_V := ADR(axAdjust_Auto_V),
		i_paxAdjust_Auto_H := ADR(axAdjust_Auto_H),
		i_paxAcc_UnitId:=ADR(axAcc_UnitId));							
	
		
	IF axNeedZeroPos[1] THEN
		GT_RN_SetHandPos(0);
		axNeedZeroPos[1]:= FALSE;
	END_IF
	FOR iN:=2 TO i_iGrpUnitNum_Pu BY 1 DO
		IF axNeedZeroPos[iN] THEN
			i_pastStHandWheel^[iN].byCtlSts_HandWheel.6:= TRUE;
			axNeedZeroPos[iN]:= FALSE;
		END_IF
	END_FOR	
		
	xFlag_Alarm_Pressure:= FALSE;
	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
		IF i_axFlag_Alarm_Pressure[iN] THEN
			xFlag_Alarm_Pressure:= TRUE;
			EXIT;			
		END_IF		
	END_FOR
	
	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
//		FOR iN:=1 TO i_byHandWheel_Num BY 1 DO
		IF NOT axAcc_UnitId[iN] THEN//正常使用过程中显示
			i_pastStHandWheel^[iN].byCtlSts_HandWheel.7:= FALSE;
			IF axFlag_LockHandwheel[iN] THEN
				sTemp := 'KESAI';
				sTemp:= CONCAT(sTemp,g_sHandConnectedSignal);
				sTemp:= CONCAT(sTemp,'LOCK');
				i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1]:=sTemp;
				//i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1]:= 'KESAI  LOCK';
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.0:= TRUE;
			ELSIF axFlag_Mode_Calid[abyUnitId_Ctl[iN]] THEN
				sTemp := 'KESAI';
				sTemp:= CONCAT(sTemp,g_sHandConnectedSignal);
				sTemp:= CONCAT(sTemp,'DEBUG');
				i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1]:=sTemp;
				//i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1]:= 'KESAI DEBUG';	
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.0:= FALSE;
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.1:= FALSE;
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.2:= TRUE;
				
			ELSE
				sTemp := 'KESAI';
				sTemp:= CONCAT(sTemp,g_sHandConnectedSignal);
				i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1]:=sTemp;
				//i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1]:= 'KESAI';		
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.0:= FALSE;
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.1:= TRUE;		
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.2:= FALSE;
			END_IF
			sTemp:= BYTE_TO_STRING(abyUnitId_Ctl[iN]);
			i_pastStHandWheel^[iN].byCtlId_HandWheel:=abyUnitId_Ctl[iN];
	(*			IF NOT axFlag_Ctl_Prn[abyUnitId_Ctl[iN]] THEN
				sTemp:= CONCAT(sTemp,'U ');
				sTemp:= CONCAT(sTemp,'W-A');
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.5:= FALSE;
			ELSE	
				sTemp:= CONCAT(sTemp,'U ');
				sTemp:= CONCAT(sTemp,'B-A');		
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.5:= TRUE;					
			END_IF
	*)			
			IF i_pastStHandWheel^[iN].byKnob_Left = 18 THEN
				sTemp:= CONCAT(sTemp,'U ');
				sTemp:= CONCAT(sTemp,'B-A');
			ELSIF i_pastStHandWheel^[iN].byKnob_Left = 19 THEN
				sTemp:= CONCAT(sTemp,'U ');
				sTemp:= CONCAT(sTemp,'W-A');
			ELSIF i_pastStHandWheel^[iN].byKnob_Left = 20 THEN
				sTemp:= CONCAT(sTemp,'U ');
				sTemp:= CONCAT(sTemp,'S-A');
			END_IF
			i_pastStHandWheel^[iN].byCtlSts_HandWheel.3:= FALSE;		
			i_pastStHandWheel^[iN].byCtlSts_HandWheel.4:= FALSE;
			IF xFlag_Alarm_Pressure THEN
				sTemp:= CONCAT(sTemp,'  Alarm');			
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.4:= TRUE;
			ELSIF i_xFlag_Estop THEN
				sTemp:= CONCAT(sTemp,'  Estop');	
				i_pastStHandWheel^[iN].byCtlSts_HandWheel.3:= TRUE;						
			END_IF
			IF abyUnitId_Ctl[iN]=0 THEN abyUnitId_Ctl[iN]:=1; END_IF
			i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[2]:= sTemp;
			sTemp:= 'M:';
			sTemp:= CONCAT(sTemp,REAL_TO_STRING(LINT_TO_REAL(REAL_TO_LINT(i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_PrnRoller_Pressure_M*100))/100));
			sTemp:= CONCAT(sTemp,'G:');
			sTemp:= CONCAT(sTemp,REAL_TO_STRING(LINT_TO_REAL(REAL_TO_LINT(i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_PrnRoller_Pressure_G*100))/100));
	
			i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[3]:= sTemp;
			sTemp:= 'M:';
			sTemp:= CONCAT(sTemp,REAL_TO_STRING(LINT_TO_REAL(REAL_TO_LINT(i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_NetRoller_Pressure_M*100))/100));			
			sTemp:= CONCAT(sTemp,'G:');
			sTemp:= CONCAT(sTemp,REAL_TO_STRING(LINT_TO_REAL(REAL_TO_LINT(i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_NetRoller_Pressure_G*100))/100));			
			i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[4]:= sTemp;	
		ELSE//如果是要进行色组选择应该如何显示
			i_pastStHandWheel^[iN].byCtlSts_HandWheel.7:= TRUE;
			sTemp := 'KESAI';
			sTemp:= CONCAT(sTemp,g_sHandConnectedSignal);
			i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[1]:=sTemp;
			
			IF abyUnitId_Ctl[iN]=0 THEN abyUnitId_Ctl[iN]:=1; END_IF
			IF abyUnitId_Ctl[iN]+1 > i_iGrpUnitNum_Pu THEN 
				abyUnitId_Ctl[iN]:=0; 
			END_IF
			sTemp:= BYTE_TO_STRING(abyUnitId_Ctl[iN]+1);
			i_pastStHandWheel^[iN].byCtlId_HandWheel:=abyUnitId_Ctl[iN];
			sTemp := CONCAT(sTemp,'U');
			sTemp := CONCAT(sTemp,' ');
			sTemp := CONCAT(sTemp,'ARE YOU SURE?');
			
			i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[2]:= sTemp;
			i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[3]:= sTemp;
			sTemp := 'F1:YES   F2:NO';
			i_pastStHandWheel^[iN].asDisplay_HardWheel_HMI[4]:= sTemp;	
		END_IF
		
		i_pastStHandWheel^[iN].arPos_HandWheel[1]:= i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_PrnRoller_Pressure_M;
		i_pastStHandWheel^[iN].arPos_HandWheel[2]:= i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_PrnRoller_Pressure_G;
		i_pastStHandWheel^[iN].arPos_HandWheel[3]:= i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_NetRoller_Pressure_M;
		i_pastStHandWheel^[iN].arPos_HandWheel[4]:= i_pstStSysParam^.astStUnitParam_Unsave[abyUnitId_Ctl[iN]].rPos_NetRoller_Pressure_G;
	END_FOR	
	
//2.填值2023.11.3.113943-版辊2023.11.3.114025	
	FOR iN:=1 TO i_iGrpGantryTrapMotion_Num BY 1 DO
// 		KS_HY_GetAxisIdForMotByStation(
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
		
		IF iTypeId=TYPE_UNIT_PRN_PRESS_MASTER THEN				
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].lrPos_CurPos_Prf:= 		
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Prf;//龙门规划位置
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].lrPos_CurPos_Prf_M:= 		
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAdjAxisId].lrPos_Prf;//主轴规划位置	

			i_pastStTrapAxisParam_Gantray^[1,iUnitId].xRev_Motor_M:= 	
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_M;	
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].lrPos_CurPos_Enc_M:= 
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Enc;//编码器位置
			dwTemp:= LREAL_TO_DWORD(i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].dwMotionSts);
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].xAxisPrfStop_M:= //规划器停止
				NOT dwTemp.10;
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].iStationId_M := i_aiGrpGantryTrapMotion_StdList[iN];
		ELSIF iTypeId=TYPE_UNIT_PRN_PRESS_G THEN
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].lrPos_CurPos_Prf_G:= 		
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Prf;//龙门规划位置
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].xRev_Motor_G:= 	
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_G;
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].lrPos_CurPos_Enc_G:= 
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Enc;//编码器位置
			dwTemp:= LREAL_TO_DWORD(i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].dwMotionSts);
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].xAxisPrfStop_G:= //规划器停止
				NOT dwTemp.10;	
			i_pastStTrapAxisParam_Gantray^[1,iUnitId].iStationId_G := i_aiGrpGantryTrapMotion_StdList[iN];			
		ELSIF iTypeId=TYPE_UNIT_NET_PRESS_MASTER THEN 
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].lrPos_CurPos_Prf:= 		
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Prf;//龙门规划位置
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].lrPos_CurPos_Prf_M:= 		
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAdjAxisId].lrPos_Prf;;//主轴规划位置

			i_pastStTrapAxisParam_Gantray^[2,iUnitId].xRev_Motor_M:= 	
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_M;	
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].lrPos_CurPos_Enc_M:= 
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Enc;//编码器位置
			dwTemp:= LREAL_TO_DWORD(i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].dwMotionSts);
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].xAxisPrfStop_M:= //规划器停止
				NOT dwTemp.10;
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].iStationId_M :=i_aiGrpGantryTrapMotion_StdList[iN];				
		ELSIF iTypeId=TYPE_UNIT_NET_PRESS_G THEN 
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].lrPos_CurPos_Prf_G:= 		
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Prf;//龙门规划位置
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].xRev_Motor_G:= 	
				i_pastStMotorParam_GantryTrap^[iGroupId].xMoveRev_G;	
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].lrPos_CurPos_Enc_G:= 
				i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].lrPos_Enc;//编码器位置	
			dwTemp:= LREAL_TO_DWORD(i_pastStGetMotionSts^[(iCoreId-1)*gc_ResCount_Profile + iAxisId].dwMotionSts);
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].xAxisPrfStop_G:= //规划器停止
				NOT dwTemp.10;
			i_pastStTrapAxisParam_Gantray^[2,iUnitId].iStationId_G := i_aiGrpGantryTrapMotion_StdList[iN];	
		END_IF	
	END_FOR	
	
//2024.10.31.103150 | bai.zy | 全体动作操作之后10秒才能再次进行操作，解决压力电机连续按键之后会走多的问题
	//全体合压

	IF g_xPressUp_To_Dn AND (NOT g_axFirstMenu[1]) THEN
		g_xPressUp_To_Dn := TRUE;
		g_axFirstMenu[1] := TRUE;
	ELSE
		g_xPressUp_To_Dn := FALSE;
	END_IF
	//全体离压
	IF g_xPressDn_To_Up AND (NOT g_axFirstMenu[2]) THEN
		g_xPressDn_To_Up := TRUE;
		g_axFirstMenu[2] := TRUE;
	ELSE
		g_xPressDn_To_Up := FALSE;
	END_IF
	//全体退出
	IF g_xPressUp_To_Load AND (NOT g_axFirstMenu[3]) THEN
		g_xPressUp_To_Load := TRUE;
		g_axFirstMenu[3] := TRUE;
	ELSE
		g_xPressUp_To_Load := FALSE;
	END_IF
	//全体进入
	IF g_xPressLoad_To_Up AND (NOT g_axFirstMenu[4]) THEN
		g_xPressLoad_To_Up := TRUE;
		g_axFirstMenu[4] := TRUE;
	ELSE
		g_xPressLoad_To_Up := FALSE;
	END_IF
	//换版准备
	IF g_xPressMoveToLoad AND (NOT g_axFirstMenu[5]) THEN
		g_xPressMoveToLoad := TRUE;
		g_axFirstMenu[5] := TRUE;
	ELSE
		g_xPressMoveToLoad := FALSE;
	END_IF
	
	
	FOR iN := 1 TO 5 BY 1 DO
		IF g_axFirstMenu[iN] THEN
			g_awPressMenu[iN] := g_awPressMenu[iN] + 1;
			IF g_awPressMenu[iN] > 10*1000/gc_TENSION_TSK_CYCLE_TIME THEN
				g_awPressMenu[iN] := 0;
				g_axFirstMenu[iN] := FALSE;
			END_IF
		END_IF
	END_FOR
	
	
	FOR iN:= 1 TO i_iGrpUnitNum_Pu BY 1 DO
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);
		//bai.zy | 2024.03.21.103748 |压力电机全体动作
		FOR iM := 1 TO 3 BY 1 DO
			IF pstStUnitParam_Save^.xLinkage THEN
				IF g_xPressUp_To_Dn THEN
					pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].10 := TRUE;
				ELSIF g_xPressDn_To_Up THEN
					pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8 := TRUE;
				ELSIF g_xPressUp_To_Load THEN
					pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].9 := TRUE;
				ELSIF g_xPressLoad_To_Up THEN
					pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8 := TRUE;
				ELSIF g_xPressMoveToLoad THEN
					pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].9 := TRUE;
				END_IF
			END_IF
		END_FOR

		//2026.02.23.135116 //Hou.N //增加自动换版_品字形柔印机
		IF 	g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
			IF pstStUnitParam_Save^.xLinkage THEN
				IF pstStUnitParam_UnSave^.adwPressureMotor_Move[1].14 THEN
					pstStUnitParam_UnSave^.adwPressureMotor_Move[1].14:=FALSE;

					pstStUnitParam_UnSave^.adwPressureMotor_Move[1].9 := TRUE;

					ax_PreInflatable[iN]:=TRUE;
				END_IF 		
				pstStUnitParam_UnSave^.adwPressureMotor_Move[1].19:=i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_Load_Unload_Press_ing ;					








				IF ax_PreInflatable[iN] THEN
					IF i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_M = 0 AND  i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_G = 0  THEN

						pstStUnitParam_UnSave^.adwPressureMotor_Move[1].19:=FALSE;
						g_stStSysParam.astStUnitParam_Save[iN].wButtonAndSwitch_ChaoXu.2:=TRUE;		
						ax_PreInflatable[iN]:=FALSE;					
					END_IF						
				END_IF					
				IF  pstStUnitParam_UnSave^.adwPressureMotor_Move[1].15 THEN  //换版完成
					 pstStUnitParam_UnSave^.adwPressureMotor_Move[1].15:=FALSE;
					g_stStSysParam.astStUnitParam_Save[iN].wButtonAndSwitch_ChaoXu.2:=FALSE;
					pstStUnitParam_UnSave^.adwPressureMotor_Move[1].8 := TRUE; 
				END_IF		
			END_IF

		END_IF		
 	
		
//重新写各个电机的动作
		FOR iM := 1 TO gc_iMax_PressureRoller_Unit BY 1 DO
			afbRTrig_HmiBtn_New[iM,iN,1](CLK:=pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].0,Q=>axMoveForward_New[iM,iN,1]);(*操作侧前进*)
			afbRTrig_HmiBtn_New[iM,iN,2](CLK:=pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].1,Q=>axMoveReversal_New[iM,iN,1]);(*操作侧后退*)
			afbRTrig_HmiBtn_New[iM,iN,3](CLK:=pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].2,Q=>axMoveForward_New[iM,iN,2]);(*传动侧前进*)
			afbRTrig_HmiBtn_New[iM,iN,4](CLK:=pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].3,Q=>axMoveReversal_New[iM,iN,2]);(*传动侧后退*)
			afbRTrig_HmiBtn_New[iM,iN,5](CLK:=pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].4,Q=>axRollerMoveForward_New[iM,iN,1]);(*前进*)
			afbRTrig_HmiBtn_New[iM,iN,6](CLK:=pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].5,Q=>axRollerMoveReversal_New[iM,iN,1]);(*后退*)
			
			IF axRollerMoveForward_New[iM,iN,1] THEN
				xTest1:= TRUE;
			END_IF
			//使用结束后清除标志
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].0:=FALSE;
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].1:=FALSE;
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].2:=FALSE;
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].3:=FALSE;
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].4:=FALSE;
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].5:=FALSE;
			
			//处理龙门动作
			i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveFor_M:=axMoveForward_New[iM,iN,1];(*操作侧前进*)
			i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveRev_M:=axMoveReversal_New[iM,iN,1];(*操作侧后退*)
			i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveFor_G:=axMoveForward_New[iM,iN,2];(*传动侧前进*)
			i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveRev_G:=axMoveReversal_New[iM,iN,2];(*操作侧后退*)
			i_pastStTrapAxisParam_Gantray^[iM,iN].xRollerMoveFor:=axRollerMoveForward_New[iM,iN,1];(*前进*)
			i_pastStTrapAxisParam_Gantray^[iM,iN].xRollerMoveRev:=axRollerMoveReversal_New[iM,iN,1];(*后退*)
			
			IF  g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
				
				;
			ELSE
				IF iM = 2 THEN
					IF i_pastStTrapAxisParam_Gantray^[1,iN].xMoveFor_M THEN
						i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveFor_M := i_pastStTrapAxisParam_Gantray^[1,iN].xMoveFor_M;
					END_IF
					IF i_pastStTrapAxisParam_Gantray^[1,iN].xMoveRev_M THEN
						i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveRev_M := i_pastStTrapAxisParam_Gantray^[1,iN].xMoveRev_M;
					END_IF
					IF i_pastStTrapAxisParam_Gantray^[1,iN].xMoveFor_G THEN
						i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveFor_G:= i_pastStTrapAxisParam_Gantray^[1,iN].xMoveFor_G;
					END_IF
					IF i_pastStTrapAxisParam_Gantray^[1,iN].xMoveRev_G THEN
						i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveRev_G:= i_pastStTrapAxisParam_Gantray^[1,iN].xMoveRev_G;
					END_IF
					IF i_pastStTrapAxisParam_Gantray^[1,iN].xRollerMoveFor THEN
						i_pastStTrapAxisParam_Gantray^[iM,iN].xRollerMoveFor := i_pastStTrapAxisParam_Gantray^[1,iN].xRollerMoveFor;
					END_IF
					IF i_pastStTrapAxisParam_Gantray^[1,iN].xRollerMoveRev THEN
						i_pastStTrapAxisParam_Gantray^[iM,iN].xRollerMoveRev := i_pastStTrapAxisParam_Gantray^[1,iN].xRollerMoveRev;
					END_IF
				END_IF
			END_IF

			IF pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8 THEN
				xtest2:=TRUE;
			END_IF
			//离压合压前进后退
			afbTRIG_Move_To_Tar[iM,iN,2](CLK:= pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8 OR//前往离压位-
				(i_pastStHandWheel_BtnCtl^[iN].axReqPress_Up[iM] AND (NOT axFlag_Mode_Calid[iN])),
				Q=>i_pastStTrapAxisParam_Gantray^[iM,iN].xMove_To_PressUp);

//2026.4.9.221308开机自动合压逻辑异常|重新处理
afbTRIG_AutoPress_Run[iM,iN](CLK:= (pstStGrpParam_Save^.wCtl_Pressure_Up_Dn.0 AND pstStGrpParam_UnSave^.xFlag_Print AND 
							pstStUnitParam_Save^.xLinkage AND pstStGrpParam_UnSave^.rVel_Film > 0.5));
			afbTRIG_Move_To_Tar[iM,iN,1](CLK:= pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].10 OR//界面合压
				(i_pastStHandWheel_BtnCtl^[iN].axReqPress_Dn[iM] AND (NOT axFlag_Mode_Calid[iN])) OR //手轮合压
				afbTRIG_AutoPress_Run[iM,iN].Q,//开机自动合压
				Q=>i_pastStTrapAxisParam_Gantray^[iM,iN].xMove_To_PressDn);
				
			afbTRIG_Move_To_Tar[iM,iN,3](CLK:= pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].9 OR//前往换版位
				(i_pastStHandWheel_BtnCtl^[iN].axReqLoad_Unload[iM] AND (NOT axFlag_Mode_Calid[iN])),
				Q=>i_pastStTrapAxisParam_Gantray^[iM,iN].xMove_To_Load_Unload);
		
// 	IF i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_PressDn	THEN
// 		xtest2:=TRUE;
// 	END_IF	
// 		
// 	IF i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_PressDn	THEN
// 		xtest3:=TRUE;
// 	END_IF		
// 			IF pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8 OR  pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].9 THEN
// 				pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8 :=  pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8;
// 			END_IF
// 				
			//使用结束后清除标志
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].8:=FALSE;
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].9:=FALSE;
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].10:=FALSE;

			axTRIG_Confirm_load_unload[iM,iN](CLK:= i_pastStHandWheel_BtnCtl^[iN].axReq_Confirm_Load_Unload[iM] 
				OR pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].18);
			axTRIG_Confirm_PressUp[iM,iN](CLK:= i_pastStHandWheel_BtnCtl^[iN].axReq_Confirm_press_up[iM] 
				OR pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].17);
			axTRIG_Confirm_PressDn[iM,iN](CLK:= i_pastStHandWheel_BtnCtl^[iN].axReq_Confirm_press_dn[iM] 
				OR pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].16 OR g_axConfirm[iM,iN]);
			g_axConfirm[iM,iN] := FALSE;
				
			IF pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].16 THEN
				aiTempCnt[iN] := aiTempCnt[iN] + 1;
			END_IF
			
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].16 := FALSE;	
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].17 := FALSE;	
			pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].18 := FALSE;	
			
			i_pastStTrapAxisParam_Gantray^[iM,iN].xConfirm_Load_Unload_Press:= axTRIG_Confirm_load_unload[iM,iN].Q;
			i_pastStTrapAxisParam_Gantray^[iM,iN].xConfirm_Dn_Press:= axTRIG_Confirm_PressDn[iM,iN].Q;
			i_pastStTrapAxisParam_Gantray^[iM,iN].xConfirm_Up_Press:= axTRIG_Confirm_PressUp[iM,iN].Q;

			axFlag_Move_For_Long[iM,iN] := i_pastStHandWheel_BtnCtl^[iN].axReqMoveFor[iM];
			axFlag_Move_Rev_Long[iM,iN] := i_pastStHandWheel_BtnCtl^[iN].axReqMoveRev[iM];			
			
			i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveFor_Long:= axFlag_Move_For_Long[iM,iN] OR pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].6;
			i_pastStTrapAxisParam_Gantray^[iM,iN].xMoveRev_Long:= axFlag_Move_Rev_Long[iM,iN] OR pstStUnitParam_UnSave^.adwPressureMotor_Move[iM].7;

	//2025.12.23.102849 | 从龙门for循环里面挪出来，因为网辊和版辊同时运动不好控制		
			abySts_HandWheel[iM,iN] := 0;
			IF i_pastStHandWheel_BtnCtl^[iN].lrPos_HandWheelChange<>0 THEN			//手轮档位选择
				IF i_pastStHandWheel_BtnCtl^[iN].axFlag_Ctl_Roller_All[iM] THEN
					abySts_HandWheel[iM,iN]:= 1;
					i_pastStTrapAxisParam_Gantray^[iM,iN].lrPos_HandWheelChange:=
						i_pastStHandWheel_BtnCtl^[iN].lrPos_HandWheelChange;
// 					i_pastStTrapAxisParam_Gantray^[2,iN].lrPos_HandWheelChange:=
// 						i_pastStHandWheel_BtnCtl^[iN].lrPos_HandWheelChange;//2023.11.08.091810 || bai.zy	
				ELSIF i_pastStHandWheel_BtnCtl^[iN].axFlag_Ctl_Roller_M[iM] THEN
					abySts_HandWheel[iM,iN]:= 2;
					i_pastStTrapAxisParam_Gantray^[iM,iN].lrPos_HandWheelChange:=
						i_pastStHandWheel_BtnCtl^[iN].lrPos_HandWheelChange;
// 					i_pastStTrapAxisParam_Gantray^[2,iN].lrPos_HandWheelChange:=
// 						i_pastStHandWheel_BtnCtl^[iN].lrPos_HandWheelChange;//2023.11.08.091810 || bai.zy	
				ELSIF i_pastStHandWheel_BtnCtl^[iN].axFlag_Ctl_Roller_G[iM] THEN
					abySts_HandWheel[iM,iN]:= 3;
					i_pastStTrapAxisParam_Gantray^[iM,iN].lrPos_HandWheelChange:=
						i_pastStHandWheel_BtnCtl^[iN].lrPos_HandWheelChange;
// 					i_pastStTrapAxisParam_Gantray^[2,iN].lrPos_HandWheelChange:=
// 						i_pastStHandWheel_BtnCtl^[iN].lrPos_HandWheelChange;//2023.11.08.091810 || bai.zy		
				END_IF
			ELSE		//2023.11.07.165018 || baizy || 手轮位置没变，变量清零
				i_pastStTrapAxisParam_Gantray^[iM,iN].lrPos_HandWheelChange:=0;
			END_IF
			i_pastStTrapAxisParam_Gantray^[iM,iN].bySts_HandWheel:= abySts_HandWheel[iM,iN];
			
			i_pastStTrapAxisParam_Gantray^[iM,iN].xSts_Calid_Pos:= axFlag_Mode_Calid[iN];
			
		
			//2024.11.26.223433 | 标定合压位时获取绝对编码器位置，并写入到库里面记录零位
			IF i_pastStTrapAxisParam_Gantray^[iM,iN].xConfirm_Dn_Press THEN
				axConfirmPressPosFromSlave[iM,iN] := TRUE;

				iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_M, encoder:= 1, pPos:= ADR(lrAbsPos_M));
				iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_G, encoder:= 1, pPos:= ADR(lrAbsPos_G));

				i_pastStTrapAxisParam_Gantray^[iM,iN].lrPos_CurPos_Enc_M:=1;// LINT_TO_LREAL(g_liAbsPos_M);
				i_pastStTrapAxisParam_Gantray^[iM,iN].lrPos_CurPos_Enc_G:=1;// LINT_TO_LREAL(g_liAbsPos_G);
// 				iRtn := GT_RN_SetTrapCoordinate(targetNum:= 1, targetStation:=ADR(i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_M) , targetAxis:= ADR(g_liAbsPos_M));
// 				iRtn := GT_RN_SetTrapCoordinate(targetNum:= 1, targetStation:=ADR(i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_G) , targetAxis:= ADR(g_liAbsPos_G));
				g_liAbsPos_M := LREAL_TO_LINT(lrAbsPos_M);
				g_liAbsPos_G := LREAL_TO_LINT(lrAbsPos_G);
				axAxisRev[1] := i_pastStTrapAxisParam_Gantray^[iM,iN].xRev_Motor_M;
 				iRtn := KS_SetTrapCoordinate(
						i_xEn:= TRUE, 
						i_iTarget_Num:= 1, 
						i_paiTargetStationList:= ADR(i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_M), 
						i_paliABSEncPos:= ADR(g_liAbsPos_M), 
						i_paxAxisRev:= ADR(axAxisRev), 
						i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
						i_pastStGetMotionSts:= i_pastStGetMotionSts,
						i_pstStSysStationInf := i_pstStSysStationInf,
						i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
						ADR(g_alrCurrentAbsPos_M));
				axAxisRev[1] := i_pastStTrapAxisParam_Gantray^[iM,iN].xRev_Motor_G;
				iRtn := KS_SetTrapCoordinate(
						i_xEn:= TRUE, 
						i_iTarget_Num:= 1, 
						i_paiTargetStationList:= ADR(i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_G), 
						i_paliABSEncPos:= ADR(g_liAbsPos_G), 
						i_paxAxisRev:= ADR(axAxisRev), 
						i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
						i_pastStGetMotionSts:= i_pastStGetMotionSts,
						i_pstStSysStationInf := i_pstStSysStationInf,
						i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
						ADR(g_alrCurrentAbsPos_G));
				//是否要将程序中的TarPos以及主从轴的规划位置全部清零？？？？				
				CASE iM OF
					1:
						pstStUnitParam_Save^.liABSPos_Prn_M := g_liAbsPos_M;
						pstStUnitParam_Save^.liABSPos_Prn_G := g_liAbsPos_G;
										
						//2026.02.04.165726 | + | 增加获取编码器成功后将编码器值清零，规划位置也清零了;在这里把他们的规划清零
						alrTargetPos_Prn[iN] := 0;
						alrTargetPos_Prn_M[iN] := 0;
						alrTargetPos_Prn_G[iN] := 0;

						pstStGrpParam_Save^.rFilmThick_Confirm:= pstStGrpParam_Save^.rFilmThickNess_Using;
						pstStUnitParam_Save^.rGirth_Confirmed_press_dn_PrnRoller:= pstStUnitParam_Save^.rGirth_PrnRoller;
					2:
						pstStUnitParam_Save^.liABSPos_Net_M := g_liAbsPos_M;
						pstStUnitParam_Save^.liABSPos_Net_G := g_liAbsPos_G;
						
						//2026.02.04.165726 | + | 增加获取编码器成功后将编码器值清零，规划位置也清零了;在这里把他们的规划清零
						alrTargetPos_Net[iN] := 0;
						alrTargetPos_Net_M[iN] := 0;
						alrTargetPos_Net_G[iN] := 0;
					3:
						pstStUnitParam_Save^.liABSPos_Str_M := g_liAbsPos_M;
						pstStUnitParam_Save^.liABSPos_Str_G := g_liAbsPos_G;
						
						//2026.02.04.165726 | + | 增加获取编码器成功后将编码器值清零，规划位置也清零了;在这里把他们的规划清零
						alrTargetPos_Str[iN] := 0;
						alrTargetPos_Str_M[iN] := 0;
						alrTargetPos_Str_G[iN] := 0;
				END_CASE
				
			END_IF
			
			
			//2024.12.03.152342 | 增加调试阶段测试压力电机反复来回运行
			IF 	i_xDebugMode AND (NOT i_xFlag_Estop)  AND g_xPressDebugMode THEN
				IF pstStUnitParam_Save^.axPressLimit_Max[iM] AND pstStUnitParam_Save^.axPressLimit_Min[iM] THEN
					;
				ELSE
					g_axPressDebugStart[iM,iN] := FALSE;
				END_IF
			ELSE
				g_axPressDebugStart[iM,iN] := FALSE;
			END_IF
			
			IF g_axPressDebugStart[iM,iN] THEN
				IF (NOT axFlag_PressDebugModeForing[iM,iN]) AND (NOT axFlag_PressDebugModeReving[iM,iN]) THEN
					axFlag_PressDebugModeForing[iM,iN] := TRUE;
				END_IF
				
				IF axFlag_PressDebugModeForing[iM,iN] THEN
					aiCount_Debug_Move_Tol[iM,iN] := iCount_Debug_Move_Time;//60000/MAJOR_TSK_CYCLE_TIME;
					IF aiCount_Debug_Move[iM,iN] > aiCount_Debug_Move_Tol[iM,iN] THEN
						axFlag_PressDebugModeForing[iM,iN] := FALSE;
						axFlag_PressDebugModeReving[iM,iN] := TRUE;
						aiCount_Debug_Move[iM,iN] := 0;
					ELSE
						aiCount_Debug_Move[iM,iN] := aiCount_Debug_Move[iM,iN] + 1;
						IF aiCount_Debug_Move[iM,iN] > 1 THEN
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveFor := FALSE;
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveRev := FALSE;
						ELSE
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveFor := TRUE;
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveRev := FALSE;
						END_IF

					END_IF
				END_IF
				
				IF axFlag_PressDebugModeReving[iM,iN] THEN
					aiCount_Debug_Move_Tol[iM,iN] := iCount_Debug_Move_Time;
					IF aiCount_Debug_Move[iM,iN] > aiCount_Debug_Move_Tol[iM,iN] THEN
						axFlag_PressDebugModeReving[iM,iN] := FALSE;
						axFlag_PressDebugModeForing[iM,iN] := TRUE;
						aiCount_Debug_Move[iM,iN] := 0;
					ELSE
						aiCount_Debug_Move[iM,iN] := aiCount_Debug_Move[iM,iN] + 1;
						IF aiCount_Debug_Move[iM,iN] > 1 THEN
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveRev := FALSE;
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveFor := FALSE;
						ELSE
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveRev := TRUE;
							i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveFor := FALSE;
						END_IF
						
					END_IF
				END_IF
			ELSE
				aiCount_Debug_Move[iM,iN] := 0;
				axFlag_PressDebugModeForing[iM,iN] := FALSE;
				axFlag_PressDebugModeReving[iM,iN] := FALSE;
				i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveRev := FALSE;
				i_pastStTrapAxisParam_Gantray^[iM,iN].xPressDebugMode_MoveFor := FALSE;
			END_IF
			//2025.03.07.140551 | 从站界面进行位置标定
			IF axConfirmPressPosFromSlave[iM,iN] THEN
				i_pastStTrapAxisParam_Gantray^[iM,iN].xSts_Calid_Pos := TRUE;
				aiConfirmPressPosFromSlave_Count[iM,iN] := aiConfirmPressPosFromSlave_Count[iM,iN] + 1;
				IF aiConfirmPressPosFromSlave_Count[iM,iN] > 5 THEN
					aiConfirmPressPosFromSlave_Count[iM,iN] := 0;
					axConfirmPressPosFromSlave[iM,iN] := FALSE;
					i_pastStTrapAxisParam_Gantray^[iM,iN].xSts_Calid_Pos := FALSE;
				END_IF
			END_IF
		END_FOR
		
		
		IF  g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
			; (*2026.01.15.140112  新增品字型柔印机-版辊网辊独立运动 Hou.N*)
		ELSE
			IF i_pastStTrapAxisParam_Gantray^[1,iN].bySts_HandWheel <> 0 THEN //2026.01.15.140654  | 版辊运动时网辊要同步运动
				i_pastStTrapAxisParam_Gantray^[2,iN].bySts_HandWheel := i_pastStTrapAxisParam_Gantray^[1,iN].bySts_HandWheel;
				i_pastStTrapAxisParam_Gantray^[2,iN].lrPos_HandWheelChange := i_pastStTrapAxisParam_Gantray^[1,iN].lrPos_HandWheelChange;
			END_IF
		END_IF
(*		
		//2024.12.11.165903 | 印版辊快速升降
		IF pstStUnitParam_Unsave^.adwPressureMotor_Move[1].11 THEN
			
			lrDistanceForAvoidPrnGear := rDistanceForAvoidPrnGear*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(pstStUnitParam_Save^.uiNum_PrnRoller_Pressure)/
					pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure/
					UINT_TO_REAL(pstStUnitParam_Save^.uiDen_PrnRoller_Pressure);	
			
			lrTemp_100um_pos := 0.1*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(pstStUnitParam_Save^.uiNum_PrnRoller_Pressure)/
					pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure/
					UINT_TO_REAL(pstStUnitParam_Save^.uiDen_PrnRoller_Pressure);
					
			IF 	((i_pastStTrapAxisParam_Gantray^[1,iN].lrPos_CurPos_Enc_M - lrDistanceForAvoidPrnGear - pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_M - lrTemp_100um_pos) < 0) AND
				((i_pastStTrapAxisParam_Gantray^[1,iN].lrPos_CurPos_Enc_G - lrDistanceForAvoidPrnGear - pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_G - lrTemp_100um_pos) < 0) THEN
				iTemp := iTemp + 1;
			ELSE			
				i_pastStTrapAxisParam_Gantray^[1,iN].xManuForPanel := TRUE;
				i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_PressUp := TRUE;
			END_IF
		END_IF

		IF pstStUnitParam_UnSave^.adwPressureMotor_Move[1].12 THEN
			i_pastStTrapAxisParam_Gantray^[1,iN].xManuForPanel := TRUE;
			i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_Load_Unload := TRUE;
		END_IF
		IF  pstStUnitParam_UnSave^.adwPressureMotor_Move[1].13 AND i_pastStTrapAxisParam_Gantray^[1,iN].xManuForPanel THEN
			i_pastStTrapAxisParam_Gantray^[1,iN].xManuNeedStop := TRUE;
			aiCountNeetStop[iN] := aiCountNeetStop[iN] + 1;
		END_IF
		
		IF i_pastStTrapAxisParam_Gantray^[1,iN].xManuNeedStop THEN
			IF aiCountNeetStop[iN] < 3 THEN
				aiCountNeetStop[iN] := aiCountNeetStop[iN] + 1;	
			ELSE
				aiCountNeetStop[iN] := 0;
				i_pastStTrapAxisParam_Gantray^[1,iN].xManuNeedStop := FALSE;
				i_pastStTrapAxisParam_Gantray^[1,iN].xManuForPanel := FALSE;
			END_IF
		END_IF
*)
		axConfirm_Adjust_PressDn[iN](CLK:=i_pastStHandWheel_BtnCtl^[iN].xReq_Confirm_Adjust_PressDn,
			Q=>i_pastStTrapAxisParam_Gantray^[1,iN].xConfirm_Adjust_PressDn);//标定矫正
		(*2026.01.15.141447  新增品字型柔印机-版辊网辊独立运动 Hou.N*)
		IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
			//i_pastStTrapAxisParam_Gantray^[2,iN].xConfirm_Adjust_PressDn:=FALSE ;//防止误触
			//i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_PressUp:= FALSE;
			//i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_PressDn :=FALSE;
		//	i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_Load_Unload:= FALSE;
					;
		ELSE
			i_pastStTrapAxisParam_Gantray^[2,iN].xConfirm_Adjust_PressDn:= i_pastStTrapAxisParam_Gantray^[1,iN].xConfirm_Adjust_PressDn;
			i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_PressUp:= i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_PressUp;
			i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_PressDn := i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_PressDn;
			i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_Load_Unload:= i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_Load_Unload;
		END_IF
		
		//2023.11.3.153513|记录一下圆心到切点的位置
		IF axFlag_Mode_Calid[iN] THEN
			pstStUnitParam_Save^.rweigth_Prn_Bottom_Confirm:= pstStUnitParam_UnSave^.rweigth_Prn_Bottom_Cur;
			pstStUnitParam_Save^.rweigth_Prn_Net_Confirm:= pstStUnitParam_UnSave^.rweigth_Prn_Net_Cur;
			pstStUnitParam_Save^.rweigth_Net_Prn_Confirm:= pstStUnitParam_UnSave^.rweigth_Net_Prn_Cur;
			pstStUnitParam_Save^.rweigth_Net_Load_Confirm:= pstStUnitParam_UnSave^.rweigth_Net_Load_Cur;
			pstStUnitParam_Save^.rGirth_Confirmed_press_dn_PrnRoller:= pstStUnitParam_Save^.rGirth_PrnRoller;
			pstStUnitParam_Save^.rGirth_Confirmed_press_dn_NetRoller:= pstStUnitParam_Save^.rGirth_NetRoller;
		
			pstStGrpParam_Save^.rFilmThick_Confirm:= pstStGrpParam_Save^.rFilmThickNess_Using;
			//记录一下料膜厚度2023.12.27.171554
		END_IF	
		
		axMoveEn_Prn_M[iN]:= FALSE;
		axMoveEn_Prn_G[iN]:= FALSE;
		axMoveEn_Net_M[iN]:= FALSE;
		axMoveEn_Net_G[iN]:= FALSE;
		axMoveEn_Str_M[iN]:= FALSE;
		axMoveEn_Str_G[iN]:= FALSE;
	
		FOR iM:=1 TO i_iGrpGantryTrapMotion_Num BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_aiGrpGantryTrapMotion_StdList[iM],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);	
			KS_GetAxisIdForMotByStation_Gantry(
				i_iStationId:= i_aiGrpGantryTrapMotion_StdList[iM],
				i_piAxisId:= ADR(iAxisId), 
				i_piTypeId:= ADR(iTypeId), 
				i_piUnitId:= ADR(iUnitId), 
				i_piCoreId:= ADR(iCoreId), 
				i_piGroupId:= ADR(iGroupId), 
				i_piAdjAxisId:= ADR(iAdjAxisId), 
				i_pstStSysStationInf:= i_pstStSysStationInf,
				i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf);	
			
			IF iUnitId=iN AND iTypeId= TYPE_UNIT_PRN_PRESS_MASTER THEN
				axMoveEn_Prn_M[iN]:=  i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep=MOTIONCTL_STEP_WRITEDATA_Run ;
				//i_pastStTrapAxisParam_Gantray^[1,iN].rTorque_M:= i_paStStationMotionSts^[iM].torque/1000;
			END_IF
			IF iUnitId=iN AND iTypeId= TYPE_UNIT_PRN_PRESS_G THEN
				axMoveEn_Prn_G[iN]:= i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep=MOTIONCTL_STEP_WRITEDATA_Run ;
				//i_pastStTrapAxisParam_Gantray^[1,iN].rTorque_G:= i_paStStationMotionSts^[iM].torque/1000;	
			END_IF
			IF iUnitId=iN AND iTypeId= TYPE_UNIT_NET_PRESS_MASTER THEN
				axMoveEn_Net_M[iN]:=  i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep=MOTIONCTL_STEP_WRITEDATA_Run ;
				//i_pastStTrapAxisParam_Gantray^[2,iN].rTorque_M:= i_paStStationMotionSts^[iM].torque/1000;
			END_IF
			IF iUnitId=iN AND iTypeId= TYPE_UNIT_NET_PRESS_G THEN
				axMoveEn_Net_G[iN]:= i_pastStMotorParam_GantryTrap^[iGroupId].iMoveStep=MOTIONCTL_STEP_WRITEDATA_Run ;
				//i_pastStTrapAxisParam_Gantray^[2,iN].rTorque_G:= i_paStStationMotionSts^[iM].torque/1000;	
			END_IF								
		END_FOR

		i_pastStTrapAxisParam_Gantray^[1,iN].xFlag_MoveEn:= axMoveEn_Prn_M[iN] AND axMoveEn_Prn_G[iN] AND i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wCtl_Pressure_Up_Dn.5;
		i_pastStTrapAxisParam_Gantray^[2,iN].xFlag_MoveEn:= axMoveEn_Net_M[iN] AND axMoveEn_Net_G[iN] AND i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wCtl_Pressure_Up_Dn.5;
		
	END_FOR
	
	g_xPressUp_To_Dn:= FALSE;// : BOOL;//全体合压
	g_xPressDn_To_Up:= FALSE;// : BOOL;//全体合压
	g_xPressUp_To_Load:= FALSE;// : BOOL;//全体合压
	g_xPressLoad_To_Up:= FALSE;// : BOOL;//全体合压
	g_xPressMoveToLoad:= FALSE;// : BOOL;//全体合压
//2023.11.21.135705处理一下停机时侯需要先离压网辊，版辊再转3圈后离压版辊
//2023.11.21.135830同样在这里需要处理一下印刷自动合压标志
	xNeedMoveUp_Stop_Net:= FALSE;
	xNeedMoveUp_Stop_Prn:= FALSE;
	fbTRIG_ResetEstop(CLK:= (NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop) AND
							 (NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping));
	IF i_xStopOrEstop_Valid AND (pstStGrpParam_UnSave^.rVel_Film>0 OR i_ReqResetEstop) OR fbTRIG_ResetEstop.Q THEN
		xMoveUp_Stop_Delay:= TRUE;
		rTemp_RunLength:= 0;
	END_IF
	IF xMoveUp_Stop_Delay AND pstStGrpParam_UnSave^.rVel_Film>0 THEN
		IF pstStGrpParam_UnSave^.rVel_Film > 0 AND pstStGrpParam_UnSave^.rVel_Film < pstStGrpParam_Save^.rVel_NetReturn AND (NOT xNeedMoveUp_Stop_Net_Finished) THEN
			xNeedMoveUp_Stop_Net:= TRUE;
			xNeedMoveUp_Stop_Net_Finished := TRUE;
		END_IF
		
// 		IF xNeedMoveUp_Stop_Net_Finished AND (NOT xNeedMoveUp_Stop_Prn_Finished) THEN
// 			iMoveUp_Stop_Cnt:= iMoveUp_Stop_Cnt+1;
// 			i_byCycle_PrnRoller_MoveUp := 1;
// 			rTemp:= i_byCycle_PrnRoller_MoveUp*pstStGrpParam_Save^.rGirth_PrnRoller/1000.0;//单位mm

// 			rTemp_RunLength:= rTemp_RunLength+pstStGrpParam_UnSave^.rVel_Film*gc_TENSION_TSK_CYCLE_TIME/1000.0/60.0;
// 			IF rTemp_RunLength>=rTemp THEN
// 				xNeedMoveUp_Stop_Prn:= TRUE;
// 				//xMoveUp_Stop_Delay:= FALSE;
// 				xNeedMoveUp_Stop_Prn_Finished := TRUE;
// 			END_IF
// 		END_IF











	ELSIF xMoveUp_Stop_Delay AND pstStGrpParam_UnSave^.rVel_Film=0 THEN
		xNeedMoveUp_Stop_Net:= TRUE;//2024.12.17.090526
		xNeedMoveUp_Stop_Prn:= TRUE;
		xMoveUp_Stop_Delay:= FALSE;
		rTemp_RunLength:= 0;
		xNeedMoveUp_Stop_Net_Finished := FALSE;
		xNeedMoveUp_Stop_Prn_Finished := FALSE;
	END_IF
(*
	IF i_xStopOrEstop_Valid AND (pstStGrpParam_UnSave^.rVel_Film>0 OR i_ReqResetEstop) OR fbTRIG_ResetEstop.Q THEN
		//2026.01.15.100301//新增品字型柔印机-版辊网辊独立运动 
// 		IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
// 			xNeedMoveUp_Stop_Prn:=TRUE;
// 		ELSE
//			xNeedMoveUp_Stop_Prn:=TRUE;
			xNeedMoveUp_Stop_Net:= TRUE; //停机/急停需要离压就直接离压网辊
// 		END_IF
		xMoveUp_Stop_Delay:= TRUE;
		rTemp_RunLength:= 0;
	END_IF
	IF xMoveUp_Stop_Delay AND pstStGrpParam_UnSave^.rVel_Film>0 THEN
		iMoveUp_Stop_Cnt:= iMoveUp_Stop_Cnt+1;
		rTemp:= i_byCycle_PrnRoller_MoveUp*pstStGrpParam_Save^.rGirth_PrnRoller/1000.0;//单位mm
		rTemp_RunLength:= rTemp_RunLength+pstStGrpParam_UnSave^.rVel_Film*gc_TENSION_TSK_CYCLE_TIME/1000.0/60.0;
		IF rTemp_RunLength>=rTemp THEN
			xNeedMoveUp_Stop_Prn:= TRUE;
			xMoveUp_Stop_Delay:= FALSE;
		END_IF
	ELSIF xMoveUp_Stop_Delay AND pstStGrpParam_UnSave^.rVel_Film=0 THEN
		xNeedMoveUp_Stop_Prn:= TRUE;
		xMoveUp_Stop_Delay:= FALSE;
		rTemp_RunLength:= 0;
	END_IF
*)
//料头避让处理；
(*
//2025.07.09.104648 | 增加跳板功能开关，客户不需要这个功能，做个开关默认关了
	IF i_pstStSysParam^.dwCtlSwitchRef.4 THEN
		fbTRIG_Avoidance_Ctl(CLK:= i_xCutter_DnCut);
		//i_pstStSysParam^.rLength_AvoidancePoint_To_1u_mm:= 10000;
		fbKS_FB_Avoidance_Prn_Ctl(
			i_xEn:= TRUE, 
			i_iUnitNum:= i_iUnitNum, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStTrapAxisParam_Gantray:= i_pastStTrapAxisParam_Gantray, 
			i_xFlag_Avoidance:= fbTRIG_Avoidance_Ctl.Q, 
			i_iDelayTime_Flag_Avoidance_ms:=0,// UDINT_TO_INT(g_audiSkirtTime[2]/1000),//0, 
			i_iLength_mm_Avoidance:= 2000, 
			i_rTar_MM_Avoidance:= 0.9, 
			o_xEn=> );
	END_IF

		(*网辊避让料头*)
	fbKS_FB_Avoidance_Net_Ctl(
		i_xEn:= TRUE, 
		i_iUnitNum:= i_iUnitNum, 
		i_pstStSysParam:= i_pstStSysParam, 
		i_pastStTrapAxisParam_Gantray:= i_pastStTrapAxisParam_Gantray, 
		i_xFlag_Avoidance:= fbTRIG_Avoidance_Ctl.Q, 
		i_iDelayTime_Flag_Avoidance_ms:=0,// UDINT_TO_INT(g_audiSkirtTime[2]/1000),//0, 
		i_iLength_mm_Avoidance:= 1000, 
		i_rTar_MM_Avoidance:= 0.5, 
		o_xEn=> );
	
	g_xFlag_Avoidance :=  g_xAvoidance_Test;
	IF g_xAvoidance_Test THEN
		g_xAvoidance_Test := FALSE;
		g_xTempAvoidance := TRUE;
	END_IF
	IF i_pstStSysParam^.xFlag_Stop THEN
		g_xTempAvoidance := FALSE;
	END_IF
	
	FOR iN:=1 TO i_iUnitNum BY 1 DO
		i_pastStTrapAxisParam_Gantray^[1,iN].rMoveUp_mm_Avoidance:= 0.9;
		afbTRIG_Avoidance_MoveUp[iN](CLK:= i_pastStTrapAxisParam_Gantray^[1,iN].xMoveUp_To_Avoidance,
			Q=>i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_Up_Avoidance);
		afbTRIG_Avoidance_MoveDn[iN](CLK:= NOT i_pastStTrapAxisParam_Gantray^[1,iN].xMoveUp_To_Avoidance,
			Q=>i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_Dn_Avoidance);
	END_FOR
	(*网辊合压离压信号*)
	FOR iN:=1 TO i_iUnitNum BY 1 DO
		i_pastStTrapAxisParam_Gantray^[2,iN].rMoveUp_mm_Avoidance:= 0.5;
		afbTRIG_Avoidance_MoveUp_Net[iN](CLK:= i_pastStTrapAxisParam_Gantray^[2,iN].xMoveUp_To_Avoidance,
			Q=>i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_Up_Avoidance);
		afbTRIG_Avoidance_MoveDn_Net[iN](CLK:= NOT i_pastStTrapAxisParam_Gantray^[2,iN].xMoveUp_To_Avoidance,
			Q=>i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_Dn_Avoidance);
	END_FOR
*)	
(*
	
//2023.12.21.093624测试一下往复间隙
	IF g_xTest_MoveFor AND (NOT g_xFlag_MoveForing) AND (NOT g_xFlag_MoveReving) THEN
		g_xTest_MoveFor:= FALSE;
		g_xFlag_MoveForing:= TRUE;
// 			IF g_iAxis_Test>=1 AND g_iAxis_Test<=16 THEN
// 				i_pastStTrapAxisParam_Gantray^[1,iN].xMoveFor_Test_For_Rev_For:
// 			END_IF
	END_IF		
	IF g_xTest_MoveRev AND (NOT g_xFlag_MoveForing) AND (NOT g_xFlag_MoveReving) THEN
		g_xTest_MoveRev:= FALSE;
		g_xFlag_MoveReving:= TRUE;
// 			IF g_iAxis_Test>=1 AND g_iAxis_Test<=16 THEN
// 				i_pastStTrapAxisParam_Gantray^[1,iN].xMoveFor_Test_For_Rev_For:
// 			END_IF
	END_IF				
	IF g_xFlag_MoveForing THEN
		iCnt_Test_Move:= REAL_TO_INT(g_rTest_AllLength/g_rTest_StepLength);
		IF iCnt_>= iCnt_Test_Move THEN
			iCnt_:= 0;
			i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_For:= FALSE;	
			g_xFlag_MoveForing:= FALSE;
		ELSE
			IF g_iAxis_Test>=1 AND g_iAxis_Test<=16 THEN
				IF xMoveEN THEN
					i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_For:= TRUE;
					iCnt_:= iCnt_+1;
				ELSE
					i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_For:= FALSE;				
				END_IF
				xMoveEN:= NOT xMoveEN;
			ELSE
				iCnt_:= 0;
				i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_For:= FALSE;	
				g_xFlag_MoveForing:= FALSE;					
			END_IF
		END_IF
	END_IF
	IF g_xFlag_MoveReving THEN
		iCnt_Test_Move:= REAL_TO_INT(g_rTest_AllLength/g_rTest_StepLength);
		IF iCnt_>= iCnt_Test_Move THEN
			iCnt_:= 0;
			i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_Rev:= FALSE;	
			g_xFlag_MoveReving:= FALSE;
		ELSE
			IF g_iAxis_Test>=1 AND g_iAxis_Test<=16 THEN
				IF xMoveEN THEN
					i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_Rev:= TRUE;
					iCnt_:= iCnt_+1;
				ELSE
					i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_Rev:= FALSE;				
				END_IF
				xMoveEN:= NOT xMoveEN;
			ELSE
				iCnt_:= 0;
				i_pastStTrapAxisParam_Gantray^[1,g_iAxis_Test].xMoveFor_Test_For_Rev_Rev:= FALSE;	
				g_xFlag_MoveReving:= FALSE;					
			END_IF
		END_IF
	END_IF
*)	

(*	
//bai.zy | 2023.12.17.160732 | 压力电机扭矩保护	
	FOR iN := 1 TO 	gc_iMax_PressureRoller_Unit BY 1 DO
		FOR iM := 1 TO i_iUnitNum BY 1 DO
			IF ABS(i_pastStTrapAxisParam_Gantray^[iN,iM].rTorque_M) > i_pstStSysParam^.rRatedTorque THEN
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_M := i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_M + 1;
				IF ABS(i_pastStTrapAxisParam_Gantray^[iN,iM].rTorque_M) > i_pstStSysParam^.rPeakTorque THEN
					i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_M := i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_M + 1;
				ELSE
					i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_M:= 0;
				END_IF
			ELSE
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_M := 0;
				i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_M:= 0;
			END_IF
			IF ABS(i_pastStTrapAxisParam_Gantray^[iN,iM].rTorque_G) > i_pstStSysParam^.rRatedTorque THEN
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_G := i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_G + 1;
				IF ABS(i_pastStTrapAxisParam_Gantray^[iN,iM].rTorque_G) > i_pstStSysParam^.rPeakTorque THEN
					i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_G := i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_G + 1;
				ELSE
					i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_G := 0;
				END_IF
			ELSE
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_G := 0;
				i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_G := 0;
			END_IF
			
			IF i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_M > i_pstStSysParam^.rPeakTorqueKeepTime*1000/MAJOR_TSK_CYCLE_TIME OR
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_M > i_pstStSysParam^.rRatedTorqueKeepTime*1000/MAJOR_TSK_CYCLE_TIME OR
				i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_G > i_pstStSysParam^.rPeakTorqueKeepTime*1000/MAJOR_TSK_CYCLE_TIME OR
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_G > i_pstStSysParam^.rRatedTorqueKeepTime*1000/MAJOR_TSK_CYCLE_TIME THEN
				i_pastStTrapAxisParam_Gantray^[iN,iM].xPressFlag_Stop := TRUE;		
			ELSE
				;
			END_IF
		END_FOR
	END_FOR

	FOR iN := 1 TO i_iUnitNum BY 1 DO
		//bai.zy | 2023.12.19.162958 | 临时
		IF i_pastStTrapAxisParam_Gantray^[2,iN].xPressFlag_Stop THEN
			i_pastStTrapAxisParam_Gantray^[1,iN].xPressFlag_Stop:= TRUE;
		END_IF	
		//bai.zy | 2023.12.19.162958 | 临时
		IF i_pastStTrapAxisParam_Gantray^[1,iN].xPressFlag_Stop THEN
			i_pastStTrapAxisParam_Gantray^[2,iN].xPressFlag_Stop:= TRUE;
		END_IF	
	END_FOR
*)	

rMaxErr := i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].rMaxErr_GantryTrap;
IF rMaxErr < 0.1 THEN
	rMaxErr := 0.1;
END_IF
//2026.05.09.160415 | + | 增加龙门偏差过大保护
	FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
		IF (ABS(i_pastStTrapAxisParam_Gantray^[1,iN].lrParallelError_MM) > rMaxErr) OR (ABS(i_pastStTrapAxisParam_Gantray^[2,iN].lrParallelError_MM) > rMaxErr) THEN
			i_pastStTrapAxisParam_Gantray^[1,iN].xPressFlag_Stop:= TRUE;


			g_axPressFlag_Stop[iN] := TRUE;

		ELSE
			i_pastStTrapAxisParam_Gantray^[1,iN].xPressFlag_Stop:= FALSE;

			g_axPressFlag_Stop[iN] := FALSE;

		END_IF
	END_FOR
	
	IF g_xConfirmContinueForward THEN		//清除保护
		g_xConfirmContinueForward := FALSE;
		FOR iN := 1 TO gc_iMax_PressureRoller_Unit BY 1 DO
			FOR iM := 1 TO i_iGrpUnitNum_Pu BY 1 DO
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_M := 0;
				i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_M := 0;
				i_pastStTrapAxisParam_Gantray^[iN,iM].iRatedCount_G := 0;
				i_pastStTrapAxisParam_Gantray^[iN,iM].iPeakCount_G := 0;
				i_pastStTrapAxisParam_Gantray^[iN,iM].xPressFlag_Stop := FALSE;
			END_FOR
		END_FOR
	END_IF


//3.版辊压力处理
	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);			
		
		i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_M_Confirm:= 	
			pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_M;
		i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_G_Confirm:= 	
			pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_G;		
		i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_M_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_M;		
		i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_G_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_G;						
		i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_M;		
		i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_G;	
			
		//2024.10.21.121704
		i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmParallelPos:=pstStUnitParam_UnSave^.xConfirmParallelPos_Prn ;//平行确认按钮
		i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosParallel_M := pstStUnitParam_Save^.lrEncPosParallel_Prn_M ;
		i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosParallel_G := pstStUnitParam_Save^.lrEncPosParallel_Prn_G ;
		
		i_pastStTrapAxisParam_Gantray^[1,iN].lrPrintPosOffsetDn_M:=pstStUnitParam_Save^.lrPrintPosOffsetDn_Prn_M;//合压偏移量
		i_pastStTrapAxisParam_Gantray^[1,iN].lrPrintPosOffsetDn_G:=pstStUnitParam_Save^.lrPrintPosOffsetDn_Prn_G;
		
		//2024.12.03.162342 | 增加调试阶段的压力运动
		i_pastStTrapAxisParam_Gantray^[1,iN].xCalidPressLimit_Max:=pstStUnitParam_UnSave^.axCalidPressLimit_Max[1] ;//平行确认按钮
		i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosLimit_M_Max := pstStUnitParam_Save^.lrEncPosLimit_Prn_M_Max ;
		i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosLimit_G_Max := pstStUnitParam_Save^.lrEncPosLimit_Prn_G_Max ;
			
		//bai.zy | 2024.01.15.105513 | 合压位换版位标定完成标志
		i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmDnPosDne_Pressure_M := pstStUnitParam_Save^.xConfirmDnPosDne_PrnRoller_Pressure_M;
		i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmDnPosDne_Pressure_G := pstStUnitParam_Save^.xConfirmDnPosDne_PrnRoller_Pressure_G;	
		i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmload_unloadPosDne_Pressure_M := pstStUnitParam_Save^.xConfirmload_unloadPosDne_PrnRoller_Pressure_M;
		i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmload_unloadPosDne_Pressure_G := pstStUnitParam_Save^.xConfirmload_unloadPosDne_PrnRoller_Pressure_G;


	(*2026.03.19.203725 // Hou.N// 换版+料膜补偿后品字形柔印机新的合压离压位计算*)
	IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
		IF ((pstStUnitParam_Save^.rGirth_Confirmed_press_dn_PrnRoller<>pstStUnitParam_Save^.rGirth_PrnRoller AND
			pstStUnitParam_Save^.rGirth_Confirmed_press_dn_PrnRoller<>0 AND pstStGrpParam_Save^.rGirth_PrnRoller<>0))
			OR ((pstStGrpParam_Save^.rFilmThick_Confirm<>pstStGrpParam_Save^.rFilmThickNess_Using AND
			pstStGrpParam_Save^.rFilmThick_Confirm<>0 AND pstStGrpParam_Save^.rFilmThickNess_Using<>0)) THEN
			
			afKS_FB_CacuHypotenuse_V3[iN](
				i_xEn:= g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5, 
				i_rPrRoller_Girth0:= pstStUnitParam_Save^.rGirth_Confirmed_press_dn_PrnRoller,//标定时记录的换版前版辊周长 
				i_rPrRoller_Girth:= pstStUnitParam_Save^.rGirth_PrnRoller, //换版后版辊周长
				i_rBrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_BottomRoller , 
				i_rFix_Horizontal_Edge_X:= g_arFix_RightEdge[iN], 
				i_rFilmThick_Confirm:=pstStGrpParam_Save^.rFilmThick_Confirm,
				i_rFilmThickNess_Using:=pstStGrpParam_Save^.rFilmThickNess_Using,
				o_rCathetus_diff=> rPosdiff_Dnpress//换版前和换版后合压位置的竖直位置差 mm
				);
			afKS_FB_CalcuHypotenuse[iN](
				i_xEn:=g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 , 
				i_rPrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller , 
				i_rNrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_NetRoller , 
				i_rBrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_BottomRoller  , 
				i_rPos_press_dn_PrnRoller_Pressure_MM:=g_rPos_press_dn_PrnRoller_Pressure_MM , 
				i_rFix_Horizontal_Edge_X:= g_arFix_RightEdge[iN], 
				o_rPos_press_dn_PrnRoller_Pressure_MM=>g_rUp_Dn_Length_MM[iN]);//计算换版后的离压位置 
			lrTemp1:=g_rUp_Dn_Length_MM[iN]*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(pstStUnitParam_Save^.uiNum_PrnRoller_Pressure)/
						pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure/
						UINT_TO_REAL(pstStUnitParam_Save^.uiDen_PrnRoller_Pressure); 
						//换版后的离压物理距离->编码器位置
			IF i_pastStTrapAxisParam_Gantray^[1,iN].xRev_Motor_M THEN
					i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M:=
						i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M_Confirm-
						((rPosdiff_Dnpress)*
						UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_PrnRoller_Pressure)*GC_LRMOTORPPR_TRAP/
						UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_PrnRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure);

				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_M:= 
					i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M-lrTemp1;	//计算换版后新的离压位置
			ELSE
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M:= 
						i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M_Confirm+
						((
						(rPosdiff_Dnpress))*
						UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_PrnRoller_Pressure)*GC_LRMOTORPPR_TRAP/
						UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_PrnRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure);
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_M:= 
					i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M+lrTemp1;	
			END_IF	
			IF i_pastStTrapAxisParam_Gantray^[1,iN].xRev_Motor_G THEN
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G:= 
						i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G_Confirm-
						((rPosdiff_Dnpress)*
						UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_PrnRoller_Pressure)*GC_LRMOTORPPR_TRAP/
						UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_PrnRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure);
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_G:= 
					i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G-lrTemp1;
				
			ELSE
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G:= 
						i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G_Confirm+
						(((rPosdiff_Dnpress))*
						UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_PrnRoller_Pressure)*GC_LRMOTORPPR_TRAP/
						UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_PrnRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure);
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_G:= 
					i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G+lrTemp1;	
			END_IF	
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_M:= //换版位的物理位置是不变的2023.12.13.081145
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_M_Confirm;
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_G:= 
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_G_Confirm;
			
		ELSE
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M:= 
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M_Confirm;
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G:= 
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G_Confirm;
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_M:= 
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_M_Confirm;				
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_G:= 
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_G_Confirm;
								
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_M:= //换版位的物理位置是不变的2023.12.13.081145
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_M_Confirm;
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_G:= 
				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_G_Confirm;				
		END_IF
	END_IF


		IF g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller=0 THEN
			g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller:=400;
		END_IF
		(*2026.01.30.141632 新增品字型柔印机处理 Hou.N*)
		afKS_FB_CalcuHypotenuse[iN](
			i_xEn:=g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 , 
			i_rPrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller , 
			i_rNrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_NetRoller , 
			i_rBrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_BottomRoller  , 
			i_rPos_press_dn_PrnRoller_Pressure_MM:=g_rPos_press_dn_PrnRoller_Pressure_MM , 
			i_rFix_Horizontal_Edge_X:= g_arFix_RightEdge[iN], 
			o_rPos_press_dn_PrnRoller_Pressure_MM=>g_rUp_Dn_Length_MM[iN] );
			
	//2026.02.08.135719 | + | 步进量处理
		IF pstStUnitParam_Save^.rStep_Pressure_Prn_Net = 0 THEN
			pstStUnitParam_Save^.rStep_Pressure_Prn_Net := 0.1;
		END_IF
		afKS_FB_CalcuHypotenuse_V2[iN](
			i_xEn:=g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 , 
			i_rPrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller , 
			i_rNrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_NetRoller , 
			i_rBrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_BottomRoller  , 
			i_rPos_press_dn_PrnRoller_Pressure_MM:=pstStUnitParam_Save^.rStep_Pressure_Prn_Net,
			i_rFix_Horizontal_Edge_X:= g_arFix_RightEdge[iN], 
			i_lrCurPos_mm :=(i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_M + i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_G)/2,
			o_rProportion=>arProportion[iN]);
		
		afbKS_FB_GantryTrap_Calc_TargetPos_Prn[iN](
			i_xEn:= TRUE, 
			i_uiNum:= pstStUnitParam_Save^.uiNum_PrnRoller_Pressure, 
			i_uiDen:= pstStUnitParam_Save^.uiDen_PrnRoller_Pressure, 
			i_rScrewPitch:= pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure, 
			i_rUp_Dn_Length:=g_rUp_Dn_Length_MM[iN],//g_rPos_press_dn_PrnRoller_Pressure_MM,//1.35, //3mm
			i_rGirth_Roller:= pstStUnitParam_Save^.rGirth_PrnRoller, 
			i_xStopOrEstop_Valid:= xNeedMoveUp_Stop_Prn,
			i_prGirth_Confirm:= ADR(pstStUnitParam_Save^.rGirth_Confirmed_press_dn_PrnRoller), 
			i_xFlag_Print:= pstStGrpParam_UnSave^.xFlag_Print, 
			i_xStep_Fast:= pstStUnitParam_Save^.wFlag_PressFun.1,//^.xStep_Fast, 
			i_rStep_Fast:= pstStGrpParam_Save^.rStep_Fast, 
			i_rStep_Little:= pstStGrpParam_Save^.rStep_Little, 
			i_rVel_Fast:= pstStGrpParam_Save^.rVel_Press_Prn, 
			i_rVel_Little:= 0.1, 
			i_plrTargetPos_All:= ADR(alrTargetPos_Prn[iN]), 
			i_plrTargetPos_M:= ADR(alrTargetPos_Prn_M[iN]), 
			i_plrTargetPos_G:= ADR(alrTargetPos_Prn_G[iN]), 
			i_pstStTrapAxisParam_Gantray:= ADR(i_pastStTrapAxisParam_Gantray^[1,iN]), 
			i_xFlag_Estop:= i_xFlag_Estop,
			//i_rStep_HMI:= pstStUnitParam^.rStep_Pressure_Prn_Net,//2023.12.22.220303
			//i_rDistanceForAvoidPrnGear := rDistanceForAvoidPrnGear,
			i_pxFinishConfirm_Adjust_PressDn := ADR(axFinishConfirm_Adjust_PressDn[iN]),//: POINTER TO BOOL;
			i_rStep_HMI_Use:=pstStUnitParam_Save^.rStep_Pressure_Prn_Net,
			i_rProportion:=arProportion[iN],
			i_xMove_to_Up_Estop := pstStGrpParam_Save^.wCtl_Pressure_Up_Dn.1,
			i_ReqResetEstop := i_ReqResetEstop,
			i_rMaxErr := rMaxErr,
			o_xEn=> , 
			o_rVel=> o_arVel_Prn[iN], 
			o_lrTargetPos_All=> o_alrTargetPos_Prn[iN], 
			o_lrTargetPos_M=> o_alrTargetPos_Prn_M[iN], 
			o_lrTargetPos_G=> o_alrTargetPos_Prn_G[iN],
			o_lrTemp_Len_Up_Pos=>alrTemp_Len_Up_Pos_Prn[iN],
			o_lrTemp_Len_Load_Unload_Pos=>alrTemp_Len_Load_Unload_Pos_Prn[iN],
			o_lrK_Dynamic=>g_arK_TSHAPED_PrnVertical[iN]); //2026.01.17.93800 先全局 后续优化
			
			
			//2026.04.10.184313 //超旭增加一些保存 //Hou.N||调试信息待删除
			IF i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_PressDn THEN
				g_aiCount_Dn[iN]:= g_aiCount_Dn[iN]+1;
			END_IF			
			IF i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_PressUp THEN
				g_aiCount_Up[iN]:= g_aiCount_Up[iN]+1;
			END_IF		
			IF i_pastStTrapAxisParam_Gantray^[1,iN].xMove_To_Load_Unload THEN
				g_aiCount_Unload[iN]:= g_aiCount_Unload[iN]+1;
			END_IF
			
//2026.04.10.143550增加一些保存2026.04.10.143554|niu.j||调试信息待删除
IF	i_pastStTrapAxisParam_Gantray^[1,iN].xRollerMoveFor THEN		
	g_aiCount_MoveUp[iN]:= g_aiCount_MoveUp[iN]+1;
END_IF
IF	i_pastStTrapAxisParam_Gantray^[1,iN].xRollerMoveRev THEN		
	g_aiCount_MoveDn[iN]:= g_aiCount_MoveDn[iN]+1;
END_IF
g_arStep_Use[iN]:= afbKS_FB_GantryTrap_Calc_TargetPos_Prn[iN].rStep_Use;
			
// 			pstStUnitParam^.rPos_load_unload_PrnRoller_Pressure_M:=
// 				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_M;
// 			pstStUnitParam^.rPos_load_unload_PrnRoller_Pressure_G:= 
// 				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_G;		
// 			pstStUnitParam^.rPos_press_up_PrnRoller_Pressure_M:= 
// 				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_M;		
// 			pstStUnitParam^.rPos_press_up_PrnRoller_Pressure_G:= 
// 				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_G;						
// 			pstStUnitParam^.rPos_press_dn_PrnRoller_Pressure_M:= 
// 				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M;		
// 			pstStUnitParam^.rPos_press_dn_PrnRoller_Pressure_G:=
// 				i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G;	
		//这里是标定的位置2023.12.12.231132
		//标定位置的处理在功能里
		pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_M:=
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_M_Confirm;
		pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_G:= 
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Load_Unload_Press_G_Confirm;		
		pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_M:= 
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_M_Confirm;		
		pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_G:= 
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Up_Press_G_Confirm;						
		pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_M:= 
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_M_Confirm;		
		pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_G:=
			i_pastStTrapAxisParam_Gantray^[1,iN].lrposConfirm_Dn_Press_G_Confirm;	
			
		(*2026.01.30.141632 新增品字型柔印机-界面以及手轮显示处理 Hou.N*)
	IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
		afKS_FB_CalcuDisplayT_M[iN](
				i_xEn:=g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 , 
				i_rPrRoller_Girth:= g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller, 
				i_rNrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_NetRoller , 
				i_rBrnRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_BottomRoller  , 
				i_rFix_Horizontal_Edge_X:= g_arFix_RightEdge[iN], 
				i_lrCurPos_mm:=i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_M , 
				o_rHypotenuse=>pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_M );
				
	g_lrposM[iN]:=i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_M;
	g_rposM[iN]:=pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_M;
	
		afKS_FB_CalcuDisplayT_G[iN](
				i_xEn:=g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 , 
				i_rPrRoller_Girth:= g_stStSysParam.astStGrpParam_Save[1].rGirth_PrnRoller, 
				i_rNrRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_NetRoller , 
				i_rBrnRoller_Girth:=g_stStSysParam.astStGrpParam_Save[1].rGirth_BottomRoller  , 
				i_rFix_Horizontal_Edge_X:= g_arFix_RightEdge[iN], 
				i_lrCurPos_mm:=i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_G , 
				o_rHypotenuse=>pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_G);
				
	g_lrposG[iN]:=i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_G;
	g_rposG[iN]:=pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_G;
	
	ELSE
			pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_M:= LREAL_TO_REAL(i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_M);
			pstStUnitParam_UnSave^.rPos_PrnRoller_Pressure_G:= LREAL_TO_REAL(i_pastStTrapAxisParam_Gantray^[1,iN].lrCurPos_mm_G);
	END_IF
		//bai.zy | 2024.01.15.105513 | 合压位换版位标定完成标志			
		pstStUnitParam_Save^.xConfirmDnPosDne_PrnRoller_Pressure_M := i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmDnPosDne_Pressure_M;
		pstStUnitParam_Save^.xConfirmDnPosDne_PrnRoller_Pressure_G := i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmDnPosDne_Pressure_G;
		pstStUnitParam_Save^.xConfirmload_unloadPosDne_PrnRoller_Pressure_M := i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmload_unloadPosDne_Pressure_M;
		pstStUnitParam_Save^.xConfirmload_unloadPosDne_PrnRoller_Pressure_G := i_pastStTrapAxisParam_Gantray^[1,iN].xConfirmload_unloadPosDne_Pressure_G;

		
		//2024.10.21.121704
		IF  pstStUnitParam_UnSave^.xConfirmParallelPos_Prn THEN//平行确认按钮
			pstStUnitParam_Save^.axPressLimit_Min[1] := TRUE;
			pstStUnitParam_Save^.lrEncPosParallel_Prn_M:=i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosParallel_M;//平行编码器值
			pstStUnitParam_Save^.lrEncPosParallel_Prn_G:=i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosParallel_G;
			pstStUnitParam_UnSave^.xConfirmParallelPos_Prn := FALSE;
		END_IF     
		pstStUnitParam_UnSave^.rParallelError_Prn_MM := i_pastStTrapAxisParam_Gantray^[1,iN].lrParallelError_MM;                                                                                 
		pstStUnitParam_Save^.lrPrintPosOffsetDn_Prn_M:=i_pastStTrapAxisParam_Gantray^[1,iN].lrPrintPosOffsetDn_M;//合压偏移量
		pstStUnitParam_Save^.lrPrintPosOffsetDn_Prn_G:=i_pastStTrapAxisParam_Gantray^[1,iN].lrPrintPosOffsetDn_G;
		
		IF i_pastStTrapAxisParam_Gantray^[1,iN].xCalidPressLimit_Max(*pstStUnitParam^.axCalidPressLimit_Max[1]*) THEN
			pstStUnitParam_UnSave^.axCalidPressLimit_Max[1] := FALSE;
			pstStUnitParam_Save^.axPressLimit_Max[1] := TRUE;
			pstStUnitParam_Save^.lrEncPosLimit_Prn_M_Max := i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosLimit_M_Max ;
			pstStUnitParam_Save^.lrEncPosLimit_Prn_G_Max := i_pastStTrapAxisParam_Gantray^[1,iN].lrEncPosLimit_G_Max ;
		END_IF
	END_FOR
	
//4.网辊压力处理
	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);			
			IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.5 THEN
				i_pastStTrapAxisParam_Gantray^[2,iN].xMove_To_Load_Unload:= FALSE;//品字形柔印机将离压位用作换版位
			ELSE
				;
			END_IF
		i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_M_Confirm:= 	
			pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_M;
		i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_G_Confirm:= 	
			pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_G;		
		i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_M_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_M;		
		i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_G_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_G;						
		i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_M;		
		i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G_Confirm:= 	
			pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_G;	
		
		//2024.10.21.121704
		i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmParallelPos:=pstStUnitParam_UnSave^.xConfirmParallelPos_Net ;//平行确认按钮
		i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosParallel_M := pstStUnitParam_Save^.lrEncPosParallel_Net_M ;
		i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosParallel_G := pstStUnitParam_Save^.lrEncPosParallel_Net_G ;
																								  
		i_pastStTrapAxisParam_Gantray^[2,iN].lrPrintPosOffsetDn_M:=pstStUnitParam_Save^.lrPrintPosOffsetDn_Net_M;//合压偏移量
		i_pastStTrapAxisParam_Gantray^[2,iN].lrPrintPosOffsetDn_G:=pstStUnitParam_Save^.lrPrintPosOffsetDn_Net_G;
		
		//2024.12.03.162342 | 增加调试阶段的压力运动
		i_pastStTrapAxisParam_Gantray^[2,iN].xCalidPressLimit_Max:=pstStUnitParam_UnSave^.axCalidPressLimit_Max[2] ;//平行确认按钮
		i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosLimit_M_Max := pstStUnitParam_Save^.lrEncPosLimit_Net_M_Max ;
		i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosLimit_G_Max := pstStUnitParam_Save^.lrEncPosLimit_Net_G_Max ;		
		
		//bai.zy | 2024.01.15.105513 | 合压位换版位标定完成标志
		i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmDnPosDne_Pressure_M := pstStUnitParam_Save^.xConfirmDnPosDne_NetRoller_Pressure_M;
		i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmDnPosDne_Pressure_G := pstStUnitParam_Save^.xConfirmDnPosDne_NetRoller_Pressure_G;	
		i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmload_unloadPosDne_Pressure_M := pstStUnitParam_Save^.xConfirmload_unloadPosDne_NetRoller_Pressure_M;
		i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmload_unloadPosDne_Pressure_G := pstStUnitParam_Save^.xConfirmload_unloadPosDne_NetRoller_Pressure_G;
			
		//如果版辊周长变了/料膜厚度变了2023.12.27.171307
		IF (pstStGrpParam_Save^.rFilmThick_Confirm<>pstStGrpParam_Save^.rFilmThickNess_Using AND
			pstStGrpParam_Save^.rFilmThick_Confirm<>0 AND pstStGrpParam_Save^.rFilmThickNess_Using<>0) OR
			pstStUnitParam_Save^.rGirth_Confirmed_press_dn_NetRoller<>pstStUnitParam_Save^.rGirth_NetRoller OR
			pstStUnitParam_Save^.rGirth_Confirmed_press_dn_PrnRoller<>pstStUnitParam_Save^.rGirth_PrnRoller OR
			rGirth_PrnRoller_Mem <> pstStGrpParam_Save^.rGirth_PrnRoller THEN
			//处理一下位置更新2023.12.27.171801
			lrTemp:= g_rPos_press_dn_NetRoller_Pressure_MM*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(pstStUnitParam_Save^.uiNum_NetRoller_Pressure)/
						pstStUnitParam_Save^.rScrewPitch_NetRoller_Pressure/
						UINT_TO_REAL(pstStUnitParam_Save^.uiDen_NetRoller_Pressure);	
										
			IF i_pastStTrapAxisParam_Gantray^[2,iN].xRev_Motor_M THEN
	
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M_Confirm-
						((
						(pstStGrpParam_Save^.rFilmThick_Manu-pstStGrpParam_Save^.rFilmThick_Confirm))*
						UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_NetRoller_Pressure)*GC_LRMOTORPPR_TRAP/
						UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_NetRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_NetRoller_Pressure);
		
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_M:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M-lrTemp;	
			ELSE

					i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M_Confirm+
						((
						(pstStGrpParam_Save^.rFilmThick_Manu-pstStGrpParam_Save^.rFilmThick_Confirm))*
						UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_NetRoller_Pressure)*GC_LRMOTORPPR_TRAP/
						UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_NetRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_NetRoller_Pressure);
										
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_M:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M+lrTemp;		
			END_IF	
			IF i_pastStTrapAxisParam_Gantray^[2,iN].xRev_Motor_G THEN
				
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G_Confirm-
						(((*(i_pastStTrapAxisParam_Gantray^[2,iN].rweigth_Zero-
						i_pastStTrapAxisParam_Gantray^[2,iN].rweigth_Zero_Confirm)+*)
						(pstStGrpParam_Save^.rFilmThickNess_Using-pstStGrpParam_Save^.rFilmThick_Confirm))*
						UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_NetRoller_Pressure)*GC_LRMOTORPPR_TRAP/
						UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_NetRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_NetRoller_Pressure);			
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_G:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G-lrTemp;
			ELSE
				
					i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G_Confirm+
							(((i_pastStTrapAxisParam_Gantray^[2,iN].rweigth_Zero-
							i_pastStTrapAxisParam_Gantray^[2,iN].rweigth_Zero_Confirm)+
							(pstStGrpParam_Save^.rFilmThick_Manu-pstStGrpParam_Save^.rFilmThick_Confirm))*
							UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_NetRoller_Pressure)*GC_LRMOTORPPR_TRAP/
							UINT_TO_LREAL(pstStUnitParam_Save^.uiDen_NetRoller_Pressure)/pstStUnitParam_Save^.rScrewPitch_NetRoller_Pressure);
	
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_G:= i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G+lrTemp;	
			END_IF	
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_M:= //换版位的物理位置是不变的2023.12.13.081145
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_M_Confirm;
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_G:= 
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_G_Confirm;
		ELSE
			//bai.zy | 2024.03.21.130939 | 增加印刷位
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M:= 	
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M_Confirm;	
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G:= 	
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G_Confirm;
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_M:= 	
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_M_Confirm;	
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_G:= 	
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_G_Confirm;	
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_M:= //换版位的物理位置是不变的2023.12.13.081145
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_M_Confirm;
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_G:= 
				i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_G_Confirm;
			
		END_IF
	//2026.02.07.160105 计算网辊步进量
		
		afbKS_FB_GantryTrap_Calc_TargetPos_Net[iN](
			i_xEn:= TRUE, 
			i_uiNum:= pstStUnitParam_Save^.uiNum_NetRoller_Pressure, 
			i_uiDen:= pstStUnitParam_Save^.uiDen_NetRoller_Pressure, 
			i_rScrewPitch:= pstStUnitParam_Save^.rScrewPitch_NetRoller_Pressure, 
			i_rUp_Dn_Length:= g_rPos_press_dn_NetRoller_Pressure_MM,//1.35, //3mm			
			i_rGirth_Roller:= pstStUnitParam_Save^.rGirth_NetRoller, 
			i_xStopOrEstop_Valid:= xNeedMoveUp_Stop_Net,
			i_prGirth_Confirm:= ADR(pstStUnitParam_Save^.rGirth_Confirmed_press_dn_NetRoller), 
			i_xFlag_Print:= pstStGrpParam_UnSave^.xFlag_Print, 
			i_xStep_Fast:= pstStUnitParam_Save^.wFlag_PressFun.2,//^.xStep_Fast,  
			i_rStep_Fast:= pstStGrpParam_Save^.rStep_Fast, 
			i_rStep_Little:= pstStGrpParam_Save^.rStep_Little, 
			i_rVel_Fast:= pstStGrpParam_Save^.rVel_Press_Net,// 
			i_rVel_Little:= 0.1, 
			i_plrTargetPos_All:= ADR(alrTargetPos_Net[iN]), 
			i_plrTargetPos_M:= ADR(alrTargetPos_Net_M[iN]), 
			i_plrTargetPos_G:= ADR(alrTargetPos_Net_G[iN]), 
			i_pstStTrapAxisParam_Gantray:= ADR(i_pastStTrapAxisParam_Gantray^[2,iN]), 
			i_xFlag_Estop:= i_xFlag_Estop,
			//i_rStep_HMI:= pstStUnitParam^.rStep_Pressure_Prn_Net,//2023.12.22.220303
			//i_rDistanceForAvoidPrnGear := 0,
			i_pxFinishConfirm_Adjust_PressDn := ADR(axFinishConfirm_Adjust_PressDn[iN]),//: POINTER TO BOOL;
			i_rStep_HMI_Use:=pstStUnitParam_Save^.rStep_Pressure_Prn_Net,
			i_rProportion:=1.0,
			i_xMove_to_Up_Estop := pstStGrpParam_Save^.wCtl_Pressure_Up_Dn.1,
			i_ReqResetEstop := i_ReqResetEstop,
			i_rMaxErr := rMaxErr,
			o_xEn=> , 
			o_rVel=> o_arVel_Net[iN], 
			o_lrTargetPos_All=> o_alrTargetPos_Net[iN], 
			o_lrTargetPos_M=> o_alrTargetPos_Net_M[iN], 
			o_lrTargetPos_G=> o_alrTargetPos_Net_G[iN],
			o_lrTemp_Len_Up_Pos=>alrTemp_Len_Up_Pos_Net[iN],
			o_lrTemp_Len_Load_Unload_Pos=>alrTemp_Len_Load_Unload_Pos_Net[iN]);
			
		pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_M:=
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_M_Confirm;
		pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_G:= 
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Load_Unload_Press_G_Confirm;		
		pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_M:= 
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_M_Confirm;		
		pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_G:= 
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Up_Press_G_Confirm;						
		pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_M:= 
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_M_Confirm;		
		pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_G:=
			i_pastStTrapAxisParam_Gantray^[2,iN].lrposConfirm_Dn_Press_G_Confirm;	
		pstStUnitParam_UnSave^.rPos_NetRoller_Pressure_M:= LREAL_TO_REAL(i_pastStTrapAxisParam_Gantray^[2,iN].lrCurPos_mm_M);
		pstStUnitParam_UnSave^.rPos_NetRoller_Pressure_G:= LREAL_TO_REAL(i_pastStTrapAxisParam_Gantray^[2,iN].lrCurPos_mm_G);
		
		//bai.zy | 2024.01.15.105513 | 合压位换版位标定完成标志
		pstStUnitParam_Save^.xConfirmDnPosDne_NetRoller_Pressure_M := i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmDnPosDne_Pressure_M;
		pstStUnitParam_Save^.xConfirmDnPosDne_NetRoller_Pressure_G := i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmDnPosDne_Pressure_G;
		pstStUnitParam_Save^.xConfirmload_unloadPosDne_NetRoller_Pressure_M := i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmload_unloadPosDne_Pressure_M;
		pstStUnitParam_Save^.xConfirmload_unloadPosDne_NetRoller_Pressure_G := i_pastStTrapAxisParam_Gantray^[2,iN].xConfirmload_unloadPosDne_Pressure_G;
		
		//2024.10.21.121704
		IF pstStUnitParam_UnSave^.xConfirmParallelPos_Net THEN//平行确认按钮
			pstStUnitParam_Save^.axPressLimit_Min[2] := TRUE;
			pstStUnitParam_Save^.lrEncPosParallel_Net_M:=i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosParallel_M;//平行编码器值
			pstStUnitParam_Save^.lrEncPosParallel_Net_G:=i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosParallel_G;
			pstStUnitParam_UnSave^.xConfirmParallelPos_Net := FALSE;
		END_IF		
		pstStUnitParam_UnSave^.rParallelError_Net_MM := i_pastStTrapAxisParam_Gantray^[2,iN].lrParallelError_MM;															
		pstStUnitParam_Save^.lrPrintPosOffsetDn_Net_M:=i_pastStTrapAxisParam_Gantray^[2,iN].lrPrintPosOffsetDn_M;//合压偏移量
		pstStUnitParam_Save^.lrPrintPosOffsetDn_Net_G:=i_pastStTrapAxisParam_Gantray^[2,iN].lrPrintPosOffsetDn_G;
		
		IF pstStUnitParam_UnSave^.axCalidPressLimit_Max[2] THEN
			pstStUnitParam_UnSave^.axCalidPressLimit_Max[2] := FALSE;
			pstStUnitParam_Save^.axPressLimit_Max[2] := TRUE;
			pstStUnitParam_Save^.lrEncPosLimit_Net_M_Max := i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosLimit_M_Max ;
			pstStUnitParam_Save^.lrEncPosLimit_Net_G_Max := i_pastStTrapAxisParam_Gantray^[2,iN].lrEncPosLimit_G_Max ;
		END_IF			
		
	END_FOR	

	//版周长 














	rGirth_PrnRoller_Mem := pstStGrpParam_Save^.rGirth_PrnRoller;		//	秦华不需要了

	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
		IF axFlag_Mode_Calid[iN] THEN
			g_xModeCalibSwitch_Flag := TRUE;
			IF NOT i_xDebugMode THEN
				g_xModeCalibSwitch_Flag := FALSE;
			END_IF
			EXIT;
		ELSE
			g_xModeCalibSwitch_Flag := FALSE;
		END_IF
	END_FOR
	
	IF i_xDebugMode THEN
		FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);
			axTRIG_ResetFlag_FinishCalid[iN](CLK:=g_axResetFlag_FinishCalid[iN]);
			IF axTRIG_ResetFlag_FinishCalid[iN].Q THEN
				g_axResetFlag_FinishCalid[iN] := FALSE;
				
				pstStUnitParam_Save^.xConfirmDnPosDne_PrnRoller_Pressure_M:=FALSE;
				pstStUnitParam_Save^.xConfirmDnPosDne_PrnRoller_Pressure_G:=FALSE;
				pstStUnitParam_Save^.xConfirmDnPosDne_NetRoller_Pressure_M:=FALSE;
				pstStUnitParam_Save^.xConfirmDnPosDne_NetRoller_Pressure_G:=FALSE;
				pstStUnitParam_Save^.xConfirmload_unloadPosDne_PrnRoller_Pressure_M:=FALSE;
				pstStUnitParam_Save^.xConfirmload_unloadPosDne_PrnRoller_Pressure_G:=FALSE;
				pstStUnitParam_Save^.xConfirmload_unloadPosDne_NetRoller_Pressure_M:=FALSE;
				pstStUnitParam_Save^.xConfirmload_unloadPosDne_NetRoller_Pressure_G:=FALSE;
				
				pstStUnitParam_Save^.xConfirmDnPosDne_StrRoller_Pressure_M:=FALSE;
				pstStUnitParam_Save^.xConfirmDnPosDne_StrRoller_Pressure_G:=FALSE;
				//印版
				pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_M := 0;//换版位
				pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_G := 0;
				pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_M := 0;//离压位
				pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_G := 0;
				pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_M := 0;//合压位
				pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_G := 0;
				pstStUnitParam_Save^.liABSPos_Prn_M := 0;
				pstStUnitParam_Save^.liABSPos_Prn_G := 0;
				//网辊
				pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_M := 0;//换版位
				pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_G := 0;
				pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_M := 0;//离压位
				pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_G := 0;
				pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_M := 0;//合压位
				pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_G := 0;
				pstStUnitParam_Save^.liABSPos_Net_M := 0;
				pstStUnitParam_Save^.liABSPos_Net_G := 0;
				//张带
				pstStUnitParam_Save^.rPos_load_unload_StrRoller_Pressure_M := 0;//换版位
				pstStUnitParam_Save^.rPos_load_unload_StrRoller_Pressure_G := 0;
				pstStUnitParam_Save^.rPos_press_up_StrRoller_Pressure_M := 0;//离压位
				pstStUnitParam_Save^.rPos_press_up_StrRoller_Pressure_G := 0;
				pstStUnitParam_Save^.rPos_press_dn_StrRoller_Pressure_M := 0;//合压位
				pstStUnitParam_Save^.rPos_press_dn_StrRoller_Pressure_G := 0;
				pstStUnitParam_Save^.liABSPos_Str_M := 0;
				pstStUnitParam_Save^.liABSPos_Str_G := 0;
				
				
				FOR iM := 1 TO gc_iMax_PressureRoller_Unit BY 1 DO
					aitargetStation[2*iM-1] := (i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_M);
					aitargetStation[2*iM] := (i_pastStTrapAxisParam_Gantray^[iM,iN].iStationId_G);
					aliABSEncPos[2*iM-1] := 0;
					aliABSEncPos[2*iM] := 0;
				END_FOR
				//iRtn := GT_RN_SetTrapCoordinate(targetNum:= INT_TO_BYTE(gc_iMax_PressureRoller_Unit*2), targetStation:= ADR(abytargetStation), targetAxis:= ADR(aliABSEncPos));

				axAxisRev[1]:= i_pastStTrapAxisParam_Gantray^[1,iN].xRev_Motor_M;
				axAxisRev[2]:= i_pastStTrapAxisParam_Gantray^[1,iN].xRev_Motor_G;
				axAxisRev[3]:= i_pastStTrapAxisParam_Gantray^[2,iN].xRev_Motor_M;
				axAxisRev[4]:= i_pastStTrapAxisParam_Gantray^[2,iN].xRev_Motor_G;
				axAxisRev[5]:= i_pastStTrapAxisParam_Gantray^[3,iN].xRev_Motor_M;
				axAxisRev[6]:= i_pastStTrapAxisParam_Gantray^[3,iN].xRev_Motor_G;
				
				iRtn := KS_SetTrapCoordinate(
						i_xEn:= TRUE, 
						i_iTarget_Num:= INT_TO_BYTE(gc_iMax_PressureRoller_Unit*2), 
						i_paiTargetStationList:= ADR(aitargetStation), 
						i_paliABSEncPos:= ADR(aliABSEncPos), 
						i_paxAxisRev:= ADR(axAxisRev), 
						i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
						i_pastStGetMotionSts:= i_pastStGetMotionSts,
						i_pstStSysStationInf := i_pstStSysStationInf,
						i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
						ADR(g_alrCurrentAbsPos_Debug));

			END_IF
		END_FOR
	END_IF
	
(*
	FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);
		//印刷过程中矫正合压位是否要重新清零清规划？？？？
		//矫正后更新当前参数值
		//2025.08.28.152652 | 矫正增加对于压力电机的位置判断，之前做过判断，但是不再范围内的位置还是被矫正了，这里再次判断一下
		IF axFinishConfirm_Adjust_PressDn[iN] AND
			pstStUnitParam_Save^.xLinkage AND
			(i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_M = 1 OR
			i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_M = 2 OR
			i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_M = 3 ) AND
			(i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_G = 1 OR
			i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_G = 2 OR
			i_pastStTrapAxisParam_Gantray^[1,iN].byCurPos_G = 3 ) AND
			(i_pastStTrapAxisParam_Gantray^[2,iN].byCurPos_M = 1 OR
			i_pastStTrapAxisParam_Gantray^[2,iN].byCurPos_M = 2 OR
			i_pastStTrapAxisParam_Gantray^[2,iN].byCurPos_M = 3 ) AND
			(i_pastStTrapAxisParam_Gantray^[2,iN].byCurPos_G = 1 OR
			i_pastStTrapAxisParam_Gantray^[2,iN].byCurPos_G = 2 OR
			i_pastStTrapAxisParam_Gantray^[2,iN].byCurPos_G = 3 ) THEN
			
			axFinishConfirm_Adjust_PressDn[iN] := FALSE;
			
			alrTemp_Len_Up_Pos_Prn[iN] := g_rPos_press_dn_PrnRoller_Pressure_MM(*i_pstStSysParam^.rPos_press_dn_PrnRoller_Pressure_MM*)*
										pstStUnitParam_Save^.uiNum_PrnRoller_Pressure*GC_LRMOTORPPR_TRAP/
										pstStUnitParam_Save^.uiDen_PrnRoller_Pressure/pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure;
			alrTemp_Len_Load_Unload_Pos_Prn[iN] :=g_rPos_press_dn_PrnRoller_Pressure_MM(*i_pstStSysParam^.rPos_load_unload_PrnRoller_Pressure_MM*)*
										pstStUnitParam_Save^.uiNum_PrnRoller_Pressure*GC_LRMOTORPPR_TRAP/
										pstStUnitParam_Save^.uiDen_PrnRoller_Pressure/pstStUnitParam_Save^.rScrewPitch_PrnRoller_Pressure;
			//印版
			iRtn := GTN_RN_GetAxisAbsPosEx(cardNum:= 1, axis:= 1, pPos:= ADR(g_liAbsPos_M), stationId:= i_pastStTrapAxisParam_Gantray^[1,iN].iStationId_M);
			iRtn := GTN_RN_GetAxisAbsPosEx(cardNum:= 1, axis:= 1, pPos:= ADR(g_liAbsPos_G), stationId:= i_pastStTrapAxisParam_Gantray^[1,iN].iStationId_G);
			pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_M:= 1;//LINT_TO_LREAL(g_liAbsPos_M);
			pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_G:= 1;//LINT_TO_LREAL(g_liAbsPos_G);
			pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_M:= pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_M + alrTemp_Len_Up_Pos_Prn[iN];//1;//LINT_TO_LREAL(g_liAbsPos_M);
			pstStUnitParam_Save^.rPos_press_up_PrnRoller_Pressure_G:= pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_G + alrTemp_Len_Up_Pos_Prn[iN];//1;//LINT_TO_LREAL(g_liAbsPos_G);
			pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_M:= pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_M + alrTemp_Len_Load_Unload_Pos_Prn[iN];//1;//LINT_TO_LREAL(g_liAbsPos_M);
			pstStUnitParam_Save^.rPos_load_unload_PrnRoller_Pressure_G:= pstStUnitParam_Save^.rPos_press_dn_PrnRoller_Pressure_G + alrTemp_Len_Load_Unload_Pos_Prn[iN];//1;//LINT_TO_LREAL(g_liAbsPos_G);
			iRtn := GT_RN_SetTrapCoordinate(targetNum:=1 , targetStation:=ADR(i_pastStTrapAxisParam_Gantray^[1,iN].iStationId_M),targetAxis:= ADR(g_liAbsPos_M));
			iRtn := GT_RN_SetTrapCoordinate(targetNum:=1 , targetStation:=ADR(i_pastStTrapAxisParam_Gantray^[1,iN].iStationId_G),targetAxis:= ADR(g_liAbsPos_G));
			pstStUnitParam_Save^.liABSPos_Prn_M := g_liAbsPos_M;
			pstStUnitParam_Save^.liABSPos_Prn_G := g_liAbsPos_G;
			//网辊			
			iRtn := GTN_RN_GetAxisAbsPosEx(cardNum:= 1, axis:= 1, pPos:= ADR(g_liAbsPos_M), stationId:= i_pastStTrapAxisParam_Gantray^[2,iN].iStationId_M);
			iRtn := GTN_RN_GetAxisAbsPosEx(cardNum:= 1, axis:= 1, pPos:= ADR(g_liAbsPos_G), stationId:= i_pastStTrapAxisParam_Gantray^[2,iN].iStationId_G);
			pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_M:= 1;//LINT_TO_LREAL(g_liAbsPos_M);
			pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_G:= 1;//LINT_TO_LREAL(g_liAbsPos_G);
			pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_M:= pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_M + alrTemp_Len_Up_Pos_Net[iN];//1;//LINT_TO_LREAL(g_liAbsPos_M);
			pstStUnitParam_Save^.rPos_press_up_NetRoller_Pressure_G:= pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_G + alrTemp_Len_Up_Pos_Net[iN];//1;//LINT_TO_LREAL(g_liAbsPos_G);
			pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_M:= pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_M + alrTemp_Len_Load_Unload_Pos_Net[iN];//1;//LINT_TO_LREAL(g_liAbsPos_M);
			pstStUnitParam_Save^.rPos_load_unload_NetRoller_Pressure_G:= pstStUnitParam_Save^.rPos_press_dn_NetRoller_Pressure_G + alrTemp_Len_Load_Unload_Pos_Net[iN];//1;//LINT_TO_LREAL(g_liAbsPos_G);
			iRtn := GT_RN_SetTrapCoordinate(targetNum:=1 , targetStation:=ADR(i_pastStTrapAxisParam_Gantray^[2,iN].iStationId_M),targetAxis:= ADR(g_liAbsPos_M));
			iRtn := GT_RN_SetTrapCoordinate(targetNum:=1 , targetStation:=ADR(i_pastStTrapAxisParam_Gantray^[2,iN].iStationId_G),targetAxis:= ADR(g_liAbsPos_G));
			pstStUnitParam_Save^.liABSPos_Net_M := g_liAbsPos_M;
			pstStUnitParam_Save^.liABSPos_Net_G := g_liAbsPos_G;

		END_IF
	END_FOR
*)
IF xtest4 THEN
	xtest4:=FALSE;
	iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  113, encoder:= 1, pPos:= ADR(lrAbsPos1));
	iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  129, encoder:= 1, pPos:= ADR(lrAbsPos2));
	iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  145, encoder:= 1, pPos:= ADR(lrAbsPos3));
	iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  161, encoder:= 1, pPos:= ADR(lrAbsPos4));
END_IF

// iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  114, encoder:= 1, pPos:= ADR(lrAbsPos2));
// iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  115, encoder:= 1, pPos:= ADR(lrAbsPos3));
 //iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  116, encoder:= 1, pPos:= ADR(lrAbsPos4));
// 
// iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  129, encoder:= 1, pPos:= ADR(lrAbsPos5));
//  iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  130, encoder:= 1, pPos:= ADR(lrAbsPos6));
//  iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  131, encoder:= 1, pPos:= ADR(lrAbsPos7));
 // iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=  132, encoder:= 1, pPos:= ADR(lrAbsPos8));


END_IF

