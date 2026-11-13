(*@CES
Name=KS_FB_SpecialFun_CHAOXU
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f5b24564-6771-49b2-be0e-b28fd4c398bb
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpecialFun_CHAOXU
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
	i_pastStInteraction : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StInteraction;
	i_pstStEvtReq: POINTER TO StEvtReq;(* 动作提取 *)	
	i_rVel_UVstartVel: REAL;
	i_rVel_CoronaVel:REAL:=3;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN : INT;
	iRtn : INT;
	
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	xNeedPrint:BOOL;
	xNeedInk:BOOL;
	xStateChange:BOOL;
	
	xFlag_Ink_to_stop: BOOL;
	xFlag_Stop_to_Print: BOOL;
	fbtrig_Inch_Print: R_TRIG;
	fbtrig_Inch_Stop: R_TRIG;
	xFlag_Print_to_stop: BOOL;
	xUnitHaveAxisInch : BOOL;
	xAxisInch_Print: BOOL;//点动2023.9.27.153613|收放牵|收放料|底辊|中心辊
	iAxisId: INT;
// 	aTRIG_InkRollerFor: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
// 	aTRIG_InkRollerRev: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
// 	aTRIG_InkTrayUp: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
// 	aTRIG_InkTrayDn: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
// 	
	iTime_RelTime: INT:= 150;
	aiNum_InkRollerFor: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiNum_InkRollerRev: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiNum_InkTrayUp: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiNum_InkTrayDn: ARRAY [1..MAX_UNIT_NUM] OF INT;
	xUVStart_En: BOOL;
	rUV_SetValue: REAL;
	wUV_Output: WORD;
	
	xCorona_En: BOOL;
	rCorona_SetValue: REAL;
	wCorona_Output: WORD;
	//2026.03.09.170159 | + 一色压辊自动处理
	iCnt_Rel_Press_1U : INT;
	iDelay:INT:=0;
	fbTRIG_AxisInch_Prn: R_TRIG;
	xAlarming_InchPrn: BOOL;
	tmStart_InchPrn_Alr: TIME;
	
	
	xstopAuto:BOOL;
	fbTrig_AutoStop:R_TRIG;
	iReadyCount:INT;
	xReadyStop:BOOL;	
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
	pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
	
(*点动处理一下2026.2.9.140724*)
//2026.03.11.144803 | + | 使用新的点动方案
(*

	//走纸点动
	xAxisInch_Print:= (i_pastStIOMap_Main_FE^[1].i_xRsvd_DI0  AND (NOT pstStGrpParam_UnSave^.xFlag_Estop));
	IF xAxisInch_Print THEN
		g_xFlag_AxisInch_Print := TRUE;
	ELSIF (NOT xAxisInch_Print) AND pstStGrpParam_UnSave^.rVel_Film = 0 THEN
		g_xFlag_AxisInch_Print := FALSE;
	END_IF
//处理一些流程问题
	fbtrig_Inch_Print(CLK:= xAxisInch_Print);
	fbtrig_Inch_Stop(CLK:= NOT xAxisInch_Print);
	IF fbtrig_Inch_Print.Q THEN
		i_pstStEvtReq^.xReqPrint:= TRUE;
	END_IF
	IF fbtrig_Inch_Stop.Q THEN
		i_pstStEvtReq^.xReqStop:= TRUE;
	END_IF
	
	
	IF pstStGrpParam_UnSave^.xFlag_Stop AND (NOT xFlag_Stop_to_Print) AND (NOT xFlag_Ink_to_stop) THEN
//停机状态下如果触发了一个匀墨按钮就进入断料空转档位，其他色组直接触发使能挂靠
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			IF g_axInk_Unit[iN] AND i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
				i_pstStEvtReq^.xReqPrestart:= TRUE;
				i_pstStEvtReq^.xEvt_TapPosition_Breaking := TRUE;
				i_pstStEvtReq^.xEvt_TapPosition_Printing := FALSE;			
				
			END_IF
		END_FOR
	END_IF
	IF i_pstStEvtReq^.xReqPrint THEN
		IF pstStGrpParam_UnSave^.xFlag_Ink THEN
			i_pstStEvtReq^.xReqStop:= TRUE;
			xFlag_Ink_to_stop:= TRUE;
		ELSE
			xFlag_Stop_to_Print:= TRUE;
			i_pstStEvtReq^.xReqPrestart:= TRUE;
			i_pstStEvtReq^.xEvt_TapPosition_Printing := TRUE;			
			i_pstStEvtReq^.xEvt_TapPosition_Breaking := FALSE;
			
			pstStGrpParam_Save^.rVel_Tar:= pstStGrpParam_Save^.rVel_Ink;
		END_IF
	END_IF
	IF xFlag_Ink_to_stop AND pstStGrpParam_UnSave^.xFlag_Stop THEN
		xFlag_Ink_to_stop:= FALSE;
		xFlag_Stop_to_Print:= TRUE;
		i_pstStEvtReq^.xReqPrestart:= TRUE;
		i_pstStEvtReq^.xEvt_TapPosition_Breaking := FALSE;	
		i_pstStEvtReq^.xEvt_TapPosition_Printing := TRUE;			
		pstStGrpParam_Save^.rVel_Tar:= pstStGrpParam_Save^.rVel_Ink;		
	END_IF
	IF xFlag_Stop_to_Print AND pstStGrpParam_UnSave^.xFlag_Print THEN//转到印刷后自动加速到10
		i_pstStEvtReq^.xReqPrestart:= TRUE;
		xFlag_Stop_to_Print:= FALSE;
	END_IF
	IF pstStGrpParam_UnSave^.xFlag_Print AND i_pstStEvtReq^.xReqStop THEN
		xFlag_Print_to_stop:= TRUE;//印刷停机触发-
	END_IF
	IF xFlag_Print_to_stop AND pstStGrpParam_UnSave^.rVel_Cur=0 THEN
		//当前速度降到0再触发一下停机，直接停下来，但是所有伺服维持？//支持0速切状态
		xFlag_Print_to_stop:= FALSE;
		//2025.08.26.091339 | 点动结束后仍然维持张力，不再触发停机
		//i_pstStEvtReq^.xReqStop:= TRUE;
	END_IF
*)	
//2026.03.11.144803 | + | 使用新的点动方案
	//走纸点动
	xAxisInch_Print:= ((i_pastStIOMap_Main_FE^[1].i_xRsvd_DI0 OR i_pastStIOMap_Main_FE^[2].i_xRsvd_DI0) AND (NOT pstStGrpParam_UnSave^.xFlag_Estop));
	fbTRIG_AxisInch_Prn(CLK:= xAxisInch_Print);
	IF fbTRIG_AxisInch_Prn.Q THEN
		xAlarming_InchPrn:= TRUE;
		tmStart_InchPrn_Alr:= TIME();
	END_IF
	IF xAlarming_InchPrn THEN
		IF TIME()-tmStart_InchPrn_Alr>=T#3S THEN
			xAlarming_InchPrn:= FALSE;
		END_IF
		i_pstStEvtReq^.xEvt_AlarmBell:= TRUE;
	END_IF
	IF xAxisInch_Print THEN
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching := TRUE;//   g_xFlag_AxisInch_Print := TRUE;
	ELSIF (NOT xAxisInch_Print) AND pstStGrpParam_UnSave^.rVel_Film = 0 THEN
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xPrintInching := FALSE;//   g_xFlag_AxisInch_Print := false;
	END_IF
	
(*点动处理完成2026.2.9.140740*)
	i_pstStEvtReq^.xEvt_TapPosition_Printing := TRUE;			
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print AND i_pstStEvtReq^.xReqStop THEN
		xFlag_Print_to_stop:= TRUE;//印刷停机触发-
	END_IF
	IF xFlag_Print_to_stop AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur=0 THEN
		//当前速度降到0再触发一下停机，直接停下来，但是所有伺服维持？//支持0速切状态
		xFlag_Print_to_stop:= FALSE;
		i_pstStEvtReq^.xReqStop:= TRUE;
		IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wCtl_Pressure_Up_Dn.4 THEN//需要自动匀墨时处理这个
			FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
				IF i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
					IF NOT i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Net THEN//再切换到匀墨
						i_pstStSysParam^.astStRSV_UnitParam_UnSave[iN].xSwitch_Inching_Net:= TRUE;
					END_IF
				END_IF
			END_FOR
		ELSE;
		END_IF
	END_IF
	//处理一下墨盘和网辊锁阀
	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
		iAxisId:= i_aiGrpUnitList[iN];
		//从站增加照明 2026.02.28.133700 Hou.N
		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO6:=i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI3;
		IF i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI0 THEN
			//墨盘锁有效
			aiNum_InkRollerRev[iAxisId]:= 0;
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO1:= FALSE;//关闭降电磁阀
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO0:= TRUE;//打开升电磁阀
			
			aiNum_InkRollerFor[iAxisId]:= aiNum_InkRollerFor[iAxisId]+1;
			IF aiNum_InkRollerFor[iAxisId]>= iTime_RelTime THEN
				aiNum_InkRollerFor[iAxisId]:= aiNum_InkRollerFor[iAxisId]-1;
				i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO0:= FALSE;//关闭升电磁阀
			END_IF
		ELSE
			aiNum_InkRollerFor[iAxisId]:= 0;
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO0:= FALSE;//关闭升电磁阀
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO1:= TRUE;//打开降电磁阀
			
			aiNum_InkRollerRev[iAxisId]:= aiNum_InkRollerRev[iAxisId]+1;
			IF aiNum_InkRollerRev[iAxisId]>= iTime_RelTime THEN
				aiNum_InkRollerRev[iAxisId]:= aiNum_InkRollerRev[iAxisId]-1;
				i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO1:= FALSE;//关闭升电磁阀
			END_IF			
		END_IF
		
		IF i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI1 THEN
			//墨盘锁有效
			aiNum_InkTrayDn[iAxisId]:= 0;
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO3:= FALSE;//关闭降电磁阀
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO2:= TRUE;//打开升电磁阀
			
			aiNum_InkTrayUp[iAxisId]:= aiNum_InkTrayUp[iAxisId]+1;
			IF aiNum_InkTrayUp[iAxisId]>= iTime_RelTime THEN
				aiNum_InkTrayUp[iAxisId]:= aiNum_InkTrayUp[iAxisId]-1;
				i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO2:= FALSE;//关闭升电磁阀
			END_IF
		ELSE
			aiNum_InkTrayUp[iAxisId]:= 0;
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO2:= FALSE;//关闭升电磁阀
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO3:= TRUE;//打开降电磁阀
			
			aiNum_InkTrayDn[iAxisId]:= aiNum_InkTrayDn[iAxisId]+1;
			IF aiNum_InkTrayDn[iAxisId]>= iTime_RelTime THEN
				aiNum_InkTrayDn[iAxisId]:= aiNum_InkTrayDn[iAxisId]-1;
				i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO3:= FALSE;//关闭升电磁阀
			END_IF			
		END_IF
		
		
// 		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO0:= i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI0;//墨盘电磁阀升
// 		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO1:= NOT i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI0;//墨盘电磁阀降
// 		
// 		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO2:=i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI1;//网辊锁轴
// 		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO3:= NOT i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI1;//网辊锁轴

		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO4:= i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI2;//墨盘锁轴电磁阀锁轴
//		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO2:= i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI2;//墨盘锁轴电磁阀锁轴
//		i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO3:=i_pastStIOMap_Axis_FE^[iAxisId].i_xRsvd_DI3;//墨盘锁轴电磁阀解锁
// 	
// 		IF NOT(i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO1) THEN
// 			i_pastStIOMap_Axis_FE^[iAxisId].o_xRsvd_DO3:=FALSE;
// 		END_IF

	END_FOR
	
	i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_RollerPressDone:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
	
// 	IF 	i_pastStIOMap_Main_FE^[1].i_xPrint AND i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur >3 THEN
// 					i_pastStIOMap_Main_FE^[1].o_xRsvd_DO1 :=TRUE;
// 	END_IF 
//2026.02.07.104403UV加热处理
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film> i_rVel_UVstartVel THEN
		xUVStart_En:= TRUE;
		rUV_SetValue:= (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film-i_rVel_UVstartVel)*10/
				(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Max-i_rVel_UVstartVel);
		wUV_Output:= REAL_TO_WORD(rUV_SetValue*32767/10.0);		
		IF wUV_Output<0 THEN 
			wUV_Output:=0;
		ELSIF wUV_Output>32767 THEN 
			wUV_Output:= 32767;
		END_IF
	ELSE
		xUVStart_En:= FALSE;
		rUV_SetValue:= 0;
		wUV_Output:= 0;
	END_IF
	i_pastStIOMap_Main_FE^[1].o_xRsvd_DO1:= xUVStart_En;
	i_pastStIOMap_Main_FE^[1].o_wRsvd_AO1:= wUV_Output;
	
	
//2026.03.20.153334 新增电晕处理
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film> i_rVel_CoronaVel THEN
		xCorona_En:= TRUE;
		rCorona_SetValue:= (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film-i_rVel_CoronaVel)*10/
				(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rVel_Max-i_rVel_CoronaVel);
		wCorona_Output:= REAL_TO_WORD(rCorona_SetValue*32767/10.0);		
		IF wCorona_Output<0 THEN 
			wCorona_Output:=0;
		ELSIF wCorona_Output>32767 THEN 
			wCorona_Output:= 32767;
		END_IF
	ELSE
		xCorona_En:= FALSE;
		rCorona_SetValue:= 0;
		wCorona_Output:= 0;
	END_IF
	i_pastStIOMap_Main_FE^[1].o_xRsvd_DO2:= xCorona_En;
	i_pastStIOMap_Main_FE^[1].o_wRsvd_AO2:= wCorona_Output;
(*	
 	i_pastStIOMap_Axis_FE^[2].o_xRel_Press:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
	i_pastStIOMap_Axis_FE^[3].o_xRel_Press:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
// 	i_pastStIOMap_Axis_FE^[4].o_xRel_Press:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
// 	
// 	i_pstStSysParam^.astStUnitParam_UnSave[1].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
// 	i_pstStSysParam^.astStUnitParam_UnSave[2].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
// 	i_pstStSysParam^.astStUnitParam_UnSave[3].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
// 	i_pstStSysParam^.astStUnitParam_UnSave[4].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;

	i_pstStSysParam^.astStUnitParam_UnSave[1].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
	i_pstStSysParam^.astStUnitParam_UnSave[2].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
	i_pstStSysParam^.astStUnitParam_UnSave[3].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[1].o_xRel_Press;
	i_pstStSysParam^.astStUnitParam_UnSave[4].xFlag_PressDn:= i_pastStIOMap_Axis_FE^[4].o_xRel_Press;	
	
	//2026.03.17.92116  ＋四色自动压辊处理  Hou.N
	FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
		iAxisId:= i_aiGrpUnitList[iN];
		IF i_pastStIOMap_Axis_FE^[iAxisId].i_xPress THEN
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRel_Press := TRUE;
		ELSIF ((NOT i_pastStIOMap_Axis_FE^[iAxisId].i_xPress) AND ( i_pastStIOMap_Axis_FE^[iAxisId].i_xUnPress)) OR  pstStGrpParam_UnSave^.xFlag_Estop THEN
			i_pastStIOMap_Axis_FE^[iAxisId].o_xRel_Press := FALSE;
		ELSE
			//压辊自动
			IF  pstStGrpParam_UnSave^.xFlag_Print  THEN
				IF i_pastStIOMap_Main_FE^[1].o_xRel_Press_IF (*AND i_pastStIOMap_Main_FE^[2].o_xRel_Press_OF*) THEN
					i_pastStIOMap_Axis_FE^[iAxisId].o_xRel_Press := TRUE;
				END_IF
			END_IF
		END_IF
	END_FOR
*)	

// 	IF pstStGrpParam_UnSave^.xFlag_Print THEN
// 			IF i_pastStIOMap_Main_FE^[1].o_xRel_Press_IF THEN
// 				IF NOT i_pstStEvtReq^.xReqPressAll THEN
// 					iDelay := iDelay + 1;
// 					IF iDelay = 57 THEN
// 						iDelay := 0;  
// 						i_pstStEvtReq^.xReqPressAll := TRUE; 
// 					END_IF
// 				END_IF
// 			ELSE
// 				iDelay := 0;
// 			END_IF
// 	ELSE
// 		iDelay := 0;
// 	END_IF

		IF pstStGrpParam_UnSave^.xFlag_Print THEN
			IF i_pastStIOMap_Main_FE^[1].o_xRel_Press_IF THEN
				IF  pstStGrpParam_UnSave^.rVel_Film >10 THEN
					i_pstStEvtReq^.xReqPressAll := TRUE; 	
				END_IF
			END_IF
		END_IF

		//2026.05.14.104714 自动卷径停机  Hou.N
		IF i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].xIsAutoStop THEN
				IF  i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Uw<0.5 AND  
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Rw<0.5 AND
				    i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_If<0.5 AND
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_Of<0.5  AND
					 pstStGrpParam_UnSave^.rVel_Film >14 
					THEN
					iReadyCount:=iReadyCount+1;
					IF iReadyCount=(10*1000/gc_EXT_TSK_CYCLE_TIME) THEN
						xReadyStop:=TRUE;
						iReadyCount:=0;
					END_IF
					IF xReadyStop AND (g_arRemainDia_Cur[i_iGrpId]<i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].rRemainDia_stop) THEN
						xstopAuto:=TRUE;
						xReadyStop:=FALSE;
					ELSE
						xstopAuto:=FALSE;
					END_IF 
					fbTrig_AutoStop(clk:=xstopAuto);
					IF fbTrig_AutoStop.Q THEN
						i_pstStEvtReq^.xReqStop:= TRUE;
						iReadyCount:=0;
					END_IF
				ELSE
					iReadyCount:=0;
				END_IF
		ELSE
				xstopAuto:=FALSE;
				xReadyStop:=FALSE;
				iReadyCount:=0;			
		END_IF

END_IF
