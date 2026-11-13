(*@CES
Name=MatProduct
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c51cd6fe-fb5a-47c0-a409-be36c7f0e134
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
(*需要预先输入：输入矩阵的维数，输出矩阵的维数*)
FUNCTION MatProduct : REAL
VAR_INPUT
	LMat_Row:INT;
	LMat_Col:INT;
	RMat_Row:INT;
	RMat_Col:INT;
	pLMat_Member:POINTER TO  REAL;
	pRMat_Member:POINTER TO  REAL;
	pOutMat_Member:POINTER TO  REAL;
END_VAR
VAR
	iN: INT;
	iJ: INT;
	iK: INT;
	pRMat_temp:POINTER TO  REAL;
	pLMat_temp:POINTER TO  REAL;
	rTwmp1: REAL;
	DW: DWORD;
	rTwmp2: REAL;
	WordLength:DWORD;
END_VAR

{IMPLEMENTATION}
IF pRMat_Member=0 OR pLMat_Member=0 THEN
	RETURN;
END_IF
(*SysMemSet(i_pPh,0,4*9);*)
WordLength:=REAL_TO_DWORD(SIZEOF(pLMat_Member^));
FOR iN:=0 TO LMat_Row-1 BY +1 DO
	FOR iJ:=0 TO RMat_Col-1 BY +1 DO
             pOutMat_Member^:=0;
		FOR iK:=0 TO LMat_Col-1 BY +1 DO
			DW:=INT_TO_DWORD(iN*LMat_Col+iK);
                    pLMat_temp:=pLMat_Member+DW*WordLength;
			rTwmp1:=pLMat_temp^;

			DW:=INT_TO_DWORD(iJ+iK*RMat_Col);
			pRMat_temp:=pRMat_Member+DW*WordLength;
			rTwmp2:=pRMat_temp^;
                   pOutMat_Member^:= pOutMat_Member^+pLMat_temp^*pRMat_temp^;
		END_FOR
		pOutMat_Member:=pOutMat_Member+WordLength;
	END_FOR
END_FOR
(*pOutMat_Member:=pOutMat_Member-WordLength*(LMat_Row*RMat_Col-1);*)