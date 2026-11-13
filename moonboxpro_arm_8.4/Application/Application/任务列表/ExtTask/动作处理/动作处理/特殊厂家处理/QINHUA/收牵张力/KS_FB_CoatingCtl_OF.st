(*@CES
Name=KS_FB_CoatingCtl_OF
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=76f6afa6-7c3c-46f9-b256-a9cc133bff9b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CoatingCtl_OF
VAR_INPUT
	i_xEn : BOOL;
	i_iGrpId: INT;
	i_xSwitchOn : BOOL;
	i_plrUsingGirth : POINTER TO REAL;
	i_pastStIOMap_Main_FE						: POINTER TO ARRAY [1..4] OF StIOMap_Main_FE;(*轴io数据区域|AB系*)
	i_pastStIOMap_Axis_FE					: POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StIOMap_Axis_FE;(*轴io数据区域|*)
	i_pstStSysParam							: POINTER TO StSysParam;
	i_rPressure_Input :REAL;
	i_iKp: INT;
	i_iKi: INT;
	i_iTSK_CYCLE_TIME : INT;
END_VAR
VAR_OUTPUT
	o_lrCur_PressureValue : LREAL;
END_VAR
VAR
	iN : INT;
	iAxisId : INT;
	xStartInit : BOOL;
	xStopInit : BOOL;
	xPrintInit : BOOL;
	xEvenning : BOOL;
	xConditionDone : BOOL;
	iCalGirthCount : INT;
	iCycleCount : INT;
	lrPreGirth : REAL;
	lrAnalogInput_Pressure : LREAL;
	lrAnalogMiddle :LREAL;
	lrAnalogDifference : LREAL;
	iSecondLinkageAxis : INT;
	rPreCurVel : REAL;
	lrAnalog_Sum : LREAL;
	lrAnalog_Aver : LREAL;
	xCalcGirthEn : BOOL;
	lrGirthTemp : LREAL;
	lrGirthStep_Temp : LREAL;
	rGirthStep : REAL := 0.01;
	rThreshold : REAL;
	lrPreAnalog_Aver : LREAL;
	xInit : BOOL;
	rSlopeAboutPress : REAL := 72.0;//压力斜率
	rPaperThickness_Min : REAL := 30;
	rPaperThickness_Max : REAL := 100;
	rPaperThickness_Cur : REAL;
	rPressure_Min : REAL := 240.0;
	rPressure_Max : REAL := 480.0;
	rPaperThicknessDifference : REAL;
	rSlope_Temp : REAL;
	rB : REAL;
	rPressure_Tar : REAL;
	iTimeAdjNum: INT;
	rVel_pre:REAL;
	rStep_Compension: REAL;
END_VAR
VAR CONSTANT
	c_iSpd_AdjTime: UINT:=80;//2025.2.8.160344根据速度切换调整频次，低于80米，3s调整一次，高于80米，2s调整一次
	c_tiTimeAdj_L: TIME:=T#3000MS;//调整频次3S
	c_tiTimeAdj_H: TIME:=T#2000MS;//调整频次2S
	c_rMaxAdjustValue: REAL:=0.025;//摆臂调整最大调整量
//	c_rMinAdjustValue: REAL:=0;//最小调整量
	c_rStep_Compension: REAL:= 0.0025;//前馈补偿，加速负值，减速正值
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_plrUsingGirth<>0 AND
		i_pastStIOMap_Axis_FE<>0 AND
		i_pastStIOMap_Main_FE<>0 AND
		i_pstStSysParam<>0 THEN(*指针合法*)
		
		IF NOT xStartInit THEN(*开机初始化上个周期的版周长*)
			xStartInit:=TRUE;
			lrPreGirth:= i_plrUsingGirth^;
		END_IF
		
		IF i_rPressure_Input = 0 THEN
			i_rPressure_Input := 1;
		END_IF
		IF g_xInitPressSlope AND (ABS(i_rPressure_Input)>0.001) THEN
			g_xInitPressSlope := FALSE;
			rSlopeAboutPress := g_rPressValue/i_rPressure_Input;
		END_IF
		rSlopeAboutPress := 200.0;
		lrAnalogInput_Pressure := i_rPressure_Input * rSlopeAboutPress;
		
		o_lrCur_PressureValue:= lrAnalogInput_Pressure;		
		(*电压值转换为压力大小用于显示*)
		IF rSlopeAboutPress = 0 THEN
			rSlopeAboutPress := 1;
		END_IF

		lrAnalogMiddle:=i_pstStSysParam^.astStGrpParam_Save[i_iGrpId].rPressure_Tar/rSlopeAboutPress;(* (*i_pstStGrpParam^.rPressure_Tar*)*10/g_rPressure_Max(*i_pstStGrpParam^.rPressure_Max*);(*目标压力对应的电压值*)*)
		(*目标压力对应电压值-即中位值*)
		lrAnalogDifference:=i_rPressure_Input-lrAnalogMiddle;(*中位差值*)

		IF i_xSwitchOn THEN
			IF i_pastStIOMap_Axis_FE^[1].o_xRel_Press AND
				i_pastStIOMap_Main_FE^[2].o_xRel_Press_OF AND
				i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Print THEN(*压力传感器调整使能*)
				xStopInit:=TRUE;
				IF NOT xPrintInit THEN
					xPrintInit:=TRUE;
					lrPreGirth:=i_plrUsingGirth^;(*初始化版周长,记下开机前的1色版周长*)
				END_IF
	
				xEvenning:=FALSE;(*稳速标志*)
				IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film(*i_Vel_Film*)>=10  THEN(*速度大于一定值，并且处于匀速*)
					xEvenning:=TRUE;(*稳速标志*)
				END_IF
				xConditionDone:=FALSE;(*延时500周期进入计算周长状态，延时完成标志*)
				IF xEvenning THEN(*进入匀速状态之后 等待一段时间在进入计算周长状态*)
					iCalGirthCount:=iCalGirthCount+1;
					IF iCalGirthCount>=286(*500*) THEN (*延迟500个周期 进入计算周长状态*)
						iCalGirthCount:=iCalGirthCount-1;
						xConditionDone:=TRUE;
					END_IF
				ELSE
					iCalGirthCount:=0;
				END_IF
				(*模拟量平均----*)
				iCycleCount:=iCycleCount+1;
				lrAnalog_Sum:=lrAnalog_Sum+lrAnalogDifference;
				xCalcGirthEn:=FALSE;

//2025.2.8.173856				xCalcGirthEn:=TRUE;
				(*----------------*)
	//2025.01.23.171553 | 升降速调整0.02，稳速调整0.005
				IF (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing) AND (NOT i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stoping)  THEN
					rGirthStep := 0.02;
				ELSE
					rGirthStep := 0.01;
				END_IF
				IF g_xTensionAdjust_NewWay THEN//
					//2025.2.8.162956
					IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film<80 THEN
						iTimeAdjNum:= UINT_TO_INT(TIME_TO_UINT(c_tiTimeAdj_H)/ i_iTSK_CYCLE_TIME);
					ELSE
						iTimeAdjNum:= UINT_TO_INT(TIME_TO_UINT(c_tiTimeAdj_H)/ i_iTSK_CYCLE_TIME);
					END_IF
					IF iCycleCount>=iTimeAdjNum(*50*) THEN
						lrAnalog_Aver:=lrAnalog_Sum/iCycleCount; (*计算调整周期内压力传感器输入平均值*)
						lrAnalog_Sum:=0;
						iCycleCount:=0;
						xCalcGirthEn:=TRUE;
					ELSE;
					END_IF
					//放这里做一个PID调整算法2025.2.8.162019
					IF i_iKp=0 THEN
						i_iKp:=30;
					END_IF
					IF i_iKi=0 THEN
						i_iKi:=50;
					END_IF
					IF xConditionDone AND xCalcGirthEn THEN
						//2025.2.8.175524
						rGirthStep:=lrAnalog_Aver*INT_TO_REAL(i_iKp)/1000.0+INT_TO_REAL(i_iKi)*(lrAnalog_Aver-lrPreAnalog_Aver)/100.0;
						IF i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Accing OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Decing THEN
							rStep_Compension:= -1*(i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film-rVel_pre)*c_rStep_Compension;
						ELSE
							rStep_Compension:= 0;
						END_IF
						g_rGirthStep := rGirthStep;
						g_rGirthStep_Kp := lrAnalog_Aver*INT_TO_REAL(i_iKp)/1000.0;
						g_rGirthStep_Ki := INT_TO_REAL(i_iKi)*(lrAnalog_Aver-lrPreAnalog_Aver)/100.0;
						g_lrAnalog_Aver := lrAnalog_Aver;
						g_rStep_Compension := rStep_Compension;
						
						IF ABS(lrAnalog_Aver) < g_rPressure_AnalogThreshold THEN
							g_rGirthStep := 0;
							rGirthStep := 0;
							g_rGirthStep_Kp := 0;
							g_rGirthStep_Ki := 0;
							g_rStep_Compension := 0;
						ELSE
							IF rGirthStep>c_rMaxAdjustValue THEN
								rGirthStep:= c_rMaxAdjustValue;
							ELSIF rGirthStep<-1*c_rMaxAdjustValue THEN
								rGirthStep:= -1*c_rMaxAdjustValue;
							END_IF

						END_IF
						IF ABS(lrPreGirth-i_plrUsingGirth^)<=3 THEN(*调整限值±3mm*)
							i_plrUsingGirth^:=i_plrUsingGirth^+rGirthStep+rStep_Compension;
						ELSE
							;
						END_IF
						
						lrPreAnalog_Aver:=lrAnalog_Aver;	
						rVel_Pre:= i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film;
					END_IF
				ELSE
					IF iCycleCount>28(*50*) THEN
						lrAnalog_Aver:=lrAnalog_Sum/iCycleCount; (*计算调整周期内压力传感器输入平均值*)
						lrAnalog_Sum:=0;
						iCycleCount:=0;
						xCalcGirthEn:=TRUE;
					ELSE;
					END_IF
					lrGirthTemp:=0;(*版周长步进量临时变量*)
					lrGirthStep_Temp:=rGirthStep; (*版周长步进量*)
					IF xConditionDone AND xCalcGirthEn THEN
						IF ABS(lrAnalog_Aver)>g_rPressure_AnalogThreshold(*i_pstStGrpParam^.rPressure_AnalogThreshold*) THEN
							rThreshold:=0.001;
						ELSE
							rThreshold:=0;
						END_IF
		
						IF  lrAnalog_Aver >g_rPressure_AnalogThreshold(*i_pstStGrpParam^.rPressure_AnalogThreshold*) THEN
							IF  lrAnalog_Aver>lrPreAnalog_Aver+rThreshold THEN(*位置值越来越大了*)
								lrGirthTemp:=lrGirthStep_Temp;
							END_IF
						ELSIF  lrAnalog_Aver <-g_rPressure_AnalogThreshold(*i_pstStGrpParam^.rPressure_AnalogThreshold*)  THEN
							IF  lrAnalog_Aver+rThreshold<lrPreAnalog_Aver THEN(*位置值越来越小了*)
								lrGirthTemp:=-lrGirthStep_Temp;
							END_IF
						END_IF
		
					END_IF
		
					IF ABS(lrPreGirth-i_plrUsingGirth^)<=3 THEN(*调整限值±3mm*)
						i_plrUsingGirth^:=i_plrUsingGirth^+lrGirthTemp;
					ELSE
						;
					END_IF
					lrPreAnalog_Aver:=lrAnalog_Aver;
				END_IF

//2025.2.8.162541				
(*
*)
	
			ELSE
				//2025.07.06.232420 | 印后牵引恢复默认周长增加停止标志
				IF xStopInit AND (i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_Stop OR i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].xFlag_EStop)  THEN (*停机*)
					xStopInit:=FALSE;
					i_plrUsingGirth^:=lrPreGirth;
				END_IF
				xPrintInit:=FALSE;
			END_IF
		ELSE
			;
		END_IF
	ELSE
		;
	END_IF
	rPreCurVel:=i_pstStSysParam^.astStGrpParam_UnSave[i_iGrpId].rVel_Film(*i_Vel_Film*);
	;
ELSE
	;
END_IF

