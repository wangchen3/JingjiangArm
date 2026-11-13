(*@CES
Name=Action_ActCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=d708d637-9a54-43a2-a2bb-b0bab69a9e9f
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*系的色组数量有效|*)
	i_pstStEvtReq<>0 AND
	i_pstStSysParam <> 0 AND
	i_PastStIOMap_Axis_Extra_FE<> 0 THEN

	(*2024.01.22.143013+*)
	IF i_iCycleTime_Plc<=0 THEN
		i_iCycleTime_Plc:=gc_EXT_TSK_CYCLE_TIME;
	END_IF

		KS_ReCfgHotBlowerIO(
			TRUE(*i_xInput*),
			FALSE(*i_xOutput*),
			o_xHotBlowerFlag(*i_xHotBlowerFlag*),
			i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
			i_aiGrpAxisList(*i_aiGrpAxisList*),
			ADR(axAxisStartEn)(*i_paxAxisStartEn*),
			ADR(axAxisStartKnob)(*i_paxStartKnob*),
			ADR(axStartOrStopBtn)(*i_paxStartOrStopBtn*),
			ADR(axNeedStop)(*i_paxNeedStop*),
			ADR(o_axHotBlowerEn)(*i_paxAxisStarted*),
			byHotBlowerStopDelayTime_In,(*byHotBlowerStopDelayTime*)(*热风延时关闭时间|S*)
			ADR(atHotBlowerDelayTimeSa),(*i_patAxisDelayTimeSa	*)(*延时开始时间|用于和当前时间对比检查是否到时间*)
			ADR(o_xFlag_HotBlowerStopping),(*i_pxFlag_AxisStopping   *)(*热风停止中|至少一个轴*)
			axHotBlower_In, 
			axHotBlower_Button_In,
			axHotBlower_Err_In,
			axLamp_Heating_In,
			ADR(axRel_HotBlower_Out),
			ADR(axLamp_HotBlower_Out),
			ADR(axLamp_AllHotBlower_Out),
			ADR(xLamp_AllHotBlower_Out));
	xHotBlowerEn:=i_xEn;
	(*排风限制热风开并且限制热风关|*)
	IF i_xAirExhaustLimit THEN
		IF i_xAirExhaustFinishFlag THEN;
		ELSE(*排风没启动的时候热风需要关闭*)
			xHotBlowerEn:=FALSE;
		END_IF
	ELSE;
	END_IF

	IF i_xStopHotBlowerWhenEstop THEN(*急停时关闭热风标志*)
		IF xFlag_Estop_In OR i_pstStEvtReq^.xReqEstop THEN(*2022.3.22.145825 增加了急停按键*)
			xHotBlowerEn:=FALSE;
		END_IF
	END_IF


	fbKS_FB_HotBlowerSys(
		i_xEn:= xHotBlowerEn,
		i_xAllStartOrStop_Trig:=i_pstStEvtReq^.xReqAllHotBlower,
		i_xStartByKnob:= i_xHotBlowerByKnob,
		(*2021.7.29.160651 改成s单位了*)
		i_iAllStartDelayTime:= iDelayMsec_HeatBlower_In(*i_pstStGrpParam^.iDelayMsec_HeatBlower/1000*),(*输入值为ms*)
		i_iCycleTime_Plc:= i_iCycleTime_Plc,
		i_iAxisSum:= i_iGrpAxisNum_Pu,
		i_paiAxisNumList:= ADR(i_aiGrpAxisList),
		i_paxAxisStartEn:=ADR(axAxisStartEn),
		i_paxStartKnob:=ADR(axAxisStartKnob) ,
		i_paxStartOrStopBtn:=ADR(axStartOrStopBtn) ,
		i_paxNeedStop:= ADR(axNeedStop),
		i_paxAxisStarted:=ADR(o_axHotBlowerEn) ,
		o_xEn=> ,
		o_xAllStarted=> o_xHotBlowerFlag,
		o_xAutoStartDne=> , 
		o_iStartedSum=>iStartedSum );

		KS_ReCfgHotBlowerIO(
			FALSE(*i_xInput*),
			TRUE(*i_xOutput*),
			o_xHotBlowerFlag(*i_xHotBlowerFlag*),
			i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
			i_aiGrpAxisList(*i_aiGrpAxisList*),
			ADR(axAxisStartEn)(*i_paxAxisStartEn*),
			ADR(axAxisStartKnob)(*i_paxStartKnob*),
			ADR(axStartOrStopBtn)(*i_paxStartOrStopBtn*),
			ADR(axNeedStop)(*i_paxNeedStop*),
			ADR(o_axHotBlowerEn)(*i_paxAxisStarted*),
			byHotBlowerStopDelayTime_In,(*byHotBlowerStopDelayTime*)(*热风延时关闭时间|S*)
			ADR(atHotBlowerDelayTimeSa),(*i_patAxisDelayTimeSa	*)(*延时开始时间|用于和当前时间对比检查是否到时间*)
			ADR(o_xFlag_HotBlowerStopping),(*i_pxFlag_AxisStopping   *)(*热风停止中|至少一个轴*)
			axHotBlower_In, 
			axHotBlower_Button_In,
			axHotBlower_Err_In,
			axLamp_Heating_In,
			ADR(axRel_HotBlower_Out),
			ADR(axLamp_HotBlower_Out),
			ADR(axLamp_AllHotBlower_Out),
			ADR(xLamp_AllHotBlower_Out));

	(*2022.3.22.154537*)
(*	Action_AirHotFreq;*)

	(*2022.5.11.191101*)
	SYSMEMSET(ADR(o_axHotBlowerEn_Act),0,SIZEOF(o_axHotBlowerEn_Act));
	FOR iN:=1 TO (*i_iGrpAxisNum_Pu*)i_iGrpAxisNum_Pu BY  1 DO(*2024.7.1.165643 将索引上限修改到了总轴数*)
		iUnitId:=i_aiGrpAxisList[iN];
	
		o_axHotBlowerEn_Act[iUnitId]:=o_axHotBlowerEn[iUnitId] AND
										axHotBlower_Opened_Act_In[iUnitId] ;
	END_FOR

ELSE
	o_iErNo:= -1;
END_IF