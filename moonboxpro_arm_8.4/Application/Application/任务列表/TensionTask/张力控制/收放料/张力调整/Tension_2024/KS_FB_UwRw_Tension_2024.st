(*@CES
Name=KS_FB_UwRw_Tension_2024
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a2ea20de-6ea3-42dc-9732-f01f9ffb715d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_UwRw_Tension_2024
(*2024.05.25.085608|张力控制器算法*)
(*2024.7.12.113324 bug修复|输出限值调整*)
(*2024.7.26.090714 增加了接料后卷径使用方式选择-默认保持接料卷径@位置要放在接料新旧卷径切换后
平滑时间增加接口@默认切换的平滑时间有200ms加长到2s-数据观察200ms还是有波动*)
(*2024.8.5.164840+i_uiDelayTime_UsePI_Cut接口*)
(*2025.1.10.115812 开始使能的时候剔除3幅补偿量*)
(*2025.1.16.204151 收料使用低通卷径在接料的时候会拉断料膜*)
(*2025.9.18.150411+ 接料压辊合压后不输出调整量。*)
VAR_INPUT
	i_xEn:BOOL;(*控制器使能*)
	(*rKc不同位置的取值还没确认*)
	i_byTensionUsePos:BYTE;(*张力控制使用位置@=0 放牵 |=1 放料|=2 收料|=3 收牵*)
	i_xTensionCompensateEn:BOOL;(*张力补偿使能@总开关*)
	i_xCanTensionCompensate:BOOL;(*可以进行张力补偿了@需要的条件都满足了*)
	i_xTensionCompensateEn_Cut:BOOL;(*裁切补偿@不用就写false*)
	i_xUseDiam_Lp_Cut:BOOL;(*裁切时候使用低通卷径@2024.7.26.090627*)
	i_bySmoothTime_Diam_Cut:BYTE:=2;(*裁切后使用卷径切换平滑时间@2s*)
	i_byCycleTime_Plc:BYTE:=20;(*程序周期@ms*)
	i_rAi:REAL;(*摆臂位置*)
	i_rVel_Cur:REAL;(*主机当前速度*)
	i_rVel_CurAxis:REAL;(*当前轴速度@收放料是转速|收放牵是线速度*)
	i_uiDelayTime_UsePI_Cut: UINT; (*放料裁切PI投入时间@2024.8.5.164500+*)

	i_xAccing:BOOL;(*加速中*)
	i_xDecing:BOOL;(*减速中*)
	i_xFlag_Cut_end:BOOL;(*裁切完成标志@有效一个周期*)
	i_rDiam_mm:REAL;(*卷径实时值@mm*)
	i_rDiam_Lp:REAL;(*经过低通卷径值@mm*)

	i_rR_K_LQR				: REAL;
	i_rN_LQR				: REAL;

	i_rR_K_MinBeat			: REAL;
	i_iN_MinBeat			: INT;

	i_xUseIMatrix_rX_DARE:BOOL;(*使用单位矩阵*)
	i_xUseTime_Variaition:BOOL;(*使用时变参数*)
	i_uiUseTime_Diam_Min:UINT;(*使用时变的最小卷径@小于该值就不时变*)
	i_xUseTime_b1:BOOL;(*b1使用时变方式*)
	i_rKc:REAL;(*增益*)
	i_rKc_AccDec:REAL;(*加减速增益*)

(*	i_pstModelParam: POINTER TO Initial_Model_Parameters;(*模型初始参数@50bytes*)*)
	i_pstInitial_Model_Parameters_Input: POINTER TO Initial_Model_Parameters;(*2024.05.07.093000 调整接口名*)
	i_pstInvariant_Parameters: POINTER TO Invariant_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
(*
	i_pstKalman_Status_Estimation_And_Feedback: POINTER TO Kalman_Status_Estimation_And_Feedback;(*2024.05.07.105319 修改接口名by Liu*)
	i_pstKalman_Status_Estimation_And_Feedback_MinBeat: POINTER TO Kalman_Status_Estimation_And_Feedback_MinBeat;(*2024.05.07.105319 修改接口名by Liu*)
*)
	i_pstPI_Parameters: POINTER TO PI_Parameters;(*2024.05.07.105319 修改接口名by Liu*)
	i_pstPI_Parameters_AccDec: POINTER TO PI_Parameters;(*2024.05.13.181126 升降速pi参数*)
(*2024.06.08.151649修改到了局部*)
(*	i_parX_DARE:POINTER TO ARRAY [1..4,1..4] OF REAL;(*上一个周期已经迭代收敛的值X_Dare*)*)
	i_pstTime_Varying_Parameters_Output: POINTER TO Time_Varying_Parameters;(*时变参数输出*)
	//2025.9.18.145850+
	i_xCutRollerPress:BOOL;(*裁切压辊合压*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_rWuCompensate:REAL;(*补偿输出*)
	o_rWuCompensate_Act:REAL;(*实际补偿输出@写入到电机*)
	o_iMaxIterateCnt_LQR:INT;(*迭代次数*)
END_VAR
VAR_IN_OUT
	io_byKalmanFilterType:BYTE;(*滤波方式@只支持4、5*)
	io_byStructParanInitEn:BYTE;(*参数结构体初始化*)
END_VAR
VAR
	xTensionCompensateEn: BOOL;(*张力补偿标志*)
	xCanTensionCompensate: BOOL;(*可以进行张力补偿*)
	xNeedWuCompensate_Cut: BOOL;(*裁切需要补偿标志*)
	xNotNeedWuCompensate_Cut: BOOL;(*裁切不需要补偿@延迟时间不做补偿输出*)
	fbTon_TensionEn_Cut: TON;
	rDiamWuCompensate: REAL;(*计算补偿的卷径*)
	rDiamCurTmp_Cut: REAL:=0;(*裁切时候保存的使用当前卷径值*)
	rDeltaDiam_Cut: REAL:=0.3;(*裁切时候|使用的卷径向实际卷径变化量*)

	(*控制器相关*)
	rIterateCnt: REAL;(*迭代次数@主要是用于监控*)
	stCached_Array_Pointers: Cached_Array_Pointers;
	stKalman_Status_Estimation_And_Feedback: Kalman_Status_Estimation_And_Feedback;
	stKalman_Status_Estimation_And_Feedback_MinBeat: Kalman_Status_Estimation_And_Feedback_MinBeat;
	stPI_Parameters: PI_Parameters;(*控制器pi参数@根据加减速变化切换*)
	rKc:REAL;(*输出系数*)
	byLastKalmanFilterType: BYTE;
	iCountNum: INT;
	(*2024.06.08.151620  修改为了局部*)
	(*LQR迭代求解DARE*)
	arX_DARE:ARRAY [1..4,1..4] OF REAL;(*上一个周期已经迭代收敛的值X_Dare*)
	alrX_DARE:ARRAY [1..4,1..4] OF LREAL;(*上一个周期已经迭代收敛的值X_Dare*)
	uiSmoothCnt: UINT;(*2024.7.26.101944+*)
	(*2024.8.5.172016*)
	uiWaitTime_ms: UINT:=5000;(*等待的时间@裁切后切换张力算法延时*)
	uiWaitTime_ms_Use: UINT:=5000;(*使用的等待的时间*)
	byCompensateZeroCnt: BYTE:=0;
END_VAR
{IMPLEMENTATION}
IF io_byKalmanFilterType<>4 AND io_byKalmanFilterType<>5 THEN
	io_byKalmanFilterType:=4;
END_IF
IF i_byCycleTime_Plc=0 THEN i_byCycleTime_Plc:=INT_TO_BYTE(gc_TENSION_TSK_CYCLE_TIME); END_IF
IF i_bySmoothTime_Diam_Cut=0 THEN i_bySmoothTime_Diam_Cut:=2;END_IF
uiSmoothCnt:=BYTE_TO_UINT(i_bySmoothTime_Diam_Cut)*1000/i_byCycleTime_Plc;(*周期个数*)

IF i_xEn THEN
	o_xEn:=i_xEn;

	(*裁切部分处理---------------------------------------------------------------start*)
	(*接料的时候取消扰动补偿@2023.09.14.155200*)
	IF i_xTensionCompensateEn_Cut THEN;(*裁切补偿的时候，继续执行张力估计以及补偿*)
		IF i_xFlag_Cut_end THEN(*裁切的时候置位*)
			xNeedWuCompensate_Cut:=TRUE;(*该标志控制卷径使用低通后卷径*)
		END_IF
		xNotNeedWuCompensate_Cut:=FALSE;
	ELSE(*不补偿的时候|让掉接料这段时间*)
		xNeedWuCompensate_Cut:=FALSE;
		IF i_xFlag_Cut_end OR(*裁切的时候置位不需要补偿*)
			i_xCutRollerPress THEN(*2025.9.18.150151 裁切压辊合压的时候取消补偿*)
			xNotNeedWuCompensate_Cut:=TRUE;
			IF i_xCutRollerPress THEN
				fbTon_TensionEn_Cut(IN:=FALSE);//清除计时器@在裁切后再开始计时@2025.9.18.150341+
			END_IF
		END_IF
	END_IF
	(*2024.8.5.165011+*)
	IF xNotNeedWuCompensate_Cut THEN(*接料后不补偿的时候|PI投入时间后再切换@2024.8.5.161442*)
		uiWaitTime_ms_Use:=i_uiDelayTime_UsePI_Cut;
		IF i_uiDelayTime_UsePI_Cut<uiWaitTime_ms THEN
			uiWaitTime_ms_Use:=uiWaitTime_ms;
		END_IF
	ELSE
		uiWaitTime_ms_Use:=uiWaitTime_ms;
	END_IF


	fbTon_TensionEn_Cut(IN:=xNeedWuCompensate_Cut OR xNotNeedWuCompensate_Cut,
				PT:=UINT_TO_TIME(uiWaitTime_ms_Use)(*T#5S*));(*启动计时*)

	IF fbTon_TensionEn_Cut.Q THEN(*时间到*)
		xNeedWuCompensate_Cut:=FALSE;
		xNotNeedWuCompensate_Cut:=FALSE;
	END_IF

	(*2024.05.24.084240+*)
	IF xNeedWuCompensate_Cut THEN(*需要裁切补偿的时候-卷径使用低通卷径@定时后切换为当前卷径*)
		(*2024.7.26.090702*)
		IF i_xUseDiam_Lp_Cut THEN(*使用低通卷径*)
			rDiamWuCompensate:=i_rDiam_Lp;(*使用经过低通的卷径*)
		ELSE;(*保持不变*)
			IF i_xFlag_Cut_end THEN(*接料的时候获取到当前新卷径*)
				rDiamWuCompensate:=i_rDiam_mm;(*此时已经把卷径交换过了*)
			END_IF
		END_IF

		(*处于裁切保持状态下,记录并计算下面的值@退出的时候使用*)
		rDiamCurTmp_Cut:=rDiamWuCompensate;(*作为条件使用@平常都是0*)
		rDeltaDiam_Cut:=(i_rDiam_mm-rDiamCurTmp_Cut)/uiSmoothCnt;(*2S平滑*)
		rDeltaDiam_Cut:=ABS(rDeltaDiam_Cut);(*取正值*)
		IF rDeltaDiam_Cut<3.0/UINT_TO_REAL(uiSmoothCnt) THEN(*限值递减量别太小@数据出现过了3mm的偏差|最小值用这个来确定*)
			rDeltaDiam_Cut:=3.0/UINT_TO_REAL(uiSmoothCnt);
		END_IF
	ELSE
		IF rDiamCurTmp_Cut>1 THEN(*该值合法*)
			IF (i_rDiam_mm-rDiamCurTmp_Cut)>rDeltaDiam_Cut THEN(*当前卷径比低通的大*)
				rDiamCurTmp_Cut:=rDiamCurTmp_Cut+rDeltaDiam_Cut;(*写入当前卷径值*)
				rDiamWuCompensate:=rDiamCurTmp_Cut;(*写入当前卷径值*)
			ELSIF (i_rDiam_mm-rDiamCurTmp_Cut)<-rDeltaDiam_Cut THEN(*当前卷径比低通的小*)
				rDiamCurTmp_Cut:=rDiamCurTmp_Cut-rDeltaDiam_Cut;(*写入当前卷径值*)
				rDiamWuCompensate:=rDiamCurTmp_Cut;(*写入当前卷径值*)
			ELSE
				rDiamCurTmp_Cut:=0.0;(*退出*)
				rDiamWuCompensate:=i_rDiam_mm;
			END_IF
		ELSE(*使用当前卷径*)
			rDiamWuCompensate:=i_rDiam_mm;(*写入当前卷径值*)
		END_IF
	IF i_xFlag_Cut_end THEN(*裁切的时候初始化*)
		io_byStructParanInitEn.2:=TRUE;(*初始化标志@下个周期才会运行*)
		io_byStructParanInitEn.3:=TRUE;(*初始化标志@下个周期才会运行*)
		io_byStructParanInitEn.5:=TRUE;(*初始化迭代矩阵标志@下个周期才会运行*)
	END_IF
	(*裁切部分处理---------------------------------------------------------------end*)

	(*初始化一些参数*)
	END_IF
	KS_InitTensionCtl_StructParam(
		io_byStructParanInitEn(*i_byInitEn*),(*界面用于控制非法值的初始化*)
		i_xUseIMatrix_rX_DARE(*i_xUseIMatrix_rX_DARE*),
		i_pstInitial_Model_Parameters_Input(*i_pstInitial_Model_Parameters_Input*),
		i_pstInvariant_Parameters(*i_pstInvariant_Parameters1*),
		ADR(stKalman_Status_Estimation_And_Feedback)(*i_pstKalman_Status_Estimation_And_Feedback1*),
		ADR(stKalman_Status_Estimation_And_Feedback_MinBeat)(*i_pstKalman_Status_Estimation_And_Feedback_MinBeat1*),
		i_pstPI_Parameters(*i_pstPI_Parameters1*),
(*		i_parX_DARE,(*i_parX_DARE*)*)
		ADR(arX_DARE),(*i_parX_DARE*)
		ADR(alrX_DARE),(*i_palrX_DARE*)
		i_pstPI_Parameters_AccDec,(*i_pstPI_Parameters1_AccDec*)
		BYTE_TO_INT(i_byCycleTime_Plc)(*i_iCycleTime_Plc*));

	IF io_byStructParanInitEn.2 THEN(*初始化值写入到使用的结构体中*)
		IF i_rR_K_LQR = 0 THEN//2025.9.20.161612+
			stKalman_Status_Estimation_And_Feedback.R_K:=10;(*初始化的值是保持的*)
		ELSE
			stKalman_Status_Estimation_And_Feedback.R_K:=i_rR_K_LQR;(*初始化的值是保持的*)
		END_IF
		IF i_rN_LQR = 0 THEN//2025.9.20.161616+
			stKalman_Status_Estimation_And_Feedback.N_LQR:=10;(*初始化的值是保持的*)
		ELSE
			stKalman_Status_Estimation_And_Feedback.N_LQR:=i_rN_LQR;(*初始化的值是保持的*)
		END_IF
	END_IF
	IF io_byStructParanInitEn.3 THEN(*初始化值写入到使用的结构体中*)
		stKalman_Status_Estimation_And_Feedback_MinBeat.R_K:=i_rR_K_MinBeat;(*初始化的值是保持的*)
		stKalman_Status_Estimation_And_Feedback_MinBeat.N_MinBeat:=i_iN_MinBeat;(*初始化的值是保持的*)
	END_IF
	IF io_byStructParanInitEn.5 THEN(*初始化了arX_DARE函数写入到使用的结构体中*)
		stCached_Array_Pointers.arX_DARE:=arX_DARE;(*初始化的值是保持的,局部变量是迭代生成的*)
		stCached_Array_Pointers.alrX_DARE:=alrX_DARE;(*初始化的值是保持的,局部变量是迭代生成的*)
	END_IF
	io_byStructParanInitEn:=0;(*初始化标志清零*)

	(*Kc处理*)
	(*随加减速状态做切换*)
	stPI_Parameters:=i_pstPI_Parameters^;
	rKc:=i_rKc;
	IF i_xAccing OR i_xDecing THEN(*加减速时候使用另外的参数*)
		stPI_Parameters:=i_pstPI_Parameters_AccDec^;
		rKc:=i_rKc_AccDec;
	END_IF

	rKc:=ABS(rKc);(*保证为正值*)
	IF i_byTensionUsePos=0 THEN(*放牵*);
	ELSIF i_byTensionUsePos=2 THEN(*收料*);
	ELSIF i_byTensionUsePos=3 THEN(*收牵*);
	ELSE(*默认是放料*)
		(*rKc 只能为负值*)
		rKc:=-rKc;
	END_IF


	(*处理使能标志*)
	xTensionCompensateEn:=i_xTensionCompensateEn;
	IF i_xCanTensionCompensate AND
		NOT xNotNeedWuCompensate_Cut THEN(**)
		xCanTensionCompensate:=TRUE;
	ELSIF xCanTensionCompensate THEN
		IF xNotNeedWuCompensate_Cut OR(*裁切不补偿*)
			NOT i_xCanTensionCompensate THEN
			xCanTensionCompensate:=FALSE;
		END_IF
	END_IF
	xTensionCompensateEn:=xTensionCompensateEn AND xCanTensionCompensate;


	(*计算补偿量*)
	IF xTensionCompensateEn THEN
		IF io_byKalmanFilterType<>byLastKalmanFilterType OR
			i_xFlag_Cut_end THEN(*裁切后初始化，重新开始运算*)
			byLastKalmanFilterType:=io_byKalmanFilterType;
			iCountNum:=0;
			o_rWuCompensate:=0;
			o_rWuCompensate_Act:=0;
			rIterateCnt:=0;(*2024.05.07.114309+*)
			SysMemSet(ADR(stCached_Array_Pointers),0,SIZEOF(stCached_Array_Pointers));
			io_byStructParanInitEn.2:=TRUE;(*初始化标志@下个周期才会运行*)
			io_byStructParanInitEn.3:=TRUE;(*初始化标志@下个周期才会运行*)
			io_byStructParanInitEn.5:=TRUE;(*初始化迭代矩阵标志@下个周期才会运行*)
			(*每次进入的时候会执行初始化动作,这里增加标志控制刚开始的几个调整量剔除逻辑@2025.1.10.113728*)
			(*现场发现刚进入计算逻辑的时候会有异常值的出现*)
			byCompensateZeroCnt:=0;(*补偿量清零计数@2025.1.10.115519*)

		END_IF


		CASE io_byKalmanFilterType OF
			4,5:(*Time_Variaition_PILQR or Time_Variaition_PIMinBeat|2024.05.07.113012*)
				(*参数运算*)
				Para_Cal(
					i_xUseTime_Variaition(*i_xUseTime_Variaition*),
					i_pstInitial_Model_Parameters_Input^(*i_stInitial_Model_Parameters_Input*),
					i_pstTime_Varying_Parameters_Output(*i_pTime_Varying_Parameters_Output*),
					rDiamWuCompensate/2/1000(*i_rEST_R*),
					UINT_TO_REAL(i_uiUseTime_Diam_Min)/2/1000(*i_rUseTime_R_Min*),
					i_xUseTime_b1(*i_xUseTime_b1*));

				IF io_byStructParanInitEn=0 THEN(*初始化完成*)
					IF io_byKalmanFilterType=4 THEN

						Time_Variaition_PILQR(
							TRUE(*i_xUseWfValue*),
							i_rVel_Cur(*i_rVt*),
							i_rVel_CurAxis(*i_rWu*),
							i_rAi(*i_rY*),
							rKc(*i_rKc*),
							ADR(iCountNum)(*i_piK*),
							ADR(o_rWuCompensate)(*i_prWf*),
							ADR(rIterateCnt)(*i_prCNT*),
							i_pstInvariant_Parameters^(*i_stInvariant_Parameters1*),
							i_pstTime_Varying_Parameters_Output^(*i_stTime_Varying_Parameters1*),
							stKalman_Status_Estimation_And_Feedback(*i_stKalman_Status_Estimation_And_Feedback1*),
							stPI_Parameters(*i_stPI_Parameters1*),
							ADR(stCached_Array_Pointers)(*i_pCached_Array_Pointers1*));
					ELSE(*=5*)
						Time_Variaition_PIMinBeat(
							TRUE(*i_xUseWfValue*),
							i_rVel_Cur(*i_rVt*),
							i_rVel_CurAxis(*i_rWu*),
							i_rAi(*i_rY*),
							rKc(*i_rKc*),
							ADR(iCountNum)(*i_piK*),
							ADR(o_rWuCompensate)(*i_prWf*),
							ADR(rIterateCnt)(*i_prCNT*),
							i_pstInvariant_Parameters^(*i_stInvariant_Parameters1*),
							i_pstTime_Varying_Parameters_Output^(*i_stTime_Varying_Parameters1*),
							stKalman_Status_Estimation_And_Feedback_MinBeat(*i_stKalman_Status_Estimation_And_Feedback_MinBeat1*),
							stPI_Parameters(*i_stPI_Parameters1*),
							ADR(stCached_Array_Pointers)(*i_pCached_Array_Pointers1*));
					END_IF
				END_IF

				(*2025.1.10.115656 前3幅调整量不要了*)
				IF byCompensateZeroCnt>3 THEN(*第一个周期本事就没补偿量*)
					o_rWuCompensate_Act:=o_rWuCompensate;
				ELSE
					byCompensateZeroCnt:=byCompensateZeroCnt+1;
					o_rWuCompensate_Act:=0;
				END_IF
				(*输出增加限制幅度-先按照20r/min@2024.05.14.180114*)
				IF xNeedWuCompensate_Cut THEN(*裁切后一段时间增加转速限制@xNeedWuCompensate_UwCut 有效由时间控制*)
					IF ABS(o_rWuCompensate)>20 THEN
						o_rWuCompensate_Act:=20*o_rWuCompensate/ABS(o_rWuCompensate);
					END_IF
				END_IF
				(*2024.05.22.202801+*)
				(*2025.1.2.112027 限值从100改到500*)
				IF ABS(o_rWuCompensate)>500 THEN
					o_rWuCompensate_Act:=500*o_rWuCompensate/ABS(o_rWuCompensate);
				END_IF
		END_CASE
	ELSE(*取消使能*)
		byLastKalmanFilterType:=io_byKalmanFilterType+1;(*保证使能开始的时候会初始化参数@2024.05.07.114541*)
		o_rWuCompensate:=0;
		o_rWuCompensate_Act:=0;
		byCompensateZeroCnt:=0;(*2025.1.10.115643*)
	END_IF

	o_iMaxIterateCnt_LQR:=stCached_Array_Pointers.iMaxIterateCnt_LQR;
ELSE
	byLastKalmanFilterType:=io_byKalmanFilterType+1;(*保证使能开始的时候会初始化参数@2024.05.07.114541*)
	o_rWuCompensate:=0;
	o_rWuCompensate_Act:=0;
	o_iMaxIterateCnt_LQR:=0;
	rDiamCurTmp_Cut:=0;
	xNeedWuCompensate_Cut:=FALSE;
	xNotNeedWuCompensate_Cut:=FALSE;
	rDiamWuCompensate:=i_rDiam_mm;(*写入当前卷径值*)
	byCompensateZeroCnt:=0;(*2025.1.10.115643*)
END_IF