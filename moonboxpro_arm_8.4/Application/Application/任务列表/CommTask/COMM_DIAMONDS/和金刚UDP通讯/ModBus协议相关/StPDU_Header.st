(*@CES
Name=StPDU_Header
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=e7e8d47d-075f-4d58-8263-79c4bddf08e0
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPDU_Header :(*Modbus/功能码/起始地址/寄存器数量*)
STRUCT
	byFunction: BYTE;
	uiAddress: UINT;
	uiQuantity: UINT;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
