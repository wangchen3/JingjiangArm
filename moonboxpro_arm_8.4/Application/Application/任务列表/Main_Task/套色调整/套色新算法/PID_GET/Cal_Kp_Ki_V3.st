(*@CES
Name=Cal_Kp_Ki_V3
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=deaeaf1e-1ab7-4a2c-8f0b-a36d361ddac8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Cal_Kp_Ki_V3 : BOOL
(*2025.1.11.165519 增加了非法值处理@Liu.yt*)
(*将开环对象镇定为期望的幅值裕度和相位裕度*)
(*输入开环幅值裕度(10-20)，相位裕度(40-60)*)
(*由于需要调整积分满足相位裕度，因此实际的幅值裕度会略微小于设置值（在所给出的相位裕度范围内一般偏差在1dB以内，不超过2dB），相位裕度取得越小，幅值裕度偏差越大*)

VAR_INPUT
(*模型变量*)
	i_rV:REAL;(*运行速度m/min*)
	i_rLTao:REAL;(*印刷点到光电眼距离*)
	i_rL:REAL;(*机组料长m*)
(*控制变量*)
	i_rMargin_Mag:REAL;(*幅值裕度   15dB*)
	i_rMargin_Phi:REAL;(*相位裕度  50度*)
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

	rKp_temp:REAL; (*临时Kp*)
	rKi_temp:REAL;(*临时Ki*)

	rax:REAL; (*模型临时参数，计算Wc使用*)
	rbx:REAL; (*模型临时参数，计算Wc使用*)

	rA_e:REAL;(*二次方程系数*)
	rB_e:REAL;(*二次方程系数*)
	rC_e:REAL;(*二次方程系数*)

	rX_temp:REAL;(*方程的解*)
	rWc:REAL;(*近似截止频率*)

	rPhi_temp:REAL;(*相位裕度临时量*)
	rDelta_Phi:REAL;(*相位裕度偏差*)
	rDelta_Phi_rad:REAL;(*相位裕度偏差 弧度表示*)

	rI:REAL;(*积分系数*)
END_VAR
{IMPLEMENTATION}
IF i_rL<>0 AND i_rV<>0 AND i_rLTao<>0 THEN
(*计算模型参数*)
	rA := (i_rV/60.0)/i_rL;
	rTao := i_rLTao/(i_rV/60.0) +0.1 ;
(*计算满足幅值裕度时的近似截止频率和增益*)
	(*计算-180度对应的频率*)
	rWf := LREAL_TO_REAL(90.0 * gc_lrPi / 180.0 / rTao);
	(*计算-180度对应的幅值 和rKadj*)
	rMag_Wf := 20.0 * LOG(0.1 * rA / rWf); (*为负数*)
	rKTemp := (-1.0*i_rMargin_Mag - rMag_Wf) / 20.0  ;
	rKadj := LREAL_TO_REAL(EXPT(10, rKTemp));

	(*Kp*)
	rKp_temp := rKadj;

	(*Ki*)
	rKi_temp := rKadj * rA;
	(*计算此时的截止频率Wc*)
	rax := rA;
	rbx := 0.1*rA;

	(*构建二次方程*)
	rA_e := 1;
	rB_e := rax * rax - rbx * rbx * rKp_temp * rKp_temp;
	rC_e := -1.0 * rbx * rbx * rKi_temp * rKi_temp;

	(*计算根*)
	rX_temp := (-1.0 * rB_e + SQRT(rB_e * rB_e - 4.0 * rA_e * rC_e)) / (2.0 * rA_e);
	rWc := SQRT(rX_temp);

	(*计算相位裕度偏差*)
	rPhi_temp := LREAL_TO_REAL(90.0 - rWc * rTao / gc_lrPi * 180.0);
	rDelta_Phi := rPhi_temp - i_rMargin_Phi - 5;(*5是额外的裕度，可调整*)

	rI := rA;
	IF rDelta_Phi > 0 THEN
		(*转成弧度表示*)
		rDelta_Phi_rad := LREAL_TO_REAL(rDelta_Phi / 180.0 * gc_lrPi);

		(*计算调整的积分系数rI *)
		rI := rWc * (1.0 + (rWc / rA) * TAN(rDelta_Phi_rad) ) /  ((rWc / rA) - TAN(rDelta_Phi_rad) );
	END_IF

	(*Kp*)
	i_prKp^ := rKadj;

	(*Ki*)
	i_prKi^ := rKadj * rI;
ELSE
	i_prKp^ := 16;
	i_prKi^ := 8;
END_IF