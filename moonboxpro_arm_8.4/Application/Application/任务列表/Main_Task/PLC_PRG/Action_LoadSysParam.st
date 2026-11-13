(*@CES
Name=Action_LoadSysParam
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=8746dbbe-52c8-402a-ae1c-b2fa975f442a
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
FOR iN:=1 TO 2 BY 1 DO
	IF iN=1 THEN
		sFileName_Param:= FNAME_SYS_PARAM_A;
	ELSE
		sFileName_Param:= FNAME_SYS_PARAM_B;				
	END_IF

	iRtn:=
	KS_HY_FileProc(
		i_iFileTyp_cfg0_para1:= 1, 
		i_xFileOpt_falseR_trueW:= FALSE, (* 读 *)
		i_pstStSysCfgStruct:= 0, 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_dwDlen:= ADR(g_stStSysParam.stStSysParam_UnSave)-ADR(g_stStSysParam),
		i_dwMemSnapshot:= g_dwMem1MB, 
		i_sFileName:= sFileName_Param, 
		i_xEnableWriteFile2:= FALSE, 
		i_sFileName_2:= '', 
		i_pdiErrCodeEx:= ADR(g_diErrCode_FileProc));
	IF iRtn=0 THEN
		KS_RstSysParam(ADR(g_stStSysParam), iRtn<>0);(* 2023.8.3.094715/han.dp/读取失败就要全部恢复/成功则只恢复标志即可 *)
		KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, CONCAT('KS_HY_FileProc() RPRM succeed!', INT_TO_STRING(iRtn)), DINT_TO_STRING(g_diErrCode_FileProc));(*2026.03.19.173443/han.dp/增加g_diErrCode_FileProc保存*)
		//2026.03.24.192744 | + | 增加判断A参数是不是全0,部分参数判断是不是0，如果是0就读下一个参数，要是都是0那就没办法，恢复默认
		IF g_stStSysParam.stStSysParam_Save.iTitleTextHeight = 0 OR g_stStSysParam.stStSysParam_Save.iEntryTextHeight = 0 OR g_stStSysParam.stStSysParam_Save.iLabelTextHeight = 0 THEN
			KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM,'FNAME_SYS_PARAM_A Err!', DINT_TO_STRING(g_diErrCode_FileProc));
			IF iN = 2 THEN
				IF KS_RstSysParam(ADR(g_stStSysParam), TRUE)=1 THEN;(* 2023.8.3.094715/han.dp/读取失败就要全部恢复/成功则只恢复标志即可 *)
					KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM,'RstSysParam!', DINT_TO_STRING(g_diErrCode_FileProc));
					g_iRunStepId:= RUNSTEP_LoadCfg_Motor;//RUNSTEP_NormalWork;(* 再去加载系统配置文件 *)
				END_IF
			END_IF	
		ELSE
			g_iRunStepId:= RUNSTEP_LoadCfg_Motor;//RUNSTEP_NormalWork;(* 再去加载系统配置文件 *)
			EXIT;
		END_IF
// 		g_iRunStepId:= RUNSTEP_LoadCfg_Motor;//RUNSTEP_NormalWork;(* 再去加载系统配置文件 *)
// 		EXIT;

	ELSE
		//KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'KS_HY_FileProc() failed!', INT_TO_STRING(iRtn));	
		KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, CONCAT('KS_HY_FileProc() RPRM failed!', INT_TO_STRING(iRtn)), DINT_TO_STRING(g_diErrCode_FileProc));(*2026.03.19.173443/han.dp/增加g_diErrCode_FileProc保存*)
	
		IF KS_RstSysParam(ADR(g_stStSysParam), iRtn<>0)=1 THEN;(* 2023.8.3.094715/han.dp/读取失败就要全部恢复/成功则只恢复标志即可 *)
			g_iRunStepId:= RUNSTEP_LoadCfg_Motor;//RUNSTEP_NormalWork;(* 再去加载系统配置文件 *)
		END_IF
	END_IF
	
	
END_FOR