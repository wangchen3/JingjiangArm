(*@CES
Name=Action_LoadSysCfg
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=edc97201-e859-48f6-958e-a40c6aed1800
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//加载系统配置
(* deprecated@2025.8.27.161510/han.dp
iRtn_RdCfg:= KS_RdSysCfgFile(FNAME_SYS_CFGDETAILS, ADR(g_stStSysCfgStruct));
*)
g_xError_SysCfg:= FALSE;
iRtn_RdCfg:=
KS_HY_FileProc(
	i_iFileTyp_cfg0_para1:= 0, 
	i_xFileOpt_falseR_trueW:= FALSE, (* 读 *)
	i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct), 
	i_pstStSysParam:= 0, 
	i_dwDlen:= SIZEOF(g_stStSysCfgStruct), 
	i_dwMemSnapshot:= g_dwMem1MB, 
	i_sFileName:= FNAME_SYS_CONF, 
	i_xEnableWriteFile2:= FALSE, 
	i_sFileName_2:= '', 
	i_pdiErrCodeEx:= ADR(g_diErrCode_FileProc));

IF iRtn_RdCfg<>0 THEN

	//2026.03.23.113559 | + |	
	IF iRtn_RdCfg=0 THEN
		;//KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'KS_HY_FileProc() succeed!', INT_TO_STRING(iRtn));
	ELSE
		KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, CONCAT('KS_HY_FileProc() failed!', INT_TO_STRING(iRtn)), DINT_TO_STRING(g_diErrCode_FileProc));(*2026.03.19.173443/han.dp/增加g_diErrCode_FileProc保存*)		
		//iErrCnt := iErrCnt + 1;
		g_xError_SysCfg:= TRUE;
	END_IF
ELSE
	//g_stStSysCfgStruct.iCompanyId:= 2064;
	SysMemCpy(
		ADR(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct),
		ADR(g_stStSysCfgStruct),
		SIZEOF(g_stStSysCfgStruct));
		
	g_stStSysParam.stStSysParam_Save.iUnitMaxNum := g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.byUnitMaxNum;
	g_stStSysParam.stStSysParam_Save.iCustomerId:= g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.iCompanyId;
	(* ___test/2023.08.30.203627/han.dp *)

END_IF

//2025.12.23.141157 | 拓扑
//判断离线

g_xUnLine_SysStation:= FALSE;
//系统配置的每个站都应该判断是否在线
//根据系统配置开关和配置站号站点判断
//A系放牵	
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_IF:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_I.iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_IF:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF 
//B系放牵	
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_IF:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_IF_II.iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_IF:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF 	
//A系收牵	
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_OF:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_I.iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_OF:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF 
//B系收牵	
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_OF:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.stStAxisCfgStruct_OF_II.iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_OF:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF
//A系放料A
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_UW_A:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[1].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[1].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[1].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[1].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_UW_A:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//A系放料B
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_UW_B:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[2].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[2].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[2].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_I[2].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_UW_B:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//B系放料A
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_UW_A:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[1].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[1].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[1].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[1].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_UW_A:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//B系放料B
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_UW_B:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[2].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[2].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[2].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_UW_II[2].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_UW_B:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//A系收料A
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_RW_A:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[1].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[1].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[1].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[1].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_RW_A:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//A系收料B
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_RW_B:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[2].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[2].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[2].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_I[2].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_RW_B:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//B系收料A
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_RW_A:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[1].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[1].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[1].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[1].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_RW_A:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//B系收料B
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_RW_B:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[2].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[2].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[2].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_RW_II[2].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_RW_B:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF
END_IF	
//A系中心辊1
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_CENTRAL:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[1].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[1].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[1].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[1].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_CENTRAL:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF		
END_IF
//A系中心辊2
g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_CENTRAL2:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[2].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[2].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[2].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_I[2].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[1].xNetOffline_CENTRAL2:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF		
END_IF	
//B系中心辊1
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_CENTRAL:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[1].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[1].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[1].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[1].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_CENTRAL:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF		
END_IF
//B系中心辊2
g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_CENTRAL2:= FALSE;
IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[2].dwAxisProf.0 AND
	g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[2].iSid>0 THEN
	IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[2].iSid,ADR(g_stStStationInfo_KS))=1 THEN
		;//正常在线
	ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_CD_II[2].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
		g_stStSysParam.astStGrpParam_UnSave[2].xNetOffline_CENTRAL2:= TRUE;
		g_xUnLine_SysStation:= TRUE;
	END_IF		
END_IF	
FOR iN:= 1 TO g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.byUnitMaxNum BY 1 DO
//色组版辊
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_PrnRoller:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_PrnRoller:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF	
//色组底辊		
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_BottomRoller:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_BR_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_BR_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_BR_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_BR_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_BottomRoller:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF	
//色组网辊		
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_NetRoller:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_NetRoller:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF	
//色组版辊压力M		
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Prn_Pressure_M:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_M_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_M_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_M_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_M_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Prn_Pressure_M:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF	
//色组版辊压力G		
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Prn_Pressure_G:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_G_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_G_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_G_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_PR_G_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Prn_Pressure_G:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF	
//色组网辊压力M		
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Net_Pressure_M:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_M_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_M_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_M_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_M_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Net_Pressure_M:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF	
//色组网辊压力G		
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Net_Pressure_G:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_G_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_G_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_G_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_NR_G_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Net_Pressure_G:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF
//色组横向
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Horz:= FALSE;
	IF g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_HORIZ_[iN].dwAxisProf.0 AND
		g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_HORIZ_[iN].iSid>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_HORIZ_[iN].iSid,ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.stStSysCfgStruct.astStAxisCfgStruct_HORIZ_[iN].iSid,ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Horz:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF		
	END_IF	
//色组控制器||先这样，需要加到系统配置里
	g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Ctl:=FALSE;
	IF 	g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN]>0 THEN
		IF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN],ADR(g_stStStationInfo_KS))=1 THEN
			;//正常在线
		ELSIF KS_StationOnLine(g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN],ADR(g_stStStationInfo_KS))=-2 THEN
			g_stStSysParam.astStUnitParam_UnSave[iN].xNetOffline_Ctl:= TRUE;
			g_xUnLine_SysStation:= TRUE;
		END_IF	
	END_IF			
END_FOR


KS_CreatMap(
	TRUE,(*创建使能@事件触发*)
	TRUE,(*使用实际站创建*)
	MACHINERYTYPE_FELXO_INLINE,(*机器类型*)
	INT_TO_BYTE(g_stStStationInfo_KS.iStationNum),
	ADR(g_stStStationInfo_KS),//	ADR(g_stStStationInfo_KS.aiStationId_List),
	ADR(g_stStSysStationInf));
KS_CreatGantryAxisInf(i_pstStSysStationInf:= ADR(g_stStSysStationInf), i_pstStSysGantryAxisInf:= ADR(g_stStSysGantryAxisInf));

IF g_iMachineryType = MACHINERYTYPE_FELXO_INLINE THEN
	FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
		g_stStSysParam.astStUnitParam_Save[iN].iStationId := iN + MAX_UNIT_NUM;
	END_FOR
ELSIF g_iMachineryType = MACHINERYTYPE_FELXO_INLINE_ONEBOTOMROLLER THEN
	FOR iN := 1 TO MAX_UNIT_NUM BY 1 DO
		g_stStSysParam.astStUnitParam_Save[iN].iStationId := iN + 3*MAX_UNIT_NUM;
	END_FOR
END_IF

//g_iRunStepId:= RUNSTEP_NormalWork;(* 成功与否/最后都会进入到这一步 *)
//2026.5.12.201747增加初始化异站逻辑
g_iRunStepId := RUNSTEP_RESERVED;
//g_iRunStepId:= RUNSTEP_NormalWork;(* 成功与否/最后都会进入到这一步 *)

