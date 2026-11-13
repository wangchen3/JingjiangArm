(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=8e681107-c8fd-43a2-b69b-04e8cb291095
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:=i_aiGrpAxisList[iN];
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iUnitId]) ; 
	pstStIOMap_Axis_Extra_FE^.o_xLamp_CoolBlower  := axLamp_CoolBlower_Out[iUnitId];	
	pstStIOMap_Axis_Extra_FE^.o_xRel_CoolBlower  := axRel_CoolBlower_Out[iUnitId];	
	pstStIOMap_Axis_Extra_FE^.o_xLamp_AllCoolBlower  := axLamp_AllCoolBlower_Out[iUnitId];
END_FOR
//输出到牵引IO
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xLamp_AllCoolBlower := xLamp_AllCoolBlower_Out   ;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xLamp_AllCoolBlower := xLamp_AllCoolBlower_Out   ; 