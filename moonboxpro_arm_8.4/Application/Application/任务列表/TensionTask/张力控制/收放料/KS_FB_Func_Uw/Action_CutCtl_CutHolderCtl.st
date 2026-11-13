(*@CES
Name=Action_CutCtl_CutHolderCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=c6b634c9-b59c-4376-bf25-787beb9a6a9a
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*---------------------------2017-08-17 11:30:42
/.放料限位信号
.----------------------------------------------*)
(*2018.9.30.105824 | niu.j | 收料限位取反，当前A轴限位取B轴*)
IF (xCutAxisA_In_Out AND fbRTrig_AxisBLimit.Q) OR
	((NOT xCutAxisA_In_Out) AND fbRTrig_AxisALimit.Q) THEN
	xSts_Limited_AxisLocaltion:= TRUE;
END_IF

(*
/.han.dp| 2018.4.2.173246|
/.检查放料大臂的输出状态|
/.*)
(*------------------------调试控制大臂-----------------------START*)
(*2021.7.15.165418 增加在放料调试过程中大臂使用接料按钮控制上下逻辑*)
IF xDebug_Enc_In_Out_UwRw THEN(*调试过程中|才能使用这种方式控制*)
	IF NOT o_xSts_PreCutting THEN(*只有在非接料状态下才可以执行*)
		IF xCutHolderCanDebug THEN(*有效一个周期|取反大臂状态*)
			IF io_xCutOnTop THEN
				i_pstStEvtReq^.xOutCutHolder_Up:= NOT i_pstStEvtReq^.xOutCutHolder_Up;
				xCutHolderDn_Debug:=i_pstStEvtReq^.xOutCutHolder_Up;
			ELSE
				i_pstStEvtReq^.xOutCutHolder_Dn:= NOT i_pstStEvtReq^.xOutCutHolder_Dn;
				xCutHolderDn_Debug:=i_pstStEvtReq^.xOutCutHolder_Dn;
			END_IF
		END_IF
	END_IF
END_IF

IF NOT xDebug_Enc_In_Out_UwRw OR o_xSts_PreCutting THEN(*清除调试状态下大臂的下压*)
	IF xCutHolderDn_Debug THEN(*有被下压了|抬起来*)
		xCutHolderDn_Debug:=FALSE;
		IF io_xCutOnTop THEN
			i_pstStEvtReq^.xOutCutHolder_Up:= FALSE;
		ELSE
			i_pstStEvtReq^.xOutCutHolder_Dn:=FALSE;
		END_IF
	END_IF
END_IF
(*------------------------调试控制大臂-----------------------END*)

IF io_xCutOnTop THEN
	xCutHolder_InPosition:= i_pstStEvtReq^.xOutCutHolder_Up;
ELSE
	xCutHolder_InPosition:= i_pstStEvtReq^.xOutCutHolder_Dn;
END_IF
IF o_xSts_PreCutting AND (*接料准备中状态*)
	xSts_Limited_AxisLocaltion AND (*限位到*)
	(NOT xCutHolder_InPosition) THEN (*大臂未输出*)

	IF io_xCutOnTop THEN
		i_pstStEvtReq^.xOutCutHolder_Up:= TRUE;
	ELSE
		i_pstStEvtReq^.xOutCutHolder_Dn:= TRUE;
	END_IF
	xSts_ArmFalling:= TRUE; (*下落中*)
	xSts_ArmFall_end:= FALSE; (*还未下落完成*)
END_IF

fbTon_ArmFalling(
	IN:= xSts_ArmFalling,
	PT:= INT_TO_TIME(iDelayMsec_CutterHolder_Final));
IF fbTon_ArmFalling.Q AND (NOT xSts_ArmFall_end) THEN
	xSts_ArmFall_end:= TRUE; (*放料大臂正式落下*)
	xSts_ArmFalling:= FALSE;
END_IF