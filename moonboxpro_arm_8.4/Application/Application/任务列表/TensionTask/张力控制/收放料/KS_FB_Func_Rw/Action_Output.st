(*@CES
Name=Action_Output
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=7e09b06b-ea1a-40f5-9c97-4b9a776704f8
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
//2026.05.21.100601
Action_Hmi_Display();

(**---------------2025.8.4.215646IO输出控制--------**)
i_pstStIOMap_Rw^.o_xEstopLamp:= i_pstStEvtReq^.xOutEstop;
i_pstStIOMap_Rw^.o_xCutOnTop := i_pstStEvtReq^.xOutCutOnTop					;(*: BOOL;(*上裁指示*)		*)
i_pstStIOMap_Rw^.o_xLamp_SafeTyGrating := i_pstStEvtReq^.xOutSafeTyGrating			;(*	: BOOL;(*安全光栅*)		*)	
i_pstStIOMap_Rw^.o_xCutHolder_UpCut := i_pstStEvtReq^.xOutCutHolder_Up				;(*: BOOL;		            *)
i_pstStIOMap_Rw^.o_xCutHolder_DnCut := i_pstStEvtReq^.xOutCutHolder_Dn				;(*: BOOL;		            *)
i_pstStIOMap_Rw^.o_xCutCylinder_UpCut := i_pstStEvtReq^.xOutCutCylinder_Up			;(*	: BOOL;			        *)
i_pstStIOMap_Rw^.o_xCutCylinder_DnCut := i_pstStEvtReq^.xOutCutCylinder_Dn			;(*	: BOOL;		            *)
i_pstStIOMap_Rw^.o_xCutter_UpCut := i_pstStEvtReq^.xOutCutter_Up				;(*	: BOOL;(*裁刀*)		    *)
i_pstStIOMap_Rw^.o_xCutter_DnCut := i_pstStEvtReq^.xOutCutter_Dn				;(*	: BOOL;(*裁刀*)			*)
i_pstStIOMap_Rw^.o_xRel_TowerForeward := i_pstStEvtReq^.xOutTowerFor					;(*: BOOL;(*翻转架正转*)		*)
i_pstStIOMap_Rw^.o_xRel_TowerReversal := i_pstStEvtReq^.xOutTowerRev					;(*: BOOL;(*翻转架反转*)		*)		
i_pstStIOMap_Rw^.o_xAxisAForeward := i_pstStEvtReq^.xOutAxisAFor					;(*: BOOL;(*A轴正转*)		*)
i_pstStIOMap_Rw^.o_xAxisAReversal := i_pstStEvtReq^.xOutAxisARev					;(*: BOOL;(*A轴反转*)		*)
i_pstStIOMap_Rw^.o_xAxisAZeroServo := i_pstStEvtReq^.xOutAxisAZeroServo			;(*	: BOOL;(*A轴零伺服*)		*)
i_pstStIOMap_Rw^.o_xAxisBForeward := i_pstStEvtReq^.xOutAxisBFor					;(*: BOOL;(*B轴正转*)		*)
i_pstStIOMap_Rw^.o_xAxisBReversal := i_pstStEvtReq^.xOutAxisBRev					;(*: BOOL;(*B轴反转*)		*)
i_pstStIOMap_Rw^.o_xAxisBZeroServo := i_pstStEvtReq^.xOutAxisBZeroServo			;(*	: BOOL;(*B轴零伺服*)		*)	
i_pstStIOMap_Rw^.o_xAxisALamp := i_pstStEvtReq^.xOutAxisALamp				;(*	: BOOL;(*A轴指示*)		*)
i_pstStIOMap_Rw^.o_xAxisBLamp := i_pstStEvtReq^.xOutAxisBLamp				;(*	: BOOL;(*B轴指示*)		*)
i_pstStIOMap_Rw^.o_xAxisATorqueCancel := i_pstStEvtReq^.xOutAxisATorqueCancel		;(*	: BOOL;(*转矩取消*)		*)
i_pstStIOMap_Rw^.o_xAxisBTorqueCancel := i_pstStEvtReq^.xOutAxisBTorqueCancel		;(*	: BOOL;(*转矩取消*)		*)
i_pstStIOMap_Rw^.o_wAxisATorqueVolt := i_pstStEvtReq^.wOutAxisATorqueVolt			;(*	: WORD;(*转矩*)		    *)
i_pstStIOMap_Rw^.o_wAxisBTorqueVolt := i_pstStEvtReq^.wOutAxisBTorqueVolt			;(*	: WORD;(*转矩*)		    *)
i_pstStIOMap_Rw^.o_xLamp_SafeTyGrating := i_pstStEvtReq^.xOutLamp_SafeTyGrating_Out	;(*	: BOOL;(*光栅保护*)		*)
i_pstStIOMap_Rw^.o_xLampAxisInching := i_pstStEvtReq^.xOutLampAxisInching			;(*	: BOOL;(*轴单运行指示*)	*)	
i_pstStIOMap_Rw^.o_xLamp_PreDrive := i_pstStEvtReq^.xOutLampPreDrive				;(*: BOOL;(*预驱完成指示灯*)	*)	
i_pstStIOMap_Rw^.o_xRel_AlarmBell := i_pstStEvtReq^.xOutAlarmBell				;(*	: BOOL;(*报警铃*)		*)	
i_pstStIOMap_Rw^.o_xLamp_PaperCoreSelect6Inch:= i_pstStEvtReq^.xOutLamp_PaperCoreSelect6Inch;	
(*---------------------------------------------*)
(*电机运动需要增加的变量2025.9.23.102804|niu.j*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisAForeward_Rw:= i_pstStIOMap_Rw^.o_xAxisAForeward;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisBForeward_Rw:= i_pstStIOMap_Rw^.o_xAxisBForeward;


(* 2021.7.7.084438/ *)
(*输出参数赋值2025.8.4.215731*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xSts_PreCutting_Rw:= o_xSts_PreCutting;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisAFreq_Rw:= rAxisAFreq_Out						;(*: REAL;								*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisBFreq_Rw:= rAxisBFreq_Out						;(*: REAL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Rw_AxisA:= rAxisAVolByVel_Out					;(*: REAL;(*A轴输出电压值*)                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAO_Inverter_Rw_AxisB:= rAxisBVolByVel_Out					;(*: REAL;(*B轴输出电压值*)                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisAVelRPM_Cur_Rw:= rAxisAVel_RPM_Out					;(*: REAL;(*A轴转速值*)                   *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAxisBVelRPM_Cur_Rw:= rAxisBVel_RPM_Out					;(*: REAL;(*B轴转速值*)	                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_AutoMaticCutting_Rw:= xFlag_AutoMaticCutting_Out			;(*: BOOL;                               *)
IF xNeedAlarmBell_Out<>xPrevNeedAlarmBell_Out THEN(*更新了才赋值@2026.06.01.182008+*)
	i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAlarmBell_Rw:= xNeedAlarmBell_Out					;(*: BOOL;(**)                           *)
	xPrevNeedAlarmBell_Out:=xNeedAlarmBell_Out;
END_IF
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisALocation_Use_Rw:= xAxisALocaltion_Out				;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAxisBLocation_Use_Rw:= xAxisBLocaltion_Out				;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xAllowSwitchCutter_Rw:= xAllowSwitchCutter_Out				;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_6Inch_Rw:= xFlag_6Inch_Out;(*: BOOL;(*当前为6吋纸芯*)*)

i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_PreDrv_Rw:= rVel_Predrv_Out						;(*: REAL;(*预驱速度输出*)                 *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreDrv_ing_Rw:= xFlag_PreDrv_ing_Out				;(*: BOOL;(**)                           *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_PreDrv_end_Rw:= xFlag_PreDrv_end_Out				;(*: BOOL;                               *)
(*	xPreDrvAxis_Releasing_Out: BOOL;*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_ing_Rw:= xFlag_Cut_ing_Out					;(*: BOOL;                               *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].arKpid_Current_Rw:= arKpid_Use_Out						;(*: ARRAY [1..3] OF REAL;(*当前使用PID*) *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Rw:= xFlag_Cut_end_Out					;(*: BOOL;                               *)
(*	stTime_Varying_Parameters_Output: Time_Varying_Parameters;	*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Rw:= rWuCompensate_Out					;(*: REAL;(*补偿的转速-计算值*)             *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rWuCompensate_Act_Rw:= rWuCompensate_Act_Out				;(*: REAL;(*补偿的转速-应用值*)             *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rMainVel_Rw:=rMainVel;//缺少赋值处理@2026.5.27.141827+
	
(*2025.10.20.134259*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rAutoMaticCuttingLenth_CurMode_Rw:= rAutoMaticCuttingLenth_CurMode_Rw_Out;

(*2025.8.4.142641输入输出参数-输入获取*)
i_pstStSysParam^.stStSysParam_UnSave.byTaperUnitType.3					:= xTaperUnitType_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byTaperUnit_Rw				:= byTaperUnit_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byTaperUnitConfirm_Rw	:= byTaperUnitConfirm_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchN_Rw			:= rPercentMatchN_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPercentMatchMpa_Rw		:= rPercentMatchMpa_In_Out		;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueBegin_Hmi_Rw	:= rTaperValueBegin_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueEnd_Hmi_Rw	:= rTaperValueEnd_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperValueCur_Hmi_Rw	:= rTaperValueCur_Hmi_In_Out	;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_Begin_Rw			:= rTaper_Begin_In_Out			;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rTaper_End_Rw				:= rTaper_End_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaper_Rw			:= rTaper_Cur_In_Out			;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rTaperMax_Rw				:= rTaperMax_In_Out			;

i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisA_Rw			:= iDebugVelmpm_AxisA_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisA_Rw			:= iDebugGirthmm_AxisA_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugVelmpm_AxisB_Rw			:= iDebugVelmpm_AxisB_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].iDebugGirthmm_AxisB_Rw			:= iDebugGirthmm_AxisB_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].dwAbsEncSPos_Cur_Rw				:= dwEncodePos_In_Out							;(*: DWORD;                                                  *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCutterOnTopFroDebug_Rw			:= xCutterOnTopFroDebug_In_Out					;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisAFroDebug_Rw			:= xCurAxisAFroDebug_In_Out						;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].bySetTestPid_Rw					:= bySetTestPid_In_Out							;(*: BYTE;(*伪随机步骤*)                         *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xCurAxisDia_Rw_Wr				:= xCurAxisDia_Wr_In_Out						;(*: BOOL;(*界面周长设定写入按钮*)                *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].wUwRwAxisProf.1					:= xCutAxisA_In_Out								;(*: BOOL;(*当前轴*)                            *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiDia_Rw						:= rEstiDia_In_Out								;(*: REAL;(*预估卷径值*)                         *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xSwitch_Change_CutterOnTop_HMI_Rw	:= xSwitch_IsUpCut_HMI_In_Out					;(*: BOOL;(*界面切换上下裁开关*)                  *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].byEncodeValueWr_Rw				:= byEncodeValueWr_In_Out						;(*: BYTE;(*编码器值写入|放料:                    *)
											:= ;(*			 01 写入轴定位值                    *)
											:= ;(*			 02 写入A轴最小径定位值*)            *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xGetLenthMachine_Rw:= xGetLenthMachine_In_Out	;(*自动获取整机料长标志*)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byLenth_Machine:= byLenth_Machine_In_Out	;(*整机料长*)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].xUseKnob_6Inch_Rw_Hmi:=xUseKnob_6Inch_HMI_In_Out;(*TRUE:3/6吋切换使用界面按钮
							FALSE:3/6吋切换使用IO输入开关*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xKnob_6Inch_Rw:= xKnob_6Inch_HMI_In_Out;(*界面3/6吋切换开关*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].x6InchFroDebug_Rw:= x6InchFroDebug_In_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xEnCodeErr_Rw					:= xEnCodeFailed_In_Out							;(*: BOOL;			                          *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisALocation_Rw			:= adwAxisALocation_In_Out						;(*: ARRAY [0..1] OF DWORD;                    *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].adwEnc_AxisBLocation_Rw			:= adwAxisBLocation_In_Out						;(*: ARRAY [0..1] OF DWORD;                    *)
(*2025.11.14.093209
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw					:= wAxisDebug_UwRw_In_Out						;(*: WORD;(**)(*轴调试标志|.0\放料调试使能.1\放料A轴调试运行.2\放料A轴自动加减速.3\放料A轴运行中.4\放料B轴调试运行.5\放料B轴自动加减速.6\放料B轴运行中*)
											:= ;(*	.8\收料调试使能.9\收料A轴调试运行.10\收料A轴自动加减速.11\收料A轴运行中.12\收料B轴调试运行.13\收料B轴自动加减速.14\收料B轴运行中*)				*)		 
*)i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisA_Rw			:= rDebugCurVelmpmAxisA_In_Out					;(*: REAL;                   *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelmpmAxisB_Rw			:= rDebugCurVelmpmAxisB_In_Out					;(*: REAL;                   *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisA_Rw			:= rDebugCurVelrpmAxisA_In_Out					;(*: REAL;	                *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rDebugCurVelrpmAxisB_Rw			:= rDebugCurVelrpmAxisB_In_Out					;(*: REAL;					*)			  
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaA_Rw:= rGirth_AxisA_In_Out;(*: REAL;(*设定周长A*)                                                          *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rGirth_AxiaB_Rw:= rGirth_AxisB_In_Out;(*: REAL;(*设定周长B*)                                                          *)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Cut_end_Rw_UseInOtherPrg	:= xFlag_Cut_end_UseInOtherPrg_In_Out			;	(*: BOOL;(*使用在别的Prg中的放料裁切完成标志|在自己的prg中清除*)	*)						  
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_FilmVel:= alrPrnLen_FilmVel_In_Out;						
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_PTPos:= alrPrnLen_PTPos_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen_FilmCnt:= alrPrnLen_FilmCnt_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].alrPrnLen:= alrPrnLen_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rEstiThickness_Rw					:= rEstiThickness_In_Out						;	(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byVelSa_DiamCompensate_Rw			:= byVelSa_DiamCompensate_In_Out				;(*: BYTE;(*补偿起始速度*)                                     *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byDelayTime_DiaCompensateWhenCutDne_Rw:= byDelayTime_DiaCompensateWhenCutDne_In_Out	;(*: BYTE;(*裁切后卷径补偿之后时间|s*)                           *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rFilmThickNess_Using				:= rFilmThickNess_Using_In_Out					;(*: REAL;(*使用的料膜厚度*)                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Rw					:= rKc_In_Out									;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rKc_Rw_AccDec				:= rKc_AccDec_In_Out							;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].uiUseTime_Diam_Min_Rw		:= uiUseTime_Diam_Min_In_Out					;(*: UINT;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_LQR_Rw				:= rR_K_LQR_In_Out								;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rN_LQR_Rw					:= rN_LQR_In_Out								;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rR_K_MinBeat_Rw			:= rR_K_MinBeat_In_Out							;(*: REAL;                                                   *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].iN_MinBeat_Rw				:= iN_MinBeat_In_Out							;(*: INT;                                                    *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stModelParam_Rw			:= stModelParam_In_Out							;(*: Initial_Model_Parameters;(*放料模型初始参数@50bytes*)      *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stInvariant_Parameters_Rw	:= stInvariant_Parameters_In_Out				;(*: Invariant_Parameters;(*放料张力算法系统参数@30bytes*)      *)
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Rw		:= stPI_Parameters_In_Out						;(*: PI_Parameters;(*控制器pi参数@20bytes|用于稳速*)			*)			  
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].stPI_Parameters_Rw_AccDec	:= stPI_Parameters_AccDec_In_Out				;(*: PI_Parameters;(*控制器pi参数@20bytes|用于加减速*)			*)			  

i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.8 := xAxisDebugEn_In_Out		;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.9 := xAxisADebugRun_In_Out		; 
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.12:= xAxisBDebugRun_In_Out		;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.11:= xAxisADebugRunning_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.14:= xAxisBDebugRunning_In_Out	;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.10:= xAxisADebugAutoAccDec_In_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].wAxisDebug_UwRw.13:= xAxisBDebugAutoAccDec_In_Out;		
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byInitTaper_Rw:= byInitTaper_In_Out		;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rInitTaper_Hmi_Rw:= rInitTaper_Hmi_In_Out					; 
					
(*------------------------------------------------------------*)
(*------------------------------------------------------------*)
(*2025.8.22.202930*)
(*2026.04.10.101037*)
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyClrPrnLenCount_Rw[1]:=abyClrPrnLenCount_In_Out[1];
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyClrPrnLenCount_Rw[2]:=abyClrPrnLenCount_In_Out[2];
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].abyClrPrnLenCount_Rw[3]:=abyClrPrnLenCount_In_Out[3];





g_abyClrPrnLenCount[i_iGrpId,1]:= abyClrPrnLenCount_In_Out[1]					;					
g_abyClrPrnLenCount[i_iGrpId,2]:= abyClrPrnLenCount_In_Out[2]					;					
g_abyClrPrnLenCount[i_iGrpId,3]:= abyClrPrnLenCount_In_Out[3]					;					


i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].lrPrnLen_AmountTo:= lrPrintLength_In_Out;
i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].byPrintLength_CalcCtl:= byPrintLength_CalcCtl_In_Out;
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[1]:= axFlag_PrnLen_Alarm_In_Out[1];
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[2]:= axFlag_PrnLen_Alarm_In_Out[2];
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].axFlag_PrnLen_Alarm[3]:= axFlag_PrnLen_Alarm_In_Out[3];
//2025.10.22.114150增加输出一下单运行模式2025.10.22.114159||niu.j|用于电机运行规划
i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xInching_Rw:= xInch OR xRevInch;(*标志输出-使能和速度已经有输出了*)

(*增加几个用于保存的变量*)
g_arDiamWuCompensate_Rw[i_iGrpId]:= fbKS_FB_UwRw_Tension_2024.rDiamWuCompensate;
g_arEstiDia_LowPass_Rw[i_iGrpId]:= rEstiDia_LowPass;

