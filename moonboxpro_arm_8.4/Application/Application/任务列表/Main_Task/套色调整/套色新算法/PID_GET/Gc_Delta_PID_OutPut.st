(*@CES
Name=Gc_Delta_PID_OutPut
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3bd2524c-3dcf-44dc-9cb0-138873b78811
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION Gc_Delta_PID_OutPut : REAL
(*根据绝对值PID控制器输出和增量限幅计算实际的控制器输出增量*)
(*Input:绝对值PID控制器计算值 Cal_PID, 增量限幅值Limit_Delta, 当前控制量累计值*)
(*Output: 当前拍输出的控制量增量 Real_Delta_PID, 控制量累计值*)
VAR_INPUT
	i_rCal_PID:REAL;(*绝对值PID控制器计算值*)
	i_rLimit_Delta:REAL;(*增量限幅值 输入正值*)

	i_prReal_Delta_PID:POINTER TO REAL;(*当前拍输出的控制量增量*)
	i_prSigema_PID:POINTER TO REAL;(*控制量累计值*)
END_VAR

VAR
	rSigema_PID:REAL:=0.0;(*控制量累计值*)
	rGc_Delta:REAL:=0.0;(*当前绝对值PID输出与上一拍累计控制量的差*)
END_VAR
{IMPLEMENTATION}
(*内部变量赋值*)
rSigema_PID := i_prSigema_PID^;

(*计算当前绝对值PID输出与上一拍累计控制量的差*)
rGc_Delta := i_rCal_PID - rSigema_PID;

(*判断该差值的绝对值是否大于限幅值Limit_Delta*)
IF ABS(rGc_Delta) > i_rLimit_Delta THEN

	IF rGc_Delta >0 THEN
		i_prReal_Delta_PID^ := i_rLimit_Delta;
		i_prSigema_PID^ := rSigema_PID + i_rLimit_Delta;
	END_IF

	IF rGc_Delta <0 THEN
		i_prReal_Delta_PID^ := -i_rLimit_Delta;
		i_prSigema_PID^ := rSigema_PID - i_rLimit_Delta;
	END_IF

ELSE
	i_prReal_Delta_PID^ := rGc_Delta;
	i_prSigema_PID^ := rSigema_PID + rGc_Delta;
END_IF