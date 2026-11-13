(*@CES
Name=KS_JudgeAxisIdValid
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1af44d02-7d75-4756-b34e-b0dfd1fbad7b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_JudgeAxisIdValid :BOOL(*判断轴id是否存在于轴列表中*)
VAR_INPUT
	i_iAxisId:INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴列表|有排序规则|*)
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	xValid: BOOL;
END_VAR
{IMPLEMENTATION}
IF i_paiGrpAxisList<>0 THEN
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iAxisId:=i_paiGrpAxisList^[iN];
		IF i_iAxisId=iAxisId THEN
			xValid:=TRUE;
			EXIT;
		END_IF
	END_FOR
END_IF
KS_JudgeAxisIdValid:=xValid;