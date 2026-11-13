(*@CES
Name=Tdelay
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b2b05836-3b11-4df7-b306-4e2257244770
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Tdelay : REAL
(*传递函数e^(-sTL)*)
VAR_INPUT

	i_rU:REAL;(*控制器输入*)
	i_prYout: POINTER TO REAL;(*控制器输出*)

	i_iN:INT;(*时延拍数N=TL/Ts+1*)

	i_prUk:POINTER TO ARRAY [1..ARC_DELAY_N_MAX] OF REAL;(*输入寄存器*)
END_VAR

VAR
	iI: INT:=0;
END_VAR
{IMPLEMENTATION}
(*防止数据溢出@2023.11.17.172723*)
IF i_iN>ARC_DELAY_N_MAX THEN
	i_iN:=ARC_DELAY_N_MAX;
END_IF
(*差分计算*)
i_prUk^[1]:=i_rU;

(*输出*)
i_prYout^:=i_prUk^[i_iN];
(*更新寄存器注意顺序*)
(*
FOR iI:=0 TO i_iN-2 BY 1 DO
	i_prUk^[i_iN-iI]:=i_prUk^[i_iN-iI-1];
END_FOR
*)