(*@CES
Name=KS_SetTrapDir
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=81943cc0-d64c-4c7b-ab28-c2314cf3c7fc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetTrapDir : INT
VAR_INPUT
	i_xEn : BOOL;
	i_iAxisId : INT;
	i_iCoreId : INT;
	i_xRevDir : BOOL;
END_VAR
VAR
	iN : INT;
	iRtn : INT;
	iResult : INT;
	
END_VAR

{IMPLEMENTATION}
iResult := 0;

IF i_xEn THEN
	IF i_iCoreId >= 1 AND i_iCoreId <=2 THEN
		IF i_xRevDir THEN
			iRtn := GTN_SetSense(core:= i_iCoreId, dataType:= MC_ENCODER, dataIndex:= i_iAxisId, value:= 1);
			iRtn := GTN_ProfileScale(core:= i_iCoreId, axis:= i_iAxisId, alpha:= 1, beta:= -1);
		ELSE
			iRtn := GTN_SetSense(core:= i_iCoreId, dataType:= MC_ENCODER, dataIndex:= i_iAxisId, value:= 0);
			iRtn := GTN_ProfileScale(core:= i_iCoreId, axis:= i_iAxisId, alpha:= 1, beta:= 1);
		END_IF
	ELSE
		iResult := -1;
	END_IF
END_IF


KS_SetTrapDir := iResult;