/*
 * AutoFindTaps.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */
#include "AutoFindTaps.h"
#include "base.h"
#include <stdlib.h>//处理abs()使用报警
#include "calcerr.h"
#include "KS_FB_VISU.h"

void KS_FB_FindSignal(
		uint8_t* i_pbyData,//数据起始
		short i_iLength,//数据长度
		float i_rBase_Positive,//数据判断阀值
		StAutoFindSignalDetail* i_pstStAutoFindSignalDetail)
{
	uint8_t* pData;
	short iN;
	short iNext_1;
	short iNext_2;
	short iNext_3;

	float rTemp_Sum;
	//变量定义
	if(i_pbyData!=0 && i_iLength>0 && i_rBase_Positive!=0 && i_pstStAutoFindSignalDetail!=0)
	{
		//滤波处理一下，同时做一次一阶导数
		pData= i_pbyData;
		for(iN=0 ; iN<i_iLength ; iN++)
		{
			if(iN<2)
			{
				i_pstStAutoFindSignalDetail->abyData_Sample_Temp[iN]= *pData;//前两个点的滤波处理
				i_pstStAutoFindSignalDetail->abySampData_Filtered[iN]= *pData;
			}
			else
			{
				i_pstStAutoFindSignalDetail->abyData_Sample_Temp[2]= *pData;
				rTemp_Sum= (float)((short)(i_pstStAutoFindSignalDetail->abyData_Sample_Temp[0])+
											(short)(i_pstStAutoFindSignalDetail->abyData_Sample_Temp[1])+
												(short)(i_pstStAutoFindSignalDetail->abyData_Sample_Temp[2]))/(float)3.0;
				i_pstStAutoFindSignalDetail->abyData_Sample_Temp[0]=
													i_pstStAutoFindSignalDetail->abyData_Sample_Temp[1];
				i_pstStAutoFindSignalDetail->abyData_Sample_Temp[1]=
													i_pstStAutoFindSignalDetail->abyData_Sample_Temp[2];
				i_pstStAutoFindSignalDetail->abySampData_Filtered[iN]=(uint8_t)rTemp_Sum;
			}

			//然后把大于阀值的值全部处理成阀值
			if(i_pstStAutoFindSignalDetail->abySampData_Filtered[iN]>=i_rBase_Positive)
			{
				i_pstStAutoFindSignalDetail->abySampData_Filtered[iN]= (uint8_t)i_rBase_Positive;
			}
			//求出一阶导数
			if(iN>0)
			{
				i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]=
						(signed char)((short)i_pstStAutoFindSignalDetail->abySampData_Filtered[iN]-
							(short)i_pstStAutoFindSignalDetail->abySampData_Filtered[iN-1]);
			}
			if(iN==i_iLength-1)
			{
				i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[0]=
						(signed char)((short)i_pstStAutoFindSignalDetail->abySampData_Filtered[0]-
							(short)i_pstStAutoFindSignalDetail->abySampData_Filtered[iN]);
			}
			pData++;
		}
		//先对一些变量进行清零处理
		i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=0;
		i_pstStAutoFindSignalDetail->iNum_Positive=0;
		i_pstStAutoFindSignalDetail->iNum_Negative=0;
		i_pstStAutoFindSignalDetail->iNum_Mid=0;
		i_pstStAutoFindSignalDetail->byFlag_FirstSignal_Negative=0;
		i_pstStAutoFindSignalDetail->byNum_Signal=0;
		for(iN=0;iN<100;iN++)
		{
			i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[iN]=0;
			i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[iN]=0;
			i_pstStAutoFindSignalDetail->aiPosValue_Signal_Positive[iN]=0;
			i_pstStAutoFindSignalDetail->aiPosValue_Signal_Negative[iN]=0;
			i_pstStAutoFindSignalDetail->aiPosValue_Signal_Mid[iN]=0;
			i_pstStAutoFindSignalDetail->aiPosValue_Signal_Width[iN]=0;
		}

		//以下找到的色标，记录细节是从数组1开始，1对应第一个色标，0暂时未用，99用于存储特殊位置的细节（目前用于存储零位后的半个色标细节）
		for(iN=1;iN<i_iLength;iN++)
		{
			iNext_1=iN+1;
			iNext_2=iN+2;
			iNext_3=iN+3;
			if(iNext_1>i_iLength-1)
			{
				iNext_1= iNext_1-i_iLength;
			}
			if(iNext_2>i_iLength-1)
			{
				iNext_2= iNext_2-i_iLength;
			}
			if(iNext_3>i_iLength-1)
			{
				iNext_3= iNext_3-i_iLength;
			}
			switch(i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step)
			{
				case 0://默认阀值线下的全部不参与色标判断
					if(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]>=2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1]>=2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2]>=2 )
					{//说明最后一个色标的一半在起始位置
						//这里就需要记录一下下降沿的点数，再去找第一个色标
						i_pstStAutoFindSignalDetail->iNum_Negative++;
						i_pstStAutoFindSignalDetail->byFlag_FirstSignal_Negative=2;//最前面是有半个色标的
					}
					else if(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2]<=-2 )
					{//认为是一个色标的起始
						if(i_pstStAutoFindSignalDetail->byFlag_FirstSignal_Negative==2)//记录一下开始的半个色标细节
						{
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_Negative[99]= i_pstStAutoFindSignalDetail->iNum_Negative;
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[99]= iN;
							i_pstStAutoFindSignalDetail->byFlag_FirstSignal_Negative=0;//细节记录完成
							i_pstStAutoFindSignalDetail->iNum_Negative=0;
						}
						i_pstStAutoFindSignalDetail->byNum_Signal++;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]= iN;
						i_pstStAutoFindSignalDetail->iNum_Positive=1;//从0开始统计
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=1;//开始去统计一下上升沿的点数
					}
					if(i_pstStAutoFindSignalDetail->byFlag_FirstSignal_Negative==2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_3])<2)
					{
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Negative[99]= i_pstStAutoFindSignalDetail->iNum_Negative;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[99]= iN;
						i_pstStAutoFindSignalDetail->byFlag_FirstSignal_Negative=0;//细节记录完成
						i_pstStAutoFindSignalDetail->iNum_Negative=0;
					}
					break;
				case 1://进入一个色标的判断范围-这里开始统计上升沿的细节
					i_pstStAutoFindSignalDetail->iNum_Positive++;
					if(	ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_3])<2)
					//出现了一个拐点，是不是这个色标的前半段统计完成了-先就不继续统计上升沿了
					{
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Positive[i_pstStAutoFindSignalDetail->byNum_Signal]=
								i_pstStAutoFindSignalDetail->iNum_Positive;
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=2;//去统计拐点那里的点数宽度
						i_pstStAutoFindSignalDetail->iNum_Mid= 1;
					}
					else if(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]>=2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1]>=2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2]>=2 )//拐点过于短暂直接开始统计下降沿点数
					{
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=3;//去统计下降沿那里的点数宽度
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Positive[i_pstStAutoFindSignalDetail->byNum_Signal]=
								i_pstStAutoFindSignalDetail->iNum_Positive;
						i_pstStAutoFindSignalDetail->iNum_Positive=0;
						i_pstStAutoFindSignalDetail->iNum_Negative=1;
					}
					break;
				case 2://色标顶部的地方要注意一下，下一步色标走向是下降还是上升，如果出现了一个上升沿+拐点+上升沿的情况，可能这里有一部分是基线有点高的地方，重置色标的起始位置
					i_pstStAutoFindSignalDetail->iNum_Mid++;
					if(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2]<=-2)
					//有连续的四个点上升，干脆重新开始统计上升沿去吧，这里算是色标新的起始位置
					{
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]= iN;
						i_pstStAutoFindSignalDetail->iNum_Positive=1;//从0开始统计
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=1;//开始去统计一下上升沿的点数
					}
					else if(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]>=2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1]>=2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2]>=2)//开始下降了2024.7.1.145337
					{
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Mid[i_pstStAutoFindSignalDetail->byNum_Signal]= i_pstStAutoFindSignalDetail->iNum_Mid;
						i_pstStAutoFindSignalDetail->iNum_Mid=0;//从0开始统计
						i_pstStAutoFindSignalDetail->iNum_Negative=1;//从0开始统计
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=3;//开始去统计一下下降沿的点数
					}
					break;
				case 3://色标开始下降了
					//下降过程中如果出现上升沿-暂且当上一个色标结束了，重新开始统计新一个色标
					//下降过程中遇到拐点，也当这个色标结束，重新开始，等下一个色标
					i_pstStAutoFindSignalDetail->iNum_Negative++;
					if(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2]<=-2)
					//连续四个点负值，出现了上升沿，则认为前一个色标结束了，统计一下色标细节
					{
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Negative[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_pstStAutoFindSignalDetail->iNum_Negative;
						i_pstStAutoFindSignalDetail->iNum_Negative=0;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]=iN-1;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Width[i_pstStAutoFindSignalDetail->byNum_Signal]=
								i_pstStAutoFindSignalDetail->aiPosValue_Signal_Positive[i_pstStAutoFindSignalDetail->byNum_Signal]+
								i_pstStAutoFindSignalDetail->aiPosValue_Signal_Mid[i_pstStAutoFindSignalDetail->byNum_Signal]+
								i_pstStAutoFindSignalDetail->aiPosValue_Signal_Negative[i_pstStAutoFindSignalDetail->byNum_Signal];
						i_pstStAutoFindSignalDetail->byNum_Signal++;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]= iN;
						i_pstStAutoFindSignalDetail->iNum_Positive=1;//重新开始新色标的统计
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=1;//去上面再开始统计了

					}
					else if(ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2])<2 &&
								ABS(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_3])<2)
					//色标在下降过程中平了，色标结束
					{
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Negative[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_pstStAutoFindSignalDetail->iNum_Negative;
						i_pstStAutoFindSignalDetail->iNum_Negative=0;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]=iN-1;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Width[i_pstStAutoFindSignalDetail->byNum_Signal]=
								i_pstStAutoFindSignalDetail->aiPosValue_Signal_Positive[i_pstStAutoFindSignalDetail->byNum_Signal]+
								i_pstStAutoFindSignalDetail->aiPosValue_Signal_Mid[i_pstStAutoFindSignalDetail->byNum_Signal]+
								i_pstStAutoFindSignalDetail->aiPosValue_Signal_Negative[i_pstStAutoFindSignalDetail->byNum_Signal];
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=4;//去等下一个色标上升沿吧
					}
					break;
				case 4:
					if(i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iN]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_1]<=-2 &&
							i_pstStAutoFindSignalDetail->asiSampData_FirstDerivative[iNext_2]<=-2)
					//连续四个点负值，出现了上升沿，统计一下色标细节
					{
						i_pstStAutoFindSignalDetail->byNum_Signal++;
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]= iN;
						i_pstStAutoFindSignalDetail->iNum_Positive=1;//重新开始新色标的统计
						i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step=1;//去上面再开始统计了
					}
					break;
			}

			if(iN==i_iLength-1)//倒最后一个点后，判断一下在统计的色标有没有结束
			{
				if(i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step!=4)
				{
					if(i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step==2 || i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step==3)
					{
						if(i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[99]!=0)
						{
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[99];
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_Width[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]+
									(i_iLength-i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]);
						}
						else
						{
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_iLength-1;
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_Width[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]+
									(i_iLength-i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]);
						}
					}
					else if(i_pstStAutoFindSignalDetail->iStatue_Find_Signal_Step==1)
					{
						if(i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[99]!=0)
						{
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[99];
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_Width[i_pstStAutoFindSignalDetail->byNum_Signal]=
									i_pstStAutoFindSignalDetail->aiPosValue_Signal_End[i_pstStAutoFindSignalDetail->byNum_Signal]+
									(i_iLength-i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]);
						}
						else
						{
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[1]=
									i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal];
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_Positive[1]=
									i_pstStAutoFindSignalDetail->aiPosValue_Signal_Positive[1]+
									i_pstStAutoFindSignalDetail->iNum_Positive;
							i_pstStAutoFindSignalDetail->iNum_Positive=0;
							i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[i_pstStAutoFindSignalDetail->byNum_Signal]=0;
							i_pstStAutoFindSignalDetail->byNum_Signal= i_pstStAutoFindSignalDetail->byNum_Signal-1;
						}
					}
				}
			}
		}
		//最后这里处理一下色标间隔
		if(i_pstStAutoFindSignalDetail->byNum_Signal>2)
		{
			for(iN=2;iN<=i_pstStAutoFindSignalDetail->byNum_Signal;iN++)
			{
				i_pstStAutoFindSignalDetail->aiDetal_Signal[iN-1]=
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[iN]-
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[iN-1];
			}
			i_pstStAutoFindSignalDetail->aiDetal_Signal[i_pstStAutoFindSignalDetail->byNum_Signal]=
						i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[1]+
						(i_iLength-i_pstStAutoFindSignalDetail->aiPosValue_Signal_Start[iN]);
		}
	}
	else
	{
		//输入参数非法-输出异常标志
	}
}

