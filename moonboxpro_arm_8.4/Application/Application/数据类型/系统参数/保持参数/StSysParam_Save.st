(*@CES
Name=StSysParam_Save
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=a67fb49f-2618-48db-a2b1-8f99cf5bed12
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSysParam_Save :
STRUCT
	dwFileVersion								: DWORD;(* 文件版本/后续作为识别参数的规范 *)	
	iCustomerId									: INT;(* 客户id/2021.11.21.191558 *)
	dwEquipmentProf								: DWORD;(* 设备描述标志 *)
												(*bit0:反手机
												bit1:卫星式柔印
												bit2:机组式柔印
												
												bit3:凹印
												bit4:胶印
												bit5:品字形柔印
												bit8:特殊厂家显示界面-根据ID设置了

												bit20：双收双放
												bit21：A放B收
												bit22：收放料伺服控制

*)
	iUnitMaxNum									: INT;(* 最大色组数量 *)
	iCurveViewMaxRange				:INT;(*误差曲线量程上限		*)
	iUid							: INT;(*当前采样操作色组号*)

	(* 有关HMI字体高度设定的 *)
	iTitleTextHeight							: INT:=16;(* 标题字体高度 *)
	iEntryTextHeight							: INT:=12;(* 输入框字体高度 *)
	iLabelTextHeight							: INT:=12;(* 标签字体高度 *)
	iButtonTextHeight							: INT:=10;(* 按钮字体高度 *)
	iMessageTextHeight							: INT:=18;(* 消息字体高度 *)
	iRsvdTextHeight								: INT;(* 保留的字体高度 *)
	byLanguageId								: BYTE;(* 系统操作语言 *)
	byMinutes_ScrSaver							: BYTE;(* 屏幕延时分钟数 *)
	iPointDensity_RS							: INT;	
	wCtlFlag_IndependentSettings				: WORD;
		(* 独立设定参数的标志
		/bit0=1底辊周长独立设置
		/bit1=1版辊周长独立设置
		/bit2=1网辊周长独立设置
		/bit3=1张带辊周长独立设置(保留)
		/bit4=1版辊压力电机丝杆节距独立设置
		/bit5=1版辊压力电机减速比独立设置
		/bit6=1网辊压力电机丝杆节距独立设置
		/bit7=1网辊压力电机减速比独立设置
		/bit8=1底辊减速比独立设置
		/bit9=1版辊减速比独立设置
		/bit10=1网辊减速比独立设置
		/bit11~bit15(保留)
		/ *)
(*原dwControlComplexBits内容不再用，直接拆分为BIT类型，直接不用*)		
		
	xFlag_CancelSafetyGrate						: BIT;(*原dwControlComplexBits.14|取消光栅保护*)
	xSwitch_ArcTest_V							: BIT;(*原dwControlComplexBits.11|纵向快调标志*)
	xSwitch_ArcTest_H							: BIT;(*原dwControlComplexBits.15|横向快调标志*)
	xAllowLinkageChangeInRunning				: BIT;(*bit.24: 伺服电机支持开机状态下的单联动切换*)
	xChangLinkageStsWhenPrint					: bit;(*bit18:印刷状态下可以切换单联动*)
(*	dwControlComplexBits						: DWORD;(* 整机控制位 *)*)
			(*	/以下的整理来自2020.10.15.161719|后续版本严格按照该分配来执行 *)
			(*	/.0 : 置位表示关闭日志存储功能(默认为FALSE) *)
			(*	/.1 : 置位表示整机运动按照电机额定转速中的下限值进行限速(默认TRUE) *)
			(*	/.2 : 置位要求印刷机显示冷风机图标 *)
			(*	/.3 : 置位要求隐藏误差历史曲线的报警数值 *)
			(*	/.4 : 置位要求隐藏误差历史曲线的误差数值 *)
			(*	/.5 : 置位要求隐藏印刷机中的电机温度显示 *)
			(*	/.6 : 置位要求印刷机显示热风机图标 *)
			(*	/.7 : 置位要求界面的综合误差修正能通过界面手动控制横向电机 *)
			(*	/.8 : 置位放料卷径估计使能标志 *)
			(*	/.9 : 置位收料卷径估计使能标志 *)
			(*	/.10: 置位放料裁切窄方波+微分量补偿使能标志 *)
			(*	/.11~13: 保留/2021.12.11.194448/hdp *)
			(*	/.14: 关闭预套准修正量自动计算功能(TRUE=关闭;FALSE=打开自动计算<默认值>)/2021.12.11.194401/hdp修正.bit10重复 *)
			(*	/.15: 置位套色快调使能开关/2021.12.11.194420/hdp修正.bit11重复 *)
			(*	/.16: 界面套色修正步进量0.05(TRUE)/0.01(FALSE)选择/2021.11.4.172153 *)
			(*	/.17: 反复切换状态用于表示触发清除历史误差曲线的请求/2021.11.4.172150 *)
			(*	/.18: 套色报警使能开关/2021.11.4.180006 *)
			(*	/.19: Modbus通讯使能 *)
			(*	/.20: 横向采用步进控制 *)
			(*	/.22: 断料保护功能位 *)
			(*	/.26: 要求从站可以在空转状态下输入距离来进行纵向的快速对版 *)
			(*	/.29: 放料变频自调整使能(TRUE表示自调整) *)
			(*	/.30: DLL的粗采样波形显示采用形式(TRUE=方波;FALSE=模拟)
				/.31: 下伺服开关  *)
	astStMechanicalParamBuf						: ARRAY [1..5] OF StMechanicalParamBuf;(*2019.4.8.152905|新增系统机械参数|*)
	dwCtlSwitchRef						: DWORD;//整机控制位
													//.0: 伺服电机支持开机状态下的单联动切换
													//.1：色组联动采用按钮/开关
													//.2: 同步带长使用平均，True是平均，false是跟某一色
													//.3: 系统张力调整开关
	
//	byHorz_CtrlMode: BYTE;(*横向电机控制方式：0-不控制；1-同步电机；2-步进电机；3-伺服电机；--待续*)
	byRsvdata0							: BYTE;(*2025.9.16.093903*)
	rStepDrivePosPPulse					: REAL;(*步进电机|每个脉冲对应的位置值 mm|default.0.0002||*)
	iStepDrivePulsePRev					: INT;(*步进电机|每一圈对应的脉冲数|default.6000||*)
	iStepDriveSa_Vel					: INT;(*步进电机|步进电机启动速度,不能写0|default.10||*)
	iStepDrivePreReg_Vel				: INT;(*步进电机|步进电机预套准速度|default.50||*)
	iStepDriveManu_Vel					: INT;(*步进电机|步进电机手动调整低速速度|default.20||*)
	iStepDriveAuto_Vel					: INT;(*步进电机|步进电机自动调整速度|default.20||*)
	iStepDriveAccTime					: INT;(*步进电机|步进电机升速时间ms|default.50||*)
	iStepDriveManu_Vel_Fast				: INT;(*步进电机|步进电机手动高速调整速度|default.40||*)
	byOverPercent_RatedRpm				: BYTE;(*2019.4.17.163614|超频比例|相对于电机额定转速|*)
	rCurrent_Limit						: REAL;
	xWorkMode_Inch						: BOOL;(*单运行模式-TURE:按一下走一下听*)
(* 2021.2.4.141533 增加横向控制时的参数|34 bytes/lyt *)
	rHorCtl_PosPPulse					: REAL; (* 横向伺服控制每个脉冲对应的位置值 um|default.0.635| *)
	diHorCtl_PulsePRev					: DINT; (* 伺服电机脉冲/圈|default.131072 *)
	rHorCtl_PreReg_Vel					: REAL; (* 伺服电机预套准速度mm/sdefault.2 *)
	rHorCtl_Manu_Vel					: REAL; (* 伺服电机手动低速度mm/sdefault.0.5 *)
	rHorCtl_Manu_Vel_Fast				: REAL; (* 伺服电机手动高速度mm/sdefault.1 *)
	rHorCtl_Auto_Vel					: REAL; (* 伺服电机自动速度mm/sdefault.0.5 *)
	iHorCtl_Num							: INT; (* 横向控制电机侧|default.60 *)
	iHorCtl_Den							: INT; (* 横向控制传动侧|default.1 *)
	rHorCtl_Pitch						: REAL; (* 横向控制螺距mm|default.5 *)
	iHorCtl_AccDecTime					: INT; (* 加速到自动速度或者自动速度减速到0的时间ms|default.10 *)	
	(*2023.8.29.151955增加报警铃响铃时间*)
	diTimeHold_Prestart				:DINT;
	diTimeHold_Uw_Diam				:DINT;
	diTimeHold_Rw_Diam				:DINT;
	diTimeHold_Rw_Prnlength			:DINT;

	byHotBlowerStopDelayTime					: BYTE;//热风延时关闭时间
	byHeatingOutWay_III							: BYTE;
	iTimeOut_Slave_485_Inverter				: INT;

(*2023.3.27.151009需增加排风、递墨、热风、刮刀485控制使能开关-用于屏蔽相关报警||
新增水加热控制系数-分段*)

	iCofe_TempCtl_30						: INT;(*温度偏差超过30℃-系数-水加热推荐30，蒸汽加热推荐50*)
	iCofe_TempCtl_30_10						: INT;(*温度偏差超过30℃-10℃-系数-水加热推荐40，蒸汽加热推荐100*)
	iCofe_TempCtl_10_5						: INT;(*温度偏差超过10℃-5℃-系数-水加热推荐50，蒸汽加热推荐100*)
	iCofe_TempCtl_5							: INT;(*温度偏差5℃以内-系数-水加热推荐60，蒸汽加热推荐100*)
	iTime_Thres_Water						: INT;(*水加热/蒸汽加热阀门打开时间-用于计算最大调整量*)
	byHeatingMode							: BYTE;(*0:加热模块1：驱动器温控2：温控表*)

	byOverTempValue						: BYTE;(* 2022.3.21.184802/过温值/摄氏度 *)

	byEn_ExtraFun_485						: BYTE;
	iPidAlgorithm_Threshold					: INT;(*PID;(*pid算法介入阈值(相差一定温度后进入pid算法调整)|目标速度-当前速度>该值-*) *)
	iMaxOutValue								: INT;(*最大输出值|长有效的最大值*)
	rKp											: REAL;(*i_rKp:REAL;(*Kp*)      *)
	rKi											: REAL;(*i_rKi:REAL;(*Ki*)    *)
	rKd											: REAL;(*i_rKd:REAL;(*Kd*)    *)
	uiCtrolCycle_Ms							: UINT;(*i_uiCtrolCycle_Ms:UINT;(*控制周期|ms*)   *)
(*2022.10.22.131113*)

(*iWaterValue_Threshold|2022.10.27.184352|水加热阀值*)
	iWaterValue_Threshold					: INT;
	iTempAcc_Threshold						: INT;(*温度上升速率阀值*)
	iDecSV_PV_Threshold					: INT;(*温度阀值2022.10.28.155136*)
	(*2023.12.21.210222||xi.hy||停机后关闭加热使能/停机后关闭热风使能/热风延时关闭时间*)
	xEn_HeatOff_AfterStop:BOOL;
	xEn_HeatAirOff_AfterStop:BOOL;
	rDelayOff_HotAir:REAL;
	(*2024.06.11.102646*)
	iDebugStep								: INT	:=0;(*初始值0||调试向导|2018.12.19.134002||*)
	dwSwitch								: DWORD	:=0;(*初始值0||调试向导|2018.12.19.134002||*)
												(*标志位使用介绍：
												* 控制调试界面确认完成标志
												* bit.0: 调试向导DEBUGSTEP_CONFIG系统配置界面完成标志|
												* bit.1: 调试向导DEBUGSTEP_FUNCTIONSET功能配置完成标志|
												* bit.2: 调试向导DEBUGSTEP_CHECKPARAM1核对参数1完成标志|
												* bit.3: 调试向导DEBUGSTEP_CHECKPARAM2核对参数2完成标志|
												* bit.4: 调试向导DEBUGSTEP_CHECKPARAM3核对参数3完成标志|
												* bit.5: 调试向导DEBUGSTEP_AXISIO色组IO测试完成标志|
												* bit.6: 调试向导DEBUGSTEP_UWRWIO收放料IO测试完成标志|
												* bit.7: 调试向导DEBUGSTEP_ANALOGIO模拟量测试完成标志|
												* bit.8: 调试向导DEBUGSTEP_EXTRAPARAM扩展参数完成|
												|*)	
//2026.5.8.160853调整强度切换标志
												
//2026.4.25.144455增加调整强度切换开关变量|1个字节|2-1=1
	byArcIntensity								: BYTE;
//2026.4.25.144533
	byData:								 BYTE;(*原纵横向飞点阈值*)

	uiMaxVel_UseCalcAcc				: UINT;				
	xUnitPressOneBtn			: BOOL := FALSE; (* 色组合压离压单个按钮标志 *)
	xAllPressOneBtn				: BOOL := FALSE; (* 全体合压离压单个按钮标志 *)
	xPreCutOneBtn_Uw			: BOOL := FALSE; (* 接料准备解除单个按钮标志_放料 *)
	xPreCutOneBtn_Rw			: BOOL := FALSE; (* 接料准备解除单个按钮标志_收料 *)			

	xTypeGetInitDiam						: BOOL;(*方式切换|TRUE=使用停机之前的值|=FALSE 使用固定值*)
	uiMaxDia								: UINT;(*最大的卷径@mm*)
	uiInitDiam_Uw							: UINT;(*初始的卷径@mm|=0 按照200---uiMaxDia取中间值*)
	uiInitDiam_Rw							: UINT;(*初始的卷径@mm|=0 按照200---uiMaxDia取中间值*)
	xAutoSetArcCtlWay						: BOOL;(*自动设置耦合方式@根据是否隔色控制*)
	byCouplingType:BYTE:=0;(*耦合方式@=0原来的直接传递的逻辑@不输出耦合量
									 @=1新修改的按照比例定位传递。总量100%@从o_aiCouplingValue_A输出
									 @=2新修改的按照比例定位传递。总量根据输入的耦合值@从o_aiCouplingValue_A输出
									 @=3调整引起张力变化需要直接传递一定比例-等到达下一色取消这部分传递o_aiCouplingValue_T输出、
									   等待固定料长传递之前调整的量o_aiCouplingValue_A输出*)	
(*新增加参数|wang.nt|2025.08.07.143540*)
	wMachineArchitectureRef : WORD;(*机器架构描述*)		
	iPromptMsgId : INT;(*提示信息ID（报警代码）*)
	byHorzCtlMode : BYTE;(*横向控制方式-同步-步进-伺服*)
	byCheckTimeToTips_BrakeResistance : BYTE;(*制动电阻访问超限提示时间*)
	byCheckTimeToEStop_BrakeResistance : BYTE;(*制动电阻访问超限急停时间*)
	byAccessTimes_BrakeResistance : BYTE;(*制动电阻报警限制*)
	byAlarmHold_VOL_Uw : BYTE;(*放料没料响应时间*)
	byAlarmHold_PrnLength :BYTE;(*收料印长报警响应时间*)
	rOpenThr_Ele : REAL;(*电加热开启*)
	rCloseThr_Ele : REAL;(*电加热关闭*)
	rDealValue_Water : REAL;(*水加热死区*)
	iHeatingDebugValue_Water : INT;(*测试开度*)
	diStepDriveDebugPulse : DINT;(*测试脉冲数*)
	rStepDriveDebugPulse_PosAct :REAL;(*测试距离*)
	iStepDriveDebugNum : INT;(*测试色组号*)
	rHz_MainExhaust_ManuallySet : REAL;(*主排风设定频率*)
	byFreq_I_ExhaustAir : BYTE;(*排风一档频率*)
	byFreq_II_ExhaustAir : BYTE;(*排风二档频率*)
	byFreq_III_ExhaustAir : BYTE;(*排风三档频率*)
	(*9905界面参数*)
	byPseudoRandomRoundTimes:BYTE;
	rPseudoRandomAmplitude:REAL;
	bySetTestPid_IfOf:BYTE;
	by10vSignalCoef:BYTE;
	rCompensateGirthWhenAccing_If	:REAL;
	rCompensateGirthWhenAccing_Of	:REAL;
	byArcDeCoupleStepTest			:BYTE;
	iCustomerLogoOffsetX			:INT;
	byGuardrialColor_R				:BYTE;
	byGuardrialColor_G				:BYTE;
	byGuardrialColor_B				:BYTE;
	iLedFuncId						:INT;
	iSetHmiResValue					:INT;
	wRunningTime_Day				:WORD;
	byRunningTime_Hour				:BYTE;
	byRunningTime_Min				:BYTE;
	byRunningTime_Sec				:BYTE;
	byArcIntensity_W				:BYTE;
	byArcIntensity_M				:BYTE;
	byArcIntensity_S				:BYTE;
	byMotorOverTempValue_UseEncTemp	:BYTE;
	byRemainSpaceNum_PTCTL			:BYTE;
	rSpeed_SCoeff_Type789			:REAL;
	byMaxPulseOut_16dIO				:BYTE;
	bySysSamplePrecision			:BYTE;
	byArcAdjValueDealType			:BYTE;
	byArcErrLimitToCtl_P			:BYTE;
	byArcErrLimitToCtl_I 			:BYTE;
	byMaxPulseOut_Module			:BYTE;
	byArcFineSampleType				:BYTE;
	byArcPidGetType 				:BYTE;
	rFilmLenth_Eyes					:REAL;
	uiArcSysDelayTime_ms           	:UINT;
	byParamIndex_Huang				:BYTE;
	uiControllerVel_Huang			:UINT;
	byDeCoupleArcNum				:BYTE;
				

(*部分开关-直接用BIT-先放这里2025.8.8.151629*)	
	xSwitch_PreHotEn_Print					 :BIT;(*预热印刷激活开关*)
    xSwitch_ExhAir_Limit_HotWind			 :BIT;(*排风限制热风开关*)
    xSwitch_ExhAir_Limit_Run				 :BIT;(*排风限制开机开关*)
    xSwitch_CommEn_WatchDevice_Tcp			 :BIT;(*TCP-外部监控设备开关*)
    xSwitch_CommEn_WatchDevice_485			 :BIT;(*485-外部监控设备开关*)
    xSwitch_CommEn_1U_485					 :BIT;(*1色人机通讯开关*)
    xSwitch_CommEn_485						 :BIT;(*485通讯开关*)
    xSwitch_CommEn_485_Exh					 :BIT;(*排风485通讯开关*)
    xSwitch_CommEn_485_Scraper				 :BIT;(*刮刀485通讯开关*)
    xSwitch_CommEn_485_InkRoller			 :BIT;(*递墨辊485通讯开关*)
    xSwitch_CommEn_485_HotWind				 :BIT;(*热风485通讯开关*)
    xSwitch_ArcIntensityBtn_Hmi				 :BIT;(*手动调节随速度走开关*)
    xSwitch_PrnRatioIndividual_Setting		 :BIT;(*色组版辊减速比单独设置开关*)	
    xSwitch_NetRatioIndividual_Setting		 :BIT;(*色组网辊减速比单独设置开关*)	
    xSwitch_BottomRatioIndividual_Setting	 :BIT;(*色组底辊减速比单独设置开关*)	
    xSwitch_StepDriveDebugRun				 :BIT;(*横向步进电机测试执行开关*)

	xSetProPointEn										: BIT;
	xUseMaxTimeAsSBegin_InLowSpeed      				: BIT;
	xPseudoRandomEn                     				: BIT;
	xPseudoRandomStart                  				: BIT;
	xEn_RevLimit                        				: BIT;
	xSaveFineSampleData_ToArc           				: BIT;
	xReqSetLedFunc                      				: BIT;
	xSetHmiResolution                   				: BIT;
	xPopupWindowVisible                 				: BIT;
	xInitArcErr_AjdImmediately          				: BIT;
	xPhaseAutoRecoveryEn                				: BIT;
	xKeepServo_PreRegisterDne           				: BIT;
	xUseIfVel_Uw                        				: BIT;
	xKeepServo_Stop                     				: BIT;
	xAxisPrfVelEn                       				: BIT;
	xUseGc_PID_2025                     				: BIT;
	xFlag_Follow_1U_Double_V            				: BIT;
	xArcErrCorrectIsRev_V               				: BIT;
	xAutoSetSampleType                  				: BIT;
	xGetSampleTypeBtn                   				: BIT;
	byKadj_SetType				: BYTE;
	xUseArcErr_Lp				: BOOL;(*套色误差使用低通*)	
	byUseArcAccOrDecCompensate	: BYTE;
	
	(*新增参数-开始|wang.nt|2025.08.12.141656*)
	byAlarmHold_CutDne_Uw		: BYTE := 3; (* 放料接完料后报警持续时间@单位s *)
	(*新增参数-结束|wang.nt|2025.08.12.141656*)
	(*新增工艺参数|2025.08.15.152053*)
	iDelayMsec_HeatBlower :INT ;//热风停止延时
	xAirExhaustLimit:BOOL;(*排风限制开机*)
	(*2025.8.19.211236*)
	byTypeFollow_Arc	: BYTE;	
		
	iRemaindPartCouplingPos	: INT:=0;(*剩余部分的耦合位置@距离总幅数
														   @=1 到达下一色前第一幅
														   @=2 到达下一色前第二幅*)		
	(*新增等料长参数|wang.nt|2025.08.20.221817*)
	dwAxis_SkipTheHeader				: DWORD;(*让料头标志| 位标志bit0=机组1,...,bit31=机组32*)
	(*新增预套准参数|2025.08.23.091002*)
	byMechanicalTypeId					: BYTE;(*1摆臂\2直压\3pvc直压|*)
	xFilpSwitch:BOOL;(*翻转架开关*)
(*全局*)	
(*要更新数据结构2025.10.13.134149--这些全部要加到金刚读写通讯区域*)
	(*2025.6.9.142100+油墨槽控制@20BYTES*)
	xInkGrooveCtlEn						: BOOL;(*油墨槽控制使能*)
	xInkGrooveCtlDirRev					: BOOL;(*油墨槽运动方向取反*)
	iInkGroovePulsePRev					: INT;(*一圈的脉冲数*)
	iInkGrooveSa_Vel					: INT;(*油墨槽控制|油墨槽控制启动速度,不能写0|default.10||*)
	iInkGroove_Vel						: INT;(*油墨槽控制|油墨槽控制手动调整速度|default.20||*)
	iInkGrooveAccTime					: INT;(*油墨槽控制|油墨槽控制升速时间ms|default.50||*)
	rInkGroovePosPPulse					: REAL;(*油墨槽控制|每个脉冲对应的位置值 mm|default.0.0002||*)
	iInkGrooveMoveDis_Max				: INT;(*油墨槽控制|最大运行的距离 mm|*)			

	(*增加排风三档频率|2022.5.5.154339*)
	(*增加了热风三档频率|2022.5.6.083338*)
	byFreq_I_AirHot						: BYTE;
	byFreq_II_AirHot					: BYTE;
	byFreq_III_AirHot					: BYTE;				
//2025.10.20.145004增加排风控制相关一些变量72-5=67
	byExhaustMode				: BYTE;	
	byExhaustLinkageNum			: BYTE;	
	byFreqMax_ExhaustAir		: BYTE;	
	byFreqMin_ExhaustAir		: BYTE;	
	byCoefExhaust				: BYTE;								   
	xArcFollowAnyAxis			: BOOL;
	byTypeFollow1UEn			: BYTE;
	xFlag_Follow_1U_Double_H	: BOOL;
	byModbusNum_Max							: BYTE;

END_STRUCT
END_TYPE

{IMPLEMENTATION}
