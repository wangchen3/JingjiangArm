(*@CES
Name=KS_InstallMem_RS
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3c1006dd-3441-469c-8106-999143937635
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InstallMem_RS : INT
VAR_INPUT
	i_ppstStRSampFifo: POINTER TO POINTER TO StRSampFifo;
END_VAR
VAR
	iResult: INT;
	pstStRSampFifo_Tmp: POINTER TO StRSampFifo;
END_VAR
{IMPLEMENTATION}
IF i_ppstStRSampFifo<>0 THEN
	pstStRSampFifo_Tmp:= SysMemAlloc(SIZEOF(pstStRSampFifo_Tmp^));
	IF pstStRSampFifo_Tmp<>0 THEN
		pstStRSampFifo_Tmp^.byIDX_Wr:= 0;
		pstStRSampFifo_Tmp^.byIDX_Rd:= 0;
		i_ppstStRSampFifo^:= pstStRSampFifo_Tmp;
		iResult:= 0;
	ELSE
		iResult:= -2;(* 内存申请失败 *)
	END_IF
ELSE
	iResult:= -1;
END_IF
KS_InstallMem_RS:= iResult;