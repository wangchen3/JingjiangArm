(*@CES
Name=KS_FB_AxisTrapPosCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2e2173c6-f3c4-47fe-9b59-d4fa6be54b09
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisTrapPosCtl(*预套准、相位回复等位置计0算*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pastStWatch_Sts_display_Prn				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StWatch_Sts_display;
	//i_pastStWatch_Sts_display_Bottom			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StWatch_Sts_display;
	i_pawAxisVirtualCnt: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.104504/增加的虚拟编码器原始值输入 *)	
	i_pawAxisVirtualSts: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.104504/增加的虚拟编码器原始值输入 *)	
	i_diTime_PreReg: DINT:=5000;//5s内走完

	i_padiPreRegisterPos: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF DINT;
	i_palrMaxVel_PreReg: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;//预套准最大速度-时间固定，速度不同
	//2024.10.22.193803增加单圈绝对位置计算预套准
	//i_padiEncPos_Virtual_start_0: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF DINT;	
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;	
END_VAR
VAR
	fbRTrig_Home: R_TRIG;
	fbRTrig_PreRegister: R_TRIG;
	fbRTrig_PhaseRestore: R_TRIG;
	xCalcAdjustPos: BOOL:= FALSE;
	iN: INT;
	iUnitId:INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	lrMotorPPR_temp: LREAL;
	alrMotorNeedMovePos_Pul: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	alrAxisMotorPulseMovement: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	
	xFlag_PreRegValueReloaded: BOOL;
	axVirEncOffsetInitialized: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	iTemp: INT;
	alrMaxVel_PreReg: ARRAY [1..MAX_UNIT_NUM] OF LREAL;//预套准最大速度-时间固定，速度不同
	alrMotorNeedMovePos_Temp_PreReg_test: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	iDeltaPhase_MarkPos_FirstLinkage: INT;
	iTmp: INT;
	wVirtuaCnt_Temp: WORD;
	
	iAxisId : INT;
	xFlag_PreReg:BOOL;
	xFlag_PreReg_End:BOOL;
	iTimeCnt: INT;
	
	lrTmp : LREAL;
	lrTmp1 : LREAL;
	rMaxAdjust : REAL;
	rAcc_TargetAxis : REAL := 2.0;
	rTime_Acc : REAL;
	arTargetVel : ARRAY [1..MAX_UNIT_NUM] OF REAL;
	xFlag_PreReg_Finished : BOOL;
	
	iTypeId: INT;
	iCoreId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF	i_pstStSysParam<>0 AND i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM  AND
		 i_pawAxisVirtualCnt<>0 AND i_padiPreRegisterPos<>0 AND i_palrMaxVel_PreReg<>0AND
		i_diTime_PreReg<>0 AND i_pastStGetMotionSts <> 0 THEN
		pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		fbRTrig_Home(CLK:= pstStGrpParam_UnSave^.xFlag_Home);
		fbRTrig_PreRegister(CLK:= pstStGrpParam_UnSave^.xFlag_PreRegister);
		fbRTrig_PhaseRestore(CLK:= pstStGrpParam_UnSave^.xFlag_PhaseRestore);
	
		IF fbRTrig_Home.Q OR fbRTrig_PreRegister.Q OR fbRTrig_PhaseRestore.Q THEN
			IF pstStGrpParam_UnSave^.xFlag_Home THEN
				pstStGrpParam_UnSave^.xFlag_Home_end:= FALSE;
			ELSIF pstStGrpParam_UnSave^.xFlag_PreRegister THEN
				pstStGrpParam_UnSave^.xFlag_PreRegister_end:= FALSE;
			ELSIF pstStGrpParam_UnSave^.xFlag_PhaseRestore THEN
				pstStGrpParam_UnSave^.xFlag_PhaseRestore_end:= FALSE;				
			END_IF
			
			xCalcAdjustPos:= TRUE;
		END_IF
		
		IF (NOT pstStGrpParam_UnSave^.xFlag_Home) AND 
			(NOT pstStGrpParam_UnSave^.xFlag_PreRegister) AND 
			(NOT pstStGrpParam_UnSave^.xFlag_PhaseRestore) THEN
			xFlag_PreRegValueReloaded:= FALSE;
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpUnitList[iUnitId];
				axVirEncOffsetInitialized[iUnitId]:=FALSE;
			END_FOR
		END_IF
		
		IF xCalcAdjustPos THEN
			xCalcAdjustPos:= FALSE;//只计算一次2023.08.11.180238
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpUnitList[iN];
				pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
				IF pstStGrpParam_UnSave^.xFlag_Home THEN
					IF pstStUnitParam_Save^.xLinkage THEN(*只计算联动轴|2022.9.8.120509*)
						//2026.1.6.134228 | + | 不同机器类型处理
						IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
							IF pstStUnitParam_UnSave^.xMotRev_BottomRoller THEN
								lrMotorPPR_temp:= -(GC_LRMOTORPPR)* pstStUnitParam_Save^.rGirth_PrnRoller *pstStUnitParam_Save^.uiNum_BottomRoller / pstStUnitParam_Save^.uiDen_BottomRoller/pstStUnitParam_Save^.rGirth_BottomRoller;
							ELSE
								lrMotorPPR_temp:= (GC_LRMOTORPPR)* pstStUnitParam_Save^.rGirth_PrnRoller *pstStUnitParam_Save^.uiNum_BottomRoller / pstStUnitParam_Save^.uiDen_BottomRoller/pstStUnitParam_Save^.rGirth_BottomRoller;
							END_IF
						ELSE
							IF pstStUnitParam_UnSave^.xMotRev_PrnRoller THEN
								lrMotorPPR_temp:= -(GC_LRMOTORPPR)* pstStUnitParam_Save^.uiNum_PrnRoller / pstStUnitParam_Save^.uiDen_PrnRoller;
							ELSE
								lrMotorPPR_temp:= (GC_LRMOTORPPR)* pstStUnitParam_Save^.uiNum_PrnRoller / pstStUnitParam_Save^.uiDen_PrnRoller;
							END_IF
						END_IF
						
						alrMotorNeedMovePos_Pul[iUnitId]:=lrMotorPPR_temp;
						alrMotorNeedMovePos_Pul[iUnitId]:=lrMotorPPR_temp*2;
					END_IF
				(*2017-09-13 13:26:39|
				/.预套准
				*)
				ELSIF pstStGrpParam_UnSave^.xFlag_PreRegister THEN
					IF NOT xFlag_PreRegValueReloaded THEN
						KS_ReloadPreRegValue(
							i_iGrpId,
							i_iGrpAxisNum_Pu,
							i_aiGrpUnitList,
							i_pstStSysParam,
							i_pawAxisVirtualCnt,
							i_pawAxisVirtualSts,
							ADR(alrAxisMotorPulseMovement),
							ADR(iDeltaPhase_MarkPos_FirstLinkage));
						xFlag_PreRegValueReloaded:= TRUE;
					END_IF

					IF pstStGrpParam_Save^.xPreRegisterAxisId_Manu THEN(*预套准id手动选择@2025.1.12.193735*)
						IF pstStUnitParam_Save^.xPreRegisterValid_Manu AND(*有效了@则进行预套*)
							pstStUnitParam_Save^.xLinkage THEN
							alrMotorNeedMovePos_Pul[iUnitId]:=alrAxisMotorPulseMovement[iUnitId];
						END_IF
					ELSE
						IF pstStUnitParam_Save^.xLinkage THEN(*只计算联动轴|2022.9.8.120509*)
							alrMotorNeedMovePos_Pul[iUnitId]:=alrAxisMotorPulseMovement[iUnitId];
						END_IF
					END_IF

				(*2017-09-13 13:26:58|
				/.相位恢复
				*)
				ELSIF pstStGrpParam_UnSave^.xFlag_PhaseRestore THEN
					IF pstStUnitParam_Save^.xLinkage THEN(*只计算联动轴|2022.9.8.120509*)
						//IF NOT axVirEncOffsetInitialized[iUnitId] THEN
(*deprecated@2021.6.25.113401
							IF i_pastStPTSts^[iAxisId].virtualCnt>= pstStAxisParam^.iPhase_RegisterOk THEN (*当前位置在相位点之后|那么移动的是一个补值*)
								iTemp:= (pstStAxisParam^.iPhase_RegisterOk-i_pastStPTSts^[iAxisId].virtualCnt+gc_iVirEncPPR);
with/
*)
							IF i_pawAxisVirtualCnt^[iUnitId] >= pstStUnitParam_Save^.iPhase_RegisterOk THEN (* 2021.6.25.113420/ *)
								iTemp:= (pstStUnitParam_Save^.iPhase_RegisterOk - i_pawAxisVirtualCnt^[iUnitId] + gc_iVirEncPPR); (* 2021.6.25.113649/ *)
								WHILE iTemp<0 DO
									iTemp:= iTemp+gc_iVirEncPPR;
								END_WHILE
								//2026.1.6.134228 | + | 不同机器类型处理
								IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.rGirth_PrnRoller *pstStUnitParam_Save^.uiNum_BottomRoller / pstStUnitParam_Save^.uiDen_BottomRoller/pstStUnitParam_Save^.rGirth_BottomRoller );
								ELSE
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.uiNum_PrnRoller / pstStUnitParam_Save^.uiDen_PrnRoller);
								END_IF
							ELSE (*还没到相位点*)
(*deprecated@2021.6.25.113607
								iTemp:= pstStAxisParam^.iPhase_RegisterOk-i_pastStPTSts^[iAxisId].virtualCnt;
with/
*)
								iTemp:= pstStUnitParam_Save^.iPhase_RegisterOk-i_pawAxisVirtualCnt^[iUnitId]; (* 2021.6.25.113644/ *)
								WHILE iTemp>gc_iVirEncPPR DO
									iTemp:= iTemp-gc_iVirEncPPR;
								END_WHILE
								//2026.1.6.135139 | + | 不同机器类型处理
								IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.rGirth_PrnRoller *pstStUnitParam_Save^.uiNum_BottomRoller / pstStUnitParam_Save^.uiDen_BottomRoller/pstStUnitParam_Save^.rGirth_BottomRoller );
								ELSE
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.uiNum_PrnRoller / pstStUnitParam_Save^.uiDen_PrnRoller);
								END_IF
							END_IF
							//2026.1.6.135139 | + | 不同机器类型处理
							IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
								IF pstStUnitParam_UnSave^.xMotRev_BottomRoller THEN
									alrAxisMotorPulseMovement[iUnitId]:= -alrAxisMotorPulseMovement[iUnitId];
								ELSE;
								END_IF
							ELSE
								IF pstStUnitParam_UnSave^.xMotRev_PrnRoller THEN
									alrAxisMotorPulseMovement[iUnitId]:= -alrAxisMotorPulseMovement[iUnitId];
								ELSE;
								END_IF
							END_IF
							axVirEncOffsetInitialized[iUnitId]:= TRUE;
						END_IF
						alrMotorNeedMovePos_Pul[iUnitId]:=alrAxisMotorPulseMovement[iUnitId];
					//END_IF
(*
				ELSIF i_pxFlag_CphCommonVir^ THEN(*通用相位初始装版相位记录*)
					FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
						iAxisId:= i_aiGrpAxisList[iN];
						//pstStAxisParam:= ADR(i_pstStShmGlobalParam^.astStAxisParam[iAxisId]);
						IF i_pstStSysParam^.astStUnitParam_Save[iAxisId].xServoOn AND
							i_pstStSysParam^.astStUnitParam_Save[iAxisId].xLinkage THEN(*只计算联动轴|2022.9.8.120509*)
							IF i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xMotRev_PrnRoller THEN
								lrMotorPPR_temp:= -DWORD_TO_LREAL(gc_dwMotorPPR)* i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiNum_PrnRoller / i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiDen_PrnRoller;
							ELSE
								lrMotorPPR_temp:= DWORD_TO_LREAL(gc_dwMotorPPR)* i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiNum_PrnRoller / i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiDen_PrnRoller;
							END_IF
							alrMotorNeedMovePos_Pul[iAxisId]:=lrMotorPPR_temp;
						END_IF
					END_FOR
				ELSIF i_pxCphaseRestore^ THEN(*通用相位恢复*)
					FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
						iAxisId:= i_aiGrpAxisList[iN];
						//pstStAxisParam:= ADR(i_pstStShmGlobalParam^.astStAxisParam[iAxisId]);
						IF i_pstStSysParam^.astStUnitParam_Save[iAxisId].xServoOn AND
							i_pstStSysParam^.astStUnitParam_Save[iAxisId].xLinkage THEN(*只计算联动轴|2022.9.8.120509*)
							IF NOT axVirEncOffsetInitialized[iAxisId] THEN
								iTemp:= i_pstStSysParam^.astStUnitParam_Save[iAxisId].iPhase_FinalUsed;
								alrAxisMotorPulseMovement[iAxisId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * (DWORD_TO_LREAL(gc_dwMotorPPR) * pstStAxisParam^.uiNum / pstStAxisParam^.uiDen);
								axVirEncOffsetInitialized[iAxisId]:= TRUE;
								IF i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xMotRev_PrnRoller THEN
									alrAxisMotorPulseMovement[iAxisId]:= -alrAxisMotorPulseMovement[iAxisId];
								ELSE;
								END_IF
							END_IF
							alrMotorNeedMovePos_Pul[iAxisId]:=alrAxisMotorPulseMovement[iAxisId];
						END_IF
					END_FOR
					*)
				ELSIF pstStGrpParam_Save^.xFlag_PhaseRead THEN(*固定相位恢复|2024.9.6.214324*)
					IF pstStUnitParam_Save^.xLinkage THEN(*只计算联动轴|2022.9.8.120509*)
						IF NOT axVirEncOffsetInitialized[iUnitId] THEN
							iTmp:=KS_GetPhaseValue(i_pawAxisVirtualCnt^[iUnitId],gc_iVirEncPPR);(*2023.6.28.113035 更新*)
							wVirtuaCnt_Temp:=INT_TO_WORD(iTmp);
							IF wVirtuaCnt_Temp >= pstStUnitParam_Save^.iPhase_Locating THEN (* 2021.6.25.113420/ *)
								iTemp:= (pstStUnitParam_Save^.iPhase_Locating - wVirtuaCnt_Temp + gc_iVirEncPPR); (* 2021.6.25.113649/ *)
								WHILE iTemp<0 DO
									iTemp:= iTemp+gc_iVirEncPPR;
								END_WHILE
								//2026.1.6.135139 | + | 不同机器类型处理
								IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.rGirth_PrnRoller * pstStUnitParam_Save^.uiNum_BottomRoller / pstStUnitParam_Save^.uiDen_BottomRoller/pstStUnitParam_Save^.rGirth_BottomRoller);
								ELSE
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.uiNum_PrnRoller / pstStUnitParam_Save^.uiDen_PrnRoller);
								END_IF
								
							ELSE (*还没到相位点*)
								iTemp:= pstStUnitParam_Save^.iPhase_Locating-wVirtuaCnt_Temp; (* 2021.6.25.113644/ *)
								WHILE iTemp>gc_iVirEncPPR DO
									iTemp:= iTemp-gc_iVirEncPPR;
								END_WHILE
								//2026.1.6.135139 | + | 不同机器类型处理
								IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.rGirth_PrnRoller * pstStUnitParam_Save^.uiNum_BottomRoller / pstStUnitParam_Save^.uiDen_BottomRoller/pstStUnitParam_Save^.rGirth_BottomRoller);
								ELSE
									alrAxisMotorPulseMovement[iUnitId]:= (INT_TO_LREAL(iTemp) / gc_iVirEncPPR) * ((GC_LRMOTORPPR) * pstStUnitParam_Save^.uiNum_PrnRoller / pstStUnitParam_Save^.uiDen_PrnRoller);
								END_IF
								
							END_IF
							//2026.1.6.135139 | + | 不同机器类型处理
							IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
								IF pstStUnitParam_UnSave^.xMotRev_BottomRoller THEN
									alrAxisMotorPulseMovement[iUnitId]:= -alrAxisMotorPulseMovement[iUnitId];
								ELSE;
								END_IF
							ELSE
								IF pstStUnitParam_UnSave^.xMotRev_PrnRoller THEN
									alrAxisMotorPulseMovement[iUnitId]:= -alrAxisMotorPulseMovement[iUnitId];
								ELSE;
								END_IF
							END_IF

							axVirEncOffsetInitialized[iUnitId]:= TRUE;
						END_IF
						alrMotorNeedMovePos_Pul[iUnitId]:=alrAxisMotorPulseMovement[iUnitId];
					END_IF
				ELSE;
				END_IF
(*
				(*预套时间计算*)
				(*参数单位切换*)
				IF i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller<>0 AND i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiDen_PrnRoller<>0 THEN
					alrPreRegisterVel_PPMS[iAxisId]:=INT_TO_LREAL(i_iPreRegisterVel_Max)/i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller/60
													*i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiNum_PrnRoller / i_pstStSysParam^.astStUnitParam_Save[iAxisId].uiDen_PrnRoller*gc_dwMotorPPR;(*电机侧速度|Pul/ms*)
				END_IF

				lrTemp:=0;
				IF alrPreRegisterVel_PPMS[iAxisId]<>0 THEN
					lrTemp:=ABS(alrMotorNeedMovePos_Pul[iAxisId])/alrPreRegisterVel_PPMS[iAxisId];(*计算最大速度匀速运动时间|MS*)
					IF lrTemp>i_iAccTime_MaxVel THEN(*超过了最大速度的加速时间|规划为梯形规划*)
						(*计算实际运动的时间*)
						(*最大速度不变*)
						lrTemp:=lrTemp+i_iAccTime_MaxVel;
						IF alrMotorNeedMovePos_Pul[iAxisId]<0 THEN(*位置小于0速度取反*)
							alrPreRegisterVel_PPMS[iAxisId]:=-alrPreRegisterVel_PPMS[iAxisId];
						END_IF
					ELSIF lrTemp>0 THEN(*规划为不能达到最大速度的三角形规划*)
						(*最大速度被改变了*)
						lrTemp:=i_iAccTime_MaxVel*2;
						IF i_iAccTime_MaxVel<>0 THEN
							alrPreRegisterVel_PPMS[iAxisId]:=(alrMotorNeedMovePos_Pul[iAxisId])/i_iAccTime_MaxVel;
						END_IF
					END_IF
				END_IF

				alrPreRegisterTime_Ms[iAxisId]:=lrTemp;
				*)
				i_padiPreRegisterPos^[iUnitId]:= LREAL_TO_DINT(alrMotorNeedMovePos_Pul[iUnitId]);
				//2025.11.13.191045 | + | 速度计算不对，应该是要计算最大速度，不是平均速度
				//i_palrMaxVel_PreReg^[iUnitId]:= ABS(alrMotorNeedMovePos_Pul[iUnitId])/i_diTime_PreReg;
				rAcc_TargetAxis := 2.0;
				rMaxAdjust:= 0.5*0.5*rAcc_TargetAxis*DINT_TO_REAL(i_diTime_PreReg)*DINT_TO_REAL(i_diTime_PreReg);
				IF ABS(alrMotorNeedMovePos_Pul[iUnitId])>rMaxAdjust THEN
					IF 	alrMotorNeedMovePos_Pul[iUnitId]>0 THEN
						alrMotorNeedMovePos_Pul[iUnitId]:= rMaxAdjust;
					ELSE
						alrMotorNeedMovePos_Pul[iUnitId]:= -rMaxAdjust;
					END_IF
					rTime_Acc:= DINT_TO_REAL(i_diTime_PreReg)*0.5;
					arTargetVel[iUnitId]:=rAcc_TargetAxis*rTime_Acc;
				ELSE
(*
					//知道调整量和调整时间，计算调整速度和加速度
					//S = a*t*t/4;
					//a = s*4/t/t;
					//v = at;
					arAcc_Out[iUnitId] := arTargetPos_Out[iUnitId]*4/arTime_Cycle[iUnitId]/arTime_Cycle[iUnitId];
					arTargetVel_Out[iUnitId] := arAcc_Out[iUnitId] * arTime_Cycle[iUnitId]*0.5 + 0.5;
*)						
				(*计算最大速度*)
				(*一元二次方程x=(-b+SQRT(b²-4ac))/2a*)	
				(*调整量计算公式
				arTargetPos_Out=(arTime_Cycle+arTime_Cycle-2*rTime_Acc)*rAcc_TargetAxis_In_Out*rTime_Acc*0.5*)
					lrTmp1:= ABS(alrMotorNeedMovePos_Pul[iUnitId]);
					lrTmp:= (REAL_TO_LREAL(rAcc_TargetAxis)*REAL_TO_LREAL(rAcc_TargetAxis)*
						DINT_TO_LREAL(i_diTime_PreReg*i_diTime_PreReg));
					lrTmp:= lrTmp-	REAL_TO_LREAL(4*(rAcc_TargetAxis)*lrTmp1);
					lrTmp:= SQRT(lrTmp);
					lrTmp:= -1*rAcc_TargetAxis*DINT_TO_LREAL(i_diTime_PreReg)+lrTmp;
					rTime_Acc:= lrTmp/(-2*rAcc_TargetAxis);
					arTargetVel[iUnitId]:=rAcc_TargetAxis*rTime_Acc;
				END_IF
				i_palrMaxVel_PreReg^[iUnitId]:=arTargetVel[iUnitId];
				
			END_FOR		
		END_IF
		
		//2025.10.29.162354 | bai.zy | 
		IF (pstStGrpParam_UnSave^.xFlag_Home OR pstStGrpParam_UnSave^.xFlag_PreRegister OR pstStGrpParam_UnSave^.xFlag_PhaseRestore) THEN
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				KS_GetAxisIdForMotByStation_V2(
					i_iStationId:= i_pstStSysParam^.astStUnitParam_Save[iN].iStationId,
					i_piAxisId:= ADR(iAxisId), 
					i_piTypeId:= ADR(iTypeId), 
					i_piUnitId:= ADR(iUnitId), 
					i_piCoreId:= ADR(iCoreId), 
					i_piGroupId:= ADR(iGroupId), 
					i_piAdjAxisId:= ADR(iAdjAxisId), 
					i_pstStSysStationInf:= i_pstStSysStationInf);	
				IF NOT xFlag_PreReg THEN
					IF i_pastStGetMotionSts^[iAxisId].dwMotionSts.10 AND
						i_pastStGetMotionSts^[iAxisId].dwMotionSts.9 THEN
						xFlag_PreReg:= TRUE;//预套准/回复相位等已经开始动作
						EXIT;
					END_IF
				END_IF			
			END_FOR
			
			IF xFlag_PreReg THEN
				xFlag_PreReg_End:= TRUE;	
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
					KS_GetAxisIdForMotByStation_V2(
						i_iStationId:= i_pstStSysParam^.astStUnitParam_Save[iN].iStationId,
						i_piAxisId:= ADR(iAxisId), 
						i_piTypeId:= ADR(iTypeId), 
						i_piUnitId:= ADR(iUnitId), 
						i_piCoreId:= ADR(iCoreId), 
						i_piGroupId:= ADR(iGroupId), 
						i_piAdjAxisId:= ADR(iAdjAxisId), 
						i_pstStSysStationInf:= i_pstStSysStationInf);			
					IF i_pastStGetMotionSts^[iAxisId].dwMotionSts.10 AND 
						i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
						xFlag_PreReg_End:= FALSE;
						EXIT;
					END_IF
				END_FOR
			END_IF
			//2025.11.14.145703 | 判断运动状态然后下使能
			IF xFlag_PreReg THEN
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
					KS_GetAxisIdForMotByStation_V2(
						i_iStationId:= i_pstStSysParam^.astStUnitParam_Save[iN].iStationId,
						i_piAxisId:= ADR(iAxisId), 
						i_piTypeId:= ADR(iTypeId), 
						i_piUnitId:= ADR(iUnitId), 
						i_piCoreId:= ADR(iCoreId), 
						i_piGroupId:= ADR(iGroupId), 
						i_piAdjAxisId:= ADR(iAdjAxisId), 
						i_pstStSysStationInf:= i_pstStSysStationInf);			
					IF i_pastStGetMotionSts^[iAxisId].dwMotionSts.10 AND 
						i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
						EXIT;
					END_IF
					
					IF iN = i_iGrpAxisNum_Pu THEN
						xFlag_PreReg_Finished := TRUE;
					END_IF
				END_FOR
			END_IF
			
			iTimeCnt:= iTimeCnt+1;
			IF (xFlag_PreReg_End OR iTimeCnt>(i_diTime_PreReg+1000)/gc_TENSION_TSK_CYCLE_TIME) AND xFlag_PreReg_Finished THEN
				(*IF xFlag_PreReg_End THEN*)
				IF pstStGrpParam_UnSave^.xFlag_Home THEN
					pstStGrpParam_UnSave^.xFlag_Home:= FALSE;
					pstStGrpParam_UnSave^.xFlag_Home_end:= TRUE;
				ELSIF pstStGrpParam_UnSave^.xFlag_PreRegister THEN
					pstStGrpParam_UnSave^.xFlag_PreRegister:= FALSE;
					pstStGrpParam_UnSave^.xFlag_PreRegister_end:=TRUE;
				ELSIF pstStGrpParam_UnSave^.xFlag_PhaseRestore THEN
					pstStGrpParam_UnSave^.xFlag_PhaseRestore:= FALSE;
					pstStGrpParam_UnSave^.xFlag_PhaseRestore_end:=TRUE;										
				END_IF	
				(*END_IF*)
	
			END_IF
		ELSE
			iTimeCnt:= 0;
			xFlag_PreReg_End:= FALSE;
			xFlag_PreReg:=FALSE;
			xFlag_PreReg_Finished := FALSE;
		END_IF
	END_IF
END_IF
