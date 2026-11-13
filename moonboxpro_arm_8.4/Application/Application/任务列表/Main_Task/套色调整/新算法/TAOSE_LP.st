(*@CES
Name=TAOSE_LP
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=485985c2-2621-484a-b6fa-e6cad1c717a3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION TAOSE_LP : BOOL
(*套色时变低通*)
VAR_INPUT
	i_rE:REAL;(*输入的原始套色误差*)
	i_prE_DEAL: POINTER TO REAL;(*处理后的套色输出*)
(*滤波强度*)
	i_rK:REAL;
(*系统参数*)
	i_rC:REAL;(*版周长mm*)
	i_rL:REAL;(*机组料长m *)
	i_rV:REAL;(*运行速度 m/min*)
(*寄存器*)
	i_prEk:POINTER TO ARRAY [1..3] OF REAL;(*输入寄存器*)
	i_prE_DEALk:POINTER TO ARRAY [1..3] OF REAL;(*输出寄存器*)
END_VAR
VAR
(*模型参数*)
	rA:REAL;
(*滤波器参数*)
	rWn:REAL;
	rBeta:REAL;

(*二阶传递函数参数K(a2s^2+a1s+a0)/(b2s^2+b1s+b0)*)
	rK:REAL;
	ra2:REAL;
	ra1:REAL;
	ra0:REAL;

	rb2:REAL;
	rb1:REAL;
	rb0:REAL;

	rTs:REAL;(*采样时间*)
END_VAR
{IMPLEMENTATION}
IF i_rL<>0 AND
	i_rV<>0 AND(*参数合法*)
	i_rC<>0 THEN
(*模型参数*)
	rA:= (i_rV/60.0)/i_rL;
(*滤波器参数计算*)
	rWn := i_rK*rA;
	rBeta := 0.707;
(*传递函数参数计算*)
	rK:=1.0;
	ra2:=0;
	ra1:=0;
	ra0:=rWn*rWn;

	rb2:=1;
	rb1:=2*rBeta*rWn;
	rb0:=rWn*rWn;

	rTs := i_rC/1000.0/(i_rV/60.0);
(*滤波计算*)
	TF_TwoOrder_V2(i_rE,i_prE_DEAL,rK,ra2,ra1,ra0,rb2,rb1,rb0,rTs,i_prEk,i_prE_DEALk);
ELSE;
END_IF