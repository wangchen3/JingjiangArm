(*@CES
Name=GVL
Type=ConstantList
TypeGuid=ffbfa93a-b94d-45fc-a329-229860183b1d
Guid=8a98e878-1566-4378-b3a1-83639989e28b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
VAR_GLOBAL
	g_xRunNormalTask			: BOOL:= FALSE;
	g_iRunStepId				: INT := RUNSTEP_STARTUP;(* 2023.8.3.095049/han.dp *)
	g_xFlag_LogTaskRun			: BOOL;(*文件保存模块运行标志*)
	g_xFlag_OtherTaskRun		: BOOL;(*其他任务*)
	g_xFlag_WriteParamFile		: BOOL;
(*deprecated@2025.8.27.164639/han.dp
	g_stStTravelLogRec: StTravelLogRec;(* 运行日志 *)
*)
	g_stStSts_To_Diamonds_HMI: StParam_Diamonds_Wr;	
	g_stStSysParam				: StSysParam;

	(* 2025.8.27.154412/han.dp/合并功能 *)	
	g_pstStHYLogFifo			: POINTER TO StHYLogFifo := 0;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
	g_dwMem1MB					: DWORD := 0;(* 2025.8.21.181040/程序进入任务前申请的1M内存 *)
	g_diErrCode_FileProc		: DINT := 0;(* 2025.8.21.181514/文件操作错误代码 *)
	g_pstStUdpOnlySendFifo		: POINTER TO StUdpOnlySendFifo := 0;

(*deprecated@2025.8.27.154430/han.dp
	g_stStSysParam_SaveParam				: StSysParam_SaveParam;
*)
	
	g_astStAxisRapidAdjProf_V	: ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_V;
	g_astStAxisRapidAdjProf_H	: ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;
	g_astStEvtReq				: ARRAY [1..2] OF StEvtReq	;
	g_axCommVel_Sure: ARRAY [1..2,1..3] OF BOOL;(*2019.10.21.095108|常用速度123按钮*)	
	g_adiVel_Virtual_Tar: ARRAY [1..2] OF DINT;
	g_alrMax_a_S_pos: ARRAY [1..2] OF LREAL;
	g_alrTime_S: ARRAY [1..2] OF LREAL;
	g_alrJerk_SBegin: ARRAY [1..2] OF LREAL;
	g_alrJerk_SEnd: ARRAY [1..2] OF LREAL;
	g_axMotionEnabled:ARRAY [1..2] OF BOOL;	
	g_axis_ctl: INT;
	wTestButton_Input: WORD;
	wTestButton_Output: WORD;
	g_astStIOMap_Main_FE					: ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	g_astStIOMap_Axis_FE					: ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	g_astStIOMap_Axis_Extra_FE				: ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;
	g_astStIOMap_UwRw_FE_Uw					: ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|AB系*)
	g_astStIOMap_UwRw_FE_Rw					: ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|AB系*)
	
//	g_stStRingInfVer1			: StRingInfVer1;	
	g_astStSetPrm				: ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	g_stStGetPrm				: TMultiMcFunctionReadPrm;
	//g_alrVarValue				: ARRAY [1..200] OF LREAL;
	g_astMotionSts 				: ARRAY[1..MAX_STATION_NUM] OF MotionSts;

	g_abyStationList_CommHMI	: ARRAY [1..MAX_STATION_NUM] OF BYTE;
//	g_abyStationList_CommKSCR	: ARRAY [1..MAX_STATION_NUM] OF BYTE;
	
	(*2025.6.25.211256测试电机运动，完全照搬*)
	g_xStart: BOOL;
	g_mBtn_Init: BOOL;
	g_mBtn_Clr:BOOL:=FALSE;
	g_mBtn_ZeroPos:BOOL:=FALSE;
	g_mBtn_SetMode:BOOL:=FALSE;
	g_mBtn_Start:BOOL:=FALSE;
	g_mBtn_ServerCtl:BOOL:=FALSE;
	g_mBtn_Stop:BOOL:=FALSE;
// 	g_axisId:ARRAY [1..20] OF INT;
	
// 	g_iAxisId:ARRAY [1..96] OF INT;
// 	g_iServerCtl:BYTE:=0;
// 	core: INT:=1;
// 	g_axisCount:INT:=3;
// 	g_varValue:ARRAY [1..200] OF LREAL;
// 	g_rVel_Cur_HMI_Test:REAL;
	
	
	//新增运动相关全局定义|2025.08.05.094744
	//Trap
// 	g_alrTarPos_Horz : ARRAY[1..MAX_UNIT_NUM] OF LREAL := [MAX_UNIT_NUM(1000)];			//um
// 	g_lrMaxVel_Horz : LREAL := 0.2;		//um/ms、mm/s
// 	g_alrTarPos_PhotoCell : ARRAY[1..MAX_UNIT_NUM] OF LREAL := [MAX_UNIT_NUM(10)];			//mm
// 	g_lrMaxVel_PhotoCell : LREAL := 5;
	//Gantry
// 	g_target_pos : LINT := 4194304;
// 	g_max_vel : DINT := 100;
// 	g_diMain : DINT := 0;
// 	g_diSecond : DINT := 0;
	//运动相关
// 	g_astTStTrapParamUser 			: ARRAY[1..MAX_STATION_NUM] OF TStTrapParamUser;
// 	g_astTStJogParamUser 			: ARRAY[1..MAX_STATION_NUM] OF TStJogParamUser;
// 	g_astTStGearParamUser 			: ARRAY[1..MAX_STATION_NUM] OF TStGearParamUser;	
// 	g_astTStGantrayTrapParamUser 	: ARRAY[1..MAX_STATION_NUM] OF TStGantrayTrapParamUser;
	
	g_iAxisNum_Trap					: INT;(*点位运动轴数量*)
	g_aiStationList_Trap			: ARRAY [1..MAX_STATION_NUM] OF INT;(*点位运动轴列表*)
	g_iAxisNum_Gear					: INT;(*电子齿轮运动轴数量*)
	g_aiStationList_Gear			: ARRAY [1..MAX_STATION_NUM] OF INT;(*电子齿轮运动轴列表*)
	g_iAxisNum_GantrayTrap			: INT;(*龙门点位运动组数量*)
	g_aiStationList_GantrayTrap		: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)
	g_iAxisNum_Jog					: INT;(*龙门点位运动组数量*)
	g_aiStationList_Jog				: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)		
	g_iAxisNum_All					: INT;
	g_aiStationList_All				: ARRAY [1..MAX_STATION_NUM] OF INT; 
	g_aiIndexList_All_Trap			: ARRAY [1..MAX_STATION_NUM] OF INT;(*点位运动轴列表*)
	g_aiIndexList_All_Gear			: ARRAY [1..MAX_STATION_NUM] OF INT;(*电子齿轮运动轴列表*)
	g_aiIndexList_All_Gantray		: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)	
	g_aiIndexList_All_Jog			: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)
	
	g_arVel_PrnRoller		: ARRAY[1..2] OF REAL;(* 版辊运行速度*)
	g_arVel_NetRoller		: ARRAY[1..2] of REAL;(* 网辊运行速度*)
	g_arVel_BottomRoller	: ARRAY[1..2] OF REAL;(* 底辊运行速度*)
	
	g_xFlag_Stop_En_Servo : BOOL;	
	
// 	g_axEn_Motor_Gear : ARRAY [1..2] OF  BOOL;
// 	g_axEn_Motor_Trap :  ARRAY [1..2] OF BOOL;
// 	g_axEn_Motor_Gantry :  ARRAY [1..2] OF BOOL;

	//2025.08.05.094751 | 测试 | 运动控制流程
	g_xInk : BOOL;
	g_xTension : BOOL;
	g_xPrint : BOOL;
	g_xStop : BOOL;
	g_xEstop : BOOL;
	g_xStop_ServoOn:BOOL;
	g_xPreStart : BOOL;
	//g_max_acc:LREAL:=0.4;
	g_lrVel_tar: REAL:= 10;
	g_uiArcAdjValue_Max:UINT:=1000;(*套色调整最大值@1000um|临时做到全局*)	
	g_pstStTravelDataRec: POINTER TO StTravelDataRec := 0; (* 实时数据记录缓存 *)
	(*系统时间出错想办法先避免2023.09.12.103011*)
	g_stSysTimedate_Rec: RTS_SYSTIMEDATE;
	g_xInitTime: BOOL;
//	g_stStTravelLogRec: StTravelLogRec;(* 运行日志 *)
(*deprecated@2025.8.27.164745/han.dp
	g_pstStTravelLogRec: POINTER TO StTravelLogRec := 0;
*)
	g_stStTravelDataRec: StTravelDataRec;(* 实时数据记录缓存 *)
(*deprecated@2025.8.27.164827/han.dp
	g_astStTravelLogItem_view: ARRAY [1..GC_LOG_ITEM_MAX_NUM] OF StTravelLogItem;(* 2023.11.23.142330/han.dp/用于查看日志的列表/[1]永远是最新的一条记录 *)	
*)
	g_xFileClosed_BecauseEmergency: BOOL := FALSE;(* 由于紧急情况文件关闭的标志 *)
	g_xRst_fileProtect: BOOL := FALSE;
	g_sFilename_datfile: STRING := '';
	g_sFilename_logfile: STRING := '';
	g_iErNo_datfile: INT := 0;
	g_iErNo_logfile: INT := 0;	
	
	g_xSaveFineSampleData :BOOL;//精采样标志
	g_dwPlcLoad :DWORD ; // 	
	g_astAllAxisErrorTransfer: ARRAY [1..MAX_UNIT_NUM] OF StForArcErrRelay; (* 误差传递使用的队列 *)		
	g_pastAllAxisErrorTransfer: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StForArcErrRelay := 0; (* 误差传递使用的队列 *)	
	(*一些占空间比较大的变量|通过allloc获得内存*)
	g_pstStGlobalVarByAllocMem:POINTER TO StGlobalVarByAllocMem;
	g_apbyKp_Arc:ARRAY [1..MAX_UNIT_NUM] OF POINTER TO BYTE;(*套色Kp地址值*)
	g_apbyKi_Arc:ARRAY [1..MAX_UNIT_NUM] OF POINTER TO BYTE;(*套色Ki地址值*)
	g_apbyKd_Arc:ARRAY [1..MAX_UNIT_NUM] OF POINTER TO BYTE;(*套色Kd地址值*)
	g_astStRegAdjMana: ARRAY [1..MAX_UNIT_NUM] OF StRegAdjMana ; (* 套色调整量 *)
	
	g_astStTaskCycleDetection	: ARRAY [1..MAX_TSK_CYCLE_MONITORING] OF StTaskCycleDetection := [MAX_TSK_CYCLE_MONITORING((xRstDetection:= FALSE, udiCycleCnt:= 0, xCalcIntervalEnabled:= FALSE))];
	g_aiFunctionConsueTime : ARRAY [1..10] OF INT;
	g_iTime_Main_Task : INT;
	g_pstStDatasetARC: POINTER TO StDatasetARC := 0; (* 套色数据记录缓存 *)
//	g_xSaveFineSampleData_ToArc:BOOL;(*保存精采样数据-用于套色保存@通过执行GT_RN_MailWrMultReg函数发送数据到pc机(16#F2)*)
	g_abyActionCtlWay	: ARRAY [1..2] OF BYTE;
	(*新增横向参数-开始|wang.nt|2025.08.09.160741*)
	g_iStepDriveDebugNum: INT := 1; (* 步进电机计算单位脉冲对应的距离的色组号 *)
	g_xStepDriveDebugRun: BOOL; (* 步进电机测试启动 *)
	g_xStepDriveDebugResult_Wr: BOOL; (* 步进电机测试结果写入按钮 *)
	g_diStepDriveDebugPulse: DINT := 60000; (* 测试时输出的脉冲个数；以6000个脉冲一圈 我们默认输出10圈 *)
	g_lrStepDriveDebugPulse_PosAct: LREAL; (* 脉冲完成后位置的变化量 *)
	g_astStDigitalMicroStepDrive: ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
	(*横向重复总值*)
	g_abyBtn_HorzPreRegister_Repeat:ARRAY [1..2] OF BYTE;(*重复值的横向按钮@界面使用|=0 不运动|=1 按照轴距离运动|=2 整机按照单个值运动*)
	g_adiPreReg_RepeatVal_H:ARRAY [1..2] OF DINT;
	(*目标值*)
	g_abyBtn_HorzPreRegister_Setup:ARRAY [1..2] OF BYTE;(*目标值的横向按钮@界面使用|=0 不运动|=1 按照轴距离运动|=2 整机按照单个值运动*)
	g_adiPreReg_SetupVal_H:ARRAY [1..2] OF DINT;
	(*新增横向参数-结束|wang.nt|2025.08.09.160741*)

	g_xPressRollerDne_Of_WhenTensionIn:BOOL:=FALSE;(*张力投入时候收牵合压标志|有效表示在张力投入的时候收牵合压并且
											使用牵引使用变频器的时候输出收牵使能*)	
	g_xUnPressTop_AllUnPressBtn:BOOL;(*全体离压按钮按下时候方式标志|FALSE=按照延时离压|TRUE=离压到最高处*)	
	g_xClearUnPressFlag:BOOL:=FALSE;(*最高点清除离压信号@2023.09.21.141508同步*)
	g_axFlag_PressDne: ARRAY [1..MAX_UNIT_NUM] OF BOOL := [MAX_UNIT_NUM(FALSE)];		
	g_arDiamWuCompensate_Uw: ARRAY [1..2] OF REAL;			(*主要用于保存了*)			
	g_arDiamWuCompensate_Rw: ARRAY [1..2] OF REAL;			(*主要用于保存了*)					
	g_arEstiDia_LowPass_Uw: ARRAY [1..2] OF REAL;			(*主要用于保存了*)			
	g_arEstiDia_LowPass_Rw: ARRAY [1..2] OF REAL;			(*主要用于保存了*)			
	g_arAntiNotch_Out_Uw: ARRAY [1..2] OF REAL;			(*主要用于保存了*)				
	g_arAntiNotch_Out_If: ARRAY [1..2] OF REAL;			(*主要用于保存了*)			

	g_astStProgMonitoring						: ARRAY [1..2] OF StProgMonitoring;
	(*新增变量-开始|wang.nt|2025.08.12.162001*)
	g_axKeepAlarm_NoMaterial: ARRAY [1..2] OF BOOL;(*没料持续报警*)
	g_axAlarm_AccOrDecing:ARRAY [1..2] OF BOOL;
	g_axAlarm_CutFinish_Uw:ARRAY [1..2] OF BOOL;
	g_axAlarm_CutFinish_Rw:ARRAY [1..2] OF BOOL;
	g_axAlarm_VolDiamAlarm_Uw:ARRAY [1..2] OF BOOL;
	g_xAlarm_CutDne_Uw: BOOL:=FALSE;(*放料裁切后输出报警标志@时间由界面设置*)
	g_xAtleastOneUnitOverTemp:BOOL;(*至少一色过温标志|用于显示*)
	g_axAxisInchDecing: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单运行减速中*)
	(*新增变量-结束|wang.nt|2025.08.12.162001*)
	g_dwNormalWorkRunNum: DWORD;
	g_dwTensionRunNum: DWORD;
	
	g_iAxisOffCnt_If_OK : INT;
	g_iAxisOffCnt_If_Err : INT;
	(*新增变量-结束|wang.nt|2025.08.12.162001*)
	g_pbyRoundData1: POINTER TO BYTE; (* 存储采样数据T1的波形首地址 *)
	g_pbyRoundData2: POINTER TO BYTE; (* 存储采样数据T2的波形首地址 *)
	
	(*新增变量-开始|wang.nt|2025.08.13.134901*)
(*deprecated@2025.8.27.165000/han.dp
	g_pstStAlarmLogForView		: POINTER TO StAlarmLogForView := 0;(* 用于存放报警列表内容的 *)
	g_pastStAlarmItemForView	: POINTER TO ARRAY [1..MAX_ALARMITEM_NUM] OF StAlarmItemForView := 0;(* 指向报警显示列表的 *)
*)
	g_abyiNFeedLimitWarnFlag: ARRAY [1..2] OF BYTE;
	g_abyOutFeedLimitWarnFlag: ARRAY [1..2] OF BYTE;
	g_axAlarmHeating:ARRAY [1..2] OF BOOL;(*加热异常报警-用于界面显示*)
	g_xIODebugging: BOOL := FALSE; (* 默认未处于IO测试状态|@2020.11.10.094810 *)
	g_xInTheDiagnosis: BOOL := FALSE; (* 标记当前运行是否在诊断中 *)
	g_dwParaFileImportFailed:DWORD;(*参数导入失败标志|按位标识|.0 1色\.1 2色 依次类推*)
	g_xParaFileExportFailed:BOOL;(*参数导出失败*)
	g_iRtn_CheckFirmWareVer:INT;(*版本检查信息
		-1:参数错误
		\.0:GTSD13版本不一致
		\.1:GTSD16D版本不一致
		\.2:GTSD16M版本不一致
		\.3:GSHD版本不一致*)
	g_xAtleastOneUnitOffline_485:BOOL;(*至少一色485离线*)
	g_xAtleastOneUnitLineBreak_485:BOOL;(*至少一色pt100断线*)
	g_axFlag_Alarm_LD:ARRAY [1..2] OF BOOL;
	g_xAlarm_Rev:BOOL:=FALSE;
	g_iAxisId_Alarm_Rev:INT:=1;
	g_dwAvailPhys_kB:DWORD;
	g_xMemAllocFailed:BOOL;
	g_xEhmiOpened_Master:BOOL;(*主站ehmi未打开*)
	g_xNeedRestartPlc:BOOL;(*需要重启plc*)
	g_axReflectSensorLoss:ARRAY [1..2] OF BOOL;
	g_byAutoBackUpSts:BYTE;(*自动备份状态@=1 提示|=2 显示备份弹窗(强制界面切换到主界面)|PRG_SYNC_UI_UPDATE_\fbKS_FB_GrpFailureProc界面操作或者使用了 *)
(*deprecated@2025.8.27.165059/han.dp
	g_apstStTravelLogRec: ARRAY [1..GC_LOG_CLASSES_MAX_NUM] OF POINTER TO StTravelLogRec; (* 2021.7.5.111146/+/ *)
*)
	(*新增变量-结束|wang.nt|2025.08.13.134919*)
	(*新增工艺相关变量*)
	g_xCoolBlowerOpenByKnob: BOOL := FALSE; (* TRUE:冷风开关旋钮作为打开关闭冷风使能标志|否则为全体冷风打开旋钮打开的色组 *)
	g_xStopCoolBlowerWhenEstop: BOOL := FALSE; (* TRUE:急停停止冷风-- *)
	g_xHotBlowerOpenByKnob: BOOL := FALSE; (* TRUE:热风开关旋钮作为打开关闭热风使能标志|否则为全体热风打开旋钮打开的色组 *)
	g_xStopHotBlowerWhenEstop: BOOL := FALSE; (* TRUE:急停停止热风-- *)
	g_xStopAirExhaustWhenEstop:BOOL:=FALSE;(*TRUE:急停停止排风*)	
	g_xUseButton_PreHotBlower:BOOL:=FALSE;(*预热风使用按钮选择*)
	g_xUseButton_PreHeating:BOOL:=FALSE;(*预加热使用按钮选择*)
	g_xflag_printPreHeating:bool:=false;(*印刷开启预加热*)
		
	//2025.08.18.110718 | 增加固高WATCH功能相关
	g_xWatchOn : BOOL;
	g_xWatchOff : BOOL;
	(*2025.08.20.090543 模块采集的编码器值|未认真处理双收双放结构|2021.4.30.113648*)
	g_dwAbsEncSinglePos_Uw			: DWORD;(*放料编码器单圈值|*)
	g_wAbsEncMultiPos_Uw			: WORD;(*放料料编码器多圈值|*)
	g_dwAbsEncSinglePos_Rw			: DWORD;(*收料编码器单圈值|*)
	g_wAbsEncMultiPos_Rw			: WORD;(*收料料编码器多圈值|*)
	
	
	g_byLinkage_Lamp_3_Color:BYTE:=0;(*联动时三色灯颜色|默认=Normal|1=Lost|2=warning@2023.07.07.161402*)	
	g_byArcLampDisWay:BYTE:=0;(*三色灯显示模式
							    @0 默认在非印刷的时候按照联动指示用，红色作为急停！
					 			@1 在非印刷的时候不显示三色灯,
								@2 欧诺专用*)	
	g_axStartAutoFind: ARRAY [1..2] OF BOOL;(*2023.6.1.161520|分系*)					
	g_byTypeStepTest:BYTE;(*阶跃测试类型@=1 横向阶跃|反之纵向阶跃@2023.09.04.230955*)
	g_abyVerManuTrigButton: ARRAY [1..MAX_UNIT_NUM] OF BYTE := [MAX_UNIT_NUM(0)]; (* 纵向手动按钮|转发vs可视化界面操作| =1 向上|=2 向下*)			
	g_awVirtualCnt: ARRAY [1..MAX_UNIT_NUM] OF WORD;
	
	g_aiGrpUnitNum: ARRAY [1..2] OF INT;
	g_aiGrpAxisList: ARRAY [1..2,1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	g_aiStepAdj: ARRAY [1..2,1..MAX_UNIT_NUM] OF INT;

	g_axAdjMove_Up : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axAdjMove_Dn : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	(*新增绝对值编码器相关*)
	g_stStAbsEncIOModule_Uw : StAbsEncIOModule;
	g_stStAbsEncIOModule_Rw : StAbsEncIOModule;
	
	
	g_aiMode_Trap_Rtn : ARRAY [1..MAX_UNIT_NUM] OF INT;
	(*2025.8.22.202521*)
	
	g_abyClrPrnLenCount: ARRAY [1..2,1..3] OF BYTE := [6(0)]; (* 主界面记米清零点击计数 *)
	g_axClearPrnLen: ARRAY [1..2,1..3] OF BOOL; (* 主界面记米清零按钮 *)(*2020.7.30.111243|记米清零分A/B系|X.^_^*)

	g_xClrSts : BOOL;	
	g_iCoreId : INT := 1;
	g_iAxisId : INT := 1;
	(*新增预套准相关变量|wang.nt|2025.08.21.165745*)
	g_axPreRegisterCorrConfirm:ARRAY [1..2] OF BOOL;(*预套准修正量确认|通过印刷自动获得修正量*)
	g_axCorrectConfirmBtnDisplay: ARRAY [1..2] OF BOOL;(*自动获取的预套准修正量确认按钮显示标志*)
	g_iPrewrkSubPageId: INT := 3; (* 预套准子画面id| *)
	g_xLoadRecipe_End: BOOL; (* 读取配方完成标志|用于进行相位回复使能| *)
	g_xReqSaveRecipe: BOOL := FALSE; (* 保存配方按钮 *)
	g_xReqSaveCphRecipe: BOOL;
	g_xReqSaveCphCommonVir: BOOL;
	g_xLoadCphRecipe_End: BOOL;
	g_alrTotalAdjustVal_V:ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*套色总的调整量|用于预套准的修正*)
	g_xFlag_CphCommonVir: BOOL;
	g_xFlag_CphCommonVir_end: BOOL;
	g_xCphaseRestore: BOOL;
	g_xCphaseRestore_end: BOOL;
	(*固定相位保存和读取按钮|2024.6.22.163348*)
	g_axFixedPhaseSave:ARRAY [1..2] OF BOOL;
	g_axFixedPhaseRead:ARRAY [1..2] OF BOOL;
	g_adwIndex: ARRAY [1..2] OF DWORD;
	
	(*2025.9.5.100111*)
	g_byPseudoRandomSeries				:BYTE:=9;(*伪随机测试级数*)
	g_rPseudoRandomAmplitude			:REAL:=0.03;(*伪随机幅值@m/min\V*)	
	(*就直接放初始化里处理吧*)
	g_astStAxisIdListInf: ARRAY [1..128] OF StAxisIdListInf;(*128轴运动控制器所有轴的信息-与cfg文件同步，这样以后的CFG文件可不更改*)
	g_xPseudoRandomEn:BOOL;
	
	g_xPseudoRandomStart:BOOL;
	
	g_stStStationInfo_KS	: StStationInfo_KS;(*站列表信息*)
	g_astStStepDriveIOModule: ARRAY [1..MAX_UNIT_NUM] OF StStepDriveIOModule;
	g_astStEnc0410R: ARRAY [1..MAX_UNIT_NUM] OF StEnc0410R;             (* 数组下标代表色组号 *)	
	g_abyHorzManuTrigButton: ARRAY [1..MAX_UNIT_NUM] OF BYTE := [MAX_UNIT_NUM(0)]; (* 横向手动按钮|转发vs可视化界面操作| *)	
	g_abyHorzManu_HMI				: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	g_alrGirth_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF LREAL; (* 实际用于计算的涂布版周长 *)	
	(*2024.01.18.094629 +涂布处理参数*)
	g_stStCoatingAxisInf:StCoatingAxisInf;
	g_alrAI_CoatingHMI: ARRAY [1..MAX_UNIT_NUM] OF LREAL; (* 数组索引代表轴号 *)
	g_axArcErrValid:ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	g_aiArcErr_V:ARRAY [1..MAX_UNIT_NUM] OF INT;(*套色的纵向误差@每圈更新一次并按bit置位表示误差有效*)

	g_axAxisInching: ARRAY [1..MAX_UNIT_NUM] OF BOOL; (* 处于过单运行 *)
//	g_axAxisInchDecing: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单运行减速中*)
	g_axAxisInchAccing: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单运行加速中*)
	
	g_auiSendDataCnt_Tcp									:ARRAY [1..8] OF UINT;
	g_auiRecvDataCnt_Tcp									:ARRAY [1..8] OF UINT;
	g_auiRecvErrDataCnt_Tcp								:ARRAY [1..8] OF UINT;
	g_auiTimeOutDataCnt_Tcp								:ARRAY [1..8] OF UINT;	
	g_auiSendDataCnt_485									:ARRAY [1..8] OF UINT;
	g_auiRecvDataCnt_485									:ARRAY [1..8] OF UINT;
	g_auiRecvErrDataCnt_485								:ARRAY [1..8] OF UINT;
	g_auiTimeOutDataCnt_485								:ARRAY [1..8] OF UINT;	
	g_astStGetMotionSts: ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;
	g_adiPreRegisterPos: ARRAY [1..MAX_UNIT_NUM] OF DINT;
	
(*2025.11.1.142853*)	
	g_alrMaxVel_PreReg:ARRAY [1..MAX_UNIT_NUM] OF LREAL;//预套准最大速度-时间固定，速度不同
	
	g_awAxisVirtualCnt: ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.103841/轴虚拟编码器位置记录/恢复配方后由于重新配置采样会造成轴当前相位清零/用该值先保存恢复之前的位置值 *)
	g_awAxisVirtualSts: ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.104504/增加的虚拟编码器原始值输入 *)	
	
	g_aiGrpUnitList:ARRAY [1..2,1..MAX_UNIT_NUM] OF INT;(*联动未涂布轴列表|一维数组代表系号|初始值代表隐藏*)
	
	g_alrVel_VirtualAxis : ARRAY[1..2] OF LREAL;
	g_stStSysCfgStruct: StSysCfgStruct;
	g_xBtn_UpdateSysCfg:  BOOL;(*保存系统配置*)
	g_alrPrfPos : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	
	
	//2025.11.03.103620 | bai.zy | TEST_1103
	(*2021.11.29.142224 同步*)
	(*2020.12.23.211550 增加色组轴在运动过程中停止运动以及停止后加速到目标速度功能|Liu.yt*)
(*	g_xMotionStsSwitchEn:BOOL:=TRUE;(*使用该功能标志*)*)
	g_iMaxVel_StsSwitch:INT:=(*50*)600;(*速度可以切换的最大主机速度值|不要限值-写一个大值*)

	g_abyAxisMotionSts:ARRAY [1..MAX_STATION_NUM] OF BYTE;(*轴运动状态标志|0:同步运动状态.
													  |1:同步运动时停止运动状态.
													  |2:停止运动状态
													  |3:停止运动时加速到单运行速度状态.
													  |4:单运行时减速到停止状态.
													  |5:停止运动时或者使用单运行速度运行时加速到同步运动状态.
													  |6:非同步运动时急停到0状态.
													  |7:非同步运动时空转停机到0状态.*)
	g_axAxisMotionInching:ARRAY [1..MAX_STATION_NUM] OF BOOL;
	g_alrAxisMotionVel:ARRAY [1..MAX_STATION_NUM] OF LREAL;(*轴的速度值*)
	g_axLastAxisMotionInchBtn:ARRAY [1..MAX_STATION_NUM] OF BOOL;
	g_alrAcceleToSync: ARRAY [1..16] OF LREAL:=[16(0.0)];(*用来保证同步的加速度|m/min/ms*)
	g_alrTimeToSync: ARRAY [1..16] OF LREAL;(*用来保证同步的时间|m/min/ms*)
	g_alrRelatePos_Final:ARRAY [1..16,1..16] OF LREAL;(*做成16个轴|
													记录目标轴和当前轴的相对位置值|最后恢复的位置差
													一维下标为当前轴号，二维下标为目标轴号*)
	g_alrRelatePosToSync:ARRAY [1..16,1..16] OF LREAL;(*做成16个轴|
												记录目标轴和当前轴的相对位置值|开始切换到同步状态时的位置差
												一维下标为当前轴号，二维下标为目标轴号*)
												
	g_axInch : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axLinkage : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	g_diSyncErrorLimit : DINT := 83886080;
	g_astStMcgsBtn_HMI: ARRAY [1..MAX_UNIT_NUM] OF StMcgsBtn_HMI;
	
	g_xInit_StationList:BOOL;
	
	g_xCutSenSorDelay: BOOL;
//	g_stGT_SystemInfo : GT_SystemInfo;
	
	g_abyCpu_Load : ARRAY [0..3] OF BYTE;
	
	g_xFlagEmergencyForFile_tmp : BOOL;
	
//2025.11.24.104500 | 增加修改龙门相关	
	g_astStSetPrm_GantryTrap				: ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	
	//压力全体动作
	g_xPressUp_To_Dn : BOOL;//全体合压
	g_xPressDn_To_Up : BOOL;//全体离压
	g_xPressUp_To_Load : BOOL;//全体退出
	g_xPressLoad_To_Up : BOOL;//全体进入
	g_xPressMoveToLoad : BOOL;//换版准备
	g_axFirstMenu : ARRAY [1..5] OF BOOL;
	g_awPressMenu : ARRAY [1..5] OF WORD;
	
	g_axConfirm:ARRAY [1..3,1..MAX_UNIT_NUM] OF BOOL;
	
	//增加调试阶段测试压力电机反复来回运行	
	g_xPressDebugMode : BOOL;
	g_axPressDebugStart : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF BOOL;
	
	//清除压力电机扭矩保护的标志	
	g_xConfirmContinueForward : BOOL;
	
	g_rPos_press_dn_PrnRoller_Pressure_MM : REAL := 3;
	
	//
	g_rUp_Dn_Length_MM : ARRAY [1..MAX_UNIT_NUM] OF REAL := [MAX_UNIT_NUM(3)];
//	g_rUp_Dn_Length_MM:REAL:=3;
	g_rPos_press_dn_NetRoller_Pressure_MM : REAL :=3;
	g_xConfirm_Adjust_PressDn : BOOL;
	
	g_iAxis_Test: INT:= 1;
	g_xTest_MoveFor: BOOL;
	g_xTest_MoveRev: BOOL;
	g_rTest_AllLength: REAL:= 3000;
	g_rTest_StepLength: REAL:= 5;
	
	g_astStTrapAxisParam_Gantray : ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF StTrapAxisParam_Gantray;

	g_astStHandWheel: ARRAY[1..MAX_UNIT_NUM] OF StHandWheel;
	g_astStHandWheel_BtnCtl: ARRAY [1..MAX_UNIT_NUM] OF StHandWheel_BtnCtl;	
	g_sHandConnectedSignal : STRING;
	g_xModeCalibSwitch : BOOL;
	g_xModeCalibSwitch_Flag : BOOL;

	
	g_axAuto_Press_Unit: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axPress_Manu: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axUnPress_Manu: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	
	g_liAbsPos_M : LINT;
	g_liAbsPos_G : LINT;
	g_liAbsPosTrap : LINT;
	
	//2024.11.22.154437 | bai.zy | 清除压力标定
	g_axResetFlag_FinishCalid : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	
	g_astStLatch : ARRAY [1..MAX_UNIT_NUM] OF StLatch;
	
	g_aliTrapAbsPos :ARRAY [1..MAX_STATION_NUM] OF LINT;
	g_aliM_EncPos :ARRAY [1..MAX_STATION_NUM] OF LINT;
	
	//检测带长
	g_iSyncBandLen_Unit : INT := 1;	
	g_xFlag_AxisInch_Print : BOOL;//整机点动标志
	
	//2025.03.25.180838 |
	g_rGirthStepBandLen_Kp : REAL := 0.1;
	g_rGirthStepBandLen_Kd : REAL := 0.3;
	
	//2025.01.23.113618 | 带长检测异常
	g_axCheckBandLenErr : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	//2025.03.10.171545 | 带长滤波去除极值
	g_xRemoveExtremum : BOOL;
	
	//2025.02.10.095044 | 增加张力调整方式的开关选择以及增加界面对于新PID调整方式的P、I的输入
	g_xTensionAdjust_NewWay : BOOL;
	g_iTensionAdjust_Kp : INT := 30;
	g_iTensionAdjust_Ki : INT := 60;
	g_xInitPressSlope : BOOL;
	g_rPressValue : REAL := 1000.0;
	g_rPressure_AnalogThreshold : REAL := 0.025;
	//2025.02.10.194406 | 
	g_rGirthStep : REAL;//收牵调整量
	g_rGirthStep_Kp : REAL;//收牵调整量
	g_rGirthStep_Ki : REAL;//收牵调整量
	g_lrAnalog_Aver : LREAL;//模拟量平均值
	g_rStep_Compension : REAL;//补偿量
	g_lrCur_PressureValue : LREAL;
	
	//2025.01.23.085415 | bai.zy | 秦华增加印后牵引的压力传感器
	g_lrTempOF_PrintingOut : LREAL;
	g_lrTempOF : LREAL;
	
	//交互信号
	g_astStInteraction : ARRAY [1..MAX_UNIT_NUM] OF StInteraction;
	
	g_stStSysStationInf : StSysStationInf;
	g_stStSysGantryAxisInf : StSysGantryAxisInf;
	
	//2025.03.19.95021 | 纵向对版标志
// 	g_axArcMoveUp : ARRAY[1..MAX_UNIT_NUM] OF BOOL;
// 	g_axArcMoveDn : ARRAY[1..MAX_UNIT_NUM] OF BOOL;

	//2025.12.27.142247 | + 机器类型，看后面要不要增加到系统参数
	g_iMachineryType : INT;
	
	g_arTempEncPosBandLength : ARRAY [1..MAX_UNIT_NUM] OF REAL;

	g_axInk_Unit: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	g_axMoveUp : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axMoveDn : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_aiTemp : ARRAY [1..8] OF INT := [1,2,3,4,5,6,7,8];
	
	//2026.01.12.140115 | + | 清除驱动器报警
	g_xClrAlr_HMI : BOOL;
	
	g_iErrAxisId : INT;
	g_iErrTypeId : INT;
	g_iErrUnitId : INT;
	g_iErrCoreId : INT;
	
	g_abyInteractionCtl : ARRAY [1..MAX_STATION_NUM] OF BYTE;	
	(*2026.01.15.154707//新增品字形柔印机参数-适配版辊垂直移动*)
	g_arFix_RightEdge: ARRAY [1..MAX_UNIT_NUM] OF REAL:=[MAX_UNIT_NUM(120.00)]; //直角边固定机械值 单位:mm 底辊到版辊
	g_arK_TSHAPED_PrnVertical : ARRAY [1..MAX_UNIT_NUM] OF REAL; //比例系数
	
	//2026.1.28.151219增加GNS本地IO处理
	g_xUseIO_FromGNS_Enable: BOOL;
	g_dwInput_IO_GNS_P6P8: DWORD;
	g_dwInput_IO_GNS_P4P3: DWORD;
	g_dwOutput_IO_GNS_P5P7: DWORD;
	
	//2026.01.28.114017 | + | 增加横向的位置记忆，此参数需要放在色组的保持参数里面，先放这里吧
	g_aliABSPos_Horiz : ARRAY [1..MAX_UNIT_NUM] OF LINT;
	g_astStSetPrm_Trap				: ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	g_axLimit_Left_Wr	 					: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//标定横向左右限位值
 	g_axLimit_Right_Wr	 					: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//标定横向左右限位值
	g_axLimit_Left_WrClr	 					: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//清除横向左右标定限位值
 	g_axLimit_Right_WrClr	 					: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//清除横向左右标定限位值
	
	g_xMoveEnTrap:BOOL:=TRUE;
	g_axMove_Left: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axMove_Right: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_xInit_TrapPoint: BOOL:= FALSE;
	g_xWashingPrn: BOOL;
	
	g_xAxis:BOOL;
	g_xjogtest:BOOL;
	
	//2026.03.14.113537 | + | 增加虚拟码盘异站功能
	(*2022.1.20.103708 增加了虚拟码盘功能需要变量*)
	g_auiSetVirtualEncCfgCnt:ARRAY [1..2] OF UINT;(*异站虚拟码盘参数设置计数*)
	g_xCheckVirtualStsEn:BOOL;(*异站编码器返回状态检查标志|*)
	g_adwVirtualAcrossEnSts:ARRAY [1..2] OF DWORD;(*异站虚拟码盘设置状态返回*)
	g_axVirtualStsChangeFrom2To:ARRAY [1..2] OF BOOL;(*异站虚拟码盘状态由2切换到别的状态标志|有切换对该标志取反切换*)
	g_axReSetEncCfg:ARRAY [1..2] OF BOOL;(*重新设置异站编码器配置*)

	g_aiSetVirtualEnc_ErrCode: ARRAY [1..2] OF INT;
	g_aiVirtualEnc_AxisId_Src: ARRAY [1..2] OF INT;(*虚拟码盘的源轴号*)
	g_aiVirtualEnc_AxisId_Des: ARRAY [1..2] OF INT := [2(1)];(*虚拟码盘的目标轴号*)
	g_aiSetVirtualEncCfgRtn	 : ARRAY [1..2] OF INT;(*虚拟码盘配置返回值*)
	
	g_StVirtualParam : StVirtualParam;
	
	g_awAccButton_Count				:ARRAY [1..MAX_UNIT_NUM] OF WORD;
	g_awDecButton_Count			:ARRAY [1..MAX_UNIT_NUM] OF WORD;
	g_awUpAdjButton_Count			:ARRAY [1..MAX_UNIT_NUM] OF WORD;
	g_awDnAdjButton_Count			:ARRAY [1..MAX_UNIT_NUM] OF WORD;
	g_awLeftAdjButton_Count			:ARRAY [1..MAX_UNIT_NUM] OF WORD;
	g_awRightAdjButton_Count			:ARRAY [1..MAX_UNIT_NUM] OF WORD;
	g_awAlarmButton_Count			:ARRAY [1..MAX_UNIT_NUM] OF WORD;	
	
	//2026.1.26.171345 | + | 增加回零位的功能
	g_axBackToHome : ARRAY [1..2] OF BOOL;
	
	g_aiTestBtn:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiTestBtn1:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiTestBtn2:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiTestBtn3:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiTestBtn4:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiTestBtn5:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiTestBtn6:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiTestBtn7:ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_lrtest:LREAL;
	g_lrtest1:LREAL;
	g_lrtest2:LREAL;
	g_lrtest3:LREAL;
	g_lrtest4:LREAL;
	g_rtest:REAL;
	g_rtest1:REAL;
	g_uitest1:UINT;
	g_uitest2:UINT;
	
	g_r1test:REAL;
	g_r1test1:REAL;
	g_ui1test1:UINT;
	g_ui1test2:UINT;
	
	g_lrposM:ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	g_lrposG:ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	
	g_rposM:ARRAY [1..MAX_UNIT_NUM] OF REAL;
	g_rposG:ARRAY [1..MAX_UNIT_NUM] OF REAL;
	g_uiNum:ARRAY [1..MAX_UNIT_NUM] OF UINT;
	
	g_alrTrap_EncPos						: ARRAY [1..MAX_UNIT_NUM] OF LREAL;//横向点位轴的规划位置
	g_aiCount_MoveUp						: ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiCount_MoveDn						: ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_arStep_Use							: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	g_alrGantryTrapM_EncPos					: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	g_alrGantryTrapG_EncPos					: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	g_aiCount_Dn							: ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiCount_Up							: ARRAY [1..MAX_UNIT_NUM] OF INT;
	g_aiCount_unLoad						: ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	g_alrGantryTrap_PrfPos					: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	g_alrGantryTrapM_PrfPos					: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	g_alrGantryTrapG_PrfPos					: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
//2026.04.12.171341
	g_alrCurrentAbsPos_Init : ARRAY [1..MAX_STATION_NUM] OF LREAL;
	g_alrCurrentAbsPos_Debug : ARRAY [1..MAX_STATION_NUM] OF LREAL;
	g_alrCurrentAbsPos_Trap : ARRAY [1..MAX_STATION_NUM] OF LREAL;
	g_alrCurrentAbsPos_M : ARRAY [1..MAX_STATION_NUM] OF LREAL;
	g_alrCurrentAbsPos_G : ARRAY [1..MAX_STATION_NUM] OF LREAL;

	g_alrM_EncPos_1u_m : LREAL;
	g_alrM_EncPos_1u_g : LREAL;
	
	g_astStAxis_Sts_Save_Gear : ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Gear;
	g_astStAxis_Sts_Display_Gear : ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Gear;
	g_astStAxis_Sts_Save_GantryTrap : ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_GantryTrap;
	g_astStAxis_Sts_Display_GantryTrap : ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_GantryTrap;
	g_astStAxis_Sts_Save_Trap : ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Trap;
	g_astStAxis_Sts_Display_Trap : ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Trap;
	
//2026.3.2.162241 | 添加用于存储扭矩系数的数组（大小为MAX_STATION_NUM）
	g_arTqCOeff:ARRAY[1..MAX_STATION_NUM] OF REAL;

//2026.05.08.141028 | + | 增加收放料伺服的标志
	g_xUwRwIsServo	: BOOL;
	
	g_iRtn_MulFunCtl : INT;
	
	g_adiMasterEven : ARRAY [1..3] OF DINT;
	g_adiSlaveEven : ARRAY [1..3] OF DINT;
	g_adiMasterSlope : ARRAY [1..3] OF DINT;
	
	//2026.05.09.160415 | + | 增加龙门偏差过大保护
	g_axPressFlag_Stop : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axBtn_MoveLeft_Horz: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_axBtn_MoveRight_Horz: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_arTrapPos_mm	: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	
//2026.5.9.181759增加全自动套印一些变量
	
	g_aiStep_AutoAdjust: ARRAY [1..MAX_UNIT_NUM] OF INT;(*主站全自动套印的找标的执行状态*)
	//g_io_xStartAutoFind:BOOL;
	//xi.hy
	g_astStFiberMoveStepDriver: ARRAY [1..MAX_UNIT_NUM] OF StFiberMoveStepDriver;
	g_xFindMarkCenter:BOOL;
	(* 2022.4.8.203048/hdp (*2026.03.23.163405||粗采样保存wang.xy*)*)
//	g_xSaveRS2file: BOOL := FALSE;
	g_pstStRSampFifo: POINTER TO StRSampFifo := 0;
	
	g_StiffenTest :BOOL := FALSE;
	g_lrP_Component_Uw:LREAL;
	g_lrI_Component_Uw:LREAL;
	g_lrD_Component_Uw:LREAL;
	
	g_lrP_Component_Rw:LREAL;
	g_lrI_Component_Rw:LREAL;
	g_lrD_Component_Rw:LREAL;
	(*2026.03.28.182319||wang.xy*)
//	g_rFiberMove:ARRAY [1..2] OF REAL:= [-3,6];//光纤粗调移动距离
	
//	g_xEnFastPress :BOOL:=TRUE;//当前色找到就合压
	g_xEnFastPress2 :BOOL;//1.5圈直接合压
//	g_xRFailure:BOOL;//粗采样校准失效
//	g_xFFailure:BOOL;//精采样校准失效
	g_EffectiveHumanIntervention:BOOL;//人工干预有效，打开时如果全自动套印三次没找到位置，需要人工干预才能进行下一步
	g_xAllMeanCtl:bool;
	
	g_xSendResToOnline:BOOL;
	
	//2026.04.03.233727
	g_rCoffByOnline:REAL:=1/1000;
	
	//(*2026.04.06.175340||wang.xy全自动套印合压输入*)
	g_axAutoFind_Press:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*套色Kp地址值*)
	
//2026.4.11.150854加速度与加加速度
	g_arCur_A: ARRAY [1..2] OF REAL;
	g_arCur_Jerk: ARRAY [1..2] OF REAL;
	g_aiGrpLinkageAxisNum_Pu: ARRAY [1..2] OF INT;
	g_aiGrpLinkageAxisList: ARRAY [1..2,1..MAX_UNIT_NUM] OF INT;
	
//	g_alrAxisMotionVel:ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*轴的速度值*)	
	
	g_lrPrfVel2 : LREAL;
	
	g_lrPrfAcc_MasterAxis : LREAL;
	g_alrPrfAcc_MasterAxis2 : ARRAY [1..2] OF LREAL;	
	
	g_lrK:LREAL;
	g_lrB:LREAL;
	g_xLoadParamFild: BOOL:= FALSE;
//2026.4.12.135907为了将裁切放在主任务增加
	g_axSts_Sensor1Ok: ARRAY [1..2] OF BOOL;
	g_axLamp_PreDrive_Debug_Uw: ARRAY [1..2] OF BOOL;
	g_axReqCut_Uw: ARRAY [1..2] OF BOOL;
	g_axTell_KS_PreDrv_CTL_Uw_CuttDne: ARRAY [1..2] OF BOOL;
	//2026.06.02.223725+
	g_axTell_KS_FB_AvoidSomeFilmWithoutAdjust_CuttDne: ARRAY [1..2] OF BOOL;
	
	//xi.hy新增@七号以后
//	g_astStVarList : ARRAY [1..MAX_STATION_NUM] OF StVarList;
	
		(*2026.5.7.173444lhy+*)
	g_byOutType:BYTE:=0;(*输出类型@=0 阶跃一定时间|=1 方波输出|=2 伪随机输出@i_xStepBtn有效则接收伪随机量*)
	g_iTestVelSa:INT:=50;(*启动速度m/min*)
//	g_iTestVelSa_ACC:INT:=60;(*加速启动速度m/min*)
//	g_iTestVelSa_DEC:INT:=100;(*减速启动速度m/min*)
	g_uiSquareCycle_ms:UINT:=1000;
	g_uiSquareNum:UINT:=16;(*2026.1.14.192100+方波个数*)
	g_axStepBtn_MotionCtl:ARRAY [1..2] OF BOOL;(*阶跃按钮@外部沿复位*)
	g_arStepVel_MotionCtl:ARRAY [1..2] OF REAL:=[0.03,0.03];(*阶跃速度@m/min*)
	g_auiStepAccDecTime_MotionCtl:ARRAY [1..2] OF UINT:=[0,0];(*加减速时间，简单点使用一个@ms*)
	g_auiStepTotalTime_MotionCtl:ARRAY [1..2] OF UINT:=[16,16];(*输出的总时间@s|默认1s*)
	g_abyStepAxisId_MotionCtl:ARRAY [1..2] OF BYTE:=[3,3];(*阶跃的轴id@默认为非法值*)
	g_axStepping_MotionCtl:ARRAY [1..2] OF BOOL:=[FALSE,FALSE];(*阶跃中标志*)	
	
//2026.5.12.143246|同步超限代码
	g_diVel_Virtual_Tar_Temp : DINT;
	g_lrMax_a_S_pos : LREAL;
	
	g_axRemoteSetFailed : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	g_aiCurLabelPos: ARRAY[1..MAX_UNIT_NUM,1..3] OF INT;
    g_arCurLabelWidth: ARRAY[1..MAX_UNIT_NUM,1..3] OF REAL;
    g_rFiberMoveDist: ARRAY[1..MAX_UNIT_NUM,1..2] OF REAL;
	
//	g_axRemoteSetFailed : ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	g_arRemainDia_Cur: ARRAY [1..2] OF REAL;	
	g_xError_SysCfg: BOOL;//系统配置异常
	g_xUnLine_SysStation: BOOL;//网络站点离线
	g_xTrigSave_BlackoutSts: BOOL;
//2026.05.23.111030 | + |相位恢复超时报警标志
	g_axPhaseRestore_Overtime:  ARRAY [1..2] OF BOOL;	
(*2026.5.28.150112增加预套准结构初始化*)	
	g_pstStMechanicalParam_01: POINTER TO StMechanicalParam_01; (* 机械结构1 *)
	g_pstStMechanicalParam_02: POINTER TO StMechanicalParam_02; (* 机械结构2 *)
	g_pstStMechanicalParam_03: POINTER TO StMechanicalParam_03; (* 机械结构3 *)
	(*2023.09.21.145817 同步*)
	g_pstStMechanicalParam_05: POINTER TO StMechanicalParam_05;(*机械结构5|2023.07.11.110800*)
//2026.5.29.153619	
	g_xAutoPrintMasterAlarm : ARRAY [1..2] OF BOOL;
	
END_VAR
{IMPLEMENTATION}
