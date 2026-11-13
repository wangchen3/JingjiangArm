(*@CES
Name=KS_FB_VelocityToVoltage_IfOf
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4be52c15-88f8-41f0-baca-d2b67222a9df
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_VelocityToVoltage_IfOf
VAR_INPUT
	i_xEn: BOOL;
	i_rVel: REAL;
	i_rVel_Film: REAL;
	i_xMachineRev: BOOL;
	i_rUsingGirth: REAL;
	i_rGirth: REAL;
	i_xInchEn: BOOL;
	i_xInchBtn: BOOL;
	i_xInchDir: BOOL;
	i_iInchVel: INT;
	i_iRatedRpm: INT;
	i_iRatedFrq: INT;
	i_iUpperFrq: INT;
	i_uiNum: UINT;
	i_uiDen: UINT;
	
END_VAR
VAR_OUTPUT
	o_xEn: BOOL;
	o_rVolt: REAL;
	o_rVolt_Film: REAL;
END_VAR
VAR
	rUsingGirth: REAL;
	rRpm_Max: REAL;
	rVel_Max: REAL;
	rVel_Max_Film: REAL;
	rVel_Temp: REAL;
	rFilmVel_Temp: REAL;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_iRatedRpm<>0 AND i_iRatedFrq<>0 AND
		i_iUpperFrq<>0 AND i_uiNum<>0 AND i_uiDen<>0 THEN
		rUsingGirth:= i_rUsingGirth;
		rRpm_Max:=INT_TO_REAL(i_iUpperFrq)/i_iRatedFrq*i_iRatedRpm;
		rVel_Max:=rRpm_Max*rUsingGirth*i_uiDen/i_uiNum/1000;
		rVel_Max_Film:=rRpm_Max*i_rGirth*i_uiDen/i_uiNum/1000;
		IF i_xMachineRev THEN
			rVel_Temp:= -i_rVel;
			rFilmVel_Temp:= -i_rVel_Film;
		ELSE
			rVel_Temp:= i_rVel;
			rFilmVel_Temp:= i_rVel_Film;			
		END_IF
		IF i_xInchEn THEN
			IF i_xInchBtn THEN
				IF i_xInchDir THEN
					rVel_Temp:= -i_iInchVel;
				ELSE
					rVel_Temp:= i_iInchVel;
				END_IF
			END_IF
		END_IF
		IF rVel_Max<>0 THEN
			o_rVolt:= rVel_Temp*10.0/rVel_Max;
		END_IF
		//牵引变频自调
		IF rVel_Max_Film<>0 THEN
			o_rVolt_Film:= rFilmVel_Temp*10.0/rVel_Max_Film;
		END_IF
	ELSE
		o_rVolt:= 0;
		o_rVolt_Film:= 0;
	END_IF
END_IF