(*@CES
Name=KS_FB_HorzCtl_Driver
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=da6152f2-d53e-407a-9477-cd718a7d485f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_HorzCtl_Driver
VAR_INPUT
	i_xEn: BOOL;(*使能*)
	i_iGrpId: INT;
	i_iGrpAxisNum_Pu: INT; (*色组轴数*)
	i_pstStSysParam:POINTER TO StSysParam;(*系参数*)
	i_pastStIOMap_AxisBasic					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE; (*基础io|*)
	i_lrVel_HorzAdjust		: LREAL;(*mm/s; um/ms; 横向调整速度|*)
	i_lrVel_HorzPreRegister		: LREAL;(*mm/s;横向预套准速度|*)
	(*2023.3.8.114628*)
	i_xFlag_Estop							: BOOL;(*急停标志*)
	i_xFlag_Stop							: BOOL;(*停机标志*)
	i_iCycleTime_Plc						: INT;
	i_pastStAxisRapidAdjProf_H				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StAxisRapidAdjProf_H;(*纵向快速对版|*)
	i_alrTarp_EncPos						: ARRAY [1..MAX_UNIT_NUM] OF LREAL;//横向点位轴的编码器位置
	i_paxLimit_Left_Wr 						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
 	i_paxLimit_Right_Wr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxLimit_Left_WrClr 						: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
 	i_paxLimit_Right_WrClr 					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_xHorManuCtrl:BOOL;(*界面横向手动修正功能*)
//	i_arStep_Horz			:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF REAL;
//2026.05.09.100428 新增横向标定功能
	i_aiGrpTrapMotion_StdList: ARRAY [1..MAX_STATION_NUM] OF INT;
	i_pastStGetMotionSts: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StGetMotionSts;	
	i_pstStSysStationInf			:POINTER TO StSysStationInf;
	i_pstStSysGantryAxisInf 		:POINTER TO StSysGantryAxisInf;
	i_pastStAxisIdListInf :POINTER TO ARRAY [1..128] OF StAxisIdListInf;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0成功\-1参数失败|*)	
	o_alrTotalAdjust_Horz: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*横向调整量*)
	
END_VAR
VAR
	iN: INT;
	xInit: BOOL;
	iAxisId: INT;
	pstStGrpParam_Save: POINTER TO StGrpParam_Save;
	pstStGrpParam_UnSave: POINTER TO StGrpParam_UnSave;
	
	pstStUnitParam_Save: POINTER TO StUnitParam_Save;
	pstStUnitParam_UnSave: POINTER TO StUnitParam_UnSave;
	pstStRSV_UnitParam_Save: POINTER TO StRSV_UnitParam_Save;
	pstStRSV_UnitParam_UnSave: POINTER TO StRSV_UnitParam_UnSave;
	(*横向运动相关变量都使用操作侧和传动侧变量重新赋值@2023.3.8.104853*)
	axHorMovingBtn_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动按钮*)
	axHorMovingBtn_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动按钮*)
	axHorMovingLimit_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动限位*)
	axHorMovingLimit_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动限位*)
	axHorMoving_M: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向操作侧运动*)
	axHorMoving_G: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向传动侧运动*)	
	
	lrAdjustVel_:LREAL;(*每个周期调整的量|这里还是mm/s，需要转化为*)
	alrTotalAdjust_Horz: ARRAY [1..MAX_UNIT_NUM] OF LREAL;(*横向调整量*)
	adwTotalTimes_CW_AxisHorzManu: ARRAY [1..MAX_UNIT_NUM] OF DWORD := [MAX_UNIT_NUM(0)];
	adwTotalTimes_CCW_AxisHorzManu: ARRAY [1..MAX_UNIT_NUM] OF DWORD := [MAX_UNIT_NUM(0)];

	wHorzMotorDir: WORD;(*.0 |正转方向
					.1|反转方向*)
	awPreHorzMotorDir: ARRAY [1..MAX_UNIT_NUM] OF WORD;
	axHorzMotorStart_Delay: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向启动延时标志*)
	axHorzMotorStart_DelayDne: ARRAY [1..MAX_UNIT_NUM] OF BOOL;(*横向启动延时完成*)
	auiHorzMotorStart_Count: ARRAY [1..MAX_UNIT_NUM] OF UINT;(*启动延时计时变量*)
	iHorzMotorStart_DelayTime_MS: INT:=0;(*启动的延时时间ms*)

	axStopManuMove_Horz: ARRAY  [1..MAX_UNIT_NUM] OF BOOL;
	lrLimit_Left:LREAL;
	lrLimit_Right:LREAL;
	xLimit_LeftTemp:BOOL;
	xLimit_RightTemp:BOOL;
	xLimit_Left:BOOL;
	xLimit_Right:BOOL;
	lrAbsPosHorz:LREAL;
	iRtn:INT;
	xAxisRev:BOOL;
	
	//2026.05.09.170157 | + | 增加正反流向
	xMachineIsRev : BOOL;
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	IF (i_iGrpAxisNum_Pu>=1 AND i_iGrpAxisNum_Pu<=MAX_UNIT_NUM) AND(*系的色组数量有效|*)		
		i_pstStSysParam<>0 AND(*参数有效|*)
		i_pastStIOMap_AxisBasic<>0 AND
		i_paxLimit_Left_Wr<>0 AND 
		i_paxLimit_Right_Wr<>0 THEN
		
		pstStGrpParam_Save :=  ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
		pstStGrpParam_UnSave :=  ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
		//初始化输出调整量为当前规划位置
// 		IF NOT xInit THEN
// 			xInit:= TRUE;
// 			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
// 				alrTotalAdjust_Horz[iN]:= i_alrTarp_PrfPos[iN];
// 			END_FOR
// 		END_IF

		//2026.05.09.170157 | + | 增加正反流向
		xMachineIsRev := TRUE;

		IF NOT xInit THEN
			xInit:= TRUE;
			FOR iN:=1 TO i_iGrpAxisNum_Pu BY 1 DO
				alrTotalAdjust_Horz[iN]:= 0;
			END_FOR
		END_IF
		(*2023.3.8.114227 将函数KS_FB_AxisHorAdj中的代码移植到此处*)
		FOR iN:= 1 TO i_iGrpAxisNum_Pu BY 1 DO
			iAxisId:= iN;
			pstStUnitParam_Save:= ADR(i_pstStSysParam^.astStUnitParam_Save[iAxisId]);
			pstStUnitParam_UnSave:= ADR(i_pstStSysParam^.astStUnitParam_UnSave[iAxisId]);
			
			pstStRSV_UnitParam_Save := ADR(i_pstStSysParam^.astStRSV_UnitParam_Save[iAxisId]);
			pstStRSV_UnitParam_UnSave := ADR(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId]);

			(*处理一下限位*)
			(*限位赋值*)
			IF pstStGrpParam_UnSave^.xIsDebugMode_Machine AND pstStGrpParam_UnSave^.xFlag_Stop THEN//调试模式
				//记录一下横向限位
				IF i_paxLimit_Left_Wr^[iAxisId] THEN
					i_paxLimit_Left_Wr^[iAxisId]:= FALSE;								
					//2026.05.09.100428 新增横向标定功能 Hou.N
					iRtn := GTN_RN_ReadAbsEncPos(cardIndex:= 1, stationPhyId:=i_aiGrpTrapMotion_StdList[iAxisId], encoder:= 1, pPos:= ADR(lrAbsPosHorz));			
					g_liAbsPosTrap := LREAL_TO_LINT(lrAbsPosHorz);
					xAxisRev := pstStUnitParam_UnSave^.xMotRev_Horiz_;
					iRtn := KS_SetTrapCoordinate(
							i_xEn:= TRUE, 
							i_iTarget_Num:= 1, 
							i_paiTargetStationList:= ADR(i_aiGrpTrapMotion_StdList[iAxisId]), 
							i_paliABSEncPos:= ADR(g_liAbsPosTrap), 
							i_paxAxisRev:= ADR(xAxisRev), 
							i_pastStAxisIdListInf:= i_pastStAxisIdListInf, 
							i_pastStGetMotionSts:= i_pastStGetMotionSts,
							i_pstStSysStationInf := i_pstStSysStationInf,
							i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf,
							ADR(g_alrCurrentAbsPos_Trap));
					i_pstStSysParam^.astStRSV_UnitParam_Save[iAxisId].liABSPos_Trap:= g_liAbsPosTrap;
					pstStRSV_UnitParam_Save^.lrLimit_Left:= 1;
				END_IF
				
				IF i_paxLimit_Right_Wr^[iAxisId] THEN
					i_paxLimit_Right_Wr^[iAxisId]:= FALSE;
					pstStRSV_UnitParam_Save^.lrLimit_Right:= i_alrTarp_EncPos[iAxisId];
				END_IF
				IF 	i_paxLimit_Left_WrClr^[iAxisId] THEN
					i_paxLimit_Left_WrClr^[iAxisId] := FALSE;
					pstStRSV_UnitParam_Save^.lrLimit_Left := 0;
					i_pstStSysParam^.astStRSV_UnitParam_Save[iAxisId].liABSPos_Trap:=0;
				END_IF
				IF 	i_paxLimit_Right_WrClr^[iAxisId] THEN
					i_paxLimit_Right_WrClr^[iAxisId] := FALSE;
					pstStRSV_UnitParam_Save^.lrLimit_Right := 0;
				END_IF
			ELSE
				i_paxLimit_Left_Wr^[iAxisId]:= FALSE;
				i_paxLimit_Right_Wr^[iAxisId]:= FALSE;
				i_paxLimit_Left_WrClr^[iAxisId]:= FALSE;
				i_paxLimit_Right_WrClr^[iAxisId]:= FALSE;
			END_IF
			lrLimit_Left:= pstStRSV_UnitParam_Save^.lrLimit_Left;
			lrLimit_Right:= pstStRSV_UnitParam_Save^.lrLimit_Right;
			xLimit_LeftTemp:=i_pastStIOMap_AxisBasic^[iAxisId].i_xPosLimit_Left;
			xLimit_RightTemp:=i_pastStIOMap_AxisBasic^[iAxisId].i_xPosLimit_Right;
	
			IF lrLimit_Left=0 THEN(*未有软限位|按照最远距离*);
	
			ELSE(*存在软限位|限位标志取接近开关和位置值的or*)
				IF pstStUnitParam_UnSave^.xMotRev_Horiz_ THEN
					xLimit_LeftTemp:=xLimit_LeftTemp OR
									(lrLimit_Left<i_alrTarp_EncPos[iAxisId]);
				ELSE
					xLimit_LeftTemp:=xLimit_LeftTemp OR
									(lrLimit_Left<i_alrTarp_EncPos[iAxisId]);
				END_IF
			END_IF
			IF lrLimit_Right=0 THEN(*未有软限位|按照最远距离*);
			ELSE(*存在软限位|限位标志取接近开关和位置值的or*)
				IF pstStUnitParam_UnSave^.xMotRev_Horiz_ THEN
					xLimit_RightTemp:=xLimit_RightTemp OR
								(lrLimit_Right>i_alrTarp_EncPos[iAxisId]);
				ELSE
					xLimit_RightTemp:=xLimit_RightTemp OR
								(lrLimit_Right>i_alrTarp_EncPos[iAxisId]);
					
				END_IF	
			END_IF
	
	
			(*手动左右取反*)(*bai.zy|2023.12.18.161830|feida取反*)
			xLimit_Left:=xLimit_RightTemp;
			xLimit_Right:=xLimit_LeftTemp;
			(*
			IF xMachineIsRev THEN
				xLimit_Left:=xLimit_RightTemp;
				xLimit_Right:=xLimit_LeftTemp;
				IF pstStUnitParam_UnSave^.xMotRev_Horiz_ THEN
					xLimit_Left:=xLimit_LeftTemp;
					xLimit_Right:=xLimit_RightTemp;
				END_IF
			ELSE
				xLimit_Left:=xLimit_LeftTemp;
				xLimit_Right:=xLimit_RightTemp;
				IF pstStUnitParam_UnSave^.xMotRev_Horiz_ THEN
					xLimit_Left:=xLimit_LeftTemp;
					xLimit_Right:=xLimit_RightTemp;
				END_IF
			END_IF
			*)
//2026.01.28.152311 | + | 界面上的限位提示，先不要了	
// 			g_axLimit_Left_Wr_HMI[iN]:= xLimit_Left;
// 			g_axLimit_Right_Wr_HMI[iN]:= xLimit_Right;	
			(*处理横向开关相关@2023.3.8.104924*)
			(*和运动方向关联@伺服正转(正手机)-左对应操作侧#先不关心反印时候的方向变化问题
						    @伺服反转(反手机)-左对应传动侧#先不关心反印时候的方向变化问题*)
							
//			IF pstStUnitParam^.xMotRev_PrnRoller THEN(*正转*)
				axHorMovingBtn_M[iAxisId]:=i_pastStIOMap_AxisBasic^[iAxisId].i_xMove_Left;
				axHorMovingBtn_G[iAxisId]:=i_pastStIOMap_AxisBasic^[iAxisId].i_xMove_Right;

				axHorMovingLimit_M[iAxisId]:=xLimit_Left;
				axHorMovingLimit_G[iAxisId]:=xLimit_Right;
(*			ELSE(*反转*)
				axHorMovingBtn_M[iAxisId]:=pstStIOMap_Axis_FLEXO^.i_xMove_Right;
				axHorMovingBtn_G[iAxisId]:=pstStIOMap_Axis_FLEXO^.i_xMove_Left;

				IF i_pstStSysParam^.dwControlComplexBits.17 THEN
					(*使用左右限位*)
					axHorMovingLimit_M[iAxisId]:=xLimit_Right;
					axHorMovingLimit_G[iAxisId]:=xLimit_Left;
				ELSE
					(*使用正转(操作侧)反转(传动侧)限位*)
					axHorMovingLimit_M[iAxisId]:=xLimit_Left;
					axHorMovingLimit_G[iAxisId]:=xLimit_Right;
				END_IF
			END_IF
*)

			IF i_pastStIOMap_AxisBasic^[iAxisId].o_xRel_Press OR (NOT i_pastStIOMap_AxisBasic^[iAxisId].i_xHorzMotor_FastSpd) THEN
			(*快调/慢调处理*)
				lrAdjustVel_:= i_lrVel_HorzAdjust;
			ELSE
				lrAdjustVel_:= i_lrVel_HorzPreRegister;
			END_IF

			(*2019.5.15.170941|niu.j|急停清零横向调整量*)
			IF pstStGrpParam_UnSave^.xFlag_EStoping OR pstStGrpParam_UnSave^.xFlag_Estop THEN
				pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrTotalAdjustVal_Rapid_vh[2]:= 0;
			END_IF
			
			IF (pstStUnitParam_Save^.dwFlag_Ctl.0 AND pstStUnitParam_Save^.dwFlag_Sts.1) THEN
				IF ABS(pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2])>0 THEN
					IF pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]>0 THEN
						(*正向*)
						alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]+pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2];
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]:= 0;
						pstStUnitParam_UnSave^.axCurCycleAdjustVal_Auto_done_vh[2]:= FALSE;
						axHorMoving_M[iAxisId]:= TRUE;(*操作侧*)
						axHorMoving_G[iAxisId]:= FALSE;(*传动侧*)
					ELSE
						(*反向*)
						alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]+pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2];
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]:= 0;
						pstStUnitParam_UnSave^.axCurCycleAdjustVal_Auto_done_vh[2]:= FALSE;
						axHorMoving_G[iAxisId]:= TRUE;(*传动侧*)
						axHorMoving_M[iAxisId]:= FALSE;(*操作侧*)
					END_IF
				ELSE
					IF pstStUnitParam_UnSave^.xFlag_HorzPreRegister_ing THEN
						pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]:= 0;
					END_IF
					axHorMoving_M[iAxisId]:= FALSE;
					axHorMoving_G[iAxisId]:= FALSE;
				END_IF
			ELSIF i_xHorManuCtrl THEN//i_pstStSysParam^.dwControlComplexBits.7 THEN(*界面上有横向手动修正功能|*)
				(*消耗手动细调量累计|*)
				IF ABS(pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2])>0 THEN
(*					IF axHorzMotorStart_DelayDne[iAxisId] THEN(*延时启动完成了*)
*)						IF pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2]>0 THEN
							(*正向*)
							alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]+pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2];
							pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2]:= 0;
							pstStUnitParam_UnSave^.axCurCycleAdjustVal_ManuFine_done_vh[2]:= FALSE;
							axHorMoving_M[iAxisId]:= TRUE;(*操作侧*)
							axHorMoving_G[iAxisId]:= FALSE;(*传动侧*)

						ELSE
							(*反向*)
							alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]+pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2];
							pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2]:= 0;
							pstStUnitParam_UnSave^.axCurCycleAdjustVal_ManuFine_done_vh[2]:= FALSE;							
							axHorMoving_G[iAxisId]:= TRUE;(*传动侧*)
							axHorMoving_M[iAxisId]:= FALSE;(*操作侧*)

						END_IF

					(*monitoring...\2018.10.7.104410|*)
					IF axHorMoving_M[iAxisId] THEN
						adwTotalTimes_CW_AxisHorzManu[iAxisId]:= adwTotalTimes_CW_AxisHorzManu[iAxisId]+1;
					END_IF
					IF axHorMoving_G[iAxisId] THEN
						adwTotalTimes_CCW_AxisHorzManu[iAxisId]:= adwTotalTimes_CCW_AxisHorzManu[iAxisId]+1;
					END_IF

				ELSE
					axHorMoving_M[iAxisId]:= FALSE;
					axHorMoving_G[iAxisId]:= FALSE;
				END_IF	
			ELSE
				(*没开横向或者横向在手动状态*)
				pstStUnitParam_UnSave^.axCurCycleAdjustVal_Auto_done_vh[2]:= FALSE;
				pstStUnitParam_UnSave^.axCurCycleAdjustVal_Rapid_done_vh[2]:= FALSE;
				pstStUnitParam_UnSave^.axCurCycleAdjustVal_ManuCoarse_done_vh[2]:= FALSE;
				pstStUnitParam_UnSave^.axCurCycleAdjustVal_ManuFine_done_vh[2]:= FALSE;
				pstStUnitParam_UnSave^.axCurCycleAdjustVal_Coupling_done_vh[2]:= FALSE;
//				pstStUnitParam^.axCurCycleAdjustVal_Compensate_done_vh[2]:= FALSE;

				pstStUnitParam_UnSave^.alrCurCycleAdjustVal_Auto_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrCurCycleAdjustVal_Rapid_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrCurCycleAdjustVal_ManuCoarse_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrCurCycleAdjustVal_ManuFine_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrCurCycleAdjustVal_Coupling_vh[2]:= 0;
//				pstStUnitParam^.alrCurCycleAdjustVal_Compensate_vh[2]:= 0;

				pstStUnitParam_UnSave^.alrTotalAdjustVal_Auto_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrTotalAdjustVal_Rapid_vh[2]:= 0;
(*				pstStUnitParam^.alrTotalAdjustVal_ManuCoarse_vh[2]:= 0;*)
				pstStUnitParam_UnSave^.alrTotalAdjustVal_ManuFine_vh[2]:= 0;
				pstStUnitParam_UnSave^.alrTotalAdjustVal_Coupling_vh[2]:= 0;
//				pstStUnitParam^.alrTotalAdjustVal_Compensate_vh[2]:= 0;

				axHorMoving_M[iAxisId]:= FALSE;
				axHorMoving_G[iAxisId]:= FALSE;			
			END_IF

			(*增加了正反转信号启动延时2018.10.7.085705 by liu.yt*)
			wHorzMotorDir:=BOOL_TO_WORD(axHorMoving_M[iAxisId])+SHL(BOOL_TO_WORD(axHorMoving_G[iAxisId]),1);
			IF wHorzMotorDir<>awPreHorzMotorDir[iAxisId] THEN(*方向发生了变化*)
				IF wHorzMotorDir<>0THEN(*说明有正反转信号了*)
					axHorzMotorStart_Delay[iAxisId]:=TRUE;
				ELSE
					axHorzMotorStart_Delay[iAxisId]:=FALSE;
				END_IF
				axHorzMotorStart_DelayDne[iAxisId]:=FALSE;
				auiHorzMotorStart_Count[iAxisId]:=0;
				awPreHorzMotorDir[iAxisId]:=wHorzMotorDir;
			END_IF

			IF axHorzMotorStart_Delay[iAxisId] THEN(*启动延时*)
				IF auiHorzMotorStart_Count[iAxisId]>=iHorzMotorStart_DelayTime_MS/i_iCycleTime_Plc THEN
					auiHorzMotorStart_Count[iAxisId]:=0;
					axHorzMotorStart_Delay[iAxisId]:=FALSE;
					axHorzMotorStart_DelayDne[iAxisId]:=TRUE;
				ELSE
					auiHorzMotorStart_Count[iAxisId]:=auiHorzMotorStart_Count[iAxisId]+1;
				END_IF
			END_IF
			
			IF i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].xBtn_FromHMI_HorMove_M THEN
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].xBtn_FromHMI_HorMove_G:= FALSE;
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].xBtn_FromHMI_HorMove_M:= FALSE;
				IF NOT xLimit_Left THEN
					alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]-
						REAL_TO_LREAL(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].rStep_Horz*1000.0);
				END_IF			
			ELSIF i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].xBtn_FromHMI_HorMove_G THEN
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].xBtn_FromHMI_HorMove_M:= FALSE;
				i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].xBtn_FromHMI_HorMove_G:= FALSE;
				IF NOT xLimit_Right THEN
					alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]+
						REAL_TO_LREAL(i_pstStSysParam^.astStRSV_UnitParam_UnSave[iAxisId].rStep_Horz*1000.0);
				END_IF		
			END_IF
// 			(*2026.2.10.095914 增加从站横向步进量调整*)			
// 			IF pstStRSV_UnitParam_UnSave^.xHorMoving_M AND (NOT pstStRSV_UnitParam_UnSave^.xHorMoving_G) AND (NOT xLimit_Left) THEN
// 				(*左*)
// 				alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]-REAL_TO_LREAL(pstStRSV_UnitParam_UnSave^.rStep_Horz)
// 				;
// 				axHorMoving_G[iAxisId]:= FALSE;
// 				axHorMoving_M[iAxisId]:= TRUE;
// 
// 			ELSIF pstStRSV_UnitParam_UnSave^.xHorMoving_G AND (NOT pstStRSV_UnitParam_UnSave^.xHorMoving_M) AND (NOT xLimit_Right) THEN
// 				(*右*)
// 				alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]+REAL_TO_LREAL(pstStRSV_UnitParam_UnSave^.rStep_Horz)
// 				;
// 				axHorMoving_M[iAxisId]:= FALSE;
// 				axHorMoving_G[iAxisId]:= TRUE;
// 			ELSE	
// 				axHorMoving_M[iAxisId]:= FALSE;
// 				axHorMoving_G[iAxisId]:= FALSE;
// 			END_IF
// 			
			
			(*---------------------------2017-08-14 15:21:18
			/.手动调整
			.----------------------------------------------*)	
			IF axHorMovingBtn_M[iAxisId]  AND (NOT axHorMovingBtn_G[iAxisId]) AND (NOT xLimit_Left) (*AND 
			(NOT pstStRSV_UnitParam_UnSave^.xHorMoving_G)	AND 
			(NOT pstStRSV_UnitParam_UnSave^.xHorMoving_M)*) THEN
				(*左*)
				alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]-
				i_lrVel_HorzAdjust*	i_iCycleTime_Plc*1;
				
				axHorMoving_G[iAxisId]:= FALSE;
				axHorMoving_M[iAxisId]:= TRUE;
			ELSIF axHorMovingBtn_G[iAxisId]  AND (NOT axHorMovingBtn_M[iAxisId]) AND (NOT xLimit_Right)(* AND 
			(NOT pstStRSV_UnitParam_UnSave^.xHorMoving_G)	AND 
			(NOT pstStRSV_UnitParam_UnSave^.xHorMoving_M) *) THEN
				(*右*)
				alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId]+
				i_lrVel_HorzAdjust*	i_iCycleTime_Plc*1;
				
				axHorMoving_M[iAxisId]:= FALSE;
				axHorMoving_G[iAxisId]:= TRUE;
			ELSE
				
				axHorMoving_M[iAxisId]:= FALSE;
				axHorMoving_G[iAxisId]:= FALSE;

			
// 			ELSIF (NOT  axHorMovingBtn_G[iAxisId])  AND 
// 				(NOT axHorMovingBtn_M[iAxisId]) AND 
// 				(NOT axStopManuMove_Horz[iAxisId]) THEN
// 				axStopManuMove_Horz[iAxisId]:= TRUE;
// 				axHorMoving_M[iAxisId]:= FALSE;
// 				axHorMoving_G[iAxisId]:= FALSE;
// 				alrTotalAdjust_Horz[iAxisId]:= i_alrTarp_PrfPos[iAxisId]*
// 						pstStUnitParam^.uiDen_Horz*1000.0*pstStUnitParam^.rScrewPitch_Horz/
// 						GC_LRMOTORPPR_TRAP/UINT_TO_LREAL(pstStUnitParam^.uiNum_Horz);
// 				IF pstStUnitParam^.xMotRev_Horiz_ THEN
// 					alrTotalAdjust_Horz[iAxisId]:= -alrTotalAdjust_Horz[iAxisId];
// 				END_IF
			END_IF


			(*---------------------------2017-08-14 15:21:18
			/.横向限位处理
			.----------------------------------------------*)
			IF axHorMovingLimit_M[iAxisId] THEN(*操作侧*)
				axHorMoving_M[iAxisId]:= FALSE;
			END_IF

			IF axHorMovingLimit_G[iAxisId] THEN(*传动侧*)
				axHorMoving_G[iAxisId]:= FALSE;
			END_IF

			(*急停停止横向输出|2022.5.11.171513*)
			IF pstStGrpParam_UnSave^.xFlag_EStoping OR pstStGrpParam_UnSave^.xFlag_Estop THEN
				axHorMoving_M[iAxisId]:= FALSE;
				axHorMoving_G[iAxisId]:= FALSE;
			END_IF

			

			(*将操作侧和传动侧信号输出*)
			(*电机输出是按照正转和反转@一般情况正反手机电机的旋转方向是一致的即,都是向操作侧或者都是向传动侧
			我们定义正传是向操作侧@反转是向传动侧*)
//2026.5.12.143337点位控制横向不需要再输出到IO了			
// 			i_pastStIOMap_AxisBasic^[iAxisId].o_xHorzMotor_CW:=axHorMoving_M[iAxisId];
// 			i_pastStIOMap_AxisBasic^[iAxisId].o_xHorzMotor_CCW:=axHorMoving_G[iAxisId];	
			//2023.9.25.174830确定输出方向
			o_alrTotalAdjust_Horz[iAxisId]:= alrTotalAdjust_Horz[iAxisId];	
			IF pstStUnitParam_UnSave^.xMotRev_Horiz_ THEN
				o_alrTotalAdjust_Horz[iAxisId]:= -o_alrTotalAdjust_Horz[iAxisId];
			END_IF			
		END_FOR
	END_IF
END_IF