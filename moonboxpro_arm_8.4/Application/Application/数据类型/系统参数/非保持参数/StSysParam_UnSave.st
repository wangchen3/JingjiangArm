(*@CES
Name=StSysParam_UnSave
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=a407ba0f-c9c2-422c-ab5e-e61307b67d21
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSysParam_UnSave :
STRUCT
	stStSysCfgStruct							: StSysCfgStruct;(* 2022.6.8.154438/hdp/系统配置更改结构 *)			
	byCurrUsrLevel								: BYTE;(*用户等级处理*)
	diEncPos_Virtual							: DINT;
	(*tcp需要的*)
	(*[2]=厂家支持设备@10bytes*)
	xCommEn_Tcp:BOOL;(*厂家支持设备tcp通讯使能@常有效*)
	xOpenSocketing:BOOL;(*厂家支持设备tcp打开中@连接中*)
	xOpenSocketDne:BOOL;(*厂家支持设备tcp打开成功*)
	xOpenSocketFailed:BOOL;(*厂家支持设备tcp打开失败*)
	xConnectOk_Tcp: BOOL;(*厂家支持设备连接成功了*)
	byConnectSts_Tcp:BYTE;(*厂家支持设备的连接状态		  @=0 未打开
														  @=1 打开中@连接中
														  @=2 打开成功
														  @=3 打开失败
														  @=4 通讯超时*)
	abyReserved_Tcp:ARRAY [1..4] OF BYTE;

	(*[1]=监控设备@10bytes*)
	xCommEn_WatchDevice_Tcp:BOOL;(*监控设备tcp通讯使能@常有效*)
	xOpenSocketing_WatchDevice:BOOL;(*监控设备tcp打开中@连接中*)
	xOpenSocketDne_WatchDevice:BOOL;(*监控设备tcp打开成功*)
	xOpenSocketFailed_WatchDevice:BOOL;(*监控设备tcp打开失败*)
	xConnectOk_WatchDevice_Tcp: BOOL;(*监控设备连接成功了*)
	byConnectSts_WatchDevice_Tcp:BYTE;(*监控设备的连接状态@=0 未打开
														  @=1 打开中@连接中
														  @=2 打开成功
														  @=3 打开失败
														  @=4 通讯超时*)
	abyReserved1_Tcp:ARRAY [1..4] OF BYTE;
	
(*新增2023.10.14.104239||11字节*)													
	(*485需要的@10bytes*)
	xCommEn_485:BOOL;(*485通讯使能开关*)
	xOpenPortDne:BOOL;(*485打开成功*)
	xOpenPortFailed:BOOL;(*485打开失败*)
	xCommEn_WatchDevice_485:BOOL;(*监控设备通讯使能*)
	byConnectSts_485:BYTE;(*485设备的连接状态@=0 未打开
											 @=1 打开中@连接中@485不用
											 @=2 打开成功
											 @=3 打开失败*)
	abyReserved_485:ARRAY [1..5] OF BYTE;		

	rAO0_WaterValue_Start					: REAL;
	rAO0_WaterValue_Start2					: REAL;

	dwCtl_FromDiamonds						: DWORD;(*金刚界面的一些临时按钮控制*)
											(*
											bit0~bit15: A系用
											bit0: 预启动
											bit1: 停机
											bit2: 急停
											bit16~bit31: B系用
											bit16: 预启动
											bit17: 停机
											bit18: 急停
											*)
	byTaperUnitType:BYTE;(*张力单位切换标志|.0 放牵\.1收牵\.2放料\.3收料*)
	byCurGrpId_HMI: BYTE;(*当前界面的系号*)
	byArcDeCoupleStepTest:BYTE;(*套色阶跃测试@=1 经过小黄解耦控制器输出阶跃调整量
											   @=2 不经过解耦控制器直接阶跃输出*)	
	xSaveFineSampleData_ToArc: BOOL;
	iAxisId_CurSmpData: INT;(*当前显示的波形机组号*)
	abyData_T1_R: ARRAY [1..4000] OF BYTE;
	abyData_T1_G: ARRAY [1..4000] OF BYTE;
	abyData_T1_B: ARRAY [1..4000] OF BYTE;
	abyData_T2_R: ARRAY [1..4000] OF BYTE;
	abyData_T2_G: ARRAY [1..4000] OF BYTE;
	abyData_T2_B: ARRAY [1..4000] OF BYTE;

	aiStationList_UnitController: ARRAY [1..MAX_STATION_NUM] OF INT;(*用月光宝盒/PRO时候，需要一个控制器列表，用于通讯？*)
	aiAxisIdList_UnitArcAdj: ARRAY [1..MAX_STATION_NUM] OF INT;(*用月光宝盒/PRO时候，需要一个轴列表-对应宝盒/PRO*)
	
	(*2025.8.19.213305*)
	dwAxis_SkipTheHeader				: DWORD;(*让料头标志| 位标志bit0=机组1,...,bit31=机组32*)	
	
	xIOTestMode: BIT;(*IO测试模式*)
	xMoveFreq_I_ToAll_AirHot: BIT;
	xMoveFreq_II_ToAll_AirHot: BIT;
	xMoveFreq_III_ToAll_AirHot: BIT;
	xMoveFreq_I_ToAll_ExhaustAir: BIT;
	xMoveFreq_II_ToAll_ExhaustAir: BIT;
	xMoveFreq_III_ToAll_ExhaustAir: BIT;
	xSwitch_ScraperReset								: BIT;
	xSwitch_InkRollerReset								: BIT;
	xSwitch_HotwindReset: BIT;
	xSwitch_ResetTemctlModule: BIT;		
	xSwitch_Copy1stUExhaustDamperPos : BIT;
	xInkGrooveCali_Hmi: BIT;
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
