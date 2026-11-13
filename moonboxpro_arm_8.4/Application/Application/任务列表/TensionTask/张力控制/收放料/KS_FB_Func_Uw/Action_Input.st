(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=db6d155d-1a25-4326-875f-62c73ceb0918
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2025.8.4.142614||输入参数获取*)
rN_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_Uw;
rMpa_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMpa_Uw;
uiNum_In							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_Uw;
uiDen_In							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_Uw;
rRatedRpm_In						:= INT_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iRatedRpm_Uw);
rRatedFreq_In						:= INT_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iRatedFreq_Uw);
rUpperFreq_In						:= INT_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iUpperFreq_Uw);
rPseudoRandomRoundAmplitude_Cur_In	:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPseudoRandomRoundAmplitude_Cur;
xFlag_AxisABParaFroDiaMea_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xFlag_AxisABParaFroDiaMea_Uw;
xDiamMeasureAutomatic_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xDiamMeasureAutomatic_Uw;
dwAbsEncSinglePos_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAbsEncSinglePos_Uw;
xEn_DualParam_AbsEncLocation_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xEn_DualParam_AbsEncLocation_Uw;
rDia_PaperRoller_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDia_PaperRoller_Uw;
xCutUseReflectionSensor_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCutUseReflectionSensor_Uw;
uiAutoMaticCutDia_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiAutoMaticCutDia_Uw;
uiAutoMaticCutMeters_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiAutoMaticCutMeters_Uw;
xCancelTenEn_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCancelTenEn;
iInitial_speed_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byInitialSpd_Stiffen_Uw;
iStiffenCoff_UwRw_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byCoef_stiffen_Uw;
xRollerSts_IfOf_In						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_If;
rAI_IfOf_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_If;
xUseAntiNotch_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseAntiNotch_Uw;(*: BOOL;(*陷波器使能开关*)                                                      *)
rWn_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWn_Uw;(*: REAL;(*陷波中心频率*)                                                        *)
rBw_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rBw_Uw;(*: REAL;(*陷波宽度*)                                                           *)
rDp_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDp_Uw;(*: REAL;(*陷波深度*)                                                           *)
xPseudoRandomEn_In					:= i_pstStSysParam^.stStSysParam_Save.xPseudoRandomEn ;(*: BOOL;(*伪随机测试按钮*)                                                      *)
byPseudoRandomId_In					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byPseudoRandomId;(*: BYTE;(*放料伪随机使能*)                                                      *)
arK_pid_In							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_Uw;(*: ARRAY [1..3] OF REAL;(*设定PID值*)                                          *)
aiTestKp_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kp;(*: ARRAY [1..3] OF INT;(*伪随机P值*)                                           *)
aiTestKd_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kd;(*: ARRAY [1..3] OF INT;(*伪随机D值*)                                           *)
xCutDneResetPidEn_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCutDneResetPidEn_Uw;(*: BOOL;(*裁切后PID放大*)                                                       *)
piCutDneResetPidMultiple_In			:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iCutDneResetPidMultiple_Uw);(*: POINTER TO INT;(*PID放大倍数*)                                              *)
iCutDneResetPidRemainTime_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iCutDneResetPidRemainTime_Uw;(*: INT;(*保持时间*)                                                            *)
iCutDneResetPidToDefaultTime_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iCutDneResetPidToDefaultTime_Uw;(*: INT;(*恢复时间*)                                                            *)
xSmallDiaMulEn_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSmallDiaMulEn_UW;(*: BOOL;(*小卷补偿功能使能*)                                                     *)
iSmallDiaMulSa_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulSa_UW;(*: INT;(*小卷补偿起始直径*)                                                      *)
iSmallDiaMulEd_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulEd_UW;(*: INT;(*小卷补偿结束直径*)                                                      *)
iSmallDiaMulSa_Coeff_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulSa_Coeff_UW;(*: INT;(*小卷补偿起始系数*)                                                      *)
iSmallDiaMulEd_Coeff_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulEd_Coeff_UW;(*: INT;(*小卷补偿结束系数*)                                                      *)
xPseudoRandomTsting_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPseudoRandomTsting;(*: BOOL;(*伪随机使能*)                                                          *)
uiPiDelayWhenCut_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiPiDelay_Uw;(*: UINT;(*放料裁切PI投入时间*)                                                   *)
rFilmThickNess_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThick_Manu;(*: REAL;(*料膜厚度*)                                                           *)
xAutomaticCutEn_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xAutomaticCutEn_Uw;(*: BOOL;(*自动接料使能*)                                                        *)
xFlag_CancelSafetyGrating_In		:= i_pstStSysParam^.stStSysParam_Save.xFlag_CancelSafetyGrate;(*: BOOL;(*光栅保护取消*)                                                        *)
byAutoMaticCutMode_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAutoMaticCutMode_Uw;(*: BYTE;(*自动接料模式选择*)                                                     *)
rGirth_AxisA_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaA_Uw;(*: REAL;(*设定周长A*)                                                          *)
rGirth_AxisB_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaB_Uw;(*: REAL;(*设定周长B*)                                                          *)
xDebug_Enc_In_Out_UwRw					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xDebug_Enc_Uw;(*: BOOL;(*绝对值编码器调试开关*)                                                 *)
xIsDebug_DiaMeasure_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebug_DiaMeasure_Uw;(*: BOOL;(*卷径标定调试开关*)                                                     *)
//xAxisDebug_Spd_In					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.0;(*: BOOL;(*速度调试开关*)                                                        *)
xPreCutOneBtn_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xPreCutOneBtn_Uw;(*: BOOL;(*接料-解除用一个按钮标志*)                                               *)
xFlag_SafeTyGratingProctec_In		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_SafeTyGratingProctec_Uw;(*: BOOL;(*光栅保护触发*)                                                        *)
xUseAbsEncoder_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseAbsEncoder_Uw;(*: BOOL;(*翻转架使用绝对值编码器定位方式&自动卷径*)                                 *)
byDiamMeasureTypeId_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byDiamMeasureTypeId_Uw;(*: BYTE; (*=1 电位器 =2 编码器 =3 超声波I(ndependent) =4超声波S(hare) *)	         *)
uiPreStopDelayTime_ms_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiPreStopDelayTime_ms;(*: UINT;(*预驱停止延迟时间@100ms*)                                               *)
iTime_PreDrvAcc_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_PreDrvAcc_Uw;(*: INT;(*预驱加速时间*)                                                         *)
iTime_PreDrvDec_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_PreDrvDec_Uw;(*: INT;(*预驱减速时间*)                                                         *)
xFlag_CCW_AfterCutted_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xFlag_CCW_AfterCutted_Uw;(*: BOOL;(*裁切完反转标志*)                                                      *)
iPreRevLenth_MM_Cutted_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iPreRevLenth_MM_Cutted_Uw;(*: INT;(*反转距离*)                                                            *)
iPreRevVel_RPM_Cutted_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iPreRevVel_RPM_Cutted_Uw;(*: INT;(*反转速度*)                                                            *)
iDebugGirthmm_AxisA_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisA_Uw;(*: INT;                                                                       *)
iDebugGirthmm_AxisB_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisB_Uw;(*: INT;                                                                       *)
rCoefCut_FilmVolPerimeter_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rCoefCut_FilmVolPerimeter_Uw;(*: REAL;                                                                      *)
dwAbsEnCodeResolution_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].dwAbsEnCodeResolution_Uw;(*: DWORD;(*绝对值编码器线数*)                                                    *)
xUseRadCompensate_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseRadCompensate_Uw;(*: BOOL;(*放料翻转架补偿开关*)                                                   *)
xTowerDir_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xTowerDir_Uw;(*: BOOL;(*翻转架和绝对位置方向控制|*)                                             *)
rDiam_DeflectorRollPos_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_DeflectorRollPos_Uw;(*: REAL;(*翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)                      *)
rDiam_DeflectorRoller_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_DeflectorRoller_Uw;(*: REAL;(*翻料架上导向辊的直径|mm*)                                              *)
xFlag_RollerPressAtLeast1_In		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressAtLeast1;(*: BOOL;                                                                      *)
xUseFollow_1U_V_UwCut_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseFollow_1U_V_UwCut;(*: BOOL;(* THEN(*使用裁切时候跟踪第一色方法*)	*)                                   *)
uiMaxDia_In							:= i_pstStSysParam^.stStSysParam_Save.uiMaxDia;(*: UINT;                                                                      *)
uiInitDiam_In						:= i_pstStSysParam^.stStSysParam_Save.uiInitDiam_Uw;(*: UINT;                                                                      *)
xTypeGetInitDiam_In					:= i_pstStSysParam^.stStSysParam_Save.xTypeGetInitDiam;(*: BOOL;                                                                      *)
rWc_LowPass_Diam_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWc_LowPass_Diam_Uw;(*: REAL;                                                                      *)
xGetFilmThickNessAuto_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xGetFilmThickNessAuto;(*: BOOL;(*自动获取标志*)                                                        *)
rDiamAlarm_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiamAlarm_Uw;(*: REAL;(*放料报警卷径*)                                                        *)
byAlarmType_NoMaterial_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAlarmType_NoMaterial_Uw;(*: BYTE;(*没料报警方式@=0 放料没料3S响铃报警                                       *)
									:= ;(*	@=1 放料没料时候一直报警-直到按下正转\反转\接料准备*)                           *)
xUseFeedVel_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseIfVel_Uw;(*: BOOL;                                                                      *)
rVel_Feed_In						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur_If;(*: REAL;(*牵引速度-放料放牵收料收牵*)	                                         *)
xFilmAccDecDone_In					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FilmAccDecDone;(*: BOOL;(*料膜加减速完成*)                                                      *)
xDiaEstEn_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xDiaEstEn_Uw;(*: BOOL;(*卷径估计使能开关*)                                                     *)
xFlag_RollerPressDne_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressDone;(*: BOOL;	(*色组压辊合压完成*)                                                    *)
xUseDiam_LowPass_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseDiam_LowPass_Uw;(*: BOOL;(*使用低通的卷径值*)                                                     *)
xTensionCompensateEn_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xTensionCompensateEn_Uw;(*: BOOL;(*张力补偿开关*)	                                                     *)
xTensionCompensateEn_Cut_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xTensionCompensateEn_UwCut;(*: BOOL;(*裁切张力补偿开关*)	                                                 *)
xUseIMatrix_rX_DARE_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseIMatrix_rX_DARE_Uw;(*: BOOL;(*使用单位矩阵*)                                                        *)
xUseTime_Variaition_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseTime_Variaition_Uw;(*: BOOL;(*使用时变参数标志*)                                                     *)
xUseTime_b1_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseTime_b1_Uw;(*: BOOL;(*默认时时变的,有效则b1随卷径实时变化-不实时变化则使用b1_0@2024.05.14.080937*)*)
byAlarmHold_PreCut_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAlarmHold_PreCut_Uw;(*预备接料响铃时间*)
(*------------------------------------------------------------*)

(*2025.8.4.142641输入输出参数-输入获取*)
xAxisDebugEn_In_Out			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.0;
xAxisADebugRun_In_Out		 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.1; 
xAxisBDebugRun_In_Out		 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.4;
xAxisADebugRunning_In_Out	 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.3;
xAxisBDebugRunning_In_Out	 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.6;
xAxisADebugAutoAccDec_In_Out := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.2;
xAxisBDebugAutoAccDec_In_Out := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.5;

xTaperUnitType_In_Out					:= i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.2;
byTaperUnit_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_Uw;
byTaperUnitConfirm_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_Uw;
rPercentMatchN_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_Uw;
rPercentMatchMpa_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_Uw;
rTaperValueBegin_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_Uw;
rTaperValueEnd_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_Uw;
rTaperValueCur_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_Uw;
rTaper_Begin_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_Uw;
rTaper_End_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_Uw;
rTaper_Cur_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_Uw;
rTaperMax_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_Uw;

iDebugVelmpm_AxisA_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisA_Uw;
iDebugGirthmm_AxisA_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisA_Uw;
iDebugVelmpm_AxisB_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisB_Uw;
iDebugGirthmm_AxisB_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisB_Uw;
axMeasure_StdVol_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axMeasure_StdVol;
xCutterOnTopFroDebug_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCutterOnTopFroDebug_Uw;
xCurAxisAFroDebug_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisAFroDebug_Uw;
rActRemainFilmLenth_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rActRemainFilmLenth_Uw;
bySetTestPid_In_Out							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_Uw;(*: BYTE;(*伪随机步骤*)                         *)
xCurAxisDia_Wr_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisDia_Uw_Wr;(*: BOOL;(*界面周长设定写入按钮*)                *)
xCutAxisA_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.0;(*: BOOL;(*当前轴*)                            *)
rEstiDia_In_Out								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiDia_Uw;(*: REAL;(*预估卷径值*)                         *)
xSwitch_IsUpCut_HMI_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_Change_CutterOnTop_HMI_Uw;(*: BOOL;(*界面切换上下裁开关*)                  *)
byEncodeValueWr_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byEncodeValueWr_Uw;(*: BYTE;(*编码器值写入|放料:                    *)
											:= ;(*			 01 写入轴定位值                    *)
											:= ;(*			 02 写入A轴最小径定位值*)            *)
adwAxisALocation_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisALocation_Uw;(*: ARRAY [0..1] OF DWORD;                    *)
adwAxisBLocation_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisBLocation_Uw;(*: ARRAY [0..1] OF DWORD;                    *)
adwAxisALocation_MinDia_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisALocation_MinDiam_Uw;(*: ARRAY [0..1] OF DWORD;                    *)
adwAxisBLocation_MinDia_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisBLocation_MinDiam_Uw;(*: ARRAY [0..1] OF DWORD;                    *)
rAi_DiamMeasure_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_DiamMeasure_Uw;(*: REAL;                                     *)
xEnCodeFailed_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Uw;(*: BOOL;			                          *)

xFlag_DiamCalc_end_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_DiamCalc_end_Uw;(*: BOOL;(*卷径计算完成标志*)                    *)
xFlag_DiamCalc_ing_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_DiamCalc_ing_Uw;(*: BOOL;(*卷径计算中标志*)                     *)
xIsDebug_DiaMeasure_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebug_DiaMeasure_Uw;(*: BOOL;                                     *)
xIsDebuging_DiaMeasure_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebuging_DiaMeasure_Uw;(*: BOOL;(*放料卷径测量调试中*)                  *)
xCancelDebuging_DiaMeasure_In_Out			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCancelDebuging_DiaMeasure_Uw;(*: BOOL;(*放料卷径测量调试条件*)                *)
byIsDebug_DiaMeasureArea_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byIsDebug_DiaMeasureArea_Uw;(*: BYTE;                                     *)
astStStdVolParam_DnCut_UpCut_In_Out			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].astStStdVolParam_DnCut_UpCut;(*: ARRAY [0..1] OF StStdVolParam_DnCut_UpCut;*)
(*2025.11.14.092228
wAxisDebug_UwRw_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw;(*: WORD;(**)(*轴调试标志|.0\放料调试使能.1\放料A轴调试运行.2\放料A轴自动加减速.3\放料A轴运行中.4\放料B轴调试运行.5\放料B轴自动加减速.6\放料B轴运行中*)
											:= ;(*	.8\收料调试使能.9\收料A轴调试运行.10\收料A轴自动加减速.11\收料A轴运行中.12\收料B轴调试运行.13\收料B轴自动加减速.14\收料B轴运行中*)				*)		 
*)rDebugCurVelmpmAxisA_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisA_Uw;(*: REAL;                   *)
rDebugCurVelmpmAxisB_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisB_Uw;(*: REAL;                   *)
rDebugCurVelrpmAxisA_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisA_Uw;(*: REAL;	                *)
rDebugCurVelrpmAxisB_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisB_Uw;(*: REAL;					*)			  

//xFlag_Cut_end_UseInOtherPrg_In_Out			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw_UseInOtherPrg;(*: BOOL;(*使用在别的Prg中的放料裁切完成标志|在自己的prg中清除*)	*)						  
(*翻转架补偿相关参数*)                      (*    := ;                                                         *)
rDiam_Tower_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_Tower_Uw;(*: REAL;                                                   *)
rDiam_NextRoller_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_NextRoller_Uw;(*: REAL;                                                   *)
rXPos_NextRoller_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rXPos_NextRoller_Uw;(*: REAL;                                                   *)
rYPos_NextRoller_In_Out 					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rYPos_NextRoller_Uw;(*: REAL;		                                            *)

dwEncodePos_In_Out							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAbsEncSPos_Cur_Uw;(*: DWORD;                                                  *)
//2026.05.20.211011  变量使用错误
//xConfirmRad0_In_Out							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xConfirmRad0;(*: BOOL;(*0弧度确认*)                                       *)
xConfirmRad0_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xConfirmRad0_Uw;(*: BOOL;(*0弧度确认*)                                       *)

dwAxisAAbsPos_0Rad_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].dwAxisAabsPos_0Rad_Uw;(*: DWORD;(*A轴0弧度位置*)                                    *)
dwAxisBAbsPos_0Rad_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].dwAxisBabsPos_0Rad_Uw;(*: DWORD;(*B轴0弧度位置*)                                    *)
xFlag_Follow_1U_V_UwCut_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Follow_1U_V_UwCut;(*: BOOL;(*裁切时跟踪第一色标志*)                              *)
byMeters_UseFollow_1U_V_UwCut_In_Out		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byMeters_UseFollow_1U_V_UwCut;(*: BYTE;                                                   *)
rEstiThickness_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiThickness_Uw;(*: REAL;                                                   *)
rFilmThickNess_Using_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThickNess_Using;(*: REAL;(*使用的料膜厚度*)                                   *)
xKeepAlarm_NoMaterial_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xKeepAlarm_NoMaterial;(*: BOOL;(*长报警标志复位*)                                   *)
byVelSa_DiamCompensate_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byVelSa_DiamCompensate_Uw;(*: BYTE;(*补偿起始速度*)                                     *)
byDelayTime_DiaCompensateWhenCutDne_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byDelayTime_DiaCompensateWhenCutDne_Uw;(*: BYTE;(*裁切后卷径补偿之后时间|s*)                           *)
rKc_In_Out									:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Uw;(*: REAL;                                                   *)
rKc_AccDec_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Uw_AccDec;(*: REAL;                                                   *)
uiUseTime_Diam_Min_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiUseTime_Diam_Min_Uw;(*: UINT;                                                   *)
rR_K_LQR_In_Out								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_LQR_Uw;(*: REAL;                                                   *)
rN_LQR_In_Out								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_LQR_Uw;(*: REAL;                                                   *)
rR_K_MinBeat_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_MinBeat_Uw;(*: REAL;                                                   *)
iN_MinBeat_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iN_MinBeat_Uw;(*: INT;                                                    *)
stModelParam_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stModelParam_Uw;(*: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)      *)
stInvariant_Parameters_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stInvariant_Parameters_Uw;(*: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)      *)
stPI_Parameters_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Uw;(*: PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)			*)			  
stPI_Parameters_AccDec_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Uw_AccDec;(*: PI_Parameters;(*控制器pi参数@20bytes|用于加减速*)			*)			  

(*------------------------------------------------------------*)
//2026.05.24.210851|增加一个裁切完成信号，原信号是输出信号，现需要改为输入
//xFlag_Cut_ing_Out							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_ing_Uw;
xFlag_Cut_end_Out							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw;
//2026.05.25.113606|2026.05.25.132242|指针
// xFlag_Cut_ing_Uw_UseInOtherPrg_In_Out		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_ing_Uw_UseInOtherPrg;
// xFlag_Cut_end_Uw_UseInOtherPrg_In_Out		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw_UseInOtherPrg;



(*IO状态获取2025.8.4.142712*)
(*上下裁切换*)
afbTRIG_UwRw_Input[1](CLK:= i_pstStIOMap_Uw^.i_xIsUpCut,Q=>i_pstStEvtReq^.xReq_IsUpCut);
i_pstStEvtReq^.xEvt_IsUpCut:= i_pstStIOMap_Uw^.i_xIsUpCut;
(*预备接料*)
afbTRIG_UwRw_Input[2](CLK:= i_pstStIOMap_Uw^.i_xPreCut,Q=>i_pstStEvtReq^.xReq_PreCut);
i_pstStEvtReq^.xEvt_PreCut:= i_pstStIOMap_Uw^.i_xPreCut;
(*接料取消*)
afbTRIG_UwRw_Input[3](CLK:= i_pstStIOMap_Uw^.i_xCut_Cancel,Q=>i_pstStEvtReq^.xReq_CutCancel);
i_pstStEvtReq^.xEvt_CutCancel:= i_pstStIOMap_Uw^.i_xCut_Cancel;
(*接料*)
afbTRIG_UwRw_Input[4](CLK:= i_pstStIOMap_Uw^.i_xCut,Q=>i_pstStEvtReq^.xReq_Cut);
i_pstStEvtReq^.xEvt_Cut:= i_pstStIOMap_Uw^.i_xCut;
(*轴切换*)
afbTRIG_UwRw_Input[5](CLK:= i_pstStIOMap_Uw^.i_xAxisExchange,Q=>i_pstStEvtReq^.xReq_AxisExchange);
i_pstStEvtReq^.xEvt_AxisExchange:= i_pstStIOMap_Uw^.i_xAxisExchange;
(*正转*)
afbTRIG_UwRw_Input[6](CLK:= i_pstStIOMap_Uw^.i_xForward,Q=>i_pstStEvtReq^.xReq_Forward);
i_pstStEvtReq^.xEvt_Forward:= i_pstStIOMap_Uw^.i_xForward;
(*反转*)
afbTRIG_UwRw_Input[7](CLK:= i_pstStIOMap_Uw^.i_xReversal,Q=>i_pstStEvtReq^.xReq_Reversal);
i_pstStEvtReq^.xEvt_Reversal:= i_pstStIOMap_Uw^.i_xReversal;
(*急停*)
afbTRIG_UwRw_Input[8](CLK:= i_pstStIOMap_Uw^.i_xEstop,Q=>i_pstStEvtReq^.xReq_Estop);
i_pstStEvtReq^.xEvt_Estop:= i_pstStIOMap_Uw^.i_xEstop;
(*单运行*)
afbTRIG_UwRw_Input[9](CLK:= i_pstStIOMap_Uw^.i_xAxisInch,Q=>i_pstStEvtReq^.xReq_Inch);
i_pstStEvtReq^.xEvt_Inch:= i_pstStIOMap_Uw^.i_xAxisInch;
(*反向单运行*)
afbTRIG_UwRw_Input[10](CLK:= i_pstStIOMap_Uw^.i_xAxisInch_Rev,Q=>i_pstStEvtReq^.xReq_RevInch);
i_pstStEvtReq^.xEvt_RevInch:= i_pstStIOMap_Uw^.i_xAxisInch_Rev;
(*上裁A轴3吋定位*)
afbTRIG_UwRw_Input[11](CLK:= i_pstStIOMap_Uw^.i_xAxisA_Locating_UpCut,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_Up);
i_pstStEvtReq^.xEvt_AxisA_Locating_Up:= i_pstStIOMap_Uw^.i_xAxisA_Locating_UpCut;
(*上裁B轴3吋定位*)
afbTRIG_UwRw_Input[12](CLK:= i_pstStIOMap_Uw^.i_xAxisB_Locating_UpCut,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_Up);
i_pstStEvtReq^.xEvt_AxisB_Locating_Up:= i_pstStIOMap_Uw^.i_xAxisB_Locating_UpCut;
(*上裁A轴6吋定位*)
afbTRIG_UwRw_Input[13](CLK:= i_pstStIOMap_Uw^.i_xAxisA_Locating_UpCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_UpCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisA_Locating_UpCut_PaperCore6Inch:= i_pstStIOMap_Uw^.i_xAxisA_Locating_UpCut_PaperCore6Inch;
(*上裁B轴6吋定位*)
afbTRIG_UwRw_Input[14](CLK:= i_pstStIOMap_Uw^.i_xAxisB_Locating_UpCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_UpCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisB_Locating_UpCut_PaperCore6Inch:= i_pstStIOMap_Uw^.i_xAxisB_Locating_UpCut_PaperCore6Inch;
(*下裁A轴3吋定位*)
afbTRIG_UwRw_Input[15](CLK:= i_pstStIOMap_Uw^.i_xAxisA_Locating_DnCut,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_Dn);
i_pstStEvtReq^.xEvt_AxisA_Locating_Dn:= i_pstStIOMap_Uw^.i_xAxisA_Locating_DnCut;
(*下裁B轴3吋定位*)
afbTRIG_UwRw_Input[16](CLK:= i_pstStIOMap_Uw^.i_xAxisB_Locating_DnCut,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_Dn);
i_pstStEvtReq^.xEvt_AxisB_Locating_Dn:= i_pstStIOMap_Uw^.i_xAxisB_Locating_DnCut;
(*下裁A轴6吋定位*)
afbTRIG_UwRw_Input[17](CLK:= i_pstStIOMap_Uw^.i_xAxisA_Locating_DnCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_DnCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisA_Locating_DnCut_PaperCore6Inch:= i_pstStIOMap_Uw^.i_xAxisA_Locating_DnCut_PaperCore6Inch;
(*下裁B轴6吋定位*)
afbTRIG_UwRw_Input[18](CLK:= i_pstStIOMap_Uw^.i_xAxisB_Locating_DnCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_DnCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisB_Locating_DnCut_PaperCore6Inch:= i_pstStIOMap_Uw^.i_xAxisB_Locating_DnCut_PaperCore6Inch;
(*上裁最小径定位*)
afbTRIG_UwRw_Input[19](CLK:= i_pstStIOMap_Uw^.i_xMinimumDiamProtect_UpCut,Q=>i_pstStEvtReq^.xReq_MinimumDiamProtect_Up);
i_pstStEvtReq^.xEvt_MinimumDiamProtect_Up:= i_pstStIOMap_Uw^.i_xMinimumDiamProtect_UpCut;
(*上裁对射电眼*)
afbTRIG_UwRw_Input[20](CLK:= i_pstStIOMap_Uw^.i_xSensor_DiamMeasureLocating_UpCut,Q=>i_pstStEvtReq^.xReq_Sensor_DiamMeasureLocating_Up);
i_pstStEvtReq^.xEvt_Sensor_DiamMeasureLocating_Up:= i_pstStIOMap_Uw^.i_xSensor_DiamMeasureLocating_UpCut;
(*下裁最小径定位*)
afbTRIG_UwRw_Input[21](CLK:= i_pstStIOMap_Uw^.i_xMinimumDiamProtect_DnCut,Q=>i_pstStEvtReq^.xReq_MinimumDiamProtect_Dn);
i_pstStEvtReq^.xEvt_MinimumDiamProtect_Dn:= i_pstStIOMap_Uw^.i_xMinimumDiamProtect_DnCut;
(*下裁对射电眼*)
afbTRIG_UwRw_Input[22](CLK:= i_pstStIOMap_Uw^.i_xSensor_DiamMeasureLocating_DnCut,Q=>i_pstStEvtReq^.xReq_Sensor_DiamMeasureLocating_Dn);
i_pstStEvtReq^.xEvt_Sensor_DiamMeasureLocating_Dn:= i_pstStIOMap_Uw^.i_xSensor_DiamMeasureLocating_DnCut;
(*上裁A轴反射电眼*)
afbTRIG_UwRw_Input[23](CLK:= i_pstStIOMap_Uw^.i_xSensor_Reflex_A_Up,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Up_AxisA);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Up_AxisA:= i_pstStIOMap_Uw^.i_xSensor_Reflex_A_Up;
(*上裁B轴反射电眼*)
afbTRIG_UwRw_Input[24](CLK:= i_pstStIOMap_Uw^.i_xSensor_Reflex_B_Up,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Up_AxisB);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Up_AxisB:= i_pstStIOMap_Uw^.i_xSensor_Reflex_B_Up;
(*下裁A轴反射电眼*)
afbTRIG_UwRw_Input[25](CLK:= i_pstStIOMap_Uw^.i_xSensor_Reflex_A_Dn,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Dn_AxisA);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Dn_AxisA:= i_pstStIOMap_Uw^.i_xSensor_Reflex_A_Dn;
(*下裁B轴反射电眼*)
afbTRIG_UwRw_Input[26](CLK:= i_pstStIOMap_Uw^.i_xSensor_Reflex_B_Dn,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Dn_AxisB);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Dn_AxisB:= i_pstStIOMap_Uw^.i_xSensor_Reflex_B_Dn;
(*3/6吋切换*)
afbTRIG_UwRw_Input[27](CLK:= i_pstStIOMap_Uw^.i_xPaperCoreSelect6Inch,Q=>i_pstStEvtReq^.xReq_PaperCoreSelect6Inch);
i_pstStEvtReq^.xEvt_PaperCoreSelect6Inch:= i_pstStIOMap_Uw^.i_xPaperCoreSelect6Inch;

afbTRIG_UwRw_Input[28](CLK:= i_pstStIOMap_Uw^.i_xUwMeasureSensor,Q=>i_pstStEvtReq^.xReq_UwMeasureSensor);
i_pstStEvtReq^.xEvt_UwMeasureSensor:= i_pstStIOMap_Uw^.i_xUwMeasureSensor;
(*------------------------------------------------------------*)

//2026.4.12.143451交互裁切完成信号
xTell_KS_PreDrv_CTL_Uw_CuttDne_In:= g_axTell_KS_PreDrv_CTL_Uw_CuttDne[i_iGrpId];

//2026.5.27.100554单运行速度输入
rVel_Inch_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch;