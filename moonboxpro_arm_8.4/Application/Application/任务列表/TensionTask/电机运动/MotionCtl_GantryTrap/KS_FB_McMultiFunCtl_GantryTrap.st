(*@CES
Name=KS_FB_McMultiFunCtl_GantryTrap
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b1cd30ae-efbb-4f40-9386-b86c83b34233
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_McMultiFunCtl_GantryTrap(*大指令控制*)
(*
1.检查伺服状态
2.大指令写控制
*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpGantryTrapGroup_Num: INT;
	i_iGrpGantryTrapMotion_Num: INT;
	i_aiGrpGantryTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_pastStSetPrm					:POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pastStMotorParam_GantryTrap: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
	i_pstStHYLogFifo			: POINTER TO StHYLogFifo;(* 2025.8.23.170701/han.dp/增加的日志队列 *)
END_VAR
VAR_OUTPUT
END_VAR
VAR_IN_OUT
END_VAR
VAR
	iN : INT;
	iRtn: INT;
	alrVarValue : ARRAY [1..80] OF LREAL;	
	dwRtn : DWORD;
	astStSetPrm_Pre				: ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	
	fbKS_FB_CheckServeOnDone_GantryTrap : KS_FB_CheckServeOnDone_GantryTrap;
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	iRtn_McMulFun : INT ;
	iRtn_McMulFun_Pre : INT ;
	
	sTMultiMcFunctionReadPrm : TMultiMcFunctionReadPrm;
	
	(*2025-12-10 by sjw 非阻塞大指令*)
	FB_Set_StartMcMUltiFunction: GTMC_StartMcMultiFunction;
	bDoneSet: BOOL := TRUE;
	bBusySet: BOOL;
	bErrorSet: BOOL;
	iErrorIdSet: INT;
END_VAR


{IMPLEMENTATION}
(*1.伺服检查-确保所有需要转的轴都上伺服了才能进行下一步*)
pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);

fbKS_FB_CheckServeOnDone_GantryTrap(
	i_xEn:= ((pstStGrpParam_Save^.wCtl_Pressure_Up_Dn.5) AND (NOT fbKS_FB_CheckServeOnDone_GantryTrap.o_xDone)), 
	i_iGrpGantryTrapGroup_Num := i_iGrpGantryTrapGroup_Num,
	i_iGrpGantryTrapMotion_Num:= i_iGrpGantryTrapMotion_Num, 
	i_aiGrpGantryTrapMotion_StdList:= i_aiGrpGantryTrapMotion_StdList, 
	i_pstStSysParam:= i_pstStSysParam, 
	i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
	i_pastStGetMotionSts:= i_pastStGetMotionSts, 
	i_pastStMotorParam_GantryTrap:= i_pastStMotorParam_GantryTrap, 
	i_xFlag_StopOrEStop := pstStGrpParam_UnSave^.xFlag_Stop OR pstStGrpParam_UnSave^.xFlag_Estop,
	o_xEn=> , 
	o_xDone=> , 
	o_iErrNo=> , 
	o_iErrAxisId=> , 
	o_iErrTypeId=> , 
	o_iErrUnitId=> , 
	o_iErrCoreId=> );

	
(*2.大指令写*)
sTMultiMcFunctionReadPrm.readCommandVarTableIndex := 1;
sTMultiMcFunctionReadPrm.readCount := 0;
sTMultiMcFunctionReadPrm.pVarValue := ADR(alrVarValue);
dwRtn:= SysMemCmp(i_pastStSetPrm,ADR(astStSetPrm_Pre),SIZEOF(astStSetPrm_Pre));
IF dwRtn<>0 THEN
	//修改非阻塞方式 2025-12-10 by sjw
	iRtn_McMulFun:=GTN_StartMcMultiFunction(2,INT_TO_UINT(i_iGrpGantryTrapGroup_Num),1,i_pastStSetPrm,ADR(sTMultiMcFunctionReadPrm));
	IF iRtn_McMulFun <> 0 AND iRtn_McMulFun_Pre <> iRtn_McMulFun THEN
		KS_HY_AddMsgToLog(g_pstStHYLogFifo, LOG_LEVEL_ALARM, 'GTN_StartMcMultiFunction GantryTrap Err!', INT_TO_STRING(iRtn_McMulFun));
	END_IF
	iRtn_McMulFun_Pre := iRtn_McMulFun;
	(*
	IF bDoneSet  = TRUE AND bBusySet = FALSE THEN
		FB_Set_StartMcMUltiFunction(
		Execute:= TRUE, 
		Block:= TRUE, 
		core:= 2, 
		axisCount:= INT_TO_UINT(i_iGrpGantryTrapGroup_Num), 
		writeEnable:= 1, 
		pSetPrm:= i_pastStSetPrm, 
		pGetPrm:= ADR(sTMultiMcFunctionReadPrm), 
		Done=> bDoneSet, 
		Busy=> bBusySet, 	
		Error=> bErrorSet, 
		ErrorID=> iErrorIdSet);
	END_IF
	*)
END_IF
SysMemCpy(ADR(astStSetPrm_Pre),i_pastStSetPrm,SIZEOF(i_pastStSetPrm^));

