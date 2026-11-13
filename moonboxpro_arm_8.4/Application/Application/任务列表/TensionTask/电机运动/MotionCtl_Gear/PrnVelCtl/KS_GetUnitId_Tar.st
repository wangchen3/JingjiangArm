(*@CES
Name=KS_GetUnitId_Tar
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=50ffccd4-38ae-4948-a424-e85895436bf8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetUnitId_Tar : INT(*获取目标轴id|轴号1--16*)
VAR_INPUT
	i_iUnitId_Cur:INT;(*当前轴id*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_STATION_NUM] OF INT; (*系内所有轴的列表*)
	i_pastStUnitParam_Save: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StUnitParam_Save;
	i_pastStUnitParam_UnSave: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StUnitParam_UnSave;
	i_pabyAxisMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF BYTE;(*轴运动状态|*)
END_VAR
VAR
	iUnitId_Tar: INT;
	iUnitId:INT;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	iN: INT;
END_VAR
{IMPLEMENTATION}
iUnitId_Tar:=-1;
IF i_iUnitId_Cur>0 AND
	i_iUnitId_Cur<=16 AND
	i_iGrpAxisNum_Pu>1 AND
	i_paiGrpAxisList<>0 AND
	i_pastStUnitParam_Save<>0 AND
	i_pastStUnitParam_UnSave<>0 AND
	i_pabyAxisMotionSts<>0 THEN

	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:=i_paiGrpAxisList^[iN];
		IF iUnitId<>i_iUnitId_Cur THEN
			pstStUnitParam_Save:=ADR(i_pastStUnitParam_Save^[iUnitid]);
	
			IF pstStUnitParam_Save^.xLinkage AND(*联动*)
				NOT pstStUnitParam_Save^.xSwitchOn_CoatingPrn AND(*非涂布色组*)
				i_pabyAxisMotionSts^[iUnitId]=0 THEN(*处于同步运动状态*)
				iUnitId_Tar:=iUnitId;
				EXIT;
			END_IF
		END_IF
	END_FOR
END_IF
KS_GetUnitId_Tar:=iUnitId_Tar;