(*@CES
Name=Initial_Model_Parameters
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=d7326a99-ac75-4fbf-9581-4e08c3dedfbc
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE Initial_Model_Parameters :
(*共24bytes|增加冗余空间*)
(*该结构体中参数需要保持 不能随意修改大小@2024.05.28.082414*)
STRUCT
    R_0: REAL;             (*初始卷半径m*)
    a0_0: REAL;           (*初始a0*)
    b1_0: REAL;	 	(*初始b1*)
    Wn_0: REAL;	(*初始Wn*)
    Beta_0: REAL;	(*初始Beta*)
    l_0: REAL;		(*初始调整系数l*)
(*	abyReserved:ARRAY [1..26] OF BYTE;*)

END_STRUCT
END_TYPE

{IMPLEMENTATION}
