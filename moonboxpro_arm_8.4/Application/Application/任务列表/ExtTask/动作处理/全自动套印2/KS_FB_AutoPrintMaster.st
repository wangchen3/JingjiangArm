(*@CES
Name=KS_FB_AutoPrintMaster
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8faa04dc-26bf-43df-9e4a-ef930424aed8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AutoPrintMaster
VAR_INPUT
    (* 基本输入 *)
    i_xEn: BOOL;                         (* 主使能 *)
    i_rVel: REAL;                        (* 料膜速度@m/min *)
    i_rMachineryFilmLenth: REAL;         (* 机器总料长@m *)
    i_xTipsConfirm: BOOL;                (* 提示确认标志@沿触发 *)
    i_xUseAutoPreRegister_Hor: BOOL;     (* 使用横向对版功能 *)
    i_xAutoPreRegisterIdle_Hor: BOOL;    (* 横向预对版空闲状态 *)
    i_xAutoPreRegistering_Hor: BOOL;     (* 横向预对版中 *)
    i_xUseAutoSensorPos: BOOL;           (* 自动传感器位置@否则直接到纵向全自动纵向套印 *)
    i_xUseSensorPos_3rd: BOOL;           (* 使用第三方设备位置@在线|否则手动移动 *)
    i_xSensorPosValid_3rd: BOOL;         (* 传感器位置有效 *)
    i_rSenserPos_3rd: REAL;              (* 传感器位置@单位未知,暂定一个值 *)
    i_xSensorPosValid_Manu: BOOL;        (* 手动传感器值有效 *)
    i_rSensorPos_Manu: REAL;             (* 手动传感器值@绝对位置@mm *)
    i_xUseFindBestPosStep: BOOL;         (* 使用寻找最佳位置步 *)
	i_xSwitch_RFailure: BOOL;            (** R失效开关 **)
    i_xSwitch_FFailure: BOOL;            (** F失效开关 **)
    
    (* 轴配置 *)
    i_byAxisNum: BYTE;                   (* 轴个数@全自动套印轴 *)
    i_aiAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 轴列表 *)
    i_pafbKS_FB_AxisFindModule: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF KS_FB_AxisFindModule;
    
    (* 系统参数 *)
    i_pstStSysParam: POINTER TO StSysParam;
    i_pastStIOMap_AxisBasic: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;
    
    (* 快速对版参数 *)
    i_pastStAxisRapidAdjProf_V: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_V; (* 快速对版参数数组 *)
    
    (* 轴状态输入 *)
    i_abyRapidAdjustStep: ARRAY[1..MAX_UNIT_NUM] OF BYTE; (* 各轴快速对版步骤 *)
	i_pastFindResults :POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StFindResult;
END_VAR
VAR_OUTPUT
    (* 状态输出 *)
    o_xEning: BOOL;                      (* 使能中 *)
    o_xAlarm: BOOL;                      (* 3s响铃输出 *)
   // o_xWaitingFilmLenthEn: BOOL;         (* 等料长使能 *)
    o_xAutoPreRegister_Hor: BOOL;        (* 横向自动对版@启动预套后复位 *)
   // o_xExcuteRollerPress_LastAxis: BOOL; (* 最后一个轴执行压辊动作@长有效 *)
    o_xManuConfirmSensorPos_LastAxis: BOOL; (* 最后一个轴手动确认传感器位置标志 *)
    
    (* 传感器电机运动 *)
    o_xSensorGoTargetPos_All: BOOL;      (* 所有轴向目标位置运动@到位后清除 *)
    o_rSenserTarPos_All: REAL;           (* 运动的目标位置 *)
    
    (* 动作控制 *)
    o_xExcuteAutoPreRegister_Ver: BOOL;  (* 执行纵向自动套印 *)
    o_xExcuteAutoPreRegisterDne_Ver: BOOL;(* 执行纵向自动套印完成 *)
    o_xExcuteAutoPreRegisterFailed_Ver: BOOL; (* 执行纵向自动套印失败 *)
    o_xAutoPreRegisterFinish_Ver: BOOL;  (* 执行纵向自动套印完成 *)
    o_byArcAdjAutoCtl: BYTE;             (* 套色手自动控制 *)
    
    (* 状态信息 *)
    o_eSts: EnumAutoPrintMasterStep;     (* 主状态机状态 *)
    o_iMsgInf: EnumAutoMaticRegisterCtlMsg; (* 信息 *)
    
    (* 轴控制输出 *)
    o_axAxisFindModuleEn: ARRAY[1..MAX_UNIT_NUM] OF BOOL; (* 轴寻找模块使能 *)
    o_axAxisCmd: ARRAY[1..MAX_UNIT_NUM] OF EnumFindCommand; (* 轴命令 *)
    
    (* 寻找结果 *)
 //   o_astFindResult: ARRAY[1..MAX_UNIT_NUM] OF StFindResult; (* 各轴寻找结果 *)
    o_xAllFindComplete: BOOL;            (* 所有轴寻找完成 *)
    
    (* 调整量输出 *)
    o_arAdjValue_Point: ARRAY[1..MAX_UNIT_NUM] OF REAL; (* 调整量@点 *)
    o_axAxisStartPress: ARRAY[1..MAX_UNIT_NUM] OF BOOL; (* 合压输出 *)
	o_arAdjPos_um	:ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*色组调整了*)
    
    (* 流水线状态 *)
    o_iCurrentAxisIndex: INT;            (* 当前处理的轴索引（从后往前） *)
    o_xCurrentAxisProcessing: BOOL;      (* 当前轴正在处理 *)
    
    (* 轴状态显示 *)
    o_eState: ARRAY[1..MAX_UNIT_NUM] OF EnumFindState; (* 各轴状态描述 *)
	o_iErrorCode: ARRAY[1..MAX_UNIT_NUM] OF EnumFindState; (* 各轴报错*)
END_VAR
VAR
    (* 主状态机 *)
    eMainSts: EnumAutoPrintMasterStep;
    iMsgInf: EnumAutoMaticRegisterCtlMsg;
    
    (* 准备阶段变量 *)
    fbTimeOutTon: TON;                   (* 超时计时器 *)
    iLastAxisId: INT;                    (* 最后一个轴id *)
    rWaitFilmLenth: REAL;                (* 等待的料长@m *)
    xCheckSensorToTargetPos: BOOL;       (* 检查传感器到达目标位置 *)
    rTmp: REAL;                          (* 临时变量 *)
    xTmp: BOOL;                          (* 临时布尔 *)
    
    (* 传感器相关 *)
    axRollerPressSts_In: ARRAY[1..MAX_UNIT_NUM] OF BOOL; (* 压辊状态 *)
    axSensorMotorIdle: ARRAY[1..MAX_UNIT_NUM] OF BOOL;   (* 传感器电机空闲 *)
    
    (* 寻找结果 *)
 //   astFindResult: ARRAY[1..MAX_UNIT_NUM] OF StFindResult;
    
    (* 控制标志 *)
    xNextStep: BOOL;                     (* 初始化完成 *)
    
    (* 轴间关系 *)
    aiBeforeAxisId: ARRAY[1..MAX_UNIT_NUM] OF INT; (* 前轴号 *)
    aiAfterAxisId: ARRAY[1..MAX_UNIT_NUM] OF INT;  (* 后轴号 *)
    
    (* 临时变量 *)
    iN: INT;
	iM:INT;
    iAxisId: INT;
	iAxisId_Calc :INT;
    iBeforeAxisId: INT;
    iAfterAxisId: INT;
    
    pstStGrpParam_Save: POINTER TO StGrpParam_Save;
    pstStUnitParam_Save: POINTER TO StUnitParam_Save;
    pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave;
    pstStRSV_GrpParam_Save: POINTER TO StRSV_GrpParam_Save;
    
    rGirth: REAL;
    rFilmLength: REAL;
    
    (* 寻找结果存储 *)
    aiCurBestSignalPos: ARRAY[1..MAX_UNIT_NUM] OF INT;  (* 当前色最佳位置 *)
    aiPreLabelPos: ARRAY[1..MAX_UNIT_NUM] OF INT;       (* 前色位置 *)
    
    (* 轴命令控制 *)
    axAxisCmdSingle: ARRAY[1..MAX_UNIT_NUM] OF BOOL;    (* 轴单色命令触发 *)
    axAxisCmdMix: ARRAY[1..MAX_UNIT_NUM] OF BOOL;       (* 轴混色命令触发 *)
    
    (* 新增：简化流水线状态管理 *)
    axAxisComplete: ARRAY[1..MAX_UNIT_NUM] OF BOOL;     (* 轴完成标志 *)
    axAxisNeedPress: ARRAY[1..MAX_UNIT_NUM] OF BOOL;    (* 轴需要合压标志 *)
    axAxisPressDone: ARRAY[1..MAX_UNIT_NUM] OF BOOL;    (* 轴合压完成标志 *)
    axAxisStartPressTriggered: ARRAY[1..MAX_UNIT_NUM] OF BOOL; (* 轴合压已触发标志 *)
    
    (* 新增：前轴合压请求记录 *)
    axBeforeAxisPressRequested: ARRAY[1..MAX_UNIT_NUM] OF BOOL; (* 前轴合压已请求 *)
    
    (* 新增：所有轴完成标志 *)
    xAllAxisComplete: BOOL;               (* 所有轴完成标志 *)
	xCalculationCompleted:BOOL;           (*所有轴调整量计算完成*)
    
    (* 新增：轴状态描述数组 *)
  //  asAxisStatus: ARRAY[1..MAX_UNIT_NUM] OF STRING(50); (* 各轴状态描述 *)
    
    (* 新增：第一轴合压完成标志 *)
    xFirstAxisPressComplete: BOOL;        (* 第一轴合压完成 *)
	
	(*快速调整计算*)
	iIndexTmp:INT;(*//临时索引*)
	iIndex1TO2:INT;(*//从前向后的当前索引*)
	iIndex2TO1:INT;(*//从后向前的当前索引*)
	iAxisNum_1TO2:INT;(*//从前向后轴个数*)
	aiAxisIdList_FastAdj_1TO2:ARRAY [1..MAX_UNIT_NUM] OF INT;(*//从前到后压辊轴id*)
	iAxisNum_2TO1:INT;(*//从后向前轴个数*)
	aiAxisIdList_FastAdj_2TO1:ARRAY [1..MAX_UNIT_NUM] OF INT;(*//从后向前压辊轴id*)
	xCanFastAdj:BOOL;(*//可以快速对版标志*)
	iNeedFastAdjAxisNum:INT;(*//需要快速对版轴个数*)
	axFastAdjing:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*//快速对版中*)
	iAxisIdTmp:INT;
	axAdjust_ing: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAdjust_finish: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xAllAdjust_finish:BOOL;
	byMeanANDAutoChangeCnt:BYTE;
	
END_VAR

{IMPLEMENTATION}
(* 初始化输出 *)
o_xAlarm := FALSE;
//o_xWaitingFilmLenthEn := FALSE;
o_xAutoPreRegister_Hor := FALSE;
o_xManuConfirmSensorPos_LastAxis := FALSE;
o_xSensorGoTargetPos_All := FALSE;
o_rSenserTarPos_All := 0;
o_xExcuteAutoPreRegister_Ver := FALSE;
o_xExcuteAutoPreRegisterDne_Ver := FALSE;
o_xExcuteAutoPreRegisterFailed_Ver := FALSE;
o_xAutoPreRegisterFinish_Ver := FALSE;
o_byArcAdjAutoCtl := 0;
o_xAllFindComplete := FALSE;
o_eSts := APM_STEP_IDLE;
o_iMsgInf := AMRC_MSG_NORMAL;
o_iCurrentAxisIndex := 0;
o_xCurrentAxisProcessing := FALSE;

FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
    o_axAxisFindModuleEn[iN] := FALSE;
    o_axAxisCmd[iN] := FIND_CMD_IDLE;
    i_pastFindResults^[iN].xSuccess := FALSE;
    i_pastFindResults^[iN].iErrorCode := 0;
   // 
   // o_axAxisStartPress[iN] := FALSE;
  //  o_axAxisStatus[iN] := '';
END_FOR

(* 检查指针有效性 *)
IF i_pstStSysParam = 0 OR
   i_pastStIOMap_AxisBasic = 0 OR
   i_pastStAxisRapidAdjProf_V = 0 OR
   i_pafbKS_FB_AxisFindModule = 0 THEN
    RETURN;
END_IF

(* 获取外部状态 *)
FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
    pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN]);
    axRollerPressSts_In[iN] := i_pastStIOMap_AxisBasic^[iN].o_xRel_Press;
    axSensorMotorIdle[iN] := pstStRSV_UnitParam_UnSave^.wState_FiberMove.8;
END_FOR

IF i_xEn THEN
    (* 前期准备阶段 *)
    rWaitFilmLenth := i_rMachineryFilmLenth ;  (* 等待机组料长等待 *)
    
    IF NOT o_xEning THEN
        (* 做参数初始化 *)
        o_xAlarm := FALSE;
        o_xAutoPreRegister_Hor := FALSE;
        o_xSensorGoTargetPos_All := FALSE;
        o_xManuConfirmSensorPos_LastAxis := FALSE;
        o_rSenserTarPos_All := 0;
        o_xExcuteAutoPreRegister_Ver := FALSE;
        o_xAutoPreRegisterFinish_Ver := FALSE;
       // o_xWaitingFilmLenthEn := FALSE;
        o_byArcAdjAutoCtl := 2;  (* 套色手动 *)
        
        fbTimeOutTon(IN:=FALSE);
        iLastAxisId := 0;
        xCheckSensorToTargetPos := FALSE;
        
        (* 计算最后一个轴ID *)
        IF i_byAxisNum > 0 AND i_byAxisNum <= MAX_UNIT_NUM THEN
            iLastAxisId := i_aiAxisList[i_byAxisNum];
        END_IF
        
        (* 初始化寻找结果 *)
        FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
            i_pastFindResults^[iN].xSuccess := FALSE;
            i_pastFindResults^[iN].iErrorCode := 0;
			o_arAdjValue_Point[iN] := 0.0;
			o_arAdjPos_um[iN] := 0.0;
			(* 初始化状态标志 *)
            axAxisComplete[iN] := FALSE;
            axAxisNeedPress[iN] := FALSE;
            axAxisPressDone[iN] := FALSE;
            axAxisStartPressTriggered[iN] := FALSE;
            axBeforeAxisPressRequested[iN] := FALSE;
            axAxisCmdSingle[iN] := FALSE;
            axAxisCmdMix[iN] := FALSE;
			//2026.05.19.200017+
			axAdjust_ing[iN]:=FALSE;
			axFastAdjing[iN]:=FALSE;
			axAdjust_finish[iN]:=FALSE;
        END_FOR
        
        (* 初始化轴间关系 *)
        FOR iN := 1 TO i_byAxisNum BY 1 DO
            iAxisId := i_aiAxisList[iN];
            
            (* 计算前后轴关系 *)
            IF iN = 1 THEN
                (* 第一个轴 *)
                aiBeforeAxisId[iAxisId] := -1;
                aiAfterAxisId[iAxisId] := i_aiAxisList[2];
            ELSIF iN = i_byAxisNum THEN
                (* 最后一个轴 *)
                aiBeforeAxisId[iAxisId] := i_aiAxisList[i_byAxisNum-1];
                aiAfterAxisId[iAxisId] := -1;
            ELSE
                (* 中间轴 *)
                aiBeforeAxisId[iAxisId] := i_aiAxisList[iN-1];
                aiAfterAxisId[iAxisId] := i_aiAxisList[iN+1];
            END_IF
		   //o_axAxisStartPress[iAxisId] := TRUE;
          //  asAxisStatus[iAxisId] := '空闲';
        END_FOR
		xNextStep:=TRUE;
		FOR iN:=2 TO i_byAxisNum BY 1 DO(*开始的时候全部打手动*)
			iAxisId:= i_aiAxisList[iN];
			pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[iAxisId]);
			IF pstStUnitParam_Save^.dwFlag_Sts.0 OR pstStUnitParam_Save^.dwFlag_Sts.1 THEN
				pstStUnitParam_Save^.dwFlag_Sts.0:= FALSE;
				pstStUnitParam_Save^.dwFlag_Sts.1:= FALSE;
				xNextStep:=FALSE;			
			END_IF
		END_FOR
        (* 初始化全自动控制变量 *)
        xAllAxisComplete := FALSE;
        xFirstAxisPressComplete := FALSE;
		xCanFastAdj:=FALSE;
		
        IF xNextStep THEN
			o_xEning := TRUE;
			eMainSts := APM_STEP_TIPS;
			iMsgInf := AMRC_MSG_NORMAL;
		END_IF
      //  xInitDone := FALSE;
    END_IF
    
    (* 主状态机处理 - 前期准备阶段 *)
    CASE eMainSts OF
        APM_STEP_IDLE:
            (* 空闲状态 *)
            ;
            
        APM_STEP_TIPS:
            IF i_xTipsConfirm THEN
                eMainSts := APM_STEP_TIPS_ALARM;
            END_IF
            
        APM_STEP_TIPS_ALARM:
            o_xAlarm := TRUE;
            fbTimeOutTon(IN:=TRUE, PT:=T#3S);
            
            IF fbTimeOutTon.Q THEN
                IF i_xUseAutoPreRegister_Hor THEN
                    eMainSts := APM_STEP_AUTO_HOR;
                ELSE
                    IF i_xUseAutoSensorPos THEN
                        eMainSts := APM_STEP_AUTOSENSORPOS;
                    ELSE
                        eMainSts := APM_STEP_AUTO_VER;
                    END_IF 
                END_IF
            END_IF
            
            (* 复位计时器 *)
            IF eMainSts <> APM_STEP_TIPS_ALARM THEN
                o_xAlarm := FALSE;
                fbTimeOutTon(IN:=FALSE);
            END_IF
            
        (* 横向动作状态处理 *)
        APM_STEP_AUTO_HOR:
            IF i_xAutoPreRegisterIdle_Hor THEN
                o_xAutoPreRegister_Hor := TRUE;
                
                IF i_xAutoPreRegistering_Hor THEN
                    eMainSts := APM_STEP_AUTOING_HOR;
                ELSE
                    fbTimeOutTon(IN:=TRUE, PT:=T#1S);
                    IF fbTimeOutTon.Q THEN
                        eMainSts := APM_STEP_TIMEOUT;
                    END_IF
                END_IF
            ELSE
                eMainSts := APM_STEP_ERR;
            END_IF
            
            (* 错误信息处理 *)
            IF eMainSts = APM_STEP_ERR THEN
                iMsgInf := AMRC_MSG_ERR_BUSY_HOR;
            END_IF
            IF eMainSts = APM_STEP_TIMEOUT THEN
                iMsgInf := AMRC_MSG_TIMEOUT_HOR;
            END_IF
            
            (* 退出case复位计时器 *)
            IF eMainSts <> APM_STEP_AUTO_HOR THEN
                o_xAutoPreRegister_Hor := FALSE;
                fbTimeOutTon(IN:=FALSE);
            END_IF
            
        APM_STEP_AUTOING_HOR:
            IF NOT i_xAutoPreRegistering_Hor THEN
                IF i_xUseAutoSensorPos THEN
                    eMainSts := APM_STEP_AUTOSENSORPOS;
                ELSE
                    eMainSts := APM_STEP_AUTO_VER;
                END_IF
            END_IF
            
        (* 自动sensor位置控制 *)
        APM_STEP_AUTOSENSORPOS:
            IF i_xUseSensorPos_3rd THEN
                eMainSts := APM_STEP_SENSORPOSBYSYS3RD;
            ELSE
                eMainSts := APM_STEP_SENSORPOSBYMANU;
            END_IF
            
        (* 第三方设备获取传感器位置 *)
        APM_STEP_SENSORPOSBYSYS3RD:
            IF iLastAxisId <> 0 THEN
                IF NOT axRollerPressSts_In[iLastAxisId] THEN
					o_axAxisStartPress[iLastAxisId] := TRUE;
                    //o_xExcuteRollerPress_LastAxis := TRUE;
                END_IF
                eMainSts := APM_STEP_WAITPOSBY3RD;
            ELSE
                eMainSts := APM_STEP_ERR;
            END_IF
            
            IF eMainSts = APM_STEP_ERR THEN
                iMsgInf := AMRC_MSG_ERR_LASTAXISID_INVALID;
            END_IF
            
        APM_STEP_WAITPOSBY3RD:
            IF NOT i_xSensorPosValid_3rd THEN
                eMainSts := APM_STEP_SENSOR_TO_TARGETPOS;
                o_rSenserTarPos_All := i_rSenserPos_3rd;
            ELSE
                IF i_rVel <> 0 THEN
                    rTmp := rWaitFilmLenth / i_rVel * 60;
                ELSE
                    rTmp := rWaitFilmLenth / 30.0 * 60;
                END_IF
                rTmp := rTmp * 1000;  (* 转换为毫秒 *)
                
                fbTimeOutTon(IN:=TRUE, PT:=REAL_TO_TIME(rTmp));
                IF fbTimeOutTon.Q THEN
                    eMainSts := APM_STEP_TIMEOUT;
                END_IF
            END_IF
            
            (* 输出信息 *)
            IF eMainSts = APM_STEP_TIMEOUT THEN
                iMsgInf := AMRC_MSG_TIMEOUT_WAITPOS_3RD;
            END_IF
            
            IF eMainSts <> APM_STEP_WAITPOSBY3RD THEN
                fbTimeOutTon(IN:=FALSE);
            END_IF
            
        (* 手动确认传感器位置 *)
        APM_STEP_SENSORPOSBYMANU:
            IF iLastAxisId <> 0 THEN
                IF NOT axRollerPressSts_In[iLastAxisId] THEN
					o_axAxisStartPress[iLastAxisId] := TRUE;
                    //o_xExcuteRollerPress_LastAxis := TRUE;
                END_IF
                eMainSts := APM_STEP_WAITPOSBYMANU;
            ELSE
                eMainSts := APM_STEP_ERR;
            END_IF
            
            IF eMainSts = APM_STEP_ERR THEN
                iMsgInf := AMRC_MSG_ERR_LASTAXISID_INVALID;
            END_IF
            
        APM_STEP_WAITPOSBYMANU:
            o_xManuConfirmSensorPos_LastAxis := TRUE;
            
            IF  i_xSensorPosValid_Manu THEN
                eMainSts := APM_STEP_SENSOR_TO_TARGETPOS;
                o_rSenserTarPos_All := i_rSensorPos_Manu;
            ELSE
                IF i_rVel <> 0 THEN
                    rTmp := rWaitFilmLenth / i_rVel * 60;
                ELSE
                    rTmp := rWaitFilmLenth / 30.0 * 60;;
                END_IF
                rTmp := rTmp * 1000;  (* 转换为毫秒 *)
                
                fbTimeOutTon(IN:=TRUE, PT:=REAL_TO_TIME(rTmp));
                IF fbTimeOutTon.Q THEN
                    eMainSts := APM_STEP_TIMEOUT;
                END_IF
            END_IF
            
            (* 输出信息 *)
            IF eMainSts = APM_STEP_TIMEOUT THEN
                iMsgInf := AMRC_MSG_TIMEOUT_WAITPOS_MANU;
            END_IF
            
            IF eMainSts <> APM_STEP_WAITPOSBYMANU THEN
                fbTimeOutTon(IN:=FALSE);
                o_xManuConfirmSensorPos_LastAxis := FALSE;
            END_IF
            
        (* 传感器电机向目标位置运动 *)
        APM_STEP_SENSOR_TO_TARGETPOS:
            xTmp := KS_CheckSensorMotorIdleSts(0, i_byAxisNum, i_aiAxisList, axSensorMotorIdle);
            IF xTmp THEN
                o_xSensorGoTargetPos_All := TRUE;
            END_IF
            
            IF o_xSensorGoTargetPos_All THEN
				eMainSts := APM_STEP_SENSOR_TO_TARGETPOSING;
				o_xSensorGoTargetPos_All := FALSE;
            END_IF
            
        APM_STEP_SENSOR_TO_TARGETPOSING:
            xTmp := KS_CheckSensorMotorIdleSts(iLastAxisId, i_byAxisNum, i_aiAxisList, axSensorMotorIdle);
            
            IF i_xUseFindBestPosStep THEN
                xCheckSensorToTargetPos := TRUE;
                eMainSts := APM_STEP_AUTO_VER;
            ELSE
                IF xTmp THEN
                    eMainSts := APM_STEP_AUTO_VER;
                END_IF
            END_IF
            
        (* 纵向全自动套印 - 流水线处理 *)
        APM_STEP_AUTO_VER:
            (* 启动寻找模块 *)
            o_xExcuteAutoPreRegister_Ver := TRUE;
            o_xCurrentAxisProcessing := TRUE;
            axAxisNeedPress[iLastAxisId]:=TRUE;
            eMainSts := APM_STEP_AUTOING_VER;
            
        APM_STEP_AUTOING_VER:
            (* 简化流水线处理逻辑 - 只负责触发前轴合压和激活寻找模块 *)
            o_xCurrentAxisProcessing := TRUE;
            o_iCurrentAxisIndex := 0;
            
            (* 首先，更新所有轴的状态描述 *)
            xAllAxisComplete := TRUE;  (* 假设所有轴都完成 *)
            
            FOR iN := i_byAxisNum TO 1 BY -1 DO
                iAxisId := i_aiAxisList[iN];
                iBeforeAxisId := aiBeforeAxisId[iAxisId];
                
                (* 跳过已完成的轴 *)
                IF axAxisComplete[iAxisId] THEN
                    CONTINUE;
                END_IF
                
                (* 标记有轴未完成 *)
                xAllAxisComplete := FALSE;
                
                (* 记录当前正在处理的轴索引 *)
                IF NOT axAxisComplete[iAxisId] THEN
                    o_iCurrentAxisIndex := iN;
                END_IF
                
                (* 第一轴特殊处理：只需要合压 *)
                IF iN = 1 THEN
                    (* 第一轴尚未合压完成 *)
                    IF NOT axAxisPressDone[iAxisId] THEN
                        (* 检查是否需要合压 *)
                        IF axAxisNeedPress[iAxisId] AND NOT axAxisPressDone[iAxisId] THEN
                            (* 触发合压 *)
                            IF NOT axAxisStartPressTriggered[iAxisId] THEN
                                o_axAxisStartPress[iAxisId] := TRUE;
                                axAxisStartPressTriggered[iAxisId] := TRUE;
                              //  asAxisStatus[iAxisId] := '合压中';
                            END_IF
                            
                            (* 检查合压是否完成 *)
                            IF axRollerPressSts_In[iAxisId] THEN
                                (* 合压完成 *)
                                o_axAxisStartPress[iAxisId] := FALSE;
                                axAxisPressDone[iAxisId] := TRUE;
                                axAxisComplete[iAxisId] := TRUE;
                             //   asAxisStatus[iAxisId] := '完成';
                                xFirstAxisPressComplete := TRUE;
                            END_IF
                        END_IF
                    END_IF
                    CONTINUE;
                END_IF
                
                (* 非第一轴的处理逻辑 *)
                
                (* 1. 检查是否需要合压 *)
                IF axAxisNeedPress[iAxisId] AND NOT axAxisPressDone[iAxisId] THEN
                    (* 需要合压但未合压 *)
                    IF NOT axAxisStartPressTriggered[iAxisId] THEN
                        (* 触发合压 *)
                        IF iN = i_byAxisNum THEN
                            (* 最后一个轴 *)
							o_axAxisStartPress[iLastAxisId] := TRUE;
                        ELSE
                            (* 其他轴 *)
                            o_axAxisStartPress[iAxisId] := TRUE;
                        END_IF
                        axAxisStartPressTriggered[iAxisId] := TRUE;
                     //   asAxisStatus[iAxisId] := '等待合压';
                    END_IF
                    
                    (* 检查合压是否完成 *)
                    IF axRollerPressSts_In[iAxisId] THEN
                        (* 合压完成 *)
//                         IF iN = i_byAxisNum THEN
// 							o_axAxisStartPress[iLastAxisId] := TRUE;
//                         END_IF
                        o_axAxisStartPress[iAxisId] := FALSE;
                        axAxisPressDone[iAxisId] := TRUE;
                        
                        (* 激活寻找模块并发送单色寻找命令 *)
                        o_axAxisFindModuleEn[iAxisId] := TRUE;
                        IF NOT axAxisCmdSingle[iAxisId] THEN
                            o_axAxisCmd[iAxisId] := FIND_CMD_START_SINGLE;
                            axAxisCmdSingle[iAxisId] := TRUE;
                        END_IF
                        
                      //  asAxisStatus[iAxisId] := '寻找单色中';
                    END_IF
                END_IF
                
                (* 2. 检查轴寻找模块的状态 *)
                IF axAxisPressDone[iAxisId] AND NOT axAxisComplete[iAxisId] THEN
                    (* 轴已合压完成，正在寻找中 *)
                   
                    (* 激活寻找模块 *)
                    o_axAxisFindModuleEn[iAxisId] := TRUE;
                    
                    (* 3. 检查是否需要触发前轴合压 *)
                    IF iBeforeAxisId <> -1 THEN
                        (* 检查轴寻找模块是否发出前轴合压信号 *)
                        IF i_pafbKS_FB_AxisFindModule^[iAxisId].o_xBeforeAxisStartPress AND
                           NOT axBeforeAxisPressRequested[iAxisId] THEN
                            (* 触发前轴合压 *)
                            axAxisNeedPress[iBeforeAxisId] := TRUE;
                            axBeforeAxisPressRequested[iAxisId] := TRUE;
                        END_IF
                    END_IF
                    
                    (* 4. 检查轴是否完成 *)
                    IF i_pafbKS_FB_AxisFindModule^[iAxisId].o_xDone THEN
                        (* 轴寻找完成 *)
                        o_axAxisFindModuleEn[iAxisId] := FALSE;
                        axAxisComplete[iAxisId] := TRUE;
                        
                        (* 保存寻找结果 *)
                        i_pastFindResults^[iAxisId] := i_pafbKS_FB_AxisFindModule^[iAxisId].o_stResult;
                        aiCurBestSignalPos[iAxisId] := i_pastFindResults^[iAxisId].iCurBestPos;
                        
                        (* 记录前色位置（如果找到混色）*)
                        IF i_pastFindResults^[iAxisId].iPreLabelPos >= 0 THEN
                            aiPreLabelPos[iAxisId] := i_pastFindResults^[iAxisId].iPreLabelPos;
                        END_IF
                        
                        (* 复位命令 *)
                        IF axAxisCmdSingle[iAxisId] THEN
                            o_axAxisCmd[iAxisId] := FIND_CMD_IDLE;
                            axAxisCmdSingle[iAxisId] := FALSE;
                        END_IF
                        
                        IF axAxisCmdMix[iAxisId] THEN
                            o_axAxisCmd[iAxisId] := FIND_CMD_IDLE;
                            axAxisCmdMix[iAxisId] := FALSE;
                        END_IF
                    END_IF
                END_IF
            END_FOR
            
            (* 检查是否所有轴都完成 *)
            IF xAllAxisComplete THEN
                eMainSts := APM_STEP_CALC_ADJUSTMENTS;
                (* 复位全自动套印标志 *)
                o_xExcuteAutoPreRegister_Ver := FALSE;
                o_xAutoPreRegisterFinish_Ver := TRUE;
            END_IF
            
        APM_STEP_CALC_ADJUSTMENTS:
            (* 计算调整量 *)
           // o_xBusy := TRUE;
            
            (* 计算每个轴的调整量（从第二个轴开始）*)
            FOR iN := 2 TO i_byAxisNum BY 1 DO
                iAxisId := i_aiAxisList[iN];
                
                (* 获取参数指针 *)
                pstStUnitParam_Save := ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
                pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save);
                
                (* 计算纵向调整量 *)
                IF aiCurBestSignalPos[iAxisId] >= 0 AND aiPreLabelPos[iAxisId] >= 0 THEN
                    o_arAdjValue_Point[iAxisId] := KS_CalculateVerticalAdjustment(
                        iAxisId,
                        aiCurBestSignalPos[iAxisId],
                        aiPreLabelPos[iAxisId],
                        pstStUnitParam_Save,
                        pstStGrpParam_Save
                    );
                ELSE
                    o_arAdjValue_Point[iAxisId] := 0.0;
                END_IF
            END_FOR
            xCalculationCompleted:=FALSE;
			(*动作执行*)

			FOR iN:=2 TO i_byAxisNum BY 1 DO
				iAxisId:=i_aiAxisList[iN];
				pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[iAxisId]);			
				o_arAdjPos_um[iAxisId]:=0;
				FOR iM:=2 TO iN BY 1 DO
					iAxisId_Calc:= i_aiAxisList[iM];
					(*当前色获取到的粗采样点数*)
					rTmp:=o_arAdjValue_Point[iAxisId_Calc];(*记录位置*)
					(*累加@此时单位还是粗采样点数*)
					o_arAdjPos_um[iAxisId]:=o_arAdjPos_um[iAxisId] + rTmp;
				END_FOR
				(*测试*)
				//o_arAdjPos_um[iAxisId]:=15000*iAxisId;
				(*2026.3.26.213041+ by liu.yt*)
				(*将调整的粗采样点数转换到+-MAX_ROUNDSAMPLE_NUM/2范围内*)
				WHILE o_arAdjPos_um[iAxisId] < -MAX_ROUNDSAMPLE_NUM / 2 DO
					o_arAdjPos_um[iAxisId] := o_arAdjPos_um[iAxisId] + MAX_ROUNDSAMPLE_NUM;
				END_WHILE
				WHILE o_arAdjPos_um[iAxisId] > MAX_ROUNDSAMPLE_NUM / 2 DO
					o_arAdjPos_um[iAxisId] := o_arAdjPos_um[iAxisId] - MAX_ROUNDSAMPLE_NUM;
				END_WHILE(*此时单位还是粗采样点数*)
				(*计算um单位*)
				o_arAdjPos_um[iAxisId]:= o_arAdjPos_um[iAxisId]* pstStUnitParam_Save^.rGirth_PrnRoller*1000 / MAX_ROUNDSAMPLE_NUM;
			END_FOR
			xCalculationCompleted:=TRUE;		
            (* 进入快速调整步骤 *)
            eMainSts := APM_STEP_FAST_ADJUSTMENT;
            
        APM_STEP_FAST_ADJUSTMENT:
            (* 快速对版调整 *)
            //o_xBusy := TRUE;
			Action_Excute();
			IF xAllAdjust_finish THEN
				eMainSts := APM_STEP_COMPLETE;
				byMeanANDAutoChangeCnt:=0;
			END_IF
        APM_STEP_COMPLETE:
            (* 完成 *)
           // o_xBusy := FALSE;
		   IF xAllAdjust_finish THEN(*全部调整完成-自动合压*)
			   xNextStep:=TRUE;
				FOR iN:=2 TO i_byAxisNum BY 1 DO(*开始的时候全部打手动*)
					iAxisId:= i_aiAxisList[iN];
					pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[iAxisId]);
					(*结束后全部打自动*)
					IF NOT pstStUnitParam_Save^.dwFlag_Sts.0 THEN
						pstStUnitParam_Save^.dwFlag_Sts.0:= TRUE;
						xNextStep:=FALSE;			
					END_IF
				END_FOR
				IF xNextStep THEN
					o_xAllFindComplete := TRUE;
				END_IF
		  
// 				byMeanANDAutoChangeCnt := byMeanANDAutoChangeCnt+1;
// 				IF  byMeanANDAutoChangeCnt < 3 THEN
// 					o_byArcAdjAutoCtl:=1;
// 					o_xWaitingFilmLenthEn := TRUE;
// 				ELSE
// 					o_xWaitingFilmLenthEn := FALSE;	
// 				
// 					//xAllAdjust_finish:=FALSE;
// 				END_IF
			END_IF
           
        (* 超时步 *)
        APM_STEP_TIMEOUT:
            eMainSts := APM_STEP_ERR;
            iMsgInf := AMRC_MSG_TIMEOUT_HOR;
            
        (* 返回失败 *)
        APM_STEP_ERR:
            o_xExcuteAutoPreRegisterFailed_Ver := TRUE;
            o_xAllFindComplete := FALSE;
    END_CASE
    
    (* 调用所有轴的寻找模块 *)
    FOR iN := 1 TO i_byAxisNum BY 1 DO
        iAxisId := i_aiAxisList[iN];
        
        (* 获取参数指针 *)
        pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
        pstStUnitParam_Save := ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
        pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save);
        pstStRSV_GrpParam_Save := ADR(i_pstStSysParam^.astStRSV_GrpParam_Save);
        
        rGirth := pstStUnitParam_Save^.rGirth_PrnRoller;
        rFilmLength := pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit;
        
        (* 获取前后轴号 *)
        iBeforeAxisId := aiBeforeAxisId[iAxisId];
        iAfterAxisId := aiAfterAxisId[iAxisId];
        
        (* 调用轴寻找模块 *)
        i_pafbKS_FB_AxisFindModule^[iAxisId](
            (* 基本输入 *)
            i_xEn := o_axAxisFindModuleEn[iAxisId],
            i_iAxisId := iAxisId,
            i_eCmd := o_axAxisCmd[iAxisId],
            i_xUseFindBestPosStep := i_xUseFindBestPosStep,
            
            (* 参数输入 *)
            i_pstStRSV_UnitParam_UnSave := pstStRSV_UnitParam_UnSave,
            i_pstStUnitParam_Save := pstStUnitParam_Save,
            i_pstStGrpParam_Save := pstStGrpParam_Save,
            i_rVel := i_rVel,
            i_rGirth := rGirth,
            i_rFilmLength := rFilmLength,
            i_iBeforeAxisId := iBeforeAxisId,
            i_iAfterAxisId := iAfterAxisId,
            i_rFindBestPos_MoveDis := pstStRSV_GrpParam_Save^.arFiberMove,
            
            (* 外部状态输入 *)
            i_xCoarseDone := axSensorMotorIdle[iAxisId],
            i_xPressDone := axRollerPressSts_In[iAxisId],
            i_xAutoMode := (eMainSts = APM_STEP_AUTOING_VER),
            i_xFind_IDLE := pstStRSV_UnitParam_UnSave^.byFlag_CommFromSlave.4,
            
            (* 开关参数 *)
            i_xSwitch_EnFastPress := pstStRSV_GrpParam_Save^.xSwitch_EnFastPress,
            i_xSwitch_RFailure := FALSE,
            i_xSwitch_FFailure := FALSE,
            i_xSpecialMarkEn := FALSE
        );
		
    END_FOR
    
ELSE
    (* 复位处理 *)
    IF o_xEning THEN
        o_xEning := FALSE;
        eMainSts := APM_STEP_IDLE;
        o_xAlarm := FALSE;
        o_xAutoPreRegister_Hor := FALSE;
        o_xManuConfirmSensorPos_LastAxis := FALSE;
        o_xSensorGoTargetPos_All := FALSE;
        o_rSenserTarPos_All := 0;
        o_xExcuteAutoPreRegister_Ver := FALSE;
      //  o_xWaitingFilmLenthEn := FALSE;
        xCheckSensorToTargetPos := FALSE;
        o_byArcAdjAutoCtl := 0;  (* 套色手动 *)
		xCalculationCompleted:=FALSE;	
        (* 复位所有轴的寻找模块 *)
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			 o_axAxisStartPress[iAxisId]:=FALSE;
		END_FOR
        FOR iN := 1 TO i_byAxisNum BY 1 DO
            iAxisId := i_aiAxisList[iN];      
            (* 获取参数指针 *)
            pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
            pstStUnitParam_Save := ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
            pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save);
            pstStRSV_GrpParam_Save := ADR(i_pstStSysParam^.astStRSV_GrpParam_Save);
            
            rGirth := pstStUnitParam_Save^.rGirth_PrnRoller;
            rFilmLength := pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit;
            
            (* 获取前后轴号 *)
            iBeforeAxisId := aiBeforeAxisId[iAxisId];
            iAfterAxisId := aiAfterAxisId[iAxisId];
            
            (* 调用轴寻找模块复位 *)
            i_pafbKS_FB_AxisFindModule^[iAxisId](
                (* 基本输入 *)
                i_xEn := TRUE,
                i_iAxisId := iAxisId,
                i_eCmd := FIND_CMD_RESET,
                i_xUseFindBestPosStep := i_xUseFindBestPosStep,
                
                (* 参数输入 *)
                i_pstStRSV_UnitParam_UnSave := pstStRSV_UnitParam_UnSave,
                i_pstStUnitParam_Save := pstStUnitParam_Save,
                i_pstStGrpParam_Save := pstStGrpParam_Save,
                i_rVel := i_rVel,
                i_rGirth := rGirth,
                i_rFilmLength := rFilmLength,
                i_iBeforeAxisId := iBeforeAxisId,
                i_iAfterAxisId := iAfterAxisId,
				i_rFindBestPos_MoveDis := pstStRSV_GrpParam_Save^.arFiberMove,
                
                (* 外部状态输入 *)
                i_xCoarseDone := pstStRSV_UnitParam_UnSave^.wState_FiberMove.8,
                i_xPressDone := axRollerPressSts_In[iAxisId],
                i_xAutoMode := FALSE,
                i_xFind_IDLE := pstStRSV_UnitParam_UnSave^.byFlag_CommFromSlave.4,
                
                (* 开关参数 *)
                i_xSwitch_EnFastPress := pstStRSV_GrpParam_Save^.xSwitch_EnFastPress,
                i_xSwitch_RFailure := i_xSwitch_RFailure,
                i_xSwitch_FFailure := i_xSwitch_FFailure,
                i_xSpecialMarkEn := FALSE
            );
			i_pastFindResults^[iAxisId] := i_pafbKS_FB_AxisFindModule^[iAxisId].o_stResult;
        END_FOR	
    END_IF
END_IF


(* 输出状态 *)
o_eSts := eMainSts;
o_iMsgInf := iMsgInf;
//o_astFindResult := astFindResult;
g_axAutoFind_Press:=o_axAxisStartPress;
FOR iN := 1 TO i_byAxisNum BY 1 DO	 
	iAxisId := i_aiAxisList[iN];
	o_eState[iAxisId]:= i_pafbKS_FB_AxisFindModule^[iAxisId].o_eState;
	o_iErrorCode[iAxisId]:=i_pafbKS_FB_AxisFindModule^[iAxisId].o_stResult.iErrorCode;
END_FOR
      
//o_axAxisStatus := asAxisStatus;