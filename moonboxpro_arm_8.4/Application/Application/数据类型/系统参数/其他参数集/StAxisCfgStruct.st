(*@CES
Name=StAxisCfgStruct
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=69d05dad-9768-48d4-85b0-14945c9a532b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StAxisCfgStruct :
STRUCT
	dwAxisProf		: DWORD:= 0;
							(*
							/ bit0=TRUE 轴打开
							/ bit1=TRUE 运动反向
							/ bit2=TRUE 采样反向() 
							/ bit3~bit30 保留
							/ bit31=TRUE 站点存在于列表中
							*)
	iSid			: INT:= -1;
							(*
							/ -1表示无效轴
							/ 1~255(采用GNS方案后0作为GNS的默认分配/不体现在系统配置中
							*)
	iUnitId          :INT:=1;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
