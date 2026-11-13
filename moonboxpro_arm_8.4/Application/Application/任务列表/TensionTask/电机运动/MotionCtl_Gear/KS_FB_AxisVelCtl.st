(*@CES
Name=KS_FB_AxisVelCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=151c0b62-81a2-453f-8398-cdb757e1a3a2
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisVelCtl
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpGearMotion_Num: INT;
	i_aiGrpGearMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStMotorParam_Vel: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_xMotionEnabled: BOOL;(*|2021.1.15.092801 速度控制块使能修改为输入输出变量|这里处理该值的复位*)
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
//2026.5.9.220343
	//增加加速度及加加速度输入只2026.4.11.153755
	i_paxFlag_PressDne: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;	
	i_rVel_A: REAL;//加速度
	i_rVel_Jerk: REAL;//加加速度；		
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	iTypeId: INT;
	iUnitId: INT;
	iCoreId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	fbKS_FB_AxisVelCtl_PrnRoller: KS_FB_AxisVelCtl_PrnRoller;
	alrAxisMotionVel:ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*轴的速度值*)	
	lrTempAxisVel: LREAL;(**)
//2026.5.9.220120速度升速补偿
	fbKS_FB_Compensate_Vel_Prn: KS_FB_Compensate_Vel_Prn;
	aiGrpLinkageAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	arAxisVelPrf_Coeff1: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	arAxisVelPrf_Coeff2: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	arAxisVelPrf_Coeff3: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	alrAxisPrfVel: ARRAY [1..MAX_UNIT_NUM] OF LREAL;	
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_iGrpUnitNum_Pu>=1 AND i_iGrpUnitNum_Pu<=MAX_UNIT_NUM AND
		i_iGrpGearMotion_Num>=1 AND i_iGrpGearMotion_Num<= MAX_STATION_NUM AND
		i_pstStSysParam<>0 AND
		i_pastStAxisIdListInf<>0 AND
		i_pastStMotorParam_Vel<>0 AND
		i_pstStSysStationInf <>0 THEN
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
//2026.04.11.204947		
		FOR iN:=1 TO g_aiGrpLinkageAxisNum_Pu[i_iGrpId] BY 1 DO
			aiGrpLinkageAxisList[iN]:= g_aiGrpLinkageAxisList[i_iGrpId,iN];
		END_FOR

		FOR iN:=1 TO  i_iGrpUnitNum_Pu BY 1 DO
			iUnitId:= i_aiGrpUnitList[iN];
			arAxisVelPrf_Coeff1[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAxisVelPrf_Coeff1;
			arAxisVelPrf_Coeff2[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAxisVelPrf_Coeff2;
			arAxisVelPrf_Coeff3[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rAxisVelPrf_Coeff3;
		END_FOR
		fbKS_FB_Compensate_Vel_Prn(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_rVel_Cur:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur,
			i_iGrpUnitNum_Pu:= i_iGrpUnitNum_Pu, 
			i_aiGrpUnitList:= i_aiGrpUnitList, 
			i_iGrpLinkageAxisNum_Pu:= g_aiGrpLinkageAxisNum_Pu[i_iGrpId], 
			i_aiGrpLinkageAxisList:= aiGrpLinkageAxisList, 
		//	i_palrAxisMotionVel:= ADR(alrAxisMotionVel), 
			i_paxFlag_PressDne:= i_paxFlag_PressDne, 
			i_rVel_A:= i_rVel_A, 
			i_rVel_Jerk:= i_rVel_Jerk, 
			i_arAxisVelPrf_Coeff1:= arAxisVelPrf_Coeff1,//i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].rAxisVelPrf_Coeff1, 
			i_arAxisVelPrf_Coeff2:= arAxisVelPrf_Coeff2,//i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].rAxisVelPrf_Coeff2, 
			i_arAxisVelPrf_Coeff3:= arAxisVelPrf_Coeff3,//i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].rAxisVelPrf_Coeff3, 
			i_xFlag_Accing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing, 
			i_xFlag_Decing:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing,
			o_alrAxisPrfVel=>alrAxisPrfVel);	
		
		FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
			iUnitId:= i_aiGrpUnitList[iN];
			IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM THEN
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisPrfVel:= LREAL_TO_REAL(alrAxisPrfVel[iUnitId]);
			END_IF
		END_FOR	
//2026.04.11.204941增加结束		
				
		fbKS_FB_AxisVelCtl_PrnRoller(
			i_xEn:= TRUE, 
			i_iGrpId:= i_iGrpId, 
			i_xSwitchType0:= FALSE, 
			i_xSwitchType1:= FALSE, 
			i_xMotionStsSwitchEn:= FALSE, 
			i_xNeedKeepSync:= FALSE, 
			i_iGrpAxisNum_Pu:= i_iGrpUnitNum_Pu, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_paiGrpAxisList:= ADR(i_aiGrpUnitList), 
			i_pastStIOMap_Main_FE:= i_pastStIOMap_Main_FE, 
			i_pastStIOMap_Axis_FE:= i_pastStIOMap_Axis_FE, 
			i_pabyAxisMotionSts:= ADR(g_abyAxisMotionSts), 
			i_paxAxisInching:= ADR(g_axAxisMotionInching), 
			i_paxLastAxisInchBtn:= ADR(g_axLastAxisMotionInchBtn), 
			i_iMaxVel_StsSwitch:= g_iMaxVel_StsSwitch, 
			i_palrAxisMotionVel:= ADR(alrAxisMotionVel), 
			i_palrAcceleToSync:= ADR(g_alrAcceleToSync), 
			i_palrTimeToSync:= ADR(g_alrTimeToSync), 
			i_palrRelatePos_Final:= ADR(g_alrRelatePos_Final), 
			i_palrRelatePosToSync:= ADR(g_alrRelatePosToSync), 
			i_xMotionEnabled:= i_xMotionEnabled, 
			i_xChangLinkageStsWhenPrint:= FALSE, 
			i_uiMaxVel_UseCalcAcc:= i_pstStSysParam^.stStSysParam_Save.uiMaxVel_UseCalcAcc, 
			o_xEn=> );
			
		FOR iN:=1 TO  i_iGrpUnitNum_Pu BY 1 DO
			g_alrAxisMotionVel[iN] := alrAxisMotionVel[iN];
		END_FOR	
			
		FOR iN:=1 TO i_iGrpGearMotion_Num BY 1 DO
// 			KS_HY_GetAxisIdForMotByStation(
// 				i_aiGrpGearMotion_StdList[iN],
// 				ADR(iAxisId),
// 				ADR(iTypeId),
// 				ADR(iUnitId),
// 				ADR(iCoreId),
// 				ADR(iGroupId),
// 				ADR(iAdjAxisId),
// 				i_pastStAxisIdListInf);	
			KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_aiGrpGearMotion_StdList[iN],
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);	
			i_pastStMotorParam_Vel^[iN].iAxisId:= iAxisId;
			i_pastStMotorParam_Vel^[iN].iCoreId:= iCoreId;
			i_pastStMotorParam_Vel^[iN].iStationId:= i_aiGrpGearMotion_StdList[iN];
			CASE iTypeId OF
			TYPE_MASTER_I,TYPE_MASTER_II:
				;
			TYPE_CENTRAL_I,TYPE_CENTRAL_II:
				lrTempAxisVel:= pstStGrpParam_UnSave^.rVel_Film;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;				
				i_pastStMotorParam_Vel^[iN].rAxisGirth:= pstStGrpParam_Save^.rGirth_CenterRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= pstStGrpParam_Save^.uiNum_CenterRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= pstStGrpParam_Save^.uiDen_CenterRoller;
			TYPE_UNWIND_A_I,TYPE_UNWIND_A_II:
				lrTempAxisVel:= pstStGrpParam_UnSave^.rAxisAVelRPM_Cur_Uw;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;			
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= pstStGrpParam_Save^.uiNum_Uw;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= pstStGrpParam_Save^.uiDen_Uw;
			TYPE_UNWIND_B_I,TYPE_UNWIND_B_II:
				lrTempAxisVel:= pstStGrpParam_UnSave^.rAxisBVelRPM_Cur_Uw;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;			
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= pstStGrpParam_Save^.uiNum_Uw;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= pstStGrpParam_Save^.uiDen_Uw;
			TYPE_REWIND_A_I,TYPE_REWIND_A_II:
				lrTempAxisVel:= pstStGrpParam_UnSave^.rAxisAVelRPM_Cur_Rw;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= pstStGrpParam_Save^.uiNum_Rw;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= pstStGrpParam_Save^.uiDen_Rw;
			TYPE_REWIND_B_I,TYPE_REWIND_B_II:
				lrTempAxisVel:= pstStGrpParam_UnSave^.rAxisBVelRPM_Cur_Rw;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= pstStGrpParam_Save^.uiNum_Rw;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= pstStGrpParam_Save^.uiDen_Rw;
			TYPE_INFEED_I,TYPE_INFEED_II:
				lrTempAxisVel:= pstStGrpParam_UnSave^.rVel_Cur_If;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;
				i_pastStMotorParam_Vel^[iN].rAxisGirth:= pstStGrpParam_UnSave^.rUsingGirth_If;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= pstStGrpParam_Save^.uiNum_If;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= pstStGrpParam_Save^.uiDen_If;
			TYPE_OUTFEED_I,TYPE_OUTFEED_II:
				lrTempAxisVel:= pstStGrpParam_UnSave^.rVel_Cur_Of;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;
				i_pastStMotorParam_Vel^[iN].rAxisGirth:= pstStGrpParam_UnSave^.rUsingGirth_Of;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= pstStGrpParam_Save^.uiNum_Of;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= pstStGrpParam_Save^.uiDen_Of;
			TYPE_UNIT_PRN:
				IF pstStGrpParam_UnSave^.xFlag_Stop THEN
					lrTempAxisVel:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_PrnRoller;
				ELSE
					lrTempAxisVel:= alrAxisMotionVel[iUnitId];
				END_IF
				
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;
				i_pastStMotorParam_Vel^[iN].rAxisGirth:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller;
			TYPE_UNIT_BOTTOM:
				IF g_iMachineryType = MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN //机组式柔印、单伺服底辊
				//	lrTempAxisVel:= alrAxisMotionVel[iUnitId];//i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller;
					lrTempAxisVel:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller;
				ELSE
					lrTempAxisVel:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller;
				END_IF
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;
				i_pastStMotorParam_Vel^[iN].rAxisGirth:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_BottomRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_BottomRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_BottomRoller;
			TYPE_UNIT_NET:
				lrTempAxisVel:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_NetRoller;
				IF i_pastStMotorParam_Vel^[iN].xMoveRev THEN
					lrTempAxisVel:= -lrTempAxisVel;
				END_IF
				i_pastStMotorParam_Vel^[iN].rAxisVel:= lrTempAxisVel;
				i_pastStMotorParam_Vel^[iN].rAxisGirth:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_NetRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisNum:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller;
				i_pastStMotorParam_Vel^[iN].uiAxisDen:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller;
			END_CASE
		END_FOR
		
	i_pastStMotorParam_Vel^[1].rAxisVel;
	i_pastStMotorParam_Vel^[2].rAxisVel;
	i_pastStMotorParam_Vel^[3].rAxisVel;
	i_pastStMotorParam_Vel^[4].rAxisVel;
	i_pastStMotorParam_Vel^[5].rAxisVel;
	i_pastStMotorParam_Vel^[6].rAxisVel;
	i_pastStMotorParam_Vel^[1].xMoveEn;
	i_pastStMotorParam_Vel^[2].xMoveEn;
	i_pastStMotorParam_Vel^[3].xMoveEn;
	i_pastStMotorParam_Vel^[4].xMoveEn;
	i_pastStMotorParam_Vel^[5].xMoveEn;
	i_pastStMotorParam_Vel^[6].xMoveEn;
	
	END_IF
ELSE
	;
END_IF