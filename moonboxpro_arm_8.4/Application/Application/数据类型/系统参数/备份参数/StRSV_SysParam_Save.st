(*@CES
Name=StRSV_SysParam_Save
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=92f95b5a-0b73-4709-b624-b6c26b818526
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRSV_SysParam_Save :
STRUCT
	abyRSV_SysParam_Save: ARRAY [1..1000] OF BYTE;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
