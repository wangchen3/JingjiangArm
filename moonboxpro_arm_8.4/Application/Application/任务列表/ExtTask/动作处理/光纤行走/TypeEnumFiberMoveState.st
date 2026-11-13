(*@CES
Name=TypeEnumFiberMoveState
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=731ba6b0-59cf-46aa-ad0e-8bd1713c03ab
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE TypeEnumFiberMoveState :
(
	FIBERMOVE_IDLE,(*空闲*)
	FIBERMOVE_GOHOME,(*回零*)
	FIBERMOVE_RUN,(*启动*)
	FIBERMOVE_GETBASEPOS,(*获取基准位置*)
	FIBERMOVE_ALARM,(*报警*)
	FIBERMOVE_DEBUG(*调试*)
);
END_TYPE

{IMPLEMENTATION}
