(*@CES
Name=LowPass
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d3642d54-f54d-4ba9-a90e-82a081cd60e8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION LowPass : BOOL
(*
	功能：一阶低通滤波器   截止频率1rad/s  
	输入：计算的补偿量
	输出：滤波后补偿量
*)
VAR_INPUT

	i_rInput:REAL;(*摆臂输出模拟量*)
	i_prOutput: POINTER TO REAL;(*控制器输出转速(r/min)-绝对值*)
	i_parUk:POINTER TO ARRAY [1..2] OF REAL;(*输入寄存器 [U(k);U(k-1)]*)
	i_parYk:POINTER TO ARRAY [1..2] OF REAL;(*输出寄存器[Y(k);Y(k-1)]*)

	(*2023.09.27.222339 增加了截止频率的输入设置*)
	i_rWc:REAL;
	i_iCycleTime_Plc: INT;
END_VAR

VAR
	rTs:REAL :=0.02;

	rAp:REAL :=1.0;  (*%通带允许的最大衰减 dB*)
	rWc:REAL :=2.0;  (*%截止频率rad/s,一般取1，(一般放卷系统的截止频率为1rad/s),若补偿效果差，可以加大，若发散，则减小*)

	rE:REAL :=0;
	rA0:REAL :=0;
	rB0:REAL :=0;
	rA1:REAL :=0;
	rB1:REAL :=0;

	rTemp:REAL :=0;
END_VAR
{IMPLEMENTATION}
(*2023.09.27.222448 增加截止频率的赋值*)
rWc:=i_rWc;
IF rWc<=0 THEN
	rWc:=2;
END_IF
rTs:=INT_TO_REAL(i_iCycleTime_Plc)/1000.0;(*2024.12.3.103753 周期通过变量计算*)
(*参数*)
rTemp :=rAp/10.0;
rTemp :=LREAL_TO_REAL(EXPT(10.0,rTemp));
rE :=SQRT(rTemp-1.0);

rA0:=rWc*rTs;
rA1:=rWc*rTs;

rB0 :=rWc*rTs-2.0*rE;
rB1 :=rWc*rTs+2.0*rE;

(*差分计算*)
i_parUk^[1] :=i_rInput;
i_parYk^[1] :=1/rB1*(rA1*i_parUk^[1]+rA0*i_parUk^[2]-rB0*i_parYk^[2]);

(*更新寄存器*)
i_parUk^[2] :=i_parUk^[1];

i_parYk^[2] :=i_parYk^[1];

(*输出*)
i_prOutput^ :=i_parYk^[1];