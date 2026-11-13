(*@CES
Name=Action_Normal_Act_ZeroPID
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=70686969-4fb8-42bc-b896-44183ac4e9c3
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2017.8.25.091452\处理pid对清零的操作|*)
FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum  BY 1 DO
	iStationId:= g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN];(*g_stStRingInf.stationIdList[iN];*)
	iUnitId:= KS_GetAxisIdByStationId(iStationId,g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController);
	//iUnitId:= KS_GetAxisIdByStationId();
	iGrpId:= KS_GetGrpIdByAxisId(iUnitId, ADR(g_stStSysParam), ADR(iAxisTypeId));(*2018.7.29.213902\Refill parameter|*)
	IF (iGrpId=1 OR iGrpId=2) AND
		(iUnitId>=1 AND iUnitId<=MAX_UNIT_NUM) THEN
		pstStGrpParam_Save:= ADR(g_stStSysParam.astStGrpParam_Save[iGrpId]);(*2018.6.10.140215\访问系参数的地址|*)
		pstStGrpParam_UnSave:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrpId]);(*2018.6.10.140215\访问系参数的地址|*)
		pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iUnitId]);
		pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iUnitId]);

		xClrSts:=pstStGrpParam_UnSave^.xFlag_Print AND pstStGrpParam_UnSave^.rVel_Film>=5;(*印刷状态不能清除*)
		xClrSts:=xClrSts OR (pstStGrpParam_UnSave^.xFlag_Ink AND pstStGrpParam_UnSave^.xEnaTestARC_Ink);(*空转调试模式不能清除*)
		xClrSts:=NOT xClrSts;(*取反就是能清除的*)

		IF xClrSts THEN(*2024.05.25.143021+*)
			(*2023.09.04.103231  对于5号命令上传的误差进行滤波用于误差显示*)
			IF iUnitId<=16 AND iUnitId>=2 THEN
				(*2024.7.18.094243处理@套色误差滤波器*)
// 				pfbFilter:=0;
// 				IF g_pstStGlobalVarByAllocMem<>0 THEN
// 					pfbFilter:=ADR(g_pstStGlobalVarByAllocMem^.afbArcErrFilter[iUnitId]);
// 				END_IF
// 
// 				pfbFilter^(
// 					i_xEn:=FALSE,
// 					i_iFiltTimes:=BYTE_TO_INT(pstStUnitParam_Save^.byAve_v_extra),
// 					i_dwDataAdr:=ADR(iError_Curve_Temp_V),
// 					i_byDataType:=TYPE_INT);
// 
// 				(*2024.7.18.093925 修改@加减速补偿滤波器*)
// 				pfbFilter:=0;
// 				IF g_pstStGlobalVarByAllocMem<>0 THEN
// 					pfbFilter:=ADR(g_pstStGlobalVarByAllocMem^.afbDeltaAccelerationFilter[iUnitId]);
// 				END_IF
// 				pfbFilter^(i_xEn:=FALSE);

				FOR iM:=1 TO 20 BY 1 DO
					arDeltaAcceleration_Cur_Delay[iUnitId,iM]:=0;
					IF iM<=3 THEN
						arEk_ArcErr_Lp[iUnitId,iM]:=0;
						arE_DEAL_ArcErr_Lp[iUnitId,iM]:=0;
					END_IF

					IF iM<=5 THEN
						arAcceleration[iUnitId,iM]:=0;
					END_IF
				END_FOR
				abyAccDecCompensate[iUnitId]:=0;
				arAcceleration_Last[iUnitId]:=0;
				arArcVel_LastCycle[iUnitId,1]:=0;(*2024.05.15.160002+*)
				arArcVel_LastCycle[iUnitId,2]:=0;(*2024.05.15.160002+*)
				axDelayCntEn[iUnitId]:=FALSE;
				abyDelayCnt[iUnitId]:=0;
				arTarVel_AccDec[iUnitId]:=0;
				arVel_AccelerationEnd[iUnitId]:=0;

				(*2024.8.1.120345*)
				axFlagCutDne_UseHorCompensate_Uw[iUnitId]:=FALSE;
				axFlagCutDne_UseHorCompensate_Rw[iUnitId]:=FALSE;
				arPrevCycleAcceleration[iUnitId]:=0;(*2024.9.6.102947+*)
				arPrevCycleDeltaAcceleration[iUnitId]:=0;(*2024.9.6.102947+*)
				axTargetValueTo0_En[iUnitId]:=0;(*2024.9.6.102947+*)
				auiCnt_TargetValueTo0_En[iUnitId]:=0;(*2024.9.6.102947+*)
				arTime_TargetValueTo_ms[iUnitId]:=0;(*2024.9.6.132737+*)
				arTargetValue_Cur[iUnitId]:=0;(*2024.9.6.152521+*)
(*				abyTargetValueCnt[iUnitId]:=0;(*2024.9.7.152734+*)*)

				(*2024.8.7.153946+误差传递队列数据清零*)
				IF g_pastAllAxisErrorTransfer<>0 THEN (* 初始化 *)
					KS_InitErrDataList(g_pastAllAxisErrorTransfer, iUnitId);
				END_IF
					afbKS_FB_ARC_PIDAdjust[iUnitId](
						i_byStateOfMotion:= 0, 
						i_byModeOfAdjust:= INT_TO_BYTE(pstStGrpParam_Save^.iWorkMode_Pid),
						i_wErProf:= 16#0303, 
						i_iError_v:= 0, 
						i_iError_h:= 0, 
						i_xAccSpeedFlag:= FALSE, 
						i_lrCurrVelocity:= pstStGrpParam_UnSave^.rVel_Cur,
						i_rMaxAdjustVal:= LREAL_TO_REAL(lrMaxAdjustVal), 
						i_xArcTest:= g_stStSysParam.stStSysParam_Save.xSwitch_ArcTest_V, 
						i_xArcTest_H:= g_stStSysParam.stStSysParam_Save.xSwitch_ArcTest_H, 
						i_rMaxAdjustVal_H:= LREAL_TO_REAL(lrMaxAdjustVal_H), 
						i_rAcceleration_Max:= pstStGrpParam_UnSave^.rAcceleration_Max, 
						i_rAcceleration_Cur:= pstStGrpParam_UnSave^.rAcceleration_Cur, 
						i_byParamIndex:= g_stStSysParam.stStSysParam_Save.byParamIndex_Huang, 
						i_uiControllerVel_Huang:= g_stStSysParam.stStSysParam_Save.uiControllerVel_Huang, 
						i_byFilmType:= pstStGrpParam_Save^.byFilmType, 
						i_pbyKp:= g_apbyKp_Arc[iUnitId], 
						i_pbyKi:= g_apbyKi_Arc[iUnitId], 
						i_pbyKd:= g_apbyKd_Arc[iUnitId], 
						i_iError_Act_v:= 0, 
						i_iCustomId:= g_stStSysParam.stStSysParam_Save.iCustomerId, 
						i_byArcId_Cur:= pstStUnitParam_UnSave^.byColorIdCurrent, 
						i_byArcNum:= pstStGrpParam_UnSave^.byGrpArcAxisNum, 
						i_xFlag_RollerPressDne:= FALSE, 
						i_xInitArcErr_AjdImmediately:= g_stStSysParam.stStSysParam_Save.xInitArcErr_AjdImmediately, 
						i_byUseArcAccOrDecCompensate:= g_stStSysParam.stStSysParam_Save.byUseArcAccOrDecCompensate, 
						i_rTarVel_ThisTime:= pstStGrpParam_UnSave^.rFinalVelocity, 
						i_xFlag_Acc:= pstStGrpParam_UnSave^.xFlag_Accing AND pstStGrpParam_UnSave^.xFlag_AutoAcc, 
						i_xFlag_Dec:= pstStGrpParam_UnSave^.xFlag_Decing AND pstStGrpParam_UnSave^.xFlag_AutoDec, 
						i_rFilmLenth_InUnit:= LREAL_TO_REAL(pstStUnitParam_Save^.lrFilmLengthFromPrevUnit), 
						i_rKp_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rKp_GC, 
						i_rKi_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rKi_GC, 
						i_rKd_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rKd_GC, 
						i_rN_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rN_GC, 
						i_byArcErrLimitToCtl_P:= g_stStSysParam.stStSysParam_Save.byArcErrLimitToCtl_P, 
						i_byArcErrLimitToCtl_I:= g_stStSysParam.stStSysParam_Save.byArcErrLimitToCtl_I, 
						i_xCompensateEn_Hor:= pstStUnitParam_Save^.stStArc_Mol_Param.xCompensateEn_H, 
						i_xCut_Uw:= FALSE, 
						i_xCut_Rw:= FALSE, 
						i_byCompensateValue_Hor:= pstStUnitParam_Save^.stStArc_Mol_Param.byCompensateValue_Hor, 
						i_byMaxAddValue_Total_Hor:= pstStUnitParam_Save^.stStArc_Mol_Param.byMaxAddValue_Total_Hor, 
						i_byKadj_SetType:= g_stStSysParam.stStSysParam_Save.byKadj_SetType, 
						i_rTotalAdjustValue_Act:= LREAL_TO_REAL(lrTotalAdjustValue), 
						i_rFilmLenth_Eyes:= g_stStSysParam.stStSysParam_Save.rFilmLenth_Eyes, 
						i_uiArcSysDelayTime_ms:= g_stStSysParam.stStSysParam_Save.uiArcSysDelayTime_ms, 
						i_byArcPidGetType:= g_stStSysParam.stStSysParam_Save.byArcPidGetType, 
						i_xUseGc_PID_2025:= g_stStSysParam.stStSysParam_Save.xUseGc_PID_2025, 
						i_xFlag_AdjValid_V:= pstStUnitParam_Save^.dwFlag_Sts.0,
						i_xFlag_AdjValid_H:= pstStUnitParam_Save^.dwFlag_Ctl.0 AND pstStUnitParam_Save^.dwFlag_Sts.1,
						i_rDeadzoneMin_H:= pstStUnitParam_Save^.rDeadzoneMin_H, 
						i_rDeadzoneMax_H:= pstStUnitParam_Save^.rDeadzoneMAX_H, 
						i_xWaitFilmLenth_FollowPreU:= pstStUnitParam_Save^.xWaitFilmLenth_FollowPreU, (*后续处理了*)
						i_rGirth_Arc:= pstStUnitParam_Save^.rGirth_Sam, 
						i_iKp_V:= pstStUnitParam_Save^.iKp_V,
						i_iKi_V:= pstStUnitParam_Save^.iKi_V,
						i_iKd_V:= pstStUnitParam_Save^.iKd_V,
						i_iKp_H:= pstStUnitParam_Save^.iKp_H,
						i_iKi_H:= pstStUnitParam_Save^.iKi_H,
						i_iKd_H:= pstStUnitParam_Save^.iKd_H,
						i_iMarkArrangeModal:= pstStUnitParam_Save^.iMarkArrangeMode, 
						i_xAdjREV_V:= pstStUnitParam_Save^.dwFlag_Ctl.4,
						i_xAdjREV_H:= pstStUnitParam_Save^.dwFlag_Ctl.5,
						i_xFollow_1U:= pstStUnitParam_Save^.dwFlag_Sts.10,
						i_xWaitFilmLenth_Follow1U:= pstStUnitParam_Save^.xWaitFilmLenth_Follow1U,
						i_xWaitFilmLength:= pstStUnitParam_Save^.xWaitFilmLength,
						i_stStArc_Mol_Param:= pstStUnitParam_Save^.stStArc_Mol_Param, 
						o_iVResult=> iFinalAdjust_V,
						o_iVKp=> iKp_InUse,
						o_iVKi=> iKi_InUse,
						o_iVKd=> iKd_InUse,
						o_iHResult=> iFinalAdjust_H,
						//2026.04.10.102239 修改输出@到金刚的值
						//o_rKp_MolCal=>pstStUnitParam_Save^.stStArc_Mol_Param.rKp_MolCal,
						//o_rKi_MolCal=>pstStUnitParam_Save^.stStArc_Mol_Param.rKi_MolCal
						o_rKp_MolCal=>pstStUnitParam_Save^.rKp_MolCal,
						o_rKi_MolCal=>pstStUnitParam_Save^.rKi_MolCal);
						


				pstStUnitParam_UnSave^.iVerror_Follow1UnitByErrTrans:=0;(*清零@2023.08.19.110414*)
				(*2025.4.20.130854+*)
				pstStUnitParam_UnSave^.byArcSts:=0;(*2025.4.20.125527 套色状态变量清零*)
				pstStUnitParam_UnSave^.xArcErrIsAlarm_V:=FALSE;(*报警*)
				pstStUnitParam_UnSave^.xArcErrIsLost_V:=FALSE;(*丢失*)
				pstStUnitParam_UnSave^.xArcErrIsFake_V:=FALSE;(*飞点*)
				pstStUnitParam_UnSave^.xArcErrIsAlarm_H:=FALSE;(*报警*)
				pstStUnitParam_UnSave^.xArcErrIsLost_H:=FALSE;(*丢失*)
				pstStUnitParam_UnSave^.xArcErrIsFake_H:=FALSE;(*飞点*)
				pstStUnitParam_UnSave^.iArcErr_V:=0;
				pstStUnitParam_UnSave^.xArcErrIsValid_V:=FALSE;

				atPrevCycleTime[iUnitId]:=T#0MS;
				arResult_EvenAccSeg[iUnitId,1]:=0;
				arResult_EvenAccSeg[iUnitId,2]:=0;
				(*清零*)
				IF g_pstStGlobalVarByAllocMem<>0 THEN
					parCompensateDelayArr := ADR(g_pstStGlobalVarByAllocMem^.arArcAccOrDecCompensateDelayArr[iUnitId,1]);
					SysMemSet(parCompensateDelayArr,0,SIZEOF(parCompensateDelayArr^));
				END_IF
			END_IF
			g_stStSysParam.stStSysParam_UnSave.xSaveFineSampleData_ToArc:=FALSE;(*2023.06.14.100406*)

		END_IF
	END_IF
END_FOR