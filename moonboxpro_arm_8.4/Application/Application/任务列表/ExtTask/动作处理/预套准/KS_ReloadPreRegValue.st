(*@CES
Name=KS_ReloadPreRegValue
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=57fb531d-4a0f-4c52-9839-1f16e0b31222
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ReloadPreRegValue : INT
(*2022.9.8.120612 只计算联动轴*)
(*2023.6.25.151146 计算的时候取消了联动条件*)
(*2023.10.16.171750 重新启用aiVirEnc_AlignMarkToSamePosition变量作为自动对其mark线位置*)
(*2025.1.14.081723 单色预套功能还要再减去当前色的预套准量*)
(*2025.1.15.125933 1色也会计算调整量*)
VAR_INPUT
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pawAxisVirtualCnt: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.104504/增加的虚拟编码器原始值输入 *)	
	i_pawAxisVirtualSts: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF WORD; (* 2021.6.25.104504/增加的虚拟编码器原始值输入 *)	
	i_palrMovementResult: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	i_piDeltaPhase_MarkPos_FirstLinkage:POINTER TO INT;(*监控使用-第一个非手动预套的轴的信息@2025.1.12.183900*)
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	pstStAxisParam_FirstValidAxis: POINTER TO StUnitParam_Save;

//	pstStPTSts_FirstValidAxis: POINTER TO StPTSts;
//	pstStPTSts: POINTER TO StPTSts;

	iLastServoOnAxisId: INT;
	iFirstValidAxisId: INT;

	aiVirEnc_AxisResult: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiVirEnc_PlatePositionOffset: ARRAY [1..MAX_UNIT_NUM] OF INT; (*装版位置绝对差*)
	aiVirEnc_AlignMarkToSamePosition: ARRAY [1..MAX_UNIT_NUM] OF INT; (*对齐码刻线要移动的脉冲数*)
	aiVirEnc_AxisPreRegister: ARRAY [1..MAX_UNIT_NUM] OF INT;

	(*2025.1.12.180103*)
	iDeltaPhase_MarkPos_NotManuPreRegister1st:INT:=0;(*第一个不是手动预套的轴 距离mark位置的相位值@初值给个特殊值*)
END_VAR
{IMPLEMENTATION}
IF (i_iGrpId=1 OR i_iGrpId=2) AND
	(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND
	i_pstStSysParam<>0 AND
	i_palrMovementResult<>0 THEN
	;
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		aiVirEnc_PlatePositionOffset[iN]:= 0;
		aiVirEnc_AlignMarkToSamePosition[iN]:= 0;
		aiVirEnc_AxisPreRegister[iN]:= 0;
		aiVirEnc_AxisResult[iN]:= 0;
		i_palrMovementResult^[iN]:= 0;
	END_FOR

	(*2025.1.15.132938 移动*)
	(*先计算第一个非手动预套的轴联动色,当前位置距离mark线的值*)
	(*iPhase_InstallPlate 变量作为记录预套前的mark位置,用于实现单轴的预套准*)
	iDeltaPhase_MarkPos_NotManuPreRegister1st:=gc_iVirEncPPR;(*初值给个特殊值*)
	IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xPreRegisterAxisId_Manu THEN(*2025.1.14.142427 单轴预套的时候*)
		IF iDeltaPhase_MarkPos_NotManuPreRegister1st = gc_iVirEncPPR THEN(*第一个非手动预套的轴标记记录*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];
				
//				pstStPTSts:= ADR(i_pastStPTSts^[iAxisId]);
				(*预套准本身要走的量@后面计算要用*)
				
				aiVirEnc_AxisPreRegister[iUnitId]:=
					LREAL_TO_INT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].lrPreReg_Length_V/ i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller * gc_iVirEncPPR);
				IF NOT i_pstStSysParam^.astStUnitParam_Save[iUnitId].xPreRegisterValid_Manu THEN
					iDeltaPhase_MarkPos_NotManuPreRegister1st:=(*当前位置-记录的mark位置*)
						KS_GetPhaseValue(i_pawAxisVirtualCnt^[iUnitId],gc_iVirEncPPR)-i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate;
					(*2025.1.14.081723 还要再减去当前色的预套准量*)
					iDeltaPhase_MarkPos_NotManuPreRegister1st:=iDeltaPhase_MarkPos_NotManuPreRegister1st-aiVirEnc_AxisPreRegister[iUnitId];

					IF iDeltaPhase_MarkPos_NotManuPreRegister1st<0 THEN
						iDeltaPhase_MarkPos_NotManuPreRegister1st:=iDeltaPhase_MarkPos_NotManuPreRegister1st+gc_iVirEncPPR;
					END_IF
					EXIT;
				END_IF
			END_FOR
		END_IF
	END_IF


	iFirstValidAxisId:= -1;
	iLastServoOnAxisId:= -1;
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];
		
//		pstStPTSts:= ADR(i_pastStPTSts^[iAxisId]);

			IF NOT (iFirstValidAxisId>=1 AND iFirstValidAxisId<=MAX_UNIT_NUM) THEN
				iFirstValidAxisId:= iUnitId;
			END_IF

			(*第一个轴不运动 从第二个轴开始运动*)
			IF iFirstValidAxisId>=1 AND iFirstValidAxisId<=MAX_UNIT_NUM THEN
				;
				pstStAxisParam_FirstValidAxis:= ADR(i_pstStSysParam^.astStUnitParam_Save[iFirstValidAxisId]);
//				pstStPTSts_FirstValidAxis:= ADR(i_pastStPTSts^[iFirstValidAxisId]);

				(*这个差值就是码刻线在同一位置，虚拟码盘的绝对差@未使用*)
				aiVirEnc_PlatePositionOffset[iUnitId]:=
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate-pstStAxisParam_FirstValidAxis^.iPhase_InstallPlate; (*和不动的第1色版装版位置绝对差*)

				(*预套准本身要走的量*)
				aiVirEnc_AxisPreRegister[iUnitId]:=
					LREAL_TO_INT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].lrPreReg_Length_V/ i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller * gc_iVirEncPPR);

				(*2023.10.16.154812*)
				(*将码刻线对齐需要移动的脉冲数*)
				(*2025.1.12.171650 增加开关条件*)
				(*KS_FB_ProcPhaseOptReq 中增加逻辑实现预套时的mark位置记录*)
				IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAxisInitPhaseTypeWhenPreRegister=1 THEN(*mark线和键槽固定相位时*)
					IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate<>0 AND(*有初始相位|计算需要执行的码盘数*)
						i_pawAxisVirtualSts^[iUnitId].12 THEN(*虚拟马盘是有效的*)
						aiVirEnc_AlignMarkToSamePosition[iUnitId]:=
							i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate-
							KS_GetPhaseValue(i_pawAxisVirtualCnt^[iUnitId],gc_iVirEncPPR);(*当前轴的位置偏差*)

						IF pstStAxisParam_FirstValidAxis^.iPhase_InstallPlate<>0 AND(*第一个轴有初始相位*)
							i_pawAxisVirtualSts^[iFirstValidAxisId].12 THEN(*虚拟马盘是有效的*)
							aiVirEnc_AlignMarkToSamePosition[iUnitId]:=
								aiVirEnc_AlignMarkToSamePosition[iUnitId]+
								KS_GetPhaseValue(i_pawAxisVirtualCnt^[iFirstValidAxisId],gc_iVirEncPPR)-
								pstStAxisParam_FirstValidAxis^.iPhase_InstallPlate;(*需要弥补的第一个轴位置偏差*)
						ELSE(*否则就舍弃掉*);
						END_IF
					ELSE
						aiVirEnc_AlignMarkToSamePosition[iUnitId]:=0;
					END_IF
				ELSE(*功能没开，这个计算值就写0*)
					(*iPhase_InstallPlate 变量作为记录预套前的mark位置,用于实现单轴的预套准*)
					(*先计算第一个非手动预套的轴联动色,当前位置距离mark线的值*)
					IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xPreRegisterValid_Manu THEN(*2025.1.14.142427 单轴预套的时候*)
						(*算出偏差*)
						IF iDeltaPhase_MarkPos_NotManuPreRegister1st<>gc_iVirEncPPR THEN
							aiVirEnc_AlignMarkToSamePosition[iUnitId]:=iDeltaPhase_MarkPos_NotManuPreRegister1st;
						END_IF
					ELSE
						aiVirEnc_AlignMarkToSamePosition[iUnitId]:=0;
					END_IF
				END_IF



				(*当前轴本身共走的量*)
				aiVirEnc_AxisResult[iUnitId]:=
					aiVirEnc_AlignMarkToSamePosition[iUnitId] +(*将对齐马克线的相位差加入到当前轴走的量里面|2023.10.16.171901*)
					aiVirEnc_AxisPreRegister[iUnitId] (*+
					aiVirEnc_AxisPreRegister[iLastServoOnAxisId]*); (* 2020.9.11.154445|取消掉之前的色组重复走了的值 *)


				WHILE aiVirEnc_AxisResult[iUnitId]<0 DO
					aiVirEnc_AxisResult[iUnitId]:= aiVirEnc_AxisResult[iUnitId]+gc_iVirEncPPR;
				END_WHILE
				WHILE aiVirEnc_AxisResult[iUnitId]>=gc_iVirEncPPR DO
					aiVirEnc_AxisResult[iUnitId]:= aiVirEnc_AxisResult[iUnitId]-gc_iVirEncPPR;
				END_WHILE

				(*将伺服电机需要走的量输出*)
				//2026.1.6.134228 | + | 不同机器类型处理
				IF g_iMachineryType	= MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
					i_palrMovementResult^[iUnitId]:=
							INT_TO_LREAL(aiVirEnc_AxisResult[iUnitId]) / INT_TO_LREAL(gc_iVirEncPPR) * i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller *
							(GC_LRMOTORPPR) * UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_BottomRoller) / UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_BottomRoller)/
							i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_BottomRoller;
	
					(*2020.9.8.155451 如果电机反转|我们需要将预套准输出值写反|Liu.yt*)
					IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_BottomRoller THEN
						i_palrMovementResult^[iUnitId]:=
								-i_palrMovementResult^[iUnitId];
					END_IF
				ELSE
					i_palrMovementResult^[iUnitId]:=
							INT_TO_LREAL(aiVirEnc_AxisResult[iUnitId]) / INT_TO_LREAL(gc_iVirEncPPR) *
							(GC_LRMOTORPPR) * UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller) / UINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller);
	
					(*2020.9.8.155451 如果电机反转|我们需要将预套准输出值写反|Liu.yt*)
					IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller THEN
						i_palrMovementResult^[iUnitId]:=
								-i_palrMovementResult^[iUnitId];
					END_IF
				END_IF
				

			ELSE
				aiVirEnc_PlatePositionOffset[iUnitId]:= 0;
				aiVirEnc_AlignMarkToSamePosition[iUnitId]:= 0;
				aiVirEnc_AxisPreRegister[iUnitId]:= 0;
				aiVirEnc_AxisResult[iUnitId]:= 0;

				i_palrMovementResult^[iUnitId]:= 0;
			END_IF
			iLastServoOnAxisId:= iUnitId;

			IF NOT (iFirstValidAxisId>=1 AND iFirstValidAxisId<=MAX_UNIT_NUM) THEN
				iFirstValidAxisId:= iLastServoOnAxisId;
			END_IF
(*2023.6.25.151119屏蔽*)
(*		END_IF*)
	END_FOR
END_IF

(*2025.1.12.183940 增加一个监控*)
IF i_piDeltaPhase_MarkPos_FirstLinkage<>0 THEN
	IF iDeltaPhase_MarkPos_NotManuPreRegister1st<>gc_iVirEncPPR THEN
		i_piDeltaPhase_MarkPos_FirstLinkage^:=iDeltaPhase_MarkPos_NotManuPreRegister1st;
	END_IF
END_IF