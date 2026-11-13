(*@CES
Name=KS_FB_AlarmDisList
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9df2daeb-e031-42e6-924b-50f6708c13fd
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AlarmDisList
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId : INT;(*系ID*)
	i_iUnitNum:INT;	
	i_pstStSysParam								: POINTER TO StSysParam;(*机器参数|*)
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
	i_pstStIOMap_Uw: POINTER TO StIOMap_UwRw_FE; (* 放料io|分A/B系 *)
	i_pstStIOMap_Rw: POINTER TO StIOMap_UwRw_FE; (* 收料io|分A/B系 *)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
END_VAR
VAR
	iN : INT;
	iM : INT;
	iRtn : INT;
	iCustomerName: INT;
	afbRTrig_Estop:ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;(*急停沿处理*)
	afbRTrig_Estop_UwRw:ARRAY [1..2] OF R_TRIG;(*收放料急停沿处理*)
	afbRTrig_Estop_IfOf:R_TRIG;(*收放料急停沿处理*)
	afbRTrig_PreStart: R_TRIG;(*预启动沿处理*)
	afbRTrig_Ink: R_TRIG;(*匀墨沿处理*)
	afbRTrig_Tension: R_TRIG;(*张力投入沿处理*)
	afbRTrig_Print: R_TRIG;(*印刷沿处理*)
	afbRTrig_Acc: R_TRIG;(*手动加速沿处理*)
	afbRTrig_Dec: R_TRIG;(*手动减速沿处理*)
	afbRTrig_Stop: R_TRIG;(*印刷沿处理*)
	xAxisInch_Print: BOOL;//点动2023.9.27.153613|收放牵|收放料|底辊|中心辊
	fbtrig_Inch_Print: R_TRIG;
	fbtrig_Inch_Stop: R_TRIG;
	fbtrig_Ink_Unit: R_TRIG;
	
	sAlarmMsg : STRING;
	sAlarmUnitId : STRING;
	iMsgId_Rec : INT := 1600;;
	iAlarmId_Rec : INT := 1600;
	iAlarm_TypeId_Rec : INT := 1600;
	
	afbRTrig_UnitPanel:ARRAY [1..MAX_UNIT_NUM,1..18] OF R_TRIG;(*收放料急停沿处理*)
	
	sAdjSts : STRING;
	sAlarmContent : STRING;
	(*2025.03.04.153303//网版电机开关沿处理*)
	afbtrig_NetMotorNo:ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbtrig_NetMotorOff:ARRAY [1..MAX_UNIT_NUM] OF F_TRIG;
	(*2025.03.04.153303//走纸点动沿处理*)
	afbtrig_JogPaperNo:ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbtrig_JogPaperOff:ARRAY [1..MAX_UNIT_NUM] OF F_TRIG;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND
		i_pstStSysParam <> 0 AND
		i_pastStIOMap_Main_FE <> 0 AND
		i_pastStIOMap_Axis_FE <> 0 AND
		i_pstStIOMap_Uw <> 0 AND
		i_pstStIOMap_Rw <> 0 THEN
		
		//收放料急停
		afbRTrig_Estop_UwRw[1](CLK:=i_pstStIOMap_Uw^.i_xEstop);
		afbRTrig_Estop_UwRw[2](CLK:=i_pstStIOMap_Rw^.i_xEstop);
		
		IF afbRTrig_Estop_UwRw[1].Q THEN
			//2026.1.20.140626 | + | 增加打印测试流程
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'UW_EStop!', BOOL_TO_STRING(TRUE));
		END_IF
		IF afbRTrig_Estop_UwRw[2].Q THEN
			//2026.1.20.140626 | + | 增加打印测试流程
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'RW_EStop!', BOOL_TO_STRING(TRUE));
		END_IF
		//牵引、界面急停
		afbRTrig_Estop_IfOf(CLK:=i_pastStIOMap_Main_FE^[1].i_xEstop OR i_pastStIOMap_Main_FE^[2].i_xEstop OR i_pastStIOMap_Main_FE^[3].i_xEstop OR i_pastStIOMap_Main_FE^[4].i_xEstop);
		IF afbRTrig_Estop_IfOf.Q THEN
			//2026.1.20.140626 | + | 增加打印测试流程
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_EStop!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//预启动
		afbRTrig_PreStart(CLK:=i_pastStIOMap_Main_FE^[1].i_xPreStart OR i_pastStIOMap_Main_FE^[2].i_xPreStart OR i_pastStIOMap_Main_FE^[3].i_xPreStart OR i_pastStIOMap_Main_FE^[4].i_xPreStart);
		IF afbRTrig_PreStart.Q THEN
			//2026.1.20.140626 | + | 增加打印测试流程
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_PreStart!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//匀墨
		afbRTrig_Ink(CLK:=i_pastStIOMap_Main_FE^[1].i_xInk OR i_pastStIOMap_Main_FE^[2].i_xInk OR i_pastStIOMap_Main_FE^[3].i_xInk OR i_pastStIOMap_Main_FE^[4].i_xInk);
		IF afbRTrig_Ink.Q THEN
			//2026.1.20.140626 | + | 增加打印测试流程
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_Ink!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//张力投入
		afbRTrig_Tension(CLK:=i_pastStIOMap_Main_FE^[1].i_xTension OR i_pastStIOMap_Main_FE^[2].i_xTension OR i_pastStIOMap_Main_FE^[3].i_xTension OR i_pastStIOMap_Main_FE^[4].i_xTension);
		IF afbRTrig_Tension.Q THEN
			//2026.1.20.140626 | + | 增加打印测试流程
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_Tension!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//印刷
		afbRTrig_Print(CLK:=i_pastStIOMap_Main_FE^[1].i_xPrint OR i_pastStIOMap_Main_FE^[2].i_xPrint OR i_pastStIOMap_Main_FE^[3].i_xPrint OR i_pastStIOMap_Main_FE^[4].i_xPrint);
		IF afbRTrig_Print.Q THEN
			//2026.1.20.140626 | + | 增加打印测试流程
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_Print!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//加速
		afbRTrig_Acc(CLK:=i_pastStIOMap_Main_FE^[1].i_xAcc OR i_pastStIOMap_Main_FE^[2].i_xAcc OR i_pastStIOMap_Main_FE^[3].i_xAcc OR i_pastStIOMap_Main_FE^[4].i_xAcc);
		IF afbRTrig_Acc.Q THEN
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_Acc!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//减速
		afbRTrig_Dec(CLK:=i_pastStIOMap_Main_FE^[1].i_xDec OR i_pastStIOMap_Main_FE^[2].i_xDec OR i_pastStIOMap_Main_FE^[3].i_xDec OR i_pastStIOMap_Main_FE^[4].i_xDec);
		IF afbRTrig_Dec.Q THEN
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_Dec!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//停止
		afbRTrig_Stop(CLK:=i_pastStIOMap_Main_FE^[1].i_xStop OR i_pastStIOMap_Main_FE^[2].i_xStop OR i_pastStIOMap_Main_FE^[3].i_xStop OR i_pastStIOMap_Main_FE^[4].i_xStop);
		IF afbRTrig_Stop.Q THEN
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'IFOF_Stop!', BOOL_TO_STRING(TRUE));
		END_IF
		
		//色组急停
		FOR iN:= 1 TO i_iUnitNum BY 1 DO
			//pstStUnitParam := ADR(i_pstStSysParam^.astStUnitParam[iN]);
			afbRTrig_Estop[iN](CLK:= i_pastStIOMap_Axis_FE^[iN].i_xEstop);
			IF afbRTrig_Estop[iN].Q THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'EStop Unit: ', INT_TO_STRING(iN));
			END_IF

			afbtrig_JogPaperNo[iN](CLK:= i_pastStIOMap_Axis_FE^[iN].i_xJogPaper);
			afbtrig_JogPaperOff[iN](CLK:= i_pastStIOMap_Axis_FE^[iN].i_xJogPaper);

			//走纸点动开关
			IF afbtrig_JogPaperNo[iN].Q THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'JogPaperOn Unit: ', INT_TO_STRING(iN));
			END_IF
		
			IF afbtrig_JogPaperOff[iN].Q THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'JogPaperOff Unit: ', INT_TO_STRING(iN));
			END_IF
		END_FOR	
		
		IF iMsgId_Rec <> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iPromptMsg OR iAlarm_TypeId_Rec <> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_TypeId OR 
			iAlarmId_Rec <> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_UnitId THEN
		
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'iPromptMsg: ', INT_TO_STRING(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iPromptMsg));
			//KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'iAlarm_TypeId: ', INT_TO_STRING(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_TypeId));
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'iAlarm_UnitId: ', INT_TO_STRING(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_UnitId));
		END_IF
		iMsgId_Rec := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iPromptMsg;
		iAlarmId_Rec := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_UnitId;
		iAlarm_TypeId_Rec := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iAlarm_TypeId;
		
		//2025.01.04.111645 | 空转
		fbtrig_Ink_Unit(CLK:=g_axInk_Unit[1]);
		IF fbtrig_Ink_Unit.Q THEN
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'Ink!', BOOL_TO_STRING(TRUE));
		END_IF
	END_IF
END_IF