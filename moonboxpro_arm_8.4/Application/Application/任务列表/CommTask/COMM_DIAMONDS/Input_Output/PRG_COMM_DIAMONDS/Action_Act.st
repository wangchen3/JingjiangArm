(*@CES
Name=Action_Act
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=37bb1e5e-fdeb-4f35-8cd7-4b7ebcdf80f2
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*deprecated@2025.8.27.160402/han.dp
内存申请放在 KS_HY_AllocGlobalMem()中实现
IF g_pstStUdpOnlySendFifo<>0 THEN;
ELSE 
	g_pstStUdpOnlySendFifo:= SysMemAlloc(SIZEOF(g_pstStUdpOnlySendFifo^));
	IF g_pstStUdpOnlySendFifo<>0 THEN
		g_pstStUdpOnlySendFifo^.byR:= 0;
		g_pstStUdpOnlySendFifo^.byW:= 0;
	END_IF
END_IF
*)

(*和金刚通讯*)
fbKS_FB_COMM_DIAMONDS(i_xEn:= TRUE, 
	i_xEnableHeartbeat:= TRUE,
	i_xEnableRealtime:= TRUE,
	i_pstStParam_Diamonds_WrRd:= ADR(stStParam_Diamonds_WrRd),
	i_pstStParam_Diamonds_Wr:= ADR(stStParam_Diamonds_Wr),
	i_pstStUdpOnlySendFifo:= g_pstStUdpOnlySendFifo,
	i_pstStHYLogFifo:= g_pstStHYLogFifo,(* 2025.8.27.154847/han.dp/+ *)
	o_xEno=> ,
	o_iErNo=> ,
	o_iCaseId=> iCaseId);
IF iCaseId <> iCaseId_Pre THEN
	KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'COMM_DIAMONDS_CaseId: ', INT_TO_STRING(iCaseId));
	iCaseId_Pre := iCaseId;
END_IF



(*测量dut大小/用来匹配测试的/正式代码不用这部分*)
(*测算一次数据结构的大小/监测用*)
fbKS_FB_MEASURE_DUT(
	i_xEn:= NOT xMesureGlobalDUT_, 
	o_xEno=> , 
	o_iErNo=> , 
	o_MAX_UNIT_NUM=> , 
	o_MAX_STATION_NUM=> , 
	o_dwLen_StParam_Diamonds_Wr=> , 
	o_dwLen_StParam_Diamonds_Wr_Err=> , 
	o_dwLen_StParam_Diamonds_Wr_RdSam=> , 
	o_dwLen_StParam_Diamonds_Wr_RunSts=> , 
	o_dwLen_StParam_Diamonds_Wr_SysSts=> , 
	o_dwLen_StSts_GrpFlag=> , 
	o_dwLen_StSts_Modbus=> , 
	o_dwLen_StSts_PressRoller_Flag=> , 
	o_dwLen_StSts_UnitFlag=> , 
	o_dwLen_StSts_UnitParam=> , 
	o_dwLen_StSts_UnitParam_2=> , 
	o_dwLen_StParam_Diamonds_WrRd=> , 
	o_dwLen_StWrRd_Switch_Grp=> , 
	o_dwLen_StWrRd_Switch_Machine=> , 
	o_dwLen_StWrRd_Switch_Unit=> , 
	o_dwLen_StWrRd_UnitParam=> , 
	o_dwLen_member_stStParam_Diamonds_Wr_SysSts=> , 
	o_dwLen_member_stStParam_Diamonds_Wr_RdSam=> , 
	o_dwLen_member_astStParam_Diamonds_Wr_Err=> , 
	o_dwLen_member_astStParam_Diamonds_Wr_RunSts=> );
xMesureGlobalDUT_:= TRUE;

