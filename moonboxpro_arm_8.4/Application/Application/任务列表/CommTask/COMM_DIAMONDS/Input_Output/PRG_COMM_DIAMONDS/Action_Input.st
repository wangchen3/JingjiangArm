(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=eb0a867e-6bb1-4d75-9fc1-5bc667cc1ab3
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*fbKS_FB_DIAMONDS_Input(
	i_xEn:= TRUE, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pstStParam_Diamonds_Wr:= ADR(stStParam_Diamonds_Wr), 
	i_pstStParam_Diamonds_WrRd:= ADR(stStParam_Diamonds_WrRd), 
	i_pstStWrRd_SysCfg:= ADR(stStWrRd_SysCfg),
	i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct),
	i_pastStGetMotionSts := ADR(g_astStGetMotionSts), 
	
	o_xEn=> , 
	o_iErNo=> 
);

2026.5.29.145521*)

fbKS_FB_DIAMONDS_Input(
	i_xEn:= TRUE, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pstStParam_Diamonds_Wr:= ADR(stStParam_Diamonds_Wr), 
	i_pstStParam_Diamonds_WrRd:= ADR(stStParam_Diamonds_WrRd), 
	i_pstStWrRd_SysCfg:= ADR(stStWrRd_SysCfg),
	i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct),
	i_pastStGetMotionSts := ADR(g_astStGetMotionSts), 
	o_xEn=> , 
	o_iErNo=> 
);



fbKS_FB_DIAMONDS_Input_WRRD(
	i_xEn:= TRUE, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pstStParam_Diamonds_WrRd:= ADR(stStParam_Diamonds_WrRd), 
	i_pstStWrRd_SysCfg:= ADR(stStWrRd_SysCfg),
	i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct),
	o_xEn=> , 
	o_iErNo=> );
	
//检查下天枢有没有数据更新到金刚结构体里@强制更新到金刚
dwResult:= SysMemCmp(
		ADR(stStParam_Diamonds_WrRd_Bak),
		ADR(stStParam_Diamonds_WrRd),
		SIZEOF(stStParam_Diamonds_WrRd_Bak));
IF dwResult<>0 THEN(*说明是天枢做了修改@强制执行按照天枢->金刚@通过置标志不更新金刚->天枢的值*)
	xLocal2Remote:=TRUE;
	(*更新备值*)
	SysMemCpy(
			ADR(stStParam_Diamonds_WrRd_Bak),
			ADR(stStParam_Diamonds_WrRd),
			SIZEOF(stStParam_Diamonds_WrRd_Bak));
ELSE(*更新完成了|复位标志*)
	xLocal2Remote:=FALSE;
END_IF
	