(*@CES
Name=KS_FB_HandwheelCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2f871db0-86b8-4868-b4d6-3d54ec95653d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_HandwheelCtl
VAR_INPUT
	i_xEn: BOOL;
	i_byUnitNumMax: BYTE;//色组数
	i_pastStHandWheel: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StHandWheel;
	i_pastStHandWheel_BtnCtl: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StHandWheel_BtnCtl;
	
	i_pabyUnitId_Ctl: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BYTE;//每个手持器控制的色组，可调整
	i_xFlag_Stop: BOOL;//停机状态
	i_xDebugMode: BOOL;//调试模式
	i_paxNeedZeroPos:  POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;//手轮计数清零标志
	i_paxFlag_Mode_Calid: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;//手持器标定标值
	i_paxFlag_LockHandwheel: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;//手持器suoding
	//i_paxFlag_Ctl_Prn: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxEn_HandWheel: POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxAdjust_Auto_V: POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	i_paxAdjust_Auto_H: POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	
	i_paxAcc_UnitId : POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	iN: INT;
	iM: INT;
	iRtn : INT;
	xFlag_Handwheel_Unit_One: BOOL;//手持器与色组一对一标值
	axFlag_LockHandwheel: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//手持器锁定标值
	xInit: BOOL:= FALSE;//初始化一些东西
	astStHandWheel_Rec: ARRAY [1..MAX_UNIT_NUM] OF StHandWheel;
	aiCtlStep_Handwheel: ARRAY [1..MAX_UNIT_NUM] OF INT;//手持器锁定标值
	aiCtlUnit_Handwheel: ARRAY [1..MAX_UNIT_NUM] OF INT;//手持器锁定标值
	iTemp:INT:=1;
	aiStartUnitId:ARRAY [1..MAX_UNIT_NUM] OF INT;//非一对一手持器，每个手持器控制的起始
	aiStopUnitId:ARRAY [1..MAX_UNIT_NUM] OF INT;//非一对一手持器，每个手持器控制的结束色组号
	axFlag_Mode_Calid: ARRAY [1..MAX_UNIT_NUM] OF BOOL;//手持器标定标值
	iTimeCnt_Lock:INT:= 600;//超过600个周期没操作，认为可以锁定手轮了防止误操作
	iTimeCnt_Lock_Init:INT:= 3429;//超过600个周期没操作(2分钟)，手轮初始化一次防止进入休眠
	aiCnt_Lock_Num: ARRAY [1..MAX_UNIT_NUM] OF INT;
	aiCnt_Lock_Num_Init: ARRAY [1..MAX_UNIT_NUM] OF INT;
	axFlag_Lock: ARRAY [1..MAX_UNIT_NUM,1..5] OF BOOL;//手轮无动作标志
	iUnitIdCtl: INT;
	aiCnt_LockBtn: ARRAY [1..MAX_UNIT_NUM] OF INT;
	iTimeCnt_LockBtn:INT:= 20;//超过20个周期没操作，认为可以锁定手轮了防止误操作
	afbAcc_AxisId: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	afbDec_AxisId: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	abyAxisId_handwheel: ARRAY [1..MAX_UNIT_NUM] OF BYTE;
	axEn_HandWheel: ARRAY [1..MAX_UNIT_NUM] OF BOOL;
	iK: INT;
	afbTRIG_Switch_Calib: ARRAY [1..MAX_UNIT_NUM] OF R_TRIG;
	fbKS_FB_HandwheelCtl_Reset : KS_FB_HandwheelCtl_Reset;
	xFlag_En_ModeCalib : BOOL;
//2024.12.05.170136 | bai.zy
	xHandWheelCtlSignalUnit : BOOL;
	iHandWheelCount : INT;
	
	aiAccCtlUnitId_Handwheel: ARRAY [1..MAX_UNIT_NUM] OF INT;//切换色组时手持器锁定的色组号
END_VAR



{IMPLEMENTATION}
IF i_xEn THEN
	IF (i_byUnitNumMax>=1 AND i_byUnitNumMax<= MAX_UNIT_NUM) AND
		i_pastStHandWheel<>0 AND
		i_pabyUnitId_Ctl<>0 AND
		i_pastStHandWheel_BtnCtl <> 0 AND
		i_paxNeedZeroPos <> 0 AND
		i_paxFlag_Mode_Calid <> 0 AND
		i_paxEn_HandWheel <> 0 AND
		i_paxAdjust_Auto_V <> 0 AND
		i_paxAdjust_Auto_H <> 0 THEN

	//	i_pastStHandWheel^[2] := i_pastStHandWheel^[3];
		IF NOT xInit THEN
			xInit:= TRUE;
			FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
				axFlag_LockHandwheel[iN]:= TRUE;
				axFlag_Mode_Calid[iN]:= FALSE;							
				FOR iM:=1 TO 5 BY 1 DO
					axFlag_Lock[iN,iM]:= FALSE;//用于判断手持器无动作的标志
				END_FOR
				aiCtlUnit_Handwheel[iN]:= MAX_UNIT_NUM;	
				axEn_HandWheel[iN]:= FALSE;								
			END_FOR

		ELSE//初始化完成就可以处理其他了
//2024.3.13.141555
// axEn_HandWheel[1]:= TRUE;
// axEn_HandWheel[2]:= FALSE;
			iHandWheelCount := 0;
			FOR iN := 1 TO i_byUnitNumMax BY 1 DO
				axEn_HandWheel[iN] := i_paxEn_HandWheel^[iN];
				IF axEn_HandWheel[iN] THEN
					iHandWheelCount := iHandWheelCount + 1;
				END_IF
			END_FOR
			
			IF iHandWheelCount = i_byUnitNumMax THEN
				xHandWheelCtlSignalUnit := TRUE;
			ELSE
				xHandWheelCtlSignalUnit := FALSE;
			END_IF

			FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
				IF axFlag_LockHandwheel[iN]  OR (NOT axEn_HandWheel[iN]) THEN
					aiCtlStep_Handwheel[iN]:= 1;//锁定状态
				ELSE
					IF xFlag_En_ModeCalib THEN//标定模式2023.7.26.094141更新轴选旋钮，先这么试一下
						IF i_xFlag_Stop AND i_xDebugMode THEN
							axFlag_Mode_Calid[aiCtlUnit_Handwheel[iN]]:= TRUE;
						ELSE
							axFlag_Mode_Calid[aiCtlUnit_Handwheel[iN]]:= FALSE;	
							xFlag_En_ModeCalib := FALSE;						
						END_IF
 					ELSE
 						axFlag_Mode_Calid[aiCtlUnit_Handwheel[iN]]:= FALSE;							
 					END_IF
					
					IF axFlag_Mode_Calid[aiCtlUnit_Handwheel[iN]] THEN
						aiCtlStep_Handwheel[iN]:= 2;//标定模式
					ELSE
						aiCtlStep_Handwheel[iN]:= 3;//运行模式
					END_IF
				END_IF
				
			END_FOR
			//换一下吧2024.3.13.132259循环手轮数不好处理
			
			FOR iN:=1 TO i_byUnitNumMax BY 1 DO
//			FOR iN:=1 TO i_byHandWheel_Num BY 1 DO
				IF i_pastStHandWheel^[iN].wButton_HardWheel=0 THEN//无按钮按下
					axFlag_Lock[iN,1]:= TRUE;
				ELSE
					axFlag_Lock[iN,1]:= FALSE;					
				END_IF
				IF i_pastStHandWheel^[iN].byKnob_Left-astStHandWheel_Rec[iN].byKnob_Left=0 THEN//轴选未操作
					axFlag_Lock[iN,2]:= TRUE;
				ELSE
					axFlag_Lock[iN,2]:= FALSE;						
				END_IF
				IF i_pastStHandWheel^[iN].byKnob_Right-astStHandWheel_Rec[iN].byKnob_Right=0 THEN//右旋钮无动作
					axFlag_Lock[iN,3]:= TRUE;
				ELSE
					axFlag_Lock[iN,3]:= FALSE;						
				END_IF		
				IF i_pastStHandWheel^[iN].lrTargetPos_HardWheel-astStHandWheel_Rec[iN].lrTargetPos_HardWheel=0 THEN//手轮无动作
					axFlag_Lock[iN,4]:= TRUE;
				ELSE
					axFlag_Lock[iN,4]:= FALSE;						
				END_IF		
				IF axFlag_Lock[iN,1] AND axFlag_Lock[iN,2] AND axFlag_Lock[iN,3] AND axFlag_Lock[iN,4] THEN//手轮本周期无动作
					aiCnt_Lock_Num[iN]:= aiCnt_Lock_Num[iN]+1;
					aiCnt_Lock_Num_Init[iN] := aiCnt_Lock_Num_Init[iN] +1;
					IF aiCnt_Lock_Num[iN]>=iTimeCnt_Lock THEN//手持器持续600周期无动作-20s-进入锁定状态
						axFlag_LockHandwheel[iN]:= TRUE;
						aiCnt_Lock_Num[iN] := 0;
					END_IF
					IF aiCnt_Lock_Num_Init[iN]>= iTimeCnt_Lock_Init THEN
;//						iRtn := GT_RN_UsbInit();
						aiCnt_Lock_Num_Init[iN] := 0;
					END_IF
				ELSE
					aiCnt_Lock_Num[iN]:= 0;
					aiCnt_Lock_Num_Init[iN] := 0;
				END_IF	
				
			END_FOR

			
			
			FOR iN:=1 TO i_byUnitNumMax BY 1 DO
//			FOR iN:=1 TO i_byHandWheel_Num BY 1 DO
				IF axEn_HandWheel[iN] THEN
					iUnitIdCtl:= aiCtlUnit_Handwheel[iN];
					afbAcc_AxisId[iN](CLK:= i_pastStHandWheel^[iN].wButton_HardWheel.0);
					afbDec_AxisId[iN](CLK:= i_pastStHandWheel^[iN].wButton_HardWheel.1);
					IF abyAxisId_handwheel[iN]<>i_pastStHandWheel^[iN].byKnob_Right THEN
						i_paxNeedZeroPos^[iN]:= TRUE;
						astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理	
						i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
					END_IF
					abyAxisId_handwheel[iN]:= i_pastStHandWheel^[iN].byKnob_Right;
					CASE aiCtlStep_Handwheel[iN] OF
						1: //手轮锁定，不允许操作
						//锁定后，所有按钮输入不响应
							IF NOT i_paxAcc_UnitId^[iN] THEN
								IF i_pastStHandWheel^[iN].wButton_HardWheel.0 AND i_pastStHandWheel^[iN].wButton_HardWheel.11 THEN
									//两个按钮同时按下，就认为需要解锁
									axFlag_LockHandwheel[iN]:= FALSE;//解锁
									i_paxNeedZeroPos^[iN]:= TRUE;
									astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
									i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
									
								END_IF
							ELSE
								IF afbAcc_AxisId[iN].Q THEN//继续增加
									iUnitIdCtl:= iUnitIdCtl+1;
									FOR iK:=1 TO i_byUnitNumMax BY 1 DO
										IF axEn_HandWheel[iK] THEN
											IF iUnitIdCtl= aiCtlUnit_Handwheel[iK] OR iUnitIdCtl > i_byUnitNumMax THEN//不能与其他手轮冲突
												IF iUnitIdCtl+1 > i_byUnitNumMax THEN//2024.12.05.133431 | bai.zy | 双手轮冲突、超过两个要重新做
													iUnitIdCtl:= 1;
												ELSE
													iUnitIdCtl:= iUnitIdCtl+1;
												END_IF
											END_IF
										END_IF
									END_FOR
									IF iUnitIdCtl>i_byUnitNumMax THEN
										iUnitIdCtl:= 1;
									END_IF
	// 								i_paxAcc_UnitId^[iN] := FALSE;
	// 								axFlag_LockHandwheel[iN]:= FALSE;//解锁
									i_paxNeedZeroPos^[iN]:= TRUE;
									astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
									i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
	
									aiCtlUnit_Handwheel[iN]:=iUnitIdCtl;
								ELSIF i_pastStHandWheel^[iN].wButton_HardWheel.1 THEN//确认
									iUnitIdCtl:= iUnitIdCtl+1;
									FOR iK:=1 TO i_byUnitNumMax BY 1 DO
										IF axEn_HandWheel[iK] THEN
											IF iUnitIdCtl= aiCtlUnit_Handwheel[iK] OR iUnitIdCtl > i_byUnitNumMax THEN//不能与其他手轮冲突
												IF iUnitIdCtl+1 > i_byUnitNumMax THEN//2024.12.05.133431 | bai.zy | 双手轮冲突、超过两个要重新做
													iUnitIdCtl:= 1;
												ELSE
													iUnitIdCtl:= iUnitIdCtl+1;
												END_IF
											END_IF
										END_IF
									END_FOR
									IF iUnitIdCtl>i_byUnitNumMax THEN
										iUnitIdCtl:= 1;
									END_IF
									i_paxAcc_UnitId^[iN] := FALSE;
									axFlag_LockHandwheel[iN]:= FALSE;//解锁
									i_paxNeedZeroPos^[iN]:= TRUE;
									astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
									i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
									
									IF xHandWheelCtlSignalUnit THEN
										aiCtlUnit_Handwheel[iN]:=iN;
									ELSE
										aiCtlUnit_Handwheel[iN]:=iUnitIdCtl;
									END_IF
									
								ELSIF i_pastStHandWheel^[iN].wButton_HardWheel.2 THEN//取消
									aiCtlUnit_Handwheel[iN] := aiAccCtlUnitId_Handwheel[iN];
									i_paxAcc_UnitId^[iN] := FALSE;
									axFlag_LockHandwheel[iN]:= FALSE;//解锁
									i_paxNeedZeroPos^[iN]:= TRUE;
									astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
									i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
								ELSE//其他按键无效
									;
								END_IF
							END_IF
							
							
							afbTRIG_Switch_Calib[iN](CLK:= g_xModeCalibSwitch);
							g_xModeCalibSwitch := FALSE;
							IF afbTRIG_Switch_Calib[iN].Q THEN
								//axFlag_Mode_Calid[iUnitIdCtl]:= NOT axFlag_Mode_Calid[iUnitIdCtl];
								xFlag_En_ModeCalib:= NOT xFlag_En_ModeCalib;
							END_IF
		(*
		xReqMoveLeft: BOOL;
		xReqMoveRight: BOOL;
		xReqMoveUp: BOOL;
		xReqMoveDn: BOOL;
		xReqLoad_Unload: BOOL;
		xReqPress_Up: BOOL;
		xReqPress_Dn: BOOL;
		xReqSwitch_P_N: BOOL;
		xReqMoveFor: BOOL;
		xReqMoveRev: BOOL;
		xReq_Confirm_Load_Unload: BOOL;//
		xReq_Confirm_Load_Unload
		xReq_Confirm_press_up: BOOL;
		xReq_Confirm_press_dn: BOOL;
		*)
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMove_M:= FALSE;
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMove_G:= FALSE;
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveUp:= FALSE;
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveDn:= FALSE;
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqSwitch_Calib:= FALSE;
							
							FOR iM :=1 TO gc_iMax_PressureRoller_Unit BY 1 DO
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqLoad_Unload[iM]:= FALSE;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Up[iM]:= FALSE;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Dn[iM]:= FALSE;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveFor[iM]:= FALSE;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveRev[iM]:= FALSE;							
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_Load_Unload[iM]:= FALSE;			
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_up[iM]:= FALSE;			
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_dn[iM]:= FALSE;
							END_FOR
							
						2://标定模式
							IF afbAcc_AxisId[iN].Q THEN
								i_paxAcc_UnitId^[iN] := TRUE;
								aiAccCtlUnitId_Handwheel[iN] := iUnitIdCtl;
								axFlag_LockHandwheel[iN]:= TRUE;//锁定
								i_paxNeedZeroPos^[iN]:= TRUE;
								astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
								i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
	// 							iUnitIdCtl:= iUnitIdCtl+1;
	// 							FOR iK:=1 TO i_byUnitNumMax BY 1 DO
	// 								IF axEn_HandWheel[iK] THEN
	// 									IF iUnitIdCtl= aiCtlUnit_Handwheel[iK] OR iUnitIdCtl > i_byUnitNumMax THEN//不能与其他手轮冲突
	// 										IF iUnitIdCtl+1 > i_byUnitNumMax THEN//2024.12.05.133431 | bai.zy | 双手轮冲突、超过两个要重新做
	// 											iUnitIdCtl:= 1;
	// 										ELSE
	// 											iUnitIdCtl:= iUnitIdCtl+1;
	// 										END_IF
	// 									END_IF
	// 								END_IF
	// 							END_FOR
	// 							IF iUnitIdCtl>i_byUnitNumMax THEN
	// 								iUnitIdCtl:= 1;
	// 							END_IF
	// 							i_paxNeedZeroPos^[iN]:= TRUE;
	// 							astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
	// 							i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
	// 							
							END_IF//循环切换
	// 						IF xHandWheelCtlSignalUnit THEN
	// 							aiCtlUnit_Handwheel[iN]:=iN;
	// 						ELSE
	// 							aiCtlUnit_Handwheel[iN]:=iUnitIdCtl;
	// 						END_IF
							
							IF i_pastStHandWheel^[iN].byKnob_Left=18 THEN
										
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_Load_Unload[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.2;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_up[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.5;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_dn[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.9;
								
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_All[1]:= 
									i_pastStHandWheel^[iN].byKnob_Right=13;	
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_M[1]:= 
									i_pastStHandWheel^[iN].byKnob_Right=14;	
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_G[1]:= 
									i_pastStHandWheel^[iN].byKnob_Right=15;								
		//前进后退需要服用                                                       
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveFor[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.7;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveRev[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.8;
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 2, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 3, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
							ELSIF i_pastStHandWheel^[iN].byKnob_Left=19 THEN
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_Load_Unload[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.2;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_up[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.5;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_dn[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.9;
								
			
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_All[2]:= 
									i_pastStHandWheel^[iN].byKnob_Right=13;	
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_M[2]:= 
									i_pastStHandWheel^[iN].byKnob_Right=14;	
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_G[2]:= 
									i_pastStHandWheel^[iN].byKnob_Right=15;								
		//前进后退需要服用                                                       
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveFor[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.7;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveRev[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.8;
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 1, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 3, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
							ELSIF i_pastStHandWheel^[iN].byKnob_Left=20 THEN
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_Load_Unload[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.2;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_up[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.5;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReq_Confirm_press_dn[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.9;
								
			
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_All[3]:= 
									i_pastStHandWheel^[iN].byKnob_Right=13;	
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_M[3]:= 
									i_pastStHandWheel^[iN].byKnob_Right=14;	
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_G[3]:= 
									i_pastStHandWheel^[iN].byKnob_Right=15;								
		//前进后退需要服用                                                       
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveFor[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.7;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqMoveRev[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.8;
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 1, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 2, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
							ELSE
								FOR iM := 1 TO gc_iMax_PressureRoller_Unit BY 1 DO
									fbKS_FB_HandwheelCtl_Reset(i_iD:= iM, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								END_FOR
							END_IF
						
							afbTRIG_Switch_Calib[iN](CLK:= i_pastStHandWheel^[iN].wButton_HardWheel.12 OR g_xModeCalibSwitch);
							g_xModeCalibSwitch := FALSE;
							IF afbTRIG_Switch_Calib[iN].Q THEN
								//axFlag_Mode_Calid[iUnitIdCtl]:= NOT axFlag_Mode_Calid[iUnitIdCtl];
								xFlag_En_ModeCalib:= NOT xFlag_En_ModeCalib;
							END_IF
							
							IF i_pastStHandWheel^[iN].wButton_HardWheel= 2048 THEN//单独按下锁定才生效
								aiCnt_LockBtn[iN]:= aiCnt_LockBtn[iN]+1;
								IF aiCnt_LockBtn[iN]>iTimeCnt_LockBtn THEN
									axFlag_LockHandwheel[iN]:= TRUE;
								END_IF
							ELSE
								aiCnt_LockBtn[iN]:= 0;
							END_IF
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].lrPos_HandWheelChange:= i_pastStHandWheel^[iN].lrTargetPos_HardWheel-
										astStHandWheel_Rec[iN].lrTargetPos_HardWheel;	
						3://运行模式
							IF afbAcc_AxisId[iN].Q THEN
								i_paxAcc_UnitId^[iN] := TRUE;
								aiAccCtlUnitId_Handwheel[iN] := iUnitIdCtl;
								axFlag_LockHandwheel[iN]:= TRUE;//锁定
								i_paxNeedZeroPos^[iN]:= TRUE;
								astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
								i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
	// 							iUnitIdCtl:= iUnitIdCtl+1;
	// 							FOR iK:=1 TO i_byUnitNumMax BY 1 DO
	// 								IF axEn_HandWheel[iK] THEN
	// 									IF iUnitIdCtl= aiCtlUnit_Handwheel[iK] OR iUnitIdCtl > i_byUnitNumMax THEN//不能与其他手轮冲突
	// 										IF iUnitIdCtl+1 > i_byUnitNumMax THEN//2024.12.05.133431 | bai.zy | 双手轮冲突、超过两个要重新做
	// 											iUnitIdCtl:= 1;
	// 										ELSE
	// 											iUnitIdCtl:= iUnitIdCtl+1;
	// 										END_IF
	// 									END_IF
	// 								END_IF
	// 							END_FOR
	// 							IF iUnitIdCtl>i_byUnitNumMax THEN
	// 								iUnitIdCtl:= 1;
	// 							END_IF
	// 							i_paxNeedZeroPos^[iN]:= TRUE;
	// 							astStHandWheel_Rec[iN].lrTargetPos_HardWheel:= 0;//手轮值清零-好处理
	// 							i_pastStHandWheel^[iN].lrTargetPos_HardWheel:= 0;
	// 							
							END_IF
	// 						IF xHandWheelCtlSignalUnit THEN
	// 							aiCtlUnit_Handwheel[iN]:=iN;
	// 						ELSE
	// 							aiCtlUnit_Handwheel[iN]:=iUnitIdCtl;
	// 						END_IF
							
							IF i_pastStHandWheel^[iN].byKnob_Left=18 THEN
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqLoad_Unload[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.2 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Up[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.5 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Dn[1]:= i_pastStHandWheel^[iN].wButton_HardWheel.9 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_All[1]:= 
									i_pastStHandWheel^[iN].byKnob_Right=13;			
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_M[1]:= 
									i_pastStHandWheel^[iN].byKnob_Right=14;	    
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_G[1]:= 
									i_pastStHandWheel^[iN].byKnob_Right=15;	
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 3, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 2, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
							ELSIF i_pastStHandWheel^[iN].byKnob_Left=19 THEN	
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqLoad_Unload[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.2 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Up[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.5 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Dn[2]:= i_pastStHandWheel^[iN].wButton_HardWheel.9 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_All[2]:= 
									i_pastStHandWheel^[iN].byKnob_Right=13;			
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_M[2]:= 
									i_pastStHandWheel^[iN].byKnob_Right=14;	    
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_G[2]:= 
									i_pastStHandWheel^[iN].byKnob_Right=15;	
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 1, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 3, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));	
							ELSIF i_pastStHandWheel^[iN].byKnob_Left=20 THEN
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqLoad_Unload[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.2 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Up[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.5 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axReqPress_Dn[3]:= i_pastStHandWheel^[iN].wButton_HardWheel.9 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
								
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_All[3]:= 
									i_pastStHandWheel^[iN].byKnob_Right=13;			
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_M[3]:= 
									i_pastStHandWheel^[iN].byKnob_Right=14;	    
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].axFlag_Ctl_Roller_G[3]:= 
									i_pastStHandWheel^[iN].byKnob_Right=15;
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 1, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								fbKS_FB_HandwheelCtl_Reset(i_iD:= 2, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
							ELSE
								FOR iM := 1 TO gc_iMax_PressureRoller_Unit BY 1 DO
									fbKS_FB_HandwheelCtl_Reset(i_iD:= iM, i_pstStHandWheel_BtnCtl:= ADR(i_pastStHandWheel_BtnCtl^[iUnitIdCtl]));
								END_FOR  
							END_IF
							
							//2025.03.04.154540 | 横向
							IF i_paxAdjust_Auto_H^[iUnitIdCtl] THEN
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xAdjust_H_M:= i_pastStHandWheel^[iN].wButton_HardWheel.3;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xAdjust_H_G:= i_pastStHandWheel^[iN].wButton_HardWheel.4;
							ELSE
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMove_M:= i_pastStHandWheel^[iN].wButton_HardWheel.3;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMove_G:= i_pastStHandWheel^[iN].wButton_HardWheel.4;
							END_IF
							//2025.03.04.154550| 纵向
							IF i_paxAdjust_Auto_V^[iUnitIdCtl] THEN//自动是修正量
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xAdjust_V_Up:= i_pastStHandWheel^[iN].wButton_HardWheel.7;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xAdjust_V_Dn:= i_pastStHandWheel^[iN].wButton_HardWheel.8;
							ELSE//手动是调整量
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveUp:= i_pastStHandWheel^[iN].wButton_HardWheel.7;
								i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveDn:= i_pastStHandWheel^[iN].wButton_HardWheel.8;
							END_IF
							
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReq_Inch_Net:= i_pastStHandWheel^[iN].wButton_HardWheel.1;
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReq_Confirm_Adjust_PressDn:= i_pastStHandWheel^[iN].wButton_HardWheel.6;
							
	
							afbTRIG_Switch_Calib[iN](CLK:= i_pastStHandWheel^[iN].wButton_HardWheel.12 OR g_xModeCalibSwitch);
							g_xModeCalibSwitch := FALSE;
							IF afbTRIG_Switch_Calib[iN].Q THEN
								//axFlag_Mode_Calid[iUnitIdCtl]:= NOT axFlag_Mode_Calid[iUnitIdCtl];
								xFlag_En_ModeCalib:= NOT xFlag_En_ModeCalib;
							END_IF			
							
								
	// 						IF i_xFlag_Stop THEN//运行模式时，停机状态下需要前进后退吗？，先按这个复用吧-两个键同时按下
	// 							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveFor:= 
	// 								i_pastStHandWheel^[iN].wButton_HardWheel.7 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
	// 							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveRev:= 
	// 								i_pastStHandWheel^[iN].wButton_HardWheel.8 AND i_pastStHandWheel^[iN].wButton_HardWheel.11;
	// 						ELSE//非停机状态就不给用前进后退了吧，就靠这个手轮或者进入退出使用了
	// 							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveFor:= FALSE;
	// 							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].xReqMoveRev:= FALSE;
	// 						END_IF
							IF i_pastStHandWheel^[iN].wButton_HardWheel= 2048 THEN//单独按下锁定才生效
								aiCnt_LockBtn[iN]:= aiCnt_LockBtn[iN]+1;
								IF aiCnt_LockBtn[iN]>iTimeCnt_LockBtn THEN
									axFlag_LockHandwheel[iN]:= TRUE;
								END_IF
							ELSE
								aiCnt_LockBtn[iN]:= 0;
							END_IF		
							i_pastStHandWheel_BtnCtl^[iUnitIdCtl].lrPos_HandWheelChange:= i_pastStHandWheel^[iN].lrTargetPos_HardWheel-
										astStHandWheel_Rec[iN].lrTargetPos_HardWheel;							
					END_CASE
					i_pabyUnitId_Ctl^[iN]:= INT_TO_BYTE(aiCtlUnit_Handwheel[iN]);
	//				i_paxFlag_Ctl_Prn^[iUnitIdCtl]:= axFlag_Ctl_Prn[iUnitIdCtl];
					i_paxFlag_Mode_Calid^[iUnitIdCtl]:= axFlag_Mode_Calid[iUnitIdCtl];//手持器标定标值
					i_paxFlag_LockHandwheel^[iN]:= axFlag_LockHandwheel[iN];//手持器suoding	
				ELSE
					i_pastStHandWheel^[iN].byCtlSts_HandWheel.7:= FALSE;	
				END_IF				
			END_FOR
	
			sysmemcpy(ADR(astStHandWheel_Rec),i_pastStHandWheel,SIZEOF(astStHandWheel_Rec));
		END_IF
	END_IF
END_IF