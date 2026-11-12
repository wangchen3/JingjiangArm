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
    from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
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
        # ARM同口径: 只取波门切片(噪声窗为门内区间1/区间2, 坐标0基门内)
        cur_pos = positive(chans[cur_ch][s:e].astype(float)[g0:g0+gw], pol)
        fol_pos = positive(chans[fol_ch][s:e].astype(float)[g0:g0+gw], pol)
        c_cur = find_anchor(cur_pos, 0, gw)
        if c_cur is None:
            rows.append(dict(rev=ri, status="门内无标"))
            continue
        c_fol = find_anchor(fol_pos, max(0, c_cur - recenter),
                            min(gw, c_cur + recenter))
        if c_fol is None:
            c_fol = c_cur
        try:
            r_cur = m_cur.process(chans[cur_ch][s:e].astype(float)[g0:g0+gw], c_cur, pitch,
                                  polarity=pol, seg_half=seg_half,
                                  margin=margin, recenter=recenter)
            r_fol = m_fol.process(chans[fol_ch][s:e].astype(float)[g0:g0+gw], c_fol, pitch,
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

        # ── 图表区: 大图弹窗按钮(不再在主窗口内嵌小画布,太小看不清) ──
        if HAS_MPL:
            frm3 = ttk.LabelFrame(self.root, text="图表(独立大窗口, 弹出后可缩放/平移)", padding=4)
            frm3.pack(fill="x", padx=8, pady=4)
            ttk.Button(frm3, text="🔍 大图·逐圈波形(可切圈/三档交点标注)",
                       command=lambda: self._open_rev_viewer("逐圈波形")).pack(side="left", padx=6, pady=2)
            ttk.Button(frm3, text="📈 大图·误差与质量曲线",
                       command=self._open_curve_viewer).pack(side="left", padx=6, pady=2)

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

    # ═══════════ 绘图基础设施: 数据缓存 / 参数口径 / 大图弹窗 ═══════════

    def _load_data(self, bipolar):
        """CSV解析缓存(按 文件+双极性 组合键, 切圈时不重复解析)"""
        key = (self.var_file.get(), bool(bipolar))
        if getattr(self, "_dcache", None) and self._dcache.get("key") == key:
            return self._dcache
        t1, t2, revs, clen = load_ptwatch(self.var_file.get(), bipolar=bipolar)
        self._dcache = dict(key=key, t1=t1, t2=t2, revs=revs, clen=clen)
        return self._dcache

    def _draw_params(self, p, dc):
        """由界面参数求绘图/算法口径; si不可得(丝/点和版周都没填)返回None"""
        si = p["si"]
        if si <= 0 < p["girth"]:
            si = p["girth"] / dc["clen"] * 100.0    # 与run_simulation一致: 用实测圈长
        if si <= 0:
            return None
        si_mm = si / 100.0
        return dict(si=si, si_mm=si_mm,
                    pitch=max(1, int(round(20.0 / si_mm))),
                    BL=max(16, int(round(2.77 / si_mm))),
                    margin=max(10, int(round(0.8 / si_mm))),
                    seg_half=max(240, int(round(5.0 / si_mm))),
                    recenter=max(30, int(round(3.5 / si_mm))))

    def _preview(self):
        """预览波形 = 打开逐圈大图弹窗(圈1起, 可切圈)"""
        self._open_rev_viewer("波形预览")

    def _open_rev_viewer(self, title, start_rev=1):
        """独立大窗口: 逐圈波形(概览+标记放大+三档交点标注), 可切圈/缩放/平移"""
        if not HAS_MPL:
            messagebox.showinfo("提示", "需要matplotlib才能画图")
            return
        p = self._get_params()
        if p is None:
            return
        try:
            dc = self._load_data(p["bipolar"])
        except Exception as ex:
            messagebox.showerror("错误", f"读文件失败:\n{ex}")
            return
        if not dc["revs"]:
            messagebox.showerror("错误", "没有有效圈")
            return
        nmax = len(dc["revs"]) - 1
        if nmax < 1:
            messagebox.showerror("错误", "只有1圈数据")
            return
        top = tk.Toplevel(self.root)
        top.title(f"{title} — {os.path.basename(self.var_file.get())}")
        top.geometry("1500x950")
        state = {"rev": max(1, min(int(start_rev), nmax))}

        ctrl = ttk.Frame(top, padding=6)
        ctrl.pack(fill="x")
        info = ttk.Label(ctrl, text="", font=("Microsoft YaHei", 10, "bold"))
        info.pack(side="left", padx=10)

        def goto(r):
            state["rev"] = max(1, min(nmax, int(r)))
            redraw()

        ttk.Button(ctrl, text="◀ 上一圈", command=lambda: goto(state["rev"] - 1)).pack(side="left")
        ttk.Button(ctrl, text="下一圈 ▶", command=lambda: goto(state["rev"] + 1)).pack(side="left", padx=4)
        sb = ttk.Spinbox(ctrl, from_=1, to=nmax, width=5,
                         command=lambda: goto(sb.get()))
        sb.pack(side="left")
        sb.bind("<Return>", lambda ev: goto(sb.get()))

        figframe = ttk.Frame(top)
        figframe.pack(fill="both", expand=True)
        fig = Figure(figsize=(14.5, 8.8), dpi=100)
        canvas = FigureCanvasTkAgg(fig, master=figframe)
        canvas.get_tk_widget().pack(fill="both", expand=True)
        NavigationToolbar2Tk(canvas, figframe).update()

        top.bind("<Left>", lambda ev: goto(state["rev"] - 1))
        top.bind("<Right>", lambda ev: goto(state["rev"] + 1))

        def redraw():
            sb.set(state["rev"])
            fig.clear()
            self._draw_rev(fig, state["rev"], dc, p)
            fig.tight_layout()
            canvas.draw()
            row = next((r for r in self.rows if r.get("rev") == state["rev"]), None)
            extra = ""
            if row:
                extra = (f"   |   级={row.get('qLevel')}  σ={row.get('sigma')}  "
                         f"jp={row.get('jp')}丝  Qn={row.get('Qn')}  "
                         f"W50={row.get('w50')}丝  {row.get('status','')}")
            info.config(text=f"圈 {state['rev']}/{nmax}   (←/→键或按钮切圈){extra}")

        redraw()

    def _draw_rev(self, fig, ri, dc, p):
        """单圈绘图(门内坐标0..gw, 与ARM detail数组同口径):
        概览=双通道+标记排除区+ARM区间1/区间2噪声窗豆腐块(双端同步铺块+块中位线)
        放大=T1/T2标记(三档线+交点标注+稳健峰位置)"""
        t1, t2, revs = dc["t1"], dc["t2"], dc["revs"]
        s, e = revs[ri]
        g0, gw = p["g0"], p["gw"]
        pol = p["pol"]
        cur_ch, fol_ch = p["cur"], ("T2" if p["cur"] == "T1" else "T1")
        cur_arr = (t1 if cur_ch == "T1" else t2)[s:e].astype(float)
        fol_arr = (t1 if fol_ch == "T1" else t2)[s:e].astype(float)
        if pol == "auto":
            pol = polarity_of(cur_arr[g0:g0 + gw])
        cur_pos = positive(cur_arr[g0:g0 + gw], pol)   # 只取门内
        fol_pos = positive(fol_arr[g0:g0 + gw], pol)
        dp = self._draw_params(p, dc)
        half = dp["seg_half"] if dp else 150

        ax1 = fig.add_subplot(311)
        ax2 = fig.add_subplot(312)
        ax3 = fig.add_subplot(313)
        xs = np.arange(0, len(cur_pos))
        for y, ch, cc in ((cur_pos, cur_ch, "#1a4d8f"), (fol_pos, fol_ch, "#e07b39")):
            ax1.plot(xs, y, lw=.8, color=cc, alpha=.9,
                     label="%s%s" % (ch, "(当前色)" if ch == cur_ch else "(跟踪色)"))
        ax1.axhline(0, ls="-.", c="gray", lw=.5)
        ax1.grid(alpha=.2); ax1.legend(fontsize=8, loc="upper right")
        ax1.set_ylabel("正向化幅值(LSB)", fontsize=9)
        ax1.set_xlim(0, len(cur_pos))
        si_txt = ("si=%.4f丝/点  BL=%d点/块" % (dp["si"], dp["BL"])
                  ) if dp else "si未知(填丝/点或版周后显示标注)"
        ax1.set_title("圈%d  极性=%s  波门[%d,%d) 门内坐标  圈长%d  %s"
                      % (ri, pol, g0, g0 + gw, dc["clen"], si_txt), fontsize=11)

        c_cur = find_anchor(cur_pos, 0, len(cur_pos))
        if c_cur is None:
            for ax in (ax2, ax3):
                ax.text(.5, .5, "门内找不到标记(锚=最高点群)", ha="center", va="center",
                        transform=ax.transAxes, fontsize=12, color="#c0392b")
            return

        def extract(arr, c, h):
            a, b = max(0, c - h), min(len(arr) - 1, c + h)
            return smooth3e(arr[a:b + 1]), a

        # T1放大(自适应两轮, 宽标扩窗)
        seg, a0 = extract(cur_pos, c_cur, half)
        scope = rpeak(seg)
        cr = fw_crossings(seg, scope)
        if None not in cr[0.25]:
            w25 = cr[0.25][1] - cr[0.25][0]
            if w25 > 1.2 * half:
                seg, a0 = extract(cur_pos, c_cur, int(w25 * 0.75) + 20)
                scope = rpeak(seg)
                cr = fw_crossings(seg, scope)

        ax1.axvline(c_cur, ls="--", c="#c0392b", lw=1)

        # ── ARM噪声窗: 排除区 + 区间1/区间2 豆腐块(双端同步) ──
        if dp is not None and cr is not None and None not in cr[0.25]:
            f25g = a0 + cr[0.25][0]
            b25g = a0 + cr[0.25][1]
            hb = int(b25g - f25g)                        # 排除区半宽=W25(K已取消|2026.11.12)
            ex1, ex2 = int(f25g) - hb, int(b25g) + hb     # 排除区边界
            n1 = len(cur_pos)
            if 0 <= ex1 < ex2 <= n1:
                ax1.axvspan(ex1, ex2, alpha=.15, color="#95a5a6")
                ax1.text((ex1 + ex2) / 2, .99, "标记排除区 W25=%d点" % hb,
                         transform=ax1.get_xaxis_transform(), fontsize=7.5,
                         color="#566573", ha="center", va="top")
            BL = dp["BL"]
            blockc = ("#d4e6f1", "#fadbd8")
            tot_pts = 0
            for (wa, we, dr, nm) in ((0, ex1, -1, "区间1"), (ex2, n1, +1, "区间2")):
                wl = we - wa
                if wl < 8:                                # 连残块都放不下(空白<8点)
                    ax1.text(.25 if dr < 0 else .75, .5,
                             "%s空白不足8点→该侧无块" % nm,
                             transform=ax1.get_xaxis_transform(), fontsize=9,
                             color="#c0392b", ha="center")
                    continue
                nfull = wl // BL
                if nfull > 0:                             # 整块: 自排除边向外(双端同步)
                    blocks = ([(we - (j + 1) * BL, we - j * BL) for j in range(nfull)]
                              if dr < 0 else
                              [(wa + j * BL, wa + (j + 1) * BL) for j in range(nfull)])
                    label = "%s: %d块×%d" % (nm, nfull, BL)
                else:                                     # 每侧保底一块(残块=整窗)
                    blocks = [(wa, we)]
                    label = "%s: 1残块×%d点(保底)" % (nm, wl)
                for bi, (s0, s1) in enumerate(blocks):    # 豆腐块
                    ax1.axvspan(s0, s1, alpha=.35, color=blockc[bi % 2],
                                lw=.6, ec="#7d3c98", ls="--")
                for (s0, s1) in blocks:                   # 块中位线
                    blk = cur_pos[s0:s1]
                    bm = np.sort(blk)[len(blk) // 2]
                    ax1.plot([s0, s1], [bm, bm], c="#c0392b", lw=1.6, alpha=.85)
                tot_pts += sum(s1 - s0 for (s0, s1) in blocks)
                cen = (blocks[0][0] + blocks[-1][1]) / 2
                ax1.text(cen, .93, label,
                         transform=ax1.get_xaxis_transform(), fontsize=7.5,
                         color="#7d3c98", ha="center", va="top")
            if 0 < tot_pts < mqm.PAR["noise_min_pts"]:
                ax1.text(n1 / 2, .04, "两侧块点合计%d<%d→σ无效"
                         % (tot_pts, mqm.PAR["noise_min_pts"]),
                         transform=ax1.get_xaxis_transform(), fontsize=9,
                         color="#c0392b", ha="center")

        self._draw_mark_zoom(ax2, cur_pos, half, seg, scope, cr, dp, a0,
                             "%s(当前色)  标@%d 门内坐标" % (cur_ch, c_cur))

        # ── T2放大: 管线同款先在当前色附近找 ──
        c_fol = None
        if dp is not None:
            c_fol = find_anchor(fol_pos, max(0, c_cur - dp["recenter"]),
                                min(len(fol_pos), c_cur + dp["recenter"]))
        borrowed = c_fol is None
        c_fol = c_cur if borrowed else c_fol
        seg2, a2 = extract(fol_pos, c_fol, half)
        scope2 = rpeak(seg2)
        cr2 = fw_crossings(seg2, scope2)
        ax1.axvline(c_fol, ls="--", c="#e07b39", lw=1, alpha=.8)
        self._draw_mark_zoom(ax3, fol_pos, half, seg2, scope2, cr2, dp, a2,
                             "%s(跟踪色)  标@%d 门内坐标%s"
                             % (fol_ch, c_fol, "(未找到,借当前色位)" if borrowed else ""))
        ax3.set_xlabel("门内坐标(点)", fontsize=9)

    def _draw_mark_zoom(self, ax, pos, half, seg, scope, cr, dp, a0, title):
        """标记放大窗: 原始+平滑、三档阈值线、前后沿交点竖线标注、W50标注、稳健峰位置"""
        xs = np.arange(a0, a0 + len(seg))
        ax.plot(xs, pos[a0:a0 + len(seg)], lw=.5, color="gray", alpha=.5, label="原始")
        ax.plot(xs, seg, lw=1.1, color="#1a4d8f", label="3点平滑")
        ax.axhline(0, ls="-.", c="gray", lw=.5)
        ax.grid(alpha=.2)
        # 稳健峰位置(rpeak为top5中位值, 位置取平滑段argmax)
        pk = a0 + int(np.argmax(seg))
        ax.axvline(pk, ls="-.", c="#27ae60", lw=1.2)
        ax.annotate("稳健峰@%d\n(top5中位=%.0f)" % (pk, scope),
                    xy=(pk, scope), fontsize=8, color="#27ae60", ha="center",
                    xytext=(0, 10), textcoords="offset points")
        cols = {0.25: "#e07b39", 0.5: "#c0392b", 0.75: "#2e8b57"}
        for r in (0.25, 0.5, 0.75):
            lvl = scope * r
            ax.axhline(lvl, ls=":", c=cols[r], lw=1, alpha=.85)
            ax.text(xs[-1], lvl, " %d%%=%.0f" % (r * 100, lvl), fontsize=8,
                    color=cols[r], va="center", ha="left")
        if cr is not None:
            for r in (0.25, 0.5, 0.75):
                f_, b_ = cr[r]
                for x_, tag in ((f_, "f"), (b_, "b")):
                    if x_ is None:
                        continue
                    xi = a0 + x_
                    ax.axvline(xi, ls="--", c=cols[r], lw=1, alpha=.8)
                    silk = ("=%.1f丝" % (x_ * dp["si"])) if dp else ""
                    ax.annotate("%s%d@%d%s" % (tag, r * 100, xi, silk),
                                xy=(xi, scope * r), fontsize=7.5, color=cols[r],
                                xytext=(0, 14 if tag == "f" else -18),
                                textcoords="offset points", ha="center")
            f50, b50 = cr[0.5]
            if None not in (f50, b50) and dp:
                w50 = (b50 - f50) * dp["si"]
                ax.annotate("", xy=(a0 + b50, scope * .5), xytext=(a0 + f50, scope * .5),
                            arrowprops=dict(arrowstyle="<->", color="#c0392b", lw=1.2))
                ax.text((2 * a0 + f50 + b50) / 2, scope * .55,
                        "W50=%.1f丝(%.2fmm)" % (w50, w50 / 100.0),
                        fontsize=9, color="#c0392b", ha="center")
        ax.set_title(title, fontsize=10)
        ax.set_ylabel("幅值(LSB)", fontsize=9)
        miss = [("%d%%" % (r * 100)) for r in (0.25, 0.5, 0.75)
                if cr is None or None in cr[r]]
        if miss:
            ax.text(.99, .05, "交点未找到: %s(窗口外?)" % ",".join(miss),
                    transform=ax.transAxes, fontsize=9, color="#c0392b",
                    ha="right", va="bottom")

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
            self._open_rev_viewer("仿真结果·逐圈波形", 1)

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

    def _open_curve_viewer(self):
        """独立大窗口: eV/eH/质量逐圈曲线(运行仿真后可看)"""
        if not HAS_MPL:
            messagebox.showinfo("提示", "需要matplotlib才能画图")
            return
        if not self.rows:
            messagebox.showwarning("提示", "请先运行仿真")
            return
        top = tk.Toplevel(self.root)
        top.title("误差与质量曲线 — %s" % os.path.basename(self.var_file.get()))
        top.geometry("1400x800")
        figframe = ttk.Frame(top)
        figframe.pack(fill="both", expand=True)
        fig = Figure(figsize=(13.5, 7.4), dpi=100)
        canvas = FigureCanvasTkAgg(fig, master=figframe)
        canvas.get_tk_widget().pack(fill="both", expand=True)
        NavigationToolbar2Tk(canvas, figframe).update()

        x = [r.get("rev", i) for i, r in enumerate(self.rows)]
        f = lambda k: [r.get(k) if r.get(k) is not None else np.nan for r in self.rows]
        ax1 = fig.add_subplot(311)
        ax1.plot(x, f("eV"), "-o", ms=4, lw=.9, color="#1a4d8f", label="eV纵向误差")
        ax1.axhline(0, ls=":", c="gray", lw=.5)
        ax1.set_ylabel("eV(丝)"); ax1.legend(fontsize=9); ax1.grid(alpha=.25)
        ax2 = fig.add_subplot(312)
        ax2.plot(x, f("eH"), "-o", ms=4, lw=.9, color="#e07b39", label="eH横向误差")
        ax2.axhline(0, ls=":", c="gray", lw=.5)
        ax2.set_ylabel("eH(丝)"); ax2.legend(fontsize=9); ax2.grid(alpha=.25)
        ax3 = fig.add_subplot(313)
        ax3.plot(x, f("Q_simple"), "-o", ms=4, lw=1, color="#c0392b", label="Q简化(Qn×Qd)")
        ax3.plot(x, f("Q_pair"), "-s", ms=3, lw=.8, color="#7d3c98", label="配对Q", alpha=.7)
        ax3.axhline(90, ls="--", c="#2e8b57", lw=.8, label="90分良线")
        ax3.axhline(25, ls="--", c="#c0392b", lw=.8, label="25分差线")
        ax3.set_ylabel("Q(分)"); ax3.set_xlabel("圈号")
        ax3.legend(fontsize=8, ncol=4); ax3.grid(alpha=.25); ax3.set_ylim(0, 105)
        fig.tight_layout()
        canvas.draw()

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
