(*@CES
Name=StPdu_Dn_94_Dep
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=28ccc25b-e1b3-40e8-9cb7-612afea4cc4b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPdu_Dn_94_Dep :
STRUCT
	rPos_M_Prn_HandWheelCtl		:REAL;(*版辊压力操作侧位置-手轮显示						*)
	rPos_G_Prn_HandWheelCtl		:REAL;(*版辊压力传动侧位置-手轮显示						*)
	rPos_M_Net_HandWheelCtl		:REAL;(*网辊压力操作侧位置-手轮显示						*)
	rPos_G_Net_HandWheelCtl		:REAL;(*网辊压力传动侧位置-手轮显示						*)
	rPos_PrnRoller_Pressure_M	:REAL;(*版辊压力操作侧实时位置							*)
	rPos_PrnRoller_Pressure_G	:REAL;(*版辊压力传动侧实时位置							*)
	rPos_NetRoller_Pressure_M	:REAL;(*网辊压力操作侧实时位置							*)
	rPos_NetRoller_Pressure_G	:REAL;(*网辊压力传动侧实时位置							*)
	byCtlId_HandWheel			:BYTE;(*手轮控制ID										*)
	byCtlSts_HandWheel			:BYTE;(*手轮控制状态									*)
	wAxis_Alarm_Net				:WORD;(*色组网辊报警状态(bit0-1U,bit15-16U)				*)
	wAxis_Alarm_Bottom			:WORD;(*色组底辊报警状态(bit0-1U,bit15-16U)				*)
	wAxis_Alarm_Prn_M			:WORD;(*色组版辊压力操作侧报警状态(bit0-1U,bit15-16U)	*)
	wAxis_Alarm_Prn_G			:WORD;(*色组版辊压力传动侧报警状态(bit0-1U,bit15-16U)	*)
	wAxis_Alarm_Net_M			:WORD;(*色组网辊压力操作侧报警状态(bit0-1U,bit15-16U)	*)
	wAxis_Alarm_Net_G			:WORD;(*色组网辊压力传动侧报警状态(bit0-1U,bit15-16U)	*)
	wAxis_Alarm_Other			:WORD;(*整机其他轴报警状态								*)
	abyRsv_93					:array [1..9] of BYTE;(*柔印参数预留									*)		
END_STRUCT
END_TYPE

{IMPLEMENTATION}
