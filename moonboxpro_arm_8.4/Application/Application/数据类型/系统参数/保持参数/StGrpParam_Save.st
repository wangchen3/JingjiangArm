(*@CES
Name=StGrpParam_Save
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=f58940ec-a17f-4bea-a7e2-f076956df0df
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StGrpParam_Save :
STRUCT
	rGirth_BottomRoller							: REAL;(* 底辊周长/整机设置状态 *)
	uiNum_BottomRoller							: UINT;(* 底辊减速比分子/整机设置状态 *)
	uiDen_BottomRoller							: UINT;(* 底辊减速比分母/整机设置状态 *)

	rGirth_PrnRoller							: REAL;(* 印版周长/整机设置状态 *)
	uiNum_PrnRoller								: UINT;(* 版辊减速比分子/整机设置状态 *)
	uiDen_PrnRoller								: UINT;(* 版辊减速比分母/整机设置状态 *)

	rGirth_NetRoller							: REAL;(* 网辊周长/整机设置状态 *)
	uiNum_NetRoller								: UINT;(* 网辊减速比分子/整机设置状态 *)
	uiDen_NetRoller								: UINT;(* 网辊减速比分母/整机设置状态 *)
	
	rGirth_StrRoller							: REAL;(* 张带辊周长 *)
	uiNum_StrRoller								: UINT;(* 张带辊减速比分子/整机设置状态 *)
	uiDen_StrRoller								: UINT;(* 张带辊减速比分母/整机设置状态 *)

	rScrewPitch_PrnRoller_Pressure				: REAL;(* 版辊压力架丝杆节距/整机设置状态/单位mm *)
	uiNum_PrnRoller_Pressure					: UINT;(* 版辊压力电机减速比分子/整机设置状态 *)
	uiDen_PrnRoller_Pressure					: UINT;(* 版辊压力电机减速比分母/整机设置状态 *)

	rScrewPitch_NetRoller_Pressure				: REAL;(* 网辊压力架丝杆节距/整机设置状态/单位mm *)
	uiNum_NetRoller_Pressure					: UINT;(* 网辊压力电机减速比分子/整机设置状态 *)
	uiDen_NetRoller_Pressure					: UINT;(* 网辊压力电机减速比分母/整机设置状态 *)
	
	rScrewPitch_StrRoller_Pressure				: REAL;(* 张带辊压力架丝杆节距/整机设置状态/单位mm *)
	uiNum_StrRoller_Pressure					: UINT;(* 张带辊压力电机减速比分子/整机设置状态 *)
	uiDen_StrRoller_Pressure					: UINT;(* 张带辊压力电机减速比分母/整机设置状态 *)

	rGirth_CenterRoller							: REAL;(* 中心辊周长/整机设置状态 *)
	uiNum_CenterRoller							: UINT;(* 中心辊减速比分子/整机设置状态 *)
	uiDen_CenterRoller							: UINT;(* 中心辊减速比分母/整机设置状态 *)

	rScrewPitch_Horz							: REAL;(* 横向架丝杆节距/整机设置状态/单位mm *)
	uiNum_Horz									: UINT;(* 横向电机减速比分子/整机设置状态 *)
	uiDen_Horz									: UINT;(* 横向电机减速比分母/整机设置状态 *)
	
	rScrewPitch_PhotoCell						: REAL;(* 光电眼架丝杆节距/整机设置状态/单位mm *)
	uiNum_PhotoCell								: UINT;(* 光电眼电机减速比分子/整机设置状态 *)
	uiDen_PhotoCell								: UINT;(* 光电眼电机减速比分母/整机设置状态 *)

	wAI_polarity								: WORD;(* 模拟量输入极性配置 *)
		(*
		/bit0=1放料模拟量输入反向
		/bit1=1收料模拟量输入反向
		/bit2=1放牵模拟量输入反向
		/bit3=1收牵模拟量输入反向
		/bit4~bit15(保留)
		/ *)
	lrPrnLen_AmountTo							: LREAL;(* 总计印刷长度/单位:m *)
	rPrintLengthCoef							: REAL;(*印刷计长系数|*)	
	alrPrnLen									: ARRAY [1..3] OF LREAL;(* A轴印长/B轴印长/总印长 *)
	alrPrnLen_Alr								: ARRAY [1..3] OF LREAL;(* 印长报警值/相对应于alrPrnLen *)
	iDelayMsec_RollerPress						: INT;(* 压辊延时/单位:ms *)

	wUwRwAxisProf								: WORD;
(*												/放料&收料轴描述 *)
(*												/bit0=TRUE,放料当前轴A轴 *)
(*												/bit1=TRUE,收料当前轴A轴 *)

	iMarkTypeId									: INT;(* 色标形式 *)
	iMarkArrangeMode							: INT;(* 标记排列形式 *)
	byTriMark_SideC								: BYTE;(* 梯形色标直边(c边) *)
	byTriMark_SideB								: BYTE;(* 梯形色标底边(b边) *)
	bySysSamplePrecision						: BYTE;(*系统采样精度			*)
	byArcFineSampleType							: BYTE;(*系统采样方式*)

	
	(* 时间设定 *)
	iTime_Stop									: INT;(* 停机时间/单位:s *)
	iTime_Estop									: INT;(* 急停时间/单位:s *)
	iTime_AutoAcc							: INT;(* 自动加减速时间/单位:s *)
	iTime_ManuAcc							: INT;(* 手动加减速时间/单位:s *)
	iTime_S										: INT;(* S加减速时间/单位:s *)
	iTime_PreDrvAcc_Uw								: INT;(* 预驱加速时间/10s *)
	iTime_PreDrvDec_Uw							: INT;(* 预驱减速时间/2s *)
	iTime_PreDrvAcc_Rw								: INT;(* 预驱加速时间/10s *)
	iTime_PreDrvDec_Rw							: INT;(* 预驱减速时间/2s *)
	iTime_FilmAcc								: INT;(* 料膜加速时间/8S *)
	iTime_FilmDec								: INT;(* 料膜减速时间/2S *)
	iTime_AutoDec							: INT;(*自动加减速时间|单位:s|*)
	iTime_ManuDec							: INT;(*手动加减速时间|单位:s|*)
	iTime_FastStop							: INT;(*快停时间*)
	iTime_S_End								: INT;(*S减加速时间*)
	byAutoAccDecCurve					: BYTE;(*自动加减速曲线选择|默认 按照最大直线加速度进行s处理-
																		 1：按照直线加速时间进行s处理
																		 2：按照直线加速时间全程s处理-*)
	
	rVel_Max									: REAL;(* 设备最大速度/单位:m/min *)
	rVel_Tar									: REAL;(* 目标速度/单位:m/min *)
	arVel_Usr									: ARRAY [1..3] OF REAL;(* 用户速度1,2,3/单位:m/min *)
	rVel_Ink									: REAL;(* 匀墨速度/单位:m/min *)
	rVel_Inch									: REAL;(* 单运行速度/单位:m/min *)
	rVel_AutoAdj								: REAL;(* 自动修正速度/单位:m/min *)
	rVel_ManuAdj_Corse							: REAL;(* 手动粗调速度/单位:m/min *)
	rVel_ManuAdj_Fine							: REAL;(* 手动细调速度/单位:m/min *)
	rVel_RapidAdj								: REAL;(* 快速调版速度/单位:m/min *)
	rVel_HorzdAdj								: REAL;(* 横向调版速度/单位:mm/s *)

	rDiamAlarm_Uw								: REAL;(* 放料报警卷径 *)
	rGirth_AxiaA_Uw								: REAL;(* 放料A轴周长 *)
	rGirth_AxiaB_Uw								: REAL;(* 放料B轴周长 *)
	arKpid_Uw									: ARRAY [1..3] OF REAL;(* 放料pid比例 *)
	rGirth_Uw									: REAL;(* 放料周长 *)
	uiNum_Uw									: UINT;(* 放料减速比-电机转数 *)
	uiDen_Uw									: UINT;(* 放料减速比-负载转数 *)
	rTaper_Uw									: REAL;(* 放料锥度 *)
	rAI_med_Uw									: REAL;(* 放料摆臂模拟量中位 *)
	byDiamMeasureTypeId_Uw						: BYTE;(* 放料卷径测量类型 *)
	byAIType_Uw									: BYTE;(* 放料摆臂类型/初始值0 *)
	byCoef_stiffen_Uw							: BYTE;(* 放料拉料系数|10 *)

	adwEnc_AxisALocation_Uw						: ARRAY [0..1] OF DWORD;(* 放料A轴定位位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)
	adwEnc_AxisALocation_MinDiam_Uw				: ARRAY [0..1] OF DWORD;(* 放料A轴最小径位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)
	adwEnc_AxisBLocation_Uw						: ARRAY [0..1] OF DWORD;(* 放料B轴定位位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)
	adwEnc_AxisBLocation_MinDiam_Uw				: ARRAY [0..1] OF DWORD;(* 放料B轴最小径位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)
	iRatedRpm_Uw								: INT;(* 放料电机额定转速/1500r/min *)
	iRatedFreq_Uw								: INT;(* 放料电机额定频率/50HZ *)
	iUpperFreq_Uw								: INT;(* 放料电机上限频率/100HZ *)
	xDiamMeasureAutomatic_Uw					: BOOL;(* 放料卷径自动测量标志/FALSE *)
	xCutUseReflectionSensor_Uw					: BOOL;(* 放料采用弧面检测方式标志,TRUE标识有效/FALSE *)
	xMultAxisParaEn_Uw							: BOOL;(* 放料AB轴单独参数-卷径测量/FALSE *)
	xFlag_CCW_AfterCutted_Uw					: BOOL;(* 裁切后放料轴反转/TRUE *)
	iPreRevLenth_MM_Cutted_Uw					: INT;(* 放料轴裁切反转距离/初始值1000 *)
	iPreRevVel_RPM_Cutted_Uw					: INT;(* 放料轴裁切反转转速/初始值80 *)
	xPreCutOneBtn_Uw							: BOOL;(* 放料接料准备使用单输入标志/FALSE *)
	rCoefCut_FilmVolPerimeter_Uw				: REAL;(* 放料裁切系数/1.5 *)
	xDiaEstEn_Uw								: BOOL;(* 放料卷径估计使能/FALSE *)
	rEstiDia_Uw									: REAL;(* 预估卷径值/300mm *)
	rEstiThickness_Uw							: REAL;(* 预估料膜厚度值/0.02mm *)
	byDelayTime_DiaCompensateWhenCutDne_Uw		: BYTE;(* 裁切后卷径补偿介入时间/10s *)
	uiPiDelay_Uw								: UINT;(* 裁切后放料PI延迟时间/1000ms *)


	xUseRadCompensate_Uw						: BOOL;(* 放料翻转架补偿使能标志/FALSE *)
	xConfirmRad0_Uw								: BOOL;(* 放料确认弧度0标志/FALSE *)
	dwAxisAabsPos_0Rad_Uw						: DWORD;(* 放料A轴翻转架0度的绝对位置/翻转架中心作为坐标系0点/0 *)
	dwAxisBabsPos_0Rad_Uw						: DWORD;(* 放料B轴翻转架0度的绝对位置/翻转架中心作为坐标系0点/0 *)
	(*											/ALTMA的放料架结构 *)
	rDiam_Tower_Uw								: REAL;(* 放料翻转架的直径/1000mm *)
	rDiam_NextRoller_Uw							: REAL;(* 放料翻转架下个辊的直径/100mm *)
	rXPos_NextRoller_Uw							: REAL;(* 放料翻转架下个辊的X位置/232.5mm/翻转架中心作为坐标系0点 *)
	rYPos_NextRoller_Uw							: REAL;(* 放料翻转架下个辊的Y位置/1052mm/翻转架中心作为坐标系0点 *)
	xTowerDir_Uw								: BOOL;(* 翻转架和绝对位置方向控制/FALSE *)
	(*2022.5.17.121911 放料翻转架补偿算法优化后增加的变量|13bytes|2023.8.17.161013*)
	rDiam_DeflectorRollPos_Uw				: REAL;(*翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	rDiam_DeflectorRoller_Uw				: REAL;(*翻料架上导向辊的直径|mm*)
	xMultAxisPosEn_Uw							: BOOL;(* 放料定位位置单独参数-绝对值编码器/FALSE *)
	byInitialSpd_Stiffen_Uw						: BYTE;(* 放料拉料初始速度/10r/min *)
	(*											/ 2021.11.5.174244 *)
	rFilmLen_UnwindToPU1						: REAL;(*放料裁切点到1U的料膜距离|单位:mm|*)
	rFilmLen_NotAdjFront						: REAL;(*裁切点前不调整的料长|单位:mm|*)
	rFilmLen_NotAdjBack							: REAL;(*裁切点后不调整的料长|单位:mm|*)
	rFilmLen_BetweenImpressPoints				: REAL;(*两个压印点之间的料长|单位:mm|*)

	rDiamAlarm_Rw								: REAL;(* 收料报警卷径 *)
	rGirth_AxiaA_Rw								: REAL;(* 收料A轴周长 *)
	rGirth_AxiaB_Rw								: REAL;(* 收料B轴周长 *)
	arKpid_Rw									: ARRAY [1..3] OF REAL;(* 放料pid比例 *)
	rGirth_Rw									: REAL;(* 收料周长 *)
	uiNum_Rw									: UINT;(* 收料减速比-电机转数 *)
	uiDen_Rw									: UINT;(* 收料减速比-负载转数 *)	
	rAI_med_Rw									: REAL;(* 收料摆臂模拟量中位 *)
	byAIType_Rw									: BYTE;(* 收料摆臂类型/初始值0 *)
	byCoef_stiffen_Rw							: BYTE;(* 收料拉料系数|10 *)
	xRsv										: BOOL;
	adwEnc_AxisALocation_Rw						: ARRAY [0..1,0..1] OF DWORD;(* 收料A轴定位位置/一维索引通过BOOL_TO_INT(xCutterOnTop_Rw)/二维索引[0]表示3吋纸芯,[1]表示6吋纸芯 *)
	adwEnc_AxisBLocation_Rw						: ARRAY [0..1,0..1] OF DWORD;(* 收料B轴定位位置/一维索引通过BOOL_TO_INT(xCutterOnTop_Rw)/二维索引[0]表示3吋纸芯,[1]表示6吋纸芯 *)
	rTaper_begin_Rw								: REAL;(* 锥度起始值-收料 *)
	rTaper_end_Rw								: REAL;(* 锥度结束值-收料 *)
	rDiam_taper_begin_Rw						: REAL;(* 锥度起始直径-收料 *)
	rDiam_taper_end_Rw							: REAL;(* 锥度结束直径-收料 *)
	iRatedRpm_Rw								: INT;(* 收料电机额定转速/默认1500 *)
	iRatedFreq_Rw								: INT;(* 收料电机额定频率/默认50 *)
	iUpperFreq_Rw								: INT;(* 收料电机上限频率/默认100 *)
	rGirth_3inch_Rw								: REAL;(* 收料3寸周长/默认300 *)
	rGirth_6inch_Rw								: REAL;(* 收料6寸周长/默认600 *)
	xPreCutOneBtn_Rw							: BOOL;(* 收料接料准备使用单输入标志/默认FALSE *)
	rCoefCut_FilmVolPerimeter_Rw				: REAL;(* 收料裁切系数/0.5 *)
	xDiaEstEn_Rw								: BOOL;(* 收料卷径估计使能/默认FALSE *)
	rEstiDia_Rw									: REAL;(* 预估卷径值/默认300mm *)
	rEstiThickness_Rw							: REAL;(* 预估料膜厚度值/默认0.02mm *)
	byDelayTime_DiaCompensateWhenCutDne_Rw		: BYTE;(* 裁切后卷径补偿介入时间/默认10s *)
	xUseAbsEncEn_Rw								: BOOL;(* 收料使用绝对值编码器标志/默认FALSE *)
	xMultAxisPosEn_Rw							: BOOL;(* 收料定位位置单独参数-绝对值编码器/默认FALSE *)
	byInitialSpd_Stiffen_Rw						: BYTE;(* 收料拉料初始速度/10r/min *)
	
	rDiamCurAxis_Uw								: REAL;(* 放料当前卷径 *)
	rDiamCurAxis_Rw								: REAL;(* 收料当前卷径 *)

	rGirth_If									: REAL;(* 放牵周长 *)
	uiNum_If									: UINT;(* 放牵减速比-电机转数 *)
	uiDen_If									: UINT;(* 放牵减速比-负载转数 *)
	rTaper_If									: REAL;(* 放牵锥度 *)
	byAIType_If									: BYTE;(* 放牵摆臂类型/初始值0 *)
	rAI_med_If									: REAL;(* 放牵摆臂模拟量中位 *)
	arKpid_If									: ARRAY [1..3] OF REAL;(* 放牵pid/2021.11.18.201839 *)
	iRatedRpm_If								: INT;(* 放牵电机额定转速/1500rpm *)
	iRatedFreq_If								: INT;(* 放牵电机额定频率/50HZ *)
	iUpperFreq_If								: INT;(* 放牵电机上限频率/100HZ *)
	xInchNegative_If							: BOOL;(* 放牵单运行反向/FALSE *)
	iInchVel_If									: INT;(* 放牵单运行速度/10m/min *)

	rGirth_Of									: REAL;(* 收牵周长 *)
	uiNum_Of									: UINT;(* 收牵减速比-电机转数 *)
	uiDen_Of									: UINT;(* 收牵减速比-负载转数 *)
	rTaper_Of									: REAL;(* 收牵锥度 *)
	byAIType_Of									: BYTE;(* 收牵摆臂类型/初始值0 *)
	rAI_med_Of									: REAL;(* 收牵摆臂模拟量中位 *)
	arKpid_Of									: ARRAY [1..3] OF REAL;(* 收牵pid/2021.11.18.202112 *)
	iRatedRpm_Of								: INT;(* 收牵电机额定转速/1500rpm *)
	iRatedFreq_Of								: INT;(* 收牵电机额定频率/50HZ *)
	iUpperFreq_Of								: INT;(* 收牵电机上限频率/100HZ *)
	xInchNegative_Of							: BOOL;(* 收牵单运行反向/FALSE *)
	iInchVel_Of									: INT;(* 收牵单运行速度/10m/min *)

(*2025.8.4.144213|原dwExtBitCtlFlag变量-改为BIT型--*)
	xSwitch_Change_CutterOnTop_HMI_Uw			: BIT;(*放料上下裁切换-界面按钮bit2*)
	xSwitch_Change_CutterOnTop_HMI_Rw			: BIT;(*收料上下裁切换-界面按钮bit3*)
	xCancelTenEn								: BIT;(*取消张力规划使能开bit10*)
	xEn_DualParam_AbsEncLocation_Uw				: BIT;(*bit11: 放料编码器方式下定位使用多轴使能|2021.5.7.111434|Liu.yt*)
	xEn_DualParam_AbsEncLocation_Rw				: BIT;(*bit12: 收料编码器方式下定位使用多轴使能|2021.5.7.111434|Liu.yt*)
	xFlag_AxisABParaFroDiaMea_Uw				: BIT;(*放料自动卷径分轴标志*)
	xSwitchTension_If							: BIT;(*bit6 放牵张力算法切换/FALSE *)
	xSwitchTension_Of							: BIT;(*bit7 收牵张力算法切换/FALSE *)
	xEnFeedLimitWarnFlag						: BIT;(*bit5 牵引速度限制提示使能位*)
	xSwitch_AxisLocaltion_DualParam_Uw			: BIT;(*放料绝对值编码器定位双轴参数开关|原bit11*)
	xSwitch_AxisLocaltion_DualParam_Rw			: BIT;(*收料绝对值编码器定位双轴参数开关|原bit12*)
	dwExtBitCtlFlag								: DWORD;(*扩展位控制标志|2019.1.25.143212|
													*.bit0: 放料自动卷径是否分轴来作?|FALSE默认一起|TRUE表示ab轴分开||
													*.bit1: 一键开机使能标志||
													*.bit2: 放料上下裁控制开关(区分于xCutterOnTop_Uw|)|2019.3.28.092931|补充遗漏||
													*.bit3: 收料上下裁控制开关(区分于xCutterOnTop_Rw|)|2019.3.28.092931|补充遗漏||
													Deprecated@2019.8.13.115259|*.bit4: 超声波检测使能|2019.3.23.154021||2019.3.28.092949|纠正错误||
													*.bit5: 牵引速度限制提示使能位|2019.4.18.135612|xie.gc||
													*.bit6: 放牵算法切换开关|@2019.8.1.091703|
													*.bit7: 收牵算法切换开关|@2019.8.1.091703|
													*.bit8: 放料前馈使能位|@2019.8.8.162527|xie.gc|
													*.bit9: 收料前馈使能位|@2019.8.8.162527|xie.gc|
													*.bit10: 取消张力规划使能开|2019.10.14.152513|niu.j|
													*.bit11: 放料编码器方式下定位使用多轴使能|2021.5.7.111434|Liu.yt|
													*.bit12: 收料编码器方式下定位使用多轴使能|2021.6.1.093832|Liu.yt|
													ALTMA增加了上下裁刀是否配置标志
													*.bit13: |2021.7.17.142536 放料上裁刀开启|Liu.yt|
													*.bit14: |2021.7.17.142536 放料下裁刀开启|Liu.yt|
													*.bit15: |2021.7.17.142536 收料上裁刀开启|Liu.yt|
													*.bit16: |2021.7.17.142536 收料下裁刀开启|Liu.yt|
													*.bit17: 2022.4.6.130956\翻料架打开控制位|
													|*)	

	byTaperCtlMode_Uw							: BYTE;(*锥度调整方式*)			
	byTaperCtlMode_Rw							: BYTE;(*锥度调整方式*)		
	(*2022.4.14.094534 收放料自动接料|21BYTES*)
	xAutomaticCutEn_Uw							: BOOL;(*放料自动裁切使能|*)
	byAutoMaticCutMode_Uw						: BYTE;(*放料自动裁切模式|0 按照剩余米数
																	 |1 按照剩余卷径*)
	uiAutoMaticCutMeters_Uw						: UINT;(*自动裁切米数|m*)
	uiAutoMaticCutDia_Uw						: UINT;(*自动裁切卷径|*)

	xAutomaticCutEn_Rw							: BOOL;(*收料自动裁切使能|*)
	byAutoMaticCutMode_Rw						: BYTE;(*收料自动裁切模式|0 按照计米长度-在上次接料完成后启动
															         |1 按照放料裁切后整机长度-在放料接料完成后启动
																     |2 按照当前卷径-在上次接料完成后启动*)
	uiAutoMaticCutMeters_Rw						: UINT;(*自动裁切米数|m*)
	uiAutoMaticCutDia_Rw						: UINT;(*自动裁切卷径|*)
	byLenth_Machine								: BYTE;(*整机长度|m*)
	rDia_PaperRoller_Uw							: REAL;(*纸筒直径|mm*)
	rFilmThickNess								: REAL;(*料膜厚度|mm*)
	(*放料|*)
	rDiamTaper_Begin_Uw							: REAL;(*放料起始锥度对应卷径|*)
	rDiamTaper_End_Uw							: REAL;(*放料结束锥度对应卷径|*)
	rTaper_Begin_Uw								: REAL;(*锥度起始|放料|*)
	rTaper_End_Uw								: REAL;(*锥度结束|放料|*)
	
	(*放牵|*)
	rTaper_Begin_If								: REAL;(*锥度起始|放牵|*)
	rTaper_End_If								: REAL;(*锥度结束|放牵|*)
	(*收牵|*)
	rTaper_Begin_Of								: REAL;(*锥度起始|收牵|*)
	rTaper_End_Of								: REAL;(*锥度结束|收牵|*)
														
	xStep_Fast:BOOL;
	rStep_Fast:REAL;
	rStep_Little:REAL; 
(*增加收放料收放牵锥度单位切换|支持%、N、mpa|104bytes*)
	byTaperUnit_Uw								: BYTE;(*放料锥度单位|默认%*)
	rPercentMatchN_Uw							: REAL;(*放料百分比-单位是N的对应|确认的值*)
	rN_Uw										: REAL;(*放料牛顿值|确认的值*)
	rPercentMatchMpa_Uw							: REAL;(*放料百分比-单位是Mpa的对应|确认的值*)
	rMpa_Uw										: REAL;(*放料兆帕值|确认的值*)

	byTaperUnit_Rw								: BYTE;(*收料锥度单位|默认%*)
	rPercentMatchN_Rw							: REAL;(*收料百分比-单位是N的对应|确认的值*)
	rN_Rw										: REAL;(*收料牛顿值|确认的值*)
	rPercentMatchMpa_Rw							: REAL;(*收料百分比-单位是Mpa的对应|确认的值*)
	rMpa_Rw										: REAL;(*收料兆帕值|确认的值*)

	byTaperUnit_If								: BYTE;(*放牵锥度单位|默认%*)
	rPercentMatchN_If							: REAL;(*放牵百分比-单位是N的对应|确认的值*)
	rN_If										: REAL;(*放牵牛顿值|确认的值*)
	rPercentMatchMpa_If							: REAL;(*放牵百分比-单位是Mpa的对应|确认的值*)
	rMpa_If										: REAL;(*放牵兆帕值|确认的值*)

	byTaperUnit_Of								: BYTE;(*收牵锥度单位|默认%*)
	rPercentMatchN_Of							: REAL;(*收牵百分比-单位是N的对应|确认的值*)
	rN_Of										: REAL;(*收牵牛顿值|确认的值*)
	rPercentMatchMpa_Of							: REAL;(*收牵百分比-单位是Mpa的对应|确认的值*)
	rMpa_Of										: REAL;(*收牵兆帕值|确认的值*)
	rDiamCurAxis_Uw2							: REAL;
	
	(*2025.8.9.142811增加*)
	xUseBtn_Linkage							: BIT;(*联动使用按钮/FALSE:开关|原wCtlSwitchRef.5*)
	xSwitch_WaitFilmLengthEn				: BIT;(*开机等料长|原原wCtlSwitchRef.4*)
	xSwitch_WaitFilmLengthEn_From1st		: BIT;(*开机等首色料长|原原wCtlSwitchRef.13*)
	xSwitch_GiveupHeaderEn					: BIT;(*让料头|原wCtlSwitchRef.15*)					
	xSwitch_Alarm_Arc						: BIT;(*套色报警开关|wCtlSwitchRef.0*)
	xSwitch_InkRollerSolenoid_Use3			: BIT;(*递墨辊三档有效标志|原wCtlSwitchRef.9*)
	xBitRsv6: BIT;
	xBitRsv7: BIT;
//2025.12.30.215929注意新增变量了，参数不统一了
	byIn_outFeed_ThresCoff							: BYTE;(*断料保护牵引判断阀值|原LREAL型，改为BYTE吧*)	
//2026.1.9.160446这里替代一下先防止数据大小变化
//	byBitRsv: BYTE;
	byBitRsv1: BYTE;
	(*2025.10.14.134703先把这个屏蔽了，直接用bit类型吧|NIU.J
	wCtlSwitchRef							: WORD;(*整机控制开关描述|
													*.bit0: 套色报警开关
													*.bit1: 波门锁|根据色组来更新
													*.bit2: 整机纵向自动| 2018.3.23.145133| han.dp|
													*.bit3: 整机横向自动| 2018.3.23.145153| han.dp|
													*.bit4: 开机等料长\2018.5.27.153018|
													*.bit5: han.dp\2018.6.19.172042\联动采用非两档开关|
													*.bit6: 2018.7.13.081355\使能标准3''6''纸管选择|TRUE按标准纸管走 FALSE按屏幕输入走|
													*.bit7: 2018.7.3.194246\色组单独减速比设置|
													*.bit8: 2018.7.23.143553\刮刀使能开关|
													*.bit9: 2018.7.28.102401\递墨辊三档有效标志|(TRUE有效)|
													*.bit10: 2018.8.13.101345\预加热印刷使能|
													*.bit11: 排风限制热风使能|
													*.bit12: 2018.8.15.082652\放料表印选择\默认FALSE=里印|
													*.bit13: 2018.8.15.082652\收料表印选择\默认FALSE=里印|
													*.bit14: 2022.4.6.140140排风限制开机使能
													|*)
													*)

	wCtl_Pressure_Up_Dn							: WORD;	
												(*
												bit0：自动合压-进入印刷状态后自动合压
												bit1：急停直接离压/FALSE急停不动作，复位离压
												bit2：裁切避让胶带使能
												bit3：裁切避让胶带外触发标志/内触发需要计算裁切切点到1色料长
												bit4：停机自动匀墨
												bit5：压力电机维持使能
												bit6：点位运动电机维持使能
												*)		
	rLength_AvoidancePoint_To_1u_mm				: REAL;//避让胶带检测点到1色的距离	

	rFilmThick_Confirm							: REAL;
	rFilmThick_Manu								: REAL;
	
	lrDistanceOfLimitTo_MEdge_MM				: LREAL;//限位距离边缘的距离,单位 ： mm
//秦华带长相关功能标志	
	xLength_BandLen_Check						: BOOL;(*手动检测带长*)
	rLength_Band_Confirm						: REAL;(* 带长/整机设置状态,需要同步到每个色组的检测带长 *)
	xLength_BandLen_Sync						: BOOL;(*自动同步带长*)	
	rLength_HeightStandard						: REAL;(*整机同步带长的标准纵向高度值*)
	rLength_Width								: REAL;(*版辊张带辊横向差值*)
	rLength_Printing : REAL;		//系统印长
//2024.12.11.135813 | 增加印版辊速度、网辊速度、张带速度		12字节
	rVel_Press_Prn:REAL;
	rVel_Press_Net:REAL; 
	rVel_Press_Str:REAL;		
	rPressure_Tar : REAL;
//2025.02.27.200725 | 增加收放料小卷径补偿		18字节
	xSmallDiaMulEn_UW						: BOOL;//:= FALSE;
	iSmallDiaMulSa_UW						: INT;//:=200;(*进入该方式的启动卷径|大卷径*)
	iSmallDiaMulEd_UW						: INT;//:=100;(*结束的卷径|写死为最小卷径*)
	iSmallDiaMulSa_Coeff_UW					: INT;//:=100;(*系数|单位%*)
	iSmallDiaMulEd_Coeff_UW					: INT;//:=300;(*系数|单位%*)
	
	xSmallDiaMulEn_RW						: BOOL;//:= FALSE;
	iSmallDiaMulSa_RW						: INT;//:=200;(*进入该方式的启动卷径|大卷径*)
	iSmallDiaMulEd_RW						: INT;//:=100;(*结束的卷径|写死为最小卷径*)
	iSmallDiaMulSa_Coeff_RW					: INT;//:=100;(*系数|单位%*)
	iSmallDiaMulEd_Coeff_RW					: INT;//:=300;(*系数|单位%*)		
//	2025.02.28.092405 /增加色组间加热控制的两档位 		4字节
	rVel_Temp_I								: INT;//:=30;
	rVel_Temp_II							: INT;//:=60;	
	rBandLengthNotAdjArea					: REAL;
	rVel_NetReturn : REAL;

	iVelSa_ScraperRun						: INT;
	iVolt_ScraperMin						: INT;(*刮刀变频最小电压|2018.7.25.121151|*)
	iVolt_ScraperMax						: INT;(*刮刀变频最大电压|2018.7.25.121151|*)
	lrRatedRpm_Scraper						: LREAL;(*刮刀变频额定转速|*)
	lrRatedFreq_Scraper						: LREAL;(*刮刀变频额定频率|*)
	lrUpperFreq_Scraper						: LREAL;(*刮刀变频上限频率|*)
	lrLowerFreq_Scraper						: LREAL;(*刮刀变频下限频率|*)
	rMaxFreq_Scraper						: REAL;(*刮刀变频最大频率|*)
	rMinFreq_Scraper						: REAL;(*刮刀变频最小频率|*)
	
	lrCoeff_Scraper							: LREAL;(*刮刀变频速度系数|*)
	iNum_ScraperMotor						: INT;(*刮刀电机减速比分子numerator*)
	iDen_ScraperMotor						: INT;(*刮刀频率分母denominator*)
	iRatio_ScraperContrastToPrintRoller		: INT;(*刮刀相对版转速的对应比*)
	iDelayMsec_Heat							: INT;(*加热延时时间|*)
	iDelayMsec_HeatBlower					: INT;(*热风延时时间|*)
	iDelayMsec_ExhPowerMode					: INT;(*排风模式切换时间|*)
	
	(*张力优化算法2025.7.3.175755*)
	rR_K_LQR_Uw												: REAL;
	rN_LQR_Uw												: REAL;
	rR_K_MinBeat_Uw											: REAL;
	iN_MinBeat_Uw											: INT;
	xUseAntiNotch_Uw										: BOOL;(*套色使用陷波器@*)
	rWn_Uw													: REAL;(*陷波中心频率 rad/s*)
	rBw_Uw													: REAL;(*陷波宽度 rad/s*)
	rDp_Uw													: REAL;(*陷波深度 dB*)	
	xUseIMatrix_rX_DARE_Uw									: BOOL;(*使用单位矩阵否则使用的是特定卷径的收敛值*)
	rKc_Uw													: REAL;(*补偿系数*)
	rKc_Uw_AccDec											: REAL:=0.08;(*加减速时候输出系数@必须为负值*)
	uiUseTime_Diam_Min_Uw									: UINT;(*使用时变的最小卷径|mm@2024.05.14.080937*)
	xUseTime_b1_Uw											: BOOL;(*有效则b1随卷径实时变化-不实时变化则使用b1_0@2024.05.14.080937*)
	xUseDiam_LowPass_Uw										: BOOL;(*使用低通滤波后的卷径*)
	rWc_LowPass_Diam_Uw										: REAL;(*放料卷径低通截止频率@2024.7.11.152456*)
	xUseIfVel_Uw											: BOOL;(*使用放牵速度|放料张力算法以及原来的前馈@2024.8.21.165317*)
	

	rR_K_LQR_Rw												: REAL;
	rN_LQR_Rw												: REAL;

	rR_K_MinBeat_Rw											: REAL;
	iN_MinBeat_Rw											: INT;

	xUseIMatrix_rX_DARE_Rw									: BOOL;(*使用单位矩阵否则使用的是特定卷径的收敛值*)
	rKc_Rw_AccDec											: REAL:=0.08;(*加减速时候输出系数@必须为负值*)
	uiUseTime_Diam_Min_Rw									: UINT;(*使用时变的最小卷径|mm@2024.05.14.080937*)
	xUseTime_b1_Rw											: BOOL;(*有效则b1随卷径实时变化-不实时变化则使用b1_0@2024.05.14.080937*)
	rKc_Rw													: REAL;(*补偿系数*)
	byKalmanFilterType_Rw									: BYTE;(*收料张力估计时卡尔曼滤波类型选择*)

	(*收料张力算法使能标志@2024.7.15|11bytes*)
	xTensionCompensateEn_Rw									: BOOL;(*张力补偿算法使能*)
	xTensionCompensateEn_RwCut								: BOOL;(*收料裁切使用张力补偿使能*)
	xUseDiam_LowPass_Rw										: BOOL;(*使用低通滤波后的卷径*)
	rWc_LowPass_Diam_Rw										: REAL;(*收料卷径低通截止频率*)
	rWuCompensate_Rw										: REAL;(*补偿的转速(R/MIN)|计算的*)
	rWuCompensate_Act_Rw									: REAL;(*补偿的转速(R/MIN)|实际使用的*)


	xUseOfVel_Rw											: BOOL;(*使用收牵速度|收料张力算法以及原来的前馈@2024.8.21.165317*)
(*	abyReserved_TensionCtl_Rw								: ARRAY [1..1] OF BYTE;*)
											(*xUseOfVel_Rw|0*)
											(*xTensionCompensateEn_Rw-->xTensionCompensateEn_RwCut|16->1*)
	(*收放料新的pid算法标志*)
	xPidType_If_New							: BOOL;
	xPidType_Of_New							: BOOL;
(*2025.7.3.175755开始增加内容*)
	byKalmanFilterType_Uw:BYTE;(*放料张力估计时卡尔曼滤波类型选择@=0 Kalman_CycDis_BeiRen/Kalman_CycDis_test
																 @=1 Youla_Kalman
																 @=2 ExtendKalman
																 @=3 UnExtendKalman*)
	byStructParanInitEn_Uw									: BYTE;(*初始化使能标志@按照定义顺序/.0 初始化第一个结构体。以此类推！@顺序按照KS_InitTensionCtl_StructParam定义*)																 
	byStructParanInitEn_Rw									: BYTE;(*初始化使能标志@按照定义顺序/.0 初始化第一个结构体。以此类推！@顺序按照KS_InitTensionCtl_StructParam定义*)																 

	byNeedAutomaticCut_UwRw									: BYTE;	(*打开自动裁切使能提示标志@按系区分*)	
	(*2025.7.3.175755增加*)
	iCutDneResetPidMultiple_Uw								: INT;(*裁切后PID放大倍数*)
	iCutDneResetPidMultiple_Rw								: INT;(*裁切后PID放大倍数*)
	iCutDneResetPidRemainTime_Uw							: INT;
	iCutDneResetPidRemainTime_Rw							: INT;
	iCutDneResetPidToDefaultTime_Uw							: INT;
	iCutDneResetPidToDefaultTime_Rw							: INT;
	xUseAbsEncoder_Uw										: BOOL;(*放料编码器方式定位*)
	xUseAbsEncoder_Rw										: BOOL;(*收料编码器方式定位*)
	uiPreStopDelayTime_ms									: UINT:=100;(*预驱停止延迟时间@100ms*)
	dwAbsEnCodeResolution_Uw					: DWORD;(* 放料绝对值编码器分辨率/8388608 *)
	dwAbsEnCodeResolution_Rw					: DWORD;(* 收料绝对值编码器分辨率/8388608 *)
	xUseFollow_1U_V_UwCut					: BOOL;(*使用放料裁切跟踪第一色方法*)
	uiMaxDia								: UINT;(*最大的卷径@mm*)
	uiInitDiam_Uw							: UINT;(*初始的卷径@mm|=0 按照200---uiMaxDia取中间值*)
	uiInitDiam_Rw							: UINT;(*初始的卷径@mm|=0 按照200---uiMaxDia取中间值*)
	xGetFilmThickNessAuto					: BOOL;(*料膜厚度获取方式*)
	rFilmThickNess_Using					: REAL;(*最终应用的料膜厚度*)
	byAlarmType_NoMaterial_Uw				: BYTE:=0;(*没料报警方式@=0 放料没料3S响铃报警
													  @=1 放料没料时候一直报警-直到按下正转\反转\接料准备*)
	xTensionCompensateEn_Uw					: BOOL;
	xTensionCompensateEn_UwCut				: BOOL;
	xUseTime_Variaition_Uw					: BOOL;(*使用时变参数标志*)
	xUseTime_Variaition_Rw					: BOOL;(*使用时变参数标志*)
	byAlarmHold_PreCut_Uw					: BYTE;
	byAlarmHold_PreCut_Rw					: BYTE;
	xCutDneResetPidEn_Uw					: BOOL;
	xCutDneResetPidEn_Rw					: BOOL;
	byMeters_UseFollow_1U_V_UwCut			: BYTE;(*裁切时跟一色*)
	byVelSa_DiamCompensate_Uw				: BYTE;
	byVelSa_DiamCompensate_Rw				: BYTE;
	xGetLenthMachine_Rw:BOOL;(*收料自动裁切获取料长使能*)
	xUseKnob_6Inch_Rw_Hmi: BOOL;(**)(*收料3-6寸使用界面旋钮@2024.04.18.182812*)
	byPrintLength_CalcCtl					: BYTE;(*控制印刷记长显示|niu.j|2019.1.25.135921||*)
	alrPrnLen_FilmVel						: ARRAY [1..3] OF LREAL;(*根据料膜速度计算记米|niu.j|2019.1.25.135921||*)
	alrPrnLen_PTPos							: ARRAY [1..3] OF LREAL;(*根据PT规划位置计算记米|niu.j|2019.1.25.135921||*)
	alrPrnLen_FilmCnt						: ARRAY [1..3] OF LREAL;(*根据幅数记米|niu.j|2019.1.25.135921||*)

	xCompensateWhenAccing_If			:BOOL:=FALSE;
	rCompensateGirthWhenAccing_If		:REAL:=0;(*补偿的值|mm*)
	xCompensateWhenAccing_Of			:BOOL:=FALSE;
	rCompensateGirthWhenAccing_of		:REAL:=0;(*补偿的值|mm*)
	byVelLimit_PerCent_IfOf				: BYTE;
	iFeedLimitWarnCoff					: INT;(*牵引调整fazhi*)
	xUseAntiNotch_If					: BOOL;
	xUseAntiNotch_Of					: BOOL;
	rWn_If								: REAL;
	rBw_If								: REAL;
	rDp_If								: REAL;
	rWn_Of								: REAL;
	rBw_Of								: REAL;
	rDp_Of								: REAL;

	(*2025.8.6.193451套色调整*)
	iWorkMode_Pid						: INT;(*1-传统pid; 2-目标pid|*)
	xFlag_Follow_1U_H						:BOOL;
	xFlag_Follow_1U_V						:BOOL;
	(*目前取值2--6|该值代表当前色不受前n个轴影响
	即为2时是解耦每个机组的前两组(第3组不受第2组影响；第4组不受第2、3组影响；第5组不受第3、4组影响*)
	byDeCoupleArcNum:BYTE;(*解耦的深度|默认先取3*)
	byDeCoupleDelayNum:BYTE;(*解耦时延拍数|默认先取18*)
	rFilmLenth_InUnit:REAL;(*色组间料长单位|m@测试先写成系参数*)	
	byInitTaper_Rw: BYTE;
	rInitTaper_Hmi_Rw: REAL;
	rPressure_Max									:REAL		;(*涂布压力传感器最大标定值*)
	rHz_MainExhaust_ManuallySet						:REAL	;(*主排风设定频率*)	
	byStationIdDst_VirEnc							:BYTE		;(*异站编码器目标站好*)
	iPreHotRoller_Velocity_PreHot 					:INT	;  (*预热辊额定转速*)
	rStandardFreq_HotRoller_PreHot 					:REAL	; (*预热辊额定频率*)
	rUpperFreq_HotRoller_PreHot 					:REAL	;    (*预热辊上限频率*)
	rCoeff_HotRoller_PreHot 						:REAL;        (*预热辊速度系数*)
	rGirth_HotRoller_PreHot 						:REAL	;        (*预热辊周长*)
	iPreAirHotRollTorque 							:INT;           (*预热辊转矩*)
	uiDen_HotRoller_PreHot 							:UINT	;         (*预热辊减速比分母*)
	uiNum_HotRoller_PreHot 							:UINT;         (*预热辊减速比分子*)
	iPreHotRoller_Velocity_Water 					:INT	;   (*水冷辊额定转速*)
	rStandardFreq_HotRoller_Water 					:REAL	;  (*水冷辊额定频率*)
	rUpperFreq_HotRoller_Water 						:REAL	;     (*水冷辊上限频率*)
	rCoeff_HotRoller_Water 							:REAL;         (*水冷辊速度系数*)
	rGirth_HotRoller_Water 							:REAL	;         (*水冷辊周长*)
	uiDen_HotRoller_Water 							:UINT	;          (*水冷辊减速比分母*)
	uiNum_HotRoller_Water 							:UINT;			(*水冷辊减速比分子*)
	byHotBlowerStopDelayTime 						:BYTE;		  (*热风停止延时*)
	byFreqMin_HotWind 								:BYTE	;				(*热风最小频率*)
	byFreqMax_HotWind 								:BYTE	;				(*热风最大频率*)	
	byDelayTime_PressDneInPrint_If 					:BYTE		;		 (*放牵压辊延时*)	
	byAxisInitPhaseTypeWhenPreRegister 				:BYTE;              	(*预套准初始位置*)
	rAdjVal_PerTime_Fine : REAL;(*手动细调调整量*)
	rAdjVal_PerTime_Coarse : REAL;(*手动粗调调整量*)
	rVel_HorzPreRegister : REAL;(*横向预套准速度*)
	
	rVel_Tar_9905			: REAL;
	iMicron_StepTest1_V		: INT;
	iMicron_StepTest2_V		: INT;
	R_0_RW				: REAL;	
	a0_0_RW	        	: REAL;
	b1_0_RW	        	: REAL;
	Wn_0_RW	        	: REAL;
	Beta_0_RW	    	: REAL;
	l_0_RW	        	: REAL;
	K_PI_RW	        	: REAL;
	a_RW	            : REAL;
	b_RW	            : REAL;
	Ts_RW	            : REAL;
	Range_RW	        : REAL;
	Theta_RW	        : REAL;
	K_adj_RW	        : REAL;
	R_0_UW		: REAL	;
	a0_0_UW     : REAL 	;
	b1_0_UW     : REAL 	;
	Wn_0_UW     : REAL 	;
	Beta_0_UW   : REAL 	;
	l_0_UW      : REAL 	;
	K_PI_UW     : REAL 	;
	a_UW        : REAL 	;
	b_UW        : REAL 	;
	Ts_UW       : REAL 	;
	Range_UW    : REAL 	;
	Theta_UW    : REAL 	;
	K_adj_UW    : REAL 	;
	
(*部分开关变量2025.8.8.152013*)
	xSwitch_StartUp					: BIT;(*一键开机*)
	xSwitch_RollOver				: BIT;(*翻料架开关*)
	(*新增变量-开始-2025.08.11.135045*)
	xHor_Goal_Flag : BOOL;(*横向目标值标志*)
	xHor_PreRegist_Flag : BOOL;(*横向重复值标志*)
	xEnaTestARC_Ink : BOOL;(*空转测试使能*)
	xHorLimit : BOOL; (*限位定义修改为左右|默认是正反转*)
	xHorManuCtrl:BOOL; (*界面横向手动修正功能*)
	(*新增变量-结束-2025.08.11.135057*)

(*原用户基础工艺开关控制位直接用BIT吧，不用dwCtlBits_UnitBaseCraft了--
通讯改为共用体吧*)		
(*bit0-bit31--2025.8.13.100117*)
	xSwitch_ScraperAuto_If					: BIT;(*刮刀手自动-bit0*)
	xSwitch_ScraperOn_If					: BIT;(*刮刀开关bit1*)
	xInterver_ScraperRun_If					: BIT;(*刮刀开关bit2*)
	xRsv_BIT3_If							: BIT;(*BIT3预留*)
	xSwitch_InkRollerAuto_If				: BIT;(*递墨辊手自动bit4*)
	xSwitch_InkRollerCW_If					: BIT;(*递墨辊正转bit5*)
	xSwitch_InkRollerCCW_If					: BIT;(*递墨辊反转bit6*)
	xInterver_InkRollerRun_If				: BIT;(*递墨辊运行bit7*)
	xInterver_HotWindRun_If					: BIT;(*热风1运行bit9*)
	xRsv_BIT10_If							: BIT;(*BIT10预留*)
	xRsv_BIT11_If							: BIT;(*BIT11预留*)
	xSwitch_HotWindOn_II_If					: BIT;(*热风开关bit12*)
	xInterver_HotWindRun_II_If				: BIT;(*热风1运行bit13*)
	xRsv_BIT14_If							: BIT;(*BIT14预留*)
	xRsv_BIT15_If							: BIT;(*BIT15预留*)
	xSwitch_HeatingMode_Water_If			: BIT;(*水加热开关bit16*)
	xSwitch_HeatingMode_Ele_If				: BIT;(*电加热开关bit17*)
	xSwitch_Heating_II_If					: BIT;(*加热II档bit19*)
	xSwitch_Heating_III_If					: BIT;(*加热III档bit20*)
	xRsv_BIT21_If							: BIT;(*BIT21预留*)
	xRsv_BIT22_If							: BIT;(*BIT22预留*)
	xErrReset_Scraper_If					: BIT;(*刮刀故障复位bit23*)
	xErrReset_InkRoller_If					: BIT;(*递墨故障复位bit24*)
	xErrReset_Hotwind_If					: BIT;(*热风故障复位bit25*)
	xErrReset_Hotwind_II_If					: BIT;(*热风2故障复位bit26*)
	xErrReset_ExhAir_If						: BIT;(*排风故障复位bit27*)
	xSwitch_ExhAir_If						: BIT;(*排风开关bit28*)
	xInterver_ExhAir_If						: BIT;(*排风运行bit29*)
	xRsv_BIT30_If							: BIT;(*BIT30预留*)
	xSwitch_Coolwind_If						: BIT;(*冷风开关*)
	
	xSwitch_PreHotAirEn								: BIT;
	xSwitch_PreHeatingEn							: BIT;
	
(*基础工艺开关-*)	
(*原用户基础工艺开关控制位直接用BIT吧，不用dwCtlBits_UnitBaseCraft了--
通讯改为共用体吧*)		
(*bit0-bit31--2025.8.13.100117*)
	xSwitch_ScraperAuto_Of					: BIT;(*刮刀手自动-bit0*)
	xSwitch_ScraperOn_Of					: BIT;(*刮刀开关bit1*)
	xInterver_ScraperRun_Of					: BIT;(*刮刀开关bit2*)
	xRsv_BIT3_Of							: BIT;(*BIT3预留*)
	xSwitch_InkRollerAuto_Of				: BIT;(*递墨辊手自动bit4*)
	xSwitch_InkRollerCW_Of					: BIT;(*递墨辊正转bit5*)
	xSwitch_InkRollerCCW_Of					: BIT;(*递墨辊反转bit6*)
	xInterver_InkRollerRun_Of				: BIT;(*递墨辊运行bit7*)
	xSwitch_HotWindOn_Of					: BIT;(*热风开关bit8*)
	xInterver_HotWindRun_Of					: BIT;(*热风1运行bit9*)
	xRsv_BIT10_Of							: BIT;(*BIT10预留*)
	xRsv_BIT11_Of							: BIT;(*BIT11预留*)
	xSwitch_HotWindOn_II_Of					: BIT;(*热风开关bit12*)
	xInterver_HotWindRun_II_Of				: BIT;(*热风1运行bit13*)
	xRsv_BIT14_Of							: BIT;(*BIT14预留*)
	xRsv_BIT15_Of							: BIT;(*BIT15预留*)
	xSwitch_HeatingMode_Water_Of			: BIT;(*水加热开关bit16*)
	xSwitch_HeatingMode_Ele_Of				: BIT;(*电加热开关bit17*)
	xSwitch_Heating_I_Of					: BIT;(*加热I档bit18*)
	xSwitch_Heating_II_Of					: BIT;(*加热II档bit19*)
	xSwitch_Heating_III_Of					: BIT;(*加热III档bit20*)
	xRsv_BIT21_Of							: BIT;(*BIT21预留*)
	xRsv_BIT22_Of							: BIT;(*BIT22预留*)
	xErrReset_Scraper_Of					: BIT;(*刮刀故障复位bit23*)
	xErrReset_InkRoller_Of					: BIT;(*递墨故障复位bit24*)
	xErrReset_Hotwind_Of					: BIT;(*热风故障复位bit25*)
	xErrReset_Hotwind_II_Of					: BIT;(*热风2故障复位bit26*)
	xErrReset_ExhAir_Of						: BIT;(*排风故障复位bit27*)
	xSwitch_ExhAir_Of						: BIT;(*排风开关bit28*)
	xInterver_ExhAir_Of						: BIT;(*排风运行bit29*)
	xRsv_BIT30_Of							: BIT;(*BIT30预留*)
	xSwitch_Coolwind_Of						: BIT;(*冷风开关*)
(*基础工艺开关-*)	
(*刮刀递墨一控多相关参数*)
	rHz_Scraper_ManuallySet				: REAL;(*刮刀手动频率*)
	(*新增变量-开始|wang.nt|2025.08.12.163420*)
	xLostPressure:BOOL;(*气压低报警|不允许开机*)
	xPrnRollerLoose_AtLeast1:BOOL;(*至少1色夹板报警|不允许开机*)
	xbrakeResistanceTempHigh_AtLeast1:BOOL;(*至少1色制动电阻温度过高*)
	(*新增变量-结束|wang.nt|2025.08.12.163420*)

(*2025.8.13.114803新增递墨参数*)
	iRatedRpm_InkRoller						: INT;(*递墨辊变频额定转速|*)
	iRatedFreq_InkRoller					: INT;(*递墨辊变频额定频率|*)
	iUpperFreq_InkRoller					: INT;(*递墨辊变频上限频率|*)
	iVel_InkRollerMin						: INT;(*递墨辊变频最小频率对应最小速度|*)
	iFrq_InkRollerMin						: INT;(*递墨辊变频最小频率|*)
	iVel_InkRollerMax						: INT;(*递墨辊变频最大频率对应的最大速度|*)
	iFrq_InkRollerMax						: INT;(*递墨辊变频最大频率|*)
	rCoeff_InkRoller						: REAL;(*递墨辊变频速度系数|*)
	iVelSa_InkRollerRun						: INT;(*递墨辊可以运行的起始速度|2022.5.19.130612*)

(*2025.8.13.114803新增递墨参数*)
	rHz_InkRoller_ManuallySet			: REAL;(*刮刀手动频率*)			
	(*新增变量-开始|wang.nt|2025.08.12.163420*)
	xBtn_ResetAlarm:BOOL;(*按钮被按下*)
	xFlag_PhaseRead:BOOL;(*读取装版相位*)
	iOneKeySwitchOn_IdGSE: INT;(*当前系处于一键开机*)
	iMotionCtlErrCode:INT;(*错误*)
	xTips_ExhausLimitStart:BOOL;(*排风限制开机*)
	xHorzMotorAlarmAtLeastOne:bool;(*横向电机报警*)
	(*新增变量-结束|wang.nt|2025.08.12.163420*)							
								
	xWorkMode_RollerPress					: BOOL;(*压辊顺序; TRUE从前到后; FALSE从后到前|*)	
	//结构体定义
	astStTimeSet_DnCut_UpCut_Uw					: ARRAY [0..1] OF StTimeSet_DnCut_UpCut;(* 放料端的裁切时间集/BOOL_TO_INT(xCutterOnTop_Uw)做索引访问 *)
	astStTimeSet_DnCut_UpCut_Rw					: ARRAY [0..1] OF StTimeSet_DnCut_UpCut;(* 收料端的裁切时间集/BOOL_TO_INT(xCutterOnTop_Rw)做索引访问 *)
	astStStdVolParam_DnCut_UpCut				: ARRAY [0..1] OF StStdVolParam_DnCut_UpCut;(* 卷径测量参数集/BOOL_TO_INT(xCutterOnTop_Uw)做索引访问 *)
	stModelParam_Uw								: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)
	stInvariant_Parameters_Uw					: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)
	stPI_Parameters_Uw							: PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)
	stPI_Parameters_Uw_AccDec					: PI_Parameters;(*控制器pi参数@20bytes|2024.05.13.180942 增加一组加减速的控制参数*)

	stModelParam_Rw								: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)
	stInvariant_Parameters_Rw					: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)
	stPI_Parameters_Rw							: PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)
	stPI_Parameters_Rw_AccDec					: PI_Parameters;(*控制器pi参数@20bytes|2024.05.13.180942 增加一组加减速的控制参数*)



	byParamIndex_Huang			: BYTE;
	uiControllerVel_Huang		: UINT;
	byFilmType					: BYTE;
	rFinalVel_ThisTime			: REAL;

	abyReserved					: ARRAY [1..28] OF BYTE;(*预留28个字节*)

	astTaperPoint_Rw						: ARRAY [1..10] OF StPoint_XY;
	(*新增工艺参数|2025.08.15.152008*)
	byFreqUpper_ExhaustAir :BYTE;
	uiFreqCoeff_Auto_ExhaustAir:UINT;
	byFreqMax_ExhaustAir:BYTE;
	byFreqMin_ExhaustAir:BYTE;
	
(*2025.8.19.205954*)
	xWorkMode_ManuAdj: BOOL;	
	(*新增等料长相关参数|wang.nt|2025.08.20.220737*)
	lrFilmLen_UnwindToPU1					: LREAL;(*放料裁切点到1U的料膜距离|单位:mm|*)
	lrFilmLen_NotAdjFront					: LREAL;(*裁切点前不调整的料长|单位:mm|*)
	lrFilmLen_NotAdjBack					: LREAL;(*裁切点后不调整的料长|单位:mm|*)		
	(*预套准相关变量|wang.nt|2025.08.21.162056*)
	byTurnOverAxisId						: BYTE;(*翻料架轴id@比如第10色反印那么 byTurnOverAxisId=10*)		
	xPreRegisterAxisId_Manu					: BOOL;(*预套准的轴号手动确定@不考虑联动开关*)			
	xSwitch_TempFromEnc_PT1000_If							: BIT;
	xSwitch_MotorTemp_PT1000_NTC_If						: BIT;
	xSwitch_TempFromEnc_PT1000_Of							: BIT;
	xSwitch_MotorTemp_PT1000_NTC_Of						: BIT;				
//增加预热风和预加热参数2025.10.15.162208|niuj||88-16=72
	rHz_PreHotAir_ManuallySet							: REAL;(*预热风频率*)
	rSV_PreHeating										: REAL;(*预加热温控SV*)
	rCoeff_Scraper_Auto									: real;(*主刮刀自动系数*)

END_STRUCT
END_TYPE

{IMPLEMENTATION}
