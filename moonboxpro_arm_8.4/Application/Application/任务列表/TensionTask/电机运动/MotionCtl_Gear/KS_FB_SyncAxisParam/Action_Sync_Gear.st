(*@CES
Name=Action_Sync_Gear
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=dad2ac90-07c7-4d75-96bd-76c3d7e70d50
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO i_iGrpUnitNum_Pu BY 1 DO
	iUnitId:= i_aiGrpUnitList[iN];
	(*旋转方向设置*)
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.1;
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_[iUnitId].dwAxisProf.1;
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_BottomRoller:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.1;
	(*采样方向设置*)
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xSamRev_PrnRoller:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_[iUnitId].dwAxisProf.2;
//2026.1.5.220502 | +		
	(*采样方向设置*)
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xSamRev_BottomRoller:=
			i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_BR_[iUnitId].dwAxisProf.2;
	(*色组周长处理*)		
	IF NOT i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.0 THEN(*底辊周长设置*)
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_BottomRoller:= 
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_BottomRoller;	
	END_IF
	IF NOT i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.2 THEN(*网辊周长设置*)
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_NetRoller:= 
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_NetRoller;	
	END_IF
	IF NOT i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.3 THEN(*张带辊周长设置*)
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_StrRoller:= 
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_StrRoller;	
	END_IF	
	(*版辊周长处理-考虑涂布选项*)
	i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller:= 
			i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_PrnRoller;(*先做整体处理*)
	IF NOT i_pstStSysParam^.astStUnitParam_Save[iUnitId].xSwitchOn_CoatingPrn THEN(*涂布未打开*)
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].lrGirth_Using_CoatingPrn:= 
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_PrnRoller;
		g_alrGirth_CoatingPrn[iUnitId]:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller;
	ELSE
		IF g_alrGirth_CoatingPrn[iUnitId]<>0 THEN
			i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller:= 
					g_alrGirth_CoatingPrn[iUnitId];(*先做整体处理*)			
		END_IF
	END_IF
	(*减速比单独设置处理*)
	IF NOT i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.8 THEN(*底辊减速比设置*)
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_BottomRoller:=
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_BottomRoller;
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_BottomRoller:=
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_BottomRoller;			
	END_IF
	IF NOT i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.9 THEN(*版辊减速比设置*)
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller:=
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_PrnRoller;
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller:=
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_PrnRoller;			
	END_IF
	IF NOT i_pstStSysParam^.stStSysParam_Save.wCtlFlag_IndependentSettings.10 THEN(*版辊减速比设置*)
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller:=
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiNum_NetRoller;
		i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller:=
				i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiDen_NetRoller;			
	END_IF
	

	(*处理轴速度和使能*)
	(*色组版辊*)
	IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink (*AND g_xWashingPrn*)) OR (*版辊在空转或者印刷时是主机速度
			单运行或者预套准属于其他方式*)
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print THEN
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_PrnRoller:= 
				i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
	ELSIF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching OR g_axAxisInchDecing[iUnitId] THEN
		;
	ELSE
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_PrnRoller:= 0;
	END_IF
	xEnTemp:= FALSE;
	xEnTemp:= ((i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink (*AND g_xWashingPrn*)) OR 
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print OR
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home OR 
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister OR
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore) AND
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage AND
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMoveEnable_Motor;
	xEnTemp:= xEnTemp OR 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching OR 
					g_axAxisInchDecing[iUnitId];				
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_PrnRoller:= xEnTemp;
	
	
	(*色组底辊*)
	IF g_iMachineryType = MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN //机组式柔印、单伺服底辊
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink OR (*版辊在空转或者印刷时是主机速度
				单运行或者预套准属于其他方式*)
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print THEN
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller:= 
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
		ELSIF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching OR g_axAxisInchDecing[iUnitId] THEN
			;
		ELSE
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller:= 0;
		END_IF

		xEnTemp:= FALSE;
		xEnTemp:= (((i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink OR 
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home OR 
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister OR
						i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore) AND
						i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage)  OR 
						(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print )) (*AND
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMoveEnable_Motor*);
		xEnTemp:= xEnTemp OR 
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching OR 
						g_axAxisInchDecing[iUnitId];
		xEnTemp:= xEnTemp OR i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller;	 			
						
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_BottomRoller:= xEnTemp;	
	ELSE//其他机型
		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print THEN
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller:= 
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
		ELSE
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller:= 0;
		END_IF
		xEnTemp:= FALSE;
		xEnTemp:= (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print OR
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension) AND
						i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage AND
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMoveEnable_Motor;
		xEnTemp:= xEnTemp OR i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_BottomRoller;	 			
				
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_BottomRoller:= xEnTemp;
		
	END_IF
	
	(*色组网辊*)
	IF (*版辊在空转或者印刷时是主机速度
			单运行或者预套准属于其他方式*)
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print THEN
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_NetRoller:= 
				i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Cur;
	ELSIF  i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller THEN
		;
	ELSE
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_NetRoller:= 0;
	END_IF
	xEnTemp:= FALSE;
	xEnTemp:= ((i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Ink AND g_axInk_Unit[iUnitId]) OR 
					(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print  OR
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Tension)) AND
					i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage AND
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMoveEnable_Motor;			
	xEnTemp:= xEnTemp OR i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].xInching_NetRoller;	 			
	i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_NetRoller:= xEnTemp;
			
END_FOR
IF i_iGrpId=1 THEN
i_pstStSysParam^.astStGrpParam_UnSave[1].xMotRev_If:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[1].xMotRev_Of:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[1].xMotRev_CentralDrum:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[1].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[1].xMotRev_AxisA_Uw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[1].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[1].xMotRev_AxisB_Uw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[2].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[1].xMotRev_AxisA_Rw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[1].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[1].xMotRev_AxisB_Rw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[2].dwAxisProf.1;
END_IF
IF i_iGrpId=2 THEN
i_pstStSysParam^.astStGrpParam_UnSave[2].xMotRev_If:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[2].xMotRev_Of:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[2].xMotRev_CentralDrum:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[1].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[2].xMotRev_AxisA_Uw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[1].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[2].xMotRev_AxisB_Uw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[2].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[2].xMotRev_AxisA_Rw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[1].dwAxisProf.1;
i_pstStSysParam^.astStGrpParam_UnSave[2].xMotRev_AxisB_Rw:= i_pstStSysParam^.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[2].dwAxisProf.1;
END_IF
// 
// FOR iN:=1 TO i_byGrpGearMotion_Num BY 1 DO
// 	KS_HY_GetAxisIdForMotByStation(
// 		i_abyGrpGearMotion_StdList[iN],
// 		ADR(iAxisId),
// 		ADR(iTypeId),
// 		ADR(iUnitId),
// 		ADR(iCoreId),
// 		i_pastStAxisIdListInf);
// 		
// 	Action_Sync_Gear_Param();
// END_FOR
// astStTStGearParam;
// i_pastStMotorParam_Vel;