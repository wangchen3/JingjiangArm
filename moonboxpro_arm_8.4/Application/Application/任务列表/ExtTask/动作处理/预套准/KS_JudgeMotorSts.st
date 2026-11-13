(*@CES
Name=KS_JudgeMotorSts
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a5e3ced4-c2da-4f83-ae84-e1a255808c54
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_JudgeMotorSts : BYTE(*判断电机状态函数|0 停止 1 运动*)
(*检测10个周期规划速度在一定阈值内则认为处于停止状态|*)
VAR_INPUT
	i_rMotorVel_FeedBack:REAL;(*反馈电机速度|PTsts反馈*)
	i_iThreshold:INT;(*判断的阈值|单位好像是脉冲*)
	i_iCycleNum_InStop:INT;(*处于停止的周期次数|这么多周期都处于阈值内就认为是停止了*)
	i_piCycleCnt_Stop:POINTER TO INT;(*处于停止阈值的周期计数*)
END_VAR
VAR
	iCycleCnt_Stop: INT;
	byMotorSts:BYTE;
END_VAR

{IMPLEMENTATION}
IF i_piCycleCnt_Stop<>0 THEN
	iCycleCnt_Stop:=i_piCycleCnt_Stop^;
END_IF

IF ABS(i_rMotorVel_FeedBack)<i_iThreshold THEN
	IF iCycleCnt_Stop<i_iCycleNum_InStop THEN
		iCycleCnt_Stop:=iCycleCnt_Stop+1;
	END_IF
ELSE
	iCycleCnt_Stop:=0;
END_IF

IF iCycleCnt_Stop>=i_iCycleNum_InStop THEN(*超过周期设定值|*)
	byMotorSts:=0;
ELSE
	byMotorSts:=1;
END_IF

IF i_piCycleCnt_Stop<>0 THEN
	i_piCycleCnt_Stop^:=iCycleCnt_Stop;
END_IF

KS_JudgeMotorSts:=byMotorSts;