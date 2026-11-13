/*
 * KS_RsRootBaseline.h
 *
 *  Created on: Oct 24, 2026
 *      Author: wang.c
 *
 *  wang.c 2026.10.26.110221 新增模块：粗采样形态学根部估计基线（门内基线分支）。
 *  算法与桌面离线工作台"粗采样根部估计"基线模式一致：
 *  	1) 整圈4000点粗采样(8bit)按极性做圆周形态学（正极性开运算贴底根/反极性闭运算贴顶根），
 *  	   得到一条贴近根部的基线曲线；
 *  	2) 形态学滑窗长度 = 色标垂直边长/版周长 × 4000（向上取整）；
 *  	3) 从根部曲线上截取波门区间（起点iGateSa/iGateSaEx，长度iGateWidthRdPt，环绕取数）求平均，
 *  	   得到该通道本圈基线（8bit粗采样域0~255浮点）。
 *  供误差链路使用：calcerr.c 门内基线开时经宏 USE_RS_ROOT_BASELINE 选择本分支，
 *  基线×256换到16bit精采样域后与传统门内基线同一去向。
 */

#ifndef KS_RS_ROOTBASELINE_H_
#define KS_RS_ROOTBASELINE_H_

#include "base.h"
#include "stdint.h"

//------------------------------------参数宏------------------------------------
//粗采样整圈点数@与采样配置的roundSamplePoint一致
#define KS_RSROOT_ROUND_PTS			4000

//wang.c 2026.10.26.110221 门内基线开时的基线算法分支开关：
//1=门内基线使用粗采样形态学根部估计(KS_RsRootBase_Calc)，
//0=使用传统门内基线算法(KS_CalcBaselineByData_FS)。
//宏为1时误差计算链路(三档阈值/找沿/误差)自动使用根部估计基线。
#define USE_RS_ROOT_BASELINE  		0 //暂时改为0，供10.27测试
//----------------------------------------------------------------------------

//wang.c 2026.10.26.110221 粗采样形态学根部估计基线计算
//入参/出参命名遵循工程规范(i_=输入,o_=输出)
//i_pbyRoundData   整圈粗采样数据地址(环网原始8bit数据,双极性时为int8存储)
//i_xInclNegative10vSignal 双极性标志@1=int8存储需+128还原到0~255
//i_wGateStartPt   波门起始粗采样点(0~3999,T1用iGateSa,T2双波门时用iGateSaEx)
//i_wGatePtNum     波门宽度粗采样点数(iGateWidthRdPt)
//i_xNegPolarity   该通道信号反极性@1=反极性(色标向下,闭运算贴顶根)
//i_lrGirthMm      版周长mm
//i_lrMarkVLenMm   色标垂直边长mm(byTriMark_SideC)|决定形态学滑窗长度
//o_prBase         输出基线@8bit粗采样域0~255浮点|调用方×256换到16bit精采样域
//返回 1=成功 0=参数无效(未更新o_prBase)
uint8_t KS_RsRootBase_Calc(const uint8_t* i_pbyRoundData,
							uint8_t i_xInclNegative10vSignal,
							uint16_t i_wGateStartPt,
							uint16_t i_wGatePtNum,
							uint8_t i_xNegPolarity,
							float i_lrGirthMm,
							float i_lrMarkVLenMm,
							float* o_prBase);

#endif /* KS_RS_ROOTBASELINE_H_ */
