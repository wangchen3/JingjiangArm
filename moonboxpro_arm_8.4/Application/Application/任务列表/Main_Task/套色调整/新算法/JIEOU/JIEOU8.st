(*@CES
Name=JIEOU8
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=cb531a50-6479-4a30-ae73-c8a7aeed7012
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION JIEOU8 : REAL
VAR_INPUT
	i_rPI2:REAL;(*PI2经过JIEOU6 Gc2Yk_K4的输出/Gc2Uk_K5_K6输入*)
	i_rJIEOU3:REAL;(*U3经过JIEOU6 Gc2Yk_K3的输出/Gc2Uk_K5输入*)
	i_rJIEOU4:REAL;(*U4经过JIEOU7 Gc2Yk_K3的输出*)
	i_rJIEOU5:REAL;(*U5经过JIEOU7 Gc2_1的输出*)
	i_rJIEOU6:REAL;(*U6输出*)
	i_rJIEOU7:REAL;(*U7输出*)
	i_rPI8:REAL;(*PI8输出*)

	i_prU8: POINTER TO REAL;(*解耦后控制器8输出*)

(*
	i_rL:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
*)
	i_rTs:REAL;(*2024.6.29.135040修改为了输入@s*)
	i_rA:REAL;(*系统参数A*)
(*Gc1_1寄存器*)
	i_prGc1_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc1_1输入寄存器*)
	i_prGc1_1_Gc1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc1_1 Gc1输出寄存器*)
(*Gc2_1寄存器*)
	i_prGc2_1_Uk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*Gc2_1输入寄存器*)
	i_prGc2_1_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1输出寄存器*)

	i_prGc2_1_Gc1_Uk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc1输入寄存器*)
	i_prGc2_1_Gc2_Yk:POINTER TO ARRAY [1..2] OF REAL;(*Gc2_1 Gc2输出寄存器*)

(*Gc2寄存器3*)
	i_prGc2Uk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输入寄存器2*)
	i_prGc2Yk_K5:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器2*)

(*Gc2寄存器1*)
	i_prGc2Uk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输入寄存器1*)
	i_prGc2Yk_K4:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器1*)
(*Gc2寄存器2*)
	i_prGc2Uk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输入寄存器2*)
	i_prGc2Yk_K3:POINTER TO ARRAY [1..2] OF REAL;(*Gc2输出寄存器2*)

(*控制参数*)
	i_iN:INT;(*时延拍数N=TL/Ts+1*)
	i_bEn:BOOL;(*解耦使能 1：开解耦*)
	i_bK3:BOOL;(*K3=1时前三解耦*)
	i_bK4:BOOL;(*K4=1时前四解耦*)
	i_bK5:BOOL;(*K5=1时前五解耦*)
	i_bK6:BOOL;(*K6=1时前六解耦*)
END_VAR
VAR
(*	rTs:REAL:=0;(*采样时间*)   *)
	iI: INT:=0;

	(*中间变量*)
	rTemp5:REAL:=0;(*Gc2_K5输入*)
	rTemp6:REAL:=0;(*Gc2_K5输出*)

	rTemp7:REAL:=0;(*PI2+JIEOU3+JIEOU4输出*)

	(*中间变量*)
	rTemp1:REAL:=0;(*Gc2_K4输入*)
	rTemp2:REAL:=0;(*Gc2_K4输出*)
	(*中间变量*)
	rTemp3:REAL:=0;(*Gc2_K3输入*)
	rTemp4:REAL:=0;(*Gc2_K3输出*)

	rTempz:REAL:=0;(*总输出*)
	rGc1_1Out:REAL:=0;(*rGcd1_1控制器输出*)
	rGc2_1Out:REAL:=0;(*rGcd2_1控制器输出*)
END_VAR
{IMPLEMENTATION}
Gc2(rTemp1,ADR(rTemp2),i_rTs,i_rA,i_prGc2Uk_K4,i_prGc2Yk_K4);
Gc2(rTemp3,ADR(rTemp4),i_rTs,i_rA,i_prGc2Uk_K3,i_prGc2Yk_K3);

IF i_bK4=0 THEN
	rTemp2:=0;
	i_prGc2Yk_K4^[1]:=rTemp2;
END_IF

IF i_bK3=0 THEN
	rTemp4:=0;
	i_prGc2Yk_K3^[1]:=rTemp4;
END_IF


Gcd1_1(i_rJIEOU7,ADR(rGc1_1Out),i_rTs,i_rA,i_prGc1_1_Uk,i_prGc1_1_Gc1_Yk,i_iN,i_bEn);

Gcd2_1(i_rJIEOU6,ADR(rGc2_1Out),i_rTs,i_rA,i_prGc2_1_Uk,i_prGc2_1_Yk,i_prGc2_1_Gc1_Uk,i_prGc2_1_Gc2_Yk,i_iN,i_bEn);

rTempz:=rGc1_1Out+rGc2_1Out+i_rPI8+rTemp2+rTemp4;


(*输出*)
IF i_bEn<>0 THEN
	i_prU8^:=rTempz;
ELSE
	i_prU8^:=i_rPI8;
END_IF