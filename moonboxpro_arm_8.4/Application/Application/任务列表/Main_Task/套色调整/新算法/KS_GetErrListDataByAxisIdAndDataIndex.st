(*@CES
Name=KS_GetErrListDataByAxisIdAndDataIndex
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ce9d4482-1047-49bb-908b-7d18aa84a12d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetErrListDataByAxisIdAndDataIndex : INT (* 读取指定轴指定幅的误差数据 *)
VAR_INPUT
	i_pastStForArcErrRelay: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StForArcErrRelay; (* 误差队列 *)
	i_iAxisId: INT; (* 轴id *)
	i_iDataIndex: INT; (* 误差位置索引 *)
END_VAR
VAR
	iN: INT;
	iResult: INT;
	iTotalItems: INT;
	pstStForArcErrRelay: POINTER TO StForArcErrRelay;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_pastStForArcErrRelay<>0 AND
	i_iAxisId>=1 AND i_iAxisId<=MAX_UNIT_NUM THEN
	pstStForArcErrRelay:= ADR(i_pastStForArcErrRelay^[i_iAxisId]);
	iTotalItems:= DWORD_TO_INT(SIZEOF(pstStForArcErrRelay^.aiErrDataList)/SIZEOF(pstStForArcErrRelay^.aiErrDataList[1])); (* 算出数组的元素最大数量 *)
	IF i_iDataIndex>=1 AND i_iDataIndex<=iTotalItems THEN
		iResult:= pstStForArcErrRelay^.aiErrDataList[i_iDataIndex];
	END_IF
END_IF
KS_GetErrListDataByAxisIdAndDataIndex:= iResult;