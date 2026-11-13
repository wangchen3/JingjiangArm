(*@CES
Name=TypeEnumStepDriveStat
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=3c3a1540-5152-4e9f-b7fc-bae736162d3c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE TypeEnumStepDriveStat :
(
	STEPDRIVE_IDLE,(*空闲*)
	STEPDRIVE_RUN,(*启动*)
	STEPDRIVE_CLR,(*状态清除*)
	STEPDRIVE_WAITING,(*等待一个周期*)
	STEPDRIVE_MODULE_VALID,(*模块使能*)
	STEPDRIVE_PULSEOUT,(*脉冲输出*)
	STEPDRIVE_ALARM(*报警*)
);
END_TYPE

{IMPLEMENTATION}
