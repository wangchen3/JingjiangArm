(*@CES
Name=KS_SetMotionMode
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eb1bfde3-c781-4a8b-bb4b-64a6f57a70ed
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_SetMotionMode : INT(*0:无错误| >0:失败的指令数量; |-1:参数错误;*)
VAR_INPUT
	i_iAxisId: INT;
	i_iCoreId: INT;
	i_iStationId: INT;
	i_iMoveMode: INT;
	i_iAxisId_Master: INT;
	i_xMasterType : BOOL;
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
	IF i_iMoveMode=0 THEN
		iRtn := SetPrfGearModePrm(
				i_iCore:= i_iCoreId, 
				i_iAxisId:= i_iAxisId, 
				i_iMasterIndex:= i_iAxisId_Master,//i_pastTStGearParamUser^[iCnt_GearAxis].iMasterIndex, 
				i_diMasterEven:= 1,//i_pastTStGearParamUser^[iCnt_GearAxis].diMasterEven, 
				i_diSlaveEven:= 1,//i_pastTStGearParamUser^[iCnt_GearAxis].diSlaveEven, 
				i_diMasterSlope:= 100000,
				i_xMasterType := i_xMasterType);//i_pastTStGearParamUser^[iCnt_GearAxis].diMasterSlope);

	ELSIF i_iMoveMode=1 THEN
		//2025.10.28.105106 | bai.zy  | 单运行仍然使用电子齿轮
		iRtn := SetPrfGearModePrm(
				i_iCore:= i_iCoreId, 
				i_iAxisId:= i_iAxisId, 
				i_iMasterIndex:= i_iAxisId_Master,//i_pastTStGearParamUser^[iCnt_GearAxis].iMasterIndex, 
				i_diMasterEven:= 1,//i_pastTStGearParamUser^[iCnt_GearAxis].diMasterEven, 
				i_diSlaveEven:= 1,//i_pastTStGearParamUser^[iCnt_GearAxis].diSlaveEven, 
				i_diMasterSlope:= 100000,
				i_xMasterType := i_xMasterType);//i_pastTStGearParamUser^[iCnt_GearAxis].diMasterSlope);
		
// 		iRtn := SetPrfJogModePrm(
// 				i_iCore:= i_iCoreId, 
// 				i_iAxisId:= i_iAxisId, 
// 				i_lrAcc:= 1, 
// 				i_lrDec:= 1, 
// 				i_rSmooth:= 0.8);

	ELSIF i_iMoveMode=2 THEN
		iRtn := SetPrfTrapModePrm(
				i_iCoreId:= i_iCoreId, 
				i_iAxisId:= i_iAxisId, 
				i_lrVel:= 100,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrVel, 
				i_lrAcc:= 2.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrAcc, 
				i_lrDec:= 2.0,//i_pastTStTrapParamUser^[iCnt_TrapAxis].lrDec, 
				i_iSmoothTime:= 0);//i_pastTStTrapParamUser^[iCnt_TrapAxis].iSmoothTime);				
	ELSIF i_iMoveMode=3 THEN//增加一种运动模式2026.4.27.215724|收放料速度模式
		iRtn := SetPrfJogModePrm(
				i_iCore:= i_iCoreId, 
				i_iAxisId:= i_iAxisId, 
				i_lrAcc:= 1, 
				i_lrDec:= 1, 
				i_rSmooth:= 0.8);
		
	ELSE;
		iRtn := SetPrfGearModePrm(
				i_iCore:= i_iCoreId, 
				i_iAxisId:= i_iAxisId, 
				i_iMasterIndex:= i_iAxisId_Master,//i_pastTStGearParamUser^[iCnt_GearAxis].iMasterIndex, 
				i_diMasterEven:= 1,//i_pastTStGearParamUser^[iCnt_GearAxis].diMasterEven, 
				i_diSlaveEven:= 1,//i_pastTStGearParamUser^[iCnt_GearAxis].diSlaveEven, 
				i_diMasterSlope:= 100000,
				i_xMasterType := i_xMasterType);//i_pastTStGearParamUser^[iCnt_GearAxis].diMasterSlope);		
	END_IF
	
	IF iRtn<>0 THEN
		iResult:= iRtn;
		(* 2021.2.26.172210/归属于普通报警 *)
		wLogLevel:= LOG_LEVEL_ALARM;
(*2022.6.4.093146|精简打印信息！*)
(*		sMsg_major:= CONCAT('ALARM_NORMAL: KS_SetGrpAxisClrSts_PshLog|Aid:', INT_TO_STRING(iAxisId));*)
		sMsg_major:= CONCAT('KS_SetMotionMode|Aid:', INT_TO_STRING(i_iAxisId));
		sMsg_major:= CONCAT(sMsg_major, '|Sid:');
		sMsg_major:= CONCAT(sMsg_major, INT_TO_STRING(i_iStationId));
		//sMsg_minor:= CONCAT('GTN_ClrSts: ', INT_TO_STRING(iRtn));
	END_IF
END_IF

IF sMsg_major<>'' THEN (* 2021.2.26.172055/有内容代表要写日志的 *)
	KS_HY_AddMsgToLog(i_pstStHYLogFifo, wLogLevel, sMsg_major, sMsg_minor);				
END_IF

KS_SetMotionMode:= iResult;