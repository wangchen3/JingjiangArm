(*@CES
Name=StRecord_A
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=136b24a0-c4f1-416e-bf48-48716262a31a
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRecord_A :
STRUCT
	dwCurYMD: DWORD;
	dwCurHMSU: DWORD;
	byAxisId: BYTE; (* 轴id *)
	byGrpId: BYTE; (* 系id *)
	uiNum: UINT; (* 减速比分子 *)
	uiDen: UINT; (* 减速比分母 *)
	udiVel: UDINT; (* 主机速度|单位:0.01m/min *)
	udiGirth: UDINT; (* 版周长|单位:0.001mm *)
	iGateSa: INT; (* 波门地址1 *)
	iGateSaEx: INT; (* 波门地址2 *)
	byMarkTypeId: BYTE; (* 标记形式 *)
	byMarkArrangeId: BYTE; (* 标记排列 *)
	wSwitchRef: WORD; (* 开关状态 *)
	wStatusRef: WORD; (* 手/自动状态 *)
	wExtendedProf: WORD;
			(* 描述位|
				bit0=1表示合压中,
				bit1=1标识等料长,
				bit2=1标识裁切让料头

				bit8=1表示第一组波门T1极性
				bit9=1表示第一组波门T2极性
				bit10=1表示第二组波门T1极性
				bit11=1表示第二组波门T2极性
*)
	byStsV: BYTE; (* 纵向误差状态 *)
	byStsH: BYTE; (* 横向误差状态 *)
	aiKpid_setup_v: ARRAY [1..3] OF INT; (*界面设置的纵向pid*)
	aiKpid_setup_h: ARRAY [1..3] OF INT; (*界面设置的横向pid*)
	aiKpid_used_v: ARRAY [1..3] OF INT; (*使用中的纵向pid*)
	aiAdjVal_vh: ARRAY [1..2] OF INT; (*纵横向版修正量*)
	lrFilmLengthFromPrevUnit: LREAL; (* 预套准料长总值 *)
	byCouplingMask: BYTE; (* 耦合开关 *)
	iErrDataRelay_Index_V: INT; (* 取的误差间隔幅数 *)
	iErrDataRelay_V: INT; (* 传来的误差 *)
	aiErrorVal_vh: ARRAY [1..2] OF INT; (*纵横向误差*)
	aiAdjValCalcByPid_vh: ARRAY [1..2] OF INT; (*计算的调整量*)

	alrCurCycleAdjustVal_Auto_vh: ARRAY [1..2] OF LREAL; (* 自动调整*)
	alrCurCycleAdjustVal_Rapid_vh: ARRAY [1..2] OF LREAL; (* 快速对版调整*)
	alrCurCycleAdjustVal_ManuCoarse_vh: ARRAY [1..2] OF LREAL; (* 手动粗调*)
	alrCurCycleAdjustVal_ManuFine_vh: ARRAY [1..2] OF LREAL; (* 手动细调*)
	alrCurCycleAdjustVal_Coupling_vh: ARRAY [1..2] OF LREAL; (* 耦合量*)
	alrCurcycleAdjustVal_Compensate_vh: ARRAY [1..2] OF LREAL; (* 补偿量*)

	alrTotalAdjustVal_Auto_vh: ARRAY [1..2] OF LREAL; (* 自动调整仓库*)
	alrTotalAdjustVal_Rapid_vh: ARRAY [1..2] OF LREAL; (* 快速对版仓库*)
	alrTotalAdjustVal_ManuCoarse_vh: ARRAY [1..2] OF LREAL; (* 手动粗调仓库*)
	alrTotalAdjustVal_ManuFine_vh: ARRAY [1..2] OF LREAL; (* 手动细调仓库*)
	alrTotalAdjustVal_Coupling_vh: ARRAY [1..2] OF LREAL; (* 耦合量仓库*)
	alrTotalAdjustVal_Compensate_vh: ARRAY [1..2] OF LREAL; (* 补偿量仓库*)

	alrExecutedAdjVal_Auto_vh: ARRAY [1..2] OF LREAL; (* 已经执行的自动调整量*)
	alrExecutedAdjVal_Rapid_vh: ARRAY [1..2] OF LREAL; (* 已经执行的快速调整量*)
	alrExecutedAdjVal_ManuCoarse_vh: ARRAY [1..2] OF LREAL; (* 已经执行的手动粗调量*)
	alrExecutedAdjVal_ManuFine_vh: ARRAY [1..2] OF LREAL; (* 已经执行的手动细调量*)
	alrExecutedAdjVal_Coupling_vh: ARRAY [1..2] OF LREAL; (* 已经执行的耦合量*)
	alrExecutedAdjVal_Compensate_vh: ARRAY [1..2] OF LREAL; (* 已经执行的补偿量*)

	dwFS_index: DWORD; (* 精采样数据幅数索引 *)
	aiParsing_base: ARRAY [1..2] OF INT; (* 两路信号基线 *)
	aiParsing_min: ARRAY [1..2] OF INT; (* 两路信号最小值 *)
	aiParsing_max: ARRAY [1..2] OF INT; (* 两路信号最大值 *)
	dwIndex:DWORD; (* 索引号，用于与张力数据对应*)
	(*保存精采样标志@可能会滞后一幅*)
	xSaveFineSampleData_ToArc:BOOL;



	(*2023.09.04.092458  增加*)
	aiActErrorVal_vh: ARRAY [1..2] OF INT; (*纵横向误差原始值|未经过平均的*)

	(*计算的当前误差@8bytes*)
	iVerror_FollowPreUnit 					: INT; (*纵向跟前一色误差@05号命令*)
	iVerror_Follow1Unit 					: INT;(*纵向跟1色误差@05号命令*)
	iHerror_FollowPreUnit 					: INT; (*横向跟前一色误差@05号命令*)
	iHerror_Follow1Unit 					: INT;(*横向跟1色误差@05号命令*)

	(*2024.03.10.233250 修改*)
	rFinalAdjust_V_Act:REAL;(*小黄耦合函数输出的实际调整量@上一拍的值|2023.11.18.194816*)
	(*2026.5.7.175735套色算法测试lhy+*)
	dwTime:DWORD; (*2026.1.17.112058*)
	abyReserved:ARRAY [1..2] OF BYTE;
	(*2023.11.18.194736|+rFinalAdjust_V_Act@10-->6*)
(*2023.11.18.194636 屏蔽使用@使用上面的数组保持内存对其|保证解析工具的兼容*)
(*
	(*2023.09.11.104053 增加误差滤波函数的数据保存*)
	iCurrentObservationError : INT;(*当前观测误差*)
	iPreviousAdjustment : INT;(*上一幅调整量@正误差需要输入负调整量-外面根据正逆序修改*)
	(*最终返回预测误差*)
	iPredictionError : INT; (*预测误差*)
	rKalmanGain:REAL;(*增益*)
*)

END_STRUCT
END_TYPE

{IMPLEMENTATION}
