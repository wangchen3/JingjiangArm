(*@CES
Name=StPdu_Dn_91
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=22e1e21e-e973-4286-a59d-d3b41682a852
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPdu_Dn_91 :
STRUCT
	byUnitId					:BYTE  ;(*机组号+系ID(最高位为系ID)*)
	rGirth_Sam					:REAL  ;(*采样版周长*)
	uiNum_Sam					:WORD  ;(*采样减速比分子*)
	uiDen_Sam					:WORD  ;(*采样减速比分母*)
	byCurrUsrLevel				:BYTE  ;(*用户权限*)
	iCompanyId					:INT   ;(*用户编号*)
	byLanguageId				:BYTE  ;(*语言选择*)
	byMinutes_ScrAutoSleep		:BYTE  ;(*屏幕休眠时间*)
	wUnit_input_I				:WORD  ;(*色组IO输入1*)
	wUnit_input_II				:WORD  ;(*色组IO输入2*)
	wUnit_input_III				:WORD  ;(*色组IO输入3*)
	wVelocity					:WORD  ;(*主机速度，单位0.1m/min*)
	wVel_Axis					:WORD  ;(*轴速度，单位0.1m/min*)
//	wComplexBit					:WORD  ;(*复合控制位描述*)
	wAxis_RollerDn				:WORD  ;(*轴压辊状态(bit0-1U,bit15-16U)*)
	wAxis_Alarm_Prn				:WORD  ;(*色组版辊报警状态(bit0-1U,bit15-16U)*)
	dwAlarmCode					:DWORD ;(*轴报警码*)
	wComplexFlag_AxisInching	:WORD  ;(*所有轴的单运行状态*)
	wComplexFlag_Linkage		:WORD  ;(*所有轴的联动状态*)
	wComplexFlag_Estop			:DWORD ;(*所有轴的急停状态*)
	wHMI_SwitchSts				:WORD  ;(*色组人机界面开关状态*)
	wSts_HorzManuPreReg			:WORD  ;(*横向手动预套准状态*)
	iPos_HorzManuPreReg			:INT   ;(*横向手动预套准位置*)
(*2025.8.6.205703增加*)	
	bySts_Flag					:BYTE;(*色组状态*)
(*	dwAxis_SkipTheHeader 		:DWORD;(*让料头标志*)*)
	bySts_Machine				:BYTE;
	(*
		bit0: 印刷标志
		bit1: 空转标志
		bit2: 
	*)
	//2025.11.14.155203||把误差状态发到从站，用于从站人机屏保实现9-1=8；
	byErrSts_V					: BYTE;
//用两个预留放低通滤波频率2025.11.15.132130|niu.j|8-2=6	
	//Filter原本的wRsv在这里改一下改为从站精采样数据低通滤波频率
	uilowpasscutoff_hz				:UINT;
	
	abyRsv_91					:ARRAY [1..6] OF BYTE  ;(*预留空间*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
