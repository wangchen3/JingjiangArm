(*@CES
Name=KS_FB_MotionCtl_New
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2af648f3-021d-4838-aa76-d812d81b3636
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_MotionCtl_New
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpGearMotion_Num: INT;
	i_aiGrpGearMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_rVel_VirtualMotion: REAL;
	i_pastStSetPrm					:POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pstStGetPrm					:POINTER TO TMultiMcFunctionReadPrm;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pastStMotorParam_Vel: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
	i_diVel_Virtual_Tar: DINT;(*虚拟主轴规划速度*)
	i_lrMax_a_S_pos: LREAL;(*虚拟主轴最大减速度*)	
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	
	i_pstStEvtReq: POINTER TO StEvtReq;(* 动作提取 *)
	i_pawAxisVirtualCnt: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.104504/增加的虚拟编码器原始值输入 *)	
	i_pawAxisVirtualSts: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.104504/增加的虚拟编码器原始值输入 *)	
	i_padiPreRegisterPos: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF DINT;
	i_palrMaxVel_PreReg: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;//预套准最大速度-时间固定，速度不同
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	//增加加速度及加加速度输入只2026.4.11.153755
	i_paxFlag_PressDne: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	i_rVel_A: REAL;//加速度
	i_rVel_Jerk: REAL;//加加速度；		
END_VAR
VAR_OUTPUT
	o_iAxisId_Master: INT;
	o_lrVel_VirtualAxis : LREAL;
	o_iErrAxisId : INT;
	o_iErrTypeId : INT;
	o_iErrUnitId : INT;
	o_iErrCoreId : INT;
	o_iMoveErrCode: INT; (* 初始化错误代码
												0-正常
												1-使能异常
												2-模态0设置异常
												3-模态1设置异常
												4-规划器启动异常
												5-PT模式设置异常
												6-伺服打开超时
												7-PT规划异常 *)	
END_VAR
VAR_IN_OUT
	io_xMotionEnabled: BOOL;(*|2021.1.15.092801 速度控制块使能修改为输入输出变量|这里处理该值的复位*)
END_VAR
VAR
	fbTRIG_Home: R_TRIG;
	fbTRIG_PreRegister: R_TRIG;
	fbTRIG_PhaseRestore: R_TRIG;
	fbTRIG_PhaseRead: R_TRIG;
	
	fbTRIG_Home_end: R_TRIG;
	fbTRIG_PreRegister_end: R_TRIG;
	fbTRIG_PhaseRestore_end: R_TRIG;
	fbTRIG_PhaseRead_end: R_TRIG;
	
	fbTRIG_PreStart: R_TRIG;
	fbTRIG_Tension: R_TRIG;
	fbTRIG_Tension_End: R_TRIG;
	fbTRIG_Ink: R_TRIG;
	fbTRIG_Print: R_TRIG;
	fbTRIG_AllInch: R_TRIG;
	fbTRIG_AllInchDone: R_TRIG;
	fbTRIG_Stop: R_TRIG;
	fbTRIG_Estop: R_TRIG;
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	
	dwRtn : DWORD;
	iRtn : INT;
	astStSetPrm_Pre				: ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	stStGetPrm				: TMultiMcFunctionReadPrm;
	iMaxRetryTimes: INT := 5;
	aiRetryCount: ARRAY [1..MAX_STATION_NUM] OF INT := [0];
	iWaitedCycleCount: INT := 0;
	xForceAxisOff: BOOL;(*强制下伺服标志*)
	xFlag_AllInchRun_ing: BOOL;
	iMotionModePrn : INT;//版辊运动模式
						//0、电子齿轮
						//1、点位 --恢复相位等
						//2、Jog模式
	astStTStGearParam: ARRAY [1..MAX_STATION_NUM] OF TStGearParam;
	fbKS_FB_SyncAxisParam : KS_FB_SyncAxisParam;
	iAxisId_Master : INT := 64;//虚拟主轴轴号
	xKeepServo: BOOL;//保持伺服标志
		
	fbKS_FB_AxisEnCtl: KS_FB_AxisEnCtl;
	fbKS_FB_AxisModeCtl: KS_FB_AxisModeCtl;
	fbKS_FB_AxisVelCtl: KS_FB_AxisVelCtl;
	afbTRIG_Start_Servo: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	afbTRIG_Stop_Servo: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	fbKS_FB_McMultiFunCtl: KS_FB_McMultiFunCtl;
	//fbKS_FB_AxisInchCtl: KS_FB_AxisInchCtl;
	fbKS_FB_AxisTrapPosCtl: KS_FB_AxisTrapPosCtl;
	axServoOn: ARRAY [1..MAX_STATION_NUM] OF BOOL;
	
	iN: INT;
	lrTemp: LREAL;
	iAxisId_T: INT;
	iCoreId_T: INT;
	iTypeId_T: INT;
	iUnitId_T: INT;
	iGroupId_T : INT;
	
	lrVel_Pos_Temp: LREAL;
	diTemp: DINT;
	
	diVel_Virtual_Tar_Inch : DINT;
	lrMax_a_S_pos_Inch : LREAL;
	xAxisInching : BOOL;
	afbTRIG_AxisInching: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbTRIG_AxisInchingDone: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	
	//2025.10.28.140624 | bai.zy | 单运行的轴速度先单独拿出来
	arInchTarVel: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	
	aiWaitingModalChange : ARRAY [1..MAX_STATION_NUM] OF INT;
	
	iAdjAxisId_T : INT;
	
	xMasterType : BOOL;//true=跟随同一个核的轴；FALSE=跟随另一个核的轴
	
	axRecalcAccelerationFilmAcc:ARRAY[1..MAX_STATION_NUM] OF BOOL;
	axRecalcAccelerationFilmDec:ARRAY[1..MAX_STATION_NUM] OF BOOL;
	abyWatch:ARRAY[1..MAX_STATION_NUM] OF BYTE;
	
	afbTRIG_UwRwEn: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	afbTRIG_UwRwEnDn: ARRAY [1..MAX_STATION_NUM] OF R_TRIG;
	
	xFlag_UwRw_Tension : BOOL;
	
	iInchRollerType : INT;
	afbInk_Unit_Net: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbUnInk_Unit_Net: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbInk_Unit_Bottom: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbUnInk_Unit_Bottom: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	
	//fbKS_FB_AxisInchCtl_Net: KS_FB_AxisInchCtl_Net;
	fbKS_FB_AxisInchCtl_All: KS_FB_AxisInchCtl_All;
	diVel_Virtual_Tar_Inch_Net: DINT;
	lrMax_a_S_pos_Inch_Net: LREAL;
	rVelTemp: REAL;
	//2026.1.20.105520 | + | 对所有运动轴的运动模式进行初始化
	xInitAxisMotionMode : BOOL;
	
	aiCntAxisOn : ARRAY [1..MAX_STATION_NUM] OF INT;
	axFlgAxisOn : ARRAY [1..MAX_STATION_NUM] OF BOOL;
	
	afbInk_Unit_If: R_TRIG;
	afbUnInk_Unit_If: R_TRIG;
	afbInk_Unit_Of: R_TRIG;
	afbUnInk_Unit_Of: R_TRIG;
	
	axAxisInching_Prn : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisInchDecing_Prn : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	arVelTemp_Prn : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	axAxisInching_Net : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisInchDecing_Net : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	arVelTemp_Net : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	axAxisInching_Bottom : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisInchDecing_Bottom : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	arVelTemp_Bottom : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	
	xAxisInching_Of : BOOL;
	xAxisInchDecing_Of : BOOL;
	rVelTemp_Of : REAL;
	xAxisInching_If : BOOL;
	xAxisInchDecing_If : BOOL;
	rVelTemp_If : REAL;
	
	xInchDecing : BOOL;
	
	rAcc_Inch : REAL := 0.2;

	//2026.4.27.221019留有速度备份
	arVel_Pre: ARRAY [1..MAX_STATION_NUM] OF REAL;
	rTemp_Vel_UwRw: REAL;
	udiMax_Acc: UDINT;
	diTarget_Vel: DINT;	
	//TEST
	axAxisONBegin : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisONING : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	atAxisOnBeginTime : ARRAY [1..MAX_UNIT_NUM] OF TIME;
	atAxisOnUseTime : ARRAY [1..MAX_UNIT_NUM] OF TIME;	
	
	//test by lyt
	iCheckCnt:int:=100;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam<>0 AND i_pastStAxisIdListInf<>0 AND i_pastStSetPrm <> 0 AND i_pastStGetMotionSts <> 0 AND
		i_pstStGetPrm <> 0 AND i_pastStMotorParam_Vel <> 0 AND i_pstStHYLogFifo <> 0 AND i_pastStIOMap_Main_FE <> 0 AND i_pastStIOMap_Axis_FE <> 0 AND
		i_padiPreRegisterPos <> 0 AND i_palrMaxVel_PreReg <> 0 AND i_pstStSysStationInf <>0 THEN
				
(*这里作为同步使能、速度等参数*)
		
		fbKS_FB_SyncAxisParam(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpGearMotion_Num:= i_iGrpGearMotion_Num, 
			i_aiGrpGearMotion_StdList:= i_aiGrpGearMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_rVel_VirtualMotion:= i_rVel_VirtualMotion, 
			i_pastStMotorParam_Vel:= i_pastStMotorParam_Vel
		);
// 		fbKS_FB_AxisInchCtl(
// 			i_xEn:= TRUE, 
// 			i_iGrpId:= i_iGrpId, 
// 			i_iGrpAxisNum_Pu:= i_iGrpUnitNum_Pu, 
// 			i_aiGrpAxisList:= i_aiGrpUnitList, 
// 			i_pstStSysParam:= i_pstStSysParam, 
// 			i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE, 
// 			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE, 
// 			i_pstStEvtReq:= i_pstStEvtReq, 
// 			i_xAllLinkageAxis_Inch:= , 
// 			o_xEno=> , 
// 			o_iErNo=> , 
// 			o_xHasAxisOnInchRunningSts=> , 
// 			o_diVel_Virtual_Tar_Inch=> diVel_Virtual_Tar_Inch, 
// 			o_lrMax_a_S_pos_Inch=> lrMax_a_S_pos_Inch,
// 			o_arInchTarVel=>arInchTarVel 
// 		);
// 		fbKS_FB_AxisInchCtl_Net(
// 			i_xEn:= TRUE, 
// 			i_iGrpId:= i_iGrpId, 
// 			i_iGrpAxisNum_Pu:= i_iGrpUnitNum_Pu, 
// 			i_aiGrpAxisList:= i_aiGrpUnitList, 
// 			i_pstStSysParam:= i_pstStSysParam, 
// 			i_pstStEvtReq:= i_pstStEvtReq, 
// 			o_xEno=> , 
// 			o_iErNo=> , 
// 			o_xHasAxisOnInchRunningSts=> , 
// 			o_diVel_Virtual_Tar_Inch=> diVel_Virtual_Tar_Inch_Net, 
// 			o_lrMax_a_S_pos_Inch=> lrMax_a_S_pos_Inch_Net, 
// 			o_arInchTarVel=> 
// 		);

		fbKS_FB_AxisInchCtl_All(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpAxisNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpAxisList:= i_aiGrpUnitList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pstStEvtReq:= i_pstStEvtReq, 
			i_pastStIOMap_Axis_FE := i_pastStIOMap_Axis_FE,
			i_rAcc_Inch := rAcc_Inch,
			o_xEno=> , 
			o_iErNo=> , 
			o_xHasAxisOnInchRunningSts=> , 
			o_diVel_Virtual_Tar_Inch=> diVel_Virtual_Tar_Inch, 
			o_lrMax_a_S_pos_Inch=> lrMax_a_S_pos_Inch, 
			o_arInchTarVel=> ,
			o_xInchDecing => xInchDecing
		);


		fbKS_FB_AxisTrapPosCtl(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpAxisNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pawAxisVirtualCnt:= i_pawAxisVirtualCnt, 
			i_pawAxisVirtualSts:= i_pawAxisVirtualSts, 
			i_diTime_PreReg:= 5000, 
			i_padiPreRegisterPos:= i_padiPreRegisterPos, 
			i_palrMaxVel_PreReg:= i_palrMaxVel_PreReg, 
			i_pastStGetMotionSts:=i_pastStGetMotionSts,
			i_pstStSysStationInf:=i_pstStSysStationInf,
			o_xEn=> );	
		fbKS_FB_AxisEnCtl(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpGearMotion_Num:= i_iGrpGearMotion_Num, 
			i_aiGrpGearMotion_StdList:= i_aiGrpGearMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_pastStMotorParam_Vel:= i_pastStMotorParam_Vel, 
			i_pstStSysStationInf:=i_pstStSysStationInf,
			o_iAxisId_Master=> iAxisId_Master
		);	
		fbKS_FB_AxisModeCtl(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpGearMotion_Num:= i_iGrpGearMotion_Num, 
			i_aiGrpGearMotion_StdList:= i_aiGrpGearMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_pastStMotorParam_Vel:= i_pastStMotorParam_Vel,
			i_pstStSysStationInf:=i_pstStSysStationInf
		);	
		fbKS_FB_AxisVelCtl(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpGearMotion_Num:= i_iGrpGearMotion_Num, 
			i_aiGrpGearMotion_StdList:= i_aiGrpGearMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_pastStMotorParam_Vel:= i_pastStMotorParam_Vel,
			i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE,
			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE,
			i_xMotionEnabled := io_xMotionEnabled,
			i_pstStSysStationInf:=i_pstStSysStationInf,

			//2026.5.9.220642
			i_paxFlag_PressDne:= i_paxFlag_PressDne,
			i_rVel_A:= i_rVel_A,
			i_rVel_Jerk:= i_rVel_Jerk
		);

		
		xAxisInching := FALSE;
		
		//2025.11.26.160547 | bai.zy  | TEST_
		IF i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.1 OR i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.2 THEN
			iAxisId_Master := 64;
		ELSIF i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.3 THEN
			iAxisId_Master := 32;
		END_IF
		
		o_iAxisId_Master:= iAxisId_Master;
		pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		//2025.10.27.130955 | bai.zy| TEST_
		fbTRIG_PreStart(CLK:=pstStGrpParam_UnSave^.xFlag_PreStart);
		fbTRIG_Print(CLK:=pstStGrpParam_UnSave^.xFlag_Print);
		fbTRIG_AllInch(CLK:=pstStGrpParam_UnSave^.xFlag_AllInchRun);
		fbTRIG_AllInchDone(CLK:=(NOT pstStGrpParam_UnSave^.xFlag_AllInchRun) AND (ABS(o_lrVel_VirtualAxis) < 100) AND pstStGrpParam_UnSave^.xFlag_Stop);
		fbTRIG_Stop(CLK:=pstStGrpParam_UnSave^.xFlag_Stop);
		fbTRIG_Estop(CLK:=pstStGrpParam_UnSave^.xFlag_EStop);
		fbTRIG_Tension(CLK:=pstStGrpParam_UnSave^.xFlag_Tension);
		fbTRIG_Tension_End(CLK:=NOT pstStGrpParam_UnSave^.xFlag_Tension);
		fbTRIG_Ink(CLK:= (pstStGrpParam_UnSave^.xFlag_Ink));

		fbTRIG_Home(CLK:=pstStGrpParam_UnSave^.xFlag_Home);// R_TRIG;
		fbTRIG_PreRegister(CLK:=pstStGrpParam_UnSave^.xFlag_PreRegister);// R_TRIG;
		fbTRIG_PhaseRestore(CLK:=pstStGrpParam_UnSave^.xFlag_PhaseRestore);// R_TRIG;
		fbTRIG_PhaseRead(CLK:= pstStGrpParam_UnSave^.xFlag_PhaseRead);// R_TRIG;
	
		fbTRIG_Home_end(CLK:=(NOT pstStGrpParam_UnSave^.xFlag_Home) AND pstStGrpParam_UnSave^.xFlag_Stop);// R_TRIG;
		fbTRIG_PreRegister_end(CLK:=(NOT pstStGrpParam_UnSave^.xFlag_PreRegister) AND pstStGrpParam_UnSave^.xFlag_Stop);// R_TRIG;
		fbTRIG_PhaseRestore_end(CLK:=(NOT pstStGrpParam_UnSave^.xFlag_PhaseRestore) AND pstStGrpParam_UnSave^.xFlag_Stop);// R_TRIG;
		fbTRIG_PhaseRead_end(CLK:=(NOT pstStGrpParam_UnSave^.xFlag_PhaseRead) AND pstStGrpParam_UnSave^.xFlag_Stop);// R_TRIG;
		
		
		FOR iN:=1 TO i_iGrpGearMotion_Num BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_aiGrpGearMotion_StdList[iN],
// 				ADR(iAxisId_T),
// 				ADR(iTypeId_T),
// 				ADR(iUnitId_T),
// 				ADR(iCoreId_T),
// 				ADR(iGroupId_T),
// 				ADR(iAdjAxisId_T),
// 				i_pastStAxisIdListInf);	
			KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiGrpGearMotion_StdList[iN],
					i_piAxisId:= ADR(iAxisId_T), 
					i_piTypeId:= ADR(iTypeId_T), 
					i_piUnitId:= ADR(iUnitId_T), 
					i_piCoreId:= ADR(iCoreId_T), 
					i_piGroupId:= ADR(iGroupId_T), 
					i_piAdjAxisId:= ADR(iAdjAxisId_T), 
					i_pstStSysStationInf:= i_pstStSysStationInf);
			
			//2026.01.31.130843 | + | 秦华有停机维持伺服的功能，需要增加一个判断是否是使能状态的标志		
			i_pastStMotorParam_Vel^[iN].xAxisOn_ing := i_pastStGetMotionSts^[iAxisId_T].dwMotionSts.9 (*AND i_pastStGetMotionSts^[iAxisId_T].dwDriverSts.1*);
			
			IF fbTRIG_PreStart.Q OR fbTRIG_Ink.Q OR fbTRIG_Print.Q OR fbTRIG_AllInch.Q (*OR fbTRIG_Tension.Q*) OR
					fbTRIG_Home.Q OR fbTRIG_PreRegister.Q OR fbTRIG_PhaseRestore.Q OR fbTRIG_PhaseRead.Q THEN
				IF iTypeId_T = TYPE_UNWIND_A_I OR iTypeId_T = TYPE_UNWIND_A_II OR
					iTypeId_T = TYPE_UNWIND_B_I OR iTypeId_T = TYPE_UNWIND_B_II OR
					iTypeId_T = TYPE_REWIND_A_I OR iTypeId_T = TYPE_REWIND_A_II OR
					iTypeId_T = TYPE_REWIND_B_I OR iTypeId_T = TYPE_REWIND_B_II  THEN
					;
				ELSE
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
					ELSE;
					END_IF
				END_IF
				IF pstStGrpParam_UnSave^.xFlag_Home OR pstStGrpParam_UnSave^.xFlag_PreRegister OR pstStGrpParam_UnSave^.xFlag_PhaseRestore OR pstStGrpParam_UnSave^.xFlag_PhaseRead THEN
					i_pastStMotorParam_Vel^[iN].liTargetPos := i_padiPreRegisterPos^[iN];
					i_pastStMotorParam_Vel^[iN].udiTargetVel := LREAL_TO_UDINT(i_palrMaxVel_PreReg^[iN]+0.5);
				END_IF
			END_IF
			IF fbTRIG_Stop.Q (*OR fbTRIG_Estop.Q*) OR fbTRIG_AllInchDone.Q OR fbTRIG_Home_end.Q OR fbTRIG_PreRegister_end.Q OR fbTRIG_PhaseRestore_end.Q OR fbTRIG_PhaseRead_end.Q THEN
				IF iTypeId_T = TYPE_UNWIND_A_I OR iTypeId_T = TYPE_UNWIND_A_II OR
					iTypeId_T = TYPE_UNWIND_B_I OR iTypeId_T = TYPE_UNWIND_B_II OR
					iTypeId_T = TYPE_REWIND_A_I OR iTypeId_T = TYPE_REWIND_A_II OR
					iTypeId_T = TYPE_REWIND_B_I OR iTypeId_T = TYPE_REWIND_B_II  THEN
					;
				ELSE
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
						i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
						;
					ELSE
						//2026.03.11.144211 | 增加停机维持伺服功能|
						//2026.07.30.113643 | + | 欧诺绍兴机进行强制修改版辊
						IF pstStGrpParam_Save^.dwExtBitCtlFlag.21 AND iTypeId_T = TYPE_UNIT_PRN THEN
							IF i_pastStMotorParam_Vel^[iN].xAxisInching THEN
								;
							ELSE
								i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
							END_IF
							//i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
						ELSE
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						END_IF
					END_IF
				END_IF
			END_IF
			
			IF fbTRIG_Estop.Q THEN
				IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
					i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
					;
				ELSE
					i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
				END_IF
			END_IF
			
//2026.02.27.093638 | + | 版辊单运行 			
			IF iTypeId_T = TYPE_UNIT_PRN THEN
				i_pastStMotorParam_Vel^[iN].xAxisInching := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching;
				afbTRIG_AxisInching[iUnitId_T](CLK:=i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching);
				afbTRIG_AxisInchingDone[iUnitId_T](CLK:=(NOT i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching)  AND (ABS(o_lrVel_VirtualAxis) < 100) AND pstStGrpParam_UnSave^.xFlag_Stop);

				IF afbTRIG_AxisInching[iUnitId_T].Q THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
					ELSE;
					END_IF
				END_IF
				IF afbTRIG_AxisInchingDone[iUnitId_T].Q  THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
						i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
						;
					ELSE
						//2026.03.11.144211 | 增加停机维持伺服功能|
						IF pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
						ELSE
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						END_IF
					END_IF
				END_IF

				IF (NOT axAxisInching_Prn[iUnitId_T]) AND i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching THEN
					axAxisInchDecing_Prn[iUnitId_T] := TRUE;
				END_IF
				axAxisInching_Prn[iUnitId_T] := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching;
				
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching THEN
					rVelTemp := o_lrVel_VirtualAxis * gc_rGirth_Master * 1000 * 60 /GC_LRMOTORPPR;
					IF (o_lrVel_VirtualAxis > (diVel_Virtual_Tar_Inch-0.5)) AND (o_lrVel_VirtualAxis < (diVel_Virtual_Tar_Inch+0.5)) THEN
						arVelTemp_Prn[iUnitId_T] := arVelTemp_Prn[iUnitId_T] + rAcc_Inch;
						//2026.03.16.171137 | + | 增加单运行方向判断
						IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel:=-arVelTemp_Prn[iUnitId_T];
							IF i_pastStMotorParam_Vel^[iN].rAxisVel < -rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
								arVelTemp_Prn[iUnitId_T] := rVelTemp;
							END_IF
						ELSE
							i_pastStMotorParam_Vel^[iN].rAxisVel:=arVelTemp_Prn[iUnitId_T];
							IF i_pastStMotorParam_Vel^[iN].rAxisVel > rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
								arVelTemp_Prn[iUnitId_T] := rVelTemp;
							END_IF
						END_IF
						//i_pastStMotorParam_Vel^[iN].rAxisVel:=arVelTemp_Prn[iUnitId_T];
// 						IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) > rVelTemp THEN
// 							//2026.03.16.171137 | + | 增加单运行方向判断
// 							IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
// 							ELSE
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
// 							END_IF
// 							arVelTemp_Prn[iUnitId_T] := rVelTemp;
// 						END_IF
					ELSIF (NOT axAxisInching_Prn[iUnitId_T]) THEN
						arVelTemp_Prn[iUnitId_T] := 0;
					END_IF
				END_IF
				IF (NOT i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching) AND axAxisInchDecing_Prn[iUnitId_T] THEN
					arVelTemp_Prn[iUnitId_T] := arVelTemp_Prn[iUnitId_T] - rAcc_Inch;
					//2026.03.16.171137 | + | 增加单运行方向判断
					IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
						i_pastStMotorParam_Vel^[iN].rAxisVel := -arVelTemp_Prn[iUnitId_T];
						IF i_pastStMotorParam_Vel^[iN].rAxisVel >0 THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							arVelTemp_Prn[iUnitId_T] := 0;
							axAxisInchDecing_Prn[iUnitId_T] := FALSE;
						END_IF
					ELSE
						i_pastStMotorParam_Vel^[iN].rAxisVel := arVelTemp_Prn[iUnitId_T];
						IF i_pastStMotorParam_Vel^[iN].rAxisVel < 0  THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							arVelTemp_Prn[iUnitId_T] := 0;
							axAxisInchDecing_Prn[iUnitId_T] := FALSE;
						END_IF
					END_IF
					
// 					IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) < 0 THEN
// 						i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
// 						arVelTemp_Prn[iUnitId_T] := 0;
// 						axAxisInchDecing_Prn[iUnitId_T] := FALSE;
// 					END_IF
				END_IF
			END_IF
						
//2026.02.06.212145匀墨功能测试；
			IF iTypeId_T = TYPE_UNIT_NET THEN
				i_pastStMotorParam_Vel^[iN].xAxisInching := i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xSwitch_GrpInkEn AND i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xSwitch_Inching_Net;
				afbInk_Unit_Net[iUnitId_T](CLK:=i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_NetRoller);
				afbUnInk_Unit_Net[iUnitId_T](CLK:=(NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_NetRoller)  AND (ABS(o_lrVel_VirtualAxis) < 100) AND pstStGrpParam_UnSave^.xFlag_Stop);

				//2026.02.27.093638 | + | 网辊单运行
				IF afbInk_Unit_Net[iUnitId_T].Q THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep = MOTION_STEP_Nothing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
					ELSE;
					END_IF
				END_IF
				IF afbUnInk_Unit_Net[iUnitId_T].Q  THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
						i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
						;
					ELSE
						//2026.03.11.144211 | 增加停机维持伺服功能|
						IF pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
						ELSE
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						END_IF
					END_IF
				END_IF
				
				IF (NOT axAxisInching_Net[iUnitId_T]) AND i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_NetRoller THEN
					axAxisInchDecing_Net[iUnitId_T] := TRUE;
				END_IF
				axAxisInching_Net[iUnitId_T] := i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_NetRoller;
				
				IF i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_NetRoller THEN
					rVelTemp := o_lrVel_VirtualAxis * gc_rGirth_Master * 1000 * 60 /GC_LRMOTORPPR;
					IF (o_lrVel_VirtualAxis > (diVel_Virtual_Tar_Inch-0.5)) AND (o_lrVel_VirtualAxis < (diVel_Virtual_Tar_Inch+0.5)) THEN
						arVelTemp_Net[iUnitId_T] := arVelTemp_Net[iUnitId_T] + rAcc_Inch;
						//2026.03.16.171137 | + | 增加单运行方向判断
						IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel:=-arVelTemp_Net[iUnitId_T];
							IF i_pastStMotorParam_Vel^[iN].rAxisVel < -rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
								arVelTemp_Net[iUnitId_T] := rVelTemp;
							END_IF
						ELSE
							i_pastStMotorParam_Vel^[iN].rAxisVel:=arVelTemp_Net[iUnitId_T];
							IF i_pastStMotorParam_Vel^[iN].rAxisVel > rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
								arVelTemp_Net[iUnitId_T] := rVelTemp;
							END_IF
						END_IF
// 						IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) > rVelTemp THEN
// 							//2026.03.16.171137 | + | 增加单运行方向判断
// 							IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
// 							ELSE
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
// 							END_IF
// 							arVelTemp_Net[iUnitId_T] := rVelTemp;
// 						END_IF
					ELSIF (NOT axAxisInching_Net[iUnitId_T]) THEN
						arVelTemp_Net[iUnitId_T] := 0;
					END_IF
				END_IF
				IF (NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_NetRoller) AND axAxisInchDecing_Net[iUnitId_T] THEN
					arVelTemp_Net[iUnitId_T] := arVelTemp_Net[iUnitId_T] - rAcc_Inch;
					//2026.03.16.171137 | + | 增加单运行方向判断
					IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
						i_pastStMotorParam_Vel^[iN].rAxisVel:=-arVelTemp_Net[iUnitId_T];
						IF i_pastStMotorParam_Vel^[iN].rAxisVel >0 THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							arVelTemp_Net[iUnitId_T] := 0;
							axAxisInchDecing_Net[iUnitId_T] := FALSE;
						END_IF
					ELSE
						i_pastStMotorParam_Vel^[iN].rAxisVel:=arVelTemp_Net[iUnitId_T];
						IF i_pastStMotorParam_Vel^[iN].rAxisVel < 0  THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							arVelTemp_Net[iUnitId_T] := 0;
							axAxisInchDecing_Net[iUnitId_T] := FALSE;
						END_IF
					END_IF
// 					IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) > 0 THEN
// 						i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
// 						arVelTemp_Net[iUnitId_T] := 0;
// 						axAxisInchDecing_Net[iUnitId_T] := FALSE;
// 					END_IF
				END_IF
			END_IF
//2026.02.27.093638 | + | 底辊单运行 			
			IF iTypeId_T = TYPE_UNIT_BOTTOM THEN
				i_pastStMotorParam_Vel^[iN].xAxisInching := i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller;
				afbInk_Unit_Bottom[iUnitId_T](CLK:=i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller);
				afbUnInk_Unit_Bottom[iUnitId_T](CLK:=(NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller)  AND (ABS(o_lrVel_VirtualAxis) < 100) AND pstStGrpParam_UnSave^.xFlag_Stop);
				//2026.02.27.093638 | + | 底辊单运行
				IF afbInk_Unit_Bottom[iUnitId_T].Q THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
					ELSE;
					END_IF
				END_IF
				IF afbUnInk_Unit_Bottom[iUnitId_T].Q  THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
						i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
						;
					ELSE
						//2026.03.11.144211 | 增加停机维持伺服功能|
						IF pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
						ELSE
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						END_IF
					END_IF
				END_IF
				
				IF (NOT axAxisInching_Bottom[iUnitId_T]) AND i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller THEN
					axAxisInchDecing_Bottom[iUnitId_T] := TRUE;
				END_IF
				axAxisInching_Bottom[iUnitId_T] := i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller;
				
				IF i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller THEN
					rVelTemp := o_lrVel_VirtualAxis * gc_rGirth_Master * 1000 * 60 /GC_LRMOTORPPR;
					IF (o_lrVel_VirtualAxis > (diVel_Virtual_Tar_Inch-0.5)) AND (o_lrVel_VirtualAxis < (diVel_Virtual_Tar_Inch+0.5)) THEN
						arVelTemp_Bottom[iUnitId_T] := arVelTemp_Bottom[iUnitId_T] + rAcc_Inch;
						//2026.03.16.171137 | + | 增加单运行方向判断
						IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel:=-arVelTemp_Bottom[iUnitId_T];
							IF i_pastStMotorParam_Vel^[iN].rAxisVel < -rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
								arVelTemp_Bottom[iUnitId_T] := rVelTemp;
							END_IF
						ELSE
							i_pastStMotorParam_Vel^[iN].rAxisVel:=arVelTemp_Bottom[iUnitId_T];
							IF i_pastStMotorParam_Vel^[iN].rAxisVel > rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
								arVelTemp_Bottom[iUnitId_T] := rVelTemp;
							END_IF
						END_IF
// 						IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) > rVelTemp THEN
// 							//2026.03.16.171137 | + | 增加单运行方向判断
// 							IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
// 							ELSE
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
// 							END_IF
// 							arVelTemp_Bottom[iUnitId_T] := rVelTemp;
// 						END_IF
					ELSIF (NOT axAxisInching_Bottom[iUnitId_T]) THEN
						arVelTemp_Bottom[iUnitId_T] := 0;
					END_IF
				END_IF
				IF (NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller) AND axAxisInchDecing_Bottom[iUnitId_T] THEN
					arVelTemp_Bottom[iUnitId_T] := arVelTemp_Bottom[iUnitId_T] - rAcc_Inch;
					//2026.03.16.171137 | + | 增加单运行方向判断
					IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
						i_pastStMotorParam_Vel^[iN].rAxisVel:=-arVelTemp_Bottom[iUnitId_T];
						IF i_pastStMotorParam_Vel^[iN].rAxisVel >0 THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							arVelTemp_Bottom[iUnitId_T] := 0;
							axAxisInchDecing_Bottom[iUnitId_T] := FALSE;
						END_IF
					ELSE
						i_pastStMotorParam_Vel^[iN].rAxisVel:=arVelTemp_Bottom[iUnitId_T];
						IF i_pastStMotorParam_Vel^[iN].rAxisVel < 0  THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							arVelTemp_Bottom[iUnitId_T] := 0;
							axAxisInchDecing_Bottom[iUnitId_T] := FALSE;
						END_IF
					END_IF
// 					IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) < 0 THEN
// 						i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
// 						arVelTemp_Bottom[iUnitId_T] := 0;
// 						axAxisInchDecing_Bottom[iUnitId_T] := FALSE;
// 					END_IF
				END_IF
			END_IF
			
			//2026.03.11.153617 | + | 增加牵引单运行
			IF iTypeId_T = TYPE_INFEED_I OR iTypeId_T = TYPE_INFEED_II THEN
				i_pastStMotorParam_Vel^[iN].xAxisInching := i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller;
				afbInk_Unit_If(CLK:=i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller);
				afbUnInk_Unit_If(CLK:=(NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller)  AND (ABS(o_lrVel_VirtualAxis) < 100) AND pstStGrpParam_UnSave^.xFlag_Stop);
				
				IF afbInk_Unit_If.Q THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
					ELSE;
					END_IF
				END_IF
				IF afbUnInk_Unit_If.Q  THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
						i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
						;
					ELSE
						//2026.03.11.144211 | 增加停机维持伺服功能|
						IF pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
						ELSE
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						END_IF
					END_IF
				END_IF
				
				IF (NOT xAxisInching_If) AND i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller THEN
					xAxisInchDecing_If := TRUE;
				END_IF
				xAxisInching_If := i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller;
				
				IF i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller THEN
					rVelTemp := o_lrVel_VirtualAxis * gc_rGirth_Master * 1000 * 60 /GC_LRMOTORPPR;
					IF (o_lrVel_VirtualAxis > (diVel_Virtual_Tar_Inch-0.5)) AND (o_lrVel_VirtualAxis < (diVel_Virtual_Tar_Inch+0.5)) THEN
						rVelTemp_If := rVelTemp_If + rAcc_Inch;
						//2026.03.16.171137 | + | 增加单运行方向判断
						IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel:=-rVelTemp_If;
							IF i_pastStMotorParam_Vel^[iN].rAxisVel < -rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
								rVelTemp_If := rVelTemp;
							END_IF
						ELSE
							i_pastStMotorParam_Vel^[iN].rAxisVel:=rVelTemp_If;
							IF i_pastStMotorParam_Vel^[iN].rAxisVel > rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
								rVelTemp_If := rVelTemp;
							END_IF
						END_IF
						
// 						IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) > rVelTemp THEN
// 							//2026.03.16.171137 | + | 增加单运行方向判断
// 							IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
// 							ELSE
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
// 							END_IF
// 							rVelTemp_If := rVelTemp;
// 						END_IF
					ELSIF (NOT xAxisInching_If) THEN
						rVelTemp_If := 0;
					END_IF
				END_IF
				IF (NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller) AND xAxisInchDecing_If THEN
					rVelTemp_If := rVelTemp_If - rAcc_Inch;
					//2026.03.16.171137 | + | 增加单运行方向判断
					IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
						i_pastStMotorParam_Vel^[iN].rAxisVel:=-rVelTemp_If;
						IF i_pastStMotorParam_Vel^[iN].rAxisVel >0 THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							rVelTemp_If := 0;
							xAxisInchDecing_If := FALSE;
						END_IF
					ELSE
						i_pastStMotorParam_Vel^[iN].rAxisVel:=rVelTemp_If;
						IF i_pastStMotorParam_Vel^[iN].rAxisVel < 0  THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							rVelTemp_If := 0;
							xAxisInchDecing_If := FALSE;
						END_IF
					END_IF
// 					IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) < 0 THEN
// 						i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
// 						rVelTemp_If := 0;
// 						xAxisInchDecing_If := FALSE;
// 					END_IF
				END_IF
			END_IF
			
			
			IF iTypeId_T = TYPE_OUTFEED_I OR iTypeId_T = TYPE_OUTFEED_II THEN
				i_pastStMotorParam_Vel^[iN].xAxisInching := i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller;
				afbInk_Unit_Of(CLK:=i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller);
				afbUnInk_Unit_Of(CLK:=(NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller)  AND (ABS(o_lrVel_VirtualAxis) < 100) AND pstStGrpParam_UnSave^.xFlag_Stop);
				
				IF afbInk_Unit_Of.Q THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
					ELSE;
					END_IF
				END_IF
				IF afbUnInk_Unit_Of.Q  THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
						i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_AXISOFF THEN
						;
					ELSE
						//2026.03.11.144211 | 增加停机维持伺服功能|
						IF pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
						ELSE
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						END_IF
					END_IF
				END_IF
				
// 				IF i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller AND (iTypeId_T = TYPE_OUTFEED_I OR iTypeId_T = TYPE_OUTFEED_II) THEN
// 					rVelTemp := o_lrVel_VirtualAxis * gc_rGirth_Master * 1000 * 60 /GC_LRMOTORPPR;
// 					i_pastStMotorParam_Vel^[iN].rAxisVel:=rVelTemp;
// 				END_IF
				
				IF (NOT xAxisInching_Of) AND i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller THEN
					xAxisInchDecing_Of := TRUE;
				END_IF
				xAxisInching_Of := i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller;
				
				IF i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller THEN
					rVelTemp := o_lrVel_VirtualAxis * gc_rGirth_Master * 1000 * 60 /GC_LRMOTORPPR;
					IF (o_lrVel_VirtualAxis > (diVel_Virtual_Tar_Inch-0.5)) AND (o_lrVel_VirtualAxis < (diVel_Virtual_Tar_Inch+0.5)) THEN
						rVelTemp_Of := rVelTemp_Of + rAcc_Inch;
						//2026.03.16.171137 | + | 增加单运行方向判断
						IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel:=-rVelTemp_Of;
							IF i_pastStMotorParam_Vel^[iN].rAxisVel < -rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
								rVelTemp_Of := rVelTemp;
							END_IF
						ELSE
							i_pastStMotorParam_Vel^[iN].rAxisVel:=rVelTemp_Of;
							IF i_pastStMotorParam_Vel^[iN].rAxisVel > rVelTemp THEN
								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
								rVelTemp_Of := rVelTemp;
							END_IF
						END_IF
						
// 						IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) > rVelTemp THEN
// 							//2026.03.16.171137 | + | 增加单运行方向判断
// 							IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := -rVelTemp;
// 							ELSE
// 								i_pastStMotorParam_Vel^[iN].rAxisVel := rVelTemp;
// 							END_IF
// 							rVelTemp_Of := rVelTemp;
// 						END_IF
					ELSIF (NOT xAxisInching_Of) THEN
						rVelTemp_Of := 0;
					END_IF
				END_IF
				IF (NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller) AND xAxisInchDecing_Of THEN
					rVelTemp_Of := rVelTemp_Of - rAcc_Inch;
					//2026.03.16.171137 | + | 增加单运行方向判断
					IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
						i_pastStMotorParam_Vel^[iN].rAxisVel:=-rVelTemp_Of;
						IF i_pastStMotorParam_Vel^[iN].rAxisVel >0 THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							rVelTemp_Of := 0;
							xAxisInchDecing_Of := FALSE;
						END_IF
					ELSE
						i_pastStMotorParam_Vel^[iN].rAxisVel:=rVelTemp_Of;
						IF i_pastStMotorParam_Vel^[iN].rAxisVel < 0  THEN
							i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
							rVelTemp_Of := 0;
							xAxisInchDecing_Of := FALSE;
						END_IF
					END_IF
// 					IF ABS(i_pastStMotorParam_Vel^[iN].rAxisVel) < 0 THEN
// 						i_pastStMotorParam_Vel^[iN].rAxisVel := 0;
// 						rVelTemp_Of := 0;
// 						xAxisInchDecing_Of := FALSE;
// 					END_IF
				END_IF
			END_IF
			
			
			IF iAxisId_Master = 32 AND
				(iTypeId_T = TYPE_INFEED_I OR iTypeId_T = TYPE_INFEED_II OR
					iTypeId_T = TYPE_OUTFEED_I OR iTypeId_T = TYPE_OUTFEED_II OR 
					iTypeId_T = TYPE_UNWIND_A_I OR iTypeId_T = TYPE_UNWIND_A_II OR
					iTypeId_T = TYPE_UNWIND_B_I OR iTypeId_T = TYPE_UNWIND_B_II OR
					iTypeId_T = TYPE_REWIND_A_I OR iTypeId_T = TYPE_REWIND_A_II OR
					iTypeId_T = TYPE_REWIND_B_I OR iTypeId_T = TYPE_REWIND_B_II ) THEN
				xMasterType := TRUE;
			ELSE
				xMasterType := FALSE;
			END_IF
			
			IF iTypeId_T = TYPE_UNWIND_A_I OR iTypeId_T = TYPE_UNWIND_A_II OR
				iTypeId_T = TYPE_UNWIND_B_I OR iTypeId_T = TYPE_UNWIND_B_II OR
				iTypeId_T = TYPE_REWIND_A_I OR iTypeId_T = TYPE_REWIND_A_II OR
				iTypeId_T = TYPE_REWIND_B_I OR iTypeId_T = TYPE_REWIND_B_II (*OR
				iTypeId_T = TYPE_UNIT_BOTTOM *) THEN
				
				IF fbTRIG_Tension.Q  THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing OR
						i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_WRITEDATA_Jog THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE(*MOTIONCTL_STEP_AXISON*);
					ELSE;
					END_IF
				END_IF
				
				IF fbTRIG_Tension_end.Q  THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTIONCTL_STEP_WRITEDATA_Jog THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOff;
					ELSE;
						//2026.03.11.144211 | 增加停机维持伺服功能|
						IF pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
						ELSE
							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						END_IF
					END_IF
					

				END_IF
(*				

				//收放料点动
				afbTRIG_UwRwEn[iN](CLK:= i_pastStMotorParam_Vel^[iN].xMoveEn AND (NOT pstStGrpParam_UnSave^.xFlag_Tension));
				//afbTRIG_UwRwEnDn[iN](CLK:=NOT (i_pastStMotorParam_Vel^[iN].xMoveEn AND pstStGrpParam_UnSave^.xFlag_Stop));
				IF afbTRIG_UwRwEn[iN].Q THEN
					IF i_pastStMotorParam_Vel^[iN].iMoveStep= MOTION_STEP_Nothing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_SETMOTIONMODE;
					ELSE;
					END_IF
				END_IF
				
				IF (i_pastStMotorParam_Vel^[iN].xMoveEn AND (NOT pstStGrpParam_UnSave^.xFlag_TensionDone)) OR
					pstStGrpParam_UnSave^.xFlag_Tension THEN
					
					xFlag_UwRw_Tension := TRUE;
					diVel_Virtual_Tar_Inch := LREAL_TO_DINT( pstStGrpParam_Save^.rVel_Inch*GC_LRMOTORPPR/gc_rGirth_Master/60.0/1000);
					lrMax_a_S_pos_Inch := 0.2;
				ELSE
					xFlag_UwRw_Tension := FALSE;
				END_IF
*)
			END_IF

		
			CASE i_pastStMotorParam_Vel^[iN].iMoveStep OF
			MOTION_STEP_Nothing:
				;
				i_pastStSetPrm^[iN].prm.trapPrm.axis_ctrl:= 2;
				//2026.03.11.103736 | + | 停机维持伺服、停机上下伺服
				IF NOT pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
					IF i_pastStMotorParam_Vel^[iN].xAxisOn_ing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;(*下伺服*)
						axFlgAxisOn[iN]:=FALSE;
					END_IF
				ELSIF pstStGrpParam_Save^.dwExtBitCtlFlag.21 THEN
					//2026.07.30.113643 | + | 欧诺绍兴机进行强制修改版辊
					IF NOT i_pastStMotorParam_Vel^[iN].xAxisOn_ing AND aiCntAxisOn[iN] < 1 AND 
						(NOT i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwMotionSts.1) AND
						iTypeId_T = TYPE_UNIT_PRN AND i_pstStSysParam^.astStUnitParam_Save[iUnitId_T].xLinkage THEN(*如果没有上伺服，则执行上伺服的操作，如果已经上伺服了，则不操作*)
						axFlgAxisOn[iN] := TRUE;
						iRtn:= KS_SetMotionServoOn(
						i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
						i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
						i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
						i_pxMoveEn := ADR(axFlgAxisOn[iN]),//ADR(pstStGrpParam_Save^.dwExtBitCtlFlag.21),
						i_pxServoOn:= ADR(axServoOn[iN]),
						i_pstStHYLogFifo:= i_pstStHYLogFifo);
						IF iRtn<>0 THEN
							IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
								i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
							ELSE
								aiRetryCount[iN]:= aiRetryCount[iN]+1;
							END_IF
						ELSE
							aiRetryCount[iN]:= 0;
							aiCntAxisOn[iN] := aiCntAxisOn[iN] + 1;
						END_IF
					ELSE 
						aiCntAxisOn[iN] := aiCntAxisOn[iN] + 1;
						IF aiCntAxisOn[iN] > 20 THEN
							aiCntAxisOn[iN] := 0;
							axFlgAxisOn[iN] := FALSE;
						END_IF
					END_IF
					ELSE
						;
				END_IF						
			MOTIONCTL_STEP_AXISOFF:
				iRtn:= KS_SetMotionServoOff(
					i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
					i_xForceAxisOff:= FALSE, 
					i_dwMotionSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwMotionSts, 
					i_dwDriverSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwDriverSts, 
					i_pxServoOn:= ADR(axServoOn[iN]), 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);

				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTION_STEP_Nothing;
				END_IF	

				//2025.10.27.164954 | bai.zy | 
				i_pastStSetPrm^[iN].prm.trapPrm.axis_ctrl:= 2;							
				//2026.4.27.221400清零复位变量
				arVel_Pre[iN]:= 0;			
			MOTIONCTL_STEP_SETMOTIONMODE:
				iRtn:= KS_SetMotionMode(
					i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
					i_iMoveMode:= i_pastStMotorParam_Vel^[iN].iMotionMode,//0, 
					i_iAxisId_Master:= iAxisId_Master, 
					i_xMasterType := xMasterType,
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						//2026.03.11.103736 | + | 停机维持伺服、停机上下伺服
// 						IF i_pastStMotorParam_Vel^[iN].xAxisOn_ing THEN
// 							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_CHECKAXISON;
// 						ELSE
// 							i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;							
// 						END_IF
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_CLRSTS;
				END_IF

				//2025.10.27.132646 | bai.zy | TEST_
				iRtn:= GTN_LmtsOffEx(1,iAxisId_Master,-1,-1);	
				iRtn:= GTN_AlarmOff(1,iAxisId_Master);
				iRtn:= GTN_ClrSts(1,iAxisId_Master,1);				
			MOTIONCTL_STEP_CLRSTS:
				iRtn:= KS_SetMotionClrSts(
					i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_ZEROPOS;
				END_IF
			MOTIONCTL_STEP_ZEROPOS:	
				iRtn:= KS_SetMotionZeroPos(
					i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					
					//2026.03.11.103736 | + | 停机维持伺服、停机上下伺服
					IF i_pastStMotorParam_Vel^[iN].xAxisOn_ing THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_WaitingModalChanged;
					ELSE
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISON;							
					END_IF
				END_IF			
				axAxisONBegin[iN] := FALSE;	//TST					
			MOTIONCTL_STEP_AXISON:
				iRtn:= KS_SetMotionServoOn(
					i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
					i_pxMoveEn := ADR(i_pastStMotorParam_Vel^[iN].xMoveEn),
					i_pxServoOn:= ADR(axServoOn[iN]), 
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_WaitingModalChanged;
				END_IF		
				aiWaitingModalChange[iN] := 0;
				
				
				IF i_pastStMotorParam_Vel^[iN].iMoveStep = MOTIONCTL_STEP_WaitingModalChanged THEN
					axAxisONBegin[iN] := TRUE;
					atAxisOnUseTime[iN]:=T#0MS;
				END_IF				
			MOTIONCTL_STEP_WaitingModalChanged:
					aiWaitingModalChange[iN] := aiWaitingModalChange[iN] + 1;
					IF aiWaitingModalChange[iN] > 50 THEN
					//	aiWaitingModalChange[iN] := 0;
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_CHECKAXISON;
					END_IF
			MOTIONCTL_STEP_CHECKAXISON:
				iRtn:= KS_SetMotionCheckServoOn(
					i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
					i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
					i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
					i_pxMoveEn := ADR(i_pastStMotorParam_Vel^[iN].xMoveEn),
					i_dwMotionSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwMotionSts, 
					i_dwDriverSts:= i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwDriverSts, 
					i_pxServoOn:= ADR(axServoOn[iN]),
					i_pstStHYLogFifo:= i_pstStHYLogFifo);
				IF iRtn<>0 THEN
					IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束绝对位置确认这个操作*)
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_AXISOFF;
						axServoOn[iN] := FALSE;
					ELSE
						aiRetryCount[iN]:= aiRetryCount[iN]+1;
					END_IF
				ELSE
					aiRetryCount[iN]:= 0;
					IF i_pastStMotorParam_Vel^[iN].iMotionMode=0 THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_WRITEDATA_Run;
					ELSIF i_pastStMotorParam_Vel^[iN].iMotionMode=1 THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_WRITEDATA_Run;
					ELSIF i_pastStMotorParam_Vel^[iN].iMotionMode=2 THEN
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_WRITEDATA_Preg;
					ELSIF i_pastStMotorParam_Vel^[iN].iMotionMode=3 THEN//2026.4.27.220809增加运动模式
						i_pastStMotorParam_Vel^[iN].iMoveStep:= MOTIONCTL_STEP_WRITEDATA_Jog;
					END_IF
					
				END_IF		
			MOTIONCTL_STEP_WRITEDATA_Run:
				i_pastStSetPrm^[iN].profileMode := 3;
				i_pastStSetPrm^[iN].prm.gearPrm.axis_id:= INT_TO_UINT(i_pastStMotorParam_Vel^[iN].iAxisId);
				i_pastStSetPrm^[iN].prm.gearPrm.axis_mode:= 3;
				i_pastStSetPrm^[iN].prm.gearPrm.mode:= 1;
				i_pastStSetPrm^[iN].prm.gearPrm.reserve:= 0;
				i_pastStSetPrm^[iN].prm.gearPrm.reserve2:= 0;
				
				//2025.10.27.150737 | bai.zy |
				IF i_pastStMotorParam_Vel^[iN].xMoveEn OR xInchDecing THEN
					i_pastStSetPrm^[iN].prm.gearPrm.axis_ctrl:= 3;
				ELSE
					i_pastStSetPrm^[iN].prm.gearPrm.axis_ctrl:= 2;
				END_IF
				
				IF i_pastStMotorParam_Vel^[iN].xMoveVelMode THEN
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a:= 
						LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
					lrTemp:= REAL_TO_LREAL(i_pastStMotorParam_Vel^[iN].rAxisVel)*2000.0*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum*1000
							/1000.0/60.0;		
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_b:= LREAL_TO_DINT(lrTemp/i_pastStMotorParam_Vel^[iN].rAxisGirth
							/i_pastStMotorParam_Vel^[iN].uiAxisDen);					
				ELSE
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
					lrTemp:= REAL_TO_LREAL(i_pastStMotorParam_Vel^[iN].rAxisVel)*2000.0*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/1000.0/60.0;
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_b:= LREAL_TO_DINT(lrTemp/i_pastStMotorParam_Vel^[iN].uiAxisDen);		
				END_IF
				
				//2025.10.27.142943 | bai.zy | 
				IF (*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a = 0 THEN//分母不能为0不能为负
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a := 100000;
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_b := 0;

				END_IF
	
				
				IF (iTypeId_T = TYPE_INFEED_I OR iTypeId_T = TYPE_INFEED_II OR
						iTypeId_T = TYPE_OUTFEED_I OR iTypeId_T = TYPE_OUTFEED_II OR 
						iTypeId_T = TYPE_UNWIND_A_I OR iTypeId_T = TYPE_UNWIND_A_II OR
						iTypeId_T = TYPE_UNWIND_B_I OR iTypeId_T = TYPE_UNWIND_B_II OR
						iTypeId_T = TYPE_REWIND_A_I OR iTypeId_T = TYPE_REWIND_A_II OR
						iTypeId_T = TYPE_REWIND_B_I OR iTypeId_T = TYPE_REWIND_B_II ) THEN
					IF (NOT pstStGrpParam_UnSave^.xFlag_Print) AND pstStGrpParam_UnSave^.xFlag_FilmAccDecDone THEN
						//料膜减速
						IF NOT axRecalcAccelerationFilmDec[iN] THEN
							axRecalcAccelerationFilmDec[iN]:= TRUE;
							lrVel_Pos_Temp:= i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen;//单位pul/ms
							diTemp:= LREAL_TO_DINT((lrVel_Pos_Temp)*pstStGrpParam_Save^.iTime_FilmDec* 1000.0 /2.0);					
						END_IF
					ELSE					
						axRecalcAccelerationFilmDec[iN]:= FALSE;
					//离合区
//					lrVel_Pos_Temp:= ABS(i_pastStMotorParam_Vel^[iN].rAxisVel)*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/i_pastStMotorParam_Vel^[iN].rAxisGirth/i_pastStMotorParam_Vel^[iN].uiAxisDen;//单位pul/ms
//					diTemp:= LREAL_TO_DINT((lrVel_Pos_Temp)* pstStGrpParam_Save^.iTime_FilmDec* 1000.0 /2.0);									
					diTemp:= ABS(REAL_TO_DINT(i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*gc_TENSION_TSK_CYCLE_TIME*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen/4));
				
					END_IF
				ELSE
					diTemp:= ABS(REAL_TO_DINT(i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*gc_TENSION_TSK_CYCLE_TIME*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen/4));
				END_IF
				
				diTemp := REAL_TO_DINT(i_rVel_VirtualMotion * 3);

				IF diTemp <= 1 THEN
					diTemp:= 5000;
				END_IF
			(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].modify_delta := diTemp;
				
				i_pastStSetPrm^[iN].prm.gearPrm.ratio_a := i_pastStMotorParam_Vel^[iN].ratio_a;
				i_pastStSetPrm^[iN].prm.gearPrm.ratio_b := i_pastStMotorParam_Vel^[iN].ratio_b;
				i_pastStSetPrm^[iN].prm.gearPrm.modify_delta := i_pastStMotorParam_Vel^[iN].modify_delta;
				
			MOTIONCTL_STEP_WRITEDATA_Preg:
				i_pastStSetPrm^[iN].profileMode := 1;
				i_pastStSetPrm^[iN].prm.trapPrm.axis_ctrl:= 3;
				i_pastStSetPrm^[iN].prm.trapPrm.axis_id:= INT_TO_UINT(i_pastStMotorParam_Vel^[iN].iAxisId);
				i_pastStSetPrm^[iN].prm.trapPrm.axis_mode:= 1;
				i_pastStSetPrm^[iN].prm.trapPrm.reserve:= 0;
				i_pastStSetPrm^[iN].prm.trapPrm.reserve2[1]:= 0;
				i_pastStSetPrm^[iN].prm.trapPrm.reserve2[2]:= 0;
				i_pastStSetPrm^[iN].prm.trapPrm.target_pos:= i_pastStMotorParam_Vel^[iN].liTargetPos;
				i_pastStSetPrm^[iN].prm.trapPrm.max_vel:= i_pastStMotorParam_Vel^[iN].udiTargetVel;
		
			MOTIONCTL_STEP_WRITEDATA_Inch:
				(*i_pastStSetPrm^[iN].profileMode := 3;
				i_pastStSetPrm^[iN].prm.gearPrm.axis_id:= INT_TO_UINT(i_pastStMotorParam_Vel^[iN].iAxisId);
				i_pastStSetPrm^[iN].prm.gearPrm.axis_mode:= 3;
				i_pastStSetPrm^[iN].prm.gearPrm.mode:= 1;
				i_pastStSetPrm^[iN].prm.gearPrm.reserve:= 0;
				i_pastStSetPrm^[iN].prm.gearPrm.reserve2:= 0;
				
				//2025.10.27.150737 | bai.zy |
				IF i_pastStMotorParam_Vel^[iN].xMoveEn OR xInchDecing THEN
					i_pastStSetPrm^[iN].prm.gearPrm.axis_ctrl:= 3;
				ELSE
					i_pastStSetPrm^[iN].prm.gearPrm.axis_ctrl:= 2;
				END_IF
				
				IF i_pastStMotorParam_Vel^[iN].xMoveVelMode THEN
					i_pastStSetPrm^[iN].prm.gearPrm.ratio_a:= 
						LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
					lrTemp:= REAL_TO_LREAL(i_pastStMotorParam_Vel^[iN].rAxisVel)*2000.0*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum*1000
							/1000.0/60.0;		
					i_pastStSetPrm^[iN].prm.gearPrm.ratio_b:= LREAL_TO_DINT(lrTemp/i_pastStMotorParam_Vel^[iN].rAxisGirth
							/i_pastStMotorParam_Vel^[iN].uiAxisDen);

					//2026.1.7.093121 | + | 停机状态下的纵向对版运动
// 					IF 	g_axMoveUp[iUnitId_T] THEN
// 						;
// 					ELSE
// 						i_pastStSetPrm^[iN].prm.gearPrm.ratio_b := -1* i_pastStSetPrm^[iN].prm.gearPrm.ratio_b;
// 					END_IF
				ELSE
					i_pastStSetPrm^[iN].prm.gearPrm.ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
					lrTemp:= REAL_TO_LREAL(i_pastStMotorParam_Vel^[iN].rAxisVel)*2000.0*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/1000.0/60.0;
					i_pastStSetPrm^[iN].prm.gearPrm.ratio_b:= LREAL_TO_DINT(lrTemp/i_pastStMotorParam_Vel^[iN].uiAxisDen);	

// 2026.1.7.093121 | + | 停机状态下的纵向对版运动
// 					IF 	g_axMoveUp[iUnitId_T] THEN
// 						;
// 					ELSE
// 						i_pastStSetPrm^[iN].prm.gearPrm.ratio_b := -1* i_pastStSetPrm^[iN].prm.gearPrm.ratio_b;
// 					END_IF	
				END_IF
				
				//2025.10.27.142943 | bai.zy | 
				IF i_pastStSetPrm^[iN].prm.gearPrm.ratio_a = 0 THEN//分母不能为0不能为负
					i_pastStSetPrm^[iN].prm.gearPrm.ratio_a := 100000;
					i_pastStSetPrm^[iN].prm.gearPrm.ratio_b := 0;
				END_IF
				
				IF (iTypeId_T = TYPE_INFEED_I OR iTypeId_T = TYPE_INFEED_II OR
						iTypeId_T = TYPE_OUTFEED_I OR iTypeId_T = TYPE_OUTFEED_II OR 
						iTypeId_T = TYPE_UNWIND_A_I OR iTypeId_T = TYPE_UNWIND_A_II OR
						iTypeId_T = TYPE_UNWIND_B_I OR iTypeId_T = TYPE_UNWIND_B_II OR
						iTypeId_T = TYPE_REWIND_A_I OR iTypeId_T = TYPE_REWIND_A_II OR
						iTypeId_T = TYPE_REWIND_B_I OR iTypeId_T = TYPE_REWIND_B_II ) THEN
					IF (NOT pstStGrpParam_UnSave^.xFlag_Print) AND pstStGrpParam_UnSave^.xFlag_FilmAccDecDone THEN
						//料膜减速
						IF NOT axRecalcAccelerationFilmDec[iN] THEN
							axRecalcAccelerationFilmDec[iN]:= TRUE;
							lrVel_Pos_Temp:= i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen;//单位pul/ms
							diTemp:= LREAL_TO_DINT((lrVel_Pos_Temp)*pstStGrpParam_Save^.iTime_FilmDec* 1000.0 /2.0);					
						END_IF
					ELSE					
						axRecalcAccelerationFilmDec[iN]:= FALSE;
						//离合区
						lrVel_Pos_Temp:= ABS(i_pastStMotorParam_Vel^[iN].rAxisVel)*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/i_pastStMotorParam_Vel^[iN].rAxisGirth/i_pastStMotorParam_Vel^[iN].uiAxisDen;//单位pul/ms
						diTemp:= LREAL_TO_DINT((lrVel_Pos_Temp)* pstStGrpParam_Save^.iTime_FilmDec* 1000.0 /2.0);										
						
					END_IF
				ELSE		
					diTemp:= ABS(REAL_TO_DINT(i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*gc_TENSION_TSK_CYCLE_TIME*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen/4));
				END_IF
				
				IF diTemp=0 THEN
					diTemp:= 1000000;
				END_IF
				i_pastStSetPrm^[iN].prm.gearPrm.modify_delta := diTemp;*)
				i_pastStSetPrm^[iN].profileMode := 3;
				i_pastStSetPrm^[iN].prm.gearPrm.axis_id:= INT_TO_UINT(i_pastStMotorParam_Vel^[iN].iAxisId);
				i_pastStSetPrm^[iN].prm.gearPrm.axis_mode:= 3;
				i_pastStSetPrm^[iN].prm.gearPrm.mode:= 1;
				i_pastStSetPrm^[iN].prm.gearPrm.reserve:= 0;
				i_pastStSetPrm^[iN].prm.gearPrm.reserve2:= 0;
				
				//2025.10.27.150737 | bai.zy |
				IF i_pastStMotorParam_Vel^[iN].xMoveEn OR xInchDecing THEN
					i_pastStSetPrm^[iN].prm.gearPrm.axis_ctrl:= 3;
				ELSE
					i_pastStSetPrm^[iN].prm.gearPrm.axis_ctrl:= 2;
				END_IF
				
				IF i_pastStMotorParam_Vel^[iN].xMoveVelMode THEN
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a:= 

						LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
					lrTemp:= REAL_TO_LREAL(i_pastStMotorParam_Vel^[iN].rAxisVel)*2000.0*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum*1000
							/1000.0/60.0;		
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_b:= LREAL_TO_DINT(lrTemp/i_pastStMotorParam_Vel^[iN].rAxisGirth
							/i_pastStMotorParam_Vel^[iN].uiAxisDen);					









				ELSE
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);

					lrTemp:= REAL_TO_LREAL(i_pastStMotorParam_Vel^[iN].rAxisVel)*2000.0*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/1000.0/60.0;
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_b:= LREAL_TO_DINT(lrTemp/i_pastStMotorParam_Vel^[iN].uiAxisDen);		








				END_IF
				
				//2025.10.27.142943 | bai.zy | 
				IF (*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a = 0 THEN//分母不能为0不能为负
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_a := 100000;
					(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].ratio_b := 0;




				END_IF
				

				IF (iTypeId_T = TYPE_INFEED_I OR iTypeId_T = TYPE_INFEED_II OR
						iTypeId_T = TYPE_OUTFEED_I OR iTypeId_T = TYPE_OUTFEED_II OR 
						iTypeId_T = TYPE_UNWIND_A_I OR iTypeId_T = TYPE_UNWIND_A_II OR
						iTypeId_T = TYPE_UNWIND_B_I OR iTypeId_T = TYPE_UNWIND_B_II OR
						iTypeId_T = TYPE_REWIND_A_I OR iTypeId_T = TYPE_REWIND_A_II OR
						iTypeId_T = TYPE_REWIND_B_I OR iTypeId_T = TYPE_REWIND_B_II ) THEN
					IF (NOT pstStGrpParam_UnSave^.xFlag_Print) AND pstStGrpParam_UnSave^.xFlag_FilmAccDecDone THEN
						//料膜减速
						IF NOT axRecalcAccelerationFilmDec[iN] THEN
							axRecalcAccelerationFilmDec[iN]:= TRUE;
							lrVel_Pos_Temp:= i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen;//单位pul/ms
							diTemp:= LREAL_TO_DINT((lrVel_Pos_Temp)*pstStGrpParam_Save^.iTime_FilmDec* 1000.0 /2.0);					
						END_IF
					ELSE					
						axRecalcAccelerationFilmDec[iN]:= FALSE;
					//离合区
//					lrVel_Pos_Temp:= ABS(i_pastStMotorParam_Vel^[iN].rAxisVel)*GC_LRMOTORPPR*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/i_pastStMotorParam_Vel^[iN].rAxisGirth/i_pastStMotorParam_Vel^[iN].uiAxisDen;//单位pul/ms
//					diTemp:= LREAL_TO_DINT((lrVel_Pos_Temp)* pstStGrpParam_Save^.iTime_FilmDec* 1000.0 /2.0);									
					diTemp:= ABS(REAL_TO_DINT(i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*gc_TENSION_TSK_CYCLE_TIME*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen/4));
				




					END_IF
				ELSE

					diTemp:= ABS(REAL_TO_DINT(i_pastStMotorParam_Vel^[iN].rAxisVel*GC_LRMOTORPPR*gc_TENSION_TSK_CYCLE_TIME*i_pastStMotorParam_Vel^[iN].uiAxisNum/60.0/1000.0/i_pastStMotorParam_Vel^[iN].uiAxisDen/4));
				END_IF
				
				diTemp := REAL_TO_DINT(i_rVel_VirtualMotion * 3);

				IF diTemp <= 1 THEN
					diTemp:= 5000;


				END_IF
				(*i_pastStSetPrm^[iN].prm.gearPrm*)i_pastStMotorParam_Vel^[iN].modify_delta := diTemp;
				
				i_pastStSetPrm^[iN].prm.gearPrm.ratio_a := i_pastStMotorParam_Vel^[iN].ratio_a;
				i_pastStSetPrm^[iN].prm.gearPrm.ratio_b := i_pastStMotorParam_Vel^[iN].ratio_b;
				i_pastStSetPrm^[iN].prm.gearPrm.modify_delta := i_pastStMotorParam_Vel^[iN].modify_delta;

			MOTIONCTL_STEP_WRITEDATA_Jog://速度模式2026.4.27.220305主要用于收放料
				i_pastStSetPrm^[iN].profileMode := 7;
				i_pastStSetPrm^[iN].prm.jogPrm.axis_id:= INT_TO_UINT(i_pastStMotorParam_Vel^[iN].iAxisId);
				IF i_pastStMotorParam_Vel^[iN].xMoveEn THEN
					i_pastStSetPrm^[iN].prm.jog2Prm.axis_ctrl:= 3;
				ELSE
					i_pastStSetPrm^[iN].prm.jog2Prm.axis_ctrl:= 2;
				END_IF
				
				i_pastStSetPrm^[iN].prm.jog2Prm.axis_mode:= 7;
				//最大加速度计算2026.4.27.220651|先按预计10ms加到目标速度；
				rTemp_Vel_UwRw:= i_pastStMotorParam_Vel^[iN].rAxisVel;
// 				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
// 					rTemp_Vel_UwRw:= -rTemp_Vel_UwRw;
// 				END_IF

				IF NOT i_pastStMotorParam_Vel^[iN].xMoveVelMode THEN
					IF arVel_Pre[iN]<>rTemp_Vel_UwRw THEN
						udiMax_Acc:= ABS(LREAL_TO_UDINT(REAL_TO_LREAL(rTemp_Vel_UwRw-arVel_Pre[iN])*GC_LRMOTORPPR*
										i_pastStMotorParam_Vel^[iN].uiAxisNum /60.0/1000.0/10.0/ i_pastStMotorParam_Vel^[iN].uiAxisDen));
						IF udiMax_Acc<1 THEN
							udiMax_Acc:= 1;
						END_IF
					ELSE
						udiMax_Acc:= 1;
					END_IF
					arVel_Pre[iN]:= rTemp_Vel_UwRw;
					i_pastStSetPrm^[iN].prm.jog2Prm.max_acc:= ABS(udiMax_Acc);
					diTarget_Vel:= (LREAL_TO_DINT(REAL_TO_LREAL(rTemp_Vel_UwRw)*GC_LRMOTORPPR*
								i_pastStMotorParam_Vel^[iN].uiAxisNum /60.0/1000.0/ i_pastStMotorParam_Vel^[iN].uiAxisDen));
					i_pastStSetPrm^[iN].prm.jog2Prm.target_vel:= diTarget_Vel;				
				ELSE
					IF arVel_Pre[iN]<>rTemp_Vel_UwRw THEN
						udiMax_Acc:= ABS(LREAL_TO_UDINT(REAL_TO_LREAL(rTemp_Vel_UwRw-arVel_Pre[iN])*GC_LRMOTORPPR*1000.0*
										i_pastStMotorParam_Vel^[iN].uiAxisNum /60.0/1000.0/10.0/ i_pastStMotorParam_Vel^[iN].uiAxisDen/
										i_pastStMotorParam_Vel^[iN].rAxisGirth));
						IF udiMax_Acc<1 THEN
							udiMax_Acc:= 1;
						END_IF
					ELSE
						udiMax_Acc:= 1;
					END_IF
					arVel_Pre[iN]:= rTemp_Vel_UwRw;
					i_pastStSetPrm^[iN].prm.jog2Prm.max_acc:= ABS(udiMax_Acc);
					diTarget_Vel:= LREAL_TO_DINT(REAL_TO_LREAL(rTemp_Vel_UwRw)*GC_LRMOTORPPR*1000.0*
								i_pastStMotorParam_Vel^[iN].uiAxisNum /60.0/1000.0/ i_pastStMotorParam_Vel^[iN].uiAxisDen/
								i_pastStMotorParam_Vel^[iN].rAxisGirth);
					i_pastStSetPrm^[iN].prm.jog2Prm.target_vel:= diTarget_Vel;
				END_IF

				i_pastStSetPrm^[iN].prm.jog2Prm.reserve:= 0;				
			END_CASE

//2025.10.23.164012记录一下版辊的运动流程
			IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
				IF iTypeId_T= TYPE_UNIT_BOTTOM THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].iAxisPrnRunCaseId:= i_pastStMotorParam_Vel^[iN].iMoveStep;
				END_IF
			ELSE
				IF iTypeId_T= TYPE_UNIT_PRN THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].iAxisPrnRunCaseId:= i_pastStMotorParam_Vel^[iN].iMoveStep;
				//	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].lrEnc_Pos := i_pastStGetMotionSts^[iAxisId_T].lrPos_Enc;
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].lrEnc_Pos := i_pastStGetMotionSts^[iAxisId_T].lrPos_Prf;
				END_IF
			END_IF
			

			
			xAxisInching := xAxisInching OR i_pstStSysParam^.astStUnitParam_UnSave[iUnitId_T].xAxisInching;
			//增加单运行使能处理2026.2.7.091517任何一个轴单运行就处理一下运行速度；
			xAxisInching:= xAxisInching OR i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_NetRoller OR i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId_T].xInching_BottomRoller;
			xAxisInching:= xAxisInching OR i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_Of_Roller OR i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xInching_If_Roller;
			
			IF axAxisONBegin[iN] THEN(*开始上私服了*)
				IF NOT axAxisONING[iN] THEN
					axAxisONING[iN]:=TRUE;
					atAxisOnBeginTime[IN] :=  TIME();
				END_IF
				
				IF i_pastStGetMotionSts^[i_pastStMotorParam_Vel^[iN].iAxisId].dwDriverSts = 3 THEN
					atAxisOnUseTime[iN] := TIME() - atAxisOnBeginTime[IN];
					axAxisONBegin[iN]:=FALSE;
				END_IF
			ELSE
				axAxisONING[iN]:=FALSE;
			END_IF
					
		END_FOR 

//2025.10.28.170840 | bai.zy | 区分单运行时的主轴速度
		IF pstStGrpParam_UnSave^.xFlag_AllInchRun OR xInchDecing OR (xAxisInching AND pstStGrpParam_UnSave^.xFlag_Stop) OR xFlag_UwRw_Tension THEN
			IF diVel_Virtual_Tar_Inch<>0 THEN
				i_diVel_Virtual_Tar := diVel_Virtual_Tar_Inch;
// 			ELSIF diVel_Virtual_Tar_Inch_Net<>0 THEN
// 				i_diVel_Virtual_Tar := diVel_Virtual_Tar_Inch_Net;
			END_IF
			i_lrMax_a_S_pos := lrMax_a_S_pos_Inch;
		END_IF
// 		IF i_pstStSysParam^.stStSysParam_Save.wMachineArchitectureRef.3 THEN
// 			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension THEN
// 				i_diVel_Virtual_Tar := LREAL_TO_DINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Inch
// 																		*GC_LRMOTORPPR/
// 																		gc_rGirth_Master/60.0/1000);
// 				i_lrMax_a_S_pos:= 1;				
// 			END_IF
// 		END_IF
		g_diVel_Virtual_Tar_Temp := i_diVel_Virtual_Tar;
		g_lrMax_a_S_pos:=i_lrMax_a_S_pos;
		
		fbKS_FB_McMultiFunCtl(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpGearMotion_Num:= i_iGrpGearMotion_Num, 
			i_aiGrpGearMotion_StdList:= i_aiGrpGearMotion_StdList, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
			i_rVel_VirtualMotion:= i_rVel_VirtualMotion,  
			i_pastStSetPrm:= i_pastStSetPrm, 
			i_pstStGetPrm:= i_pstStGetPrm, 
			i_pastStGetMotionSts:= i_pastStGetMotionSts, 
			i_pastStMotorParam_Vel:= i_pastStMotorParam_Vel, 
			i_pstStHYLogFifo:= i_pstStHYLogFifo, 
			i_iAxisId_Master:= iAxisId_Master, 
			i_diVel_Virtual_Tar:= i_diVel_Virtual_Tar, 
			i_lrMax_a_S_pos:= i_lrMax_a_S_pos,
			i_pstStSysStationInf:=i_pstStSysStationInf,
			o_lrVel_VirtualAxis=>o_lrVel_VirtualAxis,
			o_iErrAxisId=> o_iErrAxisId, 
			o_iErrTypeId=> o_iErrTypeId, 
			o_iErrUnitId=> o_iErrUnitId, 
			o_iErrCoreId=> o_iErrCoreId,
			o_iMoveErrCode=>o_iMoveErrCode,
			io_xMotionEnabled := io_xMotionEnabled
			);	
			
		//test
// 		
// 		IF fbKS_FB_McMultiFunCtl.o_xSetParamDne THEN
// 			iCheckCnt:=0;
// 		END_IF
// 		IF  iCheckCnt<100 THEN(*检查100个周期*)
// 			iCheckCnt:=iCheckCnt+1;
// 			//测试代码@2026.5.14.133026+
// 			iRtn := GTN_GetGearRatio(
// 				core:= 1, 
// 				profile:= 2, 
// 				pMasterEven:= ADR(g_adiMasterEven[1]), 
// 				pSlaveEven:= ADR(g_adiSlaveEven[1]), 
// 				pMasterSlope:= ADR(g_adiMasterSlope[1]));
// 				
// 			IF g_adiMasterEven[1] <> g_astStSetPrm[1].prm.gearPrm.ratio_a THEN
// 				KS_HY_AddMsgToLog(i_pstStHYLogFifo, LOG_LEVEL_ALARM_NORMAL,
// 					CONCAT('g_adiMasterEven[1]=',DINT_TO_STRING(g_adiMasterEven[1])), 
// 					CONCAT('g_astStSetPrm[1].prm.gearPrm.ratio_a=',DINT_TO_STRING(g_astStSetPrm[1].prm.gearPrm.ratio_a)));		
// 			END_IF
// 				
// 			IF g_adiSlaveEven[1] <> g_astStSetPrm[1].prm.gearPrm.ratio_b THEN
// 				KS_HY_AddMsgToLog(i_pstStHYLogFifo, LOG_LEVEL_ALARM_NORMAL,
// 					CONCAT('g_adiSlaveEven[1]=',DINT_TO_STRING(g_adiSlaveEven[1])), 
// 					CONCAT('g_astStSetPrm[1].prm.gearPrm.ratio_b=',DINT_TO_STRING(g_astStSetPrm[1].prm.gearPrm.ratio_b)));	
// 			END_IF	
// 			IF g_adiMasterSlope[1] <> g_astStSetPrm[1].prm.gearPrm.modify_delta THEN
// 				KS_HY_AddMsgToLog(i_pstStHYLogFifo, LOG_LEVEL_ALARM_NORMAL,
// 					CONCAT('g_adiMasterSlope[1]=',DINT_TO_STRING(g_adiMasterSlope[1])), 
// 					CONCAT('g_astStSetPrm[1].prm.gearPrm.modify_delta=',DINT_TO_STRING(g_astStSetPrm[1].prm.gearPrm.modify_delta)));				
// 			END_IF
// 		END_IF
		//end
			
			//2026.1.20.105520 | + | 对所有运动轴的运动模式进行初始化
		IF NOT xInitAxisMotionMode THEN			
			IF i_iGrpGearMotion_Num>0 THEN
				xInitAxisMotionMode := TRUE;
				FOR iN := 1 TO i_iGrpGearMotion_Num BY 1 DO
					iRtn:= KS_SetMotionMode(
						i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
						i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
						i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
						i_iMoveMode:= 2,//2026.5.13.094253更新为3,//i_pastStMotorParam_Vel^[iN].iMotionMode,//0, 
						i_iAxisId_Master:= iAxisId_Master, 
						i_xMasterType := xMasterType,
						i_pstStHYLogFifo:= i_pstStHYLogFifo);
					
					iRtn:= KS_SetMotionZeroPos(
						i_iAxisId:= i_pastStMotorParam_Vel^[iN].iAxisId, 
						i_iCoreId:= i_pastStMotorParam_Vel^[iN].iCoreId, 
						i_iStationId:= i_pastStMotorParam_Vel^[iN].iStationId, 
						i_pstStHYLogFifo:= i_pstStHYLogFifo);
		
					i_pastStSetPrm^[iN].profileMode := 1;
					i_pastStSetPrm^[iN].prm.trapPrm.axis_ctrl:= 2;
					i_pastStSetPrm^[iN].prm.trapPrm.axis_id:= INT_TO_UINT(i_pastStMotorParam_Vel^[iN].iAxisId);
					i_pastStSetPrm^[iN].prm.trapPrm.axis_mode:= 1;
					i_pastStSetPrm^[iN].prm.trapPrm.reserve:= 0;
					i_pastStSetPrm^[iN].prm.trapPrm.reserve2[1]:= 0;
					i_pastStSetPrm^[iN].prm.trapPrm.reserve2[2]:= 0;
					i_pastStSetPrm^[iN].prm.trapPrm.target_pos:= 0;
					i_pastStSetPrm^[iN].prm.trapPrm.max_vel:= 10;
	
	
				//2025.10.27.132646 | bai.zy | 主轴的状态清理
						iRtn:= GTN_LmtsOffEx(1,iAxisId_Master,-1,-1);	
						iRtn:= GTN_AlarmOff(1,iAxisId_Master);
						iRtn:= GTN_ClrSts(1,iAxisId_Master,1);
						
	// 				i_pastStSetPrm^[iN].profileMode := 3;
	// 				i_pastStSetPrm^[iN].prm.gearPrm.axis_ctrl:= 2;
	// 				i_pastStSetPrm^[iN].prm.gearPrm.axis_id:= i_pastStMotorParam_Vel^[iN].iAxisId;
	// 				i_pastStSetPrm^[iN].prm.gearPrm.axis_mode:= 3;
	// 				i_pastStSetPrm^[iN].prm.gearPrm.mode:= 1;
	// 				i_pastStSetPrm^[iN].prm.gearPrm.modify_delta:= 5000;
	// 				i_pastStSetPrm^[iN].prm.gearPrm.ratio_a:= 100000;
	// 				i_pastStSetPrm^[iN].prm.gearPrm.ratio_b:= 0;
	// 				
				
				END_FOR
				i_pastStSetPrm^[1].prm.gearPrm.modify_delta		;
				i_pastStSetPrm^[2].prm.gearPrm.modify_delta		;
				i_pastStSetPrm^[3].prm.gearPrm.modify_delta		;
				i_pastStSetPrm^[4].prm.gearPrm.modify_delta		;
				i_pastStSetPrm^[5].prm.gearPrm.modify_delta		;
				i_pastStSetPrm^[6].prm.gearPrm.modify_delta		;
				i_pastStSetPrm^[1].prm.gearPrm.axis_ctrl;
				i_pastStSetPrm^[2].prm.gearPrm.axis_ctrl;
				i_pastStSetPrm^[3].prm.gearPrm.axis_ctrl;
				i_pastStSetPrm^[4].prm.gearPrm.axis_ctrl;
				i_pastStSetPrm^[5].prm.gearPrm.axis_ctrl;
				i_pastStSetPrm^[6].prm.gearPrm.axis_ctrl;
				i_pastStSetPrm^[1].prm.gearPrm.ratio_a;
				i_pastStSetPrm^[2].prm.gearPrm.ratio_a;
				i_pastStSetPrm^[3].prm.gearPrm.ratio_a;
				i_pastStSetPrm^[4].prm.gearPrm.ratio_a;
				i_pastStSetPrm^[5].prm.gearPrm.ratio_a;
				i_pastStSetPrm^[6].prm.gearPrm.ratio_a;	
				i_pastStSetPrm^[1].prm.gearPrm.ratio_b;
				i_pastStSetPrm^[2].prm.gearPrm.ratio_b;
				i_pastStSetPrm^[3].prm.gearPrm.ratio_b;
				i_pastStSetPrm^[4].prm.gearPrm.ratio_b;
				i_pastStSetPrm^[5].prm.gearPrm.ratio_b;
				i_pastStSetPrm^[6].prm.gearPrm.ratio_b;		
			END_IF	
		END_IF
		
	ELSE;
	END_IF
ELSE
	;
END_IF