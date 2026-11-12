/*
 * calcbase.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef CALCBASE_H_
#define CALCBASE_H_

#include "base.h"
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

INT KS_AutoFindGate(
		BYTE *i_pbyRSdata1,
		INT i_iUseBase,
		StAxisParam *i_pstStAxisParam,
		INT i_iTotalPoints);

#endif /* CALCBASE_H_ */
