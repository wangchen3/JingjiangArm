(*@CES
Name=StSts_Modbus
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=cd32acf0-34b3-49da-a704-86f77df9a440
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSts_Modbus :
STRUCT
	xCommEn_Tcp								: BIT;(*厂家支持设备tcp通讯使能@常有效*)
	xOpenSocketing							: BIT;(*厂家支持设备tcp打开中@连接中*)
	xOpenSocketDne							: BIT;(*厂家支持设备tcp打开成功*)
	xOpenSocketFailed						: BIT;(*厂家支持设备tcp打开失败*)
	xConnectOk_Tcp							: BIT;(*厂家支持设备连接成功了*)

	(*[1]=监控设备@10bytes*)
	xCommEn_WatchDevice_Tcp					: BIT;(*监控设备tcp通讯使能@常有效*)
	xOpenSocketing_WatchDevice				: BIT;(*监控设备tcp打开中@连接中*)
	xOpenSocketDne_WatchDevice				: BIT;(*监控设备tcp打开成功*)
	xOpenSocketFailed_WatchDevice			: BIT;(*监控设备tcp打开失败*)
	xConnectOk_WatchDevice_Tcp				: BIT;(*监控设备连接成功了*)

(*新增2023.10.14.104239||11字节*)													
	(*485需要的@10bytes*)
	xCommEn_485								: BIT;(*485通讯使能开关*)
	xOpenPortDne							: BIT;(*485打开成功*)
	xOpenPortFailed							: BIT;(*485打开失败*)
	xCommEn_WatchDevice_485					: BIT;(*监控设备通讯使能*)
	
	xRsv_SysFlag_Modbus1					: BIT;(*预留1*)
	xRsv_SysFlag_Modbus2					: BIT;(*预留2*)
	
	byConnectSts_Tcp						: BYTE;(*厂家支持设备的连接状态		  @=0 未打开
														  @=1 打开中@连接中
														  @=2 打开成功
														  @=3 打开失败
														  @=4 通讯超时*)
	byConnectSts_WatchDevice_Tcp			: BYTE;(*监控设备的连接状态@=0 未打开
														  @=1 打开中@连接中
														  @=2 打开成功
														  @=3 打开失败
														  @=4 通讯超时*)	
	byConnectSts_485						: BYTE;(*485设备的连接状态@=0 未打开
											 @=1 打开中@连接中@485不用
											 @=2 打开成功
											 @=3 打开失败*)	
	byRsv_SysFlag_Modbus					: BYTE;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
