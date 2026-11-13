(*@CES
Name=KS_FB_Func_If
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=396ed0e2-8ecf-47df-835c-9b592e8522ae
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Func_If
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_rAi_Swing: REAL;
	i_xIsDebugMode: BOOL;
	i_xMachineRev: BOOL;
	i_rVel_Film: REAL;
	i_rVel_Max: REAL;
	i_iCycleTime_Plc: INT;
	i_iIndex_MainIO_If: INT;
	i_pastStIOMap_Main_FE					: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)		
	i_pstStSysParam: POINTER TO StSysParam;
END_VAR
VAR_OUTPUT
	
END_VAR
VAR
	rActualGirth_In		: REAL;(*默认周长*)
	xRollerPressDone_In	: BOOL;(*压辊完成*)
	xSwitchTension_In	: BOOL;(*调整算法切换|TRUE:pid|FALSE:算周长*)
	xFlag_Accing_In		: BOOL;(*加速标志*)
	xFlag_Decing_In		: BOOL;(*加速标志*)
	xCompensateWhenAccing_In 		: BOOL;(*补偿开关*)
	rCompensateGirthWhenAccing_In	: REAL;(*补偿值*)
	xRollerSts_IfOf_In								: BOOL;(*收放牵压辊状态*)
	xFilmAccDecDone_In				: BOOL;
	iTimeTo0WhenDisEn_In			: INT;
	arKpid_IfOf_In					: ARRAY [1..3] OF REAL;
	byVelLimit_PerCent_In			: BYTE;
	iFeedLimitWarnCoff_In			: INT;
	xFeedlimitWarnFlag_In			: BOOL;
	uiMaxVel_UseCalcAcc_In			: UINT;
	rPseudoRandomRoundAmplitude_Cur_In			: REAL;(*伪随机序列*)
	xPseudoRandomEn_In							: BOOL;(*伪随机测试按钮*)
	xPseudoRandomId_In							: BOOL;(*放料伪随机使能*)
	xPseudoRandomTsting_In						: BOOL;
	aiTestKp_In									: ARRAY [1..3] OF INT;(*伪随机P值*)
	aiTestKd_In									: ARRAY [1..3] OF INT;(*伪随机D值*)
	xPidType_In									: BOOL;
	xUseAntiNotch_In							: BOOL;
	xEn_Disturbance_In							: BOOL;
	rFreq_Disturbance_In: REAL;
	rAmplitude_Disturbance_In: REAL;
	uiTotalTime_Disturbance_In: UINT;
	xFlag_RollerPressAtLeast1_In: BOOL;
	rN_In										: REAL;
	rMpa_In										: REAL;
//2025.12.30.103448
	xClrAlarmInf_In: BOOL;(*报警清除输入*)
	xFlag_Ink_In: BOOL;
	xFlag_Stop_In: BOOL;
	xFlag_Tension_In: BOOL;
	xInchBtn_In: BOOL;
	xInchType_In: BOOL;
	xInchDir_In: BOOL;
	iInchVel_In: INT;
	xFlag_Print_In: BOOL;
	xInverterAlarm_IO_In: BOOL;
	iRatedRpm_In: INT;
	iRatedFrq_In: INT;
	iUpperFrq_In: INT;
	uiNum_In: UINT;
	uiDen_In: UINT;	
	
	
	xGirthCalFinish_Out: BOOL;
	rUsingGirth_Out: REAL;
	rVel_Cur_Out	: REAL;
	rPi_Value_Out: REAL;
	rForwardStep_Out: REAL;
	rVel_rpm_Out: REAL;
	xOuting_sin_Out: BOOL;
	rResult_sin_Out: REAL;
//2025.12.30.103455	
	xInverterAlarm_Out: BOOL;(*变频报警输出*)
	xInch_Out: BOOL;
	xInverterResetIO_Out: BOOL;
	wAO_Inverter_Out: WORD;
	rAO_Inverter_Out: REAL;
	wAO_FilmVel_Out: WORD;
	rAO_VelFilm_Out: REAL;
	xInverter_Cw_Out: BOOL;
	xAdjustEn_Out: BOOL;
	
	
	byInitTaper_In_Out:BYTE ;(*: POINTER TO BYTE;*)
	rInitTaper_Hmi_In_Out:REAL ;(*: POINTER TO REAL;*)	
	bySetTestPid_In_Out: BYTE;
	rWn_In_Out			: REAL;
	rBw_In_Out			: REAL;
	rDp_In_Out			: REAL;
	xTaperUnitType_In_Out					: BOOL;
	byTaperUnit_In_Out						: BYTE;
	byTaperUnitConfirm_In_Out				: BYTE;
	rPercentMatchN_In_Out					: REAL;
	rPercentMatchMpa_In_Out					: REAL;
	rTaperValueBegin_Hmi_In_Out				: REAL;
	rTaperValueEnd_Hmi_In_Out				: REAL;
	rTaperValueCur_Hmi_In_Out				: REAL;
	rTaper_Begin_In_Out						: REAL;
	rTaper_End_In_Out						: REAL;
	rTaper_Cur_In_Out						: REAL;
	rTaperMax_In_Out						: REAL;

	
	iCycleNum_Delay: INT;
	iCycleNum_AI_Ave: INT;
	xInit_Taper_Cur: BOOL;
	iTimeTaperChange:INT:=10000;(*锥度变化时间|ms*)
	rTaperTar: REAL;
	rTaperCur: REAL;
	rDeltTaper: REAL;
	xInverterAlarmIO: BOOL;
	xInverterReset: BOOL;
	xCanClrAlarmInf: BOOL;
	xInchEn: BOOL;
	xInch: BOOL;
	xInchDir: BOOL;
	iInchVel: INT;
	xInverter_Cw: BOOL;
		
	fbKS_FB_CalcGirthLogic: KS_FB_CalcGirthLogic_IfOf;
	fbKS_FB_CalcGirthByVel: KS_FB_CalcGirthByVel_IfOf;
	//2026.04.09.200905 替换
	//fbKS_FB_Tension: KS_FB_TensionCtl_IfOf;
	fbKS_FB_Tension: KS_FB_TensionCtl_IfOf_V2;
	fbKS_FB_TaperUnitDeal: KS_FB_TaperUnitDeal_New;
	fbTrig_Inch:R_TRIG;
	fbKS_FB_VelocityToVoltage_IfOf: KS_FB_VelocityToVoltage_IfOf;	
END_VAR

{IMPLEMENTATION}
Action_Input();
(*张力计算*)
Action_Tension();

Action_Taper();

(*IO 使能控制|变频自调控制*)
Action_InverterCtl();

Action_Output();