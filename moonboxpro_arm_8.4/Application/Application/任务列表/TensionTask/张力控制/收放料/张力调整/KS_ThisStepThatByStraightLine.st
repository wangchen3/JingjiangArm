(*@CES
Name=KS_ThisStepThatByStraightLine
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7e0684ca-8029-4adc-9883-37fc94a520b5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ThisStepThatByStraightLine : BOOL(*到达目标值标志*)
VAR_INPUT
	i_rThis:REAL;(*起始值 用于计算变化量*)
	i_rThat:REAL;(*目标值*)
	i_prCur:POINTER TO REAL;(*当前值*)
	i_iStepTime:INT:=10;(*S*)
	i_iCycleTime:INT:=20;(*程序执行时间*)
	i_xFlag_Cut_end:BOOL;
END_VAR
VAR
	rDel: REAL;
	rCur: REAL;
END_VAR
{IMPLEMENTATION}
IF i_iStepTime=0 THEN
	i_iStepTime:=10*1000;
ELSE
	i_iStepTime:=i_iStepTime*1000;
END_IF(*ms即10s*)

rDel:=(i_rThat-i_rThis)/i_iStepTime*i_iCycleTime;(*计算变化量*)
rDel:=ABS(rDel);

IF i_prCur<>0 THEN
(*有个小bug 目标值从a切到b未到达b的时候又切到a可能会存在不变化的问题；
针对该问题 我们将变化量值切换为固定值|2019.4.11.095538*)

	IF rDel=0 AND i_prCur^<>i_rThat THEN
		rDel:=ABS(10.0/i_iStepTime*i_iCycleTime);(*固定变化量*)
	END_IF

	IF i_xFlag_Cut_end THEN
		i_prCur^:=i_rThat;
	ELSE
		IF i_prCur^>i_rThat THEN
			i_prCur^:=i_prCur^-rDel;
			IF i_prCur^<i_rThat THEN
				i_prCur^:=i_rThat;
			END_IF
		ELSIF i_prCur^<i_rThat THEN
			i_prCur^:=i_prCur^+rDel;
			IF i_prCur^>i_rThat THEN
				i_prCur^:=i_rThat;
			END_IF
		ELSE
			i_prCur^:=i_rThat;
		END_IF
	END_IF

	IF i_prCur^=i_rThat THEN
		KS_ThisStepThatByStraightLine:=TRUE;
	END_IF
ELSE
	RETURN;
END_IF