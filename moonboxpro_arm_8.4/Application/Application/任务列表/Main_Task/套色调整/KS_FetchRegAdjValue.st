(*@CES
Name=KS_FetchRegAdjValue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1dd2d585-55d6-4e53-9602-3ae775b26755
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FetchRegAdjValue : INT (* -1220:参数无效/1220:操作指针无效(并作复位处理)/0:无错误 *)
VAR_INPUT
	i_pastStRegAdjMana: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StRegAdjMana; (* 单元调整量 *)
	i_iUnitId: INT; (* 轴id *)
	i_piAdj_V: POINTER TO INT; (* 用以返回纵向调整量 *)
	i_piAdj_H: POINTER TO INT; (* 用以返回横向调整量 *)
END_VAR
VAR
	iResult: INT;
	iItemTotalNum: INT; (* 数据总量 *)
	iTmpValue: INT;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_pastStRegAdjMana<>0 AND (*调整量结构体有效*)
	(i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM) AND (*轴id有效*)
	(i_piAdj_V<>0 AND i_piAdj_H<>0) THEN (*返回地址有效*)
	iItemTotalNum:= SIZEOF(i_pastStRegAdjMana^[i_iUnitId].aiAdj_V)/SIZEOF(i_pastStRegAdjMana^[i_iUnitId].aiAdj_V[1]);
	IF (i_pastStRegAdjMana^[i_iUnitId].iIdxWr<1 OR i_pastStRegAdjMana^[i_iUnitId].iIdxWr>iItemTotalNum) OR
		(i_pastStRegAdjMana^[i_iUnitId].iIdxRd<1 OR i_pastStRegAdjMana^[i_iUnitId].iIdxRd>iItemTotalNum) THEN
		(*索引无效*)
		i_pastStRegAdjMana^[i_iUnitId].iIdxRd:= 1;
		i_pastStRegAdjMana^[i_iUnitId].iIdxWr:= 1;
		iResult:= 1220;
	ELSIF i_pastStRegAdjMana^[i_iUnitId].iIdxWr<>i_pastStRegAdjMana^[i_iUnitId].iIdxRd THEN
		(*队列不齐*)
		i_piAdj_V^:= i_pastStRegAdjMana^[i_iUnitId].aiAdj_V[i_pastStRegAdjMana^[i_iUnitId].iIdxRd];
		i_piAdj_H^:= i_pastStRegAdjMana^[i_iUnitId].aiAdj_H[i_pastStRegAdjMana^[i_iUnitId].iIdxRd];

		(*定位下次要访问的位置*)
		iTmpValue:= i_pastStRegAdjMana^[i_iUnitId].iIdxRd+1;
		IF iTmpValue>iItemTotalNum THEN
			iTmpValue:= iTmpValue-iItemTotalNum;
		END_IF
		i_pastStRegAdjMana^[i_iUnitId].iIdxRd:= iTmpValue;
	ELSE(*2018.8.21.202154\修复bug\基本可以怀疑是这里的问题了\折腾了好多天|*)
		(*忘记else分支最后造成返回值为默认的0|这样之前的值会被重复使用|造成调整量量增|*)
		iResult:= 1221;
	END_IF
ELSE
	iResult:= -1220;
END_IF

KS_FetchRegAdjValue:= iResult;