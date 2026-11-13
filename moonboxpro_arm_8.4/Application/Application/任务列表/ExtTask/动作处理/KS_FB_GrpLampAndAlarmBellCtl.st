(*@CES
Name=KS_FB_GrpLampAndAlarmBellCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eea8cc40-7b3e-4264-b59d-3f431f7baf96
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpLampAndAlarmBellCtl
VAR_INPUT
	i_xEn: BOOL;
	i_iUnitNum: INT;
	i_pstStEvtReq: POINTER TO StEvtReq;
	i_xFlag_Stoping: BOOL;
	i_xFlag_Stop: BOOL;
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
END_VAR
VAR
	tmNow: TIME;
	tmLastStateChanged_Stop: TIME;
	xLamp_Stop: BOOL;(*停止指示灯*)
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	tmNow:= TIME();
	IF i_xFlag_Stoping THEN(*停机过程中停止指示灯闪烁*)
		IF tmNow-tmLastStateChanged_Stop>=T#200MS THEN
			xLamp_Stop:= NOT xLamp_Stop;
			tmLastStateChanged_Stop:= tmNow;
		END_IF
	ELSE
		xLamp_Stop:= i_xFlag_Stop;
		tmLastStateChanged_Stop:= tmNow;
	END_IF
	
	
ELSE
	o_iErNo:= -1;
END_IF