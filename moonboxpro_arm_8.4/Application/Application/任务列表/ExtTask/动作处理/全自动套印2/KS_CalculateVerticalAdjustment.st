(*@CES
Name=KS_CalculateVerticalAdjustment
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=55283c42-1c2e-4d65-8dd3-8f793fe68a41
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
(*返回计算误差的点数*)
FUNCTION KS_CalculateVerticalAdjustment : real
VAR_INPUT
    i_iAxisId: INT;                        (* 轴号 *)
    i_iCurBestSignalPos: INT;              (* 当前色最佳位置 *)
    i_iPreLabelPos: INT;                   (* 前色位置 *)
    i_pstUnitParam_Save: POINTER TO StUnitParam_Save; (* 单元参数 *)
    i_pstGrpParam_Save: POINTER TO StGrpParam_Save;  (* 组参数 *)
END_VAR
VAR
   	rAdjValue: REAL;                       (* 调整量@粗采样点数*)
    pstUnitParam_Save: POINTER TO StUnitParam_Save;
    pstGrpParam_Save: POINTER TO StGrpParam_Save;
    rTmp: REAL;
END_VAR
{IMPLEMENTATION}
pstUnitParam_Save := i_pstUnitParam_Save;
pstGrpParam_Save := i_pstGrpParam_Save;

(* 初始化返回值 *)
rAdjValue := 0.0;

(* 检查输入有效性 *)
IF i_iCurBestSignalPos >= 0 AND i_iPreLabelPos >= 0 AND
   i_iCurBestSignalPos < 4000 AND i_iPreLabelPos < 4000 THEN
    
    (* 根据标记排列方式计算调整量 *)
    IF pstUnitParam_Save^.iMarkArrangeMode = MARK_ARRANGE_VFOR THEN
        (* 正向排列 *)
        rTmp := INT_TO_REAL(i_iCurBestSignalPos - i_iPreLabelPos - 
                   LREAL_TO_INT(20.0 * MAX_ROUNDSAMPLE_NUM / pstUnitParam_Save^.rGirth_PrnRoller));
    ELSIF pstUnitParam_Save^.iMarkArrangeMode = MARK_ARRANGE_VREV THEN
        (* 反向排列 *)
        rTmp := INT_TO_REAL(i_iCurBestSignalPos - i_iPreLabelPos + 
                   LREAL_TO_INT(20.0 * MAX_ROUNDSAMPLE_NUM / pstUnitParam_Save^.rGirth_PrnRoller));
    ELSE
        (* 默认处理 *)
        rTmp := INT_TO_REAL(i_iCurBestSignalPos - i_iPreLabelPos);
    END_IF
    
    (* 将调整的粗采样点数转换到±MAX_ROUNDSAMPLE_NUM/2范围内 *)
    WHILE rTmp < -MAX_ROUNDSAMPLE_NUM / 2.0 DO
        rTmp := rTmp + MAX_ROUNDSAMPLE_NUM;
    END_WHILE
    WHILE rTmp > MAX_ROUNDSAMPLE_NUM / 2.0 DO
        rTmp := rTmp - MAX_ROUNDSAMPLE_NUM;
    END_WHILE
    
    (* 计算um单位：调整量(um) = 点数 * 版辊周长(um) / 总采样点数 *)
   // rAdjValue := rTmp * pstUnitParam_Save^.rGirth_PrnRoller * 1000.0 / MAX_ROUNDSAMPLE_NUM;
END_IF

KS_CalculateVerticalAdjustment := rTmp;