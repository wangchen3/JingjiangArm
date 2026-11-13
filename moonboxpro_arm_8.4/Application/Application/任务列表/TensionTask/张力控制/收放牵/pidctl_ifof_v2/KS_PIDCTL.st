(*@CES
Name=KS_PIDCTL
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=be76a32f-4a10-43da-9f5b-6751dc2c804d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PIDCTL : BOOL
(*控制量是增量值,输出的是目标速度*)
VAR_INPUT
	i_xCtlEn:BOOL;(*控制使能*)
	i_xFeedForwardEn:BOOL;(*主速度前馈使能@按照原逻辑,在料膜加速完成时进入*)
	i_rE:REAL;(*误差值*)
	i_rPrevE:REAL;(*前一个误差值@用于增量计算*)
	i_rKp:REAL;(*Kp*)
	i_Ki:REAL;(*Ki*)
	i_rAddVel:REAL;(*叠加的速度增量@常用于伪随机或者测试速度叠加*)
	i_rMaxAdjVel:REAL;(*最大调整速度@相对于主速度*)
	i_rMainVel:REAL;(*主速度*)
	i_rMaxDelVel:REAL;(*最大速度变化量*)
	i_rMaxDelVel_Zero:REAL;(*主机速度为零速时的最大变化量*)
	i_prPrevMainVel:POINTER TO REAL;(*主速度@上个周期值*)
	i_prVel:POINTER TO REAL;(*输出的速度值*)
	(*用于监控*)
	i_prPiValue:POINTER TO REAL;(*调整量*)
	i_prDeltaMainVel:POINTER TO REAL;(*主速度变化量*)
END_VAR
VAR
	rPiValue:REAL;
	rMainVel:REAL;(*主速度*)
	rDeltaMainVel:REAL;(*主速度增量*)
	rPrevMainVel:REAL;(*主速度@上个周期值*)
	rVel:REAL;(*输出的速度值*)
	rTmp: REAL;
	rTmp1: REAL;
END_VAR
{IMPLEMENTATION}
rPrevMainVel:=i_prPrevMainVel^;
rVel:=i_prVel^;
rMainVel:=i_rMainVel;

IF i_xCtlEn THEN
	(*计算主速度增量*)
	rDeltaMainVel:=0;
	IF i_xFeedForwardEn THEN(*主速度前馈使能*)
		rDeltaMainVel := rMainVel - rPrevMainVel;
	END_IF
	rPrevMainVel  := rMainVel;

	(*计算pid值*)
	rPiValue := i_rKp * (i_rE-i_rPrevE) + i_Ki * i_rE;
	IF  ABS(rPiValue)>i_rMaxDelVel THEN
		rPiValue:=i_rMaxDelVel*(rPiValue)/ABS(rPiValue);
	ELSE
		;
	END_IF

	IF rMainVel=0 THEN(*料膜速度为0速的时候，调整牵引到中位。对pi调整量进行限值*)(*2018.7.11.223054*)
		IF ABS(rPiValue)>i_rMaxDelVel_Zero THEN
			rPiValue:=i_rMaxDelVel_Zero*rPiValue/ABS(rPiValue);
		END_IF
	END_IF

	rTmp := rVel + rPiValue + rDeltaMainVel;(*速度累计*)
	rTmp := rTmp + i_rAddVel;(*叠加一些测试速度量@例如伪随机等*)
	IF rTmp < 0 THEN
		IF rMainVel=0 THEN
			rVel:= rTmp;
		ELSE
			rVel:=0;
		END_IF
	ELSE
		rVel:= rTmp;
	END_IF


	(*对输出的速度进行限值*)
	rTmp := i_rMaxAdjVel + rMainVel;(*输出的速度相对于主机速度限值@上限*)
	rTmp1 := -i_rMaxAdjVel + rMainVel;(*输出的速度相对于主机速度限值@下限*)
	IF rVel > rTmp THEN
		rVel := rTmp ;
	ELSIF rVel < rTmp1  THEN
		rVel := rTmp1 ;
	ELSE
		;
	END_IF
ELSE
	rVel := rMainVel;
	rPrevMainVel := rMainVel;
END_IF

i_prPrevMainVel^:=rPrevMainVel;
i_prVel^:=rVel;
IF i_prPiValue<>0 THEN
	i_prPiValue^:=rPiValue;
END_IF
IF i_prDeltaMainVel<>0 THEN
	i_prDeltaMainVel^:=rDeltaMainVel;
END_IF