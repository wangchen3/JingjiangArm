(*@CES
Name=StParam_Diamonds_Wr_SysSts
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=36567eeb-cf40-455c-ac4d-1ac9c3fe2b84
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StParam_Diamonds_Wr_SysSts :
STRUCT
	dwFileVersion										: DWORD;(* 文件版本/后续作为识别参数的规范 *)	
	dwPrgVersion_YMD									: DWORD;(*程序版本*)
	dwPrgVersion_HMS									: DWORD;(*程序版本*)
	dwPrgVersion										: DWORD;(*程序版本*)
	dwCmpVersion_YMD									: DWORD;(*固高库版本*)
	dwCmpVersion_HMS									: DWORD;(*固高库版本*)
	dwCmpVersion										: DWORD;(*固高库版本*)
	//StStsModbus结构体6字节
	stStStsModbus										: StSts_Modbus;(*该联合体6字节*)
	abyReserved_Modbus									: ARRAY [1..11] OF BYTE;		
//2025.12.30.231113把abyReserved_Modbus放出1个字节放全局的开关状态等；12-1=11；
	xAlarm_CutDne_Uw									: BIT;
	xFlag_Rsv1											: BIT;
	xFlag_Rsv2											: BIT;
	xFlag_Rsv3											: BIT;
	xFlag_Rsv4											: BIT;
	xFlag_Rsv5											: BIT;
	xFlag_Rsv6											: BIT;
	xFlag_Rsv7											: BIT;	
//2025.12.30.231224	
	//StSts_GrpFlag结构体24字节
	astStSts_GrpFlag									: ARRAY [1..2] OF StSts_GrpFlag;	
	aiPromptMsg											: ARRAY [1..2] OF INT;
	aiAlarm_TypeId										: ARRAY [1..2] OF INT;//报警轴的类型
	aiAlarm_UnitId										: ARRAY [1..2] OF INT;//报警轴位置
	aiIdGSE												: ARRAY [1..2] OF INT;
	aiTimeSec_AccDec_AllTheWay							: ARRAY [1..2] OF INT;(* 全程加减速所需要的秒 *)
	arAccDecTime_ThisTime								: ARRAY [1..2] OF REAL;(* 本次加减速时间/单位:s *)
//卷径检测参数不妨这里了2026.5.15.102253|空出来了32个字节
	abyData_Rsv_4										: ARRAY [1..32] OF BYTE;
//	arStdVol_Volt_Axis_Hmi								: ARRAY [1..2,1..4] OF REAL;(* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计188字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
(*在这里增加一下收放料调试当前速度变量2025.11.14.150401
共REAL型*8字节=32|||66-32=34*)
	arDebugCurVelmpmAxisA_Uw							: ARRAY [1..2] OF REAL;(*放料A调试当前速度*)
	arDebugCurVelmpmAxisB_Uw							: ARRAY [1..2] OF REAL;(*放料B调试当前速度*)
	arDebugCurVelmpmAxisA_Rw							: ARRAY [1..2] OF REAL;(*收料A调试当前速度*)
	arDebugCurVelmpmAxisB_Rw							: ARRAY [1..2] OF REAL;(*收料B调试当前速度*)
//2025.12.30.230258这里增加一个全局参数吧||	diStepDrivePluse_Act:DINT;(*步进电机实际走的脉冲数*)||34-4=30
	diStepDrivePluse_Act								:DINT;(*步进电机实际走的脉冲数*)		

//更新一些东西2026.5.8.161200
//2026.4.28.094309||增加异站编码器相关||30-29=1
	auiSetVirtualEncCfgCnt								: ARRAY [1..2] OF UINT;(*异站虚拟码盘参数设置计数*)
	xCheckVirtualStsEn									: BIT;(*异站编码器返回状态检查标志|*)
	xVirtualStsChangeFrom2To_A							: BIT;(*异站虚拟码盘状态由2切换到别的状态标志|有切换对该标志取反切换*)	
	xVirtualStsChangeFrom2To_B							: BIT;(*异站虚拟码盘状态由2切换到别的状态标志|有切换对该标志取反切换*)	
	xRsv_Virtual3										: BIT;
	xRsv_Virtual4										: BIT;
	xRsv_Virtual5										: BIT;
	xRsv_Virtual6										: BIT;
	xRsv_Virtual7										: BIT;
//bit总共8位一字节	
	adwVirtualAcrossEnSts								: ARRAY [1..2] OF DWORD;(*异站虚拟码盘设置状态返回*)
	aiSetVirtualEnc_ErrCode								: ARRAY [1..2] OF INT;
	aiSetVirtualEncCfgRtn	 							: ARRAY [1..2] OF INT;(*虚拟码盘配置返回值*)	
	aiVirtualEnc_AxisId_Des								: ARRAY [1..2] OF INT;(*虚拟码盘的目标轴号*)	
	aiVirtualEnc_AxisId_Src								: ARRAY [1..2] OF INT;(*虚拟码盘的源轴号*)	
//2026.4.28.103517增加结束	
	byRsvData_1										: BYTE;
//	abyRsvData_1										: ARRAY [1..30] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-每隔一段数据增加些预留空间/////////////////////////////////////////////////////////////////////////////	

	abyRsvData_a										: ARRAY [1..440] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//卷径检测参数不妨这里了2026.5.15.102253|空出来了40个字节
	abyData_Rsv_3										: ARRAY [1..40] OF BYTE;
//	arStdVol_Coef_Axis_Hmi								: ARRAY [1..2,0..4] OF REAL;(* 分段系数|2019.1.25.142601|更名A轴|[0]表<=1,[1]表>1&& <=2,[2]表>2&& <=3,[3]表>3&& <=4,[4]表>4 *)
	(* 速度 *)
	arVel_Film											: ARRAY [1..2] OF REAL;(* 料膜速度/0 *)
	aiSid_AxisA_Uw										: ARRAY [1..2] OF INT;(* 放料站id/-1表示变频/2021.11.21.192354/hdp *)
	aiSid_AxisB_Uw										: ARRAY [1..2] OF INT;(* 放料站id/-1表示变频/2021.11.21.192354/hdp *)
	arKpid_Current_Uw									: ARRAY [1..2,1..3] OF REAL;(* 当前放料pid监控 *)
(*	astStTimeSet_DnCut_UpCut_Uw_Hmi						: ARRAY [1..2] OF StTimeSet_DnCut_UpCut;(* 放料端的裁切时间集/界面显示 *)
2025.9.11.184210裁切时间集属于读写内容，控66*2字节*)
//在这里增加9905收放料速度等监控变量2025.10.13.143821||||niuj||96个字节||132-96=36
	arVel_Uw											: ARRAY [1..2] OF REAL;
	arVel_Rw											: ARRAY [1..2] OF REAL;
	arVel_If											: ARRAY [1..2] OF REAL;
	arVel_Of											: ARRAY [1..2] OF REAL;
	arAIMax_Uw											: ARRAY [1..2] OF REAL;
	arAIMin_Uw											: ARRAY [1..2] OF REAL;
	arAIMax_Rw											: ARRAY [1..2] OF REAL;
	arAIMin_Rw											: ARRAY [1..2] OF REAL;
	arAIMax_If											: ARRAY [1..2] OF REAL;
	arAIMin_If											: ARRAY [1..2] OF REAL;
	arAIMax_Of											: ARRAY [1..2] OF REAL;
	arAIMin_Of											: ARRAY [1..2] OF REAL;

//2025.10.13.164816增加当前伪随机测试次数36-10=26
	abyPseudoRandomRoundTimes_Cur						: ARRAY [1..2] OF BYTE;(*伪随机测试当前次数|AB系*)
	arPseudoRandomRoundAmplitude_Cur					: ARRAY [1..2] OF REAL;(*伪随机测试|AB系*)
//2025.10.15.163100|增加预加热PV反馈|26-8=22
	arPV_PreHeating										: ARRAY [1..2] OF REAL;(*预加热温控PV*)		
	//2025.12.30.221324增加放料翻转架0度位置总共2+2）*4=16；；18-16||=2
	adwAxisAabsPos_0Rad_Uw						: ARRAY [1..2] OF DWORD;(* 放料A轴翻转架0度的绝对位置/翻转架中心作为坐标系0点/0 *)
	adwAxisBabsPos_0Rad_Uw						: ARRAY [1..2] OF DWORD;(* 放料B轴翻转架0度的绝对位置/翻转架中心作为坐标系0点/0 *)
	abyRsvData_21										: ARRAY [1..2] OF BYTE;	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计212字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
//占用8字节放放料翻转架当前弧度  8-8=0||2025.12.30.222039
	arTowerThetaCur_Uw							: ARRAY [1..2] OF REAL;(* 翻转架当前弧度/0 *)

	//abyRsvData_2										: ARRAY [1..8] OF BYTE;
//	abyRsvData_21										: ARRAY [1..18] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计212字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
//	abyRsvData_2										: ARRAY [1..8] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	arVel_Cur_HMI										: ARRAY [1..2] OF REAL;	
	arAI_HMI_Uw											: ARRAY [1..2] OF REAL;(* 放料摆臂值显示用 *)
	arAI_DiamMeasure_Uw									: ARRAY [1..2] OF REAL;(* 放料卷径测量输入反馈 *)	
	arKpid_Current_Rw									: ARRAY [1..2,1..3] OF REAL;(* 当前收料pid监控 *)	
	arDiam_NewVol_Uw									: ARRAY [1..2] OF REAL;(* 放料新卷卷径 *)
	adwAbsEncSinglePos_Uw								: ARRAY [1..2] OF DWORD;(* 放料单圈位置/0 *)
	adwAbsEncSPos_Cur_Uw								: ARRAY [1..2] OF DWORD;(* 放料当前绝对位置/0 *)		
(*	astStTimeSet_DnCut_UpCut_Rw_Hmi						: ARRAY [1..2] OF StTimeSet_DnCut_UpCut;(* 收料端的裁切时间集/界面显示 *)	
2025.9.11.184210裁切时间集属于读写内容，控66*2字节*)
(*增加485&TCP通讯监控变量2025.10.13.163412||niu.j||80字节||132-128=4||暂时主站最大支持8个485设备*)
	auiSendDataCnt_Tcp									:ARRAY [1..8] OF UINT;
	auiRecvDataCnt_Tcp									:ARRAY [1..8] OF UINT;
	auiRecvErrDataCnt_Tcp								:ARRAY [1..8] OF UINT;
	auiTimeOutDataCnt_Tcp								:ARRAY [1..8] OF UINT;	
	auiSendDataCnt_485									:ARRAY [1..8] OF UINT;
	auiRecvDataCnt_485									:ARRAY [1..8] OF UINT;
	auiRecvErrDataCnt_485								:ARRAY [1..8] OF UINT;
	auiTimeOutDataCnt_485								:ARRAY [1..8] OF UINT;	
	
	abyRsvData_22										: ARRAY [1..4] OF BYTE;
	
	arAIByAbsEnc_Cur_Uw									: ARRAY [1..2] OF REAL;(* 放料绝对值编码器位置转换的电压值/0 *)
	abyIsDebug_DiaMeasureArea_Uw						: ARRAY [1..2] OF BYTE;(* 放料卷径测量调试的时候卷径区域值/1 *)
	abyAxisDebugBit_Uw									: ARRAY [1..2] OF BYTE;(* 放料轴调试标志/.0\调试使能.1\A轴调试运行.2\A轴自动加减速.3\A轴运行中.4\B轴调试运行.5\B轴自动加减速.6\B轴运行中/0 *)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计216字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
	abyRsvData_3										: ARRAY [1..4] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	awUwRwAxisProf										: ARRAY [1..2] OF WORD;
(*												/放料&收料轴描述 *)
(*												/bit0=TRUE,放料当前轴A轴 *)
(*												/bit1=TRUE,收料当前轴A轴 *)
	abyAxisDebugBit_Uw_2								: ARRAY [1..2] OF BYTE;(* 放料2轴调试标志/.0\调试使能.1\A轴调试运行.2\A轴自动加减速.3\A轴运行中.4\B轴调试运行.5\B轴自动加减速.6\B轴运行中/0 *)
	arPi_Value_Uw										: ARRAY [1..2] OF REAL;(* 放料pi值/0 *)
	arForwardStep_Uw									: ARRAY [1..2] OF REAL;(* 放料升降速前馈/0 *)
	arAxisAVelRPM_Cur_Uw								: ARRAY [1..2] OF REAL;(* 放料A轴转速/0/2021.11.18.201209 *)
	arAxisBVelRPM_Cur_Uw								: ARRAY [1..2] OF REAL;(* 放料B轴转速/0/2021.11.18.201209 *)
	aiSid_AxisA_Rw										: ARRAY [1..2] OF INT;(* 收料站id/-1表示变频/2021.11.21.192354/hdp *)
	aiSid_AxisB_Rw										: ARRAY [1..2] OF INT;(* 收料站id/-1表示变频/2021.11.21.192354/hdp *)
	arAI_HMI_Rw											: ARRAY [1..2] OF REAL;(* 收料摆臂值显示用 *)
	arDiam_NewVol_Rw									: ARRAY [1..2] OF REAL;(* 收料新卷卷径 *)
	arTaper_Rw											: ARRAY [1..2] OF REAL;(* 收料锥度 *)
//2025.11.14.151249调试速度统一放上面了这里预留吧
//	arDebugCurVelmpmAxisA_Rw							: ARRAY [1..2] OF REAL;(* A轴调试当前速度/m/min *)
	abyData_Rsv_Debug									: ARRAY [1..8] OF BYTE;
	adwAbsEncSinglePos_Rw								: ARRAY [1..2] OF DWORD;(* 收料单圈位置/0 *)
	adwAbsEncSPos_Cur_Rw								: ARRAY [1..2] OF DWORD;(* 收料当前绝对位置/0 *)
	adwAbsEnCodeResolution_Rw							: ARRAY [1..2] OF DWORD;(* 收料绝对值编码器分辨率/8388608 *)
	abyAxisDebugBit_Rw									: ARRAY [1..2] OF BYTE;(* 收料轴调试标志/.0\调试使能.1\A轴调试运行.2\A轴自动加减速.3\A轴运行中.4\B轴调试运行.5\B轴自动加减速.6\B轴运行中/0 *)
	arPi_Value_Rw										: ARRAY [1..2] OF REAL;(* 收料pi值/0 *)
	arForwardStep_Rw									: ARRAY [1..2] OF REAL;(* 收料升降速前馈/0 *)	
	arAxisAVelRPM_Cur_Rw								: ARRAY [1..2] OF REAL;(* 收料A轴转速/0/2021.11.18.201604 *)
	arAxisBVelRPM_Cur_Rw								: ARRAY [1..2] OF REAL;(* 收料B轴转速/0/2021.11.18.201608 *)
	aiSid_If											: ARRAY [1..2] OF INT;(* 放牵站id/-1表示变频 *)
	arAI_HMI_If											: ARRAY [1..2] OF REAL;(* 放牵摆臂值显示用 *)
	arVel_Cur_If										: ARRAY [1..2] OF REAL;(* 放牵速度/0 *)
	arPi_Value_If										: ARRAY [1..2] OF REAL;(* 放牵pi值/0 *)
	arForwardStep_If									: ARRAY [1..2] OF REAL;(* 放牵升降速前馈/0 *)
	arUsingGirth_If										: ARRAY [1..2] OF REAL;(* 放牵速度控制实际使用的周长/500mm *)	
	aiSid_Of											: ARRAY [1..2] OF INT;(* 收牵站id/-1表示变频 *)
	arAI_HMI_Of											: ARRAY [1..2] OF REAL;(* 收牵摆臂值显示用 *)
	arVel_Cur_Of										: ARRAY [1..2] OF REAL;(* 收牵速度/0 *)
	arPi_Value_Of										: ARRAY [1..2] OF REAL;(* 收牵pi值/0 *)
	arForwardStep_Of									: ARRAY [1..2] OF REAL;(* 收牵升降速前馈/0 *)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计216字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
	abyRsvData_4										: ARRAY [1..4] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

	arUsingGirth_Of										: ARRAY [1..2] OF REAL;(* 收牵速度控制实际使用的周长/500mm *)
	arTaper_Cur_Uw										: ARRAY [1..2] OF REAL;(*锥度当前|放料|*)
	arTaper_Cur_If										: ARRAY [1..2] OF REAL;(*锥度当前|放牵|*)
	arTaper_Cur_Of										: ARRAY [1..2] OF REAL;(*锥度当前|收牵|*)	
	arVolt_CalcDiam_Used_Watch							: ARRAY [1..2] OF REAL;(*计算卷径的电压值*)			
	arAO_Inverter_Uw_AxisA								: ARRAY [1..2] OF REAL;(*放料A轴输出|2017-08-12 17:25:33*)
	arAO_Inverter_Uw_AxisB								: ARRAY [1..2] OF REAL;(*放料B轴输出|2017-08-12 17:25:33*)
	arAO_Inverter_Rw_AxisA								: ARRAY [1..2] OF REAL;(*收料A轴输出|2017-08-12 17:25:33*)
	arAO_Inverter_Rw_AxisB								: ARRAY [1..2] OF REAL;(*收料B轴输出|2017-08-12 17:25:33*)
	adwAlarmDetail_CENTRAL								: ARRAY [1..2] OF DWORD;//轴报警信息-ZHONGX
	adwAlarmDetail_CENTRAL2								: ARRAY [1..2] OF DWORD;//轴报警信息-ZHONGX
	adwAlarmDetail_IF									: ARRAY [1..2] OF DWORD;//轴报警信息-放牵
	adwAlarmDetail_OF									: ARRAY [1..2] OF DWORD;//轴报警信息-收前
	adwAlarmDetail_UW_A									: ARRAY [1..2] OF DWORD;//轴报警信息-放A
	adwAlarmDetail_UW_B									: ARRAY [1..2] OF DWORD;//轴报警信息-放B
	adwAlarmDetail_RW_A									: ARRAY [1..2] OF DWORD;//轴报警信息-收A
	adwAlarmDetail_RW_B									: ARRAY [1..2] OF DWORD;//轴报警信息-收B
	adwPrnLen_AmountTo									: ARRAY [1..2] OF DWORD;(*总计印长lrPrnLen_AmountTo/AB系*)
	adwPrnLen											: ARRAY [1..2,1..3] OF DWORD;(*A轴印长/B轴印长/总印长/alrPrnLen*)
	(*2025.9.15.203631||摆臂类型放双向区域
	abyAIType_Uw										: ARRAY [1..2] OF BYTE;(*放料摆臂类型/byAIType_Uw*) 
	abyAIType_Rw										: ARRAY [1..2] OF BYTE;(*收料摆臂类型/byAIType_Rw*) 
	abyAIType_If										: ARRAY [1..2] OF BYTE;(*放牵摆臂类型/byAIType_If*) 
	abyAIType_Of										: ARRAY [1..2] OF BYTE;(*收牵摆臂类型/byAIType_Of*) 	
	*)
//2025.12.30.224455增加放料收料迭代次数显示||8-8=0
	aiMaxIterateCnt_LQR_Uw								: ARRAY [1..2] OF INT;(*迭代次数*)	
	aiMaxIterateCnt_LQR_Rw								: ARRAY [1..2] OF INT;(*迭代次数*)	
//	abyRsvData_20										: ARRAY [1..8] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计216字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
//	增加收放料补偿转速值2025.12.30.224748||4*4=16||44-16=28			
	arWuCompensate_Act_Uw								: ARRAY [1..2] OF REAL;	//放料补偿转速
	arWuCompensate_Act_Rw								: ARRAY [1..2] OF REAL;	//收料补偿转速
//2025.12.31.111850增加压力传感器当前值	|8字节|28-8=20
	arCur_PressureValue									: ARRAY [1..2] OF REAL;//第二牵引压力传感器当前值
	abyRsvData_5										: ARRAY [1..20] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	arValue_DiaMeasure									: ARRAY [1..2] OF REAL;(*卷径测量采样值*)	                               		
	adwEnc_AxisALocation_Uw								: ARRAY [1..2,0..1] OF DWORD;(* 放料A轴定位位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)
	adwEnc_AxisALocation_MinDiam_Uw						: ARRAY [1..2,0..1] OF DWORD;(* 放料A轴最小径位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)
	adwEnc_AxisBLocation_Uw								: ARRAY [1..2,0..1] OF DWORD;(* 放料B轴定位位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)
	adwEnc_AxisBLocation_MinDiam_Uw						: ARRAY [1..2,0..1] OF DWORD;(* 放料B轴最小径位置/索引通过BOOL_TO_INT(xCutterOnTop_#w)来访问 *)		                                        		
	adwEnc_AxisALocation_Rw								: ARRAY [1..2,0..1,0..1] OF DWORD;(* 收料A轴定位位置/一维索引通过BOOL_TO_INT(xCutterOnTop_Rw)/二维索引[0]表示3吋纸芯,[1]表示6吋纸芯 *)
	adwEnc_AxisBLocation_Rw								: ARRAY [1..2,0..1,0..1] OF DWORD;(* 收料B轴定位位置/一维索引通过BOOL_TO_INT(xCutterOnTop_Rw)/二维索引[0]表示3吋纸芯,[1]表示6吋纸芯 *)	                                        		
	arDiamCurAxis_Uw										: ARRAY [1..2] OF REAL;(* 放料当前卷径 *)
	arDiamCurAxis_Rw										: ARRAY [1..2] OF REAL;(* 收料当前卷径 *)	
//	arStdVol_Diam_Axis_Hmi									: ARRAY [1..2,1..4] OF REAL; (* 标准卷径对应的电压值|2019.1.25.142552|更名A轴 *)
//这里多出来了一些保持区域，32字节2026.5.15.101100
	abyData_Rsv_2										: ARRAY [1..64] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计216字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
	abyRsvData_6										: ARRAY [1..4] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

//2026.5.15.100742|界面只留有一个变量,这里就屏蔽了吧
//2026.5.15.100837
	abyData_Rsv_1										: ARRAY [1..64] OF BYTE;
//	arStdVol_Volt_AxisB									: ARRAY [1..2,0..1,1..4] OF REAL; (* 标准卷径对应的电压值|2019.1.25.142524|新增B轴 *)
	
 	byNum_StationList_Valid								: BYTE;(*当前状态下轴状态反馈轴数*)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////分界线-以上字节数统计64字节，凑齐220/////////////////////////////////////////////////////////////////////////////	
//2025.10.15.175953增加主排风，主刮刀，递墨、预热参数80字节|2025.10.15.180016|155-80=75
	awSTS_Scraper									: ARRAY [1..2] OF WORD;(* 刮刀状态/pdu上行给主站/ |.0 运行\停止
														 	              				  /.6 刮刀打开超时-
														 	                              /.7 485通讯断开标志*)
														  								  
	awSTS_InkRoller									: ARRAY [1..2] OF WORD;(* 递墨辊状态/pdu上行给主站 |.0 运行\停止
														 	              				   /.6 递墨辊刀打开超时
														  	                               /.7 485通讯断开标志*)
	awSTS_Exhaust									: ARRAY [1..2] OF WORD;	(*主排风状态*)																				   
	arHz_Scraper_CurrRD								: ARRAY [1..2] OF REAL;(* 刮刀当前回读频率/pdu上行给主站/ *)
	arHz_Scraper_CurrWR								: ARRAY [1..2] OF REAL;(* 刮刀当前写入频率/pdu下行给从站/ *)
	arHz_InkRoller_CurrRD							: ARRAY [1..2] OF REAL;(* 递墨辊当前回读频率/pdu上行给主站/ *)
	arHz_InkRoller_CurrWR							: ARRAY [1..2] OF REAL;(* 递墨辊当前写入频率/pdu下行给从站/ *)	
	arHz_Exhaust_CurrRD								: ARRAY [1..2] OF REAL;(*主排风反馈频率*)
	arHz_Exhaust_CurrWR								: ARRAY [1..2] OF REAL;(*主排风写入频率*)

	awSTS_PreHotAir									: ARRAY [1..2] OF WORD;	(*主排风状态*)																				   
	arHz_PreHotAir_CurrRD								: ARRAY [1..2] OF REAL;(* 刮刀当前回读频率/pdu上行给主站/ *)
	arHz_PreHotAir_CurrWR								: ARRAY [1..2] OF REAL;(* 刮刀当前写入频率/pdu下行给从站/ *)
//2025.10.20.133547增加放料自动接料剩余料长||rActRemainFilmLenth_Uw||niu.j|75-8=67
	arActRemainFilmLenth_Uw								: ARRAY [1..2] OF REAL;
//2025.10.20.134354增加收料自动接料模式计米值||rAutoMaticCuttingLenth_CurMode_Rw|niu.j|67-8=59
	arAutoMaticCuttingLenth_CurMode_Rw					: ARRAY [1..2] OF REAL;
//2025.10.20.150034增加预加热状态反馈值59-4=55
	awSts_PreHeating									: ARRAY [1..2] OF WORD;
	abyRsvData_7										: ARRAY [1..55] OF BYTE;
//////////////////////////////////////分界线-每隔一段数据增加些预留空间/////////////////////////////////////////////////////////////////////////////	
	abyRsvData_b										: ARRAY [1..2,1..440] OF BYTE;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(*2025.8.20.145825|ni.j|在这里增加面板IO输入和收放料IO输入测试*)
	awInput_IOtestDI_Main_If							: ARRAY [1..2,1..4] OF WORD;(*主面板IO测试输入*)
	awInput_IOtestAI_Main_If							: ARRAY [1..2,1..6] OF WORD;(*主面板IO测试输入*)
	awInput_IOtestDI_Main_Of							: ARRAY [1..2,1..4] OF WORD;(*主面板IO测试输入*)
	awInput_IOtestAI_Main_Of							: ARRAY [1..2,1..6] OF WORD;(*主面板IO测试输入*)
	awInput_IOtestDI_Uw									: ARRAY [1..2,1..5] OF WORD;(*主面板IO测试输入*)
	awInput_IOtestAI_Uw									: ARRAY [1..2,1..10] OF WORD;(*主面板IO测试输入*)
	awInput_IOtestDI_Rw									: ARRAY [1..2,1..5] OF WORD;(*主面板IO测试输入*)
	awInput_IOtestAI_Rw									: ARRAY [1..2,1..10] OF WORD;(*主面板IO测试输入*)
	abyRsvData_8										: ARRAY [1..20] OF BYTE;
	
(*IO测试共200字节，干脆新开个包吧-增加一个220-，剩余20*)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

	astStSts_UnitParam									: ARRAY [1..MAX_UNIT_NUM] OF StSts_UnitParam;
	astStSts_UnitParam_2								: ARRAY [1..MAX_UNIT_NUM] OF StSts_UnitParam_2;			
																   
END_STRUCT
END_TYPE

{IMPLEMENTATION}
