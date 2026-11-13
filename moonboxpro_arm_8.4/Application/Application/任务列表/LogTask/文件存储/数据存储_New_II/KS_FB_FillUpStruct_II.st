(*@CES
Name=KS_FB_FillUpStruct_II
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=76ca8318-99ef-4640-8be8-d9c1267bca61
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_FillUpStruct_II
VAR_INPUT
	i_xEn 								: BOOL;
	i_iGrpId 							: INT;(*系ID*)
	i_pstStSysParam 					: POINTER TO StSysParam;
	i_pastStGetMotionSts				: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;
	i_pastStSetPrm_Gear					: POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pastStSetPrm_GantryTrap			: POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pastStSetPrm_Trap					: POINTER TO ARRAY [1..MAX_STATION_NUM] OF TSetMultiMcFunctionPrm;
	i_pastStMotorParam_Vel				: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Vel;
	i_pastStMotorParam_GantryTrap		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_GantryTrap;
	i_pastStMotorParam_Trap				: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StMotorParam_Trap;
	i_pstStSysStationInf				: POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf 			: POINTER TO StSysGantryAxisInf;
	i_iGrpGearMotion_Num				: INT;
	i_aiGrpGearMotion_StdList			: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_iGrpGantryTrapMotion_Num			: INT;
	i_aiGrpGantryTrapMotion_StdList		: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_iGrpTrapMotion_Num				: INT;
	i_aiGrpTrapMotion_StdList			: ARRAY [1..MAX_STATION_NUM] OF INT;

	i_pastStAxis_Sts_Display_Gear 		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Gear;
	i_pastStAxis_Sts_Save_Gear	 		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Gear;
	i_pastStAxis_Sts_Display_GantryTrap : POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_GantryTrap;
	i_pastStAxis_Sts_Save_GantryTrap	: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_GantryTrap;
	i_pastStAxis_Sts_Display_Trap 		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Trap;
	i_pastStAxis_Sts_Save_Trap	 		: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxis_Sts_Trap;
	i_pastStTrapAxisParam_Gantray 		: POINTER TO ARRAY [1..gc_iMax_PressureRoller_Unit,1..MAX_UNIT_NUM] OF StTrapAxisParam_Gantray;

END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN : INT;
	iAxisId: INT;
	iUnitId:INT;
	iTypeId: INT;
	iCoreId: INT;
	iGroupId : INT;
	iAdjAxisId : INT;
	
	iAxisId_Gantry: INT;
	iUnitId_Gantry:INT;
	iTypeId_Gantry: INT;
	iCoreId_Gantry: INT;
	iGroupId_Gantry : INT;
	iAdjAxisId_Gantry : INT;
	
	pstStGrpParam_Save : POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave : POINTER TO StGrpParam_UnSave;
	
	iAxisId_InAll : INT;
	
	iCountNum_Gear : INT;
	//iCountNum_GantryTrap : INT;
	iCountNum_Trap : INT;
	
	dwTemp : DWORD;
END_VAR


{IMPLEMENTATION}
IF i_xEn THEN
	IF i_pstStSysParam <> 0 THEN
		
		pstStGrpParam_Save := ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave := ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		
		ACT_Gear();
		ACT_GantryTrap();
		ACT_Trap();
	ELSE
		;
	END_IF
ELSE
	;
END_IF