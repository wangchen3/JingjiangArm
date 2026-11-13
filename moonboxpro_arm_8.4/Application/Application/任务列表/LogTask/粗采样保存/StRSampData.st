(*@CES
Name=StRSampData
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=647225e6-5d7c-4765-8d74-e5faea58caf3
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StRSampData :
STRUCT
	abyRs_T1: ARRAY[1..4000] OF BYTE;(* T1粗采样 *)
	abyRs_T2: ARRAY[1..4000] OF BYTE;(* T2粗采样 *)
	byUnitNR: BYTE;(* 色组号 *)
	diVel: DINT;(* 速度*100.0 *)
	udiTskCycleNR: UDINT;(* 任务周期计数 *)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
