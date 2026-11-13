(*@CES
Name=KS_RstSysParam_Save
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8442070d-5efa-4f31-a934-f12a469761f6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RstSysParam_Save : INT
VAR_INPUT
	i_pstStSysParam_Save: POINTER TO StSysParam_Save;
	i_pstStSysParam_Save_RSV: POINTER TO StRSV_SysParam_Save;

	i_pstStMechanicalParam_01: POINTER TO StMechanicalParam_01; (* 机械结构1| *)
	i_pstStMechanicalParam_02: POINTER TO StMechanicalParam_02; (* 机械结构2| *)
	i_pstStMechanicalParam_03: POINTER TO StMechanicalParam_03; (* 机械结构3| *)
	i_pstStMechanicalParam_05: POINTER TO StMechanicalParam_05; (* 机械结构5| *)(*2023.09.21.150812 同步*)
	
END_VAR
VAR
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:=0;

IF i_pstStSysParam_Save<>0 AND i_pstStSysParam_Save_RSV<>0 THEN
	SysMemSet(ADR(i_pstStSysParam_Save_RSV^.abyRSV_SysParam_Save),
				0, 
				SIZEOF(i_pstStSysParam_Save_RSV^.abyRSV_SysParam_Save));
	i_pstStSysParam_Save^.dwFileVersion						:= 16#20250628;
	i_pstStSysParam_Save^.iCustomerId                       := 0;
	i_pstStSysParam_Save^.dwEquipmentProf                   := 0;
	i_pstStSysParam_Save^.iUnitMaxNum                       := 9;
	i_pstStSysParam_Save^.iCurveViewMaxRange                := 100;
	i_pstStSysParam_Save^.iTitleTextHeight                  := 16;
	i_pstStSysParam_Save^.iEntryTextHeight                  := 12;
	i_pstStSysParam_Save^.iLabelTextHeight                  := 12;
	i_pstStSysParam_Save^.iButtonTextHeight                 := 10;
	i_pstStSysParam_Save^.iMessageTextHeight                := 18;
	i_pstStSysParam_Save^.iRsvdTextHeight                   := 10;
	i_pstStSysParam_Save^.byLanguageId                      := 1;
	i_pstStSysParam_Save^.byMinutes_ScrSaver                := 3;
	i_pstStSysParam_Save^.iPointDensity_RS                  := 4;
	i_pstStSysParam_Save^.wCtlFlag_IndependentSettings      := 0;
(*	i_pstStSysParam_Save^.dwControlComplexBits              := 0;*)
	i_pstStSysParam_Save^.xFlag_CancelSafetyGrate			:= FALSE;
	i_pstStSysParam_Save^.xSwitch_ArcTest_V					:= TRUE;
	i_pstStSysParam_Save^.xSwitch_ArcTest_H					:= TRUE;
	i_pstStSysParam_Save^.xAllowLinkageChangeInRunning		:= FALSE;
	i_pstStSysParam_Save^.xChangLinkageStsWhenPrint			:= FALSE;
	
	
//2026.5.14.091013
//	i_pstStSysParam_Save^.astStMechanicalParamBuf           := 1;
	i_pstStSysParam_Save^.dwCtlSwitchRef                    := 0;
	i_pstStSysParam_Save^.byHorzCtlMode                   := 1;
	i_pstStSysParam_Save^.rStepDrivePosPPulse               := 0.0002;
	i_pstStSysParam_Save^.iStepDrivePulsePRev               := 6000;
	i_pstStSysParam_Save^.iStepDriveSa_Vel                  := 10;
	i_pstStSysParam_Save^.iStepDrivePreReg_Vel              := 50;
	i_pstStSysParam_Save^.iStepDriveManu_Vel                := 20;
	i_pstStSysParam_Save^.iStepDriveAuto_Vel                := 20;
	i_pstStSysParam_Save^.iStepDriveAccTime                 := 50;
	i_pstStSysParam_Save^.iStepDriveManu_Vel_Fast           := 40;
	i_pstStSysParam_Save^.byOverPercent_RatedRpm            := 10;
	i_pstStSysParam_Save^.rCurrent_Limit                    := 10;
	i_pstStSysParam_Save^.xWorkMode_Inch                    := FALSE;
	i_pstStSysParam_Save^.rHorCtl_PosPPulse                 := 0.000635;
	i_pstStSysParam_Save^.diHorCtl_PulsePRev                := 131072;
	i_pstStSysParam_Save^.rHorCtl_PreReg_Vel                := 2;
	i_pstStSysParam_Save^.rHorCtl_Manu_Vel                  := 0.5;
	i_pstStSysParam_Save^.rHorCtl_Manu_Vel_Fast             := 1;
	i_pstStSysParam_Save^.rHorCtl_Auto_Vel                  := 0.5;
	i_pstStSysParam_Save^.iHorCtl_Num                       := 60;
	i_pstStSysParam_Save^.iHorCtl_Den                       := 1;
	i_pstStSysParam_Save^.rHorCtl_Pitch                     := 5;
	i_pstStSysParam_Save^.iHorCtl_AccDecTime                := 10;
	i_pstStSysParam_Save^.diTimeHold_Prestart               := 3000;
	i_pstStSysParam_Save^.diTimeHold_Uw_Diam                := 3000;
	i_pstStSysParam_Save^.diTimeHold_Rw_Diam                := 3000;
	i_pstStSysParam_Save^.diTimeHold_Rw_Prnlength           := 3000;
	i_pstStSysParam_Save^.byHotBlowerStopDelayTime          := 0;
	i_pstStSysParam_Save^.byHeatingOutWay_III               := 1;
	i_pstStSysParam_Save^.iTimeOut_Slave_485_Inverter       := 3;
	i_pstStSysParam_Save^.iCofe_TempCtl_30                  := 30;
	i_pstStSysParam_Save^.iCofe_TempCtl_30_10               := 40;
	i_pstStSysParam_Save^.iCofe_TempCtl_10_5                := 50;
	i_pstStSysParam_Save^.iCofe_TempCtl_5                   := 60;
	i_pstStSysParam_Save^.iTime_Thres_Water                 := 150;
	i_pstStSysParam_Save^.byHeatingMode                     := 1;
	i_pstStSysParam_Save^.byOverTempValue                   := 150;
	i_pstStSysParam_Save^.byEn_ExtraFun_485                 := 16#0;
	i_pstStSysParam_Save^.iPidAlgorithm_Threshold           := 2;
	i_pstStSysParam_Save^.iMaxOutValue                      := 150;
	i_pstStSysParam_Save^.rKp                               := 10;
	i_pstStSysParam_Save^.rKi                               := 10;
	i_pstStSysParam_Save^.rKd                               := 300;
	i_pstStSysParam_Save^.uiCtrolCycle_Ms                   := 6000;
	i_pstStSysParam_Save^.iWaterValue_Threshold             := 60;
	i_pstStSysParam_Save^.iTempAcc_Threshold                := 20;
	i_pstStSysParam_Save^.iDecSV_PV_Threshold               := 10;
	i_pstStSysParam_Save^.xEn_HeatOff_AfterStop             := FALSE;
	i_pstStSysParam_Save^.xEn_HeatAirOff_AfterStop          := FALSE;
	i_pstStSysParam_Save^.rDelayOff_HotAir                  := 0;
	i_pstStSysParam_Save^.iDebugStep                        := 0;
	i_pstStSysParam_Save^.dwSwitch                          := 0;
//	i_pstStSysParam_Save^.byFakeThreshold_V                 := 50;
//	i_pstStSysParam_Save^.byFakeThreshold_H                 := 50;
//2026.5.29.185244补漏初始化
	i_pstStSysParam_Save^.xUnitPressOneBtn			:= FALSE;
	i_pstStSysParam_Save^.xAllPressOneBtn			:= FALSE;
	i_pstStSysParam_Save^.xPreCutOneBtn_Rw			:= FALSE;
	i_pstStSysParam_Save^.xPreCutOneBtn_Uw			:= FALSE;
	i_pstStSysParam_Save^.xTypeGetInitDiam:= TRUE;

	i_pstStSysParam_Save^.uiMaxDia:= 800;
	i_pstStSysParam_Save^.uiInitDiam_Uw:= 350;
	i_pstStSysParam_Save^.uiInitDiam_Rw:= 350;
	i_pstStSysParam_Save^.byCouplingType:= 0;
	
	(*新增加参数|wang.nt|2025.08.07.143540*)
	i_pstStSysParam_Save^.wMachineArchitectureRef									 :=0	;(*机器架构描述*)		
	i_pstStSysParam_Save^.iPromptMsgId												 :=0	;(*提示信息ID（报警代码）*)
	i_pstStSysParam_Save^.byCheckTimeToTips_BrakeResistance							 :=1	;(*制动电阻访问超限提示时间*)
	i_pstStSysParam_Save^.byCheckTimeToEStop_BrakeResistance						:=4	;(*制动电阻访问超限急停时间*)
	i_pstStSysParam_Save^.byAccessTimes_BrakeResistance								 :=40	;(*制动电阻报警限制*)
	i_pstStSysParam_Save^.byAlarmHold_VOL_Uw										:=3	;(*放料没料响应时间*)
	i_pstStSysParam_Save^.byAlarmHold_PrnLength										 :=3	;(*收料印长报警响应时间*)
	i_pstStSysParam_Save^.rOpenThr_Ele												 :=0.9	;(*电加热开启*)
	i_pstStSysParam_Save^.rCloseThr_Ele												 :=0	;(*电加热关闭*)
	i_pstStSysParam_Save^.rDealValue_Water											 :=0.2	;(*水加热死区*)
	i_pstStSysParam_Save^.diStepDriveDebugPulse										 :=60000	;(*测试脉冲数*)
	i_pstStSysParam_Save^.iStepDriveDebugNum										:=1	;(*测试色组号*)
	i_pstStSysParam_Save^.rHz_MainExhaust_ManuallySet								 :=20	;(*主排风设定频率*)
	i_pstStSysParam_Save^.byFreq_I_ExhaustAir										 :=10	;(*排风一档频率*)
	i_pstStSysParam_Save^.byFreq_II_ExhaustAir										 :=20	;(*排风二档频率*)
	i_pstStSysParam_Save^.byFreq_III_ExhaustAir										 :=30	;(*排风三档频率*)
	(*9905界面参数*)
	i_pstStSysParam_Save^.byPseudoRandomRoundTimes									:=2		;
	i_pstStSysParam_Save^.rPseudoRandomAmplitude									:=0.03	;
	i_pstStSysParam_Save^.rCompensateGirthWhenAccing_If								:=0		;
	i_pstStSysParam_Save^.rCompensateGirthWhenAccing_Of								:=0		;
	i_pstStSysParam_Save^.iCustomerLogoOffsetX										:=-50	;
	i_pstStSysParam_Save^.byGuardrialColor_R										:=220	;
	i_pstStSysParam_Save^.byGuardrialColor_G										:=0		;
	i_pstStSysParam_Save^.byGuardrialColor_B										:=0		;
	i_pstStSysParam_Save^.iLedFuncId												:=0		;
	i_pstStSysParam_Save^.wRunningTime_Day											:=0		;
	i_pstStSysParam_Save^.byRunningTime_Hour										:=0		;
	i_pstStSysParam_Save^.byRunningTime_Min											:=0		;
	i_pstStSysParam_Save^.byRunningTime_Sec											:=0		;
	i_pstStSysParam_Save^.byArcIntensity_W											:=20		;
	i_pstStSysParam_Save^.byArcIntensity_M											:=15		;
	i_pstStSysParam_Save^.byArcIntensity_S											:=10		;
//2026.5.8.160718增加调整强度切换
	i_pstStSysParam_Save^.byArcIntensity											:=1		;
	
	
	i_pstStSysParam_Save^.byMotorOverTempValue_UseEncTemp							:=110		;
	i_pstStSysParam_Save^.byRemainSpaceNum_PTCTL									:=5		;
	i_pstStSysParam_Save^.rSpeed_SCoeff_Type789										:=2.0/3.0	;
	i_pstStSysParam_Save^.byMaxPulseOut_16dIO										:=3		;
	i_pstStSysParam_Save^.bySysSamplePrecision										:=2		;
	i_pstStSysParam_Save^.byArcAdjValueDealType										:=1		;
	i_pstStSysParam_Save^.byArcErrLimitToCtl_P										:=8		;
	i_pstStSysParam_Save^.byArcErrLimitToCtl_I 										:=1		;
	i_pstStSysParam_Save^.byMaxPulseOut_Module										:=15	;
	i_pstStSysParam_Save^.byArcFineSampleType										:=0		;
	i_pstStSysParam_Save^.byArcPidGetType 											:=0		;
	i_pstStSysParam_Save^.rFilmLenth_Eyes											:=1.5	;
	i_pstStSysParam_Save^.uiArcSysDelayTime_ms           							:=100	;
	i_pstStSysParam_Save^.byParamIndex_Huang										:=9		;
	i_pstStSysParam_Save^.uiControllerVel_Huang										:=0		;
	i_pstStSysParam_Save^.byDeCoupleArcNum											:=5		;	
	i_pstStSysParam_Save^.xUseGc_PID_2025											:=TRUE	;(*2025.1.15.175536+*)
	i_pstStSysParam_Save^.byKadj_SetType											:= 0	;
	(*2025.8.19.211325增加*)
	i_pstStSysParam_Save^.byTypeFollow_Arc:= 0;(*先按照保持的处理*)	
	i_pstStSysParam_Save^.byParamIndex_Huang:= 9;
	i_pstStSysParam_Save^.uiControllerVel_Huang:= 0;

	i_pstStSysParam_Save^.xInitArcErr_AjdImmediately:= TRUE;
	i_pstStSysParam_Save^.byUseArcAccOrDecCompensate:= 0;(*柔印先默认=0，不适用加速补偿*)
	
	i_pstStSysParam_Save^.xAutoSetArcCtlWay := TRUE;
	i_pstStSysParam_Save^.iUid:= 2;//2025.08.23.200449+
//2026.05.27.214505
	i_pstStSysParam_Save^.uiMaxVel_UseCalcAcc:= 100;	
	
//2026.5.28.145220增加机械参数初始化	
	IF i_pstStMechanicalParam_01<>0 THEN
		i_pstStMechanicalParam_01^.lrA			:= 90;(*LREAL*)
		i_pstStMechanicalParam_01^.lrD1			:= 100;(*LREAL*)
		i_pstStMechanicalParam_01^.lrD2			:= 100;(*LREAL*)
		i_pstStMechanicalParam_01^.lrD3			:= 100;(*LREAL*)
		i_pstStMechanicalParam_01^.lrDR			:= 135;(*LREAL*)
		i_pstStMechanicalParam_01^.lrL1			:= 225;(*LREAL*)
		i_pstStMechanicalParam_01^.lrL2			:= 225;(*LREAL*)
		i_pstStMechanicalParam_01^.lrX1			:= 325;(*LREAL*)
		i_pstStMechanicalParam_01^.lrX3			:= 105;(*LREAL*)
		i_pstStMechanicalParam_01^.lrX5			:= 145;(*LREAL*)
		i_pstStMechanicalParam_01^.lrX6			:= 464;(*LREAL*)
		i_pstStMechanicalParam_01^.lrY1			:= 700;(*LREAL*)
		i_pstStMechanicalParam_01^.lrY3			:= 882.5;(*LREAL*)
		i_pstStMechanicalParam_01^.lrY5			:= 1230;(*LREAL*)
		i_pstStMechanicalParam_01^.lrY6			:= 1075;(*LREAL*)
	END_IF
	IF i_pstStMechanicalParam_02<>0 THEN
		i_pstStMechanicalParam_02^.lrD1			:= 100;(**)
		i_pstStMechanicalParam_02^.lrD3			:= 100;(**)
		i_pstStMechanicalParam_02^.lrDR			:= 135;(**)
		i_pstStMechanicalParam_02^.lrX1			:= 325;(**)
		i_pstStMechanicalParam_02^.lrX5			:= 145;(**)
		i_pstStMechanicalParam_02^.lrX6			:= 464;(**)
		i_pstStMechanicalParam_02^.lrY1			:= 700;(**)
		i_pstStMechanicalParam_02^.lrY5			:= 1230;(**)
		i_pstStMechanicalParam_02^.lrY6			:= 1075;(**)
	END_IF
	IF i_pstStMechanicalParam_03<>0 THEN
		i_pstStMechanicalParam_03^.lrD2			:= 100;(**)
		i_pstStMechanicalParam_03^.lrD3			:= 100;(**)
		i_pstStMechanicalParam_03^.lrD4			:= 135;(**)
		i_pstStMechanicalParam_03^.lrD5			:= 100;(**)
		i_pstStMechanicalParam_03^.lrD6			:= 80;(**)
		i_pstStMechanicalParam_03^.lrH12		:= 70;(**)
		i_pstStMechanicalParam_03^.lrM			:= 100;(**)
		i_pstStMechanicalParam_03^.lrN			:= 100;(**)
		i_pstStMechanicalParam_03^.lrX1			:= 325;(**)
		i_pstStMechanicalParam_03^.lrX2			:= 0;(**)
		i_pstStMechanicalParam_03^.lrX3			:= 105;(**)
		i_pstStMechanicalParam_03^.lrX4			:= 640;(**)
		i_pstStMechanicalParam_03^.lrX5			:= 145;(**)
		i_pstStMechanicalParam_03^.lrX6			:= 464;(**)
		i_pstStMechanicalParam_03^.lrY1			:= 700;(**)
		i_pstStMechanicalParam_03^.lrY2			:= 0;(**)
		i_pstStMechanicalParam_03^.lrY3			:= 882.5;(**)
		i_pstStMechanicalParam_03^.lrY4			:= 0;(**)
		i_pstStMechanicalParam_03^.lrY5			:= 1230;(**)
		i_pstStMechanicalParam_03^.lrY6			:= 1075;(**)	
	END_IF
	IF i_pstStMechanicalParam_05<>0 THEN
		(*2026.08.27.095847 默认值暂未处理*)
		i_pstStMechanicalParam_05^.rX1:= 167;
		i_pstStMechanicalParam_05^.rX2:= 135;
		i_pstStMechanicalParam_05^.rX3:= 300;
		i_pstStMechanicalParam_05^.rX4:= 454;	

		i_pstStMechanicalParam_05^.rY0:= 700;
		i_pstStMechanicalParam_05^.rY1:= 1255;
		i_pstStMechanicalParam_05^.rY4:= 1075;
		
		i_pstStMechanicalParam_05^.rD1:= 100;	
		i_pstStMechanicalParam_05^.rD2:= 100;	
		i_pstStMechanicalParam_05^.rD3:= 135;	
		i_pstStMechanicalParam_05^.rD4:= 100;	
		
		i_pstStMechanicalParam_05^.rY2:= 1109;(*[AI修改20260829]rL2_3改rY2|辊2安装高度,机台图纸值*)		
	END_IF
	
	iResult:=1;
ELSE
	iResult:=-1;
END_IF