(*@CES
Name=KS_TskCycle_Begin
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4df1a699-322b-4ad9-8d1d-9083be64c28d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TskCycle_Begin : INT
VAR_INPUT
	i_pstStTaskCycleDetection: POINTER TO StTaskCycleDetection;
END_VAR
VAR
	iResult: INT;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_pstStTaskCycleDetection<>0 THEN
	i_pstStTaskCycleDetection^.tmTskIn:= TIME(); (* 进入的时间 *)
	i_pstStTaskCycleDetection^.udiCycleCnt:= i_pstStTaskCycleDetection^.udiCycleCnt+1; (* 进入一次就累计1次 *)
ELSE
	iResult:= -1;
END_IF
KS_TskCycle_Begin:= iResult;