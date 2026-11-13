(*@CES
Name=StPdu_Dn_93_Dep
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=233641f5-af31-41e2-841e-6ff9f436d5aa
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPdu_Dn_93_Dep :
STRUCT
	dwControlComplexBits		:DWORD;(*开关状态			*)
	wHz_UnitInkRoller_CurrWR	:WORD ;(*递墨辊最终写入频率	*)
	wHz_UnitScraper_CurrWR		:WORD ;(*刮刀写入频率		*)
	wHz_UnitHotWind_CurrWR		:WORD ;(*热风写入频率		*)
	wHz_UnitHotWind2_CurrWR		:WORD ;(*热风2写入频率		*)
	rPV_UnitTemCtl				:REAL ;(*当前温度			*)
	wSTS_UnitTemCtl				:WORD ;(*温控状态			*)
(*2025.8.6.212214增加*)
	wHotWind_Print				:WORD;(*热风打开色组号*)
	byDriverType_Hor			:BYTE;(*横向的驱动器类型*)
	wPulseCtlInf  				:WORD;(*脉冲控制信息*)
	wPulse_1r					:WORD;(*1圈的脉冲数*)
	byPulseCtl_DisPerPulse 		:BYTE;(*单位脉冲距离*)
	byPulseCtlBit 				:BYTE;(*脉冲控制位*)
	abyRsv_93					:ARRAY [1..30] OF BYTE ;(*工艺参数预留		*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
