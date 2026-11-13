(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=31129176-87a5-474e-b2e5-05ceabe544b5
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
pstStGrpParam_Save :=ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId] );
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iAxisId:=i_aiGrpAxisList[iN];
	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId] );
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iAxisId]) ; 
	axAllExhBlower_Err_Up_In[iAxisId] := pstStIOMap_Axis_Extra_FE^.i_xAllExhBlower_Err_Up; 
	axAllExhBlower_Err_Dn_In[iAxisId]:= pstStIOMap_Axis_Extra_FE^.i_xAllExhBlower_Err_Dn; 
	axAirExhaustSwitch_In[iAxisId]:= pstStIOMap_Axis_Extra_FE^.i_xAirExhaustSwitch;
	axAirExhaustButton_In[iAxisId]:= pstStIOMap_Axis_Extra_FE^.i_xAirExhaustButton;
	
	arHz_UnitExhaust_ManuallySet_In[iAxisId] :=pstStUnitParam_Save^.rHz_UnitExhaust_ManuallySet ;
	abyFreq_ExhaustAir_In[iAxisId]:=pstStUnitParam_Save^.byFreq_ExhaustAir;
	
	byFreqUpper_ExhaustAir_In:= pstStGrpParam_Save^.byFreqUpper_ExhaustAir;
	uiFreqCoeff_Auto_ExhaustAir_In :=pstStGrpParam_Save^.uiFreqCoeff_Auto_ExhaustAir;
	byFreqMax_ExhaustAir_In :=pstStGrpParam_Save^.byFreqMax_ExhaustAir;
	byFreqMin_ExhaustAir_In:=pstStGrpParam_Save^.byFreqMin_ExhaustAir;
	
END_FOR