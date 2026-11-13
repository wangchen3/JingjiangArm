(*@CES
Name=StParam_UnitHMI485_Wr_82
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=726df55c-874d-4dcc-bc3a-20d650b779ca
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_UnitHMI485_Wr_82 ://全部作为预留区域||2026.1.4.135806
STRUCT
	byPackId: BYTE;//先放一个标志标记通讯只写内容的格式：
	//=1--StParam_UnitHMI485_Wr_81
	//=2--StParam_UnitHMI485_Wr_82
	//=3--StParam_UnitHMI485_Wr_83	
	abyRsv_LowComm: ARRAY [1..239] OF BYTE;(*低速只写通讯保留位*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
