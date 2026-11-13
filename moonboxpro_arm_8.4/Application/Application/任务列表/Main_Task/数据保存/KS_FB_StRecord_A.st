(*@CES
Name=KS_FB_StRecord_A
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7892d2ce-415a-4db2-a255-854b9f2f62ee
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
//2025.08.22.095041 | 重新整理套色数据

FUNCTION_BLOCK KS_FB_StRecord_A
VAR_INPUT
	i_xEn: BOOL;(* 数据写入的使能条件 *)
	i_iGrpId:INT;(*系Id*)
	i_iUnitId:INT;(*轴ID*)
	i_pstStSysParam : POINTER TO StSysParam;
	i_xRel_Press: BOOL;(*压辊输出*)
	i_iTmp_DataIndex : INT;(*误差传递的幅数|*)
	i_iSaveTmp_RelayErrData_V : INT;(*2018.8.17.155253\传递的误差量|*)
	i_iFinalAdjust_V : INT;(*计算的调整量*)
	i_iFinalAdjust_H : INT;(*计算的调整量*)
	i_iArcErr_V : INT;(*纵向误差*)
	i_iArcErr_H : INT;(*横向误差*)
	i_xSkipHeaderSts: BOOL;(*让料头状态*)
	i_xCompensateEn_H : BOOL;(*横向裁切补偿使能*)
	i_iVKp_Use,i_iVKi_Use,i_iVKd_Use:INT;
	i_arFinalAdjust_V_Act: ARRAY [1..MAX_UNIT_NUM] OF REAL;(*实际调整量数组*)
	i_stStErrParam_Use: StErrParam_Use;

END_VAR
VAR_OUTPUT
END_VAR
VAR
	iTmpN:INT;
	stStRecord_A_Tmp: StRecord_A;
	sResult: STRING;
	byStsV: BYTE; (* 纵向误差状态 *)
	byStsH: BYTE; (* 横向误差状态 *)	
END_VAR

{IMPLEMENTATION}

	(*--------------------------------------------------|*)
	(*保存套色数据|2020.1.6.153130_*)
	(*--------------------------------------------------|*)
	sResult:= KS_GetTimeString(TIMEFORMAT_NO_HYPHEN, FALSE, FALSE, ADR(stStRecord_A_Tmp.dwCurYMD), ADR(stStRecord_A_Tmp.dwCurHMSU));(* 2023.7.27.093547/han.dp |时间戳*)
	stStRecord_A_Tmp.byAxisId:= INT_TO_BYTE(i_iUnitId);(*轴id|*)
	stStRecord_A_Tmp.byGrpId:= INT_TO_BYTE(i_iGrpId);(*系id|*)
	stStRecord_A_Tmp.uiNum:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].uiNum_PrnRoller;(*减速比分子|*)
	stStRecord_A_Tmp.uiDen:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].uiDen_PrnRoller;(*减速比分母|*)
	stStRecord_A_Tmp.udiVel:= LREAL_TO_UDINT(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur*100.0);(*主机速度|单位:0.01m/min|*)
	stStRecord_A_Tmp.udiGirth:= LREAL_TO_UDINT(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rGirth_PrnRoller*1000.0);(*版周长|单位:0.001mm|*)
	stStRecord_A_Tmp.iGateSa:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iGateSa;(*波门地址1|*)

	stStRecord_A_Tmp.iGateSaEx:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iGateSaEx;(*波门地址2|*)
	stStRecord_A_Tmp.byMarkTypeId:= INT_TO_BYTE(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iMarkTypeId);(*标记形式|*)
	stStRecord_A_Tmp.byMarkArrangeId:= INT_TO_BYTE(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iMarkArrangeMode);(*标记排列|*)
	stStRecord_A_Tmp.wSwitchRef:= DWORD_TO_WORD(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].dwFlag_Ctl);(*开关状态|*)
	stStRecord_A_Tmp.wStatusRef:= DWORD_TO_WORD(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].dwFlag_Sts);(*手/自动状态|*)
	stStRecord_A_Tmp.wExtendedProf:= 0;(*描述位|bit0=1表示合压中,bit1=1标识等料长,bit2=1标识裁切让料头|*)
	stStRecord_A_Tmp.wExtendedProf.0:= i_xRel_Press;(*压辊输出|*)
	stStRecord_A_Tmp.wExtendedProf.1:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].xWaitFilmLength;(*等料长|*)
	stStRecord_A_Tmp.wExtendedProf.2:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].xSkipHeader;(*让料头|*)
(*
	(*保存为实时判断的让料头标志@误差变相*)
	stStRecord_A_Tmp.wExtendedProf.2:= afbKS_ARC_PIDAdjust[iUnitId].xAvoidFilmHead(*wParam.2*);(*让料头|*)
*)
	(*2023.6.6.160840*)
	stStRecord_A_Tmp.wExtendedProf.3:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].xWaitFilmLenth_Follow1U;(*等料长|等1色*)
	stStRecord_A_Tmp.wExtendedProf.4:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].xWaitFilmLenth_FollowPreU;(*等料长|等前一色*)

	stStRecord_A_Tmp.wExtendedProf.5:= i_xSkipHeaderSts;(*让料头@只要接料就会输出但是根据开关是否使用*)
	stStRecord_A_Tmp.wExtendedProf.6:= i_pstStSysParam^.stStSysParam_Save.xUseArcErr_Lp;(*使用低通滤波后的误差*)
	stStRecord_A_Tmp.wExtendedProf.7:= i_xCompensateEn_H;(*横向裁切补偿使能@2024.8.1.122143*)
	(*新增2023.5.10.124537*)
	stStRecord_A_Tmp.wExtendedProf.8:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].dwFlag_Ctl.2;(*极性|*)
	stStRecord_A_Tmp.wExtendedProf.9:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].dwFlag_Ctl.11;(*极性|*)
	stStRecord_A_Tmp.wExtendedProf.10:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].dwFlag_Ctl.3;(*极性|*)
	stStRecord_A_Tmp.wExtendedProf.11:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].dwFlag_Ctl.12;(*极性|*)
	stStRecord_A_Tmp.wExtendedProf.12:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].byArcSts=1;(*套色调整状态|为稳态@2024.9.2.125556+*)
	stStRecord_A_Tmp.wExtendedProf.13:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].dwFlag_Sts.31;(*增加新的滤波方式开关| 2025.11.16.091803*)
	
byStsV:= 0;
byStsV.0:= i_stStErrParam_Use.byErrSts.0;
byStsV.1:= i_stStErrParam_Use.byErrSts.1;
byStsV.2:= i_stStErrParam_Use.byErrSts.2;
byStsH:= 0;
byStsH.0:= i_stStErrParam_Use.byErrSts.4;
byStsH.1:= i_stStErrParam_Use.byErrSts.5;
byStsH.2:= i_stStErrParam_Use.byErrSts.6;
	
	
	stStRecord_A_Tmp.byStsV:= byStsV;(*纵向误差状态|*)
	stStRecord_A_Tmp.byStsH:= byStsH;(*横向误差状态|*)
	stStRecord_A_Tmp.aiKpid_used_v[1]:=  i_iVKp_Use;//i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iKp_V;(*使用中的纵向Kp|*)
	stStRecord_A_Tmp.aiKpid_used_v[2]:=  i_iVKi_Use;//i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iKi_V;(*使用中的纵向Ki|*)
	stStRecord_A_Tmp.aiKpid_used_v[3]:=  i_iVKd_Use;//i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iKd_V;(*使用中的纵向Kd|*)

//2026.05.10.152031||niu.j|增加视觉误差保存
	stStRecord_A_Tmp.aiKpid_setup_h[1]:= i_stStErrParam_Use.uiV_cam_raw;
	stStRecord_A_Tmp.aiKpid_setup_h[2]:= i_stStErrParam_Use.uiH_cam_raw;
	stStRecord_A_Tmp.aiKpid_setup_h[3]:= i_stStErrParam_Use.iV_cam_pure;
	stStRecord_A_Tmp.aiKpid_setup_v[3]:= i_stStErrParam_Use.iH_cam_pure;

	stStRecord_A_Tmp.aiAdjVal_vh[1]:= REAL_TO_INT(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rAdj_V*100.0);(*纵向版修正量|*)
	stStRecord_A_Tmp.aiAdjVal_vh[2]:= REAL_TO_INT(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rAdj_H*100.0);(*横向版修正量|*)
	stStRecord_A_Tmp.lrFilmLengthFromPrevUnit:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].lrFilmLengthFromPrevUnit;(*2018.8.17.155715\料长总值|*)
	stStRecord_A_Tmp.byCouplingMask:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].byCouplingMask;(*2018.8.17.155313\耦合开关|*)
	stStRecord_A_Tmp.iErrDataRelay_Index_V:= i_iTmp_DataIndex;(*2018.8.17.155456\误差传递的幅数|*)
	(*2022.5.23.185541 误差传递值一直存储*)
	stStRecord_A_Tmp.iErrDataRelay_V:= i_iSaveTmp_RelayErrData_V(*iTmp_RelayErrData_V*);(*2018.8.17.155253\传递的误差量|*)
	stStRecord_A_Tmp.aiErrorVal_vh[1]:= i_iArcErr_V;(*纵向误差|计算调整量使用的误差*)
	stStRecord_A_Tmp.aiErrorVal_vh[2]:= i_iArcErr_H;(*stStPara_PduBroadcastUp.iHerror;*)(*横向误差|*)
	stStRecord_A_Tmp.aiAdjValCalcByPid_vh[1]:= i_iFinalAdjust_V;(*计算的调整量|*)
	stStRecord_A_Tmp.aiAdjValCalcByPid_vh[2]:= i_iFinalAdjust_H;(*计算的调整量|*)
	(*2023.11.18.194830 +*)
	stStRecord_A_Tmp.rFinalAdjust_V_Act:= i_arFinalAdjust_V_Act[i_iUnitId];(*经过小黄耦合函数处理过的误差值@应该是上一拍的值|*)



	(*2023.09.04.093226*)
	stStRecord_A_Tmp.aiActErrorVal_vh[1]	:= i_stStErrParam_Use.iErr_V;(*通讯上来的值*)
	stStRecord_A_Tmp.aiActErrorVal_vh[2]	:= i_stStErrParam_Use.iErr_H;(*通讯上来的值*)

(*先屏蔽下吧@2023.10.09.144804*)
(*
	(*2023.09.11.113202*)
	(*需要外部修改输入*)
	stStRecord_A_Tmp.iCurrentObservationError :=g_astStArcErr_KalmanFilter[iUnitId].iCurrentObservationError;(*当前观测误差|丝*)
	stStRecord_A_Tmp.iPreviousAdjustment:=g_astStArcErr_KalmanFilter[iUnitId].iPreviousAdjustment;(*上一幅调整量@正误差需要输入负调整量-外面根据正逆序修改|微米*)
	(*最终返回预测误差*)
	stStRecord_A_Tmp.iPredictionError:=g_astStArcErr_KalmanFilter[iUnitId].iPredictionError; (*预测误差|丝*)
	stStRecord_A_Tmp.rKalmanGain:=g_astStArcErr_KalmanFilter[iUnitId].rKalmanGain; (*k*)
*)

	(*复用下@小黄控制器中间变量|2023.09.05.132632*)
	IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iWorkMode_Pid=4 OR i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iWorkMode_Pid=3 THEN
		IF i_iUnitId>=2 AND i_iUnitId<=16 THEN(*限制到2-16轴*)
			
			stStRecord_A_Tmp.aiParsing_min[1]:= REAL_TO_INT(PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].arYPk_huang[1]);
			stStRecord_A_Tmp.aiParsing_max[1]:= REAL_TO_INT(PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].arYIk_huang[1]);(*[2]=[1] 就存[1]*)
			stStRecord_A_Tmp.aiParsing_base[1]:=REAL_TO_INT(PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].arYPIDk_Huang[1]);(*[2]=[1] 就存[1]*)
			stStRecord_A_Tmp.aiParsing_min[2]:= REAL_TO_INT(PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].rSigema_PID);(*绝对式的限值*)
			stStRecord_A_Tmp.aiParsing_max[2]:= REAL_TO_INT(PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].rReal_Delta_PID);(*使用绝对式限值后的增量值*)
		(*	stStRecord_A_Tmp.aiParsing_min[2]:= REAL_TO_INT(afbKS_ARC_PIDAdjust[iUnitId].arYI2k_Huang[1]);(*[2]=[1] 就存[1]*)*)
		ELSE

			stStRecord_A_Tmp.aiParsing_base[1]	:= 0;
			stStRecord_A_Tmp.aiParsing_base[2]	:= 0;
			stStRecord_A_Tmp.aiParsing_min[1]	:= 0;
			stStRecord_A_Tmp.aiParsing_min[2]	:= 0;
			stStRecord_A_Tmp.aiParsing_max[1]	:= 0;
			stStRecord_A_Tmp.aiParsing_max[2]	:= 0;
		END_IF
	ELSE
		stStRecord_A_Tmp.aiParsing_base[1]	:= 0;
		stStRecord_A_Tmp.aiParsing_base[2]	:= 0;
		stStRecord_A_Tmp.aiParsing_min[1]	:= 0;
		stStRecord_A_Tmp.aiParsing_min[2]	:= 0;
		stStRecord_A_Tmp.aiParsing_max[1]	:= 0;
		stStRecord_A_Tmp.aiParsing_max[2]	:= 0;
	END_IF
	(*全自动套印保存的内容*)
	//stStRecord_A_Tmp.aiParsing_max[2]:=	i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].aiPos_Cur_AutoAdj[1];
//	stStRecord_A_Tmp.aiParsing_base[2]:=i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].aiPos_Pre_AutoAdj[1];


	FOR iTmpN:=1 TO 2 BY 1 DO
		stStRecord_A_Tmp.alrCurCycleAdjustVal_Auto_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrCurCycleAdjustVal_Auto_vh[iTmpN];
		stStRecord_A_Tmp.alrCurCycleAdjustVal_Rapid_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrCurCycleAdjustVal_Rapid_vh[iTmpN];
		stStRecord_A_Tmp.alrCurCycleAdjustVal_ManuCoarse_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[iTmpN];
		stStRecord_A_Tmp.alrCurCycleAdjustVal_ManuFine_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrCurCycleAdjustVal_ManuFine_vh[iTmpN];
		stStRecord_A_Tmp.alrCurCycleAdjustVal_Coupling_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrCurCycleAdjustVal_Coupling_vh[iTmpN];
		stStRecord_A_Tmp.alrCurcycleAdjustVal_Compensate_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrCurcycleAdjustVal_Compensate_vh[iTmpN];
		stStRecord_A_Tmp.alrTotalAdjustVal_Auto_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrTotalAdjustVal_Auto_vh[iTmpN];
		stStRecord_A_Tmp.alrTotalAdjustVal_Rapid_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrTotalAdjustVal_Rapid_vh[iTmpN];
		stStRecord_A_Tmp.alrTotalAdjustVal_ManuCoarse_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrTotalAdjustVal_ManuCoarse_vh[iTmpN];
		stStRecord_A_Tmp.alrTotalAdjustVal_ManuFine_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrTotalAdjustVal_ManuFine_vh[iTmpN];
		stStRecord_A_Tmp.alrTotalAdjustVal_Coupling_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrTotalAdjustVal_Coupling_vh[iTmpN];
		stStRecord_A_Tmp.alrTotalAdjustVal_Compensate_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrTotalAdjustVal_Compensate_vh[iTmpN];
		stStRecord_A_Tmp.alrExecutedAdjVal_Auto_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Auto_vh[iTmpN];
		stStRecord_A_Tmp.alrExecutedAdjVal_Rapid_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Rapid_vh[iTmpN];
		stStRecord_A_Tmp.alrExecutedAdjVal_ManuCoarse_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_ManuCoarse_vh[iTmpN];
		stStRecord_A_Tmp.alrExecutedAdjVal_ManuFine_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_ManuFine_vh[iTmpN];
		stStRecord_A_Tmp.alrExecutedAdjVal_Coupling_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Coupling_vh[iTmpN];
		stStRecord_A_Tmp.alrExecutedAdjVal_Compensate_vh[iTmpN]:= i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Compensate_vh[iTmpN];
(*2025.08.29.165219||清除已调整量*)
		i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Auto_vh[1]:= 0;
		i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Rapid_vh[1]:= 0;
		i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_ManuCoarse_vh[1]:= 0;
		i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_ManuFine_vh[1]:= 0;
		i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Coupling_vh[1]:= 0;
		i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].alrExecutedAdjVal_Compensate_vh[1]:= 0;
		
		IF iTmpN=2 THEN
			
			//stStRecord_A_Tmp.alrCurcycleAdjustVal_Compensate_vh[iTmpN]:=(rErr_ArcAccOrDecCompensate);(*替换为升速补偿值@2024.8.30.150236*)
		//	stStRecord_A_Tmp.alrTotalAdjustVal_Compensate_vh[iTmpN]:= arDeltaAcceleration_Cur_Delay[iUnitId,1](*INT_TO_LREAL(aiArcActErr_V[iUnitId])*);
			//stStRecord_A_Tmp.alrExecutedAdjVal_Compensate_vh[iTmpN]:=i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rAcceleration_Cur;(*BYTE_TO_LREAL(abyCNT[iUnitId])*);
		
			(*2024.05.15.160626 替换*)
			//stStRecord_A_Tmp.alrCurCycleAdjustVal_Coupling_vh[iTmpN]:=afbKS_ARC_PIDAdjust[iUnitId].rSmith_Out;
			//stStRecord_A_Tmp.alrTotalAdjustVal_Coupling_vh[iTmpN]:=afbKS_ARC_PIDAdjust[iUnitId].rTotalAdjustValue_Act;
			//stStRecord_A_Tmp.alrExecutedAdjVal_Coupling_vh[iTmpN]:=afbKS_ARC_PIDAdjust[iUnitId].rErrValue_Use_4;
	
			stStRecord_A_Tmp.alrCurCycleAdjustVal_ManuFine_vh[iTmpN]:=PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].rCompensateValue_Hor;(*横向补偿值*)
		
			stStRecord_A_Tmp.alrTotalAdjustVal_ManuFine_vh[iTmpN]:=	PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].rResult_Total_Hor;(*补偿的总量*)
			stStRecord_A_Tmp.alrExecutedAdjVal_ManuFine_vh[iTmpN]:=	BOOL_TO_LREAL(PLC_PRG.afbKS_FB_ARC_PIDAdjust[i_iUnitId].xWatching_Hor);
		
		
		
		(*2024.8.22.101305|}||替换保存一些东西*)
		//	stStRecord_A_Tmp.alrCurCycleAdjustVal_Rapid_vh[iTmpN]:= INT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iVerror_Follow1U_New);
			//stStRecord_A_Tmp.alrTotalAdjustVal_Rapid_vh[iTmpN]:=BOOL_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].xUseAntiNotch_Arc);
						(*BYTE_TO_LREAL(g_pstStShmGlobalParam^.stStSystemExtInfo.byArcFineSampleType);*)
		//	stStRecord_A_Tmp.alrExecutedAdjVal_Rapid_vh[iTmpN]:= INT_TO_LREAL(i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].iHerror_Follow1U_New);
		END_IF
		
	END_FOR
//2025.11.13.111548先临时保存吧，后面规整
	stStRecord_A_Tmp.alrCurCycleAdjustVal_Auto_vh[1]:= i_stStErrParam_Use.uiBaseUse_t1;
	stStRecord_A_Tmp.alrCurCycleAdjustVal_Rapid_vh[1]:= i_stStErrParam_Use.uiBaseUse_t2;
	stStRecord_A_Tmp.alrCurCycleAdjustVal_ManuCoarse_vh[1]:= i_stStErrParam_Use.uiPeakValue_t1;
	stStRecord_A_Tmp.alrCurCycleAdjustVal_ManuFine_vh[1]:= i_stStErrParam_Use.uiPeakValue_t2;
	stStRecord_A_Tmp.alrCurCycleAdjustVal_Coupling_vh[1]:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rOffset_T1;
	stStRecord_A_Tmp.alrCurcycleAdjustVal_Compensate_vh[2]:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rOffset_T2;
	stStRecord_A_Tmp.alrTotalAdjustVal_Compensate_vh[2]:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rSource_Light_T1;
	stStRecord_A_Tmp.alrExecutedAdjVal_Compensate_vh[2]:= i_pstStSysParam^.astStUnitParam_Save[i_iUnitId].rSource_Light_T2;

	
	stStRecord_A_Tmp.dwFS_index:=UINT_TO_DWORD(i_stStErrParam_Use.uiFSampleCounter);(*精采样数据帧数|*)
	(*修改到轴参数中写入@2023.11.18.091010*)
	stStRecord_A_Tmp.iVerror_FollowPreUnit 	:=i_stStErrParam_Use.iErr_V_Unprocessed 	; (*纵向跟前一色误差*)
	stStRecord_A_Tmp.iVerror_Follow1Unit 	:=i_stStErrParam_Use.iResult_VFollowpre_1stDerivate	;(*纵向跟1色误差*)
	stStRecord_A_Tmp.iHerror_FollowPreUnit 	:=i_stStErrParam_Use.iErr_H_Unprocessed 	; (*横向跟前一色误差*)
	stStRecord_A_Tmp.iHerror_Follow1Unit 	:=i_stStErrParam_Use.iHerror_Follow1Unit 	;(*横向跟1色误差*)

	stStRecord_A_Tmp.dwIndex:= g_adwIndex[i_iGrpId];//g_astStTaskCycleDetection[1].udiCycleCnt;
	stStRecord_A_Tmp.xSaveFineSampleData_ToArc:=i_pstStSysParam^.stStSysParam_UnSave.xSaveFineSampleData_ToArc;(*2023.06.14.100315*)
	i_pstStSysParam^.stStSysParam_UnSave.xSaveFineSampleData_ToArc:=FALSE;
	//2026.5.9.190456+
	stStRecord_A_Tmp.dwTime:=i_pstStSysParam^.astStUnitParam_UnSave[i_iUnitId].dwLockTime_GetArcErr;

	(*写入到套色数据集中|2020.1.6.152831_*)
	KS_Push2DatasetARC(g_pstStDatasetARC, ADR(stStRecord_A_Tmp));
	(*--------------------------------------------------||*)

