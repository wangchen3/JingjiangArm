(*@CES
Name=StParam_UnitHMI485_WrRd
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=20b40184-5295-49e6-bf5f-17e6b491675e
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_UnitHMI485_WrRd :
STRUCT
	byHMI_Cnt: BYTE;(*人机通讯计数*)
	byAxisId: BYTE;(*轴号*)
	iAdjust_V: INT;(*套色修正量，单位：丝*)
	iAdjust_H: INT;(*套色修正量，单位：丝*)
	wStatus: WORD;(*界面上套色相关状态*)
	wButtonFun: WORD;(*界面按钮及指示灯*)
	wSwitchFun: WORD;(*界面开关*)
	wUnit_Outout_I: WORD;(*IO输出监控/测试*)
	wUnit_Outout_II: WORD;(*IO输出监控/测试*)
	iPlateAdjustmentProf:INT;(*纵向快速对版量*)
	iJourney_HorzRapidAdjust: INT;(*横向快速对版量*)
	wHz_UnitInkRoller_ManuallySet: WORD;(*递墨辊手动频率*)
	wCoeff_UnitInkRoller_Auto: WORD;(*递墨辊自动系数*)
	wHz_UnitScraper_ManuallySet: WORD;(*刮刀手动频率*)
	wCoeff_UnitScraper_Auto: WORD;(*刮刀自动系数*)
	wHz_UnitHotWind: WORD;(*热风频率*)
	wHz_UnitHotWind_2: WORD;(*热风2频率*)
	wSV_UnitTemCtl: WORD;(*加热设定温度*)
	dwCtlBits_UnitBaseCraft: DWORD;(*工艺控制开关*)
	wAirInletWindDoorValue: WORD;(*进风风门*)
	wAirExhaustWindDoorValue: WORD;(*排风风门*)
	wAirReturnWindDoorValue: WORD;(*回风风门*)
//增加一些开关变量||2025.12.31.141711||总共	7||94-7=87
	bySwitch_Arc: BYTE;(*先用一个BYTE作为其他套色需要的开关
							bit0: 横向开关*)
	wSwitch_Process: WORD;(*工艺开关
							bit0:递墨辊自动
							bit1:递墨辊正转
							bit2:递墨辊反转
							bit3:刮刀自动
							bit4:刮刀开关
							bit5:加热I档
							bit6:加热II档
							bit7:加热III档
							bit8:热风开关
							bit9:热风2开关							
*)					
	dwSwitch_Pressure: DWORD;(*压力相关
							bit0:版辊压力操作侧靠近
							bit1:版辊压力操作侧远离
							bit2:版辊压力传动侧靠近
							bit3:版辊压力传动侧远离
							bit4:版辊压力靠近
							bit5:版辊压力远离
							bit6:网辊压力操作侧靠近
							bit7:网辊压力操作侧远离
							bit8:网辊压力传动侧靠近
							bit9:网辊压力传动侧远离
							bit10:网辊压力靠近
							bit11:网辊压力远离
							bit12:张带辊压力操作侧靠近
							bit13:张带辊压力操作侧远离
							bit14:张带辊压力传动侧靠近
							bit15:张带辊压力传动侧远离
							bit16:张带辊压力靠近
							bit17:张带辊压力远离
							bit18~bit23:预留
							bit24:版辊离压位标定
							bit25:版辊合压位标定
							bit26:版辊换版位标定
							bit27:版辊平行标定
							bit24:网辊离压位标定
							bit25:网辊合压位标定
							bit26:网辊换版位标定
							bit27:网辊平行标定							
*)
	abyRsv_RdWr: ARRAY [1..73] OF BYTE;	
	
	byHMI_Cnt_OtherUnit: BYTE;(*人机通讯计数*)
	byAxisId_OtherUnit: BYTE;(*轴号*)
	wButtonFun_OtherUnit: WORD;(*界面按钮及指示灯*)
	wSwitchFun_OtherUnit: WORD;(*界面开关*)
	wUnit_Outout_I_OtherUnit: WORD;(*IO输出监控/测试*)
	wUnit_Outout_II_OtherUnit: WORD;(*IO输出监控/测试*)
	iJourney_HorzRapidAdjust_OtherUnit: INT;(*横向快速对版量*)
	wHz_UnitInkRoller_ManuallySet_OtherUnit: WORD;(*递墨辊手动频率*)
	wCoeff_UnitInkRoller_Auto_OtherUnit: WORD;(*递墨辊自动系数*)
	wHz_UnitScraper_ManuallySet_OtherUnit: WORD;(*刮刀手动频率*)
	wCoeff_UnitScraper_Auto_OtherUnit: WORD;(*刮刀自动系数*)
	wHz_UnitHotWind_OtherUnit: WORD;(*热风频率*)
	wHz_UnitHotWind_2_OtherUnit: WORD;(*热风2频率*)
	wSV_UnitTemCtl_OtherUnit: WORD;(*加热设定温度*)
	dwCtlBits_UnitBaseCraft_OtherUnit: DWORD;(*工艺控制开关*)
	wAirInletWindDoorValue_OtherUnit: WORD;(*进风风门*)
	wAirExhaustWindDoorValue_OtherUnit: WORD;(*排风风门*)
	wAirReturnWindDoorValue_OtherUnit: WORD;(*回风风门*)
//增加一些开关变量||2025.12.31.141711||总共	7||94-7=87
	wSwitch_Process_OtherUnit: WORD;(*工艺开关
							bit0:递墨辊自动
							bit1:递墨辊正转
							bit2:递墨辊反转
							bit3:刮刀自动
							bit4:刮刀开关
							bit5:加热I档
							bit6:加热II档
							bit7:加热III档
							bit8:热风开关
							bit9:热风2开关							
*)					
	dwSwitch_Pressure_OtherUnit: DWORD;(*压力相关
							bit0:版辊压力操作侧靠近
							bit1:版辊压力操作侧远离
							bit2:版辊压力传动侧靠近
							bit3:版辊压力传动侧远离
							bit4:版辊压力靠近
							bit5:版辊压力远离
							bit6:网辊压力操作侧靠近
							bit7:网辊压力操作侧远离
							bit8:网辊压力传动侧靠近
							bit9:网辊压力传动侧远离
							bit10:网辊压力靠近
							bit11:网辊压力远离
							bit12:张带辊压力操作侧靠近
							bit13:张带辊压力操作侧远离
							bit14:张带辊压力传动侧靠近
							bit15:张带辊压力传动侧远离
							bit16:张带辊压力靠近
							bit17:张带辊压力远离
							bit18~bit23:预留
							bit24:版辊离压位标定
							bit25:版辊合压位标定
							bit26:版辊换版位标定
							bit27:版辊平行标定
							bit24:网辊离压位标定
							bit25:网辊合压位标定
							bit26:网辊换版位标定
							bit27:网辊平行标定							
*)	
	abyRsv_RdWr_OtherUnit: ARRAY [1..74] OF BYTE;	

END_STRUCT
END_TYPE

{IMPLEMENTATION}
