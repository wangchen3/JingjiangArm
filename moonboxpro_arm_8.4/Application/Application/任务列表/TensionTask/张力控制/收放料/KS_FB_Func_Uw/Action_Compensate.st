(*@CES
Name=Action_Compensate
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=6081e771-64c0-4a2a-94af-7751f0e66993
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*卷径估计逻辑-张力补偿*)
(*2021.8.26.164715 卷径部分重新处理|包括张力补偿转速----------------------------------START*)
(*在轴切换逻辑中需要增加赋值语句|别忘了！！！！！！！！！！！！*)

(*放料卷径估计函数执行-2021.8.26.154549*)
xFilmToBig:=FALSE;
IF  i_xMachineRev THEN
	xFilmToBig:=TRUE;
END_IF

(*增加卷径估计使能标志|防止单色时压辊频繁抬起压下引起的计算异常|2022.7.25.160135*)
IF i_xFlag_Print AND
	(xFlag_RollerPressAtLeast1_In ) AND(*2022.5.19.204101修改为至少合压1色启用*)
	(NOT i_xIsDebugMode) AND
	i_rVel_Film>=10 THEN(*速度超过10m/min计算@2023.09.04.142056*)
	xCalcEstValueEn:=TRUE;
ELSIF xCalcEstValueEn THEN
	IF i_xIsDebugMode OR
		NOT i_xFlag_Print THEN
		xCalcEstValueEn:=FALSE;
	END_IF
END_IF

(*2023.09.22.173934*)
(*接料时候将rVel_CalcVolt_Uw更新为轴速度@它会滞后一个周期赋值-接料时候影响较大*)
IF xFlag_Cut_end_Out THEN
	rVel_CalcVolt:=	o_rVelRPM_Cur;
END_IF


(*2024.01.02.113504 同步*)
(*2023.12.25.210309 接料使能跟踪第一色--------------------START*)
IF xUseFollow_1U_V_UwCut_In THEN(*使用裁切时候跟踪第一色方法*)
	IF xFlag_Cut_end_Out THEN
		xFlag_Follow_1U_V_UwCut_In_Out:=TRUE;
	END_IF
ELSE
	xFlag_Follow_1U_V_UwCut_In_Out:=FALSE;
END_IF

IF byMeters_UseFollow_1U_V_UwCut_In_Out=0 THEN
	byMeters_UseFollow_1U_V_UwCut_In_Out:=100;
END_IF
IF i_rVel_Film<>0 THEN
	uiTime_UseFollow_1U_V_UwCut:=
			LREAL_TO_UINT(
			BYTE_TO_LREAL(byMeters_UseFollow_1U_V_UwCut_In_Out)/i_rVel_Film*60);
ELSE
	uiTime_UseFollow_1U_V_UwCut:=60;
END_IF

fbTon_UseFollow_1U_UwCut(IN:=xFlag_Follow_1U_V_UwCut_In_Out,
						PT:=DWORD_TO_TIME(UINT_TO_DWORD(uiTime_UseFollow_1U_V_UwCut)*1000));
IF fbTon_UseFollow_1U_UwCut.Q THEN(*时间到@xFlag_Follow_1U_V_UwCut 保持一定时间*)
	xFlag_Follow_1U_V_UwCut_In_Out:=FALSE;
END_IF

(*2023.12.25.210309 接料使能跟踪第一色--------------------END*)

fbKS_FB_EstimationByVel(
	i_xEn:= xCalcEstValueEn,(*2022.7.25.160645 调整*)
	i_xFilmToBig:=xFilmToBig,(*卷径变小方向*)
	i_rFeedBack:= i_rAI_Swing,
	i_rVel_rpm:= rVel_CalcVolt,
	i_rVel_mpm:= i_rVel_Film,
	i_xCutDne:= xFlag_Cut_end_Out,
	(*该变量只在接料时候使用|在前面的逻辑会在接料时候将新卷卷径值和当前卷径值交换|
	所以这里去当前卷径值-其实是接料前的新卷卷径*)
	i_rNewDia:= io_rDiamCurAxis,
	(*2023.6.25.095127 修改了变量*)
	i_uiMaxDia:= uiMaxDia_In,
	i_uiInitDiam:= uiInitDiam_In,
	(*2023.6.19.144957 默认使用每次计算初始卷径的方式@Liu.yt*)
	i_xTypeGetInitDiam:=NOT xTypeGetInitDiam_In,(*卷径估计参数传入|2023.06.12.124419*)
	(*2024.01.02.111906  同步*)
	i_rInitThickNess:=0.02,(*取一个常规值@2023.12.15.234821*)
	i_rInitThickNess_Cut:=rEstiThickness_In_Out,(*使用接料前的值@2023.12.15.234821*)
	i_rPara_R:=100,
	i_iCycleTime_Plc:= i_iCycleTime_Plc,
	io_rEstDia:= rEstiDia_In_Out,
	o_rEstThickness=> rEstiThickness_In_Out);
	

(*放料卷径增加低通@2024.05.11.161204*)
(*低通一直运算*)
rWc_LowPass:=rWc_LowPass_Diam_In;(*复用为了放料低通截止频率*)
IF xFlag_Cut_end_Out OR(*裁切标志|初始化*)
	xDiamWr_Manu OR(*手动写入就不要低通了*)
	xDiamRegInit_Lp THEN(*初始化*)
	arUk_LowPass[1]:=rEstiDia_In_Out;
	arUk_LowPass[2]:=rEstiDia_In_Out;
	arYk_LowPass[1]:=rEstiDia_In_Out;
	arYk_LowPass[2]:=rEstiDia_In_Out;
END_IF
xDiamRegInit_Lp:=FALSE;

LowPass(
	rEstiDia_In_Out(*i_rInput*),
	ADR(rEstiDia_LowPass)(*i_prOutput*),
	ADR(arUk_LowPass)(*i_parUk*),
	ADR(arYk_LowPass)(*i_parYk*),
	rWc_LowPass(*i_rWc*),
	i_iCycleTime_Plc);


(*START-----@2023.12.02.094421*)
(*使用放料的估计厚度值进行自动运算*)
(*2023.12.02.090252 对使用的料膜厚度值进行计算@通过估计厚度自动计算或者手动输入*)
IF	i_xFlag_Print AND
	(NOT i_xIsDebugMode) AND
	i_rVel_Film>=100 AND
	(NOT(i_xFlag_Accing OR
	i_xFlag_Decing))THEN(*匀速中*)
	xGetFilmThicknessEn:=TRUE;
ELSIF xGetFilmThicknessEn THEN
	IF NOT i_xFlag_Print OR(*退出印刷状态才能清除使能标志重新开始*)
		NOT xThicknessAutoGetDne THEN(*没完成就重新开始@如果完成了就保持之前的不需要重新计算*)
		xGetFilmThicknessEn:=FALSE;
	END_IF
END_IF

(*接料时候还要特殊处理@此时的波动比较大*)
IF xFlag_Cut_end_Out THEN(*裁切完成-如果没计算完成则复位*)
	IF NOT xThicknessAutoGetDne THEN
		xGetFilmThicknessEn:=FALSE;(*初始化运算数据*)
	END_IF
END_IF

KS_GetFilmThickNessByEstDiaFunc(
		xGetFilmThicknessEn(*i_xGetFilmThicknessEn*),
		xGetFilmThickNessAuto_In(*i_xGetFilmThickNessAuto*),
		5(*i_byWaitTime_Min*),(*写长点为了保证接料后能足够稳定*)
		2(*i_byContinuousTime_Min*),
		5(*i_byShakeThreshold*),
		xDiaEstEn(*i_xEstiThikcknessValid*),
		rEstiThickness_In_Out(*i_rEstiThickness*),
		0.02,(*i_rThickness_Init*)(*2024.03.16.101838+*)
		ADR(xThicknessAutoGetDne)(*i_pxAutoGetDne*),
		ADR(rFilmThickNess_Using_In_Out)(*i_prThickness*),
		ADR(rTotalThickness)(*i_prTotalThickness*),
		ADR(udiTotalNum)(*i_pudiTotalNum*),
		ADR(rThickness_Max)(*i_prThickness_Max*),
		ADR(rThickness_Min)(*i_prThickness_Min*),
		ADR(tLastTime_AutoGetThikcness)(*i_ptLastTime*));
(*END-----*)
(*将卷径计算逻辑移动到这里--CALCDIA|2021.8.26.163627*)
IF xInitDiameter THEN(*下面的功能块卷径是输入输出变量|故开机需要初始化一下*)
	xInitDiameter:=FALSE;
	rDiameterTmp:= io_rDiamCurAxis;
	rLastDia_Cur:= io_rDiamCurAxis;
END_IF

(*上面逻辑会对当前卷径值进行交换更新|必须同步更新卷径临时变量才能保证正常切换*)
IF xFlag_Cut_end_Out THEN(*裁切完成|更新卷径临时变量*)
	rDiameterTmp:= io_rDiamCurAxis;
END_IF


(*需要屏蔽下面的卷径计算功能块|*)
fbKS_FB_CalcDiamOfFilmVol((*2020.4.20.172051|避免调试模式下压下胶辊造成计算卷径不正确|*)
	i_xEnable:= (NOT i_xIsDebugMode)
				AND i_xFlag_Print
				AND (NOT i_xFlag_EStoping)
				AND (NOT i_xFlag_Stoping)
				AND (NOT i_xFlag_FastStoping)
				AND xFlag_RollerPressAtLeast1_In,
	i_lrFilmVelocity:= i_rVel_Film,
	i_lrUnWind_Velocity:= rVel_CalcVolt,(*2023.09.11.122305*)
	i_lrWind_Velocity:= 0(*pstStGrpParam^.lrVel_Rw*),
	i_lrAlarm_Diameter:= rDiamAlarm_In,
	i_xUnWind_CutFinished:= xFlag_Cut_end_Out,
	i_xWind_CutFinished:= FALSE,
	i_CycleTime:= i_iCycleTime_Plc,
	i_xRollerPress_Uw:= xOutput_CutCylinder,
	i_xMachineRev:= i_xMachineRev,
	(*2021.8.26.173642 增加 用于控制报警铃输出*)
	i_rDiaAcT_Uw:= io_rDiamCurAxis,
	i_rDiaAcT_Rw:= ,
	(*修改为临时变量|2021.8.26.163843*)
	rUnWind_Diameter:= rDiameterTmp,
	rWind_Diameter:= rNull,
	o_xEno=> xEnFlag_CalcDiam_Ret,(*将i_xEn的条件拿到|*)
	o_iErNo=> ,
	o_xFlag_AlarmDiameter=> xFlag_VolDiamAlarm_Out );



(*2024.02.27.130302 恢复*)
(*2024.01.20.114508 移动到了PRG_USERFUNC中执行*)
(*2023.12.21.104426 增加没料报警切换逻辑*)
IF byAlarmType_NoMaterial_In=0 THEN(*保持之前的3s报警@不做处理*)
	xKeepAlarm_NoMaterial_In_Out:=FALSE;(*长报警标志复位*)
ELSIF byAlarmType_NoMaterial_In=1 THEN(*没料后一直报警*)
	fbKS_FB_KeepAlarm_NoMaterial(
		i_xEn:=i_xEn ,
		i_xFlag_VolDiamAlarm:= xFlag_VolDiamAlarm_Out ,
		i_xBtnStopAlarm:=  i_xEstop_Input OR
							i_xStop_Input OR
							i_pstStEvtReq^.xEvt_PreCut OR
							i_pstStEvtReq^.xEvt_CutCancel OR
							i_pstStEvtReq^.xEvt_Cut OR
							i_pstStEvtReq^.xEvt_Forward OR 
							i_pstStEvtReq^.xEvt_Reversal OR
							(*2023.3.28.103943增加了裁切完成后停止响铃@自动接料可能会不清除报警标志
							手按的时候直接清除，如果自动接料，就一直响*)
							xFlag_Cut_end_Out,
		o_xEn=> ,
		o_xKeepAlarm_NoMaterial=>xKeepAlarm_NoMaterial_In_Out );
END_IF

	


(*放料*)
io_rDiamCurAxis:=rDiameterTmp;(*默认取原来方式计算的卷径值*)
rMainVel:=0;(*主速度清零*)
(*如果使用牵引速度作为放料跟随速度直接修改下个变量*)
(*2021.9.16.164726 使用料膜速度*)

(*2024.8.21.172921 按钮切换*)
IF 	xUseFeedVel_In THEN
	rVelTmp:=rVel_Feed_In;
ELSE
	rVelTmp:=i_rVel_Film;
END_IF
xAccDecingCompensateEn:=xFilmAccDecDone_In;
xDiaEstEn:=xDiaEstEn_In;(*
			AND pstStGrpParam^.xFlag_RollerPressDne;(*2022.5.19.205810|全部合压完成才使用卷径估计的值*)*)
(*可以使用卷径速度补偿值|2021.10.8.150130*)
(*2021.10.25.164758 |启用速度条件修改到>40m/min*)

(*2024.01.02.125017同步*)
(*2023.12.12.112818将补偿的速度起始条件做成变量*)
(*	xCanDiaCompensate_Uw:=pstStGrpParam^.lrVel_Film>=40 AND pstStGrpParam^.xFlag_RollerPressDne ;*)
IF byVelSa_DiamCompensate_In_Out=0 THEN(*不补偿*)
	(*强制修改为40@2024.01.25.111419*)
	byVelSa_DiamCompensate_In_Out:=40;
(*		xCanDiaCompensate_Uw:=FALSE;*)
ELSE
	(*限制最小值为40*)
(*取消了限制@2024.05.14.173041*)
(*		IF pstStGrpParam^.byVelSa_DiamCompensate_Uw<40 THEN
		pstStGrpParam^.byVelSa_DiamCompensate_Uw:=40;
	END_IF*)
	xCanDiaCompensate:=i_rVel_Film>=byVelSa_DiamCompensate_In_Out AND xFlag_RollerPressDne_In ;
END_IF

(*2022.6.18.122511*)
IF byDelayTime_DiaCompensateWhenCutDne_In_Out=0 THEN
	byDelayTime_DiaCompensateWhenCutDne_In_Out:=10;
END_IF
IF xDiaEstEn THEN(*放料使用预估卷径值*)
	io_rDiamCurAxis:=rEstiDia_In_Out;

	IF xUseDiam_LowPass_In (*OR(*使用低通后的卷径值*)
		xNeedWuCompensate_UwCut*) THEN(*接料的时候使用一段时间低通滤波的值@2024.05.14.195838*)
		io_rDiamCurAxis:=rEstiDia_LowPass;
	END_IF



	(*2022.7.25.170538 在非停止的时候更新计算的当前卷径值|
	如果处于停止中 急停中则保持之前的卷径值计算补偿值*)
	IF (xCanDiaCompensate AND
		(NOT i_xFlag_EStoping) AND
		(NOT i_xFlag_Stoping) AND
		(NOT i_xFlag_FastStoping)) OR
		 NOT xCanDiaCompensate THEN(*不补偿*)
		rDia_Cur:=io_rDiamCurAxis;
	END_IF
	IF xFlag_Cut_end_Out OR (*裁切完成|更新上个周期卷径值*)
		NOT xLastDiaEstEn THEN(*卷径估计切换了*)
		rLastDia_Cur:=rDia_Cur(*pstStGrpParam^.lrDiamCurAxis_Uw*);
		IF xFlag_Cut_end_Out THEN(*裁切时候取初始时间作为计时点*)
			tTimeCutDne:=TIME();
			rDiaSa_CutDne:=rDia_Cur;(*记录接料后起始卷径@2023.09.04.142331*)
		END_IF
	END_IF

	(*2023.09.04.142325*)
	IF tTimeCutDne<>T#0MS THEN
		IF TIME()-tTimeCutDne<UINT_TO_TIME(BYTE_TO_UINT(byDelayTime_DiaCompensateWhenCutDne_In_Out)*1000) THEN
			rDiaPrf_CutDne:=rDiaPrf_CutDne-o_rVelRPM_Cur*
					i_iCycleTime_Plc/1000/60*
					(rFilmThickNess_Using_In_Out)*2;(*转换为直径*)(*2023.12.02.090136 修改了使用的厚度值变量*)
			rDia_Cur:=rDiaSa_CutDne+rDiaPrf_CutDne;(*强制写为规划卷径*)
		ELSE(*退出的时候切换卷径注意上个周期卷径变化*)
			rLastDia_Cur:=rDia_Cur;(*这个周期卷径当前值=前一次的值|存在卷径切换*)
			tTimeCutDne:=T#0MS;
			rDiaPrf_CutDne:=0;
		END_IF
	ELSE
		rDiaPrf_CutDne:=0;(*初始化规划卷径值*)
	END_IF


	(*计算主速度|*)
	IF xCanDiaCompensate THEN
		(*按照400m/min 料轴300mm周长时料膜厚度50丝 的大概直径变化值作为限值|
		=400/60*20/300*50=22.2丝|直径 44.4丝|取值0.5mm*)
		IF ABS(rDia_Cur-rLastDia_Cur)<=0.5 THEN(*非法值处理*)

			IF rLastDia_Cur<>0 AND
				rDia_Cur<>0 THEN
				rMainVel:= LREAL_TO_REAL(rVelTmp/rDia_Cur*1000/gc_lrPi-
							rLastVelmpm/rLastDia_Cur*1000/gc_lrPi);
				xAccDecingCompensateEn:=FALSE;(*启动了直流分量补偿则不需要以前升降速补偿*)
			END_IF

			(*2024.8.22.091836 放料接料前馈时候输出和摆臂相关@2024.8.22.091854*)
			(*2025.1.10.120220  将取消补偿的阈值从0.5修改到0.2*)
			(*接料以后这段代码会影响停机时候的前馈,导致断料@2025.1.15.162951*)
			IF rDiaPrf_CutDne<>0 THEN
				IF i_xFlag_Accing OR
					i_xFlag_Decing THEN;(*加减速的时候不检查摆臂是否松,前馈需要有效*)
				ELSE
					IF i_rAI_Swing<-0.2 THEN(*摆臂松的时候@不要输出加速补偿*)
						IF rMainVel>0 THEN
							rMainVel:=0;
						END_IF
					END_IF
				END_IF
			END_IF
		END_IF
	END_IF
ELSE
	IF tTimeCutDne<>T#0MS THEN
		tTimeCutDne:=T#0MS;
		rDiaPrf_CutDne:=0;(*初始化规划卷径值*)
	END_IF
END_IF
	
xLastDiaEstEn:=xDiaEstEn;
rLastDia_Cur:=rDia_Cur(*pstStGrpParam^.lrDiamCurAxis_Rw*);
rLastVelmpm:=rVelTmp(*pstStGrpParam^.lrVel_Film*);	
	
	
	

