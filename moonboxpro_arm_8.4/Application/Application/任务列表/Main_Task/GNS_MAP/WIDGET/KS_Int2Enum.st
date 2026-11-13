(*@CES
Name=KS_Int2Enum
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ce208212-85df-4d43-9cce-e1a5fdafda9b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Int2Enum : BOOL
//枚举类型按照2个字节处理@简单点
VAR_INPUT
	i_stEnumAdr:DWORD;//枚举地址
	i_iData:INT;//转换值
END_VAR
VAR
	pitmp:POINTER TO INT;
END_VAR

{IMPLEMENTATION}
IF i_stEnumAdr<>0 THEN
	pitmp := i_stEnumAdr;
	pitmp^:= i_iData;
END_IF