/*
 * calcbase.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#include "calcbase.h"
#include "base.h"
#include "math.h"
#include "led.h"

//
//INT KS_AutoFindGate(
//					BYTE *i_pbyRSdata1,
//					INT i_iUseBase,
//					StAxisParam *i_pstStAxisParam,
//					INT i_iTotalPoints
//					)//自动寻址
//{
//		INT iN;
//		INT aiPosPoint[100];
//		INT aiInterValPoint[100];
//		BYTE* pbyItem;
//		BYTE* pbyLastItem;
//		BYTE* pbyNextItem;
//		static INT iPointNum;
//		BYTE  byMarkWidthMin;//波形宽度范围min
//		BYTE  byMarkWidthMax;//波形宽度范围Max
//		static BYTE  byMarkIntervalThreshold=15;//波形间隔宽度阀值10
//		static BYTE  byQualifiedMarkNum;
//
//		static INT iFirstMarkPoint=-1;
//		pbyItem = i_pbyRSdata1;
//		iPointNum = 0;
//		INT iGateAdrResult;
//		INT iTemp;
//		INT iMarkIntervalMin,iMarkIntervalMax;
//		byQualifiedMarkNum=0;
//
//		iFirstMarkPoint=-1;
//
//		for(iN=0; iN<i_iTotalPoints; iN++)
//		{
//			//计算前一个点的值和后一个点的值，用以判断交点2020.5.30.163918|niu.j
//			if(iN==0)//前一个点
//			{
//				pbyLastItem = pbyItem+3999;//起始点的前一个点是最后一个点
//			}
//			else
//			{
//				pbyLastItem = pbyItem-1;
//			}
//			if(iN==3999)//后一个点
//			{
//				pbyNextItem = pbyItem-3999;//最后一个点的下一个点是起始点
//			}
//			else
//			{
//				pbyNextItem = pbyItem+1;
//			}
//
//			//计算交点位置并保存
//			if((*pbyItem < i_iUseBase && *pbyLastItem >= i_iUseBase) ||  //前沿交点
//				(*pbyItem < i_iUseBase && *pbyNextItem >= i_iUseBase))		//后沿交点
//			{
//				if(iPointNum<100)
//				{
//					aiPosPoint[iPointNum] = iN;
//					iPointNum++;
//				}
//				else
//				{
//					break;
//				}
//			}
//			pbyItem+=1;
//		}
//		if(i_pstStAxisParam->iMarkTypeId==1)//根据色标形式选择宽度范围
//		{
//			byMarkWidthMin=1;
//			byMarkWidthMax=4;
//		}
//		else
//		{
//			byMarkWidthMin=3;
//			byMarkWidthMax=8;
//		}
//		//2020.5.30.170024||获取了交点位置信息
//		for(iN=1; iN<iPointNum; iN=iN+2)
//		{
//			aiInterValPoint[iN-1]=aiPosPoint[iN]-aiPosPoint[iN-1];
//			aiInterValPoint[iN]=aiPosPoint[iN+1]-aiPosPoint[iN];
//			//if( byMarkWidthMin <= aiInterValPoint[iN-1] <= byMarkWidthMax )
//			if( byMarkWidthMin <= aiInterValPoint[iN-1] && aiInterValPoint[iN-1] <= byMarkWidthMax )//2025.9.8.101837优化 liu.yt
//			{
//				byQualifiedMarkNum+=1;
//				if(byQualifiedMarkNum==1)
//				{
//					iFirstMarkPoint=iN-1;
//				}
//				if(byQualifiedMarkNum==i_pstStAxisParam->byColorIdCurrent)
//				{
//					if(i_pstStAxisParam->iMarkArrangeModal==2||i_pstStAxisParam->iMarkArrangeModal==4)
//					{
//						iGateAdrResult=(((aiPosPoint[iFirstMarkPoint+3]-aiPosPoint[iFirstMarkPoint+2])/2)
//														+aiPosPoint[iFirstMarkPoint+2]
//																-(i_pstStAxisParam->iGateWidthRondPt/2));
//					}
//					else if(i_pstStAxisParam->iMarkArrangeModal==1||i_pstStAxisParam->iMarkArrangeModal==3)
//					{
//						iGateAdrResult=(((aiPosPoint[iFirstMarkPoint+1+((byQualifiedMarkNum-1)*2)]
//													-aiPosPoint[iFirstMarkPoint+((byQualifiedMarkNum-1)*2)])/2)
//														+aiPosPoint[iFirstMarkPoint+((byQualifiedMarkNum-1)*2)]
//																-(i_pstStAxisParam->iGateWidthRondPt/2));
//					}
//					break;
//				}
//				else
//				{
//					iGateAdrResult=i_pstStAxisParam->iGateSa;
//				}
//				iTemp = (INT)((REAL)(aiInterValPoint[iN])*i_pstStAxisParam->lrGirth/i_iTotalPoints);
//				iMarkIntervalMin = 20-byMarkIntervalThreshold;
//				iMarkIntervalMax = 20+byMarkIntervalThreshold;
//
//				if(iTemp<iMarkIntervalMin || iTemp>iMarkIntervalMax)
//				{
//					byQualifiedMarkNum=0;
//					iFirstMarkPoint=-1;
//				}
//			}
//			else
//			{
//				byQualifiedMarkNum=0;
//				iFirstMarkPoint=-1;
//			}
//		}
//		if(iGateAdrResult>4000||iGateAdrResult<0)
//		{
//			iGateAdrResult=0;
//		}
//		return iGateAdrResult;
//	}

	void KS_CalcBaselineByData_RS(BYTE *i_pbyRSdata1,//粗采样数据T1入口地址
			BYTE* i_pbyRSdata2,//粗采样第二路入口地址；
			INT i_iTotalPoints,//粗采样数据点数|最大4000
			INT i_iZoomCoef,//由于精采样是16bits，粗采样数据8bits，所以放大系数默认256|
			BYTE i_xCalibrateTwice,
			REAL o_alrBase[2])//对找到的基线进行二次校准
	{
		static REAL alrBothSidesSumVal[2][2]	;//(*两边的分别累计值|1为上,2为下|*)
		static INT aiBothSidesTotalPts[2][2]	;//(*两边的统计点数|1为上,2为下|*)
		INT	iN					 	;//(*循环变量|*),iJ
		DINT adiSumVal[2]			 	;//(*累加和|*)
		BYTE* pbyItem1				;//(*采样点访问临时指针|*)
		BYTE* pbyItem2				;//(*采样点访问临时指针|*)
		REAL lrTemp				;//(*临时lreal型变量|*)
		REAL lrBaselineRef0[2]		;//(*隔直基线|*)
		REAL lrBaselineRef1[2]		;//(*隔直后二次平均的基线|*)
		REAL lrBaselineRef2[2]		;//(*基线重新整定|*)

		//变量定义结束
		if ((i_iTotalPoints>=1) && (i_iTotalPoints<=4000))
		{
			//(*取全部数据的均值0||*)
			pbyItem1= i_pbyRSdata1;//第一路波形地址
			pbyItem2= i_pbyRSdata2;//第二路波形地址
			adiSumVal[0]= 0;//初始化和值
			adiSumVal[1]= 0;//初始化
			for (iN=0; iN<i_iTotalPoints; iN++)//4000个点进行循环第一次
			{
				adiSumVal[0]= adiSumVal[0]+(*pbyItem1);
				pbyItem1= pbyItem1+1;

				adiSumVal[1]= adiSumVal[1]+(*pbyItem2);
				pbyItem2= pbyItem2+1;
			}
			lrBaselineRef0[0]= (REAL)adiSumVal[0]/(REAL)(i_iTotalPoints);
			lrBaselineRef0[1]= (REAL)adiSumVal[1]/(REAL)(i_iTotalPoints);
			//两路首次平均值计算
			//(*均值分割后的两部分数据再次获取均值||*)
			//T1部分初始化
			//(*超出均值0的部分|*)
			aiBothSidesTotalPts[0][0]= 0;//T1超出均值的部分
			alrBothSidesSumVal[0][0]= 0;//T1超出均值部分数据的总和

			//(*低于均值0的部分|*)
			aiBothSidesTotalPts[0][1]= 0;//T1低于均值的部分
			alrBothSidesSumVal[0][1]= 0;//T1低于均值部分数据总和

			//T2部分初始化
			//(*超出均值0的部分|*)
			aiBothSidesTotalPts[1][0]= 0;//T2超出均值的部分
			alrBothSidesSumVal[1][0]= 0; //T1超出均值部分数据的总和

			//(*低于均值0的部分|*)
			aiBothSidesTotalPts[1][1]= 0;//T2低于均值的部分
			alrBothSidesSumVal[1][1]= 0; //T2低于均值部分数据总和

			pbyItem1= i_pbyRSdata1;//T1地址
			pbyItem2= i_pbyRSdata2;//T2地址

			//第二次循环
			for (iN=0; iN<i_iTotalPoints; iN++)
			{
				///T1
				lrTemp= (REAL)(*pbyItem1);
				if (lrTemp>=lrBaselineRef0[0])
				{
					//(*高于均值0的部分|*)
					aiBothSidesTotalPts[0][0]= aiBothSidesTotalPts[0][0]+1;
					alrBothSidesSumVal[0][0]= alrBothSidesSumVal[0][0]+lrTemp;
				}
				else
				{
					//(*低于均值0的部分|*)
					aiBothSidesTotalPts[0][1]= aiBothSidesTotalPts[0][1]+1;
					alrBothSidesSumVal[0][1]= alrBothSidesSumVal[0][1]+lrTemp;
				}
				pbyItem1= pbyItem1+1;
				//T2
				lrTemp= (REAL)(*pbyItem2);
				if (lrTemp>=lrBaselineRef0[1])
				{
					//(*高于均值0的部分|*)
					aiBothSidesTotalPts[1][0]= aiBothSidesTotalPts[1][0]+1;
					alrBothSidesSumVal[1][0]= alrBothSidesSumVal[1][0]+lrTemp;
				}
				else
				{
					//(*低于均值0的部分|*)
					aiBothSidesTotalPts[1][1]= aiBothSidesTotalPts[1][1]+1;
					alrBothSidesSumVal[1][1]= alrBothSidesSumVal[1][1]+lrTemp;
				}
				pbyItem2= pbyItem2+1;
			}
			//>>>>>>>>第二次循环取出低于一次均值的部分数据总和及个数和高于一次均值的数据总和及个数
			//T1
			//(*取大多数作为参考标准|*)
			if (aiBothSidesTotalPts[0][0]>=aiBothSidesTotalPts[0][1]) //T1处理 - 数量多的部分数据求平均
			{
				if(aiBothSidesTotalPts[0][0]!=0)
				lrBaselineRef1[0]= alrBothSidesSumVal[0][0]/aiBothSidesTotalPts[0][0];
			}
			else
			{
				if(aiBothSidesTotalPts[0][1]!=0)
				lrBaselineRef1[0]= alrBothSidesSumVal[0][1]/aiBothSidesTotalPts[0][1];
			}
			//T2
			//(*取大多数作为参考标准|*)
			if (aiBothSidesTotalPts[1][0]>=aiBothSidesTotalPts[1][1])
			{
				if(aiBothSidesTotalPts[1][0]!=0)
				lrBaselineRef1[1]= alrBothSidesSumVal[1][0]/aiBothSidesTotalPts[1][0];
			}
			else
			{
				if(aiBothSidesTotalPts[1][1]!=0)
				lrBaselineRef1[1]= alrBothSidesSumVal[1][1]/aiBothSidesTotalPts[1][1];
			}
			//(*再次校准基线|*)
			if (i_xCalibrateTwice)
			{
				//T1初始化
				aiBothSidesTotalPts[0][0]= 0;
				alrBothSidesSumVal[0][0]= 0;

				aiBothSidesTotalPts[0][1]= 0;
				alrBothSidesSumVal[0][1]= 0;
				//T2初始化
				aiBothSidesTotalPts[1][0]= 0;
				alrBothSidesSumVal[1][0]= 0;

				aiBothSidesTotalPts[1][1]= 0;
				alrBothSidesSumVal[1][1]= 0;

				pbyItem1= i_pbyRSdata1;//两路地址
				pbyItem2= i_pbyRSdata2;
				//第三次循环
				lrTemp= (REAL)(*pbyItem1);
				if(lrBaselineRef1[0]!=lrBaselineRef0[0])
				{
					for (iN=0; iN<i_iTotalPoints; iN++)
					{
						if (lrBaselineRef1[0]>lrBaselineRef0[0])
						{
							if (lrTemp>=lrBaselineRef1[0])
							{
								//(*超过lrBaselineRef1的部分|*)
								aiBothSidesTotalPts[0][0]= aiBothSidesTotalPts[0][0]+1;
								alrBothSidesSumVal[0][0]= alrBothSidesSumVal[0][0]+lrTemp;
							}
							else if (lrTemp>lrBaselineRef0[0])
							{
								//(*介于lrBaselineRef0和lrBaselineRef1之间|*)
								aiBothSidesTotalPts[0][1]= aiBothSidesTotalPts[0][1]+1;
								alrBothSidesSumVal[0][1]= alrBothSidesSumVal[0][1]+lrTemp;
							}
						}
						else if (lrBaselineRef1[0]<lrBaselineRef0[0])
						{
							if (lrTemp<lrBaselineRef1[0])
							{
								//(*低过lrBaselineRef1的部分|*)
								aiBothSidesTotalPts[0][1]= aiBothSidesTotalPts[0][1]+1;
								alrBothSidesSumVal[0][1]= alrBothSidesSumVal[0][1]+lrTemp;
							}
							else if (lrTemp<lrBaselineRef0[0])
							{
								//(*介于lrBaselineRef1和lrBaselineRef0之间|*)
								aiBothSidesTotalPts[0][0]= aiBothSidesTotalPts[0][0]+1;
								alrBothSidesSumVal[0][0]= alrBothSidesSumVal[0][0]+lrTemp;
							}
						}
						pbyItem1=pbyItem1+1;
					}
				}
				else
				{
					//(*两次基线一致|比如全高/低电平|用谁都可以||*)
					lrBaselineRef2[0]= lrBaselineRef1[0];
				}

				if(lrBaselineRef1[0]!=lrBaselineRef0[0])
				{
					if (aiBothSidesTotalPts[0][0]>=aiBothSidesTotalPts[0][1])
					{
						lrBaselineRef2[0]= alrBothSidesSumVal[0][0]/aiBothSidesTotalPts[0][0];
					}
					else
					{
						lrBaselineRef2[0]= alrBothSidesSumVal[0][1]/aiBothSidesTotalPts[0][1];
					}
				}
				lrTemp= (REAL)(*pbyItem2);
				if(lrBaselineRef1[1]!=lrBaselineRef0[1])
				{
					for (iN=0; iN<i_iTotalPoints; iN++)
					{
						if (lrBaselineRef1[1]>lrBaselineRef0[1])
						{
							if (lrTemp>=lrBaselineRef1[1])
							{
								//(*超过lrBaselineRef1的部分|*)
								aiBothSidesTotalPts[1][0]= aiBothSidesTotalPts[1][0]+1;
								alrBothSidesSumVal[1][0]= alrBothSidesSumVal[1][0]+lrTemp;
							}
							else if (lrTemp>lrBaselineRef0[1])
							{
								//(*介于lrBaselineRef0和lrBaselineRef1之间|*)
								aiBothSidesTotalPts[1][1]= aiBothSidesTotalPts[1][1]+1;
								alrBothSidesSumVal[1][1]= alrBothSidesSumVal[1][1]+lrTemp;
							}
						}
						else if (lrBaselineRef1[1]<lrBaselineRef0[1])
						{
							if (lrTemp<lrBaselineRef1[1])
							{
								//(*低过lrBaselineRef1的部分|*)
								aiBothSidesTotalPts[1][1]= aiBothSidesTotalPts[1][1]+1;
								alrBothSidesSumVal[1][1]= alrBothSidesSumVal[1][1]+lrTemp;
							}
							else if (lrTemp<lrBaselineRef0[1])
							{
								//(*介于lrBaselineRef1和lrBaselineRef0之间|*)
								aiBothSidesTotalPts[1][0]= aiBothSidesTotalPts[1][0]+1;
								alrBothSidesSumVal[1][0]= alrBothSidesSumVal[1][0]+lrTemp;
							}
						}
						pbyItem2=pbyItem2+1;

					}
				}
				else
				{
					//(*两次基线一致|比如全高/低电平|用谁都可以||*)
					lrBaselineRef2[1]= lrBaselineRef1[1];
				}
				//>>>>>>>>>第三次循环，用于二次校准，求取二次校准的基线
				if(lrBaselineRef1[1]!=lrBaselineRef0[1])
				{
					if (aiBothSidesTotalPts[1][0]>=aiBothSidesTotalPts[1][1])
					{
						lrBaselineRef2[1]= alrBothSidesSumVal[1][0]/aiBothSidesTotalPts[1][0];
					}
					else
					{
						lrBaselineRef2[1]= alrBothSidesSumVal[1][1]/aiBothSidesTotalPts[1][1];
					}
				}
			}
			else
			{
				//(*没做二次校正||*)
				lrBaselineRef2[0]= lrBaselineRef1[0];
				lrBaselineRef2[1]= lrBaselineRef1[1];
			}
		}

		o_alrBase[0]= (lrBaselineRef2[0]*(REAL)(i_iZoomCoef));
		o_alrBase[1]= (lrBaselineRef2[1]*(REAL)(i_iZoomCoef));
	}

	void KS_CalcBaselineByData_FS(WORD *i_puiFSdata1,//精采样数据入口地址1
			WORD *i_puiFSdata2,//精采样数据入口地址2
			INT i_iTotalPoints,//精采样点数|默认按0.02系统精度是20mm宽度
			BYTE i_xIsNegPolarity[2],//信号极性|原始采集信号反极性，显示做了反向处理
			BYTE i_xCalibrateTwice,//二次校准基线
			REAL o_alrBase[2])
	{
		//定义开始start
		INT	iN							;				//,iJ(*循环变量|*)
		DINT adiSumVal[2]				;				//(*累加和|*)
		WORD* puiItem1					;				//(*临时变量,用来指针操作采样数据|*)
		WORD* puiItem2					;				//(*临时变量,用来指针操作采样数据|*)
		REAL lrTemp						;				//(*临时lreal型变量|*)
		REAL lrBaselineRef0[2]			;				//(*隔直基线|*)
		REAL lrBaselineRef1[2]			;				//(*隔直后二次平均的基线|*)
		REAL lrBaselineRef2[2]			;				//(*基线重新整定|*)
		REAL alrBothSidesSumVal[2][2]	;				//(*两边的分别累计值|1为上,2为下|*)
		INT aiBothSidesTotalPts[2][2]	;				//(*两边的统计点数|1为上,2为下|*)
		//定义变量结束stop
	//	(*recheck@2018.12.1.113055|
	//	* han.dp|精采样数据获取基线|*)
	//	lrResult= 0;
		if ((i_iTotalPoints>=250) && (i_iTotalPoints<=4000)) //(*波门在5mm~80mm之间|*)
		{
			//(*隔直方法|所有数据均值|*)
			puiItem1= i_puiFSdata1;
			puiItem2= i_puiFSdata2;

			adiSumVal[0]= 0;
			adiSumVal[1]= 0;
			for (iN=0; iN<i_iTotalPoints; iN++)
			{
				adiSumVal[0]= adiSumVal[0]+(*puiItem1);
				puiItem1= puiItem1+1;

				adiSumVal[1]= adiSumVal[1]+(*puiItem2);
				puiItem2= puiItem2+1;
			}
			lrBaselineRef0[0]= (REAL)adiSumVal[0]/(REAL)(i_iTotalPoints);
			lrBaselineRef0[1]= (REAL)adiSumVal[1]/(REAL)(i_iTotalPoints);

	//		(*用均值作为第1道阀值|
	//		* 然后把超过(含)阀值的点和低于阀值的点|
	//		* 个数和累计和分别记录下来|
	//		* 特别注意: 原始信号和显示的信号是相反的||*)
			//T1初始化
	//		(*记录超过(含)阀值的部分|*)
			aiBothSidesTotalPts[0][0]= 0;
			alrBothSidesSumVal[0][0]= 0;

			//(*记录低过阀值的部分|*)
			aiBothSidesTotalPts[0][1]= 0;
			alrBothSidesSumVal[0][1]= 0;
			//T2初始化
	//		(*记录超过(含)阀值的部分|*)
			aiBothSidesTotalPts[1][0]= 0;
			alrBothSidesSumVal[1][0]= 0;

			//(*记录低过阀值的部分|*)
			aiBothSidesTotalPts[1][1]= 0;
			alrBothSidesSumVal[1][1]= 0;

			//(*开始操作|*)
			puiItem1= i_puiFSdata1;
			puiItem2= i_puiFSdata2;

			for (iN=0; iN<i_iTotalPoints; iN++)
			{
				//T1处理
				lrTemp= (REAL)(*puiItem1);
				if (lrTemp>=lrBaselineRef0[0])
				{
					//(*记录超过(含)阀值的点|*)
					aiBothSidesTotalPts[0][0]= aiBothSidesTotalPts[0][0]+1;
					alrBothSidesSumVal[0][0]= alrBothSidesSumVal[0][0]+lrTemp;
				}
				else
				{
					//(*记录低过阀值的点|*)
					aiBothSidesTotalPts[0][1]= aiBothSidesTotalPts[0][1]+1;
					alrBothSidesSumVal[0][1]= alrBothSidesSumVal[0][1]+lrTemp;
				}
				puiItem1= puiItem1+1;
				//T2处理
				lrTemp= (REAL)(*puiItem2);
				if (lrTemp>=lrBaselineRef0[1])
				{
					//(*记录超过(含)阀值的点|*)
					aiBothSidesTotalPts[1][0]= aiBothSidesTotalPts[1][0]+1;
					alrBothSidesSumVal[1][0]= alrBothSidesSumVal[1][0]+lrTemp;
				}
				else
				{
					//(*记录低过阀值的点|*)
					aiBothSidesTotalPts[1][1]= aiBothSidesTotalPts[1][1]+1;
					alrBothSidesSumVal[1][1]= alrBothSidesSumVal[1][1]+lrTemp;
				}
				puiItem2= puiItem2+1;			//2023.10.12.165703||niu.j|修复bug
			}
			//T1处理
			if (i_xIsNegPolarity[0]==1)
			{
				//(*反极性|*)
				lrBaselineRef1[0]= alrBothSidesSumVal[0][0]/aiBothSidesTotalPts[0][0];
			}
			else
			{
				//(*正极性|*)
				lrBaselineRef1[0]= alrBothSidesSumVal[0][1]/aiBothSidesTotalPts[0][1];
			}
			//T2处理
			if (i_xIsNegPolarity[1]==1)
			{
				//(*反极性|*)
				lrBaselineRef1[1]= alrBothSidesSumVal[1][0]/aiBothSidesTotalPts[1][0];
			}
			else
			{
				//(*正极性|*)
				lrBaselineRef1[1]= alrBothSidesSumVal[1][1]/aiBothSidesTotalPts[1][1];
			}
			if (i_xCalibrateTwice==1)
			{
	//			(*需要再校准一次基线|
	//			* 避免lrBaselineRef0和lrBaselineRef1都不理想
	//			* 就再折中一下||*)
				//T1
				aiBothSidesTotalPts[0][0]= 0;
				alrBothSidesSumVal[0][0]= 0;

				aiBothSidesTotalPts[0][1]= 0;
				alrBothSidesSumVal[0][1]= 0;
				//T2
				aiBothSidesTotalPts[1][0]= 0;
				alrBothSidesSumVal[1][0]= 0;

				aiBothSidesTotalPts[1][1]= 0;
				alrBothSidesSumVal[1][1]= 0;

				puiItem1= i_puiFSdata1;
				puiItem2= i_puiFSdata2;
	//////>>>>>>>>>>>>>>>>>>>>>>.T1
				if (lrBaselineRef1[0]>lrBaselineRef0[0])
				{
					//(*第一次均值后的单边数据再次均值后变高了|*)
					for (iN=0; iN<i_iTotalPoints; iN++)
					{
						lrTemp= (REAL)(*puiItem1);

						if (lrTemp>=lrBaselineRef1[0])
						{
							//(*超过lrBaselineRef1的部分||*)
							aiBothSidesTotalPts[0][0]= aiBothSidesTotalPts[0][0]+1;
							alrBothSidesSumVal[0][0]= alrBothSidesSumVal[0][0]+lrTemp;
						}
						else if (lrTemp>lrBaselineRef0[0])
						{
							//(*介于lrBaselineRef1和lrBaselineRef0之间||*)
							aiBothSidesTotalPts[0][1]= aiBothSidesTotalPts[0][1]+1;
							alrBothSidesSumVal[0][1]= alrBothSidesSumVal[0][1]+lrTemp;
						}
						puiItem1= puiItem1+1;
					}

					if (aiBothSidesTotalPts[0][0]>=aiBothSidesTotalPts[0][1])
					{
						lrBaselineRef2[0]= alrBothSidesSumVal[0][0]/aiBothSidesTotalPts[0][0];
					}
					else
					{
						lrBaselineRef2[0]= alrBothSidesSumVal[0][1]/aiBothSidesTotalPts[0][1];
					}
				}
				else if (lrBaselineRef1[0]<lrBaselineRef0[0])
				{
					//(*第一次均值后的单边数据再次均值后变低了|*)
					for (iN=0; iN<i_iTotalPoints; iN++)
					{
						lrTemp= (REAL)(*puiItem1);

						if (lrTemp<lrBaselineRef1[0])
						{
							//(*低过lrBaselineRef1的部分||*)
							aiBothSidesTotalPts[0][1]= aiBothSidesTotalPts[0][1]+1;
							alrBothSidesSumVal[0][1]= alrBothSidesSumVal[0][1]+lrTemp;
						}
						else if (lrTemp<lrBaselineRef0[0])
						{
							//(*介于lrBaselineRef1和lrBaselineRef0之间的部分||*)
							aiBothSidesTotalPts[0][0]= aiBothSidesTotalPts[0][0]+1;
							alrBothSidesSumVal[0][0]= alrBothSidesSumVal[0][0]+lrTemp;
						}
						puiItem1= puiItem1+1;
					}

					//(*取点数多的区域有效||*)
					if (aiBothSidesTotalPts[0][0]>=aiBothSidesTotalPts[0][1])
					{
						lrBaselineRef2[0]= alrBothSidesSumVal[0][0]/aiBothSidesTotalPts[0][0];
					}
					else
					{
						lrBaselineRef2[0]= alrBothSidesSumVal[0][1]/aiBothSidesTotalPts[0][1];
					}
				}
				else
				{
					//(*竟然一样?那就随便谁都可以啦||*)
					lrBaselineRef2[0]= lrBaselineRef1[0];
				}
				o_alrBase[0]= lrBaselineRef2[0];
	///////>>>>>>>>>>>>>>>>>>>>>>T2
				if (lrBaselineRef1[1]>lrBaselineRef0[1])
				{
					//(*第一次均值后的单边数据再次均值后变高了|*)
					for (iN=0; iN<i_iTotalPoints; iN++)
					{
						lrTemp= (REAL)(*puiItem2);

						if (lrTemp>=lrBaselineRef1[1])
						{
							//(*超过lrBaselineRef1的部分||*)
							aiBothSidesTotalPts[1][0]= aiBothSidesTotalPts[1][0]+1;
							alrBothSidesSumVal[1][0]= alrBothSidesSumVal[1][0]+lrTemp;
						}
						else if (lrTemp>lrBaselineRef0[1])
						{
							//(*介于lrBaselineRef1和lrBaselineRef0之间||*)
							aiBothSidesTotalPts[1][1]= aiBothSidesTotalPts[1][1]+1;
							alrBothSidesSumVal[1][1]= alrBothSidesSumVal[1][1]+lrTemp;
						}
						puiItem2= puiItem2+1;
					}

					if (aiBothSidesTotalPts[1][0]>=aiBothSidesTotalPts[1][1])
					{
						lrBaselineRef2[1]= alrBothSidesSumVal[1][0]/aiBothSidesTotalPts[1][0];
					}
					else
					{
						lrBaselineRef2[1]= alrBothSidesSumVal[1][1]/aiBothSidesTotalPts[1][1];
					}
				}
				else if (lrBaselineRef1[1]<lrBaselineRef0[1])
				{
					//(*第一次均值后的单边数据再次均值后变低了|*)
					for (iN=0; iN<i_iTotalPoints; iN++)
					{
						lrTemp= (REAL)(*puiItem2);

						if (lrTemp<lrBaselineRef1[1])
						{
							//(*低过lrBaselineRef1的部分||*)
							aiBothSidesTotalPts[1][1]= aiBothSidesTotalPts[1][1]+1;
							alrBothSidesSumVal[1][1]= alrBothSidesSumVal[1][1]+lrTemp;
						}
						else if (lrTemp<lrBaselineRef0[1])
						{
							//(*介于lrBaselineRef1和lrBaselineRef0之间的部分||*)
							aiBothSidesTotalPts[1][0]= aiBothSidesTotalPts[1][0]+1;
							alrBothSidesSumVal[1][0]= alrBothSidesSumVal[1][0]+lrTemp;
						}
						puiItem2= puiItem2+1;
					}

					//(*取点数多的区域有效||*)
					if (aiBothSidesTotalPts[1][0]>=aiBothSidesTotalPts[1][1])
					{
						lrBaselineRef2[1]= alrBothSidesSumVal[1][0]/aiBothSidesTotalPts[1][0];
					}
					else
					{
						lrBaselineRef2[1]= alrBothSidesSumVal[1][1]/aiBothSidesTotalPts[1][1];
					}
				}
				else
				{
					//(*竟然一样?那就随便谁都可以啦||*)
					lrBaselineRef2[1]= lrBaselineRef1[1];
				}
				o_alrBase[1]= lrBaselineRef2[1];
			}
			else
			{
				//(*不做二次校正||*)
				o_alrBase[0]= lrBaselineRef1[0];
				o_alrBase[1]= lrBaselineRef1[1];
			}
		}
	}
	REAL KS_RatioL_ByThresholdCutting(REAL i_lrThresholdY, REAL i_lrPreviousY, REAL i_lrCurrentY)
	{
		REAL lrResult;
		//定义结束
	//	(*han.dp@2017.3.31.131121||
	//	* 跨阀值的左边占据的比例%|必须跨点||*)
		lrResult= 0;
		if ((i_lrPreviousY!=i_lrCurrentY) && //(*isn't the same sampling point*)
			((i_lrThresholdY>=i_lrPreviousY && i_lrThresholdY<=i_lrCurrentY) || //(*rising edge*)
			 (i_lrThresholdY<=i_lrPreviousY && i_lrThresholdY>=i_lrCurrentY)))	//(*falling edge*)
		{
			lrResult= (i_lrThresholdY-i_lrPreviousY)/(i_lrCurrentY-i_lrPreviousY);
		}

		return lrResult;
}

//平均处理@int16_t
float KS_Average(int8_t xAverageEn,//平均使能
		int16_t idata,//数据
		uint8_t byAverageNum,//平均次数
		int16_t aidatabuff[MAX_AVERAGE_NUM],//缓存的数组
		uint8_t* pbyCurIndex,//当前的索引@从0开始
		uint8_t* pxDataInitDne)//平均的数据初始化完成
{
	uint8_t byAverageNumUse = 0u;
	int8_t siIndexEnd = 0u;//循环结束的索引位置
	uint8_t byCurIndex = *pbyCurIndex;//从0开始
	uint8_t xDataInitDne = *pxDataInitDne;//数据初始化完成标志
	int16_t i = 0u,j = 0u;
	float fSum = 0.0f,fResult = 0.0f;
#if KS_USE_TRIM_AVERAGE
	float fMax = 0.0f,fMin = 0.0f;//窗口内最大/最小值@截尾平均用|Yang.zj+ 2026.10.26.210016
#endif


	if(!xAverageEn)//平均未使能@复位数据
	{
		if(xDataInitDne || byCurIndex !=0)
		{
			for(int16_t i = 0;i < MAX_AVERAGE_NUM;i++)
				aidatabuff[i] = 0;

			byCurIndex = 0;
			xDataInitDne = FALSE;
		}
	}
	else//平均使能
	{
#if KS_USE_TRIM_AVERAGE
		//截尾平均@2026.10.26:实际选取点数=平均次数+2,去掉1个最大值和1个最小值后平均剩余点;
		//暖机:缓冲内有效值<4个直接算术平均,>=4个即截尾(除以点数-2)
		//平均次数合法性处理(次数上限=容量-2,保证窗口=次数+2不超过缓冲)|Yang.zj+ 2026.10.26.210016
		byAverageNumUse = byAverageNum;
		if(byAverageNumUse == 0)
			byAverageNumUse = 1;
		else if(byAverageNumUse > MAX_AVERAGE_NUM-2)
			byAverageNumUse = MAX_AVERAGE_NUM-2;
		else
			;
		byAverageNumUse = byAverageNumUse + 2;//实际选取的窗口点数=平均次数+2
#else
		//平均次数合法性处理
		byAverageNumUse = byAverageNum;
		if(byAverageNumUse == 0)
			byAverageNumUse = 1;
		else if(byAverageNumUse > MAX_AVERAGE_NUM)
			byAverageNumUse = MAX_AVERAGE_NUM;
		else
			;
#endif

		if(!xDataInitDne)//数据初始化未完成
		{
			if(byCurIndex+1 >= byAverageNumUse)//数据足够了@置位初始化完成标志
				xDataInitDne = TRUE;

			if(!xDataInitDne)//未初始化成功，修改平均次数值
				byAverageNumUse = byCurIndex + 1;//byCurIndex 从0开始
		}
		else//数据初始化完成
		{
			;
		}

		//索引处理
		aidatabuff[byCurIndex] = idata;//数据存储到数组中@最新的数据
		//计算累计值@截尾平均同时一趟扫描找窗口内最大/最小|Yang.zj+ 2026.10.26.210016
		siIndexEnd = (int8_t)(byCurIndex + 1) - (int8_t)byAverageNumUse;
		for(i = byCurIndex;i >= siIndexEnd;i--)//siIndexEnd 有可能是负值
		{
			j = i;//i 有可能是负值@不能修改i,写入到临时变量,修改临时变量
			if(j < 0 ) j += MAX_AVERAGE_NUM;//拉回到正常范围
#if KS_USE_TRIM_AVERAGE
			if(i == byCurIndex)//以最新的点初始化最大最小
			{
				fMax = aidatabuff[j];
				fMin = fMax;
			}
			else
			{
				if(aidatabuff[j] > fMax)
					fMax = aidatabuff[j];
				if(aidatabuff[j] < fMin)
					fMin = aidatabuff[j];
			}
#endif
			fSum += aidatabuff[j];//计算累计值
		}
#if KS_USE_TRIM_AVERAGE
		if(byAverageNumUse < 4)
			fResult = fSum / byAverageNumUse;//暖机:不足4个点直接算术平均
		else
			fResult = (fSum - fMax - fMin) / (byAverageNumUse - 2);//去掉1个最大值和1个最小值后平均
#else
		fResult = fSum / byAverageNumUse;
#endif

		byCurIndex++;
		if(byCurIndex >= MAX_AVERAGE_NUM)
			byCurIndex = 0;
	}//平均使能


	*pbyCurIndex = byCurIndex;//更新
	*pxDataInitDne = xDataInitDne;
	return fResult;
}
