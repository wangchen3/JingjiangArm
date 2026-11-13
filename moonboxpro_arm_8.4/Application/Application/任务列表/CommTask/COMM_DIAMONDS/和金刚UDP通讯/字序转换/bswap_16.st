(*@CES
Name=bswap_16
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=23f18752-a056-4851-b32f-04af14ba319d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION bswap_16 : UINT
VAR_INPUT
	i_uiData: UINT;
END_VAR
VAR
END_VAR

{IMPLEMENTATION}
bswap_16:= SHR(i_uiData,8) OR SHL(i_uiData,8);
