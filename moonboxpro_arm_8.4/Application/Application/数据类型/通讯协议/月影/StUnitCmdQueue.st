(*@CES
Name=StUnitCmdQueue
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=19a15640-4c7d-4711-b79a-2e35810a62a5
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StUnitCmdQueue :
STRUCT
	byCmdNum				: BYTE;(* 命令数量 *)
	byCmdIdx				: BYTE;(* 命令当前索引id *)
	aiCmdId					: ARRAY [1..MAX_CMD_NUM_PDU] OF INT;(* 命令id *)		
END_STRUCT
END_TYPE

{IMPLEMENTATION}
