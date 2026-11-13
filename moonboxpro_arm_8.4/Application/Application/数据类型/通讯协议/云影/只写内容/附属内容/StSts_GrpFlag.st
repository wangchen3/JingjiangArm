(*@CES
Name=StSts_GrpFlag
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=84c3180d-bd4c-42e6-a1a9-68017632a9f9
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
{attribute 'pack_mode' := '1'}
TYPE StSts_GrpFlag :(*2025.7.3.175755总16字节+8预留字节*)
STRUCT
	xCutterOnTop_Uw								: BIT;(* TRUE=放料上裁 *)
	xCutterOnTop_Rw								: BIT;(* TRUE=放料上裁 *)
	xFlag_Stop									: BIT;(* 停机标志/第1次从当前速度降到空转速度，抬所有色组胶辊/牵引速度到0时抬牵引胶辊，第2次按下则将色组从空转停到0速度 *)
	xFlag_PreStart								: BIT;(* 预启动标志/从停机状态按(预)启动置位标志 色组速度达到空转速度清xFlag_PreStart标志,置位xFlag_Ink标志;当xFlag_Print标志有效后 *)
	xFlag_Ink									: BIT;(* 匀墨标志/>20m/min不能联动 *)
	xFlag_InkAccing								: BIT;(* 匀墨加速中<指0~10m/min那个加速过程> *)
	xFlag_Tension								: BIT;(* 张力投入标志/张力投入有效时收放料变频开始起作用/收放料就位后按印刷按钮,牵引压辊合压/xFlag_Print有效时张力投入不处理 *)
	xFlag_TensionDone							: BIT;(* 张力ok，可以投入印刷 *)
	xFlag_Print									: BIT;(* 张力拉料标志有效时，按联动或印刷按钮 先压收牵(延时2s)再压放牵 印刷标志/印刷色组根据联动标志按用户指定的压辊顺序逐一延时压胶辊/胶辊压合完毕后才可置该标志有效 *)
	xFlag_Estop									: BIT;(* 急停标志/和停机一样要减速到0，只不过减速时间是急停时间 *)
	xFlag_AutoAcc								: BIT;(* 自动加速 *)
	xFlag_AutoDec								: BIT;(* 自动减速 *)
	xFlag_ManuAcc								: BIT;(* 手动加速 *)
	xFlag_ManuDec								: BIT;(* 手动减速 *)
	xFlag_Accing								: BIT;(* 加速中 *)
	xFlag_Decing								: BIT;(* 减速中 *)
	xFlag_EStoping								: BIT;(* 正在急停中 *)
	xFlag_Stoping								: BIT;(* 停机中 *)
	xFlag_GotoInking							: BIT;(* 转到匀墨 *)
	xFlag_InPressing							: BIT;(* 顺序压辊中 *)
	xFlag_RollerPressDone						: BIT;(* 压辊处理完成 *)
	xFlag_InchRun								: BIT;(* 至少有1色处于单运行 *)
	xFlag_AllInchRun							: BIT;(* 整机单运行标志 *)
	xFlag_AllPress								: BIT;(* 全体合压 *)
	xFlag_AllUnpress							: BIT;(* 全体离压 *)
	xFlag_RollerPressAtLeast1					: BIT;(* 至少1色色组合压 *)
	xFlag_PrnLen_Alarm_A						: BIT;
	xFlag_PrnLen_Alarm_B						: BIT;
	xFlag_PrnLen_Alarm_All						: BIT;
	xFlag_LinkageAxisAlarm						: BIT;(* 至少有1个联动轴发生报警 *)
	xFlag_TensionUnfinished						: BIT;(* 张力未完成 *)
	xFlag_VelTooHigh							: BIT;(* 速度过高 *)
	xFlag_PrestartTimeout						: BIT;(* 预启动超时标志 *)
	xFlag_KeepAlarming							: BIT;(* 维持报警*)
	xFlag_ArrivedToTargetVel					: BIT;(* 到达目标速度 *)
	xFlag_FilmAccDecDone						: BIT;(* 料膜加减速完成 *)
	xFlag_IfOf_Ink								: BIT;(*空转牵引联动标志*)
	xFlag_FastStoping							: BIT;	
	xSlowStopTenEn								: BIT;(* 收放料慢速松料使能/TRUE *)
	xIsDebugMode_Machine						: BIT;(* 机器调试模式 *)
(*以上40bit*)
	xReflectSensorLoss_Uw						: BIT;(* 放料弧面信号丢失标志/FALSE *)
	xFilmTouchRoller_Uw							: BIT;(*料膜接触到了辊子标志*)
	xSts_PreCutting_Uw							: BIT;(* 放料预备接料/FALSE *)
	xCutterOnTopFroDebug_Uw						: BIT;(* 放料上裁刀标志/用于调试/FALSE *)
	xCurAxisAFroDebug_Uw						: BIT;(* 放料预驱轴为A轴标志/用于调试/FALSE *)
	xAlarmBell_Uw								: BIT;(* 放料响铃常输出/用于控制定位写入响铃提示使用/FALSE *)
	xIsDebuging_DiaMeasure_Uw					: BIT;(* 放料卷径测量调试中/FALSE *)
	xCancelDebuging_DiaMeasure_Uw				: BIT;(* 放料取消卷径测量调试中/FALSE *)
	xEnCodeErr_Uw								: BIT;(* 放料编码器故障*)
	xEnCodeErr_Rw								: BIT;(* 收料编码器故障*)	
	xAxisAForeward_Uw							: BIT;(* 放料A轴正转/FALSE *)
	xAxisBForeward_Uw							: BIT;(* 放料B轴正转/FALSE *)
	xFlag_DiamCalc_ing_Uw						: BIT;(* 放料卷径计算中 *)
	xFlag_DiamCalc_end_Uw						: BIT;(* 放料卷径计算完成 *)
	xFlag_DiamMeasure_end_Uw					: BIT;(* 放料卷径测量完成 *)
	xFlag_PreDrv_ing_Uw							: BIT;(* 放料预驱中... *)
	xFlag_PreDrv_end_Uw							: BIT;(* 放料预驱完成  *)
	xFlag_Cut_ing_Uw							: BIT;
	xFlag_Cut_end_Uw							: BIT;
	xFlag_VolDiamAlarm_Uw						: BIT;(* 卷径报警标志 *)
	xStationOnline_AxisA_Uw						: BIT;(* 放料a轴驱动器在线标志/2021.12.4.175524/hdp *)
	xStationOnline_AxisB_Uw						: BIT;(* 放料a轴驱动器在线标志/2021.12.4.175524/hdp *)	
	xFlag_AutoMaticCutting_Uw					: BIT;(*2022.4.25.090246 自动裁切中标志*)
(*以上23bit*)
	xSts_PreCutting_Rw							: BIT;(* 收料预备接料 *)
	xCutterOnTopFroDebug_Rw						: BIT;(* 收料上裁刀标志/用于调试/FALSE *)
	xCurAxisAFroDebug_Rw						: BIT;(* 收料预驱轴为A轴标志/用于调试/FALSE *)
	x6InchFroDebug_Rw       					: BIT;(* 收料6寸标志/用于调试/FALSE*)
	xAlarmBell_Rw								: BIT;(* 收料响铃常输出/用于控制定位写入响铃提示使用/FALSE *)
	xAxisAForeward_Rw							: BIT;(* 收料A轴正转/FALSE *)
	xAxisBForeward_Rw							: BIT;(* 收料B轴正转/FALSE *)
	xFlag_6Inch_Rw								: BIT;(* 收料6寸标志/反之为3寸/FALSE *)
	xFlag_PreDrv_ing_Rw							: BIT;(* 收料预驱中... *)
	xFlag_PreDrv_end_Rw							: BIT;(* 收料预驱完成 *)
	xFlag_Cut_ing_Rw							: BIT;(* 收料裁切中 *)
	xFlag_Cut_end_Rw							: BIT;(* 收料裁切完成 *)
	xStationOnline_AxisA_Rw						: BIT;(* 收料a轴驱动器在线标志/2021.12.4.175524/hdp *)
	xStationOnline_AxisB_Rw						: BIT;(* 收料a轴驱动器在线标志/2021.12.4.175524/hdp *)	
	xFlag_AutoMaticCutting_rw					: BIT;(*2022.4.25.090246 自动裁切中标志*)
(*以上15bit*)
	xStationOnline_If							: BIT;(* 放牵驱动器在线标志/2021.12.4.175524/hdp *)
	xRollerSts_If								: BIT;(* 放牵压辊/FALSE *)
	xRunEn_If									: BIT;(* 放牵运动使能/0/2021.11.18.201925 *)
	xInching_If									: BIT;(* 放牵单运行中/FALSE *)
	xStationOnline_Of							: BIT;(* 放牵驱动器在线标志/2021.12.4.175524/hdp *)
	xRollerSts_Of								: BIT;(* 放牵压辊/FALSE *)
	xRunEn_Of									: BIT;(* 放牵运动使能/0/2021.11.18.201925 *)
	xInching_Of									: BIT;(* 放牵单运行中/FALSE *)
(*以上8bit*)
	xSts_HorzPreRegister						: BIT;(*横向预套准状态*)
	xFlag_HorzPreRegister_All_end				: BIT;(*横向预套准全部完成*)
	xFlag_Home									: BIT;
	xFlag_Home_ing								: BIT;
	xFlag_Home_end								: BIT;
	xFlag_ConfirmPreRegHomePos					: BIT;(*2017-09-13 12:51:52| 确认预套准基准点*)
	xFlag_ConfirmPreRegHomePos_ing				: BIT;(*确认预套准基准点-ing*)
	xFlag_ConfirmPreRegHomePos_end				: BIT;(*确认预套准基准点-end*)
	xFlag_PreRegister							: BIT;
	xFlag_PreRegister_ing						: BIT;
	xFlag_PreRegister_end						: BIT;
	xFlag_PhaseRestore							: BIT;(*相位恢复*)
	xFlag_PhaseRestore_ing						: BIT;(*相位恢复-ing*)
	xFlag_PhaseRestore_end						: BIT;(*相位恢复-end*)
(*以上14bit*)	
	xNetOffline_CENTRAL							: BIT;
	xAxisAlarm_CENTRAL							: BIT;
	xPosDeviationAlarm_CENTRAL					: BIT;
	xNetOffline_CENTRAL2						: BIT;
	xAxisAlarm_CENTRAL2							: BIT;
	xPosDeviationAlarm_CENTRAL2					: BIT;
	xNetOffline_IF								: BIT;
	xAxisAlarm_IF								: BIT;
	xPosDeviationAlarm_IF						: BIT;
	xNetOffline_OF								: BIT;
	xAxisAlarm_OF								: BIT;
	xPosDeviationAlarm_OF						: BIT;
	xNetOffline_UW_A							: BIT;
	xAxisAlarm_UW_A								: BIT;
	xPosDeviationAlarm_UW_A						: BIT;
	xNetOffline_UW_B							: BIT;
	xAxisAlarm_UW_B								: BIT;
	xPosDeviationAlarm_UW_B						: BIT;
	xNetOffline_RW_A							: BIT;
	xAxisAlarm_RW_A								: BIT;
	xPosDeviationAlarm_RW_A						: BIT;
	xNetOffline_RW_B							: BIT;
	xAxisAlarm_RW_B								: BIT;
	xPosDeviationAlarm_RW_B						: BIT;
	xPrintInching								: BIT;//整机点动
	xTapPosition_Breaking						: BIT;(*断料档位|*)
	xTapPosition_UniformInk						: BIT;(*匀墨档位|*)
	xTapPosition_Printing						: BIT;(*印刷档位|*)
(*以上28bit*)
////////////////////////////////////////////////////////////////////////////////////
(*截至这里，以上总共40+23+15+8+14+28=128BIT，占16BYTES，下面再预留8BYTE，用于放系只写标志*)
(*2025.9.18.134744||伪随机中标志-占用一个位预留|niu.j*)
	xPseudoRandomTsting								: BIT;
	xFlag_PressDn_If								: BIT;
	xFlag_PressDn_Of								: BIT;
	xLinkage_If									: BIT;
	xLinkage_Of									: BIT;
//2025.11.14.151756|收放料调试中标bit5\bit6\bit7|新加一个BYTE继续用了bit0||7-1=6
	xFlag_AxisA_DebugRunning_Uw					: BIT;
	xFlag_AxisB_DebugRunning_Uw					: BIT;
	xFlag_AxisA_DebugRunning_Rw					: BIT;
	xFlag_AxisB_DebugRunning_Rw					: BIT;
//	xFlag_GrpRsv5								: BIT;
//	xFlag_GrpRsv6								: BIT;
//	xFlag_GrpRsv7								: BIT;
	
	xFlag_GrpRsv1								: BIT;
	xFlag_GrpRsv2								: BIT;
	xFlag_GrpRsv3								: BIT;
	xFlag_GrpRsv4								: BIT;
	xFlag_GrpRsv5								: BIT;
	xFlag_GrpRsv6								: BIT;
	xFlag_GrpRsv7								: BIT;
	
	abyFlag_GrpRsv								: ARRAY [1..6] OF BYTE;
END_STRUCT
END_TYPE

{IMPLEMENTATION}
