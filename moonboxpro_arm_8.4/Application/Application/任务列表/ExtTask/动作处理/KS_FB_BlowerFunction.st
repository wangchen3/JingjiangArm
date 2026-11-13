(*@CES
Name=KS_FB_BlowerFunction
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d1a93ad3-e4c3-4af6-9dda-58720c2c75d3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_BlowerFunction
VAR_INPUT
	i_xEn					:BOOL;(*功能使能*)
	i_xAllStartOrStop_Trig	:BOOL;(*全体启动或者停止|沿触发|延时启动*)
	i_xStartByKnob			:BOOL;(*单轴启动根据旋钮开关标志|用于开关控制启动的逻辑|无则不输入*)
	i_iAllStartDelayTime	:INT;(*全体启动延时S*)
	i_iCycleTime_Plc		:INT;(*程序执行时间*)
	i_iAxisSum				:INT;(*轴总数*)
	i_paiAxisNumList		:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF INT;(*轴号列表*)
	i_paxAxisStartEn		:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴启动使能|有效后按钮开关才能起作用*)
	i_paxStartKnob			:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*全体启动,每个轴旋钮输入*)
	i_paxStartOrStopBtn		:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴的启动停止按钮*)
	i_paxNeedStop			:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴需要停止输出标志*)
	i_paxAxisStarted		:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单个轴的启动输出标志|实际处于启动状态，
																			可以根据i_paxNeedStop这个变量控制实际输出*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xAllStarted:BOOL;(*全体启动标志*)
	o_xAutoStartDne:BOOL;(*自动启动轴启动完成*)
	o_iStartedSum:INT;(*启动的总数*)
END_VAR
VAR
	iN: INT;
	xEned: BOOL;(*进入过使能状态*)
	iAxisNum: INT;(*轴号*)
	xPreAllStartOrStop_Trig: BOOL;(*全部启动或者停止上个周期标志*)
	axAllStartedTemp:ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单个轴的启动了*)
	axAutoStarted: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*自动启动的标志*)
	axPreStartOrStopBtn: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*手动按钮由于沿处理标志*)
	xTimeUp: BOOL;(*计时时间到*)
	iCnt: INT;(*计数值*)
	(*旋钮取沿|用于旋钮控制启动停止方式*)
	afbKnobRTrig: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbKnobFTrig: ARRAY [1..MAX_UNIT_NUM] OF F_TRIG;
END_VAR

{IMPLEMENTATION}
IF i_paxStartKnob<>0 AND
	i_paxNeedStop<>0 AND
 	i_paxStartOrStopBtn<>0 AND
	i_paxAxisStartEn<>0 AND
	i_paiAxisNumList<>0 AND
	i_paxAxisStarted<>0 THEN

	IF i_iCycleTime_Plc<=0 THEN
		i_iCycleTime_Plc:=gc_EXT_TSK_CYCLE_TIME;
	END_IF

	IF i_xEn THEN
		(*旋钮控制*)
		IF i_xStartByKnob THEN(*根据旋钮状态控制|按钮将不起作用*)
			o_xAllStarted:=FALSE;
			FOR iN:=1 TO i_iAxisSum BY 1 DO
				iAxisNum:=i_paiAxisNumList^[iN];
				IF iAxisNum>0 AND iAxisNum<=MAX_UNIT_NUM THEN;
					afbKnobRTrig[iAxisNum](CLK:=i_paxStartKnob^[iAxisNum]);
					afbKnobFTrig[iAxisNum](CLK:=i_paxStartKnob^[iAxisNum]);
					IF afbKnobRTrig[iAxisNum].Q THEN
						axAllStartedTemp[iAxisNum]:=TRUE;
					ELSIF afbKnobFTrig[iAxisNum].Q THEN
						axAllStartedTemp[iAxisNum]:=FALSE;
					END_IF
				END_IF
			END_FOR
		ELSE
(*--------------------------自动部分START-------------------------*)
			xTimeUp:=FALSE;
			(*全体启动部分*)
			IF  i_xAllStartOrStop_Trig AND NOT xPreAllStartOrStop_Trig THEN(*启动按键按下*)
				o_xAllStarted:=NOT o_xAllStarted;
				IF o_xAllStarted THEN(*启动了|清零周期计数|并输出时间到标志打开第一个轴*)
					iCnt:=0;
					xTimeUp:=TRUE;
				END_IF
			END_IF

			(*计时部分*)
			iCnt:=iCnt+1;
			IF o_xAutoStartDne THEN(*自动启动完成后清零计数值*)
				iCnt:=0;
			END_IF
			IF iCnt>i_iAllStartDelayTime*1000/i_iCycleTime_Plc THEN(*时间到*)
				iCnt:=0;
				xTimeUp:=TRUE;
			END_IF

			(*自动控制延时启动*)
			FOR iN:=1 TO i_iAxisSum BY 1 DO
				iAxisNum:=i_paiAxisNumList^[iN];
				IF iAxisNum>0 AND iAxisNum<=MAX_UNIT_NUM THEN(*轴号是否合法*)
					IF o_xAllStarted THEN(*全体启动了|延时启动|只自动启动一次*)
						IF i_paxStartKnob^[iAxisNum] AND i_paxAxisStartEn^[iAxisNum] THEN(*开关打开了*)
							IF NOT axAutoStarted[iAxisNum]  THEN(*未自动启动*)
								IF NOT axAllStartedTemp[iAxisNum] THEN(*未启动*)
									IF xTimeUp THEN(*计时到了*)
										axAllStartedTemp[iAxisNum]:=TRUE;
										axAutoStarted[iAxisNum]:=TRUE;
										xTimeUp:=FALSE;
									END_IF
								ELSE
									axAutoStarted[iAxisNum]:=TRUE;
								END_IF
							END_IF
						END_IF
					END_IF

					IF (NOT o_xAllStarted OR
						NOT i_paxStartKnob^[iAxisNum] OR
						NOT i_paxAxisStartEn^[iAxisNum])AND
						axAutoStarted[iAxisNum] THEN(*已经自动打开了|我们关闭它*)
						axAllStartedTemp[iAxisNum]:=FALSE;
						axAutoStarted[iAxisNum]:=FALSE;
					END_IF
				END_IF
			END_FOR

			(*查看自动启动是否完成*)
			o_xAutoStartDne:=TRUE;
			IF o_xAllStarted THEN(*全体启动了*)
				FOR iN:=1 TO i_iAxisSum BY 1 DO
					iAxisNum:=i_paiAxisNumList^[iN];
					IF i_paxStartKnob^[iAxisNum] AND
						i_paxAxisStartEn^[iAxisNum] AND
						NOT axAutoStarted[iAxisNum] THEN
						o_xAutoStartDne:=FALSE;
						EXIT;
					ELSE;
					END_IF
				END_FOR
			END_IF
(*--------------------------自动部分END-------------------------*)
		END_IF


(*--------------------------手动部分START-------------------------*)
		(*手动控制按钮启动停止部分*)
		FOR iN:=1 TO i_iAxisSum BY 1 DO
			iAxisNum:=i_paiAxisNumList^[iN];
			IF i_paxStartOrStopBtn^[iAxisNum] AND
				NOT axPreStartOrStopBtn[iAxisNum] THEN(*按下按钮*)
				axAllStartedTemp[iAxisNum]:=NOT axAllStartedTemp[iAxisNum];
			END_IF

			(*在这个循环里面处理轴启动使能标志对输出的影响*)
			IF NOT i_paxAxisStartEn^[iAxisNum] THEN;
				axAllStartedTemp[iAxisNum]:=FALSE;
			END_IF
		END_FOR
(*--------------------------手动部分END-------------------------*)
		xEned:=TRUE;
	ELSE(*功能块未使能*)
		IF xEned THEN
			xEned:=FALSE;
			o_xAllStarted:=FALSE;
			o_xAutoStartDne:=FALSE;
			FOR  iN:=1 TO i_iAxisSum BY 1 DO
				iAxisNum:=i_paiAxisNumList^[iN];
				IF iAxisNum>0 AND iAxisNum<=MAX_UNIT_NUM THEN
					axAllStartedTemp[iAxisNum]:=FALSE;
					axAutoStarted[iAxisNum]:= FALSE(*TRUE*); (* 2021.3.31.092022/参照2021.3.32在欧泰715机器上更新(汕头彭城) *)
				END_IF
			END_FOR
		END_IF
	END_IF


	(*最终输出控制*)
	o_iStartedSum:=0;
	FOR  iN:=1 TO i_iAxisSum BY 1 DO
		iAxisNum:=i_paiAxisNumList^[iN];
		i_paxAxisStarted^[iAxisNum]:=axAllStartedTemp[iAxisNum];
		IF i_paxNeedStop^[iAxisNum] THEN
			i_paxAxisStarted^[iAxisNum]:=FALSE;
		END_IF

		(*统计实际输出的个数*)
		IF i_paxAxisStarted^[iAxisNum] THEN
			o_iStartedSum:=o_iStartedSum+1;
		END_IF

		(* 2020.11.3.110550|lyt|修复已知的bug *)
		axPreStartOrStopBtn[iAxisNum]:=i_paxStartOrStopBtn^[iAxisNum];
	END_FOR

	xPreAllStartOrStop_Trig:=i_xAllStartOrStop_Trig;
END_IF
o_xEn:=i_xEn;