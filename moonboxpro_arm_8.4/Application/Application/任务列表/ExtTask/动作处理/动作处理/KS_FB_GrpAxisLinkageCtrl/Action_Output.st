(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=66e17568-e325-48c9-9d0f-f35acf35d465
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xLinkage_If:= xFlag_Linkage_If_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xLinkage_Of:= xFlag_Linkage_Of_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMoveEnable_Motor_If:= xMoveEnable_Motor_If_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMoveEnable_Motor_If:= xMoveEnable_Motor_Of_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end:= xFlag_Home_end_In_Out;

FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	i_pastStIOMap_Axis_FE^[iN].o_xLamp_Linkage:= axLamp_Linkage_IO_Out[iN];
	i_pstStSysParam^.astStUnitParam_UnSave[iN].xMoveEnable_Motor:= axMoveEnable_Motor_Out[iN];
	
	i_pstStSysParam^.astStUnitParam_Save[iN].xBtnLinkage_HMI:= axBtnLinkage_HMI_In_Out[iN];
	i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage:= axFlag_Linkage_In_Out[iN];
	
END_FOR