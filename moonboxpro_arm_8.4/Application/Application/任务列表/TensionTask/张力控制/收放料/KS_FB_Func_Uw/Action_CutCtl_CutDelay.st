(*@CES
Name=Action_CutCtl_CutDelay
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ae44ec32-e544-4460-a9a6-8e284dc4b5bc
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*---------------------------2017-08-19 08:57:54
/.接料
.----------------------------------------------*)
(*放料端*)

//2026.4.12.140817
IF fbRTrig_Cut.Q THEN
	i_pxReq_Cut_Uw^:= TRUE;
END_IF
//结束2026.4.12.140823

(*------------------------------------------------------------*)
//2026.05.24.210851|增加一个裁切完成信号，原信号是输出信号，现需要改为输入
xFlag_Cut_end_Out:= i_pxFlag_Cut_end_Uw_UseInOtherPrg^;
IF xFlag_Cut_End_Out THEN
	xCutAxisA_In_Out:= NOT xCutAxisA_In_Out;
	i_pxFlag_Cut_end_Uw_UseInOtherPrg^:= FALSE;	
END_IF

	
(**2026.4.12.145214将整个裁切输出放到主任务执行了|niu.j
(*提取弧面io信号2018.10.6.154255 by liu.yt*)
IF io_xCutOnTop THEN
	IF xCutAxisA_In_Out THEN
		xSensor_Reflex:=i_pstStEvtReq^.xEvt_Sensor_Reflex_Up_AxisB;
	ELSE
		xSensor_Reflex:=i_pstStEvtReq^.xEvt_Sensor_Reflex_Up_AxisA;
	END_IF
ELSE
	IF xCutAxisA_In_Out THEN
		xSensor_Reflex:=i_pstStEvtReq^.xEvt_Sensor_Reflex_Dn_AxisB;
	ELSE
		xSensor_Reflex:=i_pstStEvtReq^.xEvt_Sensor_Reflex_Dn_AxisA;
	END_IF
END_IF

(*2021.10.14.142525 增加了接料准备的调试逻辑*)
xCutCtlEn:=xFlag_PreDrv_end_Out AND o_xSts_PreCutting;
rDiam_NewVol_Use:=o_rDiam_NewVol;
rVel_Predrv_Use:= rVel_Predrv_Out;
IF xAxisDebugEn_In_Out THEN(*放料调试*)
	(*2022.6.18.124949 更新了裁切功能块使能条件|确保到达对射电眼位置*)
	xCutCtlEn:=xLamp_PreDrive_Debug AND xSts_Sensor1Ok AND o_xSts_PreCutting;(*预驱同步了就使能*)
	IF xCutAxisA_In_Out THEN(*当前轴为a|取b的值*)
		rDiam_NewVol_Use:=LREAL_TO_REAL(INT_TO_LREAL(iDebugGirthmm_AxisB_In)/gc_lrPi);
		rVel_Predrv_Use:=rDebugCurVelmpmAxisB_In_Out;
	ELSE(*当前轴为b|取a的值*)
		rDiam_NewVol_Use:=LREAL_TO_REAL(INT_TO_LREAL(iDebugGirthmm_AxisA_In)/gc_lrPi);
		rVel_Predrv_Use:=rDebugCurVelmpmAxisA_In_Out;
	END_IF
END_IF

fbKS_FB_CutDelay_CTL_Uw(
	i_xEn:=xCutCtlEn,
	i_xUseTime:= FALSE,(*使用计圈延时*)
	i_rDelayTimeMs:= ,
	i_rCoef_FilmVolPerimeter:= rCoefCut_FilmVolPerimeter_In,
	i_rDiam_New:= (*pstStGrpParam^.lrDiam_NewVol_Uw*)rDiam_NewVol_Use,
	//i_pstStGrpParam:= pstStGrpParam,
	i_pstStTimeSet_DnCut_UpCut:= ADR(i_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)]),
	i_xReq_Cut:= fbRTrig_Cut.Q,
	i_rVel_PreDrv:= rVel_Predrv_Use(*pstStGrpParam^.lrVel_Predrv_Uw*),(*2021.10.14.142258 修改为预驱速度*)
	i_xReflectionSensorIO:= xSensor_Reflex,
	i_xCutUseReflectionSensor:= xCutUseReflectionSensor_In,
	i_iCycleTime_Plc:= i_iCycleTime_Plc,
	o_xEno=> ,
	o_iErNo=> ,
	o_xRollerCylinderOutput=> xOutput_CutCylinder,
	o_xCut_ing=> xFlag_Cut_ing_Out,
	o_xReflectSensorLoss=>xReflectSensorLoss_Out(*弧面信号丢失|2020.10.9.103839*),
	o_xReflectionSensorValid=> xReflectionSensorValid_Out,(*2019.11.29.174022_*)
	o_iCutTotalTime=>iCutTotalTime,(*2022.5.4.170313+这是胶辊的延时还需要加上裁刀的延时时间*)
	o_xCutSenSorDelay=>g_xCutSenSorDelay);
	IF iCutTotalTime<>0 THEN
		iCutTotalTime:=iCutTotalTime+iDelayMsec_CutOffKnifeCylinder_Final;
	END_IF
	

IF io_xCutOnTop THEN
	i_pstStEvtReq^.xOutCutCylinder_Up:= xOutput_CutCylinder;
	i_pstStEvtReq^.xOutCutter_Up:= xFlag_Cut_ing_Out;
ELSE
	i_pstStEvtReq^.xOutCutCylinder_Dn:= xOutput_CutCylinder;
	i_pstStEvtReq^.xOutCutter_Dn:= xFlag_Cut_ing_Out;
END_IF

(*上面逻辑会使用，不能在完成的这个周期清除切记！@2024.05.14.153626*)
IF iDelayMsec_CutOffKnifeCylinder_Final=0 THEN
	iDelayMsec_CutOffKnifeCylinder_Final:= 100;
END_IF
fbTon_DelayTimer_CutOffKnifeCylinder_Uw(
	IN:= xFlag_Cut_ing_Out,
	PT:= INT_TO_TIME(iDelayMsec_CutOffKnifeCylinder_Final));

IF fbTon_DelayTimer_CutOffKnifeCylinder_Uw.Q THEN
	xFlag_Cut_ing_Out:= FALSE;
	xFlag_Cut_end_Out:= TRUE;
	xCutAxisA_In_Out:= NOT xCutAxisA_In_Out; (*把轴换了*)

END_IF
(*2024.01.19.132832|在KS_FB_GrpCentralizedProc_UserFunc任务中要使用@获取到信号后自己清除*)
IF xFlag_Cut_end_Out THEN
	xFlag_Cut_end_UseInOtherPrg_In_Out:=xFlag_Cut_end_Out;
END_IF

xTell_KS_PreDrv_CTL_Uw_CuttDne:= xFlag_Cut_end_Out;

(*2020.5.13.085938 控制放料接料时取消转矩功能*)
xTorqueCancel:=KS_PreCut_Torqe(
					(*2020.5.13.085932 先看下在裁切完后直接恢复力矩会有什么风险吗？*)
					FALSE(*xPreDrvAxis_Releasing_Uw*)(*i_xPreDrvAxisRunning*),
					xOutput_CutCylinder,(*i_xRoller_Cut,*)
					iDelayMsec_RollerCylinder_Final(*i_iRoller_DelayTime*),
					i_iCycleTime_Plc(*i_iPlcCycleTime*),
					ADR(iTimeCnt)(*i_piTimeCnt*));


fbRTrig_Sts_Precuting(CLK:=o_xSts_PreCutting);
IF fbRTrig_Sts_Precuting.Q THEN (*接料准备过程中|我们确定需要取消转矩的轴*)
	xNeedTorqueCancel:= xCutAxisA_In_Out;
END_IF


IF xNeedTorqueCancel THEN(*放料需要取消转矩的轴为A轴*)
	xAxisATorqueCancel_Out:=xTorqueCancel;
	xAxisBTorqueCancel_Out:=FALSE;
ELSE(*放料需要取消转矩的轴为B轴*)
	xAxisATorqueCancel_Out:=FALSE;
	xAxisBTorqueCancel_Out:=xTorqueCancel;
END_IF




(* 2020.9.28.094352|补充进来|liu.yt指导  *)
(*转矩取消状态赋值到功能块变量2020.6.29.114342*)
i_pstStEvtReq^.xOutAxisATorqueCancel:=xAxisATorqueCancel_Out;
i_pstStEvtReq^.xOutAxisBTorqueCancel:=xAxisBTorqueCancel_Out;
(*输出模拟量*)
IF xAxisATorqueCancel_Out THEN(*取消有效|转矩为0*)
	i_pstStEvtReq^.wOutAxisATorqueVolt:=0;
ELSE
	i_pstStEvtReq^.wOutAxisATorqueVolt:=32767;(*10v*)
END_IF
IF xAxisBTorqueCancel_Out THEN(*取消有效|转矩为0*)
	i_pstStEvtReq^.wOutAxisBTorqueVolt:=0;
ELSE
	i_pstStEvtReq^.wOutAxisBTorqueVolt:=32767;(*10v*)
END_IF	

*)









