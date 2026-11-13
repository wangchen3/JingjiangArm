(*@CES
Name=StSts_UnitParam
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=8b49756c-4691-49d4-9f32-1d800649b411
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSts_UnitParam :(*总440字节-每个色组两个数据包*)
STRUCT
	diPos_press_dn_PrnRoller_Pressure_M					: DINT;(* 合压位置/版辊压力电机M侧/单位:mm *)
	diPos_press_dn_PrnRoller_Pressure_G					: DINT;(* 合压位置/版辊压力电机G侧/单位:mm *)
	diPos_press_up_PrnRoller_Pressure_M					: DINT;(* 离压位置/版辊压力电机M侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	diPos_press_up_PrnRoller_Pressure_G					: DINT;(* 离压位置/版辊压力电机G侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	diPos_load_unload_PrnRoller_Pressure_M				: DINT;(* 装卸辊位置/版辊压力电机M侧/单位:mm *)
	diPos_load_unload_PrnRoller_Pressure_G				: DINT;(* 装卸辊位置/版辊压力电机G侧/单位:mm *)
	diPos_press_dn_NetRoller_Pressure_M					: DINT;(* 合压位置/网辊压力电机M侧/单位:mm *)
	diPos_press_dn_NetRoller_Pressure_G					: DINT;(* 合压位置/网辊压力电机G侧/单位:mm *)
	diPos_press_up_NetRoller_Pressure_M					: DINT;(* 离压位置/网辊压力电机M侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	diPos_press_up_NetRoller_Pressure_G					: DINT;(* 离压位置/网辊压力电机G侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	diPos_load_unload_NetRoller_Pressure_M				: DINT;(* 装卸辊位置/网辊压力电机M侧/单位:mm *)
	diPos_load_unload_NetRoller_Pressure_G				: DINT;(* 装卸辊位置/网辊压力电机G侧/单位:mm *)
	diPos_press_dn_StrRoller_Pressure_M					: DINT;(* 合压位置/网辊压力电机M侧/单位:mm *)
	diPos_press_dn_StrRoller_Pressure_G					: DINT;(* 合压位置/网辊压力电机G侧/单位:mm *)
	diPos_press_up_StrRoller_Pressure_M					: DINT;(* 离压位置/网辊压力电机M侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	diPos_press_up_StrRoller_Pressure_G					: DINT;(* 离压位置/网辊压力电机G侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	diPos_load_unload_StrRoller_Pressure_M				: DINT;(* 装卸辊位置/网辊压力电机M侧/单位:mm *)
	diPos_load_unload_StrRoller_Pressure_G				: DINT;(* 装卸辊位置/网辊压力电机G侧/单位:mm *)
	diGirth_Confirmed_press_dn_PrnRoller				: DINT;(* 确认合压位时候的版辊周长*)
	diGirth_Confirmed_press_dn_NetRoller				: DINT;(* 确认合压位时候的网纹辊周长*)
	diGirth_Confirmed_press_dn_StrRoller				: DINT;(* 确认合压位时候的网纹辊周长*)		
	stStSts_PressRoller_Flag							: StSts_PressRoller_Flag;
(*该结构体StSts_PressRoller_Flag----4*MAX_UNIT_NUM字节-64字节*)	
	
	rAI_med_CoatingPrn									: REAL;(*涂布中位值|*)	
	(*bit0-bit15分别对应色组1到16*)
	diEncPosPrintDn_Prn_M 								: DINT;
	diEncPosPrintDn_Prn_G 								: DINT;
	diEncPosPrintDn_Net_M 								: DINT;
	diEncPosPrintDn_Net_G 								: DINT;
	diEncPosPrintDn_Str_M 								: DINT;
	diEncPosPrintDn_Str_G 								: DINT;								
		//2024.10.21.114530 | bai.zy | 版辊网辊操作侧传动侧平行位置标定值	48字节
	diEncPosParallel_Prn_M 							: DINT;
	diEncPosParallel_Prn_G 							: DINT;
	diEncPosParallel_Net_M 							: DINT;
	diEncPosParallel_Net_G 							: DINT;
	diEncPosParallel_Str_M 							: DINT;
	diEncPosParallel_Str_G 							: DINT;
		//2024.10.21.114530 | bai.zy | 版辊网辊操作侧传动侧合压位偏移量	  48字节
	diPrintPosOffsetDn_Prn_M 							: DINT;
	diPrintPosOffsetDn_Prn_G 							: DINT;
	diPrintPosOffsetDn_Net_M 							: DINT;
	diPrintPosOffsetDn_Net_G 							: DINT;
	diPrintPosOffsetDn_Str_M 							: DINT;
	diPrintPosOffsetDn_Str_G 							: DINT;	
	diSampleNum 										: DINT;//采样减速比分子
	diSampleDen 										: DINT;//采样减速比分母
	rSampleGirth										: REAL;
//2024.11.27.154753 | bai.zy | 增加绝对编码器位置,48字节   
	diABSPos_Prn_M										: DINT;
	diABSPos_Prn_G 									: DINT;
	diABSPos_Net_M 									: DINT;
	diABSPos_Net_G 									: DINT;
	diABSPos_Str_M 									: DINT;
	diABSPos_Str_G 									: DINT;
	
	diEncPosLimit_Prn_M_Max 							: DINT;	
	diEncPosLimit_Prn_G_Max 							: DINT;
	diEncPosLimit_Net_M_Max 							: DINT;
	diEncPosLimit_Net_G_Max 							: DINT;
	diEncPosLimit_Str_M_Max 							: DINT;
	diEncPosLimit_Str_G_Max 							: DINT;
	rPos_press_dn_PrnRoller_Pressure_M_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/版辊压力电机M侧/单位:mm *)
	rPos_press_dn_PrnRoller_Pressure_G_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/版辊压力电机G侧/单位:mm *)
	rPos_press_up_PrnRoller_Pressure_M_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/版辊压力电机M侧/单位:mm *)
	rPos_press_up_PrnRoller_Pressure_G_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/版辊压力电机G侧/单位:mm *)
	rPos_load_unload_PrnRoller_Pressure_M_Hmi			: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/版辊压力电机M侧/单位:mm *)
	rPos_load_unload_PrnRoller_Pressure_G_Hmi			: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/版辊压力电机G侧/单位:mm *)
	rPos_press_dn_NetRoller_Pressure_M_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/网辊压力电机M侧/单位:mm *)
	rPos_press_dn_NetRoller_Pressure_G_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/网辊压力电机G侧/单位:mm *)
	rPos_press_up_NetRoller_Pressure_M_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/网辊压力电机M侧/单位:mm *)
	rPos_press_up_NetRoller_Pressure_G_Hmi				: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/网辊压力电机G侧/单位:mm *)
	rPos_load_unload_NetRoller_Pressure_M_Hmi			: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/网辊压力电机M侧/单位:mm *)
	rPos_load_unload_NetRoller_Pressure_G_Hmi			: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/网辊压力电机G侧/单位:mm *)	
	rPos_PrnRoller_Pressure_M							: REAL;(* 版辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_PrnRoller_Pressure_G							: REAL;(* 版辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_M							: REAL;(* 网辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_G							: REAL;(* 网辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	rPos_StrRoller_Pressure_M							: REAL;(* 张带辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_StrRoller_Pressure_G							: REAL;(* 张带辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	dwAxisAlrSts_NetRoller_Pressure_M					: DWORD;(* 网辊压力M侧报警状态 *)
	dwAlrCode_NetRoller_Pressure_M						: DWORD;(* 网辊压力M侧报警代码 *)
	dwAxisAlrSts_NetRoller_Pressure_G					: DWORD;(* 网辊压力G侧报警状态 *)
	dwAlrCode_NetRoller_Pressure_G						: DWORD;(* 网辊压力G侧报警代码 *)
	dwAxisAlrSts_PrnRoller_Pressure_M					: DWORD;(* 版辊压力M侧报警状态 *)
	dwAlrCode_PrnRoller_Pressure_M						: DWORD;(* 版辊压力M侧报警代码 *)
	dwAxisAlrSts_PrnRoller_Pressure_G					: DWORD;(* 版辊压力G侧报警状态 *)
	dwAlrCode_PrnRoller_Pressure_G						: DWORD;(* 版辊压力G侧报警代码 *)
	dwAlarmDetail_Prn									: DWORD;//轴报警信息-版辊
	dwAlarmDetail_Net									: DWORD;//轴报警信息-wnag辊
	dwAlarmDetail_Bottom								: DWORD;//轴报警信息-底辊
	dwAlarmDetail_Prn_M								: DWORD;//轴报警信息-版辊_M
	dwAlarmDetail_Prn_G								: DWORD;//轴报警信息-版辊_G
	dwAlarmDetail_Net_M								: DWORD;//轴报警信息-网辊_M
	dwAlarmDetail_Net_G								: DWORD;//轴报警信息-网辊_G
	dwAlarmDetail_Horz									: DWORD;//轴报警信息-横向
	dwAlarmDetail_PHOTOCELL							: DWORD;//光电眼
	dwAlarmDetail_Str_M								: DWORD;//轴报警信息-网辊_M
	dwAlarmDetail_Str_G								: DWORD;//轴报警信息-网辊_G
	rPhotoCellPosLimit_M 								: REAL;
	rPhotoCellPosLimit_G 								: REAL;

(*该结构体8字节*MAX_UNIT_NUM=128字节*)
	stStSts_UnitFlag									: StSts_UnitFlag;
	


	rPV_UnitTemCtl										: REAL;(* 色组温度控制实时值 *)
	rHz_UnitExhaust_CurrRD								: REAL;(* 排风当前回读频率/pdu上行给主站/ *)
	rHz_UnitExhaust_CurrWR								: REAL;(* 排风当前写入频率/pdu下行给从站/ *)
	rHz_UnitHotWind2_CurrRD							: REAL;(* 热风当前回读频率/pdu上行给主站/ *)
	rHz_UnitHotWind2_CurrWR							: REAL;(* 热风当前写入频率/pdu下行给从站/ *)
	rHz_UnitHotWind_CurrRD								: REAL;(* 热风当前回读频率/pdu上行给主站/ *)
	rHz_UnitHotWind_CurrWR								: REAL;(* 热风当前写入频率/pdu下行给从站/ *)
	rHz_UnitScraper_CurrRD								: REAL;(* 刮刀当前回读频率/pdu上行给主站/ *)
	rHz_UnitScraper_CurrWR								: REAL;(* 刮刀当前写入频率/pdu下行给从站/ *)
	rHz_UnitInkRoller_CurrRD							: REAL;(* 递墨辊当前回读频率/pdu上行给主站/ *)
	rHz_UnitInkRoller_CurrWR							: REAL;(* 递墨辊当前写入频率/pdu下行给从站/ *)	

	
(*	//增加色组版辊相位2025.8.25.152919					|niu.j*)
	wVirtual											: WORD;
//2025.10.20.151557增加预套准料长值||6-4=2
	rPreReg_Length_V						: REAL;(*纵向预套准料长值|单位:mm|*)
//增加色组版辊虚拟码盘状态--2字节
	wVirTual_Sts										: WORD;
//	abyRsv												: ARRAY [1..2] OF BYTE;
END_STRUCT
END_TYPE
{IMPLEMENTATION}
