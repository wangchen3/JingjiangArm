(*@CES
Name=StDataNode
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=d2752c56-02c4-4ac3-a8e3-7575782c62c6
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StDataNode :(*Modbus读写区域*)
STRUCT
	uiAddress: UINT;(*寄存器地址/相对于字节数有2倍关系*)
	uiQuantity: UINT;(*寄存器数量*)
	bySynchronized: BYTE;(*同步过的标志/0表示未同步/1表示当前在fifo中/255表示已经完成同步*)
	xRd_ing: BOOL;(*写操作进行中*)
	xWr_ing: BOOL;(*读操作进行中*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
