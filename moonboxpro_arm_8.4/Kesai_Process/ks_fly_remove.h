/*
 * ks_fly_remove.h
 *
 *  新飞点剔除(在线严格因果版)对外接口
 *  移植自上位机工具 飞点剔除仿真.py 的 FlyRemover(在线链式):
 *    可信历史(只收真实测量,飞点/暂缓帧不进) → Theil-Sen趋势带参照
 *    → 差分MAD噪声σ(量纲无关) → 双门槛迟滞(外门槛Kσ/回归门槛0.5Kσ)
 *    → 阶跃确认(连续强超门)+观察帧 → 飞点/暂缓替换=趋势外推P(双守卫:账本≥3点
 *    且非振荡;用P时同步刷锁存使输出连续无台阶),守卫不过退回锁存(上一好值/P)
 *    → 量化容忍β门限法:外门槛=max(Kσ,β×q)(β=KS_FLY_QUANTUM_TOL,10可调,0关闭,
 *    q=近16个非零相邻差分最小值,只垫门槛不垫σ);回归门槛=0.5×实际外门槛
 *    → 好(观察)输出=latch+clamp(x−latch,±实际外门槛)有界接管(锁存不动,防等值串)
 *  移植与挂接|Yang.zj+用于新飞点检测 2026.10.24.103254|替换值P同步自仿真版|Yang.zj+ 2026.10.27.140301|quantum兜底同步自仿真版晚四|Yang.zj+ 2026.10.27.175616|收敛β门限法+观察帧有界接管,同步自仿真版/主站v1.4|Yang.zj+ 2026.10.28.153701
 */

#ifndef KS_FLY_REMOVE_H_
#define KS_FLY_REMOVE_H_

#include <stdint.h>

/* 新旧飞点算法总开关
 * 1 = 新算法:calcerr.c内N幅平均之前逐帧剔除,飞点用锁存值替换(判定同时带回标志)
 * 0 = 回退旧算法:KS_FB_PickOutFakePoint_V/H二阶差分判断,仅置byStsV/H bit2标志不替换数值
 * 回退方法:本宏改成0重新编译即可,新旧两条调用路径都完整保留
 * 宏开关与回退设计|Yang.zj+用于新飞点检测 2026.10.24.103254 */
#define KS_USE_NEW_FLY_REMOVE	1

/* 逐帧判定码(对应 飞点剔除.py 的判定字符串,供上位观测/标志位使用) */
#define KS_FLY_JUDGE_FIRST	0	/* 首帧(启动期无条件采信) */
#define KS_FLY_JUDGE_GOOD	1	/* 好(原值输出,进可信历史) */
#define KS_FLY_JUDGE_QUAR	2	/* 好(观察):阶跃确认后过门,进历史但输出仍是旧电平 */
#define KS_FLY_JUDGE_FAKE	3	/* 飞点(锁存):输出锁存值,不进历史 */
#define KS_FLY_JUDGE_HOLD	4	/* 暂缓(锁存):迟滞带内未决,输出锁存值,不进历史 */
#define KS_FLY_JUDGE_STEP	5	/* 阶跃(确认):历史重建为新电平,输出仍是旧电平 */
#define KS_FLY_JUDGE_LOST	6	/* 丢失:输入为-32768时调用侧不feed本模块,由外层原样上报-32768
									 (丢失是"没测到",没有测量可言,不用锁存占位)|Yang.zj+用于新飞点检测 2026.10.24.112829 */
#define KS_FLY_JUDGE_TREND	7	/* 趋势确认:候选链2点+当前帧严格同向连续且残差<=冻结门槛min(链首T_start,
									 当前T_out)时,三点实测直接重建可信历史,输出/锁存接管到本帧原值(σ沿用)
									 ——开机压辊/调整期快速连续变化不再被反复"飞点-阶跃确认-观察失败"拦截
									 |Yang.zj+ 2026.10.29.161307 */

/* 纵向/横向各一个独立剔除器实例(内部静态,无动态内存)
 * 实例划分|Yang.zj+用于新飞点检测 2026.10.24.103254 */
void  KS_FlyRemove_Reset_V(void);	/* 复位纵向剔除器(工况切换时调用) */
void  KS_FlyRemove_Reset_H(void);	/* 复位横向剔除器 */
void  KS_FlyRemove_Invalid_V(void);	/* 纵向丢失帧通知:打断三点趋势确认候选链(不能跨越丢失确认趋势);
									 连续丢失≥4拍自动全复位(长丢失后旧参照不可信,恢复帧重新暖机,同步自
									 仿真版LOST_RESET_N=4)|Yang.zj+ 2026.10.29.161307 |Yang.zj+ 2026.11.09.161525 */
void  KS_FlyRemove_Invalid_H(void);	/* 横向丢失帧通知 */
void  KS_FlyRemove_NoteDv_V(float i_fDv);	/* 纵向速度变化通知:Δv=本拍速度-上一拍,入5拍滑窗供第四支路(升降速容忍);须在Feed之后调用|Yang.zj+ 2026.11.06.112637 */
void  KS_FlyRemove_NoteDv_H(float i_fDv);	/* 横向速度变化通知 */
float KS_FlyRemove_Feed_V(float i_fErr, uint8_t *o_byJudge);	/* 喂入一帧原始误差(丝),返回剔除后输出值 */
float KS_FlyRemove_Feed_H(float i_fErr, uint8_t *o_byJudge);

#endif /* KS_FLY_REMOVE_H_ */
