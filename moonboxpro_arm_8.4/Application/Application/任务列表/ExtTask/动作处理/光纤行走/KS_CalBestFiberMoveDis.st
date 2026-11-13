(*@CES
Name=KS_CalBestFiberMoveDis
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=31e17208-b3c4-43ba-b525-12b355475b15
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalBestFiberMoveDis : REAL
VAR_INPUT
	i_ar_width      :ARRAY[1..3] OF REAL;    (*三个位置的色标宽度*)
	i_ar_position   :ARRAY[1..3] OF REAL;    (*三个绝对位置*)
	rmark_width      : REAL;                 (*三角形标宽度*)
    rmark_height     : REAL;                 (*三角形标高度*)
END_VAR
VAR
	rstandard_value  : REAL;                 (*标准宽度*)
    ibest_index      : INT := -1;            // 最佳点索引
    rmin_diff        : REAL := REAL#1.0E6;   // 最小差值（初始值）
    iN              : INT;                   // 循环计数器
    rcurrent_diff    : REAL;                  // 当前循环计算的差值
    rbest_width      : REAL;                  // 最佳点对应的宽度
    rbest_pos        : REAL;                  // 最佳点对应的位置
    rcurrent_pos     : REAL;                  // 当前机械位置
    rwidth_ratio     : REAL;                  // 宽高比
    rdeviation       : REAL;                  // 计算出的偏差量
    rtarget_pos      : REAL;                  // 最终目标位置
END_VAR

{IMPLEMENTATION}
// 1. 安全检查：避免除零
IF (Rmark_height < REAL#0.001) THEN
    KS_CalBestFiberMoveDis := REAL#0.0;
    RETURN;
END_IF;

// 2. 遍历筛选最佳点（宽度最接近标准值）
ibest_index := -1;
rmin_diff := REAL#1.0E6;
rstandard_value := rmark_height / 2;

FOR iN := 1 TO 3 DO
    // 假设位置为 -1.0 表示该点无效
    IF (i_ar_position[iN] <> REAL#-1.0 OR i_ar_width[iN] <> REAL#-1.0) THEN
        rcurrent_diff := ABS(i_ar_width[iN] - rstandard_value);
        
        // 更新最佳点
        IF (rcurrent_diff < rmin_diff) THEN
            rmin_diff := rcurrent_diff;
            ibest_index := iN;
        END_IF;
    END_IF;
END_FOR;

// 3. 若无有效点，不移动
IF (ibest_index < 0) THEN
    KS_CalBestFiberMoveDis := REAL#0.0;
    RETURN;
END_IF;

// 4. 提取计算所需数据
rbest_width := i_ar_width[ibest_index];
rbest_pos := i_ar_position[ibest_index];
rcurrent_pos := i_ar_position[3]; // 当前位置锁定为第三个点 (Index 2)

// 5. 计算几何偏差
rwidth_ratio := rmark_width / rmark_height;
rdeviation := rmin_diff * rwidth_ratio;

// 6. 确定目标位置   以后可以改成根据色标形式控制左右方向   总体而言，是宽了往窄的方向移动，窄了往宽的方向移动
IF (rbest_width > rstandard_value) THEN
    rtarget_pos := rbest_pos - rdeviation; // 太宽 -> 向左
ELSIF (rbest_width < rstandard_value) THEN
    rtarget_pos := rbest_pos + rdeviation; // 太窄 -> 向右
ELSE
    rtarget_pos := rbest_pos; // 正好
END_IF;

// 7. 计算并返回最终移动距离
KS_CalBestFiberMoveDis := rtarget_pos - rcurrent_pos;