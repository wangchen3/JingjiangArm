(*@CES
Name=StMBAP
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=18e79d68-9469-4b38-b2f6-5459a353a7ac
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StMBAP :(*Modbus-UDP应用层协议的7个字节*)
STRUCT
	uiInvocation: UINT;(*调用操作标识*)
	uiProtocol: UINT;(*协议*)
	uiLength: UINT;(*数据长度*)
	byUnit: BYTE;(*远程单元标识*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
