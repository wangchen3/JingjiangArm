(*@CES
Name=KS_GetAxisIdByStationId
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=70bbd18d-dc05-4e5d-8cd8-b579d4b6dda1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetAxisIdByStationId : INT
VAR_INPUT
 	i_StationId: INT;
	i_aiStationList_UnitController: ARRAY [1..MAX_STATION_NUM] OF INT;(*用月光宝盒/PRO时候，需要一个控制器列表，用于通讯？*)
END_VAR
VAR
	iUnitId:INT;
	iN:INT;
	xResult: BOOL;	
END_VAR

{IMPLEMENTATION}
iUnitId := 0;
IF i_StationId>=0 AND i_StationId<= MAX_STATION_NUM THEN
	FOR iN := 1 TO MAX_STATION_NUM BY 1 DO
		IF i_aiStationList_UnitController[iN] = i_StationId THEN
			iUnitId := iN;
			EXIT;
		END_IF
	END_FOR
END_IF
KS_GetAxisIdByStationId := iUnitId;
