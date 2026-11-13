(*@CES
Name=KS_FB_AxisPosCtl_Trap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=53966cce-5ce5-480b-a4cc-b0ff05bfaf84
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisPosCtl_Trap
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpTrapMotion_Num: INT;
	i_aiGrpTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStMotorParam_Trap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Trap;
	
	i_xHorManuCtrl:BOOL;(*界面横向手动修正功能*)
	
	//2026.01.28.173520 | + | 横向伺服控制
	i_alrTarp_EncPos						: ARRAY [1..MAX_UNIT_NUM] OF LREAL;//横向点位轴的编码器位置
	i_pastStIOMap_AxisBasic					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (*基础io|*)
	i_pastStAxisRapidAdjProf_H				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;(*纵向快速对版|*)
	
	i_paxLimit_Left_Wr 						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
 	i_paxLimit_Right_Wr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxLimit_Left_WrClr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
 	i_paxLimit_Right_WrClr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	//新增拿横向编码器 2026.05.09.104451
	i_pastStGetMotionSts			: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf 		:POINTER TO StSysGantryAxisInf;
	i_pastStAxisIdListInf 			:POINTER TO ARRAY [1..128] OF StAxisIdListInf;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN: INT;
	iAxisId: INT;
	iTypeId: INT;
	iUnitId: INT;
	iCoreId: INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	
		
	//2026.01.28.173520 | + | 横向伺服控制
	fbKS_FB_HorzCtl_Driver : KS_FB_HorzCtl_Driver;
	
	alrTotalAdjust_Horz : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
END_VAR


{IMPLEMENTATION}
IF i_xEn THEN
	IF (i_iGrpId=1 OR i_iGrpId=2) AND
		i_iGrpUnitNum_Pu>=1 AND i_iGrpUnitNum_Pu<=MAX_UNIT_NUM AND
		i_iGrpTrapMotion_Num>=1 AND i_iGrpTrapMotion_Num<= MAX_STATION_NUM AND
		i_pstStSysParam<>0 AND
		i_pastStMotorParam_Trap<>0 THEN
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		//2026.01.28.173520 | + | 横向伺服控制	
		fbKS_FB_HorzCtl_Driver(
			i_xEn:= TRUE,//(pstStGrpParam_UnSave^.xFlag_Print OR i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xEnaTestARC_Ink (*空转测试使能*)) AND g_stStSysParam.stStSysParam_Save.byHorzCtlMode=3, 
			i_iGrpId:= i_iGrpId, 
			i_iGrpAxisNum_Pu:= i_iGrpUnitNum_Pu, 
			i_pstStSysParam:= i_pstStSysParam, 
			i_pastStIOMap_AxisBasic:= i_pastStIOMap_AxisBasic, 
			i_lrVel_HorzAdjust:= REAL_TO_LREAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_HorzdAdj), 
			i_lrVel_HorzPreRegister:=  REAL_TO_LREAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_HorzPreRegister), 
			i_xFlag_Estop:= pstStGrpParam_UnSave^.xFlag_EStop, 
			i_xFlag_Stop:= pstStGrpParam_UnSave^.xFlag_Stop, 
			i_iCycleTime_Plc:= gc_TENSION_TSK_CYCLE_TIME, 
			i_pastStAxisRapidAdjProf_H:= i_pastStAxisRapidAdjProf_H, 
			i_alrTarp_EncPos:= i_alrTarp_EncPos, 
			i_paxLimit_Left_Wr:= i_paxLimit_Left_Wr,
			i_paxLimit_Right_Wr:= i_paxLimit_Right_Wr,
			i_paxLimit_Left_WrClr:= i_paxLimit_Left_WrClr,
			i_paxLimit_Right_WrClr:= i_paxLimit_Right_WrClr,
			i_xHorManuCtrl:= i_xHorManuCtrl, 		
			i_aiGrpTrapMotion_StdList:=i_aiGrpTrapMotion_StdList,
			i_pastStGetMotionSts:=i_pastStGetMotionSts,
			i_pstStSysStationInf:=i_pstStSysStationInf,
			i_pstStSysGantryAxisInf :=i_pstStSysGantryAxisInf,
			i_pastStAxisIdListInf :=i_pastStAxisIdListInf,
			o_xEno=> , 
			o_iErNo=> , 
			o_alrTotalAdjust_Horz=> alrTotalAdjust_Horz);
			
		FOR iN:=1 TO i_iGrpTrapMotion_Num BY 1 DO
			i_pastStMotorParam_Trap^[iN].liTargetPos := LREAL_TO_LINT(alrTotalAdjust_Horz[iN]*
						i_pstStSysParam^.astStUnitParam_Save[iN].uiNum_Horz*
						GC_LRMOTORPPR_TRAP/
						i_pstStSysParam^.astStUnitParam_Save[iN].rScrewPitch_Horz/
						i_pstStSysParam^.astStUnitParam_Save[iN].uiDen_Horz/1000.0);
			i_pastStMotorParam_Trap^[iN].udiTargetVel := LREAL_TO_UDINT(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_HorzdAdj*
						i_pstStSysParam^.astStUnitParam_Save[iN].uiNum_Horz*
						GC_LRMOTORPPR_TRAP/
						i_pstStSysParam^.astStUnitParam_Save[iN].rScrewPitch_Horz/
						i_pstStSysParam^.astStUnitParam_Save[iN].uiDen_Horz/1000.0);
		END_FOR
	END_IF
ELSE
	;
END_IF