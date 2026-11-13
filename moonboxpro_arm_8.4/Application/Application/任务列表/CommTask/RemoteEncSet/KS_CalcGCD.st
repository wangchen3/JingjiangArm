(*@CES
Name=KS_CalcGCD
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2443a29b-db8f-4374-ad32-0269145bb8f6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcGCD : DWORD
(*计算最大公约数 by liu.yt*)
(*0代表未找到|出现死循环@最大10000*)
VAR_INPUT
	i_dwA:DWORD;
	i_dwB:DWORD;
END_VAR
VAR
	dwA:DWORD;
	dwB:DWORD;
	dwResult:DWORD;
	iCntNum:INT:=0;(*循环计数 防止死循环*)
	xNotFind: BOOL;
END_VAR

{IMPLEMENTATION}
dwA:=i_dwA;
dwB:=i_dwB;
IF (dwA = 0) THEN
	dwResult:=dwB;
ELSIF(dwB = 0) THEN
	dwResult:=dwB;
ELSE
	WHILE(dwB <> 0) DO
		dwResult:=dwB;
		dwB:=dwA MOD dwB;
		dwA:=dwResult;
		(*2025.12.11.172123+*)
		iCntNum:=iCntNum+1;
		IF iCntNum>=10000 THEN
			xNotFind:=TRUE;
			EXIT;
		END_IF
	END_WHILE
	(*未找到强制写0*)
	IF xNotFind THEN
		dwResult:=0;
	ELSE(*找到了*)
		dwResult:=dwA;
	END_IF
END_IF
KS_CalcGCD:=dwResult;

