(*@CES
Name=KS_FB_AxisFindModule
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fe608f45-03e0-4e2e-a249-20c440ac82a6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisFindModule
VAR_INPUT
    (** 基本输入 **)
    i_xEn: BOOL;                         (** 模块使能 **)
    i_iAxisId: INT;                      (** 轴号 **)
    i_eCmd: EnumFindCommand;             (** 命令 **)
    i_xUseFindBestPosStep: BOOL;         (** 使用寻找最佳位置步骤 **)

    (** 参数输入 **)
    i_pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave; (** 单元参数 **)
    i_pstStUnitParam_Save: POINTER TO StUnitParam_Save; (** 单元参数 **)
    i_pstStGrpParam_Save: POINTER TO StGrpParam_Save; (** 组参数 **)
    i_rVel: REAL;                        (** 速度 **)
    i_rGirth: REAL;                      (** 版周长 **)
    i_rFilmLength: REAL;                 (** 料长 **)
    i_iBeforeAxisId: INT;                (** 前轴号 **)
    i_iAfterAxisId: INT;                 (** 后轴号 **)
    i_rFindBestPos_MoveDis: ARRAY [1..2] OF REAL; (** 光纤移动距离 **)
    
    (** 外部状态输入 **)
    i_xCoarseDone: BOOL;                 (** 粗调完成标志 **)
    i_xPressDone: BOOL;                  (** 合压完成标志 **)
    i_xAutoMode: BOOL;                   (** 自动模式标志 **)
    i_xFind_IDLE: BOOL;                  (** 当前轴全自动套印空闲 **)
    
    (** 开关参数 **)
    i_xSwitch_EnFastPress: BOOL;         (** 快速合压开关 **)
    i_xSwitch_RFailure: BOOL;            (** R失效开关 **)
    i_xSwitch_FFailure: BOOL;            (** F失效开关 **)
    i_xSpecialMarkEn: BOOL;              (** 特殊标使能 **)
END_VAR
VAR_OUTPUT
    (** 状态输出 **)
    o_eState: EnumFindState;             (** 当前状态 **)
    o_stResult: StFindResult;            (** 寻找结果 **)
    o_xBusy: BOOL;                       (** 忙标志 **)
    o_xDone: BOOL;                       (** 完成标志 **)
    o_xSuccess: BOOL;                    (** 成功标志 **)
    o_xError: BOOL;                      (** 错误标志 **)
    o_iErrorCode: INT;                   (** 错误代码 **)
    
    (** 控制输出 **)
    o_xNeedPress: BOOL;                  (** 需要合压 **)
    o_xBeforeAxisStartPress: BOOL;       (** 前轴开始合压（自动模式下使用）**)
    
    (** 从站控制信号 **)
    o_xFindFirstMark: BOOL;              (** 启动单色寻找@发送给从站 **)
    o_xFindPreMark: BOOL;                (** 启动混色寻找@发送给从站 **)
    o_xGateMoveFinish: BOOL;             (** 波门移动完成 **)
    o_xCurManuAdjust: BOOL;              (** 当前色需要手动调整 **)
    o_xPreCurManuAdjust: BOOL;           (** 前色需要手动调整 **)
    
    (** 光纤移动控制 **)
    o_xFiberMoveDisRunStart_FindSignal: BOOL; (** 光纤移动启动 **)
    o_rFiberMoveDistanceIn_FindSignal: REAL; (** 光纤移动距离 **)
    
    (** 参数设置输出 **)
    o_iGateSa: INT;                      (** 波门起始位置 **)
    
    (** 寻找状态标志 **)
    o_xSingleFound: BOOL;                (** 单色至少找到一次 **)
    o_xMixFound: BOOL;                   (** 混色找到 **)
    o_xHasAlarm: BOOL;                   (** 有报警 **)
	o_xHasAlarming: BOOL;                (** 有报警铃输出 **)
    o_xPressTriggered: BOOL;             (** 合压已触发（前轴）**)
END_VAR
VAR
    iN: INT;
    (** 状态机 **)
    eState: EnumFindState;
    ePrevState: EnumFindState;
    
    (** 寻找参数 **)
    byFindCycleCnt: BYTE;
    aiCurLabelPos: ARRAY[1..3] OF INT;
    arCurLabelWidth: ARRAY[1..3] OF REAL;
    rFiberMoveDist: ARRAY[1..2] OF REAL;
    iCurBestSignalPos: INT;
    
    (** 计时器 **)
    fbDelayTimer: TON;
    fbMixDelayTimer: TON;                (** 混色寻找延时计时器 **)
    iDelayTime: DINT;
    iTotalDelayTime: DINT;
    iMixDelayTime: DINT;                 (** 混色延时时间 **)
    
    (** 状态标志 **)
  //  xInitDone: BOOL;
    xCoarseChecked: BOOL;
    xGateAdjusted: BOOL;
	xMasterComplete:BOOL;				(*从站再找一次*)
	xMasterCompleteing:BOOL;			(*从站再找一次中*)
    xFindSingleSuccess: BOOL;            (** 单色寻找最终成功 **)
    xFindMixSuccess: BOOL;               (** 混色寻找最终成功 **)
    xFiberMoved: BOOL;
    xPressRequested: BOOL;
    xMixDelayStarted: BOOL;              (** 混色延时已开始 **)
    xFineAdjustStarted: BOOL;            (** 精调已开始 **)
    xFineAdjustComplete: BOOL;           (** 精调完成 **)
    
    (** 寻找结果标志 **)
    xSingleFoundAtLeastOnce: BOOL;       (** 单色至少找到一次 **)
    xMixFound: BOOL;                     (** 混色找到 **)
    xHasSingleError: BOOL;               (** 单色寻找有错误 **)
    xHasMixError: BOOL;                  (** 混色寻找有错误 **)
    
    (** 触发标志 **)
    xBeforeAxisPressTriggered: BOOL;     (** 前轴合压已触发标志 **)
    
    (** 错误处理 **)
    iErrorCount: INT;
	fbR_TRIG_HasAlarm :R_trig;
	fbTON_HasAlarming :TON;
	
    
    (** 临时变量 **)
    iTemp: INT;
    rTemp: REAL;
    
    pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave;
    pstStUnitParam_Save: POINTER TO StUnitParam_Save;
    pstStGrpParam_Save: POINTER TO StGrpParam_Save;
    
    (** 寻找延时 **)
    iFindSingleDelayTime: DINT;          (** 单色寻找延时@ms **)
    iFindMixDelayTime: DINT;             (** 混色寻找延时@ms **)
    
    (** 命令处理 **)
    eCmd: EnumFindCommand;
    xCmdRising: BOOL;
    xPrevCmd: EnumFindCommand;
    
    (** 寻找标志 **)
    xUseFindBestPosStep: BOOL;           (** 使用寻找最佳位置步骤 **)
    
    (** 从站计算精采样宽度 **)
    xFindMarkCenter_CalWidth: BOOL;
    xPreStsFineAdjFiber: BOOL;
    xStsFineAdjFiber: BOOL;
	
	iWaitFiberMoveDelayTime:DINT:=500;
	
	
	xNeedMsg:BOOL;
	sLogMsg: STRING;
	sTimeStamp_Tmp				: STRING;
	tChangeStsTime:TIME;
	tLastTime:TIME;
END_VAR
{IMPLEMENTATION}
IF i_pstStRSV_UnitParam_UnSave = 0 OR
   i_pstStUnitParam_Save = 0 OR
   i_pstStGrpParam_Save = 0 THEN
    RETURN;
END_IF

(** 初始化指针 **)
pstStRSV_UnitParam_UnSave := i_pstStRSV_UnitParam_UnSave;
pstStUnitParam_Save := i_pstStUnitParam_Save;
pstStGrpParam_Save := i_pstStGrpParam_Save;

(** 重置输出 **)
o_xBusy := FALSE;
o_xDone := FALSE;
o_xSuccess := FALSE;
o_xError := FALSE;
o_xNeedPress := FALSE;
o_xBeforeAxisStartPress := FALSE;
o_xGateMoveFinish := FALSE;
o_xCurManuAdjust := FALSE;
o_xPreCurManuAdjust := FALSE;
o_xFiberMoveDisRunStart_FindSignal := FALSE;
o_rFiberMoveDistanceIn_FindSignal := 0.0;
o_iGateSa := 0;
o_eState := eState;
o_xSingleFound := FALSE;
o_xMixFound := FALSE;
o_xHasAlarm := FALSE;
o_xPressTriggered := xBeforeAxisPressTriggered;

(** 保存设置 **)
xUseFindBestPosStep := i_xUseFindBestPosStep;

(** 检测沿信号 **)
xPrevCmd := eCmd;
eCmd := i_eCmd;
IF eCmd <> xPrevCmd THEN
    xCmdRising := TRUE;
ELSE
    xCmdRising := FALSE;
END_IF

IF i_xEn THEN
    
    (** 命令处理 **)
    IF xCmdRising THEN
        CASE eCmd OF
            FIND_CMD_START_SINGLE:
                IF eState = FIND_STATE_IDLE THEN
                    eState := FIND_STATE_INIT;
                 //   xInitDone := FALSE;
                    xFindSingleSuccess := FALSE;
                    xFindMixSuccess := FALSE;
                    o_stResult.xSuccess := FALSE;
                    xBeforeAxisPressTriggered := FALSE;  (** 重置触发标志 **)
                END_IF
                
            FIND_CMD_START_MIX:
                IF eState = FIND_STATE_IDLE OR eState = FIND_STATE_COMPLETE THEN
                    (** 直接进入混色寻找延时状态 **)
                    eState := FIND_STATE_DELAY_MIX;
                    xFindMixSuccess := FALSE;
                    o_stResult.xSuccess := FALSE;
                END_IF
                
            FIND_CMD_RESET:
                eState := FIND_STATE_IDLE;
              //  xInitDone := FALSE;
                xFindSingleSuccess := FALSE;
                xFindMixSuccess := FALSE;
                o_stResult.xSuccess := FALSE;
                o_xBusy := FALSE;
                o_xDone := TRUE;
                o_xSuccess := TRUE;
                o_xError := FALSE;
                o_xNeedPress := FALSE;
                o_xFindFirstMark := FALSE;
                o_xFindPreMark := FALSE;
                o_xGateMoveFinish := TRUE;
                o_xBeforeAxisStartPress := FALSE;
                xFindMarkCenter_CalWidth := FALSE;
                o_xFiberMoveDisRunStart_FindSignal := FALSE;
                xBeforeAxisPressTriggered := FALSE;
				xHasSingleError :=FALSE;
				xHasMixError:=FALSE;
				fbDelayTimer(iN:=FALSE);
				fbMixDelayTimer(iN:=FALSE);
				fbTON_HasAlarming(iN:=FALSE);
        END_CASE
    END_IF
	
	(*混色计时器挪到外面*)
	fbMixDelayTimer(IN:=xBeforeAxisPressTriggered, PT:=DINT_TO_TIME(iFindMixDelayTime)); 
    
    (** 状态机主循环 **)
    CASE eState OF
        FIND_STATE_IDLE:
            (** 空闲状态，等待命令 **)
            o_xBusy := FALSE;
            o_xDone := TRUE;
            o_xNeedPress := FALSE;
            
        FIND_STATE_INIT:
            (** 初始化寻找参数 **)
            o_xBusy := TRUE;
            (** 初始化参数 **)
            byFindCycleCnt := 0;
            FOR iTemp := 1 TO 3 BY 1 DO
                aiCurLabelPos[iTemp] := -1;
                arCurLabelWidth[iTemp] := 0.0;
            END_FOR
            
            FOR iN := 1 TO 3 BY 1 DO
                IF iN <= 2 THEN
                    g_aiCurLabelPos[i_iAxisId, iN] := -1;
                    g_arCurLabelWidth[i_iAxisId, iN] := 0.0;
                    g_rFiberMoveDist[i_iAxisId, iN] := 0;
                END_IF
                g_aiCurLabelPos[i_iAxisId, iN] := -1;
                g_arCurLabelWidth[i_iAxisId, iN] := 0.0;
            END_FOR
            iCurBestSignalPos := -1;
            xMixDelayStarted := FALSE;
            xFineAdjustStarted := FALSE;
            xFineAdjustComplete := FALSE;
            xFindMarkCenter_CalWidth := FALSE;
            xSingleFoundAtLeastOnce := FALSE;
            xMixFound := FALSE;
            xHasSingleError := FALSE;
            xHasMixError := FALSE;
            xBeforeAxisPressTriggered := FALSE;
			fbTON_HasAlarming(iN:=FALSE);
			fbR_TRIG_HasAlarm(clk:=FALSE);
			o_stResult.xSuccess := FALSE;
			o_stResult.iErrorCode := 0;
            
            (** 检查是否需要合压 **)
            IF i_iAfterAxisId = -1 AND i_xAutoMode THEN
                (** 最后一个轴，需要合压 **)
                o_xNeedPress := TRUE;
                eState := FIND_STATE_CHECK_COARSE;
            ELSE
                eState := FIND_STATE_CHECK_COARSE;
            END_IF
			
			(** 计算延时时间 **)
			IF i_rVel > 0 AND i_rGirth > 0 THEN
				(** 单色寻找前延时：等待1.5圈 **)
				iFindSingleDelayTime := REAL_TO_DINT(1.5 * 60.0 * i_rGirth / 1000.0 / i_rVel * 1000.0);
				
				(** 混色寻找延时 **)
				IF i_iBeforeAxisId <> -1 THEN
					iFindMixDelayTime := KS_CalculateMixFindDelayTime(
						i_iAxisId,
						i_iBeforeAxisId,
						pstStUnitParam_Save,
						i_rVel
					);
				END_IF
			ELSE
				iFindSingleDelayTime := 1000;  (** 默认1秒 **)
				iFindMixDelayTime := 30000;    (** 默认30秒 **)
			END_IF   
			fbMixDelayTimer(IN:=FALSE);        
        FIND_STATE_CHECK_COARSE:
            (** 检查粗调状态 **)
            o_xBusy := TRUE;
            IF i_xCoarseDone THEN
				IF i_iAfterAxisId = -1 AND i_xPressDone THEN
					(** 最后一个轴，且合压完成，不需要需要合压，直接进入找标 **)
					eState := FIND_STATE_DELAY_SINGLE;
				ELSE
					 xCoarseChecked := TRUE;
               		 eState := FIND_STATE_WAIT_PRESS;
				END_IF  
            ELSE
                (** 粗调未完成，设置错误标志但不停止流程 **)
                xHasSingleError := TRUE;
                o_stResult.iErrorCode := FIND_ERR_COARSE_NOT_READY;
            END_IF
            
        FIND_STATE_WAIT_PRESS:
            (** 等待合压完成 **)
            o_xBusy := TRUE;
            
            IF i_xPressDone THEN
                o_xNeedPress := FALSE;
                xPressRequested := FALSE;                
                (** 启动单色寻找前延时计时器 **)
                fbDelayTimer(IN:=TRUE, PT:=DINT_TO_TIME(iFindSingleDelayTime));
            ELSE
                o_xNeedPress := TRUE;
            END_IF
			
            IF fbDelayTimer.Q THEN
                fbDelayTimer(IN:=FALSE);
                eState := FIND_STATE_DELAY_SINGLE;
            END_IF
            
        FIND_STATE_DELAY_SINGLE:
            o_xBusy := TRUE;         
            (** 等待从站空闲 **)
			IF i_xFind_IDLE THEN
				IF i_xAutoMode THEN(*自动模式*)
					(** 初始化从站参数 **)
					o_xFindFirstMark := TRUE;
					o_xCurManuAdjust := FALSE;
					eState := FIND_STATE_FIND_SINGLE;
				ELSE (*手动模式*)
					eState := FIND_STATE_FIND_SINGLE;
				END_IF
			END_IF 
        FIND_STATE_FIND_SINGLE:
            (** 执行单色寻找 **)
            o_xBusy := TRUE;
            IF NOT i_xFind_IDLE THEN
				xMasterComplete:=FALSE;
			END_IF
			IF i_xAutoMode THEN(*自动模式*)
					(** 等待从站结果 从站状态机在7或者8时，表示该次寻找完成**)
				IF pstStRSV_UnitParam_UnSave^.byFlag_CommFromSlave.2 AND (pstStRSV_UnitParam_UnSave^.byMarkStep = 7 
					OR pstStRSV_UnitParam_UnSave^.byMarkStep = 8)THEN
					(** 从站找标完成 **)
					o_xFindFirstMark := FALSE;
					
					(** 记录结果 **)
					IF pstStRSV_UnitParam_UnSave^.iCurLabelPos >= 0 THEN
						(** 找到标记 **)
						byFindCycleCnt := byFindCycleCnt + 1;
						aiCurLabelPos[byFindCycleCnt] := pstStRSV_UnitParam_UnSave^.iCurLabelPos;
						arCurLabelWidth[byFindCycleCnt] := pstStRSV_UnitParam_UnSave^.rGateSignalWidth_R;
						xSingleFoundAtLeastOnce := TRUE;  (** 标记至少找到一次 **)
						
						(** 快速合压模式：第一次找到就触发前轴合压 **)
						IF i_xAutoMode AND i_iBeforeAxisId <> -1 AND i_xSwitch_EnFastPress 
						   AND byFindCycleCnt = 1 AND NOT xBeforeAxisPressTriggered THEN
							o_xBeforeAxisStartPress := TRUE;
							xBeforeAxisPressTriggered := TRUE;  (** 标记已触发 **)
						END_IF
						
						(** 如果使用最佳位置步骤且还没采完3次，继续采样 **)
						IF xUseFindBestPosStep AND byFindCycleCnt < 3 THEN
							eState := FIND_STATE_MOVE_FIBER;
						ELSE
							(** 采完3次或不使用最佳位置步骤 **)
							eState := FIND_STATE_CALC_BEST;
						END_IF
					ELSE
						(** 未找到标记，记录错误但不停止 **)
						//xHasSingleError := TRUE;
						o_stResult.iErrorCode := FIND_ERR_SINGLE_MARK_NOT_FOUND;
						o_xCurManuAdjust := TRUE;  (** 需要手动调整 **)
						
						(** 增加计数，继续尝试 **)
						byFindCycleCnt := byFindCycleCnt + 1;
						
						(** 如果还没采完3次，继续采样 **)
						IF xUseFindBestPosStep AND byFindCycleCnt < 3 THEN
							eState := FIND_STATE_MOVE_FIBER;
						ELSE
							(** 采完3次，进入下一步 **)
							eState := FIND_STATE_CALC_BEST;
						END_IF
					END_IF
				END_IF
			ELSE (*手动模式*)
				 (** 通过精采样计算当前波门内波形宽度 **)
				xFindMarkCenter_CalWidth := TRUE;
				xStsFineAdjFiber := pstStRSV_UnitParam_UnSave^.byFlag_CommFromSlave.3;
				(** 检查是否需要光纤精调 **)
				IF xUseFindBestPosStep AND NOT xPreStsFineAdjFiber AND xStsFineAdjFiber 
				    AND pstStRSV_UnitParam_UnSave^.xFiberMoveIdle THEN
					xFindMarkCenter_CalWidth := FALSE;
					byFindCycleCnt := byFindCycleCnt + 1;
					(*手动模式，需要填写一个>=0的值作为波形的位置，保证后续逻辑正确，所以这里先填写一个波门位置，实际波形位置不在这里*)
					aiCurLabelPos[byFindCycleCnt] := pstStUnitParam_Save^.iGateSa;
					arCurLabelWidth[byFindCycleCnt] := pstStRSV_UnitParam_UnSave^.rWidth_FindMarkCenter;
					xSingleFoundAtLeastOnce := TRUE;  (** 标记至少找到一次 **)
					(** 如果使用最佳位置步骤且还没采完3次，继续采样 **)
					IF xUseFindBestPosStep AND byFindCycleCnt < 3 THEN
						eState := FIND_STATE_MOVE_FIBER;
					ELSE
						(** 采完3次或不使用最佳位置步骤 **)
						eState := FIND_STATE_CALC_BEST;
					END_IF
				END_IF
				xPreStsFineAdjFiber := xStsFineAdjFiber;	
			END_IF  
        FIND_STATE_MOVE_FIBER:
            (** 移动光纤到下一个采样位置 **)
            o_xBusy := TRUE;
             IF NOT i_xFind_IDLE THEN
				xMasterComplete:=FALSE;
			END_IF
            IF pstStRSV_UnitParam_UnSave^.xFiberMoveIdle THEN
                (** 计算移动距离 **)
                CASE byFindCycleCnt OF
                    1:  (** 第二次采样，左移3mm **)
                        rFiberMoveDist[1] := i_rFindBestPos_MoveDis[1];
                    2:  (** 第三次采样，右移6mm **)
                        rFiberMoveDist[1] := i_rFindBestPos_MoveDis[2];
                END_CASE
                
                (** 执行移动 **)
                o_rFiberMoveDistanceIn_FindSignal := rFiberMoveDist[1];
                o_xFiberMoveDisRunStart_FindSignal := TRUE;
                xMasterCompleteing:=FALSE;
                eState := FIND_STATE_WAIT_FIBER_MOVE;
            END_IF
            
        FIND_STATE_WAIT_FIBER_MOVE:
            (** 等待光纤移动完成 **)
            o_xBusy := TRUE;
             IF NOT i_xFind_IDLE THEN
				xMasterComplete:=FALSE;
			END_IF
			
            IF pstStRSV_UnitParam_UnSave^.xFiberMoveIdle THEN
               	o_xFiberMoveDisRunStart_FindSignal := FALSE;
				IF i_xAutoMode THEN(*自动模式*)
					(** 等待从站空闲 **)
					IF i_xFind_IDLE AND NOT xMasterCompleteing THEN
						xMasterCompleteing:=TRUE;
						xMasterComplete := TRUE;
					END_IF
					IF NOT i_xFind_IDLE AND xMasterCompleteing THEN
						 eState := FIND_STATE_FIND_SINGLE;
					END_IF
				ELSE (*手动模式*)
					 eState := FIND_STATE_FIND_SINGLE;
				END_IF   
            END_IF            
        FIND_STATE_CALC_BEST:
            (** 计算最佳位置 **)
            o_xBusy := TRUE;
            xMasterComplete := FALSE;
			(** 使用寻找最佳位置步骤，且至少找到过一次 **)
			KS_CalBestFiberMoveDisByRS(
				arCurLabelWidth,
				aiCurLabelPos,
				pstStGrpParam_Save^.byTriMark_SideB,
				pstStGrpParam_Save^.byTriMark_SideC,
				pstStGrpParam_Save^.iMarkTypeId,
				ADR(iCurBestSignalPos),
				ADR(rFiberMoveDist[1])
			);
            IF xSingleFoundAtLeastOnce AND xUseFindBestPosStep THEN        
                IF iCurBestSignalPos <> -1 THEN
                    (** 计算成功 **)
					 xFindSingleSuccess := TRUE;
					o_stResult.iCurBestPos := iCurBestSignalPos;
					
					(** 移动光纤到最佳位置 **)
					IF pstStRSV_UnitParam_UnSave^.xFiberMoveIdle THEN
						o_rFiberMoveDistanceIn_FindSignal := rFiberMoveDist[1];
						o_xFiberMoveDisRunStart_FindSignal := TRUE;
						IF i_xSwitch_RFailure THEN
							o_xFiberMoveDisRunStart_FindSignal := FALSE;
						END_IF
						eState := FIND_STATE_ADJUST_GATE;
					END_IF				                   
                ELSE
                    (** 计算失败，记录错误但继续流程 **)
                    xHasSingleError := TRUE;
                    o_stResult.iErrorCode := FIND_ERR_CALC_BEST_FAILED;
                    o_xCurManuAdjust := TRUE;  (** 需要手动调整 **)
                   // eState := FIND_STATE_ADJUST_GATE;  (** 继续流程 **)
                END_IF
            ELSE
                (** 没有找到单色或不使用最佳位置步骤 **)
                IF xSingleFoundAtLeastOnce THEN
                    (** 至少找到过一次，使用第一次采样的位置 **)
                    iCurBestSignalPos := aiCurLabelPos[1];
                    rFiberMoveDist[1] := rFiberMoveDist[1];  (** 移动回原原位 **)
					o_xFiberMoveDisRunStart_FindSignal := TRUE;
                    xFindSingleSuccess := TRUE;
                    o_stResult.iCurBestPos := iCurBestSignalPos;
                ELSE
                    (** 一次都没找到，不设置最佳位置 **)
					o_rFiberMoveDistanceIn_FindSignal := rFiberMoveDist[1];
                    o_xFiberMoveDisRunStart_FindSignal := TRUE;
                    iCurBestSignalPos := -1;
                    xHasSingleError := TRUE;
                END_IF 
            END_IF
		 	(** 非快速合压模式：在当前轴处理完成后触发前轴合压 **)
			IF i_xAutoMode AND i_iBeforeAxisId <> -1 AND NOT xBeforeAxisPressTriggered THEN
				o_xBeforeAxisStartPress := TRUE;
				xBeforeAxisPressTriggered := TRUE;  (** 标记已触发 **)
				eState := FIND_STATE_ADJUST_GATE;  (** 继续流程 **)
			END_IF
        FIND_STATE_ADJUST_GATE:
            (** 调整波门位置 **)
            o_xBusy := TRUE;
            
            (** 等待光纤移动完成（如果有移动）**)
            IF pstStRSV_UnitParam_UnSave^.xFiberMoveIdle THEN
                o_xFiberMoveDisRunStart_FindSignal := FALSE;
                
                (** 如果单色找到 且为自动模式，设置波门位置；否则波门保持原位 **)
                IF xSingleFoundAtLeastOnce AND i_xAutoMode AND iCurBestSignalPos <> -1 THEN
                    (** 设置波门中心位置 **)
                    o_iGateSa := iCurBestSignalPos - pstStUnitParam_Save^.iGateWidthRoundPoints / 2;
                    
                    (** 边界检查 **)
                    IF o_iGateSa < 0 THEN
                        o_iGateSa := o_iGateSa + 4000;
                    ELSIF o_iGateSa > 3999 THEN
                        o_iGateSa := o_iGateSa - 4000;
                    END_IF
					pstStUnitParam_Save^.iGateSa:= o_iGateSa;
                ELSE
                    (** 单色没找到或者手动模式，波门保持原位 **)
                   o_iGateSa:=pstStUnitParam_Save^.iGateSa;
                END_IF
                o_xGateMoveFinish := TRUE;
                
                IF xSingleFoundAtLeastOnce AND iCurBestSignalPos <> -1 THEN
                    o_stResult.iCurLabelPos := iCurBestSignalPos;
                ELSE
                    o_stResult.iCurLabelPos := -1;
                END_IF
                
                (** 检查是否需要寻找混色 因为手动模式设置前色轴位-1，所以直接完成，不需要处理**)
                IF i_iBeforeAxisId <> -1 THEN
                    (** 有前轴，需要寻找混色 **)
					IF  pstStUnitParam_Save^.iGateSa =o_iGateSa THEN
						eState := FIND_STATE_DELAY_MIX;
					END_IF 
                ELSE
                    (** 没有前轴，完成 **)
                    eState := FIND_STATE_COMPLETE;
                END_IF
            END_IF
            
        FIND_STATE_DELAY_MIX:
            (** 混色寻找前延时 **)
            o_xBusy := TRUE;
            
            (** 启动混色延时计时器 **)
            IF NOT xMixDelayStarted THEN
                xMixDelayStarted := TRUE;
				//fbMixDelayTimer(IN:=FALSE);
            END_IF
          //  fbMixDelayTimer(IN:=xMixDelayStarted, PT:=DINT_TO_TIME(iFindMixDelayTime));
            (** 光纤精调 **)
			IF  NOT xFineAdjustStarted THEN
				 xFindMarkCenter_CalWidth := TRUE;
			END_IF
            xStsFineAdjFiber := pstStRSV_UnitParam_UnSave^.byFlag_CommFromSlave.3;
            
            (** 检查是否需要光纤精调 **)
            IF xUseFindBestPosStep AND NOT xPreStsFineAdjFiber AND xStsFineAdjFiber AND 
               NOT xFineAdjustStarted AND pstStRSV_UnitParam_UnSave^.xFiberMoveIdle AND
               NOT fbMixDelayTimer.Q THEN
			    xFindMarkCenter_CalWidth := FALSE;
                eState := FIND_STATE_FINE_ADJUST;
            END_IF
            
            xPreStsFineAdjFiber := xStsFineAdjFiber;
            
            (** 检查混色延时是否结束 **)
            IF fbMixDelayTimer.Q THEN
                fbMixDelayTimer(IN:=FALSE);
                xMixDelayStarted := FALSE;
                o_xFindPreMark := TRUE;
                eState := FIND_STATE_FIND_MIX;
            END_IF
            
        FIND_STATE_FINE_ADJUST:
            (** 光纤精调 **)
            o_xBusy := TRUE;
            
            IF NOT xFineAdjustStarted THEN
                (** 计算精调距离 **)
                KS_CalBestFiberMoveDisByPS(
                    ADR(pstStRSV_UnitParam_UnSave^.rWidth_FindMarkCenter),
                    pstStGrpParam_Save^.byTriMark_SideB,
                    pstStGrpParam_Save^.byTriMark_SideC,
                    pstStGrpParam_Save^.iMarkTypeId,
                    ADR(rFiberMoveDist[2])
                );
                
                (** 执行精调移动 **)
                o_rFiberMoveDistanceIn_FindSignal := rFiberMoveDist[2];
                o_xFiberMoveDisRunStart_FindSignal := TRUE;
				IF i_xSwitch_FFailure THEN
					 o_xFiberMoveDisRunStart_FindSignal := FALSE;
				END_IF
                xFineAdjustStarted := TRUE;               
                eState := FIND_STATE_WAIT_FINE_ADJ;
            END_IF
            
        FIND_STATE_WAIT_FINE_ADJ:
            (** 等待精调完成 **)
            o_xBusy := TRUE;
         //   fbMixDelayTimer(IN:=xMixDelayStarted, PT:=DINT_TO_TIME(iFindMixDelayTime));
            IF pstStRSV_UnitParam_UnSave^.xFiberMoveIdle THEN
                o_xFiberMoveDisRunStart_FindSignal := FALSE;
                xFineAdjustComplete := TRUE;
                
                (** 返回等待混色状态，继续等待混色延时 **)
                eState := FIND_STATE_DELAY_MIX;
            END_IF
			 (** 检查混色延时是否结束 **)
            IF fbMixDelayTimer.Q THEN
                fbMixDelayTimer(IN:=FALSE);
                xMixDelayStarted := FALSE;
                o_xFindPreMark := TRUE;
                eState := FIND_STATE_FIND_MIX;
            END_IF
            
        FIND_STATE_FIND_MIX:
            (** 执行混色寻找 **)
            o_xBusy := TRUE;
            
            (** 等待从站结果 **)
            IF pstStRSV_UnitParam_UnSave^.xFlag_FindPreSuccess THEN
                (** 记录前色位置 **)
                IF pstStRSV_UnitParam_UnSave^.iPreLabelPos >= 0 AND pstStRSV_UnitParam_UnSave^.iPreLabelPos < 4000 THEN
                    xMixFound := TRUE;
                    xFindMixSuccess := TRUE;
                    o_stResult.iPreLabelPos := pstStRSV_UnitParam_UnSave^.iPreLabelPos;
                ELSE
                    (** 前色位置无效 **)
                    xHasMixError := TRUE;
                    o_stResult.iErrorCode := FIND_ERR_PRE_POS_INVALID;
                    o_xPreCurManuAdjust := TRUE;  (** 需要手动调整 **)
                END_IF
                
                o_xFindPreMark := FALSE;
                eState := FIND_STATE_COMPLETE;
            END_IF
            
        FIND_STATE_COMPLETE:
            (** 寻找完成 **)
            o_xBusy := FALSE;
            o_xDone := TRUE;
            
            (** 设置最终成功标志：单色和混色都找到才算成功 **)
            IF i_iBeforeAxisId = -1 THEN
                (** 第一色，不需要寻找，只要合压完成就算成功 **)
                o_xSuccess := TRUE;
            ELSE
                (** 非第一色，需要单色和混色都找到 **)
                o_xSuccess := xSingleFoundAtLeastOnce AND xMixFound;
            END_IF
            
            o_stResult.xSuccess := o_xSuccess;
            
            (** 设置错误标志 **)
            IF xHasSingleError OR xHasMixError THEN
                o_xError := TRUE;
            END_IF
                        
            (** 设置寻找结果标志 **)
            o_xSingleFound := xSingleFoundAtLeastOnce;
            o_xMixFound := xMixFound;
            
    END_CASE 
END_IF

(** 设置报警标志 **)
o_xHasAlarm := xHasSingleError OR xHasMixError;
fbR_TRIG_HasAlarm(clk:=o_xHasAlarm);
IF fbR_TRIG_HasAlarm.Q THEN
	o_xHasAlarming:=TRUE;
END_IF
fbTON_HasAlarming(iN:=o_xHasAlarming,PT:=T#2000MS);
IF fbTON_HasAlarming.Q THEN
	fbTON_HasAlarming(iN:=FALSE);
	o_xHasAlarming:=FALSE;
END_IF


(** 更新全局数组 **)
FOR iN := 1 TO 3 BY 1 DO
	IF iN <= 2 THEN
		g_aiCurLabelPos[i_iAxisId, iN] := aiCurLabelPos[iN];
		g_arCurLabelWidth[i_iAxisId, iN] := arCurLabelWidth[iN];
		g_rFiberMoveDist[i_iAxisId, iN] := INT_TO_REAL((REAL_TO_INT(rFiberMoveDist[iN] * 10))) / 10;
	END_IF
	g_aiCurLabelPos[i_iAxisId, iN] := aiCurLabelPos[iN];
	g_arCurLabelWidth[i_iAxisId, iN] := arCurLabelWidth[iN];
END_FOR

g_aiStep_AutoAdjust[i_iAxisId] := eState;
    
o_stResult.eState:=eState;
(** 更新输出状态 **)
o_eState := eState;
o_xPressTriggered := xBeforeAxisPressTriggered;

(** 设置从站通信标志 **)
pstStRSV_UnitParam_UnSave^.byFlag_CommFromMaster.0 := i_xEn AND (eCmd <> FIND_CMD_RESET);
pstStRSV_UnitParam_UnSave^.byFlag_CommFromMaster.1 := o_xFindFirstMark;
pstStRSV_UnitParam_UnSave^.byFlag_CommFromMaster.3 := o_xFindPreMark;
pstStRSV_UnitParam_UnSave^.byFlag_CommFromMaster.5 := o_xGateMoveFinish;
pstStRSV_UnitParam_UnSave^.byFlag_CommFromMaster.6 := xMasterComplete;
pstStRSV_UnitParam_UnSave^.byFlag_CommFromMaster.7 := xFindMarkCenter_CalWidth;

(** 处理光纤移动 **)
pstStRSV_UnitParam_UnSave^.rFiberMoveDistanceIn_FindSignal := o_rFiberMoveDistanceIn_FindSignal;
pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal := o_xFiberMoveDisRunStart_FindSignal;
IF ABS(o_rFiberMoveDistanceIn_FindSignal) < 0.1 THEN
    pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal := FALSE;
END_IF
o_stResult.rFiberMoveDist:=o_rFiberMoveDistanceIn_FindSignal;
(*2026.05.21.095119上报金刚相关讯息||wang.xy*)
pstStRSV_UnitParam_UnSave^.wCommFromDubheFindSignal.0:=i_xEn AND (eCmd <> FIND_CMD_RESET);
pstStRSV_UnitParam_UnSave^.wCommFromDubheFindSignal.6 := xHasSingleError OR xHasMixError;
// pstStRSV_UnitParam_UnSave^.wCommFromDubheFindSignal.1:=
pstStRSV_UnitParam_UnSave^.iStep_AutoAdjust:=o_stResult.eState;
pstStRSV_UnitParam_UnSave^.iError_Msg:=o_stResult.iErrorCode;

// 					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].iStep_AutoAdjust;
// 	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].iError_Msg:= 
// 					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].iError_Msg;

(*日志*)
xNeedMsg :=FALSE;
IF eState<>ePrevState THEN
	tChangeStsTime:=TIME()-tLastTime;
	tLastTime:=TIME();
	//sTimeStamp_Tmp:= KS_GetTimeString(TIMEFORMAT_HYPHEN_DOT, TRUE, TRUE);
	sLogMsg := CONCAT('AXIS : ', INT_TO_STRING(i_iAxisId));
	sLogMsg := CONCAT(sLogMsg, '@');
	sLogMsg := CONCAT(sLogMsg, TIME_TO_STRING(tChangeStsTime));
	sLogMsg := CONCAT(sLogMsg,'|');
	sLogMsg := CONCAT(sLogMsg, INT_TO_STRING(ePrevState));
	sLogMsg := CONCAT(sLogMsg, '->');
	sLogMsg := CONCAT(sLogMsg, INT_TO_STRING(eState));
	xNeedMsg :=TRUE;
END_IF
(** 保存上一状态 **)
ePrevState := eState;

IF xNeedMsg THEN
	(* 调用日志函数 *)
	KS_HY_AddMsgToLog(
	g_pstStHYLogFifo, 
	LOG_LEVEL_DEBUG, 
	'MARKDETECTION',
	sLogMsg);
END_IF