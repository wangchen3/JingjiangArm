(*@CES
Name=Action_Uw
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=4490b613-5737-4689-a40d-907293f97e4e
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
fbKS_FB_Func_Uw(
	i_xEn:= TRUE, 
	i_iGrpId:= i_iGrpId, 
	i_rVel_Film:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film, 
	i_rVel_Max:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Max, 
	i_rAI_Swing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Uw, 
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
	i_xEnCodeErr:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Uw, 
	i_xClrAlarmInf:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtnClrAlarmInf, 
	i_iCycleTime_Plc:= gc_TENSION_TSK_CYCLE_TIME, 
	i_pstStEvtReq:= ADR(stStEvtReq_Uw), 
	i_pbyNeedAutomaticCut_UwRw:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byNeedAutomaticCut_UwRw), 
	//2026.05.20.213840 替换为输入输出了
	//i_astStTimeSet_DnCut_UpCut:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].astStTimeSet_DnCut_UpCut_Uw, 

	i_pstStIOMap_Uw:= ADR(g_astStIOMap_UwRw_FE_Uw[i_iId_Uw_IO]), 
	i_pstStSysParam:= i_pstStSysParam,//ADR(g_stStSysParam), 
	i_xInverterCW := xInverterCW_UW,// : BOOL;
	i_rVel_Stiffen:= rVel_Stiffen_Uw,
//2026.5.9.195247接料放主任务
	i_pxReq_Cut_Uw:= ADR(g_axReqCut_Uw[i_iGrpId]),
//2026.05.25.132313
	i_pxFlag_Cut_end_Uw_UseInOtherPrg:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw_UseInOtherPrg),
	i_pxFlag_Cut_ing_Uw_UseInOtherPrg:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_ing_Uw_UseInOtherPrg),
	o_xEn=> , 
	o_iErNo=> , 
	o_rStep=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rForwardStep_Uw, 
	o_rPi_Value=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_Uw, 
	o_rTotalPiValue=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTotalPiValue_Uw, 
	o_xSts_PreCutting=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_PreCutting_Uw, 
//	o_xFlag_CutEnd=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw, 
	o_rDiam_NewVol=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDiam_NewVol_Uw, 
//	o_rVel_Predrv=> g_stStSysParam.astStGrpParam_UnSave[i_iGrpId].rVel_PreDrv_Uw, 
	o_rVelRPM_Cur=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVelRPM_Cur_Uw, 
	o_xUwVolDiamMeasurementFailed=> i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xUwVolDiamMeasurementFailed, 
	o_rRemainDia_Cur=>g_arRemainDia_Cur[i_iGrpId], 
	io_xCutOnTop:= g_stStSysParam.astStGrpParam_UnSave[i_iGrpId].xCutterOnTop_Uw, 
//	io_wUwRwAxisProf:= (g_stStSysParam.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf), 
	io_rDiamCurAxis:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiamCurAxis_Uw, 
	io_byKalmanFilterType:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byKalmanFilterType_Uw, 
	io_byStructParanInitEn:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byStructParanInitEn_Uw,
	io_alrStdVol_Diam_Axis_Hmi:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].alrStdVol_Diam_Axis_Hmi,//	: ARRAY [1..4] OF LREAL;(* 标准卷径值| *)
	io_alrStdVol_Volt_Axis_Hmi:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].alrStdVol_Volt_Axis_Hmi,//	: ARRAY [1..4] OF LREAL;(* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
	io_alrStdVol_Coef_Axis_Hmi:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].alrStdVol_Coef_Axis_Hmi,//	: ARRAY [0..4] OF LREAL;(* 分段系数|2019.1.25.142601|更名A轴|[0]表<=1,[1]表>1&& <=2,[2]表>2&& <=3,[3]表>3&& <=4,[4]表>4 *)

	//2026.05.20.213935+
	io_astStTimeSet_DnCut_UpCut:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].astStTimeSet_DnCut_UpCut_Uw,
	io_stStTimeSet_DnCut_UpCut_Hmi:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].stStTimeSet_DnCut_UpCut_Uw_Hmi
	);
		

