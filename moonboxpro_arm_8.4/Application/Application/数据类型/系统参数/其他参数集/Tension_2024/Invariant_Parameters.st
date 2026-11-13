(*@CES
Name=Invariant_Parameters
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=a59fa2b6-149e-4947-99eb-438790530e43
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE Invariant_Parameters :
(*共16bytes|增加冗余空间*)
(*该结构体中参数需要保持 不能随意修改大小@2024.05.28.082414*)
STRUCT
    Ts: REAL;		(*采样时间Ts*)
    Range: REAL;    	(*输出最大量程*)
    Theta: REAL;	(*摆臂偏角范围*)
    K_adj: REAL;		(*模型调整增益*)
(*	abyReserved:ARRAY [1..14] OF BYTE;*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
