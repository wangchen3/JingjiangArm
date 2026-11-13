(*@CES
Name=KS_FB_SpeedControl_2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3721ed5a-e7f4-4c95-a3b8-3e53b0c929eb
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_SpeedControl_2(*先用这个吧，后面再整理2025.6.12.174817*)
(*变化速度的时候置1次xFlag_ArrivedToTargetVel为TRUE就可以了|*)
(*2022.10.27.164825 修改了第4中速度控制方式未在本次时间基础上前后各加s*)
(*2022.10.27.162617调整|在小于S加减速时间的情况下
						使用本次时间+前后i_bySTime_AtLeast时间的s||2022.12.7.170426*)
(*王宁涛处理了前后s分开问题@2023.3.2.210705*)
(*在空转时候自动加减速修改为了手动方式|Liu.yt@2023.3.2.210734*)
VAR_INPUT
	i_xEn: BOOL;
	i_byAutoAccDecCurve:BYTE;(*2022.4.21.231635|
							默认 按照最大直线加速度进行s处理-
						 	1：按照直线加速时间进行s处理-不限制最大加速度
						 	2：按照直线加速时间进行s处理-限制最大加速度
						 	3：按照直线加速时间全程s处理-
							4: 和默认处理方式接近|使用本次时间+前后i_bySTime_AtLeast时间的s|2022.12.7.170445*)
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
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;(*0.no error\-1.bad parameters\-2.bad lrVelMax&TimeAccDec|*)
	o_diVel_Virtual_Tar: DINT;
	o_lrMax_a_S_pos: LREAL;
	o_lrTime_S : LREAL;
END_VAR
VAR

	lrVel_delta: LREAL;(*速度变化量|*)
	lrJerk_SBegin: LREAL;
	lrJerk_SEnd: LREAL;
	lrAve_a: LREAL;(*全程平均加速度|*)
	lrMax_a_S: LREAL;(*S规划的最大加速度|*)
	iNum_InflectionPts: INT;
	lrCurr_t: LREAL;(*当前时间|*)
	lrPrev_t: LREAL;(*前次时间|*)
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
END_VAR
{IMPLEMENTATION}
o_xEno:= i_xEn;
o_iErNo:= 0;
(*
IF i_bySTime_AtLeast=0 THEN
	i_bySTime_AtLeast:=10;
END_IF
*)
IF i_rGirth_Master=0 THEN
	i_rGirth_Master:= 0.5;
END_IF
IF i_xEn THEN
	IF 
		i_iMsCycle_Motion>0 AND
		i_lrTimeSec_SBegin>0 AND
		i_lrTimeSec_SEnd>0 THEN
		//在这里处理速度到位清标志动作2023.8.17.210154

		IF NOT (i_piTimeSec_AccDec_AllTheWay^(*i_pstStGrpParam^.iTimeSec_AccDec_AllTheWay*)>0 
			AND (*i_pstStGrpParam^.lrVel_Max*)i_rVel_Max>0) THEN
			o_iErNo:= -2;
			RETURN;
		END_IF
		fbTRIG_ArrivedTOtar(CLK:=i_pxFlag_ArrivedToTargetVel^);
		IF fbTRIG_ArrivedTOtar.Q THEN
			o_diVel_Virtual_Tar:= REAL_TO_DINT(ABS(i_rAux_enc_vel));
			o_lrMax_a_S_pos:= 1;
			o_lrTime_S:= 0;
		END_IF		
		IF (*i_pstStGrpParam^.xFlag_ArrivedToTargetVel*)i_pxFlag_ArrivedToTargetVel^ OR i_xReCalc_Target THEN(*速度到位|*)
			xFlag_MotionParamInitialized:= FALSE;
			o_iErNo:= -3;
			RETURN;
		END_IF

		
		IF NOT xFlag_MotionParamInitialized THEN(*未初始化就在这里初始化1次|*)
			xFlag_MotionParamInitialized:= TRUE;
			(*平均加速度(m/min/s)|*)
			lrAve_a:= (*i_pstStGrpParam^.l*)i_rVel_Max/INT_TO_LREAL(i_piTimeSec_AccDec_AllTheWay^);
			(*速度变化量|*)
			lrVel_delta:= (*i_pstStGrpParam^.lrFinalVelocity*)i_rFinalVelocity-i_prVel_Cur^(*i_pstStGrpParam^.lrVel_Cur*);

			(*按照平均加速度算出该段速度变化所需要的时间\
			/*由于时间是绝对量\不能出现负值|*)
(*			i_pstStGrpParam^.lrAccDecTime_ThisTime*)
			i_prAccDecTime_ThisTime^:= LREAL_TO_REAL(ABS(lrVel_delta/lrAve_a));

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
			(*2022.4.21.163408 增加了自动加减速曲线选择|*)
			(*自动加减速曲线选择|默认 按照最大直线加速度进行s处理-
									 1：按照直线加速时间进行s处理-不限制最大加速度
									 2：按照直线加速时间进行s处理-限制最大加速度
									 3：按照直线加速时间全程s处理-
									 4: 和默认处理方式接近|增加了至少10s的s加减速处理|2022.8.9.091924*)
			rS_AccDecTime_Coeff:= LREAL_TO_REAL(i_lrTimeSec_SBegin/(i_lrTimeSec_SBegin+i_lrTimeSec_SEnd));
			IF i_byAutoAccDecCurve=1 THEN(*按照直线加速时间进行s处理-不限制最大加速度*)
				i_prAccDecTime_ThisTime^:= i_prAccDecTime_ThisTime^;

				IF i_prAccDecTime_ThisTime^>(i_lrTimeSec_SBegin+i_lrTimeSec_SEnd) THEN(*梯形|*)
					iNum_InflectionPts:= 2;
					(*平均加速度(m/min/s)|*)
					IF i_prAccDecTime_ThisTime^*2<>i_lrTimeSec_SBegin+i_lrTimeSec_SEnd THEN
						lrMax_a_S:= 2*lrVel_delta/(2*i_prAccDecTime_ThisTime^-i_lrTimeSec_SBegin-i_lrTimeSec_SEnd);
					END_IF

					lrJerk_SBegin:= lrMax_a_S/i_lrTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/i_lrTimeSec_SEnd;
					alrInflectionPts_t[1]:= i_lrTimeSec_SBegin;
					alrInflectionPts_t[2]:= i_prAccDecTime_ThisTime^-i_lrTimeSec_SEnd;
				ELSE(*三角形*)
					iNum_InflectionPts:= 1;
					(*平均加速度(m/min/s)|*)
					IF i_prAccDecTime_ThisTime^<>0 THEN
						lrMax_a_S:= 2*lrVel_delta/(i_prAccDecTime_ThisTime^);
					END_IF

					alrInflectionPts_t[1]:= ABS(i_prAccDecTime_ThisTime^*(rS_AccDecTime_Coeff));
					alrInflectionPts_t[2]:= ABS(i_prAccDecTime_ThisTime^*(1-rS_AccDecTime_Coeff));
					lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
					lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
				END_IF
				
			ELSIF i_byAutoAccDecCurve=2 THEN(*按照直线加速时间进行s处理-限制最大加速度|这中情况下s加减速时间会变*)
				i_prAccDecTime_ThisTime^:= i_prAccDecTime_ThisTime^;
				(*在不修改s加减速时间计算最大平均加速度(m/min/s)|*)
				IF i_prAccDecTime_ThisTime^>(i_lrTimeSec_SBegin+i_lrTimeSec_SEnd) THEN(*梯形|*)
					IF i_prAccDecTime_ThisTime^*2>i_lrTimeSec_SBegin+i_lrTimeSec_SEnd THEN
						lrMax_a_S:= 2*lrVel_delta/(2*i_prAccDecTime_ThisTime^-i_lrTimeSec_SBegin-i_lrTimeSec_SEnd);
					END_IF
				ELSE
					(*重新计算平均加速度(m/min/s)|*)
					IF i_prAccDecTime_ThisTime^<>0 THEN
						lrMax_a_S:= 2*lrVel_delta/(i_prAccDecTime_ThisTime^);
					END_IF
				END_IF

				IF ABS(lrAve_a)*rMax_a_Coeff<ABS(lrMax_a_S) THEN(*超过了我限制的最大加速度-按照最大加速度处理
													我就需要重新计算s加减速时间*)
					lrMax_a_S:=lrAve_a*rMax_a_Coeff;(*最大加速度为直线加速度的倍数*)

					(*重新计算s时间*)
					i_lrTimeSec_SBegin:=2*(i_prAccDecTime_ThisTime^-ABS(lrVel_delta/lrMax_a_S))*rS_AccDecTime_Coeff;
					i_lrTimeSec_SEnd:=2*(i_prAccDecTime_ThisTime^-ABS(lrVel_delta/lrMax_a_S))*(1-rS_AccDecTime_Coeff);
				END_IF



				IF i_prAccDecTime_ThisTime^>(i_lrTimeSec_SBegin+i_lrTimeSec_SEnd) THEN(*梯形|*)
					iNum_InflectionPts:= 2;

					lrJerk_SBegin:= lrMax_a_S/i_lrTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/i_lrTimeSec_SEnd;
					alrInflectionPts_t[1]:= i_lrTimeSec_SBegin;
					alrInflectionPts_t[2]:= i_prAccDecTime_ThisTime^-i_lrTimeSec_SEnd;
				ELSE(*三角形*)
					iNum_InflectionPts:= 1;

					alrInflectionPts_t[1]:= ABS(i_prAccDecTime_ThisTime^*(rS_AccDecTime_Coeff));
					alrInflectionPts_t[2]:= ABS(i_prAccDecTime_ThisTime^*(1-rS_AccDecTime_Coeff));
					lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
					lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
				END_IF
				
			ELSIF i_byAutoAccDecCurve=3 THEN(*按照直线加速时间全程s处理*)
				(*三角形*)
				iNum_InflectionPts:= 1;
				(*平均加速度(m/min/s)|*)
				IF i_prAccDecTime_ThisTime^<>0 THEN
					lrMax_a_S:= 2*lrVel_delta/(i_prAccDecTime_ThisTime^);
				END_IF

				alrInflectionPts_t[1]:= ABS(i_prAccDecTime_ThisTime^*(rS_AccDecTime_Coeff));
				alrInflectionPts_t[2]:= ABS(i_prAccDecTime_ThisTime^*(1-rS_AccDecTime_Coeff));
				lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
				lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
			ELSIF i_byAutoAccDecCurve=4 THEN(*和默认处理方式接近|增加了至少10s的s加减速处理|2022.8.9.091924*)
				IF i_xFlag_Print THEN(*增加印刷标志|印刷状态和空转匀墨使用不同加速逻辑|2022.11.06.104252*)
					(*屏蔽之前前后加相等时间的S曲线加速方式|改为前后加不同时间的方式|2023.03.02.112443*)
					(*
						iNum_InflectionPts:=2;(*还是使用T形方式|本次时间前后+i_bySTime_AtLeast时间s*)
						lrMax_a_S:= lrAve_a*i_pstStGrpParam^.lrAccDecTime_ThisTime/(i_pstStGrpParam^.lrAccDecTime_ThisTime+i_bySTime_AtLeast);(*计算最大的加速度*)
	
						i_pstStGrpParam^.lrAccDecTime_ThisTime:= i_pstStGrpParam^.lrAccDecTime_ThisTime+i_bySTime_AtLeast*2;
						lrJerk_SBegin:= lrMax_a_S/i_bySTime_AtLeast;
						lrJerk_SEnd:= lrMax_a_S/i_bySTime_AtLeast;
						alrInflectionPts_t[1]:= i_bySTime_AtLeast;
						alrInflectionPts_t[2]:= i_pstStGrpParam^.lrAccDecTime_ThisTime-i_bySTime_AtLeast;
	(*2022.12.7.170336@liu
					END_IF
	*)
					*)
						iNum_InflectionPts:=2;(*还是使用T形方式|*)
						(*使用前后不同的S加速时间|2023.03.02.113109|*)
						lrMax_a_S:=2*lrVel_delta/(i_lrTimeSec_SBegin+i_lrTimeSec_SEnd+
									2*i_prAccDecTime_ThisTime^);

						i_prAccDecTime_ThisTime^:= LREAL_TO_REAL(i_prAccDecTime_ThisTime^+i_lrTimeSec_SBegin+i_lrTimeSec_SEnd);
						lrJerk_SBegin:= lrMax_a_S/i_lrTimeSec_SBegin;
						lrJerk_SEnd:= lrMax_a_S/i_lrTimeSec_SEnd;
						alrInflectionPts_t[1]:= i_lrTimeSec_SBegin;
						alrInflectionPts_t[2]:= i_prAccDecTime_ThisTime^-i_lrTimeSec_SEnd;
				ELSE(*使用默认加速方式|2022.11.06.104353*)
					(*平均加速度(m/min/s)|*)
					IF i_prAccDecTime_ThisTime^*2>(i_lrTimeSec_SBegin+i_lrTimeSec_SEnd) THEN(*梯形|*)
						iNum_InflectionPts:= 2;
						i_prAccDecTime_ThisTime^:= LREAL_TO_REAL(i_prAccDecTime_ThisTime^+i_lrTimeSec_SBegin/2.0+i_lrTimeSec_SEnd/2.0);
						lrMax_a_S:= lrAve_a;
						lrJerk_SBegin:= lrMax_a_S/i_lrTimeSec_SBegin;
						lrJerk_SEnd:= lrMax_a_S/i_lrTimeSec_SEnd;
						alrInflectionPts_t[1]:= i_lrTimeSec_SBegin;
						alrInflectionPts_t[2]:= i_prAccDecTime_ThisTime^-i_lrTimeSec_SEnd;
					ELSE(*三角形*)
						iNum_InflectionPts:= 1;
						i_prAccDecTime_ThisTime^:= i_prAccDecTime_ThisTime^*2;
						lrMax_a_S:= lrAve_a;
						alrInflectionPts_t[1]:= i_prAccDecTime_ThisTime^/2;
						alrInflectionPts_t[2]:= i_prAccDecTime_ThisTime^/2;
						lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
						lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
					END_IF
				END_IF
				
			ELSE(*默认*)
				(*平均加速度(m/min/s)|*)
				IF i_prAccDecTime_ThisTime^*2>(i_lrTimeSec_SBegin+i_lrTimeSec_SEnd) THEN(*梯形|*)
					iNum_InflectionPts:= 2;
					i_prAccDecTime_ThisTime^:= LREAL_TO_REAL(i_prAccDecTime_ThisTime^+i_lrTimeSec_SBegin/2.0+i_lrTimeSec_SEnd/2.0);
					lrMax_a_S:= lrAve_a;
					lrJerk_SBegin:= lrMax_a_S/i_lrTimeSec_SBegin;
					lrJerk_SEnd:= lrMax_a_S/i_lrTimeSec_SEnd;
					alrInflectionPts_t[1]:= i_lrTimeSec_SBegin;
					alrInflectionPts_t[2]:= i_prAccDecTime_ThisTime^-i_lrTimeSec_SEnd;
				ELSE(*三角形*)
					iNum_InflectionPts:= 1;
					i_prAccDecTime_ThisTime^:= i_prAccDecTime_ThisTime^*2;
					lrMax_a_S:= lrAve_a;
					alrInflectionPts_t[1]:= i_prAccDecTime_ThisTime^/2;
					alrInflectionPts_t[2]:= i_prAccDecTime_ThisTime^/2;
					lrJerk_SBegin:= lrMax_a_S/alrInflectionPts_t[1];
					lrJerk_SEnd:= lrMax_a_S/alrInflectionPts_t[2];
				END_IF
			END_IF

			lrCurr_t:= 0;
			lrPrev_t:= 0;
			//2023.8.17.210752在这里输出一下目标速度和加速度减速度
			//o_iVel_Virtual_Tar:= REAL_TO_INT(i_rFinalVelocity*GC_LRMOTORPPR/1.5/60.0/1000.0);
			//o_lrMax_a_S_pos:= lrMax_a_S*GC_LRMOTORPPR/60.0/1000.0/1000.0;
(*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			IF i_xFlag_ManuDec OR i_xFlag_EStoping(*2023.08.28.193725*)
				OR i_xFlag_Stoping OR
				i_xFlag_FastStoping THEN(* OR(*手动减速和急停/停机/快速停止中采用直线减速|*)
				(*2023.3.2.164553 空转自动减速也使用直线减速*)
				(i_xFlag_AutoDec AND i_xflag_ink) THEN*)
					o_iVel_Virtual_Tar:= REAL_TO_INT(i_rFinalVelocity*GC_LRMOTORPPR/1.5/60.0/1000.0);
					o_lrMax_a_S_pos:= lrAve_a*GC_LRMOTORPPR/1.5/60.0/1000.0/1000.0;
					o_lrTime_S := 0;
			ELSIF i_xFlag_ManuAcc OR
				i_xFlag_InkAccing (*OR(*手动加速/空转加速用手动直线加速|*)
				(*2023.3.2.164553 空转自动加速使用直线加速*)
				(i_xFlag_AutoAcc AND i_xflag_ink)*) THEN
					o_iVel_Virtual_Tar:= REAL_TO_INT(i_rFinalVelocity*GC_LRMOTORPPR/1.5/60.0/1000.0);
					o_lrMax_a_S_pos:= lrAve_a*GC_LRMOTORPPR/1.5/60.0/1000.0/1000.0;
					o_lrTime_S := 0;
			ELSIF i_xFlag_AutoAcc  OR(*自动加速或空转加速|*)
				i_xFlag_AutoDec OR (*2023.3.2.164553 空转自动减速也使用直线减速*)
				(i_xFlag_AutoDec AND i_xflag_ink) THEN(*自动减速或默认停机|*)	
					o_iVel_Virtual_Tar:= REAL_TO_INT(i_rFinalVelocity*GC_LRMOTORPPR/1.5/60.0/1000.0);
					o_lrMax_a_S_pos:= lrMax_a_S*GC_LRMOTORPPR/1.5/60.0/1000.0/1000.0;
					o_lrTime_S := alrInflectionPts_t[1];
			END_IF
*)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//2023.10.19.142926
			IF i_xFlag_ManuDec OR i_xFlag_EStoping(*2023.08.28.193725*)
				OR i_xFlag_Stoping OR
				i_xFlag_FastStoping OR(*手动减速和急停/停机/快速停止中采用直线减速|*)
				(*2023.3.2.164553 空转自动减速也使用直线减速*)
				(i_xFlag_AutoDec AND (i_xflag_ink OR i_byAutoAccDecCurve=5)) THEN
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
					o_lrMax_a_S_pos:= lrAve_a*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0;
					o_lrTime_S := 0;
			ELSIF i_xFlag_ManuAcc OR
				i_xFlag_InkAccing OR(*手动加速/空转加速用手动直线加速|*)
				(*2023.3.2.164553 空转自动加速使用直线加速*)
				(i_xFlag_AutoAcc AND (i_xflag_ink OR i_byAutoAccDecCurve=5)) THEN
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
					o_lrMax_a_S_pos:= lrAve_a*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0;
					o_lrTime_S := 0;
			ELSIF i_xFlag_AutoAcc  OR(*自动加速或空转加速|*)
				i_xFlag_AutoDec THEN(*自动减速或默认停机|*)	
					o_diVel_Virtual_Tar:= LREAL_TO_DINT(i_rFinalVelocity*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0);
					o_lrMax_a_S_pos:= lrMax_a_S*GC_LRMOTORPPR/i_rGirth_Master/60.0/1000.0/1000.0;
					o_lrTime_S := alrInflectionPts_t[1];
			END_IF
		END_IF
//bai.zy | 2024.01.16.103002 | 重新判断标志

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
END_IF

