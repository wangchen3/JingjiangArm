(*@CES
Name=KS_GetPulse_Act
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7e51e991-78cc-4457-be42-c8156f7134b7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetPulse_Act : int
VAR_INPUT
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
KS_GetPulse_Act:=0;
IF pwStepDrivePulse_Act_Rd<>0 AND pwStepDrivePulse_Act_Rd_Bak<>0 AND pdiStepDrivePulse_Act <>0 THEN;
ELSE
	KS_GetPulse_Act:=-1;
	RETURN;
END_IF

iStepDrivePulse_Act_Rd:=WORD_TO_INT(pwStepDrivePulse_Act_Rd^);
iStepDrivePulse_Act_Rd_Bak:= WORD_TO_INT(pwStepDrivePulse_Act_Rd_Bak^);

IF iStepDrivePulse_Act_Rd <> iStepDrivePulse_Act_Rd_Bak THEN
	iDeltaPulse:=(iStepDrivePulse_Act_Rd-iStepDrivePulse_Act_Rd_Bak);
	pdiStepDrivePulse_Act^:=pdiStepDrivePulse_Act^+iDeltaPulse;
ELSE;
END_IF

pwStepDrivePulse_Act_Rd_Bak^:=INT_TO_WORD(iStepDrivePulse_Act_Rd);(*保存上个周期的值*)