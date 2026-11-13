(*@CES
Name=StAxis_Sts_Trap
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=2d66e9bc-131c-4b1d-9db8-4381f072fd39
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StAxis_Sts_Trap :
STRUCT
	byStationId				: BYTE;		//站号
	byUnitId				: BYTE;		//色组号
	byTypeId				: BYTE;		//类型
	byAxisId				: BYTE;		//轴号
	dwMotionSts				: DWORD;	//运动状态
	lrPos_Prf				: LREAL;	//规划位置
	lrPos_Enc				: LREAL;	//编码器位置
	
	diTarget_pos			: DINT;		//目标位置
	udiMax_vel				: UDINT;	//最大速度
	
	byAxisCtl				: BYTE;		//轴控制位
	byMotionStep			: BYTE;		//运动步骤
	dwFlag_AxisSts			: DWORD;	//用于保存轴的状态或者标志
										//.0	xMoveEnable	轴运动使能
	rTorque					: REAL;		//扭矩输出	
	rTorqueCoeff			: REAL;		//扭矩系数                           		
	dwErr_Driver			: DWORD;	//驱动器报警状态
	wSts_Driver				: WORD;		//驱动器状态
	uiBrake_Cnt				: UINT;		//制动次数
	dwRsv1					: DWORD;	//预留1
	dwRsv2					: DWORD;	//预留2
	dwRsv3					: DWORD;	//预留3
	dwRsv4					: DWORD;	//预留4
	dwRsv5					: DWORD;	//预留5
END_STRUCT
END_TYPE

{IMPLEMENTATION}
