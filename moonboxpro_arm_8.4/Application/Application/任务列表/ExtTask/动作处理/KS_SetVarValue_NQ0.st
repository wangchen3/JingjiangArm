(*@CES
Name=KS_SetVarValue_NQ0
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b4c3880f-3565-4c03-a3ee-9be25f97e488
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetVarValue_NQ0 : BOOL
VAR_INPUT
	i_dwVarAdr:DWORD;(*变量地址*)
	i_iSetValue:INT;(*设置的初始值|暂定设置的初始值为int型*)
	i_EmVarType:TypEnumDataType;(*变量类型*)
END_VAR
VAR
	piVar:POINTER TO INT;
END_VAR
{IMPLEMENTATION}
IF i_dwVarAdr<>0 THEN;ELSE RETURN;END_IF
CASE i_EmVarType OF
TYPE_BOOL:;
TYPE_INT:
	piVar:=i_dwVarAdr;
	IF piVar^=0 THEN
		piVar^:=i_iSetValue;
	END_IF
TYPE_WORD:;
TYPE_DWORD:;
TYPE_REAL:;
TYPE_LREAL:;
ELSE;
END_CASE