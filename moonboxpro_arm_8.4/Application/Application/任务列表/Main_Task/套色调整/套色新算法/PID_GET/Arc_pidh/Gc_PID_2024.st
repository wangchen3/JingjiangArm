(*@CES
Name=Gc_PID_2024
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=552ec7f6-cc2d-49c3-aeac-a3021bb272f5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Gc_PID_2024 : REAL
(*2023.09.04.143809 增加加速积分环节*)
(*微调@2023.10.31.192825*)
(*2024.04.06.143012 增加pi的最大输出限值*)
(*2024.7.26.154629 将d值输出打开*)
(*2024.7.27.081735 输出超限了-从积分器里减*)
(*2024.9.12.174833*)
(*积分抗饱和增加注释@2025.1.13.171853*)
VAR_INPUT
	i_rTs:REAL;(*采样周期*)
	i_rP:REAL;
	i_rI:REAL;
	i_rD:REAL;
	i_rN:REAL;
	i_rU:REAL;(*控制器输入*)
	i_prYout: POINTER TO REAL;(*控制器输出*)

	i_parEk:POINTER TO ARRAY [1..2] OF REAL;(*误差寄存器 [e(k);e(k-1)]*)
	i_parYPk:POINTER TO ARRAY [1..2] OF REAL;(*比例控制输出寄存器*)
	i_parYIk:POINTER TO ARRAY [1..2] OF REAL;(*积分控制输出寄存器*)
	i_parYDk:POINTER TO ARRAY [1..2] OF REAL;(*微分控制输出寄存器*)
	i_parYPIDk:POINTER TO ARRAY [1..2] OF REAL;(*PID控制器输出寄存器*)
	(*2024.04.06.135400|增加了调整量的输出限值*)
	i_iMaxYPID:INT;(*最大的pid输出@增量*)
	i_iErrLimit_P:INT;(*Kp的误差限幅@2024.8.1.152553+*)
	i_iErrLimit_I:INT;(*积分的误差限幅@2024.8.1.152553+*)
END_VAR

VAR
	rP:REAL:=20.0;
	rI:REAL:=8.0;
	rD:REAL:=0;
	rN:REAL:=0;
	rTs:REAL:=0;

	rA:REAL:=0;(*加速度*)
	rA_max: REAL:=1.5;(*测试状态下写为定值*)

	rP2:REAL:=1.0;
	rI2:REAL:=0.5;(*用来控制那种加速补偿方式|=1 加速度补偿系数|=2 delta速度补偿方式*)
	rI2_A:REAL:=0.5;
	rPID_Y:REAL:=0;
	(*积分分离*)
	rE_max:REAL:=60.0;(*3*20*)
	rP_max:REAL:=40.0;(*2*rP*)

	(*加速补偿积分使用速度差系数2023.9.18*)
	rV0:REAL:=30.0;(*开始升速的速度*)(*测试状态下写为定值*)
	rVmax:REAL:=200.0;(*升速目标速度*)(*测试状态下写为定值*)
	rI2_v:REAL:=0;
	rDelta_V:REAL:=0;
	rEk_P: REAL;
	rEk_I: REAL;
	rDelta: REAL;
END_VAR
{IMPLEMENTATION}
rTs:=i_rTs;

rP:=i_rP;
rI:=i_rI;
rD:=i_rD;
rN:=i_rN;

(*先按照d不等于0的时候rN=1*)
IF rD=0 THEN
	rN:=0;
ELSE
	rN:=1;
END_IF

(*差分计算*)
i_parEk^[1]:=i_rU;
(*比例*)
(*2024.04.08.110035*)
(*i_prYPk^:=rP*i_parEk^[1];*)

(*对kp的误差值限幅@2024.8.1.152800*)
rEk_P:=i_parEk^[1];
IF i_iErrLimit_P<>0 THEN
	IF ABS(i_parEk^[1])>i_iErrLimit_P THEN
		rEk_P:=INT_TO_REAL(i_iErrLimit_P)*i_parEk^[1]/ABS(i_parEk^[1]);
	END_IF
END_IF
i_parYPk^[1]:=rP*rEk_P(*i_parEk^[1]*);
(*积分*)
(*积分的误差值限幅@2024.8.1.152800*)
rEk_I:=i_parEk^[2];
IF i_iErrLimit_I<>0 THEN
	IF ABS(i_parEk^[2])>i_iErrLimit_I THEN
		rEk_I:=INT_TO_REAL(i_iErrLimit_I)*i_parEk^[2]/ABS(i_parEk^[2]);
	END_IF
END_IF

i_parYIk^[1]:=i_parYIk^[2]+rI*rTs*rEk_I(*i_parEk^[2])*);
(*微分*)
i_parYDk^[1]:=i_parYDk^[2]*(1.0-rN*rTs)+rD*rN*(i_parEk^[1]-i_parEk^[2]);

(*2024.04.06.143033 先取消d值的使用吧*)
(*2024.7.26.141434  又把d值打开了*)
(*2024.04.08.110121*)
(*i_parYPIDk^[1]:=i_prYPk^+i_parYIk^[1]+i_parYDk^[1]*0;(*上面pi的输出*)*)
i_parYPIDk^[1]:=i_parYPk^[1]+i_parYIk^[1]+i_parYDk^[1];(*上面pi的输出*)

(*增加了限值输出@输出的变化量|2024.04.06.140853*)
rDelta:=ABS(i_parYPIDk^[1]-i_parYPIDk^[2]);

IF i_iMaxYPID<>0 THEN
	IF rDelta>i_iMaxYPID THEN(*输出超过了最大允许的变化量|做限值处理*)
		(*限值后的输出*)

		IF i_parYPIDk^[1]>i_parYPIDk^[2] THEN
			i_parYPIDk^[1]:=i_parYPIDk^[2]+i_iMaxYPID;
			(*从积分器里剔除@2024.7.27.081256*)
			i_parYIk^[1]:=i_parYIk^[1]-i_iMaxYPID;(*这种方式相当于是按照绝对位置输出@输出多少量,就减小多少*)
(*			i_parYIk^[1]:=i_parYIk^[1]-(rDelta-i_iMaxYPID);*)(*这种方式相当于是按照最大增量输出后不再输出*)

		ELSE
			i_parYPIDk^[1]:=i_parYPIDk^[2]-i_iMaxYPID;
			(*从积分器里剔除@2024.7.27.081256*)
			i_parYIk^[1]:=i_parYIk^[1]+i_iMaxYPID;(*这种方式相当于是按照绝对位置输出@输出多少量,就减小多少*)
(*			i_parYIk^[1]:=i_parYIk^[1]+(rDelta-i_iMaxYPID);*)(*这种方式相当于是按照最大增量输出后不再输出*)
		END_IF
(*
		IF ABS(i_parYPk^[1]-i_parYPk^[2])>=i_iMaxYPID THEN(*因为kp超过的,此时进行积分隔离@取消积分的叠加*)
			i_parYIk^[1]:=i_parYIk^[2];(*当前积分寄存器中的值和上一拍保持一致*)
		ELSE(*还有一部分积分起作用，超过限制值@只保留输出的积分部分*)
			i_parYIk^[1]:=i_parYPIDk^[1]-i_parYPk^[1];(*当前积分寄存器中的值和上一拍保持一致*)
		END_IF
*)
	END_IF
ELSE;(*保持之前的*)
END_IF

(*更新寄存器的值-注意顺序*)
i_parEk^[2]:=i_parEk^[1];
i_parYPk^[2]:=i_parYPk^[1];(*2024.04.08.110707+*)
i_parYIk^[2]:=i_parYIk^[1];
i_parYDk^[2]:=i_parYDk^[1];
i_parYPIDk^[2]:=i_parYPIDk^[1];

i_prYout^:=i_parYPIDk^[1];