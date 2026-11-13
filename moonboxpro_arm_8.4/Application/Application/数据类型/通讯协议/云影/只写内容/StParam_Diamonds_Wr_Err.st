(*@CES
Name=StParam_Diamonds_Wr_Err
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=384a9a15-d8c8-428e-a7cb-2bf5e78ff116
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Diamonds_Wr_Err :
STRUCT
	(*误差队列保存近50幅误差|
		索引1放置当前最新误差*)
	abyDataRsv						: ARRAY [1..18] OF BYTE;
	(*索引用于金刚判断误差是否更新|
		第二就是用于计算本次刷新曲线到前次刷新曲线间隔幅数*)
	byIndex: BYTE;(*当前索引=粗采样辐数*)
	byNum_Refesh: BYTE;(*当前周期误差刷新辐数=当前索引-上次刷新曲线时的索引*)
	aiError_V_History: ARRAY [1..50] OF INT;(*纵向误差队列*)
	aiError_H_History: ARRAY [1..50] OF INT;(*横向误差队列*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
