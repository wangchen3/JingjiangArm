(*@CES
Name=KS_CalculateMixFindDelayTime
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2d7bebb1-5781-4f9d-9266-922f12b4caec
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalculateMixFindDelayTime  : uint
VAR_INPUT
    i_iAxisId: INT;                        (* 轴号 *)
    i_iBeforeAxisId: INT;                  (* 前轴号 *)
    i_pstUnitParam_Save: POINTER TO StUnitParam_Save; (* 单元参数 *)
    i_rVel: REAL;                          (* 速度 *)
END_VAR
VAR
    uiDelayTime: UINT;                     (* 延时时间@ms *)
    pstUnitParam_Save: POINTER TO StUnitParam_Save;
    rWaitTime: REAL;                       (* 等待时间@s *)
    rFilmLength: REAL;                     (* 料长@m *)
END_VAR
{IMPLEMENTATION}
pstUnitParam_Save := i_pstUnitParam_Save;
uiDelayTime := 0;

(* 计算前一色到此色的料长 *)
IF i_iBeforeAxisId <> -1 THEN
    (* 获取前一色到此色的料长 *)
    rFilmLength := (pstUnitParam_Save^.rFilmLengthFromPrevPressUnit)/1000.0*(i_iAxisId-i_iBeforeAxisId);
    
    (* 计算等待时间：料长(m) / 速度(m/min) * 60s/min = 等待时间(s) *)
    IF i_rVel > 0 THEN
        rWaitTime := rFilmLength / i_rVel * 60.0;
        
        (* 转换为毫秒 *)
        uiDelayTime := REAL_TO_UINT(rWaitTime * 1000.0);
    ELSE
        (* 速度为零，使用默认值 *)
        uiDelayTime := 30000;  (* 30秒 *)
    END_IF
END_IF

(* 增加安全余量（5个版周长的时间） *)
IF pstUnitParam_Save^.rGirth_PrnRoller > 0 AND i_rVel > 0 THEN
    rWaitTime := 5.0 * pstUnitParam_Save^.rGirth_PrnRoller / 1000.0 / i_rVel * 60.0;
    uiDelayTime := uiDelayTime + REAL_TO_UINT(rWaitTime * 1000.0);
END_IF

(* 最小延时时间 *)
IF uiDelayTime < 1000 THEN
    uiDelayTime := 1000;  (* 至少1秒 *)
END_IF

KS_CalculateMixFindDelayTime := uiDelayTime;