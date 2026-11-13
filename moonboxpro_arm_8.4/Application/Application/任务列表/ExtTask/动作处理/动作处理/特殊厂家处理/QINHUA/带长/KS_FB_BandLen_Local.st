(*@CES
Name=KS_FB_BandLen_Local
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3cc07ba8-e2aa-468c-89eb-1132d0eacfdd
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_BandLen_Local
VAR_INPUT
	i_xEn : BOOL;
	i_iGrpId: INT;
	i_iUnitNum:INT;	
	i_pstStSysParam: POINTER TO StSysParam;(* 系统参数地址 *)
	i_pastLatch: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF StLatch;
	//i_paudiSkirtTime : POINTER TO ARRAY[1..MAX_UNIT_NUM,1..11] OF UDINT;
	//i_paStStationMotionSts : POINTER TO ARRAY[1..MAX_STATION_NUM] OF StStationMotionSts;
	//版辊当前位置
// 	i_pabyCurPos_Prn_M								: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF BYTE;
// 	i_pabyCurPos_Prn_G								: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF BYTE;
	//对版状态
// 	i_paxArcMoveUp									: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF BOOL;
// 	i_paxArcMoveDn									: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	
// 	i_palrEnc_Pos_Prn_M 							: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	i_palrEnc_Pos_Prn_G 							: POINTER TO ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	i_xSrcDirectionMotRev							: BOOL;//TRUE : 反转			false： 正向
	i_pastStInteraction : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StInteraction;
END_VAR
VAR_OUTPUT
	o_xEn : BOOL;
	o_iErrNo : INT;
	
END_VAR
VAR
	iN : INT;
	iM : INT;
	iRtn : INT;
	xInit : BOOL;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;	
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
//	afbKS_FB_AveBandLen: ARRAY[1..MAX_UNIT_NUM] OF KS_FB_AveBandLen;
	alrCenterDistance_Min : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	rCenterDistanceStandard								: REAL;(*标准圆心距*)
	m_lastLen : REAL;
	m_lastTime : UDINT;
	Err : UDINT;
	axCalBandLen : ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	
	lrBandLength : LREAL;
	lrAveBandLength : LREAL;
	lrBandLengthSum : LREAL;
	alrBandLengthList : ARRAY [1..MAX_UNIT_NUM,1..55] OF LREAL;
	alrBandLengthList_BubbleSort : ARRAY [1..MAX_UNIT_NUM,1..55] OF LREAL;
	aiCount : ARRAY[1..MAX_UNIT_NUM] OF INT;
	
	aiCount_AdjBand : ARRAY[1..MAX_UNIT_NUM] OF INT;
	afbKS_FB_AdjustBandLen_II : ARRAY [1..MAX_UNIT_NUM] OF KS_FB_AdjustBandLen_II;
	iUnitBand_Valid : INT;
	lrLength_Bnad_Sum : LREAL;
	aiCheckBandLenErrCount : ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	
// 	afbKS_FB_CheckBandLen : ARRAY [1..MAX_UNIT_NUM] OF  KS_FB_CheckBandLen;
// 	aiCheckBandCnt :  ARRAY [1..MAX_UNIT_NUM] OF INT;
	
	//2025.03.08.151328 | 时间计算带长g_arBandLength
	alrBandLength : ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	
	alrBandLengthList_Time : ARRAY [1..MAX_UNIT_NUM,1..55] OF LREAL;
	alrLength_Bnad_Sum_Time : ARRAY [1..MAX_UNIT_NUM] OF lREAL;
	iK : INT;
	
	
	fbKS_FB_BubbleSort : KS_FB_BubbleSort;
	
	lrBandLength_Min : LREAL;
	lrBandLength_Max : LREAL;
	
	audiSkirtEncPos : ARRAY[1..MAX_UNIT_NUM] OF UDINT;
	audiSkirtEncPos_Pre : ARRAY[1..MAX_UNIT_NUM] OF UDINT;
	iCycleNum : INT;
	
	axDI_Positive : ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	axDI_Positive_Count : ARRAY[1..MAX_UNIT_NUM] OF INT;
	
// 	alrGear_Aux_Prf_Pos : ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrGear_Aux_Prf_Pos_Pre : ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrGear_Aux_Prf_Pos_Err : ARRAY[1..MAX_UNIT_NUM] OF LREAL;
	
// 	alrEnc_Pos_Prn_M_Pre 							: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrEnc_Pos_Prn_M_Err 							: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrEnc_Pos_Prn_M_Err_MM 						: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrEnc_Pos_Prn_M_Err_MM_DisDn 					: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	
// 	alrEnc_Pos_Prn_G_Pre 							: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrEnc_Pos_Prn_G_Err 							: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrEnc_Pos_Prn_G_Err_MM 						: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
// 	alrEnc_Pos_Prn_G_Err_MM_DisDn 					: ARRAY[1..MAX_UNIT_NUM] OF LREAL;
	
	rGirthStep_Kp : REAL;
	rGirthStep_Kd : REAL;
	
	arErrLength_Band 								: ARRAY[1..MAX_UNIT_NUM] OF REAL;
	rBandLengthNotAdjArea 							: REAL;
	
//2025.05.20.145804 | 修复使用32位累加值的时候高速计算会差周期的BUG	
	//audiSkirtTime_Pre : ARRAY[1..MAX_UNIT_NUM] OF UDINT;
	//audiSkirtEncSrc_Pre : ARRAY[1..MAX_UNIT_NUM] OF UDINT;
	//audiSkirtTime_AdjPre : ARRAY[1..MAX_UNIT_NUM] OF UDINT;
	//audiSkirtEncSrc_AdjPre : ARRAY[1..MAX_UNIT_NUM] OF UDINT;
	
	arLength_Band :  ARRAY[1..MAX_UNIT_NUM] OF REAL;
	
	axInit : ARRAY[1..MAX_UNIT_NUM] OF BOOL;
	
	arLen_Alarm : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	arGirth_BottomRoller_Pre: ARRAY [1..MAX_UNIT_NUM] OF REAL;
	
	astLatch_Pre: ARRAY[1..MAX_UNIT_NUM] OF StLatch;
END_VAR


{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam <> 0 AND 
		i_pastStInteraction <> 0 THEN
		
		pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
//2024.12.30.161904 | 带长计算方法进行修改
		FOR iN := 1 TO i_iUnitNum BY 1 DO
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);
//2025.05.20.145804 | 修复使用32位累加值的时候高速计算会差周期的BUG	
//2025.06.25.223355 | 修复速度为0时还会计算调整带长的BUG
//2025.07.09.083543 | 增加跳板避让料头过程中不计算带长不调整
			IF pstStGrpParam_UnSave^.rVel_Cur>0  AND
				(astLatch_Pre[iN].udiTriggerTimeErr <> i_pastLatch^[iN].udiTriggerTimeErr OR astLatch_Pre[iN].udiTriggerEncErr <> i_pastLatch^[iN].udiTriggerEncErr) AND 
					pstStUnitParam_Save^.xLinkage THEN
				IF NOT axInit[iN] THEN
					axInit[iN] := TRUE;
					axDI_Positive[iN] := FALSE;
				ELSE
					axDI_Positive[iN] := TRUE;
				END_IF
				
				axDI_Positive_Count[iN] := 0;
				astLatch_Pre[iN].udiTriggerEncErr := i_pastLatch^[iN].udiTriggerEncErr;
				astLatch_Pre[iN].udiTriggerTimeErr := i_pastLatch^[iN].udiTriggerTimeErr;
			END_IF
			
// 			IF pstStGrpParam_UnSave^.xFlag_Print THEN
// 				IF NOT i_pastStInteraction^[iN].i_xPressEngageSignal THEN
// 					axDI_Positive[iN] := FALSE;
// 				END_IF
// 			END_IF

			
			IF axDI_Positive[iN] THEN
				axDI_Positive_Count[iN] := axDI_Positive_Count[iN] + 1;
			END_IF
		
			IF  axDI_Positive_Count[iN] > 0 AND axDI_Positive[iN] THEN
				axDI_Positive[iN] := FALSE;
				axDI_Positive_Count[iN] := 0;
				IF iN=1 THEN
					//audiSkirtEncPos[iN] := i_paudiSkirtTime^[iN,7];
// 					alrGear_Aux_Prf_Pos[iN] := 0;
// 					alrGear_Aux_Prf_Pos_Pre[iN] := 0;	
				//ELSE	
					//audiSkirtEncPos[iN] := i_paudiSkirtTime^[iN,7];
				END_IF
				
// 				alrGear_Aux_Prf_Pos_Err[iN] := alrGear_Aux_Prf_Pos[iN] - alrGear_Aux_Prf_Pos_Pre[iN];
// 				alrGear_Aux_Prf_Pos_Pre[iN] := alrGear_Aux_Prf_Pos[iN];
				
				arLen_Alarm[iN] := pstStGrpParam_Save^.rLength_Band_Confirm-8;
				
				lrBandLength_Min := arLen_Alarm[iN]* gc_diVirEncPPR_New*
										UINT_TO_LREAL(pstStGrpParam_Save^.uiNum_BottomRoller)/
										UINT_TO_LREAL(pstStGrpParam_Save^.uiDen_BottomRoller)/
										pstStGrpParam_Save^.rGirth_BottomRoller;
				lrBandLength_Max := lrBandLength_Min +
										2*((pstStGrpParam_Save^.rLength_Band_Confirm - arLen_Alarm[iN])*gc_diVirEncPPR_New*
										UINT_TO_LREAL(pstStGrpParam_Save^.uiNum_BottomRoller)/
										UINT_TO_LREAL(pstStGrpParam_Save^.uiDen_BottomRoller)/
										pstStGrpParam_Save^.rGirth_BottomRoller);

				lrBandLength := i_pastLatch^[iN].udiTriggerEncErr;//    UDINT_TO_LREAL(audiSkirtEncPos[iN]);

				IF lrBandLength > lrBandLength_Min AND lrBandLength < lrBandLength_Max THEN
					aiCheckBandLenErrCount[iN] := 0;//清除带长异常计数
					g_axCheckBandLenErr[iN] := FALSE;
					aiCount[iN] := aiCount[iN] + 1;//带长值正常，是否需要去掉最大最小值？
					//2026.1.14.181226 | + | 对滤波次数增加除0保护
					IF pstStUnitParam_Save^.iBandLengthFilterCnt=0 THEN
						pstStUnitParam_Save^.iBandLengthFilterCnt := 10;
					END_IF					
					IF aiCount[iN] > pstStUnitParam_Save^.iBandLengthFilterCnt THEN
						IF g_xRemoveExtremum THEN
							alrBandLengthList[iN,aiCount[iN]] := lrBandLength;
							FOR iM := 1 TO aiCount[iN]-1 BY 1 DO
								alrBandLengthList[iN,iM] := alrBandLengthList[iN,iM+1];
							END_FOR
							FOR iK := 1 TO pstStUnitParam_Save^.iBandLengthFilterCnt BY 1 DO
								alrBandLengthList_BubbleSort[iN,iK] := alrBandLengthList[iN,iK];
							END_FOR
							lrBandLengthSum := 0;
							fbKS_FB_BubbleSort(i_plrArrList:= ADR(alrBandLengthList_BubbleSort[iN,1]), 
												i_iLeft:= 1, 
												i_iRight:= pstStUnitParam_Save^.iBandLengthFilterCnt);
							FOR iM := 2 TO pstStUnitParam_Save^.iBandLengthFilterCnt-1 BY 1 DO
								lrBandLengthSum := lrBandLengthSum + alrBandLengthList_BubbleSort[iN,iM];
							END_FOR
							lrAveBandLength := lrBandLengthSum/(pstStUnitParam_Save^.iBandLengthFilterCnt-2);
							aiCount[iN] := pstStUnitParam_Save^.iBandLengthFilterCnt;
						ELSE
							alrBandLengthList[iN,aiCount[iN]] := lrBandLength;
							FOR iM := 1 TO aiCount[iN]-1 BY 1 DO
								alrBandLengthList[iN,iM] := alrBandLengthList[iN,iM+1];
							END_FOR
							
							lrBandLengthSum := 0;
							FOR iM := 1 TO aiCount[iN]-1 BY 1 DO
								lrBandLengthSum := lrBandLengthSum + alrBandLengthList[iN,iM];
							END_FOR
							lrAveBandLength := lrBandLengthSum/(aiCount[iN]-1);
							aiCount[iN] := pstStUnitParam_Save^.iBandLengthFilterCnt;
						END_IF
					ELSE
						alrBandLengthList[iN,aiCount[iN]] := lrBandLength;
						lrBandLengthSum := 0;
						FOR iM := 1 TO aiCount[iN] BY 1 DO
							lrBandLengthSum := lrBandLengthSum + alrBandLengthList[iN,iM];
						END_FOR
						lrAveBandLength := lrBandLengthSum/aiCount[iN];
					END_IF
				ELSE//出现异常的带长值，连续出现两次开始报警，带长值使用什么呢？？？还是不更新？？？
					aiCheckBandLenErrCount[iN] := aiCheckBandLenErrCount[iN] + 1;
					IF aiCheckBandLenErrCount[iN] > 0 THEN
						g_axCheckBandLenErr[iN] := TRUE;
					ELSE
						;//g_axCheckBandLenErr[iN] := FALSE;
					END_IF
					//rAveBandLength := arBandLengthList[iN,aiCount[iN]];//使用列表中正常的某个值？？？
// 					lrAveBandLength := i_pstStSysParam^.astStUnitParam[iN].rLength_Band * gc_diVirEncPPR_New*
// 										UINT_TO_LREAL(i_pstStSysParam^.uiNum_BottomRoller)/
// 										UINT_TO_LREAL(i_pstStSysParam^.uiDen_BottomRoller)/
// 										i_pstStSysParam^.rGirth_BottomRoller;//使用上一幅计算的值不更新？？？
					//2025.08.25.151728 | 使用标准带长
					lrAveBandLength := pstStGrpParam_Save^.rLength_Band_Confirm * gc_diVirEncPPR_New*
										UINT_TO_LREAL(pstStGrpParam_Save^.uiNum_BottomRoller)/
										UINT_TO_LREAL(pstStGrpParam_Save^.uiDen_BottomRoller)/
										i_pstStSysParam^.astStUnitParam_Save[iN].rGirth_BottomRoller;//使用上一幅计算的值不更新？？？

				END_IF
				i_pstStSysParam^.astStUnitParam_Save[iN].rLength_Band := lrAveBandLength*i_pstStSysParam^.astStUnitParam_Save[iN].rGirth_BottomRoller*
								UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iN].uiDen_BottomRoller)/
								UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iN].uiNum_BottomRoller)/
								DINT_TO_LREAL(gc_diVirEncPPR_New);
								
				g_arTempEncPosBandLength[iN] := lrBandLength *i_pstStSysParam^.astStUnitParam_Save[iN].rGirth_BottomRoller*
								UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iN].uiDen_BottomRoller)/
								UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iN].uiNum_BottomRoller)/
								DINT_TO_LREAL(gc_diVirEncPPR_New);
// 				
				arLength_Band[iN] := lrAveBandLength*pstStGrpParam_Save^.rGirth_BottomRoller*
								UINT_TO_LREAL(pstStGrpParam_Save^.uiDen_BottomRoller)/
								UINT_TO_LREAL(pstStGrpParam_Save^.uiNum_BottomRoller)/
								DINT_TO_LREAL(gc_diVirEncPPR_New);			
								
								
				//audiSkirtEncPos_Pre[iN] := audiSkirtEncPos[iN];
			END_IF
		END_FOR	
//根据是否联动自动调整基准色，若手动输入则按照手动输入值，否则按照首个联动色组		
		IF i_pstStSysParam^.astStUnitParam_Save[g_iSyncBandLen_Unit].xLinkage THEN
			;
			//2025.07.09.103920 | 如果一色参与印刷并且计算带长，强制将基准色改成1
			IF i_pstStSysParam^.astStUnitParam_Save[1].xLinkage AND aiCount[1] >= 5 THEN
				g_iSyncBandLen_Unit := 1;
			END_IF
		ELSE
			FOR iN:= 1 TO i_iUnitNum BY 1 DO
				IF i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
					g_iSyncBandLen_Unit := iN;
					EXIT;
				ELSE
					g_iSyncBandLen_Unit := MAX_UNIT_NUM;
				END_IF
			END_FOR
		END_IF
		//设置标准带长，并计算标准的纵向高度值
		i_pstStSysParam^.stStSysParam_Save.dwCtlSwitchRef.2 := TRUE;
		IF i_pstStSysParam^.stStSysParam_Save.dwCtlSwitchRef.2 THEN
			;
		ELSE
			pstStGrpParam_Save^.rLength_Band_Confirm := i_pstStSysParam^.astStUnitParam_Save[g_iSyncBandLen_Unit].rLength_Band;
		END_IF
		
		IF pstStGrpParam_UnSave^.rVel_Cur = 0 THEN
			FOR iN := 1 TO i_iUnitNum BY 1 DO
				aiCount[iN] := 0;
				aiCount_AdjBand[iN] := 0;
				aiCheckBandLenErrCount[iN] := 0;//清除带长异常计数
				g_axCheckBandLenErr[iN] := FALSE;
				axInit[iN] := FALSE;
			END_FOR
		END_IF
(*
		IF g_xAdjBandLenAll_Open THEN
			g_xAdjBandLenAll_Open := FALSE;
			FOR iN := 1 TO i_iUnitNum BY 1 DO
				i_pstStSysParam^.astStUnitParam_Unsave[iN].xAdjBandLen := TRUE;
			END_FOR
		END_IF
		
		IF g_xAdjBandLenAll_Close THEN
			g_xAdjBandLenAll_Close := FALSE;
			FOR iN := 1 TO i_iUnitNum BY 1 DO
				i_pstStSysParam^.astStUnitParam_Unsave[iN].xAdjBandLen := FALSE;
			END_FOR
		END_IF
*)		
		IF pstStGrpParam_UnSave^.xFlag_Accing OR pstStGrpParam_UnSave^.xFlag_Decing  OR pstStGrpParam_UnSave^.xFlag_Stoping OR pstStGrpParam_UnSave^.rVel_Film<=30 THEN
			rGirthStep_Kp := g_rGirthStepBandLen_Kp * 2;
			rGirthStep_Kd := g_rGirthStepBandLen_Kd * 2;
		ELSE
			rGirthStep_Kp := g_rGirthStepBandLen_Kp;
			rGirthStep_Kd := g_rGirthStepBandLen_Kd;
		END_IF
		
		//计算每个色组的带长误差值
		FOR iN := 1 TO i_iUnitNum BY 1 DO
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iN]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN]);
			
			IF NOT pstStUnitParam_Save^.xLinkage THEN
				pstStUnitParam_UnSave^.xAdjBandLen := FALSE;
			END_IF
//2025.05.20.145804 | 修复使用32位累加值的时候高速计算会差周期的BUG	
//2025.06.25.223355 | 修复速度为0时还会计算调整带长的BUG
//2025.07.09.083543 | 增加跳板避让料头过程中不计算带长不调整
//2025.08.26.091339 | 增加走纸点动带长不调整
			IF pstStUnitParam_Save^.xLinkage AND
				((astLatch_Pre[iN].udiTriggerTimeErr <> i_pastLatch^[iN].udiTriggerTimeErr) OR (astLatch_Pre[iN].udiTriggerEncErr <> i_pastLatch^[iN].udiTriggerEncErr) OR (astLatch_Pre[iN].iTriggerCnt <> i_pastLatch^[iN].iTriggerCnt)) AND
				(*(i_paudiSkirtTime^[iN,1] <> 0) AND*)
				pstStGrpParam_UnSave^.rVel_Cur>0 AND
				(NOT g_axCheckBandLenErr[iN]) AND
				(aiCount[iN] >=8) AND
				(NOT g_xFlag_AxisInch_Print) THEN
				
				IF (iN = g_iSyncBandLen_Unit) AND (g_iSyncBandLen_Unit = 1) THEN
					IF pstStUnitParam_Save^.rGirth_BottomRoller = pstStGrpParam_Save^.rGirth_BottomRoller THEN
						//2025.09.16.095948 | 根据现场情况发现基准色的底辊周长会小于实际值，需要将标准带长值加大一点
						//i_pstStSysParam^.rLength_Band_Confirm := arLength_Band[iN]- 0.002;
						pstStGrpParam_Save^.rLength_Band_Confirm := arLength_Band[iN] + 0.1;
					END_IF
				END_IF
				
				pstStUnitParam_Save^.rErrLength_Band := pstStGrpParam_Save^.rLength_Band_Confirm - arLength_Band[iN];
				//2025.03.24.150735 | 转换为底辊的误差值
				arErrLength_Band[iN] := pstStUnitParam_Save^.rErrLength_Band * pstStGrpParam_Save^.rGirth_BottomRoller/pstStGrpParam_Save^.rLength_Band_Confirm;
				rBandLengthNotAdjArea := pstStGrpParam_Save^.rBandLengthNotAdjArea * pstStGrpParam_Save^.rGirth_BottomRoller/pstStGrpParam_Save^.rLength_Band_Confirm;

				astLatch_Pre[iN].udiTriggerTimeErr := i_pastLatch^[iN].udiTriggerTimeErr;
				astLatch_Pre[iN].udiTriggerEncErr := i_pastLatch^[iN].udiTriggerEncErr;
				astLatch_Pre[iN].iTriggerCnt := i_pastLatch^[iN].iTriggerCnt;
				
				//2025.12.29.112105 | TEST | + 
//				pstStUnitParam_UnSave^.xAdjBandLen := TRUE;
				IF pstStUnitParam_UnSave^.xAdjBandLen THEN
					arGirth_BottomRoller_Pre[iN] := pstStUnitParam_Save^.rGirth_BottomRoller;//2025.08.25.173132 | 临时使用变量，后续标准化
					pstStUnitParam_Save^.rGirth_BottomRoller := pstStGrpParam_Save^.rGirth_BottomRoller;
				END_IF
			
				
				afbKS_FB_AdjustBandLen_II[iN](i_xEn:= pstStUnitParam_UnSave^.xAdjBandLen, 
					i_plrUsingGirth:= ADR(pstStUnitParam_Save^.rGirth_BottomRoller), 
					i_prErrLength_Band:= ADR(arErrLength_Band[iN]),//ADR(pstStUnitParam^.rErrLength_Band),
					i_rBandLengthNotAdjArea := rBandLengthNotAdjArea,//i_pstStSysParam^.rBandLengthNotAdjArea,
					i_rGirthStep_Kp := rGirthStep_Kp,
					i_rGirthStep_Kd := rGirthStep_Kd);
					
				IF (pstStUnitParam_Save^.rGirth_BottomRoller < pstStGrpParam_Save^.rGirth_BottomRoller-1.5) OR 
					(pstStUnitParam_Save^.rGirth_BottomRoller > pstStGrpParam_Save^.rGirth_BottomRoller+1.5) THEN
					pstStUnitParam_Save^.rGirth_BottomRoller := arGirth_BottomRoller_Pre[iN];//i_pstStSysParam^.rGirth_BottomRoller;
				END_IF
			END_IF
		END_FOR		
	END_IF
END_IF


