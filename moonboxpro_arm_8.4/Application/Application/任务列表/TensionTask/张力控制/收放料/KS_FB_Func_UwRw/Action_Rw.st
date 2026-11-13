(*@CES
Name=Action_Rw
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=892cf5d8-fb4b-4643-b363-29f7e8fa5306
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
fbKS_FB_Func_Rw(
	i_xEn:= TRUE, 
	i_iGrpId:= i_iGrpId, 
	i_rVel_Film:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film, 
	i_rVel_Max:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Max, 
	i_rAI_Swing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Rw, 
	i_xIsDebugMode:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebugMode_Machine, 
	i_xEstop_Input:= i_pstStEvtReq^.xEvt_Estop, 
	i_xStop_Input:= i_pstStEvtReq^.xEvt_Stop, 
	i_xMachineRev:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMachineRev, 
	i_xFlag_Print:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print, 
	i_xFlag_Tension:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension, 
	i_xFlag_EStop:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop, 
	i_xFlag_EStoping:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping, 
	i_xFlag_Stoping:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stoping, 
	i_xFlag_FastStoping:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FastStoping, 
	i_xFlag_Accing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing, 
	i_xFlag_Decing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing, 
	i_iCustomerNameId:= i_pstStSysParam^.stStSysParam_Save.iCustomerId, 
	i_xEnCodeErr:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Rw, 
	i_iCycleTime_Plc:= gc_TENSION_TSK_CYCLE_TIME, 
	i_pstStEvtReq:= ADR(stStEvtReq_Rw),  
	i_pbyNeedAutomaticCut_UwRw:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byNeedAutomaticCut_UwRw), 
	//2026.05.20.213840 替换为输入输出了
	//i_astStTimeSet_DnCut_UpCut:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].astStTimeSet_DnCut_UpCut_Uw,  

	i_pstStIOMap_Rw:= ADR(g_astStIOMap_UwRw_FE_Rw[i_iId_Rw_IO]), 
	i_pstStSysParam:= i_pstStSysParam,//ADR(g_stStSysParam), 
	i_xInverterCW := xInverterCW_RW,// : BOOL;
	i_rVel_Stiffen:= rVel_Stiffen_Rw,
(*2025.8.23.090905*)
	i_iGrpAxisNum_Pu:= i_iGrpAxisNum_Pu,
	i_aiGrpAxisList:= i_aiGrpAxisList,	
	o_xSts_PreCutting=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_PreCutting_Rw, 
//	o_xFlag_CutEnd=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Rw, 
	o_rDiam_NewVol=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDiam_NewVol_Rw, 
//	o_rVel_Predrv=> g_stStSysParam.astStGrpParam_UnSave[i_iGrpId].rVel_PreDrv_Rw, 
	o_rVelRPM_Cur=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVelRPM_Cur_Rw, 
	o_rStep=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rForwardStep_Rw, 
	o_rPi_Value=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_Rw, 
	o_rTotalPiValue=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTotalPiValue_Rw, 
	io_xCutOnTop:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCutterOnTop_Rw, 
//	io_xCurAxisA:= BIT_TO_BOOL(g_stStSysParam.astStGrpParam_Save[iGrp].wUwRwAxisProf.1), 
	io_rDiamCurAxis:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiamCurAxis_Rw, 
	io_byKalmanFilterType:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byKalmanFilterType_Rw, 
	io_byStructParanInitEn:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byStructParanInitEn_Rw,
	//2026.05.20.213935+
	io_astStTimeSet_DnCut_UpCut:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].astStTimeSet_DnCut_UpCut_Rw,
	io_stStTimeSet_DnCut_UpCut_Hmi:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].stStTimeSet_DnCut_UpCut_Rw_Hmi

 );

