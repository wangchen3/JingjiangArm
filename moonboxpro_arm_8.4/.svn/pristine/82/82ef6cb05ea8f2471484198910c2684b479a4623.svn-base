/*
 * KS_FB_RoundSample.h
 *
 *  Created on: Jul 22, 2025
 *      Author: 17500
 */

#ifndef KS_FB_ROUNDSAMPLE_H_
#define KS_FB_ROUNDSAMPLE_H_

#include "base.h"
#include "stdint.h"
//#include "comm.h"
//#include "modbus485_master.h"

#define PUMPPOINT 800//抽点的个数@不能随意更改|全局结构体里只定义了800个
#define RSDATADEAL(VALUE) ((int8_t)VALUE + 128) //双极性粗采样处理@byte型数据
#define HMI_DISPLAY_RESOLUTION 600 //人机波形显示分辨率

//控制切换RGB输出通道地址(RGB)|高8位=0xAC|bit0 代表R通道|bit1 代表G通道|bit2代表B通道@=1代表屏蔽
#define MASK_CHANNEL_ADR  	0x304	//控制屏蔽RGB输出通道地址
#define MASK_CHANNEL_FLAG 	0xAC00	//屏蔽有效,高8bit有效字
#define MASK_CHANNEL_R 		0x0001 	//bit0 = 1 屏蔽R通道
#define MASK_CHANNEL_G 		0x0002 	//bit1 = 1 屏蔽G通道
#define MASK_CHANNEL_B 		0x0004 	//bit2 = 1 屏蔽B通道


//粗采样rgb通道控制处理
//可以控制是否上传那个通道
//ctlBit 的低3bit|.0=1 屏蔽r|.1=1 屏蔽g|.2=1 屏蔽b
void KsRGBChannelCtl(uint8_t ctlBit);


void KS_CalBaseByRS(StGlobalParam* i_pstStGlobalParam,	//系参数
						uint8_t* i_pbyRoundData1,				//粗采样T1_R起始地址
						uint8_t* i_pbyRoundData2,				//粗采样T2_R起始地址
						uint8_t* i_pbyRoundData3,				//粗采样T1_G起始地址
						uint8_t* i_pbyRoundData4,				//粗采样T2_G起始地址
						uint8_t* i_pbyRoundData5,				//粗采样T1_B起始地址
						uint8_t* i_pbyRoundData6,				//粗采样T2_B起始地址
						float i_alrBase_Fs[2],					//精采样基线
						uint16_t* i_pwCount_CaseBase,			//计算基线计数
						uint8_t o_byRefresh_Flag,				//波形刷新标志
						float o_alrBase[2],						//粗采样基线，给KS_FB_ProSample使用
						float o_alrBase_HMI[6]				//粗采样基线，给KS_FB_VISU使用
						);

//重新封装计算粗采样函数
//粗采样数据处理@计算基线+抽点输出
//单字节数据
//2025.10.23.151326+
void KsRsDataDealEx(//uint8_t xBaseLineInDoor,//门内基线
				uint8_t xInclNegative10vSignal,//双极性
				uint8_t xCalcBaseLine,//计算基线使能
				uint8_t*pbyRoundData,//粗采样数据地址
				float* prBaseLine,//基线值
				//uint8_t* pbyBaseLine,//基线值@四舍五入
				uint8_t* pbyMinRsData,//最小的粗采样值@不知道为啥用的抽点的值|先不做更改,
				uint8_t* pbyMaxRsData,//最大的粗采样值@不知道为啥用的抽点的值|先不做更改,
				uint8_t abyPumpPoint_RSData[PUMPPOINT], //抽取的800个点
				int16_t iGateSa,//当前波门地址
				uint8_t xHorizontalScal, //波形横向放大开关
				int16_t* piScalPoints_HorScal,//横向放大后的总点数
				int16_t* piGateSa_Scale//横向放大后的波门起始@在不取消放大的时候保持不变
				//uint8_t abyMinRsData[10],//最小的粗采样值@用来滤波
				//uint8_t* pbyMinRsDataNum//最小粗采样值个数|低7bit是个数,最高bit作为数据满标志
				);

//通过当前通道获取当前通道指针@2025.8.6.093750+
void KsGetDataAdrByCurChannel(
		StGlobalParam* i_pstStGlobalParam,//整机参数
		uint8_t* pbyRoundData1,				//粗采样T1_R起始地址
		uint8_t* pbyRoundData2,				//粗采样T2_R起始地址
		uint8_t* pbyRoundData3,				//粗采样T1_G起始地址
		uint8_t* pbyRoundData4,				//粗采样T2_G起始地址
		uint8_t* pbyRoundData5,				//粗采样T1_B起始地址
		uint8_t* pbyRoundData6,				//粗采样T2_B起始地址
		uint8_t  byCurChannel,//当前通道
		uint8_t byCurId_T1T2,//T1T2选择
		//输出
		uint8_t** pbyRoundData,//粗采样值指针
		uint8_t** pbyRoundData_PumpPoint,//抽点的值指针
		float** pfBaseLine,//基线值指针
		uint8_t** pbyMinRsData,//最小值指针
		uint8_t** pbyMaxRsData);//最大值指针

//获取基线、抽点数据等信息@一个周期处理一个@2025.8.6.114339+
void KsGetSampleInf_V2(	uint8_t* pxDealRsData,//处理粗采样数据标志@处理结束后复位
						StGlobalParam* i_pstStGlobalParam,									//整机参数
						StAxisParam* i_pstStAxisParam,
						StGrpParam* i_pstStGrpParam,//系参数@2026.4.22.152658+
						uint8_t* pxCalcBaseLine,//计算基线使能@修改为指针,需要的计算完成后就清零
						float afBase_Fs[2],					//精采样基线
						uint8_t* pbyRoundData1,				//粗采样T1_R起始地址
						uint8_t* pbyRoundData2,				//粗采样T2_R起始地址
						uint8_t* pbyRoundData3,				//粗采样T1_G起始地址
						uint8_t* pbyRoundData4,				//粗采样T2_G起始地址
						uint8_t* pbyRoundData5,				//粗采样T1_B起始地址
						uint8_t* pbyRoundData6,				//粗采样T2_B起始地址
						uint8_t* pbyRoundId,//轮询id
						uint8_t* pbySignalSelect,//当前轮询RGB通道
						uint8_t* pbyChannel_T1T2,
						uint8_t* pxDealRsDataDne);//粗采样数据处理完成@外部清零

//获取基线、抽点数据等信息
void KsGetSampleInf(    StGlobalParam* i_pstStGlobalParam,
						StAxisParam* i_pstStAxisParam,
						uint8_t xCalcBaseLine,//计算基线使能
						float afBase_Fs[2],					//精采样基线
						uint8_t* pbyRoundData1,				//粗采样T1_R起始地址
						uint8_t* pbyRoundData2,				//粗采样T2_R起始地址
						uint8_t* pbyRoundData3,				//粗采样T1_G起始地址
						uint8_t* pbyRoundData4,				//粗采样T2_G起始地址
						uint8_t* pbyRoundData5,				//粗采样T1_B起始地址
						uint8_t* pbyRoundData6);				//粗采样T2_B起始地址)

//void KSRoundDataDisplayDeal(uint16_t uiDoorPos,uint8_t RoundData[],uint8_t value_wr, uint16_t RemainNum_F,uint16_t RemainNum_B);
void KSRoundDataDisplayDeal(uint16_t uiDoorPos,uint8_t RoundData[],uint8_t value_wr, uint16_t RemainNum_F,uint16_t RemainNum_B,uint8_t xScale);
//获取界面的波门宽度
int16_t KSGetGateWidth_Hmi(int16_t iGateWidthRondPt,int16_t iScalPoints_HorScal,uint8_t xHorizontalScal);
#endif /* KS_FB_ROUNDSAMPLE_H_ */
