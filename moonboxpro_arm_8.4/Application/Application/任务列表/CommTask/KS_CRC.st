(*@CES
Name=KS_CRC
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c4c7953d-06dd-403a-ba97-b7ea9fcb71b0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CRC : WORD
VAR_INPUT
	i_pbyBuf: POINTER TO BYTE :=0;
	i_dwLen: DWORD;
	i_pdwSumResult: POINTER TO DWORD := 0;
END_VAR
VAR
	dwN: DWORD;
	wMask: WORD;
	wResult: WORD;
	dwSumResult: DWORD;
	pbyTemp: POINTER TO BYTE := 0;
END_VAR
{IMPLEMENTATION}

pbyTemp:= i_pbyBuf;
wResult:= 0;
dwSumResult:= 0;
FOR dwN:=1 TO i_dwLen BY 1 DO
	dwSumResult:= dwSumResult+(pbyTemp^);
	wMask:= CRC_DICTIONARY[WORD_TO_INT((wResult XOR BYTE_TO_WORD(pbyTemp^)) AND 16#FF)];
	wResult:= wMask XOR SHR(wResult,8);
	pbyTemp:= pbyTemp+1;
END_FOR
IF i_pdwSumResult<>0 THEN
	i_pdwSumResult^:= dwSumResult;
END_IF
KS_CRC:= wResult;