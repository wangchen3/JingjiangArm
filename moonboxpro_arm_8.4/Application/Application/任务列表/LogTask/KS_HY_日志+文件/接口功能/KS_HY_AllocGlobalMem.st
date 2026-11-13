(*@CES
Name=KS_HY_AllocGlobalMem
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=11b74300-b4dc-4b42-bc03-7b37d7588a0c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_HY_AllocGlobalMem : DWORD
(* 该POU建议放在系统事件PrepareStart中调用 *)
VAR_IN_OUT
	EventPrm: CmpApp.EVTPARAM_CmpApp;
END_VAR
VAR
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;

(* 用于文件保存时搬运的内存区域
/ 全局内存操作小于1M区域的都可以复用这个内存
*)
IF g_dwMem1MB=0 THEN
	g_dwMem1MB:= SysMemAlloc(16#100000);
END_IF


(* 火眼系统日志队列申请
/ 目前结构体中的读写索引是按照BYTE(0~255)值域覆盖范围申请数组大小的
/ 如果后续要改变数组大小/需要留意对指针索引的保护处理
*)
IF g_pstStHYLogFifo=0 THEN
	g_pstStHYLogFifo:= SysMemAlloc(SIZEOF(g_pstStHYLogFifo^));
END_IF

(* 2025.8.27.160700/han.dp
/ 增加的火眼只发数据队列内存申请
*)
IF g_pstStUdpOnlySendFifo=0 THEN
	g_pstStUdpOnlySendFifo:= SysMemAlloc(SIZEOF(g_pstStUdpOnlySendFifo^));
END_IF
KS_initStUdpOnlySendFifo(g_pstStUdpOnlySendFifo);

KS_HY_AllocGlobalMem:= INT_TO_DWORD(iResult);
