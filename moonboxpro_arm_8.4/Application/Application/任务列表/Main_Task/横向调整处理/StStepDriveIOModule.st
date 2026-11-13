(*@CES
Name=StStepDriveIOModule
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=050a5971-e7ba-4c31-b40e-01a320b97a7e
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StStepDriveIOModule :
STRUCT
	wIX:WORD;(*输入数据*)(*0：15位为数字量输入*)
	wQX:WORD;(*输出数据*)(*2：9位为数字量继电器输出位*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
