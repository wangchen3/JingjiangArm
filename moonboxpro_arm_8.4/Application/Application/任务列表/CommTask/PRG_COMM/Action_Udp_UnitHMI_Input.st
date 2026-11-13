(*@CES
Name=Action_Udp_UnitHMI_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=f5c1d7ba-7edb-4795-af5d-1ee2ef07b11e
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	iGrpIdTmp:= g_stStSysParam.astStUnitParam_Save[iN].byGrpId;
	astStParam_UnitHMI485_Wr_81[iN].byPackId:= 1;
	astStParam_UnitHMI485_Wr_81[iN].wGirth:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_Save[iN].rGirth_Sam*10);
	astStParam_UnitHMI485_Wr_81[iN].iCompanyId:= g_stStSysParam.stStSysParam_Save.iCustomerId;
	astStParam_UnitHMI485_Wr_81[iN].iPromptMsgId:= g_stStSysParam.astStGrpParam_UnSave[iGrpIdTmp].iPromptMsg;
	astStParam_UnitHMI485_Wr_81[iN].wAxisId_And_GrpId:= SHL(INT_TO_WORD(iN),8)+INT_TO_WORD(iGrpIdTmp);    
	astStParam_UnitHMI485_Wr_81[iN].wLedtime_And_Language:= SHL(BYTE_TO_WORD(g_stStSysParam.stStSysParam_Save.byMinutes_ScrSaver),8)+
																BYTE_TO_WORD(g_stStSysParam.stStSysParam_Save.byLanguageId);
	astStParam_UnitHMI485_Wr_81[iN].iVel_Axis:= REAL_TO_INT(g_stStSysParam.astStUnitParam_UnSave[iN].rAxisVel_PrnRoller*10.0);															
	astStParam_UnitHMI485_Wr_81[iN].iVel_Grp:= REAL_TO_INT(g_stStSysParam.astStGrpParam_UnSave[iGrpIdTmp].rVel_Cur*10.0);
	astStParam_UnitHMI485_Wr_81[iN].wIndex_And_ErrNum:= g_stStSysParam.astStUnitParam_UnSave[iN].byIndex;
	astStParam_UnitHMI485_Wr_81[iN].iArcAlarm_V:= REAL_TO_INT(g_stStSysParam.astStUnitParam_Save[iN].rAlr_V*100);//单位丝
	astStParam_UnitHMI485_Wr_81[iN].iArcAlarm_H:= REAL_TO_INT(g_stStSysParam.astStUnitParam_Save[iN].rAlr_H*100);//单位丝
	astStParam_UnitHMI485_Wr_81[iN].wUnit_Input_I:= g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I;
	astStParam_UnitHMI485_Wr_81[iN].wUnit_Input_II:= g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II;
	astStParam_UnitHMI485_Wr_81[iN].wUnit_Input_III:= g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III;
	astStParam_UnitHMI485_Wr_81[iN].wHz_UnitInkRoller_CurrWR:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[iN].rHz_UnitInkRoller_CurrWR*100);
	astStParam_UnitHMI485_Wr_81[iN].wHz_UnitScraper_CurrWR:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[iN].rHz_UnitScraper_CurrWR *100);
	astStParam_UnitHMI485_Wr_81[iN].wHz_UnitHotWind_CurrWR:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[iN].rHz_UnitHotWind_CurrWR*100);
	astStParam_UnitHMI485_Wr_81[iN].wHz_UnitHotWind2_CurrWR:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[iN].rHz_UnitHotWind2_CurrWR*100);
	astStParam_UnitHMI485_Wr_81[iN].wPV_UnitTemCtl:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[iN].rPV_UnitTemCtl);
	astStParam_UnitHMI485_Wr_81[iN].wSts_UnitTemCtl:= g_stStSysParam.astStUnitParam_UnSave[iN].wSTS_UnitTemCtl;
	astStParam_UnitHMI485_Wr_81[iN].rPos_PrnRoller_Pressure_M:= g_stStSysParam.astStUnitParam_UnSave[iN].rPos_PrnRoller_Pressure_M;
	astStParam_UnitHMI485_Wr_81[iN].rPos_PrnRoller_Pressure_G:= g_stStSysParam.astStUnitParam_UnSave[iN].rPos_PrnRoller_Pressure_G;
	astStParam_UnitHMI485_Wr_81[iN].rPos_NetRoller_Pressure_M:= g_stStSysParam.astStUnitParam_UnSave[iN].rPos_NetRoller_Pressure_M;
	astStParam_UnitHMI485_Wr_81[iN].rPos_NetRoller_Pressure_G:= g_stStSysParam.astStUnitParam_UnSave[iN].rPos_NetRoller_Pressure_G;

	astStParam_UnitHMI485_Wr_82[iN].byPackId:= 2;
	SysMemCmp(ADR(astStParam_UnitHMI485_Wr_82[iN].abyRsv_LowComm),0,SIZEOF(astStParam_UnitHMI485_Wr_82[iN].abyRsv_LowComm));
	
	IF iN=2 AND astStParam_UnitHMI485_Wr_81[iN].bySts_Ctl.0 THEN(*2色控制1色*)
		iGrpIdTmp:= g_stStSysParam.astStUnitParam_Save[1].byGrpId;	
		astStParam_UnitHMI485_Wr_83[iN].byPackId:= 3;
		astStParam_UnitHMI485_Wr_83[iN].wGirth_OtherUnit:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_Save[1].rGirth_Sam*10);
		astStParam_UnitHMI485_Wr_83[iN].iCompanyId_OtherUnit:= g_stStSysParam.stStSysParam_Save.iCustomerId;
		astStParam_UnitHMI485_Wr_83[iN].iPromptMsgId_OtherUnit:= g_stStSysParam.astStGrpParam_UnSave[iGrpIdTmp].iPromptMsg;
		astStParam_UnitHMI485_Wr_83[iN].wAxisId_And_GrpId_OtherUnit:= SHL(INT_TO_WORD(iN),8)+INT_TO_WORD(iGrpIdTmp);    
		astStParam_UnitHMI485_Wr_83[iN].wLedtime_And_Language_OtherUnit:= SHL(BYTE_TO_WORD(g_stStSysParam.stStSysParam_Save.byMinutes_ScrSaver),8)+
																	BYTE_TO_WORD(g_stStSysParam.stStSysParam_Save.byLanguageId);
		astStParam_UnitHMI485_Wr_83[iN].iVel_Axis_OtherUnit:= REAL_TO_INT(g_stStSysParam.astStUnitParam_UnSave[1].rAxisVel_PrnRoller*10.0);															
		astStParam_UnitHMI485_Wr_83[iN].iVel_Grp_OtherUnit:= REAL_TO_INT(g_stStSysParam.astStGrpParam_UnSave[iGrpIdTmp].rVel_Cur*10.0);
		astStParam_UnitHMI485_Wr_83[iN].wIndex_And_ErrNum_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].byIndex;
		astStParam_UnitHMI485_Wr_83[iN].wUnit_Input_I_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].wUnit_input_I;
		astStParam_UnitHMI485_Wr_83[iN].wUnit_Input_II_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].wUnit_input_II;
		astStParam_UnitHMI485_Wr_83[iN].wUnit_Input_III_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].wUnit_input_III;
		astStParam_UnitHMI485_Wr_83[iN].wHz_UnitInkRoller_CurrWR_OtherUnit:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[1].rHz_UnitInkRoller_CurrWR*100);
		astStParam_UnitHMI485_Wr_83[iN].wHz_UnitScraper_CurrWR_OtherUnit:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[1].rHz_UnitScraper_CurrWR *100);
		astStParam_UnitHMI485_Wr_83[iN].wHz_UnitHotWind_CurrWR_OtherUnit:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[1].rHz_UnitHotWind_CurrWR*100);
		astStParam_UnitHMI485_Wr_83[iN].wHz_UnitHotWind2_CurrWR_OtherUnit:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[1].rHz_UnitHotWind2_CurrWR*100);
		astStParam_UnitHMI485_Wr_83[iN].wPV_UnitTemCtl_OtherUnit:= REAL_TO_WORD(g_stStSysParam.astStUnitParam_UnSave[1].rPV_UnitTemCtl);
		astStParam_UnitHMI485_Wr_83[iN].wSts_UnitTemCtl_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[iN].wSTS_UnitTemCtl;
		astStParam_UnitHMI485_Wr_83[iN].rPos_PrnRoller_Pressure_M_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].rPos_PrnRoller_Pressure_M;
		astStParam_UnitHMI485_Wr_83[iN].rPos_PrnRoller_Pressure_G_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].rPos_PrnRoller_Pressure_G;
		astStParam_UnitHMI485_Wr_83[iN].rPos_NetRoller_Pressure_M_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].rPos_NetRoller_Pressure_M;
		astStParam_UnitHMI485_Wr_83[iN].rPos_NetRoller_Pressure_G_OtherUnit:= g_stStSysParam.astStUnitParam_UnSave[1].rPos_NetRoller_Pressure_G;
	END_IF
(*	
	astStParam_UnitHMI485_WrRd[iN].byAxisId:= INT_TO_BYTE(iN);
	astStParam_UnitHMI485_WrRd[iN].iAdjust_V:= 
	astStParam_UnitHMI485_WrRd[iN].iAdjust_H:= 
	astStParam_UnitHMI485_WrRd[iN].wStatus:= ;
	astStParam_UnitHMI485_WrRd[iN].wUnit_Outout_I:= ;
	astStParam_UnitHMI485_WrRd[iN].wUnit_Outout_II:= ;
*)	
END_FOR