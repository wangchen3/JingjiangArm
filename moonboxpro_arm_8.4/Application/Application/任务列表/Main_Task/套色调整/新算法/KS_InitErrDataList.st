(*@CES
Name=KS_InitErrDataList
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=773b0694-f937-4ac6-8a46-830343c4818d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitErrDataList : BOOL (* 初始化误差数据列表区域 *)
VAR_INPUT
	i_pastStForArcErrRelay: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StForArcErrRelay; (* 误差队列 *)
	i_iAxisId: INT; (* 轴id *)
END_VAR
VAR
	iN: INT;
	xResult: BOOL;
	iTotalItems: INT;
	pstStForArcErrRelay: POINTER TO StForArcErrRelay;
END_VAR
{IMPLEMENTATION}
xResult:= FALSE;
IF i_pastStForArcErrRelay<>0 AND
	i_iAxisId>=1 AND i_iAxisId<=MAX_STATION_NUM THEN
	pstStForArcErrRelay:= ADR(i_pastStForArcErrRelay^[i_iAxisId]);
	iTotalItems:= DWORD_TO_INT(SIZEOF(pstStForArcErrRelay^.aiErrDataList)/SIZEOF(pstStForArcErrRelay^.aiErrDataList[1])); (* 算出数组的元素最大数量 *)
	FOR iN:=1 TO iTotalItems BY 1 DO
		pstStForArcErrRelay^.aiErrDataList[iN]:= 0;
	END_FOR
	xResult:= TRUE;
END_IF
KS_InitErrDataList:= xResult;