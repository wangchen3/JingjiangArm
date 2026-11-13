(*@CES
Name=Action_Act
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=3d9282e5-ad0f-4219-8897-b5a4201c94c2
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
o_xHorzMotorAlarmAtLeastOne:=FALSE;
IF i_xEn THEN
	IF i_iGrpAxisNum_Pu>=1 AND(*系的色组数量有效|*)
		i_pastStIOMap_AxisBasic<>0 AND
		i_pastStIOMap_AxisExtra<>0 AND
		i_pastStDigitalMicroStepDrive<>0 AND
		i_pastStAxisRapidAdjProf_H<>0 THEN

		(*****************************************************************START*)
		(*2025.2.7.165334  对横向重复值按钮和目标值按钮做重新处理*)
		(*重复值*)
		IF io_byBtn_HorzPreRegister_Repeat<>0 THEN
			xBtn_HorzPreRegister_Repeat_In:=TRUE;(*下面逻辑会清除，这里不用理会*)
			IF io_byBtn_HorzPreRegister_Repeat=1 THEN;(*按照轴的位置执行*)
			ELSE(*按照单个整机值执行@对轴的值进行赋值*)
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
					iUnitId:=i_abyGrpAxisList[iN];
					diPreReg_RepeatVal_H_In[iUnitId]:=i_diPreReg_RepeatVal_H;
				END_FOR
			END_IF
		END_IF
		io_byBtn_HorzPreRegister_Repeat:=0;

		(*目标值*)
		IF io_byBtn_HorzPreRegister_Setup<>0 THEN
			xBtn_HorzPreRegister_Setup_In:=TRUE;(*下面逻辑会清除，这里不用理会*)
			IF io_byBtn_HorzPreRegister_Setup=1 THEN;(*按照轴的位置执行*)
			ELSE(*按照单个整机值执行@对轴的值进行赋值*)
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
					iUnitId:=i_abyGrpAxisList[iN];
					diPreReg_RepeatVal_H_In[iUnitId]:=i_diPreReg_RepeatVal_H;
				END_FOR
			END_IF
		END_IF
		io_byBtn_HorzPreRegister_Setup:=0;

		(*****************************************************************END*)

		(*2019.08.23.183334|niu.j|横向预套准动作控制-重新修改*)
		IF xFlag_Stop_In THEN (*停机状态下才能进行横向预套准*)
			IF NOT xSts_HorzPreRegister_In THEN (*不在横向预套准状态*)
				IF xBtn_HorzPreRegister_Setup_In THEN (*横向设定值按钮有效*)
					xSts_HorzPreRegister_In:=TRUE;
					xMode_HorzPreRegister_In:=FALSE;
					xBtn_HorzPreRegister_Setup_In:= FALSE;
					xBtn_HorzPreRegister_Repeat_In:= FALSE;(*2025.2.7.164556+*)
				ELSIF xBtn_HorzPreRegister_Repeat_In  THEN(*横向重复值按钮有效*)
					xSts_HorzPreRegister_In:=TRUE;
					xMode_HorzPreRegister_In:=TRUE;
					xBtn_HorzPreRegister_Repeat_In:= FALSE;
					xBtn_HorzPreRegister_Setup_In:= FALSE;(*2025.2.7.164556+*)
				END_IF
			ELSE(*在预套准状态下*)
				IF xBtn_HorzPreRegister_Setup_In THEN (*横向设定值按钮有效*)
					xSts_HorzPreRegister_In:=FALSE;
					xBtn_HorzPreRegister_Setup_In:= FALSE;
					xBtn_HorzPreRegister_Repeat_In:= FALSE;(*2025.2.7.164556+*)
				ELSIF xBtn_HorzPreRegister_Repeat_In  THEN(*横向重复值按钮有效*)
					xSts_HorzPreRegister_In:=FALSE;
					xBtn_HorzPreRegister_Repeat_In:= FALSE;
					xBtn_HorzPreRegister_Setup_In:= FALSE;(*2025.2.7.164556+*)
				ELSIF xFlag_HorzPreRegister_All_end_In THEN (*所有的横向预套准完成了*)
					xSts_HorzPreRegister_In:=FALSE;
				END_IF
			END_IF
		ELSE
			xBtn_HorzPreRegister_Setup_In:=FALSE;
			xBtn_HorzPreRegister_Repeat_In:=FALSE;
			xSts_HorzPreRegister_In:=FALSE;
		END_IF



		(*自动调整量*)
		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			aiCommAdjustMentH[iUnitId]:= LREAL_TO_INT(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]);
			(*2025.2.7.170514 移动*)
			(*处理横向报警|*)
			IF xHorzMotor_Alarm_In[iUnitId] AND
				xLinkage_In[iUnitId] THEN
				o_xHorzMotorAlarmAtLeastOne:=TRUE;
			END_IF
		END_FOR



(*2019.09.11.211840|横向界面手动调整处理|niu.j*)
(*界面手动调整横向位置2018.10.6.222148by liu.yt*)

		iRtn:=KS_GetHorizonManuAdj(
			(*2023.3.9.230151 修改为true详见KS_GetHorizonManuAdj中2023.3.9的注释*)
			TRUE(*i_xHorManuDirSwitch*),(*横向输出量方向*)
			10(*i_iHorManuAdj_Step*),(*细调um*)
			50(*i_iHorManuAdj_FastStep*),(*粗调um*)
			20,(*i_iHorManuAdj_MidStep*)(*2022.8.9.094455新增20档位-0.02mm*)
			ADR(iUnitId)(*piUnitId*),(*需要进行调整的色组号*)
			ADR(io_abyHorzManuTrigButton)(*pabyHorManuBtn*),(*界面横向按钮*)
			ADR(aiCommAdjustMentH_HMI)(*padiHorAdjustMent*),
			i_iGrpAxisNum_Pu,
			i_abyGrpAxisList,
			i_pstStSysParam);(*返回的实际输出量*)

		IF xFlag_Stop_In <> xPreFlag_Stop THEN(*状态发生变化了*)
			FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
				aiCommAdjustMentH_HMI[iN]:=0;
			END_FOR
		END_IF
		xPreFlag_Stop:=xFlag_Stop_In;
		
		

		IF iUnitId>0 AND iUnitId<=MAX_UNIT_NUM THEN
			IF iRtn<>-22222 THEN
				IF NOT i_xHorStepDriveCtrl THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2]+INT_TO_LREAL(iRtn);
				ELSE
					aiCommAdjustMentH[iUnitId]:= aiCommAdjustMentH[iUnitId]+iRtn;

					(* 2020.8.11.145825|*)
					IF iRtn<>0 THEN
						;
					END_IF
				END_IF
			END_IF
		END_IF


		(*参数配置*)
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			i_pastStDigitalMicroStepDrive^[iN].iStepDriveNum:=0;
			i_pastStDigitalMicroStepDrive^[iN].iStepDriveDen:=0;
			i_pastStDigitalMicroStepDrive^[iN].iStepDrivePulsePRev:=i_iStepDrivePulsePRev;

			IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveNum<>0 AND i_pastStDigitalMicroStepDrive^[iN].iStepDriveDen <>0 THEN(*减速比不等于0的时候，*);
			ELSE(*减速比有一个等于0 我们使用测量的步进电机当量mm/pul*)
				i_pastStDigitalMicroStepDrive^[iN].lrStepDrivePosPPulse:=i_rStepDrivePosPPulse;
			END_IF
		END_FOR

		(*传统横向电机调整*)
		fbKS_FB_GrpHorAdj(
			i_xEn:= i_xHorSyncMotorCtrl,(*同步电机*)
			i_iGrpAxisNum_Pu:= i_iGrpAxisNum_Pu,
			i_abyGrpAxisList:= i_abyGrpAxisList,
			i_pastStIOMap_AxisBasic:= i_pastStIOMap_AxisBasic,
			i_pastStIOMap_AxisExtra:= i_pastStIOMap_AxisExtra,
			i_lrVel_HorzAdjust:= i_lrVel_HorzAdjust,
			i_lrVel_HorzPreRegister:= i_lrVel_HorzPreRegister,
			i_xFlag_Estop:= xFlag_Estop_In,
			i_xFlag_Stop:= xFlag_Stop_In,
			i_iCycleTime_Plc:= gc_MAIN_TSK_CYCLE_TIME,
			i_pastStAxisRapidAdjProf_H:= i_pastStAxisRapidAdjProf_H,
			i_pstStSysParam:= i_pstStSysParam, 
			i_xHorLimit:= i_xHorLimit, 
			i_iGrpId:= i_iGrpId, 
			i_xHorManuCtrl:= i_xHorManuCtrl, 
			o_xEno=> ,
			o_iErNo=>,
			o_axAxisHorAdjing=> );

		(*步进电机控制横向------------------------------------------------------*)
		(*测试单位脉冲对应位置值*)
		(*调试模式下|选择某个色组进行测试|输出一个固定脉冲数|根据界面输入的实际位置值|计算出单位脉冲对应距离*)
		fbKS_FB_Debug_Get_mmPpul(
			i_xEn:= i_xIsDebugMode AND i_xHorStepDriveCtrl,
			i_xStartTrig:= i_xDebugTestRun,
			i_xCalEn:= i_xDebugTestResult_Wr,
			i_iNum:= i_iDebugNum,
			i_iStepDriveSa_Vel:= i_iStepDriveSa_Vel,
			i_iStepDrivePreReg_Vel:= i_iStepDrivePreReg_Vel,
			i_diPulse:=i_diDebugPulse,
			i_lrPos_Act:=i_lrDebugPulse_PosAct ,
			i_pastStDigitalMicroStepDrive:=i_pastStDigitalMicroStepDrive ,
			o_xEn=> ,
			o_xDebugTestDone=>o_xStepDriveDebugDne ,
			o_lrResult=>lrStepDrivePosPPulse ,
			o_iErrCode=> );

		IF lrStepDrivePosPPulse<>0 THEN
			i_rStepDrivePosPPulse:=LREAL_TO_REAL(lrStepDrivePosPPulse);
		END_IF

		(*--------------------------------------------------|2019.11.18.174116_*)
		(*修正接口参数|*)
		(*横向步进电机控制*)
		(*计算预套准、手动、自动调整量|*)
		fbKS_FB_StepDrive_H(
			i_xEn:= i_xHorStepDriveCtrl,
			i_xHorAdjEn:= xFlag_Print_In OR i_xEnaTestARC_Ink,
			i_iUnitNum:= i_iGrpAxisNum_Pu ,
			i_abyGrpAxisList:= i_abyGrpAxisList,
			i_iStepDriveSa_Vel:= i_iStepDriveSa_Vel,
			i_iStepDrivePreReg_Vel:= i_iStepDrivePreReg_Vel,
			i_iStepDriveManu_Vel:= i_iStepDriveManu_Vel ,
			i_iStepDriveManu_Vel_Fast:= i_iStepDriveManu_Vel_Fast,
			i_iStepDriveAuto_Vel:= i_iStepDriveAuto_Vel ,
			i_iStepDriveAccTime:= i_iStepDriveAccTime ,
			i_xHor_Goal_Flag:= NOT i_xHor_Goal_Flag,
			i_xHor_PreRegist_Flag:= i_xHor_PreRegist_Flag,
			i_pastStIOMap_AxisBasic:= i_pastStIOMap_AxisBasic,
			i_pastStIOMap_AxisExtra:= i_pastStIOMap_AxisExtra,
			i_aiHorAdjValue:= aiCommAdjustMentH,
			i_pastStDigitalMicroStepDrive:=i_pastStDigitalMicroStepDrive ,
			i_pastStAxisRapidAdjProf_H:= i_pastStAxisRapidAdjProf_H,(*2019.11.18.174055_*)
			i_xFlag_Estop:= xFlag_Estop_In,(*2019.11.18.174055_*)
			i_xFlag_Stop:= xFlag_stop_In,(*2019.11.18.174055_*)
			i_pstStSysParam:= i_pstStSysParam, 
			i_xHorLimit:= i_xHorLimit, 
			i_iGrpId:= i_iGrpId, 
			o_xEn=> );

	ELSE
		o_iErNo:= -1;
	END_IF
END_IF