(*@CES
Name=KS_TrF_GA
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f3222eac-8dde-42f3-9eae-885323aaa6cd
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TrF_GA : REAL
(*传递函数GA*)
VAR_INPUT
	i_rU:REAL;(*输入*)
	i_rA:ARRAY [1..2] OF REAL;(*系统参数a*)
	i_rB:ARRAY [1..2] OF REAL;(*系统参数b*)
	i_rN: INT;(*延时拍数*)
	i_rTs:REAL;(*采样时间*)
	i_parTrF_UGrp_A: POINTER TO ARRAY [1..2] OF REAL;(*GA输入函数寄存器*)
	i_parTrF_UA_G1: POINTER TO ARRAY [1..2] OF REAL;(*G1输入函数寄存器*)
	i_parTrF_UA_G2: POINTER TO ARRAY [1..2] OF REAL;(*G2输入函数寄存器*)
	i_parTrF_YGrp_A: POINTER TO ARRAY [1..2] OF REAL;(*GA输出函数寄存器*)
	i_parTrF_YA_G1: POINTER TO ARRAY [1..2] OF REAL;(*G1输出函数寄存器*)
	i_parTrF_YA_G2: POINTER TO ARRAY [1..2] OF REAL;(*G2输出函数寄存器*)
	i_parTrF_ADelay: POINTER TO ARRAY [1..ARC_DELAY_N_MAX_DDPD] OF REAL;(*Delay函数寄存器*)
END_VAR
VAR
	rTemp:REAL:=0;
	rDelayTemp:REAL:=0;
	ffff:REAL:=0;
END_VAR
{IMPLEMENTATION}
IF i_parTrF_UGrp_A<>0 AND i_parTrF_UA_G1<>0 AND i_parTrF_UA_G2<>0
	AND i_parTrF_YGrp_A<>0 AND i_parTrF_YA_G1<>0 AND i_parTrF_YA_G2<>0
	AND i_parTrF_ADelay<>0 THEN
	i_parTrF_UGrp_A^[1]:=i_rU;
	KS_TrF_G1(i_rU,i_rTs,i_rA[2],i_rA[1],i_parTrF_UA_G1,i_parTrF_YA_G1);
	KS_TrF_G2(i_rU,i_rTs,i_rA[2],i_rA[1],i_parTrF_UA_G2,i_parTrF_YA_G2);
	KS_TrF_Delay(i_parTrF_YA_G1^[1],i_rN,i_parTrF_ADelay,ADR(rDelayTemp));
	ffff:=i_rB[1]/i_rB[2];
	rTemp:=(rDelayTemp-i_parTrF_YA_G2^[1])*(i_rB[1]/i_rB[2])+i_rU;
	i_parTrF_YGrp_A^[1]:=rTemp;
END_IF