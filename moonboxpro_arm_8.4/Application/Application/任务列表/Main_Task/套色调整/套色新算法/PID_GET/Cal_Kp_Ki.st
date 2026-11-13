(*@CES
Name=Cal_Kp_Ki
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a93d564e-2599-4b4b-9c00-c963b5a75637
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Cal_Kp_Ki : BOOL
(*2024.9.6.123503*)
(*通过和控制器计算公式对比这里对Ki做的一些处理,反应到Ki计算上相当于积分的系数是定值,因为ts=周长/速度*系数
这里对输入的i_rV 按照30m/min定值输入,这样在计算积分的时候会出现积分根据速度逐渐减小的变化*)
(*2024.9.6.125139 将Ki的速度分开*)
(*2025.1.3.140421删除无用的*)
VAR_INPUT
(*
	i_byFilmType:BYTE;
	(*增加一些控制变量@2024.8.25.164242*)
	i_byTimingKiByArcErr:BYTE;(*=0 不使能|=1根据误差值Ki变化|值越大积分越小*)
	i_byAverageNum:BYTE;(*平均次数*)
	i_byColorId:BYTE;(*色序id*)
	i_iArcErr:INT;(*套色误差@mm*)
*)
(*模型变量*)
	i_rV:REAL;(*运行速度m/min*)
	i_rV_Ki:REAL;(*运行速度m/min*)
	i_rCL:REAL;(*版周长mm*)
	i_rL:REAL;(*机组料长m*)
(*控制变量*)
	i_rKadj_all:REAL;(*调整增益   40*)
	i_rKadj_i:REAL;(*积分增益  2.0*)
(*输出指针*)
	i_prKp:POINTER TO REAL;(*Kp*)
	i_prKi:POINTER TO REAL;(*Ki*)
END_VAR
VAR

	rA:REAL;(*模型参数*)(*
	iAverageNum:INT;
	iArcErr:INT;
*)
END_VAR
{IMPLEMENTATION}
IF i_rL<>0 AND i_rV<>0 AND i_rV_Ki<>0 AND i_rCL<>0 THEN
	(*计算模型参数*)
	rA := (i_rV/60.0)/i_rL;
	(*Kp*)
	i_prKp^ := i_rKadj_all/i_rCL*i_rV/rA;

	(*Ki*)
(*	i_prKi^ := i_rKadj_all/i_rCL*i_rV*i_rKadj_i;*)
	i_prKi^ := i_rKadj_all/i_rCL*i_rV_Ki*i_rKadj_i;
ELSE
	i_prKp^ := 16;
	i_prKi^ := 8;
END_IF