(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=80d53ffb-9331-493b-802c-989d7f4c0f1e
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyAxisList_CoatingPrn[iN]:= abyAxisList_CoatingPrn_Out[iN];
END_FOR
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byAxisNum_CoatingPrn:= byAxisNum_CoatingPrn_Out;
//2026.8.20.180126
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	i_pstStSysParam^.astStUnitParam_UnSave[iN].lrVelocity_CoatingPrn:= alrVelocity_CoatingPrn_In[iN];
END_FOR