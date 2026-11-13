(*@CES
Name=StParam_Diamonds_WrRd
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=15a28b25-6b83-4126-9bba-1eec8961298e
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Diamonds_WrRd :
STRUCT
	iCustomerId										: INT;(*客户ID						*)
	dwEquipmentProf             					: DWORD  ;(*设备描述*)
	iUnitMaxNum                 					: INT  ;(*最大色组数*)
	iCurveViewMaxRange          					: INT  ;(*误差曲线量程上限*)
	iTitleTextHeight            					: INT  ;(*标题字体高度*)
	iEntryTextHeight            					: INT  ;(*输入框字体高度*)
	iLabelTextHeight            					: INT  ;(*标签字体高度*)
	iButtonTextHeight           					: INT  ;(*按钮字体高度*)
	iMessageTextHeight          					: INT  ;(*消息字体高度*)
	byLanguageId                					: BYTE  ;(*语言设置*)
	byMinutes_ScrSaver          					: BYTE  ;(*屏保延时*)
	wMachineArchitectureRef     					: WORD  ;(*机器架构描述*)
	iPromptMsgId                					: INT  ;(*提示信息ID（报警代码）*)
	byHorzCtlMode									: BYTE;(*横向控制方式-同步-步进-伺服*)
	byCheckTimeToTips_BrakeResistance				: BYTE;(*制动电阻访问超限提示时间*)
	byCheckTimeToEStop_BrakeResistance				: BYTE;(*制动电阻访问超限急停时间*)
	byAccessTimes_BrakeResistance					: BYTE;(*制动电阻报警限制*)
	byAlarmHold_VOL_Uw								: BYTE;(*放料没料响应时间*)
	byAlarmHold_PrnLength							: BYTE;(*收料印长报警响应时间*)
	byHeatingOutWay_III								: BYTE;(*三档调整方式-只调最低档、只调最高档、三档同时调*)	
	byHeatingMode									: BYTE;(*温控设置方式切换*)
	rOpenThr_Ele                                 	: REAL;(*电加热开启*)
	rCloseThr_Ele                             		: REAL;(*电加热关闭*)
	rDealValue_Water                          		: REAL;(*水加热死区*)
	iMaxOutValue                              		: INT;(*最大输出*)
	iHeatingDebugValue_Water                  		: INT;(*测试开度*)
	rKp                                       		: REAL;(*KP*)
	rKi                                       		: REAL;(*KI*)
	rKd                                       		: REAL;(*Kd*)
	iTime_Thres_Water                         		: INT;(*阀门打开时间*)
	iCofe_TempCtl_30                          		: INT;(*控制阈值1*)
	iCofe_TempCtl_30_10                       		: INT;(*控制阈值2*)
	iCofe_TempCtl_10_5                        		: INT;(*控制阈值3*)
	iCofe_TempCtl_5                           		: INT;(*控制阈值4*)
	iWaterValue_Threshold                     		: INT;(*水电阈值*)
	uiInitDiam_Uw									: UINT;(*放料初始卷径*)
	uiInitDiam_Rw									: UINT;(*收料初始卷径*)
	diStepDriveDebugPulse							: DINT;(*测试脉冲数*)
	rStepDriveDebugPulse_PosAct 					: REAL;(*测试距离*)
	iStepDriveDebugNum          					: INT;(*测试色组号*)
	rStepDrivePosPPulse         					: REAL;(*单位脉冲距离*)
	iStepDrivePulsePRev         					: INT;(*每圈脉冲数*)
	iStepDriveSa_Vel            					: INT;(*启动速度*)
	iStepDrivePreReg_Vel        					: INT;(*预套准速度*)
	iStepDriveManu_Vel          					: INT;(*手动低速*)
	iStepDriveManu_Vel_Fast     					: INT;(*手动高速*)
	iStepDriveAuto_Vel          					: INT;(*自动速度*)
	iStepDriveAccTime           					: INT;(*升速时间*)		
	rHz_MainExhaust_ManuallySet						: REAL;(*主排风设定频率*)
	byFreq_I_ExhaustAir								: BYTE;(*排风一档频率*)
	byFreq_II_ExhaustAir							: BYTE;(*排风二档频率*)
	byFreq_III_ExhaustAir							: BYTE;(*排风三档频率*)
								
	stBitStWrRd_Switch_Machine						: StWrRd_Switch_Machine;(*总12字节*)
//2025.7.3.175755以上总共125字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////

(*2025.8.25.152044||niu.j|增加当前波形通道选择*)
	iUid_Choose											: INT;
(*全局变量增加油墨槽控制相关2025.10.13.134322总共15字节||93-15=78*)	
	(*2025.6.9.142100+油墨槽控制@15BYTES*)
	xInkGrooveCtlEn						: BIT;(*油墨槽控制使能*)
	xInkGrooveCtlDirRev					: BIT;(*油墨槽运动方向取反*)
	xInkGrooveCali_Hmi					: BIT;(*油墨槽标定按钮*)
	//这里还有5个bit位
	iInkGroovePulsePRev					: INT;(*一圈的脉冲数*)
	iInkGrooveSa_Vel					: INT;(*油墨槽控制|油墨槽控制启动速度,不能写0|default.10||*)
	iInkGroove_Vel						: INT;(*油墨槽控制|油墨槽控制手动调整速度|default.20||*)
	iInkGrooveAccTime					: INT;(*油墨槽控制|油墨槽控制升速时间ms|default.50||*)
	rInkGroovePosPPulse					: REAL;(*油墨槽控制|每个脉冲对应的位置值 mm|default.0.0002||*)
	iInkGrooveMoveDis_Max				: INT;(*油墨槽控制|最大运行的距离 mm|*)					
	
//485通讯超时时间|最大MODBUS设备---78-3=75
	iTimeOut_Slave_485_Inverter				: INT;	
	byModbusNum_Max							: BYTE;
	
//增加三档热风频率3字节75-3=72	
	byFreq_I_AirHot						: BYTE;
	byFreq_II_AirHot					: BYTE;
	byFreq_III_AirHot					: BYTE;			
//2025.10.20.145004增加排风控制相关一些变量72-5=67
	byExhaustMode				: BYTE;	
	byExhaustLinkageNum			: BYTE;	
	byFreqMax_ExhaustAir		: BYTE;	
	byFreqMin_ExhaustAir		: BYTE;	
	byCoefExhaust				: BYTE;	
	

//2025.12.30.225646占用1个字节放电机超频系数|67-1=66
	byOverPercent_RatedRpm				: BYTE;(*2019.4.17.163614|超频比例|相对于电机额定转速|*)
//2025.12.30.225905占用2个字节放最大卷径||66-2=64
	uiMaxDia								: UINT;(*最大的卷径@mm*)
//占用1个字节放放料裁切后报警时间设定单位s||64-1=63
	byAlarmHold_CutDne_Uw		: BYTE ; (* 放料接完料后报警持续时间@单位s *)	
	abyRsvData_1										: ARRAY [1..63] OF BYTE;
(*95-93||2025.8.25.152438*)
//2025.10.15.141047||取出220字节用于通讯机械参数|niu.j||660-220=440
//	stStWrRd_MechanicalType				:StWrRd_MechanicalType;//总共220字节
//2026.8.14.094620机械结构放后面
	abyRsvData_23										: ARRAY [1..220] OF BYTE;

//2026.5.8.161333增加全自动套印
	abyRsvData_2										: ARRAY [1..220] OF BYTE;
//2026.4.25.140631从上面取220字节放全自动套印相关内容||剩余220
	arWidth_Mark_Max			: ARRAY [1..2] OF REAL ;//	: ARRAY [1..2] OF REAL;(*单个色标最大宽度0.1mm（0~20mm) *)
	arWidth_Mark_Min			: ARRAY [1..2] OF REAL ;//	: ARRAY [1..2] OF REAL;(*单个色标最小宽度0.1mm（0~20mm) *)
	arMaxGap					: ARRAY [1..2] OF REAL ;//	: ARRAY [1..2] OF REAL;(*最大间隙，0.1mm（0~20mm) *)
	arSimilarityThreshold		: ARRAY [1..2] OF REAL ;//	: ARRAY [1..2] OF REAL;(*相似度阈值40%-70%, 0~100*)
	abyMeanOffset				: ARRAY [1..2] OF BYTE ;//	: ARRAY [1..2] OF BYTE; (*均值偏移 越大越找不到小色标，太小会出现较多信号导致直接失败 0~255*)
	abySignalType				: ARRAY [1..2] OF BYTE ;//	: ARRAY [1..2] OF BYTE;(*信号类型，1北人标，暂不支持其他标 0~255*)
	arOuterCoff					: ARRAY [1..2] OF REAL ;//	: ARRAY [1..2] OF REAL;//=1.2;     //外滑窗系数 real 0.5~2
    arInnerCoff					: ARRAY [1..2] OF REAL ;//	: ARRAY [1..2] OF REAL;//=0.3;		//内滑窗系数 real 0.2~byOuterCoff
	arFiberMove					: ARRAY [1..2,1..2] OF REAL ;//	: ARRAY [1..2,1..2] OF REAL;//:= [-3,6];//光纤粗调移动距离 两个限制-10,10
	arModeMsg					: ARRAY [1..2,1..15] OF REAL ;//	: ARRAY [1..2,1..15] OF REAL:		//模版信息 0.1mm
	abyRsvData_22				: ARRAY [1..32] OF BYTE ;//	: ARRAY [1..32] OF BYTE;

//2026.4.25.140701增加结束
/////////////////////////////////////////////////////2025.7.3.175755新增755字节，总大小880byte//////////////////////////////////////////////////////////////	
	
	arGirth_AxiaA_Uw            					: ARRAY [1..2] OF REAL  ;(*放料A轴周长*)
	arGirth_AxiaB_Uw            					: ARRAY [1..2] OF REAL  ;(*放料B轴周长*)
	arGirth_AxiaA_Rw            					: ARRAY [1..2] OF REAL  ;(*收料A轴周长*)
	arGirth_AxiaB_Rw            					: ARRAY [1..2] OF REAL  ;(*收料B轴周长*)
	arGirth_Pu                  					: ARRAY [1..2] OF REAL  ;(*版周长*)
	arTaper_Begin_Rw            					: ARRAY [1..2] OF REAL  ;(*收料锥度-大张力*)
	arTaper_End_Rw              					: ARRAY [1..2] OF REAL  ;(*收料锥度-小张力*)
	arVel_Tar                   					: ARRAY [1..2] OF REAL  ;(*目标速度*)
	aiTime_AutoAcc              					: ARRAY [1..2] OF INT  ;(*自动加速时间（S）*)
	aiTime_AutoDec              					: ARRAY [1..2] OF INT  ;(*自动减速时间（S）*)
	aiTime_ManuAcc              					: ARRAY [1..2] OF INT  ;(*手动加速时间（S）*)
	aiTime_ManuDec              					: ARRAY [1..2] OF INT  ;(*手动减速时间（S）*)
	aiTime_FastStop             					: ARRAY [1..2] OF INT  ;(*快停时间（S）*)
	aiTime_Estop                					: ARRAY [1..2] OF INT  ;(*急停时间（S)*)	
	adwPrnLen_Alarm									: ARRAY [1..2,1..3] OF DWORD;(*印长报警*)
						
	astBitStWrRd_Switch_Grp							: ARRAY [1..2] OF StWrRd_Switch_Grp;(*总22*2字节*)
	adwDiamAlarm_Uw									: ARRAY [1..2] OF DWORD;(*放料报警卷径*)
	arFilmThickNess_Using							: ARRAY [1..2] OF REAL;(*料膜厚度手动输入值*)
	arInitTaper_Hmi_Rw								: ARRAY [1..2] OF REAL;(*收料起始气压*)
	auiVel_CommonlyUsed								: ARRAY [1..2,1..3] OF UINT;(*常用速度*)
	aiCutDneResetPidMultiple_Uw						: ARRAY [1..2] OF INT;(*裁切PID放大系数-放料*)
	aiCutDneResetPidRemainTime_Uw					: ARRAY [1..2] OF INT;(*裁切PID放大保持时间-放料*)
	aiCutDneResetPidDefaultTime_Uw					: ARRAY [1..2] OF INT;(*裁切PID放大恢复时间-放料*)
	aiCutDneResetPidMultiple_Rw						: ARRAY [1..2] OF INT;(*裁切PID放大系数-收料*)
	aiCutDneResetPidRemainTime_Rw					: ARRAY [1..2] OF INT;(*裁切PID放大保持时间-收料*)
	aiCutDneResetPidDefaultTime_Rw					: ARRAY [1..2] OF INT;(*裁切PID放大恢复时间-收料*)
	abyAutoMaticCutMode_uw							: ARRAY [1..2] OF BYTE;(*放料自动接料方式-剩余卷径/剩余米数*)
//2025.7.3.175755以上总共218字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
//z占用了两个字节位置用来放牵引断料判断阀值2025.12.30.220228||2-2=0
	abyIn_outFeed_ThresCoff							: ARRAY [1..2] OF BYTE;(*断料保护牵引判断阀值|原LREAL型，改为BYTE吧*)
	//abyRsvData_3										: ARRAY [1..2] OF BYTE;
/////////////////////////////////////////////////////2025.7.3.175755新增2字节，总大小220byte//////////////////////////////////////////////////////////////	
	
	arDia_PaperRoller_Uw							: ARRAY [1..2] OF REAL;(*放料纸筒直径*)
	auiAutoMaticCutDia_Uw							: ARRAY [1..2] OF UINT;(*放料剩余卷径*)
	auiAutoMaticCutMeters_Uw						: ARRAY [1..2] OF UINT;(*放料剩余米数*)
	abyAutoMaticCutMode_Rw							: ARRAY [1..2] OF BYTE;(*收料自动接料方式-收料米数/整机料长*)
	auiAutoMaticCutMeters_Rw						: ARRAY [1..2] OF UINT;(*收料米数*)
	abyLenth_Machine								: ARRAY [1..2] OF BYTE;(*整机料长*)
	arPressure_Max									: ARRAY [1..2] OF REAL;(*涂布压力传感器最大标定压力值*)
	arHz_MainExhaust_ManuallySet					: ARRAY [1..2] OF REAL;(*主排风手动频率*)
	aiMarkId										: ARRAY [1..2] OF INT;(*色斑形式*)
	aicurMarkArrangeId								: ARRAY [1..2] OF INT;(*色标顺序*)
	abyTriMark_SideC								: ARRAY [1..2] OF BYTE;(*梯标直边宽度1mm*)
	abyTriMark_SideB								: ARRAY [1..2] OF BYTE;(*梯标直边宽度2mm*)
	arAI_med_Uw										: ARRAY [1..2] OF REAL;(*放料摆臂中位值/rAI_med_Uw*)
	arAI_med_Rw										: ARRAY [1..2] OF REAL;(*收料摆臂中位值/rAI_med_Rw*)
	arAI_med_If										: ARRAY [1..2] OF REAL;(*放牵摆臂中位值/rAI_med_If*)
	arAI_med_Of										: ARRAY [1..2] OF REAL;(*收牵摆臂中位值/rAI_med_Of*)
	arRatedRpm_Uw									: ARRAY [1..2] OF REAL;(*额定转速*)
	arRatedFreq_Uw									: ARRAY [1..2] OF REAL;(*额定频率*)
	arUpperFreq_Uw									: ARRAY [1..2] OF REAL;(*上限频率*)
	arRatedRpm_Rw									: ARRAY [1..2] OF REAL;(*额定转速*)
	arRatedFreq_Rw									: ARRAY [1..2] OF REAL;(*额定频率*)
	arUpperFreq_Rw									: ARRAY [1..2] OF REAL;(*上限频率*)
	arRatedRpm_If									: ARRAY [1..2] OF REAL;(*额定转速*)
	arRatedFreq_If									: ARRAY [1..2] OF REAL;(*额定频率*)
	arUpperFreq_If									: ARRAY [1..2] OF REAL;(*上限频率*)
	arRatedRpm_Of									: ARRAY [1..2] OF REAL;(*额定转速*)
	arRatedFreq_Of									: ARRAY [1..2] OF REAL;(*额定频率*)
	arUpperFreq_Of									: ARRAY [1..2] OF REAL;(*上限频率*)	
	arDiamTaper_Begin_Rw							: ARRAY [1..2] OF REAL;(*锥度起始直径*)
	arDiamTaper_End_Rw                              : ARRAY [1..2] OF REAL;(*锥度结束直径*)
	arGirth_3Inch                                   : ARRAY [1..2] OF REAL;(*收料3吋默认周长*)
	arGirth_6Inch                                   : ARRAY [1..2] OF REAL;(*收料6吋默认周长*)	
//2025.7.3.175755以上总共212字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
//	abyRsvData_4										: ARRAY [1..8] OF BYTE;
//2025.9.15.203814|niu.j|摆臂类型放到双向参数
	abyAIType_Uw										: ARRAY [1..2] OF BYTE;(*放料摆臂类型/byAIType_Uw*) 
	abyAIType_Rw										: ARRAY [1..2] OF BYTE;(*收料摆臂类型/byAIType_Rw*) 
	abyAIType_If										: ARRAY [1..2] OF BYTE;(*放牵摆臂类型/byAIType_If*) 
	abyAIType_Of										: ARRAY [1..2] OF BYTE;(*收牵摆臂类型/byAIType_Of*) 		
/////////////////////////////////////////////////////2025.7.3.175755新增8字节，总大小220byte//////////////////////////////////////////////////////////////	
	
	arKpid_SVol_Uw									: ARRAY [1..2,1..3] OF REAL;(*放料PID设定*)
	arKpid_SVol_Rw									: ARRAY [1..2,1..3] OF REAL;(*收料PID设定*)
	arKpid_If										: ARRAY [1..2,1..3] OF REAL;(*放牵PID设定*)
	arKpid_Of										: ARRAY [1..2,1..3] OF REAL;(*收牵PID设定*)
	abyCoef_Stiffen_Uw                              : ARRAY [1..2] OF BYTE;(*放料拉料系数*)
	abyCoef_Stiffen_Rw                              : ARRAY [1..2] OF BYTE;(*收料拉料系数*)
	abyInitialSpd_Stiffen                           : ARRAY [1..2] OF BYTE;(*拉料初始速度*)
	abyStationIdDst_VirEnc                          : ARRAY [1..2] OF BYTE;(*异站编码器目标站好*)
	abyDelayTime_DiaCompensateWhenCutDne_Uw			: ARRAY [1..2] OF BYTE;(*放料裁切延时*)
	abyVelSa_DiamCompensate_Uw						: ARRAY [1..2] OF BYTE;(*放料补偿速度*)
	abyDelayTime_DiaCompensateWhenCutDne_Rw			: ARRAY [1..2] OF BYTE;(*收料裁切延时*)
	abyVelSa_DiamCompensate_Rw						: ARRAY [1..2] OF BYTE;(*收料补偿速度*)
	arRatedRpm_Scraper								: ARRAY [1..2] OF REAL;(*刮刀额定转速*)
	arRatedFreq_Scraper	                			: ARRAY [1..2] OF REAL;(*刮刀额定频率*)
	arUpperFreq_Scraper                 			: ARRAY [1..2] OF REAL;(*刮刀上限频率*)
	arMinFreq_Scraper                   			: ARRAY [1..2] OF REAL;(*刮刀最小频率*)
	arMaxFreq_Scraper                   			: ARRAY [1..2] OF REAL;(*刮刀最大频率*)
	aiRatio_ScraperContrastToPrintRoller			: ARRAY [1..2] OF INT;(*刮刀调整比例*)
	aiVelSa_ScraperRun                  			: ARRAY [1..2] OF INT;(*刮刀启动速度*)
	aiDen_ScraperMotor                  			: ARRAY [1..2] OF INT;(*刮刀减速比分母*)
	aiNum_ScraperMotor                  			: ARRAY [1..2] OF INT;(*刮刀减速比分子*)
	aiUpperFreq_InkRoller               			: ARRAY [1..2] OF INT;(*递磨辊上限频率*)
	aiVelSa_InkRollerRun                			: ARRAY [1..2] OF INT;(*递磨辊启动速度*)
	aiFrq_InkRollerMin                  			: ARRAY [1..2] OF INT;(*递磨辊最小频率*)
	aiFrq_InkRollerMax                  			: ARRAY [1..2] OF INT;(*递磨辊最大频率*)
	aiVel_InkRollerMin                  			: ARRAY [1..2] OF INT;(*递磨辊最小速度*)
	aiVel_InkRollerMax                  			: ARRAY [1..2] OF INT;(*递磨辊最大速度*)
//2025.7.3.175755以上总共192字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
	aiTime_Stop										: ARRAY [1..2] OF INT;(* 停机时间/单位:s *)
//2025.9.16.124645增加停机时间28-4=24
//2025.10.13.165248|增加伪随机测试使能|24-2=22
	abyPseudoRandomId								: ARRAY [1..2] OF BYTE;(*=0 放牵|=1 放料|=2 收料 |=3 收牵*)
//2025.10.14.110518增加料膜选择22-2=20
	abyFilmType					: ARRAY [1..2] OF BYTE;
//2025.10.14.110829增加4*2||20-8=12
	auiUseTime_Diam_Min_Uw							: ARRAY [1..2] OF UINT;(*使用时变的最小卷径|mm@2024.05.14.080937*)
	auiUseTime_Diam_Min_Rw							: ARRAY [1..2] OF UINT;(*使用时变的最小卷径|mm@2024.05.14.080937*)
//2025.12.30.223759增加收放料伪随机步骤设置|12-4=8	
	abySetTestPid_Uw								: ARRAY [1..2] OF BYTE;(*放料伪随机步骤设置*)
	abySetTestPid_Rw								: ARRAY [1..2] OF BYTE;(*放料伪随机步骤设置*)	
	
//2025.12.30.225324||占用6个字节放计米清零计次吧||8-6=2
	abyClrPrnLenCount								: ARRAY [1..2,1..3] OF BYTE; (* 主界面记米清零点击计数 *)	

//2026.5.12.160727增加通讯速度规划方式逻辑|直接占用abyRsvData_5
	abyAutoAccDecCurve								: ARRAY [1..2] OF BYTE;	
//	abyRsvData_5										: ARRAY [1..2] OF BYTE;
/////////////////////////////////////////////////////2025.7.3.175755新增28字节，总大小220byte//////////////////////////////////////////////////////////////	
	
	aiPreHotRoller_Velocity_PreHot      			: ARRAY [1..2] OF INT;(*预热辊额定转速*)
	arStandardFreq_HotRoller_PreHot           		: ARRAY [1..2] OF REAL;(*预热辊额定频率*)
	arUpperFreq_HotRoller_PreHot              		: ARRAY [1..2] OF REAL;(*预热辊上限频率*)
	arCoeff_HotRoller_PreHot                  		: ARRAY [1..2] OF REAL;(*预热辊速度系数*)
	arGirth_HotRoller_PreHot                  		: ARRAY [1..2] OF REAL;(*预热辊周长*)
	aiPreAirHotRollTorque                     		: ARRAY [1..2] OF INT;(*预热辊转矩*)
	auiDen_HotRoller_PreHot                   		: ARRAY [1..2] OF UINT;(*预热辊减速比分母*)
	auiNum_HotRoller_PreHot                   		: ARRAY [1..2] OF UINT;(*预热辊减速比分子*)
	aiPreHotRoller_Velocity_Water             		: ARRAY [1..2] OF INT;(*水冷辊额定转速*)
	arStandardFreq_HotRoller_Water            		: ARRAY [1..2] OF REAL;(*水冷辊额定频率*)
	arUpperFreq_HotRoller_Water               		: ARRAY [1..2] OF REAL;(*水冷辊上限频率*)
	arCoeff_HotRoller_Water                   		: ARRAY [1..2] OF REAL;(*水冷辊速度系数*)
	arGirth_HotRoller_Water                   		: ARRAY [1..2] OF REAL;(*水冷辊周长*)
	auiDen_HotRoller_Water                    		: ARRAY [1..2] OF UINT;(*水冷辊减速比分母*)
	auiNum_HotRoller_Water				      		: ARRAY [1..2] OF UINT;(*水冷辊减速比分子*)
	aiDelayMsec_ExhPowerMode						: ARRAY [1..2] OF INT; (*排风切换延时*)
	aiDelayMsec_HeatBlower							: ARRAY [1..2] OF INT; (*热风延时*)
	aiDelayMsec_Heat								: ARRAY [1..2] OF INT; (*加热延时*)
	abyHotBlowerStopDelayTime						: ARRAY [1..2] OF BYTE;(*热风停止延时*)
	abyFreqMin_HotWind								: ARRAY [1..2] OF BYTE;(*热风最小频率*)
	abyFreqMax_HotWind								: ARRAY [1..2] OF BYTE;(*热风最大频率*)
//为了把卷径检测参数放一起2026.5.15.102809|这里先屏蔽|空出56字节
	abyData_Rsv_11									: ARRAY [1..56] OF BYTE;
//	arStdVol_Diam_Axis_Hmi							: ARRAY [1..2,1..4] OF REAL;(* 标准卷径值| 双向通讯参数*)		
//	arStdVol_Coef									: ARRAY [1..2,1..3] OF REAL;(* 标准卷径系数| 双向通讯参数*)	
	aiTime_FilmAcc									: ARRAY [1..2] OF INT;(*预驱料膜加速时间*)
	aiTime_FilmDec              					: ARRAY [1..2] OF INT;(*预驱料膜减速时间*)
	aiTime_PreDrvAcc_Rw         					: ARRAY [1..2] OF INT;(*收料预驱加速时间*)
	aiTime_PreDrvDec_Rw         					: ARRAY [1..2] OF INT;(*收料预驱减速时间*)
	aiTime_PreDrvAcc_Uw         					: ARRAY [1..2] OF INT;(*放料预驱加速时间*)
	aiTime_PreDrvDec_Uw         					: ARRAY [1..2] OF INT;(*放料预驱减速时间*)
	arFilmLen_NotAdjFront							: ARRAY [1..2] OF REAL;	(*料前幅数*)		
	arFilmLen_NotAdjBack        					: ARRAY [1..2] OF REAL; (*料后幅数*)
	arFilmLen_UnwindToPU1       					: ARRAY [1..2] OF REAL; (*裁点到1色距离*)
//2025.7.3.175755以上总共214字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
//增加版辊压力电机减速比分母|2026.2.2.163405|总4个字节|6-4=2
	auiDen_PrnRoller_Pressure					: ARRAY [1..2] OF UINT;(* 版辊压力电机减速比分母/整机设置状态 *)
	abyRsvData_6										: ARRAY [1..2] OF BYTE;
/////////////////////////////////////////////////////2025.7.3.175755新增6字节，总大小220byte//////////////////////////////////////////////////////////////	
		
	auiPiDelay_Uw               					: ARRAY [1..2] OF UINT; (*放料接料PI投入时间*)
	aiPreRevLenth_MM_Cutted     					: ARRAY [1..2] OF INT;  (*裁切反转距离*)
	aiPreRevVel_RPM_Cutted      					: ARRAY [1..2] OF INT;  (*裁切反转速度*)
	arCoefCut_FilmVolPerimeter_Uw					: ARRAY [1..2] OF REAL;(*放料裁切圈数*)
	arCoefCut_FilmVolPerimeter_Rw					: ARRAY [1..2] OF REAL;(*收料裁切圈数*)
	arDiam_Tower_Uw									: ARRAY [1..2] OF REAL;(*反转架直径*)
	arDiam_NextRoller_Uw            				: ARRAY [1..2] OF REAL;(*下个辊直径*)
	arXPos_NextRoller_Uw            				: ARRAY [1..2] OF REAL;(*下个辊X*)
	arYPos_NextRoller_Uw            				: ARRAY [1..2] OF REAL;(*下个辊Y*)
	arDiam_DeflectorRoller_Uw       				: ARRAY [1..2] OF REAL;(*导向辊直径*)
	arDiam_DeflectorRollPos_Uw      				: ARRAY [1..2] OF REAL;(*AB导向辊长度*)
//调试周长变量不对2025.11.14.145848更新一下改为
	aiDebugVelmpm_AxisA_Uw							: ARRAY [1..2] OF INT;(*放料A轴调试速度*)			
	aiDebugGirthmm_AxisA_Uw	    					: ARRAY [1..2] OF INT;(*放料A轴调试周长*)
	abyDebugRsv										: ARRAY [1..4] OF BYTE;(*原REAL型改为INT型*)
//	arDebugCurVelmpmAxisA_Uw    					: ARRAY [1..2] OF REAL;(*放料A轴调试周长*)
	aiDebugVelmpm_AxisB_Uw							: ARRAY [1..2] OF INT;(*放料A轴调试速度*)			
	aiDebugGirthmm_AxisB_Uw	    					: ARRAY [1..2] OF INT;(*放料B轴调试周长*)
	abyDebugRsv1										: ARRAY [1..4] OF BYTE;(*原REAL型改为INT型*)
//	arDebugCurVelmpmAxisB_Uw    					: ARRAY [1..2] OF REAL;(*放料A轴调试周长*)
	aiDebugVelmpm_AxisA_Rw							: ARRAY [1..2] OF INT;(*放料A轴调试速度*)			
	aiDebugGirthmm_AxisA_Rw	    					: ARRAY [1..2] OF INT;(*收料A轴调试周长*)
	abyDebugRsv2									: ARRAY [1..4] OF BYTE;(*原REAL型改为INT型*)
//	arDebugCurVelmpmAxisA_Rw    					: ARRAY [1..2] OF REAL;(*放料A轴调试周长*)
	aiDebugVelmpm_AxisB_Rw							: ARRAY [1..2] OF INT;(*放料A轴调试速度*)			
	aiDebugGirthmm_AxisB_Rw	    					: ARRAY [1..2] OF INT;(*收料B轴调试周长*)
	abyDebugRsv3										: ARRAY [1..4] OF BYTE;(*原REAL型改为INT型*)
//	arDebugCurVelmpmAxisB_Rw    					: ARRAY [1..2] OF REAL;(*放料A轴调试周长*)
	arVel_Ink										: ARRAY [1..2] OF REAL;(*空转速度*)
	arVel_Inch                      				: ARRAY [1..2] OF REAL;(*单运行速度*)
	abyDelayTime_PressDneInPrint_If 				: ARRAY [1..2] OF BYTE;(*放牵压辊延时*)
	arVel_Max                       				: ARRAY [1..2] OF REAL;(*最大速度*)
	abyMeters_UseFollow_1U_V_UwCut					: ARRAY [1..2] OF BYTE;(*有效距离*)
	arGirth_If                    					: ARRAY [1..2] OF REAL;(*放牵辊周长*)
	arGirth_Of                    					: ARRAY [1..2] OF REAL;(*收牵辊周长*)
	aiDelayMsec_RollerPress       					: ARRAY [1..2] OF INT;(*合压时间*)
	aiTime_S                      					: ARRAY [1..2] OF INT;(*S加速时间*)
	aiTime_S_End                  					: ARRAY [1..2] OF INT;(*S减速时间*)
	abyAxisInitPhaseTypeWhenPreRegister				: ARRAY [1..2] OF BYTE;(*预套准初始位置*)
	abyVelLimit_PerCent_IfOf           				: ARRAY [1..2] OF BYTE;(*牵引调制限制值*)
	arVel_ManuAdjust                   				: ARRAY [1..2] OF REAL;(*手动粗调速度*)
	arVel_AutoAdjust                   				: ARRAY [1..2] OF REAL;(*自动调整速度*)
	arVel_RapidAdjust                  				: ARRAY [1..2] OF REAL;(*快速对版速度*)
//2025.7.3.175755以上总共208字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
//增加版辊压力电机减速比分子，分母预留不够放其他地方 和螺距|2026.2.2.163405|总12个字节|12-12=0
	arScrewPitch_PrnRoller_Pressure				: ARRAY [1..2] OF REAL;(* 版辊压力架丝杆节距/整机设置状态/单位mm *)
	auiNum_PrnRoller_Pressure					: ARRAY [1..2] OF UINT;(* 版辊压力电机减速比分子/整机设置状态 *)
//	uiDen_PrnRoller_Pressure					: UINT;(* 版辊压力电机减速比分母/整机设置状态 *)
//	abyRsvData_7										: ARRAY [1..0] OF BYTE;
/////////////////////////////////////////////////////2025.7.3.175755新增12字节，总大小220byte//////////////////////////////////////////////////////////////	
	
	arAdjVal_PerTime_Fine              				: ARRAY [1..2] OF REAL;(*手动细调调整量*)
	arAdjVal_PerTime_Coarse            				: ARRAY [1..2] OF REAL;(*手动粗调调整量*)
	arVel_HorzAdjust                   				: ARRAY [1..2] OF REAL;(*横向调整速度*)
	arVel_HorzPreRegister              				: ARRAY [1..2] OF REAL;(*横向预套准速度*)
	auiNum_If                          				: ARRAY [1..2] OF UINT;(*放牵减速比-电机侧*)
	auiDen_If                          				: ARRAY [1..2] OF UINT;(*放牵减速比-传动侧*)
	auiNum_Of                          				: ARRAY [1..2] OF UINT;(*收牵减速比-电机侧*)
	auiDen_Of                          				: ARRAY [1..2] OF UINT;(*收牵减速比-传动侧*)
	auiNum_Uw                          				: ARRAY [1..2] OF UINT;(*放料减速比-电机侧*)
	auiDen_Uw                          				: ARRAY [1..2] OF UINT;(*放料减速比-传动侧*)
	auiNum_Rw                          				: ARRAY [1..2] OF UINT;(*收料减速比-电机侧*)
	auiDen_Rw                          				: ARRAY [1..2] OF UINT;(*收料减速比-传动侧*)
	auiNum_Pu                          				: ARRAY [1..2] OF UINT;(*色组减速比-电机侧*)
	auiDen_Pu                          				: ARRAY [1..2] OF UINT;(*色组减速比-传动侧*)
	
(*重新分配一下awOutput_IOtestDO_Main-abyRsvData_8||共96+52字节*)	
(*	awOutput_IOtestDO_Main							: ARRAY [1..2,1..8] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestAO_Main							: ARRAY [1..2,1..16] OF WORD;(*主面板IO测试输出*)*)

////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
(*2025.9.11.184126增加放料裁切时间集--66*2||148-132=16*)
	astStTimeSet_DnCut_UpCut_Uw_Hmi						: ARRAY [1..2] OF StTimeSet_DnCut_UpCut;(* 放料端的裁切时间集/界面显示 *)
(*	
	abyRsvData_8										: ARRAY [1..148] OF BYTE;
	*)
	(*2025.10.13.140150增加预备接料响铃时间16-2=14*)
	abyAlarmHold_PreCut_Uw								: ARRAY [1..2] OF BYTE;(*放料预备接料响铃时间*)

	//2026.02.07.105543增加UV启动速度||14-8=6
	arVel_UVstartVel									: ARRAY [1..2] OF REAL;	
	
	abyRsvData_8										: ARRAY [1..6] OF BYTE;
	
/////////////////////////////////////////////////////2025.7.3.175755新增52字节，总大小220byte//////////////////////////////////////////////////////////////	

//干脆新增吧正好一个包处理2025.8.20.160418
	awOutput_IOtestDO_Main_If							: ARRAY [1..2,1..4] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestAO_Main_If							: ARRAY [1..2,1..6] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestDO_Main_Of							: ARRAY [1..2,1..4] OF WORD;(*主面板IO测试输出*)
	awOutput_IOtestAO_Main_Of							: ARRAY [1..2,1..6] OF WORD;(*主面板IO测试输出*)	
	awOutput_IOtestDO_Uw								: ARRAY [1..2,1..5] OF WORD;(*收放料IO测试输出*)
	awOutput_IOtestAO_Uw								: ARRAY [1..2,1..12] OF WORD;(*收放料IO测试输出*)
	awOutput_IOtestDO_Rw								: ARRAY [1..2,1..5] OF WORD;(*收放料IO测试输出*)
	awOutput_IOtestAO_Rw								: ARRAY [1..2,1..12] OF WORD;(*收放料IO测试输出*)	
	abyRsvData_IOtest										: ARRAY [1..4] OF BYTE;
	

////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
(*2025.9.11.184126增加收料裁切时间集--66*2*)
	astStTimeSet_DnCut_UpCut_Rw_Hmi						: ARRAY [1..2] OF StTimeSet_DnCut_UpCut;(* 收料端的裁切时间集/界面显示 *)
(*增加收料裁切时间--=440-132=88+220	
	abyRsvData_9										: ARRAY [1..440] OF BYTE;*)
//增加预热风和预加热参数2025.10.15.162208|niuj||88-16=72
	arHz_PreHotAir_ManuallySet							: ARRAY [1..2] OF REAL;(*预热风频率*)
	arSV_PreHeating										: ARRAY [1..2] OF REAL;(*预加热温控SV*)
//2025.10.15.164656增加刮刀、递墨辊手动频率、自动系数（一对多）	72-32=40
	arHz_Scraper_ManuallySet						: ARRAY [1..2] OF REAL;(*刮刀手动频率*)
	arCoeff_Scraper_Auto							: ARRAY [1..2] OF REAL;(*刮刀自动系数*)
	arHz_InkRoller_ManuallySet						: ARRAY [1..2] OF REAL;(*递墨辊手动频率*)
	arCoeff_InkRoller_Auto							: ARRAY [1..2] OF REAL;(*递墨辊自动系数*)
	
//2025.12.31.092340增加秦华相关内容|标准带长|第二牵引目标压力|16字节||40-16=24
	arLength_Band_Confirm							: ARRAY [1..2] OF REAL;
	arPressure_Tar									: ARRAY [1..2] OF REAL;
	
//2026.1.9.095418增加底辊周长减速比网辊周长减速比等	这里剩余24个字节，不够从后面加
//总共32字节||24个字节剩余全用完，从220-8=212
	arGirth_BottomRoller								: ARRAY [1..2] OF REAL;
	auiNum_BottomRoller								: ARRAY [1..2] OF UINT;
	auiDen_BottomRoller								: ARRAY [1..2] OF UINT;
	arGirth_NetRoller								: ARRAY [1..2] OF REAL;
	auiNum_NetRoller									: ARRAY [1..2] OF UINT;
	auiDen_NetRoller									: ARRAY [1..2] OF UINT;
	
//	abyRsvData_9										: ARRAY [1..24] OF BYTE;

//2026.2.2.163922增加网辊压力电机减速比分子分母||总32字节|212-32=180
	arScrewPitch_NetRoller_Pressure				: ARRAY [1..2] OF REAL;(* 网辊压力架丝杆节距/整机设置状态/单位mm *)
	auiNum_NetRoller_Pressure					: ARRAY [1..2] OF UINT;(* 网辊压力电机减速比分子/整机设置状态 *)
	auiDen_NetRoller_Pressure					: ARRAY [1..2] OF UINT;(* 网辊压力电机减速比分母/整机设置状态 *)
	arScrewPitch_StrRoller_Pressure				: ARRAY [1..2] OF REAL;(* 张带辊压力架丝杆节距/整机设置状态/单位mm *)
	auiNum_StrRoller_Pressure					: ARRAY [1..2] OF UINT;(* 张带辊压力电机减速比分子/整机设置状态 *)
	auiDen_StrRoller_Pressure					: ARRAY [1..2] OF UINT;(* 张带辊压力电机减速比分母/整机设置状态 *)

//增加横向参数2026.2.2.17012|niu.j||总16字节|180-16=164
	arScrewPitch_Horz							: ARRAY [1..2] OF REAL;(* 横向架丝杆节距/整机设置状态/单位mm *)
	auiNum_Horz									: ARRAY [1..2] OF UINT;(* 横向电机减速比分子/整机设置状态 *)
	auiDen_Horz									: ARRAY [1..2] OF UINT;(* 横向电机减速比分母/整机设置状态 *)
	
//2026.5.15.101914界面卷径检测变量得放这里双向，可输入参数
//2026.5.15.101727增加了界面卷径检测部分的赋值||总104字节||164-104=60
	arStdVol_Diam_Axis_Hmi								: ARRAY [1..2,1..4] OF REAL; (* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
	arStdVol_Coef_Axis_Hmi								: ARRAY [1..2,0..4] OF REAL;(* 分段系数|2019.1.25.142601|更名A轴|[0]表<=1,[1]表>1&& <=2,[2]表>2&& <=3,[3]表>3&& <=4,[4]表>4 *)
	arStdVol_Volt_Axis_Hmi								: ARRAY [1..2,1..4] OF REAL;(* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
	

	abyRsvData_10										: ARRAY [1..60] OF BYTE;
//	abyRsvData_10										: ARRAY [1..212] OF BYTE;	
//	abyRsvData_10										: ARRAY [1..220] OF BYTE;
/////////////////////////////////////////////////////2025.7.3.175755总大小440byte//////////////////////////////////////////////////////////////	
						
	astStWrRd_UnitParam									: ARRAY [1..MAX_UNIT_NUM] OF StWrRd_UnitParam;(*总220*3*16字节*)

	
	
	(*2025.7.3.175755——||| 9905界面参数*)
	uiMaxVel_UseCalcAcc								: UINT;
	byPseudoRandomRoundTimes						: BYTE;
	rPseudoRandomAmplitude							: REAL;
	bySetTestPid_IfOf								: BYTE;
	by10vSignalCoef									: BYTE;
	rCompensateGirthWhenAccing_If					: REAL;
	rCompensateGirthWhenAccing_Of					: REAL;
	byArcDeCoupleStepTest							: BYTE;			
	iCustomerLogoOffsetX							: INT;			
	byGuardrialColor_R								: BYTE;		
	byGuardrialColor_G								: BYTE;		
	byGuardrialColor_B								: BYTE;		
	iLedFuncId										: INT;
	iSetHmiResValue									: INT;	
	wRunningTime_Day								: WORD;		
	byRunningTime_Hour								: BYTE;		
	byRunningTime_Min								: BYTE;		
	byRunningTime_Sec								: BYTE;		
	byArcIntensity_W								: BYTE;
	byArcIntensity_M								: BYTE;
	byArcIntensity_S								: BYTE;
	byMotorOverTempValue_UseEncTemp					: BYTE;
	byRemainSpaceNum_PTCTL         					: BYTE;
	rSpeed_SCoeff_Type789          					: REAL;
	byMaxPulseOut_16dIO            					: BYTE;
	bySysSamplePrecision           					: BYTE;
	byArcAdjValueDealType          					: BYTE;
	byArcErrLimitToCtl_P           					: BYTE;
	byArcErrLimitToCtl_I           					: BYTE;
	byMaxPulseOut_Module           					: BYTE;
	byArcFineSampleType            					: BYTE;
	byArcPidGetType                					: BYTE;
	rFilmLenth_Eyes                					: REAL;
	uiArcSysDelayTime_ms           					: UINT;
	byParamIndex_Huang								: BYTE;
	uiControllerVel_Huang							: UINT;
	byCouplingType									: BYTE;
	byDeCoupleArcNum								: BYTE;

	auiPreStopDelayTime_ms							: ARRAY [1..2] OF UINT;
	arVel_Tar_9905									: ARRAY [1..2] OF REAL; 
	aiAxisId_StepTest_V								: ARRAY [1..2] OF INT;
	aiInterval_StepTest12							: ARRAY [1..2] OF INT;
	aiMicron_StepTest1_V							: ARRAY [1..2] OF INT;
	aiMicron_StepTest2_V							: ARRAY [1..2] OF INT;
	abyKalmanFilterType_Rw							: ARRAY [1..2] OF BYTE;
	abyStructParanInitEn_Rw							: ARRAY [1..2] OF BYTE;
	(*
	aR_0_RW											: ARRAY [1..2] OF REAL;	
	aa0_0_RW	                					: ARRAY [1..2] OF REAL;
	ab1_0_RW	                					: ARRAY [1..2] OF REAL;
	aWn_0_RW	                					: ARRAY [1..2] OF REAL;
	aBeta_0_RW	            						: ARRAY [1..2] OF REAL;
	al_0_RW	                						: ARRAY [1..2] OF REAL;
	aK_PI_RW	                					: ARRAY [1..2] OF REAL;
	aa_RW	                						: ARRAY [1..2] OF REAL;
	ab_RW	                						: ARRAY [1..2] OF REAL;
	aTs_RW	                						: ARRAY [1..2] OF REAL;
	aRange_RW	            						: ARRAY [1..2] OF REAL;
	aTheta_RW	            						: ARRAY [1..2] OF REAL;
	aK_adj_RW	            						: ARRAY [1..2] OF REAL;
	*)
	astModelParam_Rw								: ARRAY [1..2] OF Initial_Model_Parameters;(*放料模型初始参数@50bytes*)
	astInvariant_Parameters_Rw						: ARRAY [1..2] OF Invariant_Parameters;(*放料张力算法系统参数@30bytes*)
	astPI_Parameters_Rw								: ARRAY [1..2] OF PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)
	
	(*上面104字节先屏蔽了，在后面加结构体2025.9.18.095804*)
	arR_K_MinBeat_Rw	        					: ARRAY [1..2] OF REAL;
	aiN_MinBeat_Rw	        						: ARRAY [1..2] OF INT;
	arR_K_LQR_Rw	            					: ARRAY [1..2] OF REAL;
//2025.7.3.175755以上总共216字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
	abyRsvData_11										: ARRAY [1..4] OF BYTE;
/////////////////////////////////////////////////////2025.7.3.175755新增52字节，总大小220byte//////////////////////////////////////////////////////////////	


	arN_LQR_Rw	            						: ARRAY [1..2] OF REAL;
	arKc_Rw	                						: ARRAY [1..2] OF REAL;
	arKc_Rw_AccDec	        						: ARRAY [1..2] OF REAL;
	arWc_LowPass_Diam_Rw	    					: ARRAY [1..2] OF REAL;
	abyKalmanFilterType_Uw 							: ARRAY [1..2] OF BYTE;
	abyStructParanInitEn_Uw							: ARRAY [1..2] OF BYTE;
(*	aR_0_UW											: ARRAY [1..2] OF REAL;
	aa0_0_UW            						    : ARRAY [1..2] OF REAL;
	ab1_0_UW            						    : ARRAY [1..2] OF REAL;
	aWn_0_UW            						    : ARRAY [1..2] OF REAL;
	aBeta_0_UW          						    : ARRAY [1..2] OF REAL;
	al_0_UW             						    : ARRAY [1..2] OF REAL;
	aK_PI_UW            						    : ARRAY [1..2] OF REAL;
	aa_UW               						    : ARRAY [1..2] OF REAL;
	ab_UW               						    : ARRAY [1..2] OF REAL;
	aTs_UW              						    : ARRAY [1..2] OF REAL;
	aRange_UW           						    : ARRAY [1..2] OF REAL;
	aTheta_UW           						    : ARRAY [1..2] OF REAL;
	aK_adj_UW           						    : ARRAY [1..2] OF REAL;
*)	(*上面104字节先屏蔽了，在后面加结构体2025.9.18.095804*)
	astModelParam_Uw								: ARRAY [1..2] OF Initial_Model_Parameters;(*放料模型初始参数@50bytes*)
	astInvariant_Parameters_Uw						: ARRAY [1..2] OF Invariant_Parameters;(*放料张力算法系统参数@30bytes*)
	astPI_Parameters_Uw								: ARRAY [1..2] OF PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)
	
	arR_K_MinBeat_Uw    						    : ARRAY [1..2] OF REAL;
	aiN_MinBeat_Uw      						    : ARRAY [1..2] OF INT;
	arR_K_LQR_Uw        						    : ARRAY [1..2] OF REAL;
	arN_LQR_Uw          						    : ARRAY [1..2] OF REAL;
	arKc_Uw             						    : ARRAY [1..2] OF REAL;
	arKc_Uw_AccDec      						    : ARRAY [1..2] OF REAL;
	arWc_LowPass_Diam_Uw						    : ARRAY [1..2] OF REAL;
//2025.7.3.175755以上总共192字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
	abyRsvData_12										: ARRAY [1..28] OF BYTE;
/////////////////////////////////////////////////////2025.7.3.175755新增28字节，总大小220byte//////////////////////////////////////////////////////////////	
		
	arWn_Uw         							    : ARRAY [1..2] OF REAL;
	arBw_Uw         							    : ARRAY [1..2] OF REAL;
	arDp_Uw         							    : ARRAY [1..2] OF REAL;
	aiWorkMode_Pid									: ARRAY [1..2] OF INT;
	arFilmLenth_InUnit							    : ARRAY [1..2] OF REAL;
//2025.7.3.175755以上总共36字节
////////////////////////////////////////////////////////////分割线///////////////////////////////////////////////
//2025.9.18.103045|niu.j|占用48字节184-48=136
	astPI_Parameters_Uw_AccDec					: ARRAY [1..2] OF PI_Parameters;(*控制器pi参数@20bytes|2024.05.13.180942 增加一组加减速的控制参数*)
	astPI_Parameters_Rw_AccDec					: ARRAY [1..2] OF PI_Parameters;(*控制器pi参数@20bytes|2024.05.13.180942 增加一组加减速的控制参数*)
//2025.10.23.104446增加放牵收牵放料锥度控制136-48= 88
	arTaper_Begin_If						: ARRAY [1..2] OF REAL;
	arTaper_End_If							: ARRAY [1..2] OF REAL;
	arTaper_Begin_Of						: ARRAY [1..2] OF REAL;
	arTaper_End_Of							: ARRAY [1..2] OF REAL;
	arTaper_Begin_Uw						: ARRAY [1..2] OF REAL;
	arTaper_End_Uw							: ARRAY [1..2] OF REAL;
	


//2026.4.25.144455增加调整强度切换开关变量|1个字节|88-1=87
	byArcIntensity								: BYTE;
//2026.4.25.144533
//2026.05.14.145106 新增 87-3*8=63
	arRemainDia_stop	:ARRAY [1..2] OF REAL;
	arMaxErr_GantryTrap	:ARRAY [1..2] OF REAL;
	arVel_NetReturn 	:ARRAY [1..2] OF REAL;
//2026.05.15.85011 新增电晕启动速度 63-8=55
	arVel_CoronaVel 	:ARRAY [1..2] OF REAL;
	arVel_AutoDec: ARRAY [1..2] OF REAL;
	
//2026.05.24.133343 增加光纤行走变量 47-14=33
	aiFiberMoveVel:ARRAY [1..2] OF INT;//光纤行走速度
	arFiberMoveDistance_AllUnit: ARRAY [1..2] OF REAL;(*光纤色组同步运动距离*)
	abyFiberMove_MicroMoveStep : ARRAY [1..2] OF BYTE;(*光纤微调步进量*)
	
	
	abyRsvData_13										: ARRAY [1..32] OF BYTE;
//2026.8.14.095411取1个字节||33-1=32
	byMachanicalTypeId: BYTE;(*1摆臂2直压3PVC直压4等料长5力达欧诺直压*)
	
/////////////////////////////////////////////////////2025.7.3.175755新增184字节，总大小220byte//////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////2025.7.3.175755新增184字节，总大小220byte//////////////////////////////////////////////////////////////	
//从这里新增220*5字节通讯机械参数2026.8.14.094926||5种机械结构200字节*5；预留一种机械结构；如超过6种再新增；
//同时从上面取一个字节，存放摆臂结构byMachanicalTypeId: BYTE;(*1摆臂2直压3PVC直压4等料长5力达欧诺直压*)；
	astStMechanicalParamBuf								: ARRAY [1..5] OF StMechanicalParamBuf;
	stStMechanicalParamBuf_Rsv							: StMechanicalParamBuf;
	
	//2026.09.12.105930 | + | 修改预套准机械参数之后预留120字节	
	abyRsvData_120										: ARRAY [1..120] OF BYTE;
	
(*2025.10.13.113907增加系统配置相关变量|niu.j*)
	stStWrRd_SysCfg 								: StWrRd_SysCfg;(*总660字节*)	
	
	stStRd_PhaseRead: StRd_PhaseRead;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
