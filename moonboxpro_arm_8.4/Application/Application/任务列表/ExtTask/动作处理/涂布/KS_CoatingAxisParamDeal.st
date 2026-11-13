(*@CES
Name=KS_CoatingAxisParamDeal
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f4156371-7451-43fd-b965-d24d4d478a2f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CoatingAxisParamDeal : BOOL
VAR_INPUT
(*涂布轴参数处理*)
	i_byDealType:BYTE;(*处理方式@=1 初始化涂布轴参数
								@=2 从轴参数写入到涂布轴参数中#涂布控制输入变量
								@=3 涂布轴参数写入到轴参数中#涂布控制输出变量
								@=4 操作的轴参数值复位*)
	i_iAxisId:INT;
	i_xFlag_AxisPressDne:BOOL;(*轴的合压状态@经过延时后输出标志*)
	i_pstStCoatingAxisParam:POINTER TO StCoatingAxisParam;
	i_palrGirth_CoatingPrn:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*用于计算pt的周长值@未定义到轴参数中*)
	i_palrAI_CoatingHMI:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*界面显示的模拟量值@未定义到轴参数中*)	
//2025.7.3.175755
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
END_VAR

{IMPLEMENTATION}
CASE i_byDealType OF
	1:(*初始化涂布参数*)
		IF i_pstStCoatingAxisParam<>0 THEN
			SysMemSet(i_pstStCoatingAxisParam,0,SIZEOF(i_pstStCoatingAxisParam^));
			i_pstStCoatingAxisParam^.iUnitId:=-1;
		END_IF
	2:(*从轴参数写入到涂布轴参数中#涂布控制输入变量*)
		IF i_iAxisId>0 AND i_iAxisId<MAX_UNIT_NUM AND(*轴号合法*)
	
			i_pstStCoatingAxisParam<>0 THEN

			i_pstStCoatingAxisParam^.iUnitId						:= i_iAxisId;
			i_pstStCoatingAxisParam^.xSwitchOn_CoatingPrn			:= i_axSwitchOn_CoatingPrn[i_iAxisId];(*涂布开关*)
			i_pstStCoatingAxisParam^.byAdjMode_CoatingPrn			:= i_abyAdjMode_CoatingPrn[i_iAxisId];(*涂布轴模式*)
			i_pstStCoatingAxisParam^.xReverseAdj_CoatingPrn			:= i_axReverseAdj_CoatingPrn[i_iAxisId]	;(*涂布轴调整取反*)
			i_pstStCoatingAxisParam^.rAI_CoatingPrn					:= i_alrAI_CoatingPrn[i_iAxisId];(*涂布轴模拟量*)
			i_pstStCoatingAxisParam^.rAI_med_CoatingPrn				:= i_alrAI_med_CoatingPrn[i_iAxisId];(*涂布轴中位值*)
			i_pstStCoatingAxisParam^.lrGirth_Using_CoatingPrn		:= i_alrGirth_Using_CoatingPrn[i_iAxisId];(*涂布轴周长@界面输入*)
			i_pstStCoatingAxisParam^.iKp_CoatingPrn					:= i_aiKp_CoatingPrn[i_iAxisId]	;(*涂布kp*)
			i_pstStCoatingAxisParam^.iKi_CoatingPrn					:= i_aiKi_CoatingPrn[i_iAxisId];(*涂布ki*)
			i_pstStCoatingAxisParam^.iKd_CoatingPrn					:= i_aiKd_CoatingPrn[i_iAxisId]	;(*涂布kd*)
			i_pstStCoatingAxisParam^.xFlag_PressDne					:= i_xFlag_AxisPressDne			;(*涂布轴合压*)
		END_IF
	3:(*涂布轴参数写入到轴参数中*)
		IF i_iAxisId>0 AND i_iAxisId<MAX_UNIT_NUM AND(*轴号合法*)
			i_pstStCoatingAxisParam<>0 AND
			i_palrGirth_CoatingPrn<>0 AND
			i_palrAI_CoatingHMI<>0 THEN

			i_palrAI_CoatingHMI^[i_iAxisId]			:= i_pstStCoatingAxisParam^.rAI_CoatingHMI		 	;(*涂布模拟量显示*)
			i_palrGirth_CoatingPrn^[i_iAxisId]		:= i_pstStCoatingAxisParam^.lrGirth_CoatingPrn	 	;(*涂布周长@用于运算pt*)
			i_palrVelocity_CoatingPrn^[i_iAxisId]	:= i_pstStCoatingAxisParam^.lrVelocity_CoatingPrn	;(*涂布速度*)
		END_IF

	4:(*操作的轴参数值复位*)
		IF i_iAxisId>0 AND i_iAxisId<MAX_UNIT_NUM AND(*轴号合法*)
			i_palrGirth_CoatingPrn<>0 AND
			i_palrAI_CoatingHMI<>0 THEN

			i_palrAI_CoatingHMI^[i_iAxisId]			:= 0;(*涂布模拟量显示*)
			i_palrGirth_CoatingPrn^[i_iAxisId]		:= i_alrGirth[i_iAxisId];(*赋值为当前周长*)
			i_palrVelocity_CoatingPrn^[i_iAxisId]	:= 0;(*涂布速度*)
		END_IF
ELSE;(*啥也不干*)
END_CASE