(*@CES
Name=Action_DispatchInfProcess
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=637606d4-6997-4c2d-a65c-1af566130149
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*处理下发arm信息需要通讯的信息*)
FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
	iAxisId := i_paiGrpAxisList^[iN];
	pstStRSV_GrpParam_Save:=ADR(i_pstStsysParam^.astStRSV_GrpParam_Save[i_iGrpId]);//
	pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);//
	pstStUnitParam_Save:= ADR(i_pstStsysParam^.astStUnitParam_Save[iAxisId]);//
	pstStUnitParam_UnSave:=ADR(i_pstStsysParam^.astStUnitParam_UnSave[iAxisId]);//
	pstStRSV_UnitParam_UnSave:=ADR(i_pstStsysParam^.astStRSV_UnitParam_UnSave[iAxisId]);//
	//参数信息
	pstStRSV_UnitParam_UnSave^.byWidth_Mark_Max:=  REAL_TO_BYTE(pstStRSV_GrpParam_Save^.rWidth_Mark_Max*10);
	pstStRSV_UnitParam_UnSave^.byWidth_Mark_Min:= REAL_TO_BYTE(pstStRSV_GrpParam_Save^.rWidth_Mark_Min*10);
	pstStRSV_UnitParam_UnSave^.byMaxGap:= REAL_TO_BYTE(pstStRSV_GrpParam_Save^.rMaxGap*10);
	pstStRSV_UnitParam_UnSave^.bySimilarityThreshold:= pstStRSV_GrpParam_Save^.bySimilarityThreshold;
	pstStRSV_UnitParam_UnSave^.xSpecialMarkEn:= pstStRSV_GrpParam_Save^.xSpecialMarkEn;
	pstStRSV_UnitParam_UnSave^.byMeanOffset:= pstStRSV_GrpParam_Save^.byMeanOffset;
	pstStRSV_UnitParam_UnSave^.byOuterCoff:=  REAL_TO_BYTE(pstStRSV_GrpParam_Save^.rOuterCoff*10);
	pstStRSV_UnitParam_UnSave^.byInnerCoff:=  REAL_TO_BYTE(pstStRSV_GrpParam_Save^.rInnerCoff*10);
	pstStRSV_UnitParam_UnSave^.bySpotWidth:=  REAL_TO_BYTE(pstStRSV_GrpParam_Save^.rSpotWidth*10);
	//初始化模版信息
	KS_CreateTemplate(
		i_bySignalType := pstStRSV_GrpParam_Save^.bySignalType,(*模版类型，1 北人标，2普通标 ，3科赛引导条标*)
		i_iMarkTypeId :=pstStGrpParam_Save^.iMarkTypeId,(*色标形式pstStGrpParam_Save^.iMarkTypeId*)
		i_iMarkArrangeMode := pstStGrpParam_Save^.iMarkArrangeMode,
		i_byColorIdCurrent :=pstStUnitParam_UnSave^.byColorIdCurrent,(*当前轴色序*)
		i_rGirth_PrnRoller :=pstStUnitParam_Save^.rGirth_PrnRoller ,(*版周*)
		//模版构建方法 要求条标直接输入起点mm与终点mm，三角标，先确定直角边的位置，斜边按照三角标高度的一半推
		ADR(aiModeMidPoint[iAxisId,1]),
		ADR(abyModeRadius[iAxisId,1]),
		ADR(arModeStartmm[iAxisId,1]),
		ADR(arModeEndmm[iAxisId,1]),
		i_parSignalMsg:= ADR(pstStRSV_GrpParam_Save^.arModeMsg[1])
	);
END_FOR

FOR iN := 1 TO i_iGrpAxisNum_Pu BY 1 DO
	iAxisId := i_paiGrpAxisList^[iN];
	pstStRSV_UnitParam_UnSave := ADR(i_pstStsysParam^.astStRSV_UnitParam_UnSave[iAxisId]);
	//全自动套印下发模版
	FOR  iM:= 1 TO 4 BY 1 DO
		pstStRSV_UnitParam_UnSave^.aiCurModeMidPoint[iM]:=aiModeMidPoint[iAxisId,iM];
		pstStRSV_UnitParam_UnSave^.abyCurModeRadius[iM]:=abyModeRadius[iAxisId,iM];
		IF aiAxisId_Before[iAxisId] <> -1 THEN
			pstStRSV_UnitParam_UnSave^.aiPreModeMidPoint[iM]:=aiModeMidPoint[aiAxisId_Before[iAxisId],iM];
			pstStRSV_UnitParam_UnSave^.abyPreModeRadius[iM]:=abyModeRadius[aiAxisId_Before[iAxisId],iM];
		END_IF
	END_FOR	
END_FOR				