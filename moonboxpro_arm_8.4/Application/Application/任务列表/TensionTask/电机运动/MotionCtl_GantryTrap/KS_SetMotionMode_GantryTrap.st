(*@CES
Name=KS_SetMotionMode_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7ab09aac-15c9-441c-8ca2-dc927ffdf88d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionMode_GantryTrap : INT(*0:无错误| >0:失败的指令数量; |-1:参数错误;*)
VAR_INPUT
	i_iAxisId: INT;
	i_iCoreId: INT;
	i_iGroupId : INT;
	i_iStationId: INT;
	i_iAxisSlaver : INT;
	i_iAxisMasterVirtual : INT;
	i_diSyncErrorLimit : DINT;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
END_VAR
VAR
	iN : INT;
	iResult: INT;
	//iRtn: INT;
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
(*2026.02.03.100113 CX*)
	aiRtn[1] := SetPrfGantryTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iGroupId:= i_iGroupId, 
				i_iAxisMaster:= i_iAxisId, 
				i_iAxisSlaver:= i_iAxisSlaver, 
				i_iAxisMasterVirtual:= i_iAxisMasterVirtual, 
				i_diSyncErrorLimit:=UDINT_TO_DINT(20971520));//i_diSyncErrorLimit);//UDINT_TO_DINT(2147483648));//i_diSyncErrorLimit);//UDINT_TO_DINT(2147483648));//

	aiRtn[2] := SetPrfTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iAxisId:= i_iAxisId, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 20.0,//i_pastTStTrapParmUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0);//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime);

	aiRtn[3] := SetPrfTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iAxisId:= i_iAxisSlaver, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0);//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime);
				
	aiRtn[4]:= GTN_LmtsOffEx(1,i_iAxisMasterVirtual,-1,-1);	
	aiRtn[5]:= GTN_AlarmOff(1,i_iAxisMasterVirtual);
	aiRtn[6]:= GTN_ClrSts(1,i_iAxisMasterVirtual,1);	
	aiRtn[7] := SetPrfTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iAxisId:= i_iAxisMasterVirtual, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 20.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0);//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime);
	
	FOR iN := 1 TO 10 BY 1 DO
		IF aiRtn[iN]<>0 THEN
			iResult:= iResult + 1;
			(* 2021.2.26.172210/归属于普通报警 *)
			wLogLevel:= LOG_LEVEL_ALARM;
	(*2022.6.4.093146|精简打印信息！*)
	(*		sMsg_major:= CONCAT('ALARM_NORMAL: KS_SetGrpAxisClrSts_PshLog|Aid:', INT_TO_STRING(iAxisId));*)
			sMsg_major:= CONCAT('KS_SetMotionMode_GantryTrap|Gid:', INT_TO_STRING(i_iGroupId));
			sMsg_major:= CONCAT(sMsg_major, '|Sid:');
			sMsg_major:= CONCAT(sMsg_major, INT_TO_STRING(i_iStationId));
			//sMsg_minor:= CONCAT('GTN_ClrSts: ', INT_TO_STRING(iRtn));
		END_IF
	END_FOR
ELSE
	iResult := -1;
END_IF

IF sMsg_major<>'' THEN (* 2021.2.26.172055/有内容代表要写日志的 *)
	KS_HY_AddMsgToLog(i_pstStHYLogFifo, wLogLevel, sMsg_major, sMsg_minor);				
END_IF

KS_SetMotionMode_GantryTrap:= iResult;