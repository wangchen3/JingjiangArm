(*@CES
Name=KS_PushRegAdjValue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5b088804-504f-459b-bb64-be78c2ffc3f4
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PushRegAdjValue : INT(* 0:无错误/-1220:参数错误 *)
VAR_INPUT
	i_pastStRegAdjMana: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StRegAdjMana; (* 单元调整量 *)
	i_iUnitId: INT; (* 轴id *)
	i_iAdj_V: INT; (* 纵向调整量 *)
	i_iAdj_H: INT; (* 横向调整量 *)
END_VAR
VAR
	iItemTotalNum: INT; (* 数据总量 *)
	iTmpValue: INT;
END_VAR
{IMPLEMENTATION}
IF i_pastStRegAdjMana<>0 AND (*调整量结构体有效*)
	(i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM) THEN (*轴id有效*)
	iItemTotalNum:= SIZEOF(i_pastStRegAdjMana^[i_iUnitId].aiAdj_V)/SIZEOF(i_pastStRegAdjMana^[i_iUnitId].aiAdj_V[1]);
	IF (i_pastStRegAdjMana^[i_iUnitId].iIdxWr<1 OR i_pastStRegAdjMana^[i_iUnitId].iIdxWr>iItemTotalNum) OR
		(i_pastStRegAdjMana^[i_iUnitId].iIdxRd<1 OR i_pastStRegAdjMana^[i_iUnitId].iIdxRd>iItemTotalNum) THEN
		i_pastStRegAdjMana^[i_iUnitId].iIdxRd:= 1;
		i_pastStRegAdjMana^[i_iUnitId].iIdxWr:= 1;
	END_IF

	i_pastStRegAdjMana^[i_iUnitId].aiAdj_V[i_pastStRegAdjMana^[i_iUnitId].iIdxWr]:= i_iAdj_V; (*写入纵向调整量*)
	i_pastStRegAdjMana^[i_iUnitId].aiAdj_H[i_pastStRegAdjMana^[i_iUnitId].iIdxWr]:= i_iAdj_H; (*写入横向调整量*)

	(*处理下一次要写入数据的位置
	.由于Push和Fetch最终会在两个优先级不同的任务中执行
	.每个函数调用时都会先检查索引是否有效
	.所以为了保证变量的原子态操作
	.所以把+1和判断放在临时变量中操作
	*)
	iTmpValue:= i_pastStRegAdjMana^[i_iUnitId].iIdxWr+1;
	IF iTmpValue>iItemTotalNum THEN
		iTmpValue:= iTmpValue-iItemTotalNum;
	END_IF
	i_pastStRegAdjMana^[i_iUnitId].iIdxWr:= iTmpValue;

	KS_PushRegAdjValue:= 0;
ELSE
	KS_PushRegAdjValue:= -1220;
END_IF