/*
 * KS_RsMorphFilter.h
 */
#include "base.h"
#include "stdint.h"

#ifndef KS_RS_MORPHFILTER_H_
#define KS_RS_MORPHFILTER_H_

#define KS_MORPH_MODE_DUAL       1u  /* 模式1：双极性提取 (正负共存) */
#define KS_MORPH_MODE_POSITIVE   2u  /* 模式2：仅正极性 (白顶帽, 滤除反极性色标) */
#define KS_MORPH_MODE_NEGATIVE   3u  /* 模式3：仅反极性 (黑底帽, 滤除正极性色标) */

#ifndef PUMPPOINT
#define PUMPPOINT 800u
#endif

#define KS_RS_MORPH_MAX_POINTS   PUMPPOINT       /* 默认按界面显示800点设计 */
#define KS_RS_MORPH_MIN_WINDOW   3u         /* 最小窗口长度，必须为奇数 */

/*
 * @brief 检查滑窗参数是否合法
 * @return 1=合法 0=非法
 */
uint8_t KS_RsMorphFilter_CheckWindowValid(uint16_t i_wPointNum, uint16_t i_wWindowLen);

/*
 * @brief  8位信号形态学滤波（带多模式选择）
 * @param  io_abySignal    输入/输出信号数组
 * @param  i_wPointNum     信号长度
 * @param  i_wWindowLen    结构元素窗口长度
 * @param  i_byExtractMode 提取模式 (1=双极性, 2=仅正极性, 3=仅反极性)
 * @return 1=成功 0=失败
 */
uint8_t KS_RsMorphFilter_U8(uint8_t io_abySignal[], uint16_t i_wPointNum, uint16_t i_wWindowLen, uint8_t i_byExtractMode);

uint16_t KsCalcMorphWindowLen(float i_fMarkWidthMm, float i_fGirthMm);
#endif /* KS_RS_MORPHFILTER_H_ */
