/*
 * ks_conf_err.c
 *
 *  双置信度融合误差模块实现(老架构误差链路外挂)
 *  本模块只负责置信度计算与误差融合,不涉及飞点剔除(飞点开关归ks_fly_remove.h自持)
 *  置信度公式逐条移植自仿真平台qtversion的ks_calc_arc_err_opt.c:
 *    KSOptNoteCrossings(:229)/KSOptBlendConf(:292) → 本模块ks_conf_note_ck/ks_conf_ck_conf
 *    KSOptCalcQn(:88)                             → 本模块ks_conf_calc_qn
 *    KSOptQnConf(:311)/KSOptBlendOutput(:327)     → 本模块ks_conf_qn_conf/ks_conf_blend
 *  信号源适配为老链StCalcParam_Out.astStSignalParsingGroupDetail(单位口径已核对calcerr.c):
 *    ①交点位置=门内局部点数(带小数插值,0基),三档阈值顺序[0]=50%[1]=25%[2]=75%
 *    ②alrMidlinePos已按标记形式完成选沿(梯形前沿/后沿/Line中线),与opt选沿规则一致
 *    ③auiFSampData_Filtered即Qn噪声窗所用门内滤波波形(对应opt的auDataFilter)
 *    ④有效幅值alrSignalEffectiveScope对应opt的fSignalEffectiveScope
 *  与仿真平台的有意差异(信号源/口径不同,数值不逐位一致):
 *    E_k=o_iVResult/o_iHResult(老链N幅平均+修正量后的当圈上报值,而非opt的原始误差);
 *    混合在calcerr.c之外进行,calcerr.c零改动
 *  |wang.c+双置信度融合 2026.11.9.165510|解耦飞点开关 2026.11.9.171753
 *
 *  2026.11.10调整(Yang.zj):
 *    ①Qn噪声窗改对称锚:右窗由75%后沿b75改为25%后沿b25外扩half_base(与左窗f25对称);
 *    ②有效幅值<3000(LSB)时Qn直接置满分(沿过缓,宽度测量随机精度无意义,
 *      融合F=√(C×Qn/100)=√C,质量单靠CK评价),该圈不进噪声链;
 *      仅作用Qn——CK的s计算与参照刷新均不受低幅影响;
 *    ③σ维持3点滤波后数据口径(2026-11-10确认接受:白噪声工况Qn较原始口径偏乐观,已知)
 *    |Yang.zj+噪声窗对称/幅值门槛Qn满 2026.11.10.110543|撤销CK记忆门槛(低幅仅置Qn,与C无关) 2026.11.10.112204
 */

#include "ks_conf_err.h"
#include <math.h>
#include <string.h>

/* ---------------- 常量(与仿真平台opt链一致) ---------------- */
#define KS_CONF_STREAM_NUM		4	/* 流=(波门组0/1)×(通道T1/T2)|单波门只算g0 |wang.c+双置信度融合 2026.11.9.165510 */
#define KS_CONF_IDX(g,c)		((g)*2+(c))
#define KS_CONF_TAU_SILK		5.0f	/* Qn容差τ@丝|固定值,需要可调时再开变量(仿真平台optTauSilk默认5) */
#define KS_CONF_MAD_C			1.4826f	/* MAD→正态标准差系数 */
#define KS_CONF_SQRT2			1.41421356f
#define KS_CONF_QN_MIN_PT_LOOSE	16	/* 噪声窗最少点数(保底模式:每侧残块≥8)|2026.11.12
									 * 原60点门槛随"每侧保底一块"决策放宽;常规整块n≥BL≥16不受影响 */
/* KS_CONF_QN_KEEP_MIN(40绝对保留线)已并入60%比例线:n≥67时二者等价,小n放宽|2026.11.12 */
#define KS_CONF_QN_KEEP_RATIO	0.6f	/* 离群剔除后最少保留比例 */
#define KS_CONF_QN_MAXPT		3000	/* 噪声残差缓冲上限@同detail滤波数组维度 */
#define KS_CONF_QN_BLK_MAX		256	/* 分块尺寸上限@块排序缓冲维度 */
#define KS_CONF_QN_QUANT		4.0f	/* 精采样数据量化码@LSB(实测数据为4的整倍数):MAD/σ下限
									 * 治本2026.11.12——空白区"钉零+稀疏量化毛刺"型噪声下,原0.5下限
									 * 使MAD塌底→剔除阈值仅2.6LSB→毛刺全体被判离群→保留率<60%整窗误拒;
									 * 下限提到1个量化码后阈值≈20.8LSB,毛刺回归噪声身份,窗口正常通过,
									 * σ可实测(连续噪声工况σ>4,下限不参与,行为不变) */
#define KS_CONF_QN_SCOPE_MIN	3000.0f	/* 有效幅值门槛@LSB:低于此沿过缓,宽度测量随机精度
									 * 无意义→Qn置满分(质量单靠CK);仅作用于Qn,与CK无关
									 * |Yang.zj+ 2026.11.10.110543(110543版误加CK记忆门槛,112204撤销) */

/* 本地位提取(避免跨头文件依赖)|wang.c+双置信度融合 2026.11.9.165510 */
#define KS_CONF_GETBIT16(w,b)	((BYTE)(((WORD)(w)>>(b))&0x0001))

/* ---------------- 全局开关/变量(定义,声明见ks_conf_err.h) ---------------- */
BYTE xEnableConfErr = 0;	 /* 置信度观察开关(46059.03)|=1计算并显示置信度(6206),误差链仍用
							 * 原每圈值|=0完全原行为(默认)|开关语义解耦:仅显示不接入误差链 2026.11.12 */
BYTE xSwitchWrEn = 0;		 /* 置信度接入误差链开关(46059.04)|仅在xEnableConfErr=1时有效:再=1
							 * 融合误差才替换上报o_iVResult/o_iHResult|=0只显示不接入(默认)
							 * |开关语义解耦:双开才接入 2026.11.12 */
REAL rConfS50Mm = 0.08f;	 /* s50默认0.08mm|wang.c+双置信度融合 2026.11.9.165510 */
REAL rConfLastRevV = 0.0f;	/* 纵向每圈融合置信度记录0~100 */
REAL rConfLastRevH = 0.0f;	/* 横向每圈融合置信度记录0~100 */

/* ---------------- 模块内部状态 ---------------- */
/* CK流状态:上一圈三档交点+本圈位移标准差s(点,<0=本圈无效)|对应opt的s_optPrevX/s_optCurS
 * 流key=(波门组,通道);色序/排列/双波门变化时整体复位(物理标记变了历史不可信)
 * |wang.c+双置信度融合 2026.11.9.165510 */
static REAL  s_afPrevX[KS_CONF_STREAM_NUM][3];
static BYTE  s_xHasPrev[KS_CONF_STREAM_NUM];
static REAL  s_afCurS[KS_CONF_STREAM_NUM];
/* Qn流状态:本圈Qn(0~100,<0=本圈无效)|对应opt的s_optCurQn */
static REAL  s_afCurQn[KS_CONF_STREAM_NUM];
/* 融合路递推状态|对应opt融合路的s_optPrevOutVFu/s_optHasPrevOutVFu */
static INT   s_iPrevOutV, s_iPrevOutH;
static BYTE  s_xHasPrevOutV, s_xHasPrevOutH;
/* 本圈输出(含-32768丢失直通) */
static INT   s_iOutV, s_iOutH;

/* Qn噪声窗工作缓冲(单缓冲:残差升序排序后离群剔除即前缀,与opt双缓冲数值等价省12KB)
 * |wang.c+双置信度融合 2026.11.9.165510 */
static REAL  s_afQnResid[KS_CONF_QN_MAXPT];
static REAL  s_afQnBlk[KS_CONF_QN_BLK_MAX];

/* ---------------- 工具:快速选择取第k小(原插入排序/全排序已废弃) ----------------
 * opt桌面版用纯插入排序,ARM上O(n²)过慢|wang.c+双置信度融合 2026.11.9.165510
 * 改为快速选择(只影响耗时不影响数值)|2026.11.12 */
/* 快速选择:返回数组第k小(0基)的值,平均O(n)|2026.11.12
 * 替代原逐块插入排序(O(BL²))与残差全排序(O(n·logn))——中位数取值唯一,
 * 与算法无关,数值逐位一致(按用户指令:效果相同时优先时间复杂度最小;
 * DWT实测排序占置信度耗时大头);三点取中枢轴,噪声残差近随机,退化可忽略 */
static REAL ks_conf_qselect(REAL* a, INT n, INT k)
{
	INT iLo = 0, iHi = n - 1;
	REAL rPivot, rTmp;
	while (iLo < iHi)
	{
		INT iMid = iLo + (iHi - iLo) / 2;
		INT l, h;
		if (a[iMid] < a[iLo]) { rTmp = a[iLo]; a[iLo] = a[iMid]; a[iMid] = rTmp; }
		if (a[iHi] < a[iLo]) { rTmp = a[iLo]; a[iLo] = a[iHi]; a[iHi] = rTmp; }
		if (a[iHi] < a[iMid]) { rTmp = a[iMid]; a[iMid] = a[iHi]; a[iHi] = rTmp; }
		rPivot = a[iMid];
		l = iLo; h = iHi;
		while (l <= h)
		{
			while (a[l] < rPivot) l++;
			while (a[h] > rPivot) h--;
			if (l <= h) { rTmp = a[l]; a[l] = a[h]; a[h] = rTmp; l++; h--; }
		}
		if (k <= h) iHi = h;          /* 第k小在左段 */
		else if (k >= l) iLo = l;     /* 第k小在右段 */
		else return a[k];             /* h<k<l: a[k]在等于枢轴的中间带,即为所求 */
	}
	return a[k];
}

/* ---------------- CK:三档交点跨圈位移一致性(移植KSOptNoteCrossings) ----------------
 * 选沿规则与误差计算严格一致:老链alrMidlinePos已按标记形式完成(梯形前沿/后沿/Line中线),
 * 三档均有效才记账;任一档无效本圈s=-1且不更新历史(与opt一致,坏圈不污染参照)
 * |wang.c+双置信度融合 2026.11.9.165510 */
static void ks_conf_note_ck(const StSignalParsingGroupDetail* d, INT c, INT idx)
{
	REAL x[3], d0, d1, d2, mean, var;
	INT i;
	BYTE all = 1;

	for (i = 0; i < 3; i++)
	{
		if (d->axThresholdLevelValidFlag[c][i] == 0) { all = 0; break; }
		x[i] = d->alrMidlinePos[c][i];
	}
	if (all)
	{
		if (s_xHasPrev[idx])
		{
			d0 = x[0] - s_afPrevX[idx][0];
			d1 = x[1] - s_afPrevX[idx][1];
			d2 = x[2] - s_afPrevX[idx][2];
			mean = (d0 + d1 + d2) / 3.0f;
			var = ((d0 - mean) * (d0 - mean) + (d1 - mean) * (d1 - mean)
				+ (d2 - mean) * (d2 - mean)) / 2.0f;/* 样本方差(÷2=÷(3-1)) */
			s_afCurS[idx] = sqrtf(var);
		}
		for (i = 0; i < 3; i++) s_afPrevX[idx][i] = x[i];
		s_xHasPrev[idx] = 1;
	}
	/* all=0:s_afCurS[idx]保持圈首置的-1(本圈无效) */
}

/* ---------------- Qn:宽度测量随机精度分数(移植KSOptCalcQn数学部分) ----------------
 * 噪声窗=门内标记两侧空白区(25%前沿f25/25%后沿b25对称各外扩half_base=25%标宽;
 * 原+0.8mm脚部安全边K已取消,冗余|2026.11.12用户决策)
 * |Yang.zj+噪声窗对称 2026.11.10.110543(原右窗锚75%后沿b75,不对称);
 * 分块(2.77mm/精度)取中位数去局部基线,残差做MAD,剔除3.5×1.4826×MAD离群后
 * σ=1.4826×中位数;斜率m=0.5×幅值/(25%→75%沿跨度)取前后沿较小;
 * jp=2σ·si/m_min(si=精度×100丝/点),Qn=100·erf(τ/(√2·jp)),arg>3直接100
 * 有效幅值<KS_CONF_QN_SCOPE_MIN(3000)时Qn直接置满分不进噪声链(见函数内)
 * 【治本】2026.11.12: MAD/σ下限0.5→KS_CONF_QN_QUANT(1个量化码)——空白区"钉零+稀疏
 * 量化毛刺"型噪声下原下限致MAD塌底→阈值2.6LSB→毛刺全判离群→整窗误拒(实测数据
 * rev1-4/rev6命中);下限提高后毛刺回归噪声身份,窗口通过,σ可实测;
 * 其余"评不了"分支(沿无效/点数不足/剔除拒绝/斜率不可估等)保持原有无效语义(-1→F=0冻结)
 * |2026.11.12用户决策:异常置满分的方案已回退,采用量化下限治本
 * σ在3点滤波后数据上计算为既定口径(2026-11-10确认:白噪声工况较原始口径偏乐观,接受)
 * 老链口径:交点位置0基门内点数无需opt的-1;25%档=索引1,75%档=索引2
 * |wang.c+双置信度融合 2026.11.9.165510 */
static void ks_conf_calc_qn(const StSignalParsingGroupDetail* d, INT c, INT idx,
							REAL rPrecMm, INT iDn)
{
	INT i, j, n, nKept, dn, markW, BL;
	INT lwS, lwE, rwS, rwE;
	REAL sigma, mf, mb, mMin, si, jp, arg, mad, thr;
	REAL f25, b25, f75, b75, scope, df, db, bm;

	scope = d->alrSignalEffectiveScope[c];
	if (scope <= 0.0f) return;
	/* 有效幅值过小(沿过缓,宽度测量的随机精度已无评价意义):Qn直接置满分,
	 * 融合F=√(C×Qn/100)=√C即质量单靠CK评价;本圈不进噪声链
	 * (仅作用Qn:CK的s计算与参照刷新均不受低幅影响)|Yang.zj+幅值门槛Qn置满 2026.11.10.110543 */
	if (scope < KS_CONF_QN_SCOPE_MIN)
	{
		s_afCurQn[idx] = 100.0f;
		return;
	}
	/* 25%/75%两档须前后沿均有效(评的是宽度测量精度,与标型选沿无关) */
	if (d->axThresholdLevelValidFlag[c][1] == 0 || d->axThresholdLevelValidFlag[c][2] == 0)
	{
		return;/* s_afCurQn[idx]保持圈首置的-1 */
	}
	f25 = d->alrEdgeCrossPointPosLR[c][1][0];/* 25%前沿|门内点0基 */
	b25 = d->alrEdgeCrossPointPosLR[c][1][1];/* 25%后沿 */
	f75 = d->alrEdgeCrossPointPosLR[c][2][0];/* 75%前沿 */
	b75 = d->alrEdgeCrossPointPosLR[c][2][1];/* 75%后沿 */

	/* 门内实际点数:右窗截到有效数据内(超界会读到门外的陈旧数据)
	 * |wang.c+双置信度融合 2026.11.9.165510 */
	dn = iDn;
	if (dn < 1) dn = 1;
	if (dn > KS_CONF_QN_MAXPT) dn = KS_CONF_QN_MAXPT;

	markW = (INT)(b25 - f25);/* 25%处标宽(点) */
	if (markW <= 0) return;
	/* K(0.8mm脚部安全边)取消|2026.11.12用户决策: W25外扩本身已覆盖标记脚部,
	 * 叠加K属冗余,窄门工况每侧白白损失0.8mm空白;排除区半宽=25%标宽 */
	BL = (INT)(2.77f / rPrecMm + 0.5f);/* 2.77mm物理带宽换算为块长 */
	if (BL < 16) BL = 16;
	if (BL > KS_CONF_QN_BLK_MAX) BL = KS_CONF_QN_BLK_MAX;

	/* 左窗:[0, f25-halfBase),右窗:[b25+halfBase, dn)截到门内
	 * 两侧对称:均以25%沿为锚向外扩half_base(原右窗锚75%后沿b75,不对称)
	 * |Yang.zj+噪声窗对称 2026.11.10.110543;
	 * 边界只做越界钳位,不再"放不下整块则整窗置空"——放不下整块的侧由
	 * 下方"每侧保底一块"补残块|2026.11.12用户决策 */
	/* 边界取整与Python同口径:int(f25-W25浮点)整体取整,而非各自取整再相减|2026.11.12 */
	lwS = 0;
	lwE = (INT)(f25 - (b25 - f25));
	if (lwE < lwS) lwE = lwS;
	rwS = (INT)(b25 + (b25 - f25));
	if (rwS < 0) rwS = 0;
	rwE = dn;
	if (rwS > rwE) rwS = rwE;

	/* 分块去趋势:每块取中位数,偏差从块中位数算;
	 * 左窗块自排除边向左铺(与Python双端同步镜像一致,原从门首向右|2026.11.12),
	 * 逐块独立减中位,块相位对σ数值本不敏感,此为逐位对齐 */
	n = 0;
	for (i = lwE - BL; i >= lwS && n + BL <= KS_CONF_QN_MAXPT; i -= BL)
	{
		for (j = 0; j < BL; j++) s_afQnBlk[j] = (REAL)d->auiFSampData_Filtered[c][i + j];
		bm = ks_conf_qselect(s_afQnBlk, BL, BL / 2);/* 快速选择取上中位,值与原插入排序一致|2026.11.12 */
		for (j = 0; j < BL; j++)
			s_afQnResid[n++] = fabsf((REAL)d->auiFSampData_Filtered[c][i + j] - bm);
	}
	for (i = rwS; i + BL <= rwE && n + BL <= KS_CONF_QN_MAXPT; i += BL)
	{
		for (j = 0; j < BL; j++) s_afQnBlk[j] = (REAL)d->auiFSampData_Filtered[c][i + j];
		bm = ks_conf_qselect(s_afQnBlk, BL, BL / 2);/* 同左窗|2026.11.12 */
		for (j = 0; j < BL; j++)
			s_afQnResid[n++] = fabsf((REAL)d->auiFSampData_Filtered[c][i + j] - bm);
	}
	/* 每侧保底一块|2026.11.12用户决策: 某侧放不下整块但空白≥8点时,取整窗残块
	 * (块长=窗口长,紧贴排除区边),避免宽标窄门两侧全空、σ无从估计("数量不够
	 * 也可以");常规工况(该侧≥1整块)不经过此处,行为不变 */
	{
		INT lwLen = lwE - lwS;
		INT rwLen = rwE - rwS;
		if (lwLen > 0 && lwLen < BL && lwLen >= 8 && n + lwLen <= KS_CONF_QN_MAXPT)
		{
			for (j = 0; j < lwLen; j++)
			{
				s_afQnBlk[j] = (REAL)d->auiFSampData_Filtered[c][lwS + j];
			}
			bm = ks_conf_qselect(s_afQnBlk, lwLen, lwLen / 2);/* 快速选择取上中位|2026.11.12 */
			for (j = 0; j < lwLen; j++)
				s_afQnResid[n++] = fabsf((REAL)d->auiFSampData_Filtered[c][lwS + j] - bm);
		}
		if (rwLen > 0 && rwLen < BL && rwLen >= 8 && n + rwLen <= KS_CONF_QN_MAXPT)
		{
			for (j = 0; j < rwLen; j++)
			{
				s_afQnBlk[j] = (REAL)d->auiFSampData_Filtered[c][rwS + j];
			}
			bm = ks_conf_qselect(s_afQnBlk, rwLen, rwLen / 2);/* 同左残块|2026.11.12 */
			for (j = 0; j < rwLen; j++)
				s_afQnResid[n++] = fabsf((REAL)d->auiFSampData_Filtered[c][rwS + j] - bm);
		}
	}
	if (n < KS_CONF_QN_MIN_PT_LOOSE) return;/* 保底模式下限16点(每侧残块≥8);
	 * 常规整块n≥BL≥16自动满足,原60点门槛随"每侧保底一块"决策放宽|2026.11.12 */

	/* MAD+离群剔除:全排序改两次快速选择+线性计数,取值与原排序口径逐位一致
	 * (kept=≤thr的nKept个最小值,其第(nKept/2)小即保留组中位)|2026.11.12 */
	mad = ks_conf_qselect(s_afQnResid, n, n / 2);
	if (mad < KS_CONF_QN_QUANT) mad = KS_CONF_QN_QUANT;/*量化下限治本2026.11.12,见常量注释*/
	thr = 3.5f * KS_CONF_MAD_C * mad;
	nKept = 0;
	for (i = 0; i < n; i++)
	{
		if (s_afQnResid[i] <= thr) nKept++;/* 线性计数(数组不再整体有序) */
	}
	/* 绝对40点线取消仅留60%比例线:n≥67时0.6n≥40.2,与原判定完全等价;
	 * 小n(仅保底模式/粗采小门可达)按比例放宽|2026.11.12 */
	if ((REAL)nKept < KS_CONF_QN_KEEP_RATIO * (REAL)n)
	{
		return;
	}
	sigma = KS_CONF_MAD_C * ks_conf_qselect(s_afQnResid, n, nKept / 2);
	if (sigma < KS_CONF_QN_QUANT) sigma = KS_CONF_QN_QUANT;/*量化下限治本2026.11.12*/

	/* 斜率:前后沿25%→75%跨度 */
	df = f75 - f25;
	db = b25 - b75;
	if (df <= 0.0f || db <= 0.0f) return;
	mf = 0.5f * scope / df;
	mb = 0.5f * scope / db;
	mMin = (mf < mb) ? mf : mb;
	if (mMin <= 0.0f) return;

	/* jp与Qn */
	si = rPrecMm * 100.0f;/* 丝/点 */
	jp = 2.0f * sigma * si / mMin;
	if (jp <= 0.0f) return;
	arg = KS_CONF_TAU_SILK / (KS_CONF_SQRT2 * jp);
	if (arg > 3.0f) { s_afCurQn[idx] = 100.0f; return; }
	s_afCurQn[idx] = 100.0f * erff(arg);
}

/* ---------------- 误差涉及流选取(核对calcerr.c波门↔标记映射) ----------------
 * 单波门:全部用detail[0]双通道;
 * 双波门VFOR(纵顺):跟前一色=detail[1]双通道,跟任意色=detail[1].T1+detail[0].T1;
 * 双波门VREV(纵逆):跟前一色=detail[0]双通道,跟任意色=detail[1].T2+detail[0].T2;
 * 横排双波门calcerr不计算误差(上报丢失),取detail[0]双通道(置信度不参与上报);
 * 跟踪选择位:纵向wStatusRef.12/横向wStatusRef.9(与calcerr.c选择aiVerror[1]/[0]一致)
 * |wang.c+双置信度融合 2026.11.9.165510 */
static void ks_conf_pick_streams(const StCalcParam_In* in, const StAxisParam* ax,
									BYTE xFollowOther, INT* pi0, INT* pi1)
{
	if (in->i_xFlag_Gate_double == 0)
	{
		*pi0 = KS_CONF_IDX(0, 0);
		*pi1 = KS_CONF_IDX(0, 1);
		return;
	}
	switch (in->i_iMarkArrangeId)
	{
		case MARK_ARRANGE_VFOR:
			if (xFollowOther) { *pi0 = KS_CONF_IDX(1, 0); *pi1 = KS_CONF_IDX(0, 0); }
			else			  { *pi0 = KS_CONF_IDX(1, 0); *pi1 = KS_CONF_IDX(1, 1); }
			break;
		case MARK_ARRANGE_VREV:
			if (xFollowOther) { *pi0 = KS_CONF_IDX(1, 1); *pi1 = KS_CONF_IDX(0, 1); }
			else			  { *pi0 = KS_CONF_IDX(0, 0); *pi1 = KS_CONF_IDX(0, 1); }
			break;
		default:
			*pi0 = KS_CONF_IDX(0, 0);
			*pi1 = KS_CONF_IDX(0, 1);
			break;
	}
	(void)ax;/* 选择位从参数带入,轴参数预留 */
}

/* CK置信度:两标记s取max(短板决定)换算mm后映射C=2^-(sMm/s50)²;任一流无效→0(保持上一圈)
 * |移植KSOptBlendConf|wang.c+双置信度融合 2026.11.9.165510 */
static REAL ks_conf_ck_conf(INT i0, INT i1, REAL rPrecMm)
{
	REAL s0, s1, sMm, r;

	s0 = s_afCurS[i0];
	s1 = s_afCurS[i1];
	if (s0 < 0.0f || s1 < 0.0f || rPrecMm <= 0.0f || rConfS50Mm <= 0.0f)
	{
		return 0.0f;
	}
	sMm = (s0 > s1 ? s0 : s1) * rPrecMm;/* 取更差的s→更低的置信度 */
	r = sMm / rConfS50Mm;
	return powf(2.0f, -r * r);
}

/* Qn置信度:两标记Qn取min(短板)归一0~1;任一无效→0 |移植KSOptQnConf
 * |wang.c+双置信度融合 2026.11.9.165510 */
static REAL ks_conf_qn_conf(INT i0, INT i1)
{
	REAL q0, q1;

	q0 = s_afCurQn[i0];
	q1 = s_afCurQn[i1];
	if (q0 < 0.0f || q1 < 0.0f)
	{
		return 0.0f;
	}
	return ((q0 < q1) ? q0 : q1) / 100.0f;
}

/* 递推混合:out_k=conf·E_k+(1-conf)·out_{k-1};哨兵圈(≤-32767)直通不更新历史;
 * 首个有效圈直接输出;四舍五入钳位±32767 |移植KSOptBlendOutput
 * |wang.c+双置信度融合 2026.11.9.165510 */
static INT ks_conf_blend(INT iErr, INT* piPrev, BYTE* pxHas, REAL rConf)
{
	REAL rBlend;
	DINT diRound;

	if (iErr <= -32767)
	{
		return iErr;/* 丢失/飞点哨兵:保持上一圈输出(由调用侧丢失分支处理上报) */
	}
	if (*pxHas == 0)
	{
		*piPrev = iErr;
		*pxHas = 1;
		return iErr;
	}
	rBlend = rConf * (REAL)iErr + (1.0f - rConf) * (REAL)(*piPrev);
	diRound = (DINT)(rBlend >= 0.0f ? rBlend + 0.5f : rBlend - 0.5f);
	if (diRound > 32767) diRound = 32767;
	if (diRound < -32767) diRound = -32767;
	*piPrev = (INT)diRound;
	return (INT)diRound;
}

/* ---------------- 对外接口 ---------------- */

/* 全状态复位|wang.c+双置信度融合 2026.11.9.165510 */
void KS_ConfErr_Reset(void)
{
	memset(s_afPrevX, 0, sizeof(s_afPrevX));
	memset(s_xHasPrev, 0, sizeof(s_xHasPrev));
	memset(s_afCurS, 0, sizeof(s_afCurS));
	memset(s_afCurQn, 0, sizeof(s_afCurQn));
	s_iPrevOutV = 0; s_iPrevOutH = 0;
	s_xHasPrevOutV = 0; s_xHasPrevOutH = 0;
	s_iOutV = 0; s_iOutH = 0;
	rConfLastRevV = 0.0f;
	rConfLastRevH = 0.0f;
}

void KS_ConfErr_Process(StAxisParam* i_pstStAxisParam,
						const StCalcParam_In* i_pstIn,
						const StCalcParam_Out* i_pstOut)
{
	/* 工况变化检测(静态记录上次状态) */
	static INT  iArrangePre = -1;/* 上次色标排列 */
	static BYTE byColorCurPre = 0xFF, byColorFolPre = 0xFF;/* 上次色序 */
	static BYTE xDoublePre = 0xFF;/* 上次双波门标志 */
	INT  iFollowV, iFollowH;
	INT  i0, i1;
	INT  g, c, idx;
	INT  nGates;
	INT  dnPt;
	REAL rPrecMm, rCV, rQV, rFV, rCH, rQH, rFH;

	if (i_pstStAxisParam == 0 || i_pstIn == 0 || i_pstOut == 0)
	{
		return;
	}

	/* 置信度开关翻转不复位:模块每圈都在算(开关只控制上报选择),翻转无缝衔接 */

	/* ①色序/排列/双波门变化:物理标记变了,CK流历史不可信整体复位
	 *   (Qn无历史不受影响;混合递推保留——误差电平连续性优先)|wang.c+双置信度融合 2026.11.9.165510 */
	if ((iArrangePre != -1) &&
		(iArrangePre != i_pstIn->i_iMarkArrangeId ||
		 byColorCurPre != i_pstStAxisParam->byColorIdCurrent ||
		 byColorFolPre != i_pstStAxisParam->byFollowColorId ||
		 xDoublePre != (BYTE)i_pstIn->i_xFlag_Gate_double))
	{
		memset(s_afPrevX, 0, sizeof(s_afPrevX));
		memset(s_xHasPrev, 0, sizeof(s_xHasPrev));
	}
	iArrangePre = i_pstIn->i_iMarkArrangeId;
	byColorCurPre = i_pstStAxisParam->byColorIdCurrent;
	byColorFolPre = i_pstStAxisParam->byFollowColorId;
	xDoublePre = (BYTE)i_pstIn->i_xFlag_Gate_double;

	/* ②圈首:本圈各流s/Qn全部置无效(只填实际解析过的门) */
	for (idx = 0; idx < KS_CONF_STREAM_NUM; idx++)
	{
		s_afCurS[idx] = -1.0f;
		s_afCurQn[idx] = -1.0f;
	}

	/* ③逐流计算CK与Qn */
	rPrecMm = i_pstIn->i_rSysPrecision;
	if (rPrecMm <= 0.0f) rPrecMm = 0.02f;/* 与KS_FB_ProSample的精度兜底一致 */
	dnPt = i_pstIn->i_iEachGatePointsNr;/* 门内点数(每门),calcerr按此界解析detail数组 */
	if (dnPt < 1) dnPt = 1;
	if (dnPt > KS_CONF_QN_MAXPT) dnPt = KS_CONF_QN_MAXPT;
	nGates = (i_pstIn->i_xFlag_Gate_double != 0) ? 2 : 1;/* 单波门只解析detail[0] */
	for (g = 0; g < nGates; g++)
	{
		for (c = 0; c < 2; c++)
		{
			idx = KS_CONF_IDX(g, c);
			ks_conf_note_ck(&i_pstOut->astStSignalParsingGroupDetail[g], c, idx);
			ks_conf_calc_qn(&i_pstOut->astStSignalParsingGroupDetail[g], c, idx, rPrecMm, dnPt);
		}
	}

	/* ④纵向:涉及流→C/Qn→F→混合(丢失圈直通-32768,保持递推状态,记录变量不刷) */
	iFollowV = (INT)KS_CONF_GETBIT16(i_pstStAxisParam->wStatusRef, 12);
	iFollowH = (INT)KS_CONF_GETBIT16(i_pstStAxisParam->wStatusRef, 9);
	ks_conf_pick_streams(i_pstIn, i_pstStAxisParam, (BYTE)iFollowV, &i0, &i1);
	rCV = ks_conf_ck_conf(i0, i1, rPrecMm);
	rQV = ks_conf_qn_conf(i0, i1);
	rFV = sqrtf(rCV * rQV);/* 融合路F=√(C×Q)几何平均:保留"任一为0则F=0"的门槛语义,
							*比纯乘积柔和(双低时F抬升),单路中等偏差不再被过度惩罚
							*|wang.c+双置信度融合 2026.11.9.172950 */
	if (i_pstOut->o_iRtn_V != 0)/* 丢失:与老链上报口径一致 */
	{
		s_iOutV = -32768;
	}
	else
	{
		s_iOutV = ks_conf_blend(i_pstOut->o_iVResult, &s_iPrevOutV, &s_xHasPrevOutV, rFV);
		rConfLastRevV = rFV * 100.0f;/* 有效圈刷新记录变量 */
	}

	/* ⑤横向:同纵向(流选取按wStatusRef.9) */
	ks_conf_pick_streams(i_pstIn, i_pstStAxisParam, (BYTE)iFollowH, &i0, &i1);
	rCH = ks_conf_ck_conf(i0, i1, rPrecMm);
	rQH = ks_conf_qn_conf(i0, i1);
	rFH = sqrtf(rCH * rQH);/* 融合路F=√(C×Q),同纵向|wang.c+双置信度融合 2026.11.9.172950 */
	if (i_pstOut->o_iRtn_H != 0)
	{
		s_iOutH = -32768;
	}
	else
	{
		s_iOutH = ks_conf_blend(i_pstOut->o_iHResult, &s_iPrevOutH, &s_xHasPrevOutH, rFH);
		rConfLastRevH = rFH * 100.0f;
	}
}

INT KS_ConfErr_GetV(void)
{
	return s_iOutV;
}

INT KS_ConfErr_GetH(void)
{
	return s_iOutH;
}
