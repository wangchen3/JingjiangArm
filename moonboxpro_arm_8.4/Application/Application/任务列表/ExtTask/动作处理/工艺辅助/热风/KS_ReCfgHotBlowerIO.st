(*@CES
Name=KS_ReCfgHotBlowerIO
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=38ee2e16-ce71-4341-b3d7-8aa23afc131e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ReCfgHotBlowerIO : BOOL
VAR_INPUT
	i_xInput				: BOOL;(*输入重新分配*)
	i_xOutput				: BOOL;(*输出重新分配*)
	i_xHotBlowerFlag		: BOOL;(*全体热风启动标志*)
	i_iGrpAxisNum_Pu         : INT ; 
	i_aiGrpAxisList			: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系的轴列表*)
	i_paxAxisStartEn		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴启动使能|有效后按钮开关才能起作用*)
	i_paxStartKnob			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*全体启动,每个轴旋钮输入*)
	i_paxStartOrStopBtn		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴的启动停止按钮*)
	i_paxNeedStop			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴需要停止标志*)
	i_paxAxisStarted		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单个轴的启动输出标志|实际处于启动状态，
																			可以根据i_paxNeedStop这个变量控制实际输出*)
	i_byHotBlowerStopDelayTime: BYTE;(*热风延时关闭时间|S*)
	i_patAxisDelayTimeSa	: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF TIME;(*延时开始时间|用于和当前时间对比检查是否到时间*)
	i_pxFlag_AxisStopping   : POINTER TO BOOL;(*热风停止中|至少一个轴*)
	i_axHotBlower :ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_axHotBlower_Button:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_axHotBlower_Err:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_axLamp_Heating:ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxRel_HotBlower:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxLamp_HotBlower:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxLamp_AllHotBlower:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_pxLamp_AllHotBlower		:POINTER TO BOOL;
END_VAR
VAR
	iUnitId: INT;
	iN: INT;
	xAxisStartEn: BOOL;
	xNeedStop: BOOL;
	tTimeCur: TIME;
	xAxisSts: BOOL;
	axAxisStoping		:  ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴热风停止中|用于加热时延时关闭*)
	xFlag_AxisStopping	: BOOL;
END_VAR

{IMPLEMENTATION}
IF i_paxAxisStartEn<>0 AND
	i_paxStartKnob<>0 AND
	i_paxNeedStop<>0 AND
 	i_paxStartOrStopBtn<>0 AND
	i_paxAxisStarted<>0 AND
	i_pxFlag_AxisStopping<>0 AND
	i_patAxisDelayTimeSa<>0 THEN
	tTimeCur:=TIME();
	IF i_xInput THEN
		FOR iN:=1 TO MAX_UNIT_NUM  BY 1 DO
			i_paxStartKnob^[iN]:=FALSE;
			i_paxStartOrStopBtn^[iN]:=FALSE;
			i_paxNeedStop^[iN]:=FALSE;
			i_paxAxisStartEn^[iN]:=FALSE;
		END_FOR

		FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];
			IF iUnitId>0 AND iUnitId<= MAX_UNIT_NUM THEN
				i_paxStartKnob^[iUnitId]:=i_axHotBlower[iUnitId];
				i_paxStartOrStopBtn^[iUnitId]:=i_axHotBlower_Button[iUnitId];
				xNeedStop:=i_axHotBlower_Err[iUnitId];
				i_paxNeedStop^[iUnitId]:=xNeedStop;

				xAxisStartEn:=TRUE;
				i_paxAxisStartEn^[iUnitId]:=xAxisStartEn;
			END_IF
		END_FOR
	ELSIF i_xOutput THEN
		FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];
			IF iUnitId>0 AND iUnitId <= MAX_UNIT_NUM THEN(*输出循环到收牵，这样热风输出灯就可以配到收牵上了|2020.1.9.094955*)
				IF i_paxAxisStarted^[iUnitId] THEN(*如果打开的话|我们直接输出临时变量*)
					xAxisSts:=TRUE;
				ELSE(*关闭时  保持之前状态*)
					IF i_byHotBlowerStopDelayTime=0 THEN(*延时=0的时候直接关闭*)
						xAxisSts:=FALSE;
					ELSE
						xAxisSts:=i_paxRel_HotBlower^[iUnitId];
					END_IF
					IF xAxisSts THEN(**)
						axAxisStoping[iUnitId]:=TRUE;(*停止过程中*)
					END_IF
				END_IF

				(*2021.7.27.115739  增加了加热打开时 热风延时关闭|*)
				IF i_axLamp_Heating[iUnitId] THEN(*处于加热过程中|保留当前时间*)
					i_patAxisDelayTimeSa^[iUnitId]:=tTimeCur;
				ELSE(*加热关闭了|统计关闭时间-*)
					IF tTimeCur-i_patAxisDelayTimeSa^[iUnitId]>=WORD_TO_TIME(BYTE_TO_WORD(i_byHotBlowerStopDelayTime)*1000) THEN(*时间到了|如果需要关闭，可正常关闭*)
						IF NOT i_paxAxisStarted^[iUnitId] THEN(*热风关闭的时候*)
							xAxisSts:=FALSE;
							axAxisStoping[iUnitId]:=FALSE;
						END_IF
					ELSE;
					END_IF
				END_IF

				IF axAxisStoping[iUnitId] THEN(*有一个轴停止中|*)
					xFlag_AxisStopping:=TRUE;
				END_IF

				i_paxLamp_HotBlower^[iUnitId]:=(*i_paxAxisStarted^[iUnitId]*)xAxisSts;
				i_paxRel_HotBlower^[iUnitId]:=(*i_paxAxisStarted^[iUnitId]*)xAxisSts;
(*				i_pastStIOMap_AxisExtra^[iUnitId].o_xLamp_AllHotBlower:=i_xHotBlowerFlag OR xFlag_AxisStopping;*)
			END_IF
		END_FOR

		FOR iN:=1 TO i_iGrpAxisNum_Pu + 2  BY 1 DO
			(*输出到牵引，*)
			IF  iN >=  i_iGrpAxisNum_Pu THEN
				i_pxLamp_AllHotBlower^ :=  i_xHotBlowerFlag OR xFlag_AxisStopping;; 
			ELSE
				iUnitId:=i_aiGrpAxisList[iN];
				IF iUnitId>0 AND iUnitId <= MAX_UNIT_NUM THEN(*输出循环到收牵，这样热风输出灯就可以配到收牵上了|2020.1.9.094955*)
					i_paxLamp_AllHotBlower^[iUnitId]:=i_xHotBlowerFlag OR xFlag_AxisStopping;
				END_IF
			END_IF
		END_FOR
		i_pxFlag_AxisStopping^:=xFlag_AxisStopping;
	END_IF
END_IF