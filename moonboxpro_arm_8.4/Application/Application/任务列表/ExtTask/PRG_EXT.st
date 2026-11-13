(*@CES
Name=PRG_EXT
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2328aaa2-cac0-4dd6-92e5-fc2ee2949008
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
  PROGRAM PRG_EXT
(*处理动作流程和工艺动作-包含IO处理*)
VAR
	iN: INT;
	iGrp: INT;
	iK: INT;
	abyColorIdCurrent: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*色组色序*)
	abyFollowColorId: ARRAY [1..MAX_UNIT_NUM] OF BYTE;	
	iRtn: INT;
	aiIOGrpIdx_Uw	: ARRAY [1..2] OF INT;
	aiIOGrpIdx_Rw	: ARRAY [1..2] OF INT;
	
	xInit_TEST : BOOL;
	aiIOGrpIdx_If 	: ARRAY [1..2] OF INT;
	aiIOGrpIdx_Of 	: ARRAY [1..2] OF INT;
	iGrpAxisNum_Pu: INT; (* 色组的轴数 *)	
	aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (* 当前系轴号列表 *)

	
	afbKS_FB_GrpFetchIOCtrl: ARRAY [1..2] OF KS_FB_GrpFetchIOCtrl;
	afbKS_FB_GrpUserActionCtrl: ARRAY [1..2] OF KS_FB_GrpUserActionCtrl;
	afbKS_FB_GrpAxisLinkageCtrl: ARRAY [1..2] OF KS_FB_GrpAxisLinkageCtrl;
	afbKS_FB_RollerPressCTL_Home: ARRAY [1..2] OF KS_FB_RollerPressCTL_Home;(*压辊控制*)
	afbKS_FB_GetPressDneFlag: ARRAY [1..2] OF KS_FB_GetPressDneFlag;(*获取压辊状态*)
	afbKS_FB_GrpScraperCtrl: ARRAY [1..2] OF KS_FB_GrpScraperCtrl;(*刮刀*)
	afbKS_FB_GrpAlarmBellControl: ARRAY [1..2] OF KS_FB_GrpAlarmBellControl;(*报警铃处理*)
	afbKS_FB_GrpIndicatorLampCtrl: ARRAY [1..2] OF  KS_FB_GrpIndicatorLampCtrl;(*指示灯处理*)
	afbKS_FB_GrpInkRollerCtrl :  ARRAY [1..2] OF  KS_FB_GrpInkRollerCtrl;(*递磨辊*)
	afbKS_FB_GrpCoolBlowerCtrl :  ARRAY [1..2] OF  KS_FB_GrpCoolBlowerCtrl;(*冷风*)
	afbKS_FB_GrpHeatingCtrl  :  ARRAY [1..2] OF KS_FB_GrpHeatingCtrl;(*加热*)
	afbKS_FB_GrpAirExhaustCtrl  :  ARRAY [1..2] OF  KS_FB_GrpAirExhaustCtrl;(*排风*)
	afbKS_FB_GrpAirHotCtrl  :  ARRAY [1..2] OF KS_FB_GrpAirHotCtrl;(*热风*)
	afbKS_FB_GrpPreHotBlowerCtrl :  ARRAY [1..2] OF  KS_FB_GrpPreHotBlowerCtrl;(*预加热*)
	afbKS_FB_WindDoorCtl  :  ARRAY [1..2] OF  KS_FB_WindDoorCtl;(*风门*)
//	afbKS_FB_VertAdjustCtrl: ARRAY [1..2] OF KS_FB_VertAdjustCtrl;(*套色调整*)
	axHotBlowerEn_Act:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xAirHotFlag:BOOL;
	xCoolBlowerFlag:BOOL;
	xAirExhaustFinishFlag: BOOL;
	xHeatingFlag:BOOL;
	
	iGrpArcAxisNum_Pu: INT;
	aiGrpArcAxisList:ARRAY [1..MAX_UNIT_NUM] OF INT; (* 当前系轴号列表 *)

	awTemp : ARRAY [0..50] OF WORD;	
	xTest:BOOL;
	
	aiAdjMove_UpCnt : ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiAdjMove_DnCnt : ARRAY [1..MAX_UNIT_NUM] OF INT;
	axLinkage: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axEnable_Arc: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	aiGrpArcIdList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiGrpFollowArcIdList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	iGrpLinkageAxisNum_Pu : int;
	aiGrpLinkageAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	afbKS_FB_AvoidSomeFilmWithoutAdjust: ARRAY [1..2] OF KS_FB_AvoidSomeFilmWithoutAdjust;
	afbKS_FB_SpecialFun : ARRAY [1..2] OF KS_FB_SpecialFun;
	dwSizeof_WrRd: DWORD;
	dwSizeof_Wr: DWORD;
	axFlag_PreStart_Print: ARRAY [1..2] OF BOOL;
	afbKS_FB_GrpFailureProc: ARRAY [1..2] OF KS_FB_GrpFailureProc;
	afbKS_FB_ProcPhaseOptReq: ARRAY [1..2] OF KS_FB_ProcPhaseOptReq;
	afbKS_FB_PreRegisterCorrDeal: ARRAY [1..2] OF KS_FB_PreRegisterCorrDeal;
	iGrpAllStationNum:INT; 
	aiStationList:ARRAY [1..MAX_STATION_NUM] OF INT;

	aliTimeTest: ARRAY [1..20] OF LTIME;
	
//2026.1.24.220244
	axFlag_SlaveUseCmm_Pro: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*色组使用PRO/月光宝盒*)
	axRollerPressDone:  ARRAY [1..2] OF BOOL;
	
	
		aiRtn:ARRAY [1..10] OF INT;
//	apData:ARRAY [1..11] OF DINT;
	iM:BYTE;
//	aliTimeTest: ARRAY [1..20] OF LTIME;
	xtest1:BOOL:=TRUE;
	aiCfgData						: ARRAY [1..30] OF INT := [30(0)];
	stStSampleParam					: StSampleParam;
	
	
	//2026.03.16.141753 | + | 增加日志打印
	afbKS_FB_AlarmDisList : ARRAY [1..2] OF KS_FB_AlarmDisList;
		//xi.hy2026.5.9.110050
	afbKS_FB_GrpFiberMoveCtl:ARRAY[1..2] OF KS_FB_GrpFiberMoveCtl;
		
	//2026.3.2.164029| + | 增加物理轴和逻辑轴的对应，获取扭矩系数 | zhang.hz
	pstStSysStationInf:POINTER TO StSysStationInf;
	stTServoParamReader : TServoParamReader;
	iAxisId: INT;
	iCoreId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	iUnitId:INT;
	iTypeId: INT;
	ausiTemp : ARRAY[1..2] OF USINT;
	// 临时变量（拆分高/低八位，方便理解）
    wLowByte: WORD;   // 低八位（ausiTemp[1]）
    wHighByte: WORD;  // 高八位（ausiTemp[2]）
	xOne_time_count:BOOL:=TRUE;
	awTqCoeff:ARRAY[1..MAX_STATION_NUM] OF WORD;
	iDriverCnt_Core1 : INT; 
	iDriverCnt_Core2 : INT; 
	iDriverId : INT;
END_VAR

{IMPLEMENTATION}
IF g_iRunStepId=RUNSTEP_NormalWork AND g_dwNormalWorkRunNum>3 THEN
	;
ELSE
	RETURN;
END_IF

dwSizeof_WrRd:= SIZEOF(StParam_Diamonds_WrRd);
dwSizeof_Wr:= SIZEOF(StParam_Diamonds_Wr);


Action_Input();

Action_ActCtl();


Action_Output();



