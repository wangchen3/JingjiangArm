(*@CES
Name=StWrRd_Switch_Grp
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=4a26eb77-6c13-4193-b710-63a532b0c18f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}//总22字节
TYPE StWrRd_Switch_Grp :
STRUCT
	xSwitch_MachineRev							: BIT;(*反向走料开关*)
	xSwitch_6Inch_Rw							: BIT;(*收料3/6吋选择开关*)
	xSwitch_StartUp								: BIT;(*一键开机开关*)
	xSwitch_DiamMeasureAuto						: BIT;(*自动卷径开关*)
	xSwitch_RollOver							: BIT;(*设备翻料架开关*)
	xSwitch_Thickness							: BIT;(*料膜厚度手自动获取开关*)
	xSwitch_CutDneResetPidEn_Uw					: BIT;(*放料裁切后系数手自动*)
	xSwitch_CutDneResetPidEn_Rw					: BIT;(*收料裁切后系数手自动*)
	xSwitch_AutomaticCutEn_Uw					: BIT;(*放料自动接料是能*)
	xSwitch_AutomaticCutEn_Rw					: BIT;(*放料自动接料是能*)
	xSwitch_AutoAdjust_V_Grp					: BIT;(*整机纵向自动调整开关*)
	xSwitch_AutoAdjust_H_Grp					: BIT;(*整机纵向自动调整开关*)
	xSwitch_Follow_1U_V_Grp						: BIT;(*纵向跟1色开关*)
	xSwitch_Follow_1U_H_Grp						: BIT;(*横向跟1色开关*)	
	xSwitch_DiamAuto_Pot						: BIT;(*卷径检测使用电位器*)
	xSwitch_DiamAuto_Enc						: BIT;(*卷径检测使用编码器*)
	xSwitch_DiamAuto_Ultrasonic_S				: BIT;(*卷径检测使用单超声波*)
	xSwitch_DiamAuto_Ultrasonic_D				: BIT;(*卷径检测使用双超声波*)
	xSwitch_DiamAuto_DualParam					: BIT;(*卷径检测双轴参数分开*)
	xSwitch_DebugMode							: BIT;(*调试模式开关*)
	xSwitch_Debug_DiamMeasure_Uw				: BIT;(*放料卷径检测电位器调试开关*)
	xBtn_Diameasure_Confirm_1					: BIT;(*自动卷径标定——1*)
	xBtn_Diameasure_Confirm_2					: BIT;(*自动卷径标定——2*)
	xBtn_Diameasure_Confirm_3					: BIT;(*自动卷径标定——3*)
	xBtn_Diameasure_Confirm_4					: BIT;(*自动卷径标定——4*)
(*2025.11.3.153321收放料绝对值编码器定位等相关开关
原总共42BIT位||重新整理一部分||总共需要14BIT位剩余作为预留*)
	xSwitch_UseAbsEnc_Uw						: BIT;(*放料使用绝对值编码器开关*)
	xSwitch_AxisLocaltion_DualParam_Uw			: BIT;(*放料绝对值编码器定位双轴参数开关*)
	xSwitch_Debug_Axis_Uw						: BIT;(*放料轴运行调试模式*)
	xSwitch_Debug_Uw_CutUpChoose				: BIT;(*放料绝对值编码器定位调试-上下裁选择||TRUE：上裁FALSE：下裁*)
	xSwitch_Debug_Uw_AxisA_Choose				: BIT;(*放料绝对值编码器定位调试-AB轴选择|TRUE:A轴；FALSE:B轴*)
	xBtn_Debug_Uw_Wr							: BIT;(*放料轴定位写入*)
	xBtn_Debug_Uw_MinDiam_Wr					: BIT;(*放料最小径写入*)	
	xSwitch_UseAbsEnc_Rw						: BIT;(*收料使用绝对值编码器开关*)	
	xSwitch_AxisLocaltion_DualParam_Rw			: BIT;(*收料绝对值编码器定位双轴参数开关*)
	xSwitch_Debug_Axis_Rw						: BIT;(*收料轴运行调试模式*)	
	xSwitch_Debug_Rw_CutUpChoose				: BIT;(*收料绝对值编码器定位调试-上下裁选择||TRUE：上裁FALSE：下裁*)
	xSwitch_Debug_Rw_AxisA_Choose				: BIT;(*收料绝对值编码器定位调试-AB轴选择|TRUE:A轴；FALSE:B轴*)
	xSwitch_Debug_Rw_Inch3_CutUpChoose			: BIT;(*收料绝对值编码器定位调试-3/6吋选择|TRUE:3吋；FALSE:6吋*)	
	xBtn_Debug_Rw_Wr							: BIT;(*收料轴定位写入*)
//2026.4.25.140018合并结构体|niu.j|增加5个变量
	xSwitch_StartAutoFind	: BIT;(*全自动套印开关*)
	xSwitch_EnFastPress		: BIT;(*当前色找到就合压使能*)
	xSwitch_SaveRS2File		: BIT;(*粗采样保存*)
	xSwitch_RFailure		: BIT;(*全自动套印粗采样失败校准*)
	xSwitch_FFailure		: BIT;(*全自动套印精采样失败校准按钮*)
// 	xRsv_Grp_1									: BIT;
// 	xRsv_Grp_2									: BIT;
// 	xRsv_Grp_3									: BIT;
// 	xRsv_Grp_4									: BIT;
// 	xRsv_Grp_5									: BIT;
//2026.4.25.140311增加结束	
	xRsv_Grp_6									: BIT;
	xRsv_Grp_7									: BIT;
	xRsv_Grp_8									: BIT;
	xRsv_Grp_9									: BIT;
	xRsv_Grp_10									: BIT;
	xRsv_Grp_11									: BIT;
	xRsv_Grp_12									: BIT;
	xRsv_Grp_13									: BIT;
	xRsv_Grp_14									: BIT;
	xRsv_Grp_15									: BIT;
	xRsv_Grp_16									: BIT;
	xRsv_Grp_17									: BIT;
	xRsv_Grp_18									: BIT;
//2026.4.28.104338增加异站虚拟码盘重新配置开关xRsv_Grp_19
//	xRsv_Grp_19									: BIT;
	xSwitch_ReSetEncCfg							: BIT;
	
	
//bit20和bit21替换为换卷完成放料和收料	
// 	xRsv_Grp_20									: BIT;
// 	xRsv_Grp_21									: BIT;
	xBtn_ChangeFilmDn_Uw						: BIT;
	xBtn_ChangeFilmDn_Rw						: BIT;
//2026.04.10.180829结束
//2026.03.11.100402 | + | 使用Bit22作为压力电机自动合压开关
	xSwitch_PressureAuto_Up_Dn							: BIT;
	//xRsv_Grp_22									: BIT;
//2026.2.25.094558 | + | 使用Bit23作为天枢数据保存的开关
	xSwitch_SaveData_GNS						: BIT;
	//xRsv_Grp_23									: BIT;
//2026.02.01.112053 | + | 使用Bit24作为停机维持使能的开关
	xSwitch_KeepServoOn							: BIT;
	//xRsv_Grp_24									: BIT;
//2026.01.27.093334 | + | 使用Bit25和Bit26作为清除报警按钮和回零位的操作标志
	xSwitch_ClearSysAlarm						: BIT;
	xSwitch_BackToHome							: BIT;
// 	xRsv_Grp_25									: BIT;
// 	xRsv_Grp_26									: BIT;
//2026.1.5.151405增加用Bit27和bit28作为收牵压力传感器调整开关和带长调整基准（标准带长/首色带长）开关（暂时只有秦华用）
	xSwitch_TensionAdjust_QH					: BIT;
	xSwitch_PrnLenAdj_Follow_QH					: BIT;
//	xRsv_Grp_27									: BIT;
//	xRsv_Grp_28									: BIT;
(*	
	xSwitch_UseAbsEnc_Uw						: BIT;(*放料使用绝对值编码器开关*)
	xSwitch_AxisLocaltion_DualParam_Uw			: BIT;(*放料绝对值编码器定位双轴参数开关*)
	xSwitch_Debug_Axis_Uw						: BIT;(*放料轴运行调试模式*)
	xSwitch_Debug_Uw_CutUpChoose				: BIT;(*放料绝对值编码器定位调试-上裁选择*)
	xSwitch_Debug_Uw_AxisA_CutUpChoose			: BIT;(*放料绝对值编码器定位调试-上裁A选择*)
	xBtn_Debug_Uw_AxisA_CutUpWr					: BIT;(*上裁A轴定位写入*)
	xBtn_Debug_Uw_MinDiamA_CutUpWr				: BIT;(*上裁A轴最小径写入*)
	xSwitch_Debug_Uw_AxisB_CutUpChoose			: BIT;(*放料绝对值编码器定位调试-上裁B选择*)
	xBtn_Debug_Uw_AxisB_CutUpWr					: BIT;(*上裁B轴定位写入*)
	xBtn_Debug_Uw_MinDiamB_CutUpWr				: BIT;(*上裁B轴最小径写入*)	
	xSwitch_Debug_Uw_CutDnChoose				: BIT;(*放料绝对值编码器定位调试-下裁选择*)
	xSwitch_Debug_Uw_AxisA_CutDnChoose			: BIT;(*放料绝对值编码器定位调试-下裁A选择*)
	xBtn_Debug_Uw_AxisA_CutDnWr					: BIT;(*下裁A轴定位写入*)
	xBtn_Debug_Uw_MinDiamA_CutDnWr				: BIT;(*下裁A轴最小径写入*)
	xSwitch_Debug_Uw_AxisB_CutDnChoose			: BIT;(*放料绝对值编码器定位调试-下裁B选择*)
	xBtn_Debug_Uw_AxisB_CutDnWr					: BIT;(*下裁B轴定位写入*)
	xBtn_Debug_Uw_MinDiamB_CutDnWr				: BIT;(*下裁B轴最小径写入*)	
	xSwitch_UseAbsEnc_Rw						: BIT;(*收料使用绝对值编码器开关*)	
	xSwitch_AxisLocaltion_DualParam_Rw			: BIT;(*收料绝对值编码器定位双轴参数开关*)
	xSwitch_Debug_Axis_Rw						: BIT;(*收料轴运行调试模式*)
	xSwitch_Debug_Rw_CutUpChoose				: BIT;(*收料绝对值编码器定位调试-上裁选择*)
	xSwitch_Debug_Rw_Inch3_CutUpChoose			: BIT;(*收料绝对值编码器定位调试-上裁3吋选择*)	
	xSwitch_Debug_Rw_AxisA_3_CutUpChoose		: BIT;(*收料绝对值编码器定位调试-上裁A选择*)
	xBtn_Debug_Rw_AxisA_3_CutUpWr				: BIT;(*上裁A轴定位写入*)
	xSwitch_Debug_Rw_AxisB_3_CutUpChoose		: BIT;(*收料绝对值编码器定位调试-上裁B选择*)
	xBtn_Debug_Rw_AxisB_3_CutUpWr				: BIT;(*上裁B轴定位写入*)
	xSwitch_Debug_Rw_Inch6_CutUpChoose			: BIT;(*收料绝对值编码器定位调试-上裁6吋选择*)	
	xSwitch_Debug_Rw_AxisA_6_CutUpChoose		: BIT;(*收料绝对值编码器定位调试-上裁A选择*)
	xBtn_Debug_Rw_AxisA_6_CutUpWr				: BIT;(*上裁A轴定位写入*)
	xSwitch_Debug_Rw_AxisB_6_CutUpChoose		: BIT;(*收料绝对值编码器定位调试-上裁B选择*)
	xBtn_Debug_Rw_AxisB_6_CutUpWr				: BIT;(*上裁B轴定位写入*)
	xSwitch_Debug_Rw_CutDnChoose				: BIT;(*收料绝对值编码器定位调试-下裁选择*)
	xSwitch_Debug_Rw_Inch3_CutDnChoose			: BIT;(*收料绝对值编码器定位调试-下裁3吋选择*)	
	xSwitch_Debug_Rw_AxisA_3_CutDnChoose		: BIT;(*收料绝对值编码器定位调试-下裁A选择*)
	xBtn_Debug_Rw_AxisA_3_CutDnWr				: BIT;(*下裁A轴定位写入*)
	xSwitch_Debug_Rw_AxisB_3_CutDnChoose		: BIT;(*收料绝对值编码器定位调试-下裁B选择*)
	xBtn_Debug_Rw_AxisB_3_CutDnWr				: BIT;(*下裁B轴定位写入*)
	xSwitch_Debug_Rw_Inch6_CutDnChoose			: BIT;(*收料绝对值编码器定位调试-下裁6吋选择*)	
	xSwitch_Debug_Rw_AxisA_6_CutDnChoose		: BIT;(*收料绝对值编码器定位调试-下裁A选择*)
	xBtn_Debug_Rw_AxisA_6_CutDnWr				: BIT;(*下裁A轴定位写入*)
	xSwitch_Debug_Rw_AxisB_6_CutDnChoose		: BIT;(*收料绝对值编码器定位调试-下裁B选择*)
	xBtn_Debug_Rw_AxisB_6_CutDnWr				: BIT;(*下裁B轴定位写入*)
*)	
	xSwitch_Scrap_Avoidance						: BIT;(*裁切让料头开关*)
	xSwitch_CCW_AfterCut_Uw						: BIT;(*放料裁切后反转轴开关*)
	xSwitch_CutUseReflectionSensor				: BIT;(*放料裁切使用弧面开关*)
	xSwitch_UseRadCompensate_Uw					: BIT;(*放料翻转架补偿开关*)
	xSwitch_TowerDir_Uw							: BIT;(*翻转架补偿方向取反开关*)
	xBtn_ConfirmRad0_Uw							: BIT;(*放料翻转架补偿0弧度确认按钮*)			
(*2025.11.14.145213调试使能只需要一个
	xSwitch_Debug_SpdAxisA_Uw					: BIT;(*放料A轴速度调试模式开关*)
	xBtn_DebugSpdAxisA_Uw_MoveEn				: BIT;(*放料A轴运动使能*)
	xBtn_DebugSpdAxisA_Uw_AccEn					: BIT;(*放料A轴加速使能*)
	xSwitch_Debug_SpdAxisB_Uw					: BIT;(*放料B轴速度调试模式开关*)
	xBtn_DebugSpdAxisB_Uw_MoveEn				: BIT;(*放料B轴运动使能*)
	xBtn_DebugSpdAxisB_Uw_AccEn					: BIT;(*放料B轴加速使能*)
	xSwitch_Debug_SpdAxisA_Rw					: BIT;(*收料A轴速度调试模式开关*)
	xBtn_DebugSpdAxisA_Rw_MoveEn				: BIT;(*收料A轴运动使能*)
	xBtn_DebugSpdAxisA_Rw_AccEn					: BIT;(*收料A轴加速使能*)
	xSwitch_Debug_SpdAxisB_Rw					: BIT;(*收料B轴速度调试模式开关*)
	xBtn_DebugSpdAxisB_Rw_MoveEn				: BIT;(*收料B轴运动使能*)
	xBtn_DebugSpdAxisB_Rw_AccEn					: BIT;(*收料B轴加速使能*)
	*)
	xSwitch_Debug_Spd_Uw					: BIT;(*放料A轴速度调试模式开关*)
	xBtn_DebugSpdAxisA_Uw_MoveEn				: BIT;(*放料A轴运动使能*)
	xBtn_DebugSpdAxisA_Uw_AccEn					: BIT;(*放料A轴加速使能*)
	xSwitch_Rsv1					 				: BIT;(*2025.11.14.145252原收料B轴速度调试模式开关*)
	xBtn_DebugSpdAxisB_Uw_MoveEn				: BIT;(*放料B轴运动使能*)
	xBtn_DebugSpdAxisB_Uw_AccEn					: BIT;(*放料B轴加速使能*)
	xSwitch_Debug_Spd_Rw					: BIT;(*收料A轴速度调试模式开关*)
	xBtn_DebugSpdAxisA_Rw_MoveEn				: BIT;(*收料A轴运动使能*)
	xBtn_DebugSpdAxisA_Rw_AccEn					: BIT;(*收料A轴加速使能*)
	xSwitch_Rsv					 				: BIT;(*2025.11.14.145252原收料B轴速度调试模式开关*)
	xBtn_DebugSpdAxisB_Rw_MoveEn				: BIT;(*收料B轴运动使能*)
	xBtn_DebugSpdAxisB_Rw_AccEn					: BIT;(*收料B轴加速使能*)
	
	xSwitch_UseFollow_1U_V_UwCut				: BIT;(*裁切套色新方式开关*)
	xSwitch_TypeGetInitDiam						: BIT;(*收放料初始卷径获取方式*)
	xSwitch_Heating_I							: BIT;(*全部加热1档*)
	xSwitch_Heating_II							: BIT;(*全部加热1I档*)
	xSwitch_Heating_III							: BIT;(*全部加热1II档*)
	xSwitch_Heating_Close						: BIT;(*全部加热关闭*)
	xSwitch_Heating_Water						: BIT;(*全部水加热控制开关*)
	xSwitch_Heating_Elc							: BIT;(*全部电加热控制开关*)
	xBtn_CopySV_1U_To_Other						: BIT;(*复制1色设定温度到其他色组*)
	xBtn_Reset_TempCtlBlock						: BIT;(*重启温控模块按钮*)
	xBtn_AllExhAir_On							: BIT;(*排风总开*)
	xBtn_AllExhAir_Off							: BIT;(*排风总关*)
	xBtn_CopyExhFreq_1U_To_Other				: BIT;(*复制1色设定温度到其他色组*)
	xBtn_ExhAir_Reset							: BIT;(*排风总关*)
	/////////////////////////////////////////////////////////////////////////////////////////////
	//以上刚好99bit，再增加9字节+5bit吧预留
	(*增加14BIT-9905界面*)
	xPidType_If_New								: BIT;
	xPidType_Of_New                 			: BIT;
	xBtn_StepTest_V                 			: BIT;
	xUseDiam_LowPass_Rw             			: BIT;
	xTensionCompensateEn_Rw         			: BIT;
	xUseTime_b1_Rw                  			: BIT;
	xUseTime_Variaition_Rw          			: BIT;
	xUseIMatrix_rX_DARE_Rw          			: BIT;
	xTensionCompensateEn_RwCut      			: BIT;
	xUseDiam_LowPass_Uw             			: BIT;
	xTensionCompensateEn_Uw         			: BIT;
	xUseTime_b1_Uw                  			: BIT;
	xUseTime_Variaition_Uw          			: BIT;
	xUseIMatrix_rX_DARE_Uw          			: BIT;

	
(**占用两个BIT位-卷径估计开关|2025.8.20.163450|niu.j	
	xRsv_Flag0											: BIT;
	xRsv_Flag1											: BIT;
	*)
	xSwitch_Estimate_Uw					: BIT;(*放料卷径估计开关*)
	xSwitch_Estimate_Rw					: BIT;(*收料卷径估计开关*)
	
	
	xSwitchTension_If											: BIT;
	xSwitchTension_Of											: BIT;
	xUseBtn_Linkage											: BIT;	
	xSwitch_ScraperOn_Of										: BIT;
	
	
	xNegPolarity_Uw											: BIT;
	xNegPolarity_Rw											: BIT;
	xNegPolarity_If											: BIT;
	xNegPolarity_Of											: BIT;


//2025.10.14.105504bit0和1、2、3用做dwControlBits.30和.31
	xSwitch_TempFromEnc_PT1000_If							: BIT;
	xSwitch_MotorTemp_PT1000_NTC_If						: BIT;
	xSwitch_TempFromEnc_PT1000_Of							: BIT;
	xSwitch_MotorTemp_PT1000_NTC_Of						: BIT;
//	xRsv_Flag0											: BIT;
//	xRsv_Flag1											: BIT;
//	xRsv_Flag2											: BIT;
//	xRsv_Flag3											: BIT;
//2025.10.14.111349|用bit4替代为xTensionCompensateEn_UwCut
	xTensionCompensateEn_UwCut							: BIT;
//	xRsv_Flag4											: BIT;
//2025.10.14.112844重新取出来一个byte用做位|bit0用作xUseAntiNotch_Uw
	xUseAntiNotch_Uw										: BIT;(*套色使用陷波器@*)
//2025.10.14.113357用bit1替代	xWorkMode_RollerPress					: BOOL;(*压辊顺序; TRUE从前到后; FALSE从后到前|*)	
	xWorkMode_RollerPress										: BIT;	
//	xRsv_Flag1										: BIT;
//2025.10.14.135539|用bit2和bit3替代等料长
	xSwitch_WaitFilmLengthEn				: BIT;(*开机等料长|原原wCtlSwitchRef.4*)
	xSwitch_WaitFilmLengthEn_From1st		: BIT;(*开机等首色料长|原原wCtlSwitchRef.13*)

//	xRsv_Flag2										: BIT;
//	xRsv_Flag3										: BIT;
//2025.10.15.144413|bit4用于套色报警铃
	xSwitch_Alarm_Arc						: BIT;(*套色报警开关|wCtlSwitchRef.0*)

//	xRsv_Flag4										: BIT;
//2025.10.15.160851||bit5和bit6用作预热风和预加热界面使能开关
	xSwitch_PreHotAirEn								: BIT;
	xSwitch_PreHeatingEn							: BIT;
//	xRsv_Flag5										: BIT;
//	xRsv_Flag6										: BIT;
//2025.10.15.165123||bit7和新的bi0-bit3用作刮刀递墨总控-再取一个BYTE用做BIT||5-1=4
	xSwitch_ScraperAuto					: BIT;(*刮刀手自动*)
	xSwitch_ScraperOn					: BIT;(*刮刀开关*)
	xSwitch_InkRollerAuto				: BIT;(*递墨辊手自动*)
	xSwitch_InkRollerCW					: BIT;(*递墨辊正转*)
	xSwitch_InkRollerCCW				: BIT;(*递墨辊反转*)
//	xRsv_Flag7										: BIT;
//	xRsv_Flag0										: BIT;
//	xRsv_Flag1										: BIT;
//	xRsv_Flag2										: BIT;
//	xRsv_Flag3										: BIT;
//2025.10.20.153333||bit4-bit7用做预套准按钮
	xBtn_ReadPhase_Home: BIT;//读取装版相位按钮
	xBtn_PreRegisterAxisId_Manu					: BIT;(*预套准的轴号手动确定@不考虑联动开关*)	
	xBtn_PreRegister: BIT;//预套准按钮
	xBtn_PreRegisterCorrConfirm: BIT;//预套准自动修正按钮

	//xRsv_Flag4										: BIT;
	//xRsv_Flag5										: BIT;
	//xRsv_Flag6										: BIT;
	//xRsv_Flag7										: BIT;
	//再取一个BYTE用做BIT||4-1=3
	//2025.10.20.153729||bit0和bit1用作横向预套准按钮	
	xBtn_HorzPreRegister_Repeat				: BIT;(*横向重复值按钮*)
	xBtn_HorzPreRegister_Setup				: BIT;(*横向设定值按钮*)
	
	//xRsv_Flag0										: BIT;
	//xRsv_Flag1										: BIT;
//2025.10.20.163844用bit2作为配方通讯标志
//金刚读取配方完成后，给天枢一个相位回复标志，天枢读取配方回复内容并且进行相位回复
	xBtn_RestorePhase_Hmi					: BIT;
//	xRsv_Flag2										: BIT;
//2025.12.30.171854||bit3和bit4用作界面切换上下裁开关
	xSwitch_Change_CutterOnTop_HMI_Uw				: BIT;
	xSwitch_Change_CutterOnTop_HMI_Rw				: BIT;
//	xRsv_Flag3										: BIT;	
//	xRsv_Flag4										: BIT;
//2025.12.30.172757||bit5和bit6分别做收料3/6吋切换使用界面/开关，以及界面切换3/6吋开关
	xUseKnob_6Inch_Rw_Hmi							: BIT;
	xKnob_6Inch_Rw									: BIT;
//	xRsv_Flag5										: BIT;
//	xRsv_Flag6										: BIT;
//	xRsv_Flag7										: BIT;
	xSwitch_GrpInkEn:									BIT;
//2026.5.14.151101再取一位
	xSwitch_En_AutoStop								: BIT;
//xRsv_Flag1用作界面自动加减速按钮	
	xAutoAccDec_Hmi									: BIT;
//	xRsv_Flag1										: BIT;

//2026.05.24.134141 增加光纤行走相关开关
//	xRsv_Flag2										:BIT;
// 	xRsv_Flag3										: BIT;
//	xRsv_Flag4										: BIT;
// 	xRsv_Flag5										: BIT;
// 	xRsv_Flag6										: BIT;
// 	xRsv_Flag7										: BIT;
	xFiberMove_DebugMode							:BIT;(*光纤行走调试模式*)
	xFiberMoveDisRunStart_AllUnit					:BIT;(*光纤行走同步运动启动*)
	xUseOnline_FiberMove							:BIT;(*光纤行走使用外部联动*)
	xFiberMoveConfirm_AllUnit						:BIT;(*光纤行走主站确认基准位置*)
	xFiberMovePosCal_ByUnit							:BIT;(*光纤行走色组标定*)
	xFiberMovePosCal_ByOnline						:BIT;(*光纤行走在线标定*)
	
	xFiberMove_Negative_AdjustByUnit				:BIT;(*光纤行走色组修正取反*)
	xFiberMove_Negative_AdjustByOnline				:BIT;(*光纤行走在线修正取反*)
	xRsv_Flag0										: BIT;
	xRsv_Flag1										: BIT;
	xRsv_Flag2										: BIT;
	xRsv_Flag3										: BIT;
	xRsv_Flag4										: BIT;
	xRsv_Flag5										: BIT;

	abyRsv_Flag											: ARRAY [1..1] OF BYTE;	

END_STRUCT
END_TYPE



{IMPLEMENTATION}
