(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=9dca3c75-e47f-462b-8c51-2621578ce5fc
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
// FOR iN := 1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
// 	g_stStSysParam.astStUnitParam_UnSave[iN].lrEnc_Pos := g_astMotionSts[iN].lrPos_Enc;
// END_FOR

//2026.4.30.091702|获取当前速度和加速度放INPUT吧
(*2026.4.30.091718先屏蔽
(*获取当前速度*)
//g_stStSysParam.astStGrpParam_UnSave[1].rVel_Cur:= LREAL_TO_REAL(ABS(g_astMotionSts[g_iAxisNum_All+g_stStSysParam.stStSysParam_Save.iUnitMaxNum+1].lrVel_Prf*1000*60/GC_LRMOTORPPR*gc_rGirth_Master/2));		
g_stStSysParam.astStGrpParam_UnSave[1].rVel_Cur:= LREAL_TO_REAL(ABS(g_alrVel_VirtualAxis[1]*1000*60/GC_LRMOTORPPR*gc_rGirth_Master));	


//2026.4.11.145204处理一下加速度输出和加加速度输出
IF NOT axInit_Vel[1] THEN
	axInit_Vel[1]:= TRUE;
	g_arCur_Jerk[1]:= 0;
//	arVel_Pre[1]:= 0;
	arVel_Pre_A[1]:= 0;
END_IF
IF g_stStSysParam.astStGrpParam_UnSave[1].rVel_Cur =0 THEN
	axInit_Vel[1]:= FALSE;
END_IF

g_arCur_A[1]:= g_alrPrfAcc_MasterAxis2[1]*gc_rGirth_Master/GC_LRMOTORPPR * 6 * 10000000;//m/min/s
g_arCur_Jerk[1]:= (g_arCur_A[1]-arVel_Pre_A[1])*1000/gc_TENSION_TSK_CYCLE_TIME;//m/min/s/s
arVel_Pre_A[1]:= g_arCur_A[1];
*)
//Watch 功能
IF g_xWatchOn THEN
	g_xWatchOn := FALSE;
	iRtn := GTN_LoadWatchConfig(1,ADR(PATH_HOME_WATCH_CONFIG));
END_IF

IF g_xWatchOff THEN
	g_xWatchOff := FALSE;
	iRtn := GTN_WatchOff(1);
	iRtn := GTN_PrintWatch(1,0,0,ADR(PATH_HOME_WATCH_DATA));
END_IF

IF g_xClrSts THEN
	g_xClrSts := FALSE;
	iRtn := GTN_ClrSts(g_iCoreId,g_iAxisId,1);
END_IF


(*
//2025.11.03.103620 | bai.zy | TEST_1103
IF iReadVirtualSts_UnitId > g_stStSysParam.stStSysParam_Save.iUnitMaxNum THEN
	iReadVirtualSts_UnitId := 1;
END_IF
atiTimeReadWatch[1] := LTIME();
iRtn := GTN_GetMailbox(
	core:= 1, 
	station:= 0, 
	byteAddress:= 16#C416, 
	pData:= ADR(apData[iReadVirtualSts_UnitId]), 
	wordCount:= 1, 
	dataMode:= 1, 
	desId:=iReadVirtualSts_UnitId, 
	typeVar:= 1);
atiTimeReadWatch[2] := LTIME();

atiTimeReadWatch[10] := atiTimeReadWatch[2] - atiTimeReadWatch[1];
g_stStSysParam.astStUnitParam_UnSave[iReadVirtualSts_UnitId].wVirTual_Sts := apData[iReadVirtualSts_UnitId];
	
iReadVirtualSts_UnitId := iReadVirtualSts_UnitId + 1;
*)
//2026.4.24.132758  屏蔽测试
// 
// FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
// 	iRtn := GTN_ReadWatch(
// 		1,
// 		iN,
// 		ADR(alrBuff_Read[iN,1]),
// 		50,
// 		ADR(adiReadCount[iN]));	
// END_FOR

// 
// FOR iN := 1  TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
// 	IF adiReadCount[iN] = 0 THEN
// 		EXIT;
// 	END_IF
// 	IF iN = g_stStSysParam.stStSysParam_Save.iUnitMaxNum THEN
// 		FOR iK := 1 TO  g_stStSysParam.stStSysParam_Save.iUnitMaxNum BY 1 DO
// 			g_stStSysParam.astStUnitParam_UnSave[iK].wVirTual_Cnt:= LREAL_TO_WORD(alrBuff_Read[iK,adiReadCount[iK]]);
// 			g_alrPrfPos[iK] := alrBuff_Read[iK,adiReadCount[iK]];
// 			g_awAxisVirtualCnt[iK] := g_stStSysParam.astStUnitParam_UnSave[iK].wVirTual_Cnt;
// 			g_awAxisVirtualSts[iK] := g_stStSysParam.astStUnitParam_UnSave[iK].wVirTual_Sts;
// 		END_FOR
// 	END_IF
// END_FOR

//iRtn := GTN_GetResCount(core:= 1, typeVar:= MC_AU_ENCODER_EX, pCount:= ADR(iCountRes));

//xi.hy新增@七号开始
//2026.5.14.093917 获取每个轴的站列表 by liu.yt
byGetStationVarNum:=0;
SysMemSet(ADR(abyGetVar_StationIdList),0,SIZEOF(abyGetVar_StationIdList));
SysMemSet(ADR(abyGetVar_AxisIdList),0,SIZEOF(abyGetVar_AxisIdList));
FOR iN:=1 TO g_stStSysParam.stStSysParam_Save.iUnitMaxNum DO
	IF iN<=MAX_UNIT_NUM AND
		g_stStSysParam.astStUnitParam_Save[iN].iStationId>0 THEN//站号合法@这套程序0#站不获取这些信息
		byGetStationVarNum:=byGetStationVarNum+1;
		//列表站号更新
		//abyGetVar_StationIdList[byGetStationVarNum]:=INT_TO_BYTE(g_stStSysParam.astStUnitParam_Save[iN].iStationId_CTL);
		//临时处理@需要删除的 by liu.t 2026.05.14.114705+
		abyGetVar_StationIdList[byGetStationVarNum]:=INT_TO_BYTE(iN);
		abyGetVar_AxisIdList[byGetStationVarNum]:=INT_TO_BYTE(iN);
	END_IF
END_FOR

iRtn:=GTN_RN_GetKSVarList(1,ADR(abyGetVar_StationIdList),ADR(apiStationVar),byGetStationVarNum);

IF iRtn<>0 THEN
	;
ELSE
	//将获取到的数据写如到轴参数中@2026.5.14.105521+ by liu.yt
	FOR iN:=1 TO byGetStationVarNum DO
		iK:=BYTE_TO_INT(abyGetVar_AxisIdList[iN]);//轴id
		//获取数据
		pwTmp:=ADR(apiStationVar[iN]^[1]);//索引是按照队列
		g_stStSysParam.astStUnitParam_UnSave[iK].wVirTual_Cnt:=pwTmp^;//索引是按照色组id
		pwTmp:=ADR(apiStationVar[iN]^[2]);
		g_stStSysParam.astStUnitParam_UnSave[iK].wVirTual_Sts:=pwTmp^;
		pdwTmp:=ADR(apiStationVar[iN]^[3]);
		g_stStSysParam.astStUnitParam_UnSave[iK].dwTime_Lock:=pdwTmp^;
		pdwTmp:=ADR(apiStationVar[iN]^[5]);
		g_stStSysParam.astStUnitParam_UnSave[iK].dwEnc_Lock:=pdwTmp^;
		
	//2026.5.19.094140	
		g_awAxisVirtualCnt[iK]:= g_stStSysParam.astStUnitParam_UnSave[iK].wVirTual_Cnt;
		
	END_FOR
END_IF
