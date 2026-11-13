(*@CES
Name=Action_CutCtl_AbsEncForTower
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=c002e003-325a-4af6-9e19-7b8558e1cf4e
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
	(*大臂定位写入*)
	IF fbRTrig_Cut.Q THEN(*接料按键按下了|*)
		iCnt_Cuttrig:=iCnt_Cuttrig+1;
		IF iCnt_Cuttrig=1 THEN(*开始的时候获取时间*)
			tTime_CutTrig:=TIME();(*获取按下时间*)
		END_IF
	END_IF

	IF iCnt_Cuttrig>=2 THEN(*按下2次|写入大臂定位*)
		iCnt_Cuttrig:=0;
		byEncodeValueWr_In_Out:=1;
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

	(*最小径写入*)
	IF fbRTrig_Cut.CLK THEN(*接料按下了*)
		IF TIME()-tTime_CutTrig>=T#3S THEN(*超过3s写入最小径*)
			byEncodeValueWr_In_Out:=2;
		END_IF
	END_IF
ELSE
	iCnt_Cuttrig:=0;
END_IF


(*2022.4.23.131233 增加编码器方式下，在编码器故障时候接料按钮作为手动定位的按钮逻辑*)
IF byDiamMeasureTypeId_In=2 AND
	i_xEnCodeErr AND (*绝对值编码器故障的时候*)
	i_xFlag_Print AND
	o_xSts_PreCutting THEN
	IF (NOT xSts_ArmFall_end) THEN(*大臂还未落下的时候|接料按钮作为手动定位按钮*)
		xBtn_AxisLocationManu:=fbRTrig_Cut.Q;

	END_IF
ELSE
	xBtn_AxisLocationManu:= FALSE;(*2022.9.12.170150||liu*)
END_IF
fbKS_FB_AbsEncForTower(
	i_xAxisPosEn:= xUseAbsEncoder_In, 
	i_xDiamMeasureEn:= byDiamMeasureTypeId_In=2, 
	i_xMultAxisPosEn:= xEn_DualParam_AbsEncLocation_In, 
	i_iGrpId:= i_iGrpId, 
	i_pxGetAxisLocation:= ADR(xDebug_Enc_In_Out_UwRw), 
	i_pxCurAxisAFroDebug:= ADR(xCurAxisAFroDebug_In_Out), 
	i_pxCutterOnTopFroDebug:= ADR(xCutterOnTopFroDebug_In_Out), 
	i_pbyEncodeValueWr:= ADR(byEncodeValueWr_In_Out), 
	i_dwAbsEncSinglePos:= dwAbsEncSinglePos_In, 
	i_wAbsEncMultiPos:= 0, 
	i_dwAbsEnCodeResolution:= gc_dwAbsEnCodeResolution_Uw, 
	i_xTowerMoving:= i_pstStEvtReq^.xOutTowerFor OR i_pstStEvtReq^.xOutTowerRev, 
	i_xBtn_AxisLocationManu:= xBtn_AxisLocationManu, 
	o_xEn=> , 
	o_dwEnCodePos=> dwEnCodePos_In_Out, 
	o_xAxisAMinimumDiamProtect=> xAxisAMinimumDiamLocationByAbsEnc,
	o_xAxisBMinimumDiamProtect=> xAxisBMinimumDiamLocationByAbsEnc,
	o_xAxisALocation=> xAxisALocationByAbsEnc,
	o_xAxisBLocation=> xAxisBLocationByAbsEnc,
	o_xAxisLocationInvalid=>xAxisLocationInvalid,
	o_xAxisLocation_MinDiaInvalid=>xAxisLocation_MinDiaInvalid,
	o_xAxisLocationWrDne=>xAxisLocationWrDne,(*轴定位写入成功*)
	o_xAxisLocation_MinDiaWrDne=>xAxisLocation_MinDiaWrDne,(*轴最小径写入成功*)
	io_xEnCodeFailed:= xEnCodeFailed_In_Out, 
	io_xCutOnTop:= io_xCutOnTop, 
	io_xCurAxisA:= xCutAxisA_In_Out, 
	io_adwAxisALocation:= adwAxisALocation_In_Out, 
	io_adwAxisBLocation:= adwAxisBLocation_In_Out, 
	io_adwAxisALocation_MinDia:= adwAxisALocation_MinDia_In_Out, 
	io_adwAxisBLocation_MinDia:= adwAxisBLocation_MinDia_In_Out, 
	io_rAIByAbsEnc_Cur:= rAi_DiamMeasure_In_Out
	);

(*写入完成响铃提示|有效一个周期*)
IF xAxisLocationWrDne THEN(*定位写入完成响铃1s*)
	tTime_Alarm:=tTime_AlarmForAxisLocation;
	tTime_AlarmSa:=TIME();
END_IF

(*写入完成响铃提示|有效一个周期*)
IF xAxisLocation_MinDiaWrDne THEN(*最小径定位写入完成响铃3s*)
	tTime_Alarm:=tTime_AlarmForAxisLocation_MinDia;
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
	
