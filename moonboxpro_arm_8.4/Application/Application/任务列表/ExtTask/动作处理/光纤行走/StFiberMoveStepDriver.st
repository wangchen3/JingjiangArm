(*@CES
Name=StFiberMoveStepDriver
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=5b3079b0-675f-4331-8b68-d66a1064d433
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StFiberMoveStepDriver :
STRUCT
	byFiberMoveMode:BYTE;(*光纤行走运行模式*)
	byFiberMoveDir:BYTE;(*光纤行走方向*)
	rFiberMoveVel:REAL;(*光纤行走运行速度 mm/s*)
	rFiberMoveDistanceIn:REAL;(*光纤行走行走距离输入*)
	rFiberMoveDistanceOut:REAL;(*光纤行走行走距离输出*)
	uiFiberMoveAlarm:UINT;(*光纤行走报警码*)
	iFiberMoveState:INT;(*光纤行走状态机*)
	xFiberMoveGoHome:BOOL;(*光纤行走回零状态*)
	rFiberMovePosCur:REAL;(*光纤行走当前位置*)
	rFiberMoveAdjust:REAL;(*光纤行走修正量*)
	rFiberMoveAdjust_ByOnline:REAL;(*光纤行走在线检测修正量*)
	rFiberMoveAdjust_Use:REAL;(*光纤行走修正量_使用值*)
	rFiberMoveAdjustByOnline_Use:REAL;(*光纤行走在线检测修正量_使用值*)
	rFiberMovePosStart:REAL;(*光纤行走起始位置*)
	rFiberMoveDistancePre:REAL;(*光纤行走上一次所有色同步运动的距离输入值*)
	xFiberMoveLeft:BOOL;(*光纤行走手动左移*)
	xFiberMoveRight:BOOL;(*光纤行走手动右移*)
	iFiberMoveCountGoHome:INT;(*光纤行走回零次数计数*)
	xFiberMoveLimit_Left:BOOL;(*光纤行走左限位*)
	xFiberMoveLimit_Right:BOOL;(*光纤行走右限位*)
	xFiberMoveRunning:BOOL;(*光纤行走运动中标志*)
	xFiberMoveDisRunStart:BOOL;(*光纤行走定长运动启动开关*)
	xFiberMoveMotorRunning:BOOL;(*光纤行走电机运动中标志*)
	xFiberMoveBasePosDone:BOOL;(*光纤行走基准位置确认*)
	xFiberMoveSyncDone:BOOL;(*光纤行走基准位置同步完成*)
	xFiberMoveIsSyncing:BOOL;(*光纤行走基准位置同步中*)
	xFiberMoveIsHoming:BOOL;(*光纤行走回零中*)
	xFiberMove_LimitPos:bool;(*光纤行走到限位了*)
	xFiberMove_GoHomeDoneByDebug:BOOL;(*已经被调试模式触发过回零*)
	iFiberMove_StsSlave:INT;(*从站运动状态机*)
	xFiberMove_RunHomeStart:BOOL;(*启动本色回零*)
	iFiberMove_OutTimeCount:INT;(*超时计数*)
	
	uiFiberMovePulsePerCycle:UINT;(*光纤行走每圈的脉冲数*)
	rFiberMoveDistancePerCycle: REAL;(*光纤行走每圈的距离*)
	lrFiberMovePosPPulse:LREAL;(*光纤行走每个脉冲对应的位置值，单位mm*)(*通过测量得到，或者通过计算得到*)
	
	
	xBasePosDoneByOnline:BOOL;(*在线检测基准位置确认*)
	rFiberMove_BasePos:REAL;(*基准位置-带修正量*)
	rFiberMoveBasePosFromSlave:real;(*基准位置-从站发来的*)
	
	tFiberMove_StateTime:TIME;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
