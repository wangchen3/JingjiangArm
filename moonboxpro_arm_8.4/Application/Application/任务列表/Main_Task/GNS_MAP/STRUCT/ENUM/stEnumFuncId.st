(*@CES
Name=stEnumFuncId
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=977dc716-2507-48a6-a21c-666c8469de7d
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
//{attribute 'qualified_only'}
{attribute 'strict'}
TYPE stEnumFuncId :((*色组驱动器的功能id*)
	FUNCID_NULL :=-1,(*无功能*)
	FUNCID_RESERVED,(*占位*)
	(*站的功能*)
	FUNCID_CONTROL,(*控制功能@目前架构应该是月光系列*)
	FUNCID_PRNROLLER,(*版辊*)
	FUNCID_NETROLLER,(*网辊*)
	FUNCID_BOTTOMROLLER,(*底辊*)
	FUNCID_PRNROLLER_PRESSURE_M,(*版辊压力|操作侧*)
	FUNCID_PRNROLLER_PRESSURE_G,
	FUNCID_NETROLLER_PRESSURE_M,(*网辊压力|操作侧*)
	FUNCID_NETROLLER_PRESSURE_G,
	FUNCID_HORZ,(*横向*)
	(*龙门功能id@*)
	FUNCID_PRNROLLER_GANTRY,(*印刷辊龙门*)
	FUNCID_NETROLLER_GANTRY(*网纹辊龙门*)
);
END_TYPE

{IMPLEMENTATION}
