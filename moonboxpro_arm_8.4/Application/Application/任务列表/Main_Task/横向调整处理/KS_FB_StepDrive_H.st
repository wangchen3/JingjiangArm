(*@CES
Name=KS_FB_StepDrive_H
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f275ef3d-5ed9-47c6-a743-922ee6eb9ea9
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_StepDrive_H(*步进电机横向调整*)
(*2023.3.8.092821 从站横向调整关于限位的处理bug修复*)
(*
程序逻辑只有操作侧和传动侧的方向
@位置正值代表向操作侧运动
@位置负值代表向传动侧运动
电机输出方向
	xStepDriveDir=true 传动侧
	xStepDriveDir=false 操作侧
@正转是向操作侧
@反转是向传动侧*)
(*2023.3.10.105606 为了兼容外部的硬件限位处理
这里将限位定义调整下
@i_xMove_Left 为正转限位即操作侧限位
@i_xMove_Right 为反转限位即传动侧限位
@支持密码切换将限位定义切换为左右限位@dwControlComplexBits.17|未处理密码切换部分*)

(*2024.01.17.162016 优化从站横向控制标志处理@现场偶尔出现从站横向操作无响应问题
处理索引使用错误的bug*)
(*2024.01.17.220227 之前修改的在进入脉冲输出状态置位运行中逻辑有问题,恢复为以前的处理逻辑*)
(*2024.7.16.175547| 将自动调整量的值复位@不再累计*)
(*2025.4.20.104124从站横向运动功能，停机状态取消联动相关|开机状态下非联动轴也可以运动*)
VAR_INPUT
	i_xEn									: BOOL;(*步进电机横向功能使能*)
	i_xHorAdjEn								: BOOL;(*横向自动调整使能**)
	i_iUnitNum								: INT;(*色组数*)
	i_abyGrpAxisList							: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (*系的轴列表*)
	i_iStepDriveSa_Vel						: INT;(*步进电机启动速度*)
	i_iStepDrivePreReg_Vel					: INT;(*z步进电机预套速度R/MIN*)
	i_iStepDriveManu_Vel					: INT;(*z步进电机手动速度R/MIN*)
	i_iStepDriveManu_Vel_Fast				: INT;(*z步进电机手动高速速度R/MIN*)
	i_iStepDriveAuto_Vel					: INT;(*步进电机自动速度R/MIN*)
	i_iStepDriveAccTime						: INT;(*步进电机加速时间*)
	i_xHor_Goal_Flag						: BOOL;(*TRUE:目标值调整标志,走到左限位以目标值+当前修正量的值;FALSE :修正量调整标志,当前修正量-前次修正量的值*)
	i_xHor_PreRegist_Flag					: BOOL;(*横向预套准标志*)
	//i_pstStShmGlobalParam					: POINTER TO StShmGlobalParam; (*参数结构*)
	i_pastStIOMap_AxisBasic					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (*基础io|*)
	i_pastStIOMap_AxisExtra					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE; (* 扩展io|*)
	i_aiHorAdjValue							: ARRAY [1..MAX_UNIT_NUM] OF INT;(*横向调整量单位是um*)
	//i_pstStGrpParam							: POINTER TO StGrpParam;
	i_pastStDigitalMicroStepDrive			: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
	i_pastStAxisRapidAdjProf_H				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;(*纵向快速对版|*)
	i_xFlag_Estop							: BOOL;
	i_xFlag_Stop							: BOOL;
	i_pstStSysParam: POINTER TO StSysParam;
	i_xHorLimit:BOOL;(*横向限位定义修改为左右|默认是纤维定义为正反方向*)
	i_iGrpId: INT;
END_VAR
VAR_OUTPUT
	o_xEn									: BOOL;
END_VAR
VAR
	iLp: INT;
	iN: INT;
	lrTemp: LREAL;
	lrTemp0: LREAL;
	lrTemp1: LREAL;
	lrStepDriveMoveValue: LREAL;(*步进电机实际走的量*)
	axHorizontal_Manu: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*手动横向调整标志*)
	axHorizontal_Auto: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*自动横向调整标志*)
	lrHorAdjPulseTemp: LREAL;(*横向自动调整的脉冲值*)
	iStepDriveManuVel: INT;(*步进电机手动速度*)
	pstStIOMap_AxisBasic: POINTER TO StIOMap_Axis_FE;
	iRtn: INT;
	iAdjustment_HorAxisAdj: INT;
	axHorAxisAdjStop: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axHorAxisAdjStart: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axFlag_HorAxisAdj: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	wSts_HorzManuPreReg:WORD;
	iUnitId: INT;
	axAxisHorAdjSts: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisHorAdjing: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisHorAdj_End: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	adiStartPluse_Act: ARRAY [1..MAX_UNIT_NUM] OF DINT;
	alrTempRun: ARRAY [1..MAX_UNIT_NUM] OF LREAL;
	(*横向运动相关变量都使用操作侧和传动侧变量重新赋值@2023.3.12.103321*)
	axHorMovingBtn_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动按钮*)
	axHorMovingBtn_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动按钮*)
	axHorMovingLimit_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动限位*)
	axHorMovingLimit_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动限位*)
	xAutoMove_H: BOOL;(*2025.4.20.105629+*)
END_VAR

{IMPLEMENTATION}
IF (i_iUnitNum>=1 AND i_iUnitNum<=MAX_UNIT_NUM) AND
	i_pastStIOMap_AxisBasic <>0 AND
	i_pastStIOMap_AxisExtra<>0 AND
	i_pastStDigitalMicroStepDrive<>0 THEN;
ELSE
	RETURN;
END_IF
 (*&&&&&&&左限位为操作侧方向，电机默认方向为操作侧方向转动.正调整量使用默认方向.负调整量使用取反方向,&&&&&&&&
调整量正值向左侧运动 负值向右侧运动*)
IF i_xEn THEN

	FOR iN:= 1 TO i_iUnitNum BY 1 DO
		iUnitId:= i_abyGrpAxisList[iN];
		pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iUnitId]);(*提取IO列表*)

		(*2023.3.12.103443 同步*)
		(*处理横向开关相关@2023.3.8.104924*)
		(*和运动方向关联@伺服正转(正手机)-左对应操作侧#先不关心反印时候的方向变化问题
					    @伺服反转(反手机)-左对应传动侧#先不关心反印时候的方向变化问题*)
		IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller THEN(*正转*)
			axHorMovingBtn_M[iUnitId]:=pstStIOMap_AxisBasic^.i_xMove_Left;
			axHorMovingBtn_G[iUnitId]:=pstStIOMap_AxisBasic^.i_xMove_Right;

			axHorMovingLimit_M[iUnitId]:=pstStIOMap_AxisBasic^.i_xPosLimit_Left;
			axHorMovingLimit_G[iUnitId]:=pstStIOMap_AxisBasic^.i_xPosLimit_Right;
		ELSE(*反转*)
			axHorMovingBtn_M[iUnitId]:=pstStIOMap_AxisBasic^.i_xMove_Right;
			axHorMovingBtn_G[iUnitId]:=pstStIOMap_AxisBasic^.i_xMove_Left;

			IF i_xHorLimit THEN
				(*使用左右限位*)
				axHorMovingLimit_M[iUnitId]:=pstStIOMap_AxisBasic^.i_xPosLimit_Right;
				axHorMovingLimit_G[iUnitId]:=pstStIOMap_AxisBasic^.i_xPosLimit_Left;
			ELSE
				(*使用正转(操作侧)反转(传动侧)限位*)
				axHorMovingLimit_M[iUnitId]:=pstStIOMap_AxisBasic^.i_xPosLimit_Left;
				axHorMovingLimit_G[iUnitId]:=pstStIOMap_AxisBasic^.i_xPosLimit_Right;
			END_IF
		END_IF


		(*--------------------------------------------------|2019.11.18.155026_*)
		(*按轴id来处理横向快速对版|*)
		iRtn:= KS_FetchRapidAdjValue_H(i_pastStAxisRapidAdjProf_H, iUnitId, ADR(iAdjustment_HorAxisAdj));
		(*2024.01.17.161205 增加清除处理*)
		axHorAxisAdjStart[iUnitId]:= FALSE;
		axHorAxisAdjStop[iUnitId]:= FALSE;
		IF iRtn=0 THEN
			IF iAdjustment_HorAxisAdj=-32767 THEN(*人为停止标志|*)
				axHorAxisAdjStop[iUnitId]:= TRUE;
			ELSIF iAdjustment_HorAxisAdj<>0 THEN
				axHorAxisAdjStart[iUnitId]:= TRUE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]+iAdjustment_HorAxisAdj;
			END_IF
		END_IF



		IF (NOT i_xFlag_Estop) (*AND i_xFlag_Stop*) THEN(*非急停*)
			(*2025.4.20.105720 修改条件*)
			IF i_xFlag_Stop THEN(*不用限制单联动*)
				xAutoMove_H:=TRUE;
			ELSE(*非停机状态下|只有单动的可以*)
				xAutoMove_H:=NOT i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;
			END_IF

			(*2025.4.20.105720 修改条件*)
			IF xAutoMove_H(*pstStAxisParam^.xLinkage*) THEN
				IF axHorAxisAdjStart[iUnitId] AND (NOT axAxisHorAdjSts[iUnitId]) THEN(*开始运行*)
					axAxisHorAdjSts[iUnitId]:= TRUE;
				END_IF
				IF (axHorAxisAdjStop[iUnitId] AND axAxisHorAdjSts[iUnitId]) OR(*停止运行*)
					axAxisHorAdj_End[iUnitId] THEN(*控制结束了就停止*)
					axAxisHorAdjSts[iUnitId]:= FALSE;
				END_IF
			ELSE
				axAxisHorAdjSts[iUnitId]:= FALSE;
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
				END_IF

			END_IF
		ELSE
			IF axAxisHorAdjSts[iUnitId] THEN
				axAxisHorAdjSts[iUnitId]:= FALSE;(*急停或者非停机-直接停止运行*)
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
			END_IF
		END_IF

		IF axAxisHorAdjSts[iUnitId] THEN (*色组进入到横向对版状态*)
			IF NOT axFlag_HorAxisAdj[iUnitId] THEN
				axFlag_HorAxisAdj[iUnitId]:= TRUE;
				(*2019.11.20.115030 将该值强制赋值为0 不再取当前的总脉冲值*)
				adiStartPluse_Act[iUnitId]:=0;
				alrTempRun[iUnitId]:=0;
			END_IF
			(*2025.4.20.105821 屏蔽联动条件*)
			IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage OR TRUE THEN(*色组联动*)
				IF NOT axAxisHorAdj_End[iUnitId] THEN
					IF NOT axAxisHorAdjing[iUnitId] THEN
						axAxisHorAdjing[iUnitId]:= TRUE;
					ELSE
						(*横向对版量叠加到横向手动粗调仓库*)
						IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<0 THEN
							axHorMovingBtn_M[iUnitId]:= TRUE;
						ELSIF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]>0 THEN
							axHorMovingBtn_G[iUnitId]:= TRUE;
						ELSE;
						END_IF
						(*2023.3.8.093903*)
						IF (axHorMovingLimit_M[iUnitId] AND axHorMovingBtn_M[iUnitId])OR(*左转运动限位*)
							(axHorMovingLimit_G[iUnitId] AND axHorMovingBtn_G[iUnitId]) THEN (*右转运动限位*)
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
							axHorMovingBtn_M[iUnitId]:=FALSE;(*缺失了按钮的清除@2023.5.23.112147*)
							axHorMovingBtn_G[iUnitId]:= FALSE;(*缺失了按钮的清除@2023.5.23.112147*)
						END_IF
						(*进入脉冲输出状态的时候进行位置判断|2019.11.20.115136 Liu.yt*)
						(*索引用成in了@2024.01.17.171103*)
						IF i_pastStDigitalMicroStepDrive^[iUnitId].iStepDriveState=STEPDRIVE_PULSEOUT THEN
							alrTempRun[iUnitId]:= (i_pastStDigitalMicroStepDrive^[iUnitId].diStepDrivePluse_Act-adiStartPluse_Act[iUnitId])*i_pastStDigitalMicroStepDrive^[iUnitId].lrStepDrivePosPPulse;
							(*2025.4.20.111927 保证计算运动的值的符号和设置的一致*)
							IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]>=0 THEN
								alrTempRun[iUnitId]:=ABS(alrTempRun[iUnitId]);
							ELSE
								alrTempRun[iUnitId]:=-ABS(alrTempRun[iUnitId]);
							END_IF
							IF ABS(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2])<=ABS(alrTempRun[iUnitId]) THEN(*调整量消耗完成*)
								axAxisHorAdjing[iUnitId]:= FALSE;
								axAxisHorAdj_End[iUnitId]:= TRUE;

								i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
							END_IF
						ELSE;
						END_IF
					END_IF
				END_IF
			ELSE(*单动*)
				axAxisHorAdjing[iUnitId]:= FALSE;
				(*单动轴写为完成*)
				axAxisHorAdj_End[iUnitId]:= TRUE(*FALSE*);
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
				END_IF
			END_IF
		ELSE
			IF axFlag_HorAxisAdj[iUnitId] THEN
				axFlag_HorAxisAdj[iUnitId]:= FALSE;
			END_IF
			axAxisHorAdjing[iUnitId]:= FALSE;
			axAxisHorAdj_End[iUnitId]:= FALSE;
			IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN(*退出横向对版状态，调整量清零*)
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
			END_IF
		END_IF
		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPos_HorzManuPreReg:= LREAL_TO_INT(alrTempRun[iUnitId]);
		(*2024.01.17.170746 替换*)
		wSts_HorzManuPreReg.0:= axAxisHorAdjSts[iUnitId];
		wSts_HorzManuPreReg.1:= pstStIOMap_AxisBasic^.o_xHorzMotor_CW;
		wSts_HorzManuPreReg.2:= pstStIOMap_AxisBasic^.o_xHorzMotor_CCW;
		wSts_HorzManuPreReg.3:= axHorMovingLimit_M[iUnitId];
		wSts_HorzManuPreReg.4:= axHorMovingLimit_G[iUnitId];
		wSts_HorzManuPreReg.5:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;

		i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSts_HorzManuPreReg:= wSts_HorzManuPreReg;
	END_FOR
	(*下面循环索引使用错误@2023.3.24.113944*)
	FOR iLp:=1 TO i_iUnitNum BY  1 DO
		iN:= i_abyGrpAxisList[iLp];
		//pstStAxisParam:= ADR(i_pstStShmGlobalParam^.astStAxisParam[iN]);(*提取轴参数*)
		pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iN]);(*提取IO列表*)

		IF i_xHorAdjEn THEN (*横向调整使能*)
			lrTemp:=i_pastStDigitalMicroStepDrive^[iN].lrStepDrivePosPPulse*1000;(*单位脉冲对应的位置值 um/pul*)
			IF lrTemp=0 THEN lrTemp:=0.0002; END_IF
			lrTemp0:=i_iStepDriveSa_Vel*i_pastStDigitalMicroStepDrive^[iN].iStepDrivePulsePRev/60.0;(*pul/s*)
			lrTemp1:=i_iStepDriveAuto_Vel*i_pastStDigitalMicroStepDrive^[iN].iStepDrivePulsePRev/60.0;(*pul/s*)
			IF (i_aiHorAdjValue[iN]<>0) AND (NOT  axHorizontal_Manu[iN])(**说明有调整量,不是在手动调整状态*)(*由外部清零*)
				AND (NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking) THEN(*底层不在调整过程中的时候才能继续写调整量*)
				IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_IDLE THEN (*处于空闲状态*)
					i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_RUN;(*启动步进电机调整*)
				END_IF
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa:=LREAL_TO_WORD(lrTemp0);
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar:=LREAL_TO_WORD(lrTemp1);
				lrHorAdjPulseTemp:=ABS(i_aiHorAdjValue[iN])/lrTemp;
				IF lrHorAdjPulseTemp>65535 THEN(*防止值溢出*)
					lrHorAdjPulseTemp:=65535;
				END_IF
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse:=LREAL_TO_WORD(lrHorAdjPulseTemp);(*写入的脉冲数*)
				i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode:=TRUE;(*位置模式*)
				i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
				IF  i_aiHorAdjValue[iN]>0 THEN (*正调整量使用默认方向*)
					i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=FALSE;
				ELSE(*负调整量使用取反方向*)
					i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=TRUE;
				END_IF
				axHorizontal_Auto[iN]:=TRUE;(*进入一次自动调整我们认为就是置位自动调整状态*)
				i_pstStSysParam^.astStUnitParam_UnSave[iN].alrTotalAdjustVal_Auto_vh[2]:= 0;
			ELSE(*调整量为0*);
			END_IF
		ELSE
			IF axHorizontal_Auto[iN] THEN
				i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
				axHorizontal_Auto[iN]:=FALSE;
			END_IF
		END_IF
		(*2024.7.17.085405强制复位横向自动调整量@如果没调整就不用理了|可能会有累计的问题*)
		i_pstStSysParam^.astStUnitParam_UnSave[iN].alrTotalAdjustVal_Auto_vh[2]:= 0;




(*横向手动*)
(*步进电机横向手动 两档速度切换逻辑*)
		IF pstStIOMap_AxisBasic^.o_xRel_Press OR (NOT pstStIOMap_AxisBasic^.i_xHorzMotor_FastSpd) THEN(*压辊合压了，或者按钮选择为横向低速速度*)
			iStepDriveManuVel:=i_iStepDriveManu_Vel;
		ELSE
			iStepDriveManuVel:=i_iStepDriveManu_Vel_Fast;
		END_IF

		IF NOT i_xHor_PreRegist_Flag OR i_xHorAdjEn THEN (*非横向预套准*)
			IF i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing OR i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end THEN
				i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
				IF ( NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking)   (*停止脉冲输出了 我们就去空闲状态*)
					OR i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode THEN(*当前为位置模式的时候直接停止，因为不这样打断的话 它会把所有脉冲走完才停止*)
					 i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
					i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing:=FALSE;
					i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end:=FALSE;
				END_IF
			ELSE
				lrTemp0:=i_iStepDriveSa_Vel*i_pastStDigitalMicroStepDrive^[iN].iStepDrivePulsePRev/60.0;(*pul/s*)
				lrTemp1:=iStepDriveManuVel*i_pastStDigitalMicroStepDrive^[iN].iStepDrivePulsePRev/60.0;(*pul/s*)
				IF axHorizontal_Auto[iN] THEN (*横向自动调整了*)
					IF axHorMovingBtn_M[iN] OR axHorMovingBtn_G[iN] THEN(*手动按钮有效了*)
						i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;(*先退出到空闲状态*)
						axHorizontal_Manu[iN]:=TRUE;(*手动横向调整状态*)
						axHorizontal_Auto[iN]:=FALSE;
					END_IF
				ELSE(*横向没有自动调整*)


					IF axHorMovingBtn_M[iN] THEN(*横向正转我们定义为默认反向*)
						axHorizontal_Manu[iN]:=TRUE;(*手动横向调整状态*)
						IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_IDLE THEN(*空闲状态*)
							i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_RUN;(*启动步进电机调整*)
							i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa:=LREAL_TO_WORD(lrTemp0);
							i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar:=LREAL_TO_WORD(lrTemp1);
							i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode:=FALSE;(*速度模式*)
							i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=TRUE;(*置位速度模式输出标志*)
							i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=FALSE;(*使用默认方向*)
						END_IF
					ELSIF axHorMovingBtn_G[iN] THEN
						axHorizontal_Manu[iN]:=TRUE;(*手动横向调整状态*)
						IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_IDLE THEN(*空闲状态*)
							i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_RUN;(*启动步进电机调整*)
							i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa:=LREAL_TO_WORD(lrTemp0);
							i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar:=LREAL_TO_WORD(lrTemp1);
							i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode:=FALSE;(*速度模式*)
							i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=TRUE;(*置位速度模式输出标志*)
							i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=TRUE;(*使用反方向*)
						END_IF
					ELSE
						IF axHorizontal_Manu[iN] THEN
							i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
							IF NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*停止脉冲输出了 我们就去空闲状态*)
								i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
								axHorizontal_Manu[iN]:=FALSE;(*清除手动横向调整状态*)
							END_IF
						END_IF
					END_IF
				END_IF
			END_IF

(*限位处理*)
			IF ((NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir) AND axHorMovingLimit_M[iN]) THEN(*方向为默认方向就即向操作侧移动*)(*向操作侧运动并且到达限位*)
				IF i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN(*处于脉冲输出过程中*)
					i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse:=0;(*写入的脉冲数为0，也就意味着不能再继续位置模式下输出脉冲了*)
					i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
				ELSE
					IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveState<>STEPDRIVE_IDLE THEN
						i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;(*停止脉冲输出了 我们就去空闲状态*)
					END_IF
				END_IF
			ELSIF(  i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir AND  axHorMovingLimit_G[iN]) THEN(*方向为默认方向就即向操作侧移动*)(*向传动侧运动并且到达限位*)
				IF i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN(*处于脉冲输出过程中*)
					i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse:=0;(*写入的脉冲数为0，也就意味着不能再继续位置模式下输出脉冲了*)
					i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
				ELSE
					IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveState<>STEPDRIVE_IDLE THEN
						i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;(*停止脉冲输出了 我们就去空闲状态*)
					END_IF
				END_IF
			END_IF
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end:=FALSE;
		ELSE
			IF axHorizontal_Manu[iN] THEN
				i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
				IF  NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*脉冲输出下降沿*)(*停止脉冲输出了 我们就去空闲状态*)
					i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
					axHorizontal_Manu[iN]:=FALSE;(*清除手动横向调整状态*)
				END_IF
			ELSE
				IF  i_xHor_PreRegist_Flag THEN (*横向预套准*)(*横向预套准都走的是速度模式，由于位置模式位置脉冲的数据类型限制，导致走的距离不会很远！*)
					lrTemp0:=i_iStepDriveSa_Vel*i_pastStDigitalMicroStepDrive^[iN].iStepDrivePulsePRev/60.0;(*pul/s*)
					lrTemp1:=i_iStepDrivePreReg_Vel*i_pastStDigitalMicroStepDrive^[iN].iStepDrivePulsePRev/60.0;(*pul/s*)
					lrTemp:=i_pastStDigitalMicroStepDrive^[iN].lrStepDrivePosPPulse;(*单位脉冲对应的位置值 mm/pul*)
					IF lrTemp=0 THEN lrTemp:=0.0002; END_IF
					lrStepDriveMoveValue:=i_pastStDigitalMicroStepDrive^[iN].diStepDrivePluse_Act*lrTemp;(*MM*)(*实际走的距离*)
(*
(*2019.5.29.233226|横向快速调整量填充预套准调整量*)
					pstStAxisParam^.alrTotalAdjustVal_Rapid_vh[2]:=pstStAxisParam^.diPreReg_SetupVal_H
							+pstStAxisParam^.diPreReg_AdjustVal_H;(*总的目标值*)
*)
(*
					pstStAxisParam^.alrTotalAdjustVal_Auto_vh[2]:=pstStAxisParam^.diPreReg_SetupVal_H
							+pstStAxisParam^.diPreReg_AdjustVal_H;(*总的目标值*)*)


					IF i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN(*联动的色组才进行*)
						IF i_xHor_Goal_Flag THEN (*目标值算法*)
							IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end THEN(*预套准未完成*)
								IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing THEN(*还没预套准中*)

									(*2019.11.13.130426|将258处代码移动到这里|Liu.yt*)
									i_pstStSysParam^.astStUnitParam_UnSave[iN].alrTotalAdjustVal_Rapid_vh[2]:=i_pstStSysParam^.astStUnitParam_UnSave[iN].diPreReg_SetupVal_H
											+i_pstStSysParam^.astStUnitParam_Save[iN].diPreReg_AdjustVal_H;(*总的目标值*)
									IF NOT axHorMovingLimit_M[iN] THEN(*未到限位开关时一直转动*)
										IF  i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_IDLE THEN (*处于空闲状态*)
											i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_RUN;(*启动步进电机调整*)
											i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa:=LREAL_TO_WORD(lrTemp0);(*写入的启动频率*)
											i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar:=LREAL_TO_WORD(lrTemp1);(*写入的目标频率*)
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode:=FALSE;(*速度模式*)
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=TRUE;(*置位速度模式输出标志*)
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=FALSE;(*使用默认方向到达左边限位*)
										END_IF
									END_IF
									i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing:=TRUE;
								ELSE(*在预套准中*)
									IF axHorMovingLimit_M[iN]  THEN (*到达左限位了*)
										IF  NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir THEN(*处于向左限位运动中*)
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
											IF NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*停止脉冲输出了 我们就去空闲状态*)
												i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
												i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=TRUE;(*改变方向向右限位运动，之所以放在这里只是为了用它作为条件*)
											END_IF
										ELSE
											IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_IDLE THEN(*空闲状态*)
												i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_RUN;(*启动步进电机调整*)
												i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa:=LREAL_TO_WORD(lrTemp0);
												i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar:=LREAL_TO_WORD(lrTemp1);
												i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode:=FALSE;(*速度模式*)
												i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=TRUE;(*置位速度模式输出标志*)
												i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=TRUE;(*向右限位方向运动*)
											END_IF
										END_IF
									END_IF

									IF i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir AND
										i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_PULSEOUT THEN (*已经开始向右限位运动了*)
										IF ABS(lrStepDriveMoveValue)>=(i_pstStSysParam^.astStUnitParam_UnSave[iN].alrTotalAdjustVal_Rapid_vh[2]) THEN
										(*IF axStepDriveWorking[iN] AND NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*脉冲输出下降沿*)*)
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
											(*增加次条件会停止比较平滑 但是会增加多余脉冲输出*)
											IF NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*停止脉冲输出了 我们就去空闲状态*)
												i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
												i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end:=TRUE;
												i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing:=FALSE;
											END_IF
										END_IF

										IF axHorMovingLimit_G[iN] THEN (*到达右限位*)
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
											IF NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*停止脉冲输出了 我们就去空闲状态*)
												i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
												i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end:=TRUE;
												i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing:=FALSE;
											END_IF
										END_IF
									END_IF
								END_IF
							ELSE(*预套准完成*);
							END_IF
						ELSE(*重复目标值*)
							IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end THEN(*预套准未完成*)
								IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing  THEN (*不在调整中*)
									IF i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_IDLE THEN(*空闲状态*)
										i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_RUN;(*启动步进电机调整*)
										i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode:=FALSE;(*速度模式*)
										i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=TRUE;(*置位速度模式输出标志*)
										i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa:=LREAL_TO_WORD(lrTemp0);
										i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar:=LREAL_TO_WORD(lrTemp1);
										i_pstStSysParam^.astStUnitParam_UnSave[iN].alrTotalAdjustVal_Rapid_vh[2]:=(*-*)i_pstStSysParam^.astStUnitParam_UnSave[iN].diPreReg_RepeatVal_H(*.diHorzPreReg_RepeatVal*);(*diHorzPreReg_RepeatVal为正值代表要向右转动*)
																			(*下面执行的时候 只有总的调整量小于0才会输出向右转信号，故取反*)
																			(*2019.11.13.130750将公式中的负号取消是和约定方向一致*)

										IF i_pstStSysParam^.astStUnitParam_UnSave[iN].alrTotalAdjustVal_Rapid_vh[2]>0 THEN(*重复值大于0我们向传动侧运动，这个和调整的方向是反的.注意*)
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=TRUE;(*所以使用默认方向的反方向*)
										ELSE
											i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir:=FALSE;(*所以使用默认方向*)
										END_IF
									END_IF
									i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing:=TRUE;
								ELSE
									IF ABS(lrStepDriveMoveValue)>=ABS(i_pstStSysParam^.astStUnitParam_UnSave[iN].alrTotalAdjustVal_Rapid_vh[2]) AND
										(*2019.12.6.104358增加了进入脉冲输出状态的时候进行位置判断*)
										i_pastStDigitalMicroStepDrive^[iN].iStepDriveState=STEPDRIVE_PULSEOUT THEN
									(*IF axStepDriveWorking[iN] AND NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*脉冲输出下降沿*)*)
										i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run:=FALSE;(*清除速度模式输出标志*)
										(*增加次条件会停止比较平滑 但是会增加多余脉冲输出*)
										IF NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking THEN (*停止脉冲输出了 我们就去空闲状态*)
											i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;(*停止运动*)
											i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end:=TRUE;
											i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing:=FALSE;
										END_IF
									END_IF

									(*2020.11.4.095612 重新处理重复值限位判断逻辑*)
									IF (i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir AND
										axHorMovingLimit_G[iN]) OR(*检查右限位*)
										(NOT i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir AND
										axHorMovingLimit_M[iN]) THEN (*检查左限位*)
										i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;(*停止运动*)
										i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end:=TRUE;
										i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_ing:=FALSE;
									END_IF
									(*2020.11.4.095630 屏蔽下面逻辑*)
									(*
									IF axHorMovingLimit_G[iN] OR axHorMovingLimit_M[iN] THEN (*到达左或右限位*)
										i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;(*停止运动*)
										pstStAxisParam^.xFlag_HorzPreRegister_end:=TRUE;
										pstStAxisParam^.xFlag_HorzPreRegister_ing:=FALSE;
									END_IF*)
								END_IF
							ELSE(*预套准完成了*);
							END_IF
						END_IF
					END_IF
				END_IF
			END_IF
		END_IF
		(*axStepDriveWorking[iN]:=i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking;*)
	END_FOR

	FOR iLp:=1 TO i_iUnitNum BY 1 DO
		iN:= i_abyGrpAxisList[iLp];
		//pstStAxisParam:= ADR(i_pstStShmGlobalParam^.astStAxisParam[iN]);

		IF  i_pstStSysParam^.astStUnitParam_UnSave[iN].xFlag_HorzPreRegister_end  THEN
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end:=TRUE;(*横向到位*)
		ELSE
			IF  i_pstStSysParam^.astStUnitParam_Save[iN].xLinkage THEN
				i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end:=FALSE;
				EXIT;(*横向还未到位*)
			ELSE
				i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end:=TRUE;(*横向到位*);
			END_IF
		END_IF
	END_FOR

ELSE;
END_IF