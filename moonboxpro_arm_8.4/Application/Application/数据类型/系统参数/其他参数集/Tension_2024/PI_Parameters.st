(*@CES
Name=PI_Parameters
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=b0e3524c-689e-4728-99f0-2c6c99433dca
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE PI_Parameters :
(*共12bytes|增加冗余空间*)
(*该结构体中参数需要保持 不能随意修改大小@2024.05.28.082414*)
STRUCT
	(*PI控制器参数*)
	(*K(s+a)/(s+b)*)
	K_PI:REAL;(*系统参数K_PI*)
	a:REAL;(*系统参数a*)
	b:REAL;(*系统参数b*)
(*	abyReserved:ARRAY [1..8] OF BYTE;*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
