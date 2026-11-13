(*@CES
Name=Action_ACT
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ccee1341-6268-4f89-ad35-5203e2e63559
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

fbKS_FB_FiberMoveCtl(
	i_xEn:=TRUE,
	i_iUnitNum:=i_iGrpAxisNum_Pu,
	i_abyGrpAxisList:=i_abyGrpAxisList,
	i_pastStFiberMoveStepDriver:=ADR(g_astStFiberMoveStepDriver),
	i_rFiberVel:=iFiberVel,
	i_rFiberVel_Fast:=iFiberVel_Fast,
	i_xFlag_Estop:=xFlag_Estop_In,
	i_xFlag_Stop:=xFlag_Stop_In,
	i_xIsDebugMode:=xIsDebugMode,
	i_pxFiberMovePosCal_ByUnit:=pxFiberMovePosCal_ByUnit,
	i_pxFiberMovePosCal_ByOnline:=pxFiberMovePosCal_ByOnline,
	i_arDistanceIn_HMI:=arDistanceIn_HMI,
	i_arWidth_FindMarkCenter:=arWidth_FindMarkCenter,
	i_xUseOnline:=xUseOnline,
	i_rBasePosByOnline:=rBasePosByOnline,
	i_pxFiberMoveDisRunStart_AllUnit:=pxFiberMoveDisRunStart_AllUnit,
	i_rFiberMoveDistance_AllUnit:=rFiberMoveDistance_AllUnit,
	i_pxConfirm_AllUnit:=pxConfirm_AllUnit,
	i_pstStSysParam:= ADR(g_stStSysParam)
);