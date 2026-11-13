/*
 * comm.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef COMM_H_
#define COMM_H_

#include "base.h"
#include "gt_rn_struct.h"
#include <stdint.h>

#define PDUCOMM_TIMEOUT_CYCLECNT 150//pdu通讯超时周期计数

#pragma pack(1)
typedef struct{
	BYTE abyBaseline_Max[2];
	BYTE abyBaseline_Min[2];	
	//2023.09.18.135925 同步
	//(*2023.09.04.094608 修改*)
	INT iVerror_FollowPreUnit 		;//: INT; (*纵向跟前一色误差*)
	INT iVerror_Follow1Unit 		;//: INT;(*纵向跟1色误差*)
	
//(*2025.6.5.112746 取消横向误差的通讯@这几个值只是监控不使用|替换为脉冲输出相关返回*)
	//INT iHerror_FollowPreUnit 		;//: INT; (*横向跟前一色误差*)
	//INT iHerror_Follow1Unit 		;//: INT;(*横向跟1色误差*)
	//(*2025.6.5.094218+脉冲输出相关返回*)
	WORD wPulse_Rd;//:WORD;(*输出的脉冲数@单位Pulse,只针对新款16d|上位机做增量累加处理*)
	BYTE byStsBit;//:BYTE;(*arm 返回的一些状态bit	 |.\0 脉冲输出中@只针对新款16d
										// 		 |.\1 油墨槽脉冲控制到位标志
										 //		 |.\2 .\3 油墨槽脉冲控制输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常| *)
	BYTE abyReserved_;

	short iVerror_Follow1U_New;//间接跟1色误差
	WORD uiFSampleCounter	;//(*色组精采样计数索引|*)
	//2024.8.28.171310||暂时不用|\保存点其他东西|
	DWORD dwSlaveVer;//从站版本号2024.9.14.095654恢复通讯版本号

}StCMD_05;//(*最大20B字节|*)

//06#
typedef struct{
	WORD wHz_UnitInkRoller_CurrRD;//上报的递墨辊当前频率/实际从变频器内读取的值
	WORD wSTS_UnitInkRoller;//上报的递墨辊变频状态

	WORD wHz_UnitScraper_CurrRD;//上报的刮刀当前频率/实际从变频器内读取的值
	WORD wSTS_UnitScraper;//上报的刮刀变频状态

	WORD wHz_UnitHotWind_CurrRD;//热风频率2022.3.31.110826
	WORD wSTS_UnitHotWind;//热风1变频状态
	
//(*2025.6.5.090341+屏蔽热风2的通讯 替换为byStsBit->abyRsv_0*)
	//WORD wHz_UnitHotWind2_CurrRD;//热风频率2022.3.31.110826
	//WORD wSTS_UnitHotWind_2;//热风2变频状态

	//(*2025.10.17.091615+ 没空间了(不够4byte)才出此下策！*)
	//(*横向编码器值=iEncValue_Hor<<16 | byEncValue_Hor_L8@共24bit数据*)
	BYTE byStsBit;//:BYTE;(*一些状态位|\.0 横向编码器值有效*)
	INT iEncValue_Hor;//:INT;(*横向编码器值*)
	//(*2025.10.17.091648+ 横向编码器值的低8bit@和iEncValue_Hor拼接为24bit编码器数据*)
	BYTE byEncValue_Hor_16To23bit;
	//BYTE abyRsv_0;


	//2023.5.18.154112不要这两个变量了，现已经增加了双波门精采样计算了，不需要粗采样的值了
	//更改为占用一个字节通讯计数值，另外三个预留
	//INT iHError_Follow1U;
	//INT iRtn_CalcError_Follow1U;
	BYTE byCnt_Comm;
	//5\6号命令时分时传输，为了保证精采样计数值不突变,在6号命令中也增加精采样计数值
	//2023.09.19.160725 6号命令也增加该值
	WORD uiFSampleCounter	;//(*色组精采样计数索引|*)
	BYTE abyRSV[1];
	//2022.8.2.135712占用4字节处理横向跟1色误差上传
//	BYTE byArmRunNum;
//	BYTE abyRsv[3] ;
}StCMD_06;//(*最大20B字节|*)

typedef struct{
	INT iCurLabelPos ;//(*本色三角标位置，点数*)
	INT iPreLabelPos ;//(*前色三角标位置，点数*)
	BYTE byFlag_CommFromSlave					;//(*bit0 xFlag_FindFirstSuccess;bit1 xFlag_FindPreSuccess
													//,bit 2 //从站本次寻找寻找成功**)
	BYTE byDetectedSignalCount ;//(*当前检测到色标个数*)
	BYTE byMarkStep;//当前全自动套印步骤
	BYTE byWidthRS;//粗采样计算色标宽度 0.1mm
	INT iWidth_FindMarkCenter;//(*精采样计算出来的宽度*100*)
	BYTE abyRsv[9];
	BYTE byRsv;
}StCMD_07;//(*最大20B字节|*)

//31#命令
typedef struct{
	DWORD udiVelocity				;			// DWORD;(*主机运行速度<单位:0.01m/min>|*)
	DWORD dwAxis_RollerDn			;			// DWORD;(*所有轴的压辊状态|bit0=1U,...,bit31=32U|*)
	DWORD dwAxis_Alarm				;			// DWORD;(*轴报警位状态|bit0=1U,...,bit31=32U|*)
	DWORD dwStation_AlarmId			;			// DWORD;(*站报警id|*)
	DWORD dwAxis_SkipTheHeader		;			// DWORD;(*让料头位状态|bit0=1U,...,bit31=32U|*)
	SINT siUMax						;			// SINT;(*最大机组号|*)
	SINT siUId						;			// SINT;(*映射机组号|*)
	SINT siUId_Current				;			// SINT;(*上位机当前操作机组号|*)
	INT iCurveViewMaxRange			;			// INT;(*误差曲线量程上限|*)
	BYTE bySignalGain				;			// BYTE;(*信号放大增益|bit3~0:T1信号增益|bit7~4:T2信号增益|2018.4.10.161154|*)
	WORD wComplexBitFields			;			// WORD;(*复合位域描述|2018.4.10.154830|*)
												//	(*
												//	*.bit0:整机波门锁;
												//	*.bit1:整机纵向自动|
												//	*.bit2:整机横向自动|
												//	*.bit3:整机套色报警开关|
												//	*.bit4:整机反转|
												//	*.bit5:色组反转|
												//	*.bit6:放料当前轴|
												//	*.bit7:收料当前轴|
												//	*.bit8:套色使能|
												//	*.bit9:印刷标志|
												//	*.bit10: 标志变化用来作为单标记确认功能|2018.12.1.110505|
												//	*.bit11:隐藏报警值的显示|2018.5.1.101054|
												//	*.bit12:隐藏误差值的显示|2018.5.1.101057|
												//	*.bit13:状态发生变化时|无论是上升沿还是下降沿都是用来清除历史曲线的|2018.5.2.173805|
												//	*.bit14:标记系统是否是双收双放|如果是则界面上要显示A.B系指示|否则就要隐藏|
												//	*.bit15:要求显示调试信息|
												//	|*)
}StCMD_31;

//32#命令
typedef struct{
//单片机不支持double型数据，将协议中的LREAL转换成REAL通讯
//每个REAL+DWORD占8个字节
	BYTE  byGrpId					;			 //BYTE;(*系id|*)
	BYTE  byMarkTypeId				;			 //BYTE;(*标记形式|*)
	BYTE  byMarkArrangeModalId		;			 //BYTE;(*标记排列形式|*)
	BYTE  byColorIdCurrent			;			 //BYTE;(*当前色序|*)
	REAL lrAlarmV					;			 //REAL;(*纵向报警|*)
	//DWORD dwRes1_32					;
	BYTE  dwRes1_1_32;
	BYTE  dwRes1_2_32;
	BYTE  dwRes1_3_32;
	BYTE  dwRes1_4_32;
	REAL lrAlarmH					;			 //REAL;(*横向报警|*)
	BYTE byFollowColorId;

	//2024.7.31.171829替换
	//BYTE abyRsv[3];//2024.2.17.094114
	BYTE byFakeThreshold_V		;//: BYTE;(*纵向飞点阈值@丝*)
	BYTE byFakeThreshold_H		;//: BYTE;(*横向飞点阈值@丝*)
	BYTE byAve_v_extra_V		;//	: BYTE;(*套色误差显示平均次数*)
	//	DWORD dwRes2_32					;
	REAL lrGirth					;			 //REAL;(*版周长|*)
	WORD wHotWind_Print;//热风打开色组号//2022.6.29.154717
	//2024.8.14.093126同步
	BYTE bySysSamplePrecision;//	: BYTE;(*系统套色采样精度-单位是丝@2024.8.7.160236+*)
	BYTE byArcFineSampleType;//			: BYTE;(*套色采样方式@=0默认波门宽度mm|还没使用呢*)
	//(*	diRsv03					: WORD; (* 保留 *)*)

}StCMD_32;

//33#命令
typedef struct{
//(*2025.6.4.155432 取消rDeadzoneV 通讯*)
//	REAL lrDeadzoneV						;			// REAL;(*纵向不工作区|*)
	//(*2025.8.11.210337 替换diRsv00*)
	//DWORD diRsv00								;//: DINT;
	WORD uiSource_Light_T1_Cur				;//: UINT;(*当前光源亮度@原始值*1000*)
	WORD uiSource_Light_T2_Cur				;//: UINT;(*当前光源亮度@原始值*1000*)
	
	//2023.11.08.103611 同步|为了不破坏原来的结构。使用dwRes1_33位置
	WORD wUnit_input_I; //色组I输入
						   //Bit0: i_xLinkage; //联动
						   //Bit1: i_xInch;//单运行
						   //Bit2: i_xEstop; //急停输入
						   //Bit3: i_xAlarmBell; //警报
						   //Bit4: i_xLittleAdj; //细调
						   //Bit5: i_xPressMode_Auto; //自动合压
						   //Bit6: i_xPress;  //合压输入
						   //Bit7: i_xUnPress; // 离压输入
						   //Bit8: i_xUnPress_Inching; //点动离压
						   //Bit9: i_xMove_Up; //纵向上
						   //Bit10: i_xMove_Down; //纵向下
						   //Bit11: i_xPosLimit_Left; //横向左限位
						   //Bit12: i_xMove_Left; //横向左
						   //Bit13:
						   //Bit14:
						   //Bit15: wU_IO_Monitoring_Flag; // IO监控标志位
	WORD wUnit_input_II;//色组II输入
							//Bit0: i_xMove_Right；// 横向右
							//Bit1: i_xPosLimit_Right; //横向右限位
							//Bit2: i_xHorzMotor_FastSpd; //横向电机快
							//Bit3: i_xCoolBlower; //冷风开关
							//Bit4: i_xCoolBlower_Button; //冷风按钮
							//Bit5: i_xHotBlower_Err; //热风报警
							//Bit6: i_xHotBlower; //热风开关
							//Bit7: i_xHotBlower_Button; //热风按钮
							//Bit8: i_xTemReachToTarget; //温度达到预设
							//Bit9: i_xHeating_I; //加热I档
							//Bit10: i_xHeating_II; //加热II档
							//Bit11: i_xHeating_III; //加热III档
							//Bit12: i_xHeating_Button; //加热按钮


//(*2025.6.4.155432 取消lrDeadzoneMinH通讯*)
	//REAL lrDeadzoneMinH					;			// REAL;(*横向最小不工作区|*)
	//DWORD diRsv01							;//	: DINT;
	//2023.11.08.103611 同步|为了不破坏原来的结构。使用dwRes2_33中低word位置
	//(*2025.9.26.110946 替换使用*)
	BYTE byDriverType_Hmi485;//					: BYTE;(*从站人机485递墨辊和刮刀等驱动器类型|
							//					默认:吉泰科;
							//					= 1: 汇川;
							//					.....*)
	BYTE byRev02		   ;//					: BYTE;
	BYTE byRev03		   ;//					: BYTE;
	//2026.4.22.150516 替换
	//BYTE byRev04		   ;//					: BYTE;
	BYTE xRsMorphFilter		;//	:BOOL;(*粗采样美化标志*)

	WORD wUnit_input_III;//色组III输入
							//Bit0: i_xScraperInveterError; //刮刀变频报警
							//Bit1: i_xScraperOn; //刮刀开关
							//Bit2: i_xAirExhaustSwitch; //排风开关
							//Bit3: i_xInkRoller_CW; //递墨辊正转
							//Bit4: i_xInkRoller_Up; //递墨辊上
							//Bit5: i_xAirExhaustButton; //排风按钮
							//Bit6: i_xAcc; //加速
							//Bit7: i_xDec; //减速
							//Bit8: i_xStop; //停机
							//Bit9: i_xFastStop; //快停
							//Bit10: i_xPtcSignal; //PTC过温
							//Bit11: i_xLostPressure; //顶板松

	//(*2025.4.25.142136+ 用户权限通讯*)
	//WORD wRes2_33					;           // 2023.10.14.161111
	BYTE byCurrUsrLevel;//						: BYTE;
	
//(*2025.6.4.155432 取消rDeadzoneMaxH通讯*)
//(*byRes2_33+rDeadzoneMaxH+diRsv03 平替为了abyReserved_*)
	/*
	BYTE byRes2_33		;//					: BYTE;
	
	REAL lrDeadzoneMaxH					;			// REAL;(*横向最大不工作区|*)
	DWORD dwRes3_33					;
	*/
	//INT iRsv02					;//		: DINT;
	//(*2025.6.4.232600+byDriverType_Hor|1->0*)
	//(*2025.6.4.232600+wPulseCtlInf-->iInkGrooveCtlMsg|9->1*)
	//(*2025.6.5.114655 横向使用的设备类型,控制横向编码器值的返回算法|*)
	BYTE byDriverType_Hor;//:BYTE;(*横向的驱动类型(都是需要arm->主站方式获得编码器值)
							//	|0:默认同步电机\步进电机(不带反馈)-也就是不要编码器值
							//	|1:步进电机(带反馈)
							//	|2:汇川*)

	//(*2025.6.4.232406+*)
	//(*步进脉冲输出控制变量@和新款16d通讯|起始速度频率和加速时间参数再arm里写死为10r/min&100ms(使用宏定义的方式)*)
	WORD wPulseCtlInf						;//: WORD;(*脉冲控制的信息@速度模式就是速度值(puls/s),位置模式就是距离(丝-最大655mm)*)
	WORD wPulse_1r							;//: INT;(*1圈的脉冲数*)
	BYTE byPulseCtl_DisPerPulse				;//: BYTE;(*单位脉冲的距离@0.1um/pulse|最大输入就是0.025mm/pulse*)
	BYTE byPulseCtlBit						;//: BYTE;(*脉冲控制bit@bit0:脉冲控制使能
														//bit1:运动使能@再次使能才能启动下次运动
														//bit2:电机方向
														//bit3: 0：速度模式，1：位置模式(超过最大位置值|使用先速度后位置的方式)
														//bit4: 反馈脉冲数清零
														//*)
	INT iInkGrooveCtlMsg					;//: INT;(*油墨槽控制的信息@用于从站人机显示*)

	WORD wSwitchRef				;			// WORD;(*色组的开关状态|*)
	BYTE byAverageV				;			// BYTE;(*纵向平均值|*)
	BYTE byAverageH				;			// BYTE;(*横向平均值|*)	
	
}StCMD_33;

//34#命令
typedef struct{
	INT iGateWidthPhy						;	// INT;(*波门宽度|*)
	INT iGateWidthRoundPts					;	// INT;(*波门占据的粗采样点|*)
	INT iGateWidthFinePts					;	// INT;(*波门占据的精采样点|*)
	WORD uiNum								;	// UINT;(*减速比分子|*)
	WORD uiDen								;	// UINT;(*减速比分母|*)
	BYTE byTriangleMark_SideC				;	// BYTE;(*梯标内三角形纵向边长|*)
	BYTE byTriangleMark_SideB				;	// BYTE;(*梯标内三角形横向边长|*)
	INT iCompanyId							;	// INT;(*企业id|*)
	BYTE byLanguageId						;	// BYTE;(*操作语言id|*)
	BYTE xReqRecordSampleData				;	// BOOL;(*请求保存采样数据|2017.8.22.103408|*)
	BYTE byDeputyProf						;	// BYTE;(*2017.9.1.112943|将副主站的标志和站号传下去|bit7=1标识有副主站|bit6~bit0为副主站的站号|*)
	INT iSampleCfgParam_Ctl					;	// INT;(*2018.4.10.161837| 采样控制参数里的ctl|*)
	BYTE byMinutes_ScrAutoSleep				;	// BYTE;(*屏幕自动休眠时间|单位:minute|2019.4.15.101634|*)
	DWORD dwControlComplexBits				;	// DWORD;(*同步等于StSystemExtInfo.dwControlComplexBits|2019.5.23.092401||*)
	WORD wSts_HorzManuPreReg				;	// WORD;(*横向手动预套准状态标志|*)
	INT iPos_HorzManuPreReg					;	// INT;(*横向手动预套准位置|*)
}StCMD_34;

//35#命令
typedef struct{
	DWORD dwKpid_V						;	// DWORD;
	DWORD dwKpid_H						;	// DWORD;
	DWORD dwComplexFlag_AxisInchRunning	;	// DWORD;(*2019.4.2.182326|所有轴的单运行状态|*)
	DWORD dwComplexFlag_AxisLinkage		;	// DWORD;(*2019.4.2.182326|所有轴的联动状态|*)
	DWORD dwComplexFlag_AxisEStop		;	// DWORD;(*2019.8.21.113250|轴急停完全标志|传输轴所在的系内标志|*)
	//2025.10.28.165455同步
	//2025.12.1.092255
	BYTE xArmUpdating					;
	BYTE byUnLockHmi_UI;//2026.1.31.145012+(*解锁ui界面	|/.0 heating_etc-刮刀界面
						//|/.1 heating_etc-递墨界面
						//|/.2 heating_etc-热风界面
						//|/.3 heating_etc-加热界面
						//|/.4 heating_etc-排风界面@.0~.4有一个有效，heating_etc界面可以进入
						//|/.5 主界面热风风门界面*)
	BYTE abyRESERVED0[2];//	: ARRAY [1..4] OF BYTE;
					//2026.1.31.145056+byUnLockHmi_UI|3->2
					//2025.12.3.094328+xArmUpdating|4->3
	//WORD wMCGSButtonStaton;
	//WORD wTemperature_Feedback          ;//加热温度反馈值|2020.12.11.094135
	WORD wGrpVel;
	//2023.5.18.160709
	BYTE bySts_Flag;//2022.6.29.153725预留剩1-0：停机，1。印刷，2：空转，3：急停
	//增加了滤波次数下发2024.8.31.153159
	unsigned short byFilterNum_PeakValue_FineData;
	//2024.8.31.153052占用了	BYTE abyRESERVED[1]				;	// ARRAY [1..8] OF BYTE;
										//	2020.12.5.134038wMCGSButtonStaton-从站按钮备用功能-》6
										//	(*2019.8.21.113324|max12->max8|*)
										//	(*2019.4.2.182636|max20->max12|*)
}StCMD_35;

//36#
typedef struct{
	WORD wHz_UnitInkRoller_CurrWR	;//递墨辊当前下发频率/是需要写到人机里的
	WORD wHz_UnitScraper_CurrWR		;//刮刀当前下发频率/是需要写到人机里的
	WORD wHz_UnitHotWind_CurrWR		;//刮刀当前下发频率/是需要写到人机里的
	WORD wHz_UnitHotWind2_CurrWR	;//刮刀当前下发频率/是需要写到人机里的
	REAL rPV_UnitTemCtl				;//主站下发的该色组当前温度
	WORD wSTS_UnitTemCtl			;//主站下发的改色组当前温控状态

	//2022.9.23.105230增加一键对版相关
	BYTE byWidth_Mark_Max						;//(*单个色标最大宽度-0.1mm*)
	BYTE byWidth_Mark_Min						;//(*单个色标最小宽度-0.1mm*)
	BYTE byMaxGap						;//(*最大间隙，-0.1mm*)
	BYTE bySimilarityThreshold								;//(*相似度阈值40%-70%,*)
	BYTE bySpotWidth								;//(*光斑宽度*10*)
	//2022.9.23.105230增加一键对版相关
	BYTE byFlag_CommFromMaster;
	BYTE byMeanOffset							; //(*均值偏移 越大越找不到小色标，太小会出现较多信号导致直接失败*)
	uint8_t byOuterCoff;//外滑窗系数 *10
	uint8_t byInnerCoff;//内滑窗系数 *10
	BYTE abyRsv[4];//预留
	BYTE byCustomInterface; //(*定制界面编号2025.12.15.110612 *)
}StCMD_36;

//37#
typedef struct{
	//(*2026.04.14.131400||wang.xy添加模版通讯*)
	int16_t aiCurModeMidPoint[4];//当前色模版中心
	uint8_t abyCurModeRadius[4];//当前色模版半径
	int16_t aiPreModeMidPoint[4];//前一色模版中心
	uint8_t abyPreModeRadius[4];//前一色模版半径
	BYTE abyRsv[4];//预留
}StCMD_37;

typedef struct{
	INT iPackId				;//(*数据包索引|*)
	BYTE abyPayload[20]		;//(*通讯净荷数据|*)
	WORD wCHK				;//(*校验码|*)
	INT iVerror				;//(*纵向套印误差|*)
	BYTE byStsV				;//(*纵向套印状态|*)
	BYTE byIndexV			;//(*纵向套印误差索引|*)
	INT iHerror				;//(*横向套印误差|*)
	BYTE byStsH				;//(*横向套印状态|*)
	BYTE byIndexH			;//(*横向套印误差索引|*)
}StPara_PduBroadcastUp;//色组->主站

typedef struct{
	INT iPackId			;//(*包id|*)
	BYTE abyPayload[28]		;//(*通讯净荷|*)
	WORD wCHK			;//(*校验码|*)
}StPara_PduBroadcastDn;

typedef struct{
	DWORD dwSyncFlag				;			//: DWORD;(*同步信号标志|*)
	DWORD dwPlateAdjustmentProf		;		//: DWORD;(*版调整量\bit24~bit31为请求信号\低24bit用来表示要调整的量<单位:0.01mm>|*)
	WORD wStatusRef					;		//: WORD;(*工作状态|*)
	WORD wReserved					;		//: WORD;(*控制标志|*)
	INT iGateSa						;		//: INT;(*波门地址|*)
	INT iGateSaEx					;		//: INT;(*波门地址2|*)
	REAL lrAdjust_V					;		//: LREAL;(*纵向版修正量|*)
	//DWORD dwRes1_Mail;拆分成两个word型wRes1_Mail+wArmResetCount|2020.6.29.154418
	WORD wRes1_Mail                 ;
	WORD wArmResetCount             ;//看门狗计数
	REAL lrAdjust_H					;		//: LREAL;(*横向版修正量|*)
	WORD wButtonFun;//2020.12.5.134104|预留空间作为人机按钮上传给主站
	DWORD dwAxisControlBits			;		//: DWORD;(*轴控制位|2019.3.28.152546||*)						;
	//(*--------------------------------------------------|2019.8.28.091013_*)
	INT iJourney_HorzRapidAdjust	;		//: INT;(*横向快速调整距离|*)
	//以上38BYTE，为MCGS增加以下通讯内容，大小8BYTE|2020.12.11.094119

	//2025.10.28.165143屏蔽容易混淆的变量
	BYTE abyReserved_1[2];
	//WORD wInkRoller_Fre				;//递墨辊频率
	WORD wAirInletWindDoorValue		;//进风口风门开度值|输入范围(0~100)
	WORD wAirExhaustWindDoorValue	;//排风口风门开度值|输入范围(0~100)
	WORD wAirReturnWindDoorValue	;//回风口风门开度值|输入范围(0~100)
	//2025.10.28.165143屏蔽容易混淆的变量
	BYTE abyReserved_2[2];
	//WORD wTemperature_Set           ;//加热温度设置SV
	BYTE bySampleSholdSwitch		;//从站阀值选择开关
	WORD wUpAdjButton_Count     ;//MCGS调整上按钮计数
	WORD wDnAdjButton_Count;//MCGS调整下按钮计数
	WORD wLeftAdjButton_Count;//MCGS调整左按钮计数
	WORD wRightAdjButton_Count;//MCGS调整右按钮计数
	WORD wAlarmButton_Count;//MCGS报警按钮计数
	WORD wMCGS_SingleSwitch;//MCGS单向开关

	//2025.10.28.165143屏蔽容易混淆的变量
	BYTE abyReserved_3[25];
	//2021.10.27.090939||新增奥特马兼容
	//REAL rHz_AxisInkRoller_ManuallySet		;// REAL; (* ?REAL/??????????/??:Hz/@2020.11.6.142249 *)
	//REAL rCoeff_AxisInkRoller_Automatic		;// REAL; (* ?REAL/?????????/@2020.11.6.142249 *)
	//REAL rHz_AxisAirBlowning_ManuallySet	;// REAL; (* ?REAL/???????????/??:Hz/@2020.11.6.142249 *)
	//REAL rHz_AxisAirExhaust_ManuallySet		;// REAL; (* ?REAL/???????????/??:Hz/@2020.11.6.142249 *)

	//(*2021.7.19.161122-??????*)
	//WORD wSV_TemCtrl						;// ; (* ????/????? *)
	//WORD wSV_TemCtrl_PreHot					;// ; (* ????/????? *)
	//(*2021.7.21.135342 ???????|??????-->?*)
	//BYTE byAxisRoller_UpperFrq				; //;(*???????*)
	//REAL rAxisRoller_Frq					; //;(*???????*)

	DWORD dwCtlBits_UnitBaseCraft;//对应StAxisParam.dwCtlBits_UnitBaseCraft
	WORD wHz_UnitInkRoller_ManuallySet;//StAxisParam.rHz_UnitInkRoller_ManuallySet*100
	WORD wCoeff_UnitInkRoller_Auto;//StAxisParam.rCoeff_UnitInkRoller_Auto*100
	WORD wHz_UnitScraper_ManuallySet;//StAxisParam.rHz_UnitScraper_ManuallySet*100
	WORD wCoeff_UnitScraper_Auto;//StAxisParam.rCoeff_UnitScraper_Auto*100
	WORD wHz_UnitHotWind;//StAxisParam.rHz_UnitHotWind*100
	WORD wHz_UnitHotWind_2;//StAxisParam.rHz_UnitHotWind_2*100
	WORD wSV_UnitTemCtl;//StAxisParam.rSV_UnitTemCtl*100
	//2022.7.3.114828加减速按钮
	WORD wAccButton_Count;
	WORD wDecButton_Count;

	//2023.11.08.095353 同步
	//2023.10.14.100557/wei.n/7吋人机色组IO与ARM通讯
	WORD wUnit_output_I;//色组I输出
							//Bit0: o_xLamp_Linkage; //联动指示
							//Bit1: o_xLamp_Inch; //单运行指示
							//Bit2: o_xLamp_Estop; //急停灯输出
							//Bit3: o_xLamp_Normal; //套色正常
							//Bit4: o_xLamp_Warning; //套色报警
							//Bit5: o_xLamp_Lost; //套色丢失
							//Bit6: o_xHorzMotor_CW; //横向正转输出
							//Bit7: o_xRel_ArcAlarm_Unit; //本组套色报警
							//Bit8: o_xRel_Press; //和压输出
							//Bit9: o_xHorzMotor_CCW; //横向反转输出
							//Bit10: o_xLamp_AxisError; //轴故障指示
							//Bit11: o_xRel_UnPress; //离压输出
							//Bit12: o_xRel_CoolBlower; //冷风输出

	WORD wUnit_output_II;//色组II输出
							//Bit0: o_xRel_HotBlower; //热风输出
							//Bit1: o_wInExhaustAir; //色组排风输出
							//Bit2: o_xRel_Heating_I; //加热I输出
							//Bit3: o_xRel_Heating_II; //加热II输出
							//Bit4: o_xRel_Heating_III; //加热III输出
							//Bit5: o_xScraperOn; //刮刀使能
							//Bit6: o_xRel_InkRoller_CW; //递墨辊正转
							//Bit7: o_xRel_InkRoller_Up; //递墨辊上

	//2025.7.23.203456 增加光纤电眼需要的参数通讯


	//2025.7.23.204942+
	uint16_t	uiOffset_T1;			  	//T1路光纤偏移/1000
	uint16_t 	uiSource_Light_T1;        //T1路光纤光源/1000
	uint16_t	uiBias_T1;			  	//T1路光纤电眼偏置/1000
	uint16_t	uiBrightness_Light_T1; 	//T1路光纤电眼亮度/1000

	uint16_t	uiOffset_T2;			  	//T2路光纤偏移/1000
	uint16_t 	uiSource_Light_T2;        //T2路光纤光源/1000
	uint16_t	uiBias_T2;			  	//T2路光纤电眼偏置/1000
	uint16_t	uiBrightness_Light_T2; 	//T2路光纤电眼亮度/1000

	uint8_t	bySignalSelect;	//光纤电眼信号选择//当前波形通道选择
							//=1：主显 R 通道
							//=2：主显 G 通道
							//=3：主显 B 通道
	//2025.10.24.084811 最后一个字节
	uint8_t byArcSensorType;//:BYTE;(*套色传感器类型|=0 传统光电眼|=1 曜光接口(光纤电眼)*)

}StPara_MailboxAlternate;

//2024.02.01.105838 同步@liu.yt
// information of master-station program crash.
// 2024.1.18.093536/han.dp/+
typedef struct {
	uint32_t dwrunPostion;//wr函数最小单位是dword
	uint16_t wYear;
	uint16_t wMonth;
	uint16_t wDay;
	uint16_t wHour;
	uint16_t wMinute;
	uint16_t wSecond;
	uint32_t dwCpuInf;// double//2024.1.19.112621/变成dword
	uint32_t dwMemoryLoad;
	uint32_t dwTotalPhys;
	uint32_t dwAvailPhys;
	uint32_t dwTryLockNums;
	int32_t dwFileError;
	int32_t dwFileHandle;
	uint16_t wMemOperation;// BOOL
}
EXCEPTION_OF_CRASH, *LP_EXCEPTION_OF_CRASH;

typedef struct{
	BYTE o_xEno										;
	INT o_iErNo										;
	DWORD o_dwSampleConfigTimes						;
	BYTE o_xRecSampleData							;//(*2019.4.2.193659|采样保存标志|请绑定g_xRecSampleData|*)
}StSyncWithServerOut;
#pragma pack()

//CRC校验
//	i_pbyBuf								: POINTER TO BYTE; (*数据输入地址*)
//	i_iLen									: INT; (*数据量大小*)
//	i_pdwSumResult							: POINTER TO DWORD := 0; (*返回累加和*)
WORD KS_CRC(BYTE* i_pbyBuf,INT i_iLen,DWORD* i_pdwSumResult);
void KS_FB_SyncWithServer(
					BYTE i_xEn,
					BYTE i_iStationId					,
					BYTE i_xGotTheMailboxClock			,       //		: BOOL;(*拿到Mailbox传输周期|*)
					BYTE* i_pxGetAxisId					,       //		: POINTER TO BOOL;
					BYTE* i_pbySignal10VCoef,
					BYTE* i_pbyScanCount,
					BYTE* i_pbyLedSwitchTimeouts			,       //		: POINTER TO BYTE;
					INT* i_piJourney_HorzRapidAdjust		,       //		: POINTER TO INT := 0;(*2019.8.28.105803_|指向横向快速调整量变量|被读取以后会自动清零|*)
					DWORD* i_pdwPlateAdjustmentProf			,
					BYTE* i_pbyFineSampleSaveFlag,
					BYTE* i_pxFlag_CopyFromMaster			,//获取主站参数成功标志
					WORD* i_pwArmResetCount                 ,//看门狗计数值
					StAxisParam* i_pstStAxisParam,
					StGrpParam* i_pstStGrpParam,
					StGlobalParam* i_pstStGlobalParam,
					StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
					StPara_PduBroadcastDn* i_pstStPara_PduBroadcastDn,
					StSyncWithServerOut* i_pstStSyncWithServerOut,
					WORD i_iCount_TimeOutNum,
					DINT* pdiFineSampleStart,
					REAL i_alrBase[2],
					WORD i_wCnt_Rs,//2022.4.13.181712/粗采样计数值
					INT i_iRtn_Calc2022,//2022.4.13.182228/+
					INT i_aiVResult[2],//REAL i_arVResult[2],
					//REAL i_arHResult[2]
					INT i_aiHResult[2],//REAL i_arVResult[2],

					BYTE* i_pxFlag_SingleMode//2022.5.17.152932

);

INT KS_CfgAxisSampleParam(
		StAxisParam* i_pstStAxisParam,
		DINT* pdiFineSampleStart,
		DINT* i_pdiArgumentToArc,
		BYTE i_byArcFineSampleType);//(*套色精采样方式@=0 原来的20mm采样| =1 双眼采样所有色标@单个波门*)

//2024.8.21.190847--新误差计算-配采样不一样
INT KS_CfgAxisSampleParam_New(
		StAxisParam* i_pstStAxisParam,
		DINT* pdiFineSampleStart,
		DINT* i_pdiArgumentToArc);

INT KS_InitSample(INT i_iStationId);//激活本地采样

WORD Get_SampleParamUpda(short axis, short *cfg_data);

#pragma pack(1)
typedef struct{
	WORD wFLAG_RUN; //WORD;(*
				//	/ bit0: 运行状态-停机
				//	/ bit1: 运行状态-空转
				//	/ bit2: 运行状态-印刷
				//	/ bit3: 运行状态-故障
				//	/ bit4: 运行状态-急停
				//	/ bit5: 放料当前轴
				//	/ bit6: 放料上下裁
				//  / bit15:arm升级中标志 by liu.yt
				//	*)
	WORD wGRP_VEL;// WORD;(* 系当前速度*10 *)
	INT iDIAM_UW;//: INT;(* 放料当前直径 *)
	INT iDIAM_Pre_UW;//: INT;(* 放料预驱轴直径 *)
	INT iAI_IF;//: INT;(* 放牵摆臂*10 *)
	INT iAI_UW;//: INT;(* 放料摆臂*10 *)

	INT iCur_Rad_Uw;//: INT;(*放料翻转架当前弧度*10*)
	INT iAI_DIAMMEASURE_UW_CUR;//: INT;(* 监控值-电压*100 *)


	DWORD dwEncode_value;//:DWORD;(*当前编码器值*)

	BYTE byCurrUsrLevel;//: BYTE;
	INT iCOMPANYID;//: INT;(* 客户名称 *)
	DWORD	dwAxisALocation_Uw_U;//:;(*编码器定位放A*)
	BYTE i_byLanguageIndex;//(*语言类型|2025.2.8.095711*)

}stCMD_31_Deputy;

typedef struct{
	DWORD	dwAxisBLocation_Uw_U;//:;(*编码器定位放A*)
	DWORD	dwAxisALocation_Uw_D;//:;(*编码器定位放A*)
	DWORD	dwAxisBLocation_Uw_D;//:;(*编码器定位放A*)
	DWORD	dwAxisALocation_MinDia_Uw_U;//:;(*编码器定位放A*)
	DWORD	dwAxisBLocation_MinDia_Uw_U;//:;(*编码器定位放A*)
	DWORD	dwAxisALocation_MinDia_Uw_D;//:;(*编码器定位放A*)
	DWORD	dwAxisBLocation_MinDia_Uw_D;//:;(*编码器定位放A*)

}stCMD_32_Deputy;

typedef struct{
	DWORD dwSyncFlag				;			//: DWORD;(*同步信号标志|*)

	INT iGirth_Uw_A;//: INT; (*放A周长*)
	INT iGirth_Uw_B;//: INT; (*放B周长*)
	INT iGirth_Pu;//: INT;(*版周长*)
	INT iVelocity_Tar;//: INT;(*目标速度*)
	INT iAI_mid_Uw;//: INT;(*放料中位*)
	INT iAI_mid_If;//: INT;(*放牵中位*)
	BYTE byDir_Uw_If_AI;//: BYTE;(*放料放牵摆臂方向判断bit0:放料bit1:放牵*)
	WORD wKp_Uw;//: WORD;(*放料P*)
	WORD wKi_Uw;//: WORD;(*放料I*)
	WORD wKd_Uw;//: WORD;(*放料D*)
	WORD wKp_If;//: WORD;(*放牵P*)
	WORD wKi_If;//: WORD;(*放牵i*)
	WORD wKd_If;//: WORD;(*放牵d*)
	BYTE bySwitch_AutoCut_Uw;//: BYTE;(*放料自动裁切使能开关bit0:使能；bit1:剩余卷径方式bit2:剩余米数方式*)
	INT iDia_PaperRoller_Uw;//: INT;(*纸筒直径*10*)
	INT iFilmThickNess;//: INT;(*料模厚度*1000*)
	WORD wAutoMaticCutDia_Uw;//: WORD;(*剩余卷径方式卷径设定*)
	WORD wAutoMaticCutMeters_Uw;//: WORD;(*剩余米数方式米数设定*)
	WORD wActRemainFilmLenth_Uw;//: WORD;(*实际剩余料长-校正纸筒直径可用*)
	INT iAlarm_Uw_Dia ;//: INT;(*放料报警卷径设置*)
	INT iDelayMsec_CutterHolder;//: INT;(*刀架执行时间*)
	INT iDelayMsec_RollerCylinder;//: INT;(*压辊执行时间*)
	INT iDelayMsec_CutOffKnifeCylinder;//: INT;(*裁刀执行时间*)
	WORD uiMM_Roller2GummedTape;//: WORD;(*压辊胶带距离*)
	WORD uiMM_Roller2CutOfKnife;//: WORD;(*压辊裁刀距离*)
	WORD uiMM_CutOfKnife2GummedTape;//: WORD;(*裁刀胶带距离*)
	INT iCoefCut_FilmVolPerimeter_Uw;//:INT;(*放料裁切圈数*)
	INT iStepVariation4ChangeTime;//		: INT; (* 2018.9.30.100457/用来步进胶辊延时和裁刀延时的变化量 *)
	BYTE bySwitch_Compensate_Uw;//		: BYTE;(*放料翻转架补偿开关：Bit0:补偿开启,bit1:方向取反,bit2:0弧度确认*)
	WORD wDiam_Tower_Uw							;//: WORD;(*放料翻转架的直径|mm*)
	WORD wDiam_NextRoller_Uw				;//		: WORD;(*放料翻转架下个辊的直径|mm*)
	WORD wXPos_NextRoller_Uw				;//		: WORD;(*放料翻转架下个辊的X位置|mm|翻转架中心作为坐标系0点*)
	WORD wYPos_NextRoller_Uw				;//		: WORD;(*放料翻转架下个辊的Y位置|mm|翻转架中心作为坐标系0点*)
	WORD wDiam_DeflectorRoller_Uw		;//		: WORD;(*翻料架上导向辊的直径|mm*)
	WORD wDiam_DeflectorRollPos_Uw	;//			: WORD;(*ABjuli翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	BYTE byDiamMeasureTypeId;//: BYTE;(*卷径测量方式=0：电位器=1*)
	INT iStdVol_Diam_1;//: INT;
	INT iStdVol_Diam_2;//: INT;
	INT iStdVol_Diam_3;//: INT;
	INT iStdVol_Diam_4;//: INT;
	DWORD dwStdVol_Volt_AxisA_1;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_2;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_3;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_4;//: DWORD;
	INT iStdVol_Coef_Axis_1;//: INT;(* 卷径测量系数*1000 *)
	INT iStdVol_Coef_Axis_2;//: INT;
	INT iStdVol_Coef_Axis_3;//: INT;
	BYTE byIsDebug_DiaMeasureArea_Uw;//: BYTE;
	BYTE bySwitch_DiaMeasure;//: byte;(*bit0:自动卷径开关bit1:双轴biw2:弧面bit3:调试模式*)
	BYTE bySwitch_Enc_Uw;//: BYTE;(*放料编码器标定相关bit0:双轴系数bit1:调试模式
								//bit2:定位写入bit3:最小径写入*)
//2022.6.20.180546||以上40BYTES
//后续需求再增加
	//2023.09.18.155837 同步
	WORD wButton_Uw ; //2023.9.9.140626||按钮通讯|./0 放料写入按钮
}StPara_MailboxAlternate_Deputy;
#pragma pack()
//2025.10.29.165856+ by liu.yt
void KS_Led1Flick(uint16_t uiFlickTime_ms,uint16_t *ptimer_ms);//ptimer_ms 计时器,内部清零
//2025.7.22.142138|wei.n|移植
/*2025.09.06.151339//xi.hy//数码管控制*/
void KS_DigitalTubesCtl(
		uint16_t i_uinumDisplay,	 //需要显示的值
		uint8_t i_xpointDisplay,	 //是否需要显示右下角的点
		uint8_t i_byClose_DigitalTubes//关闭数码管显示
		);
//2025.09.06.151345//xi.hy//数码管显示站号处理
void KS_ShowId_DigitalTubes(uint16_t i_uiStationId,//站号
						   uint16_t* i_puiTime_DigitalTubes,//数码管显示的中断时间计数
						   uint8_t i_xpointDisplay);	 //是否需要显示右下角的点


void KS_FB_SyncWithServer_Deputy(
					BYTE i_xEn,
					BYTE i_iStationId					,
					BYTE i_xGotTheMailboxClock			,       //		: BOOL;(*拿到Mailbox传输周期|*)
					BYTE* i_pxFlag_CopyFromMaster			,//获取主站参数成功标志
					StAxisParam* i_pstStAxisParam,
					StGrpParam* i_pstStGrpParam,
					StGlobalParam* i_pstStGlobalParam,
					StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
					StPara_PduBroadcastDn* i_pstStPara_PduBroadcastDn,
					StSyncWithServerOut* i_pstStSyncWithServerOut	,
					BYTE* i_pxGetParam					       //		: POINTER TO BOOL;

);
#endif /* COMM_H_ */
