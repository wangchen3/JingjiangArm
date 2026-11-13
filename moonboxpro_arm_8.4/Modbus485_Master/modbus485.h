/*
 * modbus485.h
 *
 *  Created on: Jul 22, 2025
 *      Author: 17500
 */

/*
 * 2026.6.16.143624+
 * 为了减少申请的内存。将通讯的结构做了调整。
 * 通讯的最小单位只到寄存器区。且取消通讯列表的数据结构的申请
 *
 * */


#ifndef MODBUS485_H_
#define MODBUS485_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "stdint.h"
#include "base.h"


//宏定义
#define MODBUSNUM_MAX				1//最大通讯站个数
//#define REGISTER_AREA_MAX 			26//最大寄存器区
#define REGISTER_AREA_MAX 			27//最大寄存器区@2026.1.27.162409扩展了一个只写区域
#define MODBUS_VAR_MAX 				120//每个寄存器区 最大变量个数@word
#define CYCLEQUEUE_NUM				255//循环队列大小
#define SENDBUFF_NUM				255//发送buff个数
#define RECEIVEBUFF_NUM				255//读取buff个数
#define TRANSMIT_EN_485				1//发送@总线
#define RECEIVE_EN_485				0//接收@总线
#define TIME_TIMEOUT				100//超时时间100ms@单位是ms
#define TIME_COMMCYCLE				0//通讯周期收到就启动下次@单位是ms


#define POLLTIME 500 //ms轮询时间@过这么多时间切换使能标志
#define POLLID_SA 10//轮询区起始id@数组索引(实际是第11个区)
#define POLLID_ED 25//轮询区结束id@数组索引(实际是第26个区)
#define POLLNUM 4//轮询个数@目前是4个

//#define DEBUG_485

#ifndef FALSE
#define FALSE (0)
#endif
#ifndef TRUE
#define TRUE (1)
#endif


#ifndef RS485_TX_EN
// 2024.8.12.143329/wei.n/PA1引脚默认高电平-发送
#define RS485_TX_EN(x)   do{x?HAL_GPIO_WritePin(RS485_TX_EN_GPIO_Port,RS485_TX_EN_Pin,GPIO_PIN_SET) :\
						   HAL_GPIO_WritePin(RS485_TX_EN_GPIO_Port,RS485_TX_EN_Pin,GPIO_PIN_RESET);\
						  }while(0)			// 0, 接收  1,发送
#endif
//单字节封装
#pragma pack(1)

//数据类型枚举
typedef enum{
	KS_MB_TYPE_BYTE,
	KS_MB_TYPE_SINT,
	KS_MB_TYPE_USINT,
	KS_MB_TYPE_WORD,
	KS_MB_TYPE_INT,
	KS_MB_TYPE_UINT,
	KS_MB_TYPE_DWORD,
	KS_MB_TYPE_DINT,
	KS_MB_TYPE_UDINT,
	KS_MB_TYPE_REAL,
	KS_MB_TYPE_LREAL,
	KS_MB_TYPE_BOOL
}KS_EMBDataType;

typedef enum{
	INPUTREGISTER_RD=0x04,//(*读取输入寄存器功能码|操作只读区域*)
	HOLDREGISTER_RD=0x03,//(*读取保持寄存器功能码|操作可读写区域*)
	HOLDREGISTER_SINGLE_WR=0x06,//(*写单个保持寄存器功能码*)
	HOLDREGISTER_MULT_WR=0x10,//(*写多个保持寄存器功能码*)

	COIL_SINGLE_RD=0x02,//(*读取单个线圈*)
	COIL_MULT_RD=0x01,//(*读取多个线圈*)
	COIL_SINGLE_WR=0x05,//(*写单个线圈*)
	COIL_MULT_WR=0x0F//(*写多个线圈*)
}TyEnumModbusFunCode;
//2026.6.16.143939 屏蔽
//typedef struct{
//	uint8_t byType_RW;//(*读写属性|0-只读，1-只写，2-读写*)
//	uint32_t dwDataAdr;//(*操作的数据地址|如果需要保持型变量，绑定为变量地址|不需要保持则可以使用wValued地址*)
//	uint32_t dwDataBakAdr;//(*写入数据备份值的地址|2021.7.16.144944*)
//	uint16_t wValue;//(*值|可以不使用-没有对应变量就用该值*)
//	uint16_t wValueBak;//(*备份值|可以不使用-没有对应变量就用该值*)
//}StDataAttribute,*LP_StDataAttribute;

//寄存器区属性
typedef struct{
	uint8_t byType_RW;//(*读写属性|0-只读，1-只写，2-读写*)
	uint8_t byType_Data;//(*数据格式|Data Models. 0: Coils(RW)
												//1:Discretes Inputs(RO)
												//3:Input Registers(RO)
												//4:Holding Registers(RW) *)
	uint8_t xCommEn;//(*寄存器区操作标志|有效了才会处理*)
	uint16_t wModbusAdr;//(*寄存器区的首地址*)
	int16_t iRegisterNum;//(*寄存器区的个数*)
	//(*移动到寄存器区中2022.11.25.112917*)
	uint32_t dwxNeedReSendAdr;//(*有写操作的数据需要该变量控制再次写的地址|2022.6.15.094023*)
	//2026.6.16.144021 屏蔽
	//StDataAttribute astRegisterDate[MODBUS_VAR_MAX];//(*寄存器区中的数据*)
	uint32_t dwDataAdrSa;//数据的起始地址
	uint16_t awBackData[MODBUS_VAR_MAX];//备份的数据区数据内容
	uint8_t byFunCode;//寄存器区的功能码
}StRegisterAreaAttibute,*LP_StRegisterAreaAttibute;

//2026.6.16.143911 屏蔽
////寄存器区通讯变量列表
//typedef struct{
//	uint8_t xCommEn;//(*这个寄存器区域使能标志|2021.7.17.120629*)
//	//(*|地址是有效的|地址对应的值作为实际值|*)
//	StDataAttribute astDataAdrList[MODBUS_VAR_MAX];//(*数据属性列表|最大为总变量个数*)
//	uint16_t awData_Wr[MODBUS_VAR_MAX];//(*执行写入动作的时候每个寄存器写入的数据|不能被初始化@2023.7.20.191002*)
//	uint16_t wAdrSa;
//	int16_t iRegisterNum;//(*寄存器区里的寄存器个数@WORD的个数*)
//	uint8_t byFunCode;//(*功能码！*)
//	uint8_t byType_RW;//(*读写属性@需要根据byType_Data类型选择处理|0和4是允许自定义|0-只读，1-只写，2-读写*)
//	uint8_t byType_Data;//(*数据格式|Data Models. 0: Coils(RW)
//											//1:Discretes Inputs(RO)
//											//3:Input Registers(RO)
//											//4:Holding Registers(RW) *)
//	//(*移动到寄存器区中2022.11.25.112917*)
//	uint32_t dwxNeedReSendAdr;//(*有写操作的数据需要该变量控制再次写的地址|2022.6.15.094023*)
//
//}StModbusDataAdrList,*LP_StModbusDataAdrList;

//每个站id所有通讯的内容
typedef struct{
	uint8_t xCommEn;//通讯使能
	uint8_t byModbusId;//(*站号*)
	StRegisterAreaAttibute astStRegisterArea[REGISTER_AREA_MAX];//(*多个寄存器区定义|每个数字可以配置不同的寄存器区域-*)
}StData_Comm,*LP_StData_Comm;



//通讯的寄存器结构

//@只写-单个包最大120word
//寄存器0--119(120WORD)@人机地址从1开始
//只写动态变化数据,不稳定的数据
typedef struct tagDynaData_WO_485
{
	//int16_t		aiErrorBuff[80];	//纵向、横向误差队列，该队列主要用于上次更新误差队列到本次更新中间刷新的误差数，预计各留40个空间

	int16_t 	aiErrorBuff_V[40];
	int16_t 	aiErrorBuff_H[40];
	uint16_t	wBaseR_T1T2;	//信号基线R，高8位T1，低8位T2
	uint16_t	wBaseG_T1T2;	//信号基线G，高8位T1，低8位T2
	uint16_t	wBaseB_T1T2;	//信号基线B，高8位T1，低8位T2
	uint16_t	wMinDataR_Sample;	//信号最小值R，高8位T1，低8位T2
	uint16_t	wMinDataG_Sample;	//信号最小值G，高8位T1，低8位T2
	uint16_t	wMinDataB_Sample;	//信号最小值B，高8位T1，低8位T2
	int16_t		iVel_Axis;	//轴速度*10（保留1位小数）
	int16_t		iVel_Grp;	//系速度*10（保留1位小数）
	uint16_t	wIndex_ErrNum;	//高8位采样索引，低8位误差刷新幅数
	int16_t		iArcAlarm_V;	//纵向报警值
	int16_t		iArcAlarm_H;	//横向报警值
	uint16_t	wFlag_Arc;	/*套色相关标志
								bit0～bit6:色标形式，
								bit7～bit11:色标顺逆序
								bit12:压辊状态，
								bit13双波门状态
								bit14:波形显示样式（棍棍图/原始图）
								bit15:波门锁*/
	uint16_t	wLED_485Cnt;	//高8位：屏保图片，低8位485通讯计数
	uint16_t	wUnit_input_I;	//IO监控
	uint16_t	wUnit_input_II;	//IO监控
	uint16_t	wUnit_input_III;//IO监控
	uint16_t	wHz_UnitInkRoller_CurrWR;	//递墨辊频率
	uint16_t	wHz_UnitScraper_CurrWR;	//刮刀频率
	uint16_t	wHz_UnitHotWind_CurrWR;	//热风频率
	uint16_t	wHz_UnitHotWind2_CurrWR;	//热风2频率
	uint16_t	wPV_UnitTemCtl;	//实时温度
	uint16_t	wSts_UnitTemCtl;	//加热状态

	//通讯误码率@103--106
	uint16_t uiSendDataCnt;//发送的计数
	uint16_t uiRecvDataCnt;//接收的计数
	uint16_t uiRecvErrDataCnt;//接收出错的计数
	uint16_t uiTimeOutDataCnt;//超时计数
	//2025.6.25.135957+
	uint16_t uiRSampleCounter;//粗采样计数
	uint16_t uiFSampleCounter;//精采样计数
	//2025.7.30.093142+精彩样峰值显示
	uint16_t uiPeakValue_t1;
	uint16_t uiPeakValue_t2;
	//2025.8.12.085828+2WORDS@升降速会变化
	uint16_t uiSource_Light_T1_Cur; 	//T1路光纤电眼亮度@当前值/1000
	uint16_t uiSource_Light_T2_Cur; 	//T2路光纤电眼亮度@当前值/1000

	//2025.09.05.163815//xi.hy
	int16_t iPos_HorzManuPreReg;	//横向快速对版运行剩余值
	//2025.12.23.140915//Hou.N//增加柔印压力相关内容
	int16_t iPos_PrnRoller_Pressure_M;	//版辊操作侧实时位置*100
	int16_t iPos_PrnRoller_Pressure_G; //版辊传动侧实时位置*100
	int16_t iPos_NetRoller_Pressure_M; //网辊操作侧实时位置*100
	int16_t iPos_NetRoller_Pressure_G; //网辊传动侧实时位置*100
	int16_t iPos_StrRoller_Pressure_M; //张带辊操作侧实时位置*100
	int16_t iPos_StrRoller_Pressure_G; //张带辊传动侧实时位置*100
	uint16_t uiPeakCur_AutoFocus;

	//uint16_t 	aRsv_HignComm[1];//预留
	//2026.1.27.222202+uiPeakCur_AutoFocus正好用完了！
	//2025.12.26.133010||iPos_PrnRoller_Pressure_M->iPos_StrRoller_Pressure_G|7->1
	//2025.09.05.163911//xi.hy iPos_HorzManuPreReg|8->7
	//2025.8.12.170429 uiSource_Light_T1_Cur->uiSource_Light_T2_Cur|10->8
	//2025.6.21.105321 uiPeakValue_t1->uiPeakValue_t2|12->10
	//2025.6.21.105321 uiRSampleCounter->uiFSampleCounter|14->12
	//2025.6.21.105321 uiSendDataCnt->uiTimeOutDataCnt|18->14
}DynaData_WO_485,*LP_DynaData_WO_485;

//2026.1.27.161604+再扩展一个快速变化只写区
//@只写-单个包最大120word
//寄存器120--239(120WORD)@人机地址从1开始
//只写动态变化数据,不稳定的数据
typedef struct tagDynaData_WO_485_Ex
{
	uint16_t 	wSa;//预留
	uint16_t 	aRsv_HignComm[119];//预留

}DynaData_WO_485_Ex,*LP_DynaData_WO_485_Ex;

//@只写-单个包最大120word
//寄存器360--479(120WORD)@人机起始地址361
//相对比较稳定的只写数据
typedef struct tagStdData_WO_485
{
	uint16_t	wGirth;	//版周长*10（保留1位小数）
	int16_t		iCompanyId;	//用户编号
	int16_t		iPromptMsgId;	//当前报警/提示信息
	uint16_t	wAxisId_GrpId;	//高8位轴号，低8位系号
	uint16_t	wLedtime_Language;	//高8位屏保延时，低8位语言设置
	uint32_t	dwVersion;	//ARM程序版本号
	uint16_t 	uiGateWhy;//波门宽度|人机显示@点数
	
	//2026.1.27.165259 数据整合处理
	//2025.8.04.161610|wei.n+
	uint16_t    wSts_Print;
	uint16_t    wFlag_Estop;
	uint16_t    wLinkage_Print;
	uint16_t    wHotWind_Print;
	//(*2025.9.26.110946 按照byte使用*)
	uint8_t 	byDriverType_Hmi485;			//					: BYTE;(*从站人机485递墨辊和刮刀等驱动器类型|
												//					默认:吉泰科;
												//					= 1: 汇川;
												//					.....*)
	uint8_t 	resved0;

	uint16_t 	aReserved[107];
	//2026.1.27.165327 数据整合|[111]-->[107]
	//2025.9.26.124801+ byDriverType_Hmi485-resved |[112]-->[111]


}StdData_WO_485,*LP_StdData_WO_485;

//@只写
//(每个通道是800个数据点byte)|需要400个word
//寄存器600--3039(2440word)@人机地址从601开始
//寄存器600--3039(2440word)-多出来的40个word是单纯为了对齐
//这部分优先使用11个包发送@当前T1 显示内容(400WORD)+T2 显示内容(400WORD)+对齐(40word)--共7个包按照120word封装,
//+其他路显示内容(400WORD)--共4个包按照100word封装@这部分轮询发送
//最终会将2440个word发送一遍
//光纤电眼
//采样数据是动态变化的@双眼：其中_1&_2当前使用运算的值|其他是辅助显示的eg rgb 中g作为主显示|其他就按照rb顺序|通道按照T1\T2
//					单眼：其中_1&为当前使用运算的值|其他_2&_3是辅助显示的eg rgb 中g作为主显示|其他就按照rb顺序|456不用
//光电眼
//采样数据是动态变化的|其中_1&_2当前使用运算的值|通道按照T1\T2|3456不用
typedef struct tagSampleData_WO_485
{
	uint16_t 	awSampleData_1[400];	//第一路 采样数据@根据配置动态变化@400WORD
	uint16_t 	awSampleData_2[400];	//第二路 采样数据@根据配置动态变化@400WORD
	uint16_t 	awReserved[40];			//为了地址对齐，也可以作为其他通讯使用400+400+40=840能被120整除
	//下面每400个word轮询发送
	uint16_t 	awSampleData_3[400];	//第三路 采样数据@根据配置动态变化@400WORD
	uint16_t 	awSampleData_4[400];	//第四路 采样数据@根据配置动态变化@400WORD
	uint16_t 	awSampleData_5[400];	//第四路 采样数据@根据配置动态变化@400WORD
	uint16_t 	awSampleData_6[400];	//第四路 采样数据@根据配置动态变化@400WORD


	//一些状态标志@由外部输入
	uint8_t byEyeType;//电眼类型@=0 光纤双眼|=1 光纤单眼|=2 普通光电眼
}SampleData_WO_485,*LP_SampleData_WO_485;



//双向读写区域
//寄存器3120--3239(120WORD)@人机起始地址3121
typedef struct tagData_RW
{
	uint8_t		byHMI_Cnt;	//人机的状态读取，计划开始初始化为1，如果人机出现异常重启读回的值为0
	uint8_t     byReserved_1;//word对齐
	uint8_t		byAxisId;	//轴号放这里主要是为了人机通讯放错判断
	uint8_t     byReserved_2;//word对齐
	int16_t		iAdjust_V;	//纵向修正量*100（单位：丝）
	int16_t		iAdjust_H;	//横向修正量*100（单位：丝）
	int16_t		iGateSa;	//波门地址
	int16_t		iGateSaEx;	//第二波门地址
	uint16_t	wStatus;	/*界面上套色相关状态
							bit0./纵向自动
							bit1./横向自动
							bit2./横向开始运行
							bit3./横向开关
							bit4./横向运行中
							bit5./
							bit6./误差确认
							bit7./快速对版中
							bit8./允许快速对版标志
							bit9./T1反极性
							bit10./T2反极性
							bit11./
							bit12./
							bit13./
							bit14./纵向跟任意色
							bit15./横向跟任意色
							*/
	uint16_t	wButtonFun;	//界面按钮及指示灯
							/*
							 * bit0.单运行
							 * bit15.单运行指示
							 * */
	uint16_t	wSwitchFun;	//界面开关
							/*
							 * bit0.单联动开关
							 * bit1.压辊手自动
							 * */
	uint16_t	wUnit_output_I;	//IO输出测试
	uint16_t	wUnit_output_II;	//IO输出测试
	int16_t		iPlateAdjustmentProf;	//纵向快速对版量
	int16_t		iJourney_HorzRapidAdjust;	//横向向快速对版量
	uint16_t	wHz_UnitInkRoller_ManuallySet;	//递墨辊手动频率*100
	uint16_t	wCoeff_UnitInkRoller_Auto;	//递墨辊自动系数*100
	uint16_t	wHz_UnitScraper_ManuallySet;	//刮刀手动频率*100
	uint16_t	wCoeff_UnitScraper_Auto;	//刮刀自动系数*100
	uint16_t	wHz_UnitHotWind;	//热风频率
	uint16_t	wHz_UnitHotWind_2;	//热风2频率
	uint16_t	wSV_UnitTemCtl;	//加热设定温度
	uint32_t	dwCtlBits_UnitBaseCraft;	//工艺控制开关
	uint16_t	wAirInletWindDoorValue;	//进风风门
	uint16_t	wAirExhaustWindDoorValue;	//排风风门
	uint16_t	wAirReturnWindDoorValue;	//回风风门
	uint8_t		byRGBChosse_Cur;//当前波形通道选择
								//=1：主显 R 通道
								//=2：主显 G 通道
								//=3：主显 B 通道
								//先只占用低 8 位

	uint8_t		byReserved_3;//word对齐
	//光纤调试参数@8个word
	uint16_t	uiOffset_T1;			  	//T1路光纤偏移/1000
	uint16_t 	uiSource_Light_T1;        //T1路光纤光源/1000
	uint16_t	uiBias_T1;			  	//T1路光纤电眼偏置/1000
	uint16_t	uiBrightness_Light_T1; 	//T1路光纤电眼亮度/1000

	uint16_t	uiOffset_T2;			  	//T2路光纤偏移/1000
	uint16_t 	uiSource_Light_T2;        //T2路光纤光源/1000
	uint16_t	uiBias_T2;			  	//T2路光纤电眼偏置/1000
	uint16_t	uiBrightness_Light_T2; 	//T2路光纤电眼亮度/1000

	uint16_t 	uiSomeCtlBit;//通讯一些控制位	//.0 有效 屏蔽r通道
											//.1 有效 屏蔽g通道
											//.2 有效 屏蔽b通道
											//.3 有效 波形横向放大
											//.4 有效 演示波形处理
	uint16_t 	uiRemainNum_F;
	uint16_t	uiRemainNum_B;

	//2025.8.12.085705 同步@还未配置
	//2025.7.26.160424|wei.n|+
	// 单向往上发(15个 wAccButton_Count->rHz_UnitHotWind2_CurrRD)
	//2022.7.3.114828+
	uint16_t 	wAccButton_Count;//加速按钮计数
	uint16_t 	wDecButton_Count; //减速按钮计数
	uint16_t 	wUpAdjButton_Count ;//MCGS调整上按钮计数
	uint16_t 	wDnAdjButton_Count;//MCGS调整下按钮计数
	uint16_t 	wLeftAdjButton_Count;//MCGS调整左按钮计数
	uint16_t 	wRightAdjButton_Count;//MCGS调整右按钮计数
	uint16_t 	wAlarmButton_Count;//MCGS报警按钮计数
	uint16_t	wHz_UnitInkRoller_CurrRD;//递墨辊实际频率
	uint16_t	wSts_UnitInkRoller;//递墨辊变频状态
	uint16_t   	wHz_UnitScraper_CurrRD;//刮刀实际频率
	uint16_t  	wSts_UnitScraper;//刮刀状态
	uint16_t	wSts_UnitHotWind;//热风1状态
	uint16_t	wSts_UnitHotWind_2;//热风2状态
	uint16_t   	wHz_UnitHotWind_CurrRD;//热风频率
	uint16_t   	wHz_UnitHotWind2_CurrRD;//热风频率
	
	uint16_t	wSlaveBtn_HMI;//.0 版辊操作侧靠近
							   //.1 版辊操作侧远离
							   //.2 版辊平行靠近
							   //.3 版辊平行远离
							   //.4 版辊传动侧靠近
							   //.5 版辊传动侧远离
							   //.6 网辊操作侧靠近
							   //.7 网辊操作侧远离
							   //.8 网辊平行靠近
							   //.9 网辊平行远离
								//.10 网辊传动侧靠近
							   //.11 网辊传动侧远离
							   //.12 版辊标定
								//.13 网辊标定
								//.14 张带棍标定
								
	//2025.10.24.093526+
	uint16_t	wStsBit_RO;//只读的状态bit|/.0 横向编码器有效|/.1横向电机报警
	uint32_t 	dwEncValue_Hor;//横向编码器值@通讯获取|按照4字节获取@2025.10.17.092113


	uint16_t	awRsv_RdWr[64];	//先预留着-双向区域
	//2026.1.27.165628 数据整合|67->64
	//2025.12.26.132813||增加压力操作2个字节----68->67
	//2025.8.8.143722+ wAccButton_Count  wHz_UnitHotWind2_CurrRD|83->68
	//2025.07.04.161839+ uiRemainNum_F  uiRemainNum_B|85->83
	//2025.6.26.114444+ uiSomeCtlBit |86->85
	//uiBrightness_Light_T1 -> uiReserved_T2 |94->86
}Data_RW,*LP_Data_RW;




//通讯的数据结构体@单向-只写、只读。双向
//结构体中的首个变量不能被修改
typedef struct tagVisuCommData{
	Data_RW					data_RW;//读写的数据
	DynaData_WO_485 		dynaData_WO;//只写@变化比较频繁
	DynaData_WO_485_Ex 		dynaData_WO_Ex;//只写(再扩展一个区)@变化比较频繁|2026.1.27.162223+
	StdData_WO_485 			stdData_WO;//只写@变化比较缓慢
	SampleData_WO_485 		sampleData_WO;//只写的采样数据

	Data_RW					data_RW_Bak;//读写的数据备份值

	uint8_t axReSendAllData[4];//重新发送数据标志@前三个结构体的重发标志@2026.1.27.162542+只写
	//uint8_t axReSendAllData[3];//重新发送数据标志@前三个结构体的重发标志
} VisuCommData,*LP_VisuCommData;



extern uint16_t g_uiCycleCommTimer;
extern uint16_t g_uiTimeOutTimer;//循环通讯计时器、超时计时器@在时间中断中处理
extern uint16_t g_uiPollTimer;//轮询时间
extern VisuCommData g_stVisuCommData;//通讯的数据结构体

#pragma pack()


//函数声明

uint16_t KS_16CRC_OverWrite(
				uint32_t i_dwDataAdr,//(*数据起始地址*)
				int16_t i_iDataLen);//(*数据长度*)


//获取函数bit@最大字节长度为4字节
uint8_t KSGetDataBit(void*,uint8_t);
//设置函数位@最大字节长度4字节
void KSSetDataBit(void*,uint8_t,uint8_t);//写入的值、写入的bit

//(*将数据高低位按照byte颠倒,将颠倒后的值放置在原位置*)
//如果是奇数字节最后一个就不颠倒
//(*返回值-1 数据大小错误.-2 数据地址错误*)
int16_t KS_DataShift(uint32_t i_dwDataAdr,//(*数据的地址*)
					int16_t i_iDataSize);//(*数据长度*)

//(*将数据高低位按照byte颠倒,将颠倒后的值放置在原位置*)
//如果是奇数字节最后一个就不颠倒
//(*返回值-1 数据大小错误.-2 数据地址错误 -3参数非法*)
//增加输入参数控制控制颠倒的字节@支持双字节颠倒
int16_t KS_DataShift_V2(uint32_t i_dwDataAdr,//(*数据的地址*)
					int16_t i_iDataSize,//(*数据长度*)
					int8_t i_iShiftLenth);//颠倒的长度@=1 按照单字节|=2 按照双字节

//将2个byte拼成一个word@支持2个字节取反拼接
void KS_BYTE_TO_WORD(
		uint8_t i_xBigEndian,//(*高低字节取反标志|有效代表会先发高字节*)
		uint8_t i_abyData[],//2个元素
		uint16_t* i_pwData);

//(*word转换为2个字节*)
void KS_WORD_TO_BYTE(
		uint8_t i_xBigEndian,//(*高低字节取反标志|有效代表会先发高字节*)
		uint16_t i_wData,
		uint8_t abyData[]);//输出2个元素

void KS_InitQueue(uint32_t i_dwQueueAdrSa,//(*队列首地址*)
					int16_t i_iQueueLen,//(*队列长度@字节长度*)
					int16_t* i_piQueueSa,//(*队列开始*)
					int16_t* i_piQueueEd);//(*队列结束*)

//2025.8.7.144955+
//(*单个modbus设备*)
//增加初始化标志控制不变参数的单次更新|减少耗时
//周期更新使能标志@它是经常变化的值
//void KS_GetDataList_V2(uint8_t i_xInitData,//初始化标志|外部控制@控制固有参数只更新一次,使能参数周期更新
//				LP_StData_Comm i_pstStData_Comm)//(*通讯的数据初始化*)
//				StModbusDataAdrList i_pastStDataList[REGISTER_AREA_MAX]);//(*通讯的数据列表|为了方便循环处理|索引为寄存器区@多申请一个数组索引从1开始处理*)
//(*单个modbus设备*)
//(*函数里面直接处理了所有寄存器区的数据列表@2022.10.22.124027*)
//将通讯变量写入到地址列表中|方便循环操作
//void KS_GetDataList(LP_StData_Comm i_pstStData_Comm,//(*通讯的数据初始化*)
//				StModbusDataAdrList i_pastStDataList[REGISTER_AREA_MAX]);//(*通讯的数据列表|为了方便循环处理|索引为寄存器区@多申请一个数组索引从1开始处理*)

/*检查是否需要进行写入或者读取动作
0无动作
1 写入
2 读取*/
//uint8_t KS_CheckRWSts(
//		uint8_t* i_pxWrInit,//(*写入未初始化|用于开机写1次*)
//		LP_StModbusDataAdrList i_pStDataList);//(*通讯的数据列表|一个区域一个区域看*))

//2026.6.17.102400 + 检查读写状态
/*检查是否需要进行写入或者读取动作
0无动作
1 写入
2 读取*/
uint8_t KS_CheckRWSts_V2(LP_StRegisterAreaAttibute pstStRegisterArea);//(*下标代表索引*))

void KS_GetNextRegister(uint8_t i_xNextRegister,//(*切换下个寄存器标志|外部处理为沿*)
				StData_Comm i_pastStData_Comm[MODBUSNUM_MAX],//(*所有通讯的数据|*)
				//StModbusDataAdrList i_paStDataList[][REGISTER_AREA_MAX],//(*通讯的数据列表|[]=MODBUSNUM_MAX*)
				uint8_t* i_pbyCurModbusId,//(*当前modbusid|会被更新为下一个*)
				uint8_t* i_pbyCurRegisterIndex,//(*当前寄存器索引|会被更新为下一个*)
				uint8_t* i_pbyRWSts,//(*读写状态|0 不动作 1 写入 2 读取*)
				uint8_t i_byModbusNum_Max);//(*最大站数量*))


/*获取通讯数据|只处理的读写多个寄存器命令
	  1 写入的数据返回成功了！
	  2 读取的数据返回成功了!
	 -1 站号错误
	 -2 返回设备错误码
	 -3 功能吗错误
	 -4 读寄存器返回的字节个数错误
	 -5 写入多个寄存器 返回的地址不对
	 -6 CRC校验错误
	 -4 读多个线圈返回的字节个数错误
	 -15 写入多个线圈 返回的地址不对*/
//(*增加线圈获取处理@最小单位是一个寄存器即16个线圈@2023.4.6.141636*)
int16_t KS_GetRecvData_Comm(uint8_t i_pabyRecvData[RECEIVEBUFF_NUM],//(*收到的数据|根据通讯编码处理为正常顺序数据@0--254*)
						uint8_t i_byRecvDataNum,//(*需要接收的数据个数|用来判定是否接收完成*)
						int16_t* i_piQueueSa,//(*队列开始*)
						int16_t* i_piQueueEd,//(*队列结束*)
						uint8_t i_pabyCycleQueue[CYCLEQUEUE_NUM],//(*循环队列*)
						uint8_t* i_pbyErrCodeFrSlaver,//(*从站返回的错误码*)
						uint8_t* i_xRecvDataOk,//(*接收正确|用于反馈*)
						//(*通讯的信息*)
						uint8_t i_byModbusId,//(*id*)
						uint8_t i_byFunCode,//(*功能码*)
						uint16_t i_wAdrSa,//(*起始地址*)
						uint8_t i_byRegisterNum,//(*寄存器个数*)
						uint8_t i_xBigEndian,//(*编码顺序*)
						uint8_t i_pabyRecvDataAct[CYCLEQUEUE_NUM]);//(*实际接收到的数据不分对错*))


//(*打包数据用于通过485发送|modbus协议-带crc校验
//只处理了操作寄存器功能码
//-1 指针错误
//-2 站号非法
//-3 写入寄存器个数非法
//-4 读取寄存器个数非法
//-13 写入线圈个数非法
//-14 读取线圈个数非法*)
//(*增加线圈处理@最小单位是寄存器个数-历史原因最少16个线圈@2023.4.6.130536*)
int16_t KS_PackDataToSend(uint8_t i_xFlag_DataCmd,//(*TRUE 写入数据命令标志|false代表读取数据命令*)
					uint8_t i_byType_RegisterOrCoils,//(*操作对象选择|0为线圈-1为寄存器*)
					uint8_t i_xBigEndian,//(*高低字节取反标志|有效代表会先发高字节*)
					uint8_t i_byModbusId,//(*通讯站号*)
					uint16_t i_wAdr_Rd,//(*读取寄存器的起始地址*)
					uint8_t i_byRegisterNum_Rd,//(*读取的寄存器数量@线圈个数=i_byRegisterNum_Rd*8*)
					uint16_t i_wAdr_Wr,//(*写入寄存器的起始地址*)
					uint8_t i_byRegisterNum_Wr,//(*写入的寄存器数量@线圈个数=i_byRegisterNum_Rd*8*)
					uint8_t i_pabyData_Wr[SENDBUFF_NUM],//(*写入的数据|未高低取反@包含线圈和寄存器*)
					uint8_t i_pabySendData_Buff[SENDBUFF_NUM],//(*发送的数据buff|可能为写入命令也可能为读取命令*)
					uint8_t* i_pbySendDataNum,//(*发送的字节个数*)
					uint8_t* i_pbyRecvDataNum,//(*接收到的字节个数|用于判定接收是否完成*)
					uint8_t* i_pbyFunCode);//(*功能码*)

void KSModbus485_Master(
		uint8_t i_xEn,//通讯使能
		StData_Comm i_pastStData[MODBUSNUM_MAX],//(*下标代表索引*)
		//(*数据地址列表|一维索引代表站号-二维索引为区块分类*)
		//StModbusDataAdrList i_paStDataList[MODBUSNUM_MAX][REGISTER_AREA_MAX],//所有通讯数据列表
		uint8_t i_byModbusNum_Max,//(*最大的设备个数|*)
		uint8_t i_pabyModbusIdList[MODBUSNUM_MAX],//(*modbusid列表|下标代表索引*)
		uint8_t i_paxModbusCommEnList[MODBUSNUM_MAX],//(*modbus站通讯使能列表|下标代表索引*)
		uint8_t i_paxRegisterAreaCommEnList[MODBUSNUM_MAX][REGISTER_AREA_MAX],//(*站的 寄存器区使能标志|最大5个区*)
		LP_VisuCommData pstVisuCommData,//通讯的数据
		//输出的数据
		//(*修改为数组变量-2021.7.16.170008*)
		uint16_t o_auiSendDataCnt[MODBUSNUM_MAX],//发送的计数
		uint16_t o_auiRecvDataCnt[MODBUSNUM_MAX],//接收的计数
		uint16_t o_auiRecvErrDataCnt[MODBUSNUM_MAX],//接收出错的计数
		uint16_t o_auiTimeOutDataCnt[MODBUSNUM_MAX],//超时计数
		uint8_t o_axConnectOk[MODBUSNUM_MAX],//通讯正常标志
		uint8_t o_abyErrCodeFrSlav[MODBUSNUM_MAX],/*(*设备返回错误码|响应功能码 = 请求功能码+0x80
																				01 非法功能码
																				02 非法地址
																				03 非法数据
																				04 服务器故障
																				05 确认
																				06 服务器繁忙
																				0A 0B 网关故障-具体信息详见Modbus协议中文版.pdf中113页*)
																				*/

		int16_t o_aiErrCode[10],//(*返回的错误码*)
		uint8_t* pbyCurModbusIdIndex,//当前的站id索引从0开始
		uint8_t* pbyCurRegisterIndex);//当前的寄存器索引从0开始
/*
//485通讯数据的初始化@单个站
extern void KS_DataInit_Comm_485(
					uint8_t i_xCommEn,//通讯使能标志@写入到StData_Comm中
					uint8_t i_byModbusId,//通讯的站号@写入到StData_Comm中
					uint8_t i_paxRegisterAreaCommEn[REGISTER_AREA_MAX],//(**)
					StData_Comm* i_pstStData_Comm,//通讯的数据初始化|
					LP_VisuCommData);//这里只声明@实现还没做
*/

void KSModbusHmiComm();

//2025.8.7.142316 通讯初始化-周期执行初始化使能标志@其他不变参数只执行一次
//所有内容周期执行耗时比较久
void KS_DataInit_Comm_485_V2(
					uint8_t i_xInitData,//初始化标志|外部控制@控制固有参数只更新一次,使能参数周期更新
					uint8_t i_xCommEn,//通讯使能标志@写入到StData_Comm中
					uint8_t i_byModbusId,//通讯的站号@写入到StData_Comm中
					uint8_t i_paxRegisterAreaCommEn[REGISTER_AREA_MAX],//@写入到StData_Comm中
					StData_Comm* i_pstStData_Comm,//通讯的数据初始化|
					LP_VisuCommData pstVisuCommData);//这里只声明@实现还没做
//
////485通讯数据的初始化@单个站
//void KS_DataInit_Comm_485(
//					uint8_t i_xCommEn,//通讯使能标志@写入到StData_Comm中
//					uint8_t i_byModbusId,//通讯的站号@写入到StData_Comm中
//					uint8_t i_paxRegisterAreaCommEn[REGISTER_AREA_MAX],//(**)
//					StData_Comm* i_pstStData_Comm,//通讯的数据初始化|
//					LP_VisuCommData);//这里只声明@实现还没做

uint8_t KsGetRegisterNum(uint16_t);//获取结构体的支持的寄存器个数最大120个|结构体超过了，建议重新封装

//使能中断发送函数
void KSStartSendBuffByIRQ();

//485通讯数据的赋值
//更新读写数据
void KsUpdateDataRw(uint8_t xHmiToLocal,
					StGlobalParam* i_pstStGlobalParam,
					StAxisParam* i_pstStAxisParam,
					StGrpParam* i_pstStGrpParam,
					LP_VisuCommData i_pstVisuCommData);

void KS_SetData_485(
		uint8_t xRoundSampleFlag,//粗采样标志@有效才刷新粗采样通讯数据
		uint8_t bySignalSelect_Cur,//当前轮询RGB通道
		uint8_t byChannel_T1T2_Cur,//当前轮询T1 T2通道
		StGlobalParam* i_pstStGlobalParam,
		StAxisParam* i_pstStAxisParam,
		StGrpParam* i_pstStGrpParam,
		VisuCommData* i_pstVisuCommData,
		int16_t i_aiError_V[40],
		int16_t i_aiError_H[40]);

//获取屏保id
void KSGetScreenSaverId(StAxisParam* i_pstStAxisParam,StGrpParam* i_pstStGrpParam,uint8_t byStsV);


//检查数据,和备份数据对比
//返回1 有变化
//返回0 未变化
uint8_t KS_DataCmp(LP_StRegisterAreaAttibute pstStRegisterArea);
//寄存器备份数据拷贝
void KS_UpdateBackData(LP_StRegisterAreaAttibute pstStRegisterArea);

//获取寄存器区结构体地址
LP_StRegisterAreaAttibute KS_GetRegAreaPointer(StData_Comm i_pastStData[MODBUSNUM_MAX] ,uint8_t byModbusId,uint8_t byAreaId);


#ifdef __cplusplus
}
#endif

#endif /* MODBUS485_H_ */
