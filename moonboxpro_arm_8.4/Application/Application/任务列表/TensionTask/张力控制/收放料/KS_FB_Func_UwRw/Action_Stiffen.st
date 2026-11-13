(*@CES
Name=Action_Stiffen
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=731ffc97-6387-4f26-aeb5-9a44e04aff31
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
	
	i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byCoef_stiffen_Rw:= 10;
IF NOT g_StiffenTest THEN
	fbKS_FB_Stiffen(
		i_xEn:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film = 0, 
		i_xDebugMode:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebugMode_Machine, 
		i_lrAI_Uw:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Uw, 
		i_lrAI_Rw:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Rw, 
		i_lrAI_If:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_If, 
		i_lrAI_Of:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Of, 
		i_xRollerSts_If:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_If, 
		i_xRollerSts_Of:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_Of, 
		i_lrThreshold_Stiffen:= 0.5, 
		i_prVel_Uw:= ADR(rVel_Stiffen_Uw), 
		i_prVel_Rw:= ADR(rVel_Stiffen_Rw),  
		i_xMachineRev:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMachineRev, 
		i_xCancelTenEn:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCancelTenEn, 
		i_lrFilmVel:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film, 
		i_xFlag_Print:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print, 
		i_lrDiamCurAxis_Uw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiamCurAxis_Uw, 
		i_lrDiamCurAxis_Rw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiamCurAxis_Rw, 
		i_iInitial_speed_Uw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byInitialSpd_Stiffen_Uw, 
		i_iInitial_speed_Rw:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byInitialSpd_Stiffen_Rw, 
		i_iwindCoff:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byCoef_stiffen_Uw, 
		i_iUnwindCoff:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byCoef_stiffen_Rw, 
		i_iCycleTime_Plc:= gc_TENSION_TSK_CYCLE_TIME, 
		o_xEno=> , 
		o_iErNo=> , 
		o_xStiffenDone=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_TensionDone, 
		o_xZeroServo_Uw=> , 
		o_xForeward_Uw=> xInverterCW_UW, 
		o_xZeroServo_Rw=> , 
		o_xForeward_Rw=> xInverterCW_RW,
		o_lrAIMax_Uw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_Uw,
		o_lrAIMin_Uw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_Uw,
		o_lrAIMax_Rw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_Rw,
		o_lrAIMin_Rw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_Rw,
		o_lrAIMin_If=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_If,
		o_lrAIMax_If=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_If,
		o_lrAIMin_Of=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_Of,
		o_lrAIMax_Of=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_Of
		
	);

//2026.5.14.102441增加支持单边解除张力，没有该功能的这里输入TRUE吧	
	IF NOT i_pstStIOMap_Uw^.i_xOperation_UWRW THEN
		xInverterCW_UW:= FALSE;
		rVel_Stiffen_Uw:= 0;
	END_IF
	IF NOT i_pstStIOMap_Rw^.i_xOperation_UWRW THEN
		xInverterCW_RW:= FALSE;
		rVel_Stiffen_Rw:= 0;
	END_IF
	
ELSE
	
(*2026.3.23.145810 中卷标定测试区间周期数，大卷验证-PID各项按比率乘系数——收放卷一起*)
	fbKS_FB_StiffenTestNew(
		i_xEn:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film = 0, 
		i_xDebugMode:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebugMode_Machine, 
		i_lrAI_Uw:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Uw, 
		i_lrAI_Rw:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Rw, 
		i_lrAI_If:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_If, 
		i_lrAI_Of:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Of, 
		i_xRollerSts_If:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_If, 
		i_xRollerSts_Of:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_Of, 
		i_lrThreshold_Stiffen:= 0.5, 
		i_iCycleTime_Plc:= gc_TENSION_TSK_CYCLE_TIME, 
		
		o_xEno=> , 
		o_iErNo=> , 
		o_xStiffenDone=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_TensionDone, 
		o_xZeroServo_Uw=> , 
		o_xForeward_Uw=> xInverterCW_UW, 
		o_xZeroServo_Rw=> , 
		o_xForeward_Rw=> xInverterCW_RW,
		o_lrAIMax_Uw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_Uw,
		o_lrAIMin_Uw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_Uw,
		o_lrAIMax_Rw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_Rw,
		o_lrAIMin_Rw=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_Rw,
		o_lrAIMin_If=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_If,
		o_lrAIMax_If=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_If,
		o_lrAIMin_Of=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMin_Of,
		o_lrAIMax_Of=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAIMax_Of,
		o_lrUwShaftSpeed_RPM=> rVel_Stiffen_Uw, (* 输出给放料轴的转速 *)
		o_lrRwShaftSpeed_RPM=> rVel_Stiffen_Rw (* 输出给收料轴的转速 *)
	);
//2026.5.14.102441增加支持单边解除张力，没有该功能的这里输入TRUE吧	
	IF NOT i_pstStIOMap_Uw^.i_xOperation_UWRW THEN
		xInverterCW_UW:= FALSE;
		rVel_Stiffen_Uw:= 0;
	END_IF
	IF NOT i_pstStIOMap_Rw^.i_xOperation_UWRW THEN
		xInverterCW_RW:= FALSE;
		rVel_Stiffen_Rw:= 0;
	END_IF
	
END_IF

i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_HMI_Uw := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Uw;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_HMI_Rw := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Rw;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_HMI_If := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_If;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_HMI_Of := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Of;
	
		