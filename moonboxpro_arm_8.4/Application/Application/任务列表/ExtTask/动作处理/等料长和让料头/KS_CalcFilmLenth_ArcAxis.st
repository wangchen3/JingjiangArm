(*@CES
Name=KS_CalcFilmLenth_ArcAxis
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=255b5e66-4618-45f5-bc39-000f4174c998
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcFilmLenth_ArcAxis : BOOL(*计算套色轴之间的料长@2024.7.30.174149*)
(*2025.1.4.112408 调整合压信号输入*)
VAR_INPUT
	(*调整接口@使用实际合压完成标志|2025.1.4.111522*)
	i_iGrpId: INT; (*系id*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*实际压辊完成标志*)
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	iPrevAxisId: INT;
	rLenth: REAL;
END_VAR


{IMPLEMENTATION}


IF i_pstStSysParam<>0 AND
	i_paxFlag_PressDne<>0 THEN
	(*清零*)
	
	FOR iN:=1 TO i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byGrpAxisNum_Pu BY 1 DO
		iAxisId:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyGrpAxisList[iN];
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN
			i_pstStSysParam^.astStUnitParam_Save[iAxisId].rFilmLengthFromPrevPressUnit:=0;
		END_IF
	END_FOR

	(*从2色开始计算*)
	FOR iN:=2 TO i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byGrpArcAxisNum BY 1 DO
		iAxisId:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyGrpArcAxisList[iN];
		iPrevAxisId:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyGrpArcAxisList[iN-1];
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM AND
			iPrevAxisId>0 AND iPrevAxisId<=MAX_UNIT_NUM THEN
			rLenth:=
				KS_CalcFilmLenth_Unit(
					iPrevAxisId(*i_iAxisId_1*),
					iAxisId(*i_iAxisId_2*),
					i_paxFlag_PressDne(*i_paxFlag_PressDne*),
					i_pstStSysParam(*i_pastStAxisParam*),
					0(*i_prFilmLenthWhenCurUnitPressDn*));
			i_pstStSysParam^.astStUnitParam_Save[iAxisId].rFilmLengthFromPrevPressUnit:=rLenth;
		END_IF
	END_FOR
END_IF