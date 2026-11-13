(*@CES
Name=StParam_UnitHMI485_Wr_81
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=7390c00c-e7d7-4035-8319-06dcd475a32f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_UnitHMI485_Wr_81 :
STRUCT
	byPackId: BYTE;//先放一个标志标记通讯只写内容的格式：
	//=1--StParam_UnitHMI485_Wr_81
	//=2--StParam_UnitHMI485_Wr_82
	//=3--StParam_UnitHMI485_Wr_83	
	wGirth: WORD;(*版周长*10*)
	iCompanyId: INT;(*用户编号*)
	iPromptMsgId: INT;(*当前报警/提示信息*)
	wAxisId_And_GrpId: WORD;(*高8位轴号，低8位系号*)
	wLedtime_And_Language: WORD;(*高8位屏保延时，低8位语言选择*)
	aiErrorBuff_V: ARRAY [1..40] OF INT;(*纵向误差队列*)
	aiErrorBuff_H: ARRAY [1..40] OF INT;(*横向误差队列*)
	iVel_Axis: INT;(*轴速度*10*)
	iVel_Grp: INT;(*系速度*10*)
	wIndex_And_ErrNum: WORD;(*高8为采样索引，低8为误差刷新幅数*)
	iArcAlarm_V: INT;(*纵向报警值*)
	iArcAlarm_H: INT;(*横向报警值*)
	wFlag_Arc: WORD;(*套色相关标志，bit0-bit6:色标形式；bit7-bot11:色标顺逆序；bit12:压辊状态*)
	wLED_485Cnt: WORD;(*高8为屏保图片，低8为485通讯计数*)
	wUnit_Input_I: WORD;(*IO监控输入*)
	wUnit_Input_II: WORD;(*IO监控输入*)
	wUnit_Input_III: WORD;(*IO监控输入*)
	wHz_UnitInkRoller_CurrWR: WORD;(*递墨辊频率写入值*)
	wHz_UnitScraper_CurrWR: WORD;(*刮刀频率写入值*)
	wHz_UnitHotWind_CurrWR: WORD;(*热风频率写入值*)
	wHz_UnitHotWind2_CurrWR: WORD;(*热风频率写入值*)
	wPV_UnitTemCtl: WORD;(*实时温度*)
	wSts_UnitTemCtl: WORD;(*加热状态*)
	rPos_PrnRoller_Pressure_M							: REAL;(* 版辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_PrnRoller_Pressure_G							: REAL;(* 版辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_M							: REAL;(* 网辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_G							: REAL;(* 网辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	
	bySts_Ctl: BYTE;//留有一个BYTE作为通讯一些重要标志
	//BIT0:先用作第二色组通讯使能2026.1.4.140126
	abyRsv_HignComm: ARRAY [1..20] OF BYTE;(*保留24个寄存器*)
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
