(*@CES
Name=KS_FB_SpeedRamp
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=bdbad0f9-c013-4df4-8a1e-22a5d51e65fb
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK  KS_FB_SpeedRamp 
VAR_INPUT
	i_lrTarget :LREAL;    //目标值-PID输出
	i_lrRampTime : LREAL; //爬坡时间
	i_lrVelLimit : LREAL;  // 基准速度限制
	i_lrTs :LREAL;  //plc周期执行时间 
END_VAR
VAR_OUTPUT
    o_lrCurrentVel : LREAL;   (* 当前速度 (o_fMotorSpeed_RPM) - 既是输入也是输出 *)
END_VAR 
VAR
	lrStep       : LREAL;   (* 单步变化量 *)
END_VAR

{IMPLEMENTATION}
// 计算步长以 rVel_limit 为基准速度。如果 c_fRampTime =5.0s，代表 5秒内 允许速度变化量为 rVel_limit
IF i_lrRampTime > 0.001 THEN
	lrStep := (i_lrVelLimit / i_lrRampTime) * i_lrTs;
ELSE
	lrStep := i_lrVelLimit;
END_IF

// 斜坡追赶=让 当前速度 基于"上一次的值"，一步步逼近 目标值
IF i_lrTarget > o_lrCurrentVel THEN
	o_lrCurrentVel := o_lrCurrentVel + lrStep;   // PID要求加速 (或反向减速)
	IF o_lrCurrentVel > i_lrTarget THEN 
		o_lrCurrentVel := i_lrTarget; 
	END_IF
ELSIF i_lrTarget < o_lrCurrentVel THEN
	o_lrCurrentVel := o_lrCurrentVel - lrStep;    // PID要求减速 (或反向加速)

	IF o_lrCurrentVel <i_lrTarget THEN 
		o_lrCurrentVel := i_lrTarget; 
	END_IF
END_IF

// 安全限幅 
IF o_lrCurrentVel > i_lrVelLimit THEN 
	o_lrCurrentVel := i_lrVelLimit; 
END_IF;
IF o_lrCurrentVel < -i_lrVelLimit THEN 
	o_lrCurrentVel := -i_lrVelLimit; 
END_IF;

