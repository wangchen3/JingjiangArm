(*@CES
Name=Action_LoadConfig_Motor
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=d5355eaf-d8c7-4497-bb30-3b9def60d749
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
SysMemSet(ADR(g_stStGetPrm),0,SIZEOF(g_stStGetPrm));
SysMemSet(ADR(aiRtn),0,SIZEOF(aiRtn));

aiRtn[1]:= GTN_RESET(iCoreId_1);
aiRtn[2]:= GTN_RESET(iCoreId_2);
aiRtn[3]:= GTN_LoadConfig(core:= iCoreId_1, pFile:= ADR(PATH_CONFIG_CORE1));
aiRtn[4]:= GTN_LoadConfig(core:= iCoreId_2, pFile:= ADR(PATH_CONFIG_CORE2));

// aiRtn[5]:= GTN_LoadReadCommandVarTable(iCoreId_1,1,ADR(PATH_WATCHFILE_1));
// aiRtn[6]:= GTN_LoadReadCommandVarTable(iCoreId_1,2,ADR(PATH_WATCHFILE_2));
// aiRtn[7]:= GTN_LoadReadCommandVarTable(iCoreId_1,3,ADR(PATH_WATCHFILE_3));
// aiRtn[8]:= GTN_LoadReadCommandVarTable(iCoreId_1,4,ADR(PATH_WATCHFILE_4));
// aiRtn[9]:= GTN_LoadReadCommandVarTable(iCoreId_1,5,ADR(PATH_WATCHFILE_5));
// 
// aiRtn[9]:= GTN_LoadReadCommandVarTable(iCoreId_2,1,ADR(PATH_WATCHFILE_1));
// aiRtn[10]:= GTN_LoadReadCommandVarTable(iCoreId_2,2,ADR(PATH_WATCHFILE_2));
// aiRtn[11]:= GTN_LoadReadCommandVarTable(iCoreId_2,3,ADR(PATH_WATCHFILE_3));
// aiRtn[12]:= GTN_LoadReadCommandVarTable(iCoreId_2,4,ADR(PATH_WATCHFILE_4));
// aiRtn[5]:= GTN_LoadReadCommandVarTable(iCoreId_1,1,ADR(PATH_WATCHFILE));
// aiRtn[6]:= GTN_LoadReadCommandVarTable(iCoreId_2,1,ADR(PATH_WATCHFILE));


	hsMode:=6;
	interval:=0;
	readHsEnable:=0;
	
	aiRtn[5]:=GTN_ReadHSOn(iCoreId_1,readHsEnable,hsMode,interval);
	aiRtn[6]:=GTN_ReadHSOn(iCoreId_2,readHsEnable,hsMode,interval);
	
	aiRtn[7]:=GTN_LoadReadHsConfig(iCoreId_1,ADR(PATH_WATCHFILE));
	aiRtn[8]:=GTN_LoadReadHsConfig(iCoreId_2,ADR(PATH_WATCHFILE));
	
	
	
	readHsEnable:=1;
//	interval:=9;//(当前值+1)*用户周期(2毫秒) = 程序获取状态任务的周期
	interval:=5;//运控没有执行+1-9表示18ms，5代表10ms
	aiRtn[9]:=GTN_ReadHSOn(iCoreId_1,readHsEnable,hsMode,interval);
	aiRtn[10]:=GTN_ReadHSOn(iCoreId_2,readHsEnable,hsMode,interval);


(**2026.5.29.175453屏蔽
//2026.04.10.161624
aiRtn[13] := GTN_LoadWatchConfig(iCoreId_1,ADR(PATH_HOME_WATCH_CONFIG));
2026.5.29.175535*)
aiRtn[14]:= GTN_SetResCount(iCoreId_1, MC_AXIS, 64);// rtn = 0, [10:03:08:483]; 
aiRtn[15]:= GTN_SetResCount(iCoreId_2, MC_AXIS, 64);// rtn = 0, [10:03:08:483];    

GTN_SetAxisOnDelayTime(iCoreId_1, 0);       
GTN_SetAxisOnDelayTime(iCoreId_2, 0);  
//2025.11.10.212535 |
(*2026.5.29.175519屏蔽先
FOR iN := 1  TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
	aiRtn[15+iN] := GTN_GetMailbox(
		core:= 1, 
		station:= 0, 
		byteAddress:= 16#0198, 
		pData:= ADR(apData[iN]), 
		wordCount:= 1, 
		dataMode:= 1, 
		desId:= iN, 
		typeVar:= 1);
	apData1[iN] := UINT_TO_LREAL(apData[iN]);
	aiRtn[15+2*g_stStSysParam.stStSysParam_Save.iUnitMaxNum] := GTN_WriteAuEncPos(core:= 1, encoder:= iN, pPos:= ADR(apData1[iN]), count:=1);//g_stStSysParam.stStSysParam_Save.iUnitMaxNum);

END_FOR
2026.5.29.175528*)
FOR iN:=1 TO 64 BY 1 DO
	iRtn:= GTN_ClrSts(iCoreId_1,iN,1);
	iRtn:= GTN_ClrSts(iCoreId_2,iN,1);
END_FOR	   

sMsg:= '';
FOR iN:=1 TO 40 BY 1 DO
	IF aiRtn[iN]<>0 THEN
		sMsg:= CONCAT(INT_TO_STRING(iN),'-');
		sMsg:= CONCAT(sMsg,INT_TO_STRING(aiRtn[iN]));
		KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'LoadMotorCfg-failed!', sMsg);	

		//2025.11.05.101559 | bai.zy | 
		IF aiRetryCount[iN]>=iMaxRetryTimes THEN(*如果失败次数超过3次则就结束这个操作并进行提示*)
			g_iRunStepId:= RUNSTEP_LoadSysCfg;
		ELSE
			aiRetryCount[iN]:= aiRetryCount[iN]+1;
		END_IF
		EXIT;
	ELSE
		aiRetryCount[iN] := 0;
	END_IF
	IF iN=35 THEN
		g_iRunStepId:= RUNSTEP_LoadSysCfg;
	END_IF
END_FOR

