(*@CES
Name=SmithPI
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=cdff3448-9cdd-43dc-a40d-d24eec630f60
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION SmithPI : BOOL
(*采取Smith的方法设计的控制器，只针对套色系统，采用滑动平均，长度3*)
(*输入:*)
VAR_INPUT
(*输入输出*)
	i_rU:REAL;(*输入*)
	i_prYout: POINTER TO REAL;(*输出*)
(*系统参数*)
	i_rC:REAL;(*版周长mm*)
	i_rV:REAL;(*运行速度m/min*)
	i_rL:REAL;(*机组料长m*)
	i_iNDEL:INT;(*时延拍数N=LDel/C*)(*检测料长LDEL*)
(*PI控制器*)
	i_rKp:REAL;(*版周长mm*)
	i_rKi:REAL;(*运行速度m/min*)
(*寄存器  初始值0*)
	i_prPIUk:POINTER TO ARRAY [1..2] OF REAL;(*输入寄存器*)
	i_prPIYk:POINTER TO ARRAY [1..2] OF REAL;(*输出寄存器*)
(*0.1a/(s+a)*)
	i_prTF1Uk:POINTER TO ARRAY [1..2] OF REAL;(*输入寄存器*)
	i_prTF1Yk:POINTER TO ARRAY [1..2] OF REAL;(*输出寄存器*)
(*滑动滤波器(长度3) 1/3(z^2+z+1)/z^2*)
	i_prTF2Uk:POINTER TO ARRAY [1..3] OF REAL;(*输入寄存器*)
	i_prTF2Yk:POINTER TO ARRAY [1..3] OF REAL;(*输出寄存器*)
(*纯时延*)
	i_prDELUk:POINTER TO ARRAY [1..gc_iNDEL] OF REAL;(*输入寄存器*)

END_VAR

VAR
(*模型参数*)
	ra:REAL;
	rbc:REAL;
(*PI*)
	rPIIN:REAL;
	rPIOUT:REAL;
	rKp:REAL;
	rKi:REAL;

(*(a1s+a0)/(b1s+b0)*)
	rTF1IN:REAL;
	rTF1OUT:REAL;

	ra1_TF1:REAL;(*系统参数a1*)
	ra0_TF1:REAL;(*系统参数a0*)
	rb1_TF1:REAL;(*系统参数b1*)
	rb0_TF1:REAL;(*系统参数b0*)

(*(z^2+a1z+a0)/(z^2+b1z+b0)*)
	rTF2IN:REAL;
	rTF2OUT:REAL;

	ra2_TF2:REAL;(*系统参数a2*)
	ra1_TF2:REAL;(*系统参数a1*)
	ra0_TF2:REAL;(*系统参数a0*)
	rb2_TF2:REAL;(*系统参数b2*)
	rb1_TF2:REAL;(*系统参数b1*)
	rb0_TF2:REAL;(*系统参数b0*)

(*纯时延 *)
	iNDEL:INT;(*时延拍数*)
	rTF3IN:REAL;
	rTF3OUT:REAL;

	rTs:REAL:=0;(*采样时间*)
	rTemp:REAL:=0;

	iI:INT;(*循环拍数*)
END_VAR
{IMPLEMENTATION}
(*参数初始化*)
	ra := (i_rV/60.0)/i_rL;
	rbc := 0.1*ra;
	rTs := (i_rC/1000.0)/(i_rV/60.0);
(*PI*)
	rKp:=i_rKp;
	rKi:=i_rKi;

	rTF2OUT:=i_prTF2Yk^[1];
	rPIIN:=i_rU-rTF2OUT;

	(*计算*)
	i_prPIUk^[1]:=rPIIN;
	i_prPIYk^[1]:=rKp*i_prPIUk^[1]+rTs*rKi*i_prPIYk^[2];
	(*更新寄存器注意顺序*)
	i_prPIYk^[2]:=i_prPIYk^[2]+i_prPIUk^[1];
	i_prPIUk^[2]:=i_prPIUk^[1];

	rPIOUT:=i_prPIYk^[1];
	i_prYout^:=rPIOUT;


(*TF1*)(*(a1s+a0)/(b1s+b0)*)
	rTF1IN := rPIOUT;

	ra1_TF1 := 0;(*a1*)
	ra0_TF1 := rbc;(*a0*)
	rb1_TF1 := 1.0;(*b1*)
	rb0_TF1 := ra;(*b0*)

	(*差分计算*)
	i_prTF1Uk^[1]:=rTF1IN;
	rTemp:=1.0/(rb0_TF1*rTs+2.0*rb1_TF1)*(-(rb0_TF1*rTs-2.0*rb1_TF1)*i_prTF1Yk^[2]+(ra0_TF1*rTs+2.0*ra1_TF1)*i_prTF1Uk^[1]+(ra0_TF1*rTs-2.0*ra1_TF1)*i_prTF1Uk^[2]);
	i_prTF1Yk^[1]:=rTemp;

	(*更新寄存器注意顺序*)
	i_prTF1Yk^[2]:=i_prTF1Yk^[1];
	i_prTF1Uk^[2]:=i_prTF1Uk^[1];

	rTF1OUT := i_prTF1Yk^[1];
(*时延*)(*1-e^(ts)*)
	iNDEL := i_iNDEL;
	(*差分计算*)
	rTF3IN:=rTF1OUT;
	(*输出*)
	rTemp:=i_prDELUk^[iNDEL];
	i_prDELUk^[1]:=rTF3IN;
	(*更新寄存器注意顺序*)
	FOR iI:=0 TO iNDEL-2 BY 1 DO
		i_prDELUk^[iNDEL-iI]:=i_prDELUk^[iNDEL-iI-1];
	END_FOR
	
	rTF3OUT := rTF3IN-rTemp;

(*TF2*)(*(z^2+a1z+a0)/(z^2+b1z+b0)*)
	rTF2IN := rTF3OUT;

	ra2_TF2:=1.0/3.0;(*a2*)
	ra1_TF2:=1.0/3.0;(*a1*)
	ra0_TF2:=1.0/3.0;(*a0*)
	rb2_TF2:=1.0;(*b2*)
	rb1_TF2:=0;(*b1*)
	rb0_TF2:=0;(*b0*)

	(*差分计算*)
	i_prTF2Uk^[1]:=rTF2IN;
	rTemp:=1.0/rb2_TF2*(-rb1_TF2*i_prTF2Yk^[2]-rb0_TF2*i_prTF2Yk^[3]+ra2_TF2*i_prTF2Uk^[1]+ra1_TF2*i_prTF2Uk^[2]+ra0_TF2*i_prTF2Uk^[3]);
	i_prTF2Yk^[1]:=rTemp;

	(*更新寄存器注意顺序*)
	i_prTF2Yk^[3]:=i_prTF2Yk^[2];
	i_prTF2Yk^[2]:=i_prTF2Yk^[1];
	
	i_prTF2Uk^[3]:=i_prTF2Uk^[2];
	i_prTF2Uk^[2]:=i_prTF2Uk^[1];