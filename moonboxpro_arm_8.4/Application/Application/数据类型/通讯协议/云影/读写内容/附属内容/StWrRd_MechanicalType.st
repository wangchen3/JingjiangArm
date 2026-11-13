(*@CES
Name=StWrRd_MechanicalType
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=03e174c8-9f43-4388-8870-9d21820ee6bb
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StWrRd_MechanicalType :
STRUCT
	byMachanicalTypeId: BYTE;(*1摆臂2直压3PVC直压4等料长5力达欧诺直压*)
	abyrsv: ARRAY [1..19] OF BYTE;//先放19个字节在这里放其他预套准相关内容|例如按钮
	abyBuffMechanicalParam: ARRAY [1..200] OF BYTE;(*机械参数*)
	//预留200字节用于通讯机械参数，
		//根据byMachanicalTypeId变量切换通讯内容
		//StMechanicalParam_01/
		//StMechanicalParam_02/
		//StMechanicalParam_03/
		//StMechanicalParam_05	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
