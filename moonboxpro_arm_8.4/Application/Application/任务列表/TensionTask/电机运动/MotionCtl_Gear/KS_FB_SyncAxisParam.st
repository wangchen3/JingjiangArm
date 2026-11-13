(*@CES
Name=KS_FB_SyncAxisParam
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=077804ff-0a67-4efe-85c5-857f707c9b28
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SyncAxisParam(*同步运动参数-速度等*)
VAR_INPUT
	i_xEn: BOOL;
	i_iGrpId: INT;
	i_iGrpUnitNum_Pu : INT;
	i_aiGrpUnitList: ARRAY [1..MAX_UNIT_NUM] OF INT;
	i_iGrpGearMotion_Num: INT;
	i_aiGrpGearMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	
	i_pstStSysParam: POINTER TO StSysParam;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
	i_rVel_VirtualMotion: REAL;
	i_pastStMotorParam_Vel: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
END_VAR
VAR_OUTPUT
//	o_iAxisId_Master: INT;
//	o_astStTStGearParam: ARRAY [1..MAX_STATION_NUM] OF TStGearParam;
END_VAR
VAR
	iN: INT;
	iUnitId: INT;
	iTypeId: INT;
	iCoreId: INT;
	xEnTemp: BOOL;
	iAxisId: INT;
	rTemp_Vel: REAL;
	lrTemp:LREAL;
	diModify_Delta: dint;(*离合区计算*)
	astStTStGearParam: ARRAY [1..MAX_STATION_NUM] OF TStGearParam;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam<>0 AND i_pastStAxisIdListInf<>0 THEN
		Action_Sync_Gear();
	ELSE;
	END_IF
ELSE
	;
END_IF