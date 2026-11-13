(*@CES
Name=EnumFindState
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=4b638ac6-7ee9-4b1b-9b99-b2600605b011
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
// {attribute 'qualified_only'}
// {attribute 'strict'}
// 寻找模块状态
TYPE EnumFindState :
(
    FIND_STATE_IDLE := 0,                (* 0空闲 *)
    FIND_STATE_INIT,                     (* 1初始化 *)
    FIND_STATE_WAIT_PRESS,               (* 2等待合压 *)
    FIND_STATE_CHECK_COARSE,             (* 3检查粗调 *)
    FIND_STATE_DELAY_SINGLE,             (* 4单色前延时 *)
    FIND_STATE_FIND_SINGLE,              (* 5寻找单色 *)
    FIND_STATE_MOVE_FIBER,               (* 6移动光纤 *)
    FIND_STATE_WAIT_FIBER_MOVE,          (* 7等待光纤移动 *)
    FIND_STATE_CALC_BEST,                (* 8计算最佳位置 *)
    FIND_STATE_ADJUST_GATE,              (* 9调整波门 *)
    FIND_STATE_DELAY_MIX,                (* 10混色前延时 *)
    FIND_STATE_FINE_ADJUST,              (* 11光纤精调 *)
    FIND_STATE_WAIT_FINE_ADJ,            (* 12等待精调完成 *)
    FIND_STATE_FIND_MIX,                 (* 13寻找混色 *)
    FIND_STATE_COMPLETE,                 (* 14完成 *)
    FIND_STATE_ERROR                     (* 15错误 *)
);
END_TYPE
{IMPLEMENTATION}
