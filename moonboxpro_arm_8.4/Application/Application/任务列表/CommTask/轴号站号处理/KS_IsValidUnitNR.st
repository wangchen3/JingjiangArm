(*@CES
Name=KS_IsValidUnitNR
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8ab37e44-6a25-425d-9d9c-1a5dcec00b7a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_IsValidUnitNR : BOOL
VAR_INPUT
	i_iUnitNR: INT;
END_VAR
VAR
	xResult: BOOL;
END_VAR
{IMPLEMENTATION}
IF i_iUnitNR>=1 AND i_iUnitNR<=MAX_UNIT_NUM THEN
	xResult:= TRUE;
ELSE
	xResult:= FALSE;
END_IF
KS_IsValidUnitNR:= xResult;