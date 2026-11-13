(*@CES
Name=KS_FB_IOMAP_UwRw_KS1
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3fdf527d-7ba2-4b44-94e3-31e35d6ee8ed
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
 FUNCTION_BLOCK KS_FB_IOMAP_UwRw_KS1
VAR_INPUT
	i_xEn: BOOL;(*功能块使能|*)
	i_xRdInput: BOOL;(*读io输入|*)
	i_xWrOutput: BOOL;(*写io输出|*)
	i_pastStIOMap_UwRw_FE_Uw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|*)
	i_pastStIOMap_UwRw_FE_Rw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|*)
END_VAR
VAR_OUTPUT
	o_xEno										: BOOL;(*indicated to i_xEn|*)
	o_iErNo										: INT;(*0.no err\-1.bad parameter|*)	
END_VAR
VAR
	afbKS_FB_MapIO_UwRw_Uw						: ARRAY [1..2] OF KS_FB_MapIO_UwRw;
	afbKS_FB_MapIO_UwRw_Rw						: ARRAY [1..2] OF KS_FB_MapIO_UwRw;
END_VAR



{IMPLEMENTATION}
