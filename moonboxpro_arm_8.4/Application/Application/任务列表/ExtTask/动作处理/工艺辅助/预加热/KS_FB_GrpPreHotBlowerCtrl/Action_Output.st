(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=6e994558-82e0-4fec-a533-2b23fce767dc
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	
	pstStIOMap_Axis_Extra_FE^.o_xRel_PreHotBlower := axOutputRel_PreHotBlower[iUnitId]; 
	pstStIOMap_Axis_Extra_FE^.o_xLamp_PreHotBlower	:= axOutputLamp_PreHotBlower[iUnitId]; 
	pstStIOMap_Axis_Extra_FE^.o_xRel_PreHeating:= axOutputRel_PreHeating[iUnitId]; 
	pstStIOMap_Axis_Extra_FE^.o_xLamp_PreHeating:= axOutputLamp_PreHeating[iUnitId]; 
	
END_FOR