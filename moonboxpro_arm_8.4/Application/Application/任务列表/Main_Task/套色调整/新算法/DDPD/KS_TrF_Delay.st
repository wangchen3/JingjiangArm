(*@CES
Name=KS_TrF_Delay
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c788a2ce-61f3-4a2d-905d-cbc53a4319a9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TrF_Delay : REAL
(*传递函数e^(-sTL)*)
VAR_INPUT
	i_rU:REAL;(*控制器输入*)
	i_iN:INT;(*时延拍数N=TL/Ts+1*)
	i_prDelay:POINTER TO ARRAY [1..ARC_DELAY_N_MAX_DDPD] OF REAL;(*输入寄存器*)
	i_prYDelay: POINTER TO REAL;(*控制器输出*)
END_VAR
VAR
END_VAR
{IMPLEMENTATION}
IF i_prDelay<>0 THEN
	IF i_iN>ARC_DELAY_N_MAX_DDPD THEN
		i_iN:=ARC_DELAY_N_MAX_DDPD;
	END_IF
	(*差分计算*)
	i_prDelay^[1]:=i_rU;
	i_prYDelay^:=i_prDelay^[i_iN];
END_IF