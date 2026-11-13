(*@CES
Name=KS_CalBestFiberMoveDisByPS
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=54f61bec-2d54-4cc2-8835-56cc55fddebe
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalBestFiberMoveDisByPS : REAL
VAR_INPUT
	i_rwidth      		:POINTER TO REAL;    (*色标宽度*)
	rmark_width      : BYTE;                 (*三角形标宽度*)
    rmark_height     : BYTE;                 (*三角形标高度*)
	i_iMarkId        : INT; (*三角形标类型*)
	i_pBestMoveDisPS: POINTER TO REAL;
END_VAR
VAR
	rstandard_value  : REAL;                 (*标准宽度*)
	rdiff            : REAL;                 (*差值*)
    rdeviation       : REAL;                 (*差值乘比例*)
	rratio           : REAL;                 (*宽高比例*)
	rmove            : REAL;
	
END_VAR

{IMPLEMENTATION}
// 1. 安全检查：避免除零
IF (rmark_height < 1) THEN
    i_pBestMoveDisPS^ := REAL#-0.0;
    RETURN;
END_IF;

// 1. 安全检查：避免除零
IF (i_rwidth^ = 0) THEN
    i_pBestMoveDisPS^ := REAL#-0.0;
    RETURN;
END_IF;

rstandard_value := BYTE_TO_REAL(rmark_height) / 2.0;
rdiff := i_rwidth^ - rstandard_value;
rratio := BYTE_TO_REAL(rmark_width) / BYTE_TO_REAL(rmark_height);
rmove := rdiff * rratio;

// 4. 根据MARK类型决定方向
IF i_iMarkId = MARK_TYPE_TRAPE_VFLN OR i_iMarkId = MARK_TPYE_TRAPE_VBLN THEN
    i_pBestMoveDisPS^ := -rmove;  // 宽了向左调
ELSIF i_iMarkId = MARK_TYPE_TRAPE_VFLP OR i_iMarkId = MARK_TYPE_TRAPE_VBLP THEN
    i_pBestMoveDisPS^ := rmove;   // 窄了向右调
ELSIF i_iMarkId = MARK_TYPE_LINE THEN (*条标*)
	i_pBestMoveDisPS^ := 0;
END_IF;
