/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"
#include "fsmc.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "sys.h"
#include "led.h"
#include "KesaiAPI.h"
#include "comm.h"
#include "base.h" /* 基本结构 */
#include "stdio.h"
#include "stdafx.h"
#include "KS_FB_VISU.h"/* VISU相关 */
#include "KS_FB_ProSample.h"/* 采样处理及计算误�??? */
//#include "AutoFindTaps.h"
#include "calcerr.h"
#include "calcbase.h"
/* 2024.02.01.110058 同步 liu.yt */
#include "StRingNet.h"  /* 2024.1.18.153154/han.dp/+ */
#include "StFileOp.h"
#include "bin_upgrade.h"
#include "ks_somefunc.h"
#include "string.h"
#include "KS_RsMorphFilter.h"//2026.4.21.172138+

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

EXCEPTION_OF_CRASH exception_crash;/* 主机死机信息/2024.1.20.142743/han.dp/+ */
uint8_t byReqRdExceptionOfProgCrash = 0;/* =1.send Mailbox cmd to master-station. and echo ack message./2024.1.18.105623/han.dp */
unsigned char g_bygetsts = 0;/* =0 idle =1 给上位机信号 抓取死机信息 */
							 /* =2 获取抓取到信�??? =3 获取成功 =4 获取超时@10�??? */
unsigned short g_getcrash_inf_timecnt_10ms = 0;/* 10ms计时计数值@用于获取死机信息计时 */
char g_send_crashinf_hmi = 0;

static WORD g_wCnt_Rs = 0;
static INT g_iRtn_Calc2022 = 0;
static INT g_aiVResult[2] = {0};
static INT g_aiHResult[2] = {0};

INT Perimeter = 500;
INT Coordinate = 4000;
//static BYTE iStationId=240;                                         /* 站号获取 */
//2025.10.28.134048  修改非法值为255@最大站号可以到255
static BYTE iStationId=255;                                         /* 站号获取 */
/* 2021.8.14.152254=-------------------------------------------------2021.8.14.152306判断定时器无标志，只做计数增�??? */
static WORD g_wCount_Comm;											/* 主从通讯 */
//static WORD g_wCount_Visu;											/* 485通讯 */
static WORD g_wCount_CaseBase;										/* 计算基线 */
static WORD g_wCount_TimeOut;										/* 485超时计数 */
static WORD g_wCount_FeedDog;										/* 喂狗计数 */
static WORD g_iCount_TimeOutNum;									/* 超时计次 */
static WORD g_uiTime_DigitalTubes;									//数码管处理需要的时间计数@2025.10.29.115018+
static WORD g_uiTime_LED1_Flick;									//LED1闪烁计时@2025.10.29.115018+
static WORD g_uiDelayTime_Init;										//2025.10.29.184309+
INT aiFineData1[4000];												/* 精采样�?? */
INT aiFineData2[4000];												/* 精采样�?? */
unsigned short tmp;
extern unsigned char byReceiveEnd;									/* 接收完成标志，根据接收数据量与CRC校验判断 */
extern DWORD dwRoundSampleThreshold;								/* 主站接收到的粗采样阀�???*/
char* pbyRoundData2;												/* 粗采样第二路信号地址**便于保存文件 */
char* pbyRoundData1;												/* 粗采样第�???路信号地�???**便于保存文件 */
static BYTE byFineSampleSaveFlag;									/* 主站下发的保存采样按�???*/
static INT aiError_V[40];											/* 2020.05.04.171022|niu.j|误差存入循环队列，等待发送时读取索引，判断误差刷新幅数，根据幅数发�?�误差个�???*/
static INT aiError_H[40];
static BYTE byScanCount=0;
static BYTE byScanCountPre=0;
static unsigned short FeedDogAdr=0x054;								/* 喂狗地址*/
static unsigned short FeedDog=0x5555;								/* 喂狗�???*/
static unsigned short wArmResetCountAdr=0x500;						/* 看门狗复位计数地�??? */
static unsigned short wArmResetCount;								/* 看门狗复位计�??? */
static REAL alrThreshold[2];										/* 采样显示�???�??? */
static REAL alrBase_Fs[2];											/* 精采样计算基�??? */
INT iRtnRdID;
extern BYTE RS485_RX_BUFF[150];										/* 读取到的485数据 */
WORD ErrNum;														/* 错误计次 */
BYTE abyRoundSampleData_485[1600];									/* 发�?�波形使用缓冲区 */
static BYTE abyMinData_Sample[2] ;									/* 两路信号�???小�??-2021.9.16.105149通讯到人机处理波形显�??? */

extern WORD wSendNum_Test;											/* 485发�?�计�???2021.8.20.103739 */
extern WORD wReadNum_Test;											/* 485接收计次2021.8.20.103749 */

/* 2023.09.18.113506 定义 */
unsigned int dwAdrStAutoFind_wwz_IN,dwAdrStAutoFind_wwz_OUT;

//2026.4.22.162622+
uint8_t xCanRsMorphFilter = 0;
uint8_t byRsMorphFilter_T1T2 = 1;//T1 T2轮询@ =1 T1 |=2 T2

//2025.9.24.214713 从while(1)中结构体移动到全局
/* 部变量定�??? */
StAxisParam stStAxisParam;													/* 轴参�??? */
StGrpParam stStGrpParam;														/* 系参�??? */
StGlobalParam stStGlobalParam;												/* 整机参数 */
StSyncWithServerOut stStSyncWithServerOut;									/* 通讯相关变量 */
StPara_PduBroadcastUp stStPara_PduBroadcastUp;								/* 通讯数据|UP */
StPara_PduBroadcastDn stStPara_PduBroadcastDn;								/* 通讯数据|Dn */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */
/* 2024.02.01.155049 死机时获取信息函�??? */
/* pxgeten 使用的轴参数中的i_pstStAxisParam->wButtonFun.15| */
void ks_get_prgcrash_inf(short iStationId,/* 本地站号的接口好像没用，先留�???�??? */
						char* pxgeten,
						unsigned char* pbygetsts,
						unsigned short* pgetcrash_inf_timecnt_10ms,
						LP_EXCEPTION_OF_CRASH pcrash_inf)
{
	unsigned char bygetsts,xgeten;
	unsigned short crash_inf_adrsa = 0x3e00;/* 死机信息的起始地�??? */
	unsigned short getcrash_inf_timecnt_10ms;
	static unsigned char timeout_cnt;/* 超时计数 */
	StFunction get_inf;/* 获取死机信息时需要发送的内容结构体@主要是m_id=0x400; */
	get_inf.m_id = 0x400;
	/* 计算dword的个�??? */
	signed int inf_lenth=sizeof(EXCEPTION_OF_CRASH);
	if(inf_lenth % 4 ==0 ) inf_lenth = inf_lenth/4;
	else inf_lenth = inf_lenth/4+1;

	if(pbygetsts!=0 && pcrash_inf!=0 && pxgeten!=0 &&  pgetcrash_inf_timecnt_10ms!=0)
	{
		bygetsts = *pbygetsts;/* 拿到当前状�?�|=1 向主站写入获取命令�?��?? */
		xgeten = *pxgeten;
		getcrash_inf_timecnt_10ms = *pgetcrash_inf_timecnt_10ms;
		if(xgeten)
		{/* 获取标志有效�??? */
			xgeten = 0;
			if(bygetsts==3 || bygetsts==4 || bygetsts==0)/* 在初始状�???,或着完成状�?�|超时状�?�可以重新开�??? */
				bygetsts = 1;
		}
		else
		{/* 未使�??? */
			;
		}
		switch (bygetsts)
		{
			case 0:/* 初始状�?? */
				break;
			case 1:/* 向主站写入获取命�??? */
				/* 给主站触发请�???,通过mailbox通讯 */
				GT_RN_DevicePcMailComWr((unsigned long *) & (get_inf), 0, 0, 2, RN_LMWR, 1);/* RN_LMWR 起始地址无意�??? */
				/* inf_lenth 这个变量是dword的个�???,使用sizeof获取@2024.06.07.090154 */
				memset((void*)pcrash_inf,0,(int32)(sizeof(EXCEPTION_OF_CRASH))/*inf_lenth*/);/* 初始化信�??? */
				bygetsts = 2;
				getcrash_inf_timecnt_10ms =0 ;/* 清零计时�??? */
				timeout_cnt = 0;
				break;
			case 2:/* 定时�???�??? 获取的信息写入区域@起始地址0x3E00 */
				if(getcrash_inf_timecnt_10ms>=100)/* 100*10ms */
				{
					getcrash_inf_timecnt_10ms = 0;
					GT_RN_DevicePcMailComRd((unsigned long *) pcrash_inf, 0, crash_inf_adrsa, inf_lenth, RN_ARD);/* RN_ARD |绝对寻址 */
					if(pcrash_inf->wYear!=0)/* 获取到了信息*/
					{
						bygetsts = 3;
					}
					else
					{
						timeout_cnt = timeout_cnt+1;/* 超时+1*/
					}

					if (timeout_cnt>=10)/* 10次超�???*/
					{
						bygetsts = 4;
					}
				}
				break;
			case 3:/* 获取完成�??? */
				break;
			case 4:/* 获取超时�???*/
				break;
			default:
				break;
		}
		*pbygetsts = bygetsts;
		*pxgeten = xgeten;
		*pgetcrash_inf_timecnt_10ms = getcrash_inf_timecnt_10ms;
	}
}
/* ********************************************************获取死机信息@2024.02.01.224710-end */

/* 2024.9.28.141504/wei.n/外部中断的回调函�??? */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
	if(GPIO_Pin == GPIO_PIN_9)
	{
		__HAL_GPIO_EXTI_CLEAR_IT(EXTI_LINE_9); /* 清除LINE9上的中断标志�??? */
	}
	else
	{
		__HAL_GPIO_EXTI_CLEAR_IT(EXTI_LINE_10); /* 清除LINE10上的中断标志�??? */
		RingNetRxPacketThread(0);
	}
}

/* +注释 10ms计时器@2024.02.01.221826 */
/* 2024.7.31.115331/wei.n/TIM3的中断函�??? */
//已经验证过了,time3的计时周期为10ms@2025.11.5.125252确认
//调整一些计时的宏
void TIM3_IRQHandler(void)
{
	//2025.11.5.125159+
	//获取更新中断宏使用错误@用成了更新中断使能标志获取宏
	//if(__HAL_TIM_GET_IT_SOURCE(&htim3, TIM_IT_UPDATE) == SET)  /* 溢出中断 */
	if(__HAL_TIM_GET_FLAG(&htim3, TIM_FLAG_UPDATE))//更新中断有效
	{
		//2025.11.5.184802+
		__HAL_TIM_CLEAR_FLAG(&htim3, TIM_FLAG_UPDATE);//清除更新中断标志
		HAL_TIM_IRQHandler(&htim3);

		g_wCount_Comm= g_wCount_Comm+1;
		//g_wCount_Visu= g_wCount_Visu+1;
		g_wCount_CaseBase= g_wCount_CaseBase+1;
		g_wCount_TimeOut= g_wCount_TimeOut+1;
		g_wCount_FeedDog= g_wCount_FeedDog+1;
		/* 2024.02.01.221659 增加获取死机信息计时�??? */
		g_getcrash_inf_timecnt_10ms = g_getcrash_inf_timecnt_10ms+1;
		//2025.10.29.114811+ 一个中断5ms
		//2025.11.5.125716  已经验证了周期为10ms
		g_uiTime_DigitalTubes += 10;
		g_uiTime_LED1_Flick += 10;
		g_uiDelayTime_Init += 10;

		//LED0 = !LED0;
	}

	//2025.11.5.124942 清除的宏定义使用错误
	//__HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);  /* 清除中断标志�??? */
}

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  /* USER CODE BEGIN 2 */
  HAL_NVIC_SetPriorityGrouping(NVIC_PRIORITYGROUP_2);/* 设置系统中断优先级分�???2 */
  MX_LED_Init();									 /* LED初始�??? */
  MX_FSMC_Init();
  GTD_Open(Bank1_SRAM3_ADDR);
  tmp = 0;
//2025.10.29.185529 调整位置 先设置中断
 MX_USART2_UART_Init(); 	/* 485初始化，APB1时钟1/4系统时钟频率,25HZ */
 MX_TIM3_Init();   		/* 10ms */
 MX_TIM2_Init();			/* 该定时器用于增加接收与发送数据包之间的间�???-100us-1000us,根据设定值不�??? */
  /********************************************************/

  while(iStationId<1 || iStationId>=MAX_STATION_NUM)				/* 站号读取成功 */
  {
	  //iRtnRdID= GT_RN_GetLocalID(&iStationId);

	  if(g_uiDelayTime_Init >= 1000)//超过1s后执行 获取站号
	  {
		  //g_uiDelayTime_Init = 1000;//防止溢出
		  iRtnRdID= GT_RN_GetLocalID(&iStationId);
	  }
	}

	while( (tmp & 0x4000) == 0x0000)					/* 读取主站DSP启动标志 */
	{
		if(g_uiDelayTime_Init>1000)//2025.11.29.155702+增加1s sleep|没开主站的时候有可能在线升级不成功
		{
			g_uiDelayTime_Init = 0;//2025.11.29.155802+ 重新计时
			iRtnRdID = GT_RN_MailRdMultReg(2, &tmp, 1, 1, 0);
			if(iRtnRdID)
			{
				tmp = 0;
			}
			/* 从站等待主站响应过程中，�???直喂�??? */
			GT_RN_WriteFPGA(FeedDogAdr, &FeedDog);
		}
	}

//  MX_USART2_UART_Init(); 	/* 485初始化，APB1时钟1/4系统时钟频率,25HZ */
//  MX_TIM3_Init();   		/* 10ms */
//  MX_TIM2_Init();			/* 该定时器用于增加接收与发送数据包之间的间�???-100us-1000us,根据设定值不�??? */

  /* 用于看门狗计�??? */
  GT_RN_ReadFPGA(wArmResetCountAdr,&wArmResetCount);							/* 从FPGA中先读出计数�??? */
  wArmResetCount=wArmResetCount+1;
  GT_RN_WriteFPGA(wArmResetCountAdr,&wArmResetCount);							/* +1后再写入进去 */
  /* �???活本地采�??? 2021.9.7.132553 */
  KS_InitSample(iStationId);
  /* 2021.9.7.132556 */
  /* LED用于时间监控-GPIO示波器测�??? */
  /* 2020.03.06.142857|niu.j|以上为黄工程序，Tim3_Init为留用的定时器，定时10ms */
  /* 以下增加自己程序，main函数主要处理内容| */
  /* 1.读取采样信息，判断是否需要进行误差计�??? */
  /* 2.判断485数据包的完整性，如若完整，更新到系统参数�??? */
  /* 3.100ms任务-处理485通讯，完成本地人机交�??? */
  /* 4.20ms任务-处理PC-PC通讯，PDU通讯和Mailbox通讯 */
  /* ResetNum=0xaa; */

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
	  //2025.9.24.214621 结构体移动到全局！
//
//	  /* 部变量定�??? */
//	  StAxisParam stStAxisParam;													/* 轴参�??? */
//	  StGrpParam stStGrpParam;														/* 系参�??? */
//	  StGlobalParam stStGlobalParam;												/* 整机参数 */
//	  StSyncWithServerOut stStSyncWithServerOut;									/* 通讯相关变量 */
//	  StPara_PduBroadcastUp stStPara_PduBroadcastUp;								/* 通讯数据|UP */
//	  StPara_PduBroadcastDn stStPara_PduBroadcastDn;								/* 通讯数据|Dn */
	  static BYTE xGetAxisId;														/* 获取站号 */
	  BYTE byLedSwitchTimeouts;														/* 屏保延时 */
	  static INT iJourney_HorzRapidAdjust;											/* 横向快�?�丢�??? */
	  static DWORD  dwPlateAdjustmentProf;											/* 快�?�对版�?? */
	  INT iRoundSampleFlag;															/* 实际粗采样数据采集到�??? */
	  INT iFineSampleFlag;															/* 实际精采样数据采集到�??? */
	  static BYTE xStart;															/* 程序首次运行标志 */
	  char* pbyFineData2;															/* 粗采样第二路信号地址 */
	  char* pbyFineData1;															/* 粗采样第�???路信号地�??? */
	  static REAL alrBase[2];														/* 两路波形的基�??? */
	  static REAL alrBase_HMI[2];													/* 两路波形的基�??? */
	  static BYTE xFlag_1_s_Calcbase;												/* 2024.1.30.145736--1s计算�???次基�??? */
	  /* 2024.1.30.145556增加界面使用的基线�?�，之前时计算的基线，如果是精采样基线，容易造成无波形问题； */
	  static REAL alrBase_RS[2];													/* 两路波形的基�??? */
	  BYTE* pbyItem1;																/* T1信号起始地址 */
	  BYTE* pbyItem2;																/* T2信号起始地址 */
	  BYTE* pbyItem1_Temp;															/* T1信号起始地址 */
	  BYTE* pbyItem2_Temp;															/* T2信号起始地址 */
	  SINT* psiItem1;																/* T1信号起始地址 */
	  SINT* psiItem2;																/* T2信号起始地址 */
	  static BYTE xInclNegative10vSignal;											/* 处理±10V电眼 */
	  INT iN,iSig;																	/* 循环变量 */
	  INT* piItem1;
	  INT* piItem2;
	  BYTE abyBase[2];																/* 使用的基�??? */
	  static INT aiFineSample_Data[9];												/* 通讯给主站的波形细节 */
	  static BYTE bySignal10VCoef;													/* ±10V光电眼IO控制 */
	  static BYTE xOK_PosConfirmed;													/* 单标记位置确�??? */
	  BYTE xFlag_CopyFromMaster;													/* 主站参数更新完成标志，用�???485通讯使能 */

	  BYTE xOK_FromMaster;
	  static BYTE test;
	  static INT iWave_offset_Temp;													/* 偏移�??? */
	  static INT iWave_offset;														/* 偏移�??? */
	  static BYTE xFlag_Mag;														/* 横向放大标志 */
	  BYTE bySample_Interval;														/* 采样间隔-放大�???2，不放大5 */
	  static BYTE xRefresh_Flag;
	  static BYTE xFlag_SingleMode;
	  BYTE xMarkHor;																/* 门内基线标志 */
	  DINT diFineSampleStart;
	  INT iGateWidthFinePt = 1000;//精彩样点数值@2025.7.15.183713+

	//在20ms周期任务中执行@2025.6.11.124050+
	//油墨槽脉冲输出控制变量定义
	BYTE xPulseCtlEn = FALSE;//脉冲控制使能
	BYTE xPulseOutEn_Act = FALSE;//脉冲输出使能了
	BYTE xMoveDir_Act = FALSE;//运动方向
	BYTE xPulseCtlMode_Act = FALSE;//脉冲控制模式
	BYTE xVelMod_Run_Act = FALSE;//速度模式,速度使能标志
	REAL rVelMod_Vel_Act = 0;//速度模式下的速度
	WORD wPosMod_Pulse_Act = 0;//位置模式下实际的脉冲数
	WORD wPulse_1r = 0;//1圈的脉冲数
	WORD wTmp = 0;
	//DINT diThisMovePluse = 0;//2025.6.11.232404 本次运动的距离
	Lp_StInkGrooveCtl pstStInkGrooveCtl = 0;

		//2025.10.29.114729 同步数码管显示处理
		//2025.09.06.151737//xi.hy//数码管显示站号处理
		KS_ShowId_DigitalTubes(iStationId,
					  &g_uiTime_DigitalTubes,
					  xFlag_CopyFromMaster);

		//运行指示(LED1)@2025.10.29.164927+
		if(xFlag_CopyFromMaster)//主站通讯成功按照500ms闪烁
			KS_Led1Flick(500,&g_uiTime_LED1_Flick);
		else//运行了就按照2s闪烁
			KS_Led1Flick(2000,&g_uiTime_LED1_Flick);

	  /* ----------------------------------------------------sj 2021.8.20.105400--------------�???部变量定义完�???--------------------------- */
	  /* 2022.6.21.090345 -判断站号31�???-不进入以下�?�辑-进入到副主站485通讯 */
	  if(iStationId!=31)
	  {
		  //2025.11.4.092644 屏蔽该值的设置
		  //GT_RN_SetSenceDO((WORD)bySignal10VCoef);								/* ±10V光电眼两路IO控制 */
		  bySample_Interval=5;
		  /* 主�?�辑里面500ms喂一次狗 */
		  if(g_wCount_FeedDog>=50&&test==0)
		  {
			  GT_RN_WriteFPGA(FeedDogAdr, &FeedDog);
			  g_wCount_FeedDog=0;
		  }

		/* 看门�???-喂狗结束2021.8.20.105514 */

		/* -----------------------------2021.1.5.153657---------横排打开后，基线�???要用精采样基线，获取门内基线�???�??? */
		xMarkHor = GetBit(stStAxisParam.wSwitchRef,1);
		/* -----------------------------------------------------计算偏移�??? */ 
		stStAxisParam.iARMRunNum=0;		/* 2022.5.21.084425 */
		/* 2021.8.20.112017-------------------------------------粗采样处�???--------------------------------------- */
		/* 读取粗采样数据有效标�??? */ 
		GT_RN_SampleGetRoundData((void**)&pbyRoundData2, (void**)&pbyRoundData1, &iRoundSampleFlag);
		/* 粗采样数据到位后，每500ms处理�???次数�??? */
		/* 1.计算粗采样基�??? */
		/* 2.将两路信号处理为HMI显示�???用数�??? */
		if ( iRoundSampleFlag == 1 )												/* 实际粗采样数据采集到�??? */
		{
			stStAxisParam.iARMRunNum=1;		/* 2022.5.21.084425 */
			if( pbyRoundData2 != 0 && pbyRoundData1 != 0 )							/* 指针合法 */
			{
				if(byScanCountPre!=byScanCount)										/* 自动寻址 */
				{
					stStAxisParam.iGateSa=KS_AutoFindGate(  (BYTE*)pbyRoundData1,	/* 用T1 粗采样完成自动寻�??? */
															(INT)(alrBase[0]-dwRoundSampleThreshold),
															&stStAxisParam,
															4000);
					byScanCountPre = byScanCount;
				}
				if( g_wCount_CaseBase>=gc_Count_CalcBaseNum)						/* 500ms计时到位标志�???始计算基�??? */
				{																	/* 计算基线 */
					xRefresh_Flag = 0;
					/* 使用±10V电眼�???要的处理 */
					if( xInclNegative10vSignal )									/* ±10V电眼处理--原始数据+128 */
					{
						/* 两路波形数据的地�??? */
						psiItem1 = (SINT*)pbyRoundData1;
						psiItem2 = (SINT*)pbyRoundData2;
						for( iN=0; iN<4000; iN++ )
						{
							*psiItem1 = *psiItem1 + 128;							/* 原始值基�???�???+128转换�???0-255的�?? */
							psiItem1 = psiItem1 + 1;

							*psiItem2 = *psiItem2 + 128;
							psiItem2 = psiItem2 + 1;
						}
					}
					/* 处理两路信号 */
					pbyItem1 = (BYTE*)pbyRoundData1;								/* 获取T1起始地址 */
					pbyItem2 = (BYTE*)pbyRoundData2;								/* 获取T2起始地址 */
					if (xMarkHor)													/* 横排基线打开-使用精采样基�??? */
					{
						/* 精采样基�??? */ 
						alrBase[0] = alrBase_Fs[0];
						alrBase[1] = alrBase_Fs[1];
						/* 2024.1.30.145758精采样基线还是要用粗采样计算的�?? */
						if(xFlag_1_s_Calcbase==1)/* 1s算一次吧，减小频率正常算采样还是用精采样基线 */
						{
							/* 计算粗采样基�??? */
							KS_CalcBaselineByData_RS( 	pbyItem1,					/* 粗采样数据T1入口地址 */
														pbyItem2,					/* 粗采样第二路入口地址 */
														4000,						/* 粗采样数据点数|�???�???4000 */
														1,							/* 由于精采样是16bits，粗采样数据8bits，所以放大系数默�???256| */
														0,							/* 对找到的基线进行二次校准 */
														alrBase_RS 					/* 计算的粗采样基线 */
													);
							alrBase_HMI[0]= alrBase_RS[0];
							alrBase_HMI[1]= alrBase_RS[1];
						}
						if(xFlag_1_s_Calcbase==1)
						{
							xFlag_1_s_Calcbase=0;
						}
						else
						{
							xFlag_1_s_Calcbase=1;
						}
					}
					else
					{
						/* 计算粗采样基�??? */
						KS_CalcBaselineByData_RS( pbyItem1,							/* 粗采样数据T1入口地址 */
												  pbyItem2,							/* 粗采样第二路入口地址 */
												  4000,								/* 粗采样数据点数|�???�???4000 */
												  1,								/* 由于精采样是16bits，粗采样数据8bits，所以放大系数默�???256| */
												  0,								/* 对找到的基线进行二次校准 */
												  alrBase_RS 						/* 计算的粗采样基线 */
												);
						alrBase[0] = alrBase_RS[0];
						alrBase[1] = alrBase_RS[1];
						alrBase_HMI[0]= alrBase_RS[0];
						alrBase_HMI[1]= alrBase_RS[1];
					}
					abyBase[0]=(BYTE)alrBase[0];									/* 基线浮点型转整型数据处理 */
					abyBase[1]=(BYTE)alrBase[1];
					if(ABS((REAL)abyBase[0]-alrBase[0])>=0.5)
					{
						alrBase[0]=(REAL)abyBase[0]+1;
					}
					else
					{
						alrBase[0]=(REAL)abyBase[0];
					}
					if(ABS((REAL)abyBase[1]-alrBase[1])>=0.5)
					{
						alrBase[1]=(REAL)abyBase[1]+1;
					}
					else
					{
						alrBase[1]=(REAL)abyBase[1];
					}
					/* >>>>>>>粗采样基线计算完�???>>>>>>> */

					/* 2021.8.20.112235-------------------------------处理显示的波�???----移出到和粗采样无�???-防止移动波形时等待下�???圈才会处�??? */
					abyMinData_Sample[0] = 255;
					abyMinData_Sample[1] = 255;

					pbyItem1_Temp= (BYTE*)pbyRoundData1 ;										/* 根据计算的偏移量算出从站波形显示起始位置 */
					pbyItem2_Temp= (BYTE*)pbyRoundData2 ;
					for( iSig=0; iSig<2; iSig++ )										/* 两路波形循环计算 */
					{
						for(iN = 0 ;iN<800; iN++)
						{
							if(iSig==0)													/* T1波形处理 */
							{
								abyRoundSampleData_485[iN]= 255-*pbyItem1_Temp;			/* 原始�???10V对应0,255对应0V，反转波形，方便显示 */
								/* 2024.5.29.112519处理原始波形拉低问题，排除粗采样�???0||niu.j */
								if(abyMinData_Sample[0]>abyRoundSampleData_485[iN] && abyRoundSampleData_485[iN]!=0)
								{
									abyMinData_Sample[0]=  abyRoundSampleData_485[iN];
								}
								pbyItem1_Temp = pbyItem1_Temp + bySample_Interval;

								if(((unsigned int)pbyItem1_Temp - (unsigned int)pbyRoundData1)>4000)
								{
									pbyItem1_Temp= pbyItem1_Temp - 4000;
								}
							}
							else														/* T2波形处理 */
							{
								abyRoundSampleData_485[iN+800]= 255-*pbyItem2_Temp;		/* 原始�???10V对应0,255对应0V，反转波形，方便显示 */
								/* 2024.5.29.112519处理原始波形拉低问题，排除粗采样�???0||niu.j */
								if(abyMinData_Sample[1]>abyRoundSampleData_485[iN+800] && abyRoundSampleData_485[iN+800]!=0)
								{
									abyMinData_Sample[1]=  abyRoundSampleData_485[iN+800];
								}
								pbyItem2_Temp = pbyItem2_Temp + bySample_Interval;
								if(((unsigned int)pbyItem2_Temp - (unsigned int)pbyRoundData2)>4000)
								{
									pbyItem2_Temp= pbyItem2_Temp - 4000;
								}
							}
						}
					}
					g_wCount_CaseBase=0;												/* 基线计算完成后，清除计数，从新计�??? */

					//2026.4.22.163006+
					xCanRsMorphFilter=1;//可以美化标志@2026.4.22.162427+轮询处理T1 T2
					byRsMorphFilter_T1T2 = 1;//从T1开始轮询

				}//500ms周期计时
			}
			GT_RN_SampleRoundUpdata();													/* 刷新采样 */
		}

		//2026.4.21.165939+粗采样波形美化
		//轮询美化
		//需要确认执行时间@10ms
		if(xCanRsMorphFilter && stStAxisParam.xRsMorphFilter)
		{
			uint16_t wLen_WindowMorph = KsCalcMorphWindowLen((float)stStGrpParam.byTriMark_SideC, (float)stStAxisParam.lrGirth);//形态学结构元素长度，必须为奇数
			//界面显示粗采样波形滤波：去基线漂移
			if(byRsMorphFilter_T1T2 <= 2)//轮询到T2就退出
			{
				if(KS_RsMorphFilter_CheckWindowValid(PUMPPOINT, wLen_WindowMorph))
				{
					if(byRsMorphFilter_T1T2 == 1)
						//T1@前800个点
						KS_RsMorphFilter_U8(abyRoundSampleData_485, PUMPPOINT, wLen_WindowMorph, 2);
					else
						//T2@后800个点
						KS_RsMorphFilter_U8(&(abyRoundSampleData_485[PUMPPOINT]), PUMPPOINT, wLen_WindowMorph, 2);
				}

				byRsMorphFilter_T1T2 += 1;//切换到下一个
			}

			if(byRsMorphFilter_T1T2 > 2)//轮询到T2就复位
				xCanRsMorphFilter = 0;//复位标志
		}

		/* 粗采样处理完�???2021.8.20.112846-------------------------------------------------------------------------- */

		/* 获取两路精采样地�???，用于方便处理正�???10V信号 */
		pbyFineData1 = (char*)&aiFineData1[0];
		pbyFineData2 = (char*)&aiFineData2[0];
		/* 读取精采样数据有效标�??? */
		if(byFineSampleSaveFlag==0)														/* 非采样保存过程中读取精采样数�??? */
		{
			GT_RN_SampleGetFineData( pbyFineData2, pbyFineData1, &iFineSampleFlag );
		}
		if( iFineSampleFlag == 1 )														/* 实际采样数据采集到位 */
		{
			if( xInclNegative10vSignal )												/* 处理±10V电眼信号 */
			{
				piItem1 = (INT*)pbyFineData1;
				piItem2 = (INT*)pbyFineData2;
				//2025.7.15.183816+
				iGateWidthFinePt = stStAxisParam.iGateWidthFinePt_Act;
				if(iGateWidthFinePt<0) iGateWidthFinePt = 1000;
				for( iN=0; iN<iGateWidthFinePt; iN++ )//2025.7.15.183821 常量1000修改为变量
				{
					*piItem1 = *piItem1 + 32768;
					piItem1 = piItem1 + 1;

					*piItem2 = *piItem2 + 32768;
					piItem2 = piItem2 + 1;
				}
			}
			/* 计算误差处理 */
			/* 1.计算误差 */
			/* 2.误差平均 */
			/* 3.05#命令-误差上报 */
			stStAxisParam.iARMRunNum=9;		/* 2022.5.21.084425 */

			xOK_FromMaster = GetBit(stStAxisParam.dwControlBits,4);								/* 单标记||2020.6.24.160749||niu.j|使用单元盒的处理 */
			KS_FB_ProSample(
								&stStPara_PduBroadcastUp,  										/* 通讯参数，上�??? */
								(WORD*)pbyFineData1,											/* 精采样数据地�??? */
								(WORD*)pbyFineData2,											/* 精采样数据地�??? */
								iFineSampleFlag,												/* 精采样有效标 */
								&stStAxisParam,													/* 轴参�??? */
								&stStGrpParam,													/* 系参�??? */
								alrBase,														/* 粗采样基�??? */
								aiError_V,														/* 当前误差队列，用�???485通讯 */
								aiError_H,														/* 横向误差队列 */
								aiFineSample_Data,												/* 计算误差细节描述-基线、最大�?��?�最小�??... */
								&xOK_PosConfirmed,												/* 单标记误差确认按�??? */
								xOK_FromMaster,													/* 单标记误差确�???/单元盒，标志由主站�?�讯 */
								alrThreshold,													/* �???�??? */
								alrBase_Fs,														/* 精采样基线�?? */
								(BYTE*)pbyRoundData1,
								(BYTE*)pbyRoundData2,
								xFlag_SingleMode
							);																    /* 精采样数据处�???-计算误差 */
			if(xOK_FromMaster)																	/* 单标记||2020.6.24.160749||niu.j|使用单元盒的处理 */
			{
				xOK_FromMaster = 0;
				stStAxisParam.dwControlBits &= ~(1<<4);											/* 清除bit4; */
			}
		}
		//2021.8.20.114345|||精采样处理|计算误差|完成----------------------------------------------------------------------------

		//2024.02.01.154601 同步
	    // 2024.1.18.163136/han.dp/弃用从站往主站发送精采样数据/现在的保存工具支持从16D上保存连续整圈的精采样数据
		//处理采样数据保存，精采样需要把值上传给主站-----------------------2021.8.20.140504----------------------------------------------------------------------------------------------------------

		//精采样mailbox发往主站END2021.8.20.140524	-----------------------------------------------------------------------------

		/* >>>>>>>>>>>>>>>>>>485>>>>>>>>>485通讯处理-人机>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
		/* 1.485数据处理 */
		/* 2.485发�?�和接收 */
		/* 人机处理 */
		/*	1.原有程序-和定时器关联，每100ms处理�???次数据，�???100ms发�?�周�??? 
				依次按照�???-写T1-�???-写T2-�???-写其余数据完成一次循环�?�讯，整体周�???600ms，�?�讯�???次波形理论时间最�???2.4s
			2.修改逻辑：与100ms任务无关，现改为由接收中断给出接收完成标志，main函数判断接收完成标志有效后，直接进行下一次�?�讯
				存在问题：根据modbus手册注明：两个报文帧必须有至�???3.5个字符时间的空闲间隔区分
			3.处理：数据写入软件缓冲区后不直接发�?�，启动定时器TIM2使能，等待TIM2中断产生�???
				在中断里处理发�?�缓冲区第一个字节，触发发�?�中断，剩余字节在中断里发�?�完成�??
				由中断触发时间控制报文帧间隔，目前测试至少大�???800us.
			4.处理2：改成自由周期发送后,485通讯速率增加，大约平�???30ms，将通讯过程更改为读-写T1-写T2-写其他数�???
				通讯�???次完整波形数据大约需�???500ms
				处理3：增�???100ms超时判断，当100ms后还没收到接收完成标志，强制再发送一次当前数据�??
				速度加快后，外部中断打断485中断概率增加，容易�?�成485数据丢失，无法判断接收完成，�???要一次超时重�???485.
		*/
		  if((byReceiveEnd||(g_wCount_TimeOut>=gc_485_TimeoutNum)) && xFlag_CopyFromMaster)	/* 进入485通讯处理逻辑 */
		  {
			stStAxisParam.iARMRunNum=11;													/* 2022.5.21.084425 */
			if (g_wCount_TimeOut>=gc_485_TimeoutNum) 										/* 超时标志 */
			{
				g_iCount_TimeOutNum= g_iCount_TimeOutNum+1;									/* 超时计次，发送至人机显示及主站保�??? */
			}
			if(byReceiveEnd||(g_wCount_TimeOut>=gc_485_TimeoutNum))							/* 进入485实际发�?��?�辑 */
			{
				/* 给发送结构体stStModbusComm_Tx填入数据 */
				KS_FB_VISU(																	/* 处理485通讯  */
							&stStAxisParam,												/* 轴参数相�??? */
							&stStGlobalParam,											/* 全局参数相关 */
							&stStGrpParam,												/* 系参数相�??? */
							&stStPara_PduBroadcastUp,									/* 上行参数 */
							&iJourney_HorzRapidAdjust,									/* 横向快�?�对版量 */
							&dwPlateAdjustmentProf,										/* 纵向快�?�对版量 */
							aiError_V,													/* 纵向误差队列 */
							aiError_H,													/* 横向误差队列 */ 
							byLedSwitchTimeouts,										/* 人机屏保延时 */
							&xOK_PosConfirmed,											/* 人机单标记误差确认标�??? */
							&xFlag_Mag,													/* 人机波形横向放大标志 */
							&iWave_offset_Temp,											/* 波形显示偏移�??? */
							iWave_offset,
							bySample_Interval,											/* 波形显示点密�??? */
							&xRefresh_Flag,												/* 波形刷新标志 */
							abyRoundSampleData_485,										/* 485�???要的波形数据 */
							alrBase_HMI,												/* alrBase,			//基线//2024.1.30.150142||不管�???么时候都是用粗采样基线去显示数字波形|Niu.j */
							g_iCount_TimeOutNum,										/* 超时计次 */
							diFineSampleStart,
							abyMinData_Sample
						 );
				}
				g_wCount_TimeOut=0;															/* �???0定时�???100ms计次 */
				byReceiveEnd=0;
		}

		/* >>>>>>>>>>>>>.mailbox+pdu>>>>>>>>>>>>>>>>>>>> */
		/* 等环网�?�讯 */
		/* 1.mailbox通讯-双向修改参数-波门地址、修正量 */
		/* 2.pdu通讯-单向参数-31-35#命令下行-05#上行 */
		if(g_wCount_Comm>=gc_Count_CommNum)
		{
			LED0 = !LED0;
			/* 20ms计时到，进入主从站�?�讯逻辑处理 */
			/* 初始赋�??32，等待主站轴号下�???,如果初始不在1-32范围内，主从通讯逻辑进不去，�???以赋值初�???32 */
			if( xStart == 0 )
			{
				xStart = 1;																/* 只做�???次初始赋�??? */
				stStAxisParam.iAxisId = 32;
			}
			/* 通讯逻辑 */
			stStAxisParam.iARMRunNum=12;		/* 2022.5.21.084425 */
			KS_FB_SyncWithServer(/* 主从站�?�讯逻辑处理 */
									1,
									iStationId,												/* 站号 */
									1,     													/* BOOL;(*拿到Mailbox传输周期|*) */
									&xGetAxisId,											
									&bySignal10VCoef,
									&byScanCount,
									&byLedSwitchTimeouts,      		 						
									&iJourney_HorzRapidAdjust,       						/*2019.8.28.105803_|指向横向快�?�调整量变量|被读取以后会自动清零|*/
									&dwPlateAdjustmentProf,
									&byFineSampleSaveFlag,
									&xFlag_CopyFromMaster,
									&wArmResetCount,										/* 看门狗计数�?? */
									&stStAxisParam,											/* 轴参�??? */
									&stStGrpParam,											/* 系参�??? */
									&stStGlobalParam,										/* 全局参数 */
									&stStPara_PduBroadcastUp,								/* 上行参数 */
									&stStPara_PduBroadcastDn,								/* 下行参数 */
									&stStSyncWithServerOut,
									g_iCount_TimeOutNum,
									/*2021.8.6.095337 */
									/* 2022.6.22.151624										&xSaveRead485Data, */
									&diFineSampleStart,
									alrBase_HMI,      									    /* 基线//2024.1.30.150142||不管�???么时候都是用粗采样基线去显示数字波形|Niu.j|同样给主站的基线也是这样处理 */
									g_wCnt_Rs,
									g_iRtn_Calc2022,
									g_aiVResult,
									g_aiHResult,
									&xFlag_SingleMode
								);
			xInclNegative10vSignal = GetBit(stStAxisParam.wSwitchRef,9);
			g_wCount_Comm=0;


			//在20ms周期任务中执行@2025.6.11.124050+
			//油墨槽脉冲输出控制
			pstStInkGrooveCtl = &stStAxisParam.stStInkGrooveCtl;//地址获取


			//获取通讯的数据@主->arm
			wTmp = (WORD)stStAxisParam.byPulseCtlBit;//低8bit是有效的
			xPulseCtlEn = GetBit(wTmp,0);//脉冲控制使能
			pstStInkGrooveCtl->byMovingSts = GetBit(wTmp,1);
			pstStInkGrooveCtl->xMoveDir = GetBit(wTmp,2);
			pstStInkGrooveCtl->xCtlMode = GetBit(wTmp,3);
			if(pstStInkGrooveCtl->xCtlMode)//位置模式
				pstStInkGrooveCtl->rMoveDis = (REAL)stStAxisParam.wPulseCtlInf / 100;//mm
			else//速度模式
				pstStInkGrooveCtl->rVel = (REAL)stStAxisParam.wPulseCtlInf / 10;//r/min

			stStAxisParam.rInkGroovePosPPulse = (REAL)stStAxisParam.byPulseCtl_DisPerPulse/100000;//单位脉冲运动的距离@mm
			pstStInkGrooveCtl->diMoveDis_Pulse = (DINT)(pstStInkGrooveCtl->rMoveDis / stStAxisParam.rInkGroovePosPPulse) ;//需要运动的脉冲数
			wPulse_1r = stStAxisParam.wPulse_1r;
			if(wPulse_1r==0) wPulse_1r = 6000;
			//将上位机的控制信息重新处理
			KS_ReDealCtlCommand(
				pstStInkGrooveCtl,//通讯获取相关控制内容
				stStAxisParam.byPulseOutSts,//脉冲输出函数反馈@通讯到主站
				&xPulseOutEn_Act,
				&xMoveDir_Act,
				&xPulseCtlMode_Act,
				&xVelMod_Run_Act,
				&rVelMod_Vel_Act,
				&wPosMod_Pulse_Act,
				&stStAxisParam.xInkGrooveInPos);//通讯到主站

			//控制脉冲输出
			KS_PulseOutCtl(
				xPulseOutEn_Act,//控制脉冲输出
				xPulseCtlEn,//脉冲控制使能
				FALSE,//(*清理实际的脉冲数*)
				10,//超时计数值
				wPulse_1r,//1圈的脉冲数
				xPulseCtlMode_Act,//控制模式
				xVelMod_Run_Act,//速度模式 运动使能
				xMoveDir_Act,//方向
				(WORD)10,//起始转速没有通讯下来,写10吧
				(WORD)rVelMod_Vel_Act,//速度模式速度值
				100,//加速时间也没有通讯下来，写成100ms
				&wPosMod_Pulse_Act,//需要写入的脉冲数@0->非零才会执行
				(WORD*)&stStAxisParam.wPulse_Rd,//脉冲个数
				(BYTE*)&stStAxisParam.xPulse_Outing,//脉冲输出中标志@通讯到主站
				(BYTE*)&stStAxisParam.byPulseOutSts,//脉冲输出状态@通讯到主站
				0,
				(DINT*)&pstStInkGrooveCtl->diThisMovedPulse);//本次运动的脉冲数
		}
	}
	else/* 站号�???31--进入以下逻辑 */
	{
		if((byReceiveEnd||(g_wCount_TimeOut>=gc_485_TimeoutNum)) && xFlag_CopyFromMaster)		/* 进入485通讯处理逻辑 */
		{
			stStAxisParam.iARMRunNum=11;		/* 2022.5.21.084425 */
			if (g_wCount_TimeOut>=gc_485_TimeoutNum) 											/* 超时标志 */
			{
				g_iCount_TimeOutNum= g_iCount_TimeOutNum+1;										/* 超时计次，发送至人机显示及主站保�??? */
			}
			if(byReceiveEnd||(g_wCount_TimeOut>=gc_485_TimeoutNum))								/* 进入485实际发�?��?�辑 */
			{
				KS_FB_VISU_IF(
								&stStGlobalParam,											    /* 全局参数相关 */
								&stStGrpParam												    /* 系参数相�??? */
							);
			}
				g_wCount_TimeOut=0;																/* �???0定时�???100ms计次 */
				byReceiveEnd=0;
		}
		/* >>>>>>>>>>>>>.mailbox+pdu>>>>>>>>>>>>>>>>>>>> */
		/* 等环网�?�讯 */
		/* 1.mailbox通讯-双向修改参数-波门地址、修正量 */
		/* 2.pdu通讯-单向参数-31-35#命令下行-05#上行 */
		if(g_wCount_Comm>=gc_Count_CommNum)
		{												/* 20ms计时到，进入主从站�?�讯逻辑处理 */

			LED0 = !LED0;//2025.12.3.143945+
			/* 初始赋�??32，等待主站轴号下�???,如果初始不在1-32范围内，主从通讯逻辑进不去，�???以赋值初�???32 */
			if( xStart == 0 )
			{
				xStart = 1;																	/* 只做�???次初始赋�??? */
				stStAxisParam.iAxisId = 32;
			}
			/* 通讯逻辑 */
			KS_FB_SyncWithServer_Deputy(
											1,												
											iStationId,													
											1,											/* 拿到Mailbox传输周期|*/
											&xFlag_CopyFromMaster,						/* 获取主站参数成功标志 */
											&stStAxisParam,								/* 轴参�??? */
											&stStGrpParam,								/* 系参�??? */
											&stStGlobalParam,							/* 全局参数 */
											&stStPara_PduBroadcastUp,					/* 上行参数 */
											&stStPara_PduBroadcastDn,					/* 下行参数 */
											&stStSyncWithServerOut,						
											&xGetAxisId							    
										);
			g_wCount_Comm=0;
		}
	}

	/* 2024.02.01.154941+处理死机时�?�获取信息实现�?? */
	char xgeten = GetBit(stStAxisParam.wButtonFun,15);
	static unsigned char bygetsts_tmp;/* 备份获取状�?? */
	ks_get_prgcrash_inf(iStationId,&xgeten, &g_bygetsts,&g_getcrash_inf_timecnt_10ms,&exception_crash);
	if(g_bygetsts==3 && bygetsts_tmp !=3)/* 获取成功了，置位标志触发485通讯发�?�到人机界面�??? */
	{
		g_send_crashinf_hmi = 1;
	}
	bygetsts_tmp = g_bygetsts;
	stStAxisParam.wButtonFun=SetBit(xgeten,stStAxisParam.wButtonFun,15);/* 更新获取的按钮位 */
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 25;
  RCC_OscInitStruct.PLL.PLLN = 400;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV4;
  RCC_OscInitStruct.PLL.PLLQ = 2;//2;@2025.11.5.124501+参考keil
  RCC_OscInitStruct.PLL.PLLR = 2;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
//  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
//  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
  //2025.11.5.124710+
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;//参考keil@4分频(25MHZ)|stm32cube 代码time3为5ms,而keil周期为10ms的原因就在这里
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;//同上

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
