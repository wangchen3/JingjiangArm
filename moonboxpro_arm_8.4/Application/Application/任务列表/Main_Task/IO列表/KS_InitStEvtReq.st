(*@CES
Name=KS_InitStEvtReq
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=29056b31-c015-4828-ae2e-3b4c94234de1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitStEvtReq : INT
VAR_INPUT
	i_pstStEvtReq: POINTER TO StEvtReq;
END_VAR
VAR
	iResult: INT;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_pstStEvtReq<>0 THEN
	i_pstStEvtReq^.xEvt_Estop:= FALSE; (* 急停 *)
	i_pstStEvtReq^.xEvt_Stop:= FALSE; (* 停机 *)
	i_pstStEvtReq^.xEvt_FastStop:= FALSE; (* 快速停机 *)
	i_pstStEvtReq^.xEvt_Tension:= FALSE; (* 张力投入 *)
	i_pstStEvtReq^.xEvt_ManuSpdUp:= FALSE; (* 手动加速 *)
	i_pstStEvtReq^.xEvt_ManuSpdDn:= FALSE; (* 手动减速 *)
	i_pstStEvtReq^.xEvt_Ink:= FALSE; (* 空转 *)
	i_pstStEvtReq^.xEvt_Prestart:= FALSE; (* (预)启动 *)
	i_pstStEvtReq^.xEvt_PressAll:= FALSE; (* 全体合压 *)
	i_pstStEvtReq^.xEvt_UnpressAll:= FALSE; (* 全体离压 *)
	i_pstStEvtReq^.xEvt_Print:= FALSE; (* 印刷/联动 *)
	i_pstStEvtReq^.xEvt_AlarmBell:= FALSE; (* 报警 *)
	i_pstStEvtReq^.xEvt_AllInchRun:= FALSE; (* 整机单动 *)
	i_pstStEvtReq^.xEvt_AllExhBlower:= FALSE; (* 排风启动 *)
	i_pstStEvtReq^.xEvt_AllCoolBlower:= FALSE; (* 2018.7.19.142033/冷风启动 *)
	i_pstStEvtReq^.xEvt_AllHotBlower:= FALSE; (* 热风启动 *)
	i_pstStEvtReq^.xEvt_AllHeating:= FALSE; (* 加热启动 *)
	i_pstStEvtReq^.xEvt_TapPosition_Printing:= FALSE; (* 2018.7.16.151840/印刷档位 *)
	i_pstStEvtReq^.xEvt_TapPosition_Breaking:= FALSE; (* 2018.7.16.151514/断料档位 *)
	i_pstStEvtReq^.xEvt_TapPosition_UniformInk:= FALSE; (* 2018.7.16.151507/匀墨档位 *)

	i_pstStEvtReq^.xReqEstop:= FALSE; (* 急停 *)
	i_pstStEvtReq^.xReqStop:= FALSE; (* 停机 *)
	i_pstStEvtReq^.xReqFastStop:= FALSE; (* 快速停机 *)
	i_pstStEvtReq^.xReqTension:= FALSE; (* 张力投入 *)
	i_pstStEvtReq^.xReqManuSpdUp:= FALSE; (* 手动加速 *)
	i_pstStEvtReq^.xReqManuSpdDn:= FALSE; (* 手动减速 *)
	i_pstStEvtReq^.xReqInk:= FALSE; (* 空转 *)
	i_pstStEvtReq^.xReqPrestart:= FALSE; (* (预)启动 *)
	i_pstStEvtReq^.xReqPressAll:= FALSE; (* 全体合压 *)
	i_pstStEvtReq^.xReqUnpressAll:= FALSE; (* 全体离压 *)
	i_pstStEvtReq^.xReqPrint:= FALSE; (* 印刷/联动 *)
	i_pstStEvtReq^.xReqAlarmBell:= FALSE; (* 报警 *)
	i_pstStEvtReq^.xReqAllInchRun:= FALSE; (* 整机单动 *)
	i_pstStEvtReq^.xReqAllExhBlower:= FALSE; (* 整机排风 *)
	i_pstStEvtReq^.xReqAllCoolBlower:= FALSE; (* 整机冷风 *)
	i_pstStEvtReq^.xReqAllHotBlower:= FALSE; (* 整机热风 *)
	i_pstStEvtReq^.xReqAllHeating:= FALSE; (* 整机加热 *)
ELSE
	iResult:= -1;
END_IF

KS_InitStEvtReq:= iResult;