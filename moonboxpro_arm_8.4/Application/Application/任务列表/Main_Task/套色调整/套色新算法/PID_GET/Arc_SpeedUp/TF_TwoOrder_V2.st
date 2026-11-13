(*@CES
Name=TF_TwoOrder_V2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d5659cd4-5616-4a4b-b992-8b70523837b9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION TF_TwoOrder_V2 : REAL
(*功能：二阶传递函数K(a2s^2+a1s+a0)/(b2s^2+b1s+b0)的差分方程实现*)
(*输入：*)
(*输出：*)
VAR_INPUT

	i_rU:REAL;(*控制器输入*)
	i_prYout: POINTER TO REAL;(*控制器输出*)

(*K(a2s^2+a1s+a0)/(b2s^2+b1s+b0)*)
	i_rK:REAL;(*系统参数K*)
	i_ra2:REAL;(*系统参数a2*)
	i_ra1:REAL;(*系统参数a1*)
	i_ra0:REAL;(*系统参数a0*)

	i_rb2:REAL;(*系统参数b2*)
	i_rb1:REAL;(*系统参数b1*)
	i_rb0:REAL;(*系统参数b0*)
	i_rTs:REAL;(*采样时间*)

	i_prUk:POINTER TO ARRAY [1..3] OF REAL;(*输入寄存器*)
	i_prYk:POINTER TO ARRAY [1..3] OF REAL;(*输出寄存器*)

END_VAR

VAR
	rK:REAL:=0;
	ra2:REAL:=0;
	ra1:REAL:=0;
	ra0:REAL:=0;

	rb2:REAL:=0;
	rb1:REAL:=0;
	rb0:REAL:=0;
	rTs:REAL:=0;(*采样时间*)
	rTemp:REAL:=0;
END_VAR
{IMPLEMENTATION}
(*参数初始化*)
rK:=i_rK;
ra2:=i_ra2;
ra1:=i_ra1;
ra0:=i_ra0;

rb2:=i_rb2;
rb1:=i_rb1;
rb0:=i_rb0;
rTs:=i_rTs;

(*更新寄存器注意顺序*)
i_prYk^[3]:=i_prYk^[2];
i_prYk^[2]:=i_prYk^[1];

i_prUk^[3]:=i_prUk^[2];
i_prUk^[2]:=i_prUk^[1];

(*差分计算*)
i_prUk^[1]:=rK*i_rU;
rTemp:=1/(rb0*rTs*rTs+2*rb1*rTs+4*rb2)*(-(2*rb0*rTs*rTs-8*rb2)*i_prYk^[2]-(rb0*rTs*rTs-2*rb1*rTs+4*rb2)*i_prYk^[3]
            +(ra0*rTs*rTs+2*ra1*rTs+4*ra2)*i_prUk^[1]+(2*ra0*rTs*rTs-8*ra2)*i_prUk^[2]+(ra0*rTs*rTs-2*ra1*rTs+4*ra2)*i_prUk^[3]);
i_prYk^[1]:=rTemp;
i_prYout^:=rTemp;