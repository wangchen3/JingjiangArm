(*@CES
Name=StUdpHeartbeat
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=916805f0-886b-4db1-bea3-feba1340632c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StUdpHeartbeat :(*固定长度8B*)
STRUCT
	uiPkgTyp: UINT;(*16#"HB"*)
	uiProtocolVer: UINT;(*协议版本/版本号格式A.B/bit0~bit7版本数字B/bit8~bit14/版本数字A*)
	dwInvocation: DWORD;(*id/自+1*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
