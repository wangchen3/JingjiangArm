(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=250c1277-b8ca-4b5c-b2c6-d99fe57f9149
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xRel_InkRoller_CW:= xRel_InkRoller_CW_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xRel_InkRoller_CCW:= xRel_InkRoller_CCW_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xRel_InkRoller_CW:= xRel_InkRoller_CW_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xRel_InkRoller_CCW:= xRel_InkRoller_CCW_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xInkRollerOn:= xInkRollerOn_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xInkRollerOn:= xInkRollerOn_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_wAO_InkRoller:= wAO_InkRoller_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_wAO_InkRoller:= wAO_InkRoller_Out;

;
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	i_pastStIOMap_AxisExtra^[iUnitId].o_xRel_InkRoller_CW:= axRel_InkRoller_CW_Out[iUnitId];
	i_pastStIOMap_AxisExtra^[iUnitId].o_xRel_InkRoller_CCW:= axRel_InkRoller_CCW_Out[iUnitId];
	i_pastStIOMap_AxisExtra^[iUnitId].o_xInkRollerOn:= axInkRollerOn_Out[iUnitId];
	i_pastStIOMap_AxisExtra^[iUnitId].o_wAO_InkRoller:= awAO_InkRoller_Out[iUnitId];
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitInkRoller_CurrWR:= arHz_UnitInkRoller_CurrWR_Out[iUnitId];	
	i_pastStIOMap_AxisExtra^[iUnitId].o_xRel_InkRoller_Up:= axRel_InkRoller_Up_Out[iUnitId];
	i_pastStIOMap_AxisExtra^[iUnitId].o_xRel_InkRoller_Dn:= axRel_InkRoller_Dn_Out[iUnitId];
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xFlag_InkRollerRisen:= axFlag_InkRollerRisen_In_Out[iUnitId];
	//2026.05.25.133848 反转后输出负电压
	i_pastStIOMap_AxisExtra^[iUnitId].o_wAO_InkRoller_Dir:=awAO_InkRoller_Out_DIR[iUnitId];

END_FOR