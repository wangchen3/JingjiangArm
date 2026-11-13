#include "ks_fb_prosample_v2.h"
#include "ks_calc_arc_err.h"
#include "ks_arc_err_define.h"
#include "ks_define.h"
#include "comm.h"
#include "base.h"

#define GET_BIT16(v, b)   (((uint16_t)(v) >> (b)) & 0x01u)

/* 保持精采样计数方式 */
static WORD s_uiFSampleCount = 0;
/* 与老架构保持一致：纵向连续丢失计数 */
static uint16_t s_uiCount_ErrorLost = 0;
static int16_t s_lastValidVErr = 0;//三帧丢失沿用上一帧

static uint8_t xFlagTrigger;                   // 色标宽度传递触发标志
static uint8_t uiWaitCount;                    // 宽度传递延时计数器
static BYTE xPreFlag_AutoAdj_En;               // 上一周期自动调整使能标志（边沿检测用）

static uint8_t s_byDataCurIndex_V = 0;
static uint8_t s_byDataCurIndex_H = 0;
static uint8_t s_xDataInitDne_V = 0;
static uint8_t s_xDataInitDne_H = 0;
static int16_t s_aidatabuff_V[MAX_AVERAGE_NUM];
static int16_t s_aidatabuff_H[MAX_AVERAGE_NUM];//显示平均静态变量

/**
 * @brief 更新轴参数中的监控量
 * 直接读取结构体中已存好的峰值原始采样值 uPeakRawValue
 */
 static void KS_FB_UpdateAxisMonitor(
    StAxisParam* i_pstStAxisParam,
    const ArcErrParam* pstArcErrParam,
    const ArcMarkInf* pstArcMarkInfCurV,
    const ArcMarkInf* pstArcMarkInfFollowV,
    const ArcErrInf* pstArcErrInfV,
    const ArcErrInf* pstArcErrInfH,
    REAL o_alrThreshold[2],
    REAL o_alrBase_Fs[2])
{
    if (i_pstStAxisParam == NULL ||
        pstArcErrParam == NULL ||
        pstArcMarkInfCurV == NULL ||
        pstArcMarkInfFollowV == NULL ||
        pstArcErrInfV == NULL ||
        pstArcErrInfH == NULL)
    {
        return;
    }

    /* 1) 回填实际使用基线监控值 */
    {
        float baseUseT1 = pstArcErrParam->fBase1;
        float baseUseT2 = pstArcErrParam->fBase2;

        if (pstArcMarkInfCurV->uIsT1T2Pos == SAMPLE_T1) baseUseT1 = pstArcMarkInfCurV->fBaseLine;
        if (pstArcMarkInfCurV->uIsT1T2Pos == SAMPLE_T2) baseUseT2 = pstArcMarkInfCurV->fBaseLine;

        if (pstArcMarkInfFollowV->uIsT1T2Pos == SAMPLE_T1) baseUseT1 = pstArcMarkInfFollowV->fBaseLine;
        if (pstArcMarkInfFollowV->uIsT1T2Pos == SAMPLE_T2) baseUseT2 = pstArcMarkInfFollowV->fBaseLine;

        i_pstStAxisParam->arBase_use[0] = baseUseT1;
        i_pstStAxisParam->arBase_use[1] = baseUseT2;
    }

    /* 2) 回填波门误差 */
    i_pstStAxisParam->aiVerror_Gate[0] = pstArcErrInfV->iErrValue;
    i_pstStAxisParam->aiVerror_Gate[1] = pstArcErrInfV->iErrValue__;
    i_pstStAxisParam->aiHerror_Gate[0] = pstArcErrInfH->iErrValue__;
    i_pstStAxisParam->aiHerror_Gate[1] = pstArcErrInfH->iErrValue;

    /* 3) 峰值路由（补齐 OMK/横向） */
    if (i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_VFOR)
    {
        /* 纵顺: t1<-cur, t2<-follow */
        i_pstStAxisParam->uiPeakValue_t1 = pstArcMarkInfCurV->uPeakRawValue;
        i_pstStAxisParam->uiPeakValue_t2 = pstArcMarkInfFollowV->uPeakRawValue;
    }
    else if (i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_VREV)
    {
        /* 纵逆: t1<-follow, t2<-cur */
        i_pstStAxisParam->uiPeakValue_t1 = pstArcMarkInfFollowV->uPeakRawValue;
        i_pstStAxisParam->uiPeakValue_t2 = pstArcMarkInfCurV->uPeakRawValue;
    }
    else if (i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_HFOR ||
             i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_HREV ||
             i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_OMK)
    {
        /* 横向/单标记: 当前->T1, 跟踪->T2 */
        i_pstStAxisParam->uiPeakValue_t1 = pstArcMarkInfCurV->uPeakRawValue;
        i_pstStAxisParam->uiPeakValue_t2 = pstArcMarkInfFollowV->uPeakRawValue;
    }
    else
    {
        /* 兜底 */
        i_pstStAxisParam->uiPeakValue_t1 = pstArcMarkInfCurV->uPeakRawValue;
        i_pstStAxisParam->uiPeakValue_t2 = pstArcMarkInfFollowV->uPeakRawValue;
    }

    /* 4) 阈值与门内基线回填（老架构口径） */
    if (o_alrThreshold != NULL && o_alrBase_Fs != NULL)
    {
        /* 默认兜底 */
        o_alrThreshold[0] = pstArcMarkInfCurV->fSignalGate_Sample / 256.0f;
        o_alrThreshold[1] = pstArcMarkInfFollowV->fSignalGate_Sample / 256.0f;
        o_alrBase_Fs[0]   = pstArcErrParam->fBase1 / 256.0f;
        o_alrBase_Fs[1]   = pstArcErrParam->fBase2 / 256.0f;

        if (i_pstStAxisParam->xFlag_Gate_double)
        {
            BYTE xFollowV = GET_BIT16(i_pstStAxisParam->wStatusRef, 12);
            BYTE xFollowH = GET_BIT16(i_pstStAxisParam->wStatusRef, 9);

            if (xFollowV || xFollowH)
            {
                if (i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_VFOR)
                {
                    /* VFOR: t1<-cur, t2<-follow */
                    o_alrThreshold[0] = pstArcMarkInfCurV->fSignalGate_Sample / 256.0f;
                    o_alrThreshold[1] = pstArcMarkInfFollowV->fSignalGate_Sample / 256.0f;
                }
                else if (i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_VREV)
                {
                    /* VREV: t1<-follow, t2<-cur */
                    o_alrThreshold[0] = pstArcMarkInfFollowV->fSignalGate_Sample / 256.0f;
                    o_alrThreshold[1] = pstArcMarkInfCurV->fSignalGate_Sample / 256.0f;
                }
            }
        }
    }
}


 /**
  * @brief  拿到物理色标宽度（单位mm）@用于全自动套印精调步骤
  * @param  pstArcMarkInf_Use: 色标信息结构体
  * @param  rSysPrecision: 系统精度系数
  * @return 色标物理宽度
  * @note   多级容错：优先补偿宽度→原始宽度→默认宽度
  */
 static float KS_FB_GetMarkWidthMm(ArcMarkInf* pstArcMarkInf_Use, float rSysPrecision)
 {
 	uint8_t byScopeLevelId;
 	float rWaveWidth;

 	if (pstArcMarkInf_Use == NULL || rSysPrecision <= 0.0f)
 	{
 		return 0.0f;
 	}

 	// 阈值等级容错处理
 	byScopeLevelId = pstArcMarkInf_Use->uScopeLevelId;
 	if (byScopeLevelId >= MAX_SCOPELEVEL_ARCMARK)
 	{
 		byScopeLevelId = 0;
 	}

 	// 多级宽度取值，保证数据有效性
 	rWaveWidth = pstArcMarkInf_Use->afWidthComp[byScopeLevelId];
 	if (rWaveWidth <= 0.0f)
 	{
 		rWaveWidth = pstArcMarkInf_Use->afWidth[byScopeLevelId];
 	}
 	if (rWaveWidth <= 0.0f)
 	{
 		rWaveWidth = pstArcMarkInf_Use->afWidthComp[0];
 	}
 	if (rWaveWidth <= 0.0f)
 	{
 		rWaveWidth = pstArcMarkInf_Use->afWidth[0];
 	}
 	// 转换为丝
 	return rWaveWidth * rSysPrecision;
 }


 /**
  * @brief  色标宽度信号处理（延时稳值+请求应答机制）
  * @param  全局参数+色标信息
  * @return 无
  * @note   收到宽度请求后，延时2个精采样周期，输出稳定宽度值
  */
 static void KS_FB_DealWaveWidth(StAxisParam* i_pstStAxisParam, ArcErrParam* pstArcErrParam, ArcMarkInf* pstArcMarkInf_Cur_V, ArcMarkInf* pstArcMarkInf_Follow_V)
 {
 	ArcMarkInf* pstArcMarkInf_Use;

 	if (i_pstStAxisParam == NULL || pstArcErrParam == NULL || pstArcMarkInf_Cur_V == NULL || pstArcMarkInf_Follow_V == NULL)
 	{
 		return;
 	}

 	// 根据色标排列顺序选择使用的色标信息
 	pstArcMarkInf_Use = pstArcMarkInf_Cur_V;//取当前色的宽度
 	i_pstStAxisParam->WaveWidth = KS_FB_GetMarkWidthMm(pstArcMarkInf_Use, pstArcErrParam->fPrecision_Act);


 	// 自动调整使能边沿：关闭→打开时，复位宽度标志
 	if (xPreFlag_AutoAdj_En == 0 && i_pstStAxisParam->xFlag_AutoAdj_En == 1)
 	{
 		i_pstStAxisParam->xFlag_AskWaveWidth = 0;
 		i_pstStAxisParam->xFlag_GiveWaveWidth = 0;
 		xFlagTrigger = 0;
 	}
 	// 收到宽度请求，触发延时
 	if (i_pstStAxisParam->xFlag_AskWaveWidth && xFlagTrigger == 0)
 	{
 		xFlagTrigger = 1;
 		uiWaitCount = 2;    // 延时2个精采样周期
 		i_pstStAxisParam->xFlag_GiveWaveWidth = 0;
 	}
 	// 延时倒计时结束，赋值稳定宽度
 	if (xFlagTrigger == 1)
 	{
 		uiWaitCount--;
 		if (uiWaitCount == 0)
 		{
 			i_pstStAxisParam->rWaveWidth = i_pstStAxisParam->WaveWidth;
 			i_pstStAxisParam->xFlag_GiveWaveWidth = 1;
 			xFlagTrigger = 0;
 		}
 	}
 	// 保存当前自动调整状态
 	xPreFlag_AutoAdj_En = i_pstStAxisParam->xFlag_AutoAdj_En;
 }

/**
 * @brief 组织给主站上报的误差与状态位
 */
/*
 * 组织上报误差与状态位
 * 这里尽量保持和旧版 KS_FB_ProSample 中该段逻辑一致，
 * 只是将代码封装成函数，结果来源改为新架构 ArcErrInf。
 */
 static void KS_FB_UpdatePduResult(
    StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
    StAxisParam* i_pstStAxisParam,
    const ArcErrInf* pstArcErrInfV,
    const ArcErrInf* pstArcErrInfH,
    BYTE xFakePointV,
    BYTE xFakePointH)
{
    if(i_pstStPara_PduBroadcastUp == NULL || i_pstStAxisParam == NULL ||
       pstArcErrInfV == NULL || pstArcErrInfH == NULL)
    {
        return;
    }

    i_pstStPara_PduBroadcastUp->byStsV = 0;
    i_pstStPara_PduBroadcastUp->byStsH = 0;

    BYTE xIsOMK = (i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_OMK) ? TRUE : FALSE;//界面上选定omk模式标志位

    /* ===== 纵向：对齐老架构“连续3帧丢失才上报” ===== */
    if (pstArcErrInfV->iErrValue == ARC_ERR_LOST)
{
    if (xIsOMK)
    {
        /*
         * OMK 未误差确认时算法层会给 LOST。
         * 这里不要沿用上一帧有效误差，否则切到 OMK 后会显示普通模式上一帧误差。
         */
        i_pstStPara_PduBroadcastUp->iVerror = ARC_ERR_LOST;
        i_pstStPara_PduBroadcastUp->byStsV |= (0x01 << 1);

        s_uiCount_ErrorLost = 0;
    }
    else
    {
        s_uiCount_ErrorLost++;

        if (s_uiCount_ErrorLost >= 3)
        {
            i_pstStPara_PduBroadcastUp->iVerror = ARC_ERR_LOST;
            i_pstStPara_PduBroadcastUp->byStsV |= (0x01 << 1);
        }
        else
        {
            i_pstStPara_PduBroadcastUp->iVerror = s_lastValidVErr;
        }
    }
}
else
{
    s_uiCount_ErrorLost = 0;
    i_pstStPara_PduBroadcastUp->iVerror = pstArcErrInfV->iErrValue;
    //s_lastValidVErr = i_pstStPara_PduBroadcastUp->iVerror;

    if (xFakePointV)
    {
        i_pstStPara_PduBroadcastUp->byStsV |= (0x01 << 2);
    }

    if ((i_pstStAxisParam->wStatusRef & 0x01) &&
        ABS(i_pstStPara_PduBroadcastUp->iVerror) > ABS(i_pstStAxisParam->lrAlarm_V * 100.0f))
    {
        i_pstStPara_PduBroadcastUp->byStsV |= (0x01 << 0);
    }
}



    /* ===== 横向 ===== */
    if(pstArcErrInfH->iErrValue == ARC_ERR_LOST)
    {
        i_pstStPara_PduBroadcastUp->iHerror = ARC_ERR_LOST;
        i_pstStPara_PduBroadcastUp->byStsH |= (0x01 << 1);
    }
    else
    {
        i_pstStPara_PduBroadcastUp->iHerror = pstArcErrInfH->iErrValue;

        if(xFakePointH)
        {
            i_pstStPara_PduBroadcastUp->byStsH |= (0x01 << 2);
        }

        if((i_pstStAxisParam->wSwitchRef & 0x01) &&
           (i_pstStAxisParam->wStatusRef & 0x02) &&
           ABS(i_pstStPara_PduBroadcastUp->iHerror) > ABS(i_pstStAxisParam->lrAlarm_H * 100.0f))
        {
            i_pstStPara_PduBroadcastUp->byStsH |= (0x01 << 0);
        }
    }

    /* ===== 老架构一致：横向开关关时 iHerror=0 ===== */
    if (GET_BIT16(i_pstStAxisParam->wSwitchRef, 0) == 0)
    {
        i_pstStPara_PduBroadcastUp->iHerror = 0;
    }
}

/**
 * @brief 执行飞点剔除检查
 */
 static void KS_FB_DoFakePointCheck(
    StAxisParam* i_pstStAxisParam,
    const ArcErrInf* pstArcErrInfV,
    const ArcErrInf* pstArcErrInfH,
    StPickOutFakePoint* pstStPickOutFakePointIn,
    BYTE* pxFakePointV,
    BYTE* pxFakePointH)
{
    if(i_pstStAxisParam == NULL || pstArcErrInfV == NULL || pstArcErrInfH == NULL ||
       pstStPickOutFakePointIn == NULL || pxFakePointV == NULL || pxFakePointH == NULL)
    {
        return;
    }

    *pxFakePointV = 0;
    *pxFakePointH = 0;

    pstStPickOutFakePointIn->i_iBoundaryError_0_01mm = 20;
    pstStPickOutFakePointIn->i_iErrorLevel_0_01mm = 25;
    pstStPickOutFakePointIn->i_iVariationVariationMin = 5;
    pstStPickOutFakePointIn->i_iVariationVariationMax = 50;

    /* 纵向：保持和老架构一致，基于最终误差值 + 是否有效 */
    pstStPickOutFakePointIn->i_xIsValidError =
        (pstArcErrInfV->iErrValue == ARC_ERR_LOST) ? 0 : 1;
    pstStPickOutFakePointIn->i_iError_0_01mm = pstArcErrInfV->iErrValue;

    if(i_pstStAxisParam->byFakeThreshold_V == 0)
    {
        pstStPickOutFakePointIn->i_iVariationBaseValue = 5;
    }
    else if(i_pstStAxisParam->byFakeThreshold_V > 50)
    {
        pstStPickOutFakePointIn->i_iVariationBaseValue = 50;
    }
    else
    {
        pstStPickOutFakePointIn->i_iVariationBaseValue = (INT)i_pstStAxisParam->byFakeThreshold_V;
    }

    KS_FB_PickOutFakePointV2_V(*pstStPickOutFakePointIn, pxFakePointV);

    /* 横向：保持和老架构一致，基于最终误差值 + 是否有效 */
    pstStPickOutFakePointIn->i_xIsValidError =
        (pstArcErrInfH->iErrValue == ARC_ERR_LOST) ? 0 : 1;
    pstStPickOutFakePointIn->i_iError_0_01mm = pstArcErrInfH->iErrValue;

    if(i_pstStAxisParam->byFakeThreshold_H == 0)
    {
        pstStPickOutFakePointIn->i_iVariationBaseValue = 5;
    }
    else if(i_pstStAxisParam->byFakeThreshold_H > 50)
    {
        pstStPickOutFakePointIn->i_iVariationBaseValue = 50;
    }
    else
    {
        pstStPickOutFakePointIn->i_iVariationBaseValue = (INT)i_pstStAxisParam->byFakeThreshold_H;
    }

    KS_FB_PickOutFakePointV2_H(*pstStPickOutFakePointIn, pxFakePointH);
}

/**
 * @brief 迁移版主流程函数
 */
ArcMarkParam g_stArcMarkParam;
ArcErrParam  g_stArcErrParam;
ArcMarkInf   g_stArcMarkInfCurV, g_stArcMarkInfFollowV, g_stArcMarkInfCurH, g_stArcMarkInfFollowH;
ArcErrInf    g_stArcErrInfV, g_stArcErrInfH;
StPickOutFakePoint g_stStPickOutFakePointIn;

void KS_FB_ProSample_V2(
    StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
    WORD* i_puiFineData1,
    WORD* i_puiFineData2,
    INT i_iFineSampleFlag,
    StAxisParam* i_pstStAxisParam,
    StGrpParam* i_pstStGrpParam,
    REAL i_alrBase[2],
    INT o_aiError_V[40],
    INT o_aiError_H[40],
    INT aiFineSample_Data[9],
    BYTE* i_pxOK_PosConfirmed,
    BYTE i_xOK_FromMaster,
    REAL o_alrThreshold[2],
    REAL o_alrBase_Fs[2],
    BYTE* i_pbyRSdata1,
    BYTE* i_pbyRSdata2,
    BYTE i_xFlag_SingleMode)
{
    BYTE xFakePointV = 0;
    BYTE xFakePointH = 0;
    

    (void)i_pbyRSdata1;
    (void)i_pbyRSdata2;
    (void)i_xFlag_SingleMode;

    if (i_pstStPara_PduBroadcastUp == NULL || i_pstStAxisParam == NULL ||
        i_pstStGrpParam == NULL || i_alrBase == NULL ||
        i_pxOK_PosConfirmed == NULL)
    {
        return;
    }

    if (!i_iFineSampleFlag)
    {
        return;
    }

    /* 1. 调用核心算法 */
    KSCalcArcErr_VH(
        i_puiFineData1,
        i_puiFineData2,
        i_pstStAxisParam,
        i_pstStGrpParam,
        i_alrBase,
        i_pxOK_PosConfirmed,
        i_xOK_FromMaster,
        &g_stArcMarkParam,
        &g_stArcMarkInfCurV,
        &g_stArcMarkInfFollowV,
        &g_stArcMarkInfCurH,
        &g_stArcMarkInfFollowH,
        &g_stArcErrParam,
        &g_stArcErrInfV,
        &g_stArcErrInfH);

    /* 2. 更新监控量 */
    KS_FB_UpdateAxisMonitor(
        i_pstStAxisParam,
        &g_stArcErrParam,
        &g_stArcMarkInfCurV,
        &g_stArcMarkInfFollowV,
        &g_stArcErrInfV,
        &g_stArcErrInfH,
        o_alrThreshold,
        o_alrBase_Fs);

    //3.行走机构精调所需要的宽度
     KS_FB_DealWaveWidth(
		i_pstStAxisParam,
		&g_stArcErrParam,
		&g_stArcMarkInfCurV,
		&g_stArcMarkInfFollowV);

    /* 3. 飞点剔除：基于最终误差值判断 */
    KS_FB_DoFakePointCheck(
        i_pstStAxisParam,
        &g_stArcErrInfV,
        &g_stArcErrInfH,
        &g_stStPickOutFakePointIn,
        &xFakePointV,
        &xFakePointH);

    /* 4. 一次性组织最终上报结果与状态位 */
    KS_FB_UpdatePduResult(
        i_pstStPara_PduBroadcastUp,
        i_pstStAxisParam,
        &g_stArcErrInfV,
        &g_stArcErrInfH,
        xFakePointV,
        xFakePointH);

    /* 5. 单标记确认后清零请求，并与老架构保持一致 */
     /* 5. 单标记确认后清零请求，并与老架构保持一致 */
    if (*i_pxOK_PosConfirmed)
    {
        if (i_pstStAxisParam->iMarkArrangeModal == MARK_ARRANGE_OMK)
        {
            i_pstStAxisParam->lrAdjust_V = 0;
            s_byDataCurIndex_V = 0;
            s_xDataInitDne_V = 0;
        }
        *i_pxOK_PosConfirmed = 0;
    }

    /* 6. 误差结果写回：与老架构对齐，写入HMI显示平均值 */
    if (o_aiError_V != NULL && o_aiError_H != NULL)
    {
        int i;
        int16_t iVerrorHmi = 0;
        int16_t iHerrorHmi = 0;
        uint8_t xAverageEnTmp = 0;

        for (i = 39; i >= 1; --i)
        {
            o_aiError_V[i] = o_aiError_V[i - 1];
            o_aiError_H[i] = o_aiError_H[i - 1];
        }

        /* 纵向 HMI 显示平均：OMK 确认帧直接用原始值，避免平均拉向旧数据 */
        xAverageEnTmp = (i_pstStAxisParam->byAve_v_extra_V > i_pstStAxisParam->iAverage_V) ? 1 : 0;
        if(ABS(i_pstStPara_PduBroadcastUp->iVerror) > 10000)
            iVerrorHmi = i_pstStPara_PduBroadcastUp->iVerror;
        else
        {
            iVerrorHmi = (int16_t)KS_Average_copy(xAverageEnTmp,
                                i_pstStPara_PduBroadcastUp->iVerror,
                                i_pstStAxisParam->byAve_v_extra_V,
                                                s_aidatabuff_V,
                                                &s_byDataCurIndex_V,
                                                &s_xDataInitDne_V);
            if(!xAverageEnTmp)
                iVerrorHmi = i_pstStPara_PduBroadcastUp->iVerror;
        }

        /* 横向 HMI 显示平均 */
        xAverageEnTmp = (i_pstStAxisParam->byAve_v_extra_V > i_pstStAxisParam->iAverage_H) ? 1 : 0;
        if(ABS(i_pstStPara_PduBroadcastUp->iHerror) > 10000)
        {
            iHerrorHmi = i_pstStPara_PduBroadcastUp->iHerror;
        }
        else
        {
            iHerrorHmi = (int16_t)KS_Average_copy(xAverageEnTmp,
                                             i_pstStPara_PduBroadcastUp->iHerror,
                                             i_pstStAxisParam->byAve_v_extra_V,
                                             s_aidatabuff_H,
                             &s_byDataCurIndex_H,
                                &s_xDataInitDne_H);
            if(!xAverageEnTmp)
                iHerrorHmi = i_pstStPara_PduBroadcastUp->iHerror;
        }

        o_aiError_V[0] = iVerrorHmi;
        o_aiError_H[0] = iHerrorHmi;

        /* 与老架构对齐：回退值跟随HMI平均值 */
        if(i_pstStPara_PduBroadcastUp->iVerror != ARC_ERR_LOST)
        {
            s_lastValidVErr = (int16_t)iVerrorHmi;
        }
    }

    /* 7. 调试/上层兼容输出*/
    if (aiFineSample_Data != NULL)
    {
        aiFineSample_Data[0] = (i_pstStPara_PduBroadcastUp->iVerror == ARC_ERR_LOST) ? -3 : 0;
        aiFineSample_Data[1] = (i_pstStPara_PduBroadcastUp->iHerror == ARC_ERR_LOST) ? -3 : 0;
        aiFineSample_Data[2] = i_pstStPara_PduBroadcastUp->iVerror;
        aiFineSample_Data[3] = i_pstStPara_PduBroadcastUp->iHerror;
    }

    i_pstStPara_PduBroadcastUp->byIndexV++;
    i_pstStPara_PduBroadcastUp->byIndexH++;

    s_uiFSampleCount++;
    i_pstStAxisParam->uiFSampleCounter = s_uiFSampleCount;
}
