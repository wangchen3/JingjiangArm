(*@CES
Name=ACT_Gear
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=d82493d6-93a4-4699-ba5c-ca529dca8fbf
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
iCountNum_Gear := 0;
//开始添加数据
FOR iN := 1 TO i_iGrpGearMotion_Num BY 1 DO
	KS_GetAxisIdForMotByStation_V2(
			i_iStationId:= i_aiGrpGearMotion_StdList[iN],
			i_piAxisId:= ADR(iAxisId), 
			i_piTypeId:= ADR(iTypeId), 
			i_piUnitId:= ADR(iUnitId), 
			i_piCoreId:= ADR(iCoreId), 
			i_piGroupId:= ADR(iGroupId), 
			i_piAdjAxisId:= ADR(iAdjAxisId), 
			i_pstStSysStationInf:= i_pstStSysStationInf);
			
	iAxisId_InAll := (iCoreId-1)* gc_ResCount_Profile +iAxisId;
	
	i_pastStAxis_Sts_Display_Gear^[iN].byStationId			 := INT_TO_BYTE(i_aiGrpGearMotion_StdList[iN]);
	i_pastStAxis_Sts_Display_Gear^[iN].byTypeId			 	 := INT_TO_BYTE(iTypeId);
	i_pastStAxis_Sts_Display_Gear^[iN].byAxisId				 := INT_TO_BYTE(iAxisId_InAll);
	                        
	i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts			 := i_pastStGetMotionSts^[iAxisId_InAll].dwMotionSts;   
	i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf			 := i_pastStGetMotionSts^[iAxisId_InAll].lrVel_Enc;   
	i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Enc			 := i_pastStGetMotionSts^[iAxisId_InAll].lrPos_Enc;
	i_pastStAxis_Sts_Display_Gear^[iN].rTorque				 := i_pastStGetMotionSts^[iAxisId_InAll].lrVel_Prf; 
	i_pastStAxis_Sts_Display_Gear^[iN].rTorqueCoeff		     := g_arTqCOeff[iAxisId_InAll];
	i_pastStAxis_Sts_Display_Gear^[iN].wSts_Driver	         := DWORD_TO_WORD(i_pastStGetMotionSts^[iAxisId_InAll].dwDriverSts);
	                        
	i_pastStAxis_Sts_Display_Gear^[iN].dwErr_Driver		     := 17;
	//2026.05.30.102138@Test 暂时保存位置
	//i_pastStAxis_Sts_Display_Gear^[iN].uiBrake_Cnt			 := 25;
	i_pastStAxis_Sts_Display_Gear^[iN].uiBrake_Cnt			 := REAL_TO_WORD(g_astStFiberMoveStepDriver[iN].rFiberMovePosCur*10);
	                        
	//i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1		         := 26; 
	i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2		         := 27; 
	i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3		         := 28; 
	i_pastStAxis_Sts_Display_Gear^[iN].dwRsv4		         := 29; 
	i_pastStAxis_Sts_Display_Gear^[iN].dwRsv5		         := 30; 
	
	
//根据不同的类型添加参数
//TYPE_MASTER_I,(*虚拟主轴/A系*)
// TYPE_MASTER_II,(*虚拟主轴/A系*)
// TYPE_CENTRAL_I,(*中心辊A*)
// TYPE_CENTRAL_II,(*中心辊B*)
// TYPE_UNWIND_A_I,(*放料A-A系*)
// TYPE_UNWIND_A_II,(*放料A-B系*)
// TYPE_UNWIND_B_I,(*放料B-A系*)
// TYPE_UNWIND_B_II,(*放料B-B系*)
// TYPE_REWIND_A_I,(*收料A-A系*)
// TYPE_REWIND_A_II,(*收料A-B系*)
// TYPE_REWIND_B_I,(*收料B-A系*)
// TYPE_REWIND_B_II,(*收料B-B系*)
// TYPE_INFEED_I,(*放牵A系*)
// TYPE_INFEED_II,(*放牵B系*)
// TYPE_OUTFEED_I,(*收牵A系*)
// TYPE_OUTFEED_II,(*收牵B系*)
// TYPE_UNIT_PRN,(*色组版辊*)
// TYPE_UNIT_ADJ,(*色组调整轴*)
// TYPE_UNIT_BOTTOM,(*色组底辊*)
// TYPE_UNIT_NET,(*色组网辊*)
// TYPE_UNIT_PRN_PRESS_MASTER,(*色组版辊龙门主轴*)
// TYPE_UNIT_PRN_PRESS_M,(*色组版辊龙门从轴M侧*)
// TYPE_UNIT_PRN_PRESS_G,(*色组版辊龙门从轴G侧*)
// TYPE_UNIT_NET_PRESS_MASTER,(*色组网辊龙门主轴*)
// TYPE_UNIT_NET_PRESS_M,(*色组网辊龙门从轴M侧*)
// TYPE_UNIT_NET_PRESS_G,(*色组网辊龙门从轴G侧*)
// TYPE_UNIT_STR_PRESS_MASTER,(*色组张带辊龙门主轴*)
// TYPE_UNIT_STR_PRESS_M,(*色组张带龙门从轴M侧*)
// TYPE_UNIT_STR_PRESS_G,(*色组张带龙门从轴G侧*)
// TYPE_UNIT_HORIZ,(*色组横向电机*)			

	CASE iTypeId OF 
	TYPE_UNWIND_A_I,TYPE_UNWIND_A_II:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := 25;
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := pstStGrpParam_Save^.rDiamCurAxis_Uw; 
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0												 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	TYPE_UNWIND_B_I,TYPE_UNWIND_B_II:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := 26;
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := pstStGrpParam_Save^.rDiamCurAxis_Uw;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0										 		 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	TYPE_REWIND_A_I,TYPE_REWIND_A_II:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := 27;
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := pstStGrpParam_Save^.rDiamCurAxis_Rw;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0										 		 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	TYPE_REWIND_B_I,TYPE_REWIND_B_II:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := 28;
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := pstStGrpParam_Save^.rDiamCurAxis_Rw;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0										 		 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	TYPE_INFEED_I,TYPE_INFEED_II:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := 31;
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := pstStGrpParam_UnSave^.rUsingGirth_If;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0										 		 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	TYPE_OUTFEED_I,TYPE_OUTFEED_II:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := 32;
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := pstStGrpParam_UnSave^.rUsingGirth_Of;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0											 	 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	TYPE_UNIT_PRN:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := INT_TO_BYTE(iUnitId);
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := i_pastStGetMotionSts^[iAdjAxisId].dwMotionSts;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := i_pastStGetMotionSts^[iAdjAxisId].lrPos_Prf;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Sts;
		//2026.5.14.110108 变量替换
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwEnc_Lock;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].dwTime_Lock;
		
		(*2026.5.8.190958lhy+*)


		(*2026.05.19.185413 别人把dwRsv1 dwRsv2用了 我换成4和5吧| liu.yt*)
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv4	:= REAL_TO_DWORD(PRG_TENSION.afbKS_FB_AdjOutCtl[i_iGrpId].rStepVel_Cur*100);//pstStAxisParam^.iAI0_Data_16D;
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv5	:= BOOL_TO_DWORD(PRG_TENSION.afbKS_FB_AdjOutCtl[i_iGrpId].xSetTrapParam);//pstStAxisParam^.iTemp_Data_16D;

		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0										 		 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);


		//2026.05.24.100954
		//i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3 				:= g_aiStepAdj[i_iGrpId,iN];
	TYPE_UNIT_NET:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := INT_TO_BYTE(iUnitId);
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_NetRoller;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			 := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0											 	 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	TYPE_UNIT_BOTTOM:
		i_pastStAxis_Sts_Display_Gear^[iN].byUnitID			 	 := INT_TO_BYTE(iUnitId);
		i_pastStAxis_Sts_Display_Gear^[iN].rGirth 				 := i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_BottomRoller;
		i_pastStAxis_Sts_Display_Gear^[iN].dwMotionSts_AddUp	 := i_pastStGetMotionSts^[iAdjAxisId].dwMotionSts;
		i_pastStAxis_Sts_Display_Gear^[iN].lrPos_Prf_AddUp		 := i_pastStGetMotionSts^[iAdjAxisId].lrPos_Prf;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Cnt		     := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Cnt;
		i_pastStAxis_Sts_Display_Gear^[iN].wVirtual_Sts		     := i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].wVirTual_Sts;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisEnc_Lock	 := 0;
		i_pastStAxis_Sts_Display_Gear^[iN].diCurAxisTime_Lock    := 0;
		
		iCountNum_Gear := iCountNum_Gear + 1;
		i_pastStAxis_Sts_Display_Gear^[iN].byAxisCtl			  := UINT_TO_BYTE(i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_Gear^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_Vel^[iCountNum_Gear].iMoveStep);  
		i_pastStAxis_Sts_Display_Gear^[iN].rVel_Axis	         := i_pastStMotorParam_Vel^[iCountNum_Gear].rAxisVel; 
		dwTemp.0											 	 := i_pastStMotorParam_Vel^[iCountNum_Gear].xMoveEn;
		i_pastStAxis_Sts_Display_Gear^[iN].dwFlag_AxisSts	     := dwTemp;          
			                    
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_A			 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_a;
		i_pastStAxis_Sts_Display_Gear^[iN].diRatio_B	         := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.ratio_b;
		i_pastStAxis_Sts_Display_Gear^[iN].dimodify_delta		 := i_pastStSetPrm_Gear^[iCountNum_Gear].prm.gearPrm.modify_delta;
		
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv1				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_a);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv2				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].ratio_b);
		i_pastStAxis_Sts_Display_Gear^[iN].dwRsv3				 := DINT_TO_DWORD(i_pastStMotorParam_Vel^[iCountNum_Gear].modify_delta);
	END_CASE   
END_FOR
SysMemcpy(i_pastStAxis_Sts_Save_Gear,i_pastStAxis_Sts_Display_Gear,SIZEOF(i_pastStAxis_Sts_Save_Gear^));
