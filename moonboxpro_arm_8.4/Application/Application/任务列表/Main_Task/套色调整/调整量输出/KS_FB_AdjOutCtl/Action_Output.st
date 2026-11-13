(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=fccb975f-5ce4-4868-8a73-fdd5b4173960
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
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byRapidAdjustStep:= abyRapidAdjustStep_In_Out[iUnitId];

//2026.5.11.160052更新问题：这里不能处理横向相关，不能用循环，只处理索引1	注意等号前后都有
//	FOR iM:= 1 TO 2 BY 1 DO
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[1]:= alrTotalAdjustVal_Auto_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Rapid_vh[1]:= alrTotalAdjustVal_Rapid_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[1]:= alrTotalAdjustVal_ManuCoarse_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[1]:= alrTotalAdjustVal_ManuFine_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Coupling_vh[1]:= alrTotalAdjustVal_Coupling_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Compensate_vh[1]:= alrTotalAdjustVal_Compensate_vh_In_Out[iUnitId,1];

		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Auto_vh[1]		:= alrExecutedAdjVal_Auto_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Rapid_vh[1]		:= alrExecutedAdjVal_Rapid_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_ManuCoarse_vh[1]	:= alrExecutedAdjVal_ManuCoarse_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_ManuFine_vh[1]	:= alrExecutedAdjVal_ManuFine_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Coupling_vh[1]	:= alrExecutedAdjVal_Coupling_vh_In_Out[iUnitId,1];
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrExecutedAdjVal_Compensate_vh[1]	:= alrExecutedAdjVal_Compensate_vh_In_Out[iUnitId,1];

//	END_FOR
END_FOR

