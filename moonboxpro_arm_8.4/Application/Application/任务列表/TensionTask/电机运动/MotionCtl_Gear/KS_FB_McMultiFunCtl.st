(*@CES
Name=KS_FB_McMultiFunCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=fb2a2e7c-d266-47f9-853c-d0f655c10779
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_McMultiFunCtl(*大指令控制*)
(*
1.检查伺服状态
2.大指令写控制
3.虚拟主轴控制
*)
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
//	i_piMotionStep: POINTER TO INT;
	i_pastStSetPrm					:POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pstStGetPrm					:POINTER TO TMultiMcFunctionReadPrm;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pastStMotorParam_Vel: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
	i_iAxisId_Master: INT;(*虚拟主轴轴号*)	
	i_diVel_Virtual_Tar: DINT;(*虚拟主轴规划速度*)
	i_lrMax_a_S_pos: LREAL;(*虚拟主轴最大减速度*)
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
END_VAR
VAR_OUTPUT
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
												
	o_xSetParamDne:BOOL;(*设置参数标志@2026.5.14.135646+测试*)
END_VAR
VAR_IN_OUT
	io_xMotionEnabled: BOOL;(*|2021.1.15.092801 速度控制块使能修改为输入输出变量|这里处理该值的复位*)
END_VAR
VAR
	stTMoveVelocityPrm : TMoveVelocityPrm;
	iDirection: INT;
	diLastVel: DINT;
	lrMax_a_S_Last: LREAL;
	iRtn: INT;
	alrVarValue : ARRAY [1..80] OF LREAL;	
	dwRtn : DWORD;
	astStSetPrm_Pre				: ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	
	diClock : DINT;
	
	fbKS_FB_CheckServeOnDone : KS_FB_CheckServeOnDone;
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	fbTRIG_MotionEnable: R_TRIG;
	
	aiRtn_McMulFun : ARRAY [1..10] OF INT ;
	aiRtn_McMulFun_Pre : ARRAY [1..10] OF INT ;
	iRtn_MoveVelocity : INT;
	
	sTMultiMcFunctionReadPrm : TMultiMcFunctionReadPrm;
	
	(*2025-12-10 by sjw 非阻塞大指令*)
	FB_Set_StartMcMUltiFunction: ARRAY[1..3] OF GTMC_StartMcMultiFunction;
	bDoneSet: ARRAY[1..3] OF BOOL := [TRUE, TRUE];
	bBusySet: ARRAY[1..3] OF BOOL;
	bErrorSet: ARRAY[1..3] OF BOOL;
	iErrorIdSet: ARRAY[1..3] OF INT;
	
	iCnt : INT;
	rTemp : REAL;
	rTemp2 : REAL;
	
END_VAR

{IMPLEMENTATION}
(*1.伺服检查-确保所有需要转的轴都上伺服了才能进行下一步*)
pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
fbKS_FB_CheckServeOnDone(
	i_xEn:= ((pstStGrpParam_UnSave^.xFlag_PreStart OR pstStGrpParam_UnSave^.xFlag_Ink OR pstStGrpParam_UnSave^.xFlag_AllInchRun OR pstStGrpParam_UnSave^.xFlag_Print OR (pstStGrpParam_UnSave^.xFlag_Tension AND g_xUwRwIsServo)) (*AND (NOT fbKS_FB_CheckServeOnDone.o_xDone)*)), 
	i_iGrpGearMotion_Num:= i_iGrpGearMotion_Num, 
	i_aiGrpGearMotion_StdList:= i_aiGrpGearMotion_StdList, 
	i_pstStSysParam:= i_pstStSysParam, 
	i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
	i_pastStGetMotionSts:= i_pastStGetMotionSts, 
	i_pastStMotorParam_Vel:= i_pastStMotorParam_Vel, 
	i_xFlag_StopOrEStop := pstStGrpParam_UnSave^.xFlag_Stop OR pstStGrpParam_UnSave^.xFlag_Estop,
	i_pstStSysStationInf:=i_pstStSysStationInf,
	o_xEn=> , 
	o_xDone=> , 
	o_iErrNo=> , 
	o_iErrAxisId=> o_iErrAxisId, 
	o_iErrTypeId=> o_iErrTypeId, 
	o_iErrUnitId=> o_iErrUnitId, 
	o_iErrCoreId=> o_iErrCoreId,
	o_iMoveErrCode=>o_iMoveErrCode);
	
fbTRIG_MotionEnable (CLK := (fbKS_FB_CheckServeOnDone.o_xEn AND fbKS_FB_CheckServeOnDone.o_xDone));
IF fbTRIG_MotionEnable.Q THEN
	io_xMotionEnabled := TRUE;
END_IF
(*2.大指令写*)
//IF fbKS_FB_CheckServeOnDone.o_xEn (*AND fbKS_FB_CheckServeOnDone.o_xDone*) THEN
	sTMultiMcFunctionReadPrm.readCommandVarTableIndex := 1;
	sTMultiMcFunctionReadPrm.readCount := 80;
	sTMultiMcFunctionReadPrm.pVarValue := ADR(alrVarValue);
	dwRtn:= SysMemCmp(i_pastStSetPrm,ADR(astStSetPrm_Pre),SIZEOF(astStSetPrm_Pre));
	o_xSetParamDne:=FALSE;
	IF dwRtn<>0 THEN
		o_xSetParamDne:=TRUE;(*2026.5.14.135659+*)
		IF i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.3 THEN
			//修改非阻塞方式 2025-12-10 by sjw
			aiRtn_McMulFun[1]:=GTN_StartMcMultiFunction(1,i_iGrpUnitNum_Pu,1,i_pastStSetPrm,ADR(sTMultiMcFunctionReadPrm));
			IF aiRtn_McMulFun[1] <> 0 AND aiRtn_McMulFun_Pre[1] <> aiRtn_McMulFun[1] THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'GTN_StartMcMultiFunction Gear Err!', INT_TO_STRING(aiRtn_McMulFun[1]));
			END_IF
			aiRtn_McMulFun_Pre[1] := aiRtn_McMulFun[1];
			(*
			IF bDoneSet[1] = TRUE AND bBusySet[1] = FALSE THEN
				FB_Set_StartMcMUltiFunction[1](
				Execute:= TRUE, 
				Block:= TRUE, 
				core:= 1, 
				axisCount:= i_iGrpUnitNum_Pu, 
				writeEnable:= 1, 
				pSetPrm:= i_pastStSetPrm, 
				pGetPrm:= ADR(sTMultiMcFunctionReadPrm), 
				Done=> bDoneSet[1], 
				Busy=> bBusySet[1], 	
				Error=> bErrorSet[1], 
				ErrorID=> iErrorIdSet[1]);
			END_IF
			*)
			aiRtn_McMulFun[2]:=GTN_StartMcMultiFunction(2,i_iGrpGearMotion_Num-i_iGrpUnitNum_Pu,1,ADR(i_pastStSetPrm^[i_iGrpUnitNum_Pu + 1]),ADR(sTMultiMcFunctionReadPrm));
			IF aiRtn_McMulFun[2] <> 0 AND aiRtn_McMulFun_Pre[2] <> aiRtn_McMulFun[2] THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'GTN_StartMcMultiFunction Gear Err!', INT_TO_STRING(aiRtn_McMulFun[2]));
			END_IF
			aiRtn_McMulFun_Pre[2] := aiRtn_McMulFun[2];
			(*
			IF bDoneSet[2] = TRUE AND bBusySet[2] = FALSE THEN
				FB_Set_StartMcMUltiFunction[2](
				Execute:= TRUE, 
				Block:= TRUE, 
				core:= 2, 
				axisCount:= i_iGrpGearMotion_Num-i_iGrpUnitNum_Pu, 
				writeEnable:= 1, 
				pSetPrm:= ADR(i_pastStSetPrm^[i_iGrpUnitNum_Pu + 1]), 
				pGetPrm:= ADR(sTMultiMcFunctionReadPrm), 
				Done=> bDoneSet[2], 
				Busy=> bBusySet[2], 	
				Error=> bErrorSet[2], 
				ErrorID=> iErrorIdSet[2]);
			END_IF
			*)
		ELSE
			aiRtn_McMulFun[3]:=GTN_StartMcMultiFunction(1,i_iGrpGearMotion_Num,1,i_pastStSetPrm,ADR(sTMultiMcFunctionReadPrm));
			g_iRtn_MulFunCtl := aiRtn_McMulFun[3];
			IF aiRtn_McMulFun[3] <> 0 AND aiRtn_McMulFun_Pre[3] <> aiRtn_McMulFun[3] THEN
				KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'GTN_StartMcMultiFunction Gear Err!', INT_TO_STRING(aiRtn_McMulFun[3]));
			END_IF
			aiRtn_McMulFun_Pre[3] := aiRtn_McMulFun[3];
			(*
			IF bDoneSet[3] = TRUE AND bBusySet[3] = FALSE THEN
				FB_Set_StartMcMUltiFunction[3](
				Execute:= TRUE, 
				Block:= TRUE, 
				core:= 1, 
				axisCount:= i_iGrpUnitNum_Pu, 
				writeEnable:= 1, 
				pSetPrm:= i_pastStSetPrm, 
				pGetPrm:= ADR(sTMultiMcFunctionReadPrm), 
				Done=> bDoneSet[3], 
				Busy=> bBusySet[3], 	
				Error=> bErrorSet[3], 
				ErrorID=> iErrorIdSet[3]);
			END_IF
			*)
		END_IF
	END_IF
	SysMemCpy(ADR(astStSetPrm_Pre),i_pastStSetPrm,SIZEOF(i_pastStSetPrm^));
	(*3.虚拟主轴控制*)
	(*主轴规划写值2025.8.25.200653*)	

	//2026.1.21.185728 | + | 首次开机单运行之后停不下来
	//2026.1.21.185728 | + | 首次开机单运行之后停不下来
	IF i_lrMax_a_S_pos = 0 THEN
		i_lrMax_a_S_pos := 1;
		iCnt := iCnt + 1;

	END_IF
	
	IF i_diVel_Virtual_Tar<>diLastVel OR
		i_lrMax_a_S_pos<>lrMax_a_S_Last THEN	
		stTMoveVelocityPrm.vel:= i_diVel_Virtual_Tar;//g_adiVel_Virtual_Tar[1];
		stTMoveVelocityPrm.acc:= ABS(i_lrMax_a_S_pos);//ABS(g_alrMax_a_S_pos[1]);
		stTMoveVelocityPrm.dec:= ABS(i_lrMax_a_S_pos);//ABS(g_alrMax_a_S_pos[1]);
		stTMoveVelocityPrm.jerkBegin:= ABS(g_alrJerk_SBegin[1]);
		stTMoveVelocityPrm.jerkEnd:= ABS(g_alrJerk_SEnd[1]);	
		stTMoveVelocityPrm.direction:= iDirection;
		iRtn_MoveVelocity := GTN_MoveVelocity(core:= 1, profile:=i_iAxisId_Master, pPrm:= ADR(stTMoveVelocityPrm));	
		
		rTemp := i_diVel_Virtual_Tar / GC_LRMOTORPPR * gc_rGirth_Master * 60.0 * 1000;
		KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'Target Vel: ', REAL_TO_STRING(rTemp));
		rTemp2 := i_lrMax_a_S_pos * 1000;
		KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'Target A: ', REAL_TO_STRING(rTemp2));
		
	END_IF
	diLastVel:= i_diVel_Virtual_Tar;
	lrMax_a_S_Last:= i_lrMax_a_S_pos;
//END_IF

(*先不用小指令读速度2026.4.30.092047
iRtn := GTN_GetPrfVel(
	core:= 1, 
	profile:= i_iAxisId_Master, 
	pValue:= ADR(o_lrVel_VirtualAxis), 
	count:= 1, 
	pClock:= ADR(diClock));
*)
//换个获取方式吧
o_lrVel_VirtualAxis:= i_pastStGetMotionSts^[i_iAxisId_Master].lrVel_Prf;


// iRtn := GTN_GetAxisPrfVel(
// 	core:= 1, 
// 	axis:= i_iAxisId_Master, 
// 	pValue:= ADR(g_lrPrfVel2), 
// 	count:= 1, 
// 	pClock:= ADR(diClock));
//2026.4.30.092405加速度也换小指令处理
(*
iRtn := GTN_GetPrfAcc(
	core:= 1, 
	profile:= 64, 
	pValue:= ADR(g_alrPrfAcc_MasterAxis2[i_iGrpId]), 
	count:= 1, 
	pClock:= ADR(diTempClock));
*)
g_alrPrfAcc_MasterAxis2[i_iGrpId]:= i_pastStGetMotionSts^[i_iAxisId_Master].lrPrfAcc;	
	
// 	
// iRtn := GTN_GetAxisPrfAcc(
// 	core:= 1, 
// 	axis:= 64, 
// 	pValue:= ADR(lrTempAxisPrfAcc), 
// 	count:= 1, 
// 	pClock:= ADR(diTempClock));