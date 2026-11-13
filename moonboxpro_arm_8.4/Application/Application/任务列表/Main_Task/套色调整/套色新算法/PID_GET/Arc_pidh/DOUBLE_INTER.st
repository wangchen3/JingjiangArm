(*@CES
Name=DOUBLE_INTER
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ffc9ca76-f385-4e76-b007-d8ddf6459d90
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION DOUBLE_INTER : LREAL
VAR_INPUT
    (* --- 运行时输入 --- *)
    lrV_m_min   : LREAL;    (* 线速度 (m/min)，需在内部转换为 m/s *)
    lrY_Meas    : LREAL;    (* 测量套色误差 (mm) *)
    bEnable     : BOOL;     (* 控制器使能 *)

    (* --- 配置参数 (PSO 辨识与机械参数) --- *)
    lrPM_deg    : LREAL;    (* 目标相位裕度 (°) *)
    lrWc_Ts     : LREAL;    (* 归一化穿越频率 *)
	
    lrL         : LREAL;    (* 等效传输路径长度 (m) *)
    lrK_M       : LREAL;    (* 被控对象静态增益 (mm/deg) *)
    lrNK1       : LREAL;    (* 延迟物理量 *)
    lrC_SP      : LREAL;    (* 版辊等效周长 (m) *)

    (* --- 内部状态持久化指针 (外部传入) --- *)
    parrE       : POINTER TO ARRAY[1..2] OF LREAL; (* e(k-1), e(k-2) *)
    parrU       : POINTER TO ARRAY[1..2] OF LREAL; (* u(k-1), u(k-2) *)
END_VAR

VAR
    lrV_ms      : LREAL;    (* 转换后的线速度 m/s *)
    lrE_k       : LREAL;    (* 当前拍偏差 *)
    lrU_k       : LREAL;    (* 当前拍输出 *)
    
    lrTs        : LREAL;    (* 采样周期 *)
    lrA         : LREAL;    (* 极点 *)
    lrTau       : LREAL;    (* 传输延迟 *)
    lrPM_rad    : LREAL;    (* 相位裕度 (弧度) *)
    
    lrWc        : LREAL;    (* 穿越频率 *)
    lrWc_delay  : LREAL;    (* 受延迟约束的穿越频率上限 *)
    
    lrP_v       : LREAL;    (* 自适应极点 *)
    lrKc        : LREAL;    (* 自适应增益 *)
    
    lrAlpha     : LREAL;    (* Tustin 参数 2/Ts *)
    lrAlpha2    : LREAL;    (* Alpha 的平方 *)
    
    lrB0        : LREAL;    (* 差分方程系数 b0 *)
    lrB1        : LREAL;    (* 差分方程系数 b1 *)
    lrB2        : LREAL;    (* 差分方程系数 b2 *)
	
	//
	lrPi:LREAL:=3.14159265358979323846;
END_VAR
{IMPLEMENTATION}

(* ==========================================
   0. 空指针保护
   ========================================== *)
IF parrE = 0 OR parrU = 0 THEN
    DOUBLE_INTER := 0.0;
    RETURN;
END_IF;

(* ==========================================
   1. 单位转换与使能/速度保护
   ========================================== *)
lrV_ms := lrV_m_min / 60.0;(*单位对齐至m/s*)
IF lrC_SP<>0 THEN
	lrK_M := lrK_M * 36 / lrC_SP ;(*增益转换，从deg/mm转换到0.1丝/丝*)
ELSE
	lrK_M := 0.2;
END_IF
lrC_SP := lrC_SP / 1000.0 ;(*单位对齐至m*)

IF NOT bEnable THEN
    (* 未使能时，强制清空历史数组 *)
    parrE^[1] := 0.0;
    parrE^[2] := 0.0;
    parrU^[1] := 0.0;
    parrU^[2] := 0.0;
    DOUBLE_INTER := 0.0;
    RETURN;
END_IF;

IF lrV_ms < 0.1 THEN
    (* 速度过低保护，防止除零故障 *)
    DOUBLE_INTER := 0.0;
    RETURN;
END_IF;

(* ==========================================
   2. 计算物理模型参数与约束限制
   ========================================== *)
IF lrV_ms<>0 THEN
	lrTs  := lrC_SP / lrV_ms;
ELSE
	lrTs := 1;
END_IF

IF lrL<>0 THEN
	lrA   := lrV_ms / lrL;
ELSE
	lrA := 4.5;
END_IF
IF lrV_ms<>0 THEN
	lrTau := MAX(0.0, lrNK1 / lrV_ms);
ELSE
	lrTau := 0.6;
END_IF
lrPM_rad := lrPM_deg * lrPi / 180.0;

lrWc := lrWc_Ts / lrTs; 
lrWc_delay := (lrPi / 2 - lrPM_rad) / MAX(lrTau, 0.001);

IF lrWc > lrWc_delay THEN
    lrWc := lrWc_delay; 
END_IF;

(* ==========================================
   3. 反解自适应参数与 Tustin 离散化系数
   ========================================== *)
lrP_v := lrWc / TAN(lrPM_rad + (lrWc * lrTau)); 
lrKc  := (lrWc * lrWc) / (lrK_M * lrA * SQRT((lrWc * lrWc) + (lrP_v * lrP_v))); 

lrAlpha  := 2.0 / lrTs;
lrAlpha2 := lrAlpha * lrAlpha;

lrB0 := lrKc * (lrAlpha + lrA) * (lrAlpha + lrP_v) / lrAlpha2;
lrB1 := lrKc * 2.0 * ((lrA * lrP_v) - lrAlpha2) / lrAlpha2;
lrB2 := lrKc * (lrA - lrAlpha) * (lrP_v - lrAlpha) / lrAlpha2;

(* ==========================================
   4. 差分方程执行
   ========================================== *)
lrE_k := lrY_Meas;

lrU_k := (lrB0 * lrE_k)
       + (lrB1 * parrE^[1]) 
       + (lrB2 * parrE^[2])
       + (2.0 * parrU^[1]) 
       - parrU^[2];

(* ==========================================
   5. 状态推移更新
   ========================================== *)
parrE^[2] := parrE^[1];
parrE^[1] := lrE_k;

parrU^[2] := parrU^[1];
parrU^[1] := lrU_k;

(* ==========================================
   6. 输出结果
   ========================================== *)
DOUBLE_INTER := lrU_k;
