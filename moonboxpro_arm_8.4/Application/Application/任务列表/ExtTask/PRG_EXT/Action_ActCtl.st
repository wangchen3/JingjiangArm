(*@CES
Name=Action_ActCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=20c6962b-a686-4592-b1ef-7e98f2b28301
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}


(*动作流程处理*)


FOR iGrp:=1 TO 2 BY 1 DO(*循环2个系处理一下*)

	IF iGrp=2 THEN
		EXIT;
	END_IF
aliTimeTest[1]:= LTIME();	
	afbKS_FB_SpecialFun[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_iCustomerName:= g_stStSysParam.stStSysParam_Save.iCustomerId, 
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
		i_pastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE),
		i_pstStIOMap_UwRw_FE_Uw:= ADR(g_astStIOMap_UwRw_FE_Uw),  
		i_pstStIOMap_UwRw_FE_Rw:= ADR(g_astStIOMap_UwRw_FE_Rw), 
		i_iIOGrpIdx_Uw:= aiIOGrpIdx_Uw[iGrp], 
		i_iIOGrpIdx_Rw:= aiIOGrpIdx_Rw[iGrp], 
		i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
		i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
		i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]),
		i_pstStSysParam:= ADR(g_stStSysParam),
		i_pastStInteraction := ADR(g_astStInteraction),
		i_pstStSysStationInf:=ADR(g_stStSysStationInf),
		i_pastStGetMotionSts:= ADR(g_astStGetMotionSts) 
		);
	afbKS_FB_GrpUserActionCtrl[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iCustomerName:=g_stStSysParam.stStSysParam_Save.iCustomerId , 
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
		i_pastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
		i_pstStIOMap_UwRw_FE_Uw:= ADR(g_astStIOMap_UwRw_FE_Uw), 
		i_pstStIOMap_UwRw_FE_Rw:= ADR(g_astStIOMap_UwRw_FE_Rw), 
		i_iIOGrpIdx_Uw:= aiIOGrpIdx_Uw[iGrp], 
		i_iIOGrpIdx_Rw:= aiIOGrpIdx_Rw[iGrp], 
		i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
		i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
		i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
		i_xInverterAlarm:= , 
		i_xBrakeFilm:= , 
		i_xLostPressure:= , 
		i_xPrnRollerLoose_AtLeast1:= , 
		i_xNeedEstop_BrakeAlarm:= , 
		i_paxCommVel_Sure:= ADR(g_axCommVel_Sure), 
		i_xFalg_ExhaustEn:= , 
		i_prVel_Tar_HMI:= ADR(g_stStSysParam.astStGrpParam_Save[iGrp].rVel_Tar), 
		i_pxTapPosition_Breaking:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xTapPosition_Breaking), 
		i_pxTapPosition_Printing:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xTapPosition_Printing), 
		i_pxTapPosition_UniformInk:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xTapPosition_UniformInk), 
		i_pxAutoAccDec_Hmi:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xAutoAccDec_Hmi), 
		i_arVel_CommonlyUsed:= g_stStSysParam.astStGrpParam_Save[iGrp].arVel_Usr, 
		i_xFalg_ExhaustLimitStart:= , 
		i_rVel_Cur:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rVel_Cur, 
		i_rVel_Ink:= g_stStSysParam.astStGrpParam_Save[iGrp].rVel_Ink, 
		i_xFlag_TensionDone:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_TensionDone, 
		i_xFlag_TensionUnfinished:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_TensionUnfinished, 
		i_xFlag_LinkageAxisAlarm:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_LinkageAxisAlarm, 
		i_uiMaxVel_UseCalcAcc:= g_stStSysParam.stStSysParam_Save.uiMaxVel_UseCalcAcc, 
		i_pxFlag_KeepAlarming:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_KeepAlarming), 
		i_iTime_Stop:= g_stStSysParam.astStGrpParam_Save[iGrp].iTime_Stop, 
		i_iTime_FastStop:=  g_stStSysParam.astStGrpParam_Save[iGrp].iTime_FastStop, 
		i_iTime_Estop:=  g_stStSysParam.astStGrpParam_Save[iGrp].iTime_Estop, 
		i_iTime_AutoAcc:=  g_stStSysParam.astStGrpParam_Save[iGrp].iTime_AutoAcc, 
		i_iTime_AutoDec:=  g_stStSysParam.astStGrpParam_Save[iGrp].iTime_AutoDec, 
		i_iTime_ManuAcc:=  g_stStSysParam.astStGrpParam_Save[iGrp].iTime_ManuAcc, 
		i_iTime_ManuDec:=  g_stStSysParam.astStGrpParam_Save[iGrp].iTime_ManuDec, 
		i_xFilmAccDecDone:=  g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_FilmAccDecDone, 
		i_byAutoAccDecCurve:= g_stStSysParam.astStGrpParam_Save[iGrp].byAutoAccDecCurve, 
		i_iTime_S:= g_stStSysParam.astStGrpParam_Save[iGrp].iTime_S, 
		i_iTime_S_End:= g_stStSysParam.astStGrpParam_Save[iGrp].iTime_S_End, 
		i_rVel_Max:= g_stStSysParam.astStGrpParam_Save[iGrp].rVel_Max, 
		i_prAccDecTime_ThisTime:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].rAccDecTime_ThisTime), 
		i_rAux_enc_vel:= LREAL_TO_REAL(g_alrVel_VirtualAxis[iGrp]), 	//2025.11.03.103620 | bai.zy | TEST_1103
//		i_rAux_enc_vel:= LREAL_TO_REAL(g_astMotionSts[g_iAxisNum_All+g_stStSysParam.stStSysParam_Save.iUnitMaxNum + 1].lrVel_Prf/2), 	//bai.zy | Test_ 临时使用,
//		i_pxFlag_FilmAccDecDone:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_FilmAccDecDone), 
		i_xUseMaxTimeAsSBegin_InLowSpeed:= g_stStSysParam.stStSysParam_Save.xUseMaxTimeAsSBegin_InLowSpeed,
		i_rSpeed_SCoeff_Type789:= g_stStSysParam.stStSysParam_Save.rSpeed_SCoeff_Type789,
		o_xEn=> , 
		o_iErNo=> , 
		o_xSpeedHigh=> , 
		o_byActionCtlWay=> g_abyActionCtlWay[iGrp], 
		//2026.06.04.144406
		o_xFlag_FastStoppBtnDn=>g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_FastStopBtnDn,
		o_xTips_ExhausLimitStart=> , 
		o_xTowerInvAlarm_Uw=> , 
		o_xTowerInvAlarm_Rw=> , 
		o_iIdGSE=> , 
		o_xFlag_Stop=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Stop, 
		o_xFlag_PreStart=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_PreStart, 
		o_xFlag_PreStart_Print=> axFlag_PreStart_Print[iGrp], 
		o_xFlag_Ink=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Ink, 
		o_xFlag_InkAccing=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_InkAccing, 
		o_xFlag_Tension=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Tension, 
		o_xFlag_Print=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Print, 
		o_xFlag_Estop=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Estop, 
		o_xFlag_AutoAcc=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_AutoAcc, 
		o_xFlag_AutoDec=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_AutoDec, 
		o_xFlag_ManuAcc=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_ManuAcc, 
		o_xFlag_ManuDec=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_ManuDec, 
		o_xFlag_Accing=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Accing, 
		o_xFlag_Decing=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Decing, 
		o_xFlag_EStoping=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_EStoping, 
		o_xFlag_Stoping=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Stoping, 
		o_xFlag_FastStoping=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_FastStoping, 
		o_xLinkage_IfOf_Ink=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xLinkage_IfOf_Ink, 
		o_xTensionNotFinish=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_TensionUnfinished, 		
		o_xToPrintVelTooHigh=> , 
		o_rFinalVelocity=> g_stStSysParam.astStGrpParam_UnSave[iGrp].rFinalVelocity, 
		o_iTimeSec_AccDec_AllTheWay=> g_stStSysParam.astStGrpParam_UnSave[iGrp].iTimeSec_AccDec_AllTheWay, 
		o_iTimeSec_AccDec_AllTheWay_0_1s=> , 
		o_xVel_Tar_OverRange=> , 
		o_xFlag_ArrivedToTargetVel=> , 
		o_diVel_Virtual_Tar=> g_adiVel_Virtual_Tar[iGrp], 
		o_lrMax_a_S_pos=> g_alrMax_a_S_pos[iGrp], 
		o_lrTime_S=> g_alrTime_S[iGrp], 
		o_lrJerk_SBegin=> g_alrJerk_SBegin[iGrp],
		o_lrJerk_SEnd=> g_alrJerk_SEnd[iGrp],
//		o_rVel_Film=> g_stStSysParam.astStGrpParam_UnSave[iGrp].rVel_Film, 
		o_rVel_PrnRoller=> g_arVel_PrnRoller[iGrp], 
		o_rVel_NetRoller=> g_arVel_NetRoller[iGrp], 
		o_rVel_BottomRoller=> g_arVel_BottomRoller[iGrp], 
		o_rVel_Cur_HMI=> g_stStSysParam.astStGrpParam_UnSave[iGrp].rVel_Cur_HMI, 
		io_xMotionEnabled:= g_axMotionEnabled[iGrp]);
		IF g_alrJerk_SBegin[1]=0 THEN
			g_alrJerk_SBegin[1]:= 1;
		END_IF
		IF g_alrJerk_SEnd[1]=0 THEN
			g_alrJerk_SEnd[1]:= 1;
		END_IF
//2026.1.19.154949		
// 	IF axFlag_PreStart_Print[iGrp] AND (NOT	g_axMotionEnabled[iGrp]) THEN
// 		g_axMotionEnabled[iGrp]:= TRUE;
// 	END_IF
	afbKS_FB_GrpAxisLinkageCtrl[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
		i_iMaxVel_StsSwitch:= 600, 
		i_xChangLinkageStsWhenPrint:= g_stStSysParam.stStSysParam_Save.xChangLinkageStsWhenPrint, 
		o_xEno=> , 
		o_iErNo=> , 
		o_xFlag_LinkageAtleast1=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_LinkageAtleast1Axis
	);	
(*压辊处理*)

	afbKS_FB_RollerPressCTL_Home[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
		i_iAxisId_If:= aiIOGrpIdx_If[iGrp], 
		i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp], 
		i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
		i_xMachineRev:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xMachineRev, 
		i_iCycle_Time:= gc_EXT_TSK_CYCLE_TIME, 
		i_xPressRollerDne_Of_WhenTensionIn:= g_xPressRollerDne_Of_WhenTensionIn,
		i_xUnPressTop_EstopBtn:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Estop OR g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_EStoping, 
		i_xUnPressTop_AllUnPressBtn:= g_xUnPressTop_AllUnPressBtn, 
		i_xClearUnPressSignal_OnTop:= g_xClearUnPressFlag, 
		i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME, 
		i_byActionCtlWay:= g_abyActionCtlWay[iGrp], 
		i_pastStInteraction := ADR(g_astStInteraction),
		o_xEno=> , 
		o_xRollerPressDone=>g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_RollerPressDone//axRollerPressDone[iGrp]// 
	);
// 	IF g_stStSysParam.stStSysParam_Save.iCustomerId=CUSTOMERNAME_CHAOXU OR g_stStSysParam.stStSysParam_Save.iCustomerId=CUSTOMERNAME_QINHUA THEN
// 		;
// 	ELSE
// 		g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_RollerPressDone:= axRollerPressDone[iGrp];
// 	END_IF
	afbKS_FB_GetPressDneFlag[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_pastStIOMap_Main_FE:=  ADR(g_astStIOMap_Main_FE), 
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
		i_paxFlag_PressDne:= ADR(g_axFlag_PressDne), 
		i_pxFlag_PressDne_If:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xRollerSts_If), 
		i_pxFlag_PressDne_Of:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xRollerSts_Of), 
		i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME, 
		i_iAxisId_If:= aiIOGrpIdx_If[iGrp],
		i_iAxisId_Of:= aiIOGrpIdx_Of[iGrp],
		
		o_xEn=> , 
		o_xRollerStsDn_AtLeast1=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_RollerPressAtLeast1
	);	

	
		(*等料长和让料头处理*)
	afbKS_FB_AvoidSomeFilmWithoutAdjust[iGrp](
		i_xEn:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Print, 
		i_iGrpId:= iGrp, 
		i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_pastStIOMap_AxisBasic:= ADR(g_astStIOMap_Axis_FE), 
		i_xWaitFilmLenthEn:= g_stStSysParam.astStGrpParam_Save[iGrp].xSwitch_WaitFilmLengthEn,//g_stStSysParam.astStGrpParam_Save[iGrp].wCtlSwitchRef.4, 
		i_xGiveupHeaderEn:= g_stStSysParam.astStGrpParam_Save[iGrp].xSwitch_GiveupHeaderEn,//g_stStSysParam.astStGrpParam_Save[iGrp].wCtlSwitchRef.15, 
		i_iGrpLinkageAxisNum_Pu:= iGrpLinkageAxisNum_Pu, 
		i_aiGrpLinkageAxisList:= aiGrpLinkageAxisList, 
		i_xWaitFilmLenth_From1stLinkageAxis:= g_stStSysParam.astStGrpParam_Save[iGrp].xSwitch_WaitFilmLengthEn_From1st, 
		i_xStartAutoFind:= g_axStartAutoFind[iGrp], 
		i_xFlag_Cut_end_Uw:= g_axTell_KS_FB_AvoidSomeFilmWithoutAdjust_CuttDne[iGrp],//g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Cut_end_Uw, 
		i_iCycleTime_Plc:= gc_EXT_TSK_CYCLE_TIME, 
		i_paxFlag_PressDne:= ADR(g_axFlag_PressDne), 
		o_xEno=> );
		//2026.06.02.224049  获取到 就清零
		g_axTell_KS_FB_AvoidSomeFilmWithoutAdjust_CuttDne[iGrp]:=FALSE;


//xi.hy新增@七号以后
	afbKS_FB_GrpFiberMoveCtl[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpAxisNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu,// iGrpAxisNum_Pu, 
		i_abyGrpAxisList:= g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpAxisList,
		i_pstStSysParam:= ADR(g_stStSysParam),
		i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE));		

// 		
aliTimeTest[2]:= LTIME();	
		
	Action_LampAndAlarmBell();
aliTimeTest[3]:= LTIME();	
	
	Action_Process();
aliTimeTest[4]:= LTIME();	

	(*增加涂布功能处理2025.10.16.144436||niu.j*)
	Action_PreReg();
aliTimeTest[5]:= LTIME();	

	//2025.11.03.103620 | bai.zy | TEST_1103
	Action_Failure();
aliTimeTest[6]:= LTIME();	
	
	
	(*调用|2025.08.21.145451*)
	KS_CalcFilmLenth_ArcAxis(
		i_iGrpId:= iGrp, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_paxFlag_PressDne:= ADR(g_axFlag_PressDne));

//2025.12.01.150642 | 增加套筒处理
KS_ChangeRoller_ValveCTL(ADR(g_astStIOMap_Axis_FE), ADR(g_stStSysParam));		
	
END_FOR
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	g_stStSysParam.astStUnitParam_UnSave[iN].xFlag_PressDn:= g_axFlag_PressDne[iN];
END_FOR
Action_Normal_Reset_HMIBtn();
aliTimeTest[7]:= LTIME();	

aliTimeTest[20]:= aliTimeTest[2]-aliTimeTest[1];	
aliTimeTest[19]:= aliTimeTest[3]-aliTimeTest[2];	
aliTimeTest[18]:= aliTimeTest[4]-aliTimeTest[3];	
aliTimeTest[17]:= aliTimeTest[5]-aliTimeTest[4];	
aliTimeTest[16]:= aliTimeTest[6]-aliTimeTest[5];	
aliTimeTest[15]:= aliTimeTest[7]-aliTimeTest[6];	
