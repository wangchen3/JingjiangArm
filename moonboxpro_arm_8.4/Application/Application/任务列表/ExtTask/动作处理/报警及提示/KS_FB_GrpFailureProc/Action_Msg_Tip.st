(*@CES
Name=Action_Msg_Tip
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=2a3b2715-1549-4dfe-9aa9-c855953a89ab
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
	
(*如果没有严重报警-处理提示信息*)
IF iMsgId<1000 THEN
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebugMode_Machine THEN(*调试模式*)
		iMsgId:=8;
	END_IF


	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_TensionUnfinished THEN(*拉料未完成*)
		iMsgId:= 6;
	END_IF

	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_VelTooHigh THEN (*速度过高*)
		iMsgId:= 4;
	END_IF
	fbTrigWillAutoPreCut_Uw(CLK:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xWillAutoMaticPreCut_Uw,Q=>);
	fbTrigWillAutoPreCut_Rw(CLK:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xWillAutoMaticPreCut_Rw,Q=>);
	IF fbTrigWillAutoPreCut_Uw.Q THEN
		xWillAutoMaticPreCut_Uw:=TRUE;
	ELSE
		IF NOT fbTrigWillAutoPreCut_Uw.CLK OR
			o_xClrAlarmSts THEN
			xWillAutoMaticPreCut_Uw:=FALSE;
		END_IF
	END_IF
	IF fbTrigWillAutoPreCut_Rw.Q THEN
		xWillAutoMaticPreCut_Rw:=TRUE;
	ELSE
		IF NOT fbTrigWillAutoPreCut_Rw.CLK OR
			o_xClrAlarmSts THEN
			xWillAutoMaticPreCut_Rw:=FALSE;
		END_IF
	END_IF

	IF xWillAutoMaticPreCut_Uw THEN(*放料即将自动接料*)
		iMsgId:= 50;
	END_IF
	IF xWillAutoMaticPreCut_Rw THEN(*收料即将自动接料*)
		iMsgId:= 51;
	END_IF
	IF xWillAutoMaticPreCut_Uw AND(*放料即将自动接料*)
		xWillAutoMaticPreCut_Rw THEN(*收料即将自动接料*)
		iMsgId:= 52;
	END_IF
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_VolDiamAlarm_Uw THEN (*放料卷径*)
		iMsgId:= 5;
	END_IF

(*一键开机先不处理？？？？*)
(*
	IF i_iOneKeySwitchOn_IdGSE <> STEPAUTO_IDLE THEN(*一键开机*)
		iMsgId:=10;
	END_IF
*)
	iLinkageAxisNum:= 0;(* 2021.9.22.110348/+ *)
	FOR iN:=1 TO i_byGrpUnitNum BY 1 DO(*至少联动一色*)
		pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[i_abyAxisList[iN]]);(*轴参数入口|*)
		IF pstStUnitParam_Save^.xLinkage THEN
			iLinkageAxisNum:= iLinkageAxisNum+1;(* 联动轴计数 *)
		END_IF
	END_FOR
	IF iMsgId<>3 AND iLinkageAxisNum=0 THEN (* 2021.9.22.110311/+ *)
		iMsgId:= 3;
	END_IF


	(*2021.7.26.131725  增加热风停止中显示|*)
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HotBlowerStopDelay THEN(*热风延时关闭中*)
		iMsgId:= 21;
	END_IF

	IF i_pstStSysParam^.stStSysParam_UnSave.xIOTestMode THEN(*IO测试*)(*增加OR g_xAnalogTest|2019.11.14.163941_*)
		iMsgId:= 7;
	END_IF


	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMachineRev THEN(*整机反转*)
		iMsgId:= 12;
	END_IF


(*远程诊断也先不处理了2025.9.25.134518*)
(*			IF g_xInTheDiagnosis THEN(*远程诊断协助中*)
		iMsgId:= 13;
	END_IF
*)
	IF (g_abyiNFeedLimitWarnFlag[i_iGrpId]=1)
		OR (g_abyOutFeedLimitWarnFlag[i_iGrpId]=1) THEN
		iMsgId:= 18;
	END_IF

	(*2020.10.9.184227 弧面检测时弧面信号丢失提示*)
	IF i_xReflectSensorLoss THEN
		iMsgId:=20;
		iPromptMsg:=20;
	ELSE
		IF iPromptMsg=20 THEN
			iMsgId:=20;
		END_IF
	END_IF

	(*力达增加第三方系统报警和停机输入-界面提示2022.7.1.133519*)
	IF i_xFlag_Alarm_LD THEN
		iMsgId:= 42;
	END_IF
(*关于485一些工艺相关报警后面回去了仔细处理2025.9.25.134949*)
	IF i_xFlag_FastStopBtnDn THEN(*快停被按下了*)
		iMsgId:=32;
	END_IF

	fbToF_UwVolDiamMeasurement(IN:=i_xUwVolDiamMeasurementFailed,PT:=T#10s);
(*			IF fbToF_UwVolDiamMeasurement.Q THEN(*卷径测量失败|有关闭10s延时处理*)*)
	IF fbToF_UwVolDiamMeasurement.in THEN(*卷径测量失败|2022.9.14.155428 界面点击清除*)
		iMsgId:=33;
	END_IF

	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Uw THEN(*放料绝对值编码器故障*)
		iMsgId:=34;
	END_IF
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Rw THEN(*收料绝对值编码器故障*)
		iMsgId:=35;
	END_IF

	(*2025.4.20.141710+*)
	FOR iN:=1 TO i_byGrpUnitNum BY 1 DO
		iUnitId:=i_abyAxisList[iN];
		pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
		IF pstStUnitParam_UnSave^.xInValidVirtualCnt THEN
			iMsgId:=46;
			EXIT;
		END_IF
	END_FOR

	(*2024.02.23.170019*)
	IF i_dwAvailPhys_kB<=i_wAvailPhysAlarm_Kb AND i_dwAvailPhys_kB<>0 THEN(*内存太小了|提示报警*)
		iMsgId:=60;
	END_IF

	(*2024.03.11.105351+*)
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Home THEN(*读取装版相位*)
		iMsgId:=70;
	END_IF
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreRegister THEN(*预套准*)
		iMsgId:=71;
	END_IF
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRestore THEN(*相位恢复*)
		iMsgId:=72;
	END_IF
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AllInchRun THEN(*整机单运行*)
		iMsgId:=73;
	END_IF
	IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PhaseRead THEN(*恢复装版相位中标志@2025.2.7.152811*)
		iMsgId:=75;
	END_IF


	(*新增停机相位回复提示2024.9.4.230759||niu.j*)
	IF i_xCompensate_Phase_Stop THEN
		iMsgId:=74;
	END_IF
(*自动备份功能暂时无内容2025.9.25.140246先不提示			
	(*sdctl自动备份状态显示@2025.5.28.174423*)
	IF io_byAutoBackUpSts=1 OR io_byAutoBackUpSts=2 THEN(*显示提示*)
		IF i_pstStGrpParam^.xBtn_ResetAlarm THEN(*提示按钮被按下*)
			io_byAutoBackUpSts:=2;(*显示备份弹框*)
		END_IF
		iMsgId:=80;
	END_IF
*)
	(*2024.7.10.172415+*)
	IF i_xMemAllocFailed THEN
		iMsgId:=61;
	END_IF	
	
	//2026.1.9.165419 \ + | 增加带长检测异常的报警
	FOR iN := 1 TO i_byGrpUnitNum BY 1 DO
		IF g_axCheckBandLenErr[iN] THEN
			iMsgId:=81;
			iAlarm_UnitId := iN;
		END_IF
	END_FOR	
	
	//2026.05.09.160415 | + | 增加龙门偏差过大保护
	FOR iN:= 1 TO i_byGrpUnitNum BY 1 DO
		IF g_axPressFlag_Stop[iN] THEN
			iMsgId:=82;
			iAlarm_UnitId := iN;
		END_IF
	END_FOR	
		//2026.5.19.100322增加网络站点离线提示
	IF g_xError_SysCfg THEN//系统配置异常
		iMsgId:= 1;//系统配置异常
	END_IF
	//2026.5.24.084902配方加载异常
	IF g_axPhaseRestore_Overtime[i_iGrpId] THEN
		iMsgId:=83;
	END_IF	
END_IF