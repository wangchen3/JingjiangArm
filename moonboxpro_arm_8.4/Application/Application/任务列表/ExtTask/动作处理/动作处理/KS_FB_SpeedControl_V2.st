(*@CES
Name=KS_FB_SpeedControl_V2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=22870b27-c9f1-48dc-96b4-a19cd60d6746
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpeedControl_V2
VAR_INPUT
	i_xEn: BOOL;
	i_byAutoAccDecCurve:BYTE;(*2022.4.21.231635|
							默认 按照最大直线加速度进行s处理-总时间等于直线时间+平滑时间/2
						 	1：按照直线加速时间进行s处理-不限制最大加速度@总时间=直线时间
						 	2：按照直线加速时间进行s处理-限制最大加速度@总时间=直线时间
						 	3：按照直线加速时间全程s处理-@总时间=直线时间
							4: 和默认处理方式接近|@总时间=直线时间+平滑时间|2022.12.7.1704458
							5: 自动加速使用直线加速
							6: 取消s加速段，只保留s减速段|本次加减速时间是可以保证的
							7: s加速和减速保证位移一致@总时间=平滑时间+dv/i_uiMaxVel_UseCalcAcc*界面时间;平滑时间按照界面设置(s前+s后)
							8: s加速和减速保证位移一致@总时间=平滑时间+dv/i_uiMaxVel_UseCalcAcc*界面时间;平滑时间=总时间*系数
							9: s加速和减速保证位移一致@总时间=dv/i_uiMaxVel_UseCalcAcc*界面时间;平滑时间=总时间*系数*)


	i_iMsCycle_Motion: INT;(*运动周期|*)
	i_lrTimeSec_SBegin: LREAL := 30;(*S规划前半程时间|*)
	i_lrTimeSec_SEnd: LREAL := 30;(*S规划后半程时间|*)
	i_xReCalc_Target:BOOL;
	i_piTimeSec_AccDec_AllTheWay					: POINTER TO INT; (* S加减速时间 *)
	i_rVel_Max										: REAL; (* 最大速度 *)
	i_pxFlag_ArrivedToTargetVel						: POINTER TO BOOL; (* | *)
	i_rFinalVelocity								: REAL; (* 加减速末端速度 *)
	i_prVel_Cur										: POINTER TO REAL; (* 当前速度 *)
	i_prAccDecTime_ThisTime							: POINTER TO REAL; (* 本次加减速时间 *)
	i_xFlag_PTfifofull								: BOOL; (* 允许写PT使能 *)
	i_xFlag_ManuAcc									: BOOL; (* 手动加速标志 *)
	i_xFlag_ManuDec									: BOOL; (* 手动减速标志 *)
	i_xFlag_EStoping								: BOOL; (* 急停中标志 *)
	i_xFlag_Stoping									: BOOL; (* 停机中标志 *)
	i_pxFlag_Decing									: POINTER TO BOOL; (* 减速中 *)
	i_pxFlag_Accing									: POINTER TO BOOL; (* 加速中 *)
	i_xFlag_AutoAcc									: BOOL; (* 自动减速 *)
	i_xFlag_AutoDec									: BOOL; (* 自动减速 *)
	i_xFlag_InkAccing								: BOOL; (* 空转加速中 *)
	i_iIdGSE										: INT; (* 当前运行步骤 *)	
	i_xFlag_Print									: BOOL;
	i_xFlag_FastStoping								: BOOL;
	i_xFlag_Ink										: BOOL;
	(*i_apstStTravelLogRec: ARRAY [1..GC_LOG_CLASSES_MAX_NUM] OF POINTER TO StTravelLogRec; (* 2021.7.5.144816/ *)*)
(*	i_bySTime_AtLeast:BYTE;(*至少s加减速时间|默认10s*)*)(*需要删除|2023.03.02.112331*)
	i_rAux_enc_vel									: REAL;//虚拟主轴的速度//当速度到位标志触发时，直接将虚拟主轴速度给目标速度
	i_rGirth_Master: REAL;
	//2025.8.25.150143+ By Liu.yt
	i_uiMaxVel_UseCalcAcc:UINT;
	i_rSpeed_SCoeff_Type789:REAL:=0.666;
	i_xUseMaxTimeAsSBegin_InLowSpeed:BOOL;
	i_iTime_AutoAcc:INT;
	i_iTime_AutoDec:INT;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0.no error\-1.bad parameters\-2.bad lrVelMax&TimeAccDec|*)
	o_diVel_Virtual_Tar: DINT;
	o_lrMax_a_S_pos: LREAL;
	o_lrTime_S : LREAL;
	o_lrJerk_SBegin: LREAL;
	o_lrJerk_SEnd: LREAL;
END_VAR
VAR

	lrVel_delta: LREAL;(*速度变化量|*)
	lrJerk_SBegin: LREAL;
	lrJerk_SEnd: LREAL;
	lrAve_a: LREAL;(*全程平均加速度|*)
	lrMax_a_S: LREAL;(*S规划的最大加速度|*)
	iNum_InflectionPts: INT;
	//lrCurr_t: LREAL;(*当前时间|*)
	//lrPrev_t: LREAL;(*前次时间|*)
	xReqTestEndVelocity: BOOL;
	lrCurCycleVelVeries: LREAL;(*当前周期速度变化量|*)
	alrInflectionPts_t: ARRAY [1..2] OF LREAL:= [2(0)];(*时间轴上的拐点位置|*)

	xFlag_MotionParamInitialized: BOOL := FALSE;(*运动参数初始化标志|*)

	rMax_a_Coeff: REAL:=1.5;
	rS_AccDecTime_Coeff:REAL;(*S加减速时间-加速占的比例*)
	rAux_enc_vel_Temp:REAL;
	rTemp_Compera_Vel: REAL := 0.000016;
	fbTRIG_ArrivedTOtar: R_TRIG;
	lrFinalVelocity : LREAL;
	rAux_enc_vel : REAL;
	
	//2025.8.25.112406 同步
	
	(*2024.6.15.103803+注释*)
	rTimeSec_SBegin: REAL;(*保证位移一致的s前时间*)
	rTimeSec_SEnd: REAL;(*保证位移一致的s后时间*)
	rDistance_AccInc: REAL;(*加速过程的位移*)
	rDistance_AccDec: REAL;(*减速过程的位移*)
	rTime_Total: REAL;(*使用的总时间*)
	rTime_SmActual: REAL;(*s的总时间*)

(*	rAllTime:REAL;
	rSTime:REAL;*)
	byCalcType: BYTE;
	(*2025.2.10.112014 单位为s@Liu.yt*)
	rTimeSec_AccDec_AllTheWay_Use:REAL;(*2024.8.30.152530*)
	lrAccDecTime_ThisTime:LREAL;(*有些指针是LREAL*)
END_VAR
{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;

IF i_rGirth_Master=0 THEN
	i_rGirth_Master:= 0.5;
END_IF
IF i_rSpeed_SCoeff_Type789=0 THEN
	i_rSpeed_SCoeff_Type789:= 0.6667;
END_IF
IF i_xEn THEN
	IF i_iMsCycle_Motion>0 AND
		i_lrTimeSec_SBegin>0 AND
		i_lrTimeSec_SEnd>0 THEN
		IF i_uiMaxVel_UseCalcAcc=0 THEN
			i_uiMaxVel_UseCalcAcc:=100;
		END_IF
		//在这里处理速度到位清标志动作2023.8.17.210154

		IF NOT (i_piTimeSec_AccDec_AllTheWay^>0 AND i_rVel_Max>0) THEN
			o_iErNo:= -2;
			RETURN;
		END_IF
		fbTRIG_ArrivedTOtar(CLK:=i_pxFlag_ArrivedToTargetVel^);
		IF fbTRIG_ArrivedTOtar.Q THEN
			o_diVel_Virtual_Tar:= REAL_TO_DINT(ABS(i_rAux_enc_vel));
			o_lrMax_a_S_pos:= 1;
			o_lrTime_S:= 0;
		END_IF		
		IF i_pxFlag_ArrivedToTargetVel^ OR i_xReCalc_Target THEN(*速度到位|*)
			xFlag_MotionParamInitialized:= FALSE;
			o_iErNo:= -3;
			RETURN;
		END_IF

		
		IF NOT xFlag_MotionParamInitialized THEN(*未初始化就在这里初始化1次|*)
			xFlag_MotionParamInitialized:= TRUE;

			(*加速时间处理@2024.7.10.144615*)
			rTimeSec_AccDec_AllTheWay_Use:=i_piTimeSec_AccDec_AllTheWay^/10.0;



			(*平均加速度(m/min/s)|*)
(*			lrAve_a:= UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)(*i_pstStGrpParam^.lrVel_Max*)/INT_TO_LREAL(i_pstStGrpParam^.iTimeSec_AccDec_AllTheWay);*)
			lrAve_a:= UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)/(rTimeSec_AccDec_AllTheWay_Use);
			(*速度变化量|*)
			lrVel_delta:= i_rFinalVelocity-i_prVel_Cur^;

			IF lrVel_delta>0 THEN(*加速*)
				IF i_prVel_Cur^<9 AND(*开始的速度小于10m/min*)
					i_rFinalVelocity<=30 THEN(*目标速度小于30m/min切换*)
					IF i_byAutoAccDecCurve=4 OR
						i_byAutoAccDecCurve=7 OR
						i_byAutoAccDecCurve=8 THEN
						i_byAutoAccDecCurve:=0;(*使用默认方式*)
					END_IF
					IF rTimeSec_AccDec_AllTheWay_Use < 30 THEN(*加速时间太短了|限制最小值*)
						rTimeSec_AccDec_AllTheWay_Use:=30;
					END_IF
				END_IF
			END_IF
			
			
			(*按照平均加速度算出该段速度变化所需要的时间\
			/*由于时间是绝对量\不能出现负值|*)
			//i_prAccDecTime_ThisTime^:= ABS(lrVel_delta/lrAve_a);
			lrAccDecTime_ThisTime:= ABS(lrVel_delta/lrAve_a);

			IF lrVel_delta<0 THEN
				lrAve_a:= -lrAve_a;

			(*2018.11.26.184729|niu.j|判断如果10米印刷停机到10米空转时，
				当前速度等于目标速度导致有加速度计算，直接输出速度到位标志
				速度变化量为0时直接退出，防止rAccDecTime_ThisTime=0,导致除0*)
			ELSIF lrVel_delta=0 THEN
				i_pxFlag_ArrivedToTargetVel^:= TRUE;
				RETURN;
			ELSE;
			END_IF


			(*s加减速时间保证前后距离一致自动获取*)
			IF i_byAutoAccDecCurve=7 OR
				i_byAutoAccDecCurve=8 OR
				i_byAutoAccDecCurve=9 THEN
				
				IF i_byAutoAccDecCurve=7 THEN
					byCalcType:=1;(*总时间=平滑时间+dv/i_uiMaxVel_UseCalcAcc*界面时间;平滑时间按照界面设置*)
				ELSIF i_byAutoAccDecCurve=8 THEN
					byCalcType:=2;(*总时间=平滑时间+dv/i_uiMaxVel_UseCalcAcc*界面时间;平滑时间=总时间*系数*)
				ELSIF i_byAutoAccDecCurve=9 THEN
					byCalcType:=3;(*总时间=dv/i_uiMaxVel_UseCalcAcc*界面时间;平滑时间=总时间*系数*)
				ELSE
					byCalcType:=1;
				END_IF
				(*s时间占总时间的比例*)
				IF i_rSpeed_SCoeff_Type789=0 THEN
					i_rSpeed_SCoeff_Type789:=2.0/3.0;
				END_IF
				KS_GetSTime(
					byCalcType(*byCalcType*),
					i_rSpeed_SCoeff_Type789(*i_rSpeed_SCoeff*),
					LREAL_TO_INT(i_lrTimeSec_SBegin)(*i_iTimeSa_S*),
					LREAL_TO_INT(i_lrTimeSec_SEnd)(*i_iTimeEd_S*),
					i_iTime_AutoAcc(*i_iTime_Acc*),
					i_iTime_AutoDec(*i_iTime_Dec*),
					i_uiMaxVel_UseCalcAcc(*i_iVel_GetAcceleration*),
					i_prVel_Cur^(*i_rVel_Cur*),
					i_rFinalVelocity(*i_rVel_Tar*),
					ADR(rTimeSec_SBegin)(*i_prTimeSa_S*),
					ADR(rTimeSec_SEnd)(*i_prTimeEd_S*),
					ADR(rDistance_AccInc)(*i_prDis_Sa*),
					ADR(rDistance_AccDec)(*i_prDis_Ed*),
					ADR(rTime_Total)(*i_prTime_Total*),
					ADR(rTime_SmActual)(*i_prTime_SmActual*),
					ADR(lrAccDecTime_ThisTime));(*lrAccDecTime_ThisTime此时输出的直线加速的时间@下面会重新运算*)
			ELSE(*以前的方式*)
				rTimeSec_SBegin	:=	LREAL_TO_REAL(i_lrTimeSec_SBegin);
				rTimeSec_SEnd	:=	LREAL_TO_REAL(i_lrTimeSec_SEnd);
				(*2024.05.17.181512+*)
				(*s起始和结束时间做动态切换@原则是低速使用长的s时间规划*)
				IF i_xUseMaxTimeAsSBegin_InLowSpeed THEN
					IF lrAve_a>0 THEN(*加速*)
						rTimeSec_SBegin	:=	LREAL_TO_REAL(MAX(i_lrTimeSec_SBegin,i_lrTimeSec_SEnd));
						rTimeSec_SEnd	:=	LREAL_TO_REAL(MIN(i_lrTimeSec_SBegin,i_lrTimeSec_SEnd));
					ELSE(*减速*)
						rTimeSec_SBegin	:=	LREAL_TO_REAL(MIN(i_lrTimeSec_SBegin,i_lrTimeSec_SEnd));
						rTimeSec_SEnd	:=	LREAL_TO_REAL(MAX(i_lrTimeSec_SBegin,i_lrTimeSec_SEnd));
					END_IF
				END_IF
			END_IF

			rS_AccDecTime_Coeff:=rTimeSec_SBegin/(rTimeSec_SBegin+rTimeSec_SEnd);
			IF i_byAutoAccDecCurve=1 THEN(*按照直线加速时间进行s处理-不限制最大加速度*)
				//i_pstStGrpParam^.lrAccDecTime_ThisTime:= i_pstStGrpParam^.lrAccDecTime_ThisTime;

				IF lrAccDecTime_ThisTime>(rTimeSec_SBegin+rTimeSec_SEnd) THEN(*梯形|*)
					iNum_InflectionPts:= 2;
					(*平均加速度(m/min/s)|*)
					IF lrAccDecTime_ThisTime*2<>rTimeSec_SBegin+rTimeSec_SEnd THEN
						lrMax_a_S:= 2*lrVel_delta/(2*lrAccDecTime_ThisTime-rTimeSec_SBegin-rTimeSec_SEnd);
					END_IF

					lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
					alrInflectionPts_t[1]:= rTimeSec_SBegin;
					alrInflectionPts_t[2]:= lrAccDecTime_ThisTime-rTimeSec_SEnd;
				ELSE(*三角形*)
					iNum_InflectionPts:= 1;
					(*平均加速度(m/min/s)|*)
					IF lrAccDecTime_ThisTime<>0 THEN
						lrMax_a_S:= 2*lrVel_delta/(lrAccDecTime_ThisTime);
					END_IF

					alrInflectionPts_t[1]:= ABS(lrAccDecTime_ThisTime*(rS_AccDecTime_Coeff));
					alrInflectionPts_t[2]:= ABS(lrAccDecTime_ThisTime*(1-rS_AccDecTime_Coeff));
(*
					lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
					lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
*)
					rTimeSec_SBegin:= LREAL_TO_REAL(alrInflectionPts_t[1]);
					rTimeSec_SEnd:= LREAL_TO_REAL(alrInflectionPts_t[2]);
					lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
				END_IF
			ELSIF i_byAutoAccDecCurve=2 THEN(*按照直线加速时间进行s处理-限制最大加速度|这中情况下s加减速时间会变*)
				lrAccDecTime_ThisTime:= lrAccDecTime_ThisTime;
				(*在不修改s加减速时间计算最大平均加速度(m/min/s)|*)
				IF lrAccDecTime_ThisTime>(rTimeSec_SBegin+rTimeSec_SEnd) THEN(*梯形|*)
					IF lrAccDecTime_ThisTime*2>rTimeSec_SBegin+rTimeSec_SEnd THEN
						lrMax_a_S:= 2*lrVel_delta/(2*lrAccDecTime_ThisTime-rTimeSec_SBegin-rTimeSec_SEnd);
					END_IF
				ELSE
					(*重新计算平均加速度(m/min/s)|*)
					IF lrAccDecTime_ThisTime<>0 THEN
						lrMax_a_S:= 2*lrVel_delta/(lrAccDecTime_ThisTime);
					END_IF
				END_IF

				IF ABS(lrAve_a)*rMax_a_Coeff<ABS(lrMax_a_S) THEN(*超过了我限制的最大加速度-按照最大加速度处理
													我就需要重新计算s加减速时间*)
					lrMax_a_S:=lrAve_a*rMax_a_Coeff;(*最大加速度为直线加速度的倍数*)

					(*重新计算s时间*)
					rTimeSec_SBegin:=LREAL_TO_REAL(2*(lrAccDecTime_ThisTime-ABS(lrVel_delta/lrMax_a_S))*rS_AccDecTime_Coeff);
					rTimeSec_SEnd:=LREAL_TO_REAL(2*(lrAccDecTime_ThisTime-ABS(lrVel_delta/lrMax_a_S))*(1-rS_AccDecTime_Coeff));
				END_IF



				IF lrAccDecTime_ThisTime>(rTimeSec_SBegin+rTimeSec_SEnd) THEN(*梯形|*)
					iNum_InflectionPts:= 2;

					lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
					alrInflectionPts_t[1]:= rTimeSec_SBegin;
					alrInflectionPts_t[2]:= lrAccDecTime_ThisTime-rTimeSec_SEnd;
				ELSE(*三角形*)
					iNum_InflectionPts:= 1;

					alrInflectionPts_t[1]:= ABS(lrAccDecTime_ThisTime*(rS_AccDecTime_Coeff));
					alrInflectionPts_t[2]:= ABS(lrAccDecTime_ThisTime*(1-rS_AccDecTime_Coeff));
(*
					lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
					lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
*)
					rTimeSec_SBegin:= LREAL_TO_REAL(alrInflectionPts_t[1]);
					rTimeSec_SEnd:= LREAL_TO_REAL(alrInflectionPts_t[2]);
					lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
				END_IF

			ELSIF i_byAutoAccDecCurve=3 THEN(*按照直线加速时间全程s处理*)
				(*三角形*)
				iNum_InflectionPts:= 1;
				(*平均加速度(m/min/s)|*)
				IF lrAccDecTime_ThisTime<>0 THEN
					lrMax_a_S:= 2*lrVel_delta/(lrAccDecTime_ThisTime);
				END_IF

				alrInflectionPts_t[1]:= ABS(lrAccDecTime_ThisTime*(rS_AccDecTime_Coeff));
				alrInflectionPts_t[2]:= ABS(lrAccDecTime_ThisTime*(1-rS_AccDecTime_Coeff));
(*
				lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
				lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
*)
				rTimeSec_SBegin:= LREAL_TO_REAL(alrInflectionPts_t[1]);
				rTimeSec_SEnd:= LREAL_TO_REAL(alrInflectionPts_t[2]);
				lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
				lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;

			ELSIF i_byAutoAccDecCurve=4 OR(*强制在直线的基础时间上增加了s时间*)
					i_byAutoAccDecCurve=7 OR(*s是保证位移相等的@s按照界面设置*)
					i_byAutoAccDecCurve=8 OR(*s是保证位移相等的@s按照总时间的比例*)
					i_byAutoAccDecCurve=9 THEN(*s是保证位移相等的@保证总时间是直线计算的时间的*)
					
					iNum_InflectionPts:=2;(*还是使用T形方式|*)
					(*使用前后不同的S加速时间|2023.03.02.113109|*)
					lrMax_a_S:=2*lrVel_delta/(rTimeSec_SBegin+rTimeSec_SEnd+
								2*lrAccDecTime_ThisTime);

					lrAccDecTime_ThisTime:= lrAccDecTime_ThisTime+rTimeSec_SBegin+rTimeSec_SEnd;
					lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
					alrInflectionPts_t[1]:= rTimeSec_SBegin;
					alrInflectionPts_t[2]:= lrAccDecTime_ThisTime-rTimeSec_SEnd;
				
			ELSIF i_byAutoAccDecCurve=6 THEN(*取消s加速段，只保留s减速段|本次加减速时间是可以保证的*)
				//lrAccDecTime_ThisTime:= lrAccDecTime_ThisTime;

				IF lrAccDecTime_ThisTime>(rTimeSec_SEnd) THEN(*梯形|*)
					iNum_InflectionPts:= 2;
					(*平均加速度(m/min/s)|*)
					lrMax_a_S:= 2*lrVel_delta/(2*lrAccDecTime_ThisTime-rTimeSec_SEnd);

					lrJerk_SBegin:=0;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
					alrInflectionPts_t[1]:= 0;
					alrInflectionPts_t[2]:= lrAccDecTime_ThisTime-rTimeSec_SEnd;
				ELSE(*三角形*)
					iNum_InflectionPts:= 1;
					(*平均加速度(m/min/s)|*)
					IF lrAccDecTime_ThisTime<>0 THEN
						lrMax_a_S:= 2*lrVel_delta/(lrAccDecTime_ThisTime);
					END_IF

					alrInflectionPts_t[1]:= 0;
					alrInflectionPts_t[2]:= 0;
					rTimeSec_SBegin:=0;
					rTimeSec_SEnd:= LREAL_TO_REAL(lrAccDecTime_ThisTime);
					lrJerk_SBegin:= 0;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
				END_IF
			ELSE(*默认*)
				(*平均加速度(m/min/s)|*)
				IF lrAccDecTime_ThisTime*2>(rTimeSec_SBegin+rTimeSec_SEnd) THEN(*梯形|*)
					iNum_InflectionPts:= 2;
					lrAccDecTime_ThisTime:= lrAccDecTime_ThisTime+rTimeSec_SBegin/2+rTimeSec_SEnd/2;
					lrMax_a_S:= lrAve_a;
					lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
					alrInflectionPts_t[1]:= rTimeSec_SBegin;
					alrInflectionPts_t[2]:= lrAccDecTime_ThisTime-rTimeSec_SEnd;
				ELSE(*三角形*)
					iNum_InflectionPts:= 1;
					lrAccDecTime_ThisTime:= lrAccDecTime_ThisTime*2;
					lrMax_a_S:= lrAve_a;
					alrInflectionPts_t[1]:= lrAccDecTime_ThisTime/2;
					alrInflectionPts_t[2]:= lrAccDecTime_ThisTime/2;
					rTimeSec_SBegin:= LREAL_TO_REAL(alrInflectionPts_t[1]);
					rTimeSec_SEnd:= LREAL_TO_REAL(alrInflectionPts_t[2]);
					lrJerk_SBegin:= lrMax_a_S/rTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/rTimeSec_SEnd;
				END_IF
			END_IF
			
			i_prAccDecTime_ThisTime^:= LREAL_TO_REAL(lrAccDecTime_ThisTime);//写入到输出
			
			IF i_xFlag_ManuDec OR i_xFlag_EStoping(*2023.08.28.193725*)
				OR i_xFlag_Stoping OR
				i_xFlag_FastStoping OR(*手动减速和急停/停机/快速停止中采用直线减速|*)
				(*2023.3.2.164553 空转自动减速也使用直线减速*)
				(i_xFlag_AutoDec AND (i_xflag_ink OR i_byAutoAccDecCurve=5)) THEN
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
					o_lrMax_a_S_pos:= lrAve_a*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0;
					o_lrTime_S := 0;
					o_lrJerk_SBegin:= 0;
					o_lrJerk_SEnd:= 0;
			ELSIF i_xFlag_ManuAcc OR
				i_xFlag_InkAccing OR(*手动加速/空转加速用手动直线加速|*)
				(*2023.3.2.164553 空转自动加速使用直线加速*)
				(i_xFlag_AutoAcc AND (i_xflag_ink OR i_byAutoAccDecCurve=5)) THEN
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
					o_lrMax_a_S_pos:= lrAve_a*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0;
					o_lrTime_S := 0;
					o_lrJerk_SBegin:= 0;
					o_lrJerk_SEnd:= 0;
					
			ELSIF i_xFlag_AutoAcc  OR(*自动加速或空转加速|*)
				i_xFlag_AutoDec THEN(*自动减速或默认停机|*)	
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
					o_lrMax_a_S_pos:= lrMax_a_S*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0;
					o_lrTime_S := alrInflectionPts_t[1];
					o_lrJerk_SBegin:= lrJerk_SBegin*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0/1000.0;
					o_lrJerk_SEnd:= lrJerk_SEnd*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0/1000.0;					
			END_IF
		END_IF

		rAux_enc_vel_Temp:= LREAL_TO_REAL(ABS(i_rAux_enc_vel)*1000.0*60.0*i_rGirth_Master/GC_LRMOTORPPR);
		i_prVel_Cur^:= rAux_enc_vel_Temp;
		rAux_enc_vel:= ABS(i_rAux_enc_vel);
		lrFinalVelocity := LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);

		IF i_iIdGSE=GSE_ACCING OR
			i_iIdGSE=GSE_DECING THEN

			IF i_xFlag_ManuDec OR i_xFlag_EStoping
				OR i_xFlag_Stoping OR
				i_xFlag_FastStoping OR(*手动减速和急停/停机/快速停止中采用直线减速|*)
				(*2023.3.2.164553 空转自动减速也使用直线减速*)
				(i_xFlag_AutoDec AND (i_xflag_ink OR i_byAutoAccDecCurve=5)) THEN
				lrCurCycleVelVeries:= lrAve_a*(INT_TO_LREAL(i_iMsCycle_Motion)/1000);
				IF rAux_enc_vel > lrFinalVelocity + rTemp_Compera_Vel(*i_prVel_Cur^>i_rFinalVelocity+rTemp_Compera_Vel*) THEN
					i_pxFlag_Decing^:= TRUE;
					i_pxFlag_Accing^:= FALSE;
				ELSE
					i_pxFlag_Decing^:= FALSE;
					i_pxFlag_Accing^:= FALSE;
					i_prVel_Cur^:= i_rFinalVelocity;
//2023.8.17.213343到目标速度后，把目标速度再设置一次-为了防止手自动加速过程中停下并且速度同步
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
					i_pxFlag_ArrivedToTargetVel^:= TRUE;
				END_IF
			(*2018.10.5.133955 | niu.j | 空转加速采用直线加速*)
			ELSIF i_xFlag_ManuAcc OR
				i_xFlag_InkAccing OR(*手动加速/空转加速用手动直线加速|*)
				(*2023.3.2.164553 空转自动加速使用直线加速*)
				(i_xFlag_AutoAcc AND (i_xflag_ink OR i_byAutoAccDecCurve=5)) THEN

				IF rAux_enc_vel < lrFinalVelocity-rTemp_Compera_Vel(*i_prVel_Cur^<i_rFinalVelocity-rTemp_Compera_Vel *)THEN
					i_pxFlag_Decing^:= FALSE;
					i_pxFlag_Accing^:= TRUE;
				ELSE
					i_pxFlag_Decing^:= FALSE;
					i_pxFlag_Accing^:= FALSE;
					i_prVel_Cur^:= i_rFinalVelocity;
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);					
					i_pxFlag_ArrivedToTargetVel^:= TRUE;
				END_IF
			ELSIF i_xFlag_AutoAcc  OR(*自动加速或空转加速|*)
				i_xFlag_AutoDec THEN(*自动减速或默认停机|*)
				IF (((i_xFlag_AutoAcc OR i_xFlag_InkAccing) AND
						rAux_enc_vel < lrFinalVelocity-rTemp_Compera_Vel) (*i_prVel_Cur^<i_rFinalVelocity-rTemp_Compera_Vel) *)OR
					((i_xFlag_AutoDec OR i_xFlag_Stoping OR i_xFlag_FastStoping) AND
						rAux_enc_vel > lrFinalVelocity+rTemp_Compera_Vel))(*i_prVel_Cur^>i_rFinalVelocity+rTemp_Compera_Vel)) *)THEN

					IF i_xFlag_AutoAcc OR i_xFlag_InkAccing THEN
						i_pxFlag_Accing^:= TRUE;
						i_pxFlag_Decing^:= FALSE;
					ELSE
						i_pxFlag_Accing^:= FALSE;
						i_pxFlag_Decing^:= TRUE;
					END_IF
				ELSE
					i_pxFlag_Decing^:= FALSE;
					i_pxFlag_Accing^:= FALSE;
					i_pxFlag_ArrivedToTargetVel^:= TRUE;
					(*2018.8.15.095720 :| niu.j | 到目标速度后，当前速度赋值为目标速度*)
					i_prVel_Cur^:= i_rFinalVelocity;
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
				END_IF				
			END_IF
			
		END_IF
		
	ELSE
		o_iErNo:= -1;(*Bad parameters|*)
	END_IF
ELSE;
END_IF