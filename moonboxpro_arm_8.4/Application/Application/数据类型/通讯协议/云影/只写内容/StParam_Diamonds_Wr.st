(*@CES
Name=StParam_Diamonds_Wr
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=0233bf28-5ede-42fb-8a30-2c60d553db67
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Diamonds_Wr :
STRUCT
	stStParam_Diamonds_Wr_SysSts: StParam_Diamonds_Wr_SysSts;(*系统只写*)
	stStParam_Diamonds_Wr_RdSam	: StParam_Diamonds_Wr_RdSam;
	
//	byNum_Err_History_Valid: BYTE;(*当前状态下误差曲线队列有效色组数*)
	astStParam_Diamonds_Wr_Err: ARRAY [1..MAX_UNIT_NUM] OF StParam_Diamonds_Wr_Err;
	
	astStParam_Diamonds_Wr_RunSts: ARRAY [1..MAX_STATION_NUM] OF StParam_Diamonds_Wr_RunSts;
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
