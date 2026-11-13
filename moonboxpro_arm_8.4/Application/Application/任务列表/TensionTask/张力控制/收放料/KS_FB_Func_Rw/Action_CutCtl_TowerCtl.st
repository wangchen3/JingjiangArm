(*@CES
Name=Action_CutCtl_TowerCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ad4c13ab-9645-483b-b3c4-303850291c54
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*---------------------------2017-08-17 10:25:10
/.收料翻转架处理
/.带限位信号
.----------------------------------------------*)
(*正转*)
byForeward_mtf:= 0;
IF i_pstStEvtReq^.xEvt_Forward AND (*正转按钮*)
	(NOT i_pstStEvtReq^.xOutTowerRev) THEN (*并未在反转中*)
	byForeward_mtf.0:= TRUE;
END_IF
IF o_xSts_PreCutting AND (*预备接料状态*)
	(NOT io_xCutOnTop) AND
	(NOT xSts_Limited_AxisLocaltion) THEN (*限位没到*)
	byForeward_mtf.1:= TRUE;
END_IF
IF (NOT i_xFlag_Estop) AND byForeward_mtf<>0 THEN
	i_pstStEvtReq^.xOutTowerFor:= TRUE;
ELSE
	i_pstStEvtReq^.xOutTowerFor:= FALSE;
END_IF

(*反转*)
byReversal_mtf:= 0;
IF i_pstStEvtReq^.xEvt_Reversal AND (*手动反转*)
	(NOT i_pstStEvtReq^.xOutTowerFor) THEN (*并未在正转中*)
	byReversal_mtf.0:= TRUE;
END_IF
IF o_xSts_PreCutting AND (*预备接料状态*)
	(io_xCutOnTop) AND
	(NOT xSts_Limited_AxisLocaltion) THEN (*限位没到*)
	byReversal_mtf.1:= TRUE;
END_IF
IF (NOT i_xFlag_Estop) AND byReversal_mtf<>0 THEN
	i_pstStEvtReq^.xOutTowerRev:= TRUE;
ELSE
	i_pstStEvtReq^.xOutTowerRev:= FALSE;
END_IF
