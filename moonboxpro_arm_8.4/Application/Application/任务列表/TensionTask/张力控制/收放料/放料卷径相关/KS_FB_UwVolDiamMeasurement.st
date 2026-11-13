(*@CES
Name=KS_FB_UwVolDiamMeasurement
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9f32bb8b-84d2-4732-bfc1-41e60baeebf8
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_UwVolDiamMeasurement(*2021.4.30.112012 更新卷径编码器方式测量时候的过圈以及轴对称时的处理方式|
										将手自动标志和测量方式区分开*)
(*2022.2.22.141830 绝对值编码器计算使用实际值，不再使用换算为电压区间的值了*)
(*2022.6.18.122917 增加了i_dwAbsEnCodeResolution接口*)
VAR_INPUT
	i_xEn:BOOL;
	i_xDiamMeasureAutomatic:BOOL;(*自动卷径测量标志*)
	i_rGirth_AxisA:REAL;(*轴a周长|MM*)
	i_rGirth_AxisB:REAL;(*轴b周长|MM*)
	i_xMultAxisParaEn:BOOL;(*多轴参数使能*)
	i_rVel_Film:REAL;(*料膜速度*)
	i_byDiamMeasureTypeId:BYTE;(*卷径测量方式值|=1 电位器=2编码器*)
	i_xCutOnTop:BOOL;(*TRUE  上裁刀| FALSE 下裁刀*)
	i_xCurAxisA:BOOL;(*当前轴标志*)
	i_rAi_DiamMeasure:REAL;(*卷径测量电压值*)
	i_xIsDebuging_DiaMeasure:BOOL;(*卷径测量调试过程中*)
	i_axMeasure_StdVol:ARRAY [1..4] OF BOOL;(*卷径测量按钮标志*)
	i_dwAbsEnCodeResolution:DWORD;(*2022.6.18.122901|该值可变化*)
	i_xEnCodeErr:BOOL;(*绝对值编码器故障*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_iErrCode: INT;(*-1 指针非法；-2输入 的数据错误,-3代表标准卷径没有单调性,-4代表区间索引错误*)
	o_xFlag_DiamMeasure_end:BOOL;(*卷径测量完成*)
	o_rVolt_CalcDiam_Used_Watch:REAL;(*用于监控*)
	o_xFlag_Type4AndDiamMeasure_end_UW:BOOL;	(*单个超声波且卷径计算完成输出标志|2024.1.10.174141*)
END_VAR
VAR_IN_OUT
	io_rDiam_NewVol:REAL;(*测量的新卷径*)
	io_xCancelDebuging_DiaMeasure: BOOL;(*调试模式下取消卷径测量按钮*)
	(*卷径测量参数集|BOOL_TO_INT(xCutterOnTop_Uw)做索引访问|*)
	io_astStStdVolParam_DnCut_UpCut: ARRAY [0..1] OF StStdVolParam_DnCut_UpCut;
END_VAR
VAR
	xFlag_CalDelay: BOOL;(*卷径计算延迟标志，测量卷径电位器电压的时候进行固定的周期延时，目的为了使得旋转架稳定*)
	iVar_DelayTimes: INT;
	uiDelayTimes: UINT:=50;(*延迟周期次数*)
	xStoreFinish: BOOL;(*10次采样电压值存储完成标志*)
	iStoreNum: INT:=0;
	arDiaMeaVol: ARRAY [1..15] OF REAL;
	iSamplingTimes:INT:=10;(*采样次数*)
	iN: INT;
	rSum_DiaMeaVol: REAL;
	rDia_Voltage_Sensored: REAL;(*到达对射电眼时的模拟量值*)(*用于卷径计算的电压值，经过10次平均*)
	byCutterOnTop_Uw: BYTE;(*上下裁刀标志，1为上裁刀,0为下裁刀*)
	arStdVol_Diam: ARRAY [1..c_byStdVol_Num] OF REAL;(*界面标准卷径值*)
	arStdVol_Volt: ARRAY [1..c_byStdVol_Num] OF REAL;(*界面标准电压值*)
	arStdVol_Coef: ARRAY [1..c_byStdVol_Num] OF REAL;(*界面的标准卷径系数，只用到1.2.3数组下标(c_byStdVol_Num-1)*)
	rDiam_NewVol_Uw: REAL;
	rAI_DiamMeasure_Uw_cur: REAL;(*放料卷径测量电压值*)
	iRtn: INT;
	iIndexSa: INT;(*标准卷径区间起始索引*)
	iIndexEd: INT;(*标准卷径区间结束索引*)

	aiWatch:ARRAY [1..10] OF INT;

	(*2021.4.30.112001 绝对值编码器卷径测量特殊处理*)
	xFlag_AxisABParaFroDiaMea_Uw: BOOL;(*放料使用ab轴分轴参数标志*)
	byDiamMeasureTypeId: BYTE;(*卷径测量方式|=1 电位器=2编码器*)
	xNextCycle: BOOL;(*过圈标志*)
(*	iAbsEncCycleVol:INT:=10;(*单圈电压值|绝对值对应电压值的最大值*)*)
	diAbsEncCycleVol:DINT:=8388608;(*单圈最大绝对值|23BIT*)
	iNextCycleArea: INT;(*过圈区间起始值|1代表1-2区间
										2代表2-3区间...*)
	xNeedAddCycle: BOOL;(*绝对值编码器时需要加圈标志*)
	xNeedDecCycle: BOOL;(*绝对值编码器时需要减圈标志*)
	iCoeff: INT;
	rTemp: REAL;
	xDiamMeasureAutomatic: BOOL;(*卷径测量手自动标志*)
END_VAR
VAR_OUTPUT
	o_xParamErr:BOOL;(*卷径参数错误*)
END_VAR
VAR CONSTANT
	c_byStdVol_Num:BYTE:=4;(*标准卷径个数*)
END_VAR
{IMPLEMENTATION}
(********************************************************************************
 *					放料手自动卷径测量功能块                                             * 
*零速下进行标准卷径测量                                                                     *
*非零速下进行手自动卷径的测量                                                              *
*i_UnWind_DiaMode 控制自动卷径测量方法：0：电位器测量 1：时间测量                        *
*i_xDiaMode_Auto 控制卷径测量方式： TRUE:自动，FALSE:手动                               *
**********************************************************************************)
o_iErrCode:=0;
o_xParamErr:=FALSE;
iIndexSa:=0;
iIndexEd:=0;
IF i_xEn THEN(*到达对射电眼位置并且在准备接料状态*)
(*指针合法性判断*)

	(*2022.6.18.123010*)
	diAbsEncCycleVol:= DWORD_TO_DINT(i_dwAbsEnCodeResolution);
	IF diAbsEncCycleVol<=0 THEN
		diAbsEncCycleVol:=8388608;
	END_IF

	xFlag_AxisABParaFroDiaMea_Uw:=i_xMultAxisParaEn;
	byDiamMeasureTypeId:=i_byDiamMeasureTypeId;(*卷径测量方式值|=1 电位器=2编码器*)
	byCutterOnTop_Uw:= BOOL_TO_BYTE(i_xCutOnTop);(*放料上下裁刀*)
	rAI_DiamMeasure_Uw_cur:=i_rAi_DiamMeasure;



	IF NOT xFlag_CalDelay THEN
		IF  iVar_DelayTimes>uiDelayTimes  THEN
			xFlag_CalDelay:=TRUE;
			iVar_DelayTimes:=0;
		ELSE
			iVar_DelayTimes:=iVar_DelayTimes+1;
		END_IF
	END_IF

	IF NOT xStoreFinish AND xFlag_CalDelay THEN
		IF byDiamMeasureTypeId=2 AND FALSE THEN(*编码器方式|不进行滤波,直接取值*)
			xStoreFinish:=TRUE;
			rDia_Voltage_Sensored:=rAI_DiamMeasure_Uw_cur;
		ELSE(*电位器方式|10次滤波*)
			iStoreNum:=iStoreNum+1;(*存储的模拟量个数*)
			arDiaMeaVol[iStoreNum]:=rAI_DiamMeasure_Uw_cur;
			IF iStoreNum>=iSamplingTimes AND iStoreNum<=15 THEN
				xStoreFinish:=TRUE;(*存储完成了*)
				rSum_DiaMeaVol:=0;
				FOR iN:=1 TO iStoreNum BY 1 DO(*计算模拟量的均值*)
					rSum_DiaMeaVol:=rSum_DiaMeaVol+arDiaMeaVol[iN];
				END_FOR
				rDia_Voltage_Sensored:=rSum_DiaMeaVol/iStoreNum;
			END_IF
		END_IF
	END_IF

	(*进行标准卷径测量*)
	IF xStoreFinish AND i_rVel_Film=0 THEN (**)
		FOR iN:=1 TO c_byStdVol_Num BY 1 DO
			IF i_xIsDebuging_DiaMeasure AND i_axMeasure_StdVol[iN] THEN(*卷径测量中|更新标准卷径电压值*)
				io_xCancelDebuging_DiaMeasure:=TRUE;(*取消标准卷径输入有效*)
(*2021.4.30.1125574重新处理单双轴系数的逻辑|
在单轴的系数的时候同时重写另外一个轴的参数|
保证2个轴参数一样*)
				IF NOT i_xCurAxisA THEN(*放料为B轴*)
					IF byDiamMeasureTypeId=2 THEN(*编码器方式|进行对称处理+5v取模*)
						io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]:=
						rDia_Voltage_Sensored;
						IF NOT xFlag_AxisABParaFroDiaMea_Uw THEN(*单轴*)
							rTemp:=rDia_Voltage_Sensored+DINT_TO_REAL(diAbsEncCycleVol)/2;
							IF rTemp>DINT_TO_REAL(diAbsEncCycleVol) THEN
								rTemp:=rTemp-DINT_TO_REAL(diAbsEncCycleVol);
							END_IF
							io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]:=rTemp;
						END_IF
		
					ELSIF byDiamMeasureTypeId=3 OR(*超声波@2023.08.29.100108*)
						byDiamMeasureTypeId=4 THEN(*单个超声波@2024.1.10.141323*)
						(*不区分上下裁刀*)
						io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisA[iN]:=
						rDia_Voltage_Sensored;
						io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisA[iN]:=
						rDia_Voltage_Sensored;
					ELSE(*电位器方式*)
						io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]:=
						rDia_Voltage_Sensored;
						IF NOT xFlag_AxisABParaFroDiaMea_Uw THEN(*单轴*)
							io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]:=
							rDia_Voltage_Sensored;
						END_IF
					END_IF

				ELSE
					IF byDiamMeasureTypeId=2 THEN(*编码器方式|进行对称处理+5v取模*)
						io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]:=
						rDia_Voltage_Sensored;
						IF NOT xFlag_AxisABParaFroDiaMea_Uw THEN(*单轴*)
							rTemp:=rDia_Voltage_Sensored+DINT_TO_REAL(diAbsEncCycleVol)/2;
							IF rTemp>DINT_TO_REAL(diAbsEncCycleVol) THEN
								rTemp:=rTemp-DINT_TO_REAL(diAbsEncCycleVol);
							END_IF
							io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]:=rTemp;
						END_IF

					ELSIF byDiamMeasureTypeId=3 OR(*超声波@2023.08.29.100108*)
						byDiamMeasureTypeId=4 THEN(*单个超声波@2024.1.10.141323*)
						(*不区分上下裁刀*)
						io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisB[iN]:=
						rDia_Voltage_Sensored;
						io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisB[iN]:=
						rDia_Voltage_Sensored;
					ELSE(*电位器方式*)
						io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]:=
						rDia_Voltage_Sensored;
						IF NOT xFlag_AxisABParaFroDiaMea_Uw THEN(*单轴*)
							io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]:=
							rDia_Voltage_Sensored;
						END_IF
					END_IF					
				END_IF
				 o_xFlag_DiamMeasure_end:=TRUE;(*不在进入自动计算卷径逻辑*)
				EXIT;
			END_IF
		END_FOR
	END_IF




(*卷径电压计算完成之后才能进行卷径测量*)
(*2019.01.28.113207|niu.j|增加卷径测量分轴|*)
	FOR iN:=1 TO c_byStdVol_Num BY 1 DO(*将界面的标准卷径值电压值写入临时变量中*)
		(*2021.4.30.100210 按轴取值*)
		(*IF xFlag_AxisABParaFroDiaMea_Uw THEN(*分轴做卷径*)*)
		IF NOT i_xCurAxisA THEN
(*			alrStdVol_Diam[iN]:=io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].arStdVol_Diam_AxisA[iN];*)
			arStdVol_Diam[iN]:=LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Diam[iN]);
			arStdVol_Volt[iN]:=LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]);
			arStdVol_Coef[iN]:=LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisA[iN]);
		ELSE
(*			alrStdVol_Diam[iN]:=io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].arStdVol_Diam_AxisB[iN];*)
			arStdVol_Diam[iN]:=LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Diam[iN]);
			arStdVol_Volt[iN]:=LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]);
			arStdVol_Coef[iN]:=LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisB[iN]);
		END_IF
	END_FOR


	(*2021.4.30.112546
	卷径测量方式为编码器时候需要做一些特殊处理|比如过圈，单轴系数时的对称处理*)
	xNextCycle:=FALSE;
	IF byDiamMeasureTypeId=2 THEN
		(*------------------------------------------START*)
		(*位置值过圈处理|过圈电位器方式认为是非法值.
		但是绝对值编码器却可以正常处理。
		为了适用下面逻辑.在这里做一些处理*)
		(*判定区间1和c_byStdVol_Num是否有过圈现象|距离拉大一些*)
		(*标准卷径过圈处理---start*)

		IF ABS(arStdVol_Volt[1]-arStdVol_Volt[c_byStdVol_Num])*2.0>DINT_TO_REAL(diAbsEncCycleVol) THEN(*区间的变化量超过半圈|我们认为过圈*)
			xNextCycle:=TRUE;
		END_IF
		xNeedAddCycle:=FALSE;
		xNeedDecCycle:=FALSE;
		iNextCycleArea:=0;
		IF xNextCycle THEN(*过圈|*)
			(*寻找过圈区间*)
			FOR iN:=1 TO c_byStdVol_Num-1 BY 1 DO(*将界面的标准卷径值电压值写入临时变量中*)
				IF ABS(arStdVol_Volt[iN]-arStdVol_Volt[iN+1])*2>DINT_TO_REAL(diAbsEncCycleVol) THEN(**)
					iNextCycleArea:=iN;
					EXIT;
				END_IF
			END_FOR
			(*过圈值变大还是变小确定后
			执行电压值+-圈*)
			IF iNextCycleArea<>0 THEN(*找到了过圈点*)
				IF arStdVol_Volt[iNextCycleArea+1]>arStdVol_Volt[iNextCycleArea] THEN(*下个值变大了|需要减小1圈为负值*)
					xNeedAddCycle:=FALSE;
					xNeedDecCycle:=TRUE;
				ELSE(*下个值变小了|需要增大一圈*)
					xNeedAddCycle:=TRUE;
					xNeedDecCycle:=FALSE;
				END_IF
			END_IF

			(*根据标志从过圈位置执行加圈减圈动作*)
			iCoeff:=0;
			IF xNeedAddCycle THEN
				iCoeff:=1;
			ELSIF xNeedDecCycle THEN
				iCoeff:=-1;
			END_IF
			IF iNextCycleArea<>0 THEN(*找到了过圈点*)
				FOR iN:=iNextCycleArea+1 TO c_byStdVol_Num BY 1 DO(*处理过圈的值*)
					arStdVol_Volt[iN]:=arStdVol_Volt[iN]+DINT_TO_REAL(iCoeff*diAbsEncCycleVol);
				END_FOR
			END_IF
		END_IF
		(*标准卷径过圈处理---end*)

		(*当前值的过圈处理|lrDia_Voltage_Sensored 是实际使用的值*)
		(*标准值是经过过圈处理后的值|*)
		IF xStoreFinish THEN(*位置值获取完成了|*)
			IF ABS(rDia_Voltage_Sensored-arStdVol_Volt[1])*2 > DINT_TO_REAL(diAbsEncCycleVol) AND (*和第某一个区间值偏差超过了半圈|当前值也过圈了*)
				 ABS(rDia_Voltage_Sensored-arStdVol_Volt[c_byStdVol_Num])*2 > DINT_TO_REAL(diAbsEncCycleVol) THEN(*当前值过圈了|*)
				FOR iN:=1 TO 2 BY 1 DO(*加圈值减圈值测试|判断是应该加还是减*)
					iCoeff:=iN*2-3;(*根据索引值计算系数值|1/-1*)
					rTemp:=rDia_Voltage_Sensored+DINT_TO_REAL(iCoeff*diAbsEncCycleVol);
					(*加减圈后找出和标准卷径值偏差不大的状态*)
					IF ABS(rTemp-arStdVol_Volt[1])*2.0 < DINT_TO_REAL(diAbsEncCycleVol) AND(*和半圈值比较*)
						ABS(rTemp-arStdVol_Volt[c_byStdVol_Num])*2 < DINT_TO_REAL(diAbsEncCycleVol) THEN(*和半圈值比较*)
						rDia_Voltage_Sensored:=rTemp;
						EXIT;
					END_IF
				END_FOR
			END_IF
		END_IF
		(*过圈问题处理完成了------------------------------END*)
	END_IF

	(*2022.6.9.162342*)
	xDiamMeasureAutomatic:=i_xDiamMeasureAutomatic;
	IF byDiamMeasureTypeId=2 THEN(*编码器方式接料的时候|使用手动*)
		IF i_xEnCodeErr THEN(*编码器出错了|只能使用手动*)
			xDiamMeasureAutomatic:=FALSE;
		END_IF
	END_IF
	IF xDiamMeasureAutomatic  AND xStoreFinish THEN (*卷径自动输入*)
(*2022.4.12.185204 屏蔽该条件|可以随时切换手自动*)
(*		IF NOT o_xFlag_DiamMeasure_end THEN (*放料卷径计算未完成*)*)

(*检查输入的标准卷径和标准卷径对应的电压值是否正确*)
			iRtn:=KS_MonotonousJudge(ADR(arStdVol_Diam), c_byStdVol_Num);
			aiWatch[1]:=iRtn;
			IF iRtn>0 THEN(*说明是单调递增或者单调递减*)
				iRtn:=KS_MonotonousJudge(ADR(arStdVol_Volt), c_byStdVol_Num);(*将电压的单调性变量作为最后的输出*)
				aiWatch[2]:=iRtn;
			ELSE;
			END_IF
			IF iRtn<=0 THEN(*说明数据有错 或者不存在单调性*)
				o_iErrCode:=-3;
				o_xParamErr:=TRUE;
			END_IF

(*参数正确了，这时候才能进行卷径计算*)
			IF NOT o_xParamErr THEN
			(*寻找输入的卷径电压位于那个标准区间*)
				KS_GetSection(
					rDia_Voltage_Sensored,
					ADR(arStdVol_Volt),
					ADR(iIndexSa),
					ADR(iIndexEd),
					c_byStdVol_Num);

(*计算卷径值*)

				IF iIndexSa>0 AND iIndexSa<=c_byStdVol_Num
					AND iIndexEd>0 AND iIndexEd<=c_byStdVol_Num THEN(*索引是有效的*)

					aiWatch[3]:=iIndexSa;
					aiWatch[4]:=iIndexEd;

					rDiam_NewVol_Uw:=arStdVol_Diam[iIndexSa]+(rDia_Voltage_Sensored-arStdVol_Volt[iIndexSa])*(arStdVol_Diam[iIndexEd]-arStdVol_Diam[iIndexSa])/
								(arStdVol_Volt[iIndexEd]-arStdVol_Volt[iIndexSa]);(*新算法*)

					aiWatch[5]:=LREAL_TO_INT(rDiam_NewVol_Uw);
					rDiam_NewVol_Uw:=rDiam_NewVol_Uw*arStdVol_Coef[iIndexSa];

					o_rVolt_CalcDiam_Used_Watch:= rDia_Voltage_Sensored;(*2019.11.27.093904_*)
					(*2022.9.14.161920*)
					IF rDiam_NewVol_Uw>90 AND rDiam_NewVol_Uw<=2000 THEN(*非法值处理*)
						o_xFlag_DiamMeasure_end:=TRUE;
					ELSE
						o_iErrCode:=-5;
						o_xParamErr:=TRUE;
						rDiam_NewVol_Uw:=222;(*给一个特殊值*)
					END_IF
				ELSE	(*索引无效*)
					o_iErrCode:=-4;
					o_xParamErr:=TRUE;
					rDiam_NewVol_Uw:=222;(*输出有一个特殊值*)
				END_IF
(*
				o_xFlag_DiamMeasure_end:=TRUE;
*)
			ELSE
				rDiam_NewVol_Uw:=222;(*输出有一个特殊值*)
			END_IF
(*2022.4.12.193149*)
(*		ELSE;
		END_IF*)
		io_rDiam_NewVol:=rDiam_NewVol_Uw;(*放料新卷径值*)
	ELSIF NOT xDiamMeasureAutomatic THEN(*卷径手动输入*)

		IF i_xCurAxisA THEN (*当前轴为A轴*)
(*			io_lrDiam_NewVol:=i_rGirth_AxisA/gc_lrPi;*)
			io_rDiam_NewVol:=i_rGirth_AxisB/gc_lrPi;(*2022.10.31.182325处理*)
		ELSE(*当前轴为B轴*)
(*			io_lrDiam_NewVol:=i_rGirth_AxisB/gc_lrPi;*)
			io_rDiam_NewVol:=i_rGirth_AxisA/gc_lrPi;(*2022.10.31.182325处理*)
		END_IF
		o_xFlag_DiamMeasure_end:=TRUE;
	END_IF
(*	g_lrDiam_NewVol_Uw:= i_pstStGrpParam^.lrDiam_NewVol_Uw;*)
(*	g_lrDiam_NewVol_Uw:= i_pstStGrpParam^.lrDiam_NewVol_Uw;*)
	(*单个超声波且卷径计算完成输出标志|2024.1.10.174141*)
	IF byDiamMeasureTypeId=4 AND o_xFlag_DiamMeasure_end THEN
		o_xFlag_Type4AndDiamMeasure_end_UW:=TRUE;
	ELSE
		o_xFlag_Type4AndDiamMeasure_end_UW:=FALSE;
	END_IF

ELSE
	o_xFlag_DiamMeasure_end:=FALSE;
	xFlag_CalDelay:=FALSE;
	xStoreFinish:=FALSE;
	iStoreNum:=0;
	iVar_DelayTimes:=0;
	o_xFlag_Type4AndDiamMeasure_end_UW:=FALSE;
END_IF

(*2021.4.30.100210 增加了单轴参数的同步动作|*)

byCutterOnTop_Uw:= BOOL_TO_BYTE(i_xCutOnTop);(*放料上下裁刀*)
xFlag_AxisABParaFroDiaMea_Uw:=i_xMultAxisParaEn;
byDiamMeasureTypeId:=i_byDiamMeasureTypeId;(*卷径测量方式值|=1 电位器=2编码器*)
FOR iN:=1 TO c_byStdVol_Num BY 1 DO
	IF byDiamMeasureTypeId=3 THEN(*模式=3@独立超声波|不能同步ab轴的参数|需要同步上下裁刀参数|2023.08.29.102325*)
		(*A轴*)
		rTemp:= LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]);
		IF byCutterOnTop_Uw=0 THEN(*当前下裁刀|更新上裁刀*)
			io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisA[iN]:=rTemp;(*更新上裁刀的值*)
			io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisA[iN]:=(*系数同步*)
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisA[iN];

			(*更新标准卷径值参数(不用区分ab轴|写在一个地方就好了)|2023.09.04.133242*)
			io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Diam[iN]:=
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Diam[iN];
		ELSE(*当前上裁刀|更新下裁刀*)
			io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisA[iN]:=rTemp;(*更新下裁刀的值*)
			io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisA[iN]:=(*系数同步*)
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisA[iN];

			(*更新标准卷径值参数(不用区分ab轴|写在一个地方就好了)|2023.09.04.133242*)
			(*2023.09.25.155913 索引写错了@[1]-->[0]*)
			io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Diam[iN]:=
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Diam[iN];
		END_IF
		(*b轴*)
		rTemp:= LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]);
		IF byCutterOnTop_Uw=0 THEN(*当前下裁刀|更新上裁刀*)
			io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Volt_AxisB[iN]:=rTemp;(*更新上裁刀的值*)
			io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisB[iN]:=(*系数同步*)
				io_astStStdVolParam_DnCut_UpCut[1].alrStdVol_Coef_AxisB[iN];
		ELSE(*当前上裁刀|更新下裁刀*)
			io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Volt_AxisB[iN]:=rTemp;(*更新下裁刀的值*)
			io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisB[iN]:=(*系数同步*)
				io_astStStdVolParam_DnCut_UpCut[0].alrStdVol_Coef_AxisB[iN];
		END_IF


	ELSE(*常规方式下,单轴就同步下ab轴参数*)
		IF NOT xFlag_AxisABParaFroDiaMea_Uw AND byDiamMeasureTypeId<>3 THEN(*单轴|模式=3@独立超声波|不能同步ab轴的参数*)
			IF NOT i_xCurAxisA THEN(*当前轴B轴*)
				(*A-->B*)
				rTemp:= LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]);
				IF byDiamMeasureTypeId=2 THEN(*编码器方式|进行对称处理+5v取模*)
					rTemp:=rTemp+DINT_TO_REAL(diAbsEncCycleVol)/2;
					IF rTemp>DINT_TO_REAL(diAbsEncCycleVol) THEN
						rTemp:=rTemp-DINT_TO_REAL(diAbsEncCycleVol);
					END_IF
				END_IF
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]:=rTemp;
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisB[iN]:=
					io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisA[iN];

			ELSE(*当前轴A轴*)
				(*b-->a*)
				rTemp:= LREAL_TO_REAL(io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisB[iN]);
				IF byDiamMeasureTypeId=2 THEN(*编码器方式|进行对称处理+5v取模*)
					rTemp:=rTemp+DINT_TO_REAL(diAbsEncCycleVol)/2;
					IF rTemp>DINT_TO_REAL(diAbsEncCycleVol) THEN
						rTemp:=rTemp-DINT_TO_REAL(diAbsEncCycleVol);
					END_IF
				END_IF
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Volt_AxisA[iN]:=rTemp;
				io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisA[iN]:=
					io_astStStdVolParam_DnCut_UpCut[byCutterOnTop_Uw].alrStdVol_Coef_AxisB[iN];

			END_IF
		END_IF
	END_IF
END_FOR


o_xEn:=i_xEn;