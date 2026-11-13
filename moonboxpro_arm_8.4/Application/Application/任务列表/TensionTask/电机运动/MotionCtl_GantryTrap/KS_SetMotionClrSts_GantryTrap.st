(*@CES
Name=KS_SetMotionClrSts_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a18b3a41-02c7-487f-b68c-7b38e9287e6e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionClrSts_GantryTrap : INT(*0:无错误| >0:失败的指令数量; |-1:参数错误;*)
VAR_INPUT
	i_iAxisId: INT;
	i_iCoreId: INT;
	i_iGroupId : INT;
	i_iStationId: INT;
	i_iAxisSlaver : INT;
	i_iAxisMasterVirtual : INT;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
END_VAR
VAR
	iResult: INT;
	iRtn: INT;
	iFailedAxisCntNum: INT;
	wLogLevel: WORD;
	sMsg_major: STRING;
	sMsg_minor: STRING;
	iN : INT;
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
	aiRtn[1]:= GTN_ClrSts(i_iCoreId, i_iAxisId, 1);(*清除错误|*)
	aiRtn[2]:= GTN_ClrSts(i_iCoreId, i_iAxisSlaver, 1);(*清除错误|*)
	aiRtn[3]:= GTN_ClrSts(i_iCoreId, i_iAxisMasterVirtual, 1);(*清除错误|*)
	
	FOR iN := 1 TO 10 BY 1 DO
		IF aiRtn[iN]<>0 THEN
			iResult:= iResult + 1;
	
			(* 2021.2.26.172210/归属于普通报警 *)
			wLogLevel:= LOG_LEVEL_ALARM;
	(*2022.6.4.093146|精简打印信息！*)
	(*		sMsg_major:= CONCAT('ALARM_NORMAL: KS_SetGrpAxisClrSts_PshLog|Aid:', INT_TO_STRING(iAxisId));*)
			sMsg_major:= CONCAT('KS_SetMotionClrSts|Aid:', INT_TO_STRING(i_iAxisId));
			sMsg_major:= CONCAT(sMsg_major, '|Sid:');
			sMsg_major:= CONCAT(sMsg_major, INT_TO_STRING(i_iStationId));
			sMsg_minor:= CONCAT('GTN_ClrSts: ', INT_TO_STRING(aiRtn[iN]));
		END_IF
	END_FOR
ELSE
	iResult := -1;
END_IF

IF sMsg_major<>'' THEN (* 2021.2.26.172055/有内容代表要写日志的 *)
	KS_HY_AddMsgToLog(i_pstStHYLogFifo, wLogLevel, sMsg_major, sMsg_minor);				
END_IF

KS_SetMotionClrSts_GantryTrap:= iResult;