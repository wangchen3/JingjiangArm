(*@CES
Name=Action_Normal_Act
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=0c0b0199-56be-40f7-870a-22bf3fc9cd63
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*根据输入处理动作*)
(*在这里处理一下LOG任务触发的标志*)
tTime_Cur:= TIME();
xFlag_Stop_Sys:= FALSE;
xFlag_Stop_Sys:= (g_stStSysParam.astStGrpParam_UnSave[1].xFlag_Stop OR 
						g_stStSysParam.astStGrpParam_UnSave[1].xFlag_Estop) AND
			    		(g_stStSysParam.astStGrpParam_UnSave[2].xFlag_Stop OR 
						g_stStSysParam.astStGrpParam_UnSave[2].xFlag_Estop);	
IF NOT xInitTime_Log THEN
	xInitTime_Log:= TRUE;
	tTime_Start_Log:= tTime_Cur;
END_IF
//2026.5.19.194643||停机后强制写一次参数，开机时候不写
fbKS_FB_TRIG(CLK:= xFlag_Stop_Sys);
IF xFlag_Stop_Sys AND (NOT g_xTrigSave_BlackoutSts) THEN//只有停机状态并且非断电时候，可以写文件
	IF ((tTime_Cur- tTime_Start_Log)>=tTime_WriteFileParam_Log) OR 
			fbKS_FB_TRIG.Q THEN
		g_xFlag_LogTaskRun:= TRUE;
		tTime_Start_Log:= tTime_Cur;
	END_IF
ELSE
	g_xFlag_LogTaskRun:= FALSE;
END_IF


(*处理一下误差队列--
同时处理调整量计算*)
//g_stStSysParam.astStGrpParam_UnSave[1].xIsDebugMode_Machine:= TRUE;
g_stStSysParam.astStGrpParam_UnSave[1].xEnaTestARC_Ink:= g_stStSysParam.astStGrpParam_UnSave[1].xIsDebugMode_Machine;
//pstStGrpParam_UnSave^.xEnaTestARC_Ink
FOR iN:=2 TO MAX_UNIT_NUM BY 1 DO
	(*误差队列*)
	iUnitId:= iN;
	IF abyLastIndex[iN]<> astStErrParam_Use[iN].byIDX_V THEN(*误差已更新*)
		adwGetArcErrorAxisIdBitIndex[iGrpId]:=(*按bit存放获取成功标志*)
				adwGetArcErrorAxisIdBitIndex[iGrpId] OR SHL(DWORD#1,iUnitId-1);		
		FOR iNum:=50 TO 2 BY -1 DO
			g_stStSysParam.astStUnitParam_UnSave[iN].aiError_V_History[iNum]:=
				g_stStSysParam.astStUnitParam_UnSave[iN].aiError_V_History[iNum-1];
			g_stStSysParam.astStUnitParam_UnSave[iN].aiError_H_History[iNum]:=
				g_stStSysParam.astStUnitParam_UnSave[iN].aiError_H_History[iNum-1];				
		END_FOR
		//2026.4.11.151626 修改为显示误差值
		//g_stStSysParam.astStUnitParam_UnSave[iN].aiError_V_History[1]:= astStErrParam_Use[iN].iErr_V;
		//g_stStSysParam.astStUnitParam_UnSave[iN].aiError_H_History[1]:= astStErrParam_Use[iN].iErr_H;
		g_stStSysParam.astStUnitParam_UnSave[iN].aiError_V_History[1]:= astStErrParam_Use[iN].iErr_V_Display;
		g_stStSysParam.astStUnitParam_UnSave[iN].aiError_H_History[1]:= astStErrParam_Use[iN].iErr_H_Display;
		g_stStSysParam.astStUnitParam_UnSave[iN].byIndex:= astStErrParam_Use[iN].byIDX_V;

		(*误差队列处理完毕2025.8.6.165528-处理调整*)	
		(*误差队列处理完毕2025.8.6.165528-处理调整*)	
		//2026.5.9.185731+
//		g_stStSysParam.astStUnitParam_UnSave[iN].dwLockTime_GetArcErr:=g_astStVarList[iN].dwTime_Lock;
		g_stStSysParam.astStUnitParam_UnSave[iN].dwLockTime_GetArcErr:=g_stStSysParam.astStUnitParam_UnSave[iN].dwTime_Lock;

	END_IF
	
	abyLastIndex[iN]:= astStErrParam_Use[iN].byIDX_V;
END_FOR
(*处理调整*)
(*2024.03.09.000915 增加自动设置套色耦合方式@根据是否隔色控制*)
(*先不考虑b系@主要是由于耦合方式的变量未分系*)
IF g_stStSysParam.stStSysParam_Save.xAutoSetArcCtlWay THEN(*自动设置@根据隔色还是不隔色*)
	(*检查色组是不是隔色印刷*)
	FOR iGrpId:=1 TO 2 BY 1 DO
		pstStGrpParam_Save:= ADR(g_stStSysParam.astStGrpParam_Save[iGrpId]);
		pstStGrpParam_UnSave:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrpId]);
		(*检查套色轴是否连续*)
(*		xIsContinue:=
			KS_CheckArcAxisIdIsContinue(pstStGrpParam^.byGrpArcAxisNum,pstStGrpParam^.abyGrpArcAxisList);
*)
		xIsContinue:=TRUE;(*只是做了一个沿处理@和命名已经无关*)
		pstStGrpParam_Save^.iWorkMode_Pid:=4;
		IF iGrpId=1 THEN(*解耦先只按照a系@主要是由于耦合方式的变量未分系*)
			IF (pstStGrpParam_Save^.xFlag_Follow_1U_V ) OR
				axUseErrTransfer[iGrpId] OR(*误差传递@2024.7.28.154101*)
				pstStGrpParam_UnSave^.xFlag_Follow_1U_V_UwCut OR(*跟一色使用新20ms解耦|2024.7.25.111717*)
				pstStGrpParam_UnSave^.xFlagFollow1U_AccDecing THEN(*加减速跟一色@2024.7.25.112544*)
				(*都用成11 兼容隔色*)
				g_stStSysParam.stStSysParam_Save.byCouplingType:=11;
			ELSE
				g_stStSysParam.stStSysParam_Save.byCouplingType:=9(*10*);(*自动使用第9种*)
			END_IF
		END_IF
	END_FOR
ELSE(*手动设置*)
	(*用上面的xIsContinue变量做一个沿*)
	IF xIsContinue THEN(*说明自动方式下被修改成了新的方案@else中恢复一次*)
		xIsContinue:=FALSE;
		FOR iGrpId:=1 TO 2 BY 1 DO
			pstStGrpParam_Save:= ADR(g_stStSysParam.astStGrpParam_Save[iGrpId]);
			pstStGrpParam_UnSave:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrpId]);
			pstStGrpParam_Save^.iWorkMode_Pid:=2;
			IF iGrpId=1 THEN(*解耦先只按照a系@主要是由于耦合方式的变量未分系*)
				IF (pstStGrpParam_Save^.xFlag_Follow_1U_V ) OR
					axUseErrTransfer[iGrpId] OR(*误差传递@2024.7.28.154101*)
					pstStGrpParam_UnSave^.xFlag_Follow_1U_V_UwCut OR(*跟一色使用新20ms解耦|2024.7.25.111717*)
					pstStGrpParam_UnSave^.xFlagFollow1U_AccDecing THEN(*加减速跟一色@2024.7.25.112544*)
					(*都用成11 兼容隔色*)
					g_stStSysParam.stStSysParam_Save.byCouplingType:=11;
				ELSE
					g_stStSysParam.stStSysParam_Save.byCouplingType:=9(*10*);(*自动使用第9种*)
				END_IF
			END_IF
		END_FOR
	END_IF
END_IF

(*2023.11.17.181958*)
(*为了使用小黄的耦合算法。在这里检查所有套色轴的误差是否都更新了，如果都更新了则启动套色调整*)
SysMemSet(ADR(axCanCalcArcAdjustValue),0,SIZEOF(axCanCalcArcAdjustValue));
axCanCalcArcAdjustValue_Grp[1]:=FALSE;(*一圈触发一次*)
axCanCalcArcAdjustValue_Grp[2]:=FALSE;(*一圈触发一次*)


FOR iGrpId:=1 TO 2 BY 1 DO
	pstStGrpParam_Save:= ADR(g_stStSysParam.astStGrpParam_Save[iGrpId]);
	pstStGrpParam_UnSave:= ADR(g_stStSysParam.astStGrpParam_UnSave[iGrpId]);

	(*2024.03.12.130424 修改*)
	(*从第二个套色轴开始*)
	FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO
		iUnitId:=pstStGrpParam_UnSave^.abyGrpArcAxisList[iN];
		IF iUnitId>1 THEN
			xRtn:=KS_GetBitByDword(INT_TO_BYTE(iUnitId-1), adwGetArcErrorAxisIdBitIndex[iGrpId]);
			IF xRtn THEN(*有效了*)
				IF iN=pstStGrpParam_UnSave^.byGrpArcAxisNum THEN(*都有效了|可以计算套色了*)
					axCanCalcArcAdjustValue_Grp[iGrpId]:=TRUE;(**)
					(*用于监控测试@2024.03.12.145143*)
					aiGetAxisArcErrorNum[2]:=aiGetAxisArcErrorNum[2]+1;
				END_IF
			ELSE(*还有无效的*)
				EXIT;
			END_IF
		ELSE;
		END_IF
	END_FOR

	IF iGrpId=1 THEN(*用于监控测试@2024.03.12.145143*)
		IF adwGetArcErrorAxisIdBitIndex[iGrpId]<>0 THEN
			aiGetAxisArcErrorNum[iGrpId]:=DWORD_TO_INT(adwGetArcErrorAxisIdBitIndex[iGrpId]);
		END_IF
	END_IF

	IF g_stStSysParam.stStSysParam_Save.byCouplingType=10 OR (*使用小黄的不隔色解耦控制方式*)
		g_stStSysParam.stStSysParam_Save.byCouplingType=9 OR(*隔色解耦*)
		g_stStSysParam.stStSysParam_Save.byCouplingType=11 OR//跟一色
		g_stStSysParam.stStSysParam_Save.byCouplingType=12 THEN
		IF axCanCalcArcAdjustValue_Grp[iGrpId] THEN(*套色轴的误差都获取了|不包含首色*)
			(*使能套色调整标志@从第二个套色轴开始*)
			FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO
				iUnitId:=pstStGrpParam_UnSave^.abyGrpArcAxisList[iN];
				axCanCalcArcAdjustValue[iUnitId]:=TRUE;
			END_FOR
			adwGetArcErrorAxisIdBitIndex[iGrpId]:=0;(*2024.03.12.131035 确认可以套色后清零*)
		END_IF
	ELSE(*原来的控制方式@套色误差来了就直接调整*)
		IF adwGetArcErrorAxisIdBitIndex[iGrpId]<>0 THEN(*有轴需要调整*)
			FOR iN:=2 TO pstStGrpParam_UnSave^.byGrpArcAxisNum BY 1 DO
				iUnitId:=pstStGrpParam_UnSave^.abyGrpArcAxisList[iN];
				dwTempVal:=SHR(adwGetArcErrorAxisIdBitIndex[iGrpId],iUnitId-1);
				IF dwTempVal.0 THEN(*可以进行调整*)
					axCanCalcArcAdjustValue[iUnitId]:=TRUE;
				END_IF
			END_FOR
			adwGetArcErrorAxisIdBitIndex[iGrpId]:=0;
		END_IF
	END_IF
END_FOR
aliTime_Value[3]:= LTIME();

(*调整、传递、PID清零*)
Action_Normal_Act_Adj();
aliTime_Value[4]:= LTIME();

Action_Normal_Act_Coupling();
aliTime_Value[5]:= LTIME();

Action_Normal_Act_ZeroPID();
aliTime_Value[6]:= LTIME();

Action_Normal_Act_VerCtl();
