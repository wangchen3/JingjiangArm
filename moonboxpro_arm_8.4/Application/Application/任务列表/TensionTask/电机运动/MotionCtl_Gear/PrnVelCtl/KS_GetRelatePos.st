(*@CES
Name=KS_GetRelatePos
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=64bf2139-19b0-44f0-86e4-ed0fdab8fbfc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetRelatePos : BOOL(*计算所有目标轴和当前轴的相对位置|节省空间就只做16个轴
								目标轴为联动非涂布轴*)
VAR_INPUT
	i_iAxisId_Cur:INT;(*当前轴id*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT; (*系内所有轴的列表*)
	i_pastStUnitParam_Save: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StUnitParam_Save;
	i_pastStUnitParam_UnSave: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StUnitParam_UnSave;
	i_palrRelatePos:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*索引为目标轴*)
END_VAR
VAR
	in: INT;
	iAxisId: INT;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStUnitParam_Cur_UnSave: POINTER TO StUnitParam_UnSave;
	ailist: ARRAY [1..MAX_STATION_NUM] OF INT;(*联动非涂布列表|不包含当前色*)
	iIndex:INT;
	xDne: BOOL;(*获取成功了*)
END_VAR
{IMPLEMENTATION}
(*初始化*)
IF	i_palrRelatePos<>0	THEN
	FOR iN:=1 TO 16 BY 1 DO
		i_palrRelatePos^[iN]:=0;
	END_FOR
END_IF
iIndex:=0;
IF i_iAxisId_Cur>0 AND
	i_iAxisId_Cur<=16 AND
	i_iGrpAxisNum_Pu>1 AND
	i_paiGrpAxisList<>0 THEN
	pstStUnitParam_Cur_UnSave:=ADR(i_pastStUnitParam_UnSave^[i_iAxisId_Cur]);
	FOR in:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iAxisId:=i_paiGrpAxisList^[iN];
		IF iAxisId<>i_iAxisId_Cur THEN(*非当前轴*)
			pstStUnitParam_Save:=ADR(i_pastStUnitParam_Save^[iAxisId]);
			IF pstStUnitParam_Save^.xLinkage AND(*联动*)
				NOT pstStUnitParam_Save^.xSwitchOn_CoatingPrn THEN(*非涂布色组*)
				iIndex:=iIndex+1;
				ailist[iIndex]:=iAxisId;
			END_IF
		END_IF
	END_FOR

	FOR iN:=1 TO iIndex BY 1 DO
		iAxisId:=ailist[iN];
		pstStUnitParam_UnSave:=ADR(i_pastStUnitParam_UnSave^[iAxisId]);
		i_palrRelatePos^[iAxisId]:=pstStUnitParam_UnSave^.lrPrf_Pos-pstStUnitParam_Cur_UnSave^.lrPrf_Pos;
		xDne:=TRUE;
	END_FOR
END_IF
KS_GetRelatePos:=xDne;