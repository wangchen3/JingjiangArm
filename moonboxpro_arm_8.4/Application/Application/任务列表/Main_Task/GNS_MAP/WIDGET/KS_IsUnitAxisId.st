(*@CES
Name=KS_IsUnitAxisId
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fbe75c62-94e0-460b-970c-a4df6e13b71e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_IsUnitAxisId : BOOL
(*色组轴id@轴id枚举里包含了非色组轴的定义*)
VAR_INPUT
	i_iAxisId:stEnumAxisId;
END_VAR
VAR
	xResult: BOOL;
END_VAR
{IMPLEMENTATION}
IF i_iAxisId>=AXISID_1U AND
	i_iAxisId<=AXISID_15U THEN
	xResult:=TRUE;
END_IF
KS_IsUnitAxisId:=xResult;