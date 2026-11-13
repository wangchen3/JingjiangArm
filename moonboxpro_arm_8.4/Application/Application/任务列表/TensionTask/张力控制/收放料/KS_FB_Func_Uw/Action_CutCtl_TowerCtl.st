(*@CES
Name=Action_CutCtl_TowerCtl
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=e261c074-b6a3-4d96-9fb0-3adb29677741
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*翻转架控制-*)

(*先处理正常时候的正反转-------------------------------*)
byForeward_mtf:= 0;
IF i_pstStEvtReq^.xEvt_Forward AND (*正转按钮*)
	(NOT i_pstStEvtReq^.xOutTowerRev) THEN(*并未在反转中*)
	byForeward_mtf.0:= TRUE;
END_IF
IF o_xSts_PreCutting AND (*预备接料状态*)
	(NOT xSts_Limited_AxisLocaltion) AND (*限位还没到*)
	io_xCutOnTop AND
	(NOT xSts_Sensor1Ok) THEN (*对射电眼还没有输出*)
	byForeward_mtf.1:= TRUE;
END_IF
IF o_xSts_PreCutting AND (*预备裁切状态*)
	xSts_Limited_AxisLocaltion AND (*已经限位了*)
	io_xCutOnTop AND
	xSts_ArmFall_end AND (*大臂也已经落下*)
	(NOT xSts_Sensor1Ok) THEN (*对射电眼还没有输出*)
	byForeward_mtf.2:= TRUE;
END_IF
IF (NOT i_xFlag_Estop) AND byForeward_mtf<>0 THEN
	i_pstStEvtReq^.xOutTowerFor:= TRUE;
ELSE
	i_pstStEvtReq^.xOutTowerFor:=FALSE;
END_IF

(*反转*)
byReversal_mtf:= 0;
IF i_pstStEvtReq^.xEvt_Reversal AND (*手动反转*)
	(NOT i_pstStEvtReq^.xOutTowerFor) THEN (*并未在正转中*)
	byReversal_mtf.0:= TRUE;
END_IF
IF o_xSts_PreCutting AND (*预备接料状态*)
	(NOT xSts_Limited_AxisLocaltion) AND (*限位还没到*)
	(NOT io_xCutOnTop) AND
	(NOT xSts_Sensor1Ok) THEN (*对射电眼还没有输出*)
	byReversal_mtf.1:= TRUE;
END_IF
IF o_xSts_PreCutting AND (*预备裁切状态*)
	xSts_Limited_AxisLocaltion AND (*已经限位了*)
	(NOT io_xCutOnTop) AND
	xSts_ArmFall_end AND (*大臂也已经落下*)
	(NOT xSts_Sensor1Ok) THEN (*对射电眼还没有输出*)
	byReversal_mtf.2:= TRUE;
END_IF
IF (NOT i_xFlag_Estop) AND byReversal_mtf<>0 THEN
	i_pstStEvtReq^.xOutTowerRev:= TRUE;
ELSE
	i_pstStEvtReq^.xOutTowerRev:= FALSE;
END_IF
(* 
// IF i_pstStNewIOMap_UwRw<>0 THEN
// 	(*获取输入*)
// 	KS_MutexOut_MultInput(
// 	xTowerForing,
// 	xTowerReving,
// 	200,(*延迟200ms输出*)
// (*2022.9.15.134535写入到局部变量*)
// (*
// 	ADR(i_pstStNewIOMap_UwRw^.o_xRel_TowerForeward),
// 	ADR(i_pstStNewIOMap_UwRw^.o_xRel_TowerReversal),
// *)
// 	ADR(xRel_TowerForward),
// 	ADR(xRel_TowerReversal),
// 	ADR(fbTon_TowerForOrRevMutexOut));
// END_IF

*)
(*放料翻转架补偿功能*)
(*2021.7.26.082435*)
(*翻转架运动放料补偿------------------------------------------------START*)
(*翻转架运动时候进行补偿*)
(*参数初始化|按照奥特马结构*)
IF rDiam_Tower_In_Out=0 THEN	  rDiam_Tower_In_Out:=1000; END_IF
IF rDiam_NextRoller_In_Out=0 THEN rDiam_NextRoller_In_Out:=100; END_IF
IF rXPos_NextRoller_In_Out=0 THEN rXPos_NextRoller_In_Out:=232.5; END_IF
IF rYPos_NextRoller_In_Out=0 THEN rYPos_NextRoller_In_Out:=2137-1085; END_IF
dwTowerPos_Cur:=dwEnCodePos_In_Out;

fbKS_FB_TowerRadCompensate(i_xEn:=xUseRadCompensate_In AND i_xFlag_Print AND
						(i_pstStEvtReq^.xOutTowerFor OR i_pstStEvtReq^.xOutTowerRev),
						i_xAxis_Cur:= xCutAxisA_In_Out,(*放料当前轴*)
						i_xConfirmRad:=xConfirmRad0_In_Out,
						i_rDiam_CurAxis:= io_rDiamCurAxis,
						i_dwAbsPos_Cur:=dwTowerPos_Cur,
						i_dwAbsEnCodeResolution:=dwAbsEnCodeResolution_In,
						I_xTowerDir_Uw:=xTowerDir_In,
						i_rDiam_Tower:= rDiam_Tower_In_Out,
						i_rDiam_NextRoller:=rDiam_NextRoller_In_Out,
						i_rXPos_NextRoller:=rXPos_NextRoller_In_Out,
						i_rYPos_NextRoller:=rYPos_NextRoller_In_Out,
						i_pdwAbsPos_0Rad_AxisA:=ADR(dwAxisAAbsPos_0Rad_In_Out),
						i_pdwAbsPos_0Rad_AxisB:=ADR(dwAxisBAbsPos_0Rad_In_Out),
						(*2022.5.17.122239*)
						i_xOnTop:= io_xCutOnTop,(*上下裁刀标志*)
						i_rDiam_DeflectorRollPos:=rDiam_DeflectorRollPos_In,(*翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
						i_rDiam_DeflectorRoller:=rDiam_DeflectorRoller_In,(*翻料架上导向辊的直径|mm*)
						i_iCycleTime_Plc:= i_iCycleTime_Plc,
						o_rDeltaW_RPMIN=> rDeltaW_RPMIN_Out,
						o_rTheta_Cur=> rTowerThetaCur_Out,
						o_rFilmToTowerRollerDis=>rFilmToTowerRollerDis_Out,(*料膜距离导向辊距离|mm*)
						o_xFilmTouchRoller=>xFilmTouchRoller_Out(*料膜接触到了辊子标志*));
xConfirmRad0_In_Out:=FALSE;
(*翻转架运动放料补偿------------------------------------------------END*)