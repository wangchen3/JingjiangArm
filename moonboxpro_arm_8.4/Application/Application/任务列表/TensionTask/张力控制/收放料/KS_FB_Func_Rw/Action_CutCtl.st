(*@CES
Name=Action_CutCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=95f3c419-3c67-4406-98bb-93b8415c50f9
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//先处理一下上下裁切换
xAllowSwitchCutter_Out:= FALSE;
IF NOT (i_xFlag_Tension OR i_xFlag_Print) THEN		
(* 只要没有张力投入/也没有印刷/就可以切换上下裁 *)
	IF NOT o_xSts_PreCutting THEN	(*接料准备时候不允许切换上下裁*)
		IF i_pstStEvtReq^.xEvt_IsUpCut THEN//IO输入的上下裁切换开关
			io_xCutOnTop:= TRUE;
		ELSE
			io_xCutOnTop:= FALSE;
		END_IF
		xAllowSwitchCutter_Out:= TRUE;
	ELSE
		xSwitch_IsUpCut_HMI_In_Out:= io_xCutOnTop;
	END_IF
ELSE
	xSwitch_IsUpCut_HMI_In_Out:= io_xCutOnTop;
END_IF
i_pstStEvtReq^.xOutCutOnTop:= io_xCutOnTop;
//2026.05.21.092706



// iDelayMsec_CutterHolder_Final:= i_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_CutterHolder;
// iDelayMsec_RollerCylinder_Final:= i_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_RollerCylinder;
// iDelayMsec_CutOffKnifeCylinder_Final:= i_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_CutOffKnifeCylinder;
iDelayMsec_CutterHolder_Final:= io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_CutterHolder;
iDelayMsec_RollerCylinder_Final:= io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_RollerCylinder;
iDelayMsec_CutOffKnifeCylinder_Final:= io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_CutOffKnifeCylinder;
(*2021.7.15.144429 接料准备解除使用单个按钮还是多个按钮选择逻辑*)
xBtnPreCut:=FALSE;
xBtnCut_Cancel:=FALSE;
IF xPreCutOneBtn_In  THEN
	(*按下接料准备*)
	IF i_pstStEvtReq^.xEvt_PreCut AND
		NOT xLastPreCutBtn THEN
		xBtnPreCut:=NOT o_xSts_PreCutting;
		xBtnCut_Cancel:=o_xSts_PreCutting;
	END_IF
ELSE(*默认是多个按钮*)
	xBtnPreCut:=i_pstStEvtReq^.xEvt_PreCut;
	xBtnCut_Cancel:= i_pstStEvtReq^.xEvt_CutCancel;
END_IF
xLastPreCutBtn:=i_pstStEvtReq^.xEvt_PreCut;
(*自动接料处理*)
Action_Cutctl_AutoCut();
(*//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//自动接料放在这里处理吧-都属于接料*)
xBtnPreCut_Use:= xBtnPreCut OR xAutoMaticCutTrig_Precut;(*预备接料来自于实体按钮和自动裁切输出*)
xBtnCut_Cancel_Use:= xBtnCut_Cancel;
xBtnCut_Use:= i_pstStEvtReq^.xEvt_Cut OR xAutoMaticCutTrig_Cut;
IF xAxisDebugEn_In_Out THEN(*放料处于轴调试状态|2021.10.14.130619*)
(*按钮的输入在后面的逻辑也会使用*)
(*		fbRTrig_PreCut_Uw(CLK:= xPreCut_Debug_Uw); (*预备接料-增加调试按键|2021.10.14.112453*)
	fbRTrig_Cut_Uw(CLK:= xCut_Debug_Uw); (*接料-增加调试按键|2021.10.14.112453*)*)
	xBtnPreCut_Use:= xBtnPreCut_Debug;//xPreCut_Debug_Uw;(*2022.4.2.161051 修改为赋值方式*)
	xBtnCut_Use:=xBtnCut_Debug;
ELSE;
(*		fbRTrig_PreCut_Uw(CLK:= xPreCut_Uw ); (*预备接料*)
	fbRTrig_Cut_Uw(CLK:= i_pstStIOMap_Uw^.i_xCut ); (*接料*)*)(*2022.4.2.223851屏蔽*)
END_IF

fbLampFlick_SafeTyGrating(IN:=	xFlag_SafeTyGratingProctec_In,PT:=T#500MS);(*光栅保护触发*)
IF xFlag_SafeTyGratingProctec_In THEN
	xFlag_SafetyGratingProcting:=TRUE;(*光栅保护中*)
	xCutHolderSts_Retain:=TRUE;(*大臂保持当前状态标志*)
	IF o_xSts_PreCutting THEN(*接料准备中|取消接料准备*)
		xBtnCut_Cancel_Use:=TRUE;
	ELSE
		xBtnPreCut_Use:=FALSE;(*屏蔽接料准备按钮*)
	END_IF
	(*指示灯需要闪烁*)
	IF fbLampFlick_SafeTyGrating.Q THEN(*计时到*)
		fbLampFlick_SafeTyGrating(IN:=FALSE);
		i_pstStEvtReq^.xOutLamp_SafeTyGrating_Out:= NOT i_pstStEvtReq^.xOutLamp_SafeTyGrating_Out;
		
	END_IF
ELSE
(*保留光栅触发前的大臂状态*)
	xCutHolderSts_UpCut_WhenSaftyGratingOn:=
						i_pstStEvtReq^.xOutCutHolder_Up;//i_pstStIOMap_Uw^.o_xCutHolder_UpCut;
	xCutHolderSts_DnCut_WhenSaftyGratingOn:=
						i_pstStEvtReq^.xOutCutHolder_Dn;//i_pstStIOMap_Uw^.o_xCutHolder_DnCut;
	i_pstStEvtReq^.xOutLamp_SafeTyGrating_Out:=FALSE;//i_pstStIOMap_Uw^.o_xLamp_SafeTyGrating
	IF xFlag_SafetyGratingProcting THEN
		xFlag_SafetyGratingProcting:=FALSE;
		xCutHolderSts_Retain:=FALSE;
	END_IF	
END_IF

fbRTrig_PreCut(CLK:= xBtnPreCut_Use ); (*预备接料|2022.4.2.161112移动到此处*)
fbRTrig_Cut(CLK:= xBtnCut_Use);(*接料|2022.4.2.161112移动到此处*)
fbRTrig_CancelCut(CLK:= xBtnCut_Cancel_Use OR xBtnCut_Cancel_Debug); (*接料取消-退出调试模式的时候有可能需要接料取消*)

(*收料增加一下3/6吋切换2025.7.3.175755*)
IF NOT o_xSts_PreCutting THEN
	IF xUseKnob_6Inch_HMI_In_Out THEN(*使用界面旋钮@2024.04.16.182728*)
		xFlag_6Inch_Out:=xKnob_6Inch_HMI_In_Out;
	ELSE
		xFlag_6Inch_Out:=i_pstStEvtReq^.xEvt_PaperCoreSelect6Inch;
	END_IF
ELSE
	(*不能切换的时候旋钮的状态保持当前3 6寸状态*)
	IF xUseKnob_6Inch_HMI_In_Out THEN(*使用界面旋钮@2024.04.16.182728*)
		xKnob_6Inch_HMI_In_Out:= xFlag_6Inch_Out;
	END_IF
END_IF
(*强制清除@2024.04.16.182628*)
IF NOT xUseKnob_6Inch_HMI_In_Out THEN(*不使用界面旋钮*)
	xKnob_6Inch_HMI_In_Out:=FALSE;(**)
END_IF
////////////////////////////////////////////////////////////////////////////////////////////////////////
Action_CutCtl_AbsEncForTower();
////////////////////////////////////////////////////////////////////////////////////////////////////////
(*处理定位逻辑*)
IF xFlag_6Inch_Out THEN
	IF io_xCutOnTop  THEN(*上裁刀6寸定位-A*)
		xAxisALocation_Use:= i_pstStEvtReq^.xEvt_AxisA_Locating_UpCut_PaperCore6Inch;
	ELSE(*下裁刀6寸定位-A*)
		xAxisALocation_Use:= i_pstStEvtReq^.xEvt_AxisA_Locating_DnCut_PaperCore6Inch;
	END_IF

	IF io_xCutOnTop THEN(*上裁刀6寸定位-B*)
		xAxisBLocation_Use:= i_pstStEvtReq^.xEvt_AxisB_Locating_UpCut_PaperCore6Inch;
	ELSE(*下裁刀6寸定位-B*)
		xAxisBLocation_Use:= i_pstStEvtReq^.xEvt_AxisB_Locating_DnCut_PaperCore6Inch;
	END_IF
ELSE
	IF io_xCutOnTop  THEN(*上裁刀3寸定位-A*)
		xAxisALocation_Use:= i_pstStEvtReq^.xEvt_AxisA_Locating_Up;
	ELSE(*下裁刀3寸定位-A*)
		xAxisALocation_Use:= i_pstStEvtReq^.xEvt_AxisA_Locating_Dn;
	END_IF

	IF io_xCutOnTop THEN(*上裁刀3寸定位-B*)
		xAxisBLocation_Use:= i_pstStEvtReq^.xEvt_AxisB_Locating_Up;
	ELSE(*下裁刀3寸定位-B*)
		xAxisBLocation_Use:= i_pstStEvtReq^.xEvt_AxisB_Locating_Dn;
	END_IF
END_IF


IF xUseAbsEncoder_In THEN(*编码器方式使能了|取编码器获取的定位位置*)
	IF NOT xAxisLocationInvalid THEN(*轴定位值有效|使用编码器定位*)
		xAxisALocation_Use:=xAxisALocationByAbsEnc;
		xAxisBLocation_Use:=xAxisBLocationByAbsEnc;
	END_IF
END_IF

fbRTrig_AxisALimit(CLK:= xAxisALocation_Use);
fbRTrig_AxisBLimit(CLK:= xAxisBLocation_Use);
xAxisALocaltion_Out:= xAxisALocation_Use;
//2026.07.09.170423
xAxisBLocaltion_Out:= xAxisBLocation_Use;
i_pstStEvtReq^.xOutLamp_PaperCoreSelect6Inch:= xFlag_6Inch_Out;

(*---------------------------------------------------------------*)
Action_CutCtl_CutHolderCtl();(*大臂控制*)
(*---------------------------------------------------------------*)
(*---------------------------------------------------------------*)
(*翻转架控制*)
Action_CutCtl_TowerCtl();
(*-------------------------------------------------------------------*)
(*---------------------------------------------------------------*)
(*预备接料-接料取消控制控制*)
Action_CutCtl_PreCut();
(*-------------------------------------------------------------------*)

(*---------------------------------------------------------------*)
(*预驱控制*)
Action_CutCtl_PreDrv();
(*-------------------------------------------------------------------*)
		
(*接料控制*)	
Action_CutCtl_CutDelay();
(*-------------------------------------------------------------------*)



