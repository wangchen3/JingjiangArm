(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=56b8238a-f12c-4ff6-96c1-542522f120e9
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}



FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	axLinkage[iN]:= g_stStSysParam.astStUnitParam_Save[iN].xLinkage;
	axEnable_Arc[iN]:= g_stStSysParam.astStUnitParam_Save[iN].xEnable_arc;

END_FOR
FOR iGrp:=1 TO 2 BY 1 DO(*循环2个系处理一下*)
	IF iGrp=2 THEN
		EXIT;
	END_IF
		afbKS_FB_GrpFetchIOCtrl[iGrp](
			i_xEn:= TRUE, 
			i_iGrpId:= iGrp, 
			i_pstStEvtReq:= ADR(g_astStEvtReq[iGrp]), 
			i_pstStSysCfgStruct:=ADR(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct),
			i_pastStIOMap_Main_FE:= ADR(g_astStIOMap_Main_FE), 
			i_pastStIOMap_Axis_FE:= ADR(g_astStIOMap_Axis_FE), 
			i_pastStIOMap_Axis_Extra_FE:= ADR(g_astStIOMap_Axis_Extra_FE), 
			i_pastStIOMap_UwRw_FE_Uw:= ADR(g_astStIOMap_UwRw_FE_Uw), 
			i_pastStIOMap_UwRw_FE_Rw:= ADR(g_astStIOMap_UwRw_FE_Rw), 
			i_iUMax:= g_stStSysParam.stStSysParam_Save.iUnitMaxNum, 
			i_dwEquipmentProf:= g_stStSysParam.stStSysParam_Save.dwEquipmentProf, 
			i_xUseRealStationOnRingnet:= TRUE, 

			i_axLinkage:= axLinkage, 
			i_axThisUnitEna:= axEnable_Arc, 
			i_axSwitchOn_CoatingPrn:= , 
			i_xIsValid_If_I:= g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0, 
			i_xIsValid_If_II:= g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.dwAxisProf.0, 
			i_xIsValid_Of_I:= g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.dwAxisProf.0, 
			i_xIsValid_Of_II:= g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.dwAxisProf.0, 
//			i_pstStRingInfVer1:= ADR(g_stStRingInfVer1), (* 所有站点列表 *)
			//i_pstStStationInfo_KS:= ADR(g_stStStationInfo_KS),
			i_pstStSysStationInf:=ADR(g_stStSysStationInf),

			i_pxInit_StationList:= ADR(g_xInit_StationList),

			o_xEn=> , 
			o_iErNo=> , 
			o_iGrpAxisNum_Pu=> iGrpAxisNum_Pu, 
			o_iGrpAxisTotalNum=> , 
			o_aiGrpAxisList=> aiGrpAxisList, 
			o_iIOGrpIdx_Uw=> aiIOGrpIdx_Uw[iGrp], 
			o_iIOGrpIdx_Rw=> aiIOGrpIdx_Rw[iGrp], 
			o_iAxisId_If_IOMapUse=> aiIOGrpIdx_If[iGrp], 
			o_iAxisId_Of_IOMapUse=> aiIOGrpIdx_Of[iGrp], 
			o_aiGrpServoAxisList_Uw=> , 
			o_aiGrpServoAxisList_Rw=> , 
			o_iGrpLinkageAxisNum_Pu=> iGrpLinkageAxisNum_Pu, 
			o_aiGrpLinkageAxisList=> aiGrpLinkageAxisList, 
			o_iGrpArcAxisNum_Pu=> iGrpArcAxisNum_Pu, 
			o_aiGrpArcAxisList=> aiGrpArcAxisList, 
			o_aiGrpArcIdList=> aiGrpArcIdList, 
			o_aiGrpFollowArcIdList=> aiGrpFollowArcIdList, 
			
			o_iAxisNum_Trap=>g_iAxisNum_Trap,//: INT;(*点位运动轴数量*)
			o_aiStationList_Trap=>g_aiStationList_Trap,//(*点位运动轴列表*)
			o_iAxisNum_Gear=>g_iAxisNum_Gear,//: INT;(*电子齿轮运动轴数量*)
			o_aiStationList_Gear=>g_aiStationList_Gear,//(*电子齿轮运动轴列表*)
			o_iAxisNum_GantrayTrap=>g_iAxisNum_GantrayTrap,//: INT;(*龙门点位运动组数量*)
			o_aiStationList_GantrayTrap=>g_aiStationList_GantrayTrap,//(*龙门点位运动轴列表*)
			o_iAxisNum_Jog=>g_iAxisNum_Jog,//: INT;(*龙门点位运动组数量*)
			o_aiStationList_Jog=>g_aiStationList_Jog,//(*龙门点位运动轴列表*)		
			o_iAxisNum_All=>g_iAxisNum_All,//: INT;
			o_aiStationList_All=>g_aiStationList_All, 
			o_aiIndexList_All_Trap=>g_aiIndexList_All_Trap,//(*点位运动轴列表*)
			o_aiIndexList_All_Gear=>g_aiIndexList_All_Gear,//(*电子齿轮运动轴列表*)
			o_aiIndexList_All_Gantray=>g_aiIndexList_All_Gantray,//(*龙门点位运动轴列表*)	
			o_aiIndexList_All_Jog=>g_aiIndexList_All_Jog,//(*龙门点位运动轴列表*)
			o_axFlag_SlaveUseCmm_Pro=> axFlag_SlaveUseCmm_Pro,
//2026.5.9.145734
			//2026.04.10.145756 增加系急停状态
			o_dwAxisFlags_Estop=>g_stStSysParam.astStRSV_GrpParam_UnSave[iGrp].dwAxisFlags_Estop,
			
			io_abyColorIdCurrent:= abyColorIdCurrent, 
			io_abyFollowColorId:= abyFollowColorId);
			
	FOR iN:=1 TO iGrpAxisNum_Pu BY 1 DO	
		IF aiGrpAxisList[iN]>0 AND aiGrpAxisList[iN]<=MAX_UNIT_NUM THEN
			g_stStSysParam.astStUnitParam_UnSave[aiGrpAxisList[iN]].byColorIdCurrent:= abyColorIdCurrent[aiGrpAxisList[iN]];
			abyFollowColorId[aiGrpAxisList[iN]]:=g_stStSysParam.astStUnitParam_Save[aiGrpAxisList[iN]].byFollowColorId;
		END_IF
		
	END_FOR
	//2026.04.11.200539|2026.5.9.151126
	g_aiGrpLinkageAxisNum_Pu[iGrp]:= iGrpLinkageAxisNum_Pu;
	FOR iN:= 1 TO iGrpLinkageAxisNum_Pu BY 1 DO
		g_aiGrpLinkageAxisList[iGrp,iN]:= aiGrpLinkageAxisList[iN];
	END_FOR	
	(*g_aiGrpUnitNum: ARRAY [1..2] OF INT;
	g_aiGrpAxisList_A:  (*系的轴列表*)*)
	g_aiGrpUnitNum[iGrp]:= iGrpAxisNum_Pu;
	g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu:= INT_TO_BYTE(iGrpAxisNum_Pu);
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		g_aiGrpAxisList[iGrp,iN]:= aiGrpAxisList[iN];
		g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpAxisList[iN]:= INT_TO_BYTE(aiGrpAxisList[iN]);
		//2026.1.24.220551||增加从站通讯使用PRO/月光宝盒2026.1.24.220647|niu.j
		g_stStSysParam.astStUnitParam_Save[iN].dwFlag_Ctl.28:= axFlag_SlaveUseCmm_Pro[iN];
	END_FOR
	
	(*将系中套色轴个数以及套色轴列表同步到系参数中|2023.09.14.102102*)
	g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpArcAxisNum:=0;
	IF iGrpArcAxisNum_Pu>=0 AND  iGrpArcAxisNum_Pu<=255 THEN
		g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpArcAxisNum:=INT_TO_BYTE(iGrpArcAxisNum_Pu);
	END_IF
	FOR in:=1 TO MAX_UNIT_NUM BY 1 DO
		g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpArcAxisList[iN]:=0;
		IF aiGrpArcAxisList[iN]>=0 AND aiGrpArcAxisList[iN]<=255 THEN
			g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpArcAxisList[iN]:=INT_TO_BYTE(aiGrpArcAxisList[iN]);
		END_IF

		(*2024.02.22.084119+*)
		g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpArcIdList[iN]:=0;
		IF aiGrpArcIdList[iN]>=0 AND aiGrpArcIdList[iN]<=255 THEN
			g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpArcIdList[iN]:=INT_TO_BYTE(aiGrpArcIdList[iN]);
		END_IF

		(*2024.02.22.084119+*)
		g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpFollowArcIdList[iN]:=0;
		IF aiGrpFollowArcIdList[iN]>=0 AND aiGrpFollowArcIdList[iN]<=255 THEN
			g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpFollowArcIdList[iN]:=INT_TO_BYTE(aiGrpFollowArcIdList[iN]);
		END_IF
	END_FOR
//2026.5.8.125720新增波形美化赋值
	FOR iN:=1 TO iGrpAxisNum_Pu BY 1 DO
		g_stStSysParam.astStRSV_UnitParam_Save[aiGrpAxisList[iN]].xRsMorphFilter:= 
				g_stStSysParam.astStRSV_GrpParam_Save[iGrp].xRsMorphFilter;
	END_FOR		
END_FOR
(*得先获取一下当前速度*)

IF xOne_time_count THEN
	xOne_time_count:=FALSE;(*确保只执行一次*)
	iDriverCnt_Core1 := 0;
	iDriverCnt_Core2 := 0;
	pstStSysStationInf:=ADR(g_stStSysStationInf);
	FOR iN := 1 TO g_iAxisNum_All BY 1 DO
		KS_GetAxisIdForMotByStation_V2(
			i_iStationId:= g_aiStationList_All[iN],
			i_piAxisId:= ADR(iAxisId), 
			i_piTypeId:= ADR(iTypeId), 
			i_piUnitId:= ADR(iUnitId), 
			i_piCoreId:= ADR(iCoreId), 
			i_piGroupId:= ADR(iGroupId), 
			i_piAdjAxisId:= ADR(iAdjAxisId), 
			i_pstStSysStationInf:= pstStSysStationInf);
		stTServoParamReader.objectIndex := 16#2008;
		stTServoParamReader.subIndex := 16#0;
		stTServoParamReader.reserve := 0;
		stTServoParamReader.memType := 0;
		stTServoParamReader.byteSize := 2;
		IF iCoreId = 1 THEN
			iDriverCnt_Core1 := iDriverCnt_Core1 + 1;
			iDriverId := iDriverCnt_Core1;
		ELSIF iCoreId = 2 THEN
			iDriverCnt_Core2 := iDriverCnt_Core2 + 1;
			iDriverId := iDriverCnt_Core2;
		END_IF
		iRtn := GTN_ReadServoParamInfo(core:= iCoreId, axis:= iDriverId, pTServoParamReader:= ADR(stTServoParamReader), pData:= ADR(ausiTemp));
		wLowByte := USINT_TO_WORD(ausiTemp[1]);  
		wHighByte := USINT_TO_WORD(ausiTemp[2]); 
		awTqCoeff[(iCoreId-1)* gc_ResCount_Profile +iAxisId]:=SHL(wHighByte, 8) OR (wLowByte);
		g_arTqCOeff[(iCoreId-1)* gc_ResCount_Profile +iAxisId]:=UINT_TO_REAL(WORD_TO_UINT(awTqCoeff[(iCoreId-1)* gc_ResCount_Profile +iAxisId]))/493;
	END_FOR
END_IF

