(*@CES
Name=KS_FB_ManualFindMixColor
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=48811e36-789b-45c0-9237-87d497c0d2dc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_ManualFindMixColor
VAR_INPUT
    i_iAxisId: INT;                      (* 轴号 *)
    i_pstStSysParam: POINTER TO StSysParam; (* 系统参数 *)
    i_rVel: REAL;                        (* 速度 *)
    i_rGirth: REAL;                      (* 版周长 *)
    i_rFilmLength: REAL;                 (* 料长 *)
    i_iBeforeAxisId: INT;                (* 前轴号（用于计算延时） *)
	i_pfbKS_FB_AxisFindModule: POINTER TO KS_FB_AxisFindModule;
END_VAR
VAR_OUTPUT
	o_xManualMixComplete :BOOL;           (*寻找完成*)
END_VAR
VAR
    pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave;
    pstStUnitParam_Save: POINTER TO StUnitParam_Save;
    pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStRSV_GrpParam_Save	: POINTER TO StRSV_GrpParam_Save;//
    rGirth: REAL;
    rFilmLength: REAL;
END_VAR


{IMPLEMENTATION}
(* 获取参数指针 *)
pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[i_iAxisId]);
pstStUnitParam_Save := ADR(i_pstStSysParam^.astStUnitParam_Save[i_iAxisId]);
pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save);
pstStRSV_GrpParam_Save :=  ADR(i_pstStSysParam^.astStRSV_GrpParam_Save);
rGirth := pstStUnitParam_Save^.rGirth_PrnRoller;
rFilmLength := pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit;

(* 调用轴寻找模块 *)
i_pfbKS_FB_AxisFindModule^(
    (* 基本输入 *)
    i_xEn := TRUE,
    i_iAxisId := i_iAxisId,
    i_eCmd := FIND_CMD_START_MIX,
    i_xUseFindBestPosStep := FALSE,      (* 混色寻找不使用最佳位置步骤 *)
    
    (* 参数输入 *)
  	i_pstStRSV_UnitParam_UnSave := pstStRSV_UnitParam_UnSave,
	i_pstStUnitParam_Save := pstStUnitParam_Save,
	i_pstStGrpParam_Save := pstStGrpParam_Save,
    i_rVel := i_rVel,
    i_rGirth := rGirth,
    i_rFilmLength := rFilmLength,
    i_iBeforeAxisId := i_iBeforeAxisId,  (* 需要前轴号计算延时 *)
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

o_xManualMixComplete := i_pfbKS_FB_AxisFindModule^.o_xDone AND i_pfbKS_FB_AxisFindModule^.o_xSuccess;