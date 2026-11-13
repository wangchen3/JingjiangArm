(*@CES
Name=StProofList
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=df0f82a0-67c4-4a3b-a0bd-b03f60b31cfe
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StProofList :(*证据链*)
STRUCT
	astStProofItem: ARRAY [1..MAX_MB_FIFO_ITEMS] OF StProofItem;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
