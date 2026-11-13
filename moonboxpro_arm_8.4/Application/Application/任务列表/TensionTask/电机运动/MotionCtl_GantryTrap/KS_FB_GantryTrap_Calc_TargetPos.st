(*@CES
Name=KS_FB_GantryTrap_Calc_TargetPos
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0bce8d11-2bc3-4a0c-8964-1d70c50dfb2a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GantryTrap_Calc_TargetPos
//一组龙门的控制？
VAR_INPUT
	i_xEn: BOOL;
	i_uiNum: UINT;//压力电机减速比
	i_uiDen: UINT;
	i_rScrewPitch: REAL;//压力电机螺杆螺距
	i_rUp_Dn_Length: REAL;//合压位离压位距离
	i_rGirth_Roller: REAL;//棍子周长，秦华记录带长，只对于张带辊有效
	i_xStopOrEstop_Valid: BOOL;
	
	i_prGirth_Confirm: POINTER TO REAL;//记录标定的周长
	i_xFlag_Print: BOOL;
	i_xStep_Fast: BOOL;//长步选择
	i_rStep_Fast: REAL;//长步步幅
	i_rStep_Little: REAL;//长步步幅
	i_rVel_Fast: REAL;//快速
	i_rVel_Little: REAL;//慢速	
	i_plrTargetPos_All: POINTER TO LREAL;
	i_plrTargetPos_M: POINTER TO LREAL;
	i_plrTargetPos_G: POINTER TO LREAL;
	
	i_pstStTrapAxisParam_Gantray : POINTER TO StTrapAxisParam_Gantray;	
	i_xFlag_Estop: BOOL;
//	i_rDistanceForAvoidPrnGear: REAL;
	i_pxFinishConfirm_Adjust_PressDn : POINTER TO BOOL;
	//2026.01.16.140531  新增品字型
	i_rStep_HMI_Use: REAL;
	i_rProportion :REAL;
	i_xMove_to_Up_Estop : BOOL;
	i_ReqResetEstop: BOOL;//急停复位
	i_rMaxErr : REAL;
	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_rVel: REAL;
	o_lrTargetPos_All: LREAL;
	o_lrTargetPos_M: LREAL;
	o_lrTargetPos_G: LREAL;
	o_lrTemp_Len_Up_Pos : LREAL;
	o_lrTemp_Len_Load_Unload_Pos : LREAL;
	//2026.01.17.93413 新增
	o_lrK_Dynamic:LREAL;	
END_VAR
VAR
	//根据版周长和标定位置计算出对应版周的对应位置
// 	lrposConfirm_Dn_Press_Temp_M:LREAL;//合压位标定；
// 	lrposConfirm_Up_Press_Temp_M:LREAL;//离压位标定；
// 	lrposConfirm_Load_Unload_Press_Temp_M:LREAL;//换版位标定；
// 	lrposConfirm_Dn_Press_Temp_G:LREAL;//合压位标定；
// 	lrposConfirm_Up_Press_Temp_G:LREAL;//离压位标定；
// 	lrposConfirm_Load_Unload_Press_Temp_G:LREAL;//换版位标定；	
	lrTemp: LREAL;	
	fbTRIG_Confirm_load_unload: R_TRIG;
	fbTRIG_Confirm_PressUp: R_TRIG;
	fbTRIG_Confirm_PressDn: R_TRIG;
	fbTRIG_Confirm_ParallelPos: R_TRIG;
	fbTRIG_xCalidPressLimit_Max: R_TRIG;
	lrTemp_Len_Load_Unload_Pos: LREAL;
	lrTemp_100um_pos:LREAL:=167772;
	xPosIn: BOOL;
	xPosOut: BOOL;
	rStep_Use: REAL;
	xClearVelSetCurPos_For: BOOL;
	iClearVelSetCurPosCount_For:INT;
	xClearVelSetCurPos_Rev: BOOL;
	iClearVelSetCurPosCount_Rev:INT;	
	rTemp_MovePos_M: REAL;
	rTemp_MovePos_G: REAL;
	lrTarPos_M_Temp: LREAL;
	lrTarPos_G_Temp: LREAL;
	xClearVelSetCurPos_HandWheel: BOOL;
	iClearVelSetCurPosCount_HandWheel:INT;
	rTemp: REAL;
	xPreStop_Prf_M: BOOL;
	xPreStop_Prf_G: BOOL;
	xMove_TO_TarFlag_M: BOOL;
	xMove_TO_TarFlag_G: BOOL;
	
	lrEncParallelError_M : LREAL;
	lrEncParallelError_G : LREAL;
	
	rStep_Panel : REAL;
	rVel_Panel : REAL;

	lrK_Dynamic:REAL:=1;	
//	lrDistanceForAvoidPrnGear : LREAL;
	fbTRIG_Move_to_Up: R_TRIG;
	fbTRIG_Move_to_Dn: R_TRIG;
	fbTRIG_Move_to_Unload: R_TRIG;

	//2026.05.10.003923 | + | 增加限位保护
	rLast_TarPos_All : REAL;
	rLast_TarPos_M : REAL;
	rLast_TarPos_G : REAL;
	rLast_ErrPos : REAL;
	
	
	rErr_TarPos_All : REAL;
	rErr_TarPos_M : REAL;
	rErr_TarPos_G : REAL;
	rErr_Pos : REAL;
		
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_uiNum<>0 AND i_uiDen<>0 AND i_rScrewPitch<>0 AND i_pstStTrapAxisParam_Gantray<>0 THEN
//2023.12.27.185420处理都放外面		
		//先计算当前位置（M侧和G侧）//先就以合压位作为原点吧
		
		
// 			g_rtest:=i_rVel_Fast;
// 			g_uitest1:=i_uiNum;
// 			g_uitest2:=i_uiDen;
// 			g_rtest1:=i_rScrewPitch;
			
		i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_M:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M;
		IF i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_M<>0 THEN//未标定
			//当前位置需要根据电机正反计算
			IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
				i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_M:= -1*
					(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M-i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_M)*
					i_rScrewPitch*UINT_TO_LREAL(i_uiDen)/GC_LRMOTORPPR_TRAP/UINT_TO_REAL(i_uiNum);	
				//计算一下前后表面的位置
	
			ELSE
				i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_M:= 1*
					(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M-i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_M)*
					i_rScrewPitch*UINT_TO_LREAL(i_uiDen)/GC_LRMOTORPPR_TRAP/UINT_TO_REAL(i_uiNum);				
			END_IF
		ELSE
			i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_M:= 0;
		END_IF
		//i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_G:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm;
		i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_G:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G;
		IF i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_G<>0 THEN//未标定
			//当前位置需要根据电机正反计算
			IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_G THEN
				i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_G:= -1*
					(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G-i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_G)*
					i_rScrewPitch*UINT_TO_LREAL(i_uiDen)/GC_LRMOTORPPR_TRAP/UINT_TO_REAL(i_uiNum);	
			ELSE
				i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_G:= 1*
					(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G-i_pstStTrapAxisParam_Gantray^.lrPos_ZeroPos_Enc_G)*
					i_rScrewPitch*UINT_TO_LREAL(i_uiDen)/GC_LRMOTORPPR_TRAP/UINT_TO_REAL(i_uiNum);				
			END_IF
		ELSE
			i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_G:= 0;			
		END_IF
		

	
		//处理一下当前位置判断
		i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 0;
		lrTemp_100um_pos:= 0.1*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(i_uiNum)/
						i_rScrewPitch/
						UINT_TO_REAL(i_uiDen);	
		IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
			IF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)>lrTemp_100um_pos THEN
				(*版辊操作侧位置在合压位和底辊中间*)				
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 1;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)<lrTemp_100um_pos THEN
				(*在合压位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 2;									
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)>lrTemp_100um_pos THEN
				(*在合压位和离压位之间*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 3;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)<lrTemp_100um_pos THEN
				(*在离压位*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 4;				
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_M)>lrTemp_100um_pos THEN
				(*在换版位和离压位之间*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 5;				
			ELSE(*其他都算在换版位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 0;												
			END_IF
		ELSE
			IF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)<(-1*lrTemp_100um_pos) THEN
				(*版辊操作侧位置在合压位和底辊中间*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 1;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)<lrTemp_100um_pos THEN
				(*在合压位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 2;									
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M)>lrTemp_100um_pos THEN
				(*在合压位和离压位之间*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 3;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)<lrTemp_100um_pos THEN
				(*在离压位*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 4;				
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_M)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M)>lrTemp_100um_pos THEN
				(*在换版位和离压位之间*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 5;				
			ELSE(*其他都算在换版位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_M:= 0;												
			END_IF			
		END_IF
		i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 0;
		lrTemp_100um_pos:= 0.1*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(i_uiNum)/
						i_rScrewPitch/
						UINT_TO_REAL(i_uiDen);	
		IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_G THEN
			IF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)>lrTemp_100um_pos THEN
				(*版辊操作侧位置在合压位和底辊中间*)				
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 1;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)<lrTemp_100um_pos THEN
				(*在合压位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 2;									
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)>lrTemp_100um_pos THEN
				(*在合压位和离压位之间*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 3;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)<lrTemp_100um_pos THEN
				(*在离压位*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 4;				
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_G)>lrTemp_100um_pos THEN
				(*在换版位和离压位之间*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 5;				
			ELSE(*其他都算在换版位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 0;												
			END_IF
		ELSE
			IF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)<(-1*lrTemp_100um_pos) THEN
				(*版辊操作侧位置在合压位和底辊中间*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 1;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)<lrTemp_100um_pos THEN
				(*在合压位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 2;									
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G)>lrTemp_100um_pos THEN
				(*在合压位和离压位之间*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 3;				
			ELSIF (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)>(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)<lrTemp_100um_pos THEN
				(*在离压位*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 4;				
			ELSIF  (i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_G)<(-1*lrTemp_100um_pos) AND
				(i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G)>lrTemp_100um_pos THEN
				(*在换版位和离压位之间*)	
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 5;				
			ELSE(*其他都算在换版位*)
				i_pstStTrapAxisParam_Gantray^.byCurPos_G:= 0;												
			END_IF
			
		END_IF

		
		
		//这里处理一下再次按按钮逻辑-运行过程中不能再动了
		IF i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing AND 
			i_pstStTrapAxisParam_Gantray^.byCurPos_G=2 AND 
			i_pstStTrapAxisParam_Gantray^.byCurPos_M=2 THEN//到位了，就可以处理其他按钮
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_end:= TRUE;
			
		END_IF
		IF i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing AND 
			i_pstStTrapAxisParam_Gantray^.byCurPos_G=4 AND 
			i_pstStTrapAxisParam_Gantray^.byCurPos_M=4 THEN//到位了，就可以处理其他按钮
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing:= FALSE;
		END_IF	
		IF i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing AND 
			i_pstStTrapAxisParam_Gantray^.byCurPos_G=0 AND 
			i_pstStTrapAxisParam_Gantray^.byCurPos_M=0 THEN//到位了，就可以处理其他按钮
			i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing:= FALSE;
		END_IF	
		
		fbTRIG_Move_to_Up(CLK:= i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing);
		fbTRIG_Move_to_Dn(CLK:= i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing);
		fbTRIG_Move_to_Unload(CLK:= i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing);
		IF fbTRIG_Move_to_Up.Q OR fbTRIG_Move_to_Dn.Q OR fbTRIG_Move_to_Unload.Q THEN
			xMove_TO_TarFlag_M:= FALSE;		
			xMove_TO_TarFlag_G:= FALSE;		
		END_IF
		
		IF xPreStop_Prf_M<>i_pstStTrapAxisParam_Gantray^.xAxisPrfStop_M THEN
			IF i_pstStTrapAxisParam_Gantray^.xAxisPrfStop_M THEN
				xMove_TO_TarFlag_M:= TRUE;
			ELSE
				xMove_TO_TarFlag_M:= FALSE;				
			END_IF
			xPreStop_Prf_M:= i_pstStTrapAxisParam_Gantray^.xAxisPrfStop_M;			
		END_IF
		IF xPreStop_Prf_G<>i_pstStTrapAxisParam_Gantray^.xAxisPrfStop_G THEN
			IF i_pstStTrapAxisParam_Gantray^.xAxisPrfStop_G THEN
				xMove_TO_TarFlag_G:= TRUE;
			ELSE
				xMove_TO_TarFlag_G:= FALSE;
			END_IF
			xPreStop_Prf_G:= i_pstStTrapAxisParam_Gantray^.xAxisPrfStop_G;		
		END_IF		
	
		IF (i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing OR 
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing OR
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing) THEN
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn:= FALSE;
			i_xStopOrEstop_Valid:= FALSE;
		END_IF		
		
		IF (xMove_TO_TarFlag_M AND xMove_TO_TarFlag_G) AND
			(i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing OR 
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing OR
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing) THEN
			i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing:= FALSE;	
// 			xMove_TO_TarFlag_G:= FALSE;
// 			xMove_TO_TarFlag_M:= FALSE;
		END_IF
//bai.zy | 2024.01.15.101452 | 标定完成标志
		IF i_pstStTrapAxisParam_Gantray^.xConfirmDnPosDne_Pressure_M AND i_pstStTrapAxisParam_Gantray^.xConfirmDnPosDne_Pressure_G THEN			
		
			xPosIn:= FALSE;
			xPosOut:= FALSE;
			IF i_pstStTrapAxisParam_Gantray^.byCurPos_M=0 AND i_pstStTrapAxisParam_Gantray^.byCurPos_G=0 THEN
				IF i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp THEN
					xPosIn:= TRUE;
					xPosOut:= FALSE;
				END_IF
			ELSIF i_pstStTrapAxisParam_Gantray^.byCurPos_M=4 AND i_pstStTrapAxisParam_Gantray^.byCurPos_G=4 THEN
				IF i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload THEN
					xPosIn:= FALSE;
					xPosOut:= TRUE;					
				END_IF
				IF i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn THEN
					xPosIn:= TRUE;
					xPosOut:= FALSE;
					i_pstStTrapAxisParam_Gantray^.xCanReFlashPos := TRUE;	
					i_pstStTrapAxisParam_Gantray^.xRefleshPos := FALSE;				
				END_IF	
			ELSIF i_pstStTrapAxisParam_Gantray^.byCurPos_M=5 AND i_pstStTrapAxisParam_Gantray^.byCurPos_G=5 THEN
				IF i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp THEN
					xPosIn:= TRUE;
					xPosOut:= FALSE;			
				END_IF	
				IF i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload THEN
					xPosIn:= FALSE;
					xPosOut:= TRUE;			
				END_IF	
			ELSIF (i_pstStTrapAxisParam_Gantray^.byCurPos_M=1 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_M=2 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_M=3) AND
				 (i_pstStTrapAxisParam_Gantray^.byCurPos_G=1 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_G=2 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_G=3) THEN
				IF i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp OR i_xStopOrEstop_Valid OR i_ReqResetEstop THEN//liya 
					xPosIn:= FALSE;
					xPosOut:= TRUE;	
					i_pstStTrapAxisParam_Gantray^.xRefleshPos := TRUE;			
				END_IF
				IF i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn THEN//heya 
					xPosIn:= TRUE;
					xPosOut:= FALSE;			
				END_IF	
			END_IF
		ELSE
			xPosIn:= FALSE;
			xPosOut:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xCanReFlashPos := FALSE;
			i_pstStTrapAxisParam_Gantray^.xRefleshPos := FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn := FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp := FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload := FALSE;
		END_IF
		//处理界面按钮
			
		//IF i_xStep_Fast THEN
//2026.04.09.225246这里不能再算步进量了，会有误动作的2026.04.09.225309		
(*			rStep_Use:= i_rVel_Fast*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(i_uiNum)/
					i_rScrewPitch/
					UINT_TO_REAL(i_uiDen);//为了方便这里直接换算成脉冲吧
*)			o_rVel:= i_rVel_Fast*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(i_uiNum)/
					i_rScrewPitch/
					UINT_TO_REAL(i_uiDen)/1000.0;
					

			
// 		ELSE
// //				rStep_Use:= i_rStep_Little/5.0*2.0*GC_LRMOTORPPR_TRAP;
// //				o_arVel[iN]:= i_rVel_Little/5.0 *2.0*GC_LRMOTORPPR_TRAP/1000.0;
// 			rStep_Use:= i_rStep_Little*GC_LRMOTORPPR_TRAP*
// 					UINT_TO_REAL(i_uiNum)/
// 					i_rScrewPitch/
// 					UINT_TO_REAL(i_uiDen);//为了方便这里直接换算成脉冲吧
// 			o_rVel:= i_rVel_Little*GC_LRMOTORPPR_TRAP*
// 					UINT_TO_REAL(i_uiNum)/
// 					i_rScrewPitch/
// 					UINT_TO_REAL(i_uiDen)/1000.0;
//		END_IF
//bai.zy | 2024.01.05.104330 | 手轮与界面操作冲突
(*2026.04.09.235930
		IF NOT (i_pstStTrapAxisParam_Gantray^.xMoveRev_Long OR 
			i_pstStTrapAxisParam_Gantray^.xMoveFor_Long OR
			i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing OR
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing OR
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing) THEN
*)
			rStep_Use:= i_rStep_HMI_Use*GC_LRMOTORPPR_TRAP*i_rProportion*
				UINT_TO_REAL(i_uiNum)/
				i_rScrewPitch/
				UINT_TO_REAL(i_uiDen);	
			o_rVel:= i_rVel_Fast*GC_LRMOTORPPR_TRAP*
				UINT_TO_REAL(i_uiNum)/
				i_rScrewPitch/
				UINT_TO_REAL(i_uiDen)/1000.0;
			

			//2026.01.16.153921
(*
		ELSE
			;
		END_IF
*)			
		IF i_pstStTrapAxisParam_Gantray^.xMoveFor_M	THEN
			i_plrTargetPos_M^:= i_plrTargetPos_M^+(-1*rStep_Use);
		ELSIF i_pstStTrapAxisParam_Gantray^.xMoveRev_M THEN
			i_plrTargetPos_M^:= i_plrTargetPos_M^+(1*rStep_Use);
		END_IF	
		IF i_pstStTrapAxisParam_Gantray^.xMoveFor_G	THEN
			i_plrTargetPos_G^:= i_plrTargetPos_G^+(-1*rStep_Use);
		ELSIF i_pstStTrapAxisParam_Gantray^.xMoveRev_G THEN
			i_plrTargetPos_G^:= i_plrTargetPos_G^+(1*rStep_Use);
		END_IF		


		rTemp:= (g_rTest_StepLength/1000.0)*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(i_uiNum)/
					i_rScrewPitch/
					UINT_TO_REAL(i_uiDen);//为了方便这里直接换算成脉冲吧
		
		IF i_pstStTrapAxisParam_Gantray^.xMoveFor_Test_For_Rev_For THEN
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(-1*rTemp);
		ELSIF i_pstStTrapAxisParam_Gantray^.xMoveFor_Test_For_Rev_Rev THEN
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(1*rTemp);
		END_IF	
//2024.12.03.152342 | 增加调试阶段测试压力电机反复来回运行 
		IF i_pstStTrapAxisParam_Gantray^.xPressDebugMode_MoveFor THEN
			rTemp := ((i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_M - i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M)+
						(i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_G - i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G))/2;
			
			o_rVel:= i_rVel_Fast*GC_LRMOTORPPR_TRAP*
				UINT_TO_REAL(i_uiNum)/
				i_rScrewPitch/
				UINT_TO_REAL(i_uiDen)/1000.0;
				
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(1*rTemp);
		ELSIF i_pstStTrapAxisParam_Gantray^.xPressDebugMode_MoveRev THEN
			rTemp := ((i_pstStTrapAxisParam_Gantray^.lrEncPosLimit_M_Max - i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M)+
						(i_pstStTrapAxisParam_Gantray^.lrEncPosLimit_G_Max - i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G))/2;
			o_rVel:= i_rVel_Fast*GC_LRMOTORPPR_TRAP*
				UINT_TO_REAL(i_uiNum)/
				i_rScrewPitch/
				UINT_TO_REAL(i_uiDen)/1000.0;
				
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(1*rTemp);
		END_IF
		
		//2023.11.29.182021在这里处理一下避让吧
		IF i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Avoidance AND
			(NOT i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Avoidance_ing) AND
			 (i_pstStTrapAxisParam_Gantray^.byCurPos_M=1 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_M=2 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_M=3) AND
			 (i_pstStTrapAxisParam_Gantray^.byCurPos_G=1 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_G=2 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_G=3) THEN
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Avoidance_ing:= TRUE;
			i_plrTargetPos_All^:= i_plrTargetPos_All^+i_pstStTrapAxisParam_Gantray^.rMoveUp_mm_Avoidance*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(i_uiNum)/
					i_rScrewPitch/
					UINT_TO_REAL(i_uiDen);			
		END_IF
		IF i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Avoidance_ing AND 
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Avoidance THEN
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Avoidance_ing:= FALSE;
			i_plrTargetPos_All^:= i_plrTargetPos_All^-i_pstStTrapAxisParam_Gantray^.rMoveUp_mm_Avoidance*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(i_uiNum)/
					i_rScrewPitch/
					UINT_TO_REAL(i_uiDen);				
		END_IF
		IF i_pstStTrapAxisParam_Gantray^.xRollerMoveFor THEN
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(-1*rStep_Use);
		ELSIF i_pstStTrapAxisParam_Gantray^.xRollerMoveRev THEN
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(1*rStep_Use);
		END_IF
		IF i_pstStTrapAxisParam_Gantray^.xMoveFor_Long THEN
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(-1*rStep_Use)*gc_TENSION_TSK_CYCLE_TIME*2/1000.0;	
			iClearVelSetCurPosCount_For:= 0;
			//xClearVelSetCurPos_For:= FALSE;
			xClearVelSetCurPos_For:= TRUE;
		ELSE
			//xClearVelSetCurPos_For:= TRUE;
			IF xClearVelSetCurPos_For THEN
				o_rVel:= 0;
				iClearVelSetCurPosCount_For:= iClearVelSetCurPosCount_For+1;
				IF iClearVelSetCurPosCount_For>=3 THEN
					xClearVelSetCurPos_For:= FALSE;
					iClearVelSetCurPosCount_For:= 0;
					IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN(*bai.zy | 2024.07.04.153851 | 加0.5丝补偿，电机停止效果更好*)
						i_plrTargetPos_All^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf+0.05*lrTemp_100um_pos;
					ELSE
						i_plrTargetPos_All^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf-0.05*lrTemp_100um_pos;
					END_IF
// 				ELSE
// 					IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
// 						i_plrTargetPos_All^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
// 					ELSE
// 						i_plrTargetPos_All^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
// 					END_IF
				END_IF
			END_IF			
		END_IF
		IF i_pstStTrapAxisParam_Gantray^.xMoveRev_Long THEN
			i_plrTargetPos_All^:= i_plrTargetPos_All^+(1*rStep_Use)*gc_TENSION_TSK_CYCLE_TIME*2/1000.0;	
			iClearVelSetCurPosCount_Rev:= 0;
			//xClearVelSetCurPos_Rev:= FALSE;
			xClearVelSetCurPos_Rev:= TRUE;
		ELSE
			//xClearVelSetCurPos_Rev:= TRUE;
			IF xClearVelSetCurPos_Rev THEN
				o_rVel:= 0;
				iClearVelSetCurPosCount_Rev:= iClearVelSetCurPosCount_Rev+1;
				IF iClearVelSetCurPosCount_Rev>=3 THEN
					xClearVelSetCurPos_Rev:= FALSE;
					iClearVelSetCurPosCount_Rev:= 0;
					IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN(*bai.zy | 2024.07.04.153851 | 加0.5丝补偿，电机停止效果更好*)
						i_plrTargetPos_All^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf+0.05*lrTemp_100um_pos;
					ELSE														(**)
						i_plrTargetPos_All^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf-0.05*lrTemp_100um_pos;
					END_IF
// 				ELSE
// 					IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
// 						i_plrTargetPos_All^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
// 					ELSE
// 						i_plrTargetPos_All^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
// 					END_IF
				END_IF
			END_IF			
		END_IF
		IF ( i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload OR 
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp OR 
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn OR i_xStopOrEstop_Valid OR i_ReqResetEstop) THEN//前往换版位
			o_rVel:= i_rVel_Fast*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(i_uiNum)/
					i_rScrewPitch/
					UINT_TO_REAL(i_uiDen)/1000.0;	

// 			g_rtest:=i_rVel_Fast;
// 			g_uitest1:=i_uiNum;
// 			g_uitest2:=i_uiDen;
// 			g_rtest1:=i_rScrewPitch;
//2026.04.13.03357|在一个不规范的位置，操作了离合压或者换版，没有方向信号，清除标志，不进入运行状态置位
			IF (NOT xPosIn) AND (NOT xPosOut) THEN
				i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload:= FALSE;
				i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp:= FALSE;
				i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn:= FALSE;
				i_xStopOrEstop_Valid:= FALSE;
			END_IF
//2026.04.13.03525			
			IF i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload  THEN
				i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing:= TRUE;
				lrTarPos_M_Temp:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_M;
				lrTarPos_G_Temp:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_G;
				
			ELSIF (i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp OR i_xStopOrEstop_Valid OR i_ReqResetEstop) AND(NOT i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing) THEN
				IF (i_pstStTrapAxisParam_Gantray^.byCurPos_M=0 OR
					i_pstStTrapAxisParam_Gantray^.byCurPos_M=1 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_M=2 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_M=3) AND
					(i_pstStTrapAxisParam_Gantray^.byCurPos_G=0 OR
					i_pstStTrapAxisParam_Gantray^.byCurPos_G=1 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_G=2 OR 
					i_pstStTrapAxisParam_Gantray^.byCurPos_G=3) THEN
						i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing:= TRUE;
						i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_end:= FALSE;
							lrTarPos_M_Temp:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M;
							lrTarPos_G_Temp:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G;			
				END_IF





			ELSIF i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn AND (NOT i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing) THEN
				i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing:= TRUE;

				lrTarPos_M_Temp:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M;
				lrTarPos_G_Temp:= i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G;
								
			END_IF		
			rTemp_MovePos_M:= ABS(lrTarPos_M_Temp-
				i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M);	
			rTemp_MovePos_G:= ABS(lrTarPos_G_Temp-
				i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G);
				
		//2026.03.28.16390	test	
// 			IF i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn OR i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp THEN
// 				g_lrtest1:=lrTarPos_M_Temp;
// 				g_lrtest2:=i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M;
// 				g_lrtest3:=lrTarPos_G_Temp;
// 				g_lrtest4:=i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G;
// 			END_IF
			
			IF xPosOut THEN
				IF rTemp_MovePos_M=rTemp_MovePos_G THEN
					i_plrTargetPos_All^:= i_plrTargetPos_All^+rTemp_MovePos_M;
				ELSIF rTemp_MovePos_M>rTemp_MovePos_G THEN
					i_plrTargetPos_All^:= i_plrTargetPos_All^+(rTemp_MovePos_G);
					i_plrTargetPos_M^:= i_plrTargetPos_M^+(rTemp_MovePos_M-rTemp_MovePos_G);
				ELSIF rTemp_MovePos_M<rTemp_MovePos_G THEN
					i_plrTargetPos_All^:= i_plrTargetPos_All^+(rTemp_MovePos_M);
					i_plrTargetPos_G^:= i_plrTargetPos_G^+(rTemp_MovePos_G-rTemp_MovePos_M);					
				END_IF							
			ELSIF xPosIn THEN
				IF rTemp_MovePos_M=rTemp_MovePos_G THEN
					i_plrTargetPos_All^:= i_plrTargetPos_All^-rTemp_MovePos_M;
				ELSIF rTemp_MovePos_M>rTemp_MovePos_G THEN
					i_plrTargetPos_All^:= i_plrTargetPos_All^-(rTemp_MovePos_G);
					i_plrTargetPos_M^:= i_plrTargetPos_M^-(rTemp_MovePos_M-rTemp_MovePos_G);
				ELSIF rTemp_MovePos_M<rTemp_MovePos_G THEN
					i_plrTargetPos_All^:= i_plrTargetPos_All^-(rTemp_MovePos_M);
					i_plrTargetPos_G^:= i_plrTargetPos_G^-(rTemp_MovePos_G-rTemp_MovePos_M);					
				END_IF	
			END_IF	
		END_IF	
		
		IF i_pstStTrapAxisParam_Gantray^.xFlag_MoveEn THEN
			IF i_pstStTrapAxisParam_Gantray^.lrPos_HandWheelChange<>0 THEN
				o_rVel:= ABS(i_pstStTrapAxisParam_Gantray^.lrPos_HandWheelChange*0.005*GC_LRMOTORPPR_TRAP*
					UINT_TO_REAL(i_uiNum)/
					i_rScrewPitch/
					UINT_TO_REAL(i_uiDen)/gc_TENSION_TSK_CYCLE_TIME);//*1.05;
				
					
				IF i_pstStTrapAxisParam_Gantray^.bySts_HandWheel=1 THEN
					i_plrTargetPos_All^:= i_plrTargetPos_All^-i_pstStTrapAxisParam_Gantray^.lrPos_HandWheelChange*0.005*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(i_uiNum)/
						i_rScrewPitch/
						UINT_TO_REAL(i_uiDen);	
						
				ELSIF i_pstStTrapAxisParam_Gantray^.bySts_HandWheel=2 THEN		
					i_plrTargetPos_M^:= i_plrTargetPos_M^-i_pstStTrapAxisParam_Gantray^.lrPos_HandWheelChange*0.005*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(i_uiNum)/
						i_rScrewPitch/
						UINT_TO_REAL(i_uiDen);	

				ELSIF i_pstStTrapAxisParam_Gantray^.bySts_HandWheel=3 THEN		
					i_plrTargetPos_G^:= i_plrTargetPos_G^-i_pstStTrapAxisParam_Gantray^.lrPos_HandWheelChange*0.005*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(i_uiNum)/
						i_rScrewPitch/
						UINT_TO_REAL(i_uiDen);	

				END_IF
			END_IF
		END_IF
(*
		IF i_pstStTrapAxisParam_Gantray^.xPressFlag_Stop  OR (i_pstStTrapAxisParam_Gantray^.xManuNeedStop AND i_pstStTrapAxisParam_Gantray^.xManuForPanel) THEN
			o_rVel:= 0;
			o_lrTargetPos_All:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
			o_lrTargetPos_M:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_M;
			o_lrTargetPos_G:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_G;
			IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
				i_plrTargetPos_All^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
				i_plrTargetPos_M^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_M;				
			ELSE
				i_plrTargetPos_All^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
				i_plrTargetPos_M^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_M;					
			END_IF
			IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_G THEN
				i_plrTargetPos_G^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_G;				
			ELSE
				i_plrTargetPos_G^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_G;					
			END_IF
		ELSE
			;
		END_IF
*)		
			
		//2026.05.10.003923 | + | 增加限位保护,备份原来的位置
		//2026.05.10.003923 | + | 增加限位保护

		IF i_pstStTrapAxisParam_Gantray^.xPressFlag_Stop  OR (i_pstStTrapAxisParam_Gantray^.xManuNeedStop AND i_pstStTrapAxisParam_Gantray^.xManuForPanel) THEN
			rErr_TarPos_All := i_plrTargetPos_All^-rLast_TarPos_All;
			rErr_TarPos_M := i_plrTargetPos_M^ - rLast_TarPos_M;
			rErr_TarPos_G := i_plrTargetPos_G^ - rLast_TarPos_G;
			rErr_Pos := i_plrTargetPos_M^ - i_plrTargetPos_G^;
			
			IF i_pstStTrapAxisParam_Gantray^.lrParallelError_MM > i_rMaxErr THEN
				IF rErr_TarPos_M < 0 THEN
					o_rVel:= 0;
					i_plrTargetPos_All^:= rLast_TarPos_All;
					i_plrTargetPos_M^:= rLast_TarPos_M;
					i_plrTargetPos_G^:= rLast_TarPos_G;
				END_IF
				IF rErr_TarPos_G > 0 THEN
					o_rVel:= 0;
					i_plrTargetPos_All^:= rLast_TarPos_All;
					i_plrTargetPos_M^:= rLast_TarPos_M;
					i_plrTargetPos_G^:= rLast_TarPos_G;
				END_IF
			ELSIF i_pstStTrapAxisParam_Gantray^.lrParallelError_MM <-1*i_rMaxErr THEN
				IF rErr_TarPos_M > 0 THEN
					o_rVel:= 0;
					i_plrTargetPos_All^:= rLast_TarPos_All;
					i_plrTargetPos_M^:= rLast_TarPos_M;
					i_plrTargetPos_G^:= rLast_TarPos_G;
				END_IF
				IF rErr_TarPos_G < 0 THEN
					o_rVel:= 0;
					i_plrTargetPos_All^:= rLast_TarPos_All;
					i_plrTargetPos_M^:= rLast_TarPos_M;
					i_plrTargetPos_G^:= rLast_TarPos_G;
				END_IF















			END_IF
		ELSE
			rLast_TarPos_All := i_plrTargetPos_All^;
			rLast_TarPos_M := i_plrTargetPos_M^;
			rLast_TarPos_G := i_plrTargetPos_G^;
			rLast_ErrPos := rLast_TarPos_M - rLast_TarPos_G;
// 			IF ABS(rErr_Pos) > ABS(rLast_ErrPos) THEN
// 				o_rVel:= 0;
// 				o_lrTargetPos_All:= rLast_TarPos_All;
// 				o_lrTargetPos_M:= rLast_TarPos_M;
// 				o_lrTargetPos_G:= rLast_TarPos_G;
// 			ELSE
// 				;
// 			END_IF

		END_IF



		o_lrTargetPos_All:= i_plrTargetPos_All^;
		o_lrTargetPos_M:= i_plrTargetPos_M^;
		o_lrTargetPos_G:= i_plrTargetPos_G^;
		IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
			o_lrTargetPos_All:= -i_plrTargetPos_All^;
			o_lrTargetPos_M:= -i_plrTargetPos_M^;		
		END_IF
		IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_G THEN
			o_lrTargetPos_G:= -i_plrTargetPos_G^;	
		END_IF	

		//2026.05.10.003923 | + | 增加限位保护
// 		IF i_pstStTrapAxisParam_Gantray^.xPressFlag_Stop  OR (i_pstStTrapAxisParam_Gantray^.xManuNeedStop AND i_pstStTrapAxisParam_Gantray^.xManuForPanel) THEN
// 			rErr_TarPos_All := o_lrTargetPos_All-rLast_TarPos_All;
// 			rErr_TarPos_M := o_lrTargetPos_M - rLast_TarPos_M;
// 			rErr_TarPos_G := o_lrTargetPos_G - rLast_TarPos_G;
// 			rErr_Pos := o_lrTargetPos_M - o_lrTargetPos_G;
// 			IF ABS(rErr_Pos) > ABS(rLast_ErrPos) THEN
// 				o_rVel:= 0;
// 				o_lrTargetPos_All:= rLast_TarPos_All;
// 				o_lrTargetPos_M:= rLast_TarPos_M;
// 				o_lrTargetPos_G:= rLast_TarPos_G;
// 			ELSE
// 				;
// 			END_IF
// 		END_IF

		//处理标定模式下
		IF i_pstStTrapAxisParam_Gantray^.xSts_Calid_Pos THEN			
			fbTRIG_Confirm_load_unload(CLK:=i_pstStTrapAxisParam_Gantray^.xConfirm_Load_Unload_Press);
			fbTRIG_Confirm_PressUp(CLK:=i_pstStTrapAxisParam_Gantray^.xConfirm_Up_Press);
			fbTRIG_Confirm_PressDn(CLK:=i_pstStTrapAxisParam_Gantray^.xConfirm_Dn_Press);
			i_pstStTrapAxisParam_Gantray^.xConfirm_Load_Unload_Press:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xConfirm_Up_Press:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xConfirm_Dn_Press:= FALSE;
			IF fbTRIG_Confirm_PressDn.Q THEN
				i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm:= 
					i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M;
				i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm:= 
					i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G;	
				lrTemp:= i_rUp_Dn_Length*GC_LRMOTORPPR_TRAP*
						UINT_TO_REAL(i_uiNum)/
						i_rScrewPitch/
						UINT_TO_REAL(i_uiDen);			
				g_lrtest:=lrTemp;
				IF 	i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
					i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M_Confirm:=
						i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm-lrTemp;
				ELSE
					i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M_Confirm:=
						i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm+lrTemp;
				END_IF	
				IF 	i_pstStTrapAxisParam_Gantray^.xRev_Motor_G THEN
					i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G_Confirm:=
						i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm-lrTemp;
				ELSE
					i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G_Confirm:=
						i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm+lrTemp;
				END_IF	
				//在这里记录一下标定时候的周长，秦华记录带长，只对于张带辊有效
				i_prGirth_Confirm^:= i_rGirth_Roller;
				i_pstStTrapAxisParam_Gantray^.xConfirmDnPosDne_Pressure_M := TRUE;//bai.zy | 2024.01.15.101452 | 标定完成标志
				i_pstStTrapAxisParam_Gantray^.xConfirmDnPosDne_Pressure_G := TRUE;//bai.zy | 2024.01.15.101452 | 标定完成标志
			END_IF
			IF fbTRIG_Confirm_load_unload.Q THEN
				i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_M_Confirm:= 
					i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M;
				i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_G_Confirm:= 
					i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G;
				i_pstStTrapAxisParam_Gantray^.xConfirmload_unloadPosDne_Pressure_M := TRUE;//bai.zy | 2024.01.15.101452 | 标定完成标志
				i_pstStTrapAxisParam_Gantray^.xConfirmload_unloadPosDne_Pressure_G := TRUE;//bai.zy | 2024.01.15.101452 | 标定完成标志
			END_IF
		ELSE//运行模式下可以矫正位置
			IF i_xFlag_Print AND
				(i_pstStTrapAxisParam_Gantray^.byCurPos_M=1 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_M=2 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_M=3) AND
				(i_pstStTrapAxisParam_Gantray^.byCurPos_G=1 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_G=2 OR 
				i_pstStTrapAxisParam_Gantray^.byCurPos_G=3) (*AND
				i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_end*) THEN
				IF i_pstStTrapAxisParam_Gantray^.xConfirm_Adjust_PressDn OR //手轮按键矫正
						g_xConfirm_Adjust_PressDn THEN
					IF 	i_pstStTrapAxisParam_Gantray^.iStationId_M < 120 AND
						i_pstStTrapAxisParam_Gantray^.iStationId_G < 120 THEN
							
						lrTemp_Len_Load_Unload_Pos:= ABS(i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M-
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_M);					

						i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm:= 
							i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M;		
						i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm:= 
							i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G;	
	
						lrTemp:= i_rUp_Dn_Length*GC_LRMOTORPPR_TRAP*
							UINT_TO_REAL(i_uiNum)/
							i_rScrewPitch/
							UINT_TO_REAL(i_uiDen);		
						IF 	i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm-lrTemp;
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_M_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm-lrTemp_Len_Load_Unload_Pos;
								
						ELSE
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_M_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm+lrTemp;
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_M_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_M_Confirm+lrTemp_Len_Load_Unload_Pos;
	
						END_IF	
						IF 	i_pstStTrapAxisParam_Gantray^.xRev_Motor_G THEN
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm-lrTemp;
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_G_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm-lrTemp_Len_Load_Unload_Pos;
	
						ELSE
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Up_Press_G_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm+lrTemp;
							i_pstStTrapAxisParam_Gantray^.lrposConfirm_Load_Unload_Press_G_Confirm:=
								i_pstStTrapAxisParam_Gantray^.lrposConfirm_Dn_Press_G_Confirm+lrTemp_Len_Load_Unload_Pos;
						END_IF
						
						o_lrTemp_Len_Up_Pos := lrTemp;
						o_lrTemp_Len_Load_Unload_Pos := lrTemp_Len_Load_Unload_Pos;
						//在这里更新一下矫正时候的周长
						i_prGirth_Confirm^:= i_rGirth_Roller;
						i_pxFinishConfirm_Adjust_PressDn^ := TRUE;	
					END_IF
				END_IF
			ELSE
				;
			END_IF
		END_IF
//2023.11.21.183755新增急停保护
		IF NOT i_pstStTrapAxisParam_Gantray^.xFlag_MoveEn OR (i_xFlag_Estop(* AND (NOT i_xMove_to_Up_Estop)*)) THEN//下私服需要重新处理一下输出2023.11.3.111425
			o_rVel:= 0;
			o_lrTargetPos_All:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
			o_lrTargetPos_M:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_M;
			o_lrTargetPos_G:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_G;
			IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M THEN
				i_plrTargetPos_All^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
				i_plrTargetPos_M^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_M;				
			ELSE
				i_plrTargetPos_All^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf;
				i_plrTargetPos_M^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_M;					
			END_IF
			IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_G THEN
				i_plrTargetPos_G^:= -i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_G;				
			ELSE
				i_plrTargetPos_G^:= i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Prf_G;					
			END_IF

			//2026.04.29.140841 | + | 急停或者下伺服状态把标志全清了
			i_pstStTrapAxisParam_Gantray^.xCanReFlashPos := FALSE;
			i_pstStTrapAxisParam_Gantray^.xRefleshPos := FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressDn := FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_PressUp := FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload := FALSE;

			//2026.05.08.130137 | + | 急停或者没有使能清标志
			i_pstStTrapAxisParam_Gantray^.xMove_To_Load_Unload_Press_ing:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Up_Press_ing:= FALSE;
			i_pstStTrapAxisParam_Gantray^.xMove_To_Dn_Press_ing:= FALSE;			
		END_IF
		
		//记录平行位置
		fbTRIG_Confirm_ParallelPos(CLK:=i_pstStTrapAxisParam_Gantray^.xConfirmParallelPos);			
		IF fbTRIG_Confirm_ParallelPos.Q THEN
			i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_M :=  i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M;
			i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_G :=  i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G;
		END_IF
		
		//计算平行误差
		IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_M AND i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_M<>0 THEN
			lrEncParallelError_M := i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M - 1(*i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_M*);

		ELSE
			lrEncParallelError_M := 1(*i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_M*) - i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M;	

		END_IF
		
		IF i_pstStTrapAxisParam_Gantray^.xRev_Motor_G AND i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_G <> 0 THEN
			lrEncParallelError_G := i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G - 1(*i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_G*);

		ELSE
			lrEncParallelError_G := 1(*i_pstStTrapAxisParam_Gantray^.lrEncPosParallel_G*) - i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G;	

		END_IF

		IF i_rProportion <> 0 THEN
// 			i_pstStTrapAxisParam_Gantray^.lrParallelError_MM :=ABS((lrEncParallelError_M-lrEncParallelError_G)*
// 					i_rScrewPitch*UINT_TO_LREAL(i_uiDen)/GC_LRMOTORPPR_TRAP/UINT_TO_REAL(i_uiNum))/i_rProportion;
			i_pstStTrapAxisParam_Gantray^.lrParallelError_MM :=(lrEncParallelError_M-lrEncParallelError_G)*
				i_rScrewPitch*UINT_TO_LREAL(i_uiDen)/GC_LRMOTORPPR_TRAP/UINT_TO_REAL(i_uiNum)/i_rProportion;	


		END_IF			


		IF i_xFlag_Print AND
			(i_pstStTrapAxisParam_Gantray^.byCurPos_M=1 OR 
			i_pstStTrapAxisParam_Gantray^.byCurPos_M=2 OR 
			i_pstStTrapAxisParam_Gantray^.byCurPos_M=3) AND
			(i_pstStTrapAxisParam_Gantray^.byCurPos_G=1 OR 
			i_pstStTrapAxisParam_Gantray^.byCurPos_G=2 OR 
			i_pstStTrapAxisParam_Gantray^.byCurPos_G=3) AND
			i_pstStTrapAxisParam_Gantray^.xCanReFlashPos AND
			i_pstStTrapAxisParam_Gantray^.xRefleshPos THEN
				
			i_pstStTrapAxisParam_Gantray^.lrPrintPosOffsetDn_M:= i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_M;
			i_pstStTrapAxisParam_Gantray^.lrPrintPosOffsetDn_G:= i_pstStTrapAxisParam_Gantray^.lrCurPos_mm_G;
			i_pstStTrapAxisParam_Gantray^.xCanReFlashPos := FALSE;
			i_pstStTrapAxisParam_Gantray^.xRefleshPos := FALSE;
		END_IF	
		
		//记录最大限位
		fbTRIG_xCalidPressLimit_Max(CLK:=i_pstStTrapAxisParam_Gantray^.xCalidPressLimit_Max);			
		IF fbTRIG_xCalidPressLimit_Max.Q THEN
			i_pstStTrapAxisParam_Gantray^.lrEncPosLimit_M_Max :=  i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_M;
			i_pstStTrapAxisParam_Gantray^.lrEncPosLimit_G_Max :=  i_pstStTrapAxisParam_Gantray^.lrPos_CurPos_Enc_G;
		END_IF
	
		//在这里处理一下按钮功能；
		
	END_IF
END_IF


