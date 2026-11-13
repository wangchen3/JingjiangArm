(*@CES
Name=KS_InitStProofList
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=42c94ff1-daf9-4f57-bbca-92a4069f4f99
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitStProofList : INT
VAR_INPUT
	i_pstStProofList: POINTER TO StProofList;
END_VAR
VAR
	iN: int;
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pstStProofList<>0 THEN
	(*清除证据链列表*)
	FOR iN:=1 TO MAX_MB_FIFO_ITEMS BY 1 DO
		i_pstStProofList^.astStProofItem[iN].iWaitRespCycles:= 0;
		i_pstStProofList^.astStProofItem[iN].stStADU.stStMBAP.uiInvocation:= 0;
		i_pstStProofList^.astStProofItem[iN].stStADU.stStMBAP.uiProtocol:= 0;
		i_pstStProofList^.astStProofItem[iN].stStADU.stStMBAP.uiLength:= 0;
		i_pstStProofList^.astStProofItem[iN].stStADU.stStMBAP.byUnit:= 0;
		i_pstStProofList^.astStProofItem[iN].stStADU.stStPDU_Header.byFunction:= 0;
		i_pstStProofList^.astStProofItem[iN].stStADU.stStPDU_Header.uiAddress:= 0;
		i_pstStProofList^.astStProofItem[iN].stStADU.stStPDU_Header.uiQuantity:= 0;
	END_FOR
ELSE
	iResult:= -1;
END_IF
KS_InitStProofList:= iResult;
