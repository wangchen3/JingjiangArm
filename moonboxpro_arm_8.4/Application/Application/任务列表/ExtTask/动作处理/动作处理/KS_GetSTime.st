(*@CES
Name=KS_GetSTime
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a4f55ea8-3634-425c-a7b6-679c868e638a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetSTime : BOOL
(*获取s时间保证加减速前后s时位移一致*)
(*总时间等于速度变化的直线时间+平滑时间*)
VAR_INPUT
	i_byCalcType:BYTE;(*选择平滑时间的方式
								1:按照界面输入的平滑时间和每百米的加速时间设定s曲线;总时间=平滑时间+dv/100*界面时间;平滑时间按照界面设置;
								2:按照比例系数设定平滑时间和每百米的加速时间设定s曲线;总时间=平滑时间+dv/100*界面时间;平滑时间=总时间*系数
								3:按照界面输入加减速时间设定s曲线;总时间=dv/100*界面时间;平滑时间=总时间*系数;
							*)
	i_rSpeed_SCoeff: REAL;(*平滑时间系数@默认2/3*)
	i_iTimeSa_S:INT;(*屏上输入s前时间*)
	i_iTimeEd_S:INT;(*屏上输入s后时间*)
	i_iTime_Acc:INT;(*屏上输入加速时间*)
	i_iTime_Dec:INT;(*屏上输入减速速时间*)
	i_uiMaxVel_UseCalcAcc:UINT;(*计算加速度的速度@100m/min*)
	i_rVel_Cur:REAL;(*当前速度*)
	i_rVel_Tar:REAL;(*目标速度*)
	i_prTimeSa_S:POINTER TO REAL;(*s开始时间*)
	i_prTimeEd_S:POINTER TO REAL;(*s结束时间*)
	i_prDis_Sa:POINTER TO REAL;(*s开始运动的位移*)
	i_prDis_Ed:POINTER TO REAL;(*s结束运动的位移*)
	i_prTime_Total:POINTER TO REAL;(*总时间*)
	i_prTime_SmActual:POINTER TO REAL;(*实际的平滑时间*)
	i_plrTime_Even:POINTER TO LREAL;(*匀加速段的时间@直线加速的时间*)
END_VAR
VAR
	rV0:REAL;
	rVt:REAL;
	rA:REAL;
	rB:REAL;
	rC:REAL;

	byCalcType: BYTE;
	rMaxVel_UseCalcAcc: REAL;
	rTime_AccDec: REAL;(*加减速时间s@界面输入*)
	rTime_S:REAL;(*平滑时间s@以前界面输入是前后,在这里做和处理*)
	rTotalTime: REAL;(*s*)
	rDeltV: REAL;(*m/min*)
	rDeltV_Abs: REAL;(*m/min*)
	rAcceleration_Linear: REAL;(*直线加速度@m/min/s*)
	rAcceleration_Need: REAL;(*实际最大加速度*)
	rTimeSa_S: REAL;(*实际s前时间*)
	rTimeEd_S: REAL;(*实际s后时间*)
	rDis_1: REAL;(*实际s前位移*)
	rDis_2: REAL;(*实际s后位移*)
	rTime_S_Use: REAL;(*实际平滑总时间*)
	rTime_Even:REAL;(*匀加速段的时间*)
END_VAR
{IMPLEMENTATION}
(*计算加速度的速度*)
rMaxVel_UseCalcAcc:=UINT_TO_REAL(i_uiMaxVel_UseCalcAcc);
IF rMaxVel_UseCalcAcc=0 THEN rMaxVel_UseCalcAcc:=100;END_IF
byCalcType:=i_byCalcType;
(*初速度@m/min*)
rV0:=i_rVel_Cur;
(*末速度@m/min*)
rVt:=i_rVel_Tar;
(*速度变化量*)
rDeltV:=rVt-rV0;(*带有方向*)
(*平滑时间*)
rTime_S:=INT_TO_REAL(i_iTimeSa_S+i_iTimeEd_S);

(*加速时间*)
IF rDeltV<0 THEN(*减速*)
	rTime_AccDec:=i_iTime_Dec;
ELSE
	rTime_AccDec:=i_iTime_Acc;
END_IF

IF i_rSpeed_SCoeff =0 THEN
	i_rSpeed_SCoeff:=2.0/3.0;
END_IF


(*rDeltV_Abs:=ABS(rDeltV);(*取正值@计算的是平滑时间*)*)
IF rDeltV<>0 THEN
	IF rTime_AccDec<>0 THEN
		rAcceleration_Linear:=rMaxVel_UseCalcAcc/rTime_AccDec;
	ELSE(*非法值处理*)
		rAcceleration_Linear:=1.5;
	END_IF
	(*需要的总时间@s*)
	rTime_Even:=ABS(rDeltV)/rAcceleration_Linear;(*不会/0*)
	rTotalTime:=rTime_S+rTime_Even;
	IF byCalcType=2 THEN(*总时间=平滑时间+dv/100*界面时间;平滑时间=总时间*系数*)
		rTime_S_Use:=rTotalTime*i_rSpeed_SCoeff;
		rTime_Even:=rTotalTime-rTime_S_Use;
	ELSIF  byCalcType=3 THEN(*总时间=dv/100*界面时间;平滑时间=总时间*系数*)
		rTotalTime:=rTime_Even;
		rTime_S_Use:=rTotalTime*i_rSpeed_SCoeff;
		rTime_Even:=rTotalTime-rTime_S_Use;
	ELSE(*byCalcType=1 默认*)(*总时间=平滑时间+dv/100*界面时间;平滑时间按照界面设置*)
		rTime_S_Use:=rTime_S;
	END_IF
	rAcceleration_Need:=2*rDeltV/(2*rTime_Even+rTime_S_Use);(*不会/0*)

	(*解方程用的A、B、C*)
	rA:=rAcceleration_Need/3.0;(*单位m/min/s*)
	rB:=-rAcceleration_Need*rTime_S_Use/3.0-rV0-rVt;(*单位m/min*)
	rC:=rAcceleration_Need*rTime_S_Use*rTime_S_Use/6.0+rV0*rTime_S_Use;(*m/min*s*)
	(*前后两段的时间*)
	rTimeEd_S:=(-rB-SQRT(rB*rB-4*rA*rC))/2.0/rA;(*单位是s*)
	rTimeSa_S:=rTime_S_Use-rTimeEd_S;


	(*两段时间对应的位移*)
	rDis_1:=rV0*rTimeSa_S+rAcceleration_Need*rTimeSa_S*rTimeSa_S/6.0;(*m/min*s*)
	rDis_1:=rDis_1/60.0;(*m*)
	rDis_2:=rVt*rTimeEd_S-rAcceleration_Need*rTimeEd_S*rTimeEd_S/6.0;
	rDis_2:=rDis_2/60.0;(*m*)
ELSE
	rTimeSa_S:=i_iTimeSa_S;
	rTimeEd_S:=i_iTimeEd_S;
	rTime_Even:=0;
	rDis_1:=0;
	rDis_2:=0;
END_IF
IF i_prTimeSa_S<>0 THEN
	i_prTimeSa_S^:=rTimeSa_S;
END_IF
IF i_prTimeEd_S<>0 THEN
	i_prTimeEd_S^:=rTimeEd_S;
END_IF
IF i_prDis_Sa<>0 THEN
	i_prDis_Sa^:=rDis_1;
END_IF
IF i_prDis_Ed<>0 THEN
	i_prDis_Ed^:=rDis_2;
END_IF
IF i_prTime_Total<>0 THEN
	i_prTime_Total^:=rTotalTime;
END_IF
IF i_prTime_SmActual<>0 THEN
	i_prTime_SmActual^:=rTime_S_Use;
END_IF
IF i_plrTime_Even<>0 THEN
	i_plrTime_Even^:=rTime_Even;
END_IF