(*@CES
Name=StUnitParam_UnSave
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=be979c59-c798-41af-9e86-c1d3d1a3e0f0
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StUnitParam_UnSave :
STRUCT
	xMotRev_BottomRoller						: BOOL;(* 底辊电机反向运动 *)
	xSamRev_BottomRoller						: BOOL;(* 底辊采样反向 *)
	xMotRev_PrnRoller							: BOOL;(* 版辊电机反向运动 *)
	xSamRev_PrnRoller							: BOOL;(* 版辊采样反向 *)
	xMotRev_NetRoller							: BOOL;(* 网辊电机反向运动 *)

	xMotRev_NetRoller_Pressure_M				: BOOL;(* 网辊压力M侧电机反转/2021.11.16.133827/+4 *)
	xMotRev_NetRoller_Pressure_G				: BOOL;(* 网辊压力G侧电机反转 *)
	xMotRev_PrnRoller_Pressure_M				: BOOL;(* 版辊压力M侧电机反转 *)
	xMotRev_PrnRoller_Pressure_G				: BOOL;(* 版辊压力G侧电机反转 *)
	xMotRev_StrRoller_Pressure_M				: BOOL;(* 张带辊压力M侧电机反转 *)
	xMotRev_StrRoller_Pressure_G				: BOOL;(* 张带辊压力G侧电机反转 *)


	xFlag_RollerDn_BottomRoller					: BOOL;(* 底辊合压标志/底辊的胶辊 *)
	xFlag_RollerDn_PrnRoller					: BOOL;(* 印辊合压标志/靠上底辊 *)
	xFlag_RollerDn_NetRoller					: BOOL;(* 网辊合压标志/靠上版辊 *)

	xValid_BottomRoller							: BOOL;(* 底辊有效标志 *)
	iSid_BottomRoller							: INT;(* 底辊站id/初始-1/有效性通过查表确定 *)
	xStationOnline_BottomRoller					: BOOL;(* 站在线标志-底辊/读取站号以后实时更新 *)
	rAxisVel_BottomRoller						: REAL;(* 底辊轴速度 *)
(* 2021.12.29.152610/hdp *)

	xValid_PrnRoller							: BOOL;(* 印辊有效标志 *)
	iSid_PrnRoller								: INT;(* 版辊站id/初始-1/有效性通过查表确定 *)
	xStationOnline_PrnRoller					: BOOL;(* 站在线标志-版辊/读取站号以后实时更新 *)
	rAxisVel_PrnRoller							: REAL;(* 印版轴速度 *)


	xValid_NetRoller							: BOOL;(* 网辊有效标志 *)
	iSid_NetRoller								: INT;(* 网辊站id/初始-1/有效性通过查表确定 *)
	xStationOnline_NetRoller					: BOOL;(* 站在线标志-网辊/读取站号以后实时更新 *)
	rAxisVel_NetRoller							: REAL;(* 网辊轴速度 *)
(* 2021.12.29.152610/hdp *)

	iSid_PrnRoller_Pressure_M					: INT;(* 印辊压力电机M侧驱动器站号/初始-1 *)
	iSid_PrnRoller_Pressure_G					: INT;(* 印辊压力电机G侧驱动器站号/初始-1 *)
	iSid_PrnRoller_Pressure_2in1				: INT;(* 版辊压力电机驱动器站号 *)
		(*
		/2合1/初始-1
		/wCtlmod_PrnRoller_Pressure=2时用到 *)

	wCtlmod_NetRoller_Pressure					: WORD;(* 网辊压力控制方式 *)
		(*
		/0表示不控制(默认)
		/1为独立单轴控制
		/2为双轴控制
		/4为4轴驱动器控制 *)
	iSid_NetRoller_Pressure_M					: INT;(* 网辊压力电机M侧驱动器站号/初始-1 *)
	iSid_NetRoller_Pressure_G					: INT;(* 网辊压力电机G侧驱动器站号/初始-1 *)
	iSid_NetRoller_Pressure_2in1				: INT;(* 网辊压力电机驱动器站号 *)
		(*
		/2合1/初始-1
		/wCtlmod_NetRoller_Pressure=2时用到 *)

	iSid_Pressure_4in1							: INT;(* 压力电机4合1驱动器站号/版辊+网辊/初始-1 *)
		(*
		/wCtlmod_PrnRoller_Pressure=wCtlmod_NetRoller_Pressure=4时用到 *)
	iSid_StrRoller_Pressure_M					: INT;(* 印辊压力电机M侧驱动器站号/初始-1 *)
	iSid_StrRoller_Pressure_G					: INT;(* 印辊压力电机G侧驱动器站号/初始-1 *)
	iSid_StrRoller_Pressure_2in1				: INT;(* 版辊压力电机驱动器站号 *)
		(*
		/2合1/初始-1
		/wCtlmod_PrnRoller_Pressure=2时用到 *)
		
	iAxisIdx_PrnRoller_Pressure_M				: INT;(* 轴索引-版辊压力电机M侧 *)
	iAxisIdx_PrnRoller_Pressure_G				: INT;(* 轴索引-版辊压力电机G侧 *)
		(*
		/wCtlmod_PrnRoller_Pressure=2或4时用到*)

	iAxisIdx_NetRoller_Pressure_M				: INT;(* 轴索引-网辊压力电机M侧 *)
	iAxisIdx_NetRoller_Pressure_G				: INT;(* 轴索引-网辊压力电机G侧 *)
		(*
		/wCtlmod_NetRoller_Pressure=2或4时用到*)
		
	iAxisIdx_StrRoller_Pressure_M				: INT;(* 轴索引-网辊压力电机M侧 *)
	iAxisIdx_StrRoller_Pressure_G				: INT;(* 轴索引-网辊压力电机G侧 *)
		(*
		/wCtlmod_StrRoller_Pressure=2或4时用到*)



(* 2021.12.23.154424/hdp *)
	rPos_press_dn_PrnRoller_Pressure_M_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/版辊压力电机M侧/单位:mm *)
	rPos_press_dn_PrnRoller_Pressure_G_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/版辊压力电机G侧/单位:mm *)
	rPos_press_up_PrnRoller_Pressure_M_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/版辊压力电机M侧/单位:mm *)
	rPos_press_up_PrnRoller_Pressure_G_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/版辊压力电机G侧/单位:mm *)
	rPos_load_unload_PrnRoller_Pressure_M_Hmi	: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/版辊压力电机M侧/单位:mm *)
	rPos_load_unload_PrnRoller_Pressure_G_Hmi	: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/版辊压力电机G侧/单位:mm *)
(* end/hdp *)


(* 2021.12.22.185301/hdp *)
	rPos_press_dn_NetRoller_Pressure_M_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/网辊压力电机M侧/单位:mm *)
	rPos_press_dn_NetRoller_Pressure_G_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/合压位置/网辊压力电机G侧/单位:mm *)
	rPos_press_up_NetRoller_Pressure_M_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/网辊压力电机M侧/单位:mm *)
	rPos_press_up_NetRoller_Pressure_G_Hmi		: REAL;(* 根据坐标系界面显示变量-hmi/离压位置/网辊压力电机G侧/单位:mm *)
	rPos_load_unload_NetRoller_Pressure_M_Hmi	: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/网辊压力电机M侧/单位:mm *)
	rPos_load_unload_NetRoller_Pressure_G_Hmi	: REAL;(* 根据坐标系界面显示变量-hmi/装卸辊位置/网辊压力电机G侧/单位:mm *)
(* end/hdp *)


(* replaced@2021.12.22.185435/hdp
	lrAbsEnc_PrnRoller_Pressure_M				: LREAL;(* 版辊压力电机绝对值位置M侧/实时值 *)
	lrAbsEnc_PrnRoller_Pressure_G				: LREAL;(* 版辊压力电机绝对值位置G侧/实时值 *)
	lrAbsEnc_NetRoller_Pressure_M				: LREAL;(* 网辊压力电机绝对值位置M侧/实时值 *)
	lrAbsEnc_NetRoller_Pressure_G				: LREAL;(* 网辊压力电机绝对值位置G侧/实时值 *)
with... *)

(* 2021.12.22.185539/hdp *)
	rPos_PrnRoller_Pressure_M					: REAL;(* 版辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_PrnRoller_Pressure_G					: REAL;(* 版辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_M					: REAL;(* 网辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_NetRoller_Pressure_G					: REAL;(* 网辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)
	rFrontSurfacePos_PrnRoller_Pressure_M		: REAL;(* 版辊压力电机M侧前表面位置|mm-根据坐标系变化 *)
	rFrontSurfacePos_PrnRoller_Pressure_G		: REAL;(* 版辊压力电机G侧前表面位置|mm-根据坐标系变化 *)
	rRearSurfacePos_PrnRoller_Pressure_M		: REAL;(* 版辊压力电机M侧后表面位置|mm-根据坐标系变化 *)
	rRearSurfacePos_PrnRoller_Pressure_G		: REAL;(* 版辊压力电机G侧后表面位置|mm-根据坐标系变化 *)
	rFrontSurfacePos_NetRoller_Pressure_M		: REAL;(* 网纹辊压力电机M侧前表面位置|mm-根据坐标系变化 *)
	rFrontSurfacePos_NetRoller_Pressure_G		: REAL;(* 网纹辊压力电机G侧前表面位置|mm-根据坐标系变化 *)
	rRearSurfacePos_NetRoller_Pressure_M		: REAL;(* 网纹辊压力电机M侧后表面位置|mm-根据坐标系变化 *)
	rRearSurfacePos_NetRoller_Pressure_G		: REAL;(* 网纹辊压力电机G侧后表面位置|mm-根据坐标系变化 *)
	xReConfirmPos0_AbsEnc						: BOOL;(*重新确认零位标志|由于机械位置或者电机位置跑了引起的异常需要重新确认零位 *)
	byTarPos_Roller									: BYTE;(*辊子目标位置|0 换版位
																		  1 离压位
																		  2 合压位*)
	byCurPos_Roller									: BYTE;(*辊子当前位置|0 换版位
																		  1 离压位
																		  2 合压位*)
	byInPos_Roller									: BYTE;(*辊子到位标志|.0 全部到位
																		  .1 版辊操作侧到位
																		  .2 版辊传动侧到位
																		  .3 网辊操作侧到位
																		  .4 网辊传动侧到位*)
																		  
	rPos_StrRoller_Pressure_M					: REAL;(* 张带辊压力电机位置M侧/实时值|mm-根据坐标系变化 *)
	rPos_StrRoller_Pressure_G					: REAL;(* 张带辊压力电机位置G侧/实时值|mm-根据坐标系变化 *)


(* 2021.12.23.154050/hdp *)


(* 2021.12.22.184937/hdp *)
	xMotEn_PrnRoller_Pressure					: BOOL;(* 版辊压力电机使能 *)
	xMotEn_NetRoller_Pressure					: BOOL;(* 网纹辊压力电机使能 *)
	xMotStop_PrnRoller_Pressure					: BOOL;(* 版辊压力电机停止 *)
	xMotStop_NetRoller_Pressure					: BOOL;(* 网纹辊压力电机停止 *)
	xNetRollSyncMoveByPrnRoll_Pressure			: BOOL;(* 网纹辊随版辊同时运动标志 *)
	rMoveDis_PrnRoller_Pressure_M				: REAL;(* 版辊压力操作侧运动距离|mm *)
	rMoveDis_PrnRoller_Pressure_G				: REAL;(* 版辊压力传动侧运动距离|mm *)
	rMoveDis_NetRoller_Pressure_M				: REAL;(* 网纹辊压力操作侧运动距离|mm *)
	rMoveDis_NetRoller_Pressure_G				: REAL;(* 网纹辊压力传动侧运动距离|mm *)
	xPosDevLarge_PrnRoller_Pressure				: BOOL;(* 版辊压力电机位置左右偏差太大 *)
	xPosDevLarge_NetRoller_Pressure				: BOOL;(* 网纹辊辊压力电机位置左右偏差太大 *)
	xTooClose_PrnRollerAndNetRoller_M			: BOOL;(* 版辊压力电机和网纹辊电机操作侧距离太近 *)
	xTooClose_PrnRollerAndNetRoller_G			: BOOL;(* 版辊压力电机和网纹辊电机传动侧距离太近 *)
	xSyncMoving_PrnRollAndNetRoll				: BOOL;(* 版辊和网辊同步运动中标志/2021.12.23.153947/lyt *)
	byCoordinate								: BYTE := 1;(* 坐标系类型选择:默认是使用网纹辊/0-使用各自坐标系/1-使用网纹辊坐标系|2-使用版辊坐标系 *)
	rCoordinateInter_PrnRollerAndNetRoller		: REAL;(* 版辊和网纹辊坐标系间隔|mm *)

(* end/hdp *)

	dwAxisAlrSts_NetRoller_Pressure_M			: DWORD;(* 网辊压力M侧报警状态 *)
	dwAlrCode_NetRoller_Pressure_M				: DWORD;(* 网辊压力M侧报警代码 *)
	dwAxisAlrSts_NetRoller_Pressure_G			: DWORD;(* 网辊压力G侧报警状态 *)
	dwAlrCode_NetRoller_Pressure_G				: DWORD;(* 网辊压力G侧报警代码 *)
	dwAxisAlrSts_PrnRoller_Pressure_M			: DWORD;(* 版辊压力M侧报警状态 *)
	dwAlrCode_PrnRoller_Pressure_M				: DWORD;(* 版辊压力M侧报警代码 *)
	dwAxisAlrSts_PrnRoller_Pressure_G			: DWORD;(* 版辊压力G侧报警状态 *)
	dwAlrCode_PrnRoller_Pressure_G				: DWORD;(* 版辊压力G侧报警代码 *)

(* 2021.12.23.153614/hdp *)
	byStsRapidAdjust							: BYTE;(* 快速对版状态|0不动作/1执行离开合压位动作/2合压位离开完成 *)
(* end/hdp *)

(*	//重新整理，按照每一个DWORD代表一种类型的辊子，目前有版辊网棍张带辊
	dwPressureMotor_Move						: DWORD;(* 色组压力电机控制按钮/可能来自实体/可能来自通讯及UI部分 *)
(*												/bit.0 : 印刷版辊M侧电机前进 *)
(*												/bit.1 : 印刷版辊M侧电机后退 *)
(*												/bit.2 : 印刷版辊G侧电机前进 *)
(*												/bit.3 : 印刷版辊G侧电机后退 *)
(*												/bit.4 : 印刷版辊压力电机前进 *)
(*												/bit.5 : 印刷版辊压力电机后退 *)
(*												/bit.6~7: 空闲 *)
(*												/bit.8 : 网辊M侧电机前进 *)
(*												/bit.9 : 网辊M侧电机后退 *)
(*												/bit.10: 网辊G侧电机前进 *)
(*												/bit.11: 网辊G侧电机后退 *)
(*												/bit.12: 网辊压力电机前进 *)
(*												/bit.13: 网辊压力电机后退 *)
(*												/bit.14~15: 空闲 *)
(*												/bit.16: 色组版辊压力电机前进 *)
(*												/bit.17: 色组版辊压力电机后退 *)
(*												/bit.18: 色组版辊压力电机合压 *)
(*												/bit.19: 色组版辊压力电机离压 *)
(*												/bit.20~23: 空闲 *)
(*												/bit.24: 色组版辊压力电机合压位确认按钮 *)
(*												/bit.25: 色组版辊压力电机离压位确认按钮 *)
(*												/bit.26: 色组版辊压力电机装版位确认按钮 *)
(*												/bit.27: 色组版辊压力电机零位确认按钮 *)
(*												/bit.28: 色组版辊压力电机边界位确认按钮 *)
(*												/bit.29~31: 空闲 *)

	dwPressureMotor_Move_II						: DWORD;(* 色组压力电机控制按钮/可能来自实体/可能来自通讯及UI部分 *)
(*												/bit.0 : 印刷张带辊M侧电机前进 *)
(*												/bit.1 : 印刷张带辊M侧电机后退 *)
(*												/bit.2 : 印刷张带辊G侧电机前进 *)
(*												/bit.3 : 印刷张带辊G侧电机后退 *)
(*												/bit.4 : 印刷张带辊压力电机前进 *)
(*												/bit.5 : 印刷张带辊压力电机后退 *)
(*												/bit.6~7: 空闲 *)
(*												/bit.8 : 色组网辊压力电机合压位确认按钮 *)
(*												/bit.9 : 色组网辊压力电机离压位确认按钮 *)
(*												/bit.10: 色组网辊压力电机装版位确认按钮 *)
(*												/bit.11: 色组网辊压力电机零位确认按钮 *) 
(*												/bit.12: 色组网辊压力电机边界位确认按钮 *)
(*												/bit.13~15:空闲*)
(*												/bit.16: 色组张带辊压力电机合压位确认按钮 *)
(*												/bit.17: 色组张带辊压力电机离压位确认按钮 *)
(*												/bit.18: 色组张带辊压力电机装版位确认按钮 *)
(*												/bit.19: 色组张带辊压力电机零位确认按钮 *) 
(*												/bit.20: 色组张带辊压力电机边界位确认按钮 *)
(*												/bit.21~23: 空闲 *)
(*												/bit.24: 色组网辊压力电机前进 *)
(*												/bit.25: 色组网辊压力电机后退 *)
(*												/bit.26: 色组网辊压力电机合压 *)
(*												/bit.27: 色组网辊压力电机离压 *)
(*												/bit.28: 色组张带辊压力电机前进 *)
(*												/bit.29: 色组张带辊压力电机后退 *)
(*												/bit.30: 色组张带辊压力电机合压 *)
(*												/bit.31: 色组张带辊压力电机离压 *)
*)

//重新整理，按照每一个DWORD代表一种类型的辊子，目前有1:版辊;	2:网棍;	3:张带辊
	adwPressureMotor_Move						: ARRAY[1..3] OF DWORD ;(* 色组压力电机控制按钮/可能来自实体/可能来自通讯及UI部分 *)
(*												/bit.0 : 辊M侧电机前进 *)
(*												/bit.1 : 辊M侧电机后退 *)
(*												/bit.2 : 辊G侧电机前进 *)
(*												/bit.3 : 辊G侧电机后退 *)
(*												/bit.4 : 辊压力电机前进 *)
(*												/bit.5 : 辊压力电机后退 *)
(*												/bit.6 : 辊压力电机长步持续前进 *)
(*												/bit.7 : 辊压力电机长步持续后退 *)
(*												/bit.8 : 辊压力电机离压 *)
(*												/bit.9 : 辊压力电机换版 *)
(*												/bit.10: 辊压力电机合压 *)
(*												/bit.11: 机械操作面板控制的印版辊压力电机换版走离压 *)
(*												/bit.12: 机械操作面板控制的印版辊压力电机离压走换版 *)
(*												/bit.13: 机械操作面板控制的印版辊压力电机在走离压换版的过程中停止 *)
//2026.02.23.132846 
(*												/bit.14: 自动换版 *)
(*												/bit.15: 换版完成 *)
(*												/bit.16: 色组版辊压力电机合压位确认按钮 *)
(*												/bit.17: 色组版辊压力电机离压位确认按钮 *)
(*												/bit.18: 色组版辊压力电机装版位确认按钮 *)
(*												/bit.19: 显示换版状态 *)
(*												/bit.20~23: 空闲 *)
(*												/bit.24~31: 空闲 *)

	iCTL_Sample									: INT;(* 采样控制标志/ctl *)
	(*
	/以下时和套色有关的定义 *)
	iSampleCfgParam_ctl				:INT ;(*采样控制参数里的ctl		*)
	byColorIdCurrent				:BYTE;(*当前色序				*)
//	byColorIdFollow					:BYTE;(*跟踪色序				*)
	iRoundSampleDataSa							: INT;(* 粗采样数据起点 *)
	iRoundSampleViewDensity						: INT;(* 波形显示横向放大用的系数 *)
	byArcSts									: BYTE;(* 套色状态/bit0=报警/bit1=丢失 *)

(* 2021.12.6.145203/hdp/弃用.bit31的分配/单标记确认的操作通过主站和从站的界面提交动作/程序重新处理rOMKPos0_进行上下位机的同步即可 *)
(*												/bit31.单标记误差确认/状态改变1次认为操作1次/开机上电置位FALSE/2021.11.19.135306/+ *)



	wSts_TowardsTar_H							: WORD;(* 横向目标值状态 *)
	iPos_TowardsTar_H							: INT;(* 横向目标值运动位置实时值 *)
	dwSpecialRequest							: DWORD;(* 特殊请求位 *)
(*												/bit0.横向左-1 *)
(*												/bit1.横向左-2 *)
(*												/bit2.横向右-1 *)
(*												/bit3.横向右-2 *)
	dwExtendedMask								: DWORD;(* 扩展标志位 *)
(*												/bit0.色组记录粗采样数据/@2021.11.17.115203 *)
(*												/bit1.色组记录精采样数据/@2021.11.17.135352 *)
(*												/ *)
(*												/bit31.让料头/@2021.11.17.160031 *)

	rOMKPos0_									: REAL;(* 单标记0位 *)

	(* 色组调整相关 *)
	axCurCycleAdjustVal_Auto_done_vh			: ARRAY [1..2] OF BOOL;(* 本周期的自动套色调整消耗完成/[1]纵向/[2]横向 *)
	alrCurCycleAdjustVal_Auto_vh				: ARRAY [1..2] OF LREAL;(* 自动调整/[1]纵向/[2]横向 *)
	alrTotalAdjustVal_Auto_vh					: ARRAY [1..2] OF LREAL;(* 自动调整仓库/[1]纵向/[2]横向 *)
	alrExecutedAdjVal_Auto_vh					: ARRAY [1..2] OF LREAL;(* 已经执行的自动调整量/[1]纵向/[2]横向 *)

	axCurCycleAdjustVal_Rapid_done_vh			: ARRAY [1..2] OF BOOL;(* 本周期的快速对版调整消耗完成/[1]纵向/[2]横向 *)
	alrCurCycleAdjustVal_Rapid_vh				: ARRAY [1..2] OF LREAL;(* 快速对版调整/[1]纵向/[2]横向 *)
	alrTotalAdjustVal_Rapid_vh					: ARRAY [1..2] OF LREAL;(* 快速对版仓库/[1]纵向/[2]横向 *)
	alrExecutedAdjVal_Rapid_vh					: ARRAY [1..2] OF LREAL;(* 已经执行的快速调整量/[1]纵向/[2]横向 *)

	axCurCycleAdjustVal_ManuCoarse_done_vh		: ARRAY [1..2] OF BOOL;(* 本周期的手动粗调消耗完成/[1]纵向/[2]横向 *)
	alrCurCycleAdjustVal_ManuCoarse_vh			: ARRAY [1..2] OF LREAL;(* 手动粗调/[1]纵向/[2]横向 *)
	alrTotalAdjustVal_ManuCoarse_vh				: ARRAY [1..2] OF LREAL;(* 手动粗调仓库/[1]纵向/[2]横向 *)
	alrExecutedAdjVal_ManuCoarse_vh				: ARRAY [1..2] OF LREAL;(* 已经执行的手动粗调量/[1]纵向/[2]横向 *)

	axCurCycleAdjustVal_ManuFine_done_vh		: ARRAY [1..2] OF BOOL;(* 本周期的手动细调消耗完成/[1]纵向/[2]横向 *)
	alrCurCycleAdjustVal_ManuFine_vh			: ARRAY [1..2] OF LREAL;(* 手动细调/[1]纵向/[2]横向 *)
	alrTotalAdjustVal_ManuFine_vh				: ARRAY [1..2] OF LREAL;(* 手动细调仓库/[1]纵向/[2]横向 *)
	alrExecutedAdjVal_ManuFine_vh				: ARRAY [1..2] OF LREAL;(* 已经执行的手动细调量/[1]纵向/[2]横向 *)

	axCurCycleAdjustVal_Coupling_done_vh		: ARRAY [1..2] OF BOOL;(* 本周期的耦合消耗完成/[1]纵向/[2]横向 *)
	alrCurCycleAdjustVal_Coupling_vh			: ARRAY [1..2] OF LREAL;(* 耦合量/[1]纵向/[2]横向 *)
	alrTotalAdjustVal_Coupling_vh				: ARRAY [1..2] OF LREAL;(* 耦合量仓库/[1]纵向/[2]横向 *)
	alrExecutedAdjVal_Coupling_vh				: ARRAY [1..2] OF LREAL;(* 已经执行的耦合量/[1]纵向/[2]横向 *)

	
(* 2021.12.30.165518/lyt/+ *)
	tMovingTimeSa									:TIME;(*运动启动时间|ms*)
	xAutoSts_Roller_Pressure						:BOOL;(*压力辊自动状态*)

	(*
	/保留部分 *)
	xMoveEnable_Motor						: BOOL;(*电机运动使能|用于控制驱动器是否进行电机控制|与单联动比较切换电机是否运动*)
	byHandWheelSts: BYTE;(**)
	
	rCurrent_PrnPressure_M: REAL;//版辊M侧电机电流
	rCurrent_PrnPressure_G: REAL;//版辊M侧电机电流
	rCurrent_NetPressure_M: REAL;//网辊M侧电机电流
	rCurrent_NetPressure_G: REAL;//网辊M侧电机电流
	rCurrent_StrPressure_M: REAL;//张带辊M侧电机电流
	rCurrent_StrPressure_G: REAL;//张带辊M侧电机电流
	wSts_HorzManuPreReg						: WORD; (* 横向手动预套准状态标志|bit0运行标志|bit1正转|bit2反转|bit3左限位|bit4右限位|bit5停止 *)
	iPos_HorzManuPreReg						: INT;(*横向手动预套准位置|*)
	xFlag_HorzPreRegister_ing				: BOOL;(*横向预套准进行中|*)
	xFlag_HorzPreRegister_end				: BOOL;(*横向预套准完成|*)

	diPreReg_RepeatVal_H					: DINT;(*预套准重复值-横向|单位:mm|*)
	diPreReg_SetupVal_H						: DINT;(*预套准设定值-横向|单位:mm|*)

	lrVelocity_CoatingPrn					: LREAL;(*涂布速度|*)
	byBtn_AdjModeSwitch_CoatingPrn			: BYTE;(*涂布调整方式切换按钮|*)
	xAxisInching							: BOOL;(*版辊单运行中*)
	xAxisInching_Net						: BOOL;(*网辊单运行中*)
	iPhase_InstallPlate						: INT;(*装版相位|*)
	iPhase_RegisterOk						: INT;(*套准相位|版套印准确的相位<通用相位和相位保存/恢复都可以复用该变量>|*)
	//lrPreReg_ConstVal						: LREAL;(*预套准色组间固定料长部分|单位:mm*)	
	
	xEn_Motor_PrnRoller						: BOOL;(*版辊开始运行标志-运动过程中序保证该标志一直有效*)
	xEn_Motor_NetRoller						: BOOL;(*网辊开始运行标志-运动过程中序保证该标志一直有效*)
	xEn_Motor_BottomRoller						: BOOL;(*底辊开始运行标志-运动过程中序保证该标志一直有效*)

	
	xFlag_FastAdjusting						: BOOL;//快速对半中2023.8.18.104925新增标志
	xFlag_MediumAdjusting				: BOOL;//粗调中
	xFlag_SlowAdjusting				: BOOL;//细调/等

	//以下位色组各轴的离线报警位置偏差报警标志
	xNetOffline_Horz:BOOL;
	xAxisAlarm_Horz:BOOL;
	xPosDeviationAlarm_Horz:BOOL;
	
	xNetOffline_PrnRoller:BOOL;
	xAxisAlarm_PrnRoller:BOOL;
	xPosDeviationAlarm_PrnRoller:BOOL;
	
	xNetOffline_NetRoller:BOOL;
	xAxisAlarm_NetRoller:BOOL;
	xPosDeviationAlarm_NetRoller:BOOL;
	
	xNetOffline_BottomRoller:BOOL;
	xAxisAlarm_BottomRoller:BOOL;
	xPosDeviationAlarm_BottomRoller:BOOL;
	
	xNetOffline_Prn_Pressure_M:BOOL;
	xAxisAlarm_Prn_Pressure_M:BOOL;
	xPosDeviationAlarm_Prn_Pressure_M:BOOL;
	
	xNetOffline_Prn_Pressure_G:BOOL;
	xAxisAlarm_Prn_Pressure_G:BOOL;
	xPosDeviationAlarm_Prn_Pressure_G:BOOL;

	xNetOffline_Net_Pressure_M:BOOL;
	xAxisAlarm_Net_Pressure_M:BOOL;
	xPosDeviationAlarm_Net_Pressure_M:BOOL;

	xNetOffline_Net_Pressure_G:BOOL;
	xAxisAlarm_Net_Pressure_G:BOOL;
	xPosDeviationAlarm_Net_Pressure_G:BOOL;
	
	xNetOffline_Str_Pressure_M:BOOL;
	xAxisAlarm_Str_Pressure_M:BOOL;
	xPosDeviationAlarm_Str_Pressure_M:BOOL;

	xNetOffline_Str_Pressure_G:BOOL;
	xAxisAlarm_Str_Pressure_G:BOOL;
	xPosDeviationAlarm_Str_Pressure_G:BOOL;
	
	xNetOffline_PHOTOCELL:BOOL;
	xAxisAlarm_PHOTOCELL:BOOL;
	xPosDeviationAlarm_PHOTOCELL:BOOL;
	//2023.8.18.143436各个轴的具体报警信息；
	
	dwAlarmDetail_Prn:DWORD;//轴报警信息-版辊
	dwAlarmDetail_Net:DWORD;//轴报警信息-wnag辊
	dwAlarmDetail_Bottom:DWORD;//轴报警信息-底辊
	dwAlarmDetail_Prn_M:DWORD;//轴报警信息-版辊_M
	dwAlarmDetail_Prn_G:DWORD;//轴报警信息-版辊_G
	dwAlarmDetail_Net_M:DWORD;//轴报警信息-网辊_M
	dwAlarmDetail_Net_G:DWORD;//轴报警信息-网辊_G
	dwAlarmDetail_Horz:DWORD;//轴报警信息-横向
	dwAlarmDetail_PHOTOCELL:DWORD;//光电眼
	dwAlarmDetail_Str_M:DWORD;//轴报警信息-网辊_M
	dwAlarmDetail_Str_G:DWORD;//轴报警信息-网辊_G


	xOnline_NR_M_: BOOL;(* 网辊压力M侧在线 *)
	xOnline_NR_G_: BOOL;(* 网辊压力G侧在线 *)
	xOnline_PR_M_: BOOL;(* 版辊压力M侧在线 *)
	xOnline_PR_G_: BOOL;(* 版辊压力G侧在线 *)
	xOnline_STR_M_: BOOL;(* 版辊压力M侧在线 *)
	xOnline_STR_G_: BOOL;(* 版辊压力G侧在线 *)

	iSid_Horiz_: INT;(* 横向伺服站点 *)
	xMotRev_Horiz_: BOOL;(* 横向伺服反转 *)
	xOnline_Horiz_: BOOL;(* 横向伺服在线 *)
	rErr_V:REAL;
	rErr_H:REAL;
	
	xValid_PhotoCell							: BOOL;		(* 光电眼有效标志 *)
	iSid_PhotoCell							: INT;			(* 光电眼站id/初始-1/有效性通过查表确定 *)
	xStationOnline_PhotoCell					: BOOL;		(* 站在线标志-光电眼/读取站号以后实时更新 *)
	xMotRev_PhotoCell							: BOOL;		(* 光电眼电机反向运动 *)
	rAxisVel_PhotoCell						: REAL;			(* 光电眼轴速度 *)

(*2023.9.25.135838*)	
	byEn_Motor_Pressure_: BYTE;
	//每个色组可以有8个龙门控制轴-4组，目前只用到了4个
	byEn_Motor_Trap_: BYTE;(*.0 横向
							 .1	光电眼*)
	//每个色组可以有8个点位控制轴-4组，目前只用到了1个，横向，其他当预留吧，反正一个BOOL和一个BYTE是一样的；
(*2023.10.27.085455*)
	//横向软限位
(*
	lrLimit_Left : LREAL;
	lrLimit_Right : LREAL;
*)
	abyRsv_Data1: ARRAY [1..16] OF BYTE;
	rweigth_Prn_Bottom_Cur					: REAL;//这个是版辊中心到版辊和底辊/中心辊切点的横向距离
	rweigth_Prn_Net_Cur					: REAL;//这个是版辊中心到版辊和网辊切点的横向距离
	rweigth_Net_Prn_Cur				: REAL;//这个是网辊中心到网辊与版辊切点的横向距离
	rweigth_Net_Load_Cur					: REAL;//这个是版辊中心到版辊和网辊切点的横向距离
	
	//bai.zy | 2024.04.03.132443 | 光电眼软限位位置记录
	lrPhotoCellPosLimit_M : LREAL;
	lrPhotoCellPosLimit_G : LREAL;

(*2023.10.14.105907加热部分增加|28zijie*)
(*加热相关*)
(* 加热部分 *)
	rPV_UnitTemCtl							: REAL;(* 色组温度控制实时值 *)
																  
(* 刮刀部分 *)

	rHz_UnitExhaust_CurrRD					: REAL;(* 排风当前回读频率/pdu上行给主站/ *)
	rHz_UnitExhaust_CurrWR					: REAL;(* 排风当前写入频率/pdu下行给从站/ *)
	wSTS_UnitExhaust						: WORD;(* 排风状态|/.0 通讯返回运行状态
												   /.6 排风打开超时-
												   /.7 485通讯断开标志
												   高8位作为报警码*)
	dwCtlBits_UnitBaseCraft					: DWORD;(* 用户基础工艺控制位/加热/递墨辊/刮刀/热风 *)
												(*
												/ .bit0 ~bit3  刮刀
												/	/.bit0 刮刀自动(TRUE)/手动(FALSE)
												/	/.bit1 刮刀开(TRUE)/关(FALSE)
												/	/.bit2 刮刀运行信号/控制变频器启动
												/	/.bit3
												/ .bit4 ~bit7  递墨辊
												/	/.bit4 递墨辊自动(TRUE)/手动(FALSE)
												/	/.bit5 递墨辊正转(TRUE)/关或反转(FALSE)
												/	/.bit6 递墨辊反转(TRUE)/关或正转(FALSE)
												/	/.bit7 递墨辊运行信号/控制变频器启动-与/.4/.5共同确定正转还是反转
												/ .bit8 ~bit11 热风I
												/	/.bit8 热风I开(TRUE)/关(FALSE)
												/	/.bit9 热风I运行信号/控制变频器启动
												/	/.bit10
												/	/.bit11
												/ .bit12~bit15 热风II
												/	/.bit12 热风II开(TRUE)/关(FALSE)
												/	/.bit13 热风II运行信号/控制变频器启动
												/	/.bit14
												/	/.bit15
												/ .bit16~bit23
												/	/ .bit16 加热方式（水）
												/	/ .bit17 加热方式（电）
												/	/ .bit18 I档
												/	/ .bit19 II档
												/	/ .bit20 III档
												/	/ .bit21
												/	/ .bit22
												/ .bit23~bit26
												/	/ .bit23 刮刀故障复位
												/	/ .bit24 递墨故障复位
												/	/ .bit25 热风I故障复位
												/	/ .bit26 热风II故障复位
												/   / .bit27 排风故障复位
												/ .bit28~bit31 /2022.3.23.152646/hdp/预分配好/为和界面作绑定
												/	/ .bit28 排风开(TRUE)/关(FALSE)
												/	/ .bit29 排风运行信号/控制变频器启动
												/	/ .bit30
												(*2022.4.20.091641 移动到此处*)
												/	/ .bit31: 2022.4.20.091632|冷风机开关使能位||
												*)		
	lrAxisScraperVel						: LREAL;(*刮刀速度输出|*)		
	rAI0Value_16D							: REAL;(*16D io接口获取的模拟量输入值|*)
	rTempValue_16D							: REAL;(*16D io接口获取的温度值|*)
	rAO0Value_16D							: REAL;(*16D io接口输出的电压值1|*)
	rAO1Value_16D							: REAL;(*16D io接口输出的电压值2|*)
	rDemarcate_Read_1					: REAL;
	rDemarcate_Read_2					: REAL;
	rDemarcate_Write_1					: REAL;
	rDemarcate_Write_2					: REAL;	

	//2023.11.21.155350色组压印到压印的料长
	lrArc_length_PrintPoint				: LREAL;
	dwSlaveBtn_HMI:DWORD;
												(*2023.12.22.205559
												bit0:纵向上调；
												bit1:纵向下调；
												bit2:横向左调；
												bit3:横向右调；
												bit4:版辊M侧前进；
												bit5:版辊M侧后退；
												bit6:版辊平行前进；
												bit7:版辊平行后退；
												bit8:版辊G侧前进；
												bit9:版辊G侧后退；
												bit10:网辊M侧前进；
												bit11:网辊M侧后退；
												bit12:网辊平行前进；
												bit13:网辊平行后退；
												bit14:网辊G侧前进；
												bit15:网辊G侧后退；
												
												*)	
//秦华带长调整开关
	xAdjBandLen							 : BOOL;	
	
	// 2024.10.21.114937 | bai.zy | 版辊网辊操作侧传动侧标定平行标志、标定平行后产生的误差值 15字节
	xConfirmParallelPos_Prn : BOOL;//平行确认按钮
	xConfirmParallelPos_Net : BOOL;
	xConfirmParallelPos_Str : BOOL;
	rParallelError_Prn_MM : REAL;//计算出的两侧误差
	rParallelError_Net_MM : REAL;
	rParallelError_Str_MM : REAL;
	
//根据单圈绝对值计算的装版位置；2024.10.22.222722	4字节
	diPhase_Enc_InstallPlate: DINT;
	
//2024.12.03.162342 | 增加调试阶段的压力运动 ，标定最大限位  ---3字节
	axCalidPressLimit_Max : ARRAY[1..3] OF BOOL;	
	
	wUnit_input_I : WORD;
						(*
							bit0: 联动
							bit1: 单运行
							bit2: 急停输入
							bit3: 报警
							bit4: 细调
							bit5: 自动合压
							bit6: 合压输入
							bit7: 离压输入
							bit8: 点动离压
							bit9: 纵向上
							bit10: 纵向下
							bit11: 横向左限位
							bit12: 横向左
							bit13:
							bit14:
							bit15: IO监控标志位
						*)
	wUnit_input_II : WORD;
							(*
							bit0: 横向右
							bit1: 横向右限位
							bit2: 横向电机快
							bit3: 冷风开关
							bit4: 冷风按钮
							bit5: 热风报警
							bit6: 热风开关
							bit7: 热风按钮
							bit8: 温度到达预设
							bit9: 加热I档
							bit10:加热II档
							bit11:加热III档
							bit12: 加热按钮
						*)
	wUnit_input_III : WORD;
						(*
							bit0: 刮刀变频报警
							bit1: 刮刀开关
							bit2: 排风开关
							bit3: 递墨辊正转
							bit4: 递墨辊上
							bit5: 排风按钮
							bit6: 加速
							bit7: 减速
							bit8: 停机
							bit9: 快停
							bit10: PTC过温
							bit11: 顶板送
						*)
	wUnit_output_I : WORD;
						(*
							bit0: 联动指示
							bit1: 单运行指示
							bit2: 急停灯输出
							bit3: 套色正常
							bit4: 套色报警
							bit5: 套色丢失
							bit6: 横向正转输出
							bit7: 本组套色报警
							bit8: 合压输出
							bit9: 横向反转输出
							bit10: 轴故障指示
							bit11: 离压输出
							bit12: 冷风输出
						*)
	wUnit_output_II : WORD;
						(*
							bit0: 热风输出
							bit1: 色组排风输出
							bit2: 加热I输出
							bit3: 加热II输出
							bit4: 加热III输出
							bit5: 刮刀使能
							bit6: 递墨辊正转
							bit7: 递墨辊上						
						*)												
	rHz_UnitHotWind2_CurrRD					: REAL;(* 热风当前回读频率/pdu上行给主站/ *)
	rHz_UnitHotWind2_CurrWR					: REAL;(* 热风当前写入频率/pdu下行给从站/ *)
	wSTS_UnitHotWind_2						: WORD;(* 热风II状态 *)
	rHz_UnitHotWind_CurrRD					: REAL;(* 热风当前回读频率/pdu上行给主站/ *)
	rHz_UnitHotWind_CurrWR					: REAL;(* 热风当前写入频率/pdu下行给从站/ *)
	wSTS_UnitHotWind						: WORD;(* 热风状态 |.0 运行\停止
												               /.6 热风风打开超时-
												  			   /.7 485通讯断开标志*)
	rHz_UnitScraper_CurrRD					: REAL;(* 刮刀当前回读频率/pdu上行给主站/ *)
	rHz_UnitScraper_CurrWR					: REAL;(* 刮刀当前写入频率/pdu下行给从站/ *)
	wSTS_UnitScraper						: WORD;(* 刮刀状态/pdu上行给主站/ |.0 运行\停止
												              				  /.6 刮刀打开超时-
												                              /.7 485通讯断开标志*)
	rHz_UnitInkRoller_CurrRD				: REAL;(* 递墨辊当前回读频率/pdu上行给主站/ *)
	rHz_UnitInkRoller_CurrWR				: REAL;(* 递墨辊当前写入频率/pdu下行给从站/ *)
	wSTS_UnitInkRoller						: WORD;(* 递墨辊状态/pdu上行给主站 |.0 运行\停止
												              				   /.6 递墨辊刀打开超时
												                               /.7 485通讯断开标志*)
	wSTS_UnitTemCtl							: WORD;(* 色组温度控制报警代码|低8位作为运行状态
																				/.0 通讯返回运行状态
																				/.1 加热使能输出状态
												  高8位作为报警状态/.8 断偶标志 
																   /.9 超温标志
																   /.10 离线标志*)
	rVerror_Lp		: REAL;(*低通滤波以后的误差@误差平均值需要写0*)			
	xArcErrValid		: BOOL;	
	xArcErrValid_Use_Niu: BOOL;				
	iArcErr_V: INT;(*套色的纵向误差@每圈更新一次并按bit置位表示误差有效*)	
	xSkipHeader								: BOOL;(*让料头*)	
	xSkipHeaderSts							: BOOL;(*让料头状态@每次接料都会计算@根据是否打开让料头标志是否输出xSkipHeader*)
	xArcErrIsValid_V						: BOOL;(*纵向误差有效*)	   
	xArcErrIsValid_H						: BOOL;(*横向误差有效*)	   
	(*套色相关一些值写入到轴参数中-50BYTES@2024.6.15.103803*)
	xArcErrIsLost_V							: BOOL;	(*纵向套色误差丢失*)
	xArcErrIsFake_V							: BOOL;	(*纵向套色误差飞点*)
	(*套色相关一些值写入到轴参数中-50BYTES@2024.6.15.103803*)
	xArcErrIsLost_H							: BOOL;	(*横向套色误差丢失*)
	xArcErrIsFake_H							: BOOL;	(*横向套色误差飞点*)
	
	xArcErrIsAlarm_V						: BOOL;(*纵向报警*)
	xArcErrIsAlarm_H						: BOOL;(*横向报警*)	
	xFlag_PressDn							: BOOL;(*色组压辊标志*)
	iFinalAdjust_V							: INT;
	iFinalAdjust_H							: INT;
	
	iVerror_Follow1UnitByErrTrans			: INT;(*纵向误差跟踪第一色@通过传递计算值*)

	
	(*增加一下误差队列*)
	byIndex: BYTE;
	aiError_V_History: ARRAY [1..50] OF INT;(*纵向误差队列*)
	aiError_H_History: ARRAY [1..50] OF INT;(*横向误差队列*)											

	(*新增参数|wang.nt|2025.08.08.155511*)
	alrCurcycleAdjustVal_Compensate_vh: ARRAY [1..2] OF LREAL; (* 补偿量*)
	alrTotalAdjustVal_Compensate_vh: ARRAY [1..2] OF LREAL; (* 补偿量仓库*)
	alrExecutedAdjVal_Compensate_vh: ARRAY [1..2] OF LREAL; (* 已经执行的补偿量*)	
	axCurCycleAdjustVal_Compensate_done_vh: ARRAY [1..2] OF BOOL; 
	xAxisAutoPressed					: BOOL;			
	byRapidAdjustStep					: BYTE;
	xRapidAdjust_ing					: BOOL;	
	iRapidAdjust_TimingCnt				: INT;
	(*新增工艺参数|2025.08.15.151756*)
	byFreq_ExhaustAir : BYTE;
	byFreqCur_ExhaustAir :BYTE ; 
	byAirInletWindDoorValue_FeedBack : BYTE;
		
(*2025.8.19.201439新增||需要在main里面赋值一下*)
	uiFSampleCounter: UINT;	
	iManualPlateAdjustment_disp: INT;(*2025.5.15.195937/han.dp/+单位mm@显示当前值*)	
	iAdjValue_V								: INT;(*统计纵向总调整量-用于实现新型耦合方式@um*)		
(*2025.8.22.212351*)
	lrEnc_Pos: LREAL;(*版辊编码器位置*)		
(*2025.9.24.175237||从这里开始属于润新测试后新增变量，与家里参数不再一致，回去更新吧*)	
	xAxisInf_IO_Alarm_HotBlower: BIT;(*风机变频故障*)
	xAxisInf_IO_Alarm_PowerAdj: BIT;(*功率调整器故障*)
	xAxisInf_IO_Alarm_HeatClose: BIT;(*加热电源脱开故障*)
	xAxisInf_IO_Alarm_HeatLimit: BIT;(*超温报警*)
	xAxisInf_IO_Alarm_InkRoller: BIT;(*递墨变频故障*)
	xAxisInf_IO_Alarm_Scraper: BIT;(*刮刀变频故障*)
	xAxisInf_IO_Alarm_ExhAir: BIT;(*排风变频故障*)
	xInValidVirtualCnt: BIT;(**)
	wVirTual_Cnt: WORD;(*虚拟码盘计数*)
	wVirTual_Sts: WORD;(*虚拟码盘状态*)
	lrPrf_Pos: LREAL;(*版辊编码器位置*)		
	byEnableModeSwitchDne: BYTE;
	rAxisPrfVel: REAL;
	iAxisPrnRunCaseId: INT;
	
	
	//2026.5.9.190555+
	dwLockTime_GetArcErr:DWORD;(*获取到套色误差的锁存时间@华南理工需要*)
	dwTime_Lock:DWORD;//锁存时间
	dwEnc_Lock:DWORD;//锁存编码器
	iStationId_CTL:INT:=-1;//控制的站id@例如月光宝盒\月光宝盒站id,如果是16d则和iStationId保持一样(iStationId该变量现在是电机驱动器的站号注意)
	
	//xNetOffline_Ctl色组控制器离线
	xNetOffline_Ctl: BOOL;
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
