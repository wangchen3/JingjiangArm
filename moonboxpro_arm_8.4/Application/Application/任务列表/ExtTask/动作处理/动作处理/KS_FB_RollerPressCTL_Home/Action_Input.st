(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=3dabc8a7-27ca-43ab-a9d0-05546c28b529
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
byDelayTime_PressDneInPrint_If_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byDelayTime_PressDneInPrint_If;
xFlag_PreStart_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreStart;
xAllPressOneBtn_In:= i_pstStSysParam^.stStSysParam_Save.xAllPressOneBtn;
xUnitPressOneBtn_In:= i_pstStSysParam^.stStSysParam_Save.xUnitPressOneBtn;
xWorkMode_RollerPress_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xWorkMode_RollerPress;
xFlag_Print_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;
xFilmAccDecDone_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FilmAccDecDone;
iDelayMsec_RollerPress_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iDelayMsec_RollerPress;
xPressMode_Auto_IO_If_In:= i_pastStIOMap_Main_FE^[i_iAxisId_If].i_xPressMode_Auto_IF;
xPressMode_Auto_IO_Of_In:= i_pastStIOMap_Main_FE^[i_iAxisId_Of].i_xPressMode_Auto_OF;
xFlag_Tension_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension;
xFlag_Estop_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
xPressMode_Manu_IO_If_In:= i_pastStIOMap_Main_FE^[i_iAxisId_If].i_xPressMode_Manu_IF;
xPressMode_Manu_IO_Of_In:= i_pastStIOMap_Main_FE^[i_iAxisId_Of].i_xPressMode_Manu_OF;
xFlag_EStoping_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping;
xFlag_GotoInking_In_Out:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_GotoInking;
xTapPosition_Printing_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xTapPosition_Printing;
xTapPosition_Breaking_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xTapPosition_Breaking;
xTapPosition_UniformInk_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xTapPosition_UniformInk;
xFlag_FastStoping_In:=  i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FastStoping;
xFlag_Stop_In:=  i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;
xFlag_Ink_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink;
 
rVel_Cur_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
rVel_Film_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film;
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	axFlag_Linkage_In[iN]:= i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage;
	axPressMode_Auto_IO_In[iN]:= i_pastStIOMap_Axis_FE^[iN].i_xPressMode_Auto;
	
	axAxisAutoPressed_In_Out[iN]:= i_pstStSysParam^.astStUnitParam_UnSave[iN].xAxisAutoPressed;
	abyRapidAdjustStep_In_Out[iN]:= i_pstStSysParam^.astStUnitParam_UnSave[iN].byRapidAdjustStep;
	axRapidAdjust_ing_In_Out[iN]:= i_pstStSysParam^.astStUnitParam_UnSave[iN].xRapidAdjust_ing;
	aiRapidAdjust_TimingCnt_In_Out[iN]:= i_pstStSysParam^.astStUnitParam_UnSave[iN].iRapidAdjust_TimingCnt;
//2026.5.14.092600更新	axPress_IO_In[iN]:=i_pastStIOMap_Axis_FE^[iN].i_xPress;
	axPress_IO_In[iN]:=i_pastStIOMap_Axis_FE^[iN].i_xPress OR  g_axAutoFind_Press[iN];//OR PRG_EXT.afbKS_FB_SpecialFun[i_iGrpId].fbKS_FB_MarkDetection.o_axAxisStartPress[iN];
	
	axUnPress_IO_In[iN]:=i_pastStIOMap_Axis_FE^[iN].i_xUnPress;
	axPressMode_Manu_IO_In[iN]:= i_pastStIOMap_Axis_FE^[iN].i_xPressMode_Manu;
	axUnPress_Inching_In[iN]:= i_pastStIOMap_Axis_FE^[iN].i_xUnPress_Inching;
	//2026.04.09.085848
	auiTimeMs_RollerPressUpKeep_In_Out[iN]:=i_pstStSysParam^.astStUnitParam_Save[iN].uiTimeMs_RollerPressUpKeep;
	
END_FOR