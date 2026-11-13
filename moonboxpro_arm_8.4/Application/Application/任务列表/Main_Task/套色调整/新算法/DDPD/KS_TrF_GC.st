(*@CES
Name=KS_TrF_GC
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a05e9bd4-1c9f-45ee-8234-5e8d434ebf8f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TrF_GC : REAL
(*传递函数GC*)
VAR_INPUT
	i_rU:REAL;(*输入*)
	i_rA:ARRAY [1..2] OF REAL;(*系统参数a*)
	i_rB:ARRAY [1..2] OF REAL;(*系统参数b*)
	i_rN: INT;(*延时拍数*)
	i_rTs:REAL;(*采样时间*)
	i_parTrF_UGrp_C: POINTER TO ARRAY [1..2] OF REAL;(*GC输入函数寄存器*)
	i_parTrF_UC_G2: POINTER TO ARRAY [1..2] OF REAL;(*G2输入函数寄存器*)
	i_parTrF_YGrp_C: POINTER TO ARRAY [1..2] OF REAL;(*GC输出函数寄存器*)
	i_parTrF_YC_G2: POINTER TO ARRAY [1..2] OF REAL;(*G2输出函数寄存器*)
END_VAR
VAR
	rTemp:REAL:=0;
	rabTemp:REAL:=0;
END_VAR
{IMPLEMENTATION}
IF i_parTrF_UGrp_C<>0 AND  i_parTrF_UC_G2<>0
	AND i_parTrF_YGrp_C<>0  AND i_parTrF_YC_G2<>0THEN
	i_parTrF_UGrp_C^[1]:=i_rU;
	rabTemp:=i_rA[2]*i_rB[1];
	KS_TrF_G2(i_rU,i_rTs,rabTemp,i_rA[1],i_parTrF_UC_G2,i_parTrF_YC_G2);
	rTemp:=i_parTrF_YC_G2^[1]-i_rB[2]*i_rU;
	i_parTrF_YGrp_C^[1]:=rTemp;
END_IF