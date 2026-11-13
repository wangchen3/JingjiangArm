(*@CES
Name=PRG_TENSION
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5a910309-0c13-4729-bc55-b8719e8f4b7b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
PROGRAM PRG_TENSION
VAR
	iN: INT;

	iButtonCnt: INT;
	iButtonCntStop : INT;
	iButtonCntPrint : INT;
	iButtonCntTension : INT;
	iButtonCntPrestart : INT;
	xInit_Btn: BOOL;
	xPreStart_hmi: BOOL;
	xPreStop_hmi: BOOL;
	xPreEStop_hmi: BOOL;
//	fbKS_FB_MotionCtl : KS_FB_MotionCtl;//新增|2025.08.05.100004
	iGrp : INT;
	
	xFlagEmergencyForFile_tmp :BOOL; 	
	
	
	iId_Uw_IO: INT;
	iId_Rw_IO: INT;
	iId_If_IO: INT;
	iId_Of_IO: INT;

	afbKS_FB_Func_UwRw: ARRAY [1..2] OF KS_FB_Func_UwRw;
	afbKS_FB_Func_IfOf : ARRAY [1..2] OF  KS_FB_Func_IfOf;
	//afbKS_FB_StRecord_T : ARRAY [1..2] OF KS_FB_StRecord_T ; 
	fbKS_FB_TravelFileService :KS_FB_TravelFileService ; 
	afbKS_FB_FilmSpdCtrl: ARRAY [1..2] OF KS_FB_FilmSpdCtrl;
	afbKS_FB_CoatingCTL: ARRAY [1..2] OF KS_FB_CoatingCTL;
	//2025.07.14.160135 |
	xInit_TrapPoint : BOOL;
	iRtn : INT;
	iCoreId_1 : INT := 1;
	iCoreId_2 : INT := 2;
	aiGrpAxisList_Pu: ARRAY [1..MAX_UNIT_NUM] OF INT;
	iAxisId_Master: INT;
	iPseudoRandomCurIndex:INT;(*2024.05.24.212623+*)
	astStMotorParam_Vel: ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	afbKS_FB_MotionCtl_New: ARRAY [1..2] OF KS_FB_MotionCtl_New;
	
	//2025.11.03.103620 | bai.zy | TEST_1103
	apData : ARRAY [1..MAX_UNIT_NUM] OF UINT;	
	
	atiTimeReadWatch : ARRAY [1..MAX_UNIT_NUM] OF LTIME;	
	
	iReadVirtualSts_UnitId : INT;
	
	//alrBuff_Read: ARRAY [1..MAX_UNIT_NUM,1..50] OF LREAL;

	adiReadCount: ARRAY [1..MAX_UNIT_NUM] OF DINT;	
	iK : INT;
	
	//altime : ARRAY [1..20] OF LTIME;
	
	iCountRes : INT;
	
	astStMotorParam_GantryTrap: ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
 	afbKS_FB_MotionCtl_GantryTrap : ARRAY [1..2] OF KS_FB_MotionCtl_GantryTrap;
	aiStationList_GantrayTrap		: ARRAY [1..MAX_STATION_NUM] OF INT;(*龙门点位运动轴列表*)
	astStMotorParam_Trap: ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Trap;
	afbKS_FB_MotionCtl_Trap :ARRAY [1..2] OF KS_FB_MotionCtl_Trap;
	iAxisId: INT;
	iCoreId: INT;
	iTypeId: INT;
	iUnitId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	iGantryTrapGroupId : INT;
	
//	aiGrpServoAxisList_IfOf : ARRAY [1..2] OF INT;
	
	alrEncPos : ARRAY [1..4] OF LREAL;
	adiClock : ARRAY [1..4] OF DINT;
	
	iGantryAxisCount : INT;
	aiTargetStation : ARRAY [1..MAX_STATION_NUM] OF INT;//压力电机站列表
	aliABSEncPos : ARRAY [1..MAX_STATION_NUM] OF LINT;//零位绝对编码器位置
	axAxisRev : ARRAY [1..MAX_STATION_NUM] OF BOOL;//零位绝对编码器位置
	
	afbKS_FB_BandLen_Local: ARRAY [1..2] OF KS_FB_BandLen_Local;
	
//	afbKS_FB_CoatingCtl_OF : ARRAY [1..2] OF KS_FB_CoatingCtl_OF;
//	arVel_Pre: ARRAY [1..2] OF REAL;
	arVel_Pre_A: ARRAY [1..2] OF REAL;
	axInit_Vel: ARRAY [1..2] OF BOOL;//
	
	afbKS_FB_FillUpStruct_II : ARRAY [1..2] OF KS_FB_FillUpStruct_II;
	afbKS_FB_StRecord_T_New_II : ARRAY [1..2] OF KS_FB_StRecord_T_New_II ;
	
	
	//2026.05.07.192119 xi.hy新增@七号开始
	//abySampleStationList:ARRAY [1..MAX_UNIT_NUM] OF BYTE:=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];//临时定义采样站数组，后续更换为程序已有的	
	//apbyStsList:ARRAY [1..MAX_UNIT_NUM] OF POINTER TO BYTE;
	//aiddr_Temp:POINTER TO INT;
	//iSts:ARRAY[1..MAX_UNIT_NUM,1..64] OF INT;
	
//调整量输出放这里	2026.4.29.231543
	afbKS_FB_AdjOutCtl: ARRAY [1..2] OF KS_FB_AdjOutCtl_New;
	aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	aiStepAdj: ARRAY [1..MAX_UNIT_NUM] OF INT;
//获取状态2026.4.29.231558
	iReadSts_Page: INT;
	stStSetPrm : TSetMultiMcFunctionPrm;	
	iUpdateEncPosStart: INT;
	iUpdateEncPosEnd: INT;
	//2026.02.04.170811 | + | 这里需要把方向处理一下，只有主从轴的方向不一致才需要把从轴方向改了
	axGantryAxisIsRev : ARRAY [1..20,1..2] OF BOOL;//最大20组龙门，每组龙门两个轴 
	//iGantryAxisCount : INT;
	astStStationSts : ARRAY [1..MAX_STATION_NUM] OF StStationSts;
	diRealCount: DINT;
	diRealCount_2: DINT;
	udiClock: UDINT;
	udiClock2: UDINT;
	
	//2026.5.14.102439+获取虚拟马盘等信息列表@gt接口需要
	byGetStationVarNum:BYTE;
	abyGetVar_StationIdList:ARRAY [1..MAX_UNIT_NUM] OF BYTE;//0是非法值@站id
	abyGetVar_AxisIdList:ARRAY [1..MAX_UNIT_NUM] OF BYTE;//轴id
	apiStationVar:ARRAY [1..MAX_UNIT_NUM] OF POINTER TO ARRAY[1..64] OF INT;//每个站获取到的数据@先按照64个byte-数组指针
	pdwTmp:POINTER TO DWORD;
	pwTmp:POINTER TO WORD;
END_VAR

{IMPLEMENTATION}
IF g_iRunStepId=RUNSTEP_NormalWork AND g_dwNormalWorkRunNum>5 THEN
	;
ELSE
	RETURN;
END_IF


atiTimeReadWatch[1] := LTIME();
Action_Input();
atiTimeReadWatch[2] := LTIME();
Action_ActCtl();
atiTimeReadWatch[3] := LTIME();
(*2025.06.30.203725*)
Action_Output();
atiTimeReadWatch[4] := LTIME();

atiTimeReadWatch[10] :=atiTimeReadWatch[4]-atiTimeReadWatch[3];
atiTimeReadWatch[9] :=atiTimeReadWatch[3]-atiTimeReadWatch[2];
atiTimeReadWatch[8] :=atiTimeReadWatch[2]-atiTimeReadWatch[1];

g_dwTensionRunNum:= g_dwTensionRunNum+1;