(*@CES
Name=StUdpOnlySendFifo
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=692a383b-6b0b-48bf-be0a-88ed063b622b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StUdpOnlySendFifo :
STRUCT
	byW: BYTE;
	byR: BYTE;
	astStUdpOnlySend: ARRAY [0..255] OF StUdpOnlySend;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
