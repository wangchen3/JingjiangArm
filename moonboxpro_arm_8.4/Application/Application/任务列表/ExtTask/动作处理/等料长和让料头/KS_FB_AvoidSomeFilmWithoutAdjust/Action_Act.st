(*@CES
Name=Action_Act
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ca99e89a-c656-41f4-a467-76c1a0822a83
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2017-08-26 11:11:21
/.等料长是整机让
/.裁切换料是只裁切点前后的米数
*)
IF (i_iGrpId=1 OR i_iGrpId=2) AND
	(i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND
	i_pstStSysParam<>0 AND
	i_pastStIOMap_AxisBasic<>0 THEN


	IF i_iCycleTime_Plc<=0 THEN
		i_iCycleTime_Plc:=gc_TENSION_TSK_CYCLE_TIME;
	END_IF

	(*2023.6.1.144436 移动到if外面*)
	(*
	i_pstStSysParam^.astStUnitParam_Save[1].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[2].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[3].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[4].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[5].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[6].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[7].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[8].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[9].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[10].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[11].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[12].xWaitFilmLength;
	i_pstStSysParam^.astStUnitParam_Save[13].xWaitFilmLength;
	

	i_pstStSysParam^.astStUnitParam_Save[1].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[2].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[3].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[4].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[5].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[6].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[7].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[8].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[9].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[10].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[11].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[12].xWaitFilmLenth_Follow1U;
	i_pstStSysParam^.astStUnitParam_Save[13].xWaitFilmLenth_Follow1U;
	

	i_pstStSysParam^.astStUnitParam_Save[1].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[2].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[3].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[4].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[5].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[6].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[7].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[8].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[9].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[10].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[11].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[12].xWaitFilmLenth_FollowPreU;
	i_pstStSysParam^.astStUnitParam_Save[13].xWaitFilmLenth_FollowPreU;
*)
	(*从第一色开始等料长*)
	fbKS_FB_WaitFilmLenth_2023_Follow1U(
		i_xEn:= i_xEn AND NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xStartAutoFind,(*2026.04.03.194241||wang.xy添加全自动套印使能*)(*等一色的时候不需要考虑全自动套印是否开始，只关心第一个联动色有没有合压*)
		i_xWaitFilmLenthEn:= i_xWaitFilmLenthEn,
		i_pstStSysParam:= i_pstStSysParam,
		i_rVel_Film:= rVel_Film,
		i_iGrpLinkageAxisNum_Pu:= i_iGrpLinkageAxisNum_Pu,
		i_aiGrpLinkageAxisList:= i_aiGrpLinkageAxisList,
		i_xWaitFilmLenth_From1stLinkageAxis:= TRUE,
		i_iCycleTime_Plc:= i_iCycleTime_Plc,
		i_xUseLinkageList:=FALSE,(*2023.08.07.160555*)
		i_paxFlag_PressDne:=i_paxFlag_PressDne,(*2025.1.4.112117+*)
		i_rWatiFilmLenth_Coeff:=1,(*2025.2.18.152901*)
		o_xEn=> ,
		o_xWaitFilmLenthing=> ,
		o_xWaitFilmLenthEd=> ,
		o_axFlag_WaitFilmLenth=> axFlag_WaitFilmLenth_Follow1U,
		o_arWaitFilmLenth=> ,
		o_arMovingFilmLenth=> );


	(*从前一色开始等料长*)
	fbKS_FB_WaitFilmLenth_2023_FollowPreU(
		i_xEn:= i_xEn AND NOT i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xStartAutoFind,//i_xStartAutoFind ,(*全自动套印时候需要在调整以后再开始让前一色料头*)
		i_xWaitFilmLenthEn:= i_xWaitFilmLenthEn,
		i_pstStSysParam:= i_pstStSysParam,
		i_rVel_Film:= rVel_Film,
		i_iGrpLinkageAxisNum_Pu:= i_iGrpLinkageAxisNum_Pu,
		i_aiGrpLinkageAxisList:= i_aiGrpLinkageAxisList,
		i_xWaitFilmLenth_From1stLinkageAxis:= FALSE,
		i_iCycleTime_Plc:= i_iCycleTime_Plc,
		i_xUseLinkageList:=FALSE,(*2023.08.07.160555*)
		i_paxFlag_PressDne:=i_paxFlag_PressDne,(*2025.1.4.112117+*)
		i_rWatiFilmLenth_Coeff:=1.5,(*2025.2.18.152936+*)
		o_xEn=> ,
		o_xWaitFilmLenthing=> ,
		o_xWaitFilmLenthEd=> ,
		o_axFlag_WaitFilmLenth=> axFlag_WaitFilmLenth_FollowPreU,
		o_arWaitFilmLenth=> ,
		o_arMovingFilmLenth=> );

	(*轴参数中标志赋值@2023.6.1.120925*)
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		i_pstStSysParam^.astStUnitParam_Save[iN].xWaitFilmLenth_Follow1U:=axFlag_WaitFilmLenth_Follow1U[iN];(*新增的等待第一色的标志*)
		i_pstStSysParam^.astStUnitParam_Save[iN].xWaitFilmLenth_FollowPreU:=axFlag_WaitFilmLenth_FollowPreU[iN];(*新增的等待前一色的标志*)

		IF i_xWaitFilmLenth_From1stLinkageAxis THEN(*等待料长_从第一色开始等待*)
			i_pstStSysParam^.astStUnitParam_Save[iN].xWaitFilmLength:=i_pstStSysParam^.astStUnitParam_Save[iN].xWaitFilmLenth_Follow1U ;
		ELSE
			i_pstStSysParam^.astStUnitParam_Save[iN].xWaitFilmLength:=i_pstStSysParam^.astStUnitParam_Save[iN].xWaitFilmLenth_FollowPreU ;
		END_IF
	END_FOR

	IF i_xEn THEN (*印刷状态*)
(******************************************************************************************************************)
		xFlag_Cut_end_Uw:=i_xFlag_Cut_end_Uw;

		fbRTrig_CutEnd_Uw(CLK:=xFlag_Cut_end_Uw);(*2023.2.26.220324*)
		IF fbRTrig_CutEnd_Uw.Q AND (NOT xInitial_GiveupHeader) THEN (*开始算出每个颜色要让掉的料长度*)
			xInitial_GiveupHeader:= TRUE;
			rFilmLenth_Last:=0;
			FOR iA:=1 TO MAX_UNIT_NUM BY 1 DO
				abyRunStep_GiveUp[iA]:= 0;
				alrFilmLength_GiveUp[iA]:= 0;
				alrFilmLength_Countdown[iA]:= 0;
			END_FOR

			(*先算出每个颜色要让出的量*)
			(*2024.7.31.165513|计算需要让出的长度*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iAxisId:= i_aiGrpAxisList[iN];
				(*重新修改计算方法@2023.2.26.204102
				最终计算的位置是每一色胶带距离压印点的位置*)
				xRollerPressDneSts:=i_pastStIOMap_AxisBasic^[iAxisId].o_xRel_Press;
				rFilmLenthFromPrevUnit:=LREAL_TO_REAL(i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrFilmLengthFromPrevUnit);(*前一色和当前色之间的料长*)
				rFilmLenth_UnwindToPU1:=LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrFilmLen_UnwindToPU1);(*放料裁切点到1色之间的距离*)
				rFilmLenth_Var:=rFilmLenthFromPrevUnit-LREAL_TO_REAL(i_pstStSysParam^.astStUnitParam_Save[iAxisId].lrPreReg_ConstVal);(*计算可变料长值*)(*2023.3.7.163157*)
				rFilmLenth_Var:=0;(*2024.7.31.163533可变料长清零|不合压的时候不要减去可变料长*)

				(*2024.7.31.165722调整*)
				rFilmLen_NotAdjFront:=LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrFilmLen_NotAdjFront)*i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				rFilmLen_NotAdjBack:=LREAL_TO_REAL(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrFilmLen_NotAdjBack)*i_pstStSysParam^.astStUnitParam_Save[iAxisId].rGirth_PrnRoller;
				IF iN=1 THEN(*计算裁切点到1色的距离*)
					IF xRollerPressDneSts THEN(*压辊合压了*)
						rFilmLenth:=rFilmLenth_UnwindToPU1-rFilmLen_NotAdjFront;(*rFilmLen_NotAdjFront 用于计算出的位置是胶带距离压印点的位置*)
					ELSE(*未合压*)
						(*减小一个可变料长，用于计算下一色到裁切点的料长*)
						rFilmLenth:=rFilmLenth_UnwindToPU1-rFilmLenth_Var-rFilmLen_NotAdjFront;(*rFilmLen_NotAdjFront 用于计算出的位置是胶带距离压印点的位置*)
						IF rFilmLenth<0 THEN
							rFilmLenth:=0;
						END_IF
					END_IF
					rFilmLenth_Last:=rFilmLenth;(*为下一色做准备*)
				ELSE
					IF xRollerPressDneSts THEN(*压辊合压了*)
						rFilmLenth:=rFilmLenth_Last+rFilmLenthFromPrevUnit;
					ELSE(*未合压*)
						rFilmLenth:=rFilmLenth_Last+rFilmLenthFromPrevUnit-rFilmLenth_Var;(*减小一个可变料长，用于计算下一色到裁切点的料长*)
					END_IF
					rFilmLenth_Last:=rFilmLenth;(*更新下*)
				END_IF
				alrFilmLength_Countdown[iAxisId]:=rFilmLenth;(*写入到对应轴的料长变量中*)


				(*把不调整的料长也写好*)
				IF iN<>1 THEN
					(*alrFilmLength_GiveUp[iAxisId]:= pstStGrpParam^.lrFilmLen_NotAdjFront + pstStGrpParam^.lrFilmLen_NotAdjBack;*)
					alrFilmLength_GiveUp[iAxisId]:= rFilmLen_NotAdjFront + rFilmLen_NotAdjBack;(*2024.7.31.165248|*)
					abyRunStep_GiveUp[iAxisId]:= 2;(*进入等待料长到达case*)(*从倒计米数开始*)
				ELSE
					(*1色是没有调整的*)
					alrFilmLength_Countdown[iAxisId]:= 0;
					alrFilmLength_GiveUp[iAxisId]:= 0;
				END_IF
			END_FOR
		ELSIF xInitial_GiveupHeader THEN(*2023.2.26.214912 让料头中*)
			FOR iN:=2 TO i_iGrpAxisNum_Pu BY 1 DO(*检查让料头是不是结束了*)
				IF abyRunStep_GiveUp[in]<>0 THEN(*还有没让完的呢*)
					EXIT;
				ELSE
					IF iN=i_iGrpAxisNum_Pu THEN(*都结束了*)
						xInitial_GiveupHeader:=FALSE;(*复位等待下次触发*)
					END_IF
				END_IF
			END_FOR
		END_IF


		(*---------------------------2017-08-26 14:29:52|
		/.处理让料头的标志
		.----------------------------------------------*)
		lrCurCycleFilmDisplacement:= i_iCycleTime_Plc * i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur / 60.0; (*单位:mm*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			xRollerPressDneSts:=i_pastStIOMap_AxisBasic^[iAxisId].o_xRel_Press;(*2023.2.26.213516*)
		
			CASE abyRunStep_GiveUp[iAxisId] OF
			2: (*倒计米*)
				IF alrFilmLength_Countdown[iAxisId] > lrCurCycleFilmDisplacement THEN
					alrFilmLength_Countdown[iAxisId]:= alrFilmLength_Countdown[iAxisId] - lrCurCycleFilmDisplacement;
				ELSE
					alrFilmLength_Countdown[iAxisId]:= 0;
					abyRunStep_GiveUp[iAxisId]:= 1; (*料头来了 congratulations!!!*)
				END_IF

				i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeaderSts:= FALSE; (*清-裁切让料头@2023.2.26.201950*)
			1: (*不调整*)
				IF alrFilmLength_GiveUp[iAxisId] > lrCurCycleFilmDisplacement THEN
					alrFilmLength_GiveUp[iAxisId]:= alrFilmLength_GiveUp[iAxisId] - lrCurCycleFilmDisplacement;
				ELSE
					alrFilmLength_GiveUp[iAxisId]:= 0;
					abyRunStep_GiveUp[iAxisId]:= 0; (*下次该轴就不让料头了*)
				END_IF

				IF xRollerPressDneSts THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeaderSts:= TRUE; (*置位-裁切让料头@2023.2.26.201950*)
				ELSE(*不合压的轴就不用让料头了吧|2023.2.26.213611*)
					i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeaderSts:= FALSE; (*清-裁切让料头@2023.2.26.201950*)
				END_IF
			ELSE
				i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeaderSts:= FALSE; (*清-裁切让料头@2023.2.26.201950*)
			END_CASE

			(*根据状态输出@2024.7.26.171000*)
			i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeader:=i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeaderSts AND i_xGiveupHeaderEn;

			(*2024.7.26.213352 重新处理*)
			IF i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeader THEN
				dwTempVal:= SHL(DWORD#1, (iAxisId-1));
				i_pstStSysParam^.stStSysParam_Save.dwAxis_SkipTheHeader:= i_pstStSysParam^.stStSysParam_Save.dwAxis_SkipTheHeader OR dwTempVal; (*置位*)
			ELSE
				dwTempVal:= SHL(DWORD#1, (iAxisId-1));
				dwTempVal:= NOT dwTempVal;
				i_pstStSysParam^.stStSysParam_Save.dwAxis_SkipTheHeader:= i_pstStSysParam^.stStSysParam_Save.dwAxis_SkipTheHeader AND dwTempVal; (*清除*)
			END_IF
		END_FOR
	ELSE
		(*非印刷状态*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= i_aiGrpAxisList[iN];
			i_pstStSysParam^.astStUnitParam_Save[iAxisId].xWaitFilmLength:= FALSE; (*清-开机等料长*)
			i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeader:= FALSE; (*清-裁切让料头*)
			i_pstStSysParam^.astStUnitParam_UnSave[iAxisId].xSkipHeaderSts:= FALSE; (*清-裁切让料头@每次都计算*)

			(*2017-08-26 11:10:30
			/.让料头和等料长标志
			*)
			dwTempVal:= SHL(DWORD#1, (iAxisId-1));
			dwTempVal:= NOT dwTempVal;
			i_pstStSysParam^.stStSysParam_Save.dwAxis_SkipTheHeader:= i_pstStSysParam^.stStSysParam_Save.dwAxis_SkipTheHeader AND dwTempVal; (*清除*)
		END_FOR
		xInitial_WaitFilmLen:= FALSE;
		xInitial_GiveupHeader:= FALSE;
		fbRTrig_CutEnd_Uw(CLK:= FALSE);
		FOR iA:=1 TO MAX_UNIT_NUM BY 1 DO
			abyRunStep_GiveUp[iA]:= 0;
			alrFilmLength_GiveUp[iA]:= 0;
			alrFilmLength_Countdown[iA]:= 0;

		END_FOR
	END_IF
ELSE
	o_xEno:= FALSE;
END_IF