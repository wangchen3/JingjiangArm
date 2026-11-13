(*@CES
Name=GCL
Type=ConstantList
TypeGuid=ffbfa93a-b94d-45fc-a329-229860183b1d
Guid=bcb51df0-81a2-49d0-af31-1b6fd6cdee10
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
VAR_GLOBAL CONSTANT
	gc_xUseNewFlyRemove: BOOL:= TRUE;(*新飞点剔除总开关:TRUE=误差平均前用KS_FlyRemove
逐帧剔除并以锁存值替换飞点,FALSE=回退旧飞点判断KS_FB_PickOutFakePoint(旧逻辑完整
保留),改后重新编译生效|Yang.zj+用于新飞点检测 2026.10.24.191149*)
	MASTER_DRIVER_TIME:REAL:= 1;(*运控周期2ms*)
//2026.1.24.215529增加月光宝盒和月光宝盒PRO的类型
	HY_YTPE_CMM_CR_PRO: WORD:= 16#6006;
	HY_YTPE_CMM_CR: WORD:= 16#6005;
	
	
	USER_MAX_STATION_NUM_V1:INT:=256;	

	gc_iNum_ErrorNum_GT: INT:=3;//gt指令报错执行次数
	gc_iNum_ErrorNum_GT_LOG: INT:=300;//gt指令报错执行次数去写日志
	gc_iTime_s_ServoFailed: INT:=10;//10s伺服打开超时	

	gc_lrPi: LREAL:= 3.1415926;	
	MAX_UNIT_NUM: INT:=16;(*最大色组数*)
	MAX_STATION_NUM: INT:= 256;
	MAX_AXIS_NUM: INT:= 128;
	(*应对牵引周长算法增加稳速判断等待时长和模拟量滤波计算周长的时长
	默认等待10s和1s调整一次周长*)
	gc_iValueReferToLost: INT:= -32768	;										(*误差标识-丢失|*)
	gc_iValueReferToFakePoint: INT:= -32767	;									(*误差标识-飞点|*)
	gc_iValueReferToSkipTheHeader: INT:= -32766	;							(*误差标识-让料头|*)
	
	gc_iCycleNum_CalcGirthEvenDelay: INT:= 500;(*算周长算法稳速等待时常，推荐10s(20ms周期就是500个周期)*)
	gc_iCycleNum_CalcDelay: INT:= 500;(*周长计算间隔时长，推荐1s(20ms周期就是50个周期)*)
	
	gc_tmHold_PreStart				: TIME := T#3S; (* 开机预启动持续时间|该值在程序中赋值给响铃时间| 2022.5.27.143829|该值被弃用*)
	gc_tmHold_PreStart_BeiRen		: TIME := T#6s; (* 北人开机预启动持续时间|和响铃时间是分开的| 2022.5.27.143829*)
	gc_tmAlarmHold_PreStart			: TIME := T#3s; (* 开机预启动报警持续时间| *)
	GC_LRMOTORPPR					: LREAL:=4194304;//2025.7.3.175755
	gc_EXT_TSK_CYCLE_TIME		: INT := 35;(*2023.06.19.102054||niu.j||任务周期35*)
	gc_TENSION_TSK_CYCLE_TIME		: INT := 20;(*2023.06.19.102054||niu.j||任务周期35*)
	gc_MAIN_TSK_CYCLE_TIME		: INT := 10;(*2023.06.19.102054||niu.j||任务周期35*)

	MAX_CMD_NUM_PDU				: INT := 10;(* 最大pdu命令的数量 *)	
	MAX_PDU_CMD_BYTES_UP		: INT := 60;(* 来源于1024/16(MAX_UNIT_NUM)/此数必须是4字节的整数倍 *)
	MAX_PDU_CMD_BYTES_DN		: INT := 60;(* 来源于1024/16(MAX_UNIT_NUM)/此数必须是4字节的整数倍 *)
	MAILBOX_PKG_MAX_BYTES		: INT := 480;(* Mailbox包最大长度/2021.11.24.180543/+ *)
	TIMEOUTS_PDU_CMD_CHG		: TIME := T#60MS;(* PDU命令切换超时/2021.12.4.131327/hdp *)
	TIMEOUTS_MAILBOX_FORCESYNC	: TIME := T#100S;(* MAILBOX通讯强制同步超时/2021.12.21.143505/hdp *)

	MAX_KS_UDPPKG_BYTES: UINT := 1024;
	MAX_MEMBLOCK_BYTES: UINT:= (MAX_KS_UDPPKG_BYTES-20);
	PARAM_ZONE_ALTERNATE_OFST: UINT := 0;
	PARAM_ZONE_C2S: UINT := 16384;
	PARAM_ZONE_RESERVED: UINT := 45912;
	REGS_PER_DATA_NODE: UINT := 110;(*每个数据节点的寄存器数量*)
	MAX_DATA_NODE_NUM: UINT := 512;(*最大的数据节点数量*)
	MAX_MB_FIFO_ITEMS: INT := 10;(*ModBus报文FiFo条目上限*)

	
	CRC_DICTIONARY: ARRAY [0..255] OF WORD :=
		[16#0000, 16#1189, 16#2312, 16#329B, 16#4624, 16#57AD, 16#6536, 16#74BF,
		16#8C48, 16#9DC1, 16#AF5A, 16#BED3, 16#CA6C, 16#DBE5, 16#E97E, 16#F8F7,
		16#1081, 16#0108, 16#3393, 16#221A, 16#56A5, 16#472C, 16#75B7, 16#643E,
		16#9CC9, 16#8D40, 16#BFDB, 16#AE52, 16#DAED, 16#CB64, 16#F9FF, 16#E876,
		16#2102, 16#308B, 16#0210, 16#1399, 16#6726, 16#76AF, 16#4434, 16#55BD,
		16#AD4A, 16#BCC3, 16#8E58, 16#9FD1, 16#EB6E, 16#FAE7, 16#C87C, 16#D9F5,
		16#3183, 16#200A, 16#1291, 16#0318, 16#77A7, 16#662E, 16#54B5, 16#453C,
		16#BDCB, 16#AC42, 16#9ED9, 16#8F50, 16#FBEF, 16#EA66, 16#D8FD, 16#C974,
		16#4204, 16#538D, 16#6116, 16#709F, 16#0420, 16#15A9, 16#2732, 16#36BB,
		16#CE4C, 16#DFC5, 16#ED5E, 16#FCD7, 16#8868, 16#99E1, 16#AB7A, 16#BAF3,
		16#5285, 16#430C, 16#7197, 16#601E, 16#14A1, 16#0528, 16#37B3, 16#263A,
		16#DECD, 16#CF44, 16#FDDF, 16#EC56, 16#98E9, 16#8960, 16#BBFB, 16#AA72,
		16#6306, 16#728F, 16#4014, 16#519D, 16#2522, 16#34AB, 16#0630, 16#17B9,
		16#EF4E, 16#FEC7, 16#CC5C, 16#DDD5, 16#A96A, 16#B8E3, 16#8A78, 16#9BF1,
		16#7387, 16#620E, 16#5095, 16#411C, 16#35A3, 16#242A, 16#16B1, 16#0738,
		16#FFCF, 16#EE46, 16#DCDD, 16#CD54, 16#B9EB, 16#A862, 16#9AF9, 16#8B70,
		16#8408, 16#9581, 16#A71A, 16#B693, 16#C22C, 16#D3A5, 16#E13E, 16#F0B7,
		16#0840, 16#19C9, 16#2B52, 16#3ADB, 16#4E64, 16#5FED, 16#6D76, 16#7CFF,
		16#9489, 16#8500, 16#B79B, 16#A612, 16#D2AD, 16#C324, 16#F1BF, 16#E036,
		16#18C1, 16#0948, 16#3BD3, 16#2A5A, 16#5EE5, 16#4F6C, 16#7DF7, 16#6C7E,
		16#A50A, 16#B483, 16#8618, 16#9791, 16#E32E, 16#F2A7, 16#C03C, 16#D1B5,
		16#2942, 16#38CB, 16#0A50, 16#1BD9, 16#6F66, 16#7EEF, 16#4C74, 16#5DFD,
		16#B58B, 16#A402, 16#9699, 16#8710, 16#F3AF, 16#E226, 16#D0BD, 16#C134,
		16#39C3, 16#284A, 16#1AD1, 16#0B58, 16#7FE7, 16#6E6E, 16#5CF5, 16#4D7C,
		16#C60C, 16#D785, 16#E51E, 16#F497, 16#8028, 16#91A1, 16#A33A, 16#B2B3,
		16#4A44, 16#5BCD, 16#6956, 16#78DF, 16#0C60, 16#1DE9, 16#2F72, 16#3EFB,
		16#D68D, 16#C704, 16#F59F, 16#E416, 16#90A9, 16#8120, 16#B3BB, 16#A232,
		16#5AC5, 16#4B4C, 16#79D7, 16#685E, 16#1CE1, 16#0D68, 16#3FF3, 16#2E7A,
		16#E70E, 16#F687, 16#C41C, 16#D595, 16#A12A, 16#B0A3, 16#8238, 16#93B1,
		16#6B46, 16#7ACF, 16#4854, 16#59DD, 16#2D62, 16#3CEB, 16#0E70, 16#1FF9,
		16#F78F, 16#E606, 16#D49D, 16#C514, 16#B1AB, 16#A022, 16#92B9, 16#8330,
		16#7BC7, 16#6A4E, 16#58D5, 16#495C, 16#3DE3, 16#2C6A, 16#1EF1, 16#0F78];	
		
	(* 通讯信号 *)
	SEMA_UPLOAD					: DWORD := 16#87654321; (* 上行旗语/去主站 *)
	SEMA_DOWNLOAD				: DWORD := 16#12345678; (* 下行旗语/主站来 *)
(*	SEMA_EXT_UPLOAD				: DWORD := 16#56782345; (* 扩展上行旗语/去主站 *)
	SEMA_EXT_DOWNLOAD			: DWORD := 16#23455678; (* 扩展下行旗语/主站来 *)
*)	SEMA_REQ_DISPATCH			: DWORD := 16#51515151; (* 请求旗语/请求主站重新派发指定数据包 *)
	SEMA_PLS_REQ_DISPATCH		: DWORD := 16#A781220A; (* 请非主站重发请求指令(SEMA_REQ_DISPATCH)/主站来 *)
(*	SEMA_SYNC_ING				: DWORD := 16#13572468; (* 状态旗语/正在同步中... *)
	SEMA_SYNC_END				: DWORD := 16#A1A2A3A4; (* 状态旗语/同步完成... *)
*)	SEMA_VIP_COMMAND			: DWORD := 16#19781220; (* 超级旗语/作特殊用途... *)
	SEMA_STANDBY				: DWORD := 16#00000000; (* 复位旗语 *)
	
	(*2021.7.16.104349 485串口通讯使用|*)
	gc_auchCRCHi:ARRAY [0..255] OF BYTE:=
	[16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0,16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41,
	16#00, 16#C1, 16#81, 16#40, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0,16#80, 16#41, 16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1, 16#81, 16#40,
	16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1,16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0, 16#80, 16#41,
	16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1,16#81, 16#40, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41,
	16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0,16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#00, 16#C1, 16#81, 16#40,
	16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1,16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1, 16#81, 16#40,
	16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0,16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#00, 16#C1, 16#81, 16#40,
	16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0,16#80, 16#41, 16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1, 16#81, 16#40,
	16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0,16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41,
	16#00, 16#C1, 16#81, 16#40, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0,16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41,
	16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0,16#80, 16#41, 16#00, 16#C1, 16#81, 16#40, 16#00, 16#C1, 16#81, 16#40,
	16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0, 16#80, 16#41, 16#00, 16#C1,16#81, 16#40, 16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41,
	16#00, 16#C1, 16#81, 16#40, 16#01, 16#C0, 16#80, 16#41, 16#01, 16#C0,16#80, 16#41, 16#00, 16#C1, 16#81, 16#40];
	gc_auchCRCLo:ARRAY [0..255] OF BYTE:=
	[16#00, 16#C0, 16#C1, 16#01, 16#C3, 16#03, 16#02, 16#C2, 16#C6, 16#06,16#07, 16#C7, 16#05, 16#C5, 16#C4, 16#04, 16#CC, 16#0C, 16#0D, 16#CD,
	16#0F, 16#CF, 16#CE, 16#0E, 16#0A, 16#CA, 16#CB, 16#0B, 16#C9, 16#09,16#08, 16#C8, 16#D8, 16#18, 16#19, 16#D9, 16#1B, 16#DB, 16#DA, 16#1A,
	16#1E, 16#DE, 16#DF, 16#1F, 16#DD, 16#1D, 16#1C, 16#DC, 16#14, 16#D4,16#D5, 16#15, 16#D7, 16#17, 16#16, 16#D6, 16#D2, 16#12, 16#13, 16#D3,
	16#11, 16#D1, 16#D0, 16#10, 16#F0, 16#30, 16#31, 16#F1, 16#33, 16#F3,16#F2, 16#32, 16#36, 16#F6, 16#F7, 16#37, 16#F5, 16#35, 16#34, 16#F4,
	16#3C, 16#FC, 16#FD, 16#3D, 16#FF, 16#3F, 16#3E, 16#FE, 16#FA, 16#3A,16#3B, 16#FB, 16#39, 16#F9, 16#F8, 16#38, 16#28, 16#E8, 16#E9, 16#29,
	16#EB, 16#2B, 16#2A, 16#EA, 16#EE, 16#2E, 16#2F, 16#EF, 16#2D, 16#ED,16#EC, 16#2C, 16#E4, 16#24, 16#25, 16#E5, 16#27, 16#E7, 16#E6, 16#26,
	16#22, 16#E2, 16#E3, 16#23, 16#E1, 16#21, 16#20, 16#E0, 16#A0, 16#60,16#61, 16#A1, 16#63, 16#A3, 16#A2, 16#62, 16#66, 16#A6, 16#A7, 16#67,
	16#A5, 16#65, 16#64, 16#A4, 16#6C, 16#AC, 16#AD, 16#6D, 16#AF, 16#6F,16#6E, 16#AE, 16#AA, 16#6A, 16#6B, 16#AB, 16#69, 16#A9, 16#A8, 16#68,
	16#78, 16#B8, 16#B9, 16#79, 16#BB, 16#7B, 16#7A, 16#BA, 16#BE, 16#7E,16#7F, 16#BF, 16#7D, 16#BD, 16#BC, 16#7C, 16#B4, 16#74, 16#75, 16#B5,
	16#77, 16#B7, 16#B6, 16#76, 16#72, 16#B2, 16#B3, 16#73, 16#B1, 16#71,16#70, 16#B0, 16#50, 16#90, 16#91, 16#51, 16#93, 16#53, 16#52, 16#92,
	16#96, 16#56, 16#57, 16#97, 16#55, 16#95, 16#94, 16#54, 16#9C, 16#5C,16#5D, 16#9D, 16#5F, 16#9F, 16#9E, 16#5E, 16#5A, 16#9A, 16#9B, 16#5B,
	16#99, 16#59, 16#58, 16#98, 16#88, 16#48, 16#49, 16#89, 16#4B, 16#8B,16#8A, 16#4A, 16#4E, 16#8E, 16#8F, 16#4F, 16#8D, 16#4D, 16#4C, 16#8C,
	16#44, 16#84, 16#85, 16#45, 16#87, 16#47, 16#46, 16#86, 16#82, 16#42,16#43, 16#83, 16#41, 16#81, 16#80, 16#40];	
	SEMA_FUNCODE_485_MULT_WR: BYTE:= 16#10;
	SEMA_FUNCODE_485_MULT_RD: BYTE:= 16#03;
	RN_AWR:BYTE:= 16#01;
	RN_ARD:BYTE:= 16#05;
	
	(* 2025.8.27.154257/han.dp/新合并内容 *)
	FNAME_SYS_CONF: STRING := '/data/kesai/conf/HY.conf';
	FNAME_SYS_PARAM_A: STRING := '/data/kesai/conf/HY-A.bin';
	FNAME_SYS_PARAM_B: STRING := '/data/kesai/conf/HY-B.bin';
	
(*deprecated@2025.8.27.154330/han.dp
	EACH_MEM_BLOCK_LEN			: DWORD := 4096;(* 每次独立操作的内存块大小 *)
	FILE_BLOCKSIZE_PER_TIMES	: DWORD := 4096;(* 文件操作每次的块大小 *)	
	FNAME_SYS_PARAMETERS_A: STRING := '/data/kesai/conf/flexo_A.bin';(* 系统参数文件/2023.8.2.112609/han.dp *)
	FNAME_SYS_PARAMETERS_B: STRING := '/data/kesai/conf/flexo_B.bin';(* 系统参数文件/2023.8.2.112609/han.dp *)	
	GC_LOG_ITEM_MAX_NUM							: UINT := 512;(* 日志fifo的最大行数 *)	
	(* bit7~bit4/打印信息分类区域/@2021.2.26.111851 *)
	LOG_LEVEL_INFO_NORMAL						: WORD := 16#0080;(* 打印信息/常规 *)
	LOG_LEVEL_INFO_DBG							: WORD := 16#0040;(* 打印信息/程序调试 *)//YY2023.05.20.112732
*)

	gc_byCoatingMaxSum_New			: BYTE := 5; (* 涂布最大轴数-按照列表分配 *)
	gc_dwAbsEnCodeResolution_Uw		: DWORD:=8388608;(*绝对值编码器线束*) (* 2021.8.6.143421/lyt/2^23 *)
	gc_dwAbsEnCodeResolution_Rw		: DWORD:=8388608;(*绝对值编码器线束*) (* 2021.8.6.143421/lyt/2^23 *)	

	(*矩阵运算时申请空间所需要的参数|2023.2.16.114926*)
	MATRIX_ROW_MAX:INT:=4;(*矩阵最大行*)
	MATRIX_COLUMN_MAX:INT:=4;(*矩阵最大列*)
	MATRIX_ELEMENT_MAX:INT:=16;(*最大元素|行和列的乘积*)	
	//新增运动变量定义|2025.08.05.095813
	GC_LRMOTORPPR_TRAP			:LREAL:=262144.0;//4194304.0;(*Trap电机运动一圈脉冲数*)
	gc_rGirth_Master : REAL := 0.5;
	MAX_ROUNDSAMPLE_NUM: INT:= 4000;(*粗采样点数*)
	gc_iNDEL:INT:=20;(*从压印点到光电眼的幅数*)
	//2025.8.5.101743文件存储
	PREAMBLE: INT := 16#55AA;(* 2023.7.27.110513/han.dp/文件数据桢格式头 *)
	ENDMARK: BYTE := 16#FF;(* 2023.7.27.110513/han.dp/文件数据桢格式尾 *)
	BYTES_PER_ROW_RECORD						: UINT := 8192;(* 每个记录最大的字节数/2021.11.27.150026/hdp *)
	MAX_ROWS_OF_RECORD							: UINT := 5000;(* 记录的最大行/2021.11.27.150411/hdp *)
	PATH_HOME: STRING := '/data/kesai/';
	PATH_HOME_CONF: STRING :='/data/kesai/conf/';
	PATH_HOME_LOG: STRING := '/data/kesai/log/';
	PATH_HOME_DATA: STRING := '/data/kesai/data/';
	MAX_LOG_ITEM_VIEW :INT:= 100 ; 
//2025.07.14.160934 | WATCH文件路径
//	PATH_WATCHFILE_1 : STRING := '/opt/codesyscontrol/readCommandTable1.ini';
//	PATH_WATCHFILE_2 : STRING := '/opt/codesyscontrol/readCommandTable2.ini';
//	PATH_WATCHFILE_3 : STRING := '/opt/codesyscontrol/readCommandTable3.ini';
//	PATH_WATCHFILE_4 : STRING := '/opt/codesyscontrol/readCommandTable4.ini';
//	PATH_WATCHFILE_5 : STRING := '/opt/codesyscontrol/readCommandTableEXT.ini';
	PATH_CONFIG_CORE1 : STRING := '/opt/codesyscontrol/gtn_core1.cfg';
	PATH_CONFIG_CORE2 : STRING := '/opt/codesyscontrol/gtn_core2.cfg';	
	PATH_WATCHFILE : STRING := '/opt/codesyscontrol/readCommandTable.ini';
	
	(*2025.8.7.141111*)
	ARC_DELAY_N_MAX:INT:=50;
	ARC_DELAY_N_MAX_DDPD:INT:=200;(*DDPD解耦延时函数缓存大小,"该色到前一色料长/版周长"取整不得大于200*)
	DECOUPLD_DDPD_MAX:INT:=13;(*DDPD共配置13色解耦*)
	DECOUPLD_FDPD_MAX:INT:=13;(*FDPD共配置13色解耦@跟一色隔色解耦*)	
	gc_iMaxErrDataItemInList					: INT := 100;(* 误差传递功能的最大存储误差幅数数量 *)	
	GC_PU_MAX_NUM								: INT := 16;(* 支持的最大印刷色 *)	
	MAX_TSK_CYCLE_MONITORING	: INT := 3;(* 任务周期需要监测的最大数量 *)
	
(*日志服务新增*)

	GC_LOG_CLASSES_MAX_NUM						: INT := 4;(* 日志种类的数量/[1]总日志/[2]LOG_LEVEL_ALARM/[3]LOG_LEVEL_EVT_/[4]LOG_LEVEL_INFO/ *)


	(* 2021.1.22.163214|为了让过滤更好处理一些|我们从枚举放到了全局常量区域 *)
	(* bit15~bit12/故障报警等分类区域/@2021.2.26.111851 *)
	LOG_LEVEL_ALARM_FATAL						: WORD := 16#8000;(* 致命错误/程序运行都存在问题 *)
	LOG_LEVEL_ALARM_SERIOUS						: WORD := 16#4000;(* 严重报警/会作急停处理 *)
	LOG_LEVEL_ALARM_NORMAL						: WORD := 16#2000;(* 普通报警/不会主动急停 *)
	LOG_LEVEL_ALARM_LOGICCONDITION				: WORD := 16#1000;(* 报警|逻辑条件错误 *)

	(* bit11~bit8/事件记录分类区域/@2021.2.26.111851 *)
	LOG_LEVEL_EVT_USRACTIONS					: WORD := 16#0800;(* 事件记录/用户操作 *)
	LOG_LEVEL_EVT_MOTIONLOGIC					: WORD := 16#0400;(* 事件记录/运动逻辑 *)
	LOG_LEVEL_EVT_PROGRAM_AUTOMATIC				: WORD := 16#0200;(* 事件记录/程序自动触发 *)

	(* bit7~bit4/打印信息分类区域/@2021.2.26.111851 *)

	(* 2023.3.31.091435/han.dp/准备支持日志的部分中文显示 *)
	MAX_ALARMITEM_NUM							: INT := 100;(* 报警条目上限 *)	
	(*新增变量-开始|wang.nt|2025.08.13.135942*)
	GC_FORCEDOUT_AXIS_BOUND_L					: INT := 17;(* 强制排除的轴范围左边界从17/最大到GC_PU_MAX_NUM色 *)
	GC_FORCEDOUT_AXIS_BOUND_R					: INT := 20;(* 强制排除的轴范围右边界到20/21开始是B系放料A轴 *)
	(*新增变量-结束|wang.nt|2025.08.13.135942*)

	//2025.08.18.110718 | 增加固高WATCH功能路径
	PATH_HOME_WATCH_DATA: STRING := '/data/kesai/watch/watchData.txt';
 	PATH_HOME_WATCH_CONFIG: STRING := '/opt/codesyscontrol/watchTimer.ini';
	
	PATH_HOME_WATCH_CONFIG_TEMP: STRING := '/opt/codesyscontrol/watchTimerTemp.ini';
	
	(*2025.8.19.201228新增*)
	gc_iVirEncPPR: INT:= 8000;
	
	gc_diVirEncPPR_New			: DINT:= 131072;//131072;//2024.10.23.184529新增的单圈绝对位置累计值 |火眼从65536变换成131072
	//gc_dwMotorPPR								: DWORD := 2097152;(* 电机每转的脉冲数|2^21 *)
	gc_iCycleTime_Motion			: INT := 21; (* 2018.7.1.204007\原始约定| *)
	gc_byInvisCoatingPrnAxisIdx					: BYTE := 20;(* 涂布隐藏轴索引id *)	
	gc_byCoatingWay					: BYTE := 5;	
	
//2025.11.24.104500 | 增加修改龙门相关	
	gc_iMax_PressureRoller_Unit: INT:=3;//每个色组最大的压力组数
	gc_ResCount_Profile : INT := 64;//单个核的轴资源数
END_VAR
{IMPLEMENTATION}
