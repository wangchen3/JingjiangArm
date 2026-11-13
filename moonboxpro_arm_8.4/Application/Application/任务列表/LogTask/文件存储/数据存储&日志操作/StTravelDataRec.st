(*@CES
Name=StTravelDataRec
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=4a1c87c8-507f-49a1-a6b5-dfc3139d89be
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StTravelDataRec :
STRUCT
	uiWR				: UINT;(* 写位置 *)
	uiRD				: UINT;(* 读位置 *)
	astStTravelDataItem	: ARRAY [1..MAX_ROWS_OF_RECORD] OF StTravelDataItem;(* 数据静荷区域 *)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
