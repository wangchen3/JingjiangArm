(*@CES
Name=Action_Compensate
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=55bd0b8d-a0bd-4261-86ad-bddace02a959
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*收料卷径估计函数执行-2021.8.26.154549*)
xFilmToBig:=TRUE;
IF  i_xMachineRev THEN
	xFilmToBig:=FALSE;
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
	
(*收料卷径增加低通@2024.7.11.114932*)
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
	i_lrUnWind_Velocity:= 0,(*2023.09.11.122305*)
	i_lrWind_Velocity:= rVel_CalcVolt(*pstStGrpParam^.lrVel_Rw*),
	i_lrAlarm_Diameter:= ,
	i_xUnWind_CutFinished:= FALSE,
	i_xWind_CutFinished:= xFlag_Cut_end_Out,
	i_CycleTime:= i_iCycleTime_Plc,
	i_xRollerPress_Uw:= xOutput_CutCylinder,
	i_xMachineRev:= i_xMachineRev,
	(*2021.8.26.173642 增加 用于控制报警铃输出*)
	i_rDiaAcT_Uw:= ,
	i_rDiaAcT_Rw:= io_rDiamCurAxis,
	(*修改为临时变量|2021.8.26.163843*)
	rUnWind_Diameter:= rNull,
	rWind_Diameter:= rDiameterTmp,
	o_xEno=> xEnFlag_CalcDiam_Ret,(*将i_xEn的条件拿到|*)
	o_iErNo=> ,
	o_xFlag_AlarmDiameter=> );	
	
	(*收料*)
io_rDiamCurAxis:=rDiameterTmp;(*默认取原来方式计算的卷径值*)
rMainVel:=0;(*主速度清零*)
(*如果使用牵引速度作为收料跟随速度直接修改下个变量*)
(*2021.9.16.164726 使用料膜速度*)
(*2024.8.21.172921 按钮切换*)
IF 	xUseFeedVel_In THEN
	rVelTmp:=rVel_Feed_In;
ELSE
	rVelTmp:=i_rVel_Film;
END_IF

xDiaEstEn:=xDiaEstEn_In;(*
			AND pstStGrpParam^.xFlag_RollerPressDne;(*2022.5.19.205810|全部合压完成才使用卷径估计的值*)*)
xAccDecingCompensateEn:= xFilmAccDecDone_In;

(*2024.01.02.125125同步*)
(*2023.12.12.112818将补偿的速度起始条件做成变量*)
(*	xCanDiaCompensate_Rw:=pstStGrpParam^.lrVel_Film>=40 AND pstStGrpParam^.xFlag_RollerPressDne ;*)
IF byVelSa_DiamCompensate_In_Out=0 THEN(*不补偿*)
	(*强制修改为40@2024.01.25.111419*)
	byVelSa_DiamCompensate_In_Out:=40;
(*		xCanDiaCompensate_Uw:=FALSE;*)
ELSE
(*2024.05.14.195757 取消输入限制*)
(*
	(*限制最小值为40*)
	IF pstStGrpParam^.byVelSa_DiamCompensate_Rw<40 THEN
		pstStGrpParam^.byVelSa_DiamCompensate_Rw:=40;
	END_IF
*)
	xCanDiaCompensate:=i_rVel_Film>=byVelSa_DiamCompensate_In_Out  AND xFlag_RollerPressDne_In ;
END_IF

(*2022.6.18.122511*)
IF byDelayTime_DiaCompensateWhenCutDne_In_Out=0 THEN
	byDelayTime_DiaCompensateWhenCutDne_In_Out:=10;
END_IF
IF xDiaEstEn THEN(*收料使用预估卷径值*)

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
			//2026.08.25.142736 收料应该是+
			//rDiaPrf_CutDne:=rDiaPrf_CutDne-o_rVelRPM_Cur*
			rDiaPrf_CutDne:=rDiaPrf_CutDne+o_rVelRPM_Cur*
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

	(*计算主速度*)
	IF xCanDiaCompensate THEN
		(*按照400m/min 料轴300mm周长时料膜厚度50丝 的大概直径变化值作为限值|
		=400/60*20/300*50=22.2丝|直径 44.4丝|取值0.5mm*)
		IF ABS(rDia_Cur-rLastDia_Cur)<=0.5 THEN(*非法值处理*)

			IF rLastDia_Cur<>0 AND
				rDia_Cur<>0 THEN
				rMainVel:=LREAL_TO_REAL(rVelTmp/rDia_Cur(*pstStGrpParam^.lrDiamCurAxis_Rw*)*1000/gc_lrPi-
							rLastVelmpm/rLastDia_Cur*1000/gc_lrPi);
				xAccDecingCompensateEn:=FALSE;(*启动了直流分量补偿则不需要以前升降速补偿*)
			END_IF

			(*2024.8.22.091836 放料接料前馈时候输出和摆臂相关@2024.8.22.091854*)
			(*2025.1.10.120220  将取消补偿的阈值从0.5修改到0.2*)
			(*接料以后这段代码会影响停机时候的前馈,导致断料@2025.1.15.162951*)
			IF rDiaPrf_CutDne<>0 THEN
				(*此时算出来的补偿量是负的值*)
				IF i_xFlag_Accing OR
					i_xFlag_Decing THEN;(*加减速的时候不检查摆臂是否松,前馈需要有效*)
				ELSE
					IF i_rAI_Swing<-0.2 THEN(*摆臂松的时候@不要输出减速补偿*)
						IF rMainVel<0 THEN
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
	
	
	



