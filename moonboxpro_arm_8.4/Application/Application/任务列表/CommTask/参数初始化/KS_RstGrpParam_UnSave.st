(*@CES
Name=KS_RstGrpParam_UnSave
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=192eb973-c984-42d3-866b-81e626ce7a5f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstGrpParam_UnSave : INT
VAR_INPUT
	i_pastStGrpParam_UnSave: POINTER TO ARRAY [1..2] OF StGrpParam_UnSave;
	i_pastStGrpParam_UnSave_RSV: POINTER TO ARRAY [1..2] OF StRSV_GrpParam_UnSave;
END_VAR
VAR
	iGrp: INT;
	iResult: INT;	
	iT: INT;
END_VAR

{IMPLEMENTATION}
iResult:=0;

IF i_pastStGrpParam_UnSave<>0 AND i_pastStGrpParam_UnSave_RSV<>0 THEN
	FOR iGrp:=1 TO 2 BY 1 DO
		SysMemSet(ADR(i_pastStGrpParam_UnSave_RSV^[iGrp].abyRSV_StGrpParam_UnSave),
					0, 
					SIZEOF(i_pastStGrpParam_UnSave_RSV^[iGrp].abyRSV_StGrpParam_UnSave));
		i_pastStGrpParam_UnSave^[iGrp].xCutterOnTop_Uw						:= TRUE;
		i_pastStGrpParam_UnSave^[iGrp].iDebugVelmpm_AxisA_Uw                := 100;
		i_pastStGrpParam_UnSave^[iGrp].iDebugGirthmm_AxisA_Uw               := 300;
		i_pastStGrpParam_UnSave^[iGrp].iDebugVelmpm_AxisB_Uw                := 100;
		i_pastStGrpParam_UnSave^[iGrp].iDebugGirthmm_AxisB_Uw               := 300;
		i_pastStGrpParam_UnSave^[iGrp].iDebugVelmpm_AxisA_Rw                := 100;
		i_pastStGrpParam_UnSave^[iGrp].iDebugGirthmm_AxisA_Rw               := 300;
		i_pastStGrpParam_UnSave^[iGrp].iDebugVelmpm_AxisB_Rw                := 100;
		i_pastStGrpParam_UnSave^[iGrp].iDebugGirthmm_AxisB_Rw               := 300;
		i_pastStGrpParam_UnSave^[iGrp].xMachineRev                          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].iPromptMsg                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].iAlarm_TypeId                        := 0;
		i_pastStGrpParam_UnSave^[iGrp].iAlarm_UnitId                        := 0;
		i_pastStGrpParam_UnSave^[iGrp].iIdGSE                               := GSE_STOP;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Stop                           := TRUE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreStart                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Ink                            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_InkAccing                      := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Tension                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_TensionDone                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Print                          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Estop                          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AutoAcc                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AutoDec                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_ManuAcc                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_ManuDec                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Accing                         := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Decing                         := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_EStoping                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Stoping                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_GotoInking                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_InPressing                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_RollerPressDone                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_InchRun                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AllInchRun                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AllPress                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AllUnpress                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_RollerPressAtLeast1            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].axFlag_PrnLen_Alarm[1]                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].axFlag_PrnLen_Alarm[2]                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].axFlag_PrnLen_Alarm[3]                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_LinkageAxisAlarm               := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_TensionUnfinished              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_VelTooHigh                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PrestartTimeout                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_KeepAlarming                   := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_ArrivedToTargetVel             := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_FilmAccDecDone                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xSlowStopTenEn                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xIsDebugMode_Machine                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].uiFilmThickNess                      := 20;
		i_pastStGrpParam_UnSave^[iGrp].abyClrPrnLenCount_Rw[1]                 := 0;
		i_pastStGrpParam_UnSave^[iGrp].abyClrPrnLenCount_Rw[2]                 := 0;
		i_pastStGrpParam_UnSave^[iGrp].abyClrPrnLenCount_Rw[3]                 := 0;
		i_pastStGrpParam_UnSave^[iGrp].iTimeSec_AccDec_AllTheWay            := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAccDecTime_ThisTime                 := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Diam_Axis_Hmi[1]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Diam_Axis_Hmi[2]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Diam_Axis_Hmi[3]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Diam_Axis_Hmi[4]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Volt_Axis_Hmi[1]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Volt_Axis_Hmi[2]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Volt_Axis_Hmi[3]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Volt_Axis_Hmi[4]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Coef_Axis_Hmi[0]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Coef_Axis_Hmi[1]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Coef_Axis_Hmi[2]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Coef_Axis_Hmi[3]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].alrStdVol_Coef_Axis_Hmi[4]              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rVel_Cur                             := 0;
		i_pastStGrpParam_UnSave^[iGrp].rVel_Film                            := 0;
		i_pastStGrpParam_UnSave^[iGrp].iSid_AxisA_Uw                        := 112;
		i_pastStGrpParam_UnSave^[iGrp].xStationOnline_AxisA_Uw              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMotRev_AxisA_Uw                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].iSid_AxisB_Uw                        := 113;
		i_pastStGrpParam_UnSave^[iGrp].xStationOnline_AxisB_Uw              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMotRev_AxisB_Uw                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAI_Uw                               := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_Act_Uw                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_HMI_Uw                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_DiamMeasure_Uw                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].arKpid_Current_Uw[1]                    := 20;
		i_pastStGrpParam_UnSave^[iGrp].arKpid_Current_Uw[2]                    := 50;
		i_pastStGrpParam_UnSave^[iGrp].arKpid_Current_Uw[3]                    := 50;
		i_pastStGrpParam_UnSave^[iGrp].arKpid_Current_Rw[1]                    := 0;
		i_pastStGrpParam_UnSave^[iGrp].arKpid_Current_Rw[2]                    := 0;
		i_pastStGrpParam_UnSave^[iGrp].arKpid_Current_Rw[3]                    := 0;
		i_pastStGrpParam_UnSave^[iGrp].rVel_PreDrv_Uw                       := 0;
		i_pastStGrpParam_UnSave^[iGrp].xReflectionSensorValid_Uw            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xReflectSensorLoss_Uw                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rDiam_NewVol_Uw                      := 400;
		i_pastStGrpParam_UnSave^[iGrp].rTowerThetaCur_Uw                    := 0;
		i_pastStGrpParam_UnSave^[iGrp].rFilmToTowerRollerDis_Uw             := 0;
		i_pastStGrpParam_UnSave^[iGrp].xFilmTouchRoller_Uw                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xSts_PreCutting_Uw                   := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelmpmAxisA_Uw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelrpmAxisA_Uw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelmpmAxisB_Uw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelrpmAxisB_Uw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDeltaW_RPMIN_Uw                     := 0;
		i_pastStGrpParam_UnSave^[iGrp].xDebugMode_AbsEnc_Uw                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].dwAbsEncSinglePos_Uw                 := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAbsEncSPos_Cur_Uw                  := 0;
		i_pastStGrpParam_UnSave^[iGrp].byEncodeValueWr_Uw                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAIByAbsEnc_Cur_Uw                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].xCutterOnTopFroDebug_Uw              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xCurAxisAFroDebug_Uw                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAlarmBell_Uw                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xIsDebug_DiaMeasure_Uw               := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].byIsDebug_DiaMeasureArea_Uw          := 0;
		i_pastStGrpParam_UnSave^[iGrp].xIsDebuging_DiaMeasure_Uw            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xCancelDebuging_DiaMeasure_Uw        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].byAxisDebugBit_Uw                    := 0;
		i_pastStGrpParam_UnSave^[iGrp].byAxisDebugBit_Uw_2                  := 0;
		i_pastStGrpParam_UnSave^[iGrp].xEnCodeErr_Uw                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xEnCodeErr_Rw                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rPi_Value_Uw                         := 0;
		i_pastStGrpParam_UnSave^[iGrp].rForwardStep_Uw                      := 0;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAForeward_Uw                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisBForeward_Uw                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rVelRPM_Cur_Uw                       := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAxisAVelRPM_Cur_Uw                  := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAxisBVelRPM_Cur_Uw                  := 0;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_DiamCalc_ing_Uw                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_DiamCalc_end_Uw                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_DiamMeasure_end_Uw             := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreDrv_ing_Uw                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreDrv_end_Uw                  := FALSE;
		
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_end_Uw_UseInOtherPrg:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_ing_Uw_UseInOtherPrg:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_end_Uw:= TRUE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_ing_Uw:= FALSE;

		

		i_pastStGrpParam_UnSave^[iGrp].xFlag_VolDiamAlarm_Uw                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAI_DiamMeasure_HMI_Uw               := 0;
		i_pastStGrpParam_UnSave^[iGrp].xAITypeBtn_Uw                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].iSid_AxisA_Rw                        := 114;
		i_pastStGrpParam_UnSave^[iGrp].xStationOnline_AxisA_Rw              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMotRev_AxisA_Rw                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].iSid_AxisB_Rw                        := 115;
		i_pastStGrpParam_UnSave^[iGrp].xStationOnline_AxisB_Rw              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMotRev_AxisB_Rw                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAI_Rw                               := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_Act_Rw                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_HMI_Rw                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].rVel_PreDrv_Rw                       := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDiam_NewVol_Rw                      := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaper_Rw                            := 0;
		i_pastStGrpParam_UnSave^[iGrp].xSts_PreCutting_Rw                   := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelmpmAxisA_Rw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelrpmAxisA_Rw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelmpmAxisB_Rw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rDebugCurVelrpmAxisB_Rw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].xDebugMode_AbsEnc_Rw                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].dwAbsEncSinglePos_Rw                 := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAbsEncSPos_Cur_Rw                  := 0;
		i_pastStGrpParam_UnSave^[iGrp].byEncodeValueWr_Rw                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].xCutterOnTopFroDebug_Rw              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xCurAxisAFroDebug_Rw                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].x6InchFroDebug_Rw                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAlarmBell_Rw                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].byAxisDebugBit_Rw                    := 0;
		i_pastStGrpParam_UnSave^[iGrp].rPi_Value_Rw                         := 0;
		i_pastStGrpParam_UnSave^[iGrp].rForwardStep_Rw                      := 0;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAForeward_Rw                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisBForeward_Rw                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rVelRPM_Cur_Rw                       := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAxisAVelRPM_Cur_Rw                  := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAxisBVelRPM_Cur_Rw                  := 0;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_6Inch_Rw                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreDrv_ing_Rw                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreDrv_end_Rw                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_ing_Rw                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_end_Rw                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAITypeBtn_Rw                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].iSid_If                              := 120;
		i_pastStGrpParam_UnSave^[iGrp].xStationOnline_If                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMotRev_If                           := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAI_If                               := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_Act_If                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_HMI_If                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].xInchBtn_If                          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xRollerSts_If                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xRunEn_If                            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rVel_Cur_If                          := 0;
		i_pastStGrpParam_UnSave^[iGrp].rPi_Value_If                         := 0;
		i_pastStGrpParam_UnSave^[iGrp].rForwardStep_If                      := 0;
		i_pastStGrpParam_UnSave^[iGrp].rUsingGirth_If                       := 0;
		i_pastStGrpParam_UnSave^[iGrp].xInching_If                          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAITypeBtn_if                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].iSid_Of                              := 121;
		i_pastStGrpParam_UnSave^[iGrp].xStationOnline_Of                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMotRev_Of                           := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAI_Of                               := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_Act_Of                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAI_HMI_Of                           := 0;
		i_pastStGrpParam_UnSave^[iGrp].xInchBtn_Of                          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xRollerSts_Of                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xRunEn_Of                            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rVel_Cur_Of                          := 0;
		i_pastStGrpParam_UnSave^[iGrp].rPi_Value_Of                         := 0;
		i_pastStGrpParam_UnSave^[iGrp].rForwardStep_Of                      := 0;
		i_pastStGrpParam_UnSave^[iGrp].rUsingGirth_Of                       := 0;
		i_pastStGrpParam_UnSave^[iGrp].xInching_Of                          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAITypeBtn_Of                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].sCurRecipeName_InUse                 := '';
		i_pastStGrpParam_UnSave^[iGrp].dwSTS_ALL                            := 0;
		i_pastStGrpParam_UnSave^[iGrp].xAutoAccDec_Hmi                      := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_IfOf_Ink                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_FastStoping                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rFinalVelocity                       := 0;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AutoMaticCutting_Uw            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AutoMaticCutting_rw            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAutoMaticCuttingLenth_CurMode_uw    := 0;
		i_pastStGrpParam_UnSave^[iGrp].rActRemainFilmLenth_Uw               := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAutoMaticCuttingLenth_CurMode_Rw    := 0;
		i_pastStGrpParam_UnSave^[iGrp].xCurAxisDia_Uw_Wr                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xCurAxisDia_Rw_Wr                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rTaper_Cur_Uw                        := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaper_Cur_If                        := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaper_Cur_Of                        := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueBegin_Hmi_Uw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueEnd_Hmi_Uw                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueBegin_Hmi_Rw              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueEnd_Hmi_Rw                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueBegin_Hmi_If              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueEnd_Hmi_If                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueBegin_Hmi_Of              := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueEnd_Hmi_Of                := 0;
		i_pastStGrpParam_UnSave^[iGrp].byTaperUnitConfirm_Uw                := 0;
		i_pastStGrpParam_UnSave^[iGrp].byTaperUnitConfirm_Rw                := 0;
		i_pastStGrpParam_UnSave^[iGrp].byTaperUnitConfirm_If                := 0;
		i_pastStGrpParam_UnSave^[iGrp].byTaperUnitConfirm_Of                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueCur_Hmi_If                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueCur_Hmi_of                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueCur_Hmi_Uw                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rTaperValueCur_Hmi_Rw                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rValue_DiaMeasure                    := 0;
		i_pastStGrpParam_UnSave^[iGrp].rVolt_CalcDiam_Used_Watch            := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAO_Inverter_Uw_AxisA                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAO_Inverter_Uw_AxisB                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAO_Inverter_Rw_AxisA                := 0;
		i_pastStGrpParam_UnSave^[iGrp].rAO_Inverter_Rw_AxisB                := 0;
		i_pastStGrpParam_UnSave^[iGrp].xBtn_HorzPreRegister_Repeat          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xBtn_HorzPreRegister_Setup           := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xSts_HorzPreRegister                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMode_HorzPreRegister                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_HorzPreRegister_All_end        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Home                           := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Home_ing                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Home_end                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_ConfirmPreRegHomePos           := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_ConfirmPreRegHomePos_ing       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_ConfirmPreRegHomePos_end       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreRegister                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreRegister_ing                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PreRegister_end                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PhaseRestore                   := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PhaseRestore_ing               := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_PhaseRestore_end               := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xBtn_Home                            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xBtn_ConfirmPreRegHomePos            := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xBtn_PreRegister                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xBtn_PhaseSave                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xBtn_PhaseRestore                    := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_MotionParamInitialized         := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_AccDecStop                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_CENTRAL                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_CENTRAL                   := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_CENTRAL           := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_CENTRAL2                 := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_CENTRAL2                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_CENTRAL2          := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_IF                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_IF                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_IF                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_OF                       := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_OF                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_OF                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_UW_A                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_UW_A                      := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_UW_A              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_UW_B                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_UW_B                      := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_UW_B              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_RW_A                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_RW_A                      := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_RW_A              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xNetOffline_RW_B                     := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xAxisAlarm_RW_B                      := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xPosDeviationAlarm_RW_B              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_CENTRAL                := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_CENTRAL2               := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_IF                     := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_OF                     := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_UW_A                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_UW_B                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_RW_A                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].dwAlarmDetail_RW_B                   := 0;
		i_pastStGrpParam_UnSave^[iGrp].xValid_CentralDrum                   := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].iSid_CentralDrum                     := 16;
		i_pastStGrpParam_UnSave^[iGrp].xStationOnline_CentralDrum           := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xMotRev_CentralDrum                  := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAxisVel_CentralDrum                 := 0;
		i_pastStGrpParam_UnSave^[iGrp].xPrintInching                        := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rVel_Inching_Print                   := 5;
		i_pastStGrpParam_UnSave^[iGrp].xTapPosition_Breaking                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xTapPosition_UniformInk              := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xTapPosition_Printing                := FALSE;
		i_pastStGrpParam_UnSave^[iGrp].wEn_UwRw_IfOf_Center                 := 0;
		SysMemSet(ADR(i_pastStGrpParam_UnSave^[iGrp].aiMotionStep_AllStation ),
				0,
				SIZEOF(i_pastStGrpParam_UnSave^[iGrp].aiMotionStep_AllStation ));
		          
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi.iDelayMsec_CutterHolder:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi.iDelayMsec_CutOffKnifeCylinder:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi.iDelayMsec_RollerCylinder:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi.uiMM_Roller2GummedTape:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi.uiMM_Roller2CutOfKnife:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi.uiMM_CutOfKnife2GummedTape:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi.iStepVariation4ChangeTime:= 0;
		
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi.iDelayMsec_CutterHolder:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi.iDelayMsec_CutOffKnifeCylinder:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi.iDelayMsec_RollerCylinder:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi.uiMM_Roller2GummedTape:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi.uiMM_Roller2CutOfKnife:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi.uiMM_CutOfKnife2GummedTape:= 0;
		i_pastStGrpParam_UnSave^[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi.iStepVariation4ChangeTime:= 0;

		i_pastStGrpParam_UnSave^[iGrp].xPseudoRandomEn:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].byPseudoRandomId:= 1;
		i_pastStGrpParam_UnSave^[iGrp].aiTestPseudoRandom_Kp[1]:= 10;
		i_pastStGrpParam_UnSave^[iGrp].aiTestPseudoRandom_Kp[2]:= 15;
		i_pastStGrpParam_UnSave^[iGrp].aiTestPseudoRandom_Kp[3]:= 20;
		i_pastStGrpParam_UnSave^[iGrp].aiTestPseudoRandom_Kd[1]:= 20;
		i_pastStGrpParam_UnSave^[iGrp].aiTestPseudoRandom_Kd[2]:= 35;
		i_pastStGrpParam_UnSave^[iGrp].aiTestPseudoRandom_Kd[3]:= 40;
		i_pastStGrpParam_UnSave^[iGrp].xPseudoRandomTsting:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xLinkage_IfOf_Ink:=FALSE;(*2022.4.9.235740*)
		i_pastStGrpParam_UnSave^[iGrp].xCurAxisDia_Uw_Wr:= FALSE;(*2022.4.9.235740*)
		i_pastStGrpParam_UnSave^[iGrp].xCurAxisDia_Rw_Wr:= FALSE;(*2022.4.9.235740*)
		(*2024.01.19.132742*)
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_end_Uw_UseInOtherPrg:=FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Cut_end_Rw_UseInOtherPrg:=FALSE;		
		i_pastStGrpParam_UnSave^[iGrp].xFlag_Follow_1U_V_UwCut:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xKeepAlarm_NoMaterial:= FALSE;
		
		i_pastStGrpParam_UnSave^[iGrp].xKnob_6Inch_Rw:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].x6InchFroDebug_Rw		:=FALSE;(*收料6寸标志|用于调试*)
		i_pastStGrpParam_UnSave^[iGrp].xWillAutoMaticPreCut_Uw:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAxisAFreq_Uw:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rAxisBFreq_Uw:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rAxisAFreq_Rw:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rAxisBFreq_Rw:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rWuCompensate_Uw:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rWuCompensate_Rw:= 0;	
		i_pastStGrpParam_UnSave^[iGrp].rWuCompensate_Act_Uw:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rWuCompensate_Act_Rw:= 0;
		i_pastStGrpParam_UnSave^[iGrp].xEn_Disturbance_If:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].xEn_Disturbance_Of:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rFreq_Disturbance_If:= 1;
		i_pastStGrpParam_UnSave^[iGrp].rAmplitude_Disturbance_If:= 1;
		i_pastStGrpParam_UnSave^[iGrp].uiTotalTime_Disturbance_If:= 0;
		i_pastStGrpParam_UnSave^[iGrp].xOuting_sin_If:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rResult_sin_If:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rFreq_Disturbance_Of:= 1;
		i_pastStGrpParam_UnSave^[iGrp].rAmplitude_Disturbance_Of:= 1;
		i_pastStGrpParam_UnSave^[iGrp].uiTotalTime_Disturbance_Of:= 0;
		i_pastStGrpParam_UnSave^[iGrp].xOuting_sin_Of:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rResult_sin_Of:= 0;
		
		i_pastStGrpParam_UnSave^[iGrp].byPseudoRandomRoundTimes_Cur:= 0;
		
		i_pastStGrpParam_UnSave^[iGrp].xFlagFollow1U_AccDecing:= FALSE;

		i_pastStGrpParam_UnSave^[iGrp].xEnaTestARC_Ink:= FALSE;
		i_pastStGrpParam_UnSave^[iGrp].rAcceleration_Max:= 0;
		i_pastStGrpParam_UnSave^[iGrp].rAcceleration_Cur:= 0;
		
		i_pastStGrpParam_UnSave^[iGrp].byGrpAxisNum_Pu	:= 0;
		
		SysMemSet(ADR(i_pastStGrpParam_UnSave^[iGrp].abyGrpAxisList),0,SIZEOF(i_pastStGrpParam_UnSave^[iGrp].abyGrpAxisList));			
		
		SysMemSet(ADR(i_pastStGrpParam_UnSave^[iGrp].abyGrpArcAxisList),0,SIZEOF(i_pastStGrpParam_UnSave^[iGrp].abyGrpArcAxisList));	
		FOR iT:=1 TO MAX_UNIT_NUM BY 1 DO
			i_pastStGrpParam_UnSave^[iGrp].abyAxisList_CoatingPrn[iT]:= gc_byInvisCoatingPrnAxisIdx;
		END_FOR
		i_pastStGrpParam_UnSave^[iGrp].byAxisNum_CoatingPrn		:= 0(*BYTE*);(*涂布总轴数|*)
		i_pastStGrpParam_UnSave_RSV^[iGrp].xSwitch_GrpInkEn:=FALSE;
	END_FOR
	iResult:=1;
ELSE
	iResult:=-1;
END_IF

