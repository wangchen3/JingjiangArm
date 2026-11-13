(*@CES
Name=KS_TrF_GB
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f024bf9d-3c63-4978-8db4-4bae8b7ab550
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TrF_GB : REAL
(*传递函数GB*)
VAR_INPUT
	i_rU:REAL;(*输入*)
	i_rA:ARRAY [1..2] OF REAL;(*系统参数a*)
	i_rB: REAL;(*系统参数b*)
	i_rN: INT;(*延时拍数*)
	i_rTs:REAL;(*采样时间*)
	i_parTrF_UGrp_B: POINTER TO ARRAY [1..2] OF REAL;(*GB输入函数寄存器*)
	i_parTrF_UB_G1: POINTER TO ARRAY [1..2] OF REAL;(*G1输入函数寄存器*)
	i_parTrF_UB_G2: POINTER TO ARRAY [1..2] OF REAL;(*G2输入函数寄存器*)
	i_parTrF_YGrp_B: POINTER TO ARRAY [1..2] OF REAL;(*GB输出函数寄存器*)
	i_parTrF_YB_G1: POINTER TO ARRAY [1..2] OF REAL;(*G1输出函数寄存器*)
	i_parTrF_YB_G2: POINTER TO ARRAY [1..2] OF REAL;(*G2输出函数寄存器*)
	i_parTrF_BDelay: POINTER TO ARRAY [1..ARC_DELAY_N_MAX_DDPD] OF REAL;(*Delay函数寄存器*)
END_VAR
VAR
	rTemp:REAL:=0;
	rDelayTemp:REAL:=0;
END_VAR
{IMPLEMENTATION}
IF i_parTrF_UGrp_B<>0 AND i_parTrF_UB_G1<>0 AND i_parTrF_UB_G2<>0
	AND i_parTrF_YGrp_B<>0AND i_parTrF_YB_G1<>0 AND i_parTrF_YB_G2 <>0
	AND i_parTrF_BDelay<>0 THEN
	i_parTrF_UGrp_B^[1]:=i_rU;
	KS_TrF_G1(i_rU,i_rTs,i_rA[2],i_rA[1],i_parTrF_UB_G1,i_parTrF_YB_G1);
	KS_TrF_G2(i_rU,i_rTs,i_rA[2],i_rA[1],i_parTrF_UB_G2,i_parTrF_YB_G2);
	KS_TrF_Delay(i_parTrF_YB_G1^[1],i_rN,i_parTrF_BDelay,ADR(rDelayTemp));
	rTemp:=(rDelayTemp-i_parTrF_YB_G2^[1])*1.0/i_rB;
	i_parTrF_YGrp_B^[1]:=rTemp;
END_IF