# -*- coding: utf-8 -*-
"""色标质量计算模块 —— 参照实现 (与ARM C版逐行对应, 交叉验证15帧×12字段通过)
管线: 正向化→滤波→稳健峰→固件向三档交点→固定窗噪声σ→jp分级→沿线性度→沿回归R²
      →ΔW表偏差→连续可信度Q→qBits/qLevel装配→表更新(仅干净帧)
每标一个 MarkQuality 实例(携带ΔW表/wJit状态), 逐帧喂入 process()
"""
import math
import numpy as np

# ---------- 可调参数(标定依据见 docs/横向误差改进/06_质量指标公式手册.md §12) ----------
PAR = dict(
    jp_l0l1=3.0, jp_l1l2=15.0,      # 交点抖动预测分级(丝)
    dw_rej_si=12.0,                  # ΔW表更新拒绝门限(丝)
    dw_ewma=16,                      # EWMA时间常数(帧)
    lin_rej_si=8.0,                  # 沿线性度门限(丝)
    r2_warn=0.99, r2_bad=0.95,       # R²双档
    reg_band=(0.30, 0.70),           # 回归带
    noise_min_pts=60,                # 噪声窗最少点数
    blk_len=48,                      # 噪声分块长度(点)@2.77mm物理带宽, 粗采按§16换算
    rpeak_k=5,                       # 稳健峰top-k
    reg_en=True,                     # 沿回归指标使能(粗采样下置False)
    tau_si=5.0,                      # 可信度公差τ(丝): Q=P(|ΔW|≤τ)
    quant_lsb=4.0,                   # 精采样量化码@LSB(数据为4整倍数): MAD/σ下限
                                     # 治本2026.11.12: 防钉零+量化毛刺噪声下MAD塌底→整窗误拒
)

def smooth3e(x):
    xp = np.concatenate(([x[0]], x, [x[-1]]))
    return (xp[:-2] + xp[1:-1] + xp[2:]) / 3.0

def rpeak(y, k=None):
    k = k or PAR["rpeak_k"]
    return float(np.median(np.sort(y)[-k:]))

def fw_crossings(y, scope):
    """固件方向三档交点: 从峰向两侧最近穿阈点, 亚点插值"""
    pk = int(np.argmax(y)); res = {}
    for r in (0.25, 0.5, 0.75):
        lvl = scope * r
        f = b = None
        for i in range(pk, 0, -1):
            if y[i] >= lvl > y[i-1]:
                f = (i-1) + (lvl-y[i-1])/(y[i]-y[i-1]); break
        for i in range(pk, len(y)-1):
            if y[i] >= lvl > y[i+1]:
                b = i + (y[i]-lvl)/(y[i]-y[i+1]); break
        res[r] = (f, b)
    return res

class MarkQuality:
    """单色标质量状态机: ΔW表 + wJit + 逐帧指标 + 可信度Q + qBits/qLevel"""

    def __init__(self, si_per_pt, dw_init=None):
        self.si = si_per_pt
        self.dw25 = dw_init[0] if dw_init else None
        self.dw75 = dw_init[1] if dw_init else None
        self.dw_frames = 0
        self.sigma_last = None
        self.w_prev = None
        self.wjit = None
        self.wjit_base = None
        self.clean_cnt = 0
        self.l2_streak = 0

    # ---- 内部: 噪声窗(门级空隙 + 分块去趋势σ, 与C逐位一致) ----
    def _noise_sigma(self, gate, center, pitch, cr, margin=25):
        f25, b25 = cr[0.25]
        if f25 is not None and b25 is not None:
            half_base = (b25 - f25) * 1.0 + margin
        else:
            half_base = pitch * 0.25
        # 注意: 先浮点加减后截断(勿先截断half_base, 与C一致)
        g0 = max(0, int(center - pitch + half_base))
        g1 = int(max(g0 + 1, center - half_base))
        g2 = int(min(len(gate) - 1, center + half_base))
        g3 = min(len(gate), int(center + pitch - half_base))
        seg = np.concatenate([gate[g0:g1], gate[g2:g3]])
        if len(seg) < PAR["noise_min_pts"]:
            return None, len(seg)
        BL = PAR["blk_len"]
        resid = []
        for sub in (gate[g0:g1], gate[g2:g3]):      # 按段分块不拼接(与C一致)
            for i in range(len(sub) // BL):
                blk = sub[i*BL:(i+1)*BL]
                bm = np.sort(blk)[len(blk)//2]        # 上中位(与C一致)
                resid.extend(np.abs(blk - bm))
        resid = np.array(resid)
        mad = np.sort(resid)[len(resid)//2]           # 单遍MAD
        if mad < PAR["quant_lsb"]:                    # 量化下限治本2026.11.12
            mad = PAR["quant_lsb"]
        keep = resid <= 3.5 * 1.4826 * mad
        if keep.sum() < 40 or keep.sum() < 0.6*len(resid):
            return None, -len(resid)
        sigma = 1.4826 * np.sort(resid[keep])[int(keep.sum())//2]
        return max(sigma, PAR["quant_lsb"]), int(keep.sum())

    # ---- 内部: 沿回归 ----
    def _edge_reg(self, y, scope):
        pk = int(np.argmax(y))
        lo, hi = scope*PAR["reg_band"][0], scope*PAR["reg_band"][1]
        L, R = y[:pk+1], y[pk:]
        m1 = (L >= lo) & (L <= hi); m2 = (R >= lo) & (R <= hi)
        out = dict(reg_w=None, r2=None, n1=int(m1.sum()), n2=int(m2.sum()))
        if m1.sum() < 4 or m2.sum() < 4:
            return out
        def fit(yv, xv):
            n = len(yv); sy = yv.sum(); syy = (yv*yv).sum()
            sx = xv.sum(); sxy = (xv*yv).sum()
            den = n*syy - sy*sy
            if abs(den) < 1e-9: return None
            k = (n*sxy - sx*sy)/den; c = (sx-k*sy)/n
            res = xv - (c + k*yv)
            r2 = 1 - (res*res).sum()/max(((xv-xv.mean())**2).sum(), 1e-9)
            return k, c, r2
        c1 = fit(L[m1], np.flatnonzero(m1)*1.0)
        c2 = fit(R[m2], (pk+np.flatnonzero(m2))*1.0)
        if c1 and c2:
            lvl = scope*0.5
            out["reg_w"] = (c2[1]+c2[0]*lvl) - (c1[1]+c1[0]*lvl)
            out["r2"] = min(c1[2], c2[2])
        return out

    # ---- 主入口 ----
    def process(self, gate_raw, center, pitch, polarity="auto",
                seg_half=170, margin=25, recenter=60):
        """gate_raw: 整门原始数据(未滤波, 极性任意)
        polarity: "neg"=反极性(喂原始) | "pos"=正极性 | "raw"=已正向化 | "auto"=统计(仅离线)
        seg_half/margin/recenter: 点数域参数, 粗采样按手册§16物理换算"""
        gate_raw = np.asarray(gate_raw, float)
        if polarity == "raw":
            gate_pos = gate_raw          # 调用方已正向化(与C模块pwGate约定一致), 不再扣基线
        else:
            base = np.median(gate_raw)
            d = gate_raw - base
            if polarity == "neg" or (polarity == "auto" and abs(d.min()) > abs(d.max())):
                d = -d
            gate_pos = d
        c = int(center) - recenter + int(np.argmax(gate_pos[max(0, int(center)-recenter):int(center)+recenter]))
        c = int(np.clip(c, seg_half, len(gate_pos) - seg_half - 1))
        y_raw = gate_pos[c-seg_half:c+seg_half+1]
        y = smooth3e(y_raw)
        scope = rpeak(y)
        cr = fw_crossings(y, scope)
        widths = {r: (cr[r][1]-cr[r][0]) if (cr[r][0] is not None and cr[r][1] is not None) else None
                  for r in (0.25, 0.5, 0.75)}
        all3 = all(v is not None for v in widths.values())
        # firmware选档 0.5→0.25→0.75
        fw_w = fw_lvl = None
        for r in (0.5, 0.25, 0.75):
            if widths[r] is not None:
                fw_w, fw_lvl = widths[r], r; break
        # 噪声/SNR
        sigma, _npts = self._noise_sigma(gate_pos, c, pitch, cr, margin=margin)
        noise_inv = sigma is None
        if noise_inv:
            sigma = self.sigma_last if self.sigma_last else 1.0
        else:
            self.sigma_last = sigma
        snr = scope / max(sigma, 1e-6)
        # 斜率与交点抖动预测
        f25, b25 = cr[0.25]; f50, b50 = cr[0.5]; f75, b75 = cr[0.75]
        slope_min = None
        if None not in (f25, f75, b25, b75) and (f75-f25) > 1e-6 and (b25-b75) > 1e-6:
            slope_min = min(0.5*scope/(f75-f25), 0.5*scope/(b25-b75))
        jp = (2.0*sigma/slope_min*self.si) if (slope_min and slope_min > 1) else None
        # 沿线性度
        lin = None
        if all3:
            worst = 0.0
            for side in (0, 1):
                lv = np.array([r for r in (0.25, 0.5, 0.75)]) * scope
                xs = np.array([cr[r][side] for r in (0.25, 0.5, 0.75)])
                k, cc = np.polyfit(lv, xs, 1)
                worst = max(worst, float(np.max(np.abs(xs-(k*lv+cc)))))
            lin = worst * self.si
        # 沿回归(reg_en=False时r2与reg_fb均不参与, 粗采模式)
        reg = self._edge_reg(y, scope)
        r2 = reg["r2"] if PAR["reg_en"] else None
        reg_w_si = reg["reg_w"]*self.si if reg["reg_w"] is not None else None
        reg_fb = (reg["reg_w"] is None) if PAR["reg_en"] else False
        # ΔW偏差
        dev25 = dev75 = None
        if all3 and self.dw25 is not None:
            dev25 = (widths[0.25]-widths[0.5]-self.dw25)*self.si
            dev75 = (widths[0.75]-widths[0.5]-self.dw75)*self.si
        # ---- 分级与判定 ----
        if jp is None:
            snr_level = 1
        else:
            snr_level = 0 if jp <= PAR["jp_l0l1"] else (1 if jp <= PAR["jp_l1l2"] else 2)
        if snr_level == 2:
            self.l2_streak += 1
        else:
            self.l2_streak = 0
        shape_ir = False
        if dev25 is not None and abs(dev25) > PAR["dw_rej_si"]: shape_ir = True
        if dev75 is not None and abs(dev75) > PAR["dw_rej_si"]: shape_ir = True
        if all3 and self.dw25 is not None and lin is not None and lin > PAR["lin_rej_si"]:
            shape_ir = True
        if not all3 and fw_lvl != 0.5 and self.dw25 is not None:
            shape_ir = True
        r2_bad = (r2 is not None and r2 < PAR["r2_bad"])
        r2_warn = (r2 is not None and r2 < PAR["r2_warn"])
        # qLevel
        if (snr_level == 2 and self.l2_streak >= 3) or shape_ir or r2_bad:
            q = 3
        elif snr_level >= 1 or r2_warn or reg_fb or noise_inv:
            q = 2
        elif fw_lvl is not None and fw_lvl != 0.5:
            q = max(1, 2 if (self.dw25 is None) else 1)
        else:
            q = 0
        # 滚动宽度抖动 wJit
        wjit_alarm = False
        if fw_w is not None:
            if self.w_prev is not None:
                dw_abs = abs(fw_w - self.w_prev) * self.si
                self.wjit = dw_abs if self.wjit is None else self.wjit + (dw_abs-self.wjit)/8.0
            self.w_prev = fw_w
        if q <= 1:
            self.clean_cnt += 1
            if self.clean_cnt == 8 and self.wjit is not None:
                self.wjit_base = self.wjit
        if self.wjit_base is not None and self.wjit is not None:
            if self.wjit > max(3.0*self.wjit_base, 3.0):
                wjit_alarm = True
                q = max(q, 2)
        # ---- 连续可信度 Q∈[0,100] ----
        # 随机项: Qn = P(|ΔW|≤τ) = erf(τ/(jp√2))·100  (jp即宽度测量预测σ)
        if jp is not None and jp > 0:
            Qn = math.erf(min(PAR["tau_si"] / (jp * math.sqrt(2.0)), 3.0)) * 100.0
        else:
            Qn = 26.0  # jp=None(slope不可估)→保守(2026.11.12曾改100后回退,治本走quant_lsb下限)
        # 形状项: logistic, 门限处=50分
        dv = 0.0
        if dev25 is not None: dv = max(dv, abs(dev25))
        if dev75 is not None: dv = max(dv, abs(dev75))
        # 表未建: 形状无从校验→中性100不罚(冷启动帧), 档位侧由lvlUncal位表达
        dv = min(dv, 60.0)
        Qd = 100.0 / (1.0 + (dv / PAR["dw_rej_si"]) ** 4)
        lv2 = lin if (lin is not None and self.dw25 is not None) else 0.0
        Ql = 100.0 / (1.0 + (lv2 / PAR["lin_rej_si"]) ** 4)
        # 拟合项: R²=0.99处=50分; 回归禁用→中性100
        Qr = 100.0
        if PAR["reg_en"] and r2 is not None:
            Qr = 100.0 / (1.0 + (max(0.0, 0.99 - r2) / 0.015) ** 4)
        # 趋势项: 报警线处=50分; 基线未建→中性
        Qw = 100.0
        if self.wjit_base is not None and self.wjit is not None:
            thr_w = max(3.0*self.wjit_base, 3.0)
            Qw = 100.0 / (1.0 + (self.wjit / thr_w) ** 4)
        q_score = Qn * Qd * Ql * Qr * Qw / 100.0**4
        # qBits
        qb = 0
        qb |= min(int(scope/655.35), 127)
        qb |= snr_level << 7
        if fw_lvl is not None and fw_lvl != 0.5: qb |= 1 << 9
        if fw_lvl is not None and fw_lvl != 0.5 and self.dw25 is None: qb |= 1 << 10
        if fw_lvl is not None and fw_lvl != 0.5 and self.dw25 is not None: qb |= 1 << 11
        if reg_fb: qb |= 1 << 12
        if r2_warn: qb |= 1 << 13
        if shape_ir: qb |= 1 << 14
        if wjit_alarm: qb |= 1 << 15
        # 表更新(仅干净帧; 建表帧免dev条件)
        tbl_upd = False
        if q <= 1 and all3 and abs(dev25 if dev25 is not None else 0) <= PAR["dw_rej_si"] \
                and abs(dev75 if dev75 is not None else 0) <= PAR["dw_rej_si"]:
            d25 = widths[0.25]-widths[0.5]; d75 = widths[0.75]-widths[0.5]
            if self.dw25 is None:
                self.dw25, self.dw75 = d25, d75
            else:
                a = 1.0/PAR["dw_ewma"]
                self.dw25 += (d25-self.dw25)*a
                self.dw75 += (d75-self.dw75)*a
            self.dw_frames += 1
            tbl_upd = True
        # 回退补偿输出
        w50comp = fw_w
        if fw_lvl is not None and fw_lvl != 0.5 and self.dw25 is not None and fw_w is not None:
            w50comp = fw_w - (self.dw25 if fw_lvl == 0.25 else self.dw75)
        return dict(scope=scope, snr=snr, snr_level=snr_level, sigma=sigma,
                    widths={r: (v*self.si if v is not None else None) for r, v in widths.items()},
                    fw_w=fw_w*self.si if fw_w is not None else None, fw_lvl=fw_lvl,
                    dev25=dev25, dev75=dev75, lin=lin, r2=r2, reg_w=reg_w_si,
                    reg_fb=reg_fb, shape_ir=shape_ir, qBits=qb, qLevel=q,
                    jp=jp, q_score=q_score, Qn=Qn, Qd=Qd, Ql=Ql, Qr=Qr, Qw=Qw,
                    wjit=self.wjit, wjit_base=self.wjit_base, wjit_alarm=wjit_alarm,
                    w50comp=w50comp*self.si if w50comp is not None else None,
                    tbl_upd=tbl_upd, dw_frames=self.dw_frames, noise_inv=noise_inv)
