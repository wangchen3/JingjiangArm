(*@CES
Name=KS_HY_GetAxisIdForMotByStation
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=98e977ff-93c3-495b-bafe-fe457f0448cc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_HY_GetAxisIdForMotByStation : BOOL
VAR_INPUT
	i_iStationId: INT;
	i_piAxisId: POINTER TO INT;
	i_piTypeId: POINTER TO INT;
	i_piUnitId: POINTER TO INT;
	i_piCoreId: POINTER TO INT;
	i_piGroupId : POINTER TO INT;
	i_piAdjAxisId : POINTER TO INT;
	i_pastStAxisIdListInf: POINTER TO ARRAY [1..128] OF StAxisIdListInf;
END_VAR
VAR
	iN: INT;
	xResult: BOOL;
END_VAR

{IMPLEMENTATION}
xResult:= FALSE;
IF i_piAxisId<>0 AND i_piTypeId<>0 AND i_piUnitId<>0 AND i_piCoreId<>0 AND i_pastStAxisIdListInf<>0 AND
	i_iStationId>=0 AND i_iStationId< MAX_STATION_NUM THEN
	FOR iN:=1 TO 128 BY 1 DO
		IF i_iStationId= i_pastStAxisIdListInf^[iN].iStdId THEN
			i_piAxisId^:= i_pastStAxisIdListInf^[iN].iAxisId;
			i_piTypeId^:= i_pastStAxisIdListInf^[iN].iTypeId;
			i_piUnitId^:= i_pastStAxisIdListInf^[iN].iUnitId;
			i_piCoreId^:= i_pastStAxisIdListInf^[iN].iCoreId;
			i_piGroupId^:= i_pastStAxisIdListInf^[iN].iGroupId;
			i_piAdjAxisId^:= i_pastStAxisIdListInf^[iN].iAdjAxisId;
			EXIT;
		END_IF
	END_FOR
END_IF