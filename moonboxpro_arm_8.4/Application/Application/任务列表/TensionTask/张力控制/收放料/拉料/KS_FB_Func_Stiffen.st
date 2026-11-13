(*@CES
Name=KS_FB_Func_Stiffen
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=affe5d74-c683-49e9-a1dd-f048b74b74a5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Func_Stiffen
VAR_INPUT
	i_xEn: BOOL;
	i_xDebugMode:BOOL;(*调试模式*)	
	i_iCycleTime_Plc: INT;(*程序执行周期*)
	i_rAI_UwRw: REAL;(*摆臂输入*)
	i_rAI_IfOf: REAL;(*牵引摆臂输入-放料与放牵一组，收料与收牵一组*)
	i_xRollerSts_IfOf: BOOL;(*牵引压辊-放料与放牵一组，收料与收牵一组*)
	i_xMachineRev: BOOL;(*反向走料*)	
	i_iStiffenCoff_UwRw: INT;(*拉料系数输入*)
	i_iInitial_speed: INT;(*拉料起始速度*)
	i_prVel: POINTER TO REAL := 0;(*收放料速度值地址*)
	i_lrThreshold_Stiffen: LREAL := 0.5;(*拉料进入稳定状态的阀值|*)	
	i_xCancelTenEn: BOOL;(*取消张力时慢放使能*)	
	i_lrDiamCurAxis:LREAL;(*正常印刷的时候卷径*)	
	i_xFlag_Print: BOOL;(*印刷状态*)	
	i_lrFilmVel:LREAL;	
	i_xVelRev: BOOL;(*速度方向-放料正值，收料负值*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;
	o_xStiffenDone: BOOL;(*拉料完成标志|*)
	o_xZeroServo: BOOL;(*放料零伺服|*)
	o_xForeward: BOOL;(*放料使能\正转|*)	
END_VAR
VAR
	iStiffenCoff_Temp: INT;
	iInitial_Speed: INT;

	iN: INT;
	iSum: INT:=5;	
	arUwRwCompensate: ARRAY [1..10] OF REAL;
	rUwRwStep_GE1:REAL:=0.02;(*摆臂大于1v的时候补偿量*)
	iUwRwCompensate_LT1:REAL:=20;(*摆臂小于1v的时候补偿量系数*)
	rUwRwCompensate_Sum: REAL;(*摆臂累积量总和*)
	alrAnalog_InputUwRw: ARRAY [1..10] OF LREAL;	
	xAIValid_UwRw: BOOL:=FALSE;
	xAIValid_IfOf: BOOL:=FALSE;
	iStep_UwRw: INT; (*收料拉料流程*)
	lrDetAnalogInput_UwRw: LREAL;(*模拟量的变化量*)
	lrPreAnalogInput_UwRw: LREAL;(*上个周期的模拟量值*)
	iInitial_Speed_Temp: INT;	
	lrAcc: LREAL;(*开始拉料时候的加速度*)
	lrAcc_Time: LREAL:=0.2;(*开始拉料时候的加速时间S*)
	lrTemp: LREAL;
	iUwRwCount: INT:=1;	
	lrUwRwTemp: LREAL;	
	lrUwRwCompensate: LREAL;(*每个周期的补偿值*)	
	xFlagDone: BOOL;	
	rVel_Temp_Uw: REAL;	
	iDecTime: INT:=100;(*ms*)
	rBaseVel: LREAL;	
	xStopFrom_Ten: BOOL;(*从张力投入状态停止*)
	xStopFrom_Print: BOOL;(*从印刷状态停止*)
	xCancelTenRateDec: BOOL;(*取消张力状态转速减速标志*)
	iCnt: INT;(*计数*)
	lrCancelTenRate:LREAL;(*取消张力的转速*)	
	rMaxRate_CancelTen:REAL:=5;(*慢松料最大转速|2022.1.7.171923 增加*)	
	iCancelTenVel:INT:=10;(*取消张力的速度*)	
	iCancelTenAccTime: INT:=1000;(*取消张力加速时间ms*)
	iCancelTenDecTime: INT:=300;(*取消张力减速时间ms*)
	lrDelRate_Acc: LREAL;(*单个周期的转速变化量-加速*)
	lrDelRate_Dec: LREAL;(*单个周期的转速变化量-减速*)
	rAIMax_UwRw: LREAL;
	rAIMin_UwRw: LREAL;	
	rAIMax_IfOf: LREAL;
	rAIMin_IfOf: LREAL;		
	rMargin:REAL:=1;(*慢松料逻辑的余量，默认1v*)
	
END_VAR

{IMPLEMENTATION}
(*增加拉料系数输入|L.YT|2019.6.29.154256*)
IF i_iStiffenCoff_UwRw <=0 THEN
	iStiffenCoff_Temp:=10;
ELSE
	iStiffenCoff_Temp:=i_iStiffenCoff_UwRw;
END_IF

IF i_iInitial_speed <=0 THEN
	iInitial_speed:=10;
ELSE
	iInitial_speed:=i_iInitial_speed;
END_IF


o_xEno:= i_xEn;
o_iErNo:= 0;

(*2019.08.06.163951|niu.j|指针合法判断*)
IF i_prVel<>0 THEN
	;
ELSE
	RETURN;
END_IF

FOR iN:=iSum TO 2 BY -1 DO
	arUwRwCompensate[iN]:=arUwRwCompensate[iN-1];
END_FOR

IF  ABS(i_rAI_UwRw)>1 THEN
	IF i_rAI_UwRw>1 THEN
		arUwRwCompensate[1]:=-rUwRwStep_GE1;
	ELSE
		arUwRwCompensate[1]:=rUwRwStep_GE1;
	END_IF
ELSE
	arUwRwCompensate[1]:=-(i_rAI_UwRw)/iUwRwCompensate_LT1;(*累计量数组*)
END_IF

rUwRwCompensate_Sum:=0;
FOR iN:=1 TO iSum BY 1 DO(*计算总的累积和~~*)
	rUwRwCompensate_Sum:=rUwRwCompensate_Sum+arUwRwCompensate[iN];
END_FOR

FOR iN:=10 TO 2 BY -1 DO(*存储前几个周期的模拟量值*)
	alrAnalog_InputUwRw[iN]:=alrAnalog_InputUwRw[iN-1];
END_FOR

alrAnalog_InputUwRw[1]:= i_rAI_UwRw;

(*2020.1.3.144851 增加了收放料摆臂以及收放牵摆臂存在检验标志|用于慢速松料功能|Liu.yt*)
IF i_rAI_UwRw >0.1 OR i_rAI_UwRw<-0.1 THEN
	xAIValid_UwRw:=TRUE;
END_IF


IF i_rAI_IfOf >0.1 OR i_rAI_IfOf<-0.1 THEN
	xAIValid_IfOf:=TRUE;
END_IF

(*模拟量正负控制电机正反转*)(*反转是负电压，正转为正电压*)
IF i_xEn THEN(*拉料功能块使能即张力投入状态*)
	IF iStep_UwRw =STIFFEN_STEP_Stop  THEN
		iStep_UwRw:=STIFFEN_STEP_Start;
		lrDetAnalogInput_UwRw:=0;
	END_IF

	CASE iStep_UwRw OF(*放料流程*)
		STIFFEN_STEP_Start:(*开始启动*)
			IF NOT i_xVelRev THEN
				IF NOT i_xMachineRev THEN
					IF i_rAI_UwRw <0 THEN(*料松了*)
						iInitial_Speed_Temp:=-iInitial_speed;
					ELSIF  i_rAI_UwRw >0   THEN (*料紧了*)
						iInitial_Speed_Temp:=iInitial_speed;
					ELSE
						iInitial_Speed_Temp:=0;
					END_IF
				ELSE
					IF i_rAI_UwRw >0 THEN(*料松了*)
						iInitial_speed_Temp:=-iInitial_speed;
					ELSIF  i_rAI_UwRw <0   THEN (*料紧了*)
						iInitial_speed_Temp:=iInitial_speed;
					ELSE
						iInitial_speed_Temp:=0;
					END_IF
				END_IF
			ELSE
				IF NOT i_xMachineRev THEN
					IF i_rAI_UwRw <0 THEN(*料松了*)
						iInitial_Speed_Temp:=iInitial_speed;
					ELSIF  i_rAI_UwRw >0   THEN (*料紧了*)
						iInitial_Speed_Temp:=-iInitial_speed;
					ELSE
						iInitial_Speed_Temp:=0;
					END_IF
				ELSE
					IF i_rAI_UwRw >0 THEN(*料松了*)
						iInitial_speed_Temp:=iInitial_speed;
					ELSIF  i_rAI_UwRw <0   THEN (*料紧了*)
						iInitial_speed_Temp:=-iInitial_speed;
					ELSE
						iInitial_speed_Temp:=0;
					END_IF
				END_IF				
			END_IF
			lrAcc:=iInitial_speed_Temp/(lrAcc_Time*1000);(*R/MIN/MS*)

			o_xForeward:=TRUE;
			IF ABS(i_prVel^+lrAcc*i_iCycleTime_Plc)<=ABS(iInitial_speed_Temp)THEN
				i_prVel^:=i_prVel^+lrAcc*i_iCycleTime_Plc;(*放料角速度=10R/MIN*)(*程序执行周期为20ms*)
			ELSE
				i_prVel^:=iInitial_speed_Temp;
			END_IF
			lrDetAnalogInput_UwRw:=lrDetAnalogInput_UwRw+ i_rAI_UwRw-lrPreAnalogInput_UwRw;
			IF ABS(lrDetAnalogInput_UwRw) >0.05 THEN(*模拟量的变化量大于0.05认为摆臂发生运动了*)
				iStep_UwRw:=STIFFEN_STEP_Compensate;
			END_IF
		STIFFEN_STEP_Delay:
			IF iUwRwCount>=iSum-1 THEN(*第iSum个周期后进入调整过程中，即状态3*)
				iUwRwCount:=1;
				iStep_UwRw:=STIFFEN_STEP_Compensate;
			ELSE
				iUwRwCount:=iUwRwCount+1;
			END_IF
		STIFFEN_STEP_Compensate:
			lrUwRwTemp:=(alrAnalog_InputUwRw[1]-alrAnalog_InputUwRw[6]);
			lrUwRwCompensate:=(REAL_TO_LREAL(rUwRwCompensate_Sum)-(lrUwRwTemp))/INT_TO_LREAL(iStiffenCoff_Temp);
			(*当前模拟量减去前第5个周期的模拟量得到的变化量与存储的前五个周期的变化量的和相减的10分之一作为当前周期的速度补偿量*)
	ELSE;
	END_CASE

	IF NOT i_xVelRev THEN
		IF NOT i_xMachineRev THEN
			IF iStep_UwRw=STIFFEN_STEP_Compensate THEN
				IF i_rAI_UwRw<-i_lrThreshold_Stiffen THEN(*摆臂位置与中位位置小于-0.5，即料松*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^>0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^-lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSIF  i_rAI_UwRw>i_lrThreshold_Stiffen THEN(*摆臂位置与中位位置大于0.5，即料紧*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^<0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^-lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSE(*摆臂在正负0.5之间，拉料完成*)
					xFlagDone:=TRUE;
					(*i_plrVel_Uw^:=0;*)
				END_IF
			END_IF
		ELSE
			IF iStep_UwRw=STIFFEN_STEP_Compensate THEN
				IF i_rAI_UwRw<-i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置小于-0.5，即料松*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^<0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^+lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSIF  i_rAI_UwRw>i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置大于0.5，即料紧*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^>0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^+lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSE(*摆臂在正负0.5之间，放料拉料完成*)
					xFlagDone:=TRUE;
					(*i_plrVel_Uw^:=0;*)
				END_IF
			END_IF
		END_IF
	ELSE
		IF NOT i_xMachineRev THEN
			IF iStep_UwRw=STIFFEN_STEP_Compensate THEN
				IF i_rAI_UwRw<-i_lrThreshold_Stiffen THEN(*摆臂位置与中位位置小于-0.5，即料松*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^<0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^+lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSIF  i_rAI_UwRw>i_lrThreshold_Stiffen THEN(*摆臂位置与中位位置大于0.5，即料紧*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^>0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^+lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSE(*摆臂在正负0.5之间，拉料完成*)
					xFlagDone:=TRUE;
					(*i_plrVel_Uw^:=0;*)
				END_IF
			END_IF
		ELSE
			IF iStep_UwRw=STIFFEN_STEP_Compensate THEN
				IF i_rAI_UwRw<-i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置小于-0.5，即料松*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^<0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^-lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSIF  i_rAI_UwRw>i_lrThreshold_Stiffen THEN(*放料摆臂位置与中位位置大于0.5，即料紧*)
					IF NOT o_xZeroServo THEN
						o_xForeward:=TRUE;
						IF i_prVel^<0 THEN
							i_prVel^:=0;
						ELSE
							i_prVel^:=i_prVel^-lrUwRwCompensate;
						END_IF
					END_IF
					xFlagDone:=FALSE;
				ELSE(*摆臂在正负0.5之间，放料拉料完成*)
					xFlagDone:=TRUE;
					(*i_plrVel_Uw^:=0;*)
				END_IF
			END_IF
		END_IF		
	END_IF
	IF i_xDebugMode THEN
		o_xForeward:=TRUE;
		xFlagDone:=TRUE;
		o_xStiffenDone:= TRUE;
	ELSE
		IF iStep_UwRw=STIFFEN_STEP_Compensate THEN
			IF NOT o_xZeroServo THEN
				rVel_Temp_Uw:= i_prVel^;
			ELSE
				lrAcc:= -rVel_Temp_Uw/iDecTime;
				rBaseVel:= lrAcc;
				i_prVel^:= i_prVel^+lrAcc*i_iCycleTime_Plc;
				IF (i_prVel^<=0 AND lrAcc<0) OR
					(i_prVel^>=0 AND lrAcc>0) THEN
					i_prVel^:=0;
				END_IF
			END_IF
		ELSE
			rVel_Temp_Uw:= i_prVel^;
		END_IF
	END_IF




	IF  xFlagDone THEN
		IF (i_rAI_UwRw>-(i_lrThreshold_Stiffen+0.5) AND
			i_rAI_UwRw<(i_lrThreshold_Stiffen+0.5) ) THEN

			o_xZeroServo:=TRUE;
		END_IF
	ELSE
		IF (i_rAI_UwRw<-(i_lrThreshold_Stiffen+1) OR
			i_rAI_UwRw>(i_lrThreshold_Stiffen+1) ) THEN

			o_xZeroServo:=FALSE;
		END_IF
	END_IF

	IF o_xZeroServo THEN
		o_xStiffenDone:=TRUE;
	ELSE
		o_xStiffenDone:=FALSE;
	END_IF

	(*将收放料拉料速度限制为10m/min,由于正反转使用正负速度标识，所以收放料速度可以为负值*)
	lrTemp:=10*1000/92/3.14159;(*10M/MIN，92mm直径对应的转速*)
	IF i_prVel^>lrTemp THEN
		i_prVel^:=lrTemp;
	ELSIF  i_prVel^<-lrTemp THEN
		i_prVel^:=-lrTemp;
	END_IF

	xStopFrom_Ten:=TRUE;
	xCancelTenRateDec:=FALSE;
	iCnt:=0;
ELSE
(*2019.7.11.094916  增加了取消张力投入后慢速松开摆臂,防止突然松开张力,张力太大损坏部件|Liu.yt*)
	IF i_xCancelTenEn AND (NOT i_xDebugMode) THEN
	(*放料速度是正值*)
		IF NOT i_xVelRev THEN
			lrCancelTenRate:=rMaxRate_CancelTen;
			IF xStopFrom_Print THEN
				IF i_lrDiamCurAxis<>0 THEN
					lrCancelTenRate:=iCancelTenVel/i_lrDiamCurAxis/gc_lrPI*1000;
				END_IF
			END_IF
	
			IF lrCancelTenRate>rMaxRate_CancelTen THEN
				lrCancelTenRate:=rMaxRate_CancelTen;
			END_IF
		ELSE
			lrCancelTenRate:=-rMaxRate_CancelTen;
			IF xStopFrom_Print THEN
				IF i_lrDiamCurAxis<>0 THEN
					lrCancelTenRate:=-iCancelTenVel/i_lrDiamCurAxis/gc_lrPI*1000;
				END_IF
			END_IF
	
			IF lrCancelTenRate<-rMaxRate_CancelTen THEN
				lrCancelTenRate:=-rMaxRate_CancelTen;
			END_IF			
		END_IF
		lrDelRate_Acc:=lrCancelTenRate/iCancelTenAccTime*i_iCycleTime_Plc;(*单个周期的转速变化量-加速*)
		lrDelRate_Dec:=lrCancelTenRate/iCancelTenDecTime*i_iCycleTime_Plc;(*单个周期的转速变化量-减速*)
		lrTemp:=lrCancelTenRate;
	(*小值是料松*)
	(*2019.9.26.091700 增加了取消张力投入时考虑收放牵摆臂的逻辑|Liu.yt*)
		IF NOT i_xFlag_Print AND i_lrFilmVel=0 AND xStopFrom_Ten THEN
			iCnt:=iCnt+1;
			IF ((i_rAI_UwRw>(rAIMin_UwRw+rMargin) AND xAIValid_UwRw)OR
				(i_rAI_IfOf>(rAIMin_IfOf+rMargin)AND (NOT i_xRollerSts_IfOf) AND xAIValid_IfOf))(*牵引未压辊的时候才考虑牵引摆臂*)
				AND iCnt<=250 THEN(*料膜张紧了*)(*5s还未到位强制取消*)
				o_xForeward:=TRUE;
				IF NOT i_xMachineRev THEN(*正向走料*)
					IF i_prVel^+lrDelRate_Acc >=lrCancelTenRate THEN
						i_prVel^:=lrCancelTenRate;
					ELSE
						i_prVel^:=i_prVel^+lrDelRate_Acc;
					END_IF
				ELSE(*反向走料*)
					IF i_prVel^-lrDelRate_Acc <=-lrCancelTenRate THEN
						i_prVel^:=-lrCancelTenRate;
					ELSE
						i_prVel^:=i_prVel^-lrDelRate_Acc;
					END_IF
				END_IF
			ELSE
				IF o_xForeward THEN
					xStopFrom_Ten:=FALSE;
					xStopFrom_Print:=FALSE;
					xCancelTenRateDec:=TRUE;
				END_IF
			END_IF
		ELSIF i_xFlag_Print THEN
			xStopFrom_Print:=TRUE;
		END_IF

		IF xCancelTenRateDec THEN(**)
			IF NOT i_xMachineRev THEN(*正向走料*)
				IF i_prVel^-lrDelRate_Dec<=0 THEN
					o_xForeward:=FALSE;
					xCancelTenRateDec:=FALSE;
					i_prVel^:=0;
				ELSE
					i_prVel^:=i_prVel^-lrDelRate_Dec;
				END_IF
			ELSE(*反向走料*)
				IF i_prVel^+lrDelRate_Dec>=0 THEN
					o_xForeward:=FALSE;
					xCancelTenRateDec:=FALSE;
					i_prVel^:=0;
				ELSE
					i_prVel^:=i_prVel^+lrDelRate_Dec;
				END_IF
			END_IF
		END_IF
	ELSE
		o_xForeward:=FALSE;
		xStopFrom_Print:=FALSE;
		xStopFrom_Ten:=FALSE;
		xCancelTenRateDec:=FALSE;
		iCnt:=0;

		IF NOT i_xFlag_Print AND i_lrFilmVel=0 THEN
			i_prVel^:=0;
		END_IF
	END_IF

	o_xZeroServo:=FALSE;
	xFlagDone:=FALSE;
	o_xStiffenDone:=FALSE;
	iStep_UwRw:=STIFFEN_STEP_Stop;
	iUwRwCount:=1;
END_IF
(*获取模拟量的最大值和最小值2019.7.11.101113*)
KS_GetMax_MinVlaue(ADR(rAIMax_UwRw), ADR(rAIMin_UwRw),i_rAI_UwRw );

(*2019.9.26.091700 增加了取消张力投入时考虑收放牵摆臂的逻辑|Liu.yt*)
KS_GetMax_MinVlaue(ADR(rAIMax_IfOf), ADR(rAIMin_IfOf),i_rAI_IfOf );

lrPreAnalogInput_UwRw:=i_rAI_UwRw;

o_xEno:=i_xEn;