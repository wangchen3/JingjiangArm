(*@CES
Name=KS_GetBitByDword
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6ef6fac5-03f1-4f35-a007-cccb879e1ed9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetBitByDword : BOOL(*获取Dword中的位*)
VAR_INPUT
	i_byBitId:BYTE;(*0--31*)
	i_dwValue:DWORD;
END_VAR
VAR
	xGetDne: BOOL;
	dwTmp: DWORD;
	xBit:BOOL;
END_VAR
{IMPLEMENTATION}
IF i_byBitId>=0 AND
	i_byBitId<16 THEN
	dwTmp:=SHR(i_dwValue,i_byBitId);
	xBit:=dwTmp.0;
END_IF
KS_GetBitByDword:=xBit;