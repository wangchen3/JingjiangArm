(*@CES
Name=Action_Output_SysCfg_Rd
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=909f7ab4-d978-4471-a9da-dbc7dc5fbb7a
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
SysMemCpy(
	i_pstStWrRd_SysCfg,
	ADR(i_pstStParam_Diamonds_WrRd^.stStWrRd_SysCfg),
	SIZEOF(i_pstStWrRd_SysCfg^)
	);
fbKS_FB_DIAMONDS_SysCfg_WrRd(
	i_xEn:= TRUE, 
	i_xWr:= FALSE, 
	i_xRd:= TRUE, 
	i_iStationNum:= g_stStStationInfo_KS.iStationNum, 
	i_pstStWrRd_SysCfg:= i_pstStWrRd_SysCfg, 
	i_pstStSysCfgStruct:= i_pstStSysCfgStruct, 
	i_paiStationId_List:= ADR(g_stStStationInfo_KS.aiStationId_List));	
IF i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xBtn_UpdateSysCfg THEN
	i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xBtn_UpdateSysCfg:= FALSE;

	g_xBtn_UpdateSysCfg:=TRUE;

END_IF