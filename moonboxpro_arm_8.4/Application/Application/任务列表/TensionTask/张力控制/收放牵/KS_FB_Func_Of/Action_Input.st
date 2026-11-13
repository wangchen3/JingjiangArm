(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ec271e93-b13c-4a6d-822b-d08902f7d27b
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
rActualGirth_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_Of;
xRollerPressDone_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressDone;
xSwitchTension_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitchTension_Of;
xFlag_Accing_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing;
xFlag_Decing_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing;
xCompensateWhenAccing_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCompensateWhenAccing_Of;
rCompensateGirthWhenAccing_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rCompensateGirthWhenAccing_Of;
xRollerSts_IfOf_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_Of;
xFilmAccDecDone_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FilmAccDecDone;
arKpid_IfOf_In[1]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_Of[1];
arKpid_IfOf_In[2]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_Of[2];
arKpid_IfOf_In[3]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_Of[3];
byVelLimit_PerCent_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byVelLimit_PerCent_IfOf;
iFeedLimitWarnCoff_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iFeedLimitWarnCoff;
xFeedlimitWarnFlag_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xEnFeedLimitWarnFlag;
uiMaxVel_UseCalcAcc_In:= i_pstStSysParam^.stStSysParam_Save.uiMaxVel_UseCalcAcc;
rPseudoRandomRoundAmplitude_Cur_In	:=  i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPseudoRandomRoundAmplitude_Cur;(*伪随机序列*)
xPseudoRandomEn_In				:= i_pstStSysParam^.stStSysParam_Save.xPseudoRandomEn ;(*: BOOL;(*伪随机测试按钮*) *)
xPseudoRandomId_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byPseudoRandomId=3;(*放料伪随机使能*)
xPseudoRandomTsting_In			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPseudoRandomTsting;
aiTestKp_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kp;(*: ARRAY [1..3] OF INT;(*伪随机P值*)                                           *)
aiTestKd_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kd;(*: ARRAY [1..3] OF INT;(*伪随机D值*)                                           *)
xPidType_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xPidType_Of_New;
xUseAntiNotch_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseAntiNotch_Of;
xEn_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEn_Disturbance_Of;
rFreq_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rFreq_Disturbance_Of;
rAmplitude_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAmplitude_Disturbance_Of;
uiTotalTime_Disturbance_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].uiTotalTime_Disturbance_Of;
xFlag_RollerPressAtLeast1_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressAtLeast1;
rN_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_Of;
rMpa_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMpa_Of;


rWn_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWn_Of;
rBw_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rBw_Of;
rDp_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDp_Of;

bySetTestPid_In_Out			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_Of;(*: BYTE;(*伪随机步骤*)                         *)
xTaperUnitType_In_Out					:= i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.1;
byTaperUnit_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_Of;
byTaperUnitConfirm_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_Of;
rPercentMatchN_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_Of;
rPercentMatchMpa_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_Of;
rTaperValueBegin_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_Of;
rTaperValueEnd_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_Of;
rTaperValueCur_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_Of;
rTaper_Begin_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_Of;
rTaper_End_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_Of;
rTaper_Cur_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_Of;
rTaperMax_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_Of;
