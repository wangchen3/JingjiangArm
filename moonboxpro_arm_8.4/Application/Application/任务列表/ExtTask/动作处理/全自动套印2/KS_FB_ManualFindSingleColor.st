(*@CES
Name=KS_FB_ManualFindSingleColor
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0bdb7d05-a86b-4043-9f3c-70353c93f32a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_ManualFindSingleColor
VAR_INPUT
	i_xEn: BOOL;                         (* 主使能 *)
	i_rVel: REAL;                        (* 料膜速度@m/min *)
	//i_aeCmd: ARRAY[1..MAX_UNIT_NUM] OF EnumFindCommand;(** 命令 **)
  	i_paxManualSingleAxisEn:POINTER TO  ARRAY[1..MAX_UNIT_NUM] OF BOOL;     (* 手动单色寻找使能 *)
    i_xUseFindBestPosStep: BOOL;         (* 使用寻找最佳位置步骤 *)
    i_pstStSysParam: POINTER TO StSysParam; (* 系统参数 *)
	i_iGrpAxisNum_Pu						: INT;(*色组轴数量|*)
	i_paiGrpAxisList						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*排序好的轴id列表|*)
	i_pafbKS_FB_AxisFindModule: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF KS_FB_AxisFindModule;
	i_pastFindResults :POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StFindResult;
END_VAR
VAR_OUTPUT
	o_xManualAxisSingleComplete :ARRAY[1..MAX_UNIT_NUM] OF BOOL;        (*寻找完成*)
	 (* 轴状态显示 *)
//	o_astFindResult: ARRAY[1..MAX_UNIT_NUM] OF StFindResult; (* 各轴寻找结果 *)
END_VAR
VAR
    pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave;
    pstStUnitParam_Save: POINTER TO StUnitParam_Save;
    pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStRSV_GrpParam_Save	: POINTER TO StRSV_GrpParam_Save;
	axinit:ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	afbTON_FlagFindCuring:ARRAY [1..MAX_UNIT_NUM] OF TON;
	iManualWaitTime:INT;
    rGirth: REAL;
    rFilmLength: REAL;
	iN :INT;
	iAxisId: INT;
	xNeedRset:BOOL;
END_VAR
{IMPLEMENTATION}
IF  NOT i_xEn THEN
	RETURN;
END_IF
IF i_paxManualSingleAxisEn = 0 OR
   i_pstStSysParam = 0 OR
   i_paiGrpAxisList = 0 OR
   i_pafbKS_FB_AxisFindModule = 0 THEN
   RETURN;
END_IF
FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
	iAxisId := i_paiGrpAxisList^[iN];
	IF i_paxManualSingleAxisEn^[iAxisId] THEN
		IF NOT axinit[iAxisId] THEN
			axinit[iAxisId]:=TRUE;
			afbTON_FlagFindCuring[iAxisId](IN:=FALSE);	
		END_IF
		o_xManualAxisSingleComplete[iAxisId]:=TRUE;
		pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
		pstStUnitParam_Save := ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
		
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save);
		pstStRSV_GrpParam_Save :=  ADR(i_pstStSysParam^.astStRSV_GrpParam_Save);
		rGirth := pstStUnitParam_Save^.rGirth_PrnRoller;
		rFilmLength := pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit;
		(*等待10圈时间，+10s如果时间到强制结束*)
		IF i_rVel <> 0 AND rGirth <> 0 THEN
			iManualWaitTime:= REAL_TO_INT(10 * 60.0 * rGirth / i_rVel)+10000;
		ELSE
			iManualWaitTime:= 30000;
		END_IF
		xNeedRset:=FALSE;
		(*2026.05.24.183923 等待10圈时间||wang.xy*)		
		afbTON_FlagFindCuring[iAxisId](IN:=i_paxManualSingleAxisEn^[iAxisId],PT:=INT_TO_TIME(iManualWaitTime));
		(*如果时间到了，且居中还是打开的说明超时了，复位*)
		IF afbTON_FlagFindCuring[iAxisId] .Q AND pstStRSV_UnitParam_UnSave^.wState_FiberMove.6  THEN
			xNeedRset:=TRUE;
		END_IF
		(*如果从站关闭了且该轴还有使能，那么复位一下*)
		IF NOT pstStRSV_UnitParam_UnSave^.wState_FiberMove.6 AND i_paxManualSingleAxisEn^[iAxisId] THEN
			xNeedRset:=TRUE;
		END_IF
	
		(* 调用轴寻找模块 *)
		i_pafbKS_FB_AxisFindModule^[iAxisId](
			(* 基本输入 *)
			i_xEn := TRUE,
			i_iAxisId := iAxisId,
			i_eCmd := FIND_CMD_START_SINGLE,
			i_xUseFindBestPosStep := i_xUseFindBestPosStep,
			
			(* 参数输入 *)
			i_pstStRSV_UnitParam_UnSave := pstStRSV_UnitParam_UnSave,
			i_pstStUnitParam_Save := pstStUnitParam_Save,
			i_pstStGrpParam_Save := pstStGrpParam_Save,
			i_rVel := i_rVel,
			i_rGirth :=  pstStUnitParam_Save^.rGirth_PrnRoller,
			i_rFilmLength := pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit,
			i_iBeforeAxisId := -1,               (* 手动模式不考虑前轴 *)
			i_iAfterAxisId := -1,                (* 手动模式不考虑后轴 *)
			i_rFindBestPos_MoveDis := pstStRSV_GrpParam_Save^.arFiberMove,
			
			(* 外部状态输入 *)
			i_xCoarseDone := TRUE,               (* 手动模式假设粗调已完成 *)
			i_xPressDone := TRUE,                (* 手动模式假设合压已完成 *)
			i_xAutoMode := FALSE,                (* 手动模式 *)
			i_xFind_IDLE := pstStRSV_UnitParam_UnSave^.byFlag_CommFromSlave.4,
			
			(* 开关参数 *)
			i_xSwitch_EnFastPress := FALSE,
			i_xSwitch_RFailure := FALSE,
			i_xSwitch_FFailure := FALSE,
			i_xSpecialMarkEn := FALSE
		);
		o_xManualAxisSingleComplete[iAxisId]:= i_pafbKS_FB_AxisFindModule^[iAxisId].o_xDone 
		AND i_pafbKS_FB_AxisFindModule^[iAxisId].o_xSuccess;

		IF o_xManualAxisSingleComplete[iAxisId] OR xNeedRset THEN
			i_paxManualSingleAxisEn^[iAxisId]:=FALSE;
			(*手动复位强制该轴完成*)
			IF xNeedRset THEN
				o_xManualAxisSingleComplete[iAxisId]:=TRUE;
			END_IF
			axinit[iAxisId]:=FALSE;
			(* 调用轴寻找模块 *)
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
				i_rGirth :=  pstStUnitParam_Save^.rGirth_PrnRoller,
				i_rFilmLength := pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit,
				i_iBeforeAxisId := -1,               (* 手动模式不考虑前轴 *)
				i_iAfterAxisId := -1,                (* 手动模式不考虑后轴 *)
				i_rFindBestPos_MoveDis := pstStRSV_GrpParam_Save^.arFiberMove,
				
				(* 外部状态输入 *)
				i_xCoarseDone := TRUE,               (* 手动模式假设粗调已完成 *)
				i_xPressDone := TRUE,                (* 手动模式假设合压已完成 *)
				i_xAutoMode := FALSE,                (* 手动模式 *)
				i_xFind_IDLE := pstStRSV_UnitParam_UnSave^.byFlag_CommFromSlave.4,
				
				(* 开关参数 *)
				i_xSwitch_EnFastPress := FALSE,
				i_xSwitch_RFailure := FALSE,
				i_xSwitch_FFailure := FALSE,
				i_xSpecialMarkEn := FALSE
			);
			pstStRSV_UnitParam_UnSave^.wState_FiberMove.6 :=FALSE; (*复位标志*)
			
			IF  NOT pstStUnitParam_Save^.dwFlag_Sts.0 THEN 
				pstStUnitParam_Save^.dwFlag_Sts.0:= TRUE;
			END_IF;
		END_IF
	END_IF
	i_pastFindResults^[iAxisId]:=i_pafbKS_FB_AxisFindModule^[iAxisId].o_stResult;
END_FOR 
