(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=813a2c3a-1268-4c3d-a4b8-596ecc5e9067
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//FOR iGrp:=1 TO 2 BY 1 DO
	xFlag_Stop_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;
	xFlag_Estop_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStop;
	xFlag_Print_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
	xSts_HorzPreRegister_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_HorzPreRegister;
	xBtn_HorzPreRegister_Repeat_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_HorzPreRegister_Repeat;
	xBtn_HorzPreRegister_Setup_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_HorzPreRegister_Setup;
	xMode_HorzPreRegister_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMode_HorzPreRegister;
	xFlag_HorzPreRegister_All_end_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end;
//END_FOR


FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_abyGrpAxisList[iN];
	diPreReg_RepeatVal_H_In[iUnitId]:=i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].diPreReg_RepeatVal_H;
	xLinkage_In[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;
	xHorzMotor_Alarm_In[iUnitId]:=i_pastStIOMap_AxisBasic^[iUnitId].i_xHorzMotor_Alarm;
END_FOR