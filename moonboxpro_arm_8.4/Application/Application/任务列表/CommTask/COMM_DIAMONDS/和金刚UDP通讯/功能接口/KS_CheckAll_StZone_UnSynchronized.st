(*@CES
Name=KS_CheckAll_StZone_UnSynchronized
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=07bfdfe8-2771-43fc-9a3c-80039394908a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CheckAll_StZone_UnSynchronized : INT(*0表示都同步了/>0表示未同步的数量/<0表示错误*)
VAR_INPUT
	i_pstStDataZone: POINTER TO StDataZone;(*读写区域*)
END_VAR
VAR
	uiN: UINT;
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pstStDataZone<>0 THEN
	FOR uiN:=1 TO i_pstStDataZone^.uiNodeNum BY 1 DO
		IF i_pstStDataZone^.astStDataNode[uiN].bySynchronized<>SINT_TO_BYTE(-1) THEN
			iResult:= iResult+1;(*未同步的数量+1*)
		END_IF
	END_FOR
ELSE
	iResult:= -1;
END_IF
KS_CheckAll_StZone_UnSynchronized:= iResult;
