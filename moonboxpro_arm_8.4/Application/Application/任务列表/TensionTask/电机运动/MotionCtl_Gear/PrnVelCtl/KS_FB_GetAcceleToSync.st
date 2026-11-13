(*@CES
Name=KS_FB_GetAcceleToSync
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1e03253e-94af-4af4-b6f9-e65dddefd7f7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GetAcceleToSync(*计算为了停止再开速度同步时位置同步的加速度*)
(*2022.11.29.232720 轴速度是带方向|计算取值需要增加取绝对值*)
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT; (*色组轴数量*)
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pstStGrpParam: POINTER TO StGrpParam;(*系参数访问入口|*)
	i_paiGrpAxisList: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT; (*系内所有轴的列表*)
//	i_pastStAxisParam: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxisParam;
	i_pabyAxisMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF BYTE;(*轴运动状态*)
	i_palrAcceleToSync:POINTER TO ARRAY [1..16] OF LREAL;(*同步加速度*)
	i_palrTimeToSync:POINTER TO ARRAY [1..16] OF LREAL;(*同步加到目标速度的时间*)
	i_palrRelatePos_Final:POINTER TO ARRAY [1..16,1..16] OF LREAL;(*做成16个轴|
													记录目标轴和当前轴的相对位置值|最后恢复的位置差
													一维下标为当前轴号，二维下标为目标轴号*)
	i_palrRelatePosToSync:POINTER TO ARRAY [1..16,1..16] OF LREAL;(*做成16个轴|
												记录目标轴和当前轴的相对位置值|开始切换到同步状态时的位置差
												一维下标为当前轴号，二维下标为目标轴号*)
	(*2022.7.17.165046 增加标志表征从同步状态退出到了其他状态|*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
END_VAR
VAR
	iN: INT;
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	abyLastAxisMotionSts: ARRAY [1..MAX_STATION_NUM] OF BYTE;(*轴运动状态上个周期值*)
	iUnitId: INT;

	aiUnitId_Tar: ARRAY [1..16] OF INT;(*目标轴号|下标为当前轴号*)
	iUnitId_Tar: INT;
	alrVel_Sa: ARRAY [1..16] OF LREAL;(*起始速度*)
	alrVel_Tar: ARRAY [1..16] OF LREAL;(*目标速度*)
	lrTimeToSync:LREAL;(*去同步状态的时间|到达速度时位置同步*)
	axAxisMotionSts_0ToNot0:ARRAY [1..16] OF BOOL;(*轴状态从0切换到非0标志|用来防止开机时候有轴处于2
												状态-切换到5状态时候触发计算同步函数*)
END_VAR
{IMPLEMENTATION}
IF i_iGrpAxisNum_Pu>1 AND(*最少2个轴*)
	i_paiGrpAxisList<>0 AND
//	i_pastStAxisParam<>0 AND
	i_pabyAxisMotionSts<>0 AND
	i_pstStSysParam<>0 AND
	i_palrAcceleToSync<>0 AND
	i_palrTimeToSync<>0 AND
	i_palrRelatePos_Final<>0 AND
	i_palrRelatePosToSync<>0 THEN

	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:=i_paiGrpAxisList^[iN];
		IF i_palrAcceleToSync<>0 THEN
			i_palrAcceleToSync^[iUnitId]:=0;
		END_IF
		IF i_palrTimeToSync<>0 THEN
			i_palrTimeToSync^[iUnitId]:=0;
		END_IF
	END_FOR

//	i_pastStAxisParam^[1].lrPT_Pos;
//	i_pastStAxisParam^[2].lrPT_Pos;

	IF i_xEn THEN(*使能*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_paiGrpAxisList^[iN];
			pstStUnitParam_Save:=ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			IF iUnitId>0 AND iUnitId<=16 THEN
				(*从同步状态切换出去时记录位置偏差*)
				IF i_pabyAxisMotionSts^[iUnitId]<>0 AND
					abyLastAxisMotionSts[iUnitId]=0 THEN
						axAxisMotionSts_0ToNot0[iUnitId]:=TRUE;
						KS_GetRelatePos(
							iUnitId(*i_iAxisId_Cur*),
							i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
							i_paiGrpAxisList(*i_paiGrpAxisList*),
							ADR(i_pstStSysParam^.astStUnitParam_Save),(*i_pastStAxisParam*)
							ADR(i_pstStSysParam^.astStUnitParam_UnSave),(*i_pastStAxisParam*)
							ADR(i_palrRelatePos_Final^[iUnitId,1])(*i_palrRelatePos*));
				END_IF

				(*由其他状态进入同步运动时的位置偏差值*)
				IF i_pabyAxisMotionSts^[iUnitId]=5 AND
					abyLastAxisMotionSts[iUnitId]<>5 THEN
						KS_GetRelatePos(
							iUnitId(*i_iAxisId_Cur*),
							i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
							i_paiGrpAxisList(*i_paiGrpAxisList*),
							ADR(i_pstStSysParam^.astStUnitParam_Save),(*i_pastStAxisParam*)
							ADR(i_pstStSysParam^.astStUnitParam_UnSave),(*i_pastStAxisParam*)
							ADR(i_palrRelatePosToSync^[iUnitId,1])(*i_palrRelatePos*));

					(*记录当前速度和目标速度*)
					alrVel_Sa[iUnitId]:=ABS(pstStUnitParam_UnSave^.rAxisVel_PrnRoller);
					alrVel_Tar[iUnitId]:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;

					(*寻找合适的目标轴号*)
					aiUnitId_Tar[iUnitId]:=
							KS_GetUnitId_Tar(
								iUnitId(*i_iAxisId_Cur*),
								i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
								i_paiGrpAxisList(*i_paiGrpAxisList*),
								ADR(i_pstStSysParam^.astStUnitParam_Save),(*i_pastStAxisParam*)
								ADR(i_pstStSysParam^.astStUnitParam_UnSave),(*i_pastStAxisParam*)
								i_pabyAxisMotionSts(*i_pabyAxisMotionSts*));

				ELSIF i_pabyAxisMotionSts^[iUnitId]<>5 THEN(*退出了加速到同步状态清除计算标志*)
					aiUnitId_Tar[iUnitId]:=-1;
				END_IF
			END_IF
		END_FOR

		(*计算当前轴的加速度*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:=i_paiGrpAxisList^[iN];
			pstStUnitParam_Save:=ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:=ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
			(*计算当前轴加速到同步速度时的加速度*)
			lrTimeToSync:=0;
			IF iUnitId>0 AND iUnitId<=16 THEN
				iUnitId_Tar:=aiUnitId_Tar[iUnitId];
				IF iUnitId_Tar>0 AND iUnitId_Tar<=16 AND
					axAxisMotionSts_0ToNot0[iUnitId] THEN(*2022.7.17.165820 用来防止开机时候有轴处于2
																状态-切换到5状态时候触发计算同步函数*)
					lrTimeToSync:=KS_CalcMovePara(
										alrVel_Sa[iUnitId](*i_lrVelSa*),
										alrVel_Tar[iUnitId](*i_lrVelTar*),
										gc_iCycleTime_Motion(*i_iDeltime*),
										pstStUnitParam_Save^.rGirth_PrnRoller(*i_lrGirth_Axis*),
										UINT_TO_LREAL(pstStUnitParam_Save^.uiNum_PrnRoller)/pstStUnitParam_Save^.uiDen_PrnRoller(*i_lrReductionRatio*),
										i_palrRelatePosToSync^[iUnitId,iUnitId_Tar](*i_lrDeltPos_Init*),
										i_palrRelatePos_Final^[iUnitId,iUnitId_Tar](*i_lrDeltPos_Final*),
										LREAL_TO_DWORD(GC_LRMOTORPPR)(*i_dwMotorPPR*),
										10(*i_iSetTime*));
				END_IF


				IF i_palrTimeToSync<>0 THEN
					i_palrTimeToSync^[iUnitId]:=lrTimeToSync;
				END_IF
				IF lrTimeToSync>0 THEN
					IF i_palrAcceleToSync<>0 THEN
						i_palrAcceleToSync^[iUnitId]:=(alrVel_Tar[iUnitId]-alrVel_Sa[iUnitId])/lrTimeToSync/1000;
					END_IF
				END_IF
			END_IF
		END_FOR
	ELSE(*非使能*)
		SysMemSet(ADR(axAxisMotionSts_0ToNot0),0,SIZEOF(axAxisMotionSts_0ToNot0));
	END_IF
	o_xEn:=i_xEn;
ELSE
	o_xEn:=FALSE;
END_IF

(*备份状态值*)
IF i_iGrpAxisNum_Pu>1 AND(*最少2个轴*)
	i_paiGrpAxisList<>0 THEN
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:=i_paiGrpAxisList^[iN];
		abyLastAxisMotionSts[iUnitId]:=i_pabyAxisMotionSts^[iUnitId];
	END_FOR
END_IF