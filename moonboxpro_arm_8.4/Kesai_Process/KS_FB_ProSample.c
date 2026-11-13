/*
 * KS_FB_ProSample.c
 *
 *  Created on: Jul 30, 2024
 *      Author: 17500
 */

#include "calcerr.h"
#include "base.h"
#include "KS_FB_ProSample.h"
#include "comm.h"
#include "KesaiAPI.h"
#include "led.h"
#include "KS_FB_VISU.h"
#include "calcbase.h"
#include "KS_RsRootBaseline.h"//wang.c 2026.10.26.110221 新增包含(自moonbox baseline版移植)：根部估计基线分支开关宏USE_RS_ROOT_BASELINE
//wang.c 2026.10.26.110221 8.4从站ProSample无i_pstStGlobalParam参数,用main.c的全局stStGlobalParam
extern StGlobalParam stStGlobalParam;
//新飞点剔除模块(总开关KS_USE_NEW_FLY_REMOVE在此头文件内)|Yang.zj+用于新飞点检测 2026.10.24.103254
#include "ks_fly_remove.h"
//双置信度融合误差模块(总开关KS_USE_CONF_ERR在此头文件内,编译期宏直接接入误差链路,
//自老架构ARM移植去运行期开关化)|Yang.zj+置信度迁移8.4 2026.11.13.112036
#include "ks_conf_err.h"

//计算误差输入明细
StCalcParam_In stStCalcParam_In;
//计算误差输出明细
StCalcParam_Out stStCalcParam_Out;
//飞点剔除输入明细
StPickOutFakePointIn stStPickOutFakePointIn;

//2026.4.21.153614  屏蔽新算法的使用
//StCalcParam_Use_New stStCalcParam_Use_New;

void KS_FB_ProSample(StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,	//上行参数
			WORD* i_puiFineData1,										//精采样数据起始地址T1
			WORD* i_puiFineData2,										//精采样数据起始地址T2
			INT i_iFineSampleFlag,										//精采样数据采集到位
			StAxisParam* i_pstStAxisParam,								//轴参数
			StGrpParam* i_pstStGrpParam	,								//系参数
			REAL i_alrBase[2],
			INT o_aiError_V[40],//2022.3.21.110119
			INT o_aiError_H[40],
			INT aiFineSample_Data[9],
			BYTE* i_pxOK_PosConfirmed,
			BYTE i_xOK_FromMaster,
			REAL o_alrThreshold[2],
			REAL o_alrBase_Fs[2],
			BYTE *i_pbyRSdata1,//2022.5.17.152932
			BYTE *i_pbyRSdata2,
			BYTE i_xFlag_SingleMode)
{
	//色组->主站
	//5#命令
    //StCMD_05* pstStCMD_05;
	//有效误差判断也分开2023.5.24.102943(仅旧飞点算法使用|Yang.zj+用于新飞点检测 2026.10.24.103254)
#if !KS_USE_NEW_FLY_REMOVE
	BYTE xErrorIsValid_V = 0;//有效误差
	BYTE xErrorIsValid_H = 0;//有效误差
#endif
	//飞点标志也分开2023.5.24.103248
	BYTE xFakePoint_V = 0;//误差剔除飞点
	BYTE xFakePoint_H = 0;//误差剔除飞点
	static WORD uiFSampleCount = 0;//精采样幅数
	INT iN = 0;
	BYTE byTemp = 0;
	BYTE xFlag_HorEn = 0;//横向开关

	BYTE xFlag_Follow_Other_V = 0;//纵向跟任意色
	BYTE xFlag_Follow_Other_H = 0;//横向跟任意色2023.4.25.161302
	REAL rSysPrecision = 0.02;
	DWORD dwAdrStCalcParam_In;
	DWORD dwAdrStCalcParam_Out;

	//2025.12.19.142433//xi.hy//处理联系三幅丢失才上报
	static uint16_t uiCount_ErrorLost=0;

	//----------------------------定义变量结束---------------------------//

#if KS_USE_NEW_FLY_REMOVE
	/*新飞点剔除状态复位:工况切换时可信历史不可信,必须清掉重新暖机
	 *①色标排列模式切换(标记方式/跟踪色变了,误差电平和噪声特性都变)
	 *②横向开关切换(横向误差链路通断,横向剔除器单独复位)
	 *RGB通道切换的复位在main.c里通道切换检测处|Yang.zj+用于新飞点检测 2026.10.24.103254*/
	{
		static INT iMarkArrangeModal_FlyPre = -1;//上次色标排列模式
		static BYTE xFlag_HorEn_FlyPre = 0xFF;//上次横向开关
		BYTE xFlag_HorEn_FlyTmp;//当前横向开关
		xFlag_HorEn_FlyTmp = GetBit(i_pstStAxisParam->wSwitchRef, 0);
		if(iMarkArrangeModal_FlyPre != i_pstStAxisParam->iMarkArrangeModal)
		{
			iMarkArrangeModal_FlyPre = i_pstStAxisParam->iMarkArrangeModal;
			KS_FlyRemove_Reset_V();
			KS_FlyRemove_Reset_H();
		}
		if(xFlag_HorEn_FlyTmp != xFlag_HorEn_FlyPre)
		{
			xFlag_HorEn_FlyPre = xFlag_HorEn_FlyTmp;
			KS_FlyRemove_Reset_H();
		}
	}
#endif

	//标志位|门内基线|极性
	stStCalcParam_In.i_wParsingKeyWord=0;

	byTemp = GetBit(i_pstStAxisParam->wSwitchRef,1);
	stStCalcParam_In.i_wParsingKeyWord = SetBit(byTemp, stStCalcParam_In.i_wParsingKeyWord, 15);

	stStCalcParam_In.i_wParsingKeyWord|= 1<<14;//(*基线多校正一次|*)

	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,12);
	stStCalcParam_In.i_wParsingKeyWord = SetBit(byTemp, stStCalcParam_In.i_wParsingKeyWord, 11);

	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,11);
	stStCalcParam_In.i_wParsingKeyWord = SetBit(byTemp, stStCalcParam_In.i_wParsingKeyWord, 10);

	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,16);
	//月光宝盒pro时反极性需要取反使用|故屏蔽下面的代码@2025.7.23.202948
//	if(byTemp == 0)
//	{
//		byTemp = 1;
//	}
//	else if(byTemp == 1)
//	{
//		byTemp = 0;
//	}
	stStCalcParam_In.i_wParsingKeyWord = SetBit(byTemp, stStCalcParam_In.i_wParsingKeyWord, 7);

	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,15);
	//月光宝盒pro时反极性需要取反使用|故屏蔽下面的代码@2025.7.23.202948
//	if(byTemp == 0)
//	{
//		byTemp = 1;
//	}
//	else if(byTemp == 1)
//	{
//		byTemp = 0;
//	}
	stStCalcParam_In.i_wParsingKeyWord = SetBit(byTemp, stStCalcParam_In.i_wParsingKeyWord, 6);

	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,6);
	//月光宝盒pro时反极性需要取反使用|故屏蔽下面的代码@2025.7.23.202948
//	if(byTemp == 0)
//	{
//		byTemp = 1;
//	}
//	else if(byTemp == 1)
//	{
//		byTemp = 0;
//	}
	stStCalcParam_In.i_wParsingKeyWord = SetBit(byTemp, stStCalcParam_In.i_wParsingKeyWord, 5);

	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,5);
	//月光宝盒pro时反极性需要取反使用|故屏蔽下面的代码@2025.7.23.202948
//	if(byTemp == 0)
//	{
//		byTemp = 1;
//	}
//	else if(byTemp == 1)
//	{
//		byTemp = 0;
//	}
	stStCalcParam_In.i_wParsingKeyWord = SetBit(byTemp, stStCalcParam_In.i_wParsingKeyWord, 4);
	//屏蔽下面赋值，统一在跨色处理的地方赋值|2024.2.17.093347

	stStCalcParam_In.i_byAverage_h=i_pstStAxisParam->iAverage_H;//横向误差平均
	stStCalcParam_In.i_byAverage_v=i_pstStAxisParam->iAverage_V;//纵向误差平均
	stStCalcParam_In.i_diGateAbsOffsetPhy=i_pstStAxisParam->diArgumentToXW;
	stStCalcParam_In.i_iAdjustH=(INT)(i_pstStAxisParam->lrAdjust_H*100);//横向误差修正量
	stStCalcParam_In.i_iAdjustV=(INT)(i_pstStAxisParam->lrAdjust_V*100);//纵向误差修正量
	stStCalcParam_In.i_iEachGatePointsNr=i_pstStAxisParam->iGateWidthFinePt;//波门占据精采样点数
	stStCalcParam_In.i_iFilterPoints=3;//滤波次数
	stStCalcParam_In.i_iGateSa=i_pstStAxisParam->iGateSa;//波门起始地址
	stStCalcParam_In.i_iGateSaEx=i_pstStAxisParam->iGateSaEx;
	stStCalcParam_In.i_iGateWidthPhy=i_pstStAxisParam->iGateWidthPhy;//波门宽度
	stStCalcParam_In.i_iMarkArrangeId=i_pstStAxisParam->iMarkArrangeModal;//标记排列形式
	stStCalcParam_In.i_iMarkHLen=i_pstStGrpParam->byTriMark_SideB;//梯形标记直边
	stStCalcParam_In.i_iMarkTypId=i_pstStAxisParam->iMarkTypeId;//标记形式
	stStCalcParam_In.i_iMarkVLen=i_pstStGrpParam->byTriMark_SideC;//梯形标记斜边//2024.8.29.142300严重bug
	stStCalcParam_In.i_iRSamplePointsNum=4000;//粗采样点数
	stStCalcParam_In.i_iStandardMarkSpacings=2000;

	rSysPrecision= 0.02;
	//实际使用的精度值在非双波门情况下也使用。@2023.08.03.173658
	if(/*stStCalcParam_In.i_xFlag_Gate_double &&*/ i_pstStAxisParam->lrInversedPrecision!=0)
	{rSysPrecision= (i_pstStAxisParam->lrInversedPrecision);}
	stStCalcParam_In.i_rSysPrecision= rSysPrecision;

	stStCalcParam_In.i_iThresNum=3;//阀值线数量
	stStCalcParam_In.i_lrGirth=i_pstStAxisParam->lrGirth;//版周长
	//2024.02.26.111525 小信号阀值
	//008光电眼@10v供电	0--65535 对应0--10v
	//012光电眼@+-10v供电，0--65535 对应-10v--10v
	//使用双极性是否打开进行判断

	BYTE xInclNegative10vSignal = GetBit(i_pstStAxisParam->wSwitchRef,9);//获取双极性开关标志
	if(xInclNegative10vSignal)
	{//双极性
		//2025.9.20.133509 同步 by liu.yt,只支持月光宝盒pro
		//2025.09.20.131701//xi.hy//根据设备类型进行区分，先直接用数字，后续增加宏
//		if(i_byType_Device==1)//月光宝盒
//		{
//			stStCalcParam_In.i_lrMinimumLimitSampVal=655;//655=0.2V/20*65535; 		//1598;
//			stStCalcParam_In.i_lrSmallSignalValue=1638;//1638=0.5V/10*65535;		//3994;
//		}
//		else//月光宝盒Pro
//		{
			//stStCalcParam_In.i_lrMinimumLimitSampVal=1986;//1986=0.2V/6.6*65535;
			//stStCalcParam_In.i_lrSmallSignalValue=4965;//4965=0.5V/6.6*65535;
			//固高了解最大电压范围应该时+-2.83@最大范围时5.66|2025.10.31.084118
			stStCalcParam_In.i_lrMinimumLimitSampVal=2315;//1986=0.2V/5.66*65535;
			stStCalcParam_In.i_lrSmallSignalValue=5789;//4965=0.5V/5.66*65535;
//		}
	}
	else
	{//单极性
		stStCalcParam_In.i_lrMinimumLimitSampVal=1311;//1311=0.2V/10*65535;     //1598;
		stStCalcParam_In.i_lrSmallSignalValue=3277;//3277=0.5V/10*65535;        //3994;
	}

	stStCalcParam_In.i_alrBase[0]= i_alrBase[0];
	stStCalcParam_In.i_alrBase[1]= i_alrBase[1];
#if USE_RS_ROOT_BASELINE
	//wang.c 2026.10.26.110221 新增(自moonbox baseline版移植)：打包粗采样形态学根部估计基线(8bit粗采样域)
	//fRootBaseLine由KsGetSampleInf_V2每圈刷新|calcerr门内基线分支宏为1时用它×256替代传统门内基线
	//0=尚未算出时calcerr自动回退传统算法
	stStCalcParam_In.i_alrRootBase[0]= stStGlobalParam.fRootBaseLine_T1;
	stStCalcParam_In.i_alrRootBase[1]= stStGlobalParam.fRootBaseLine_T2;
#endif

	//stStCalcParam_In.alrScopeLevelRatio[0]=0.5;
	//2025.12.24.084044//xi.hy//计算误差打阈值在1/5位置@陈总建议
	stStCalcParam_In.alrScopeLevelRatio[0]=0.2;
	stStCalcParam_In.alrScopeLevelRatio[1]=0.25;
	stStCalcParam_In.alrScopeLevelRatio[2]=0.75;
	//2023.5.24.102713去地址2023.5.24.102719
	dwAdrStCalcParam_In= (DWORD)&stStCalcParam_In;
	dwAdrStCalcParam_Out= (DWORD)&stStCalcParam_Out;

	//单标记||2020.6.24.160749||niu.j|使用单元盒的处理
	stStCalcParam_In.i_xOMK0_PosConfirmed = (*i_pxOK_PosConfirmed) | i_xOK_FromMaster;//单标记误差确认
	//增加跨色印刷部分处理|2024.2.17.092907
	//stStCalcParam_In.i_byColorId_Cur-1 的含义已经变成了当前色和跟踪色间隔的距离了@+1是因为在使用的时候-1 了
	if(i_pstStAxisParam->byColorIdCurrent>i_pstStAxisParam->byFollowColorId && i_pstStAxisParam->byFollowColorId!=0)
	{//增加条件@2024.02.19.103034
		stStCalcParam_In.i_byColorId_Cur = i_pstStAxisParam->byColorIdCurrent - i_pstStAxisParam->byFollowColorId + 1;
	}
	else if(i_pstStAxisParam->byFollowColorId==0)
	{//跟踪的id=0 赋值为当前色序
										//@在主站打开双波门的时候,是原来的跟踪给第一色(解决在主站未同步更新的时候可能存在的问题)
		stStCalcParam_In.i_byColorId_Cur = i_pstStAxisParam->byColorIdCurrent;
	}
	stStCalcParam_In.i_xFlag_Gate_double = i_pstStAxisParam->xFlag_Gate_double;//双波门时候需要计算多组误差，单波门只计算一组
	stStCalcParam_In.i_xFlag_Follow_Other_V= GetBit(i_pstStAxisParam->wStatusRef,12);//2023.09.18.140856 wStatusRef.8作为了开关.12作为使用标志@liu.yt
	stStCalcParam_In.i_xFlag_Follow_Other_H= GetBit(i_pstStAxisParam->wStatusRef,9);

	//以上为计算误差锁需要的所有输入全部重新整理2023.5.24.102741
	//pstStCMD_05= (StCMD_05*)&i_pstStPara_PduBroadcastUp->abyPayload[0];//(*2018.8.22.180717\修复bug|*);
	if(i_iFineSampleFlag)//开始计算误差
	{
		//2026.4.22.143126 屏蔽
//		if(i_pstStAxisParam->xFlag_CalcErr_New)
//		{
//			//这里处理一下 2024.8.21.185311---------------------------------------
//			stStCalcParam_Use_New.i_xCalcErr_V_Single=1;
//			stStCalcParam_Use_New.i_xCalcErr_V_Follow_1U=1;
//			stStCalcParam_Use_New.i_xCalcErr_H_Single=1;
//			stStCalcParam_Use_New.i_xCalcErr_H_Follow_1U=1;
//
//			if(GetBit(i_pstStAxisParam->wStatusRef,12)==1)//纵向跟1色
//			{
//				if(GetBit(i_pstStAxisParam->wStatusRef,14)==1)
//				{
//					stStCalcParam_Use_New.i_xUseErr_V_Single=0;
//					stStCalcParam_Use_New.i_xUseErr_V_Follow_1U=1;	//双眼跟1色
//				}
//				else
//				{
//					stStCalcParam_Use_New.i_xUseErr_V_Single=1;//单眼跟1色
//					stStCalcParam_Use_New.i_xUseErr_V_Follow_1U=0;
//				}
//			}
//			else
//			{
//				stStCalcParam_Use_New.i_xUseErr_V_Single=0;
//				stStCalcParam_Use_New.i_xUseErr_V_Follow_1U=0;
//			}
//
//			if(GetBit(i_pstStAxisParam->wStatusRef,9)==1)//横向跟1色
//			{
//				if(GetBit(i_pstStAxisParam->wStatusRef,15)==1)
//				{
//					stStCalcParam_Use_New.i_xUseErr_H_Single=0;
//					stStCalcParam_Use_New.i_xUseErr_H_Follow_1U=1;			//双眼跟1色
//				}
//				else
//				{
//					stStCalcParam_Use_New.i_xUseErr_H_Single=1;//单眼跟1色
//					stStCalcParam_Use_New.i_xUseErr_H_Follow_1U=0;
//				}
//			}
//			else
//			{
//				stStCalcParam_Use_New.i_xUseErr_H_Single=0;
//				stStCalcParam_Use_New.i_xUseErr_H_Follow_1U=0;
//			}
//
//			//2024.8.27.090402
//			stStCalcParam_Use_New.i_rInversedPrecision= i_pstStAxisParam->lrInversedPrecision;
//			stStCalcParam_Use_New.i_iMarkArrangeModal= i_pstStAxisParam->iMarkArrangeModal;
//			stStCalcParam_Use_New.i_byColorIdCurrent= i_pstStAxisParam->byColorIdCurrent;
//			stStCalcParam_Use_New.i_byColorIdFollow= i_pstStAxisParam->byFollowColorId;
//			stStCalcParam_Use_New.i_iAverage_H= i_pstStAxisParam->iAverage_H;
//			stStCalcParam_Use_New.i_iAverage_V= i_pstStAxisParam->iAverage_V;
//			stStCalcParam_Use_New.i_rAdjust_H= i_pstStAxisParam->lrAdjust_H;
//			stStCalcParam_Use_New.i_rAdjust_V= i_pstStAxisParam->lrAdjust_V;
//			stStCalcParam_Use_New.i_byTriMark_SideC= i_pstStGrpParam->byTriMark_SideC;//  INT_TO_BYTE(g_iTriangleSideC);
//			stStCalcParam_Use_New.i_byTriMark_SideB= i_pstStGrpParam->byTriMark_SideB;
//			stStCalcParam_Use_New.i_byMarkTypeId= (unsigned char)(i_pstStAxisParam->iMarkTypeId);
//
//			byTemp = GetBit(i_pstStAxisParam->wSwitchRef,1);
//			stStCalcParam_Use_New.i_xCalcBaselineByData_FS_OR_RS = byTemp;
//
//			xInclNegative10vSignal = GetBit(i_pstStAxisParam->wSwitchRef,9);//获取双极性开关标志
//
//			if(xInclNegative10vSignal)
//			{//双极性
//				stStCalcParam_Use_New.i_rMinimumLimitSampVal=655;//655=0.2V/20*65535; 		//1598;
//			}
//			else
//			{//单极性
//				stStCalcParam_Use_New.i_rMinimumLimitSampVal=1311;//1311=0.2V/10*65535;     //1598;
//			}
//
//			stStCalcParam_Use_New.i_byThresNum= 3;
//
//			//2024.8.31.130414、、峰值进行滤波处理
//			stStCalcParam_Use_New.byNum_PeakValueFilter= i_pstStAxisParam->byFilterNum_PeakValue_FineData;
//
//			KS_CalcErr_ARC_New(
//								i_puiFineData1,//unsigned short* i_puiFSampleDataSa1,//精采样数据起始
//								i_puiFineData2,//unsigned short* i_puiFSampleDataSa2,
//								i_alrBase,//float i_arBase[2],
//								&stStCalcParam_Use_New//StCalcParam_Use_New* i_pstStCalcParam_Use_New
//							);
//
//			i_pstStAxisParam->iResult_V_Followpre= stStCalcParam_Use_New.iResult_V_Followpre;
//			i_pstStAxisParam->iResult_H_Followpre= stStCalcParam_Use_New.iResult_H_Followpre;
//			i_pstStAxisParam->iResult_V_Follow_1U= stStCalcParam_Use_New.iResult_V_Follow_1U;
//			i_pstStAxisParam->iResult_H_Follow_1U= stStCalcParam_Use_New.iResult_H_Follow_1U;
//			i_pstStAxisParam->iResult_V_Follow_1U_New= stStCalcParam_Use_New.iResult_V_Follow_1U_New;
//			i_pstStAxisParam->iResult_H_Follow_1U_New= stStCalcParam_Use_New.iResult_H_Follow_1U_New;
//		}
//		else //原来的计算方式2024.8.21.190253
//		{
			if(i_xFlag_SingleMode)//2022.5.17.152932
			{
				;//全部重新处理2024.8.17.152423|niu.j
			}
			else
			{
				//重新调用新的计算误差
				KS_CalcError_ARC(
						i_puiFineData1,
						i_puiFineData2,
						dwAdrStCalcParam_In,
						dwAdrStCalcParam_Out);
#if KS_USE_NEW_FLY_REMOVE
				//飞点剔除第四支路(升降速容忍)接线:Feed在KS_CalcError_ARC内,此处每拍
				//在其后通知Δv=本拍整机速度-上一拍(Feed后调用防反灌——飞点当拍自己的Δv
				//不提前入窗给自己放宽门槛;丢失拍同样推进速度窗,与仿真版run_online口径
				//一致;首拍无上一拍不入窗;速度源与仿真版"速度"列同源,主站31#广播换算
				//m/min)|Yang.zj+ 2026.11.09.161525
				{
					static REAL s_lrVelFlyPre = 0.0f;
					static BYTE s_xVelFlyPreValid = 0;
					if (s_xVelFlyPreValid)
					{
						KS_FlyRemove_NoteDv_V(i_pstStGrpParam->lrVelocity - s_lrVelFlyPre);
						KS_FlyRemove_NoteDv_H(i_pstStGrpParam->lrVelocity - s_lrVelFlyPre);
					}
						s_lrVelFlyPre = i_pstStGrpParam->lrVelocity;
						s_xVelFlyPreValid = 1;
					}
#endif
#if KS_USE_CONF_ERR
				//双置信度融合:每圈老链计算完成后运行(置信度公式自老架构ARM移植,信号源为
				//本圈stStCalcParam_Out的detail结构,详见ks_conf_err.c文件头);宏=1时融合误差
				//在下方上报处直接替换iVerror/iHerror——显示与误差链路不分家,无运行期开关/观察态
				//|Yang.zj+置信度迁移8.4 2026.11.13.112036
				KS_ConfErr_Process(i_pstStAxisParam, &stStCalcParam_In, &stStCalcParam_Out);
#endif
				//2025.7.26.091142+写入到轴参数中
				i_pstStAxisParam->arBase_use[0] = stStCalcParam_Out.arBase_use[0];
				i_pstStAxisParam->arBase_use[1] = stStCalcParam_Out.arBase_use[1];
				uint8_t index_t1 = 0,index_t2 = 0;//2025.7.30.092726+色标信息索引获取
				if(i_pstStAxisParam->xFlag_Gate_double)
				{
					if(xFlag_Follow_Other_V || xFlag_Follow_Other_H)//有跟踪任意色需求
					{
						if(i_pstStAxisParam->iMarkArrangeModal== MARK_ARRANGE_VFOR )
						{
							//2025.7.30.092932+
							index_t1 = 1;
							index_t2 = 0;

							o_alrThreshold[0] = stStCalcParam_Out.astStSignalParsingGroupDetail[1].alrThreshold[0][0]/256;
							o_alrThreshold[1] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrThreshold[1][0]/256;
							o_alrBase_Fs[0] = stStCalcParam_Out.astStSignalParsingGroupDetail[1].alrBase[0]/256;
							o_alrBase_Fs[1] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrBase[1]/256;

						}
						else if(i_pstStAxisParam->iMarkArrangeModal== MARK_ARRANGE_VREV)
						{
							//2025.7.30.092932+
							index_t1 = 0;
							index_t2 = 1;

							o_alrThreshold[0] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrThreshold[0][0]/256;
							o_alrThreshold[1] = stStCalcParam_Out.astStSignalParsingGroupDetail[1].alrThreshold[1][0]/256;
							o_alrBase_Fs[0] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrBase[0]/256;
							o_alrBase_Fs[1] = stStCalcParam_Out.astStSignalParsingGroupDetail[1].alrBase[1]/256;
						}
					}
				}
				else
				{
					o_alrThreshold[0] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrThreshold[0][0]/256;
					o_alrThreshold[1] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrThreshold[1][0]/256;
					o_alrBase_Fs[0] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrBase[0]/256;
					o_alrBase_Fs[1] = stStCalcParam_Out.astStSignalParsingGroupDetail[0].alrBase[1]/256;
				}
				i_pstStAxisParam->aiVerror_Gate[0]= stStCalcParam_Out.aiVerror_Gate[0];
				i_pstStAxisParam->aiVerror_Gate[1]= stStCalcParam_Out.aiVerror_Gate[1];
				i_pstStAxisParam->aiHerror_Gate[0]= stStCalcParam_Out.aiHerror_Gate[0];
				i_pstStAxisParam->aiHerror_Gate[1]= stStCalcParam_Out.aiHerror_Gate[1];


				//获取峰值到轴数据@2025.7.30.092643+
				i_pstStAxisParam->uiPeakValue_t1 = stStCalcParam_Out.astStSignalParsingGroupDetail[index_t1].auiMaxValue[0];
				i_pstStAxisParam->uiPeakValue_t2 = stStCalcParam_Out.astStSignalParsingGroupDetail[index_t2].auiMaxValue[1];
			}
		//}

		if(*i_pxOK_PosConfirmed)
		{
			*i_pxOK_PosConfirmed = 0;//单标记误差清零

			if(i_pstStAxisParam->iMarkArrangeModal==MARK_ARRANGE_OMK)//单标记方式下-误差确认按钮同时清零修正量
			{
				i_pstStAxisParam->lrAdjust_V=0;//2024.03.11.135417 确认的时候强制将修正量写0
			}
		}
		//飞点判断分开2023.5.24.103358
//		if((stStCalcParam_Out.o_iRtn_V!=0 && i_pstStAxisParam->xFlag_CalcErr_New==0) ||
//					(stStCalcParam_Use_New.o_iRtn_V!=0 && i_pstStAxisParam->xFlag_CalcErr_New==1))
		//2026.4.21.153727 屏蔽
		//误差有效标志只被下方旧飞点判断使用,新算法路径下不参与(丢失语义由o_iRtn_V分支处理)|
		//Yang.zj+用于新飞点检测 2026.10.24.103254
#if !KS_USE_NEW_FLY_REMOVE
		if(stStCalcParam_Out.o_iRtn_V!=0)
		//返回值为0代表误差有效
		{
			xErrorIsValid_V=0;
		}
		else
		{
			xErrorIsValid_V=1;
		}
#endif
		//剔除飞点初始化
		xFakePoint_V=0;
		//通讯获取飞点阈值@2024.7.31.172440(参数合法性钳位,新旧算法共用)
		if(i_pstStAxisParam->byFakeThreshold_V==0)
		{
			i_pstStAxisParam->byFakeThreshold_V = 5;//保持以前的
		}
		else if (i_pstStAxisParam->byFakeThreshold_V > 50)
		{
			i_pstStAxisParam->byFakeThreshold_V = 50;
		}
#if KS_USE_NEW_FLY_REMOVE
		//新飞点判定:剔除已在calcerr.c内N幅平均之前对原始误差完成
		//(飞点值被替换值替换:成熟账本≥3点且非振荡时为趋势外推P并刷锁存,否则锁存),
		//这里只取逐帧判定码置byStsV bit2;飞点/暂缓都算"本帧误差被替换上报"|
		//Yang.zj+用于新飞点检测 2026.10.24.103254|Yang.zj+ 2026.10.27.140301
		if(stStCalcParam_Out.o_byFlyFlag_V==KS_FLY_JUDGE_FAKE
			|| stStCalcParam_Out.o_byFlyFlag_V==KS_FLY_JUDGE_HOLD)
		{
			xFakePoint_V = 1;
		}
#else
		stStPickOutFakePointIn.i_xIsValidError=xErrorIsValid_V;
		//2026.4.21.153752屏蔽
//		if(i_pstStAxisParam->xFlag_CalcErr_New)
//		{
//			stStPickOutFakePointIn.i_iError_0_01mm=stStCalcParam_Use_New.o_iVResult;
//		}
//		else
//		{
			stStPickOutFakePointIn.i_iError_0_01mm=stStCalcParam_Out.o_iVResult;
		//}
		//stStPickOutFakePointIn.i_iVariationBaseValue=5;
		stStPickOutFakePointIn.i_iVariationBaseValue=(INT)i_pstStAxisParam->byFakeThreshold_V;//2024.7.31.172344替换
		stStPickOutFakePointIn.i_iBoundaryError_0_01mm=20;
		stStPickOutFakePointIn.i_iErrorLevel_0_01mm=25;
		stStPickOutFakePointIn.i_iVariationVariationMin=5;
		stStPickOutFakePointIn.i_iVariationVariationMax=50;//15;最大值修改到50@2024.7.31.172730
		KS_FB_PickOutFakePoint_V(stStPickOutFakePointIn,&xFakePoint_V);//误差剔除飞点
#endif
		//增加横向飞点判断
		//2026.4.21.153827 屏蔽
//		if((stStCalcParam_Out.o_iRtn_H!=0 && i_pstStAxisParam->xFlag_CalcErr_New==0) ||
//					(stStCalcParam_Use_New.o_iRtn_H!=0 && i_pstStAxisParam->xFlag_CalcErr_New==1))
		//误差有效标志只被旧飞点判断使用|Yang.zj+用于新飞点检测 2026.10.24.103254
#if !KS_USE_NEW_FLY_REMOVE
		if(stStCalcParam_Out.o_iRtn_H!=0)
		{
			xErrorIsValid_H=0;
		}
		else
		{
			xErrorIsValid_H=1;
		}
#endif
		//剔除飞点初始化
		xFakePoint_H=0;
		//通讯获取飞点阈值@2024.7.31.172440(参数合法性钳位,新旧算法共用)
		if(i_pstStAxisParam->byFakeThreshold_H==0)
		{
			i_pstStAxisParam->byFakeThreshold_H = 5;//保持以前的
		}
		else if(i_pstStAxisParam->byFakeThreshold_H > 50)
		{
			i_pstStAxisParam->byFakeThreshold_H = 50;
		}
#if KS_USE_NEW_FLY_REMOVE
		//新飞点判定:横向,同纵向|Yang.zj+用于新飞点检测 2026.10.24.103254
		if(stStCalcParam_Out.o_byFlyFlag_H==KS_FLY_JUDGE_FAKE
			|| stStCalcParam_Out.o_byFlyFlag_H==KS_FLY_JUDGE_HOLD)
		{
			xFakePoint_H = 1;
		}
#else
		stStPickOutFakePointIn.i_xIsValidError=xErrorIsValid_H;
		//2026.4.21.153843 屏蔽
//		if(i_pstStAxisParam->xFlag_CalcErr_New)
//		{
//			stStPickOutFakePointIn.i_iError_0_01mm=stStCalcParam_Use_New.o_iHResult;
//		}
//		else
//		{
			stStPickOutFakePointIn.i_iError_0_01mm=stStCalcParam_Out.o_iHResult;
		//}
		//stStPickOutFakePointIn.i_iVariationBaseValue=5;
		stStPickOutFakePointIn.i_iVariationBaseValue=(INT)i_pstStAxisParam->byFakeThreshold_H;
		stStPickOutFakePointIn.i_iBoundaryError_0_01mm=20;
		stStPickOutFakePointIn.i_iErrorLevel_0_01mm=25;
		stStPickOutFakePointIn.i_iVariationVariationMin=5;
		stStPickOutFakePointIn.i_iVariationVariationMax=50;//15;最大值修改到50@2024.7.31.172730
		KS_FB_PickOutFakePoint_H(stStPickOutFakePointIn,&xFakePoint_H);//误差剔除飞点
#endif

		//		(*byStsV/H位定义:
		//		* bit0: 报警|
		//		* bit1: 丢失|
		//		* bit2: 飞点|
		//		* bit3: 让料头|
		//		|*)

		i_pstStPara_PduBroadcastUp->byStsV= 0;
		i_pstStPara_PduBroadcastUp->byStsH= 0;
		//让料头
		//2026.4.21.153951 屏蔽
//		if((i_pstStAxisParam->xFlag_CalcErr_New==0 && stStCalcParam_Out.o_iRtn_V!=0) ||
//					(i_pstStAxisParam->xFlag_CalcErr_New==1 && stStCalcParam_Use_New.o_iRtn_V))//丢失
		if(stStCalcParam_Out.o_iRtn_V!=0)
		{
			//2025.12.19.140723//xi.hy//处理连续三幅丢失才上报
			uiCount_ErrorLost=uiCount_ErrorLost+1;
			if(uiCount_ErrorLost>=3)
			{
				i_pstStPara_PduBroadcastUp->iVerror= -32768;
				i_pstStPara_PduBroadcastUp->byStsV |= 0x01<<1;
			}
			else//在三幅内上报上一幅误差
			{
				i_pstStPara_PduBroadcastUp->iVerror= o_aiError_V[0];
			}

		}
		else
		{
			//2025.12.19.141950//xi.hy//处理连续三幅丢失才上报 清除计数
			uiCount_ErrorLost=0;
			//2026.4.21.154008 屏蔽
//			if(i_pstStAxisParam->xFlag_CalcErr_New)
//			{
//				i_pstStPara_PduBroadcastUp->iVerror= stStCalcParam_Use_New.o_iVResult;
//			}
			//			else
//			{
#if KS_USE_CONF_ERR
				//置信度融合误差接入(编译期宏):替换当圈上报值,下游报警判断/人机显示平均
				//自动跟随融合值|Yang.zj+置信度迁移8.4 2026.11.13.112036
				i_pstStPara_PduBroadcastUp->iVerror= KS_ConfErr_GetV();
#else
				i_pstStPara_PduBroadcastUp->iVerror= stStCalcParam_Out.o_iVResult;
#endif
				//}
			if(xFakePoint_V)//飞点
			{
				i_pstStPara_PduBroadcastUp->byStsV |= 0x01<<2;
			}
			//		报警标志检查
			if( (i_pstStAxisParam->wStatusRef & 0x01) &&//纵向自动
				ABS(i_pstStPara_PduBroadcastUp->iVerror) > ABS(i_pstStAxisParam->lrAlarm_V*100) )//大于报警值
			{
				i_pstStPara_PduBroadcastUp->byStsV |= 0x01<<0;
			}
		}
		//2026.4.21.154032 屏蔽
//		if((i_pstStAxisParam->xFlag_CalcErr_New==0 && stStCalcParam_Out.o_iRtn_H!=0) ||
//					(i_pstStAxisParam->xFlag_CalcErr_New==1 && stStCalcParam_Use_New.o_iRtn_H))//丢失
		if(stStCalcParam_Out.o_iRtn_H!=0)
		{
			i_pstStPara_PduBroadcastUp->iHerror= -32768;
			i_pstStPara_PduBroadcastUp->byStsH |= 0x01<<1;
		}
		else
		{
			//2026.4.21.154045屏蔽
//			if(i_pstStAxisParam->xFlag_CalcErr_New)
//			{
//				i_pstStPara_PduBroadcastUp->iHerror= stStCalcParam_Use_New.o_iHResult;
//			}
			//			else
//			{
#if KS_USE_CONF_ERR
				//置信度融合误差接入:横向,同纵向(编译期宏)|Yang.zj+置信度迁移8.4 2026.11.13.112036
				i_pstStPara_PduBroadcastUp->iHerror= KS_ConfErr_GetH();
#else
				i_pstStPara_PduBroadcastUp->iHerror= stStCalcParam_Out.o_iHResult;
#endif
				//}
			if(xFakePoint_H)//飞点
			{
				i_pstStPara_PduBroadcastUp->byStsH |= 0x01<<2;
			}

			//		报警标志检查
			if(	(i_pstStAxisParam->wSwitchRef & 0x01) &&//横向开关
				(i_pstStAxisParam->wStatusRef & 0x02) &&//横向自动
				ABS(i_pstStPara_PduBroadcastUp->iHerror) > ABS(i_pstStAxisParam->lrAlarm_H*100) )//大于报警值
			{
				i_pstStPara_PduBroadcastUp->byStsH |= 0x01<<0;
			}
		}
		//2020.6.10.200429||niu.j||横向开关关闭，误差上报为0
		xFlag_HorEn = GetBit(i_pstStAxisParam->wSwitchRef, 0);//横向开关
		if(xFlag_HorEn==0)
		{
			i_pstStPara_PduBroadcastUp->iHerror = 0;
		}
		//		iVErr_Test= (iVErr_Test+1) % 100;
		//		iHErr_Test= (iHErr_Test+1) % 100;
		//误差存储数据|2020.05.04.171602|niu.j///////////////////////////
		for( iN=39; iN>=1; iN-- )//2022.3.21.110202更新为数组40
		{
			o_aiError_V[iN] = o_aiError_V[iN-1];
			o_aiError_H[iN] = o_aiError_H[iN-1];
		}

		//START
		//2026.4.25.134939 对上报到人机的误差值做滤波处理@和主站的显示滤波关联
		//纵向误差显示平均
		int16_t iVerrorHmi = 0 ,iHerrorHmi = 0;//界面显示的误差
		uint8_t xAverageEnTmp = FALSE;//平均使能标志
		static uint8_t byDataCurIndex_V = 0,byDataCurIndex_H = 0;//数据当前索引
		static uint8_t xDataInitDne_V = FALSE ,xDataInitDne_H = FALSE;//平均初始化标志
		static int16_t aidatabuff_V[MAX_AVERAGE_NUM]={0};//纵向平均数据buff
		static int16_t aidatabuff_H[MAX_AVERAGE_NUM]={0};//纵向平均数据buff

		//纵向平均处理
		if(i_pstStAxisParam->byAve_v_extra_V>i_pstStAxisParam->iAverage_V)//需要界面显示平均
		{
			xAverageEnTmp = TRUE;
		}
		else
		{
			xAverageEnTmp = FALSE;
		}

		if(ABS(i_pstStPara_PduBroadcastUp->iVerror)>10000)//非法值就不要平均了
			iVerrorHmi = i_pstStPara_PduBroadcastUp->iVerror;//把非法值传上去
		else//数据正常就正常平均
		{
			iVerrorHmi =
				(int16_t)KS_Average(xAverageEnTmp,//平均使能
								i_pstStPara_PduBroadcastUp->iVerror,//数据
								i_pstStAxisParam->byAve_v_extra_V,//平均次数
								aidatabuff_V,//缓存的数组
								&byDataCurIndex_V,//当前的索引@从0开始
								&xDataInitDne_V);//平均的数据初始化完成

			if(!xAverageEnTmp)//不显示平均则使用原来的值
				//误差为非法值@则显示非法值不做平均
				iVerrorHmi = i_pstStPara_PduBroadcastUp->iVerror;
		}
		//横向平均处理
		if(i_pstStAxisParam->byAve_v_extra_V>i_pstStAxisParam->iAverage_H)//需要界面显示平均
		{
			xAverageEnTmp = TRUE;
		}
		else
		{
			xAverageEnTmp = FALSE;
		}

		if(ABS(i_pstStPara_PduBroadcastUp->iHerror)>10000)//非法值就不要平均了
			iHerrorHmi = i_pstStPara_PduBroadcastUp->iHerror;//把非法值传上去
		else//数据正常就正常平均
		{
			iHerrorHmi =
				(int16_t)KS_Average(xAverageEnTmp,//平均使能
								i_pstStPara_PduBroadcastUp->iHerror,//数据
								i_pstStAxisParam->byAve_v_extra_V,//平均次数
								aidatabuff_H,//缓存的数组
								&byDataCurIndex_H,//当前的索引@从0开始
								&xDataInitDne_H);//平均的数据初始化完成

			if(!xAverageEnTmp)//不显示平均则使用原来的值
				//误差为非法值@则显示非法值不做平均
				iHerrorHmi = i_pstStPara_PduBroadcastUp->iHerror;
		}

//		o_aiError_V[0] = i_pstStPara_PduBroadcastUp->iVerror;
//		o_aiError_H[0] = i_pstStPara_PduBroadcastUp->iHerror;
		o_aiError_V[0] = iVerrorHmi;
		o_aiError_H[0] = iHerrorHmi;

		//end

		//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>end>>>>>>>>>>>>>>>>>>>>

		//	(*han.dp@2017-04-20 18:01:19\继续准备上报的附加信息|*)
		i_pstStPara_PduBroadcastUp->byIndexV= i_pstStPara_PduBroadcastUp->byIndexV+1;//(*误差索引必须变更才会被主站处理*)
		i_pstStPara_PduBroadcastUp->byIndexH= i_pstStPara_PduBroadcastUp->byIndexH+1;//(*和纵向是同一幅*)

		uiFSampleCount= uiFSampleCount+1;//精采样计数值递增
		//2023.09.19.151629 移动位置@增加了6号命令以后这里的赋值会有问题,uiFSampleCounter修改为轴变量
		//pstStCMD_05->byIndexV= i_pstStPara_PduBroadcastUp->byIndexV;//纵向误差索引@没啥用就不管了
		//pstStCMD_05->byIndexH= i_pstStPara_PduBroadcastUp->byIndexH;//横向误差索引@没啥用就不管了
		//pstStCMD_05->uiFSampleCounter= uiFSampleCount;//计圈
		i_pstStAxisParam->uiFSampleCounter= uiFSampleCount;//计圈@赋值到轴参数中|2023.09.19.163852
	}
}



