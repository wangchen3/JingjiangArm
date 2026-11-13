(*@CES
Name=Action_PreReg
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=60e2082c-32d8-4bb7-a07d-9a9729f760af
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
KS_CalcForPreRegister(
	i_iMechanicalType:= g_stStSysParam.stStSysParam_Save.byMechanicalTypeId, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pastStMechanicalParamBuf:= ADR(g_stStSysParam.stStSysParam_Save.astStMechanicalParamBuf), 
	i_iGrpId:= iGrp, 
	i_xFilpSwitch:= FALSE
);

afbKS_FB_ProcPhaseOptReq[iGrp](
	i_xEn:= TRUE, 
	i_iGrpId:= iGrp, 
	i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
	i_aiGrpAxisList:= aiGrpAxisList, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_pxFlag_CphCommonVir:= ADR(g_xFlag_CphCommonVir),
	i_pxCphaseRestore:= ADR(g_xCphaseRestore), 
	i_pxFlag_CphCommonVir_end:= ADR(g_xFlag_CphCommonVir_end), 
	i_pxCphaseRestore_end:= ADR(g_xCphaseRestore_end), 
	i_xFlag_LinkageAtleast1:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_LinkageAtleast1Axis, 
	i_xFixedPhaseSave:= g_axFixedPhaseSave[iGrp], 
	i_xFixedPhaseRead:= g_axFixedPhaseRead[iGrp], 
	o_xEn=> , 
	o_iErrCode=> 
);
g_axFixedPhaseSave[iGrp]:= FALSE;
g_axFixedPhaseRead[iGrp]:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.byCurrUsrLevel>=1 THEN
	afbKS_FB_PreRegisterCorrDeal[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpAxisNum_Pu:= iGrpAxisNum_Pu, 
		i_paiGrpAxisList:= ADR(aiGrpAxisList), 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_palrTotalAdjustVal_V:= ADR(g_alrTotalAdjustVal_V), 
		o_xEn=> 
	);
END_IF