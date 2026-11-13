(*@CES
Name=KS_FB_Func_Uw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=17963d2a-2271-4140-99c0-e5ecc7afff05
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Func_Uw
VAR_INPUT
	i_xEn							: BOOL;
	i_iGrpId						: INT;
	i_rVel_Film						: REAL;(*料膜速度*)
	i_rVel_Max						: REAL;
	i_rAI_Swing						: REAL;(*摆臂电压输入*)
	i_xIsDebugMode					: BOOL;(*整机调试模式*)
	i_xEstop_Input					: BOOL;(*急停按钮*)
	i_xStop_Input					: BOOL;(*停机按钮*)
	i_xMachineRev					: BOOL;(*反向走料*)
	i_xFlag_Print					: BOOL;(*印刷标志*)
	i_xFlag_Tension					: BOOL;(*张力投入标志*)
	i_xFlag_EStop					: BOOL;(*急停标志*)
	i_xFlag_EStoping				: BOOL;(*急停中*)
	i_xFlag_Stoping					: BOOL;(*停机中*)
	i_xFlag_FastStoping				: BOOL;(*快停中*)
	i_xFlag_Accing					: BOOL;
	i_xFlag_Decing					: BOOL;
	i_iCustomerNameId				: INT;
	i_xEnCodeErr					: BOOL;(*编码器故障*)
	i_xClrAlarmInf					: BOOL;(*清除报警信息提示|2022.9.14.155627*)
	i_iCycleTime_Plc				: INT;(*周期时间*)
	i_pstStEvtReq					: POINTER TO StEvtReq_UwRw;
	i_pbyNeedAutomaticCut_UwRw		:POINTER TO BYTE;(*2024.02.23.100940 需要自动裁切设置标志@需要清零
															@=1放料设置 
															@=2收料设置 
															@=10设置确认 =11设置取消*)
	//2026.05.20.213717 替换为输入输出 by liu.yt	
	//i_astStTimeSet_DnCut_UpCut		: ARRAY [0..1] OF StTimeSet_DnCut_UpCut;

	i_pstStIOMap_Uw: POINTER TO StIOMap_UwRw_FE; (*放料io*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_xInverterCW : BOOL;
	i_rVel_Stiffen: REAL;
	//2026.5.9.211106
	i_pxReq_Cut_Uw: POINTER TO BOOL;
	
//2026.05.25.132006
	i_pxFlag_Cut_end_Uw_UseInOtherPrg: POINTER TO BOOL;
	i_pxFlag_Cut_ing_Uw_UseInOtherPrg: POINTER TO BOOL;
		
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
	o_rStep:REAL;
	o_rPi_Value:REAL;	
	o_rTotalPiValue:REAL;(*总的pi控制量*)		
	o_xSts_PreCutting: BOOL;(*预备接料状态*)
	o_rDiam_NewVol:REAL;(*测量的新卷径*)
//	o_rVel_Predrv:REAL;(*预驱速度*)
	o_rVelRPM_Cur:REAL;(*当前转速*)
	o_xUwVolDiamMeasurementFailed: BOOL;(*放料卷径测量失败标志*)
	o_rRemainDia_Cur: REAL;
END_VAR
VAR_IN_OUT
	io_xCutOnTop:BOOL;(*TRUE 上裁刀|FALSE 下裁刀*)
//	io_wUwRwAxisProf:WORD;(*TRUE AxisA|FALSE AxisB*)
	io_rDiamCurAxis:REAL;(*当前轴的卷径*)
	io_byKalmanFilterType: BYTE;
	io_byStructParanInitEn: BYTE;
	
	//2026.5.15.094818
	io_alrStdVol_Diam_Axis_Hmi	: ARRAY [1..4] OF LREAL;(* 标准卷径值| *)
	io_alrStdVol_Volt_Axis_Hmi	: ARRAY [1..4] OF LREAL;(* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
	io_alrStdVol_Coef_Axis_Hmi	: ARRAY [0..4] OF LREAL;(* 分段系数|2019.1.25.142601|更名A轴|[0]表<=1,[1]表>1&& <=2,[2]表>2&& <=3,[3]表>3&& <=4,[4]表>4 *)
	
	//2026.05.20.212706+ by liu.yt
	io_astStTimeSet_DnCut_UpCut: ARRAY [0..1] OF StTimeSet_DnCut_UpCut;
	io_stStTimeSet_DnCut_UpCut_Hmi: StTimeSet_DnCut_UpCut;
END_VAR
VAR
(*输入相关*)
	uiNum_In									: UINT;
	uiDen_In									: UINT;
	rRatedRpm_In								: REAL;
	rRatedFreq_In								: REAL;
	rUpperFreq_In								: REAL;
	rPseudoRandomRoundAmplitude_Cur_In			: REAL;(*伪随机序列*)
	xFlag_AxisABParaFroDiaMea_In				: BOOL;(*放料自动卷径分轴标志*)
	xDiamMeasureAutomatic_In					: BOOL;
	dwAbsEncSinglePos_In						: DWORD;(*单圈位置*)
	xEn_DualParam_AbsEncLocation_In				: BOOL;
	rDia_PaperRoller_In							: REAL;(*纸筒直径*)
	xCancelTenEn_In								: BOOL;(*取消张力使能*)
	iInitial_speed_In							: INT;(*拉料初始速度*)
	iStiffenCoff_UwRw_In						: INT;(*拉料系数*)
	xRollerSts_IfOf_In								: BOOL;(*收放牵压辊状态*)
	rAI_IfOf_In									: REAL;(*收放牵摆臂输入*)
	xUseAntiNotch_In							: BOOL;(*陷波器使能开关*)
	rWn_In										: REAL;(*陷波中心频率*)
	rBw_In										: REAL;(*陷波宽度*)
	rDp_In										: REAL;(*陷波深度*)
	xPseudoRandomEn_In							: BOOL;(*伪随机测试按钮*)
	byPseudoRandomId_In							: BYTE;(*放料伪随机使能*)
	arK_pid_In									: ARRAY [1..3] OF REAL;(*设定PID值*)
	aiTestKp_In									: ARRAY [1..3] OF INT;(*伪随机P值*)
	aiTestKd_In									: ARRAY [1..3] OF INT;(*伪随机D值*)
	xCutDneResetPidEn_In						: BOOL;(*裁切后PID放大*)
	piCutDneResetPidMultiple_In					: POINTER TO INT;(*PID放大倍数*)
	iCutDneResetPidRemainTime_In				: INT;(*保持时间*)
	iCutDneResetPidToDefaultTime_In				: INT;(*恢复时间*)
	xSmallDiaMulEn_In							: BOOL;(*小卷补偿功能使能*)
	iSmallDiaMulSa_In							: INT;(*小卷补偿起始直径*)
	iSmallDiaMulEd_In							: INT;(*小卷补偿结束直径*)
	iSmallDiaMulSa_Coeff_In						: INT;(*小卷补偿起始系数*)
	iSmallDiaMulEd_Coeff_In						: INT;(*小卷补偿结束系数*)
	xPseudoRandomTsting_In						: BOOL;(*伪随机使能*)
	uiPiDelayWhenCut_In							: UINT;(*放料裁切PI投入时间*)
	rFilmThickNess_In							: REAL;(*料膜厚度*)
	xAutomaticCutEn_In							: BOOL;(*自动接料使能*)
	xFlag_CancelSafetyGrating_In				: BOOL;(*光栅保护取消*)
	byAutoMaticCutMode_In						: BYTE;(*自动接料模式选择*)
	rGirth_AxisA_In								: REAL;(*设定周长A*)
	rGirth_AxisB_In								: REAL;(*设定周长B*)
	xIsDebug_DiaMeasure_In						: BOOL;(*卷径标定调试开关*)
//	xAxisDebug_Spd_In							: BOOL;(*速度调试开关*)
	xPreCutOneBtn_In							: BOOL;(*接料-解除用一个按钮标志*)
	xFlag_SafeTyGratingProctec_In				: BOOL;(*光栅保护触发*)
	xUseAbsEncoder_In							: BOOL;(*翻转架使用绝对值编码器定位方式&自动卷径*)
	byDiamMeasureTypeId_In						: BYTE; (*=1 电位器 =2 编码器 =3 超声波I(ndependent) =4超声波S(hare) *)	
	uiPreStopDelayTime_ms_In					: UINT;(*预驱停止延迟时间@100ms*)
	iTime_PreDrvAcc_In							: INT;(*预驱加速时间*)
	iTime_PreDrvDec_In							: INT;(*预驱减速时间*)
	xFlag_CCW_AfterCutted_In					: BOOL;(*裁切完反转标志*)
	iPreRevLenth_MM_Cutted_In					: INT;(*反转距离*)
	iPreRevVel_RPM_Cutted_In					: INT;(*反转速度*)
	iDebugGirthmm_AxisA_In						: INT;
	iDebugGirthmm_AxisB_In						: INT;
	rCoefCut_FilmVolPerimeter_In				: REAL;
	dwAbsEnCodeResolution_In					: DWORD;(*绝对值编码器线数*)
	xUseRadCompensate_In						: BOOL;(*放料翻转架补偿开关*)
	xTowerDir_In								: BOOL;(*翻转架和绝对位置方向控制|*)
	rDiam_DeflectorRollPos_In					: REAL;(*翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	rDiam_DeflectorRoller_In					: REAL;(*翻料架上导向辊的直径|mm*)
	xFlag_RollerPressAtLeast1_In				: BOOL;
	xUseFollow_1U_V_UwCut_In					: BOOL;(* THEN(*使用裁切时候跟踪第一色方法*)	*)
	uiMaxDia_In									: UINT;
	uiInitDiam_In								: UINT;
	xTypeGetInitDiam_In							: BOOL;
	rWc_LowPass_Diam_In							: REAL;
	xGetFilmThickNessAuto_In					: BOOL;(*自动获取标志*)
	rDiamAlarm_In								: REAL;(*放料报警卷径*)
	byAlarmType_NoMaterial_In					: BYTE;(*没料报警方式@=0 放料没料3S响铃报警
													@=1 放料没料时候一直报警-直到按下正转\反转\接料准备*)
	xUseFeedVel_In								: BOOL;
	rVel_Feed_In								: REAL;(*牵引速度-放料放牵收料收牵*)	
	xFilmAccDecDone_In							: BOOL;(*料膜加减速完成*)
	xDiaEstEn_In								: BOOL;(*卷径估计使能开关*)
	xFlag_RollerPressDne_In						: BOOL;	(*色组压辊合压完成*)
	xUseDiam_LowPass_In							: BOOL;(*使用低通的卷径值*)
	xTensionCompensateEn_In						: BOOL;(*张力补偿开关*)	 
	xTensionCompensateEn_Cut_In					: BOOL;(*裁切张力补偿开关*)	
	xUseIMatrix_rX_DARE_In						: BOOL;(*使用单位矩阵*)
	xUseTime_Variaition_In						: BOOL;(*使用时变参数标志*)
	xUseTime_b1_In								: BOOL;(*默认时时变的,有效则b1随卷径实时变化-不实时变化则使用b1_0@2024.05.14.080937*)
	byAlarmHold_PreCut_In						: BYTE;(*预备接料响铃时间*)
	uiAutoMaticCutMeters_In						: UINT;(*剩余米数*)
	uiAutoMaticCutDia_In						: UINT;(*剩余卷径*)
	xCutUseReflectionSensor_In						: BOOL;(*放料使用弧面检测*)
	rN_In										: REAL;
	rMpa_In										: REAL;
	rVel_Inch_In								: real;//单运行速度输入2026.5.27.100543
	
	
	rAxisAFreq_Out								: REAL;
	rAxisBFreq_Out								: REAL;
	rAxisAVolByVel_Out:REAL;(*A轴输出电压值*)
	rAxisBVolByVel_Out:REAL;(*B轴输出电压值*)
	rAxisAVel_RPM_Out:REAL;(*A轴转速值*)
	rAxisBVel_RPM_Out:REAL;(*B轴转速值*)	
	xWillAutoMaticPreCut_Out					: bool;
	rAutoMaticCuttingLenth_CurMode_Out			: REAL;(*自动裁切当前模式的计米值*)
	xFlag_AutoMaticCutting_Out					: BOOL;
	arKpid_Use_Out								: ARRAY [1..3] OF REAL;(*当前使用PID*)
	xAllowSwitchCutter_Out						: BOOL;
	xNeedAlarmBell_Out							: BOOL;(**)
	xPrevNeedAlarmBell_Out						: BOOL;(*警铃输出@备份值,赋值的对象会在别的任务里操作故做此处理 by liu.yt*)

	xAxisALocation_Use_Out						: BOOL;
	xAxisBLocation_Use_Out						: BOOL;
	xFlag_DiamMeasure_end_Out					: BOOL;
	rVel_Predrv_Out								: REAL;(*预驱速度输出*)
	xFlag_PreDrv_ing_Out						: BOOL;(**)
	xFlag_PreDrv_end_Out						: BOOL;
	xPreDrvAxis_Releasing_Out					: BOOL;
	//xFlag_Cut_ing_Out							: BOOL;

	xFlag_Cut_end_Out							: BOOL;
	xReflectionSensorValid_Out					: BOOL;
	xReflectSensorLoss_Out						: BOOL;(*弧面信号丢失*)
	xAxisATorqueCancel_Out						: BOOL;
	xAxisBTorqueCancel_Out						: BOOL;
	rDeltaW_RPMIN_Out							: REAL;(*放料翻转架转动时候的转速补偿值*)
	rTowerThetaCur_Out							: REAL;(*翻转架当前弧度*)	
	rFilmToTowerRollerDis_Out					: REAL;(*料膜距离导向辊距离*)
	xFilmTouchRoller_Out						: BOOL;(*料膜接触到了棍子标志*)
	xFlag_VolDiamAlarm_Out						: BOOL;
	stTime_Varying_Parameters_Output			: Time_Varying_Parameters;	
	rWuCompensate_Out							: REAL;(*补偿的转速-计算值*)
	rWuCompensate_Act_Out						: REAL;(*补偿的转速-应用值*)
	xFlag_TensionDone_Out						: BOOL;(*拉料完成*)
	rVolt_CalcDiam_Used_Watch_Out				: REAL;

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
	
	axMeasure_StdVol_In_Out						: ARRAY [1..4] OF BOOL;
	rActRemainFilmLenth_In_Out					: REAL;(*实际剩余长度mm*)
	bySetTestPid_In_Out							: BYTE;(*伪随机步骤*)
	xCurAxisDia_Wr_In_Out						: BOOL;(*界面周长设定写入按钮*)
	xCutAxisA_In_Out							: BOOL;(*当前轴*)
	rEstiDia_In_Out								: REAL;(*预估卷径值*)
	xSwitch_IsUpCut_HMI_In_Out					: BOOL;(*界面切换上下裁开关*)
	byEncodeValueWr_In_Out						: BYTE;(*编码器值写入|放料:
															 01 写入轴定位值
															 02 写入A轴最小径定位值*)
	xCutterOnTopFroDebug_In_Out				: BOOL;(*放料上裁标志-调试*)
	xCurAxisAFroDebug_In_Out						: BOOL;(*放料预驱轴A轴-调试*)
	xDebug_Enc_In_Out_UwRw							: BOOL;(*绝对值编码器调试开关*)
	adwAxisALocation_In_Out						: ARRAY [0..1] OF DWORD;
	adwAxisBLocation_In_Out						: ARRAY [0..1] OF DWORD;
	adwAxisALocation_MinDia_In_Out				: ARRAY [0..1] OF DWORD;
	adwAxisBLocation_MinDia_In_Out				: ARRAY [0..1] OF DWORD;
	rAi_DiamMeasure_In_Out						: REAL;
	xEnCodeFailed_In_Out						: BOOL;			
	xFlag_DiamCalc_end_In_Out					: BOOL;(*卷径计算完成标志*)
	xFlag_DiamCalc_ing_In_Out					: BOOL;(*卷径计算中标志*)
	xIsDebug_DiaMeasure_In_Out					: BOOL;
	xIsDebuging_DiaMeasure_In_Out				: BOOL;(*放料卷径测量调试中*)
	xCancelDebuging_DiaMeasure_In_Out			: BOOL;(*放料卷径测量调试条件*)
	byIsDebug_DiaMeasureArea_In_Out				: BYTE;
	astStStdVolParam_DnCut_UpCut_In_Out			: ARRAY [0..1] OF StStdVolParam_DnCut_UpCut;
// 	wAxisDebug_UwRw_In_Out						: WORD;(**)(*轴调试标志|.0\放料调试使能.1\放料A轴调试运行.2\放料A轴自动加减速.3\放料A轴运行中.4\放料B轴调试运行.5\放料B轴自动加减速.6\放料B轴运行中
// 													.8\收料调试使能.9\收料A轴调试运行.10\收料A轴自动加减速.11\收料A轴运行中.12\收料B轴调试运行.13\收料B轴自动加减速.14\收料B轴运行中*)						 
	
	rDebugCurVelmpmAxisA_In_Out					: REAL;
	rDebugCurVelmpmAxisB_In_Out					: REAL;
	rDebugCurVelrpmAxisA_In_Out					: REAL;	
	rDebugCurVelrpmAxisB_In_Out					: REAL;								  

//	xFlag_Cut_end_UseInOtherPrg_In_Out			: BOOL;(*使用在别的Prg中的放料裁切完成标志|在自己的prg中清除*)								  
	(*翻转架补偿相关参数*)
	rDiam_Tower_In_Out							: REAL;
	rDiam_NextRoller_In_Out						: REAL;
	rXPos_NextRoller_In_Out						: REAL;
	rYPos_NextRoller_In_Out 					: REAL;		
	dwEncodePos_In_Out							: DWORD;
	//2026.05.20.204917+ 替换为指针操作@该值的写入值是在通讯任务获取，会存在时序问题导致在执行action_IN后获取到标志|
	xConfirmRad0_In_Out							: BOOL;(*0弧度确认*)
	dwAxisAAbsPos_0Rad_In_Out					: DWORD;(*A轴0弧度位置*)
	dwAxisBAbsPos_0Rad_In_Out					: DWORD;(*B轴0弧度位置*)
	xFlag_Follow_1U_V_UwCut_In_Out				: BOOL;(*裁切时跟踪第一色标志*)
	byMeters_UseFollow_1U_V_UwCut_In_Out		: BYTE;
	rEstiThickness_In_Out						: REAL;
	rFilmThickNess_Using_In_Out					: REAL;(*使用的料膜厚度*)
	xKeepAlarm_NoMaterial_In_Out				: BOOL;(*长报警标志复位*)
	byVelSa_DiamCompensate_In_Out				: BYTE;(*补偿起始速度*)
	byDelayTime_DiaCompensateWhenCutDne_In_Out	: BYTE;(*裁切后卷径补偿之后时间|s*)
	rKc_In_Out									: REAL;
	rKc_AccDec_In_Out							: REAL;
	uiUseTime_Diam_Min_In_Out					: UINT;
	rR_K_LQR_In_Out								: REAL;
	rN_LQR_In_Out								: REAL;
	rR_K_MinBeat_In_Out							: REAL;
	iN_MinBeat_In_Out							: INT;
	stModelParam_In_Out							: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)
	stInvariant_Parameters_In_Out				: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)
	stPI_Parameters_In_Out						: PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)							  
	stPI_Parameters_AccDec_In_Out				: PI_Parameters;(*控制器pi参数@20bytes|用于加减速*)						  
//	xFlag_Cut_end_Uw_UseInOtherPrg_In_Out		: BOOL;						  
//	xFlag_Cut_ing_Uw_UseInOtherPrg_In_Out		: BOOL;
	
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
	
	rDiameterTmp: REAL;(*原功能快计算获得的卷径值*)
	xDiamWr_Manu: BOOL;(*卷径手动写入@不需要使用低通*)
	rAI_Uw_TensionCtl: REAL;
	rAntiNotch_Out_Uw: REAL;
	arAntiNotchU_Uk_Uw: ARRAY [1..3] OF REAL;
	arAntiNotchU_Yk_Uw: ARRAY [1..3] OF REAL;
	rSpliceCompensate: REAL;
	rMainVel: REAL;
	xOpenAutomaticCutEnTips: BOOL;
	byForeward_mtf: BYTE; (*翻料架正转|Material Tumbling Frame|2017-08-17 09:41:38*)
	byReversal_mtf: BYTE; (*翻料架反转*)	
	xSts_Sensor1Ok: BOOL:= FALSE;(*对射电影标志*)
	xAccDecingCompensateEn: BOOL;
	rFilmThickNess: REAL;
	byNeedAutomaticCut_UwRw:BYTE;(*2024.02.23.100940 需要自动裁切设置标志@需要清零
															@=1放料设置 
															@=2收料设置 
															@=10设置确认 =11设置取消*)
															
	xCutHolderCanDebug: BOOL;(*放料调试控制大臂上升下降标志-调试模式单击接料按钮*)
	xCutHolderDn_Debug: BOOL;(*放料大臂调试情况下合压了|用于控制抬起逻辑沿触发*)		
	iCnt_Cuttrig: INT;(*接料按钮按下计数*)			
	tTime_CutTrig: TIME;(*获取按下接料按钮时间*)	
	xSts_ArmFalling: BOOL;(*大臂下落中*)
	xSts_ArmFall_end: BOOL;(*大臂落下标志*)
	xBtn_AxisLocationManu: BOOL;(*编码器故障时，手动按钮定位标志*)						
	xAxisAMinimumDiamLocationByAbsEnc: BOOL;(*通过绝对值编码器确定的A轴最小径*)
	xAxisBMinimumDiamLocationByAbsEnc: BOOL;(*通过绝对值编码器确定的B轴最小径*)
	xAxisALocationByAbsEnc: BOOL;(*通过绝对值编码器确定的A轴定位*)
	xAxisBLocationByAbsEnc: BOOL;(*放料通过绝对值编码器确定的B轴定位*)
	xAxisLocationInvalid: BOOL;(*轴定位无效*)
	xAxisLocation_MinDiaInvalid: BOOL;(*轴最小径无效*)
	xAxisLocationWrDne: BOOL;(*轴定位写入成功*)
	xAxisLocation_MinDiaWrDne: BOOL;(*轴最小径写入成功*)
	tTime_AlarmForAxisLocation: TIME:=T#1S;(*轴定位写入完成响铃时间*)
	tTime_AlarmForAxisLocation_MinDia: TIME:=T#3S;(*轴最小径定位写入完成响铃时间*)
	tTime_Alarm: TIME;(*响铃时间*)
	tTime_AlarmSa: TIME;(*响铃开始时间*)	
	xAxisALocation_Use: BOOL;(*A轴最终定位*)
	xAxisBLocation_Use: BOOL;(*B轴最终定位*)
	xMinimumDiamLocation_Use: BOOL;(*最小径最终定位*)
	xSts_Limited_AxisLocaltion:BOOL;(*在轴限位位置*)
	xCutHolder_InPosition: BOOL;(*大臂就wei*)
	dwCycleDelayCountdown: DWORD;
	xFlag_Measuring: BOOL;(*卷径测量标志*)
	xSts_WaitingCut: BOOL;(*等待裁切标志*)
	xMiniumuDiamProtect: BOOL;(*最小径保护标志*)
	xFlag_Measured: BOOL;(*卷径测量完成*)
	xIsDebug_DiaMeasure: BOOL;
	xLamp_DiaMeasureArea: BOOL;
	xNeedStopTowerForUwMeasure: BOOL;
	xUwVolDiamMeasureEn: BOOL;(*卷径测量使能*)
	iTimeCnt_StopTower: INT;
	xEn_UwVolDiamMeasurement: BOOL;
	xDiaMeaParamErr: BOOL;
//	xTell_KS_PreDrv_CTL_Uw_CuttDne: BOOL;
	(*2026.5.7.160108交互信号*)
	xTell_KS_PreDrv_CTL_Uw_CuttDne_In: BOOL;

	xPreDelayEn: BOOL;
	xSensor_Reflex: BOOL;
	xCutCtlEn: BOOL;
	rDiam_NewVol_Use: REAL;
	rVel_Predrv_Use: REAL;
	xLamp_PreDrive_Debug: BOOL;
	xOutput_CutCylinder: BOOL;
	iCutTotalTime: INT;
	xTorqueCancel: BOOL;
	iTimeCnt: INT;
	xNeedTorqueCancel: BOOL;
	xInverterCW: BOOL;
	xInch: BOOL;
	xRevInch: BOOL;
	dwTowerPos_Cur: DWORD;
	xFilmToBig: BOOL:=FALSE;(*存在整机反转的情况|该标志控制放料是变大还是变小*)
	xCalcEstValueEn: BOOL;	
	rVel_CalcVolt: REAL;(*计算放料电压的放料速度|放料增加扰动补偿，防止意外飞车*)
	uiTime_UseFollow_1U_V_UwCut: UINT;
	rWc_LowPass: REAL;
	xDiamRegInit_Lp: BOOL;
	(*放料卷径低通*)
	arUk_LowPass: ARRAY [1..2] OF REAL;
	arYk_LowPass: ARRAY [1..2] OF REAL;
	rEstiDia_LowPass: REAL;
	xGetFilmThicknessEn: BOOL;(*自动获取条件满足了*)
	xThicknessAutoGetDne: BOOL;(*自动获取成功了*)
	xDiaEstEn: BOOL;(*卷径估计功能使能*)
	rTotalThickness: REAL;(*条件满足后的累计厚度值@单位mm-用于计算平均厚度值*)
	udiTotalNum: UDINT;(*条件满足后的累计次数值@单位mm-用于计算平均厚度值*)
	rThickness_Max: REAL;(*计算时间内的厚度最大值*)
	rThickness_Min: REAL;(*计算时间内的厚度最小值*)
	tLastTime_AutoGetThikcness: TIME;(*时间备份*)
	xInitDiameter: BOOL :=TRUE;
	rLastDia_Cur: REAL;(*上个周期的当前卷径*)
	xEnFlag_CalcDiam_Ret: BOOL;
	rNull: REAL;
	rVelTmp: REAL;
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
	xFlag_Type4AndDiamMeasure_end: BOOL;
	xInit_Taper_Cur: BOOL;
	iTimeTaperChange:INT:=10000;(*锥度变化时间|ms*)
	rTaperTar: REAL;
	rTaperCur: REAL;
	rDeltTaper: REAL;
	
	fbAlarmHoldTon_PreCut: TON;
	fbTonFLick_Lamp_preDrive: TON;
	afbTRIG_UwRw_Input: ARRAY [1..30] OF R_TRIG;	
	fbKS_FB_EstimationByVel: KS_FB_EstimationByVel;
	fbTon_UseFollow_1U_UwCut: TON;
	fbKS_FB_TowerRadCompensate: KS_FB_TowerRadCompensate;
	fbRTrig_Sts_Precuting: R_TRIG;
	fbTon_DelayTimer_CutOffKnifeCylinder_Uw: TON;
	fbPreDelayEnTon_Uw:TON;
	fbKS_FB_PreDrv_Ctl:KS_FB_PreDrv_CTL_REV;
	fbKS_FB_AxisDebug: KS_FB_AxisDebug;
	fbTon_ArmFalling: TON;
	fbRTrig_AxisALimit :R_TRIG;
	fbRTrig_AxisBLimit :R_TRIG;
	fbRTrig_Sensor1: R_TRIG;
	fbRTrig_PreCut: R_TRIG;(*预备接料触发*)
	fbRTrig_Cut: R_TRIG;(*接料触发*)
	fbRTrig_CancelCut: R_TRIG;		(*接料解除触发*)								
	fbLampFlick_SafeTyGrating: TON;														
	afbDebug_UwRw: ARRAY [1..3] OF R_TRIG;
	fbKS_FB_Exchange: KS_FB_Exchange;
	fbKS_FB_GetKpid: KS_FB_GetKpid;
	fbKS_FB_UwRw_TensionCTL: KS_FB_UwRw_TensionCTL;
	fbKS_FB_UwRw_Tension_2024: KS_FB_UwRw_Tension_2024;
	fbKS_FB_VelocityToVoltage: KS_FB_VelocityToVoltage;
	fbKS_FB_AutoMaticCut_Uw: KS_FB_AutoMaticCut_Uw;
	fbKS_FB_AbsEncForTower: KS_FB_AbsEncForTower_Uw;
	fbKS_FB_DiaMeasure_Debug: KS_FB_DiaMeasure_Debug;
	fbKS_FB_UwVolDiamMeasurement: KS_FB_UwVolDiamMeasurement;
//	fbKS_FB_CutDelay_CTL_Uw: KS_FB_CutDelay_CTL_Uw;
	fbKS_FB_CalcDiamOfFilmVol: KS_FB_CalcDiamOfFilmVol;
	fbKS_FB_KeepAlarm_NoMaterial: KS_FB_KeepAlarm_NoMaterial;
//	fbKS_FB_Func_Stiffen: KS_FB_Func_Stiffen;
	fbKS_FB_TaperUnitDeal: KS_FB_TaperUnitDeal_New;
	
	
//2026.5.14.171244增加卷径检测相关内容
	alrLastStdVol_Volt_AxisA	: ARRAY [1..4] OF LREAL;(* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
	alrLastStdVol_Volt_AxisB	: ARRAY [1..4] OF LREAL;(* 标准卷径对应的电压值|2019.1.25.142524|新增B轴 *)
	pstStStdVolParam_DnCut_UpCut_HMI:POINTER TO StStdVolParam_DnCut_UpCut;(*当前裁刀标准卷径参数地址*)	
//2026.5.15.092014	xParaInit:BOOL:=TRUE;(*参数初始化标志*)
	xParaInit:BOOL:=TRUE;(*参数初始化标志*)
	xLastCutOnTop:BOOL;(*上个周期上下裁刀标志*)
	xLastCurAxisA: BOOL;(*上个周期当前轴biaozhi*)		
	
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
		i_pstStIOMap_Uw<>0 AND
		i_pstStSysParam<>0  AND
		i_pxReq_Cut_Uw<>0 THEN
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
			3.Action_CutCtl_AbsEncForTower()放料绝对值编码器处理
			4.Action_CutCtl_CutHolderCtl()-大臂控制
			5.Action_CutCtl_TowerCtl()-翻转架控制
			6.Action_CutCtl_PreCut()-预备接料-接料取消处理
			7.Action_CutCtl_Diameasure()卷径检测
			8.Action_CutCtl_PreDrv()-预驱控制
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
		Action_LampIODeal();(*部分指示灯逻辑*)
(*-------------------------------------处理所有动作----end----------------------------------------*)		
		
(*输出这里处理吧*)		
		Action_Output();
		
	ELSE;
	END_IF
ELSE
	;
END_IF