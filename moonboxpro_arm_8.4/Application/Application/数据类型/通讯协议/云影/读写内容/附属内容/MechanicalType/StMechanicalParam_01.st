(*@CES
Name=StMechanicalParam_01
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=5eed9775-afb6-4c37-b952-a7778bcdffd6
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StMechanicalParam_01 :(*摆臂结构*)
STRUCT
	lrX1	: LREAL;
	lrY1	: LREAL;
	lrX3	: LREAL;
	lrY3	: LREAL;
	lrX5	: LREAL;
	lrY5	: LREAL;
	lrX6	: LREAL;
	lrY6	: LREAL;
	lrL1	: LREAL;
	lrL2	: LREAL;
	lrD1	: LREAL;
	lrD2	: LREAL;
	lrD3	: LREAL;
	lrDR	: LREAL;
	lrA		: LREAL;
END_STRUCT
END_TYPE
{IMPLEMENTATION}
