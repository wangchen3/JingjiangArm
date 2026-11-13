(*@CES
Name=StZone_W
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=aa2f6bf5-5ddf-4cba-b55b-f3a209fac971
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StZone_W :(*Modbus只写区域*)
(*节点地址+PARAM_ZONE_C2S*)
STRUCT
	stStMBAP: StMBAP;(*ModBus Application Protocol*)
	stStPDU_Header: StPDU_Header;(*PDU基础头/主要针对03和16两个功能字的请求*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
