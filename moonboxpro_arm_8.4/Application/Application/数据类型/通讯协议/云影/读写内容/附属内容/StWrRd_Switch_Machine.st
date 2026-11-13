(*@CES
Name=StWrRd_Switch_Machine
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=365f591a-c508-4b2d-a584-49adde6311bf
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StWrRd_Switch_Machine ://总12字节
STRUCT
	xSwitch_PreHotEn_Print								: BIT;(*预热印刷激活开关*)
	xSwitch_ExhAir_Limit_HotWind						: BIT;(*排风限制热风开关*)
	xSwitch_ExhAir_Limit_Run							: BIT;(*排风限制开机开关*)
	xSwitch_CommEn_WatchDevice_Tcp						: BIT;(*TCP-外部监控设备开关*)
	xSwitch_CommEn_WatchDevice_485						: BIT;(*485-外部监控设备开关*)
	xSwitch_CommEn_1U_485								: BIT;(*1色人机通讯开关*)
	xSwitch_CommEn_485									: BIT;(*485通讯开关*)
	xSwitch_CommEn_485_Exh								: BIT;(*排风485通讯开关*)
	xSwitch_CommEn_485_Scraper							: BIT;(*刮刀485通讯开关*)
	xSwitch_CommEn_485_InkRoller						: BIT;(*递墨辊485通讯开关*)
	xSwitch_CommEn_485_HotWind							: BIT;(*热风485通讯开关*)
	xSwitch_ArcIntensityBtn_Hmi							: BIT;(*手动调节随速度走开关*)
	xSwitch_PrnRatioIndividual_Setting					: BIT;(*色组版辊减速比单独设置开关*)		
	xSwitch_NetRatioIndividual_Setting					: BIT;(*色组网辊减速比单独设置开关*)		
	xSwitch_BottomRatioIndividual_Setting				: BIT;(*色组底辊减速比单独设置开关*)		
	xSwitch_StepDriveDebugRun							: BIT;(*横向步进电机测试执行开关*)
	/////////////////////////////////////////////////////////////////////////////////////////////
	//以上刚好16bit，再增加10字节吧预留
	//增加21BIT
	xSetProPointEn										: BIT;
	xUseMaxTimeAsSBegin_InLowSpeed      				: BIT;
	xPseudoRandomEn                     				: BIT;
	xPseudoRandomStart                  				: BIT;
	xEn_RevLimit                        				: BIT;
	xSaveFineSampleData_ToArc           				: BIT;
	xReqSetLedFunc                      				: BIT;
	xSetHmiResolution                   				: BIT;
	xPopupWindowVisible                 				: BIT;
	xInitArcErr_AjdImmediately          				: BIT;
	xPhaseAutoRecoveryEn                				: BIT;
	xKeepServo_PreRegisterDne           				: BIT;
	xUseIfVel_Uw                        				: BIT;
	xKeepServo_Stop                     				: BIT;
	xAxisPrfVelEn                       				: BIT;
	xUseGc_PID_2025                     				: BIT;
	xFlag_Follow_1U_Double_V            				: BIT;
	xArcErrCorrectIsRev_V               				: BIT;
	xAutoSetSampleType                  				: BIT;
	xGetSampleTypeBtn                   				: BIT;
	xAutoSetArcCtlWay                   				: BIT;
	
	
	xWorkMode_Inch										: BIT;
	
//bit1和bit2代替为g_xScraperReset和g_xInkRollerReset	
	xSwitch_ScraperReset								: BIT;
	xSwitch_InkRollerReset								: BIT;
//	xRsv_Flag1											: BIT;
//	xRsv_Flag2											: BIT;
//2025.10.14.145403取一个BYTE当做BIT位处理7-1=6
	xSwitch_HotwindReset: BIT;
	xSwitch_ResetTemctlModule: BIT;
	xMoveFreq_I_ToAll_AirHot: BIT;
	xMoveFreq_II_ToAll_AirHot: BIT;
	xMoveFreq_III_ToAll_AirHot: BIT;
	xMoveFreq_I_ToAll_ExhaustAir: BIT;
	xMoveFreq_II_ToAll_ExhaustAir: BIT;
	xMoveFreq_III_ToAll_ExhaustAir: BIT;
//2025.10.14.151736取一个BYTE当用bit6-1=5
	xSwitch_Copy1stUExhaustDamperPos : BIT;
//2025.11.6.134235||bit1用来作为保存系统配置按钮通讯
	xBtn_UpdateSysCfg: BIT;
//	xBITrsv1: BIT;
//2026.1.5.150714||bit2/bit3用做底辊周长/减速比单独设定开关||bit4/bit5用做网辊周长/减速比单独设定开关
	xSwitch_IndependentSettings_BottomGirth: BIT;
	xSwitch_IndependentSettings_BottomRatio: BIT;
	xSwitch_IndependentSettings_NetGirth: BIT;
	xSwitch_IndependentSettings_NetRatio: BIT;
	
// 	xBITrsv2: BIT;
// 	xBITrsv3: BIT;
// 	xBITrsv4: BIT;
// 	xBITrsv5: BIT;
	xBITrsv6: BIT;
	xBITrsv7: BIT;
	
	abyRsv_Flag											: ARRAY [1..5] OF BYTE;
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
