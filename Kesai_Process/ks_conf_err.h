/*
 * ks_conf_err.h
 *
 *  双置信度融合误差模块(老架构误差链路外挂,独立文件不改动calcerr.c)
 *  本模块只负责置信度计算与误差融合,不涉及飞点剔除(飞点开关xEnableNewFlyRemove
 *  归ks_fly_remove.h自持,与本模块无关)
 *  置信度公式移植自仿真平台qtversion置信度加权链(algorithm/kesai_calcArcErr_Firey/
 *  ks_calc_arc_err_opt.c):检测信号源换为老架构KS_CalcError_ARC输出的
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
 *  开关与变量为模块全局变量(调试器可改),485组态屏通讯挂点已备好暂未接入(寄存器6060/6061/
 *  6206,待加代码见KS_FB_VISU.c顶部"待加代码区",等确认后接入)|wang.c+双置信度融合 2026.11.9.165510|挂点改为待接入 2026.11.10.090134
 */

#ifndef KS_CONF_ERR_H_
#define KS_CONF_ERR_H_

#include "base.h"
#include "calcerr.h"

/* 运行时开关(默认值编译在ks_conf_err.c,485组态屏46059.03/.04下发,见KS_FB_VISU.c解析) */
extern BYTE xEnableConfErr;		/* 置信度观察开关(46059.03)|=1计算并显示置信度(6206)——误差链仍用
								 * 原每圈值,不接入融合结果|=0完全原行为(默认)
								 *|wang.c+双置信度融合 2026.11.9.165510
								 *|开关语义解耦:仅显示不接入误差链 2026.11.12 */
extern BYTE xSwitchWrEn;		/* 置信度接入误差链开关(46059.04)|仅在xEnableConfErr=1时有效:
								 * 再=1融合误差替换上报o_iVResult/o_iHResult|=0只显示不接入(默认)
								 * |开关语义解耦:双开才接入 2026.11.12 */

/* 参数输入变量 */
extern REAL rConfS50Mm;			/* CK一致度尺度s50输入@mm|默认0.08,s=s50时C=50%,写入后下一圈生效
								 *|wang.c+双置信度融合 2026.11.9.165510 */

/* 每圈置信度记录变量(0~100,有效圈刷新,丢失圈保持上次值便于观测) */
extern REAL rConfLastRevV;		/* 纵向本圈融合置信度F×100|wang.c+双置信度融合 2026.11.9.165510 */
extern REAL rConfLastRevH;		/* 横向本圈融合置信度F×100|wang.c+双置信度融合 2026.11.9.165510 */

/* 全状态复位:CK流历史+混合递推状态+记录变量清零(开关翻转的内部处理在Process里,无需外部调) */
void KS_ConfErr_Reset(void);

/* 每圈精采样处理:在KS_FB_ProSample中KS_CalcError_ARC调用之后调用(单圈一次)
 * 开关关闭时照常计算置信度并更新记录变量(供A/B观测),只有"用融合值替换上报误差"受开关控制 */
void KS_ConfErr_Process(StAxisParam* i_pstStAxisParam,			/* 轴参数(波门选择位/色序) */
						const StCalcParam_In* i_pstIn,			/* 老链计算输入(精度/排列/波门) */
						const StCalcParam_Out* i_pstOut);		/* 老链计算输出(detail结构/最终误差/返回码) */

/* 取融合误差(置信度开关关闭时调用无意义,KS_FB_ProSample按开关选择)
 * 丢失圈返回-32768与老链口径一致 */
INT KS_ConfErr_GetV(void);
INT KS_ConfErr_GetH(void);

#endif /* KS_CONF_ERR_H_ */
