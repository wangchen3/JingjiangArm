(*@CES
Name=KS_FB_GrpHeatingCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e2841ed9-9770-4b1d-9b9f-08dd60591d62
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpHeatingCtrl
(*2020.10.13.133143  重新处理加热逻辑功能|Liu.yt*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpAxisNum_Pu: INT;(*色组轴数*)
	i_iGrpId : INT; 
	i_iAxisId_If: INT; 
	i_iAxisId_Of: INT;
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系的轴列表*)
	i_pstStEvtReq:POINTER TO StEvtReq;
	i_xAirHotFlag:BOOL;
	i_paxHotBlowerEn: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*热风启动标志*)
	(*2022.4.10.161618*)
	i_byHeatingOutWay_III	: BYTE;(*加热三档输出方式选择|0: 同时调整三档
														  1: 调整最高档
														  2: 超过1档保留最低档*)
	i_iCycleTime_Plc:INT;(*2024.01.22.142933+*)
	i_pstStSysParam  : POINTER TO StSysParam   ; (*系统参数*)
	i_PastStIOMap_Axis_Extra_FE:  POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE  ; 
	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1参数无效|*)
	o_xHeatingFlag: BOOL;		(*加热启动标志*)
END_VAR
VAR
	fbKS_FB_HeatTreatmentSys: KS_FB_BlowerFunction;

	axAxisStartKnob: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axStartOrStopBtn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axNeedStop: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisStarted: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisStartEn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xLastAirHotFlag: BOOL;
	arTemperature_Cur: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	
	iDelayMsec_Heat_In : INT ; 
	axHeating_I_In:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*一档加热输入*)
	axHeating_II_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*二档加热输入*)
	axHeating_III_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*三档热输入*)
	axHeating_Button_In :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*加热按钮输入*)
	axTemReachToTarget_In : ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*加热未到设定标志*)
	axOvertemperature_In   : ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*超温标志*)
	
	
	axLamp_Heating_Out :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*加热输出*)
	axRel_Heating_I_Out	: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*一档输出*)
	axRel_Heating_II_Out  : ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*二档输出*)
	axRel_Heating_III_Out  : ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*三档输出*)
	axLamp_AllHeating_Out :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*全体加热输出*)
	xLamp_AllHeating_Out : BOOL;(*全体加热输出*)
	pstStIOMap_Axis_Extra_FE:  POINTER TO  StIOMap_Axis_Extra_FE  ;
	pstStGrpParam_Save:  POINTER TO  StGrpParam_Save  ;
	pstStUnitParam_Save: POINTER TO  StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	iUnitId : INT ;
	iN : INT ;
	iGrp : INT  ; 
END_VAR
{IMPLEMENTATION}
Action_Input();

Action_ActCtl() ;

Action_Output();