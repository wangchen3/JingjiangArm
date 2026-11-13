# 双置信度融合误差迁移到 8.4 架构（编译期宏 KS_USE_CONF_ERR）

## Context

老架构ARM（`老架构ARM/Slave_stm32_ARM`）已实现"双置信度融合误差"功能：每圈给误差打 0~1 置信度 F，按 `out_k = F·E_k + (1−F)·out_{k-1}` 变权上报（可信圈紧跟测量、不可信圈趋向历史值）。老架构的开关是**运行期变量**（485 屏 46059 bit3观察/bit4接入 双态下发）。用户要求把该功能迁移到当前 8.4 工程，**不要运行期开关，改为单一编译期宏**，且**置信度直接纳入误差链路**（显示与误差计算不分家）。

调研已确认两边同源、接口完全兼容：`StSignalParsingGroupDetail`/`StCalcParam_Out`/`StCalcParam_In` 字段同名同维，`StAxisParam`（byColorIdCurrent/byFollowColorId/wStatusRef）一致，`MARK_ARRANGE_VFOR/VREV` 值一致，`KS_CalcError_ARC` 后的挂点结构两边同构（NoteDv 块已互为镜像）。**ks_conf_err.c 算法代码可零适配编译。**

## 改动清单

### 1. 新增 `Kesai_Process/ks_conf_err.h`（自老架构移植，去开关化）

- 顶部仿照 `ks_fly_remove.h:26` 的 `KS_USE_NEW_FLY_REMOVE` 惯例加总开关：
  ```c
  #define KS_USE_CONF_ERR 1  //1=置信度融合误差直接接入上报链路;0=完全回退原行为,重新编译即可
  ```
- **删除** `xEnableConfErr`/`xSwitchWrEn` 两个运行期开关声明（及 .c 中定义）
- 保留：`rConfS50Mm`（CK尺度参数，默认 0.08mm，调试器可调，非开关）、`rConfLastRevV/H`（每圈置信度记录 0~100，调试观察用）、`KS_ConfErr_Reset/Process/GetV/GetH` 接口
- 文件头注释改写：说明移植来源（老架构ARM 2026.11.12 版）、本工程为编译期宏接入、去掉485显示挂点。注释带 `|Yang.zj+ 2026.11.13.HHMMSS 置信度迁移...` 戳

### 2. 新增 `Kesai_Process/ks_conf_err.c`（算法逐行保留）

- `ks_conf_qselect`/`ks_conf_note_ck`/`ks_conf_calc_qn`/`ks_conf_pick_streams`/`ks_conf_ck_conf`/`ks_conf_qn_conf`/`ks_conf_blend`/`KS_ConfErr_Process` 全部**原样移植**（含 2026.11.10 噪声窗对称/幅值门槛、2026.11.12 量化下限治本、快速选择等全部修订）
- 仅删：开关变量定义、开关相关注释；`Process` 内部逻辑不变（排列/色序/双波门变化自复位 CK 历史，混合递推保留）
- 13.2KB 静态缓冲（`s_afQnResid[3000]`+`s_afQnBlk[256]`）原样保留

### 3. 修改 `Kesai_Process/KS_FB_ProSample.c`（两处挂点）

**挂点① 每圈计算**——`KS_CalcError_ARC` + NoteDv 块之后（当前 :383 `#endif` 后、`arBase_use` 写回前）：
```c
#if KS_USE_CONF_ERR
	//双置信度融合:每圈老链计算完成后运行,宏=1时融合误差直接替换上报(无观察态)
	KS_ConfErr_Process(i_pstStAxisParam, &stStCalcParam_In, &stStCalcParam_Out);
#endif
```
（不带老架构的 DWT 探针——那是它的耗时测量工具）

**挂点② 误差链路接入**——else 有效分支两处替换（当前 :594、:624）：
```c
#if KS_USE_CONF_ERR
	i_pstStPara_PduBroadcastUp->iVerror = KS_ConfErr_GetV();   //横向同理 KS_ConfErr_GetH()
#else
	i_pstStPara_PduBroadcastUp->iVerror = stStCalcParam_Out.o_iVResult;
#endif
```
- 丢失分支（三幅丢失上报逻辑 :568-582）**不动**：置信度丢失圈本来直通 -32768，口径天然一致
- 报警判断（:601-605）、下游人机显示平均 `KS_Average`（吃替换后的 iVerror）自动跟随融合值——显示与误差链路不分家，与老架构双开态行为一致
- 顶部加 `#include "ks_conf_err.h"`（`#if KS_USE_CONF_ERR` 包裹）

### 4. 版本记录

- `Core/Inc/base.h:83`：DWVERSION 提号（2126102916 → 21261113XX，旧值注释保留），旁注一行置信度迁移说明
- `README/readme.txt`：顶部加一条变更记录

### 不迁移的内容

- 485 组态屏开关解析（KS_FB_VISU.c 46059 bit3/bit4）与 6206 置信度显示寄存器——新架构无此需求且用户明确不要观察态
- `mark_quality.py`/`色标质量评估.py` 验证脚本（留在老架构）
- DWT 耗时探针

## 资源开销与风险

- RAM +≈13.2KB（F412 共 256KB，构建后从 .map 核对余量）
- Flash 新增约 4~5KB（Release -Os），构建后核对升级分区上限（老架构教训：Debug -O0 会膨胀超限，**必须 Release 配置**）
- CPU：每圈一次（老架构实测远小于飞点逐帧开销）
- 宏=0 时代码完全不编译，二进制行为与现状一致，回退零风险

## 验证

1. **宏=0 回退验证**：`KS_USE_CONF_ERR=0` 构建 Release，确认零错误、代码路径与改动前一致
2. **宏=1 接入验证**：构建 Release，`.map` 中出现 `ks_conf_*` 符号；对比改动前后 .map 的 RAM/Flash 占用增量（预期 +13.2KB RAM / +几KB Flash），确认不超分区
3. **行为核验**：`KS_ConfErr_GetV()` 返回值口径检查——首圈直通、丢失圈 -32768、报警位/飞点位不受影响
4. 上机建议（用户侧）：与老架构相同方式，用 60m/min 真实数据观察融合误差与置信度记录变量（`rConfLastRevV/H` 调试器可读）