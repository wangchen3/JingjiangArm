(*@CES
Name=StVarList
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=8fe36071-a98d-4a3e-9449-8cd49bd30799
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
//xi.hy新增@七号以后
TYPE StVarList:
STRUCT
	wVirTual_Cnt:WORD;//虚拟码盘计数
	wVirTual_Sts:WORD;//虚拟码盘状态
	dwTime_Lock:DWORD;//锁存时间
	dwEnc_Lock:DWORD;//锁存编码器
END_STRUCT
END_TYPE

{IMPLEMENTATION}
