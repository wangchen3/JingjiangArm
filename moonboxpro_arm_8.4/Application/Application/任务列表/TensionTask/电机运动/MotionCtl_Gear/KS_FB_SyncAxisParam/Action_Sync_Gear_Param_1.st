(*@CES
Name=Action_Sync_Gear_Param_1
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=a44e1949-81ee-4fa2-95d6-81cc1103c28b
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
pstStGrpParam_Save:= ADR(i_pstStSysParam^.astStGrpParam_Save[i_iGrpId]);
pstStGrpParam_UnSave:= ADR(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]);
astStTStGearParam[iAxisId].axis_mode:= 3;
astStTStGearParam[iAxisId].mode:= 3;
astStTStGearParam[iAxisId].reserve:= 0;
astStTStGearParam[iAxisId].reserve2:= 0;
CASE iTypeId OF
	TYPE_MASTER_I,TYPE_MASTER_II:
		o_iAxisId_Master:= iAxisId;+
	TYPE_CENTRAL_I,TYPE_CENTRAL_II:
		rTemp_Vel:= pstStGrpParam_UnSave^.rVel_Film;
		IF pstStGrpParam_UnSave^.xMotRev_CentralDrum THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.6:= pstStGrpParam_UnSave^.xFlag_Print;
		IF pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.6 THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*pstStGrpParam_Save^.uiNum_CenterRoller/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/pstStGrpParam_Save^.rGirth_CenterRoller/pstStGrpParam_Save^.uiDen_CenterRoller);
	TYPE_UNWIND_A_I,TYPE_UNWIND_A_II:
		rTemp_Vel:= pstStGrpParam_UnSave^.rAxisAVelRPM_Cur_Uw;(*转速*)
		IF pstStGrpParam_UnSave^.xMotRev_AxisA_Uw THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.2:= pstStGrpParam_UnSave^.xAxisAForeward_Uw;
		IF pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.2 THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*pstStGrpParam_Save^.uiNum_Uw/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/pstStGrpParam_Save^.uiDen_Uw);
	TYPE_UNWIND_B_I,TYPE_UNWIND_B_II:
		rTemp_Vel:= pstStGrpParam_UnSave^.rAxisBVelRPM_Cur_Uw;(*转速*)
		IF pstStGrpParam_UnSave^.xMotRev_AxisB_Uw THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.3:= pstStGrpParam_UnSave^.xAxisBForeward_Uw;
		IF pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.3 THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*pstStGrpParam_Save^.uiNum_Uw/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/pstStGrpParam_Save^.uiDen_Uw);		
	TYPE_REWIND_A_I,TYPE_REWIND_A_II:
		rTemp_Vel:= pstStGrpParam_UnSave^.rAxisAVelRPM_Cur_Rw;(*转速*)
		IF pstStGrpParam_UnSave^.xMotRev_AxisA_Rw THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.4:= pstStGrpParam_UnSave^.xAxisAForeward_Rw;
		IF pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.4 THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*pstStGrpParam_Save^.uiNum_Rw/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/pstStGrpParam_Save^.uiDen_Rw);			
	TYPE_REWIND_B_I,TYPE_REWIND_B_II:
		rTemp_Vel:= pstStGrpParam_UnSave^.rAxisBVelRPM_Cur_Rw;(*转速*)
		IF pstStGrpParam_UnSave^.xMotRev_AxisB_Rw THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.5:= pstStGrpParam_UnSave^.xAxisBForeward_Rw;
		IF pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.5 THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*pstStGrpParam_Save^.uiNum_Rw/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/pstStGrpParam_Save^.uiDen_Rw);			
	TYPE_INFEED_I,TYPE_INFEED_II:
		rTemp_Vel:= pstStGrpParam_UnSave^.rVel_Cur_If;
		IF pstStGrpParam_UnSave^.xMotRev_If THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.0:= pstStGrpParam_UnSave^.xFlag_Print;
		IF pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.6 THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		
		//计算离合区，半个周期的脉冲数
		diModify_Delta:= 0;
		diModify_Delta:= ABS(REAL_TO_DINT(rTemp_Vel*
									GC_LRMOTORPPR*
									gc_TENSION_TSK_CYCLE_TIME/60.0/1000.0/2));
		IF diModify_Delta=0 THEN
			diModify_Delta:= 1000000;
		END_IF
		
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*pstStGrpParam_Save^.uiNum_If/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/pstStGrpParam_UnSave^.rUsingGirth_If/pstStGrpParam_Save^.uiDen_If);
	
	TYPE_OUTFEED_I,TYPE_OUTFEED_II:
		rTemp_Vel:= pstStGrpParam_UnSave^.rVel_Cur_Of;
		IF pstStGrpParam_UnSave^.xMotRev_Of THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.1:= pstStGrpParam_UnSave^.xFlag_Print;
		IF pstStGrpParam_UnSave^.wEn_UwRw_IfOf_Center.6 THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		
		//计算离合区，半个周期的脉冲数
		diModify_Delta:= 0;
		diModify_Delta:= ABS(REAL_TO_DINT(rTemp_Vel*
									GC_LRMOTORPPR*
									gc_TENSION_TSK_CYCLE_TIME/60.0/1000.0/2));
		IF diModify_Delta=0 THEN
			diModify_Delta:= 1000000;
		END_IF
		
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*pstStGrpParam_Save^.uiNum_Of/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/pstStGrpParam_UnSave^.rUsingGirth_Of/pstStGrpParam_Save^.uiDen_Of);
	
	TYPE_UNIT_PRN:
		rTemp_Vel:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_PrnRoller;;
		IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_PrnRoller THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_PrnRoller THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		
		//计算离合区，半个周期的脉冲数
		diModify_Delta:= 0;
		diModify_Delta:= ABS(REAL_TO_DINT(i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_PrnRoller*
									GC_LRMOTORPPR*
									gc_TENSION_TSK_CYCLE_TIME/60.0/1000.0/2));
		IF diModify_Delta=0 THEN
			diModify_Delta:= 1000000;
		END_IF
		
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		
		IF astStTStGearParam[iAxisId].ratio_a= 0 THEN
			astStTStGearParam[iAxisId].ratio_a:= 1000000;
		END_IF
		
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_PrnRoller*1000
					/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_PrnRoller
					/i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_PrnRoller);
	
	TYPE_UNIT_BOTTOM:
		rTemp_Vel:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_BottomRoller;;
		IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_BottomRoller THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_BottomRoller THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_BottomRoller
					/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_BottomRoller
					/i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_BottomRoller);
	
	TYPE_UNIT_NET:
		rTemp_Vel:= i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].rAxisVel_NetRoller;;
		IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xMotRev_NetRoller THEN
			rTemp_Vel:= -rTemp_Vel;
		END_IF
		IF i_pstStSysParam^.astStUnitParam_UnSave[iUnitId].xEn_Motor_NetRoller THEN
			astStTStGearParam[iAxisId].axis_ctrl:= 3;
		ELSE
			astStTStGearParam[iAxisId].axis_ctrl:= 2;
		END_IF
		astStTStGearParam[iAxisId].axis_id:= INT_TO_UINT(iAxisId);
		astStTStGearParam[iAxisId].modify_delta:= diModify_Delta;
		(*主轴速度当前输入速度就是当前线速度转换的pul/2ms||2ms为运控周期，后期如果改了，许多地方都变了
		这里计算结果相当于2s主轴运行脉冲数||那么齿轮比分母*)
		astStTStGearParam[iAxisId].ratio_a:= LREAL_TO_DINT(i_rVel_VirtualMotion*2000.0/MASTER_DRIVER_TIME);
		(*GC_LRMOTORPPR*)
		lrTemp:= REAL_TO_LREAL(rTemp_Vel)*2000.0*GC_LRMOTORPPR*i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiNum_NetRoller
					/1000.0/60.0;
		astStTStGearParam[iAxisId].ratio_b:= LREAL_TO_DINT(lrTemp/i_pstStSysParam^.astStUnitParam_Save[iUnitId].rGirth_NetRoller
					/i_pstStSysParam^.astStUnitParam_Save[iUnitId].uiDen_NetRoller);
	
	
END_CASE
