(*@CES
Name=KS_GetPidParam
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5147df87-2533-411e-aab0-b9dfa23e86ce
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetPidParam : BOOL
(*2024.7.26.143250 重新调整*)
VAR_INPUT
	i_byFilmType: BYTE;
	i_byParamIndex: BYTE;
	(*以前的pid接口*)
	i_rKp_Hmi:REAL;
	i_rKi_Hmi:REAL;
	i_rKd_Hmi:REAL;
	i_rN_Hmi:REAL;

	(*模型输出的pid*)
	rKp_MolCal:REAL;
	rKi_MolCal:REAL;

	i_prKp: POINTER TO REAL;
	i_prKI: POINTER TO REAL;
	i_prKD: POINTER TO REAL;
	i_prN: POINTER TO REAL;
END_VAR
VAR
	rKp: REAL;
	rKI: REAL;
	rKD: REAL;
	rN: REAL;
END_VAR
{IMPLEMENTATION}
IF i_byParamIndex=1 THEN
	rKp:=16(*35*);
	rKI:=15(*2*);
	rKD:=0;
	rN:=0;
ELSIF i_byParamIndex=2 THEN
	rKp:=15.4634;
	rKI:=11.5601;
	rKD:=0;
	rN:=0;
ELSIF i_byParamIndex=3 THEN
	rKp:=17.3284;
	rKI:=6.0885;
	rKD:=0;
	rN:=0;
ELSIF i_byParamIndex=4 THEN
	rKp:=30;
	rKI:=0.3;
	rKD:=0;
	rN:=0;
ELSIF i_byParamIndex=9 THEN(*第9个参数作为模型pid*)
	rKp:=rKp_MolCal;
	rKI:=rKi_MolCal;
	rKD:=0;
	rN:=0;
ELSIF i_byParamIndex=10 THEN(*第10个参数作为手动输入的选择*)
	rKp:=i_rKp_Hmi;
	rKI:=i_rKi_Hmi;
	rKD:=i_rKd_Hmi;
	rN:=i_rN_Hmi;
ELSE
	rKp:=14.4215;
	rKI:=8.2591;
	rKD:=0;
	rN:=0;
END_IF

(*输出*)
IF i_prKp<>0 THEN
	i_prKp^:=rKp;
END_IF
IF i_prKI<>0 THEN
	i_prKI^:=rKI;
END_IF
IF i_prKd<>0 THEN
	i_prKd^:=rKD;
END_IF
IF i_prN<>0 THEN
	i_prN^:=rN;
END_IF