(*@CES
Name=KS_FB_IOMAP_Axis_KS1
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5e1ef807-2a8d-4def-8e48-4f55f608734d
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_IOMAP_Axis_KS1
VAR_INPUT
	i_xEn: BOOL;(*功能块使能|*)
	i_xRdInput: BOOL;(*读io输入|*)
	i_xWrOutput: BOOL;(*写io输出|*)
	i_pastStIOMap_Axis_FE						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
END_VAR
VAR_OUTPUT
	o_xEno										: BOOL;(*indicated to i_xEn|*)
	o_iErNo										: INT;(*0.no err\-1.bad parameter|*)	
END_VAR
VAR
	afbKS_FB_IOMap_Axis							: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_MapAxisIOBasic;(*色组IO配置*)
END_VAR

{IMPLEMENTATION}
