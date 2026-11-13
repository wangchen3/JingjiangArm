(*@CES
Name=KS_FB_Stiffen
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=ebf8a35e-b38d-43d8-bd45-fc76d06004b3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Stiffen
(*2022.1.7.171452 慢速松料逻辑修改：
慢速松料最大转速限制修改为变量,设置为5r/min
松料加减速分开设置,减速尽量快好一些。
*)
VAR_INPUT
	i_xEn: BOOL;(*使能标志|*)
	i_xDebugMode:BOOL;(*调试模式*)
	i_lrAI_Uw: LREAL;(*放料电位器输入|*)
	i_lrAI_Rw: LREAL;(*收料电位器输入|*)
	(*2019.9.26.091700 增加了取消张力投入时考虑收放牵摆臂的逻辑|Liu.yt*)
	i_lrAI_If:LREAL;(*放牵模拟量输入*)
	i_lrAI_Of:LREAL;(*收牵模拟量输入*)
	i_xRollerSts_If:BOOL;(**牵引压辊状态*)
	i_xRollerSts_Of:BOOL;(**牵引压辊状态*)
(*	i_lrVel_base: LREAL := 2.0;(*速度的基础值|*)*)
(*	i_lrCoeff_Stiffen: LREAL := 2.0;(*拉料速度系数|*)*)
	i_lrThreshold_Stiffen: LREAL := 0.5;(*拉料进入稳定状态的阀值|*)
	i_prVel_Uw: POINTER TO REAL := 0;(*放料速度值的地址|*)
	i_prVel_Rw: POINTER TO REAL := 0;(*收料速度值的地址|*)
	i_xMachineRev: BOOL;(*反向走料*)

	i_xCancelTenEn: BOOL;(*取消张力时慢放使能*)

	i_lrFilmVel:LREAL;
	i_xFlag_Print:BOOL;(*印刷状态*)
	i_lrDiamCurAxis_Uw:LREAL;(*正常印刷的时候放料卷径*)
	i_lrDiamCurAxis_Rw:LREAL;(*正常印刷的时候收料卷径*)
	i_iInitial_speed_Uw:INT;
	i_iInitial_speed_Rw:INT;
	i_iwindCoff:INT;
	i_iUnwindCoff:INT;
	i_iCycleTime_Plc: INT;
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;(*返回i_xEn的值|*)
	o_iErNo: INT;(*0无错误\<0有错误发生|*)
	o_xStiffenDone: BOOL;(*拉料完成标志|*)
	o_xZeroServo_Uw: BOOL;(*放料零伺服|*)
	o_xForeward_Uw: BOOL;(*放料使能\正转|*)
	o_xZeroServo_Rw: BOOL;(*收料零伺服|*)
	o_xForeward_Rw: BOOL;(*收料使能\正转|*)
(*	o_xUwInverterEna: BOOL;
	o_xRwInverterEna: BOOL;*)
	o_lrAIMax_Uw: LREAL;
	o_lrAIMin_Uw: LREAL;
	o_lrAIMax_Rw: LREAL;
	o_lrAIMin_Rw: LREAL;
	o_lrAIMin_If: LREAL;
	o_lrAIMax_If: LREAL;
	o_lrAIMin_Of: LREAL;
	o_lrAIMax_Of: LREAL;	
END_VAR
VAR
	xFlagDone_Uw: BOOL;
	xFlagDone_Rw: BOOL;


	iStep_UW: INT; (*放料拉料流程*)
	lrDetAnalogInput_Unwind: LREAL;(*放料模拟量的变化量*)
	lrPreAnalogInput_Unwind: LREAL;(*上个周期的模拟量值*)
	iN: INT;
	iSum: INT:=5;
	arUnwindCompensate: ARRAY [1..10] OF REAL;
	rUnwindStep_GE1:REAL:=0.02;(*放料大于1v的时候补偿量*)
	iUnwindCompensate_LT1:REAL:=20;(*放料小于1v的时候补偿量系数*)
	rUnWindCompensate_Sum: REAL;(*放料累积量总和*)

	lrDetAnalogInput_wind: LREAL;
	lrPreAnalogInput_wind: LREAL;(*上个周期的模拟量值*)
	arwindCompensate: ARRAY [1..10] OF REAL;
	arwindStep_GE1:REAL:=0.02;(*收料大于1v的时候补偿量*)
	iwindCompensate_LT1:REAL:=20;(*收料小于1v的时候补偿量系数*)
	rWindCompensate_Sum: REAL;(*收累积量总和*)
	alrAnalog_InputUnwind: ARRAY [1..10] OF LREAL;
	alrAnalog_Inputwind: ARRAY [1..10] OF LREAL;
	iUnwindCount: INT:=1;
	iwindCount: INT:=1;
	lrUnwindTemp: LREAL;
	lrWindTemp: LREAL;
	iUnwindCoff: INT:=10;
	iwindCoff: INT:=10;
	iInitial_speed_Uw:INT:=10;
	iInitial_speed_Rw:INT:=10;
	iStep_RW: INT; (*收料拉料流程*)
	lrUnwindCompensate: LREAL;(*放料的每个周期的补偿值*)
	lrwindCompensate: LREAL;(*收料的每个周期的补偿值*)
	lrAcc: LREAL;(*开始拉料时候的加速度*)
	lrAcc_Time: LREAL:=0.2;(*开始拉料时候的加速时间S*)
	lrTemp: LREAL;

	iInitial_speed_Temp: INT;
	xPreWindZero: BOOL;
	xPreUnWindZero: BOOL;
	lrVel_Temp_Uw: LREAL;
	iDecTime: INT:=100;(*ms*)
	lrBaseVel: LREAL;
	lrVel_Temp_Rw: LREAL;


	iCancelTenVel:INT:=10;(*取消张力的速度*)
	iCancelTenAccTime: INT:=1000;(*取消张力加速时间ms*)
	iCancelTenDecTime: INT:=300;(*取消张力减速时间ms*)
	lrCancelTenRate:LREAL;(*取消张力的转速*)
	lrDelRate_Acc: LREAL;(*单个周期的转速变化量-加速*)
	lrDelRate_Dec: LREAL;(*单个周期的转速变化量-减速*)
	xStopFrom_Ten_Uw: BOOL;(*从张力投入状态停止*)
	xStopFrom_Print_Uw: BOOL;(*从印刷状态停止*)
	xCancelTenRateDec_Uw: BOOL;(*取消张力状态转速减速标志*)
	iCnt_Uw: INT;(*计数*)


	xStopFrom_Ten_Rw: BOOL;(*从张力投入状态停止*)
	xStopFrom_Print_Rw: BOOL;(*从印刷状态停止*)
	xCancelTenRateDec_Rw: BOOL;(*取消张力状态转速减速标志*)
	iCnt_Rw: INT;(*计数*)
	rMargin:REAL:=1;(*慢松料逻辑的余量，默认1v*)
	rMaxRate_CancelTen:REAL:=5;(*慢松料最大转速|2022.1.7.171923 增加*)

	(*2020.1.3.145333增加收放料和收放牵ai是否有效标志*)
	xAIValid_Uw: BOOL:=FALSE;
	xAIValid_Rw: BOOL:=FALSE;
	xAIValid_If: BOOL:=FALSE;
	xAIValid_Of: BOOL:=FALSE;
END_VAR

{IMPLEMENTATION}
(*增加拉料系数输入|L.YT|2019.6.29.154256*)
IF i_iUnwindCoff <=0 THEN
	iUnwindCoff:=10;
ELSE
	iUnwindCoff:=i_iUnwindCoff;
END_IF
IF i_iwindCoff <=0 THEN
	iwindCoff:=10;
ELSE
	iwindCoff:=i_iwindCoff;
END_IF
IF i_iInitial_speed_Uw <=0 THEN
	iInitial_speed_Uw:=10;
ELSE
	iInitial_speed_Uw:=i_iInitial_speed_Uw;
END_IF
IF i_iInitial_speed_Rw <=0 THEN
	iInitial_speed_Rw:=10;
ELSE
	iInitial_speed_Rw:=i_iInitial_speed_Rw;
END_IF


o_xEno:= i_xEn;
o_iErNo:= 0;

(*2019.08.06.163951|niu.j|指针合法判断*)
IF i_prVel_Uw<>0 AND i_prVel_Rw<>0 THEN
	;
ELSE
	RETURN;
END_IF

FOR iN:=iSum TO 2 BY -1 DO
	arUnwindCompensate[iN]:=arUnwindCompensate[iN-1];
	arwindCompensate[iN]:=arwindCompensate[iN-1];
END_FOR

IF  ABS(i_lrAI_Uw)>1 THEN
	IF i_lrAI_Uw>1 THEN
		arUnwindCompensate[1]:=-rUnwindStep_GE1;
	ELSE
		arUnwindCompensate[1]:=rUnwindStep_GE1;
	END_IF
ELSE
	arUnwindCompensate[1]:= LREAL_TO_REAL(-(i_lrAI_Uw)/iUnwindCompensate_LT1);(*累计量数组*)
END_IF

IF  ABS(i_lrAI_Rw)>1 THEN(*补偿量的方向和模拟量的方向一致*)
	IF i_lrAI_Rw>1 THEN
		arwindCompensate[1]:=-arwindStep_GE1;
	ELSE
		arwindCompensate[1]:=arwindStep_GE1;
	END_IF
ELSE
	arwindCompensate[1]:= LREAL_TO_REAL(-(i_lrAI_Rw)/iwindCompensate_LT1);(*累计量数组*)
END_IF


rUnWindCompensate_Sum:=0;
rWindCompensate_Sum:=0;
FOR iN:=1 TO iSum BY 1 DO(*计算总的累积和~~*)
	rUnWindCompensate_Sum:=rUnWindCompensate_Sum+arUnwindCompensate[iN];
	rWindCompensate_Sum:=rWindCompensate_Sum+arwindCompensate[iN];
END_FOR

FOR iN:=10 TO 2 BY -1 DO(*存储前几个周期的模拟量值*)
	alrAnalog_InputUnwind[iN]:=alrAnalog_InputUnwind[iN-1];
	alrAnalog_Inputwind[iN]:=alrAnalog_Inputwind[iN-1];
END_FOR

alrAnalog_InputUnwind[1]:= i_lrAI_Uw;
alrAnalog_Inputwind[1]:= i_lrAI_Rw;

(*2020.1.3.144851 增加了收放料摆臂以及收放牵摆臂存在检验标志|用于慢速松料功能|Liu.yt*)
IF i_lrAI_Uw >0.1 OR i_lrAI_Uw<-0.1 THEN
	xAIValid_Uw:=TRUE;
END_IF

IF i_lrAI_Rw >0.1 OR i_lrAI_Rw<-0.1 THEN
	xAIValid_Rw:=TRUE;
END_IF

IF i_lrAI_If >0.1 OR i_lrAI_If<-0.1 THEN
	xAIValid_If:=TRUE;
END_IF

IF i_lrAI_Of >0.1 OR i_lrAI_Of<-0.1 THEN
	xAIValid_Of:=TRUE;
END_IF


(*模拟量正负控制电机正反转*)(*反转是负电压，正转为正电压*)
IF i_xEn THEN(*拉料功能块使能即张力投入状态*)
	IF iStep_UW =STIFFEN_STEP_Stop  THEN
		iStep_UW:=STIFFEN_STEP_Start;
		lrDetAnalogInput_Unwind:=0;
	END_IF

	IF  iStep_RW=STIFFEN_STEP_Stop THEN
		iStep_RW:=STIFFEN_STEP_Start;
		lrDetAnalogInput_wind:=0;
	END_IF

	CASE iStep_UW OF(*放料流程*)
		STIFFEN_STEP_Start:(*开始启动*)
			IF NOT i_xMachineRev THEN
				IF i_lrAI_Uw <0 THEN(*料松了*)
					iInitial_speed_Temp:=-iInitial_speed_Uw;
				ELSIF  i_lrAI_Uw >0   THEN (*料紧了*)
					iInitial_speed_Temp:=iInitial_speed_Uw;
				ELSE
					iInitial_speed_Temp:=0;
				END_IF
			ELSE
				IF i_lrAI_Uw >0 THEN(*料松了*)
					iInitial_speed_Temp:=-iInitial_speed_Uw;
				ELSIF  i_lrAI_Uw <0   THEN (*料紧了*)
					iInitial_speed_Temp:=iInitial_speed_Uw;
				ELSE
					iInitial_speed_Temp:=0;
				END_IF
			END_IF
			lrAcc:=iInitial_speed_Temp/(lrAcc_Time*1000);(*R/MIN/MS*)

			o_xForeward_Uw:=TRUE;
			IF ABS(i_prVel_Uw^+lrAcc*gc_TENSION_TSK_CYCLE_TIME)<=ABS(iInitial_speed_Temp)THEN
				i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^+lrAcc*gc_TENSION_TSK_CYCLE_TIME);(*放料角速度=10R/MIN*)(*程序执行周期为20ms*)
			ELSE
				i_prVel_Uw^:=iInitial_speed_Temp;
			END_IF
			lrDetAnalogInput_Unwind:=lrDetAnalogInput_Unwind+ i_lrAI_Uw-lrPreAnalogInput_Unwind;
			IF ABS(lrDetAnalogInput_Unwind) >0.05 THEN(*模拟量的变化量大于0.05认为摆臂发生运动了*)
				iStep_UW:=STIFFEN_STEP_Compensate;
			END_IF
		STIFFEN_STEP_Delay:
			IF iUnwindCount>=iSum-1 THEN(*第iSum个周期后进入调整过程中，即状态3*)
				iUnwindCount:=1;
				iStep_UW:=STIFFEN_STEP_Compensate;
			ELSE
				iUnwindCount:=iUnwindCount+1;
			END_IF
		STIFFEN_STEP_Compensate:
			lrUnwindTemp:=(alrAnalog_InputUnwind[1]-alrAnalog_InputUnwind[6]);
			lrUnwindCompensate:=(REAL_TO_LREAL(rUnWindCompensate_Sum)-(lrUnwindTemp))/INT_TO_LREAL(iUnwindCoff);
			(*当前模拟量减去前第5个周期的模拟量得到的变化量与存储的前五个周期的变化量的和相减的10分之一作为当前周期的速度补偿量*)
	ELSE;
	END_CASE


	CASE iStep_RW OF(*收料流程*)
		STIFFEN_STEP_Start:(*开始启动*)
			IF NOT i_xMachineRev THEN
				IF i_lrAI_Rw <0 THEN(*料松了*)
					iInitial_speed_Temp:=iInitial_speed_Rw;
				ELSIF  i_lrAI_Rw >0   THEN (*料紧了*)
					iInitial_speed_Temp:=-iInitial_speed_Rw;
				ELSE
					iInitial_speed_Temp:=0;
				END_IF
			ELSE
				IF i_lrAI_Rw >0 THEN(*料松了*)
					iInitial_speed_Temp:=iInitial_speed_Rw;
				ELSIF  i_lrAI_Rw <0   THEN (*料紧了*)
					iInitial_speed_Temp:=-iInitial_speed_Rw;
				ELSE
					iInitial_speed_Temp:=0;
				END_IF
			END_IF

			lrAcc:=iInitial_speed_Temp/(lrAcc_Time*1000);(*R/MIN/MS*)

			o_xForeward_Rw:=TRUE;
			IF ABS(i_prVel_Rw^+lrAcc*gc_TENSION_TSK_CYCLE_TIME)<=ABS(iInitial_speed_Temp)THEN
				i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^+lrAcc*gc_TENSION_TSK_CYCLE_TIME);(*放料角速度=10R/MIN*)(*程序执行周期为20ms*)
			ELSE
				i_prVel_Rw^:=iInitial_speed_Temp;
			END_IF

			lrDetAnalogInput_wind:=lrDetAnalogInput_wind+ i_lrAI_Rw-lrPreAnalogInput_wind;
			IF ABS(lrDetAnalogInput_wind) >0.05 THEN(*模拟量的变化量大于0.05认为摆臂发生运动了*)
				iStep_RW:=STIFFEN_STEP_Compensate;
			END_IF
		STIFFEN_STEP_Delay:
			IF iwindCount>=iSum-1 THEN(*第iSum个周期后进入调整过程中，即状态3*)
				iwindCount:=1;
				iStep_RW:=STIFFEN_STEP_Compensate;
			ELSE
				iwindCount:=iwindCount+1;
			END_IF
		STIFFEN_STEP_Compensate:
			lrwindTemp:=(alrAnalog_Inputwind[1]-alrAnalog_Inputwind[6]);
			lrwindCompensate:=(REAL_TO_LREAL(rWindCompensate_Sum)-(lrwindTemp))/INT_TO_LREAL(iwindCoff);
			(*当前模拟量减去前第5个周期的模拟量得到的变化量与存储的前五个周期的变化量的和相减的10分之一作为当前周期的速度补偿量*)
	ELSE;
	END_CASE
	(*放料*)


	IF NOT i_xMachineRev THEN
		IF iStep_UW=STIFFEN_STEP_Compensate THEN
			IF i_lrAI_Uw<-i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置小于-0.5，即料松*)
				IF NOT o_xZeroServo_Uw THEN
					o_xForeward_Uw:=TRUE;
					IF i_prVel_Uw^>0 THEN
						i_prVel_Uw^:=0;
					ELSE
						i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^-lrUnwindCompensate);
					END_IF
				END_IF
				xFlagDone_Uw:=FALSE;
			ELSIF  i_lrAI_Uw>i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置大于0.5，即料紧*)
				IF NOT o_xZeroServo_Uw THEN
					o_xForeward_Uw:=TRUE;
					IF i_prVel_Uw^<0 THEN
						i_prVel_Uw^:=0;
					ELSE
						i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^-lrUnwindCompensate);
					END_IF
				END_IF
				xFlagDone_Uw:=FALSE;
			ELSE(*放料摆臂在正负0.5之间，放料拉料完成*)
				xFlagDone_Uw:=TRUE;
				(*i_prVel_Uw^:=0;*)
			END_IF
		END_IF

	(*收料*)
		IF iStep_RW =STIFFEN_STEP_Compensate THEN
			IF i_lrAI_Rw<-i_lrThreshold_Stiffen THEN(*收料摆臂位置与中位位置小于-0.5，即料松*)
				IF NOT o_xZeroServo_Rw THEN
					o_xForeward_Rw:=TRUE;
					IF i_prVel_Rw^<0 THEN
						i_prVel_Rw^:=0;
					ELSE
						i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^+lrwindCompensate);
					END_IF
				END_IF
				xFlagDone_Rw:=FALSE;
			ELSIF  i_lrAI_Rw>i_lrThreshold_Stiffen THEN(*收料摆臂位置与中位位置大于0.5，即料紧*)
				IF NOT o_xZeroServo_Rw THEN
					o_xForeward_Rw:=TRUE;
					IF i_prVel_Rw^>0 THEN
						i_prVel_Rw^:=0;
					ELSE
						i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^+lrwindCompensate);
					END_IF
				END_IF
				xFlagDone_Rw:=FALSE;
			ELSE(*收料摆臂在正负0.5之间，收料拉料完成*)
				xFlagDone_Rw:=TRUE;
				(*i_prVel_Rw^:=0;*)
			END_IF
		END_IF
	ELSE
		IF iStep_UW=STIFFEN_STEP_Compensate THEN
			IF i_lrAI_Uw<-i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置小于-0.5，即料松*)
				IF NOT o_xZeroServo_Uw THEN
					o_xForeward_Uw:=TRUE;
					IF i_prVel_Uw^<0 THEN
						i_prVel_Uw^:=0;
					ELSE
						i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^+lrUnwindCompensate);
					END_IF
				END_IF
				xFlagDone_Uw:=FALSE;
			ELSIF  i_lrAI_Uw>i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置大于0.5，即料紧*)
				IF NOT o_xZeroServo_Uw THEN
					o_xForeward_Uw:=TRUE;
					IF i_prVel_Uw^>0 THEN
						i_prVel_Uw^:=0;
					ELSE
						i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^+lrUnwindCompensate);
					END_IF
				END_IF
				xFlagDone_Uw:=FALSE;
			ELSE(*放料摆臂在正负0.5之间，放料拉料完成*)
				xFlagDone_Uw:=TRUE;
				(*i_prVel_Uw^:=0;*)
			END_IF
		END_IF

	(*收料*)
		IF iStep_RW =STIFFEN_STEP_Compensate THEN
			IF i_lrAI_Rw<-i_lrThreshold_Stiffen THEN(*收料摆臂位置与中位位置小于-0.5，即料松*)
				IF NOT o_xZeroServo_Rw THEN
					o_xForeward_Rw:=TRUE;
					IF i_prVel_Rw^>0 THEN
						i_prVel_Rw^:=0;
					ELSE
						i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^-lrwindCompensate);
					END_IF
				END_IF
				xFlagDone_Rw:=FALSE;
			ELSIF  i_lrAI_Rw>i_lrThreshold_Stiffen THEN(*收料摆臂位置与中位位置大于0.5，即料紧*)
				IF NOT o_xZeroServo_Rw THEN
					o_xForeward_Rw:=TRUE;
					IF i_prVel_Rw^<0 THEN
						i_prVel_Rw^:=0;
					ELSE
						i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^-lrwindCompensate);
					END_IF
				END_IF
				xFlagDone_Rw:=FALSE;
			ELSE(*收料摆臂在正负0.5之间，收料拉料完成*)
				xFlagDone_Rw:=TRUE;
				(*i_prVel_Rw^:=0;*)
			END_IF
		END_IF
	END_IF

	IF i_xDebugMode THEN
		o_xForeward_Uw:=TRUE;
		o_xForeward_Rw:=TRUE;
		xFlagDone_Uw:=TRUE;
		xFlagDone_Rw:=TRUE;
		o_xStiffenDone:= TRUE;
	ELSE
		IF iStep_Uw=STIFFEN_STEP_Compensate THEN
			IF NOT o_xZeroServo_Uw THEN
				lrVel_Temp_Uw:= i_prVel_Uw^;
			ELSE
				lrAcc:= -lrVel_Temp_Uw/iDecTime;
				lrBaseVel:= lrAcc;
				i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^+lrAcc*i_iCycleTime_Plc);
				IF (i_prVel_Uw^<=0 AND lrAcc<0) OR
					(i_prVel_Uw^>=0 AND lrAcc>0) THEN
					i_prVel_Uw^:=0;
				END_IF
			END_IF
		ELSE
			lrVel_Temp_Uw:= i_prVel_Uw^;
		END_IF

		IF iStep_Rw=STIFFEN_STEP_Compensate THEN
			IF NOT o_xZeroServo_Rw THEN
				lrVel_Temp_Rw:= i_prVel_Rw^;
			ELSE
				lrAcc:= -lrVel_Temp_Rw/iDecTime;
				lrBaseVel:= lrAcc;
				i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^+lrAcc*i_iCycleTime_Plc);
				IF (i_prVel_Rw^<=0 AND lrAcc<0) OR
					(i_prVel_Rw^>=0 AND lrAcc>0) THEN
					i_prVel_Rw^:=0;
				END_IF
			END_IF
		ELSE
			lrVel_Temp_Rw:= i_prVel_Rw^;
		END_IF
	END_IF




	IF  xFlagDone_Uw THEN
		IF (i_lrAI_Uw>-(i_lrThreshold_Stiffen+0.5) AND
			i_lrAI_Uw<(i_lrThreshold_Stiffen+0.5) ) THEN

			o_xZeroServo_Uw:=TRUE;
		END_IF
	ELSE
		IF (i_lrAI_Uw<-(i_lrThreshold_Stiffen+1) OR
			i_lrAI_Uw>(i_lrThreshold_Stiffen+1) ) THEN

			o_xZeroServo_Uw:=FALSE;
		END_IF
	END_IF


	IF  xFlagDone_Rw THEN
		IF (i_lrAI_Rw>-(i_lrThreshold_Stiffen+0.5) AND
			i_lrAI_Rw<(i_lrThreshold_Stiffen+0.5) ) THEN

			o_xZeroServo_Rw:=TRUE;
		END_IF
	ELSE
		IF (i_lrAI_Rw<-(i_lrThreshold_Stiffen+1) OR
			i_lrAI_Rw>(i_lrThreshold_Stiffen+1) ) THEN

			o_xZeroServo_Rw:=FALSE;
		END_IF
	END_IF


	IF o_xZeroServo_Uw AND o_xZeroServo_Rw THEN

		o_xStiffenDone:=TRUE;
	ELSE

		o_xStiffenDone:=FALSE;
	END_IF

	(*将收放料拉料速度限制为10m/min,由于正反转使用正负速度标识，所以收放料速度可以为负值*)
	lrTemp:=10*1000/92/3.14159;(*10M/MIN，92mm直径对应的转速*)
	IF i_prVel_Uw^>lrTemp THEN
		i_prVel_Uw^:= LREAL_TO_REAL(lrTemp);
	ELSIF  i_prVel_Uw^<-lrTemp THEN
		i_prVel_Uw^:= LREAL_TO_REAL(-lrTemp);
	END_IF
	IF i_prVel_Rw^>lrTemp THEN
		i_prVel_Rw^:= LREAL_TO_REAL(lrTemp);
	ELSIF  i_prVel_Rw^<-lrTemp THEN
		i_prVel_Rw^:= LREAL_TO_REAL(-lrTemp);
	END_IF

	xStopFrom_Ten_Uw:=TRUE;
	xCancelTenRateDec_Uw:=FALSE;
	iCnt_Uw:=0;

	xStopFrom_Ten_Rw:=TRUE;
	xCancelTenRateDec_Rw:=FALSE;
	iCnt_Rw:=0;
ELSE
(*	o_xZeroServo:=FALSE;*)

(*2019.7.11.094916  增加了取消张力投入后慢速松开摆臂,防止突然松开张力,张力太大损坏部件|Liu.yt*)
	IF i_xCancelTenEn AND NOT i_xDebugMode THEN
	(*放料速度是正值*)
		lrCancelTenRate:=rMaxRate_CancelTen;
		IF xStopFrom_Print_Uw THEN
			IF i_lrDiamCurAxis_Uw<>0 THEN
				lrCancelTenRate:=iCancelTenVel/i_lrDiamCurAxis_Uw/gc_lrPI*1000;
			END_IF
		END_IF

		IF lrCancelTenRate>rMaxRate_CancelTen THEN
			lrCancelTenRate:=rMaxRate_CancelTen;
		END_IF
		lrDelRate_Acc:=lrCancelTenRate/iCancelTenAccTime*i_iCycleTime_Plc;(*单个周期的转速变化量-加速*)
		lrDelRate_Dec:=lrCancelTenRate/iCancelTenDecTime*i_iCycleTime_Plc;(*单个周期的转速变化量-减速*)
		lrTemp:=lrCancelTenRate;
	(*小值是料松*)
	(*2019.9.26.091700 增加了取消张力投入时考虑收放牵摆臂的逻辑|Liu.yt*)
		IF NOT i_xFlag_Print AND i_lrFilmVel=0 AND xStopFrom_Ten_Uw THEN
			iCnt_Uw:=iCnt_Uw+1;
			IF ((i_lrAI_Uw>(o_lrAIMin_Uw+rMargin) AND xAIValid_Uw)OR
				(i_lrAI_If>(o_lrAIMin_If+rMargin)AND NOT i_xRollerSts_If AND xAIValid_If))(*牵引未压辊的时候才考虑牵引摆臂*)
				AND iCnt_Uw<=250 THEN(*料膜张紧了*)(*5s还未到位强制取消*)
				o_xForeward_Uw:=TRUE;
				IF NOT i_xMachineRev THEN(*正向走料*)
					IF i_prVel_Uw^+lrDelRate_Acc >=lrCancelTenRate THEN
						i_prVel_Uw^:=LREAL_TO_REAL(lrCancelTenRate);
					ELSE
						i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^+lrDelRate_Acc);
					END_IF
				ELSE(*反向走料*)
					IF i_prVel_Uw^-lrDelRate_Acc <=-lrCancelTenRate THEN
						i_prVel_Uw^:= LREAL_TO_REAL(-lrCancelTenRate);
					ELSE
						i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^-lrDelRate_Acc);
					END_IF
				END_IF
			ELSE
				IF o_xForeward_Uw THEN
					xStopFrom_Ten_Uw:=FALSE;
					xStopFrom_Print_Uw:=FALSE;
					xCancelTenRateDec_Uw:=TRUE;
				END_IF
			END_IF
		ELSIF i_xFlag_Print THEN
			xStopFrom_Print_Uw:=TRUE;
		END_IF

		IF xCancelTenRateDec_Uw THEN(**)
			IF NOT i_xMachineRev THEN(*正向走料*)
				IF i_prVel_Uw^-lrDelRate_Dec<=0 THEN
					o_xForeward_Uw:=FALSE;
					xCancelTenRateDec_Uw:=FALSE;
					i_prVel_Uw^:=0;
				ELSE
					i_prVel_Uw^:= LREAL_TO_REAL(i_prVel_Uw^-lrDelRate_Dec);
				END_IF
			ELSE(*反向走料*)
				IF i_prVel_Uw^+lrDelRate_Dec>=0 THEN
					o_xForeward_Uw:=FALSE;
					xCancelTenRateDec_Uw:=FALSE;
					i_prVel_Uw^:=0;
				ELSE
					i_prVel_Uw^:=LREAL_TO_REAL(i_prVel_Uw^+lrDelRate_Dec);
				END_IF
			END_IF
		END_IF

	(*收料速度是负值*)
		lrCancelTenRate:=-rMaxRate_CancelTen;
		IF xStopFrom_Print_Rw THEN
			IF i_lrDiamCurAxis_Rw<>0 THEN
				lrCancelTenRate:=-iCancelTenVel/i_lrDiamCurAxis_Rw/gc_lrPI*1000;
			END_IF
		END_IF

		IF lrCancelTenRate<-rMaxRate_CancelTen THEN
			lrCancelTenRate:=-rMaxRate_CancelTen;
		END_IF
		lrDelRate_Acc:=lrCancelTenRate/iCancelTenAccTime*i_iCycleTime_Plc;(*单个周期的转速变化量-加速*)
		lrDelRate_Dec:=lrCancelTenRate/iCancelTenDecTime*i_iCycleTime_Plc;(*单个周期的转速变化量-减速*)

	(*小值是料松*)
	(*2019.9.26.091700 增加了取消张力投入时考虑收放牵摆臂的逻辑|Liu.yt*)
		IF NOT i_xFlag_Print AND i_lrFilmVel=0 AND xStopFrom_Ten_Rw THEN
			iCnt_Rw:=iCnt_Rw+1;
			IF ((i_lrAI_Rw>(o_lrAIMin_Rw+rMargin) AND xAIValid_Rw)OR
				(i_lrAI_Of>(o_lrAIMin_Of+rMargin) AND NOT i_xRollerSts_Of AND xAIValid_Of))(*牵引未压辊的时候才考虑牵引摆臂*)
				AND iCnt_Rw<=250 THEN(*料膜张紧了*)(*5s还未到位强制取消*)
				o_xForeward_Rw:=TRUE;
				IF NOT i_xMachineRev THEN(*正向走料*)
					IF i_prVel_Rw^+lrDelRate_Acc <=lrCancelTenRate THEN
						i_prVel_Rw^:= LREAL_TO_REAL(lrCancelTenRate);
					ELSE
						i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^+lrDelRate_Acc);
					END_IF
				ELSE(*反向走料*)
					IF i_prVel_Rw^-lrDelRate_Acc >=-lrCancelTenRate THEN
						i_prVel_Rw^:= LREAL_TO_REAL(-lrCancelTenRate);
					ELSE
						i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^-lrDelRate_Acc);
					END_IF
				END_IF
			ELSE
				IF o_xForeward_Rw THEN
					xStopFrom_Ten_Rw:=FALSE;
					xStopFrom_Print_Rw:=FALSE;
					xCancelTenRateDec_Rw:=TRUE;
				END_IF
			END_IF
		ELSIF i_xFlag_Print THEN
			xStopFrom_Print_Rw:=TRUE;
		END_IF
	
		IF xCancelTenRateDec_Rw THEN(**)
			IF NOT i_xMachineRev THEN(*正向走料*)
				IF i_prVel_Rw^-lrDelRate_Dec>=0 THEN
					o_xForeward_Rw:=FALSE;
					xCancelTenRateDec_Rw:=FALSE;
					i_prVel_Rw^:=0;
				ELSE
					i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^-lrDelRate_Dec);
				END_IF
			ELSE(*反向走料*)
				IF i_prVel_Rw^+lrDelRate_Dec<=0 THEN
					o_xForeward_Rw:=FALSE;
					xCancelTenRateDec_Rw:=FALSE;
					i_prVel_Rw^:=0;
				ELSE
					i_prVel_Rw^:= LREAL_TO_REAL(i_prVel_Rw^+lrDelRate_Dec);
				END_IF
			END_IF
		END_IF
	ELSE
		o_xForeward_Uw:=FALSE;
		xStopFrom_Print_Uw:=FALSE;
		xStopFrom_Ten_Uw:=FALSE;
		xCancelTenRateDec_Uw:=FALSE;
		iCnt_Uw:=0;

		o_xForeward_Rw:=FALSE;
		xStopFrom_Print_Rw:=FALSE;
		xStopFrom_Ten_Rw:=FALSE;
		xCancelTenRateDec_Rw:=FALSE;
		iCnt_Rw:=0;

		IF NOT i_xFlag_Print AND i_lrFilmVel=0 THEN
			i_prVel_Uw^:=0;
			i_prVel_Rw^:=0;
		END_IF
	END_IF

	o_xZeroServo_Uw:=FALSE;

	o_xZeroServo_Rw:=FALSE;

	xFlagDone_Uw:=FALSE;
	xFlagDone_Rw:=FALSE;
	o_xStiffenDone:=FALSE;

	iStep_UW:=STIFFEN_STEP_Stop;
	iStep_RW:=STIFFEN_STEP_Stop;
	iUnwindCount:=1;
	iwindCount:=1;
END_IF
(*获取模拟量的最大值和最小值2019.7.11.101113*)
KS_GetMax_MinVlaue(ADR(o_lrAIMax_Uw), ADR(o_lrAIMin_Uw),i_lrAI_Uw );
KS_GetMax_MinVlaue(ADR(o_lrAIMax_Rw), ADR(o_lrAIMin_Rw),i_lrAI_Rw );

(*2019.9.26.091700 增加了取消张力投入时考虑收放牵摆臂的逻辑|Liu.yt*)
KS_GetMax_MinVlaue(ADR(o_lrAIMax_If), ADR(o_lrAIMin_If),i_lrAI_If );
KS_GetMax_MinVlaue(ADR(o_lrAIMax_Of), ADR(o_lrAIMin_Of),i_lrAI_Of );




lrPreAnalogInput_Unwind:=i_lrAI_Uw;
lrPreAnalogInput_wind:=i_lrAI_Rw;
xPreUnWindZero:=o_xZeroServo_Uw;
xPreWindZero:=o_xZeroServo_Rw;

o_xEno:=i_xEn;