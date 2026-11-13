(*@CES
Name=Action_Tension
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=230c9f8d-dc37-4ee1-8684-475fb631e82a
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*交换卷径和速度功能块*)
fbKS_FB_Exchange
(
	i_xCut_end:= xFlag_Cut_end_Out,//pstStGrpParam^.xFlag_Cut_end_Uw,
	io_rDiam_Cur:= io_rDiamCurAxis,//pstStGrpParam^.lrDiamCurAxis_Uw,
	io_rDiam_New:= o_rDiam_NewVol,//pstStGrpParam^.lrDiam_NewVol_Uw,
	io_rVel_UwRw:= o_rVelRPM_Cur,//pstStGrpParam^.lrVel_Uw,
	io_rVel_PreDrv:= rVel_Predrv_Out//pstStGrpParam^.lrVel_Predrv_Uw
);

(*先处理摆臂陷波2025.5.12.113026*)
IF rWn_In=0 THEN
	rWn_In:= 1;
END_IF
IF rBw_In=0 THEN
	rBw_In:=2;
END_IF
IF rDp_In=0 THEN
	rDp_In:= 5;
END_IF
IF i_iCycleTime_Plc=0 THEN
	i_iCycleTime_Plc:= 20;
END_IF
IF i_rVel_Film>=10 THEN
	AntiNotch(
		i_rAI_Swing(*i_rU*),
		ADR(rAntiNotch_Out_Uw)(*i_prYout*),
		rWn_In(*i_rWn*),
		rBw_In(*i_rBw*),
		rDp_In(*i_rDp*),
		INT_TO_REAL(i_iCycleTime_Plc)/1000.0(*i_rTs*),
		ADR(arAntiNotchU_Uk_Uw)(*i_prUk*),
		ADR(arAntiNotchU_Yk_Uw)(*i_prYk*));
ELSE
	SysMemSet(ADR(arAntiNotchU_Uk_Uw),0,SIZEOF(arAntiNotchU_Uk_Uw));
	SysMemSet(ADR(arAntiNotchU_Yk_Uw),0,SIZEOF(arAntiNotchU_Yk_Uw));		
END_IF
(*处理PID值*)
(*PID处理这里增加伪随机*)
(*伪随机pid按钮设置@2024.05.13.155017*)
IF xPseudoRandomEn_In AND byPseudoRandomId_In=1 THEN(*放料处于伪随机测试*)
	IF bySetTestPid_In_Out=1 THEN(*第一组pid*)
		arK_pid_In[1]:=aiTestKp_In[1];
		arK_pid_In[3]:=aiTestKd_In[1];
	ELSIF bySetTestPid_In_Out=2 THEN(*第二组pid*)
		arK_pid_In[1]:=aiTestKp_In[2];
		arK_pid_In[3]:=aiTestKd_In[2];
	ELSIF bySetTestPid_In_Out=3 THEN(*第三组pid*)
		arK_pid_In[1]:=aiTestKp_In[3];
		arK_pid_In[3]:=aiTestKd_In[3];
	END_IF
END_IF
bySetTestPid_In_Out:=0;

fbKS_FB_GetKpid(
	i_xEn:= TRUE, 
	i_xCutFinish:= xFlag_Cut_end_Out, 
	i_iCycleTime_Plc:= i_iCycleTime_Plc, 
	i_rInitP:= arK_pid_In[1], 
	i_rInitI:= arK_pid_In[2], 
	i_rInitD:= arK_pid_In[3], 
	i_rDia_Cur:= io_rDiamCurAxis, 
	i_rThresholdCoeff:= 0.1, 
	i_xFlag_Cut_End:= xFlag_Cut_end_Out, 
	i_xCutDneResetPidEn:= xCutDneResetPidEn_In, 
	i_piCutDneResetPidMultiple:= piCutDneResetPidMultiple_In, 
	i_iCutDneResetPidRemainTime:= iCutDneResetPidRemainTime_In, 
	i_iCutDneResetPidToDefaultTime:= iCutDneResetPidToDefaultTime_In, 
	i_xSmallDiaMulEn:= xSmallDiaMulEn_In, 
	i_iSmallDiaMulSa:= iSmallDiaMulSa_In, 
	i_iSmallDiaMulEd:= iSmallDiaMulEd_In, 
	i_iSmallDiaMulSa_Coeff:= iSmallDiaMulSa_Coeff_In, 
	i_iSmallDiaMulEd_Coeff:= iSmallDiaMulEd_Coeff_In, 
	i_xPseudoRandomTsting:= xPseudoRandomTsting_In, 
	o_xEno=> , 
	o_iErNo=> , 
	o_rKp=> arKpid_Use_Out[1], 
	o_rKi=> arKpid_Use_Out[2], 
	o_rKd=> arKpid_Use_Out[3]);

(*卷径估计-转速补偿放这里*)
Action_Compensate();



(*张力调整处理*)
(*2024.9.10.121941 陷波处理*)
IF xUseAntiNotch_In THEN
	rAI_Uw_TensionCtl:=rAntiNotch_Out_Uw;
ELSE
	rAI_Uw_TensionCtl:=i_rAI_Swing;
END_IF

IF i_rVel_Film=0 THEN
	o_rVelRPM_Cur:= i_rVel_Stiffen;
END_IF

fbKS_FB_UwRw_TensionCTL(
	i_xEn:= TRUE, 
	i_xIsDebugMode:= i_xIsDebugMode, 
	i_xNegative_PiValue:= FALSE, 
	i_xMachineRev:= i_xMachineRev, 
	i_xCutPressed:= i_pstStEvtReq^.xOutCutCylinder_Up OR i_pstStEvtReq^.xOutCutCylinder_Dn, 
	i_xCancelPWhenCut:= i_pstStEvtReq^.xOutCutter_Up OR i_pstStEvtReq^.xOutCutter_Dn, 
	i_rVel_Film:= i_rVel_Film, 
	i_rAI:= rAI_Uw_TensionCtl, 
	i_prVel_AxisCur:= ADR(o_rVelRPM_Cur), 
	i_rKp:= arKpid_Use_Out[1], 
	i_rKi:= arKpid_Use_Out[2], 
	i_rKd:= arKpid_Use_Out[3], 
	i_iCycleTime_Plc:= i_iCycleTime_Plc, 
	i_xAccDecingCompensateEn:= xAccDecingCompensateEn, 
	i_rFeedforwordValue_Uw:= 0, 
	i_iCut_PIInput_Time:= UINT_TO_INT(uiPiDelayWhenCut_In), 
	i_rDeltaW_RPMIN:= 0, 
	i_rSpliceCompensate:= rSpliceCompensate, 
	i_rMailVel:= rMainVel, 
	i_rDiamCurAxis:= io_rDiamCurAxis, 
	o_xEn=> , 
	o_iErNo=> , 
	o_rStep=> o_rStep, 
	o_rPi_Value=> o_rPi_Value, 
	o_rTotalPiValue=> o_rTotalPiValue);
	

(*一些数据赋初值@2023.12.11.153048*)
IF rKc_In_Out=0 THEN(*下面强制写成负值了@2024.05.14.081813*)
	rKc_In_Out:=-0.12;
END_IF
IF rKc_AccDec_In_Out=0 THEN
	rKc_AccDec_In_Out:=-0.08;(*加减速时候的系数值@2024.05.13.182046*)
END_IF
IF uiUseTime_Diam_Min_In_Out=0 THEN
	uiUseTime_Diam_Min_In_Out:=300;(*使用时变的最小卷径|mm@2024.05.14.080937*)
END_IF
IF rR_K_LQR_In_Out=0 THEN
	rR_K_LQR_In_Out:=10;
END_IF
IF rN_LQR_In_Out=0 THEN
	rN_LQR_In_Out:=10;
END_IF
IF rR_K_MinBeat_In_Out=0 THEN
	rR_K_MinBeat_In_Out:=10;
END_IF
IF iN_MinBeat_In_Out=0 THEN
	iN_MinBeat_In_Out:=10;
END_IF

(*2024.8.21.165652 使用放牵速度作为主速度-否则安装主机速度*)
IF xUseFeedVel_In THEN
	rVelTmp:=rVel_Feed_In;
	IF rVelTmp<0 THEN
		rVelTmp:=0;
	END_IF
ELSE
	rVelTmp:= i_rVel_Film;
END_IF

	
fbKS_FB_UwRw_Tension_2024(
	i_xEn:= TRUE, 
	i_byTensionUsePos:= 1, 
	i_xTensionCompensateEn:= xTensionCompensateEn_In OR i_xIsDebugMode, 
	i_xCanTensionCompensate:= i_xIsDebugMode OR (i_xFlag_Print AND
						i_rVel_Film>=30 AND
						xFlag_RollerPressAtLeast1_In AND
						NOT i_xIsDebugMode AND
						NOT xPseudoRandomEn_In),(*伪随机未使能才能使用@2024.06.05.105718*)
	i_xTensionCompensateEn_Cut:= xTensionCompensateEn_Cut_In, 
	i_xUseDiam_Lp_Cut:= FALSE, 
	i_bySmoothTime_Diam_Cut:= 4, 
	i_byCycleTime_Plc:= INT_TO_BYTE(i_iCycleTime_Plc), 
	i_rAi:= rAI_Uw_TensionCtl, 
	i_rVel_Cur:= rVelTmp, 
	i_rVel_CurAxis:= o_rVelRPM_Cur, 
	i_uiDelayTime_UsePI_Cut:= uiPiDelayWhenCut_In, 
	i_xAccing:= i_xFlag_Accing, 
	i_xDecing:= i_xFlag_Decing, 
	i_xFlag_Cut_end:= xFlag_Cut_end_Out, 
	i_rDiam_mm:= io_rDiamCurAxis, 
	i_rDiam_Lp:= rEstiDia_LowPass, 
	i_rR_K_LQR:= rR_K_LQR_In_Out, 
	i_rN_LQR:= rN_LQR_In_Out, 
	i_rR_K_MinBeat:= rR_K_MinBeat_In_Out, 
	i_iN_MinBeat:= iN_MinBeat_In_Out, 
	i_xUseIMatrix_rX_DARE:= xUseIMatrix_rX_DARE_In, 
	i_xUseTime_Variaition:= xUseTime_Variaition_In, 
	i_uiUseTime_Diam_Min:= uiUseTime_Diam_Min_In_Out, 
	i_xUseTime_b1:= xUseTime_b1_In(**), 
	i_rKc:= rKc_In_Out, 
	i_rKc_AccDec:= rKc_AccDec_In_Out, 
	i_pstInitial_Model_Parameters_Input:= ADR(stModelParam_In_Out), 
	i_pstInvariant_Parameters:= ADR(stInvariant_Parameters_In_Out), 
	i_pstPI_Parameters:= ADR(stPI_Parameters_In_Out), 
	i_pstPI_Parameters_AccDec:= ADR(stPI_Parameters_AccDec_In_Out), 
	i_pstTime_Varying_Parameters_Output:= ADR(stTime_Varying_Parameters_Output), 
	i_xCutRollerPress:= xOutput_CutCylinder,
	o_xEn=> , 
	o_rWuCompensate=> rWuCompensate_Out, 
	o_rWuCompensate_Act=> rWuCompensate_Act_Out, 
	o_iMaxIterateCnt_LQR=> iMaxIterateCnt_LQR, 
	io_byKalmanFilterType:= io_byKalmanFilterType, 
	io_byStructParanInitEn:= io_byStructParanInitEn);
	

(*放料的转速输出值@有一些补偿*)
rVel_CalcVolt:=o_rVelRPM_Cur+
					rWuCompensate_Act_Out;
IF (*i_xFlag_Print*)i_rVel_Film>0  THEN(*印刷时候不允许为负值*)
	IF rVel_CalcVolt<0 THEN
		rVel_CalcVolt:=0;
	END_IF
END_IF
	

