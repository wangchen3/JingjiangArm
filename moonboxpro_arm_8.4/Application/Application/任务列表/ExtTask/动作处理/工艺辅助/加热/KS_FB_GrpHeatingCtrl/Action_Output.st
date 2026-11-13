(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=6411b04a-86f9-4b82-ad4b-6e58b8eb93f2
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	
	pstStIOMap_Axis_Extra_FE^.o_xLamp_Heating :=  axLamp_Heating_Out[iUnitId];(*加热输出*)
	pstStIOMap_Axis_Extra_FE^.o_xRel_Heating_I := axRel_Heating_I_Out[iUnitId];(*一档输出*)
	pstStIOMap_Axis_Extra_FE^.o_xRel_Heating_II := axRel_Heating_II_Out[iUnitId];(*二档输出*)
	pstStIOMap_Axis_Extra_FE^.o_xRel_Heating_III := axRel_Heating_III_Out[iUnitId];(*三档输出*)
	pstStIOMap_Axis_Extra_FE^.o_xLamp_AllHeating := axLamp_AllHeating_Out[iUnitId];(*全体加热输出*)

END_FOR

//输出到牵引IO
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xLamp_AllHeating := xLamp_AllHeating_Out   ;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xLamp_AllHeating := xLamp_AllHeating_Out   ; 