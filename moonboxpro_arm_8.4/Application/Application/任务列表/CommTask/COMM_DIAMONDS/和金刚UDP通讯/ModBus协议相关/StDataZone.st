(*@CES
Name=StDataZone
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=9a2c4743-5919-4081-a37c-2820a2d84e25
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StDataZone :(*Modbus读写区域*)
(*读写区域/节点地址+PARAM_ZONE_ALTERNATE_OFST*)
(*只写区域/节点地址+PARAM_ZONE_C2S*)
STRUCT
	uiNodeNum: UINT;(*节点数量/最大65535*)
	astStDataNode: ARRAY [1..MAX_DATA_NODE_NUM] OF StDataNode;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
