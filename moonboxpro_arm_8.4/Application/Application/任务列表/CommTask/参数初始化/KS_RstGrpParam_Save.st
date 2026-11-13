(*@CES
Name=KS_RstGrpParam_Save
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9ea5cc2b-8e73-4791-b11e-74f33891f310
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstGrpParam_Save : INT
VAR_INPUT
	i_pastStGrpParam_Save: POINTER TO ARRAY [1..2] OF StGrpParam_Save;
	i_pastStGrpParam_Save_RSV: POINTER TO ARRAY [1..2] OF StRSV_GrpParam_Save;
END_VAR
VAR
	iGrp: INT;
	iResult: INT;
	iN: INT;
END_VAR

{IMPLEMENTATION}
iResult:=0;

IF i_pastStGrpParam_Save<>0 AND i_pastStGrpParam_Save_RSV<>0 THEN
	FOR iGrp:=1 TO 2 BY 1 DO
		SysMemSet(ADR(i_pastStGrpParam_Save_RSV^[iGrp].abyRSV_StGrpParam_Save),
					0, 
					SIZEOF(i_pastStGrpParam_Save_RSV^[iGrp].abyRSV_StGrpParam_Save));
		i_pastStGrpParam_Save^[iGrp].rGirth_BottomRoller							:= 1005.2154;
		i_pastStGrpParam_Save^[iGrp].uiNum_BottomRoller                             := 8;
		i_pastStGrpParam_Save^[iGrp].uiDen_BottomRoller                             := 1;
		i_pastStGrpParam_Save^[iGrp].rGirth_PrnRoller                               := 620;
		i_pastStGrpParam_Save^[iGrp].uiNum_PrnRoller                                := 1;
		i_pastStGrpParam_Save^[iGrp].uiDen_PrnRoller                                := 1;
		i_pastStGrpParam_Save^[iGrp].rGirth_NetRoller                               := 502.6548;
		i_pastStGrpParam_Save^[iGrp].uiNum_NetRoller                                := 1;
		i_pastStGrpParam_Save^[iGrp].uiDen_NetRoller                                := 1;
		i_pastStGrpParam_Save^[iGrp].rGirth_StrRoller                               := 500;
		i_pastStGrpParam_Save^[iGrp].uiNum_StrRoller                                := 1;
		i_pastStGrpParam_Save^[iGrp].uiDen_StrRoller                                := 1;
		i_pastStGrpParam_Save^[iGrp].rScrewPitch_PrnRoller_Pressure                 := 4;
		i_pastStGrpParam_Save^[iGrp].uiNum_PrnRoller_Pressure                       := 40;
		i_pastStGrpParam_Save^[iGrp].uiDen_PrnRoller_Pressure                       := 1;
		i_pastStGrpParam_Save^[iGrp].rScrewPitch_NetRoller_Pressure                 := 2;
		i_pastStGrpParam_Save^[iGrp].uiNum_NetRoller_Pressure                       := 3;
		i_pastStGrpParam_Save^[iGrp].uiDen_NetRoller_Pressure                       := 1;
		i_pastStGrpParam_Save^[iGrp].rScrewPitch_StrRoller_Pressure                 := 2;
		i_pastStGrpParam_Save^[iGrp].uiNum_StrRoller_Pressure                       := 3;
		i_pastStGrpParam_Save^[iGrp].uiDen_StrRoller_Pressure                       := 1;
		i_pastStGrpParam_Save^[iGrp].rGirth_CenterRoller                            := 2513.27;
		i_pastStGrpParam_Save^[iGrp].uiNum_CenterRoller                             := 1;
		i_pastStGrpParam_Save^[iGrp].uiDen_CenterRoller                             := 1;
		i_pastStGrpParam_Save^[iGrp].rScrewPitch_Horz                               := 5;
		i_pastStGrpParam_Save^[iGrp].uiNum_Horz                                     := 1;
		i_pastStGrpParam_Save^[iGrp].uiDen_Horz                                     := 1;
		i_pastStGrpParam_Save^[iGrp].rScrewPitch_PhotoCell                          := 10;
		i_pastStGrpParam_Save^[iGrp].uiNum_PhotoCell                                := 1;
		i_pastStGrpParam_Save^[iGrp].uiDen_PhotoCell                                := 1;
		i_pastStGrpParam_Save^[iGrp].wAI_polarity                                   := 0;
		i_pastStGrpParam_Save^[iGrp].lrPrnLen_AmountTo                              := 0;
		i_pastStGrpParam_Save^[iGrp].rPrintLengthCoef                               := 1;
		SysMemSet(ADR(i_pastStGrpParam_Save^[iGrp].alrPrnLen),
				0,
				SIZEOF(i_pastStGrpParam_Save^[iGrp].alrPrnLen));
		
		SysMemSet(ADR(i_pastStGrpParam_Save^[iGrp].alrPrnLen_Alr),
				0,
				SIZEOF(i_pastStGrpParam_Save^[iGrp].alrPrnLen_Alr));

		i_pastStGrpParam_Save^[iGrp].iDelayMsec_RollerPress                         := 3000;
		i_pastStGrpParam_Save^[iGrp].wUwRwAxisProf.0                                := TRUE;
		i_pastStGrpParam_Save^[iGrp].wUwRwAxisProf.1                                := TRUE;
		i_pastStGrpParam_Save^[iGrp].iMarkTypeId                                    := MARK_TYPE_LINE;
		i_pastStGrpParam_Save^[iGrp].iMarkArrangeMode                               := MARK_ARRANGE_VFOR;
		i_pastStGrpParam_Save^[iGrp].byTriMark_SideC                                := 10;
		i_pastStGrpParam_Save^[iGrp].byTriMark_SideB                                := 10;
		i_pastStGrpParam_Save^[iGrp].bySysSamplePrecision                           := 2;
		i_pastStGrpParam_Save^[iGrp].byArcFineSampleType                            := 0;
		i_pastStGrpParam_Save^[iGrp].iTime_Stop                                     := 5;
		i_pastStGrpParam_Save^[iGrp].iTime_Estop                                    := 3;
		i_pastStGrpParam_Save^[iGrp].iTime_AutoAcc                                  := 50;
		i_pastStGrpParam_Save^[iGrp].iTime_ManuAcc                                  := 10;
		i_pastStGrpParam_Save^[iGrp].iTime_S                                        := 30;

		i_pastStGrpParam_Save^[iGrp].iTime_FilmAcc                                  := 8;
		i_pastStGrpParam_Save^[iGrp].iTime_FilmDec                                  := 2;
		i_pastStGrpParam_Save^[iGrp].iTime_AutoDec                                  := 50;
		i_pastStGrpParam_Save^[iGrp].iTime_ManuDec                                  := 10;
		i_pastStGrpParam_Save^[iGrp].iTime_FastStop                                 := 3;
		i_pastStGrpParam_Save^[iGrp].iTime_S_End                                    := 30;
		i_pastStGrpParam_Save^[iGrp].byAutoAccDecCurve                              := 0;
		i_pastStGrpParam_Save^[iGrp].rVel_Max                                       := 300;
		i_pastStGrpParam_Save^[iGrp].rVel_Tar                                       := 10;
		i_pastStGrpParam_Save^[iGrp].arVel_Usr[1]                                   := 30;
		i_pastStGrpParam_Save^[iGrp].arVel_Usr[2]                                   := 150;
		i_pastStGrpParam_Save^[iGrp].arVel_Usr[3]                                   := 300;
		
		i_pastStGrpParam_Save^[iGrp].rVel_Ink                                       := 12;
		i_pastStGrpParam_Save^[iGrp].rVel_Inch                                      := 10;
		i_pastStGrpParam_Save^[iGrp].rVel_AutoAdj                                   := 1;
		i_pastStGrpParam_Save^[iGrp].rVel_ManuAdj_Corse                             := 1.2;
		i_pastStGrpParam_Save^[iGrp].rVel_ManuAdj_Fine                              := 1;
		i_pastStGrpParam_Save^[iGrp].rVel_RapidAdj                                  := 5;
		i_pastStGrpParam_Save^[iGrp].rVel_HorzdAdj                                  := 0.5;
		i_pastStGrpParam_Save^[iGrp].rDiamAlarm_Uw                                  := 120;
		i_pastStGrpParam_Save^[iGrp].rGirth_AxiaA_Uw                                := 1280;
		i_pastStGrpParam_Save^[iGrp].rGirth_AxiaB_Uw                                := 1280;
		i_pastStGrpParam_Save^[iGrp].arKpid_Uw[1]                                   := 20;
		i_pastStGrpParam_Save^[iGrp].arKpid_Uw[2]                                   := 50;
		i_pastStGrpParam_Save^[iGrp].arKpid_Uw[3]                                   := 50;
		i_pastStGrpParam_Save^[iGrp].rGirth_Uw                                      := 1280;
		i_pastStGrpParam_Save^[iGrp].uiNum_Uw                                       := 21;
		i_pastStGrpParam_Save^[iGrp].uiDen_Uw                                       := 8;
		i_pastStGrpParam_Save^[iGrp].rTaper_Uw                                      := 1;
		i_pastStGrpParam_Save^[iGrp].rAI_med_Uw                                     := 5;
		i_pastStGrpParam_Save^[iGrp].byDiamMeasureTypeId_Uw                         := 0;
		i_pastStGrpParam_Save^[iGrp].byAIType_Uw                                    := 1;
		i_pastStGrpParam_Save^[iGrp].byCoef_stiffen_Uw                              := 10;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_Uw[0]                     := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_Uw[1]                     := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_MinDiam_Uw[0]             := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_MinDiam_Uw[1]             := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_Uw[0]                     := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_Uw[1]                     := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_MinDiam_Uw[0]             := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_MinDiam_Uw[1]             := 0;
		i_pastStGrpParam_Save^[iGrp].iRatedRpm_Uw                                   := 1500;
		i_pastStGrpParam_Save^[iGrp].iRatedFreq_Uw                                  := 50;
		i_pastStGrpParam_Save^[iGrp].iUpperFreq_Uw                                  := 100;
		i_pastStGrpParam_Save^[iGrp].xDiamMeasureAutomatic_Uw                       := FALSE;
		i_pastStGrpParam_Save^[iGrp].xCutUseReflectionSensor_Uw                     := FALSE;
		i_pastStGrpParam_Save^[iGrp].xMultAxisParaEn_Uw                             := FALSE;
		i_pastStGrpParam_Save^[iGrp].xFlag_CCW_AfterCutted_Uw                       := FALSE;
		i_pastStGrpParam_Save^[iGrp].iPreRevLenth_MM_Cutted_Uw                      := 1000;
		i_pastStGrpParam_Save^[iGrp].iPreRevVel_RPM_Cutted_Uw                       := 80;
		i_pastStGrpParam_Save^[iGrp].xPreCutOneBtn_Uw                               := FALSE;
		i_pastStGrpParam_Save^[iGrp].rCoefCut_FilmVolPerimeter_Uw                   := 1.5;
		i_pastStGrpParam_Save^[iGrp].xDiaEstEn_Uw                                   := FALSE;
		i_pastStGrpParam_Save^[iGrp].rEstiDia_Uw                                    := 400;
		i_pastStGrpParam_Save^[iGrp].rEstiThickness_Uw                              := 0;
		i_pastStGrpParam_Save^[iGrp].byDelayTime_DiaCompensateWhenCutDne_Uw         := 10;
		i_pastStGrpParam_Save^[iGrp].uiPiDelay_Uw                                   := 0;
		i_pastStGrpParam_Save^[iGrp].xUseRadCompensate_Uw                           := FALSE;
		i_pastStGrpParam_Save^[iGrp].xConfirmRad0_Uw                                := FALSE;
		i_pastStGrpParam_Save^[iGrp].dwAxisAabsPos_0Rad_Uw                          := 0;
		i_pastStGrpParam_Save^[iGrp].dwAxisBabsPos_0Rad_Uw                          := 0;
		i_pastStGrpParam_Save^[iGrp].rDiam_Tower_Uw                                 := 1000;
		i_pastStGrpParam_Save^[iGrp].rDiam_NextRoller_Uw                            := 100;
		i_pastStGrpParam_Save^[iGrp].rXPos_NextRoller_Uw                            := 232.5;
		i_pastStGrpParam_Save^[iGrp].rYPos_NextRoller_Uw                            := 2137-1085;
		i_pastStGrpParam_Save^[iGrp].xTowerDir_Uw                                   := FALSE;
		i_pastStGrpParam_Save^[iGrp].rDiam_DeflectorRollPos_Uw                      := 300;
		i_pastStGrpParam_Save^[iGrp].rDiam_DeflectorRoller_Uw                       := 100;
		i_pastStGrpParam_Save^[iGrp].xMultAxisPosEn_Uw                              := FALSE;
		i_pastStGrpParam_Save^[iGrp].byInitialSpd_Stiffen_Uw                        := 10;
		i_pastStGrpParam_Save^[iGrp].rFilmLen_UnwindToPU1                           := 8000;
		(*2026.06.02.224344+变量已经定位为副数了|修改初值*)
		i_pastStGrpParam_Save^[iGrp].rFilmLen_NotAdjFront                           := 6;//8000;
		i_pastStGrpParam_Save^[iGrp].rFilmLen_NotAdjBack                            := 6;//5000;
		i_pastStGrpParam_Save^[iGrp].rFilmLen_BetweenImpressPoints                  := 860;
		i_pastStGrpParam_Save^[iGrp].rDiamAlarm_Rw                                  := 400;
		i_pastStGrpParam_Save^[iGrp].rGirth_AxiaA_Rw                                := 300;
		i_pastStGrpParam_Save^[iGrp].rGirth_AxiaB_Rw                                := 300;
		i_pastStGrpParam_Save^[iGrp].arKpid_Rw[1]                                         := 20;
		i_pastStGrpParam_Save^[iGrp].arKpid_Rw[2]                                         := 50;
		i_pastStGrpParam_Save^[iGrp].arKpid_Rw[3]                                         := 50;
		i_pastStGrpParam_Save^[iGrp].rGirth_Rw                                      := 300;
		i_pastStGrpParam_Save^[iGrp].uiNum_Rw                                       := 1;
		i_pastStGrpParam_Save^[iGrp].uiDen_Rw                                       := 1;
		i_pastStGrpParam_Save^[iGrp].rAI_med_Rw                                     := 5;
		i_pastStGrpParam_Save^[iGrp].byAIType_Rw                                    := 1;
		i_pastStGrpParam_Save^[iGrp].byCoef_stiffen_Rw                              := 10;
//		i_pastStGrpParam_Save^[iGrp].xCutterOnTop_Rw                                := FALSE;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_Rw[0,0]                        := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_Rw[0,1]                        := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_Rw[1,0]                        := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisALocation_Rw[1,1]                        := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_Rw[0,0]                        := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_Rw[0,1]                        := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_Rw[1,0]                        := 0;
		i_pastStGrpParam_Save^[iGrp].adwEnc_AxisBLocation_Rw[1,1]                        := 0;
		i_pastStGrpParam_Save^[iGrp].rTaper_begin_Rw                                := 20;
		i_pastStGrpParam_Save^[iGrp].rTaper_end_Rw                                  := 18;
		i_pastStGrpParam_Save^[iGrp].rDiam_taper_begin_Rw                           := 100;
		i_pastStGrpParam_Save^[iGrp].rDiam_taper_end_Rw                             := 600;
		i_pastStGrpParam_Save^[iGrp].iRatedRpm_Rw                                   := 1500;
		i_pastStGrpParam_Save^[iGrp].iRatedFreq_Rw                                  := 50;
		i_pastStGrpParam_Save^[iGrp].iUpperFreq_Rw                                  := 100;
		i_pastStGrpParam_Save^[iGrp].rGirth_3inch_Rw                                := 300;
		i_pastStGrpParam_Save^[iGrp].rGirth_6inch_Rw                                := 600;
		i_pastStGrpParam_Save^[iGrp].xPreCutOneBtn_Rw                               := FALSE;
		i_pastStGrpParam_Save^[iGrp].rCoefCut_FilmVolPerimeter_Rw                   := 0.5;
		i_pastStGrpParam_Save^[iGrp].xDiaEstEn_Rw                                   := FALSE;
		i_pastStGrpParam_Save^[iGrp].rEstiDia_Rw                                    := 400;
		i_pastStGrpParam_Save^[iGrp].rEstiThickness_Rw                              := 0;
		i_pastStGrpParam_Save^[iGrp].byDelayTime_DiaCompensateWhenCutDne_Rw         := 10;
		i_pastStGrpParam_Save^[iGrp].xUseAbsEncEn_Rw                                := FALSE;
		i_pastStGrpParam_Save^[iGrp].xMultAxisPosEn_Rw                              := FALSE;
		i_pastStGrpParam_Save^[iGrp].byInitialSpd_Stiffen_Rw                        := 10;
		i_pastStGrpParam_Save^[iGrp].rDiamCurAxis_Uw                                := 300;
		i_pastStGrpParam_Save^[iGrp].rDiamCurAxis_Rw                                := 300;
		i_pastStGrpParam_Save^[iGrp].rGirth_If                                      := 841.9468;
		i_pastStGrpParam_Save^[iGrp].uiNum_If                                       := 8;
		i_pastStGrpParam_Save^[iGrp].uiDen_If                                       := 1;
		i_pastStGrpParam_Save^[iGrp].rTaper_If                                      := 1;
		i_pastStGrpParam_Save^[iGrp].byAIType_If                                    := 1;
		i_pastStGrpParam_Save^[iGrp].rAI_med_If                                     := 5;
		i_pastStGrpParam_Save^[iGrp].arKpid_If[1]                                      := 20;
		i_pastStGrpParam_Save^[iGrp].arKpid_If[2]                                      := 50;
		i_pastStGrpParam_Save^[iGrp].arKpid_If[3]                                      := 50;
		i_pastStGrpParam_Save^[iGrp].iRatedRpm_If                                   := 1500;
		i_pastStGrpParam_Save^[iGrp].iRatedFreq_If                                  := 50;
		i_pastStGrpParam_Save^[iGrp].iUpperFreq_If                                  := 100;
		i_pastStGrpParam_Save^[iGrp].xInchNegative_If                               := FALSE;
		i_pastStGrpParam_Save^[iGrp].iInchVel_If                                    := 10;
		i_pastStGrpParam_Save^[iGrp].xSwitchTension_If                              := FALSE;
		i_pastStGrpParam_Save^[iGrp].rGirth_Of                                      := 1005.2154;
		i_pastStGrpParam_Save^[iGrp].uiNum_Of                                       := 8;
		i_pastStGrpParam_Save^[iGrp].uiDen_Of                                       := 1;
		i_pastStGrpParam_Save^[iGrp].rTaper_Of                                      := 1;
		i_pastStGrpParam_Save^[iGrp].byAIType_Of                                    := 1;
		i_pastStGrpParam_Save^[iGrp].rAI_med_Of                                     := 5;
		i_pastStGrpParam_Save^[iGrp].arKpid_Of[1]                                      := 20;
		i_pastStGrpParam_Save^[iGrp].arKpid_Of[2]                                      := 50;
		i_pastStGrpParam_Save^[iGrp].arKpid_Of[3]                                      := 50;
		i_pastStGrpParam_Save^[iGrp].iRatedRpm_Of                                   := 1500;
		i_pastStGrpParam_Save^[iGrp].iRatedFreq_Of                                  := 50;
		i_pastStGrpParam_Save^[iGrp].iUpperFreq_Of                                  := 100;
		i_pastStGrpParam_Save^[iGrp].xSwitchTension_Of                              := FALSE;
		i_pastStGrpParam_Save^[iGrp].xInchNegative_Of                               := FALSE;
		i_pastStGrpParam_Save^[iGrp].iInchVel_Of                                    := 10;
		i_pastStGrpParam_Save^[iGrp].dwExtBitCtlFlag                                := 0;
		i_pastStGrpParam_Save^[iGrp].byTaperCtlMode_Uw                              := 1;
		i_pastStGrpParam_Save^[iGrp].byTaperCtlMode_Rw                              := 1;
		i_pastStGrpParam_Save^[iGrp].xAutomaticCutEn_Uw                             := FALSE;
		i_pastStGrpParam_Save^[iGrp].byAutoMaticCutMode_Uw                          := 0;
		i_pastStGrpParam_Save^[iGrp].uiAutoMaticCutMeters_Uw                        := 100;
		i_pastStGrpParam_Save^[iGrp].uiAutoMaticCutDia_Uw                           := 100;
		i_pastStGrpParam_Save^[iGrp].xAutomaticCutEn_Rw                             := FALSE;
		i_pastStGrpParam_Save^[iGrp].byAutoMaticCutMode_Rw                          := 0;
		i_pastStGrpParam_Save^[iGrp].uiAutoMaticCutMeters_Rw                        := 1000;
		i_pastStGrpParam_Save^[iGrp].uiAutoMaticCutDia_Rw                           := 200;
		i_pastStGrpParam_Save^[iGrp].byLenth_Machine                                := 80;
		i_pastStGrpParam_Save^[iGrp].rDia_PaperRoller_Uw                            := 95.5;
		i_pastStGrpParam_Save^[iGrp].rFilmThickNess                                 := 0.02;
		i_pastStGrpParam_Save^[iGrp].rDiamTaper_Begin_Uw                            := 200;
		i_pastStGrpParam_Save^[iGrp].rDiamTaper_End_Uw                              := 400;
		i_pastStGrpParam_Save^[iGrp].rTaper_Begin_Uw                                := 35;
		i_pastStGrpParam_Save^[iGrp].rTaper_End_Uw                                  := 20;
		i_pastStGrpParam_Save^[iGrp].rTaper_Begin_If                                := 35;
		i_pastStGrpParam_Save^[iGrp].rTaper_End_If                                  := 20;
		i_pastStGrpParam_Save^[iGrp].rTaper_Begin_Of                                := 35;
		i_pastStGrpParam_Save^[iGrp].rTaper_End_Of                                  := 20;
		i_pastStGrpParam_Save^[iGrp].xStep_Fast                                     := TRUE;
		i_pastStGrpParam_Save^[iGrp].rStep_Fast                                     := 5;
		i_pastStGrpParam_Save^[iGrp].rStep_Little                                   := 0.5;
		i_pastStGrpParam_Save^[iGrp].byTaperUnit_Uw                                 := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchN_Uw                              := 0;
		i_pastStGrpParam_Save^[iGrp].rN_Uw                                          := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchMpa_Uw                            := 0;
		i_pastStGrpParam_Save^[iGrp].rMpa_Uw                                        := 0;
		i_pastStGrpParam_Save^[iGrp].byTaperUnit_Rw                                 := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchN_Rw                              := 0;
		i_pastStGrpParam_Save^[iGrp].rN_Rw                                          := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchMpa_Rw                            := 0;
		i_pastStGrpParam_Save^[iGrp].rMpa_Rw                                        := 0;
		i_pastStGrpParam_Save^[iGrp].byTaperUnit_If                                 := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchN_If                              := 0;
		i_pastStGrpParam_Save^[iGrp].rN_If                                          := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchMpa_If                            := 0;
		i_pastStGrpParam_Save^[iGrp].rMpa_If                                        := 0;
		i_pastStGrpParam_Save^[iGrp].byTaperUnit_Of                                 := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchN_Of                              := 0;
		i_pastStGrpParam_Save^[iGrp].rN_Of                                          := 0;
		i_pastStGrpParam_Save^[iGrp].rPercentMatchMpa_Of                            := 0;
		i_pastStGrpParam_Save^[iGrp].rMpa_Of                                        := 0;
		i_pastStGrpParam_Save^[iGrp].rDiamCurAxis_Uw2                               := 300;
//		i_pastStGrpParam_Save^[iGrp].wCtlSwitchRef                                  := 0;
		i_pastStGrpParam_Save^[iGrp].wCtl_Pressure_Up_Dn                            := 0;
		i_pastStGrpParam_Save^[iGrp].rLength_AvoidancePoint_To_1u_mm                := 7000;
		i_pastStGrpParam_Save^[iGrp].rFilmThick_Confirm                             := 0.3;
		i_pastStGrpParam_Save^[iGrp].rFilmThick_Manu                                := 0.3;
		i_pastStGrpParam_Save^[iGrp].lrDistanceOfLimitTo_MEdge_MM                   := 2;
		i_pastStGrpParam_Save^[iGrp].xLength_BandLen_Check                          := FALSE;
		i_pastStGrpParam_Save^[iGrp].rLength_Band_Confirm                           := 1000;
		i_pastStGrpParam_Save^[iGrp].xLength_BandLen_Sync                           := FALSE;
		i_pastStGrpParam_Save^[iGrp].rLength_HeightStandard                         := 300;
		i_pastStGrpParam_Save^[iGrp].rLength_Width                                  := 100;
		i_pastStGrpParam_Save^[iGrp].rLength_Printing                               := 1132.25;
		i_pastStGrpParam_Save^[iGrp].rVel_Press_Prn                                 := 5;
		i_pastStGrpParam_Save^[iGrp].rVel_Press_Net                                 := 5;
		i_pastStGrpParam_Save^[iGrp].rVel_Press_Str                                 := 5;
		i_pastStGrpParam_Save^[iGrp].rPressure_Tar                                  := 120;
		i_pastStGrpParam_Save^[iGrp].xSmallDiaMulEn_UW                              := FALSE;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulSa_UW                              := 200;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulEd_UW                              := 100;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulSa_Coeff_UW                        := 100;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulEd_Coeff_UW                        := 100;
		i_pastStGrpParam_Save^[iGrp].xSmallDiaMulEn_RW                              := FALSE;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulSa_RW                              := 200;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulEd_RW                              := 100;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulSa_Coeff_RW                        := 100;
		i_pastStGrpParam_Save^[iGrp].iSmallDiaMulEd_Coeff_RW                        := 100;
		i_pastStGrpParam_Save^[iGrp].rVel_Temp_I                                    := 30;
		i_pastStGrpParam_Save^[iGrp].rVel_Temp_II                                   := 60;
		i_pastStGrpParam_Save^[iGrp].rBandLengthNotAdjArea                          := 0.03;
		i_pastStGrpParam_Save^[iGrp].rVel_NetReturn                                 := 30;		
		
		i_pastStGrpParam_Save^[iGrp].iVelSa_ScraperRun                    := 10;
		i_pastStGrpParam_Save^[iGrp].iVolt_ScraperMin                     := 0;
		i_pastStGrpParam_Save^[iGrp].iVolt_ScraperMax                     := 10;
		i_pastStGrpParam_Save^[iGrp].lrRatedRpm_Scraper                   := 1500;
		i_pastStGrpParam_Save^[iGrp].lrRatedFreq_Scraper                  := 50;
		i_pastStGrpParam_Save^[iGrp].lrUpperFreq_Scraper                  := 50;
		i_pastStGrpParam_Save^[iGrp].lrLowerFreq_Scraper                  := 10;
		i_pastStGrpParam_Save^[iGrp].lrCoeff_Scraper                      := 1;
		i_pastStGrpParam_Save^[iGrp].iNum_ScraperMotor                    := 20;
		i_pastStGrpParam_Save^[iGrp].iDen_ScraperMotor                    := 1;
		i_pastStGrpParam_Save^[iGrp].iRatio_ScraperContrastToPrintRoller  := 9;
		i_pastStGrpParam_Save^[iGrp].iDelayMsec_Heat                      := 3;
		i_pastStGrpParam_Save^[iGrp].iDelayMsec_HeatBlower                := 3;
		i_pastStGrpParam_Save^[iGrp].iDelayMsec_ExhPowerMode              := 30000;		
		
		(*2025.8.4.101322*)
		i_pastStGrpParam_Save^[iGrp].iCutDneResetPidMultiple_Uw:= 200;
		i_pastStGrpParam_Save^[iGrp].iCutDneResetPidMultiple_Rw:= 400;
		i_pastStGrpParam_Save^[iGrp].iCutDneResetPidRemainTime_Uw:= 10;
		i_pastStGrpParam_Save^[iGrp].iCutDneResetPidRemainTime_Rw:= 10;
		i_pastStGrpParam_Save^[iGrp].iCutDneResetPidToDefaultTime_Uw:= 1;
		i_pastStGrpParam_Save^[iGrp].iCutDneResetPidToDefaultTime_Rw:= 1;
		i_pastStGrpParam_Save^[iGrp].uiPreStopDelayTime_ms:= 100;
		i_pastStGrpParam_Save^[iGrp].dwAbsEnCodeResolution_Uw:= 8388608;
		i_pastStGrpParam_Save^[iGrp].dwAbsEnCodeResolution_Rw:= 8388608;
		i_pastStGrpParam_Save^[iGrp].xUseFollow_1U_V_UwCut:= FALSE;
		i_pastStGrpParam_Save^[iGrp].xGetFilmThickNessAuto:= FALSE;
		i_pastStGrpParam_Save^[iGrp].byAlarmType_NoMaterial_Uw:= 0;
		i_pastStGrpParam_Save^[iGrp].xTensionCompensateEn_Uw:= FALSE;
		i_pastStGrpParam_Save^[iGrp].xTensionCompensateEn_UwCut:= FALSE;
		i_pastStGrpParam_Save^[iGrp].xTensionCompensateEn_Rw:= FALSE;
		i_pastStGrpParam_Save^[iGrp].xTensionCompensateEn_RwCut:= FALSE;
		i_pastStGrpParam_Save^[iGrp].xUseIMatrix_rX_DARE_Uw:= TRUE;
		i_pastStGrpParam_Save^[iGrp].xUseIMatrix_rX_DARE_Rw:= TRUE;
		i_pastStGrpParam_Save^[iGrp].xUseTime_Variaition_Uw:= TRUE;
		i_pastStGrpParam_Save^[iGrp].xUseTime_Variaition_Rw:= TRUE;
		i_pastStGrpParam_Save^[iGrp].xUseTime_b1_Uw:= FALSE;
		i_pastStGrpParam_Save^[iGrp].xUseTime_b1_Rw:= FALSE;
		i_pastStGrpParam_Save^[iGrp].byAlarmHold_PreCut_Uw:= 3;
		i_pastStGrpParam_Save^[iGrp].byAlarmHold_PreCut_Rw:= 3;
		i_pastStGrpParam_Save^[iGrp].xCutDneResetPidEn_Uw:= FALSE;
		i_pastStGrpParam_Save^[iGrp].xCutDneResetPidEn_Rw:= TRUE;
				(*预估卷径初始化为400|2021.8.26.180414*)(*2022.7.26.101647调整为保持变量区*)
		i_pastStGrpParam_Save^[iGrp].rEstiDia_Uw:=400;
		i_pastStGrpParam_Save^[iGrp].rEstiDia_Rw:=100;
		i_pastStGrpParam_Save^[iGrp].xSwitch_Change_CutterOnTop_HMI_Uw:= TRUE;
		i_pastStGrpParam_Save^[iGrp].xSwitch_Change_CutterOnTop_HMI_Rw:= FALSE;
		i_pastStGrpParam_Save^[iGrp].byMeters_UseFollow_1U_V_UwCut:= 100;
		//2026.08.25.142941 修改使用料膜厚度的默认值
		//i_pastStGrpParam_Save^[iGrp].rFilmThickNess_Using:= 0.3;
		i_pastStGrpParam_Save^[iGrp].rFilmThickNess_Using:= 0.02;
		i_pastStGrpParam_Save^[iGrp].byVelSa_DiamCompensate_Uw:= 40;
		i_pastStGrpParam_Save^[iGrp].byVelSa_DiamCompensate_Rw:= 40;
		i_pastStGrpParam_Save^[iGrp].rKc_Uw:= 0.24;
		i_pastStGrpParam_Save^[iGrp].rKc_Uw_AccDec:= 0.24;
		i_pastStGrpParam_Save^[iGrp].rKc_Rw_AccDec:= 0.1;
		i_pastStGrpParam_Save^[iGrp].uiUseTime_Diam_Min_Uw:= 200;
		i_pastStGrpParam_Save^[iGrp].uiUseTime_Diam_Min_Rw:= 200;
		i_pastStGrpParam_Save^[iGrp].rR_K_LQR_Uw:= 10;
		i_pastStGrpParam_Save^[iGrp].rR_K_LQR_Rw:= 10;
		i_pastStGrpParam_Save^[iGrp].rN_LQR_Uw:= 10;
		i_pastStGrpParam_Save^[iGrp].rN_LQR_Rw:= 10;
		i_pastStGrpParam_Save^[iGrp].rR_K_MinBeat_Uw:= 100;
		i_pastStGrpParam_Save^[iGrp].rR_K_MinBeat_Rw:= 100;
		i_pastStGrpParam_Save^[iGrp].iN_MinBeat_Uw:= 2;
		i_pastStGrpParam_Save^[iGrp].iN_MinBeat_Rw:= 2;
		
		i_pastStGrpParam_Save^[iGrp].rKc_Rw:= 0.1;
		i_pastStGrpParam_Save^[iGrp].xGetLenthMachine_Rw:=FALSE;(*收料自动裁切获取料长使能*)
		i_pastStGrpParam_Save^[iGrp].byLenth_Machine:=80;(*整机长度|m*)
		i_pastStGrpParam_Save^[iGrp].xUseKnob_6Inch_Rw_Hmi:=FALSE;(*收料3-6寸使用界面旋钮@2024.04.18.182812*)
		FOR iN:=1 TO 3 BY 1 DO
			i_pastStGrpParam_Save^[iGrp].alrPrnLen[iN]:= 0;(*印刷长度||*)
			i_pastStGrpParam_Save^[iGrp].alrPrnLen_Alr[iN]:= 0;(*默认没有计长报警||*)
			i_pastStGrpParam_Save^[iGrp].alrPrnLen_FilmVel[iN]:= 0;(*根据料膜速度计算记米|niu.j|2019.1.25.135921||*)
			i_pastStGrpParam_Save^[iGrp].alrPrnLen_PTPos[iN]:= 0;(*根据PT规划位置计算记米|niu.j|2019.1.25.135921||*)
			i_pastStGrpParam_Save^[iGrp].alrPrnLen_FilmCnt[iN]:= 0;(*根据幅数记米|niu.j|2019.1.25.135921||*)
		END_FOR		
		
		i_pastStGrpParam_Save^[iGrp].xCancelTenEn:= TRUE;
		i_pastStGrpParam_Save^[iGrp].iWorkMode_Pid:= 2;(*1-传统pid; 2-目标pid|*)
		i_pastStGrpParam_Save^[iGrp].xFlag_Follow_1U_V:= FALSE;(*跟踪第一色*)
		i_pastStGrpParam_Save^[iGrp].xFlag_Follow_1U_H:= FALSE;(*跟踪第一色*)
		i_pastStGrpParam_Save^[iGrp].byDeCoupleArcNum:= 5;
		i_pastStGrpParam_Save^[iGrp].byDeCoupleDelayNum:= 18;
		i_pastStGrpParam_Save^[iGrp].rFilmLenth_InUnit:= 8.540;(*兴隆机组料长|m*)
		KS_InitTensionCtl_StructParam(
				16#7F(*i_byInitEn*),
				FALSE(*i_xUseIMatrix_rX_DARE*),
				ADR(i_pastStGrpParam_Save^[iGrp].stModelParam_Uw)(*i_pstInitial_Model_Parameters_Input*),
				ADR(i_pastStGrpParam_Save^[iGrp].stInvariant_Parameters_Uw)(*i_pstInvariant_Parameters1*),
				0(*i_pstKalman_Status_Estimation_And_Feedback1*),
				0(*i_pstKalman_Status_Estimation_And_Feedback_MinBeat1*),
				ADR(i_pastStGrpParam_Save^[iGrp].stPI_Parameters_Uw)(*i_pstPI_Parameters1*),
(*				ADR(pstStGrpParam^.arX_DARE_Uw)(*i_parX_DARE*),*)
				0(*i_parX_DARE*),(*2024.06.08.151800修改*)
				0(*i_palrX_DARE*),(*2024.06.08.151800修改*)
				ADR(i_pastStGrpParam_Save^[iGrp].stPI_Parameters_Uw_AccDec)(*i_pstPI_Parameters1_AccDec*),
				gc_TENSION_TSK_CYCLE_TIME(*i_iCycleTime_Plc*));
		KS_InitTensionCtl_StructParam(
				16#7F(*i_byInitEn*),
				FALSE(*i_xUseIMatrix_rX_DARE*),
				ADR(i_pastStGrpParam_Save^[iGrp].stModelParam_Rw)(*i_pstInitial_Model_Parameters_Input*),
				ADR(i_pastStGrpParam_Save^[iGrp].stInvariant_Parameters_Rw)(*i_pstInvariant_Parameters1*),
				0(*i_pstKalman_Status_Estimation_And_Feedback1*),
				0(*i_pstKalman_Status_Estimation_And_Feedback_MinBeat1*),
				ADR(i_pastStGrpParam_Save^[iGrp].stPI_Parameters_Rw)(*i_pstPI_Parameters1*),
(*				ADR(pstStGrpParam^.arX_DARE_Uw)(*i_parX_DARE*),*)
				0(*i_parX_DARE*),(*2024.06.08.151800修改*)
				0(*i_palrX_DARE*),(*2024.06.08.151800修改*)
				ADR(i_pastStGrpParam_Save^[iGrp].stPI_Parameters_Rw_AccDec)(*i_pstPI_Parameters1_AccDec*),
				gc_TENSION_TSK_CYCLE_TIME(*i_iCycleTime_Plc*));		
		(*放料上\下裁刀的时间参数设置|*)
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].iDelayMsec_CutterHolder:= 2500;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].iDelayMsec_CutOffKnifeCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].iDelayMsec_RollerCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].uiMM_Roller2GummedTape:= 300;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].uiMM_Roller2CutOfKnife:= 150;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].uiMM_CutOfKnife2GummedTape:= 300;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].iStepVariation4ChangeTime:= 10;
		SysMemSet(ADR(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].abyRsvdFields),
				0, SIZEOF(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[0].abyRsvdFields));
	
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].iDelayMsec_CutterHolder:= 2500;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].iDelayMsec_CutOffKnifeCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].iDelayMsec_RollerCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].uiMM_Roller2GummedTape:= 300;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].uiMM_Roller2CutOfKnife:= 150;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].uiMM_CutOfKnife2GummedTape:= 300;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].iStepVariation4ChangeTime:= 10;
		SysMemSet(ADR(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].abyRsvdFields),
				0, SIZEOF(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Uw[1].abyRsvdFields));

		(*收料上\下裁刀的时间参数设置|*)
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].iDelayMsec_CutterHolder:= 2500;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].iDelayMsec_CutOffKnifeCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].iDelayMsec_RollerCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].uiMM_Roller2GummedTape:= 300;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].uiMM_Roller2CutOfKnife:= 150;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].uiMM_CutOfKnife2GummedTape:= 400;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].iStepVariation4ChangeTime:= 10;
	(*	i_pstStSysParam^.astStTimeSet_DnCut_UpCut_Rw[0].iDelaySec_AirInflation_Mixed:= 0;*)
		SysMemSet(ADR(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].abyRsvdFields),
				0, SIZEOF(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[0].abyRsvdFields));
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].iDelayMsec_CutterHolder:= 2500;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].iDelayMsec_CutOffKnifeCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].iDelayMsec_RollerCylinder:= 200;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].uiMM_Roller2GummedTape:= 300;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].uiMM_Roller2CutOfKnife:= 150;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].uiMM_CutOfKnife2GummedTape:= 400;
		i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].iStepVariation4ChangeTime:= 10;
	(*	i_pstStSysParam^.astStTimeSet_DnCut_UpCut_Rw[1].iDelaySec_AirInflation_Mixed:= 0;*)
		SysMemSet(ADR(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].abyRsvdFields),
				0, SIZEOF(i_pastStGrpParam_Save^[iGrp].astStTimeSet_DnCut_UpCut_Rw[1].abyRsvdFields));

		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisA[1]:= 0.878;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisA[2]:= 2.384;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisA[3]:= 3.860;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisA[4]:= 5.362;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisA[0]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisA[1]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisA[2]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisA[3]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisA[4]:= 1;
	
		(*2019.1.25.151539|扩展了B轴||*)
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[1]:= 200;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[2]:= 400;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[3]:= 600;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[4]:= 800;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisB[1]:= 0.878;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisB[2]:= 2.384;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisB[3]:= 3.860;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisB[4]:= 5.362;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisB[0]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisB[1]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisB[2]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisB[3]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisB[4]:= 1;
	
		(*上裁|*)
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[1]:= 800;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[2]:= 600;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[3]:= 400;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[4]:= 200;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisA[1]:= 5.362;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisA[2]:= 3.860;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisA[3]:= 2.384;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisA[4]:= 0.878;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisA[0]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisA[1]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisA[2]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisA[3]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisA[4]:= 1;
	
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisB[1]:= 5.362;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisB[2]:= 3.860;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisB[3]:= 2.384;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisB[4]:= 0.878;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisB[0]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisB[1]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisB[2]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisB[3]:= 1;
		i_pastStGrpParam_Save^[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisB[4]:= 1;

		(*2025.3.6.093534增加初始化*)
		i_pastStGrpParam_Save^[iGrp].byFilmType:= 0;	
		(*收料锥度曲线点@2025.3.7.113824+*)
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[1].rX := 100;(*卷径@mm*)
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[1].rY := 50;(*锥度%*)
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[2].rX := 150;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[2].rY := 45;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[3].rX := 200;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[3].rY := 40;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[4].rX := 250;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[4].rY := 35;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[5].rX := 300;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[5].rY := 35;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[6].rX := 350;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[6].rY := 35;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[7].rX := 400;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[7].rY := 33;
												 
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[8].rX := 0;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[8].rY := 0;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[9].rX := 0;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[9].rY := 0;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[10].rX := 0;
		i_pastStGrpParam_Save^[iGrp].astTaperPoint_Rw[10].rY := 0;
		i_pastStGrpParam_Save^[iGrp].byVelLimit_PerCent_IfOf:= 20;
		i_pastStGrpParam_Save^[iGrp].iFeedLimitWarnCoff		:= 10(*INT*);
		
		
		(*新增变量|wang.nt|2025.08.07.145354*)
		i_pastStGrpParam_Save^[iGrp].byInitTaper_Rw									:=30;(*初始锥度值*)
		i_pastStGrpParam_Save^[iGrp].rInitTaper_Hmi_Rw								:=30		;(*收料起始气压*)

		i_pastStGrpParam_Save^[iGrp].rPressure_Max									:=500		;(*涂布压力传感器最大标定值*)
		i_pastStGrpParam_Save^[iGrp].rHz_MainExhaust_ManuallySet					:=50		;(*主排风手动频率*)
		i_pastStGrpParam_Save^[iGrp].byStationIdDst_VirEnc							:=33		;(*异站编码器目标站好*)
		i_pastStGrpParam_Save^[iGrp].rMinFreq_Scraper 								:=10		;(*刮刀最小频率*)
		i_pastStGrpParam_Save^[iGrp].rMaxFreq_Scraper 								:=50		;(*刮刀最大频率*)
		(*
		i_pastStGrpParam_Save^[iGrp].iUpperFreq_InkRoller 							:=50		;(*递磨辊上限频率*)
		i_pastStGrpParam_Save^[iGrp].iVelSa_InkRollerRun 							:=10		;(*递磨辊启动速度*)
		i_pastStGrpParam_Save^[iGrp].iFrq_InkRollerMin 								:=10		;(*递磨辊最小频率*)
		i_pastStGrpParam_Save^[iGrp].iFrq_InkRollerMax 								:=50		;(*递磨辊最大频率*)
		i_pastStGrpParam_Save^[iGrp].iVel_InkRollerMin 								:=10		;(*递磨辊最小速度*)
		i_pastStGrpParam_Save^[iGrp].iVel_InkRollerMax 								:=50		;(*递磨辊最大速度*)
		*)
		i_pastStGrpParam_Save^[iGrp].iPreHotRoller_Velocity_PreHot 					:=1500		;  (*预热辊额定转速*)
		i_pastStGrpParam_Save^[iGrp].rStandardFreq_HotRoller_PreHot 				:=50		; (*预热辊额定频率*)
		i_pastStGrpParam_Save^[iGrp].rUpperFreq_HotRoller_PreHot 					:=50		;    (*预热辊上限频率*)
		i_pastStGrpParam_Save^[iGrp].rCoeff_HotRoller_PreHot 						:=1		;        (*预热辊速度系数*)
		i_pastStGrpParam_Save^[iGrp].rGirth_HotRoller_PreHot 						:=628		;        (*预热辊周长*)
		i_pastStGrpParam_Save^[iGrp].iPreAirHotRollTorque 							:=0		;           (*预热辊转矩*)
		i_pastStGrpParam_Save^[iGrp].uiDen_HotRoller_PreHot 						:=21		;         (*预热辊减速比分母*)
		i_pastStGrpParam_Save^[iGrp].uiNum_HotRoller_PreHot 						:=8		;         (*预热辊减速比分子*)
		i_pastStGrpParam_Save^[iGrp].iPreHotRoller_Velocity_Water 					:=1500		;   (*水冷辊额定转速*)
		i_pastStGrpParam_Save^[iGrp].rStandardFreq_HotRoller_Water 					:=50		;  (*水冷辊额定频率*)
		i_pastStGrpParam_Save^[iGrp].rUpperFreq_HotRoller_Water 					:=50		;     (*水冷辊上限频率*)
		i_pastStGrpParam_Save^[iGrp].rCoeff_HotRoller_Water 						:=1		;         (*水冷辊速度系数*)
		i_pastStGrpParam_Save^[iGrp].rGirth_HotRoller_Water 						:=628		;         (*水冷辊周长*)
		i_pastStGrpParam_Save^[iGrp].uiDen_HotRoller_Water 							:=21		;          (*水冷辊减速比分母*)
		i_pastStGrpParam_Save^[iGrp].uiNum_HotRoller_Water 							:=8		;			(*水冷辊减速比分子*)
		i_pastStGrpParam_Save^[iGrp].byHotBlowerStopDelayTime 						:=0		;		  (*热风停止延时*)
		i_pastStGrpParam_Save^[iGrp].byFreqMin_HotWind 								:=10		;				(*热风最小频率*)
		i_pastStGrpParam_Save^[iGrp].byFreqMax_HotWind 								:=50		;				(*热风最大频率*)
		i_pastStGrpParam_Save^[iGrp].iTime_PreDrvAcc_Rw 							:=8		;         	  (*收料预驱加速时间*)
		i_pastStGrpParam_Save^[iGrp].iTime_PreDrvDec_Rw 							:=2		;         	  (*收料预驱减速时间*)
		i_pastStGrpParam_Save^[iGrp].iTime_PreDrvAcc_Uw 							:=8		;         	  (*放料预驱加速时间*)
		i_pastStGrpParam_Save^[iGrp].iTime_PreDrvDec_Uw 							:=2		;         	  (*放料预驱减速时间*)
		i_pastStGrpParam_Save^[iGrp].byDelayTime_PressDneInPrint_If 				:=5		;		 (*放牵压辊延时*)
		i_pastStGrpParam_Save^[iGrp].byAxisInitPhaseTypeWhenPreRegister 			:=0		;              	(*预套准初始位置*)
		i_pastStGrpParam_Save^[iGrp].rAdjVal_PerTime_Fine 							:=0.5		;(*手动细调调整量*)
		i_pastStGrpParam_Save^[iGrp].rAdjVal_PerTime_Coarse 						:=5		;(*手动粗调调整量*)
		i_pastStGrpParam_Save^[iGrp].rVel_HorzPreRegister 							:=0.5		;(*横向预套准速度*)
		i_pastStGrpParam_Save^[iGrp].rVel_Tar_9905									:=100		;
		i_pastStGrpParam_Save^[iGrp].iMicron_StepTest1_V							:=500		;
		i_pastStGrpParam_Save^[iGrp].iMicron_StepTest2_V							:=0			;
		i_pastStGrpParam_Save^[iGrp].R_0_RW											:=0.31		;	
		i_pastStGrpParam_Save^[iGrp].a0_0_RW	        							:=0			;
		i_pastStGrpParam_Save^[iGrp].b1_0_RW	        							:=0.016		;
		i_pastStGrpParam_Save^[iGrp].Wn_0_RW	        							:=4.3		;
		i_pastStGrpParam_Save^[iGrp].Beta_0_RW	    								:=0.22		;
		i_pastStGrpParam_Save^[iGrp].l_0_RW	        								:=1			;
		i_pastStGrpParam_Save^[iGrp].K_PI_RW	        							:=1			;
		i_pastStGrpParam_Save^[iGrp].a_RW	            							:=4			;
		i_pastStGrpParam_Save^[iGrp].b_RW	            							:=0			;
		i_pastStGrpParam_Save^[iGrp].Ts_RW	            							:=20.0/1000	;
		i_pastStGrpParam_Save^[iGrp].Range_RW	        							:=13.8		;
		i_pastStGrpParam_Save^[iGrp].Theta_RW	        							:=25.64		;
		i_pastStGrpParam_Save^[iGrp].K_adj_RW	        							:=1.3		;
		i_pastStGrpParam_Save^[iGrp].R_0_UW											:=0.31		;
		i_pastStGrpParam_Save^[iGrp].a0_0_UW     									:=0			;
		i_pastStGrpParam_Save^[iGrp].b1_0_UW     									:=0.016		;
		i_pastStGrpParam_Save^[iGrp].Wn_0_UW     									:=4.3		;
		i_pastStGrpParam_Save^[iGrp].Beta_0_UW   									:=0.22		;
		i_pastStGrpParam_Save^[iGrp].l_0_UW      									:=1			;
		i_pastStGrpParam_Save^[iGrp].K_PI_UW     									:=1			;
		i_pastStGrpParam_Save^[iGrp].a_UW        									:=4			;
		i_pastStGrpParam_Save^[iGrp].b_UW        									:=0			;
		i_pastStGrpParam_Save^[iGrp].Ts_UW       									:=20.0/1000	;
		i_pastStGrpParam_Save^[iGrp].Range_UW    									:=13.8		;
		i_pastStGrpParam_Save^[iGrp].Theta_UW    									:=25.64		;
		i_pastStGrpParam_Save^[iGrp].K_adj_UW    									:=1.3		;
		i_pastStGrpParam_Save^[iGrp].rFilmLenth_InUnit 								:=8.54		;
		i_pastStGrpParam_Save^[iGrp].xWorkMode_RollerPress							:= TRUE;
		
(*2025.8.13.114902*)
		i_pastStGrpParam_Save^[iGrp].iRatedRpm_InkRoller:= 1500;(*递墨辊变频额定转速|*)
		i_pastStGrpParam_Save^[iGrp].iRatedFreq_InkRoller:= 50;(*递墨辊变频额定频率|*)
		i_pastStGrpParam_Save^[iGrp].iUpperFreq_InkRoller:= 50;(*递墨辊变频上限频率|*)
		i_pastStGrpParam_Save^[iGrp].iVel_InkRollerMin:= 10;(*递墨辊最小频率对应的最小速度|*)
		i_pastStGrpParam_Save^[iGrp].iFrq_InkRollerMin:= 10;(*递墨辊变频最小频率|*)
		i_pastStGrpParam_Save^[iGrp].iVel_InkRollerMax:= 300;(*递墨辊变频最大频率对应的最大速度*)
		i_pastStGrpParam_Save^[iGrp].iFrq_InkRollerMax:= 50;(*递墨辊变频最大频率|*)	
		i_pastStGrpParam_Save^[iGrp].rHz_Scraper_ManuallySet:= 10;
		i_pastStGrpParam_Save^[iGrp].rHz_InkRoller_ManuallySet:= 10;		
		
		
		//2025.10.20.165114
		i_pastStGrpParam_Save^[iGrp].byFreqUpper_ExhaustAir:= 50;
		i_pastStGrpParam_Save^[iGrp].uiFreqCoeff_Auto_ExhaustAir:=100;(*放大了100倍*)
		i_pastStGrpParam_Save^[iGrp].byFreqMax_ExhaustAir:=50;
		i_pastStGrpParam_Save^[iGrp].byFreqMin_ExhaustAir:=10;		
		i_pastStGrpParam_Save^[iGrp].xWorkMode_ManuAdj:=FALSE;// BOOL;
		
		i_pastStGrpParam_Save^[iGrp].lrFilmLen_UnwindToPU1:= 8000;		
			(*定义为幅数@2024.7.31.165620*)
		i_pastStGrpParam_Save^[iGrp].lrFilmLen_NotAdjFront:= 6;
		i_pastStGrpParam_Save^[iGrp].lrFilmLen_NotAdjBack:= 3;		
		i_pastStGrpParam_Save^[iGrp].byTurnOverAxisId:=10;	
		i_pastStGrpParam_Save^[iGrp].xPreRegisterAxisId_Manu:=FALSE;(*2025.1.12.185956+*)		
		
//2026.5.13.144116

		//扩展参数默认值
		i_pastStGrpParam_Save_RSV^[iGrp].rWidth_Mark_Max := 10;(*单个色标最大宽度 mm*)
		i_pastStGrpParam_Save_RSV^[iGrp].rWidth_Mark_Min := 1;(*单个色标最xiao宽度 mm*)
		i_pastStGrpParam_Save_RSV^[iGrp].rMaxGap := 10;(*最大间隙，mm*)
		i_pastStGrpParam_Save_RSV^[iGrp].bySimilarityThreshold:= 30;(*相似度阈值*)
		i_pastStGrpParam_Save_RSV^[iGrp].bySignalType:=3;(*信号类型，1科赛标 2普通标 3北人标，暂不支持其他标*)
		i_pastStGrpParam_Save_RSV^[iGrp].xSpecialMarkEn	:=FALSE;(*特殊标有效*)
		i_pastStGrpParam_Save_RSV^[iGrp].byMeanOffset := 8;(*均值偏移 越大越找不到小色标，太小会出现较多信号导致直接失败*)
		i_pastStGrpParam_Save_RSV^[iGrp].iFiberMoveVel:= 40;(*光纤行走速度*)
		i_pastStGrpParam_Save_RSV^[iGrp].iFiberMoveVel_Fast:= 60;(*光纤行走速度_快速*) 
		i_pastStGrpParam_Save_RSV^[iGrp].xUseOnline_FiberMove:= FALSE;(*使用在线检测*) 
		i_pastStGrpParam_Save_RSV^[iGrp].xFiberMove_Negative_AdjustByUnit:= FALSE;(*色组修正取反*) 
		i_pastStGrpParam_Save_RSV^[iGrp].xFiberMove_Negative_AdjustByOnline:= FALSE;(*在线修正取反*)
		i_pastStGrpParam_Save_RSV^[iGrp].xSwitch_EnFastPress:=TRUE;//当前色找到就合压开关使能
		i_pastStGrpParam_Save_RSV^[iGrp].rOuterCoff := 1.2 ;//外滑窗系数 real 0.5~2
		i_pastStGrpParam_Save_RSV^[iGrp].rInnerCoff	:=0.3;	//内滑窗系数 real 0.2~byOuterCoff
		i_pastStGrpParam_Save_RSV^[iGrp].arFiberMove[1]	:= -3;//光纤粗调移动距离 两个限制-10,10
		i_pastStGrpParam_Save_RSV^[iGrp].arFiberMove[2]	:= 6;//光纤粗调移动距离 两个限制-10,10
		//模版信息 0.1mm	
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[1]:= 10;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[2]:= 3;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[3]:= 1.5;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[4]:= 6;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[5]:= 51;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[6]:= 56;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[7]:= 112;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[8]:= 76.5;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[9]:= 32;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[10]:= 83;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[11]:= 1.5;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[12]:= 2;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[13]:= 0;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[14]:= 0;
		i_pastStGrpParam_Save_RSV^[iGrp].arModeMsg[15]:= 0;
		i_pastStGrpParam_Save_RSV^[iGrp].rSpotWidth:=1.5; //光斑宽度1.5
		//2026.05.14.114400 新增
		i_pastStGrpParam_Save_RSV^[iGrp].xIsAutoStop:=FALSE;
		i_pastStGrpParam_Save_RSV^[iGrp].rRemainDia_stop:=95;	
		i_pastStGrpParam_Save_RSV^[iGrp].rMaxErr_GantryTrap:=3;
		i_pastStGrpParam_Save_RSV^[iGrp].rVel_CoronaVel:=0;

		
	END_FOR
	iResult:=1;
ELSE
	iResult:=-1;
END_IF
