(*@CES
Name=stEnumMoveType
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=686aa444-d3fe-4889-be0c-cd0099a56b1b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
//{attribute 'qualified_only'}
{attribute 'strict'}
TYPE stEnumMoveType :((*运动类型*)
	MOVETYPE_NULL :=0,(*不运动*)
	MOVETYPE_TRAP ,(*点位运动*)
	MOVETYPE_GANTRY,(*龙门运动*)
	MOVETYPE_ROTARY,(*旋转电机*)
	MOVETYPE_ROTARY_SUPERPOS(*旋转电机-叠加位置*)
);
END_TYPE
{IMPLEMENTATION}
