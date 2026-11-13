(*@CES
Name=StAxisWatchDetails
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=06521707-3ba7-4049-9244-d2161cd79c22
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StAxisWatchDetails :
STRUCT 
// 	iStationId						: INT;(*主控站ID*)
// 	rGirth 							:REAL ; (*周长*)
// 	iRtn_Station					: INT;//返回值
// 	iRunMode_Station				: INT;//运动模式-3电子齿轮4龙门
// 	rPos_Prf						: REAL;//规划位置
// 	rPos_Enc						: REAL;//编码器位置
// 	rVel_Enc						: REAL;//编码器速度
// 	rTorque							: REAL;//扭矩输出	
// 	rGantry_Err						: REAL;//龙门错误吗
//  	rTemperaTure					: REAL;//电机温度
// 	dwErr_Driver					: DWORD;//驱动器报警状态
// 	wSts_Driver						: WORD;//驱动器状态
// 	wSts_NetPort					: WORD;//端口状态
// 	wSts_NetRun						: WORD;//端口运行状态
//  	iErr_NetPort_a					: INT;//A误码率
//  	iErr_NetPort_b					: INT;//B误码率
// 	dwMotion_Sts					: DWORD;//运型状态
// 	uiVirtual_Cnt					: UINT;//虚拟码盘基数
// 	wVirtual_Sts					: WORD;//虚拟马盘状态
// 	uiBrake_Cnt						: UINT;//制动次数
// 	rCurrent_Driver					: REAL;//电流
// 	rVdc							: REAL;//母线电压
// 	uiStationType					: UINT;//站类型
// 	uiDrvParam_Imax					: UINT;(* 驱动参数|最大电流 *)
// 	uiDrvParam_Nrs					: UINT;(* 驱动参数|额定转速 *)
// 	uiDrvParam_Nos					: UINT;(* 驱动参数|过速转速 *)
// 	iDrvParam_PosOfst				: INT;(* 驱动参数|位置偏移 *)
	
	rGirth: REAL; (* 轴周长 *)
	lrPT_Pos: LREAL; (* 轴PT规划P *)
	diPT_Time: DINT; (* 轴PT规划T *)
	byPT_Type: BYTE; (* 轴PT段选择|2.PT_SEGMENT_NORMAL;1.PT_SEGMENT_EVEN;0.others *)
	rtnSts: INT; (* 返回状态 *)
	bySpace: BYTE; (* fifo空间 *)
	pfr: DWORD; (* 规划位置 *)
	enc_Lo16: INT; (* StPTSts.enc的低16位_跟随误差的低16位 *)
	driverSts: INT; (* 驱动器状态 *)
	driverErr: INT; (* 驱动器错误 *)
	netPortErr_a: INT; (* A口误码率 *)
	netPortErr_b: INT; (* B口误码率 *)
	motionSts: DWORD; (* 运动器状态 *)
	modal: WORD; (* 模态 *)
	brakeCnt: WORD; (* 制动电阻次数 *)
	driverCurrent: WORD; (* 驱动器电流 *)
	rVel_Axis: REAL; (* 轴速度 *)
	rAI_Axis_Coating: REAL; (* 当前值-中位值 *)
	enc_Hi16: WORD; (* StPTSts.enc的高16位_网络锁存时间的低16位 *)(* 新增14个字节|@2020.10.13.171810_ *)
	temperature: INT; (* 电机温度 *)
	vel: INT; (* 规划速度 *)
	netPortSts: INT; (* 网络端口连接状态 *)
	netRunSts: INT; (* 网络运行状态 *)
	virtualCnt: WORD; (* 虚拟码盘计数 *)
	virtualSts: WORD; (* 虚拟码盘状态 *)
	(*2022.5.25.131916 增加了锁存编码器值的保存*)
	dwCurAxisEnc_Lock: DWORD;(*当前轴锁存编码器值*)
	dwCurAxisSystime_Lock					: DWORD;(*当前轴锁存系统时间*)
(*2022.6.24.151851  取消使用*)
(*
	dwLastLinkageAxisEnc_Lock				: DWORD;(*上个联动轴锁存编码器值*)
	dwLastLinkageAxisSystime_Lock			: DWORD;(*上个联动轴锁存系统时间*)
*)
	(*2022.6.24.151255*)
	iai1_New16D:			INT;(*模拟量输入1*)
	iai2_New16D:			INT;(*温控输入*)
	rDc_Voltage:REAL;(*母线电压值*)
	idriverErr_H: INT; (* 驱动器错误 |高16bit*)

	(*新增加的单联动切换功能，在出现问题的时候为了方便查找问题,增加了文件保存内容*)
	(*电机使能模式|0: 不使能 1: 使能 3: 使能后轴可以手动转动 4: 取消模式3状态
	3、4以为的值都不允许set
	实际应用下会3、4状态下切换*)
	wEnableMode_Motor						: WORD;
	byEnableModeSwitchDne					: BYTE;(*使能模式切换成功了|.0 =3 成功了
																		.1 =4 成功了*)
	xMoveEnable_Motor						: BOOL;(*电机运动使能|用于控制驱动器是否进行电机控制|与单联动比较切换电机是否运动*)

	byAxisMotionSts:BYTE;(*轴运动状态标志|0:同步运动状态.
										  |1:同步运动时停止运动状态.
										  |2:停止运动状态
										  |3:停止运动时加速到单运行速度状态.
										  |4:单运行时减速到停止状态.
										  |5:停止运动时或者使用单运行速度运行时加速到同步运动状态.
										  |6:非同步运动时急停到0状态.
										  |7:非同步运动时空转停机到0状态.*) 
(*2022.10.22.162829保存加热相关数据*)
	rPIDValue:REAL;(*pid计算调整量*)
	rPV_Unit:REAL;(*当前温度*)
	rSV_Unit:REAL;(*设定温度*)
	rValue_P:REAL;
	rValue_I:REAL;
	rValue_D:REAL;
	iNumCount:INT;

(*end_2022.10.22.163310*)

END_STRUCT
END_TYPE

{IMPLEMENTATION}
