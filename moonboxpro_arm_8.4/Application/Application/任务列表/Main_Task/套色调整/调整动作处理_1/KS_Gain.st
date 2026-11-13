(*@CES
Name=KS_Gain
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=345e867e-ed89-44e2-aba6-0ffbaf4285c0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Gain : REAL
(*返回增益值*)
VAR_INPUT
	i_rValue:REAL;
	i_rGain:REAL;
END_VAR
VAR
	rGain: REAL;
END_VAR
{IMPLEMENTATION}
rGain:=i_rGain*i_rValue;

KS_Gain:=rGain;