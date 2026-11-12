# -*- coding: utf-8 -*-
"""色标质量仿真 GUI — tkinter 界面
双击运行或:  py -3.13 sim_gui.py
"""
import os, sys, csv, math, threading, traceback
import tkinter as tk
from tkinter import ttk, filedialog, messagebox

import numpy as np

# 同目录导入
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mark_quality as mqm
from mark_quality import MarkQuality, smooth3e, rpeak, fw_crossings

# 尝试 matplotlib(可选, 没有也能跑)
HAS_MPL = False
try:
    import matplotlib
    matplotlib.use("TkAgg")
    from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
    from matplotlib.figure import Figure
    import matplotlib.pyplot as plt
    plt.rcParams["font.sans-serif"] = ["Microsoft YaHei", "SimHei"]
    plt.rcParams["axes.unicode_minus"] = False
    HAS_MPL = True
except ImportError:
    pass


# ═══════════════════════ 数据加载 ═══════════════════════

def load_ptwatch(fn, bipolar=False):
    rows = []
    with open(fn, encoding="utf-8", errors="replace") as fh:
        fh.readline()
        for line in fh:
            p = line.strip().split(",")
            if len(p) != 3:
                continue
            try:
                rows.append((int(p[0]), int(p[1]), int(p[2])))
            except ValueError:
                pass
    if not rows:
        raise ValueError("无法解析(需3列: 通道1,通道2,过圈标志)")
    a = np.array(rows, dtype=np.int64)
    # 双极性处理: 负值 +65535 映射到单极性域
    if bipolar:
        a[:, 0] = np.where(a[:, 0] < 0, a[:, 0] + 65535, a[:, 0])
        a[:, 1] = np.where(a[:, 1] < 0, a[:, 1] + 65535, a[:, 1])
    idx = np.flatnonzero(a[:, 2] == 1)
    starts = np.concatenate(([0], idx))
    ends = np.concatenate((idx, [len(a)]))
    lens = ends - starts
    mode = int(np.bincount(lens[lens > 1000]).argmax())
    revs = [(s, e) for s, e in zip(starts, ends) if abs((e - s) - mode) <= 3 and s > 0]
    return a[:, 0], a[:, 1], revs, mode


def positive(x, pol):
    d = x - np.median(x)
    if pol == "neg" or (pol == "auto" and abs(d.min()) > abs(d.max())):
        return -d
    return d


def polarity_of(x):
    d = x - np.median(x)
    return "neg" if abs(d.min()) > abs(d.max()) else "pos"


def find_anchor(pos, g0, g1):
    w = pos[g0:g1]
    if len(w) == 0:
        return None
    hi = np.flatnonzero(w > 0.9 * w.max())
    c = g0 + int(np.mean(hi)) if len(hi) >= 3 else g0 + int(np.argmax(w))
    return c


def measure(pos, c, seg_half):
    seg = smooth3e(pos[c - seg_half: c + seg_half + 1])
    scope = rpeak(seg)
    cr = fw_crossings(seg, scope)
    return cr, scope


# ═══════════════════════ 核心计算 ═══════════════════════

def run_simulation(filepath, g0, gw, cur_ch, pol, warmup, si_val, girth_val, pitch_mm, edge="back", bipolar=False):
    """返回 (rows, info_dict) 或抛异常"""
    t1, t2, revs, clen = load_ptwatch(filepath, bipolar=bipolar)
    # ── 楼梯换算: 版周 → N → 每圈点数 → 实际精度 ──
    # N = floor(131072 × 0.02 / girth_mm)   (固件 comm.c 取整)
    # 每圈点数 = 131072 ÷ N
    # 实际精度(丝/点) = girth / 实测圈长 × 100
    stair_info = ""
    if si_val > 0:
        si = si_val
        stair_info = f"用户直接指定 si={si:.4f}丝/点"
    elif girth_val > 0:
        N = int(131072 * 0.02 / girth_val)          # floor, 与固件一致
        expected_clen = 131072 // N                 # 楼梯理论圈长
        si = girth_val / clen * 100                 # 用实测圈长算(比理论精确)
        # 交叉验证
        if abs(clen - expected_clen) <= 2:
            stair_info = (f"版周{girth_val}mm → N={N} → 楼梯圈长{expected_clen} "
                          f"(实测{clen}✓) → si={si:.4f}丝/点")
        else:
            stair_info = (f"⚠ 版周{girth_val}mm → N={N} → 楼梯圈长{expected_clen} "
                          f"但实测圈长{clen}(差{abs(clen-expected_clen)}点) — "
                          f"版周可能不对, si按实测圈长计算={si:.4f}丝/点")
    else:
        raise ValueError("请填写 丝/点 或 版周mm")
    si_mm = si / 100.0
    pitch = max(1, int(round(pitch_mm / si_mm)))
    mqm.PAR["blk_len"] = max(16, int(round(2.77 / si_mm)))
    margin = max(10, int(round(0.8 / si_mm)))
    seg_half = max(240, int(round(5.0 / si_mm)))
    recenter = max(30, int(round(3.5 / si_mm)))
    fol_ch = "T2" if cur_ch == "T1" else "T1"
    chans = {"T1": t1, "T2": t2}

    if pol == "auto":
        # 在波门内判定极性(不用整圈, 避免被门外产品图案带歪)
        s, e = revs[min(1, len(revs)-1)]
        gate_data = chans[cur_ch][s:e].astype(float)[g0:g0+gw]
        pol = polarity_of(gate_data)

    m_cur = MarkQuality(si)
    m_fol = MarkQuality(si)
    rows = []
    warmup_done = False
    warmup_count = 0
    table_rejected = False

    for ri, (s, e) in enumerate(revs):
        if ri == 0:
            continue
        cur_pos = positive(chans[cur_ch][s:e].astype(float), pol)
        fol_pos = positive(chans[fol_ch][s:e].astype(float), pol)
        c_cur = find_anchor(cur_pos, g0, g0 + gw)
        if c_cur is None:
            rows.append(dict(rev=ri, status="门内无标"))
            continue
        c_fol = find_anchor(fol_pos, max(0, c_cur - recenter), c_cur + recenter)
        if c_fol is None:
            c_fol = c_cur
        try:
            r_cur = m_cur.process(chans[cur_ch][s:e].astype(float), c_cur, pitch,
                                  polarity=pol, seg_half=seg_half,
                                  margin=margin, recenter=recenter)
            r_fol = m_fol.process(chans[fol_ch][s:e].astype(float), c_fol, pitch,
                                  polarity=pol, seg_half=seg_half,
                                  margin=margin, recenter=recenter)
        except Exception:
            r_cur = r_fol = None
        if r_cur is None:
            rows.append(dict(rev=ri, status="计算失败"))
            continue
        # 直接用质量模块的交点(它已算出Q说明交点可靠), 不再重复调measure
        w50_cur = r_cur["widths"][0.5]      # 丝(已乘si)
        w50_fol = r_fol["widths"][0.5] if r_fol else None
        # 从widths反推b50绝对位置: widths返回的是丝, 需要用锚位+段内相对位置
        # 改为直接从内部cr取: 质量模块process()的widths已可靠
        # eV用后沿(默认)或前沿(用户选)
        # 段内交点在质量模块内部, 我们重新用段提取一次(与质量模块同参数)
        try:
            cc = max(seg_half, min(c_cur, len(cur_pos) - seg_half - 1))
            seg_c = smooth3e(cur_pos[cc-seg_half:cc+seg_half+1])
            cr_c = fw_crossings(seg_c, rpeak(seg_c))
        except Exception:
            cr_c = {0.5: (None, None)}
        try:
            cf = max(seg_half, min(c_fol, len(fol_pos) - seg_half - 1))
            seg_f = smooth3e(fol_pos[cf-seg_half:cf+seg_half+1])
            cr_f = fw_crossings(seg_f, rpeak(seg_f))
        except Exception:
            cr_f = {0.5: (None, None)}
        f50_c, b50_c = cr_c[0.5]
        f50_f, b50_f = cr_f[0.5]
        # 按用户选择的沿计算eV
        if edge == "back":          # 后沿(默认)
            pos_c, pos_f = b50_c, b50_f
        elif edge == "front":       # 前沿
            pos_c, pos_f = f50_c, f50_f
        else:                        # 中线
            if None not in (f50_c, b50_c):
                pos_c = (f50_c + b50_c) / 2
            else:
                pos_c = None
            if None not in (f50_f, b50_f):
                pos_f = (f50_f + b50_f) / 2
            else:
                pos_f = None
        ev = (pos_c - pos_f) * si if None not in (pos_c, pos_f) else None
        w_cur = (b50_c - f50_c) * si if None not in (b50_c, f50_c) else None
        w_fol = (b50_f - f50_f) * si if None not in (b50_f, f50_f) else None
        eh = (w_cur - w_fol) if (w_cur is not None and w_fol is not None) else None

        status = ""
        if not warmup_done and r_cur["qLevel"] <= 1:
            w25 = r_cur["widths"][0.25]; w50 = r_cur["widths"][0.5]; w75 = r_cur["widths"][0.75]
            if None not in (w25, w50, w75):
                mono = w25 > w50 > w75
                dw25 = abs(w25 - w50); dw75 = abs(w75 - w50)
                sym = abs(dw25 - dw75) < 0.5 * max(dw25, dw75) if max(dw25, dw75) > 0 else True
                prop = max(dw25, dw75) / w50 < 0.8 if w50 > 0 else False
                if mono and sym and prop:
                    warmup_count += 1
                    if warmup_count >= warmup:
                        warmup_done = True
                        status = f"建表完成({warmup_count}圈)"
                    else:
                        status = f"暖机{warmup_count}/{warmup}"
                else:
                    if not mono: status = "[X]单调性违反"
                    elif not sym: status = f"❌对称性异常 |ΔW25|={dw25:.0f} |ΔW75|={dw75:.0f}"
                    elif not prop: status = f"❌比例异常 |ΔW|/W50={max(dw25,dw75)/w50:.2f}"
                    table_rejected = True
            else:
                status = "三档不全"
        elif table_rejected:
            status = "表被拒"

        q_fol = r_fol["q_score"] if r_fol else 0
        qp = min(r_cur["q_score"], q_fol)
        jp = r_cur["jp"] if r_cur["jp"] is not None else -1
        # 简化Q = Qn × Qd / 100 (只用噪声+形状)
        q_simple = r_cur["Qn"] * r_cur["Qd"] / 100.0
        rows.append(dict(
            rev=ri, amp=round(r_cur["scope"] / 655.35, 1),
            sigma=round(r_cur["sigma"], 1), snr=round(r_cur["snr"], 1),
            jp=round(jp, 2), w50=round(w_cur, 1) if w_cur is not None else None,
            Qn=round(r_cur["Qn"], 1), Qd=round(r_cur["Qd"], 1),
            Q_simple=round(q_simple, 1),
            Q_full=round(r_cur["q_score"], 1),
            qLevel=r_cur["qLevel"],
            eV=round(ev, 1) if ev is not None else None,
            eH=round(eh, 1) if eh is not None else None,
            Q_pair=round(qp, 1), status=status))

    info = dict(si=si, pitch=pitch, pol=pol, cur=cur_ch, fol=fol_ch,
                clen=clen, nrev=len(revs), table_done=warmup_done,
                table_rejected=table_rejected, warmup_count=warmup_count,
                stair=stair_info)
    return rows, info


# ═══════════════════════ GUI ═══════════════════════

class SimGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("色标质量仿真工具")
        self.root.geometry("1200x800")
        self.rows = []
        self.info = {}
        self._build_ui()

    def _build_ui(self):
        # ── 顶部参数区 ──
        frm = ttk.LabelFrame(self.root, text="参数", padding=8)
        frm.pack(fill="x", padx=8, pady=4)

        r1 = ttk.Frame(frm); r1.pack(fill="x", pady=2)
        ttk.Button(r1, text="选择文件…", command=self._pick_file).pack(side="left", padx=(0,8))
        self.var_file = tk.StringVar(value="未选择")
        ttk.Label(r1, textvariable=self.var_file).pack(side="left")

        r2 = ttk.Frame(frm); r2.pack(fill="x", pady=2)
        for lbl, var, default, width in (
            ("波门起点", "var_g0", "0", 6), ("门宽", "var_gw", "1000", 6),
            ("丝/点", "var_si", "0", 8), ("版周mm", "var_girth", "0", 8),
            ("暖机圈数", "var_warmup", "8", 4)):
            ttk.Label(r2, text=lbl).pack(side="left", padx=(8,2))
            v = tk.StringVar(value=default)
            setattr(self, var, v)
            ttk.Entry(r2, textvariable=v, width=width).pack(side="left")

        r3 = ttk.Frame(frm); r3.pack(fill="x", pady=2)
        ttk.Label(r3, text="当前色").pack(side="left", padx=(8,2))
        self.var_cur = tk.StringVar(value="T1")
        ttk.Combobox(r3, textvariable=self.var_cur, values=["T1","T2"],
                     width=4, state="readonly").pack(side="left", padx=(0,12))
        ttk.Label(r3, text="极性").pack(side="left", padx=(8,2))
        self.var_pol = tk.StringVar(value="auto")
        ttk.Combobox(r3, textvariable=self.var_pol, values=["auto","pos","neg"],
                     width=6, state="readonly").pack(side="left", padx=(0,12))
        ttk.Label(r3, text="测位沿").pack(side="left", padx=(8,2))
        self.var_edge = tk.StringVar(value="back")
        ttk.Combobox(r3, textvariable=self.var_edge, values=["back","front","mid"],
                     width=6, state="readonly").pack(side="left", padx=(0,12))
        self.var_bipolar = tk.BooleanVar(value=False)
        ttk.Checkbutton(r3, text="双极性", variable=self.var_bipolar).pack(side="left", padx=(8,4))
        ttk.Button(r3, text="🔍 预览波形", command=self._preview).pack(side="left", padx=8)
        ttk.Button(r3, text="▶ 运行仿真", command=self._run).pack(side="left", padx=8)
        ttk.Button(r3, text="💾 导出CSV", command=self._export).pack(side="left", padx=4)

        # ── 结果表格 ──
        cols = ("rev","amp","sigma","snr","jp","w50","Qn","Qd","Q_simple",
                "eV","eH","Q_pair","qLevel","status")
        heads = ("圈","幅度%","σ","SNR","jp丝","W50丝","Qn","Qd","Q简化",
                 "eV丝","eH丝","配对Q","级","状态")
        frm2 = ttk.LabelFrame(self.root, text="逐圈结果", padding=4)
        frm2.pack(fill="both", expand=True, padx=8, pady=4)
        self.tree = ttk.Treeview(frm2, columns=cols, show="headings", height=12)
        for c, h in zip(cols, heads):
            self.tree.heading(c, text=h)
            anchor = "e" if c in ("eV","eH","jp","w50") else "center"
            self.tree.column(c, width=52 if len(h)<=3 else 68, anchor=anchor)
        vsb = ttk.Scrollbar(frm2, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=vsb.set)
        self.tree.pack(side="left", fill="both", expand=True)
        vsb.pack(side="right", fill="y")

        # ── 汇总 ──
        self.lbl_summary = ttk.LabelFrame(self.root, text="汇总", padding=6)
        self.lbl_summary.pack(fill="x", padx=8, pady=4)
        self.var_summary = tk.StringVar(value="点击「运行仿真」开始")
        ttk.Label(self.lbl_summary, textvariable=self.var_summary,
                  font=("Microsoft YaHei", 10)).pack(anchor="w")

        # ── 图表区: 双标签页 ──
        if HAS_MPL:
            frm3 = ttk.LabelFrame(self.root, text="图表", padding=4)
            frm3.pack(fill="both", expand=True, padx=8, pady=4)
            self.nb = ttk.Notebook(frm3)
            self.nb.pack(fill="both", expand=True)
            # Tab1: 波形预览
            tab_wf = ttk.Frame(self.nb)
            self.nb.add(tab_wf, text=" 波形预览 ")
            self.fig_wf = Figure(figsize=(11, 4), dpi=96)
            self.canvas_wf = FigureCanvasTkAgg(self.fig_wf, master=tab_wf)
            self.canvas_wf.get_tk_widget().pack(fill="both", expand=True)
            # Tab2: 误差与质量
            tab_err = ttk.Frame(self.nb)
            self.nb.add(tab_err, text=" 误差与质量 ")
            self.fig = Figure(figsize=(11, 4), dpi=96)
            self.canvas = FigureCanvasTkAgg(self.fig, master=tab_err)
            self.canvas.get_tk_widget().pack(fill="both", expand=True)

    def _pick_file(self):
        fn = filedialog.askopenfilename(
            title="选择精采样文件",
            filetypes=[("ptwatch CSV", "*.csv"), ("所有文件", "*.*")])
        if fn:
            self.var_file.set(fn)

    def _get_params(self):
        """解析参数, 返回dict或None"""
        if not self.var_file.get() or self.var_file.get() == "未选择":
            messagebox.showwarning("提示", "请先选择文件")
            return None
        try:
            g0 = int(self.var_g0.get())
            gw = int(self.var_gw.get())
            si = float(self.var_si.get() or 0)
            girth = float(self.var_girth.get() or 0)
            warmup = int(self.var_warmup.get() or 8)
        except ValueError:
            messagebox.showerror("错误", "参数必须是数字")
            return None
        return dict(g0=g0, gw=gw, si=si, girth=girth, warmup=warmup,
                    cur=self.var_cur.get(), pol=self.var_pol.get(),
                    edge=self.var_edge.get(), bipolar=self.var_bipolar.get())

    def _preview(self):
        """预览波形: 选文件后点击, 显示波门区域原始/双极性处理后的波形"""
        p = self._get_params()
        if p is None:
            return
        if not HAS_MPL:
            messagebox.showinfo("提示", "需要matplotlib才能预览")
            return
        try:
            t1, t2, revs, clen = load_ptwatch(self.var_file.get(), bipolar=p["bipolar"])
            if not revs:
                messagebox.showerror("错误", "没有有效圈")
                return
            s, e = revs[min(1, len(revs)-1)]  # 第2圈(弃首圈)
            g0, gw = p["g0"], p["gw"]
            pol = p["pol"]
            # auto极性: 在门内判定(不看门外图案)
            if pol == "auto":
                t_cur = t1 if p["cur"] == "T1" else t2
                gate_raw = t_cur[s:e].astype(float)[g0:g0+gw]
                pol = polarity_of(gate_raw)
            pos1 = positive(t1[s:e].astype(float), pol)
            pos2 = positive(t2[s:e].astype(float), pol)
            auto_pol = "峰" if np.median(pos1) < np.max(pos1)*0.5 else "谷→峰"
            # 截取波门附近(前后各加500点余量)
            lo = max(0, g0 - 200)
            hi = min(len(pos1), g0 + gw + 200)
            xs = np.arange(lo, hi)
            self.fig_wf.clear()
            ax1 = self.fig_wf.add_subplot(211)
            ax2 = self.fig_wf.add_subplot(212, sharex=ax1)
            for ax, y, ch, cc in ((ax1, pos1[lo:hi], "T1", "#1a4d8f"),
                                   (ax2, pos2[lo:hi], "T2", "#e07b39")):
                ax.plot(xs, y, lw=.7, color=cc)
                ax.axvspan(g0, g0+gw, alpha=0.12, color="#2e8b57", label="波门")
                ax.axhline(0, ls="-.", c="gray", lw=.6)
                ax.set_ylabel(f"{ch}\n幅值(LSB)", fontsize=8)
                ax.grid(alpha=.2)
                if ch == "T1":
                    ax.set_title(f"波形预览 (圈2)  门[{g0},{g0+gw})  "
                                 f"极性={pol}  "
                                 f"{'双极性[OK]' if p['bipolar'] else ''}  圈长{clen}", fontsize=10)
            ax2.set_xlabel("圈坐标(点)", fontsize=9)
            self.fig_wf.tight_layout()
            self.canvas_wf.draw()
            self.nb.select(0)  # 切到波形页
        except Exception as ex:
            messagebox.showerror("预览错误", f"{ex}")

    def _draw_waveform_annotated(self):
        """仿真后: 只显示波门内容 + 阈值线 + 48点豆腐块噪声窗"""
        if not HAS_MPL or not self.rows:
            return
        p = self._get_params()
        if p is None:
            return
        try:
            t1, t2, revs, clen = load_ptwatch(self.var_file.get(), bipolar=p["bipolar"])
            s, e = revs[min(1, len(revs)-1)]
            g0, gw = p["g0"], p["gw"]
            gate_lo, gate_hi = g0, g0 + gw
            pol = self.info.get("pol", p["pol"])
            cur_ch = self.info.get("cur", "T1")
            fol_ch = self.info.get("fol", "T2")
            # 只取波门数据
            cur_raw = (t1 if cur_ch == "T1" else t2)[s:e].astype(float)[gate_lo:gate_hi]
            fol_raw = (t1 if fol_ch == "T1" else t2)[s:e].astype(float)[gate_lo:gate_hi]
            cur_pos = positive(cur_raw, pol)
            fol_pos = positive(fol_raw, pol)
            xs = np.arange(gate_lo, gate_hi)  # 用波门坐标
            mid_row = self.rows[len(self.rows)//2]
            si = self.info.get("si", 1.0)
            si_mm = si / 100.0
            BL = mqm.PAR["blk_len"]
            margin = max(10, int(round(0.8 / si_mm)))
            pitch = self.info.get("pitch", 1000)
            self.fig_wf.clear()
            ax1 = self.fig_wf.add_subplot(211)
            ax2 = self.fig_wf.add_subplot(212, sharex=ax1)
            for ax, y, ch, cc, raw in ((ax1, cur_pos, cur_ch, "#1a4d8f", cur_raw),
                                        (ax2, fol_pos, fol_ch, "#e07b39", fol_raw)):
                ax.plot(xs, y, lw=.8, color=cc)
                ax.axhline(0, ls="-.", c="gray", lw=.6)
                ax.grid(alpha=.2)
                ax.set_ylabel(f"{ch}\nLSB", fontsize=8)
                role = "当前色" if ch == cur_ch else "跟踪色"
                ax.text(0.98, 0.95, f"{ch}={role}", transform=ax.transAxes,
                        ha="right", va="top", fontsize=9, color=cc, weight="bold")
            # ── 在当前色上标注 ──
            ax_cur = ax1 if cur_ch == "T1" else ax2
            # 找标(门内)
            w = cur_pos
            if len(w) > 0 and w.max() > 0:
                hi_pts = np.flatnonzero(w > 0.9 * w.max())
                anchor = int(np.mean(hi_pts)) if len(hi_pts) >= 3 else int(np.argmax(w))
            else:
                anchor = None
            if anchor is not None:
                seg = smooth3e(cur_pos[max(0,anchor-100):anchor+101])
                scope = rpeak(seg)
                # 三档阈值线(画在门坐标上)
                for r, lcc in ((0.75, "#2e8b57"), (0.5, "#c0392b"), (0.25, "#e07b39")):
                    lvl = scope * r
                    ax_cur.axhline(lvl, ls=":", c=lcc, lw=1, alpha=.8)
                    ax_cur.text(gate_hi - 5, lvl, f"{int(r*100)}%={lvl:.0f}",
                                fontsize=7, color=lcc, va="center", ha="right")
                # 噪声窗计算(门内坐标, 裁剪到门边界)
                cr = fw_crossings(seg, scope)
                hb = pitch // 4  # 默认
                if None not in cr[0.25]:
                    f25 = max(0, anchor-100) + cr[0.25][0]
                    b25 = max(0, anchor-100) + cr[0.25][1]
                    hb = int(b25 - f25) + margin
                # 左窗: [max(门首, anchor-pitch+hb), anchor-hb)
                lw_s = max(gate_lo, gate_lo + anchor - pitch + hb)
                lw_e = gate_lo + anchor - hb
                # 右窗: [anchor+hb, min(门尾, anchor+pitch-hb))
                rw_s = gate_lo + anchor + hb
                rw_e = min(gate_hi, gate_lo + anchor + pitch - hb)
                # 画48点豆腐块
                block_colors = ["#d4e6f1", "#fadbd8"]  # 交替
                y_min, y_max = ax_cur.get_ylim()
                for wi, (ws, we) in enumerate(((lw_s, lw_e), (rw_s, rw_e))):
                    if we <= ws:
                        continue
                    nb = (we - ws) // BL  # 完整块数
                    for j in range(nb):
                        bx_s = ws + j * BL
                        bx_e = bx_s + BL
                        # 转回门坐标
                        bx_s_abs = gate_lo + bx_s - gate_lo  # ws已经是门坐标
                        ax_cur.axvspan(bx_s, bx_e, alpha=0.3,
                                       color=block_colors[j % 2], lw=0.5,
                                       ec="#7d3c98", ls="--")
                    # 块中位线
                    for j in range(nb):
                        blk = cur_pos[ws-gate_lo+j*BL : ws-gate_lo+(j+1)*BL]
                        if len(blk) == BL:
                            bm = np.sort(blk)[BL//2]
                            bx_s = ws + j * BL
                            ax_cur.plot([bx_s, bx_s+BL], [bm, bm],
                                       c="#c0392b", lw=2, alpha=.8)
                    we_txt = "左窗" if wi == 0 else "右窗"
                    info_txt = f"{we_txt} {nb}块×{BL}点"
                    if we - ws < BL:
                        info_txt += f" (余{we-ws}点不够一块)"
                    if we <= ws + BL:
                        info_txt += " ⚠太小"
                    ax_cur.text((ws+we)/2, y_min + (y_max-y_min)*0.05,
                               info_txt, fontsize=7, color="#7d3c98",
                               ha="center", va="bottom",
                               bbox=dict(fc="white", ec="#7d3c98", alpha=.8, pad=1))
                # 标位置
                ax_cur.axvline(gate_lo + anchor, ls="--", c="#c0392b", lw=1.2, alpha=.7)
                ax_cur.text(gate_lo + anchor, scope * 1.02,
                           f"标@{gate_lo+anchor}", fontsize=8,
                           color="#c0392b", ha="center")
            ax1.set_title(f"波门[{gate_lo},{gate_hi})  极性={pol}  "
                          f"BL={BL}点/块  pitch={pitch}点  "
                          f"Q简化={mid_row.get('Q_simple','?')}", fontsize=10)
            ax2.set_xlabel("波门坐标(点)", fontsize=9)
            ax2.set_xlim(gate_lo, gate_hi)
            self.fig_wf.tight_layout()
            self.canvas_wf.draw()
        except Exception as ex:
            pass

    def _run(self):
        if not self.var_file.get() or self.var_file.get() == "未选择":
            messagebox.showwarning("提示", "请先选择文件")
            return
        try:
            g0 = int(self.var_g0.get())
            gw = int(self.var_gw.get())
            si = float(self.var_si.get() or 0)
            girth = float(self.var_girth.get() or 0)
            warmup = int(self.var_warmup.get() or 8)
        except ValueError:
            messagebox.showerror("错误", "参数必须是数字")
            return
        if si <= 0 and girth <= 0:
            messagebox.showerror("错误", "丝/点 和 版周mm 至少填一个")
            return
        self.var_summary.set("... 计算中…")
        self.root.update()
        try:
            self.rows, self.info = run_simulation(
                self.var_file.get(), g0, gw, self.var_cur.get(),
                self.var_pol.get(), warmup, si, girth, 20.0,
                self.var_edge.get(), self.var_bipolar.get())
        except Exception as ex:
            messagebox.showerror("错误", f"{ex}\n{traceback.format_exc()}")
            self.var_summary.set("[X] 计算失败")
            return
        self._fill_table()
        self._fill_summary()
        if HAS_MPL:
            self._draw_waveform_annotated()
            self._draw_fig()

    def _fill_table(self):
        self.tree.delete(*self.tree.get_children())
        keys = ("rev","amp","sigma","snr","jp","w50","Qn","Qd","Q_simple",
                "eV","eH","Q_pair","qLevel","status")
        for row in self.rows:
            vals = []
            for k in keys:
                v = row.get(k, "")
                if v is None: v = "—"
                vals.append(str(v))
            self.tree.insert("", "end", values=vals)

    def _fill_summary(self):
        ev = [r["eV"] for r in self.rows if r.get("eV") is not None]
        eh = [r["eH"] for r in self.rows if r.get("eH") is not None]
        q  = [r["Q_simple"] for r in self.rows if "Q_simple" in r]
        info = self.info
        lines = [f"版周={info.get('clen',0)}点×{info.get('nrev',0)}圈  "
                 f"极性={info.get('pol','')}  "
                 f"当前色={info.get('cur','')}  跟踪色={info.get('fol','')}"]
        if info.get("stair"):
            lines.append(info["stair"])
        lines.append(f"pitch={info.get('pitch',0)}点  si={info.get('si',0):.4f}丝/点")
        if ev:
            a = np.array(ev)
            lines.append(f"纵向eV: mean={a.mean():+.1f}丝  σ={a.std():.2f}丝  范围[{a.min():+.1f},{a.max():+.1f}]丝")
        else:
            lines.append("纵向eV: 无有效数据")
        if eh:
            a = np.array(eh)
            lines.append(f"横向eH: mean={a.mean():+.1f}丝  σ={a.std():.2f}丝  范围[{a.min():+.1f},{a.max():+.1f}]丝")
        else:
            lines.append("横向eH: 无有效数据")
        if q:
            a = np.array(q)
            lines.append(f"当前色质量Q(简化=Qn×Qd): 中位={np.median(a):.1f}  范围[{a.min():.1f},{a.max():.1f}]")
        if info.get("table_rejected"):
            lines.append("[!] 建表被拒绝 — 色标可能在暖机期就异常, 请人工确认!")
        elif info.get("table_done"):
            lines.append(f"[OK] 建表完成 ({info.get('warmup_count',0)}圈)")
        else:
            lines.append(f"... 建表未完成 (暖机{info.get('warmup_count',0)}圈, 质量不够或圈数不足)")
        self.var_summary.set("\n".join(lines))

    def _draw_fig(self):
        self.fig.clear()
        x = [r.get("rev", i) for i, r in enumerate(self.rows)]
        f = lambda k: [r.get(k) if r.get(k) is not None else np.nan for r in self.rows]
        ax1 = self.fig.add_subplot(311)
        ax1.plot(x, f("eV"), "-o", ms=3, lw=.8, color="#1a4d8f", label="eV")
        ax1.axhline(0, ls=":", c="gray", lw=.5)
        ax1.set_ylabel("eV(丝)"); ax1.legend(fontsize=7); ax1.grid(alpha=.25)
        ax2 = self.fig.add_subplot(312)
        ax2.plot(x, f("eH"), "-o", ms=3, lw=.8, color="#e07b39", label="eH")
        ax2.axhline(0, ls=":", c="gray", lw=.5)
        ax2.set_ylabel("eH(丝)"); ax2.legend(fontsize=7); ax2.grid(alpha=.25)
        ax3 = self.fig.add_subplot(313)
        ax3.plot(x, f("Q_simple"), "-o", ms=3, lw=1, color="#c0392b", label="Q简化(Qn×Qd)")
        ax3.plot(x, f("Q_pair"), "-s", ms=2, lw=.7, color="#7d3c98", label="配对Q", alpha=.7)
        ax3.axhline(90, ls="--", c="#2e8b57", lw=.7)
        ax3.axhline(25, ls="--", c="#c0392b", lw=.7)
        ax3.set_ylabel("Q(分)"); ax3.set_xlabel("圈号")
        ax3.legend(fontsize=7); ax3.grid(alpha=.25); ax3.set_ylim(0, 105)
        self.fig.tight_layout()
        self.canvas.draw()

    def _export(self):
        if not self.rows:
            messagebox.showwarning("提示", "请先运行仿真")
            return
        fn = filedialog.asksaveasfilename(
            title="导出CSV", defaultextension=".csv",
            filetypes=[("CSV", "*.csv")])
        if not fn:
            return
        keys = list(self.rows[0].keys())
        with open(fn, "w", newline="", encoding="utf-8-sig") as fp:
            w = csv.DictWriter(fp, fieldnames=keys)
            w.writeheader()
            w.writerows(self.rows)
        messagebox.showinfo("完成", f"已导出 {len(self.rows)} 圈 → {fn}")

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = SimGUI()
    app.run()
