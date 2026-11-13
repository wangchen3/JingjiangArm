(*@CES
Name=KS_FB_AxisHorAdj
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=bd4bc8d3-26df-4dfe-bfb9-1ac44a7e80cd
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisHorAdj(*从站横向*)
(*2022.6.10.161033 修复横向运动限位问题*)
(*屏蔽使用移动到KS_FB_GrpHorAdj函数中*)
(*2025.4.20.104124从站横向运动功能，停机状态取消联动相关|开机状态下非联动轴也可以运动*)
(*已经不使用了@@@@*)
VAR_INPUT
	i_xEn									: BOOL;(*功能块使能*)
	i_iGrpAxisNum_Pu						: INT; (*色组轴数*)
	i_aiGrpAxisList							: ARRAY [1..MAX_UNIT_NUM] OF INT; (*系的轴列表*)
	i_pastStIOMap_AxisBasic					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (*基础io|*)
	i_xFlag_Estop							: BOOL;(*急停标志*)
	i_xFlag_Stop							: BOOL;(*停机标志*)
	i_lrVel_HorzPreRegister					: LREAL;
	i_lrVel_HorzAdjust						: LREAL;
	i_iCycleTime_Plc						: INT;
	i_pastStAxisRapidAdjProf_H				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;(*纵向快速对版|*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_iGrpId: INT;
END_VAR
VAR_OUTPUT

	o_axAxisHorAdjing: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	//pstStAxisParam: POINTER TO StAxisParam;
	pstStIOMap_AxisBasic: POINTER TO StIOMap_Axis_FE;


	lrAdjustVal_H_PerCycle: LREAL;
	axAxisHorAdjSts: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisHorAdj_End: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	iRtn: INT;
	iAdjustment_HorAxisAdj: INT;
	axHorAxisAdjStop: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axHorAxisAdjStart: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xFlag_HorAxisAdj: BOOL;
	wSts_HorzManuPreReg:WORD;
	xAutoMove_H: BOOL;(*2025.4.20.110020+*)
END_VAR


{IMPLEMENTATION}
IF i_xEn AND
	(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND
	i_pastStIOMap_AxisBasic<>0 AND
	i_pastStAxisRapidAdjProf_H<>0 THEN(*2019.11.18.153726_*)

	FOR iN:= 1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];
		pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iUnitId]);

		(*--------------------------------------------------|2019.11.18.153930_*)
		(*横向快速对版改成单个轴处理时放在循环内处理|*)
		iRtn:= KS_FetchRapidAdjValue_H(i_pastStAxisRapidAdjProf_H, iUnitId, ADR(iAdjustment_HorAxisAdj));
		(*2025.4.20.110359 同步*)
		(*2024.01.17.161205 增加清除处理*)
		axHorAxisAdjStart[iUnitId]:= FALSE;
		axHorAxisAdjStop[iUnitId]:= FALSE;
		IF iRtn=0 THEN
			IF iAdjustment_HorAxisAdj=-32767 THEN(*人为停止标志|*)
				axHorAxisAdjStop[iUnitId]:= TRUE;
				axHorAxisAdjStart[iUnitId]:= FALSE;
			ELSIF iAdjustment_HorAxisAdj<>0 THEN
				axHorAxisAdjStop[iUnitId]:= FALSE;
				axHorAxisAdjStart[iUnitId]:= TRUE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]+iAdjustment_HorAxisAdj;
			END_IF
		END_IF


		IF (NOT i_xFlag_Estop) (*AND i_xFlag_Stop*) THEN(*非急停*)
			(*2025.4.20.105720 修改条件*)
			IF i_xFlag_Stop THEN(*不用限制单联动*)
				xAutoMove_H:=TRUE;
			ELSE(*非停机状态下|只有单动的可以*)
				xAutoMove_H:=NOT i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;
			END_IF

			IF (*pstStAxisParam^.xLinkage*)xAutoMove_H THEN
				IF axHorAxisAdjStart[iUnitId] AND (NOT axAxisHorAdjSts[iUnitId]) THEN(*开始运行*)
					axAxisHorAdjSts[iUnitId]:= TRUE;
					axHorAxisAdjStart[iUnitId]:= FALSE;
				END_IF
				IF axHorAxisAdjStop[iUnitId] AND axAxisHorAdjSts[iUnitId] THEN(*停止运行*)
					axAxisHorAdjSts[iUnitId]:= FALSE;
					axHorAxisAdjStop[iUnitId]:= FALSE;
				END_IF
			ELSE
				axHorAxisAdjStart[iUnitId]:= FALSE;
				axHorAxisAdjStop[iUnitId]:= FALSE;
				axAxisHorAdjSts[iUnitId]:= FALSE;
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
				END_IF

			END_IF
		ELSE(*2019.11.20.115512 增加了清除axHorAxisAdjStart
								axHorAxisAdjStop标志|Liu.yt*)
			axHorAxisAdjStart[iUnitId]:= FALSE;
			axHorAxisAdjStop[iUnitId]:= FALSE;
			IF axAxisHorAdjSts[iUnitId] THEN
				axAxisHorAdjSts[iUnitId]:= FALSE;(*急停或者非停机-直接停止运行*)
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
			END_IF
		END_IF

		IF pstStIOMap_AxisBasic^.o_xRel_Press OR (NOT pstStIOMap_AxisBasic^.i_xHorzMotor_FastSpd) THEN
		(*快调/慢调处理*)
			lrAdjustVal_H_PerCycle:= i_lrVel_HorzAdjust*INT_TO_LREAL(i_iCycleTime_Plc);
		ELSE
			lrAdjustVal_H_PerCycle:= i_lrVel_HorzPreRegister*INT_TO_LREAL(i_iCycleTime_Plc);
		END_IF

		IF axAxisHorAdjSts[iUnitId] THEN (*色组进入到横向对版状态*)
			xFlag_HorAxisAdj:= TRUE;

			(*2025.4.20.105821 屏蔽联动条件*)
			IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage OR TRUE THEN(*色组联动*)
				IF NOT axAxisHorAdj_End[iUnitId] THEN
					IF NOT o_axAxisHorAdjing[iUnitId] THEN
						o_axAxisHorAdjing[iUnitId]:= TRUE;
						(*横向对版量叠加到横向手动粗调仓库*)
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= -i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]*1000;(*单位um*)
					ELSE
(*2022.6.10.160946*)
(*
						IF pstStIOMap_AxisBasic^.i_xPosLimit_Left OR pstStIOMap_AxisBasic^.i_xPosLimit_Right THEN (*到达左右限位，直接清零调整量*)
							pstStAxisParam^.alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
						END_IF
*)

						IF (pstStIOMap_AxisBasic^.i_xPosLimit_Right AND i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<0) OR
							(pstStIOMap_AxisBasic^.i_xPosLimit_Left AND i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]>0) THEN
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
						END_IF


						IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]=0 THEN(*调整量消耗完成*)
							o_axAxisHorAdjing[iUnitId]:= FALSE;
							axAxisHorAdj_End[iUnitId]:= TRUE;
							axAxisHorAdjSts[iUnitId]:= FALSE;
						END_IF
					END_IF
				END_IF
			ELSE(*单动*)
				o_axAxisHorAdjing[iUnitId]:= FALSE;
				axAxisHorAdj_End[iUnitId]:= TRUE;
				axAxisHorAdjSts[iUnitId]:= FALSE;
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
				END_IF
			END_IF
		ELSE
			IF xFlag_HorAxisAdj THEN
				xFlag_HorAxisAdj:= FALSE;
			END_IF
			o_axAxisHorAdjing[iUnitId]:= FALSE;
			axAxisHorAdj_End[iUnitId]:= FALSE;
			IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN(*退出横向对版状态，调整量清零*)
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
			END_IF
		END_IF


		IF axAxisHorAdjSts[iUnitId] THEN
			IF ABS(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2])>lrAdjustVal_H_PerCycle THEN
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]>0 THEN
					(*正向*)
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2]:= lrAdjustVal_H_PerCycle;
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2];
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuCoarse_done_vh[2]:= FALSE;
					pstStIOMap_AxisBasic^.o_xHorzMotor_CW:= TRUE;(*正转*)
					pstStIOMap_AxisBasic^.o_xHorzMotor_CCW:= FALSE;
				ELSE
					(*反向*)
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2]:= -lrAdjustVal_H_PerCycle;
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2];
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuCoarse_done_vh[2]:= FALSE;
					pstStIOMap_AxisBasic^.o_xHorzMotor_CCW:= TRUE;(*反转*)
					pstStIOMap_AxisBasic^.o_xHorzMotor_CW:= FALSE;
				END_IF
			ELSE
				IF o_axAxisHorAdjing[iUnitId] THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
				END_IF
				pstStIOMap_AxisBasic^.o_xHorzMotor_CW:= FALSE;
				pstStIOMap_AxisBasic^.o_xHorzMotor_CCW:= FALSE;
			END_IF

		END_IF
(*往从站发送*)
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPos_HorzManuPreReg:= -LREAL_TO_INT(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]/1000);

		wSts_HorzManuPreReg.0:= o_axAxisHorAdjing[iUnitId];
		wSts_HorzManuPreReg.1:= pstStIOMap_AxisBasic^.o_xHorzMotor_CW;
		wSts_HorzManuPreReg.2:= pstStIOMap_AxisBasic^.o_xHorzMotor_CCW;
		wSts_HorzManuPreReg.3:= pstStIOMap_AxisBasic^.i_xPosLimit_Left;
		wSts_HorzManuPreReg.4:= pstStIOMap_AxisBasic^.i_xPosLimit_Right;
		wSts_HorzManuPreReg.5:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;

		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSts_HorzManuPreReg:= wSts_HorzManuPreReg;
	END_FOR


END_IF