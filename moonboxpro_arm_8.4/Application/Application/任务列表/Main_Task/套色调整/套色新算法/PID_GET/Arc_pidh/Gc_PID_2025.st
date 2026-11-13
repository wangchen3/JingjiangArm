(*@CES
Name=Gc_PID_2025
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=460d2dc5-80dd-4599-9edb-64334fe92a43
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Gc_PID_2025 : REAL
(*2025.1.15.095113@增加误差阈值,超过该值按照最大值输出。范围内按照pi控制器输出*)
VAR_INPUT
	i_rTs:REAL;(*采样周期*)
	i_rP:REAL;
	i_rI:REAL;
	i_rD:REAL;
	i_rN:REAL;
	i_rU:REAL;(*控制器输入*)
	i_prYout: POINTER TO REAL;(*控制器输出*)

	i_parEk:POINTER TO ARRAY [1..2] OF REAL;(*误差寄存器 [e(k);e(k-1)]*)
	i_parYPk:POINTER TO ARRAY [1..2] OF REAL;(*比例控制输出寄存器*)
	i_parYIk:POINTER TO ARRAY [1..2] OF REAL;(*积分控制输出寄存器*)
	i_parYDk:POINTER TO ARRAY [1..2] OF REAL;(*微分控制输出寄存器*)
	i_parYPIDk:POINTER TO ARRAY [1..2] OF REAL;(*PID控制器输出寄存器*)
END_VAR

VAR
	rP:REAL:=20.0;
	rI:REAL:=8.0;
	rD:REAL:=0;
	rN:REAL:=0;
	rTs:REAL:=0;
END_VAR
{IMPLEMENTATION}
rTs:=i_rTs;

rP:=i_rP;
rI:=i_rI;
rD:=i_rD;
rN:=i_rN;

(*先按照d不等于0的时候rN=1*)
IF rD=0 THEN
	rN:=0;
ELSE
	rN:=1;
END_IF

(*差分计算*)
i_parEk^[1]:=i_rU;

(*超过阈值按照最大值输出*)
(*比例*)
i_parYPk^[1]:=rP*i_parEk^[1];
(*积分*)
i_parYIk^[1]:=i_parYIk^[2]+rI*rTs*i_parEk^[2];
(*微分*)
i_parYDk^[1]:=i_parYDk^[2]*(1.0-rN*rTs)+rD*rN*(i_parEk^[1]-i_parEk^[2]);
(*总输出*)
i_parYPIDk^[1]:=i_parYPk^[1]+i_parYIk^[1]+i_parYDk^[1];(*上面pi的输出*)


(*更新寄存器的值-注意顺序*)
i_parEk^[2]:=i_parEk^[1];
i_parYPk^[2]:=i_parYPk^[1];(*2024.04.08.110707+*)
i_parYIk^[2]:=i_parYIk^[1];
i_parYDk^[2]:=i_parYDk^[1];
i_parYPIDk^[2]:=i_parYPIDk^[1];

i_prYout^:=i_parYPIDk^[1];