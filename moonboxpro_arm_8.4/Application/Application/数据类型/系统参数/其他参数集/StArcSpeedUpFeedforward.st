(*@CES
Name=StArcSpeedUpFeedforward
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=b9193669-47b2-40da-89b1-6ca603c59eae
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StArcSpeedUpFeedforward :
(*套色升速前馈@30BYTES*)
STRUCT
	rK:REAL;(*前馈系数-低速段*)
	rK_2:REAL;(*前馈系数-高速段*)
	abyReserved:ARRAY [1..22] OF BYTE;
(*	abyReserved:ARRAY [1..26] OF BYTE;*)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
