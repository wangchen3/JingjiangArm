(*@CES
Name=KS_FB_GrpCoolBlowerCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1cc9b71b-01ee-4c63-826f-1c195b3708a6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpCoolBlowerCtrl
(*2020.10.14.090348重新处理*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId : INT; 
	i_iAxisId_If: INT; 
	i_iAxisId_Of: INT;
	i_iGrpAxisNum_Pu: INT; (*色组轴数*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	i_pstStEvtReq:POINTER TO StEvtReq;
	i_xCoolBlowerByKnob:BOOL;(*单轴启动根据旋钮开关标志|用于全体开关控制启动的逻辑|无则不输入*)
	i_xStopCoolBlowerWhenEstop:BOOL;(*急停停止热风标志|有效了和急停关联，无效则不影响*)
	i_iCycleTime_Plc:INT;(*2024.01.22.142933+*)
	i_PastStIOMap_Axis_Extra_FE:  POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE  ; 

	i_pastStIOMap_Main_FE	: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)	
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1参数无效|*)
	o_xCoolBlowerFlag:BOOL;
END_VAR
VAR
	fbKS_FB_CoolBlowerSys: KS_FB_BlowerFunction;
	axAxisStartKnob: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axStartOrStopBtn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axNeedStop: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisStarted: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisStartEn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xCoolBlowerEn: BOOL;
	iStartedSum: INT;(*启动的轴数*)
	xFlag_Estop_In : BOOL; 
	
	axCoolBlower_In			:ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axCoolBlower_Button_In			:ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	
	
	xCoolBlower_In			: BOOL;	
	xCoolBlower_Button_In			: BOOL;
	
	axLamp_CoolBlower_Out			: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axRel_CoolBlower_Out			: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	axLamp_AllCoolBlower_Out	: ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	xLamp_AllCoolBlower_Out	: BOOL;	

	pstStIOMap_Axis_Extra_FE:  POINTER TO  StIOMap_Axis_Extra_FE  ; 
	
	iN: INT;
	iUnitId: INT;(*轴号*)	
	iGrp: INT;
END_VAR
{IMPLEMENTATION}
Action_Input();

Action_ActCtl() ;

Action_Output();