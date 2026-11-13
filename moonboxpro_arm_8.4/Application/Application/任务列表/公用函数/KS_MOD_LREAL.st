(*@CES
Name=KS_MOD_LREAL
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c7df3acb-0909-4f65-9b34-010cacb37200
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_MOD_LREAL : LREAL(*浮点数的取模*)
VAR_INPUT
	i_lrData:LREAL;
	i_rMOD:REAL;
END_VAR
VAR
	iTimes: INT;
	iN: INT;
	lrTemp: LREAL;
END_VAR
{IMPLEMENTATION}
IF i_rMOD<>0 THEN
	iTimes:=LREAL_TO_INT(i_lrData/i_rMOD);
END_IF

lrTemp:=i_lrData-i_rMOD*iTimes;
IF lrTemp<0 THEN
	lrTemp:=lrTemp+i_rMOD;
END_IF
KS_MOD_LREAL:=lrTemp;