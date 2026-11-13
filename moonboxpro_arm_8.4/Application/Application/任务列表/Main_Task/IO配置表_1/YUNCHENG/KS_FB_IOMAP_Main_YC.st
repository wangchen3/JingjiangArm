(*@CES
Name=KS_FB_IOMAP_Main_YC
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=78cc0731-9c37-4998-b1bf-cfc3648cca0c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_IOMAP_Main_YC
(*主面板IO配置分A/B系和放/收牵*)
(*正常单收单放选1和2*)
(*双收双放1和2是A系的放牵收牵，3和4是B系的放牵收牵*)
(*双收双放A放B收1和4*)
VAR_INPUT
	i_xEn: BOOL;(*功能块使能|*)
	i_xRdInput: BOOL;(*读io输入|*)
	i_xWrOutput: BOOL;(*写io输出|*)
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)
	i_pstStSysParam	:POINTER TO StSysParam;
END_VAR
VAR_OUTPUT
	o_xEno										: BOOL;(*indicated to i_xEn|*)
	o_iErNo										: INT;(*0.no err\-1.bad parameter|*)	
END_VAR
VAR
	afbKS_FB_MapIO_Main						: ARRAY [1..4] OF KS_FB_MapIO_Main;(*主面板IO配置*)
END_VAR


{IMPLEMENTATION}
