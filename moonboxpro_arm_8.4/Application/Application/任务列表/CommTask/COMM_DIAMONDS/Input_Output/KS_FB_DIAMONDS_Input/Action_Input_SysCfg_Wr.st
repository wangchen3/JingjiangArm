(*@CES
Name=Action_Input_SysCfg_Wr
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=d945df21-3750-4729-b76a-1cb208091679
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
fbKS_FB_DIAMONDS_SysCfg_WrRd(
	i_xEn:= TRUE, 
	i_xWr:= TRUE, 
	i_xRd:= FALSE, 
	i_iStationNum:= g_stStStationInfo_KS.iStationNum, 
	i_pstStWrRd_SysCfg:= i_pstStWrRd_SysCfg, 
	i_pstStSysCfgStruct:= i_pstStSysCfgStruct, 
	i_paiStationId_List:= ADR(g_stStStationInfo_KS.aiStationId_List));
	
SysMemCpy(
	ADR(i_pstStParam_Diamonds_WrRd^.stStWrRd_SysCfg),
	i_pstStWrRd_SysCfg,
	SIZEOF(i_pstStWrRd_SysCfg^)
	);