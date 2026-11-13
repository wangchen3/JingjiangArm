(*@CES
Name=Action_Normal_Act_Adj
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=e66732c1-f86e-46d6-bb4d-275bf04b7640
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*调整量计算*)

FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
	iStationId:= g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN];(*g_stStRingInf.stationIdList[iN];*)
	iUnitId:= KS_GetAxisIdByStationId(iStationId,g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController);
	iGrpId:= KS_GetGrpIdByAxisId(iUnitId, ADR(g_stStSysParam), ADR(iAxisTypeId));(*2018.7.29.213902\Refill parameter|*)

	IF (iGrpId=1 OR iGrpId=2)  THEN(*已经分配了系|*)
		IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM THEN
			pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iUnitId]);
			pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iUnitId]);
		END_IF
		
		pstStGrpParam_Save:= ADR(g_stStSysParam.astStGrpParam_Save[iGrpId]);(*2018.6.10.140215\访问系参数的地址|*)
		pstStGrpParam_UnSave:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrpId]);(*2018.6.10.140215\访问系参数的地址|*)
		(*2024.8.1.120220*)
		IF iUnitId>=2 AND iUnitId<=16 THEN
			IF pstStGrpParam_UnSave^.xFlag_Cut_end_Uw THEN
				axFlagCutDne_UseHorCompensate_Uw[iUnitId]:=pstStGrpParam_UnSave^.xFlag_Cut_end_Uw;
			END_IF
			IF pstStGrpParam_UnSave^.xFlag_Cut_end_Rw THEN
				axFlagCutDne_UseHorCompensate_Rw[iUnitId]:=pstStGrpParam_UnSave^.xFlag_Cut_end_Rw;
			END_IF
		END_IF
//		stStPara_PduBroadcastUp:=astStPara_PduBroadcastUp[iUnitId];

		(*调整量值初始化@2023.11.18.131736*)
		aiFinalAdjust_V[iUnitId]:=0;
		aiFinalAdjust_H[iUnitId]:=0;
		aiArcActErr_V[iUnitId]:=0;(*2024.7.26.160533+*)
		IF axCanCalcArcAdjustValue[iUnitId](*dwTempVal<>0 *)THEN (*确认发生改变*)(*条件修改为了标志*)
			IF iUnitId>=2 AND iUnitId<=g_stStSysParam.stStSysParam_Save.iUnitMaxNum THEN (*认为色组才会上报误差*)
				pstStUnitParam_Save:= ADR(g_stStSysParam.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:= ADR(g_stStSysParam.astStUnitParam_UnSave[iUnitId]);

					(*2024.05.24.172339*)
					(*对套色误差进行低通*)
					IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16号轴*)
						IF pstStUnitParam_Save^.rK_ArcErr_Lp=0 THEN
							pstStUnitParam_Save^.rK_ArcErr_Lp:=30;
						END_IF

						IF ABS(astStErrParam_Use[iUnitId].iErr_V)<10000 THEN(*非法值@不用滤波*)
							(*将输入的料长修改为了色组间料长@当前色和前一色之间|2024.8.20.083559*)
							TAOSE_LP(
								astStErrParam_Use[iUnitId].iErr_V(*i_rE*),
								ADR(pstStUnitParam_UnSave^.rVerror_Lp)(*i_prE_DEAL*),
								pstStUnitParam_Save^.rK_ArcErr_Lp(*i_rK*),
								pstStUnitParam_Save^.rGirth_Sam(*i_rC*),
								pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit/1000(*pstStGrpParam^.rFilmLenth_InUnit*)(*i_rL*),
								pstStGrpParam_UnSave^.rVel_Film(*i_rV*),
								ADR(arEk_ArcErr_Lp[iUnitId,1])(*i_prEk*),
								ADR(arE_DEAL_ArcErr_Lp[iUnitId,1])(*i_prE_DEALk*));
						END_IF
					END_IF


					(*2023.12.05.133156 获取误差值|用于外部PRG_SYNC_UI_UPDATE_中处理跟踪第一色标志处理函数*)
					IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16号轴*)
						IF pstStGrpParam_UnSave^.xFlag_Print THEN(*印刷*)
							(*等料长的时候@套色误差无效*)
							pstStUnitParam_UnSave^.xArcErrValid:= NOT pstStUnitParam_Save^.xWaitFilmLenth_Follow1U;
							(*2024.9.7.134156||niujing||新增一个标志给牛靖用-停机恢复相位*)
							pstStUnitParam_UnSave^.xArcErrValid_Use_Niu:= NOT pstStUnitParam_Save^.xWaitFilmLenth_Follow1U;
						ELSE
							pstStUnitParam_UnSave^.xArcErrValid:= FALSE;
							pstStUnitParam_UnSave^.xArcErrValid_Use_Niu:= FALSE;
						END_IF
					(*	pstStUnitParam_UnSave^.iArcErr_V :=astStErrParam_Use[iUnitId].iErr_V;(*记录下纵向误差值*)*)

						(*2025.4.20.130610写入到轴参数中*)
						pstStUnitParam_UnSave^.iArcErr_V:= astStErrParam_Use[iUnitId].iErr_V;
						(*pstStUnitParam_UnSave^.xArcErrIsValid_V:=g_axArcErrValid[iUnitId];*)
						g_aiArcErr_V[iUnitId]:= astStErrParam_Use[iUnitId].iErr_V;
						g_axArcErrValid[iUnitId]:= pstStUnitParam_UnSave^.xArcErrValid;
					END_IF


					(*2022.7.19.083027计算调整量增加如果是横向跟1色-赋值为横向跟1色误差*)
					(*保留原始计算跟前一色误差*)
					aiHerror_FollowBefore[iUnitId]:= astStErrParam_Use[iUnitId].iErr_H;

					(*2018.8.14.105229\给pstStAxisParam^.byArcSts赋值|*)
					(*2024.03.12.102822 增加了横向自动的条件*)
					pstStUnitParam_UnSave^.byArcSts.0:= astStErrParam_Use[iUnitId].byErrSts.0 OR(*报警*)
										(astStErrParam_Use[iUnitId].byErrSts.4 AND pstStUnitParam_Save^.dwFlag_Sts.1);
					pstStUnitParam_UnSave^.byArcSts.1:= astStErrParam_Use[iUnitId].byErrSts.1 OR(*丢失*)
										(astStErrParam_Use[iUnitId].byErrSts.5 AND pstStUnitParam_Save^.dwFlag_Sts.1);

					(*han.dp\2017.8.3.112709\byStsV和byStsH的位描述|
					/.bit0报警\bit1丢失\bit2飞点\bit3让料头|*)
					wParam:= 0;
					wParam.0:= (astStErrParam_Use[iUnitId].byErrSts.1 );(*丢失|*)
					wParam.1:= (astStErrParam_Use[iUnitId].byErrSts.2 );(*飞点|*)
					(*arm上根本就没有处理这一bit*)
(*					wParam.2:= (stStPara_PduBroadcastUp.byStsV.3 );(*让料头|*)*)
					wParam.2:= (pstStUnitParam_UnSave^.xSkipHeader);(*让料头@使用轴标志*)
					(*是否可以把纵横向判断分开bit8后面为横向*)

					(*2025.4.20.124736 轴参数中变量赋值*)
					pstStUnitParam_UnSave^.xArcErrIsAlarm_V:= astStErrParam_Use[iUnitId].byErrSts.0;(*报警*)
					pstStUnitParam_UnSave^.xArcErrIsLost_V:= astStErrParam_Use[iUnitId].byErrSts.1;(*丢失*)
					pstStUnitParam_UnSave^.xArcErrIsFake_V:= astStErrParam_Use[iUnitId].byErrSts.2;(*飞点*)


					wParam.8:= (astStErrParam_Use[iUnitId].byErrSts.5);(*丢失|*)
					wParam.9:= (astStErrParam_Use[iUnitId].byErrSts.6);(*飞点|*)
					wParam.10:= (astStErrParam_Use[iUnitId].byErrSts.7);(*让料头|*)
					(*arm上根本就没有处理这一bit@2025.2.18.151937*)
					wParam.10:= (pstStUnitParam_UnSave^.xSkipHeader);(*让料头@使用轴标志*)

					(*2025.4.20.124736 轴参数中变量赋值*)
					pstStUnitParam_UnSave^.xArcErrIsAlarm_H:=astStErrParam_Use[iUnitId].byErrSts.4;(*报警*)
					pstStUnitParam_UnSave^.xArcErrIsLost_H:=astStErrParam_Use[iUnitId].byErrSts.5;(*丢失*)
					pstStUnitParam_UnSave^.xArcErrIsFake_H:=astStErrParam_Use[iUnitId].byErrSts.6;(*飞点*)

					xFlagAdjEnaCalc:= pstStGrpParam_UnSave^.xFlag_Print;(*印刷标志|*)
					IF (NOT xFlagAdjEnaCalc) AND pstStGrpParam_UnSave^.xEnaTestARC_Ink THEN(*非印刷\但允许使用套色调整|*)
						xFlagAdjEnaCalc:= pstStGrpParam_UnSave^.xFlag_Ink;(*取空转标志|*)
					END_IF

					xFlagVelCtl:= (pstStGrpParam_UnSave^.xFlag_Accing AND pstStGrpParam_UnSave^.xFlag_AutoAcc);
					xFlagVelCtl:= xFlagVelCtl OR (pstStGrpParam_UnSave^.xFlag_Decing AND pstStGrpParam_UnSave^.xFlag_AutoDec);
					xFlagVelCtl:= xFlagVelCtl AND pstStGrpParam_UnSave^.xFlag_Print;

					IF pstStGrpParam_UnSave^.rVel_Cur<>0 THEN
						lrMaxAdjustVal:= pstStUnitParam_Save^.rGirth_Sam / pstStGrpParam_UnSave^.rVel_Cur;
						lrMaxAdjustVal:= lrMaxAdjustVal * pstStGrpParam_Save^.rVel_AutoAdj * 1000;
					ELSE
						lrMaxAdjustVal:= 0;
					END_IF

					(*计算横向一个周期的调整量@2023.6.19.163123*)
					IF pstStGrpParam_UnSave^.rVel_Cur<>0 THEN
						lrMaxAdjustVal_H:= pstStUnitParam_Save^.rGirth_Sam / pstStGrpParam_UnSave^.rVel_Cur*60;(*s/1000*)
						lrMaxAdjustVal_H:= lrMaxAdjustVal_H * pstStGrpParam_Save^.rVel_HorzdAdj;(*um*)
					ELSE
						lrMaxAdjustVal_H:=0;
					END_IF


					(*2018.8.17.153536\新增的误差传递列表|*)
					(*2018.8.18.125708\修正料长使用的变量|*)
					(*iTmp_DataIndex:= LREAL_TO_INT(pstStAxisParam^.lrFilmLengthFromPrevUnit/pstStAxisParam^.lrGirth);(*取数据位置|*)*)
					(*2024.8.15.163600 误差传递的机组料长值修改*)
					iTmp_DataIndex:= LREAL_TO_INT(pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit/pstStUnitParam_Save^.rGirth_Sam);(*取数据位置|*)

					(*2018.8.18.105217\找前一个有效的轴\同系|*)
					iTmp_RelayErrData_V:= 0;
					(*2024.7.30.124442 修改为寻找前一个色序id*)
					iTmp_PrevAxisId:=iUnitId;
					IF iUnitId>2 AND iUnitId<= g_stStSysParam.stStSysParam_Save.iUnitMaxNum THEN(*当前色组从3开始|*)
						FOR iM:=3 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO(*从第三个色序开始找@2024.8.31.154626*)
							IF pstStGrpParam_UnSave^.abyGrpArcAxisList[iM]=iUnitId THEN(*该轴属于套色轴*)
								iTmp_PrevAxisId:= pstStGrpParam_UnSave^.abyGrpArcAxisList[iM-1];(*前一个套色轴id*)
								EXIT;
							END_IF
						END_FOR
(*						iTmp_PrevAxisId:= iUnitId-1;*)

						IF g_stStSysParam.astStUnitParam_Save[iTmp_PrevAxisId].byGrpId=pstStUnitParam_Save^.byGrpId AND(*前1色必须和当前色组同系|*)
							g_stStSysParam.astStUnitParam_Save[iTmp_PrevAxisId].xLinkage AND(*前色处于联动|*)
							g_stStSysParam.astStUnitParam_Save[iTmp_PrevAxisId].byCouplingMask.2 AND(*前色开了误差传递|*)
							NOT pstStUnitParam_Save^.xWaitFilmLenth_Follow1U AND(*1色来的时候在取传递的值@2024.8.7.171422*)
							iTmp_PrevAxisId<>iUnitId AND(*说明找到了前一个套色轴@料长还没处理-隔色可能传递的不对|2024.8.15.163709 处理了*)
							iTmp_DataIndex<=gc_iMaxErrDataItemInList THEN(*误差列表有效范围以内@2024.8.15.164042*)
							(*2023.09.04.124704|-1 修改为了+1*)
							iTmp_RelayErrData_V:= KS_GetErrListDataByAxisIdAndDataIndex(g_pastAllAxisErrorTransfer, iTmp_PrevAxisId, (iTmp_DataIndex+1));

						END_IF
					END_IF
					(*2022.5.24.1525372022.5.24.152541刘工*)
					iSaveTmp_RelayErrData_V:=iTmp_RelayErrData_V;


					IF wParam.0 OR wParam.1 THEN(*2018.8.22.173151\如果飞点\就把上一幅误差用过来好了|*)
						(*2022.8.30.150745 将数组索引2-->1
						索引1为前一个值*)
						iErForCalc_v:= g_pastAllAxisErrorTransfer^[iUnitId].aiErrDataList[1];
					ELSE
						iErForCalc_v:= astStErrParam_Use[iUnitId].iErr_V;
						IF g_stStSysParam.stStSysParam_Save.xUseArcErr_Lp THEN(*2024.05.25.141626+*)
							iErForCalc_v:=REAL_TO_INT(pstStUnitParam_UnSave^.rVerror_Lp);
						END_IF
						(*2024.8.24.152526 移动*)
						iErForCalc_v:=iErForCalc_v+iTmp_RelayErrData_V;(*在当前色处于飞点或者丢失时候也可以进行误差传递|2022.4.11.132704*)
					END_IF

					(*2024.7.27.075730 获取当前误差*)
					IF wParam.0 THEN(*如果丢失了使用上一幅误差*)
						aiArcActErr_V[iUnitId]:=iErForCalc_v;
					ELSE
						aiArcActErr_V[iUnitId]:= astStErrParam_Use[iUnitId].iErr_V;(*2024.7.26.160512+*)
					END_IF

					(*2023.09.04.102406  对于5号命令上传的误差进行滤波用于误差显示*)
					(*2023.09.23.085605 使用通讯上来用于计算的误差@上面使用的16d通讯因为又6号命令会不连续*)
					iError_Curve_Temp_V:= astStErrParam_Use[iUnitId].iErr_V+iTmp_RelayErrData_V;(*加上误差传递的值@2024.05.19.222458*)
					IF g_stStSysParam.stStSysParam_Save.xUseArcErr_Lp THEN(*2024.05.25.141853*)
						iError_Curve_Temp_V:=REAL_TO_INT(pstStUnitParam_UnSave^.rVerror_Lp+iTmp_RelayErrData_V);(*加上误差传递的值@2024.05.19.222458*)
					END_IF
// 					IF iUnitId<=16 THEN
// 						IF ABS(iError_Curve_Temp_V)<10000 THEN(*非法值@不用滤波*)
// 							(*2024.7.18.094243处理*)
// 							pfbFilter:=0;
// 							IF g_pstStGlobalVarByAllocMem<>0 THEN
// 								pfbFilter:=ADR(g_pstStGlobalVarByAllocMem^.afbArcErrFilter[iUnitId]);
// 							END_IF
// 							pfbFilter^(
// 								i_xEn:=TRUE,
// 								i_iFiltTimes:=BYTE_TO_INT(pstStUnitParam_Save^.byAve_v_extra),
// 								i_dwDataAdr:=ADR(iError_Curve_Temp_V),
// 								i_byDataType:=TYPE_INT,
// 								i_xFrom0Average:=FALSE,(*2024.05.21.163449*)
// 								o_lrFiltData=>rError_Curve_Temp_V_Filter);
// 						ELSE
// 							rError_Curve_Temp_V_Filter:= astStErrParam_Use[iUnitId].iErr_V(*iError_Curve_Temp_V*);
// 						END_IF
// 					END_IF

					(*2018.10.25.152001|niu.j|压误差压入计算所用误差*)
					(*han.dp@2018.10.7.142627\轴在让料头的时候传递误差都是0|*)
					(*把当前幅的误差压入到误差数据队列中|*)
					IF astStErrParam_Use[iUnitId].byErrSts.3 (*OR stStPara_PduBroadcastUp.byStsH.3*) THEN(*只检查纵向丢失@2023.07.28.083941*)
						KS_PushErrDataToListHead(g_pastAllAxisErrorTransfer, iUnitId, 0);
					ELSE
						KS_PushErrDataToListHead(g_pastAllAxisErrorTransfer, iUnitId, iErForCalc_v);(*iErForCalc_v包含了前色传递的值*)
					END_IF

					(*2023.7.26.171713 在函数中已经处理丢失飞点让料头状态的输出  这里就没必要了|
					屏蔽了
					写到这里会引起横向处于这些状态时候纵向不调整|同样纵向也会影响横向
					因为这个iFinalError_V下面并不使用，wParam<>0这个条件虽然不对但是改的必要不大
					只屏蔽调整量清零部分
					iFinalAdjust_V:= 0;*)
					IF wParam.2 THEN(*让料头|*)
						iFinalError_V:= gc_iValueReferToSkipTheHeader;
					ELSIF wParam.1 THEN(*飞点|*)
						iFinalError_V:= gc_iValueReferToFakePoint;
					ELSIF wParam.0 THEN(*丢失|*)
						iFinalError_V:= gc_iValueReferToLost;
					ELSE
						iFinalError_V:= astStErrParam_Use[iUnitId].iErr_V;
					END_IF
					(*2023.7.26.171713 在函数中已经处理丢失飞点让料头状态的输出  这里就没必要了|
					屏蔽了
					写到这里会引起横向处于这些状态时候纵向不调整|同样纵向也会影响横向
					因为这个iFinalError_V下面并不使用，wParam<>0这个条件虽然不对但是改的必要不大
					只屏蔽调整量清零部分
					iFinalAdjust_H:= 0;*)
					IF wParam.10 THEN(*让料头|*)
						iFinalError_H:= gc_iValueReferToSkipTheHeader;
					ELSIF wParam.9 THEN(*飞点|*)
						iFinalError_H:= gc_iValueReferToFakePoint;
					ELSIF wParam.8 THEN(*丢失|*)
						iFinalError_H:= gc_iValueReferToLost;
					ELSE
						iFinalError_H:= astStErrParam_Use[iUnitId].iErr_H;
					END_IF


				(*升降速套色补偿启动开关@2023.09.20.105146*)
				(*使用加速减速pid|=1 加速度系数补偿|=2 delta速度系数补偿*)
(*
				byCanUseAccDecPid:=0;
				IF pstStGrpParam^.xFilmAccDecDone AND pstStGrpParam^.lrVel_Film>10 THEN
					byCanUseAccDecPid:=pstStGrpParam^.byArcAccDecPidEn;
				END_IF
*)
				(*参数合法处理@2024.03.03.180048*)
				
				IF g_stStSysParam.stStSysParam_Save.byParamIndex_Huang=0 THEN
					g_stStSysParam.stStSysParam_Save.byParamIndex_Huang:=9;(*默认是第9中*)
				END_IF


				IF iUnitId>=2 AND iUnitId<=16 THEN(*限制到2-16轴*)

					(*2024.9.11.082925  增加了smith环节*)
					(*正的调整量输入,对应正的误差输出*)
					(*输入时调整量,输出是误差值*)
					lrTotalAdjustValue:=pstStUnitParam_UnSave^.alrExecutedAdjVal_Auto_vh[1]+
								pstStUnitParam_UnSave^.alrExecutedAdjVal_Coupling_vh[1]*0+
								pstStUnitParam_UnSave^.alrExecutedAdjVal_Rapid_vh[1]*0+
								pstStUnitParam_UnSave^.alrExecutedAdjVal_ManuCoarse_vh[1]*0+
								pstStUnitParam_UnSave^.alrExecutedAdjVal_ManuFine_vh[1]*0+
								pstStUnitParam_UnSave^.alrExecutedAdjVal_Coupling_vh[1]*0;
					g_stStSysParam.stStSysParam_Save.byUseArcAccOrDecCompensate:=0;(*2025.7.1.193619 不再使用强制写0*)
					g_apbyKp_Arc[iUnitId]:= ADR(pstStUnitParam_Save^.iKp_V);
					g_apbyKi_Arc[iUnitId]:= ADR(pstStUnitParam_Save^.iKi_V);
					g_apbyKd_Arc[iUnitId]:= ADR(pstStUnitParam_Save^.iKd_V);
								
					afbKS_FB_ARC_PIDAdjust[iUnitId](
						i_byStateOfMotion:= BOOL_TO_BYTE(xFlagAdjEnaCalc), 
						i_byModeOfAdjust:= int_to_byte(pstStGrpParam_Save^.iWorkMode_Pid),
						i_wErProf:= wParam, 
						i_iError_v:= iErForCalc_v, 
						i_iError_h:= astStErrParam_Use[iUnitId].iErr_H, 
						i_xAccSpeedFlag:= xFlagVelCtl, 
						i_lrCurrVelocity:= pstStGrpParam_UnSave^.rVel_Cur,
						i_rMaxAdjustVal:= LREAL_TO_REAL(lrMaxAdjustVal), 
						i_xArcTest:= g_stStSysParam.stStSysParam_Save.xSwitch_ArcTest_V, 
						i_xArcTest_H:= TRUE,//g_stStSysParam.stStSysParam_Save.xSwitch_ArcTest_H, 
						i_rMaxAdjustVal_H:= LREAL_TO_REAL(lrMaxAdjustVal_H), 
						i_rAcceleration_Max:= pstStGrpParam_UnSave^.rAcceleration_Max, 
						i_rAcceleration_Cur:= pstStGrpParam_UnSave^.rAcceleration_Cur, 
						i_byParamIndex:= g_stStSysParam.stStSysParam_Save.byParamIndex_Huang, 
						i_uiControllerVel_Huang:= g_stStSysParam.stStSysParam_Save.uiControllerVel_Huang, 
						i_byFilmType:= pstStGrpParam_Save^.byFilmType, 
						i_pbyKp:= g_apbyKp_Arc[iUnitId], 
						i_pbyKi:= g_apbyKi_Arc[iUnitId], 
						i_pbyKd:= g_apbyKd_Arc[iUnitId], 
						i_iError_Act_v:= astStErrParam_Use[iUnitId].iErr_V, 
						i_iCustomId:= g_stStSysParam.stStSysParam_Save.iCustomerId, 
						i_byArcId_Cur:= pstStUnitParam_UnSave^.byColorIdCurrent, 
						i_byArcNum:= pstStGrpParam_UnSave^.byGrpArcAxisNum, 
						i_xFlag_RollerPressDne:= pstStUnitParam_UnSave^.xFlag_PressDn OR pstStGrpParam_UnSave^.xEnaTestARC_Ink, 
						i_xInitArcErr_AjdImmediately:= g_stStSysParam.stStSysParam_Save.xInitArcErr_AjdImmediately, 
						i_byUseArcAccOrDecCompensate:= g_stStSysParam.stStSysParam_Save.byUseArcAccOrDecCompensate, 
						i_rTarVel_ThisTime:= pstStGrpParam_UnSave^.rFinalVelocity, 
						i_xFlag_Acc:= pstStGrpParam_UnSave^.xFlag_Accing AND pstStGrpParam_UnSave^.xFlag_AutoAcc, 
						i_xFlag_Dec:= pstStGrpParam_UnSave^.xFlag_Decing AND pstStGrpParam_UnSave^.xFlag_AutoDec, 
						i_rFilmLenth_InUnit:= LREAL_TO_REAL(pstStUnitParam_Save^.lrFilmLengthFromPrevUnit), 
						i_rKp_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rKp_GC, 
						i_rKi_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rKi_GC, 
						i_rKd_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rKd_GC, 
						i_rN_Gc:= pstStUnitParam_Save^.stStArc_Mol_Param.rN_GC, 
						i_byArcErrLimitToCtl_P:= g_stStSysParam.stStSysParam_Save.byArcErrLimitToCtl_P, 
						i_byArcErrLimitToCtl_I:= g_stStSysParam.stStSysParam_Save.byArcErrLimitToCtl_I, 
						i_xCompensateEn_Hor:= pstStUnitParam_Save^.stStArc_Mol_Param.xCompensateEn_H, 
						i_xCut_Uw:= axFlagCutDne_UseHorCompensate_Uw[iUnitId], 
						i_xCut_Rw:= axFlagCutDne_UseHorCompensate_Rw[iUnitId], 
						i_byCompensateValue_Hor:= pstStUnitParam_Save^.stStArc_Mol_Param.byCompensateValue_Hor, 
						i_byMaxAddValue_Total_Hor:= pstStUnitParam_Save^.stStArc_Mol_Param.byMaxAddValue_Total_Hor, 
						i_byKadj_SetType:= g_stStSysParam.stStSysParam_Save.byKadj_SetType, 
						i_rTotalAdjustValue_Act:= LREAL_TO_REAL(lrTotalAdjustValue), 
						i_rFilmLenth_Eyes:= g_stStSysParam.stStSysParam_Save.rFilmLenth_Eyes, 
						i_uiArcSysDelayTime_ms:= g_stStSysParam.stStSysParam_Save.uiArcSysDelayTime_ms, 
						i_byArcPidGetType:= g_stStSysParam.stStSysParam_Save.byArcPidGetType, 
						i_xUseGc_PID_2025:= g_stStSysParam.stStSysParam_Save.xUseGc_PID_2025, 
						i_xFlag_AdjValid_V:= pstStUnitParam_Save^.dwFlag_Sts.0,
						i_xFlag_AdjValid_H:= pstStUnitParam_Save^.dwFlag_Ctl.0 AND pstStUnitParam_Save^.dwFlag_Sts.1,
						i_rDeadzoneMin_H:= pstStUnitParam_Save^.rDeadzoneMin_H, 
						i_rDeadzoneMax_H:= pstStUnitParam_Save^.rDeadzoneMAX_H, 
						i_xWaitFilmLenth_FollowPreU:= pstStUnitParam_Save^.xWaitFilmLenth_FollowPreU, (*后续处理了*)
						i_rGirth_Arc:= pstStUnitParam_Save^.rGirth_Sam, 
						i_iKp_V:= pstStUnitParam_Save^.iKp_V,
						i_iKi_V:= pstStUnitParam_Save^.iKi_V,
						i_iKd_V:= pstStUnitParam_Save^.iKd_V,
						i_iKp_H:= pstStUnitParam_Save^.iKp_H,
						i_iKi_H:= pstStUnitParam_Save^.iKi_H,
						i_iKd_H:= pstStUnitParam_Save^.iKd_H,
						i_iMarkArrangeModal:= pstStUnitParam_Save^.iMarkArrangeMode, 
						i_xAdjREV_V:= pstStUnitParam_Save^.dwFlag_Ctl.4,
						i_xAdjREV_H:= pstStUnitParam_Save^.dwFlag_Ctl.5,
						i_xFollow_1U:= pstStUnitParam_Save^.dwFlag_Sts.10,
						i_xWaitFilmLenth_Follow1U:= pstStUnitParam_Save^.xWaitFilmLenth_Follow1U,
						i_xWaitFilmLength:= pstStUnitParam_Save^.xWaitFilmLength,
						i_stStArc_Mol_Param:= pstStUnitParam_Save^.stStArc_Mol_Param, 
						i_xFilmArrived_Cut:=pstStUnitParam_UnSave^.xSkipHeaderSts,
						o_iVResult=> iFinalAdjust_V,
						o_iVKp=> iKp_InUse,
						o_iVKi=> iKi_InUse,
						o_iVKd=> iKd_InUse,
						o_iHResult=> iFinalAdjust_H,
						//2026.04.10.102156 修改输出值@到金刚
						//o_rKp_MolCal=>pstStUnitParam_Save^.stStArc_Mol_Param.rKp_MolCal,
						//o_rKi_MolCal=>pstStUnitParam_Save^.stStArc_Mol_Param.rKi_MolCal
						o_rKp_MolCal=>pstStUnitParam_Save^.rKp_MolCal,
						o_rKi_MolCal=>pstStUnitParam_Save^.rKi_MolCal);
					(*2023.11.18.094608 将误差值写到误差数组中*)
					(*2024.9.3.151223  根据解耦标志决定要不要累加进入自动调整量中*)
					(*取消@2025.1.2.154307*)
					(*iFinalAdjust_V:=iFinalAdjust_V+REAL_TO_INT(-rErr_ArcAccOrDecCompensate)*BOOL_TO_BYTE(xCompensate_DeCouple);(*调整量需要取反@2024.05.23.142807*)*)
			//		iFinalAdjust_V:= 1000;//测试代码2025.12.03.164002删除
					aiFinalAdjust_V[iUnitId]:=iFinalAdjust_V;
					aiFinalAdjust_H[iUnitId]:=iFinalAdjust_H;
				ELSE
					iFinalAdjust_V:=0;
					iKp_InUse:=0;
					iKi_InUse:=0;
					iKd_InUse:=0;
					iFinalAdjust_H:=0;
				END_IF

			
				
				fbKS_FB_StRecord_A(
					i_xEn:= TRUE, 
					i_iGrpId:= iGrpId, 
					i_iUnitId:= iUnitId, 
					i_pstStSysParam:= ADR(g_stStSysParam), 
					i_xRel_Press:= g_astStIOMap_Axis_FE[iUnitId].o_xRel_Press, 
					i_iTmp_DataIndex:= iTmp_DataIndex, 
					i_iSaveTmp_RelayErrData_V:= iSaveTmp_RelayErrData_V, 
					i_iFinalAdjust_V:= iFinalAdjust_V, 
					i_iFinalAdjust_H:= iFinalAdjust_H, 
					i_iArcErr_V:= iErForCalc_v, 
					i_iArcErr_H:= astStErrParam_Use[iUnitId].iErr_H, 
					//2026.4.10.100244+ 变量配置错误
					//i_xSkipHeaderSts:= pstStUnitParam_UnSave^.xSkipHeader,// xSkipHeaderSts, 
					i_xSkipHeaderSts:= pstStUnitParam_UnSave^.xSkipHeaderSts,// xSkipHeaderSts,
					i_xCompensateEn_H:= pstStUnitParam_Save^.stStArc_Mol_Param.xCompensateEn_H,
				
					i_iVKp_Use:=iKp_InUse,
					i_iVKi_Use:= iKi_InUse,
					i_iVKd_Use:= iKd_InUse,
					i_arFinalAdjust_V_Act:=arFinalAdjust_V_Act,
					i_stStErrParam_Use:=  astStErrParam_Use[iUnitId],
					
					);(*套色数据保存*)
				





					(*2017.8.24.113932\接收到误差就把已经执行的调整量清零|*)
					pstStUnitParam_UnSave^.alrExecutedAdjVal_Auto_vh[1]:= 0;(*累计调整-纵向自动|*)
					pstStUnitParam_UnSave^.alrExecutedAdjVal_Auto_vh[2]:= 0;(*累计调整-横向自动|*)
					pstStUnitParam_UnSave^.alrExecutedAdjVal_Rapid_vh[1]:= 0;(*累计调整-快速|*)
					pstStUnitParam_UnSave^.alrExecutedAdjVal_Manucoarse_vh[1]:= 0;(*累计调整-手动粗调|*)
					pstStUnitParam_UnSave^.alrExecutedAdjVal_Manufine_vh[1]:= 0;(*累计调整-手动细调|*)
					pstStUnitParam_UnSave^.alrExecutedAdjVal_Coupling_vh[1]:= 0;(*累计调整-耦合|*)
//					pstStUnitParam_UnSave^.alrExecutedAdjVal_Compensate_vh[1]:= 0;(*累计调整-补偿|*)

					(*2024.8.1.120345*)
				IF iUnitId>=2 AND iUnitId<=16 THEN(*为了数据存储*)
					axFlagCutDne_UseHorCompensate_Uw[iUnitId]:=FALSE;
					axFlagCutDne_UseHorCompensate_Rw[iUnitId]:=FALSE;
				END_IF
			ELSE;
			END_IF
		END_IF
	END_IF
END_FOR