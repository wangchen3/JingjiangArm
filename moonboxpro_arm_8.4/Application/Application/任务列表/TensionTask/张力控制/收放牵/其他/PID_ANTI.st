(*@CES
Name=PID_ANTI
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ddf7a214-0c45-4257-a0f0-8ae2d0e2601d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION PID_ANTI : BOOL
VAR_INPUT
(*输入输出*)
	i_rU:REAL;(*控制器输入*)
	i_prYout: POINTER TO REAL;(*控制器输出@绝对值输出*)
(*PID参数*)
	i_rP:REAL;
	i_rI:REAL;
	i_rD:REAL;
	i_rN:REAL;
	i_rTs:REAL;(*s*)
(*积分抗饱和*)
	i_rLim:REAL;(*控制器输出限幅*)
	i_rAntiWindup:REAL;(*抗积分饱和系数@0-->1*)
(*寄存器*)
	i_prYI: POINTER TO REAL;(*积分控制输出寄存器*)
	i_prYD: POINTER TO REAL;(*微分控制输出寄存器*)
	i_parEk:POINTER TO ARRAY [1..2] OF REAL;(*误差寄存器 [e(k);e(k-1)]*)
END_VAR
VAR
	rP:REAL;(*比例部分*)
	rI:REAL;(*积分部分*)
	rD:REAL:=0;(*微分部分*)

	rUnsat:REAL;(*未限幅输出*)
	rTs:REAL:=0;

END_VAR
{IMPLEMENTATION}
(*计算采样时间*)
rTs := i_rTs;

(*误差寄存器更新*)
i_parEk^[2] := i_parEk^[1];
i_parEk^[1] := i_rU;

(*计算比例部分*)
rP := i_rP*i_rU;

(*计算积分部分*)
rI := i_prYI^ + i_rI*i_rU*rTs;
(*计算微分*)
rD := i_prYD^ * (1.0 - i_rN * rTs) + i_rD * i_rN * (i_parEk^[1] - i_parEk^[2]);

(*计算未限幅输出*)
rUnsat := rP + rI + rD;

(*抗积分饱和*)
IF rUnsat>i_rLim THEN
	i_prYout^ := i_rLim;
	rI:=rI - i_rAntiWindup*(rUnsat - i_rLim);
ELSIF rUnsat < -i_rLim THEN
	i_prYout^ := -i_rLim;
	rI:=rI - i_rAntiWindup*(rUnsat + i_rLim);
ELSE
	i_prYout^ := rUnsat;
END_IF

(*寄存器更新*)
i_prYI^ := rI;
i_prYD^ := rD;