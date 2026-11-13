(*@CES
Name=StAbsEncIOModule
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=efeeddf2-9261-434f-a051-5c43e14c5972
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StAbsEncIOModule :(*专用绝对值编码器的模块IO数据@非标固件实现*)
STRUCT
	wIX:WORD;(*输入数据*)
	wQX:WORD;(*输出数据*)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
