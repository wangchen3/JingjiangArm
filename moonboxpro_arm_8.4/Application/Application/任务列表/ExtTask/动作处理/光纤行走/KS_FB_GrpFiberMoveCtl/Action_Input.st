(*@CES
Name=Action_Input
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=3d432cf6-e9b0-4702-bdd7-25ff80946d8b
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
xFlag_Stop_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;//停止
xFlag_Estop_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStop;//急停
xFlag_Print_In:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print;//印刷
iFiberVel:=i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].iFiberMoveVel;//移动速度
iFiberVel_Fast:=i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].iFiberMoveVel;//移动速度_快
xIsDebugMode:=i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xFiberMove_DebugMode;//光纤行走调试模式

pxFiberMovePosCal_ByUnit:=ADR(i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xFiberMovePosCal_ByUnit);//色组标定按钮
pxFiberMovePosCal_ByOnline:=ADR(i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xFiberMovePosCal_ByOnline);//在线标定按钮
xUseOnline:=i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].xUseOnline_FiberMove;//使用外部在线联动
rBasePosByOnline:=i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].rFiberMoveBasePosByOnline;//在线检测发来的基准位置
pxFiberMoveDisRunStart_AllUnit:=ADR(i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xFiberMoveDisRunStart_AllUnit);//所有色组同步运动使能
rFiberMoveDistance_AllUnit:=i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].rFiberMoveDistance_AllUnit;//所有色组同步运动距离
pxConfirm_AllUnit:=ADR(i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xFiberMoveConfirm_AllUnit);//色组标定确认目标色按钮，其余色组运动到目标色组位置
byFiberMove_MicroMoveStep:=i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].byFiberMove_MicroMoveStep;//光纤行走微调步进量@mm
//2026.06.04.102052
byArcAxisNum:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byGrpArcAxisNum;//套色轴数量
byArcId_Final:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyGrpArcAxisList[byArcAxisNum];//套色最后一个轴轴号


FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iUnitId:= i_abyGrpAxisList[iN];
	pstStRSV_UnitParam_Save:= ADR(i_pstStSysParam^.astStRSV_UnitParam_Save[iUnitId]);
	pstStRSV_UnitParam_UnSave:= ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId]);
	pstStIOMap_Axis_FE:=ADR(i_pastStIOMap_Axis_FE^[iUnitId]);
	
	//Save
	pstStRSV_UnitParam_Save^.uiFiberMovePulsePerCycle:=6000;//单圈脉冲
	g_astStFiberMoveStepDriver[iUnitId].uiFiberMovePulsePerCycle:=pstStRSV_UnitParam_Save^.uiFiberMovePulsePerCycle;//单圈脉冲
	pstStRSV_UnitParam_Save^.rFiberMoveDistancePerCycle:=40;//单圈距离
	g_astStFiberMoveStepDriver[iUnitId].rFiberMoveDistancePerCycle:=pstStRSV_UnitParam_Save^.rFiberMoveDistancePerCycle;//单圈距离
	g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust:=pstStRSV_UnitParam_Save^.rFiberMoveAdjust;//行走 色组修正
	g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust_ByOnline:=pstStRSV_UnitParam_Save^.rFiberMoveAdjust_ByOnlie;//行走 在线修正
	g_astStFiberMoveStepDriver[iUnitId].rFiberMoveVel:=i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].iFiberMoveVel;//移动速度
	
	
	//unSave
	xLinkage_In[iUnitId]:=i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;//联动
	g_astStFiberMoveStepDriver[iUnitId].uiFiberMoveAlarm:=pstStRSV_UnitParam_UnSave^.uiFiberMoveAlarm;//行走报警
	g_astStFiberMoveStepDriver[iUnitId].xFiberMoveGoHome:=pstStRSV_UnitParam_UnSave^.wState_FiberMove.5;//行走回零状态
	g_astStFiberMoveStepDriver[iUnitId].xFiberMoveLimit_Left:=0;//左限位
	g_astStFiberMoveStepDriver[iUnitId].xFiberMoveLimit_Right:=0;//右限位
	g_astStFiberMoveStepDriver[iUnitId].xFiberMove_LimitPos:=pstStRSV_UnitParam_UnSave^.wState_FiberMove.7;//人机读取到的限位有效
	g_astStFiberMoveStepDriver[iUnitId].xFiberMoveMotorRunning:=pstStRSV_UnitParam_UnSave^.wState_FiberMove.0;//电机运行中
	//2026.05.28.183104
	g_astStFiberMoveStepDriver[iUnitId].rFiberMoveBasePosFromSlave:=pstStRSV_UnitParam_UnSave^.rFiberMoveBasePosFromSlave;//从站发来的基准位置
	//色组修正取反
	IF i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].xFiberMove_Negative_AdjustByUnit THEN
		g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust_Use:=-g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust;
	ELSE
		g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust_Use:=g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust;
	END_IF
	//在线修正取反
	IF i_pstStSysParam^.astStRSV_GrpParam_Save[i_iGrpId].xFiberMove_Negative_AdjustByOnline THEN
		g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjustByOnline_Use:=-g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust_ByOnline;
	ELSE
		g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjustByOnline_Use:=g_astStFiberMoveStepDriver[iUnitId].rFiberMoveAdjust_ByOnline;
	END_IF
	g_astStFiberMoveStepDriver[iUnitId].rFiberMovePosCur:=pstStRSV_UnitParam_UnSave^.rFiberMovePosCur;//当前位置
	//2026.04.29.094723
	g_astStFiberMoveStepDriver[iUnitId].iFiberMove_StsSlave:=pstStRSV_UnitParam_UnSave^.iStsSlave_FiberMove;//从站运动状态机
	
	//2026.05.06.102558 处理按钮控制
	KS_BtnClick(
		pstStIOMap_Axis_FE^.i_xRsvd_DI0,
		300,
		35,
		ADR(axClick_FiberMoveBtn1[iUnitId]),
		ADR(axDoubleClick_FiberMoveBtn1[iUnitId]),
		ADR(axHold_FiberMoveBtn1[iUnitId]),
		ADR(awCnt_FiberMoveBtn1[iUnitId])
		);
	KS_BtnClick(
		pstStIOMap_Axis_FE^.i_xRsvd_DI1,
		300,
		35,
		ADR(axClick_FiberMoveBtn2[iUnitId]),
		ADR(axDoubleClick_FiberMoveBtn2[iUnitId]),
		ADR(axHold_FiberMoveBtn2[iUnitId]),
		ADR(awCnt_FiberMoveBtn2[iUnitId])
		);
	g_astStFiberMoveStepDriver[iUnitId].xFiberMoveLeft:=axHold_FiberMoveBtn1[iUnitId];//手动左移
	g_astStFiberMoveStepDriver[iUnitId].xFiberMoveRight:=axHold_FiberMoveBtn2[iUnitId];//手动右移
	//全自动套印开始
	axFindMarkCenter_Local[iUnitId]:=pstStRSV_UnitParam_UnSave^.wState_FiberMove.6;//本地找中使能
	IF i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xStartAutoFind  THEN//全自动套印开始/色组本地找中，定长运动控制由全自动套印控制
		//初始化
		IF NOT axInit_AutoFind[iUnitId] THEN
			g_astStFiberMoveStepDriver[iUnitId].xFiberMoveSyncDone:=FALSE;(*同步完成标志*)
			//2026.06.04.105556 最后一个套色轴不回零
			IF iUnitId<>byArcId_Final THEN
				g_astStFiberMoveStepDriver[iUnitId].xFiberMove_RunHomeStart:=TRUE;(*回零*)
			END_IF
			axInit_AutoFind[iUnitId]:=TRUE;
		ELSE
			//定长控制
			arDistanceIn_HMI[iUnitId]:=pstStRSV_UnitParam_UnSave^.rFiberMoveDistanceIn_FindSignal;
			IF(pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal)AND (NOT g_astStFiberMoveStepDriver[iUnitId].xFiberMoveMotorRunning) AND ABS(arDistanceIn_HMI[iUnitId])>0 THEN
				g_astStFiberMoveStepDriver[iUnitId].xFiberMoveDisRunStart:=pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal;
				pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal:=0;
			ELSE
				pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal:=0;
			END_IF
		END_IF
	ELSE//非全自动套印
		IF pstStRSV_UnitParam_UnSave^.xManualSingleAxisEn THEN(*色标居中手动*)
			//定长控制
			arDistanceIn_HMI[iUnitId]:=pstStRSV_UnitParam_UnSave^.rFiberMoveDistanceIn_FindSignal;
			IF(pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal)AND (NOT g_astStFiberMoveStepDriver[iUnitId].xFiberMoveMotorRunning) AND ABS(arDistanceIn_HMI[iUnitId])>0 THEN
				g_astStFiberMoveStepDriver[iUnitId].xFiberMoveDisRunStart:=pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal;
				pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal:=0;
			ELSE
				pstStRSV_UnitParam_UnSave^.xFiberMoveDisRunStart_FindSignal:=0;
			END_IF
		ELSE(*其余情况*)
			//定向左移微调
			IF axClick_FiberMoveBtn1[iUnitId] THEN
				arDistanceIn_HMI[iUnitId]:=-byFiberMove_MicroMoveStep;
				IF pstStRSV_UnitParam_UnSave^.iStsSlave_FiberMove=0 THEN
					g_astStFiberMoveStepDriver[iUnitId].xFiberMoveDisRunStart:=axClick_FiberMoveBtn1[iUnitId];
				END_IF
			END_IF
			//定向右移微调
			IF axClick_FiberMoveBtn2[iUnitId] THEN
				arDistanceIn_HMI[iUnitId]:=byFiberMove_MicroMoveStep;
				IF pstStRSV_UnitParam_UnSave^.iStsSlave_FiberMove=0 THEN
					g_astStFiberMoveStepDriver[iUnitId].xFiberMoveDisRunStart:=axClick_FiberMoveBtn2[iUnitId];
				END_IF
			END_IF
		END_IF
		//下面部分是 非全自动套印时候都在执行
		//回零
		g_astStFiberMoveStepDriver[iUnitId].xFiberMove_RunHomeStart:=axDoubleClick_FiberMoveBtn1[iUnitId];//当前色回零
		//初始化置位
		axInit_AutoFind[iUnitId]:=FALSE;
	END_IF

	IF(pstStRSV_UnitParam_UnSave^.wState_FiberMove.1)THEN//光纤行走基准位置确认/来自色组按钮
		g_astStFiberMoveStepDriver[iUnitId].xFiberMoveBasePosDone:=pstStRSV_UnitParam_UnSave^.wState_FiberMove.1;
		pstStRSV_UnitParam_UnSave^.wState_FiberMove.1:=0;
	END_IF
	IF(i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xBasePosDoneByOnline) THEN//基准位置确认/来自在线
		FOR iM:=1 TO i_iGrpAxisNum_Pu BY  1 DO
			iK:= i_abyGrpAxisList[iM];
			g_astStFiberMoveStepDriver[iK].xBasePosDoneByOnline:=TRUE;
		END_FOR
		i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xBasePosDoneByOnline:=FALSE;
	END_IF	
END_FOR

//给在线检测发送Ready信号
IF i_pstStSysParam^.astStRSV_GrpParam_UnSave[i_iGrpId].xFlagAutoFindLastPress THEN
	g_xSendResToOnline:=TRUE;
ELSE
	g_xSendResToOnline:=FALSE;
END_IF


