(*@CES
Name=KS_CRC_16
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e85d0efd-f099-48e2-8c4c-78a018dd74a2
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CRC_16 : WORD
VAR_INPUT
	i_dwDataAdr:DWORD;(*数据起始地址*)
	i_iDataLen:INT;(*数据长度*)
END_VAR
VAR
	pbyData: POINTER TO BYTE;
	dwDataAdr: DWORD;
	iDataLen: INT;
	wIndex:WORD;
	byCRCHi:BYTE:=16#FF;
	byCRCLo:BYTE:=16#FF;
END_VAR
{IMPLEMENTATION}
IF i_dwDataAdr<>0 AND i_iDataLen>0 THEN
	dwDataAdr:=i_dwDataAdr;
	iDataLen:=i_iDataLen;

	pbyData:=dwDataAdr;
	WHILE iDataLen>0 DO
		pbyData:=dwDataAdr;
		iDataLen:=iDataLen-1;
		wIndex:=byCRCHi XOR pbyData^;
		byCRCHi:=byCRCLo XOR gc_auchCRCHi[wIndex];
		byCRCLo:=gc_auchCRCLo[wIndex];
		dwDataAdr:=dwDataAdr+1;
	END_WHILE

	KS_CRC_16:= ((SHL(BYTE_TO_WORD(byCRCHi), 8)))+BYTE_TO_WORD(byCRCLo);
END_IF