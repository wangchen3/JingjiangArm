(*@CES
Name=StMotorParam_Trap
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=895de25e-1961-43a4-b404-7adc5138347b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StMotorParam_Trap ://点位轴和龙门轴的参数
STRUCT
	iAxisId: INT;
	iCoreId: INT;
	iStationId: INT;
	iUnitId : INT;
	iMoveStep: INT;
	xMoveRev: BOOL;
	xMoveEn: BOOL;
	uiAxisNum: UINT;(*减速比分子*)
	uiAxisDen: UINT;(*减速比分母*)
	liTargetPos: LINT;(*点位目标位置*)
	udiTargetVel: UDINT;
	rScrewPitch_: REAL;(*螺距*)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
