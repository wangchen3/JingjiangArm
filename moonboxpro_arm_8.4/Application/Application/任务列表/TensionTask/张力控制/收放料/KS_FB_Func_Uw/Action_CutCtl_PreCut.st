(*@CES
Name=Action_CutCtl_PreCut
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=ae5a1269-630e-4ed9-82ea-cf14ddab8b91
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*---------------------------2017-08-17 10:31:06
/.放料预备接料
.----------------------------------------------*)
IF (fbRTrig_PreCut.Q OR(*按下接料准备*)
	xFlag_Measuring) AND(*进行标准卷径测量*)
	(NOT i_xFlag_Estop) AND (*非急停状态*)
	(*2022.4.23.151132*)
	(NOT i_xFlag_estoping) AND(*非急停止中*)
	(NOT i_xFlag_stoping) AND(*非停止中*)
	(NOT i_xFlag_FastStoping) AND (*非快停*)
	(NOT o_xSts_PreCutting) THEN (*非接料预备状态*)
	xSts_Limited_AxisLocaltion:= FALSE;
	xSts_ArmFall_end:= FALSE;
	o_xSts_PreCutting:= TRUE;
	xSts_Sensor1Ok:= FALSE;
	xSts_WaitingCut:= FALSE;
	xSts_ArmFalling:= FALSE;
	fbRTrig_Cut(CLK:= FALSE);
	fbRTrig_AxisALimit(CLK:= FALSE);
	fbRTrig_AxisBLimit(CLK:= FALSE);
	fbRTrig_Sensor1(CLK:= FALSE);
END_IF


(*接料解除逻辑*)

(*放料*)
IF (fbRTrig_CancelCut.Q  AND o_xSts_PreCutting) OR
	xFlag_Cut_end_Out 	OR
	i_xEstop_Input OR
	i_xStop_Input OR
	i_xFlag_Estop OR
	xFlag_Measured OR (*增加最小径处理*)
	xMiniumuDiamProtect THEN (*标准卷径测量完成*)

	xSts_Limited_AxisLocaltion:= FALSE;
	xSts_ArmFall_end:= FALSE;
	o_xSts_PreCutting:= FALSE;
	xSts_Sensor1Ok:= FALSE;
	xSts_WaitingCut:= FALSE;
	xSts_ArmFalling:= FALSE;
	xFlag_DiamCalc_end_In_Out:= FALSE;
	xFlag_DiamCalc_ing_In_Out:= FALSE;

(*		fbRTrig_PreCut_Uw(CLK:= FALSE);*)
	fbRTrig_Cut(CLK:= FALSE);
(*		fbRTrig_CancelCut_Uw(CLK:= FALSE);*)
	fbRTrig_AxisALimit(CLK:= FALSE);
	fbRTrig_AxisBLimit(CLK:= FALSE);
	fbRTrig_Sensor1(CLK:= FALSE);
//	fbRTrig_AxisExchg(CLK:= FALSE);

	xFlag_Cut_end_Out:=FALSE;

	(*大臂上的动作*)
	i_pstStEvtReq^.xOutCutHolder_Up:= FALSE; (*大臂收回*)
	i_pstStEvtReq^.xOutCutCylinder_Up:= FALSE; (*胶辊收回*)
	i_pstStEvtReq^.xOutCutter_Up:= FALSE; (*裁刀收回*)

	i_pstStEvtReq^.xOutCutHolder_Dn:= FALSE; (*大臂收回*)
	i_pstStEvtReq^.xOutCutCylinder_Dn:= FALSE; (*胶辊收回*)
	i_pstStEvtReq^.xOutCutter_Dn:= FALSE; (*裁刀收回*)
(*
	(*放料卷径测量标志清除*)
	FOR iN:=1 TO SIZEOF(pstStGrpParam^.axMeasure_StdVol)/SIZEOF(pstStGrpParam^.axMeasure_StdVol[1]) BY 1 DO
		pstStGrpParam^.axMeasure_StdVol[iN]:= FALSE;
	END_FOR
*)	
	(*2021.8.27.144632 同步*)
	(*2021.8.4.110427 |替换*)
	IF xIsDebuging_DiaMeasure_In_Out THEN
		xCancelDebuging_DiaMeasure_In_Out:=TRUE;
	END_IF
END_IF