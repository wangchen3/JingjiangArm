(*@CES
Name=EnumFindErrorCode
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=764d2f18-3722-49fd-bd0f-02e1ffafaf8d
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
// 寻找错误代码枚举
TYPE EnumFindErrorCode :
(
   	FIND_ERR_NONE := 0,                  (* 无错误 *)
    FIND_ERR_COARSE_NOT_READY := 88,     (* 粗调未到位 *)
    FIND_ERR_WAITING_CIRCLE := 50,       (* 等待1.5圈中 *)
    FIND_ERR_WAITING_FIBER_IDLE := 51,   (* 等待光纤空闲 *)
    FIND_ERR_SINGLE_MARK_NOT_FOUND := 101,(* 单色标记未找到 *)
    FIND_ERR_CALC_BEST_FAILED := 102,    (* 最佳位置计算失败 *)
    FIND_ERR_PRE_POS_INVALID := 103,     (* 前色位置无效 *)
    FIND_ERR_WAITING_SINGLE_INFO := 53,  (* 等待单色新的一圈信息 *)
    FIND_ERR_WAITING_MIX_INFO := 54,     (* 等待前色信息 *)
    FIND_ERR_TIMEOUT := 200,             (* 超时 *)
    FIND_ERR_AXIS_ID_INVALID := 201,     (* 轴ID无效 *)
    FIND_ERR_NOT_ENABLED := 202,         (* 未使能 *)
    FIND_ERR_UNKNOWN := 255              (* 未知错误 *)
);
END_TYPE
{IMPLEMENTATION}
