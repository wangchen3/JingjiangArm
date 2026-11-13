(*@CES
Name=Action_Init
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a05dd113-9682-4abc-a5de-6b735b5cffeb
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
fbKS_FB_DIAMONDS_Input_WRRD(
	i_xEn:= TRUE, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pstStParam_Diamonds_WrRd:= ADR(stStParam_Diamonds_WrRd), 
	i_pstStWrRd_SysCfg:= ADR(stStWrRd_SysCfg),
	i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct),
	o_xEn=> , 
	o_iErNo=> );
