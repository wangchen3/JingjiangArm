(*@CES
Name=Action_Alarm_ClearAndReset
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=4731ad3b-3029-4852-8cb2-0b02bba95cf6
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}


//2026.01.12.112710 | + | 增加清理驱动器报警的功能
//2026.1.19.155427界面清除标志后面从界面获取2026.1.19.155438
IF g_xClrAlr_HMI THEN
	g_xClrAlr_HMI:= FALSE;
	//2026.05.09.160415 | + | 增加龙门偏差过大保护
	g_xConfirmContinueForward := TRUE;
	g_axPhaseRestore_Overtime[i_iGrpId] := FALSE;
	FOR iN := 1 TO i_iGrpAllStationNum BY 1 DO
		iRtn := GTN_RN_ClrAlarm(cardIndex:=1 , station_id:=i_aiStationList[iN] , axis:=1 , count:=1 );

		KS_GetAxisIdForMotByStation_V2(
			i_iStationId:= i_aiStationList[iN],
			i_piAxisId:= ADR(iAxisId), 
			i_piTypeId:= ADR(iTypeId), 
			i_piUnitId:= ADR(iUnitId), 
			i_piCoreId:= ADR(iCoreId), 
			i_piGroupId:= ADR(iGroupId), 
			i_piAdjAxisId:= ADR(iAdjAxisId), 
			i_pstStSysStationInf:= i_pstStSysStationInf);	

		IF iRtn = 0 THEN
			iRtn := GTN_ClrSts(core:= iCoreId, axis:= iAxisId, count:=1 );
		END_IF			

// 		IF iType_Id= OBJ_IS_UNWIND_A THEN
// 			IF i_pstStSysParam^.xPosDeviationAlarm_UW_A OR 
// 				i_pstStSysParam^.xAxisAlarm_UW_A THEN
// 				GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 			END_IF
// 		ELSIF iType_Id= OBJ_IS_UNWIND_B THEN
// 			IF i_pstStSysParam^.xPosDeviationAlarm_UW_B OR 
// 				i_pstStSysParam^.xAxisAlarm_UW_B THEN
// 				GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 			END_IF
// 		ELSIF iType_Id= OBJ_IS_REWIND_A THEN
// 			IF i_pstStSysParam^.xPosDeviationAlarm_RW_A OR 
// 				i_pstStSysParam^.xAxisAlarm_RW_A THEN
// 				GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 			END_IF
// 		ELSIF iType_Id= OBJ_IS_REWIND_B THEN
// 			IF i_pstStSysParam^.xPosDeviationAlarm_RW_B OR 
// 				i_pstStSysParam^.xAxisAlarm_RW_B THEN
// 				GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 			END_IF
// 		ELSIF iType_Id= OBJ_IS_INFEED THEN
// 			IF i_pstStSysParam^.xPosDeviationAlarm_IF OR 
// 				i_pstStSysParam^.xAxisAlarm_IF THEN
// 				GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 			END_IF
// 		ELSIF iType_Id= OBJ_IS_OUTFEED THEN
// 			IF i_pstStSysParam^.xPosDeviationAlarm_OF OR 
// 				i_pstStSysParam^.xAxisAlarm_OF THEN
// 				GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 			END_IF
// 		ELSIF iType_Id= OBJ_IS_CENTRAL_DRUM THEN
// 			IF i_pstStSysParam^.xPosDeviationAlarm_CENTRAL OR 
// 				i_pstStSysParam^.xAxisAlarm_CENTRAL THEN
// 				GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 			END_IF
// 		ELSE
// 			FOR iUnit:=1 TO MAX_UNIT_NUM BY 1 DO
// 				IF iUnit=iUnitId THEN 
// 					pstStUnitParam:= ADR(i_pstStSysParam^.astStUnitParam[iUnitId]);
// 					IF iType_Id=OBJ_IS_BOTTOM_ROLLER THEN//色组底辊
// 						IF pstStUnitParam^.xPosDeviationAlarm_BottomRoller OR
// 							pstStUnitParam^.xAxisAlarm_BottomRoller THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF
// 					ELSIF iType_Id=OBJ_IS_PRN_ROLLER THEN//色组版辊
// 						IF pstStUnitParam^.xPosDeviationAlarm_PrnRoller OR
// 							pstStUnitParam^.xAxisAlarm_PrnRoller THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF
// 					ELSIF iType_Id=OBJ_IS_NET_ROLLER THEN//色组网辊
// 						IF pstStUnitParam^.xPosDeviationAlarm_NetRoller OR
// 							pstStUnitParam^.xAxisAlarm_NetRoller THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF	
// 					ELSIF iType_Id=OBJ_IS_PRN_ROLLER_PRESSURE_M THEN//色组版辊M
// 						IF pstStUnitParam^.xPosDeviationAlarm_Prn_Pressure_M OR
// 							pstStUnitParam^.xAxisAlarm_Prn_Pressure_M THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF		
// 					ELSIF iType_Id=OBJ_IS_PRN_ROLLER_PRESSURE_G THEN//色组版辊G
// 						IF pstStUnitParam^.xPosDeviationAlarm_Prn_Pressure_G OR
// 							pstStUnitParam^.xAxisAlarm_Prn_Pressure_G THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF	
// 					ELSIF iType_Id=OBJ_IS_NET_ROLLER_PRESSURE_M THEN//色组网辊M
// 						IF pstStUnitParam^.xPosDeviationAlarm_Net_Pressure_M OR
// 							pstStUnitParam^.xAxisAlarm_Net_Pressure_M THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF			
// 					ELSIF iType_Id=OBJ_IS_NET_ROLLER_PRESSURE_G THEN//色组网辊G
// 						IF pstStUnitParam^.xPosDeviationAlarm_Net_Pressure_G OR
// 							pstStUnitParam^.xAxisAlarm_Net_Pressure_G THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF
// 					ELSIF iType_Id=OBJ_IS_HORIZ_MOTION THEN//横向
// 						IF pstStUnitParam^.xPosDeviationAlarm_Horz OR
// 							pstStUnitParam^.xAxisAlarm_Horz THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF
// 					ELSIF iType_Id= OBJ_IS_PHOTOCELL THEN
// 						IF pstStUnitParam^.xPosDeviationAlarm_PHOTOCELL OR 
// 							pstStUnitParam^.xAxisAlarm_PHOTOCELL THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF
// 					ELSIF iType_Id=OBJ_IS_STR_ROLLER_PRESSURE_M THEN//色组张带辊M
// 						IF pstStUnitParam^.xPosDeviationAlarm_Str_Pressure_M OR
// 							pstStUnitParam^.xAxisAlarm_Str_Pressure_M THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF			
// 					ELSIF iType_Id=OBJ_IS_STR_ROLLER_PRESSURE_G THEN//色组张带辊G
// 						IF pstStUnitParam^.xPosDeviationAlarm_Str_Pressure_G OR
// 							pstStUnitParam^.xAxisAlarm_Str_Pressure_G THEN
// 							GT_ClrSts(1, 1, (*pstStAxisParam^.iStationId*)i_aiStationIdList[iN]);
// 						END_IF						
// 					END_IF
// 				END_IF					
// 			END_FOR	
// 		END_IF	
	END_FOR
END_IF


