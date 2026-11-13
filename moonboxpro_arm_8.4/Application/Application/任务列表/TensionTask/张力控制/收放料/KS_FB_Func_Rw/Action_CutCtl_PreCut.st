(*@CES
Name=Action_CutCtl_PreCut
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=5f8699dd-125c-4ab6-8530-cc778a5eeade
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

(*---------------------------2017-08-17 10:41:00
/.收料预备接料
.----------------------------------------------*)
IF fbRTrig_PreCut.Q AND(*按下接料准备*)
	(NOT i_xFlag_Estop) AND (*非急停状态*)
	(*2022.4.23.151132*)
	(NOT i_xFlag_estoping) AND(*非急停止中*)
	(NOT i_xFlag_stoping) AND(*非停止中*)
	(NOT i_xFlag_FastStoping) AND (*非快停*)
	(NOT o_xSts_PreCutting) THEN (*非接料预备状态*)
	xSts_Limited_AxisLocaltion:= FALSE;
	xSts_ArmFall_end:= FALSE;
	o_xSts_PreCutting:= TRUE;
	xSts_WaitingCut:= FALSE;
	xSts_ArmFalling:= FALSE;
	fbRTrig_Cut(CLK:= FALSE);
	fbRTrig_AxisALimit(CLK:= FALSE);
	fbRTrig_AxisBLimit(CLK:= FALSE);

END_IF

(*接料解除逻辑*)

(*收料*)
IF (fbRTrig_CancelCut.Q AND o_xSts_PreCutting) OR
	xFlag_Cut_end_Out OR
	i_xEstop_Input OR
	i_xStop_Input OR
	i_xFlag_Estop THEN

	xSts_Limited_AxisLocaltion:= FALSE;
	xSts_ArmFall_end:= FALSE;
	o_xSts_PreCutting:= FALSE;
	xSts_WaitingCut:= FALSE;
	xSts_ArmFalling:= FALSE;

(*		fbRTrig_PreCut_Rw(CLK:= FALSE);*)
	fbRTrig_Cut(CLK:= FALSE);
(*		fbRTrig_CancelCut_Rw(CLK:= FALSE);*)
	fbRTrig_AxisALimit(CLK:= FALSE);
	fbRTrig_AxisBLimit(CLK:= FALSE);
//	fbRTrig_AxisExchg_Rw(CLK:= FALSE);

	xFlag_Cut_end_Out:=FALSE;

	(*大臂上的动作*)
		
	i_pstStEvtReq^.xOutCutHolder_Up:= FALSE; (*大臂收回*)
	i_pstStEvtReq^.xOutCutCylinder_Up:= FALSE; (*胶辊收回*)
	i_pstStEvtReq^.xOutCutter_Up:= FALSE; (*裁刀收回*)

	i_pstStEvtReq^.xOutCutHolder_Dn:= FALSE; (*大臂收回*)
	i_pstStEvtReq^.xOutCutCylinder_Dn:= FALSE; (*胶辊收回*)
	i_pstStEvtReq^.xOutCutter_Dn:= FALSE; (*裁刀收回*)

END_IF

IF o_xSts_PreCutting THEN (*收料接料准备中*)
	IF xCutAxisA_In_Out THEN(*当前轴为A轴|计算B轴的直径*)
		o_rDiam_NewVol:= LREAL_TO_REAL(rGirth_AxisB_In_Out/gc_lrPI);
	ELSE(*当前轴为B轴|计算A轴的直径*)
		o_rDiam_NewVol:= LREAL_TO_REAL(rGirth_AxisA_In_Out/gc_lrPI);
	END_IF
END_IF

