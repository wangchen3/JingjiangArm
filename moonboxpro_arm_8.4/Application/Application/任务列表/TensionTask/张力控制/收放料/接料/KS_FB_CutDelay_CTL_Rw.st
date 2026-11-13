(*@CES
Name=KS_FB_CutDelay_CTL_Rw
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=74fe1525-7efd-40ab-ad64-80816e2b6802
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CutDelay_CTL_Rw
(*2021.10.14.142355 修改为了预驱速度*)
VAR_INPUT
	i_xEn: BOOL; (*使能*)
	i_xReq_Cut: BOOL; (*裁切*)
	i_lrDiam_New: LREAL; (*新卷的卷径*)
	lrVel_Predrv: LREAL; (*修改为了预驱速度*)
	i_lrCoef_FilmVolPerimeter: LREAL := 1.5; (*料卷周长系数*)
	i_xUseTime:BOOL:=FALSE;
	i_lrDelayTimeMs: LREAL := 250;
	i_iCycleTime_Plc: INT;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL; (*功能块输出*)
	o_xRollerCylinderOutput: BOOL; (*胶辊输出*)
	o_xCut_ing: BOOL; (*裁刀已经出了*)
	o_iCutTotalTime:INT;(*2022.5.4.165847 裁切总时间ms|用于收料自动接料*)
END_VAR
VAR
	lrTotalDistance: LREAL; (*总共要走过的距离|单位:mm*)
	lrDisplacement_OneCycle: LREAL; (*单周期的位移量|单位:mm*)
	lrDisplacement_Total: LREAL := 0; (*总共的位移量|单位:mm*)

	iDelayMaxTimes: INT;
	iDelayTimesCnt: INT;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	iDelayMaxTimes:= LREAL_TO_INT(i_lrDelayTimeMs/INT_TO_LREAL(i_iCycleTime_Plc));

	IF (NOT o_xRollerCylinderOutput) AND i_xReq_Cut THEN
		o_xRollerCylinderOutput:= TRUE;
		lrDisplacement_Total:= 0;
		iDelayTimesCnt:= 0;
	END_IF



	IF i_xUseTime THEN
		(*2018.08.16.143649\通过时间延时|*)
		IF o_xRollerCylinderOutput AND (NOT o_xCut_ing) THEN (*开始计算要多久裁切完成*)
			iDelayTimesCnt:= iDelayTimesCnt+1;
			IF iDelayTimesCnt>=iDelayMaxTimes THEN
				o_xCut_ing:= TRUE;
				iDelayTimesCnt:= 0;
			END_IF
		END_IF

		o_iCutTotalTime:=LREAL_TO_INT(i_lrDelayTimeMs);
	ELSE
		lrTotalDistance:= i_lrCoef_FilmVolPerimeter * gc_lrPI * i_lrDiam_New; (*新卷需要走过的料长|单位:mm*)
		IF o_xRollerCylinderOutput AND (NOT o_xCut_ing) THEN (*开始计算要多久裁切完成*)
			lrDisplacement_OneCycle:= lrVel_Predrv * i_iCycleTime_Plc / 60.0; (*单周期走过的位移量|单位:mm*)
			lrDisplacement_Total:= lrDisplacement_Total + lrDisplacement_OneCycle;
			IF lrDisplacement_Total>=lrTotalDistance THEN
				o_xCut_ing:= TRUE;
				lrDisplacement_Total:= 0;
			END_IF
		END_IF
		(*2022.5.4.170240*)
		o_iCutTotalTime:=0;
		IF lrVel_Predrv<>0 THEN
			o_iCutTotalTime:=LREAL_TO_INT(lrTotalDistance/lrVel_Predrv*60);
		END_IF
	END_IF


	o_xEno:= TRUE;
ELSE
	iDelayTimesCnt:= 0;
	lrTotalDistance:= 0; (*总共要走过的距离|单位:mm*)
	lrDisplacement_OneCycle:= 0; (*单周期的位移量|单位:mm*)
	lrDisplacement_Total:= 0; (*总共的位移量|单位:mm*)
	o_xRollerCylinderOutput:= FALSE;
	o_xCut_ing:= FALSE;
	o_iCutTotalTime:=0;
	o_xEno:= FALSE;
END_IF