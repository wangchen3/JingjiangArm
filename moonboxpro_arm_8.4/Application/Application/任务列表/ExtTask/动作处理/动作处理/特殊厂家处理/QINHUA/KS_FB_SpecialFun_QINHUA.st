(*@CES
Name=KS_FB_SpecialFun_QINHUA
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b0fd8d6e-5e31-4c12-93b4-a3bf1f0ab9df
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpecialFun_QINHUA
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
	i_pastStInteraction : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StInteraction;
	i_pstStEvtReq: POINTER TO StEvtReq;(* 动作提取 *)	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN : INT;
	iRtn : INT;
	
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	xNeedPrint:BOOL;
	xNeedInk:BOOL;
	xStateChange:BOOL;
	
	xFlag_Ink_to_stop: BOOL;
	xFlag_Stop_to_Print: BOOL;
	fbtrig_Inch_Print: R_TRIG;
	fbtrig_Inch_Stop: R_TRIG;
	xFlag_Print_to_stop: BOOL;
	xUnitHaveAxisInch : BOOL;
	xAxisInch_Print: BOOL;//点动2023.9.27.153613|收放牵|收放料|底辊|中心辊
	
	//2026.1.9.110731| zhang.hz | 秦华增加印后牵引的压力传感器
	wAnalogSignals_OF_PrintingOut : WORD;	
	lrN_min: LREAL;
	lrN_max: LREAL;
	diN_min: DINT;
	diN_max: DINT;	
	wAnalogSignals_OF : WORD;	

	fbTRIG_InkStop: r_trig;
	
	iAxisId : INT;
	iTypeId: INT;
	iUnitId : INT;
	iCoreId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	
	alrPos_Prf_Aux_Back : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	aiCount : ARRAY [1..MAX_UNIT_NUM] OF INT;
	iCnt_Rel_Press_1U : INT;
	rSlopeAboutPress: REAL;
	lrAnalogInput_Pressure: LREAL;
	lrAnalogMiddle: LREAL;
	lrAnalogDifference:LREAL;	
END_VAR
{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND i_pastStIOMap_Main_FE <> 0 AND i_pastStIOMap_Axis_FE <> 0 AND 
		i_pstStSysStationInf<>0 AND i_pastStGetMotionSts <> 0 THEN
		
		pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
	
		pstStGrpParam_Save^.rGirth_PrnRoller := pstStGrpParam_Save^.rLength_Band_Confirm;
		
		FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
			i_pstStSysParam^.astStUnitParam_Save[iN].rGirth_PrnRoller := pstStGrpParam_Save^.rLength_Band_Confirm;
		END_FOR
		
		//2026.1.6.104544 | + 一色压辊处理
		IF i_pastStIOMap_Axis_FE^[1].i_xPress THEN
			i_pastStIOMap_Axis_FE^[1].o_xRel_Press := TRUE;
		ELSIF ((NOT i_pastStIOMap_Axis_FE^[1].i_xPress) AND (NOT i_pastStIOMap_Axis_FE^[1].i_xPressMode_Auto)) OR  pstStGrpParam_UnSave^.xFlag_Estop THEN
			i_pastStIOMap_Axis_FE^[1].o_xRel_Press := FALSE;
		ELSE
			//压辊自动
			IF  pstStGrpParam_UnSave^.xFlag_Print  THEN
				IF i_pastStIOMap_Main_FE^[1].o_xRel_Press_IF AND i_pastStIOMap_Main_FE^[2].o_xRel_Press_OF THEN
					//2026.1.14.172552 | + | 收放牵压辊10秒后压一色压辊
					iCnt_Rel_Press_1U := iCnt_Rel_Press_1U + 1;
					IF iCnt_Rel_Press_1U > 10.0*1000/gc_EXT_TSK_CYCLE_TIME THEN
						i_pastStIOMap_Axis_FE^[1].o_xRel_Press := TRUE;
						iCnt_Rel_Press_1U := iCnt_Rel_Press_1U - 1;
					END_IF
				ELSE
					iCnt_Rel_Press_1U := 0;
				END_IF
			ELSE
				iCnt_Rel_Press_1U := 0;
			END_IF
		END_IF
		
		FOR iN := 2 TO i_iGrpUnitNum_Pu BY 1 DO
			i_pastStIOMap_Axis_FE^[iN].o_xRel_Press := TRUE;
		END_FOR
		
		//2024.12.30.100717 | 空转一色抬压辊
		IF 	pstStGrpParam_UnSave^.xFlag_Ink OR pstStGrpParam_UnSave^.xFlag_Home OR pstStGrpParam_UnSave^.xFlag_PreRegister OR pstStGrpParam_UnSave^.xFlag_PhaseRestore OR pstStGrpParam_UnSave^.xFlag_PhaseRead THEN
			i_pastStIOMap_Axis_FE^[1].o_xRel_Press := FALSE;
		END_IF
		
		//2024.12.24.150101 | 停机状态下的纵向对版运动
		IF (NOT pstStGrpParam_UnSave^.xFlag_Print) THEN
			FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
				g_axMoveUp[iN] := i_pastStIOMap_Axis_FE^[iN].i_xMove_Up;
				g_axMoveDn[iN] := i_pastStIOMap_Axis_FE^[iN].i_xMove_Down;
			END_FOR
		ELSE
			FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
				g_axMoveUp[iN] := FALSE;
				g_axMoveDn[iN] := FALSE;
			END_FOR
		END_IF
		
		
		FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO			
			i_pastStInteraction^[iN].i_xPressEngageSignal:= i_pastStIOMap_Axis_FE^[iN].i_xRsvd_DI0;
			i_pastStInteraction^[iN].i_xPressWarningSignal:= i_pastStIOMap_Axis_FE^[iN].i_xRsvd_DI1;
			i_pastStInteraction^[iN].i_xPressRetractionPositionSignal:= i_pastStIOMap_Axis_FE^[iN].i_xRsvd_DI2;
			i_pastStIOMap_Axis_FE^[iN].o_xRsvd_DO0:=i_pastStInteraction^[iN].o_xCoarseAdjStart;
			i_pastStIOMap_Axis_FE^[iN].o_xRsvd_DO1:=i_pastStInteraction^[iN].o_xCoarseAdjEnd;
			i_pastStIOMap_Axis_FE^[iN].o_xRsvd_DO2:=i_pastStInteraction^[iN].o_xUnitWarningSignal;
			
			IF i_pastStInteraction^[iN].i_xPressEngageSignal THEN
				i_pastStInteraction^[iN].o_xCoarseAdjEnd := FALSE;
			END_IF
			
			//2026.1.14.173759 | + | 处理停机状态下的色组交互信号
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop THEN
				i_pastStInteraction^[iN].o_xCoarseAdjStart := FALSE;
				i_pastStInteraction^[iN].o_xCoarseAdjEnd := FALSE;
			END_IF
			
			//2026.01.14.233501 | + | 增加标志保存到文件中进行分析
			g_abyInteractionCtl[iN].0 := i_pastStInteraction^[iN].i_xPressEngageSignal;
			g_abyInteractionCtl[iN].1 := i_pastStInteraction^[iN].i_xPressWarningSignal;
			g_abyInteractionCtl[iN].2 := i_pastStInteraction^[iN].i_xPressRetractionPositionSignal;
			g_abyInteractionCtl[iN].3 := i_pastStInteraction^[iN].o_xCoarseAdjStart;
			g_abyInteractionCtl[iN].4 := i_pastStInteraction^[iN].o_xCoarseAdjEnd;
			g_abyInteractionCtl[iN].5 := i_pastStInteraction^[iN].o_xUnitWarningSignal;
			
		END_FOR
		
		(*2025.12.29.115248+ | 张力控制交互信号DO*)
		i_pastStIOMap_Main_FE^[1].o_xRsvd_DO0 := i_pastStIOMap_Main_FE^[1].o_xLamp_Print;//整机启动信号
		i_pastStIOMap_Main_FE^[1].o_xRsvd_DO1 := i_pastStIOMap_Main_FE^[1].o_xLamp_Stop;//整机停机信号
		i_pastStIOMap_Main_FE^[1].o_xRsvd_DO2 := i_pastStIOMap_Main_FE^[1].o_xLamp_Estop;//整机急停信号
		i_pastStIOMap_Main_FE^[1].o_xRsvd_DO3 := i_pastStIOMap_Axis_FE^[1].o_xRel_Press;//一色胶辊合压信号
		i_pastStIOMap_Main_FE^[1].o_xRsvd_DO4 := i_pastStIOMap_Main_FE^[1].o_xRel_Press_IF;//放牵合压信号
		i_pastStIOMap_Main_FE^[1].o_xRsvd_DO5 := i_pastStIOMap_Main_FE^[2].o_xRel_Press_OF;//收牵合压信号	
		
		//走纸点动
		xUnitHaveAxisInch := FALSE;
		FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
			IF i_pastStIOMap_Axis_FE^[iN].i_xJogPaper THEN
				xUnitHaveAxisInch := TRUE;
				EXIT;
			END_IF
		END_FOR
	 
	
		xAxisInch_Print:= ((*i_pstStIOMap_Main_FLEXO^.i_xRsvd_DI3*)xUnitHaveAxisInch  AND (NOT pstStGrpParam_UnSave^.xFlag_Estop));(* OR
							g_xAxisInch_Print;*)
		IF xAxisInch_Print THEN
			g_xFlag_AxisInch_Print := TRUE;
		ELSIF (NOT xAxisInch_Print) AND pstStGrpParam_UnSave^.rVel_Film = 0 THEN
			g_xFlag_AxisInch_Print := FALSE;
		END_IF
//处理一些流程问题
		fbtrig_Inch_Print(CLK:= xAxisInch_Print);
		fbtrig_Inch_Stop(CLK:= NOT xAxisInch_Print);
		IF fbtrig_Inch_Print.Q THEN
			i_pstStEvtReq^.xReqPrint:= TRUE;
		END_IF
		IF fbtrig_Inch_Stop.Q THEN
			i_pstStEvtReq^.xReqStop:= TRUE;
		END_IF
		
		
		IF pstStGrpParam_UnSave^.xFlag_Stop AND (NOT xFlag_Stop_to_Print) AND (NOT xFlag_Ink_to_stop) THEN
	//停机状态下如果触发了一个匀墨按钮就进入断料空转档位，其他色组直接触发使能挂靠
			FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
				IF g_axInk_Unit[iN] AND i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
					i_pstStEvtReq^.xReqPrestart:= TRUE;
					i_pstStEvtReq^.xEvt_TapPosition_Breaking := TRUE;
					i_pstStEvtReq^.xEvt_TapPosition_Printing := FALSE;			
					
				END_IF
			END_FOR
		END_IF
		IF i_pstStEvtReq^.xReqPrint THEN
			IF pstStGrpParam_UnSave^.xFlag_Ink THEN
				i_pstStEvtReq^.xReqStop:= TRUE;
				xFlag_Ink_to_stop:= TRUE;
			ELSE
				xFlag_Stop_to_Print:= TRUE;
				i_pstStEvtReq^.xReqPrestart:= TRUE;
				i_pstStEvtReq^.xEvt_TapPosition_Printing := TRUE;			
				i_pstStEvtReq^.xEvt_TapPosition_Breaking := FALSE;
				
				pstStGrpParam_Save^.rVel_Tar:= pstStGrpParam_Save^.rVel_Ink;
				
				//2026.01.14.234426 | + | 增加打印测试流程
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'Vel=Ink!', BOOL_TO_STRING(xFlag_Stop_to_Print));		

			END_IF
		END_IF
		IF xFlag_Ink_to_stop AND pstStGrpParam_UnSave^.xFlag_Stop THEN
			xFlag_Ink_to_stop:= FALSE;
			xFlag_Stop_to_Print:= TRUE;
			i_pstStEvtReq^.xReqPrestart:= TRUE;
			i_pstStEvtReq^.xEvt_TapPosition_Breaking := FALSE;	
			i_pstStEvtReq^.xEvt_TapPosition_Printing := TRUE;			
			pstStGrpParam_Save^.rVel_Tar:= pstStGrpParam_Save^.rVel_Ink;		
		END_IF
		IF xFlag_Stop_to_Print AND pstStGrpParam_UnSave^.xFlag_Print THEN//转到印刷后自动加速到10
			i_pstStEvtReq^.xReqPrestart:= TRUE;
			xFlag_Stop_to_Print:= FALSE;
		END_IF
		IF pstStGrpParam_UnSave^.xFlag_Print AND i_pstStEvtReq^.xReqStop THEN
			xFlag_Print_to_stop:= TRUE;//印刷停机触发-
		END_IF
		IF xFlag_Print_to_stop AND pstStGrpParam_UnSave^.rVel_Cur=0 THEN
			//当前速度降到0再触发一下停机，直接停下来，但是所有伺服维持？//支持0速切状态
			xFlag_Print_to_stop:= FALSE;
			//2025.08.26.091339 | 点动结束后仍然维持张力，不再触发停机
			//i_pstStEvtReq^.xReqStop:= TRUE;
		END_IF
		
		
		IF pstStGrpParam_UnSave^.xFlag_Stop  THEN
	//停机状态下如果触发了一个匀墨按钮就进入断料空转档位，其他色组直接触发使能挂靠
			FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
				IF g_axInk_Unit[iN] AND i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
					i_pstStEvtReq^.xReqPrestart:= TRUE;
					i_pstStEvtReq^.xEvt_TapPosition_Breaking := TRUE;
					i_pstStEvtReq^.xEvt_TapPosition_Printing := FALSE;			
				END_IF
			END_FOR
		END_IF
		
		//2024.12.30.100740 | 空转状态按停机清除空转标志		
		fbTRIG_InkStop(CLK:=i_pastStIOMap_Main_FE^[1].i_xStop OR i_pastStIOMap_Main_FE^[1].i_xEstop OR i_pastStIOMap_Main_FE^[2].i_xStop OR i_pastStIOMap_Main_FE^[2].i_xEstop);
		IF fbTRIG_InkStop.Q THEN
			FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
				g_axInk_Unit[iN] := FALSE;
			END_FOR
		END_IF
		
		IF pstStGrpParam_UnSave^.xFlag_Stop THEN(*停机状态下进行启动判断*)
			IF i_pstStEvtReq^.xReqInk THEN(*按下预启动 我们控制启动空转逻辑*)
				xNeedInk:=TRUE;
				i_pstStEvtReq^.xReqInk:= FALSE;
				i_pstStEvtReq^.xReqPrestart:= TRUE;
			END_IF
	
			IF NOT xNeedInk THEN
				IF i_pstStEvtReq^.xReqPrestart THEN(*按下印刷启动 我们控制启动印刷逻辑*)
					xNeedPrint:=TRUE;
					pstStGrpParam_Save^.rVel_Tar:= pstStGrpParam_Save^.rVel_Ink;
				END_IF
			END_IF
	
			IF xStateChange THEN(*状态切换过我们清除状态变量*)
				xNeedInk:=FALSE;
				xNeedPrint:=FALSE;
				xStateChange:=FALSE;
			END_IF
		ELSE
			xStateChange:=TRUE;
		END_IF
	
		(*档位切换*)
		IF xNeedInk THEN
			(*使能匀墨状态*)
			i_pstStEvtReq^.xEvt_TapPosition_Breaking:=TRUE;(*断料*)
			i_pstStEvtReq^.xEvt_TapPosition_Printing:=FALSE;(*印刷*)
			i_pstStEvtReq^.xEvt_TapPosition_UniformInk:=FALSE;(*匀墨*)
		ELSIF xNeedPrint THEN
			(*使能印刷状态*)
			i_pstStEvtReq^.xEvt_TapPosition_Breaking:=FALSE;(*断料*)
			i_pstStEvtReq^.xEvt_TapPosition_Printing:=TRUE;(*印刷*)
			i_pstStEvtReq^.xEvt_TapPosition_UniformInk:=FALSE;(*匀墨*)
			
			//2026.1.5.163356 | + 
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_TensionDone := TRUE;
		END_IF	
		IF pstStGrpParam_UnSave^.xFlag_Ink THEN
			IF i_pstStEvtReq^.xReqPrestart THEN
				i_pstStEvtReq^.xReqPrestart:= FALSE;
			END_IF
			IF i_pstStEvtReq^.xReqInk THEN
				i_pstStEvtReq^.xReqInk:=FALSE;
				i_pstStEvtReq^.xReqPrestart:= TRUE;
			END_IF
		END_IF
		//2026.1.9.110731| zhang.hz | 秦华增加印后牵引的压力传感器
		wAnalogSignals_OF_PrintingOut := %IW8;
		KS_QueryRangeByAType(1, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
		g_lrTempOF_PrintingOut:= KSIO_DA(WORD_TO_INT(wAnalogSignals_OF_PrintingOut), lrN_min, lrN_max, diN_min, diN_max);
		
		//2026.1.15.171605处理一下模拟量输入。，|秦华输入为压力传感器|niu.j
		
		//2026.1.14.165419 | + | 收牵传感器修正为1V对应200牛
		rSlopeAboutPress := 200.0;
		lrAnalogInput_Pressure := g_lrTempOF_PrintingOut * rSlopeAboutPress;

// 		i_rPressure_Input_Of:= g_lrTempOF_PrintingOut,
// 		o_lrCur_PressureValue => g_lrCur_PressureValue		
		g_lrCur_PressureValue:= lrAnalogInput_Pressure;		
		(*电压值转换为压力大小用于显示*)
		IF rSlopeAboutPress = 0 THEN
			rSlopeAboutPress := 1;
		END_IF
		
		lrAnalogMiddle:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPressure_Tar/rSlopeAboutPress;(* (*i_pstStGrpParam^.rPressure_Tar*)*10/g_rPressure_Max(*i_pstStGrpParam^.rPressure_Max*);(*目标压力对应的电压值*)*)
		i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rAI_med_Of:= lrAnalogMiddle;
// 		(*目标压力对应电压值-即中位值*)
// 		lrAnalogDifference:=i_rPressure_Input_Of-lrAnalogMiddle;(*中位差值*)
// 		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Of:= lrAnalogDifference;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressDone:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
		
		//2026.1.17.093554 | + | 打开小信号开关
		FOR iN := 1 TO i_iGrpUnitNum_Pu BY 1 DO
			i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_Ctl.13 := TRUE;
			i_pstStSysParam^.astStUnitParam_Save[iN].dwFlag_Ctl.14 := TRUE;
		END_FOR
		
		//2026.1.9.110731| zhang.hz | 秦华增加收牵摆臂记录
		wAnalogSignals_OF := %IW9;
		KS_QueryRangeByAType(1, ADR(lrN_min), ADR(lrN_max), ADR(diN_min), ADR(diN_max));
		g_lrTempOF:= KSIO_DA(WORD_TO_INT(wAnalogSignals_OF), lrN_min, lrN_max, diN_min, diN_max);
		
	ELSE
		;
	END_IF
	

ELSE
	;
END_IF