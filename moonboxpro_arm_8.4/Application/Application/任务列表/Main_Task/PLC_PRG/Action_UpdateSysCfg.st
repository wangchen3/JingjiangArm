(*@CES
Name=Action_UpdateSysCfg
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=12b6ce14-531f-4463-953f-4be5abea9b1c
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//iRtn:= KS_WrSysCfgFile(FNAME_SYS_CFGDETAILS, ADR(g_stStSysCfgStruct));
iRtn_WrCfg:=
KS_HY_FileProc(
	i_iFileTyp_cfg0_para1:= 0, 
	i_xFileOpt_falseR_trueW:= TRUE, (* 读 *)
	i_pstStSysCfgStruct:= ADR(g_stStSysCfgStruct), 
	i_pstStSysParam:= 0, 
	i_dwDlen:= SIZEOF(g_stStSysCfgStruct), 
	i_dwMemSnapshot:= g_dwMem1MB, 
	i_sFileName:= FNAME_SYS_CONF, 
	i_xEnableWriteFile2:= FALSE, 
	i_sFileName_2:= '', 
	i_pdiErrCodeEx:= ADR(g_diErrCode_FileProc));
IF (*iRtn*)iRtn_WrCfg=0 THEN
	g_iRunStepId:= RUNSTEP_LoadSysCfg;(* 写文件没错就重新读1遍吧 *)
ELSE
	KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'KS_WrSysCfgFile() failed!', INT_TO_STRING(iRtn_WrCfg));		
END_IF
