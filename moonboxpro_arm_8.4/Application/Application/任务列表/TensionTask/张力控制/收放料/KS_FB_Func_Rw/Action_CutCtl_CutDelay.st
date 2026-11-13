(*@CES
Name=Action_CutCtl_CutDelay
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=3edf00f9-4484-4bb3-9753-5f3a48542402
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2021.10.14.142525 增加了接料准备的调试逻辑*)
xCutCtlEn:=xFlag_PreDrv_end_Out AND o_xSts_PreCutting;
rDiam_NewVol_Use:=o_rDiam_NewVol;
rVel_Predrv_Use:= rVel_Predrv_Out;
IF xAxisDebugEn_In_Out THEN(*放料调试*)
	(*2022.6.18.124949 更新了裁切功能块使能条件|确保到达对射电眼位置*)
	xCutCtlEn:=xLamp_PreDrive_Debug AND xSts_ArmFall_end AND o_xSts_PreCutting;(*预驱同步了就使能*)
	IF xCutAxisA_In_Out THEN(*当前轴为a|取b的值*)
		rDiam_NewVol_Use:=LREAL_TO_REAL(INT_TO_LREAL(iDebugGirthmm_AxisB_In)/gc_lrPi);
		rVel_Predrv_Use:=rDebugCurVelmpmAxisB_In_Out;
	ELSE(*当前轴为b|取a的值*)
		rDiam_NewVol_Use:=LREAL_TO_REAL(INT_TO_LREAL(iDebugGirthmm_AxisA_In)/gc_lrPi);
		rVel_Predrv_Use:=rDebugCurVelmpmAxisA_In_Out;
	END_IF
END_IF


(*2018.08.16.91726 | niu.j | 修改收料裁切方式，由计圈改为固定时间*)
fbKS_FB_CutDelay_CTL_Rw(
	i_xEn:= xCutCtlEn, (*预驱完成且裁切未完成*)
	i_xReq_Cut:= fbRTrig_Cut.Q,
	i_lrDiam_New:= rDiam_NewVol_Use(*pstStGrpParam^.lrDiam_NewVol_Rw*),
	lrVel_Predrv:= rVel_Predrv_Use(*pstStGrpParam^.lrVel_Predrv_Uw*),
	i_lrCoef_FilmVolPerimeter:= rCoefCut_FilmVolPerimeter_In,
	i_xUseTime:= TRUE,
	i_lrDelayTimeMs:= iDelayMsec_RollerCylinder_Final,
	i_iCycleTime_Plc:= i_iCycleTime_Plc,
	o_xEno=> ,
	o_xRollerCylinderOutput=> xOutput_CutCylinder,(*由于分上下裁|先把胶辊输出保存到临时变量|han.dp|2018.4.2.171450|*)
	o_xCut_ing=> xFlag_Cut_ing_Out,
	o_iCutTotalTime=>iCutTotalTime(*2022.5.4.170313+这是胶辊的延时还需要加上裁刀的延时时间*));
	IF iCutTotalTime<>0 THEN(*2022.5.4.174048*)
		iCutTotalTime:=iCutTotalTime+iDelayMsec_CutOffKnifeCylinder_Final;
	END_IF

IF io_xCutOnTop THEN
	IF i_pstStEvtReq^.xOutCutCylinder_Up<>xOutput_CutCylinder THEN
		i_pstStEvtReq^.xOutCutCylinder_Up:= xOutput_CutCylinder;
	END_IF

	IF i_pstStEvtReq^.xOutCutter_Up<>xFlag_Cut_ing_Out THEN
		i_pstStEvtReq^.xOutCutter_Up:= xFlag_Cut_ing_Out;
	END_IF
ELSE
	IF i_pstStEvtReq^.xOutCutCylinder_Dn<>xOutput_CutCylinder THEN
		i_pstStEvtReq^.xOutCutCylinder_Dn:= xOutput_CutCylinder;
	END_IF

	IF i_pstStEvtReq^.xOutCutter_Dn<>xFlag_Cut_ing_Out THEN
		i_pstStEvtReq^.xOutCutter_Dn:= xFlag_Cut_ing_Out;
	END_IF
END_IF

IF iDelayMsec_CutOffKnifeCylinder_Final=0 THEN
	iDelayMsec_CutOffKnifeCylinder_Final:= 100;
END_IF
fbTon_DelayTimer_CutOffKnifeCylinder(
	IN:= xFlag_Cut_ing_Out,
	PT:= INT_TO_TIME(iDelayMsec_CutOffKnifeCylinder_Final));

IF fbTon_DelayTimer_CutOffKnifeCylinder.Q THEN
	xFlag_Cut_ing_Out:= FALSE;
	xFlag_Cut_end_Out:= TRUE;
	xCutAxisA_In_Out:= NOT xCutAxisA_In_Out; (*把轴换了*)


	(*2019.5.10.135749|niu.j|收料裁切记米清零*)
	IF xCutAxisA_In_Out THEN
		alrPrnLen_FilmVel_In_Out[1]:= 0; (*A轴计长从0开始*)
		alrPrnLen_PTPos_In_Out[1]:= 0; (*A轴计长从0开始*)
		alrPrnLen_FilmCnt_In_Out[1]:= 0; (*A轴计长从0开始*)
		alrPrnLen_In_Out[1]:= 0;
	ELSE
		alrPrnLen_FilmVel_In_Out[2]:= 0; (*B轴计长从0开始*)
		alrPrnLen_PTPos_In_Out[2]:= 0; (*B轴计长从0开始*)
		alrPrnLen_FilmCnt_In_Out[2]:= 0; (*B轴计长从0开始*)
		alrPrnLen_In_Out[2]:= 0;
	END_IF

	xExChange:= TRUE;
END_IF

(*2024.01.19.132832|在KS_FB_GrpCentralizedProc_UserFunc任务中要使用@获取到信号后自己清除*)
IF xFlag_Cut_end_Out THEN(*2024.02.27.125613+*)
	xFlag_Cut_end_UseInOtherPrg_In_Out:= xFlag_Cut_end_Out;
END_IF
