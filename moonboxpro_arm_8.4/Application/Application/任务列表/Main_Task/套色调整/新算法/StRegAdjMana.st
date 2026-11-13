(*@CES
Name=StRegAdjMana
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=c5ea8ef8-7fa1-48f7-bc7e-73f35ed6d9a4
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StRegAdjMana :
STRUCT
	iIdxWr: INT;(* 当前写入id *)
	iIdxRd: INT;(* 当前读取id *)
	aiAdj_V: ARRAY [1..GC_PU_MAX_NUM] OF INT;(* 纵向调整量 *)
	aiAdj_H: ARRAY [1..GC_PU_MAX_NUM] OF INT;(* 横向调整量 *)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
