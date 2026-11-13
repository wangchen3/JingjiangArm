(*@CES
Name=StCoatingAxisParam
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=8a071cba-fd95-4a8c-93c6-fe3e9b0305b5
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StCoatingAxisParam :(*涂布轴参数@2024.01.18.093551*)
STRUCT
	iUnitId							:INT;(*轴id@默认-1*)
	xSwitchOn_CoatingPrn			:BOOL;(*涂布开关*)
	byAdjMode_CoatingPrn			:BYTE;(*涂布轴模式*)
	xReverseAdj_CoatingPrn			:BOOL;(*涂布轴调整取反*)
	rAI_CoatingPrn					:REAL;(*涂布轴模拟量*)
	rAI_med_CoatingPrn				:REAL;(*涂布轴中位值*)
	lrGirth_Using_CoatingPrn		:LREAL;(*涂布轴周长@界面输入*)
	iKp_CoatingPrn					:INT;(*涂布kp*)
	iKi_CoatingPrn					:INT;(*涂布ki*)
	iKd_CoatingPrn					:INT;(*涂布kd*)
	xFlag_PressDne					:BOOL;(*涂布轴合压*)

	rAI_CoatingHMI					:REAL;(*涂布模拟量显示*)
	lrGirth_CoatingPrn				:LREAL;(*涂布周长@用于运算pt*)
	lrVelocity_CoatingPrn			:LREAL;(*涂布速度*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
