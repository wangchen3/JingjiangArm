(*@CES
Name=AntiNotch
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=24b15fba-c20e-4805-94ad-f0677bc5936e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION AntiNotch : BOOL
(*功能：反陷波器(s^2+2*d*wn*s+wn^2)/(s^2+2*d*xi*wn*s+wn^2)的差分方程实现*)
(*输入：*)
(*输出：*)
VAR_INPUT
	i_rU:REAL;(*信号输入*)
	i_prYout: POINTER TO REAL;(*信号输出*)

(*(s^2+2*d*wn*s+wn^2)/(s^2+2*d*xi*wn*s+wn^2)*)
	i_rWn:REAL;(*陷波中心频率 rad/s*)
	i_rBw:REAL;(*陷波宽度 rad/s*)
	i_rDp:REAL;(*陷波深度 dB*)

	i_rTs:REAL;(*采样时间*)

	i_prUk:POINTER TO ARRAY [1..3] OF REAL;(*输入寄存器*)
	i_prYk:POINTER TO ARRAY [1..3] OF REAL;(*输出寄存器*)
END_VAR
VAR
	rFn:REAL:=0;
	rFBw:REAL:=0;
	rWn:REAL:=0;
	rDp:REAL:=0;

	rD:REAL:=0;
	rXi:REAL:=0;

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
rFn := LREAL_TO_REAL(i_rWn/2.0*gc_lrPi);
rWn := i_rWn;
rFBw := LREAL_TO_REAL(i_rBw/2.0*gc_lrPi);
rDp := i_rDp;

rTemp := -rDp/20.0;
rD := LREAL_TO_REAL(EXPT(10,rTemp));

rTemp := LREAL_TO_REAL(1.0/(1.0 - 2.0*EXPT(rD,2)));
rXi := rFBw/(2.0*rFn)*SQRT(rTemp);

rK := 1.0;

ra2:=1.0;
ra1:=2*rXi*rWn;
ra0:=rWn*rWn;

rb2:=1;
rb1:=2*rD*rXi*rWn;
rb0:=rWn*rWn;

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