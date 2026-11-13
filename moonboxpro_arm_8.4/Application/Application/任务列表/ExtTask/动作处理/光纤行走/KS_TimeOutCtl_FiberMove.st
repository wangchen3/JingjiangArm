(*@CES
Name=KS_TimeOutCtl_FiberMove
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3073fc8a-5882-4d64-879a-83cf9fdc8105
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TimeOutCtl_FiberMove : int
VAR_INPUT
	i_pstStFiberMoveStepDriver				:POINTER TO StFiberMoveStepDriver;
END_VAR
VAR
END_VAR

{IMPLEMENTATION}
    // 强制复位状态和标志
    i_pstStFiberMoveStepDriver^.iFiberMoveState := FIBERMOVE_IDLE;
    i_pstStFiberMoveStepDriver^.xFiberMoveRunning := FALSE;
    i_pstStFiberMoveStepDriver^.xFiberMoveIsHoming := FALSE;
    i_pstStFiberMoveStepDriver^.xFiberMoveIsSyncing := FALSE;
    i_pstStFiberMoveStepDriver^.xFiberMoveSyncDone := FALSE;
    i_pstStFiberMoveStepDriver^.byFiberMoveMode := 0;
	i_pstStFiberMoveStepDriver^.rFiberMoveDistanceOut:=0;
    i_pstStFiberMoveStepDriver^.xFiberMove_GoHomeDoneByDebug:=FALSE;
    
    // 更新时间戳，避免连续触发
    i_pstStFiberMoveStepDriver^.tFiberMove_StateTime := TIME();