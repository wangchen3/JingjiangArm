(*@CES
Name=KS_RstUnitParam_Save
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7648ef96-3be4-4568-b3eb-0b6ef16921e6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstUnitParam_Save : INT
VAR_INPUT
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStUnitParam_Save: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StUnitParam_Save;
	i_pastStUnitParam_Save_RSV: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StRSV_UnitParam_Save;
END_VAR
VAR
	iUnit: INT;
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:=0;

IF i_pastStUnitParam_Save<>0 AND i_pastStUnitParam_Save_RSV<>0 THEN
	FOR iUnit:=1 TO MAX_UNIT_NUM BY 1 DO
		SysMemSet(ADR(i_pastStUnitParam_Save_RSV^[iUnit].abyRSV_UnitParam_Save),
					0, 
					SIZEOF(i_pastStUnitParam_Save_RSV^[iUnit].abyRSV_UnitParam_Save));
		i_pastStUnitParam_Save^[iUnit].byGrpId											:= 1;
		i_pastStUnitParam_Save^[iUnit].rGirth_BottomRoller                              := 1005.2154;
		i_pastStUnitParam_Save^[iUnit].uiNum_BottomRoller                               := 8;
		i_pastStUnitParam_Save^[iUnit].uiDen_BottomRoller                               := 1;
		i_pastStUnitParam_Save^[iUnit].rGirth_PrnRoller                                 := 500;
		i_pastStUnitParam_Save^[iUnit].uiNum_PrnRoller                                  := 1;
		i_pastStUnitParam_Save^[iUnit].uiDen_PrnRoller                                  := 1;
		i_pastStUnitParam_Save^[iUnit].rGirth_NetRoller                                 := 502.6548;
		i_pastStUnitParam_Save^[iUnit].uiNum_NetRoller                                  := 1;
		i_pastStUnitParam_Save^[iUnit].uiDen_NetRoller                                  := 1;
		i_pastStUnitParam_Save^[iUnit].rLength_Band                                     := 1000;
		i_pastStUnitParam_Save^[iUnit].rErrLength_Band                                  := 0;
		i_pastStUnitParam_Save^[iUnit].rGirth_StrRoller                                 := 500;
		i_pastStUnitParam_Save^[iUnit].uiNum_StrRoller                                  := 1;
		i_pastStUnitParam_Save^[iUnit].uiDen_StrRoller                                  := 1;
		i_pastStUnitParam_Save^[iUnit].rScrewPitch_Horz                                 := 5;
		i_pastStUnitParam_Save^[iUnit].uiNum_Horz                                       := 1;
		i_pastStUnitParam_Save^[iUnit].uiDen_Horz                                       := 1;
		i_pastStUnitParam_Save^[iUnit].lrLimit_Operate_Horz                             := 0;
		i_pastStUnitParam_Save^[iUnit].lrLimit_Driver_Horz                              := 0;
		i_pastStUnitParam_Save^[iUnit].wCtlmod_PrnRoller_Pressure                       := 1;
		i_pastStUnitParam_Save^[iUnit].rScrewPitch_PrnRoller_Pressure                   := 4;
		i_pastStUnitParam_Save^[iUnit].uiNum_PrnRoller_Pressure                         := 40;
		i_pastStUnitParam_Save^[iUnit].uiDen_PrnRoller_Pressure                         := 1;
		i_pastStUnitParam_Save^[iUnit].rScrewPitch_NetRoller_Pressure                   := 2;
		i_pastStUnitParam_Save^[iUnit].uiNum_NetRoller_Pressure                         := 3;
		i_pastStUnitParam_Save^[iUnit].uiDen_NetRoller_Pressure                         := 1;
		i_pastStUnitParam_Save^[iUnit].rScrewPitch_StrRoller_Pressure                   := 2;
		i_pastStUnitParam_Save^[iUnit].uiNum_StrRoller_Pressure                         := 3;
		i_pastStUnitParam_Save^[iUnit].uiDen_StrRoller_Pressure                         := 1;
		i_pastStUnitParam_Save^[iUnit].rMovementHiSpd_PrnRoller_Pressure                := 10;
		i_pastStUnitParam_Save^[iUnit].rMovementHiSpd_NetRoller_Pressure                := 10;
		i_pastStUnitParam_Save^[iUnit].rMovementLoSpd_PrnRoller_Pressure                := 5;
		i_pastStUnitParam_Save^[iUnit].rMovementLoSpd_NetRoller_Pressure                := 5;
		i_pastStUnitParam_Save^[iUnit].rPos_press_dn_PrnRoller_Pressure_M               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_dn_PrnRoller_Pressure_G               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_up_PrnRoller_Pressure_M               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_up_PrnRoller_Pressure_G               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_load_unload_PrnRoller_Pressure_M            := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_load_unload_PrnRoller_Pressure_G            := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_dn_NetRoller_Pressure_M               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_dn_NetRoller_Pressure_G               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_up_NetRoller_Pressure_M               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_up_NetRoller_Pressure_G               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_load_unload_NetRoller_Pressure_M            := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_load_unload_NetRoller_Pressure_G            := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_dn_StrRoller_Pressure_M               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_dn_StrRoller_Pressure_G               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_up_StrRoller_Pressure_M               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_press_up_StrRoller_Pressure_G               := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_load_unload_StrRoller_Pressure_M            := 0;
		i_pastStUnitParam_Save^[iUnit].rPos_load_unload_StrRoller_Pressure_G            := 0;
		i_pastStUnitParam_Save^[iUnit].rGirth_Confirmed_press_dn_PrnRoller              := 520;
		i_pastStUnitParam_Save^[iUnit].rGirth_Confirmed_press_dn_NetRoller              := 508.94;
		i_pastStUnitParam_Save^[iUnit].rGirth_Confirmed_press_dn_StrRoller              := 500;
//		i_pastStUnitParam_Save^[iUnit].bySts_PrfPosAndEncPosDir                         := 0;
//		i_pastStUnitParam_Save^[iUnit].bySts_PrfPosAndActEncPosDirDir                   := 0;
		i_pastStUnitParam_Save^[iUnit].wFlag_PressFun                                   := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncZeroPos_PrnRoller_Pressure_M             := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncZeroPos_PrnRoller_Pressure_G             := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncZeroPos_NetRoller_Pressure_M             := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncZeroPos_NetRoller_Pressure_G             := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncLimMin_PrnRoller_Pressure_M              := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncLimMax_PrnRoller_Pressure_G              := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncLimMin_NetRoller_Pressure_M              := 0;
		i_pastStUnitParam_Save^[iUnit].lrAbsEncLimMax_NetRoller_Pressure_G              := 0;
		i_pastStUnitParam_Save^[iUnit].xConfirmAbsEncZeroPosDne_PrnRoller_Pressure_M    := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmAbsEncZeroPosDne_PrnRoller_Pressure_G    := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmAbsEncZeroPosDne_NetRoller_Pressure_M    := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmAbsEncZeroPosDne_NetRoller_Pressure_G    := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmload_unloadPosDne_PrnRoller_Pressure_M   := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmload_unloadPosDne_PrnRoller_Pressure_G   := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmload_unloadPosDne_NetRoller_Pressure_M   := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmload_unloadPosDne_NetRoller_Pressure_G   := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmDnPosDne_PrnRoller_Pressure_M            := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmDnPosDne_PrnRoller_Pressure_G            := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmDnPosDne_NetRoller_Pressure_M            := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmDnPosDne_NetRoller_Pressure_G            := FALSE;
		i_pastStUnitParam_Save^[iUnit].xEnable_arc                                      := TRUE;
		IF i_pastStUnitParam_Save^[iUnit].byGrpId<>1 AND i_pastStUnitParam_Save^[iUnit].byGrpId<>2 THEN
			i_pastStUnitParam_Save^[iUnit].byGrpId:= 1;
		END_IF
		
		i_pastStUnitParam_Save^[iUnit].iMarkTypeId                                      := 
				i_pstStSysParam^.astStGrpParam_Save[i_pastStUnitParam_Save^[iUnit].byGrpId].iMarkTypeId;
		i_pastStUnitParam_Save^[iUnit].iMarkArrangeMode                                 :=
				i_pstStSysParam^.astStGrpParam_Save[i_pastStUnitParam_Save^[iUnit].byGrpId].iMarkArrangeMode;
		i_pastStUnitParam_Save^[iUnit].iGateWidthPhy                                    := 20;
		i_pastStUnitParam_Save^[iUnit].iGateWidthRoundPoints                            := 160;
		i_pastStUnitParam_Save^[iUnit].iGateWidthFinePoints                             := 1000;
		i_pastStUnitParam_Save^[iUnit].iGateSa                                          := 0;
		i_pastStUnitParam_Save^[iUnit].iGateSaEx                                        := 0;
		i_pastStUnitParam_Save^[iUnit].rAlr_V                                           := 0.2;
		i_pastStUnitParam_Save^[iUnit].rAdj_V                                           := 0;
		i_pastStUnitParam_Save^[iUnit].byAvg_V                                          := 3;
		i_pastStUnitParam_Save^[iUnit].iKp_V                                            := 2;
		i_pastStUnitParam_Save^[iUnit].iKi_V                                            := 0;
		i_pastStUnitParam_Save^[iUnit].iKd_V                                            := 0;
		i_pastStUnitParam_Save^[iUnit].rDeadzoneMin_V                                   := 0;
		i_pastStUnitParam_Save^[iUnit].rAlr_H                                           := 0.2;
		i_pastStUnitParam_Save^[iUnit].rAdj_H                                           := 0;
		i_pastStUnitParam_Save^[iUnit].byAvg_H                                          := 3;
		i_pastStUnitParam_Save^[iUnit].iKp_H                                            := 3;
		i_pastStUnitParam_Save^[iUnit].iKi_H                                            := 0;
		i_pastStUnitParam_Save^[iUnit].iKd_H                                            := 8;
		i_pastStUnitParam_Save^[iUnit].rDeadzoneMin_H                                   := 0.01;
		i_pastStUnitParam_Save^[iUnit].rDeadzoneMax_H                                   := 5;
		i_pastStUnitParam_Save^[iUnit].lrPreReg_Length_V                                := 0;
		i_pastStUnitParam_Save^[iUnit].lrFilmLengthFromPrevUnit                         := 7500;
		i_pastStUnitParam_Save^[iUnit].lrPreReg_Adjust                                  := 0;
		i_pastStUnitParam_Save^[iUnit].dwFlag_Ctl                                       := 0;
		i_pastStUnitParam_Save^[iUnit].dwFlag_Sts                                       := 0;
		i_pastStUnitParam_Save^[iUnit].diPreReg_AdjustVal_H                             := 0;
		i_pastStUnitParam_Save^[iUnit].lrAI_med_CoatingPrn                              := 0;
		i_pastStUnitParam_Save^[iUnit].xSwitchOn_CoatingPrn                             := FALSE;
		i_pastStUnitParam_Save^[iUnit].xReverseAdj_CoatingPrn                           := FALSE;
		i_pastStUnitParam_Save^[iUnit].byAdjMode_CoatingPrn                             := 0;
		i_pastStUnitParam_Save^[iUnit].iKp_CoatingPrn                                   := 30;
		i_pastStUnitParam_Save^[iUnit].iKi_CoatingPrn                                   := 30;
		i_pastStUnitParam_Save^[iUnit].iKd_CoatingPrn                                   := 60;
		i_pastStUnitParam_Save^[iUnit].bySensorType_CoatingPrn                          := 0;
		i_pastStUnitParam_Save^[iUnit].lrAI_CoatingPrn                                  := 0;
		i_pastStUnitParam_Save^[iUnit].lrGirth_Using_CoatingPrn                         := 500;
		i_pastStUnitParam_Save^[iUnit].bySignalGain                                     := 0;
		i_pastStUnitParam_Save^[iUnit].xLinkage                                         := FALSE;
		i_pastStUnitParam_Save^[iUnit].rInversedPrecision                               := 0.02;
		i_pastStUnitParam_Save^[iUnit].byCouplingMask                                   := 1;
		i_pastStUnitParam_Save^[iUnit].rHigh_Prn_Roller                                 := 50;
		i_pastStUnitParam_Save^[iUnit].rHigh_Net_Roller                                 := 50;
		i_pastStUnitParam_Save^[iUnit].rweigth_Prn_Bottom_Confirm                       := 0;
		i_pastStUnitParam_Save^[iUnit].rweigth_Prn_Net_Confirm                          := 0;
		i_pastStUnitParam_Save^[iUnit].rweigth_Net_Prn_Confirm                          := 0;
		i_pastStUnitParam_Save^[iUnit].rweigth_Net_Load_Confirm                         := 0;
		i_pastStUnitParam_Save^[iUnit].dwColor_Print                                    := 0;
		i_pastStUnitParam_Save^[iUnit].wLines_Net_Roller                                := 500;
		i_pastStUnitParam_Save^[iUnit].rStep_Pressure_Prn_Net                           := 0;
		i_pastStUnitParam_Save^[iUnit].xConfirmDnPosDne_StrRoller_Pressure_M            := FALSE;
		i_pastStUnitParam_Save^[iUnit].xConfirmDnPosDne_StrRoller_Pressure_G            := FALSE;
		i_pastStUnitParam_Save^[iUnit].lrEncPosPrintDn_Prn_M                            := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosPrintDn_Prn_G                            := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosPrintDn_Net_M                            := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosPrintDn_Net_G                            := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosPrintDn_Str_M                            := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosPrintDn_Str_G                            := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosParallel_Prn_M                           := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosParallel_Prn_G                           := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosParallel_Net_M                           := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosParallel_Net_G                           := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosParallel_Str_M                           := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosParallel_Str_G                           := 0;
		i_pastStUnitParam_Save^[iUnit].lrPrintPosOffsetDn_Prn_M                         := 0;
		i_pastStUnitParam_Save^[iUnit].lrPrintPosOffsetDn_Prn_G                         := 0;
		i_pastStUnitParam_Save^[iUnit].lrPrintPosOffsetDn_Net_M                         := 0;
		i_pastStUnitParam_Save^[iUnit].lrPrintPosOffsetDn_Net_G                         := 0;
		i_pastStUnitParam_Save^[iUnit].lrPrintPosOffsetDn_Str_M                         := 0;
		i_pastStUnitParam_Save^[iUnit].lrPrintPosOffsetDn_Str_G                         := 0;
//		i_pastStUnitParam_Save^[iUnit].adiEncPos_Start_Virtual_0                        := 0;
		i_pastStUnitParam_Save^[iUnit].diEncPos_Start_Virtual_0                         := 0;
		i_pastStUnitParam_Save^[iUnit].diSampleNum                                      := 1;
		i_pastStUnitParam_Save^[iUnit].diSampleDen                                      := 1;
		i_pastStUnitParam_Save^[iUnit].liABSPos_Prn_M                                   := 0;
		i_pastStUnitParam_Save^[iUnit].liABSPos_Prn_G                                   := 0;
		i_pastStUnitParam_Save^[iUnit].liABSPos_Net_M                                   := 0;
		i_pastStUnitParam_Save^[iUnit].liABSPos_Net_G                                   := 0;
		i_pastStUnitParam_Save^[iUnit].liABSPos_Str_M                                   := 0;
		i_pastStUnitParam_Save^[iUnit].liABSPos_Str_G                                   := 0;
		i_pastStUnitParam_Save^[iUnit].axPressLimit_Min[1]                                 := FALSE;
		i_pastStUnitParam_Save^[iUnit].axPressLimit_Min[2]                                 := FALSE;
		i_pastStUnitParam_Save^[iUnit].axPressLimit_Min[3]                                 := FALSE;
		i_pastStUnitParam_Save^[iUnit].axPressLimit_Max[1]                                 := FALSE;
		i_pastStUnitParam_Save^[iUnit].axPressLimit_Max[2]                                 := FALSE;
		i_pastStUnitParam_Save^[iUnit].axPressLimit_Max[3]                                 := FALSE;
		i_pastStUnitParam_Save^[iUnit].lrEncPosLimit_Prn_M_Max                          := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosLimit_Prn_G_Max                          := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosLimit_Net_M_Max                          := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosLimit_Net_G_Max                          := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosLimit_Str_M_Max                          := 0;
		i_pastStUnitParam_Save^[iUnit].lrEncPosLimit_Str_G_Max                          := 0;
		i_pastStUnitParam_Save^[iUnit].rLength_Printing                                 := 1040.68;
		i_pastStUnitParam_Save^[iUnit].iBandLengthFilterCnt                             := 10;
		i_pastStUnitParam_Save^[iUnit].iCoefOfCoupling_V                                := 100;
		i_pastStUnitParam_Save^[iUnit].byFollowColorId                                  := 0;
		i_pastStUnitParam_Save^[iUnit].xWaitFilmLenth_Follow1U                          := FALSE;
		i_pastStUnitParam_Save^[iUnit].wButtonFun_Lamp                                  := 0;
		i_pastStUnitParam_Save^[iUnit].wSwitchFun										:= 0;
//		i_pastStUnitParam_Save^[iUnit].dwSlaveBtn_HMI                                   := 0;
		i_pastStUnitParam_Save^[iUnit].rLong_Step_Roller_Pressure                       := 5;
		i_pastStUnitParam_Save^[iUnit].rShort_Step_Roller_Pressure                      := 0.5;
		i_pastStUnitParam_Save^[iUnit].rSV_UnitTemCtl                                   := 50;
		i_pastStUnitParam_Save^[iUnit].dwCtlBits_UnitBaseCraft                          := 0;
		i_pastStUnitParam_Save^[iUnit].rHz_UnitInkRoller_ManuallySet                    := 20;
		i_pastStUnitParam_Save^[iUnit].rCoeff_UnitInkRoller_Auto                        := 1;

		i_pastStUnitParam_Save^[iUnit].rHz_UnitScraper_ManuallySet                      := 20;
		i_pastStUnitParam_Save^[iUnit].rCoeff_UnitScraper_Auto                          := 1;
		i_pastStUnitParam_Save^[iUnit].rHz_UnitHotWind_ManuallySet                      := 20;
		i_pastStUnitParam_Save^[iUnit].rHz_UnitHotWind_2_ManuallySet                    := 20;
		i_pastStUnitParam_Save^[iUnit].byHotBlower_AO                                   := 20;
		i_pastStUnitParam_Save^[iUnit].wAirReturnWindDoorValue                          := 50;
		i_pastStUnitParam_Save^[iUnit].wAirExhaustWindDoorValue                         := 50;
		i_pastStUnitParam_Save^[iUnit].rHz_UnitExhaust_ManuallySet              		  := 20;

		i_pastStUnitParam_Save^[iUnit].bySignalSelect                                   := 0;
		i_pastStUnitParam_Save^[iUnit].rOffset_T1:=1.73;
		i_pastStUnitParam_Save^[iUnit].rSource_Light_T1:=0.15;
		i_pastStUnitParam_Save^[iUnit].rBias_T1:=2;
		i_pastStUnitParam_Save^[iUnit].rBrightness_Light_T1:=0.15;
		i_pastStUnitParam_Save^[iUnit].rOffset_T2:=1.73;
		i_pastStUnitParam_Save^[iUnit].rSource_Light_T2:=0.15;
		i_pastStUnitParam_Save^[iUnit].rBias_T2:=2;
		i_pastStUnitParam_Save^[iUnit].rBrightness_Light_T2:=0.15;
		
		i_pastStUnitParam_Save^[iUnit].rK_ArcErr_Lp:= 30;
		i_pastStUnitParam_Save^[iUnit].rFilmLengthFromPrevPressUnit:=8000;(*mm*)
		
		i_pastStUnitParam_Save^[iUnit].byAve_v_extra:= 3;
		i_pastStUnitParam_Save^[iUnit].xWaitFilmLenth_FollowPreU:= FALSE;
		(*增加参数初始化2025.3.5.161313-套色新算法参数相关*)
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.xUse_NewArcMol		:= FALSE;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.xUsePID_Mol			:= FALSE;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rKadj_PID_Mol		:= 20;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rKadj_I_Mol			:= 1.5;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.byKadj_SetType		:= 0;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rKadj_PID_Mol_SteadySts:= 20;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rKadj_I_Mol_SteadySts:= 1;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rMargin_Mag_Arc		:= 20;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rMargin_Phi_Arc		:= 50;
	
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.xUseAntiNotch_Arc	:= FALSE;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rWn_Arc				:= 0.08;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rBw_Arc				:= 0.08;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rDp_Arc				:= 10;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.xUsePeriodic		:= FALSE;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rG_Periodic			:= 0.5;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rW_Periodic			:= 2;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.stStArcSpeedUpParam.rK:= 1;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.stStArcSpeedUpParam.rA2:= 40;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.stStArcSpeedUpParam.rA1:= 6;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.stStArcSpeedUpParam.rA0:= 0.01;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.stStArcSpeedUpFeedforward.rK:= 2000;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.stStArcSpeedUpFeedforward.rK_2:= 2000;
		
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rKp_GC:= 16;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rKi_GC:= 15;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rKd_GC:=0;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.rN_GC:= 0;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.xCompensateEn_H:=FALSE;
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.byCompensateValue_Hor:=50;(*丝*)
		i_pastStUnitParam_Save^[iUnit].stStArc_Mol_Param.byMaxAddValue_Total_Hor:=5;(*mm*)

			(*新增变量|wang.nt|2025.08.07.204018*)
		i_pastStUnitParam_Save^[iUnit].rStep_OfChangeGirth 					:= 0.01;  (*涂布版轴修改步幅*)
		i_pastStUnitParam_Save^[iUnit].uiTimeMs_RollerPressUpKeep 			:= 0;      (*压辊双气缸-离压保持时间*)
		//9905界面内容	
		i_pastStUnitParam_Save^[iUnit].rAxisVelPrf_Coeff1 					:= -200	;
		i_pastStUnitParam_Save^[iUnit].rAxisVelPrf_Coeff2 					:= 0.03	;
		i_pastStUnitParam_Save^[iUnit].rAxisVelPrf_Coeff3 					:= 1	;
		i_pastStUnitParam_Save^[iUnit].rMargin_Mag_Arc 						:= 20	;
		i_pastStUnitParam_Save^[iUnit].rMargin_Phi_Arc 						:= 50	;
		i_pastStUnitParam_Save^[iUnit].rKp_MolCal 							:= 16	;
		i_pastStUnitParam_Save^[iUnit].rKi_MolCal 							:= 8	;
		i_pastStUnitParam_Save^[iUnit].rFilmLengthFromPrevPressUnit 		:= 8000	;
		i_pastStUnitParam_Save^[iUnit].byCompensateValue_Hor 				:= 50	;
		i_pastStUnitParam_Save^[iUnit].byMaxAddValue_Total_Hor 				:= 5	;
		i_pastStUnitParam_Save^[iUnit].rWn_Arc 								:= 0.08	;
		i_pastStUnitParam_Save^[iUnit].rBw_Arc 								:= 0.08	;
		i_pastStUnitParam_Save^[iUnit].rDp_Arc 								:= 10	;
		i_pastStUnitParam_Save^[iUnit].rK 									:= 1	;
		i_pastStUnitParam_Save^[iUnit].rA2 									:= 40	;
		i_pastStUnitParam_Save^[iUnit].rA1 									:= 6	;
		i_pastStUnitParam_Save^[iUnit].rA0 									:= 0.01	;
		i_pastStUnitParam_Save^[iUnit].rG_Periodic 							:= 0.5 	;
		i_pastStUnitParam_Save^[iUnit].rW_Periodic 							:= 2	;
		(*2025.8.13.144044增加*)
		i_pastStUnitParam_Save^[iUnit].xFlag_InkRollerRisen:= FALSE;(*2018.7.28.101609\递墨辊升起标志|*)			
		i_pastStUnitParam_Save^[iUnit].lrPreReg_ConstVal                          := 6000;	
		(*2026.02.28.134214 超旭照明默认开 Hou.N*)
		i_pastStUnitParam_Save^[iUnit].wButtonAndSwitch_ChaoXu.4                          := TRUE;	
	END_FOR
	iResult:=1;
ELSE
	iResult:=-1;
END_IF
