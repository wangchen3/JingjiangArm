(*@CES
Name=StRSV_SysParam_UnSave
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=580fcb8a-9dea-42ea-95d1-60553efab088
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRSV_SysParam_UnSave :
STRUCT
	abyRSV_SysParam_UnSave: ARRAY [1..1000] OF BYTE;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
