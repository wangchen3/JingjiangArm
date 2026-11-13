(*@CES
Name=KS_TskCycle_End
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=379e6dd0-0b0c-44de-a9dc-120ed630a8f7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TskCycle_End : INT
VAR_INPUT
	i_pstStTaskCycleDetection: POINTER TO StTaskCycleDetection;
END_VAR
VAR
	iResult: INT;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_pstStTaskCycleDetection<>0 THEN
	i_pstStTaskCycleDetection^.tmTskOut:= TIME(); (* 结束的时间 *)
	i_pstStTaskCycleDetection^.tmElapsed:= i_pstStTaskCycleDetection^.tmTskOut-i_pstStTaskCycleDetection^.tmTskIn; (* 算出本次耗时 *)
	IF i_pstStTaskCycleDetection^.tmElapsed>i_pstStTaskCycleDetection^.tmElapsedMax THEN (* 如果最高纪录有变化 *)
		i_pstStTaskCycleDetection^.tmElapsedMax:= i_pstStTaskCycleDetection^.tmElapsed;
	END_IF
	IF NOT i_pstStTaskCycleDetection^.xCalcIntervalEnabled THEN
		i_pstStTaskCycleDetection^.xCalcIntervalEnabled:= TRUE;
	ELSE
		i_pstStTaskCycleDetection^.tmInterval:= i_pstStTaskCycleDetection^.tmTskIn-i_pstStTaskCycleDetection^.tmTskIn_Prev; (* 周期间隔 *)
		IF i_pstStTaskCycleDetection^.tmInterval>i_pstStTaskCycleDetection^.tmIntervalMax THEN (* 如果周期间隔纪录有变化 *)
			i_pstStTaskCycleDetection^.tmIntervalMax:= i_pstStTaskCycleDetection^.tmInterval;
		END_IF
	END_IF

	i_pstStTaskCycleDetection^.tmTskIn_Prev:= i_pstStTaskCycleDetection^.tmTskIn; (* 上次进入的时间 *)

	IF i_pstStTaskCycleDetection^.xRstDetection THEN (* 重新计算周期的操作 *)
		i_pstStTaskCycleDetection^.xRstDetection:= FALSE;
		i_pstStTaskCycleDetection^.xCalcIntervalEnabled:= FALSE;
		i_pstStTaskCycleDetection^.tmElapsedMax:= T#0ms;
		i_pstStTaskCycleDetection^.tmIntervalMax:= T#0ms;
	END_IF
ELSE
	iResult:= -1;
END_IF

KS_TskCycle_End:= iResult;