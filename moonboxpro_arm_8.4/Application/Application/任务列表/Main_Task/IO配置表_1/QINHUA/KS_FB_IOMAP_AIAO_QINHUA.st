(*@CES
Name=KS_FB_IOMAP_AIAO_QINHUA
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=95805f6d-5389-4683-9ccd-89bb7210177c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_IOMAP_AIAO_QINHUA
VAR_INPUT
	i_xEn: BOOL;(*功能块使能|*)
	i_xRdInput: BOOL;(*读io输入|*)
	i_xWrOutput: BOOL;(*写io输出|*)	
	i_pstStSysParam								: POINTER TO StSysParam;
	i_pastStProgMonitoring						: POINTER TO ARRAY [1..2] OF StProgMonitoring;	
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;(*indicated to i_xEn|*)
	o_iErNo: INT;(*0.no err\-1.bad parameter|*)	
END_VAR
VAR
//	fb_KS_FB_SetAIType: KS_FB_SetAIType;
	fbKS_FB_Analog_IO_CTL: KS_FB_Analog_IO_CTL;	
	
	byAiFilterTms_UwRw_I					:  BYTE:= 1;(*滤波次数*)
	byAiFilterTms_UwRw_II					:  BYTE:= 1;
	byAiFilterTms_IfOf_I					:  BYTE:= 1;
	byAiFilterTms_IfOf_II					:  BYTE:= 1;
	byAiFilterTms_DiaMeasure_I				:   BYTE:= 1;			
	byAiFilterTms_DiaMeasure_II				:   BYTE:= 1;
END_VAR

{IMPLEMENTATION}
