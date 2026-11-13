(*@CES
Name=JIEOU4
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1946c078-7c38-40e6-bd29-bc69214024d3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION JIEOU4 : REAL
VAR_INPUT

	i_rPI2:REAL;(*PI2输出*)
	i_rJIEOU3:REAL;(*U3输出*)
	i_rPI4:REAL;(*PI4输出*)

	i_prU4: POINTER TO REAL;(*解耦后控制器4输出*)

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

	i_iN:INT;(*时延拍数N=TL/Ts+1*)
	i_bEn:BOOL;(*解耦使能 1：开解耦*)
END_VAR

VAR
(*	rTs:REAL:=0;(*采样时间*)   *)
	iI: INT:=0;

	(*中间变量*)
	rTemp1:REAL:=0;(*总输出*)
	rGc1_1Out:REAL:=0;(*rGcd1_1控制器输出*)
	rGc2_1Out:REAL:=0;(*rGcd2_1控制器输出*)
END_VAR
{IMPLEMENTATION}
(*
(*更新寄存器*)
(*Gc1_1*)
i_prGc1_1_Gc1_Yk^[2]:=i_prGc1_1_Gc1_Yk^[1];

FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prGc1_1_Uk^[i_iN-iI]:=i_prGc1_1_Uk^[i_iN-iI-1];
END_FOR

(*Gc2_1*)
i_prGc2_1_Gc1_Uk^[2]:=i_prGc2_1_Gc1_Uk^[1];

i_prGc2_1_Gc2_Yk^[2]:=i_prGc2_1_Gc2_Yk^[1];

i_prGc2_1_Yk^[2]:=i_prGc2_1_Yk^[1];

FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prGc2_1_Uk^[i_iN-iI]:=i_prGc2_1_Uk^[i_iN-iI-1];
END_FOR
*)


(*计算*)
Gcd1_1(i_rJIEOU3,ADR(rGc1_1Out),i_rTs,i_rA,i_prGc1_1_Uk,i_prGc1_1_Gc1_Yk,i_iN,i_bEn);
Gcd2_1(i_rPI2,ADR(rGc2_1Out),i_rTs,i_rA,i_prGc2_1_Uk,i_prGc2_1_Yk,i_prGc2_1_Gc1_Uk,i_prGc2_1_Gc2_Yk,i_iN,i_bEn);
rTemp1:=rGc1_1Out+i_rPI4+rGc2_1Out;


(*输出*)
IF i_bEn<>0 THEN
	i_prU4^:=rTemp1;
ELSE
	i_prU4^:=i_rPI4;
END_IF