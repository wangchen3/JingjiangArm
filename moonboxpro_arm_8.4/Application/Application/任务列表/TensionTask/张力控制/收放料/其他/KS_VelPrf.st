(*@CES
Name=KS_VelPrf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=b931f0d4-2560-4387-b073-ed705f607109
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_VelPrf : BOOL
(*2024.04.12.181136 增加了计算最大加速度的速度输入*)
VAR_INPUT
	i_xEn:BOOL;(*规划使能*)
	i_xAcc:BOOL;(*加速*)
	i_xDec:BOOL;(*减速*)
	i_iTime_PlcCycle:INT:=20;(*plc执行时间*)
	i_iAccTime:INT;(*加速时间S|0加速到最大速度的时间|写0则直接赋值*)
	i_iDecTime:INT;(*减速时间S|由最大速度减速到0的时间|写0则直接赋值*)
	i_iVel_Max:INT;(*最大速度|用来计算加速度*)
	i_rVel_Tar:REAL;(*目标速度|如果目标速度等于特殊值 例如-222，我们根据按钮加减速。否则根据目标速度加减速*)
	i_prVel_Cur:POINTER TO REAL;(*当前速度*)
	i_uiMaxVel_UseCalcAcc:UINT;(*2024.04.12.180908+*)
END_VAR
VAR
	lrAcceleration: LREAL;(*加速度|m/min/ms*)
	lrDeceleration: LREAL;(*减加速度|m/min/ms*)
	xAcc: BOOL;
	xDec: BOOL;
	lrVel_Tar: LREAL;(*目标速度*)
END_VAR
{IMPLEMENTATION}
IF i_xEn THEN(*规划使能*)
	IF  i_prVel_Cur<>0 THEN
		(*计算加减速度*)
		IF i_iAccTime>0 THEN
			lrAcceleration:=UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)/i_iAccTime/1000;(*加速度*)
		END_IF
		IF i_iDecTime>0 THEN
			lrDeceleration:=-UINT_TO_LREAL(i_uiMaxVel_UseCalcAcc)/i_iDecTime/1000;(*减加速度*)
		END_IF

		lrVel_Tar:=i_rVel_Tar;
		(*判断加减速状态*)
		IF i_rVel_Tar<>-222 THEN(*根据目标速度确定加减速*)
			IF i_prVel_Cur^>i_rVel_Tar THEN
				xDec:=TRUE;
			ELSIF i_prVel_Cur^<i_rVel_Tar THEN
				xAcc:=TRUE;
			END_IF
		ELSE(*根据按钮确定加减速度*)
			xAcc:=i_xAcc;(*按钮同时按下 则是加速*)
			xDec:=NOT xAcc AND i_xDec;

			IF xAcc THEN(*加速我们加到最大速度*)
				lrVel_Tar:=i_iVel_Max;
			ELSIF xDec THEN(*减速我们减到0*)
				lrVel_Tar:=0;
			END_IF
		END_IF


		IF xAcc THEN(*加速*)
			IF lrAcceleration<>0 THEN
				i_prVel_Cur^:=i_prVel_Cur^+LREAL_TO_REAL(lrAcceleration*i_iTime_PlcCycle);
				IF i_prVel_Cur^>lrVel_Tar THEN
					i_prVel_Cur^:=LREAL_TO_REAL(lrVel_Tar);
				END_IF
			ELSE
				i_prVel_Cur^:=LREAL_TO_REAL(lrVel_Tar);
			END_IF
		ELSIF xDec THEN(*减速*)
			IF lrDeceleration<>0 THEN
				i_prVel_Cur^:=i_prVel_Cur^+LREAL_TO_REAL(lrDeceleration*i_iTime_PlcCycle);
				IF i_prVel_Cur^<lrVel_Tar THEN
					i_prVel_Cur^:=LREAL_TO_REAL(lrVel_Tar);
				END_IF
			ELSE
				i_prVel_Cur^:=LREAL_TO_REAL(lrVel_Tar);
			END_IF
		END_IF
	END_IF
ELSE(*规划取消*)
	i_prVel_Cur^:=0;
END_IF