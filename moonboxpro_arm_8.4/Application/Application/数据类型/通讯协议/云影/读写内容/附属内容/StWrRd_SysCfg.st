(*@CES
Name=StWrRd_SysCfg
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=80b81a88-c08a-42a7-913a-d9e7c94af84c
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}//系统配置
TYPE StWrRd_SysCfg :
STRUCT
	iCompanyId					: INT := 0;(* 公司id/0科赛/1飞达/... *)
	byLanguageId				: BYTE := 1;(* 语言id/1.中文/2.英文/... *)
	byUnitMaxNum				: BYTE := 7;(* 色组数量/0~MAX_UNIT_NUM *)
	astStAxisCfgStruct_PC_		: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(*光电眼行走机构 | 2024.04.01.092649*)
	astStAxisCfgStruct_BR_		: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* BR: Bottom Roller/底辊 *)
	astStAxisCfgStruct_PR_		: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* PR: Prn Roller/版辊 *)
	astStAxisCfgStruct_NR_		: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* NR: Net Roller/网辊 *)
	astStAxisCfgStruct_UW_I		: ARRAY [1..2] OF StWrRd_AxisCfg;(* UW: UnWind/放料 *)
	astStAxisCfgStruct_RW_I		: ARRAY [1..2] OF StWrRd_AxisCfg;(* RW: ReWind/收料 *)
	stStAxisCfgStruct_IF_I		: StWrRd_AxisCfg;(* IF: InFeed/放牵 *)
	stStAxisCfgStruct_OF_I		: StWrRd_AxisCfg;(* OF: OutFeed/收牵 *)
	astStAxisCfgStruct_CD_I		: ARRAY [1..2] OF StWrRd_AxisCfg;(* CD: Central Drum/中心滚筒 *)(*中心辊增加一个|2024.04.01.094732*)
(*以上总共220字节2025.10.13.104636*)	
	
	astStAxisCfgStruct_PR_M_	: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* PR_M: PrnRoller Mside/版辊压力M侧 *)
	astStAxisCfgStruct_PR_G_	: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* PR_G: PrnRoller Gside/版辊压力G侧 *)
	astStAxisCfgStruct_NR_M_	: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* NR_M: NetRoller Mside/网辊压力M侧 *)
	astStAxisCfgStruct_NR_G_	: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* NR_G: NetRoller Gside/网辊压力G侧 *)
	astStAxisCfgStruct_UW_II		: ARRAY [1..2] OF StWrRd_AxisCfg;(* UW: UnWind/放料 *)
	astStAxisCfgStruct_RW_II		: ARRAY [1..2] OF StWrRd_AxisCfg;(* RW: ReWind/收料 *)
	stStAxisCfgStruct_IF_II		: StWrRd_AxisCfg;(* IF: InFeed/放牵 *)
	stStAxisCfgStruct_OF_II		: StWrRd_AxisCfg;(* OF: OutFeed/收牵 *)
	astStAxisCfgStruct_CD_II		: ARRAY [1..2] OF StWrRd_AxisCfg;(* CD: Central Drum/中心滚筒 *)(*中心辊增加一个|2024.04.01.094732*)
	abyDataRsv					: ARRAY [1..4] OF BYTE;
(*以上总共216+4字节2025.10.13.104657|*)		
	
	astStAxisCfgStruct_STR_M_	: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* NR_M: NetRoller Mside/张带辊压力M侧 *)
	astStAxisCfgStruct_STR_G_	: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* NR_G: NetRoller Gside/张带辊压力G侧 *)
	astStAxisCfgStruct_HORIZ_	: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(* HORIZ: 横向控制电机 *)	
//	abyDataRsv1					: ARRAY [1..76] OF BYTE;
//2026.5.15.154633增加色组控制器配置|总48字节|76-48=28
	astStAxisCfgStruct_Ctl		: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_AxisCfg;(*色组控制器配置通讯*)
	abyDataRsv1					: ARRAY [1..28] OF BYTE;	
(*系统配置总共220*3个字节2025.10.13.105513*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
