(*@CES
Name=KS_FB_FilmSpdCtrl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8e68b64a-5f8e-42af-b4b6-70f4efcd8fe4
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_FilmSpdCtrl
VAR_INPUT
	i_xEn											: BOOL; (* 使能 *)
	i_xFlag_Print									: BOOL; (* 印刷标志 *)
	i_pxFlag_FilmAccDecDone							: POINTER TO BOOL; (* 料膜加速完成标志 *)
	i_rVel_Cur										: REAL; (* 当前速度 *)
	i_iTimeFilmAcc									: INT; (* 料膜加速时间 *)
	i_iTimeFilmDec									: INT; (* 料膜减速时间 *)
END_VAR
VAR_OUTPUT
	o_xEno											: BOOL; (* | *)
	o_rVel_Film										: REAL; (* 料膜速度 *)

END_VAR

VAR
	xRecalcAccelerationFilmAcc: BOOL;
	xRecalcAccelerationFilmDec: BOOL;
	rFilmVelocityAcceleration: REAL;		(*料膜加速加速度 *)
	rTempFilmVelocity: REAL;
END_VAR
{IMPLEMENTATION}
o_xEno:= i_xEn;
IF i_xEn THEN
	IF i_pxFlag_FilmAccDecDone<>0 THEN
		IF i_xFlag_Print THEN (* 印刷状态 *)
			IF NOT i_pxFlag_FilmAccDecDone^ THEN(* 料膜加速未完成 *)
				IF NOT xRecalcAccelerationFilmAcc THEN (* 计算加速度 *)
					rFilmVelocityAcceleration:= i_rVel_Cur/i_iTimeFilmAcc/1000.0; (*加速度单位: m/min/ms*)
					xRecalcAccelerationFilmAcc:= TRUE;
				END_IF
				rTempFilmVelocity:= o_rVel_Film + rFilmVelocityAcceleration * gc_TENSION_TSK_CYCLE_TIME;
				IF rTempFilmVelocity<i_rVel_Cur THEN
					o_rVel_Film:= rTempFilmVelocity;
				ELSE
					o_rVel_Film:= i_rVel_Cur;
					i_pxFlag_FilmAccDecDone^:= TRUE; (* 加速完成 *)
					xRecalcAccelerationFilmAcc:= FALSE;
					xRecalcAccelerationFilmDec:= FALSE;
				END_IF
			ELSE
				o_rVel_Film:= i_rVel_Cur;
			END_IF
		ELSE (* 非印刷状态 *)
			IF (NOT xRecalcAccelerationFilmDec) AND o_rVel_Film<>0 THEN
				rFilmVelocityAcceleration:= o_rVel_Film/i_iTimeFilmDec/1000.0; (*加速度单位: m/min/ms*)
				xRecalcAccelerationFilmDec:= TRUE;
			END_IF

			rTempFilmVelocity:= o_rVel_Film - rFilmVelocityAcceleration * gc_TENSION_TSK_CYCLE_TIME;
			IF rTempFilmVelocity>0 THEN
				o_rVel_Film:= rTempFilmVelocity;
			ELSE
				o_rVel_Film:= 0;
				i_pxFlag_FilmAccDecDone^:= FALSE;
				xRecalcAccelerationFilmDec:= FALSE;
				xRecalcAccelerationFilmAcc:= FALSE;
			END_IF
		END_IF
	END_IF
END_IF