(*@CES
Name=Action_LampIODeal
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=52bb145f-22d0-45ec-b9b1-b9325da54028
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}

(*2017-08-26 08:49:31
/.放料预驱灯
*)

IF xFlag_PreDrv_end_Out AND (NOT xFlag_PreDrv_ing_Out) THEN
	i_pstStEvtReq^.xOutLampPreDrive:= TRUE;
ELSE
	i_pstStEvtReq^.xOutLampPreDrive:= FALSE;
END_IF

(*2020.10.9.171501 弧面信号丢失的时候我们闪烁同步指示灯提示|Liu.yt*)
(*2021.4.30.111152 增加了调试确认放料定位绝对值时预驱灯闪烁*)
fbTonFLick_Lamp_preDrive(IN:=xReflectSensorLoss_Out OR xDebug_Enc_In_Out_UwRw,PT:=T#500MS);
IF fbTonFLick_Lamp_preDrive.Q THEN(*500ms计时到*)
	xLamp_PreDrive:=NOT xLamp_PreDrive;
	fbTonFLick_Lamp_preDrive(IN:=FALSE);(*清计时*)
END_IF
(*弧面丢失的时候预驱灯由闪烁变量控制*)
IF xReflectSensorLoss_Out OR xDebug_Enc_In_Out_UwRw THEN(*2021.4.30.111152 增加了调试确认放料定位绝对值时预驱灯闪烁*)
	i_pstStEvtReq^.xOutLampPreDrive:=xLamp_PreDrive;
ELSE(*没有丢失时临时变量保持和预驱灯同步*)
	xLamp_PreDrive:=i_pstStEvtReq^.xOutLampPreDrive;
END_IF
(*2021.8.27.144707 同步*)
(*2021.8.4.105830  卷径标定时预驱指示闪烁表征标定区间num*)
(*自动接料时闪烁指示-在非北人情况下才能起作用|2022.6.8.171815*)
i_pstStEvtReq^.xOutLampPreDrive:=i_pstStEvtReq^.xOutLampPreDrive OR xLamp_DiaMeasureArea
				OR
				(xLampAutoMaticCutting AND
				 i_iCustomerNameId<>CUSTOMERNAME_BEIREN AND
				 i_iCustomerNameId<>CUSTOMERNAME_BEIREN_NOLOGO);
(*2021.9.2.104951  增加放料轴速度的调试指示*)
i_pstStEvtReq^.xOutLampPreDrive:= i_pstStEvtReq^.xOutLampPreDrive OR (xLampFlick_AxisVelDebug AND NOT xReflectSensorLoss_Out);

(*2022.4.2.113806  放料急停指示灯输出控制|*)
i_pstStEvtReq^.xOutEstop:= i_pstStEvtReq^.xEvt_Estop AND i_xFlag_Estop;

(*2022.4.2.225611  预备接料的时候输出响铃信号*)
i_pstStEvtReq^.xOutAlarmBell:= o_xSts_PreCutting (*AND(*接料准备中*)
(*									pstStGrpParam^.xFlag_Print AND(*印刷状态*)*)
								(i_pstStIOMap_Uw^.o_xRel_TowerForeward OR(*翻转架运动时候*)
								i_pstStIOMap_Uw^.o_xRel_TowerReversal)*);

(*2025.7.1.100951优化*)

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
IF xCutHolderSts_Retain THEN
	xCutHolderSts_Retaining:=TRUE;
	i_pstStEvtReq^.xOutCutHolder_Up:= xCutHolderSts_UpCut_WhenSaftyGratingOn;
	i_pstStEvtReq^.xOutCutHolder_Dn:= xCutHolderSts_DnCut_WhenSaftyGratingOn;
ELSIF xCutHolderSts_Retaining THEN
	xCutHolderSts_Retaining:= FALSE;
	i_pstStEvtReq^.xOutCutHolder_Up:=FALSE;
	i_pstStEvtReq^.xOutCutHolder_Dn:=FALSE;
END_IF