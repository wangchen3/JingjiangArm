/*
 * KS_RsRootBaseline.c
 *
 *  Created on: Oct 24, 2026
 *      Author: wang.c
 *
 *  wang.c 2026.10.26.110221 新增模块：粗采样形态学根部估计基线（门内基线分支）。
 *  算法说明见 KS_RsRootBaseline.h 文件头。
 *  性能：形态学滑窗极值用单调队列实现（每个元素最多进队/出队一次，O(N)复杂度），
 *  整圈4000点开/闭运算+门内均值约3~4ms@100MHz，满足V2一个周期只处理一路(10ms)的实时要求。
 */

#include "KS_RsRootBaseline.h"
#include "string.h"
#include "math.h"

//wang.c 2026.10.26.110221 模块级工作缓冲@避免大数组压栈
//形态学根部曲线(双极性还原后的0~255数据)
static uint8_t s_abyWork[KS_RSROOT_ROUND_PTS];
//第一趟滑窗输出(腐蚀或膨胀的中间结果)
static uint8_t s_abyPass1[KS_RSROOT_ROUND_PTS];
//第二趟滑窗输出(根部曲线)
static uint8_t s_abyRoot[KS_RSROOT_ROUND_PTS];
//单调队列存粗采样下标(uint16_t)
static uint16_t s_awDeque[KS_RSROOT_ROUND_PTS + 1];

/**
 * @brief  圆周滑窗极值(单调队列实现)
 * @param  i_abySrc    输入曲线(KS_RSROOT_ROUND_PTS点)
 * @param  o_abyDst    输出曲线(o[i]=窗口i-wHalf..i+wHalf内的极值,下标环绕整圈)
 * @param  i_wHalf     半窗长|窗口长度=2*i_wHalf+1
 * @param  i_xMaxOp    1=取窗口最大值(膨胀) 0=取窗口最小值(腐蚀)
 * @note   单调队列：每个元素最多进队/出队一次，复杂度O(N)；
 *         圆周回绕通过把输入序列延长一个窗口长度实现。
 */
//wang.c 2026.10.26.110221 新增：圆周单调队列滑窗极值
static void KS_RsRoot_SlidingExtremum(const uint8_t* i_abySrc, uint8_t* o_abyDst,
										uint16_t i_wHalf, uint8_t i_xMaxOp)
{
	uint16_t wWinLen = (uint16_t)(2u * i_wHalf + 1u);//窗口长度
	uint16_t wHead = 0, wTail = 0;//队头/队尾(存下标)
	uint16_t i;
	uint16_t wIdx;
	uint8_t byVal;

	if (i_wHalf == 0u)//窗口长度1=原样拷贝
	{
		memcpy(o_abyDst, i_abySrc, KS_RSROOT_ROUND_PTS);
		return;
	}

	//序列延长一个窗口：i从0到N+wWinLen-1，输出对齐到o[(i-wWinLen+1) mod N]
	for (i = 0u; i < (uint16_t)(KS_RSROOT_ROUND_PTS + wWinLen - 1u); i++)
	{
		wIdx = (uint16_t)(i % KS_RSROOT_ROUND_PTS);
		//队头过期(滑出窗口)出队
		if (i >= wWinLen)
		{
			if (s_awDeque[wHead] == (uint16_t)((i - wWinLen) % KS_RSROOT_ROUND_PTS))
			{
				wHead++;
			}
		}
		//队尾保持单调：比当前元素更差(不会成为极值)的出队
		byVal = i_abySrc[wIdx];
		while (wTail > wHead)
		{
			uint8_t byTail = i_abySrc[s_awDeque[wTail - 1u]];
			if ((i_xMaxOp != 0u) ? (byTail <= byVal) : (byTail >= byVal))
			{
				wTail--;
			}
			else
			{
				break;
			}
		}
		s_awDeque[wTail++] = wIdx;
		//窗口满后输出队头极值
		//wang.c 2026.10.26.110221 窗口[i-W+1,i]的中心=i-half,输出按中心对齐o[center],
		//与桌面工作台"out[i]=src[i-half..i+half]极值"同口径|输出时i>=2*half,i-half恒非负
		if (i >= (uint16_t)(wWinLen - 1u))
		{
			o_abyDst[(uint16_t)((i - i_wHalf) % KS_RSROOT_ROUND_PTS)] =
				i_abySrc[s_awDeque[wHead]];
		}
	}
}

/**
 * @brief  粗采样形态学根部估计基线（门内基线分支算法）
 * @see    KS_RsRootBaseline.h 接口说明
 */
//wang.c 2026.10.26.110221 新增：粗采样形态学根部估计基线计算
uint8_t KS_RsRootBase_Calc(const uint8_t* i_pbyRoundData,
							uint8_t i_xInclNegative10vSignal,
							uint16_t i_wGateStartPt,
							uint16_t i_wGatePtNum,
							uint8_t i_xNegPolarity,
							float i_lrGirthMm,
							float i_lrMarkVLenMm,
							float* o_prBase)
{
	uint16_t i;
	uint16_t wHalf;
	uint32_t dwSum = 0;
	uint16_t wGateStart;
	uint16_t wGateNum;
	float lrWindow;

	if ((i_pbyRoundData == 0) || (o_prBase == 0))
	{
		return 0;
	}

	//1)数据还原到0~255(双极性int8+128)@与KsRsDataDealEx同口径
	for (i = 0u; i < KS_RSROOT_ROUND_PTS; i++)
	{
		if (i_xInclNegative10vSignal != 0u)
		{
			s_abyWork[i] = (uint8_t)(((int8_t)i_pbyRoundData[i]) + 128);
		}
		else
		{
			s_abyWork[i] = i_pbyRoundData[i];
		}
	}

	//2)形态学滑窗长度=色标垂直边长/版周长×4000(向上取整)|保证罩住色标
	//wang.c 2026.10.26.110221 与桌面离线工作台同口径:全窗W=ceil(边长/周长×4000),半窗=W/2,窗口=2*half+1
	lrWindow = 1.0f;
	if ((i_lrGirthMm > 0.0f) && (i_lrMarkVLenMm > 0.0f))
	{
		lrWindow = (i_lrMarkVLenMm / i_lrGirthMm) * (float)KS_RSROOT_ROUND_PTS;
		lrWindow = ceilf(lrWindow);//向上取整
	}
	if (lrWindow < 1.0f)
	{
		lrWindow = 1.0f;
	}
	if (lrWindow > (float)(KS_RSROOT_ROUND_PTS - 1))
	{
		lrWindow = (float)(KS_RSROOT_ROUND_PTS - 1);//窗口不得超过整圈-1
	}
	wHalf = (uint16_t)((uint16_t)lrWindow / 2u);//半窗长|窗口=2*half+1
	if (wHalf > (uint16_t)(KS_RSROOT_ROUND_PTS / 2u - 1u))
	{
		wHalf = (uint16_t)(KS_RSROOT_ROUND_PTS / 2u - 1u);
	}

	//3)极性选形态学：正极性(色标向上)开运算(先腐蚀后膨胀)贴底根；
	//   反极性(色标向下)闭运算(先膨胀后腐蚀)贴顶根
	if (i_xNegPolarity != 0u)
	{
		KS_RsRoot_SlidingExtremum(s_abyWork, s_abyPass1, wHalf, 1);//膨胀
		KS_RsRoot_SlidingExtremum(s_abyPass1, s_abyRoot, wHalf, 0);//腐蚀
	}
	else
	{
		KS_RsRoot_SlidingExtremum(s_abyWork, s_abyPass1, wHalf, 0);//腐蚀
		KS_RsRoot_SlidingExtremum(s_abyPass1, s_abyRoot, wHalf, 1);//膨胀
	}

	//4)波门区间均值(环绕取数)
	wGateStart = (uint16_t)(i_wGateStartPt % KS_RSROOT_ROUND_PTS);
	wGateNum = i_wGatePtNum;
	if (wGateNum == 0u)
	{
		wGateNum = 1u;
	}
	if (wGateNum > KS_RSROOT_ROUND_PTS)
	{
		wGateNum = KS_RSROOT_ROUND_PTS;
	}
	for (i = 0u; i < wGateNum; i++)
	{
		dwSum += s_abyRoot[(uint16_t)((wGateStart + i) % KS_RSROOT_ROUND_PTS)];
	}

	//输出基线@8bit粗采样域0~255浮点|调用方×256换到16bit精采样域
	*o_prBase = (float)dwSum / (float)wGateNum;
	return 1;
}
