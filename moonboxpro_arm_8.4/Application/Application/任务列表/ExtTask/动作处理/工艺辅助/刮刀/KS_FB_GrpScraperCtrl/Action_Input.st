(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=4bb0cd80-b029-4a4c-9f4a-6727b2749063
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
rVel_Cur_In:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
iVelSa_ScraperRun_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iVelSa_ScraperRun;
xScraperOn_IfOf_In:= i_pastStIOMap_Main_FE^[i_iAxisId_If].i_xScraperOn OR 
							i_pastStIOMap_Main_FE^[i_iAxisId_Of].i_xScraperOn;
xScraperInveterError_IfOf_In:= i_pastStIOMap_Main_FE^[i_iAxisId_If].i_xScraperInveterError OR 
							i_pastStIOMap_Main_FE^[i_iAxisId_Of].i_xScraperInveterError;
							
rGirth_PrnRoller_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_PrnRoller;
iRatio_ScraperContrastToPrintRoller_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iRatio_ScraperContrastToPrintRoller;
rRatedRpm_Scraper_In:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrRatedRpm_Scraper);
iNum_ScraperMotor_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iNum_ScraperMotor;						
iDen_ScraperMotor_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iDen_ScraperMotor;						
rRatedFreq_Scraper_In:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrRatedFreq_Scraper);
rCoeff_Scraper_In:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrCoeff_Scraper);
xSwitch_ScraperAuto_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_ScraperAuto_If OR
								i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_ScraperAuto_Of;
rHz_UnitScraper_ManuallySet_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rHz_Scraper_ManuallySet; 								
rMaxFreq_Scraper_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMaxFreq_Scraper;
rMinFreq_Scraper_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMinFreq_Scraper;
rUpperFreq_Scraper_In	:= LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrUpperFreq_Scraper);


FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	axFlag_Linkage_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;
	arAxisVel_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_PrnRoller;
	axScraperOn_Unit_In[iUnitId]:= i_pastStIOMap_AxisExtra^[iUnitId].i_xScraperOn;
	axScraperInveterError_Unit_In[iUnitId]:= i_pastStIOMap_AxisExtra^[iUnitId].i_xScraperInveterError;
	axSwitch_ScraperAuto_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_ScraperAuto;
	arGirth_PrnRoller_In[iUnitId]:=	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller;
	arCoeff_UnitScraper_Auto_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rCoeff_UnitScraper_Auto;
	//2026.06.26.125044
	arHz_UnitScraper_ManuallySet_In[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitScraper_ManuallySet;
	
END_FOR