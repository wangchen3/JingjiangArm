(*@CES
Name=KS_CheckSensorMotorIdleSts
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e3f21590-970b-415a-a0bb-786d7afe314f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CheckSensorMotorIdleSts : BOOL
(*|=0 检查所有传感器的是否处于空闲状态@所有都空闲则输出true|有一个在运动就置位false*)
(*|=合法轴id,则返回轴状态|TRUE 是空闲,FALSE是运动*)
VAR_INPUT
	i_iAxisId:INT;(*轴号@=0 *)
	i_byAxisNum:BYTE;(*轴个数@全自动套印轴*)
	i_aiAxisList_AutoAdj:ARRAY [1..MAX_UNIT_NUM] OF int;(*轴列表*)
	i_axSensorMotorIdle:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*传感器电机空闲状态@该状态不是直接通讯上来的,需要做处理后的*)
END_VAR
VAR
	iN: INT;
	xSensorMotorIdle: BOOL;
	iAxisId: INT;
	xResult: BOOL:=TRUE;
END_VAR
{IMPLEMENTATION}
IF i_iAxisId=0 THEN
	FOR iN:=2 TO i_byAxisNum BY 1 DO
		iAxisId:=i_aiAxisList_AutoAdj[iN];
		IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN
			xSensorMotorIdle:=i_axSensorMotorIdle[iAxisId];
			IF NOT xSensorMotorIdle THEN(*处于运动中*)
				xResult:=FALSE;
				EXIT;
			END_IF
		END_IF
	END_FOR
ELSE
	iAxisId:=i_iAxisId;
	IF iAxisId>0 AND iAxisId<=MAX_UNIT_NUM THEN
		xSensorMotorIdle:=i_axSensorMotorIdle[iAxisId];
		IF NOT xSensorMotorIdle THEN(*处于运动中*)
			xResult:=FALSE;
		END_IF
	END_IF
END_IF

KS_CheckSensorMotorIdleSts:=xResult;