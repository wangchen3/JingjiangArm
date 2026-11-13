(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=bde20589-da35-47e8-a7cf-95d5bcfed050
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
xAllowLinkageChangeInRunning_In:= i_pstStSysParam^.stStSysParam_Save.xAllowLinkageChangeInRunning;
xFlag_Stop_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;
xFlag_Estop_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
xFlag_Stoping_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stoping;
xFlag_FastStoping_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FastStoping;
xFlag_EStoping_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping;
xFlag_AllInchRun_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun;
xFlag_Home_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home;
xFlag_PreRegister_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister;
xFlag_PhaseRestore_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore;
xFlag_Print_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
rVel_Cur_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur; 
xUseBtn_Linkage_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseBtn_Linkage;

xFlag_Alarm_If_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xNetOffline_IF OR
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_IF OR
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPosDeviationAlarm_IF;
xFlag_Alarm_Of_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xNetOffline_OF OR
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_OF OR
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPosDeviationAlarm_OF;
xLinkage_IfOf_Ink_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xLinkage_IfOf_Ink;						
xFlag_Home_end_In_Out:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end;
						
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	axFlag_Alarm_Unit_In[iN]:= i_pstStSysParam^.astStUnitParam_UnSave[iN].xNetOffline_PrnRoller OR
								i_pstStSysParam^.astStUnitParam_UnSave[iN].xAxisAlarm_PrnRoller OR
								i_pstStSysParam^.astStUnitParam_UnSave[iN].xPosDeviationAlarm_PrnRoller;	
	axLinkage_IO_In[iN]:= i_pastStIOMap_Axis_FE^[iN].i_xLinkage;

	axBtnLinkage_HMI_In_Out[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].xBtnLinkage_HMI;
	axFlag_Linkage_In_Out[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage;
	
	
END_FOR