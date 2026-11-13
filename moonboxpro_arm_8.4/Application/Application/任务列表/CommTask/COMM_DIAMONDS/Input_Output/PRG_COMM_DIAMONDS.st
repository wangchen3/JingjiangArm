(*@CES
Name=PRG_COMM_DIAMONDS
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=363878d7-2f1d-44a1-b392-82fad9b0c498
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
PROGRAM PRG_COMM_DIAMONDS
VAR
	fbKS_FB_COMM_DIAMONDS: KS_FB_COMM_DIAMONDS;(*和金刚的lan通讯处理*)
	fbKS_FB_MEASURE_DUT: KS_FB_MEASURE_DUT;(*2025.7.24.174005*)
	xMesureGlobalDUT_: BOOL := FALSE;

(*测试用例中使用的变量/2025.8.5.194602/han.dp
	dwDlen_regs: DWORD;
	dwN: DWORD;
	puiRegs: POINTER TO UINT;
*)
	stStParam_Diamonds_Wr: StParam_Diamonds_Wr;
	stStParam_Diamonds_WrRd: StParam_Diamonds_WrRd;
	stStWrRd_SysCfg: StWrRd_SysCfg;
	fbKS_FB_DIAMONDS_Input: KS_FB_DIAMONDS_Input;
	fbKS_FB_DIAMONDS_Output: KS_FB_DIAMONDS_Output;
	dwSizeWr: DWORD;
	dwSizeWrRd: DWORD;
	
	iCaseId : INT;
	iCaseId_Pre : INT;	
	xInit:BOOL;
	fbKS_FB_DIAMONDS_Input_WRRD: KS_FB_DIAMONDS_Input_WRRD;
	dwResult: DWORD;	
	(*2026.5.28.124614 + 处理双向通讯可能存在写入不生效问题  by liu.yt*)
	xLocal2Remote:BOOL;	
	stStParam_Diamonds_WrRd_Bak: StParam_Diamonds_WrRd;
	(*2026.06.01.202622 处理联动按钮主从、主->金刚通讯互斥问题 by liu.yt*)
	//axSwitch_Linkage_Lo:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
END_VAR

{IMPLEMENTATION}
(*以下是测试代码/在测试用例工程中
没有全局数据的申请/以下是对全局数据的空间申请

IF g_pstStParam_Diamonds_WrRd<>0 THEN;
ELSE
	g_pstStParam_Diamonds_WrRd:= sysmemalloc(SIZEOF(g_pstStParam_Diamonds_WrRd^));

	dwDlen_regs:= SIZEOF(g_pstStParam_Diamonds_WrRd^)/2;
	FOR dwN:=1 TO dwDlen_regs BY 1 DO
		puiRegs:= g_pstStParam_Diamonds_WrRd+dwN*2;
		puiRegs^:= bswap_16(DWORD_TO_UINT(dwN));
	END_FOR
END_IF
IF g_pstStParam_Diamonds_Wr<>0 THEN;
ELSE
	g_pstStParam_Diamonds_Wr:= sysmemalloc(SIZEOF(g_pstStParam_Diamonds_Wr^));
END_IF
*)
//2026.5.26.212323初始化时候赋值一次
IF NOT xInit THEN
	xInit:= TRUE;
	Action_Init();
END_IF
Action_Input();
Action_Act();
Action_Output();

dwSizeWr:= SIZEOF(stStParam_Diamonds_Wr);
dwSizeWrRd:= SIZEOF(stStParam_Diamonds_WrRd);