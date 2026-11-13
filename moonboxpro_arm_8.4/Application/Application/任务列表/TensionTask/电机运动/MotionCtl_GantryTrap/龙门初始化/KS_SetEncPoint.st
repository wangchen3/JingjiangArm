(*@CES
Name=KS_SetEncPoint
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=489127b3-87fc-4286-be69-a7e48303fbd1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetEncPoint : INT
VAR_INPUT
	i_xEn : BOOL;
	i_iStationId : INT;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
END_VAR
VAR
	iN : INT;
	iRtn : INT;
	iResult : INT;
	
	iRtn_Local : INT;
	iRtn_Mul : INT;
	liPos : LINT;
	
	iStationId : INT;
	iAxisId : INT;
	iTypeId : INT;
	iUnitId : INT;
	iCoreId : INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	
	//diCurrentAbsPos : DINT;
	
	lrCurrentAbsPos : LREAL;
END_VAR

{IMPLEMENTATION}

iResult := 0;
iRtn_Local := 0;
iRtn_Mul := 0;

IF i_xEn THEN
	IF i_pastStAxisIdListInf <> 0 THEN
		KS_HY_GetAxisIdForMotByStation(
				i_iStationId,
				ADR(iAxisId),
				ADR(iTypeId),
				ADR(iUnitId),
				ADR(iCoreId),
				ADR(iGroupId),
				ADR(iAdjAxisId),
				i_pastStAxisIdListInf);
		//iRtn_Local :=GTN_RN_GetAbsEncPosEx(core:= iCoreId, encoder:= iAxisId, pEncPos:= ADR(diCurrentAbsPos));
		iRtn_Local := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:= i_iStationId, encoder:= 1, pPos:= ADR(lrCurrentAbsPos));

		iRtn_Mul := iRtn_Mul + iRtn_Local;
		
		IF lrCurrentAbsPos >= 16#FFFFFFFF THEN
			;
		END_IF
		iRtn_Local := GTN_SetEncPos(core:= iCoreId, encoder:= iAxisId, encPos:= LREAL_TO_DINT(lrCurrentAbsPos));
		IF iRtn_Local<> 0 THEN
			;
		END_IF
		iResult := iRtn_Local;
	ELSE
		iResult := -1;
	END_IF
ELSE
	;
END_IF

KS_SetEncPoint := iResult;
