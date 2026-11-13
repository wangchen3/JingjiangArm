(*@CES
Name=StTravelDataItem
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=62504b07-d26b-473c-be85-27d686726a0a
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StTravelDataItem :
STRUCT
	uiValidBytesNum		: UINT;(* 描述abyPayload有效的字节数量 *)
	abyPayload			: ARRAY [1..BYTES_PER_ROW_RECORD] OF BYTE;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
