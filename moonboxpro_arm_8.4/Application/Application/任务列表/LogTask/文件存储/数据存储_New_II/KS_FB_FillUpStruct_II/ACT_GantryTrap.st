(*@CES
Name=ACT_GantryTrap
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=3425416c-bc6e-457d-8ef9-62b599073539
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//开始添加数据
FOR iN := 1 TO i_iGrpGantryTrapMotion_Num BY 1 DO
	KS_GetAxisIdForMotByStation_V2(
			i_iStationId:= i_aiGrpGantryTrapMotion_StdList[iN],
			i_piAxisId:= ADR(iAxisId), 
			i_piTypeId:= ADR(iTypeId), 
			i_piUnitId:= ADR(iUnitId), 
			i_piCoreId:= ADR(iCoreId), 
			i_piGroupId:= ADR(iGroupId), 
			i_piAdjAxisId:= ADR(iAdjAxisId), 
			i_pstStSysStationInf:= i_pstStSysStationInf);
	KS_GetAxisIdForMotByStation_Gantry(
			i_iStationId:= i_aiGrpGantryTrapMotion_StdList[iN],
			i_piAxisId:= ADR(iAxisId_Gantry), 
			i_piTypeId:= ADR(iTypeId_Gantry), 
			i_piUnitId:= ADR(iUnitId_Gantry), 
			i_piCoreId:= ADR(iCoreId_Gantry), 
			i_piGroupId:= ADR(iGroupId_Gantry), 
			i_piAdjAxisId:= ADR(iAdjAxisId_Gantry), 
			i_pstStSysStationInf:= i_pstStSysStationInf,
			i_pstStSysGantryAxisInf := i_pstStSysGantryAxisInf);
			
	iAxisId_InAll := (iCoreId-1)* gc_ResCount_Profile +iAxisId;
	
	i_pastStAxis_Sts_Display_GantryTrap^[iN].byStationId			 := INT_TO_BYTE(i_aiGrpGantryTrapMotion_StdList[iN]);
	i_pastStAxis_Sts_Display_GantryTrap^[iN].byUnitID			 	 := INT_TO_BYTE(iUnitId);
	i_pastStAxis_Sts_Display_GantryTrap^[iN].byTypeId			 	 := INT_TO_BYTE(iTypeId);
	i_pastStAxis_Sts_Display_GantryTrap^[iN].byAxisId				 := INT_TO_BYTE(iAxisId_InAll);
	                        
	i_pastStAxis_Sts_Display_GantryTrap^[iN].dwMotionSts			 := i_pastStGetMotionSts^[iAxisId_InAll].dwMotionSts;   
	i_pastStAxis_Sts_Display_GantryTrap^[iN].lrPos_Prf			     := i_pastStGetMotionSts^[iAxisId_InAll].lrPos_Prf;   
	i_pastStAxis_Sts_Display_GantryTrap^[iN].lrPos_Enc			     := i_pastStGetMotionSts^[iAxisId_InAll].lrPos_Enc;
	i_pastStAxis_Sts_Display_GantryTrap^[iN].rTorque				 := i_pastStGetMotionSts^[iAxisId_InAll].lrVel_Prf; 
	i_pastStAxis_Sts_Display_GantryTrap^[iN].rTorqueCoeff		     := g_arTqCOeff[iAxisId_InAll];
	i_pastStAxis_Sts_Display_GantryTrap^[iN].wSts_Driver	         := DWORD_TO_WORD(i_pastStGetMotionSts^[iAxisId_InAll].dwDriverSts);
	                        
	i_pastStAxis_Sts_Display_GantryTrap^[iN].dwErr_Driver		     := 17;
	i_pastStAxis_Sts_Display_GantryTrap^[iN].uiBrake_Cnt			 := 25;
	                       
	i_pastStAxis_Sts_Display_GantryTrap^[iN].dwRsv1		         	:= 26; 
	i_pastStAxis_Sts_Display_GantryTrap^[iN].dwRsv2		         	:= 27; 
	i_pastStAxis_Sts_Display_GantryTrap^[iN].dwRsv3		         	:= 28; 
	i_pastStAxis_Sts_Display_GantryTrap^[iN].dwRsv4		         	:= 29; 
	i_pastStAxis_Sts_Display_GantryTrap^[iN].dwRsv5		         	:= 30; 
	
	
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
	TYPE_UNIT_PRN_PRESS_MASTER:
		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwMotionSts_AddUp	     := i_pastStGetMotionSts^[iAxisId_InAll+40].dwMotionSts;
		i_pastStAxis_Sts_Display_GantryTrap^[iN].lrPos_Prf_AddUp		 := i_pastStGetMotionSts^[iAxisId_InAll+40].lrPos_Prf;
		                       
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byAxisCtl			     := UINT_TO_BYTE(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].iMoveStep);  
		                       
		dwTemp.0											 			 := i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].xMoveEn;
		dwTemp.1											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
		dwTemp.2											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping;
		dwTemp.3											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_PressDn;
		dwTemp.4											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_PressUp;
		dwTemp.5											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Load_Unload;
		dwTemp.6											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Dn_Press_ing;
		dwTemp.7											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Up_Press_ing;
		dwTemp.8											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Load_Unload_Press_ing;
		

		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwFlag_AxisSts	     	 := dwTemp; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diTarget_pos	     	 := LINT_TO_DINT(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.target_pos); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].udiMax_vel	     	 	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.max_vel; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diMain_axis_shift	     := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.main_axis_shift; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diSecond_axis_shift	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.second_axis_shift; 

	TYPE_UNIT_PRN_PRESS_G:
		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwMotionSts_AddUp	     := 0;
		i_pastStAxis_Sts_Display_GantryTrap^[iN].lrPos_Prf_AddUp		 := 0;
		                       
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byAxisCtl			     := UINT_TO_BYTE(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].iMoveStep);  
		                       
		dwTemp.0											 			 := i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].xMoveEn;
		dwTemp.1											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
		dwTemp.2											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping;
		dwTemp.3											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_PressDn;
		dwTemp.4											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_PressUp;
		dwTemp.5											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Load_Unload;
		dwTemp.6											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Dn_Press_ing;
		dwTemp.7											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Up_Press_ing;
		dwTemp.8											 			 := i_pastStTrapAxisParam_Gantray^[1,iUnitId].xMove_To_Load_Unload_Press_ing;
		

		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwFlag_AxisSts	     	 := dwTemp; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diTarget_pos	     	 := LINT_TO_DINT(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.target_pos); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].udiMax_vel	     	 	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.max_vel; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diMain_axis_shift	     := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.main_axis_shift; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diSecond_axis_shift	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.second_axis_shift; 
	TYPE_UNIT_NET_PRESS_MASTER:
		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwMotionSts_AddUp	     := i_pastStGetMotionSts^[iAxisId_InAll+30].dwMotionSts;
		i_pastStAxis_Sts_Display_GantryTrap^[iN].lrPos_Prf_AddUp		 := i_pastStGetMotionSts^[iAxisId_InAll+30].lrPos_Prf;
		                       
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byAxisCtl			     := UINT_TO_BYTE(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].iMoveStep);  
		                       
		dwTemp.0											 			 := i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].xMoveEn;
		dwTemp.1											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
		dwTemp.2											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping;
		dwTemp.3											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_PressDn;
		dwTemp.4											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_PressUp;
		dwTemp.5											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Load_Unload;
		dwTemp.6											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Dn_Press_ing;
		dwTemp.7											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Up_Press_ing;
		dwTemp.8											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Load_Unload_Press_ing;

		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwFlag_AxisSts	     	 := dwTemp; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diTarget_pos	     	 := LINT_TO_DINT(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.target_pos); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].udiMax_vel	     	 	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.max_vel; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diMain_axis_shift	     := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.main_axis_shift; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diSecond_axis_shift	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.second_axis_shift; 
	TYPE_UNIT_NET_PRESS_G:
		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwMotionSts_AddUp	     := 0;
		i_pastStAxis_Sts_Display_GantryTrap^[iN].lrPos_Prf_AddUp		 := 0;
		                       
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byAxisCtl			     := UINT_TO_BYTE(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.axis_ctrl); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].byMotionStep			 := INT_TO_BYTE(i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].iMoveStep);  
		                       
		dwTemp.0											 			 := i_pastStMotorParam_GantryTrap^[iGroupId_Gantry].xMoveEn;
		dwTemp.1											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Estop;
		dwTemp.2											 			 := i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStoping;
		dwTemp.3											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_PressDn;
		dwTemp.4											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_PressUp;
		dwTemp.5											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Load_Unload;
		dwTemp.6											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Dn_Press_ing;
		dwTemp.7											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Up_Press_ing;
		dwTemp.8											 			 := i_pastStTrapAxisParam_Gantray^[2,iUnitId].xMove_To_Load_Unload_Press_ing;

		i_pastStAxis_Sts_Display_GantryTrap^[iN].dwFlag_AxisSts	     	 := dwTemp; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diTarget_pos	     	 := LINT_TO_DINT(i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.target_pos); 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].udiMax_vel	     	 	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.max_vel; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diMain_axis_shift	     := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.main_axis_shift; 
		i_pastStAxis_Sts_Display_GantryTrap^[iN].diSecond_axis_shift	 := i_pastStSetPrm_GantryTrap^[iGroupId_Gantry].prm.gantrayTrapPrm.second_axis_shift; 
	END_CASE   
END_FOR
SysMemcpy(i_pastStAxis_Sts_Save_GantryTrap,i_pastStAxis_Sts_Display_GantryTrap,SIZEOF(i_pastStAxis_Sts_Save_GantryTrap^));