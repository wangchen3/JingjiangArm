(*@CES
Name=KS_FB_GrpHorAdj
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d546f829-7451-435f-8672-15bc73f9dc0f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpHorAdj(*传统横向电机调整*)
(*2023.3.8.214754
移植KS_FB_AxisHorAdj 代码
程序逻辑只有操作侧和传动侧的方向
@位置正值代表向操作侧运动
@位置负值代表向传动侧运动
电机输出只有正转和反转
@正转是向操作侧
@反转是向传动侧*)
(*2023.3.10.105606 为了兼容外部的硬件限位处理
这里将限位定义调整下
@i_xMove_Left 为正转限位即操作侧限位
@i_xMove_Right 为反转限位即传动侧限位
@支持密码切换将限位定义切换为左右限位@dwControlComplexBits.17|未处理密码切换部分*)

(*2024.01.17.162016 优化从站横向控制标志处理@现场偶尔出现从站横向操作无响应问题*)
(*2025.4.20.104124从站横向运动功能，停机状态取消联动相关|开机状态下非联动轴也可以运动*)
(*2025.9.5.104845 自动横向调整时单周期调整量超过1丝的量不会因为自动速度太快而不响应@现场会出现小误差一直不能回来(单个周期的调整量太大了)*)
VAR_INPUT
	i_xEn: BOOL;(*使能*)
	i_iGrpAxisNum_Pu: INT; (*色组轴数*)
	i_abyGrpAxisList: ARRAY [1..MAX_UNIT_NUM] OF BYTE; (*系的轴列表*)
	i_pastStIOMap_AxisBasic: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (*基础io|*)
	i_pastStIOMap_AxisExtra: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE; (* 扩展io|*)
	i_lrVel_HorzAdjust		: LREAL;(*mm/s; um/ms; 横向调整速度|*)
	i_lrVel_HorzPreRegister		: LREAL;(*mm/s;横向预套准速度|*)
	(*2023.3.8.114628*)
	i_xFlag_Estop							: BOOL;(*急停标志*)
	i_xFlag_Stop							: BOOL;(*停机标志*)
	i_iCycleTime_Plc						: INT;
	i_pastStAxisRapidAdjProf_H				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;(*纵向快速对版|*)
	i_pstStSysParam: POINTER TO StSysParam;
	i_xHorLimit:BOOL;(*横向限位定义修改为左右|默认是纤维定义为正反方向*)
	i_iGrpId: INT;
	i_xHorManuCtrl:BOOL;(*界面横向手动修正功能*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1参数失败|*)
	o_axAxisHorAdjing: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
END_VAR
VAR
	iN: INT;

	iUnitId: INT;


	pstStIOMap_AxisBasic: POINTER TO StIOMap_Axis_FE;
	pstStIOMap_AxisExtra: POINTER TO StIOMap_Axis_Extra_FE;
	//pstStAxisParam: POINTER TO StAxisParam;


	xFlag_PreRegister_H: BOOL;(*用来表征是否进入过横向预套准状态*)

	wHorzMotorDir: WORD;(*.0 |正转方向
					.1|反转方向*)
	awPreHorzMotorDir: ARRAY [1..MAX_UNIT_NUM] OF WORD;
	axHorzMotorStart_Delay: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向启动延时标志*)
	axHorzMotorStart_DelayDne: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向启动延时完成*)
	auiHorzMotorStart_Count: ARRAY [1..MAX_UNIT_NUM] OF UINT;(*启动延时计时变量*)
	iHorzMotorStart_DelayTime_MS: INT:=0;(*启动的延时时间ms*)

	adwTotalTimes_CW_AxisHorzManu: ARRAY [1..MAX_UNIT_NUM] OF DWORD ;
	adwTotalTimes_CCW_AxisHorzManu: ARRAY [1..MAX_UNIT_NUM] OF DWORD ;
	lrAdjustVal_H_PerCycle:LREAL;(*每个周期调整的量*)

	(*2023.3.8.114227 将函数KS_FB_AxisHorAdj中的代码移植到此处*)
	axAxisHorAdjSts: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axAxisHorAdj_End: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	iRtn: INT;
	iAdjustment_HorAxisAdj: INT;
	axHorAxisAdjStop: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	axHorAxisAdjStart: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	xFlag_HorAxisAdj: BOOL;
	wSts_HorzManuPreReg:WORD;
	(*横向运动相关变量都使用操作侧和传动侧变量重新赋值@2023.3.8.104853*)
	axHorMovingBtn_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动按钮*)
	axHorMovingBtn_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动按钮*)
	axHorMovingLimit_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动限位*)
	axHorMovingLimit_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动限位*)
	axHorMoving_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动*)
	axHorMoving_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动*)
	xAutoMove_H: BOOL;(*2025.4.20.110711+*)
END_VAR


{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*系的色组数量有效|*)
		i_pastStIOMap_AxisBasic<>0 AND
		i_pastStIOMap_AxisExtra<>0 THEN



		(*2023.3.8.114227 将函数KS_FB_AxisHorAdj中的代码移植到此处*)
		FOR iN:= 1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iUnitId]);

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

			(*--------------------------------------------------|2019.11.18.153930_*)
			(*横向快速对版改成单个轴处理时放在循环内处理|*)
			(*返回的距离单位是mm*)
			iAdjustment_HorAxisAdj:=0;(*清零*)
			iRtn:= KS_FetchRapidAdjValue_H(i_pastStAxisRapidAdjProf_H, iUnitId, ADR(iAdjustment_HorAxisAdj));
			(*2024.01.17.161205 增加清除处理*)
			axHorAxisAdjStart[iUnitId]:= FALSE;
			axHorAxisAdjStop[iUnitId]:= FALSE;
			IF iRtn=0 THEN
				IF iAdjustment_HorAxisAdj=-32767 THEN(*人为停止标志|*)
					axHorAxisAdjStop[iUnitId]:= TRUE;
				ELSIF iAdjustment_HorAxisAdj<>0 THEN
					axHorAxisAdjStart[iUnitId]:= TRUE;
				END_IF
			END_IF


			IF (NOT i_xFlag_Estop) (*AND i_xFlag_Stop*) THEN(*非急停*)
				(*2025.4.20.105720 修改条件*)
				IF i_xFlag_Stop THEN(*不用限制单联动*)
					xAutoMove_H:=TRUE;
				ELSE(*非停机状态下|只有单动的可以*)
					xAutoMove_H:=NOT i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage;
				END_IF
				IF xAutoMove_H(*pstStAxisParam^.xLinkage *)THEN
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

			IF pstStIOMap_AxisBasic^.o_xRel_Press OR (NOT pstStIOMap_AxisBasic^.i_xHorzMotor_FastSpd) THEN
			(*快调/慢调处理*)
				lrAdjustVal_H_PerCycle:= i_lrVel_HorzAdjust*INT_TO_LREAL(i_iCycleTime_Plc);
			ELSE
				lrAdjustVal_H_PerCycle:= i_lrVel_HorzPreRegister*INT_TO_LREAL(i_iCycleTime_Plc);
			END_IF

			IF axAxisHorAdjSts[iUnitId] THEN (*色组进入到横向对版状态*)
				xFlag_HorAxisAdj:= TRUE;

				(*2025.4.20.105821 屏蔽联动条件*)
				IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage OR TRUE THEN(*色组联动*)
					IF NOT axAxisHorAdj_End[iUnitId] THEN
						IF NOT o_axAxisHorAdjing[iUnitId] THEN
							o_axAxisHorAdjing[iUnitId]:= TRUE;
							(*横向对版量叠加到横向手动粗调仓库*)
							(*iAdjustment_HorAxisAdj正值需要往传动侧运动*)
							(*iAdjustment_HorAxisAdj 单位mm
							  alrTotalAdjustVal_ManuCoarse_vh[2] 单位um*)
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]+iAdjustment_HorAxisAdj*1000;(*单位um*)
							(*alrTotalAdjustVal_ManuCoarse_vh[2] 负值是向传动侧运动的@故取反*)
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=-i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2];
						ELSE

							IF (axHorMovingLimit_G[iUnitId] AND i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<0) OR
								(axHorMovingLimit_M[iUnitId] AND i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]>0) THEN
								i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
							END_IF


							IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]=0 THEN(*调整量消耗完成*)
								o_axAxisHorAdjing[iUnitId]:= FALSE;
								axAxisHorAdj_End[iUnitId]:= TRUE;
							END_IF
						END_IF
					END_IF
				ELSE(*单动*)
					o_axAxisHorAdjing[iUnitId]:= FALSE;
					axAxisHorAdj_End[iUnitId]:= TRUE;
					IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
					END_IF
				END_IF
			ELSE
				IF xFlag_HorAxisAdj THEN
					xFlag_HorAxisAdj:= FALSE;
				END_IF
				o_axAxisHorAdjing[iUnitId]:= FALSE;
				axAxisHorAdj_End[iUnitId]:= FALSE;
				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]<>0 THEN(*退出横向对版状态，调整量清零*)
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:=0;
				END_IF
			END_IF
	
	
			IF axAxisHorAdjSts[iUnitId] THEN
				IF ABS(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2])>=lrAdjustVal_H_PerCycle THEN
					IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]>0 THEN
						(*正向*)
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2]:= lrAdjustVal_H_PerCycle;
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2];
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuCoarse_done_vh[2]:= FALSE;
						axHorMovingBtn_M[iUnitId]:=TRUE;
						axHorMovingBtn_G[iUnitId]:=FALSE;
					ELSE
						(*反向*)
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2]:= -lrAdjustVal_H_PerCycle;
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2];
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuCoarse_done_vh[2]:= FALSE;

						axHorMovingBtn_M[iUnitId]:=FALSE;
						axHorMovingBtn_G[iUnitId]:=TRUE;
					END_IF
				ELSE
					IF o_axAxisHorAdjing[iUnitId] THEN
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;
					END_IF
				END_IF
			END_IF
	(*往从站发送*)
			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].iPos_HorzManuPreReg:= -LREAL_TO_INT(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuCoarse_vh[2]/1000);
			(*2024.01.17.170711 替换*)
			wSts_HorzManuPreReg.0:= axAxisHorAdjSts[iUnitId](*o_axAxisHorAdjing[iUnitId]*);
			wSts_HorzManuPreReg.1:= axHorMoving_M[iUnitId];
			wSts_HorzManuPreReg.2:= axHorMoving_G[iUnitId];
			wSts_HorzManuPreReg.3:= axHorMovingLimit_M[iUnitId];
			wSts_HorzManuPreReg.4:= axHorMovingLimit_G[iUnitId];
			wSts_HorzManuPreReg.5:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop;

			i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wSts_HorzManuPreReg:= wSts_HorzManuPreReg;
		END_FOR




		IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_HorzPreRegister THEN (*横向预套准状态*)
			xFlag_PreRegister_H:=TRUE;
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
(*2019.03.15.142555|niu.j|放在IF外*)
				iUnitId:= i_abyGrpAxisList[iN];
				pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iUnitId]);
				pstStIOMap_AxisExtra:= ADR(i_pastStIOMap_AxisExtra^[iUnitId]);

				IF pstStIOMap_AxisBasic^.o_xRel_Press OR (NOT pstStIOMap_AxisBasic^.i_xHorzMotor_FastSpd) THEN
				(*快调/慢调处理*)
					lrAdjustVal_H_PerCycle:= i_lrVel_HorzAdjust*INT_TO_LREAL(i_iCycleTime_Plc);
				ELSE
					lrAdjustVal_H_PerCycle:= i_lrVel_HorzPreRegister*INT_TO_LREAL(i_iCycleTime_Plc);
				END_IF

				IF NOT 	i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xMode_HorzPreRegister THEN (*false 代表设定值 ，true代表重复值*)(*设定值！！走到左限位以目标值+当前修正量的值*)

					IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN (*当前色处于联动状态才进行横向预套准*)
						IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end THEN (*未调整完*)
							IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing THEN (*非横向预套准中*)
								IF NOT axHorMovingLimit_M[iUnitId] THEN (*未到操作侧限位*)
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=(2*lrAdjustVal_H_PerCycle);(*为了电机向左一直转动 diHorAdjValue_Sum>0,并且让他=一个周期调整的量*)

								ELSE(*到了操作侧限位*)
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing:=TRUE;
									(*调整量单位um*)
									(*需要向传动侧运动*)
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=dint_to_lreal(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].diPreReg_SetupVal_H)*1000.0(*.diHorzPreReg_SetupVal*)+dint_to_lreal(i_pstStSysParam^.astStUnitParam_Save[iUnitId].diPreReg_AdjustVal_H)*1000.0(*.diHorzPreReg_AdjustVal*);(*设定值+修正值*)
									IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]<0 THEN
										i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=0;
									END_IF
									(*位置值为负值才是向传动侧运动的*)
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=-i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2];
								END_IF
							ELSE(*预套准中*)
								IF axHorMovingLimit_G[iUnitId] THEN (*到达了传动侧限位*)
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=0;
								END_IF

								IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2] =0 THEN(*预套准走完了*)
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing:=FALSE;
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end:=TRUE;
								END_IF
							END_IF
						END_IF
					ELSE(*单动中*)
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing:=FALSE;
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end:=TRUE;
						IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]<>0 THEN
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=0;
						END_IF
					END_IF

				ELSE(*重复值*)
					IF i_pstStSysParam^.astStUnitParam_Save[iUnitId].xLinkage THEN (*当前色处于联动状态才进行横向预套准*)
						IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end THEN (*未调整完*)
							IF NOT i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing THEN (*非横向预套准中*)
								i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing:=TRUE;
								(*diPreReg_RepeatVal_H 正值向传动侧运动
								alrTotalAdjustVal_Auto_vh[2] 负值才是向传动侧运动@故需要取反*)
								i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=-DINT_TO_LREAL(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].diPreReg_RepeatVal_H)*1000.0(*.diHorzPreReg_RepeatVal*);(*diHorzPreReg_RepeatVal为正值代表要向右转动*)
																			(*下面执行的时候 只有总的调整量小于0才会输出向右转信号，故取反*)

							ELSE(*预套准中*)
								IF (axHorMovingLimit_G[iUnitId] AND i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]<0) OR
									(axHorMovingLimit_M[iUnitId] AND i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]>0) THEN
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=0;
								END_IF


								IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2] =0 THEN(*预套准走完了*)
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing:=FALSE;
									i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end:=TRUE;
								END_IF
							END_IF
						END_IF
					ELSE(*单动中*)
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing:=FALSE;
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end:=TRUE;
						IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]<>0 THEN
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=0;
						END_IF
					END_IF
				END_IF
			END_FOR

			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*检查所有的色组是否都完成*)
				iUnitId:= i_abyGrpAxisList[iN];

				IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end THEN
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end :=TRUE;(*横向预套准完成了*)
				ELSE
					i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end:=FALSE;
					EXIT;
				END_IF
			END_FOR

		ELSE(*非横向预套准中*)
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*检查所有的色组是否都完成*)
				iUnitId:= i_abyGrpAxisList[iN];
				
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing:=FALSE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_end:=FALSE;
			END_FOR

			IF xFlag_PreRegister_H THEN
				xFlag_PreRegister_H:=FALSE;
				FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO(*检查所有的色组是否都完成*)
					iUnitId:= i_abyGrpAxisList[iN];
					
					i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=0;
				END_FOR
			END_IF
			i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_HorzPreRegister_All_end:=FALSE;
		END_IF



		FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
			iUnitId:= i_abyGrpAxisList[iN];
			pstStIOMap_AxisBasic:= ADR(i_pastStIOMap_AxisBasic^[iUnitId]);
			pstStIOMap_AxisExtra:= ADR(i_pastStIOMap_AxisExtra^[iUnitId]);

			IF pstStIOMap_AxisBasic^.o_xRel_Press OR (NOT pstStIOMap_AxisBasic^.i_xHorzMotor_FastSpd) THEN
			(*快调/慢调处理*)
				lrAdjustVal_H_PerCycle:= i_lrVel_HorzAdjust*INT_TO_LREAL(i_iCycleTime_Plc);
			ELSE
				lrAdjustVal_H_PerCycle:= i_lrVel_HorzPreRegister*INT_TO_LREAL(i_iCycleTime_Plc);
			END_IF

			(*2019.5.15.170941|niu.j|急停清零横向调整量*)
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop THEN
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Rapid_vh[2]:= 0;
			END_IF

			IF (i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Ctl.0 AND i_pstStSysParam^.astStUnitParam_Save[iUnitId].dwFlag_Sts.1)
				OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_HorzPreRegister  THEN(*横向开|横向自动|*)
				(*消耗自动调整量累计|*)
				IF ABS(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2])>=lrAdjustVal_H_PerCycle THEN
					IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]>0 THEN
						(*正向*)
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Auto_vh[2]:= lrAdjustVal_H_PerCycle;
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Auto_vh[2];
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_Auto_done_vh[2]:= FALSE;
						axHorMoving_M[iUnitId]:= TRUE;(*操作侧*)
						axHorMoving_G[iUnitId]:= FALSE;(*传动侧*)
					ELSE
						(*反向*)
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Auto_vh[2]:= -lrAdjustVal_H_PerCycle;
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Auto_vh[2];
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_Auto_done_vh[2]:= FALSE;
						axHorMoving_G[iUnitId]:= TRUE;(*传动侧*)
						axHorMoving_M[iUnitId]:= FALSE;(*操作侧*)
					END_IF
				ELSE
					IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xFlag_HorzPreRegister_ing THEN
						i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:= 0;
					END_IF
					//2025.9.9.200410 同步
					(*2025.9.5.104621 对于小调整量进行响应处理优化*)
					IF lrAdjustVal_H_PerCycle > 10 THEN(*单周期的量超过1丝执行这部分代码*)
						IF ABS(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]) >= 10 THEN(*强制响应1丝以上的调整量*)
							IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2] > 0 THEN(*正向*)
								axHorMoving_M[iUnitId]:= TRUE;(*操作侧*)
								axHorMoving_G[iUnitId]:= FALSE;(*传动侧*)
							ELSE(*反向*)
								axHorMoving_M[iUnitId]:= FALSE;(*操作侧*)
								axHorMoving_G[iUnitId]:= TRUE;(*传动侧*)
							END_IF
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:=0;(*清零*)
						ELSE
							axHorMoving_M[iUnitId]:= FALSE;(*操作侧*)
							axHorMoving_G[iUnitId]:= FALSE;(*传动侧*)
						END_IF
					ELSE(*单周期的量小于1丝的时候就不响应剩余的调整量*)
						axHorMoving_M[iUnitId]:= FALSE;(*操作侧*)
						axHorMoving_G[iUnitId]:= FALSE;(*传动侧*)
					END_IF
				END_IF
			ELSIF i_xHorManuCtrl THEN(*界面上有横向手动修正功能|*)
				(*消耗手动细调量累计|*)
				IF ABS(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2])>=lrAdjustVal_H_PerCycle THEN
(*					IF axHorzMotorStart_DelayDne[iUnitId] THEN(*延时启动完成了*)
*)						IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2]>0 THEN
							(*正向*)
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuFine_vh[2]:= lrAdjustVal_H_PerCycle;

							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuFine_vh[2];
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuFine_done_vh[2]:= FALSE;
							axHorMoving_M[iUnitId]:= TRUE;(*操作侧*)
							axHorMoving_G[iUnitId]:= FALSE;(*传动侧*)

						ELSE
							(*反向*)
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuFine_vh[2]:= -lrAdjustVal_H_PerCycle;

							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2]:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2] - i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuFine_vh[2];
							i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuFine_done_vh[2]:= FALSE;
							axHorMoving_G[iUnitId]:= TRUE;(*传动侧*)
							axHorMoving_M[iUnitId]:= FALSE;(*操作侧*)

						END_IF

					(*monitoring...\2018.10.7.104410|*)
					IF axHorMoving_M[iUnitId] THEN
						adwTotalTimes_CW_AxisHorzManu[iUnitId]:= adwTotalTimes_CW_AxisHorzManu[iUnitId]+1;
					END_IF
					IF axHorMoving_G[iUnitId] THEN
						adwTotalTimes_CCW_AxisHorzManu[iUnitId]:= adwTotalTimes_CCW_AxisHorzManu[iUnitId]+1;
					END_IF

				ELSE

					axHorMoving_M[iUnitId]:= FALSE;
					axHorMoving_G[iUnitId]:= FALSE;
				END_IF
			ELSE
				(*没开横向或者横向在手动状态*)
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_Auto_done_vh[2]:= FALSE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_Rapid_done_vh[2]:= FALSE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuCoarse_done_vh[2]:= FALSE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_ManuFine_done_vh[2]:= FALSE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_Coupling_done_vh[2]:= FALSE;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].axCurCycleAdjustVal_Compensate_done_vh[2]:= FALSE;

				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Auto_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Rapid_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuCoarse_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_ManuFine_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Coupling_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrCurCycleAdjustVal_Compensate_vh[2]:= 0;

				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Auto_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Rapid_vh[2]:= 0;
(*				pstStAxisParam^.alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;*)
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_ManuFine_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Coupling_vh[2]:= 0;
				i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].alrTotalAdjustVal_Compensate_vh[2]:= 0;

				axHorMoving_M[iUnitId]:= FALSE;
				axHorMoving_G[iUnitId]:= FALSE;
			END_IF
(*
			axHorzMotorStart_Delay[1];
			axHorzMotorStart_Delay[2];
			axHorzMotorStart_Delay[3];
			axHorzMotorStart_Delay[4];
			axHorzMotorStart_Delay[5];
			axHorzMotorStart_Delay[6];
			axHorzMotorStart_Delay[7];
			axHorzMotorStart_Delay[8];
			axHorzMotorStart_Delay[9];


			axHorzMotorStart_DelayDne[1];
			axHorzMotorStart_DelayDne[2];
			axHorzMotorStart_DelayDne[3];
			axHorzMotorStart_DelayDne[4];
			axHorzMotorStart_DelayDne[5];
			axHorzMotorStart_DelayDne[6];
			axHorzMotorStart_DelayDne[7];
			axHorzMotorStart_DelayDne[8];
			axHorzMotorStart_DelayDne[9];

			auiHorzMotorStart_Count[1];
			auiHorzMotorStart_Count[2];
			auiHorzMotorStart_Count[3];
			auiHorzMotorStart_Count[4];
			auiHorzMotorStart_Count[5];
			auiHorzMotorStart_Count[6];
			auiHorzMotorStart_Count[7];
			auiHorzMotorStart_Count[8];
			auiHorzMotorStart_Count[9];


			awPreHorzMotorDir[1];
			awPreHorzMotorDir[2];
			awPreHorzMotorDir[3];
			awPreHorzMotorDir[4];
			awPreHorzMotorDir[5];
			awPreHorzMotorDir[6];
			awPreHorzMotorDir[7];
			awPreHorzMotorDir[8];
			awPreHorzMotorDir[9];
*)

			(*增加了正反转信号启动延时2018.10.7.085705 by liu.yt*)
			wHorzMotorDir:=BOOL_TO_WORD(axHorMoving_M[iUnitId])+SHL(BOOL_TO_WORD(axHorMoving_G[iUnitId]),1);
			IF wHorzMotorDir<>awPreHorzMotorDir[iUnitId] THEN(*方向发生了变化*)
				IF wHorzMotorDir<>0THEN(*说明有正反转信号了*)
					axHorzMotorStart_Delay[iUnitId]:=TRUE;
				ELSE
					axHorzMotorStart_Delay[iUnitId]:=FALSE;
				END_IF
				axHorzMotorStart_DelayDne[iUnitId]:=FALSE;
				auiHorzMotorStart_Count[iUnitId]:=0;
				awPreHorzMotorDir[iUnitId]:=wHorzMotorDir;
			END_IF

			IF axHorzMotorStart_Delay[iUnitId] THEN(*启动延时*)
				IF auiHorzMotorStart_Count[iUnitId]>=iHorzMotorStart_DelayTime_MS/i_iCycleTime_Plc THEN
					auiHorzMotorStart_Count[iUnitId]:=0;
					axHorzMotorStart_Delay[iUnitId]:=FALSE;
					axHorzMotorStart_DelayDne[iUnitId]:=TRUE;
				ELSE
					auiHorzMotorStart_Count[iUnitId]:=auiHorzMotorStart_Count[iUnitId]+1;
				END_IF
			END_IF




			(*---------------------------2017-08-14 15:21:18
			/.手动调整
			.----------------------------------------------*)	
			IF axHorMovingBtn_M[iUnitId] AND (NOT axHorMovingBtn_G[iUnitId]) THEN
				(*左*)
				axHorMoving_G[iUnitId]:= FALSE;
				axHorMoving_M[iUnitId]:= TRUE;
			ELSIF axHorMovingBtn_G[iUnitId] AND (NOT axHorMovingBtn_M[iUnitId]) THEN
				(*右*)
				axHorMoving_M[iUnitId]:= FALSE;
				axHorMoving_G[iUnitId]:= TRUE;
			END_IF


			(*---------------------------2017-08-14 15:21:18
			/.横向限位处理
			.----------------------------------------------*)
			IF axHorMovingLimit_M[iUnitId] THEN(*操作侧*)
				axHorMoving_M[iUnitId]:= FALSE;
			END_IF

			IF axHorMovingLimit_G[iUnitId] THEN(*传动侧*)
				axHorMoving_G[iUnitId]:= FALSE;
			END_IF

			(*急停停止横向输出|2022.5.11.171513*)
			IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop THEN
				axHorMoving_M[iUnitId]:= FALSE;
				axHorMoving_G[iUnitId]:= FALSE;
			END_IF


			(*将操作侧和传动侧信号输出*)
			(*电机输出是按照正转和反转@一般情况正反手机电机的旋转方向是一致的即,都是向操作侧或者都是向传动侧
			我们定义正传是向操作侧@反转是向传动侧*)
			pstStIOMap_AxisBasic^.o_xHorzMotor_CW:=axHorMoving_M[iUnitId];
			pstStIOMap_AxisBasic^.o_xHorzMotor_CCW:=axHorMoving_G[iUnitId];
		END_FOR
	ELSE
		o_iErNo:= -1;
	END_IF
END_IF