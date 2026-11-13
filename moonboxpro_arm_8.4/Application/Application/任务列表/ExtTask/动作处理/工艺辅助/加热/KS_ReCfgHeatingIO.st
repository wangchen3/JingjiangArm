(*@CES
Name=KS_ReCfgHeatingIO
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ad46a264-ec33-4c55-a1f7-e1728fbfd470
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ReCfgHeatingIO : BOOL
(*根据功能块输入需求重新分配io*)
(*2024.11.26.084858|重新处理i_byHeatingOutWay_III 调整方式的映射*)
(*2024.12.6.113819 获取过温标志|有效后停止加热输出*)

VAR_INPUT
	i_xInput				: BOOL;(*输入重新分配*)
	i_xOutput				: BOOL;(*输出重新分配*)
	i_xHeatingFlag			: BOOL;(*全体加热启动标志*)
	i_iGrpAxisNum_Pu: INT;(*色组轴的数量|*)
	i_aiGrpAxisList			: ARRAY [1..MAX_UNIT_NUM] OF INT;(*系的轴列表*)
	i_paxAxisStartEn		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*轴启动使能|有效后按钮开关才能起作用*)
	i_paxStartKnob			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*全体启动,每个轴旋钮输入*)
	i_paxStartOrStopBtn		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴的启动停止按钮*)
	i_paxNeedStop			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单轴需要停止标志*)
	i_paxAxisStarted		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*单个轴的启动输出标志|实际处于启动状态，
																			可以根据i_paxNeedStop这个变量控制实际输出*)
	i_paxHotBlowerEn		: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*热风启动标志*)
	i_byHeatingOutWay_III	: BYTE;(*加热三档输出方式选择|0: 同时调整三档
														  1: 调整最高档@为了heatingctl函数兼容修改了调整最低档(2024.11.26.084440)
														  2: 超过1档保留最低档
														  3: 调整最高档@移动到第三种(2024.11.26.084515)*)
	i_axHeating_I :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*一档加热输入*)
	i_axHeating_II :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*二档加热输入*)
	i_axHeating_III :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*三档热输入*)
	i_axHeating_Button :ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*加热按钮输入*)
	i_axTemReachToTarget : ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*加热未到设定标志*)
	i_axOvertemperature   : ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*超温标志*)
	i_paxLamp_Heating :POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*加热输出*)
	i_paxRel_Heating_I	:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*一档输出*)
	i_paxRel_Heating_II  :POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*二档输出*)
	i_paxRel_Heating_III  :POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*三档输出*)
	i_paxLamp_AllHeating :POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*全体加热输出*)
	
	i_pxLamp_AllHeating :POINTER TO   BOOL;(*全体加热输出*)
END_VAR

VAR
	iN: INT;
	iUnitId: INT;
	xNeedOpenHeatingOut: BOOL;(*需要打开加热输出|2022.4.10.223107*)
END_VAR

{IMPLEMENTATION}
IF i_paxAxisStartEn<>0 AND
	i_paxStartKnob<>0 AND
	i_paxNeedStop<>0 AND
 	i_paxStartOrStopBtn<>0 AND
	i_paxAxisStarted<>0 AND
	i_paxHotBlowerEn<>0 THEN
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
				i_paxStartKnob^[iUnitId]:=i_axHeating_I[iUnitId] OR
										i_axHeating_II[iUnitId] OR
										i_axHeating_III[iUnitId];
				i_paxStartOrStopBtn^[iUnitId]:=i_axHeating_Button[iUnitId];
(*				i_paxNeedStop^[iUnitId]:=i_pastStIOMap_AxisExtra^[iUnitId].i_xTemReachToTarget;*)
				i_paxNeedStop^[iUnitId]:=FALSE;(*2022.4.10.222707 加热标志打开后只能同步关闭加热或者旋钮切换到off或者按钮复位*)
				i_paxAxisStartEn^[iUnitId]:=i_paxHotBlowerEn^[iUnitId];
			END_IF
		END_FOR
	ELSIF i_xOutput THEN
		FOR iN:=1 TO i_iGrpAxisNum_Pu  BY 1 DO
			iUnitId:=i_aiGrpAxisList[iN];
			IF iUnitId>0 AND iUnitId <= MAX_UNIT_NUM THEN(*输出循环到收牵，这样加热输出灯就可以配到收牵上了|2020.1.9.094955*)
				i_paxLamp_Heating^[iUnitId]:=i_paxAxisStarted^[iUnitId];
				i_paxRel_Heating_I^[iUnitId]:=FALSE;(*复位*)
				i_paxRel_Heating_II^[iUnitId]:=FALSE;
				i_paxRel_Heating_III^[iUnitId]:=FALSE;
				(*加热打开后未到温度置位需要打开加热输出标志*)
				xNeedOpenHeatingOut:=NOT i_axTemReachToTarget[iUnitId] AND i_paxAxisStarted^[iUnitId];
				CASE i_byHeatingOutWay_III OF
					3:(* 调整最高档*)
						IF i_axHeating_III[iUnitId] THEN
							i_paxRel_Heating_I^[iUnitId]:=i_paxAxisStarted^[iUnitId];
							i_paxRel_Heating_II^[iUnitId]:=i_paxAxisStarted^[iUnitId];
							i_paxRel_Heating_III^[iUnitId]:=xNeedOpenHeatingOut;
						ELSIF i_axHeating_II[iUnitId]THEN
							i_paxRel_Heating_I^[iUnitId]:=i_paxAxisStarted^[iUnitId];
							i_paxRel_Heating_II^[iUnitId]:=xNeedOpenHeatingOut;
						ELSIF i_axHeating_I[iUnitId]  THEN
							i_paxRel_Heating_I^[iUnitId]:=xNeedOpenHeatingOut;
						END_IF
					2:(*超过1档保留最低档*)
						IF i_axHeating_III[iUnitId] THEN
							i_paxRel_Heating_I^[iUnitId]:=i_paxAxisStarted^[iUnitId];
							i_paxRel_Heating_II^[iUnitId]:=xNeedOpenHeatingOut;
							i_paxRel_Heating_III^[iUnitId]:=xNeedOpenHeatingOut;
						ELSIF i_axHeating_II[iUnitId]  THEN
							i_paxRel_Heating_I^[iUnitId]:=i_paxAxisStarted^[iUnitId];
							i_paxRel_Heating_II^[iUnitId]:=xNeedOpenHeatingOut;
						ELSIF i_axHeating_I[iUnitId] THEN
							i_paxRel_Heating_I^[iUnitId]:=xNeedOpenHeatingOut;
						END_IF
					1:(* 调整最低档*)
						IF i_axHeating_III[iUnitId] THEN
							i_paxRel_Heating_II^[iUnitId]:=i_paxAxisStarted^[iUnitId];
							i_paxRel_Heating_III^[iUnitId]:=i_paxAxisStarted^[iUnitId];
						ELSIF i_axHeating_II[iUnitId] THEN
							i_paxRel_Heating_II^[iUnitId]:=i_paxAxisStarted^[iUnitId];
						ELSIF i_axHeating_I[iUnitId] THEN;
						END_IF
						i_paxRel_Heating_I^[iUnitId]:=xNeedOpenHeatingOut;

				ELSE(*三档同时控制*)
					i_paxRel_Heating_I^[iUnitId]:=xNeedOpenHeatingOut AND(i_axHeating_I[iUnitId] OR
																		i_axHeating_II[iUnitId] OR
																		i_axHeating_III[iUnitId]);
					i_paxRel_Heating_II^[iUnitId]:=xNeedOpenHeatingOut AND(i_axHeating_II[iUnitId] OR
																		i_axHeating_III[iUnitId]);
					i_paxRel_Heating_III^[iUnitId]:=xNeedOpenHeatingOut AND i_axHeating_III[iUnitId];
				END_CASE

				(*超温了 就把所有的输出清零@2024.12.6.132546*)
				IF i_axOvertemperature[iUnitId] THEN
					i_paxRel_Heating_I^[iUnitId]:=FALSE;
					i_paxRel_Heating_II^[iUnitId]:=FALSE;
					i_paxRel_Heating_III^[iUnitId]:=FALSE;
				END_IF
				i_paxLamp_AllHeating^[iUnitId]:=i_xHeatingFlag;
			END_IF
		END_FOR
		i_pxLamp_AllHeating^ := i_xHeatingFlag ; 
	END_IF
END_IF
