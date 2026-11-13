(*@CES
Name=KS_GetNumOfDwordUsed
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eabd948f-bf57-46f0-b6b9-e9b06f242a41
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetNumOfDwordUsed : WORD
VAR_INPUT
	i_dwBytesNum				: DWORD;
END_VAR
VAR
	wResult						: WORD;
END_VAR
{IMPLEMENTATION}
wResult:= DWORD_TO_WORD(SHR(i_dwBytesNum, 2));
IF (i_dwBytesNum AND DWORD#3)<>0 THEN
	wResult:= wResult+1;
END_IF
KS_GetNumOfDwordUsed:= wResult;