(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=b0016f94-cb21-4963-a7c7-b71be1783ab0
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId] );

	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	
	byHotBlowerStopDelayTime_In:= i_pstStSysParam^.stStSysParam_Save.byHotBlowerStopDelayTime;  //热风延时关闭时间
	iDelayMsec_HeatBlower_In := i_pstStSysParam^.stStSysParam_Save.iDelayMsec_HeatBlower; 
	axHotBlower_In[iUnitId] := pstStIOMap_Axis_Extra_FE^.i_xHotBlower;
	axHotBlower_Button_In[iUnitId]:= pstStIOMap_Axis_Extra_FE^.i_xHotBlower_Button;
	axHotBlower_Err_In[iUnitId] := pstStIOMap_Axis_Extra_FE^.i_xHotBlower_Err;
	axLamp_Heating_In[iUnitId] := pstStIOMap_Axis_Extra_FE^.o_xLamp_Heating;
	axHotBlower_Opened_Act_In[iUnitId] := pstStIOMap_Axis_Extra_FE^.i_xHotBlower_Opened_Act;
END_FOR


	