(*@CES
Name=Action_CutCtl_AutoCut
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=0f7889b4-7d20-4f2f-acf9-04c5a97d50d0
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
rFilmThickNess:= rFilmThickNess_In;
(*2024.02.23.100704 为了防止自动接料打开引起异常增加提示处理函数*)
(*获取操作标志@收放料都在使用|在收料使用结束后清零*)
byNeedAutomaticCut_UwRw:=0;
IF i_pbyNeedAutomaticCut_UwRw<>0 THEN
	byNeedAutomaticCut_UwRw:=i_pbyNeedAutomaticCut_UwRw^;
END_IF

(*光栅不打开,不响应界面输入@dwControlComplexBits.14 代表取消光栅保护*)
IF xFlag_CancelSafetyGrating_In THEN
	byNeedAutomaticCut_UwRw:=0;
	(*并强制关闭收放料使能使能*)
	xAutomaticCutEn_In:=FALSE;
END_IF

KS_ButtonTipsDeal(
	NOT i_xFlag_Print(*i_xCanSet*),
	byNeedAutomaticCut_UwRw=2(*i_xBtnTrig_Hmi*),
	byNeedAutomaticCut_UwRw=10 AND xOpenAutomaticCutEnTips(*i_xConfirOpen*),
	byNeedAutomaticCut_UwRw=11 AND xOpenAutomaticCutEnTips(*i_xCancelTipsTrig*),
	ADR(xAutomaticCutEn_In)(*i_pxFlag_En*),
	ADR(xOpenAutomaticCutEnTips)(*i_pxTipsDisPlay*));
IF i_pbyNeedAutomaticCut_UwRw<>0 THEN
	i_pbyNeedAutomaticCut_UwRw^:=0;
END_IF
fbKS_FB_AutoMaticCut_Rw(
	i_xFlag_CanAutoMaticCut:= i_xFlag_Print AND i_rVel_Film>=30
								AND (NOT i_xFlag_Estoping)
								AND (NOT i_xFlag_Stoping)
								AND (NOT i_xFlag_Faststoping), 
	i_xAutoMaticCutEn:= xAutomaticCutEn_In, 
	i_byAutoMaticCutMode:= byAutoMaticCutMode_In, 
	i_uiAutoMaticCutMeters:= uiAutoMaticCutMeters_In, 
	i_uiAutoMaticCutDia_Rw:= uiAutoMaticCutDia_In, 
	i_xFlag_Precutting_Uw:= xFlag_Precutting_Uw_In, 
	i_xCutEnd_Uw:= xFlag_Cut_end_Out, 
	i_xFlag_Precutting_Rw:= o_xSts_Precutting, 
	i_xCutEnd_Rw:= xFlag_Cut_end_Out, 
	i_xPreDrvDone_Rw:= xFlag_PreDrv_end_Out, 
	i_xCutHolderFallDone_Rw:= xSts_ArmFall_end, 
	i_rVel_Cur:= i_rVel_Film, 
	i_rDia_Cur:= io_rDiamCurAxis, 
	i_lrTotalPrnLenth:= alrPrnLen_In_Out[3], 
	i_xEnCodeFailed:= xEnCodeFailed_In_Out, 
	i_iCutTotalTime:= iCutTotalTime, 
	i_uiTimeCutHolderDne_ms:= INT_TO_UINT(iDelayMsec_CutterHolder_Final), 
	i_xWillAutoMaticPreCut_Uw:= xWillAutoMaticPreCut_Uw_In, 
	i_iAdvanceTipsDeltaMeters:= 300, 
	o_xAutoMaticCutTrig_Precut=> xAutoMaticCutTrig_Precut, 
	o_xAutoMaticCutTrig_CutCancel=> xAutoMaticCutTrig_CutCancel, 
	o_xAutoMaticCutTrig_Cut=> xAutoMaticCutTrig_Cut, 
	o_xFlag_AutoMaticCutting=> xFlag_AutoMaticCutting_Out, 
	o_xFlag_AutoMaticPreCuting=> , 
	o_xFlag_AutoMaticCutDone=> , 
	o_byFlag_AutoMaticCutting=> , 
	o_xLampAutoMaticCutting=> xLampAutoMaticCutting, 
	o_rLenth_CurType=> rAutoMaticCuttingLenth_CurMode_Rw_Out, 
	o_xWillAutoMaticPreCut=> , 
	io_xGetLenthMachine:= xGetLenthMachine_In_Out, 
	io_byLenth_Machine:= byLenth_Machine_In_Out);
	

