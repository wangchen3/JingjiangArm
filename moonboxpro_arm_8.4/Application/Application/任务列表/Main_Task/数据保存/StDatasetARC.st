(*@CES
Name=StDatasetARC
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=69ace8d2-a69c-463b-82d9-fd44ae904e34
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StDatasetARC :
STRUCT
	byIdxWr: BYTE; (* 索引-写 *)
	byIdxRd: BYTE; (* 索引-读 *)
	astStRecord_A: ARRAY [0..255] OF StRecord_A; (* 数据区域 *)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
