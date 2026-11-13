(*@CES
Name=StProofItem
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=570fb4d9-10a9-4892-8e2d-1d8339482480
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StProofItem :(*证据链*)
STRUCT
	iWaitRespCycles: INT;(*等待响应的周期次数/超时就把这个后面的报文重置/把该计数清零*)
	stStADU: StADU;(*发送的16功能字报文*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
