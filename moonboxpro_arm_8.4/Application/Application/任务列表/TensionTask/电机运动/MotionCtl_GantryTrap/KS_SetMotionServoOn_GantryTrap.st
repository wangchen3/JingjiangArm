(*@CES
Name=KS_SetMotionServoOn_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eed041ee-29dc-46a9-aea5-67e44b553fa0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionServoOn_GantryTrap : INT(*0:无错误| >0:失败的指令数量; |-1:参数错误;*)
VAR_INPUT
	i_iAxisId: INT;
	i_iCoreId: INT;
	i_iGroupId : INT;
	i_iStationId: INT;
	i_iAxisSlaver : INT;
	i_iAxisMasterVirtual : INT;
	i_pxMoveEn : POINTER TO BOOL;
	i_pxServoOn: POINTER TO BOOL;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
END_VAR
VAR
	iResult: INT;
	iRtn: INT;
	iN : INT;
	iFailedAxisCntNum: INT;
	wLogLevel: WORD;
	sMsg_major: STRING;
	sMsg_minor: STRING;
	aiRtn : ARRAY [1..10] OF INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
sMsg_major:= ''; (* 2021.2.26.170203/ *)
sMsg_minor:= ''; (* 2021.2.26.170203/ *)
FOR iN := 1 TO 10 BY 1 DO
	aiRtn[iN] := 0;
END_FOR
IF i_iStationId>=1 AND i_iStationId<=MAX_STATION_NUM AND
	i_iAxisId>=1 AND i_iAxisId<=MAX_STATION_NUM AND
	(i_iCoreId=1 OR i_iCoreId=2) THEN
	IF i_pxServoOn^ THEN(*如果之前伺服标志被置了,这里先让下伺服|*)
		i_pxServoOn^:= FALSE;
		iRtn := GTN_AxisOff(i_iCoreId, i_iAxisId);
		iRtn := GTN_AxisOff(i_iCoreId, i_iAxisSlaver);
		iRtn := GTN_AxisOff(i_iCoreId, i_iAxisMasterVirtual);
	END_IF
	
	//2025.10.27.150339 | bai.zy |
	IF i_pxMoveEn^ THEN
		aiRtn[1]:= GTN_AxisOn(i_iCoreId, i_iAxisId);(*上伺服|*)
		aiRtn[2]:= GTN_AxisOn(i_iCoreId, i_iAxisSlaver);(*上伺服|*)
		aiRtn[3]:= GTN_AxisOn(i_iCoreId, i_iAxisMasterVirtual);(*上伺服|*)
	END_IF
	
	FOR iN := 1 TO 10 BY 1 DO
		IF aiRtn[iN]<>0 THEN
			iResult:= iResult + 1;
			(* 2021.2.26.172210/归属于普通报警 *)
			wLogLevel:= LOG_LEVEL_ALARM;
	(*2022.6.4.093146|精简打印信息！*)
	(*		sMsg_major:= CONCAT('ALARM_NORMAL: KS_SetGrpAxisClrSts_PshLog|Aid:', INT_TO_STRING(iAxisId));*)
			sMsg_major:= CONCAT('KS_SetMotionServoOn|Aid:', INT_TO_STRING(i_iAxisId));
			sMsg_major:= CONCAT(sMsg_major, '|Sid:');
			sMsg_major:= CONCAT(sMsg_major, INT_TO_STRING(i_iStationId));
			sMsg_minor:= CONCAT('GTN_AxisOn: ', INT_TO_STRING(aiRtn[iN]));
		END_IF
		IF i_pxMoveEn^ AND iN=10 AND iResult=0 THEN
			i_pxServoOn^:= TRUE;
		END_IF
	END_FOR
ELSE
	iResult:= -1;
END_IF

IF sMsg_major<>'' THEN (* 2021.2.26.172055/有内容代表要写日志的 *)
	KS_HY_AddMsgToLog(i_pstStHYLogFifo, wLogLevel, sMsg_major, sMsg_minor);				
END_IF

KS_SetMotionServoOn_GantryTrap:= iResult;