(*@CES
Name=KS_GetRollerLapNum
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=210a5565-37cb-46b1-9af4-75dae064d683
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetRollerLapNum : BOOL(*获取轴的运转圈数@使用虚拟码盘计数*)
VAR_INPUT
	i_iVirEncPPR:INT;(*虚拟码盘参数@一圈对应多个脉冲@默认8000*)
	i_wvirtualCnt: WORD; (* 虚拟码盘计数 @0--i_iVirEncPPR-1*)
	i_pwLastvirtualCnt: POINTER TO WORD; (* 虚拟码盘计数备份 @0--i_iVirEncPPR-1*)
	i_pbyLapNum: POINTER TO BYTE;(*计算的圈数值*)
END_VAR
VAR
	byLapNum: BYTE;
	wLastvirtualCnt: WORD;
END_VAR
{IMPLEMENTATION}
IF i_pbyLapNum<>0 THEN
	byLapNum:=i_pbyLapNum^;
END_IF
IF i_pwLastvirtualCnt<>0 THEN
	wLastvirtualCnt:=i_pwLastvirtualCnt^;
END_IF

IF i_wvirtualCnt<wLastvirtualCnt THEN(*如果当前值突然比前一个值小了,就认为过圈了*)
	byLapNum:=byLapNum+1;
END_IF
wLastvirtualCnt:=i_wvirtualCnt;

IF i_pbyLapNum<>0 THEN
	i_pbyLapNum^:=byLapNum;
END_IF
IF i_pwLastvirtualCnt<>0 THEN
	i_pwLastvirtualCnt^:=wLastvirtualCnt;
END_IF