(*@CES
Name=Action_gLink_II_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=075e8bd3-4afc-466b-b5b0-16bdc62b582f
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	pstStUnitParam_Save:= ADR(g_stStSysParam.astStUnitParam_Save[iN]);
	pstStUnitParam_UnSave:= ADR(g_stStSysParam.astStUnitParam_UnSave[iN]);
	//xi.hy2026.5.9.114419
	pstStRSVUnitParam_UnSave:=ADR(g_stStSysParam.astStRSV_UnitParam_UnSave[iN]);
	IF axNeedUpdateParam_Malilbox[iN] THEN
		axNeedUpdateParam_Malilbox[iN]:= FALSE;
		pstStUnitParam_Save^.iGateSa:= astStParam_Mailbox_out[iN].iGateSa                      	;//第一波门位置      
		pstStUnitParam_Save^.iGateSaEx:= astStParam_Mailbox_out[iN].iGateSaEx                        ;//第二波门位置      
		pstStUnitParam_Save^.rAdj_V:= astStParam_Mailbox_out[iN].rAdjust_V                        ;//纵向版修正量      
		pstStUnitParam_Save^.rAdj_H:= astStParam_Mailbox_out[iN].rAdjust_H                        ;//横向版修正量      
		pstStUnitParam_Save^.dwFlag_Ctl:= astStParam_Mailbox_out[iN].dwFlag_Ctl                       ;//套色控制标志      
		pstStUnitParam_Save^.dwFlag_Sts:= astStParam_Mailbox_out[iN].dwFlag_Sts                       ;//套色状态标志      
		pstStUnitParam_Save^.wButtonFun_Lamp:= astStParam_Mailbox_out[iN].wButtonFun_Lamp                  ;//HMI界面按钮及指示灯 
		//2026.04.08.195419||2026.5.9.114523
		g_astStMcgsBtn_HMI[iN].xBtn_Inch:=pstStUnitParam_Save^.wButtonFun_Lamp.2;
		g_astStMcgsBtn_HMI[iN].xBtn_Press:=pstStUnitParam_Save^.wButtonFun_Lamp.5;
		g_astStMcgsBtn_HMI[iN].xBtn_UnPress:=pstStUnitParam_Save^.wButtonFun_Lamp.6;
		//g_astStMcgsBtn_HMI[iN].xBtn_TurnoverFilm:=pstStUnitParam_Save^.wButtonFun_Lamp.7;
		g_astStMcgsBtn_HMI[iN].xBtn_Stop:=pstStUnitParam_Save^.wButtonFun_Lamp.9;
		g_astStMcgsBtn_HMI[iN].xBtn_Ink:=pstStUnitParam_Save^.wButtonFun_Lamp.10;
		g_astStMcgsBtn_HMI[iN].xBtn_Print:=pstStUnitParam_Save^.wButtonFun_Lamp.11;
		g_astStMcgsBtn_HMI[iN].xBtn_PreStart:=pstStUnitParam_Save^.wButtonFun_Lamp.12;

		
		pstStUnitParam_Save^.wSwitchFun:= astStParam_Mailbox_out[iN].wSwitchFun                   ;//界面按钮    
		pstStUnitParam_Save^.rStep_Pressure_Prn_Net:= astStParam_Mailbox_out[iN].rStep_Pressure_Prn_Net           ;//版辊网辊按钮步进量   
		pstStUnitParam_Save^.rLong_Step_Roller_Pressure:= astStParam_Mailbox_out[iN].rLong_Step_Roller_Pressure       ;//色组压力控制长步进值  
		pstStUnitParam_Save^.rShort_Step_Roller_Pressure:= astStParam_Mailbox_out[iN].rShort_Step_Roller_Pressure      ;//色组压力控制短步进值  
		pstStUnitParam_Save^.byHotBlower_AO:= WORD_TO_BYTE(astStParam_Mailbox_out[iN].wAirInletWindDoorValue)           ;//进风口风门开度值    
		pstStUnitParam_Save^.wAirExhaustWindDoorValue:= astStParam_Mailbox_out[iN].wAirExhaustWindDoorValue         ;//排风口风门开度值    
		pstStUnitParam_Save^.wAirReturnWindDoorValue:= astStParam_Mailbox_out[iN].wAirReturnWindDoorValue          ;//回风口风门开度值    


		adwCtlBits_UnitBaseCraft_Temp[iN]:= astStParam_Mailbox_out[iN].dwCtlBits_UnitBaseCraft          ;//界面工艺开关及状态   
	
		
		pstStUnitParam_Save^.xSwitch_ScraperAuto			:= adwCtlBits_UnitBaseCraft_Temp[iN].0 ;//: BIT;(*刮刀手自动-bit0*)
		pstStUnitParam_Save^.xSwitch_ScraperOn			:= adwCtlBits_UnitBaseCraft_Temp[iN].1 ;//: BIT;(*刮刀开关bit1*)
		pstStUnitParam_Save^.xInterver_ScraperRun		:= adwCtlBits_UnitBaseCraft_Temp[iN].2 ;//: BIT;(*刮刀开关bit2*)
		pstStUnitParam_Save^.xRsv_BIT3					:= adwCtlBits_UnitBaseCraft_Temp[iN].3 ;//: BIT;(*BIT3预留*)
		pstStUnitParam_Save^.xSwitch_InkRollerAuto		:= adwCtlBits_UnitBaseCraft_Temp[iN].4 ;//: BIT;(*递墨辊手自动bit4*)
		pstStUnitParam_Save^.xSwitch_InkRollerCW			:= adwCtlBits_UnitBaseCraft_Temp[iN].5 ;//: BIT;(*递墨辊正转bit5*)
		pstStUnitParam_Save^.xSwitch_InkRollerCCW		:= adwCtlBits_UnitBaseCraft_Temp[iN].6 ;//: BIT;(*递墨辊反转bit6*)
		pstStUnitParam_Save^.xInterver_InkRollerRun		:= adwCtlBits_UnitBaseCraft_Temp[iN].7 ;//: BIT;(*递墨辊运行bit7*)
		pstStUnitParam_Save^.xSwitch_HotWindOn			:= adwCtlBits_UnitBaseCraft_Temp[iN].8 ;//: BIT;(*热风开关bit8*)
		pstStUnitParam_Save^.xInterver_HotWindRun		:= adwCtlBits_UnitBaseCraft_Temp[iN].9 ;//: BIT;(*热风1运行bit9*)
		pstStUnitParam_Save^.xRsv_BIT10					:= adwCtlBits_UnitBaseCraft_Temp[iN].10;//: BIT;(*BIT10预留*)
		pstStUnitParam_Save^.xRsv_BIT11					:= adwCtlBits_UnitBaseCraft_Temp[iN].11;//: BIT;(*BIT11预留*)
		pstStUnitParam_Save^.xSwitch_HotWindOn_II		:= adwCtlBits_UnitBaseCraft_Temp[iN].12;//: BIT;(*热风开关bit12*)
		pstStUnitParam_Save^.xInterver_HotWindRun_II		:= adwCtlBits_UnitBaseCraft_Temp[iN].13;//: BIT;(*热风1运行bit13*)
		pstStUnitParam_Save^.xRsv_BIT14					:= adwCtlBits_UnitBaseCraft_Temp[iN].14;//: BIT;(*BIT14预留*)
		pstStUnitParam_Save^.xRsv_BIT15					:= adwCtlBits_UnitBaseCraft_Temp[iN].15;//: BIT;(*BIT15预留*)
		pstStUnitParam_Save^.xSwitch_HeatingMode_Water	:= adwCtlBits_UnitBaseCraft_Temp[iN].16;//: BIT;(*水加热开关bit16*)
		pstStUnitParam_Save^.xSwitch_HeatingMode_Ele		:= adwCtlBits_UnitBaseCraft_Temp[iN].17;//: BIT;(*电加热开关bit17*)
		pstStUnitParam_Save^.xSwitch_Heating_I			:= adwCtlBits_UnitBaseCraft_Temp[iN].18;//: BIT;(*加热I档bit18*)
		pstStUnitParam_Save^.xSwitch_Heating_II			:= adwCtlBits_UnitBaseCraft_Temp[iN].19;//: BIT;(*加热II档bit19*)
		pstStUnitParam_Save^.xSwitch_Heating_III			:= adwCtlBits_UnitBaseCraft_Temp[iN].20;//: BIT;(*加热III档bit20*)
		pstStUnitParam_Save^.xRsv_BIT21					:= adwCtlBits_UnitBaseCraft_Temp[iN].21;//: BIT;(*BIT21预留*)
		pstStUnitParam_Save^.xRsv_BIT22					:= adwCtlBits_UnitBaseCraft_Temp[iN].22;//: BIT;(*BIT22预留*)
		pstStUnitParam_Save^.xErrReset_Scraper			:= adwCtlBits_UnitBaseCraft_Temp[iN].23;//: BIT;(*刮刀故障复位bit23*)
		pstStUnitParam_Save^.xErrReset_InkRoller			:= adwCtlBits_UnitBaseCraft_Temp[iN].24;//: BIT;(*递墨故障复位bit24*)
		pstStUnitParam_Save^.xErrReset_Hotwind			:= adwCtlBits_UnitBaseCraft_Temp[iN].25;//: BIT;(*热风故障复位bit25*)
		pstStUnitParam_Save^.xErrReset_Hotwind_II		:= adwCtlBits_UnitBaseCraft_Temp[iN].26;//: BIT;(*热风2故障复位bit26*)
		pstStUnitParam_Save^.xErrReset_ExhAir			:= adwCtlBits_UnitBaseCraft_Temp[iN].27;//: BIT;(*排风故障复位bit27*)
		pstStUnitParam_Save^.xSwitch_ExhAir				:= adwCtlBits_UnitBaseCraft_Temp[iN].28;//: BIT;(*排风开关bit28*)
		pstStUnitParam_Save^.xInterver_ExhAir			:= adwCtlBits_UnitBaseCraft_Temp[iN].29;//: BIT;(*排风运行bit29*)
		pstStUnitParam_Save^.xRsv_BIT30					:= adwCtlBits_UnitBaseCraft_Temp[iN].30;//: BIT;(*BIT30预留*)
		pstStUnitParam_Save^.xSwitch_Coolwind			:= adwCtlBits_UnitBaseCraft_Temp[iN].31;//: BIT;(*冷风开关*)

		pstStUnitParam_Save^.rHz_UnitInkRoller_ManuallySet:= WORD_TO_REAL(astStParam_Mailbox_out[iN].wHz_UnitInkRoller_ManuallySet)/100.0    ;//递墨辊手动频率     
		pstStUnitParam_Save^.rCoeff_UnitInkRoller_Auto:= WORD_TO_REAL(astStParam_Mailbox_out[iN].wCoeff_UnitInkRoller_Auto)/100.0         ;//递墨辊自动系数     
		pstStUnitParam_Save^.rHz_UnitScraper_ManuallySet:= WORD_TO_REAL(astStParam_Mailbox_out[iN].wHz_UnitScraper_ManuallySet)/100.0       ;//刮刀手动频率      
		pstStUnitParam_Save^.rCoeff_UnitScraper_Auto:= WORD_TO_REAL(astStParam_Mailbox_out[iN].wCoeff_UnitScraper_Auto)/100.0           ;//刮刀自动系数      
		pstStUnitParam_Save^.rHz_UnitHotWind_ManuallySet:= WORD_TO_REAL(astStParam_Mailbox_out[iN].wHz_UnitHotWind)/100.0                   ;//热风频率        
		pstStUnitParam_Save^.rHz_UnitHotWind_2_ManuallySet:= WORD_TO_REAL(astStParam_Mailbox_out[iN].wHz_UnitHotWind_2)/100.0                 ;//热风2频率       
		pstStUnitParam_Save^.rSV_UnitTemCtl:= WORD_TO_REAL(astStParam_Mailbox_out[iN].wSV_UnitTemCtl)/100.0                   ;//加热设定温度      
		pstStUnitParam_UnSave^.wUnit_output_I:= astStParam_Mailbox_out[iN].wUnit_output_I                   ;//IO监控输出1     
		pstStUnitParam_UnSave^.wUnit_output_II:= astStParam_Mailbox_out[iN].wUnit_output_II                  ;//IO监控输出2 
		//xi.hy//增加 
		pstStUnitParam_Save^.bySignalSelect:= astStParam_Mailbox_out[iN].bySignalSelect;   
		pstStUnitParam_Save^.rOffset_T1:= astStParam_Mailbox_out[iN].rOffset_T1             				;//T1路光纤电眼偏移控制 
		pstStUnitParam_Save^.rSource_Light_T1:= astStParam_Mailbox_out[iN].rSource_Light_T1                ;//T1路光纤电眼光源控制 
		pstStUnitParam_Save^.rBias_T1:= astStParam_Mailbox_out[iN].rBias_T1								;//T1路光纤电眼偏置控制
		pstStUnitParam_Save^.rBrightness_Light_T1:= astStParam_Mailbox_out[iN].rBrightness_Light_T1        ;//T1路光纤电眼亮度控制 
		
		pstStUnitParam_Save^.rOffset_T2:= astStParam_Mailbox_out[iN].rOffset_T2             				;//T2路光纤电眼偏移控制 
		pstStUnitParam_Save^.rSource_Light_T2:= astStParam_Mailbox_out[iN].rSource_Light_T2                ;//T2路光纤电眼光源控制 
		pstStUnitParam_Save^.rBias_T2:= astStParam_Mailbox_out[iN].rBias_T2								;//T2路光纤电眼偏置控制
		pstStUnitParam_Save^.rBrightness_Light_T2:= astStParam_Mailbox_out[iN].rBrightness_Light_T2        ;//T2路光纤电眼亮度控制 
		//2026.02.05.161226 新增 Hou.N
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].0:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.0;//版辊操作侧靠近
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].1:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.1;//版辊操作侧远离
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].4:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.2;//版辊平行靠近
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].5:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.3; //版辊平行远离
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].2:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.4;//版辊传动侧靠近
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].3:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.5;//版辊传动侧远离


//2026.02.10.143913|新增
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].16:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.12; //版辊标定
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].16:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.13;//网辊标定
	//	pstStUnitParam_UnSave^.adwPressureMotor_Move[3].16:=astStParam_Mailbox_out[iN].dwSlaveBtn_HMI.14;//张带棍标定
		
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].10:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.15; //版辊合压
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].8:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.0;//版辊离压
		IF  astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.0 OR astStParam_Mailbox_out[iN].wSlaveBtn_HMI.15 THEN
			aiTime1[4]:= aiTime1[4]+1;
		END_IF

		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].9:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.3;//版辊换版
	//2026.02.23.133406 新增
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].14:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.5;//自动换版
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].15:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.6;//换版完成
		pstStUnitParam_UnSave^.adwPressureMotor_Move[1].19:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.7;//显示换版状态
		
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].0:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.6;//网辊操作侧靠近
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].1:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.7;//网辊操作侧远离
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].4:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.8;//网辊平行靠近
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].5:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.9;//网辊平行远离
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].2:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.10;//网辊传动侧靠近
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].3:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI.11;//网辊传动侧远离
		
		IF astStParam_Mailbox_out[iN].wSlaveBtn_HMI.6 THEN
			g_aiTestBtn[In]:= g_aiTestBtn[In] +1;			
		END_IF
		IF astStParam_Mailbox_out[iN].wSlaveBtn_HMI.7 THEN
			g_aiTestBtn1[In]:= g_aiTestBtn1[In] +1;			
		END_IF		
		
		IF astStParam_Mailbox_out[iN].wSlaveBtn_HMI.8 THEN
			g_aiTestBtn2[In]:= g_aiTestBtn2[In] +1;			
		END_IF
		
		IF astStParam_Mailbox_out[iN].wSlaveBtn_HMI.9 THEN
			g_aiTestBtn3[In]:= g_aiTestBtn3[In] +1;			
		END_IF		
		
		IF astStParam_Mailbox_out[iN].wSlaveBtn_HMI.10  THEN
			g_aiTestBtn4[In]:= g_aiTestBtn4[In] +1;			
		END_IF
		IF astStParam_Mailbox_out[iN].wSlaveBtn_HMI.11 THEN
			g_aiTestBtn5[In]:= g_aiTestBtn5[In] +1;			
		END_IF		
		

		
	//2026.02.10.143913|新增		
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].10:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.1;//网辊合压
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].8:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.2;//网辊离压
		pstStUnitParam_UnSave^.adwPressureMotor_Move[2].9:=astStParam_Mailbox_out[iN].wSlaveBtn_HMI2.4;//网辊换版
		
	//2026.03.11.101506 Hou.N +
		g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Net:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.0;//匀墨
		g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Prn:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.9;//版辊单动
		g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Bottom:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.10;//底辊单动
	
		g_stStSysParam.astStRSV_UnitParam_UnSave[iN].rStep_Horz:= INT_TO_REAL(astStParam_Mailbox_out[iN].iStep_Horz_Use)/100.0;
		g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xBtn_FromHMI_HorMove_M:= astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.14;
		g_stStSysParam.astStRSV_UnitParam_UnSave[iN].xBtn_FromHMI_HorMove_G:= astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.13;
	
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.1:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.1;//网辊锁轴
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.2:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.2;//充气
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.3:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.3;//墨盘电磁阀升
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.4:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.4;//照明
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.11:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.11;//合压
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.12:=astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.12;//离压

	pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.5:= FALSE;
	pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.6:= FALSE;
	pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.7:= FALSE;
	
		//xi.hy
		//IF(awState_FiberMove_bak[iN]<>astStParam_Mailbox_out[iN].wState_FiberMove) THEN
			pstStRSVUnitParam_UnSave^.wState_FiberMove:=astStParam_Mailbox_out[iN].wState_FiberMove;
		//	awState_FiberMove_bak[iN]:=astStParam_Mailbox_out[iN].wState_FiberMove;
	//	END_IF

		pstStRSVUnitParam_UnSave^.uiFiberMoveAlarm:=astStParam_Mailbox_out[iN].wAlarm_FiberMove;
		pstStRSVUnitParam_UnSave^.rFiberMoveDistanceIn:=INT_TO_REAL(astStParam_Mailbox_out[iN].iFiberMoveDistanceIn)/10.0;
		pstStRSVUnitParam_UnSave^.rFiberMovePosCur:=INT_TO_REAL(astStParam_Mailbox_out[iN].iPosCur_FiberMove)/10.0;
		pstStRSVUnitParam_UnSave^.rWidth_FindMarkCenter:=INT_TO_REAL(astStParam_Mailbox_out[iN].iWidth_FindMarkCenter)/100.0;
	
		//2026.04.28.133209 xi.hy新增@七号开始
		pstStRSVUnitParam_UnSave^.iStsSlave_FiberMove:=astStParam_Mailbox_out[iN].iStsSlave_FiberMove;
		//2026.05.28.181905
		pstStRSVUnitParam_UnSave^.rFiberMoveBasePosFromSlave:=INT_TO_REAL(astStParam_Mailbox_out[iN].iFiberMoveBasePosFromSlave)/10.0;
	
		
IF  astStParam_Mailbox_out[iN].wButtonAndSwitch_ChaoXu.13 THEN
	aiTime[In]:= aiTime[In] +1;
END_IF	
	//2026.02.05.195231
	IF pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.11 THEN
		g_astStMcgsBtn_HMI[iN].xBtn_Press:= TRUE;
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.11 := FALSE;
	END_IF
	IF pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.12 THEN
		g_astStMcgsBtn_HMI[iN].xBtn_UnPress:= TRUE;
		pstStUnitParam_Save^.wButtonAndSwitch_ChaoXu.12 := FALSE;
	END_IF

		SysMemSet(adr(astStParam_Mailbox_out[iN]),0,sizeof(astStParam_Mailbox_out[iN]));
	END_IF
	

	//2025.11.14.172840  | + |延时6个周期请标志
	IF g_astStMcgsBtn_HMI[iN].xBtn_Inch THEN
		aiCntInch[iN] := aiCntInch[iN] + 1;
		IF aiCntInch[iN] > 5 THEN
			aiCntInch[iN] := 0;
			g_astStMcgsBtn_HMI[iN].xBtn_Inch := FALSE;
		END_IF
	ELSE
		aiCntInch[iN] := 0;
	END_IF
	
	IF g_astStMcgsBtn_HMI[iN].xBtn_Press THEN
		aiCntPress[iN] := aiCntPress[iN] + 1;
		IF aiCntPress[iN] > 10 THEN
			aiCntPress[iN] := 0;
			g_astStMcgsBtn_HMI[iN].xBtn_Press := FALSE;
		END_IF
	ELSE
		aiCntPress[iN] := 0;
	END_IF
	
	IF g_astStMcgsBtn_HMI[iN].xBtn_UnPress THEN
		aiCntUnPress[iN] := aiCntUnPress[iN] + 1;
		IF aiCntUnPress[iN] > 10 THEN
			aiCntUnPress[iN] := 0;
			g_astStMcgsBtn_HMI[iN].xBtn_UnPress := FALSE;
		END_IF
	ELSE
		aiCntUnPress[iN] := 0;
	END_IF


	//2026.08.06.203030+
	IF g_astStMcgsBtn_HMI[iN].xBtn_Stop THEN
		aiCntStop[iN] := aiCntStop[iN] + 1;
		IF aiCntStop[iN] > 5 THEN
			aiCntStop[iN] := 0;
			g_astStMcgsBtn_HMI[iN].xBtn_Stop := FALSE;
		END_IF
	ELSE
		aiCntStop[iN] := 0;
	END_IF
	
END_FOR
