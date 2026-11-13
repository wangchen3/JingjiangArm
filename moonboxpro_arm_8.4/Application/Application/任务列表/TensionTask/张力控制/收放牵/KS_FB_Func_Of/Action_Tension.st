(*@CES
Name=Action_Tension
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a2ef1874-5174-4c10-b660-570935e1f927
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
iCycleNum_Delay:= 10000/i_iCycleTime_Plc;(*10s*)
iCycleNum_AI_Ave:= 1000/i_iCycleTime_Plc;(*1s算一次*)
fbKS_FB_CalcGirthLogic(
	i_xEn:= TRUE, 
	i_xMachineRev:= i_xMachineRev, 
	i_xNegative:= FALSE, 
	i_rVel_Film:= i_rVel_Film, 
	i_iCycleTime_Plc:= i_iCycleTime_Plc, 
	i_rAnalogLimit:= 0.1, 
	i_rAxisVel_Cur:= rVel_Cur_Out, 
	i_rAi_Swing:= i_rAi_Swing, 
	i_rActualGirth:= rActualGirth_In, 
	i_xRollerPressDone:= xRollerPressDone_In, 
	i_xSwitchTension:= xSwitchTension_In, 
	i_xAccing:= xFlag_Accing_In, 
	i_xDecing:= xFlag_Decing_In, 
	i_xCompensateWhenAccing:= xCompensateWhenAccing_In, 
	i_rCompensateGirthWhenAccing:= rCompensateGirthWhenAccing_In, 
	i_iCycleNum_Delay:= iCycleNum_Delay, 
	i_iCycleNum_AI_Ave:= iCycleNum_AI_Ave, 
	o_xEno=> , 
	o_iErNo=> , 
	o_xGirthCalFinish=> xGirthCalFinish_Out, 
	o_rUsingGirth=> rUsingGirth_Out
);

fbKS_FB_Tension(
	//2026.04.09.201333 替换输入
	//i_xEn:= TRUE, 
	//i_xCanAdjEn:= xRollerSts_IfOf_In AND xFlag_RollerPressAtLeast1_In AND (NOT xGirthCalFinish_Out), 
	i_xEn:= xRollerSts_IfOf_In AND xFlag_RollerPressAtLeast1_In, 
	i_xCanAdjEn:=  (NOT xGirthCalFinish_Out), 
	i_xIsDebugMode:= i_xIsDebugMode, 
	i_xNegative_PiValue:= TRUE, 
	i_xMachineRev:= i_xMachineRev, 
	i_rAI_Swing:= i_rAI_Swing, 
	i_rVel_Film:= i_rVel_Film, 
	i_xFilmAccDecDone:= xFilmAccDecDone_In, 
	i_iTimeTo0WhenDisEn:= iTimeTo0WhenDisEn_In, 
	i_iCycleTime_Plc:= i_iCycleTime_Plc, 
	i_rKp:= arKpid_IfOf_In[1], 
	i_rKi:= arKpid_IfOf_In[2], 
	i_rKd:= arKpid_IfOf_In[3], 
	i_byVelLimit_PerCent:= byVelLimit_PerCent_In, 
	i_xFeedlimitWarnFlag:= xFeedlimitWarnFlag_In, 
	i_iFeedLimitWarnCoff:= iFeedLimitWarnCoff_In, 
	i_rUsingGirth:= rUsingGirth_Out, 
	i_xAdjustMode:= xSwitchTension_In, 
	i_rGirth_Input:= rActualGirth_In, 
	i_iVel_Max:= REAL_TO_INT(i_rVel_Max), 
	i_uiMaxVel_UseCalcAcc:= uiMaxVel_UseCalcAcc_In, 
	i_xPseudoRandomId:= xPseudoRandomId_In, 
	i_xPseudoRandomEn:= xPseudoRandomEn_In, 
	i_xPseudoRandomTsting:= xPseudoRandomTsting_In, 
	i_rPseudoRandomRoundAmplitude_Cur:= rPseudoRandomRoundAmplitude_Cur_In, 
	i_pbySetTestPid:= ADR(bySetTestPid_In_Out), 
	i_iPseudoRandomRound_Kp_1:= aiTestKp_In[1], 
	i_iPseudoRandomRound_Kd_1:= aiTestKd_In[1], 
	i_iPseudoRandomRound_Kp_2:= aiTestKp_In[2], 
	i_iPseudoRandomRound_Kd_2:= aiTestKd_In[2], 
	i_iPseudoRandomRound_Kp_3:= aiTestKp_In[3], 
	i_iPseudoRandomRound_Kd_3:= aiTestKd_In[3], 
	i_xPidType:= xPidType_In, 
	i_xUseAntiNotch:= xUseAntiNotch_In, 
	i_prWn:= ADR(rWn_In_Out), 
	i_prBw:= ADR(rBw_In_Out), 
	i_prDp:= ADR(rDp_In_Out), 
	i_xEn_Disturbance:= xEn_Disturbance_In, 
	i_rFreq_Disturbance:= rFreq_Disturbance_In, 
	i_rAmplitude_Disturbance:= rAmplitude_Disturbance_In, 
	i_uiTotalTime_Disturbance:= uiTotalTime_Disturbance_In, 	
	i_xRollerSts_Pu:= xFlag_RollerPressAtLeast1_In,
	o_xEno=> , 
	o_iErNo=> , 
	o_rVel=> rVel_Cur_Out, 
	o_rPi_Value=> rPi_Value_Out, 
	o_rForwardStep=> rForwardStep_Out, 
	o_rVel_rpm=> rVel_rpm_Out, 
	o_xOuting_sin=> xOuting_sin_Out, 
	o_rResult_sin=> rResult_sin_Out
);