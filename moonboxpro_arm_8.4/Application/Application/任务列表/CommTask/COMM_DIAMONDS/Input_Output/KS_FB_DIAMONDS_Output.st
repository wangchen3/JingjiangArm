(*@CES
Name=KS_FB_DIAMONDS_Output
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=be254e16-7eb3-45ae-81c3-a86511f52729
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_DIAMONDS_Output
VAR_INPUT
	i_xEn: BOOL;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pstStParam_Diamonds_WrRd: POINTER TO StParam_Diamonds_WrRd;
	//2025.10.22.090126 | bai.zy | 配方
	i_pstStRd_PhaseRead : POINTER TO StRd_PhaseRead;	
	i_pstStWrRd_SysCfg: POINTER TO StWrRd_SysCfg;
	i_pstStSysCfgStruct: POINTER TO StSysCfgStruct;	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
END_VAR

VAR
	iGrp: INT;
	iUnitId: INT;
	fbKS_FB_DIAMONDS_SysCfg_WrRd: KS_FB_DIAMONDS_SysCfg_WrRd;
	iMachanicalTypeId: INT;
	arVel_Tar_Pre_Gns : ARRAY [1..2] OF REAL;
	//2026.04.03.114841
	aiGateSa_Pre_GNS: ARRAY [1..MAX_UNIT_NUM] OF INT;
	axSwitch_AutoAdjust_V_Unit: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	iN: INT;
	abyPreCount_ClrPrn: ARRAY [1..2,1..3] OF BYTE;
	byArcIntensity_pre: BYTE;
//2026.5.15.112601
	iK: INT;	
	arStdVol_Coef_Axis_Hmi_Bak: ARRAY [1..2,0..4] OF REAL;
	arStdVol_Diam_Axis_Hmi_Bak: ARRAY [1..2,1..4] OF REAL;
	arStdVol_Volt_Axis_Hmi_Bak: ARRAY [1..2,1..4] OF REAL;
	//2026.5.15.114314
	wChk_Tmp: WORD;
	dwSum_Tmp: DWORD;
	tmTimeOut_ReadPhase: TIME:=T#3000MS;
	tmStart_ReadPhase: TIME;
	axInitTime: ARRAY [1..2] OF BOOL;

	ax_RestorePhase_hmi: ARRAY [1..2] OF BOOL;//实际触发配方的按钮
	afbRestorePhase: ARRAY [1..2] OF R_TRIG;
	

	iMachanicalTypeId_Tmp: INT;

END_VAR

{IMPLEMENTATION}
(*整机参数|2025.08.06.203301*)
	IF i_pstStParam_Diamonds_WrRd^.iCustomerId>=0 THEN
		i_pstStSysParam^.stStSysParam_Save.iCustomerId							:=	i_pstStParam_Diamonds_WrRd^.iCustomerId 									;				 	(*客户ID*)
	END_IF
	i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf						:=	i_pstStParam_Diamonds_WrRd^.dwEquipmentProf 								;				 	(*设备描述*)
	IF i_pstStParam_Diamonds_WrRd^.iUnitMaxNum>=1 THEN
		i_pstStSysParam^.stStSysParam_Save.iUnitMaxNum							:=	i_pstStParam_Diamonds_WrRd^.iUnitMaxNum 									;				 	(*最大色组数*)
	END_IF
	i_pstStSysParam^.stStSysParam_Save.iCurveViewMaxRange					:=	i_pstStParam_Diamonds_WrRd^.iCurveViewMaxRange 								;				 	(*误差曲线量程上限*)
	i_pstStSysParam^.stStSysParam_Save.iTitleTextHeight						:=	i_pstStParam_Diamonds_WrRd^.iTitleTextHeight 								;				 	(*标题字体高度*)
	i_pstStSysParam^.stStSysParam_Save.iEntryTextHeight						:=	i_pstStParam_Diamonds_WrRd^.iEntryTextHeight 								;				 	(*输入框字体高度*)
	i_pstStSysParam^.stStSysParam_Save.iLabelTextHeight						:=	i_pstStParam_Diamonds_WrRd^.iLabelTextHeight 								;				 	(*标签字体高度*)
	i_pstStSysParam^.stStSysParam_Save.iButtonTextHeight 					:=	i_pstStParam_Diamonds_WrRd^.iButtonTextHeight 								;				 	(*按钮字体高度*)
	i_pstStSysParam^.stStSysParam_Save.iMessageTextHeight					:=	i_pstStParam_Diamonds_WrRd^.iMessageTextHeight 								;				 	(*消息字体高度*)
	i_pstStSysParam^.stStSysParam_Save.byLanguageId							:=	i_pstStParam_Diamonds_WrRd^.byLanguageId 									;				 	(*语言设置*)
	i_pstStSysParam^.stStSysParam_Save.byMinutes_ScrSaver					:=	i_pstStParam_Diamonds_WrRd^.byMinutes_ScrSaver 								;				 	(*屏保延时*)
	i_pstStSysParam^.stStSysParam_Save.wMachineArchitectureRef				:=	i_pstStParam_Diamonds_WrRd^.wMachineArchitectureRef 						;				 	(*机器架构描述*)
//	i_pstStSysParam^.stStSysParam_Save.iPromptMsgId							:=	i_pstStParam_Diamonds_WrRd^.iPromptMsgId 									;				 	(*提示信息ID（报警代码）*)
	i_pstStSysParam^.stStSysParam_Save.byHorzCtlMode						:=	i_pstStParam_Diamonds_WrRd^.byHorzCtlMode 									;				 	(*横向控制方式-同步-步进-伺服*)
	i_pstStSysParam^.stStSysParam_Save.byCheckTimeToTips_BrakeResistance	:=	i_pstStParam_Diamonds_WrRd^.byCheckTimeToTips_BrakeResistance 				;				 	(*制动电阻访问超限提示时间*)
	i_pstStSysParam^.stStSysParam_Save.byCheckTimeToEStop_BrakeResistance	:=	i_pstStParam_Diamonds_WrRd^.byCheckTimeToEStop_BrakeResistance 				;				 	(*制动电阻访问超限急停时间*)
	i_pstStSysParam^.stStSysParam_Save.byAccessTimes_BrakeResistance		:=	i_pstStParam_Diamonds_WrRd^.byAccessTimes_BrakeResistance 					;				 	(*制动电阻报警限制*)
	i_pstStSysParam^.stStSysParam_Save.byAlarmHold_VOL_Uw					:=	i_pstStParam_Diamonds_WrRd^.byAlarmHold_VOL_Uw 								;				 	(*放料没料响应时间*)
	i_pstStSysParam^.stStSysParam_Save.byAlarmHold_PrnLength				:=	i_pstStParam_Diamonds_WrRd^.byAlarmHold_PrnLength 							;				 	(*收料印长报警响应时间*)
	i_pstStSysParam^.stStSysParam_Save.byHeatingOutWay_III					:=	i_pstStParam_Diamonds_WrRd^.byHeatingOutWay_III 							;				 	(*三档调整方式-只调最低档、只调最高档、三档同时调*)	
	i_pstStSysParam^.stStSysParam_Save.byHeatingMode						:=	i_pstStParam_Diamonds_WrRd^.byHeatingMode 									;				 	(*温控设置方式切换*)
	i_pstStSysParam^.stStSysParam_Save.rOpenThr_Ele							:=	i_pstStParam_Diamonds_WrRd^.rOpenThr_Ele 									;				 	(*电加热开启*)
	i_pstStSysParam^.stStSysParam_Save.rCloseThr_Ele						:=	i_pstStParam_Diamonds_WrRd^.rCloseThr_Ele 									;				 	(*电加热关闭*)
	i_pstStSysParam^.stStSysParam_Save.rDealValue_Water						:=	i_pstStParam_Diamonds_WrRd^.rDealValue_Water 								;				 	(*水加热死区*)
	i_pstStSysParam^.stStSysParam_Save.iMaxOutValue							:=	i_pstStParam_Diamonds_WrRd^.iMaxOutValue 									;				 	(*最大输出*)
	i_pstStSysParam^.stStSysParam_Save.iHeatingDebugValue_Water				:=	i_pstStParam_Diamonds_WrRd^.iHeatingDebugValue_Water 						;				 	(*测试开度*)
	i_pstStSysParam^.stStSysParam_Save.rKp									:=	i_pstStParam_Diamonds_WrRd^.rKp 											;				 	(*KP*)
	i_pstStSysParam^.stStSysParam_Save.rKi									:=	i_pstStParam_Diamonds_WrRd^.rKi 											;				 	(*KI*)
	i_pstStSysParam^.stStSysParam_Save.rKd									:=	i_pstStParam_Diamonds_WrRd^.rKd 											;				 	(*Kd*)
	i_pstStSysParam^.stStSysParam_Save.iTime_Thres_Water					:=	i_pstStParam_Diamonds_WrRd^.iTime_Thres_Water 								;				 	(*阀门打开时间*)
	i_pstStSysParam^.stStSysParam_Save.iCofe_TempCtl_30						:=	i_pstStParam_Diamonds_WrRd^.iCofe_TempCtl_30 								;				 	(*控制阈值1*)
	i_pstStSysParam^.stStSysParam_Save.iCofe_TempCtl_30_10					:=	i_pstStParam_Diamonds_WrRd^.iCofe_TempCtl_30_10 							;				 	(*控制阈值2*)
	i_pstStSysParam^.stStSysParam_Save.iCofe_TempCtl_10_5					:=	i_pstStParam_Diamonds_WrRd^.iCofe_TempCtl_10_5 								;				 	(*控制阈值3*)
	i_pstStSysParam^.stStSysParam_Save.iCofe_TempCtl_5						:=	i_pstStParam_Diamonds_WrRd^.iCofe_TempCtl_5 								;				 	(*控制阈值4*)
	i_pstStSysParam^.stStSysParam_Save.iWaterValue_Threshold				:=	i_pstStParam_Diamonds_WrRd^.iWaterValue_Threshold 							;				 	(*水电阈值*)
	i_pstStSysParam^.stStSysParam_Save.uiInitDiam_Uw						:=	i_pstStParam_Diamonds_WrRd^.uiInitDiam_Uw 									;				 	(*放料初始卷径*)
	i_pstStSysParam^.stStSysParam_Save.uiInitDiam_Rw						:=	i_pstStParam_Diamonds_WrRd^.uiInitDiam_Rw 									;				 	(*收料初始卷径*)
	i_pstStSysParam^.stStSysParam_Save.diStepDriveDebugPulse				:=	i_pstStParam_Diamonds_WrRd^.diStepDriveDebugPulse 							;				 	(*测试脉冲数*)
	i_pstStSysParam^.stStSysParam_Save.rStepDriveDebugPulse_PosAct			:=	i_pstStParam_Diamonds_WrRd^.rStepDriveDebugPulse_PosAct 					;				 	(*测试距离*)
	i_pstStSysParam^.stStSysParam_Save.iStepDriveDebugNum					:=	i_pstStParam_Diamonds_WrRd^.iStepDriveDebugNum 								;				 	(*测试色组号*)
	i_pstStSysParam^.stStSysParam_Save.rStepDrivePosPPulse					:=	i_pstStParam_Diamonds_WrRd^.rStepDrivePosPPulse 							;				 	(*单位脉冲距离*)
	i_pstStSysParam^.stStSysParam_Save.iStepDrivePulsePRev					:=	i_pstStParam_Diamonds_WrRd^.iStepDrivePulsePRev 							;				 	(*每圈脉冲数*)
	i_pstStSysParam^.stStSysParam_Save.iStepDriveSa_Vel						:=	i_pstStParam_Diamonds_WrRd^.iStepDriveSa_Vel 								;				 	(*启动速度*)
	i_pstStSysParam^.stStSysParam_Save.iStepDrivePreReg_Vel					:=	i_pstStParam_Diamonds_WrRd^.iStepDrivePreReg_Vel 							;				 	(*预套准速度*)
	i_pstStSysParam^.stStSysParam_Save.iStepDriveManu_Vel					:=	i_pstStParam_Diamonds_WrRd^.iStepDriveManu_Vel 								;				 	(*手动低速*)
	i_pstStSysParam^.stStSysParam_Save.iStepDriveManu_Vel_Fast				:=	i_pstStParam_Diamonds_WrRd^.iStepDriveManu_Vel_Fast 						;				 	(*手动高速*)
	i_pstStSysParam^.stStSysParam_Save.iStepDriveAuto_Vel					:=	i_pstStParam_Diamonds_WrRd^.iStepDriveAuto_Vel 								;				 	(*自动速度*)
	i_pstStSysParam^.stStSysParam_Save.iStepDriveAccTime					:=	i_pstStParam_Diamonds_WrRd^.iStepDriveAccTime 								;				 	(*升速时间*)		
	i_pstStSysParam^.stStSysParam_Save.rHz_MainExhaust_ManuallySet			:=	i_pstStParam_Diamonds_WrRd^.rHz_MainExhaust_ManuallySet 					;				 	(*主排风设定频率*)
	i_pstStSysParam^.stStSysParam_Save.byFreq_I_ExhaustAir					:=	i_pstStParam_Diamonds_WrRd^.byFreq_I_ExhaustAir 							;				 	(*排风一档频率*)
	i_pstStSysParam^.stStSysParam_Save.byFreq_II_ExhaustAir					:=	i_pstStParam_Diamonds_WrRd^.byFreq_II_ExhaustAir 							;				 	(*排风二档频率*)
	i_pstStSysParam^.stStSysParam_Save.byFreq_III_ExhaustAir				:=	i_pstStParam_Diamonds_WrRd^.byFreq_III_ExhaustAir 							;				 	(*排风三档频率*)
	(*待补充-开始|2025.08.06.210116*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_PreHotEn_Print				:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_PreHotEn_Print				;(*预热印刷激活开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_ExhAir_Limit_HotWind			:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_ExhAir_Limit_HotWind			;(*排风限制热风开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_ExhAir_Limit_Run				:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_ExhAir_Limit_Run				;(*排风限制开机开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_WatchDevice_Tcp		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_WatchDevice_Tcp		;(*TCP-外部监控设备开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_WatchDevice_485		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_WatchDevice_485		;(*485-外部监控设备开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_1U_485				:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_1U_485				;(*1色人机通讯开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_485					:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_485					;(*485通讯开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_485_Exh				:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_485_Exh				;(*排风485通讯开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_485_Scraper			:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_485_Scraper			;(*刮刀485通讯开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_485_InkRoller			:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_485_InkRoller			;(*递墨辊485通讯开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_CommEn_485_HotWind			:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_CommEn_485_HotWind			;(*热风485通讯开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_ArcIntensityBtn_Hmi			:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_ArcIntensityBtn_Hmi			;(*手动调节随速度走开关*)
	i_pstStSysParam^.stStSysParam_Save.xSwitch_PrnRatioIndividual_Setting	:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_PrnRatioIndividual_Setting	;(*色组版辊减速比单独设置开关*)	
	i_pstStSysParam^.stStSysParam_Save.xSwitch_NetRatioIndividual_Setting	:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_NetRatioIndividual_Setting	;(*色组网辊减速比单独设置开关*)	
	i_pstStSysParam^.stStSysParam_Save.xSwitch_BottomRatioIndividual_Setting:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_BottomRatioIndividual_Setting;(*色组底辊减速比单独设置开关*)	
	i_pstStSysParam^.stStSysParam_Save.xSwitch_StepDriveDebugRun			:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_StepDriveDebugRun			;(*横向步进电机测试执行开关*)
                                                                              
	i_pstStSysParam^.stStSysParam_Save.xSetProPointEn						:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSetProPointEn						;
	i_pstStSysParam^.stStSysParam_Save.xUseMaxTimeAsSBegin_InLowSpeed		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xUseMaxTimeAsSBegin_InLowSpeed   	;
	i_pstStSysParam^.stStSysParam_Save.xPseudoRandomEn               		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xPseudoRandomEn                  	;
	i_pstStSysParam^.stStSysParam_Save.xPseudoRandomStart            		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xPseudoRandomStart               	;
	i_pstStSysParam^.stStSysParam_Save.xEn_RevLimit                  		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xEn_RevLimit                     	;
	i_pstStSysParam^.stStSysParam_Save.xSaveFineSampleData_ToArc     		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSaveFineSampleData_ToArc        	;
	i_pstStSysParam^.stStSysParam_Save.xReqSetLedFunc                		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xReqSetLedFunc                   	;
	i_pstStSysParam^.stStSysParam_Save.xSetHmiResolution             		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSetHmiResolution                	;
	i_pstStSysParam^.stStSysParam_Save.xPopupWindowVisible           		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xPopupWindowVisible              	;
	i_pstStSysParam^.stStSysParam_Save.xInitArcErr_AjdImmediately    		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xInitArcErr_AjdImmediately       	;
	i_pstStSysParam^.stStSysParam_Save.xPhaseAutoRecoveryEn          		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xPhaseAutoRecoveryEn             	;
	i_pstStSysParam^.stStSysParam_Save.xKeepServo_PreRegisterDne     		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xKeepServo_PreRegisterDne        	;
	i_pstStSysParam^.stStSysParam_Save.xUseIfVel_Uw                  		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xUseIfVel_Uw                     	;
	i_pstStSysParam^.stStSysParam_Save.xKeepServo_Stop               		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xKeepServo_Stop                  	;
	i_pstStSysParam^.stStSysParam_Save.xAxisPrfVelEn                 		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xAxisPrfVelEn                    	;
	i_pstStSysParam^.stStSysParam_Save.xUseGc_PID_2025               		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xUseGc_PID_2025                  	;
	i_pstStSysParam^.stStSysParam_Save.xFlag_Follow_1U_Double_V      		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xFlag_Follow_1U_Double_V         	;
	i_pstStSysParam^.stStSysParam_Save.xArcErrCorrectIsRev_V         		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xArcErrCorrectIsRev_V            	;
	i_pstStSysParam^.stStSysParam_Save.xAutoSetSampleType            		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xAutoSetSampleType               	;
	i_pstStSysParam^.stStSysParam_Save.xGetSampleTypeBtn             		:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xGetSampleTypeBtn                	;
	i_pstStSysParam^.stStSysParam_Save.xAutoSetArcCtlWay					:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xAutoSetArcCtlWay                	;	
	i_pstStSysParam^.stStSysParam_Save.iTimeOut_Slave_485_Inverter	:= i_pstStParam_Diamonds_WrRd^.iTimeOut_Slave_485_Inverter;
	i_pstStSysParam^.stStSysParam_Save.byModbusNum_Max	:= i_pstStParam_Diamonds_WrRd^.byModbusNum_Max;
	i_pstStSysParam^.stStSysParam_UnSave.xSwitch_ScraperReset:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_ScraperReset;
	i_pstStSysParam^.stStSysParam_UnSave.xSwitch_InkRollerReset:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_InkRollerReset;
	i_pstStSysParam^.stStSysParam_UnSave.xSwitch_HotwindReset:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_HotwindReset;
	i_pstStSysParam^.stStSysParam_UnSave.xSwitch_ResetTemctlModule:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_ResetTemctlModule;
	i_pstStSysParam^.stStSysParam_UnSave.xSwitch_Copy1stUExhaustDamperPos:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_Copy1stUExhaustDamperPos;
	i_pstStSysParam^.stStSysParam_UnSave.xMoveFreq_I_ToAll_AirHot:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xMoveFreq_I_ToAll_AirHot;
	i_pstStSysParam^.stStSysParam_UnSave.xMoveFreq_II_ToAll_AirHot:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xMoveFreq_II_ToAll_AirHot;
	i_pstStSysParam^.stStSysParam_UnSave.xMoveFreq_III_ToAll_AirHot:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xMoveFreq_III_ToAll_AirHot;
	i_pstStSysParam^.stStSysParam_UnSave.xMoveFreq_I_ToAll_ExhaustAir:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xMoveFreq_I_ToAll_ExhaustAir;
	i_pstStSysParam^.stStSysParam_UnSave.xMoveFreq_II_ToAll_ExhaustAir:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xMoveFreq_II_ToAll_ExhaustAir;
	i_pstStSysParam^.stStSysParam_UnSave.xMoveFreq_III_ToAll_ExhaustAir:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xMoveFreq_III_ToAll_ExhaustAir;
	i_pstStSysParam^.stStSysParam_Save.byFreq_I_AirHot:= i_pstStParam_Diamonds_WrRd^.byFreq_I_AirHot;
	i_pstStSysParam^.stStSysParam_Save.byFreq_II_AirHot:= i_pstStParam_Diamonds_WrRd^.byFreq_II_AirHot;
	i_pstStSysParam^.stStSysParam_Save.byFreq_III_AirHot:= i_pstStParam_Diamonds_WrRd^.byFreq_III_AirHot;
	i_pstStSysParam^.stStSysParam_Save.byFreq_I_ExhaustAir:= i_pstStParam_Diamonds_WrRd^.byFreq_I_ExhaustAir;
	i_pstStSysParam^.stStSysParam_Save.byFreq_II_ExhaustAir:= i_pstStParam_Diamonds_WrRd^.byFreq_II_ExhaustAir;
	i_pstStSysParam^.stStSysParam_Save.byFreq_III_ExhaustAir:= i_pstStParam_Diamonds_WrRd^.byFreq_III_ExhaustAir;
	//还有遗漏啊@2026.05.26.214611
	(*2025.10.28.112509*)
	i_pstStSysParam^.stStSysParam_Save.byExhaustMode			:=i_pstStParam_Diamonds_WrRd^.byExhaustMode				;
	i_pstStSysParam^.stStSysParam_Save.byExhaustLinkageNum	:=i_pstStParam_Diamonds_WrRd^.byExhaustLinkageNum			;
	i_pstStSysParam^.stStSysParam_Save.byFreqMax_ExhaustAir	:=i_pstStParam_Diamonds_WrRd^.byFreqMax_ExhaustAir		;
	i_pstStSysParam^.stStSysParam_Save.byFreqMin_ExhaustAir	:=i_pstStParam_Diamonds_WrRd^.byFreqMin_ExhaustAir		;
	i_pstStSysParam^.stStSysParam_Save.byCoefExhaust			:=i_pstStParam_Diamonds_WrRd^.byCoefExhaust				;
	//2026.05.26.214806+
	i_pstStSysParam^.stStSysParam_Save.byOverPercent_RatedRpm:=i_pstStParam_Diamonds_WrRd^.byOverPercent_RatedRpm		;
	i_pstStSysParam^.stStSysParam_Save.uiMaxDia				:=i_pstStParam_Diamonds_WrRd^.uiMaxDia					;

(*机械参数2025.10.28.151626*)
	g_stStSysParam.stStSysParam_Save.byMechanicalTypeId:= i_pstStParam_Diamonds_WrRd^.byMachanicalTypeId;//i_pstStParam_Diamonds_WrRd^.stStWrRd_MechanicalType.byMachanicalTypeId;
	iMachanicalTypeId:= BYTE_TO_INT(i_pstStParam_Diamonds_WrRd^.byMachanicalTypeId);
//	IF iMachanicalTypeId>=1 AND iMachanicalTypeId<=5 THEN 
	FOR iMachanicalTypeId_Tmp:= 1 TO 5 BY 1 DO
		SysMemCpy(
			ADR(i_pstStSysParam^.stStSysParam_Save.astStMechanicalParamBuf[iMachanicalTypeId_Tmp].abyBuf),
			ADR(i_pstStParam_Diamonds_WrRd^.astStMechanicalParamBuf[iMachanicalTypeId_Tmp].abyBuf),
			SIZEOF(i_pstStParam_Diamonds_WrRd^.astStMechanicalParamBuf[iMachanicalTypeId_Tmp].abyBuf),
		);
	END_FOR
//	END_IF
		
	(*待补充-结束|2025.08.06.210116*)
(*2025.8.25.152610||增加当前波形通道选择2025.8.25.152623*)
	i_pstStSysParam^.stStSysParam_Save.iUid			:= i_pstStParam_Diamonds_WrRd^.iUid_Choose;
	(*2025.7.3.175755——||| 9905界面参数*)
	i_pstStSysParam^.stStSysParam_Save.uiMaxVel_UseCalcAcc				:=	i_pstStParam_Diamonds_WrRd^.uiMaxVel_UseCalcAcc							 ;
	i_pstStSysParam^.stStSysParam_Save.byPseudoRandomRoundTimes			:=	i_pstStParam_Diamonds_WrRd^.byPseudoRandomRoundTimes					 ;
	i_pstStSysParam^.stStSysParam_Save.rPseudoRandomAmplitude			:=	i_pstStParam_Diamonds_WrRd^.rPseudoRandomAmplitude						 ;
	i_pstStSysParam^.stStSysParam_Save.bySetTestPid_IfOf				:=	i_pstStParam_Diamonds_WrRd^.bySetTestPid_IfOf							 ;
	i_pstStSysParam^.stStSysParam_Save.by10vSignalCoef					:=	i_pstStParam_Diamonds_WrRd^.by10vSignalCoef								 ;
	i_pstStSysParam^.stStSysParam_Save.rCompensateGirthWhenAccing_If	:=	i_pstStParam_Diamonds_WrRd^.rCompensateGirthWhenAccing_If				 ;
	i_pstStSysParam^.stStSysParam_Save.rCompensateGirthWhenAccing_Of	:=	i_pstStParam_Diamonds_WrRd^.rCompensateGirthWhenAccing_Of				 ;
	i_pstStSysParam^.stStSysParam_Save.byArcDeCoupleStepTest			:=	i_pstStParam_Diamonds_WrRd^.byArcDeCoupleStepTest						 ;
	i_pstStSysParam^.stStSysParam_Save.iCustomerLogoOffsetX				:=	i_pstStParam_Diamonds_WrRd^.iCustomerLogoOffsetX						 ;
	i_pstStSysParam^.stStSysParam_Save.byGuardrialColor_R				:=	i_pstStParam_Diamonds_WrRd^.byGuardrialColor_R							 ;
	i_pstStSysParam^.stStSysParam_Save.byGuardrialColor_G				:=	i_pstStParam_Diamonds_WrRd^.byGuardrialColor_G							 ;
	i_pstStSysParam^.stStSysParam_Save.byGuardrialColor_B				:=	i_pstStParam_Diamonds_WrRd^.byGuardrialColor_B							 ;
	i_pstStSysParam^.stStSysParam_Save.iLedFuncId						:=	i_pstStParam_Diamonds_WrRd^.iLedFuncId									 ;
	i_pstStSysParam^.stStSysParam_Save.iSetHmiResValue					:=	i_pstStParam_Diamonds_WrRd^.iSetHmiResValue								 ;
	i_pstStSysParam^.stStSysParam_Save.wRunningTime_Day					:=	i_pstStParam_Diamonds_WrRd^.wRunningTime_Day							 ;
	i_pstStSysParam^.stStSysParam_Save.byRunningTime_Hour				:=	i_pstStParam_Diamonds_WrRd^.byRunningTime_Hour							 ;
	i_pstStSysParam^.stStSysParam_Save.byRunningTime_Min				:=	i_pstStParam_Diamonds_WrRd^.byRunningTime_Min							 ;
	i_pstStSysParam^.stStSysParam_Save.byRunningTime_Sec				:=	i_pstStParam_Diamonds_WrRd^.byRunningTime_Sec							 ;
	i_pstStSysParam^.stStSysParam_Save.byArcIntensity_W					:=	i_pstStParam_Diamonds_WrRd^.byArcIntensity_W							 ;
	i_pstStSysParam^.stStSysParam_Save.byArcIntensity_M					:=	i_pstStParam_Diamonds_WrRd^.byArcIntensity_M							 ;
	i_pstStSysParam^.stStSysParam_Save.byArcIntensity_S					:=	i_pstStParam_Diamonds_WrRd^.byArcIntensity_S							 ;
	i_pstStSysParam^.stStSysParam_Save.byMotorOverTempValue_UseEncTemp	:=	i_pstStParam_Diamonds_WrRd^.byMotorOverTempValue_UseEncTemp				 ;
	i_pstStSysParam^.stStSysParam_Save.byRemainSpaceNum_PTCTL         	:=	i_pstStParam_Diamonds_WrRd^.byRemainSpaceNum_PTCTL         				 ;
	i_pstStSysParam^.stStSysParam_Save.rSpeed_SCoeff_Type789          	:=	i_pstStParam_Diamonds_WrRd^.rSpeed_SCoeff_Type789          				 ;
	i_pstStSysParam^.stStSysParam_Save.byMaxPulseOut_16dIO            	:=	i_pstStParam_Diamonds_WrRd^.byMaxPulseOut_16dIO            				 ;
	i_pstStSysParam^.stStSysParam_Save.bySysSamplePrecision           	:=	i_pstStParam_Diamonds_WrRd^.bySysSamplePrecision           				 ;
	i_pstStSysParam^.stStSysParam_Save.byArcAdjValueDealType          	:=	i_pstStParam_Diamonds_WrRd^.byArcAdjValueDealType          				 ;
	i_pstStSysParam^.stStSysParam_Save.byArcErrLimitToCtl_P           	:=	i_pstStParam_Diamonds_WrRd^.byArcErrLimitToCtl_P           				 ;
	i_pstStSysParam^.stStSysParam_Save.byArcErrLimitToCtl_I           	:=	i_pstStParam_Diamonds_WrRd^.byArcErrLimitToCtl_I           				 ;
	i_pstStSysParam^.stStSysParam_Save.byMaxPulseOut_Module           	:=	i_pstStParam_Diamonds_WrRd^.byMaxPulseOut_Module           				 ;
	i_pstStSysParam^.stStSysParam_Save.byArcFineSampleType            	:=	i_pstStParam_Diamonds_WrRd^.byArcFineSampleType            				 ;
	i_pstStSysParam^.stStSysParam_Save.byArcPidGetType                	:=	i_pstStParam_Diamonds_WrRd^.byArcPidGetType                				 ;
	i_pstStSysParam^.stStSysParam_Save.rFilmLenth_Eyes                	:=	i_pstStParam_Diamonds_WrRd^.rFilmLenth_Eyes                				 ;
	i_pstStSysParam^.stStSysParam_Save.uiArcSysDelayTime_ms           	:=	i_pstStParam_Diamonds_WrRd^.uiArcSysDelayTime_ms           				 ;
	i_pstStSysParam^.stStSysParam_Save.byParamIndex_Huang				:=	i_pstStParam_Diamonds_WrRd^.byParamIndex_Huang							 ;
	i_pstStSysParam^.stStSysParam_Save.uiControllerVel_Huang			:=	i_pstStParam_Diamonds_WrRd^.uiControllerVel_Huang						 ;
	i_pstStSysParam^.stStSysParam_Save.byCouplingType					:=	i_pstStParam_Diamonds_WrRd^.byCouplingType								 ;
	i_pstStSysParam^.stStSysParam_Save.byDeCoupleArcNum					:=	i_pstStParam_Diamonds_WrRd^.byDeCoupleArcNum							 ;
	i_pstStSysParam^.stStSysParam_Save.xWorkMode_Inch:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xWorkMode_Inch;
(*2025.10.24.134149|油墨槽控制*)
	i_pstStSysParam^.stStSysParam_Save.xInkGrooveCtlEn		:= i_pstStParam_Diamonds_WrRd^.xInkGrooveCtlEn		;
	i_pstStSysParam^.stStSysParam_Save.xInkGrooveCtlDirRev	:= i_pstStParam_Diamonds_WrRd^.xInkGrooveCtlDirRev	;	
	i_pstStSysParam^.stStSysParam_UnSave.xInkGrooveCali_Hmi	:= i_pstStParam_Diamonds_WrRd^.xInkGrooveCali_Hmi	;
	i_pstStSysParam^.stStSysParam_Save.iInkGroove_Vel		:= i_pstStParam_Diamonds_WrRd^.iInkGroove_Vel		;
	i_pstStSysParam^.stStSysParam_Save.iInkGrooveMoveDis_Max:= i_pstStParam_Diamonds_WrRd^.iInkGrooveMoveDis_Max;
	i_pstStSysParam^.stStSysParam_Save.iInkGrooveSa_Vel		:= i_pstStParam_Diamonds_WrRd^.iInkGrooveSa_Vel	;	
	i_pstStSysParam^.stStSysParam_Save.iInkGrooveAccTime	:= i_pstStParam_Diamonds_WrRd^.iInkGrooveAccTime	;
	i_pstStSysParam^.stStSysParam_Save.iInkGroovePulsePRev	:= i_pstStParam_Diamonds_WrRd^.iInkGroovePulsePRev	;
	i_pstStSysParam^.stStSysParam_Save.rInkGroovePosPPulse	:= i_pstStParam_Diamonds_WrRd^.rInkGroovePosPPulse	;
(*2025.10.24.134628*)	
(*2025.11.4.130939*)
	i_pstStSysParam^.stStSysParam_Save.byExhaustMode:= i_pstStParam_Diamonds_WrRd^.byExhaustMode;
//2026.4.25.144922
	IF byArcIntensity_pre= i_pstStSysParam^.stStSysParam_Save.byArcIntensity THEN
		i_pstStSysParam^.stStSysParam_Save.byArcIntensity:= i_pstStParam_Diamonds_WrRd^.byArcIntensity	;
	END_IF
	byArcIntensity_pre:= i_pstStSysParam^.stStSysParam_Save.byArcIntensity;	
(*系参数|2025.08.06.202852*)
FOR iGrp:=1 TO 2 BY 1 DO
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_AxiaA_Uw	:=	i_pstStParam_Diamonds_WrRd^.arGirth_AxiaA_Uw[iGrp]  		 ;								(*放料A轴周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_AxiaB_Uw 	:=	i_pstStParam_Diamonds_WrRd^.arGirth_AxiaB_Uw[iGrp]  		 ;								(*放料B轴周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_AxiaA_Rw 	:=	i_pstStParam_Diamonds_WrRd^.arGirth_AxiaA_Rw[iGrp]  		 ;								(*收料A轴周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_AxiaB_Rw 	:=	i_pstStParam_Diamonds_WrRd^.arGirth_AxiaB_Rw[iGrp]  		 ;								(*收料B轴周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_PrnRoller 	:=	i_pstStParam_Diamonds_WrRd^.arGirth_Pu[iGrp]        		 ;								(*版周长*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rTaperValueBegin_Hmi_Rw 	:=	i_pstStParam_Diamonds_WrRd^.arTaper_Begin_Rw[iGrp]  		 ;								(*收料锥度-大张力*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rTaperValueEnd_Hmi_Rw 	:=	i_pstStParam_Diamonds_WrRd^.arTaper_End_Rw[iGrp]    		 ;								(*收料锥度-小张力*)
//先加个保护看看是不是界面给他更新了，目标速度
	IF arVel_Tar_Pre_Gns[iGrp] = i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Tar THEN
		//如果GNS更新了，就把他更新到界面先
		i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Tar 			:=	i_pstStParam_Diamonds_WrRd^.arVel_Tar[iGrp]         		 ;							(*目标速度*)
	END_IF
	arVel_Tar_Pre_Gns[iGrp] := i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Tar;		
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Tar 			:=	i_pstStParam_Diamonds_WrRd^.arVel_Tar[iGrp]         		 ;								(*目标速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_AutoAcc 	:=	i_pstStParam_Diamonds_WrRd^.aiTime_AutoAcc[iGrp]    		 ;								(*自动加速时间（S）*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_AutoDec 	:=	i_pstStParam_Diamonds_WrRd^.aiTime_AutoDec[iGrp]    		 ;								(*自动减速时间（S）*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_ManuAcc 	:=	i_pstStParam_Diamonds_WrRd^.aiTime_ManuAcc[iGrp]    		 ;								(*手动加速时间（S）*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_ManuDec 	:=	i_pstStParam_Diamonds_WrRd^.aiTime_ManuDec[iGrp]    		 ;								(*手动减速时间（S）*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_FastStop 	:=	i_pstStParam_Diamonds_WrRd^.aiTime_FastStop[iGrp]   		 ;								(*快停时间（S）*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_Estop 		:=	i_pstStParam_Diamonds_WrRd^.aiTime_Estop[iGrp]      		 ;								(*急停时间（S)*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_Stop 		:=	i_pstStParam_Diamonds_WrRd^.aiTime_Stop[iGrp]      		 ;								(*急停时间（S)*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].alrPrnLen_Alr[1]		:=	i_pstStParam_Diamonds_WrRd^.adwPrnLen_Alarm[iGrp,1]		 ;								(*印长报警*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].alrPrnLen_Alr[2]		:=	i_pstStParam_Diamonds_WrRd^.adwPrnLen_Alarm[iGrp,2]		 ;								(*印长报警*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].alrPrnLen_Alr[3]		:=	i_pstStParam_Diamonds_WrRd^.adwPrnLen_Alarm[iGrp,3]		 ;								(*印长报警*)
	(*待补充-开始|2025.08.06.215021*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xMachineRev  			                := 	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_MachineRev ;                    (*反向走料开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseKnob_6Inch_Rw_Hmi 				    := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_6Inch_Rw 	;            (*收料3/6吋选择开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_StartUp 				            :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_StartUp	;                (*一键开机开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xDiamMeasureAutomatic_Uw 		            := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamMeasureAuto ;          (*自动卷径开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_RollOver 				            := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_RollOver	;                (*设备翻料架开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xGetFilmThickNessAuto 				    := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Thickness 	;            (*料膜厚度手自动获取开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xCutDneResetPidEn_Uw	                    :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_CutDneResetPidEn_Uw	;            (*放料裁切后系数手自动*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xCutDneResetPidEn_Rw	                    :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_CutDneResetPidEn_Rw	;            (*收料裁切后系数手自动*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xAutomaticCutEn_Uw		                := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_AutomaticCutEn_Uw 	;            (*放料自动接料是能*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xAutomaticCutEn_Rw		                :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_AutomaticCutEn_Rw	;            (*放料自动接料是能*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xSwitch_AutoAdjust_V_Grp		        := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_AutoAdjust_V_Grp 	;    (*整机纵向自动调整开关*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xSwitch_AutoAdjust_H_Grp		        :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_AutoAdjust_H_Grp	;    (*整机纵向自动调整开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xFlag_Follow_1U_V 		                := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Follow_1U_V_Grp	;                (*纵向跟1色开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xFlag_Follow_1U_H		                    :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Follow_1U_H_Grp	;                (*横向跟1色开关*)	
	(*卷径检测处理|2025.09.12.162434*)
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Pot THEN(*卷径检测使用电位器*)
		i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw :=1 ; 
	END_IF
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Enc THEN(*卷径检测使用编码器*)
		i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw :=2 ; 
	END_IF
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Ultrasonic_S THEN(*卷径检测使用单超声波*)
		i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw :=3 ; 
	END_IF
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Ultrasonic_D	THEN(*卷径检测使用双超声波*)
		i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw :=3 ; 
	END_IF
	(*
	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Pot			                := i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw=1 	;        (*卷径检测使用电位器*)
	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Enc			                := i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw=2 	;        (*卷径检测使用编码器*)
	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Ultrasonic_S	                := i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw=3 	;        (*卷径检测使用单超声波*)
	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_Ultrasonic_D	                := i_pstStSysParam^.astStGrpParam_Save[iGrp].byDiamMeasureTypeId_Uw=4 	;        (*卷径检测使用双超声波*)
	*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xFlag_AxisABParaFroDiaMea_Uw	                := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DiamAuto_DualParam 	;(*卷径检测双轴参数分开*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xIsDebugMode_Machine			                := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DebugMode	 	;(*调试模式开关*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xIsDebug_DiaMeasure_Uw	                :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_DiamMeasure_Uw	;(*放料卷径检测电位器调试开关*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].axMeasure_StdVol[1]		                :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Diameasure_Confirm_1	;(*自动卷径标定——1*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].axMeasure_StdVol[2]		                :=  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Diameasure_Confirm_2	;(*自动卷径标定——2*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].axMeasure_StdVol[3]		                := 	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Diameasure_Confirm_3;(*自动卷径标定——3*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].axMeasure_StdVol[4]		                := 	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Diameasure_Confirm_4;(*自动卷径标定——4*)
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseAbsEncoder_Uw							:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_UseAbsEnc_Uw;(*放料使用绝对值编码器开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xEn_DualParam_AbsEncLocation_Uw			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_AxisLocaltion_DualParam_Uw;(*放料绝对值编码器定位双轴参数开关*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xDebug_Enc_Uw							:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Axis_Uw;(*放料轴运行调试模式*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCutterOnTopFroDebug_Uw					:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Uw_CutUpChoose;(*放料绝对值编码器定位调试-上裁选择*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCurAxisAFroDebug_Uw	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Uw_AxisA_Choose;
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Debug_Uw_Wr THEN
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Debug_Uw_Wr:= FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].byEncodeValueWr_Uw:= 1;
	END_IF
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Debug_Uw_MinDiam_Wr THEN
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Debug_Uw_MinDiam_Wr:= FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].byEncodeValueWr_Uw:= 2;
	END_IF
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseAbsEncoder_Rw							:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_UseAbsEnc_Rw;(*放料使用绝对值编码器开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_AxisLocaltion_DualParam_Rw:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_AxisLocaltion_DualParam_Rw;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xDebug_Enc_Rw:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Axis_Rw;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCutterOnTopFroDebug_Rw					:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Rw_CutUpChoose;(*放料绝对值编码器定位调试-上裁选择*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCurAxisAFroDebug_Rw	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Rw_AxisA_Choose;
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Debug_Rw_Wr THEN
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Debug_Rw_Wr:= FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].byEncodeValueWr_Rw:= 1;
	END_IF
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_GiveupHeaderEn:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Scrap_Avoidance;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xFlag_CCW_AfterCutted_Uw:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_CCW_AfterCut_Uw;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xCutUseReflectionSensor_Uw	:=	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_CutUseReflectionSensor				 ;(*放料裁切使用弧面开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseRadCompensate_Uw:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_UseRadCompensate_Uw;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xTowerDir_Uw:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_TowerDir_Uw;
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ConfirmRad0_Uw THEN
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ConfirmRad0_Uw:= FALSE;
		i_pstStSysParam^.astStGrpParam_Save[iGrp].xConfirmRad0_Uw:= TRUE;
	END_IF
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.0:= 
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Spd_Uw (*OR
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_SpdAxisB_Uw*);
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.1:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisA_Uw_MoveEn;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.2:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisA_Uw_AccEn;
	
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.4:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisB_Uw_MoveEn;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.5:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisB_Uw_AccEn;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.8:= 
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_Spd_Rw (*OR
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Debug_SpdAxisB_Rw*);
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.9:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisA_Rw_MoveEn;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.10:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisA_Rw_AccEn;
	
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.12:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisB_Rw_MoveEn;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.13:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_DebugSpdAxisB_Rw_AccEn;
 	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseFollow_1U_V_UwCut:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_UseFollow_1U_V_UwCut ;(*裁切套色新方式开关*)
	i_pstStSysParam^.stStSysParam_Save.xTypeGetInitDiam:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_TypeGetInitDiam ;(*收放料初始卷径获取方式*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllHeating_I			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Heating_I			;//	: BIT;(*全体加热I当*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllHeating_II		  	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Heating_II		;//	: BIT;(*全体加热II当*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllHeating_III			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Heating_III		;//    : BIT;(*全体加热III当*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllHeating_Close		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Heating_Close		;//	: BIT;(*全体加热关*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllHeating_Water	 	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Heating_Water		;//    : BIT;	(*全体水加热*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllHeating_Elc			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Heating_Elc		;//	: BIT;(*全体电加热*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_CopySV_1U_To_Other		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_CopySV_1U_To_Other	;//	: BIT;(*复制1U排风频率到所有色*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_Reset_TempCtlBlock		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_Reset_TempCtlBlock	;//	: BIT;(*复位温控模块按钮*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllExhAir_On			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_AllExhAir_On			;//	: BIT;(*全体排风开*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_AllExhAir_Off			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_AllExhAir_Off		;//	: BIT;(*全体排风关*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_CopyExhFreq_1U_To_Other	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_CopyExhFreq_1U_To_Other;//	: BIT;(*复制1U排风频率到所有色*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_ExhAir_Reset			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ExhAir_Reset			;//	: BIT;(*排风复位按钮*)
				
	
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_StepTest_V			:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_StepTest_V           ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseDiam_LowPass_Rw		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseDiam_LowPass_Rw       ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xTensionCompensateEn_Rw	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xTensionCompensateEn_Rw   ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseTime_b1_Rw				:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseTime_b1_Rw            ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseTime_Variaition_Rw		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseTime_Variaition_Rw    ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseIMatrix_rX_DARE_Rw		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseIMatrix_rX_DARE_Rw    ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xTensionCompensateEn_RwCut	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xTensionCompensateEn_RwCut;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseDiam_LowPass_Uw		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseDiam_LowPass_Uw       ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xTensionCompensateEn_Uw	:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xTensionCompensateEn_Uw   ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseTime_b1_Uw				:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseTime_b1_Uw            ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseTime_Variaition_Uw		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseTime_Variaition_Uw    ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseIMatrix_rX_DARE_Uw		:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseIMatrix_rX_DARE_Uw    ;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xDiaEstEn_Uw:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Estimate_Uw;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xDiaEstEn_Rw:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Estimate_Rw;


	i_pstStSysParam^.astStGrpParam_Save[iGrp].xPidType_If_New	:=	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xPidType_If_New								 	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xPidType_Of_New	:=	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xPidType_Of_New                 				 	;

	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_TempFromEnc_PT1000_If:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_TempFromEnc_PT1000_If;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_TempFromEnc_PT1000_Of:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_TempFromEnc_PT1000_Of;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_MotorTemp_PT1000_NTC_If:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_MotorTemp_PT1000_NTC_If;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_MotorTemp_PT1000_NTC_Of:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_MotorTemp_PT1000_NTC_Of;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_Alarm_Arc:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Alarm_Arc;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_PreHotAirEn:=	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_PreHotAirEn;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_PreHeatingEn:=	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_PreHeatingEn;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_ScraperAuto_If:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_ScraperAuto ;(*刮刀手自动*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_ScraperOn_If := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_ScraperOn	;(*刮刀开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_InkRollerAuto_If:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_InkRollerAuto ;(*递墨辊手自动*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_InkRollerCW_If := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_InkRollerCW;(*递墨辊正转*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_InkRollerCCW_If:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_InkRollerCCW ;(*递墨辊反转*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_ScraperAuto_Of:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_ScraperAuto ;(*刮刀手自动*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_ScraperOn_Of := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_ScraperOn	;(*刮刀开关*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_InkRollerAuto_Of:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_InkRollerAuto ;(*递墨辊手自动*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_InkRollerCW_Of := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_InkRollerCW;(*递墨辊正转*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_InkRollerCCW_Of:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_InkRollerCCW ;(*递墨辊反转*)
	
	
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xIsDebugMode_Machine 		:=	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_DebugMode				 ;(*调试模式开关*)

	//2025.9.18.171636
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wAI_polarity.0:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xNegPolarity_Uw;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wAI_polarity.1:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xNegPolarity_Rw;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wAI_polarity.2:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xNegPolarity_If;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wAI_polarity.3:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xNegPolarity_Of;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitchTension_If:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitchTension_If;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitchTension_Of:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitchTension_Of;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseBtn_Linkage:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseBtn_Linkage;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_ScraperOn_Of:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_ScraperOn_Of;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xTensionCompensateEn_UwCut:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xTensionCompensateEn_UwCut;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xUseAntiNotch_Uw := i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseAntiNotch_Uw;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xWorkMode_RollerPress:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xWorkMode_RollerPress;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_WaitFilmLengthEn:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_WaitFilmLengthEn;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_WaitFilmLengthEn_From1st:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_WaitFilmLengthEn_From1st;
	
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_PreRegisterAxisId_Manu:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_PreRegisterAxisId_Manu;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_PreRegister:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_PreRegister;
// 	IF  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_PreRegister= TRUE THEN
// 		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_PreRegister:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_PreRegister;
// 	END_IF
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_PreRegisterCorrConfirm:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_PreRegisterCorrConfirm;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_HorzPreRegister_Repeat:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_HorzPreRegister_Repeat;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_HorzPreRegister_Setup:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_HorzPreRegister_Setup;
	
	
	(*待补充-结束|2025.08.06.215042*)																										
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiamAlarm_Uw						:=   DWORD_TO_REAL(i_pstStParam_Diamonds_WrRd^.adwDiamAlarm_Uw[iGrp])			 ;				(*放料报警卷径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rFilmThickNess_Using				:=	i_pstStParam_Diamonds_WrRd^.arFilmThickNess_Using[iGrp]						 ;				(*料膜厚度手动输入值*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rInitTaper_Hmi_Rw					:=	i_pstStParam_Diamonds_WrRd^.arInitTaper_Hmi_Rw[iGrp]						 ;				(*收料起始气压*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arVel_Usr[1]						:=	i_pstStParam_Diamonds_WrRd^.auiVel_CommonlyUsed[iGrp,1]					 ;				(*常用速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arVel_Usr[2]						:=	i_pstStParam_Diamonds_WrRd^.auiVel_CommonlyUsed[iGrp,2]					 ;				(*常用速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arVel_Usr[3]						:=	i_pstStParam_Diamonds_WrRd^.auiVel_CommonlyUsed[iGrp,3]					 ;				(*常用速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iCutDneResetPidMultiple_Uw		:=	i_pstStParam_Diamonds_WrRd^.aiCutDneResetPidMultiple_Uw[iGrp]				 ;				(*裁切PID放大系数-放料*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iCutDneResetPidRemainTime_Uw		:=	i_pstStParam_Diamonds_WrRd^.aiCutDneResetPidRemainTime_Uw[iGrp]				 ;				(*裁切PID放大保持时间-放料*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iCutDneResetPidToDefaultTime_Uw	:=	i_pstStParam_Diamonds_WrRd^.aiCutDneResetPidDefaultTime_Uw[iGrp]			 ;				(*裁切PID放大恢复时间-放料*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iCutDneResetPidMultiple_Rw		:=	i_pstStParam_Diamonds_WrRd^.aiCutDneResetPidMultiple_Rw[iGrp]				 ;				(*裁切PID放大系数-收料*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iCutDneResetPidRemainTime_Rw		:=	i_pstStParam_Diamonds_WrRd^.aiCutDneResetPidRemainTime_Rw[iGrp]				 ;				(*裁切PID放大保持时间-收料*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iCutDneResetPidToDefaultTime_Rw	:=	i_pstStParam_Diamonds_WrRd^.aiCutDneResetPidDefaultTime_Rw[iGrp]			 ;				(*裁切PID放大恢复时间-收料*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAutoMaticCutMode_uw				:=	i_pstStParam_Diamonds_WrRd^.abyAutoMaticCutMode_uw[iGrp]					 ;				(*放料自动接料方式-剩余卷径/剩余米数*)
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDia_PaperRoller_Uw			:=		i_pstStParam_Diamonds_WrRd^.arDia_PaperRoller_Uw[iGrp]			 	;							(*放料纸筒直径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiAutoMaticCutDia_Uw			:=		i_pstStParam_Diamonds_WrRd^.auiAutoMaticCutDia_Uw[iGrp]			 	;							(*放料剩余卷径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiAutoMaticCutMeters_Uw		:=		i_pstStParam_Diamonds_WrRd^.auiAutoMaticCutMeters_Uw[iGrp]		 	;							(*放料剩余米数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAutoMaticCutMode_Rw			:=		i_pstStParam_Diamonds_WrRd^.abyAutoMaticCutMode_Rw[iGrp]		 	;							(*收料自动接料方式-收料米数/整机料长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiAutoMaticCutMeters_Rw		:=		i_pstStParam_Diamonds_WrRd^.auiAutoMaticCutMeters_Rw[iGrp]		 	;							(*收料米数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byLenth_Machine				:=		i_pstStParam_Diamonds_WrRd^.abyLenth_Machine[iGrp]				 	;							(*整机料长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rPressure_Max					:=		i_pstStParam_Diamonds_WrRd^.arPressure_Max[iGrp]				 	;							(*涂布压力传感器最大标定压力值*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rHz_MainExhaust_ManuallySet   :=		i_pstStParam_Diamonds_WrRd^.arHz_MainExhaust_ManuallySet[iGrp]	 	;							(*主排风手动频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iMarkTypeId					:=		i_pstStParam_Diamonds_WrRd^.aiMarkId[iGrp]						 	;							(*色斑形式*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iMarkArrangeMode				:=		i_pstStParam_Diamonds_WrRd^.aicurMarkArrangeId[iGrp]			 	;							(*色标顺序*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byTriMark_SideC				:=		i_pstStParam_Diamonds_WrRd^.abyTriMark_SideC[iGrp]				 	;							(*梯标直边宽度1mm*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byTriMark_SideB				:=		i_pstStParam_Diamonds_WrRd^.abyTriMark_SideB[iGrp]				 	;							(*梯标直边宽度2mm*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rAI_med_Uw					:=		i_pstStParam_Diamonds_WrRd^.arAI_med_Uw[iGrp]					 	;							(*放料摆臂中位值/rAI_med_Uw*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rAI_med_Rw					:=		i_pstStParam_Diamonds_WrRd^.arAI_med_Rw[iGrp]					 	;							(*收料摆臂中位值/rAI_med_Rw*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rAI_med_If					:=		i_pstStParam_Diamonds_WrRd^.arAI_med_If[iGrp]					 	;							(*放牵摆臂中位值/rAI_med_If*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rAI_med_Of					:=		i_pstStParam_Diamonds_WrRd^.arAI_med_Of[iGrp]					 	;							(*收牵摆臂中位值/rAI_med_Of*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedRpm_Uw					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedRpm_Uw[iGrp])		;						(*额定转速*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedFreq_Uw					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedFreq_Uw[iGrp])		;						(*额定频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iUpperFreq_Uw					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arUpperFreq_Uw[iGrp])		;						(*上限频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedRpm_Rw					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedRpm_Rw[iGrp]	)		;						(*额定转速*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedFreq_Rw					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedFreq_Rw[iGrp])		;						(*额定频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iUpperFreq_Rw					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arUpperFreq_Rw[iGrp])		;						(*上限频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedRpm_If					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedRpm_If[iGrp]	)		;						(*额定转速*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedFreq_If					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedFreq_If[iGrp])		;						(*额定频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iUpperFreq_If					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arUpperFreq_If[iGrp])		;						(*上限频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedRpm_Of					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedRpm_Of[iGrp]	)		;						(*额定转速*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatedFreq_Of					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arRatedFreq_Of[iGrp])		;						(*额定频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iUpperFreq_Of					:=		REAL_TO_INT(i_pstStParam_Diamonds_WrRd^.arUpperFreq_Of[iGrp])		;						(*上限频率*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiam_taper_begin_Rw			:=		i_pstStParam_Diamonds_WrRd^.arDiamTaper_Begin_Rw[iGrp]			 		;						(*锥度起始直径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiam_taper_end_Rw			:=		i_pstStParam_Diamonds_WrRd^.arDiamTaper_End_Rw[iGrp]             		;						(*锥度结束直径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_3inch_Rw				:=		i_pstStParam_Diamonds_WrRd^.arGirth_3Inch[iGrp]                  		;						(*收料3吋默认周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_6inch_Rw				:=		i_pstStParam_Diamonds_WrRd^.arGirth_6Inch[iGrp]                  		;						(*收料6吋默认周长*)	
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Uw[1]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_SVol_Uw[iGrp,1]	   		;											(*放料PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Uw[2]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_SVol_Uw[iGrp,2]	   		;											(*放料PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Uw[3]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_SVol_Uw[iGrp,3]	   		;											(*放料PID设定*)
																														
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Rw[1]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_SVol_Rw[iGrp,1]	   		;											(*收料PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Rw[2]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_SVol_Rw[iGrp,2]	   		;											(*收料PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Rw[3]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_SVol_Rw[iGrp,3]	   		;											(*收料PID设定*)
																														
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_If[1]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_If[iGrp,1]			   		;											(*放牵PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_If[2]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_If[iGrp,2]			   		;											(*放牵PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_If[3]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_If[iGrp,3]			   		;											(*放牵PID设定*)
																														
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Of[1]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_Of[iGrp,1]			   		;											(*收牵PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Of[2]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_Of[iGrp,2]			   		;											(*收牵PID设定*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].arKpid_Of[3]		:=	i_pstStParam_Diamonds_WrRd^.arKpid_Of[iGrp,3]			   		;											(*收牵PID设定*)
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byCoef_Stiffen_Uw							:=	i_pstStParam_Diamonds_WrRd^.abyCoef_Stiffen_Uw[iGrp]                      		 ;								(*放料拉料系数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byCoef_Stiffen_Rw							:=	i_pstStParam_Diamonds_WrRd^.abyCoef_Stiffen_Rw[iGrp]                      		 ;								(*收料拉料系数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byInitialSpd_Stiffen_Uw					:=	i_pstStParam_Diamonds_WrRd^.abyInitialSpd_Stiffen[iGrp]                   		 ;							(*拉料初始速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byStationIdDst_VirEnc						:=	i_pstStParam_Diamonds_WrRd^.abyStationIdDst_VirEnc[iGrp]                  		 ;							(*异站编码器目标站好*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byDelayTime_DiaCompensateWhenCutDne_Uw	:=	i_pstStParam_Diamonds_WrRd^.abyDelayTime_DiaCompensateWhenCutDne_Uw[iGrp] 		 ;		  (*放料裁切延时*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byVelSa_DiamCompensate_Uw					:=	i_pstStParam_Diamonds_WrRd^.abyVelSa_DiamCompensate_Uw[iGrp]			  		 ;						(*放料补偿速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byDelayTime_DiaCompensateWhenCutDne_Rw	:=	i_pstStParam_Diamonds_WrRd^.abyDelayTime_DiaCompensateWhenCutDne_Rw[iGrp] 		 ;			(*收料裁切延时*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byVelSa_DiamCompensate_Rw					:=	i_pstStParam_Diamonds_WrRd^.abyVelSa_DiamCompensate_Rw[iGrp]			  		 ;						(*收料补偿速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].lrRatedRpm_Scraper						:=	REAL_TO_LREAL(i_pstStParam_Diamonds_WrRd^.arRatedRpm_Scraper[iGrp])				 ;				(*刮刀额定转速*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].lrRatedFreq_Scraper						:=	REAL_TO_LREAL(i_pstStParam_Diamonds_WrRd^.arRatedFreq_Scraper[iGrp])	         ;				(*刮刀额定频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].lrUpperFreq_Scraper						:=	REAL_TO_LREAL(i_pstStParam_Diamonds_WrRd^.arUpperFreq_Scraper[iGrp])             ;				(*刮刀上限频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rMinFreq_Scraper							:=	(i_pstStParam_Diamonds_WrRd^.arMinFreq_Scraper[iGrp])               ;				(*刮刀最小频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rMaxFreq_Scraper							:=	(i_pstStParam_Diamonds_WrRd^.arMaxFreq_Scraper[iGrp])               ;				(*刮刀最大频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iRatio_ScraperContrastToPrintRoller		:=	i_pstStParam_Diamonds_WrRd^.aiRatio_ScraperContrastToPrintRoller[iGrp]	  		 ;				(*刮刀调整比例*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iVelSa_ScraperRun							:=	i_pstStParam_Diamonds_WrRd^.aiVelSa_ScraperRun[iGrp]                  	  		 ;								(*刮刀启动速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iDen_ScraperMotor							:=	i_pstStParam_Diamonds_WrRd^.aiDen_ScraperMotor[iGrp]                  	  		 ;								(*刮刀减速比分母*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iNum_ScraperMotor							:=	i_pstStParam_Diamonds_WrRd^.aiNum_ScraperMotor[iGrp]                  	  		 ;								(*刮刀减速比分子*)

	i_pstStSysParam^.astStGrpParam_Save[iGrp].iPreHotRoller_Velocity_PreHot			:= 		i_pstStParam_Diamonds_WrRd^.aiPreHotRoller_Velocity_PreHot[iGrp]   					;  				(*预热辊额定转速*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rStandardFreq_HotRoller_PreHot		:= 		i_pstStParam_Diamonds_WrRd^.arStandardFreq_HotRoller_PreHot[iGrp]  						; 				(*预热辊额定频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rUpperFreq_HotRoller_PreHot			:= 		i_pstStParam_Diamonds_WrRd^.arUpperFreq_HotRoller_PreHot[iGrp]     					;    				(*预热辊上限频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rCoeff_HotRoller_PreHot				:= 		i_pstStParam_Diamonds_WrRd^.arCoeff_HotRoller_PreHot[iGrp]         					;        				(*预热辊速度系数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_HotRoller_PreHot				:= 		i_pstStParam_Diamonds_WrRd^.arGirth_HotRoller_PreHot[iGrp]         					;        				(*预热辊周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iPreAirHotRollTorque					:= 		i_pstStParam_Diamonds_WrRd^.aiPreAirHotRollTorque[iGrp]            					;           				(*预热辊转矩*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_HotRoller_PreHot				:= 		i_pstStParam_Diamonds_WrRd^.auiDen_HotRoller_PreHot[iGrp]          						;         				(*预热辊减速比分母*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_HotRoller_PreHot				:= 		i_pstStParam_Diamonds_WrRd^.auiNum_HotRoller_PreHot[iGrp]          						;         				(*预热辊减速比分子*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iPreHotRoller_Velocity_Water			:= 		i_pstStParam_Diamonds_WrRd^.aiPreHotRoller_Velocity_Water[iGrp]    					;   				(*水冷辊额定转速*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rStandardFreq_HotRoller_Water			:= 		i_pstStParam_Diamonds_WrRd^.arStandardFreq_HotRoller_Water[iGrp]   					;  				(*水冷辊额定频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rUpperFreq_HotRoller_Water			:= 		i_pstStParam_Diamonds_WrRd^.arUpperFreq_HotRoller_Water[iGrp]      						;     				(*水冷辊上限频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rCoeff_HotRoller_Water				:= 		i_pstStParam_Diamonds_WrRd^.arCoeff_HotRoller_Water[iGrp]          						;         				(*水冷辊速度系数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_HotRoller_Water				:= 		i_pstStParam_Diamonds_WrRd^.arGirth_HotRoller_Water[iGrp]          						;         				(*水冷辊周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_HotRoller_Water					:= 		i_pstStParam_Diamonds_WrRd^.auiDen_HotRoller_Water[iGrp]           					;          				(*水冷辊减速比分母*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_HotRoller_Water					:= 		i_pstStParam_Diamonds_WrRd^.auiNum_HotRoller_Water[iGrp]							;							(*水冷辊减速比分子*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iDelayMsec_ExhPowerMode				:= 		i_pstStParam_Diamonds_WrRd^.aiDelayMsec_ExhPowerMode[iGrp]		 					;						(*排风切换延时*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iDelayMsec_HeatBlower					:= 		i_pstStParam_Diamonds_WrRd^.aiDelayMsec_HeatBlower[iGrp]							;							(*热风延时*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iDelayMsec_Heat						:= 		i_pstStParam_Diamonds_WrRd^.aiDelayMsec_Heat[iGrp]				 					;								(*加热延时*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byHotBlowerStopDelayTime				:= 		i_pstStParam_Diamonds_WrRd^.abyHotBlowerStopDelayTime[iGrp]		 					;						(*热风停止延时*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byFreqMin_HotWind						:= 		i_pstStParam_Diamonds_WrRd^.abyFreqMin_HotWind[iGrp]								;								(*热风最小频率*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byFreqMax_HotWind						:= 		i_pstStParam_Diamonds_WrRd^.abyFreqMax_HotWind[iGrp]								;								(*热风最大频率*)
(*	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[1]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][1]	;			(* 标准卷径值| 双向通讯参数*)		
	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[2]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][2]	;			(* 标准卷径值| 双向通讯参数*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[3]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][3]	;			(* 标准卷径值| 双向通讯参数*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[4]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][4]	;			(* 标准卷径值| 双向通讯参数*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[1]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][1]	;			(* 标准卷径值| 双向通讯参数*)		
	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[2]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][2]	;			(* 标准卷径值| 双向通讯参数*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[3]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][3]	;			(* 标准卷径值| 双向通讯参数*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[4]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp][4]	;			(* 标准卷径值| 双向通讯参数*)	
*)	(*待补充-开始|2025.08.07.162226*)
(*	i_pstStSysParam^.astStGrpParam_Save[iGrp].rStdVol_Coef[1]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Coef[iGrp][1]	;			 (* 标准卷径系数| 双向通讯参数*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rStdVol_Coef[2]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Coef[iGrp][2]	;			 (* 标准卷径系数| 双向通讯参数*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rStdVol_Coef[3]		:= 	i_pstStParam_Diamonds_WrRd^.arStdVol_Coef[iGrp][3]	;			 (* 标准卷径系数| 双向通讯参数*)	
*)	(*待补充-结束|2025.08.07.162244*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_FilmAcc			 := 	i_pstStParam_Diamonds_WrRd^.aiTime_FilmAcc[iGrp]				;						(*预驱料膜加速时间*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_FilmDec			 := 	i_pstStParam_Diamonds_WrRd^.aiTime_FilmDec[iGrp]              	;              			(*预驱料膜减速时间*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_PreDrvAcc_Rw	 := 	i_pstStParam_Diamonds_WrRd^.aiTime_PreDrvAcc_Rw[iGrp]         	;         			  	(*收料预驱加速时间*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_PreDrvDec_Rw	 := 	i_pstStParam_Diamonds_WrRd^.aiTime_PreDrvDec_Rw[iGrp]         	;         			  	(*收料预驱减速时间*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_PreDrvAcc_Uw	 := 	i_pstStParam_Diamonds_WrRd^.aiTime_PreDrvAcc_Uw[iGrp]         	;         			  	(*放料预驱加速时间*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_PreDrvDec_Uw	 := 	i_pstStParam_Diamonds_WrRd^.aiTime_PreDrvDec_Uw[iGrp]         	;         			  	(*放料预驱减速时间*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].rFilmLen_NotAdjFront	 := 	i_pstStParam_Diamonds_WrRd^.arFilmLen_NotAdjFront[iGrp]			;					  	(*料前幅数*)		
    i_pstStSysParam^.astStGrpParam_Save[iGrp].rFilmLen_NotAdjBack	 := 	i_pstStParam_Diamonds_WrRd^.arFilmLen_NotAdjBack[iGrp]        	;        			  	(*料后幅数*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].rFilmLen_UnwindToPU1	 := 	i_pstStParam_Diamonds_WrRd^.arFilmLen_UnwindToPU1[iGrp]       	;       			   	(*裁点到1色距离*)
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiPiDelay_Uw							:=	i_pstStParam_Diamonds_WrRd^.auiPiDelay_Uw[iGrp]               		 		 ;  										(*放料接料PI投入时间*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iPreRevLenth_MM_Cutted_Uw				:=	i_pstStParam_Diamonds_WrRd^.aiPreRevLenth_MM_Cutted[iGrp]     		 		 ; 							(*裁切反转距离*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iPreRevVel_RPM_Cutted_Uw				:=	i_pstStParam_Diamonds_WrRd^.aiPreRevVel_RPM_Cutted[iGrp]      		 		 ;    							(*裁切反转速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rCoefCut_FilmVolPerimeter_Uw			:=	i_pstStParam_Diamonds_WrRd^.arCoefCut_FilmVolPerimeter_Uw[iGrp]		 		 ;       				 	(*放料裁切圈数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rCoefCut_FilmVolPerimeter_Rw			:=	i_pstStParam_Diamonds_WrRd^.arCoefCut_FilmVolPerimeter_Rw[iGrp]		 		 ;       				 	(*收料裁切圈数*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiam_Tower_Uw						:=	i_pstStParam_Diamonds_WrRd^.arDiam_Tower_Uw[iGrp]					 	 	 ;           								(*反转架直径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiam_NextRoller_Uw					:=	i_pstStParam_Diamonds_WrRd^.arDiam_NextRoller_Uw[iGrp]            	 		 ;      								(*下个辊直径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rXPos_NextRoller_Uw					:=	i_pstStParam_Diamonds_WrRd^.arXPos_NextRoller_Uw[iGrp]            	 		 ;      								(*下个辊X*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rYPos_NextRoller_Uw					:=	i_pstStParam_Diamonds_WrRd^.arYPos_NextRoller_Uw[iGrp]            	 		 ;   								(*下个辊Y*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiam_DeflectorRoller_Uw				:=	i_pstStParam_Diamonds_WrRd^.arDiam_DeflectorRoller_Uw[iGrp]       	 		 ; 								(*导向辊直径*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiam_DeflectorRollPos_Uw				:=	i_pstStParam_Diamonds_WrRd^.arDiam_DeflectorRollPos_Uw[iGrp]      	 		 ;								(*AB导向辊长度*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugVelmpm_AxisA_Uw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugVelmpm_AxisA_Uw[iGrp]			 		 ;    								(*放料A轴调试速度*)		
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugGirthmm_AxisA_Uw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugGirthmm_AxisA_Uw[iGrp]			 		 ;    								(*放料A轴调试速度*)		
//	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisA_Uw				:=	i_pstStParam_Diamonds_WrRd^.arDebugCurVelmpmAxisA_Uw[iGrp]    		 		 ;  								(*放料A轴调试周长*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugVelmpm_AxisB_Uw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugVelmpm_AxisB_Uw[iGrp]			 		 ;    								(*放料A轴调试速度*)		
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugGirthmm_AxisB_Uw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugGirthmm_AxisB_Uw[iGrp]			 		 ;    								(*放料A轴调试速度*)		
//	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisB_Uw				:=	i_pstStParam_Diamonds_WrRd^.arDebugCurVelmpmAxisB_Uw[iGrp]    		 		 ;								(*放料A轴调试周长*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugVelmpm_AxisA_Rw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugVelmpm_AxisA_Rw[iGrp]			 		 ;									(*放料A轴调试速度*)		
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugGirthmm_AxisA_Rw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugGirthmm_AxisA_Rw[iGrp]			 		 ;    								(*放料A轴调试速度*)		
//	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisA_Rw				:=	i_pstStParam_Diamonds_WrRd^.arDebugCurVelmpmAxisA_Rw[iGrp]    		 		 ;								(*放料A轴调试周长*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugVelmpm_AxisB_Rw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugVelmpm_AxisB_Rw[iGrp]			 		 ;									(*放料A轴调试速度*)		
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iDebugGirthmm_AxisB_Rw					:=	i_pstStParam_Diamonds_WrRd^.aiDebugGirthmm_AxisB_Rw[iGrp]			 		 ;    								(*放料A轴调试速度*)		
//	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisB_Rw				:=	i_pstStParam_Diamonds_WrRd^.arDebugCurVelmpmAxisB_Rw[iGrp]    		 		 ;								(*放料A轴调试周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Ink								:=	i_pstStParam_Diamonds_WrRd^.arVel_Ink[iGrp]							 		 ;				 								(*空转速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Inch								:=	i_pstStParam_Diamonds_WrRd^.arVel_Inch[iGrp]                      	 		 ;				 								(*单运行速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byDelayTime_PressDneInPrint_If		:=	i_pstStParam_Diamonds_WrRd^.abyDelayTime_PressDneInPrint_If[iGrp] 	 	 	 ;		 				(*放牵压辊延时*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Max								:=	i_pstStParam_Diamonds_WrRd^.arVel_Max[iGrp]                       	 		 ;		 										(*最大速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byMeters_UseFollow_1U_V_UwCut			:=	i_pstStParam_Diamonds_WrRd^.abyMeters_UseFollow_1U_V_UwCut[iGrp]	 		 ;		 					(*有效距离*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_If								:=	i_pstStParam_Diamonds_WrRd^.arGirth_If[iGrp]                    	 		 ;		 										(*放牵辊周长*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_Of								:=	i_pstStParam_Diamonds_WrRd^.arGirth_Of[iGrp]                    	 		 ;				 								(*收牵辊周长*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iDelayMsec_RollerPress				:=	i_pstStParam_Diamonds_WrRd^.aiDelayMsec_RollerPress[iGrp]       	 	 	 ;								(*合压时间*)	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_S								:=	i_pstStParam_Diamonds_WrRd^.aiTime_S[iGrp]                      	 		 ;												(*S加速时间*)	
    i_pstStSysParam^.astStGrpParam_Save[iGrp].iTime_S_End							:=	i_pstStParam_Diamonds_WrRd^.aiTime_S_End[iGrp]                  	 		 ;											(*S减速时间*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].byAxisInitPhaseTypeWhenPreRegister	:=	i_pstStParam_Diamonds_WrRd^.abyAxisInitPhaseTypeWhenPreRegister[iGrp] 	 	 ;              		(*预套准初始位置*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].byVelLimit_PerCent_IfOf				:=	i_pstStParam_Diamonds_WrRd^.abyVelLimit_PerCent_IfOf[iGrp]            		 ;         						(*牵引调制限制值*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_ManuAdj_Corse					:=	i_pstStParam_Diamonds_WrRd^.arVel_ManuAdjust[iGrp]                    	 	 ;         							(*手动粗调速度*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_AutoAdj							:=	i_pstStParam_Diamonds_WrRd^.arVel_AutoAdjust[iGrp]                    		 ;         									(*自动调整速度*)
    i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_RapidAdj							:=	i_pstStParam_Diamonds_WrRd^.arVel_RapidAdjust[iGrp]                   		 ;         								(*快速对版速度*)
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rAdjVal_PerTime_Fine			:=	i_pstStParam_Diamonds_WrRd^.arAdjVal_PerTime_Fine[iGrp]   		 	;											(*手动细调调整量*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rAdjVal_PerTime_Coarse		:=	i_pstStParam_Diamonds_WrRd^.arAdjVal_PerTime_Coarse[iGrp] 		 	;										(*手动粗调调整量*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_HorzdAdj					:=	i_pstStParam_Diamonds_WrRd^.arVel_HorzAdjust[iGrp]        		 	;													(*横向调整速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_HorzPreRegister			:=	i_pstStParam_Diamonds_WrRd^.arVel_HorzPreRegister[iGrp]   		 	;											(*横向预套准速度*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_If						:=	i_pstStParam_Diamonds_WrRd^.auiNum_If[iGrp]               		 	;														(*放牵减速比-电机侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_If						:=	i_pstStParam_Diamonds_WrRd^.auiDen_If[iGrp]               		 	;														(*放牵减速比-传动侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_Of						:=	i_pstStParam_Diamonds_WrRd^.auiNum_Of[iGrp]               		 	;														(*收牵减速比-电机侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_Of						:=	i_pstStParam_Diamonds_WrRd^.auiDen_Of[iGrp]               		 	;														(*收牵减速比-传动侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_Uw						:=	i_pstStParam_Diamonds_WrRd^.auiNum_Uw[iGrp]               		 	;														(*放料减速比-电机侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_Uw						:=	i_pstStParam_Diamonds_WrRd^.auiDen_Uw[iGrp]               		 	;														(*放料减速比-传动侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_Rw						:=	i_pstStParam_Diamonds_WrRd^.auiNum_Rw[iGrp]               		 	;														(*收料减速比-电机侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_Rw						:=	i_pstStParam_Diamonds_WrRd^.auiDen_Rw[iGrp]               		 	;														(*收料减速比-传动侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_PrnRoller				:=	i_pstStParam_Diamonds_WrRd^.auiNum_Pu[iGrp]               		 	;												(*色组减速比-电机侧*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_PrnRoller				:=	i_pstStParam_Diamonds_WrRd^.auiDen_Pu[iGrp]               		 	;												(*色组减速比-传动侧*)	
	(*待补充-开始|2025.08.07.202603*)	                                        
(*	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[1]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][1]		 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[2]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][2]		 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[3]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][3]		 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[4]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][4]		 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[5]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][5]		 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[6]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][6]		 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[7]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][7]		 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestDO_Main[8]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestDO_Main[iGrp][8]		 	;										(*主面板IO测试输出*)
																            
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[1]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][1]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[2]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][2]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[3]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][3]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[4]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][4]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[5]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][5]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[6]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][6]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[7]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][7]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[8]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][8]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[9]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][9]		 	;									(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[10]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][10]	 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[11]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][11]	 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[12]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][12]	 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[13]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][13]	 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[14]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][14]	 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[15]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][15]	 	;										(*主面板IO测试输出*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wOutput_IOtestAO_Main[16]		:=	i_pstStParam_Diamonds_WrRd^.awOutput_IOtestAO_Main[iGrp][16]	 	;										(*主面板IO测试输出*)
*)	(*待补充-结束|2025.08.07.202615*)
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiPreStopDelayTime_ms		:= 	i_pstStParam_Diamonds_WrRd^.auiPreStopDelayTime_ms[iGrp]    	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_Tar_9905				:= 	i_pstStParam_Diamonds_WrRd^.arVel_Tar_9905[iGrp]            	;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iAxisId_StepTest_V		:= 	i_pstStParam_Diamonds_WrRd^.aiAxisId_StepTest_V[iGrp]       	;
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iInterval_StepTest12		:= 	i_pstStParam_Diamonds_WrRd^.aiInterval_StepTest12[iGrp]     	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iMicron_StepTest1_V		:= 	i_pstStParam_Diamonds_WrRd^.aiMicron_StepTest1_V[iGrp]      	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iMicron_StepTest2_V		:= 	i_pstStParam_Diamonds_WrRd^.aiMicron_StepTest2_V[iGrp]      	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byKalmanFilterType_Rw		:= 	i_pstStParam_Diamonds_WrRd^.abyKalmanFilterType_Rw[iGrp]    	;
	IF i_pstStParam_Diamonds_WrRd^.abyStructParanInitEn_Rw[iGrp]<>0 THEN
		i_pstStSysParam^.astStGrpParam_Save[iGrp].byStructParanInitEn_Rw 	:= 	i_pstStParam_Diamonds_WrRd^.abyStructParanInitEn_Rw[iGrp]   	;
	END_IF
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rR_K_MinBeat_Rw	    	:= 	i_pstStParam_Diamonds_WrRd^.arR_K_MinBeat_Rw[iGrp]          	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iN_MinBeat_Rw	        	:= 	i_pstStParam_Diamonds_WrRd^.aiN_MinBeat_Rw[iGrp]            	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rR_K_LQR_Rw	        	:= 	i_pstStParam_Diamonds_WrRd^.arR_K_LQR_Rw[iGrp]              	;
	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rN_LQR_Rw	            		:= i_pstStParam_Diamonds_WrRd^.arN_LQR_Rw[iGrp]	               		;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rKc_Rw	            		:= i_pstStParam_Diamonds_WrRd^.arKc_Rw[iGrp]	                   	;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rKc_Rw_AccDec	        		:= i_pstStParam_Diamonds_WrRd^.arKc_Rw_AccDec[iGrp]	           		;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rWc_LowPass_Diam_Rw			:= i_pstStParam_Diamonds_WrRd^.arWc_LowPass_Diam_Rw[iGrp]	   		;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byKalmanFilterType_Uw 		:= i_pstStParam_Diamonds_WrRd^.abyKalmanFilterType_Uw[iGrp] 	   	;
	IF i_pstStParam_Diamonds_WrRd^.abyStructParanInitEn_Uw[iGrp]<>0 THEN
		i_pstStSysParam^.astStGrpParam_Save[iGrp].byStructParanInitEn_Uw		:= i_pstStParam_Diamonds_WrRd^.abyStructParanInitEn_Uw[iGrp]	   	;
	END_IF
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stModelParam_Uw),
		ADR(i_pstStParam_Diamonds_WrRd^.astModelParam_Uw[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stModelParam_Uw));
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stInvariant_Parameters_Uw),
		ADR(i_pstStParam_Diamonds_WrRd^.astInvariant_Parameters_Uw[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stInvariant_Parameters_Uw));
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Uw),
		ADR(i_pstStParam_Diamonds_WrRd^.astPI_Parameters_Uw[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Uw));
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Uw_AccDec),
		ADR(i_pstStParam_Diamonds_WrRd^.astPI_Parameters_Uw_AccDec[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Uw_AccDec));
		
		
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stModelParam_Rw),
		ADR(i_pstStParam_Diamonds_WrRd^.astModelParam_Rw[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stModelParam_Rw));
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stInvariant_Parameters_Rw),
		ADR(i_pstStParam_Diamonds_WrRd^.astInvariant_Parameters_Rw[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stInvariant_Parameters_Rw));
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Rw),
		ADR(i_pstStParam_Diamonds_WrRd^.astPI_Parameters_Rw[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Rw));
	SysMemCpy(
		ADR(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Rw_AccDec),
		ADR(i_pstStParam_Diamonds_WrRd^.astPI_Parameters_Rw_AccDec[iGrp]),
		SIZEOF(i_pstStSysParam^.astStGrpParam_Save[iGrp].stPI_Parameters_Rw_AccDec));
		
		
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rR_K_MinBeat_Uw    			:= i_pstStParam_Diamonds_WrRd^.arR_K_MinBeat_Uw[iGrp]    			;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iN_MinBeat_Uw      			:= i_pstStParam_Diamonds_WrRd^.aiN_MinBeat_Uw[iGrp]      			;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rR_K_LQR_Uw        			:= i_pstStParam_Diamonds_WrRd^.arR_K_LQR_Uw[iGrp]        			;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rN_LQR_Uw          			:= i_pstStParam_Diamonds_WrRd^.arN_LQR_Uw[iGrp]          			;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rKc_Uw             			:= i_pstStParam_Diamonds_WrRd^.arKc_Uw[iGrp]             			;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rKc_Uw_AccDec      			:= i_pstStParam_Diamonds_WrRd^.arKc_Uw_AccDec[iGrp]      			;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rWc_LowPass_Diam_Uw			:= i_pstStParam_Diamonds_WrRd^.arWc_LowPass_Diam_Uw[iGrp]			;
				                                                            
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rWn_Uw         				:= i_pstStParam_Diamonds_WrRd^.arWn_Uw[iGrp]         	      		;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rBw_Uw         				:= i_pstStParam_Diamonds_WrRd^.arBw_Uw[iGrp]         	      		;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rDp_Uw         				:= i_pstStParam_Diamonds_WrRd^.arDp_Uw[iGrp]         	      		;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iWorkMode_Pid					:= i_pstStParam_Diamonds_WrRd^.aiWorkMode_Pid[iGrp]		  			;
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rFilmLenth_InUnit  			:= i_pstStParam_Diamonds_WrRd^.arFilmLenth_InUnit[iGrp]	   			;
	











	(*增加裁切时间集处理2025.9.11.193948*)	
	//2026.05.20.214715 替换为直接赋值 by liu.yt	
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi:=i_pstStParam_Diamonds_WrRd^.astStTimeSet_DnCut_UpCut_Uw_Hmi[iGrp];
	//2026.05.21.085510 补充收料
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].stStTimeSet_DnCut_UpCut_RW_Hmi:=i_pstStParam_Diamonds_WrRd^.astStTimeSet_DnCut_UpCut_Rw_Hmi[iGrp];

	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_Uw:= i_pstStParam_Diamonds_WrRd^.abyAIType_Uw[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_Rw:= i_pstStParam_Diamonds_WrRd^.abyAIType_Rw[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_If:= i_pstStParam_Diamonds_WrRd^.abyAIType_If[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_Of:= i_pstStParam_Diamonds_WrRd^.abyAIType_Of[iGrp];
(*2025.10.24.134439||增加变量*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAlarmHold_PreCut_Uw:= i_pstStParam_Diamonds_WrRd^.abyAlarmHold_PreCut_Uw[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byFilmType:= i_pstStParam_Diamonds_WrRd^.abyFilmType[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiUseTime_Diam_Min_Uw:= i_pstStParam_Diamonds_WrRd^.auiUseTime_Diam_Min_Uw[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiUseTime_Diam_Min_Rw:= i_pstStParam_Diamonds_WrRd^.auiUseTime_Diam_Min_Rw[iGrp];
	
(*2025.11.5.154653*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iUpperFreq_InkRoller:= i_pstStParam_Diamonds_WrRd^.aiUpperFreq_InkRoller[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iVelSa_InkRollerRun:= i_pstStParam_Diamonds_WrRd^.aiVelSa_InkRollerRun[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iFrq_InkRollerMin:= i_pstStParam_Diamonds_WrRd^.aiFrq_InkRollerMin[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iFrq_InkRollerMax:= i_pstStParam_Diamonds_WrRd^.aiFrq_InkRollerMax[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iVel_InkRollerMin:= i_pstStParam_Diamonds_WrRd^.aiVel_InkRollerMin[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].iVel_InkRollerMax:= i_pstStParam_Diamonds_WrRd^.aiVel_InkRollerMax[iGrp];
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].byPseudoRandomId:= i_pstStParam_Diamonds_WrRd^.abyPseudoRandomId[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rHz_PreHotAir_ManuallySet:= i_pstStParam_Diamonds_WrRd^.arHz_PreHotAir_ManuallySet[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rSV_PreHeating:= i_pstStParam_Diamonds_WrRd^.arSV_PreHeating[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rHz_Scraper_ManuallySet:= i_pstStParam_Diamonds_WrRd^.arHz_Scraper_ManuallySet[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rCoeff_Scraper_Auto:= i_pstStParam_Diamonds_WrRd^.arCoeff_Scraper_Auto[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rHz_InkRoller_ManuallySet:= i_pstStParam_Diamonds_WrRd^.arHz_InkRoller_ManuallySet[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rCoeff_InkRoller:= i_pstStParam_Diamonds_WrRd^.arCoeff_InkRoller_Auto[iGrp];
//2026.1.6.095943增加一些变量
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rLength_Band_Confirm:= i_pstStParam_Diamonds_WrRd^.arLength_Band_Confirm[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rPressure_Tar:= i_pstStParam_Diamonds_WrRd^.arPressure_Tar[iGrp];
// 	xSwitch_TensionAdjust_QH					: BIT;
// 	xSwitch_PrnLenAdj_Follow_QH					: BIT;	
	i_pstStSysParam^.stStSysParam_Save.dwCtlSwitchRef.3:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_TensionAdjust_QH;
	i_pstStSysParam^.stStSysParam_Save.dwCtlSwitchRef.2:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_PrnLenAdj_Follow_QH;	

	//2026.2.2.165944||新增界面的一些内容|Niu/j
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rScrewPitch_PrnRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.arScrewPitch_PrnRoller_Pressure[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_PrnRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.auiNum_PrnRoller_Pressure[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_PrnRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.auiDen_PrnRoller_Pressure[iGrp];
					
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rScrewPitch_NetRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.arScrewPitch_NetRoller_Pressure[iGrp];	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_NetRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.auiNum_NetRoller_Pressure[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_NetRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.auiDen_NetRoller_Pressure[iGrp];
					
	i_pstStSysParam^.astStGrpParam_Save[iGrp].rScrewPitch_StrRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.arScrewPitch_StrRoller_Pressure[iGrp];	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_StrRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.auiNum_StrRoller_Pressure[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_StrRoller_Pressure:=
					i_pstStParam_Diamonds_WrRd^.auiDen_StrRoller_Pressure[iGrp];

	i_pstStSysParam^.astStGrpParam_Save[iGrp].rScrewPitch_Horz:=
					i_pstStParam_Diamonds_WrRd^.arScrewPitch_Horz[iGrp];	
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_Horz:=
					i_pstStParam_Diamonds_WrRd^.auiNum_Horz[iGrp];
	i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_Horz:=
					i_pstStParam_Diamonds_WrRd^.auiDen_Horz[iGrp];
				
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rVel_UVstartVel:= i_pstStParam_Diamonds_WrRd^.arVel_UVstartVel[iGrp];	
	
	//2026.02.28.144731 | + | 上下裁切换
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_Change_CutterOnTop_HMI_Uw:=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Change_CutterOnTop_HMI_Uw;(*上下裁切换*)
	i_pstStSysParam^.astStGrpParam_Save[iGrp].xSwitch_Change_CutterOnTop_HMI_Rw:=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_Change_CutterOnTop_HMI_Rw;(*上下裁切换*)
	
	//2026.03.11.100402 | + | 使用Bit22作为压力电机自动合压开关
	i_pstStSysParam^.astStGrpParam_Save[iGrp].wCtl_Pressure_Up_Dn.0:=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_PressureAuto_Up_Dn;

	//2026.03.11.114928 | + | 使用Bit24作为停机维持使能的开关
	i_pstStSysParam^.astStGrpParam_Save[iGrp].dwExtBitCtlFlag.21 :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_KeepServoOn;

	//2026.02.25.100358 | + | 使用Bit23作为控制天枢存储数据的开关
	i_pstStSysParam^.astStGrpParam_Save[iGrp].dwExtBitCtlFlag.22 :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_SaveData_GNS;

	//2026.03.27.175514 | + | 给超旭同步秦华的金刚清除报警功能    2026.1.27.141112 | + | 增加清除报警的功能
	IF 	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_ClearSysAlarm THEN
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_ClearSysAlarm := FALSE;
		g_xClrAlr_HMI := TRUE;
	END_IF
	//2026.04.01.165429 增加总匀墨 Hou.N
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xSwitch_GrpInkEn :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_GrpInkEn;
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ChangeFilmDn_Uw THEN
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCurAxisDia_Uw_Wr:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ChangeFilmDn_Uw;
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ChangeFilmDn_Uw:= FALSE;
	END_IF
	IF i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ChangeFilmDn_Rw THEN
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCurAxisDia_Rw_Wr:= i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ChangeFilmDn_Rw;
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ChangeFilmDn_Rw:= FALSE;
	END_IF	
//2026.5.9.172241
	//增加全自动套印相关变量的通讯；2026.4.6.112942|niu.j
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xStartAutoFind:= 
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_StartAutoFind;
//2026.04.06.141649最终需要放开
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].xSwitch_EnFastPress:=
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_EnFastPress;
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xSwitch_SaveRS2file:=
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_SaveRS2file;
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xSwitch_RFailure:=	
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_RFailure;
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xSwitch_FFailure:=
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_FFailure;
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rWidth_Mark_Max:=
			i_pstStParam_Diamonds_WrRd^.arWidth_Mark_Max[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rWidth_Mark_Min:=
			i_pstStParam_Diamonds_WrRd^.arWidth_Mark_Min[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rMaxGap:=
			i_pstStParam_Diamonds_WrRd^.arMaxGap[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].bySimilarityThreshold:=
			REAL_TO_BYTE(i_pstStParam_Diamonds_WrRd^.arSimilarityThreshold[iGrp]);
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].byMeanOffset:=
			i_pstStParam_Diamonds_WrRd^.abyMeanOffset[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].bySignalType:=
			i_pstStParam_Diamonds_WrRd^.abySignalType[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rOuterCoff:=
			i_pstStParam_Diamonds_WrRd^.arOuterCoff[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rInnerCoff:=
			i_pstStParam_Diamonds_WrRd^.arInnerCoff[iGrp];
	FOR iN:=1 TO 15 BY 1 DO
		IF iN<=2 THEN
			i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].arFiberMove[iN]:=
						i_pstStParam_Diamonds_WrRd^.arFiberMove[iGrp,iN];
		END_IF
		i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].arModeMsg[iN]:=
					i_pstStParam_Diamonds_WrRd^.arModeMsg[iGrp,iN];		
	END_FOR		


	//2026.04.10.110541 增加伪随机pid按钮处理
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].bySetTestPid_Uw:=i_pstStParam_Diamonds_WrRd^.abySetTestPid_Uw[iGrp];
	
	
//2026.4.10.092048增加界面计米清零计数
	IF abyPreCount_ClrPrn[iGrp,1]= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[1] THEN
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[1]:= i_pstStParam_Diamonds_WrRd^.abyClrPrnLenCount[iGrp,1];
	END_IF
	abyPreCount_ClrPrn[iGrp,1]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[1];
	
	IF abyPreCount_ClrPrn[iGrp,2]= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[2] THEN
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[2]:= i_pstStParam_Diamonds_WrRd^.abyClrPrnLenCount[iGrp,2];
	END_IF
	abyPreCount_ClrPrn[iGrp,2]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[2];
	
	IF abyPreCount_ClrPrn[iGrp,3]= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[3] THEN
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[3]:= i_pstStParam_Diamonds_WrRd^.abyClrPrnLenCount[iGrp,3];
	END_IF	
	abyPreCount_ClrPrn[iGrp,3]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].abyClrPrnLenCount_Rw[3];
//增加完成2026.4.10.092101
	
//2026.5.12.161016增加速度规划方式的通讯
	i_pstStSysParam^.astStGrpParam_Save[iGrp].byAutoAccDecCurve:= i_pstStParam_Diamonds_WrRd^.abyAutoAccDecCurve[iGrp];
	//2026.05.14.151130 新增自动停机、网辊离压速度
    i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rRemainDia_stop := i_pstStParam_Diamonds_WrRd^.arRemainDia_stop[iGrp];
    i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rMaxErr_GantryTrap := i_pstStParam_Diamonds_WrRd^.arMaxErr_GantryTrap[iGrp];
    i_pstStSysParam^.astStGrpParam_Save[iGrp].rVel_NetReturn := i_pstStParam_Diamonds_WrRd^.arVel_NetReturn[iGrp];
   	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].xIsAutoStop :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_En_AutoStop;
	//2026.05.15.85606 新增电晕启动速度
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].rVel_CoronaVel:= i_pstStParam_Diamonds_WrRd^.arVel_CoronaVel[iGrp];	
	(*2026.05.26.155252+*)
	i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAutoAccDec_Hmi:=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xAutoAccDec_Hmi;
	
	//2026.05.24.135821 光纤行走部分
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].iFiberMoveVel:=i_pstStParam_Diamonds_WrRd^.aiFiberMoveVel[iGrp];	
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].rFiberMoveDistance_AllUnit:=i_pstStParam_Diamonds_WrRd^.arFiberMoveDistance_AllUnit[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].byFiberMove_MicroMoveStep:=i_pstStParam_Diamonds_WrRd^.abyFiberMove_MicroMoveStep[iGrp];
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xFiberMove_DebugMode :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xFiberMove_DebugMode;
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xFiberMoveDisRunStart_AllUnit :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xFiberMoveDisRunStart_AllUnit;
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].xUseOnline_FiberMove :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xUseOnline_FiberMove;
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xFiberMoveConfirm_AllUnit :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xFiberMoveConfirm_AllUnit;
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xFiberMovePosCal_ByUnit :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xFiberMovePosCal_ByUnit;
	i_pstStSysParam^.astStRSV_GrpParam_UnSave[iGrp].xFiberMovePosCal_ByOnline :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xFiberMovePosCal_ByOnline;
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].xFiberMove_Negative_AdjustByUnit :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xFiberMove_Negative_AdjustByUnit;
	i_pstStSysParam^.astStRSV_GrpParam_Save[iGrp].xFiberMove_Negative_AdjustByOnline :=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xFiberMove_Negative_AdjustByOnline;

//2026.5.15.112026增加卷径检测变量输入
	FOR iK:=1 TO 4 BY 1 DO
		IF arStdVol_Coef_Axis_Hmi_Bak[iGrp,iK]= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Coef_Axis_Hmi[iK] THEN
			i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Coef_Axis_Hmi[iK]:= i_pstStParam_Diamonds_WrRd^.arStdVol_Coef_Axis_Hmi[iGrp,iK];
		END_IF
		arStdVol_Coef_Axis_Hmi_Bak[iGrp,iK]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Coef_Axis_Hmi[iK];
		IF arStdVol_Diam_Axis_Hmi_Bak[iGrp,iK]= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Diam_Axis_Hmi[iK] THEN
			i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Diam_Axis_Hmi[iK]:=i_pstStParam_Diamonds_WrRd^.arStdVol_Diam_Axis_Hmi[iGrp,iK];
		END_IF
		arStdVol_Diam_Axis_Hmi_Bak[iGrp,iK]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Diam_Axis_Hmi[iK];
		IF arStdVol_Volt_Axis_Hmi_Bak[iGrp,iK]= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Volt_Axis_Hmi[iK] THEN
			i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Volt_Axis_Hmi[iK]:= i_pstStParam_Diamonds_WrRd^.arStdVol_Volt_Axis_Hmi[iGrp,iK];
		END_IF
		arStdVol_Volt_Axis_Hmi_Bak[iGrp,iK]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Volt_Axis_Hmi[iK];
	END_FOR
	IF arStdVol_Coef_Axis_Hmi_Bak[iGrp,0]= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Coef_Axis_Hmi[0] THEN
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Coef_Axis_Hmi[0]:= i_pstStParam_Diamonds_WrRd^.arStdVol_Coef_Axis_Hmi[iGrp,0];
	END_IF
	arStdVol_Coef_Axis_Hmi_Bak[iGrp,0]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].alrStdVol_Coef_Axis_Hmi[0];
END_FOR	
(*轴参数|2025.08.07.101610*)
FOR iUnitId:= 1 TO MAX_UNIT_NUM BY 1 DO	
	//2026.04.03.115045
	IF axSwitch_AutoAdjust_V_Unit[iUnitId]= i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Sts.0 THEN
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Sts.0 	:=		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_AutoAdjust_V_Unit			 ;			(*整机纵向自动调整开关*)
	END_IF
	axSwitch_AutoAdjust_V_Unit[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Sts.0;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Sts.1 	:=		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_AutoAdjust_H_Unit			 ;			(*整机纵向自动调整开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xEnable_arc 	:=		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_ThisUnitEna ;			(*色组套印开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.0:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Horz ;(*横向开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.1:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_DoorBaseLn	 ;(*门内基线开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.4:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_AdjRev_V ;(*横向调整反*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.5:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_AdjRev_H ;(*横向调整反*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byCouplingMask.2:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Transfer_Err ;(*误差传递开关*)
//	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byCouplingMask.0:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Transfer_Adj ;(*调整量传递开关*)
(*小信号2025.10.27.141809*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.13:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_SmallSignalProcessing_T1;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.14:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_SmallSignalProcessing_T2;

(*2025.11.12.111108*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_ScraperAuto:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_ScraperAuto ;(*刮刀手自动*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_ScraperOn := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_ScraperOn	;(*刮刀开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_InkRollerAuto:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_InkRollerAuto ;(*递墨辊手自动*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_InkRollerCW := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_InkRollerCW;(*递墨辊正转*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_InkRollerCCW:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_InkRollerCCW ;(*递墨辊反转*)

(*2025.11.5.163824*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitchOn_CoatingPrn:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_CoatingPrn;(*色组涂布开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xReverseAdj_CoatingPrn:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_CoatingRec;(*涂布调整反向*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_HotWindOn:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_HotWindOn;(*热风开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_Heating_I:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Heating_I;(*加热I档*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_Heating_II:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Heating_II	;(*加热II档*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_Heating_III:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Heating_III;(*加热III档*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.7:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_AdjRev_O;(*单标记调整反*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Sts.8:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Follow_1U_V_Unit;(*纵向跟1色开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Sts.9 				:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Follow_1U_H_Unit;(*横向跟1色开关*)	
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.9 				:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_DualPolarity	;(*双极性开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.8 				:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_UnitRevPrn		;(*色组反印开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.6 				:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_DualGate		;(*双波门开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byCouplingMask.2 			:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Transfer_Err	;(*误差传递开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byCouplingMask.0 			:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Transfer_Adj	;(*调整量传递开关*)
//2026.5.12.163836增加小信号处理
//小信号 2026.05.11.191235
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.13:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_SmallSignalProcessing_T1	;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.14:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_SmallSignalProcessing_T2	;
	
//2026.5.11.172229+反极性值界面修改未赋值
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.2 :=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_NegativePolarity_T1_1	;(*第一组波门内T1信号反极性*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.3 :=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_NegativePolarity_T2_1	;(*第一组波门内T2信号反极性*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.11:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_NegativePolarity_T1_2	;(*第二组波门内T1信号反极性*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.12:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_NegativePolarity_T2_2	;(*第二组波门内T2信号反极性*)
//2026.5.12.163844

	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_HeatingMode_Water := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Heating_Water	;(*水加热控制开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_HeatingMode_Ele 	:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Heating_Elc	;(*电加热控制开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_ExhAir 			:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_ExhAir			;(*色组排风开关*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].stStArc_Mol_Param.xCompensateEn_H 	:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xCompensateEn_H	;		
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].stStArc_Mol_Param.xUseAntiNotch_Arc 	:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xUseAntiNotch_Arc  ;						
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].stStArc_Mol_Param.xUsePeriodic 		:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xUsePeriodic    	;   						


	
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].lrGirth_Using_CoatingPrn 			:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rGirth_Using_CoatingPrn			 ;  		(*涂布周长*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byAdjMode_CoatingPrn 				:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byBtn_AdjModeSwitch_CoatingPrn		 ;      	(*涂布调整方式切换按钮*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rStep_OfChangeGirth 				:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rStep_OfChangeGirth				 ;  		(*涂布版轴修改步幅*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitScraper_ManuallySet 		:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rHz_UnitScraper_ManuallySet		 ;  		(*刮刀手动频率*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rCoeff_UnitScraper_Auto 			:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rCoeff_UnitScraper_Auto			 ;  		(*刮刀自动系数*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitInkRoller_ManuallySet 	:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rHz_UnitInkRoller_ManuallySet		 ;			(*递墨辊手动频率*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rCoeff_UnitInkRoller_Auto 		:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rCoeff_UnitInkRoller_Auto			 ;    		(*递墨辊自动系数*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitHotWind_ManuallySet 		:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rHz_UnitHotWind_ManuallySet		 ;  		(*热风手动频率*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rSV_UnitTemCtl 					:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rSV_UnitTemCtl						 ;      	(*加热设定温度*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateWidthPhy 					:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].iGateWidthPhy						 ;      	(*波门宽度*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAlr_V 							:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rAlarm_V							 ;      	(*纵向报警值*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAlr_H 							:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rAlarm_H							 ;      	(*横向报警值*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAdj_V 							:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rAdjust_V							 ;      	(*纵向修正量*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAdj_H 							:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rAdjust_H							 ;      	(*横向修正量*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rDeadzoneMax_H 					:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rDeadzoneMax_H						 ;      	(*横向最大不动作区*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rDeadzoneMin_H 					:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rDeadzoneMin_H						 ;      	(*横向最小不动作区*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].iCoefOfCoupling_V 				:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].iCoefOfCoupling_V					 ;      	(*纵向传递2系数*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byAvg_V 							:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAverage_V						 ;  		(*纵向平均值*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byAvg_H 							:=	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAverage_H						 ;  		(*横向平均值*)
	(*待补充-开始|2025.08.07.204217*)
	(*待补充-结束|2025.08.07.204230*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiTimeMs_RollerPressUpKeep 	:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiTimeMs_RollerPressUpKeep			;       (*压辊双气缸-离压保持时间*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller 				:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiAxisNum							;      			(*色组单独减速比分子*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller 				:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiAxisDen							;     				(*色组单独减速比分母*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitExhaust_ManuallySet 	:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rHz_UnitExhaust_ManuallySet		;  	(*色组排风设定频率*)
	//9905界面内容	
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAxisVelPrf_Coeff1 			:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rAxisVelPrf_Coeff1						;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAxisVelPrf_Coeff2 			:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rAxisVelPrf_Coeff2             		;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAxisVelPrf_Coeff3 			:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rAxisVelPrf_Coeff3             		;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].stStArc_Mol_Param.rMargin_Mag_Arc 				:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rMargin_Mag_Arc                		;
//	//2026.05.13.091849+变量替换
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].stStArc_Mol_Param.rKadj_I_Mol 	:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rKadj_I_Mol                		;
//	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rMargin_Phi_Arc 				:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rMargin_Phi_Arc                		;
//这两个变量放只写区域，不需要双向2026.4.25.142438
//	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rKp_MolCal 					:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rKp_MolCal                     		;
//	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rKi_MolCal 					:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rKi_MolCal                     		;
//2026.4.25.142452结束
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rFilmLengthFromPrevPressUnit 	:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rFilmLengthFromPrevPressUnit   		;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byCompensateValue_Hor 		:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byCompensateValue_Hor					;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byMaxAddValue_Total_Hor 		:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byMaxAddValue_Total_Hor				;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rWn_Arc 						:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rWn_Arc								;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rBw_Arc 						:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rBw_Arc								;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rDp_Arc 						:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rDp_Arc								;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rK 							:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rK     								;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rA2 							:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rA2    								;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rA1 							:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rA1    								;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rA0 							:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rA0    								;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rG_Periodic 					:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rG_Periodic  							;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rW_Periodic 					:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rW_Periodic  							;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byCnt_Comm2ARM 				:= 	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byCnt_Comm2ARM							;

(*2025.8.25.151756|、niu.j||波门位置*)
(*2025.8.25.151756|、niu.j||波门位置*)
	//2026.04.03.115113
	IF aiGateSa_Pre_GNS[iUnitId]=i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateSa THEN
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateSa:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].iGateSa	;
	END_IF
	aiGateSa_Pre_GNS[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateSa;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateSaEx:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].iGateSaEx	;
(*2025.9.19.124046*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].iMarkArrangeMode:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].iMarkArrangeMode;
(*横向手动调整按钮2025.9.20.111304*)
	g_abyHorzManu_HMI[iUnitId].0 := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_HorzMoveLeft_Manu_1;
	g_abyHorzManu_HMI[iUnitId].4 := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_HorzMoveLeft_Manu_2;
	g_abyHorzManu_HMI[iUnitId].1 := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_HorzMoveLeft_Manu_3;
	g_abyHorzManu_HMI[iUnitId].2 := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_HorzMoveRight_Manu_1;
	g_abyHorzManu_HMI[iUnitId].5 := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_HorzMoveRight_Manu_2;
	g_abyHorzManu_HMI[iUnitId].3 := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_HorzMoveRight_Manu_3;
		
(*2025.11.5.165752*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].lrPreReg_Adjust:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rPreReg_Adjust;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].lrPreReg_ConstVal:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rPreReg_ConstVal;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiTurnOverFilmLenth:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiTurnOverFilmLenth;
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].diPreReg_RepeatVal_H:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].diPreReg_RepeatVal_H;
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].diPreReg_SetupVal_H:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].diPreReg_SetupVal_H;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].diPreReg_AdjustVal_H:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].diPreReg_AdjustVal_H;
	
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rGirth_PrnRoller;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byAirInletWindDoorValue:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAirInletWindDoorValue;
//	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byOvensAirOutWindDoorValue:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAirInletWindDoorValue;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].wAirReturnWindDoorValue:= BYTE_TO_WORD(i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAirReturnWindDoorValue);
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].wAirExhaustWindDoorValue:= BYTE_TO_WORD(i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAirExhaustWindDoorValue);
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byOvensAirOutWindDoorValue        := i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAirInletWindDoorValue;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byFakeThreshold_V:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byFakeThreshold_V;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byFakeThreshold_H:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byFakeThreshold_H;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].byAve_v_extra:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byAve_v_extra;

//2026.1.6.095943增加一些变量
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].iBandLengthFilterCnt:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].iBandLengthFilterCnt;
 	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAdjBandLen:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_AdjBandLen;
	//2026.2.2.165944||新增界面的一些内容|Niu/j
	
	IF i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[1]<>0 THEN
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].adwPressureMotor_Move[1]:=
				i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[1];
		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[1]:= 0;
	END_IF
	IF i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[2]<>0 THEN
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].adwPressureMotor_Move[2]:=
				i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[2];
		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[2]:= 0;
	END_IF
	IF i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[3]<>0 THEN
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].adwPressureMotor_Move[3]:=
				i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[3];
		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].adwPressureMotor_Move_MasterHMI[3]:= 0;
	END_IF	
	
	//2026.02.06.194535增加联动和匀墨
	(*变量使用错误@2026.06.02.130846+*)
	i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].xSwitch_Linkage := 
							i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Linkage;
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].wSwitchFun.0 := 
							i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].xSwitch_Linkage;
	
	
	
	i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xSwitch_Inching_Net
				:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_Ink;
				
	//2026.04.02.191415  Hou.N 增加横向限位实时位置
	g_axLimit_Left_Wr[iUnitId]:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_ConfirmLimit_Left	 ;(*标定横向左限位*)
    g_axLimit_Right_Wr[iUnitId]:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_ConfirmLimit_Right;(*标定横向右限位*)
    g_axLimit_Left_WrClr[iUnitId]:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_ResetLimit_Left;(*清除横向左限位*)
    g_axLimit_Right_WrClr[iUnitId]:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_ResetLimit_Right ;(*清除横向右限位*)	
//2026.5.10.002039
	IF NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xBtn_FromHMI_HorMove_G THEN
		i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xBtn_FromHMI_HorMove_G:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_MoveLeft_Horz;(*横向左移*)
		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_MoveLeft_Horz:= FALSE;
	END_IF
	IF NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xBtn_FromHMI_HorMove_M THEN
		i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xBtn_FromHMI_HorMove_M:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_MoveRight_Horz ;(*横向右移*)
		i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xBtn_MoveRight_Horz:= FALSE;
	END_IF

//	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].lrLimit_Left:=
	i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].lrLimit_Left:=
				DINT_TO_LREAL(i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].diPos_LimitLeft);				
//	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].lrLimit_Right:=
	i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].lrLimit_Right:=	
				DINT_TO_LREAL(i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].diPos_LimitRight);		
// 	g_alrTrap_EncPos[iUnitId]:=
// 				DINT_TO_LREAL(i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].diPos_Horz);		

//增加全自动套印相关变量2026.4.6.130533|2026.5.9.172510
	i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xCurManuAdjust:=
				i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_CurManuAdjust;
	i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xPreCurManuAdjust:=
				i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_PreCurManuAdjust;
				
//2026.05.24.180357 光纤行走
i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].rFiberMoveAdjust:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rFiberMoveAdjust;
i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].rFiberMoveAdjust_ByOnlie:=i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rFiberMoveAdjust_ByOnlie;
//2026.5.29.172542增加一些变量
i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitch_Coolwind:= 
			i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].stBitStWrRd_Switch_Unit.xSwitch_CoolWind;
i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId].byGetErrMode:=
			i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].byGetErrMode;				
END_FOR
//在这里处理一下减速比单独设定和周长单独设定问题；
i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.0:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_BottomGirth;
i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.2:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_NetGirth;
i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.8:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_BottomRatio;
i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.10:= i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_NetRatio;

IF i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_BottomGirth THEN//底辊周长单独设定
	//这时候只更新色组底辊周长
	FOR iUnitId:=1 TO MAX_UNIT_NUM BY 1 DO
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_BottomRoller:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rGirth_BottomGirth;
	END_FOR
ELSE
	FOR iGrp:=1 TO 2 BY 1 DO
		i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_BottomRoller:= i_pstStParam_Diamonds_WrRd^.arGirth_BottomRoller[iGrp];
	END_FOR
END_IF
IF i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_NetGirth THEN//底辊周长单独设定
	//这时候只更新色组wang辊周长
	FOR iUnitId:=1 TO MAX_UNIT_NUM BY 1 DO
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_NetRoller:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rGirth_NetGirth;
	END_FOR
ELSE
	FOR iGrp:=1 TO 2 BY 1 DO
		i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_NetRoller:= i_pstStParam_Diamonds_WrRd^.arGirth_NetRoller[iGrp];
	END_FOR
END_IF
//底辊减速比
IF i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_BottomRatio THEN//底辊周长单独设定
	//这时候只更新色组wang辊周长
	FOR iUnitId:=1 TO MAX_UNIT_NUM BY 1 DO
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_BottomRoller:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiNum_Bottom;
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_BottomRoller:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiDen_Bottom;
	END_FOR
ELSE
	FOR iGrp:=1 TO 2 BY 1 DO
		i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_BottomRoller:= i_pstStParam_Diamonds_WrRd^.auiNum_BottomRoller[iGrp];
		i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_BottomRoller:= i_pstStParam_Diamonds_WrRd^.auiDen_BottomRoller[iGrp];
	END_FOR
END_IF
//wang辊减速比
IF i_pstStParam_Diamonds_WrRd^.stBitStWrRd_Switch_Machine.xSwitch_IndependentSettings_NetRatio THEN//底辊周长单独设定
	//这时候只更新色组wang辊周长
	FOR iUnitId:=1 TO MAX_UNIT_NUM BY 1 DO
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiNum_Net;
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller:= i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].uiDen_Net;
	END_FOR
ELSE
	FOR iGrp:=1 TO 2 BY 1 DO
		i_pstStSysParam^.astStGrpParam_Save[iGrp].uiNum_NetRoller:= i_pstStParam_Diamonds_WrRd^.auiNum_NetRoller[iGrp];
		i_pstStSysParam^.astStGrpParam_Save[iGrp].uiDen_NetRoller:= i_pstStParam_Diamonds_WrRd^.auiDen_NetRoller[iGrp];
	END_FOR
END_IF


i_pstStSysParam^.astStUnitParam_Save[1].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[2].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[3].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[4].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[5].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[6].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[7].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[8].iMarkArrangeMode;
i_pstStSysParam^.astStUnitParam_Save[9].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[1].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[2].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[3].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[4].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[5].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[6].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[7].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[8].iMarkArrangeMode;
i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[9].iMarkArrangeMode;
(*2025.10.23.135406*)
Action_Output_SysCfg_Rd();

//2025.10.22.091027 | bai.zy | 配方

//2025.10.22.091027 | bai.zy | 配方
FOR iGrp := 1 TO 2 BY 1 DO
	//获取启动标志@2026.5.24.212821+
	afbRestorePhase[iGrp](CLK:=i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_RestorePhase_Hmi);
	i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_RestorePhase_Hmi:= FALSE;
	IF afbRestorePhase[iGrp].Q THEN

		ax_RestorePhase_hmi[iGrp] := TRUE;
	END_IF
	
	IF ax_RestorePhase_hmi[iGrp] THEN
		//2026.5.15.113637校验
		IF NOT axInitTime[iGrp] THEN

			tmStart_ReadPhase:= TIME();
			axInitTime[iGrp]:= TRUE;
			g_axPhaseRestore_Overtime[iGrp] := FALSE;

		END_IF
		
		wChk_Tmp:= KS_CRC(i_pstStRd_PhaseRead,SIZEOF(i_pstStRd_PhaseRead^)-6,ADR(dwSum_Tmp));
		IF TIME()-tmStart_ReadPhase<tmTimeOut_ReadPhase THEN//判断超时时间
			IF wChk_Tmp= i_pstStRd_PhaseRead^.wChk AND 
					dwSum_Tmp= i_pstStRd_PhaseRead^.dwSum AND
					dwSum_Tmp<> 0 THEN

				i_pstStSysParam^.astStGrpParam_Save[iGrp].rGirth_PrnRoller 	:= i_pstStRd_PhaseRead^.arGirth_Pu[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].iMarkTypeId 		:= i_pstStRd_PhaseRead^.aiMarkTypeId[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].iMarkArrangeMode  := i_pstStRd_PhaseRead^.aiMarkArrangeId[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].byTriMark_SideC   := i_pstStRd_PhaseRead^.abyTriMark_SideC[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].byTriMark_SideB   := i_pstStRd_PhaseRead^.abyTriMark_SideB[iGrp];
				//是不是和下面这个变量是一样的作用？？？
				//i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.1 := i_pstStRd_PhaseRead^.axGirthInputMode[iGrp];
				
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_Begin_If   := i_pstStRd_PhaseRead^.arTaper_Begin_If[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_End_If     := i_pstStRd_PhaseRead^.arTaper_End_If[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_Begin_Of   := i_pstStRd_PhaseRead^.arTaper_Begin_Of[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_End_Of     := i_pstStRd_PhaseRead^.arTaper_End_Of[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_Begin_Uw   := i_pstStRd_PhaseRead^.arTaper_Begin_Uw[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_End_Uw     := i_pstStRd_PhaseRead^.arTaper_End_Uw[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_Begin_Rw   := i_pstStRd_PhaseRead^.arTaper_Begin_Rw[iGrp];
				i_pstStSysParam^.astStGrpParam_Save[iGrp].rTaper_End_Rw     := i_pstStRd_PhaseRead^.arTaper_End_Rw[iGrp];
				
				FOR iUnitId := 1 TO MAX_UNIT_NUM BY 1 DO
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller 					:= i_pstStRd_PhaseRead^.arGirth[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].xEnable_Arc                       := i_pstStRd_PhaseRead^.axEnable_Arc[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iMarkTypeId                       := i_pstStRd_PhaseRead^.aiMarkTypeId_Pu[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iMarkArrangeMode                  := i_pstStRd_PhaseRead^.aiMarkArrangeId_Pu[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateWidthPhy                     := i_pstStRd_PhaseRead^.aiGateWidthPhy[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateSa                           := i_pstStRd_PhaseRead^.aiGateSa[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iGateSaEx                         := i_pstStRd_PhaseRead^.aiGateSaEx[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.0 := i_pstStRd_PhaseRead^.abySwitch_Unit_Phase[iUnitId].0;
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.2 := i_pstStRd_PhaseRead^.abySwitch_Unit_Phase[iUnitId].1;
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.3 := i_pstStRd_PhaseRead^.abySwitch_Unit_Phase[iUnitId].2;
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.11 := i_pstStRd_PhaseRead^.abySwitch_Unit_Phase[iUnitId].3;
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.12 := i_pstStRd_PhaseRead^.abySwitch_Unit_Phase[iUnitId].4;
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitchOn_CoatingPrn := i_pstStRd_PhaseRead^.abySwitch_Unit_Phase[iUnitId].5;
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAdj_V                            := i_pstStRd_PhaseRead^.arAdj_V[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAdj_H                            := i_pstStRd_PhaseRead^.arAdj_H[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_RegisterOK                 := i_pstStRd_PhaseRead^.aiPhase_RegisterOK[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rSV_UnitTemCtl                    := i_pstStRd_PhaseRead^.arSV_TemCtl[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].byHotBlower_AO          			:= i_pstStRd_PhaseRead^.abyAiirInletWindDoorValue[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].byOvensAirOutWindDoorValue        := i_pstStRd_PhaseRead^.abyOvensAirOutWindDoorValue[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].wAirExhaustWindDoorValue         	:= i_pstStRd_PhaseRead^.abyAirExhaustWindDoorValue[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].wAirReturnWindDoorValue          	:= i_pstStRd_PhaseRead^.abyAirReturnWindDoorValue[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitInkRoller_ManuallySet     := i_pstStRd_PhaseRead^.arHz_UnitInkRoller_ManuallySet[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rCoeff_UnitInkRoller_Auto         := i_pstStRd_PhaseRead^.arCoeff_UnitInkRoller_Auto[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitScraper_ManuallySet       := i_pstStRd_PhaseRead^.arHz_UnitScraper_ManuallySet[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rCoeff_UnitScraper_Auto           := i_pstStRd_PhaseRead^.arCoeff_UnitScraper_Auto[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitHotWind_ManuallySet       := i_pstStRd_PhaseRead^.arHz_UnitHotWind_ManuallySet[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitHotWind_2_ManuallySet     := i_pstStRd_PhaseRead^.arHz_UnitHotWind_2_ManuallySet[iUnitId];
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].rHz_UnitExhaust_ManuallySet       := i_pstStRd_PhaseRead^.arHz_UnitExhaust_ManuallySet[iUnitId];
				END_FOR
				
				i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore := TRUE;
				axInitTime[iGrp]:= FALSE;


				//这里只先清空一下校验码吧
				i_pstStRd_PhaseRead^.wChk:= 0;
				i_pstStRd_PhaseRead^.dwSum:= 0;
				ax_RestorePhase_hmi[iGrp]:= FALSE;
			END_IF
		ELSE
			axInitTime[iGrp]:= FALSE;	


			i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore := FALSE;
			//增加一个报警码？
			//报警清除在Action_Alarm_ClearAndReset，直接清除这个标志
			g_axPhaseRestore_Overtime[iGrp] := TRUE;

			ax_RestorePhase_hmi[iGrp]:= FALSE;//超时直接处理清除
		END_IF	

	END_IF
	
// 	//恢复相位完成了也清除一次
// 	afbResetRestorePhase[iGrp](CLK:= NOT i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore);
// 	//IF afbResetRestorePhase[iGrp].Q THEN




// 	IF (NOT i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore) AND
// 		(NOT i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_RestorePhase_Hmi) THEN
// // 		xInitTime:= FALSE;
// 		ax_RestorePhase_hmi[iGrp]:= FALSE;//超时直接处理清除			
// 	END_IF
	(**)


	//读取装版相位
	IF  i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ReadPhase_Home THEN
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xBtn_ReadPhase_Home := FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xBtn_Home := TRUE;
	END_IF
	
		//2026.1.26.171345 | + | 增加回零位的功能
	IF g_axBackToHome[iGrp] OR i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_BackToHome THEN
		g_axBackToHome[iGrp] := FALSE;
		i_pstStParam_Diamonds_WrRd^.astBitStWrRd_Switch_Grp[iGrp].xSwitch_BackToHome := FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore := TRUE;
		FOR iUnitId := 1 TO MAX_UNIT_NUM BY 1 DO
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_RegisterOK := 0;
		END_FOR
	END_IF	
	
END_FOR



