(*@CES
Name=KS_PushDataToFifo
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b493b00e-9b49-48fd-b986-2a847e7b8547
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PushDataToFifo : INT(*-1表示错误/>0表示写入的值数量/限制单次写入量1020有效内容*)
VAR_INPUT
	i_xRTdata: BOOL;(*TRUE表示‘RT'类型/FALSE表示'FI'类型*)
	i_pbyMem: POINTER TO BYTE;
	i_iBytesNum: INT;
	i_pstStUdpOnlySendFifo: POINTER TO StUdpOnlySendFifo;
END_VAR
VAR
	iResult: INT:= 0;
	byIdx_w: BYTE;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pbyMem<>0 AND 
	i_iBytesNum>0 AND
	i_pstStUdpOnlySendFifo<>0 THEN
	(*参数合法*)

	byIdx_w:= i_pstStUdpOnlySendFifo^.byW;
	IF i_xRTdata THEN
		i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byIdx_w].uiPkgTyp:= 16#5254;
	ELSE
		i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byIdx_w].uiPkgTyp:= 16#4649;
	END_IF

	iResult:= MIN(SIZEOF(i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byIdx_w].abyMem), i_iBytesNum);
	i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byIdx_w].uiDlen:= INT_TO_UINT(iResult);

	SysMemCpy(
		ADR(i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byIdx_w].abyMem),
		i_pbyMem, 
		i_pstStUdpOnlySendFifo^.astStUdpOnlySend[byIdx_w].uiDlen);
	byIdx_w:= byIdx_w+1;
	i_pstStUdpOnlySendFifo^.byW:= byIdx_w;

ELSE
	iResult:= -1;
END_IF
KS_PushDataToFifo:= iResult;
