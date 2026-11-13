(*@CES
Name=StAxisRapidAdjProf_V
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=880600c0-33b6-45cc-b2cb-0ddee2d5a314
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StAxisRapidAdjProf_V :
STRUCT
	iIdxWr: INT; (* 索引-写 *)
	iIdxRd: INT; (* 索引-读 *)
	adiAdjustment: ARRAY [1..MAX_UNIT_NUM] OF DINT; (* 快速调整量 *)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
