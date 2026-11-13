(*@CES
Name=PRG_LOG
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6bb64d52-3e54-4942-b6a7-cf17d1606afc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
PROGRAM PRG_LOG
VAR
	udiRtn: UDINT;
	xEnableWriteFile2: BOOL := FALSE;
	iRtn : INT;
END_VAR

{IMPLEMENTATION}
IF g_iRunStepId<>RUNSTEP_NormalWork THEN RETURN; END_IF

(*
/ 尝试新的保存参数方式||niu.j
/ 每次写文件都是操作A文件，写文件前把当前的B文件删除|A文件改名为B文件|
/ 如果未检测到B文件，就A|B文件各写一次
*)	
(* 2025.8.21.182654/han.dp *)
xEnableWriteFile2:= TRUE;(* 默认写第2个文件 *)
udiRtn:= SysFileDelete(FNAME_SYS_PARAM_B);(* 删除_B文件 *)
IF udiRtn=0 THEN(* 删除_B文件成功 *)
	udiRtn:= SysFileRename(FNAME_SYS_PARAM_A, FNAME_SYS_PARAM_B);(* 更名_A为_B *)
	IF udiRtn=0 THEN(* 更名_A为_B成功 *)
		xEnableWriteFile2:= FALSE;(* 只用写_A即可/不操作_B文件 *)
	END_IF
END_IF
iRtn := KS_HY_FileProc(
	i_iFileTyp_cfg0_para1:= 1, (* 参数文件 *)
	i_xFileOpt_falseR_trueW:= TRUE, (* 写 *)
	i_pstStSysCfgStruct:= 0, 
	i_pstStSysParam:= ADR(g_stStSysParam), 
	i_dwDlen:= ADR(g_stStSysParam.stStSysParam_UnSave)-ADR(g_stStSysParam),
	i_dwMemSnapshot:= g_dwMem1MB, 
	i_sFileName:= FNAME_SYS_PARAM_A, 
	i_xEnableWriteFile2:= xEnableWriteFile2, 
	i_sFileName_2:= FNAME_SYS_PARAM_B, 
	i_pdiErrCodeEx:= ADR(g_diErrCode_FileProc));	
//2026.03.23.113559 | + |	
IF iRtn=0 THEN
	;//KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'KS_HY_FileProc() succeed!', INT_TO_STRING(iRtn));
ELSE
	KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, CONCAT('KS_HY_FileProc() failed!', INT_TO_STRING(iRtn)), DINT_TO_STRING(g_diErrCode_FileProc));(*2026.03.19.173443/han.dp/增加g_diErrCode_FileProc保存*)		
	//iErrCnt := iErrCnt + 1;
END_IF

IF g_xFlag_LogTaskRun THEN g_xFlag_LogTaskRun:= FALSE; END_IF
