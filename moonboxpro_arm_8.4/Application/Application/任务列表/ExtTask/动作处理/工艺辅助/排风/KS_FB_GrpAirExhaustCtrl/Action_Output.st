(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=752bb6d3-c7a4-4db0-bb86-8ead87fa90f7
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iAxisId:=i_aiGrpAxisList[iN];
	pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iAxisId]) ;
	pstStIOMap_Axis_Extra_FE := ADR(i_PastStIOMap_Axis_Extra_FE^[iAxisId]) ; 
	pstStIOMap_Axis_Extra_FE^.o_xLamp_AllExhBlower_Up :=  axlamp_AllExhBlower_Up_Out[iAxisId]; 
	pstStIOMap_Axis_Extra_FE^.o_xLamp_AllExhBlower_Dn := axlamp_AllExhBlower_Dn_Out[iAxisId]; 
	
	pstStIOMap_Axis_Extra_FE^.o_xRel_AllExhBlower_Up := axRel_AllExhBlower_Up_Out[iAxisId]; 
	pstStIOMap_Axis_Extra_FE^.o_xRel_ModeTriangle_AllExhBlower_Up :=  axRel_ModeTriangle_AllExhBlower_Up_Out[iAxisId]; 
	pstStIOMap_Axis_Extra_FE^.o_xRel_ModeStar_AllExhBlower_Up := axRel_ModeStar_AllExhBlower_Up_Out[iAxisId]; 
	
	pstStIOMap_Axis_Extra_FE^.o_xRel_AllExhBlower_Dn := axRel_AllExhBlower_Dn_Out[iAxisId]; 
	pstStIOMap_Axis_Extra_FE^.o_xRel_ModeTriangle_AllExhBlower_Dn := axRel_ModeTriangle_AllExhBlower_Dn_Out[iAxisId]; 
	pstStIOMap_Axis_Extra_FE^.o_xRel_ModeStar_AllExhBlower_Dn := axRel_ModeStar_AllExhBlower_Dn_Out[iAxisId]; 
	
	pstStIOMap_Axis_Extra_FE^.o_xAirExhaustEn := axAirExhaustEn_Out[iAxisId]; 
	
	pstStIOMap_Axis_Extra_FE^.o_wAO_AllExhBlower_Up :=  awAO_AllExhBlower_Up_Out[iAxisId]; 	
	pstStIOMap_Axis_Extra_FE^.o_wAO_AllExhBlower_Dn := awAO_AllExhBlower_Dn_Out[iAxisId]; 
	
	pstStUnitParam_UnSave^.byFreqCur_ExhaustAir :=   abyFreqCur_ExhaustAir_Out[iAxisId]; 
END_FOR
IF i_iAxisId_If>0 AND i_iAxisId_If<=4 AND i_iAxisId_Of>0 AND i_iAxisId_Of<= 4 THEN
	i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xRel_AllExhBlower_Up:= xAirExhaustFlag;
	i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xRel_AllExhBlower_Dn:= xAirExhaustFlag;
	i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xLamp_AllExhBlower_Up:= xAirExhaustFlag;
	i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xLamp_AllExhBlower_Dn:= xAirExhaustFlag;
	i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xRel_AllExhBlower_Up:= xAirExhaustFlag;
	i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xRel_AllExhBlower_Dn:= xAirExhaustFlag;
	i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xLamp_AllExhBlower_Up:= xAirExhaustFlag;
	i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xLamp_AllExhBlower_Dn:= xAirExhaustFlag;
	
END_IF