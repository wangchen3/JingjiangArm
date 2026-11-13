(*@CES
Name=KS_FB_VelocityToVoltage
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b6ed5fff-3200-46a2-bf0a-c919750fea95
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_VelocityToVoltage (*将速度量转换为电压量*)
(*2024.04.14.124441 对输出转速值做伪随机叠加@伪随机值单位是r/min|对电压做伪随机叠加@单位是v*)
VAR_INPUT
	i_xEn: BOOL; (*使能*)
	i_xCurAxisIsA: BOOL; (*当前轴是否A轴*)
	i_xCut_end: BOOL; (*裁切完成*)
	i_uiNum: UINT; (*减速比分子*)
	i_uiDen: UINT; (*减速比分母*)
	i_rRatedRpm: REAL; (*额定转速*)
	i_rRatedFreq: REAL; (*额定频率*)
	i_rUpperFreq: REAL; (*上限频率*)
	i_rCoef_AxisA: REAL; (*A轴系数*)
	i_rCoef_AxisB: REAL; (*B轴系数*)
(*2019.10.09.145556|niu.j|替换为上下裁处理，无表里印逻辑*)
	(*i_xIsSurfacePrint: BOOL := FALSE;(*表印标志|*)*)
	i_xIsUpCut:BOOL;(*2018.5.11.154901 | niu.j | 增加上下裁刀配置不同时，速度取反*)
	i_xInch: BOOL := FALSE; (*停机状态下的放料速度测试|停机非张力投入时候使能*)
	i_xMachine_Rev:BOOL;(*反向走料，收放料速度取反*)
	i_prUwRwA_Feq:POINTER TO REAL;(*A轴频率*)
	i_prUwRwB_Feq:POINTER TO REAL;(*B轴频率*)
	(*输入输出修改为输入*)
	i_rDiam_New: REAL; (*新卷径*)
	i_rVel_UwRw: REAL; (*料膜速度|R/MIN*)
	i_rVel_PreDrv: REAL; (*预驱速度*)
	(*2021.9.2.091038 增加轴速度的调试模式|进行兼容*)
	i_xAxisDebugEn:BOOL;(*轴速度调试使能标志*)
	i_rAxisAVelDebug:REAL;(*调试的轴A速度|m/min*)
	i_rAxisAGirthDebug:REAL;(*调试的轴A周长|mm*)
	i_rAxisBVelDebug:REAL;(*调试的轴B速度|m/min*)
	i_rAxisBGirthDebug:REAL;(*调试的轴B周长|mm*)
(*
	(*2022.10.16.174805同步*)
	(*2022.9.8.171637 伪随机测试代码*)
	i_xVolAdditionTst:BOOL;
	i_pxRstRoundTimes:POINTER TO BOOL;
	i_prAmplitude:POINTER TO REAL;
(*	i_pxAmplitudeTestEn:POINTER TO BOOL;*)
	i_pbyTimesAddtionTst:POINTER TO BYTE;
*)
	i_xRevInch:BOOL;(*停机状态下放料反向单运行使能|2023.8.19.234634*)

	(*2024.05.24.110325+*)
	i_xPseudoRandomTsting				:BOOL;(*伪随机使能了*)
	i_rPseudoRandomRoundAmplitude_Cur	:REAL;(*伪随机值*)
	i_rDiam_Cut: REAL;//当前卷径用于计算单运行速度
	i_rVel_Inch_Print: REAL;//单运行速度2026.04.10.224012
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_rVolt_AxisA: REAL; (*A轴电压输出*)
	o_rVolt_AxisB: REAL; (*B轴电压输出*)
	(*2021.1.8.133018 增加的当前轴、预驱轴转速输出值*)
	o_rAxisAVel_RPM: REAL;(*A轴转速输出值*)
	o_rAxisBVel_RPM: REAL;(*B轴转速输出值*)
(*
	(*2022.10.16.174825 伪随机测试*)
	o_byRoundTime: BYTE;
	o_xAddtionTstting: BOOL;
	o_rVolAdditionValue:REAL;
*)
END_VAR
(*2021.9.2.093300 修改为输入变量*)
(*
VAR_IN_OUT
	io_lrDiam_New: LREAL; (*新卷径*)
	io_lrVel_UwRw: LREAL; (*料膜速度*)
	io_lrVel_PreDrv: LREAL; (*预驱速度*)
END_VAR
*)
VAR
	lrRatedRpm: LREAL; (*额定转速*)
	lrRatedFreq: LREAL; (*额定频率*)
	lrUpperFreq: LREAL; (*上限频率*)
	lrMaxRpm: LREAL; (*上限转速*)
	lrVel_Local: LREAL; (*本地速度|r/min*)
	lrVel_PreDrv: LREAL; (*预驱速度|m/min*)
	lrDiam_PreDrv: LREAL; (*预驱卷径*)
	lrCoef_Local: LREAL;
	lrAxisVolt_Local: LREAL;
	lrCoef_PreDrv: LREAL;
	lrAxisVolt_PreDrv: LREAL;

	lrAxisFeq_Local_Temp: LREAL;
	lrAxisFeq_PreDrv_Temp: LREAL;

	(*2021.1.8.133018 增加的当前轴、预驱轴转速输出值*)
	lrVel_RPM: LREAL;(*当前轴转速输出值*)
	lrVel_Predrv_RPM: LREAL;(*预驱轴转速输出值*)
(*
	(*2022.10.16.180513 伪随机测试*)
	abyDataList:ARRAY [1..20] OF BYTE:=20(1);(*数据列表|初值=1*)
	abyDataCoeffList:ARRAY [1..20] OF BYTE:=0,0,0,1,0,0,0,0,1,11(0);(*数据系数列表|*)
	arRandomDataList:ARRAY [1..2000] OF REAL;(*产生的随机数|*)
	iList: INT:=0;
	iRandomDataNum: INT:=1023;
	rAmplitude: REAL;
	xAmplitudeTestEn: BOOL;
	byTimesAddtionTst:BYTE;
	lrVel_Temp: LREAL;
*)
END_VAR

{IMPLEMENTATION}
(*---------------------------2017-08-18 10:56:50
/.该功能块在裁切换料完成之后进行预驱以及当前轴的卷径切换
/.同时要放在收放料裁切换料标志清零之前
.----------------------------------------------*)
IF i_xEn AND i_rRatedFreq<>0 THEN
	IF lrRatedRpm<>i_rRatedRpm OR lrRatedFreq<>i_rRatedFreq OR lrUpperFreq<>i_rUpperFreq THEN
		lrRatedRpm:= i_rRatedRpm;
		lrRatedFreq:= i_rRatedFreq;
		lrUpperFreq:= i_rUpperFreq;
		lrMaxRpm:= lrUpperFreq * lrRatedRpm / lrRatedFreq; (*最大转速=上限频率*额定转速/额定频率*)
	END_IF

	(*2021.9.2.095737  重新处理这部分赋值逻辑*)
	lrVel_Local:=0;
	lrVel_PreDrv:=0;
	IF NOT i_xAxisDebugEn THEN(*轴速度调试没使能*)
		(*预驱轴*)
		lrDiam_PreDrv:= i_rDiam_New;
		lrVel_PreDrv:=i_rVel_PreDrv;
		(*当前轴*)
		IF i_xInch THEN(*单动有效*)(*停机非张力投入时候使能*)
			//lrVel_Local:=10;
			//2026.04.10.224031
			IF i_rDiam_Cut<>0 THEN
				lrVel_Local:= i_rVel_Inch_Print*1000/i_rDiam_Cut/gc_lrPI;
			ELSE
				lrVel_Local:= 10;
			END_IF
		ELSIF i_xRevInch THEN(*2024.2.26.093059*)
			lrVel_Local:=-50;
		ELSE
			lrVel_Local:=i_rVel_UwRw;
		END_IF
	ELSE(*轴速度调试方式|*)
		IF i_xCurAxisIsA THEN(*A轴*)
			(*当前轴*)
			IF i_rAxisAGirthDebug<>0 THEN
				lrVel_Local:=i_rAxisAVelDebug/i_rAxisAGirthDebug*1000;(*r/min*)
			END_IF

			(*预驱轴*)
			lrDiam_PreDrv:= i_rAxisBGirthDebug/gc_lrPI;
			lrVel_PreDrv:=i_rAxisBVelDebug;(*m/min*)
		ELSE(*B轴*)
			(*当前轴*)
			IF i_rAxisAGirthDebug<>0 THEN
				lrVel_Local:=i_rAxisBVelDebug/i_rAxisBGirthDebug*1000;(*r/min*)
			END_IF
			(*预驱轴*)
			lrDiam_PreDrv:= i_rAxisAGirthDebug/gc_lrPI;
			lrVel_PreDrv:=i_rAxisAVelDebug;(*m/min*)
		END_IF
	END_IF

	IF i_xCurAxisIsA THEN
		lrCoef_Local:= i_rCoef_AxisA;
		lrCoef_PreDrv:= i_rCoef_AxisB;
	ELSE
		lrCoef_Local:= i_rCoef_AxisB;
		lrCoef_PreDrv:= i_rCoef_AxisA;
	END_IF
	IF lrMaxRpm<>0 AND lrRatedRpm<>0 THEN
		lrAxisVolt_Local:= lrCoef_Local * lrVel_Local * UINT_TO_LREAL(i_uiNum) / lrMaxRpm /  UINT_TO_LREAL(i_uiDen) * 10;
		lrAxisFeq_Local_Temp:= lrCoef_Local * lrVel_Local * UINT_TO_LREAL(i_uiNum)  * lrRatedFreq / lrRatedRpm /  UINT_TO_LREAL(i_uiDen);
	END_IF

	IF lrMaxRpm<>0 AND lrDiam_PreDrv<>0 THEN
		lrAxisVolt_PreDrv:= lrCoef_PreDrv * lrVel_PreDrv * UINT_TO_LREAL(i_uiNum) / lrMaxRpm / lrDiam_PreDrv / gc_lrPI / UINT_TO_LREAL(i_uiDen) * 10000.0;
		lrAxisFeq_PreDrv_Temp:= lrCoef_PreDrv * lrVel_PreDrv * UINT_TO_LREAL(i_uiNum) * lrRatedFreq / lrRatedRpm / lrDiam_PreDrv / gc_lrPI / UINT_TO_LREAL(i_uiDen)* 1000.0;
	ELSE
		lrAxisVolt_PreDrv:= 0;
	END_IF

	(*2021.1.8.132810 增加了当前轴和预驱轴的转速输出值|*)
	lrVel_RPM:= lrCoef_Local * lrVel_Local * UINT_TO_LREAL(i_uiNum)  /  UINT_TO_LREAL(i_uiDen) ;
	lrVel_Predrv_RPM:=0;
	IF lrDiam_PreDrv<>0 THEN
		lrVel_Predrv_RPM:= lrCoef_PreDrv * lrVel_PreDrv * UINT_TO_LREAL(i_uiNum) / lrDiam_PreDrv / gc_lrPI / UINT_TO_LREAL(i_uiDen) * 1000.0;
	END_IF

	(*重新实现伪随机*)
	IF i_xPseudoRandomTsting THEN(*处于伪随机中*)
		lrAxisVolt_Local:=i_rPseudoRandomRoundAmplitude_Cur+lrAxisVolt_Local;
		(*2024.04.14.124337+*)
		lrVel_RPM:=i_rPseudoRandomRoundAmplitude_Cur+lrVel_RPM;
	ELSE;
	END_IF



	(*2018.5.11.154901 | niu.j | 增加上下裁刀配置不同时，速度取反*)
(*2019.10.09.145556|niu.j|替换为上下裁处理，无表里印逻辑*)
	IF i_xIsUpCut THEN
		;
	ELSE
		lrAxisVolt_Local:= -lrAxisVolt_Local;
		lrAxisVolt_PreDrv:= -lrAxisVolt_PreDrv;

		(*转速的方向配置*)
		lrVel_RPM:=-lrVel_RPM;
		lrVel_Predrv_RPM:=-lrVel_Predrv_RPM;
	END_IF

	IF i_xMachine_Rev THEN(*反向走料时，速度取反*)
		lrAxisVolt_Local:= -lrAxisVolt_Local;
		lrAxisVolt_PreDrv:= -lrAxisVolt_PreDrv;

		(*转速的方向配置*)
		lrVel_RPM:=-lrVel_RPM;
		lrVel_Predrv_RPM:=-lrVel_Predrv_RPM;
	ELSE
		;
	END_IF

	IF i_xCurAxisIsA THEN
		o_rVolt_AxisA:= LREAL_TO_REAL(lrAxisVolt_Local);
		o_rVolt_AxisB:= LREAL_TO_REAL(lrAxisVolt_PreDrv);

		(*2021.1.8.133640处理AB轴转速输出*)
		o_rAxisAVel_RPM:= LREAL_TO_REAL(lrVel_RPM);
		o_rAxisBVel_RPM:= LREAL_TO_REAL(lrVel_Predrv_RPM);
		IF i_prUwRwA_Feq<>0 THEN
			i_prUwRwA_Feq^:= LREAL_TO_REAL(lrAxisFeq_Local_Temp);
		ELSE
			;
		END_IF
		IF i_prUwRwB_Feq<>0 THEN
			i_prUwRwB_Feq^:= LREAL_TO_REAL(lrAxisFeq_PreDrv_Temp);
		ELSE
			;
		END_IF
	ELSE
		o_rVolt_AxisA:= LREAL_TO_REAL(lrAxisVolt_PreDrv);
		o_rVolt_AxisB:= LREAL_TO_REAL(lrAxisVolt_Local);
		(*2021.1.8.133646处理AB轴转速输出*)
		o_rAxisAVel_RPM:= LREAL_TO_REAL(lrVel_Predrv_RPM);
		o_rAxisBVel_RPM:= LREAL_TO_REAL(lrVel_RPM);
		IF i_prUwRwA_Feq<>0 THEN
			i_prUwRwA_Feq^:= LREAL_TO_REAL(lrAxisFeq_PreDrv_Temp);
		ELSE
			;
		END_IF
		IF i_prUwRwB_Feq<>0 THEN
			i_prUwRwB_Feq^:= LREAL_TO_REAL(lrAxisFeq_Local_Temp);
		ELSE
			;
		END_IF
	END_IF
	o_xEno:= TRUE;


ELSE
	lrVel_Local:=0;
	lrVel_PreDrv:=0;
	o_rVolt_AxisA:= 0;
	o_rVolt_AxisB:= 0;
	o_rAxisAVel_RPM:=0;
	o_rAxisBVel_RPM:=0;
	lrAxisFeq_Local_Temp:=0;
	lrAxisFeq_PreDrv_Temp:=0;
	IF i_prUwRwA_Feq<>0 THEN
		i_prUwRwA_Feq^:= 0 ;
	END_IF
	IF i_prUwRwB_Feq<>0 THEN
		i_prUwRwB_Feq^:= 0;
	END_IF
	o_xEno:= FALSE;
END_IF