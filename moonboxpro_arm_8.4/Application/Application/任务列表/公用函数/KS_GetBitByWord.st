(*@CES
Name=KS_GetBitByWord
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=14ad4b69-ea73-4214-a3fe-9debcfa02eec
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetBitByWord : BOOL(*获取word中的位*)
VAR_INPUT
	i_byBitId:BYTE;(*0--15*)
	i_wValue:WORD;
END_VAR
VAR
	xGetDne: BOOL;
	wTmp: WORD;
	xBit:BOOL;
END_VAR
{IMPLEMENTATION}
IF i_byBitId>=0 AND
	i_byBitId<16 THEN
	wTmp:=SHR(i_wValue,i_byBitId);
	xBit:=wTmp.0;
END_IF
KS_GetBitByWord:=xBit;