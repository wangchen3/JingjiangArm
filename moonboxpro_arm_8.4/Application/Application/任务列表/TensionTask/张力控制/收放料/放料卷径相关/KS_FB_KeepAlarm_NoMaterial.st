(*@CES
Name=KS_FB_KeepAlarm_NoMaterial
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a4ff428e-9d6c-4ae9-9146-136ef32f1966
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_KeepAlarm_NoMaterial
VAR_INPUT
	i_xEn:BOOL;
	i_xFlag_VolDiamAlarm:BOOL;(*没料报警了*)
	i_xBtnStopAlarm:BOOL;(*停止报警输出*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xKeepAlarm_NoMaterial:BOOL;
END_VAR
VAR
	Trig_DiamAlarm: R_TRIG;
	Trig_StopAlarm: R_TRIG;
END_VAR
{IMPLEMENTATION}
o_xEn:=i_xEn;
Trig_DiamAlarm(CLK:=i_xFlag_VolDiamAlarm);
Trig_StopAlarm(CLK:=i_xBtnStopAlarm);
IF i_xEn THEN
	IF i_xFlag_VolDiamAlarm THEN
	(*启动输出*)
		IF Trig_DiamAlarm.Q  THEN
			o_xKeepAlarm_NoMaterial:=TRUE;
		END_IF
	(*停止输出*)
		IF Trig_StopAlarm.Q THEN
			o_xKeepAlarm_NoMaterial:=FALSE;
		END_IF
	ELSE
		o_xKeepAlarm_NoMaterial:=FALSE;
	END_IF
ELSE
	o_xKeepAlarm_NoMaterial:=FALSE;
END_IF