(*@CES
Name=StMotorParam_GantryTrap
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=00c231ec-a232-4c57-93bf-824e3e8747db
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StMotorParam_GantryTrap :
STRUCT
	iAxisId: INT;
	iCoreId: INT;
	iStationId: INT;
	iUnitId : INT;
	iGroupId : INT;
	iTypeId : INT;
	iAxisSlaver : INT;
	iAxisMasterVirtual : INT;
	uiAxisNum: UINT;(*减速比分子*)
	uiAxisDen: UINT;(*减速比分母*)
	rScrewPitch_: REAL;(*螺距*)
	diSyncErrorLimit : DINT;//龙门误差
	
	iMoveStep: INT;
//	iMotionMode: INT;(*运动模式-=0：点位=1：龙门+点位=2：龙门的点位*)
//	iAxis_Ctrl : INT;
	xMoveRev_M: BOOL;
	xMoveRev_G: BOOL;
	xMoveEn: BOOL;

	liTarget_Pos_All : LINT;//龙门目标位置
	diMain_Axis_Shift : DINT;//主轴单动位置
	diSecond_Axis_Shift : DINT;//从轴单动位置
	diMax_Vel : DINT;//最大速度
	
//计算位置相关内容	
	lrPos_ZeroPos_Enc_M: LREAL;//原点位置
	lrPos_CurPos_Enc_M: LREAL;//当前编码器位置
	lrPos_CurPos_Prf_M: LREAL;//当前规划位置
	lrPos_CurPos_Prf: LREAL;//龙门轴规划期
	lrCurPos_mm_M: LREAL;//当前位置距离远点的物理距离
	lrPos_Limit_For_mm_M: LREAL;//辊子前表面位置（与底辊/版辊的切点的位置）
	lrPos_Limit_Rev_mm_M: LREAL;//辊子前表面位置（与网辊的切点的位置/网辊距离换版位的位置）
	lrPos_ZeroPos_Enc_G: LREAL;//原点位置
	lrPos_CurPos_Enc_G: LREAL;//当前编码器位置
	lrPos_CurPos_Prf_G: LREAL;//当前规划位置
	lrPos_CurPos_Enc: LREAL;//龙门轴编码器位置
	lrCurPos_mm_G: LREAL;//当前位置距离远点的物理距离
	lrPos_Limit_For_mm_G: LREAL;//辊子前表面位置（与底辊/版辊的切点的位置）
	lrPos_Limit_Rev_mm_G: LREAL;//辊子前表面位置（与网辊的切点的位置/网辊距离换版位的位置）
	
	
	xAxisPrfStop_M:BOOL;//规划器停止
	xAxisPrfStop_G:BOOL;//规划器停止
	
	//增加站号
	iStationId_M : INT;
	iStationId_G : INT;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
