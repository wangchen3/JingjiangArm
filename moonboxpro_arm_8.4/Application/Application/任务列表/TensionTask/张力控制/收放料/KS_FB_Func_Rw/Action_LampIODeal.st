(*@CES
Name=Action_LampIODeal
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=4ba025f7-4774-4c56-b494-eb688faceaef
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

(*收料预驱灯*)
IF xFlag_PreDrv_end_Out AND (NOT xFlag_PreDrv_ing_Out) THEN
	i_pstStEvtReq^.xOutLampPreDrive:= TRUE;
ELSE
	i_pstStEvtReq^.xOutLampPreDrive:= FALSE;
END_IF


(*2021.6.1.084546 增加收料预驱灯闪烁*)
fbTonFLick_Lamp_preDrive(IN:= xDebug_Enc_In_Out_UwRw,PT:=T#500MS);
IF fbTonFLick_Lamp_preDrive.Q THEN(*500ms计时到*)
	xLamp_PreDrive:=NOT xLamp_PreDrive;
	fbTonFLick_Lamp_preDrive(IN:=FALSE);(*清计时*)
ELSIF NOT xDebug_Enc_In_Out_UwRw THEN
	xLamp_PreDrive:= FALSE;
END_IF

(*2021.9.2.104951  增加收料轴速度的调试指示*)
(*自动接料时闪烁指示-在非北人情况下才能起作用|2022.6.8.171810*)
i_pstStEvtReq^.xOutLampPreDrive:=i_pstStEvtReq^.xOutLampPreDrive OR xLamp_PreDrive
				OR xLampFlick_AxisVelDebug OR
				(xLampAutoMaticCutting AND
				 i_iCustomerNameId<>CUSTOMERNAME_BEIREN AND
				 i_iCustomerNameId<>CUSTOMERNAME_BEIREN_NOLOGO);
				 

(*2022.4.2.113806  收料急停指示灯输出控制|*)
i_pstStEvtReq^.xOutEstop:= i_pstStEvtReq^.xEvt_Estop AND i_xFlag_Estop;

(*2022.4.2.225611  预备接料的时候输出响铃信号*)
(*2025.7.1.100951优化*)
(*界面按照放料输入|在这里赋值给收料*)
IF byAlarmHold_PreCut_In = 0 THEN(*长时间报警*)
	i_pstStEvtReq^.xOutAlarmBell:=o_xSts_PreCutting;
ELSE
	fbAlarmHoldTon_PreCut(IN:=o_xSts_PreCutting,
			PT:=UINT_TO_TIME(BYTE_TO_UINT(byAlarmHold_PreCut_In)*1000));
	IF NOT fbAlarmHoldTon_PreCut.Q THEN(*时间没到按照状态输出*)
		i_pstStEvtReq^.xOutAlarmBell:=o_xSts_PreCutting;
	ELSE(*时间到了*)
		i_pstStEvtReq^.xOutAlarmBell:=FALSE;
	END_IF
END_IF

(*2022.4.13.163636 增加大臂保持当前状态逻辑
触发光栅报警时候*)
IF xCutHolderSts_Retain THEN
	xCutHolderSts_Retaining:=TRUE;
	i_pstStEvtReq^.xOutCutHolder_Up:= xCutHolderSts_UpCut_WhenSaftyGratingOn;
	i_pstStEvtReq^.xOutCutHolder_Dn:= xCutHolderSts_DnCut_WhenSaftyGratingOn;
ELSIF xCutHolderSts_Retaining THEN
	xCutHolderSts_Retaining:= FALSE;
	i_pstStEvtReq^.xOutCutHolder_Up:=FALSE;
	i_pstStEvtReq^.xOutCutHolder_Dn:=FALSE;
END_IF