(*@CES
Name=KS_ClearRapidAdjValue_V
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1935351e-c560-4435-95d2-225c7524606b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ClearRapidAdjValue_V : INT(* 0:无错误/-1220:参数错误 *)
VAR_INPUT
	i_pastStAxisRapidAdjProf_V: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_V; (* 纵向快速对版 *)
	i_iUnitId: INT; (* 轴id *)
END_VAR
VAR
	iN: INT;
END_VAR

{IMPLEMENTATION}
IF i_pastStAxisRapidAdjProf_V<>0 AND
	i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM THEN
	i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxRd:= 1;
	i_pastStAxisRapidAdjProf_V^[i_iUnitId].iIdxWr:= 1;
	FOR iN:= 1 TO MAX_UNIT_NUM BY 1 DO
		i_pastStAxisRapidAdjProf_V^[i_iUnitId].adiAdjustment[iN]:= 0;
	END_FOR

ELSE
	KS_ClearRapidAdjValue_V:= -1220;
END_IF

KS_ClearRapidAdjValue_V:= 0;