(*@CES
Name=Action_Normal_Act_Horz
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=e8ca34c9-bbd2-4fc3-a17e-a8fca3d34d6c
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*横向处理功能块调用*)
	afbKS_FB_GrpHorzAdjustCtrl[iGrp](
		i_xEn:= TRUE, 
		i_iGrpId:= iGrp, 
		i_iGrpAxisNum_Pu:= g_stStSysParam.astStGrpParam_UnSave[iGrp].byGrpAxisNum_Pu,// iGrpAxisNum_Pu, 
		i_abyGrpAxisList:= g_stStSysParam.astStGrpParam_UnSave[iGrp].abyGrpAxisList, 
		i_pastStIOMap_AxisBasic:= ADR(g_astStIOMap_Axis_FE), 
		i_pastStIOMap_AxisExtra:= ADR(g_astStIOMap_Axis_Extra_FE), 
		i_pstStSysParam:= ADR(g_stStSysParam), 
		i_xDebugTestRun:= g_xStepDriveDebugRun, (*启动步进电机*)
		i_xDebugTestResult_Wr:= g_xStepDriveDebugResult_Wr, (*横向步进电机脉冲测试*)
		i_iDebugNum:= g_iStepDriveDebugNum, 
		i_diDebugPulse:= g_diStepDriveDebugPulse, 
		i_lrDebugPulse_PosAct:= g_lrStepDriveDebugPulse_PosAct, 
		i_pastStDigitalMicroStepDrive:= ADR(g_astStDigitalMicroStepDrive), 
		i_lrVel_HorzAdjust:= REAL_TO_LREAL(g_stStSysParam.astStGrpParam_Save[iGrp].rVel_HorzdAdj), 
		i_lrVel_HorzPreRegister:= REAL_TO_LREAL(g_stStSysParam.astStGrpParam_Save[iGrp].rVel_HorzPreRegister) , 
		i_pastStAxisRapidAdjProf_H:= ADR(g_astStAxisRapidAdjProf_H), 
		i_diPreReg_RepeatVal_H:= g_abyBtn_HorzPreRegister_Repeat[iGrp], 
		i_diPreReg_SetupVal_H:= g_adiPreReg_SetupVal_H[iGrp], 
		i_xHorSyncMotorCtrl:= g_stStSysParam.stStSysParam_Save.byHorzCtlMode=1, (*横向同步电机控制*)
		i_xHorStepDriveCtrl:= g_stStSysParam.stStSysParam_Save.byHorzCtlMode=2, (*横向步进电机控制*)
		i_iStepDrivePulsePRev:= g_stStSysParam.stStSysParam_Save.iStepDrivePulsePRev, 
		i_rStepDrivePosPPulse:= g_stStSysParam.stStSysParam_Save.rStepDrivePosPPulse, (*每个电机对应的脉冲值*)
		i_xIsDebugMode:= g_stStSysParam.astStGrpParam_UnSave[iGrp].xIsDebugMode_Machine, 
		i_iStepDriveSa_Vel:= g_stStSysParam.stStSysParam_Save.iStepDriveSa_Vel, 
		i_iStepDrivePreReg_Vel:= g_stStSysParam.stStSysParam_Save.iStepDrivePreReg_Vel, 
		i_iStepDriveManu_Vel:= g_stStSysParam.stStSysParam_Save.iStepDriveManu_Vel, (*手动低速*)
		i_iStepDriveManu_Vel_Fast:= g_stStSysParam.stStSysParam_Save.iStepDriveManu_Vel_Fast,(*手动高速*) 
		i_iStepDriveAuto_Vel:= g_stStSysParam.stStSysParam_Save.iStepDriveAuto_Vel, 
		i_iStepDriveAccTime:= g_stStSysParam.stStSysParam_Save.iStepDriveAccTime, 
		i_xHor_Goal_Flag:= g_stStSysParam.astStGrpParam_Save[iGrp].xHor_Goal_Flag, (*目标值调整标志*)
		i_xHor_PreRegist_Flag:= g_stStSysParam.astStGrpParam_Save[iGrp].xHor_PreRegist_Flag, (*重复值调整标志*)
		i_xEnaTestARC_Ink:= g_stStSysParam.astStGrpParam_Save[iGrp].xEnaTestARC_Ink, (*空转测试使能*)
		i_xHorLimit:= g_stStSysParam.astStGrpParam_Save[iGrp].xHorLimit, (*限位定义修改为左右|默认是正反转*)
		i_xHorManuCtrl:= g_stStSysParam.astStGrpParam_Save[iGrp].xHorManuCtrl, (*界面横向手动修正功能*)
		io_byBtn_HorzPreRegister_Repeat:= g_abyBtn_HorzPreRegister_Repeat[iGrp], 
		io_byBtn_HorzPreRegister_Setup:= g_abyBtn_HorzPreRegister_Setup[iGrp], 
		io_abyHorzManuTrigButton:= g_abyHorzManuTrigButton, (*界面横向按钮*)
		
		o_xEno=> , 
		o_iErNo=> , 
		o_xStepDriveDebugDne=> , 
		o_xHorxPreRegister_Finish=> , 
		o_xHorzMotorAlarmAtLeastOne=> );(*至少一色联动轴横向报警*)
