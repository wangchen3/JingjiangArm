(*@CES
Name=KS_GetPulse_ActEx
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fa7aacb3-70fc-4571-89fd-f05cb3be533c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetPulse_ActEx : INT(*读取实际的走了的脉冲数*)
(*2025.6.14.134137 增加累计取反*)
VAR_INPUT
	i_xRev:BOOL;(*取反标志|累计取反@2025.6.14.134133*)
	pwStepDrivePulse_Act_Rd :POINTER TO WORD;(*读取到的脉冲数*)
	pwStepDrivePulse_Act_Rd_Bak:POINTER TO WORD;(*上个周期读到的脉冲数*)
	pdiStepDrivePulse_Act:POINTER TO DINT;(*实际走的脉冲数*)
END_VAR
VAR
	iStepDrivePulse_Act_Rd: INT;
	iStepDrivePulse_Act_Rd_Bak: INT;
	iDeltaPulse: INT;(*步进电机脉冲变化量*)
END_VAR
{IMPLEMENTATION}
KS_GetPulse_ActEx:=0;
IF pwStepDrivePulse_Act_Rd<>0 AND pwStepDrivePulse_Act_Rd_Bak<>0 AND pdiStepDrivePulse_Act <>0 THEN;
ELSE
	KS_GetPulse_ActEx:=-1;
	RETURN;
END_IF

iStepDrivePulse_Act_Rd:=WORD_TO_INT(pwStepDrivePulse_Act_Rd^);
iStepDrivePulse_Act_Rd_Bak:= WORD_TO_INT(pwStepDrivePulse_Act_Rd_Bak^);

IF iStepDrivePulse_Act_Rd <> iStepDrivePulse_Act_Rd_Bak THEN
	iDeltaPulse:=(iStepDrivePulse_Act_Rd-iStepDrivePulse_Act_Rd_Bak);
	IF i_xRev THEN
		iDeltaPulse:=-iDeltaPulse;
	END_IF
	pdiStepDrivePulse_Act^:=pdiStepDrivePulse_Act^+iDeltaPulse;
ELSE;
END_IF

pwStepDrivePulse_Act_Rd_Bak^:=INT_TO_WORD(iStepDrivePulse_Act_Rd);(*保存上个周期的值*)