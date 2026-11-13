(*@CES
Name=KS_GetPhaseValue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4208271a-275a-4ef9-bf83-b8f9c218fcae
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetPhaseValue : INT(*获取相位值@0--7999变化*)
VAR_INPUT
	i_wVirtualCnt:WORD;(*获取的虚拟码盘值0--65535变化*)
	i_iVirEncPPR:INT;(*一圈的脉冲数*)
END_VAR
VAR
	iVirtualCnt: INT;
	iVirtualPan_1Cycle:INT:=8000;
END_VAR
{IMPLEMENTATION}
iVirtualCnt:=WORD_TO_INT(i_wvirtualCnt);
iVirtualPan_1Cycle:=i_iVirEncPPR;
IF iVirtualPan_1Cycle=0 THEN
	iVirtualPan_1Cycle:=8000;
END_IF
IF iVirtualCnt>=0 AND
	iVirtualCnt<=iVirtualPan_1Cycle-1 THEN;
ELSE
	IF iVirtualCnt<0 THEN(*小于0*)
		REPEAT
			iVirtualCnt:=iVirtualCnt+iVirtualPan_1Cycle;
		UNTIL
			iVirtualCnt>=0
		END_REPEAT
	ELSE(*大于0*)
		iVirtualCnt:=iVirtualCnt MOD iVirtualPan_1Cycle;
	END_IF
END_IF
KS_GetPhaseValue:=iVirtualCnt;