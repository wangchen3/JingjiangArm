(*@CES
Name=KS_FB_Func_IfOf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=62ddb97d-87f2-4e86-970f-1b823eab0bf1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Func_IfOf
VAR_INPUT
	i_xEn : BOOL;
	i_iGrpId : INT;
	i_iIndex_MainIO_If: INT;
	i_iIndex_MainIO_Of: INT;	
	i_pastStIOMap_Main_FE					: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
	i_pstStSysParam: POINTER TO StSysParam;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	fbKS_FB_Func_If: KS_FB_Func_If;
	fbKS_FB_Func_Of: KS_FB_Func_Of;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam <> 0 THEN
		Action_If();
		Action_Of();
	ELSE;
	END_IF
ELSE;
END_IF
