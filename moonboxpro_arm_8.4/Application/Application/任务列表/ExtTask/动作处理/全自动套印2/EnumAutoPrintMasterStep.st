(*@CES
Name=EnumAutoPrintMasterStep
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=e561adc0-0517-4418-b830-643ab1aeef13
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
// 主控制状态机枚举
TYPE EnumAutoPrintMasterStep :
(
    APM_STEP_IDLE := 0,                  (* 1空闲 *)
    APM_STEP_TIPS,                       (* 2提示 *)
    APM_STEP_TIPS_ALARM,                 (* 3警铃提示 *)
    APM_STEP_AUTO_HOR,                   (* 4横向预对版 *)
    APM_STEP_AUTOING_HOR,                (* 5横向对版中 *)
    APM_STEP_AUTOSENSORPOS,              (* 6自动传感器位置 *)
    APM_STEP_SENSORPOSBYSYS3RD,          (* 7第三方设备获取传感器位置 *)
    APM_STEP_WAITPOSBY3RD,               (* 8等待第三方位置 *)
    APM_STEP_SENSORPOSBYMANU,            (* 9手动获取传感器位置 *)
    APM_STEP_WAITPOSBYMANU,              (* 10等待手动位置 *)
    APM_STEP_SENSOR_TO_TARGETPOS,        (* 11传感器到目标位置 *)
    APM_STEP_SENSOR_TO_TARGETPOSING,     (* 12传感器到目标位置中 *)
    APM_STEP_AUTO_VER,                   (* 13纵向全自动套印 *)
    APM_STEP_AUTOING_VER,                (* 14纵向全自动套印中 *)
    APM_STEP_AUTODNE_VER,                (* 15纵向全自动套印完成 *)
	APM_STEP_CALC_ADJUSTMENTS,             (** 16计算调整量 *)
    APM_STEP_FAST_ADJUSTMENT,              (** 17快速对版调整 *)
    APM_STEP_COMPLETE,                     (** 18完成 *)
    APM_STEP_TIMEOUT,                    (* 19超时 *)
    APM_STEP_ERR                         (* 20错误 *)
);
END_TYPE

{IMPLEMENTATION}
