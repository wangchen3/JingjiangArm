/*
 * KS_FB_RoundSample.c
 *
 *  Created on: Jul 22, 2025
 *      Author: 17500
 */
//2025.7.22.102459|wei.n|移植
#include "KS_FB_RoundSample.h"
#include "StSample.h"
#include "stdlib.h"
#include "modbus485.h"
#include "KesaiAPI.h"
#include "string.h"//内存操作
#include "KS_RsMorphFilter.h"
#include "KS_RsRootBaseline.h"//wang.c 2026.10.26.110221 新增包含(自moonbox baseline版移植)：粗采样形态学根部估计基线//2026.4.22.151921+

//粗采样rgb通道控制处理
//可以控制是否上传那个通道
//ctlBit 的低3bit|.0=1 屏蔽r|.1=1 屏蔽g|.2=1 屏蔽b
void KsRGBChannelCtl(uint8_t ctlBit)
{

	static uint8_t byPrevRGBChannelMaskCtl = 0;

	//rgb显示通道屏蔽处理
	uint16_t uiCtlWord = 0;//控制字
	uint8_t byRGBChannelMaskCtl = ctlBit & 0x0007;//只取低3bit

	if(byPrevRGBChannelMaskCtl != byRGBChannelMaskCtl)//屏蔽字变了|写入到fpga
	{
		uiCtlWord = MASK_CHANNEL_FLAG;//标志字
		if (KSGetDataBit(&byRGBChannelMaskCtl,0))//屏蔽r通道
		{
			uiCtlWord |= MASK_CHANNEL_R;
		}
		if(KSGetDataBit(&byRGBChannelMaskCtl,1))//屏蔽g通道
		{
			uiCtlWord |= MASK_CHANNEL_G;
		}
		if(KSGetDataBit(&byRGBChannelMaskCtl,2))//屏蔽b通道
		{
			uiCtlWord |= MASK_CHANNEL_B;
		}
		GT_RN_WriteFPGA(MASK_CHANNEL_ADR, &uiCtlWord);//写入到fpga
		byPrevRGBChannelMaskCtl = byRGBChannelMaskCtl;
	}
}

//粗采样数据处理@计算基线+抽点输出
//单字节数据
//2025.10.23.150645 增加最大值的获取
void KsRsDataDealEx(//uint8_t xBaseLineInDoor,//门内基线
				uint8_t xInclNegative10vSignal,//双极性
				uint8_t xCalcBaseLine,//计算基线使能
				uint8_t*pbyRoundData,//粗采样数据地址
				float* prBaseLine,//基线值
				//uint8_t* pbyBaseLine,//基线值@四舍五入
				uint8_t* pbyMinRsData,//最小的粗采样值@不知道为啥用的抽点的值|先不做更改,
				//2025.10.23.151259+
				uint8_t* pbyMaxRsData,//最小的粗采样值@不知道为啥用的抽点的值|先不做更改,
				uint8_t abyPumpPoint_RSData[PUMPPOINT], //抽取的800个点
				int16_t iGateSa,//当前波门地址
				uint8_t xHorizontalScal, //波形横向放大开关
				int16_t* piScalPoints_HorScal,//横向放大后的总点数
				int16_t* piGateSa_Scale//横向放大后的波门起始@在不取消放大的时候保持不变
				//uint8_t abyMinRsData[10],//最小的粗采样值@用来滤波
				//uint8_t* pbyMinRsDataNum//最小粗采样值个数|低7bit是个数,最高bit作为数据满标志
				)
{
	//int8_t* piRoundData = 0;//有符号指针
	uint8_t byRoundData = 0;//粗采样值
	uint8_t abyRoundData[MAX_ROUND_POINT] = {0};//粗采样值@数组 处理过的
	int16_t i = 0,iIndex = 0;
	uint16_t uiPumpInterval = (uint16_t)(MAX_ROUND_POINT / PUMPPOINT);//抽点间隔
	//2025.07.02.114109//取消静态变量的设置
	uint8_t byMinData = 255;//抽点后数据最小值获取
	uint8_t byMaxData = 0;//抽点后数据最大值获取@2025.10.23.150710+
	//基线计算
	uint32_t diSum = 0,diSum_GTAver = 0,diSum_LTAver = 0;
	float rBaseBaselineRef0 = 0.0;//第一次平均值
	float rBaseBaselineRef1 = 0.0;//第二次平均值
	float rBaseBaselineRef2 = 0.0;//第三次平均值@二次校准|没有处理
	uint16_t uiGTAverCnt = 0;//超过平均值计数
	uint16_t uiLTAverCnt = 0;//小于平均值计数

	if(pbyRoundData ==0 || prBaseLine == 0 || piGateSa_Scale == 0)
		return;

	//信号处理
	//piRoundData = (int8_t*)pbyRoundData;
	for(i = 0; i< MAX_ROUND_POINT;i++)//逐点处理@转换为0--255变化区间
	{
		//根据极性处理数据
		if(xInclNegative10vSignal)//双极性
		{
			byRoundData = RSDATADEAL(pbyRoundData[i]);//双极性数据处理后的值
		}
		else//单极性
		{
			byRoundData = pbyRoundData[i];//自己的值
		}
		abyRoundData[i] = byRoundData;//写入到数组中

		if(!xHorizontalScal) //横向不放大
		{
			//顺道把点抽出来
			if(i % uiPumpInterval == 0)
			{
				if(iIndex < PUMPPOINT)//索引正常
				{
					if(byMinData > byRoundData && byRoundData != 0)
						byMinData = byRoundData;//更新最小值

					//2025.10.23.150741+更新最大值
					if( byRoundData > byMaxData)
						byMaxData = byRoundData;//更新为最大值

					//抽点值记录
					abyPumpPoint_RSData[iIndex] = byRoundData;
					iIndex += 1;//更新索引
				}
				else;//取够了
			}
		}
		//基线计算@第一次数据累计
		diSum += byRoundData;
	}

	int16_t indexSa = 0,indexEd = 0;
	int16_t iScalPoints = 0;//放大后的总点数
	int16_t iGateSa_Scale = *piGateSa_Scale;//横向放大后的波门起始@在不取消放大的时候保持不变//横向放大后的波门起始@在不取消放大的时候保持不变
	if(xHorizontalScal) //横向放大重新抽点@2倍
	{
		if(iGateSa_Scale == -1)//放大的波门地址是特殊值
			iGateSa_Scale = iGateSa;

		iScalPoints =  MAX_ROUND_POINT / 2;
		iScalPoints = iScalPoints / PUMPPOINT * PUMPPOINT;//确保能被PUMPPOINT整除
		indexSa = iGateSa_Scale + MAX_ROUND_POINT - iScalPoints / 2;
		indexSa = indexSa % MAX_ROUND_POINT;//波门左边位置
		indexEd = iGateSa_Scale + iScalPoints / 2;
		indexEd = indexEd % MAX_ROUND_POINT;//波门右边位置

		//抽点
		uiPumpInterval = (uint16_t)(iScalPoints / PUMPPOINT);//抽点间隔
		iIndex = 0;
		byMinData = 255;
		byMaxData = 0;//2025.10.23.151016+
		for(i = 0; i< iScalPoints;i++)//逐点处理@转换为0--255变化区间
		{

			byRoundData = abyRoundData[(indexSa + i) % MAX_ROUND_POINT];
			if(i % uiPumpInterval == 0)
			{
				if(iIndex < PUMPPOINT)//索引正常
				{
					if(byMinData > byRoundData && byRoundData != 0)
						byMinData = byRoundData;//更新最小值

					//2025.10.23.150741+更新最大值
					if( byRoundData > byMaxData)
						byMaxData = byRoundData;//更新为最大值
					//抽点值记录
					abyPumpPoint_RSData[iIndex] = byRoundData;
					iIndex += 1;//更新索引
				}
				else;//取够了
			}
		}
		//2025.07.17.094016//xi.hy//将放大后的总点数输出
		*piScalPoints_HorScal=iScalPoints;

	}
	else//未放大
		iGateSa_Scale = -1;//写一个特殊值
	*piGateSa_Scale = iGateSa_Scale;//输出出去


	if(xCalcBaseLine)//计算基线使能
	{
		//基线计算的首次平均值
		rBaseBaselineRef0 = (float)diSum / MAX_ROUND_POINT;//计算首次平均值

		//(*均值分割后的两部分数据再次获取均值||*)
		for(i = 0; i< MAX_ROUND_POINT;i++)//逐点处理@转换为0--255变化区间
		{
			byRoundData = abyRoundData[i];

			if(byRoundData >= rBaseBaselineRef0)//超过首次平均值
			{
				uiGTAverCnt += 1;
				diSum_GTAver += byRoundData;//超过平均值累计

			}
			else//小于首次平均值
			{
				uiLTAverCnt += 1;
				diSum_LTAver += byRoundData;//小于平均值累计
			}
		}
		//数量多的部分再次求平均
		if(uiGTAverCnt >= uiLTAverCnt)
		{
			if(uiGTAverCnt != 0)
				rBaseBaselineRef1 = (float)diSum_GTAver / uiGTAverCnt;
		}
		else
		{
			if(uiLTAverCnt != 0)
				rBaseBaselineRef1 = (float)diSum_LTAver / uiLTAverCnt;
		}

		rBaseBaselineRef2 = rBaseBaselineRef1;
		//以前有二次校准@未实现
		*prBaseLine = rBaseBaselineRef2;
		//*pbyBaseLine = (uint8_t)KS_ROUND(rBaseBaselineRef2);
	}
	else;//不计算的时候不要更新


	*pbyMinRsData = byMinData;
	*pbyMaxRsData = byMaxData;
}

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
		uint8_t** pbyMaxRsData)//最大值指针
{
	if(byCurId_T1T2 == T1 )
	{	//T1通道
		if(byCurChannel == CURR_VISU_G)//选择g通道
		{
			*pbyRoundData = pbyRoundData3;//T1_G@粗采样值
			*pbyRoundData_PumpPoint = i_pstStGlobalParam->abyRSData_T1G;//T1_G@抽点的值
			*pfBaseLine =&i_pstStGlobalParam->fBaseLine_T1G;//T1_G@基线值
			*pbyMinRsData = &i_pstStGlobalParam->byMinRsData_T1G;//T1_G@最小值
			*pbyMaxRsData = &i_pstStGlobalParam->byMaxRsData_T1G;//T1_G@最大值
		}
		else if(byCurChannel == CURR_VISU_B)//选择B通道
		{
			*pbyRoundData = pbyRoundData5;//T1_B
			*pbyRoundData_PumpPoint = i_pstStGlobalParam->abyRSData_T1B;//T1_B
			*pfBaseLine =&i_pstStGlobalParam->fBaseLine_T1B;//T1_B
			*pbyMinRsData = &i_pstStGlobalParam->byMinRsData_T1B;//T1_B
			*pbyMaxRsData = &i_pstStGlobalParam->byMaxRsData_T1B;//T1_B@最大值
		}
		else//默认通道
		{
			*pbyRoundData = pbyRoundData1;//T1_R
			*pbyRoundData_PumpPoint = i_pstStGlobalParam->abyRSData_T1R;//T1_R
			*pfBaseLine =&i_pstStGlobalParam->fBaseLine_T1R;//T1_R
			*pbyMinRsData = &i_pstStGlobalParam->byMinRsData_T1R;//T1_R
			*pbyMaxRsData = &i_pstStGlobalParam->byMaxRsData_T1R;//T1_R@最大值
		}
	}
	else//t2
	{
		//T2通道
		if(byCurChannel == CURR_VISU_G)//选择g通道
		{
			*pbyRoundData = pbyRoundData4;//T2_G@粗采样值
			*pbyRoundData_PumpPoint = i_pstStGlobalParam->abyRSData_T2G;//T2_G@抽点的值
			*pfBaseLine =&i_pstStGlobalParam->fBaseLine_T2G;//T2_G@基线值
			*pbyMinRsData = &i_pstStGlobalParam->byMinRsData_T2G;//T2_G@最小值
			*pbyMaxRsData = &i_pstStGlobalParam->byMaxRsData_T2G;//T2_G@最大值

		}
		else if(byCurChannel == CURR_VISU_B)//选择B通道
		{
			*pbyRoundData = pbyRoundData6;//T2_B
			*pbyRoundData_PumpPoint = i_pstStGlobalParam->abyRSData_T2B;//T2_B
			*pfBaseLine =&i_pstStGlobalParam->fBaseLine_T2B;//T2_B
			*pbyMinRsData = &i_pstStGlobalParam->byMinRsData_T2B;//T2_B
			*pbyMaxRsData = &i_pstStGlobalParam->byMaxRsData_T2B;//T2_B@最大值
		}
		else//默认通道
		{
			*pbyRoundData = pbyRoundData2;//T2_R
			*pbyRoundData_PumpPoint = i_pstStGlobalParam->abyRSData_T2R;//T2_R
			*pfBaseLine =&i_pstStGlobalParam->fBaseLine_T2R;//T2_R
			*pbyMinRsData = &i_pstStGlobalParam->byMinRsData_T2R;//T2_R
			*pbyMaxRsData = &i_pstStGlobalParam->byMaxRsData_T2R;//T2_R@最大值
		}
	}
	return;
}



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
						uint8_t* pxDealRsDataDne)//粗采样数据处理完成@外部清零
{
	//uint8_t bySignalSelect_T1 = 0,bySignalSelect_T2 = 0;//2025.8.6.091337 修改
	uint8_t bySignalSelect	= 0;//2025.8.6.091337 修改
	uint8_t xBaseLineInDoor = 0;
	//数组索引代表|T1_R T1_G T1_B ...T2_B
	uint8_t* apbyRoundData[6] = {0};//粗采样数组指针
	uint8_t* apbyRoundData_PumpPoint[6] = {0};//粗采样抽点后数组指针
	float* apfBaseLine[6] = {0};//基线值指针
	uint8_t* apbyMinRsData[6] = {0};//最小的粗采样数据
	//2025.10.23.151428+
	uint8_t* apbyMaxRsData[6] = {0};//最大的粗采样数据
	uint16_t i = 0,j = 0 ;
	uint8_t abyChannelList[3] = {CURR_VISU_R,CURR_VISU_G,CURR_VISU_B};//列表
	uint8_t abyRonndList[6] = {0};//轮询列表@获取的t1-当前 t2-当前 t1其他+t2其他
	uint8_t abyCurChannel_T1T2[6] = {0};//轮询列表对应的T1 T2通道
	uint8_t byChannel_T1T2 = T1;//t1 t2 通道
	uint8_t xUpdataBaseLineValue = FALSE;
	uint8_t xDealRsData = *pxDealRsData;//获取处理粗采样数据标志
	uint8_t	xCalcBaseLineEn = *pxCalcBaseLine;//计算基线使能
	uint8_t	xDealRsDataDne = *pxDealRsDataDne;//粗采样处理完成标志
	//轮询处理
	uint8_t byRoundId = *pbyRoundId;//轮询id@外部输入
	if(byRoundId>=6)//非法值处理
		byRoundId = 0;


	if(xDealRsData)
	{
		/********************************************************轮询列表处理@获取的t1-当前 t2-当前 t1其他+t2其他************************************/
		abyRonndList[0] = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,1);//T1当前通道选择
		abyCurChannel_T1T2[0] = T1;
		abyRonndList[1] = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,2);//T2当前通道选择
		abyCurChannel_T1T2[1] = T2;
		//T1通道剩余
		j = 2;//从2开始
		bySignalSelect = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,1);//T1当前通道选择;
		for(i=0;i<3;i++)
		{
			if(abyChannelList[i]  == bySignalSelect)
			{
				;
			}
			else//抽出不是的
			{
				abyRonndList[j] = abyChannelList[i];//2--3
				abyCurChannel_T1T2[j] = T1;
				j += 1;
				if(j >= 4)
					break;//退出循环
			}
		}

		//T2通道剩余
		bySignalSelect = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,2);//T2当前通道选择;
		for(i=0;i<3;i++)
		{
			if(abyChannelList[i]  == bySignalSelect)
			{
				;
			}
			else//抽出不是的
			{
				abyRonndList[j] = abyChannelList[i];//4 - 5
				abyCurChannel_T1T2[j] = T2;
				j += 1;
				if(j >= 6)
					break;//退出循环
			}
		}
/******************************end**********************************/

		//byRoundId = 当前轮询的id
		bySignalSelect = abyRonndList[byRoundId];//轮询当前通道选择;
		byChannel_T1T2 = abyCurChannel_T1T2[byRoundId];//处于T1还是T2

		if(byRoundId>=2)//需要计算的通道都计算完了@此时byRoundId代表当前轮询id
		{
			//xCalcBaseLine = FALSE;//其他通道不计算基线,只计算当前选择的通道
			xCalcBaseLineEn = FALSE;//清除基线计算使能。
		}

		//下一个轮询的索引
		byRoundId += 1;//0--5变化
		if(byRoundId>5)
		{
			byRoundId = 0;
			xDealRsData = FALSE;//处理完成|等下一次粗采样触发
			xDealRsDataDne = TRUE;//处理完成
		}

		if(byRoundId == 2)//把使用的2个通道(0 && 1)轮询完成后就输出更新标志
		{
			xUpdataBaseLineValue = TRUE;//轮询完了T1 和 T2使用的值,更新下基线值
		}
		else;//根据输入控制基线计算

		KsGetDataAdrByCurChannel(
				i_pstStGlobalParam,//整机参数
				pbyRoundData1,				//粗采样T1_R起始地址
				pbyRoundData2,				//粗采样T2_R起始地址
				pbyRoundData3,				//粗采样T1_G起始地址
				pbyRoundData4,				//粗采样T2_G起始地址
				pbyRoundData5,				//粗采样T1_B起始地址
				pbyRoundData6,				//粗采样T2_B起始地址
				bySignalSelect,				//当前通道
				byChannel_T1T2,				//T1T2选择
				//输出
				&(apbyRoundData[0]),//粗采样值
				&(apbyRoundData_PumpPoint[0]),//抽点的值
				&(apfBaseLine[0]),//基线值
				&(apbyMinRsData[0]),//最小值
				&(apbyMaxRsData[0]));//最大值

		//根据选择rgb通道选择当前误差计算的基线值
		KsRsDataDealEx(
				  KSGetDataBit(&i_pstStAxisParam->wSwitchRef,9),//双极性
				  xCalcBaseLineEn,//计算基线使能
				  apbyRoundData[0],//粗采样数据地址@T1_R
				  apfBaseLine[0],//基线值
				  apbyMinRsData[0],
				  apbyMaxRsData[0],
				  apbyRoundData_PumpPoint[0],
				  i_pstStAxisParam->iGateSa,
				  KSGetDataBit(&i_pstStGlobalParam->uiSomeCtlBit_RW,3),//波形横向放大标志
				  &i_pstStGlobalParam->iScalPoints_HorScal, //横向放大后的总点数大家的值应该都是一样的,就用一个变量好了
				  &i_pstStGlobalParam->iGateSa_Scale//横向放大后的波门地址大家的值应该都是一样的,就用一个变量好了
				  );


		//2026.4.22.151841+粗采样波形美化
		//需要确认执行时间
		if(i_pstStAxisParam->xRsMorphFilter)
		{
			uint16_t wLen_WindowMorph = KsCalcMorphWindowLen((float)i_pstStGrpParam->byTriMark_SideC, (float)i_pstStAxisParam->lrGirth);//形态学结构元素长度，必须为奇数
			//界面显示粗采样波形滤波：去基线漂移
			if(KS_RsMorphFilter_CheckWindowValid(PUMPPOINT, wLen_WindowMorph))
			{
				KS_RsMorphFilter_U8(apbyRoundData_PumpPoint[0], PUMPPOINT, wLen_WindowMorph, 2);
			}
		}
		//end

	}//

	//wang.c 2026.10.26.110221 新增(自moonbox baseline版移植)：门内基线开且宏USE_RS_ROOT_BASELINE=1时,
	//按当前轮询通道计算粗采样形态学根部估计基线(整圈圆周形态学(单调队列O(N))后截取波门
	//区间平均,8bit粗采样域0~255),存入fRootBaseLine_T1/T2供calcerr门内基线分支使用
	//8.4版参数归属：门/周长/开关在i_pstStAxisParam,色标边长在i_pstStGrpParam,
	//极性位=i_pstStAxisParam->dwControlBits(bit5=T1门1,bit6=T2门1,bit15=T1门2,bit16=T2门2),
	//门宽粗点数=iGateWidthPhy/lrGirth×4000(8.4无iGateWidthRdPt字段,现算同口径)
#if USE_RS_ROOT_BASELINE
	if ((xCalcBaseLineEn != 0u)//当前通道本圈允许计算基线@V2标量,轮到非当前通道时已在上方清零
		&& (KSGetDataBit(&i_pstStAxisParam->wSwitchRef,1) != 0u))//门内基线开
	{
		int32_t iGateSaRoot = i_pstStAxisParam->iGateSa;//波门起始粗采样点@T1用门1
		uint8_t xNegPolarityRoot = KSGetDataBit(&i_pstStAxisParam->dwControlBits,5);//T1反极性@门1
		uint16_t wGateRdPtRoot;//波门宽度粗采样点数|现算
		float lrRootBase = 0.0f;

		if (byChannel_T1T2 == T2)//T2通道:双波门取门2地址,单波门同T1用门1
		{
			if (KSGetDataBit(&i_pstStAxisParam->wSwitchRef,6) != 0u)//双波门(bit6)
			{
				iGateSaRoot = i_pstStAxisParam->iGateSaEx;
				//wang.c 2026.10.26.110221 T2在门2内,极性取T2第二门内反极性dwControlBits.bit16
				//(与ProSample打包keyword bit7的极性口径一致)|单波门时T2在门1内用bit6
				xNegPolarityRoot = KSGetDataBit(&i_pstStAxisParam->dwControlBits,16);//T2反极性@门2
			}
			else
			{
				xNegPolarityRoot = KSGetDataBit(&i_pstStAxisParam->dwControlBits,6);//T2反极性@门1
			}
		}
		iGateSaRoot = (iGateSaRoot % MAX_ROUND_POINT + MAX_ROUND_POINT) % MAX_ROUND_POINT;//归一化0~3999
		wGateRdPtRoot = (uint16_t)(i_pstStAxisParam->iGateWidthPhy * (int32_t)MAX_ROUND_POINT
							  / (int32_t)(i_pstStAxisParam->lrGirth > 0.0f ? i_pstStAxisParam->lrGirth : 1.0f));

		if (KS_RsRootBase_Calc(apbyRoundData[0],//当前轮询通道整圈粗采样原始数据
							   KSGetDataBit(&i_pstStAxisParam->wSwitchRef,9),//双极性
							   (uint16_t)iGateSaRoot,//波门起始粗采样点
							   wGateRdPtRoot,//波门宽度粗采样点数
							   xNegPolarityRoot,//反极性
							   i_pstStAxisParam->lrGirth,//版周长mm
							   (float)i_pstStGrpParam->byTriMark_SideC,//色标垂直边长mm|决定滑窗
							   &lrRootBase) != 0u)
		{
			if (byChannel_T1T2 == T2)
			{
				i_pstStGlobalParam->fRootBaseLine_T2 = lrRootBase;
			}
			else
			{
				i_pstStGlobalParam->fRootBaseLine_T1 = lrRootBase;
			}
		}
	}
#endif

	*pbyRoundId = byRoundId;//输出
	*pxDealRsData = xDealRsData ;//输出处理粗采样数据标志
	*pxCalcBaseLine = xCalcBaseLineEn;//计算基线使能
	//2025.8.9.104530+
	*pbySignalSelect = bySignalSelect;//当前处理的rgb通道
	*pbyChannel_T1T2 = byChannel_T1T2;//当前处理的T1 T2 通道
	*pxDealRsDataDne = xDealRsDataDne;//处理完成标志输出@外部清零



	//基线值处理
	xBaseLineInDoor = KSGetDataBit(&i_pstStAxisParam->wSwitchRef,1);//门内基线
	if(xBaseLineInDoor)//精采样基线
	{
		i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(afBase_Fs[0]);//四舍五入
		i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(afBase_Fs[1]);//四舍五入
	}
	else  //粗采样基线处理
	{
		if(xUpdataBaseLineValue)//更新基线值
		{
			//T1通道
			bySignalSelect = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,1);//T1当前通道选择;
			if(bySignalSelect == CURR_VISU_G)//选择g通道
			{
			  i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1G);//四舍五入
			}
			else if(bySignalSelect == CURR_VISU_B)//选择B通道
			{
			  i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1B);//四舍五入

			}
			else//默认通道
			{
			  i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1R);//四舍五入
			}

			//T2通道
			bySignalSelect = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,2);//T2当前通道选择;
			if(bySignalSelect == CURR_VISU_G)//选择g通道
			{
			  i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2G);//四舍五入
			}
			else if(bySignalSelect == CURR_VISU_B)//选择B通道
			{
			  i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2B);//四舍五入
			}
			else//默认通道
			{
			  i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2R);//四舍五入
			}
		}
	}
	//2025.12.18.140240//xi.hy//输出一个给偏移自调使用的粗采样基线值@使用门内基线时，偏移自调就拿不到粗采样基线值
	//2026.01.04.113007//xi.hy//同时将这个值给主站数字量显示使用，以前没给主站数字波形显示的基线变量赋值
	if(xUpdataBaseLineValue)//更新基线值
	{
		//T1通道
		bySignalSelect = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,1);//T1当前通道选择;
		if(bySignalSelect == CURR_VISU_G)//选择g通道
		{
		  i_pstStGlobalParam->fBaseLine_T1_OffsetCtl = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1G);//四舍五入
		}
		else if(bySignalSelect == CURR_VISU_B)//选择B通道
		{
		  i_pstStGlobalParam->fBaseLine_T1_OffsetCtl = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1B);//四舍五入

		}
		else//默认通道
		{
		  i_pstStGlobalParam->fBaseLine_T1_OffsetCtl = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1R);//四舍五入
		}

		//T2通道
		bySignalSelect = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,2);//T2当前通道选择;
		if(bySignalSelect == CURR_VISU_G)//选择g通道
		{
		  i_pstStGlobalParam->fBaseLine_T2_OffsetCtl = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2G);//四舍五入
		}
		else if(bySignalSelect == CURR_VISU_B)//选择B通道
		{
		  i_pstStGlobalParam->fBaseLine_T2_OffsetCtl = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2B);//四舍五入
		}
		else//默认通道
		{
		  i_pstStGlobalParam->fBaseLine_T2_OffsetCtl = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2R);//四舍五入
		}
	}

	if(xDealRsDataDne)//2025.9.2.083414+粗采样六路处理完成后才能更新粗采样采集
		GT_RN_SampleRoundUpdata();													/* 刷新采样 */
}


//获取基线、抽点数据等信息
void KsGetSampleInf(	StGlobalParam* i_pstStGlobalParam,									//整机参数
						StAxisParam* i_pstStAxisParam,
						uint8_t xCalcBaseLine,//计算基线使能
						float afBase_Fs[2],					//精采样基线
						uint8_t* pbyRoundData1,				//粗采样T1_R起始地址
						uint8_t* pbyRoundData2,				//粗采样T2_R起始地址
						uint8_t* pbyRoundData3,				//粗采样T1_G起始地址
						uint8_t* pbyRoundData4,				//粗采样T2_G起始地址
						uint8_t* pbyRoundData5,				//粗采样T1_B起始地址
						uint8_t* pbyRoundData6)				//粗采样T2_B起始地址)
{
	uint8_t bySignalSelect_T1 = 0,bySignalSelect_T2 = 0;//2025.8.6.091337 修改
	uint8_t xBaseLineInDoor = 0;
	//数组索引代表|T1_R T1_G T1_B ...T2_B
	uint8_t* apbyRoundData[6] = {0};//粗采样数组指针
	uint8_t* apbyRoundData_PumpPoint[6] = {0};//粗采样抽点后数组指针
	float* apfBaseLine[6] = {0};//基线值指针
	uint8_t* apbyMinRsData[6] = {0};//最小的粗采样数据
	uint8_t* apbyMaxRsData[6] = {0};//最小的粗采样数据
	uint16_t i = 0 ,j = 0;
	uint8_t axCalcBaseLineEn[6] ={0};//计算基线使能@2025.8.7.102802+
	uint8_t axChannel_RGB[3] = {CURR_VISU_R,CURR_VISU_G,CURR_VISU_B};


	bySignalSelect_T1 = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,1);//T1当前通道选择
	bySignalSelect_T2 = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,2);//T2当前通道选择

	for(i=0;i<3;i++)//检查当前通道是什么颜色|决定是否需要计算基线
	{
		if(bySignalSelect_T1 == axChannel_RGB[i])
			axCalcBaseLineEn[i] = xCalcBaseLine;//0 1 2是T1

		j = 3 + i;//3 4 5 是T2
		if(bySignalSelect_T2 == axChannel_RGB[i])
			axCalcBaseLineEn[j] = xCalcBaseLine;//3 4 5 是T2
	}

	apbyRoundData[0] = pbyRoundData1;//T1_R
	apbyRoundData[1] = pbyRoundData3;//T1_G
	apbyRoundData[2] = pbyRoundData5;//T1_B
	apbyRoundData[3] = pbyRoundData2;//T2_R
	apbyRoundData[4] = pbyRoundData4;//T2_G
	apbyRoundData[5] = pbyRoundData6;//T2_B

	apbyRoundData_PumpPoint[0] = i_pstStGlobalParam->abyRSData_T1R;//T1_R
	apbyRoundData_PumpPoint[1] = i_pstStGlobalParam->abyRSData_T1G;//T1_G
	apbyRoundData_PumpPoint[2] = i_pstStGlobalParam->abyRSData_T1B;//T1_B
	apbyRoundData_PumpPoint[3] = i_pstStGlobalParam->abyRSData_T2R;//T2_R
	apbyRoundData_PumpPoint[4] = i_pstStGlobalParam->abyRSData_T2G;//T2_G
	apbyRoundData_PumpPoint[5] = i_pstStGlobalParam->abyRSData_T2B;//T2_B

	apfBaseLine[0] =&i_pstStGlobalParam->fBaseLine_T1R;
	apfBaseLine[1] =&i_pstStGlobalParam->fBaseLine_T1G;
	apfBaseLine[2] =&i_pstStGlobalParam->fBaseLine_T1B;
	apfBaseLine[3] =&i_pstStGlobalParam->fBaseLine_T2R;
	apfBaseLine[4] =&i_pstStGlobalParam->fBaseLine_T2G;
	apfBaseLine[5] =&i_pstStGlobalParam->fBaseLine_T2B;

	apbyMinRsData[0] = &i_pstStGlobalParam->byMinRsData_T1R;
	apbyMinRsData[1] = &i_pstStGlobalParam->byMinRsData_T1G;
	apbyMinRsData[2] = &i_pstStGlobalParam->byMinRsData_T1B;
	apbyMinRsData[3] = &i_pstStGlobalParam->byMinRsData_T2R;
	apbyMinRsData[4] = &i_pstStGlobalParam->byMinRsData_T2G;
	apbyMinRsData[5] = &i_pstStGlobalParam->byMinRsData_T2B;

	apbyMaxRsData[0] = &i_pstStGlobalParam->byMaxRsData_T1R;
	apbyMaxRsData[1] = &i_pstStGlobalParam->byMaxRsData_T1G;
	apbyMaxRsData[2] = &i_pstStGlobalParam->byMaxRsData_T1B;
	apbyMaxRsData[3] = &i_pstStGlobalParam->byMaxRsData_T2R;
	apbyMaxRsData[4] = &i_pstStGlobalParam->byMaxRsData_T2G;
	apbyMaxRsData[5] = &i_pstStGlobalParam->byMaxRsData_T2B;




	for(i=0;i<6;i++)
	{
		KsRsDataDealEx(
				  KSGetDataBit(&i_pstStAxisParam->wSwitchRef,9),//双极性
				  axCalcBaseLineEn[i],//计算基线使能@只计算需要的
				  apbyRoundData[i],//粗采样数据地址@T1_R
				  apfBaseLine[i],//基线值
				  apbyMinRsData[i],
				  apbyMaxRsData[i],//2025.10.23.152358+
				  apbyRoundData_PumpPoint[i],
				  i_pstStAxisParam->iGateSa,
				  KSGetDataBit(&i_pstStGlobalParam->uiSomeCtlBit_RW,3),//波形横向放大标志
				  &i_pstStGlobalParam->iScalPoints_HorScal,//横向放大后的总点数
				  &i_pstStGlobalParam->iGateSa_Scale//横向放大后的波门地址大家的值应该都是一样的,就用一个变量好了
				  );
//
//		float ftmp = *apfBaseLine[i];
//		if(xBaseLineInDoor)//精采样基线)
//		{
//			if(i<3) ftmp = i_pstStGlobalParam->fBaseLine_T1;//t1
//			else ftmp = i_pstStGlobalParam->fBaseLine_T2;//t2
//		}
//
//
//		if(KSGetDataBit(&i_pstStGlobalParam->uiSomeCtlBit_RW,4) /*&& !KSGetDataBit(&i_pstStGlobalParam->uiSomeCtlBit_RW,3)*/)//一定范围数据写0
//			KSRoundDataDisplayDeal(i_pstStAxisParam->iGateSa,apbyRoundData_PumpPoint[i], (uint8_t)ftmp,i_pstStGlobalParam->uiRemainNum_F,i_pstStGlobalParam->uiRemainNum_B,
//					 KSGetDataBit(&i_pstStGlobalParam->uiSomeCtlBit_RW,3));
	}


	//根据选择rgb通道选择当前误差计算的基线值
	xBaseLineInDoor = KSGetDataBit(&i_pstStAxisParam->wSwitchRef,1);//门内基线
	if(xBaseLineInDoor)//精采样基线
	{
		i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(afBase_Fs[0]);//四舍五入
		i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(afBase_Fs[1]);//四舍五入
	}
	else  //粗采样基线处理
	{
		//T1通道
		if(bySignalSelect_T1 == CURR_VISU_G)//选择g通道
		{
		  i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1G);//四舍五入
		}
		else if(bySignalSelect_T1 == CURR_VISU_B)//选择B通道
		{
		  i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1B);//四舍五入

		}
		else//默认通道
		{
		  i_pstStGlobalParam->fBaseLine_T1 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T1R);//四舍五入
		}

		//T2通道
		if(bySignalSelect_T2 == CURR_VISU_G)//选择g通道
		{
		  i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2G);//四舍五入
		}
		else if(bySignalSelect_T2 == CURR_VISU_B)//选择B通道
		{
		  i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2B);//四舍五入

		}
		else//默认通道
		{
		  i_pstStGlobalParam->fBaseLine_T2 = KS_ROUND(i_pstStGlobalParam->fBaseLine_T2R);//四舍五入
		}
	}
	GT_RN_SampleRoundUpdata();													/* 刷新采样 */
}
//获取界面波门宽度值
int16_t KSGetGateWidth_Hmi(int16_t iGateWidthRondPt,int16_t iScalPoints_HorScal,uint8_t xHorizontalScal)
{
	int16_t iGateWidthRdPt_Hmi = 20;
	if(iGateWidthRondPt < MAX_ROUND_POINT && iGateWidthRondPt >0)
	{
		if(xHorizontalScal)//横向放大了
		{
			if(iScalPoints_HorScal != 0 )
				iGateWidthRdPt_Hmi =KS_ROUND(((float)iGateWidthRondPt / iScalPoints_HorScal * HMI_DISPLAY_RESOLUTION));
		}
		else //不放大，默认是按照4000个原始数据处理
		{
			iGateWidthRdPt_Hmi =KS_ROUND(((float)iGateWidthRondPt / MAX_ROUND_POINT * HMI_DISPLAY_RESOLUTION));
		}
	}

	return  iGateWidthRdPt_Hmi;
}
//为了演示使用做的粗采样显示处理@4000个点,不是特别严谨。处理完后再写回去
void KSRoundDataDisplayDeal(uint16_t uiDoorPos,uint8_t RoundData[],uint8_t value_wr, uint16_t RemainNum_F,uint16_t RemainNum_B,uint8_t xScale)
{
	uint16_t max_num = 800;//根据处理的粗采样个数计算@最好能和4000整除
	uint16_t points = 4000 / max_num;
	uint16_t uiDoorPosPoints = uiDoorPos/points;//转换到800个点位置
	int16_t i = 0;
	if(RemainNum_F ==0 || RemainNum_F >=max_num || RemainNum_B ==0 || RemainNum_B >=max_num )
		return;

	if(xScale)//临时凑的
	{
		points = 1600 / max_num;
		uiDoorPosPoints = 400 ;
	}

	//保留波门附近数据|其他写0
	uint16_t clearPosSa = uiDoorPosPoints + RemainNum_B;
	clearPosSa = clearPosSa % max_num;
	uint16_t clearPosEd = uiDoorPosPoints + max_num - RemainNum_F;
	clearPosEd = clearPosEd % max_num;

	//清理其他区域
	if(clearPosEd > clearPosSa)
	{
		for(i = clearPosSa;i<=clearPosEd;i++)
		{
			if(RoundData[i] > value_wr) RoundData[i] = value_wr;
			else;//保持不变
		}
	}
	else
	{
		for(i = 0;i<clearPosEd;i++)
		{
			if(RoundData[i] > value_wr) RoundData[i] = value_wr;
			else;//保持不变
		}

		for(i = clearPosSa;i<max_num - 1;i++)
		{
			if(RoundData[i] > value_wr) RoundData[i] = value_wr;
			else;//保持不变
		}
	}

	return;
}

