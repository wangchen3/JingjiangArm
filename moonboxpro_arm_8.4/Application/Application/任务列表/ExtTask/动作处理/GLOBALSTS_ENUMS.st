(*@CES
Name=GLOBALSTS_ENUMS
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=72e745eb-8b64-4285-a625-315fc9f93d85
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE GLOBALSTS_ENUMS :
(
	GSE_ESTOP				:= 1,(*急停状态|*)
	GSE_STOP				:= 2,(*停机状态|*)
	GSE_ACCING				:= 3,(*加速状态|*)
	GSE_DECING				:= 4,(*减速状态|*)
	GSE_INK					:= 5,(*空转状态|*)
	GSE_PRINT				:= 6,(*印刷状态|*)
	GSE_PRESTART			:= 7,(*预启动|*)
	GSE_KEEP_TENSION		:= 8,(*保持张力|*)
	GSE_PRINT_PRESTART		:= 9,(*印刷预启动|*)
	GSE_UNKNOWN				:= -1(*未知状态|*)
);
END_TYPE

{IMPLEMENTATION}
