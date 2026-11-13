/*
 * Comm.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */
#ifdef __LINUX
#include "linux_com.h"
#else
#include "stdafx.h"
#endif

#include "comm.h"
#include "gt_rn_struct.h"
#include "calcerr.h"
#include "KesaiAPI.h"
#include "base.h"
#include "led.h"
#include "KS_FB_VISU.h"
#include "gt_rn_struct_private.h"
#include "StRingNet.h"
#include "gt_rtn_def.h"
#include "PCIOperate.h"
#include "tim.h"
#include "modbus485.h"

StRingNet Gc_RingNet;
StRingNet* Gc_pRingNet = &Gc_RingNet;
WORD read_H;
WORD read_L;

StSampleParam stStSampleParam					;//				: StSampleParam;
StSampleParam stStSampleParam_UpParam			;//				: StSampleParam;
StSampleParam stStSampleParam_Updata			;//				: StSampleParam;
StSampleParam stStSampleParam_GN				;//				: StSampleParam;

INT aiCfgData[32]								;//				: ARRAY [1..30] OF INT := 30(0);

INT aiCfgData_UpParam[32]						;//				: ARRAY [1..30] OF INT := 30(0);
INT aiCfgData_Updata[32]						;//				: ARRAY [1..30] OF INT := 30(0);
INT aiCfgData_GN[32]							;//				: ARRAY [1..30] OF INT := 30(0);

BYTE abyBuf[gc_iMailboxBlockLen]				;//: ARRAY [1..gc_iMailboxBlockLen] OF BYTE;
INT aiRtnCode[10]={0}							;//: ARRAY [1..10] OF INT := 10(0);
DWORD adwBuf[32]								;//: ARRAY [1..32] OF DWORD;(*MailCom通讯数据内存|*)
DWORD dwRoundSampleThreshold;//主站下发的粗采样阀值
static BYTE byFineSampleSaveFlag;//主站下发的按钮
static BYTE byFineSampleSaveFlag_Temp;//临时判断主站下发的按钮
static BYTE byFineSampleSaveFlag_PreTemp;//保存上个周期主站传下来的采样保存按钮
//2022.3.19.173528
static INT iCmdId=5;


//2025.10.29.165433 LED1 闪烁实现
void KS_Led1Flick(uint16_t uiFlickTime_ms,uint16_t *ptimer_ms)//ptimer_ms 计时器,内部清零
{
	//非法值处理
	uint16_t uiFlickTime_Use = uiFlickTime_ms;
	if(uiFlickTime_Use == 0)
		uiFlickTime_Use = 1000;

	if(*ptimer_ms >= uiFlickTime_Use)
	{
		*ptimer_ms = 0;
//		if(HAL_GPIO_ReadPin(LED1_GPIO_Port,LED1_Pin) != GPIO_PIN_SET)
//			HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);  //LED1=0;
//		else
//			HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_RESET);  //LED1=0;
		LED1 = !LED1;
	}
	return;
}


/*2025.09.06.141803//xi.hy//数码管控制*/
void KS_DigitalTubesCtl(
		uint16_t i_uinumDisplay,	 //需要显示的值
		uint8_t i_xpointDisplay,	 //是否需要显示右下角的点
		uint8_t i_byClose_DigitalTubes//关闭数码管显示
		)
{
	//初始化值
	uint16_t iCode=0;//2025.9.8.101020 调整了下数据类型@liu.yt
	//int16_t iRtnRdID=0;

	if(!i_byClose_DigitalTubes)//没有关闭数码管显示，数码管按照正常输入显示
	{
	    switch (i_uinumDisplay)
	    {
			case 0: iCode = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5); break;
			case 1: iCode = (1<<1)|(1<<2); break;
			case 2: iCode = (1<<0)|(1<<1)|(1<<3)|(1<<4)|(1<<6); break;
			case 3: iCode = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<6); break;
			case 4: iCode = (1<<1)|(1<<2)|(1<<5)|(1<<6); break;
			case 5: iCode = (1<<0)|(1<<2)|(1<<3)|(1<<5)|(1<<6); break;
			case 6: iCode = (1<<0)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6); break;
			case 7: iCode = (1<<0)|(1<<1)|(1<<2); break;
			case 8: iCode = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6); break;
			case 9: iCode = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<5)|(1<<6); break;
			case 10: iCode = (1<<0)|(1<<1)|(1<<2)|(1<<4)|(1<<5)|(1<<6); break;   // A
			case 11: iCode = (1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6); break;          // b	小写b和d便于区分
			case 12: iCode = (1<<0)|(1<<3)|(1<<4)|(1<<5); break;          		 // C
			case 13: iCode = (1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<6); break;          // d	小写b和d便于区分
			case 14: iCode = (1<<0)|(1<<3)|(1<<4)|(1<<5)|(1<<6); break;          // E
			case 15: iCode = (1<<0)|(1<<4)|(1<<5)|(1<<6); break;          		 // F
			default: iCode = (1<<6);; // 输入不是0-15，显示"-",应该不会到达这里
	    }

	    if(i_xpointDisplay) iCode |= (1<<7); //点亮右下角的点
	}
	else //关闭数码管显示
	{
		iCode=0;
	}

    GT_RN_WriteFPGA(SMG_ADR, &iCode);
}

//2025.09.06.151119//xi.hy//数码管显示站号
void KS_ShowId_DigitalTubes(uint16_t i_uiStationId,//站号
						   uint16_t* i_puiTime_DigitalTubes,//数码管显示的中断时间计数
						   uint8_t i_xpointDisplay)	 //是否需要显示右下角的点
{
	//初始化一些局部变量
	uint16_t uiTime_DigitalTubes=*i_puiTime_DigitalTubes;//数码管时间计数值
	uint8_t byPos = 0;//当前处理到的位置
	uint8_t byShift = 12;//需要右移的位数
	uint8_t byVal = 0; //取出的当前这四位的值
	static uint8_t byIndex_DigitalTubes=0;//当前数码管显示值的索引
	uint8_t byCount_DigitalTubes=0;//本次数码管显示的有效位数
	static uint8_t byDelay_DigitalTubes=0;//是否进入中间熄灭状态的标志
	uint8_t byCode_Temp=0;//当前数码管轮询到哪个值
	uint8_t abyChar_Valid[4]; // 有效字符缓存：0~F

	//拆分需要显示的值
	do{
		byVal=(i_uiStationId>>byShift) & 0x0F;
		if(byPos//在此之前已经更高位已经出现过有效值，那么这一位0或非0都要保留
			||byVal //这一位非0，保留
			||byShift==0)//最低位0或非0都要保留
			abyChar_Valid[byPos++]=byVal;//保存有效位的值
		byShift -=4;//偏移位变化
	}while(byShift<=12);

	byCount_DigitalTubes=byPos;//本次数码管显示的有效位数

	//数码管显示的值按周期轮询的处理
	if(!byDelay_DigitalTubes)
	{
		if(uiTime_DigitalTubes>=500)//500ms切换下一位
		{
			if(byCount_DigitalTubes>1)
				byIndex_DigitalTubes=(byIndex_DigitalTubes+1) % byCount_DigitalTubes;
			else
				byIndex_DigitalTubes=0;

			if(byIndex_DigitalTubes==0 && byCount_DigitalTubes>1)//判断是否刷完整组,并且有效位数大于1才进入闪烁
				byDelay_DigitalTubes=1;

			*i_puiTime_DigitalTubes=0;
		}
	}
	else//进入组之间的熄灭阶段
	{
		if(uiTime_DigitalTubes>=2000)//2s熄灭
		{
			byDelay_DigitalTubes=0;
			*i_puiTime_DigitalTubes=0;
		}
	}
	//当前轮询到哪个值
	byCode_Temp=abyChar_Valid[byIndex_DigitalTubes];

	//最终显示
	KS_DigitalTubesCtl(byCode_Temp,
						i_xpointDisplay,
						byDelay_DigitalTubes);
}

 WORD Get_SampleParamUpda(short axis, short *cfg_data)
 {
 	 StPci pci;
	 WORD i;
	 _ENTER_CRITICAL_SECTION(NULL)
	 pci.baseAddr = Gc_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_KESAI_SAMPLE_DSP_BASE;
	 for(i = 0; i < 14; i++) //reference th document "GTSD13 register discription document"
	 {
		 PciReadData16(pci, i, &cfg_data[i]);
	 }
	_EXIT_CTRITCAL_SECTION(NULL);
	return RTN_SUCCESS;
 }

 INT KS_InitSample(INT i_iStationId)//激活本地采样
 {
 	GT_RN_SampleSetLocalShowDeviceId(i_iStationId);
 	GT_RN_SampleRoundUpdata();
 	return 1;
 }

 WORD KS_CRC(BYTE* i_pbyBuf,INT i_iLen,DWORD* i_pdwSumResult)
 {
 	INT iN					;
 	WORD wMask				;
 	WORD wResult			;
 	DWORD dwSumResult		;
 	BYTE* pbyTemp			;
 	//(* This mysterious table is just the CRC OF each possible BYTE.  It can be
 	///* computed using the standard bit-AT-a-TIME methods.  The polynomial can
 	///* be seen in entry 128, 0x8408.  This corresponds TO x^0 + x^5 + x^12.
 	///* ADD the implicit x^16, AND you have the standard CRC-CCITT.|*)
 	WORD gc_awDictCRC[256]=
 		{0x0000, 0x1189, 0x2312, 0x329B, 0x4624, 0x57AD, 0x6536, 0x74BF,
 		0x8C48, 0x9DC1, 0xAF5A, 0xBED3, 0xCA6C, 0xDBE5, 0xE97E, 0xF8F7,
 		0x1081, 0x0108, 0x3393, 0x221A, 0x56A5, 0x472C, 0x75B7, 0x643E,
 		0x9CC9, 0x8D40, 0xBFDB, 0xAE52, 0xDAED, 0xCB64, 0xF9FF, 0xE876,
 		0x2102, 0x308B, 0x0210, 0x1399, 0x6726, 0x76AF, 0x4434, 0x55BD,
 		0xAD4A, 0xBCC3, 0x8E58, 0x9FD1, 0xEB6E, 0xFAE7, 0xC87C, 0xD9F5,
 		0x3183, 0x200A, 0x1291, 0x0318, 0x77A7, 0x662E, 0x54B5, 0x453C,
 		0xBDCB, 0xAC42, 0x9ED9, 0x8F50, 0xFBEF, 0xEA66, 0xD8FD, 0xC974,
 		0x4204, 0x538D, 0x6116, 0x709F, 0x0420, 0x15A9, 0x2732, 0x36BB,
 		0xCE4C, 0xDFC5, 0xED5E, 0xFCD7, 0x8868, 0x99E1, 0xAB7A, 0xBAF3,
 		0x5285, 0x430C, 0x7197, 0x601E, 0x14A1, 0x0528, 0x37B3, 0x263A,
 		0xDECD, 0xCF44, 0xFDDF, 0xEC56, 0x98E9, 0x8960, 0xBBFB, 0xAA72,
 		0x6306, 0x728F, 0x4014, 0x519D, 0x2522, 0x34AB, 0x0630, 0x17B9,
 		0xEF4E, 0xFEC7, 0xCC5C, 0xDDD5, 0xA96A, 0xB8E3, 0x8A78, 0x9BF1,
 		0x7387, 0x620E, 0x5095, 0x411C, 0x35A3, 0x242A, 0x16B1, 0x0738,
 		0xFFCF, 0xEE46, 0xDCDD, 0xCD54, 0xB9EB, 0xA862, 0x9AF9, 0x8B70,
 		0x8408, 0x9581, 0xA71A, 0xB693, 0xC22C, 0xD3A5, 0xE13E, 0xF0B7,
 		0x0840, 0x19C9, 0x2B52, 0x3ADB, 0x4E64, 0x5FED, 0x6D76, 0x7CFF,
 		0x9489, 0x8500, 0xB79B, 0xA612, 0xD2AD, 0xC324, 0xF1BF, 0xE036,
 		0x18C1, 0x0948, 0x3BD3, 0x2A5A, 0x5EE5, 0x4F6C, 0x7DF7, 0x6C7E,
 		0xA50A, 0xB483, 0x8618, 0x9791, 0xE32E, 0xF2A7, 0xC03C, 0xD1B5,
 		0x2942, 0x38CB, 0x0A50, 0x1BD9, 0x6F66, 0x7EEF, 0x4C74, 0x5DFD,
 		0xB58B, 0xA402, 0x9699, 0x8710, 0xF3AF, 0xE226, 0xD0BD, 0xC134,
 		0x39C3, 0x284A, 0x1AD1, 0x0B58, 0x7FE7, 0x6E6E, 0x5CF5, 0x4D7C,
 		0xC60C, 0xD785, 0xE51E, 0xF497, 0x8028, 0x91A1, 0xA33A, 0xB2B3,
 		0x4A44, 0x5BCD, 0x6956, 0x78DF, 0x0C60, 0x1DE9, 0x2F72, 0x3EFB,
 		0xD68D, 0xC704, 0xF59F, 0xE416, 0x90A9, 0x8120, 0xB3BB, 0xA232,
 		0x5AC5, 0x4B4C, 0x79D7, 0x685E, 0x1CE1, 0x0D68, 0x3FF3, 0x2E7A,
 		0xE70E, 0xF687, 0xC41C, 0xD595, 0xA12A, 0xB0A3, 0x8238, 0x93B1,
 		0x6B46, 0x7ACF, 0x4854, 0x59DD, 0x2D62, 0x3CEB, 0x0E70, 0x1FF9,
 		0xF78F, 0xE606, 0xD49D, 0xC514, 0xB1AB, 0xA022, 0x92B9, 0x8330,
 		0x7BC7, 0x6A4E, 0x58D5, 0x495C, 0x3DE3, 0x2C6A, 0x1EF1, 0x0F78};

 //---------------------定义结束---------------------------//
 	pbyTemp= i_pbyBuf;
 	wResult= 0;
 	dwSumResult= 0;//(*Rev. han.dp@2017年3月6日 14:47:20 增加一个文件的累加和,单字节累加存放到dword类型中,约最大15MB数据多*)
 	for(iN=0;iN<i_iLen;iN++)
 	{
 		dwSumResult= dwSumResult+(*pbyTemp);//(*Rev. han.dp@2017年3月6日 14:48:51*)
 		wMask= gc_awDictCRC[(INT)((wResult ^ (WORD)(*pbyTemp)) & 0xFF)];
 		wResult= wMask ^ wResult>>8;
 		pbyTemp= pbyTemp+1;
 	}
 	if(i_pdwSumResult!=0)
 	{
 		*i_pdwSumResult= dwSumResult;
 	}
 	return wResult;//CRC结果
 }

 INT KS_CfgAxisSampleParam(
 		StAxisParam* i_pstStAxisParam,
 		DINT* pdiFineSampleStart,
 		DINT* i_pdiArgumentToArc,
		//2025.1.4.152437+
		BYTE i_byArcFineSampleType)//(*套色精采样方式@=0 原来的20mm采样| =1 双眼采样所有色标@单个波门*)
 {
 	INT	iResult					;//				: INT	;
 	STRING sN					;//				: STRING;
 	REAL lrN					;//				: LREAL	;
 	DINT diN					;//				: DINT	;
 	INT	iStationId				;//				: INT	;
	INT	iLocalGateSa1			;//				: INT	;
	INT	iLocalGateSa2			;//				: INT	;
 	INT	iGateSaRoundPtOffset	;
 	REAL lrPPR_PrintRoller		;//				: LREAL	;
 	REAL lrInversedPrecision	;//				: LREAL	;
 	static INT iTemp_Count		;
 	short iGateWidthFinePt_Act_Door1 = 1000;//实际的波门1内精彩样值
 	INT i						;
 	//定义结束---------------------------
 	iResult=0;

 	if(i_pstStAxisParam!=0)//(*参数有效|*)
 	{
 		iStationId=i_pstStAxisParam->iStationId;//(*站id|*)
 		if(iStationId>=0 && iStationId<MAX_STATION_NUM)//(*站id有效|*)
 		{
 			stStSampleParam.ctl= i_pstStAxisParam->iSampleCfgParam_Ctl;//(*采样控制位|*)
 			stStSampleParam.rsvd0= 0;
 			stStSampleParam.motorPulse= 4194304;//(*采样位数|*)
 			stStSampleParam.printerN= i_pstStAxisParam->uiNum;//i_pstStAxisParam->uiNum;//(*减速比电机侧|*)
 			stStSampleParam.motorM= i_pstStAxisParam->uiDen;//i_pstStAxisParam->uiDen;//(*减速比负载侧|*)
 			stStSampleParam.rollorperimeter= i_pstStAxisParam->lrGirth/1000;//i_pstStAxisParam->lrGirth/1000;//(*印版周长(单位:m)|*)
 			stStSampleParam.precisionbit= 5;//(*精度位|*)
 			//2024.8.14.093618 替换为了通讯变量
 			//stStSampleParam.systemPrecision= 0.02;//(*采样物理精度(单位:mm)|*)
 			stStSampleParam.systemPrecision= (double)i_pstStAxisParam->bySysSamplePrecision / 100.0;//(*采样物理精度(单位:mm)|*)
			if(stStSampleParam.systemPrecision<=0) stStSampleParam.systemPrecision = 0.02;//出错处理@2024.8.14.093748

 			i_pstStAxisParam->lrInversedPrecision= stStSampleParam.systemPrecision;

 			stStSampleParam.maxRollorSpeed= 600;
 			stStSampleParam.roundSamplePoint= 4000;//(*粗采样点数|*)
 			lrPPR_PrintRoller= ((REAL)(stStSampleParam.printerN)/stStSampleParam.motorM)*stStSampleParam.motorPulse;//(*印版一圈对应电机的脉冲数|*)
 			//(*分子*)
 			lrN= stStSampleParam.systemPrecision*stStSampleParam.motorPulse*(REAL)(stStSampleParam.printerN);
 			lrN= lrN/(REAL)(stStSampleParam.motorM)/stStSampleParam.rollorperimeter/32.0/1000.0;
 			sN= (STRING)(lrN);
 			diN= (DINT)(sN); //(*换算出整数的分子*)
 			//(*分母*)
 			lrN= stStSampleParam.motorPulse*(REAL)(stStSampleParam.printerN);
 			lrN= lrN/(REAL)(stStSampleParam.motorM)/stStSampleParam.rollorperimeter/32.0/1000.0;
 			//(*系统采样精度*)
 			lrInversedPrecision= (REAL)(diN)/lrN;
 			i_pstStAxisParam->lrInversedPrecision= lrInversedPrecision;

 			//2025.1.4.153808+
 			if(i_byArcFineSampleType == 1) //采集整段精采用配置@2025.1.4.153245
 			{
 				//2024.8.21.191212重新处理一下采样2024.8.21.191223
 				stStSampleParam.fineSamplePoint= 4000;//2024.8.21.191356直接采样最大宽度
 				//处理一下采样起始计算
 				short iGateSaTmp;//波门起始地址
 				iGateSaTmp= i_pstStAxisParam->iGateSa;
 				if(i_pstStAxisParam->iMarkArrangeModal== MARK_ARRANGE_VFOR ||
 						i_pstStAxisParam->iMarkArrangeModal== MARK_ARRANGE_HFOR	)//顺序
 				{
 					if(i_pstStAxisParam->byColorIdCurrent>=2)
 					{
 						iGateSaTmp= i_pstStAxisParam->iGateSa-
 								(i_pstStAxisParam->byColorIdCurrent-1)*(short)(20.0*4000.0/i_pstStAxisParam->lrGirth);
 					}
 					while(iGateSaTmp<0)
 					{
 						iGateSaTmp= iGateSaTmp+4000;
 					}
 				}
 				stStSampleParam.fineStartOffset= (DINT)(((REAL)(iGateSaTmp)/stStSampleParam.roundSamplePoint)*lrPPR_PrintRoller);
 				*pdiFineSampleStart = stStSampleParam.fineStartOffset;
 				stStSampleParam.secondStartOffset= 0;
 				if(i_pdiArgumentToArc!=0)
 				{
 					*i_pdiArgumentToArc= 0;
 				}
 			}
 			else //原来配置采样的方式
 			{
				if(i_pstStAxisParam->xFlag_Gate_double)
				{
					switch(i_pstStAxisParam->iMarkArrangeModal)
					{
					case MARK_ARRANGE_VREV:case MARK_ARRANGE_HREV: //(*逆序|*)
						iLocalGateSa1= i_pstStAxisParam->iGateSa;//(*当前色|*)
						iLocalGateSa2= i_pstStAxisParam->iGateSaEx;//(*要跟踪的色|*)
						break;
					default:
						iLocalGateSa1= i_pstStAxisParam->iGateSaEx;//(*要跟踪的色|*)
						iLocalGateSa2= i_pstStAxisParam->iGateSa;//(*当前色|*)
					}
					//(*Rev.
					//.han.dp@2017-04-06 17:19:07
					//.把波门间隔算出来.
					//*)
					iGateSaRoundPtOffset= iLocalGateSa2-iLocalGateSa1; //(*两个波门差*)
					while(iGateSaRoundPtOffset<0)
					{
						iGateSaRoundPtOffset= iGateSaRoundPtOffset+4000;
					}
					if(iGateSaRoundPtOffset<i_pstStAxisParam->iGateWidthRondPt)//针对2色的情况，除去判断里面的等于限制，只有两个波门重合时候再说，2色也需要计算一个偏移量
						//(*如果波门间隔点数小于波门的宽度|直接采集两个波门宽度即可|2023.7.3.154735*)
					{
						stStSampleParam.fineStartOffset= (DINT)(((REAL)(iLocalGateSa1)/stStSampleParam.roundSamplePoint)*lrPPR_PrintRoller);
						stStSampleParam.secondStartOffset= 0;
						iGateSaRoundPtOffset= i_pstStAxisParam->iGateWidthRondPt;//(*波门的起点差是1个波门宽*)
						if(i_pdiArgumentToArc!=0)
						{
							//当两个波们重叠后，是连续采了2000个点，所以这个时候实际波们差=1000个点对应的物理距离
							//2023.08.02.193018||niu.j|单位：丝
							//*i_pdiArgumentToArc= (DINT)((REAL)(iGateSaRoundPtOffset)*i_pstStAxisParam->lrGirth*100/(REAL)(stStSampleParam.roundSamplePoint));
							*i_pdiArgumentToArc= i_pstStAxisParam->iGateWidthFinePt *i_pstStAxisParam->lrInversedPrecision*100;
						}
					}
					else
					{
						stStSampleParam.fineStartOffset= (DINT)(((REAL)(iLocalGateSa1)/stStSampleParam.roundSamplePoint)*lrPPR_PrintRoller);
						lrN= (REAL)(iGateSaRoundPtOffset);
						lrN= lrN * i_pstStAxisParam->lrGirth / (float)4000.0;
						//2024.8.22.173904
						//这里只是为了计算实际的点数计算偏移,故使用临时变量处理@2025.7.26.092842+
						//i_pstStAxisParam->iGateWidthFinePt= (short)((float)i_pstStAxisParam->iGateWidthPhy/lrInversedPrecision);
						//lrN= lrN/lrInversedPrecision- i_pstStAxisParam->iGateWidthFinePt;

						//2025.11.17.160122+ 需要使用实际配置的精采样点数
						//iGateWidthFinePt_Act_Door1= (short)((float)i_pstStAxisParam->iGateWidthPhy/lrInversedPrecision);
						iGateWidthFinePt_Act_Door1 = i_pstStAxisParam->iGateWidthFinePt;
						lrN= lrN/lrInversedPrecision- iGateWidthFinePt_Act_Door1;
						diN= (DINT)(lrN+(float)0.5);//需要加0.5才能实现四舍五入2023.5.2.141554
						stStSampleParam.secondStartOffset= (diN<<stStSampleParam.precisionbit);
						//(*Rev. han.dp@2017-05-30 18:14:21
						//.到这里,色标的间距差是 iGateSaRoundPtOffset,单位:是粗采样点数
						//.直接换算成物理距离 输出到：io_diArgumentToXW，单位：0.01mm
						//*)2023.4.27.085507这里计算的距离信息需要在计算误差里应用
						if(i_pdiArgumentToArc!=0)
						{
							*i_pdiArgumentToArc= (DINT)((REAL)(iGateSaRoundPtOffset)*i_pstStAxisParam->lrGirth*100/(REAL)(stStSampleParam.roundSamplePoint));
						}
					}
					stStSampleParam.fineSamplePoint= i_pstStAxisParam->iGateWidthFinePt*2 ;
				}
				else //单波门@2025.1.4.153107+注释
				{
					stStSampleParam.fineSamplePoint= i_pstStAxisParam->iGateWidthFinePt;
					stStSampleParam.fineStartOffset= (DINT)(((REAL)(i_pstStAxisParam->iGateSa)/stStSampleParam.roundSamplePoint)*lrPPR_PrintRoller);
					*pdiFineSampleStart = stStSampleParam.fineStartOffset;
					stStSampleParam.secondStartOffset= 0;
					if(i_pdiArgumentToArc!=0)
					{
						*i_pdiArgumentToArc= 0;
					}
				}
 			}
 			i_pstStAxisParam->iGateWidthFinePt_Act = stStSampleParam.fineSamplePoint;//实际的精彩样点数@2025.7.26.091931+
 			stStSampleParam.virtualPanPoint= 8000;
			stStSampleParam.posVirtualPan= 0;
			stStSampleParam.rsed1=0;
			GT_RN_SampleSetSampleParam(&stStSampleParam, aiCfgData);
			stStSampleParam_UpParam= stStSampleParam;
			for(i=0;i<32;i++)
			{
				aiCfgData_UpParam[i]= aiCfgData[i];
			}
			//刷新采样参数
			GTD_SampleParamUpda(1, aiCfgData);//awTimeTest[2] = TIM2->CNT;
			stStSampleParam_Updata= stStSampleParam;
			for(i=0;i<32;i++)
			{
				aiCfgData_Updata[i]= aiCfgData[i];
			}

			GT_RN_SampleRoundUpdata();
			stStSampleParam_GN = stStSampleParam;
			for(i=0;i<32;i++)
			{
				aiCfgData_GN[i]= aiCfgData[i];
			}
			iTemp_Count=iTemp_Count+1;

 		}
 		else
 		{
 			iResult=-2;
 		}
 	}
	else
	{
		iResult=-1;
	}
 	return iResult;
 }

 INT KS_CfgAxisSampleParam_New(
 		StAxisParam* i_pstStAxisParam,
 		DINT* pdiFineSampleStart,
 		DINT* i_pdiArgumentToArc)//	: POINTER TO StAxisParam;(*轴参数地址|*)
 {
	INT	iResult					;//				: INT	;
	STRING sN					;//				: STRING;
	REAL lrN					;//				: LREAL	;
	DINT diN					;//				: DINT	;
	INT	iStationId				;//				: INT	;
	REAL lrPPR_PrintRoller		;//				: LREAL	;
	REAL lrInversedPrecision	;//				: LREAL	;
	static INT iTemp_Count;

	INT i;
	//定义结束---------------------------

	iResult=0;
	if(i_pstStAxisParam!=0)//(*参数有效|*)
	{
		iStationId=i_pstStAxisParam->iStationId;//(*站id|*)
		if(iStationId>=0 && iStationId<MAX_STATION_NUM)//(*站id有效|*)
		{
			stStSampleParam.ctl= i_pstStAxisParam->iSampleCfgParam_Ctl;//i_iCtl;//(*采样控制位|*)
			stStSampleParam.rsvd0= 0;
			stStSampleParam.motorPulse= 4194304;//(*采样位数|*)
			stStSampleParam.printerN= i_pstStAxisParam->uiNum;//i_pstStAxisParam->uiNum;//(*减速比电机侧|*)
			stStSampleParam.motorM= i_pstStAxisParam->uiDen;//i_pstStAxisParam->uiDen;//(*减速比负载侧|*)
			stStSampleParam.rollorperimeter= i_pstStAxisParam->lrGirth/1000;//i_pstStAxisParam->lrGirth/1000;//(*印版周长(单位:m)|*)
			stStSampleParam.precisionbit= 6;//(*精度位|*)
			//2024.8.14.093618 替换为了通讯变量
			//stStSampleParam.systemPrecision= 0.02;//(*采样物理精度(单位:mm)|*)
			stStSampleParam.systemPrecision= (double)i_pstStAxisParam->bySysSamplePrecision / 100.0;//(*采样物理精度(单位:mm)|*)
			if(stStSampleParam.systemPrecision<=0) stStSampleParam.systemPrecision = 0.06;//出错处理@2024.8.14.093748

			i_pstStAxisParam->lrInversedPrecision= stStSampleParam.systemPrecision;

			stStSampleParam.maxRollorSpeed= 600;
			stStSampleParam.roundSamplePoint= 4000;//(*粗采样点数|*)
			lrPPR_PrintRoller= ((REAL)(stStSampleParam.printerN)/stStSampleParam.motorM)*stStSampleParam.motorPulse;//(*印版一圈对应电机的脉冲数|*)
			//(*分子*)
			lrN= stStSampleParam.systemPrecision*stStSampleParam.motorPulse*(REAL)(stStSampleParam.printerN);
			lrN= lrN/(REAL)(stStSampleParam.motorM)/stStSampleParam.rollorperimeter/32.0/1000.0;
			sN= (STRING)(lrN);
			diN= (DINT)(sN); //(*换算出整数的分子*)

			//(*分母*)
			lrN= stStSampleParam.motorPulse*(REAL)(stStSampleParam.printerN);
			lrN= lrN/(REAL)(stStSampleParam.motorM)/stStSampleParam.rollorperimeter/32.0/1000.0;

			//(*系统采样精度*)
			lrInversedPrecision= (REAL)(diN)/lrN;
			i_pstStAxisParam->lrInversedPrecision= lrInversedPrecision;

			//2024.8.21.191212重新处理一下采样2024.8.21.191223
			stStSampleParam.fineSamplePoint= 4000;//2024.8.21.191356直接采样最大宽度
			//处理一下采样起始计算
			short iGateSaTmp;//波门起始地址
			iGateSaTmp= i_pstStAxisParam->iGateSa;
			if(i_pstStAxisParam->iMarkArrangeModal== MARK_ARRANGE_VFOR ||
					i_pstStAxisParam->iMarkArrangeModal== MARK_ARRANGE_HFOR	)//顺序
			{
				if(i_pstStAxisParam->byColorIdCurrent>=2)
				{
					iGateSaTmp= i_pstStAxisParam->iGateSa-
							(i_pstStAxisParam->byColorIdCurrent-1)*(short)(20.0*4000.0/i_pstStAxisParam->lrGirth);
				}
				while(iGateSaTmp<0)
				{
					iGateSaTmp= iGateSaTmp+4000;
				}
			}

			stStSampleParam.fineStartOffset= (DINT)(((REAL)(iGateSaTmp)/stStSampleParam.roundSamplePoint)*lrPPR_PrintRoller);
			*pdiFineSampleStart = stStSampleParam.fineStartOffset;
			stStSampleParam.secondStartOffset= 0;
			if(i_pdiArgumentToArc!=0)
			{
				*i_pdiArgumentToArc= 0;
			}

			stStSampleParam.virtualPanPoint= 8000;
			stStSampleParam.posVirtualPan= 0;
			stStSampleParam.rsed1=0;

			GT_RN_SampleSetSampleParam(&stStSampleParam, aiCfgData);
			stStSampleParam_UpParam= stStSampleParam;
			for(i=0;i<32;i++)
			{
				aiCfgData_UpParam[i]= aiCfgData[i];
			}
			//刷新采样参数
			GTD_SampleParamUpda(1, aiCfgData);//awTimeTest[2] = TIM2->CNT;
			stStSampleParam_Updata= stStSampleParam;
			for(i=0;i<32;i++)
			{
				aiCfgData_Updata[i]= aiCfgData[i];
			}

			GT_RN_SampleRoundUpdata();
			stStSampleParam_GN = stStSampleParam;
			for(i=0;i<32;i++)
			{
				aiCfgData_GN[i]= aiCfgData[i];
			}
			iTemp_Count=iTemp_Count+1;
		}
		else
		{
			iResult=-2;
		}
	}
	else
	{
		iResult=-1;
	}
	return iResult;
 }

 void KS_FB_SyncWithServer(
 					BYTE i_xEn,
 					BYTE i_iStationId					,
 					BYTE i_xGotTheMailboxClock			,       //		: BOOL;(*拿到Mailbox传输周期|*)
 					BYTE* i_pxGetAxisId					,       //		: POINTER TO BOOL;
 					BYTE* i_pbySignal10VCoef,
 					BYTE* i_pbyScanCount,
 					BYTE* i_pbyLedSwitchTimeouts			,       //		: POINTER TO BYTE;
 					INT* i_piJourney_HorzRapidAdjust		,       //		: POINTER TO INT := 0;(*2019.8.28.105803_|指向横向快速调整量变量|被读取以后会自动清零|*)
 					DWORD* i_pdwPlateAdjustmentProf         ,
 					BYTE* i_pbyFineSampleSaveFlag            ,
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
 					INT i_aiVResult[2],//,
 					INT i_aiHResult[2],
 					BYTE* i_pxFlag_SingleMode//2022.5.17.152932
 					)
 {
 	INT iStationId										;//: INT;
 	WORD wTempChk										;//: WORD;

 	StCMD_31* pstStCMD_31								;//: POINTER TO StCMD_31;
 	StCMD_32* pstStCMD_32								;//: POINTER TO StCMD_32;
 	StCMD_33* pstStCMD_33								;//: POINTER TO StCMD_33;
 	StCMD_34* pstStCMD_34								;//: POINTER TO StCMD_34;
 	StCMD_35* pstStCMD_35								;//: POINTER TO StCMD_35;
 	StCMD_36* pstStCMD_36								;//: POINTER TO StCMD_36;
 	StCMD_37* pstStCMD_37								;//: POINTER TO StCMD_37;//2026.06.15.135847||wang.xy
 	DWORD* pdwTemp=NULL									;//: POINTER TO DWORD;
 	static DWORD dwReCfgFlag							;//: DWORD;(* bit0=1 is need reset sample parameter; bit1=1 need call 'GTD_ClrSampleCfg()' before reset sample parameter *)
 	BYTE* pbyBuf										;//: POINTER TO BYTE; (*char buffer's pointer*)
 	DWORD dwParaUpdateFlag								;//: DWORD;(*用来判断参数是否发生变化|*)
 	DWORD dwParaUpdateFlag_1							;//: DWORD;(*用来判断参数是否发生变化|*)2022.3.19.170744
 	StPara_MailboxAlternate* pstStPara_MailboxAlternate				;//: POINTER TO StPara_MailboxAlternate;

 	DWORD dwCheckSumVal									;//: DWORD;
 	static BYTE xGetCopyFromSrvOk=0						;//: BOOL := FALSE;(*用来表示从服务器下载copy成功|*)
 	static WORD wStatusRef_Rec							;//: WORD;(*色组状态|*)
 	static REAL lrAdjust_V_Rec							;//: LREAL;(*纵向调整量|*)
 	static REAL lrAdjust_H_Rec							;//: LREAL;(*横向调整量|*)
 	static INT iGateSa_Rec								;//: INT;(*波门地址|*)
 	static INT iGateSaEx_Rec							;//: INT;(*波门地址2|*)
 	static WORD wButtonFun_Rec;
 	DWORD dwPlateAdjustmentProf=0						;//: DWORD := 0;(*快速对版|*)
 	BYTE xReqDispatchAgain								;//: BOOL;
 	INT iGrpId											;//: INT;
 	static INT iCountdownRedispatchReq=0				;//: INT := 0;
 	BYTE* pbyLedSwitchTimeouts							;//: POINTER TO BYTE;
 	//(*2019.4.2.191222|*)                  		 	//
 	static DWORD dwControlBits_Rec						;//: DWORD;
 	DWORD dwPayloadLen									;//: DWORD;
 	static WORD wDWordNum								;//: WORD;
 	static WORD wMasterParam_Flag=0						;//获取主站参数标志
 	BYTE byGrpId_Temp									;//: BYTE;(*2019.8.21.134616|*)
 	//(*-------------------------------------------------|2019.8.28.105543_*)
 	INT iJourney_HorzRapidAdjust_Tmp					;//: INT;
 	INT iN												;//for循环变量
 	BYTE byGrpid_Dn;
 	BYTE byTemp;
 	StCMD_05* pstStCMD_05;
 	//2022.3.19.173357
 	StCMD_06* pstStCMD_06;
 	StCMD_07* pstStCMD_07;	//2022.5.4.163918
 	BYTE *pbyTemp;
 	//2020.12.11.110138昆仑通态使用
	//2025.10.28.165757 屏蔽容易混淆的内容
 	//static WORD wInkRoller_Fre							;//递墨辊频率
 	static WORD wAirInletWindDoorValue					;//进风口风门开度值|输入范围(0~100)
 	static WORD wAirExhaustWindDoorValue				;//排风口风门开度值|输入范围(0~100)
 	static WORD wAirReturnWindDoorValue					;//回风口风门开度值|输入范围(0~100)
	//2025.10.28.165757 屏蔽容易混淆的内容
 	//static WORD wTemperature_Set          				;//加热温度设置SV
 	static BYTE bySampleSholdSwitch         			;
 	static	WORD wUpAdjButton_Count     				;//MCGS调整上按钮计数
 	static	WORD wDnAdjButton_Count						;//MCGS调整下按钮计数
 	static	WORD wLeftAdjButton_Count					;//MCGS调整左按钮计数
 	static	WORD wRightAdjButton_Count					;//MCGS调整右按钮计数
 	static	WORD wAlarmButton_Count						;//MCGS报警按钮计数
 	//2022.7.3.114935增加加减速按钮
 	static WORD wAccButton_Count						;
 	static WORD wDecButton_Count						;

 	static	WORD wMCGS_SingleSwitch;//MCGS单向开关
	//2025.10.28.165757 屏蔽容易混淆的内容
 	/*
 	static REAL rHz_AxisInkRoller_ManuallySet_rec		;//	; (* ?REAL|??????????|??:Hz|@2020.11.6.142249 *)
 	static REAL rCoeff_AxisInkRoller_Automatic_rec		;// ; (* ?REAL|?????????|@2020.11.6.142249 *)
 	static REAL rHz_AxisAirBlowning_ManuallySet_rec		;// ; (* ?REAL|???????????|??:Hz|@2020.11.6.142249 *)
 	static REAL rHz_AxisAirExhaust_ManuallySet_rec		;// ; (* ?REAL|???????????|??:Hz|@2020.11.6.142249 *)
 	static WORD wSV_TemCtrl_rec							;//	;(*2021.7.19.162958*)
 	static WORD wSV_TemCtrl_PreHot_rec					;//	;(*2021.7.19.162958*)

 	static BYTE byAxisRoller_UpperFrq_rec				;//	;(*2021.7.19.162958*)
 	static REAL rAxisRoller_Frq_rec						;//	;(*2021.7.19.162958*)
	*/
 	//2022.3.19.170133新增北人
 	static DWORD dwCtlBits_UnitBaseCraft_rec			;//对应StAxisParam.dwCtlBits_UnitBaseCraft
 	static WORD wHz_UnitInkRoller_ManuallySet_rec		;//StAxisParam.rHz_UnitInkRoller_ManuallySet*100
 	static WORD wCoeff_UnitInkRoller_Auto_rec			;//StAxisParam.rCoeff_UnitInkRoller_Auto*100
 	static WORD wHz_UnitScraper_ManuallySet_rec			;//StAxisParam.rHz_UnitScraper_ManuallySet*100
 	static WORD wCoeff_UnitScraper_Auto_rec				;//StAxisParam.rCoeff_UnitScraper_Auto*100
 	static WORD wHz_UnitHotWind_rec						;//StAxisParam.rHz_UnitHotWind*100
 	static WORD wHz_UnitHotWind_2_rec					;//StAxisParam.rHz_UnitHotWind_2*100
 	static WORD wSV_UnitTemCtl_rec						;//StAxisParam.rSV_UnitTemCtl*100

 	//2025.7.24.090114+
	static float rOffset_T1_Rec,rSource_Light_T1_Rec,rBias_T1_Rec,rBrightness_Light_T1_Rec;
	static float rOffset_T2_Rec,rSource_Light_T2_Rec,rBias_T2_Rec,rBrightness_Light_T2_Rec;
	static BYTE bySignalSelect_Rec=0;
	//2025.10.24.084853+
	static BYTE byArcSensorType_Rec=0;

 	//2023.11.08.095424  同步
 	//2023.10.14.101208/wei.n/7吋人机色组IO与ARM通讯
 	static WORD wUnit_output_I_rec						;
 	static WORD wUnit_output_II_rec						;
 	static DINT diArgumentToXW							;
 	static INT iNum_SampleCfg							;
 	BYTE bySampleSholdT1								;
 	BYTE bySampleSholdT2								;
 	INT aiBase_Max[2]									;
 	INT aiBase_Min[2]									;
 	WORD wTemp = 0										;
 	/*
 	StCMD_05_Common_1* pstStCMD_05_Common_1;
 	StCMD_05_Common_2* pstStCMD_05_Common_2;
 	*/
 	//定义变量结束---------------------------------------------------------

 	//代码开始
 	i_pstStSyncWithServerOut->o_xEno= i_xEn;
 	i_pstStSyncWithServerOut->o_iErNo= 0;
 	if(i_xEn)
 	{
 		if(
 			i_pstStAxisParam!=0 &&			//(*参数地址入口有效|*)
 			i_pstStPara_PduBroadcastUp!=0 &&//(*上行命令区域有效|*)
 			i_pstStPara_PduBroadcastDn!=0 &&//(*广播下行命令区域有效|*)
 			i_pxGetAxisId!=0 &&
 			i_pbyLedSwitchTimeouts!=0 &&
 			i_pdwPlateAdjustmentProf!=0&&
 			i_piJourney_HorzRapidAdjust!=0 &&
 			i_pstStSyncWithServerOut!=0 &&
 			i_pstStGlobalParam!=0 &&
 			i_pstStGrpParam!=0)
 		{
 			;
 		}
 		else//参数无效
 		{
 			i_pstStSyncWithServerOut->o_iErNo=-1;
 			return;
 		}

 		if(i_pstStAxisParam->iAxisId>=1 && i_pstStAxisParam->iAxisId<=MAX_STATION_NUM_AOYIN)//轴id有效
 		{
 			;
 		}
 		else
 		{
 			i_pstStSyncWithServerOut->o_iErNo=-2;
 			return;
 		}

		//		dwReCfgFlag= 0; //(*默认不需要重新配置*)
		//2021.9.16.172844处理采样配置标志清除||延迟两个周期
 		if(dwReCfgFlag!=0)
 		{
 			iNum_SampleCfg =iNum_SampleCfg +1;
 			if(iNum_SampleCfg>2)
 			{
 				iNum_SampleCfg= 0;
 				dwReCfgFlag=0;
 			}
 		}
 		else
 		{
 			iNum_SampleCfg=0;
 		}
		//单独处理重新配置采样计数清零-----------------------------------------------多次配置采样确保采样参数配置成功2021.9.16.173324|||||niu.j

 		iStationId=i_iStationId;
 		xReqDispatchAgain= 0;

 		if(i_xGotTheMailboxClock)
 		{
 			pstStPara_MailboxAlternate= (StPara_MailboxAlternate*)&(adwBuf);
			//		(*han.dp|2017-08-03 23:33:10|
			//		.GT_RN_DevicePcMailComRd()参数描述:|
			//		.参数1: 数据返回地址;|
			//		.参数2: 目标站号(目前约定在主站0#站点|
			//		.参数3: 内存起点(<=8192-512)|
			//		.参数4: 4字节的数量(dwordNum)|
			//		.参数5: 操作模式;1写;5读||*)

			//		(*2019.4.2.191518|*)
			//		(*>>begin_mark|*)
 			dwPayloadLen= sizeof(*pstStPara_MailboxAlternate);
 			wDWordNum= (WORD)(dwPayloadLen/sizeof(dwPayloadLen));
 			if ((dwPayloadLen & 0x3)!=0)
 			{
 				wDWordNum= wDWordNum+1;
 			}
 			//	(*<<end_mark|*)
 			//	(*2019.4.2.192752|用变量控制读取数量|*)
 			i_pstStAxisParam->iARMRunNum=13;		//2022.5.21.084823
 			//2024.01.11.124751增加了返回值判断
			//2025.12.1.094650 增加停止mail通讯标志控制
 			int16 iRtn_MailComRd = -1;//默认非法值
			if(!i_pstStGlobalParam->xStopMailComm)
				iRtn_MailComRd=GT_RN_DevicePcMailComRd((unsigned long*)pstStPara_MailboxAlternate, 0, iStationId*gc_iMailboxBlockLen, wDWordNum, 5);
 			if(iRtn_MailComRd==0)
 			{
 				if (pstStPara_MailboxAlternate->dwSyncFlag==gc_dwSemaphoreDownLink)
 				{
 					//(*主站有数据来||*)
 					if (*i_pxGetAxisId)
 					{
 						xGetCopyFromSrvOk= 1;
 					}
 					iCountdownRedispatchReq= 0;

 					//(*纵向版修正量|*)
 					if(i_pstStAxisParam->lrAdjust_V!=pstStPara_MailboxAlternate->lrAdjust_V)
 					{
 						i_pstStAxisParam->lrAdjust_V= pstStPara_MailboxAlternate->lrAdjust_V;
 					}
					lrAdjust_V_Rec= i_pstStAxisParam->lrAdjust_V;
					//(*横向版修正量|*)
					if(i_pstStAxisParam->lrAdjust_H!=pstStPara_MailboxAlternate->lrAdjust_H)
					{
						i_pstStAxisParam->lrAdjust_H= pstStPara_MailboxAlternate->lrAdjust_H;
					}
					lrAdjust_H_Rec= i_pstStAxisParam->lrAdjust_H;

					//(*波门地址1|*)
					if (i_pstStAxisParam->iGateSa!=pstStPara_MailboxAlternate->iGateSa)
					{
						i_pstStAxisParam->iGateSa= pstStPara_MailboxAlternate->iGateSa;
						dwReCfgFlag=dwReCfgFlag|1<<0;
					}
					iGateSa_Rec= i_pstStAxisParam->iGateSa;

					//(*波门地址2|*)
					if(i_pstStAxisParam->iGateSaEx!=pstStPara_MailboxAlternate->iGateSaEx)
					{
						i_pstStAxisParam->iGateSaEx= pstStPara_MailboxAlternate->iGateSaEx;
						dwReCfgFlag=dwReCfgFlag|1<<0;
					}
					iGateSaEx_Rec= i_pstStAxisParam->iGateSaEx;

					//(*纵横向手自动等|*)
					if(i_pstStAxisParam->wStatusRef!=pstStPara_MailboxAlternate->wStatusRef)
					{
						i_pstStAxisParam->wStatusRef= pstStPara_MailboxAlternate->wStatusRef;
					}
					wStatusRef_Rec= i_pstStAxisParam->wStatusRef;
					//(*--------------------------------------------------|2019.4.2.192608_*)
					//(*轴控制位传送|*)
					if(i_pstStAxisParam->dwControlBits!=pstStPara_MailboxAlternate->dwAxisControlBits)
					{
						i_pstStAxisParam->dwControlBits= pstStPara_MailboxAlternate->dwAxisControlBits;
					}
					dwControlBits_Rec= i_pstStAxisParam->dwControlBits;

					//按钮功能2020.12.5.135831
					if(i_pstStAxisParam->wButtonFun!=pstStPara_MailboxAlternate->wButtonFun)
					{
						i_pstStAxisParam->wButtonFun= pstStPara_MailboxAlternate->wButtonFun;
					}
					wButtonFun_Rec= i_pstStAxisParam->wButtonFun;

					//2025.10.28.165757 屏蔽容易混淆的内容
					/*
					//递墨辊频率2020.12.5.135831
					if(i_pstStAxisParam->wInkRoller_Fre!=pstStPara_MailboxAlternate->wInkRoller_Fre)
					{
						i_pstStAxisParam->wInkRoller_Fre=pstStPara_MailboxAlternate->wInkRoller_Fre;
					}
					wInkRoller_Fre= i_pstStAxisParam->wInkRoller_Fre;
					*/
					//进风口风门开度值2020.12.5.135831
					if(i_pstStAxisParam->wAirInletWindDoorValue!=pstStPara_MailboxAlternate->wAirInletWindDoorValue)
					{
						i_pstStAxisParam->wAirInletWindDoorValue=pstStPara_MailboxAlternate->wAirInletWindDoorValue;
					}
					wAirInletWindDoorValue= i_pstStAxisParam->wAirInletWindDoorValue;
					//排风口风门开度值2020.12.5.135831
					if(i_pstStAxisParam->wAirExhaustWindDoorValue!=pstStPara_MailboxAlternate->wAirExhaustWindDoorValue)
					{
						i_pstStAxisParam->wAirExhaustWindDoorValue=pstStPara_MailboxAlternate->wAirExhaustWindDoorValue;
					}
					wAirExhaustWindDoorValue= i_pstStAxisParam->wAirExhaustWindDoorValue;
					//回风口门开度值2020.12.5.135831
					if(i_pstStAxisParam->wAirReturnWindDoorValue!=pstStPara_MailboxAlternate->wAirReturnWindDoorValue)
					{
						i_pstStAxisParam->wAirReturnWindDoorValue=pstStPara_MailboxAlternate->wAirReturnWindDoorValue;
					}
					wAirReturnWindDoorValue= i_pstStAxisParam->wAirReturnWindDoorValue;
					//2025.10.28.165757 屏蔽容易混淆的内容
					/*
					//加热温度设置2020.12.5.135831
					if(i_pstStAxisParam->wTemperature_Set!=pstStPara_MailboxAlternate->wTemperature_Set)
					{
						i_pstStAxisParam->wTemperature_Set=pstStPara_MailboxAlternate->wTemperature_Set;
					}
					wTemperature_Set= i_pstStAxisParam->wTemperature_Set;
					*/
					//从站阀值选择2020.12.14.142742
					if(i_pstStAxisParam->bySampleSholdSwitch!=pstStPara_MailboxAlternate->bySampleSholdSwitch)
					{
						i_pstStAxisParam->bySampleSholdSwitch=pstStPara_MailboxAlternate->bySampleSholdSwitch;
					}
					bySampleSholdSwitch= i_pstStAxisParam->bySampleSholdSwitch;
					//调整上选择2020.12.17.173602
					if(i_pstStAxisParam->wUpAdjButton_Count!=pstStPara_MailboxAlternate->wUpAdjButton_Count)
					{
						i_pstStAxisParam->wUpAdjButton_Count=pstStPara_MailboxAlternate->wUpAdjButton_Count;
					}
					wUpAdjButton_Count= i_pstStAxisParam->wUpAdjButton_Count;
					//调整下选择2020.12.17.173602
					if(i_pstStAxisParam->wDnAdjButton_Count!=pstStPara_MailboxAlternate->wDnAdjButton_Count)
					{
						i_pstStAxisParam->wDnAdjButton_Count=pstStPara_MailboxAlternate->wDnAdjButton_Count;
					}
					wDnAdjButton_Count= i_pstStAxisParam->wDnAdjButton_Count;
					//调整左选择2020.12.17.173602
					if(i_pstStAxisParam->wLeftAdjButton_Count!=pstStPara_MailboxAlternate->wLeftAdjButton_Count)
					{
						i_pstStAxisParam->wLeftAdjButton_Count=pstStPara_MailboxAlternate->wLeftAdjButton_Count;
					}
					wLeftAdjButton_Count= i_pstStAxisParam->wLeftAdjButton_Count;
					//调整右选择2020.12.17.173602
					if(i_pstStAxisParam->wRightAdjButton_Count!=pstStPara_MailboxAlternate->wRightAdjButton_Count)
					{
						i_pstStAxisParam->wRightAdjButton_Count=pstStPara_MailboxAlternate->wRightAdjButton_Count;
					}
					wRightAdjButton_Count= i_pstStAxisParam->wRightAdjButton_Count;
					//报警铃
					if(i_pstStAxisParam->wAlarmButton_Count!=pstStPara_MailboxAlternate->wAlarmButton_Count)
					{
						i_pstStAxisParam->wAlarmButton_Count=pstStPara_MailboxAlternate->wAlarmButton_Count;
					}
					wAlarmButton_Count= i_pstStAxisParam->wAlarmButton_Count;
					//单向按钮
					if(i_pstStAxisParam->wMCGS_SingleSwitch!=pstStPara_MailboxAlternate->wMCGS_SingleSwitch)
					{
						i_pstStAxisParam->wMCGS_SingleSwitch=pstStPara_MailboxAlternate->wMCGS_SingleSwitch;
					}
					wMCGS_SingleSwitch= i_pstStAxisParam->wMCGS_SingleSwitch;

					//2025.10.28.165322 屏蔽容易混淆的内容
					/*
					//2021.10.27.093803新增奥特马兼容
 					//递墨辊手动频率
					if(i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet!=pstStPara_MailboxAlternate->rHz_AxisInkRoller_ManuallySet)
					{
						i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet=pstStPara_MailboxAlternate->rHz_AxisInkRoller_ManuallySet;
					}
					rHz_AxisInkRoller_ManuallySet_rec= i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet;
					//递墨辊自动系数
					if(i_pstStAxisParam->rCoeff_AxisInkRoller_Automatic!=pstStPara_MailboxAlternate->rCoeff_AxisInkRoller_Automatic)
					{
						i_pstStAxisParam->rCoeff_AxisInkRoller_Automatic=pstStPara_MailboxAlternate->rCoeff_AxisInkRoller_Automatic;
					}
					rCoeff_AxisInkRoller_Automatic_rec= i_pstStAxisParam->rCoeff_AxisInkRoller_Automatic;

					//送风手动频率
					if(i_pstStAxisParam->rHz_AxisAirBlowning_ManuallySet!=pstStPara_MailboxAlternate->rHz_AxisAirBlowning_ManuallySet)
					{
						i_pstStAxisParam->rHz_AxisAirBlowning_ManuallySet=pstStPara_MailboxAlternate->rHz_AxisAirBlowning_ManuallySet;
					}
					rHz_AxisAirBlowning_ManuallySet_rec= i_pstStAxisParam->rHz_AxisAirBlowning_ManuallySet;
					//排风手动频率
					if(i_pstStAxisParam->rHz_AxisAirExhaust_ManuallySet!=pstStPara_MailboxAlternate->rHz_AxisAirExhaust_ManuallySet)
					{
						i_pstStAxisParam->rHz_AxisAirExhaust_ManuallySet=pstStPara_MailboxAlternate->rHz_AxisAirExhaust_ManuallySet;
					}
					rHz_AxisAirExhaust_ManuallySet_rec= i_pstStAxisParam->rHz_AxisAirExhaust_ManuallySet;
					//温度设定值
					if(i_pstStAxisParam->wSV_TemCtrl!=pstStPara_MailboxAlternate->wSV_TemCtrl)
					{
						i_pstStAxisParam->wSV_TemCtrl=pstStPara_MailboxAlternate->wSV_TemCtrl;
					}
					wSV_TemCtrl_rec= i_pstStAxisParam->wSV_TemCtrl;
					//预热温度设定值
					if(i_pstStAxisParam->wSV_TemCtrl_PreHot!=pstStPara_MailboxAlternate->wSV_TemCtrl_PreHot)
					{
						i_pstStAxisParam->wSV_TemCtrl_PreHot=pstStPara_MailboxAlternate->wSV_TemCtrl_PreHot;
					}
					wSV_TemCtrl_PreHot_rec= i_pstStAxisParam->wSV_TemCtrl_PreHot;
					//递墨辊上限频率
					if(i_pstStAxisParam->byAxisRoller_UpperFrq!=pstStPara_MailboxAlternate->byAxisRoller_UpperFrq)
					{
						i_pstStAxisParam->byAxisRoller_UpperFrq=pstStPara_MailboxAlternate->byAxisRoller_UpperFrq;
					}
					byAxisRoller_UpperFrq_rec= i_pstStAxisParam->byAxisRoller_UpperFrq;
					//递墨辊频率
					if(i_pstStAxisParam->rAxisRoller_Frq!=pstStPara_MailboxAlternate->rAxisRoller_Frq)
					{
						i_pstStAxisParam->rAxisRoller_Frq=pstStPara_MailboxAlternate->rAxisRoller_Frq;
					}
					rAxisRoller_Frq_rec= i_pstStAxisParam->rAxisRoller_Frq;
					*/
					//2022.3.19.170227新增北人相关变量
					//1
					if(i_pstStAxisParam->dwCtlBits_UnitBaseCraft!=pstStPara_MailboxAlternate->dwCtlBits_UnitBaseCraft)
					{
						i_pstStAxisParam->dwCtlBits_UnitBaseCraft=pstStPara_MailboxAlternate->dwCtlBits_UnitBaseCraft;
					}
					dwCtlBits_UnitBaseCraft_rec= i_pstStAxisParam->dwCtlBits_UnitBaseCraft;
					//2
					if(i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet!=pstStPara_MailboxAlternate->wHz_UnitInkRoller_ManuallySet)
					{
						i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet=pstStPara_MailboxAlternate->wHz_UnitInkRoller_ManuallySet;
					}
					wHz_UnitInkRoller_ManuallySet_rec= i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet;
					//3
					if(i_pstStAxisParam->wCoeff_UnitInkRoller_Auto!=pstStPara_MailboxAlternate->wCoeff_UnitInkRoller_Auto)
					{
						i_pstStAxisParam->wCoeff_UnitInkRoller_Auto=pstStPara_MailboxAlternate->wCoeff_UnitInkRoller_Auto;
					}
					wCoeff_UnitInkRoller_Auto_rec= i_pstStAxisParam->wCoeff_UnitInkRoller_Auto;
					//4
					if(i_pstStAxisParam->wHz_UnitScraper_ManuallySet!=pstStPara_MailboxAlternate->wHz_UnitScraper_ManuallySet)
					{
						i_pstStAxisParam->wHz_UnitScraper_ManuallySet=pstStPara_MailboxAlternate->wHz_UnitScraper_ManuallySet;
					}
					wHz_UnitScraper_ManuallySet_rec= i_pstStAxisParam->wHz_UnitScraper_ManuallySet;
					//5
					if(i_pstStAxisParam->wCoeff_UnitScraper_Auto!=pstStPara_MailboxAlternate->wCoeff_UnitScraper_Auto)
					{
						i_pstStAxisParam->wCoeff_UnitScraper_Auto=pstStPara_MailboxAlternate->wCoeff_UnitScraper_Auto;
					}
					wCoeff_UnitScraper_Auto_rec= i_pstStAxisParam->wCoeff_UnitScraper_Auto;
					//6
					if(i_pstStAxisParam->wHz_UnitHotWind!=pstStPara_MailboxAlternate->wHz_UnitHotWind)
					{
						i_pstStAxisParam->wHz_UnitHotWind=pstStPara_MailboxAlternate->wHz_UnitHotWind;
					}
					wHz_UnitHotWind_rec= i_pstStAxisParam->wHz_UnitHotWind;
					//7
					if(i_pstStAxisParam->wHz_UnitHotWind_2!=pstStPara_MailboxAlternate->wHz_UnitHotWind_2)
					{
						i_pstStAxisParam->wHz_UnitHotWind_2=pstStPara_MailboxAlternate->wHz_UnitHotWind_2;
					}
					wHz_UnitHotWind_2_rec= i_pstStAxisParam->wHz_UnitHotWind_2;
					//8
					if(i_pstStAxisParam->wSV_UnitTemCtl!=pstStPara_MailboxAlternate->wSV_UnitTemCtl)
					{
						i_pstStAxisParam->wSV_UnitTemCtl=pstStPara_MailboxAlternate->wSV_UnitTemCtl;
					}
					wSV_UnitTemCtl_rec= i_pstStAxisParam->wSV_UnitTemCtl;
					//2023.11.08.095454 同步
					// 2023.10.14.101445/wei.n/7吋人机色组IO与ARM通讯
					if(i_pstStAxisParam->wUnit_output_I != pstStPara_MailboxAlternate->wUnit_output_I )
					{
						i_pstStAxisParam->wUnit_output_I = pstStPara_MailboxAlternate->wUnit_output_I;
					}
					wUnit_output_I_rec = i_pstStAxisParam->wUnit_output_I;
					if(i_pstStAxisParam->wUnit_output_II != pstStPara_MailboxAlternate->wUnit_output_II)
					{
						i_pstStAxisParam->wUnit_output_II = pstStPara_MailboxAlternate->wUnit_output_II;
					}
					wUnit_output_II_rec = i_pstStAxisParam->wUnit_output_II;
					//2022.7.3.115012增加加减速按钮
					if(i_pstStAxisParam->wAccButton_Count!=pstStPara_MailboxAlternate->wAccButton_Count)
					{
						i_pstStAxisParam->wAccButton_Count=pstStPara_MailboxAlternate->wAccButton_Count;
					}
					wAccButton_Count= i_pstStAxisParam->wAccButton_Count;
					if(i_pstStAxisParam->wDecButton_Count!=pstStPara_MailboxAlternate->wDecButton_Count)
					{
						i_pstStAxisParam->wDecButton_Count=pstStPara_MailboxAlternate->wDecButton_Count;
					}
					wDecButton_Count= i_pstStAxisParam->wDecButton_Count;

					//mailbox的数据变化了|就更新本地的数据@2025.7.23.205433
					if(pstStPara_MailboxAlternate->uiOffset_T1 != (uint16_t)(i_pstStGlobalParam->rOffset_T1*1000) ||
						pstStPara_MailboxAlternate->uiSource_Light_T1 != (uint16_t)(i_pstStGlobalParam->rSource_Light_T1*1000)||
						pstStPara_MailboxAlternate->uiBias_T1 != (uint16_t)(i_pstStGlobalParam->rBias_T1*1000)||
						pstStPara_MailboxAlternate->uiBrightness_Light_T1 != (uint16_t)(i_pstStGlobalParam->rBrightness_Light_T1*1000)||
						pstStPara_MailboxAlternate->uiOffset_T2 != (uint16_t)(i_pstStGlobalParam->rOffset_T2*1000)||
						pstStPara_MailboxAlternate->uiSource_Light_T2 != (uint16_t)(i_pstStGlobalParam->rSource_Light_T2*1000)||
						pstStPara_MailboxAlternate->uiBias_T2 != (uint16_t)(i_pstStGlobalParam->rBias_T2*1000)||
						pstStPara_MailboxAlternate->uiBrightness_Light_T2 != (uint16_t)(i_pstStGlobalParam->rBrightness_Light_T2*1000))
					{
						//2025.7.23.203708增加光纤通讯的参数处理
						//t1
						i_pstStGlobalParam->rOffset_T1 				= (float)pstStPara_MailboxAlternate->uiOffset_T1 / 1000	;
						i_pstStGlobalParam->rSource_Light_T1		= (float)pstStPara_MailboxAlternate->uiSource_Light_T1  / 1000	;
						i_pstStGlobalParam->rBias_T1				= (float)pstStPara_MailboxAlternate->uiBias_T1 	 / 1000		;
						i_pstStGlobalParam->rBrightness_Light_T1	= (float)pstStPara_MailboxAlternate->uiBrightness_Light_T1 / 1000 ;
						//t2
						i_pstStGlobalParam->rOffset_T2				= (float)pstStPara_MailboxAlternate->uiOffset_T2	 / 1000		;
						i_pstStGlobalParam->rSource_Light_T2		= (float)pstStPara_MailboxAlternate->uiSource_Light_T2  / 1000	;
						i_pstStGlobalParam->rBias_T2				= (float)pstStPara_MailboxAlternate->uiBias_T2 	 / 1000	;
						i_pstStGlobalParam->rBrightness_Light_T2	= (float)pstStPara_MailboxAlternate->uiBrightness_Light_T2  / 1000;

					}
					rOffset_T1_Rec = i_pstStGlobalParam->rOffset_T1;
					rSource_Light_T1_Rec = i_pstStGlobalParam->rSource_Light_T1;
					rBias_T1_Rec = i_pstStGlobalParam->rBias_T1;
					rBrightness_Light_T1_Rec = i_pstStGlobalParam->rBrightness_Light_T1;
					rOffset_T2_Rec = i_pstStGlobalParam->rOffset_T2;
					rSource_Light_T2_Rec = i_pstStGlobalParam->rSource_Light_T2;
					rBias_T2_Rec = i_pstStGlobalParam->rBias_T2;
					rBrightness_Light_T2_Rec = i_pstStGlobalParam->rBrightness_Light_T2;


					if(i_pstStGlobalParam->bySignalSelect!=pstStPara_MailboxAlternate->bySignalSelect)
					{
						i_pstStGlobalParam->bySignalSelect=pstStPara_MailboxAlternate->bySignalSelect;
					}
					bySignalSelect_Rec= i_pstStGlobalParam->bySignalSelect;

					//2025.10.24.085029+
					if(i_pstStGlobalParam->byArcSensorType!=pstStPara_MailboxAlternate->byArcSensorType)
					{
						i_pstStGlobalParam->byArcSensorType=pstStPara_MailboxAlternate->byArcSensorType;
					}
					byArcSensorType_Rec= i_pstStGlobalParam->byArcSensorType;
					//(*--------------------------------------------------|2019.8.28.111442_*)
					//(*如果有数据下来|就把横向快速对版量清除掉|*)
					//(*i_piJourney_HorzRapidAdjust^:= 0;*)

					//(*--------------------------------------------------|2017.8.3.234123_*)
					//(*清除旗语|*)
					adwBuf[0]= 0;
					adwBuf[1]= 0;

					//2025.12.1.094650 增加停止mail通讯标志控制
					if(!i_pstStGlobalParam->xStopMailComm)
						GT_RN_DevicePcMailComWr((unsigned long*)&adwBuf[0], 0, iStationId*gc_iMailboxBlockLen, 2, 1, 1);

					//2020.6.8.202844||mailbox下行通讯完成
					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 0);
					i_pstStAxisParam->iARMRunNum=14;		//2022.5.21.084823

 				}
 				else if(pstStPara_MailboxAlternate->dwSyncFlag==gc_dwSemaphoreRequestDispatch)
 				{
 					iCountdownRedispatchReq= 0;//(*请求主站重新派发1次本站点的参数*)

 				}
 				else
 				{
 					//(*包含了上行在内|*)
 					//(*检查是否需要上报|如果有数据改变 之前的上行数据就可以覆盖掉了|*)
 					if(xGetCopyFromSrvOk && *i_pxGetAxisId)//(*如果已经从服务器获取到了数据则可以检查和本地的变化了|*)
 					{
						i_pstStAxisParam->iARMRunNum=15;		//2022.5.21.084823

 						iCountdownRedispatchReq= 0;//(*计数周期|*)
 						dwParaUpdateFlag= 0;//(*每位用来表示1项参数内容的改变状态|*)
 						dwParaUpdateFlag_1= 0;//2022.3.19.170804新增变量判断
 						dwPlateAdjustmentProf= 0;//(*纵向快速对版量|*)
 						iJourney_HorzRapidAdjust_Tmp= 0;//(*横向快速对版量|*)

 						//(*手自动状态等|*)
 						if(wStatusRef_Rec!=i_pstStAxisParam->wStatusRef)
 						{
 							dwParaUpdateFlag|= 1<<0;
 						}

 						//(*纵向修正量|*)
 						if(lrAdjust_V_Rec!=i_pstStAxisParam->lrAdjust_V)
 						{
 							dwParaUpdateFlag|= 1<<2;
 						}

 						//(*横向修正量|*)
 						if(lrAdjust_H_Rec!=i_pstStAxisParam->lrAdjust_H)
 						{
 							dwParaUpdateFlag|=1<<4;
 						}

 						//(*波门1地址|*)
 						if(iGateSa_Rec!=i_pstStAxisParam->iGateSa)
 						{
 							dwParaUpdateFlag|=1<<5;
 							dwReCfgFlag|=1<<0;
 						}

 						//(*波门2地址|*)
 						if(iGateSaEx_Rec!=i_pstStAxisParam->iGateSaEx)
 						{
 							dwParaUpdateFlag|=1<<6;
 							dwReCfgFlag|=1<<0;
 						}
 	//(**)
 	//					//(*纵向快速对版|*)
 	//					if(i_pstStShmGlobalParam^.adwExtendedDWORD[2]<>0 THEN(*请求动版|*)
 	//						dwParaUpdateFlag.7:= TRUE;
 	//						dwPlateAdjustmentProf:= i_pstStShmGlobalParam^.adwExtendedDWORD[2];
 	//						i_pstStShmGlobalParam^.adwExtendedDWORD[2]:= 0;
 	//					END_IF

 						//(*--------------------------------------------------|2019.4.2.192442_*)
 						//(*轴控制位|*)
 						if(dwControlBits_Rec!= i_pstStAxisParam->dwControlBits)
 						{
 							dwParaUpdateFlag|=1<<8;
 						}

 						//(*--------------------------------------------------|2019.8.28.110122_*)
 						//(*横向快速对版|*)
 						if(i_piJourney_HorzRapidAdjust!=0)
 						{
 							if(*i_piJourney_HorzRapidAdjust!=0)
 							{
 								dwParaUpdateFlag|=1<<9;
 								iJourney_HorzRapidAdjust_Tmp= *i_piJourney_HorzRapidAdjust;
 								*i_piJourney_HorzRapidAdjust= 0;
 							}
 						}
 						//（纵向快速对版）
 						if(i_pdwPlateAdjustmentProf!=0)
 						{
 							if(*i_pdwPlateAdjustmentProf!=0)
 							{
 								dwParaUpdateFlag|=1<<7;
 								dwPlateAdjustmentProf=((*i_pdwPlateAdjustmentProf)<<8)|((DWORD)(i_pstStAxisParam->iAxisId));
 								*i_pdwPlateAdjustmentProf=0;
 							}
 						}

 						if(wButtonFun_Rec!= i_pstStAxisParam->wButtonFun)
 						{
 							dwParaUpdateFlag|=1<<11;
 						}

 						//2025.10.28.165757 屏蔽容易混淆的内容
 						/*
 						if(wInkRoller_Fre!=i_pstStAxisParam->wInkRoller_Fre)
 						{
 							dwParaUpdateFlag|=1<<12;
 						}
 						*/
 						if(wAirInletWindDoorValue!=i_pstStAxisParam->wAirInletWindDoorValue)
 						{
 							dwParaUpdateFlag|=1<<13;
 						}
 						if(wAirExhaustWindDoorValue!=i_pstStAxisParam->wAirExhaustWindDoorValue)
 						{
 							dwParaUpdateFlag|=1<<14;
 						}
 						if(wAirReturnWindDoorValue!=i_pstStAxisParam->wAirReturnWindDoorValue)
 						{
 							dwParaUpdateFlag|=1<<15;
 						}
 						//2025.10.28.165757 屏蔽容易混淆的内容
 						/*
 						if(wTemperature_Set!=i_pstStAxisParam->wTemperature_Set)
 						{
 							dwParaUpdateFlag|=1<<16;
 						}
 						*/
 						if(bySampleSholdSwitch!=i_pstStAxisParam->bySampleSholdSwitch)
 						{
 							dwParaUpdateFlag|=1<<17;
 						}
 						if(wUpAdjButton_Count!=i_pstStAxisParam->wUpAdjButton_Count)
 						{
 							dwParaUpdateFlag|=1<<18;
 						}
 						if(wDnAdjButton_Count!=i_pstStAxisParam->wDnAdjButton_Count)
 						{
 							dwParaUpdateFlag|=1<<19;
 						}
 						if(wLeftAdjButton_Count!=i_pstStAxisParam->wLeftAdjButton_Count)
 						{
 							dwParaUpdateFlag|=1<<20;
 						}
 						if(wRightAdjButton_Count!=i_pstStAxisParam->wRightAdjButton_Count)
 						{
 							dwParaUpdateFlag|=1<<21;
 						}
 						if(wAlarmButton_Count!=i_pstStAxisParam->wAlarmButton_Count)
 						{
 							dwParaUpdateFlag|=1<<22;
 						}
 						if(wMCGS_SingleSwitch!=i_pstStAxisParam->wMCGS_SingleSwitch)
 						{
 							dwParaUpdateFlag|=1<<23;
 						}

 						//2025.10.28.165757 屏蔽容易混淆的内容
 						/*
 						//2021.10.27.102208||新增奥特马兼容
 						if(rHz_AxisInkRoller_ManuallySet_rec!=i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet)
 						{
 							dwParaUpdateFlag|=1<<24;
 						}
 						if(rCoeff_AxisInkRoller_Automatic_rec!=i_pstStAxisParam->rCoeff_AxisInkRoller_Automatic)
 						{
 							dwParaUpdateFlag|=1<<25;
 						}
 						if(rHz_AxisAirBlowning_ManuallySet_rec!=i_pstStAxisParam->rHz_AxisAirBlowning_ManuallySet)
 						{
 							dwParaUpdateFlag|=1<<26;
 						}
 						if(rHz_AxisAirExhaust_ManuallySet_rec!=i_pstStAxisParam->rHz_AxisAirExhaust_ManuallySet)
 						{
 							dwParaUpdateFlag|=1<<27;
 						}
 						if(wSV_TemCtrl_rec!=i_pstStAxisParam->wSV_TemCtrl)
 						{
 							dwParaUpdateFlag|=1<<28;
 						}
 						if(wSV_TemCtrl_PreHot_rec!=i_pstStAxisParam->wSV_TemCtrl_PreHot)
 						{
 							dwParaUpdateFlag|=1<<29;
 						}
 						if(byAxisRoller_UpperFrq_rec!=i_pstStAxisParam->byAxisRoller_UpperFrq)
 						{
 							dwParaUpdateFlag|=1<<30;
 						}//2022.7.15.170554||左移31位已超限
 						if(rAxisRoller_Frq_rec!=i_pstStAxisParam->rAxisRoller_Frq)
 						{
 							dwParaUpdateFlag_1|=1<<11;
 						}
 						*/
 						//s2022.3.19.170826
 						//1
 						if(dwCtlBits_UnitBaseCraft_rec!=i_pstStAxisParam->dwCtlBits_UnitBaseCraft)
 						{
 							dwParaUpdateFlag_1|=1<<1;
 						}
 						//2
 						if(wHz_UnitInkRoller_ManuallySet_rec!=i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet)
 						{
 							dwParaUpdateFlag_1|=1<<2;
 						}
 						//3
 						if(wCoeff_UnitInkRoller_Auto_rec!=i_pstStAxisParam->wCoeff_UnitInkRoller_Auto)
 						{
 							dwParaUpdateFlag_1|=1<<3;
 						}
 						//4
 						if(wHz_UnitScraper_ManuallySet_rec!=i_pstStAxisParam->wHz_UnitScraper_ManuallySet)
 						{
 							dwParaUpdateFlag_1|=1<<4;
 						}
 						//5
 						if(wCoeff_UnitScraper_Auto_rec!=i_pstStAxisParam->wCoeff_UnitScraper_Auto)
 						{
 							dwParaUpdateFlag_1|=1<<5;
 						}
 						//6
 						if(wHz_UnitHotWind_rec!=i_pstStAxisParam->wHz_UnitHotWind)
 						{
 							dwParaUpdateFlag_1|=1<<6;
 						}
 						//7
 						if(wHz_UnitHotWind_2_rec!=i_pstStAxisParam->wHz_UnitHotWind_2)
 						{
 							dwParaUpdateFlag_1|=1<<7;
 						}
 						//8
 						if(wSV_UnitTemCtl_rec!=i_pstStAxisParam->wSV_UnitTemCtl)
 						{
 							dwParaUpdateFlag_1|=1<<8;
 						}
 						if(wAccButton_Count!=i_pstStAxisParam->wAccButton_Count)
 						{
 							dwParaUpdateFlag_1|=1<<9;
 						}
 						if(wDecButton_Count!=i_pstStAxisParam->wDecButton_Count)
 						{
 							dwParaUpdateFlag_1|=1<<10;
 						}
 						//11被占用2022.7.15.170635

 						//2023.11.08.095658 同步
 						//2023.10.14.103952/wei.n/7吋人机色组IO与ARM通讯
 						//12
 						if(wUnit_output_I_rec != i_pstStAxisParam->wUnit_output_I)
 						{
 							dwParaUpdateFlag_1 |=1<<12;
 						}
 						//13
 						if(wUnit_output_II_rec != i_pstStAxisParam->wUnit_output_II)
 						{
 							dwParaUpdateFlag_1 |=1<<13;
 						}

 						//2025.7.23.204807 增加mailbox中光纤参数的检查
 						if(rOffset_T1_Rec != i_pstStGlobalParam->rOffset_T1 ||
							rSource_Light_T1_Rec != i_pstStGlobalParam->rSource_Light_T1||
							rBias_T1_Rec != i_pstStGlobalParam->rBias_T1||
							rBrightness_Light_T1_Rec != i_pstStGlobalParam->rBrightness_Light_T1||
							rOffset_T2_Rec != i_pstStGlobalParam->rOffset_T2||
							rSource_Light_T2_Rec != i_pstStGlobalParam->rSource_Light_T2||
							rBias_T2_Rec != i_pstStGlobalParam->rBias_T2||
							rBrightness_Light_T2_Rec != i_pstStGlobalParam->rBrightness_Light_T2)
 							dwParaUpdateFlag_1 |=1<<14;

 						if(bySignalSelect_Rec != i_pstStGlobalParam->bySignalSelect)
 							dwParaUpdateFlag_1 |=1<<15;

 						//2025.10.24.085106+
 						if(byArcSensorType_Rec != i_pstStGlobalParam->byArcSensorType)
 							dwParaUpdateFlag_1 |=1<<16;

 						if((dwParaUpdateFlag!=0) || (dwParaUpdateFlag_1!=0))
 							//(*--------------------------------------------------|2019.4.2.191314_*)
 						{
 							for(iN=0;iN<gc_iMailboxBlockLen;iN++)
 							{
 								abyBuf[iN]=0;
 							}
 	//						memset(&abyBuf[0], 0, sizeof(abyBuf));memset是否支持
 							pstStPara_MailboxAlternate= (StPara_MailboxAlternate*)(&abyBuf[0]);

 							pstStPara_MailboxAlternate->dwSyncFlag= gc_dwSemaphoreUpLink;
 							pstStPara_MailboxAlternate->dwPlateAdjustmentProf= dwPlateAdjustmentProf;

 							pstStPara_MailboxAlternate->lrAdjust_V= i_pstStAxisParam->lrAdjust_V;
 							pstStPara_MailboxAlternate->lrAdjust_H= i_pstStAxisParam->lrAdjust_H;
 							pstStPara_MailboxAlternate->iGateSa= i_pstStAxisParam->iGateSa;
 							pstStPara_MailboxAlternate->iGateSaEx= i_pstStAxisParam->iGateSaEx;
 							pstStPara_MailboxAlternate->wStatusRef= i_pstStAxisParam->wStatusRef;
 							pstStPara_MailboxAlternate->wArmResetCount = *i_pwArmResetCount;
 							//(*--------------------------------------------------|2019.4.2.191001_*)
 							//(*轴控制位|*)
 							pstStPara_MailboxAlternate->dwAxisControlBits= i_pstStAxisParam->dwControlBits;

 							//(*--------------------------------------------------|2019.8.28.110349_*)
 							//(*横向快速对版|*)
 							pstStPara_MailboxAlternate->iJourney_HorzRapidAdjust= iJourney_HorzRapidAdjust_Tmp;
 							//2020.12.5.135942按钮功能
 							pstStPara_MailboxAlternate->wButtonFun= i_pstStAxisParam->wButtonFun;
 	//2020.12.11.163553
 							//2025.10.28.165757 屏蔽容易混淆的内容
 							//pstStPara_MailboxAlternate->wInkRoller_Fre = i_pstStAxisParam->wInkRoller_Fre;
 							pstStPara_MailboxAlternate->wAirInletWindDoorValue = i_pstStAxisParam->wAirInletWindDoorValue;
 							pstStPara_MailboxAlternate->wAirExhaustWindDoorValue = i_pstStAxisParam->wAirExhaustWindDoorValue;
 							pstStPara_MailboxAlternate->wAirReturnWindDoorValue = i_pstStAxisParam->wAirReturnWindDoorValue;
 							//2025.10.28.165757 屏蔽容易混淆的内容
 							//pstStPara_MailboxAlternate->wTemperature_Set = i_pstStAxisParam->wTemperature_Set;
 							pstStPara_MailboxAlternate->bySampleSholdSwitch=i_pstStAxisParam->bySampleSholdSwitch;
 							pstStPara_MailboxAlternate->wUpAdjButton_Count=i_pstStAxisParam->wUpAdjButton_Count;
 							pstStPara_MailboxAlternate->wDnAdjButton_Count=i_pstStAxisParam->wDnAdjButton_Count;
 							pstStPara_MailboxAlternate->wLeftAdjButton_Count=i_pstStAxisParam->wLeftAdjButton_Count;
 							pstStPara_MailboxAlternate->wRightAdjButton_Count=i_pstStAxisParam->wRightAdjButton_Count;
 							pstStPara_MailboxAlternate->wAlarmButton_Count=i_pstStAxisParam->wAlarmButton_Count;
 							pstStPara_MailboxAlternate->wMCGS_SingleSwitch=i_pstStAxisParam->wMCGS_SingleSwitch;

 							//2025.10.28.165757 屏蔽容易混淆的内容
 //2021.10.27.102535||新增兼容奥特马
 							/*
 							pstStPara_MailboxAlternate->rHz_AxisInkRoller_ManuallySet=i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet;
 							pstStPara_MailboxAlternate->rCoeff_AxisInkRoller_Automatic=i_pstStAxisParam->rCoeff_AxisInkRoller_Automatic;
 							pstStPara_MailboxAlternate->rHz_AxisAirBlowning_ManuallySet=i_pstStAxisParam->rHz_AxisAirBlowning_ManuallySet;
 							pstStPara_MailboxAlternate->rHz_AxisAirExhaust_ManuallySet=i_pstStAxisParam->rHz_AxisAirExhaust_ManuallySet;
 							pstStPara_MailboxAlternate->wSV_TemCtrl=i_pstStAxisParam->wSV_TemCtrl;
 							pstStPara_MailboxAlternate->wSV_TemCtrl_PreHot=i_pstStAxisParam->wSV_TemCtrl_PreHot;
 							pstStPara_MailboxAlternate->byAxisRoller_UpperFrq=i_pstStAxisParam->byAxisRoller_UpperFrq;
 							pstStPara_MailboxAlternate->rAxisRoller_Frq=i_pstStAxisParam->rAxisRoller_Frq;
 							*/
 //2022.3.19.171115||新增北人
 							pstStPara_MailboxAlternate->dwCtlBits_UnitBaseCraft=i_pstStAxisParam->dwCtlBits_UnitBaseCraft;
 							pstStPara_MailboxAlternate->wHz_UnitInkRoller_ManuallySet=i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet;
 							pstStPara_MailboxAlternate->wCoeff_UnitInkRoller_Auto=i_pstStAxisParam->wCoeff_UnitInkRoller_Auto;
 							pstStPara_MailboxAlternate->wHz_UnitScraper_ManuallySet=i_pstStAxisParam->wHz_UnitScraper_ManuallySet;
 							pstStPara_MailboxAlternate->wCoeff_UnitScraper_Auto=i_pstStAxisParam->wCoeff_UnitScraper_Auto;
 							pstStPara_MailboxAlternate->wHz_UnitHotWind=i_pstStAxisParam->wHz_UnitHotWind;
 							pstStPara_MailboxAlternate->wHz_UnitHotWind_2=i_pstStAxisParam->wHz_UnitHotWind_2;
 							pstStPara_MailboxAlternate->wSV_UnitTemCtl=i_pstStAxisParam->wSV_UnitTemCtl;
 //2022.7.3.115223新增加减速按钮
 							pstStPara_MailboxAlternate->wAccButton_Count=i_pstStAxisParam->wAccButton_Count;
 							pstStPara_MailboxAlternate->wDecButton_Count=i_pstStAxisParam->wDecButton_Count;
 							//2023.11.08.095729 同步
 							//2023.10.14.104313/wei.n/7吋人机色组IO与ARM通讯
 							pstStPara_MailboxAlternate->wUnit_output_I = i_pstStAxisParam->wUnit_output_I;
 							pstStPara_MailboxAlternate->wUnit_output_II = i_pstStAxisParam->wUnit_output_II;

 							//2025.7.23.203708增加光纤通讯的参数处理
 							//t1
							pstStPara_MailboxAlternate->uiOffset_T1 = (uint16_t)(i_pstStGlobalParam->rOffset_T1 * 1000);
							pstStPara_MailboxAlternate->uiSource_Light_T1 = (uint16_t)(i_pstStGlobalParam->rSource_Light_T1 * 1000);
							pstStPara_MailboxAlternate->uiBias_T1 = (uint16_t)(i_pstStGlobalParam->rBias_T1 * 1000);
							pstStPara_MailboxAlternate->uiBrightness_Light_T1 = (uint16_t)(i_pstStGlobalParam->rBrightness_Light_T1 * 1000);
							//t2
							pstStPara_MailboxAlternate->uiOffset_T2 = (uint16_t)(i_pstStGlobalParam->rOffset_T2 * 1000);
							pstStPara_MailboxAlternate->uiSource_Light_T2 = (uint16_t)(i_pstStGlobalParam->rSource_Light_T2 * 1000);
							pstStPara_MailboxAlternate->uiBias_T2 = (uint16_t)(i_pstStGlobalParam->rBias_T2 * 1000);
							pstStPara_MailboxAlternate->uiBrightness_Light_T2 = (uint16_t)(i_pstStGlobalParam->rBrightness_Light_T2 * 1000);
							pstStPara_MailboxAlternate->bySignalSelect = i_pstStGlobalParam->bySignalSelect;
							//2025.10.24.085130+
							pstStPara_MailboxAlternate->byArcSensorType = i_pstStGlobalParam->byArcSensorType;

 							//(*--------------------------------------------------|2019.4.2.191518_*)
 							//(*计算报文中的DWORD数量|*)
 							dwPayloadLen= sizeof(*pstStPara_MailboxAlternate);
 							wDWordNum= (WORD)(dwPayloadLen/sizeof(dwPayloadLen));
 							if((dwPayloadLen % sizeof(dwPayloadLen))!=0)
 							{
 								wDWordNum= wDWordNum+1;
 							}

 							//(*--------------------------------------------------|2019.8.28.110536_*)
 							//(*GT指令开始发送|*)
 							//2025.12.1.094650 增加停止mail通讯标志控制
 							if(!i_pstStGlobalParam->xStopMailComm)
 								aiRtnCode[0]= GT_RN_DevicePcMailComWr((unsigned long*)&(abyBuf[0]), 0, iStationId*gc_iMailboxBlockLen, wDWordNum, 1, 1);
 							if(aiRtnCode[0]==0)
 							{
 								lrAdjust_V_Rec= i_pstStAxisParam->lrAdjust_V;
 								lrAdjust_H_Rec= i_pstStAxisParam->lrAdjust_H;
 								iGateSa_Rec= i_pstStAxisParam->iGateSa;
 								iGateSaEx_Rec= i_pstStAxisParam->iGateSaEx;
 								wStatusRef_Rec= i_pstStAxisParam->wStatusRef;

 								//(*--------------------------------------------------|2019.4.2.190826_*)
 								dwControlBits_Rec= i_pstStAxisParam->dwControlBits;
 								//2020.12.5.141000按钮
 								wButtonFun_Rec= i_pstStAxisParam->wButtonFun;
 								//2025.10.28.165757 屏蔽容易混淆的内容
 								//wInkRoller_Fre=i_pstStAxisParam->wInkRoller_Fre;
 								wAirInletWindDoorValue=i_pstStAxisParam->wAirInletWindDoorValue;
 								wAirExhaustWindDoorValue=i_pstStAxisParam->wAirExhaustWindDoorValue;
 								wAirReturnWindDoorValue=i_pstStAxisParam->wAirReturnWindDoorValue;
 								//2025.10.28.165757 屏蔽容易混淆的内容
 								//wTemperature_Set=i_pstStAxisParam->wTemperature_Set;
 								bySampleSholdSwitch=i_pstStAxisParam->bySampleSholdSwitch;
 								wUpAdjButton_Count=i_pstStAxisParam->wUpAdjButton_Count;
 								wDnAdjButton_Count=i_pstStAxisParam->wDnAdjButton_Count;
 								wLeftAdjButton_Count=i_pstStAxisParam->wLeftAdjButton_Count;
 								wRightAdjButton_Count=i_pstStAxisParam->wRightAdjButton_Count;
 								wAlarmButton_Count=i_pstStAxisParam->wAlarmButton_Count;
 								wMCGS_SingleSwitch=i_pstStAxisParam->wMCGS_SingleSwitch;

 								//2025.10.28.165757 屏蔽容易混淆的内容
 								/*
 								//2021.10.27.102535||新增兼容奥特马
 								rHz_AxisInkRoller_ManuallySet_rec=i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet;
 								rCoeff_AxisInkRoller_Automatic_rec=i_pstStAxisParam->rCoeff_AxisInkRoller_Automatic;
 								rHz_AxisAirBlowning_ManuallySet_rec=i_pstStAxisParam->rHz_AxisAirBlowning_ManuallySet;
 								rHz_AxisAirExhaust_ManuallySet_rec=i_pstStAxisParam->rHz_AxisAirExhaust_ManuallySet;
 								wSV_TemCtrl_rec=i_pstStAxisParam->wSV_TemCtrl;
 								wSV_TemCtrl_PreHot_rec=i_pstStAxisParam->wSV_TemCtrl_PreHot;
 								byAxisRoller_UpperFrq_rec=i_pstStAxisParam->byAxisRoller_UpperFrq;
 								rAxisRoller_Frq_rec=i_pstStAxisParam->rAxisRoller_Frq;
 								*/
 								//2022.3.19.171218新增北人兼容
 								dwCtlBits_UnitBaseCraft_rec=i_pstStAxisParam->dwCtlBits_UnitBaseCraft;
 								wHz_UnitInkRoller_ManuallySet_rec=i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet;
 								wCoeff_UnitInkRoller_Auto_rec=i_pstStAxisParam->wCoeff_UnitInkRoller_Auto;
 								wHz_UnitScraper_ManuallySet_rec=i_pstStAxisParam->wHz_UnitScraper_ManuallySet;
 								wCoeff_UnitScraper_Auto_rec=i_pstStAxisParam->wCoeff_UnitScraper_Auto;
 								wHz_UnitHotWind_rec=i_pstStAxisParam->wHz_UnitHotWind;
 								wHz_UnitHotWind_2_rec=i_pstStAxisParam->wHz_UnitHotWind_2;
 								wSV_UnitTemCtl_rec=i_pstStAxisParam->wSV_UnitTemCtl;
 								//2022.7.3.115223新增加减速按钮
 								wAccButton_Count=i_pstStAxisParam->wAccButton_Count;
 								wDecButton_Count=i_pstStAxisParam->wDecButton_Count;
 								//2023.11.08.095817 同步
 								//2023.10.14.104552/wei.n/7吋人机色组IO与ARM通讯
 								wUnit_output_I_rec = i_pstStAxisParam->wUnit_output_I;
 								wUnit_output_II_rec = i_pstStAxisParam->wUnit_output_II;

 								//2025.7.24.085841+
 								rOffset_T1_Rec = i_pstStGlobalParam->rOffset_T1 ;
								rSource_Light_T1_Rec = i_pstStGlobalParam->rSource_Light_T1;
								rBias_T1_Rec = i_pstStGlobalParam->rBias_T1;
								rBrightness_Light_T1_Rec = i_pstStGlobalParam->rBrightness_Light_T1;
								rOffset_T2_Rec = i_pstStGlobalParam->rOffset_T2;
								rSource_Light_T2_Rec = i_pstStGlobalParam->rSource_Light_T2;
								rBias_T2_Rec = i_pstStGlobalParam->rBias_T2;
								rBrightness_Light_T2_Rec = i_pstStGlobalParam->rBrightness_Light_T2;
								bySignalSelect_Rec = i_pstStGlobalParam->bySignalSelect;
								//2025.10.24.085212+
								byArcSensorType_Rec = i_pstStGlobalParam->byArcSensorType;
 							}
 						}
						i_pstStAxisParam->iARMRunNum=16;		//2022.5.21.084823
 					}

 					else if(pstStPara_MailboxAlternate->dwSyncFlag!=gc_dwSemaphoreUpLink)
 					{
 						//(*如果数据没改变 且标志还是未知状态 就主动请求主站派发1次了*)
 						iCountdownRedispatchReq= iCountdownRedispatchReq+1;
 						if(iCountdownRedispatchReq>=10) //(*目前按20ms的周期 就是200ms*)
 						{
 							iCountdownRedispatchReq= 0;
 							adwBuf[0]= gc_dwSemaphoreRequestDispatch;
 							adwBuf[1]= 0;
 							//2025.12.1.094650 增加停止mail通讯标志控制
 							if(!i_pstStGlobalParam->xStopMailComm)
 								GT_RN_DevicePcMailComWr((unsigned long*)&(adwBuf[0]), 0, iStationId*gc_iMailboxBlockLen, 2, 1, 1);
 						}
 					}
 				}
 			}
 		}
 		//(*han.dp|2017-08-03 23:04:25|读取主站写给本站点的数据||*)
 		aiRtnCode[1]= GT_RN_UserPCRdLocalFPGA((unsigned long*)i_pstStPara_PduBroadcastDn, 0, 0, 8);
 		pbyBuf= (BYTE*)&(i_pstStPara_PduBroadcastDn->iPackId);
 		wTempChk= KS_CRC(pbyBuf, 30, &(dwCheckSumVal));

 		//start@2025.10.29.112627
		//2025.10.29.111734+检查命令id是否发生变化用来判断通讯还在不在@这个函数是20ms周期执行
 		static int16_t iPackId_PduDn = 0;//下行通讯id备份
 		static uint16_t uiDelayCnt_PduDn = 0;//下行通讯延时计数
 		uint8_t xPduDnFailed = i_pstStGlobalParam->xPduDnFailed;//获取初值
		if(i_pstStPara_PduBroadcastDn->iPackId == iPackId_PduDn)
		{
			if(!xPduDnFailed)
				uiDelayCnt_PduDn += 1;
		}
		else//通讯建立
			uiDelayCnt_PduDn = 0;
		iPackId_PduDn = i_pstStPara_PduBroadcastDn->iPackId;

		if(uiDelayCnt_PduDn >= PDUCOMM_TIMEOUT_CYCLECNT)//3s都没通讯置位pduDnFailed 标志
			xPduDnFailed = TRUE;//pdu通讯失败
		else//通讯建立了
			xPduDnFailed = FALSE;//pdu通讯恢复
		i_pstStGlobalParam->xPduDnFailed = xPduDnFailed;//输出
		if(xPduDnFailed)//通讯失败了就把主站通讯完成标志清零|下次通讯重新获取
			wMasterParam_Flag = 0;

		//输出@pdu下行失败或者在arm升级中的时候置位停止mail通讯标志@2025.12.1.092539
		i_pstStGlobalParam->xStopMailComm = xPduDnFailed || i_pstStGlobalParam->xArmUpdating;
		//end

 		if(aiRtnCode[1]==0 &&
 			wTempChk==i_pstStPara_PduBroadcastDn->wCHK)
 		{
 			switch(i_pstStPara_PduBroadcastDn->iPackId)
 			{
 				case 31:
 					pstStCMD_31= (StCMD_31*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射31#命令到通讯数据区|*)

 					i_pstStGrpParam->lrVelocity= pstStCMD_31->udiVelocity/100;//(*主机运行速度<单位0.01m/min>|*)

 					i_pstStGlobalParam->dwAxis_RollerDn= pstStCMD_31->dwAxis_RollerDn;//(*轴压辊状态|*)
 					i_pstStGlobalParam->dwAxis_Alarm= pstStCMD_31->dwAxis_Alarm;//(*轴报警状态|*)
 					i_pstStAxisParam->dwAlarmDetail= pstStCMD_31->dwStation_AlarmId;//(*站报警号|*)
 					i_pstStGlobalParam->dwAxis_SkipTheHeader= pstStCMD_31->dwAxis_SkipTheHeader;//(*轴让料头状态|*)

 					//(*找到当前色组的id|显示在人机上告知用户是几U||*)
 					i_pstStGlobalParam->iUId= pstStCMD_31->siUId;//(*映射机组号|*)
 					if(i_pstStGlobalParam->iUId>=1 && i_pstStGlobalParam->iUId<=MAX_STATION_NUM_AOYIN)
 					{
 						i_pstStAxisParam->iAxisId= i_pstStGlobalParam->iUId;
 						*i_pxGetAxisId= 1;
 					}
 					//2020.7.2.103451||取位方式更新||niu.j
 					byTemp = GetBit(pstStCMD_31->wComplexBitFields,0);//整机波门锁
 					i_pstStAxisParam->wSwitchRef = SetBit(byTemp,i_pstStAxisParam->wSwitchRef,10);

 					byTemp = GetBit(pstStCMD_31->wComplexBitFields,1);//整机纵向自动
 					i_pstStGrpParam->wCtlSwitchRef = SetBit(byTemp, i_pstStGrpParam->wCtlSwitchRef, 2);

 					byTemp = GetBit(pstStCMD_31->wComplexBitFields,2);//整机横向自动
 					i_pstStGrpParam->wCtlSwitchRef = SetBit(byTemp, i_pstStGrpParam->wCtlSwitchRef, 3);

 					byTemp = GetBit(pstStCMD_31->wComplexBitFields,3);//整机报警开关
 					i_pstStGrpParam->wCtlSwitchRef = SetBit(byTemp, i_pstStGrpParam->wCtlSwitchRef, 0);

 					i_pstStGrpParam->xMachineRev= GetBit(pstStCMD_31->wComplexBitFields,4);//(*整机反转|*)
 					i_pstStGrpParam->xUnitRev= GetBit(pstStCMD_31->wComplexBitFields,5);//(*色组反转|*)

 					byTemp = GetBit(pstStCMD_31->wComplexBitFields,6);
 					i_pstStGrpParam->wUwRwAxisProf = SetBit(byTemp, i_pstStGrpParam->wUwRwAxisProf , 0);//放料当前轴

 					byTemp = GetBit(pstStCMD_31->wComplexBitFields,7);
 					i_pstStGrpParam->wUwRwAxisProf = SetBit(byTemp, i_pstStGrpParam->wUwRwAxisProf , 1);//放料当前轴

 					i_pstStAxisParam->xThisUnitEna = GetBit(pstStCMD_31->wComplexBitFields, 8);//(*套印使能|*)

 					i_pstStGrpParam->xFlag_Print= GetBit(pstStCMD_31->wComplexBitFields, 9);//(*印刷标志|*)

 					byTemp = GetBit(pstStCMD_31->wComplexBitFields, 14);
 					i_pstStGlobalParam->wMachineArchitectureRef = SetBit(byTemp, i_pstStGlobalParam->wMachineArchitectureRef, 0);

 					//2020.6.8.202844||31#完成
 					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 1);
					i_pstStAxisParam->iARMRunNum=17;		//2022.5.21.084823

					//2025.7.24.183621 一些状态位获取
					if(*i_pxGetAxisId)//轴号是有效的
					{
						i_pstStAxisParam->xLocalAxisRollerDn = KSGetDataBit(&i_pstStGlobalParam->dwAxis_RollerDn,i_pstStAxisParam->iAxisId-1);
						i_pstStAxisParam->xLocalAxisLinkage = KSGetDataBit(&i_pstStGlobalParam->dwComplexFlag_AxisLinkage,i_pstStAxisParam->iAxisId-1);
					}

 					break;
 			case 32:
 					pstStCMD_32= (StCMD_32*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射32#命令到通讯数据区|*)
 					byGrpid_Dn= (*pstStCMD_32).byGrpId;
 					(*i_pstStAxisParam).byGrpId= byGrpid_Dn;

 					i_pstStAxisParam->iMarkTypeId= pstStCMD_32->byMarkTypeId;//(*标记形式|*)
 					i_pstStAxisParam->iMarkArrangeModal= pstStCMD_32->byMarkArrangeModalId;//(*标记排列形式|*)
 					i_pstStAxisParam->lrAlarm_V= (float)pstStCMD_32->lrAlarmV;//(*纵向报警|*)
 					i_pstStAxisParam->lrAlarm_H= pstStCMD_32->lrAlarmH;//(*横向报警|*)
 					if(i_pstStAxisParam->lrGirth!=pstStCMD_32->lrGirth)
 					{
 						i_pstStAxisParam->lrGirth= pstStCMD_32->lrGirth;//(*版周长*)
 						dwReCfgFlag|= 1<<1;
 					}
 					i_pstStAxisParam->byColorIdCurrent=pstStCMD_32->byColorIdCurrent;//当前色序
 					dwRoundSampleThreshold=pstStCMD_32->dwRes1_1_32;//主站下发的粗采样阀值
 					byFineSampleSaveFlag_Temp=GetBit(pstStCMD_32->dwRes1_2_32, 0);
 					if(byFineSampleSaveFlag_Temp==1&&byFineSampleSaveFlag_PreTemp==0)
 					{
 						byFineSampleSaveFlag=GetBit(pstStCMD_32->dwRes1_2_32, 0);
 						*i_pbyFineSampleSaveFlag=byFineSampleSaveFlag;
 					}
 					byFineSampleSaveFlag_PreTemp=byFineSampleSaveFlag_Temp;
 					*i_pbySignal10VCoef = pstStCMD_32->dwRes1_3_32;
 					*i_pbyScanCount = pstStCMD_32->dwRes1_4_32;
 					//2020.6.8.202844||32#完成
 					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 2);
 					//2023.5.18.154840
 					i_pstStGrpParam->wHotWind_Print= pstStCMD_32->wHotWind_Print;
 					i_pstStAxisParam->byFollowColorId= pstStCMD_32->byFollowColorId;//2024.2.17.094200
					//2024.7.31.171952+
					i_pstStAxisParam->byFakeThreshold_V= pstStCMD_32->byFakeThreshold_V;
					i_pstStAxisParam->byFakeThreshold_H= pstStCMD_32->byFakeThreshold_H;
					i_pstStAxisParam->byAve_v_extra_V= pstStCMD_32->byAve_v_extra_V;
					//2024.8.14.093213 同步
					i_pstStAxisParam->bySysSamplePrecision= pstStCMD_32->bySysSamplePrecision;
					i_pstStAxisParam->byArcFineSampleType= pstStCMD_32->byArcFineSampleType;
					//byTemp= GetBit(i_pstStAxisParam->byArcFineSampleType,0);
					//2025.1.4.132824 byArcFineSampleType=1作为新的采样方式标志
					//i_pstStAxisParam->xFlag_CalcErr_New=i_pstStAxisParam->byArcFineSampleType == 1;

					i_pstStAxisParam->iARMRunNum=18;		//2022.5.21.084823

 					break;
 				case 33:
 					pstStCMD_33= (StCMD_33*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射33#命令到通讯数据区|*)

 					//i_pstStAxisParam->lrDeadzone_V= pstStCMD_33->lrDeadzoneV;//(*纵向不工作区|*)
 					//i_pstStAxisParam->lrDeadzoneMin_H= pstStCMD_33->lrDeadzoneMinH;//(*横向最小不工作区|*)
 					//i_pstStAxisParam->lrDeadzoneMax_H= pstStCMD_33->lrDeadzoneMaxH;//(*横向最大不工作区|*)
 					i_pstStAxisParam->wSwitchRef= pstStCMD_33->wSwitchRef;//(*色组的开关状态|*)
 					i_pstStAxisParam->iAverage_V= (INT)(pstStCMD_33->byAverageV);//(*纵向平均值|*)
 					i_pstStAxisParam->iAverage_H= (INT)(pstStCMD_33->byAverageH);//(*横向平均值|*)
 					//2020.6.8.202844||33#完成
 					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 3);
 					*i_pxFlag_SingleMode = GetBit(i_pstStAxisParam->wSwitchRef,8);
 					//2023.4.25.095943整机双波门
 					byTemp = GetBit(i_pstStAxisParam->wSwitchRef,6);
 					if(i_pstStAxisParam->xFlag_Gate_double!=byTemp)//双波门开关-重新配置采样
 					{
 						i_pstStAxisParam->xFlag_Gate_double= byTemp;//
 						dwReCfgFlag|= 1<<4;
 					}
					//2025.7.23.201517 月光宝盒pro的采样数据只支持双极性
 					KSSetDataBit(&i_pstStAxisParam->wSwitchRef,1,9);//强制将极性写为双极性
 					//2025.9.26.112438+
					i_pstStAxisParam->byDriverType_Hmi485 = pstStCMD_33->byDriverType_Hmi485;
					i_pstStAxisParam->xRsMorphFilter = pstStCMD_33->xRsMorphFilter;//2026.4.22.150553+
 					//2023.11.08.102118
 					//2023.10.14.145013/wei.n/7吋人机色组IO与ARM通讯
 					i_pstStAxisParam->wUnit_input_I = pstStCMD_33->wUnit_input_I;
 					i_pstStAxisParam->wUnit_input_II = pstStCMD_33->wUnit_input_II;
 					i_pstStAxisParam->wUnit_input_III = pstStCMD_33->wUnit_input_III;

					//2025.4.25.144718 增加了权限的从站通讯
					i_pstStGrpParam->byCurrUsrLevel= pstStCMD_33->byCurrUsrLevel;
					i_pstStGlobalParam->byCurrUsrLevel= pstStCMD_33->byCurrUsrLevel;

					//2025.6.5.143408+通讯内容@下行
					i_pstStAxisParam->wPulseCtlInf= pstStCMD_33->wPulseCtlInf;
					i_pstStAxisParam->wPulse_1r= pstStCMD_33->wPulse_1r;
					i_pstStAxisParam->byPulseCtl_DisPerPulse= pstStCMD_33->byPulseCtl_DisPerPulse;
					//i_pstStAxisParam->rInkGroovePosPPulse= (REAL)(pstStCMD_33->byPulseCtl_DisPerPulse)/10000;//2025.6.11.142949+
					i_pstStAxisParam->byPulseCtlBit= pstStCMD_33->byPulseCtlBit;
					i_pstStAxisParam->stStInkGrooveCtl.iMsg= pstStCMD_33->iInkGrooveCtlMsg;
					i_pstStAxisParam->byDriverType_Hor= pstStCMD_33->byDriverType_Hor;
					//2025.8.11.085243+
					i_pstStGlobalParam->rSource_Light_T1_Cur= (float)pstStCMD_33->uiSource_Light_T1_Cur / 1000;
					i_pstStGlobalParam->rSource_Light_T2_Cur= (float)pstStCMD_33->uiSource_Light_T2_Cur / 1000;

					i_pstStAxisParam->iARMRunNum=19;		//2022.5.21.084823

 					break;
 				case 34:
 					pstStCMD_34= (StCMD_34*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射34#命令到通讯数据区|*)

 					iGrpId= (INT)(i_pstStAxisParam->byGrpId);
 					if(iGrpId!=1 && iGrpId!=2)
 					{
 						iGrpId= 1;
 					}

 					if( (i_pstStAxisParam->iGateWidthPhy!=pstStCMD_34->iGateWidthPhy &&
 						pstStCMD_34->iGateWidthPhy>=5 && pstStCMD_34->iGateWidthPhy<=40) ||
 						i_pstStAxisParam->iGateWidthRondPt!=pstStCMD_34->iGateWidthRoundPts ||
 						i_pstStAxisParam->iGateWidthFinePt!=pstStCMD_34->iGateWidthFinePts )
 					{
 						i_pstStAxisParam->iGateWidthPhy= pstStCMD_34->iGateWidthPhy;//(*波门宽度|*)
 						i_pstStAxisParam->iGateWidthRondPt= pstStCMD_34->iGateWidthRoundPts;//(*波门占据的粗采样点|*)
 						i_pstStAxisParam->iGateWidthFinePt= pstStCMD_34->iGateWidthFinePts;//(*波门占据的精采样点|*)

 						dwReCfgFlag |= 1<<2;
 					}
 					i_pstStAxisParam->uiNum= pstStCMD_34->uiNum;//(*减速比分子|*)
 					i_pstStAxisParam->uiDen= pstStCMD_34->uiDen;//(*减速比分母|*)
 					i_pstStGrpParam->byTriMark_SideC= pstStCMD_34->byTriangleMark_SideC;//(*梯标内三角形纵向边长|*)
 					i_pstStGrpParam->byTriMark_SideB= pstStCMD_34->byTriangleMark_SideB;//(*梯标内三角形横向边长|*)

 					i_pstStGlobalParam->iCompanyId= pstStCMD_34->iCompanyId;//(*企业id|*)
 					i_pstStGlobalParam->byLanguageId= pstStCMD_34->byLanguageId;//(*操作语言id|*)

 					//	2021.6.17.150936||获取全局控制位
 					i_pstStGlobalParam->dwControlComplexBits=  pstStCMD_34->dwControlComplexBits;//全局控制位

 					//(*采样控制位|*)
 					if(i_pstStAxisParam->iSampleCfgParam_Ctl!=pstStCMD_34->iSampleCfgParam_Ctl)
 					{
 						i_pstStAxisParam->iSampleCfgParam_Ctl= pstStCMD_34->iSampleCfgParam_Ctl;
 						dwReCfgFlag|=1<<3;
 					}
 					//(*2018.4.11.102040|*)
 					pbyLedSwitchTimeouts= &(pstStCMD_34->byMinutes_ScrAutoSleep);//(*2019.4.15.102103|修复led自动休眠时间|*)
 					if(i_pbyLedSwitchTimeouts!=0)
 					{
 						*i_pbyLedSwitchTimeouts= *pbyLedSwitchTimeouts;
 					}
 					//(*--------------------------------------------------|2019.8.29.154525_*)
 					//(*横向快速对版广播状态|*)
 					i_pstStAxisParam->wSts_HorzManuPreReg= pstStCMD_34->wSts_HorzManuPreReg;
 					i_pstStAxisParam->iPos_HorzManuPreReg= pstStCMD_34->iPos_HorzManuPreReg;
 					//2020.6.8.202844||34#完成
 					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 4);
					i_pstStAxisParam->iARMRunNum=20;		//2022.5.21.084823

 					break;
 				case 35:
 					pstStCMD_35= (StCMD_35*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射35#命令到通讯数据区|*)
 					i_pstStAxisParam->dwKpid_V= pstStCMD_35->dwKpid_V;
 					i_pstStAxisParam->dwKpid_H= pstStCMD_35->dwKpid_H;

 					//(*--------------------------------------------------|2019.4.2.194049_*)
 					i_pstStGlobalParam->dwComplexFlag_AxisInchRunning= pstStCMD_35->dwComplexFlag_AxisInchRunning;
 					i_pstStGlobalParam->dwComplexFlag_AxisLinkage= pstStCMD_35->dwComplexFlag_AxisLinkage;

					//2025.10.28.165757 屏蔽容易混淆的内容
 					//i_pstStAxisParam->wButtonFunChoose= pstStCMD_35->wMCGSButtonStaton;
 					//i_pstStAxisParam->wTemperature_Feedback=pstStCMD_35->wTemperature_Feedback;
 					//(*--------------------------------------------------|2019.8.21.134714_*)
 					i_pstStGlobalParam->xArmUpdating = pstStCMD_35->xArmUpdating;//2025.12.1.094416+arm升级中
 					i_pstStGlobalParam->byUnLockHmi_UI = pstStCMD_35->byUnLockHmi_UI;//2026.1.31.145202+界面解锁标志
 					byGrpId_Temp= i_pstStAxisParam->byGrpId;
 					if(byGrpId_Temp==1 || byGrpId_Temp==2)
 					{
 						i_pstStGrpParam->dwAxisFlags_Estop= pstStCMD_35->dwComplexFlag_AxisEStop;
 					}
 					//2020.6.8.202844||35#完成
 					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 5);
 					i_pstStGrpParam->rGrp_Vel= pstStCMD_35->wGrpVel/100.0;//(*主机运行速度<单位0.01m/min>|*)
 					//查看代码2022年被力达做占用了,下面就无意义了
 					i_pstStGrpParam->bySts_Flag= pstStCMD_35->bySts_Flag;
 					i_pstStGrpParam->xFlag_Estop = pstStCMD_35->bySts_Flag ==3;//急停标志
 					i_pstStGrpParam->xFlag_Stop = pstStCMD_35->bySts_Flag ==0;//停止状态
 					i_pstStGrpParam->xFlag_Ink = pstStCMD_35->bySts_Flag ==2;//停止状态
 					//2024.8.31.153303
 					i_pstStAxisParam->byFilterNum_PeakValue_FineData= pstStCMD_35->byFilterNum_PeakValue_FineData;

					//2025.7.24.183621 一些状态位获取
					if(*i_pxGetAxisId)//轴号是有效的
					{
						i_pstStAxisParam->xLocalAxisEstop = KSGetDataBit(&i_pstStGrpParam->dwAxisFlags_Estop,i_pstStAxisParam->iAxisId-1);
					}

					i_pstStAxisParam->iARMRunNum=21;		//2022.5.21.084823

 					break;
 				case 36:
 					pstStCMD_36= (StCMD_36*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射35#命令到通讯数据区|*)
 					i_pstStAxisParam->rHz_UnitInkRoller_CurrWR= pstStCMD_36->wHz_UnitInkRoller_CurrWR;				//2022.3.26.111503
 					i_pstStAxisParam->rHz_UnitScraper_CurrWR= pstStCMD_36->wHz_UnitScraper_CurrWR;
 					i_pstStAxisParam->rHz_UnitHotWind_CurrWR= pstStCMD_36->wHz_UnitHotWind_CurrWR;
 					i_pstStAxisParam->rHz_UnitHotWind2_CurrWR= pstStCMD_36->wHz_UnitHotWind2_CurrWR;
 					i_pstStAxisParam->rPV_UnitTemCtl= pstStCMD_36->rPV_UnitTemCtl;
 					i_pstStAxisParam->wSTS_UnitTemCtl= pstStCMD_36->wSTS_UnitTemCtl;

 					i_pstStAxisParam->rWidth_Mark_Max= (REAL)(pstStCMD_36->byWidth_Mark_Max)/10.0;//(*单个色标最大宽度-0.1mm*)
 					i_pstStAxisParam-> rWidth_Mark_Min= (REAL)(pstStCMD_36->byWidth_Mark_Min)/10.0;//(*单个色标最小宽度-0.1mm*)
 					i_pstStAxisParam-> rMaxGap= (REAL)(pstStCMD_36->byMaxGap)/10.0;//(*最大间隙，-0.1mm*)
 					i_pstStAxisParam-> bySimilarityThreshold = (pstStCMD_36->bySimilarityThreshold);//(*相似度阈值40%-70%,*)
 					i_pstStAxisParam-> rSpotWidth = (REAL) (pstStCMD_36->bySpotWidth)/10.0;//(*光斑宽度*)
 					i_pstStAxisParam-> byFlag_CommFromMaster = pstStCMD_36->byFlag_CommFromMaster;//
 					i_pstStAxisParam-> byMeanOffset= (pstStCMD_36->byMeanOffset);
 					//2026.4.30.162644+ 通讯
 					i_pstStAxisParam->xFlag_AutoAdj_En = GetBit((WORD)pstStCMD_36->byFlag_CommFromMaster,0); //全自动套印使能
 					i_pstStAxisParam->xFlag_FindFirstMark = GetBit((WORD)pstStCMD_36->byFlag_CommFromMaster,1);//本色开始全自动套印
 					i_pstStAxisParam->xCurManuAdjust = GetBit((WORD)pstStCMD_36->byFlag_CommFromMaster,2);//本色未找到光电眼手动复位
 					i_pstStAxisParam->xFlag_FindPreMark=GetBit((WORD)pstStCMD_36->byFlag_CommFromMaster,3);//可以开始寻找前一色
 					i_pstStAxisParam->xPreCurManuAdjust = GetBit((WORD)pstStCMD_36->byFlag_CommFromMaster,4);//混色未找到光电眼手动复位
 					i_pstStAxisParam->xMasterComplete = GetBit((WORD)pstStCMD_36->byFlag_CommFromMaster,6); // 找本色主站触发再找一次
 					i_pstStAxisParam->xFlag_AskWaveWidth=GetBit((WORD)pstStCMD_36->byFlag_CommFromMaster,7);//精采样计算宽度
 					i_pstStAxisParam->rInnerCoff =(REAL) (pstStCMD_36->byInnerCoff)/10.0;
 					i_pstStAxisParam->rOuterCoff =(REAL) (pstStCMD_36->byOuterCoff)/10.0;

					i_pstStAxisParam->iARMRunNum=22;		//2022.5.21.084823
					break;
 				case 37:
 					pstStCMD_37= (StCMD_37*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射37#命令到通讯数据区|*)
					for (int i = 0; i < 4; i++)
					{
						i_pstStAxisParam->aiCurModeMidPoint[i]=pstStCMD_37->aiCurModeMidPoint[i];
						i_pstStAxisParam->abyCurModeRadius[i]=pstStCMD_37->abyCurModeRadius[i];
						i_pstStAxisParam->aiPreModeMidPoint[i]=pstStCMD_37->aiPreModeMidPoint[i] ;
						i_pstStAxisParam->abyPreModeRadius[i]=pstStCMD_37->abyPreModeRadius[i];
					}
 					break;
 				default:
 					;
 			}//switch结束
 		}//	end   if(aiRtnCode[1]==0 &&wTempChk==i_pstStPara_PduBroadcastDn->wCHK)

 		//(*han.dp|2017-08-04 10:13:21|需要重新配置采样||*)

// 		//2025.9.24.213301+ by liu.yt
 		//解决第一次上电时候,主站参数未全部更新,进入配置采样逻辑引起的配置采样异常问题。
 		static uint8_t xFlag_PreCommFromMaster = 0;
 		if(*i_pxFlag_CopyFromMaster)//主站参数同步完成
		{
			if( !xFlag_PreCommFromMaster)//从未同步完成进入同步完成状态
			{
				dwReCfgFlag= 1;//2025.9.24.213740通讯完成后强制配置一次
			}
		}
		else//参数未同步不配置采样
			dwReCfgFlag = 0;

		xFlag_PreCommFromMaster= *i_pxFlag_CopyFromMaster;
		//end@2025.9.24.214339+

 		if(dwReCfgFlag!=0)
 		{
 			if(i_pstStAxisParam->uiDen!=0 && i_pstStAxisParam->uiNum!=0 && i_pstStAxisParam->lrGirth!=0)
 			{
 				i_pstStAxisParam->iStationId= i_iStationId;//(*色组只要求是本地站点采样\2018.8.15.090118|*)
 				//byReCfgFlag=(BYTE)((dwReCfgFlag&1<<1)>>1);
 				//2024.8.21.192231||重新更新一下配采样方式
 				//不同采样方式集成到同一个函数中@2025.1.4.153526
 				/*
				if(i_pstStAxisParam->xFlag_CalcErr_New)
				{
					KS_CfgAxisSampleParam_New(
												i_pstStAxisParam,
												pdiFineSampleStart,
												&diArgumentToXW
											);
				}
				else
				{
				*/
					KS_CfgAxisSampleParam(
											i_pstStAxisParam,
											pdiFineSampleStart,
											&diArgumentToXW,
											i_pstStAxisParam->byArcFineSampleType);//2025.1.4.153626+);
				//}
 				i_pstStAxisParam->diArgumentToXW = diArgumentToXW;
 				i_pstStSyncWithServerOut->o_dwSampleConfigTimes= i_pstStSyncWithServerOut->o_dwSampleConfigTimes + 1;
 			}
 		}
 		//2024.05.13.164244 增加命令号轮询处理@删除以前的轮询方式|最多5个命令
 		static unsigned short iCurIdIndex=0;
 		unsigned short aiCmdIdList[5]={0},iCmdIdNum=0;//使用的命令id列表(默认有5号命令),命令id个数
 		//生成list
 		aiCmdIdList[iCmdIdNum]=5;
 		iCmdIdNum+=1;

 		byTemp=GetBit_DWORD(i_pstStGlobalParam->dwControlComplexBits,27);
 		if(byTemp!=1)
		{//=0则使用6#命令,反之不通讯6号命令
 			aiCmdIdList[iCmdIdNum]=6;
 			iCmdIdNum+=1;
 		}
 		if(i_pstStAxisParam->xFlag_AutoAdj_En)
		{//标志有效了则使用7#命令,全自动套印
 			aiCmdIdList[iCmdIdNum]=7;
 			iCmdIdNum+=1;
 		}

 		iCmdId=aiCmdIdList[iCurIdIndex];
 		iCurIdIndex+=1;
 		if(iCurIdIndex>=iCmdIdNum)
		{
 			iCurIdIndex=0;
 		}
 		//2024.05.13.173038 增加以上
 		switch (iCmdId)
 		{
 			case 5:
				i_pstStAxisParam->iARMRunNum=23;		//2022.5.21.084823

 				pstStCMD_05= (StCMD_05*)&i_pstStPara_PduBroadcastUp->abyPayload[0];//(*2018.8.22.180717\修复bug|*);
 				i_pstStPara_PduBroadcastUp->iPackId= iCmdId;//(*5#命令|*)
 				//取消无用变量的通讯
 				//2026.4.22.143205 屏蔽
// 				if(i_pstStAxisParam->xFlag_CalcErr_New==0)
// 				{
					pstStCMD_05->iVerror_FollowPreUnit=i_pstStAxisParam->aiVerror_Gate[0];
					pstStCMD_05->iVerror_Follow1Unit=i_pstStAxisParam->aiVerror_Gate[1];
					//pstStCMD_05->iHerror_FollowPreUnit=i_pstStAxisParam->aiHerror_Gate[0];
					//pstStCMD_05->iHerror_Follow1Unit=i_pstStAxisParam->aiHerror_Gate[1];
					pstStCMD_05->iVerror_Follow1U_New = (int16_t)(i_pstStAxisParam->arBase_use[0]);
// 				}
// 				else
// 				{// 新增通讯
//					pstStCMD_05->iVerror_FollowPreUnit=i_pstStAxisParam->iResult_V_Followpre;
//					pstStCMD_05->iVerror_Follow1Unit=i_pstStAxisParam->iResult_V_Follow_1U;
//					//pstStCMD_05->iHerror_FollowPreUnit=i_pstStAxisParam->iResult_H_Followpre;
//					//pstStCMD_05->iHerror_Follow1Unit=i_pstStAxisParam->iResult_H_Follow_1U;
//					//2026.4.22.143142 屏蔽
//					//pstStCMD_05->iVerror_Follow1U_New= i_pstStAxisParam->iResult_V_Follow_1U_New;
// 				}
 				pstStCMD_05->uiFSampleCounter=i_pstStAxisParam->uiFSampleCounter;//从轴参数中赋值@2023.09.19.155921

				//2025.6.5.142011 新增脉冲控制的内容的通讯
				//2025.6.5.142011 新增脉冲控制的内容的通讯
				wTemp = 0;//wTemp
				wTemp = SetBit(i_pstStAxisParam->xPulse_Outing,wTemp,0);//函数只支持word的写入bit
				wTemp = SetBit(i_pstStAxisParam->xInkGrooveInPos,wTemp,1);//函数只支持word的写入bit@到位标志
				//将输出状态写入到.\2 .\3为(0--3)
				if(i_pstStAxisParam->byPulseOutSts == 0)
				{
					wTemp = SetBit(FALSE,wTemp,2);
					wTemp = SetBit(FALSE,wTemp,3);
				}
				else if (i_pstStAxisParam->byPulseOutSts == 1 ||
					i_pstStAxisParam->byPulseOutSts == 255)
				{
					wTemp = SetBit(TRUE,wTemp,2);
					wTemp = SetBit(FALSE,wTemp,3);
				}
				else if (i_pstStAxisParam->byPulseOutSts == 2)
				{
					wTemp = SetBit(FALSE,wTemp,2);
					wTemp = SetBit(TRUE,wTemp,3);
				}
				else if (i_pstStAxisParam->byPulseOutSts == 3)
				{
					wTemp = SetBit(TRUE,wTemp,2);
					wTemp = SetBit(TRUE,wTemp,3);
				}


				pstStCMD_05->byStsBit=(BYTE)wTemp;
				pstStCMD_05->wPulse_Rd=i_pstStAxisParam->wPulse_Rd;

 				//2024.8.28.171912先不发这个东西为了保存基线
 				pstStCMD_05->dwSlaveVer=DWVERSION; //将从站版本号发到主站显示			2024.9.14.095654恢复通讯版本号

 				if(i_pstStAxisParam->bySampleSholdSwitch==1)
 				{
 					bySampleSholdT1= 7;
 					bySampleSholdT2= 7;
 				}
 				else
 				{
 					if(i_pstStAxisParam->bySampleSholdSwitch==2)
 					{
 						bySampleSholdT1= 20;
 						bySampleSholdT2= 20;
 					}
 					else
 					{
 						bySampleSholdT1= 14;
 						bySampleSholdT2= 14;
 					}
 				}
				aiBase_Min[0]= (INT)i_alrBase[0]- (INT)bySampleSholdT1;
				aiBase_Min[1]= (INT)i_alrBase[1]- (INT)bySampleSholdT2;
				aiBase_Max[0]= (INT)i_alrBase[0]+ (INT)bySampleSholdT1;
				aiBase_Max[1]= (INT)i_alrBase[1]+ (INT)bySampleSholdT2;
				if(aiBase_Min[0]<0) aiBase_Min[0]=0;
				if(aiBase_Min[0]>255) aiBase_Min[0]=255;
				if(aiBase_Min[1]<0) aiBase_Min[1]=0;
				if(aiBase_Min[1]>255) aiBase_Min[1]=255;
				if(aiBase_Max[0]<0) aiBase_Max[0]=0;
				if(aiBase_Max[0]>255) aiBase_Max[0]=255;
				if(aiBase_Max[1]<0) aiBase_Max[1]=0;
				if(aiBase_Max[1]>255) aiBase_Max[1]=255;

				pstStCMD_05->abyBaseline_Min[0]= (BYTE)aiBase_Min[0];
				pstStCMD_05->abyBaseline_Min[1]= (BYTE)aiBase_Min[1];
				pstStCMD_05->abyBaseline_Max[0]= (BYTE)aiBase_Max[0];
				pstStCMD_05->abyBaseline_Max[1]= (BYTE)aiBase_Max[1];

 			break;
 			case 6://2022.3.19.173629新增北人06#
				i_pstStAxisParam->iARMRunNum=24;		//2022.5.21.084823

 				pstStCMD_06= (StCMD_06*)&i_pstStPara_PduBroadcastUp->abyPayload[0];//(*2018.8.22.180717\修复bug|*);
 				i_pstStPara_PduBroadcastUp->iPackId= iCmdId;//(*6#命令|*)
 				pstStCMD_06->wHz_UnitInkRoller_CurrRD = (WORD)i_pstStAxisParam->rHz_UnitInkRoller_CurrRD;
 				pstStCMD_06->wSTS_UnitInkRoller = i_pstStAxisParam->wSTS_UnitInkRoller;
 				pstStCMD_06->wHz_UnitScraper_CurrRD = (WORD)i_pstStAxisParam->rHz_UnitScraper_CurrRD;
 				pstStCMD_06->wSTS_UnitScraper = i_pstStAxisParam->wSTS_UnitScraper;
 				pstStCMD_06->wSTS_UnitHotWind = i_pstStAxisParam->wSTS_UnitHotWind;
 				//pstStCMD_06->wSTS_UnitHotWind_2 = i_pstStAxisParam->wSTS_UnitHotWind_2;
 				pstStCMD_06->wHz_UnitHotWind_CurrRD = (WORD)i_pstStAxisParam->rHz_UnitHotWind_CurrRD;
 				//pstStCMD_06->wHz_UnitHotWind2_CurrRD = (WORD)i_pstStAxisParam->rHz_UnitHotWind2_CurrRD;
 				pstStCMD_06->uiFSampleCounter=i_pstStAxisParam->uiFSampleCounter;//从轴参数中赋值@2023.09.19.155921
 				//2025.6.5.142719+ 通讯内容修改
				//WORD wTmp = 0;
 				wTemp = 0;
				BYTE* pbyTmp;//单字节地址@2025.10.17.092241+获取横向编码器的24bit数据

				wTemp = SetBit(i_pstStAxisParam->xEncValueIsValid_Hor,wTemp,0);//写入到第0bit
				wTemp = SetBit(i_pstStAxisParam->xHorMotorAlarm,wTemp,1);//写入到第1bit
				pstStCMD_06->byStsBit=(BYTE)wTemp;
				//会多访问一个byte@2025.10.17.101746+
				pbyTmp  = (BYTE*)(&pstStCMD_06->iEncValue_Hor);//获取要写入值的首地址
				pbyTmp[0] = (BYTE)i_pstStAxisParam->dwEncValue_Hor;//低8bit
				pbyTmp[1] = (BYTE)(i_pstStAxisParam->dwEncValue_Hor>>8);
				pbyTmp[2] = (BYTE)(i_pstStAxisParam->dwEncValue_Hor>>16);
				//pstStCMD_06->iEncValue_Hor=i_pstStAxisParam->dwEncValue_Hor;

				//2023.5.18.154112不要这两个变量了，现已经增加了双波门精采样计算了，不需要粗采样的值了
				//更改为占用一个字节通讯计数值，另外三个预留
				//			pstStCMD_06->iHError_Follow1U= (INT)i_aiHResult[0];
				//			pstStCMD_06->iRtn_CalcError_Follow1U= i_iRtn_Calc2022;
 				i_pstStAxisParam->byCnt_Comm= i_pstStAxisParam->byCnt_Comm+1;
 				pstStCMD_06->byCnt_Comm= i_pstStAxisParam->byCnt_Comm;
				break;
 			case 7:
				i_pstStAxisParam->iARMRunNum=25;		//2022.5.21.084823

 				pstStCMD_07= (StCMD_07*)&i_pstStPara_PduBroadcastUp->abyPayload[0];//(*2018.8.22.180717\修复bug|*);
 				i_pstStPara_PduBroadcastUp->iPackId= iCmdId;//(*5#命令|*)
 				//(*2026.01.27.151431||wang.xy全自动套印*)
 				pstStCMD_07->iCurLabelPos = i_pstStAxisParam->iCurLabelPos;
 				pstStCMD_07->iPreLabelPos = i_pstStAxisParam->iPreLabelPos;
 				wTemp = 0;
 				wTemp = SetBit(i_pstStAxisParam->xFlag_FindFirstSuccess,wTemp,0);//写入到第0bit
 				wTemp = SetBit(i_pstStAxisParam->xFlag_FindPreSuccess,wTemp,1);//写入到第1bit
 				wTemp = SetBit(i_pstStAxisParam->xFlag_FindCurDone,wTemp,2);//写入到第2bit
 				wTemp = SetBit(i_pstStAxisParam->xFlag_GiveWaveWidth,wTemp,3);//宽度得到完成
 				wTemp = SetBit(i_pstStAxisParam ->xFind_IDLE,wTemp,4);//当前状态机空闲
 				pstStCMD_07->byFlag_CommFromSlave = wTemp;
 				pstStCMD_07->byDetectedSignalCount = i_pstStAxisParam->byDetectedSignalCount;
 				pstStCMD_07->byMarkStep = i_pstStAxisParam->byMarkStep;//当前全自动套印步骤
 				pstStCMD_07->byWidthRS = i_pstStAxisParam->byWidthRS;
 				pstStCMD_07->iWidth_FindMarkCenter=(int16_t)(i_pstStAxisParam->rWaveWidth*100.0);
				break;
 			default ://2023.09.19.153843 增加出错处理
 					//iNum_CmdStep=0;
 					iCmdId=5;
 			break;
 		}
 		pbyTemp= (BYTE*)&(i_pstStPara_PduBroadcastUp->iPackId);
 		wTempChk=KS_CRC(pbyTemp, 22, &dwCheckSumVal);//校验码
 		i_pstStPara_PduBroadcastUp->wCHK= wTempChk;
 		pdwTemp= (DWORD*)i_pstStPara_PduBroadcastUp;
 		//2025.10.31.100210 为了兼容光纤和光电眼的切换|16d驱动器站号会超过31,pdu上行的地址超限
 		//改为了轴id偏移
		if(*i_pxGetAxisId && !xPduDnFailed)//2025.10.31.100039+轴id获取成功了|才触发通讯@PDU下行通讯正常才上行
		{
			if(i_pstStAxisParam->iAxisId > 0 && i_pstStAxisParam->iAxisId < MAX_STATION_NUM_AOYIN)//轴号合法
				aiRtnCode[6]= GT_RN_UserPCWrNetFPGA(pdwTemp, 0,i_pstStAxisParam->iAxisId, 0, 8);
		}

 		//(*han.dp|2017-08-04 10:12:46|重新请求主站派发数据||*)
 		if(xReqDispatchAgain)
 		{
 			adwBuf[0]=gc_dwSemaphoreRequestDispatch;
 			adwBuf[1]= 0;
 			//(*marked by han.dp@2017-08-03 23:25:25
 			//.GT_RN_DevicePcMailComWr()
 			//.参数1: pData,要写入的数据地址
 			//.参数2: stationId,目标站点(从站默认写入主站0#站)
 			//.参数3: startAddr,起始地址(最大分配了8192字节,目前按照1个站点128个字节,最高512字节被GRT.EXE使用来写错误信息或者助手会用480字节来进行升级操作)
 			//.参数4: dwordNum,4字节的数量
 			//.参数5: cmdType,1-写操作;5-读操作
 			//.参数6: respReq,回应请求,0异步方式;1同步方式
 			//*)
			//2025.12.1.094650 增加停止mail通讯标志控制
			if(!i_pstStGlobalParam->xStopMailComm)
				GT_RN_DevicePcMailComWr((unsigned long*)&(adwBuf[0]), 0, iStationId*gc_iMailboxBlockLen, 2, 1, 1);
 		}

 		i_pstStSyncWithServerOut->o_xEno= 1;
 		if(wMasterParam_Flag == 0x3F)//二进制111111-mailbox和31~35#命令首次通讯完成
 		{
 			*i_pxFlag_CopyFromMaster=1;
 		}
 		else
 		{
 			*i_pxFlag_CopyFromMaster=0;
 		}
 	}
 	else
 	{
 		i_pstStSyncWithServerOut->o_xEno=0;
 		i_pstStSyncWithServerOut->o_dwSampleConfigTimes=0;
 	}
 }

 void KS_FB_SyncWithServer_Deputy(	BYTE i_xEn							,
 									BYTE i_iStationId					,
									BYTE i_xGotTheMailboxClock			,       //		: BOOL;(*拿到Mailbox传输周期|*)
									BYTE* i_pxFlag_CopyFromMaster		,//获取主站参数成功标志
									StAxisParam* i_pstStAxisParam		,
									StGrpParam* i_pstStGrpParam			,
									StGlobalParam* i_pstStGlobalParam	,
									StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
									StPara_PduBroadcastDn* i_pstStPara_PduBroadcastDn,
									StSyncWithServerOut* i_pstStSyncWithServerOut	,
									BYTE* i_pxGetParam)
 {
 	//变量定义2022.6.20.180953
 	static INT iGirth_Uw_A_Rec;//: INT; (*放A周长*)
 	static INT iGirth_Uw_B_Rec;//: INT; (*放B周长*)
 	static INT iGirth_Pu_Rec;//: INT;(*版周长*)
 	static INT iVelocity_Tar_Rec;//: INT;(*目标速度*)
 	static INT iAI_mid_Uw_Rec;//: INT;(*放料中位*)
 	static INT iAI_mid_If_Rec;//: INT;(*放牵中位*)
 	static BYTE byDir_Uw_If_AI_Rec;//: BYTE;(*放料放牵摆臂方向判断bit0:放料bit1:放牵*)
 	static WORD wKp_Uw_Rec;//: WORD;(*放料P*)
 	static WORD wKi_Uw_Rec;//: WORD;(*放料I*)
 	static WORD wKd_Uw_Rec;//: WORD;(*放料D*)
 	static WORD wKp_If_Rec;//: WORD;(*放牵P*)
 	static WORD wKi_If_Rec;//: WORD;(*放牵i*)
 	static WORD wKd_If_Rec;//: WORD;(*放牵d*)
 	static BYTE bySwitch_AutoCut_Uw_Rec;//: BYTE;(*放料自动裁切使能开关bit0:使能；bit1:剩余卷径方式bit2:剩余米数方式*)
 	static INT iDia_PaperRoller_Uw_Rec;//: INT;(*纸筒直径*10*)
 	static INT iFilmThickNess_Rec;//: INT;(*料模厚度*1000*)
 	static WORD wAutoMaticCutDia_Uw_Rec;//: WORD;(*剩余卷径方式卷径设定*)
 	static WORD wAutoMaticCutMeters_Uw_Rec;//: WORD;(*剩余米数方式米数设定*)
 	static WORD wActRemainFilmLenth_Uw_Rec;//: WORD;(*实际剩余料长-校正纸筒直径可用*)
 	static INT iAlarm_Uw_Dia_Rec ;//: INT;(*放料报警卷径设置*)
 	static INT iDelayMsec_CutterHolder_Rec;//: INT;(*刀架执行时间*)
 	static INT iDelayMsec_RollerCylinder_Rec;//: INT;(*压辊执行时间*)
 	static INT iDelayMsec_CutOffKnifeCylinder_Rec;//: INT;(*裁刀执行时间*)
 	static WORD uiMM_Roller2GummedTape_Rec;//: WORD;(*压辊胶带距离*)
 	static WORD uiMM_Roller2CutOfKnife_Rec;//: WORD;(*压辊裁刀距离*)
 	static WORD uiMM_CutOfKnife2GummedTape_Rec;//: WORD;(*裁刀胶带距离*)
 	static INT iCoefCut_FilmVolPerimeter_Uw_Rec;//:INT;(*放料裁切圈数*)
 	static INT iStepVariation4ChangeTime_Rec;//		: INT; (* 2018.9.30.100457/用来步进胶辊延时和裁刀延时的变化量 *)
 	static BYTE bySwitch_Compensate_Uw_Rec;//		: BYTE;(*放料翻转架补偿开关：Bit0:补偿开启,bit1:方向取反,bit2:0弧度确认*)
 	static WORD wDiam_Tower_Uw_Rec							;//: WORD;(*放料翻转架的直径|mm*)
 	static WORD wDiam_NextRoller_Uw_Rec				;//		: WORD;(*放料翻转架下个辊的直径|mm*)
 	static WORD wXPos_NextRoller_Uw_Rec				;//		: WORD;(*放料翻转架下个辊的X位置|mm|翻转架中心作为坐标系0点*)
 	static WORD wYPos_NextRoller_Uw_Rec				;//		: WORD;(*放料翻转架下个辊的Y位置|mm|翻转架中心作为坐标系0点*)
 	static WORD wDiam_DeflectorRoller_Uw_Rec		;//		: WORD;(*翻料架上导向辊的直径|mm*)
 	static WORD wDiam_DeflectorRollPos_Uw_Rec	;//			: WORD;(*ABjuli翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
 	static BYTE byDiamMeasureTypeId_Rec;//: BYTE;(*卷径测量方式=0：电位器=1*)
 	static INT iStdVol_Diam_1_Rec;//: INT;
 	static INT iStdVol_Diam_2_Rec;//: INT;
 	static INT iStdVol_Diam_3_Rec;//: INT;
 	static INT iStdVol_Diam_4_Rec;//: INT;
 	static DWORD dwStdVol_Volt_AxisA_1_Rec;//: DWORD;
 	static DWORD dwStdVol_Volt_AxisA_2_Rec;//: DWORD;
 	static DWORD dwStdVol_Volt_AxisA_3_Rec;//: DWORD;
 	static DWORD dwStdVol_Volt_AxisA_4_Rec;//: DWORD;
 	static INT iStdVol_Coef_Axis_1_Rec;//: INT;(* 卷径测量系数*1000 *)
 	static INT iStdVol_Coef_Axis_2_Rec;//: INT;
 	static INT iStdVol_Coef_Axis_3_Rec;//: INT;
 	static BYTE byIsDebug_DiaMeasureArea_Uw_Rec;//: BYTE;
 	static BYTE bySwitch_DiaMeasure_Rec;//: byte;(*bit0:自动卷径开关bit1:双轴biw2:弧面bit3:调试模式*)
 	static BYTE bySwitch_Enc_Uw_Rec;//: BYTE;(*放料编码器标定相关bit0:双轴系数bit1:调试模式
 								//bit2:定位写入bit3:最小径写入*)
 	static WORD wButton_Uw_Rec;//: WORD;

 	//以上为双向变量区域保留值-用于比对主站参数是否发生变化
 	INT iStationId								;//: INT;
 	WORD wTempChk								;//: WORD;

 	stCMD_31_Deputy* pstStCMD_31_Deputy			;//: POINTER TO StCMD_31;
 	stCMD_32_Deputy* pstStCMD_32_Deputy			;//: POINTER TO StCMD_32;

 	BYTE* pbyBuf								;//: POINTER TO BYTE; (*char buffer's pointer*)
 	DWORD dwParaUpdateFlag						;//: DWORD;(*用来判断参数是否发生变化|*)
 	DWORD dwParaUpdateFlag_1					;//: DWORD;(*用来判断参数是否发生变化|*)2022.3.19.170744
 	StPara_MailboxAlternate_Deputy* pstStPara_MailboxAlternate_Deputy	;//: POINTER TO StPara_MailboxAlternate;
 	DWORD dwPayloadLen							;//: DWORD;
 	static WORD wDWordNum						;//: WORD;
 	static BYTE xGetCopyFromSrvOk=0				;//: BOOL := FALSE;(*用来表示从服务器下载copy成功|*)
 	static INT iCountdownRedispatchReq=0		;//: INT := 0;
 	static WORD wMasterParam_Flag=0;//获取主站参数标志
 	INT iN;
 	DWORD dwCheckSumVal							;//: DWORD;
 	iStationId=i_iStationId;

 		if(i_xGotTheMailboxClock)
 		{
			pstStPara_MailboxAlternate_Deputy= (StPara_MailboxAlternate_Deputy*)&(adwBuf);
			//(*han.dp|2017-08-03 23:33:10|
			//.GT_RN_DevicePcMailComRd()参数描述:|
			//.参数1: 数据返回地址;|
			//.参数2: 目标站号(目前约定在主站0#站点|
			//.参数3: 内存起点(<=8192-512)|
			//.参数4: 4字节的数量(dwordNum)|
			//.参数5: 操作模式;1写;5读||*)

			//(*2019.4.2.191518|*)
			//(*>>begin_mark|*)
			dwPayloadLen= sizeof(*pstStPara_MailboxAlternate_Deputy);
			wDWordNum= (WORD)(dwPayloadLen/sizeof(dwPayloadLen));
			if ((dwPayloadLen & 0x3)!=0)
			{
				wDWordNum= wDWordNum+1;
			}
			//(*<<end_mark|*)
 			//2024.01.11.124956 增加函数返回值的判断
 			int16 iRtn_MailComRd = -1;//默认非法值
			if(!i_pstStGlobalParam->xStopMailComm)
				iRtn_MailComRd=GT_RN_DevicePcMailComRd((unsigned long*)pstStPara_MailboxAlternate_Deputy, 0, iStationId*gc_iMailboxBlockLen, wDWordNum, 5);
 			if(iRtn_MailComRd==0)
 			{
				if (pstStPara_MailboxAlternate_Deputy->dwSyncFlag==gc_dwSemaphoreDownLink)
				{
					//(*主站有数据来||*)
					if (*i_pxGetParam)
					{
						xGetCopyFromSrvOk= 1;
					}
					iCountdownRedispatchReq= 0;

					//判断数据项改变2022.6.20.232256

					if(i_pstStGrpParam->iGirth_Uw_A!=pstStPara_MailboxAlternate_Deputy->iGirth_Uw_A)
					{
						i_pstStGrpParam->iGirth_Uw_A= pstStPara_MailboxAlternate_Deputy->iGirth_Uw_A;
					}
					iGirth_Uw_A_Rec= i_pstStGrpParam->iGirth_Uw_A;

					if(i_pstStGrpParam->iGirth_Uw_B!=pstStPara_MailboxAlternate_Deputy->iGirth_Uw_B)
					{
						i_pstStGrpParam->iGirth_Uw_B= pstStPara_MailboxAlternate_Deputy->iGirth_Uw_B;
					}
					iGirth_Uw_B_Rec= i_pstStGrpParam->iGirth_Uw_B;

					if(i_pstStGrpParam->iGirth_Pu!=pstStPara_MailboxAlternate_Deputy->iGirth_Pu)
					{
						i_pstStGrpParam->iGirth_Pu= pstStPara_MailboxAlternate_Deputy->iGirth_Pu;
					}
					iGirth_Pu_Rec= i_pstStGrpParam->iGirth_Pu;

					if(i_pstStGrpParam->iVelocity_Tar!=pstStPara_MailboxAlternate_Deputy->iVelocity_Tar)
					{
						i_pstStGrpParam->iVelocity_Tar= pstStPara_MailboxAlternate_Deputy->iVelocity_Tar;
					}
					iVelocity_Tar_Rec= i_pstStGrpParam->iVelocity_Tar;

					if(i_pstStGrpParam->iAI_mid_Uw!=pstStPara_MailboxAlternate_Deputy->iAI_mid_Uw)
					{
						i_pstStGrpParam->iAI_mid_Uw= pstStPara_MailboxAlternate_Deputy->iAI_mid_Uw;
					}
					iAI_mid_Uw_Rec= i_pstStGrpParam->iAI_mid_Uw;

					if(i_pstStGrpParam->iAI_mid_If!=pstStPara_MailboxAlternate_Deputy->iAI_mid_If)
					{
						i_pstStGrpParam->iAI_mid_If= pstStPara_MailboxAlternate_Deputy->iAI_mid_If;
					}
					iAI_mid_If_Rec= i_pstStGrpParam->iAI_mid_If;

					if(i_pstStGrpParam->byDir_Uw_If_AI!=pstStPara_MailboxAlternate_Deputy->byDir_Uw_If_AI)
					{
						i_pstStGrpParam->byDir_Uw_If_AI= pstStPara_MailboxAlternate_Deputy->byDir_Uw_If_AI;
					}
					byDir_Uw_If_AI_Rec= i_pstStGrpParam->byDir_Uw_If_AI;

					if(i_pstStGrpParam->wKp_Uw!=pstStPara_MailboxAlternate_Deputy->wKp_Uw)
					{
						i_pstStGrpParam->wKp_Uw= pstStPara_MailboxAlternate_Deputy->wKp_Uw;
					}
					wKp_Uw_Rec= i_pstStGrpParam->wKp_Uw;

					if(i_pstStGrpParam->wKi_Uw!=pstStPara_MailboxAlternate_Deputy->wKi_Uw)
					{
						i_pstStGrpParam->wKi_Uw= pstStPara_MailboxAlternate_Deputy->wKi_Uw;
					}
					wKi_Uw_Rec= i_pstStGrpParam->wKi_Uw;

					if(i_pstStGrpParam->wKd_Uw!=pstStPara_MailboxAlternate_Deputy->wKd_Uw)
					{
						i_pstStGrpParam->wKd_Uw= pstStPara_MailboxAlternate_Deputy->wKd_Uw;
					}
					wKd_Uw_Rec= i_pstStGrpParam->wKd_Uw;

					if(i_pstStGrpParam->wKp_If!=pstStPara_MailboxAlternate_Deputy->wKp_If)
					{
						i_pstStGrpParam->wKp_If= pstStPara_MailboxAlternate_Deputy->wKp_If;
					}
					wKp_If_Rec= i_pstStGrpParam->wKp_If;

					if(i_pstStGrpParam->wKi_If!=pstStPara_MailboxAlternate_Deputy->wKi_If)
					{
						i_pstStGrpParam->wKi_If= pstStPara_MailboxAlternate_Deputy->wKi_If;
					}
					wKi_If_Rec= i_pstStGrpParam->wKi_If;

					if(i_pstStGrpParam->wKd_If!=pstStPara_MailboxAlternate_Deputy->wKd_If)
					{
						i_pstStGrpParam->wKd_If= pstStPara_MailboxAlternate_Deputy->wKd_If;
					}
					wKd_If_Rec= i_pstStGrpParam->wKd_If;

					if(i_pstStGrpParam->bySwitch_AutoCut_Uw!=pstStPara_MailboxAlternate_Deputy->bySwitch_AutoCut_Uw)
					{
						i_pstStGrpParam->bySwitch_AutoCut_Uw= pstStPara_MailboxAlternate_Deputy->bySwitch_AutoCut_Uw;
					}
					bySwitch_AutoCut_Uw_Rec= i_pstStGrpParam->bySwitch_AutoCut_Uw;

					if(i_pstStGrpParam->iDia_PaperRoller_Uw!=pstStPara_MailboxAlternate_Deputy->iDia_PaperRoller_Uw)
					{
						i_pstStGrpParam->iDia_PaperRoller_Uw= pstStPara_MailboxAlternate_Deputy->iDia_PaperRoller_Uw;
					}
					iDia_PaperRoller_Uw_Rec= i_pstStGrpParam->iDia_PaperRoller_Uw;

					if(i_pstStGrpParam->iFilmThickNess!=pstStPara_MailboxAlternate_Deputy->iFilmThickNess)
					{
						i_pstStGrpParam->iFilmThickNess= pstStPara_MailboxAlternate_Deputy->iFilmThickNess;
					}
					iFilmThickNess_Rec= i_pstStGrpParam->iFilmThickNess;

					if(i_pstStGrpParam->wAutoMaticCutDia_Uw!=pstStPara_MailboxAlternate_Deputy->wAutoMaticCutDia_Uw)
					{
						i_pstStGrpParam->wAutoMaticCutDia_Uw= pstStPara_MailboxAlternate_Deputy->wAutoMaticCutDia_Uw;
					}
					wAutoMaticCutDia_Uw_Rec= i_pstStGrpParam->wAutoMaticCutDia_Uw;

					if(i_pstStGrpParam->wAutoMaticCutMeters_Uw!=pstStPara_MailboxAlternate_Deputy->wAutoMaticCutMeters_Uw)
					{
						i_pstStGrpParam->wAutoMaticCutMeters_Uw= pstStPara_MailboxAlternate_Deputy->wAutoMaticCutMeters_Uw;
					}
					wAutoMaticCutMeters_Uw_Rec= i_pstStGrpParam->wAutoMaticCutMeters_Uw;

					if(i_pstStGrpParam->wActRemainFilmLenth_Uw!=pstStPara_MailboxAlternate_Deputy->wActRemainFilmLenth_Uw)
					{
						i_pstStGrpParam->wActRemainFilmLenth_Uw= pstStPara_MailboxAlternate_Deputy->wActRemainFilmLenth_Uw;
					}
					wActRemainFilmLenth_Uw_Rec= i_pstStGrpParam->wActRemainFilmLenth_Uw;

					if(i_pstStGrpParam->iAlarm_Uw_Dia!=pstStPara_MailboxAlternate_Deputy->iAlarm_Uw_Dia)
					{
						i_pstStGrpParam->iAlarm_Uw_Dia= pstStPara_MailboxAlternate_Deputy->iAlarm_Uw_Dia;
					}
					iAlarm_Uw_Dia_Rec= i_pstStGrpParam->iAlarm_Uw_Dia;

					if(i_pstStGrpParam->iDelayMsec_CutterHolder!=pstStPara_MailboxAlternate_Deputy->iDelayMsec_CutterHolder)
					{
						i_pstStGrpParam->iDelayMsec_CutterHolder= pstStPara_MailboxAlternate_Deputy->iDelayMsec_CutterHolder;
					}
					iDelayMsec_CutterHolder_Rec= i_pstStGrpParam->iDelayMsec_CutterHolder;

					if(i_pstStGrpParam->iDelayMsec_RollerCylinder!=pstStPara_MailboxAlternate_Deputy->iDelayMsec_RollerCylinder)
					{
						i_pstStGrpParam->iDelayMsec_RollerCylinder= pstStPara_MailboxAlternate_Deputy->iDelayMsec_RollerCylinder;
					}
					iDelayMsec_RollerCylinder_Rec= i_pstStGrpParam->iDelayMsec_RollerCylinder;

					if(i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder!=pstStPara_MailboxAlternate_Deputy->iDelayMsec_CutOffKnifeCylinder)
					{
						i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder= pstStPara_MailboxAlternate_Deputy->iDelayMsec_CutOffKnifeCylinder;
					}
					iDelayMsec_CutOffKnifeCylinder_Rec= i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder;

					if(i_pstStGrpParam->uiMM_Roller2GummedTape!=pstStPara_MailboxAlternate_Deputy->uiMM_Roller2GummedTape)
					{
						i_pstStGrpParam->uiMM_Roller2GummedTape= pstStPara_MailboxAlternate_Deputy->uiMM_Roller2GummedTape;
					}
					uiMM_Roller2GummedTape_Rec= i_pstStGrpParam->uiMM_Roller2GummedTape;

					if(i_pstStGrpParam->uiMM_Roller2CutOfKnife!=pstStPara_MailboxAlternate_Deputy->uiMM_Roller2CutOfKnife)
					{
						i_pstStGrpParam->uiMM_Roller2CutOfKnife= pstStPara_MailboxAlternate_Deputy->uiMM_Roller2CutOfKnife;
					}
					uiMM_Roller2CutOfKnife_Rec= i_pstStGrpParam->uiMM_Roller2CutOfKnife;

					if(i_pstStGrpParam->uiMM_CutOfKnife2GummedTape!=pstStPara_MailboxAlternate_Deputy->uiMM_CutOfKnife2GummedTape)
					{
						i_pstStGrpParam->uiMM_CutOfKnife2GummedTape= pstStPara_MailboxAlternate_Deputy->uiMM_CutOfKnife2GummedTape;
					}
					uiMM_CutOfKnife2GummedTape_Rec= i_pstStGrpParam->uiMM_CutOfKnife2GummedTape;

					if(i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw!=pstStPara_MailboxAlternate_Deputy->iCoefCut_FilmVolPerimeter_Uw)
					{
						i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw= pstStPara_MailboxAlternate_Deputy->iCoefCut_FilmVolPerimeter_Uw;
					}
					iCoefCut_FilmVolPerimeter_Uw_Rec= i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw;

					if(i_pstStGrpParam->iStepVariation4ChangeTime!=pstStPara_MailboxAlternate_Deputy->iStepVariation4ChangeTime)
					{
						i_pstStGrpParam->iStepVariation4ChangeTime= pstStPara_MailboxAlternate_Deputy->iStepVariation4ChangeTime;
					}
					iStepVariation4ChangeTime_Rec= i_pstStGrpParam->iStepVariation4ChangeTime;

					if(i_pstStGrpParam->bySwitch_Compensate_Uw!=pstStPara_MailboxAlternate_Deputy->bySwitch_Compensate_Uw)
					{
						i_pstStGrpParam->bySwitch_Compensate_Uw= pstStPara_MailboxAlternate_Deputy->bySwitch_Compensate_Uw;
					}
					bySwitch_Compensate_Uw_Rec= i_pstStGrpParam->bySwitch_Compensate_Uw;

					if(i_pstStGrpParam->wDiam_Tower_Uw!=pstStPara_MailboxAlternate_Deputy->wDiam_Tower_Uw)
					{
						i_pstStGrpParam->wDiam_Tower_Uw= pstStPara_MailboxAlternate_Deputy->wDiam_Tower_Uw;
					}
					wDiam_Tower_Uw_Rec= i_pstStGrpParam->wDiam_Tower_Uw;

					if(i_pstStGrpParam->wDiam_NextRoller_Uw!=pstStPara_MailboxAlternate_Deputy->wDiam_NextRoller_Uw)
					{
						i_pstStGrpParam->wDiam_NextRoller_Uw= pstStPara_MailboxAlternate_Deputy->wDiam_NextRoller_Uw;
					}
					wDiam_NextRoller_Uw_Rec= i_pstStGrpParam->wDiam_NextRoller_Uw;

					if(i_pstStGrpParam->wXPos_NextRoller_Uw!=pstStPara_MailboxAlternate_Deputy->wXPos_NextRoller_Uw)
					{
						i_pstStGrpParam->wXPos_NextRoller_Uw= pstStPara_MailboxAlternate_Deputy->wXPos_NextRoller_Uw;
					}
					wXPos_NextRoller_Uw_Rec= i_pstStGrpParam->wXPos_NextRoller_Uw;

					if(i_pstStGrpParam->wYPos_NextRoller_Uw!=pstStPara_MailboxAlternate_Deputy->wYPos_NextRoller_Uw)
					{
						i_pstStGrpParam->wYPos_NextRoller_Uw= pstStPara_MailboxAlternate_Deputy->wYPos_NextRoller_Uw;
					}
					wYPos_NextRoller_Uw_Rec= i_pstStGrpParam->wYPos_NextRoller_Uw;

					if(i_pstStGrpParam->wDiam_DeflectorRoller_Uw!=pstStPara_MailboxAlternate_Deputy->wDiam_DeflectorRoller_Uw)
					{
						i_pstStGrpParam->wDiam_DeflectorRoller_Uw= pstStPara_MailboxAlternate_Deputy->wDiam_DeflectorRoller_Uw;
					}
					wDiam_DeflectorRoller_Uw_Rec= i_pstStGrpParam->wDiam_DeflectorRoller_Uw;

					if(i_pstStGrpParam->wDiam_DeflectorRollPos_Uw!=pstStPara_MailboxAlternate_Deputy->wDiam_DeflectorRollPos_Uw)
					{
						i_pstStGrpParam->wDiam_DeflectorRollPos_Uw= pstStPara_MailboxAlternate_Deputy->wDiam_DeflectorRollPos_Uw;
					}
					wDiam_DeflectorRollPos_Uw_Rec= i_pstStGrpParam->wDiam_DeflectorRollPos_Uw;

					if(i_pstStGrpParam->byDiamMeasureTypeId!=pstStPara_MailboxAlternate_Deputy->byDiamMeasureTypeId)
					{
						i_pstStGrpParam->byDiamMeasureTypeId= pstStPara_MailboxAlternate_Deputy->byDiamMeasureTypeId;
					}
					byDiamMeasureTypeId_Rec= i_pstStGrpParam->byDiamMeasureTypeId;

					if(i_pstStGrpParam->byDiamMeasureTypeId!=pstStPara_MailboxAlternate_Deputy->byDiamMeasureTypeId)
					{
						i_pstStGrpParam->byDiamMeasureTypeId= pstStPara_MailboxAlternate_Deputy->byDiamMeasureTypeId;
					}
					byDiamMeasureTypeId_Rec= i_pstStGrpParam->byDiamMeasureTypeId;

					if(i_pstStGrpParam->iStdVol_Diam_1!=pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_1)
					{
						i_pstStGrpParam->iStdVol_Diam_1= pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_1;
					}
					iStdVol_Diam_1_Rec= i_pstStGrpParam->iStdVol_Diam_1;

					if(i_pstStGrpParam->iStdVol_Diam_2!=pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_2)
					{
						i_pstStGrpParam->iStdVol_Diam_2= pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_2;
					}
					iStdVol_Diam_2_Rec= i_pstStGrpParam->iStdVol_Diam_2;

					if(i_pstStGrpParam->iStdVol_Diam_3!=pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_3)
					{
						i_pstStGrpParam->iStdVol_Diam_3= pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_3;
					}
					iStdVol_Diam_3_Rec= i_pstStGrpParam->iStdVol_Diam_3;

					if(i_pstStGrpParam->iStdVol_Diam_4!=pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_4)
					{
						i_pstStGrpParam->iStdVol_Diam_4= pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_4;
					}
					iStdVol_Diam_4_Rec= i_pstStGrpParam->iStdVol_Diam_4;

					if(i_pstStGrpParam->dwStdVol_Volt_AxisA_1!=pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_1)
					{
						i_pstStGrpParam->dwStdVol_Volt_AxisA_1= pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_1;
					}
					dwStdVol_Volt_AxisA_1_Rec= i_pstStGrpParam->dwStdVol_Volt_AxisA_1;

					if(i_pstStGrpParam->dwStdVol_Volt_AxisA_2!=pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_2)
					{
						i_pstStGrpParam->dwStdVol_Volt_AxisA_2= pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_2;
					}
					dwStdVol_Volt_AxisA_2_Rec= i_pstStGrpParam->dwStdVol_Volt_AxisA_2;

					if(i_pstStGrpParam->dwStdVol_Volt_AxisA_3!=pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_3)
					{
						i_pstStGrpParam->dwStdVol_Volt_AxisA_3= pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_3;
					}
					dwStdVol_Volt_AxisA_3_Rec= i_pstStGrpParam->dwStdVol_Volt_AxisA_3;

					if(i_pstStGrpParam->dwStdVol_Volt_AxisA_4!=pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_4)
					{
						i_pstStGrpParam->dwStdVol_Volt_AxisA_4= pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_4;
					}
					dwStdVol_Volt_AxisA_4_Rec= i_pstStGrpParam->dwStdVol_Volt_AxisA_4;

					if(i_pstStGrpParam->iStdVol_Coef_Axis_1!=pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_1)
					{
						i_pstStGrpParam->iStdVol_Coef_Axis_1= pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_1;
					}
					iStdVol_Coef_Axis_1_Rec= i_pstStGrpParam->iStdVol_Coef_Axis_1;

					if(i_pstStGrpParam->iStdVol_Coef_Axis_2!=pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_2)
					{
						i_pstStGrpParam->iStdVol_Coef_Axis_2= pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_2;
					}
					iStdVol_Coef_Axis_2_Rec= i_pstStGrpParam->iStdVol_Coef_Axis_2;

					if(i_pstStGrpParam->iStdVol_Coef_Axis_3!=pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_3)
					{
						i_pstStGrpParam->iStdVol_Coef_Axis_3= pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_3;
					}
					iStdVol_Coef_Axis_3_Rec= i_pstStGrpParam->iStdVol_Coef_Axis_3;

					if(i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw!=pstStPara_MailboxAlternate_Deputy->byIsDebug_DiaMeasureArea_Uw)
					{
						i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw= pstStPara_MailboxAlternate_Deputy->byIsDebug_DiaMeasureArea_Uw;
					}
					byIsDebug_DiaMeasureArea_Uw_Rec= i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw;

					if(i_pstStGrpParam->bySwitch_DiaMeasure!=pstStPara_MailboxAlternate_Deputy->bySwitch_DiaMeasure)
					{
						i_pstStGrpParam->bySwitch_DiaMeasure= pstStPara_MailboxAlternate_Deputy->bySwitch_DiaMeasure;
					}
					bySwitch_DiaMeasure_Rec= i_pstStGrpParam->bySwitch_DiaMeasure;

					if(i_pstStGrpParam->bySwitch_Enc_Uw!=pstStPara_MailboxAlternate_Deputy->bySwitch_Enc_Uw)
					{
						i_pstStGrpParam->bySwitch_Enc_Uw= pstStPara_MailboxAlternate_Deputy->bySwitch_Enc_Uw;
					}
					bySwitch_Enc_Uw_Rec= i_pstStGrpParam->bySwitch_Enc_Uw;

					//2023.09.18.160336
					if(i_pstStGrpParam->wButton_Uw !=pstStPara_MailboxAlternate_Deputy->wButton_Uw)
					{
						i_pstStGrpParam->wButton_Uw= pstStPara_MailboxAlternate_Deputy->wButton_Uw;
					}
					wButton_Uw_Rec= i_pstStGrpParam->wButton_Uw;

					//(*--------------------------------------------------|2019.8.28.111442_*)
					//(*如果有数据下来|就把横向快速对版量清除掉|*)
					//(*i_piJourney_HorzRapidAdjust^:= 0;*)

					//(*--------------------------------------------------|2017.8.3.234123_*)
					//(*清除旗语|*)
					adwBuf[0]= 0;
					adwBuf[1]= 0;
					//2025.12.1.094650 增加停止mail通讯标志控制
					if(!i_pstStGlobalParam->xStopMailComm)
						GT_RN_DevicePcMailComWr((unsigned long*)&adwBuf[0], 0, iStationId*gc_iMailboxBlockLen, 2, 1, 1);

					//2020.6.8.202844||mailbox下行通讯完成
					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 0);
 				}
 				else if(pstStPara_MailboxAlternate_Deputy->dwSyncFlag==gc_dwSemaphoreRequestDispatch)
 				{
 					iCountdownRedispatchReq= 0;//(*请求主站重新派发1次本站点的参数*)
 				}
 				else
 				{
					//(*包含了上行在内|*)
					//(*检查是否需要上报|如果有数据改变 之前的上行数据就可以覆盖掉了|*)
					if(xGetCopyFromSrvOk && *i_pxGetParam)//(*如果已经从服务器获取到了数据则可以检查和本地的变化了|*)
					{
							iCountdownRedispatchReq= 0;//(*计数周期|*)
							dwParaUpdateFlag= 0;//(*每位用来表示1项参数内容的改变状态|*)
							dwParaUpdateFlag_1= 0;//2022.3.19.170804新增变量判断

							if(iGirth_Uw_A_Rec!=i_pstStGrpParam->iGirth_Uw_A)
							{
								dwParaUpdateFlag|= 1<<0;
							}

							if(iGirth_Uw_B_Rec!=i_pstStGrpParam->iGirth_Uw_B)
							{
								dwParaUpdateFlag|= 1<<1;
							}

							if(iGirth_Pu_Rec!=i_pstStGrpParam->iGirth_Pu)
							{
								dwParaUpdateFlag|= 1<<2;
							}
							if(iVelocity_Tar_Rec!=i_pstStGrpParam->iVelocity_Tar)
							{
								dwParaUpdateFlag|= 1<<3;
							}

							if(iAI_mid_Uw_Rec!=i_pstStGrpParam->iAI_mid_Uw)
							{
								dwParaUpdateFlag|= 1<<4;
							}

							if(iAI_mid_If_Rec!=i_pstStGrpParam->iAI_mid_If)
							{
								dwParaUpdateFlag|= 1<<5;
							}

							if(byDir_Uw_If_AI_Rec!=i_pstStGrpParam->byDir_Uw_If_AI)
							{
								dwParaUpdateFlag|= 1<<6;
							}

							if(wKp_Uw_Rec!=i_pstStGrpParam->wKp_Uw)
							{
								dwParaUpdateFlag|= 1<<7;
							}

							if(wKi_Uw_Rec!=i_pstStGrpParam->wKi_Uw)
							{
								dwParaUpdateFlag|= 1<<8;
							}

							if(wKd_Uw_Rec!=i_pstStGrpParam->wKd_Uw)
							{
								dwParaUpdateFlag|= 1<<9;
							}

							if(wKp_If_Rec!=i_pstStGrpParam->wKp_If)
							{
								dwParaUpdateFlag|= 1<<10;
							}

							if(wKi_If_Rec!=i_pstStGrpParam->wKi_If)
							{
								dwParaUpdateFlag|= 1<<11;
							}

							if(wKd_If_Rec!=i_pstStGrpParam->wKd_If)
							{
								dwParaUpdateFlag|= 1<<12;
							}

							if(bySwitch_AutoCut_Uw_Rec!=i_pstStGrpParam->bySwitch_AutoCut_Uw)
							{
								dwParaUpdateFlag|= 1<<13;
							}

							if(iDia_PaperRoller_Uw_Rec!=i_pstStGrpParam->iDia_PaperRoller_Uw)
							{
								dwParaUpdateFlag|= 1<<14;
							}

							if(iFilmThickNess_Rec!=i_pstStGrpParam->iFilmThickNess)
							{
								dwParaUpdateFlag|= 1<<15;
							}

							if(wAutoMaticCutDia_Uw_Rec!=i_pstStGrpParam->wAutoMaticCutDia_Uw)
							{
								dwParaUpdateFlag|= 1<<16;
							}

							if(wAutoMaticCutMeters_Uw_Rec!=i_pstStGrpParam->wAutoMaticCutMeters_Uw)
							{
								dwParaUpdateFlag|= 1<<17;
							}

							if(wActRemainFilmLenth_Uw_Rec!=i_pstStGrpParam->wActRemainFilmLenth_Uw)
							{
								dwParaUpdateFlag|= 1<<18;
							}

							if(iAlarm_Uw_Dia_Rec!=i_pstStGrpParam->iAlarm_Uw_Dia)
							{
								dwParaUpdateFlag|= 1<<19;
							}

							if(iDelayMsec_CutterHolder_Rec!=i_pstStGrpParam->iDelayMsec_CutterHolder)
							{
								dwParaUpdateFlag|= 1<<20;
							}

							if(iDelayMsec_RollerCylinder_Rec!=i_pstStGrpParam->iDelayMsec_RollerCylinder)
							{
								dwParaUpdateFlag|= 1<<21;
							}

							if(iDelayMsec_CutOffKnifeCylinder_Rec!=i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder)
							{
								dwParaUpdateFlag|= 1<<22;
							}

							if(uiMM_Roller2GummedTape_Rec!=i_pstStGrpParam->uiMM_Roller2GummedTape)
							{
								dwParaUpdateFlag|= 1<<23;
							}

							if(uiMM_Roller2CutOfKnife_Rec!=i_pstStGrpParam->uiMM_Roller2CutOfKnife)
							{
								dwParaUpdateFlag|= 1<<24;
							}

							if(uiMM_CutOfKnife2GummedTape_Rec!=i_pstStGrpParam->uiMM_CutOfKnife2GummedTape)
							{
								dwParaUpdateFlag|= 1<<25;
							}

							if(iCoefCut_FilmVolPerimeter_Uw_Rec!=i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw)
							{
								dwParaUpdateFlag|= 1<<26;
							}

							if(iStepVariation4ChangeTime_Rec!=i_pstStGrpParam->iStepVariation4ChangeTime)
							{
								dwParaUpdateFlag|= 1<<27;
							}

							if(bySwitch_Compensate_Uw_Rec!=i_pstStGrpParam->bySwitch_Compensate_Uw)
							{
								dwParaUpdateFlag|= 1<<28;
							}

							if(wDiam_Tower_Uw_Rec!=i_pstStGrpParam->wDiam_Tower_Uw)
							{
								dwParaUpdateFlag|= 1<<29;
							}

							if(wDiam_NextRoller_Uw_Rec!=i_pstStGrpParam->wDiam_NextRoller_Uw)
							{
								dwParaUpdateFlag|= 1<<30;
							}

							if(wXPos_NextRoller_Uw_Rec!=i_pstStGrpParam->wXPos_NextRoller_Uw)
							{
								dwParaUpdateFlag_1|= 1<<0;
							}

							if(wYPos_NextRoller_Uw_Rec!=i_pstStGrpParam->wYPos_NextRoller_Uw)
							{
								dwParaUpdateFlag_1|= 1<<1;
							}

							if(wDiam_DeflectorRoller_Uw_Rec!=i_pstStGrpParam->wDiam_DeflectorRoller_Uw)
							{
								dwParaUpdateFlag_1|= 1<<2;
							}

							if(wDiam_DeflectorRollPos_Uw_Rec!=i_pstStGrpParam->wDiam_DeflectorRollPos_Uw)
							{
								dwParaUpdateFlag_1|= 1<<3;
							}

							if(byDiamMeasureTypeId_Rec!=i_pstStGrpParam->byDiamMeasureTypeId)
							{
								dwParaUpdateFlag_1|= 1<<4;
							}

							if(iStdVol_Diam_1_Rec!=i_pstStGrpParam->iStdVol_Diam_1)
							{
								dwParaUpdateFlag_1|= 1<<5;
							}

							if(iStdVol_Diam_2_Rec!=i_pstStGrpParam->iStdVol_Diam_2)
							{
								dwParaUpdateFlag_1|= 1<<6;
							}

							if(iStdVol_Diam_3_Rec!=i_pstStGrpParam->iStdVol_Diam_3)
							{
								dwParaUpdateFlag_1|= 1<<7;
							}

							if(iStdVol_Diam_4_Rec!=i_pstStGrpParam->iStdVol_Diam_4)
							{
								dwParaUpdateFlag_1|= 1<<8;
							}

							if(dwStdVol_Volt_AxisA_1_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_1)
							{
								dwParaUpdateFlag_1|= 1<<9;
							}

							if(dwStdVol_Volt_AxisA_2_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_2)
							{
								dwParaUpdateFlag_1|= 1<<10;
							}

							if(dwStdVol_Volt_AxisA_3_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_3)
							{
								dwParaUpdateFlag_1|= 1<<11;
							}

							if(dwStdVol_Volt_AxisA_4_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_4)
							{
								dwParaUpdateFlag_1|= 1<<12;
							}

							if(iStdVol_Coef_Axis_1_Rec!=i_pstStGrpParam->iStdVol_Coef_Axis_1)
							{
								dwParaUpdateFlag_1|= 1<<13;
							}

							if(iStdVol_Coef_Axis_2_Rec!=i_pstStGrpParam->iStdVol_Coef_Axis_2)
							{
								dwParaUpdateFlag_1|= 1<<14;
							}

							if(iStdVol_Coef_Axis_3_Rec!=i_pstStGrpParam->iStdVol_Coef_Axis_3)
							{
								dwParaUpdateFlag_1|= 1<<15;
							}

							if(byIsDebug_DiaMeasureArea_Uw_Rec!=i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw)
							{
								dwParaUpdateFlag_1|= 1<<16;
							}

							if(bySwitch_DiaMeasure_Rec!=i_pstStGrpParam->bySwitch_DiaMeasure)
							{
								dwParaUpdateFlag_1|= 1<<17;//16;//修改为了左移17bit
							}

							if(bySwitch_Enc_Uw_Rec!=i_pstStGrpParam->bySwitch_Enc_Uw)
							{
								dwParaUpdateFlag_1|= 1<<18;//;//修改为了左移18bit
							}
							//2023.09.18.160841 同步
							if(wButton_Uw_Rec!=i_pstStGrpParam->wButton_Uw)
							{
								dwParaUpdateFlag_1|= 1<<19;
							}

							if((dwParaUpdateFlag!=0) || (dwParaUpdateFlag_1!=0))
								//(*--------------------------------------------------|2019.4.2.191314_*)
							{
								for(iN=0;iN<gc_iMailboxBlockLen;iN++)
								{
									abyBuf[iN]=0;
								}
		//						memset(&abyBuf[0], 0, sizeof(abyBuf));memset是否支持
								pstStPara_MailboxAlternate_Deputy= (StPara_MailboxAlternate_Deputy*)(&abyBuf[0]);

								pstStPara_MailboxAlternate_Deputy->dwSyncFlag= gc_dwSemaphoreUpLink;
								pstStPara_MailboxAlternate_Deputy->iGirth_Uw_A						  =  i_pstStGrpParam->iGirth_Uw_A												;
								pstStPara_MailboxAlternate_Deputy->iGirth_Uw_B						  =  i_pstStGrpParam->iGirth_Uw_B						  ;
								pstStPara_MailboxAlternate_Deputy->iGirth_Pu						  =  i_pstStGrpParam->iGirth_Pu						  ;
								pstStPara_MailboxAlternate_Deputy->iVelocity_Tar					  =  i_pstStGrpParam->iVelocity_Tar					  ;
								pstStPara_MailboxAlternate_Deputy->iAI_mid_Uw						  =  i_pstStGrpParam->iAI_mid_Uw						 ;
								pstStPara_MailboxAlternate_Deputy->iAI_mid_If						  =  i_pstStGrpParam->iAI_mid_If						 ;
								pstStPara_MailboxAlternate_Deputy->byDir_Uw_If_AI					  =  i_pstStGrpParam->byDir_Uw_If_AI					 ;
								pstStPara_MailboxAlternate_Deputy->wKp_Uw							  =  i_pstStGrpParam->wKp_Uw							  ;
								pstStPara_MailboxAlternate_Deputy->wKi_Uw							  =  i_pstStGrpParam->wKi_Uw							  ;
								pstStPara_MailboxAlternate_Deputy->wKd_Uw							  =  i_pstStGrpParam->wKd_Uw							  ;
								pstStPara_MailboxAlternate_Deputy->wKp_If							  =  i_pstStGrpParam->wKp_If							  ;
								pstStPara_MailboxAlternate_Deputy->wKi_If							  =  i_pstStGrpParam->wKi_If							  ;
								pstStPara_MailboxAlternate_Deputy->wKd_If							  =  i_pstStGrpParam->wKd_If							  ;
								pstStPara_MailboxAlternate_Deputy->bySwitch_AutoCut_Uw				  =  i_pstStGrpParam->bySwitch_AutoCut_Uw				  ;
								pstStPara_MailboxAlternate_Deputy->iDia_PaperRoller_Uw				  =  i_pstStGrpParam->iDia_PaperRoller_Uw				 ;
								pstStPara_MailboxAlternate_Deputy->iFilmThickNess					  =  i_pstStGrpParam->iFilmThickNess					  ;
								pstStPara_MailboxAlternate_Deputy->wAutoMaticCutDia_Uw				  =  i_pstStGrpParam->wAutoMaticCutDia_Uw				  ;
								pstStPara_MailboxAlternate_Deputy->wAutoMaticCutMeters_Uw			  =  i_pstStGrpParam->wAutoMaticCutMeters_Uw			  ;
								pstStPara_MailboxAlternate_Deputy->wActRemainFilmLenth_Uw			  =  i_pstStGrpParam->wActRemainFilmLenth_Uw			 ;
								pstStPara_MailboxAlternate_Deputy->iAlarm_Uw_Dia			  		  =  i_pstStGrpParam->iAlarm_Uw_Dia ;//: INT			 ;
								pstStPara_MailboxAlternate_Deputy->iDelayMsec_CutterHolder			  =  i_pstStGrpParam->iDelayMsec_CutterHolder					;
								pstStPara_MailboxAlternate_Deputy->iDelayMsec_RollerCylinder		  =  i_pstStGrpParam->iDelayMsec_RollerCylinder								;
								pstStPara_MailboxAlternate_Deputy->iDelayMsec_CutOffKnifeCylinder	  =  i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder	  ;
								pstStPara_MailboxAlternate_Deputy->uiMM_Roller2GummedTape			  =  i_pstStGrpParam->uiMM_Roller2GummedTape			  ;
								pstStPara_MailboxAlternate_Deputy->uiMM_Roller2CutOfKnife			  =  i_pstStGrpParam->uiMM_Roller2CutOfKnife			  ;
								pstStPara_MailboxAlternate_Deputy->uiMM_CutOfKnife2GummedTape		  =  i_pstStGrpParam->uiMM_CutOfKnife2GummedTape		 ;
								pstStPara_MailboxAlternate_Deputy->iCoefCut_FilmVolPerimeter_Uw	  	  =  i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw	 ;
								pstStPara_MailboxAlternate_Deputy->iStepVariation4ChangeTime		  =  i_pstStGrpParam->iStepVariation4ChangeTime		 ;
								pstStPara_MailboxAlternate_Deputy->bySwitch_Compensate_Uw			  =  i_pstStGrpParam->bySwitch_Compensate_Uw			  ;
								pstStPara_MailboxAlternate_Deputy->wDiam_Tower_Uw					  =  i_pstStGrpParam->wDiam_Tower_Uw					  ;
								pstStPara_MailboxAlternate_Deputy->wDiam_NextRoller_Uw				  =  i_pstStGrpParam->wDiam_NextRoller_Uw				  ;
								pstStPara_MailboxAlternate_Deputy->wXPos_NextRoller_Uw				  =  i_pstStGrpParam->wXPos_NextRoller_Uw				  ;
								pstStPara_MailboxAlternate_Deputy->wYPos_NextRoller_Uw				  =  i_pstStGrpParam->wYPos_NextRoller_Uw				  ;
								pstStPara_MailboxAlternate_Deputy->wDiam_DeflectorRoller_Uw		  	  =  i_pstStGrpParam->wDiam_DeflectorRoller_Uw		  ;
								pstStPara_MailboxAlternate_Deputy->wDiam_DeflectorRollPos_Uw		  =  i_pstStGrpParam->wDiam_DeflectorRollPos_Uw		  ;
								pstStPara_MailboxAlternate_Deputy->byDiamMeasureTypeId				  =  i_pstStGrpParam->byDiamMeasureTypeId				 ;
								pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_1					  =  i_pstStGrpParam->iStdVol_Diam_1					  ;
								pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_2					  =  i_pstStGrpParam->iStdVol_Diam_2					  ;
								pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_3					  =  i_pstStGrpParam->iStdVol_Diam_3					  ;
								pstStPara_MailboxAlternate_Deputy->iStdVol_Diam_4					  =  i_pstStGrpParam->iStdVol_Diam_4					 ;
								pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_1			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_1			 ;
								pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_2			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_2					;
								pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_3			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_3					;
								pstStPara_MailboxAlternate_Deputy->dwStdVol_Volt_AxisA_4			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_4					;
								pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_1				  =  i_pstStGrpParam->iStdVol_Coef_Axis_1						;
								pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_2				  =  i_pstStGrpParam->iStdVol_Coef_Axis_2						;
								pstStPara_MailboxAlternate_Deputy->iStdVol_Coef_Axis_3				  =  i_pstStGrpParam->iStdVol_Coef_Axis_3						;
								pstStPara_MailboxAlternate_Deputy->byIsDebug_DiaMeasureArea_Uw		  =  i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw				;
								pstStPara_MailboxAlternate_Deputy->bySwitch_DiaMeasure				  =  i_pstStGrpParam->bySwitch_DiaMeasure						;
								pstStPara_MailboxAlternate_Deputy->bySwitch_Enc_Uw					  =  i_pstStGrpParam->bySwitch_Enc_Uw							;
								pstStPara_MailboxAlternate_Deputy->wButton_Uw					 	  =  i_pstStGrpParam->wButton_Uw							;//2023.09.18.160943

								//(*--------------------------------------------------|2019.4.2.191518_*)
								//(*计算报文中的DWORD数量|*)
								dwPayloadLen= sizeof(*pstStPara_MailboxAlternate_Deputy);
								wDWordNum= (WORD)(dwPayloadLen/sizeof(dwPayloadLen));
								if((dwPayloadLen % sizeof(dwPayloadLen))!=0)
								{
									wDWordNum= wDWordNum+1;
								}

								//(*--------------------------------------------------|2019.8.28.110536_*)
								//(*GT指令开始发送|*)
	 							//2025.12.1.094650 增加停止mail通讯标志控制
	 							if(!i_pstStGlobalParam->xStopMailComm)
	 								aiRtnCode[0]= GT_RN_DevicePcMailComWr((unsigned long*)&(abyBuf[0]), 0, iStationId*gc_iMailboxBlockLen, wDWordNum, 1, 1);
								if(aiRtnCode[0]==0)
								{
									iGirth_Uw_A_Rec						  =  i_pstStGrpParam->iGirth_Uw_A												;
									iGirth_Uw_B_Rec						  =  i_pstStGrpParam->iGirth_Uw_B						  	;
									iGirth_Pu_Rec						  =  i_pstStGrpParam->iGirth_Pu						  		;
									iVelocity_Tar_Rec					  =  i_pstStGrpParam->iVelocity_Tar					  		;
									iAI_mid_Uw_Rec						  =  i_pstStGrpParam->iAI_mid_Uw						 	;
									iAI_mid_If_Rec						  =  i_pstStGrpParam->iAI_mid_If						 	;
									byDir_Uw_If_AI_Rec					  =  i_pstStGrpParam->byDir_Uw_If_AI					 	;
									wKp_Uw_Rec							  =  i_pstStGrpParam->wKp_Uw							  	;
									wKi_Uw_Rec							  =  i_pstStGrpParam->wKi_Uw							  	;
									wKd_Uw_Rec							  =  i_pstStGrpParam->wKd_Uw							  	;
									wKp_If_Rec							  =  i_pstStGrpParam->wKp_If							 	;
									wKi_If_Rec							  =  i_pstStGrpParam->wKi_If							 	;
									wKd_If_Rec							  =  i_pstStGrpParam->wKd_If							 	;
									bySwitch_AutoCut_Uw_Rec				  =  i_pstStGrpParam->bySwitch_AutoCut_Uw				  	;
									iDia_PaperRoller_Uw_Rec				  =  i_pstStGrpParam->iDia_PaperRoller_Uw				 	;
									iFilmThickNess_Rec					  =  i_pstStGrpParam->iFilmThickNess					 	;
									wAutoMaticCutDia_Uw_Rec				  =  i_pstStGrpParam->wAutoMaticCutDia_Uw				  	;
									wAutoMaticCutMeters_Uw_Rec			  =  i_pstStGrpParam->wAutoMaticCutMeters_Uw			  	;
									wActRemainFilmLenth_Uw_Rec			  =  i_pstStGrpParam->wActRemainFilmLenth_Uw			 	;
									iAlarm_Uw_Dia_Rec 			  =  i_pstStGrpParam->iAlarm_Uw_Dia ;//: INT			 ;
									iDelayMsec_CutterHolder_Rec			  =  i_pstStGrpParam->iDelayMsec_CutterHolder				;
									iDelayMsec_RollerCylinder_Rec		  =  i_pstStGrpParam->iDelayMsec_RollerCylinder				;
									iDelayMsec_CutOffKnifeCylinder_Rec	  =  i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder	  ;
									uiMM_Roller2GummedTape_Rec			  =  i_pstStGrpParam->uiMM_Roller2GummedTape			  ;
									uiMM_Roller2CutOfKnife_Rec			  =  i_pstStGrpParam->uiMM_Roller2CutOfKnife			  ;
									uiMM_CutOfKnife2GummedTape_Rec		  =  i_pstStGrpParam->uiMM_CutOfKnife2GummedTape		  ;
									iCoefCut_FilmVolPerimeter_Uw_Rec	  =  i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw	      ;
									iStepVariation4ChangeTime_Rec		  =  i_pstStGrpParam->iStepVariation4ChangeTime		      ;
									bySwitch_Compensate_Uw_Rec			  =  i_pstStGrpParam->bySwitch_Compensate_Uw			  ;
									wDiam_Tower_Uw_Rec					  =  i_pstStGrpParam->wDiam_Tower_Uw					  ;
									wDiam_NextRoller_Uw_Rec				  =  i_pstStGrpParam->wDiam_NextRoller_Uw				  ;
									wXPos_NextRoller_Uw_Rec				  =  i_pstStGrpParam->wXPos_NextRoller_Uw				  ;
									wYPos_NextRoller_Uw_Rec				  =  i_pstStGrpParam->wYPos_NextRoller_Uw				  ;
									wDiam_DeflectorRoller_Uw_Rec		  =  i_pstStGrpParam->wDiam_DeflectorRoller_Uw		      ;
									wDiam_DeflectorRollPos_Uw_Rec		  =  i_pstStGrpParam->wDiam_DeflectorRollPos_Uw		      ;
									byDiamMeasureTypeId_Rec				  =  i_pstStGrpParam->byDiamMeasureTypeId				  ;
									iStdVol_Diam_1_Rec					  =  i_pstStGrpParam->iStdVol_Diam_1					  ;
									iStdVol_Diam_2_Rec					  =  i_pstStGrpParam->iStdVol_Diam_2					  ;
									iStdVol_Diam_3_Rec					  =  i_pstStGrpParam->iStdVol_Diam_3					  ;
									iStdVol_Diam_4_Rec					  =  i_pstStGrpParam->iStdVol_Diam_4					  ;
									dwStdVol_Volt_AxisA_1_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_1			      ;
									dwStdVol_Volt_AxisA_2_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_2				  ;
									dwStdVol_Volt_AxisA_3_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_3				  ;
									dwStdVol_Volt_AxisA_4_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_4				  ;
									iStdVol_Coef_Axis_1_Rec				  =  i_pstStGrpParam->iStdVol_Coef_Axis_1					;
									iStdVol_Coef_Axis_2_Rec				  =  i_pstStGrpParam->iStdVol_Coef_Axis_2					;
									iStdVol_Coef_Axis_3_Rec				  =  i_pstStGrpParam->iStdVol_Coef_Axis_3					;
									byIsDebug_DiaMeasureArea_Uw_Rec		  =  i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw			;
									bySwitch_DiaMeasure_Rec				  =  i_pstStGrpParam->bySwitch_DiaMeasure					;
									bySwitch_Enc_Uw_Rec					  =  i_pstStGrpParam->bySwitch_Enc_Uw						;
									wButton_Uw_Rec  					  = i_pstStGrpParam->wButton_Uw								;

								}
							}
					}
					else if(pstStPara_MailboxAlternate_Deputy->dwSyncFlag!=gc_dwSemaphoreUpLink)
					{
						//(*如果数据没改变 且标志还是未知状态 就主动请求主站派发1次了*)
						iCountdownRedispatchReq= iCountdownRedispatchReq+1;
						if(iCountdownRedispatchReq>=10) //(*目前按20ms的周期 就是200ms*)
						{
							iCountdownRedispatchReq= 0;
							adwBuf[0]= gc_dwSemaphoreRequestDispatch;
							adwBuf[1]= 0;
 							//2025.12.1.094650 增加停止mail通讯标志控制
 							if(!i_pstStGlobalParam->xStopMailComm)
 								GT_RN_DevicePcMailComWr((unsigned long*)&(adwBuf[0]), 0, iStationId*gc_iMailboxBlockLen, 2, 1, 1);
						}
					}
				}
 			}
 		}

		//(*han.dp|2017-08-03 23:04:25|读取主站写给本站点的数据||*)
		aiRtnCode[1]= GT_RN_UserPCRdLocalFPGA((unsigned long*)i_pstStPara_PduBroadcastDn, 0, 0, 8);
		pbyBuf= (BYTE*)&(i_pstStPara_PduBroadcastDn->iPackId);
		wTempChk= KS_CRC(pbyBuf, 30, &(dwCheckSumVal));

		//2025.12.1.092921移植到副主站通讯中
 		//start@2025.10.29.112627
		//2025.10.29.111734+检查命令id是否发生变化用来判断通讯还在不在@这个函数是20ms周期执行
 		static int16_t iPackId_PduDn = 0;//下行通讯id备份
 		static uint16_t uiDelayCnt_PduDn = 0;//下行通讯延时计数
 		uint8_t xPduDnFailed = i_pstStGlobalParam->xPduDnFailed;//获取初值
		if(i_pstStPara_PduBroadcastDn->iPackId == iPackId_PduDn)
		{
			if(!xPduDnFailed)
				uiDelayCnt_PduDn += 1;
		}
		else//通讯建立
			uiDelayCnt_PduDn = 0;
		iPackId_PduDn = i_pstStPara_PduBroadcastDn->iPackId;

		if(uiDelayCnt_PduDn >= PDUCOMM_TIMEOUT_CYCLECNT)//3s都没通讯置位pduDnFailed 标志
			xPduDnFailed = TRUE;//pdu通讯失败
		else//通讯建立了
			xPduDnFailed = FALSE;//pdu通讯恢复
		i_pstStGlobalParam->xPduDnFailed = xPduDnFailed;//输出
		i_pstStGlobalParam->xStopMailComm = xPduDnFailed;//输出@pdu下行失败的时候置位停止mail通讯标志@2025.12.1.092539
		if(xPduDnFailed)//通讯失败了就把主站通讯完成标志清零|下次通讯重新获取
			wMasterParam_Flag = 0;

		//输出@pdu下行失败或者在arm升级中的时候置位停止mail通讯标志@2025.12.1.092539
		i_pstStGlobalParam->xStopMailComm = xPduDnFailed || i_pstStGlobalParam->xArmUpdating;
		//end

		if(aiRtnCode[1]==0 &&
			wTempChk==i_pstStPara_PduBroadcastDn->wCHK)
		{
			switch(i_pstStPara_PduBroadcastDn->iPackId)
			{
				case 31:
					pstStCMD_31_Deputy= (stCMD_31_Deputy*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射31#命令到通讯数据区|*)

					i_pstStGrpParam->wFLAG_RUN= pstStCMD_31_Deputy->wFLAG_RUN;
					//2025.12.3.095717+
					i_pstStGlobalParam->xArmUpdating = GetBit(i_pstStGrpParam->wFLAG_RUN,15);

					i_pstStGrpParam->wGRP_VEL= pstStCMD_31_Deputy->wGRP_VEL;
					i_pstStGrpParam->iDIAM_UW= pstStCMD_31_Deputy->iDIAM_UW;
					i_pstStGrpParam->iDIAM_Pre_UW= pstStCMD_31_Deputy->iDIAM_Pre_UW;
					i_pstStGrpParam->iAI_IF= pstStCMD_31_Deputy->iAI_IF;
					i_pstStGrpParam->iAI_UW= pstStCMD_31_Deputy->iAI_UW;
					i_pstStGrpParam->iCur_Rad_Uw= pstStCMD_31_Deputy->iCur_Rad_Uw;
					i_pstStGrpParam->iAI_DIAMMEASURE_UW_CUR= pstStCMD_31_Deputy->iAI_DIAMMEASURE_UW_CUR;
					i_pstStGrpParam->dwEncode_value= pstStCMD_31_Deputy->dwEncode_value;
					i_pstStGrpParam->iCOMPANYID= pstStCMD_31_Deputy->iCOMPANYID;
					i_pstStGrpParam->byCurrUsrLevel= pstStCMD_31_Deputy->byCurrUsrLevel;
					i_pstStGlobalParam->byCurrUsrLevel= pstStCMD_31_Deputy->byCurrUsrLevel;//2024.6.30.003110 共享内存结构体里还有一个level
					i_pstStGrpParam->dwAxisALocation_Uw_U= pstStCMD_31_Deputy->dwAxisALocation_Uw_U;
					i_pstStGlobalParam->byLanguageId= pstStCMD_31_Deputy->i_byLanguageIndex;//(*操作语言id|2025.2.8.095835*)
					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 1);

					break;
				case 32:
					pstStCMD_32_Deputy= (stCMD_32_Deputy*)&(i_pstStPara_PduBroadcastDn->abyPayload);//(*映射31#命令到通讯数据区|*)

					i_pstStGrpParam->dwAxisBLocation_Uw_U= pstStCMD_32_Deputy->dwAxisBLocation_Uw_U;
					i_pstStGrpParam->dwAxisALocation_Uw_D= pstStCMD_32_Deputy->dwAxisALocation_Uw_D;
					i_pstStGrpParam->dwAxisBLocation_Uw_D= pstStCMD_32_Deputy->dwAxisBLocation_Uw_D;

					i_pstStGrpParam->dwAxisALocation_MinDia_Uw_U= pstStCMD_32_Deputy->dwAxisALocation_MinDia_Uw_U;
					i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_U= pstStCMD_32_Deputy->dwAxisBLocation_MinDia_Uw_U;
					i_pstStGrpParam->dwAxisALocation_MinDia_Uw_D= pstStCMD_32_Deputy->dwAxisALocation_MinDia_Uw_D;
					i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_D= pstStCMD_32_Deputy->dwAxisBLocation_MinDia_Uw_D;

					wMasterParam_Flag = SetBit(1, wMasterParam_Flag, 2);
					*i_pxGetParam= 1;

					break;

				default:
					;
			}//switch结束




			if(wMasterParam_Flag == 0x7)//二进制111-mailbox和31~35#命令首次通讯完成
			{
				*i_pxFlag_CopyFromMaster=1;
			}
			else
			{
				*i_pxFlag_CopyFromMaster=0;
			}
		}//	end   if(aiRtnCode[1]==0 &&wTempChk==i_pstStPara_PduBroadcastDn->wCHK)

 }
