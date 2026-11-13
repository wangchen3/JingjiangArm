(*@CES
Name=KS_ClearRegAdjValue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=35f4f50d-9372-488d-a3f0-1c615a8e6e33
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ClearRegAdjValue : INT(* 0:无错误/-1220:参数错误 *)
VAR_INPUT
	i_pastStRegAdjMana: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StRegAdjMana; (* 单元调整量 *)
	i_iUnitId: INT; (* 轴id *)
END_VAR
VAR
	iN: INT;
END_VAR
{IMPLEMENTATION}
IF i_pastStRegAdjMana<>0 AND (*调整量结构体有效*)
	(i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM) THEN (*轴id有效*)
	i_pastStRegAdjMana^[i_iUnitId].iIdxWr:= 1;
	i_pastStRegAdjMana^[i_iUnitId].iIdxRd:= 1;
	FOR iN:=1 TO GC_PU_MAX_NUM BY 1 DO
		i_pastStRegAdjMana^[i_iUnitId].aiAdj_V[iN]:= 0;
		i_pastStRegAdjMana^[i_iUnitId].aiAdj_H[iN]:= 0;
	END_FOR
	KS_ClearRegAdjValue:= 0;
ELSE
	KS_ClearRegAdjValue:= -1220;
END_IF