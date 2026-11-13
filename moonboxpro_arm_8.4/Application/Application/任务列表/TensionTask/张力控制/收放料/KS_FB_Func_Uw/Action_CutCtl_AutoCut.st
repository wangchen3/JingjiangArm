(*@CES
Name=Action_CutCtl_AutoCut
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=8ef63a4a-d990-48d4-ab1c-3852416fc2cd
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
	byNeedAutomaticCut_UwRw=1(*i_xBtnTrig_Hmi*),
	byNeedAutomaticCut_UwRw=10 AND xOpenAutomaticCutEnTips(*i_xConfirOpen*),
	byNeedAutomaticCut_UwRw=11 AND xOpenAutomaticCutEnTips(*i_xCancelTipsTrig*),
	ADR(xAutomaticCutEn_In)(*i_pxFlag_En*),
	ADR(xOpenAutomaticCutEnTips)(*i_pxTipsDisPlay*));

fbKS_FB_AutoMaticCut_Uw(
	i_xFlag_CanAutoMaticCut:= i_xFlag_Print AND i_rVel_Film>=30
								AND (NOT i_xFlag_Estoping)
								AND (NOT i_xFlag_Stoping)
								AND (NOT i_xFlag_Faststoping), 
	i_xAutoMaticCutEn:= xAutomaticCutEn_In, 
	i_byAutoMaticCutMode:= byAutoMaticCutMode_In, 
	i_uiAutoMaticCutMeters:= uiAutoMaticCutMeters_In, 
	i_uiAutoMaticCutDia:= uiAutoMaticCutDia_In, 
	i_xCutUseReflectionSensor:= xCutUseReflectionSensor_In, 
	i_xEvenning:= NOT(i_xFlag_Accing OR i_xFlag_Decing) AND i_rVel_Film<>0,
	i_xFlag_Precutting:= o_xSts_Precutting, 
	i_xCutEnd:= xFlag_Cut_end_Out, 
	i_xPreDrvDone:= xFlag_PreDrv_end_Out, 
	i_xCutHolderFallDone:= xSts_ArmFall_end, 
	i_rVel_Cur:= i_rVel_Film, 
	i_rDia_Cur:= io_rDiamCurAxis, 
	i_rDia_Paper:= rDia_PaperRoller_In, 
	i_rFilmThickNess:= rFilmThickNess, 
	i_xEnCodeFailed:= xEnCodeFailed_In_Out, 
	i_prActRemainFilmLenth:= ADR(rActRemainFilmLenth_In_Out), 
	i_iCutTotalTime:= iCutTotalTime, 
	i_iDiam_TowerMove:= REAL_TO_INT(rDiamAlarm_In), 
	i_iAdvanceTipsDeltaDiam:= 50, 
	o_xAutoMaticCutTrig_Precut=> xAutoMaticCutTrig_Precut, 
	o_xAutoMaticCutTrig_CutCancel=> xAutoMaticCutTrig_CutCancel, 
	o_xAutoMaticCutTrig_Cut=> xAutoMaticCutTrig_Cut, 
	o_xFlag_AutoMaticCutting=> xFlag_AutoMaticCutting_Out, 
	o_xFlag_AutoMaticPreCuting=> , 
	o_xFlag_AutoMaticCutDone=> , 
	o_xLampAutoMaticCutting=> xLampAutoMaticCutting, 
	o_rRemainFilmLenth=> , 
	o_rRemainDia_Cur=> o_rRemainDia_Cur,//g_arRemainDia_Cur[i_iGrp], 
	o_rRemainValue_CurType=> rAutoMaticCuttingLenth_CurMode_Out, 
	o_xWillAutoMaticPreCut=> xWillAutoMaticPreCut_Out);