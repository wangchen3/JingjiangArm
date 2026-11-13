(*@CES
Name=StSampleDataForTest
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=737cf5e7-7729-43ac-8b0b-9f7abe5c616b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StSampleDataForTest :
STRUCT
	byIdx		: BYTE;(* 索引/只取低3位/有效范围0~7 *)
	abyBuf_Rs	: ARRAY [0..7,1..8000] OF BYTE;(* 粗采样数据缓存 *)
	abyBuf_Fs	: ARRAY [0..7,1..8000] OF BYTE;(* 精采样数据缓存 *)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
