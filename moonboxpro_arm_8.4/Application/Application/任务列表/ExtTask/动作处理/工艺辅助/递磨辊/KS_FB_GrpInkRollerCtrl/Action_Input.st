(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=c901a74d-ce20-4560-9fe5-aea306380fd6
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
iVel_InkRollerMax_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iVel_InkRollerMax;
iVel_InkRollerMin_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iVel_InkRollerMin;
iFrq_InkRollerMax_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iFrq_InkRollerMax;
iFrq_InkRollerMin_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iFrq_InkRollerMin;
rCoeff_InkRoller_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rCoeff_InkRoller;
rVel_Cur_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
xSwitch_InkRollerAuto_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_InkRollerAuto_If OR
		i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_InkRollerAuto_Of;
		
rHz_UnitInkRoller_ManuallySet_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rHz_InkRoller_ManuallySet;
iUpperFreq_InkRoller_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iUpperFreq_InkRoller;

xInkRollerInveterError_In:= i_pastStIOMap_Main_FE^[i_iAxisId_If].i_xInkRollerInveterError OR
		i_pastStIOMap_Main_FE^[i_iAxisId_Of].i_xInkRollerInveterError;
		
xFlag_Estop_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;		
iVelSa_InkRollerRun_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iVelSa_InkRollerRun;//2026.04.08.203518 配置为了刮刀起始速度了

xInkRoller_CW_In:= i_pastStIOMap_Main_FE^[i_iAxisId_If].i_xInkRoller_CW OR 
		i_pastStIOMap_Main_FE^[i_iAxisId_Of].i_xInkRoller_CW;
xInkRoller_CCW_In:= i_pastStIOMap_Main_FE^[i_iAxisId_If].i_xInkRoller_CCW OR 
		i_pastStIOMap_Main_FE^[i_iAxisId_Of].i_xInkRoller_CCW;		
		
xInkRollerSolenoid_Use3Switch_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_InkRollerSolenoid_Use3;(*电控比例阀用三档开关*) 		
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	axSwitch_InkRollerAuto_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_InkRollerAuto;
	arHz_UnitInkRoller_ManuallySet_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitInkRoller_ManuallySet;
	arAxisVel_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_PrnRoller;
	axInkRollerInveterError_In[iUnitId]:= i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRollerInveterError;
	axInkRoller_CW_In[iUnitId]:= i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRoller_CW;
	axInkRoller_CCW_In[iUnitId]:= i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRoller_CCW;
	arCoeff_UnitInkRoller_Auto_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rCoeff_UnitInkRoller_Auto;
	axFlag_Linkage_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;
	axInkRoller_Up_In[iUnitId]:= i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRoller_Up;
	axInkRoller_Dn_In[iUnitId]:= i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRoller_Dn;
	axFlag_InkRollerRisen_In_Out[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xFlag_InkRollerRisen;
	
END_FOR
(*i_pastStIOMap_Main_FE^[i_iAxisId_If];*)