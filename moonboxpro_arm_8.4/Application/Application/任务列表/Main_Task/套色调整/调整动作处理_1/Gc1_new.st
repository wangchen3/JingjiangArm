(*@CES
Name=Gc1_new
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=31808837-ad1f-48a1-98ba-96e5e7e89c1f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Gc1_new : BOOL
(*传递函数s/(s+A)*)
VAR_INPUT

	i_rU:REAL;(*控制器输入*)
	i_prYout: POINTER TO REAL;(*控制器输出*)
(*
	i_rC:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
*)
	i_rTs:REAL;(*2024.7.24.103836修改为了输入@s*)
	i_rA:REAL;(*系统参数A*)

	i_prUk:POINTER TO ARRAY [1..2] OF REAL;(*输入寄存器*)
	i_prYk:POINTER TO ARRAY [1..2] OF REAL;(*输出寄存器*)

END_VAR

VAR
	ra0:REAL:=0;
	rb0:REAL:=0;
	rTs:REAL:=0;(*采样时间*)
	rTemp:REAL:=0;
END_VAR
{IMPLEMENTATION}
(*参数*)
(*rTs:=i_rC/(i_rV*1000.0/60.0);*)
rTs:=i_rTs;
rb0:=i_rA;

(*更新寄存器注意顺序*)
i_prYk^[2]:=i_prYk^[1];
i_prUk^[2]:=i_prUk^[1];

(*差分计算*)
i_prUk^[1]:=i_rU;
rTemp:=1.0/(rb0*rTs+2.0)*(-(rb0*rTs-2.0)*i_prYk^[2]+(ra0*rTs+2.0)*i_prUk^[1]+(ra0*rTs-2.0)*i_prUk^[2]);
i_prYk^[1]:=rTemp;
i_prYout^:=rTemp;