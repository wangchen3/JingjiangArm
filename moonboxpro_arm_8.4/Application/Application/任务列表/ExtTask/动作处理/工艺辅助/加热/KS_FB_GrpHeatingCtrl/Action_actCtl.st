(*@CES
Name=Action_actCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=67743554-120a-48e0-92b3-a433235191e6
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*系的色组数量有效|*)
	i_pstStEvtReq<>0 AND
	i_paxHotBlowerEn<>0 AND
	i_pstStSysParam <> 0 AND
	i_PastStIOMap_Axis_Extra_FE<> 0 THEN

	(*2024.01.22.143013+*)
	IF i_iCycleTime_Plc<=0 THEN
		i_iCycleTime_Plc:=gc_EXT_TSK_CYCLE_TIME;
	END_IF
	(*输入*)
	KS_ReCfgHeatingIO(
		TRUE(*i_xInput*),
		FALSE(*i_xOutput*),
		o_xHeatingFlag(*i_xHeatingFlag*),
		i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
		i_aiGrpAxisList(*i_aiGrpAxisList*),
		ADR(axAxisStartEn)(*i_paxAxisStartEn*),
		ADR(axAxisStartKnob)(*i_paxStartKnob*),
		ADR(axStartOrStopBtn)(*i_paxStartOrStopBtn*),
		ADR(axNeedStop)(*i_paxNeedStop*),
		ADR(axAxisStarted)(*i_paxAxisStarted*),
		i_paxHotBlowerEn(*i_paxHotBlowerEn*),
		i_byHeatingOutWay_III(*i_byHeatingOutWay_III*),
		axHeating_I_In,
		axHeating_II_In ,
		axHeating_III_In,
		axHeating_Button_In ,
		axTemReachToTarget_In,
		axOvertemperature_In ,
		ADR(axLamp_Heating_Out) ,
		ADR(axRel_Heating_I_Out	),
		ADR(axRel_Heating_II_Out) ,
		ADR(axRel_Heating_III_Out ) ,
		ADR(axLamp_AllHeating_Out ),
		ADR(xLamp_AllHeating_Out));

	(*条件重新修改了|2021.7.27.104346*)
	IF NOT i_xAirHotFlag THEN(*热风关闭的时候我们取消全体加热*)
		i_pstStEvtReq^.xReqAllHeating:=FALSE;
		IF o_xHeatingFlag THEN(*加热的话|关闭加热*)
			IF NOT fbKS_FB_HeatTreatmentSys.i_xAllStartOrStop_Trig THEN(*沿被清除了*)
				IF xLastAirHotFlag THEN(*热风打开过，停止全体加热*)
					i_pstStEvtReq^.xReqAllHeating:=TRUE;
					xLastAirHotFlag:=i_xAirHotFlag;
				END_IF
			END_IF
		ELSE
			xLastAirHotFlag:=i_xAirHotFlag;
		END_IF
	ELSE
		xLastAirHotFlag:=i_xAirHotFlag;
	END_IF

	fbKS_FB_HeatTreatmentSys(
		i_xEn:=i_xEn,(*热风开启才能启动使能*)(*2020.11.24.105549 不再将全体热风作为功能块使能条件了*)
		i_xAllStartOrStop_Trig:= i_pstStEvtReq^.xReqAllHeating ,
		i_xStartByKnob:=FALSE ,
		(*2021.7.29.160715 单位改到s*)
		i_iAllStartDelayTime:= iDelayMsec_Heat_In(*i_pstStGrpParam^.iDelayMsec_Heat/1000*),(*输入值为ms*)
		i_iCycleTime_Plc:= i_iCycleTime_Plc,
		i_iAxisSum:= i_iGrpAxisNum_Pu,
		i_paiAxisNumList:= ADR(i_aiGrpAxisList),
		i_paxAxisStartEn:=ADR(axAxisStartEn),
		i_paxStartKnob:=ADR(axAxisStartKnob) ,
		i_paxStartOrStopBtn:=ADR(axStartOrStopBtn) ,
		i_paxNeedStop:= ADR(axNeedStop),
		i_paxAxisStarted:=ADR(axAxisStarted) ,
		o_xEn=> ,
		o_xAllStarted=>o_xHeatingFlag,
		o_xAutoStartDne=> ,
		o_iStartedSum=> );

	(*输出*)
		KS_ReCfgHeatingIO(
		FALSE(*i_xInput*),
		TRUE(*i_xOutput*),
		o_xHeatingFlag(*i_xHeatingFlag*),
		i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
		i_aiGrpAxisList(*i_aiGrpAxisList*),
		ADR(axAxisStartEn)(*i_paxAxisStartEn*),
		ADR(axAxisStartKnob)(*i_paxStartKnob*),
		ADR(axStartOrStopBtn)(*i_paxStartOrStopBtn*),
		ADR(axNeedStop)(*i_paxNeedStop*),
		ADR(axAxisStarted)(*i_paxAxisStarted*),
		i_paxHotBlowerEn(*i_paxHotBlowerEn*),
		i_byHeatingOutWay_III(*i_byHeatingOutWay_III*),
		axHeating_I_In,
		axHeating_II_In ,
		axHeating_III_In,
		axHeating_Button_In ,
		axTemReachToTarget_In,
		axOvertemperature_In ,
		ADR(axLamp_Heating_Out) ,
		ADR(axRel_Heating_I_Out	),
		ADR(axRel_Heating_II_Out) ,
		ADR(axRel_Heating_III_Out ) ,
		ADR(axLamp_AllHeating_Out ),
		
		ADR(xLamp_AllHeating_Out));
(*
(*温控-驱动器提供温控-控制输出2022.9.24.152606*)
(*2022.9.24.162543|||32767非法值||32768温度异常*)
	FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
		iUnitId:= i_aiGrpAxisList[iN];

		(*获取到了*)
	END_FOR
*)
ELSE
	o_iErNo:= -1;
END_IF