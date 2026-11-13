(*@CES
Name=KS_SetMotionCheckServoOn
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=16f739cf-935e-4f65-a185-0fbe09498330
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionCheckServoOn : INT
VAR_INPUT
	i_iAxisId: INT;
	i_iCoreId: INT;
	i_iStationId: INT;
	i_pxMoveEn : POINTER TO BOOL;
	i_dwMotionSts: DWORD;
	i_dwDriverSts: DWORD;
	i_pxServoOn: POINTER TO BOOL;	
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)	
END_VAR
VAR
	iResult: INT;
	xRtn: BOOL;
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

	IF i_pxServoOn^ AND i_pxMoveEn^ THEN
		xRtn:= (*i_dwDriverSts.1 AND*) i_dwMotionSts.9;
		
		IF NOT xRtn THEN
			iResult:= iResult+1;
			(* 2021.2.26.172210/归属于普通报警 *)
			wLogLevel:= LOG_LEVEL_ALARM_NORMAL;
	(*2022.6.4.093146|精简打印信息！*)
	(*		sMsg_major:= CONCAT('ALARM_NORMAL: KS_SetGrpAxisClrSts_PshLog|Aid:', INT_TO_STRING(iAxisId));*)
			sMsg_major:= CONCAT('KS_SetMotionCheckServoOn|Aid:', INT_TO_STRING(i_iAxisId));
			sMsg_major:= CONCAT(sMsg_major, '|Sid:');
			sMsg_major:= CONCAT(sMsg_major, INT_TO_STRING(i_iStationId));
			sMsg_minor:= CONCAT('CheckServoOn|', BOOL_TO_STRING(xRtn));
			sMsg_minor:= CONCAT(sMsg_minor,'|MotionSts:');
			sMsg_minor:= CONCAT(sMsg_minor, DWORD_TO_STRING(i_dwMotionSts));
		END_IF
					
		//i_pxServoOn^:= FALSE;	
	END_IF	
END_IF

IF sMsg_major<>'' THEN (* 2021.2.26.172055/有内容代表要写日志的 *)
	KS_HY_AddMsgToLog(i_pstStHYLogFifo, wLogLevel, sMsg_major, sMsg_minor);				
END_IF

KS_SetMotionCheckServoOn:= iResult;