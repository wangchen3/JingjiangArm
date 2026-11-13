(*@CES
Name=KS_FB_FiberMoveCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5e797760-0150-4788-bd4c-b9d94337a70d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_FiberMoveCtl
VAR_INPUT
	i_xEn									: BOOL;
	i_iUnitNum								: INT;(*色组数*)
	i_abyGrpAxisList						: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (*系的轴列表*)
	i_pastStFiberMoveStepDriver				:POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StFiberMoveStepDriver;
	i_rFiberVel								:REAL;
	i_rFiberVel_Fast						:REAL;
	i_xFlag_Estop							: BOOL;
	i_xFlag_Stop							: BOOL;
	i_xIsDebugMode							:BOOL;
	i_pxFiberMovePosCal_ByUnit				:POINTER TO BOOL;//标定使能
	i_pxFiberMovePosCal_ByOnline			:POINTER TO BOOL;//标定使能
	i_arDistanceIn_HMI						:ARRAY[1..MAX_UNIT_NUM] OF REAL;//从站界面距离输入值
	i_arWidth_FindMarkCenter				:ARRAY[1..MAX_UNIT_NUM] OF REAL;//从站找中色标宽度
	i_xUseOnline							:BOOL;//使用在线检测
	i_rBasePosByOnline						:REAL;//在线检测确认的基准位置
	i_pxFiberMoveDisRunStart_AllUnit		:POINTER TO BOOL;//所有色组同步运动使能
	i_rFiberMoveDistance_AllUnit			:REAL;//所有色组同步运动距离
	i_pxConfirm_AllUnit						:POINTER TO BOOL;//色组标定确认目标色按钮，其余色组运动到目标色组位置
	i_pstStSysParam: 						 POINTER TO StSysParam;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iLp: INT;
	iN: INT;
	iM:INT;
	iK:INT;
	xInit:BOOL;
	rBasePos_Temp:REAL;
	rDistance_Temp:REAL;
	iBasePosID:INT;//基准位置轴ID
	rMoveDistance_Current:REAL;
	arMoveDistance_FindMarkCenter:ARRAY[1..2] OF REAL:=[-3,6];
	axFiberMoveMotorRunning_pre:ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	xAllAxisIdle: BOOL;
	aiCount_Delay_FindMarkCenter:ARRAY[1..MAX_UNIT_NUM] OF INT;
	tCurrentTime:TIME;
	tDurationTime:TIME;
	iTargetPosID_DebugUnit:INT;//色组标定的目标轴ID
	rTargetPos_DebugUnit:REAL;//色组标定目标位置
	aiCount_DelayGoRun:ARRAY[1..MAX_UNIT_NUM] OF INT;
	
	//超时常量
	tTIMEOUT_GOHOME:TIME        := T#30S;   // 回零超时：30秒
    tTIMEOUT_RUN:TIME           := T#60S;   // 运动超时：60秒
    tTIMEOUT_GETBASEPOS:TIME    := T#20S;    // 获取基准位置超时：2秒
	sLogMsg:STRING;
	sTimeStamp_Tmp :STRING;
	
	
	//2026.07.06.155408 更新
	rPendingBasePosValue:REAL;
	iPendingBasePosID:INT;
	xPendingBasePos:BOOL;
	tPendingStartTime:TIME;
	xAllSlaveIdle:BOOL;
	tIdleStableStartTime:time;
END_VAR

{IMPLEMENTATION}
// =============================== 主程序逻辑 ===============================
IF i_xEn THEN
    IF NOT xInit THEN
        // 所有轴上电强制进入回零状态，初始化关键变量
        FOR iLp:=1 TO i_iUnitNum BY 1 DO
            iN := i_abyGrpAxisList[iLp];
			//2026.08.05.170343
			 // 状态初始化
			i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_GOHOME;
			i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning := FALSE; // 运动标记
			i_pastStFiberMoveStepDriver^[iN].xFiberMoveMotorRunning := FALSE;
			i_pastStFiberMoveStepDriver^[iN].iFiberMoveCountGoHome:=0;
			// 回零触发标记
			i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsHoming := FALSE;
			i_pastStFiberMoveStepDriver^[iN].xFiberMove_GoHomeDoneByDebug:=FALSE;
			
			// 运动参数初始化
			i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 0;
			i_pastStFiberMoveStepDriver^[iN].byFiberMoveDir := 0;
			i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn := 0;
			i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceOut := 0;
			i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistancePre := 0.0;
			//i_pastStFiberMoveStepDriver^[iN].rFiberMoveAdjust := 0.0;
			axFiberMoveMotorRunning_pre[iN]:=0;
			
			// 同步相关标记初始化
			i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := FALSE;
			i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing := FALSE;
			
			// 初始化状态时间戳
			i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();  
        END_FOR;
        xInit:=TRUE;
    END_IF

    // 主循环
    FOR iLp:=1 TO i_iUnitNum BY  1 DO
        iN:= i_abyGrpAxisList[iLp];
		IF i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
			// 超时检测（仅对非空闲、非报警状态进行）
			IF i_pastStFiberMoveStepDriver^[iN].iFiberMoveState <> FIBERMOVE_IDLE AND
			   i_pastStFiberMoveStepDriver^[iN].iFiberMoveState <> FIBERMOVE_ALARM THEN
				tCurrentTime := TIME();
				tDurationTime := tCurrentTime - i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime;
				CASE i_pastStFiberMoveStepDriver^[iN].iFiberMoveState OF
					FIBERMOVE_GOHOME:
						IF tDurationTime > tTIMEOUT_GOHOME THEN
							// 超时处理：停止运动并复位至空闲
							KS_TimeOutCtl_FiberMove(ADR(i_pastStFiberMoveStepDriver^[iN]));
						END_IF
					FIBERMOVE_RUN:
						IF tDurationTime > tTIMEOUT_RUN THEN
							KS_TimeOutCtl_FiberMove(ADR(i_pastStFiberMoveStepDriver^[iN]));
						END_IF
					FIBERMOVE_GETBASEPOS:
						IF tDurationTime > tTIMEOUT_GETBASEPOS THEN
							KS_TimeOutCtl_FiberMove(ADR(i_pastStFiberMoveStepDriver^[iN]));
						END_IF
					// 其他状态（ALARM/IDLE）不处理
				END_CASE
			END_IF
	
			
			
			IF(NOT(i_xFlag_Estop OR i_pastStFiberMoveStepDriver^[iN].xFiberMoveLimit_Left OR i_pastStFiberMoveStepDriver^[iN].xFiberMoveLimit_Right 
				OR i_pastStFiberMoveStepDriver^[iN].uiFiberMoveAlarm>0))THEN // 无急停和限位和报警
				CASE i_pastStFiberMoveStepDriver^[iN].iFiberMoveState OF
					FIBERMOVE_GOHOME://回零状态
						IF i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode<>3 THEN
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning := TRUE;
							// 当前RUN是回零触发的
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsHoming := TRUE;
							// 切换到RUN状态执行回零指令
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_RUN;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
						ELSE
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
							i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 0;
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsHoming := FALSE;
							i_pastStFiberMoveStepDriver^[iN].xFiberMove_GoHomeDoneByDebug:=FALSE;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳	
						END_IF
	
					FIBERMOVE_IDLE://空闲状态
						// 获取基准位置(*手动移动和在线检测*)
						IF(i_pastStFiberMoveStepDriver^[iN].xFiberMoveBasePosDone) OR (i_xUseOnline AND i_pastStFiberMoveStepDriver^[iN].xBasePosDoneByOnline)THEN
	//2026.07.06.154921 更新
	//                         IF(i_xUseOnline AND i_pastStFiberMoveStepDriver^[iN].xBasePosDoneByOnline) THEN//在线检测
	//                             rBasePos_Temp:=i_rBasePosByOnline;
	//                             i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_GETBASEPOS;
	// 							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
	//                         ELSIF i_pastStFiberMoveStepDriver^[iN].xFiberMoveBasePosDone THEN//手动移动
	//                             //获取基准轴的信息
	//                             //rBasePos_Temp:=i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur;
	// 							//2026.05.28.180119
	// 							rBasePos_Temp:=i_pastStFiberMoveStepDriver^[iN].rFiberMoveBasePosFromSlave;
	// 							//2026.06.03.203635
	//                             //i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := TRUE;
	//                             iBasePosID:=iN;
	//                             i_pastStFiberMoveStepDriver^[iN].xFiberMoveBasePosDone:=FALSE;
	//                             //所有轴都去到下一个状态
	//                             FOR iM := 1 TO i_iUnitNum BY 1 DO
	//                                 iK := i_abyGrpAxisList[iM];
	//                                 i_pastStFiberMoveStepDriver^[iK].iFiberMoveState := FIBERMOVE_GETBASEPOS;
	// 								i_pastStFiberMoveStepDriver^[iK].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
	//                             END_FOR
	//                         END_IF
	
							IF(i_xUseOnline AND i_pastStFiberMoveStepDriver^[iN].xBasePosDoneByOnline) THEN//在线检测
								rPendingBasePosValue := i_rBasePosByOnline;
								i_pastStFiberMoveStepDriver^[iN].xBasePosDoneByOnline := FALSE; 
							ELSIF i_pastStFiberMoveStepDriver^[iN].xFiberMoveBasePosDone THEN//手动移动	
								rPendingBasePosValue := i_pastStFiberMoveStepDriver^[iN].rFiberMoveBasePosFromSlave;
								iPendingBasePosID := iN;  // 记录发起轴，用于后续补偿计算
								//清除触发标志，防止本周期再次进入
								i_pastStFiberMoveStepDriver^[iN].xFiberMoveBasePosDone := FALSE;
							END_IF
							//置位挂起标志，并记录挂起时间（用于超时）
							xPendingBasePos := TRUE;
							tPendingStartTime := TIME();
						//同步其余轴位置
						ELSIF i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing THEN
							IF(i_xUseOnline) THEN//在线检测
								IF ABS(i_pastStFiberMoveStepDriver^[iN].rFiberMove_BasePos - i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur)>=0.2 THEN
									i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn := i_pastStFiberMoveStepDriver^[iN].rFiberMove_BasePos - i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur;
									i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_RUN;
									i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
									i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning := TRUE;
									i_pastStFiberMoveStepDriver^[iN].rFiberMovePosStart := i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur;
									i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := FALSE;
								ELSE
									i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
									i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
									i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing:=FALSE;
									i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := TRUE;
								END_IF
	
							ELSE//手动移动
								IF(iN<>iBasePosID) THEN
									//2026.05.20.142036
									IF ABS(i_pastStFiberMoveStepDriver^[iN].rFiberMove_BasePos - i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur)>=0.2 THEN
										i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn := i_pastStFiberMoveStepDriver^[iN].rFiberMove_BasePos - i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur;
										i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_RUN;
										i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
										i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning := TRUE;
										i_pastStFiberMoveStepDriver^[iN].rFiberMovePosStart := i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur;
										i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := FALSE;
									ELSE
										i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
										i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
										i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing:=FALSE;
										i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := TRUE;
									END_IF
								//2026.06.03.205205
								ELSE//基准轴
									IF i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=0 AND i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur>0 THEN//从站空闲/回零结束
										i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone:=TRUE;
										i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing :=FALSE;
										i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
										i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
									END_IF
								END_IF
							END_IF
							
						//调试触发回零/调试确定
						ELSIF i_xIsDebugMode AND (( NOT i_pastStFiberMoveStepDriver^[iN].xFiberMove_GoHomeDoneByDebug)
							OR(i_pxConfirm_AllUnit^)) THEN
							IF NOT i_pastStFiberMoveStepDriver^[iN].xFiberMove_GoHomeDoneByDebug THEN//调试回零
								i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_GOHOME;
								i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
								i_pastStFiberMoveStepDriver^[iN].xFiberMove_GoHomeDoneByDebug:=TRUE;
							ELSIF i_pxConfirm_AllUnit^ THEN //标定模式中其余色组运动至基准色同位置
								//找到目标值的轴ID和目标值
								FOR iM:=1 TO i_iUnitNum BY  1 DO
									iK:= i_abyGrpAxisList[iM];
									IF(i_pastStFiberMoveStepDriver^[iK].rFiberMovePosCur>1) THEN//有效位置的轴
										iTargetPosID_DebugUnit:=iK;
										rTargetPos_DebugUnit:=i_pastStFiberMoveStepDriver^[iK].rFiberMovePosCur;
										EXIT;
									END_IF
								END_FOR
								//非目标值的运动启动
								FOR iM:=1 TO i_iUnitNum BY  1 DO
									iK:= i_abyGrpAxisList[iM];
									IF(iK<>iTargetPosID_DebugUnit) THEN
										i_pastStFiberMoveStepDriver^[iK].rFiberMoveDistanceIn:=rTargetPos_DebugUnit;
										i_pastStFiberMoveStepDriver^[iK].iFiberMoveState := FIBERMOVE_RUN;
										i_pastStFiberMoveStepDriver^[iK].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
										i_pastStFiberMoveStepDriver^[iK].xFiberMoveRunning := TRUE;
										i_pastStFiberMoveStepDriver^[iK].rFiberMovePosStart:=i_pastStFiberMoveStepDriver^[iK].rFiberMovePosCur;
										i_pastStFiberMoveStepDriver^[iK].xFiberMoveIsSyncing := FALSE;
									END_IF
								END_FOR
								i_pxConfirm_AllUnit^:=FALSE;
							END_IF
						//手动左移/右移
						ELSIF((i_pastStFiberMoveStepDriver^[iN].xFiberMoveLeft OR i_pastStFiberMoveStepDriver^[iN].xFiberMoveRight)AND
							 NOT i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning) THEN
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_RUN;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning := TRUE;
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing := FALSE;
						//定长运动
						ELSIF (i_pastStFiberMoveStepDriver^[iN].xFiberMoveDisRunStart AND NOT i_pastStFiberMoveStepDriver^[iN].xFiberMoveMotorRunning) AND ABS(i_arDistanceIn_HMI[iN])>0 THEN
							i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn:=i_arDistanceIn_HMI[iN];
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_RUN;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning := TRUE;
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveDisRunStart:=FALSE;
							i_pastStFiberMoveStepDriver^[iN].rFiberMovePosStart:=i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur;
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing := FALSE;
						//主站启动所有色定长运动
						ELSIF (i_pxFiberMoveDisRunStart_AllUnit^ (*AND xAllAxisIdle*))	THEN
							FOR iM:=1 TO i_iUnitNum BY  1 DO
								iK:= i_abyGrpAxisList[iM];
								i_pastStFiberMoveStepDriver^[iK].rFiberMoveDistanceIn:=i_rFiberMoveDistance_AllUnit;
								i_pastStFiberMoveStepDriver^[iK].iFiberMoveState := FIBERMOVE_RUN;
								i_pastStFiberMoveStepDriver^[iK].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
								i_pastStFiberMoveStepDriver^[iK].xFiberMoveRunning := TRUE;
								i_pastStFiberMoveStepDriver^[iK].rFiberMovePosStart:=i_pastStFiberMoveStepDriver^[iK].rFiberMovePosCur;
								i_pastStFiberMoveStepDriver^[iK].rFiberMoveDistancePre:=i_rFiberMoveDistance_AllUnit;
								i_pastStFiberMoveStepDriver^[iK].xFiberMoveIsSyncing := FALSE;
							END_FOR
							i_pxFiberMoveDisRunStart_AllUnit^:=FALSE;
						//启动色组单独回零
						ELSIF (i_pastStFiberMoveStepDriver^[iN].xFiberMove_RunHomeStart)THEN
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_GOHOME;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
						END_IF
	
						// 调试标定逻辑
						IF i_xIsDebugMode (*AND xAllAxisIdle*) THEN
							IF i_pxFiberMovePosCal_ByUnit^ THEN//标定色组中修正
								FOR iM:=1 TO i_iUnitNum BY  1 DO
									iK:= i_abyGrpAxisList[iM];
									i_pastStFiberMoveStepDriver^[iK].rFiberMoveAdjust:=i_pastStFiberMoveStepDriver^[iK].rFiberMovePosCur - rTargetPos_DebugUnit;
								END_FOR
								i_pxFiberMovePosCal_ByUnit^:=0;
							ELSIF i_pxFiberMovePosCal_ByOnline^ THEN//标定在线检测修正
								FOR iM:=1 TO i_iUnitNum BY  1 DO
									iK:= i_abyGrpAxisList[iM];
									i_pastStFiberMoveStepDriver^[iK].rFiberMoveAdjust_ByOnline:=i_pastStFiberMoveStepDriver^[iK].rFiberMovePosCur - i_pastStFiberMoveStepDriver^[iK].rFiberMoveDistancePre;			
								END_FOR
								i_pxFiberMovePosCal_ByOnline^:=0;
							END_IF
						ELSE//清除调试回零过的状态
							i_pastStFiberMoveStepDriver^[iN].xFiberMove_GoHomeDoneByDebug:=FALSE;
						END_IF
						
					FIBERMOVE_RUN://运动状态（赋值运动参数）
						// ========== 仅首次进入RUN时赋值参数 ==========
						IF i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning THEN
							// 1. 回零模式参数赋值（靠xFiberMoveIsHoming标记判断，不是状态）/从站状态机空闲
							IF i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsHoming AND (i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=0)  THEN
	
								i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 3; // 回零模式
							// 2. 手动连续运动参数赋值/从站状态机空闲
							ELSIF (i_pastStFiberMoveStepDriver^[iN].xFiberMoveLeft OR i_pastStFiberMoveStepDriver^[iN].xFiberMoveRight) AND (i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=0) THEN
	
								i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 1; // 连续模式
								i_pastStFiberMoveStepDriver^[iN].byFiberMoveDir := BOOL_TO_BYTE(i_pastStFiberMoveStepDriver^[iN].xFiberMoveLeft);
							// 3. 定长运动（含同步轴）参数赋值/从站状态机空闲
							ELSIF ABS(i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn) > 0  AND (i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=0) THEN
	
								i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 2; // 定长模式
								// 方向判断
								IF i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn > 0 THEN
									i_pastStFiberMoveStepDriver^[iN].byFiberMoveDir := 0;
								ELSE
									i_pastStFiberMoveStepDriver^[iN].byFiberMoveDir := 1;
								END_IF
								// 距离转正值
								i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceOut := ABS(i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn);
								sLogMsg := CONCAT('AXIS : ', INT_TO_STRING(iN));
								sLogMsg := CONCAT(sLogMsg, '@');
								sLogMsg := CONCAT(sLogMsg, BYTE_TO_STRING(i_pastStFiberMoveStepDriver^[iN].byFiberMoveDir));
								sLogMsg := CONCAT(sLogMsg, '_');
								sLogMsg := CONCAT(sLogMsg, REAL_TO_STRING( i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceOut));
								KS_HY_AddMsgToLog(
									g_pstStHYLogFifo, 
									LOG_LEVEL_DEBUG, 
									'DistanceOut',
									sLogMsg);	
							END_IF
							
							//进入运行状态起始从站不在空闲状态，那么直接退出
							IF (i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave<>0) THEN
	
								i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
								i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
							END_IF
							// 重置Running
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning := FALSE;
						END_IF
	
						// 回零模式停止判断（优先）
						IF i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode=3 THEN
							IF i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=666 OR i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=777 THEN
								i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 0;
								i_pastStFiberMoveStepDriver^[iN].iFiberMoveCountGoHome:=i_pastStFiberMoveStepDriver^[iN].iFiberMoveCountGoHome+1;
								// 重置回零标记
								i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsHoming := FALSE;
								i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
								i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
								//2026.05.28.110712
								i_pastStFiberMoveStepDriver^[iN].xFiberMove_RunHomeStart:=FALSE;
							END_IF
						 // 连续运动停止判断
						ELSIF i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode=1 THEN
							IF(NOT i_pastStFiberMoveStepDriver^[iN].xFiberMoveLeft AND NOT i_pastStFiberMoveStepDriver^[iN].xFiberMoveRight) OR ((NOT i_pastStFiberMoveStepDriver^[iN].xFiberMoveMotorRunning) AND axFiberMoveMotorRunning_pre[iN]) THEN
								i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 0;
								i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
								i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
							END_IF
						// 定长运动停止判断
						ELSIF i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode=2 THEN	
	//                      rMoveDistance_Current:=ABS(i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur-i_pastStFiberMoveStepDriver^[iN].rFiberMovePosStart);
	// 						sTimeStamp_Tmp:= KS_GetTimeString(TIMEFORMAT_HYPHEN_DOT, TRUE, TRUE);
	// 						sLogMsg := CONCAT('AXIS : ', INT_TO_STRING(iN));
	// 						sLogMsg := CONCAT(sLogMsg, '_');
	// 						sLogMsg := CONCAT(sLogMsg, REAL_TO_STRING(rMoveDistance_Current));
	// 						sLogMsg := CONCAT(sLogMsg, '_');
	// 						sLogMsg := CONCAT(sLogMsg, REAL_TO_STRING(i_pastStFiberMoveStepDriver^[iN].rFiberMovePosCur));
	// 						sLogMsg := CONCAT(sLogMsg, '_');
	// 						sLogMsg := CONCAT(sLogMsg, REAL_TO_STRING(i_pastStFiberMoveStepDriver^[iN].rFiberMovePosStart));
	// 						sLogMsg := CONCAT(sLogMsg, '_');
	// 						sLogMsg := CONCAT(sLogMsg, REAL_TO_STRING(i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceOut));
	// 						sLogMsg := CONCAT(sLogMsg, '@');
	// 						sLogMsg := CONCAT(sLogMsg, sTimeStamp_Tmp);
	// 						KS_HY_AddMsgToLog(
	// 							g_pstStHYLogFifo, 
	// 							LOG_LEVEL_DEBUG, 
	// 							'FiberStop',
	// 							sLogMsg);
							//IF(rMoveDistance_Current>=(i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceOut-0.5))  (*OR ((NOT i_pastStFiberMoveStepDriver^[iN].xFiberMoveMotorRunning) AND axFiberMoveMotorRunning_pre[iN])*) THEN
							//从站状态机从0更新为666，本次运动结束
							IF i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=666 OR i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=777 THEN
								//记录超时次数
								IF i_pastStFiberMoveStepDriver^[iN].iFiberMove_StsSlave=777 THEN
									i_pastStFiberMoveStepDriver^[iN].iFiberMove_OutTimeCount:=+1;
								END_IF
								i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode := 0;
								i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceOut := 0;
								i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceIn := 0;
								 // 同步完成标记
								IF i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing THEN
									i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := TRUE;
									i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing := FALSE;
								END_IF
								i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
								i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
							ELSE
								;
							END_IF
						END_IF
						//获取上一周期电机运行状态
						axFiberMoveMotorRunning_pre[iN]:=i_pastStFiberMoveStepDriver^[iN].xFiberMoveMotorRunning;
						
					FIBERMOVE_GETBASEPOS://获取基准位置
						IF(i_xUseOnline AND i_pastStFiberMoveStepDriver^[iN].xBasePosDoneByOnline) THEN//在线检测
							i_pastStFiberMoveStepDriver^[iN].rFiberMove_BasePos:=rBasePos_Temp+i_pastStFiberMoveStepDriver^[iN].rFiberMoveAdjust_Use+i_pastStFiberMoveStepDriver^[iN].rFiberMoveAdjustByOnline_Use;
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing :=TRUE;
							i_pastStFiberMoveStepDriver^[iN].xBasePosDoneByOnline:=FALSE;
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
						ELSE//手动移动
							i_pastStFiberMoveStepDriver^[iN].rFiberMove_BasePos:=rBasePos_Temp+(i_pastStFiberMoveStepDriver^[iN].rFiberMoveAdjust_Use-i_pastStFiberMoveStepDriver^[iBasePosID].rFiberMoveAdjust_Use);
							i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing :=TRUE;
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
						END_IF
	
					FIBERMOVE_ALARM://报警
						IF i_pastStFiberMoveStepDriver^[iN].uiFiberMoveAlarm=0 AND NOT i_xFlag_Estop THEN
							i_pastStFiberMoveStepDriver^[iN].iFiberMoveState := FIBERMOVE_IDLE;
							i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 状态切换，更新时间戳
						END_IF
				END_CASE
			ELSE//急停/限位/报警：强制停止
				i_pastStFiberMoveStepDriver^[iN].iFiberMoveState:=FIBERMOVE_ALARM;
				i_pastStFiberMoveStepDriver^[iN].xFiberMoveRunning:=FALSE;
				i_pastStFiberMoveStepDriver^[iN].byFiberMoveMode:=0;
				i_pastStFiberMoveStepDriver^[iN].rFiberMoveDistanceOut:=0;
				// 重置所有标记
				i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsHoming := FALSE;
				i_pastStFiberMoveStepDriver^[iN].xFiberMoveIsSyncing := FALSE;
				i_pastStFiberMoveStepDriver^[iN].xFiberMoveSyncDone := FALSE;
				
				i_pastStFiberMoveStepDriver^[iN].xFiberMove_GoHomeDoneByDebug:=FALSE;
				i_pastStFiberMoveStepDriver^[iN].tFiberMove_StateTime := TIME();   // 重置时间戳，防止超时误触发（尽管ALARM状态不检测）
			END_IF
		END_IF
    END_FOR;
	
	//2026.07.06.161151 更新
	// ======== 挂起的基准定位请求处理（含2s空闲稳定确认） ========
	IF xPendingBasePos THEN
		
		// 1. 检查所有轴从站是否物理空闲（瞬时状态）
		xAllSlaveIdle := TRUE;
		FOR iM := 1 TO i_iUnitNum BY 1 DO
			iK := i_abyGrpAxisList[iM];
			IF i_pstStSysParam^.astStUnitParam_Save[iK].xLinkage THEN
				IF i_pastStFiberMoveStepDriver^[iK].iFiberMove_StsSlave <> 0 THEN
					xAllSlaveIdle := FALSE;
					EXIT;
				END_IF
			END_IF

		END_FOR
	
		// 2. 空闲状态持续2s@从站有回零后间隔时间继续运动的动作，有冲突
		IF xAllSlaveIdle THEN
			// 当前所有轴空闲
			IF tIdleStableStartTime = T#0s THEN
				// 首次检测到空闲 -> 开始计时
				tIdleStableStartTime := TIME();
			END_IF	
			// 判断空闲是否稳定持续 >= 2秒
			IF (TIME() - tIdleStableStartTime) >= T#2s THEN
				// ---------- 稳定空闲，正式执行基准定位 ----------
				// 将缓存的基准值赋给临时变量
				rBasePos_Temp := rPendingBasePosValue;
				// 恢复发起轴ID，供 GETBASEPOS 中 adjust 差值计算使用
				iBasePosID := iPendingBasePosID;	
				// 广播所有轴进入 FIBERMOVE_GETBASEPOS
				FOR iM := 1 TO i_iUnitNum BY 1 DO
					iK := i_abyGrpAxisList[iM];
					IF i_pstStSysParam^.astStUnitParam_Save[iK].xLinkage THEN
						i_pastStFiberMoveStepDriver^[iK].iFiberMoveState := FIBERMOVE_GETBASEPOS;
						i_pastStFiberMoveStepDriver^[iK].tFiberMove_StateTime := TIME();
					END_IF
				END_FOR
				// 清除挂起标志和所有相关计时器
				xPendingBasePos := FALSE;
				tIdleStableStartTime := T#0s;
			END_IF	
		ELSE
			// 只要有任意一个轴忙碌 -> 立即重置空闲稳定计时器
			tIdleStableStartTime := T#0s;
		END_IF
		// 3. 超时保护（避免因从站故障导致请求永久挂起）
		IF xPendingBasePos AND (TIME() - tPendingStartTime) > T#60S THEN
			// 超时处理：强制清除挂起，并触发一个报警
			xPendingBasePos := FALSE;
			tIdleStableStartTime := T#0s;
		END_IF
	END_IF
END_IF
