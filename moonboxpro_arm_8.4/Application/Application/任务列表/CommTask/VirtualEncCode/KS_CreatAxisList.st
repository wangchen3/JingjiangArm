(*@CES
Name=KS_CreatAxisList
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=cc6a2af8-1f48-4f64-9956-cd9d69d9f4f7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CreatAxisList : INT(*创建轴列表|由于韩工生成的轴列表有可能存在牵引使用变频而列表包含了收放牵,
								只要保证收放牵的站id为-1就可以剔除掉
								做此函数进行检查保证最后的列表中的轴和站一一对应|
								返回值为列表总数*)
VAR_INPUT
	i_iGrpAxisTotalNum: INT;(*含牵引在的所有轴数量|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_STATION_NUM] OF INT;(*轴列表|有排序规则|*)
	i_pstStSysParam: POINTER TO StSysParam;(*系统参数*)
	i_paiGrpAxisList_Valid: POINTER TO ARRAY [1..MAX_STATION_NUM] OF INT;(*轴列表|有排序规则|站也同时存在*)
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	iStationId: INT;
	iIndex: INT;
END_VAR

{IMPLEMENTATION}
iIndex:=0;
IF i_paiGrpAxisList<>0 AND
	i_paiGrpAxisList_Valid<>0 AND
	i_pstStSysParam<>0 THEN
	(*初始化新列表*)
	FOR iN:=1 TO MAX_STATION_NUM BY 1 DO
		i_paiGrpAxisList_Valid^[iN]:=-1;
	END_FOR

	FOR iN:=1 TO i_iGrpAxisTotalNum BY 1 DO
		iAxisId:=i_paiGrpAxisList^[iN];
		IF iAxisId>=1 AND iAxisId<=MAX_STATION_NUM THEN
			iStationId:=i_pstStSysParam^.astStUnitParam_Save[iAxisId].iStationId;
			(*重新生成列表*)
			IF iStationId<>-1 THEN(*站有效*)
				iIndex:=iIndex+1;
				i_paiGrpAxisList_Valid^[iIndex]:=iAxisId;
			END_IF
		END_IF
	END_FOR
END_IF
KS_CreatAxisList:=iIndex;