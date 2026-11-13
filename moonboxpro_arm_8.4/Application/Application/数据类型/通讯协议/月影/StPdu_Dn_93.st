(*@CES
Name=StPdu_Dn_93
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=1bb7fc47-9e93-466c-a1c5-84993bb7c104
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPdu_Dn_93 :
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
	
	//2026.1.24.193136增加色组监控信息下发niu.j||扭矩监控总共14字节|30-14=16
	iTorque_PrnRoller			: INT;//色组版辊扭矩|%/Nm。实际扭矩*10，保留一位小鼠
	iTorque_NetRoller			: INT;//色组网辊扭矩|%/Nm。实际扭矩*10，保留一位小鼠
	iTorque_BottomRoller		: INT;//色组底辊扭矩|%/Nm。实际扭矩*10，保留一位小鼠
	iTorque_Prn_PressRoller_M	: INT;//色组版辊压力操作侧扭矩|%/Nm。实际扭矩*10，保留一位小鼠
	iTorque_Prn_PressRoller_G	: INT;//色组版辊压力传动侧扭矩|%/Nm。实际扭矩*10，保留一位小鼠
	iTorque_Net_PressRoller_M	: INT;//色组网辊压力操作侧扭矩|%/Nm。实际扭矩*10，保留一位小鼠
	iTorque_Net_PressRoller_G	: INT;//色组网辊压力传动侧扭矩|%/Nm。实际扭矩*10，保留一位小鼠

	iVel_PrnRoller				: INT;//版辊速度
	iVel_BottomRoller			: INT;//底辊速度
	//2026.02.07.141032增加两个字节12-2	
	iVel_NetRoller				: INT;//转速
	//2026.5.9.104649
	uiDistancePerCycle_FiberMove	:UINT;//光纤行走的单圈距离:mm *100
	
	abyRsv_93					:ARRAY [1..8] OF BYTE ;(*工艺参数预留		*)
	//2026.03.18.152620 |uiDistancePerCycle_FiberMove->uiDistancePerCycle_FiberMove|10->8

END_STRUCT
END_TYPE

{IMPLEMENTATION}
