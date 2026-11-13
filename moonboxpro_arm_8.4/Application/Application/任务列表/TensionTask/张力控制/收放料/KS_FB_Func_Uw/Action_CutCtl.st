(*@CES
Name=Action_CutCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=d9c4dcf8-9fd2-4d8c-bf66-d7d26f8ed172
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*先处理一下上下裁切换*)
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

iDelayMsec_CutterHolder_Final:= io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_CutterHolder;
iDelayMsec_RollerCylinder_Final:= io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_RollerCylinder;
iDelayMsec_CutOffKnifeCylinder_Final:= io_astStTimeSet_DnCut_UpCut[BOOL_TO_INT(io_xCutOnTop)].iDelayMsec_CutOffKnifeCylinder;




(*放料端*)
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

(*//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//自动接料放在这里处理吧-都属于接料*)
Action_CutCtl_AutoCut();
(*接料准备动作处理*)
(*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*)
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

////////////////////////////////////////////////////////////////////////////////////////////////////////
Action_CutCtl_AbsEncForTower();
////////////////////////////////////////////////////////////////////////////////////////////////////////

(*处理定位逻辑*)

(*重新处理定位沿逻辑-在这里取值，底下逻辑使用|2021.4.8.173338@Liu.yt*)
(*放料|为了和底下逻辑兼容|分别定义了AB轴定位变量*)
IF io_xCutOnTop THEN(*上裁刀*)
	xAxisALocation_Use:= i_pstStEvtReq^.xEvt_AxisA_Locating_Up;
	xAxisBLocation_Use:= i_pstStEvtReq^.xEvt_AxisB_Locating_Up;
	xMinimumDiamLocation_Use:=i_pstStEvtReq^.xEvt_MinimumDiamProtect_Up;
ELSE(*下裁刀*)
	xAxisALocation_Use:= i_pstStEvtReq^.xEvt_AxisA_Locating_Dn;
	xAxisBLocation_Use:= i_pstStEvtReq^.xEvt_AxisB_Locating_Dn;
	xMinimumDiamLocation_Use:=i_pstStEvtReq^.xEvt_MinimumDiamProtect_Dn;
END_IF

IF xUseAbsEncoder_In THEN(*编码器方式使能了|取编码器获取的定位位置*)
	IF NOT xAxisLocationInvalid THEN(*轴定位值有效|使用编码器定位*)
		xAxisALocation_Use:=xAxisALocationByAbsEnc;
		xAxisBLocation_Use:=xAxisBLocationByAbsEnc;
	END_IF

	IF NOT xAxisLocation_MinDiaInvalid THEN(*轴最小径值有效|使用编码器定位最小径*)
		xMinimumDiamLocation_Use:=xAxisAMinimumDiamLocationByAbsEnc OR xAxisBMinimumDiamLocationByAbsEnc;
	END_IF
END_IF
(*------------------------------------------2021.4.30.105650收放料编码器方式-end*)


xAxisALocation_Use_Out:=xAxisALocation_Use;
xAxisBLocation_Use_Out:=xAxisBLocation_Use;

(*
/.han.dp| 2018.4.2.170547|
/.定位要看裁刀形式|
/.*)
(*A轴定位|*)
IF io_xCutOnTop THEN
	fbRTrig_AxisALimit(CLK:=xAxisALocation_Use(* i_pstStIOMap_Uw^.i_xAxisA_Locating_UpCut*));
ELSE
	fbRTrig_AxisALimit(CLK:= xAxisALocation_Use(*i_pstStIOMap_Uw^.i_xAxisA_Locating_DnCut*));
END_IF

(*B轴定位|*)
IF io_xCutOnTop THEN
	fbRTrig_AxisBLimit(CLK:= xAxisBLocation_Use(*i_pstStIOMap_Uw^.i_xAxisB_Locating_UpCut*));
ELSE
	fbRTrig_AxisBLimit(CLK:= xAxisBLocation_Use(*i_pstStIOMap_Uw^.i_xAxisB_Locating_DnCut*));
END_IF
(*卷径测量点到|*)
IF io_xCutOnTop THEN
	fbRTrig_Sensor1(CLK:= i_pstStEvtReq^.xEvt_Sensor_DiamMeasureLocating_Up);
ELSE
	fbRTrig_Sensor1(CLK:= i_pstStEvtReq^.xEvt_Sensor_DiamMeasureLocating_Dn);
END_IF
(*---------------------------------------------------------------*)
Action_CutCtl_CutHolderCtl();(*大臂控制*)
(*---------------------------------------------------------------*)
(*放料对射电眼到位标志放在这里处理一下，方便后续的翻转架控制限制*)

(*---------------------------2017-08-17 11:30:42
/.放料端对射电眼信号
.----------------------------------------------*)
IF o_xSts_PreCutting AND (*预驱状态*)
	fbRTrig_Sensor1.CLK AND (*对射电眼*)
	xSts_ArmFall_end AND (* 大臂落下*)
	(NOT xSts_Sensor1Ok) THEN (*对射电眼没输出*)

	xSts_Sensor1Ok:= TRUE; (*对射电眼已经有效*)
	dwCycleDelayCountdown:= INT_TO_DWORD(2500/i_iCycleTime_Plc); (*2017-08-28 10:04:00| 2.5s后才开始卷径测量*)
END_IF
(*处理一下最小径保护标志逻辑-接料取消逻辑有用*)
xMiniumuDiamProtect:= o_xSts_PreCutting AND
		xSts_ArmFall_end AND xMinimumDiamLocation_Use;(*最小径*)

(*---------------------------------------------------------------*)
(*翻转架控制*)
Action_CutCtl_TowerCtl();
(*-------------------------------------------------------------------*)


(*---------------------------------------------------------------*)
(*预备接料-接料取消控制控制*)
Action_CutCtl_PreCut();
(*-------------------------------------------------------------------*)
	
(*---------------------------------------------------------------*)
(*卷径检测控制*)
Action_CutCtl_Diameasure();
(*-------------------------------------------------------------------*)
(*---------------------------------------------------------------*)
(*预驱控制*)
Action_CutCtl_PreDrv();
(*-------------------------------------------------------------------*)
		
(*接料控制*)	
Action_CutCtl_CutDelay();
(*-------------------------------------------------------------------*)
		
		
		
		
		
