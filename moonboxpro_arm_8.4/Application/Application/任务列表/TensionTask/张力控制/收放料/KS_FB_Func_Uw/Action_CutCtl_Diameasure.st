(*@CES
Name=Action_CutCtl_Diameasure
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=9aa5e5c0-7e86-48c4-aab8-cffbde562cb2
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*卷径测量-包括调试部分Action_CutCtl_Diameasure*)

(*2021.8.27.143335 同步*)
(*新修改的卷径测量标定方法2021.8.27.144812|*)
IF i_rVel_Film=0 THEN
	IF o_xSts_PreCutting THEN;
	ELSE(*非接料准备中才能切换调试模式*)
		xIsDebug_DiaMeasure:=xIsDebug_DiaMeasure_In_Out;
	END_IF
ELSE
	(*走料的时候取消调试模式标志*)
	xIsDebug_DiaMeasure_In_Out:=FALSE;(*取消调试模式*)
	xIsDebug_DiaMeasure:=FALSE;
END_IF

fbKS_FB_DiaMeasure_Debug(
	i_xEn:=xIsDebug_DiaMeasure,
	i_xDiaMeasure_Debug:=o_xSts_PreCutting,
	i_xCancelDiaMeasuring_Debug:=xCancelDebuging_DiaMeasure_In_Out,(*由卷径功能块|接料取消中进行控制置位*)
	i_xNextArea:= i_pstStEvtReq^.xEvt_Cut,(*接料按钮常按3s触发*)
	//i_pstStGrpParam:= pstStGrpParam,
	o_xEn=> ,
	o_xDiaMeasuring_Debug=> xIsDebuging_DiaMeasure_In_Out,
	o_xDiaMeasuredDne_Debug=> xFlag_Measured,
	o_xLamp_DiaMeasureArea=>  xLamp_DiaMeasureArea,
	o_axMeasure_StdVol=> axMeasure_StdVol_In_Out,
	io_byIsDebug_DiaMeasureArea:= byIsDebug_DiaMeasureArea_In_Out);

xCancelDebuging_DiaMeasure_In_Out:=FALSE;

(*放料卷径测量*)
IF xSts_Sensor1Ok AND dwCycleDelayCountdown<>0 THEN
	dwCycleDelayCountdown:= dwCycleDelayCountdown-1;
END_IF


(*卷径测量使用接近开关*)
	IF o_xSts_PreCutting THEN(*接料准备过程中*)
//		fbRTrig_Sensor2(CLK:=xUwMeasureSensor_In);(*检测位置上升沿*)
		IF i_pstStEvtReq^.xReq_UwMeasureSensor THEN(**)
			xNeedStopTowerForUwMeasure:=TRUE;
		END_IF
	ELSE(*取消接料准备的时候复位卷径测量标志*)
		xUwVolDiamMeasureEn:=FALSE;
		xNeedStopTowerForUwMeasure:=FALSE;
		//fbRTrig_Sensor2(CLK:=FALSE);
	END_IF

	(*到达计算位置的时候先停止翻转架，1s后计算
	再过500ms恢复翻转架转动*)
	IF xNeedStopTowerForUwMeasure THEN
		iTimeCnt_StopTower:=iTimeCnt_StopTower+1;
		IF iTimeCnt_StopTower * i_iCycleTime_Plc>=1000 THEN(*超过1s后计算卷径*)
			xUwVolDiamMeasureEn:=TRUE;
			IF iTimeCnt_StopTower * i_iCycleTime_Plc>=1500 THEN(*再过500ms|取消翻转架停止*)
				xNeedStopTowerForUwMeasure:=FALSE;
			END_IF
		ELSE(*时间没到先不计算*)
			xUwVolDiamMeasureEn:=FALSE;
		END_IF
	ELSE
		iTimeCnt_StopTower:=0;
	END_IF

(*增加单个超声波检测卷径功能|2024.1.10.135142|Wang.nt*)
xEn_UwVolDiamMeasurement:=o_xSts_PreCutting AND(
	(byDiamMeasureTypeId_In<>4 AND  xSts_Sensor1Ok AND dwCycleDelayCountdown=0) OR
	(*(pstStGrpParam^.byDiamMeasureTypeId=4 AND  xSts_Limited_Uw) ); *)
	(byDiamMeasureTypeId_In=4 AND  xUwVolDiamMeasureEn) );

	
fbKS_FB_UwVolDiamMeasurement(
	i_xEn:= xEn_UwVolDiamMeasurement, 
	i_xDiamMeasureAutomatic:= xDiamMeasureAutomatic_In, 
	i_rGirth_AxisA:= rGirth_AxisA_In, 
	i_rGirth_AxisB:= rGirth_AxisB_In, 
	i_xMultAxisParaEn:= xFlag_AxisABParaFroDiaMea_In, 
	i_rVel_Film:= i_rVel_Film, 
	i_byDiamMeasureTypeId:= byDiamMeasureTypeId_In, 
	i_xCutOnTop:= io_xCutOnTop, 
	i_xCurAxisA:= xCutAxisA_In_Out, 
	i_rAi_DiamMeasure:= rAi_DiamMeasure_In_Out, 
	i_xIsDebuging_DiaMeasure:= xIsDebug_DiaMeasure_In, 
	i_axMeasure_StdVol:= axMeasure_StdVol_In_Out, 
	i_dwAbsEnCodeResolution:= gc_dwAbsEnCodeResolution_Uw, 
	i_xEnCodeErr:= xEnCodeFailed_In_Out, 
	o_xEn=> , 
	o_iErrCode=> , 
	o_xFlag_DiamMeasure_end=> xFlag_DiamMeasure_end_Out, 
	o_rVolt_CalcDiam_Used_Watch=> rVolt_CalcDiam_Used_Watch_Out, 
	o_xFlag_Type4AndDiamMeasure_end_UW=> xFlag_Type4AndDiamMeasure_end, 
	io_rDiam_NewVol:= o_rDiam_NewVol, 
	io_xCancelDebuging_DiaMeasure:= xCancelDebuging_DiaMeasure_In_Out, 
	io_astStStdVolParam_DnCut_UpCut:= astStStdVolParam_DnCut_UpCut_In_Out, 
	o_xParamErr=> xDiaMeaParamErr);
	
	(*2022.9.14.155658*)
IF xDiaMeaParamErr THEN
	o_xUwVolDiamMeasurementFailed:=TRUE;
ELSE
	IF i_xClrAlarmInf THEN
		o_xUwVolDiamMeasurementFailed:=FALSE;
	END_IF
END_IF
