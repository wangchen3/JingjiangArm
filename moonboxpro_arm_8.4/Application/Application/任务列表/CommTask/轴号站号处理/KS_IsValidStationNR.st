(*@CES
Name=KS_IsValidStationNR
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c4580633-d047-4a45-9578-afb5bd290b41
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_IsValidStationNR : BOOL
VAR_INPUT
	i_iStationNR: INT;
END_VAR
VAR
	xResult: BOOL;
END_VAR

{IMPLEMENTATION}
IF i_iStationNR>=0 AND i_iStationNR<MAX_STATION_NUM THEN
	xResult:= TRUE;
ELSE
	xResult:= FALSE;
END_IF
KS_IsValidStationNR:= xResult;