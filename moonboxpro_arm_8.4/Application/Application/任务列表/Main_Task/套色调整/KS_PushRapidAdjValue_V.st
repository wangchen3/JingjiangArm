(*@CES
Name=KS_PushRapidAdjValue_V
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=78c765c0-3731-4952-bfd4-57dc02a59b2a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PushRapidAdjValue_V : INT(*0:无错误; -1220:参数错误|*)
VAR
	iResult: INT;
	iTempIndex: INT;
	iItemTotalNum: INT;
END_VAR
VAR_INPUT
	i_pastStAxisRapidAdjProf_V: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_V; (* 纵向快速对版| *)
	i_iUnitId: INT; (* 轴id| *)
	i_diValue: DINT; (* 提交的数据 *)
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pastStAxisRapidAdjProf_V<>0 AND
	i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM AND
	i_diValue<>0 THEN

	(*先算出最大容量|*)
	iItemTotalNum:= SIZEOF(i_pastStAxisRapidAdjProf_V^[i_iUnitId].adiAdjustment)/SIZEOF(i_pastStAxisRapidAdjProf_V^[i_iUnitId].adiAdjustment[1]);

	(*如果索引超限|默认清空从头开始|*)
	IF i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxRd<1 OR(*读索引超限|*)
		i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxRd>iItemTotalNum OR
		i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxWr<1 OR(*写索引超限|*)
		i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxWr>iItemTotalNum THEN
		i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxRd:= 1;
		i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxWr:= 1;
	END_IF

	(*写入新值|*)
	i_pastStAxisRapidAdjProf_V^[i_iUnitId].adiAdjustment[i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxWr]:= i_diValue;

	(*定位到下次写入位置|*)
	iTempIndex:= i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxWr+1;
	IF iTempIndex>iItemTotalNum THEN
		iTempIndex:= iTempIndex-iItemTotalNum;
	END_IF
	i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxWr:= iTempIndex;
ELSE
	iResult:= -1220;
END_IF

KS_PushRapidAdjValue_V:= iResult;