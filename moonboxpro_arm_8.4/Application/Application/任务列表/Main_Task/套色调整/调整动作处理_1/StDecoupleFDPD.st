(*@CES
Name=StDecoupleFDPD
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=450d2209-3f6c-402f-a034-37735462c49c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StDecoupleFDPD :
STRUCT
	arUk:ARRAY [1..3] OF REAL;(*输入寄存器*)
	arYk:ARRAY [1..3] OF REAL;(*输出寄存器*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
