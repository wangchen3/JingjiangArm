(*@CES
Name=Periodic
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b9320914-a917-446b-b04f-68c6ab24df80
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Periodic : BOOL
(*自适应滤波器@频率要求特别准确*)
VAR_INPUT
(*输入输出*)
	i_rU:REAL;(*套色误差输入*)
	i_prYout: POINTER TO REAL;(*输出*)
(*
	i_prYout1: POINTER TO REAL;(*输出*)
	i_prYout2: POINTER TO REAL;(*输出*)
*)
(*系统参数*)
	i_rC:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
(*调整参数*)
	i_rG:REAL;(*趋近增益  不同频率可能符号改变*)
	i_rW:REAL;(*需要抑制的频率，应该尽可能精确*)

(*寄存器*)
	i_prTk:POINTER TO ARRAY [1..1] OF REAL;(*时间寄存器*)
	i_prTheta1k:POINTER TO ARRAY [1..1] OF REAL;(*Theta1寄存器*)
	i_prTheta2k:POINTER TO ARRAY [1..1] OF REAL;(*Theta2寄存器*)
END_VAR
VAR
(*模型参数*)
	rTs:REAL;

	rG:REAL;
	rW:REAL;

	rT:REAL;
	rTheta1:REAL;
	rTheta2:REAL;

	Dot_rTheta1:REAL;
	Dot_rTheta2:REAL;

	rTemp:REAL;
END_VAR
{IMPLEMENTATION}
(*参数初始化*)
	rTs := (i_rC/1000.0)/(i_rV/60.0);

	rG:=i_rG;
	rW:=i_rW;

	rT:=i_prTk^[1]*rTs;
	rTheta1:=i_prTheta1k^[1];
	rTheta2:=i_prTheta2k^[1];

(*计算*)
	Dot_rTheta1:=-1.0*rG*i_rU*COS(rW*rT);
	Dot_rTheta2:=-1.0*rG*i_rU*SIN(rW*rT);
rTemp:=rTheta1;
	rTheta1:=rTemp+Dot_rTheta1*rTs;
	rTheta2:=rTheta2+Dot_rTheta2*rTs;
(*输出*)
i_prYout^:=rTheta1*COS(rW*rT)+rTheta2*SIN(rW*rT);
(*
i_prYout1^:=rTheta1;
i_prYout2^:=rTheta2;
*)
(*寄存器更新*)
i_prTk^[1]:=i_prTk^[1]+1;
i_prTheta1k^[1]:=rTheta1;
i_prTheta2k^[1]:=rTheta2;