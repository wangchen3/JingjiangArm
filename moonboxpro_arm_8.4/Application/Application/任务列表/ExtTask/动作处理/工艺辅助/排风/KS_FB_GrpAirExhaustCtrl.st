(*@CES
Name=KS_FB_GrpAirExhaustCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e7181a12-d86c-4b38-8579-87f11d61154d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpAirExhaustCtrl(*排风控制*)
(*2025.1.15.103210@模拟量排风输出有问题-只支持手动修改*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpAxisNum_Pu: INT; (*色组轴数*)
	i_iGrpId :INT; 
	i_iAxisId_If: INT;
	i_iAxisId_Of: INT;
	
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	i_pstStEvtReq:POINTER TO StEvtReq;
	i_xStopAirExhaustWhenEstop:BOOL;(*急停停止排风标志|有效了和急停关联，无效则不影响*)
	i_iCycleTime_Plc:INT;(*2024.01.22.142933+*)
	i_iGrpLinkageAxisNum_Pu: INT; (* 系的色组联动轴数量|色组按照从小到大排序了 *)
	i_xFlag_Estop : BOOL; 
	i_iDelayMsec_ExhPowerMode : INT ;
 	i_iDelayMsec_HeatBlower : INT ; 
	i_rVel_Max : LREAL ; 
	i_rVel_Cur: LREAL ; 
	i_pstStSysParam  : POINTER TO StSysParam   ; (*系统参数*)
	i_pastStIOMap_Axis_Extra_FE:  POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE  ; 
	i_pastStIOMap_Main_FE: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1参数无效|*)
	o_xAirExhaustFinishFlag:BOOL;(*排风完成标志*)

END_VAR

VAR
	iN: INT;
	iAxisId: INT;
	xAirExhaustFlag: BOOL;(*排风标志*)
	xAllExhBlowerErr_Flag:BOOL;
	iExhStartStep: INT;
	iDelay_ExhStartCount: INT;
	iDelay_ExhChangeCount: INT;
	axAirExhaustEn_Auto:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axPreBtnAirExhaustON:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axPreAirExhaustRun:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	iAirExhaustOpenSum:INT;
	iAirExhaustDelayCount:INT;
	xAirExhaustDelayRunFinish: BOOL;
	xAutoAirExhaustFlag:BOOL;

	(*频率逻辑处理|2020.11.2.161456*)
	byFreq: BYTE;
	byFreqCur: BYTE;(*当前频率值*)
	byFreqUpper: BYTE;
	rFreqCoeff: REAL;
	(*2020.11.12.114242*)
	byNormalFreq: BYTE;(*常用频率*)
	xAirExhaustStopConnecEstop: BOOL;(*停止排风|和急停关联标志*)
	iCustomerNameId: INT;
	iExhaustDamperCtlNum: INT;
	iExhaustLinkageCtlNum: INT;(*新增|2025.4.27.172219*)
	
	byStepFreqExhaust:BYTE;(*排风频率步进量*)
	
	axAllExhBlower_Err_Up_In  : ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axAllExhBlower_Err_Dn_In : ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axAirExhaustSwitch_In  : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAirExhaustButton_In : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	arHz_UnitExhaust_ManuallySet_In : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	abyFreq_ExhaustAir_In: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	byFreqUpper_ExhaustAir_In:  BYTE;
	uiFreqCoeff_Auto_ExhaustAir_In :  UINT;
	byFreqMax_ExhaustAir_In :  BYTE;
	byFreqMin_ExhaustAir_In :  BYTE;
	
	axlamp_AllExhBlower_Up_Out : ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axlamp_AllExhBlower_Dn_Out : ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axRel_AllExhBlower_Up_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axRel_ModeTriangle_AllExhBlower_Up_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axRel_ModeStar_AllExhBlower_Up_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axRel_AllExhBlower_Dn_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axRel_ModeTriangle_AllExhBlower_Dn_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axRel_ModeStar_AllExhBlower_Dn_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	axAirExhaustEn_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL; 
	abyFreqCur_ExhaustAir_Out: ARRAY [1..MAX_UNIT_NUM] OF BYTE; 
	awAO_AllExhBlower_Up_Out : ARRAY [1..MAX_UNIT_NUM] OF WORD; 	
	awAO_AllExhBlower_Dn_Out : ARRAY [1..MAX_UNIT_NUM] OF WORD; 
	
	pstStUnitParam_Save: POINTER TO  StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStIOMap_Axis_Extra_FE:  POINTER TO  StIOMap_Axis_Extra_FE  ;
	pstStGrpParam_Save:  POINTER TO  StGrpParam_Save  ;
END_VAR
{IMPLEMENTATION}
Action_Input();

Action_ActCtl() ;

Action_Output();