(*@CES
Name=StADU
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=730e2a17-289c-4459-a153-1a559c1b0add
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StADU :(*Modbus-UDP应用层协议的7个字节*)
STRUCT
	stStMBAP: StMBAP;(*ModBus Application Protocol*)
	stStPDU_Header: StPDU_Header;(*PDU基础头/主要针对03和16两个功能字的请求*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
