(*@CES
Name=KS_CalBestFiberMoveDisByRS
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ef5f33da-28ef-4533-8c0f-8778b1cdea74
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalBestFiberMoveDisByRS : REAL
VAR_INPUT
	i_ar_width       : ARRAY[1..3] OF REAL;    (*三个位置的色标宽度*)
	i_ar_markerpos   : ARRAY[1..3] OF INT;     (*三个色标位置信息*)
	rmark_width      : BYTE;                 (*三角形标宽度*)
    rmark_height     : BYTE;                 (*三角形标高度*)
	i_iMarkId        : INT; (*三角形标类型*)
	i_pBestPositionRS : POINTER TO INT;
	i_pBestMoveDisRS: POINTER TO REAL;
END_VAR
VAR
	i_ar_position : ARRAY[1..3] OF REAL := [0.0,-3.0,3.0];
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
IF (rmark_height < 1) THEN
    i_pBestMoveDisRS^ := REAL#-3.0;
    RETURN;
END_IF;

// 2. 遍历筛选最佳点（宽度最接近标准值）
ibest_index := -1;
rmin_diff := REAL#1.0E6;
rstandard_value := BYTE_TO_REAL(rmark_height) / 2;

FOR iN := 1 TO 3 DO
    // 假设位置为 -1.0 或者宽度为 -0.0 表示该点无效
    IF (i_ar_markerpos[iN] = -1 OR i_ar_width[iN] = REAL#0.0) THEN
		CONTINUE;
	ELSE
        rcurrent_diff := ABS(i_ar_width[iN] - rstandard_value);
        // 更新最佳点
        IF (rcurrent_diff < rmin_diff) THEN
            rmin_diff := rcurrent_diff;
            ibest_index := iN;
        END_IF;
    END_IF;
END_FOR;

// 3. 若无有效点，退回原点
IF (ibest_index < 0) THEN
    i_pBestMoveDisRS^ := REAL#-3.0;
    RETURN;
END_IF;

// 4. 提取计算所需数据
rbest_width := i_ar_width[ibest_index];
rbest_pos := i_ar_position[ibest_index];
rcurrent_pos := i_ar_position[3]; // 当前位置锁定为第三个点 (Index 2)

// 5. 计算几何偏差
rwidth_ratio := BYTE_TO_REAL(rmark_width) / BYTE_TO_REAL(rmark_height);
rdeviation := rmin_diff * rwidth_ratio;

// 6. 确定目标位置   以后可以改成根据色标形式控制左右方向   总体而言，是宽了往窄的方向移动，窄了往宽的方向移动
IF (i_iMarkId = MARK_TYPE_TRAPE_VFLN OR i_iMarkId = MARK_TPYE_TRAPE_VBLN) THEN
	IF (rbest_width > rstandard_value) THEN
		rtarget_pos := rbest_pos - rdeviation; // 太宽 -> 向左
	ELSIF (rbest_width < rstandard_value) THEN
		rtarget_pos := rbest_pos + rdeviation; // 太窄 -> 向右
	ELSE
		rtarget_pos := rbest_pos; // 正好
	END_IF;
ELSIF (i_iMarkId = MARK_TYPE_TRAPE_VFLP OR i_iMarkId = MARK_TYPE_TRAPE_VBLP) THEN
	IF (rbest_width > rstandard_value) THEN
		rtarget_pos := rbest_pos + rdeviation; // 太宽 -> 向右
	ELSIF (rbest_width < rstandard_value) THEN
		rtarget_pos := rbest_pos - rdeviation; // 太窄 -> 向左
	ELSE
		rtarget_pos := rbest_pos; // 正好
	END_IF;
ELSIF i_iMarkId = MARK_TYPE_LINE THEN (*条标*)
	FOR iN := 1 TO 3 DO
		// 假设位置为 -1.0 或者宽度为 -1.0 表示该点无效
		IF (i_ar_markerpos[iN] = -1 OR i_ar_width[iN] = REAL#-1.0) THEN
			CONTINUE;
		ELSE
			ibest_index := iN;
			EXIT;
		END_IF;
	END_FOR;
	(*这样可以回到零位*)
	rtarget_pos:= 0;
END_IF

// 7. 计算并返回最终移动距离
i_pBestMoveDisRS^ := rtarget_pos - rcurrent_pos;
i_pBestPositionRS^ := i_ar_markerpos[ibest_index];