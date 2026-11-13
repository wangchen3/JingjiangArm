(*@CES
Name=Action_CutCtl_PreDrv
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=f4c41288-edc5-4d9a-9e4f-15e1b6582873
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*放料*)
(*2024.05.14.130347 增加预驱减速延时处理*)
(*裁切完成了|延时清除预驱使能标志*)
IF xTell_KS_PreDrv_CTL_Uw_CuttDne_In(*pstStGrpParam^.xFlag_Cut_end_Uw*) THEN(*这个标志在下面会清除*)
	xPreDelayEn:=TRUE;
END_IF
fbPreDelayEnTon_Uw(IN:=xPreDelayEn,PT:=UINT_TO_TIME(uiPreStopDelayTime_ms_In));(*延迟100ms*)
IF fbPreDelayEnTon_Uw.Q THEN
	xPreDelayEn:=FALSE;
	fbPreDelayEnTon_Uw(IN:=FALSE);
END_IF


IF iPreRevLenth_MM_Cutted_In=0 THEN
	iPreRevLenth_MM_Cutted_In:=1000;
END_IF

IF iPreRevVel_RPM_Cutted_In=0 THEN
	iPreRevVel_RPM_Cutted_In:=100;
END_IF
IF iTime_PreDrvAcc_In=0 THEN
	iTime_PreDrvAcc_In:=8;
END_IF
IF iTime_PreDrvDec_In=0 THEN
	iTime_PreDrvDec_In:=2;
END_IF


fbKS_FB_PreDrv_CTL(
	(*2024.05.14.130944 增加了xPreEn_Uw标志*)
	i_xEn:= xPreDelayEn OR(xSts_Sensor1Ok AND o_xSts_PreCutting AND xFlag_DiamMeasure_end_Out),
	i_lrVel_Film:= i_rVel_Film,
	i_diTime_Acc_PreDrv:= iTime_PreDrvAcc_In,
	i_iTime_Cycle:= i_iCycleTime_Plc,
	i_lrVel_Max:= i_rVel_Max,
	i_lrCoef_PreDrv:= 1,
	i_xoCutter:= xTell_KS_PreDrv_CTL_Uw_CuttDne_In,
	i_xPreRev_Cutted:= xFlag_CCW_AfterCutted_In,
	i_iPreRevLenth_MM_Cutted:= iPreRevLenth_MM_Cutted_In,
	i_iPreRevVel_MPM_Cutted:= iPreRevVel_RPM_Cutted_In,
	i_iPre_DecTime:= iTime_PreDrvDec_In,
	i_xBtnPreDrvStartOrStop:=,(*2021.5.7.103545 增加预驱轴的启停控制*)
	i_uiMaxVel_UseCalcAcc:=LREAL_TO_UINT(i_rVel_Max),(*2024.04.12.183151+@预取部分还是按照系统最大速度处理*)
	io_rVel_PreDrv:= rVel_Predrv_Out,
	o_xEno=> ,
	o_xIng_PreDrv=> xFlag_PreDrv_ing_Out,
	o_xDone_PreDrv=> xFlag_PreDrv_end_Out,
	o_xPreDrvAxis_Releasing=> xPreDrvAxis_Releasing_Out );

