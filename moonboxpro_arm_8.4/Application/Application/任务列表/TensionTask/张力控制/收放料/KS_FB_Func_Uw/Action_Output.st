(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=e109211b-ba5c-46a4-ab61-afb1d8f0ff81
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//2026.5.16.094857
Action_Hmi_Display();


(**---------------2025.8.4.215646IO输出控制--------**)
i_pstStIOMap_Uw^.o_xEstopLamp:= i_pstStEvtReq^.xOutEstop;
i_pstStIOMap_Uw^.o_xCutOnTop := i_pstStEvtReq^.xOutCutOnTop					;(*: BOOL;(*上裁指示*)		*)
i_pstStIOMap_Uw^.o_xLamp_SafeTyGrating := i_pstStEvtReq^.xOutSafeTyGrating			;(*	: BOOL;(*安全光栅*)		*)	
//i_pstStIOMap_Uw^.o_xCutHolder_UpCut := i_pstStEvtReq^.xOutCutHolder				;(*	: BOOL;(*大臂输出*)		*)
i_pstStIOMap_Uw^.o_xCutHolder_UpCut := i_pstStEvtReq^.xOutCutHolder_Up				;(*: BOOL;		            *)
i_pstStIOMap_Uw^.o_xCutHolder_DnCut := i_pstStEvtReq^.xOutCutHolder_Dn				;(*: BOOL;		            *)
//i_pstStIOMap_Uw^. := i_pstStEvtReq^.xOutCutCylinder				;(*	: BOOL;(*大臂压辊*)		*)
//i_pstStIOMap_Uw^.o_xCutCylinder_UpCut := i_pstStEvtReq^.xOutCutCylinder_Up			;(*	: BOOL;			        *)
//i_pstStIOMap_Uw^.o_xCutCylinder_DnCut := i_pstStEvtReq^.xOutCutCylinder_Dn			;(*	: BOOL;		            *)
//i_pstStIOMap_Uw^. := i_pstStEvtReq^.xOutCutter					;(*	: BOOL;(*裁刀*)		    *)
//i_pstStIOMap_Uw^.o_xCutter_UpCut := i_pstStEvtReq^.xOutCutter_Up				;(*	: BOOL;(*裁刀*)		    *)
//i_pstStIOMap_Uw^.o_xCutter_DnCut := i_pstStEvtReq^.xOutCutter_Dn				;(*	: BOOL;(*裁刀*)			*)
i_pstStIOMap_Uw^.o_xRel_TowerForeward := i_pstStEvtReq^.xOutTowerFor					;(*: BOOL;(*翻转架正转*)		*)
i_pstStIOMap_Uw^.o_xRel_TowerReversal := i_pstStEvtReq^.xOutTowerRev					;(*: BOOL;(*翻转架反转*)		*)		
i_pstStIOMap_Uw^.o_xAxisAForeward := i_pstStEvtReq^.xOutAxisAFor					;(*: BOOL;(*A轴正转*)		*)
i_pstStIOMap_Uw^.o_xAxisAReversal := i_pstStEvtReq^.xOutAxisARev					;(*: BOOL;(*A轴反转*)		*)
i_pstStIOMap_Uw^.o_xAxisAZeroServo := i_pstStEvtReq^.xOutAxisAZeroServo			;(*	: BOOL;(*A轴零伺服*)		*)
i_pstStIOMap_Uw^.o_xAxisBForeward := i_pstStEvtReq^.xOutAxisBFor					;(*: BOOL;(*B轴正转*)		*)
i_pstStIOMap_Uw^.o_xAxisBReversal := i_pstStEvtReq^.xOutAxisBRev					;(*: BOOL;(*B轴反转*)		*)
i_pstStIOMap_Uw^.o_xAxisBZeroServo := i_pstStEvtReq^.xOutAxisBZeroServo			;(*	: BOOL;(*B轴零伺服*)		*)	
i_pstStIOMap_Uw^.o_xAxisALamp := i_pstStEvtReq^.xOutAxisALamp				;(*	: BOOL;(*A轴指示*)		*)
i_pstStIOMap_Uw^.o_xAxisBLamp := i_pstStEvtReq^.xOutAxisBLamp				;(*	: BOOL;(*B轴指示*)		*)
//i_pstStIOMap_Uw^.o_xAxisATorqueCancel := i_pstStEvtReq^.xOutAxisATorqueCancel		;(*	: BOOL;(*转矩取消*)		*)
//i_pstStIOMap_Uw^.o_xAxisBTorqueCancel := i_pstStEvtReq^.xOutAxisBTorqueCancel		;(*	: BOOL;(*转矩取消*)		*)
//i_pstStIOMap_Uw^.o_wAxisATorqueVolt := i_pstStEvtReq^.wOutAxisATorqueVolt			;(*	: WORD;(*转矩*)		    *)
//i_pstStIOMap_Uw^.o_wAxisBTorqueVolt := i_pstStEvtReq^.wOutAxisBTorqueVolt			;(*	: WORD;(*转矩*)		    *)
i_pstStIOMap_Uw^.o_xLamp_SafeTyGrating := i_pstStEvtReq^.xOutLamp_SafeTyGrating_Out	;(*	: BOOL;(*光栅保护*)		*)
i_pstStIOMap_Uw^.o_xLampAxisInching := i_pstStEvtReq^.xOutLampAxisInching			;(*	: BOOL;(*轴单运行指示*)	*)	
i_pstStIOMap_Uw^.o_xLamp_PreDrive := i_pstStEvtReq^.xOutLampPreDrive				;(*: BOOL;(*预驱完成指示灯*)	*)	
i_pstStIOMap_Uw^.o_xRel_AlarmBell := i_pstStEvtReq^.xOutAlarmBell				;(*	: BOOL;(*报警铃*)		*)	
(*---------------------------------------------*)

(*电机运动需要增加的变量2025.9.23.102804|niu.j*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAForeward_Uw:= i_pstStIOMap_Uw^.o_xAxisAForeward;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisBForeward_Uw:= i_pstStIOMap_Uw^.o_xAxisBForeward;



(* 2021.7.7.084438/ *)
(*输出参数赋值2025.8.4.215731*)
//i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_PreCutting_Uw:= o_xSts_PreCutting;

i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisAFreq_Uw:= rAxisAFreq_Out						;(*: REAL;								*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisBFreq_Uw:= rAxisBFreq_Out						;(*: REAL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Uw_AxisA:= rAxisAVolByVel_Out					;(*: REAL;(*A轴输出电压值*)                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Uw_AxisB:= rAxisBVolByVel_Out					;(*: REAL;(*B轴输出电压值*)                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisAVelRPM_Cur_Uw:= rAxisAVel_RPM_Out					;(*: REAL;(*A轴转速值*)                   *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisBVelRPM_Cur_Uw:= rAxisBVel_RPM_Out					;(*: REAL;(*B轴转速值*)	                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xWillAutoMaticPreCut_Uw:= xWillAutoMaticPreCut_Out			;(*: bool;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAutoMaticCuttingLenth_CurMode_uw:= rAutoMaticCuttingLenth_CurMode_Out	;(*: REAL;(*自动裁切当前模式的计米值*)       *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AutoMaticCutting_Uw:= xFlag_AutoMaticCutting_Out			;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Uw:= arKpid_Use_Out						;(*: ARRAY [1..3] OF REAL;(*当前使用PID*) *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAllowSwitchCutter_Uw:= xAllowSwitchCutter_Out				;(*: BOOL;                               *)
IF xNeedAlarmBell_Out<>xPrevNeedAlarmBell_Out THEN(*更新了才赋值@2026.06.01.182008+*)
	i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAlarmBell_Uw:= xNeedAlarmBell_Out					;(*: BOOL;(**)                           *)
	xPrevNeedAlarmBell_Out:=xNeedAlarmBell_Out;
END_IF
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisALocation_Use_Uw:= xAxisALocation_Use_Out				;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisBLocation_Use_Uw:= xAxisBLocation_Use_Out				;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_DiamMeasure_end_Uw:= xFlag_DiamMeasure_end_Out			;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_PreDrv_Uw:= rVel_Predrv_Out						;(*: REAL;(*预驱速度输出*)                 *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreDrv_ing_Uw:= xFlag_PreDrv_ing_Out				;(*: BOOL;(**)                           *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreDrv_end_Uw:= xFlag_PreDrv_end_Out				;(*: BOOL;                               *)
(*i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]:= xPreDrvAxis_Releasing_Out			;*)(*: BOOL;                               *)
//i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_ing_Uw:= xFlag_Cut_ing_Out					;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw:= xFlag_Cut_end_Out					;(*: BOOL;                               *)

//2026.05.25.120105+

//i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Uw_UseInOtherPrg	:= FALSE			;	(*: BOOL;(*使用在别的Prg中的放料裁切完成标志|在自己的prg中清除*)	*)
//i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_ing_Uw_UseInOtherPrg	:= xFlag_Cut_ing_Uw_UseInOtherPrg_In_Out			;	(*: BOOL;(*使用在别的Prg中的放料裁切完成标志|在自己的prg中清除*)	*)

i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xReflectionSensorValid_Uw:= xReflectionSensorValid_Out			;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xReflectSensorLoss_Uw:= xReflectSensorLoss_Out				;(*: BOOL;(*弧面信号丢失*)                 *)
(*:= xAxisATorqueCancel_Out				;*)(*: BOOL;                               *)
(*:= xAxisBTorqueCancel_Out				;*)(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDeltaW_RPMIN_Uw:= rDeltaW_RPMIN_Out					;(*: REAL;(*放料翻转架转动时候的转速补偿值*)  *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTowerThetaCur_Uw:= rTowerThetaCur_Out					;(*: REAL;(*翻转架当前弧度*)	            *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rFilmToTowerRollerDis_Uw:= rFilmToTowerRollerDis_Out			;(*: REAL;(*料膜距离导向辊距离*)            *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFilmTouchRoller_Uw:= xFilmTouchRoller_Out				;(*: BOOL;(*料膜接触到了棍子标志*)          *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_VolDiamAlarm_Uw:= xFlag_VolDiamAlarm_Out				;(*: BOOL;                               *)
(*i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId]:= stTime_Varying_Parameters_Output	;*)(*: Time_Varying_Parameters;	        *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Uw:= rWuCompensate_Out					;(*: REAL;(*补偿的转速-计算值*)             *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Act_Uw:= rWuCompensate_Act_Out				;(*: REAL;(*补偿的转速-应用值*)             *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVolt_CalcDiam_Used_Watch:= rVolt_CalcDiam_Used_Watch_Out		;(*: REAL;                               *)	
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rMainVel_Uw:=rMainVel;//缺少赋值处理@2026.5.27.141827+


(*2025.8.4.142641输入输出参数-输入获取*)
i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.2					:= xTaperUnitType_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_Uw			:= 	byTaperUnit_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_Uw	:= byTaperUnitConfirm_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_Uw			:= rPercentMatchN_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_Uw		:= rPercentMatchMpa_In_Out		;	
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_Uw	:= rTaperValueBegin_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_Uw	:= rTaperValueEnd_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_Uw	:= rTaperValueCur_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_Uw			:= rTaper_Begin_In_Out			;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_Uw				:= rTaper_End_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Cur_Uw			:= rTaper_Cur_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_Uw			:= 	rTaperMax_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisA_Uw			:= iDebugVelmpm_AxisA_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisA_Uw			:= iDebugGirthmm_AxisA_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisB_Uw			:= iDebugVelmpm_AxisB_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisB_Uw			:= iDebugGirthmm_AxisB_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axMeasure_StdVol				:= axMeasure_StdVol_In_Out						;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCutterOnTopFroDebug_Uw			:= xCutterOnTopFroDebug_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisAFroDebug_Uw			:= xCurAxisAFroDebug_In_Out						;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rActRemainFilmLenth_Uw			:= rActRemainFilmLenth_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_Uw					:= bySetTestPid_In_Out							;(*: BYTE;(*伪随机步骤*)                         *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisDia_Uw_Wr				:= xCurAxisDia_Wr_In_Out						;(*: BOOL;(*界面周长设定写入按钮*)                *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.0					:= xCutAxisA_In_Out								;(*: BOOL;(*当前轴*)                            *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiDia_Uw						:= rEstiDia_In_Out								;(*: REAL;(*预估卷径值*)                         *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_Change_CutterOnTop_HMI_Uw	:= xSwitch_IsUpCut_HMI_In_Out					;(*: BOOL;(*界面切换上下裁开关*)                  *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byEncodeValueWr_Uw				:= byEncodeValueWr_In_Out						;(*: BYTE;(*编码器值写入|放料:                    *)
												;:= ;(*			 01 写入轴定位值                    *)
 												;:= ;(*			 02 写入A轴最小径定位值*)            *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisALocation_Uw			:= adwAxisALocation_In_Out						;(*: ARRAY [0..1] OF DWORD;                    *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisBLocation_Uw			:= adwAxisBLocation_In_Out						;(*: ARRAY [0..1] OF DWORD;                    *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisALocation_MinDiam_Uw	:= adwAxisALocation_MinDia_In_Out				;(*: ARRAY [0..1] OF DWORD;                    *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisBLocation_MinDiam_Uw	:= adwAxisBLocation_MinDia_In_Out				;(*: ARRAY [0..1] OF DWORD;                    *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAI_DiamMeasure_Uw				:= rAi_DiamMeasure_In_Out						;(*: REAL;                                     *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Uw					:= xEnCodeFailed_In_Out							;(*: BOOL;			                          *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_DiamCalc_end_Uw			:= xFlag_DiamCalc_end_In_Out					;(*: BOOL;(*卷径计算完成标志*)                    *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_DiamCalc_ing_Uw			:= xFlag_DiamCalc_ing_In_Out					;(*: BOOL;(*卷径计算中标志*)                     *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebug_DiaMeasure_Uw			:= xIsDebug_DiaMeasure_In_Out					;(*: BOOL;                                     *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xIsDebuging_DiaMeasure_Uw		:= xIsDebuging_DiaMeasure_In_Out				;(*: BOOL;(*放料卷径测量调试中*)                  *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCancelDebuging_DiaMeasure_Uw	:= xCancelDebuging_DiaMeasure_In_Out			;(*: BOOL;(*放料卷径测量调试条件*)                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byIsDebug_DiaMeasureArea_Uw		:= byIsDebug_DiaMeasureArea_In_Out				;(*: BYTE;                                     *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].astStStdVolParam_DnCut_UpCut		:= astStStdVolParam_DnCut_UpCut_In_Out			;(*: ARRAY [0..1] OF StStdVolParam_DnCut_UpCut;*)
(*2025.11.14.092955
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw					:= wAxisDebug_UwRw_In_Out						;(*: WORD;(**)(*轴调试标志|.0\放料调试使能.1\放料A轴调试运行.2\放料A轴自动加减速.3\放料A轴运行中.4\放料B轴调试运行.5\放料B轴自动加减速.6\放料B轴运行中*)
 												;:= ;(*	.8\收料调试使能.9\收料A轴调试运行.10\收料A轴自动加减速.11\收料A轴运行中.12\收料B轴调试运行.13\收料B轴自动加减速.14\收料B轴运行中*)				*)		 
*)i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisA_Uw		:= rDebugCurVelmpmAxisA_In_Out					;(*: REAL;                   *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisB_Uw			:= rDebugCurVelmpmAxisB_In_Out					;(*: REAL;                   *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisA_Uw			:= rDebugCurVelrpmAxisA_In_Out					;(*: REAL;	                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisB_Uw			:= rDebugCurVelrpmAxisB_In_Out					;(*: REAL;					*)			  						  

i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_Tower_Uw					:= rDiam_Tower_In_Out							;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rDiam_NextRoller_Uw				:= rDiam_NextRoller_In_Out						;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rXPos_NextRoller_Uw				:= rXPos_NextRoller_In_Out						;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rYPos_NextRoller_Uw				:= rYPos_NextRoller_In_Out 						;(*: REAL;		                                            *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAbsEncSPos_Cur_Uw				:= dwEncodePos_In_Out							;(*: DWORD;                                                  *)
//2026.05.20.205138 变量使用错误
//i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xConfirmRad0					:= xConfirmRad0_In_Out							;(*: BOOL;(*0弧度确认*)                                       *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xConfirmRad0_Uw					:= xConfirmRad0_In_Out;	

i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].dwAxisAabsPos_0Rad_Uw				:= dwAxisAAbsPos_0Rad_In_Out					;(*: DWORD;(*A轴0弧度位置*)                                    *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].dwAxisBabsPos_0Rad_Uw				:= dwAxisBAbsPos_0Rad_In_Out					;(*: DWORD;(*B轴0弧度位置*)                                    *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Follow_1U_V_UwCut			:= xFlag_Follow_1U_V_UwCut_In_Out				;(*: BOOL;(*裁切时跟踪第一色标志*)                              *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byMeters_UseFollow_1U_V_UwCut		:= byMeters_UseFollow_1U_V_UwCut_In_Out			;(*: BYTE;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiThickness_Uw					:= rEstiThickness_In_Out						;	(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThickNess_Using				:= rFilmThickNess_Using_In_Out					;(*: REAL;(*使用的料膜厚度*)                                   *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xKeepAlarm_NoMaterial			:= xKeepAlarm_NoMaterial_In_Out					;(*: BOOL;(*长报警标志复位*)                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byVelSa_DiamCompensate_Uw			:= byVelSa_DiamCompensate_In_Out				;(*: BYTE;(*补偿起始速度*)                                     *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byDelayTime_DiaCompensateWhenCutDne_Uw:= byDelayTime_DiaCompensateWhenCutDne_In_Out	;(*: BYTE;(*裁切后卷径补偿之后时间|s*)                           *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Uw					:= rKc_In_Out									;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Uw_AccDec				:= rKc_AccDec_In_Out							;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiUseTime_Diam_Min_Uw		:= uiUseTime_Diam_Min_In_Out					;(*: UINT;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_LQR_Uw				:= rR_K_LQR_In_Out								;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_LQR_Uw					:= rN_LQR_In_Out								;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_MinBeat_Uw			:= rR_K_MinBeat_In_Out							;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iN_MinBeat_Uw				:= iN_MinBeat_In_Out							;(*: INT;                                                    *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stModelParam_Uw			:= stModelParam_In_Out							;(*: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)      *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stInvariant_Parameters_Uw	:= stInvariant_Parameters_In_Out				;(*: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)      *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Uw		:= stPI_Parameters_In_Out						;(*: PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)			*)			  
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Uw_AccDec	:= stPI_Parameters_AccDec_In_Out				;(*: PI_Parameters;(*控制器pi参数@20bytes|用于加减速*)			*)			  
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.0 := xAxisDebugEn_In_Out		;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.1 := xAxisADebugRun_In_Out		; 
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.4:= xAxisBDebugRun_In_Out		;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.3:= xAxisADebugRunning_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.6:= xAxisBDebugRunning_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.2:= xAxisADebugAutoAccDec_In_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.5:= xAxisBDebugAutoAccDec_In_Out;

//2025.10.22.114150增加输出一下单运行模式2025.10.22.114159||niu.j|用于电机运行规划
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xInching_Uw:= xInch OR xRevInch;(*标志输出-使能和速度已经有输出了*)
(*------------------------------------------------------------*)

(*增加几个用于保存的变量*)
g_arDiamWuCompensate_Uw[i_iGrpId]:= fbKS_FB_UwRw_Tension_2024.rDiamWuCompensate;
g_arEstiDia_LowPass_Uw[i_iGrpId]:= rEstiDia_LowPass;
g_arAntiNotch_Out_Uw[i_iGrpId]:= rAntiNotch_Out_Uw;


//部分标志需要输出全局，用在主任务的裁切逻辑42026.4.12.135721
g_axLamp_PreDrive_Debug_Uw[i_iGrpId]:= xLamp_PreDrive_Debug;
g_axSts_Sensor1Ok[i_iGrpId]:= xSts_Sensor1Ok;

