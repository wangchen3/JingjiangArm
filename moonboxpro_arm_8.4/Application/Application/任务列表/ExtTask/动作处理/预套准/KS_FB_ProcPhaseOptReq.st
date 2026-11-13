(*@CES
Name=KS_FB_ProcPhaseOptReq
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6268291a-1193-49d9-aade-964d423980f4
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_ProcPhaseOptReq (*0成功/-1参数错误|*)
(*2023.10.16.161503  处理轴的初始相位获取功能@mark线和键槽有固定相位|预套准的时候不需要手工对mark线*)
(*2023.10.17.085925|+i_xFlag_LinkageAtleast接口 *)
(*2025.1.12.171334 增加在不使能byAxisInitPhaseTypeWhenPreRegister(=1)时预套准记录mark线位置实现*)
(*2025.1.13.191531 新增加的固定相位功能在其他预套使能条件上增加*)
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系内所有轴的id列表,色组部分已经按照从小到大的顺序排序了，之后的是牵引|*)
	i_pstStSysParam: POINTER TO StSysParam;
//	i_pastStPTSts: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StPTSts;(*PT运动轴的状态|*)
	i_pxFlag_CphCommonVir: POINTER TO BOOL;
	i_pxCphaseRestore: POINTER TO BOOL;
	i_pxFlag_CphCommonVir_end: POINTER TO BOOL;
	i_pxCphaseRestore_end: POINTER TO BOOL;
	i_xFlag_LinkageAtleast1:BOOL;(*2023.10.17.085835  至少联动一色标志|改标志有效的时候预套准相关按钮不能有效*)
	(*2025.1.3.164800+目前只有运城制版使用*)
	i_xFixedPhaseSave:BOOL;(*固定的相位保存@外部需要清除*)
	i_xFixedPhaseRead:BOOL;(*固定的相位读取@外部需要清除*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_iErrCode:INT;
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	(*2023.10.16.155940 初始原点位置保存标志*)
	xFlag_SaveAllData: BOOL;
	xFlag_SaveProtionData: BOOL;
	xBtn_InitPhaseHmiDis: BOOL;(*界面显示按钮*)
	xFlag_Enable: BOOL;(*一些运动的使能标志*)
	fbKS_FB_PhaseSave: KS_FB_PhaseSave;(*固定相位保存|2024.9.6.213537*)
	(*增加预套准标志沿@2025.1.12.170825*)
	fbRtrig_xFlag_PreRegister: R_TRIG;
	xFlag_CanSaveMarkPos:BOOL;(*可以记录标记位置标志*)
	byAxisInitPhaseTypeWhenPreRegister: BYTE;(*使能修改为了临时变量*)
END_VAR
{IMPLEMENTATION}
IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*色组数量有效|*)
	i_pstStSysParam<>0 AND(*参数地址有效|*)
//	i_pastStPTSts<>0 AND
	i_pxFlag_CphCommonVir<>0 AND
	i_pxCphaseRestore<>0 AND
	i_pxFlag_CphCommonVir_end<>0 AND
	i_pxCphaseRestore_end<>0 THEN(*轴PT状态有效|*)
	(*判断读取绝对位置完成标志|2019.03.05.093558|niu.j*)
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];
		IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN
			IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Sts.12=1 THEN
				i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end:= TRUE;
			ELSIF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Sts.12<>1 THEN
				i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end:= FALSE;
				EXIT;
			END_IF
		END_IF
	END_FOR

	(*2023.10.16.161034|轴初始相位写入功能*)
	IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAxisInitPhaseTypeWhenPreRegister>1 THEN(*非法值处理*)
		i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAxisInitPhaseTypeWhenPreRegister:=0;
	END_IF

	(*********************START****************************************************)
	(*2025.1.12.170519 增加在预套准开始的时候记录mark线位置*)
	(*不用预套自动恢复mark线功能时*)
	xFlag_CanSaveMarkPos:=FALSE;
	byAxisInitPhaseTypeWhenPreRegister:=0;
	IF i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAxisInitPhaseTypeWhenPreRegister=0 THEN
		fbRtrig_xFlag_PreRegister(CLK:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister);
		(*刚进入预套准@触发记录mark线功能*)
		IF fbRtrig_xFlag_PreRegister.Q AND NOT i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xPreRegisterAxisId_Manu THEN
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_SaveAllData:=TRUE;
			xFlag_CanSaveMarkPos:=TRUE;
			byAxisInitPhaseTypeWhenPreRegister:=1;
		END_IF
	ELSE(*mark线和键槽固定相位时标志处理*)
		fbRtrig_xFlag_PreRegister(CLK:=FALSE);
		xFlag_CanSaveMarkPos:=(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStop)AND(*急停或者停止都可以存储*)
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end AND(*所有联动轴已经有z脉冲了*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun AND(*整机单运行*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home AND(*读取装版相位*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister AND(*预套准*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore(*相位恢复*);

		byAxisInitPhaseTypeWhenPreRegister:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byAxisInitPhaseTypeWhenPreRegister;
	END_IF
	(******************END*******************************************************)


	KS_GetAxisInitPhaseWhenPreRegister(
		byAxisInitPhaseTypeWhenPreRegister(*i_byAxisInitPhaseTypeWhenPreRegister*),
		xFlag_CanSaveMarkPos(*i_xFlag_CanSaveData*),
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_SaveAllData(*i_xBtn_SaveAllData*),
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_SaveProtionData(*i_xBtn_SaveProtionData*),
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_SaveCancel(*i_xBtn_SaveCancel*),
		xBtn_InitPhaseHmiDis(*i_xBtn_DisHmi*),
		i_iGrpAxisNum_Pu(*i_iGrpAxisNum_Pu*),
		i_aiGrpAxisList(*i_aiGrpAxisList*),
		i_pstStSysParam,
//		i_pastStPTSts(*i_pastStPTSts*),
		ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AxisInitPhaseHmiDis)(*i_pxInitPhaseHmiSts*),
		ADR(xFlag_SaveAllData)(*i_pxFlag_SaveAll*),
		ADR(xFlag_SaveProtionData)(*i_pxFlag_SaveProtion*));
		(*按钮清除*)
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_SaveAllData:=FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_SaveProtionData:=FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_SaveCancel:=FALSE;
		xBtn_InitPhaseHmiDis:=FALSE;
	(*2023.10.16.161034|轴初始相位写入功能*)


		(*2024.6.22.164252|固定相位保存*)
		fbKS_FB_PhaseSave(
			i_xEn:= TRUE,
			i_xCanSave:= (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStop)AND(*急停或者停止都可以存储*)
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end AND(*所有联动轴已经有z脉冲了*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun AND(*整机单运行*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home AND
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister AND
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore,(*读取装版相位*)
			i_xBtnSave:= i_xFixedPhaseSave,
			i_xCanRead:=(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop)AND(*停止可以读取*)
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end AND(*所有联动轴已经有z脉冲了*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun AND(*整机单运行*)
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home AND
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister AND
						NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore,(*2025.1.13.180858+*)
			i_xBtnRead:= i_xFixedPhaseRead,
			i_iGrpAxisNum_Pu:= i_iGrpAxisNum_Pu,
			i_aiGrpAxisList:= i_aiGrpAxisList,
			i_pstStSysParam:= i_pstStSysParam,
	//		i_pastStPTSts:= i_pastStPTSts,
			io_xFlag_Save:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseSave,(*2024.12.25.110424+*)
			io_xFlag_Read:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRead,(*2024.12.25.112509*)
			o_xEn=>);

	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_Home THEN(*绝对位置确认/回原点|*)
		(*2023.10.17.090304*)
		xFlag_Enable:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping) AND

			i_xFlag_LinkageAtleast1;

		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRead THEN;
		ELSIF xFlag_Enable THEN(*2023.10.17.090009*)

			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home:= TRUE;
		END_IF
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_Home:= FALSE;

		IF g_iPrewrkSubPageId=1 THEN(*2023.10.16.161006@处于纵向预套准界面点击读取装版相位才显示*)
			xBtn_InitPhaseHmiDis:=TRUE;(*2023.10.16.161006|显示初始相位保存界面*)
		END_IF

	ELSIF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_ConfirmPreRegHomePos THEN(*保存装版位|*)
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_ConfirmPreRegHomePos:= TRUE;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_ConfirmPreRegHomePos_ing:= TRUE;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_ConfirmPreRegHomePos_end:= FALSE;

		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end THEN (*回原点完成*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];
				
				IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN
					(*2023.6.28.113335 更新*)
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPhase_InstallPlate:=KS_GetPhaseValue(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt,gc_iVirEncPPR);

				END_IF
			END_FOR

			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_ConfirmPreRegHomePos_end:= TRUE;
		END_IF

		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_ConfirmPreRegHomePos_ing:= FALSE;
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_ConfirmPreRegHomePos:= FALSE;

		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_ConfirmPreRegHomePos:= FALSE;
	ELSIF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_PreRegister THEN(*纵向预套准|*)
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRead THEN
			;
		ELSIF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping) AND
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end AND
			(i_xFlag_LinkageAtleast1 ) THEN(*2023.10.17.090009*)
			;
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister:= TRUE;
		END_IF
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_PreRegister:= FALSE;
	ELSIF g_xLoadRecipe_End THEN(*相位恢复|*)
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRead THEN
			;
		ELSIF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping) AND
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home_end AND
			(i_xFlag_LinkageAtleast1 ) THEN(*2023.10.17.090009*)
			;
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore:= TRUE;

		END_IF
		g_xLoadRecipe_End:= FALSE;
	ELSIF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_PhaseSave THEN(*相位保存|*)
		i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xBtn_PhaseSave:= FALSE;

		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			(*2021.9.18.113751 增加相位保存时候变量初始化*)
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPhase_RegisterOk:=0;
			IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN
				(*2023.6.28.113526 更新*)
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPhase_RegisterOk:=KS_GetPhaseValue(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt,gc_iVirEncPPR);

				(*非负保护|2021.10.25.154529*)
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPhase_RegisterOk < 0 THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPhase_RegisterOk:=0;
				END_IF
			END_IF
		END_FOR
		(*2018.11.5.132513|相位保存完成，直接进去配方写入流程*)
		g_xReqSaveRecipe:=TRUE; (*写入配方使能*)

(*2019.07.27.164458|niu.j|通用配方逻辑处理*)
	ELSIF g_xReqSaveCphRecipe THEN
		g_xReqSaveCphRecipe:=FALSE;
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_aiGrpAxisList[iN];
			
			(*2021.9.18.113751 增加相位保存时候变量初始化*)
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_RegisterOk:=0;
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed:=0;
			IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN
				(*2023.6.28.113822 更新*)
				i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_RegisterOk:=KS_GetPhaseValue(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt,gc_iVirEncPPR);

				i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_RegisterOk-i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate;

				WHILE i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed<0 DO
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed+gc_iVirEncPPR;
				END_WHILE

				WHILE i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed>=gc_iVirEncPPR DO (* 2021.7.1.104815/ *)
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_FinalUsed-gc_iVirEncPPR;
				END_WHILE
			END_IF
		END_FOR
		(*2018.11.5.132513|相位保存完成，直接进去配方写入流程*)

(*初始相位保存*)
	ELSIF g_xReqSaveCphCommonVir THEN
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore OR
			i_pxFlag_CphCommonVir^ THEN
			;
		ELSIF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping) AND
			(NOT i_pxFlag_CphCommonVir^) THEN
			;
			i_pxFlag_CphCommonVir^:= TRUE;
		END_IF
		IF NOT i_pxFlag_CphCommonVir_end^ THEN
			;
		ELSE
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				iUnitId:= i_aiGrpAxisList[iN];
		
				IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN
					(*2023.6.28.113642 更新*)
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].iPhase_InstallPlate:=KS_GetPhaseValue(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt,gc_iVirEncPPR);
				END_IF
			END_FOR
			g_xReqSaveCphCommonVir:= FALSE;
		END_IF

	ELSIF g_xLoadCphRecipe_End THEN
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister OR
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore THEN
			;
		ELSIF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop) AND
			(NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping) AND
			i_pxFlag_CphCommonVir_end^ THEN
			;
			i_pxCphaseRestore^:= TRUE;
		END_IF
		g_xLoadCphRecipe_End:= FALSE;
	END_IF

	o_iErrCode:= 0;
ELSE
	o_iErrCode:= -1;
END_IF