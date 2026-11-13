(*@CES
Name=Action_Msg_Alarm
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=697c4881-dae9-4441-8c81-2bb652cd5955
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*先处理一些工艺相关报警-主要通过IO反馈的信号*)
FOR iN:=1 TO i_byGrpUnitNum BY 1 DO
	iUnitId:= i_abyAxisList[iN];
	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
	pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);
	IF pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_PowerAdj OR(*功率调整器*)
		pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_HeatClose OR(*加热电源脱开*)
		pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_HeatLimit OR(*加热超温*)
		pstStUnitParam_UnSave^.wSTS_UnitTemCtl.9 THEN(*温控表故障*)
		IF pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_PowerAdj THEN
			iMsgId:= 1527;
			iAlarm_UnitId := iUnitId;
		ELSIF pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_HeatClose THEN
			iMsgId:= 1528;
			iAlarm_UnitId := iUnitId;
		ELSE
			iMsgId:= 1530;
			iAlarm_UnitId := iUnitId;
		END_IF
	END_IF
	o_xAlarmStillOnline:= o_xAlarmStillOnline OR
		pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_PowerAdj OR(*功率调整器*)
		pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_HeatClose OR(*加热电源脱开*)
		pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_HeatLimit OR(*加热超温*)
		pstStUnitParam_UnSave^.wSTS_UnitTemCtl.9;
	
	IF i_pastStIOMap_AxisExtra^[iUnitId].i_xHotBlower OR 
		i_pastStIOMap_AxisExtra^[iUnitId].o_xLamp_HotBlower THEN(*热风处于打开状态*)
		IF pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_HotBlower OR(*风机过载*)
			i_pastStIOMap_AxisExtra^[iUnitId].i_xHotBlower_Err THEN(*风机故障*)
			iMsgId:= 1529;
			iAlarm_UnitId := iUnitId;
		END_IF
	END_IF		
	(*递墨变频故障提示*)
	IF i_pastStIOMap_AxisExtra^[iUnitId].o_xInkRollerOn OR
		i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRoller_CW OR 
		i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRoller_CCW THEN
		IF pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_InkRoller OR(*递墨故障*)
			i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRollerInveterError THEN
			iMsgId:= 1531;
			iAlarm_UnitId := iUnitId;
			iAlarm_TypeId := MECHANICALPART_INK_ROLLER;
		END_IF
	END_IF
	(*刮刀变频故障提示*)
	IF (i_pastStIOMap_AxisExtra^[iUnitId].o_xScraperOn OR
		i_pastStIOMap_AxisExtra^[iUnitId].i_xScraperOn) AND
		pstStUnitParam_Save^.xLinkage THEN
		IF pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_Scraper OR(*刮刀故障*)
			i_pastStIOMap_AxisExtra^[iUnitId].i_xScraperInveterError THEN
			iMsgId:= 1532;
			iAlarm_UnitId := iUnitId;
			iAlarm_TypeId := MECHANICALPART_SCRAPER;
		END_IF
	END_IF
	o_xAlarmStillOnline:= o_xAlarmStillOnline OR
							pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_HotBlower OR
							i_pastStIOMap_AxisExtra^[iUnitId].i_xHotBlower_Err OR
							pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_InkRoller OR
							i_pastStIOMap_AxisExtra^[iUnitId].i_xInkRollerInveterError OR
							pstStUnitParam_UnSave^.xAxisInf_IO_Alarm_Scraper OR
							i_pastStIOMap_AxisExtra^[iUnitId].i_xScraperInveterError;			
END_FOR

(*下面还是一些整机工艺报警提示处理*)		
IF i_xLostPressure THEN(*气压低报警*)
	iMsgId:= 1059;(*2022.4.3.171108| *)
END_IF

IF i_xPrnRollerLoose_AtLeast1 THEN(*至少一色夹板松报警*)
	iMsgId:= 1060;(*2022.4.3.171108| *)
END_IF

IF i_xbrakeResistanceTempHigh_AtLeast1 THEN(*至少一色制动电阻温度高*)
	iMsgId:= 1061;(*2022.4.3.171108| *)
END_IF
IF i_xHorzMotorAlarmAtLeastOne THEN
	iMsgId:= 1063;(*2022.6.28.000726| *)
END_IF
o_xAlarmStillOnline:= o_xAlarmStillOnline OR
	i_xLostPressure OR
	i_xPrnRollerLoose_AtLeast1 OR
	i_xbrakeResistanceTempHigh_AtLeast1 OR
	i_xHorzMotorAlarmAtLeastOne;		
(*下面是一些系统变频报警2025.9.24.182421*)
IF i_xTowerInvAlarm_Uw THEN(*翻转架变频器报警-放料*)
	iMsgId:= 1065;(*2022.6.28.150119| *)
END_IF
IF i_xTowerInvAlarm_Rw THEN(*翻转架变频器报警-收料*)
	iMsgId:= 1066;(*2022.6.28.150119| *)
END_IF
IF i_xInverterAlarmCurAxis_Uw THEN(*收放料当前轴变频器报警*)
	iMsgId:= 1002;(* 2021.9.22.114312/+注释/放料当前轴报警 *)
ELSIF i_xInverterAlarmCurAxis_Rw THEN
	iMsgId:= 1003;(* 2021.9.22.114259/+注释/收料当前轴报警 *)
END_IF
IF i_xInverterAlarmPreAxis_Uw THEN(*收放料预驱轴报警*)
	iMsgId:= 1054;(* 2021.9.22.114203/+注释/放料预驱轴报警 *)
ELSIF i_xInverterAlarmPreAxis_Rw THEN
	iMsgId:= 1055;(* 2021.9.22.114233/+注释/收料预驱轴报警 *)
END_IF
IF i_xInverterAlarm_If THEN(* 放牵变频器报警 *)
	iMsgId:= 1070;
END_IF
IF i_xInverterAlarm_Of THEN(* 收牵变频器报警 *)
	iMsgId:= 1071;
END_IF
(*急停提示*)
IF i_xEstopBtnDne THEN
	iMsgId:= 1064;(*2022.6.28.150119| *)
END_IF		
o_xAlarmStillOnline:= o_xAlarmStillOnline OR
	i_xInverterAlarmCurAxis_Uw OR
	i_xInverterAlarmCurAxis_Rw OR
	i_xInverterAlarmPreAxis_Uw OR
	i_xInverterAlarmPreAxis_Rw OR
	i_xInverterAlarm_If OR(*2023.5.16.121615*)
	i_xInverterAlarm_of OR
	i_xEstopBtnDne;
	
IF i_iMoveErrCode<>0 THEN
	iMsgId:= 1073+i_iMoveErrCode;
	iTemp:= i_iMoveErrCode;
ELSE
	IF iTemp<>0 THEN
		IF iMsgId = 1073+iTemp THEN
			iTemp:= 0;
			iMsgId:= 0;
		END_IF
	END_IF
END_IF
(*关于PT规划异常报错先不要了，后面没这个报警了*)
(*母线电压是否能拿到还未知，暂时母线电压检测报警先不加*)

(*接下来处理详细报警信息显示2025.9.24.184026*)
FOR iN:=1 TO i_byGrpUnitNum BY 1 DO
	iUnitId:= i_abyAxisList[iN];
	pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iUnitId]);
	pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId]);

	IF pstStUnitParam_UnSave^.xAxisAlarm_PrnRoller THEN//版辊报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警		
		iAlarm_UnitId := iUnitId;		
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Prn AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_PRNROLLER;
				EXIT;						
			END_IF
		END_FOR
	END_IF
	IF pstStUnitParam_UnSave^.xAxisAlarm_NetRoller THEN//网辊报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警	
		iAlarm_UnitId := iUnitId;			
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Net AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_NETROLLER;
				EXIT;						
			END_IF
		END_FOR
	END_IF				
	IF pstStUnitParam_UnSave^.xAxisAlarm_BottomRoller THEN//底辊报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Bottom AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_BOTTOMROLLER;
				EXIT;						
			END_IF
		END_FOR
	END_IF			
	IF pstStUnitParam_UnSave^.xAxisAlarm_Horz THEN//横向报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Horz AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_HORZ;
				EXIT;						
			END_IF
		END_FOR
	END_IF			
	IF pstStUnitParam_UnSave^.xAxisAlarm_Prn_Pressure_M THEN//版辊M报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;			
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Prn_M AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_PRN_PRESS_M;
				EXIT;						
			END_IF
		END_FOR
	END_IF			
	IF pstStUnitParam_UnSave^.xAxisAlarm_Prn_Pressure_G THEN//版辊G报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Prn_G AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_PRN_PRESS_G;
				EXIT;						
			END_IF
		END_FOR
	END_IF	
	IF pstStUnitParam_UnSave^.xAxisAlarm_Net_Pressure_M THEN//网辊M报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Net_M AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_NET_PRESS_M;
				EXIT;						
			END_IF
		END_FOR
	END_IF			
	IF pstStUnitParam_UnSave^.xAxisAlarm_Net_Pressure_G THEN//网辊G报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Net_G AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_NET_PRESS_G;
				EXIT;						
			END_IF
		END_FOR
	END_IF	
	IF pstStUnitParam_UnSave^.xAxisAlarm_PHOTOCELL THEN//中心辊位置偏差报警		
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_PHOTOCELL AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_PHOTOCELL;
				EXIT;						
			END_IF
		END_FOR		
	END_IF
	IF pstStUnitParam_UnSave^.xAxisAlarm_Str_Pressure_M THEN//网辊M报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Str_M AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_STR_PRESS_M;
				EXIT;						
			END_IF
		END_FOR
	END_IF			
	IF pstStUnitParam_UnSave^.xAxisAlarm_Str_Pressure_G THEN//网辊G报警
		iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
		iAlarm_UnitId := iUnitId;
		FOR iBit:=0 TO 31 BY 1 DO
			IF (pstStUnitParam_UnSave^.dwAlarmDetail_Str_G AND SHL(DWORD#1,iBit))<>0 THEN
				iMsgId:= 1004+iBit;
				iAlarm_UnitId := iUnitId;
				iAlarm_TypeId := MECHANICALPART_STR_PRESS_G;
				EXIT;						
			END_IF
		END_FOR
	END_IF				

	IF g_axRemoteSetFailed[iUnitId] THEN
		iMsgId := 1301;
		iAlarm_UnitId := iUnitId;
	END_IF
	
END_FOR

//牵引收放料等报警详细		
IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_IF THEN//放牵位置偏差报警			
	iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警	
	iAlarm_TypeId := MECHANICALPART_IF;
	FOR iBit:=0 TO 31 BY 1 DO
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_IF AND SHL(DWORD#1,iBit))<>0 THEN
			iMsgId:= 1004+iBit;
			iAlarm_TypeId := MECHANICALPART_IF;
			EXIT;						
		END_IF
	END_FOR		
END_IF
IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_OF THEN//收牵位置偏差报警			
	iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
	iAlarm_TypeId := MECHANICALPART_OF;
	FOR iBit:=0 TO 31 BY 1 DO
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_OF AND SHL(DWORD#1,iBit))<>0 THEN
			iMsgId:= 1004+iBit;
			iAlarm_TypeId := MECHANICALPART_OF;
			EXIT;						
		END_IF
	END_FOR			
END_IF
IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_CENTRAL THEN//中心辊位置偏差报警		
	iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
	FOR iBit:=0 TO 31 BY 1 DO
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_CENTRAL AND SHL(DWORD#1,iBit))<>0 THEN
			iMsgId:= 1004+iBit;
			iAlarm_TypeId := MECHANICALPART_CENTERROLLER;
			EXIT;						
		END_IF
	END_FOR		
END_IF

IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_UW_A THEN//放料A位置偏差报警		
	iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
	FOR iBit:=0 TO 31 BY 1 DO
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_UW_A AND SHL(DWORD#1,iBit))<>0 THEN
			iMsgId:= 1004+iBit;
			iAlarm_TypeId := MECHANICALPART_UW_A;
			EXIT;						
		END_IF
	END_FOR				
END_IF	
IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_UW_B THEN//放料B位置偏差报警		
	iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
	iAlarm_UnitId := iUnitId;
	FOR iBit:=0 TO 31 BY 1 DO
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_UW_B AND SHL(DWORD#1,iBit))<>0 THEN
			iMsgId:= 1004+iBit;
			iAlarm_TypeId := MECHANICALPART_UW_B;
			EXIT;						
		END_IF
	END_FOR			
END_IF
IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_RW_A  THEN//收料A位置偏差报警		
	iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
	FOR iBit:=0 TO 31 BY 1 DO
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_RW_A AND SHL(DWORD#1,iBit))<>0 THEN
			iMsgId:= 1004+iBit;
			iAlarm_TypeId := MECHANICALPART_RW_A;
			EXIT;						
		END_IF
	END_FOR		
END_IF	
IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAlarm_RW_B  THEN//收料A位置偏差报警		
	iMsgId:= 1051;//如果是有报警细节，则被下面赋值刷新，如果没有，就只提示网络驱动器报警
	FOR iBit:=0 TO 31 BY 1 DO
		IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAlarmDetail_RW_B AND SHL(DWORD#1,iBit))<>0 THEN
			iMsgId:= 1004+iBit;
			iAlarm_TypeId := MECHANICALPART_RW_B;
			EXIT;						
		END_IF
	END_FOR		
END_IF			
//2026.01.12.201114 | + | 伺服报警
IF g_stStSysParam.astStGrpParam_Save[i_iGrpId].iMotionCtlErrCode<>0 THEN
	IF g_stStSysParam.astStGrpParam_Save[i_iGrpId].iMotionCtlErrCode = 6 THEN
		iMsgId := 1079;
		iAlarm_UnitId := g_iErrUnitId;
	END_IF
END_IF

(*制动电阻提示先不处理
	IF pstStAxisParam^.byBrakeResistanceAlarm.4 THEN(*制动电阻访问超限提示*)
		iMsgId:= 1053;
	END_IF
	IF pstStAxisParam^.byBrakeResistanceAlarm.5 THEN(*制动电阻报警急停提示*)
		iMsgId:= 1062;
	END_IF*)
(*加热异常报警2022.7.9.004540-指的是加热未输出但是接触器吸合-界面提示加报警3s-暂时用于汇通-可能其他家会有需求*)
IF i_xAlarmHeating THEN
	iMsgId:= 1081;
END_IF


IF i_pxFlag_Alarm_Rev_ErrorEnc<>0 THEN
	IF i_pxFlag_Alarm_Rev_ErrorEnc^ THEN(*编码器反转保护提示s2022.9.16.135203*)
		IF i_iAxisId_Alarm_Rev=29 THEN
			iMsgId:= 1081+17;
		ELSIF i_iAxisId_Alarm_Rev=30 THEN
			iMsgId:= 1081+18;
		ELSIF i_iAxisId_Alarm_Rev=31 THEN
			iMsgId:= 1081+19;
		ELSIF i_iAxisId_Alarm_Rev=32 THEN
			iMsgId:= 1081+20;
		ELSE
			iMsgId:= 1081+i_iAxisId_Alarm_Rev;
		END_IF
	ELSE
		IF iMsgId>1081 AND iMsgId<1081+20 THEN
			iMsgId:= 0;
		END_IF
	END_IF
END_IF	
(*2025.5.27.230308+*)
IF i_xNeedRestartPlc THEN
	iMsgId:=1200;
END_IF


IF g_xUnLine_SysStation THEN
	iMsgId:= 1050;
END_IF


