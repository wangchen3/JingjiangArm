(*@CES
Name=KS_FB_GrpPreHotBlowerCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9f092317-3841-4a3f-89f9-424e76f2fa1b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpPreHotBlowerCtrl
(*预加热，预热风*)
(*2023.09.11.081857 增加预热风\预加热使用按钮或者旋钮选择|*)
(*2023.12.07.145211 标志赋值写错了*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpAxisNum_Pu: INT; (*色组轴数*)
	
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	i_pstStEvtReq:POINTER TO StEvtReq;
	i_xUseButton_PreHotBlower:BOOL;(*预热风使用按钮*)
	i_xUseButton_PreHeating:BOOL;(*预加热使用按钮*)

	i_xflag_Estop : BOOL; 
	i_xflag_print : BOOL; 
	i_xMachineRev : BOOL; 
	i_xflag_printPreHeating : BOOL; 
	i_PastStIOMap_Axis_Extra_FE:  POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE  ; 
	
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1参数无效|*)

END_VAR

VAR
	iN: INT;
	iUnitId: INT;
	
	(*2023.09.11.082309*)
	axPreHotBlowerOpen: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*预热风打开*)
	axLastPreHotBlower:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*预热风输入信号保存值*)
	axPreHeatingOpen: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*预加热打开*)
	axPreHeatingOpen_Print: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*预加热印刷打开*)
	axLastPreHeating:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*预热输入信号保存值*)
	iM: INT;
	
	
	axPreHotBlower_In  : ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	axPreHotBlower_Err_In: ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	axPreHeating_In: ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	axPreHeating_Err_In: ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	
	
	axOutputRel_PreHotBlower : ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	axOutputLamp_PreHotBlower: ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	axOutputRel_PreHeating: ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	axOutputLamp_PreHeating: ARRAY[1..MAX_UNIT_NUM] OF BOOL; 
	
	pstStIOMap_Axis_Extra_FE:  POINTER TO  StIOMap_Axis_Extra_FE  ;
END_VAR
{IMPLEMENTATION}

Action_Input();

Action_ActCtl() ;

Action_Output();