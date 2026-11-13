(*@CES
Name=Action_Actctl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=bd103fbc-9b5b-496e-a85e-e809820287c1
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*系的色组数量有效|*)
	i_pstStEvtReq<>0 AND 
	i_PastStIOMap_Axis_Extra_FE<> 0 AND 
	i_pastStIOMap_Main_FE<> 0 THEN

	(*2024.01.22.143013+*)
	IF i_iCycleTime_Plc<=0 THEN
		i_iCycleTime_Plc:=gc_EXT_TSK_CYCLE_TIME;
	END_IF

	KS_ReCfgCoolBlowerIO(
		TRUE(*i_xInput*),
		FALSE(*i_xOutput*),
		o_xCoolBlowerFlag(*i_xCoolBlowerFlag*),
		i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
		i_aiGrpAxisList(*i_aiGrpAxisList*),
		ADR(axAxisStartEn)(*i_paxAxisStartEn*),
		ADR(axAxisStartKnob)(*i_paxStartKnob*),
		ADR(axStartOrStopBtn)(*i_paxStartOrStopBtn*),
		ADR(axNeedStop)(*i_paxNeedStop*),
		ADR(axAxisStarted)(*i_paxAxisStarted*),
		axCoolBlower_In	,
		axCoolBlower_Button_In	,
		ADR(axLamp_CoolBlower_Out),
		ADR(axRel_CoolBlower_Out),	
		ADR(axLamp_AllCoolBlower_Out),
		ADR(xLamp_AllCoolBlower_Out));

	xCoolBlowerEn:=i_xEn;
	IF i_xStopCoolBlowerWhenEstop THEN(*急停时关闭冷风标志*)
		IF xFlag_Estop_In OR
			i_pstStEvtReq^.xReqEstop THEN
			xCoolBlowerEn:=FALSE;
		END_IF
	END_IF

	fbKS_FB_CoolBlowerSys(
		i_xEn:= xCoolBlowerEn,
		i_xAllStartOrStop_Trig:=i_pstStEvtReq^.xReqAllCoolBlower,
		i_xStartByKnob:= i_xCoolBlowerByKnob,
		i_iAllStartDelayTime:= 3,(*输入值为s*)
		i_iCycleTime_Plc:= i_iCycleTime_Plc,
		i_iAxisSum:= i_iGrpAxisNum_Pu,
		i_paiAxisNumList:= ADR(i_aiGrpAxisList),
		i_paxAxisStartEn:=ADR(axAxisStartEn),
		i_paxStartKnob:=ADR(axAxisStartKnob) ,
		i_paxStartOrStopBtn:=ADR(axStartOrStopBtn) ,
		i_paxNeedStop:= ADR(axNeedStop),
		i_paxAxisStarted:=ADR(axAxisStarted) ,
		o_xEn=> , 
		o_xAllStarted=> o_xCoolBlowerFlag,
		o_xAutoStartDne=> , 
		o_iStartedSum=> iStartedSum);


		KS_ReCfgCoolBlowerIO(
		FALSE(*i_xInput*),
		TRUE(*i_xOutput*),
		o_xCoolBlowerFlag(*i_xCoolBlowerFlag*),
		i_iGrpAxisNum_Pu(*i_iGrpAxisTotalNum*),
		i_aiGrpAxisList(*i_aiGrpAxisList*),
		ADR(axAxisStartEn)(*i_paxAxisStartEn*),
		ADR(axAxisStartKnob)(*i_paxStartKnob*),
		ADR(axStartOrStopBtn)(*i_paxStartOrStopBtn*),
		ADR(axNeedStop)(*i_paxNeedStop*),
		ADR(axAxisStarted)(*i_paxAxisStarted*),
		axCoolBlower_In	,
		axCoolBlower_Button_In	,
		ADR(axLamp_CoolBlower_Out),
		ADR(axRel_CoolBlower_Out),	
		ADR(axLamp_AllCoolBlower_Out),
		ADR(xLamp_AllCoolBlower_Out));
ELSE
	o_iErNo:= -1;
END_IF