(*@CES
Name=Action_Input_Wr
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ba5e97c1-a029-4aad-9565-cf495e08052b
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*整机的状态参数赋值---------------------------------------------------------------------*)	
Action_Version();
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xCommEn_Tcp:= i_pstStSysParam^.stStSysParam_UnSave.xCommEn_Tcp;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenSocketing:= i_pstStSysParam^.stStSysParam_UnSave.xOpenSocketing;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenSocketDne:= i_pstStSysParam^.stStSysParam_UnSave.xOpenSocketDne;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenSocketFailed:= i_pstStSysParam^.stStSysParam_UnSave.xOpenSocketFailed;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xConnectOk_Tcp:= i_pstStSysParam^.stStSysParam_UnSave.xConnectOk_Tcp;

pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xCommEn_WatchDevice_Tcp:= i_pstStSysParam^.stStSysParam_UnSave.xCommEn_WatchDevice_Tcp;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenSocketing_WatchDevice:= i_pstStSysParam^.stStSysParam_UnSave.xOpenSocketing_WatchDevice;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenSocketDne_WatchDevice:= i_pstStSysParam^.stStSysParam_UnSave.xOpenSocketDne_WatchDevice;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenSocketFailed_WatchDevice:= i_pstStSysParam^.stStSysParam_UnSave.xOpenSocketFailed_WatchDevice;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xConnectOk_WatchDevice_Tcp:= i_pstStSysParam^.stStSysParam_UnSave.xConnectOk_WatchDevice_Tcp;

pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xCommEn_485:= i_pstStSysParam^.stStSysParam_UnSave.xCommEn_485;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenPortDne:= i_pstStSysParam^.stStSysParam_UnSave.xOpenPortDne;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xOpenPortFailed:= i_pstStSysParam^.stStSysParam_UnSave.xOpenPortFailed;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.xCommEn_WatchDevice_485:= i_pstStSysParam^.stStSysParam_UnSave.xCommEn_WatchDevice_485;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.byConnectSts_Tcp:= i_pstStSysParam^.stStSysParam_UnSave.byConnectSts_Tcp;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.byConnectSts_WatchDevice_Tcp:= i_pstStSysParam^.stStSysParam_UnSave.byConnectSts_WatchDevice_Tcp;
pstStParam_Diamonds_Wr_SysSts^.stStStsModbus.byConnectSts_485:= i_pstStSysParam^.stStSysParam_UnSave.byConnectSts_485;

FOR iGrp:=1 TO 2 BY 1 DO		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xCutterOnTop_Uw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCutterOnTop_Uw	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xCutterOnTop_Rw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCutterOnTop_Rw	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Stop					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Stop		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreStart				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreStart	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Ink						:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Ink		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_InkAccing				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_InkAccing	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Tension					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Tension					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_TensionDone				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_TensionDone				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Print					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Print					;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Estop					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Estop					;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AutoAcc					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_AutoAcc					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AutoDec					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_AutoDec					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_ManuAcc					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_ManuAcc					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_ManuDec					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_ManuDec					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Accing					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Accing					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Decing					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Decing					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_EStoping				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_EStoping				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Stoping					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Stoping					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_GotoInking				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_GotoInking				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_InPressing				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_InPressing				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_RollerPressDone			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_RollerPressDone			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_InchRun					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_InchRun					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AllInchRun				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_AllInchRun				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AllPress				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_AllPress				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AllUnpress				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_AllUnpress				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_RollerPressAtLeast1		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_RollerPressAtLeast1		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PrnLen_Alarm_A			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].axFlag_PrnLen_Alarm[1]			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PrnLen_Alarm_B			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].axFlag_PrnLen_Alarm[2]			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PrnLen_Alarm_All		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].axFlag_PrnLen_Alarm[3]		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_LinkageAxisAlarm		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_LinkageAxisAlarm		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_TensionUnfinished		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_TensionUnfinished		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_VelTooHigh				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_VelTooHigh				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PrestartTimeout			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PrestartTimeout			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_KeepAlarming			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_KeepAlarming			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_ArrivedToTargetVel		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_ArrivedToTargetVel		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_FilmAccDecDone			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_FilmAccDecDone			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_IfOf_Ink				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_IfOf_Ink				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_FastStoping				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_FastStoping				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xSlowStopTenEn				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xSlowStopTenEn				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xIsDebugMode_Machine			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xIsDebugMode_Machine			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xReflectSensorLoss_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xReflectSensorLoss_Uw			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFilmTouchRoller_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFilmTouchRoller_Uw			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xSts_PreCutting_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xSts_PreCutting_Uw			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xCutterOnTopFroDebug_Uw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCutterOnTopFroDebug_Uw		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xCurAxisAFroDebug_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCurAxisAFroDebug_Uw			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAlarmBell_Uw					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAlarmBell_Uw					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xIsDebuging_DiaMeasure_Uw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xIsDebuging_DiaMeasure_Uw		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xCancelDebuging_DiaMeasure_Uw	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCancelDebuging_DiaMeasure_Uw	;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xEnCodeErr_Uw					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xEnCodeErr_Uw					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xEnCodeErr_Rw					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xEnCodeErr_Rw					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAForeward_Uw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAForeward_Uw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisBForeward_Uw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisBForeward_Uw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_DiamCalc_ing_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_DiamCalc_ing_Uw			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_DiamCalc_end_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_DiamCalc_end_Uw			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_DiamMeasure_end_Uw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_DiamMeasure_end_Uw		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreDrv_ing_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreDrv_ing_Uw			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreDrv_end_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreDrv_end_Uw			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Cut_ing_Uw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Cut_ing_Uw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Cut_end_Uw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Cut_end_Uw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_VolDiamAlarm_Uw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_VolDiamAlarm_Uw			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xStationOnline_AxisA_Uw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xStationOnline_AxisA_Uw		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xStationOnline_AxisB_Uw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xStationOnline_AxisB_Uw		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AutoMaticCutting_Uw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_AutoMaticCutting_Uw		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xSts_PreCutting_Rw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xSts_PreCutting_Rw			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xCutterOnTopFroDebug_Rw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCutterOnTopFroDebug_Rw		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xCurAxisAFroDebug_Rw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xCurAxisAFroDebug_Rw			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].x6InchFroDebug_Rw       		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].x6InchFroDebug_Rw       		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAlarmBell_Rw					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAlarmBell_Rw					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAForeward_Rw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAForeward_Rw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisBForeward_Rw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisBForeward_Rw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_6Inch_Rw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_6Inch_Rw				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreDrv_ing_Rw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreDrv_ing_Rw			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreDrv_end_Rw			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreDrv_end_Rw			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Cut_ing_Rw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Cut_ing_Rw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Cut_end_Rw				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Cut_end_Rw				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xStationOnline_AxisA_Rw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xStationOnline_AxisA_Rw		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xStationOnline_AxisB_Rw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xStationOnline_AxisB_Rw		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AutoMaticCutting_rw		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_AutoMaticCutting_rw		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xStationOnline_If				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xStationOnline_If				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xRollerSts_If					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xRollerSts_If					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xRunEn_If						:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xRunEn_If						;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xInching_If					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xInching_If					;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xStationOnline_Of				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xStationOnline_Of				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xRollerSts_Of					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xRollerSts_Of					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xRunEn_Of						:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xRunEn_Of						;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xInching_Of					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xInching_Of					;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xSts_HorzPreRegister			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xSts_HorzPreRegister			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_HorzPreRegister_All_end	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_HorzPreRegister_All_end	;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Home					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Home					;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Home_ing				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Home_ing				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_Home_end				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_Home_end				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_ConfirmPreRegHomePos	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_ConfirmPreRegHomePos	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_ConfirmPreRegHomePos_ing:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_ConfirmPreRegHomePos_ing;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_ConfirmPreRegHomePos_end:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_ConfirmPreRegHomePos_end;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreRegister				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreRegister				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreRegister_ing			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreRegister_ing			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PreRegister_end			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PreRegister_end			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PhaseRestore			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PhaseRestore_ing		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore_ing		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PhaseRestore_end		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xFlag_PhaseRestore_end		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_CENTRAL			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_CENTRAL			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_CENTRAL			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_CENTRAL			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_CENTRAL	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_CENTRAL	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_CENTRAL2			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_CENTRAL2			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_CENTRAL2			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_CENTRAL2			;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_CENTRAL2	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_CENTRAL2	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_IF				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_IF				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_IF					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_IF					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_IF			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_IF			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_OF				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_OF				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_OF					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_OF					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_OF			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_OF			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_UW_A				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_UW_A				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_UW_A				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_UW_A				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_UW_A		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_UW_A		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_UW_B				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_UW_B				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_UW_B				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_UW_B				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_UW_B		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_UW_B		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_RW_A				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_RW_A				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_RW_A				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_RW_A				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_RW_A		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_RW_A		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xNetOffline_RW_B				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xNetOffline_RW_B				;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xAxisAlarm_RW_B				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xAxisAlarm_RW_B				;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPosDeviationAlarm_RW_B		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPosDeviationAlarm_RW_B		;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xPrintInching					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xPrintInching			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xTapPosition_Breaking			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xTapPosition_Breaking	;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xTapPosition_UniformInk		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xTapPosition_UniformInk	;		
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xTapPosition_Printing			:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xTapPosition_Printing	;	
(*2025.9.18.163647*)	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PressDn_If:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xRollerSts_If;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_PressDn_Of:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xRollerSts_Of;
	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xLinkage_If:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xLinkage_If;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xLinkage_Of:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].xLinkage_Of;
//2025.11.14.152402增加收放料调试中标志
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AxisA_DebugRunning_Uw:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.3;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AxisB_DebugRunning_Uw:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.6;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AxisA_DebugRunning_Rw:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.11;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_GrpFlag[iGrp].xFlag_AxisB_DebugRunning_Rw:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].wAxisDebug_UwRw.14;
	pstStParam_Diamonds_Wr_SysSts^.arDebugCurVelmpmAxisA_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisA_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arDebugCurVelmpmAxisB_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisB_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arDebugCurVelmpmAxisA_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisA_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arDebugCurVelmpmAxisB_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisB_Rw;
	
	//2026.5.19.111734 by liu.yt 处理异站编码器内容的通讯变量
	pstStParam_Diamonds_Wr_SysSts^.auiSetVirtualEncCfgCnt[iGrp]:= g_auiSetVirtualEncCfgCnt[iGrp];
	pstStParam_Diamonds_Wr_SysSts^.adwVirtualAcrossEnSts[iGrp]:= g_adwVirtualAcrossEnSts[iGrp];
	pstStParam_Diamonds_Wr_SysSts^.aiSetVirtualEnc_ErrCode[iGrp]:= g_aiSetVirtualEnc_ErrCode[iGrp];
	pstStParam_Diamonds_Wr_SysSts^.aiSetVirtualEnc_ErrCode[iGrp]:= g_aiSetVirtualEnc_ErrCode[iGrp];
	pstStParam_Diamonds_Wr_SysSts^.aiSetVirtualEncCfgRtn[iGrp]:= g_aiSetVirtualEncCfgRtn[iGrp];
	pstStParam_Diamonds_Wr_SysSts^.aiVirtualEnc_AxisId_Src[iGrp]:= g_aiVirtualEnc_AxisId_Src[iGrp];
	pstStParam_Diamonds_Wr_SysSts^.aiVirtualEnc_AxisId_Des[iGrp]:= g_aiVirtualEnc_AxisId_Des[iGrp];
	
	
	pstStParam_Diamonds_Wr_SysSts^.aiPromptMsg[iGrp]				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iPromptMsg;
	pstStParam_Diamonds_Wr_SysSts^.aiAlarm_TypeId[iGrp]				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iAlarm_TypeId;//报警轴的类型
	pstStParam_Diamonds_Wr_SysSts^.aiAlarm_UnitId[iGrp]				:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iAlarm_UnitId;//报警轴位置
	pstStParam_Diamonds_Wr_SysSts^.aiIdGSE[iGrp]					:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iIdGSE;
	pstStParam_Diamonds_Wr_SysSts^.aiTimeSec_AccDec_AllTheWay[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iTimeSec_AccDec_AllTheWay;(* 全程加减速所需要的秒 *)
	pstStParam_Diamonds_Wr_SysSts^.arAccDecTime_ThisTime[iGrp]		:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAccDecTime_ThisTime;(* 本次加减速时间/单位:s *)
	(*pstStParam_Diamonds_Wr_SysSts^.arStdVol_Vol_Axis_Hmi	:= ;*)(*暂有问题*)
	(*pstStParam_Diamonds_Wr_SysSts^.arStdVol_Coef_Axis_Hmi	:= ;*)(*暂有问题*)
	pstStParam_Diamonds_Wr_SysSts^.arVel_Film[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVel_Film;
	pstStParam_Diamonds_Wr_SysSts^.aiSid_AxisA_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iSid_AxisA_Uw;
	pstStParam_Diamonds_Wr_SysSts^.aiSid_AxisB_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iSid_AxisB_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arKpid_Current_Uw[iGrp,1]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].arKpid_Current_Uw[1];
	pstStParam_Diamonds_Wr_SysSts^.arKpid_Current_Uw[iGrp,2]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].arKpid_Current_Uw[2];
	pstStParam_Diamonds_Wr_SysSts^.arKpid_Current_Uw[iGrp,3]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].arKpid_Current_Uw[3];
//	pstStParam_Diamonds_Wr_SysSts^.astStTimeSet_DnCut_UpCut_Uw_Hmi[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].stStTimeSet_DnCut_UpCut_Uw_Hmi;
	pstStParam_Diamonds_Wr_SysSts^.arVel_Cur_HMI[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVel_Cur_HMI;
	pstStParam_Diamonds_Wr_SysSts^.arAI_HMI_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAI_HMI_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arAI_DiamMeasure_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAI_DiamMeasure_HMI_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arKpid_Current_Rw[iGrp,1]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].arKpid_Current_Rw[1];
	pstStParam_Diamonds_Wr_SysSts^.arKpid_Current_Rw[iGrp,2]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].arKpid_Current_Rw[2];
	pstStParam_Diamonds_Wr_SysSts^.arKpid_Current_Rw[iGrp,3]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].arKpid_Current_Rw[3];
	pstStParam_Diamonds_Wr_SysSts^.arDiam_NewVol_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDiam_NewVol_Uw;
	pstStParam_Diamonds_Wr_SysSts^.adwAbsEncSinglePos_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAbsEncSinglePos_Uw;
	pstStParam_Diamonds_Wr_SysSts^.adwAbsEncSPos_Cur_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAbsEncSPos_Cur_Uw;
//	pstStParam_Diamonds_Wr_SysSts^.astStTimeSet_DnCut_UpCut_Rw_Hmi[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].stStTimeSet_DnCut_UpCut_Rw_Hmi;
	pstStParam_Diamonds_Wr_SysSts^.arAIByAbsEnc_Cur_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIByAbsEnc_Cur_Uw;
	pstStParam_Diamonds_Wr_SysSts^.abyIsDebug_DiaMeasureArea_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].byIsDebug_DiaMeasureArea_Uw;
	(*pstStParam_Diamonds_Wr_SysSts^.abyAxisDebugBit_Uw[iGrp]:可能是读写参数*)
	pstStParam_Diamonds_Wr_SysSts^.awUwRwAxisProf[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].wUwRwAxisProf;
	(*pstStParam_Diamonds_Wr_SysSts^.abyAxisDebugBit_Uw_2[iGrp]:可能是读写参数*)
	pstStParam_Diamonds_Wr_SysSts^.arPi_Value_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rPi_Value_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arForwardStep_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rForwardStep_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arAxisAVelRPM_Cur_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAxisAVelRPM_Cur_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arAxisBVelRPM_Cur_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAxisBVelRPM_Cur_Uw;
(*上面这两个换了变量名*)
	pstStParam_Diamonds_Wr_SysSts^.aiSid_AxisA_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iSid_AxisA_Rw;
	pstStParam_Diamonds_Wr_SysSts^.aiSid_AxisB_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iSid_AxisB_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arAI_HMI_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAI_HMI_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arDiam_NewVol_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDiam_NewVol_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arTaper_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rTaper_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arDebugCurVelmpmAxisA_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rDebugCurVelmpmAxisA_Rw;
(*缺少收B和放AB的调试速度显示*)
	pstStParam_Diamonds_Wr_SysSts^.adwAbsEncSinglePos_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAbsEncSinglePos_Rw;
	pstStParam_Diamonds_Wr_SysSts^.adwAbsEncSPos_Cur_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAbsEncSPos_Cur_Rw;
	pstStParam_Diamonds_Wr_SysSts^.adwAbsEnCodeResolution_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].dwAbsEnCodeResolution_Rw;
	(*pstStParam_Diamonds_Wr_SysSts^.abyAxisDebugBit_Rw[iGrp]:可能是读写参数*)
	pstStParam_Diamonds_Wr_SysSts^.arPi_Value_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rPi_Value_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arForwardStep_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rForwardStep_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arAxisAVelRPM_Cur_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAxisAVelRPM_Cur_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arAxisBVelRPM_Cur_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAxisBVelRPM_Cur_Rw;

	pstStParam_Diamonds_Wr_SysSts^.aiSid_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iSid_If;
	pstStParam_Diamonds_Wr_SysSts^.arAI_HMI_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAI_HMI_If;
	pstStParam_Diamonds_Wr_SysSts^.arVel_Cur_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVel_Cur_If;
	pstStParam_Diamonds_Wr_SysSts^.arPi_Value_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rPi_Value_If;
	pstStParam_Diamonds_Wr_SysSts^.arForwardStep_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rForwardStep_If;
	pstStParam_Diamonds_Wr_SysSts^.arUsingGirth_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rUsingGirth_If;
	pstStParam_Diamonds_Wr_SysSts^.aiSid_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].iSid_Of;
	pstStParam_Diamonds_Wr_SysSts^.arAI_HMI_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAI_HMI_Of;
	pstStParam_Diamonds_Wr_SysSts^.arVel_Cur_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVel_Cur_Of;
	pstStParam_Diamonds_Wr_SysSts^.arPi_Value_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rPi_Value_Of;
	pstStParam_Diamonds_Wr_SysSts^.arForwardStep_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rForwardStep_Of;
	pstStParam_Diamonds_Wr_SysSts^.arUsingGirth_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rUsingGirth_Of;


	pstStParam_Diamonds_Wr_SysSts^.arTaper_Cur_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rTaper_Cur_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arTaper_Cur_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rTaper_Cur_If;
	pstStParam_Diamonds_Wr_SysSts^.arTaper_Cur_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rTaper_Cur_Of;
	pstStParam_Diamonds_Wr_SysSts^.arVolt_CalcDiam_Used_Watch[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVolt_CalcDiam_Used_Watch;
	pstStParam_Diamonds_Wr_SysSts^.arAO_Inverter_Uw_AxisA[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAO_Inverter_Uw_AxisA;
	pstStParam_Diamonds_Wr_SysSts^.arAO_Inverter_Uw_AxisB[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAO_Inverter_Uw_AxisB;
	pstStParam_Diamonds_Wr_SysSts^.arAO_Inverter_Rw_AxisA[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAO_Inverter_Rw_AxisA;
	pstStParam_Diamonds_Wr_SysSts^.arAO_Inverter_Rw_AxisB[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAO_Inverter_Rw_AxisB;
	
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_CENTRAL[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_CENTRAL;
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_CENTRAL2[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_CENTRAL2;
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_If[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_If;
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_Of;
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_Uw_A[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_Uw_A;
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_Uw_B[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_Uw_B;
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_Rw_A[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_Rw_A;
	pstStParam_Diamonds_Wr_SysSts^.adwAlarmDetail_Rw_B[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].dwAlarmDetail_Rw_B;

	pstStParam_Diamonds_Wr_SysSts^.adwPrnLen_AmountTo[iGrp]:= LREAL_TO_DWORD(i_pstStSysParam^.astStGrpParam_Save[iGrp].lrPrnLen_AmountTo);
	pstStParam_Diamonds_Wr_SysSts^.adwPrnLen[iGrp,1]:= LREAL_TO_DWORD(i_pstStSysParam^.astStGrpParam_Save[iGrp].alrPrnLen[1]);
	pstStParam_Diamonds_Wr_SysSts^.adwPrnLen[iGrp,2]:= LREAL_TO_DWORD(i_pstStSysParam^.astStGrpParam_Save[iGrp].alrPrnLen[2]);
	pstStParam_Diamonds_Wr_SysSts^.adwPrnLen[iGrp,3]:= LREAL_TO_DWORD(i_pstStSysParam^.astStGrpParam_Save[iGrp].alrPrnLen[3]);
(*2025.9.15.204336
	pstStParam_Diamonds_Wr_SysSts^.abyAIType_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_Uw;
	pstStParam_Diamonds_Wr_SysSts^.abyAIType_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_Rw;
	pstStParam_Diamonds_Wr_SysSts^.abyAIType_If[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_If;
	pstStParam_Diamonds_Wr_SysSts^.abyAIType_Of[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].byAIType_Of;
*)
	//2026.1.14.112048 | bai.zy | 增加秦华第二牵引的当前张力通讯
	pstStParam_Diamonds_Wr_SysSts^.arCur_PressureValue[iGrp]:= g_lrCur_PressureValue;

	pstStParam_Diamonds_Wr_SysSts^.arValue_DiaMeasure[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rValue_DiaMeasure;
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_Uw[iGrp,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_Uw[0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_Uw[iGrp,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_Uw[1];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_Uw[iGrp,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_Uw[0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_Uw[iGrp,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_Uw[1];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_MinDiam_Uw[iGrp,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_MinDiam_Uw[0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_MinDiam_Uw[iGrp,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_MinDiam_Uw[1];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_MinDiam_Uw[iGrp,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_MinDiam_Uw[0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_MinDiam_Uw[iGrp,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_MinDiam_Uw[1];

	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_Rw[iGrp,0,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_Rw[0,0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_Rw[iGrp,0,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_Rw[0,1];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_Rw[iGrp,1,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_Rw[1,0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisALocation_Rw[iGrp,1,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisALocation_Rw[1,1];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_Rw[iGrp,0,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_Rw[0,0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_Rw[iGrp,0,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_Rw[0,1];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_Rw[iGrp,1,0]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_Rw[1,0];
	pstStParam_Diamonds_Wr_SysSts^.adwEnc_AxisBLocation_Rw[iGrp,1,1]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].adwEnc_AxisBLocation_Rw[1,1];

	pstStParam_Diamonds_Wr_SysSts^.arDiamCurAxis_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiamCurAxis_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arDiamCurAxis_Rw[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].rDiamCurAxis_Rw;
	(*pstStParam_Diamonds_Wr_SysSts^.arStdVol_Volt_AxisA||上下裁？*)	
	(*pstStParam_Diamonds_Wr_SysSts^.arStdVol_Volt_AxisB||上下裁？*)	
	(*pstStParam_Diamonds_Wr_SysSts^.byNum_StationList_Valid:= ;考虑从哪里赋值*)
	Action_Input_Wr_IOTest_MainDIAI();

	(*2025.10.24.134910增加变量通讯*)
	pstStParam_Diamonds_Wr_SysSts^.arVel_Uw[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVelRPM_Cur_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arVel_Rw[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVelRPM_Cur_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arVel_If[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVel_Cur_If;	
	pstStParam_Diamonds_Wr_SysSts^.arVel_Of[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rVel_Cur_Of;
	pstStParam_Diamonds_Wr_SysSts^.arAIMax_Uw[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMax_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arAIMin_Uw[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMin_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arAIMax_Rw[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMax_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arAIMin_Rw[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMin_Rw;
	pstStParam_Diamonds_Wr_SysSts^.arAIMax_If[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMax_If;
	pstStParam_Diamonds_Wr_SysSts^.arAIMin_If[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMin_If;
	pstStParam_Diamonds_Wr_SysSts^.arAIMax_Of[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMax_Of;
	pstStParam_Diamonds_Wr_SysSts^.arAIMin_Of[iGrp]	:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rAIMin_Of;
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiSendDataCnt_Tcp),ADR(g_auiSendDataCnt_Tcp),SIZEOF(g_auiSendDataCnt_Tcp));
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiRecvDataCnt_Tcp),ADR(g_auiRecvDataCnt_Tcp),SIZEOF(g_auiRecvDataCnt_Tcp));
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiRecvErrDataCnt_Tcp),ADR(g_auiRecvErrDataCnt_Tcp),SIZEOF(g_auiRecvErrDataCnt_Tcp));
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiTimeOutDataCnt_Tcp),ADR(g_auiTimeOutDataCnt_Tcp),SIZEOF(g_auiTimeOutDataCnt_Tcp));
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiSendDataCnt_485),ADR(g_auiSendDataCnt_485),SIZEOF(g_auiSendDataCnt_485));
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiRecvDataCnt_485),ADR(g_auiRecvDataCnt_485),SIZEOF(g_auiRecvDataCnt_485));
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiRecvErrDataCnt_485),ADR(g_auiRecvErrDataCnt_485),SIZEOF(g_auiRecvErrDataCnt_485));
	SysMemCpy(ADR(pstStParam_Diamonds_Wr_SysSts^.auiTimeOutDataCnt_485),ADR(g_auiTimeOutDataCnt_485),SIZEOF(g_auiTimeOutDataCnt_485));
	pstStParam_Diamonds_Wr_SysSts^.abyPseudoRandomRoundTimes_Cur[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].byPseudoRandomRoundTimes_Cur;
	pstStParam_Diamonds_Wr_SysSts^.arPseudoRandomRoundAmplitude_Cur[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rPseudoRandomRoundAmplitude_Cur;
	//遗漏补充
	pstStParam_Diamonds_Wr_SysSts^.adwAxisAabsPos_0Rad_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].dwAxisAabsPos_0Rad_Uw;
	pstStParam_Diamonds_Wr_SysSts^.adwAxisBabsPos_0Rad_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_Save[iGrp].dwAxisBabsPos_0Rad_Uw;
	pstStParam_Diamonds_Wr_SysSts^.arTowerThetaCur_Uw[iGrp]:= i_pstStSysParam^.astStGrpParam_UnSave[iGrp].rTowerThetaCur_Uw;
	
		
	
END_FOR

FOR iUnitId:= 1 TO MAX_UNIT_NUM BY 1 DO			
(*柔印相关部分后续继续赋值2025.8.6.114235-----------------------------------------------*)	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rPV_UnitTemCtl		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rPV_UnitTemCtl				;(* 色组温度控制实时值 *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitExhaust_CurrRD:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitExhaust_CurrRD		;(* 排风当前回读频率/pdu上行给主站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitExhaust_CurrWR:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitExhaust_CurrWR		;(* 排风当前写入频率/pdu下行给从站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitHotWind2_CurrRD:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitHotWind2_CurrRD		;(* 热风当前回读频率/pdu上行给主站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitHotWind2_CurrWR:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitHotWind2_CurrWR		;(* 热风当前写入频率/pdu下行给从站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitHotWind_CurrRD:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitHotWind_CurrRD		;(* 热风当前回读频率/pdu上行给主站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitHotWind_CurrWR:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitHotWind_CurrWR		;(* 热风当前写入频率/pdu下行给从站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitScraper_CurrRD:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitScraper_CurrRD		;(* 刮刀当前回读频率/pdu上行给主站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitScraper_CurrWR:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitScraper_CurrWR		;(* 刮刀当前写入频率/pdu下行给从站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitInkRoller_CurrRD:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitInkRoller_CurrRD;(* 递墨辊当前回读频率/pdu上行给主站/ *)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rHz_UnitInkRoller_CurrWR:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rHz_UnitInkRoller_CurrWR;(* 递墨辊当前写入频率/pdu下行给从站/ *)	
	
	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xLinkage							:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage							;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xFlag_RollerDn_BottomRoller		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_RollerDn_BottomRoller		;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xFlag_RollerDn_PrnRoller			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_RollerDn_PrnRoller			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xFlag_RollerDn_NetRoller			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_RollerDn_NetRoller			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xFlag_HorzPreRegister_ing		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xFlag_HorzPreRegister_end		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisInching						:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching						;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisInching_Net					:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisInching_Net					;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_Horz					:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_Horz					;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_Horz					:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Horz					;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_Horz			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_Horz			;						
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_PrnRoller			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_PrnRoller				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_PrnRoller				:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_PrnRoller				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_PrnRoller		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_PrnRoller		;					
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_NetRoller			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_NetRoller				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_NetRoller				:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_NetRoller				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_NetRoller		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_NetRoller		;					 
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_BottomRoller			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_BottomRoller			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_BottomRoller			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_BottomRoller			;	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_BottomRoller	:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_BottomRoller	;						 
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_Prn_Pressure_M		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_Prn_Pressure_M				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_Prn_Pressure_M		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Prn_Pressure_M			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_Prn_Pressure_M:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_Prn_Pressure_M	;					 
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_Prn_Pressure_G		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_Prn_Pressure_G				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_Prn_Pressure_G		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Prn_Pressure_G			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_Prn_Pressure_G:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_Prn_Pressure_G	;					  
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_Net_Pressure_M		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_Net_Pressure_M				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_Net_Pressure_M		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Net_Pressure_M			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_Net_Pressure_M:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_Net_Pressure_M	;					
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_Net_Pressure_G		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_Net_Pressure_G				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_Net_Pressure_G		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Net_Pressure_G			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_Net_Pressure_G:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_Net_Pressure_G	;					  
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_Str_Pressure_M		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_Str_Pressure_M				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_Str_Pressure_M		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Str_Pressure_M			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_Str_Pressure_M:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_Str_Pressure_M	;					  
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_Str_Pressure_G		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_Str_Pressure_G				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_Str_Pressure_G		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_Str_Pressure_G			;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_Str_Pressure_G:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_Str_Pressure_G	;					
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xNetOffline_PHOTOCELL			:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xNetOffline_PHOTOCELL				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xAxisAlarm_PHOTOCELL				:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xAxisAlarm_PHOTOCELL				;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xPosDeviationAlarm_PHOTOCELL		:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xPosDeviationAlarm_PHOTOCELL		;
(*2025.9.18.163558|增加*)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].stStSts_UnitFlag.xFlag_PressDn:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_PressDn;
	

	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].byColorIdCurrent:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byColorIdCurrent;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].byColorIdFollow:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].byFollowColorId;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].byArcSts:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byArcSts;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wSts_HorzManuPreReg:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSts_HorzManuPreReg;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].iPos_HorzManuPreReg:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPos_HorzManuPreReg;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wSTS_UnitExhaust:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSTS_UnitExhaust;
	(**2025.8.20.162058重新分配了IO测试区域
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wUnit_input_I:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wUnit_input_I;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wUnit_input_II:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wUnit_input_II;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wUnit_input_III:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wUnit_input_III;
	*)
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wSTS_UnitHotWind_2:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSTS_UnitHotWind_2;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wSTS_UnitHotWind:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSTS_UnitHotWind;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wSTS_UnitScraper:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSTS_UnitScraper;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wSTS_UnitInkRoller:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSTS_UnitInkRoller;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wSTS_UnitTemCtl:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSTS_UnitTemCtl;
	
	
	//2025.11.07.162949 | bai.zy | 增加虚拟码盘，暂时先放在这里	
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].wVirtual:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt;
	//计算料长
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rPreReg_Length_V:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].lrPreReg_Length_V;

	//2026.1.9.103419增加一些变量
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].rLength_Band:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rLength_Band;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].iTriggerCnt:= g_astStLatch[iUnitId].iTriggerCnt;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].udiTriggerEncErr:= g_astStLatch[iUnitId].udiTriggerEncErr;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].udiTriggerTimeErr:= g_astStLatch[iUnitId].udiTriggerTimeErr;
	
	//z增加界面柔印相关内容2026.2.2.155241|
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_dn_PrnRoller_Pressure_M:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_dn_PrnRoller_Pressure_M);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_dn_PrnRoller_Pressure_G:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_dn_PrnRoller_Pressure_G);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_up_PrnRoller_Pressure_M:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_up_PrnRoller_Pressure_M);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_up_PrnRoller_Pressure_G:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_up_PrnRoller_Pressure_G);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_load_unload_PrnRoller_Pressure_M:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_load_unload_PrnRoller_Pressure_M);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_load_unload_PrnRoller_Pressure_G:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_load_unload_PrnRoller_Pressure_G);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rPos_PrnRoller_Pressure_M := 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rPos_PrnRoller_Pressure_M;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rPos_PrnRoller_Pressure_G:= 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rPos_PrnRoller_Pressure_G;


	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_dn_NetRoller_Pressure_M:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_dn_NetRoller_Pressure_M);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_dn_NetRoller_Pressure_G:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_dn_NetRoller_Pressure_G);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_up_NetRoller_Pressure_M:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_up_NetRoller_Pressure_M);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_press_up_NetRoller_Pressure_G:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_press_up_NetRoller_Pressure_G);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_load_unload_NetRoller_Pressure_M:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_load_unload_NetRoller_Pressure_M);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].diPos_load_unload_NetRoller_Pressure_G:= 
					REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_Save[iUnitId].rPos_load_unload_NetRoller_Pressure_G);
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rPos_NetRoller_Pressure_M := 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rPos_NetRoller_Pressure_M;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].rPos_NetRoller_Pressure_G:= 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rPos_NetRoller_Pressure_G;
					
					
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].rParallelError_Prn_MM:= 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rParallelError_Prn_MM;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].rParallelError_Net_MM:= 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rParallelError_Net_MM;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].rParallelError_Str_MM:= 
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rParallelError_Str_MM;
					
					
					
//这两个变量放只写区域，不需要双向2026.4.25.142438
//	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rKp_MolCal                     	:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rKp_MolCal ;
//	i_pstStParam_Diamonds_WrRd^.astStWrRd_UnitParam[iUnitId].rKi_MolCal                     	:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rKi_MolCal ;
//2026.4.25.142452结束
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].rKp_MolCal:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rKp_MolCal ;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].rKi_MolCal:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].rKi_MolCal ;
					
//2026.4.6.133333通讯一些变量全自动套印状态
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].wCommFromDubheFindSignal:= 
					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].wCommFromDubheFindSignal;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].iStep_AutoAdjust:= 
					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].iStep_AutoAdjust;
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].iError_Msg:= 
					i_pstStSysParam^.astStRSV_UnitParam_UnSave[iUnitId].iError_Msg;
	
	//增加色组版辊虚拟码盘状态--2字节
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam[iUnitId].wVirTual_Sts:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Sts;		
	//2026.06.30.101334
	pstStParam_Diamonds_Wr_SysSts^.astStSts_UnitParam_2[iUnitId].diPos_Horz := LREAL_TO_DINT(g_alrTrap_EncPos[iUnitId]);			
END_FOR
Action_Input_Wr_IOTest_AxisDIAI();

(*整机的状态参数赋值---------------------------------------------------------------------*)	

(*粗采样波形赋值2025.8.6.114309------------------------*)
pstStParam_Diamonds_Wr_RdSam^.byAxisId_HMI_RdSamData:= INT_TO_BYTE(i_pstStSysParam^.stStSysParam_Save.iUid);		
iUnitId:= i_pstStSysParam^.stStSysParam_Save.iUid;
IF iUnitId>= 0 AND iUnitId<=MAX_UNIT_NUM THEN 
	IF abyLastIndex[iUnitId]<> i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].byIndex THEN

		pstStParam_Diamonds_Wr_RdSam^.byGrpId_HMI_RdSamData:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].byGrpId;
		pstStParam_Diamonds_Wr_RdSam^.byCurSignal_Main:= i_pstStSysParam^.astStUnitParam_Save[iUnitId].bySignalSelect;
		byCurSignal_RGB:=0;

		IF pstStParam_Diamonds_Wr_RdSam^.byCurSignal_Main.0 THEN
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TA[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T1_R[iN];
				iJ:= iJ+1;
			END_FOR	
		ELSIF pstStParam_Diamonds_Wr_RdSam^.byCurSignal_Main.1 THEN
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TA[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T1_G[iN];
				iJ:= iJ+1;
			END_FOR		
		ELSIF pstStParam_Diamonds_Wr_RdSam^.byCurSignal_Main.2 THEN
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TA[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T1_B[iN];
				iJ:= iJ+1;
			END_FOR	 	
		ELSE
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TA[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T1_R[iN];
				iJ:= iJ+1;
			END_FOR				
		END_IF

		IF pstStParam_Diamonds_Wr_RdSam^.byCurSignal_Main.4 THEN
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TB[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T2_R[iN];
				iJ:= iJ+1;
			END_FOR	
		ELSIF pstStParam_Diamonds_Wr_RdSam^.byCurSignal_Main.5 THEN
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TB[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T2_G[iN];
				iJ:= iJ+1;
			END_FOR		
		ELSIF pstStParam_Diamonds_Wr_RdSam^.byCurSignal_Main.6 THEN
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TB[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T2_B[iN];
				iJ:= iJ+1;
			END_FOR	 	
		ELSE
			iJ:=1;
			FOR iN:=1 TO MAX_ROUNDSAMPLE_NUM BY 4 DO
				pstStParam_Diamonds_Wr_RdSam^.abyData_RoundSample_TB[iJ]:= 
					i_pstStSysParam^.stStSysParam_UnSave.abyData_T2_R[iN];
				iJ:= iJ+1;
			END_FOR				
		END_IF
	END_IF
END_IF

(*误差队列完全发过去？2025.8.6.164302*)
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
	IF abyLastIndex[iN]<> i_pstStSysParam^.astStUnitParam_UnSave[iN].byIndex THEN
		pastStParam_Diamonds_Wr_Err^[iN].byIndex:= i_pstStSysParam^.astStUnitParam_UnSave[iN].byIndex;
		SysMemCpy(
			ADR(pastStParam_Diamonds_Wr_Err^[iN].aiError_V_History),
			ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN].aiError_V_History),
			SIZEOF(pastStParam_Diamonds_Wr_Err^[iN].aiError_V_History));
		SysMemCpy(
			ADR(pastStParam_Diamonds_Wr_Err^[iN].aiError_H_History),
			ADR(i_pstStSysParam^.astStUnitParam_UnSave[iN].aiError_H_History),
			SIZEOF(pastStParam_Diamonds_Wr_Err^[iN].aiError_H_History));		
	END_IF

END_FOR
FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO		
	abyLastIndex[iN]:= i_pstStSysParam^.astStUnitParam_UnSave[iN].byIndex ;
END_FOR	
(*2025.10.28.104430||运动状态*)
(*由所有站号*)
iNumIndex:= 0;
FOR iN:= 1 TO g_stStSysStationInf.byStationNum BY 1 DO
	KS_GetAxisIdForMotByStation_V2(
		i_iStationId:= g_stStSysStationInf.astStationInf[iN].iStationId,
		i_piAxisId:= ADR(iAxisId_T), 
		i_piTypeId:= ADR(iTypeId_T), 
		i_piUnitId:= ADR(iUnitId_T), 
		i_piCoreId:= ADR(iCoreId_T), 
		i_piGroupId:= ADR(iGroupId_T), 
		i_piAdjAxisId:= ADR(iAdjAxisId_T), 
		i_pstStSysStationInf:= ADR(g_stStSysStationInf));

	IF iTypeId_T<>TYPE_NULL THEN
		iNumIndex:= iNumIndex+1;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byStationId			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byUnitId			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byTypeId			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byAxisId			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].lrPos_Prf			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].lrPos_Enc			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rVel_Prf			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rVel_Enc			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwMotionSts			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwErr_Driver		:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].iErr_NetPort_a		:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].iErr_NetPort_b		:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].uiVirtual_Cnt		:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].wVirtual_Sts		:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].uiBrake_Cnt			:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rCurrent_Driver		:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwCurAxisEnc_Lock	:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwCurAxisTime_Lock	:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rTemperaTure		:= 0;
		pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rVdc				:= 0;
		IF iAdjAxisId_T<>-1 THEN//有调整轴
			iNumIndex:= iNumIndex+1;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byStationId			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byUnitId			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byTypeId			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].byAxisId			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].lrPos_Prf			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].lrPos_Enc			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rVel_Prf			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rVel_Enc			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwMotionSts			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwErr_Driver		:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].iErr_NetPort_a		:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].iErr_NetPort_b		:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].uiVirtual_Cnt		:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].wVirtual_Sts		:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].uiBrake_Cnt			:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rCurrent_Driver		:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwCurAxisEnc_Lock	:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].dwCurAxisTime_Lock	:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rTemperaTure		:= 0;
			pastStParam_Diamonds_Wr_RunSts^[iNumIndex].rVdc				:= 0;
		END_IF
	END_IF 	
END_FOR

