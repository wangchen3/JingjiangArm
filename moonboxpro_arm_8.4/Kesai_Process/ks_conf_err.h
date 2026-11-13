/*
 * ks_conf_err.h
 *
 *  双置信度融合误差模块(8.4误差链路外挂,独立文件不改动calcerr.c)
 *  整体自老架构ARM(Slave_stm32_ARM,2026.11.12版)同名模块移植,算法逐行保留;
 *  本工程去运行期开关化:老架构的观察/接入双开关(xEnableConfErr/xSwitchWrEn,
 *  485屏46059 bit3/bit4下发)不迁移,改为编译期总开关KS_USE_CONF_ERR——宏=1时
 *  置信度直接接入误差链路(融合误差替换上报iVerror/iHerror,显示与误差计算不分家),
 *  宏=0时本模块完全不参与编译,回退原行为|Yang.zj+置信度迁移8.4 2026.11.13.112036
 *  本模块只负责置信度计算与误差融合,不涉及飞点剔除(飞点开关KS_USE_NEW_FLY_REMOVE
 *  归ks_fly_remove.h自持,与本模块无关)
 *  置信度公式移植自仿真平台qtversion置信度加权链(algorithm/kesai_calcArcErr_Firey/
 *  ks_calc_arc_err_opt.c):检测信号源换为KS_CalcError_ARC输出的
 *  StSignalParsingGroupDetail(三档阈值交点/门内滤波波形/有效幅值),逐圈计算:
 *    ① CK置信度 C=2^-(s_mm/s50)² —— 三档交点跨圈位移一致性(s为三档位移样本标准差,
 *       两标记取max短板决定),s50为一致度尺度mm(s=s50时C=50%)
 *    ② Qn置信度 Qn=100·erf(τ/(√2·jp)) —— 宽度测量随机精度分数(门内标记两侧空白区
 *       分块去趋势+MAD估σ,jp=2σ·si/m_min,τ默认5丝);MAD/σ下限=1个量化码
 *       (KS_CONF_QN_QUANT=4LSB,治本2026.11.12:防"钉零+量化毛刺"噪声下整窗误拒);
 *       其余"评不了"分支保持无效语义(-1→F=0→冻结)
 *    ③ 融合 F=√(C×Qn/100)几何平均,递推混合 out_k = F·E_k + (1-F)·out_{k-1}
 *       (E_k为老链当圈最终误差o_iVResult/o_iHResult,哨兵圈保持上一圈不更新历史;
 *       F保留"任一置信度为0则F=0"的门槛语义,比纯乘积柔和|wang.c+ 2026.11.9.172950)
 *  与仿真平台的有意差异:信号源为老链detail结构(非opt检测链)、E_k为N幅平均后口径
 *  (混合发生在calcerr.c之外)、混合基准为当圈上报值——数值不保证与仿真平台逐位一致
 *  |wang.c+双置信度融合 2026.11.9.165510
 */

#ifndef KS_CONF_ERR_H_
#define KS_CONF_ERR_H_

#include "base.h"
#include "calcerr.h"

/* 置信度融合误差总开关(编译期,本工程不设运行期开关/观察态)
 * 1 = 置信度融合误差直接接入误差链路:每圈KS_CalcError_ARC之后计算置信度,
 *     上报iVerror/iHerror替换为融合误差KS_ConfErr_GetV/H(主站上报/报警判断/
 *     人机显示平均同步吃到融合值,不分家)
 * 0 = 完全回退原行为(本模块不参与编译),恢复本宏重新编译即可
 * 设计与挂接|Yang.zj+置信度迁移8.4 2026.11.13.112036 */
#define KS_USE_CONF_ERR		1

/* 参数输入变量(无485下发,调试器可改,写入后下一圈生效) */
extern REAL rConfS50Mm;			/* CK一致度尺度s50输入@mm|默认0.08,s=s50时C=50%
								 *|wang.c+双置信度融合 2026.11.9.165510 */

/* 每圈置信度记录变量(0~100,有效圈刷新,丢失圈保持上次值便于观测;仅供调试器观察,
 * 不做485显示挂点——本工程显示与误差链路不分家|Yang.zj+置信度迁移8.4 2026.11.13.112036) */
extern REAL rConfLastRevV;		/* 纵向本圈融合置信度F×100|wang.c+双置信度融合 2026.11.9.165510 */
extern REAL rConfLastRevH;		/* 横向本圈融合置信度F×100|wang.c+双置信度融合 2026.11.9.165510 */

/* 全状态复位:CK流历史+混合递推状态+记录变量清零(工况变化检测在Process内自持,
 * 外部无需调用,公开备用) */
void KS_ConfErr_Reset(void);

/* 每圈精采样处理:在KS_FB_ProSample中KS_CalcError_ARC调用之后调用(单圈一次) */
void KS_ConfErr_Process(StAxisParam* i_pstStAxisParam,			/* 轴参数(波门选择位/色序) */
						const StCalcParam_In* i_pstIn,			/* 老链计算输入(精度/排列/波门) */
						const StCalcParam_Out* i_pstOut);		/* 老链计算输出(detail结构/最终误差/返回码) */

/* 取融合误差(KS_FB_ProSample在KS_USE_CONF_ERR=1时用于替换上报)
 * 丢失圈返回-32768与老链口径一致 */
INT KS_ConfErr_GetV(void);
INT KS_ConfErr_GetH(void);

#endif /* KS_CONF_ERR_H_ */
