(*@CES
Name=Action_GetGroupInf
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=aba77a0e-38e7-4e42-934c-24d6a066da07
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
tmTestSa:= TIME();
iRtn_GetGroupInf:= GTN_RN_GetGroupInfo(
	1,
	0,
	ADR(uiGroupStationNum),
	ADR(adwInfo_Station[1]),
	128
	);
g_stStStationInfo_KS.iSid_Device:= 0;	
g_stStStationInfo_KS.iStationNum:= 0;
IF uiGroupStationNum>0 AND uiGroupStationNum<=128 THEN
	g_stStStationInfo_KS.iStationNum:= UINT_TO_INT(uiGroupStationNum);
	FOR iN:=1 TO UINT_TO_INT(uiGroupStationNum) BY 1 DO
		g_stStStationInfo_KS.awStation_Type[iN]:= DWORD_TO_WORD(adwInfo_Station[iN]);
		g_stStStationInfo_KS.aiStationId_List[iN]:= WORD_TO_INT(DWORD_TO_WORD(SHR(adwInfo_Station[iN],16)));
	END_FOR
END_IF

(*先放这里2025.11.11.093315后续需要在Fetchio里处理一下*)
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[1] := 1;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[2] := 2;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[3] := 3;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[4] := 4;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[5] := 5;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[6] := 6;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[7] := 7;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[8] := 8;
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[9] := 9;
//2025.11.13.111412 | + | 增加到十色
g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[10] := 10;
(*g_abyStationList_CommKSCR[1]:= 1;
g_abyStationList_CommKSCR[2]:= 2;
g_abyStationList_CommKSCR[3]:= 3;
g_abyStationList_CommKSCR[4]:= 4;
g_abyStationList_CommKSCR[5]:= 5;
g_abyStationList_CommKSCR[6]:= 6;
g_abyStationList_CommKSCR[7]:= 7;
g_abyStationList_CommKSCR[8]:= 8;
g_abyStationList_CommKSCR[9]:= 9;
//2025.11.13.111412 | + | 增加到十色
g_abyStationList_CommKSCR[10]:= 10;
*)
KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_INFO, 'GTN_RN_GetGroupInfo()!', INT_TO_STRING(iRtn_GetGroupInf));		

tmValue:= TIME()- tmTestSa;

	