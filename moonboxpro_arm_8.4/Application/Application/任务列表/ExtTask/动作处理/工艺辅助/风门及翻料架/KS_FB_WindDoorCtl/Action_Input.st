(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=5276b0fa-3bba-4ccd-8fa9-472235f8000f
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId] );
	pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]) ;
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	awInputAI_AirInletMotor[iUnitId] := pstStIOMap_Axis_Extra_FE^.i_wAI_AirInletMotor ;
	abyAirInletWindDoorValue_In[iUnitId] :=  pstStUnitParam_Save^.byAirInletWindDoorValue  ;
END_FOR