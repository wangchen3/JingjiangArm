(*@CES
Name=Action_SetSysCfg
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=5e0a3748-7e7b-4cc7-a5fe-a3c7b5b95177
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}


//2026.05.12.132248 | + | 从通讯任务中挪出来到这里
//2025.12.16.154650 | 异站编码器新增加的功能测试，目前先放在这里，暂时还没有库，等待中。。。。。。
xRemoteSetDne := TRUE;
FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
	pstStUnitParam_Save:=ADR(g_stStSysParam.astStUnitParam_Save[iN]);
	IF 	pstStUnitParam_Save^.iStationId<>-1 THEN(*存在控制站号*)
//2026.03.11.093012 | + | 同步获取编码器位数和最大转速的功能 下面的这一段改成自动的，不使用强制了，已经在秦华验证过
		IF NOT axRemoteSetDne[iN] THEN
			//2026.02.23.161037 | + | 通过flash获取编码器位数
			udiAddrRd:= 289;(* Nos *)
			iRtn :=GTN_RN_GetFlashParamInfo(
					cardIndex:= 1, 
					station_id:= pstStUnitParam_Save^.iStationId, 
					axis:= 1, 
					addr:= udiAddrRd, 
					pData:= ADR(adwMotorEncoder[iN]));
			(*目前只支持这两种编码器@2025.12.5.151451*)
			IF adwMotorEncoder[iN]<>4194304 AND
				adwMotorEncoder[iN]<>16777216 THEN
				adwMotorEncoder[iN]:=4194304;
			END_IF
			
			//2026.02.23.161037 | + | 通过flash获取最高转速
			udiAddrRd:= 80;(* Nos *)
			iRtn :=GTN_RN_GetFlashParamInfo(
					cardIndex:= 1, 
					station_id:= pstStUnitParam_Save^.iStationId, 
					axis:= 1, 
					addr:= udiAddrRd, 
					pData:= ADR(auiAllowMotorRpm_Max[iN]));
		END_IF
		KS_SetRemoteEncParam(FALSE,(*使用异站编码器@true 使用本地编码器*)
						g_stStSysParam.stStSysParam_UnSave.aiStationList_UnitController[iN],//pstStUnitParam_Save^.iStationId,
						adwMotorEncoder[iN],
						auiAllowMotorRpm_Max[iN],//REAL_TO_UINT(pstStAxisParam^.rAllowMotorRpm_Max),
						DINT_TO_DWORD(gc_diVirEncPPR_New),(*有可能根据套色采样精度修改*)
						ADR(axRemoteSetDne[iN]),
						ADR(axRemotSetFailed[iN]));
		xRemoteSetDne := xRemoteSetDne AND axRemoteSetDne[iN];

	ELSE
		axRemoteSetDne[iN]:=FALSE;
		axRemotSetFailed[iN]:=FALSE;
	END_IF
	
	//xRemoteSetDne := xRemoteSetDne AND axRemoteSetDne[iN];

END_FOR

IF xRemoteSetDne THEN
	g_iRunStepId:= RUNSTEP_NormalWork;(* 成功与否/最后都会进入到这一步 *)
ELSE
	iRemoteSetFailed := iRemoteSetFailed + 1;
	IF iRemoteSetFailed > gc_iNum_ErrorNum_GT THEN
		FOR iN := 1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
			g_axRemoteSetFailed[iN] := axRemotSetFailed[iN] OR (NOT axRemoteSetDne[iN]);
		END_FOR
		//2026.5.24.092154
		g_iRunStepId:= RUNSTEP_NormalWork;(* 成功与否/最后都会进入到这一步 *)
	END_IF
//	g_iRunStepId:= RUNSTEP_NormalWork;(* 成功与否/最后都会进入到这一步 *)
END_IF


