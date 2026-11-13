(*@CES
Name=KS_Taper_Straight
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=74716efb-2a9a-4cd3-af40-131a820a6ef5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Taper_Straight : LREAL(*锥度直线算法*)(*输出当前锥度*)
(*2025.1.9.162837 增加当前卷径输入*)
VAR_INPUT
	i_rDiamCurAxis_Rw:REAL;
	i_rTaper_Begin_Rw: REAL;(*起始锥度*)
	i_rTaper_End_Rw: REAL;(*结束锥度*)
	i_rDiamTaper_Begin_Rw: REAL;(*起始锥度-直径*)
	i_rDiamTaper_End_Rw: REAL;(*结束锥度-直径*)		
END_VAR
VAR
	lrTempPercent: LREAL; (*临时用来计算%的变量*)
	lrCurrentTaper:LREAL;
END_VAR
{IMPLEMENTATION}
lrCurrentTaper:=0;
IF i_rDiamTaper_Begin_Rw<i_rDiamTaper_End_Rw THEN
	IF i_rDiamCurAxis_Rw<=i_rDiamTaper_Begin_Rw THEN
		(*最小卷用最大张力*)
		lrCurrentTaper:= i_rTaper_Begin_Rw;
	ELSIF i_rDiamCurAxis_Rw>=i_rDiamTaper_End_Rw THEN
		(*最大卷用最小张力*)
		lrCurrentTaper:= i_rTaper_End_Rw;
	ELSE
		(*卷径锥度的线性关系有效*)
		lrTempPercent:= (i_rDiamCurAxis_Rw - i_rDiamTaper_Begin_Rw) / (i_rDiamTaper_End_Rw - i_rDiamTaper_Begin_Rw);
		lrCurrentTaper:= i_rTaper_Begin_Rw - lrTempPercent * (i_rTaper_Begin_Rw - i_rTaper_End_Rw);
	END_IF
ELSE
	lrCurrentTaper:= 0;
END_IF
KS_Taper_Straight:=lrCurrentTaper;