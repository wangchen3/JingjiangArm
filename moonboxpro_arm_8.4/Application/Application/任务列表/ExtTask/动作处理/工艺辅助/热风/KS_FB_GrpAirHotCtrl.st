(*@CES
Name=KS_FB_GrpAirHotCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1e8a028d-d061-44b5-a7fa-8fcf2eecc751
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpAirHotCtrl
(*2020.10.13.133218 重新处理热风功能|Liu.yt*)
(*2024.7.1.165726 循环索引增加到了i_iGrpAxisTotalNum*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpAxisNum_Pu: INT; (*色组轴数*)
	i_iAxisId_If  : INT ;
	i_iAxisId_Of : INT;
	i_iGrpId	:INT ;  
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	i_pstStEvtReq:POINTER TO StEvtReq;
	i_xHotBlowerByKnob:BOOL;(*单轴启动根据旋钮开关标志|用于全体开关控制启动的逻辑|无则不输入*)
	i_xAirExhaustFinishFlag:BOOL;(*排风完成标志*)
	i_xAirExhaustLimit:BOOL;(*排风限制热风*)
	i_xStopHotBlowerWhenEstop:BOOL;(*急停停止热风标志|有效了和急停关联，无效则不影响*)
	i_iCycleTime_Plc:INT;(*2024.01.22.142933+*)
	
	i_pstStSysParam  : POINTER TO StSysParam   ; (*系统参数*)
	i_PastStIOMap_Axis_Extra_FE:  POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE  ; 
	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1参数无效|*)
	o_xHotBlowerFlag:BOOL;(*热风启动标志*)
	o_xFlag_HotBlowerStopping:BOOL;(*热风停止中*)
	o_axHotBlowerEn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*热风启动标志|停止时和实际输出存在不一致*)
	o_axHotBlowerEn_Act: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*热风启动标志和读取实际反馈*)
END_VAR
VAR

	fbKS_FB_HotBlowerSys: KS_FB_BlowerFunction;
	axAxisStartKnob: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axStartOrStopBtn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axNeedStop: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisStartEn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xHotBlowerEn: BOOL;
	iStartedSum: INT;(*启动的轴数*)
	iN: INT;
	iUnitId:INT;
	
	atHotBlowerDelayTimeSa: ARRAY [1..MAX_UNIT_NUM] OF TIME;
	byHotBlowerStopDelayTime_In : BYTE ; 
	iDelayMsec_HeatBlower_In : INT  ; 
	xFlag_Estop_In: BOOL; 
	axHotBlower_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axHotBlower_Button_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axHotBlower_Err_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axLamp_Heating_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axHotBlower_Opened_Act_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	axRel_HotBlower_Out : ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axLamp_HotBlower_Out: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axLamp_AllHotBlower_Out:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	xLamp_AllHotBlower_Out: BOOL; 
	
	pstStUnitParam_Save: POINTER TO  StUnitParam_Save;
	pstStIOMap_Axis_Extra_FE:  POINTER TO  StIOMap_Axis_Extra_FE  ; 
END_VAR
{IMPLEMENTATION}
Action_Input();

Action_ActCtl() ;

Action_Output();