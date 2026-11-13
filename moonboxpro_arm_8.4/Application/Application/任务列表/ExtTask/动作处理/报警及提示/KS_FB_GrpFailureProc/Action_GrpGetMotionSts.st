(*@CES
Name=Action_GrpGetMotionSts
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=2ae381f6-07d1-46ba-8557-6e3b08de70f4
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}


IF i_pstStSysParam^.stStSysParam_Save.dwEquipmentProf.3 THEN
	IF iReadSts_Page > 2 THEN
		iReadSts_Page := 1;
	END_IF
ELSE
	IF iReadSts_Page > 4 THEN
		iReadSts_Page := 1;
	END_IF
END_IF
alTime_Test[3]:= LTIME();

(*2026.4.29.231317读取全部放在另一个任务*)
(*
i_pstStGetPrm^.readCommandVarTableIndex := iReadSts_Page;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[iReadSts_Page*MAX_UNIT_NUM - 15]);
//修改非阻塞方式 2025-12-10 by sjw
iRtn:=GTN_StartMcMultiFunction(1,0,0,ADR(stStSetPrm),i_pstStGetPrm);
*)
//2025.12.19.133625 | 处理龙门的位置
//2025.12.19.110944 | 龙门相关
//2026.02.04.173710 | + | 对龙门编码器的处理放到后面的for循环吧，方便判断方向，这里不好判断方向
(*
FOR iN := (iReadSts_Page*MAX_UNIT_NUM - 15) TO (iReadSts_Page*MAX_UNIT_NUM - 15+15) BY 1 DO
	g_aliM_EncPos[iN] := LREAL_TO_LINT(g_astMotionSts[iN].lrPos_Enc);
	g_astMotionSts[iN].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[iN] + g_aliM_EncPos[iN]);
END_FOR
*)
// g_aliM_EncPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId] := LREAL_TO_LINT(g_astMotionSts[(iCoreId-1) * gc_ResCount_Profile + iAxisId].lrPos_Enc);
// g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId] + g_aliM_EncPos[(iCoreId-1) * gc_ResCount_Profile + iAxisId]);



(*
IF axDoneGet[1] (*= TRUE AND axBusyGet[1] = FALSE*) THEN
// 	axExecute[1] := TRUE;
// ELSE
	axExecute[1] := NOT axExecute[1];
END_IF

aFB_Get_StartMcMUltiFunction[1](
	Execute:= axExecute[1], 
	Block:= TRUE, 
	core:= 1, 
	axisCount:= 0, 
	writeEnable:= 0, 
	pSetPrm:= ADR(stStSetPrm), 
	pGetPrm:= i_pstStGetPrm, 
	Done=> axDoneGet[1], 
	Busy=> axBusyGet[1], 	
	Error=> axErrorGet[1], 
	ErrorID=> aiErrorIdGet[1]);
*)
(*2026.04.20.191606暂时不用读核2内容*)
(*i_pstStGetPrm^.readCommandVarTableIndex := iReadSts_Page;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[gc_ResCount_Profile+iReadSts_Page*MAX_UNIT_NUM - 15]);
iRtn:=GTN_StartMcMultiFunction(2,0,0,ADR(stStSetPrm),i_pstStGetPrm);
*)
//2026.02.04.173710 | + | 对龙门编码器的处理放到后面的for循环吧，方便判断方向，这里不好判断方向

(*2026.4.29.232111||这部分先不放这里
iUpdateEncPosStart := gc_ResCount_Profile+iReadSts_Page*MAX_UNIT_NUM - 15;
iUpdateEncPosEnd := gc_ResCount_Profile+iReadSts_Page*MAX_UNIT_NUM - 15+15;

alTime_Test[5]:= LTIME();

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
		i_pstStSysStationInf:= i_pstStSysStationInf,
		i_pstStSysGantryAxisInf := ADR(g_stStSysGantryAxisInf));	
		
	IF iUpdateEncPosStart <= ((iCoreId-1)* gc_ResCount_Profile +iAxisId) AND iUpdateEncPosEnd>((iCoreId-1)* gc_ResCount_Profile +iAxisId)  THEN
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
	END_IF
	
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc;
END_FOR
*)
(*
FOR iN := gc_ResCount_Profile+iReadSts_Page*MAX_UNIT_NUM - 15 TO gc_ResCount_Profile+iReadSts_Page*MAX_UNIT_NUM - 15+15 BY 1 DO
	g_aliM_EncPos[iN] := LREAL_TO_LINT(g_astMotionSts[iN].lrPos_Enc);
	g_astMotionSts[iN].lrPos_Enc := LINT_TO_LREAL(g_aliTrapAbsPos[iN] + g_aliM_EncPos[iN]);
END_FOR
*)
(*
IF axDoneGet[2] (*= TRUE AND axBusyGet[2] = FALSE*) THEN
// 	axExecute[2] := TRUE;
// ELSE
	axExecute[2] := NOT axExecute[2];
END_IF

aFB_Get_StartMcMUltiFunction[2](
	Execute:= axExecute[2], 
	Block:= TRUE, 
	core:= 2, 
	axisCount:= 0, 
	writeEnable:= 0, 
	pSetPrm:= ADR(stStSetPrm), 
	pGetPrm:= i_pstStGetPrm, 
	Done=> axDoneGet[2], 
	Busy=> axBusyGet[2], 	
	Error=> axErrorGet[2], 
	ErrorID=> aiErrorIdGet[2]);
*)
iReadSts_Page := iReadSts_Page + 1;


(*
i_pstStGetPrm^.readCommandVarTableIndex := 2;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[17]);
iRtn:=GTN_StartMcMultiFunction(1,0,0,ADR(stStSetPrm),i_pstStGetPrm);

i_pstStGetPrm^.readCommandVarTableIndex := 3;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[33]);
iRtn:=GTN_StartMcMultiFunction(1,0,0,ADR(stStSetPrm),i_pstStGetPrm);

i_pstStGetPrm^.readCommandVarTableIndex := 4;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[49]);
iRtn:=GTN_StartMcMultiFunction(1,0,0,ADR(stStSetPrm),i_pstStGetPrm);

i_pstStGetPrm^.readCommandVarTableIndex := 1;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[65]);
iRtn:=GTN_StartMcMultiFunction(2,0,0,ADR(stStSetPrm),i_pstStGetPrm);

i_pstStGetPrm^.readCommandVarTableIndex := 2;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[81]);
iRtn:=GTN_StartMcMultiFunction(2,0,0,ADR(stStSetPrm),i_pstStGetPrm);

i_pstStGetPrm^.readCommandVarTableIndex := 3;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[97]);
iRtn:=GTN_StartMcMultiFunction(2,0,0,ADR(stStSetPrm),i_pstStGetPrm);

i_pstStGetPrm^.readCommandVarTableIndex := 4;
i_pstStGetPrm^.readCount := 80;
i_pstStGetPrm^.pVarValue := ADR(g_astMotionSts[113]);
iRtn:=GTN_StartMcMultiFunction(2,0,0,ADR(stStSetPrm),i_pstStGetPrm);
*)


IF iRead_UnitId > i_iGrpAllStationNum THEN
	iRead_UnitId := 1;
END_IF
(*
alTime_Test[1]:= LTIME();	
iRtn := GTN_GetDriverSts(1,((iReadDriverSts_Page-1)*8 + 1),ADR(adwDriverSts[((iReadDriverSts_Page-1)*8 + 1)]),8,ADR(adiClock[(iReadDriverSts_Page-1)*8 + 1]));
iRtn := GTN_GetDriverSts(2,((iReadDriverSts_Page-1)*8 + 1),ADR(adwDriverSts[gc_ResCount_Profile+((iReadDriverSts_Page-1)*8 + 1)]),8,ADR(adiClock[(iReadDriverSts_Page-1)*8 + 1]));
alTime_Test[2]:= LTIME();
iReadDriverSts_Page := iReadDriverSts_Page + 1;
IF iReadDriverSts_Page  > 8 THEN
	iReadDriverSts_Page := 1;
END_IF
*)
alTime_Test[6]:= LTIME();
(*2026.4.29.232737先屏蔽获取driversts逻辑
IF i_iGrpAllStationNum < gc_ResCount_Profile THEN
	iGetDriverStsAxis := iGetDriverStsAxis + 1;
	IF iGetDriverStsAxis > i_iGrpAllStationNum THEN
		iGetDriverStsAxis := 1;
	END_IF
	KS_GetAxisIdForMotByStation_V2(
		i_iStationId:= i_aiStationList[iGetDriverStsAxis],
		i_piAxisId:= ADR(iAxisId), 
		i_piTypeId:= ADR(iTypeId), 
		i_piUnitId:= ADR(iUnitId), 
		i_piCoreId:= ADR(iCoreId), 
		i_piGroupId:= ADR(iGroupId), 
		i_piAdjAxisId:= ADR(iAdjAxisId), 
		i_pstStSysStationInf:= i_pstStSysStationInf);
	iRtn := GTN_GetDriverSts(iCoreId,iAxisId,ADR(adwDriverSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId]),1,ADR(adiClock[(iCoreId-1)* gc_ResCount_Profile +iAxisId]));
ELSE
	FOR iGetStsCnt := 1 TO 2 BY 1 DO
		iGetDriverStsAxis := iGetDriverStsAxis + 1;
		IF iGetDriverStsAxis > i_iGrpAllStationNum THEN
			iGetDriverStsAxis := 1;
		END_IF
		KS_GetAxisIdForMotByStation_V2(
			i_iStationId:= i_aiStationList[iGetDriverStsAxis],
			i_piAxisId:= ADR(iAxisId), 
			i_piTypeId:= ADR(iTypeId), 
			i_piUnitId:= ADR(iUnitId), 
			i_piCoreId:= ADR(iCoreId), 
			i_piGroupId:= ADR(iGroupId), 
			i_piAdjAxisId:= ADR(iAdjAxisId), 
			i_pstStSysStationInf:= i_pstStSysStationInf);
		iRtn := GTN_GetDriverSts(iCoreId,iAxisId,ADR(adwDriverSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId]),1,ADR(adiClock[(iCoreId-1)* gc_ResCount_Profile +iAxisId]));
	END_FOR
END_IF
(*2026.4.29.232737先屏蔽获取driversts逻辑*)
*)
alTime_Test[7]:= LTIME();

(*2026.4.29.233154先屏蔽
FOR iN := 1 TO i_iGrpAllStationNum BY 1 DO
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
		i_iStationId:= i_aiStationList[iN],
		i_piAxisId:= ADR(iAxisId), 
		i_piTypeId:= ADR(iTypeId), 
		i_piUnitId:= ADR(iUnitId), 
		i_piCoreId:= ADR(iCoreId), 
		i_piGroupId:= ADR(iGroupId), 
		i_piAdjAxisId:= ADR(iAdjAxisId), 
		i_pstStSysStationInf:= i_pstStSysStationInf);				
				
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wVirtual_Sts			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].virtual_sts;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wNet_Status			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].net_status;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wErr_a_Count			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].err_a_count;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wErr_b_Count			:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].err_b_count;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wBreakCnt				:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].break_cnt;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wMotor_Temperature	:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].motor_temperature;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wDriver_Temperature	:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].driver_temperature;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].wBus_Vol				:= astStStationSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].bus_voltage;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].dwMotionSts			:= LREAL_TO_DWORD(g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrMotionsts);
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Prf             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Prf;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrPos_Enc;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf;
	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc             := g_astMotionSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc;

	i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].dwDriverSts := adwDriverSts[(iCoreId-1)* gc_ResCount_Profile +iAxisId];

iRead_UnitId := iRead_UnitId + 1;	
END_FOR
2026.4.29.233145屏蔽结束*)
//报警先屏蔽了	
//	iRtn := GTN_RN_GetServoAlarmInfo(1,iN,ADR(i_pastStGetMotionSts^[iN].dwAlarmDetail));
//2026.02.07.141926||2026.02.07.141928

(*2026.4.29.233226先屏蔽

FOR iN := 1 TO i_iGrpAllStationNum BY 1 DO
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
		i_iStationId:= i_aiStationList[iN],
		i_piAxisId:= ADR(iAxisId), 
		i_piTypeId:= ADR(iTypeId), 
		i_piUnitId:= ADR(iUnitId), 
		i_piCoreId:= ADR(iCoreId), 
		i_piGroupId:= ADR(iGroupId), 
		i_piAdjAxisId:= ADR(iAdjAxisId), 
		i_pstStSysStationInf:= i_pstStSysStationInf);				
				
	CASE iTypeId OF
		TYPE_UNIT_PRN(*色组版辊*):
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_PrnRoller:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_PrnRoller:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);
		TYPE_UNIT_BOTTOM(*色组底辊*):
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_BottomRoller:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_BottomRoller:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);					
		TYPE_UNIT_NET(*色组网辊*):
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_NetRoller:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_NetRoller:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);					
		TYPE_UNIT_PRN_PRESS_MASTER:(*色组版辊龙门主轴*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Prn_Press_M:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Prn_Press_M:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);					
		TYPE_UNIT_PRN_PRESS_G:(*色组版辊龙门从轴G侧*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Prn_Press_G:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Prn_Press_G:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);								
		TYPE_UNIT_NET_PRESS_MASTER:(*色组网辊龙门主轴*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Net_Press_M:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Net_Press_M:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);								
		TYPE_UNIT_NET_PRESS_G:(*色组网辊龙门从轴G侧*)
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iTorque_Net_Press_G:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Prf/10.0);
			g_stStSysParam.astStRSV_UnitParam_UnSave[iUnitId].iRpm_Net_Press_G:= 
					LREAL_TO_INT(i_pastStGetMotionSts^[(iCoreId-1)* gc_ResCount_Profile +iAxisId].lrVel_Enc*1000*60/
						GC_LRMOTORPPR);			
	END_CASE	
END_FOR
2026.4.29.233238屏蔽结束*)
//2026.02.07.141938


//iRtn := GTN_GetDriverSts(1,1,ADR(adwDriverSts[1,1]),8,ADR(adiClock));
alTime_Test[4]:= LTIME();
alTime_Test[10]:= alTime_Test[5]-alTime_Test[3];
alTime_Test[9]:= alTime_Test[6]-alTime_Test[5];
alTime_Test[8]:= alTime_Test[7]-alTime_Test[6];

 