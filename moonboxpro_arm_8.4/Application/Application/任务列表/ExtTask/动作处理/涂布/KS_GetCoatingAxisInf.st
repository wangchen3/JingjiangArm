(*@CES
Name=KS_GetCoatingAxisInf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=94653cdc-8513-44b1-a378-a0e4607a5782
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetCoatingAxisInf : BOOL
VAR_INPUT
(*获取涂布轴参数@2024.01.18.094943*)
	i_pstStCoatingAxisInf:POINTER TO StCoatingAxisInf;
	i_paxFlag_PressDne:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_palrGirth_CoatingPrn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*用于计算pt的周长值@未定义到轴参数中*)	
	//2025.07.22.105010
	i_axSwitchOn_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*涂布开关*)
	i_abyAdjMode_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*涂布轴模式*)
	i_axReverseAdj_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*涂布轴调整取反*)
	i_alrAI_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布模拟量*)
	i_alrAI_med_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布中位值*)
	i_alrGirth_Using_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布轴周长*)
	i_aiKp_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF INT;(*涂布Kp*)
	i_aiKi_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF INT;(*涂布Ki*)
	i_aiKd_CoatingPrn: ARRAY [1..MAX_UNIT_NUM] OF INT;(*涂布Kd*)
	i_palrVelocity_CoatingPrn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*涂布轴速度*)
	i_alrGirth:ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*当前轴周长*)
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	xFlag_AxisPressDne: BOOL;
	byDealType: BYTE;(*处理方式@=1 初始化涂布轴参数
								@=2 从轴参数写入到涂布轴参数中#涂布控制输入变量
								@=3 涂布轴参数写入到轴参数中#涂布控制输出变量
								@=4 操作的轴参数值复位*)	
END_VAR

{IMPLEMENTATION}
IF i_pstStCoatingAxisInf<>0 AND
	i_paxFlag_PressDne<>0 AND
	i_palrGirth_CoatingPrn<>0 THEN;
ELSE
	RETURN;
END_IF


(*初始化和获取涂布轴参数*)
FOR iN:=1 TO gc_byCoatingMaxSum_New BY 1 DO
	iUnitId:=i_pstStCoatingAxisInf^.aiAxisIdList[iN];(*之前的轴id*)
	IF iUnitId=-1 THEN(*无效则清除参数*)
		byDealType:=1;
	ELSE(*ID有效@加载参数*)
		byDealType:=2;
		xFlag_AxisPressDne:=i_paxFlag_PressDne^[iUnitId];(*获取新轴的参数*)
	END_IF
	KS_CoatingAxisParamDeal(
		byDealType(*i_byDealType*) , 
		iUnitId(*i_iAxisId*) , 
		xFlag_AxisPressDne(*i_xFlag_AxisPressDne*) , 
		ADR(i_pstStCoatingAxisInf^.astStCoatingAxisParam[iN])(*i_pstStCoatingAxisParam*) , 
		i_palrGirth_CoatingPrn(*i_palrGirth_CoatingPrn*) , 
		0(*i_palrAI_CoatingHMI*) , 
		i_axSwitchOn_CoatingPrn(*i_axSwitchOn_CoatingPrn*) , 
		i_abyAdjMode_CoatingPrn(*i_abyAdjMode_CoatingPrn*), 
		i_axReverseAdj_CoatingPrn(*i_axReverseAdj_CoatingPrn*), 
		i_alrAI_CoatingPrn(*i_alrAI_CoatingPrn*), 
		i_alrAI_med_CoatingPrn(*i_alrAI_med_CoatingPrn*), 
		i_alrGirth_Using_CoatingPrn(*i_alrGirth_Using_CoatingPrn*), 
		i_aiKp_CoatingPrn(*i_aiKp_CoatingPrn*), 
		i_aiKi_CoatingPrn(*i_aiKi_CoatingPrn*), 
		i_aiKd_CoatingPrn(*i_aiKd_CoatingPrn*), 
		i_palrVelocity_CoatingPrn(*i_palrVelocity_CoatingPrn*), 
		i_alrGirth(*i_alrGirth*) );
		
END_FOR