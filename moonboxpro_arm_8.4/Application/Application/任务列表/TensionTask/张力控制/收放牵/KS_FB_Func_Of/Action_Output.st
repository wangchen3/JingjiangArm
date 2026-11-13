(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=08e215cb-c878-4263-954e-99e6cd9ef063
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xGirthCalFinish_Of:=
xGirthCalFinish_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rUsingGirth_Of:= 
rUsingGirth_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPi_Value_Of:= rPi_Value_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rForwardStep_Of:= rForwardStep_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVelRPM_Cur_Of:= rVel_rpm_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur_Of:= rVel_Cur_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xOuting_sin_Of:= xOuting_sin_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rResult_sin_Of:= rResult_sin_Out;



i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_Of:= 
bySetTestPid_In_Out	;(*: BYTE;(*伪随机步骤*)                         *)

i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWn_Of:= rWn_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rBw_Of:= rBw_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDp_Of:= rDp_In_Out;
i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.1					:= xTaperUnitType_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_Of			:= 	byTaperUnit_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_Of	:= byTaperUnitConfirm_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_Of			:= rPercentMatchN_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_Of		:= rPercentMatchMpa_In_Out		;	
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_Of	:= rTaperValueBegin_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_Of	:= rTaperValueEnd_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_Of	:= rTaperValueCur_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_Of			:= rTaper_Begin_In_Out			;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_Of				:= rTaper_End_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_Of			:= rTaper_Cur_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_Of			:= 	rTaperMax_In_Out			;
