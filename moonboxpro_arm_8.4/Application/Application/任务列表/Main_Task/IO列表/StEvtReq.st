(*@CES
Name=StEvtReq
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=8252279d-9d67-4d9b-8f5c-5fb7a358024a
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StEvtReq :
STRUCT
	xEvt_Estop						: BOOL; (* 急停 *)
	xEvt_Stop						: BOOL; (* 停机 *)
	xEvt_Tension					: BOOL; (* 张力投入 *)
	xEvt_ManuSpdUp					: BOOL; (* 手动加速 *)
	xEvt_ManuSpdDn					: BOOL; (* 手动减速 *)
	xEvt_Ink						: BOOL; (* 空转 *)
	xEvt_Prestart					: BOOL; (* (预)启动 *)
	xEvt_PressAll					: BOOL; (* 全体合压 *)
	xEvt_UnpressAll					: BOOL; (* 全体离压 *)
	xEvt_Print						: BOOL; (* 印刷|联动 *)
	xEvt_AlarmBell					: BOOL; (* 报警 *)
	xEvt_AllInchRun					: BOOL; (* 整机单动 *)
	xEvt_AllExhBlower				: BOOL; (* 整机排风 *)
	xEvt_AllCoolBlower				: BOOL; (* 整机冷风 *)
	xEvt_AllHotBlower				: BOOL; (* 整机热风 *)
	xEvt_AllHeating					: BOOL; (* 整机加热 *)
	xEvt_TapPosition_Printing		: BOOL; (* 2018.7.16.151840/印刷档位 *)
	xEvt_TapPosition_Breaking		: BOOL; (* 2018.7.16.151514/断料档位 *)
	xEvt_TapPosition_UniformInk		: BOOL; (* 2018.7.16.151507/匀墨档位 *)
	xEvt_FastStop					: BOOL;	(* 2022.4.6.110418 快停*)

	xReqEstop						: BOOL; (* 急停 *)
	xReqStop						: BOOL; (* 停机 *)
	xReqTension						: BOOL; (* 张力投入 *)
	xReqManuSpdUp					: BOOL; (* 手动加速 *)
	xReqManuSpdDn					: BOOL; (* 手动减速 *)
	xReqInk							: BOOL; (* 空转 *)
	xReqPrestart					: BOOL; (* (预)启动 *)
	xReqPressAll					: BOOL; (* 全体合压 *)
	xReqUnpressAll					: BOOL; (* 全体离压 *)
	xReqPrint						: BOOL; (* 印刷|联动 *)
	xReqAlarmBell					: BOOL; (* 报警 *)
	xReqAllInchRun					: BOOL; (* 整机单运行 *)
	xReqAllExhBlower				: BOOL; (* 整机排风 *)
	xReqAllCoolBlower				: BOOL; (* 整机冷风 *)
	xReqAllHotBlower				: BOOL; (* 整机热风 *)
	xReqAllHeating					: BOOL; (* 整机加热 *)
	xReqFastStop					: BOOL;	(* 2022.4.6.110418 快停*)	
END_STRUCT
END_TYPE

{IMPLEMENTATION}
