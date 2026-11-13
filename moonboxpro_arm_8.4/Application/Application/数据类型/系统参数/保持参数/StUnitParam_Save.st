(*@CES
Name=StUnitParam_Save
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=eeacd55f-9111-4e09-ad6b-b078dffd0b62
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StUnitParam_Save :
STRUCT
	byGrpId										: BYTE;(*系ID*)
	rGirth_BottomRoller							: REAL;(* 底辊周长 *)
	uiNum_BottomRoller							: UINT;(* 底辊减速比分子 *)
	uiDen_BottomRoller							: UINT;(* 底辊减速比分母 *)
	rGirth_PrnRoller							: REAL;(* 版辊周长 *)
	uiNum_PrnRoller								: UINT;(* 版辊减速比分子 *)
	uiDen_PrnRoller								: UINT;(* 版辊减速比分母 *)
	rGirth_NetRoller							: REAL;(* 网辊周长 *)
	uiNum_NetRoller								: UINT;(* 网辊减速比分子 *)
	uiDen_NetRoller								: UINT;(* 网辊减速比分母 *)
	rLength_Band								: REAL;(* 带长 *)
	rErrLength_Band								: REAL;(* 设置带长与实际检测之间的误差 *)
	rGirth_StrRoller							: REAL;(* 张带辊周长 *)
	uiNum_StrRoller								: UINT;(* 张带辊减速比分子 *)
	uiDen_StrRoller								: UINT;(* 张带辊减速比分母 *)
	rScrewPitch_Horz							: REAL;(* 横向架丝杆节距/整机设置状态/单位mm *)
	uiNum_Horz									: UINT;(* 横向电机减速比分子/整机设置状态 *)
	uiDen_Horz									: UINT;(* 横向电机减速比分母/整机设置状态 *)
	lrLimit_Operate_Horz						: LREAL;(*操作侧电机限位*)
	lrLimit_Driver_Horz							: LREAL;(*传动侧电机限位*)
	wCtlmod_PrnRoller_Pressure					: WORD;(* 版辊压力控制方式 *)
		(*
		/0表示不控制(默认)
		/1为独立单轴控制
		/2为双轴控制
		/4为4轴驱动器控制 *)
	rScrewPitch_PrnRoller_Pressure				: REAL;(* 版辊压力架丝杆节距/单位mm *)
	uiNum_PrnRoller_Pressure					: UINT;(* 版辊压力电机减速比分子 *)
	uiDen_PrnRoller_Pressure					: UINT;(* 版辊压力电机减速比分母 *)
	rScrewPitch_NetRoller_Pressure				: REAL;(* 网辊压力架丝杆节距/单位mm *)
	uiNum_NetRoller_Pressure					: UINT;(* 网辊压力电机减速比分子 *)
	uiDen_NetRoller_Pressure					: UINT;(* 网辊压力电机减速比分母 *)
	rScrewPitch_StrRoller_Pressure				: REAL;(* 张带辊压力架丝杆节距/单位mm *)
	uiNum_StrRoller_Pressure					: UINT;(* 张带辊压力电机减速比分子 *)
	uiDen_StrRoller_Pressure					: UINT;(* 张带辊压力电机减速比分母 *)
	rMovementHiSpd_PrnRoller_Pressure			: REAL;(* 版辊压力架移动速度(高)/默认单位:mm/s *)
	rMovementHiSpd_NetRoller_Pressure			: REAL;(* 网辊压力架移动速度(高)/默认单位:mm/s *)
	rMovementLoSpd_PrnRoller_Pressure			: REAL;(* 版辊压力架移动速度(低)/默认单位:mm/s *)
	rMovementLoSpd_NetRoller_Pressure			: REAL;(* 网辊压力架移动速度(低)/默认单位:mm/s *)
	rPos_press_dn_PrnRoller_Pressure_M			: LREAL;(* 合压位置/版辊压力电机M侧/单位:mm *)
	rPos_press_dn_PrnRoller_Pressure_G			: LREAL;(* 合压位置/版辊压力电机G侧/单位:mm *)
	rPos_press_up_PrnRoller_Pressure_M			: LREAL;(* 离压位置/版辊压力电机M侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	rPos_press_up_PrnRoller_Pressure_G			: LREAL;(* 离压位置/版辊压力电机G侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	rPos_load_unload_PrnRoller_Pressure_M		: LREAL;(* 装卸辊位置/版辊压力电机M侧/单位:mm *)
	rPos_load_unload_PrnRoller_Pressure_G		: LREAL;(* 装卸辊位置/版辊压力电机G侧/单位:mm *)
	rPos_press_dn_NetRoller_Pressure_M			: LREAL;(* 合压位置/网辊压力电机M侧/单位:mm *)
	rPos_press_dn_NetRoller_Pressure_G			: LREAL;(* 合压位置/网辊压力电机G侧/单位:mm *)
	rPos_press_up_NetRoller_Pressure_M			: LREAL;(* 离压位置/网辊压力电机M侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	rPos_press_up_NetRoller_Pressure_G			: LREAL;(* 离压位置/网辊压力电机G侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	rPos_load_unload_NetRoller_Pressure_M		: LREAL;(* 装卸辊位置/网辊压力电机M侧/单位:mm *)
	rPos_load_unload_NetRoller_Pressure_G		: LREAL;(* 装卸辊位置/网辊压力电机G侧/单位:mm *)
	rPos_press_dn_StrRoller_Pressure_M			: LREAL;(* 合压位置/网辊压力电机M侧/单位:mm *)
	rPos_press_dn_StrRoller_Pressure_G			: LREAL;(* 合压位置/网辊压力电机G侧/单位:mm *)
	rPos_press_up_StrRoller_Pressure_M			: LREAL;(* 离压位置/网辊压力电机M侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	rPos_press_up_StrRoller_Pressure_G			: LREAL;(* 离压位置/网辊压力电机G侧/单位:mm/根据当前合压位置实时变化/2021.12.29.140151 *)
	rPos_load_unload_StrRoller_Pressure_M		: LREAL;(* 装卸辊位置/网辊压力电机M侧/单位:mm *)
	rPos_load_unload_StrRoller_Pressure_G		: LREAL;(* 装卸辊位置/网辊压力电机G侧/单位:mm *)
	rGirth_Confirmed_press_dn_PrnRoller			: REAL;(* 确认合压位时候的版辊周长*)
	rGirth_Confirmed_press_dn_NetRoller			: REAL;(* 确认合压位时候的网纹辊周长*)
	rGirth_Confirmed_press_dn_StrRoller			: REAL;(* 确认合压位时候的网纹辊周长*)

//2024.12.05.180655 | bai.zy | 下面两个BYTE类型的标志不用了，合成一个WORD标志，做一下压力相关功能的参数
///////////////////////////////////////////////////////////////////////////////////////////////////		
(* 2021.12.25.083025/hdp/按照2021.12.24试机完成后lyt同步的工程进行注释更新 *)
// 	(*判定规划器和编码器的方向|*)
// 	(*FALSE-编码器方向和规划器方向一致|TRUE-编码器方向和规划器方向不一致*)
// 	bySts_PrfPosAndEncPosDir:BYTE;(*/.0 版辊操作侧压力电机方向
// 									/.1 版辊操作侧压力电机方向确认完成了
// 									/.2 版辊传动侧压力电机方向
// 									/.3 版辊传动侧压力电机方向确认完成了
// 									/.4 网纹辊传动侧压力电机方向
// 									/.5 网纹辊传动侧压力电机方向确认完成了
// 									/.6 网纹辊传动侧压力电机方向
// 									/.7 网纹辊传动侧压力电机方向确认完成了*)
// 
// 	(*实际编码器方向|FALSE-实际编码器方向和规划器方向一致|TRUE-实际编码器方向和规划器方向不一致*)
// 	bySts_PrfPosAndActEncPosDirDir:BYTE;(*/.0 版辊操作侧压力电机方向
// 									/.1 版辊操作侧压力电机方向确认完成了
// 									/.2 版辊传动侧压力电机方向
// 									/.3 版辊传动侧压力电机方向确认完成了
// 									/.4 网纹辊传动侧压力电机方向
// 									/.5 网纹辊传动侧压力电机方向确认完成了
// 									/.6 网纹辊传动侧压力电机方向
// 									/.7 网纹辊传动侧压力电机方向确认完成了*)
// (* end/hdp *)
// (* end/hdp *)
////////////////////////////////////////////////////////////////////////////////////////////////////
	wFlag_PressFun		: WORD;(*.0: 色组安装手轮开关
									.1 版辊压力粗细调
									.2 网辊压力粗细调
									.3 张带压力粗细调*)

	lrAbsEncZeroPos_PrnRoller_Pressure_M		: LREAL;(* 版辊压力电机绝对值位置M侧/零位 *)
	lrAbsEncZeroPos_PrnRoller_Pressure_G		: LREAL;(* 版辊压力电机绝对值位置G侧/零位 *)
	lrAbsEncZeroPos_NetRoller_Pressure_M		: LREAL;(* 网辊压力电机绝对值位置M侧/零位 *)
	lrAbsEncZeroPos_NetRoller_Pressure_G		: LREAL;(* 网辊压力电机绝对值位置G侧/零位 *)

	lrAbsEncLimMin_PrnRoller_Pressure_M			: LREAL;(* 版辊压力电机绝对值位置M侧边界min *)
	lrAbsEncLimMax_PrnRoller_Pressure_G			: LREAL;(* 版辊压力电机绝对值位置G侧边界max *)
	lrAbsEncLimMin_NetRoller_Pressure_M			: LREAL;(* 网辊压力电机绝对值位置M侧边界min *)
	lrAbsEncLimMax_NetRoller_Pressure_G			: LREAL;(* 网辊压力电机绝对值位置G侧边界max *)
	xConfirmAbsEncZeroPosDne_PrnRoller_Pressure_M	: BOOL;(* 版辊压力电机绝对值位置M侧/零位确认完成 *)
	xConfirmAbsEncZeroPosDne_PrnRoller_Pressure_G	: BOOL;(* 版辊压力电机绝对值位置G侧/零位确认完成 *)
	xConfirmAbsEncZeroPosDne_NetRoller_Pressure_M	: BOOL;(* 网辊压力电机绝对值位置M侧/零位确认完成 *)
	xConfirmAbsEncZeroPosDne_NetRoller_Pressure_G	: BOOL;(* 网辊压力电机绝对值位置G侧/零位确认完成 *)

(* 2021.12.29.140315/hdp/lyt *)
	xConfirmload_unloadPosDne_PrnRoller_Pressure_M	: BOOL;(* 版辊压力电机换版位置M侧/确认完成 *)
	xConfirmload_unloadPosDne_PrnRoller_Pressure_G	: BOOL;(* 版辊压力电机换版位置G侧/确认完成 *)
	xConfirmload_unloadPosDne_NetRoller_Pressure_M	: BOOL;(* 网辊压力电机换版位置M侧/确认完成 *)
	xConfirmload_unloadPosDne_NetRoller_Pressure_G	: BOOL;(* 网辊压力电机换版位置G侧/确认完成 *)

	xConfirmDnPosDne_PrnRoller_Pressure_M			: BOOL;(* 版辊压力电机合压位置M侧/确认完成 *)
	xConfirmDnPosDne_PrnRoller_Pressure_G			: BOOL;(* 版辊压力电机合压位置G侧/确认完成 *)
	xConfirmDnPosDne_NetRoller_Pressure_M			: BOOL;(* 网辊压力电机合压位置M侧/确认完成 *)
	xConfirmDnPosDne_NetRoller_Pressure_G			: BOOL;(* 网辊压力电机合压位置G侧/确认完成 *)
	xEnable_arc									: BOOL;(* 套印使能标志 *)
	iMarkTypeId									: INT;(* 标记形式 *)
	iMarkArrangeMode							: INT;(* 标记排列方式 *)
	iGateWidthPhy								: INT;(* 波门宽度/单位:mm *)
	iGateWidthRoundPoints						: INT;(* 波门宽度占据的粗采样点数 *)
	iGateWidthFinePoints						: INT;(* 波门宽度占据的精采样点数 *)
	iGateSa										: INT;(* 波门地址1 *)
	iGateSaEx									: INT;(* 波门地址2 *)
	rAlr_V										: REAL;(* 纵向报警值/pdu通信协议采用x100整型传输 *)
	rAdj_V										: REAL;(* 纵向版修正 *)
	byAvg_V										: BYTE;(* 纵向平均值 *)

	iKp_V										: INT;(* 纵向Kp *)
	iKi_V										: INT;(* 纵向Ki *)
	iKd_V										: INT;(* 纵向Kd *)
	rDeadzoneMin_V								: REAL;(* 纵向不工作区/小/pdu通信协议采用x100整型传输 *)
	rAlr_H										: REAL;(* 横向报警值/pdu通信协议采用x100整型传输 *)
	rAdj_H										: REAL;(* 横向版修正 *)
	byAvg_H										: BYTE;(* 横向平均值 *)

	iKp_H										: INT;(* 横向Kp *)
	iKi_H										: INT;(* 横向Ki *)
	iKd_H										: INT;(* 横向Kd *)
	rDeadzoneMin_H								: REAL;(* 横向不工作区/小/pdu通信协议采用x100整型传输 *)
	rDeadzoneMax_H								: REAL;(* 横向不工作区/大/pdu通信协议采用x100整型传输 *)
	lrPreReg_Length_V						: LREAL;(*纵向预套准料长值|单位:mm|*)
	lrFilmLengthFromPrevUnit				: LREAL;(*存储前色到当前色的压印点间料长|*)	
	lrPreReg_Adjust							: LREAL;(*预套准调整量|*)
	dwFlag_Ctl									: DWORD;(* 控制标志 *)
(*												/bit0.横向开关 *)
(*												/bit1.门内基线 *)
(*												/bit2.T1反极性 *)
(*						dwFlag_Ctl						/bit3.T2反极性 *)
(*												/bit4.纵向调整反 *)
(*												/bit5.横向调整反 *)
(*												/bit6.双波门 *)
(*												/bit7.单标记调整反 *)
(*												/bit8.反印开关*)
(*												/bit9.电眼型号KSC012(A) *)
(*												/bit10.波门锁定 *)
(*												/bit11.T1反极性-第二个门内 *)
(*												/bit12.T2反极性-第二个门内 *)
(*												/bit13.T1小信号 *)
(*												/bit14.T2小信号 *)
(*												/ *)

(*												/bit28.套色方式-曜光/光电眼TRUE为曜光 *)
(*												/bit29.压力电机步进快慢选择/TRUE表示快挡位/2021.12.22.165105/hdp *)
(*												/bit30.KSC-012(A)光电眼两路DO设置-DO0 *)
(*												/bit31.KSC-012(A)光电眼两路DO设置-DO1 *)
(*												/ *)
	dwFlag_Sts									: DWORD;(* 状态标志 *)
(*												/bit0.纵向自动 *)
(*												/bit1.横向自动 *)
(*												/ *)
(*												/bit8.纵向跟任意色 *)
(*												/bit9.横向跟任意色 *)
(*												/bit12.纵向使用跟踪第一色色标计算误差-反之使用前一色色标计算|2023.09.14.102543 *)
(*												/bit13.横向使用跟踪第一色色标计算误差-反之使用前一色色标计算2023.09.14.102543 *)
(*												bit14=1  纵向使用间接跟1色误差反之-默认使用前一色
												bit15=1  横向使用间接跟1色误差-
												
												//bit30+bit31用作精采样数据滤波方式选择||2025.11.15.132316
												//00：均值滤波/01：低通滤波
												
*)
	diPreReg_AdjustVal_H					: DINT;(*预套准修正值-横向|单位:mm|*)
	lrAI_med_CoatingPrn						: LREAL;(*涂布中位值|*)
	xSwitchOn_CoatingPrn					: BOOL;(*涂布开关|*)
	xReverseAdj_CoatingPrn					: BOOL;(*涂布反向调整|*)
	byAdjMode_CoatingPrn					: BYTE;(*涂布调整方式|0~1|*)
	iKp_CoatingPrn							: INT;(*涂布Kp|0~500|*)
	iKi_CoatingPrn							: INT;(*涂布Ki|0~500|*)
	iKd_CoatingPrn							: INT;(*涂布Kd|0~500|*)
	bySensorType_CoatingPrn					: BYTE;(*涂布传感器类型|0~10|*)
	lrAI_CoatingPrn							: LREAL;(*涂布模拟量|*)
	lrGirth_Using_CoatingPrn				: LREAL;(*使用的涂布版周长|*)
	bySignalGain								: BYTE;(* 信号增益控制/2021.10.21.103435 *)
(*												/bit0~bit3.T1的信号增益 *)
(*												/bit4~bit7.T2的信号增益 *)
	xLinkage									: BOOL;(*色组联动*)
	rInversedPrecision						: REAL;(*系统精度2023.6.7.170657*)	
	byCouplingMask							: BYTE;(*耦合开关|
													*.bit0=1: 纵向调整量传递|
													*.bit1=1: 横向调整量传递|
													*.bit2=1: 纵向误差传递|
													*.bit3=1: 横向误差传递|
													|*)
	rHigh_Prn_Roller					:REAL;//轴高
	rHigh_Net_Roller					:REAL;//轴高
	
	rweigth_Prn_Bottom_Confirm					: REAL;//标定位置时这个是版辊中心到版辊和底辊/中心辊切点的横向距离
	rweigth_Prn_Net_Confirm					: REAL;//标定位置时这个是版辊中心到版辊和网辊切点的横向距离
	rweigth_Net_Prn_Confirm					: REAL;//标定位置时这个是版辊中心到版辊和底辊/中心辊切点的横向距离
	rweigth_Net_Load_Confirm					: REAL;//标定位置时这个是版辊中心到版辊和网辊切点的横向距离

	dwColor_Print							: DWORD;//16进制颜色变量
													//16#FFFFFFFF分别代表
													//bit31-bit24:透明度
													//bit23-bit16:RED红色
													//bit15-bit8:GREEN绿色
													//bit7-bit0:BLUE蓝色
	wLines_Net_Roller						: WORD;//网纹辊线数
	rStep_Pressure_Prn_Net					: REAL;
	//2023.12.22.211317}||新增版辊网辊步进1928-1924
//bai.zy | 2024.01.15.105100 | 增加张带合压位换版位标定完成标志------2字节
	xConfirmDnPosDne_StrRoller_Pressure_M			: BOOL;(* 张带辊压力电机合压位置M侧/确认完成 *)
	xConfirmDnPosDne_StrRoller_Pressure_G			: BOOL;(* 张带辊压力电机合压位置G侧/确认完成 *)
//bai.zy | 2024.03.21.130939 | 增加印刷位,32字节   
	lrEncPosPrintDn_Prn_M : LREAL;
	lrEncPosPrintDn_Prn_G : LREAL;
	lrEncPosPrintDn_Net_M : LREAL;
	lrEncPosPrintDn_Net_G : LREAL;
	lrEncPosPrintDn_Str_M : LREAL;
	lrEncPosPrintDn_Str_G : LREAL;
									
//2024.10.21.114530 | bai.zy | 版辊网辊操作侧传动侧平行位置标定值	48字节
	lrEncPosParallel_Prn_M : LREAL;
	lrEncPosParallel_Prn_G : LREAL;
	lrEncPosParallel_Net_M : LREAL;
	lrEncPosParallel_Net_G : LREAL;
	lrEncPosParallel_Str_M : LREAL;
	lrEncPosParallel_Str_G : LREAL;
//2024.10.21.114530 | bai.zy | 版辊网辊操作侧传动侧合压位偏移量	  48字节
	lrPrintPosOffsetDn_Prn_M : LREAL;
	lrPrintPosOffsetDn_Prn_G : LREAL;
	lrPrintPosOffsetDn_Net_M : LREAL;
	lrPrintPosOffsetDn_Net_G : LREAL;
	lrPrintPosOffsetDn_Str_M : LREAL;
	lrPrintPosOffsetDn_Str_G : LREAL;

//2024.10.22.180832||增加	adiEncPos_Start_Virtual_0				: ARRAY [1..MAX_UNIT_NUM] OF DINT; 4字节
	diEncPos_Start_Virtual_0: DINT;
//2024.11.26.125320 | 增加采样减速比		8字节
	diSampleNum : DINT;//采样减速比分子
	diSampleDen : DINT;//采样减速比分母
	
//2024.11.27.154753 | bai.zy | 增加绝对编码器位置,48字节   
	liABSPos_Prn_M : LINT;
	liABSPos_Prn_G : LINT;
	liABSPos_Net_M : LINT;
	liABSPos_Net_G : LINT;
	liABSPos_Str_M : LINT;
	liABSPos_Str_G : LINT;
//2024.12.03.162342 | 增加调试阶段的压力运动	要大幅度运行必须平行 使用平行位置当做最小值  是否合理？？先用吧  --54字节
	axPressLimit_Min : ARRAY[1..3] OF BOOL;
	axPressLimit_Max : ARRAY[1..3] OF BOOL;
	
	lrEncPosLimit_Prn_M_Max : LREAL;
	lrEncPosLimit_Prn_G_Max : LREAL;
	lrEncPosLimit_Net_M_Max : LREAL;
	lrEncPosLimit_Net_G_Max : LREAL;
	lrEncPosLimit_Str_M_Max : LREAL;
	lrEncPosLimit_Str_G_Max : LREAL;

//2025.01.04.131102 | 增加色组印长 -4字节
	rLength_Printing : REAL;		//色组印长 -4字节
(*2025.3.5.153256移植新的套色算法-增加150个字节786-636*)	
	stStArc_Mol_Param	:StArc_Mol_Param;
//2025.03.14.181709 | 带长计算的滤波次数	---2字节
	iBandLengthFilterCnt			: INT;
	
	iCoefOfCoupling_V 	 :INT;
(*2025.3.21.195756||新增*)
	byFollowColorId				: BYTE;
	xWaitFilmLenth_Follow1U		: BOOL;	
	wButtonFun_Lamp					:WORD ;(*HMI界面按钮及指示灯			*)
	wSwitchFun						:WORD ;(*界面开关*)
	
	//Filter原本的wRsv在这里改一下改为从站精采样数据低通滤波频率
	uilowpasscutoff_hz				:UINT;
//2025.11.7.142851先把数据统一了，dwSlaveBtn_HMI分两个word,一个暂时baoliu
//	dwSlaveBtn_HMI					:DWORD;(*界面按钮						*)
(* 2021.12.23.153801/hdp *)
	rLong_Step_Roller_Pressure					: REAL;(* 压力步进值-长步|MM *)
	rShort_Step_Roller_Pressure					: REAL;(* 压力步进值-短步|MM *)
	
	rSV_UnitTemCtl					:REAL ;(*加热设定温度					*)

(*原用户基础工艺开关控制位直接用BIT吧，不用dwCtlBits_UnitBaseCraft了--
通讯改为共用体吧*)	
(*bit0-bit31--2025.8.13.100117*)
	xSwitch_ScraperAuto					: BIT;(*刮刀手自动-bit0*)
	xSwitch_ScraperOn					: BIT;(*刮刀开关bit1*)
	xInterver_ScraperRun				: BIT;(*刮刀开关bit2*)
	xRsv_BIT3							: BIT;(*BIT3预留*)
	xSwitch_InkRollerAuto				: BIT;(*递墨辊手自动bit4*)
	xSwitch_InkRollerCW					: BIT;(*递墨辊正转bit5*)
	xSwitch_InkRollerCCW				: BIT;(*递墨辊反转bit6*)
	xInterver_InkRollerRun				: BIT;(*递墨辊运行bit7*)
	xSwitch_HotWindOn					: BIT;(*热风开关bit8*)
	xInterver_HotWindRun				: BIT;(*热风1运行bit9*)
	xRsv_BIT10							: BIT;(*BIT10预留*)
	xRsv_BIT11							: BIT;(*BIT11预留*)
	xSwitch_HotWindOn_II				: BIT;(*热风开关bit12*)
	xInterver_HotWindRun_II				: BIT;(*热风1运行bit13*)
	xRsv_BIT14							: BIT;(*BIT14预留*)
	xRsv_BIT15							: BIT;(*BIT15预留*)
	xSwitch_HeatingMode_Water			: BIT;(*水加热开关bit16*)
	xSwitch_HeatingMode_Ele				: BIT;(*电加热开关bit17*)
	xSwitch_Heating_I					: BIT;(*加热I档bit18*)
	xSwitch_Heating_II					: BIT;(*加热II档bit19*)
	xSwitch_Heating_III					: BIT;(*加热III档bit20*)
	xRsv_BIT21							: BIT;(*BIT21预留*)
	xRsv_BIT22							: BIT;(*BIT22预留*)
	xErrReset_Scraper					: BIT;(*刮刀故障复位bit23*)
	xErrReset_InkRoller					: BIT;(*递墨故障复位bit24*)
	xErrReset_Hotwind					: BIT;(*热风故障复位bit25*)
	xErrReset_Hotwind_II				: BIT;(*热风2故障复位bit26*)
	xErrReset_ExhAir					: BIT;(*排风故障复位bit27*)
	xSwitch_ExhAir						: BIT;(*排风开关bit28*)
	xInterver_ExhAir					: BIT;(*排风运行bit29*)
	xRsv_BIT30							: BIT;(*BIT30预留*)
	xSwitch_Coolwind					: BIT;(*冷风开关*)
(*基础工艺开关-*)		
	dwCtlBits_UnitBaseCraft					: DWORD;(* 用户基础工艺控制位/加热/递墨辊/刮刀/热风 *)
												(*
												/ .bit0 ~bit3  刮刀
												/	/.bit0 刮刀自动(TRUE)/手动(FALSE)
												/	/.bit1 刮刀开(TRUE)/关(FALSE)
												/	/.bit2 刮刀运行信号/控制变频器启动
												/	/.bit3
												/ .bit4 ~bit7  递墨辊
												/	/.bit4 递墨辊自动(TRUE)/手动(FALSE)
												/	/.bit5 递墨辊正转(TRUE)/关或反转(FALSE)
												/	/.bit6 递墨辊反转(TRUE)/关或正转(FALSE)
												/	/.bit7 递墨辊运行信号/控制变频器启动-与/.4/.5共同确定正转还是反转
												/ .bit8 ~bit11 热风I
												/	/.bit8 热风I开(TRUE)/关(FALSE)
												/	/.bit9 热风I运行信号/控制变频器启动
												/	/.bit10
												/	/.bit11
												/ .bit12~bit15 热风II
												/	/.bit12 热风II开(TRUE)/关(FALSE)
												/	/.bit13 热风II运行信号/控制变频器启动
												/	/.bit14
												/	/.bit15
												/ .bit16~bit23
												/	/ .bit16 加热方式（水）
												/	/ .bit17 加热方式（电）
												/	/ .bit18 I档
												/	/ .bit19 II档
												/	/ .bit20 III档
												/	/ .bit21
												/	/ .bit22
												/ .bit23~bit26
												/	/ .bit23 刮刀故障复位
												/	/ .bit24 递墨故障复位
												/	/ .bit25 热风I故障复位
												/	/ .bit26 热风II故障复位
												/   / .bit27 排风故障复位
												/ .bit28~bit31 /2022.3.23.152646/hdp/预分配好/为和界面作绑定
												/	/ .bit28 排风开(TRUE)/关(FALSE)
												/	/ .bit29 排风运行信号/控制变频器启动
												/	/ .bit30
												(*2022.4.20.091641 移动到此处*)
												/	/ .bit31: 2022.4.20.091632|冷风机开关使能位||
												*)
(* 递墨辊部分 *)
	rHz_UnitInkRoller_ManuallySet			: REAL;(* 递墨辊手动输入频率/0.00~100.00Hz/协议Mailbox直接传输 *)
	rCoeff_UnitInkRoller_Auto				: REAL;(* 递墨辊自动系数/Mailbox双向/主从可设置/ *)
(* 刮刀部分 *)
	rHz_UnitScraper_ManuallySet				: REAL;(* 刮刀手动输入频率/0.00~100.00Hz/协议Mailbox直接传输 *)
	rCoeff_UnitScraper_Auto					: REAL;(* 刮刀自动系数/Mailbox双向/主从可设置/ *)
(* 热风部分 *)
	rHz_UnitHotWind_ManuallySet				: REAL;(* 热风频率/Mailbox双向/主从可设置/ |修改了命名*)
(*2022.3.22.154047 增加*)
	rHz_UnitHotWind_2_ManuallySet			: REAL;(* 热风II频率 |修改了命名*)
(*2022.3.22.154031 增加的*)
(*E<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*)		
	byHotBlower_AO							: BYTE;(*2025.6.14.100346*)
	wAirReturnWindDoorValue					: WORD;(* 回风口风门开度值|输入范围(0~100),默认值:0;|2018.11.27.140852|xie.gc重新修改定义| *)
	wAirExhaustWindDoorValue				: WORD;(* 排风口风门开度值|输入范围(0~100),默认值:0;|2018.11.27.140852|xie.gc重新修改定义| *)									
	
	rGirth_Sam								: REAL;(*套色采样的周长*)
	uiNum_Sam								: UINT;(*套色采样的减速比分子*)
	uiDen_Sam								: UINT;(*套色采样的减速比分m母*)
	rHz_UnitExhaust_ManuallySet				: REAL;(* 排风频率/Mailbox双向/主从可设置/ *)
	
	(*光纤电眼控制相关变量*)
	bySignalSelect					:BYTE;(*光纤电眼信号选择		*)
	//xi.hy//新增	
	rOffset_T1						:REAL;	//T1路光纤偏移
	rSource_Light_T1       			:REAL;  //T1路光纤光源
	rBias_T1			  			:REAL;  //T1路光纤电眼偏置
	rBrightness_Light_T1			:REAL;  //T1路光纤电眼亮度

	rOffset_T2						:REAL;  //T2路光纤偏移
	rSource_Light_T2				:REAL;  //T2路光纤光源
	rBias_T2						:REAL;  //T2路光纤电眼偏置
	rBrightness_Light_T2			:REAL;  //T2路光纤电眼亮度
	
	rK_ArcErr_Lp											: REAL;(*套色误差低通滤波处理的K值*)
	rFilmLengthFromPrevPressUnit							: REAL;(*从前一个合压色到当前色的料长@mm|1色是=0@还未实现呢2024.05.25.130043*)	
	byAve_v_extra							: BYTE;(*界面误差显示平均值*)
	xWaitFilmLenth_FollowPreU:BOOL;(*等料长标志区分为等待前一色*)
	xWaitFilmLength					: BOOL;
	(*新增变量|wang.nt|2025.08.07.204018*)
	rStep_OfChangeGirth :REAL ;  (*涂布版轴修改步幅*)
	uiTimeMs_RollerPressUpKeep : UINT ;      (*压辊双气缸-离压保持时间*)
	//9905界面内容	
	rAxisVelPrf_Coeff1 				: REAL;
	rAxisVelPrf_Coeff2 				: REAL;
	rAxisVelPrf_Coeff3 				: REAL;
	rMargin_Mag_Arc 				: REAL;
	rMargin_Phi_Arc 				: REAL;
	rKp_MolCal 						: REAL;
	rKi_MolCal 						: REAL;
	byCompensateValue_Hor 			: BYTE;
	byMaxAddValue_Total_Hor 		: BYTE;
	rWn_Arc 						: REAL;
	rBw_Arc 						: REAL;
	rDp_Arc 						: REAL;
	rK 								: REAL;
	rA2 							: REAL;
	rA1 							: REAL;
	rA0 							: REAL;
	rG_Periodic 					: REAL;
	rW_Periodic 					: REAL;
	byCnt_Comm2ARM					: BYTE;	
	
	(*2025.8.9.141718|部分位变量处理*)
	xBtnLinkage_HMI			: BIT;(*界面联动按钮*)
	xFlag_InkRollerRisen	: BIT;(*递墨辊升起标志*)
	(*新增变量-开始|wang.nt2025.08.13.165332*)
	xInValidVirtualCnt:BOOL;(*虚拟马盘非法值*)
	byBrakeResistanceAlarm:byte;
	(*新增变量-结束|wang.nt2025.08.13.165332*)
	(*新增工艺参数|2025.08.15.151930*)
	byFreq_ExhaustAir  : BYTE ; 
	byAirInletWindDoorValue : BYTE ; 
	(*新增等料长相关参数|2025.08.20.214206*)
	lrPreReg_ConstVal						: LREAL;(*预套准色组间固定料长部分|单位:mm*)
	//xSkipHeaderSts							: BOOL;(*让料头状态@每次接料都会计算@根据是否打开让料头标志是否输出xSkipHeader*)
	//xSkipHeader								: BOOL;(*让料头*)
	(*预套准相关变量|wang.nt|2025.08.21.162244*)
	uiTurnOverFilmLenth						: UINT;(*翻料架料膜长度@mm*)
	iPhase_Locating						: INT;(*固定相位|2024.9.25.174406|Wang.nt*)
	iPhase_RegisterOk						: INT;(*套准相位|版套印准确的相位<通用相位和相位保存/恢复都可以复用该变量>|*)
	iPhase_FinalUsed						: INT;(*通用相位-最终用相位|*)
	iPhase_InstallPlate						: INT;(*装版相位|*)
	byPhaseState:BYTE;(*/.0 数值有效无效位|./1 数据需要保存标志位|/.4更新成功了|/.5 更新失败了*)(*马克线位置处理-世标*)
	xPreRegisterValid_Manu					: BOOL;(*手动预套有效*)
	iStationId								: INT;(*对应的站号|每次开机和更新系统配置都会重新更新的*)
	xServoOn								: BOOL;(*伺服使能|调用过GT_AxisOn就会被置位,GT_AxisOff会被清除*)
	lrPT_Pos								: LREAL;(*轴PT位置|*)
	diPT_Time								: DINT;(*轴PT时间值|*)
	iPT_Type								: INT;(*轴PT段选择|PT_SEGMENT_NORMAL;PT_SEGMENT_EVEN*)
	xPT_DataValid							: BOOL;(*轴PT数据有效|*)
	wEnableMode_Motor						: WORD;
	byFakeThreshold_V				:BYTE;(*纵向飞点阀值@丝			*)
	byFakeThreshold_H				:BYTE;(*横向飞点阀值@丝			*)
	byOvensAirOutWindDoorValue	: BYTE;
	xSwitch_TempFromEnc_PT1000							: BIT;
	xSwitch_MotorTemp_PT1000_NTC						: BIT;
//2025.12.30.222558新增变量，数据大小变化
(*2022.4.22.114421 排风风门变量添加|10bytes*)
	xUnitExhaustDamperCtl_Auto				: BOOL;(*排风风门控制自动*)
	rUnitExhaustDamperPos_ManuallySet		: REAL;(*排风风门位置手动设置值*)
	rUnitExhaustDamperPos_Cur				: REAL;(*排风风门写入当前位置值*)
	//新增超旭026.02.05.164858
	wButtonAndSwitch_ChaoXu	: WORD;	//.0 匀墨
										//.1 网辊锁轴
										//.2 充气
										//.3 墨盘电磁阀升
										//.4 照明
										//.5 确认修改版周
										//.6 
										//.7
										//.8 
										//.9 
										//.10 
										//.11 合压
										//.12 离压			
										//.13 
										//.14 	
	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
