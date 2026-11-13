(*@CES
Name=KS_GetCoreAndAxisIdByStationId
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a5371cf2-ec50-4947-b43a-b8c7da498013
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetCoreAndAxisIdByStationId : INT
VAR_INPUT
	i_StationId: INT;
	i_piCoreId: POINTER TO INT;
	i_piAxisId: POINTER TO INT;
	i_aiStationIdList						: ARRAY [1..MAX_STATION_NUM] OF INT;(* 站号列表 *)
END_VAR
VAR
	iCoreId:INT;
	iUnitId:INT;
	iN:INT;
	xResult: BOOL;	
END_VAR

{IMPLEMENTATION}
xResult := 0;
IF i_StationId>=0 AND i_StationId<= MAX_STATION_NUM AND
	i_piCoreId <>0 AND i_piAxisId <> 0 THEN
	
	FOR iN := 1 TO MAX_STATION_NUM BY 1 DO
		IF i_aiStationIdList[iN] = i_StationId THEN
			iUnitId := iN;
			EXIT;
		END_IF
	END_FOR
	IF iUnitId > 64 THEN
		iCoreId := 2;
		iUnitId := iUnitId - 64;
	ELSE
		iCoreId := 1;
	END_IF
	i_piCoreId^ := iCoreId;
	i_piAxisId^ := iUnitId;
END_IF