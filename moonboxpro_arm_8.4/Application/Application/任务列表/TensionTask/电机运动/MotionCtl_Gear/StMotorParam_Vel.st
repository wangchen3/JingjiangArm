(*@CES
Name=StMotorParam_Vel
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=35fd48d6-a97b-4a50-89b7-bfdefdaf1e25
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StMotorParam_Vel :(*速度运动同步轴就是这些各参数了*)
STRUCT
	iAxisId: INT;
	iCoreId: INT;
	iStationId: INT;
	iMoveStep: INT;
	iMotionMode: INT;(*运动模式-=0：电子齿轮=1：JOG=2：点位*)
	xMoveRev: BOOL;
	xMoveEn: BOOL;
	rAxisGirth: REAL;(*同步版周*)
	xMoveVelMode: BOOL;(*=0:线速度=1转速*)
	rAxisVel: REAL;(*速度*)
	uiAxisNum: UINT;(*减速比分子*)
	uiAxisDen: UINT;(*减速比分母*)
	liTargetPos: LINT;(*点位目标位置*)
	udiTargetVel: UDINT;
	
	//2026.01.31.130843 | + | 增加停机维持伺服功能 秦华有停机维持伺服的功能，需要增加一个判断是否是使能状态的标志
	xAxisOn_ing : BOOL;//此标志表示该轴正处于使能中。。。
	
	//2026.05.09.085650 | + | 将大指令写入的值先放在这里，然后再穿进去
	modify_delta: DINT;
	/// 可以为正值
	ratio_a: DINT;
	/// 必须为正值
	ratio_b: DINT;
	
	
	//2026.05.12.201038 | + | 增加轴单运行中的标志
	xAxisInching : BOOL;	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
