(*@CES
Name=Time_Varying_Parameters
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=84773baf-ceab-4b75-a59b-2e424c093143
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE Time_Varying_Parameters :
STRUCT
    EST_R: REAL;             	(*卷半径m*)
    a0: REAL;           	(*a0*)
    b1: REAL;	 	(*b1*)
    Wn: REAL;		(*Wn*)
    Beta: REAL;		(*Beta*)
    l: REAL;		(*调整系数l*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
