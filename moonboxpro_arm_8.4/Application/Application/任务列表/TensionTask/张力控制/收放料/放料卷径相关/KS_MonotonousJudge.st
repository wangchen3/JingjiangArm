(*@CES
Name=KS_MonotonousJudge
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6cdc04b5-2d23-4378-b909-ce1c66d0515c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_MonotonousJudge : INT(*单调性判断,0代表不存在单调性，1为单调递增，2为单调递减,负值为有错误*)
VAR_INPUT
	i_prData:POINTER TO ARRAY [1..4] OF REAL;(*数组指针*)
	i_byDataNum:BYTE;(*数据个数，以lreal为一个单位*)
END_VAR
VAR
	iN: INT;
	dwDataAdr: DWORD;
END_VAR
{IMPLEMENTATION}
(*输入参数判断*)
KS_MonotonousJudge:=0;
IF i_prData<>0 THEN
	;
ELSE
	KS_MonotonousJudge:=-110;
	RETURN;
END_IF

dwDataAdr:=i_prData;
FOR iN:=1 TO i_byDataNum-1 BY 1 DO(*iN=0 为第一个数据地址*)
	IF i_prData^[iN]<i_prData^[iN+1] THEN
		IF KS_MonotonousJudge=2 THEN(**)
			KS_MonotonousJudge:=0;
			EXIT;
		ELSE
			KS_MonotonousJudge:=1;
		END_IF
	ELSIF i_prData^[iN]>i_prData^[iN+1] THEN
		IF KS_MonotonousJudge=1 THEN(**)
			KS_MonotonousJudge:=0;
			EXIT;
		ELSE
			KS_MonotonousJudge:=2;
		END_IF
	ELSE
		KS_MonotonousJudge:=0;
		EXIT;
	END_IF
END_FOR