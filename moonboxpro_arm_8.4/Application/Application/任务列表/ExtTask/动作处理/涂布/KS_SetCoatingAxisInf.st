(*@CES
Name=KS_SetCoatingAxisInf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=aab75e54-4a14-456c-b5e5-3fbc7559278d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetCoatingAxisInf : bool
(*设置涂布轴信息@写入到轴参数中*)
VAR_INPUT
	i_pstStCoatingAxisInf:POINTER TO StCoatingAxisInf;
	i_aiAxisIdList_Last:POINTER TO ARRAY [1..gc_byCoatingMaxSum_New]OF INT;(*备份的轴列表*)
	i_palrGirth_CoatingPrn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*用于计算pt的周长值@未定义到轴参数中*)
	i_palrAI_CoatingHMI:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*界面显示的模拟量值@未定义到轴参数中*)
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
	iM: INT;
	iUnitId: INT;
	byDealType: BYTE;(*处理方式@=1 初始化涂布轴参数
								@=2 从轴参数写入到涂布轴参数中#涂布控制输入变量
								@=3 涂布轴参数写入到轴参数中#涂布控制输出变量
								@=4 操作的轴参数值复位*)
	aiAxisIdList_Last:ARRAY [1..gc_byCoatingMaxSum_New] OF INT;(*2024.01.18.104002*)
END_VAR

{IMPLEMENTATION}
IF i_pstStCoatingAxisInf<>0 AND
	i_aiAxisIdList_Last<>0 AND
	i_palrGirth_CoatingPrn<>0 AND
	i_palrAI_CoatingHMI<>0 THEN;
ELSE
	RETURN;
END_IF
aiAxisIdList_Last:=i_aiAxisIdList_Last^;(*获取*)

(*设置涂布轴参数*)
FOR iN:=1 TO i_pstStCoatingAxisInf^.byCoatingAxisNum BY 1 DO
	iUnitId:=i_pstStCoatingAxisInf^.aiAxisIdList[iN];(*现在轴id*)
	IF iUnitId=-1 THEN(*无效则*)
		byDealType:=0;(*啥也不干*)
	ELSE(*ID有效@写入到轴参数中*)
		byDealType:=3;
	END_IF

	KS_CoatingAxisParamDeal(
		byDealType(*i_byDealType*) , 
		iUnitId(*i_iAxisId*) , 
		FALSE(*i_xFlag_AxisPressDne*) , 
		ADR(i_pstStCoatingAxisInf^.astStCoatingAxisParam[iN])(*i_pstStCoatingAxisParam*) , 
		i_palrGirth_CoatingPrn(*i_palrGirth_CoatingPrn*) , 
		i_palrAI_CoatingHMI(*i_palrAI_CoatingHMI*) , 
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

FOR iN:=1 TO gc_byCoatingMaxSum_New BY 1 DO
	iUnitId:=aiAxisIdList_Last[iN];(*之前的轴id*)
	IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM THEN
		byDealType:=0;
		IF i_pstStCoatingAxisInf^.byCoatingAxisNum>0 THEN
			FOR iM:=1 TO i_pstStCoatingAxisInf^.byCoatingAxisNum BY 1 DO
				IF i_pstStCoatingAxisInf^.aiAxisIdList[iM]=iUnitId THEN(*还在呢*)
					EXIT;
				ELSE(*已经被删除了*)
					IF iM=i_pstStCoatingAxisInf^.byCoatingAxisNum THEN(*列表里没了*)
						byDealType:=4;(*复位操作的值*)
					END_IF
				END_IF
			END_FOR
		ELSE(*一个都没有*)
			byDealType:=4;(*复位操作的值*)
		END_IF

	KS_CoatingAxisParamDeal(
		byDealType(*i_byDealType*) , 
		iUnitId(*i_iAxisId*) , 
		FALSE(*i_xFlag_AxisPressDne*) , 
		ADR(i_pstStCoatingAxisInf^.astStCoatingAxisParam[iN])(*i_pstStCoatingAxisParam*) , 
		i_palrGirth_CoatingPrn(*i_palrGirth_CoatingPrn*) , 
		i_palrAI_CoatingHMI(*i_palrAI_CoatingHMI*) , 
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
	END_IF
END_FOR

aiAxisIdList_Last:=i_pstStCoatingAxisInf^.aiAxisIdList;(*更新备份的涂布轴列表*)
i_aiAxisIdList_Last^:=aiAxisIdList_Last;(*写入*)