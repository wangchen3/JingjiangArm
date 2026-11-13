(*@CES
Name=StTaskCycleDetection
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=d17a89bb-f73c-4312-a6cf-f8b703e65793
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StTaskCycleDetection :
STRUCT
	xRstDetection			: BOOL;(* 复位测量 *)
	udiCycleCnt				: UDINT;(* 周期计数 *)
	xCalcIntervalEnabled	: BOOL;(* 计算间隔有效 *)
	tmTskIn					: TIME;(* 进入任务的时间戳 *)
	tmTskOut				: TIME;(* 离开任务的时间戳 *)
	tmTskIn_Prev			: TIME;(* 上次进入任务的时间戳 *)
	tmElapsed				: TIME;(* 任务消耗时间 *)
	tmElapsedMax			: TIME;(* 任务消耗时间最大 *)
	tmInterval				: TIME;(* 任务间隔 *)
	tmIntervalMax			: TIME;(* 任务间隔最大 *)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
