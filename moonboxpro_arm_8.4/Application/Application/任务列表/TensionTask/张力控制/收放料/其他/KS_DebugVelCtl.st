(*@CES
Name=KS_DebugVelCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=5bddb8b6-d642-4e27-baef-5c1f07abfbd7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_DebugVelCtl : BOOL(*调试的速度控制|包含使能标志*)
(*2024.04.12.181136 增加了计算最大加速度的速度输入*)
VAR_INPUT
	i_xDebugEn:BOOL;(*调试使能*)
	i_xRun:BOOL;(*运行标志*)
	i_xStopFast:BOOL;(*快停标志|类似急停时候使能*)
	i_xStopByDec:BOOL;(*减速停止|-TRUE 减速停止|FALSE 直接取消使能停止*)
	i_xManuAcc:BOOL;(*手动加速*)
	i_xManuDec:BOOL;(*手动减速*)
	i_xAutuoAccDec:BOOL;(*自动加减速*)
	i_iVel_Max_mpm:INT;(*最大速度*)
	i_rAxisGirth:REAL;(*轴周长mm*)
	i_rVel_Tar_mpm:REAL;(*目标线速度|m/min*)
	i_pxRunning:POINTER TO BOOL;(*运行中|用来控制使能信号*)
	i_prVel_Cur_mpm:POINTER TO REAL;(*当前线速度|M/MIN*)
	i_prVel_Cur_rpm:POINTER TO REAL;(*当前转速|r/min*)
	i_uiMaxVel_UseCalcAcc:UINT;(*2024.04.12.180908+*)
	i_iCycleTime_Plc: INT;
END_VAR
VAR
	rVel_Cur_mpm:REAL;
	rVel_Cur_rpm:REAL;
	xRunning:BOOL;(*运行中*)
	iAccTime_Nor:INT:=20;(*正常加速时间|S*)
	iDecTime_Nor:INT:=10;(*正常停止时间|S*)
	iDecTime_Fast:INT:=2;(*快停时间|s*)
	iDecTime_Cur: INT;(*当前减速时间*)
	rVel_Tar_mpm: REAL;(*目标速度|输入赋值*)
	rVel_CurTar_mpm: REAL;(*目标速度|=-222为手动加速使能|正常值则为自动加减速*)
	xAutuoAccDec: BOOL;(*自动加减速标志*)
END_VAR
{IMPLEMENTATION}
(*取运行使能*)
IF i_pxRunning<>0 THEN
	xRunning:=i_pxRunning^;
END_IF
(*取线速度和转速*)
IF i_prVel_Cur_mpm<>0 THEN
	rVel_Cur_mpm:=i_prVel_Cur_mpm^;
END_IF
IF i_prVel_Cur_rpm<>0 THEN
	rVel_Cur_rpm:=i_prVel_Cur_rpm^;
END_IF

xAutuoAccDec:=i_xAutuoAccDec;
rVel_Tar_mpm:=i_rVel_Tar_mpm;

iDecTime_Cur:=iDecTime_Nor;
IF i_xStopFast THEN
	iDecTime_Cur:=iDecTime_Fast;
END_IF

(*执行部分*)
IF i_xDebugEn THEN(*调试使能|*)
	(*使能标志处理*)
	IF i_xRun THEN(*运行有效*)
		IF NOT xRunning THEN(*非运行中*)
			xRunning:=TRUE;(*输出运行中标志|控制电机使能*)
		END_IF
	END_IF
END_IF

(*停止是标志处理|*)
IF NOT i_xDebugEn OR
	NOT i_xRun THEN
	IF NOT i_xStopByDec THEN
		xRunning:=FALSE;
		rVel_Cur_mpm:=0.0;(*速度写0*)
	ELSE(*停止到0*)
		IF rVel_Cur_mpm>=0.0001 THEN
			xAutuoAccDec:=TRUE;
			rVel_Tar_mpm:=0;
		END_IF
	END_IF

	IF rVel_Cur_mpm<=0.0001 THEN(*用线速度作为条件*)
		xRunning:=FALSE;
		rVel_Cur_mpm:=0.0;(*速度写0*)
	END_IF
END_IF
(*自动加减速控制|*)
IF xAutuoAccDec THEN
	rVel_CurTar_mpm:=rVel_Tar_mpm;
ELSE(**非自动加减速*)
	rVel_Tar_mpm:=-222;
END_IF


KS_VelPrf(
	xRunning,
	i_xManuAcc,
	i_xManuDec,
	i_iCycleTime_Plc,
	iAccTime_Nor,
	iDecTime_Cur,
	i_iVel_Max_mpm,
	rVel_Tar_mpm,
	ADR(rVel_Cur_mpm),
	i_uiMaxVel_UseCalcAcc);(*2024.04.12.181005+*)

(*将线速度转换为转速*)
IF i_rAxisGirth<>0 THEN
	rVel_Cur_rpm:=rVel_Cur_mpm*1000/i_rAxisGirth;
ELSE
	rVel_Cur_rpm:=0;
END_IF


(*取运行使能*)
IF i_pxRunning<>0 THEN
	i_pxRunning^:=xRunning;
END_IF
(*输出线速度和转速*)
IF i_prVel_Cur_mpm<>0 THEN
	i_prVel_Cur_mpm^:=rVel_Cur_mpm;
END_IF
IF i_prVel_Cur_rpm<>0 THEN
	i_prVel_Cur_rpm^:=rVel_Cur_rpm;
END_IF