(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=07990ead-f63a-421d-930c-30338d5d42c8
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	pstStIOMap_Axis_Extra_FE^.o_xRel_HotBlower:= axRel_HotBlower_Out[iUnitId];
	pstStIOMap_Axis_Extra_FE^.o_xLamp_HotBlower:= axLamp_HotBlower_Out[iUnitId];
	pstStIOMap_Axis_Extra_FE^.o_xLamp_AllHotBlower :=  axLamp_AllHotBlower_Out[iUnitId];
END_FOR
//输出到牵引IO
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xLamp_AllHotBlower := xLamp_AllHotBlower_Out   ;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xLamp_AllHotBlower := xLamp_AllHotBlower_Out   ; 