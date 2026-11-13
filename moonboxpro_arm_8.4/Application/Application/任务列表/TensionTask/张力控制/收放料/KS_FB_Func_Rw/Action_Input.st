(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=f71fe08d-e2f2-46a1-a19c-dad77fc748a4
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2025.8.4.142614||输入参数获取*)
astTaperPoint_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].astTaperPoint_Rw;
rDiamTaper_Begin_Rw_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_taper_begin_Rw;
rDiamTaper_End_Rw_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_taper_end_Rw;
byTaperAdjMode_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperCtlMode_Rw;
byInitTaper_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byInitTaper_Rw;
rN_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_Rw;
rMpa_In								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rMpa_Rw;

uiNum_In							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_Rw;
uiDen_In							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_Rw;
rRatedRpm_In						:= INT_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iRatedRpm_Rw);
rRatedFreq_In						:= INT_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iRatedFreq_Rw);
rUpperFreq_In						:= INT_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iUpperFreq_Rw);
rPseudoRandomRoundAmplitude_Cur_In	:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rPseudoRandomRoundAmplitude_Cur;

dwAbsEncSinglePos_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAbsEncSinglePos_Rw;
xEn_DualParam_AbsEncLocation_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xEn_DualParam_AbsEncLocation_Rw;
xWillAutoMaticPreCut_Uw_In		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xWillAutoMaticPreCut_Uw;
xFlag_Precutting_Uw_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_PreCutting_Uw;
uiAutoMaticCutDia_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiAutoMaticCutDia_Rw;
uiAutoMaticCutMeters_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiAutoMaticCutMeters_Rw;
xCancelTenEn_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCancelTenEn;
iInitial_speed_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byInitialSpd_Stiffen_Rw;
iStiffenCoff_UwRw_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byCoef_stiffen_Rw;
xRollerSts_IfOf_In						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xRollerSts_Of;
rAI_IfOf_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Of;
xPseudoRandomEn_In					:= i_pstStSysParam^.stStSysParam_Save.xPseudoRandomEn ;(*: BOOL;(*伪随机测试按钮*)                                                      *)
byPseudoRandomId_In					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byPseudoRandomId;(*: BYTE;(*放料伪随机使能*)                                                      *)
arK_pid_In							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].arKpid_Rw;(*: ARRAY [1..3] OF REAL;(*设定PID值*)                                          *)
aiTestKp_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kp;(*: ARRAY [1..3] OF INT;(*伪随机P值*)                                           *)
aiTestKd_In							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].aiTestPseudoRandom_Kd;(*: ARRAY [1..3] OF INT;(*伪随机D值*)                                           *)
xCutDneResetPidEn_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xCutDneResetPidEn_Rw;(*: BOOL;(*裁切后PID放大*)                                                       *)
piCutDneResetPidMultiple_In			:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iCutDneResetPidMultiple_Rw);(*: POINTER TO INT;(*PID放大倍数*)                                              *)
iCutDneResetPidRemainTime_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iCutDneResetPidRemainTime_Rw;(*: INT;(*保持时间*)                                                            *)
iCutDneResetPidToDefaultTime_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iCutDneResetPidToDefaultTime_Rw;(*: INT;(*恢复时间*)                                                            *)
xSmallDiaMulEn_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSmallDiaMulEn_RW;(*: BOOL;(*小卷补偿功能使能*)                                                     *)
iSmallDiaMulSa_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulSa_RW;(*: INT;(*小卷补偿起始直径*)                                                      *)
iSmallDiaMulEd_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulEd_RW;(*: INT;(*小卷补偿结束直径*)                                                      *)
iSmallDiaMulSa_Coeff_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulSa_Coeff_RW;(*: INT;(*小卷补偿起始系数*)                                                      *)
iSmallDiaMulEd_Coeff_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iSmallDiaMulEd_Coeff_RW;(*: INT;(*小卷补偿结束系数*)                                                      *)
xPseudoRandomTsting_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPseudoRandomTsting;(*: BOOL;(*伪随机使能*)                                                          *)
//uiPiDelayWhenCut_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiPiDelay_Rw;(*: UINT;(*放料裁切PI投入时间*)                                                   *)
rFilmThickNess_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThick_Manu;(*: REAL;(*料膜厚度*)                                                           *)
xAutomaticCutEn_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xAutomaticCutEn_Rw;(*: BOOL;(*自动接料使能*)                                                        *)
xFlag_CancelSafetyGrating_In		:= i_pstStSysParam^.stStSysParam_Save.xFlag_CancelSafetyGrate;(*: BOOL;(*光栅保护取消*)                                                        *)
byAutoMaticCutMode_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAutoMaticCutMode_Rw;(*: BYTE;(*自动接料模式选择*)                                                     *)
rGirth_AxisA_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaA_Rw;(*: REAL;(*设定周长A*)                                                          *)
rGirth_AxisB_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaB_Rw;(*: REAL;(*设定周长B*)                                                          *)
xDebug_Enc_In_Out_UwRw					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xDebug_Enc_Rw;(*: BOOL;(*绝对值编码器调试开关*)                                                 *)
//xAxisDebug_Spd_In					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.8;(*: BOOL;(*速度调试开关*)                                                        *)
xPreCutOneBtn_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xPreCutOneBtn_Rw;(*: BOOL;(*接料-解除用一个按钮标志*)                                               *)
xFlag_SafeTyGratingProctec_In		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_SafeTyGratingProctec_Rw;(*: BOOL;(*光栅保护触发*)                                                        *)
xUseAbsEncoder_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseAbsEncoder_Rw;(*: BOOL;(*翻转架使用绝对值编码器定位方式&自动卷径*)                                 *)
iTime_PreDrvAcc_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_PreDrvAcc_Rw;(*: INT;(*预驱加速时间*)                                                         *)
iTime_PreDrvDec_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iTime_PreDrvDec_Rw;(*: INT;(*预驱减速时间*)                                                         *)
iDebugGirthmm_AxisA_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisA_Rw;(*: INT;                                                                       *)
iDebugGirthmm_AxisB_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisB_Rw;(*: INT;                                                                       *)
rCoefCut_FilmVolPerimeter_In		:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rCoefCut_FilmVolPerimeter_Rw;(*: REAL;                                                                      *)
xFlag_RollerPressAtLeast1_In		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressAtLeast1;(*: BOOL;                                                                      *)
uiMaxDia_In							:= i_pstStSysParam^.stStSysParam_Save.uiMaxDia;(*: UINT;                                                                      *)
uiInitDiam_In						:= i_pstStSysParam^.stStSysParam_Save.uiInitDiam_Rw;(*: UINT;                                                                      *)
xTypeGetInitDiam_In					:= i_pstStSysParam^.stStSysParam_Save.xTypeGetInitDiam;(*: BOOL;                                                                      *)
rWc_LowPass_Diam_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rWc_LowPass_Diam_Rw;(*: REAL;                                                                      *)
									
xUseFeedVel_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseOfVel_Rw;(*: BOOL;                                                                      *)
rVel_Feed_In						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur_Of;(*: REAL;(*牵引速度-放料放牵收料收牵*)	                                         *)
xFilmAccDecDone_In					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_FilmAccDecDone;(*: BOOL;(*料膜加减速完成*)                                                      *)
xDiaEstEn_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xDiaEstEn_Rw;(*: BOOL;(*卷径估计使能开关*)                                                     *)
xFlag_RollerPressDne_In				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressDone;(*: BOOL;	(*色组压辊合压完成*)                                                    *)
xUseDiam_LowPass_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseDiam_LowPass_Rw;(*: BOOL;(*使用低通的卷径值*)                                                     *)
xTensionCompensateEn_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xTensionCompensateEn_Rw;(*: BOOL;(*张力补偿开关*)	                                                     *)
xTensionCompensateEn_Cut_In			:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xTensionCompensateEn_RwCut;(*: BOOL;(*裁切张力补偿开关*)	                                                 *)
xUseIMatrix_rX_DARE_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseIMatrix_rX_DARE_Rw;(*: BOOL;(*使用单位矩阵*)                                                        *)
xUseTime_Variaition_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseTime_Variaition_Rw;(*: BOOL;(*使用时变参数标志*)                                                     *)
xUseTime_b1_In						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseTime_b1_Rw;(*: BOOL;(*默认时时变的,有效则b1随卷径实时变化-不实时变化则使用b1_0@2024.05.14.080937*)*)
byAlarmHold_PreCut_In				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAlarmHold_PreCut_Rw;(*预备接料响铃时间*)
(*2025.8.22.203359*)
axClearPrnLen_In[1]					:= g_axClearPrnLen[i_iGrpId,1];
axClearPrnLen_In[2]					:= g_axClearPrnLen[i_iGrpId,2];
axClearPrnLen_In[3]					:= g_axClearPrnLen[i_iGrpId,3];
axFlag_PrnLen_Alarm_In_Out[1]		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[1];
axFlag_PrnLen_Alarm_In_Out[2]		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[2];
axFlag_PrnLen_Alarm_In_Out[3]		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[3];
alrPrnLen_Alarm_In[1]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_Alr[1];
alrPrnLen_Alarm_In[2]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_Alr[2];
alrPrnLen_Alarm_In[3]:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_Alr[3];


rPrintLengthCoef_In					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPrintLengthCoef;
lrPrintLength_In_Out:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrPrnLen_AmountTo;
byPrintLength_CalcCtl_In_Out:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byPrintLength_CalcCtl;
FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	axLinkage_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;
	axSwitchOn_CoatingPrn_In[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitchOn_CoatingPrn;
END_FOR
iGetPosUnitId:=1;

FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_aiGrpAxisList[iN];
	(*联动非涂布色*)
	IF axLinkage_In[iUnitId] THEN
		iGetPosUnitId:=iUnitId;(*联动|都是涂布就取最后一个轴*)
		IF (NOT axSwitchOn_CoatingPrn_In[iUnitId]) THEN(*非涂布*)
			iGetPosUnitId:=iUnitId;
			EXIT;
		END_IF
	END_IF
END_FOR
IF iGetPosUnitId>0 AND iGetPosUnitId<=MAX_UNIT_NUM THEN
	//lrPrf_Pos_FirstAxis_In:= i_pstStSysParam^.astStUnitParam_UnSave[iGetPosUnitId].lrEnc_Pos;
	lrPrf_Pos_FirstAxis_In:= i_pstStSysParam^.astStUnitParam_UnSave[iGetPosUnitId].lrEnc_Pos;
	uiNum_FirstAxis_In:= i_pstStSysParam^.astStUnitParam_Save[iGetPosUnitId].uiNum_PrnRoller;
	uiDen_FirstAxis_In:= i_pstStSysParam^.astStUnitParam_Save[iGetPosUnitId].uiDen_PrnRoller;
	rGirth_FirstAxis_In:= i_pstStSysParam^.astStUnitParam_Save[iGetPosUnitId].rGirth_PrnRoller;
END_IF

(*------------------------------------------------------------*)
(*2025.8.4.142641输入输出参数-输入获取*)
xAxisDebugEn_In_Out			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.8;
xAxisADebugRun_In_Out		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.9; 
xAxisBDebugRun_In_Out		:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.12;
xAxisADebugRunning_In_Out	:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.11;
xAxisBDebugRunning_In_Out	:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.14;
xAxisADebugAutoAccDec_In_Out:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.10;
xAxisBDebugAutoAccDec_In_Out:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.13;
xTaperUnitType_In_Out					:= i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.3;
byTaperUnit_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_Rw;
byTaperUnitConfirm_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_Rw;
rPercentMatchN_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_Rw;
rPercentMatchMpa_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_Rw;
rTaperValueBegin_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_Rw;
rTaperValueEnd_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_Rw;
rTaperValueCur_Hmi_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_Rw;
rTaper_Begin_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_Rw;
rTaper_End_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_Rw;
rTaper_Cur_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Rw;
rTaperMax_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_Rw;

iDebugVelmpm_AxisA_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisA_Rw;
iDebugGirthmm_AxisA_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisA_Rw;
iDebugVelmpm_AxisB_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisB_Rw;
iDebugGirthmm_AxisB_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisB_Rw;
dwEncodePos_In_Out							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAbsEncSPos_Cur_Uw;(*: DWORD;                                                  *)
xCutterOnTopFroDebug_In_Out				:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCutterOnTopFroDebug_Rw;
xCurAxisAFroDebug_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisAFroDebug_Rw;
bySetTestPid_In_Out							:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_Rw;(*: BYTE;(*伪随机步骤*)                         *)
xCurAxisDia_Wr_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisDia_Rw_Wr;(*: BOOL;(*界面周长设定写入按钮*)                *)
xCutAxisA_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.1;(*: BOOL;(*当前轴*)                            *)
rEstiDia_In_Out								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiDia_Rw;(*: REAL;(*预估卷径值*)                         *)
xSwitch_IsUpCut_HMI_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_Change_CutterOnTop_HMI_Rw;(*: BOOL;(*界面切换上下裁开关*)                  *)
byEncodeValueWr_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byEncodeValueWr_Rw;(*: BYTE;(*编码器值写入|放料:                    *)
											:= ;(*			 01 写入轴定位值                    *)
											:= ;(*			 02 写入A轴最小径定位值*)            *)
xGetLenthMachine_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xGetLenthMachine_Rw;(*自动获取整机料长标志*)
byLenth_Machine_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byLenth_Machine;(*整机料长*)
xUseKnob_6Inch_HMI_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseKnob_6Inch_Rw_Hmi;(*TRUE:3/6吋切换使用界面按钮
							FALSE:3/6吋切换使用IO输入开关*)
xKnob_6Inch_HMI_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xKnob_6Inch_Rw;(*界面3/6吋切换开关*)
x6InchFroDebug_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].x6InchFroDebug_Rw;
xEnCodeFailed_In_Out						:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Rw;(*: BOOL;			                          *)
adwAxisALocation_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisALocation_Rw;(*: ARRAY [0..1] OF DWORD;                    *)
adwAxisBLocation_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisBLocation_Rw;(*: ARRAY [0..1] OF DWORD;                    *)
rDebugCurVelmpmAxisA_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisA_Rw;(*: REAL;                   *)
rDebugCurVelmpmAxisB_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisB_Rw;(*: REAL;                   *)
rDebugCurVelrpmAxisA_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisA_Rw;(*: REAL;	                *)
rDebugCurVelrpmAxisB_In_Out					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisB_Rw;(*: REAL;					*)			  
rGirth_AxisA_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaA_Rw;(*: REAL;(*设定周长A*)                                                          *)
rGirth_AxisB_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaB_Rw;(*: REAL;(*设定周长B*)                                                          *)
xFlag_Cut_end_UseInOtherPrg_In_Out			:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Rw_UseInOtherPrg;(*: BOOL;(*使用在别的Prg中的放料裁切完成标志|在自己的prg中清除*)	*)						  
alrPrnLen_FilmVel_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_FilmVel;						
alrPrnLen_PTPos_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_PTPos;
alrPrnLen_FilmCnt_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_FilmCnt;
alrPrnLen_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen;
rEstiThickness_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiThickness_Rw;(*: REAL;                                                   *)
byVelSa_DiamCompensate_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byVelSa_DiamCompensate_Rw;(*: BYTE;(*补偿起始速度*)                                     *)
byDelayTime_DiaCompensateWhenCutDne_In_Out	:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byDelayTime_DiaCompensateWhenCutDne_Rw;(*: BYTE;(*裁切后卷径补偿之后时间|s*)                           *)
rFilmThickNess_Using_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThickNess_Using;(*: REAL;(*使用的料膜厚度*)                                   *)
rKc_In_Out									:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Rw;(*: REAL;                                                   *)
rKc_AccDec_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Rw_AccDec;(*: REAL;                                                   *)
uiUseTime_Diam_Min_In_Out					:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiUseTime_Diam_Min_Rw;(*: UINT;                                                   *)
rR_K_LQR_In_Out								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_LQR_Rw;(*: REAL;                                                   *)
rN_LQR_In_Out								:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_LQR_Rw;(*: REAL;                                                   *)
rR_K_MinBeat_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_MinBeat_Rw;(*: REAL;                                                   *)
iN_MinBeat_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iN_MinBeat_Rw;(*: INT;                                                    *)
stModelParam_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stModelParam_Rw;(*: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)      *)
stInvariant_Parameters_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stInvariant_Parameters_Rw;(*: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)      *)
stPI_Parameters_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Rw;(*: PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)			*)			  
stPI_Parameters_AccDec_In_Out				:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Rw_AccDec;(*: PI_Parameters;(*控制器pi参数@20bytes|用于加减速*)			*)			  

byInitTaper_In_Out							:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byInitTaper_Rw;
rInitTaper_Hmi_In_Out						:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rInitTaper_Hmi_Rw; 
(*2025.8.22.202930*)
abyClrPrnLenCount_In_Out[1]					:= g_abyClrPrnLenCount[i_iGrpId,1];					
abyClrPrnLenCount_In_Out[2]					:= g_abyClrPrnLenCount[i_iGrpId,2];					
abyClrPrnLenCount_In_Out[3]					:= g_abyClrPrnLenCount[i_iGrpId,3];
//2026.04.10.100719 增加计米清零
abyClrPrnLenCount_In_Out[1]					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyClrPrnLenCount_Rw[1];
abyClrPrnLenCount_In_Out[2]					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyClrPrnLenCount_Rw[2];	
abyClrPrnLenCount_In_Out[3]					:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyClrPrnLenCount_Rw[3];						





(*------------------------------------------------------------*)

(*IO状态获取2025.8.4.142712*)
(*上下裁切换*)
afbTRIG_UwRw_Input[1](CLK:= i_pstStIOMap_Rw^.i_xIsUpCut,Q=>i_pstStEvtReq^.xReq_IsUpCut);
i_pstStEvtReq^.xEvt_IsUpCut:= i_pstStIOMap_Rw^.i_xIsUpCut;
(*预备接料*)
afbTRIG_UwRw_Input[2](CLK:= i_pstStIOMap_Rw^.i_xPreCut,Q=>i_pstStEvtReq^.xReq_PreCut);
i_pstStEvtReq^.xEvt_PreCut:= i_pstStIOMap_Rw^.i_xPreCut;
(*接料取消*)
afbTRIG_UwRw_Input[3](CLK:= i_pstStIOMap_Rw^.i_xCut_Cancel,Q=>i_pstStEvtReq^.xReq_CutCancel);
i_pstStEvtReq^.xEvt_CutCancel:= i_pstStIOMap_Rw^.i_xCut_Cancel;
(*接料*)
afbTRIG_UwRw_Input[4](CLK:= i_pstStIOMap_Rw^.i_xCut,Q=>i_pstStEvtReq^.xReq_Cut);
i_pstStEvtReq^.xEvt_Cut:= i_pstStIOMap_Rw^.i_xCut;
(*轴切换*)
afbTRIG_UwRw_Input[5](CLK:= i_pstStIOMap_Rw^.i_xAxisExchange,Q=>i_pstStEvtReq^.xReq_AxisExchange);
i_pstStEvtReq^.xEvt_AxisExchange:= i_pstStIOMap_Rw^.i_xAxisExchange;
(*正转*)
afbTRIG_UwRw_Input[6](CLK:= i_pstStIOMap_Rw^.i_xForward,Q=>i_pstStEvtReq^.xReq_Forward);
i_pstStEvtReq^.xEvt_Forward:= i_pstStIOMap_Rw^.i_xForward;
(*反转*)
afbTRIG_UwRw_Input[7](CLK:= i_pstStIOMap_Rw^.i_xReversal,Q=>i_pstStEvtReq^.xReq_Reversal);
i_pstStEvtReq^.xEvt_Reversal:= i_pstStIOMap_Rw^.i_xReversal;
(*急停*)
afbTRIG_UwRw_Input[8](CLK:= i_pstStIOMap_Rw^.i_xEstop,Q=>i_pstStEvtReq^.xReq_Estop);
i_pstStEvtReq^.xEvt_Estop:= i_pstStIOMap_Rw^.i_xEstop;
(*单运行*)
afbTRIG_UwRw_Input[9](CLK:= i_pstStIOMap_Rw^.i_xAxisInch,Q=>i_pstStEvtReq^.xReq_Inch);
i_pstStEvtReq^.xEvt_Inch:= i_pstStIOMap_Rw^.i_xAxisInch;
(*反向单运行*)
afbTRIG_UwRw_Input[10](CLK:= i_pstStIOMap_Rw^.i_xAxisInch_Rev,Q=>i_pstStEvtReq^.xReq_RevInch);
i_pstStEvtReq^.xEvt_RevInch:= i_pstStIOMap_Rw^.i_xAxisInch_Rev;
(*上裁A轴3吋定位*)
afbTRIG_UwRw_Input[11](CLK:= i_pstStIOMap_Rw^.i_xAxisA_Locating_UpCut,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_Up);
i_pstStEvtReq^.xEvt_AxisA_Locating_Up:= i_pstStIOMap_Rw^.i_xAxisA_Locating_UpCut;
(*上裁B轴3吋定位*)
afbTRIG_UwRw_Input[12](CLK:= i_pstStIOMap_Rw^.i_xAxisB_Locating_UpCut,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_Up);
i_pstStEvtReq^.xEvt_AxisB_Locating_Up:= i_pstStIOMap_Rw^.i_xAxisB_Locating_UpCut;
(*上裁A轴6吋定位*)
afbTRIG_UwRw_Input[13](CLK:= i_pstStIOMap_Rw^.i_xAxisA_Locating_UpCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_UpCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisA_Locating_UpCut_PaperCore6Inch:= i_pstStIOMap_Rw^.i_xAxisA_Locating_UpCut_PaperCore6Inch;
(*上裁B轴6吋定位*)
afbTRIG_UwRw_Input[14](CLK:= i_pstStIOMap_Rw^.i_xAxisB_Locating_UpCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_UpCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisB_Locating_UpCut_PaperCore6Inch:= i_pstStIOMap_Rw^.i_xAxisB_Locating_UpCut_PaperCore6Inch;
(*下裁A轴3吋定位*)
afbTRIG_UwRw_Input[15](CLK:= i_pstStIOMap_Rw^.i_xAxisA_Locating_DnCut,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_Dn);
i_pstStEvtReq^.xEvt_AxisA_Locating_Dn:= i_pstStIOMap_Rw^.i_xAxisA_Locating_DnCut;
(*下裁B轴3吋定位*)
afbTRIG_UwRw_Input[16](CLK:= i_pstStIOMap_Rw^.i_xAxisB_Locating_DnCut,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_Dn);
i_pstStEvtReq^.xEvt_AxisB_Locating_Dn:= i_pstStIOMap_Rw^.i_xAxisB_Locating_DnCut;
(*下裁A轴6吋定位*)
afbTRIG_UwRw_Input[17](CLK:= i_pstStIOMap_Rw^.i_xAxisA_Locating_DnCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisA_Locating_DnCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisA_Locating_DnCut_PaperCore6Inch:= i_pstStIOMap_Rw^.i_xAxisA_Locating_DnCut_PaperCore6Inch;
(*下裁B轴6吋定位*)
afbTRIG_UwRw_Input[18](CLK:= i_pstStIOMap_Rw^.i_xAxisB_Locating_DnCut_PaperCore6Inch,Q=>i_pstStEvtReq^.xReq_AxisB_Locating_DnCut_PaperCore6Inch);
i_pstStEvtReq^.xEvt_AxisB_Locating_DnCut_PaperCore6Inch:= i_pstStIOMap_Rw^.i_xAxisB_Locating_DnCut_PaperCore6Inch;
(*上裁最小径定位*)
afbTRIG_UwRw_Input[19](CLK:= i_pstStIOMap_Rw^.i_xMinimumDiamProtect_UpCut,Q=>i_pstStEvtReq^.xReq_MinimumDiamProtect_Up);
i_pstStEvtReq^.xEvt_MinimumDiamProtect_Up:= i_pstStIOMap_Rw^.i_xMinimumDiamProtect_UpCut;
(*上裁对射电眼*)
afbTRIG_UwRw_Input[20](CLK:= i_pstStIOMap_Rw^.i_xSensor_DiamMeasureLocating_UpCut,Q=>i_pstStEvtReq^.xReq_Sensor_DiamMeasureLocating_Up);
i_pstStEvtReq^.xEvt_Sensor_DiamMeasureLocating_Up:= i_pstStIOMap_Rw^.i_xSensor_DiamMeasureLocating_UpCut;
(*下裁最小径定位*)
afbTRIG_UwRw_Input[21](CLK:= i_pstStIOMap_Rw^.i_xMinimumDiamProtect_DnCut,Q=>i_pstStEvtReq^.xReq_MinimumDiamProtect_Dn);
i_pstStEvtReq^.xEvt_MinimumDiamProtect_Dn:= i_pstStIOMap_Rw^.i_xMinimumDiamProtect_DnCut;
(*下裁对射电眼*)
afbTRIG_UwRw_Input[22](CLK:= i_pstStIOMap_Rw^.i_xSensor_DiamMeasureLocating_DnCut,Q=>i_pstStEvtReq^.xReq_Sensor_DiamMeasureLocating_Dn);
i_pstStEvtReq^.xEvt_Sensor_DiamMeasureLocating_Dn:= i_pstStIOMap_Rw^.i_xSensor_DiamMeasureLocating_DnCut;
(*上裁A轴反射电眼*)
afbTRIG_UwRw_Input[23](CLK:= i_pstStIOMap_Rw^.i_xSensor_Reflex_A_Up,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Up_AxisA);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Up_AxisA:= i_pstStIOMap_Rw^.i_xSensor_Reflex_A_Up;
(*上裁B轴反射电眼*)
afbTRIG_UwRw_Input[24](CLK:= i_pstStIOMap_Rw^.i_xSensor_Reflex_B_Up,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Up_AxisB);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Up_AxisB:= i_pstStIOMap_Rw^.i_xSensor_Reflex_B_Up;
(*下裁A轴反射电眼*)
afbTRIG_UwRw_Input[25](CLK:= i_pstStIOMap_Rw^.i_xSensor_Reflex_A_Dn,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Dn_AxisA);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Dn_AxisA:= i_pstStIOMap_Rw^.i_xSensor_Reflex_A_Dn;
(*下裁B轴反射电眼*)
afbTRIG_UwRw_Input[26](CLK:= i_pstStIOMap_Rw^.i_xSensor_Reflex_B_Dn,Q=>i_pstStEvtReq^.xReq_Sensor_Reflex_Dn_AxisB);
i_pstStEvtReq^.xEvt_Sensor_Reflex_Dn_AxisB:= i_pstStIOMap_Rw^.i_xSensor_Reflex_B_Dn;
(*3/6吋切换*)
afbTRIG_UwRw_Input[27](CLK:= i_pstStIOMap_Rw^.i_xPaperCoreSelect6Inch,Q=>i_pstStEvtReq^.xReq_PaperCoreSelect6Inch);
i_pstStEvtReq^.xEvt_PaperCoreSelect6Inch:= i_pstStIOMap_Rw^.i_xPaperCoreSelect6Inch;

afbTRIG_UwRw_Input[28](CLK:= i_pstStIOMap_Rw^.i_xUwMeasureSensor,Q=>i_pstStEvtReq^.xReq_UwMeasureSensor);
i_pstStEvtReq^.xEvt_UwMeasureSensor:= i_pstStIOMap_Rw^.i_xUwMeasureSensor;

afbTRIG_UwRw_Input[29](CLK:= i_pstStIOMap_Rw^.i_xTaper_Incr,Q=>i_pstStEvtReq^.xReq_Taper_Incr);
i_pstStEvtReq^.xEvt_Taper_Incr:= i_pstStIOMap_Rw^.i_xTaper_Incr;

afbTRIG_UwRw_Input[30](CLK:= i_pstStIOMap_Rw^.i_xTaper_Decr,Q=>i_pstStEvtReq^.xReq_Taper_Decr);
i_pstStEvtReq^.xEvt_Taper_Decr:= i_pstStIOMap_Rw^.i_xTaper_Decr;

//2026.5.27.100554单运行速度输入
rVel_Inch_In:= i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch;

