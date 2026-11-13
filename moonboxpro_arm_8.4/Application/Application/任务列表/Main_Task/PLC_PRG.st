(*@CES
Name=PLC_PRG
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0004b05b-52ec-439c-9f50-4a8655be5d9d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
PROGRAM PLC_PRG
(*主任务-10ms，用于处理弧面信号/套色误差处理等动作*)
VAR
	tiPLC_PRG_Start : TIME;
	tiFunctionEndTime : TIME;
	tiFunctionStartTime : TIME;

	tTime_WriteFileParam_Log: TIME:= T#20S;
	tTime_Cur: TIME;
	tTime_Start_Log: TIME;
	xInitTime_Log: BOOL;	
	
	aiAlarm_V: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiAlarm_H: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiAdj_V: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiAdj_H: ARRAY [1..MAX_UNIT_NUM] OF INT;
	abyAverageNum_V: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	abyAverageNum_H: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	//2026.04.11.152628+
	abyAverageNum_Display: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	astStErrParam_Use: ARRAY [1..MAX_UNIT_NUM] OF StErrParam_Use;
	iN: INT;
	iNum: INT;
	iGrpId: INT;
	xRequstRdAgainOfRingNetDetails: BOOL;	
	
	xInit: BOOL;
	abyLastIndex: ARRAY [1..MAX_UNIT_NUM] OF BYTE;

	(*2025.8.6.193356-套色调整相关*)
	xIsContinue: BOOL;
	axUseErrTransfer: ARRAY [1..2] OF BOOL;
	axCanCalcArcAdjustValue_Grp: ARRAY [1..2] OF BOOL;(*系的计算调整量总标志@控制小黄的耦合算法执行*)
	axCanCalcArcAdjustValue:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xRtn: BOOL;
	adwGetArcErrorAxisIdBitIndex: ARRAY [1..2] OF DWORD;(*/.0 轴1 /.1 轴2 ...以此类推*)
	aiGetAxisArcErrorNum: ARRAY [1..2] OF INT;
	dwTempVal: DWORD;
	iStationId: INT;
	iAxisTypeId: INT;
	iUnitId: INT;(*色组号*)

	(*2024.8.1.120147 横向补偿使用的裁切标志*)
	axFlagCutDne_UseHorCompensate_Uw: ARRAY [2..16] OF BOOL;
	axFlagCutDne_UseHorCompensate_Rw: ARRAY [2..16] OF BOOL;
	aiFinalAdjust_V: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiFinalAdjust_H: ARRAY [1..MAX_UNIT_NUM] OF INT;
	arFinalAdjust_V_ArcList: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*索引为色序的调整量数组*)
	arFinalAdjust_V_Act: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*实际调整量数组*)
	arFinalAdjust_V_Act_ArcList: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*索引为色序的调整量数组*)
	(*2024.7.26.161051 接料补偿@按照每个色组*)
	aiArcActErr_V: ARRAY [2..16] OF INT;(*套色的实际误差@2024.7.26.160439*)
	arD_hat:ARRAY [2..16] OF REAL;(*扰动估计量*)
	(*套色误差使用低通@2024.05.25.132905*)
	arEk_ArcErr_Lp		:ARRAY [2..16,1..3] OF REAL;(*输入寄存器*)
	arE_DEAL_ArcErr_Lp	:ARRAY [2..16,1..3] OF REAL;(*输出寄存器*)
	aiHerror_FollowBefore:ARRAY [1..MAX_UNIT_NUM] OF INT;	
	wParam: WORD; (* 丢失|飞点|让料头 *)
	xFlagAdjEnaCalc: BOOL; (* 调整计算使能 *)	
	xFlagVelCtl: BOOL; (* 速度控制状态 *)	
	lrMaxAdjustVal: LREAL := 0; (* 单周期内最大的调整量 *)	
	lrMaxAdjustVal_H: LREAL;		(*2023.6.19.163047*)
	iTmp_DataIndex: INT; (* 误差传递 *)
	iTmp_PrevAxisId: INT; (* 误差传递 *)
	iTmp_RelayErrData_V: INT; (* 误差传递| *)	
	iM: INT;
	iSaveTmp_RelayErrData_V: INT;		(*存储的误差传递值*)
	iErForCalc_v: INT; (* 2018.8.22.173310|误差传递| *)
	iError_Curve_Temp_V: INT;
	rError_Curve_Temp_V_Filter: REAL;	
	iFinalError_V: INT; (* 纵向最终误差 *)
	iFinalError_H: INT; (* 横向最终误差 *)
	lrTotalAdjustValue: LREAL;		(*总的调整量-实际电机执行的*)
	iFinalAdjust_V: INT; (* 纵向最终调整量 *)
	iFinalAdjust_H: INT; (* 横向最终调整量 *)
	iKp_InUse: INT;
	iKi_InUse: INT;
	iKd_InUse: INT;
	xByPassDeCouple: BOOL;(*跳过解耦控制器*)
	astStArcCoupleRegister:ARRAY [1..2] OF StArcCoupleRegister;(*寄存器参数|索引为系索引*)
	astStArcCoupleRegister_Follow1: ARRAY [1..2] OF StArcCoupleRegister_Follow1;
	byCurGrpId: BYTE;
	arFilmLenth_ArcList: ARRAY [1..DECOUPLD_DDPD_MAX] OF REAL;(*色组的料膜长度@索引为色序-单位mm*)
	rTs: REAL;	
	xClrSts: BOOL;
	arDeltaAcceleration_Cur_Delay: ARRAY [2..16,1..20] OF REAL;
	arAcceleration: ARRAY [2..16,1..5] OF REAL;
	arAcceleration_Last:ARRAY [2..16] OF REAL;	
	abyAccDecCompensate: ARRAY [2..16] OF BYTE(*=1 补偿开始|=2 补偿结束处理|=0不补偿*);
	arArcVel_LastCycle: ARRAY [2..16,1..2] OF REAL;(*前2拍的速度值|采样周期是圈|[1] 是上一拍,[2]是上上一拍*)
	axDelayCntEn: ARRAY [2..16] OF BOOL;
	abyDelayCnt: ARRAY [2..16] OF BYTE;
	arTarVel_AccDec: ARRAY [2..16] OF REAL;
	arVel_AccelerationEnd: ARRAY [2..16] OF REAL;
	arPrevCycleAcceleration: ARRAY [2..16] OF REAL;(*上一圈的加速度值|用来计算变化量*)
	arPrevCycleDeltaAcceleration: ARRAY [2..16] OF REAL;(*上一拍的加速变化量值@用于判断加速度变化量*)
	axTargetValueTo0_En: ARRAY [2..16] OF BOOL;
	auiCnt_TargetValueTo0_En: ARRAY [2..16] OF UINT;(*使能标志时机计数*)
	arTime_TargetValueTo_ms: ARRAY [2..16] OF REAL;(*目标值到0的时候@ms*)	
	arTargetValue_Cur: ARRAY [2..16] OF REAL;
	atPrevCycleTime:ARRAY [2..16] OF TIME;
	arResult_EvenAccSeg:ARRAY [2..16,1..2] OF REAL;
	
	sFileName_Param: STRING:= FNAME_SYS_PARAM_A;
	iRtn: INT;
	xStartUp: BOOL;
	
	parCompensateDelayArr: POINTER TO ARRAY [1..200] OF REAL;	
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;	
	
	//pfbFilter: POINTER TO KS_FB_FiltByAver;(*定义一个只想滤波器的指针*)		
	fbKS_FB_GetError_Arc: KS_FB_GetError_Arc;
	afbKS_FB_ARC_PIDAdjust: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_ARC_PIDAdjust;
	fbKS_FB_GetRingNetStationDetails: KS_FB_GetRingNetStationDetails;
	fbKS_FB_StRecord_A: KS_FB_StRecord_A;
//2026.5.9.111535调整量输出放20ms任务吧
//	afbKS_FB_AdjOutCtl: ARRAY [1..2] OF KS_FB_AdjOutCtl;
	iGrp: INT;
	aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	aiStepAdj: ARRAY [1..MAX_UNIT_NUM] OF INT;
	afbKS_FB_VertAdjustCtrl: ARRAY [1..2] OF KS_FB_VertAdjustCtrl;
	
	uiGroupStationNum: UINT;
	adwInfo_Station: ARRAY [1..128] OF DWORD;
	tmTestSa: TIME;
	tmValue: TIME;
	
	fbKS_FB_IOConfig: KS_FB_IOConfig;
	fbKS_FB_StepDriveCTL : KS_FB_StepDriveCTL ;
	fbKS_AbsEncModule_IODeal:KS_AbsEncModule_IODeal;
	afbKS_FB_GrpHorzAdjustCtrl:ARRAY [1..2] OF KS_FB_GrpHorzAdjustCtrl;(*横向*)
	iRtn_GetGroupInf: INT;
	aliTime_Value: ARRAY [1..20] OF LTIME;
	iCoreId_1: INT:=1;
	iCoreId_2: INT:=2;
	aiRtn: ARRAY [1..40] OF INT;
	sMsg: STRING;
	iRtn_RdCfg: INT;
	iRtn_WrCfg: INT;
	
	
	iMaxRetryTimes: INT := 3;
	aiRetryCount: ARRAY [1..40] OF INT := [0];	
	
	apData : ARRAY [1..MAX_UNIT_NUM] OF UINT;
	apData1 : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	apData2 : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	//2025.11.16.104641 跟一色解耦
	afbKS_FB_GetCouplingValue_V:ARRAY [1..2] OF KS_FB_GetCouplingValue_V;
	arCouplingValue: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*索引为色序的调整量数组*)
	
	aliTime : ARRAY [1..10] OF LTIME;
	
	
	aiPress_Manu: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiUnPress_Manu: ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	fbKS_FB_GNS_IOCtl: KS_FB_GNS_IOCtl;
	adiGNSIO_Input: ARRAY [1..2] OF DINT;
	diGNSIO_Output: DINT;
	
	
	//2026.4.12.134511增加放料弧面检测
	axSensor_Reflex: ARRAY [1..2] OF BOOL;
	iId_Uw_IO: INT;
	iId_Rw_IO: INT;
	iId_If_IO: INT;
	iId_Of_IO: INT;
	axCutCtlEn: ARRAY [1..2] OF BOOL;
	arDiam_NewVol_Use: ARRAY [1..2] OF REAL;
	arVel_Predrv_Use: ARRAY [1..2] OF REAL; 	
	afbKS_FB_CutDelay_CTL_Uw: ARRAY [1..2] OF KS_FB_CutDelay_CTL_Uw;
	afbTon_DelayTimer_CutOffKnifeCylinder_Uw: ARRAY [1..2] OF TON;
	afbTrig_DelayTimer_CutOffKnifeCylinder_Uw: ARRAY [1..2] OF R_TRIG;//2026.05.25.154820+ 需要一个沿
	axOutput_CutCylinder: ARRAY [1..2] OF BOOL;
	aiCutTotalTime: ARRAY [1..2] OF INT;
	aiDelayMsec_CutOffKnifeCylinder_Final: ARRAY [1..2] OF INT;
	axTorqueCancel: ARRAY [1..2] OF BOOL;
	aiDelayMsec_RollerCylinder_Final: ARRAY [1..2] OF INT;
	aiTimeCnt: ARRAY [1..2] OF INT;
	afbRTrig_Sts_Precuting: ARRAY [1..2] OF R_TRIG;
	axNeedTorqueCancel: ARRAY [1..2] OF BOOL;
	axAxisATorqueCancel_Out: ARRAY [1..2] OF BOOL;
	axAxisBTorqueCancel_Out: ARRAY [1..2] OF BOOL;	
	
//2026.5.8.115201
	hsMode : INT;
	interval : LREAL;
	readHsEnable : INT;		
	
(*月光宝盒异站配置*)
	xRemoteSetDne : BOOL;
	iRemoteSetFailed : INT;
	axRemoteSetDne				: ARRAY [1..MAX_STATION_NUM] OF  BOOL;
	axRemotSetFailed			: ARRAY [1..MAX_STATION_NUM] OF BOOL;
	
	adwMotorEncoder : ARRAY [1..MAX_UNIT_NUM] OF DWORD := [MAX_UNIT_NUM(4194304)];
	
	auiAllowMotorRpm_Max : ARRAY [1..MAX_UNIT_NUM] OF UINT := [MAX_UNIT_NUM(5000)];

	udiAddrRd:UDINT;

	iK: INT;
	fbKS_FB_TRIG: R_TRIG;
	xFlag_Stop_Sys: BOOL;//整机系统停机状态
END_VAR

{IMPLEMENTATION}
tiPLC_PRG_Start := TIME();
KS_TskCycle_Begin(ADR(g_astStTaskCycleDetection[1]));

CASE g_iRunStepId OF 
	RUNSTEP_STARTUP:
		g_xRunNormalTask:= FALSE;	
		Action_StartUp();
		IF xStartUp THEN
			g_iRunStepId:= RUNSTEP_RdRingNetStationDetails;//RUNSTEP_NormalWork;(* 再去加载系统配置文件 *)
		END_IF
	RUNSTEP_RdRingNetStationDetails:
		Action_GetGroupInf();
		g_iRunStepId:= RUNSTEP_LoadSysParam;
	RUNSTEP_LoadSysParam:
		Action_LoadSysParam();
	RUNSTEP_LoadCfg_Motor:
		Action_LoadConfig_Motor();	
	RUNSTEP_LoadSysCfg:
		Action_LoadSysCfg();
	RUNSTEP_UpdateSysCfg:
		Action_UpdateSysCfg();
	RUNSTEP_NormalWork:
		g_xRunNormalTask:= TRUE;
		Action_NormalWork();
	RUNSTEP_RESERVED:
		Action_SetSysCfg();	
END_CASE

tiFunctionEndTime := TIME();
g_aiFunctionConsueTime[5] := TIME_TO_INT(tiFunctionEndTime-tiFunctionStartTime);
	
(*主程序逻辑控制结束end-----------------------------*)
(*g_dwPlcLoad:= SysGetPlcLoad(0);(* cpu消耗 *)*)
KS_TskCycle_End(ADR(g_astStTaskCycleDetection[1]));

g_iTime_Main_Task := TIME_TO_INT(TIME()-tiPLC_PRG_Start);

aliTime[10] := aliTime[2] - aliTime[1];
aliTime[9] := aliTime[3] - aliTime[2];
aliTime[8] := aliTime[4] - aliTime[3];


