(*@CES
Name=StPdu_Up_05
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=a7996cd8-0fa8-4259-90b6-cff49420832c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPdu_Up_05 :
STRUCT
	dwSlaveVer					:DWORD;(*从站程序版本	*)
	wHz_UnitInkRoller_CurrrRD	:WORD ;(*读取的递墨辊频率*)
	wSts_UnitInkRoller			:WORD ;(*读取的递墨辊状态*)
	wHz_UnitScraper_CurrRD		:WORD ;(*读取的刮刀频率	*)
	wSTS_UnitScraper			:WORD ;(*读取的递墨辊状态*)
	wHz_UnitHotWind_CurrRD		:WORD ;(*读取的热风频率	*)
	wSTS_UnitHotWind			:WORD ;(*读取的热风状态	*)
	wHz_UnitHotWind2_CurrRD		:WORD ;(*读取的热风2频率	*)
	wSTS_UnitHotWind_2			:WORD ;(*读取的热风2状态	*)
	byCnt_Comm					:BYTE ;(*ARM通讯计数		*)
	(*2025.8.6.212503增加*)
	iEncValue_Hor				:INT;(*横向编码器值*)
	byStsBit2					:BYTE;(*状态位*)
	wPulse_Rd					:WORD;(*输出的脉冲数*)
	byStsBit					:BYTE;(*油墨槽状态*)

	iResult_VFollowpre_1stDerivate	: INT;(*YZJ计算误差*)(*18-2=16*)
	//2025.11.13.105908||上传基线和峰值16-8=8
	uiPeakValue_t1				: UINT;
	uiPeakValue_t2				: UINT;
	uiBaseUse_t1				: UINT;
	uiBaseUse_t2				: UINT;

	//全自动套印，已经用完了8个预留 8-8=0
	iCurLabelPos :INT;(*本色三角标位置，点数*)
	iPreLabelPos :INT;(*前色三角标位置，点数*)
	byFlag_CommFromSlave					: BYTE;(*bit0 xFlag_FindFirstSuccess 当前色成功找到 ;
													bit1 xFlag_FindPreSuccess 前一色成功找到
													bit2 当前色寻找完成
													bit3 精采样宽度计算完成
													bit4 从站全自动套印空闲中
													bit5 从站触发找本色
													bit6 从站触发找混色*)

	byDetectedSignalCount : BYTE;(*当前检测到色标个数*)
	byMarkStep:BYTE;(*当前全自动套印步骤*)
	byWidthRS :BYTE;//粗采样计算色标宽度 0.1mm
	
	//abyRsv_05					:ARRAY [1..8] OF BYTE ;(*参数预留		*)	
END_STRUCT
END_TYPE


{IMPLEMENTATION}
