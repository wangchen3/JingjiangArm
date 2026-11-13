(*@CES
Name=Action_RdSampleData
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=9712102a-3aaf-4685-ba49-06f5bfb943ae
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

iUMax_Tmp:= g_stStSysParam.stStSysParam_Save.iUnitMaxNum;
iUid_Tmp:= g_stStSysParam.stStSysParam_Save.iUid;
IF iUid_Tmp>=2 AND iUid_Tmp<= iUMax_Tmp THEN
	IF NOT g_stStSysParam.astStUnitParam_Save[iUid_Tmp].xEnable_arc THEN
		xReDirectedCurrUnit:= TRUE;
	END_IF
ELSE
	xReDirectedCurrUnit:= TRUE;
END_IF

IF xReDirectedCurrUnit THEN(*需要重新定向|找第1个使能套色的色组|*)
	FOR iN:=2 TO iUMax_Tmp BY 1 DO
		IF g_stStSysParam.astStUnitParam_Save[iN].xEnable_arc THEN
			g_stStSysParam.stStSysParam_Save.iUid := iN;
			xReDirectedCurrUnit := FALSE;//2025.11.19.151125 | 重定向完成
			EXIT;
		END_IF
	END_FOR
END_IF
IF g_stStSysParam.stStSysParam_Save.iUid<> iLastId AND
		g_stStSysParam.stStSysParam_Save.iUid>=2 AND 
		g_stStSysParam.stStSysParam_Save.iUid<=g_stStSysParam.stStSysParam_Save.iUnitMaxNum THEN
	iLastId:= g_stStSysParam.stStSysParam_Save.iUid;
	iStationId:= g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[g_stStSysParam.stStSysParam_Save.iUid];
	IF iStationId<>-1 THEN
		aiRtnCode[1]:= GT_RN_SampleSetShowDeviceId(INT_TO_BYTE(iStationId));
		aiRtnCode[2]:= GT_RN_SampleRoundUpdata();
	END_IF		
END_IF
(*
byChannael-bit0:T2-R
		   bit1:T2-G
		   bit2:T2-B
		   bit4:T1-R
		   bit5:T1-G
		   bit6:T1-B
*)
aiRtnCode[3]:= GT_RN_SampleGetRoundDataEx(
					g_stStSysParam.astStUnitParam_Save[g_stStSysParam.stStSysParam_Save.iUid].bySignalSelect,
					ADR(g_pbyRoundData1), 
					ADR(g_pbyRoundData2), 
					ADR(iRoundSampleFlag));	

IF iRoundSampleFlag=1 THEN
	IF g_pbyRoundData2<>0 AND g_pbyRoundData1<>0 THEN
		IF g_stStSysParam.astStUnitParam_Save[g_stStSysParam.stStSysParam_Save.iUid].bySignalSelect.0 THEN
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T1_R), 
						g_pbyRoundData1,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T1_R));
		
		ELSIF g_stStSysParam.astStUnitParam_Save[g_stStSysParam.stStSysParam_Save.iUid].bySignalSelect.1 THEN
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T1_G), 
						g_pbyRoundData1,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T1_G));
			
		ELSIF g_stStSysParam.astStUnitParam_Save[g_stStSysParam.stStSysParam_Save.iUid].bySignalSelect.2 THEN
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T1_B), 
						g_pbyRoundData1,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T1_B));
		ELSE
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T1_R), 
						g_pbyRoundData1,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T1_R));					
		END_IF
		IF g_stStSysParam.astStUnitParam_Save[g_stStSysParam.stStSysParam_Save.iUid].bySignalSelect.4 THEN
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T2_R), 
						g_pbyRoundData2,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T2_R));
		ELSIF g_stStSysParam.astStUnitParam_Save[g_stStSysParam.stStSysParam_Save.iUid].bySignalSelect.5 THEN
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T2_G), 
						g_pbyRoundData2,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T2_G));
		ELSIF g_stStSysParam.astStUnitParam_Save[g_stStSysParam.stStSysParam_Save.iUid].bySignalSelect.6 THEN
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T2_B), 
						g_pbyRoundData2,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T2_B));
		ELSE
			SysMemCpy(ADR(g_stStSysParam.stStSysParam_UnSave.abyData_T2_R), 
						g_pbyRoundData2,
						SIZEOF(g_stStSysParam.stStSysParam_UnSave.abyData_T2_R));			
		END_IF	
		(*2026.5.9.144620*)
		(*2026.03.23.171805||保存采样wang.xy*)
		IF g_stStSysParam.stStSysParam_Save.iUid>=2 AND 
			g_stStSysParam.stStSysParam_Save.iUid<=g_stStSysParam.stStSysParam_Save.iUnitMaxNum THEN
			KS_PshRSdata2Fifo(
				g_pstStRSampFifo,
				g_pbyRoundData1,
				g_pbyRoundData2,
				INT_TO_BYTE(g_stStSysParam.stStSysParam_Save.iUid),
				LREAL_TO_DINT(g_stStSysParam.astStUnitParam_UnSave[g_stStSysParam.stStSysParam_Save.iUid].rAxisVel_PrnRoller*100.0),
				g_astStTaskCycleDetection[1].udiCycleCnt);	
		END_IF
		
	END_IF
	aiRtnCode[4]:= GT_RN_SampleRoundUpdata();(* 启动下一次采样 *)
ELSE
		(*2026.03.23.162723||粗采样保存wang.xy*)
	fbKS_FB_ExportRSFifo2File(
//		i_xEn:= g_xSaveRS2file,2026.5.14.091655更新屏蔽
		i_xEn:= g_stStSysParam.astStRSV_GrpParam_UnSave[1].xSwitch_SaveRS2file,
		i_sPath:= ,
		i_pstStRSampFifo:= g_pstStRSampFifo,
		o_iErNo=> iRtn);
END_IF