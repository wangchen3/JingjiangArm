(*@CES
Name=KS_FB_AxisDebug
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=225e022e-2ac6-4e18-87bd-0bf6abe85a88
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AxisDebug
VAR_INPUT
	i_xEn:BOOL;
	i_xEstopBtn:BOOL;(*急停*)
	i_xFlag_Estop: BOOL;
	i_xFlag_Tension: BOOL;
	i_xFlag_Print: BOOL;
	i_xCurAxisA: BOOL;
	i_rVel_Max: REAL;
	i_xFuncBtn:BOOL;(*放料功能按钮|单击-根据当前轴选择控制加速哪一个轴|延迟1s后加速-考虑使用伺服初始化耗时-接料准备时候不能按钮不能使用了
									  双击(500MS内按下2次)-控制停止ab轴|
									  常按3s则根据当前轴选择控制停止哪一个轴*)
	(*2021.10.14.102041*)
	i_xPreCutBtn:BOOL;(*接料准备*)
	i_xCutCancelBtn:BOOL;(*接料解除-退出接料准备状态并减速*)
	i_xCutBtn:BOOL;(*接料|单击是接料|双击则自动加速到目标速度或者停止到当前速度*)
	i_xStsPreCut:BOOL;(*接料准备状态*)	
	i_iDebugVelmpm_AxisA:INT;(*A轴调试速度|m/min*)
	i_iDebugGirthmm_AxisA:INT;(*调试的A轴周长*)
	i_iDebugVelmpm_AxisB:INT;(*B轴调试速度|m/min*)
	i_iDebugGirthmm_AxisB:INT;(*调试的B轴周长*)	
	i_iCycleTime_Plc: INT;
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xLampFlick_Debug:BOOL;(*指示调试预驱同步有效标志-加减速250MS闪烁|处于调试状态*)
	(*接料准备动作逻辑兼容|2021.10.14.101833*)
	o_xPreCut_Debug:BOOL;(*接料准备调试按钮输出*)
	o_xCutCancel_Debug:BOOL;(*接料取消调试按钮输出|可能不需要*)
	o_xCut_Debug:BOOL;(*接料调试按钮输出*)
	o_xLamp_PreDrive_Debug:BOOL;(*调试预驱同步输出*)	
END_VAR
VAR
	xStopFast:BOOL;(*快停|用于处理急停*)
	xFlag_NeedStop: BOOL;(*停止标志*)
	xAxisDebugEn: BOOL;(*放料轴调试使能|.0*)
	xAxisADebugRun: BOOL;(*放料A轴调试运行|.1*)
	xAxisADebugAutoAccDec: BOOL;(*放料A轴调试自动加减速|.2*)
	xAxisADebugRunning: BOOL;(*放料A轴调试运行中|作为输出|.3*)
	xAxisBDebugRun: BOOL;(*放料B轴调试运行|.4*)
	xAxisBDebugAutoAccDec: BOOL;(*放料B轴调试自动加减速|.5*)
	xAxisBDebugRunning: BOOL;(*放料B轴调试运行中|作为输出|.6*)
	xLastFuncBtn:BOOL;(*功能键按下上个周期值*)
	tTimeFuncBtnDn: TIME;(*放料功能键按下时间|按下沿的时间*)
	iClickNum: BYTE;(*点击次数*)
	tTimeRetain:TIME:=T#3S;(*放料功能键按下持续时间时间|按下超过这个时间就只停止a\b轴*)
	tTimeDoubleClick:TIME:=T#500MS;(*放料功能键按下单双击时间|*)
	tDelayTimeAutoAccByBtn:TIME:=T#1S;(*放料通过放料面板自动加速延迟时间*)
	xAllAxisStop: BOOL;(*ab轴都停止标志*)
	fbAxisAStopTrig:R_TRIG;(*放料A轴停止沿*)
	fbAxisBStopTrig:R_TRIG;(*放料B轴停止沿*)
	xAxisAStop: BOOL;(*a轴停止标志*)
	xAxisBStop: BOOL;(*b轴停止标志*)
	xAxisAAutoAcc: BOOL;(*A轴自动加速标志*)
	fbTon_AxisAAutoAcc: TON;(*A轴自动加速延时器*)
	fbRTrig_AxisAAutoAcc: R_TRIG;(*A轴自动加速沿*)
	xAxisBAutoAcc: BOOL;(*B轴自动加速标志*)
	fbTon_AxisBAutoAcc: TON;(*B轴自动加速延时器*)
	fbRTrig_AxisBAutoAcc: R_TRIG;(*B轴自动加速沿*)
	xAxisAccOrDecing:BOOL;(*放料变速状态中*)
	fbTon_AxisAccOrDecingFlick: TON;(*轴加减速中闪烁计时器*)
	xLampFlick_Debug:BOOL;(*闪烁指示灯*)	
	
	afbTrigBtn:ARRAY [1..3] OF R_TRIG;
	xReqPreCut: BOOL;(*接料准备沿*)
	xReqCutCancel: BOOL;(*接料取消沿*)
	xReqCut: BOOL;(*接料沿*)
	iCutBtnClickNum: INT;
	tTimeCutBtnDn: TIME;
	xLastStsPreCut:BOOL;
	xAxisDebuging: BOOL;(*调试中标志*)
	rAxisAVelTar: REAL;(*A轴目标速度*)
	rAxisBVelTar: REAL;(*B轴目标速度*)	
	arLastCurVel: ARRAY [1..4] OF REAL;(*收放料4个轴的速度备份|判断在变速状态*)	
END_VAR
VAR_IN_OUT
	io_xAxisDebugEn: BOOL;
	io_xAxisADebugRun: BOOL;
	io_xAxisBDebugRun: BOOL;
	io_xAxisADebugRunning: BOOL;
	io_xAxisBDebugRunning: BOOL;
	io_xAxisADebugAutoAccDec: BOOL;
	io_xAxisBDebugAutoAccDec: BOOL;
	
	io_rDebugCurVelmpmAxisA: REAL;
	io_rDebugCurVelmpmAxisB: REAL;
	io_rDebugCurVelrpmAxisA: REAL;	
	io_rDebugCurVelrpmAxisB: REAL;
END_VAR
{IMPLEMENTATION}
xAxisDebugEn:=io_xAxisDebugEn;
(*放料A轴测试|*)
IF io_rDebugCurVelmpmAxisA=0 THEN
	xAxisADebugRun:=io_xAxisADebugRun;
ELSE
	IF NOT io_xAxisADebugRun THEN
		xAxisADebugRun:=io_xAxisADebugRun;
	END_IF
END_IF
xAxisADebugAutoAccDec:= io_xAxisADebugAutoAccDec;
(*放料b轴测试*)
IF io_rDebugCurVelmpmAxisB=0 THEN
	xAxisBDebugRun:=io_xAxisBDebugRun;
ELSE
	IF NOT io_xAxisBDebugRun THEN
		xAxisBDebugRun:=io_xAxisBDebugRun;
	END_IF
END_IF
xAxisBDebugAutoAccDec:=io_xAxisBDebugAutoAccDec;
(*数值合法性处理*)
IF i_iDebugGirthmm_AxisA=0 THEN i_iDebugGirthmm_AxisA:=300;END_IF
IF i_iDebugVelmpm_AxisA=0 THEN i_iDebugVelmpm_AxisA:=300;END_IF
IF i_iDebugGirthmm_AxisB=0 THEN i_iDebugGirthmm_AxisB:=300;END_IF
IF i_iDebugVelmpm_AxisB=0 THEN i_iDebugVelmpm_AxisB:=300;END_IF

IF i_xEstopBtn OR i_xFlag_Estop  THEN
	xStopFast:=TRUE;(*急停时候使用快速停止*)
	xFlag_NeedStop:=TRUE;
ELSE
	IF xFlag_NeedStop THEN
		IF NOT (xAxisADebugRunning OR
			xAxisBDebugRunning) THEN(*所有轴都停止使能了|复位标志*)
			xStopFast:=FALSE;
			xFlag_NeedStop:=FALSE;
		END_IF
	END_IF
END_IF


(*针对收放料的处理*)
IF  xFlag_NeedStop OR (*急停的时候需要停止运动*)
	i_xFlag_Tension OR(*使用收放料的时候就停止调试*)
(*		i_pstStGrpParam^.xFlag_Ink or(*空转 我们认为是开机|就停止调试*)*)
	i_xFlag_Print THEN(*印刷时候|就停止调试|2022.4.10.154641*)
	(*放料A轴清除*)
	xAxisADebugRun:=FALSE;
	xAxisAAutoAcc:=FALSE;
	xAxisADebugAutoAccDec:=FALSE;
	(*放料B轴清除*)
	xAxisBDebugRun:=FALSE;
	xAxisBAutoAcc:=FALSE;
	xAxisBDebugAutoAccDec:=FALSE;

	IF NOT xFlag_NeedStop THEN(*不是急停停止的时候我们退出调试模式|*)
		xAxisDebugEn:=FALSE;
		xAxisDebugEn:=FALSE;
	END_IF
END_IF

(****************************************************************************************************)
xAllAxisStop:=FALSE;
xAxisAStop:=FALSE;
xAxisBStop:=FALSE;
(*接料准备动作逻辑兼容|2021.10.14.101833*)
o_xPreCut_Debug:=FALSE;(*接料准备调试按钮输出*)
o_xCutCancel_Debug:=FALSE;(*接料取消调试按钮输出|可能不需要*)
o_xCut_Debug:=FALSE;(*接料调试按钮输出*)
o_xLamp_PreDrive_Debug:=FALSE;
(*放料轴停止\加速|*)
afbTrigBtn[1](CLK:=i_xPreCutBtn,Q=>xReqPreCut);
afbTrigBtn[2](CLK:=i_xCutCancelBtn,Q=>xReqCutCancel);
afbTrigBtn[3](CLK:=i_xCutBtn,Q=>xReqCut);
IF xAxisDebugEn THEN
	xAxisDebuging:=TRUE;
	(*2021.10.14.110723 兼容的接料准备逻辑------------------------------------------*)
	IF xReqPreCut AND NOT i_xStsPreCut THEN(*接料准备*)
		o_xPreCut_Debug:=TRUE;
	END_IF
	IF i_xStsPreCut THEN(*进入接料准备时候常输出运动使能标志*)
		IF io_rDebugCurVelmpmAxisA=0 THEN
			xAxisADebugRun:=TRUE;(*使能启动*)
		END_IF
		IF io_rDebugCurVelmpmAxisB=0 THEN
			xAxisBDebugRun:=TRUE;(*使能启动*)
		END_IF

		IF i_xCurAxisA THEN(*A轴|B轴常输出加速状态|下面当前速度会根据A轴速度改变*)
			xAxisBAutoAcc:=xAxisBDebugRun;
		ELSE
			xAxisAAutoAcc:=xAxisADebugRun;
		END_IF

		IF io_rDebugCurVelmpmAxisA = io_rDebugCurVelmpmAxisB AND
			io_rDebugCurVelmpmAxisA<>0 THEN(*调试速度相等|并且不等于0 认为同步了*)
			o_xLamp_PreDrive_Debug:=TRUE;
		END_IF
		(*接料准备情况下不考虑功能按键|2021.10.14.102751
		控制由接料准备和接料解除接管*)
		i_xFuncBtn:=FALSE;
		IF xReqCut THEN
			iCutBtnClickNum:=iCutBtnClickNum+1;
			IF iCutBtnClickNum=1 THEN
				tTimeCutBtnDn:=TIME();
			END_IF
		END_IF
		IF iCutBtnClickNum>=2 THEN(*按下2次|加速或者停止*)
			iCutBtnClickNum:=0;
			IF i_xCurAxisA THEN(*A轴*)
				xAxisAAutoAcc:=NOT xAxisAAutoAcc;
			ELSE
				xAxisBAutoAcc:=NOT xAxisBAutoAcc;
			END_IF
		ELSE
			(*超过500MS未再次按下|我们认为是单击事件|根据当前轴切换自动加速*)
			IF iCutBtnClickNum>0 THEN(*已经按下了|启动计时，如果500MS内未再次按下，则清除计数*)
				IF TIME()-tTimeCutBtnDn>=tTimeDoubleClick THEN
					o_xCut_Debug:=o_xLamp_PreDrive_Debug AND NOT xAxisAccOrDecing;(*预驱同步了不在加减速才能输出裁切*)
					iCutBtnClickNum:=0;
				END_IF
			END_IF
		END_IF

		IF xReqCutCancel THEN(*接料解除|并停止速度*)
			o_xCutCancel_Debug:=TRUE;
			xAllAxisStop:=TRUE;
		END_IF
	ELSE
		IF xLastStsPreCut THEN(*退出接料状态了|全体停止*)
			xAllAxisStop:=TRUE;
		END_IF
		iCutBtnClickNum:=0;
	END_IF
	(*2021.10.14.110723 兼容的接料准备逻辑------------------------------------------*)


	IF i_xFuncBtn AND NOT xLastFuncBtn THEN(*停止|*)
		iClickNum:=iClickNum+1;
		IF iClickNum=1 THEN
			tTimeFuncBtnDn:=TIME();
		END_IF
	END_IF

	IF iClickNum>=2 THEN(*按下2次|ab轴停止*)
		iClickNum:=0;
		xAllAxisStop:=TRUE;
	ELSE
		(*超过500MS未再次按下|我们认为是单击事件|根据当前轴切换自动加速*)
		IF iClickNum>0 THEN(*已经按下了|启动计时，如果500MS内未再次按下，则清除计数*)
			IF TIME()-tTimeFuncBtnDn>=tTimeDoubleClick THEN
				IF NOT i_xFuncBtn THEN(*超过tTimeDoubleClick_Uw按钮也抬起来了|*)
					IF i_xCurAxisA THEN(*A轴*)
						IF io_rDebugCurVelmpmAxisA=0 THEN
							xAxisADebugRun:=TRUE;(*使能启动*)
						END_IF
						IF xAxisADebugRun THEN
							xAxisAAutoAcc:=NOT xAxisAAutoAcc;
						END_IF
					ELSE(**B轴*)
						IF io_rDebugCurVelmpmAxisB=0 THEN
							xAxisBDebugRun:=TRUE;(*使能启动*)
						END_IF
						IF xAxisBDebugRun THEN
							xAxisBAutoAcc:=NOT xAxisBAutoAcc;
						END_IF
					END_IF
				END_IF
				iClickNum:=0;
			END_IF
		END_IF
	END_IF

	IF i_xFuncBtn THEN(*常按下|根据当前轴 分轴停止*)
		IF TIME()-tTimeFuncBtnDn>=tTimeRetain THEN
			IF i_xCurAxisA THEN(*A轴*)
				xAxisAStop:=TRUE;
			ELSE(**B轴*)
				xAxisBStop:=TRUE;
			END_IF
		END_IF
	END_IF


	fbAxisAStopTrig(CLK:=xAxisAStop);
	fbAxisBStopTrig(CLK:=xAxisBStop);
	IF fbAxisAStopTrig.Q OR
		fbAxisBStopTrig.Q OR
		xAllAxisStop  THEN
		(*放料A轴清除*)
		IF xAxisAStop OR xAllAxisStop THEN
			xAxisADebugRun:=FALSE;
			xAxisAAutoAcc:=FALSE;
			xAxisADebugAutoAccDec:=FALSE;
		END_IF
		(*放料B轴清除*)
		IF xAxisBStop OR xAllAxisStop THEN
			xAxisBDebugRun:=FALSE;
			xAxisBAutoAcc:=FALSE;
			xAxisBDebugAutoAccDec:=FALSE;
		END_IF
	END_IF

	(*延时自动加速*)
	IF NOT xAxisAAutoAcc AND fbTon_AxisAAutoAcc.IN THEN(*取消自动加速|复位标志*)
		xAxisADebugAutoAccDec:=FALSE;
	END_IF
	fbTon_AxisAAutoAcc(IN:=xAxisAAutoAcc,PT:=T#1S);
	fbRTrig_AxisAAutoAcc(CLK:=fbTon_AxisAAutoAcc.Q);
	IF fbRTrig_AxisAAutoAcc.Q THEN(*延时1s加速|考虑到收放料使用伺服情况下的初始化动作时间*)
		xAxisADebugAutoAccDec:=TRUE;
	END_IF
	(*在关闭运动使能的时候清除自动加减速标志*)
	(*没有使能的时候关闭自动减速*)
	IF NOT xAxisADebugRun THEN
		xAxisADebugAutoAccDec:=FALSE;
	END_IF
	(*延时自动加速*)
	IF NOT xAxisBAutoAcc AND fbTon_AxisBAutoAcc.IN THEN(*取消自动加速|复位标志*)
		xAxisBDebugAutoAccDec:=FALSE;
	END_IF
	fbTon_AxisBAutoAcc(IN:=xAxisBAutoAcc,PT:=tDelayTimeAutoAccByBtn);
	fbRTrig_AxisBAutoAcc(CLK:=fbTon_AxisBAutoAcc.Q);
	IF fbRTrig_AxisBAutoAcc.Q THEN(*延时1s加速|考虑到收放料使用伺服情况下的初始化动作时间*)
		xAxisBDebugAutoAccDec:=TRUE;
	END_IF
	(*在关闭运动使能的时候清除自动加减速标志*)
	(*没有使能的时候关闭自动减速*)
	IF NOT xAxisBDebugRun THEN
		xAxisBDebugAutoAccDec:=FALSE;
	END_IF
ELSE(*非调试模式*)
	IF xAxisDebuging THEN(*调试中|如果有接料准备则退出*)
		xAxisDebuging:=FALSE;
		IF i_xStsPreCut THEN
			o_xCutCancel_Debug:=TRUE;
		END_IF
	END_IF
	iClickNum:=0;
	fbAxisAStopTrig(CLK:=FALSE);
	fbAxisBStopTrig(CLK:=FALSE);
	fbTon_AxisAAutoAcc(IN:=FALSE);
	fbRTrig_AxisAAutoAcc(CLK:=FALSE);
	fbTon_AxisBAutoAcc(IN:=FALSE);
	fbRTrig_AxisBAutoAcc(CLK:=FALSE);
	xAxisADebugRun:=FALSE;
	xAxisADebugAutoAccDec:=FALSE;
	xAxisBDebugRun:=FALSE;
	xAxisBDebugAutoAccDec:=FALSE;
	xAxisAAutoAcc:=FALSE;
	xAxisBAutoAcc:=FALSE;
END_IF
xLastFuncBtn:=i_xFuncBtn;
xLastStsPreCut:=i_xStsPreCut;

(*放A速度控制*)
rAxisAVelTar:=i_iDebugVelmpm_AxisA;
IF i_xStsPreCut THEN(*接料准备状态下|目标速度为当前轴的速度*)
	IF i_xCurAxisA THEN(*当前轴是A轴*);
	ELSE(*当前轴B轴|A轴的目标速度=B轴当前速度*)
		rAxisAVelTar:=io_rDebugCurVelmpmAxisB;
	END_IF
END_IF

KS_DebugVelCtl(
	xAxisDebugEn,
	xAxisADebugRun,
	xStopFast,
	TRUE,
	FALSE,
	FALSE,
	xAxisADebugAutoAccDec,
	LREAL_TO_INT(i_rVel_Max),
	i_iDebugGirthmm_AxisA,
	rAxisAVelTar,
	ADR(xAxisADebugRunning),
	ADR(io_rDebugCurVelmpmAxisA),
	ADR(io_rDebugCurVelrpmAxisA),
	LREAL_TO_UINT(i_rVel_Max),
	i_iCycleTime_Plc);(*2024.04.12.181058+*)

(*放B速度控制*)
rAxisBVelTar:=i_iDebugVelmpm_AxisB;
IF i_xStsPreCut THEN(*接料准备状态下|目标速度为当前轴的速度*)
	IF i_xCurAxisA THEN(*当前轴是A轴|B轴的目标速度=A轴当前速度*);
		rAxisBVelTar:=io_rDebugCurVelmpmAxisA;
	ELSE(*当前轴B轴|A轴的目标速度=B轴当前速度*);
	END_IF
END_IF

KS_DebugVelCtl(
	xAxisDebugEn,
	xAxisBDebugRun,
	xStopFast,
	TRUE,
	FALSE,
	FALSE,
	xAxisBDebugAutoAccDec,
	LREAL_TO_INT(i_rVel_Max),
	i_iDebugGirthmm_AxisB,
	rAxisBVelTar,
	ADR(xAxisBDebugRunning),
	ADR(io_rDebugCurVelmpmAxisB),
	ADR(io_rDebugCurVelrpmAxisB),
	LREAL_TO_UINT(i_rVel_Max),
	i_iCycleTime_Plc);(*2024.04.12.181058+*)

(****************************************************************************************************)

xAxisAccOrDecing:=FALSE;
IF arLastCurVel[1]<>io_rDebugCurVelmpmAxisA OR
	arLastCurVel[2]<>io_rDebugCurVelmpmAxisB THEN
	xAxisAccOrDecing:=TRUE;
END_IF

arLastCurVel[1]:=io_rDebugCurVelmpmAxisA;
arLastCurVel[2]:=io_rDebugCurVelmpmAxisB;


(*调试模式指示灯闪烁指示*)
fbTon_AxisAccOrDecingFlick(IN:=xAxisAccOrDecing,PT:=T#250MS);
IF fbTon_AxisAccOrDecingFlick.Q THEN(*加减速中使用500ms闪烁指示|*)
	xLampFlick_Debug:=NOT xLampFlick_Debug;
	fbTon_AxisAccOrDecingFlick(IN:=FALSE);
ELSIF NOT xAxisAccOrDecing THEN(*停止加减速|输出同步指示*)
	xLampFlick_Debug:=o_xLamp_PreDrive_Debug;
END_IF
o_xLampFlick_Debug:=xAxisDebugEn AND xLampFlick_Debug;
(*放料调试模式*)
(*i_pstStGrpParam^.wAxisDebug_UwRw.0*)
io_xAxisDebugEn :=xAxisDebugEn;
(*放料A*)
(*i_pstStGrpParam^.wAxisDebug_UwRw.1*)
io_xAxisADebugRun:=xAxisADebugRun;
(*i_pstStGrpParam^.wAxisDebug_UwRw.2*)
io_xAxisADebugAutoAccDec:=xAxisADebugAutoAccDec;
(*i_pstStGrpParam^.wAxisDebug_UwRw.3*)
io_xAxisADebugRunning:=xAxisADebugRunning;
(*放料B*)
(*i_pstStGrpParam^.wAxisDebug_UwRw.4*)
io_xAxisBDebugRun:=xAxisBDebugRun;
(*i_pstStGrpParam^.wAxisDebug_UwRw.5*)
io_xAxisBDebugAutoAccDec:=xAxisBDebugAutoAccDec;
(*i_pstStGrpParam^.wAxisDebug_UwRw.6*)
io_xAxisBDebugRunning:=xAxisBDebugRunning;

o_xEn:=i_xEn;