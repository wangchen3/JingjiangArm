/*
 * ks_fly_remove.c
 *
 *  新飞点剔除(在线严格因果版): 飞点剔除仿真.py FlyRemover 的C移植
 *  设计要点(详见 飞点剔除_算法说明.md):
 *    1.严格因果:第i帧输出只依赖第1..i帧,无任何回溯改写,可直接用于实时;
 *    2.量纲无关免调参:所有门限都是"σ的倍数"或"帧数",代码内无带单位的绝对值;
 *    3.参照=可信历史(只收真实测量)的Theil-Sen趋势带:斜坡上外推即预测(新息≈0),
 *      中位数类估计飞点拉不动;
 *    4.σ=可信值相邻差分的MAD(1.4826/√2归一),差分天然消掉趋势与电平;
 *    5.双门槛迟滞:外门槛Kσ(强异常),回归门槛0.5Kσ(回到原趋势),两门之间暂缓;
 *    6.阶跃确认只重建参照不动锁存:飞点串无论多宽都污染不了输出,真阶跃约3~4帧跟上;
 *    7.飞点/暂缓替换值=趋势外推P(双守卫:账本≥3点且非振荡,斜坡上比锁存新鲜,
 *      实测替换误差0.99σ→0.61σ),用P时同步刷锁存→输出序列连续无台阶;
 *      守卫不过或阶跃(确认)/好(观察)/观察失败帧一律锁存(防等值串透传);
 *    8.振荡自愈:门过紧/信号大幅摆动时用含被拒帧的全幅MAD把门撑回,防"越剔越紧"死亡螺旋;
 *    9.替换值不回灌任何统计(历史只信真实测量);
 *    10.量化容忍β门限法(2026.10.28与主站PLC/Python收敛):外门槛T_out=max(K×σ,β×q),
 *      q=数据分辨率(近16个非零相邻差分的最小值,样本≥2),β=KS_FLY_QUANTUM_TOL(10,可调,
 *      0关闭)——量化/整数数据差分可为0,纯Kσ门限塌缩到≈0→台阶式漂移被判飞点爬行
 *      (实机3U整数丝数据误报59→9帧);σ与暖机σ不垫q(只垫门槛);连续数据q≈0不起作用;
 *    11.观察帧有界接管:好(观察)输出=latch+clamp(x−latch,±实际外门槛)——幅度≤5σ的
 *      真阶跃观察帧即全额跟上(阶跃响应3~4帧→2~3帧),宽3等值串泄漏封顶一个外门槛;
 *      锁存/历史/σ/防串机制全部不动;
 *    12.水平带(方案A):历史≤2点时带退化为水平中位、P不外推——仅2点时Theil-Sen只有
 *      1对斜率零鲁棒性,尖峰串污染斜率外推会把带拉飞(实测-109漏剔根因);开关KS_FLY_FLAT_BAND;
 *    13.三点连续趋势确认:候选链(飞点/暂缓/阶跃帧原始输入,≤2点)+当前帧严格同向连续且
 *      残差≤min(链首T_start,当前T_out)时,三点实测重建历史,输出/锁存接管到本帧原值——
 *      开机压辊/调整期快速连续变化不再被反复拦截;等值串零变化不满足同向仍走原逻辑;
 *      丢失帧由调用侧Invalid接口打断候选链;开关KS_FLY_TREND_CONFIRM。
 *    14.升降速容忍(第四支路):T_out≥γ_v×|近5拍最大Δv|(γ_v=25);匀速Δv=0自动失效;
 *      Δv由调用侧NoteDv接口入窗(Feed后调用防反灌)|Yang.zj+ 2026.11.06.112637。
 *  本模块为纯计算模块,不依赖HAL,仅主循环调用(每版辊一圈一帧,帧间隔50~500ms,
 *  单帧运算为≤36元中位数级别,耗时数十微秒)|Yang.zj+用于新飞点检测 2026.10.24.103254
 *  2026.10.27:替换值升级为外推P+刷锁存,同步自 飞点剔除仿真.py(晚二/晚三)|Yang.zj+ 2026.10.27.140301
 *  2026.10.27:量化σ塌缩修复(数据分辨率quantum兜底),同步自仿真版(晚四)|Yang.zj+ 2026.10.27.175616
 *  2026.10.28:收敛β门限法(σ垫q改为门槛垫底T_out=max(Kσ,βq))+观察帧有界接管,
 *  同步自仿真版/主站v1.4|Yang.zj+ 2026.10.28.153701
 *  2026.10.29:水平带+三点连续趋势确认+丢失打断候选链接口,同步自仿真版/主站v1.5|Yang.zj+ 2026.10.29.161307
 *  2026.11.06:升降速容忍(第四支路γ_v=25)同步自仿真版;稳定检查已评估后撤销(压辊后
 *  输出-32768帧过多,得不偿失);调整容忍(第三支路)因ARM拿不到调整量/解耦量暂不同步
 *  |Yang.zj+ 2026.11.06.150209
 *  2026.11.09:连续丢失≥KS_FLY_LOST_RESET_N(4)拍自动全复位(Invalid内计数,长丢失段后
 *  误差电平/工况已变,旧参照不可信,恢复帧从首帧重新暖机,同步自仿真版LOST_RESET_N)
 *  +启动期不配对被丢弃帧的差分不入分辨率窗(仿真run_online只feed实际喂入的帧,被拒
 *  配对帧不feed;同步该口径,狂跳杂波对的失败差分不占分辨率窗)。另:复位恰落在配对
 *  中途时本模块全清配对暂存重新配对——仿真run_online的_pair_buf跨复位存活属工具层
 *  疏漏(违反"复位后前2帧须差≤100丝"规格),ARM按该规格取正确语义,属有意差异
 *  |Yang.zj+ 2026.11.09.160000
 */

#include <string.h>
#include <math.h>
#include "ks_fly_remove.h"

/* 运行时飞点开关定义(声明见ks_fly_remove.h,与置信度模块无关):
 * 默认1=新剔除,与宏KS_USE_NEW_FLY_REMOVE=1现状行为一致|wang.c+双置信度融合 2026.11.9.171753
 * |修正初始化笔误0→1(原与上行注释"默认1"矛盾);开关独立后此值为485通讯建立前的默认 2026.11.12 */
uint8_t xEnableNewFlyRemove = 1;

/* ---------------- 参数(默认值即泛用值,一般不改) ---------------- */
/* 对应 飞点剔除.py 头部常量|Yang.zj+用于新飞点检测 2026.10.24.103254 */
#define KS_FLY_TRUST_WIN	9	/* 趋势窗:Theil-Sen用最近N个可信点 */
#define KS_FLY_NOISE_WIN	31	/* 噪声窗:差分σ用最近N个可信值 */
#define KS_FLY_DIFF_MIN		8	/* 差分数不足N不用MAD(3~7个时统计涨落±50%会引发越剔越紧螺旋) */
#define KS_FLY_SIG_PROV		2.0f	/* 暖机σ倍数:σ=倍数×已有差分的中位绝对值(尺度自举,量纲无关) */
#define KS_FLY_K			5.0f	/* 外门槛倍数:T_out=K×σ(调小如3更严格,能抓更浅的飞点但边界判定变多) */
#define KS_FLY_RET_FRAC		0.5f	/* 回归门槛=该比例×外门槛(文档5σ/2.5σ) */
#define KS_FLY_STEP_CONFIRM	2	/* 阶跃确认:连续强超门满N帧判阶跃 */
#define KS_FLY_QUAR_N		1	/* 阶跃确认后的观察帧数(过门进历史但不接管输出/锁存) */
#define KS_FLY_HOLD_MAX		3	/* 迟滞带内暂缓上限:连续暂缓满N帧按正常值吸收(暂缓≠剔除) */
#define KS_FLY_OSC_WIN		64	/* 振荡自愈:统计近N帧"判非好"占比 */
#define KS_FLY_OSC_IN		0.25f	/* 振荡模式进入门限:占比>25% */
#define KS_FLY_OSC_OUT		0.10f	/* 振荡模式退出门限:占比<10% */
#define KS_FLY_MAD_C		1.4826f	/* MAD→正态标准差一致性系数 */
#define KS_FLY_SQRT2		1.414213562f	/* √2:Var(差分)=2σ²的归一 */
#define KS_FLY_EPS			1e-12f	/* σ=0保护(完全恒定信号上任一偏差即异常,属正确行为) */
#define KS_FLY_QUANTUM_TOL	10.0f	/* 量化容忍倍数β:外门槛T_out=max(K×σ,β×q),q=数据分辨率(quantum);
									 * 垫门槛不垫σ;置0完全关闭量化容忍(回纯Kσ门槛);只在β>K时量化侧实际起作用;
									 * 与主站KS_FLY_QUANTUM_TOL/Python QUANTUM_TOL同值|Yang.zj+ 2026.10.28.153701 */
#define KS_FLY_TREND_CONFIRM	1	/* 三点连续趋势确认开关(1=开,同步自主站v1.5/仿真版):候选链2点+当前帧
									 * 严格同向连续且残差<=冻结门槛min(链首T_start,当前T_out)时,三点实测重建历史,
									 * 输出/锁存接管到本帧原值(开机压辊/调整期快速跟随);置0回退(=β收敛版+水平带)
									 * |Yang.zj+ 2026.10.29.161307 */
#define KS_FLY_FLAT_BAND		1	/* 水平带开关(1=开,同步自主站v1.5/仿真版):历史<=2点时带退化为水平中位
									 * (2点中位=均值),P同值不外推——仅2点时Theil-Sen只有1对斜率零鲁棒性,尖峰串
									 * 污染斜率外推会把带拉飞(实测张力数据-109漏剔根因);置0回退斜率带(老行为)
									 * |Yang.zj+ 2026.10.29.161307 */
#define KS_FLY_DV_TOL_EN		1	/* 升降速容忍开关:1=开(置0关闭第四支路) */
#define KS_FLY_DV_TOL_GAMMA	25.0f	/* 升降速容忍γ_v(第四支路): T_out再≥γ_v×|近DV_TOL_LAGS拍内最大Δv|(丝/Δv单位)
									 * 升降速期间张力瞬态使误差漂移;匀速时Δv=0支路自动失效;60文件收敛:8→25
									 * (ARM仅此支路,调整容忍第三支路因拿不到调整量/解耦量暂不同步)
									 * |Yang.zj+ 2026.11.06.112637 */
#define KS_FLY_DV_TOL_LAGS	5	/* 速度变化率滞后窗口(拍) */
#define KS_FLY_LOST_RESET_N	4	/* 连续丢失自动复位拍数:Invalid连续计数≥N拍全状态复位——长丢失段后
									 * 误差电平/工况已变,旧参照不可信,恢复帧从首帧重新暖机(与平均层
									 * ">3幅清平均"同阈值语义);同步自仿真版LOST_RESET_N|Yang.zj+ 2026.11.09.160000 */

/* ---------------- 剔除器状态(逐项对应 FlyRemover 类成员) ---------------- */
typedef struct{
	float		afHistVal[KS_FLY_NOISE_WIN];	/* 可信历史值:只有真实测量进(好点/观察帧),飞点/暂缓帧不进 */
	uint32_t	auiHistIdx[KS_FLY_NOISE_WIN];	/* 各历史点帧号(内部稠密计数,严格递增) */
	uint16_t	uwHistCnt;						/* 历史点数(≤31) */
	uint8_t		xStarted;						/* 启动态:前2帧无条件采信;阶跃重建历史≠重启,此标志不回退 */
	float		fLatch;							/* 锁存:最近好值,飞点替换用它;只被好帧更新 */
	uint8_t		xLatchValid;					/* 锁存有效性(上电后首个好帧前无效) */
	float		fSigma;							/* 差分MAD的σ估计;配合xSigmaValid使用 */
	uint8_t		xSigmaValid;					/* σ已估出标志(未估出时用暖机σ);阶跃只换电平不换噪声,σ跨阶跃沿用 */
	int16_t		iConsec;						/* 连续强超门计数(阶跃确认用) */
	int16_t		iQuar;							/* 阶跃确认后的观察帧余数 */
	int16_t		iHold;							/* 候选期暂缓计数 */
	uint8_t		abyJudged[KS_FLY_OSC_WIN];		/* 近64帧"是否判非好"记录(振荡自愈检测用) */
	uint16_t	uwJudgedCnt;
	float		afAllDev[16];					/* 近16帧|新值-带中心|(含被拒帧,振荡模式估幅用) */
	uint16_t	uwAllDevCnt;
	uint8_t		xOscOn;							/* 振荡模式开关(生效时门放宽到全幅MAD) */
	uint32_t	uiIdxNext;						/* 下一帧帧号(内部稠密递增,丢失帧不占号) */
	uint8_t		byLostRun;						/* 连续丢失计数(≥KS_FLY_LOST_RESET_N拍自动全复位;有效帧喂入时清零)
												 * |Yang.zj+ 2026.11.09.160000 */
	float		afQdq[16];						/* 近16个非零相邻差分,数据分辨率估计用|Yang.zj+ 2026.10.27.175616 */
	uint16_t	uwQdqCnt;						/* 分辨率差分窗内个数 */
	float		fPVal;							/* 上一有效输入值(算分辨率用,含被拒帧——分辨率是数据属性) */
	uint32_t	uiPIdx;							/* 上一有效输入帧号(与uiIdx比邻判定相邻帧) */
	uint8_t		xPValValid;						/* fPVal/uiPIdx有效性;本块5个成员均属量化σ塌缩修复|Yang.zj+ 2026.10.27.175616 */
	float		afCandVal[2];					/* 候选链原始点值(飞点/暂缓/阶跃帧的原始输入,≤2点滑窗)|Yang.zj+ 2026.10.29.161307 */
	uint32_t	auiCandIdx[2];					/* 候选链各点帧号(三点趋势确认判连续用) */
	uint8_t		byCandCnt;						/* 候选链点数(0~2) */
	float		fCandTStart;					/* 链首时刻的实际外门槛(冻结,滑窗不重置,丢失/清空归零) */
	float		afDvRing[KS_FLY_DV_TOL_LAGS];	/* 近DV_TOL_LAGS拍Δv滑窗(第四支路用)|Yang.zj+ 2026.11.06.112637 */
	uint8_t		byDvCnt;						/* Δv窗内个数 */
}KsFlyRemover;

/* ---------------- 中位数运算的暂存区(仅主循环单线程调用,非重入) ----------------
 * 合计约364字节BSS,避免占用任务栈|Yang.zj+用于新飞点检测 2026.10.24.103254 */
static float s_afSlope[KS_FLY_TRUST_WIN * (KS_FLY_TRUST_WIN - 1) / 2];	/* Theil-Sen两两斜率(9点36对) */
static float s_afExt[KS_FLY_TRUST_WIN];		/* 趋势带:外推值/水平值的中位数暂存 */
static float s_afDiff[KS_FLY_NOISE_WIN - 1];	/* 可信历史相邻差分(≤30个) */
static float s_afDev[16];					/* 全幅偏差中位数暂存(振荡模式) */

/* 纵向/横向各一个实例,上电零初始化即为复位态|Yang.zj+用于新飞点检测 2026.10.24.103254 */
static KsFlyRemover s_stFlyV;
static KsFlyRemover s_stFlyH;

/* ---------------- 内部工具 ---------------- */

/* 中位数:与Python statistics.median语义一致——奇数取正中,偶数取中间两值的平均
 * (插入排序会打乱入参缓冲区,窗口≤36,代价可忽略)|Yang.zj+用于新飞点检测 2026.10.24.103254 */
static float ks_fly_median(float *afBuf, int iCnt)
{
	int i, j;
	float fTmp;

	if (iCnt <= 0)
		return 0.0f;
	for (i = 1; i < iCnt; i++)		/* 插入排序 */
	{
		fTmp = afBuf[i];
		for (j = i - 1; j >= 0 && afBuf[j] > fTmp; j--)
			afBuf[j + 1] = afBuf[j];
		afBuf[j + 1] = fTmp;
	}
	if (iCnt & 1)
		return afBuf[iCnt / 2];
	return (afBuf[iCnt / 2 - 1] + afBuf[iCnt / 2]) * 0.5f;
}

/* 数据分辨率 = 最近16个非零相邻差分的最小值(样本≥2才有效,否则返回0)
 * 量化/整数数据上相邻差分大量为0 → 差分MAD的σ塌缩到≈0 → 门限≈0 →
 * 台阶式漂移(每步只挪1个最小单位)被"飞点→阶跃确认"连续误判爬行
 * (实机3U整数丝数据复现:101有效帧误报59帧);σ以分辨率兜底后量化数据
 * 门限恒≥5×分辨率,台阶漂移交回趋势带原生跟随(误报59→9);
 * 取min对大差分(飞点)免疫,16格滑动窗可随数据变粗/变细自适应;
 * 连续数据上quantum≈0,兜底不起作用,行为不变|Yang.zj+ 2026.10.27.175616 */
static float ks_fly_quantum(const KsFlyRemover *pst)
{
	uint16_t i;
	float fMin;

	if (pst->uwQdqCnt < 2)
		return 0.0f;
	fMin = pst->afQdq[0];
	for (i = 1; i < pst->uwQdqCnt; i++)
	{
		if (pst->afQdq[i] < fMin)
			fMin = pst->afQdq[i];
	}
	return fMin;
}

/* 趋势带:取可信历史最近≤KS_FLY_TRUST_WIN个点→允许带[*o_pfA,*o_pfB]与外推P
 * v=两两斜率中位数(Theil-Sen,个别坏点影响不了它)
 * P=各点按v外推到当前帧的中位数(外推预测),L=这N个点的中位水平
 * 允许带=[min(P,L),max(P,L)]:斜坡上外推即预测(新息≈0,斜坡不需要特殊处理),
 * 真实突跳后的弯曲回落值通常落在P与L之间,不会被误判
 * P另作替换值用(见ks_fly_repl)|Yang.zj+ 2026.10.27.140301 */
static void ks_fly_band(const KsFlyRemover *pst, uint32_t uiIdx, float *o_pfA, float *o_pfB, float *o_pfP)
{
	int i, j, n, m;
	float fV, fP, fL;
	const float *pfV;
	const uint32_t *puI;

	n = (pst->uwHistCnt < KS_FLY_TRUST_WIN) ? pst->uwHistCnt : KS_FLY_TRUST_WIN;
	pfV = &pst->afHistVal[pst->uwHistCnt - n];	/* 最近n个可信点在数组末尾 */
	puI = &pst->auiHistIdx[pst->uwHistCnt - n];
	if (n <= 1)	/* 阶跃重建后的单点历史:带退化为该点 */
	{
		*o_pfA = *o_pfB = *o_pfP = pfV[0];
		return;
	}
#if KS_FLY_FLAT_BAND
	if (n <= 2)	/* 水平带(方案A,同步自主站v1.5/仿真版):仅2点时Theil-Sen只有1对斜率、零鲁棒性,
	 * 而这两点常为阶跃重建点+观察帧(多为被尖峰串搅过的过渡值),污染斜率的外推会把带拉飞
	 * (实测张力数据:双尖峰骗过阶跃确认后两点定出陡斜率,使后续-109距带仅21被放行;
	 * 调K/β无效,属带位置问题);2点用水平中位带(中位=均值),P同值不外推;
	 * 代价:真阶跃后快速连续漂移会先被拒1帧,由三点趋势确认接管(两开关需同开)
	 * |Yang.zj+ 2026.10.29.161307 */
	{
		fL = (pfV[0] + pfV[1]) * 0.5f;
		*o_pfA = fL;
		*o_pfB = fL;
		*o_pfP = fL;
		return;
	}
#endif
	m = 0;
	for (i = 0; i < n; i++)
	{
		for (j = i + 1; j < n; j++)
		{
			uint32_t uiDt = puI[j] - puI[i];	/* 帧号严格递增,dt>0 */
			if (uiDt > 0)
			{
				/* 帧号差先在整数域算好再转float,避免大帧号下float相对精度损失|Yang.zj+用于新飞点检测 2026.10.24.103254 */
				s_afSlope[m++] = (pfV[j] - pfV[i]) / (float)(int32_t)uiDt;
			}
		}
	}
	fV = (m > 0) ? ks_fly_median(s_afSlope, m) : 0.0f;
	for (i = 0; i < n; i++)
		s_afExt[i] = pfV[i] + fV * (float)(int32_t)(uiIdx - puI[i]);
	fP = ks_fly_median(s_afExt, n);		/* 外推预测P */
	for (i = 0; i < n; i++)
		s_afExt[i] = pfV[i];
	fL = ks_fly_median(s_afExt, n);		/* 近期水平L */
	if (fP < fL)
	{
		*o_pfA = fP;
		*o_pfB = fL;
	}
	else
	{
		*o_pfA = fL;
		*o_pfB = fP;
	}
	*o_pfP = fP;
}

/* 值进可信历史并刷新差分σ(只有真实测量进历史——飞点/暂缓帧不进)
 * 满窗丢最旧;差分攒满KS_FLY_DIFF_MIN个才启用MAD估计σ(σ=1.4826/√2×MAD,
 * 对σ的下限保护防恒定信号除零;σ不再垫q——量化容忍改垫门槛,见步骤3的β门限法)
 * |Yang.zj+用于新飞点检测 2026.10.24.103254|Yang.zj+ 2026.10.28.153701 */
static void ks_fly_push(KsFlyRemover *pst, uint32_t uiIdx, float fX)
{
	int i, m;
	float fMed;

	if (pst->uwHistCnt >= KS_FLY_NOISE_WIN)
	{
		memmove(pst->afHistVal, &pst->afHistVal[1], (KS_FLY_NOISE_WIN - 1) * sizeof(float));
		memmove(pst->auiHistIdx, &pst->auiHistIdx[1], (KS_FLY_NOISE_WIN - 1) * sizeof(uint32_t));
		pst->uwHistCnt = KS_FLY_NOISE_WIN - 1;
	}
	pst->afHistVal[pst->uwHistCnt] = fX;
	pst->auiHistIdx[pst->uwHistCnt] = uiIdx;
	pst->uwHistCnt++;

	m = pst->uwHistCnt - 1;		/* 相邻差分个数 */
	if (m >= KS_FLY_DIFF_MIN)
	{
		for (i = 0; i < m; i++)
			s_afDiff[i] = pst->afHistVal[i + 1] - pst->afHistVal[i];
		fMed = ks_fly_median(s_afDiff, m);
		for (i = 0; i < m; i++)
			s_afDiff[i] = fabsf(s_afDiff[i] - fMed);
		fMed = (KS_FLY_MAD_C / KS_FLY_SQRT2) * ks_fly_median(s_afDiff, m);
		pst->fSigma = (fMed > KS_FLY_EPS) ? fMed : KS_FLY_EPS;	/* 不垫q(收敛β门限法)|Yang.zj+ 2026.10.28.153701 */
		pst->xSigmaValid = 1;
	}
}

/* 好点处理:进可信历史,更新锁存,原值输出,流程计数器清零|Yang.zj+用于新飞点检测 2026.10.24.103254 */
static float ks_fly_good(KsFlyRemover *pst, uint32_t uiIdx, float fX)
{
	ks_fly_push(pst, uiIdx, fX);
	pst->fLatch = fX;
	pst->xLatchValid = 1;
	pst->iConsec = 0;
	pst->iHold = 0;
	return fX;
}

/* 飞点/暂缓的替换值(严格对应 仿真版 _repl):
 * 趋势可信(账本≥3点且未进振荡模式)时用外推P——按趋势推算的当前估计,斜坡上比
 * 锁存新鲜(实测替换误差0.99σ→0.61σ);否则退回锁存——账本刚被阶跃重建(仅1~2点)
 * 时P恰为可疑新电平,用了会把等值串透传出去;振荡模式时线性外推失真,也退回锁存。
 * 用P时同步刷锁存:随后的阶跃(确认)/好(观察)帧输出的还是锁存,但咬住的是这条
 * 趋势线而非回跳到更旧的测量值→输出序列连续无台阶;防线不变——观察帧仍不接管
 * 新电平,P只会来自成熟可信账本,等值串防护不受影响。
 * 替换值一律不回灌(历史/σ不动)|Yang.zj+ 2026.10.27.140301 */
static float ks_fly_repl(KsFlyRemover *pst, float fP)
{
	if (pst->uwHistCnt >= 3 && pst->xOscOn == 0)
	{
		pst->fLatch = fP;
		pst->xLatchValid = 1;
		return fP;
	}
	return pst->fLatch;
}

/* 帧末记账1:本帧"是否判非好"记入64帧窗(振荡自愈检测用)|Yang.zj+用于新飞点检测 2026.10.24.103254 */
static void ks_fly_note_judged(KsFlyRemover *pst, uint8_t xNotGood)
{
	if (pst->uwJudgedCnt >= KS_FLY_OSC_WIN)
	{
		memmove(pst->abyJudged, &pst->abyJudged[1], KS_FLY_OSC_WIN - 1);
		pst->uwJudgedCnt = KS_FLY_OSC_WIN - 1;
	}
	pst->abyJudged[pst->uwJudgedCnt++] = xNotGood;
}

/* 帧末记账2:|新值-带中心|记入16帧窗(振荡模式估幅用,含被拒帧)|Yang.zj+用于新飞点检测 2026.10.24.103254 */
static void ks_fly_note_alldev(KsFlyRemover *pst, float fDev)
{
	if (pst->uwAllDevCnt >= 16)
	{
		memmove(pst->afAllDev, &pst->afAllDev[1], 15 * sizeof(float));
		pst->uwAllDevCnt = 15;
	}
	pst->afAllDev[pst->uwAllDevCnt++] = fDev;
}

/* 数据分辨率差分入窗(16格滑窗丢最旧);调用时机=本帧确定被喂入(见feed步骤0的
 * 入窗口径,与仿真run_online只feed实际喂入帧一致)|Yang.zj+ 2026.10.27.175616|Yang.zj+ 2026.11.09.160000 */
static void ks_fly_note_qdq(KsFlyRemover *pst, float fDd)
{
	if (pst->uwQdqCnt >= 16)
	{
		memmove(pst->afQdq, &pst->afQdq[1], 15 * sizeof(float));
		pst->uwQdqCnt = 15;
	}
	pst->afQdq[pst->uwQdqCnt++] = fDd;
}

/* ---------------- 核心:逐帧处理(严格对应 FlyRemover.feed) ----------------
 * 喂入一帧原始误差,返回剔除后输出值(好点原值;飞点/暂缓为替换值——成熟账本且
 * 非振荡时为趋势外推P并同步刷锁存,否则锁存值)
 * 丢失帧(-32768)不要喂进来:调用侧跳过(状态自然保持),由外层原样上报-32768——
 * 丢失是"没测到",没有测量可言,不用锁存占位|Yang.zj+ 2026.10.27.140301 */
static float ks_fly_feed(KsFlyRemover *pst, float fX, uint8_t *o_byJudge)
{
	uint32_t uiIdx;
	float fA, fB, fD, fDd, fSigma, fTOut, fTRet, fOut, fRatio, fTmp, fP, fQ;
	uint8_t byJudge = KS_FLY_JUDGE_GOOD;
	uint8_t xDdq;
	int i, m, iSum;

	uiIdx = pst->uiIdxNext++;
	pst->byLostRun = 0;		/* 本帧为有效帧:连续丢失计数清零|Yang.zj+ 2026.11.09.160000 */

	/* 0.数据分辨率记账(量化σ塌缩修复):相邻帧(idx差1)的非零差分,入16格滑动窗,
	 * 含被拒帧——分辨率是数据属性不是噪声属性;丢失帧不喂入自然不占号。
	 * 差分先暂存,待本帧确定被"喂入"才入窗:已启动帧无条件入(下方),启动配对帧
	 * 仅配对成功时入——不配对被丢弃的帧不喂入,与仿真run_online只feed实际喂入帧
	 * 的口径一致(狂跳杂波对的失败差分不占分辨率窗)|Yang.zj+ 2026.10.27.175616|Yang.zj+ 2026.11.09.160000 */
	fDd = 0.0f;
	xDdq = 0;
	if (pst->xPValValid != 0 && uiIdx == pst->uiPIdx + 1u)
	{
		fDd = fabsf(fX - pst->fPVal);
		if (fDd > 0.0f)
			xDdq = 1;
	}

	if (pst->xStarted == 0)
	{
		/* 启动期:首帧对一致性检查——前2帧须差≤100丝才一起采信;
		 * 狂跳杂波(|Δ|>100/帧)进不了参照,平滑偏高型(|Δ|≈5~40)正常通过;
		 * 攒对期间暂存帧1,帧2到来时判定:配对成功→两帧一起push+输出帧2;
		 * 不配对→丢帧1,帧2变新帧1,等下一帧|Yang.zj+ 2026.11.06.163802 */
		if (pst->xLatchValid == 0)
		{
			if (xDdq != 0)		/* 此态pval必无效,防御性入窗 */
				ks_fly_note_qdq(pst, fDd);
			pst->fPVal = fX;
			pst->uiPIdx = uiIdx;
			pst->xPValValid = 1;
			pst->fLatch = fX;		/* 暂存帧1(复用锁存位) */
			pst->xLatchValid = 1;
			if (o_byJudge)
				*o_byJudge = KS_FLY_JUDGE_FIRST;
			return fX;
		}
		else
		{
			if (fabsf(fX - pst->fLatch) <= 100.0f)
			{
				/* 配对成功:帧1和帧2一起进历史(两帧此刻被喂入,帧2差分|帧2-帧1|入分辨率窗) */
				if (xDdq != 0)
					ks_fly_note_qdq(pst, fDd);
				pst->fPVal = fX;
				pst->uiPIdx = uiIdx;
				pst->xPValValid = 1;
				ks_fly_push(pst, uiIdx - 1, pst->fLatch);
				ks_fly_push(pst, uiIdx, fX);
				pst->fLatch = fX;		/* 锁存=帧2 */
				pst->xStarted = 1;
				if (o_byJudge)
					*o_byJudge = KS_FLY_JUDGE_FIRST;
				return fX;
			}
			else
			{
				/* 不配对:丢帧1,帧2变新帧1;本帧未被喂入,差分不入分辨率窗,
				 * 但pval仍跟随本帧(下帧差分=|下帧-本帧|,与仿真配对成功时
				 * 双帧feed的差分口径一致)|Yang.zj+ 2026.11.09.160000 */
				pst->fPVal = fX;
				pst->uiPIdx = uiIdx;
				pst->xPValValid = 1;
				pst->fLatch = fX;
				if (o_byJudge)
					*o_byJudge = KS_FLY_JUDGE_FIRST;
				return fX;
			}
		}
	}

	/* 已启动:本帧无条件喂入(含判飞点/暂缓/阶跃的帧——真实测量都进分辨率窗) */
	if (xDdq != 0)
		ks_fly_note_qdq(pst, fDd);
	pst->fPVal = fX;
	pst->uiPIdx = uiIdx;
	pst->xPValValid = 1;

	/* 1.趋势带参照,量出带外距离d(带内d=0),同时取外推P供替换用|Yang.zj+ 2026.10.27.140301 */
	ks_fly_band(pst, uiIdx, &fA, &fB, &fP);
	fD = 0.0f;
	if (fX < fA)
		fD = fA - fX;
	else if (fX > fB)
		fD = fX - fB;

	/* 2.振荡自愈:近64帧"判非好"占比>25%→进入振荡模式(门放宽);
	 * 已在振荡模式且占比<10%→退出。
	 * 存在意义:σ只由"过门的历史"估计,被拒帧进不了统计(选择偏差),门限偶然过紧时
	 * 会大量拒绝→σ只剩小残差→门更紧→死亡螺旋;振荡模式用含被拒帧的全幅偏差MAD把门
	 * 撑回信号摆动幅度,实现自愈|Yang.zj+用于新飞点检测 2026.10.24.103254 */
	fRatio = 0.0f;
	if (pst->uwJudgedCnt > 0)
	{
		for (i = 0, iSum = 0; i < pst->uwJudgedCnt; i++)
			iSum += pst->abyJudged[i];
		fRatio = (float)iSum / (float)pst->uwJudgedCnt;
	}
	if (pst->uwJudgedCnt >= KS_FLY_OSC_WIN)
	{
		if (pst->xOscOn == 0 && fRatio > KS_FLY_OSC_IN)
			pst->xOscOn = 1;
		else if (pst->xOscOn != 0 && fRatio < KS_FLY_OSC_OUT)
			pst->xOscOn = 0;
	}

	/* 3.确定σ与两道门槛(收敛β门限法,与主站PLC/Python统一)|Yang.zj+ 2026.10.28.153701:
	 * σ主估计=差分MAD(需攒满8个差分);暖机σ=SIG_PROV×已有差分的中位绝对值(量纲自举);
	 * 振荡模式生效时与全幅MAD取大——σ与暖机σ均不垫q(量化容忍改垫门槛,σ层垫底为冗余已删);
	 * 外门槛 T_out=max(K×σ, β×q):量化/整数数据差分可为0,纯Kσ门限会塌缩到≈0→台阶式漂移
	 * 被判飞点爬行;q只垫门槛,β=KS_FLY_QUANTUM_TOL(置0关闭),q不足2个非零差分时无效;
	 * 回归门槛联动为0.5×实际外门槛 */
	if (pst->xSigmaValid)
	{
		fSigma = pst->fSigma;
	}
	else
	{
		m = pst->uwHistCnt - 1;
		fTmp = 0.0f;
		if (m > 0)
		{
			for (i = 0; i < m; i++)
				s_afDiff[i] = fabsf(pst->afHistVal[i + 1] - pst->afHistVal[i]);
			fTmp = ks_fly_median(s_afDiff, m);
		}
		fSigma = KS_FLY_SIG_PROV * ((fTmp > KS_FLY_EPS) ? fTmp : KS_FLY_EPS);
	}
	if (pst->xOscOn != 0 && pst->uwAllDevCnt >= 8)
	{
		for (i = 0; i < pst->uwAllDevCnt; i++)
			s_afDev[i] = pst->afAllDev[i];
		fTmp = KS_FLY_MAD_C * ks_fly_median(s_afDev, pst->uwAllDevCnt);
		if (fTmp > fSigma)
			fSigma = fTmp;
	}
	fTOut = KS_FLY_K * fSigma;			/* 外门槛噪声侧Kσ */
	fQ = ks_fly_quantum(pst);
	fTmp = KS_FLY_QUANTUM_TOL * fQ;		/* 量化侧下限β×q(q无效时=0不起作用) */
	if (fTmp > fTOut)
		fTOut = fTmp;					/* T_out=max(Kσ, β×q) */
#if KS_FLY_DV_TOL_EN
	if (pst->byDvCnt > 0)
	{
		fTmp = 0.0f;					/* 第四支路:升降速容忍|Yang.zj+ 2026.11.06.112637 */
		for (i = 0; i < pst->byDvCnt; i++)
		{
			if (fabsf(pst->afDvRing[i]) > fTmp)
				fTmp = fabsf(pst->afDvRing[i]);
		}
		fTmp = KS_FLY_DV_TOL_GAMMA * fTmp;
		if (fTmp > fTOut)
			fTOut = fTmp;
	}
#endif
	fTRet = KS_FLY_RET_FRAC * fTOut;	/* 回归门槛联动为0.5×实际外门槛 */

#if KS_FLY_TREND_CONFIRM
	/* 3.5 三点连续趋势确认(同步自主站v1.5/仿真版):候选链满2点且原状态机仍处候选/观察期,
	 * 当前帧与候选帧号连续:两点线性外推P_c=2×x2−x1预测第三点,两次变化严格同向(零变化
	 * 不算,等值串仍走原逻辑)且残差<=冻结门槛min(链首T_start,当前T_out)时,三点实测直接
	 * 重建可信历史,输出/锁存立即接管到本帧原值,σ沿用——开机压辊/调整期真实误差快速连续
	 * 变化不再被反复"飞点-阶跃确认-观察失败"拦截|Yang.zj+ 2026.10.29.161307 */
	if (pst->byCandCnt == 2 && (pst->iConsec > 0 || pst->iQuar > 0)
		&& pst->auiCandIdx[1] == pst->auiCandIdx[0] + 1u
		&& uiIdx == pst->auiCandIdx[1] + 1u)
	{
		fTmp = pst->afCandVal[1] - pst->afCandVal[0];	/* d1=x2−x1 */
		fQ = fX - pst->afCandVal[1];						/* d2=x−x2 */
		if ((fTmp > 0.0f && fQ > 0.0f) || (fTmp < 0.0f && fQ < 0.0f))
		{
			fQ = 2.0f * pst->afCandVal[1] - pst->afCandVal[0];	/* P_c(≠趋势带P,仅判候选链能否成新趋势) */
			fTmp = pst->fCandTStart;
			if (fTOut < fTmp)
				fTmp = fTOut;								/* 冻结候选门槛=min(链首T_start,当前T_out) */
			if (fabsf(fX - fQ) <= fTmp)
			{
				pst->afHistVal[0] = pst->afCandVal[0];		/* 三点实测为新可信历史 */
				pst->auiHistIdx[0] = pst->auiCandIdx[0];
				pst->afHistVal[1] = pst->afCandVal[1];
				pst->auiHistIdx[1] = pst->auiCandIdx[1];
				pst->afHistVal[2] = fX;
				pst->auiHistIdx[2] = uiIdx;
				pst->uwHistCnt = 3;
				pst->iConsec = 0;
				pst->iHold = 0;
				pst->iQuar = 0;
				pst->fLatch = fX;							/* 锁存同步接管 */
				pst->xLatchValid = 1;
				pst->byCandCnt = 0;
				pst->fCandTStart = 0.0f;
				/* 本帧按好点计入振荡统计与全幅偏差,不走帧末公共记账,直接返回 */
				ks_fly_note_judged(pst, 0);
				ks_fly_note_alldev(pst, fabsf(fX - (fA + fB) * 0.5f));
				if (o_byJudge)
					*o_byJudge = KS_FLY_JUDGE_TREND;
				return fX;
			}
		}
	}
#endif

	/* 4.判定状态机(按优先级)|Yang.zj+用于新飞点检测 2026.10.24.103254 */
	if (pst->iQuar > 0)
	{
		/* (a)观察期(刚确认过阶跃):过门→值进历史(参照跟上新电平),锁存仍不动(防等值飞点串),
		 * 输出有界接管——向新值方向最多挪一个实际外门槛T_out(含量化容忍),幅度≤5σ的真
		 * 阶跃观察帧即全额跟上(阶跃响应3~4帧→2~3帧),宽3等值串泄漏封顶一个外门槛;
		 * 未过门→撤销观察记1次强超门(观察失败一律锁存,不用P)|Yang.zj+ 2026.10.28.153701 */
		if (fD <= fTOut)
		{
			pst->iQuar--;
			ks_fly_push(pst, uiIdx, fX);
			if (fX > pst->fLatch + fTOut)		/* 有界接管:out=latch+clamp(x−latch,±T_out) */
				fOut = pst->fLatch + fTOut;
			else if (fX < pst->fLatch - fTOut)
				fOut = pst->fLatch - fTOut;
			else
				fOut = fX;
			byJudge = KS_FLY_JUDGE_QUAR;
		}
		else
		{
			pst->iQuar = 0;
			pst->iConsec = 1;
			fOut = pst->fLatch;
			byJudge = KS_FLY_JUDGE_FAKE;
		}
	}
	else if (pst->iConsec > 0)
	{
		/* (b)候选期(已出现强异常):迟滞判回归/续强/暂缓 */
		if (fD <= fTRet)
		{
			fOut = ks_fly_good(pst, uiIdx, fX);	/* 明确回到原趋势:此前的强超门判定为飞点,本帧按好点 */
		}
		else if (fD > fTOut)
		{
			pst->iHold = 0;
			pst->iConsec++;
			if (pst->iConsec >= KS_FLY_STEP_CONFIRM)
			{
				/* 连续强超门满确认帧数→确认阶跃:历史重建为新电平单点,
				 * 锁存不动(输出仍旧电平),σ沿用(阶跃只换电平不换噪声) */
				pst->afHistVal[0] = fX;
				pst->auiHistIdx[0] = uiIdx;
				pst->uwHistCnt = 1;
				pst->iConsec = 0;
				pst->iQuar = KS_FLY_QUAR_N;
				fOut = pst->fLatch;
				byJudge = KS_FLY_JUDGE_STEP;
			}
			else
			{
				fOut = ks_fly_repl(pst, fP);	/* 飞点:替换值(成熟账本时为外推P)|Yang.zj+ 2026.10.27.140301 */
				byJudge = KS_FLY_JUDGE_FAKE;
			}
		}
		else
		{
			/* 迟滞带内:暂缓≠判死,不进历史;连续暂缓满KS_FLY_HOLD_MAX帧按正常值吸收 */
			pst->iHold++;
			if (pst->iHold >= KS_FLY_HOLD_MAX)
				fOut = ks_fly_good(pst, uiIdx, fX);
			else
			{
				fOut = ks_fly_repl(pst, fP);	/* 暂缓:替换值(成熟账本时为外推P)|Yang.zj+ 2026.10.27.140301 */
				byJudge = KS_FLY_JUDGE_HOLD;
			}
		}
	}
	else if (fD <= fTOut)
	{
		/* (c)正常态:带内即好,原值输出 */
		fOut = ks_fly_good(pst, uiIdx, fX);
	}
	else
	{
		/* 记1次强超门(下一帧来对质),本帧输出替换值 */
		pst->iConsec = 1;
		fOut = ks_fly_repl(pst, fP);	/* 飞点:替换值(成熟账本时为外推P)|Yang.zj+ 2026.10.27.140301 */
		byJudge = KS_FLY_JUDGE_FAKE;
	}

	/* 5.帧末记账(供步骤2的振荡检测;趋势确认帧已在3.5内按好点记账并早退)
	 * |Yang.zj+用于新飞点检测 2026.10.24.103254 */
	ks_fly_note_judged(pst, (byJudge != KS_FLY_JUDGE_GOOD && byJudge != KS_FLY_JUDGE_QUAR
		&& byJudge != KS_FLY_JUDGE_TREND) ? 1 : 0);
	ks_fly_note_alldev(pst, fabsf(fX - (fA + fB) * 0.5f));

	/* 6.候选链缓存维护(三点趋势确认用,同步自主站v1.5):飞点/暂缓/阶跃帧的原始输入进
	 * 缓存(≤2点,滑窗丢最旧但保留链首冻结门槛T_start);好/观察通过/回归/暂缓吸收/趋势
	 * 确认清空;丢失帧由调用侧KS_FlyRemove_Invalid_x打断|Yang.zj+ 2026.10.29.161307 */
	if (byJudge == KS_FLY_JUDGE_FAKE || byJudge == KS_FLY_JUDGE_HOLD || byJudge == KS_FLY_JUDGE_STEP)
	{
		if (pst->byCandCnt == 0)
			pst->fCandTStart = fTOut;	/* 缓存由空变非空:冻结此刻实际外门槛为链首T_start */
		if (pst->byCandCnt >= 2)
		{
			pst->afCandVal[0] = pst->afCandVal[1];
			pst->auiCandIdx[0] = pst->auiCandIdx[1];
			pst->byCandCnt = 1;
		}
		pst->afCandVal[pst->byCandCnt] = fX;
		pst->auiCandIdx[pst->byCandCnt] = uiIdx;
		pst->byCandCnt++;
	}
	else
	{
		pst->byCandCnt = 0;
		pst->fCandTStart = 0.0f;
	}

	if (o_byJudge)
		*o_byJudge = byJudge;
	return fOut;
}

/* 复位:清零全部状态(工况切换/信号源切换时调用,新工况的历史不可信)
 * |Yang.zj+用于新飞点检测 2026.10.24.103254 */
static void ks_fly_reset(KsFlyRemover *pst)
{
	memset(pst, 0, sizeof(KsFlyRemover));
}

/* ---------------- 对外接口:纵向/横向两个独立实例 ---------------- */

void KS_FlyRemove_Reset_V(void)
{
	ks_fly_reset(&s_stFlyV);
}

void KS_FlyRemove_Reset_H(void)
{
	ks_fly_reset(&s_stFlyH);
}

float KS_FlyRemove_Feed_V(float i_fErr, uint8_t *o_byJudge)
{
	static uint8_t xFlyPre = 0xFF;/* 上次开关值(翻转检测,本实例独立) */
	/* 开关任意沿翻转:本实例全复位(0→1重新暖机;1→0清状态防残留)
	 * |wang.c+双置信度融合 2026.11.9.171753 */
	if (xFlyPre != 0xFF && xFlyPre != xEnableNewFlyRemove)
	{
		ks_fly_reset(&s_stFlyV);
	}
	xFlyPre = xEnableNewFlyRemove;
	/* 开关旁路:=0时原值直通判GOOD,calcerr.c内Feed调用点不用改;
	 * KS_FB_ProSample按同一开关运行时切回旧二阶差分路径
	 * |wang.c+双置信度融合 2026.11.9.171753 */
	if (xEnableNewFlyRemove == 0)
	{
		if (o_byJudge != 0) *o_byJudge = KS_FLY_JUDGE_GOOD;
		return i_fErr;
	}
	return ks_fly_feed(&s_stFlyV, i_fErr, o_byJudge);
}

float KS_FlyRemove_Feed_H(float i_fErr, uint8_t *o_byJudge)
{
	static uint8_t xFlyPre = 0xFF;/* 上次开关值(翻转检测,本实例独立) */
	/* 开关任意沿翻转:本实例全复位|wang.c+双置信度融合 2026.11.9.171753 */
	if (xFlyPre != 0xFF && xFlyPre != xEnableNewFlyRemove)
	{
		ks_fly_reset(&s_stFlyH);
	}
	xFlyPre = xEnableNewFlyRemove;
	/* 开关旁路:同Feed_V|wang.c+双置信度融合 2026.11.9.171753 */
	if (xEnableNewFlyRemove == 0)
	{
		if (o_byJudge != 0) *o_byJudge = KS_FLY_JUDGE_GOOD;
		return i_fErr;
	}
	return ks_fly_feed(&s_stFlyH, i_fErr, o_byJudge);
}

/* 丢失帧通知:打断三点趋势确认候选链(不能跨越丢失确认趋势,与主站i_xLost分支一致);
 * 连续丢失≥KS_FLY_LOST_RESET_N(4)拍自动全状态复位——长丢失段后误差电平/工况已变,
 * 旧参照不可信,恢复帧从首帧重新暖机(复位同时清丢失计数与候选链;同步自仿真版
 * LOST_RESET_N)|Yang.zj+ 2026.10.29.161307|Yang.zj+ 2026.11.09.160000 */
void KS_FlyRemove_Invalid_V(void)
{
	if (++s_stFlyV.byLostRun >= KS_FLY_LOST_RESET_N)
	{
		ks_fly_reset(&s_stFlyV);
		return;
	}
	s_stFlyV.byCandCnt = 0;
	s_stFlyV.fCandTStart = 0.0f;
}

void KS_FlyRemove_Invalid_H(void)
{
	if (++s_stFlyH.byLostRun >= KS_FLY_LOST_RESET_N)
	{
		ks_fly_reset(&s_stFlyH);
		return;
	}
	s_stFlyH.byCandCnt = 0;
	s_stFlyH.fCandTStart = 0.0f;
}

/* 速度变化通知:Δv入5拍滑窗(第四支路用);须在Feed之后调用(防反灌,只含已过去的Δv)
 * |Yang.zj+ 2026.11.06.112637 */
void KS_FlyRemove_NoteDv_V(float i_fDv)
{
	if (s_stFlyV.byDvCnt >= KS_FLY_DV_TOL_LAGS)
	{
		memmove(s_stFlyV.afDvRing, &s_stFlyV.afDvRing[1],
				(KS_FLY_DV_TOL_LAGS - 1) * sizeof(float));
		s_stFlyV.byDvCnt = KS_FLY_DV_TOL_LAGS - 1;
	}
	s_stFlyV.afDvRing[s_stFlyV.byDvCnt] = i_fDv;
	s_stFlyV.byDvCnt++;
}

void KS_FlyRemove_NoteDv_H(float i_fDv)
{
	if (s_stFlyH.byDvCnt >= KS_FLY_DV_TOL_LAGS)
	{
		memmove(s_stFlyH.afDvRing, &s_stFlyH.afDvRing[1],
				(KS_FLY_DV_TOL_LAGS - 1) * sizeof(float));
		s_stFlyH.byDvCnt = KS_FLY_DV_TOL_LAGS - 1;
	}
	s_stFlyH.afDvRing[s_stFlyH.byDvCnt] = i_fDv;
	s_stFlyH.byDvCnt++;
}
