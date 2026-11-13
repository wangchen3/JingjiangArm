(*@CES
Name=StAxisRapidAdjProf_H
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=5051c563-c1c0-4e5b-a440-3f9f823cc70c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StAxisRapidAdjProf_H :
STRUCT
	iIdxWr: INT; (* 索引-写 *)
	iIdxRd: INT; (* 索引-读 *)
	aiAdjustment: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 快速调整量 *)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
