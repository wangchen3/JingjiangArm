(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=732ccfe4-40b9-4d59-bdd5-f5b3a6db6d1f
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Home:= xFlag_Home_In_Out;
i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreRegister:= xFlag_PreRegister_In_Out;
i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore:= xFlag_PhaseRestore_In_Out;
FOR iN:=1 TO i_iGrpUnitNum BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	//2026.05.13.210701  屏蔽只在in中处理获取指针 by liu.yt
	//i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byRapidAdjustStep:= abyRapidAdjustStep_In_Out[iUnitId];
	
	//2026.05.11.170138更新问题，这里不能处理横向相关，不能用循环，只处理索引1 注意等号前后都有
	//FOR iM:= 1 TO 2 BY 1 DO


// 
// 		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[1]:= alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1];
// 		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Rapid_vh[1]:= alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,1];
// 		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[1]:= alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,1];
// 		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[1]:= alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,1];
// 		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Coupling_vh[1]:= alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1];
// 		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Compensate_vh[1]:= alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1];

		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Auto_vh[1]		:= alrExecutedAdjVal_Auto_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Rapid_vh[1]		:= alrExecutedAdjVal_Rapid_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_ManuCoarse_vh[1]	:= alrExecutedAdjVal_ManuCoarse_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_ManuFine_vh[1]	:= alrExecutedAdjVal_ManuFine_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Coupling_vh[1]	:= alrExecutedAdjVal_Coupling_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Compensate_vh[1]	:= alrExecutedAdjVal_Compensate_vh_In_Out[iUnitId,1];

	//END_FOR

END_FOR


