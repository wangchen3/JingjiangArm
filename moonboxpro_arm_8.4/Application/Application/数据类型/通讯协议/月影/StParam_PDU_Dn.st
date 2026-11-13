(*@CES
Name=StParam_PDU_Dn
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=7cc610ea-6431-4c4c-b72a-07e9312a874d
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_PDU_Dn :
STRUCT
	byPkgId						: BYTE;(*数据包ID*)
	abyPayLoad					: ARRAY [1..57] OF BYTE;(*数据可变区域*)
	wCHK						: WORD;(*校验码*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
