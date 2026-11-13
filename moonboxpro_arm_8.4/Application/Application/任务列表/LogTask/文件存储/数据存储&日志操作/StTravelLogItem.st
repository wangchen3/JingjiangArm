(*@CES
Name=StTravelLogItem
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=d92a6104-9117-400f-b58f-f96bab8fae06
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StTravelLogItem :
STRUCT
	wLogLevelId				: WORD;(* 参考LOG_LEVEL_xxx *)
	sInfo					: STRING(256);	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
