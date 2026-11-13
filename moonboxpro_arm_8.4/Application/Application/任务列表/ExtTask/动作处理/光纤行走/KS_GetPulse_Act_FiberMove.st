(*@CES
Name=KS_GetPulse_Act_FiberMove
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=818a40ae-341c-4bba-98a0-66ac06ec5a73
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetPulse_Act_FiberMove : int
VAR_INPUT
	pwStepDrivePulse_Act_Rd :POINTER TO WORD;(*读取到的脉冲数*)
	pwStepDrivePulse_Act_Rd_Bak:POINTER TO WORD;(*上个周期读到的脉冲数*)
	pdiStepDrivePulse_Act:POINTER TO DINT;(*实际走的脉冲数*)
END_VAR
VAR
    wCurr: WORD;
    wPrev: WORD;
    iDelta: INT;
    CONST_CYCLE: INT := 4000;
    CONST_HALF: INT := 2000;
END_VAR

{IMPLEMENTATION}
KS_GetPulse_Act_FiberMove := 0;

IF pwStepDrivePulse_Act_Rd = 0 OR pwStepDrivePulse_Act_Rd_Bak = 0 OR pdiStepDrivePulse_Act = 0 THEN
    KS_GetPulse_Act_FiberMove := -1;
    RETURN;
END_IF

wCurr := pwStepDrivePulse_Act_Rd^;
wPrev := pwStepDrivePulse_Act_Rd_Bak^;

// 计算原始差值
iDelta := WORD_TO_INT(wCurr) - WORD_TO_INT(wPrev);

// 处理跨圈
IF iDelta > CONST_HALF THEN
    iDelta := iDelta -CONST_CYCLE;
ELSIF iDelta < -CONST_HALF THEN
    iDelta := iDelta + CONST_CYCLE;
END_IF

// 累计脉冲
pdiStepDrivePulse_Act^ := pdiStepDrivePulse_Act^ + iDelta;

// 保存上周期值
pwStepDrivePulse_Act_Rd_Bak^ := wCurr;