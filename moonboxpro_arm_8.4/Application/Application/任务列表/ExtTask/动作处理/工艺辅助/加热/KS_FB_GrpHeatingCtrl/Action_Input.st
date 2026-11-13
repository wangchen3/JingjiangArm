(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ef806be5-4521-4ac4-8acb-0cd8f9c666c0
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId] );
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	pstStGrpParam_Save :=ADR(i_pstStSysParam^.astStGrpParam_Save[1] );
	pstStUnitParam_UnSave := ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId] );
	iDelayMsec_Heat_In :=pstStGrpParam_Save^.iDelayMsec_HeatBlower ; 
	axHeating_I_In[iUnitId]:=pstStIOMap_Axis_Extra_FE^.i_xHeating_I;(*一档加热输入*)
	axHeating_II_In[iUnitId] :=pstStIOMap_Axis_Extra_FE^.i_xHeating_II;(*二档加热输入*)
	axHeating_III_In[iUnitId] :=pstStIOMap_Axis_Extra_FE^.i_xHeating_III;(*三档热输入*)
	axHeating_Button_In[iUnitId] :=pstStIOMap_Axis_Extra_FE^.i_xHeating_Button;(*加热按钮输入*)
	axTemReachToTarget_In[iUnitId] :=pstStIOMap_Axis_Extra_FE^.i_xTemReachToTarget;(*加热未到设定标志*)
	axOvertemperature_In[iUnitId]  :=pstStUnitParam_UnSave^.wSTS_UnitTemCtl.9;(*超温标志*)
END_FOR