(*@CES
Name=KS_FB_DIAMONDS_Input
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1e0a50ec-9206-4692-bb5f-e2a5b8087577
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_DIAMONDS_Input
VAR_INPUT
	i_xEn: BOOL;
	i_pstStSysParam: POINTER TO StSysParam;
	i_pstStParam_Diamonds_Wr: POINTER TO StParam_Diamonds_Wr;
	i_pstStParam_Diamonds_WrRd: POINTER TO StParam_Diamonds_WrRd;
	i_pstStWrRd_SysCfg: POINTER TO StWrRd_SysCfg;
	i_pstStSysCfgStruct: POINTER TO StSysCfgStruct;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;
	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
END_VAR
VAR
	pstStParam_Diamonds_Wr_SysSts : POINTER TO StParam_Diamonds_Wr_SysSts;
	pstStParam_Diamonds_Wr_RdSam : POINTER TO StParam_Diamonds_Wr_RdSam;
	pastStParam_Diamonds_Wr_Err : POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StParam_Diamonds_Wr_Err;
	pastStParam_Diamonds_Wr_RunSts : POINTER TO ARRAY [1..MAX_STATION_NUM] OF StParam_Diamonds_Wr_RunSts;
	iGrp: INT;
	iUnitId: INT;
	byCurSignal_RGB: BYTE;
	abySignalFlag: ARRAY [1..4] OF BYTE;
	iIndex:INT:= 1;
	iN: INT;
	iJ: INT;
	iK: INT;
	
	abyLastIndex: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	iAxisId_If: INT;
	iAxisId_Of: INT;
	iGrpId_Uw: INT;
	iGrpId_Rw: INT;
	fbKS_FB_DIAMONDS_SysCfg_WrRd: KS_FB_DIAMONDS_SysCfg_WrRd;
	iMachanicalTypeId: INT;
	
	astStParam_Diamonds_Wr_RunSts : ARRAY [1..MAX_STATION_NUM] OF StParam_Diamonds_Wr_RunSts;
	iNumIndex: INT:=0;
	iAxisId_T: INT;
	iTypeId_T: INT;
	iUnitId_T: INT;
	iCoreId_T: INT;
	iGroupId_T: INT;
	iAdjAxisId_T: INT;
	
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF i_pstStSysParam<>0 AND
		i_pstStParam_Diamonds_Wr<>0 AND
		i_pstStParam_Diamonds_WrRd<>0 THEN
		pstStParam_Diamonds_Wr_SysSts:= ADR(i_pstStParam_Diamonds_Wr^.stStParam_Diamonds_Wr_SysSts);
		pstStParam_Diamonds_Wr_RdSam:= ADR(i_pstStParam_Diamonds_Wr^.stStParam_Diamonds_Wr_RdSam);
		pastStParam_Diamonds_Wr_Err:= ADR(i_pstStParam_Diamonds_Wr^.astStParam_Diamonds_Wr_Err);
		pastStParam_Diamonds_Wr_RunSts:= ADR(i_pstStParam_Diamonds_Wr^.astStParam_Diamonds_Wr_RunSts);
	
		Action_Input_Wr();
(*2025.8.6.195943*)
//2026.5.29.145241		Action_Input_WrRd();

		o_iErNo:= 1;
	ELSE
		o_iErNo:= -2;
	END_IF
ELSE
	o_iErNo:= -1;
END_IF