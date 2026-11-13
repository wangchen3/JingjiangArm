(*@CES
Name=Action_SyncParamToSample
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a15681d5-bd2f-4cd2-a15c-8116b58af265
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(* 首次同步参数记录|用以后续检查变动了没有|@2018.5.21.095735 *)
IF NOT xSynchronized_SpecialParam THEN
	xSynchronized_SpecialParam:= TRUE;
	FOR iGrp:=1 TO 2 BY 1 DO
		aiMarkTypeId[iGrp]:= g_stStSysParam.astStGrpParam_Save[iGrp].iMarkTypeId;
		aiMarkArrangeId[iGrp]:= g_stStSysParam.astStGrpParam_Save[iGrp].iMarkArrangeMode;
	END_FOR
END_IF


FOR iGrp:=1 TO 2 BY 1 DO

(* 同步系内的全局设定到色组同步|@2017.8.3.085112 *)
	pstStGrpParam_Save:= ADR(g_stStSysParam.astStGrpParam_Save[iGrp]);
	pstStGrpParam_UnSave:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrp]);

	(* 标记形式 *)
	IF aiMarkTypeId[iGrp]<>pstStGrpParam_Save^.iMarkTypeId THEN
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			pstStUnitParam_Save:= ADR(g_stStSysParam.astStUnitParam_Save[iN]);
			pstStUnitParam_UnSave:= ADR(g_stStSysParam.astStUnitParam_UnSave[iN]);

			IF pstStUnitParam_Save^.byGrpId=INT_TO_BYTE(iGrp) THEN
				pstStUnitParam_Save^.iMarkTypeId:= pstStGrpParam_Save^.iMarkTypeId;
			END_IF
			
		END_FOR
		aiMarkTypeId[iGrp]:= pstStGrpParam_Save^.iMarkTypeId;
	END_IF

(*2025.9.20.103056这里处理放到金刚吧
	(* 标记排列|当选择横排和纵排切换的时候|需要把门内基线自动切换一下|@2019.11.14.102415 *)
	IF aiMarkArrangeId[iGrp]<>pstStGrpParam_Save^.iMarkArrangeMode THEN
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			pstStUnitParam_Save:= ADR(g_stStSysParam.astStUnitParam_Save[iN]);
			pstStUnitParam_UnSave:= ADR(g_stStSysParam.astStUnitParam_UnSave[iN]);
			IF pstStUnitParam_Save^.byGrpId=INT_TO_BYTE(iGrp) THEN
				pstStUnitParam_Save^.iMarkArrangeMode:= pstStGrpParam_Save^.iMarkArrangeMode;
				CASE pstStUnitParam_Save^.iMarkArrangeMode OF
				MARK_ARRANGE_HFOR,MARK_ARRANGE_HREV:(*横排|*)
					IF NOT (aiMarkArrangeId[iGrp]=MARK_ARRANGE_HFOR OR aiMarkArrangeId[iGrp]=MARK_ARRANGE_HREV) THEN
						(* 如果之前是纵排 *)
						IF NOT pstStUnitParam_Save^.dwFlag_Ctl.1 THEN (* 如果没打开门内基线|则我们帮助其默认打开 *)
							pstStUnitParam_Save^.dwFlag_Ctl.1:= TRUE;
						END_IF
					END_IF
				ELSE(*全部当纵排处理|*)
					IF aiMarkArrangeId[iGrp]=MARK_ARRANGE_HFOR OR aiMarkArrangeId[iGrp]=MARK_ARRANGE_HREV THEN
						(* 如果之前是横排 *)
						IF pstStUnitParam_Save^.dwFlag_Ctl.1 THEN (* 如果打开了门内基线|则我们帮助其默认关闭 *)
							pstStUnitParam_Save^.dwFlag_Ctl.1:= FALSE;
						END_IF
					END_IF
				END_CASE
			END_IF			
		END_FOR
		aiMarkArrangeId[iGrp]:= pstStGrpParam_Save^.iMarkArrangeMode;(*移动到最后更新|2019.11.14.103051_*)
	END_IF
	*)
END_FOR


FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum(*g_pstStShmGlobalParam^.iUMax*) BY 1 DO
	(* 条标时把横向打开了|系统强制关闭|@2019.4.26.133820 *)
	IF g_stStSysParam.astStUnitParam_Save[iN].iMarkTypeId=MARK_TYPE_LINE AND
		g_stStSysParam.astStUnitParam_Save[iN].dwFlag_Ctl.0 THEN
		g_stStSysParam.astStUnitParam_Save[iN].dwFlag_Ctl.0:= FALSE; (* 关横向 *)
	END_IF

	(*横向手动版修正|*)
	IF NOT axSynchronizedFlag[iN] THEN
		axSynchronizedFlag[iN]:= TRUE;
	ELSE
		IF g_abyHorzManu_HMI[iN].0<>abyHorzManu_HMI_Pre[iN].0 THEN (* 横向左手动1 *)
			g_abyHorzManuTrigButton[iN]:= 1;
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, 
				LOG_LEVEL_EVT_USRACTIONS, 'Horz-Manu-Adj-Left-1', INT_TO_STRING(iN)); (* 2020.8.11.141918|watching... *)
		END_IF
		IF g_abyHorzManu_HMI[iN].1<>abyHorzManu_HMI_Pre[iN].1 THEN (* 横向左手动2 *)
			g_abyHorzManuTrigButton[iN]:= 2;
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, 
				LOG_LEVEL_EVT_USRACTIONS, 'Horz-Manu-Adj-Left-2', INT_TO_STRING(iN)); (* 2020.8.11.141918|watching... *)
		END_IF
		IF g_abyHorzManu_HMI[iN].2<>abyHorzManu_HMI_Pre[iN].2 THEN (* 横向右手动1 *)
			g_abyHorzManuTrigButton[iN]:= 3;
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, 
				LOG_LEVEL_EVT_USRACTIONS, 'Horz-Manu-Adj-Right-1', INT_TO_STRING(iN)); (* 2020.8.11.141918|watching... *)
		END_IF
		IF g_abyHorzManu_HMI[iN].3<>abyHorzManu_HMI_Pre[iN].3 THEN (* 横向右手动2 *)
			g_abyHorzManuTrigButton[iN]:= 4;
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, 
				LOG_LEVEL_EVT_USRACTIONS, 'Horz-Manu-Adj-Right-2', INT_TO_STRING(iN)); (* 2020.8.11.141918|watching... *)
		END_IF

(*2022.8.9.092113||更新韩工7.29更新||横向手动按钮0.02档位*)
		IF g_abyHorzManu_HMI[iN].4<>abyHorzManu_HMI_Pre[iN].4 THEN (* 横向左0.02 *)
			g_abyHorzManuTrigButton[iN]:= 5;
			KS_HY_AddMsgToLog(g_pstStHYLogFifo,
				LOG_LEVEL_EVT_USRACTIONS, 'Horz-Manu-Adj-Left-3', INT_TO_STRING(iN)); (* 2020.8.11.141918|watching... *)
		END_IF

		IF g_abyHorzManu_HMI[iN].5<>abyHorzManu_HMI_Pre[iN].5 THEN (* 横向右0.02 *)
			g_abyHorzManuTrigButton[iN]:= 6;
			KS_HY_AddMsgToLog(g_pstStHYLogFifo,
				LOG_LEVEL_EVT_USRACTIONS, 'Horz-Manu-Adj-Right-3', INT_TO_STRING(iN)); (* 2020.8.11.141918|watching... *)
		END_IF

	END_IF
	abyHorzManu_HMI_Pre[iN]:= g_abyHorzManu_HMI[iN];



END_FOR

wAxis_RollerDn:= 0;
wAxis_Alarm_Prn:= 0;
dwAlarmCode:= 0;
wComplexFlag_AxisInching:= 0;
wComplexFlag_Linkage:= 0;
wComplexFlag_Estop:= 0;

FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	IF g_stStSysParam.astStUnitParam_Save[iN].xLinkage THEN
		wComplexFlag_Linkage:= wComplexFlag_Linkage OR SHL(WORD#1, iN-1);
	END_IF

	IF g_stStSysParam.astStUnitParam_UnSave[iN].xAxisInching OR g_axAxisInchDecing[iN] THEN
		wComplexFlag_AxisInching:= wComplexFlag_AxisInching OR SHL(WORD#1, iN-1);
	END_IF
	IF g_astStIOMap_Axis_FE[iN].o_xRel_Press THEN
		wAxis_RollerDn:= wAxis_RollerDn OR SHL(WORD#1, iN-1);
	END_IF	
END_FOR

