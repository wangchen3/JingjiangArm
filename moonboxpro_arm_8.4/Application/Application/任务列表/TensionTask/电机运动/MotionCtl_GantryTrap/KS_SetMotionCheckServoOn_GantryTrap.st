(*@CES
Name=KS_SetMotionCheckServoOn_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ad48b66e-f167-4310-b3d8-83d13f11adce
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionCheckServoOn_GantryTrap : INT
VAR_INPUT
	i_iAxisId: INT;
	i_iCoreId: INT;
	i_iGroupId : INT;
	i_iStationId: INT;
	i_iAxisSlaver : INT;
	i_iAxisMasterVirtual : INT;
	i_pxMoveEn : POINTER TO BOOL;
	i_pxServoOn: POINTER TO BOOL;
	i_dwMotionSts: DWORD;
	i_dwDriverSts: DWORD;
	i_dwMotionSts_Slaver: DWORD;
	i_dwDriverSts_Slaver: DWORD;	
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)	
END_VAR
VAR
	iResult: INT;
	xRtn: BOOL;
	iN : INT;
	iFailedAxisCntNum: INT;
	wLogLevel: WORD;
	sMsg_major: STRING;
	sMsg_minor: STRING;	
	axRtn : ARRAY [1..2] OF BOOL;
	
	dwMotionSts: DWORD;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
sMsg_major:= ''; (* 2021.2.26.170203/ *)
sMsg_minor:= ''; (* 2021.2.26.170203/ *)
FOR iN := 1 TO 2 BY 1 DO
	axRtn[iN] := FALSE;
END_FOR
IF i_iStationId>=1 AND i_iStationId<=MAX_STATION_NUM AND
	i_iAxisId>=1 AND i_iAxisId<=MAX_STATION_NUM AND
	(i_iCoreId=1 OR i_iCoreId=2) THEN

	IF i_pxServoOn^ AND i_pxMoveEn^ THEN
		axRtn[1]:= (*i_dwDriverSts.1 AND*) i_dwMotionSts.9;
		axRtn[2]:= (*i_dwDriverSts_Slaver.1 AND*) i_dwMotionSts_Slaver.9;
		FOR iN := 1 TO 2 BY 1 DO
			IF NOT axRtn[iN] THEN
				iResult:= iResult+1;
				IF iN = 1 THEN
					dwMotionSts := i_dwMotionSts;
				ELSE
					dwMotionSts := i_dwMotionSts_Slaver;
				END_IF
				
				(* 2021.2.26.172210/归属于普通报警 *)
				wLogLevel:= LOG_LEVEL_ALARM;
		(*2022.6.4.093146|精简打印信息！*)
		(*		sMsg_major:= CONCAT('ALARM_NORMAL: KS_SetGrpAxisClrSts_PshLog|Aid:', INT_TO_STRING(iAxisId));*)
				sMsg_major:= CONCAT('KS_SetMotionCheckServoOn|Aid:', INT_TO_STRING(i_iAxisId));
				sMsg_major:= CONCAT(sMsg_major, '|Sid:');
				sMsg_major:= CONCAT(sMsg_major, INT_TO_STRING(i_iStationId));
				sMsg_minor:= CONCAT('CheckServoOn|', BOOL_TO_STRING(xRtn));
				sMsg_minor:= CONCAT(sMsg_minor,'|MotionSts:');
				sMsg_minor:= CONCAT(sMsg_minor, DWORD_TO_STRING(dwMotionSts));
			END_IF
		END_FOR
	END_IF	
END_IF

IF sMsg_major<>'' THEN (* 2021.2.26.172055/有内容代表要写日志的 *)
	KS_HY_AddMsgToLog(i_pstStHYLogFifo, wLogLevel, sMsg_major, sMsg_minor);				
END_IF

KS_SetMotionCheckServoOn_GantryTrap:= iResult;