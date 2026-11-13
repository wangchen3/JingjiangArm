# -*- coding: utf-8 -*-
"""参数收敛工作台: 加载60文件, 可配置评估(γ/γ_v/窗口/让料头处理), 拒绝帧分类(可解释vs真飞点)"""
import csv, glob, importlib.util, os

spec = importlib.util.spec_from_file_location("fysim", os.path.join(os.path.dirname(__file__), "..", "飞点剔除仿真.py"))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

COLS = {"err": "跟踪前一色纵向误差", "roll": "压辊", "dec": "解耦量@黄", "spd": "速度",
        "lh": "让料头(接料就输出)"}
LOST = -32768

def load(path):
    for enc in ("utf-8-sig", "gb18030", "utf-8"):
        try:
            with open(path, encoding=enc) as f:
                rd = [r for r in csv.reader(f)]
            break
        except UnicodeDecodeError:
            rd = []
    hdr = rd[0]
    ix = {k: hdr.index(v) for k, v in COLS.items()}
    D = {k: [] for k in COLS}
    for r in rd[1:]:
        try:
            e = float(r[ix["err"]])
        except (ValueError, IndexError):
            continue
        D["err"].append(e)
        for k in ("roll", "dec", "spd", "lh"):
            try:
                D[k].append(float(r[ix[k]]))
            except (ValueError, IndexError):
                D[k].append(None)
    return D

FILES = sorted(glob.glob(os.path.join(os.path.dirname(__file__), "..", "测试合集", "**", "*.csv"), recursive=True))
DATA = {f: load(f) for f in FILES}

def evaluate(g=0.5, gv=8.0, glags=5, vlags=5, splice=True, rel_dv=False):
    """跑全部文件, 返回 {file: [(帧号, 判定, 分类)], ...}; 分类: splice/dec/dv/hard"""
    m.ADJ_TOL_GAMMA, m.DV_TOL_GAMMA = g, gv
    m.ADJ_TOL_LAGS, m.DV_TOL_LAGS = glags, vlags
    out = {}
    for f, D in DATA.items():
        vals, rolls, decs, spds, lhs = D["err"], D["roll"], D["dec"], D["spd"], D["lh"]
        fr = m.FlyRemover()
        rows, idx = [], 0
        prev_roll = prev_spd = prev_lh = None
        for i, x in enumerate(vals, 1):
            roll = rolls[i - 1]
            if roll is not None:
                if prev_roll is not None and roll != prev_roll:
                    fr.reset()
                prev_roll = roll
            lh = lhs[i - 1] if lhs is not None else None
            if splice and lh is not None and lh:
                # 让料头=1: 透传,不喂不记账; 下降沿时复位
                if prev_lh is not None and not prev_lh:
                    pass  # 进入透传(无需动作)
                rows.append((i, "接料透传"))
                if prev_lh is not None and prev_lh and not lh:
                    fr.reset()
                prev_lh = lh
                continue
            if splice and lh is not None and prev_lh is not None and prev_lh and not lh:
                fr.reset()
            if lh is not None:
                prev_lh = lh
            spd = spds[i - 1]
            dv = (spd - prev_spd) if spd is not None and prev_spd is not None else 0.0
            rel = abs(dv) / prev_spd if rel_dv and prev_spd else abs(dv)
            if spd is not None:
                prev_spd = spd
            dec = decs[i - 1]
            if x == LOST:
                fr.note_invalid()
                rows.append((i, "丢失"))
                if decs is not None:
                    fr.note_adj(0.0 if dec is None else dec)
                if spds is not None:
                    fr.note_dv(dv)
                continue
            idx += 1
            y, flag = fr.feed(x, idx=idx)
            rows.append((i, flag))
            if decs is not None:
                fr.note_adj(0.0 if dec is None else dec)
            if spds is not None:
                fr.note_dv(dv)
        # 分类拒绝帧
        res = []
        lh_end = [i for i, (n, fl) in enumerate(rows, 1)
                  if lhs is None and False]
        # 让料头区间集合
        spans = []
        cur = None
        for i, lh in enumerate(lhs, 1):
            if lh:
                if cur is None:
                    cur = i
            else:
                if cur is not None:
                    spans.append((cur, i - 1))
                    cur = None
        if cur is not None:
            spans.append((cur, len(lhs)))
        for n, fl in rows:
            if fl in ("飞点(锁存)", "暂缓(锁存)", "阶跃(确认)"):
                i = n
                near_splice = any(a - 8 <= i <= b + 8 for a, b in spans) if spans else False
                dw = max((abs(decs[j]) for j in range(max(0, i - 6), min(len(decs), i)) if decs[j] is not None), default=0)
                vw = max((abs((spds[j] or 0) - (spds[j - 1] or 0)) for j in range(max(1, i - 6), min(len(spds), i))), default=0)
                if near_splice:
                    c = "splice"
                elif dw > 500:
                    c = "dec"
                elif vw > 0.5:
                    c = "dv"
                else:
                    c = "hard"
                res.append((n, fl, c))
        out[f] = res
    return out

def summarize(res):
    from collections import Counter
    tot = Counter()
    per = {}
    for f, r in res.items():
        c = Counter(x[2] for x in r)
        tot.update(c)
        tag = f.replace("测试合集" + os.sep, "").replace(os.sep, "/").replace("ALL.MIX_", "").replace(".csv", "")
        per[tag] = (len(r), dict(c))
    return tot, per

if __name__ == "__main__":
    import sys
    g = float(sys.argv[1]) if len(sys.argv) > 1 else 0.5
    gv = float(sys.argv[2]) if len(sys.argv) > 2 else 8.0
    splice = bool(int(sys.argv[3])) if len(sys.argv) > 3 else True
    res = evaluate(g=g, gv=gv, splice=splice)
    tot, per = summarize(res)
    worst = sorted(per.items(), key=lambda kv: -kv[1][0])[:8]
    print("总拒绝 %d | 分类 %s" % (sum(tot.values()), dict(tot)))
    for t, (n, c) in worst:
        print("  %-26s %3d %s" % (t, n, c))
