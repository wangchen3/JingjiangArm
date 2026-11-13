/*
 * calcbase.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef CALCBASE_H_
#define CALCBASE_H_

#include "base.h"


//平均处理@int16_t@2026.4.25.134615+
#define MAX_AVERAGE_NUM 20//最大平均个数

//截尾平均总开关@2026.10.26
//1 = 平均改为截尾:选取"平均次数+2"个点(含当前值),去掉1个最大值和1个最小值后平均剩余点;
//    暖机期缓冲内有效值<4个时直接算术平均,>=4个即截尾(除以点数-2);
//    作用于KS_Average(显示平均)和calcerr.c的N幅控制平均,两处语义一致
//0 = 回退原算术平均,新旧两条路径都保留,改成0重新编译即可
//注意:本宏与ks_arc_err_define.h内的同名宏保持同值(该模块不包含本头文件,V2路径用它)|Yang.zj+ 2026.10.26.210016
#define KS_USE_TRIM_AVERAGE	1

void KS_CalcBaselineByData_RS(BYTE *i_pbyRSdata1,//粗采样数据T1入口地址
		BYTE* i_pbyRSdata2,//粗采样第二路入口地址；
		INT i_iTotalPoints,//粗采样数据点数|最大4000
		INT i_iZoomCoef,//由于精采样是16bits，粗采样数据8bits，所以放大系数默认256|
		BYTE i_xCalibrateTwice,
		REAL i_alrBase[2]);//对找到的基线进行二次校准
void KS_CalcBaselineByData_FS(WORD *i_puiFSdata1,//精采样数据入口地址1
		WORD *i_puiFSdata2,//精采样数据入口地址2
		INT i_iTotalPoints,//精采样点数|默认按0.02系统精度是20mm宽度
		BYTE i_xIsNegPolarity[2],//信号极性|原始采集信号反极性，显示做了反向处理
		BYTE i_xCalibrateTwice,//二次校准基线
		REAL o_alrBase[2]);
REAL KS_RatioL_ByThresholdCutting(REAL i_lrThresholdY, //阀值水平|
		REAL i_lrPreviousY, //之前一点的采样值
		REAL i_lrCurrentY);//当前采样值
//
//INT KS_AutoFindGate(
//		BYTE *i_pbyRSdata1,
//		INT i_iUseBase,
//		StAxisParam *i_pstStAxisParam,
//		INT i_iTotalPoints);

//2026.4.25.134524+平均处理函数
float KS_Average(int8_t xAverageEn,//平均使能
		int16_t idata,//数据
		uint8_t byAverageNum,//平均次数
		int16_t aidatabuff[MAX_AVERAGE_NUM],//缓存的数组
		uint8_t* pbyCurIndex,//当前的索引@从0开始
		uint8_t* pxDataInitDne);//平均的数据初始化完成

#endif /* CALCBASE_H_ */
