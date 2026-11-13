(*@CES
Name=StArcSpeedUp
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=efa365e6-af1e-4d1e-a80c-1fadbf9c4286
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StArcSpeedUp :
(*套色升速参数@主要是小黄设计的双积分控制器的参数*)
(*每个轴的参数都可能不一样@30bytes*)
STRUCT
	rK:REAL;(*增益系数*)
	rA2:REAL;(*模型参数*)
	rA1:REAL;(*模型参数*)
	rA0:REAL;(*模型参数*)
	abyReserved:ARRAY [1..14] OF BYTE;
END_STRUCT
END_TYPE


{IMPLEMENTATION}
