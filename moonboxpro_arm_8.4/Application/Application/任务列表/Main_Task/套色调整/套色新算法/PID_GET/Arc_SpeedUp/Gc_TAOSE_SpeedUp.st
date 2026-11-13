(*@CES
Name=Gc_TAOSE_SpeedUp
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=40f291f2-24b8-42f7-a9e4-fbe4d11cb647
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Gc_TAOSE_SpeedUp : BOOL
(*升速套色双积分控制器*)
(*输入：套色误差*)
(*输出：给电机的位置控制指令，绝对式*)
(*K(s^2+a1s+a0)/(s^2)*)
VAR_INPUT
(*输入*)
	i_rU:REAL;(*控制器输入@套色误差*)
	i_rVel:REAL;(*速度参数 @运行速度值 m/min*)
	i_rGirth:REAL;(*周长参数 mm*)
(*输出*)
	i_prYout: POINTER TO REAL;(*控制器输出*)
(*控制器参数*)
	i_rK:REAL;(*系统参数K*)
	i_ra2:REAL;(*系统参数a2*)
	i_ra1:REAL;(*系统参数a1*)
	i_ra0:REAL;(*系统参数a0*)
	(*控制器寄存器*)
	i_prGc_Uk:POINTER TO ARRAY [1..3] OF REAL;(*输入寄存器*)
	i_prGc_Yk:POINTER TO ARRAY [1..3] OF REAL;(*输出寄存器*)
END_VAR
VAR
(*采样时间*)
	rTs:REAL;
END_VAR
{IMPLEMENTATION}
IF i_rVel=0 THEN
	i_rVel:=30;
END_IF
IF i_rGirth=0 THEN
	i_rGirth:=500;
END_IF

(*采样时间*)
rTs:=(i_rGirth/1000.0)/(i_rVel/60.0);
(*双积分计算*)
(*功能：二阶传递函数K(a2s^2+a1s+a0)/(b2s^2+b1s+b0)的差分方程实现*)
TF_TwoOrder_V2(i_rU,i_prYout,i_rK,i_ra2,i_ra1,i_ra0,1.0,0.0,0.0,rTs,i_prGc_Uk,i_prGc_Yk);