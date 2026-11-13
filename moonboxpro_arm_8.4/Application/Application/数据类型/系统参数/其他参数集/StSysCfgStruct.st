(*@CES
Name=StSysCfgStruct
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=08cdf89d-7f9f-4b4a-ba7e-4b606e266345
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSysCfgStruct :
STRUCT
	iCompanyId					: INT := 0;(* 公司id/0科赛/1飞达/... *)
	byLanguageId				: BYTE := 1;(* 语言id/1.中文/2.英文/... *)
	byUnitMaxNum				: BYTE := 7;(* 色组数量/0~MAX_UNIT_NUM *)
	astStAxisCfgStruct_UW_I		: ARRAY [1..2] OF StAxisCfgStruct;(* UW: UnWind/放料 *)
	astStAxisCfgStruct_RW_I		: ARRAY [1..2] OF StAxisCfgStruct;(* RW: ReWind/收料 *)
	stStAxisCfgStruct_IF_I		: StAxisCfgStruct;(* IF: InFeed/放牵 *)
	stStAxisCfgStruct_OF_I		: StAxisCfgStruct;(* OF: OutFeed/收牵 *)
	astStAxisCfgStruct_CD_I		: ARRAY [1..2] OF StAxisCfgStruct;(* CD: Central Drum/中心滚筒 *)(*中心辊增加一个|2024.04.01.094732*)
	astStAxisCfgStruct_UW_II		: ARRAY [1..2] OF StAxisCfgStruct;(* UW: UnWind/放料 *)
	astStAxisCfgStruct_RW_II		: ARRAY [1..2] OF StAxisCfgStruct;(* RW: ReWind/收料 *)
	stStAxisCfgStruct_IF_II		: StAxisCfgStruct;(* IF: InFeed/放牵 *)
	stStAxisCfgStruct_OF_II		: StAxisCfgStruct;(* OF: OutFeed/收牵 *)
	astStAxisCfgStruct_CD_II		: ARRAY [1..2] OF StAxisCfgStruct;(* CD: Central Drum/中心滚筒 *)(*中心辊增加一个|2024.04.01.094732*)
	
	astStAxisCfgStruct_PC_		: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(*光电眼行走机构 | 2024.04.01.092649*)
	astStAxisCfgStruct_BR_		: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* BR: Bottom Roller/底辊 *)
	astStAxisCfgStruct_PR_		: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* PR: Prn Roller/版辊 *)
	astStAxisCfgStruct_NR_		: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* NR: Net Roller/网辊 *)
	astStAxisCfgStruct_PR_M_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* PR_M: PrnRoller Mside/版辊压力M侧 *)
	astStAxisCfgStruct_PR_G_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* PR_G: PrnRoller Gside/版辊压力G侧 *)
	astStAxisCfgStruct_NR_M_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* NR_M: NetRoller Mside/网辊压力M侧 *)
	astStAxisCfgStruct_NR_G_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* NR_G: NetRoller Gside/网辊压力G侧 *)
	astStAxisCfgStruct_STR_M_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* NR_M: NetRoller Mside/张带辊压力M侧 *)
	astStAxisCfgStruct_STR_G_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* NR_G: NetRoller Gside/张带辊压力G侧 *)
	astStAxisCfgStruct_HORIZ_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* HORIZ: 横向控制电机 *)
//系统配置参数内容更新，记得重新保存	
	astStAxisCfgStruct_Ctl_	: ARRAY [1..MAX_UNIT_NUM] OF StAxisCfgStruct;(* HORIZ: 横向控制电机 *)
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
