(*@CES
Name=KS_FB_IOMAP_AxisExtra_QINHUA
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9bc3f83a-ed30-48fd-b56f-7d7783b3359f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_IOMAP_AxisExtra_QINHUA
VAR_INPUT
	i_xEn: BOOL;(*功能块使能|*)
	i_xRdInput: BOOL;(*读io输入|*)
	i_xWrOutput: BOOL;(*写io输出|*)
	i_pastStIOMap_Axis_Extra_FE						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;(*轴io数据区域|*)
END_VAR
VAR_OUTPUT
	o_xEno										: BOOL;(*indicated to i_xEn|*)
	o_iErNo										: INT;(*0.no err\-1.bad parameter|*)	
END_VAR
VAR
	afbKS_FB_IOMap_AxisExtra							: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_MapAxisIOExtra;(*色组IO配置*)
END_VAR

{IMPLEMENTATION}
