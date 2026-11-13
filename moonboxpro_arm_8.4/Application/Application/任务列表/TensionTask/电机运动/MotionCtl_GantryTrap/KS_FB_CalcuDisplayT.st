(*@CES
Name=KS_FB_CalcuDisplayT
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=554f8a16-8195-4e33-a33d-03d9edef6993
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CalcuDisplayT
VAR_INPUT
	i_xEn:BOOL;
	i_rPrRoller_Girth:REAL;
	i_rNrRoller_Girth:REAL;
	i_rBrnRoller_Girth:REAL;
	//i_rPos_press_dn_PrnRoller_Pressure_MM:REAL;
	i_rFix_Horizontal_Edge_X:REAL;
	i_lrCurPos_mm:REAL;
END_VAR
VAR_OUTPUT
	o_rHypotenuse:REAL;
END_VAR
VAR
	rPrRadius:REAL;
	rNrRadius:REAL;
	rBrRadius:REAL;
	rHypotenuse_L0:REAL;
	rCathetus_Basic: REAL;
	rHypotenuse_L1:REAL;//斜边
	rHypotenuse:REAL;//斜边
	rCathetus:REAL;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_rPrRoller_Girth > 0.0 THEN
		rPrRadius := i_rPrRoller_Girth / (2 * gc_lrPI);
	END_IF
	IF i_rNrRoller_Girth > 0.0 THEN
		rNrRadius := i_rNrRoller_Girth / (2 * gc_lrPI);
	END_IF
	
	IF i_rBrnRoller_Girth > 0.0 THEN
		rBrRadius := i_rBrnRoller_Girth / (2 * gc_lrPI);
	END_IF
	rHypotenuse_L0:=rPrRadius+rBrRadius; //计算原始斜边
	rCathetus_Basic:=SQRT(ABS((rHypotenuse_L0*rHypotenuse_L0) -(i_rFix_Horizontal_Edge_X*i_rFix_Horizontal_Edge_X)) );//原始竖直边
	rCathetus:=rCathetus_Basic+i_lrCurPos_mm;
	rHypotenuse_L1:=SQRT(ABS(rCathetus*rCathetus+i_rFix_Horizontal_Edge_X*i_rFix_Horizontal_Edge_X));
	rHypotenuse:=rHypotenuse_L1-rPrRadius-rBrRadius;
	o_rHypotenuse:=rHypotenuse;
END_IF