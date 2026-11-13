(*@CES
Name=StTrapAxisParam_Gantray
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=097a3e0e-cb40-441d-8bbc-7d204f3f757b
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StTrapAxisParam_Gantray :
STRUCT
	xRev_Motor_M: BOOL;
	xRev_Motor_G: BOOL;
	
	lrPos_ZeroPos_Enc_M: LREAL;//原点位置
	lrPos_CurPos_Enc_M: LREAL;//当前编码器位置
	lrPos_CurPos_Prf_M: LREAL;//当前规划位置
	lrPos_CurPos_Prf: LREAL;//龙门轴规划期
	lrCurPos_mm_M: LREAL;//当前位置距离远点的物理距离
	lrPos_Limit_For_mm_M: LREAL;//辊子前表面位置（与底辊/版辊的切点的位置）
	lrPos_Limit_Rev_mm_M: LREAL;//辊子前表面位置（与网辊的切点的位置/网辊距离换版位的位置）
	lrPos_ZeroPos_Enc_G: LREAL;//原点位置
	lrPos_CurPos_Enc_G: LREAL;//当前编码器位置
	lrPos_CurPos_Prf_G: LREAL;//当前规划位置
	lrPos_CurPos_Enc: LREAL;//龙门轴编码器位置

	lrCurPos_mm_G: LREAL;//当前位置距离远点的物理距离
	lrPos_Limit_For_mm_G: LREAL;//辊子前表面位置（与底辊/版辊的切点的位置）
	lrPos_Limit_Rev_mm_G: LREAL;//辊子前表面位置（与网辊的切点的位置/网辊距离换版位的位置）
	xMoveFor_M: BOOL;//M侧前进
	xMoveFor_G: BOOL;//G侧前进
	xMoveRev_M: BOOL;//M侧后退
	xMoveRev_G: BOOL;//G侧后退
	xRollerMoveFor: BOOL;//整体前进
	xRollerMoveRev: BOOL;//整体后退
	//以上是针对界面的按钮，点一下走一次，
	xMoveFor_Long: BOOL;//整体前进-长按一直走，松开停
	xMoveRev_Long: BOOL;//整体后退-长按一直走，松开停
	xMove_To_PressDn: BOOL;//前往合压位动作
	xMove_To_PressUp: BOOL;//前往离压位动作
	xMove_To_Load_Unload: BOOL;//前往换版位动作

	lrPos_HandWheelChange: LREAL;//手轮位移处理
	bySts_HandWheel: BYTE;//手轮当前的档位选择 =1：整体移动
												//=2：M侧移动
												//=3：G侧移动
	xFlag_MoveEn:BOOL;//移动使能-非下伺服状态就行
	
	xConfirm_Dn_Press:BOOL;//合压位标定；
	xConfirm_Up_Press:BOOL;//离压位标定；
	xConfirm_Load_Unload_Press:BOOL;//换版位标定；
	
	lrposConfirm_Dn_Press_M:LREAL;//合压位标定；
	lrposConfirm_Up_Press_M:LREAL;//离压位标定；
	lrposConfirm_Load_Unload_Press_M:LREAL;//换版位标定；
	lrposConfirm_Dn_Press_G:LREAL;//合压位标定；
	lrposConfirm_Up_Press_G:LREAL;//离压位标定；
	lrposConfirm_Load_Unload_Press_G:LREAL;//换版位标定；
	
	rweigth_Zero_Confirm					: REAL;//标定时候棍子距离原点的距离-底辊切点
	rweigth_Zero					: REAL;//当前棍子与原点的距离-底辊切点
	xSts_Calid_Pos:BOOL;//位置标定模式
	
	byCurPos_M: BYTE;//记录一下当前位置
	byCurPos_G: BYTE;//记录一下当前位置
	xConfirm_Adjust_PressDn: BOOL;//矫正位置
	xMoveUp_To_Avoidance:BOOL;//胶带避让使能-裁切避让
	rMoveUp_mm_Avoidance:REAL;//避让厚度
	
	xMove_To_Up_Press_ing:BOOL; //前往离压位中
	xMove_To_Dn_Press_ing:BOOL; //前往合压位中
	xMove_To_Load_Unload_Press_ing:BOOL; //前往换版位中
	
	xAxisPrfStop_M:BOOL;//规划器停止
	xAxisPrfStop_G:BOOL;//规划器停止

	xMove_To_Up_Avoidance: BOOL;
	xMove_To_Dn_Avoidance: BOOL;
	xMove_To_Up_Avoidance_ing: BOOL;//避让中
	
	rTorque_M : REAL;
	rTorque_G : REAL;
	
	iRatedCount_M : INT;
	iPeakCount_M : INT;
	iRatedCount_G : INT;
	iPeakCount_G : INT;
	xPressFlag_Stop : BOOL;
	
	xMoveFor_Test_For_Rev_For : BOOL;
	xMoveFor_Test_For_Rev_Rev : BOOL;
	
	xMove_To_Dn_Press_end: BOOL;
	

//2023.12.27.155445	
//这个是实际标定的位置2023.12.12.185827
	lrposConfirm_Dn_Press_M_Confirm:LREAL;//合压位标定；
	lrposConfirm_Up_Press_M_Confirm:LREAL;//离压位标定；
	lrposConfirm_Load_Unload_Press_M_Confirm:LREAL;//换版位标定；
	lrposConfirm_Dn_Press_G_Confirm:LREAL;//合压位标定；
	lrposConfirm_Up_Press_G_Confirm:LREAL;//离压位标定；
	lrposConfirm_Load_Unload_Press_G_Confirm:LREAL;//换版位标定；
	
//2024.01.15.104029
	xConfirmDnPosDne_Pressure_M : BOOL;//合压位标定完成标志
	xConfirmDnPosDne_Pressure_G : BOOL;
	xConfirmload_unloadPosDne_Pressure_M : BOOL;
	xConfirmload_unloadPosDne_Pressure_G : BOOL;//换版位标定完成标志
	
// 2024.10.21.114937 | bai.zy | 版辊网辊操作侧传动侧标定平行标志、标定平行后产生的误差值 18字节
	xConfirmParallelPos : BOOL;//平行确认按钮
	lrParallelError_MM : LREAL;//计算出的两侧误差
	
//2024.10.21.114530 | bai.zy | 版辊网辊操作侧传动侧平行位置标定值	32字节
	lrEncPosParallel_M : LREAL;
	lrEncPosParallel_G : LREAL;
//2024.10.21.114530 | bai.zy | 版辊网辊操作侧传动侧合压位偏移量	  32字节
	lrPrintPosOffsetDn_M : LREAL;
	lrPrintPosOffsetDn_G : LREAL;
	
	xCanReFlashPos : BOOL;
	xRefleshPos : BOOL;
	
//2024.11.26.222747 | 增加站号
	iStationId_M : INT;
	iStationId_G : INT;	
	
//2024.12.03.152342 | 增加调试阶段测试压力电机反复来回运行
	xPressDebugMode_MoveStart : BOOL;
	xPressDebugMode_MoveFor : BOOL;
	xPressDebugMode_MoveRev : BOOL;	
	xCalidPressLimit_Max : BOOL;
	
	lrEncPosLimit_M_Max : LREAL;
	lrEncPosLimit_G_Max : LREAL;
//2024.12.11.165903 | 印版辊快速升降	
	xManuForPanel : BOOL;
	xManuNeedStop : BOOL;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
