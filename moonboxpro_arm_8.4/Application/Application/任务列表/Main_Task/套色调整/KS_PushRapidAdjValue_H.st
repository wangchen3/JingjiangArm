(*@CES
Name=KS_PushRapidAdjValue_H
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f4c3ad13-cefe-4439-a936-6639860b4e75
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PushRapidAdjValue_H : INT(*0:无错误; -1220:参数错误|*)
VAR_INPUT
	i_pastStAxisRapidAdjProf_H: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H; (* 纵向快速对版| *)
	i_iUnitId: INT; (* 轴id| *)
	i_iValue: INT; (* 提交的数据 *)
END_VAR
VAR
	iResult: INT;
	iTempIndex: INT;
	iItemTotalNum: INT;
END_VAR


{IMPLEMENTATION}
iResult:= 0;
IF i_pastStAxisRapidAdjProf_H<>0 AND
	i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM AND
	i_iValue<>0 THEN

	(*先算出最大容量|*)
	iItemTotalNum:= SIZEOF(i_pastStAxisRapidAdjProf_H^[i_iUnitId].aiAdjustment)/SIZEOF(i_pastStAxisRapidAdjProf_H^[i_iUnitId].aiAdjustment[1]);

	(*如果索引超限|默认清空从头开始|*)
	IF i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd<1 OR(*读索引超限|*)
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd>iItemTotalNum OR
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr<1 OR(*写索引超限|*)
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr>iItemTotalNum THEN
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd:= 1;
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr:= 1;
	END_IF

	(*写入新值|*)
	i_pastStAxisRapidAdjProf_H^[i_iUnitId].aiAdjustment[i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr]:= i_iValue;

	(*定位到下次写入位置|*)
	iTempIndex:= i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr+1;
	IF iTempIndex>iItemTotalNum THEN
		iTempIndex:= iTempIndex-iItemTotalNum;
	END_IF
	i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr:= iTempIndex;
ELSE
	iResult:= -1220;
END_IF

KS_PushRapidAdjValue_H:= iResult;