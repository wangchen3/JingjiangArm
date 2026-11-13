(*@CES
Name=Kalman_Status_Estimation_And_Feedback
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=be73da61-1457-470f-a8cd-978fb9564fdc
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE Kalman_Status_Estimation_And_Feedback :
(*共152bytes|增加冗余空间，该结构体中参数需要保持*)
STRUCT
	R_K:REAL;
	Q:ARRAY [1..4,1..4] OF REAL;
	P0:ARRAY [1..4,1..4] OF REAL;
	N_LQR:REAL;
	Kf:ARRAY [1..4] OF REAL;

	(*2024.06.08.150600+lreal类型*)
	alrQ:ARRAY [1..4,1..4] OF LREAL;
	alrP0:ARRAY [1..4,1..4] OF LREAL;
	alrKf:ARRAY [1..4] OF LREAL;
(*	abyReserved:ARRAY [1..8] OF BYTE;*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
