(*@CES
Name=StTravelLogRec
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=1e9822ea-ea5b-4373-ab67-94f283ee71ec
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StTravelLogRec :
STRUCT
	uiIndex_Wr: UINT;(* 当前写入位置 *)
(*	uiIndex_Peek: UINT;(* 当前窥探位置 *)*)
	uiIndex_Rd: UINT;(* 当前读取位置 *)
	xOverwrite: BOOL;(* 过圈标志 *)
	astStTravelLogItem: ARRAY [1..GC_LOG_ITEM_MAX_NUM] OF StTravelLogItem;(* 日志队列 *)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
