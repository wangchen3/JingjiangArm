(*@CES
Name=Cal_Kp_Ki_V2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c47de549-0752-4bbe-8145-8113c580532b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Cal_Kp_Ki_V2 : BOOL
(*2025.1.15.123422 增加了时延参数输入*)
VAR_INPUT
(*模型变量*)
	i_rV:REAL;(*运行速度m/min*)
	i_rLTao:REAL;(*印刷点到光电眼距离*)
	i_rL:REAL;(*机组料长m*)
	i_rDelay:REAL;(*时延@2025.1.15.123404+*)
(*控制变量*)
	i_rKadj_Mag:REAL;(*幅值裕度   15dB|越小越强*)
	i_rKadj_i:REAL;(*积分增益  1.0*)
(*输出指针*)
	i_prKp:POINTER TO REAL;(*Kp*)
	i_prKi:POINTER TO REAL;(*Ki*)
END_VAR
VAR
	rA:REAL;(*模型参数*)
	rTao:REAL;(*光电眼到印刷点的时延 s*)

	rWf:REAL;(*-180度对应的频率*)
	rMag_Wf:REAL;(*-180度对应的幅值*)

	rKadj:REAL; (*满足幅值裕度的增益*)
	rKTemp:REAL;(*增益计算临时变量*)

	iAverageNum:INT;
	iArcErr:INT;
END_VAR
{IMPLEMENTATION}
IF i_rL<>0 AND i_rV<>0 AND i_rLTao<>0 THEN
	(*计算模型参数*)
	rA := (i_rV/60.0)/i_rL;
(*	rTao := i_rLTao/(i_rV/60.0) +0.1 ;*)
	rTao := i_rLTao/(i_rV/60.0) + i_rDelay ;

	(*计算-180度对应的频率*)
	rWf := LREAL_TO_REAL(90.0 * gc_lrPi / 180.0 / rTao);
	(*计算-180度对应的幅值 和rKadj*)
	rMag_Wf := 20.0 * LOG(0.1 * rA / rWf); (*为负数*)
	rKTemp := (-1.0*i_rKadj_Mag - rMag_Wf) / 20.0  ;
	rKadj := LREAL_TO_REAL(EXPT(10, rKTemp));

	(*Kp*)
	i_prKp^ := rKadj;

	(*Ki*)
	i_prKi^ := rKadj * rA * i_rKadj_i;
ELSE
	i_prKp^ := 16;
	i_prKi^ := 8;
END_IF