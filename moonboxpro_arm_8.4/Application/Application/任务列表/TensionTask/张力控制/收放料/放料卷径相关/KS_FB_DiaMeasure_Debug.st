(*@CES
Name=KS_FB_DiaMeasure_Debug
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c522e788-ea68-40d8-ad7d-2bae7fc5231d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_DiaMeasure_Debug(*卷径测量标定|axMeasure_StdVol作为标定位置的标识--接料准备才是真正的启动*)
(*2021.8.3.164724 增加卷径测量标定在放料操作面板处理逻辑|
通过按键接料2s进行卷径测量区间的切换，同时预驱灯3s间隔根据卷径区间
以600ms的频率闪烁次数用来表征此时的测量区间。接料准备按钮启动测量。。*)
VAR_INPUT
	i_xEn:BOOL;(*调试使能*)
	i_xDiaMeasure_Debug:BOOL;
	i_xCancelDiaMeasuring_Debug:BOOL;(*卷径测量调试标定中取消*)
	i_xNextArea:BOOL;(*卷径测量区间切换标志|输入3s认为有效*)
//	i_pstStGrpParam: POINTER TO StGrpParam; (*系参数*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xDiaMeasuring_Debug:BOOL;(*卷径测量调试标定中*)
	o_xDiaMeasuredDne_Debug:BOOL;(*卷径测量调试完成。*)
	o_xLamp_DiaMeasureArea:BOOL;(*表征卷径测量指示灯|3s间隔300ms闪烁区间数|例如：卷径2-每间隔3s启动闪烁-300ms间隔闪烁2次*)
	o_axMeasure_StdVol:ARRAY [1..4] OF BOOL;(*卷径测量按钮标志*)
END_VAR
VAR_IN_OUT
	io_byIsDebug_DiaMeasureArea: BYTE;
END_VAR
VAR
	tTimeNextAreaBtnDne:TIME;(*按钮按下时间*)
	tTimeNextAreaBtn:TIME:=T#2S;(*切换到下个区域按钮需要按下时间*)
	tTimeInterVal_Flick:TIME:=T#300MS;(*指示区间数的闪烁间隔|亮灭一共tTimeInterVal_Flick*2*)
	tLastTime_Interval:TIME;
	tTimeInterVal_Flick_Long:TIME:=T#3S;(*显示指示区间数闪烁的间隔*)
	tLastTime_LongInterval:TIME;
	iLenArea: INT;(*区间个数*)
	iN: INT;
	xMeasure: BOOL;
	byArea_Cur: BYTE;
(*	fbNextAreaBtnTON:TON;
	afbTON:ARRAY [1..2] OF TON;*)
	xAreaNumFlickTimeOut:BOOL;(*表征区域num的闪烁时间到*)
	xCanAreaNumFlickTimeOut:BOOL;(*可以进行表征区域num闪烁的时间到了*)
	iFlick_OnCnt: INT;(*闪烁有效次数计数*)
	afbR_Trig:ARRAY [1..3] OF R_TRIG;
	byLastArea_Cur: BYTE;(*检测当前卷径区间是否发生变化，用于更新测量区域标志*)
	xNextArea: BOOL;


END_VAR
{IMPLEMENTATION}
xMeasure:=FALSE;
o_xDiaMeasuredDne_Debug:=FALSE;
byArea_Cur:= io_byIsDebug_DiaMeasureArea;
iLenArea:=SIZEOF(o_axMeasure_StdVol)/SIZEOF(o_axMeasure_StdVol[1]);
IF i_xEn THEN
	(*计算区间个数|*)
	(*放料卷径测量标志清除*)
	(*测量区间切换|*)
(*		fbNextAreaBtnTON(IN:=i_xNextArea,PT:=tTimeNextAreaBtn,Q=>xNextArea);(*区间切换输入*)*)
	IF i_xNextArea THEN
		IF TIME()-tTimeNextAreaBtnDne>=tTimeNextAreaBtn THEN
			xNextArea:=TRUE;
		END_IF
	ELSE
		xNextArea:=FALSE;
		tTimeNextAreaBtnDne:=TIME();
	END_IF


	afbR_Trig[1](clk:=i_xDiaMeasure_Debug);
	afbR_Trig[2](clk:=i_xCancelDiaMeasuring_Debug);
	afbR_Trig[3](clk:=xNextArea);
	IF NOT o_xDiaMeasuring_Debug THEN(*不再卷径测量过程中|才可以进行切换*)
		IF afbR_Trig[3].Q THEN(*按下的时间够了|切换*)
			byArea_Cur:=byArea_Cur+1;
		END_IF
		IF byArea_Cur>iLenArea OR byArea_Cur=0 THEN
			byArea_Cur:=1;
		END_IF

		IF byArea_Cur<>byLastArea_Cur THEN
			byLastArea_Cur:=byArea_Cur;
			FOR iN:=1 TO iLenArea BY 1 DO
				o_axMeasure_StdVol[iN]:=FALSE;
			END_FOR
			o_axMeasure_StdVol[byArea_Cur]:=TRUE;
		END_IF
		xMeasure:=o_axMeasure_StdVol[byArea_Cur];

		IF xMeasure AND afbR_Trig[1].Q THEN(*卷径测量启动*)
			o_xDiaMeasuring_Debug:=TRUE;(*标准卷径测量中*)
		END_IF
	ELSE(*处于卷径测量过程中|需要等待一个周期byLastArea_Cur被赋值*)
		byArea_Cur:=byLastArea_Cur;(*当前区间保持不变*)
		IF afbR_Trig[2].Q THEN(*取消卷径测量*)
			o_xDiaMeasuring_Debug:=FALSE;
			o_xDiaMeasuredDne_Debug:=TRUE;
		END_IF
	END_IF


	IF byArea_Cur<>0 AND (NOT i_xNextArea OR xNextArea) THEN(*|在切换区域的时候不处理闪烁*)
		(*计时处理*)
		IF TIME()-tLastTime_LongInterval>=tTimeInterVal_Flick_Long THEN
			xCanAreaNumFlickTimeOut:=TRUE;
			tLastTime_LongInterval:=TIME();
		END_IF
		IF xCanAreaNumFlickTimeOut THEN
			IF TIME()-tLastTime_Interval>=tTimeInterVal_Flick THEN
				xAreaNumFlickTimeOut:=TRUE;
				tLastTime_Interval:=TIME();
			END_IF
		ELSE
			xAreaNumFlickTimeOut:=FALSE;
			tLastTime_Interval:=TIME();
		END_IF

		IF xCanAreaNumFlickTimeOut  THEN(*可以闪烁表征区域num*)
			IF iFlick_OnCnt=0 THEN
				o_xLamp_DiaMeasureArea:=TRUE;
				iFlick_OnCnt:=1;
			END_IF

			IF xAreaNumFlickTimeOut THEN(*时间到了|*)
				IF iFlick_OnCnt>=byArea_Cur THEN(*闪烁有效次数达到区域数，停止闪烁*)
					iFlick_OnCnt:=0;
					o_xLamp_DiaMeasureArea:=FALSE;
					xAreaNumFlickTimeOut:=FALSE;
					xCanAreaNumFlickTimeOut:=FALSE;
				ELSE
					xAreaNumFlickTimeOut:=FALSE;
					o_xLamp_DiaMeasureArea:=NOT o_xLamp_DiaMeasureArea;
					IF o_xLamp_DiaMeasureArea THEN
						iFlick_OnCnt:=iFlick_OnCnt+1;
					END_IF
				END_IF
			END_IF
		ELSE
			o_xLamp_DiaMeasureArea:=FALSE;
			iFlick_OnCnt:=0;
		END_IF
	ELSE
		tLastTime_LongInterval:=TIME();
		tLastTime_Interval:=TIME();
		xCanAreaNumFlickTimeOut:=TRUE;(*默认时间到了|这进入if逻辑可以直接启动闪烁*)
		xAreaNumFlickTimeOut:=FALSE;
		o_xLamp_DiaMeasureArea:=FALSE;
		iFlick_OnCnt:=0;
	END_IF
ELSE
	byArea_Cur:=1;
	byLastArea_Cur:=0;
	xNextArea:=FALSE;
	tTimeNextAreaBtnDne:=TIME();
	tLastTime_LongInterval:=TIME();
	tLastTime_Interval:=TIME();
	xCanAreaNumFlickTimeOut:=TRUE;(*默认时间到了|这进入if逻辑可以直接启动闪烁*)
	xAreaNumFlickTimeOut:=FALSE;
	o_xLamp_DiaMeasureArea:=FALSE;
	afbR_Trig[1](clk:=FALSE);(*沿复位*)
	afbR_Trig[2](clk:=FALSE);
	(*停止卷径测量*)
	IF o_xDiaMeasuring_Debug THEN
		o_xDiaMeasuring_Debug:=FALSE;
	END_IF
END_IF
(*2021.10.14.130150\屏蔽*)
(*	byLastArea_Cur:=byArea_Cur;*)
io_byIsDebug_DiaMeasureArea:=byArea_Cur;
