(*@CES
Name=StGrpParam_UnSave
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=502fdab7-460b-44d8-9c01-902a9f3d20a9
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StGrpParam_UnSave :
STRUCT
	xCutterOnTop_Uw								: BOOL;(* TRUE=放料上裁 *)	
	iDebugVelmpm_AxisA_Uw						: INT;(* A轴调试速度/300m/min *)
	iDebugGirthmm_AxisA_Uw						: INT;(* A轴调试周长/300mm *)
	iDebugVelmpm_AxisB_Uw						: INT;(* B轴调试速度/300m/min *)
	iDebugGirthmm_AxisB_Uw						: INT;(* B轴调试周长/300mm *)	
	xCutterOnTop_Rw								: BOOL;(* TRUE=收料上裁 *)	
	iDebugVelmpm_AxisA_Rw						: INT;(* A轴调试速度/默认300m/min *)
	iDebugGirthmm_AxisA_Rw						: INT;(* A轴调试周长/默认300mm *)
	iDebugVelmpm_AxisB_Rw						: INT;(* B轴调试速度/默认300m/min *)
	iDebugGirthmm_AxisB_Rw						: INT;(* B轴调试周长/默认300mm *)
	
	xMachineRev									: BOOL;(* 机器反转 *)

	iPromptMsg									: INT;
	iAlarm_TypeId								: INT;//报警轴的类型
	iAlarm_UnitId								: INT;//报警轴位置
	iIdGSE										: INT;
	xFlag_Stop									: BOOL;(* 停机标志/第1次从当前速度降到空转速度，抬所有色组胶辊/牵引速度到0时抬牵引胶辊，第2次按下则将色组从空转停到0速度 *)
	xFlag_PreStart								: BOOL;(* 预启动标志/从停机状态按(预)启动置位标志 色组速度达到空转速度清xFlag_PreStart标志,置位xFlag_Ink标志;当xFlag_Print标志有效后 *)
	xFlag_Ink									: BOOL;(* 匀墨标志/>20m/min不能联动 *)
	xFlag_InkAccing								: BOOL;(* 匀墨加速中<指0~10m/min那个加速过程> *)
	xFlag_Tension								: BOOL;(* 张力投入标志/张力投入有效时收放料变频开始起作用/收放料就位后按印刷按钮,牵引压辊合压/xFlag_Print有效时张力投入不处理 *)
	xFlag_TensionDone							: BOOL;(* 张力ok，可以投入印刷 *)
	xFlag_Print									: BOOL;(* 张力拉料标志有效时，按联动或印刷按钮 先压收牵(延时2s)再压放牵 印刷标志/印刷色组根据联动标志按用户指定的压辊顺序逐一延时压胶辊/胶辊压合完毕后才可置该标志有效 *)
	xFlag_Estop									: BOOL;(* 急停标志/和停机一样要减速到0，只不过减速时间是急停时间 *)
	xFlag_AutoAcc								: BOOL;(* 自动加速 *)
	xFlag_AutoDec								: BOOL;(* 自动减速 *)
	xFlag_ManuAcc								: BOOL;(* 手动加速 *)
	xFlag_ManuDec								: BOOL;(* 手动减速 *)
	xFlag_Accing								: BOOL;(* 加速中 *)
	xFlag_Decing								: BOOL;(* 减速中 *)
	xFlag_EStoping								: BOOL;(* 正在急停中 *)
	xFlag_Stoping								: BOOL;(* 停机中 *)
	xFlag_GotoInking							: BOOL;(* 转到匀墨 *)
	xFlag_InPressing							: BOOL;(* 顺序压辊中 *)
	xFlag_RollerPressDone						: BOOL;(* 压辊处理完成 *)
	xFlag_InchRun								: BOOL;(* 至少有1色处于单运行 *)
	xFlag_AllInchRun							: BOOL;(* 整机单运行标志 *)
	xFlag_AllPress								: BOOL;(* 全体合压 *)
	xFlag_AllUnpress							: BOOL;(* 全体离压 *)
	xFlag_RollerPressAtLeast1					: BOOL;(* 至少1色色组合压 *)
	axFlag_PrnLen_Alarm							: ARRAY [1..3] OF BOOL;(* 计长报警标志 *)
	xFlag_LinkageAxisAlarm						: BOOL;(* 至少有1个联动轴发生报警 *)
	xFlag_TensionUnfinished						: BOOL;(* 张力未完成 *)
	xFlag_VelTooHigh							: BOOL;(* 速度过高 *)
	xFlag_PrestartTimeout						: BOOL;(* 预启动超时标志 *)
	xFlag_KeepAlarming							: BOOL;(* 维持报警*)
	xFlag_ArrivedToTargetVel					: BOOL;(* 到达目标速度 *)
	xFlag_FilmAccDecDone						: BOOL;(* 料膜加减速完成 *)
	xSlowStopTenEn								: BOOL;(* 收放料慢速松料使能/TRUE *)
	xIsDebugMode_Machine						: BOOL;(* 机器调试模式 *)
	uiFilmThickNess								: UINT;(* 料膜厚度/20微米 *)
	abyClrPrnLenCount_Rw						: ARRAY [1..3] OF BYTE;
	

	iTimeSec_AccDec_AllTheWay					: INT;(* 全程加减速所需要的秒 *)
	rAccDecTime_ThisTime						: REAL;(* 本次加减速时间/单位:s *)



(*2021.11.5.084313/								/ 用于界面显示标准卷径信息 *)
	alrStdVol_Diam_Axis_Hmi						: ARRAY [1..4] OF LREAL;(* 标准卷径值| *)
	alrStdVol_Volt_Axis_Hmi						: ARRAY [1..4] OF LREAL;(* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
	alrStdVol_Coef_Axis_Hmi						: ARRAY [0..4] OF LREAL;(* 分段系数|2019.1.25.142601|更名A轴|[0]表<=1,[1]表>1&& <=2,[2]表>2&& <=3,[3]表>3&& <=4,[4]表>4 *)

	(* 速度 *)
	rVel_Cur									: REAL;(* 当前速度/单位:m/min *)
	rVel_Cur_HMI								: REAL;
	rVel_Film									: REAL;(* 料膜速度/0 *)
	(*											/放料部分 *)
	iSid_AxisA_Uw								: INT;(* 放料站id/-1表示变频/2021.11.21.192354/hdp *)
	xStationOnline_AxisA_Uw						: BOOL;(* 放料a轴驱动器在线标志/2021.12.4.175524/hdp *)
	xMotRev_AxisA_Uw							: BOOL;(* TRUE.放料运动反向/2021.11.21.192354/hdp *)


	iSid_AxisB_Uw								: INT;(* 放料站id/-1表示变频/2021.11.21.192354/hdp *)
	xStationOnline_AxisB_Uw						: BOOL;(* 放料b轴驱动器在线标志/2021.12.4.175524/hdp *)
	xMotRev_AxisB_Uw							: BOOL;(* TRUE.放料运动反向/2021.11.21.192354/hdp *)

	rAI_Uw										: REAL;(* 放料摆臂模拟量输入/-中位值 *)
	rAI_Act_Uw									: REAL;(* 放料摆臂实际模拟量值/2021.11.18.210606 *)
	rAI_HMI_Uw									: REAL;(* 放料摆臂值显示用 *)
	rAI_DiamMeasure_Uw							: REAL;(* 放料卷径测量输入反馈 *)
	arKpid_Current_Uw							: ARRAY [1..3] OF REAL;(* 当前放料pid监控 *)
	stStTimeSet_DnCut_UpCut_Uw_Hmi				: StTimeSet_DnCut_UpCut;(* 放料端的裁切时间集/界面显示 *)
	arKpid_Current_Rw							: ARRAY [1..3] OF REAL;(* 当前收料pid监控 *)
	stStTimeSet_DnCut_UpCut_Rw_Hmi				: StTimeSet_DnCut_UpCut;(* 收料端的裁切时间集/界面显示 *)
	rVel_PreDrv_Uw								: REAL;(* 放料预驱速度 *)
	xReflectionSensorValid_Uw					: BOOL;(* 放料使用弧面信号/FALSE *)
	xReflectSensorLoss_Uw						: BOOL;(* 放料弧面信号丢失标志/FALSE *)
	rDiam_NewVol_Uw								: REAL;(* 放料新卷卷径 *)
	rTowerThetaCur_Uw							: REAL;(* 翻转架当前弧度/0 *)
	rFilmToTowerRollerDis_Uw				: REAL;(*料膜距离导向辊距离|mm*)
	xFilmTouchRoller_Uw						: BOOL;(*料膜接触到了辊子标志*)

	xSts_PreCutting_Uw							: BOOL;(* 放料预备接料/FALSE *)
	rDebugCurVelmpmAxisA_Uw						: REAL;(* A轴调试当前速度/m/min *)
	rDebugCurVelrpmAxisA_Uw						: REAL;(* A轴调试当前速度/r/min *)
	rDebugCurVelmpmAxisB_Uw						: REAL;(* B轴调试当前速度/m/min *)
	rDebugCurVelrpmAxisB_Uw						: REAL;(* B轴调试当前速度/r/min *)


	rDeltaW_RPMIN_Uw							: REAL;(* 放料翻转架转动时候的转速补偿值/0 *)
	xDebugMode_AbsEnc_Uw						: BOOL;(* 放料绝对值编码器调试模式/FALSE *)
	dwAbsEncSinglePos_Uw						: DWORD;(* 放料单圈位置/0 *)
	dwAbsEncSPos_Cur_Uw							: DWORD;(* 放料当前绝对位置/0 *)

	byEncodeValueWr_Uw							: BYTE;(* 放料编码器值写入/放料:01写入轴定位值/02写入A轴最小径定位值/0 *)
	rAIByAbsEnc_Cur_Uw							: REAL;(* 放料绝对值编码器位置转换的电压值/0 *)
	xCutterOnTopFroDebug_Uw						: BOOL;(* 放料上裁刀标志/用于调试/FALSE *)
	xCurAxisAFroDebug_Uw						: BOOL;(* 放料预驱轴为A轴标志/用于调试/FALSE *)
	xAlarmBell_Uw								: BOOL;(* 放料响铃常输出/用于控制定位写入响铃提示使用/FALSE *)
	xIsDebug_DiaMeasure_Uw						: BOOL;(* 放料卷径测量调试模式标志/FALSE *)
	byIsDebug_DiaMeasureArea_Uw					: BYTE;(* 放料卷径测量调试的时候卷径区域值/1 *)
	xIsDebuging_DiaMeasure_Uw					: BOOL;(* 放料卷径测量调试中/FALSE *)
	xCancelDebuging_DiaMeasure_Uw				: BOOL;(* 放料取消卷径测量调试中/FALSE *)
	byAxisDebugBit_Uw							: BYTE;(* 放料轴调试标志/.0\调试使能.1\A轴调试运行.2\A轴自动加减速.3\A轴运行中.4\B轴调试运行.5\B轴自动加减速.6\B轴运行中/0 *)
	byAxisDebugBit_Uw_2							: BYTE;(* 放料2轴调试标志/.0\调试使能.1\A轴调试运行.2\A轴自动加减速.3\A轴运行中.4\B轴调试运行.5\B轴自动加减速.6\B轴运行中/0 *)
	xEnCodeErr_Uw								: BOOL;(* 放料编码器故障*)
	xEnCodeErr_Rw								: BOOL;(* 收料编码器故障*)	

	rPi_Value_Uw								: REAL;(* 放料pi值/0 *)
	rForwardStep_Uw								: REAL;(* 放料升降速前馈/0 *)
	rTotalPiValue_Uw							: REAL;	
	xAxisAForeward_Uw							: BOOL;(* 放料A轴正转/FALSE *)
	xAxisBForeward_Uw							: BOOL;(* 放料B轴正转/FALSE *)
	rVelRPM_Cur_Uw								: REAL;(* 放料当前转速/0 *)
	rAxisAVelRPM_Cur_Uw							: REAL;(* 放料A轴转速/0/2021.11.18.201209 *)
	rAxisBVelRPM_Cur_Uw							: REAL;(* 放料B轴转速/0/2021.11.18.201209 *)
	xFlag_DiamCalc_ing_Uw						: BOOL;(* 放料卷径计算中 *)
	xFlag_DiamCalc_end_Uw						: BOOL;(* 放料卷径计算完成 *)
	xFlag_DiamMeasure_end_Uw					: BOOL;(* 放料卷径测量完成 *)
	xFlag_PreDrv_ing_Uw							: BOOL;(* 放料预驱中... *)
	xFlag_PreDrv_end_Uw							: BOOL;(* 放料预驱完成  *)
	xFlag_Cut_ing_Uw							: BOOL;
	xFlag_Cut_end_Uw							: BOOL;
	xFlag_VolDiamAlarm_Uw						: BOOL;(* 卷径报警标志 *)
	rAI_DiamMeasure_HMI_Uw						: REAL;(* 兼容摆臂输入类型转换后的卷径测量结果屏显值/2021.11.5.175329 *)
	xAITypeBtn_Uw								: BOOL;(* 输入类型切换按钮/2021.11.18.201254 *)




	(*											/收料部分 *)
	iSid_AxisA_Rw								: INT;(* 收料站id/-1表示变频/2021.11.21.192354/hdp *)
	xStationOnline_AxisA_Rw						: BOOL;(* 收料a轴驱动器在线标志/2021.12.4.175524/hdp *)
	xMotRev_AxisA_Rw							: BOOL;(* TRUE.收料运动反向/2021.11.21.192354/hdp *)

	iSid_AxisB_Rw								: INT;(* 收料站id/-1表示变频/2021.11.21.192354/hdp *)
	xStationOnline_AxisB_Rw						: BOOL;(* 收料b轴驱动器在线标志/2021.12.4.175524/hdp *)
	xMotRev_AxisB_Rw							: BOOL;(* TRUE.收料运动反向/2021.11.21.192354/hdp *)

	rAI_Rw										: REAL;(* 收料摆臂模拟量输入/-中位值 *)
	rAI_Act_Rw									: REAL;(* 收料摆臂实际模拟量值/2021.11.18.201450 *)
	rAI_HMI_Rw									: REAL;(* 收料摆臂值显示用 *)
	rVel_PreDrv_Rw								: REAL;(* 收料预驱速度 *)
	rDiam_NewVol_Rw								: REAL;(* 收料新卷卷径 *)
	rTaper_Rw									: REAL;(* 收料锥度 *)

	xSts_PreCutting_Rw							: BOOL;(* 收料预备接料 *)
	rDebugCurVelmpmAxisA_Rw						: REAL;(* A轴调试当前速度/m/min *)
	rDebugCurVelrpmAxisA_Rw						: REAL;(* A轴调试当前速度/r/min *)

	rDebugCurVelmpmAxisB_Rw						: REAL;(* B轴调试当前速度/m/min *)
	rDebugCurVelrpmAxisB_Rw						: REAL;(* B轴调试当前速度/r/min *)
	xDebugMode_AbsEnc_Rw						: BOOL;(* 收料绝对值编码器调试模式/默认FALSE *)
	dwAbsEncSinglePos_Rw						: DWORD;(* 收料单圈位置/0 *)
	dwAbsEncSPos_Cur_Rw							: DWORD;(* 收料当前绝对位置/0 *)
	byEncodeValueWr_Rw							: BYTE;(* 收料编码器值写入/收料/01写入轴定位值/0 *)
	xCutterOnTopFroDebug_Rw						: BOOL;(* 收料上裁刀标志/用于调试/FALSE *)
	xCurAxisAFroDebug_Rw						: BOOL;(* 收料预驱轴为A轴标志/用于调试/FALSE *)
	x6InchFroDebug_Rw       					: BOOL;(* 收料6寸标志/用于调试/FALSE*)
	xAlarmBell_Rw								: BOOL;(* 收料响铃常输出/用于控制定位写入响铃提示使用/FALSE *)
	byAxisDebugBit_Rw							: BYTE;(* 收料轴调试标志/.0\调试使能.1\A轴调试运行.2\A轴自动加减速.3\A轴运行中.4\B轴调试运行.5\B轴自动加减速.6\B轴运行中/0 *)
	rPi_Value_Rw								: REAL;(* 收料pi值/0 *)
	rForwardStep_Rw								: REAL;(* 收料升降速前馈/0 *)
	rTotalPiValue_Rw							: REAL;	
	xAxisAForeward_Rw							: BOOL;(* 收料A轴正转/FALSE *)
	xAxisBForeward_Rw							: BOOL;(* 收料B轴正转/FALSE *)
	rVelRPM_Cur_Rw								: REAL;(* 收料当前转速/0 *)
	rAxisAVelRPM_Cur_Rw							: REAL;(* 收料A轴转速/0/2021.11.18.201604 *)
	rAxisBVelRPM_Cur_Rw							: REAL;(* 收料B轴转速/0/2021.11.18.201608 *)
	xFlag_6Inch_Rw								: BOOL;(* 收料6寸标志/反之为3寸/FALSE *)
	xFlag_PreDrv_ing_Rw							: BOOL;(* 收料预驱中... *)
	xFlag_PreDrv_end_Rw							: BOOL;(* 收料预驱完成 *)
	xFlag_Cut_ing_Rw							: BOOL;(* 收料裁切中 *)
	xFlag_Cut_end_Rw							: BOOL;(* 收料裁切完成 *)
	xAITypeBtn_Rw								: BOOL;(* 输入类型切换按钮 *)

	(*											/放牵部分 *)
	iSid_If										: INT;(* 放牵站id/-1表示变频 *)
	xStationOnline_If							: BOOL;(* 放牵驱动器在线标志/2021.12.4.175524/hdp *)
	xMotRev_If									: BOOL;(* TRUE.放牵运动反向/2021.11.16.134652/+ *)
(* 2021.12.29.153030/hdp *)

	rAI_If										: REAL;(* 放牵摆臂模拟量输入/-中位值 *)
	rAI_Act_If									: REAL;(* 放牵摆臂实际模拟量值/2021.11.18.201802 *)
	rAI_HMI_If									: REAL;(* 放牵摆臂值显示用 *)
	xInchBtn_If									: BOOL;(* 放牵单运行/FALSE *)
	xRollerSts_If								: BOOL;(* 放牵压辊/FALSE *)
	xRunEn_If									: BOOL;(* 放牵运动使能/0/2021.11.18.201925 *)
	rVel_Cur_If									: REAL;(* 放牵速度/0 *)
	rPi_Value_If								: REAL;(* 放牵pi值/0 *)
	rForwardStep_If								: REAL;(* 放牵升降速前馈/0 *)
	rUsingGirth_If								: REAL;(* 放牵速度控制实际使用的周长/500mm *)
	xInching_If									: BOOL;(* 放牵单运行中/FALSE *)
	xAITypeBtn_if								: BOOL;(* 输入类型切换按钮 *)
	(*											/收牵部分 *)
	iSid_Of										: INT;(* 收牵站id/-1表示变频 *)
	xStationOnline_Of							: BOOL;(* 收牵驱动器在线标志/2021.12.4.175524/hdp *)
	xMotRev_Of									: BOOL;(* TRUE.收牵运动反向/2021.11.16.134652/+ *)


	rAI_Of										: REAL;(* 收牵摆臂模拟量输入/-中位值 *)
	rAI_Act_Of									: REAL;(* 收牵摆臂实际模拟量值/2021.11.18.202051 *)
	rAI_HMI_Of									: REAL;(* 收牵摆臂值显示用 *)
	xInchBtn_Of									: BOOL;(* 收牵单运行/FALSE *)
	xRollerSts_Of								: BOOL;(* 收牵压辊/FALSE *)
	xRunEn_Of									: BOOL;(* 收牵运动使能/0/2021.11.18.202215 *)
	rVel_Cur_Of									: REAL;(* 收牵速度/0 *)
	rPi_Value_Of								: REAL;(* 收牵pi值/0 *)
	rForwardStep_Of								: REAL;(* 收牵升降速前馈/0 *)
	rUsingGirth_Of								: REAL;(* 收牵速度控制实际使用的周长/500mm *)
	xInching_Of									: BOOL;(* 收牵单运行中/FALSE *)
	xAITypeBtn_Of								: BOOL;(* 输入类型切换按钮/2021.11.18.202322 *)
	sCurRecipeName_InUse							: STRING ;(*当前加在的配方*)
	dwSTS_ALL									: DWORD;(* 2021.11.4.174929 *)
(*												/ 整机状态 *)
(*												/bit0.整机套印纵向自动 *)
(*												/bit1.整机套印横向自动 *)
(*												/*)
(*												/bit8.主站的通讯记录到日志中 *)
(*												/*)
(*												/*)
(*												/bit16.主站请置该标志有效/2021.11.6.102700 *)
(*												/bit17.置位标识显示精采样波形 *)
(*												/*)
(*												/*)
(*												/*)
(*												/bit24.dll显示调试信息/2021.12.1.191835/hdp *)
(*												/bit25.精采样显示阀值3 *)
(*												/bit26.精采样显示阀值2 *)
(*												/bit27.精采样显示阀值1 *)
(*												/bit28.精采样显示峰值位置 *)
(*												/bit29.精采样显示最小值位置 *)
(*												/bit30.精采样显示最大值位置 *)
(*												/bit31.精采样显示基线 *)

	xAutoAccDec_Hmi								: BOOL;
	xFlag_IfOf_Ink								: BOOL;(*空转牵引联动标志*)
	xFlag_FastStoping						: BOOL;
	rFinalVelocity							: REAL;(*末速度*)	

	xFlag_AutoMaticCutting_Uw					: BOOL;(*2022.4.25.090246 自动裁切中标志*)
(*	abyReserved1							: ARRAY [1..4] OF BYTE;*)
	xFlag_AutoMaticCutting_rw					: BOOL;(*2022.4.25.090246 自动裁切中标志*)
	rAutoMaticCuttingLenth_CurMode_uw			: REAL;(*放料自动裁切当前模式下的计米值|2022.4.26.101850*)
	rActRemainFilmLenth_Uw						: REAL;(*实际剩余长度|mm-测量值*)
	rAutoMaticCuttingLenth_CurMode_Rw			: REAL;(*收料自动裁切当前模式下的计米值|2022.4.26.101850*)

	
	xCurAxisDia_Uw_Wr							: BOOL;(*写入当前轴的卷径|2022.4.9.230449*)
	xCurAxisDia_Rw_Wr							: BOOL;(*写入当前轴的卷径|2022.4.9.230449*)
	rTaper_Cur_Uw								: REAL;(*锥度当前|放料|*)
	rTaper_Cur_If								: REAL;(*锥度当前|放牵|*)
	rTaper_Cur_Of								: REAL;(*锥度当前|收牵|*)	

	rTaperValueBegin_Hmi_Uw						: REAL;(*放料起始锥度显示值|根据单位切换*)
	rTaperValueEnd_Hmi_Uw						: REAL;(*放料结束锥度显示值|根据单位切换*)
	rTaperValueBegin_Hmi_Rw						: REAL;(*收料起始锥度显示值|根据单位切换*)
	rTaperValueEnd_Hmi_Rw						: REAL;(*收料结束锥度显示值|根据单位切换*)
	rTaperValueBegin_Hmi_If						: REAL;(*放牵起始锥度显示值|根据单位切换*)
	rTaperValueEnd_Hmi_If						: REAL;(*放牵结束锥度显示值|根据单位切换*)
	rTaperValueBegin_Hmi_Of						: REAL;(*收牵起始锥度显示值|根据单位切换*)
	rTaperValueEnd_Hmi_Of						: REAL;(*收牵结束锥度显示值|根据单位切换*)

	byTaperUnitConfirm_Uw						: BYTE;(*放料锥度单位确认|.0 N确认|.1 Mpa确认*)
	byTaperUnitConfirm_Rw						: BYTE;(*收料锥度单位确认|.0 N确认|.1 Mpa确认*)
	byTaperUnitConfirm_If						: BYTE;(*放牵锥度单位确认|.0 N确认|.1 Mpa确认*)
	byTaperUnitConfirm_Of						: BYTE;(*收牵锥度单位确认|.0 N确认|.1 Mpa确认*)
	(*2021.7.29.105859 增加|16BYTES*)
	rTaperValueCur_Hmi_If						: REAL;(*放牵锥度当前值|根据单位切换*)
	rTaperValueCur_Hmi_of						: REAL;(*收牵锥度当前值|根据单位切换*)
	rTaperValueCur_Hmi_Uw						: REAL;(*放料锥度当前值|根据单位切换*)
	rTaperValueCur_Hmi_Rw						: REAL;(*收料锥度当前值|根据单位切换*)
	rValue_DiaMeasure							: REAL;(*卷径测量采样值*)	
	rVolt_CalcDiam_Used_Watch					: REAL;(*计算卷径的电压值*)			
	rAO_Inverter_Uw_AxisA						: REAL;(*放料A轴输出|2017-08-12 17:25:33*)
	rAO_Inverter_Uw_AxisB						: REAL;(*放料B轴输出|2017-08-12 17:25:33*)
	rAO_Inverter_Rw_AxisA						: REAL;(*收料A轴输出|2017-08-12 17:25:33*)
	rAO_Inverter_Rw_AxisB						: REAL;(*收料B轴输出|2017-08-12 17:25:33*)

	
	xBtn_HorzPreRegister_Repeat				: BOOL;(*横向重复值按钮*)
	xBtn_HorzPreRegister_Setup				: BOOL;(*横向设定值按钮*)
	xSts_HorzPreRegister					: BOOL;(*横向预套准状态*)
	xMode_HorzPreRegister					: BOOL;(*横向预套准方式：FALSE为设定值;TRUE是重复值*)
	xFlag_HorzPreRegister_All_end			: BOOL;(*横向预套准全部完成*)
	xFlag_Home								: BOOL;
	xFlag_Home_ing							: BOOL;
	xFlag_Home_end							: BOOL;
	xFlag_ConfirmPreRegHomePos				: BOOL;(*2017-09-13 12:51:52| 确认预套准基准点*)
	xFlag_ConfirmPreRegHomePos_ing			: BOOL;(*确认预套准基准点-ing*)
	xFlag_ConfirmPreRegHomePos_end			: BOOL;(*确认预套准基准点-end*)
	xFlag_PreRegister						: BOOL;
	xFlag_PreRegister_ing					: BOOL;
	xFlag_PreRegister_end					: BOOL;
	xFlag_PhaseRestore						: BOOL;(*相位恢复*)
	xFlag_PhaseRestore_ing					: BOOL;(*相位恢复-ing*)
	xFlag_PhaseRestore_end					: BOOL;(*相位恢复-end*)
	xBtn_Home								: BOOL;
	xBtn_ConfirmPreRegHomePos				: BOOL;
	xBtn_PreRegister						: BOOL;
	xBtn_PhaseSave							: BOOL;(*相位保存*)
	xBtn_PhaseRestore						: BOOL;(*相位恢复*)	
	xFlag_MotionParamInitialized				: BOOL;(*加速度初始化完成-计算加速度目标速度加加速度*)
	xFlag_AccDecStop							: BOOL;
	//下面时牵引收放料中心辊的离线报警位置偏差报警标志
	xNetOffline_CENTRAL:BOOL;
	xAxisAlarm_CENTRAL:BOOL;
	xPosDeviationAlarm_CENTRAL:BOOL;
	xNetOffline_CENTRAL2:BOOL;
	xAxisAlarm_CENTRAL2:BOOL;
	xPosDeviationAlarm_CENTRAL2:BOOL;
	xNetOffline_IF:BOOL;
	xAxisAlarm_IF:BOOL;
	xPosDeviationAlarm_IF:BOOL;
	xNetOffline_OF:BOOL;
	xAxisAlarm_OF:BOOL;
	xPosDeviationAlarm_OF:BOOL;
	xNetOffline_UW_A:BOOL;
	xAxisAlarm_UW_A:BOOL;
	xPosDeviationAlarm_UW_A:BOOL;
	xNetOffline_UW_B:BOOL;
	xAxisAlarm_UW_B:BOOL;
	xPosDeviationAlarm_UW_B:BOOL;
	xNetOffline_RW_A:BOOL;
	xAxisAlarm_RW_A:BOOL;
	xPosDeviationAlarm_RW_A:BOOL;
	xNetOffline_RW_B:BOOL;
	xAxisAlarm_RW_B:BOOL;
	xPosDeviationAlarm_RW_B:BOOL;
	//2023.8.18.143718具体报警信息
	dwAlarmDetail_CENTRAL:DWORD;//轴报警信息-ZHONGX
	dwAlarmDetail_CENTRAL2:DWORD;//轴报警信息-ZHONGX
	
	dwAlarmDetail_IF:DWORD;//轴报警信息-放牵
	dwAlarmDetail_OF:DWORD;//轴报警信息-收前
	dwAlarmDetail_UW_A:DWORD;//轴报警信息-放A
	dwAlarmDetail_UW_B:DWORD;//轴报警信息-放B
	dwAlarmDetail_RW_A:DWORD;//轴报警信息-收A
	dwAlarmDetail_RW_B:DWORD;//轴报警信息-收B

	xValid_CentralDrum							: BOOL;(* 中心滚筒有效标志 *)
	iSid_CentralDrum							: INT;(* 中心滚筒站id/初始-1/有效性通过查表确定 *)
	xStationOnline_CentralDrum					: BOOL;(* 站在线标志-中心滚筒/读取站号以后实时更新 *)
	xMotRev_CentralDrum							: BOOL;(* 中心滚筒电机反向运动 *)
	rAxisVel_CentralDrum						: REAL;(* 中心滚筒轴速度 *)
	xPrintInching: BOOL;//整机点动
	rVel_Inching_Print: REAL;//点动速度
	xTapPosition_Breaking					: BOOL;(*断料档位|*)
	xTapPosition_UniformInk					: BOOL;(*匀墨档位|*)
	xTapPosition_Printing					: BOOL;(*印刷档位|*)
	wEn_UwRw_IfOf_Center					: WORD;(*牵引收放料中心辊的使能标志*)
											(*bit0:放牵*)	
											(*bit1:收牵*)	
											(*bit2:放A*)	
											(*bit3:放B*)	
											(*bit4:收A*)	
											(*bit5:收B*)	
											(*bit6:中心辊1*)
											(*bit7:中心辊2*)	
	aiMotionStep_AllStation					: ARRAY [1..MAX_STATION_NUM] OF INT;
	byBtn_ConfirmMedian						: BYTE;
	xUwVolDiamMeasurementFailed								: BIT;(*放料卷径检测失败*)
	xBtnClrAlarmInf											: BIT;(*报警清楚按钮*)

	byPseudoRandomId						: BYTE:=1;(*=0 放牵|=1 放料|=2 收料 |=3 收牵*)
	xPseudoRandomEn							: BOOL;(*伪随机使能*)
	aiTestPseudoRandom_Kp					: ARRAY [1..3] OF INT;(*伪随机测试Kp*)
	aiTestPseudoRandom_Kd					: ARRAY [1..3] OF INT;(*伪随机测试Kd*)
	xPseudoRandomTsting						: BOOL;(*伪随机测试中*)
	xDebug_Enc_Uw							: BOOL;(*放料调试*)
	xDebug_Enc_Rw							: BOOL;(*收料调试*)
	wAxisDebug_UwRw							: WORD;(*轴调试标志|.0\放料调试使能.1\放料A轴调试运行.2\放料A轴自动加减速.3\放料A轴运行中.4\放料B轴调试运行.5\放料B轴自动加减速.6\放料B轴运行中
									  .8\收料调试使能.9\收料A轴调试运行.10\收料A轴自动加减速.11\收料A轴运行中.12\收料B轴调试运行.13\收料B轴自动加减速.14\收料B轴运行中*)
	xFlag_SafeTyGratingProctec_Uw			: BOOL;(*放料光栅保护标志*)
	xFlag_SafeTyGratingProctec_Rw			: BOOL;(*放料光栅保护标志*)

	bySetTestPid_IfOf:BYTE;(*设置伪随机测试的pid值*)
	bySetTestPid_Uw:BYTE;(*设置伪随机测试的pid值*)
	bySetTestPid_Rw:BYTE;(*设置伪随机测试的pid值*)	
	bySetTestPid_If:BYTE;(*设置伪随机测试的pid值*)
	bySetTestPid_Of:BYTE;(*设置伪随机测试的pid值*)
	xLinkage_IfOf_Ink: BOOL;
	xFlag_Cut_end_Uw_UseInOtherPrg: BOOL;
	xFlag_Cut_ing_Uw_UseInOtherPrg: BOOL;
	xFlag_Cut_end_Rw_UseInOtherPrg: BOOL;
	xConfirmRad0: BOOL;(*0弧度确认*)
	xFlag_Follow_1U_V_UwCut		: BOOL;(*裁切跟一色标志*)
	xKeepAlarm_NoMaterial			: BOOL;(*没料持续报警*)
	xKnob_6Inch_Rw				: BOOL;(*界面收料6吋切换开关*)
	xWillAutoMaticPreCut_Uw		: BOOL;(**)
	axMeasure_StdVol						: ARRAY [1..4] OF BOOL;(*卷径测量按钮*)	
	rPseudoRandomRoundAmplitude_Cur		: REAL;
	
	rAxisAFreq_Uw						: REAL;(*放料A频率监控*)
	rAxisBFreq_Uw						: REAL;(*放料A频率监控*)
	rAxisAFreq_Rw						: REAL;(*放料A频率监控*)
	rAxisBFreq_Rw						: REAL;(*放料A频率监控*)
	
	xAllowSwitchCutter_Uw				: BOOL;(*收放料允许切换上下裁刀标志@|./0 放料可以|./1 收料可以*)
	xAllowSwitchCutter_Rw				: BOOL;(*收放料允许切换上下裁刀标志@|./0 放料可以|./1 收料可以*)
	xAxisALocation_Use_Uw					: BOOL;
	xAxisBLocation_Use_Uw					: BOOL;
	xAxisALocation_Use_Rw					: BOOL;
	xAxisBLocation_Use_Rw					: BOOL;

	rWuCompensate_Uw:REAL;(*补偿的转速(R/MIN)|计算的*)
	rWuCompensate_Act_Uw:REAL;(*补偿的转速(R/MIN)|实际使用的*)	
	
	rWuCompensate_Rw:REAL;(*补偿的转速(R/MIN)|计算的*)
	rWuCompensate_Act_Rw:REAL;(*补偿的转速(R/MIN)|实际使用的*)	
	rTaperMax_Uw: REAL;
	rTaperMax_Rw: REAL;
	rTaperMax_If: REAL;
	rTaperMax_Of: REAL;

	xGirthCalFinish_If: BOOL;
	xGirthCalFinish_Of: BOOL;
	(*扰动输出的控制输入参数@2024.12.3.102359*)	
	xEn_Disturbance_If: BOOL;(*扰动使能*)
	rFreq_Disturbance_If: REAL:=1;(*扰动频率@hz*)
	rAmplitude_Disturbance_If:REAL:=1;(*扰动幅值*)
	uiTotalTime_Disturbance_If: UINT:=0;(*扰动输出的总时间|=0 代表一直输出@s*)
	xOuting_sin_If:BOOL:=FALSE;(*输出标志*)
	rResult_sin_If: REAL:=0;
	xEn_Disturbance_Of: BOOL;(*扰动使能*)
	rFreq_Disturbance_Of: REAL:=1;(*扰动频率@hz*)
	rAmplitude_Disturbance_Of:REAL:=1;(*扰动幅值*)
	uiTotalTime_Disturbance_Of: UINT:=0;(*扰动输出的总时间|=0 代表一直输出@s*)
	xOuting_sin_Of:BOOL:=FALSE;(*输出标志*)
	rResult_sin_Of: REAL:=0;
	rVelRPM_Cur_If: REAL;(*放牵转速*)
	rVelRPM_Cur_Of: REAL;(*收牵转速*)
	byPseudoRandomRoundTimes_Cur: BYTE;(*伪随机测试当前次数*)
	xFlagFollow1U_AccDecing: BOOL;(*加减速跟踪第一色标志*)
	byGrpArcAxisNum			: BYTE;
	abyGrpArcAxisList: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	abyGrpFollowArcIdList: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	abyGrpArcIdList	: ARRAY [1..MAX_UNIT_NUM] OF INT;
	xEnaTestARC_Ink							: BOOL;(*空转测试使能*)	
	rAcceleration_Max				: REAL;(*最大加速度*)
	rAcceleration_Cur				: REAL;(*当前加速度*)
	
	byGrpAxisNum_Pu					: BYTE;
	abyGrpAxisList					: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	iAxisId_StepTest_V						: INT;(*阶跃测试的轴id*)
	iMicron_StepTest1_V						: INT;(*阶跃测试的数值|单位:um*)
	iMicron_StepTest2_V						: INT;(*阶跃测试的数值|单位:um*)
	iInterval_StepTest12					: INT;(*2此阶跃的间隔|幅*)
	
	xSwitch_AutoAdjust_V_Grp				: BIT;(*整机手自动*)
	xSwitch_AutoAdjust_H_Grp				: BIT;(*整机手自动*)
	xLinkage_If								: BIT;(*放牵联动*)
	xLinkage_Of								: BIT;(*收牵联动*)
	xMoveEnable_Motor_If					: BIT;
	xMoveEnable_Motor_Of					: BIT;
	rMainVel_Uw : REAL; 
	rMainVel_Rw : REAL;
	
	
	(*2025.8.13.103441||新增工艺参数*)
	lrAxisScraperVel:LREAL;
	rHz_UnitScraper_CurrWR: REAL;(*刮刀速度写入变频值-485变频*)	
	rHz_UnitInkRoller_CurrWR: REAL;
	
	(*2025.08.13.145324 || 至少联动一色标志*)
	xFlag_LinkageAtleast1Axis					: BOOL;
	(*新增变量-开始|wang.nt|2025.08.13.144038*)
	xWillAutoMaticPreCut_Rw : BOOL;(*收料即将自动接料*)
	xFlag_HotBlowerStopDelay : BOOL;(*热风延时关闭中*)
	xInverterAlarmCurAxis_Uw				: BOOL;(*放料变频器当前轴报警*)
	xInverterAlarmCurAxis_Rw				: BOOL;(*收料变频器当前轴报警*)
	xInverterAlarmPreAxis_Uw				: BOOL;(*放料变频器预驱轴报警*)
	xInverterAlarmPreAxis_Rw				: BOOL;(*收料变频器预驱轴报警*)
	xFlag_FastStopBtnDn:BOOL;(*快停被按下|2022.4.13.155130*)
	xEstopBtnDne:BOOL;(*急停被按下*)
	xTowerInvAlarm_Uw:BOOL;
	xTowerInvAlarm_Rw:BOOL;
	xInverterAlarm_If				: BOOL;(*放牵变频器报警*)
	xInverterAlarm_Of				: BOOL;(*收牵变频器报警*)
	(*新增变量-结束|wang.nt|2025.08.13.144054*)	
	
	xBtn_StepTest_V							: BOOL;(*纵向阶跃*)
	
(*2025.8.20.200913*)		
	xBtn_ExhAir_Reset						: BIT;(*排风复位按钮*)
	xBtn_CopyExhFreq_1U_To_Other			: BIT;(*复制1U排风频率到所有色*)
	xBtn_AllExhAir_Off						: BIT;(*全体排风关*)
	xBtn_AllExhAir_On						: BIT;(*全体排风开*)
	xBtn_Reset_TempCtlBlock					: BIT;(*复位温控模块按钮*)
	xBtn_CopySV_1U_To_Other					: BIT;(*复制1U排风频率到所有色*)
	xBtn_AllHeating_Elc						: BIT;(*全体电加热*)
	xBtn_AllHeating_I						: BIT;(*全体加热I当*)
	xBtn_AllHeating_II		  				: BIT;(*全体加热II当*)
	xBtn_AllHeating_III					    : BIT;(*全体加热III当*)
	xBtn_AllHeating_Close					: BIT;(*全体加热关*)
	xBtn_AllHeating_Water	 			    : BIT;	(*全体水加热*)	
	(*预套准相关变量|wang.nt|2025.08.21.171436*)
	xFlag_PhaseSave:BOOL;(*固定相位保存相关|2024.9.6.213011*)
	xFlag_PhaseSave_end:BOOL;
	xFlag_PhaseRead:BOOL;
	xFlag_PhaseRead_end:BOOL;
	xBtn_SaveAllData:BOOL;(*全部参数保存|不管有没有都写入一次当前值*)	
	xBtn_SaveProtionData:BOOL;(*部分参数保存|没有相位值的色组*)
	xBtn_SaveCancel:BOOL;(*界面关闭*)
	xFlag_AxisInitPhaseHmiDis:BOOL;(*轴的初始相位操作界面显示*)
	byFirstValidAxisId						: BYTE;(*2018.9.9.203836\首个有效轴|*)
	
	(*2025.9.25.110708从这开始是润新测试完后增加内容*)
	iStationId_Alarm: INT;(*报警时给这个变量赋值-无报警时赋值255吧*)
	abyAxisList_CoatingPrn					: ARRAY [1..MAX_UNIT_NUM] OF BYTE;(*涂布轴列表|*)
	byAxisNum_CoatingPrn					: BYTE;
	xInching_Uw: BOOL;
	xInching_Rw: BOOL;
	xArcErrInRange: BOOL;
	rAIMax_Uw: REAL;
	rAIMin_Uw: REAL;
	rAIMax_Rw: REAL;
	rAIMin_Rw: REAL;
	rAIMin_If: REAL;
	rAIMax_If: REAL;
	rAIMin_Of: REAL;
	rAIMax_Of: REAL;	

(*2025.11.5.154018*)
	xBtn_PreRegisterAxisId_Manu					: BIT;(*预套准的轴号手动确定@不考虑联动开关*)	
	xBtn_PreRegisterCorrConfirm: BIT;//预套准自动修正按钮

	//xRsv_Flag4										: BIT;
	//xRsv_Flag5										: BIT;
	//xRsv_Flag6										: BIT;
	//xRsv_Flag7										: BIT;
	//再取一个BYTE用做BIT||4-1=3
	//2025.10.20.153729||bit0和bit1用作横向预套准按钮	
//2025.12.31.111752增加变量，数据结构变化
	rCur_PressureValue	: REAL;//牵引压力传感器当前值
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
