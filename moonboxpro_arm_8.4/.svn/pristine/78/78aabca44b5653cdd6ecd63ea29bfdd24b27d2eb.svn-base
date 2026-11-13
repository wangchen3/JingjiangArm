
#include "KS_RsMorphFilter.h"

/**
 * @brief 静态工作缓冲区

 */
static uint8_t  s_arBuf_Tmp[KS_RS_MORPH_MAX_POINTS];    /**< 临时复用缓冲 */
static uint8_t  s_arBuf_Opened[KS_RS_MORPH_MAX_POINTS]; /**< 开运算结果：信号下包络线 */
static uint8_t  s_arBuf_Closed[KS_RS_MORPH_MAX_POINTS];/**< 闭运算结果：信号上包络线 */
static uint16_t s_awDeque[KS_RS_MORPH_MAX_POINTS];      /**< 单调队列索引缓存，用于滑动窗口加速 */

/**
 * @brief  获取镜像边界索引，处理信号边缘延拓
 * @param  i_wPointNum   信号总点数
 * @param  i_iIndex      当前计算索引（可能越界）
 * @return 合法镜像索引
 * @note   索引<0返回0，索引>=长度返回最后一个点，防止数组越界
 */
static uint16_t s_KsRsMorph_GetMirrorIndex(uint16_t i_wPointNum, int32_t i_iIndex)
{
    if(i_wPointNum == 0u) return 0u;
    if(i_iIndex < 0) return 0u;
    if(i_iIndex >= (int32_t)i_wPointNum) return (uint16_t)(i_wPointNum - 1u);
    return (uint16_t)i_iIndex;
}

/**
 * @brief  检查滤波窗口参数是否合法
 * @param  i_wPointNum   信号点数
 * @param  i_wWindowLen  滤波窗口长度
 * @return 1=有效 0=无效
 * @note   窗口必须为奇数，且长度不能大于信号长度
 */
uint8_t KS_RsMorphFilter_CheckWindowValid(uint16_t i_wPointNum, uint16_t i_wWindowLen)
{
    if(i_wPointNum == 0u || i_wPointNum > KS_RS_MORPH_MAX_POINTS) return 0u;
    if(i_wWindowLen < KS_RS_MORPH_MIN_WINDOW) return 0u;
    if((i_wWindowLen & 0x0001u) == 0u) return 0u;
    if(i_wWindowLen > i_wPointNum) return 0u;
    return 1u;
}

/**
 * @brief  8位信号滑动最小值（形态学腐蚀）
 * @param  i_arSrc       原始信号数组
 * @param  i_wPointNum   信号长度
 * @param  i_wWindowLen  滑动窗口长度
 * @param  o_arDst       输出最小值序列
 * @note   使用单调队列实现
 */
static void s_KsRsMorph_SlidingMin_U8(const uint8_t i_arSrc[], uint16_t i_wPointNum, uint16_t i_wWindowLen, uint8_t o_arDst[])
{
    uint16_t wHalfWin = (uint16_t)(i_wWindowLen >> 1);
    uint16_t wDequeHead = 0u, wDequeTail = 0u;
    uint16_t wExtNum = (uint16_t)(i_wPointNum + i_wWindowLen - 1u);

    for(uint16_t wExtIndex = 0u; wExtIndex < wExtNum; wExtIndex++) {
        int32_t iRealIndex = (int32_t)wExtIndex - (int32_t)wHalfWin;
        uint16_t wSrcIndex = s_KsRsMorph_GetMirrorIndex(i_wPointNum, iRealIndex);

        // 维护递增队列，移除尾部大于当前值的元素
        while(wDequeHead < wDequeTail) {
            uint16_t wTailIndex = s_awDeque[wDequeTail - 1u];
            uint16_t wTailSrc = s_KsRsMorph_GetMirrorIndex(i_wPointNum, (int32_t)wTailIndex - (int32_t)wHalfWin);
            if(i_arSrc[wTailSrc] <= i_arSrc[wSrcIndex]) break;
            wDequeTail--;
        }
        s_awDeque[wDequeTail++] = wExtIndex;

        // 移除超出窗口范围的队首元素
        while(wDequeHead < wDequeTail && (wExtIndex - s_awDeque[wDequeHead]) >= i_wWindowLen) {
            wDequeHead++;
        }

        // 窗口形成后输出结果
        if(wExtIndex >= i_wWindowLen - 1u) {
            uint16_t wOutIndex = wExtIndex - (i_wWindowLen - 1u);
            uint16_t wMinSrc = s_KsRsMorph_GetMirrorIndex(i_wPointNum, (int32_t)s_awDeque[wDequeHead] - (int32_t)wHalfWin);
            o_arDst[wOutIndex] = i_arSrc[wMinSrc];
        }
    }
}

/**
 * @brief  8位信号滑动最大值（形态学膨胀）
 * @param  i_arSrc       原始信号数组
 * @param  i_wPointNum   信号长度
 * @param  i_wWindowLen  滑动窗口长度
 * @param  o_arDst       输出最大值序列
 * @note   与滑动最小值逻辑对称，用于膨胀操作
 */
static void s_KsRsMorph_SlidingMax_U8(const uint8_t i_arSrc[], uint16_t i_wPointNum, uint16_t i_wWindowLen, uint8_t o_arDst[])
{
    uint16_t wHalfWin = (uint16_t)(i_wWindowLen >> 1);
    uint16_t wDequeHead = 0u, wDequeTail = 0u;
    uint16_t wExtNum = (uint16_t)(i_wPointNum + i_wWindowLen - 1u);

    for(uint16_t wExtIndex = 0u; wExtIndex < wExtNum; wExtIndex++) {
        int32_t iRealIndex = (int32_t)wExtIndex - (int32_t)wHalfWin;
        uint16_t wSrcIndex = s_KsRsMorph_GetMirrorIndex(i_wPointNum, iRealIndex);

        // 维护递减队列，移除尾部小于当前值的元素
        while(wDequeHead < wDequeTail) {
            uint16_t wTailIndex = s_awDeque[wDequeTail - 1u];
            uint16_t wTailSrc = s_KsRsMorph_GetMirrorIndex(i_wPointNum, (int32_t)wTailIndex - (int32_t)wHalfWin);
            if(i_arSrc[wTailSrc] >= i_arSrc[wSrcIndex]) break;
            wDequeTail--;
        }
        s_awDeque[wDequeTail++] = wExtIndex;

        // 移除超出窗口范围的队首元素
        while(wDequeHead < wDequeTail && (wExtIndex - s_awDeque[wDequeHead]) >= i_wWindowLen) {
            wDequeHead++;
        }

        // 窗口形成后输出结果
        if(wExtIndex >= i_wWindowLen - 1u) {
            uint16_t wOutIndex = wExtIndex - (i_wWindowLen - 1u);
            uint16_t wMaxSrc = s_KsRsMorph_GetMirrorIndex(i_wPointNum, (int32_t)s_awDeque[wDequeHead] - (int32_t)wHalfWin);
            o_arDst[wOutIndex] = i_arSrc[wMaxSrc];
        }
    }
}

/**
 * @brief  8位信号形态学滤波
 * @param  io_abySignal  输入/输出信号数组（原地修改）
 * @param  i_wPointNum   信号长度
 * @param  i_wWindowLen  结构元素窗口长度
 * @param  i_byExtractMode  波形提取模式，1：保留双极性，2：正极性，3：反极性
 * @return 1=滤波成功 0=参数错误
 * @note   算法：开运算(下包络)+闭运算(上包络)→计算基线→信号提纯输出
 */
uint8_t KS_RsMorphFilter_U8(uint8_t io_abySignal[], uint16_t i_wPointNum, uint16_t i_wWindowLen, uint8_t i_byExtractMode)
{
    uint32_t dwBaseSum = 0u;
    uint8_t byBaseAvg = 128u;

    if(io_abySignal == 0) return 0u;
    if(!KS_RsMorphFilter_CheckWindowValid(i_wPointNum, i_wWindowLen)) return 0u;

    // 开运算 = 腐蚀 + 膨胀 → 下包络线
    s_KsRsMorph_SlidingMin_U8(io_abySignal, i_wPointNum, i_wWindowLen, s_arBuf_Tmp);
    s_KsRsMorph_SlidingMax_U8(s_arBuf_Tmp, i_wPointNum, i_wWindowLen, s_arBuf_Opened);

    // 闭运算 = 膨胀 + 腐蚀 → 上包络线
    s_KsRsMorph_SlidingMax_U8(io_abySignal, i_wPointNum, i_wWindowLen, s_arBuf_Tmp);
    s_KsRsMorph_SlidingMin_U8(s_arBuf_Tmp, i_wPointNum, i_wWindowLen, s_arBuf_Closed);

    // 计算上下包络平均基线
    for(uint16_t i = 0u; i < i_wPointNum; i++)
    {
        dwBaseSum += ((uint16_t)s_arBuf_Opened[i] + (uint16_t)s_arBuf_Closed[i]) >> 1;
    }
    byBaseAvg = (uint8_t)(dwBaseSum / i_wPointNum);

    // 根据模式进行极性提纯
    for(uint16_t i = 0u; i < i_wPointNum; i++)
    {
        int16_t iPureVal = 0;

        switch(i_byExtractMode)
        {
            case KS_MORPH_MODE_DUAL: // 1: 双极性
                iPureVal = ((int16_t)io_abySignal[i] << 1)
                          - (int16_t)s_arBuf_Opened[i]
                          - (int16_t)s_arBuf_Closed[i];
                break;

            case KS_MORPH_MODE_POSITIVE: // 2: 仅正极性 (白顶帽)
                iPureVal = (int16_t)io_abySignal[i] - (int16_t)s_arBuf_Opened[i];
                break;

            case KS_MORPH_MODE_NEGATIVE: // 3: 仅反极性 (黑底帽)
                iPureVal = (int16_t)io_abySignal[i] - (int16_t)s_arBuf_Closed[i];
                break;

            default: // 默认双极性
                iPureVal = ((int16_t)io_abySignal[i] << 1)
                          - (int16_t)s_arBuf_Opened[i]
                          - (int16_t)s_arBuf_Closed[i];
                break;
        }

        // 基线校正 + 限幅输出
        int16_t iDisplayVal = iPureVal + (int16_t)byBaseAvg;

        if(iDisplayVal < 0) iDisplayVal = 0;
        else if(iDisplayVal > 255) iDisplayVal = 255;

        io_abySignal[i] = (uint8_t)iDisplayVal;
    }

    return 1u;
}

//计算形态学滑窗大小2026.4.10.160826
uint16_t KsCalcMorphWindowLen(float i_fMarkWidthMm, float i_fGirthMm)
{
	float fSpotWidthMm = 1.5f;
	float fWindowTheory = 0.0f;
	uint16_t wLen = 11u;

	if(i_fGirthMm <= 0.0f)
	{
		return 11u;
	}

	if(i_fMarkWidthMm < 0.0f)
	{
		i_fMarkWidthMm = 0.0f;
	}

	fWindowTheory = (i_fMarkWidthMm + fSpotWidthMm) * 800.0f / i_fGirthMm;
	wLen = (uint16_t)(fWindowTheory + 0.5f); // 四舍五入

	if(wLen < 3u)
	{
		wLen = 3u;
	}

	if((wLen & 0x0001u) == 0u)
	{
		wLen += 1u;
	}

	if(wLen >= PUMPPOINT)
	{
		wLen = (PUMPPOINT - 1u); // 800是偶数，最大合法奇数取799
	}

	return wLen;
}
