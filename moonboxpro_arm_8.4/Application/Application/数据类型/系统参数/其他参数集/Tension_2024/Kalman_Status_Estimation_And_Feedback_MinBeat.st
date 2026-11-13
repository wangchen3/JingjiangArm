(*@CES
Name=Kalman_Status_Estimation_And_Feedback_MinBeat
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=878dded7-317a-4582-b4ff-cfa950f880b6
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE Kalman_Status_Estimation_And_Feedback_MinBeat :
(*共150bytes|增加冗余空间，该结构体中参数需要保持*)
STRUCT
	R_K:REAL;
	Q:ARRAY [1..4,1..4] OF REAL;
	P0:ARRAY [1..4,1..4] OF REAL;
	N_MinBeat:INT;
	Kf:ARRAY [1..4] OF REAL;

(*	abyReserved:ARRAY [1..8] OF BYTE;*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
