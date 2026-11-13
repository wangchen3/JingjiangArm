(*@CES
Name=KS_FB_Func_Rw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ffe21991-f3a7-4bc1-814e-f267528aa09c
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Func_Rw
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId						: INT;
	i_rVel_Film: REAL;(*料膜速度*)
	i_rVel_Max: REAL;
	i_rAI_Swing: REAL;(*摆臂电压输入*)
	i_xIsDebugMode: BOOL;(*整机调试模式*)
	i_xEstop_Input: BOOL;(*急停按钮*)
	i_xStop_Input: BOOL;(*停机按钮*)
	i_xMachineRev: BOOL;(*反向走料*)
	i_xFlag_Print: BOOL;(*印刷标志*)
	i_xFlag_Tension: BOOL;(*张力投入标志*)
	i_xFlag_EStop: BOOL;(*急停标志*)
	i_xFlag_EStoping: BOOL;(*急停中*)
	i_xFlag_Stoping: BOOL;(*停机中*)
	i_xFlag_FastStoping: BOOL;(*快停中*)
	i_xFlag_Accing: BOOL;
	i_xFlag_Decing: BOOL;
	i_iCustomerNameId				: INT;
	
	i_xEnCodeErr: BOOL;(*编码器故障*)
	i_iCycleTime_Plc: INT;(*周期时间*)
	i_pstStEvtReq: POINTER TO StEvtReq_UwRw;
	i_pbyNeedAutomaticCut_UwRw:POINTER TO BYTE;(*2024.02.23.100940 需要自动裁切设置标志@需要清零
															@=1放料设置 
															@=2收料设置 
															@=10设置确认 =11设置取消*)	
	//2026.05.20.213717 替换为输入输出 by liu.yt	
	//i_astStTimeSet_DnCut_UpCut		: ARRAY [0..1] OF StTimeSet_DnCut_UpCut;

	i_pstStIOMap_Rw: POINTER TO StIOMap_UwRw_FE; (*收料io*)		
	i_pstStSysParam: POINTER TO StSysParam;
	
	i_xInverterCW : BOOL;		
	i_rVel_Stiffen: REAL;
	i_iGrpAxisNum_Pu: INT;
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;														
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
	o_xSts_PreCutting: BOOL;(*预备接料状态*)	
//	o_xFlag_CutEnd: BOOL;
	o_rDiam_NewVol:REAL;(*测量的新卷径*)
//	o_rVel_Predrv:REAL;(*预驱速度*)
	o_rVelRPM_Cur:REAL;(*当前转速*)
	o_rStep:REAL;
	o_rPi_Value:REAL;	
	o_rTotalPiValue:REAL;(*总的pi控制量*)			
END_VAR
VAR_IN_OUT
	io_xCutOnTop:BOOL;(*TRUE 上裁刀|FALSE 下裁刀*)
//	io_xCurAxisA:BOOL;(*TRUE AxisA|FALSE AxisB*)
	io_rDiamCurAxis:REAL;(*当前轴的卷径*)
	io_byKalmanFilterType: BYTE;
	io_byStructParanInitEn: BYTE;
	
	
	//2026.05.20.212706+ by liu.yt
	io_astStTimeSet_DnCut_UpCut: ARRAY [0..1] OF StTimeSet_DnCut_UpCut;
	io_stStTimeSet_DnCut_UpCut_Hmi: StTimeSet_DnCut_UpCut;
END_VAR
VAR
	astTaperPoint_In							: ARRAY [1..10] OF StPoint_XY;
	rDiamTaper_Begin_Rw_In						: REAL;
	rDiamTaper_End_Rw_In						: REAL;
	byTaperAdjMode_In							: BYTE;
	byInitTaper_In								: BYTE;
	rN_In										: REAL;
	rMpa_In										: REAL;	
	uiNum_In									: UINT;
	uiDen_In									: UINT;
	rRatedRpm_In								: REAL;
	rRatedFreq_In								: REAL;
	rUpperFreq_In								: REAL;
	rPseudoRandomRoundAmplitude_Cur_In			: REAL;(*伪随机序列*)
	
	dwAbsEncSinglePos_In						: DWORD;(*单圈位置*)	
	xEn_DualParam_AbsEncLocation_In				: BOOL;	
	xWillAutoMaticPreCut_Uw_In					: BOOL;
	xFlag_Precutting_Uw_In						: BOOL;(*f放料预备接料状态*)
	xCancelTenEn_In								: BOOL;(*取消张力使能*)
	iInitial_speed_In							: INT;(*拉料初始速度*)
	iStiffenCoff_UwRw_In						: INT;(*拉料系数*)
	xRollerSts_IfOf_In								: BOOL;(*收放牵压辊状态*)
	rAI_IfOf_In									: REAL;(*收放牵摆臂输入*)	
	xPseudoRandomEn_In: BOOL;(*伪随机测试按钮*)
	byPseudoRandomId_In: BYTE;(*放料伪随机使能*)
	arK_pid_In: ARRAY [1..3] OF REAL;(*设定PID值*)
	aiTestKp_In: ARRAY [1..3] OF INT;(*伪随机P值*)
	aiTestKd_In: ARRAY [1..3] OF INT;(*伪随机D值*)
	xCutDneResetPidEn_In: BOOL;(*裁切后PID放大*)
	piCutDneResetPidMultiple_In: POINTER TO INT;(*PID放大倍数*)
	iCutDneResetPidRemainTime_In: INT;(*保持时间*)
	iCutDneResetPidToDefaultTime_In: INT;(*恢复时间*)
	xSmallDiaMulEn_In: BOOL;(*小卷补偿功能使能*)
	iSmallDiaMulSa_In: INT;(*小卷补偿起始直径*)
	iSmallDiaMulEd_In: INT;(*小卷补偿结束直径*)
	iSmallDiaMulSa_Coeff_In: INT;(*小卷补偿起始系数*)
	iSmallDiaMulEd_Coeff_In: INT;(*小卷补偿结束系数*)	
	xPseudoRandomTsting_In: BOOL;(*伪随机使能*)
//	uiPiDelayWhenCut_In: UINT;(*放料裁切PI投入时间*)
//	xAxisDebug_Spd_In:BOOL;(*速度调试开关*)
	xPreCutOneBtn_In: BOOL;
	xFlag_SafeTyGratingProctec_In: BOOL;(*光栅保护触发*)
	xUseAbsEncoder_In: BOOL;(*翻转架使用绝对值编码器定位方式&自动卷径*)
	rFilmThickNess_In: REAL;(*料膜厚度*)
	xFlag_CancelSafetyGrating_In: BOOL;(*光栅保护取消*)
	xAutomaticCutEn_In: BOOL;(*自动接料使能*)
	byAutoMaticCutMode_In: BYTE;(*自动接料模式选择*)
	iTime_PreDrvAcc_In: INT;(*预驱加速时间*)
	iTime_PreDrvDec_In: INT;(*预驱减速时间*)
	rGirth_6Inch_In: REAL;
	rGirth_3Inch_In: REAL;
	iDebugGirthmm_AxisA_In: INT;
	iDebugGirthmm_AxisB_In: INT;
	rCoefCut_FilmVolPerimeter_In: REAL;
	uiMaxDia_In: UINT;
	uiInitDiam_In: UINT;
	xTypeGetInitDiam_In: BOOL;
	(*卷径估计计算使能|2022.7.25.160222*)	
	xFlag_RollerPressAtLeast1_In: BOOL;
	rWc_LowPass_Diam_In: REAL;
	xUseFeedVel_In: BOOL;						 
	rVel_Feed_In: REAL;(*牵引速度-放料放牵收料收牵*)					 
	xDiaEstEn_In: BOOL;(*卷径估计使能开关*)
	xFilmAccDecDone_In: BOOL;(*料膜加减速完成*)
	xFlag_RollerPressDne_In	: BOOL;	(*色组压辊合压完成*)
	xUseDiam_LowPass_In: BOOL;(*使用低通的卷径值*)
	xTensionCompensateEn_In: BOOL;(*张力补偿开关*)	 
	xTensionCompensateEn_Cut_In: BOOL;(*裁切张力补偿开关*)	
	xUseIMatrix_rX_DARE_In: BOOL;(*使用单位矩阵*)
	xUseTime_Variaition_In: BOOL;(*使用时变参数标志*)
	xUseTime_b1_In: BOOL;(*默认时时变的,有效则b1随卷径实时变化-不实时变化则使用b1_0@2024.05.14.080937*)
	byAlarmHold_PreCut_In						: BYTE;(*预备接料响铃时间*)
	uiAutoMaticCutMeters_In						: UINT;(*剩余米数*)
	uiAutoMaticCutDia_In						: UINT;(*剩余卷径*)
	(*2025.8.22.203319*)
	axClearPrnLen_In				: ARRAY [1..3] OF BOOL;
	rPrintLengthCoef_In				: REAL;(*计米系数*)
	axLinkage_In						: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axSwitchOn_CoatingPrn_In			: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	lrPrf_Pos_FirstAxis_In					: LREAL;(*版规划位置*)
	uiNum_FirstAxis_In						: UINT;(*减速比*)
	uiDen_FirstAxis_In						: UINT;(**)
	rGirth_FirstAxis_In						: REAL;(*版周长*)	
	alrPrnLen_Alarm_In						: ARRAY [1..3] OF LREAL;(**)
	rVel_Inch_In							: REAL;//2026.5.27.100716单运行速度输入

	rAxisAVolByVel_Out:REAL;(*A轴输出电压值*)
	rAxisBVolByVel_Out:REAL;(*B轴输出电压值*)
	rAxisAVel_RPM_Out:REAL;(*A轴转速值*)
	rAxisBVel_RPM_Out:REAL;(*B轴转速值*)
	rAxisAFreq_Out								: REAL;
	rAxisBFreq_Out								: REAL;
	xFlag_AutoMaticCutting_Out					: BOOL;							
	xNeedAlarmBell_Out: BOOL;(*警铃输出*)						
	xPrevNeedAlarmBell_Out: BOOL;(*警铃输出@备份值,赋值的对象会在别的任务里操作故做此处理 by liu.yt*)
	xAxisALocaltion_Out: BOOL;(*A轴定位输出-其他客户可用*)
	xAxisBLocaltion_Out: BOOL;(*A轴定位输出-其他客户可用*)
	xAllowSwitchCutter_Out: BOOL;
	xFlag_6Inch_Out: BOOL;(*当前为6吋纸芯*)

	rVel_Predrv_Out: REAL;
	xFlag_PreDrv_ing_Out: BOOL;(**)
	xFlag_PreDrv_end_Out: BOOL;
	xPreDrvAxis_Releasing_Out: BOOL;
	xFlag_Cut_ing_Out: BOOL;
	arKpid_Use_Out: ARRAY [1..3] OF REAL;(*当前使用PID*)
	xFlag_Cut_end_Out: BOOL;
	stTime_Varying_Parameters_Output: Time_Varying_Parameters;	
	rWuCompensate_Out: REAL;(*补偿的转速-计算值*)
	rWuCompensate_Act_Out: REAL;(*补偿的转速-应用值*)
	xFlag_TensionDone_Out						: BOOL;(*拉料完成*)
	rAutoMaticCuttingLenth_CurMode_Rw_Out		: real;(*收料自动接料模式计米值2025.10.20.134234*)
	
	byInitTaper_In_Out:BYTE ;(*: POINTER TO BYTE;*)
	rInitTaper_Hmi_In_Out:REAL ;(*: POINTER TO REAL;*)
	xAxisDebugEn_In_Out: BOOL;
	xAxisADebugRun_In_Out: BOOL;
	xAxisBDebugRun_In_Out: BOOL;
	xAxisADebugRunning_In_Out: BOOL;
	xAxisBDebugRunning_In_Out: BOOL;
	xAxisADebugAutoAccDec_In_Out: BOOL;
	xAxisBDebugAutoAccDec_In_Out: BOOL;
	xTaperUnitType_In_Out					: BOOL;
	byTaperUnit_In_Out						: BYTE;
	byTaperUnitConfirm_In_Out				: BYTE;
	rPercentMatchN_In_Out					: REAL;
	rPercentMatchMpa_In_Out					: REAL;
	rTaperValueBegin_Hmi_In_Out				: REAL;
	rTaperValueEnd_Hmi_In_Out				: REAL;
	rTaperValueCur_Hmi_In_Out				: REAL;
	rTaper_Begin_In_Out						: REAL;
	rTaper_End_In_Out						: REAL;
	rTaper_Cur_In_Out						: REAL;
	rTaperMax_In_Out						: REAL;
	
	iDebugVelmpm_AxisA_In_Out				: INT;
	iDebugGirthmm_AxisA_In_Out				: INT;
	iDebugVelmpm_AxisB_In_Out				: INT;
	iDebugGirthmm_AxisB_In_Out				: INT;
	dwEncodePos_In_Out						: DWORD;
	xCutterOnTopFroDebug_In_Out				: BOOL;(*放料上裁标志-调试*)
	xCurAxisAFroDebug_In_Out						: BOOL;(*放料预驱轴A轴-调试*)
	xDebug_Enc_In_Out_UwRw: BOOL;(*绝对值编码器调试开关*)	
	bySetTestPid_In_Out: BYTE;(*伪随机步骤*)
	xCurAxisDia_Wr_In_Out: BOOL;(*界面周长设定写入按钮*)
	xCutAxisA_In_Out: BOOL;(*当前轴*)
	rEstiDia_In_Out: REAL;(*预估卷径值*)
	xSwitch_IsUpCut_HMI_In_Out: BOOL;(*界面切换上下裁开关*)
	byEncodeValueWr_In_Out					: BYTE;(*编码器值写入|放料:
															 01 写入轴定位值
															 02 写入A轴最小径定位值*)	
	xGetLenthMachine_In_Out: BOOL;(*自动获取整机料长标志*)
	byLenth_Machine_In_Out: BYTE;(*整机料长*)
	xUseKnob_6Inch_HMI_In_Out: BOOL;(*TRUE:3/6吋切换使用界面按钮
							FALSE:3/6吋切换使用IO输入开关*)
	xKnob_6Inch_HMI_In_Out: BOOL;(*界面3/6吋切换开关*)
	x6InchFroDebug_In_Out: BOOL;
	xEnCodeErr_In_Out: BOOL;
	xEnCodeFailed_In_Out: BOOL;							
	adwAxisALocation_In_Out: ARRAY [0..1,0..1] OF DWORD;
	adwAxisBLocation_In_Out: ARRAY [0..1,0..1] OF DWORD;	
// 	wAxisDebug_UwRw_In_Out: WORD;(**)(*轴调试标志|.0\放料调试使能.1\放料A轴调试运行.2\放料A轴自动加减速.3\放料A轴运行中.4\放料B轴调试运行.5\放料B轴自动加减速.6\放料B轴运行中
// 									  .8\收料调试使能.9\收料A轴调试运行.10\收料A轴自动加减速.11\收料A轴运行中.12\收料B轴调试运行.13\收料B轴自动加减速.14\收料B轴运行中*)						 
// 	
	rDebugCurVelmpmAxisA_In_Out: REAL;
	rDebugCurVelmpmAxisB_In_Out: REAL;
	rDebugCurVelrpmAxisA_In_Out: REAL;	
	rDebugCurVelrpmAxisB_In_Out: REAL;		
	rGirth_AxisA_In_Out: REAL;(*设定周长A*)
	rGirth_AxisB_In_Out: REAL;(*设定周长B*)
	xFlag_Cut_end_UseInOtherPrg_In_Out: BOOL;(*使用在别的Prg中的放料裁切完成标志|在自己的prg中清除*)								  
	alrPrnLen_FilmVel_In_Out: ARRAY [1..3] OF LREAL;
	alrPrnLen_PTPos_In_Out: ARRAY [1..3] OF LREAL;
	alrPrnLen_FilmCnt_In_Out: ARRAY [1..3] OF LREAL;
	alrPrnLen_In_Out: ARRAY [1..3] OF LREAL;
	rEstiThickness_In_Out: REAL;
	byVelSa_DiamCompensate_In_Out: BYTE;(*补偿起始速度*)
	byDelayTime_DiaCompensateWhenCutDne_In_Out: BYTE;(*裁切后卷径补偿之后时间|s*)
	rFilmThickNess_Using_In_Out: REAL;(*使用的料膜厚度*)
	rKc_In_Out: REAL;
	rKc_AccDec_In_Out: REAL;
	uiUseTime_Diam_Min_In_Out: UINT;
	rR_K_LQR_In_Out: REAL;
	rN_LQR_In_Out: REAL;
	rR_K_MinBeat_In_Out: REAL;
	iN_MinBeat_In_Out: INT;
	stModelParam_In_Out: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)
	stInvariant_Parameters_In_Out: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)
	stPI_Parameters_In_Out:	PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)							  
	stPI_Parameters_AccDec_In_Out:	PI_Parameters;(*控制器pi参数@20bytes|用于加减速*)							  
	(*2025.8.22.202835*)
	abyClrPrnLenCount_In_Out: ARRAY [1..3] OF BYTE;
	lrPrintLength_In_Out: LREAL;
	byPrintLength_CalcCtl_In_Out: BYTE;
	axFlag_PrnLen_Alarm_In_Out: ARRAY [1..3] OF BOOL;
	
	
	
	
	(*3 6寸周长确认逻辑|2020.9.9.084511*)
	xGirth_RwBy3Inch_6Inch: BOOL;
	xGirth_RwBy3Inch_6InchBak:BOOL;
	rGirth_6Inch: REAL;
	rGirth_3Inch: REAL;
	xPreFlag_6Inch: BOOL;
	xInit_AxisAGirth_AxisBGirth_Rw: BOOL;
	xBtn_AxisLocationManu: BOOL;(*编码器故障时，手动按钮定位标志*)	
	xAxisALocationByAbsEnc: BOOL;(*通过绝对值编码器确定的A轴定位*)
	xAxisBLocationByAbsEnc: BOOL;(*放料通过绝对值编码器确定的B轴定位*)
	xAxisLocationInvalid: BOOL;(*轴定位无效*)
	xAxisLocationWrDne: BOOL;(*轴定位写入成功*)
	tTime_AlarmForAxisLocation: TIME:=T#1S;(*轴定位写入完成响铃时间*)
	tTime_Alarm: TIME;(*响铃时间*)
	tTime_AlarmSa: TIME;(*响铃开始时间*)	
	xAccDecingCompensateEn: BOOL;	
	rSpliceCompensate: REAL;
	rMainVel: REAL;
	rFilmThickNess: REAL;(*料膜厚度*)
	byNeedAutomaticCut_UwRw:BYTE;(*2024.02.23.100940 需要自动裁切设置标志@需要清零
															@=1放料设置 
															@=2收料设置 
															@=10设置确认 =11设置取消*)
															

	
	byForeward_mtf: BYTE; (*翻料架正转|Material Tumbling Frame|2017-08-17 09:41:38*)
	byReversal_mtf: BYTE; (*翻料架反转*)	
	iDelayMsec_CutterHolder_Final: INT;(*大臂延时*)
	iDelayMsec_RollerCylinder_Final: INT;(*压辊延时*)
	iDelayMsec_CutOffKnifeCylinder_Final: INT;(*裁刀延时*)
	xBtnPreCut:BOOL;
	xBtnCut_Cancel:BOOL;	
	xLastPreCutBtn: BOOL;
	xAutoMaticCutTrig_Precut: BOOL;(*自动接料输出的动作*)	
	xAutoMaticCutTrig_CutCancel: BOOL;
	xAutoMaticCutTrig_Cut: BOOL;(*自动裁切输出的裁切*)
	xBtnPreCut_Use: BOOL;
	xBtnCut_Cancel_Use:BOOL;
	xBtnCut_Use: BOOL;
	xBtnPreCut_Debug: BOOL;(*来自于放料调试按钮*)
	xBtnCut_Debug: BOOL;
	xBtnCut_Cancel_Debug: BOOL;(**)
	xFlag_SafetyGratingProcting: BOOL;(*光栅保护中*)
	xCutHolderSts_Retain: BOOL;(*大臂保持当前状态标志*)
	xCutHolderSts_UpCut_WhenSaftyGratingOn: BOOL;(*光栅触发时候放料大臂|上*)
	xCutHolderSts_DnCut_WhenSaftyGratingOn: BOOL;(*光栅触发时候放料大臂|下*)
	xCutHolderCanDebug: BOOL;(*放料调试控制大臂上升下降标志-调试模式单击接料按钮*)
	xCutHolderDn_Debug: BOOL;(*放料大臂调试情况下合压了|用于控制抬起逻辑沿触发*)														
	iCnt_Cuttrig: INT;(*接料按钮按下计数*)												
	tTime_CutTrig: TIME;(*获取按下接料按钮时间*)	
	xSts_ArmFalling: BOOL;(*大臂下落中*)
	xSts_ArmFall_end: BOOL;(*大臂落下标志*)

	tTime_AlarmForAxisLocation_3Inch: TIME:=T#1S;(*3寸轴定位写入完成响铃时间*)
	tTime_AlarmForAxisLocation_6Inch: TIME:=T#3S;(*6寸轴定位写入完成响铃时间*)								
	xOpenAutomaticCutEnTips: BOOL;
	xAxisLocationWrDne_3Inch: BOOL;
	xAxisLocationWrDne_6Inch: BOOL;
	xAxisALocation_Use: BOOL;(*A轴最终定位*)
	xAxisBLocation_Use: BOOL;(*B轴最终定位*)
	xSts_Limited_AxisLocaltion:BOOL;(*在轴限位位置*)
	xCutHolder_InPosition: BOOL;(*大臂就wei*)
	xSts_WaitingCut: BOOL;(*等待裁切标志*)
	rDiameterTmp: REAL;(*原功能快计算获得的卷径值*)
	xDiamWr_Manu: BOOL;(*卷径手动写入@不需要使用低通*)
	xCutCtlEn: BOOL;
	rDiam_NewVol_Use: REAL;
	rVel_Predrv_Use: REAL;
	xLamp_PreDrive_Debug: BOOL;
	xOutput_CutCylinder: BOOL;	
	iCutTotalTime: INT;
	xExChange: BOOL;
	xInverterCW: BOOL;
	xInch: BOOL;
	xRevInch: BOOL;
	xFilmToBig: BOOL:=FALSE;(*存在整机反转的情况|该标志控制放料是变大还是变小*)
	xCalcEstValueEn: BOOL;	
	rVel_CalcVolt: REAL;(*计算放料电压的放料速度|放料增加扰动补偿，防止意外飞车*)
	rWc_LowPass: REAL;
	xDiamRegInit_Lp: BOOL;
	arUk_LowPass: ARRAY [1..2] OF REAL;
	arYk_LowPass: ARRAY [1..2] OF REAL;
	rEstiDia_LowPass: REAL;
	xGetFilmThicknessEn: BOOL;(*自动获取条件满足了*)
	xThicknessAutoGetDne: BOOL;(*自动获取成功了*)
	xInitDiameter:BOOL:=TRUE;(*开机初始化卷径临时变量|初始化为保存的卷径值*)	
	rLastDia_Cur: REAL;(*上个周期的当前卷径*)
	xEnFlag_CalcDiam_Ret: BOOL;
	rNull: REAL;
	rVelTmp: REAL;
	xDiaEstEn: BOOL;(*卷径估计功能使能*)
	xCanDiaCompensate: BOOL;
	rDia_Cur: REAL;
	xLastDiaEstEn: BOOL;
	tTimeCutDne: TIME;(*裁切时间*)
	(*2023.09.04.142318 放料在接料的时候也进行按圈卷径规划*)
	rDiaPrf_CutDne: REAL;
	rDiaSa_CutDne: REAL;
	rLastVelmpm: REAL;
	iMaxIterateCnt_LQR: INT;
	xLamp_PreDrive: BOOL;
	xLampAutoMaticCutting: BOOL;
	xLampFlick_AxisVelDebug: BOOL;
	xCutHolderSts_Retaining: BOOL;
	xInit_Taper_Cur: BOOL;
	iTimeTaperChange:INT:=10000;(*锥度变化时间|ms*)
	rTaperTar: REAL;
	rTaperCur: REAL;
	rDeltTaper: REAL;
(*2025.8.22.202655*)
	axFilmLenSet0_Rw: ARRAY [1..3] OF BOOL;(*计米清零标志|索引：1-A轴 2-B轴 3-总计长*)
	iN: INT;
	atmTimeouts_ClrPrnLen: ARRAY [1..3] OF TIME := [3(T#0MS)]; (* A/B系计长清零操作计时 *)
	iCoeff_Lenth_Rw: INT;
	xCalcPrintLenWayChange: BOOL;(*计米方式切换标志--功能中已经将方式写死！*)
	iGetPosUnitId: INT;
	iUnitId:INT;
	
(*2025.8.22.202655*)	
	
	fbAlarmHoldTon_PreCut: TON;	
	fbTonFLick_Lamp_preDrive: TON;
	afbTRIG_UwRw_Input: ARRAY [1..30] OF R_TRIG;		
	fbTon_DelayTimer_CutOffKnifeCylinder: TON;
	fbKS_FB_PreDrv_Ctl:KS_FB_PreDrv_CTL_REV;
	fbKS_FB_AxisDebug: KS_FB_AxisDebug;
	fbTon_ArmFalling: TON;
	fbRTrig_AxisALimit: R_TRIG;
	fbRTrig_AxisBLimit: R_TRIG;	
	fbLampFlick_SafeTyGrating: TON;														
	afbDebug_UwRw: ARRAY [1..2] OF R_TRIG;
	fbRTrig_PreCut: R_TRIG;(*预备接料触发*)
	fbRTrig_Cut: R_TRIG;(*接料触发*)
	fbRTrig_CancelCut: R_TRIG;		(*接料解除触发*)								
	fbKS_FB_AutoMaticCut_Rw: KS_FB_AutoMaticCut_Rw;	(*自动接料*)
	fbKS_FB_AbsEncForTower_Rw: KS_FB_AbsEncForTower_Rw;(*收料编码器定位*)
	fbKS_FB_CutDelay_CTL_Rw: KS_FB_CutDelay_CTL_Rw;
	fbKS_FB_Exchange: KS_FB_Exchange;
	fbKS_FB_GetKpid: KS_FB_GetKpid;
	fbKS_FB_UwRw_TensionCTL: KS_FB_UwRw_TensionCTL;
	fbKS_FB_UwRw_Tension_2024: KS_FB_UwRw_Tension_2024;
	fbKS_FB_EstimationByVel: KS_FB_EstimationByVel;
	fbKS_FB_CalcDiamOfFilmVol: KS_FB_CalcDiamOfFilmVol;
	fbKS_FB_VelocityToVoltage: KS_FB_VelocityToVoltage;
	fbKS_FB_Taper: KS_FB_Taper;
	//fbKS_FB_WindLenthDeal: KS_FB_WindLenthDeal;
//	fbKS_FB_Func_Stiffen: KS_FB_Func_Stiffen;
	
	fbKS_FB_TaperUnitDeal: KS_FB_TaperUnitDeal_New;
(*2025.8.22.203949*)
	fbKS_FB_WindLengthDeal: KS_FB_WindLengthDeal;
	
	rVel_Adjust: REAL;
	
	
	//2026.05.21.092117
	xParaInit:BOOL:=TRUE;(*参数初始化标志*)
	xLastCutOnTop:BOOL;(*上个周期上下裁刀标志*)		
	
	//2026.05.20.212849+ by liu.yt
	pstStTimeSet_DnCut_UpCut:POINTER TO StTimeSet_DnCut_UpCut;
	xUpdateUpLoadData:BOOL;//更新上行数据
	fbTon_UpLoadData:TON;//计时器
END_VAR


{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_pstStEvtReq<>0 AND
		i_pbyNeedAutomaticCut_UwRw<>0 AND
		i_pstStIOMap_Rw<>0 AND
		i_pstStSysParam<>0 THEN
		
(*获取所有用到的输入，有一部分输入放到了功能块的输入变量上面*)
		Action_Input();
(*-------------------------------------处理所有动作--------------------------------------------*)		
		//Action_Stiffen();(*拉料控制*)
		xInverterCW := i_xInverterCW;
		
		
		Action_AxisExChange();(*轴切换*)
		Action_CutCtl();(*裁切控制*)
		(*裁切控制包含
			1.上下裁切换
			2.Action_Cutctl_AutoCut()-自动裁切处理
			3.3/6吋切换
			4.Action_CutCtl_CutHolderCtl()-大臂控制
			5.Action_CutCtl_TowerCtl()-翻转架控制
			6.Action_CutCtl_PreCut()-预备接料-接料取消处理
			7.Action_CutCtl_PreDrv()-预驱控制
		*)
		Action_Tension();(*张力控制*)
		(*裁切控制包含
			1.裁切完成交换卷径
			2.伪随机使能赋值
			3.PID计算
			4.Action_Compensate()卷径估计及张力补偿
			5.张力调整新老算法			
		*)
		Action_AxisDebug();(*轴调试*)
		Action_InverterIOCtl();(*变频IO控制*)
		Action_VelToVol();(*变频速度电压转换*)
(*2025.8.5.204633先不管计米
		Action_WindLenth();(*计米*)
		*)
		Action_Taper();(*锥度*)
		Action_LampIODeal();(*部分指示灯逻辑*)
			(*2025.8.22.214640*)
		Action_WindLength();	
(*-------------------------------------处理所有动作----end----------------------------------------*)		
		
(*输出这里处理吧*)		
		Action_Output();
		
	ELSE;
	END_IF
ELSE
	;
END_IF