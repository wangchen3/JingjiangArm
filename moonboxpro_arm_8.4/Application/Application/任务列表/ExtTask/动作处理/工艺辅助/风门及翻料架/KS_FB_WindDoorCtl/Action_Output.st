(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=177a6d68-4e06-4cdd-bba9-c8f73b8a3373
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]) ;
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	
	pstStUnitParam_UnSave^.byAirInletWindDoorValue_FeedBack := abyAirInletWindDoorValue_FeedBack_Out[iUnitId] ;
	pstStIOMap_Axis_Extra_FE^.o_wInReturnAir := awOutputAO_AirInletMotor[iUnitId] ;
	
	//2026.06.03.102330 翻料架输出
	pstStIOMap_Axis_Extra_FE^.o_xRel_TurnoverFilmAgency := pstStIOMap_Axis_Extra_FE^.i_xTurnoverFilmAgency;
END_FOR