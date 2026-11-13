(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=5f5bb4d1-2adc-4849-8364-9675506e77c2
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*fbKS_FB_DIAMONDS_Output(
	i_xEn:= , 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pstStParam_Diamonds_WrRd:= ADR(stStParam_Diamonds_WrRd), 
	i_pstStRd_PhaseRead:= ADR(stStParam_Diamonds_WrRd.stStRd_PhaseRead),
	i_pstStWrRd_SysCfg:= ADR(stStWrRd_SysCfg),
	i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct),
	o_xEn=> , 
	o_iErNo=> 
);
2026.5.29.145541*)

IF NOT xLocal2Remote THEN(*未向金刚同步数据*)
	fbKS_FB_DIAMONDS_Output(
		i_xEn:= , 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pstStParam_Diamonds_WrRd:= ADR(stStParam_Diamonds_WrRd), 
		i_pstStRd_PhaseRead:= ADR(stStParam_Diamonds_WrRd.stStRd_PhaseRead),
		i_pstStWrRd_SysCfg:= ADR(stStWrRd_SysCfg),
		i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct),
		o_xEn=> , 
		o_iErNo=> 
	);
	(*更新备值@金刚下来的数据更新到备份中。不会触发输入的比较*)
	SysMemCpy(
			ADR(stStParam_Diamonds_WrRd_Bak),
			ADR(stStParam_Diamonds_WrRd),
			SIZEOF(stStParam_Diamonds_WrRd_Bak));		
END_IF


	