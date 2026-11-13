(*@CES
Name=StParam_Diamonds_Wr_RunSts
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=071211b1-6761-4124-9f7e-0f9dc5f8b877
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Diamonds_Wr_RunSts :
STRUCT
	byStationId		: BYTE;//站号，虚拟轴显示对应实轴
	byUnitId		: BYTE;//色组号，牵引收放料可以写0
	byTypeId		: BYTE;//站类型--牵引、收放料、色组等类型
	byAxisId		: BYTE;//运控轴ID
	lrPos_Prf		: LREAL;//规划位置
	lrPos_Enc		: LREAL;//编码器位置
	rVel_Prf		: REAL;//编码器速度
	rVel_Enc		: REAL;//编码器速度
	dwMotionSts		: DWORD;//轴运动状态|16进制显示
	dwErr_Driver			: DWORD;//驱动器报警状态|16进制显示
	iErr_NetPort_a			: INT;//A误码率
 	iErr_NetPort_b			: INT;//B误码率
	uiVirtual_Cnt			: UINT;//虚拟码盘基数
	wVirtual_Sts			: WORD;//虚拟马盘状态|16进制显示
	uiBrake_Cnt				: UINT;//制动次数
	rCurrent_Driver			: REAL;//电流
	dwCurAxisEnc_Lock		: DWORD;	//当前轴锁存编码器值
	dwCurAxisTime_Lock		: DWORD;	//当前轴锁存系统时间                          		
 	rTemperaTure					: REAL;//电机温度
	rVdc							: REAL;//母线电压
//2026.5.25.093642重新整理一下这个列表

	abyDataRsv						: ARRAY [1..44] OF BYTE;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
