(*@CES
Name=StRecord_T
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=143e99cc-3331-46fe-a10c-279acbbec24f
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StRecord_T :
STRUCT
	dwYMD: DWORD;(* 年月日*)
	dwHMSU: DWORD;(* 时分秒毫秒*)
	byGrpId: BYTE; (* 系id\自动赋值 *)
	dwIndex: DWORD; (* 主任务周期索引 *)
	rVel_Cur: REAL; (* 当前速度 *)
	rVel_Film: REAL; (* 料膜速度 *)
	uiMillimeter_Diam_PaperTube_Uw: UINT; (* 放料卷纸卷直径|单位mm|2019.11.28.112452 *)
	uiMicron_FilmThickness: UINT; (* 料膜厚度|单位um|2019.11.28.112452 *)
	uiMicron_FilmThickness_RevCalculated: UINT; (* 料膜厚度的反算值|单位um|2019.11.29.153103 *)
	uiMeterLength_SurplusMaterial: UINT; (* 剩余料膜长度|单位m|2019.11.28.112452 *)
	dwFlag: DWORD; (* 标志位*)
					(*bit.0:放料当前轴
					  bit.1:收料当前轴
					  bit.2:压力传感器使能
					  bit.16:放料翻转架正转
					  bit.17:放料翻转架反转
					  bit.18:收料翻转架正转
					  bit.19:收料翻转架反转
					  bit.20:放料A轴正转使能
					  bit.21:放料B轴正转使能
					  bit.22:收料A轴正转使能
					  bit.23:收料B轴正转使能
					  bit.26:放料预估弧面信号
					  bit.27:放料对射电眼信号输入
					  bit.28:放料裁切按钮输入
					  bit.29:放料弧面信号输入
					  bit.30:放料裁刀输出
					  bit.31:放料胶辊输出
					*)
	arAI_UwRw_IfOf: ARRAY [1..4] OF REAL; (* 摆臂输入|rAI_Uw|rAI_Rw|rAI_If|rAI_Of *)
	arPI_UwRw_IfOf: ARRAY [1..4] OF REAL; (* Pi计算量|rPi_Uw|rPi_Rw|rPi_If|rPi_Of *)
	arDiam_UwRw_Girth_IfOf: ARRAY [1..4] OF REAL; (* 周长或直径|rGirth_Uw|rGirth_Rw|rGirth_If|rGirth_Of *)
	arStep_UwRw_IfOf: ARRAY [1..4] OF REAL; (* 前馈|rStep_Uw|rStep_Rw|rStep_If|rStep_Of *)
	arVel_UwRw_IfOf: ARRAY [1..4] OF REAL; (* 速度|rVel_Uw|rVel_Rw|rVel_If|rVel_Of *)
(*收放料PID保存改为*100||保留精度-改word型*)
	aiKpid_UwRw_IfOf: ARRAY [1..4,1..3] OF WORD; (* Kpid参数|iP_Uw|iI_Uw|iD_Uw|......|iP_Of|iI_Of|iD_Of *)
	rPressure_Tar: REAL; (* 压力传感器目标压力*)
	rCurPressureValue: REAL; (* 压力传感器实时压力*)
	wAOVolt_If_inverter: WORD; (* 放牵模拟量输出*)
	wAOVolt_Of_inverter: WORD; (* 收牵模拟量输出*)
	rStdVol_AI_cur: REAL; (* 当前卷径电压 *)
	rStdVol_AI_use: REAL; (* 计算用的卷径电压 *)
	rDia_New_Auto: REAL; (* 计算所得新卷卷径*)
	rUwPreVel_Vol_A: REAL; (* 放料预驱速度电压*)
	rUwPreVel_Vol_B: REAL; (* 放料预驱速度电压*)
	rRwPreVel_Vol_A: REAL; (* 收料预驱速度电压*)
	rRwPreVel_Vol_B: REAL; (* 收料预驱速度电压*)
	rUwPreVel: REAL; (* 放料预驱速度*)
	rRwPreVel: REAL; (* 收料预驱速度*)
	iMotionStepId: INT; (* MOTION_STEP_... *)
	iPromptMsgId: INT; (* 报警代码*)
	wPreHotRollerFrq: WORD; (* 预热辊输出*)
	wWaterCoolRollerFrq: WORD; (* 水冷辊输出*)
	byPlcLoad: BYTE; (* cpu消耗|2020.4.14.153153 *)
(*2023.09.20.134044 为了保证兼容|将这两个不用的real型变量作为他用|保证解析工具的内存对其*)
(*
	rVel_SelfAdjust_Uw_A: REAL; (* 2020.10.8.164751|放料A轴自调整速度 *)
	rVel_SelfAdjust_Uw_B: REAL; (* 2020.10.8.164751|放料B轴自调整速度 *)
*)
	awPressRollerVol:ARRAY [1..4] OF WORD;(*压力传感器电压值@留出来4个*)

	(*2021.8.27.170829 增加放料翻转架需要保存的变量*)
	rTowerThetaCur_Uw:REAL;
	rDeltaW_RPMIN_Uw:REAL;
	rFilmToTowerRollerDis: REAL;(*料膜距离导向辊距离|mm*)

	(*2021.8.27.093201  卷径估计需要变量保持*)
	rEstiDia_Uw:REAL;(*放料卷径估计值*)
	rEstiThickNess_Uw:REAL;(*放料厚度估计值*)
	rMainVel_Uw:REAL;(*卷径估计使用时 放料主速度*)
	rEstiDia_Rw:REAL;(*收料卷径估计值*)
	rEstiThickNess_Rw:REAL;(*收料厚度估计值*)
	rMainVel_Rw:REAL;(*卷径估计使用时 收料主速度*)

	(*2021.9.13.161022*)
(*2024.7.12.113636 复用位置*)
(*
	(*放料接料补偿-窄方波+微分*)
	rSpliceCompensate_Uw:REAL;(*计算的补偿值*)
	rSpliceCompensate_Wr_Uw:REAL;(*裁切补偿实际写入的值*)
*)
	rUseDiamWuCompensate_Uw:REAL;(*放料张力算法计算使用的卷径值*)
	rUseDiamWuCompensate_Rw:REAL;(*收料张力算法计算使用的卷径值*)

	(*2022.9.7.215546增加了锥度值的数据存储|单位0.01*)
	uiTaper_Cur_Uw:UINT;
	uiTaper_Cur_Rw:UINT;
	uiTaper_Cur_If:UINT;
	uiTaper_Cur_Of:UINT;

(*2022.10.22.162829保存加热相关数据*)
	iPidAlgorithm_Threshold:INT;(*温控PDI介入阀值*)
	iMaxOutValue:INT;(*温控最大调整量*)
	rKp:REAL;
	rKi:REAL;
	rKd:REAL;
	uiCtlCycle_Ms:UINT;(*调整周期*)
(*end2022.10.22.163043*)


	(*2022.11.2.104744 增加了伪随机测试需要的*)
	byRoundTime:BYTE;
	rVolAdditionValue:REAL;(*随机数的值*)
	rAmplitude:REAL;(*伪随机幅值*)

	(*2023.09.18.182952 同步*)
	(*2023.09.08.155701 增加*)
	rWuCompensate_Uw:REAL;(*补偿的转速(R/MIN)|计算的*)
	rDh_Uw:REAL;(*扰动的估计值(M/S)|计算的*)
	rWuCompensate_Act_Uw:REAL;(*补偿的转速(R/MIN)|实际使用的*)


	(*2024.7.11.134605+*)
	rEstiDia_LowPass_Uw:REAL;(*放料低通后卷径值*)
	byKalmanFilterType_Rw:BYTE;(*收料卡尔曼估计的方式值*)
	rWc_LowPass_Diam_Rw:REAL;(*收料卷径截止频率值*)
	rWuCompensate_Rw:REAL;(*补偿的转速(R/MIN)|计算的*)
	rWuCompensate_Act_Rw:REAL;(*补偿的转速(R/MIN)|实际使用的*)
	rKc_Rw:REAL;(*收料补偿值增益|卡尔曼估计方式1 2 3 4 5*)
	rEstiDia_LowPass_Rw:REAL;(*收料低通后卷径值*)
	(*2024.9.10.122313+8bytes*)
	rAntiNotch_Out_If:REAL;(*放牵摆臂过陷波值*)
	rAntiNotch_Out_Uw:REAL;(*放料摆臂过陷波值*)
	abyReserved_11:ARRAY [1..3] OF BYTE;(*2024.7.3.153430 替换了|将来作为别的用途*)
					(*rAntiNotch_Out_If-->rAntiNotch_Out_Uw|11->3*)
					(*rEstiDia_LowPass_Uw-->rEstiDia_LowPass_Rw|36->11*)

	xSaveFineSampleData:BOOL;(*2023.5.29.105143@精采样存储按钮|2023.6.13.090435*)


	(*2024.01.11.153854 增加了一些张力控制器的参数保存*)
	rWc_LowPass_Diam_Uw:REAL;(*放疗卷径截止频率值*)
	byKalmanFilterType_Uw:BYTE;(*放料卡尔曼估计的方式值*)
	rKc_Uw:REAL;(*放料补偿值增益|卡尔曼估计方式1 2 3 4 5*)
(*	rKc_1_Uw:REAL;(*放料补偿值增益|卡尔曼估计方式0*)*)
	abySpace_0:ARRAY [1..4] OF BYTE;(*增加空余部分*)

	(*2024.01.11.153922 任务执行周期数据保存*)
	byCycleTime_PlcPrg		: BYTE;(* 任务消耗时间 *)
	byIntervalTime_PlcPrg	: BYTE;(* 任务间隔 *)

(*	bya_Youla_Uw:BYTE;(*youla控制器的系统参数a@保留0.1|支持最大值25.5*)*)

	abySpace_1:ARRAY [1..1] OF BYTE;(*增加空余部分*)

	byTotalVariableAxisNum: BYTE; (* 轴数量 *)
	dwMask_VariableAxisDetails: DWORD; (* bit0=Axis.1|bit31=Axis.32 *)
END_STRUCT
END_TYPE
{IMPLEMENTATION}
