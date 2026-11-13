(*@CES
Name=KS_ClearRapidAdjValue_H
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=03f16b2d-6a59-44a0-871c-7df53a0c4716
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ClearRapidAdjValue_H : INT(* 0:无错误/-1220:参数错误 *)
VAR_INPUT
	i_pastStAxisRapidAdjProf_H: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H; (* 纵向快速对版 *)
	i_iUnitId: INT; (* 轴id *)
END_VAR
VAR
	iN: INT;
END_VAR

{IMPLEMENTATION}
IF i_pastStAxisRapidAdjProf_H<>0 AND
	i_iUnitId>=1 AND i_iUnitId<=MAX_UNIT_NUM THEN
	i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxRd:= 1;
	i_pastStAxisRapidAdjProf_H^[i_iUnitId].iIdxWr:= 1;
	FOR iN:= 1 TO MAX_UNIT_NUM BY 1 DO
		i_pastStAxisRapidAdjProf_H^[i_iUnitId].aiAdjustment[iN]:= 0;
	END_FOR

ELSE
	KS_ClearRapidAdjValue_H:= -1220;
END_IF

KS_ClearRapidAdjValue_H:= 0;