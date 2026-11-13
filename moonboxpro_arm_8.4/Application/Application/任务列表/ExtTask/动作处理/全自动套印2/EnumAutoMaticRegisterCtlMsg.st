(*@CES
Name=EnumAutoMaticRegisterCtlMsg
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=e7e8891f-fe97-4a56-9291-de397fe1a69c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
// {attribute 'qualified_only'}
// {attribute 'strict'}
TYPE EnumAutoMaticRegisterCtlMsg :
(
	AMRC_MSG_NORMAL := 0,                (* 正常 *)
    AMRC_MSG_ERR_BUSY_HOR,               (* 横向正忙 *)
    AMRC_MSG_ERR_LASTAXISID_INVALID,     (* 最后一个轴id非法 *)
    AMRC_MSG_ERR_AUTOPREGISTER_VER,      (* 自动纵向套印失败 *)
    AMRC_MSG_TIMEOUT_HOR,                (* 横向预套准启动超时状态 *)
    AMRC_MSG_TIMEOUT_WAITPOS_3RD,        (* 第三方设备位置等待超时 *)
    AMRC_MSG_TIMEOUT_WAITPOS_MANU        (* 手动位置等待超时 *)
);
END_TYPE

{IMPLEMENTATION}
