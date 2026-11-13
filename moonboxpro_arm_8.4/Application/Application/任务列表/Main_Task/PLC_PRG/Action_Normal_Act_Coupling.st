(*@CES
Name=Action_Normal_Act_Coupling
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=cef1b064-16b1-4c2f-a737-ec16616f6511
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*传递处理*)

(*2个系分别计算*)
FOR iGrpId:=1 TO 2 BY 1 DO
	IF iGrpId=2 THEN EXIT; END_IF	
	pstStGrpParam_Save:= ADR(g_stStSysParam.astStGrpParam_Save[iGrpId]);(*2018.6.10.140215\访问系参数的地址|*)
	pstStGrpParam_UnSave:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrpId]);(*2018.6.10.140215\访问系参数的地址|*)

	(*使用误差传递标志@只要有一个就使能*)
	axUseErrTransfer[iGrpId]:=FALSE;
	FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
		iStationId:= g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN];(*g_stStRingInf.stationIdList[iN];*)
		iUnitId:= KS_GetAxisIdByStationId(iStationId,g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController);
		//iUnitId:= KS_GetAxisIdByStationId();
		IF iGrpId = KS_GetGrpIdByAxisId(iUnitId, ADR(g_stStSysParam), ADR(iAxisTypeId)) THEN(*这个轴处于这个系*)
			IF g_stStSysParam.astStUnitParam_Save[iUnitId].byCouplingMask.2 THEN(*开了一个误差传递就置位|*)
				IF iUnitId>2 AND iUnitId<16 THEN
					IF g_stStSysParam.astStUnitParam_Save[iUnitId].xLinkage THEN
						axUseErrTransfer[iGrpId]:=TRUE;(*有一色使用误差传递则置位标志@2024.05.20.101332*)
						EXIT;
					END_IF
				END_IF
			END_IF
		END_IF
	END_FOR


	IF pstStGrpParam_Save^.byDeCoupleArcNum=0 THEN
		pstStGrpParam_Save^.byDeCoupleArcNum:=5;
	END_IF
	IF pstStGrpParam_Save^.byDeCoupleDelayNum=0 THEN
		pstStGrpParam_Save^.byDeCoupleDelayNum:=18;
	END_IF
	IF pstStGrpParam_Save^.rFilmLenth_InUnit=0 THEN
		pstStGrpParam_Save^.rFilmLenth_InUnit:=7;
	END_IF

	(*变量清除*)
	SysMemSet(ADR(arFinalAdjust_V_ArcList),0,SIZEOF(arFinalAdjust_V_ArcList));
(*使用之前都会更新的@2024.7.31.070605*)
(*	SysMemSet(ADR(arFilmLenth_ArcList),0,SIZEOF(arFilmLenth_ArcList));(*2024.7.31.064717+*)*)
	SysMemSet(ADR(arFinalAdjust_V_Act_ArcList),0,SIZEOF(arFinalAdjust_V_Act_ArcList));
	IF pstStGrpParam_UnSave^.xFlag_Print OR pstStGrpParam_UnSave^.xEnaTestARC_Ink THEN
		(*--------------------------------------------------------------------------------*)
		(* 2023.12.25.135909/han.dp/+ *)
		xByPassDeCouple:=FALSE;
		IF iGrpId=g_stStSysParam.stStSysParam_UnSave.byCurGrpId_HMI AND 
			g_stStSysParam.stStSysParam_UnSave.byArcDeCoupleStepTest<>0 AND(* g_xNeedDelet这个变量临时用来做huang.yq的阶跃测试 *)
			axCanCalcArcAdjustValue_Grp[iGrpId] THEN(*状态满足的时候再输出阶跃@2024.8.25.142530*)
			IF g_stStSysParam.stStSysParam_UnSave.byArcDeCoupleStepTest=2 THEN(*不经过解耦控制器直接输出调整量*)
				xByPassDeCouple:=TRUE;
			END_IF
			g_stStSysParam.stStSysParam_UnSave.byArcDeCoupleStepTest:= 0;(* 只在当前系内操作 *)

			SysMemSet(ADR(astStArcCoupleRegister[iGrpId]),0,SIZEOF(astStArcCoupleRegister[iGrpId]));

			(*2024.7.31.065130+清理轴寄存器*)
			FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpAxisNum_Pu BY 1 DO
				iUnitId:=pstStGrpParam_UnSave^.abyGrpAxisList[iN];
				IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
					IF iUnitId<=DECOUPLD_DDPD_MAX THEN
						IF g_pstStGlobalVarByAllocMem<>0 THEN
							SysMemSet(ADR(g_pstStGlobalVarByAllocMem^.astStDecoupleDDPD[iUnitId]),0,
									SIZEOF(g_pstStGlobalVarByAllocMem^.astStDecoupleDDPD[iUnitId]));
						END_IF
					END_IF
					arFinalAdjust_V_Act[iUnitId]:=0;(*只清理自己系的轴*)
				END_IF
			END_FOR
(*
			FOR iN:=2 TO pstStGrpParam^.byGrpArcAxisNum BY 1 DO
				iUnitId:=pstStGrpParam^.abyGrpArcAxisList[iN];
				IF iUnitId>=2 AND iUnitId<=16 THEN
					arFinalAdjust_V_Act[iUnitId]:=0;(*只清理自己系的轴*)
				END_IF
			END_FOR
*)

			axCanCalcArcAdjustValue_Grp[iGrpId]:= TRUE;(* 之后的使能条件可以进来 *)
			byCurGrpId:= g_stStSysParam.stStSysParam_UnSave.byCurGrpId_HMI;
			
			iUnitId:= g_stStSysParam.astStGrpParam_UnSave[byCurGrpId].iAxisId_StepTest_V;
			IF iUnitId>=2 AND iUnitId<=16 THEN
				aiFinalAdjust_V[iUnitId]:= aiFinalAdjust_V[iUnitId]+
						g_stStSysParam.astStGrpParam_UnSave[byCurGrpId].iMicron_StepTest1_V;

				(*调整量写入到队列/2023.12.25.170236*)
				FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO
					iUnitId:=pstStGrpParam_UnSave^.abyGrpArcAxisList[iN];
					(*将调整量压入待调整队列|*)
					IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
						axCanCalcArcAdjustValue[iUnitId]:= TRUE;
					END_IF
				END_FOR
			END_IF
		END_IF
		(*--------------------------------------------------------------------------------*)


		IF axCanCalcArcAdjustValue_Grp[iGrpId] THEN(*计算使能@一圈只执行一次*)
			(*将轴索引的调整量写入到色序索引中*)
			FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO
				iUnitId:=pstStGrpParam_UnSave^.abyGrpArcAxisList[iN];
				IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
					pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iUnitId]);
					pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iUnitId]);
					arFinalAdjust_V_ArcList[iN]:=aiFinalAdjust_V[iUnitId];
					IF iN<=DECOUPLD_DDPD_MAX THEN
						arFilmLenth_ArcList[iN]:=pstStUnitParam_Save^.rFilmLengthFromPrevPressUnit/1000;(*m*)
					END_IF
				END_IF
			END_FOR
			(*2024.03.05.095716 增加时延拍数的计算*)
			(*时延拍数N=TL/Ts+1@机组幅数-TL经过机组时间，ts版辊一圈时间*)
			pstStGrpParam_Save^.byDeCoupleDelayNum:=
					REAL_TO_BYTE(pstStGrpParam_Save^.rFilmLenth_InUnit*1000/pstStGrpParam_Save^.rGirth_PrnRoller);

			IF pstStGrpParam_UnSave^.rVel_Film<>0 THEN
				rTs:=pstStGrpParam_Save^.rGirth_PrnRoller/(pstStGrpParam_UnSave^.rVel_Film*1000/60);
			ELSE
				rTs:=1000;
			END_IF

			IF g_stStSysParam.stStSysParam_Save.byCouplingType=10 THEN(*不隔色解耦*)
				Decouple_ALL(
					arFinalAdjust_V_ArcList[2](*i_rPI2*),
					arFinalAdjust_V_ArcList[3](*i_rPI3*),
					arFinalAdjust_V_ArcList[4](*i_rPI4*),
					arFinalAdjust_V_ArcList[5](*i_rPI5*),
					arFinalAdjust_V_ArcList[6](*i_rPI6*),
					arFinalAdjust_V_ArcList[7](*i_rPI7*),
					arFinalAdjust_V_ArcList[8](*i_rPI8*),
					arFinalAdjust_V_ArcList[9](*i_rPI9*),
					arFinalAdjust_V_ArcList[10](*i_rPI10*),
					ADR(arFinalAdjust_V_Act_ArcList[2])(*i_prU2*),
					ADR(arFinalAdjust_V_Act_ArcList[3])(*i_prU3*),
					ADR(arFinalAdjust_V_Act_ArcList[4])(*i_prU4*),
					ADR(arFinalAdjust_V_Act_ArcList[5])(*i_prU5*),
					ADR(arFinalAdjust_V_Act_ArcList[6])(*i_prU6*),
					ADR(arFinalAdjust_V_Act_ArcList[7])(*i_prU7*),
					ADR(arFinalAdjust_V_Act_ArcList[8])(*i_prU8*),
					ADR(arFinalAdjust_V_Act_ArcList[9])(*i_prU9*),
					ADR(arFinalAdjust_V_Act_ArcList[10])(*i_prU10*),
(*					pstStGrpParam^.lrGirth_Pu(*i_rC*),*)
					pstStGrpParam_UnSave^.rVel_Film(*i_rV*),
					pstStGrpParam_Save^.rFilmLenth_InUnit(*i_rL*),
					ADR(astStArcCoupleRegister[iGrpId].arU2k)					(*i_prU2k*),
					ADR(astStArcCoupleRegister[iGrpId].arU3k)              	 	(*i_prU3k*),
					ADR(astStArcCoupleRegister[iGrpId].arY3k)                   (*i_prY3k*),
					ADR(astStArcCoupleRegister[iGrpId].arU4k)                   (*i_prU4k*),
					ADR(astStArcCoupleRegister[iGrpId].arY4k)                   (*i_prY4k*),
					ADR(astStArcCoupleRegister[iGrpId].arU5k)                   (*i_prU5k*),
					ADR(astStArcCoupleRegister[iGrpId].arY5k)                   (*i_prY5k*),
					ADR(astStArcCoupleRegister[iGrpId].arU6k)                   (*i_prU6k*),
					ADR(astStArcCoupleRegister[iGrpId].arY6k)                   (*i_prY6k*),
					ADR(astStArcCoupleRegister[iGrpId].arU7k)                   (*i_prU7k*),
					ADR(astStArcCoupleRegister[iGrpId].arY7k)                   (*i_prY7k*),
					ADR(astStArcCoupleRegister[iGrpId].arU8k)                   (*i_prU8k*),
					ADR(astStArcCoupleRegister[iGrpId].arY8k)                   (*i_prY8k*),
					ADR(astStArcCoupleRegister[iGrpId].arU9k)                   (*i_prU9k*),
					ADR(astStArcCoupleRegister[iGrpId].arY9k)                   (*i_prY9k*),
					ADR(astStArcCoupleRegister[iGrpId].arU10k)                   (*i_prU10k*),
					ADR(astStArcCoupleRegister[iGrpId].arY10k)                   (*i_prY10k*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU3_Gc1_1_Gc1_Yk)   (*i_prJIEOU3_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU4_Gc1_1_Gc1_Yk)   (*i_prJIEOU4_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU4_Gc2_1_Yk)       (*i_prJIEOU4_Gc2_1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU4_Gc2_1_Gc1_Uk)   (*i_prJIEOU4_Gc2_1_Gc1_Uk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU4_Gc2_1_Gc2_Yk)   (*i_prJIEOU4_Gc2_1_Gc2_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU5_Gc1_1_Gc1_Yk)   (*i_prJIEOU5_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU5_Gc2_1_Yk)       (*i_prJIEOU5_Gc2_1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU5_Gc2_1_Gc1_Uk)   (*i_prJIEOU5_Gc2_1_Gc1_Uk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU5_Gc2_1_Gc2_Yk)   (*i_prJIEOU5_Gc2_1_Gc2_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU5_Gc2Yk)          (*i_prJIEOU5_Gc2Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU6_Gc1_1_Gc1_Yk)   (*i_prJIEOU6_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU6_Gc2_1_Yk)       (*i_prJIEOU6_Gc2_1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU6_Gc2_1_Gc1_Uk)   (*i_prJIEOU6_Gc2_1_Gc1_Uk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU6_Gc2_1_Gc2_Yk)   (*i_prJIEOU6_Gc2_1_Gc2_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU6_Gc2Yk_K4)       (*i_prJIEOU6_Gc2Yk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU6_Gc2Yk_K3)       (*i_prJIEOU6_Gc2Yk_K3*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU7_Gc1_1_Gc1_Yk)   (*i_prJIEOU7_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU7_Gc2_1_Yk)       (*i_prJIEOU7_Gc2_1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU7_Gc2_1_Gc1_Uk)   (*i_prJIEOU7_Gc2_1_Gc1_Uk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU7_Gc2_1_Gc2_Yk)   (*i_prJIEOU7_Gc2_1_Gc2_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU7_Gc2Uk_K4)       (*i_prJIEOU7_Gc2Uk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU7_Gc2Yk_K4)       (*i_prJIEOU7_Gc2Yk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU7_Gc2Yk_K3)       (*i_prJIEOU7_Gc2Yk_K3*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc1_1_Gc1_Yk)   (*i_prJIEOU8_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2_1_Yk)       (*i_prJIEOU8_Gc2_1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2_1_Gc1_Uk)   (*i_prJIEOU8_Gc2_1_Gc1_Uk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2_1_Gc2_Yk)   (*i_prJIEOU8_Gc2_1_Gc2_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2Uk_K5)       (*i_prJIEOU8_Gc2Uk_K5*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2Yk_K5)       (*i_prJIEOU8_Gc2Yk_K5*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2Uk_K4)       (*i_prJIEOU8_Gc2Uk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2Yk_K4)       (*i_prJIEOU8_Gc2Yk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU8_Gc2Yk_K3)       (*i_prJIEOU8_Gc2Yk_K3*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc1_1_Gc1_Yk )  (*i_prJIEOU9_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2_1_Yk     )  (*i_prJIEOU9_Gc2_1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2_1_Gc1_Uk )  (*i_prJIEOU9_Gc2_1_Gc1_Uk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2_1_Gc2_Yk )  (*i_prJIEOU9_Gc2_1_Gc2_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2Uk_K5     )  (*i_prJIEOU9_Gc2Uk_K5*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2Yk_K5     )  (*i_prJIEOU9_Gc2Yk_K5*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2Uk_K4     )  (*i_prJIEOU9_Gc2Uk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2Yk_K4     )  (*i_prJIEOU9_Gc2Yk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU9_Gc2Yk_K3     )  (*i_prJIEOU9_Gc2Yk_K3*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc1_1_Gc1_Yk)  (*i_prJIEOU10_Gc1_1_Gc1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2_1_Yk    )  (*i_prJIEOU10_Gc2_1_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2_1_Gc1_Uk)  (*i_prJIEOU10_Gc2_1_Gc1_Uk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2_1_Gc2_Yk)  (*i_prJIEOU10_Gc2_1_Gc2_Yk*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2Uk_K5    )  (*i_prJIEOU10_Gc2Uk_K5*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2Yk_K5    )  (*i_prJIEOU10_Gc2Yk_K5*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2Uk_K4    )  (*i_prJIEOU10_Gc2Uk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2Yk_K4    )  (*i_prJIEOU10_Gc2Yk_K4*),
					ADR(astStArcCoupleRegister[iGrpId].arJIEOU10_Gc2Yk_K3    )  (*i_prJIEOU10_Gc2Yk_K3*),
					pstStGrpParam_Save^.byDeCoupleDelayNum(*i_iN*),
					(*pstStGrpParam^.xFlag_RollerPressDne AND
					pstStGrpParam^.lrVel_Film>=10(*i_bEn*)*) 
					TRUE,
					pstStGrpParam_Save^.byDeCoupleArcNum(*i_iNum*),
					rTs(*i_rTs*));

				(*2024.7.31.065130+清理轴寄存器*)
				FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpAxisNum_Pu BY 1 DO
					iUnitId:=pstStGrpParam_UnSave^.abyGrpAxisList[iN];
					IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
						IF iUnitId<=DECOUPLD_DDPD_MAX THEN
							IF g_pstStGlobalVarByAllocMem<>0 THEN
								SysMemSet(ADR(g_pstStGlobalVarByAllocMem^.astStDecoupleDDPD[iUnitId]),0,
										SIZEOF(g_pstStGlobalVarByAllocMem^.astStDecoupleDDPD[iUnitId]));
							END_IF
						END_IF
						arFinalAdjust_V_Act[iUnitId]:=0;(*只清理自己系的轴*)
					END_IF
				END_FOR
				
			ELSIF g_stStSysParam.stStSysParam_Save.byCouplingType=9 THEN(*隔色解耦@2024.7.31.063545*)
				KS_Decouple_DDPD(
					TRUE,
					arFinalAdjust_V_ArcList[2](*i_rPI2*),
					arFinalAdjust_V_ArcList[3](*i_rPI3*),
					arFinalAdjust_V_ArcList[4](*i_rPI4*),
					arFinalAdjust_V_ArcList[5](*i_rPI5*),
					arFinalAdjust_V_ArcList[6](*i_rPI6*),
					arFinalAdjust_V_ArcList[7](*i_rPI7*),
					arFinalAdjust_V_ArcList[8](*i_rPI8*),
					arFinalAdjust_V_ArcList[9](*i_rPI9*),
					arFinalAdjust_V_ArcList[10](*i_rPI10*),
					arFinalAdjust_V_ArcList[11](*i_rPI11*),
					arFinalAdjust_V_ArcList[12](*i_rPI12*),
					arFinalAdjust_V_ArcList[13](*i_rPI13*),
					ADR(arFinalAdjust_V_Act_ArcList[2])(*i_prU2*),
					ADR(arFinalAdjust_V_Act_ArcList[3])(*i_prU3*),
					ADR(arFinalAdjust_V_Act_ArcList[4])(*i_prU4*),
					ADR(arFinalAdjust_V_Act_ArcList[5])(*i_prU5*),
					ADR(arFinalAdjust_V_Act_ArcList[6])(*i_prU6*),
					ADR(arFinalAdjust_V_Act_ArcList[7])(*i_prU7*),
					ADR(arFinalAdjust_V_Act_ArcList[8])(*i_prU8*),
					ADR(arFinalAdjust_V_Act_ArcList[9])(*i_prU9*),
					ADR(arFinalAdjust_V_Act_ArcList[10])(*i_prU10*),
					ADR(arFinalAdjust_V_Act_ArcList[11])(*i_prU11*),
					ADR(arFinalAdjust_V_Act_ArcList[12])(*i_prU12*),
					ADR(arFinalAdjust_V_Act_ArcList[13])(*i_prU13*),
					pstStGrpParam_Save^.rGirth_PrnRoller(*i_rC*),
					pstStGrpParam_UnSave^.rVel_Film(*i_rV*),
					arFilmLenth_ArcList(*i_arLength*),
					pstStGrpParam_Save^.byDeCoupleArcNum(*i_DecoupleDepth*),
					ADR(g_pstStGlobalVarByAllocMem^.astStDecoupleDDPD)(*i_pastStDecoupleDDPD*));
				SysMemSet(ADR(astStArcCoupleRegister[iGrpId]),0,SIZEOF(astStArcCoupleRegister[iGrpId]));
			END_IF
			
			//2025.11.16.104557+ 跟踪第一色解耦
			afbKS_FB_GetCouplingValue_V[iGrpId](
				i_xEn:= TRUE,
				i_iGrpId:= iGrpId,
				i_byCouplingType:= g_stStSysParam.stStSysParam_Save.byCouplingType,
				i_iRemaindPartCouplingPos:= 0,
				i_xFlag_Follow1U:= FALSE,(*误差传递方式跟踪第一色*)
				i_iGrpArcAxisNum_Pu:= pstStGrpParam_UnSave^.byGrpArcAxisNum,
				i_abyGrpArcAxisList:= pstStGrpParam_UnSave^.abyGrpArcAxisList,
				i_pstStSysParam:= ADR(g_stStSysParam),
				i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE),
				//i_pastStPTSts:= i_pastStPTSts,
				i_pstStDeCoupleCoeff:= ADR(g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff),
				//i_axUseErrTransfer:= ,
				i_rTs:=rTs,
				o_xEno=> ,
				o_arCouplingValue=> arCouplingValue);
			
			(*将套色索引的轴调整量写入到轴索引中*)
			FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO
				iUnitId:=pstStGrpParam_UnSave^.abyGrpArcAxisList[iN];
				IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
					IF  g_stStSysParam.stStSysParam_Save.byCouplingType = 11 OR//跟踪第一色从fbKS_FB_GetCouplingValue_V获取
						 g_stStSysParam.stStSysParam_Save.byCouplingType = 12 THEN
						arFinalAdjust_V_Act[iUnitId]:=arCouplingValue[iUnitId];
					ELSE//跟踪前一色,从上面if else获取
						arFinalAdjust_V_Act[iUnitId]:=arFinalAdjust_V_Act_ArcList[iN];
					END_IF
				END_IF
			END_FOR
		END_IF

		(*调整量写入到队列*)
		FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO
			iUnitId:=pstStGrpParam_UnSave^.abyGrpArcAxisList[iN];
			(*将调整量压入待调整队列|*)
			IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
				pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iUnitId]);
				IF (g_stStSysParam.stStSysParam_Save.byCouplingType=10 OR(*使用小黄不隔色的解耦*)
					g_stStSysParam.stStSysParam_Save.byCouplingType=9 OR (*隔色解耦*)
					g_stStSysParam.stStSysParam_Save.byCouplingType=11 OR//跟踪第一色
					g_stStSysParam.stStSysParam_Save.byCouplingType=12)AND
					NOT xByPassDeCouple THEN(*2023.12.25.205549+不跳过解耦标志@如果跳过，就直接使用阶跃写入的调整量值*)
					IF pstStUnitParam_Save^.byCouplingMask.0 THEN(*解耦使能*)
						iFinalAdjust_V:=REAL_TO_INT(arFinalAdjust_V_Act[iUnitId]);
					ELSE(*取消解耦*)
						iFinalAdjust_V:=aiFinalAdjust_V[iUnitId];
					END_IF
				ELSE
					iFinalAdjust_V:=aiFinalAdjust_V[iUnitId];
				END_IF
				iFinalAdjust_H:=aiFinalAdjust_H[iUnitId];(*横向输出量*)

				(*获取最终调整量@2024.7.26.165107*)
				pstStUnitParam_UnSave^.iFinalAdjust_V:=iFinalAdjust_V;

				IF axCanCalcArcAdjustValue[iUnitId] THEN(*按圈有效*)
//					iFinalAdjust_V:= 1000;//测试代码2025.12.03.164002删除
					KS_PushRegAdjValue(ADR(g_astStRegAdjMana), iUnitId, iFinalAdjust_V, iFinalAdjust_H);
				END_IF
			END_IF
		END_FOR
	ELSE(*使用的寄存器清理*)
		SysMemSet(ADR(astStArcCoupleRegister[iGrpId]),0,SIZEOF(astStArcCoupleRegister[iGrpId]));
		SysMemSet(ADR(astStArcCoupleRegister_Follow1[iGrpId]),0,SIZEOF(astStArcCoupleRegister_Follow1[iGrpId]));
		FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpAxisNum_Pu BY 1 DO
			iUnitId:=pstStGrpParam_UnSave^.abyGrpAxisList[iN];
			IF iUnitId>=2 AND iUnitId<=16 THEN
				pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iUnitId]);
				pstStUnitParam_UnSave:=ADR(g_stStSysParam.astStUnitParam_UnSave[iUnitId]);
				arFinalAdjust_V_Act[iUnitId]:=0;(*只清理自己系的轴*)
				pstStUnitParam_UnSave^.iFinalAdjust_V:=0;
				(*2024.7.31.065130+*)
				IF g_pstStGlobalVarByAllocMem<>0 THEN
					IF iUnitId<=DECOUPLD_DDPD_MAX THEN
						SysMemSet(ADR(g_pstStGlobalVarByAllocMem^.astStDecoupleDDPD[iUnitId]),0,
								SIZEOF(g_pstStGlobalVarByAllocMem^.astStDecoupleDDPD[iUnitId]));
					END_IF
				END_IF
			END_IF
		END_FOR
		IF iGrpId=g_stStSysParam.stStSysParam_UnSave.byCurGrpId_HMI THEN(*2024.9.4.092958*)
			g_stStSysParam.stStSysParam_UnSave.byArcDeCoupleStepTest:= 0;(* 只在当前系内操作 *)
		END_IF
		
	
		//2025.11.16.104557+ 跟踪第一色解耦|复位参数
		afbKS_FB_GetCouplingValue_V[iGrpId](
			i_xEn:= FALSE,
			i_iGrpId:= iGrpId,
			i_byCouplingType:= g_stStSysParam.stStSysParam_Save.byCouplingType,
			i_iRemaindPartCouplingPos:= 0,
			i_xFlag_Follow1U:= FALSE,(*误差传递方式跟踪第一色*)
			i_iGrpArcAxisNum_Pu:= pstStGrpParam_UnSave^.byGrpArcAxisNum,
			i_abyGrpArcAxisList:= pstStGrpParam_UnSave^.abyGrpArcAxisList,
			i_pstStSysParam:= ADR(g_stStSysParam),
			i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE),
			//i_pastStPTSts:= i_pastStPTSts,
			i_pstStDeCoupleCoeff:= ADR(g_pstStGlobalVarByAllocMem^.stStDeCoupleCoeff),
			//i_axUseErrTransfer:= ,
			i_rTs:=rTs,
			o_xEno=> ,
			o_arCouplingValue=> arCouplingValue);
	END_IF
(*2025.1.3.135755 屏蔽*)
(*
	(*按系循环@2024.7.26.164557*)
	(*估计裁切的扰动|计算套色补偿量*)
	FOR iN:=2 TO pstStGrpParam^.byGrpArcAxisNum BY 1 DO
		iUnitId:=pstStGrpParam^.abyGrpArcAxisList[iN];
		IF iUnitId>=2 AND iUnitId<=16 THEN(*只处理2--16轴*)
			pstStAxisParam:=ADR(g_pstStShmGlobalParam^.astStAxisParam[iUnitId]);(*2024.7.26.162334*)
			(*xSkipHeaderSts 标志是一直在计算的@2024.7.26.215952*)
			IF pstStAxisParam^.xSkipHeaderSts AND NOT axPrevSkipHeaderSts[iUnitId] THEN(*有让料头|则置位标志*)
				pstStAxisParam^.xEstStart_ArcCompensate_UwCut:=TRUE;

				(*2024.7.26.215916 开始的时候吧参数复位下*)
				arD_hat[iUnitId]:=0;
				arD_hat_Cal[iUnitId]:=0;
				arU_hat[iUnitId]:=0;
				abyCNT[iUnitId]:=0;
				pstStAxisParam^.rEstValue_ArcCompensate_UwCut:=0;
				SysMemSet(ADR(arU[iUnitId,1]),0,6*4);(*6个real*)
				SysMemSet(ADR(arE[iUnitId,1]),0,6*4);(*6个real*)
			END_IF
			axPrevSkipHeaderSts[iUnitId]:=pstStAxisParam^.xSkipHeaderSts;

			IF pstStGrpParam^.xFlag_Print THEN
				IF axCanCalcArcAdjustValue[iUnitId] THEN(*按圈有效*)
					Cal_Dis(
						pstStGrpParam^.lrVel_Film(*i_rV*),
						pstStGrpParam^.lrGirth_Pu(*i_rCL*),
						pstStGrpParam^.rFilmLenth_InUnit(*i_rL*),
						3(*i_iN*),
						pstStAxisParam^.iFinalAdjust_V(*i_rU*),
						aiArcActErr_V[iUnitId](*i_rE*),
						TRUE(*i_xJudgeErrToBig*),
						4(*i_iThreshold*),
						1.1(*i_rThresholdCoeff*),
						ADR(arD_hat[iUnitId])(*i_prD_hat*),
						ADR(arD_hat_Cal[iUnitId])(*i_prD_hat_Cal*),
						ADR(arU_hat[iUnitId])(*i_prU_hat*),
						ADR(arU[iUnitId,1])(*i_parU*),
						ADR(arE[iUnitId,1])(*i_parE*),
						ADR(pstStAxisParam^.xEstStart_ArcCompensate_UwCut)(*i_pabFlag*),
						ADR(abyCNT[iUnitId])(*i_pbyCNT*),
						ADR(arThreshold_Act[iUnitId])(*i_prThreshold_Act*));
					IF NOT pstStAxisParam^.xCalcDne_ArcCompensate_UwCut AND(*未计算完成*)
						arD_hat_Cal[iUnitId]<>0 THEN
						pstStAxisParam^.rEstValue_ArcCompensate_UwCut:=arD_hat_Cal[iUnitId];
						pstStAxisParam^.xCalcDne_ArcCompensate_UwCut:=TRUE;(*计算完成*)
					END_IF
				END_IF
			ELSE
				pstStAxisParam^.xEstStart_ArcCompensate_UwCut:=FALSE;
				pstStAxisParam^.xCalcDne_ArcCompensate_UwCut:=FALSE;(*计算完成*)
				pstStAxisParam^.rEstValue_ArcCompensate_UwCut:=0;
			END_IF
		END_IF
	END_FOR
*)
END_FOR