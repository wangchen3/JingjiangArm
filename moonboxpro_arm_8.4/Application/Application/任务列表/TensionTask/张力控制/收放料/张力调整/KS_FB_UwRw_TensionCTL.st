(*@CES
Name=KS_FB_UwRw_TensionCTL
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=db71b4fc-851f-434f-8f6c-f56559c6fd2e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_UwRw_TensionCTL
VAR_INPUT
	i_xEn: BOOL;
	i_xIsDebugMode:BOOL;(*调试模式*)
	i_xNegative_PiValue:BOOL;(*pi取反*)
	i_xMachineRev:BOOL;(*反向走料信号*)	
	i_xCutPressed: BOOL;(*裁切压辊合压标志*)
	i_xCancelPWhenCut:BOOL;(*裁切输出时取消p值标志|延时恢复*)	
	i_rVel_Film: REAL;(*料膜速度*)
	i_rAI: REAL;(*传感器反馈*)
	i_prVel_AxisCur: POINTER TO REAL;(*速度值-转速*)
	i_rKp: REAL;(*P值*)
	i_rKi: REAL;(*I值*)
	i_rKd: REAL;(*D值*)
	i_iCycleTime_Plc:INT;(*程序执行周期*)	
	i_xAccDecingCompensateEn:BOOL;	
	i_rFeedforwordValue_Uw: REAL;
	i_iCut_PIInput_Time: INT; (*放料裁切PI投入时间*)	
	(*放料翻转架补偿转速值|2021.7.26.092528*)
	i_rDeltaW_RPMIN:REAL;
	(*2021.9.13.132503|放料接料补偿值|窄方波+微分*)
	i_rSpliceCompensate:REAL;
	(*2021.8.26.170700|增加收放料主转速变化量-和是否使用预估卷径相关|使用则有值-否则=0*)
	i_rMailVel:REAL;
	i_rDiamCurAxis:REAL;(*当前卷径*)
	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_iErNo: INT;
	o_rStep:REAL;
	o_rPi_Value:REAL;	
	o_rTotalPiValue:REAL;(*总的pi控制量*)	
END_VAR
VAR
	iN: INT;
	iSum: INT:=100;
	rSum: REAL;
	rAverage: REAL;
	rPreVel_Film : REAL;
	arAI_Sum: ARRAY [1..200] OF REAL:= [200(0)];
	rUwRwForward_Step: REAL;(*前馈值*)
	arPID: ARRAY [1..3] OF REAL;
	rCoeff_I_UwCut: REAL;(*2024.8.20.103518|裁切时积分系数 *)	
	xFlag_CancleP: BOOL;(*取消P值标志*)
	iCut_PIInput_Count: INT:=0;(*放料裁切PID投入计时*)
	rPIValue: REAL;
	iNum_Old: INT:= 5;(*D值上个值的位置*)
END_VAR

{IMPLEMENTATION}
o_xEn:= i_xEn;
o_iErNo:= 0;
rSum:= 0;
FOR iN:= iSum TO 2 BY -1 DO(*滑窗的时候顺道算一下和*)
	arAI_Sum[iN]:= arAI_Sum[iN-1];
	rSum:= rSum+arAI_Sum[iN];
END_FOR
arAI_Sum[1]:= i_rAI;
rSum:= rSum+arAI_Sum[1];
rAverage:= rSum/iSum;(*计算平均值*)
arPID[1]:= i_rKp;
arPID[2]:= i_rKi;
arPID[3]:= i_rKd;

IF i_xEn THEN
	IF i_prVel_AxisCur<>0 AND i_rVel_Film>0 THEN
		(*先计算前馈值*)
		rUwRwForward_Step:= 0;
		IF i_xAccDecingCompensateEn THEN(*料膜加速完成了，才使用前馈*)
			IF i_rVel_Film<>rPreVel_Film AND rPreVel_Film<>0 AND i_rVel_Film>=10 THEN
				rUwRwForward_Step:= (i_rVel_Film-rPreVel_Film)/rPreVel_Film*i_prVel_AxisCur^*
								BOOL_TO_INT(i_xAccDecingCompensateEn);
			ELSE
				;
			END_IF
		END_IF
		
		(*小卷高速前馈*)
		IF i_rAI<0 THEN(*如果放料变松了，我们就不再需要这种前馈补偿了*)
			i_rFeedforwordValue_Uw:= 0;
		END_IF
		rUwRwForward_Step:= rUwRwForward_Step+ i_rFeedforwordValue_Uw;
		(*2024.8.22.093024 增加了放料裁切后积分的系数随摆臂位置的变化*)
		(*2024.8.20.103438 在接料的时候积分逐步加大-根据摆臂位置*)
		IF ABS(i_rAI)>2 THEN
			rCoeff_I_UwCut:=1.0/5.0;
		ELSIF ABS(i_rAI)>1 THEN
			rCoeff_I_UwCut:=1.0/4.0;
		ELSIF ABS(i_rAI)>0.5 THEN
			rCoeff_I_UwCut:=1.0/3.0;
		ELSE
			rCoeff_I_UwCut:=1.0/2.0;
		END_IF
		IF i_xCancelPWhenCut THEN
			xFlag_CancleP:= TRUE;
			iCut_PIInput_Count:= 0;
			i_rKp:= i_rKp*rCoeff_I_UwCut;
		ELSE
			IF xFlag_CancleP THEN
				IF i_iCut_PIInput_Time<= i_iCycleTime_Plc*iCut_PIInput_Count THEN(*PI投入时间到了*)
					iCut_PIInput_Count:=0;
					xFlag_CancleP:=FALSE;
				ELSE
					iCut_PIInput_Count:= iCut_PIInput_Count+1;
					i_rKp:= i_rKp*rCoeff_I_UwCut;
				END_IF
			END_IF
		END_IF
		rPIValue:= LREAL_TO_REAL(i_rKp/1000*i_rAI+
			i_rKd/100*(arAI_Sum[1]-arAI_Sum[iNum_Old]));
		IF i_xCutPressed THEN (*主要是放料*)
			rPIValue:=0;
		END_IF	
		IF i_xNegative_PiValue THEN(*PI取反|*)
			rPIValue:=-rPIValue;
		END_IF
	
		IF i_xMachineRev THEN(*反向走料|只需要取反调整量-主速度会在输出部分取反*)
			rPIValue:=-rPIValue;
		END_IF
		(*2021.7.26.092414 增加了翻转架运动补偿转速|*)
		IF i_prVel_AxisCur^+rPIValue+rUwRwForward_Step+i_rDeltaW_RPMIN+i_rMailVel+i_rSpliceCompensate<0 THEN
			i_prVel_AxisCur^:=0;
		ELSE
			i_prVel_AxisCur^:=i_prVel_AxisCur^+rPIValue+rUwRwForward_Step+i_rDeltaW_RPMIN+i_rMailVel+i_rSpliceCompensate;
			o_rTotalPiValue:=o_rTotalPiValue+rPIValue;(*统计pi控制量@2023.09.09.120357*)
		END_IF
		IF i_xIsDebugMode THEN
			IF i_rDiamCurAxis<>0 THEN
				i_prVel_AxisCur^:= LREAL_TO_REAL(i_rVel_Film*1000.0/gc_lrPi/i_rDiamCurAxis);
			END_IF
		END_IF
		o_rPi_Value:= rPIValue;
		o_rStep:= rUwRwForward_Step;
		o_xEn:= TRUE;		
	ELSE(*非印刷状态，料膜速度=0*)
		FOR iN:=1 TO iSum BY 1 DO
			arAI_Sum[iN]:=0;
		END_FOR
		iCut_PIInput_Count:=0;
		xFlag_CancleP:=FALSE;
		o_rPi_Value:= 0;
		o_rStep:= 0;
		o_xEn:= FALSE;		
	END_IF
	rPreVel_Film:= i_rVel_Film;
ELSE
	;
END_IF