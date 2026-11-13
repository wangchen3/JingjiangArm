(*@CES
Name=StAxis_Sts_Gear
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=d33ee812-7e0e-4909-bba1-828f8390fbbb
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StAxis_Sts_Gear :
STRUCT
	byStationId				: BYTE;		//站号
	byUnitId				: BYTE;		//色组号
	byTypeId				: BYTE;		//类型
	byAxisId				: BYTE;		//轴号
	rGirth 					: REAL;		//轴周长
	dwMotionSts				: DWORD;	//运动状态
	lrPos_Prf				: LREAL;	//规划位置
	lrPos_Enc				: LREAL;	//编码器位置
	byAxisCtl				: BYTE;		//轴控制位
	dwMotionSts_AddUp		: DWORD;	//运动状态
	lrPos_Prf_AddUp			: LREAL;	//规划位置
	byMotionStep			: BYTE;		//运动步骤
	rVel_Axis				: REAL; 	//轴速度
	dimodify_delta			: DINT;		//离合区
	dwFlag_AxisSts			: DWORD;	//用于保存轴的状态或者标志
										//.0	xMoveEnable	轴运动使能
	rTorque					: REAL;		//扭矩输出	
	rTorqueCoeff			: REAL;		//扭矩系数                           		
	dwErr_Driver			: DWORD;	//驱动器报警状态
	wSts_Driver				: WORD;		//驱动器状态
	diRatio_A				: DINT;		//电子齿轮比A
	diRatio_B				: DINT;		//电子齿轮比B	
	
	diCurAxisEnc_Lock		: DWORD;	//当前轴锁存编码器值
	diCurAxisTime_Lock		: DWORD;	//当前轴锁存系统时间                          		
	wVirtual_Cnt			: WORD;		//虚拟码盘基数
	wVirtual_Sts			: WORD;		//虚拟码盘状态
	uiBrake_Cnt				: UINT;		//制动次数
	dwRsv1					: DWORD;	//预留1
	dwRsv2					: DWORD;	//预留2
	dwRsv3					: DWORD;	//预留3
	dwRsv4					: DWORD;	//预留4
	dwRsv5					: DWORD;	//预留5
END_STRUCT
END_TYPE

{IMPLEMENTATION}
