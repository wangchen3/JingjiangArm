(*@CES
Name=Action_Normal_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=326a375d-3670-45b8-a59c-7c4d74be7079
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*动作处理完成后-输出处理*)
(*	g_aiGrpUnitNum: ARRAY [1..2] OF INT;
	g_aiGrpAxisList: ARRAY [1..2,1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	g_aiStepAdj: ARRAY [1..2,1..MAX_UNIT_NUM] OF INT;
*)
(**2026.5.8.111823主任务不参与调整量输出
FOR iGrp:=1 TO 2 BY 1 DO
	IF iGrp=2 THEN EXIT; END_IF
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		aiGrpAxisList[iN]:= g_aiGrpAxisList[iGrp,iN];
		aiStepAdj[iN]:= g_aiStepAdj[iGrp,iN];
	END_FOR
	afbKS_FB_AdjOutCtl[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_iGrpUnitNum:= g_aiGrpUnitNum[iGrp], 
		i_aiGrpAxisList:= aiGrpAxisList, 
		i_paiStepAdj:= ADR(aiStepAdj), 
		i_pstStSysStationInf := ADR(g_stStSysStationInf),
		i_pastStInteraction := ADR(g_astStInteraction),		
		o_xEn=> , 
		o_iErNo=> 
	);
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		g_aiStepAdj[iGrp,iN]:= aiStepAdj[iN];
	END_FOR	
END_FOR
*)


//2026.4.12.134008增加接料湖面等逻辑|Niu.j|放料
FOR iGrp:=1 TO 2 BY 1 DO
(*2025.8.11.171610处理一下系IO索引/收放料收放牵*)
	
	IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.20 THEN
	(* 双收双放 *)
	
		IF g_stStSysParam.stStSysParam_Save.dwEquipmentProf.21 THEN
			(* A放B收 *)
			iId_Uw_IO:= 1;
			iId_Rw_IO:= 2;
			IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0 THEN
				iId_If_IO:= 1;
			END_IF
			IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.dwAxisProf.0 THEN
				iId_Of_IO:= 4;
			END_IF			
		ELSE
			(* A/B系各自用各自的 *)
			IF iGrp=1 THEN
				iId_Uw_IO:= 1;
				iId_Rw_IO:= 1;
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0 THEN
					iId_If_IO:= 1;
				END_IF
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.dwAxisProf.0 THEN
					iId_Of_IO:= 2;
				END_IF					
			ELSE
				iId_Uw_IO:= 2;
				iId_Rw_IO:= 2;
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.dwAxisProf.0 THEN
					iId_If_IO:= 3;
				END_IF
				IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.dwAxisProf.0 THEN
					iId_Of_IO:= 4;
				END_IF					
			END_IF
		END_IF
	ELSE(* 普通机型\只看A系 *)
		iId_Uw_IO:= 1;
		iId_Rw_IO:= 1;
		IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0 THEN
			iId_If_IO:= 1;
		END_IF
		IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.dwAxisProf.0 THEN
			iId_Of_IO:= 2;
		END_IF			
		IF iGrp=2 THEN
			EXIT;(*B系就不执行了吧*)
		END_IF
	END_IF
	(*提取弧面io信号2018.10.6.154255 by liu.yt*)
	IF g_stStSysParam.astStGrpParam_UnSave[iGrp].xCutterOnTop_Uw THEN
		IF g_stStSysParam.astStGrpParam_Save[iGrp].wUwRwAxisProf.0 THEN
			axSensor_Reflex[iGrp]:= g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].i_xSensor_Reflex_B_Up;//i_pstStEvtReq^.xEvt_Sensor_Reflex_Up_AxisB;
		ELSE
			axSensor_Reflex[iGrp]:= g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].i_xSensor_Reflex_A_Up;
		END_IF
	ELSE
		IF g_stStSysParam.astStGrpParam_Save[iGrp].wUwRwAxisProf.0 THEN
			axSensor_Reflex[iGrp]:= g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].i_xSensor_Reflex_B_Dn;
		ELSE
			axSensor_Reflex[iGrp]:= g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].i_xSensor_Reflex_A_Dn;
		END_IF
	END_IF
	//%QX52.1:=axSensor_Reflex[iGrp];
		
	(*2021.10.14.142525 增加了接料准备的调试逻辑*)
	axCutCtlEn[iGrp]:=g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_PreDrv_end_Uw AND
				 g_stStSysParam.astStGrpParam_UnSave[iGrp].xSts_PreCutting_Uw;
	arDiam_NewVol_Use[iGrp]:=g_stStSysParam.astStGrpParam_UnSave[iGrp].rDiam_NewVol_Uw;
	arVel_Predrv_Use[iGrp]:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rVel_PreDrv_Uw;
	IF g_stStSysParam.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.0 THEN(*放料调试*)
		(*2022.6.18.124949 更新了裁切功能块使能条件|确保到达对射电眼位置*)
		axCutCtlEn[iGrp]:=g_axLamp_PreDrive_Debug_Uw[iGrp] AND 
								g_axSts_Sensor1Ok[iGrp] AND 
								g_stStSysParam.astStGrpParam_UnSave[iGrp].xSts_PreCutting_Uw;(*预驱同步了就使能*)
		IF g_stStSysParam.astStGrpParam_Save[iGrp].wUwRwAxisProf.0 THEN(*当前轴为a|取b的值*)
			arDiam_NewVol_Use[iGrp]:=LREAL_TO_REAL(INT_TO_LREAL(g_stStSysParam.astStGrpParam_UnSave[iGrp].iDebugGirthmm_AxisB_Uw)/gc_lrPi);
			arVel_Predrv_Use[iGrp]:=g_stStSysParam.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisB_Uw;
		ELSE(*当前轴为b|取a的值*)
			arDiam_NewVol_Use[iGrp]:=LREAL_TO_REAL(INT_TO_LREAL(g_stStSysParam.astStGrpParam_UnSave[iGrp].iDebugGirthmm_AxisA_Uw)/gc_lrPi);
			arVel_Predrv_Use[iGrp]:=g_stStSysParam.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisA_Uw;
		END_IF
	END_IF
	
	aiDelayMsec_CutOffKnifeCylinder_Final[iGrp]:= 
			g_stStSysParam.astStGrpParam_Save[iGrp].astStTimeSet_DnCut_UpCut_Uw[BOOL_TO_INT(g_stStSysParam.astStGrpParam_UnSave[iGrp].xCutterOnTop_Uw)].iDelayMsec_CutOffKnifeCylinder;
	aiDelayMsec_RollerCylinder_Final[iGrp]:=
			g_stStSysParam.astStGrpParam_Save[iGrp].astStTimeSet_DnCut_UpCut_Uw[BOOL_TO_INT(g_stStSysParam.astStGrpParam_UnSave[iGrp].xCutterOnTop_Uw)].iDelayMsec_RollerCylinder;
	afbKS_FB_CutDelay_CTL_Uw[iGrp](
		i_xEn:=axCutCtlEn[iGrp],
		i_xUseTime:= FALSE,(*使用计圈延时*)
		i_rDelayTimeMs:= ,
		i_rCoef_FilmVolPerimeter:= g_stStSysParam.astStGrpParam_Save[iGrp].rCoefCut_FilmVolPerimeter_Uw,
		i_rDiam_New:= (*pstStGrpParam^.lrDiam_NewVol_Uw*)arDiam_NewVol_Use[iGrp],
		//i_pstStGrpParam:= pstStGrpParam,
		i_pstStTimeSet_DnCut_UpCut:= ADR(g_stStSysParam.astStGrpParam_Save[iGrp].astStTimeSet_DnCut_UpCut_Uw[BOOL_TO_INT(g_stStSysParam.astStGrpParam_UnSave[iGrp].xCutterOnTop_Uw)]),
		i_xReq_Cut:= g_axReqCut_Uw[iGrp],
		i_rVel_PreDrv:= arVel_Predrv_Use[iGrp](*pstStGrpParam^.lrVel_Predrv_Uw*),(*2021.10.14.142258 修改为预驱速度*)
		i_xReflectionSensorIO:= axSensor_Reflex[iGrp],
		i_xCutUseReflectionSensor:= g_stStSysParam.astStGrpParam_Save[iGrp].xCutUseReflectionSensor_Uw,
		i_iCycleTime_Plc:= gc_MAIN_TSK_CYCLE_TIME,
		o_xEno=> ,
		o_iErNo=> ,
		o_xRollerCylinderOutput=> axOutput_CutCylinder[iGrp],
		o_xCut_ing=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Cut_ing_Uw_UseInOtherPrg,

		o_xReflectSensorLoss=>g_stStSysParam.astStGrpParam_UnSave[iGrp].xReflectSensorLoss_Uw(*弧面信号丢失|2020.10.9.103839*),
		o_xReflectionSensorValid=> g_stStSysParam.astStGrpParam_UnSave[iGrp].xReflectionSensorValid_Uw,(*2019.11.29.174022_*)
		o_iCutTotalTime=>aiCutTotalTime[iGrp],(*2022.5.4.170313+这是胶辊的延时还需要加上裁刀的延时时间*)
		o_xCutSenSorDelay=>g_xCutSenSorDelay);
		IF aiCutTotalTime[iGrp]<>0 THEN
			aiCutTotalTime[iGrp]:=aiCutTotalTime[iGrp]+aiDelayMsec_CutOffKnifeCylinder_Final[iGrp];
		END_IF
		
//2026.4.12.141556
	g_axReqCut_Uw[iGrp]:= FALSE;
	

	IF g_stStSysParam.astStGrpParam_UnSave[iGrp].xCutterOnTop_Uw THEN
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_xCutCylinder_UpCut:= axOutput_CutCylinder[iGrp];
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_xCutter_UpCut:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Cut_ing_Uw_UseInOtherPrg;

// 		i_pstStEvtReq^.xOutCutCylinder_Up:= xOutput_CutCylinder;
// 		i_pstStEvtReq^.xOutCutter_Up:= xFlag_Cut_ing_Out;
	ELSE
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_xCutCylinder_DnCut:= axOutput_CutCylinder[iGrp];
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_xCutter_DnCut:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Cut_ing_Uw_UseInOtherPrg;		

// 		i_pstStEvtReq^.xOutCutCylinder_Dn:= xOutput_CutCylinder;
// 		i_pstStEvtReq^.xOutCutter_Dn:= xFlag_Cut_ing_Out;
	END_IF
	
	(*上面逻辑会使用，不能在完成的这个周期清除切记！@2024.05.14.153626*)
	IF aiDelayMsec_CutOffKnifeCylinder_Final[iGrp]=0 THEN
		aiDelayMsec_CutOffKnifeCylinder_Final[iGrp]:= 100;
	END_IF
	afbTon_DelayTimer_CutOffKnifeCylinder_Uw[iGrp](
		IN:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Cut_ing_Uw_UseInOtherPrg,

		PT:= INT_TO_TIME(aiDelayMsec_CutOffKnifeCylinder_Final[iGrp]));
		
	afbTrig_DelayTimer_CutOffKnifeCylinder_Uw[iGrp](CLK:=afbTon_DelayTimer_CutOffKnifeCylinder_Uw[iGrp].Q);//2026.05.25.155000+
	IF afbTrig_DelayTimer_CutOffKnifeCylinder_Uw[iGrp].Q THEN
		g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Cut_end_Uw_UseInOtherPrg:= TRUE;
		//2026.06.02.223952+裁切完成后置位
		g_axTell_KS_FB_AvoidSomeFilmWithoutAdjust_CuttDne[iGrp]:=TRUE;
	END_IF
	g_axTell_KS_PreDrv_CTL_Uw_CuttDne[iGrp]:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Cut_end_Uw_UseInOtherPrg;



	
	(*2020.5.13.085938 控制放料接料时取消转矩功能*)
	axTorqueCancel[iGrp]:=KS_PreCut_Torqe(
						(*2020.5.13.085932 先看下在裁切完后直接恢复力矩会有什么风险吗？*)
						FALSE(*xPreDrvAxis_Releasing_Uw*)(*i_xPreDrvAxisRunning*),
						axOutput_CutCylinder[iGrp],(*i_xRoller_Cut,*)
						aiDelayMsec_RollerCylinder_Final[iGrp](*i_iRoller_DelayTime*),
						gc_MAIN_TSK_CYCLE_TIME(*i_iPlcCycleTime*),
						ADR(aiTimeCnt[iGrp])(*i_piTimeCnt*));
	
	
	afbRTrig_Sts_Precuting[iGrp](CLK:=g_stStSysParam.astStGrpParam_UnSave[iGrp].xSts_PreCutting_Uw);
	IF afbRTrig_Sts_Precuting[iGrp].Q THEN (*接料准备过程中|我们确定需要取消转矩的轴*)
		axNeedTorqueCancel[iGrp]:= g_stStSysParam.astStGrpParam_Save[iGrp].wUwRwAxisProf.0;
	END_IF
	
	
	IF axNeedTorqueCancel[iGrp] THEN(*放料需要取消转矩的轴为A轴*)
		axAxisATorqueCancel_Out[iGrp]:=axTorqueCancel[iGrp];
 		axAxisBTorqueCancel_Out[iGrp]:=FALSE;
	ELSE(*放料需要取消转矩的轴为B轴*)
		axAxisATorqueCancel_Out[iGrp]:=FALSE;
		axAxisBTorqueCancel_Out[iGrp]:=axTorqueCancel[iGrp];
	END_IF
	
	
	
	
	(* 2020.9.28.094352|补充进来|liu.yt指导  *)
	(*转矩取消状态赋值到功能块变量2020.6.29.114342*)
	g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_xAxisATorqueCancel:=axAxisATorqueCancel_Out[iGrp];
	g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_xAxisBTorqueCancel:=axAxisBTorqueCancel_Out[iGrp];
	(*输出模拟量*)
	IF axAxisATorqueCancel_Out[iGrp] THEN(*取消有效|转矩为0*)
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_wAxisATorqueVolt:= 0;
		//i_pstStEvtReq^.wOutAxisATorqueVolt:=0;
	ELSE
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_wAxisATorqueVolt:= 32767;
		//i_pstStEvtReq^.wOutAxisATorqueVolt:=32767;(*10v*)
	END_IF
	IF axAxisBTorqueCancel_Out[iGrp] THEN(*取消有效|转矩为0*)
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_wAxisBTorqueVolt:= 0;
		//i_pstStEvtReq^.wOutAxisBTorqueVolt:=0;
	ELSE
		g_astStIOMap_UwRw_FE_Uw[iId_Uw_IO].o_wAxisBTorqueVolt:= 32767;
		//i_pstStEvtReq^.wOutAxisBTorqueVolt:=32767;(*10v*)
	END_IF	
END_FOR
//2026.4.12.134032

aliTime_Value[8]:= LTIME();

(*绝对值编码器*)
fbKS_AbsEncModule_IODeal(
	i_xInputEn:= FALSE, 
	i_xOutPutEn:= TRUE, 
	i_pdwAbsEncSinglePos_Uw:= ADR(g_dwAbsEncSinglePos_Uw), 
	i_pwAbsEncMultiPos_Uw:= ADR(g_wAbsEncMultiPos_Uw), 
	i_pdwAbsEncSinglePos_Rw:= ADR(g_dwAbsEncSinglePos_Rw), 
	i_pwAbsEncMultiPos_Rw:=ADR(g_wAbsEncMultiPos_Rw),
	i_pstStAbsEncIOModule_Uw:=ADR(g_stStAbsEncIOModule_Uw),
	i_pstStAbsEncIOModule_Rw:=ADR(g_stStAbsEncIOModule_Rw)
	 );
fbKS_FB_StepDriveCTL(
	i_xEn:= TRUE,
	i_iUMax:= g_stStSysParam.stStSysParam_Save.iUnitMaxNum,(*2024.01.16.124051+*)
	i_pastStDigitalMicroStepDrive:= ADR(g_astStDigitalMicroStepDrive),
	i_iAccTime_ms:= 50,
	o_xEn=> ,
	o_iErrCode=> );
	
	
fbKS_FB_IOConfig(
	i_xEn:= TRUE, 
	i_xRdInput:= FALSE, 
	i_xWrOutput:= TRUE, 
//	i_iCustomerId:= g_stStSysParam.stStSysParam_Save.iCustomerId, 
	i_pstStSysParam := ADR(g_stStSysParam),
	i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
	i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
	i_pastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
	i_pastStIOMap_UwRw_FE_Uw:= ADR(g_astStIOMap_UwRw_FE_Uw), 
	i_pastStIOMap_UwRw_FE_Rw:= ADR(g_astStIOMap_UwRw_FE_Rw), 

	i_pastStProgMonitoring := ADR(g_astStProgMonitoring),
	i_dwInput_IO_GNS_P6P8:= g_dwInput_IO_GNS_P6P8,
	i_dwInput_IO_GNS_P4P3:= g_dwInput_IO_GNS_P4P3,
	
	o_xEno=> , 
	o_iErNo=> ,
	o_dwOutput_IO_GNS_P5P7=> g_dwOutput_IO_GNS_P5P7);

// fbKS_FB_GNS_IOCtl(
// 	i_xEn:= TRUE, 
// 	i_xUseIO_FromGNS_Enable:= g_xUseIO_FromGNS_Enable, 
// 	i_xRdEn:= FALSE, 
// 	i_xWrEn:= TRUE, 
// 	i_padiGNSIO_Input:= ADR(adiGNSIO_Input), 
// 	i_pdiGNSIO_Output:= ADR(g_dwOutput_IO_GNS_P5P7), 
// 	o_xEn=> , 
// 	o_iErNo=>
// 	);

	
(*增加从站人机IO监控界面赋值2025.11.15.111647|niu.j*)
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	(*IO测试*)
	(*2023.11.08.144546 同步*)
	(*2023.10.16.172720/wei.n/主站、ARM与7寸人机色组IO通讯-单向*)
	(*色组输入I*)
	KS_SetWordBit(0,	g_astStIOMap_Axis_FE[iN].i_xLinkage,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(1,	g_astStIOMap_Axis_FE[iN].i_xInch,  				ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(2,	g_astStIOMap_Axis_FE[iN].i_xEstop,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(3,	g_astStIOMap_Axis_FE[iN].i_xAlarmBell, 			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(4,	g_astStIOMap_Axis_FE[iN].i_xLittleAdj,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(5,	g_astStIOMap_Axis_FE[iN].i_xPressMode_Auto, 	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(6,	g_astStIOMap_Axis_FE[iN].i_xPress,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(7,	g_astStIOMap_Axis_FE[iN].i_xUnPress,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(8,	g_astStIOMap_Axis_FE[iN].i_xUnPress_Inching,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(9,	g_astStIOMap_Axis_FE[iN].i_xMove_Up,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(10,	g_astStIOMap_Axis_FE[iN].i_xMove_Down,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(11,	g_astStIOMap_Axis_FE[iN].i_xPosLimit_Left,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(12,	g_astStIOMap_Axis_FE[iN].i_xMove_Left,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	(*2025.10.20.093424+横向报警输入*)
	KS_SetWordBit(13,	g_astStIOMap_Axis_FE[iN].i_xHorzMotor_Alarm,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));
	KS_SetWordBit(15,	g_xIODebugging,  								ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_I));


	(*色组输入II*)
	KS_SetWordBit(0,	g_astStIOMap_Axis_FE[iN].i_xMove_Right,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(1,	g_astStIOMap_Axis_FE[iN].i_xPosLimit_Right,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(2,	g_astStIOMap_Axis_FE[iN].i_xHorzMotor_FastSpd,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(3,	g_astStIOMap_Axis_Extra_FE[iN].i_xCoolBlower,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(4,	g_astStIOMap_Axis_Extra_FE[iN].i_xCoolBlower_Button,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(5,	g_astStIOMap_Axis_Extra_FE[iN].i_xHotBlower_Err,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(6,	g_astStIOMap_Axis_Extra_FE[iN].i_xHotBlower,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(7,	g_astStIOMap_Axis_Extra_FE[iN].i_xHotBlower_Button,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(8,	g_astStIOMap_Axis_Extra_FE[iN].i_xTemReachToTarget,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(9,	g_astStIOMap_Axis_Extra_FE[iN].i_xHeating_I,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(10,	g_astStIOMap_Axis_Extra_FE[iN].i_xHeating_II,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(11,	g_astStIOMap_Axis_Extra_FE[iN].i_xHeating_III,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));
	KS_SetWordBit(12,	g_astStIOMap_Axis_Extra_FE[iN].i_xHeating_Button,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_II));


	(*色组输入III*)
	KS_SetWordBit(0,	g_astStIOMap_Axis_Extra_FE[iN].i_xScraperInveterError,  ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(1,	g_astStIOMap_Axis_Extra_FE[iN].i_xScraperOn,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(2,	g_astStIOMap_Axis_Extra_FE[iN].i_xAirExhaustSwitch,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(3,	g_astStIOMap_Axis_Extra_FE[iN].i_xInkRoller_CW,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(4,	g_astStIOMap_Axis_Extra_FE[iN].i_xInkRoller_Up,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(5,	g_astStIOMap_Axis_Extra_FE[iN].i_xAirExhaustButton,  	ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(6,	g_astStIOMap_Axis_FE[iN].i_xAcc,  					ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(7,	g_astStIOMap_Axis_FE[iN].i_xDec,  					ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(8,	g_astStIOMap_Axis_FE[iN].i_xStop,  				ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
//	KS_SetWordBit(9,	g_astStIOMap_Axis_FE[iN].i_xFastStop,  			ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(10,	g_astStIOMap_Axis_FE[iN].i_xPtcSignal,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));
	KS_SetWordBit(11,	g_astStIOMap_Axis_FE[iN].i_xLostPressure,  		ADR(g_stStSysParam.astStUnitParam_UnSave[iN].wUnit_input_III));

END_FOR


