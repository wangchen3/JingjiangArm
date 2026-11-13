(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a71bc1ba-0d27-4c34-8029-adc7fa974e9f
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

//2025.11.12.112108 | +
//KS_RstAxisListInf_V3(i_xEn:= TRUE, i_byMachineMode:= 1, i_pastStAxisIdListInf:= ADR(g_astStAxisIdListInf));

//2026.4.29.231357获取状态放在这里吧
iUpdateEncPosStart := gc_ResCount_Profile+iReadSts_Page*MAX_UNIT_NUM - 15;
iUpdateEncPosEnd := gc_ResCount_Profile+iReadSts_Page*MAX_UNIT_NUM - 15+15;


//2026.02.04.173710 | + | 对龙门编码器的处理放到后面的for循环吧，方便判断方向，这里不好判断方向,放到这里fo 
FOR iN:=1 TO g_iAxisNum_GantrayTrap BY 1 DO
		
	KS_GetAxisIdForMotByStation_Gantry(
		i_iStationId:= g_aiStationList_GantrayTrap[iN],
		i_piAxisId:= ADR(iAxisId), 
		i_piTypeId:= ADR(iTypeId), 
		i_piUnitId:= ADR(iUnitId), 
		i_piCoreId:= ADR(iCoreId), 
		i_piGroupId:= ADR(iGroupId), 
		i_piAdjAxisId:= ADR(iAdjAxisId), 
		i_pstStSysStationInf:= ADR(g_stStSysStationInf),
		i_pstStSysGantryAxisInf := ADR(g_stStSysGantryAxisInf));	
		
	//IF iUpdateEncPosStart <= ((iCoreId-1)* gc_ResCount_Profile +iAxisId) AND iUpdateEncPosEnd>((iCoreId-1)* gc_ResCount_Profile +iAxisId)  THEN
		IF iTypeId= TYPE_UNIT_PRN_PRESS_MASTER THEN
			g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] := LREAL_TO_LINT(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc);
			g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] + g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			axGantryAxisIsRev[iGroupId,1] := g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_M;
			
			IF g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc = 0 AND ((iCoreId-1)* gc_ResCount_Profile +iAxisId)=65 THEN
				g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := 0;
			END_IF
		ELSIF iTypeId= TYPE_UNIT_PRN_PRESS_G THEN
			g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] := LREAL_TO_LINT(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc);
			axGantryAxisIsRev[iGroupId,2] := g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller_Pressure_G ;
			IF axGantryAxisIsRev[iGroupId,1] <> axGantryAxisIsRev[iGroupId,2] THEN
				g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] - g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			ELSE
				g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] + g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			END_IF
		ELSIF iTypeId= TYPE_UNIT_NET_PRESS_MASTER THEN
			g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] := LREAL_TO_LINT(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc);
			g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] + g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			axGantryAxisIsRev[iGroupId,1] := g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_M;
	
		ELSIF iTypeId= TYPE_UNIT_NET_PRESS_G THEN
			g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] := LREAL_TO_LINT(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc);
			axGantryAxisIsRev[iGroupId,2] := g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller_Pressure_G ;
			IF axGantryAxisIsRev[iGroupId,1] <> axGantryAxisIsRev[iGroupId,2] THEN
				g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] - g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			ELSE
				g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] + g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			END_IF
		ELSIF iTypeId= TYPE_UNIT_STR_PRESS_MASTER THEN
			g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] := LREAL_TO_LINT(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc);
			g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] + g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			axGantryAxisIsRev[iGroupId,1] := g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_M;
		ELSIF iTypeId= TYPE_UNIT_STR_PRESS_G THEN
			g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] := LREAL_TO_LINT(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc);
			axGantryAxisIsRev[iGroupId,2] := g_stStSysParam.astStUnitParam_UnSave[iUnitId].xMotRev_StrRoller_Pressure_G ;
			IF axGantryAxisIsRev[iGroupId,1] <> axGantryAxisIsRev[iGroupId,2] THEN
				g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] - g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			ELSE
				g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId] + g_aliM_EncPos[(iCoreId-1)* gc_ResCount_Profile +iAxisId]);
			END_IF
		END_IF
	//END_IF
	
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc;
END_FOR

(*
FOR iN := 1 TO g_iAxisNum_All BY 1 DO
// 	KS_HY_GetAxisIdForMotByStation(
// 				i_aiStationList[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);	
	KS_GetAxisIdForMotByStation_V2(
		i_iStationId:= g_aiStationList_All[iN],
		i_piAxisId:= ADR(iAxisId), 
		i_piTypeId:= ADR(iTypeId), 
		i_piUnitId:= ADR(iUnitId), 
		i_piCoreId:= ADR(iCoreId), 
		i_piGroupId:= ADR(iGroupId), 
		i_piAdjAxisId:= ADR(iAdjAxisId), 
		i_pstStSysStationInf:= ADR(g_stStSysStationInf));				
				
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wVirtual_Sts			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].virtual_sts;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wNet_Status			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].net_status;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wErr_a_Count			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].err_a_count;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wErr_b_Count			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].err_b_count;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wBreakCnt				:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].break_cnt;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wMotor_Temperature	:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].motor_temperature;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wDriver_Temperature	:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].driver_temperature;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wBus_Vol				:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].bus_voltage;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].dwMotionSts			:= LREAL_TO_DWORD(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrMotionsts);
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Prf             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Prf;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc;
	//2026.05.08.225821 xi.hy新增@七号以后
	//g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/2;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc;
	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPrfAcc             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrAcc_Prf;

//	g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].dwDriverSts := adwDriverSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId];

//	iRead_UnitId := iRead_UnitId + 1;	
END_FOR
g_astStGetMotionSts[64].lrVel_Prf             := g_astMotionSts[64].lrVel_Prf/2;
*)
//2026.05.09.101013 | + | 将获取状态全部拿出来
FOR iN := 1 TO gc_ResCount_Profile BY 1 DO
	g_astStGetMotionSts[iN].wVirtual_Sts		:= astStStationSts[iN].virtual_sts;
	g_astStGetMotionSts[iN].wNet_Status			:= astStStationSts[iN].net_status;
	g_astStGetMotionSts[iN].wErr_a_Count		:= astStStationSts[iN].err_a_count;
	g_astStGetMotionSts[iN].wErr_b_Count		:= astStStationSts[iN].err_b_count;
	g_astStGetMotionSts[iN].wBreakCnt			:= astStStationSts[iN].break_cnt;
	g_astStGetMotionSts[iN].wMotor_Temperature	:= astStStationSts[iN].motor_temperature;
	g_astStGetMotionSts[iN].wDriver_Temperature	:= astStStationSts[iN].driver_temperature;
	g_astStGetMotionSts[iN].wBus_Vol			:= astStStationSts[iN].bus_voltage;
	g_astStGetMotionSts[iN].dwMotionSts			:= LREAL_TO_DWORD(g_astMotionSts[iN].lrMotionsts);
	g_astStGetMotionSts[iN].lrPos_Prf           := g_astMotionSts[iN].lrPos_Prf;
	g_astStGetMotionSts[iN].lrPos_Enc           := g_astMotionSts[iN].lrPos_Enc;
	g_astStGetMotionSts[iN].lrVel_Prf           := g_astMotionSts[iN].lrVel_Prf/2;
	g_astStGetMotionSts[iN].lrVel_Enc           := g_astMotionSts[iN].lrVel_Enc;
	g_astStGetMotionSts[iN].lrPrfAcc            := g_astMotionSts[iN].lrAcc_Prf;
END_FOR




FOR iN := 1 TO g_iAxisNum_All BY 1 DO
// 	KS_HY_GetAxisIdForMotByStation(
// 				i_aiStationList[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);	
	KS_GetAxisIdForMotByStation_V2(
		i_iStationId:= g_aiStationList_All[iN],
		i_piAxisId:= ADR(iAxisId), 
		i_piTypeId:= ADR(iTypeId), 
		i_piUnitId:= ADR(iUnitId), 
		i_piCoreId:= ADR(iCoreId), 
		i_piGroupId:= ADR(iGroupId), 
		i_piAdjAxisId:= ADR(iAdjAxisId), 
		i_pstStSysStationInf:= ADR(g_stStSysStationInf));				
				
	CASE iTypeId OF
		TYPE_UNIT_PRN(*色组版辊*):
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_PrnRoller:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_PrnRoller:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);
		TYPE_UNIT_BOTTOM(*色组底辊*):
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_BottomRoller:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_BottomRoller:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);					
		TYPE_UNIT_NET(*色组网辊*):
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_NetRoller:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_NetRoller:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);					
		TYPE_UNIT_PRN_PRESS_MASTER:(*色组版辊龙门主轴*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Prn_Press_M:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Prn_Press_M:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);					
		TYPE_UNIT_PRN_PRESS_G:(*色组版辊龙门从轴G侧*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Prn_Press_G:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Prn_Press_G:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);								
		TYPE_UNIT_NET_PRESS_MASTER:(*色组网辊龙门主轴*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Net_Press_M:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Net_Press_M:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);								
		TYPE_UNIT_NET_PRESS_G:(*色组网辊龙门从轴G侧*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Net_Press_G:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Net_Press_G:= 
					LREAL_TO_INT(g_astStGetMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);			
	END_CASE	
END_FOR

//2026.4.30.091822获取当前速度
g_stStSysParam.astStGrpParam_UnSave[1].rVel_Cur:= LREAL_TO_REAL(ABS(g_alrVel_VirtualAxis[1]*1000*60/GC_LRMOTORPPR*gc_rGirth_Master/MASTER_DRIVER_TIME));	

//2026.4.11.145204处理一下加速度输出和加加速度输出
IF NOT axInit_Vel[1] THEN
	axInit_Vel[1]:= TRUE;
	g_arCur_Jerk[1]:= 0;
//	arVel_Pre[1]:= 0;
	arVel_Pre_A[1]:= 0;
END_IF
IF g_stStSysParam.astStGrpParam_UnSave[1].rVel_Cur =0 THEN
	axInit_Vel[1]:= FALSE;
END_IF

g_arCur_A[1]:= g_alrPrfAcc_MasterAxis2[1]*gc_rGirth_Master/GC_LRMOTORPPR * 6 * 10000000;//m/min/s
g_arCur_Jerk[1]:= (g_arCur_A[1]-arVel_Pre_A[1])*1000/gc_TENSION_TSK_CYCLE_TIME;//m/min/s/s
arVel_Pre_A[1]:= g_arCur_A[1];


// iReadSts_Page:= 1;
// g_stStGetPrm.readCommandVarTableIndex := iReadSts_Page;
// g_stStGetPrm.readCount := 512;
// g_stStGetPrm.pVarValue := ADR(g_astMotionSts[1]);
//修改非阻塞方式 2025-12-10 by sjw
//2026.4.30.114538iRtn:=GTN_StartMcMultiFunction(1,0,0,ADR(stStSetPrm),ADR(g_stStGetPrm));
iRtn:=GTN_ReadHsBufData(1,1,ADR(g_astMotionSts[1]),512,ADR(diRealCount),ADR(udiClock));
// iReadSts_Page:= 1;
// g_stStGetPrm.readCommandVarTableIndex := iReadSts_Page;
// g_stStGetPrm.readCount := 512;
// g_stStGetPrm.pVarValue := ADR(g_astMotionSts[65]);
// //修改非阻塞方式 2025-12-10 by sjw
// iRtn:=GTN_StartMcMultiFunction(2,0,0,ADR(stStSetPrm),ADR(g_stStGetPrm));
iRtn:=GTN_ReadHsBufData(2,1,ADR(g_astMotionSts[65]),512,ADR(diRealCount_2),ADR(udiClock2));


iGantryTrapGroupId := 0;
FOR iGrp:= 1 TO 2 BY 1 DO
	IF iGrp=2 THEN
		EXIT;
	END_IF
	
	
	afbKS_FB_FilmSpdCtrl[iGrp](
		i_xEn:= TRUE,
		i_xFlag_Print:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_Print,
		i_pxFlag_FilmAccDecDone:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp].xFlag_FilmAccDecDone),
		i_rVel_Cur:= g_stStSysParam.astStGrpParam_UnSave[iGrp].rVel_Cur,
		i_iTimeFilmAcc:= 8,
		i_iTimeFilmDec:= 2,
		o_xEno=> ,
		o_rVel_Film=> g_stStSysParam.astStGrpParam_UnSave[iGrp].rVel_Film);

END_FOR


