(*@CES
Name=KS_SetMotionServoOff
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=af78d755-d488-4f6e-8233-0470695debbc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionServoOff : INT(*0:无错误| >0:失败的指令数量; |-1:参数错误;*)
VAR_INPUT
	i_iAxisId: INT;
	i_iCoreId: INT;
	i_iStationId: INT;
	i_xForceAxisOff:BOOL;(*强制下伺服标志|有效后直接调用AXISOFF指令|2021.5.8.161449*)	
	i_dwMotionSts: DWORD;
	i_dwDriverSts: DWORD;
	i_pxServoOn: POINTER TO BOOL;	
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
END_VAR
VAR
	iResult: INT;
	iRtn: INT;
	iFailedAxisCntNum: INT;
	wLogLevel: WORD;
	sMsg_major: STRING;
	sMsg_minor: STRING;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
sMsg_major:= ''; (* 2021.2.26.170203/ *)
sMsg_minor:= ''; (* 2021.2.26.170203/ *)
IF i_iStationId>=1 AND i_iStationId<=MAX_STATION_NUM AND
	i_iAxisId>=1 AND i_iAxisId<=MAX_STATION_NUM AND
	(i_iCoreId=1 OR i_iCoreId=2) THEN

	IF i_pxServoOn^ (*OR i_dwDriverSts.1*) THEN
		IF i_xForceAxisOff THEN
			iRtn:= GTN_AxisOff(i_iCoreId, i_iAxisId);
		ELSE
			IF i_dwMotionSts.9=1 THEN
				iRtn:= GTN_AxisOff(i_iCoreId, i_iAxisId);
			ELSE
				iRtn:= 0;
				iResult:= iResult+1;
			END_IF
		END_IF
		IF iRtn<>0 THEN
			iResult:= iResult+1;
			(* 2021.2.26.172210/归属于普通报警 *)
			wLogLevel:= LOG_LEVEL_ALARM;
	(*2022.6.4.093146|精简打印信息！*)
	(*		sMsg_major:= CONCAT('ALARM_NORMAL: KS_SetGrpAxisClrSts_PshLog|Aid:', INT_TO_STRING(iAxisId));*)
			sMsg_major:= CONCAT('KS_SetMotionServoOff|Aid:', INT_TO_STRING(i_iAxisId));
			sMsg_major:= CONCAT(sMsg_major, '|Sid:');
			sMsg_major:= CONCAT(sMsg_major, INT_TO_STRING(i_iStationId));
			sMsg_minor:= CONCAT('GTN_AxisOff: ', INT_TO_STRING(iRtn));
		END_IF
		i_pxServoOn^:= FALSE;
	END_IF	
END_IF

IF sMsg_major<>'' THEN (* 2021.2.26.172055/有内容代表要写日志的 *)
	KS_HY_AddMsgToLog(i_pstStHYLogFifo, wLogLevel, sMsg_major, sMsg_minor);				
END_IF

KS_SetMotionServoOff:= iResult;