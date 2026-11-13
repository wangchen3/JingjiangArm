(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=98b63076-f56c-40e9-afc6-eee8182765a9
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
rActualGirth_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_If;
xRollerPressDone_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressDone;
xSwitchTension_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitchTension_If;
xFlag_Accing_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing;
xFlag_Decing_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing;
xCompensateWhenAccing_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCompensateWhenAccing_If;
rCompensateGirthWhenAccing_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rCompensateGirthWhenAccing_If;
xRollerSts_IfOf_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_If;
xFilmAccDecDone_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FilmAccDecDone;
arKpid_IfOf_In[1]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_If[1];
arKpid_IfOf_In[2]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_If[2];
arKpid_IfOf_In[3]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_If[3];
byVelLimit_PerCent_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byVelLimit_PerCent_IfOf;
iFeedLimitWarnCoff_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iFeedLimitWarnCoff;
xFeedlimitWarnFlag_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xEnFeedLimitWarnFlag;
uiMaxVel_UseCalcAcc_In:= i_pstStSysParam^.stStSysParam_Save.uiMaxVel_UseCalcAcc;
rPseudoRandomRoundAmplitude_Cur_In	:=  i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPseudoRandomRoundAmplitude_Cur;(*伪随机序列*)
xPseudoRandomEn_In				:= i_pstStSysParam^.stStSysParam_Save.xPseudoRandomEn;(*: BOOL;(*伪随机测试按钮*) *)
xPseudoRandomId_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byPseudoRandomId=0;(*放料伪随机使能*)
xPseudoRandomTsting_In			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPseudoRandomTsting;
aiTestKp_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kp;(*: ARRAY [1..3] OF INT;(*伪随机P值*)                                           *)
aiTestKd_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kd;(*: ARRAY [1..3] OF INT;(*伪随机D值*)                                           *)
xPidType_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xPidType_If_New;
xUseAntiNotch_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseAntiNotch_If;
xEn_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEn_Disturbance_If;
rFreq_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rFreq_Disturbance_If;
rAmplitude_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAmplitude_Disturbance_If;
uiTotalTime_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].uiTotalTime_Disturbance_If;
xFlag_RollerPressAtLeast1_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressAtLeast1;
rN_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_If;
rMpa_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMpa_If;



rWn_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWn_If;
rBw_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rBw_If;
rDp_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDp_If;
bySetTestPid_In_Out			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_If;(*: BYTE;(*伪随机步骤*)                         *)
xTaperUnitType_In_Out					:= i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.0;
byTaperUnit_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_If;
byTaperUnitConfirm_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_If;
rPercentMatchN_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_If;
rPercentMatchMpa_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_If;
rTaperValueBegin_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_If;
rTaperValueEnd_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_If;
rTaperValueCur_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_If;
rTaper_Begin_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_If;
rTaper_End_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_If;
rTaper_Cur_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_If;
rTaperMax_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_If;


//2026.1.5.144038 | + 
xClrAlarmInf_In ;
xFlag_Ink_In := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink;
xFlag_Stop_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;
xFlag_Tension_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension;
xInchBtn_In;
xInchType_In;
xInchDir_In;
iInchVel_In;
xFlag_Print_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
xInverterAlarm_IO_In := i_pastStIOMap_Main_FE^[1].i_xInverterAlarm_If;
iRatedRpm_In := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iRatedRpm_If;
iRatedFrq_In := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iRatedFreq_If;
iUpperFrq_In := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iUpperFreq_If;
uiNum_In := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_If;
uiDen_In := i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_If;

