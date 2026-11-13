(*@CES
Name=KS_FB_GrpUserActionCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=28236d52-8909-437b-95a9-a6f46f9e83ee
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_GrpUserActionCtrl
VAR_INPUT
	i_xEn:BOOL;
	i_iGrpId								: INT;
	i_iCustomerName							: INT;
	i_pastStIOMap_Main_FE					: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|`````````````````````````````````````````````*)
	i_pastStIOMap_Axis_Extra_FE				: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_Extra_FE;
	i_pstStIOMap_UwRw_FE_Uw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|*)
	i_pstStIOMap_UwRw_FE_Rw					: POINTER TO ARRAY [1..2] OF StIOMap_UwRw_FE;(*轴io数据区域|*)	
	i_iIOGrpIdx_Uw: INT := 1;(*放料组id|*)
	i_iIOGrpIdx_Rw: INT := 1;(*收料组id|*)
	i_iAxisId_If			: INT 						:= -1;(*放牵轴id|*)
	i_iAxisId_Of			: INT 						:= -1;(*收牵轴id|*)
	i_pstStEvtReq: POINTER TO StEvtReq;(*按钮输入操作及边沿触发描述|*)	
	i_xInverterAlarm: BOOL;
	i_xBrakeFilm:BOOL;
	i_xLostPressure							: BOOL;(*气压低报警|不允许开机*)	
	i_xPrnRollerLoose_AtLeast1				: BOOL;(*至少一色夹板松报警|不允许开机*)	
	i_xNeedEstop_BrakeAlarm					: BOOL;(*制动电阻报警急停|2022.5.11.112758*)	
	i_paxCommVel_Sure: POINTER TO ARRAY [1..2,1..3] OF BOOL;(*2019.10.21.095108|常用速度123按钮*)	
	i_xFalg_ExhaustEn: BOOL;
	i_prVel_Tar_HMI: POINTER TO REAL;
	i_pxTapPosition_Breaking		: POINTER TO BOOL;
	i_pxTapPosition_Printing		: POINTER TO BOOL;
	i_pxTapPosition_UniformInk		: POINTER TO BOOL;	
	i_pxAutoAccDec_Hmi				: POINTER TO BOOL;
	i_arVel_CommonlyUsed			: ARRAY [1..3] OF REAL;	
	i_xFalg_ExhaustLimitStart: BOOL;
	i_rVel_Cur					: REAL;
	i_rVel_Ink					: REAL;(*空运转速度*)
	i_xFlag_TensionDone:BOOL;
	i_xFlag_TensionUnfinished:BOOL;
	i_xFlag_LinkageAxisAlarm:BOOL;
	i_uiMaxVel_UseCalcAcc: UINT;
	i_pxFlag_KeepAlarming: POINTER TO BOOL;
	i_iTime_Stop: INT;
	i_iTime_FastStop: INT;
	i_iTime_Estop: INT;
	i_iTime_AutoAcc: INT;
	i_iTime_AutoDec: INT;
	i_iTime_ManuAcc: INT;
	i_iTime_ManuDec: INT;
	i_xFilmAccDecDone: BOOL;
	i_byAutoAccDecCurve: BYTE;
	i_iTime_S:INT;
	i_iTime_S_End: INT;
	i_rVel_Max: REAL;
	i_prAccDecTime_ThisTime: POINTER TO REAL;
	i_rAux_enc_vel: REAL;
//	i_pxFlag_FilmAccDecDone							: POINTER TO BOOL; (* 料膜加速完成标志 *)
//	i_uiMaxVel_UseCalcAcc: uint;
	i_xUseMaxTimeAsSBegin_InLowSpeed: BOOL;
	i_rSpeed_SCoeff_Type789: REAL;
	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
	o_xSpeedHigh: BOOL;(*2019.6.14.094543|niu.j|输出速度过高不允许印刷*)
	o_byActionCtlWay: BYTE;(*动作流程选择
							|0:预启动--空转--张力投入--印刷--空转--停机
							|1:预启动--空转--停机;预启动--张力投入--印刷(速度为0)--停机*)
	o_xFlag_FastStoppBtnDn: BOOL;(*2022.4.13.154907 快停被按下了*)
	o_xTips_ExhausLimitStart: BOOL;(*2022.5.21.102417*)
	(*2022.6.28.151929*)
	o_xTowerInvAlarm_Uw					: BOOL;
	o_xTowerInvAlarm_Rw					: BOOL;
	
	o_iIdGSE								: INT;(*状态!*)
	o_xFlag_Stop							: BOOL;(*停机标志*)
	o_xFlag_PreStart						: BOOL;(*预启动标志|从停机状态按(预)启动置位标志 色组速度达到空转速度清o_xFlag_PreStart标志,置位o_xFlag_Ink标志;当o_xFlag_Print标志有效后,*)
	o_xFlag_PreStart_Print					: BOOL;(*印刷预启动标志|用于华丰逻辑变量*)
	o_xFlag_Ink								: BOOL;(*匀墨标志|>20m/min不能联动*)
	o_xFlag_InkAccing						: BOOL;(*匀墨加速中<指0~10m/min那个加速过程>*)
	o_xFlag_Tension							: BOOL;(*张力投入标志|张力投入有效时收放料变频开始起作用|收放料就位后按印刷按钮,牵引压辊合压|o_xFlag_Print有效时张力投入不处理*)
	o_xFlag_Print							: BOOL;(*张力拉料标志有效时，按联动或印刷按钮 先压收牵(延时2s)再压放牵 印刷标志|印刷色组根据联动标志按用户指定的压辊顺序逐一延时压胶辊|胶辊压合完毕后才可置该标志有效|*)
	o_xFlag_Estop							: BOOL;(*急停标志|和停机一样要减速到0，只不过减速时间是急停时间*)
	o_xFlag_AutoAcc							: BOOL;(*自动加速*)
	o_xFlag_AutoDec							: BOOL;(*自动减速*)
	o_xFlag_ManuAcc							: BOOL;(*手动加速*)
	o_xFlag_ManuDec							: BOOL;(*手动减速*)
	o_xFlag_Accing							: BOOL;(*加速中*)
	o_xFlag_Decing							: BOOL;(*减速中*)
	o_xFlag_EStoping						: BOOL;(*正在急停中*)
	o_xFlag_Stoping							: BOOL;(*停机中*)
	o_xFlag_FastStoping						: BOOL;(*快速停机中*)
	o_xLinkage_IfOf_Ink						: BOOL;
	(*o_xFlag_GotoInking						: BOOL;(*转到匀墨*)*)
	o_xTensionNotFinish						: BOOL;(*按下印刷按钮张力投入未完成输出*)
	o_xToPrintVelTooHigh					: BOOL;(*进入印刷状态时速度太高了*)
	o_rFinalVelocity						: REAL;(*目标速度*)
	o_iTimeSec_AccDec_AllTheWay				: INT;(*全程加减速所需要的秒|*)
	(*2025.2.10.110905+ 单位修改了0.1s@急停的时候需要更短*)
	o_iTimeSec_AccDec_AllTheWay_0_1s		: INT;(*输出时间单位为0.1s*)
	o_xVel_Tar_OverRange					: BOOL;(*目标速度超限值|2019.10.28.102337*)	
	o_xFlag_ArrivedToTargetVel				: BOOL;
	o_diVel_Virtual_Tar: dINT;
	o_lrMax_a_S_pos: LREAL;	
	o_lrTime_S : LREAL;
	o_lrJerk_SBegin: LREAL;
	o_lrJerk_SEnd: LREAL;
//	o_rVel_Film: REAL;
	o_rVel_PrnRoller								: REAL;(* 版辊运行速度*)
	o_rVel_NetRoller								: REAL;(* 网辊运行速度*)
	o_rVel_BottomRoller								: REAL;(* 底辊运行速度*)
	o_rVel_Cur_HMI									: REAL;(* 当前屏显速度 *)		
END_VAR
VAR
	xBtnInk: BOOL;(*空转*)
	xBtnPrint: BOOL;(*印刷*)
	xBtnTension: BOOL;(*张力投入*)
	xBtnManuAcc: BOOL;(*手动加速*)
	xBtnManuDec: BOOL;(*手动减速*)
	xBtnAutoAccOrDec: BOOL;(*自动加减速*)
	xBtnStop: BOOL;(*停止*)
	xBtnFastStop: BOOL;(*快速停止|2022.4.9.235219*)
	xBtnEstop: BOOL;(*急停*)	
	lrVel_Tar: LREAL;
	axNeedRstTrig_AutoAccOrDec: ARRAY [1..3] OF BOOL;	
	xLastFlag_Stop: BOOL;
	xLastFlag_Ink: BOOL;
	xLastFlag_TensionUnFinished: BOOL;(*2022.11.30.093132*)
	bySpecialProcess:BYTE:=0;(*2022.5.29.001333*)	
	tmHold_PreStart: TIME := T#3S; (* 开机预启动持续时间| 2022.5.27.143829*)	
	byStates: BYTE;(*2023.09.21.143746 增加*)	
	fbTon_Timming: TON;(*2023.12.16.155301*)	
	fbKS_FB_StdActionCtl: KS_FB_StdActionCtl;
(*	fbKS_FB_SpeedControl: KS_FB_SpeedControl_2;	*)
	fbKS_FB_SpeedControl_V2: KS_FB_SpeedControl_V2;
	
(*	fbKS_FB_FilmSpdCtrl: KS_FB_FilmSpdCtrl;*)
	lrServoMotorRatedVel: LREAL;(*伺服电机额定转速可以达到的线速度|*)	
	axFlag_PreStart: ARRAY [1..2] OF BOOL;
	xReCalc_Target: BOOL;	
	xVel_Tar_OverRange: BOOL;	
	xChangeSts_To_Ink: BOOL;
	xChangeSts_To_Prn: BOOL;	
END_VAR
VAR_IN_OUT
	io_xMotionEnabled: BOOL;(*|2021.1.15.092801 速度控制块使能修改为输入输出变量|这里处理该值的复位*)
END_VAR
{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
IF i_xEn THEN
	(*1.限速处理稍后再算*)
	
	(*2.先处理按钮动作*)
	KS_ActionBtnDeal(
		i_iGrpId,(*i_iGrpId,*)
		i_pstStEvtReq,(*i_pstStEvtReq:= , *)
		ADR(o_byActionCtlWay),(*i_pbyActionCtlWay:= , *)
		ADR(xBtnInk),(*i_pxBtnInk:= ,*) 
		ADR(xBtnPrint),(*i_pxBtnPrint:= ,*) 
		ADR(xBtnTension),(*i_pxBtnTension:= ,*) 
		ADR(xBtnManuAcc),(*i_pxBtnManuAcc:= ,*) 
		ADR(xBtnManuDec),(*i_pxBtnManuDec:= ,*) 
		ADR(xBtnAutoAccOrDec),(*i_pxBtnAutoAccOrDec:= ,*) 
		ADR(xBtnStop),(*i_pxBtnStop:= ,*) 
		ADR(xBtnFastStop),(*i_pxBtnFastStop:= ,*) 
		ADR(xBtnEstop),(*i_pxBtnEstop:= ,*) 
		ADR(lrVel_Tar),(*i_plrVel_Tar:= ,*) 
		i_xInverterAlarm,(*i_xInverterAlarm:= ,*) 
		i_xBrakeFilm,(*i_xBrakeFilm:= ,*) 
		i_xLostPressure,(*i_xLostPressure:= ,*) 
		i_xPrnRollerLoose_AtLeast1,(*i_xPrnRollerLoose_AtLeast1:= ,*) 
		i_xNeedEstop_BrakeAlarm,(*i_xNeedEstop_BrakeAlarm:= ,*) 
		i_paxCommVel_Sure,(*i_paxCommVel_Sure:= ,*) 
		ADR(axNeedRstTrig_AutoAccOrDec),(*i_paxNeedRstTrig_AutoAccOrDec:= ,*) 
		ADR(xLastFlag_Stop),(*i_pxLastFlag_Stop:= ,*) 
		ADR(xLastFlag_Ink),(*i_pxLastFlag_Ink:= ,*) 
		ADR(xLastFlag_TensionUnFinished),(*i_pxLastFlag_TensionUnFinished:= ,*) 
		i_xFalg_ExhaustEn,(*i_xFalg_ExhaustEn:= ,*) 
		ADR(o_xFlag_FastStoppBtnDn),(*i_pxFastStopBtnDn:= ,*) 
		ADR(o_xTips_ExhausLimitStart),(*i_pxTips_ExhausLimitStart:= ,*) 
		ADR(bySpecialProcess),(*i_pbySpecialProcess:= ,*) 
		ADR(tmHold_PreStart),(*i_ptmHold_PreStart:= ,*) 
		gc_tmHold_PreStart_BeiRen,(*i_tmHold_PreStart_BeiRen:= ,*) 
		gc_tmAlarmHold_PreStart,(*i_tmAlarmHold_PreStart:= ,*) 
		ADR(byStates),(*i_pbyStates:= ,*) 
		ADR(fbTon_Timming),(*i_pfbTon:= ,*) 
		i_iCustomerName,(*i_iCustomerName:= ,*) 
		ADR(o_xLinkage_IfOf_Ink),(*i_pxLinkage_IfOf_Ink:= ,*) 
		i_prVel_Tar_HMI,(*i_prVel_Tar_HMI:= ,*) 
		i_pxTapPosition_Breaking , 
		i_pxTapPosition_Printing , 
		i_pxTapPosition_UniformInk, 
		i_pxAutoAccDec_Hmi, 
		i_arVel_CommonlyUsed, 
		i_xFalg_ExhaustLimitStart, 
		i_rVel_Ink,(*i_rVel_Ink:= ,*) 
		o_xFlag_Stop,(*i_xFlag_Stop:= , *)
		o_xFlag_Estop,(*i_xFlag_Estop:= ,*) 
		o_xFlag_Ink,(*i_xFlag_Ink:= ,*) 
		o_xFlag_Print,(*i_xFlag_Print:= ,*) 
		o_xFlag_InkAccing,(*i_xFlag_InkAccing:= ,*) 
		o_xFlag_Stoping,(*i_xFlag_Stoping:= ,*) 
		o_xFlag_EStoping,(*i_xFlag_EStoping:= ,*) 
		o_xFlag_Tension,(*i_xFlag_Tension:= ,*) 
		i_xFlag_TensionDone, 
		i_xFlag_TensionUnfinished, 
		i_xFlag_LinkageAxisAlarm, 
		i_rVel_Cur,(*i_rVel_Cur:= ,*) 
		o_xFlag_AutoAcc,(*i_xFlag_AutoDec:= ,*) 
		o_xFlag_AutoDec,(*i_xFlag_AutoAcc:= ,*) 
		o_xFlag_Accing,(*i_xFlag_Accing:= ,*) 
		o_xFlag_Decing,(*i_xFlag_Decing:= *)
		io_xMotionEnabled,
		ADR(xChangeSts_To_Ink),
		ADR(xChangeSts_To_Prn));
		

	fbKS_FB_StdActionCtl(
		i_xEn:= TRUE,
		i_byActionCtlWay:= o_byActionCtlWay,
		i_xBtnInk:= xBtnInk,
		i_xBtnPrint:= xBtnPrint ,
		i_xBtnTension:= xBtnTension,
		i_xBtnManuAcc:= xBtnManuAcc ,
		i_xBtnManuDec:= xBtnManuDec ,
		i_xBtnAutoAccOrDec:=  xBtnAutoAccOrDec,
		i_xBtnStop:=  xBtnStop,
		i_xBtnFastStop:=  xBtnFaststop,
		i_xBtnEstop:=  xBtnEstop,

		i_xTensionDne:= i_xFlag_TensionDone,
		i_lrVel_Cur:= i_rVel_Cur,
		i_lrVel_Max:= i_rVel_Max,//lrServoMotorRatedVel,		//bai.zy | TEST_ 临时使用 |此处应该是电机最高转速对应的最大速度lrServoMotorRatedVel,
		i_lrVel_Tar:= lrVel_Tar(*i_pstStGrpParam^.lrVel_Tar*) ,
		i_lrVel_Ink:= i_rVel_Ink,
		i_iTime_Ink:= UINT_TO_INT(i_uiMaxVel_UseCalcAcc/5),(*2024.04.12.173848 空转加速时间*)
		i_iTime_Stop:= i_iTime_Stop,
		i_iTime_FastStop:= i_iTime_FastStop,
		(*2025.2.8.162629*)
		i_iTime_Estop:= i_iTime_Estop,
		i_iTime_AutoAcc:= i_iTime_AutoAcc,
		i_iTime_AutoDec:= i_iTime_AutoDec,
		i_iTime_ManuAcc:= i_iTime_ManuAcc,
		i_iTime_ManuDec:= i_iTime_ManuDec,
		i_pxFlag_ArrivedToTargetVel:= ADR(o_xFlag_ArrivedToTargetVel),
		i_pxFlag_KeepAlarming:= i_pxFlag_KeepAlarming,
		i_xFilmAccFinish:= i_xFilmAccDecDone,(*2019.10.08.104841|niu.j|新增料膜加速完成标志*)
		(*2022.5.29.000637*)
		i_tmHold_PreStart:=tmHold_PreStart, (* 开机预启动持续时间| 2022.5.27.143829*)
		i_bySpecialProcess:=bySpecialProcess,(*在基础的开机流程上增加了特殊开机方式切换标志|0:按照基础的|
																						   |1:北人的*)
		i_xBtnInk_BeiRen:=i_pstStEvtReq^.xEvt_Ink,(*空转按钮-专为北人使用|和基础流程的空转按钮定义不同|2022.5.28.234758*)
		i_xEstopTimeIsActTime:=FALSE,(*2025.2.8.163238 不做切换了,就直接修改为输入时间是实际急停时间*)
		i_uiMaxVel_UseCalcAcc:=i_uiMaxVel_UseCalcAcc,
		i_xEstopTimeIsToMaxVel:=TRUE,(*2025.2.13.131137  急停时间是到达最大速度的时间*)
		o_xEn=> ,
		o_iIdGSE=>o_iIdGSE ,
		o_xFlag_Stop=> o_xFlag_Stop,
		o_xFlag_PreStart=> axFlag_PreStart[1],
		o_xFlag_PreStart_Print=> axFlag_PreStart[2],
		o_xFlag_Ink=> o_xFlag_Ink,
		o_xFlag_InkAccing=> o_xFlag_InkAccing,
		o_xFlag_Tension=> o_xFlag_Tension,
		o_xFlag_Print=> o_xFlag_Print,
		o_xFlag_Estop=> o_xFlag_Estop,
		o_xFlag_AutoAcc=> o_xFlag_AutoAcc,
		o_xFlag_AutoDec=> o_xFlag_AutoDec,
		o_xFlag_ManuAcc=> o_xFlag_ManuAcc,
		o_xFlag_ManuDec=> o_xFlag_ManuDec,
		o_xFlag_Accing=> o_xFlag_Accing,
		o_xFlag_Decing=> o_xFlag_Decing,
		o_xFlag_EStoping=> o_xFlag_EStoping,
		o_xFlag_Stoping=> o_xFlag_Stoping,
		o_xFlag_FastStoping=> o_xFlag_FastStoping,
(*			o_xFlag_GotoInking=> i_pstStGrpParam^.xFlag_GotoInking,*)
		o_xTensionNotFinish=> o_xTensionNotFinish,
		o_xReCalc_Target=> xReCalc_Target,
		o_xToPrintVelTooHigh=>o_xSpeedHigh,
		o_rFinalVelocity=> o_rFinalVelocity,
		o_iTimeSec_AccDec_AllTheWay=>,
		(*2025.2.10.113946 按照0.1s单位输出*)
		o_iTimeSec_AccDec_AllTheWay_0_1s=>o_iTimeSec_AccDec_AllTheWay_0_1s,
		o_xVel_Tar_OverRange=>xVel_Tar_OverRange );		
	(*速度功能块处理*)
		o_xFlag_PreStart_Print:= axFlag_PreStart[2];
	IF i_iTime_S= 0 THEN
		i_iTime_S:= 30;
	END_IF
	IF i_iTime_S_End=0 THEN
		i_iTime_S_End:=30;
	END_IF
fbKS_FB_SpeedControl_V2(
		i_xEn:= io_xMotionEnabled, 
		i_byAutoAccDecCurve:= i_byAutoAccDecCurve, 
		i_iMsCycle_Motion:= gc_EXT_TSK_CYCLE_TIME, 
		i_lrTimeSec_SBegin:= INT_TO_LREAL(i_iTime_S), 
		i_lrTimeSec_SEnd:= INT_TO_LREAL(i_iTime_S_End), 
		i_xReCalc_Target:= xReCalc_Target, 
		i_piTimeSec_AccDec_AllTheWay:= ADR(o_iTimeSec_AccDec_AllTheWay_0_1s),  
		i_rVel_Max:= i_rVel_Max, 
		i_pxFlag_ArrivedToTargetVel:= ADR(o_xFlag_ArrivedToTargetVel), 
		i_rFinalVelocity:= LREAL_TO_REAL(o_rFinalVelocity),
		i_prVel_Cur:= ADR(i_rVel_Cur), 
		i_prAccDecTime_ThisTime:= i_prAccDecTime_ThisTime, 
		i_xFlag_PTfifofull:= FALSE, 
		i_xFlag_ManuAcc:= o_xFlag_ManuAcc, 
		i_xFlag_ManuDec:= o_xFlag_ManuDec, 
		i_xFlag_EStoping:= o_xFlag_EStoping, 
		i_xFlag_Stoping:= o_xFlag_Stoping, 
		i_pxFlag_Decing:= ADR(o_xFlag_Decing), 
		i_pxFlag_Accing:= ADR(o_xFlag_Accing), 
		i_xFlag_AutoAcc:= o_xFlag_AutoAcc, 
		i_xFlag_AutoDec:= o_xFlag_AutoDec, 
		i_xFlag_InkAccing:= o_xFlag_InkAccing, 
		i_iIdGSE:= o_iIdGSE, 
		i_xFlag_Print:= o_xFlag_Print, 
		i_xFlag_FastStoping:= o_xFlag_FastStoping, 
		i_xFlag_Ink:= o_xFlag_Ink, 
		i_rAux_enc_vel:= i_rAux_enc_vel, 
		i_rGirth_Master:= gc_rGirth_Master, 
		i_uiMaxVel_UseCalcAcc:= i_uiMaxVel_UseCalcAcc, 
		i_rSpeed_SCoeff_Type789:= i_rSpeed_SCoeff_Type789, 
		i_xUseMaxTimeAsSBegin_InLowSpeed:= i_xUseMaxTimeAsSBegin_InLowSpeed, 
		i_iTime_AutoAcc:= i_iTime_AutoAcc, 
		i_iTime_AutoDec:= i_iTime_AutoDec, 
		o_xEno=> , 
		o_iErNo=> , 
		o_diVel_Virtual_Tar=> o_diVel_Virtual_Tar, 
		o_lrMax_a_S_pos=> o_lrMax_a_S_pos, 
		o_lrTime_S=> o_lrTime_S, 
		o_lrJerk_SBegin=> o_lrJerk_SBegin, 
		o_lrJerk_SEnd=> o_lrJerk_SEnd
	);	
(*
	fbKS_FB_SpeedControl(
		i_xEn:= io_xMotionEnabled, 
		i_byAutoAccDecCurve:= i_byAutoAccDecCurve, 
		i_iMsCycle_Motion:= gc_EXT_TSK_CYCLE_TIME, 
		i_lrTimeSec_SBegin:= INT_TO_LREAL(i_iTime_S), 
		i_lrTimeSec_SEnd:= INT_TO_LREAL(i_iTime_S_End), 
		i_xReCalc_Target:= xReCalc_Target, 
		i_piTimeSec_AccDec_AllTheWay:= ADR(o_iTimeSec_AccDec_AllTheWay_0_1s), 
		i_rVel_Max:= i_rVel_Max, 
		i_pxFlag_ArrivedToTargetVel:= ADR(o_xFlag_ArrivedToTargetVel), 
		i_rFinalVelocity:= LREAL_TO_REAL(o_lrFinalVelocity), 
		i_prVel_Cur:= ADR(i_rVel_Cur), 
		i_prAccDecTime_ThisTime:= i_prAccDecTime_ThisTime, 
		i_xFlag_PTfifofull:= FALSE, 
		i_xFlag_ManuAcc:= o_xFlag_ManuAcc, 
		i_xFlag_ManuDec:= o_xFlag_ManuDec, 
		i_xFlag_EStoping:= o_xFlag_EStoping, 
		i_xFlag_Stoping:= o_xFlag_Stoping, 
		i_pxFlag_Decing:= ADR(o_xFlag_Decing), 
		i_pxFlag_Accing:= ADR(o_xFlag_Accing), 
		i_xFlag_AutoAcc:= o_xFlag_AutoAcc, 
		i_xFlag_AutoDec:= o_xFlag_AutoDec, 
		i_xFlag_InkAccing:= o_xFlag_InkAccing, 
		i_iIdGSE:= o_iIdGSE, 
		i_xFlag_Print:= o_xFlag_Print, 
		i_xFlag_FastStoping:= o_xFlag_FastStoping, 
		i_xFlag_Ink:= o_xFlag_Ink, 
		i_rAux_enc_vel:= i_rAux_enc_vel,
		i_rGirth_Master:= gc_rGirth_Master,
		o_xEno=> , 
		o_iErNo=> ,
		o_diVel_Virtual_Tar=> o_diVel_Virtual_Tar,
		o_lrMax_a_S_pos=> o_lrMax_a_S_pos,
		o_lrTime_S => o_lrTime_S);		
*)
	//o_rVel_PrnRoller:= o_rVel_Film;//
	//2025.08.07.113103 | bai.zy | TEST_ 临时测试
	o_rVel_PrnRoller:= i_rVel_Cur;
	//o_rVel_BottomRoller:= o_rVel_Film;

	o_rVel_NetRoller:= i_rVel_Cur;
	//o_rVel_BottomRoller:= i_pstStSysParam^.rVel_Film;
	//2025.08.07.113103 | bai.zy | TEST_ 临时测试
	o_rVel_Cur_HMI:= i_rVel_Cur;(* 需要新增 2021.11.6.144801 *)
	//o_rVel_Cur_HMI:= o_rVel_Film;(* 需要新增 2021.11.6.144801 *)
		
	(*直接调用速度处理|*)
	IF io_xMotionEnabled THEN
		IF (o_xFlag_Stop OR
			o_xFlag_Estop )AND
			i_rVel_Cur=0 THEN
			io_xMotionEnabled:=FALSE;
		END_IF
	END_IF				
ELSE
	;
END_IF