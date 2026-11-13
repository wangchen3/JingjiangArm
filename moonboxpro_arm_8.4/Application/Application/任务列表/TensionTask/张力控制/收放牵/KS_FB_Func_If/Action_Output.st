(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=3e3c6dc9-13d5-45f0-baee-80bf8ff81991
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xGirthCalFinish_If:=
xGirthCalFinish_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rUsingGirth_If:= 
rUsingGirth_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_If:= rPi_Value_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rForwardStep_If:= rForwardStep_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVelRPM_Cur_If:= rVel_rpm_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur_If:= rVel_Cur_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xOuting_sin_If:= xOuting_sin_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rResult_sin_If:= rResult_sin_Out;

//2026.1.5.144023  | +
xInverterAlarm_Out;
xInch_Out;
i_pastStIOMap_Main_FE^[1].o_xInverterReset_If := xInverterResetIO_Out;
i_pastStIOMap_Main_FE^[1].o_wAO_If := wAO_Inverter_Out;
rAO_Inverter_Out;
i_pastStIOMap_Main_FE^[1].o_wFilm_Vel_If := wAO_FilmVel_Out;
rAO_VelFilm_Out;
i_pastStIOMap_Main_FE^[1].o_xCW_If  := xInverter_Cw_Out;
i_pastStIOMap_Main_FE^[1].o_xAdjustEn_If := xAdjustEn_Out;


i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_If:= 
bySetTestPid_In_Out	;(*: BYTE;(*伪随机步骤*)                         *)

i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWn_If:= rWn_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rBw_If:= rBw_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDp_If:= rDp_In_Out;
i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.0					:= xTaperUnitType_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_If			:= 	byTaperUnit_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_If	:= byTaperUnitConfirm_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_If			:= rPercentMatchN_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_If		:= rPercentMatchMpa_In_Out		;	
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_If	:= rTaperValueBegin_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_If	:= rTaperValueEnd_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_If	:= rTaperValueCur_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_If			:= rTaper_Begin_In_Out			;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_If				:= rTaper_End_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_If			:= rTaper_Cur_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_If			:= 	rTaperMax_In_Out			;


(*增加几个用于保存的变量*)
g_arAntiNotch_Out_Uw[i_iGrpId]:= fbKS_FB_Tension.rAntiNotch_Out;