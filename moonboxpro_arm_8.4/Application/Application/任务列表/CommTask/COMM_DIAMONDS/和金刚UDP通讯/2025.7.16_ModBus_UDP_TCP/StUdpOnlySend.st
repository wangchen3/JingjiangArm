(*@CES
Name=StUdpOnlySend
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=55108e64-6d22-4e9d-b632-f43af839db38
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StUdpOnlySend :
STRUCT
	uiPkgTyp: UINT;(*'FI'0x4649文件数据/'RT'0x5254实时数据*)
	uiDlen: UINT;(*剩余数据长度/max=1020Bytes*)
	abyMem: ARRAY [1..MAX_KS_UDPPKG_BYTES-4] OF BYTE;(*剩余长度字节*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
