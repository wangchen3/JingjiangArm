(*@CES
Name=KS_CheckStationOnLine_
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c5e0cdd1-19ab-4cb0-a985-998ee908852c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CheckStationOnLine_ : BOOL
VAR_INPUT
	i_iSid : INT;
	i_iStationNum : INT;
	i_paiStationId_List : POINTER TO ARRAY [1..128] OF INT;
END_VAR
VAR
	iN : INT;
	xResult : BOOL;
END_VAR

{IMPLEMENTATION}
xResult := FALSE;

FOR iN := 1 TO i_iStationNum BY 1 DO
	IF i_iSid = i_paiStationId_List^[iN] THEN
		xResult := TRUE;
		EXIT;
	END_IF
END_FOR

KS_CheckStationOnLine_ := xResult;

