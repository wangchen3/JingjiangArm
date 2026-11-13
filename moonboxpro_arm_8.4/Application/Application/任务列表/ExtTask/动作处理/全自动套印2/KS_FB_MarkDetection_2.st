(*@CES
Name=KS_FB_MarkDetection_2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5fe44bdc-55fc-4319-bd3e-90fc49ae9e34
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_MarkDetection_2
VAR_INPUT
	i_xEn									:BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu						: INT;(*色组轴数量|*)
	i_iGrpAxisTotalNum						: INT;(*系的总轴数量|*)
	i_paiGrpAxisList						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*排序好的轴id列表|*)
	i_pstStSysParam							: POINTER TO StSysParam;
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*基础io|*)
	i_pastStAxisRapidAdjProf_V				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_V; (* 纵向快速对版 *)
	i_pstStEvtReq							: POINTER TO StEvtReq;(*按钮输入操作及边沿触发描述|*)
	i_xIsDebugMode							:BOOL;(*调试模式*)
	i_pastFindResults :POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StFindResult;
END_VAR
VAR_IN_OUT

END_VAR
VAR_OUTPUT
	io_xStartAutoFind:BOOL;(*2023.6.19.110957 修改为了接口*)
	o_aiAxisList_AutoAdj					:ARRAY [1..MAX_UNIT_NUM] OF INT;(*全自动套印轴列表*)
	o_byAxisNum_AutoAdj						:BYTE;(*自动调整的轴个数*)
	o_arAdjPos_um							:ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*色组调整了*)
	o_axAxisStartPress                      :ARRAY [1..MAX_UNIT_NUM] OF BOOL;
END_VAR
VAR
	(*系参数访问入口|*)
	pstStGrpParam_Save :  POINTER TO  StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	pstStRSV_GrpParam_UnSave : POINTER TO StRSV_GrpParam_UnSave;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave;
	pstStRSV_UnitParam_Save: POINTER TO StRSV_UnitParam_Save;
	pstStRSV_GrpParam_Save	: POINTER TO StRSV_GrpParam_Save;
	
	fbAutoPrintMaster: KS_FB_AutoPrintMaster;
	fbKS_FB_ManualFindSingleColor:KS_FB_ManualFindSingleColor;
	//fbKS_FB_ManualFindMixColor:KS_FB_ManualFindMixColor;
	afbKS_FB_AxisFindModule: ARRAY[1..MAX_UNIT_NUM] OF KS_FB_AxisFindModule;
	
	
	(* 控制变量 *)
    xAutoPrintEn: BOOL;                  (* 全自动套印使能 *)
    xManualSingleEn :BOOL;				(* 手动单色寻找使能 *)
  //  xManualMixEn: BOOL;                  (* 手动混色寻找使能 *)
  //  iManualAxisId: INT:=3;               (* 手动寻找轴号 *)
    xTipsConfirm: BOOL;                  (* 提示确认 *)
	byAllAxisDisabled:BOOL;					(*关闭手动使能*)
	
	(*模版参数*)
    aiModeMidPoint: ARRAY [1..MAX_UNIT_NUM,1..4] OF INT;
	abyModeRadius:ARRAY [1..MAX_UNIT_NUM,1..4] OF BYTE;
	arModeStartmm: ARRAY [1..MAX_UNIT_NUM,1..4] OF REAL;
	arModeEndmm:ARRAY [1..MAX_UNIT_NUM,1..4] OF REAL;
	
    (* 状态显示 *)
    eMainStatus: EnumAutoPrintMasterStep;
    astFindResults: ARRAY[1..MAX_UNIT_NUM] OF StFindResult;
    xAllComplete: BOOL;
    arAdjValues: ARRAY[1..MAX_UNIT_NUM] OF REAL;
	byArcAdjAutoCtl : BYTE;
 
    (* 手动寻找结果 *)
   // xManualSingleComplete: BOOL;
   // xManualMixComplete: BOOL;
    
    (* 临时变量 *)
    iN: INT;
	iM: INT;
	iAxisId :INT;
	iAxisId_Calc :INT;
	rTmp :REAL;
	fbR_TrigInit: R_Trig;
	rMachineryFilmLenth:REAL;(*机组料长*)
    
    (* 控制开关 *)
	xUseAutoSensorPos:bool;				(*使用自动传感器位置控制粗调*)
	xUseAutoPreRegister_Hor :BOOL;        (*使用横向预套功能*)
    xUseFindBestPosStep: BOOL;           (* 使用寻找最佳位置步骤 *)
    
    (* 手动控制结果存储 *)
	axManualSingleAxisEn: ARRAY[1..MAX_UNIT_NUM] OF BOOL;     (* 手动单色寻找使能 *)
	//eManualCmd: ARRAY[1..MAX_UNIT_NUM] OF EnumFindCommand;(** 命令 **)
    axManualFindComplete: ARRAY[1..MAX_UNIT_NUM] OF BOOL; (* 手动寻找完成标志 *)
    aiManualFindError: ARRAY[1..MAX_UNIT_NUM] OF INT;     (* 手动寻找错误代码 *)
    
    (* 轴间关系  *)
   	aiAxisId_Before: ARRAY [1..MAX_UNIT_NUM] OF INT;(*每个色组的前一色色组号，第一个轴为-1*)
	aiAxisId_After: ARRAY [1..MAX_UNIT_NUM] OF INT;(*每个色组的后一色色组号，最后一个轴为-1*)
    
    (* 界面控制 *)
    xBtnStartAutoPrint: BOOL;            (* 启动全自动套印按钮 *)
    xBtnStopAutoPrint: BOOL;             (* 停止全自动套印按钮 *)
    xBtnResetAll: BOOL;                  (* 复位所有轴按钮 *)
    
    (* 全自动套印进度 *)
    iCurrentAxisIndex: INT;              (* 当前处理的轴索引 *)
    xCurrentAxisProcessing: BOOL;        (* 当前轴正在处理 *)
    
    (* 错误处理 *)

	(*执行调整*)
//	i_abyRapidAdjustStep					:ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	
	(*手动寻找标志*)
	afbSlaveFindCur:ARRAY [1..MAX_UNIT_NUM] OF R_Trig;
	afbSlaveFindPre:ARRAY [1..MAX_UNIT_NUM] OF R_Trig;
	//
	iManualWaitTime:INT;
	
//	xFlagFindPreing:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	arFiberMovePosCur:ARRAY [1..MAX_UNIT_NUM] OF REAL; (*光纤当前位置*)
	abyRapidAdjustStep:ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*快速调整状态*)
	
	
	wSwitchAutoFindSignal:WORD;(*全自动套印相关开关
								bit 0 不需要确认标志，目前确认在金刚上处理 true
								bit 1 横向预套功能，暂时不需要 false
								bit 2 是否需要自动传感器确认位置确认粗调位置，True有光电眼横向电机写True，没有写False，不需要基准确认直接全自动套印
								bit 3 是否使用寻找最佳位置，在存在光电眼电机的情况下，使用左3右6寻找最佳位置 true 否则，只找一次*)
END_VAR
	

{IMPLEMENTATION}
IF 	i_paiGrpAxisList<>0 AND
	i_pstStSysParam<>0 AND
	i_pastStIOMap_Axis_FE<>0 AND
	i_pastStAxisRapidAdjProf_V<>0 AND
	i_pstStEvtReq<>0	THEN
	
	pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
	pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
	pstStRSV_GrpParam_Save:=ADR(i_pstStsysParam^.astStRSV_GrpParam_Save[i_iGrpId]);
	pstStRSV_GrpParam_UnSave :=ADR(i_pstStsysParam^.astStRSV_GrpParam_UnSave[i_iGrpId]);
	

	(* 初始化手动控制标志 *)
	FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
		pstStUnitParam_UnSave:=ADR(i_pstStsysParam^.astStUnitParam_UnSave[iN]);
		axManualFindComplete[iN] := FALSE;
		aiManualFindError[iN] := 0;
		(*读取快速对版的一些步骤*)
		abyRapidAdjustStep[iN]:=pstStUnitParam_UnSave^.byRapidAdjustStep;
		(*光纤位置读取，显示用*)
		arFiberMovePosCur[iN]:=g_astStFiberMoveStepDriver[iN].rFiberMovePosCur;
	END_FOR
	(*自动模式触发后初始化一次*)
	fbR_TrigInit(clk:=pstStRSV_GrpParam_UnSave^.xStartAutoFind);
	IF fbR_TrigInit.Q THEN
		Action_GenerateAxislabels();(*轴列表与轴关系*)	
		Action_DispatchInfProcess();(*处理下发arm信息需要通讯的信息*)
	END_IF
	wSwitchAutoFindSignal.0:=TRUE; (*bit 0 不需要确认标志，目前确认在金刚上处理 true*)
	wSwitchAutoFindSignal.1:=FALSE; (*bit 1 横向预套功能，暂时不需要 false*)
	wSwitchAutoFindSignal.2:=TRUE;(*bit 2 是否需要自动传感器确认位置确认粗调位置，True有光电眼横向电机写True，没有写False，不需要基准确认直接全自动套印*)
	wSwitchAutoFindSignal.3:=TRUE;(*bit 3 是否使用寻找最佳位置，在存在光电眼电机的情况下，使用左3右6寻找最佳位置 true 否则，只找一次*)
	
	xTipsConfirm:=wSwitchAutoFindSignal.0;
	xUseAutoPreRegister_Hor:=wSwitchAutoFindSignal.1;
	xUseAutoSensorPos:= wSwitchAutoFindSignal.2;
	xUseFindBestPosStep:=wSwitchAutoFindSignal.3;
	xAutoPrintEn:=pstStRSV_GrpParam_UnSave^.xStartAutoFind AND ((pstStGrpParam_UnSave^.xFlag_Print AND pstStGrpParam_UnSave^.xFlag_FilmAccDecDone) OR pstStGrpParam_UnSave^.xIsDebugMode_Machine);
	(* 全自动套印模式 *)
	(*按钮按下，印刷且加减速完成，或者调试模式可以全自动套印*)
	fbAutoPrintMaster(
		i_xEn := xAutoPrintEn,
		i_rVel :=  pstStGrpParam_UnSave^.rVel_Film,     (* 速度30m/min *)
		i_rMachineryFilmLenth := rMachineryFilmLenth,   (* 机器总料长 *)
		//i_rFilmLenth := i_pstStsysParam^.astStUnitParam_Save[1].rFilmLengthFromPrevPressUnit,   // 机组料长1u的机组料长
		i_xTipsConfirm := xTipsConfirm,
		i_xUseAutoPreRegister_Hor := xUseAutoPreRegister_Hor, (*先关闭横向预套功能2026.05.07.102047*)
		i_xAutoPreRegisterIdle_Hor := TRUE,
		i_xAutoPreRegistering_Hor := FALSE,
		i_xUseAutoSensorPos := xUseAutoSensorPos,
		i_xUseSensorPos_3rd := pstStRSV_GrpParam_Save^.xUseOnline_FiberMove,
		i_xSensorPosValid_3rd := g_astStFiberMoveStepDriver[o_aiAxisList_AutoAdj[o_byAxisNum_AutoAdj]].xFiberMoveIsSyncing,
		i_rSenserPos_3rd := g_astStFiberMoveStepDriver[o_aiAxisList_AutoAdj[o_byAxisNum_AutoAdj]].rFiberMove_BasePos,
		i_xSensorPosValid_Manu :=NOT g_astStFiberMoveStepDriver[o_aiAxisList_AutoAdj[o_byAxisNum_AutoAdj]].xFiberMoveIsSyncing,
		i_rSensorPos_Manu := g_astStFiberMoveStepDriver[o_aiAxisList_AutoAdj[o_byAxisNum_AutoAdj]].rFiberMove_BasePos,      (* 手动设置目标位置100mm *)
		i_xUseFindBestPosStep := xUseFindBestPosStep, (* 使用寻找最佳位置步骤  使用的话执行左三右6的逻辑，否则直接找本色然后找混色*)
		i_xSwitch_RFailure:= pstStRSV_GrpParam_UnSave^.xSwitch_RFailure ,           (** R失效开关 **)
    	i_xSwitch_FFailure:= pstStRSV_GrpParam_UnSave^.xSwitch_FFailure,            (** F失效开关 **)
		
		i_byAxisNum := o_byAxisNum_AutoAdj,
		i_aiAxisList := o_aiAxisList_AutoAdj, 
		i_pafbKS_FB_AxisFindModule:=ADR(afbKS_FB_AxisFindModule),
		i_pstStSysParam := i_pstStSysParam,
		i_pastStIOMap_AxisBasic := i_pastStIOMap_Axis_FE,
		i_pastStAxisRapidAdjProf_V:= i_pastStAxisRapidAdjProf_V, (** 快速对版参数数组 *)
		i_abyRapidAdjustStep:=abyRapidAdjustStep,
		i_pastFindResults:=ADR(astFindResults)
	);
	
	
	(* 获取状态 *)
	g_xAutoPrintMasterAlarm[i_iGrpId]:=fbAutoPrintMaster.o_xAlarm;
	eMainStatus := fbAutoPrintMaster.o_eSts;
//	astFindResults := fbAutoPrintMaster.o_astFindResult;
	xAllComplete := fbAutoPrintMaster.o_xAllFindComplete;
	iCurrentAxisIndex := fbAutoPrintMaster.o_iCurrentAxisIndex;
	xCurrentAxisProcessing := fbAutoPrintMaster.o_xCurrentAxisProcessing;
	o_axAxisStartPress:=fbAutoPrintMaster.o_axAxisStartPress;
	byArcAdjAutoCtl:=fbAutoPrintMaster.o_byArcAdjAutoCtl;

	IF  xAllComplete OR pstStGrpParam_UnSave^.xFlag_Stop OR pstStGrpParam_UnSave^.xFlag_Estop OR NOT xAutoPrintEn THEN
		pstStRSV_GrpParam_UnSave^.xStartAutoFind :=FALSE;
	END_IF

	
//     (* 处理错误信息 *)
//     IF eMainStatus = APM_STEP_ERR THEN
//         CASE fbAutoPrintMaster.o_iMsgInf OF
//             AMRC_MSG_ERR_BUSY_HOR:
//                 sErrorMessage := '横向正忙';
//             AMRC_MSG_ERR_LASTAXISID_INVALID:
//                 sErrorMessage := '最后一个轴id非法';
//             AMRC_MSG_ERR_AUTOPREGISTER_VER:
//                 sErrorMessage := '自动纵向套印失败';
//             AMRC_MSG_TIMEOUT_HOR:
//                 sErrorMessage := '横向预套准启动超时';
//             AMRC_MSG_TIMEOUT_WAITPOS_3RD:
//                 sErrorMessage := '第三方设备位置等待超时';
//             AMRC_MSG_TIMEOUT_WAITPOS_MANU:
//                 sErrorMessage := '手动位置等待超时';
//         END_CASE
//     ELSE
//         sErrorMessage := '';
//     END_IF
	
	(*色组点击后触发一次初始化*)
	FOR iN:=2 TO i_iGrpAxisNum_Pu BY 1 DO
		iAxisId := i_paiGrpAxisList^[iN];
		pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
		pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[iAxisId]);
		afbSlaveFindCur[iAxisId](CLK:=pstStRSV_UnitParam_UnSave^.wState_FiberMove.6);
		(*点击了居中按钮*)
		IF afbSlaveFindCur[iAxisId].Q AND astFindResults[iAxisId].eState = FIND_STATE_IDLE AND NOT xAutoPrintEn AND pstStGrpParam_UnSave^.rVel_Cur >0 THEN
			xManualSingleEn:=TRUE;
			axManualSingleAxisEn[iAxisId]:=TRUE;
			axManualFindComplete[iAxisId] := FALSE;
		END_IF	
		IF pstStGrpParam_UnSave^.rVel_Cur = 0 AND pstStRSV_UnitParam_UnSave^.wState_FiberMove.6 THEN
			pstStRSV_UnitParam_UnSave^.wState_FiberMove.6 :=FALSE;
		END_IF	
	END_FOR	
	
	(* 手动控制模式 波门内色标居中*)
	fbKS_FB_ManualFindSingleColor(
		i_xEn := xManualSingleEn,                      (* 主使能 *)
		i_rVel :=  pstStGrpParam_UnSave^.rVel_Cur,                      (* 料膜速度@m/min *)
		i_paxManualSingleAxisEn := ADR(axManualSingleAxisEn),    (* 手动单色寻找使能 *)
		i_xUseFindBestPosStep := TRUE,         (* 使用寻找最佳位置步骤 *)
		i_pstStSysParam := i_pstStSysParam, (* 系统参数 *)
		i_iGrpAxisNum_Pu :=	i_iGrpAxisNum_Pu,					(*色组轴数量|*)
		i_paiGrpAxisList :=	i_paiGrpAxisList,				(*排序好的轴id列表|*)
		i_pafbKS_FB_AxisFindModule:=ADR(afbKS_FB_AxisFindModule),
		i_pastFindResults:=ADR(astFindResults)
	);
	axManualFindComplete:=fbKS_FB_ManualFindSingleColor.o_xManualAxisSingleComplete;
	eMainStatus := fbAutoPrintMaster.o_eSts;
	(* 如果总使能是打开的 *)
	IF xManualSingleEn THEN
		(* 假设所有轴都没有使能，直到找到有使能的轴 *)
		byAllAxisDisabled := TRUE;
		
		FOR iN := 2 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId := i_paiGrpAxisList^[iN];
			
			(* 如果这根轴有使能 *)
			IF axManualSingleAxisEn[iAxisId] AND astFindResults[iAxisId].eState <> FIND_STATE_IDLE THEN
				(* 只要有一根轴有使能，就标记“不是所有轴都禁用” *)
				byAllAxisDisabled := FALSE;
				(* 可以提前退出循环，因为已经知道至少有一根轴有使能 *)
				EXIT;
			END_IF
		END_FOR
		
		(* 循环结束后判断 *)
		IF byAllAxisDisabled THEN
			(* 所有轴都没有使能，关闭总使能 *)
			xManualSingleEn := FALSE;
		ELSE
			(* 至少有一根轴有使能，保持总使能（无需操作） *)
			(* 这里可以什么都不做，或者根据需要添加日志 *)
		END_IF
	END_IF
	
	FOR iN:=2 TO i_iGrpAxisNum_Pu BY 1 DO
		iAxisId := i_paiGrpAxisList^[iN];
		pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
		(*传出每个轴的使能标志标志*)
		pstStRSV_UnitParam_UnSave^.xManualSingleAxisEn:=axManualSingleAxisEn[iAxisId];
	END_FOR	
	
	(* 更新状态显示 *)
	eMainStatus := APM_STEP_IDLE;
	xAllComplete := FALSE;
END_IF	

// (* 错误处理 *)
// FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
//     IF astFindResults[iN].iErrorCode <> 0 THEN
//         (* 根据错误代码进行处理 *)
//         CASE astFindResults[iN].iErrorCode OF
//             FIND_ERR_COARSE_NOT_READY:
//                 (* 粗调未到位，需要检查粗调状态 *)
//                 ;
//             FIND_ERR_SINGLE_MARK_NOT_FOUND:
//                 (* 单色标记未找到，可能需要手动调整光电眼 *)
//                 ;
//             FIND_ERR_PRE_POS_INVALID:
//                 (* 前色位置无效，检查前色寻找 *)
//                 ;
//             FIND_ERR_TIMEOUT:
//                 (* 超时，检查通信或硬件状态 *)
//                 ;
//         END_CASE
//     END_IF
// END_FOR

