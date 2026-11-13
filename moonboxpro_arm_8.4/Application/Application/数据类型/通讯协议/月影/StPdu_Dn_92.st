(*@CES
Name=StPdu_Dn_92
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=45573361-4128-408d-910f-d2643f065581
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StPdu_Dn_92 :
STRUCT
	iCurveViewMaxRange				:INT;(*误差曲线量程上限		*)
	bySignalGain					:BYTE;(*光电眼IO控制			*)
	byMarkTypeId					:BYTE;(*标记形式				*)
	byMarkArrangeModalId			:BYTE;(*标记排列形式			*)
	byFakeThreshold_V				:BYTE;(*纵向飞点阀值@丝			*)
	byFakeThreshold_H				:BYTE;(*横向飞点阀值@丝			*)
	rAlarm_V						:REAL;(*纵向报警值@mm			*)
	rAlarm_H						:REAL;(*横向报警值@mm			*)
	byAve_v_extra_V					:BYTE;(*套色误差显示平均次数	*)
	byAve_v_extra_H					:BYTE;(*套色误差显示平均次数	*)
(*	dwFlag_Sts						: DWORD;(* 状态标志 *)
(*												/bit0.纵向自动 *)
(*												/bit1.横向自动 
												/bit9.双极性*)
(*												/ *)
*)
	iGateWidthPhy					: INT ;(*波门宽度				*)
	byTriangleMark_SideC			: BYTE;(*梯形标记三角形纵向边长	*)
	byTriangleMark_SideB			: BYTE;(*梯形标记三角形横向边长	*)
	bySysSamplePrecision			: BYTE;(*系统采样精度			*)
	byArcFineSampleType				: BYTE;(*套色采样方式			*)
	iSampleCfgParam_ctl				: INT ;(*采样控制参数里的ctl		*)
	byColorIdCurrent				: BYTE;(*当前色序				*)
	byColorIdFollow					: BYTE;(*跟踪色序				*)
	abyColorIdList					: ARRAY [1..16] OF BYTE;(*色序列表				*)
	//bySignalSelect					:BYTE;(*光纤电眼信号选择		*)
	xEnable_Arc						: BOOL;(*套印使能开关			*)
	uiSource_Light_T1_Cur			: UINT;
	uiSource_Light_T2_Cur			: UINT;

	//xi.hy2026.5.9.104409
	wDirAndMode_FiberMove			:WORD;//光纤行走的方向和模式:低位方向,高位模式：0不运动 1连续运动 2定长运动 3回零运动
	uiVel_FiberMove					:UINT;//光纤行走的速度:mm/s *10
	uiDistanceOut_FiberMove			:UINT;//光纤行走的输出距离:mm *10
	uiPulsePerCycle_FiberMove		:UINT;//光纤行走的单圈脉冲:pluse
	
	abyRsv_92						: ARRAY [1..1] OF BYTE;(*套色参数预留			*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
