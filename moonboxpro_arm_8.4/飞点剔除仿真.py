#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
飞点剔除.py — 单列误差数据飞点剔除工具(GUI / CLI)
在线模式参照《飞点剔除优化_可信趋势与延迟确认》升级: 趋势带参照 + 差分σ + 双门槛迟滞

两种方式(结果文件"剔除后输出"列的含义不同):
  批式MAD  : 整段一起判 — 中值参照 + MAD稳健σ(1.4826×MAD), |x−中值|>K×σ̂ 迭代剔除
             飞点行留空(真剔除); 适合平稳误差段
  在线链式 : 逐帧严格因果(无回溯改写, 可直接用于实时) —
             可信历史(只收真实测量, 飞点/暂缓帧不进; 观察帧进历史供参照但不接管
             输出) → Theil-Sen趋势带参照 + 差分MAD噪声σ + 双门槛迟滞
             + 阶跃确认(连续强超门)与跳转后观察帧;
             飞点/暂缓替换 = 趋势外推P(账本≥3点且非振荡模式时, 斜坡上比锁存新鲜),
             账本未成熟(阶跃重建后1~2点)或振荡模式时退回锁存;
             阶跃(确认)/观察失败帧一律锁存;好(观察)输出有界接管=latch+clamp(x−latch,
             ±T_out)(2026-10-28,QUAR_TAKE_FRAC=0回退);
             适合含真实跳变/趋势的数据
             (替换值不回灌 —— 历史只信真实测量; 丢失帧原样输出-32768不占帧号)

数据: 单列误差值(首行中文表头自动跳过), -32768=丢失帧; 支持 .csv / .xlsx
      四列自动定位:优先扫描首行表头关键词——"跟踪前一色"→误差列、"压辊"→压辊列(任意沿
      触发全状态复位)、"解耦"→解耦量列(门槛第三支路T_out≥γ×|近5拍最大解耦量|/10)、
      "速度"→速度列(第四支路T_out≥γ_v×|近5拍最大Δv|,升降速张力瞬态容忍);
      表头无关键词时回退相邻列0/1/2/3(简测格式);结果文件在原始值后附压辊/解耦量对照列
      |Yang.zj+ 2026.11.03.091249|Yang.zj+ 2026.11.03.161533
用法: GUI = 直接运行(双击)选文件
      CLI = python 飞点剔除.py 数据文件 [列号(0起,默认0)] [batch|online] [门限K] [阶跃确认帧数] [三点趋势确认1/0] [水平带1/0]
输出: 与输入同目录  剔除后_<文件名>_<HHMMSS>.xlsx (无openpyxl环境回退csv; 写完自动打开)

――― 修改记录(每次修改在首行追加, 新修改在最上) ―――
2026-11-09 reset()清除首帧对暂存_pair_buf: 此前压辊沿复位/丢失自动复位后旧暂存帧跨复位
             存活,复位后的首个有效帧仍与复位前的暂存值配对——与ARM memset全清语义不一致
             (16D工程差分发现);清除后恢复帧从新暂存重新攒对|Yang.zj+ 2026.11.09.161525
2026-11-09 回退接料(让料头)处理: 接料期间可能有伪误差,需要飞点算法正常处理(而非透传);
             删除让料头=1的"接料透传"和1→0沿复位;run_online不再接收lhs参数;
             load_values仍读取让料头列(仅读取不影响算法)|Yang.zj+ 2026.11.09.144724
2026-11-06 首帧对一致性检查: 复位后前2帧须差≤100丝才一起采信进入历史——76个压辊
             沿数据分析:61%的压下事件后有杂波,其中狂跳型(|Δ|>100/帧)会污染参照;
             平滑偏高型(|Δ|≈5~40)和平板型(|Δ|<10)与真实偏差不可区分,算法正确跟随;
             首帧对检查只拦狂跳型,其余正常通过;ARM同步实现|Yang.zj+ 2026.11.06.163802
2026-11-06 撤销稳定检查(Settle):评估后确认得不偿失——压辊压下后大量帧被判为-32768
             (T=10时1951帧,T=50时969帧),控制器在恢复期收不到有效误差;
             且一致性杂波(T=50仍可通过)与真实信号不可区分;恢复原有"前2帧无条件
             采信"的启动行为;ARM同步撤销(常量/结构体/feed分支/复位触发全清)
             |Yang.zj+ 2026.11.06.150209
2026-11-04 第三支路信号升级为max(|调整量|,|解耦量|): 新增读取"纵向计算调整量"列(第6列,
             表头精确定位),note_adj入窗值改为两信号的绝对值最大——调整量捕获本组控制器
             响应(1207拍仅调整量>500μm),解耦量捕获上游传播效应(6314拍仅解耦量>500μm),
             两者互补;60文件×45895帧实测:仅解耦量176帧→仅调整量273帧→max两者148帧
             (再降16%);25个真单帧尖峰零损失|Yang.zj+ 2026.11.04.141007
2026-11-04 测试合集60文件参数收敛+接料让料头支持: ①让料头列(第5列,表头"让料头(接料就输出)"
             精确定位,"接料就输出"兜底)——=1期间"接料透传"(原值直通,不喂不记账),1→0沿
             剔除器全状态复位(用户方案原样实现);②连续丢失≥LOST_RESET_N(4)拍自动复位
             (消除长丢失恢复期hard误拒39帧,与平均层">3清零"同阈值语义);③参数定稿:
             ADJ_TOL_GAMMA 0.5→0.8、DV_TOL_GAMMA 8→25(60文件×45895帧总拒337→176=0.38%,
             残余hard 106帧中单帧尖峰为真飞点、持续变化均3帧内趋势确认自愈;PET/OPP/PE
             三材料同套参数无分材料必要)|Yang.zj+ 2026.11.04.113045
2026-11-03 结果文件附速度列: 输出列序改为 序号/原始值/速度/压辊/解耦量/判定/剔除后输出/
             σ(生效)/带a/带b(A~J列,速度插在原始值与压辊之间——速度+压辊对照可推料膜
             速度),运行日志移到L列;make_stats索引顺延|Yang.zj+ 2026.11.03.162639
2026-11-03 升降速容忍第四支路(速度变化率): 数据可选第4列"速度"(表头定位,任意单位),
             Δv=本拍速度−上一拍,入5拍滑窗(同样feed之后入窗防反灌);T_out第四支路=
             DV_TOL_GAMMA(γ_v,默认8丝/Δv单位)×|窗口内最大Δv|——张力瞬态∝dV/dt,匀速时
             Δv=0支路自动失效,仅升降速期间抬门;3U实测:1622帧降速段(Δv=1.6/拍,
             Δe≈4~8丝/拍)d=11.2丝对门10.5丝差0.7丝边缘误判,γ_v=7恰在浮点边界,
             γ_v=8清零(1622/1623/1624全转好,全文件零误判);无速度列恒不触发
             |Yang.zj+ 2026.11.03.161533
2026-11-03 兑现窗口3→5拍(5U实测): ALL.MIX_5U第493帧(d=31.5丝)由489拍+2455.7μm
             解耦指令在滞后第4拍兑现引发误判,3拍窗口容忍26.8丝差5丝不够→扩到5拍
             (122.8丝)覆盖;确认代码本就是"绝对值最大"max(abs(·)),非代数最大——门槛
             只用幅值不用符号,对顺逆序/符号约定免疫|Yang.zj+ 2026.11.03.095418
2026-11-03 表头精确匹配: 三列定位优先精确相等匹配用户原文件的绝对准确表头——
             "跟踪前一色纵向误差"/"压辊"/"解耦量@黄"(Y/BE/BH),匹配不到再按短关键词
             "跟踪前一色"/"压辊"/"解耦量"模糊兜底(容变体命名),再无则回退相邻列
             0/1/2;两级匹配见_Find_col|Yang.zj+ 2026.11.03.091836
2026-11-03 三列表头自动定位+结果附对照列: load_values优先扫描首行表头关键词定位
             三列——"跟踪前一色"→误差、"压辊"→压辊、"解耦"→解耦量(用户原文件三列分散在
             Y/BE/BH,不同导出列位会变,认表头比认列号稳;表头无关键词回退相邻列
             col/col+1/col+2);结果文件在"原始值"后附压辊/解耦量两列(C/D列)方便对照,
             判定/输出/σ/带顺延至E~I列,日志移到K列|Yang.zj+ 2026.11.03.091249
2026-11-02 调整感知门槛第三支路(解耦量): 数据可选第3列=解耦量μm(本拍最终版辊指令,含
             本组调整量,用户定义——只用解耦量,不与调整量相加);指令分多拍兑现(实测
             -2414μm后误差6拍爬74丝),故T_out第三支路=γ×|近ADJ_TOL_LAGS(3)拍窗口内最大
             解耦量|/10(μm→丝),γ=ADJ_TOL_GAMMA默认0.5;时序=note_adj在feed之后调用
             (窗口只含已过去指令,防飞点当拍的大指令反向放宽门槛);无解耦列时恒不触发,
             行为与原版逐帧一致;3U实测(压辊+解耦列,γ=0与C/ARM逐帧一致且复现原结果):
             γ=0.2清467/468簇(264簇拒绝后移至266/267),γ=0.5全文件零误判
             |Yang.zj+ 2026.11.02.162426
2026-11-02 压辊状态列支持(工具层,算法本体零改动): 数据可选第2列为压辊状态(1=压下/
             0=抬起,状态信号非沿),在线模式检测到任意沿(抬起或压下)即调用新增的
             FlyRemover.reset()全状态清空——历史/σ/锁存/quantum窗/候选链/帧号全部
             归零,下一有效误差从"首帧"重新暖机;与主站压辊沿复位补丁/ARM
             KS_FlyRemove_Reset_V/H完全同语义,feed/_band/_repl等算法函数未动,
             C↔Python差分验证含压辊列数据逐帧一致;无压辊列时行为与单列版逐帧一致
             |Yang.zj+ 2026.11.02.140126
2026-10-28 趋势带斜率最少3点起用(方案A,配合三点趋势确认): 历史点数<=2时带退化为
             水平中位(1点=该点,2点=中值),P同值不外推 —— Theil-Sen的中位数鲁棒性前提
             是"多对斜率取中位",仅2点时斜率完全由两点决定、无任何抗污染能力;实测张力
             数据中双尖峰(-217/-206)骗过阶跃确认→观察帧进历史→2点陡斜率(-38/帧)外推
             把带拉低,随后-109距带仅21<门42被放行(调K/β无效,是带位置问题);本修复使
             该-109判飞点,5425帧全量仅影响此1帧,12场景/开机跟随/等值串/孤立飞点零回归。
             注意:需与三点趋势确认同开(水平带会先拒真连续趋势1帧,由趋势确认接管)
             开关flat_band,默认开|2026.10.28.220000
2026-10-28 三点连续趋势确认(同步自Qt实验分支python_algorithm.cpp,见《飞点剔除_
             三点连续趋势确认算法说明》): 候选链中已有两个连续候选原始点且原状态机
             仍处于候选/观察期时,用两点线性外推预测第三点P_c=2x2-x1,两次变化严格
             同向且|残差|<=冻结候选门槛min(T_start,当前T_out)时,以三点实测直接重建
             可信历史,输出/锁存立即接管到x3,本帧按好点计入振荡统计——解决开机压辊/
             调整期真实误差快速连续变化被反复"飞点-阶跃确认-观察失败"拦截(输出停在
             旧电平不跟)。候选缓存仅收飞点/阶跃/暂缓帧的原始输入(≤2点,滑窗保留链首
             T_start);好/观察通过/回归/吸收/趋势确认清空;丢失或无效输入打断候选链
             (run_online对丢失帧调用note_invalid)。等值串(零变化)不满足严格同向,
             仍走原逻辑;开关trend_confirm可关(关=原基线),默认开|2026.10.28.170000
2026-10-28 收敛β门限法(与主站PLC统一): 量化容忍从"σ垫底(σ≥q,等效门槛5q)"改为
             "**门槛垫底** T_out=max(Kσ, β×q)"(QUANTUM_TOL=β=10,与PLC的
             KS_FLY_QUANTUM_TOL一致),回归门槛联动为0.5×实际外门槛;观察帧接管
             幅度绑定实际外门槛(删除QUAR_TAKE_FRAC系数,等效其1.0)。β=0即完全
             关闭量化容忍(回纯Kσ门槛),β只在>K时有效(Kσ侧天然兜底);σ与暖机σ不再
             垫q。收敛后Python与主站PLC在连续与量化数据上均逐帧一致|2026.10.28.150030
2026-10-28 输出增强: 结果文件新增E/F/G三列——每帧生效σ(含暖机/振荡/quantum兜底后的
             最终值,门限=5σ/2.5σ)与允许带a/b(Theil-Sen趋势带下沿/上沿);启动期帧和
             丢失帧留空;运行日志移到I列|Yang.zj+ 2026.10.28.111107
2026-10-28 观察帧有界接管: "好(观察)"帧输出由锁存改为 latch+clamp(x−latch, ±QUAR_TAKE_FRAC×
             T_out)(默认1.0×T_out=5σ;置0完全回退旧行为) —— 幅度≤5σ的真阶跃观察帧即全额
             跟上(阶跃响应3~4帧→2~3帧),大阶跃每观察帧至少向新电平挪5σ;代价:宽度恰为3的
             等值串从0泄漏变为1帧、幅度封顶5σ(宽≥4串本就漏,见文档边界①);锁存/历史/σ
             /防串机制全部不动,仅改输出|Yang.zj+ 2026.10.28.110557
2026-10-27 晚五  版本合并: 以用户修改版为基 —— ①丢失帧原样输出-32768, 不再用
             锁存值占位(下游按丢失处理, 不造假数); ②帧号稠密化: 丢失帧不占号,
             相邻有效帧即相邻帧号(与PLC/ARM一致)。在其上移植晚四的量化σ塌缩
             修复(数据分辨率quantum兜底, 实机3U台阶漂移误报59→9帧)
2026-10-27 晚四  量化数据σ塌缩修复(实机3U误差数据复现: 全整数丝+14%重复值,
             台阶式漂移全程"飞点/确认"爬行, 101有效帧误报59帧): 新增数据分辨率
             quantum=最近16个非零相邻差分的最小值(仅相邻帧, 跨丢失段的差分不作数;
             min对飞点免疫, 滑动窗可自适应), σ与暖机σ以其兜底 → 量化数据门限
             ≥5×分辨率, 台阶漂移交回趋势带原生跟随(3U误报59→9);
             连续噪声数据quantum≈0, 行为不变
2026-10-27 晚三  用P替换时同步刷锁存(self.latch=p): 阶跃(确认)/好(观察)帧
             随后输出同一条趋势外推线, 而非回跳到更旧的测量值(消除输出序列
             台阶); 防线不变 —— 观察帧仍不接管新电平, P只来自成熟可信账本,
             等值串防护/双守卫全部保留
2026-10-27 晚二  飞点/暂缓替换值升级: 锁存 → 趋势外推P(实测平稳段替换误差
             0.99σ→0.61σ, 斜坡1.81σ→0.82σ), 双守卫: 账本≥3点(阶跃重建后
             1~2点时P=可疑新电平, 会透传)且未进振荡模式(线性外推失真);
             阶跃(确认)/好(观察)/观察失败帧维持锁存不变(防等值串的设计不变量)
2026-10-23 晚  量纲无关化+泛用性验证(免调参目标):
             ① 删除σ绝对下限(原2丝, 换单位/换传感器即失效) → σ=max(差分MAD,ε),
               暖机σ=SIG_PROV×已有差分中位绝对值(尺度自举, 量纲无关)
             ② 差分≥8个才启用MAD估计(3个时统计涨落±50%会引发"越剔越紧"死亡螺旋,
               此前被绝对下限掩盖, 删下限后暴露)
             ③ 启动态改独立标志started: 阶跃重建历史≠重启, 修复确认后观察帧被
               "首2帧无条件采信"绕过导致锁存污染(3宽串漏1帧/串的根因)
             ④ 新增 泛用性验证.py: 量纲跨度×10000 × 10场景 × 3确定性种子,
               同一套默认参数全部PASS
2026-10-23 下午  按文档《可信趋势与延迟确认》升级在线模式三处:
             ① σ改可信值相邻差分MAD(1.4826/√2归一) — 差分天然消趋势/电平; 阶跃只换
               电平不换噪声, σ跨阶跃沿用; 删除残差限幅补丁
             ② 参照改Theil-Sen趋势带(最近≤9可信点: 两两斜率中位数外推P与中位
               水平L构成允许带[min,max]) — 斜坡零新息(实测0.8~5丝/帧斜坡仅起步
               3帧过渡、末端零偏差), 删除一阶跟踪器与同号持续判据; 突跳后弯曲回落
               落在P与L之间也在带内
             ③ 双门槛迟滞 — 外门槛K×σ(成候选), 回归门槛0.5K×σ(确认回原趋势),
               两门槛之间暂缓(≤3帧未决则按正常值吸收, 暂缓≠剔除)
             另: 阶跃确认后观察帧改为"进历史但不接管输出"(修复确认后参照冻结导致
               陡斜坡/振荡死循环); 保留振荡自愈(差分σ看不到被拒帧, 需全幅MAD兜底);
               默认门限K=3→5, 对齐文档5σ/2.5σ(慢漂移区K=3产生大量13~22丝边界判定,
               K=5暂缓减半、输出σ与旧版持平、深尖峰同样为0)
2026-10-23 上午  在线模式重构为严格因果版(可上实时, 实测10U纵向深尖峰54帧→0):
             废弃回撤撤销/回溯改写 → 阶跃确认+观察帧+锁存不动机制
2026-10-22 17:30  增加选文件GUI/CLI, 输出 剔除后_<名>_<HHMMSS> 结果文件
2026-10-22 17:00  初版: 批式MAD + 在线链式 参考实现与演示
"""
import csv
import math
import os
import statistics as st
import sys
import time

LOST = -32768


# ---------------- ① 批式: 中值 + MAD 稳健门限, 迭代剔除 ----------------
def flag_fly_batch(vals, k=3.0, sigma_min=2.0, max_iter=3):
    """逐帧返回是否飞点; 每轮用存活点重算 中值/MAD/门限 再判, 直到无新飞点.
    参照=中值(飞点拉不动), σ̂=1.4826×MAD(正态一致性系数, 飞点撑不大门)."""
    alive = [v != LOST for v in vals]
    flags = [False] * len(vals)
    events = []
    for _ in range(max_iter):
        cur = [v for v, a in zip(vals, alive) if a]
        if len(cur) < 3:
            break
        med = st.median(cur)
        mad = st.median(abs(v - med) for v in cur)
        gate = k * max(sigma_min, 1.4826 * mad)
        if not events:
            events.append(f"参照中值={med:g}  MAD={mad:g}  "
                          f"σ̂=max({sigma_min:g},{1.4826 * mad:.2f})  门限=±{gate:.1f}")
        bad = [j for j, (v, a) in enumerate(zip(vals, alive)) if a and abs(v - med) > gate]
        if not bad:
            break
        for j in bad:
            flags[j], alive[j] = True, False
            events.append(f"帧{j + 1:4d}  x={vals[j]:g}  |x−{med:g}|="
                          f"{abs(vals[j] - med):.1f} > 门限{gate:.1f} → 剔除")
    return flags, events


# ---------------- ② 在线: 严格因果剔飞链(趋势带+差分σ+双门槛) ----------------
TRUST_WIN, NOISE_WIN, DIFF_MIN = 9, 31, 8   # 趋势窗(点) / 噪声窗(点) / 最少差分数
                           # (差分<8个时差分MAD统计涨落可达±50% → 紧门限拒掉的帧
                           #  进不了统计 → σ越剔越小的死亡螺旋, 故暖机期不用它)
SIG_PROV = 2.0               # 暖机σ倍数: σ=SIG_PROV×已有差分的中位绝对值(尺度
                           # 自举, 量纲无关; 暖机门限≈9σ, 宽松但不会螺旋)
STEP_CONFIRM = 2             # 阶跃确认: 连续强超门(>外门槛)满N帧
QUAR_N = 1                   # 阶跃确认后的观察帧数(过门进历史但不接管输出/锁存)
RET_FRAC = 0.5               # 回归门槛 = RET_FRAC×外门槛(文档 2.5σ/5σ 的比例)
HOLD_MAX = 3                 # 迟滞带内暂缓上限: 连续暂缓满N帧按正常值吸收(暂缓≠剔除)
OSC_WIN, OSC_IN, OSC_OUT = 64, 0.25, 0.10  # 振荡自愈: 近64帧"非好"占比
                                           # >25%进入(门放宽到全幅MAD)、<10%退出
QUANTUM_TOL = 10.0            # 量化容忍倍数β: 外门槛 T_out=max(Kσ, β×q)(2026-10-28收敛β门限法,
ADJ_TOL_GAMMA = 0.8           # 调整感知容忍γ(第三支路): T_out再≥γ×|近ADJ_TOL_LAGS拍内最大解耦量|/10
                              # (μm→丝)——解耦量=本拍最终版辊指令(含本组调整量),指令分多拍兑现
                              # (实测-2414μm后误差6拍爬74丝),大调整后出圈线垫高,调整带来的连续
                              # 变化不再判飞;窗口取"近几拍最大幅值×兑现比例";自限性:稳态指令
                              # 仅几十μm时容忍≈1~3丝形同虚设,仅大调整期间抬门;
                              # 2026.11.04测试合集60文件收敛:0.5→0.8(0.5时解耦窗内误拒仍有92帧,
                              # 0.8后残余47帧均为|dec|>2000μm巨幅工况且3帧内趋势确认恢复;
                              # 不再调大——γ≥1.0会吞掉dec≈200μm/d≈13丝的真单帧尖峰)
                              # |Yang.zj+ 2026.11.02.162426|2026.11.04.113045
ADJ_TOL_LAGS = 5              # 解耦量兑现滞后窗口(拍): 窗口内任一拍的指令都可能还在兑现中。
                              # 2026-11-03 5U实测:489拍+2456μm指令在493拍(d=31.5丝)兑现引发误判,
                              # 3拍窗口(容忍26.8丝)差5丝不够,扩到5拍(容忍122.8丝)覆盖|Yang.zj+ 2026.11.03.095418
DV_TOL_GAMMA = 25.0           # 速度变化率容忍γ_v(第四支路): T_out再≥γ_v×|近DV_TOL_LAGS拍内最大Δv|
                              # (丝/Δv单位)——升降速期间张力瞬态使误差漂移;匀速时Δv=0支路自动失效;
                              # 2026.11.04测试合集60文件收敛:8→25(升速12→240全程与起步段带宽滞后
                              # 期需要更高容忍,25后残余23帧且紧跟趋势确认恢复;标定依据:Δv=1.7的
                              # 最陡升速段容忍42.5丝仍偶有不足,但残余均3帧内自愈);
                              # 0=关闭|Yang.zj+ 2026.11.03.161533|2026.11.04.113045
DV_TOL_LAGS = 5               # 速度变化率滞后窗口(拍): 张力瞬态在速度斜坡期间及结束后短暂持续
LOST_RESET_N = 4              # 连续丢失≥N拍自动复位剔除器:长丢失段后误差电平/工况已变,旧参照
                              # 不可信,恢复帧从首帧重新暖机(与平均层">3幅清平均"同阈值语义)|Yang.zj+ 2026.11.04.113045
                              # 与主站PLC的KS_FLY_QUANTUM_TOL一致);q=数据分辨率(最近16个非零
                              # 相邻差分最小值)——量化/整数数据上σ可塌缩到0,以β×q垫门槛,稳态
                              # 小波动不报飞点;连续数据q≈0不起作用;β=0完全关闭,β只在>K时有效|2026.10.28.150030
_SQRT2 = math.sqrt(2.0)
_EPS = 1e-12                 # σ=0保护(完全恒定信号上任一偏差即异常, 属正确行为)


class FlyRemover:
    """逐帧 feed(x, idx) → (输出值, 判定). 严格因果: 第i帧输出只依赖第1~i帧.

    参照 = 可信历史的 Theil-Sen 趋势带(≤31点, 飞点/暂缓帧不进; 观察帧进但不接管输出):
      v = 最近≤9点两两斜率中位数, P = 各点按v外推到当前帧的中位数, L = 中位水平,
      允许带=[min(P,L), max(P,L)] —— 斜坡上外推即预测(零新息), 真实突跳后的弯曲
      回落落在P与L之间也在带内.
    噪声 σ = 1.4826/√2 × MAD(可信值相邻差分), 全程无量纲绝对值(量纲无关, 免调参):
      差分消掉趋势与电平; 攒满8个差分才启用(更少时统计涨落会引发"越剔越紧"螺旋);
      暖机期用 σ=SIG_PROV×已有差分中位绝对值自举; 阶跃只换电平不换噪声 → σ沿用,
      跨阶跃不断档.
    量化容忍(β门限法,2026-10-28与主站PLC统一): 外门槛 T_out=max(K×σ, β×q),
      q=数据分辨率(最近16个非零相邻差分最小值,≥2样本;仅相邻帧,跨丢失段不作数)
      ——量化/整数数据上差分可为0,不兜底则门限≈0,台阶式漂移会被"飞点/确认"
      爬行(实机3U整数丝数据复现过);β=QUANTUM_TOL(当前10,可调),置0完全关闭,
      连续数据q≈0不起作用.σ与暖机σ不再垫q(q只垫门槛).
    双门槛迟滞: 外门槛 T_out=max(K×σ, β×q), 回归门槛 T_ret=0.5×T_out(联动实际外门槛).
      好        : 带距d≤T_out(或候选期d≤T_ret确认回归) → 原值输出, 进可信历史
      飞点(锁存): d>T_out → 替换值输出; 连续强超门未满确认帧数时同样
      暂缓(锁存): 候选期 T_ret<d≤T_out → 替换值输出但不判死; 连续HOLD_MAX帧吸收
      替换值    : 飞点/暂缓 → 外推P(账本≥3点且非振荡模式; 斜坡上比锁存新鲜),
                  否则退回锁存; 阶跃(确认)/好(观察)/观察失败一律锁存 —— 确认重建
                  后账本仅1~2点, P恰为可疑新电平, 用了会透传(设计不变量)
      阶跃(确认): 连续强超门满STEP_CONFIRM帧 → 历史重建为新电平单点, 锁存不动
                  (输出仍旧电平); 其后QUAR_N观察帧过门即进历史(参照跟上), 锁存不动,
                  输出有界接管(向新值最多挪T_out, 2026-10-28) —— 宽≤2等值飞点串零污染,
                  宽3串1帧封顶5σ, 真阶跃响应滞后≈确认+观察幅内立即跟上."""

    def __init__(self, k=5.0, step_confirm=STEP_CONFIRM, trend_confirm=True,
                 flat_band=True):
        self.k, self.confirm = k, step_confirm
        self.trend_confirm = trend_confirm  # 三点连续趋势确认开关(关=原基线)|2026.10.28.170000
        self.flat_band = flat_band  # 趋势带斜率最少3点起用(<=2点水平中位带)|2026.10.28.220000
        self.hist = []        # 可信历史 [(帧号, 值)], 只收真实测量
        self.started = False  # 启动态(前2帧无条件采信); 阶跃重建历史≠重启, 不回退
        self.latch = None     # 锁存: 最近好值(替换用, 不回灌历史)
        self.sigma = None     # 最近一次差分MAD估计; None时用暖机σ(量纲自举)
        self.qdq = []         # 近期非零相邻差分(≤16个) → 数据分辨率估计
        self.pval = None      # 上一有效输入值(算分辨率用, 含被拒帧)
        self.pidx = None      # 上一有效输入帧号(跨丢失段的差分不入分辨率估计)
        self.cand = []        # 候选链原始点缓存[(帧号,值)]≤2, 三点趋势确认用|2026.10.28.170000
        self.cand_tstart = None  # 本轮候选链首帧的实际外门槛(冻结,滑窗不重置)
        self.adj_ring = []    # 近ADJ_TOL_LAGS拍解耦量(μm),调整感知门槛第三支路用|Yang.zj+ 2026.11.02.162426
        self.dv_ring = []     # 近DV_TOL_LAGS拍速度变化Δv,升降速容忍第四支路用|Yang.zj+ 2026.11.03.161533
        self.lastd = 0.0      # 最近一次可信相邻差分绝对值(暖机σ的尺度种子)
        self.consec = 0       # 连续强超门计数(阶跃确认用)
        self.quar = 0         # 阶跃确认后的观察帧计数
        self.hold = 0         # 候选期暂缓计数
        self.judged = []      # 近期"非好"判定, 振荡自愈检测用
        self.alldev = []      # 近期|新值−带中心|(含被拒帧), 振荡模式估幅用
        self.osc_on = False
        self.events = []      # 振荡进出事件, 工具层取走

    def note_invalid(self):
        """丢失/无效输入打断三点趋势确认的候选链(不能跨越丢失确认趋势)|2026.10.28.170000"""
        self.cand = []
        self.cand_tstart = None
        self.dbg_sigma = None # 每帧生效σ(供结果文件E列;启动期帧/丢失帧无)|Yang.zj+ 2026.10.28.111107
        self.dbg_a = None     # 每帧允许带下沿a(F列)
        self.dbg_b = None     # 每帧允许带上沿b(G列)

    def note_adj(self, dec_um):
        """记录本拍解耦量(最终版辊指令,μm)——供门槛第三支路:指令分多拍兑现,大调整后出圈线
        垫高γ×|窗口内最大|。须在本拍feed之后调用(ring内只留"已过去的指令");丢失帧也调用
        (窗口按拍推进,缺值补0)|Yang.zj+ 2026.11.02.162426"""
        self.adj_ring.append(float(dec_um))
        if len(self.adj_ring) > ADJ_TOL_LAGS:
            self.adj_ring.pop(0)

    def note_dv(self, dv):
        """记录本拍速度变化Δv(本拍速度−上一拍速度,任意单位)——供门槛第四支路:升降速期间
        张力瞬态使误差漂移,出圈线垫高γ_v×|窗口内最大Δv|。同样须在feed之后调用(只留已过去
        的变化);匀速时Δv=0支路自动失效|Yang.zj+ 2026.11.03.161533"""
        self.dv_ring.append(float(dv))
        if len(self.dv_ring) > DV_TOL_LAGS:
            self.dv_ring.pop(0)

    def reset(self):
        """压辊沿等工况切换:全状态清空——历史/σ/锁存/quantum窗/候选链/帧号全部归零,
        下一有效误差从首帧重新暖机。等价ARM ks_fly_reset(memset全清)/主站i_xReset分支,
        算法本体(feed/_band/_repl等)不变,与C版逐帧一致的前提|Yang.zj+ 2026.11.02.140126"""
        self.hist = []
        self.started = False
        self.latch = None
        self.sigma = None
        self.lastd = 0.0
        self.qdq = []
        self.pval = None
        self.pidx = None
        self.cand = []
        self.cand_tstart = None
        self.consec = self.quar = self.hold = 0
        self.judged = []
        self.alldev = []
        self.osc_on = False
        self.dbg_sigma = self.dbg_a = self.dbg_b = None
        self.adj_ring = []    # 解耦量窗口一并清空(新工况旧指令不可信)|Yang.zj+ 2026.11.02.162426
        self.dv_ring = []     # 速度变化窗口一并清空|Yang.zj+ 2026.11.03.161533
        self._pair_buf = None # 首帧对暂存一并清空:复位前攒的旧帧跨复位不可信,恢复帧重新攒对
                             # (与ARM memset全清对齐;否则压辊沿/丢失复位后首帧仍与复位前
                             # 暂存值配对)|Yang.zj+ 2026.11.09.161525

    @property
    def quantum(self):
        """数据分辨率 = 最近16个非零相邻差分的最小值(需≥2个样本; 量纲自举).
        量化/整数数据上σ会塌缩到0 → 门限≈0 → 台阶漂移被判飞点爬行, 以分辨率兜底;
        取min对大差分(飞点)免疫, 滑动窗可随数据变粗/变细自适应; 连续数据上≈0不起作用."""
        return min(self.qdq) if len(self.qdq) >= 2 else None

    def _band(self, idx):
        """最近≤TRUST_WIN个可信点 → (带a, 带b, 外推P).
        Theil-Sen斜率外推P与中位水平L构成允许带[min,max], P另作替换值用."""
        pts = self.hist[-TRUST_WIN:]
        if len(pts) == 1:
            v0 = pts[0][1]
            return v0, v0, v0
        if self.flat_band and len(pts) < 3:
            # 斜率至少3点起用:仅2点时Theil-Sen无中位数鲁棒性,两点(常为阶跃重建+观察帧
            # 的过渡值)即可定斜率,尖峰串污染后陡斜率外推会把带拉飞(实测-109漏剔根因)
            # 2点用水平中位带,P同值不外推|2026.10.28.220000
            lv = st.median(v for _, v in pts)
            return lv, lv, lv
        slopes = [(pts[j][1] - pts[i][1]) / (pts[j][0] - pts[i][0])
                  for i in range(len(pts)) for j in range(i + 1, len(pts))
                  if pts[j][0] > pts[i][0]]
        v = st.median(slopes) if slopes else 0.0
        p = st.median(xi + v * (idx - ti) for ti, xi in pts)
        lv = st.median(xi for _, xi in pts)
        return min(p, lv), max(p, lv), p

    def _repl(self, p):
        """飞点/暂缓的替换值: 趋势可信(账本≥3点且未进振荡模式)时用外推P
        (按趋势推算的当前估计, 斜坡上比锁存新鲜: 实测替换误差0.99σ→0.61σ);
        否则退回锁存 —— 账本刚被阶跃重建(1~2点)时P恰为可疑新电平, 用了会透传;
        振荡模式时线性外推失真, 也退回锁存. 替换值一律不回灌(历史/σ不动).
        用P时同步刷锁存: 随后的阶跃(确认)/观察失败帧输出的还是锁存, 好(观察)帧
        输出锁存+有界接管(2026-10-28), 但咬住的是这条趋势线而非回跳到更旧的
        测量值 → 输出序列连续无台阶; 防线不变 —— 观察帧锁存仍不动, P只会来自
        成熟可信账本, 等值串防护不受影响."""
        if len(self.hist) >= 3 and not self.osc_on:
            self.latch = p
            return p
        return self.latch

    def _push(self, x, idx):
        """值进可信历史并刷新差分σ(只有真实测量进历史 —— 飞点/暂缓帧不进)."""
        self.hist.append((idx, x))
        if len(self.hist) > NOISE_WIN:
            self.hist.pop(0)
        if len(self.hist) >= 2:
            self.lastd = abs(self.hist[-1][1] - self.hist[-2][1])
        dv = [b[1] - a[1] for a, b in zip(self.hist, self.hist[1:])]
        if len(dv) >= DIFF_MIN:
            med = st.median(dv)
            self.sigma = max(_EPS, 1.4826 / _SQRT2
                             * st.median(abs(t - med) for t in dv))  # σ不再垫q(2026-10-28收敛β门限法,q垫在门槛上)

    def _good(self, x, idx):
        """好点: 进可信历史, 更新锁存, 原值输出."""
        self._push(x, idx)
        self.latch = x
        self.consec = self.hold = 0
        return x, "好"

    def feed(self, x, idx=None):
        x = float(x)
        self.dbg_sigma = self.dbg_a = self.dbg_b = None   # 每帧先清:启动期帧无带/σ|Yang.zj+ 2026.10.28.111107
        idx = idx if idx is not None else (
            self.hist[-1][0] + 1 if self.hist else (self.pidx or 0) + 1)
        if self.pval is not None and idx == self.pidx + 1:   # 仅相邻帧差分入分辨率
            dd = abs(x - self.pval)                          # (跨丢失段的差分不作数)
            if dd > 0:
                self.qdq.append(dd)
                if len(self.qdq) > 16:
                    self.qdq.pop(0)
        self.pval, self.pidx = x, idx
        if not self.started:                  # 启动期: 前2帧无条件采信(凑差分自举
            self._push(x, idx)                # 尺度; 启动期不保证剔坏点)
            self.latch = x
            if len(self.hist) >= 2:
                self.started = True
            return x, "首帧"
        a, b, p = self._band(idx)
        d = max(a - x, x - b, 0.0)             # 当前值到允许带的距离
        # —— 振荡自愈: 判非好占比过高说明门过紧/信号在振荡(被拒帧进不了差分σ,
        #    σ自适应被选择偏差卡住) → 用含被拒帧的全幅MAD把门撑回摆动幅度量级
        ratio = (sum(self.judged) / len(self.judged)) if self.judged else 0.0
        if not self.osc_on and len(self.judged) >= OSC_WIN and ratio > OSC_IN:
            self.osc_on = True
            self.events.append(f"振荡模式进入(近{OSC_WIN}帧判非好占比{ratio * 100:.0f}%) → 门放宽")
        elif self.osc_on and len(self.judged) >= OSC_WIN and ratio < OSC_OUT:
            self.osc_on = False
            self.events.append("振荡模式退出")
        sigma = self.sigma
        if sigma is None:                     # 暖机σ: 已有差分中位绝对值自举(不再垫q,收敛β门限法)
            dv = [b[1] - a[1] for a, b in zip(self.hist, self.hist[1:])]
            sigma = SIG_PROV * max(st.median(abs(t) for t in dv) if dv else 0.0,
                                   _EPS)
        if self.osc_on and len(self.alldev) >= 8:
            sigma = max(sigma, 1.4826 * st.median(self.alldev))
        t_out = self.k * sigma                # 外门槛=max(Kσ, β×q)——量化容忍垫在门槛上|2026.10.28.150030
        q = self.quantum
        if q is not None and QUANTUM_TOL * q > t_out:
            t_out = QUANTUM_TOL * q
        if ADJ_TOL_GAMMA > 0.0 and self.adj_ring:   # 第三支路:调整感知容忍——解耦指令分多拍兑现,
            adj_tol = ADJ_TOL_GAMMA * max(abs(a) for a in self.adj_ring) / 10.0  # (μm→丝)大调整后出圈线垫高|Yang.zj+ 2026.11.02.162426
            if adj_tol > t_out:
                t_out = adj_tol
        if DV_TOL_GAMMA > 0.0 and self.dv_ring:      # 第四支路:升降速容忍——张力瞬态∝dV/dt,|Yang.zj+ 2026.11.03.161533
            dv_tol = DV_TOL_GAMMA * max(abs(a) for a in self.dv_ring)            # 匀速时Δv=0自动失效
            if dv_tol > t_out:
                t_out = dv_tol
        t_ret = RET_FRAC * t_out              # 回归门槛联动为0.5×实际外门槛
        self.dbg_sigma, self.dbg_a, self.dbg_b = sigma, a, b   # 供结果文件E/F/G列|Yang.zj+ 2026.10.28.111107

        # —— 三点连续趋势确认(2026-10-28同步自Qt实验分支): 候选链中两个连续候选原始点
        #    线性外推预测第三点,两次变化严格同向且残差<=冻结候选门槛时,三点实测直接重建
        #    可信历史,输出/锁存立即接管到x3 —— 减少快速连续真实变化被反复"飞点-阶跃-观察
        #    失败"拦截;等值串(零变化)不满足严格同向仍走原逻辑;开关关闭时本分支不执行|2026.10.28.170000
        if (self.trend_confirm and len(self.cand) == 2
                and (self.consec > 0 or self.quar > 0)
                and self.cand[1][0] == self.cand[0][0] + 1
                and idx == self.cand[1][0] + 1):
            x1, x2 = self.cand[0][1], self.cand[1][1]
            d1 = x2 - x1
            d2 = x - x2
            if (d1 > 0 and d2 > 0) or (d1 < 0 and d2 < 0):  # 严格同向,零变化不算
                pc = 2.0 * x2 - x1        # 候选预测P_c(≠趋势带P,仅用于判断候选链能否成为新趋势)
                tc = min(self.cand_tstart, t_out)  # 冻结候选门槛:链首外门槛与当前外门槛取小
                if abs(x - pc) <= tc:
                    self.hist = [self.cand[0], self.cand[1], (idx, x)]  # 三点实测为新可信历史
                    self.consec = self.hold = self.quar = 0
                    self.latch = x                                   # 锁存同步接管(σ沿用不清)
                    out, flag = x, "趋势确认"
                    self.cand = []
                    self.cand_tstart = None
                    self.judged.append(False)          # 本帧按好点计入振荡自愈统计
                    if len(self.judged) > OSC_WIN:
                        self.judged.pop(0)
                    self.alldev.append(abs(x - (a + b) / 2.0))
                    if len(self.alldev) > 16:
                        self.alldev.pop(0)
                    self.events.append(f"三点趋势确认: {x1:g}→{x2:g}→{x:g} "
                                       f"残差{abs(x - pc):.1f}≤门槛{tc:.1f},历史重建为三点,输出接管")
                    return out, flag

        if self.quar > 0:                      # —— 阶跃后观察帧(锁存仍不动,防等值串;
            if d <= t_out:                     # 输出有界接管:向新值方向最多挪一个实际
                self.quar -= 1                 # 外门槛T_out(含量化容忍),锁存/历史安全|2026.10.28.150030
                self._push(x, idx)             # 过门→进历史(参照跟上新电平)
                take = t_out                   # 接管幅度绑定实际外门槛(与PLC一致,无独立系数)
                out = self.latch + max(-take, min(take, x - self.latch))
                flag = "好(观察)"
            else:
                self.quar = 0                  # 未过门(观察失败)→重新计候选
                self.consec = 1
                out, flag = self.latch, "飞点(锁存)"   # 观察失败仍一律锁存,不用P
        elif self.consec > 0:                  # —— 候选期(迟滞判回归/续强/暂缓)
            if d <= t_ret:                     # 明确回到原趋势: 此前强超门=飞点
                out, flag = self._good(x, idx)
            elif d > t_out:
                self.hold = 0
                self.consec += 1
                if self.consec >= self.confirm:  # 连续强超门满确认帧数 → 确认阶跃
                    self.hist = [(idx, x)]     # 历史重建为新电平; 锁存/σ不动
                    self.consec = 0
                    self.quar = QUAR_N
                    out, flag = self.latch, "阶跃(确认)"
                else:
                    out, flag = self._repl(p), "飞点(锁存)"
            else:
                self.hold += 1                 # 迟滞带内: 暂缓≠剔除, 不进历史
                if self.hold >= HOLD_MAX:      # 连续暂缓无决 → 按正常值吸收
                    out, flag = self._good(x, idx)
                else:
                    out, flag = self._repl(p), "暂缓(锁存)"
        elif d <= t_out:                       # —— 正常: 带内即好
            out, flag = self._good(x, idx)
        else:
            self.consec = 1
            out, flag = self._repl(p), "飞点(锁存)"
        self.judged.append(flag not in ("好", "好(观察)", "趋势确认"))
        if len(self.judged) > OSC_WIN:
            self.judged.pop(0)
        self.alldev.append(abs(x - (a + b) / 2.0))
        if len(self.alldev) > 16:
            self.alldev.pop(0)
        # —— 候选链缓存维护(三点趋势确认用): 飞点/阶跃/暂缓帧的原始输入进缓存(≤2点,
        #    滑窗保留链首冻结门槛);好/观察通过/回归/暂缓吸收/趋势确认清空|2026.10.28.170000
        if flag in ("飞点(锁存)", "暂缓(锁存)", "阶跃(确认)"):
            if len(self.cand) == 0:
                self.cand_tstart = t_out   # 缓存由空变非空:保存此刻实际外门槛为链首T_start
            self.cand.append((idx, x))
            if len(self.cand) > 2:
                self.cand.pop(0)           # 滑窗:丢最旧,保留cand_tstart不随新候选放宽
        else:
            self.cand = []
            self.cand_tstart = None
        return out, flag


# ---------------- 两种方式的整段运行 ----------------
def run_batch(vals, k):
    flags, events = flag_fly_batch(vals, k)
    rows = [(i, "丢失" if x == LOST else x, "", "", "",
             "丢失" if x == LOST else ("飞点" if f else "保留"),
             "" if (x == LOST or f) else x, "", "", "")   # 批式无速度/压辊/解耦/σ/带,留空
            for i, (x, f) in enumerate(zip(vals, flags), 1)]
    return rows, events


def run_online(vals, k, confirm=STEP_CONFIRM, trend_confirm=True, flat_band=True,
               rollers=None, decs=None, speeds=None, adjs=None):
    fr, rows, events = FlyRemover(k, confirm, trend_confirm=trend_confirm,
                                   flat_band=flat_band), [], []
    fed = 0  # 稠密帧号:丢失帧不占号(与PLC/ARM及算法说明一致)
    prev_roll = None  # 上一行压辊状态:任意沿(抬起/压下)触发全状态复位|Yang.zj+ 2026.11.02.140126
    prev_spd = None   # 上一行速度(算Δv用,缺值沿用上一拍)|Yang.zj+ 2026.11.03.161533
    lost_run = 0      # 连续丢失计数(≥LOST_RESET_N自动复位)|Yang.zj+ 2026.11.04.113045
    for i, x in enumerate(vals, 1):
        roll = rollers[i - 1] if rollers is not None and i - 1 < len(rollers) else None
        if roll is not None:
            if prev_roll is not None and roll != prev_roll:
                fr.reset()  # 全状态清空(=ARM ks_fly_reset/主站i_xReset);本帧若有效即首帧|Yang.zj+ 2026.11.02.140126
                events.append(f"帧{i:4d}  压辊{int(prev_roll)}→{int(roll)} → 剔除器全状态复位,重新暖机")
            prev_roll = roll
        dec = decs[i - 1] if decs is not None and i - 1 < len(decs) else None
        adj = adjs[i - 1] if adjs is not None and i - 1 < len(adjs) else None
        # 第三支路有效信号 = max(|调整量|, |解耦量|):调整量捕获本组控制器响应,
        # 解耦量捕获上游传播效应,两者互补;60文件实测176→148帧|Yang.zj+ 2026.11.04.141007
        sig = max(abs(adj or 0), abs(dec or 0))
        spd = speeds[i - 1] if speeds is not None and i - 1 < len(speeds) else None
        dv = (spd - prev_spd) if spd is not None and prev_spd is not None else 0.0
        if spd is not None:
            prev_spd = spd
        cell_spd = spd if spd is not None else ""            # C列:速度(与D压辊对照可推料膜速度)|Yang.zj+ 2026.11.03.162639
        cell_roll = int(roll) if roll is not None else ""    # D/E列:压辊/解耦量(对照用)|Yang.zj+ 2026.11.03.091249
        cell_dec = dec if dec is not None else ""
        if x == LOST:
            lost_run += 1
            if lost_run >= LOST_RESET_N:  # 长丢失段后工况已变,自动复位|Yang.zj+ 2026.11.04.113045
                fr.reset()
                events.append(f"帧{i:4d}  连续丢失{lost_run}拍 → 剔除器全状态复位,恢复帧重新暖机")
                lost_run = 0
            fr.note_invalid()  # 丢失打断三点趋势确认候选链|2026.10.28.170000
            rows.append((i, LOST, cell_spd, cell_roll, cell_dec, "丢失", LOST, "", "", ""))
            # 原始值/输出写数值LOST(非文字):结果文件可直接回灌本工具重跑而不丢时间轴|Yang.zj+ 2026.11.03.162639
            if decs is not None:
                fr.note_adj(sig)  # 窗口按拍推进(max信号)|Yang.zj+ 2026.11.04.141007
            if speeds is not None:
                fr.note_dv(dv)                              # 速度窗按拍推进|Yang.zj+ 2026.11.03.161533
            continue
        lost_run = 0

        # 首帧对一致性检查:前2帧须差≤100丝才一起喂入;狂跳杂波(|Δ|>100/帧)进不了参照
        # 攒对期间暂存帧1,帧2到来时配对:成功→两帧一起feed+输出帧2;失败→帧2变新帧1
        # 与FlyRemover内部的首帧逻辑配合:配对成功后正常走feed的xStarted分支
        # |Yang.zj+ 2026.11.06.163802
        if not fr.started:
            if not hasattr(fr, '_pair_buf') or fr._pair_buf is None:
                fr._pair_buf = x  # 暂存帧1
                rows.append((i, x, cell_spd, cell_roll, cell_dec, "首帧", x, "", "", ""))
                if decs is not None: fr.note_adj(sig)
                if speeds is not None: fr.note_dv(dv)
                continue
            else:
                if abs(x - fr._pair_buf) <= 100.0:
                    # 配对成功:帧1和帧2一起喂入
                    fed += 1
                    fr.feed(fr._pair_buf, idx=fed)
                    fed += 1
                    y, flag = fr.feed(x, idx=fed)
                    fr._pair_buf = None
                    rows.append((i, x, cell_spd, cell_roll, cell_dec, flag, round(y, 2),
                                 "" if fr.dbg_sigma is None else round(fr.dbg_sigma, 4),
                                 "" if fr.dbg_a is None else round(fr.dbg_a, 4),
                                 "" if fr.dbg_b is None else round(fr.dbg_b, 4)))
                    if decs is not None: fr.note_adj(sig)
                    if speeds is not None: fr.note_dv(dv)
                    continue
                else:
                    fr._pair_buf = x  # 不配对:帧2变新帧1
                    rows.append((i, x, cell_spd, cell_roll, cell_dec, "首帧", x, "", "", ""))
                    if decs is not None: fr.note_adj(sig)
                    if speeds is not None: fr.note_dv(dv)
                    continue

        fed += 1
        y, flag = fr.feed(x, idx=fed)
        rows.append((i, x, cell_spd, cell_roll, cell_dec, flag, round(y, 2),
                     "" if fr.dbg_sigma is None else round(fr.dbg_sigma, 4),   # H列:生效σ|Yang.zj+ 2026.10.28.111107
                     "" if fr.dbg_a is None else round(fr.dbg_a, 4),           # I列:允许带下沿a
                     "" if fr.dbg_b is None else round(fr.dbg_b, 4)))          # J列:允许带上沿b
        if fr.events:
            events.extend(fr.events)
            fr.events = []
        if flag == "飞点(锁存)":
            events.append(f"帧{i:4d}  x={x:g}  → 飞点, 替换{y:g}")
        elif flag == "阶跃(确认)":
            events.append(f"帧{i:4d}  x={x:g}  → 阶跃确认, 历史重建于{x:g}, "
                          f"观察{QUAR_N}帧后输出跟随")
        if decs is not None:
            fr.note_adj(sig)  # 本拍有效信号入窗,feed之后调用保证只含"已过去的指令"|Yang.zj+ 2026.11.04.141007
        if speeds is not None:
            fr.note_dv(dv)  # 本拍Δv入窗(同防反灌时序)|Yang.zj+ 2026.11.03.161533
    return rows, events


# ---------------- 数据读取(表头关键词自动定位/相邻列回退, 中文表头自动跳过) ----------------
# 三列定位:先精确匹配用户原文件的绝对准确表头,匹配不到再按短关键词模糊兜底|Yang.zj+ 2026.11.03.091836
_HDR_EXACT = ("跟踪前一色纵向误差", "压辊", "解耦量@黄", "速度", "让料头(接料就输出)", "纵向计算调整量")
_HDR_FUZZY = (("跟踪前一色", "原始值"), ("压辊",), ("解耦量",), ("速度",), ("接料就输出",), ("纵向计算调整",))
# 兜底短关键词;误差列双候选:"跟踪前一色"(原文件)或"原始值"(本工具的结果文件可直接重跑);
# 让料头列用"接料就输出"兜底而非"让料头"——原文件另有恒0的"让料头"和"纵让料头"列,不能用;
# 调整量列用"纵向计算调整"兜底(区分横向)|Yang.zj+ 2026.11.04.141007

def _find_col(header):
    """表头→(误差,压辊,解耦,速度,让料头,调整量)列索引;先全名相等后模糊包含,均未命中为None;
    每列支持多个候选关键词(按序尝试)"""
    cols = [None, None, None, None, None, None]
    for keys, exact in ((_HDR_EXACT, True), (_HDR_FUZZY, False)):
        for idx, h in enumerate(header):
            if not isinstance(h, str):
                continue
            for j, cands in enumerate(keys):
                if cols[j] is not None:
                    continue
                cands = (cands,) if isinstance(cands, str) else cands
                if any((exact and h == k) or (not exact and k in h) for k in cands):
                    cols[j] = idx
        if all(c is not None for c in cols):
            break
    return cols

def load_values(path, col=0):
    """读取误差/压辊/解耦量/速度/让料头/调整量六列→(vals, rollers, decs, speeds, lhs, adjs)。
    列定位:优先精确匹配表头,模糊兜底,无表头回退相邻列 col/col+1..col+5(简测格式)。
    rollers=压辊(沿复位), speeds=速度(Δv第四支路), lhs=让料头(接料透传+复位),
    decs=解耦量μm, adjs=调整量μm——第三支路取 max(|调整量|,|解耦量|) 作为"机器在动"
    的有效信号(2026.11.04:60文件实测176→148帧,调整量捕获本组控制器响应、解耦量捕获
    上游传播效应,两者互补取最大;详见修改记录);均可缺(None),无列时行为与原版一致
    |Yang.zj+ 2026.11.04.141007"""
    ext = os.path.splitext(path)[1].lower()
    vals, rollers, decs, speeds, lhs, adjs = [], [], [], [], [], []
    c_err = c_roll = c_dec = c_spd = c_lh = c_adj = None
    if ext == ".xlsx":
        import openpyxl
        wb = openpyxl.load_workbook(path, read_only=True)
        ws = wb.worksheets[0]
        all_rows = list(ws.iter_rows(values_only=True))
        if all_rows:
            c_err, c_roll, c_dec, c_spd, c_lh, c_adj = _find_col(all_rows[0])
        for row in all_rows:
            try:
                vals.append(float(row[c_err if c_err is not None else col]))
            except (TypeError, ValueError, IndexError):
                continue
            for lst, cc in ((rollers, c_roll), (decs, c_dec), (speeds, c_spd),
                            (lhs, c_lh), (adjs, c_adj)):
                try:
                    lst.append(float(row[cc if cc is not None else col + (5 if lst is adjs else 4 if lst is lhs else 3 if lst is speeds else 2 if lst is decs else 1)]))
                except (TypeError, ValueError, IndexError):
                    lst.append(None)
    else:
        for enc in ("utf-8-sig", "gb18030", "utf-8"):
            try:
                with open(path, encoding=enc) as f:
                    lines = [r for r in csv.reader(f)]
                break
            except UnicodeDecodeError:
                lines = []
                continue
        if lines:
            c_err, c_roll, c_dec, c_spd, c_lh, c_adj = _find_col(lines[0])
        for row in lines:
            if len(row) <= (c_err if c_err is not None else col):
                continue
            try:
                vals.append(float(row[c_err if c_err is not None else col]))
            except ValueError:
                continue
            r = d = s = l = a = None
            try:
                r = float(row[c_roll if c_roll is not None else col + 1])
            except (ValueError, IndexError):
                pass
            try:
                d = float(row[c_dec if c_dec is not None else col + 2])
            except (ValueError, IndexError):
                pass
            try:
                s = float(row[c_spd if c_spd is not None else col + 3])
            except (ValueError, IndexError):
                pass
            try:
                l = float(row[c_lh if c_lh is not None else col + 4])
            except (ValueError, IndexError):
                pass
            try:
                a = float(row[c_adj if c_adj is not None else col + 5])
            except (ValueError, IndexError):
                pass
            rollers.append(r)
            decs.append(d)
            speeds.append(s)
            lhs.append(l)
            adjs.append(a)
    if not vals:
        raise RuntimeError("未读到数值数据——请确认文件为单列误差值(中文表头/空行会自动跳过)")
    return vals, rollers, decs, speeds, lhs, adjs


# ---------------- 统计与结果文件 ----------------
def make_stats(vals, rows, mode, k):
    ok = [v for v in vals if v != LOST]
    outs = [r[6] for r in rows if isinstance(r[6], float)]
    n_fly = sum(1 for r in rows if r[5] in ("飞点", "飞点(锁存)"))
    n_hold = sum(1 for r in rows if r[5] == "暂缓(锁存)")
    head = f"总帧数 {len(vals)}  丢失帧 {sum(1 for v in vals if v == LOST)}  " \
           f"飞点 {n_fly + n_hold}" + (f"(含暂缓{n_hold})" if n_hold else "")
    if mode == "online":
        head += f"  阶跃 {sum(1 for r in rows if isinstance(r[5], str) and r[5].startswith('阶跃'))}"
        n_tr = sum(1 for r in rows if r[5] == "趋势确认")   # 三点趋势确认|2026.10.28.170000
        if n_tr:
            head += f"  趋势确认 {n_tr}"
    mode_txt = ("批式MAD: 中值+1.4826×MAD迭代剔除, 飞点行留空" if mode == "batch"
                else f"在线链式(因果): Theil-Sen趋势带+差分σ+双门槛迟滞 "
                     f"(外门槛={k:g}σ, 回归={RET_FRAC * k:g}σ)")
    sig = (f"原始σ {st.pstdev(ok):.2f} → 剔除后σ {st.pstdev(outs):.2f}"
           if len(ok) > 1 and len(outs) > 1 else "σ: 数据过少, 未统计")
    return [head, f"方式 {mode_txt}", sig]


def write_result(path_in, rows, events, stats):
    """输出 剔除后_<文件名>_<HHMMSS>.xlsx: 数据A~J列(序号/原始值/速度/压辊/解耦量/判定/
    剔除后输出/生效σ/带a/带b——速度/压辊/解耦量附在原始值后方便对照,速度+压辊可推料膜速度
    |Yang.zj+ 2026.11.03.162639), 运行日志L列(K列空档隔开);
    无openpyxl环境回退csv; 文件被占用时等1秒换时间戳重存."""
    base = os.path.splitext(os.path.basename(path_in))[0]
    outdir = os.path.dirname(os.path.abspath(path_in))
    header = ["序号", "原始值", "速度", "压辊", "解耦量", "判定", "剔除后输出", "σ(生效)", "带a", "带b"]
    logs = ["—— 事件 ——"] + (events if events else ["(无)"]) + \
           ["", "—— 统计 ——"] + list(stats)

    def _name(ext):
        return os.path.join(outdir, f"剔除后_{base}_{time.strftime('%H%M%S')}.{ext}")

    try:
        import openpyxl
        from openpyxl.styles import Font, PatternFill
    except ImportError:
        out_csv = _name("csv")
        with open(out_csv, "w", newline="", encoding="utf-8-sig") as f:
            w = csv.writer(f)
            w.writerow(header)
            w.writerows(rows)
            for e in events:
                w.writerow(["# " + e])
            for s in stats:
                w.writerow(["# " + s])
        return out_csv

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "剔除结果"
    ws.append(header)
    ws.cell(row=1, column=12, value="运行日志")   # 日志在L列(K列空档隔开)|Yang.zj+ 2026.11.03.162639
    for c in ws[1]:
        c.font = Font(bold=True, color="FFFFFF")
        c.fill = PatternFill("solid", fgColor="2E6FB7")
    for r in rows:
        ws.append(r)
    for rr, txt in enumerate(logs, 2):
        ws.cell(row=rr, column=12, value=txt)
    for col, wd in zip("ABCDEFGHIJKL", (8, 12, 9, 8, 12, 16, 14, 10, 10, 10, 3, 100)):
        ws.column_dimensions[col].width = wd
    try:
        out = _name("xlsx")
        wb.save(out)
    except PermissionError:
        time.sleep(1)
        out = _name("xlsx")
        wb.save(out)
    return out


# ---------------- CLI ----------------
def run_cli(path, col=0, mode="batch", k=5.0, confirm=STEP_CONFIRM, trend=1, flat=1):
    vals, rollers, decs, speeds, lhs, adjs = load_values(path, col)
    if mode == "batch":
        rows, events = run_batch(vals, k)
    else:
        rows, events = run_online(vals, k, confirm, trend_confirm=bool(trend),
                                  flat_band=bool(flat), rollers=rollers, decs=decs,
                                  speeds=speeds, adjs=adjs)  # 让料头已回退:接料期间误差由飞点算法正常处理|Yang.zj+ 2026.11.09.144724
    stats = make_stats(vals, rows, mode, k)
    out = write_result(path, rows, events, stats)
    print("\n".join(stats))
    print("事件:")
    for e in events:
        print("  " + e)
    print(f"\n结果文件: {out}")
    try:
        os.startfile(out)
    except Exception:
        pass
    return out


# ---------------- GUI ----------------
def run_gui():
    import queue
    import threading
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox

    class App(tk.Tk):
        def __init__(self):
            super().__init__()
            self.title("飞点剔除 — 批式MAD / 在线链式(趋势带·因果)")
            self.geometry("760x540")
            self.q = queue.Queue()

            frm = ttk.Frame(self, padding=8)
            frm.pack(fill="x")
            frm.columnconfigure(1, weight=1)
            ttk.Label(frm, text="数据文件(误差列+可选第2列压辊,中文表头)").grid(row=0, column=0, sticky="w")
            self.e_file = ttk.Entry(frm)
            self.e_file.grid(row=0, column=1, sticky="ew", pady=2)
            ttk.Button(frm, text="浏览…", command=self.browse).grid(row=0, column=2, padx=4)

            p = ttk.Frame(frm)
            p.grid(row=1, column=0, columnspan=3, sticky="w", pady=4)
            ttk.Label(p, text="方式").pack(side="left")
            self.mode = tk.StringVar(value="batch")
            ttk.Radiobutton(p, text="批式MAD(飞点留空,适合平稳段)",
                            variable=self.mode, value="batch").pack(side="left")
            ttk.Radiobutton(p, text="在线链式(严格因果,可上实时)",
                            variable=self.mode, value="online").pack(side="left", padx=(8, 0))
            p2 = ttk.Frame(frm)
            p2.grid(row=2, column=0, columnspan=3, sticky="w")
            ttk.Label(p2, text="门限K(外门槛,回归=0.5K)").pack(side="left")
            self.e_k = ttk.Entry(p2, width=5)
            self.e_k.insert(0, "5.0")
            self.e_k.pack(side="left", padx=2)
            ttk.Label(p2, text="阶跃确认(帧,默认2)").pack(side="left", padx=(8, 0))
            self.e_conf = ttk.Entry(p2, width=5)
            self.e_conf.insert(0, str(STEP_CONFIRM))
            self.e_conf.pack(side="left", padx=2)
            self.trend = tk.BooleanVar(value=True)
            ttk.Checkbutton(p2, text="三点趋势确认(开机/调整期连续变化快速跟随)",
                            variable=self.trend).pack(side="left", padx=8)   # |2026.10.28.170000
            self.flat = tk.BooleanVar(value=True)
            ttk.Checkbutton(p2, text="水平带(斜率≥3点)",
                            variable=self.flat).pack(side="left", padx=8)    # |2026.10.28.220000
            ttk.Label(p2, text="(其余参数见脚本头部, 一般不改)").pack(side="left", padx=8)

            self.b_run = ttk.Button(self, text="▶ 运行并生成结果文件", command=self.run)
            self.b_run.pack(pady=4)
            self.txt = tk.Text(self, height=17, font=("Consolas", 10), wrap="none")
            self.txt.pack(fill="both", expand=True, padx=8)
            self.status = ttk.Label(self, text="就绪", anchor="w", relief="sunken", padding=(6, 3))
            self.status.pack(fill="x", side="bottom")
            self.after(100, self._poll)

        def browse(self):
            p = filedialog.askopenfilename(title="选择单列误差数据",
                                           filetypes=[("csv/xlsx", "*.csv *.xlsx"),
                                                      ("所有文件", "*.*")])
            if p:
                self.e_file.delete(0, "end")
                self.e_file.insert(0, p)

        def run(self):
            path = self.e_file.get().strip()
            if not path or not os.path.exists(path):
                messagebox.showerror("文件", "请先选择存在的数据文件")
                return
            try:
                k = float(self.e_k.get())
                conf = int(self.e_conf.get())
            except ValueError:
                messagebox.showerror("参数", "门限K/阶跃确认须为数字")
                return
            self._trend = self.trend.get()
            self._flat = self.flat.get()
            self.b_run.config(state="disabled")
            self.status.config(text="处理中…")
            self.txt.delete("1.0", "end")
            threading.Thread(target=self._worker,
                             args=(path, self.mode.get(), k, conf), daemon=True).start()

        def _worker(self, path, mode, k, conf):
            try:
                vals, rollers, decs, speeds, lhs, adjs = load_values(path)
                if mode == "batch":
                    rows, events = run_batch(vals, k)
                else:
                    rows, events = run_online(vals, k, conf, trend_confirm=self._trend,
                                              flat_band=self._flat, rollers=rollers,
                                              decs=decs, speeds=speeds,
                                              adjs=adjs)  # 让料头已回退|Yang.zj+ 2026.11.09.144724
                stats = make_stats(vals, rows, mode, k)
                out = write_result(path, rows, events, stats)
                self.q.put(("ok", (out, stats, events, len(vals))))
            except Exception as e:
                self.q.put(("err", str(e)))

        def _poll(self):
            try:
                kind, payload = self.q.get_nowait()
            except queue.Empty:
                payload = None
            if payload:
                self.b_run.config(state="normal")
                if kind == "err":
                    self.status.config(text="失败")
                    messagebox.showerror("处理失败", payload)
                else:
                    out, stats, events, n = payload
                    self.txt.insert("end", f"读入 {n} 帧\n" + "\n".join(stats) + "\n\n事件:\n")
                    self.txt.insert("end", "\n".join("  " + e for e in events) or "  (无)")
                    self.txt.insert("end", f"\n\n结果文件已生成并打开:\n{out}\n")
                    self.status.config(text=f"完成: {os.path.basename(out)}")
                    try:
                        os.startfile(out)
                    except Exception:
                        pass
                self.txt.see("end")
            self.after(100, self._poll)

    App().mainloop()


if __name__ == "__main__":
    if len(sys.argv) >= 2:
        col = int(sys.argv[2]) if len(sys.argv) >= 3 else 0
        mode = sys.argv[3] if len(sys.argv) >= 4 else "batch"
        k = float(sys.argv[4]) if len(sys.argv) >= 5 else 5.0
        conf = int(sys.argv[5]) if len(sys.argv) >= 6 else STEP_CONFIRM
        trend = int(sys.argv[6]) if len(sys.argv) >= 7 else 1
        flat = int(sys.argv[7]) if len(sys.argv) >= 8 else 1
        run_cli(sys.argv[1], col, mode, k, conf, trend, flat)
    else:
        run_gui()
