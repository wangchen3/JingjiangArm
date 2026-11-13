(*@CES
Name=KS_GetMax_MinVlaue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8f6e33c8-95eb-4af2-849c-6572b367cef7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetMax_MinVlaue : INT(*获取最大或者最小值*)
VAR_INPUT
	i_plrMaxValue:POINTER TO LREAL;(*大值*)
	i_plrMinValue:POINTER TO LREAL;(*小值*)
	i_lrValue:LREAL;(*值*)
END_VAR
VAR
END_VAR
{IMPLEMENTATION}
KS_GetMax_MinVlaue:=0;
IF i_plrMaxValue<>0 AND i_plrMinValue<>0 THEN
	IF i_lrValue>i_plrMaxValue^ THEN
		i_plrMaxValue^:=i_lrValue;
	ELSIF i_lrValue<i_plrMinValue^ THEN
		i_plrMinValue^:=i_lrValue;
	ELSE;
	END_IF
ELSE
	KS_GetMax_MinVlaue:=-1;
END_IF