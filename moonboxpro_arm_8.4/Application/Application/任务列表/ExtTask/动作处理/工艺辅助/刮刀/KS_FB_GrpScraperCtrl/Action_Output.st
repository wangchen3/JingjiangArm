(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=85d6e944-a3be-4f5f-b59c-cc0d6d509187
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*牵引一控多*)
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_xScraperOn:=
	xScraperOn_IfOf_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_xScraperOn:=
	xScraperOn_IfOf_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].lrAxisScraperVel:= 
	rAxisScraperVel_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_Of].o_wAO_Scraper:=
	wAO_Scraper_IfOf_Out;
i_pastStIOMap_Main_FE^[i_iAxisId_If].o_wAO_Scraper:=
	wAO_Scraper_IfOf_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rHz_UnitScraper_CurrWR:= 	
	rHz_UnitScraper_CurrWR_Out;
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	i_pastStIOMap_AxisExtra^[iUnitId].o_xScraperOn:= axScraperOn_Unit_Out[iUnitId];
	i_pastStIOMap_AxisExtra^[iUnitId].o_wAO_Scraper:= awAO_Scraper_Unit_Out[iUnitId];

	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].lrAxisScraperVel:= arAxisScraperVel_Out[iUnitId];
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitScraper_CurrWR:= arHz_UnitScraper_CurrWR_Out[iUnitId];

END_FOR


i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMaxFreq_Scraper:= rMaxFreq_Scraper_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMinFreq_Scraper:= rMinFreq_Scraper_In_Out;
