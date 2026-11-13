(*@CES
Name=KS_FB_CoatingCTL
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=407fa95c-6cd2-4404-bcf4-68a89e2fd197
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CoatingCTL
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴数*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系轴列表*)
	i_pastStIOMap_AxisBasic:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Main_FE;
	i_pastStIOMap_AxisExtra:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;
	i_pstStCoatingAxisInf:POINTER TO StCoatingAxisInf;	
	i_pstStSysParam: POINTER TO StSysParam;
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_palrGirth_CoatingPrn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*用于计算pt的周长值@未定义到轴参数中*)
	i_palrAI_CoatingHMI:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*界面显示的模拟量值@未定义到轴参数中*)
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
//	iGrp:INT;
	//iCoatId:INT;
	lrTemp: LREAL;
	iMaxTemp: INT;
	lrAIDel: LREAL;
	xNotCoatingUnitPressed: BOOL;
	xFlag_PressDne: BOOL;
	afbKS_FB_Coating_Tension: ARRAY [1.. gc_byCoatingMaxSum_New] OF KS_FB_Coating_Tension;
	aiAxisIdList_Last:ARRAY [1..gc_byCoatingMaxSum_New] OF INT;(*2024.01.18.104002*)
	xTensionCtlEn: BOOL;
	iIndex: INT;
	

//2026.8.20.170304	lrGirth_Using_CoatingPrn_In:ARRAY[1..MAX_UNIT_NUM] OF LREAL;(*使用的涂布版周长*)
	xLinkage_In:ARRAY[1..MAX_UNIT_NUM] OF BOOL;(*轴联动状态*)
	rVel_Film_In: REAL;(*料膜速度*)
	byVelLimit_PerCent_IfOf_In: BYTE;(*速度限制百分比*)
	rVel_Cur_In: REAL;(*当前速度*)
	axSwitchOn_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	abyAdjMode_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*涂布轴模式*)
	axReverseAdj_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*涂布轴调整取反*)	
	alrAI_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布模拟量*)
	alrAI_med_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布中位值*)	
	alrGirth_Using_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布轴周长*)
	aiKp_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF INT;(*涂布Kp*)
	aiKi_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF INT;(*涂布Ki*)
	aiKd_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF INT;(*涂布Kd*)
	alrVelocity_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布速度*)
	alrGirth_In:ARRAY[1..MAX_UNIT_NUM] OF LREAL;(*当前轴周长*)
	rPressure_Max_In:LREAL;(*压力传感器最大值*)
	aiAIAxisIdlist_Last_In:ARRAY[1..MAX_UNIT_NUM] OF INT;(*获取ai的轴id列表备份*)
	abySensorType_CoatingPrn_In: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*传感器类型*)
	byCoatingAxisNum_In:BYTE;(*涂布轴个数*)
//	aiAxisIdList_In:ARRAY[1..gc_byCoatingMaxSum_New] OF INT;(*涂布轴列表*)
//	xSwitchOn_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF BOOL;(*涂布开关*)
//	byAdjMode_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF BYTE;(*涂布轴模式*)
//	xReverseAdj_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF BOOL;(*涂布轴调整取反*)
//	rAI_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF REAL;(*涂布轴模拟量*)
//	rAI_med_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF REAL;(*涂布轴中位值*)
//	lrGirth_Using_CoatingPrnHMI_In:ARRAY[1..gc_byCoatingMaxSum_New] OF LREAL;(*涂布轴周长@界面输入*)
//	iKp_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF INT;(*涂布kp*)
//	iKi_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF INT;(*涂布ki*)
//	iKd_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF INT;(*涂布kd*)
//	xFlag_PressDne_In:ARRAY[1..gc_byCoatingMaxSum_New] OF BOOL;(*涂布轴合压*)
//	rAI_CoatingHMI_In:ARRAY[1..gc_byCoatingMaxSum_New] OF REAL;(*涂布模拟量显示*)
//	lrGirth_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF LREAL;(*涂布周长@用于运算pt*)
//	lrVelocity_CoatingPrn_In:ARRAY[1..gc_byCoatingMaxSum_New] OF LREAL;(*涂布速度*)	

	abyAxisList_CoatingPrn_Out:ARRAY[1..MAX_UNIT_NUM] OF BYTE;(*涂布轴列表*)
	byAxisNum_CoatingPrn_Out:BYTE;(*涂布轴个数*)
	pstStCoatingAxisParam:POINTER TO StCoatingAxisParam;
//	aiAxisIdList_Last:ARRAY [1..gc_byCoatingMaxSum_New] OF INT;(*2024.01.18.104002*)	
END_VAR

{IMPLEMENTATION}
Action_Input();
Action_Act();
Action_Output();
