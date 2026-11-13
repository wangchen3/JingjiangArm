(*@CES
Name=KS_FB_CutDelay_CTL_Uw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=7d00bae0-aa45-4462-8bc3-c5298b7152c0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CutDelay_CTL_Uw(*2020.4.24.144517 重新处理了弧面逻辑|liu.yt
									2020.9.30.140045 增加了1.5圈接料时考虑胶辊延时的逻辑*)
									(*2020.10.9.164829 增加弧面是否存在的检测|
														如果未检测到自动切换到计圈接料同时输出标志*)
									(*2020.11.18.111837 弧面信号是否存在判断圈数根据2s时间计算圈数最小3圈判定*)
									(*2021.10.14.142107 修改输入接口料膜速度为预驱速度*)
									(*2022.5.5.105229 增加o_iCutTotalTime输出*)
									(*2023.2.25.213421 升速支持弧面切换为圈数接料方式|*)
									(*2024.7.11.113104  切换为按圈接料,有时候需要按2次接料bug修复*)
VAR_INPUT
	i_xEn: BOOL; (*放料使能*)
	i_xUseTime:BOOL:=FALSE;
	i_rDelayTimeMs: REAL := 250;
	i_rCoef_FilmVolPerimeter: REAL := 1.5; (*料卷周长系数*)
	i_rDiam_New: REAL; (*新卷的卷径*)
//	i_pstStGrpParam:POINTER TO StGrpParam;(*系参数*)
	i_pstStTimeSet_DnCut_UpCut:POINTER TO StTimeSet_DnCut_UpCut;(*收放料端裁切时间集*)(*由外部进行上下裁区分*)
	i_xReq_Cut: BOOL; (*裁切*)

(*料膜速度修改为了预驱速度*)
(*	i_lrVel_Film: LREAL; (*料膜的速度*)*)
	i_rVel_PreDrv: REAL; (*预驱的速度*)
	i_xReflectionSensorIO: BOOL;
	i_xCutUseReflectionSensor: BOOL;
	i_byReflectionSensor_FromDriver: BYTE;(*来自于驱动器接线的反射弧面信号*)
	i_iCycleTime_Plc: INT;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL; (*功能块输出*)
	o_iErNo: INT;(*0成功\-1参数无效|*)
	o_xRollerCylinderOutput: BOOL; (*放料胶辊输出*)
	o_xCut_ing: BOOL; (*放料裁刀已经出了*)
	o_xReflectionSensorValid: BOOL;(*2019.11.29.174143_*)

	(*时间 增加监控输出*)
	o_xCutting:BOOL;
	o_xCutting_ClockBegin:BOOL;
	o_iCycleNum:INT;
	o_uiCutting_ClockNum:UINT;
	o_lrPressTime:LREAL;
	o_lrCutTime:LREAL;

	(*2020.10.7.172655 增加了弧面信号是否存在标志*)
	o_xReflectSensorLoss:BOOL;(*弧面信号丢失*)
	o_iCutTotalTime:INT;(*裁切使用的时间|ms*)
	o_xCutSenSorDelay: BOOL;
END_VAR
VAR
	lrTotalDistance: LREAL; (*总共要走过的距离|单位:mm*)
	lrDisplacement_OneCycle: LREAL; (*单周期的位移量|单位:mm*)
	lrDisplacement_Total: LREAL := 0; (*总共的位移量|单位:mm*)

	iDelayMaxTimes: INT;
	iDelayTimesCnt: INT;

(*弧面检测变量*)
	xInit: BOOL;
	lrTheoryTime_OneCycle: LREAL;(*理论旋转一圈的时间|MS*)
	lrPreTheoryTime_OneCycle: LREAL;(*上个周期理论旋转一圈的时间*)
	lrTime_OneCycle: LREAL;(*旋转一圈的时间|MS*)
	iSteadyCycle: INT;
	iCycleNum: INT;(*放料需要旋转的圈数*)
	lrPressTime: LREAL;(*压辊时间*)
	lrCutTime: LREAL;(*放料下裁刀的时间*)
	xReflectionSensorValid: BOOL;(*反射板信号有效了*)
	byPreReflectionSensorTrigCnt: BYTE;(*上个周期反射板上升沿计数*)
	xCutting: BOOL;(*放料接料中*)
	xCutting_ClockBegin: BOOL;(*放料裁切计时启动标志*)
	uiCutting_ClockNum: UINT;(*放料裁切时时间计数变量*)
	aiWatchData:ARRAY [1..5] OF INT;(*监控数据*)
	xPreReflectionSensorIO: BOOL;
	lrTemp: LREAL;
	lrTemp1: LREAL;
	lrMaxCycle: LREAL;




	lrNexCycleTime: LREAL;
	uiCycles: UINT;(*检测到第一个弧面后开始启动计数|转动圈数计数*)
	xInPos: BOOL;(*一圈到位了用来确定模拟弧面位置*)
	uiAnotherCnt: UINT;
	xCanCut: BOOL;(*可以接料标志*)
	fbTon_RollerCyclinder: TON;
	xRollerCylinderInPos: BOOL;
	(*2020.10.9.164819*)
	iCnt_CheckSensorValid: INT;(*计数用于判断弧面信号是否存在*)
	xCutUseRelectionSensor: BOOL;(*接料方式标志|有效为弧面接料*)
	xCutUseCycle: BOOL;(*接料方式为计圈接料标志|用于在未检测到弧面信号时的应急处理*)
	iMaxCyclesForCheckSensorLoss: INT:=10;(*2020.11.18.111837 弧面信号是否存在判断圈数根据2s时间计算圈数最小3圈判定*)

	(*2023.2.25.213905*)
	xCutUseCycleInReflectWay:BOOL;(*在弧面方式下使用圈数裁切标志|用于弧面升降速状态接料切换为圈数接料标志*)
END_VAR

{IMPLEMENTATION}
o_iErNo:=0;
IF i_pstStTimeSet_DnCut_UpCut<>0  THEN;(*判断指针的合法性*)
ELSE
	o_iErNo:=-1;
	RETURN;
END_IF

(*2020.10.9.165940 接料方式修改为临时变量控制|
方便弧面接料时未检测到弧面自动切换到计圈接料*)
xCutUseCycle:=FALSE;(*下面逻辑不置位的时候清除*)
IF o_xReflectSensorLoss OR(*发现弧面信号丢失自动切换到计圈接料*)
	xCutUseCycleInReflectWay THEN(*在弧面方式下接料时处于加减速状态此时用于切换为圈数接料@2023.2.25.214537*)
	xCutUseCycle:=TRUE;
END_IF
xCutUseRelectionSensor:=i_xCutUseReflectionSensor AND NOT xCutUseCycle;



IF i_xEn THEN(*放料裁切使能*)
	IF xCutUseRelectionSensor  THEN (*弧面检测*)
		lrTheoryTime_OneCycle:=i_rDiam_New*gc_lrPI/i_rVel_PreDrv*60;

		IF NOT xInit THEN(*初始化*)
			lrPreTheoryTime_OneCycle:=lrTheoryTime_OneCycle;
			iSteadyCycle:=0;
			xInit:=TRUE;
		END_IF

		(*只是用理论计算时间作为转一圈的时间，不再进行测量时间*)(*2017年4月13日 10:15:38*)
		lrTime_OneCycle:=0;
		IF lrPreTheoryTime_OneCycle=lrTheoryTime_OneCycle OR (*料膜旋转一圈的时间值未变化*)
			xCutting THEN(*2023.2.25.210755 处于裁切过程中就不考虑是不是加减速了*)
			(*只是用理论计算时间作为转一圈的时间，不再进行测量时间*)(*2017年4月13日 10:15:38*)
			IF iSteadyCycle>5 THEN(*稳定了5个周期后我们认为已经到达稳速阶段了*)
				lrTime_OneCycle:=lrPreTheoryTime_OneCycle;
			ELSE
				iSteadyCycle:=iSteadyCycle+1;
			END_IF
		ELSE
			xCutting_ClockBegin:=FALSE;
			uiCutting_ClockNum:=0;(*放料裁切时时间计数变量*)
			iSteadyCycle:=0;
		END_IF
		lrPreTheoryTime_OneCycle:=lrTheoryTime_OneCycle;(*保存上个周期的理论旋转时间*)


		(*寻找弧面开关上升沿*)
		xReflectionSensorValid:=FALSE;
		(*驱动器高速IO寻找*)
		IF i_byReflectionSensor_FromDriver<> byPreReflectionSensorTrigCnt THEN(*放料反射板检测计数变化了*)(*暂定放牵作为反射板信号输入源*)
			xReflectionSensorValid:=TRUE;
		END_IF


		(*数字量模块IO寻找*)
		xInPos:=FALSE;
		IF uiCycles>0 THEN
			lrNexCycleTime:=uiCycles*lrTheoryTime_OneCycle;

			uiAnotherCnt:=uiAnotherCnt+1;
			IF ABS(UINT_TO_INT(uiAnotherCnt)*i_iCycleTime_Plc-lrNexCycleTime)<=i_iCycleTime_Plc/2 THEN
				xInPos:=TRUE;
			END_IF

			IF xInPos THEN
				uiCycles:=uiCycles+1;
			END_IF
		END_IF

		IF (i_xReflectionSensorIO AND NOT xPreReflectionSensorIO) OR
			xInPos THEN
			xReflectionSensorValid:=TRUE;
		END_IF


		IF xReflectionSensorValid AND (i_xReflectionSensorIO AND NOT xPreReflectionSensorIO) THEN(**)
			uiCycles:=1;
			uiAnotherCnt:=0;
		END_IF

		(*裁切时间是和接料按钮按下有关的,而这个时间却是用来控制接料按钮的
		所以我们取最大的裁切时间输出-也就是一圈|2022.5.5.085043*)
		o_iCutTotalTime:=LREAL_TO_INT(lrTime_OneCycle);

		(*裁切按下了,只检测上升沿*)
		IF i_xReq_Cut AND NOT xCutting THEN
			IF lrTime_OneCycle<>0 THEN(*可以弧面接料@2023.2.25.213719*)
				xCutting:=TRUE;
				xCanCut:=FALSE;
				(*我们计算压辊和裁刀动作的时间*)
				lrTemp:=(i_pstStTimeSet_DnCut_UpCut^.iDelayMsec_RollerCylinder+
						i_pstStTimeSet_DnCut_UpCut^.uiMM_Roller2GummedTape/i_rVel_PreDrv*60);
	
				(*以前逻辑未考虑裁刀时间为负值的情况，增加胶辊和裁刀时间的大值作为需要的周期数计算条件*)
				lrTemp1:=i_pstStTimeSet_DnCut_UpCut^.uiMM_Roller2CutOfKnife/i_rVel_PreDrv*60+
						i_pstStTimeSet_DnCut_UpCut^.iDelayMsec_CutOffKnifeCylinder-
						i_pstStTimeSet_DnCut_UpCut^.uiMM_CutOfKnife2GummedTape/i_rVel_PreDrv*60;
				IF lrTemp1>lrTemp THEN(*取大值*)
					lrMaxCycle:=lrTemp1/(lrTime_OneCycle);
				ELSE
					lrMaxCycle:=lrTemp/(lrTime_OneCycle);
				END_IF

				iCycleNum:=LREAL_TO_INT(lrMaxCycle);
				IF iCycleNum>lrMaxCycle THEN;
				ELSE
					iCycleNum:=iCycleNum+1;
				END_IF

				(*计算压辊合压时间ms*)
				lrPressTime:=(lrTime_OneCycle*iCycleNum)-lrTemp;
				(*计算下裁刀时间ms*)
				lrCutTime:=lrTime_OneCycle*iCycleNum-lrTemp1;
			ELSE(*不能进行弧面接料但是已经按下了接料我们切换为圈数接料@2023.2.25.213749*)
				xCutUseCycleInReflectWay:=TRUE;
			END_IF
		END_IF

		IF lrTime_OneCycle<>0 THEN;(*速度已经稳定可以接料了*)
		ELSE xCutting:=FALSE; END_IF

		(*未裁切的时候弧面信号到的时候清零计时变量以及标志*)
		IF NOT xCutting AND xReflectionSensorValid THEN(*没有裁切换料信号的时候当再次检测到反射板信号的时候我们重新计时*)
			xCutting_ClockBegin:=FALSE;
			uiCutting_ClockNum:=0;(*放料裁切时时间计数变量*)
		END_IF

		(*按照胶辊时间 裁刀时间进行延时输出*)
		(*uiCutting_ClockNum 从0开始变了|2020.4.24.114155修改*)
		IF xCutting_ClockBegin THEN (*计时启动了*)
			uiCutting_ClockNum:=uiCutting_ClockNum+1;(*按照周期计数*)
		ELSE
			uiCutting_ClockNum:=0;(*放料裁切时时间计数变量*)
		END_IF

		IF NOT xCutting_ClockBegin THEN(*计时还未启动呢*)
			IF xReflectionSensorValid THEN (*检测到了反射板的信号了*)
				xCutting_ClockBegin:=TRUE;(*启动计时信号置有效*)
				uiCutting_ClockNum:=0;(*放料裁切时时间计数变量*)
			END_IF
		END_IF

		IF xCutting_ClockBegin THEN (*放料裁切计时启动标志*)
			IF xCutting THEN (*放料要进行裁切换料*)
				(*先判有没有过压辊和裁刀的处理时间点*)
				IF NOT xCanCut THEN
					IF lrPressTime-(UINT_TO_INT(uiCutting_ClockNum)*i_iCycleTime_Plc)<-INT_TO_LREAL(i_iCycleTime_Plc)/2 OR
						lrCutTime-UINT_TO_INT(uiCutting_ClockNum)*i_iCycleTime_Plc<-INT_TO_LREAL(i_iCycleTime_Plc)/2 THEN
						(*过了时间点|重新计时*)
						xCutting_ClockBegin:=FALSE;
					ELSE
						xCanCut:=TRUE;(*可以接料标志*)
					END_IF
				END_IF

				IF xCanCut THEN(*可以裁切了*)
					(*压辊合压点判断*)
					IF lrPressTime-(UINT_TO_INT(uiCutting_ClockNum)*i_iCycleTime_Plc)>=-INT_TO_LREAL(i_iCycleTime_Plc)/2 AND
						lrPressTime-(UINT_TO_INT(uiCutting_ClockNum)*i_iCycleTime_Plc)<=INT_TO_LREAL(i_iCycleTime_Plc)/2 THEN
						o_xRollerCylinderOutput:= TRUE;
						aiWatchData[1]:= UINT_TO_INT(uiCutting_ClockNum);
					END_IF

					(*裁刀裁切点判断*)
					IF lrCutTime-(UINT_TO_INT(uiCutting_ClockNum)*i_iCycleTime_Plc)>=-INT_TO_LREAL(i_iCycleTime_Plc)/2 AND
						lrCutTime-(UINT_TO_INT(uiCutting_ClockNum)*i_iCycleTime_Plc)<=INT_TO_LREAL(i_iCycleTime_Plc)/2 THEN
						o_xCut_ing:= TRUE;
						aiWatchData[2]:=UINT_TO_INT(uiCutting_ClockNum);
					END_IF
				END_IF
			END_IF
		END_IF

		(*2020.10.9.164457 增加弧面信号是否存在检测机制|3圈未有信号则认为弧面丢失*)
		iMaxCyclesForCheckSensorLoss:=10;
		IF lrTime_OneCycle<>0 THEN
			iMaxCyclesForCheckSensorLoss:=LREAL_TO_INT(2000/lrTime_OneCycle);(*2S时间的圈数*)
			IF iMaxCyclesForCheckSensorLoss<=3 THEN(*最小3圈*)
				iMaxCyclesForCheckSensorLoss:=3;
			END_IF
		END_IF

		IF lrTime_OneCycle<>0 AND iCnt_CheckSensorValid<>-1 AND
			NOT o_xReflectSensorLoss THEN(*说明已经稳速了|*)
			IF NOT xReflectionSensorValid THEN(*未检测到弧面信号*)
				iCnt_CheckSensorValid:=iCnt_CheckSensorValid+1;
				IF INT_TO_LREAL(iCnt_CheckSensorValid)*i_iCycleTime_Plc>=
					lrTime_OneCycle*iMaxCyclesForCheckSensorLoss THEN(*计时超过了3圈，我们输出弧面丢失报警*)
					o_xReflectSensorLoss:=TRUE;
				END_IF
			ELSE
				iCnt_CheckSensorValid:=-1;(*有效一次后就不再进行检测了*)
				o_xReflectSensorLoss:=FALSE;
			END_IF
		END_IF


		(*2024.7.11.112930 在切换到按圈方式下|如果有接料按钮输入,切换后直接接料*)
		IF o_xReflectSensorLoss OR
			xCutUseCycleInReflectWay THEN
			IF i_xReq_Cut THEN
				xCutting:=TRUE;(*切换到按圈可以直接接料*)
			END_IF
		END_IF
	ELSE(*非弧面检测*)
		IF xCutting THEN(*因为弧面丢失而切换到按圈接料模式|此时自动触发一次接料*)
			i_xReq_Cut:=TRUE;
			xCutting:=FALSE;
		END_IF
		iDelayMaxTimes:= LREAL_TO_INT(i_rDelayTimeMs/INT_TO_LREAL(i_iCycleTime_Plc));

		IF (NOT o_xRollerCylinderOutput) AND i_xReq_Cut THEN
			o_xRollerCylinderOutput:= TRUE;
			lrDisplacement_Total:= 0;
			iDelayTimesCnt:= 0;
		END_IF

		(*2020.9.24.134640 增加了圈数接料时的胶辊延时处理*)
		fbTon_RollerCyclinder(
				IN:=o_xRollerCylinderOutput,
				PT:=INT_TO_TIME(i_pstStTimeSet_DnCut_UpCut^.iDelayMsec_RollerCylinder));
(*		xRollerCylinderInPos:=o_xRollerCylinderOutput;*)
		xRollerCylinderInPos:=fbTon_RollerCyclinder.Q;

		(*2022.5.4.171609*)
		o_iCutTotalTime:=i_pstStTimeSet_DnCut_UpCut^.iDelayMsec_RollerCylinder;


		IF i_xUseTime THEN
			(*2018.08.16.143649\通过时间延时|*)
			IF xRollerCylinderInPos THEN (*开始计算要多久裁切完成*)
				iDelayTimesCnt:= iDelayTimesCnt+1;
				IF iDelayTimesCnt>=iDelayMaxTimes THEN
					o_xCut_ing:= TRUE;
					iDelayTimesCnt:= 0;
				END_IF
			END_IF
			(*2022.5.4.171343|接料消耗的时间*)
			o_iCutTotalTime:=LREAL_TO_INT(o_iCutTotalTime+i_rDelayTimeMs);
		ELSE
(*2022.7.12.141638-处理减去裁刀延时
			lrTotalDistance:= i_lrCoef_FilmVolPerimeter * gc_lrPI * i_lrDiam_New; (*新卷需要走过的料长|单位:mm*)*)
			lrTotalDistance:= i_rCoef_FilmVolPerimeter * gc_lrPI * i_rDiam_New -
					i_pstStTimeSet_DnCut_UpCut^.iDelayMsec_CutOffKnifeCylinder*i_rVel_PreDrv/60 ; (*新卷需要走过的料长|单位:mm*)
			IF xRollerCylinderInPos THEN (*开始计算要多久裁切完成*)
				lrDisplacement_OneCycle:= i_rVel_PreDrv * i_iCycleTime_Plc / 60.0; (*单周期走过的位移量|单位:mm*)
				lrDisplacement_Total:= lrDisplacement_Total + lrDisplacement_OneCycle;
				IF lrDisplacement_Total>=lrTotalDistance THEN
					o_xCut_ing:= TRUE;
					lrDisplacement_Total:= 0;
				END_IF
			END_IF
			(*2022.5.4.171343|接料消耗的时间*)
			IF i_rVel_PreDrv<>0 THEN
				o_iCutTotalTime:=LREAL_TO_INT(o_iCutTotalTime+lrTotalDistance/i_rVel_PreDrv*60);
			END_IF
		END_IF


	END_IF
	o_xEno:= TRUE;
	xPreReflectionSensorIO:=i_xReflectionSensorIO;(*2022.5.5.121236 移动*)
ELSE
	xInit:=FALSE;
	xCutting:=FALSE;
	xCanCut:=FALSE;
	xCutting_ClockBegin:=FALSE;
	uiCutting_ClockNum:=0;

	uiCycles:=0;
	lrNexCycleTime:=0;
	uiAnotherCnt:=0;
	xInPos:=FALSE;

	iDelayTimesCnt:= 0;
	lrTotalDistance:= 0; (*总共要走过的距离|单位:mm*)
	lrDisplacement_OneCycle:= 0; (*单周期的位移量|单位:mm*)
	lrDisplacement_Total:= 0; (*总共的位移量|单位:mm*)
	o_xRollerCylinderOutput:= FALSE;
	fbTon_RollerCyclinder(IN:=FALSE);
	o_xCut_ing:= FALSE;
	o_xReflectSensorLoss:=FALSE;(*弧面信号丢失*)
	iCnt_CheckSensorValid:=0;
	o_iCutTotalTime:=0;
	o_xEno:= FALSE;
	xPreReflectionSensorIO:=FALSE;(*2022.5.5.121227 移动*)
	xCutUseCycleInReflectWay:=FALSE;(*2023.2.25.214629 接料完成后清除*)
END_IF
byPreReflectionSensorTrigCnt:=i_byReflectionSensor_FromDriver;
o_xReflectionSensorValid:= xReflectionSensorValid;(*2019.11.29.174107_全局变输出变量赋值|*)
(*2020.4.24.144430 增加了监控输出*)
o_xCutting:=xCutting;
o_xCutting_ClockBegin:=xCutting_ClockBegin;
o_iCycleNum:=iCycleNum;
o_uiCutting_ClockNum:=uiCutting_ClockNum;
o_lrPressTime:=lrPressTime;
o_lrCutTime:=lrCutTime;
o_xCutSenSorDelay:= i_xReflectionSensorIO;