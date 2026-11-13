(*@CES
Name=KS_FB_AdjustBandLen_II
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4ae7b067-0880-49dd-8697-9ec5545f2595
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_AdjustBandLen_II
VAR_INPUT
	i_xEn : BOOL;
	i_plrUsingGirth : POINTER TO REAL;
	i_prErrLength_Band : POINTER TO REAL;
	//2025.03.14.155651 | 整机色组同步带长的不调整区 单位mm 2字节
	i_rBandLengthNotAdjArea					: REAL;
	i_rGirthStep_Kp : REAL;
	i_rGirthStep_Kd : REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	lrGirthTemp : LREAL;
	lrGirthStep_Temp : LREAL;
	rGirthStep : REAL := 0.01;
	rThreshold : REAL;
	rPreErrLength_Band : REAL;
	
	
	rErrRange : REAL := 0.01;
	rErrRange0 : REAL := 0.03;
	rErrRangeI : REAL := 0.1;
	rErrRangeII : REAL := 0.5;
	rErrRangeIII : REAL := 1;
	rGirthAdjustment0 : REAL := 0.003;
	rGirthAdjustmentI : REAL := 0.01;
	rGirthAdjustmentII : REAL := 0.03;
	rGirthAdjustmentIII : REAL := 0.06;
	rGirthAdjustmentIV : REAL := 0.1;
	
	lrUsingGirth : LREAL;
	rErrLength_Band : LREAL;

END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_plrUsingGirth<>0 AND
		i_prErrLength_Band<>0 THEN(*指针合法*)
(*
		lrGirthTemp:=0;(*版周长步进量临时变量*)
		//lrGirthStep_Temp:=0.01; (*版周长步进量*)
(*		
		rGirthAdjustmentII := 0.02;
		rGirthAdjustmentIII := 0.1;
		rGirthAdjustmentIV := 0.2;
/////////////////////////////////////////////////
		IF ABS(i_prErrLength_Band^) <= i_rBandLengthNotAdjArea THEN
			;
		ELSIF ABS(i_prErrLength_Band^) <= rErrRange0 THEN
			lrGirthStep_Temp := rGirthAdjustment0;
		ELSIF ABS(i_prErrLength_Band^) <= rErrRangeI THEN
			lrGirthStep_Temp := rGirthAdjustmentI;
		ELSIF ABS(i_prErrLength_Band^) <= rErrRangeII THEN
			lrGirthStep_Temp := rGirthAdjustmentII;
		ELSIF ABS(i_prErrLength_Band^) <= rErrRangeIII THEN
			lrGirthStep_Temp := rGirthAdjustmentIII;
		ELSE
			lrGirthStep_Temp := rGirthAdjustmentIV;
		END_IF	
*)		
		IF ABS(i_prErrLength_Band^) >= i_rBandLengthNotAdjArea THEN
			lrGirthStep_Temp := ABS(i_prErrLength_Band^)*i_rGirthStep_Kp;//
			IF lrGirthStep_Temp<0.003 THEN
				lrGirthStep_Temp:=0.003;
			END_IF
			IF lrGirthStep_Temp>0.2 THEN
				lrGirthStep_Temp:=0.2;
			END_IF
		ELSE
			lrGirthStep_Temp := 0;
		END_IF	
				
		IF ABS(i_prErrLength_Band^)>i_rBandLengthNotAdjArea(*i_pstStGrpParam^.rPressure_AnalogThreshold*) THEN
			rThreshold:=0.001;
		ELSE
			rThreshold:=0;
		END_IF

		IF  i_prErrLength_Band^ >i_rBandLengthNotAdjArea(*i_pstStGrpParam^.rPressure_AnalogThreshold*) THEN
			//IF  i_prErrLength_Band^>rPreErrLength_Band+rThreshold THEN(*位置值越来越大了*)
				lrGirthTemp:=lrGirthStep_Temp;
			//END_IF
		ELSIF  i_prErrLength_Band^ <-i_rBandLengthNotAdjArea(*i_pstStGrpParam^.rPressure_AnalogThreshold*)  THEN
			//IF  i_prErrLength_Band^+rThreshold<rPreErrLength_Band THEN(*位置值越来越小了*)
				lrGirthTemp:=-lrGirthStep_Temp;
			//END_IF
		END_IF
		
		lrGirthStep_Temp := i_prErrLength_Band^*i_rGirthStep_Kp+
				i_rGirthStep_Kd*(i_prErrLength_Band^-rPreErrLength_Band);
		IF lrGirthStep_Temp<0.003 AND lrGirthStep_Temp>0 THEN
			lrGirthStep_Temp:=0.003;
		ELSIF lrGirthStep_Temp>-0.003 AND lrGirthStep_Temp<0 THEN
			lrGirthStep_Temp:=-0.003;	
		END_IF
		IF lrGirthStep_Temp>0.2 THEN
			lrGirthStep_Temp:=0.2;
		ELSIF lrGirthStep_Temp<-0.2 THEN
			lrGirthStep_Temp:=-0.2;			
		END_IF
		
		IF ABS(i_prErrLength_Band^)<i_rBandLengthNotAdjArea(*i_pstStGrpParam^.rPressure_AnalogThreshold*) THEN
			lrGirthStep_Temp:= 0;
		END_IF
		
		
		i_plrUsingGirth^:=i_plrUsingGirth^+lrGirthStep_Temp;
		rPreErrLength_Band:=i_prErrLength_Band^;
*)
		//IF ABS(i_prErrLength_Band^) < 1 THEN
			i_plrUsingGirth^:= i_plrUsingGirth^+i_prErrLength_Band^;
		//END_IF
	END_IF
END_IF

