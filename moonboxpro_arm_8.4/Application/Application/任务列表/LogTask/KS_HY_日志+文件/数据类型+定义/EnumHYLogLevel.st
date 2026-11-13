(*@CES
Name=EnumHYLogLevel
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=b48dcebc-463e-4092-80ad-422dbcf48ab3
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
(*{attribute 'qualified_only'}
{attribute 'strict'}*)
TYPE EnumHYLogLevel :
(
	LOG_LEVEL_INFO	:= 0,(* 一版消息 *)
	LOG_LEVEL_DEBUG	:= 1,(* 调试消息 *)
	LOG_LEVEL_ALARM	:= 2,(* 报警消息 *)
	LOG_LEVEL_ERROR	:= 3,(* 错误消息 *)
	LOG_LEVEL_FATAL	:= 4 (* 严重消息 *)
);
END_TYPE

{IMPLEMENTATION}
