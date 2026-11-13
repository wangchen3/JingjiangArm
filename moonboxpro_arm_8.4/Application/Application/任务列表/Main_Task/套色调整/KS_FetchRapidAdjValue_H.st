(*@CES
Name=KS_FetchRapidAdjValue_H
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=78ca29e0-c0c8-4d49-891a-0d1322be4c96
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FetchRapidAdjValue_H : int
VAR_INPUT
	i_pastStAxisRapidAdjProf_H: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H; (* 纵向快速对版| *)
	i_iUnitId: INT; (* 轴id| *)
	i_piValue: POINTER TO INT; (* 该轴对应的快速调版量| *)
END_VAR
VAR
	iResult: INT;
	iTempIndex: INT;
	iItemTotalNum: INT;
	iTemp: INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pastStAxisRapidAdjProf_H<>0 AND
	i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM AND
	i_piValue<>0 THEN

	(*最大索引容量|*)
	iItemTotalNum:= SIZEOF(i_pastStAxisRapidAdjProf_H^[i_iUnitId].aiAdjustment)/SIZEOF(i_pastStAxisRapidAdjProf_H^[i_iUnitId].aiAdjustment[1]);

	IF i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd<1 OR
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd>iItemTotalNum OR
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr<1 OR
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr>iItemTotalNum THEN
		(*如果索引异常就全部清空不处理|*)
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd:= 1;
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr:= 1;
		iResult:= 1220;
	ELSIF i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd<>i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr THEN
		(*有数据需要读取|*)
		(*写入出口位置|*)
		i_piValue^:= i_pastStAxisRapidAdjProf_H^[i_iUnitId].aiAdjustment[i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd];

		(*下次读取的位置|*)
		iTempIndex:= i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd+1;
		IF iTempIndex>iItemTotalNum THEN
			iTempIndex:= iTempIndex-iItemTotalNum;
		END_IF
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd:= iTempIndex;
	ELSE
		(*没有新数据|*)
		iResult:= 1221;
	END_IF
ELSE
	iResult:= -1220;
END_IF

KS_FetchRapidAdjValue_H:= iResult;