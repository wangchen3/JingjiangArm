(*@CES
Name=Action_CutCtl_AbsEncForTower
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a6db23aa-5dfb-4dc4-a15f-858f59b7ce4e
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*使用绝对值编码器-2021.4.30.105659------------------------start*)
(*调试模式下强制重新处理了上下裁刀和ab轴的变量*)
(*定位调试模式下会有预驱灯闪烁*)
IF i_xFlag_Print OR i_xFlag_Estop OR(*印刷状态下取消定位测量模式*)
	i_xFlag_Tension OR (* 2021.7.16.093824/张力投入时也取消放料调试模式 *)
	NOT xUseAbsEncoder_In THEN(*不用编码器方式定位的时候取消调试模式@2024.02.21.153233*)
	xDebug_Enc_In_Out_UwRw:=FALSE;
END_IF
(*使用放料接料按钮进行定位写入处理|	接料按钮按1次且500MS内无按钮输入-则为单击事件-该事件控制大臂上下
									接料按钮按2次写入大臂定位-间隔时间500MS内
									接料按钮长按3S写入最小径定位。*)
xCutHolderCanDebug:= FALSE;
IF xDebug_Enc_In_Out_UwRw THEN(*调试状态下*)
	(*大臂3寸定位写入*)
	IF fbRTrig_Cut.Q THEN(*接料按键按下了|*)
		iCnt_Cuttrig:=iCnt_Cuttrig+1;
		IF iCnt_Cuttrig=1 THEN(*2021.10.21.083337  条件缺失*)
			tTime_CutTrig:=TIME();(*获取按下时间*)
		END_IF
	END_IF

	IF iCnt_Cuttrig>=2 THEN(*按下2次|写入大臂3寸定位*)
		iCnt_Cuttrig:=0;
		byEncodeValueWr_In_Out:=1;
		x6InchFroDebug_In_Out:=FALSE;
	ELSE
		IF iCnt_Cuttrig>0 THEN(*已经按下了|启动计时，如果500MS内未再次按下，则清除计数*)
			IF TIME()-tTime_CutTrig>=T#500MS THEN(*超过500MS未再次按下|我们认为是单击事件*)
				IF NOT fbRTrig_Cut.CLK THEN(*超过500ms按钮也抬起来了|*)
					xCutHolderCanDebug:=TRUE;
				END_IF
				iCnt_Cuttrig:=0;
			END_IF
		END_IF
	END_IF

	(*6寸定位写入*)
	IF fbRTrig_Cut.CLK THEN(*接料按下了*)
		IF TIME()-tTime_CutTrig>=T#3S THEN(*超过3s写入收料6寸定位*)
			byEncodeValueWr_In_Out:=1;
			x6InchFroDebug_In_Out:=TRUE;
		END_IF
	END_IF
ELSE
	iCnt_Cuttrig:=0;
END_IF


(*2022.4.23.131233 增加编码器方式下，在编码器故障时候接料按钮作为手动定位的按钮逻辑*)
IF xUseAbsEncoder_In AND
	xEnCodeErr_In_Out AND (*绝对值编码器故障的时候*)
	i_xFlag_Print AND
	o_xSts_PreCutting THEN
	IF NOT xSts_ArmFall_end THEN(*大臂还未落下的时候|接料按钮作为手动定位按钮*)
		xBtn_AxisLocationManu:=fbRTrig_Cut.Q;
	END_IF
ELSE
	xBtn_AxisLocationManu:= FALSE;(*2022.9.12.170150||liu*)
END_IF

fbKS_FB_AbsEncForTower_Rw(
	i_xEn:= xUseAbsEncoder_In, 
	i_xMultAxisPosEn:= xEn_DualParam_AbsEncLocation_In, 
	i_iGrpId:= i_iGrpId, 
	i_pxFlag_6Inch:= ADR(xFlag_6Inch_Out), 
	i_pxGetAxisLocation:= ADR(xDebug_Enc_In_Out_UwRw), 
	i_pxCurAxisAFroDebug:= ADR(xCurAxisAFroDebug_In_Out), 
	i_pxCutterOnTopFroDebug:= ADR(xCutterOnTopFroDebug_In_Out),  
	i_px6InchFroDebug:= ADR(x6InchFroDebug_In_Out), 
	i_pbyEncodeValueWr:= ADR(byEncodeValueWr_In_Out),
	i_dwAbsEncSinglePos:= dwAbsEncSinglePos_In, 
	i_wAbsEncMultiPos:= 0, 
	i_dwAbsEnCodeResolution:= gc_dwAbsEnCodeResolution_Rw, 
	i_xTowerMoving:= i_pstStEvtReq^.xOutTowerFor OR i_pstStEvtReq^.xOutTowerRev, 
	i_xBtn_AxisLocationManu:= xBtn_AxisLocationManu, 
	o_xEn=> , 
	o_dwEnCodePos=> dwEnCodePos_In_Out, 
	o_xAxisALocation=> xAxisALocationByAbsEnc, 
	o_xAxisBLocation=> xAxisBLocationByAbsEnc, 
	o_xAxisLocationInvalid=> xAxisLocationInvalid, 
	o_xAxisLocationWrDne=> xAxisLocationWrDne, 
	io_xEnCodeFailed:= xEnCodeFailed_In_Out, 
	io_xCutOnTop:= io_xCutOnTop, 
	io_xCurAxisA:= xCutAxisA_In_Out, 
	io_adwAxisALocation:= adwAxisALocation_In_Out, 
	io_adwAxisBLocation:= adwAxisBLocation_In_Out
);


xAxisLocationWrDne_3Inch:=FALSE;
xAxisLocationWrDne_6Inch:=FALSE;
IF xAxisLocationWrDne THEN
	IF x6InchFroDebug_In_Out THEN(*6寸*)
		xAxisLocationWrDne_6Inch:=TRUE;
	ELSE(*3寸*)
		xAxisLocationWrDne_3Inch:=TRUE;
	END_IF
END_IF



(*写入完成响铃提示|有效一个周期*)
IF xAxisLocationWrDne_3Inch THEN(*3寸定位写入完成响铃1s*)
	tTime_Alarm:=tTime_AlarmForAxisLocation_3Inch;
	tTime_AlarmSa:=TIME();
END_IF

(*写入完成响铃提示|有效一个周期*)
IF xAxisLocationWrDne_6Inch THEN(*6寸定位写入完成响铃3s*)
	tTime_Alarm:=tTime_AlarmForAxisLocation_6Inch;
	tTime_AlarmSa:=TIME();
END_IF

(*需要响铃提示*)
xNeedAlarmBell_Out:=FALSE;
IF TIME_TO_DWORD(tTime_AlarmSa)<>0 THEN
	xNeedAlarmBell_Out:=TRUE;
	IF TIME()-tTime_AlarmSa>=tTime_Alarm THEN(*响铃时间到了|停止响铃*)
		tTime_AlarmSa:=T#0S;
	END_IF
END_IF

(*2021.11.26.114019
(*收料响铃输出为收牵报警铃*)
IF pstStGrpParam^.xAlarmBell_Rw THEN
	pstStGrpParam^.xFlag_KeepAlarming:=TRUE;
END_IF
*)

