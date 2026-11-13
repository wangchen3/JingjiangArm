(*@CES
Name=Action_Sync_Gantry
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a6790846-b87a-41d2-af3f-c9184b93be48
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
	iUnitId:= i_aiGrpUnitList[iN];
(*压力电机方向*)	
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_M:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_M_[iUnitId].dwAxisProf.1;	
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_G:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_G_[iUnitId].dwAxisProf.1;
	
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_M:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_M_[iUnitId].dwAxisProf.1;	
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_G:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_G_[iUnitId].dwAxisProf.1;
					
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_M:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_STR_M_[iUnitId].dwAxisProf.1;	
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_G:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_STR_G_[iUnitId].dwAxisProf.1;
(*压力减速比*)					
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller_Pressure:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_PrnRoller_Pressure;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller_Pressure:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_PrnRoller_Pressure;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_PrnRoller_Pressure:=
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rScrewPitch_PrnRoller_Pressure;		
			
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller_Pressure:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_NetRoller_Pressure;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller_Pressure:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_NetRoller_Pressure;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_NetRoller_Pressure:=
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rScrewPitch_NetRoller_Pressure;			
			
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_StrRoller_Pressure:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_StrRoller_Pressure;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_StrRoller_Pressure:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_StrRoller_Pressure;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_StrRoller_Pressure:=
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rScrewPitch_StrRoller_Pressure;			

	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_Horz:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_Horz;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_Horz:=			
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_Horz;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rScrewPitch_Horz:=
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rScrewPitch_Horz;		
END_FOR