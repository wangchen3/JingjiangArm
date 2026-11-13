(*@CES
Name=StHYLogFifo
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=a852f23e-9e5b-4df0-8623-1d9d9541315b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StHYLogFifo :
STRUCT
	byIdxR: BYTE;
	byIdxW: BYTE;
	astStHYLogItem: ARRAY [0..255] OF StHYLogItem;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
