(*@CES
Name=StParam_UnitHMI485_Wr_83
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=f4069e2c-8ef0-4053-8cd1-9b1dedc27d09
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_UnitHMI485_Wr_83 ://作为第二色组通讯内容2026.1.4.135901||在Wr-81里增加第二色组通讯使能
STRUCT
	byPackId: BYTE;//先放一个标志标记通讯只写内容的格式：
	//=1--StParam_UnitHMI485_Wr_81
	//=2--StParam_UnitHMI485_Wr_82
	//=3--StParam_UnitHMI485_Wr_83	
	wGirth_OtherUnit: WORD;(*版周长*10*)
	iCompanyId_OtherUnit: INT;(*用户编号*)
	iPromptMsgId_OtherUnit: INT;(*当前报警/提示信息*)
	wAxisId_And_GrpId_OtherUnit: WORD;(*高8位轴号，低8位系号*)
	wLedtime_And_Language_OtherUnit: WORD;(*高8位屏保延时，低8位语言选择*)
	iVel_Axis_OtherUnit: INT;(*轴速度*10*)
	iVel_Grp_OtherUnit: INT;(*系速度*10*)
	wIndex_And_ErrNum_OtherUnit: WORD;(*高8为采样索引，低8为误差刷新幅数*)
	wFlag_Arc_OtherUnit: WORD;(*套色相关标志，bit0-bit6:色标形式；bit7-bot11:色标顺逆序；bit12:压辊状态*)
	wLED_485Cnt_OtherUnit: WORD;(*高8为屏保图片，低8为485通讯计数*)
	wUnit_Input_I_OtherUnit: WORD;(*IO监控输入*)
	wUnit_Input_II_OtherUnit: WORD;(*IO监控输入*)
	wUnit_Input_III_OtherUnit: WORD;(*IO监控输入*)
	wHz_UnitInkRoller_CurrWR_OtherUnit: WORD;(*递墨辊频率写入值*)
	wHz_UnitScraper_CurrWR_OtherUnit: WORD;(*刮刀频率写入值*)
	wHz_UnitHotWind_CurrWR_OtherUnit: WORD;(*热风频率写入值*)
	wHz_UnitHotWind2_CurrWR_OtherUnit: WORD;(*热风频率写入值*)
	wPV_UnitTemCtl_OtherUnit: WORD;(*实时温度*)
	wSts_UnitTemCtl_OtherUnit: WORD;(*加热状态*)
	rPos_PrnRoller_Pressure_M_OtherUnit							: REAL;(* 版辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_PrnRoller_Pressure_G_OtherUnit							: REAL;(* 版辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_M_OtherUnit							: REAL;(* 网辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_G_OtherUnit							: REAL;(* 网辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	
	abyRsv_HignComm_OtherUnit: ARRAY [1..185] OF BYTE;(*保留120个寄存器*)	
//2025.11.27.181845增加压力相关内容占用 64字节，剩余字节120-64=56  	
//	awRsv_HignComm_2: ARRAY [1..120] OF WORD;(*保留120个寄存器*)		
END_STRUCT
END_TYPE

{IMPLEMENTATION}
