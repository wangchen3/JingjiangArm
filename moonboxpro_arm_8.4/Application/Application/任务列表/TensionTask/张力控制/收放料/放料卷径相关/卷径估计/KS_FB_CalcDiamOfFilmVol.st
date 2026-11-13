(*@CES
Name=KS_FB_CalcDiamOfFilmVol
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=aa4e7948-893a-473e-86a9-5c9051eef5bc
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CalcDiamOfFilmVol(*卷径计算*)
VAR_INPUT
	i_xEnable: BOOL;
	i_lrFilmVelocity:LREAL;(*料膜速度*)
	i_lrUnWind_Velocity:LREAL;(*放料速度参数*)
	i_lrWind_Velocity :LREAL;(*收料速度参数*)
	i_lrAlarm_Diameter: LREAL ;(*报警卷径*)
	i_xUnWind_CutFinished: BOOL;(*放料裁切完成*)
	i_xWind_CutFinished: BOOL;(*收料裁切完成*)
	i_CycleTime:INT;(*程序循环时间*)
	i_xRollerPress_Uw:BOOL;(*全体合压标志*)
	i_xMachineRev:BOOL;(*整机反转标志*)
	(*2021.8.26.173437 增加了预估卷径以后添加的参数*)
	i_rDiaAcT_Uw:REAL;(*放料实际当前卷径*)
	i_rDiaAcT_Rw:REAL;(*放料实际当前卷径*)
END_VAR
VAR_OUTPUT
	o_xEno: BOOL;
	o_iErNo: INT;
	o_xFlag_AlarmDiameter: BOOL;
END_VAR
VAR_IN_OUT
	rUnWind_Diameter:REAL;(*放料卷径*)
	rWind_Diameter:REAL;(*收料卷径*)
END_VAR
VAR
	temp1: LREAL;
	temp2: LREAL;
(*2016年5月26日 14:45:08*)
	rUnWind_DiameterArr: ARRAY [1..200] OF LREAL;		(*放料计算卷径*)
	rWind_DiameterArr: ARRAY [1..200] OF LREAL;		(*收料计算卷径*)
	iNum: INT := 150;(*卷径平均次数*)
	lrUnWind_Velocity: ARRAY[1..200] OF LREAL;
	lrWind_Velocity: ARRAY[1..200] OF LREAL;
	iEven_Num: INT := 5;(*速度平均次数*)
	lrSum_UnWind_Velocity: LREAL;
	lrSum_Wind_Velocity: LREAL;	(*  *)
	lrSum_UnWind_Diameter: LREAL;
	lrSum_Wind_Diameter: LREAL;
	iN: INT;
	Init: BOOL;(*收放料速度、卷径数组初始化标志*)
	lrUnWind_Dia: LREAL;(*放料平均卷径*)
	lrWind_Dia: LREAL;(*收料平均卷径*)



	iCalDiameter: INT:=20;(*卷径计算间隔时间ms*)
	iCalDiameterCycleCount:INT:=1;(*卷径计算周期计数*)





	iUnwindDia_Min:INT:=80;(*放料最小卷径*)
	iUnwindDia_Max:INT:=1600;(*放料最大卷径*)
	iwindDia_Min:INT:=80;(*收料最小卷径*)
	iwindDia_Max:INT:=1600;(*收料最大卷径*)

	iTemp: INT;(*控制卷径计算方向的*)
	uiUpdateDia: UINT;
	uiCount: UINT;(*计数，用来确定卷径变化已经稳定，防止卷径报警异常输出*)
	lrStep_Uw: LREAL;
	lrTime_Temp: LREAL := 5000;
	lrStep_Rw: LREAL;
END_VAR

{IMPLEMENTATION}
o_xEno:= i_xEnable;
o_iErNo:= 0;

(*需要放在fb_Vel_TO_Vol功能块后，因为在fb_Vel_TO_Vol功能块中进行卷径的切换。*
*	同时要放在收放料裁切换料标志清零之前                                   *)
IF i_xEnable THEN
	IF i_xUnWind_CutFinished OR  i_xWind_CutFinished THEN(*放料或者收料裁切完成，置Init标志为false*)
		Init:=FALSE;
	END_IF
(*2020.9.30.094859|liu.yt删除该处赋值变量|
	iEven_Num:=150;
*)
	IF iCalDiameterCycleCount >=iCalDiameter/i_CycleTime THEN(*卷径计算周期条件*)
		iCalDiameterCycleCount:=1;
		IF NOT Init THEN(*收放料速度、卷径数组初始化*)
			Init:=TRUE;
			FOR iN:=1 TO iEven_Num BY 1 DO
				lrUnWind_Velocity[iN]:=i_lrUnWind_Velocity;
				lrWind_Velocity[iN]:=i_lrWind_Velocity;
			END_FOR
			FOR iN:=1 TO iNum BY 1 DO
				rUnWind_DiameterArr[iN]:=rUnWind_Diameter;
				rWind_DiameterArr[iN]:=rWind_Diameter;
			END_FOR
			temp1:=i_lrFilmVelocity;
			temp2:=i_lrFilmVelocity;
		END_IF

	(*计算平均线速度*)
		FOR iN:=iEven_Num TO 2 BY -1 DO
			lrUnWind_Velocity[iN] := lrUnWind_Velocity[iN-1];
			lrWind_Velocity[iN] := lrWind_Velocity[iN-1];
		END_FOR
		lrUnWind_Velocity[1]:=i_lrUnWind_Velocity;
		lrWind_Velocity[1]:=i_lrWind_Velocity;
		lrSum_UnWind_Velocity := 0;
		lrSum_Wind_Velocity := 0;
		FOR iN:=1 TO iEven_Num BY 1 DO
			lrSum_UnWind_Velocity:=lrSum_UnWind_Velocity+lrUnWind_Velocity[iN];
			lrSum_Wind_Velocity:=lrSum_Wind_Velocity+lrWind_Velocity[iN];
		END_FOR
		temp1 := lrSum_UnWind_Velocity / iEven_Num;(*计算放料平均速度*)
		temp2 := lrSum_Wind_Velocity / iEven_Num;(*计算收料平均速度*)
	(*计算平均卷径*)
		FOR iN:=iNum TO 2 BY -1 DO
			rUnWind_DiameterArr[iN] := rUnWind_DiameterArr[iN-1];
			rWind_DiameterArr[iN] := rWind_DiameterArr[iN-1];
		END_FOR

(*计算收放料直径用于计算料膜平均直径*)

		IF temp1<>0 THEN(*卷径=料膜速度/角速度*)
			rUnWind_DiameterArr[1]:=i_lrFilmVelocity/temp1/3.14159*1000;
		END_IF

		IF rUnWind_DiameterArr[1] <iUnwindDia_Min THEN
			rUnWind_DiameterArr[1]:=iUnwindDia_Min;
		END_IF

		IF rUnWind_DiameterArr[1] >iUnwindDia_Max THEN
			rUnWind_DiameterArr[1]:=iUnwindDia_Max;
		END_IF

		IF temp2<>0 THEN	(*卷径=料膜速度/角速度*)
			rWind_DiameterArr[1]:=i_lrFilmVelocity/temp2/3.14159*1000;
		END_IF

		IF rWind_DiameterArr[1] <iwindDia_Min THEN
			rWind_DiameterArr[1]:=iwindDia_Min;
		END_IF

		IF rWind_DiameterArr[1] >iwindDia_Max THEN
			rWind_DiameterArr[1]:=iwindDia_Max;
		END_IF


		lrSum_UnWind_Diameter := 0;
		lrSum_Wind_Diameter := 0;
		FOR iN:=1 TO iNum BY 1 DO
			lrSum_UnWind_Diameter := lrSum_UnWind_Diameter + rUnWind_DiameterArr[iN];
			lrSum_Wind_Diameter := lrSum_Wind_Diameter + rWind_DiameterArr[iN];
		END_FOR
		lrUnWind_Dia:=lrSum_UnWind_Diameter/iNum;(*计算放料平均卷径值*)
		lrWind_Dia:=lrSum_Wind_Diameter/iNum;(*计算收料平均卷径值*)




(*整机反转时候卷径计算控制*)
		IF i_xMachineRev THEN
			iTemp:=-1;
		ELSE
			iTemp:=1;
		END_IF

		IF i_lrFilmVelocity>=10 THEN(*角速度控制算法的时候开机就计算卷径，线速度算法需要大于15M/MIN时候计算*)
			uiUpdateDia:=uiUpdateDia+1;(*卷径更新计数*)
			IF uiUpdateDia>=10 THEN(*200更新一次*)
				IF NOT i_xRollerPress_Uw THEN (*放料胶辊未合压了*)
					(*防止由于裁切换料的时候 可能会导致卷径计算不准确，进行卷径切换的时候会出错，所以在此时不再计算保持之前的值*)
					IF lrTime_Temp<>0 THEN
						lrStep_Uw:= ABS(rUnWind_Diameter-lrUnWind_Dia)*i_CycleTime*uiUpdateDia/lrTime_Temp;
						IF lrStep_Uw<(*0.1 *)0.2 THEN(*|从数据中发现为0.1时不能跟上卷径的变化*)
							lrStep_Uw:=(*0.1*)0.2;
						ELSE;
						END_IF
					END_IF
					IF ABS( rUnWind_Diameter-lrUnWind_Dia)<=50 THEN
						IF iTemp*(rUnWind_Diameter - lrUnWind_Dia) > lrStep_Uw THEN
							rUnWind_Diameter := rUnWind_Diameter  - lrStep_Uw*iTemp;
						ELSIF  -iTemp*(rUnWind_Diameter - lrUnWind_Dia) >lrStep_Uw THEN
							rUnWind_Diameter := rUnWind_Diameter  + lrStep_Uw*iTemp;
						ELSE
							rUnWind_Diameter:=lrUnWind_Dia;
						END_IF
					ELSE
						rUnWind_Diameter:=lrUnWind_Dia;
					END_IF
				END_IF

				IF lrTime_Temp<>0 THEN
					lrStep_Rw:= ABS(rWind_Diameter-lrWind_Dia)*20*uiUpdateDia/lrTime_Temp;
					IF lrStep_Rw<(*0.1*)0.2 THEN(*1S-0.5mm*)(*将卷径最小变化率改为0.3即1.5mm/s.|从数据中发现为0.1时不能跟上卷径的变化*)
						lrStep_Rw:=(*0.1*)0.2;
					ELSE;
					END_IF
				END_IF
				IF ABS( rWind_Diameter-lrWind_Dia)<=50 THEN
					IF iTemp*(rWind_Diameter - lrWind_Dia) > lrStep_Rw THEN
						rWind_Diameter := rWind_Diameter  - lrStep_Rw*iTemp;
					ELSIF  -iTemp*(rWind_Diameter - lrWind_Dia) > lrStep_Rw THEN
						rWind_Diameter := rWind_Diameter  + lrStep_Rw*iTemp;
					ELSE
						rWind_Diameter:=lrWind_Dia;
					END_IF
				ELSE
					rWind_Diameter:=lrWind_Dia;
				END_IF
				uiUpdateDia:=0;
			END_IF


(*卷径报警输出*)
			IF NOT i_xMachineRev THEN(*整机正转时候*)
				IF  i_rDiaAcT_Uw <= i_lrAlarm_Diameter+2 THEN(*+2是为了防止放料计算的卷径抖动，重复触发报警*)
					IF i_rDiaAcT_Uw <= i_lrAlarm_Diameter THEN
						IF uiCount>=250 THEN(*连续5S放料卷径都小于报警卷径则认为需要报警*)
							o_xFlag_AlarmDiameter := TRUE;
						ELSE
							uiCount:=uiCount+1;
						END_IF
					ELSE
						uiCount:=0;
					END_IF
				ELSE
					uiCount:=0;
					o_xFlag_AlarmDiameter := FALSE;
				END_IF
			END_IF

			IF  i_xMachineRev THEN(*整机反转时候*)
				IF  i_rDiaAcT_Rw <= i_lrAlarm_Diameter+2 THEN(*+2是为了防止放料计算的卷径抖动，重复触发报警*)
					IF i_rDiaAcT_Rw <= i_lrAlarm_Diameter THEN
						IF uiCount>=250 THEN(*连续5S放料卷径都小于报警卷径则认为需要报警*)
							o_xFlag_AlarmDiameter := TRUE;
						ELSE
							uiCount:=uiCount+1;
						END_IF
					ELSE
						uiCount:=0;
					END_IF
				ELSE
					uiCount:=0;
					o_xFlag_AlarmDiameter := FALSE;
				END_IF
			END_IF

		END_IF

		IF rUnWind_Diameter <= iUnwindDia_Min THEN
			rUnWind_Diameter := iUnwindDia_Min;
		END_IF
		IF rUnWind_Diameter >= iUnwindDia_Max THEN
			rUnWind_Diameter := iUnwindDia_Max;
		END_IF


		IF rWind_Diameter <= iwindDia_Min THEN
			rWind_Diameter := iwindDia_Min;
		END_IF
		IF rWind_Diameter >= iwindDia_Max THEN
			rWind_Diameter := iwindDia_Max;
		END_IF
	ELSE
		iCalDiameterCycleCount:=iCalDiameterCycleCount+1;
	END_IF
ELSE
	o_xFlag_AlarmDiameter := FALSE;
	Init:=FALSE;
	iCalDiameterCycleCount:=1;
	uiUpdateDia:=0;(*卷径更新周期计数*)
	uiCount:=0;
END_IF