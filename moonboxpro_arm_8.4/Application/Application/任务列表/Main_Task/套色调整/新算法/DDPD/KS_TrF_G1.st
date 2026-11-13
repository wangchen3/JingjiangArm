(*@CES
Name=KS_TrF_G1
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=447eb93a-1879-4476-98f9-0eae4a9407a4
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_TrF_G1 : REAL
(*传递函数s+a0/s+b0*)
VAR_INPUT
	i_rU:REAL;(*控制器输入*)
	i_rTs:REAL;(*采样时间*)
	i_rA:REAL;(*系统参数Ai,分子系数*)
	i_rA_1:REAL;(*系统参数Ai-1分母系数*)
	i_prUk:POINTER TO ARRAY [1..2] OF REAL;(*G1输入函数寄存器*)
	i_prYk:POINTER TO ARRAY [1..2] OF REAL;(*G1输出函数寄存器*)
END_VAR
VAR
	ra0:REAL:=0;
	rb0:REAL:=0;
	rTs:REAL:=0;(*采样时间*)
	rTemp:REAL:=0;
END_VAR
{IMPLEMENTATION}
ra0:=i_rA;
rb0:=i_rA_1;
rTs:=i_rTs;
IF ra0<>0 AND rb0<>0 AND rTs<>0 AND i_prUk<>0 AND i_prYk<>0 THEN
	i_prUk^[1]:=i_rU;
	rTemp:=1.0/(rb0*rTs+2.0)*(-(rb0*rTs-2.0)*i_prYk^[2]+(2.0+ra0*rTs)*i_prUk^[1]+(ra0*rTs-2.0)*i_prUk^[2]);
	i_prYk^[1]:=rTemp;
ELSIF i_prUk<>0 AND i_prYk<>0 THEN
	i_prUk^[1]:=0;
	i_prYk^[1]:=0;
END_IF