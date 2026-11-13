(*@CES
Name=StGantryAxisInf
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=fa0f510b-ab81-451a-acb1-1ff626d792f3
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StGantryAxisInf :(*龙门轴信息*)
STRUCT
	xValid						:BOOL;(*龙门轴有效*)
	iAxisId						:INT;(*色组号*)
	(*FUNCID_PRNROLLER_GANTRY->FUNCID_NETROLLER_GANTRY*)
	iFuncId						:stEnumFuncId;(*版辊\网纹辊*)
	iCoreId						:INT;(*核id*)
	iLogicAxisId_M				:INT;(*操作侧逻辑轴id*)
	iLogicAxisId_G				:INT;(*传动侧逻辑轴id*)
	iLogicAxisId_SuperPos		:INT;(*逻辑轴id@叠加轴*)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
