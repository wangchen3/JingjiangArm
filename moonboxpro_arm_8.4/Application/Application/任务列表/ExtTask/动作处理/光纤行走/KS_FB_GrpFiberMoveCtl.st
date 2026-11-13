(*@CES
Name=KS_FB_GrpFiberMoveCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b12c691a-8cd5-455d-8f54-71b0645d77f2
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpFiberMoveCtl
VAR_INPUT
	i_xEn									: BOOL;(*使能*)
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu						: INT; (*色组轴数*)
	i_abyGrpAxisList							: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (*系的轴列表*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN										: INT;
	iM:INT;
	iK:int;
	iUnitId									: INT;
	xFlag_Stop_In: BOOL;(*停机标志*)
	xFlag_Estop_In: BOOL;(*急停标志*)
	xFlag_Print_In: BOOL;(*印刷标志*)
	iFiberVel:INT;
	iFiberVel_Fast:INT;
	xIsDebugMode:BOOL;
	pxFiberMovePosCal_ByUnit:POINTER TO BOOL;
	pxFiberMovePosCal_ByOnline:POINTER TO BOOL;
	xLinkage_In:ARRAY[1..MAX_UNIT_NUM] OF BOOL;(*联动*)
	fbKS_FB_FiberMoveCtl:KS_FB_FiberMoveCtl;
	xUseOnline:BOOL;
	rBasePosByOnline:REAL;
	pxFiberMoveDisRunStart_AllUnit:POINTER TO BOOL;
	rFiberMoveDistance_AllUnit:REAL;
	arDistanceIn_HMI: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	arWidth_FindMarkCenter:ARRAY [1..MAX_UNIT_NUM] OF REAL;
	pxConfirm_AllUnit:POINTER TO REAL;
	axInit_AutoFind: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	sLogMsg:STRING;
	sTimeStamp_Tmp :STRING;
	
	pstStRSV_UnitParam_UnSave: POINTER TO  StRSV_UnitParam_UnSave;
	pstStRSV_UnitParam_Save: POINTER TO  StRSV_UnitParam_Save;
	pstStIOMap_Axis_FE : POINTER TO StIOMap_Axis_FE;
	
	//按钮1变量
	axClick_FiberMoveBtn1 : ARRAY [1..MAX_UNIT_NUM] OF BOOL ;	(*按钮1单击事件*)
	axDoubleClick_FiberMoveBtn1 : ARRAY [1..MAX_UNIT_NUM] OF BOOL ;(*按钮1双击事件*)
	axHold_FiberMoveBtn1 : ARRAY [1..MAX_UNIT_NUM] OF BOOL ;(*按钮1长按事件*)
	awCnt_FiberMoveBtn1 : ARRAY [1..MAX_UNIT_NUM] OF WORD ;(*按钮1状态*)
	
	//按钮2变量
	axClick_FiberMoveBtn2 : ARRAY [1..MAX_UNIT_NUM] OF BOOL ;	(*按钮2单击事件*)
	axDoubleClick_FiberMoveBtn2 : ARRAY [1..MAX_UNIT_NUM] OF BOOL ;(*按钮2双击事件*)
	axHold_FiberMoveBtn2 : ARRAY [1..MAX_UNIT_NUM] OF BOOL ;(*按钮2长按事件*)
	awCnt_FiberMoveBtn2 : ARRAY [1..MAX_UNIT_NUM] OF WORD ;(*按钮2状态*)
	
	byFiberMove_MicroMoveStep:BYTE;(*光纤行走微调步进量@mm*)
	axFindMarkCenter_Local: ARRAY [1..MAX_UNIT_NUM] OF BOOL ;(*色组本地找中使能开关*)
	
	byArcAxisNum:BYTE;//套色轴数量
	byArcId_Final:byte;//套色最后一个轴ID
END_VAR

{IMPLEMENTATION}

Action_Input();
Action_ACT();
Action_Output();