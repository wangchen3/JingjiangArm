(*@CES
Name=Action_gLink_II_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=1dfcb6d0-4c04-4e1c-b741-2802373335cf
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	pstStUnitParam_Save:= ADR(g_stStSysParam.astStUnitParam_Save[iN]);
	pstStUnitParam_UnSave:= ADR(g_stStSysParam.astStUnitParam_UnSave[iN]);
	//xi.hy2026.5.9.114008
	pstStRSVUnitParam_UnSave:=ADR(g_stStSysParam.astStRSV_UnitParam_UnSave[iN]);
	
	astStParam_Mailbox_snd[iN].dwSemaphore:= SEMA_DOWNLOAD;
	astStParam_Mailbox_snd[iN].iGateSa:= pstStUnitParam_Save^.iGateSa;
	astStParam_Mailbox_snd[iN].iGateSaEx:= pstStUnitParam_Save^.iGateSaEx;
	astStParam_Mailbox_snd[iN].rAdjust_V:= pstStUnitParam_Save^.rAdj_V;
	astStParam_Mailbox_snd[iN].rAdjust_H:= pstStUnitParam_Save^.rAdj_H;
	astStParam_Mailbox_snd[iN].dwFlag_Ctl:= pstStUnitParam_Save^.dwFlag_Ctl;
	astStParam_Mailbox_snd[iN].dwFlag_Sts:= pstStUnitParam_Save^.dwFlag_Sts;
	//2026.04.08.193624//wButtonFun_Lamp赋值
	pstStUnitParam_Save^.wButtonFun_Lamp.0:=g_astStIOMap_Axis_FE[iN].o_xLamp_Linkage;
	pstStUnitParam_Save^.wButtonFun_Lamp.3:=g_astStIOMap_Axis_FE[iN].o_xLamp_Inch;
	pstStUnitParam_Save^.wButtonFun_Lamp.4:=g_astStIOMap_Axis_FE[iN].o_xLamp_Press;
	pstStUnitParam_Save^.wButtonFun_Lamp.2:=FALSE;
	pstStUnitParam_Save^.wButtonFun_Lamp.5:=FALSE;
	pstStUnitParam_Save^.wButtonFun_Lamp.6:=FALSE;
	//pstStUnitParam_Save^.wButtonFun_Lamp.7:=FALSE;
	pstStUnitParam_Save^.wButtonFun_Lamp.8:=g_astStIOMap_Axis_Extra_FE[iN].o_xRel_TurnoverFilmAgency;
	pstStUnitParam_Save^.wButtonFun_Lamp.9:=FALSE;
	pstStUnitParam_Save^.wButtonFun_Lamp.10:=FALSE;
	pstStUnitParam_Save^.wButtonFun_Lamp.11:=FALSE;
	pstStUnitParam_Save^.wButtonFun_Lamp.12:=FALSE;
	pstStUnitParam_Save^.wButtonFun_Lamp.13:=g_stStSysParam.astStGrpParam_UnSave[1].xFlag_Print OR g_stStSysParam.astStGrpParam_UnSave[1].xFlag_Ink;
	pstStUnitParam_Save^.wButtonFun_Lamp.14:=g_stStSysParam.astStGrpParam_UnSave[1].xFlag_Stop OR g_stStSysParam.astStGrpParam_UnSave[1].xFlag_Stoping;
	astStParam_Mailbox_snd[iN].wButtonFun_Lamp:= pstStUnitParam_Save^.wButtonFun_Lamp;

//	astStParam_Mailbox_snd[iN].wButtonFun_Lamp:= pstStUnitParam_Save^.wButtonFun_Lamp;
	astStParam_Mailbox_snd[iN].wSwitchFun:= pstStUnitParam_Save^.wSwitchFun;
	astStParam_Mailbox_snd[iN].rStep_Pressure_Prn_Net:= pstStUnitParam_Save^.rStep_Pressure_Prn_Net;
	astStParam_Mailbox_snd[iN].rLong_Step_Roller_Pressure:= pstStUnitParam_Save^.rLong_Step_Roller_Pressure;
	astStParam_Mailbox_snd[iN].rShort_Step_Roller_Pressure:= pstStUnitParam_Save^.rShort_Step_Roller_Pressure;
	astStParam_Mailbox_snd[iN].wAirInletWindDoorValue:= pstStUnitParam_Save^.byHotBlower_AO;
	astStParam_Mailbox_snd[iN].wAirExhaustWindDoorValue:= pstStUnitParam_Save^.wAirExhaustWindDoorValue;
	astStParam_Mailbox_snd[iN].wAirReturnWindDoorValue:= pstStUnitParam_Save^.wAirReturnWindDoorValue;
	adwCtlBits_UnitBaseCraft_Temp[iN].0 := pstStUnitParam_Save^.xSwitch_ScraperAuto			;//: BIT;(*刮刀手自动-bit0*)
	adwCtlBits_UnitBaseCraft_Temp[iN].1 := pstStUnitParam_Save^.xSwitch_ScraperOn			;//: BIT;(*刮刀开关bit1*)
	adwCtlBits_UnitBaseCraft_Temp[iN].2 := pstStUnitParam_Save^.xInterver_ScraperRun		;//: BIT;(*刮刀开关bit2*)
	adwCtlBits_UnitBaseCraft_Temp[iN].3 := pstStUnitParam_Save^.xRsv_BIT3					;//: BIT;(*BIT3预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].4 := pstStUnitParam_Save^.xSwitch_InkRollerAuto		;//: BIT;(*递墨辊手自动bit4*)
	adwCtlBits_UnitBaseCraft_Temp[iN].5 := pstStUnitParam_Save^.xSwitch_InkRollerCW			;//: BIT;(*递墨辊正转bit5*)
	adwCtlBits_UnitBaseCraft_Temp[iN].6 := pstStUnitParam_Save^.xSwitch_InkRollerCCW		;//: BIT;(*递墨辊反转bit6*)
	adwCtlBits_UnitBaseCraft_Temp[iN].7 := pstStUnitParam_Save^.xInterver_InkRollerRun		;//: BIT;(*递墨辊运行bit7*)
	adwCtlBits_UnitBaseCraft_Temp[iN].8 := pstStUnitParam_Save^.xSwitch_HotWindOn			;//: BIT;(*热风开关bit8*)
	adwCtlBits_UnitBaseCraft_Temp[iN].9 := pstStUnitParam_Save^.xInterver_HotWindRun		;//: BIT;(*热风1运行bit9*)
	adwCtlBits_UnitBaseCraft_Temp[iN].10:= pstStUnitParam_Save^.xRsv_BIT10					;//: BIT;(*BIT10预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].11:= pstStUnitParam_Save^.xRsv_BIT11					;//: BIT;(*BIT11预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].12:= pstStUnitParam_Save^.xSwitch_HotWindOn_II		;//: BIT;(*热风开关bit12*)
	adwCtlBits_UnitBaseCraft_Temp[iN].13:= pstStUnitParam_Save^.xInterver_HotWindRun_II		;//: BIT;(*热风1运行bit13*)
	adwCtlBits_UnitBaseCraft_Temp[iN].14:= pstStUnitParam_Save^.xRsv_BIT14					;//: BIT;(*BIT14预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].15:= pstStUnitParam_Save^.xRsv_BIT15					;//: BIT;(*BIT15预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].16:= pstStUnitParam_Save^.xSwitch_HeatingMode_Water	;//: BIT;(*水加热开关bit16*)
	adwCtlBits_UnitBaseCraft_Temp[iN].17:= pstStUnitParam_Save^.xSwitch_HeatingMode_Ele		;//: BIT;(*电加热开关bit17*)
	adwCtlBits_UnitBaseCraft_Temp[iN].18:= pstStUnitParam_Save^.xSwitch_Heating_I			;//: BIT;(*加热I档bit18*)
	adwCtlBits_UnitBaseCraft_Temp[iN].19:= pstStUnitParam_Save^.xSwitch_Heating_II			;//: BIT;(*加热II档bit19*)
	adwCtlBits_UnitBaseCraft_Temp[iN].20:= pstStUnitParam_Save^.xSwitch_Heating_III			;//: BIT;(*加热III档bit20*)
	adwCtlBits_UnitBaseCraft_Temp[iN].21:= pstStUnitParam_Save^.xRsv_BIT21					;//: BIT;(*BIT21预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].22:= pstStUnitParam_Save^.xRsv_BIT22					;//: BIT;(*BIT22预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].23:= pstStUnitParam_Save^.xErrReset_Scraper			;//: BIT;(*刮刀故障复位bit23*)
	adwCtlBits_UnitBaseCraft_Temp[iN].24:= pstStUnitParam_Save^.xErrReset_InkRoller			;//: BIT;(*递墨故障复位bit24*)
	adwCtlBits_UnitBaseCraft_Temp[iN].25:= pstStUnitParam_Save^.xErrReset_Hotwind			;//: BIT;(*热风故障复位bit25*)
	adwCtlBits_UnitBaseCraft_Temp[iN].26:= pstStUnitParam_Save^.xErrReset_Hotwind_II		;//: BIT;(*热风2故障复位bit26*)
	adwCtlBits_UnitBaseCraft_Temp[iN].27:= pstStUnitParam_Save^.xErrReset_ExhAir			;//: BIT;(*排风故障复位bit27*)
	adwCtlBits_UnitBaseCraft_Temp[iN].28:= pstStUnitParam_Save^.xSwitch_ExhAir				;//: BIT;(*排风开关bit28*)
	adwCtlBits_UnitBaseCraft_Temp[iN].29:= pstStUnitParam_Save^.xInterver_ExhAir			;//: BIT;(*排风运行bit29*)
	adwCtlBits_UnitBaseCraft_Temp[iN].30:= pstStUnitParam_Save^.xRsv_BIT30					;//: BIT;(*BIT30预留*)
	adwCtlBits_UnitBaseCraft_Temp[iN].31:= pstStUnitParam_Save^.xSwitch_Coolwind			;//: BIT;(*冷风开关*)
	
	astStParam_Mailbox_snd[iN].dwCtlBits_UnitBaseCraft:= adwCtlBits_UnitBaseCraft_Temp[iN];
	astStParam_Mailbox_snd[iN].wHz_UnitInkRoller_ManuallySet:= REAL_TO_WORD(pstStUnitParam_Save^.rHz_UnitInkRoller_ManuallySet*100.0);
	astStParam_Mailbox_snd[iN].wCoeff_UnitInkRoller_Auto:= REAL_TO_WORD(pstStUnitParam_Save^.rCoeff_UnitInkRoller_Auto*100.0);
	astStParam_Mailbox_snd[iN].wHz_UnitScraper_ManuallySet:= REAL_TO_WORD(pstStUnitParam_Save^.rHz_UnitScraper_ManuallySet*100.0)		  ;
	astStParam_Mailbox_snd[iN].wCoeff_UnitScraper_Auto:= REAL_TO_WORD(pstStUnitParam_Save^.rCoeff_UnitScraper_Auto*100.0)			     ;
	astStParam_Mailbox_snd[iN].wHz_UnitHotWind:= REAL_TO_WORD(pstStUnitParam_Save^.rHz_UnitHotWind_ManuallySet*100.0)		  ;
	astStParam_Mailbox_snd[iN].wHz_UnitHotWind_2:= REAL_TO_WORD(pstStUnitParam_Save^.rHz_UnitHotWind_2_ManuallySet*100.0)		;
	astStParam_Mailbox_snd[iN].wSV_UnitTemCtl:= REAL_TO_WORD(pstStUnitParam_Save^.rSV_UnitTemCtl*100.0)						           ;
	astStParam_Mailbox_snd[iN].wUnit_output_I:= pstStUnitParam_UnSave^.wUnit_output_I;
	astStParam_Mailbox_snd[iN].wUnit_output_II:= pstStUnitParam_UnSave^.wUnit_output_II;
	astStParam_Mailbox_snd[iN].bySignalSelect:= pstStUnitParam_Save^.bySignalSelect;
	astStParam_Mailbox_snd[iN].rOffset_T1:= pstStUnitParam_Save^.rOffset_T1;
	astStParam_Mailbox_snd[iN].rSource_Light_T1:= pstStUnitParam_Save^.rSource_Light_T1;
	astStParam_Mailbox_snd[iN].rBias_T1:= pstStUnitParam_Save^.rBias_T1;
	astStParam_Mailbox_snd[iN].rBrightness_Light_T1:= pstStUnitParam_Save^.rBrightness_Light_T1;
	astStParam_Mailbox_snd[iN].rOffset_T2:= pstStUnitParam_Save^.rOffset_T2;
	astStParam_Mailbox_snd[iN].rSource_Light_T2:= pstStUnitParam_Save^.rSource_Light_T2;
	astStParam_Mailbox_snd[iN].rBias_T2:= pstStUnitParam_Save^.rBias_T2;
	astStParam_Mailbox_snd[iN].rBrightness_Light_T2:= pstStUnitParam_Save^.rBrightness_Light_T2;

	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.0:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].0;//版辊操作侧靠近
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.1:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].1;//版辊操作侧远离
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.2:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].4;//版辊平行靠近
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.3:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].5; //版辊平行远离
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.4:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].2;//版辊传动侧靠近
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.5:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].3;//版辊传动侧远离

	//2026.02.10.143913|新增
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.15:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].10; //版辊合压
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.0:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].8;//版辊离压
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.3:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].9;//版辊换版
	//2026.02.23.151133 新增 Hou.N
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.5:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].14;//自动换版
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.6:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].15;//版辊换版
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.7:= pstStUnitParam_UnSave^.adwPressureMotor_Move[1].19;//显示换版状态
										
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.6:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].0;//网辊操作侧靠近
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.7:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].1;//网辊操作侧远离
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.8:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].4;//网辊平行靠近
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.9:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].5;//网辊平行远离
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.10:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].2;//网辊传动侧靠近
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.11:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].3;//网辊传动侧远离
		
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.1:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].10;//网辊合压
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.2:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].8;//网辊离压
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI2.4:= pstStUnitParam_UnSave^.adwPressureMotor_Move[2].9;//网辊换版
	
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.12:=pstStUnitParam_UnSave^.adwPressureMotor_Move[1].16;//版辊标定
	astStParam_Mailbox_snd[iN].wSlaveBtn_HMI.13:=pstStUnitParam_UnSave^.adwPressureMotor_Move[2].16;//网辊标定
//2026.03.14.93922 
	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.1:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.1;//网辊锁轴
	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.2:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.2;//充气
	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.3:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.3;//墨盘电磁阀升
	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.4:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.4;//照明
	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.11:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.11;//合压
	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.12:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.12;//离压
	//2026.03.18.112045 新＋
//	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.5:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.5;//显示是否修改版周
//	astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.6:=pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.6;//确认修改版周
	//2025.11.14.172840  | + 
// 	IF pstStUnitParam_Save^.wButtonFun_Lamp.0 THEN
// 		g_astStMcgsBtn_HMI[iN].xBtn_Inch:= TRUE;
// 		pstStUnitParam_Save^.wButtonFun_Lamp.0 := FALSE;
// 	END_IF
	astStParam_Mailbox_snd[iN].wState_FiberMove:=pstStRSVUnitParam_UnSave^.wState_FiberMove;
	
	g_astStMcgsBtn_HMI[iN].xSwitch_Linkage:= pstStUnitParam_Save^.wSwitchFun.0;
	g_astStMcgsBtn_HMI[iN].xSwitch_PressRollAuto:= pstStUnitParam_Save^.wSwitchFun.1;
	//2026.06.03.132225
	g_astStMcgsBtn_HMI[iN].xSwitch_TurnoverFilm:=pstStUnitParam_Save^.wButtonFun_Lamp.7;
	
//	g_stStSysParam.astStUnitParam_Save[iN].wButtonFun_Lamp.15:= g_astStIOMap_Axis_FE[iN].o_xLamp_Inch;
	
		astStParam_Mailbox_snd[iN].iStep_Horz_Use:= REAL_TO_INT(g_stStSysParam.astStRSV_UnitParam_UnSave[iN].rStep_Horz*100.0);
		astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.14:= g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xBtn_FromHMI_HorMove_M;
		astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.13:= g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xBtn_FromHMI_HorMove_G;
		
		//2026.03.11.101506  Hou.N +
		astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.0:=g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Net;//匀墨
		astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.9:=g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Prn;//版辊单动
		astStParam_Mailbox_snd[iN].wButtonAndSwitch_ChaoXu.10:=g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Bottom;//底辊单动

		//xi.hy
		astStParam_Mailbox_snd[iN].wState_FiberMove:=pstStRSVUnitParam_UnSave^.wState_FiberMove;
		astStParam_Mailbox_snd[iN].wAlarm_FiberMove:=pstStRSVUnitParam_UnSave^.uiFiberMoveAlarm;
		astStParam_Mailbox_snd[iN].iFiberMoveDistanceIn:=REAL_TO_WORD(pstStRSVUnitParam_UnSave^.rFiberMoveDistanceIn*10);
		astStParam_Mailbox_snd[iN].iPosCur_FiberMove:=	REAL_TO_INT(pstStRSVUnitParam_UnSave^.rFiberMovePosCur*10.0);
		astStParam_Mailbox_snd[iN].iWidth_FindMarkCenter:= REAL_TO_INT(	pstStRSVUnitParam_UnSave^.rWidth_FindMarkCenter*100.0);
		
		//2026.04.28.133304 xi.hy新增@七号开始
		astStParam_Mailbox_snd[iN].iStsSlave_FiberMove:=pstStRSVUnitParam_UnSave^.iStsSlave_FiberMove;
		//2026.05.28.181703
		astStParam_Mailbox_snd[iN].iFiberMoveBasePosFromSlave:=REAL_TO_INT(pstStRSVUnitParam_UnSave^.rFiberMoveBasePosFromSlave*10.0);
		
(*2026.5.9.114326
		astStParam_Mailbox_snd[iN].wAccButton_Count		:=g_awAccButton_Count[iN]		;//		: WORD;
		astStParam_Mailbox_snd[iN].wDecButton_Count		:=g_awDecButton_Count[iN]		;//	: WORD;
		astStParam_Mailbox_snd[iN].wUpAdjButton_Count	:=g_awUpAdjButton_Count[iN]	;	//	: WORD;
		astStParam_Mailbox_snd[iN].wDnAdjButton_Count	:=g_awDnAdjButton_Count[iN]	;	//	: WORD;
		astStParam_Mailbox_snd[iN].wLeftAdjButton_Count	:=g_awLeftAdjButton_Count[iN]	;	//		: WORD;
		astStParam_Mailbox_snd[iN].wRightAdjButton_Count	:=g_awRightAdjButton_Count[iN];	//		: WORD;
		astStParam_Mailbox_snd[iN].wAlarmButton_Count:= g_awAlarmButton_Count[iN]		;//	: WORD;
	*)		
END_FOR


