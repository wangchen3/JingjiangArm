(*@CES
Name=KS_BtnClick
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4b1f190c-8fa5-4402-be53-ffd017a7b610
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_BtnClick : BOOL
(*按钮的单击双击长按处理*)
(*双击信号|在设定时间内按下2次输出信号*)
(*单击信号|第一次按下后超过i_iTime_ms时间未按下第二次按键输出单击事件,只有效一个周期*)
(*长按信号|第一次按下后超过i_iTime_ms时间未取消输出长按信号,直到松开*)
(*500ms还是有点感觉*)
VAR_INPUT
	i_xBtn:BOOL;
	i_wTime_ms:WORD:=300;(*时间*)
	i_byCycleTime_ms:BYTE:=20;(*周期时间*)
	i_pxClick:POINTER TO BOOL;(*单击有效(相当于按下等待i_wTime_ms时间后输出单击事件)@支持指针=0*)
	i_pxDoubleClick:POINTER TO BOOL;(*单击有效(相当于按下等待i_wTime_ms时间后输出单击事件)@支持指针=0*)
	i_pxHold:POINTER TO BOOL;(*按钮长按(相当于按下等待i_wTime_ms时间后输出单击事件)@支持指针=0*)
	i_pwCnt:POINTER TO WORD;(*时间周期计数|@./15作为按钮第一次按下沿标志
										  |@./14作为按钮第一次按下超时标志
										  |@./13作为按钮第一次按下抬起的标志
										  |@./12作为按钮第二次按下沿标志	
										  |@故该值最大到16#FFF=4095*)
END_VAR
VAR
	wCnt: WORD;
	xDoubleClick:BOOL;
	xClick:BOOL;(*单击*)
	xHold:BOOL;(*长按*)
	xBtnU2D_1st: BOOL;(*按钮第一次按下沿标志*)
	xBtnU2DTimeOut_1st:BOOL;(*按钮第一次按下超时了*)
	xBtnD2U_1st: BOOL;(*按钮第一次按下到抬起标志*)
	xBtnU2D_2st: BOOL;(*按钮第二次抬起到按下沿标志*)
	wCnt_Use: WORD;(*实际计数值@最大16#fff*)
	xStopCnt: BOOL;(*停止计数标志*)
END_VAR
{IMPLEMENTATION}
IF i_pwCnt<>0 THEN
	wCnt:=i_pwCnt^;
END_IF
xBtnU2D_1st:=wCnt.15;
xBtnU2DTimeOut_1st:=wCnt.14;
xBtnD2U_1st:=wCnt.13;
xBtnU2D_2st:=wCnt.12;
wCnt_Use:=wCnt AND 16#FFF;(*只取低12bit*)

(*其实用状态机更好一些|有点乱*)
IF NOT xBtnU2D_1st THEN(*刚开始检测第一次按键*)
	IF i_xBtn THEN
		xBtnU2D_1st:=TRUE;
		(*标志初始化*)
		wCnt_Use:=0;
		xBtnU2DTimeOut_1st:=FALSE;
		xBtnD2U_1st:=FALSE;
		xBtnU2D_2st:=FALSE;
	END_IF
ELSE
	IF NOT xBtnD2U_1st THEN(*第一次的还没抬起来*)
		IF NOT i_xBtn THEN(*按钮抬起来了*)
			IF xBtnU2DTimeOut_1st THEN(*超过时间了@复位标志*)
				wCnt_Use:=0;
				xBtnU2DTimeOut_1st:=FALSE;
				xBtnU2D_1st:=FALSE;
				xStopCnt:=TRUE;(*停止计数*)
			ELSE(*未超过时间,继续检测*)
				xBtnD2U_1st:=TRUE;
			END_IF
		ELSE(*按下的时间太长了@输出长按标志*)
			(*超过时间了@复位标志*)
			IF NOT xBtnU2DTimeOut_1st THEN
				IF wCnt_Use*i_byCycleTime_ms>i_wTime_ms THEN
					wCnt_Use:=0;
					xBtnU2DTimeOut_1st:=TRUE;(*超时了*)
					xStopCnt:=TRUE;(*停止计数*)
					xHold:=TRUE;(*长按*)
				END_IF
			ELSE
				xStopCnt:=TRUE;(*停止计数*)
				xHold:=TRUE;(*长按*)
			END_IF
		END_IF
	ELSE
		IF NOT xBtnU2D_2st THEN(*第二次还未按下*)
			IF i_xBtn THEN(*再次按下*)
				IF wCnt_Use*i_byCycleTime_ms<=i_wTime_ms THEN(*在时间间隔内*)
					xDoubleClick:=TRUE;(*输出*)
				ELSE(*超过了时间|则不输出*)
					xDoubleClick:=FALSE;
				END_IF
				xBtnU2D_2st:=TRUE;(*第二次按下了*)
				xStopCnt:=TRUE;(*停止计数*)
			ELSE
				(*控制结束了*)
				IF wCnt_Use*i_byCycleTime_ms>i_wTime_ms THEN(*超过时间了@复位标志*)
					wCnt_Use:=0;
					xBtnU2D_1st:=FALSE;(*第一次按下复位*)
					xBtnD2U_1st:=FALSE;(*第一次抬起复位*)
					xStopCnt:=TRUE;(*停止计数*)
					xClick:=TRUE;(*输出单击事件*)
				END_IF
			END_IF
		ELSE(*第二次抬起按下了*)
			xStopCnt:=TRUE;(*停止计数*)
			IF NOT i_xBtn THEN(*抬起了,复位所有状态*)
				wCnt_Use:=0;
				xBtnU2D_1st:=FALSE;(*第一次按下复位*)
				xBtnD2U_1st:=FALSE;(*第一次抬起复位*)
				xBtnU2D_2st:=FALSE;(*第二次按下复位*)
			END_IF
		END_IF
	END_IF

	IF NOT xStopCnt THEN
		wCnt_Use:=wCnt_Use+1;(*计时开始*)
		IF wCnt_Use>=16#FFF THEN(*最大值限制*)
			wCnt_Use:=16#FFF;
		END_IF
	END_IF
END_IF



wCnt:=wCnt_Use;(*按位或*)
wCnt.15:=xBtnU2D_1st;
wCnt.14:=xBtnU2DTimeOut_1st;
wCnt.13:=xBtnD2U_1st;
wCnt.12:=xBtnU2D_2st;
IF i_pwCnt<>0 THEN
	i_pwCnt^:=wCnt;
END_IF
IF i_pxClick<>0 THEN
	i_pxClick^:=xClick;
END_IF
IF i_pxDoubleClick<>0 THEN
	i_pxDoubleClick^:=xDoubleClick;
END_IF
IF i_pxHold<>0 THEN
	i_pxHold^:=xHold;
END_IF