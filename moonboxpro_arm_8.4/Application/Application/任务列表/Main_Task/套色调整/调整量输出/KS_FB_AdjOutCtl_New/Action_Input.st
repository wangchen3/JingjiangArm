(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=894181a4-5230-475e-81ab-356e0a149522
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
iGrp:= i_iGrpId;
rVel_Cur_In:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVel_Cur;
rVel_AutoAdj_In:= i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_AutoAdj;
rVel_ManuAdj_Corse_In:= i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_ManuAdj_Corse;
rVel_ManuAdj_Fine_In:= i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_ManuAdj_Fine;
rVel_RapidAdj_In:= i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_RapidAdj;

xFlag_Home_In_Out:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Home;
xFlag_PreRegister_In_Out:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreRegister;
xFlag_PhaseRestore_In_Out:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore;
xFlag_Stop_In:=i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Stop ;
xFlag_EStop_In:=i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_EStop ;

//2026.5.8.114724
FOR iN:=1 TO i_iGrpUnitNum BY 1 DO
	astMotionSts[iN].lrMotionsts:= g_aststGetMotionSts[iN+53].dwMotionSts;
	astMotionSts[iN].lrPos_Prf:= g_aststGetMotionSts[iN+53].lrPos_Prf;
	astMotionSts[iN].lrVel_Prf:= g_aststGetMotionSts[iN+53].lrVel_Prf;
	astMotionSts[iN].lrAcc_Prf:= g_aststGetMotionSts[iN+53].lrPrfAcc;
	
END_FOR

FOR iN:=1 TO i_iGrpUnitNum BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	arGirth_Adj_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_Sam/1000.0;(*直接计算为m*)
	auiNum_Adj_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_Sam;
	auiDen_Adj_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_Sam;
	axInching_In[iUnitId]:=	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching;
	aliPrfPos_Target_In[iUnitId] := LREAL_TO_LINT(astMotionSts[iUnitId].lrPos_Prf);
	arVel_Pre_In[iUnitId] := LREAL_TO_REAL(astMotionSts[iUnitId].lrVel_Prf);
	adwAxisSts_Pre_In[iUnitId] := LREAL_TO_DWORD(astMotionSts[iUnitId].lrMotionsts);
	
	//2026.05.13.210820 替换为获取指针 by Liu.yt
	//abyRapidAdjustStep_In_Out[iUnitId]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byRapidAdjustStep;
	apbyRapidAdjustStep_In[iUnitId]:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byRapidAdjustStep);
	

	axFlag_MoveRev_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller;
	//2026.05.11.170138更新问题，这里不能处理横向相关，不能用循环，只处理索引1 注意等号前后都有
	//FOR iM:= 1 TO 2 BY 1 DO


		aplrTotalAdjustVal_Auto_vh_In_Out[iUnitId]:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[1]);
		aplrTotalAdjustVal_Rapid_vh_In_Out[iUnitId]:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Rapid_vh[1]);
		aplrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId]:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[1]);
		aplrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId]:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[1]);
		aplrTotalAdjustVal_Coupling_vh_In_Out[iUnitId]:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Coupling_vh[1]);
		aplrTotalAdjustVal_Compensate_vh_In_Out[iUnitId]:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Compensate_vh[1]);
(*错误|2025.9.1.191032|niu.j
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[iM]:= alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,iM];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Rapid_vh[iM]:= alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,iM];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[iM]:= alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,iM];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[iM]:= alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,iM];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Coupling_vh[iM]:= alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,iM];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Compensate_vh[iM]:= alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,iM];
*)
		alrExecutedAdjVal_Auto_vh_In_Out[iUnitId,1]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Auto_vh[1];
		alrExecutedAdjVal_Rapid_vh_In_Out[iUnitId,1]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Rapid_vh[1];
		alrExecutedAdjVal_ManuCoarse_vh_In_Out[iUnitId,1]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_ManuCoarse_vh[1];
		alrExecutedAdjVal_ManuFine_vh_In_Out[iUnitId,1]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_ManuFine_vh[1];
		alrExecutedAdjVal_Coupling_vh_In_Out[iUnitId,1]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Coupling_vh[1];
		alrExecutedAdjVal_Compensate_vh_In_Out[iUnitId,1]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Compensate_vh[1];
		
	//END_FOR

END_FOR
