(*@CES
Name=StSysGantryAxisInf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=7a9ba2fe-c896-4159-a4c9-1568d21622d8
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StSysGantryAxisInf :(*系统龙门轴信息@总共20个龙门轴*)
STRUCT
	byGantryAxisNum:BYTE;(*龙门轴总数*)
	astGantryAxisInf:ARRAY [1..20] OF StGantryAxisInf;
END_STRUCT
END_TYPE
{IMPLEMENTATION}
