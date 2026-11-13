(*@CES
Name=Gcd2_1
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7cf43cab-e1e9-4635-9b71-f6ee2d05867b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Gcd2_1 : REAL
(*传递函数Gcd2,1*)
VAR_INPUT

	i_rU:REAL;(*控制器输入*)
	i_prYout: POINTER TO REAL;(*控制器输出*)

(*
	i_rL:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
*)
	i_rTs:REAL;(*2024.6.29.135040修改为了输入@s*)
	i_rA:REAL;(*系统参数A*)

	i_prUk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器*)
	i_prYk:POINTER TO ARRAY [1..2] OF REAL;(*输出寄存器*)

	i_prGc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1输入内部寄存器*)
	i_prGc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出内部寄存器*)

	i_iN:INT;(*时延拍数N=TL/Ts+1*)
	i_bEn:BOOL;(*解耦使能 1：开解耦*)
END_VAR

VAR
	ra0:REAL:=0;
	rb0:REAL:=0;
	rTs:REAL:=0;(*采样时间*)

	iI: INT:=0;

	(*中间变量*)
	rTemp1:REAL:=0;(*Gc1*)
	rTemp2:REAL:=0;(*Gc2*)
	rTempTdelay:REAL:=0;(*纯时延*)
	rGc2_1Out:REAL:=0;(*rGcd1_1控制器输出*)
END_VAR
{IMPLEMENTATION}
(*计算*)
(*2024.6.29.135355 修改接口*)
(*Gc2(i_rU,ADR(rTemp2),i_rL,i_rV,i_rA,i_prUk,i_prGc2_Yk);(*A/(s+A)*)*)
Gc2(i_rU,ADR(rTemp2),i_rTs,i_rA,i_prUk,i_prGc2_Yk);(*A/(s+A)*)
Tdelay(i_rU,ADR(rTempTdelay),i_iN,i_prUk);
rTemp1:=rTemp2-rTempTdelay;

(*2024.6.29.135355 修改接口*)
(*Gc1(rTemp1,ADR(rGc2_1Out),i_rL,i_rV,i_rA,i_prGc1_Uk,i_prYk);(*s/(s+A)*)*)
Gc1(rTemp1,ADR(rGc2_1Out),i_rTs,i_rA,i_prGc1_Uk,i_prYk);(*s/(s+A)*)


(*输出*)
IF i_bEn<>0 THEN
	i_prYout^:=rGc2_1Out;
ELSE
	i_prYout^:=0;
END_IF