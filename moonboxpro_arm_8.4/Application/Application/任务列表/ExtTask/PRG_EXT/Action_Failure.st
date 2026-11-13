(*@CES
Name=Action_Failure
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=010d8f24-a9c3-4ccc-8227-15c37e3ab9df
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//2025.10.27.140629 | bai.zy | TEST_
iGrpAllStationNum := g_iAxisNum_All;//g_stStStationInfo_KS.iStationNum; //g_stStRingInfVer1.m_device_num;
FOR iK := 1 TO iGrpAllStationNum BY 1 DO
	aiStationList[iK] := g_aiStationList_All[iK];//g_stStStationInfo_KS.aiStationId_List[iK];//g_stStRingInfVer1.m_station_id_list[iK];
END_FOR

afbKS_FB_GrpFailureProc[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iCycle_Time:= gc_EXT_TSK_CYCLE_TIME, 
	i_byGrpUnitNum:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu, 
	i_abyAxisList:= g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpAxisList, 
	i_iGrpAllStationNum:= iGrpAllStationNum, 
	i_aiStationList:= aiStationList, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pastStGetMotionSts:= ADR(g_astStGetMotionSts), 
	i_pastStAxisIdListInf:= ADR(g_astStAxisIdListInf), 
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
	i_pastStIOMap_AxisExtra:= ADR(g_astStIOMap_Axis_Extra_FE), 
	i_xLostPressure:= , 
	i_xPrnRollerLoose_AtLeast1:= , 
	i_xbrakeResistanceTempHigh_AtLeast1:= , 
	i_xHorzMotorAlarmAtLeastOne:= , 
	i_xEstopBtnDne:= g_astStEvtReq[iGrp].xEvt_Estop, 
	i_xFlag_FastStopBtnDn:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_FastStopBtnDn, 
	i_xTowerInvAlarm_Uw:= , 
	i_xTowerInvAlarm_Rw:= , 
	//2026.08.21.131421
	//2026.08.06.160548 临时报警处理
// 	i_xInverterAlarmCurAxis_Uw:= g_astStIOMap_UwRw_FE_Uw[1].i_xInverterErrorA, 
// 	i_xInverterAlarmCurAxis_Rw:= g_astStIOMap_UwRw_FE_Rw[1].i_xInverterErrorA, 
// 	i_xInverterAlarmPreAxis_Uw:=  g_astStIOMap_UwRw_FE_Uw[1].i_xInverterErrorB, 
// 	i_xInverterAlarmPreAxis_Rw:= g_astStIOMap_UwRw_FE_Rw[1].i_xInverterErrorB, 
	i_xInverterAlarmCurAxis_Uw:= , 
	i_xInverterAlarmCurAxis_Rw:= , 
	i_xInverterAlarmPreAxis_Uw:=  , 
	i_xInverterAlarmPreAxis_Rw:= , 
	i_xInverterAlarm_If:= , 
	i_xInverterAlarm_Of:= , 
	i_xReflectSensorLoss:= , 
	i_iMoveErrCode:= , 
	i_xAlarmHeating:= , 
	i_xFlag_Alarm_LD:= , 
	i_pxFlag_Alarm_Rev_ErrorEnc:=  ADR(g_xAlarm_Rev), 
	i_iAxisId_Alarm_Rev:= , 
	i_xUwVolDiamMeasurementFailed:= , 
	i_dwAvailPhys_kB:= , 
	i_wAvailPhysAlarm_Kb:= , 
	i_xCompensate_Phase_Stop:= , 
	i_xMemAllocFailed:= , 
	i_xNeedRestartPlc:= , 
	i_pstStGetPrm:= ADR(g_stStGetPrm),
	i_pstStSysStationInf:= ADR(g_stStSysStationInf),
	o_xEn=> , 
	o_iErNo=> , 
	o_xInverterErrReset_Uw=> , 
	o_xInverterErrReset_Rw=> , 
	o_xAlarmStillOnline=> , 
	o_xClrAlarmSts=> , 
	io_byAutoBackUpSts:= g_byAutoBackUpSts
);

//2026.03.16.141753 | + | 增加日志打印
afbKS_FB_AlarmDisList[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iUnitNum:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE),  
	i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
	i_pstStIOMap_Uw:= ADR(g_astStIOMap_UwRw_FE_Uw),  
	i_pstStIOMap_Rw:= ADR(g_astStIOMap_UwRw_FE_Rw),
	o_xEn=> );