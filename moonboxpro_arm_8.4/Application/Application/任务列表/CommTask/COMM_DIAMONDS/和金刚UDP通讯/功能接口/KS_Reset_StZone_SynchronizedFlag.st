(*@CES
Name=KS_Reset_StZone_SynchronizedFlag
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=96d189e0-34ee-41cd-a72d-4921ed0a61dc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Reset_StZone_SynchronizedFlag : INT
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
		i_pstStDataZone^.astStDataNode[uiN].bySynchronized:= 0;

		(*2025.8.5.094713/han.dp/如果写就置xWr_ing有效/如果读就置xRd_ing有效*)
		i_pstStDataZone^.astStDataNode[uiN].xRd_ing:= FALSE;
		i_pstStDataZone^.astStDataNode[uiN].xWr_ing:= FALSE;
	END_FOR
ELSE
	iResult:= -1;
END_IF
KS_Reset_StZone_SynchronizedFlag:= iResult;
