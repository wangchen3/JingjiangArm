(*@CES
Name=KS_FB_CalcuHypotenuse_V2
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a8a80304-7605-4c77-80a2-5631ceae8e52
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CalcuHypotenuse_V2
VAR_INPUT
	i_xEn:BOOL;
	i_rPrRoller_Girth:REAL;
	i_rNrRoller_Girth:REAL;
	i_rBrRoller_Girth:REAL;
	i_rPos_press_dn_PrnRoller_Pressure_MM:REAL;
	i_rFix_Horizontal_Edge_X:REAL;
	i_lrCurPos_mm : LREAL;
END_VAR
VAR_OUTPUT
	o_rProportion:REAL;
END_VAR
VAR
rPrRadius:REAL;
rNrRadius:REAL;
rBrRadius:REAL;
rHypotenuse_L0:REAL;
rHypotenuse:REAL;//斜边
rCathetus:REAL;//直角边
rPos_press_dn_PrnRoller_Pressure_MM:REAL;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_rPrRoller_Girth > 0.0 THEN
		rPrRadius := i_rPrRoller_Girth / (2 * gc_lrPI);
	END_IF
	IF i_rNrRoller_Girth > 0.0 THEN
		rNrRadius := i_rNrRoller_Girth / (2 * gc_lrPI);
	END_IF

	IF i_rBrRoller_Girth > 0.0 THEN
		rBrRadius := i_rBrRoller_Girth / (2 * gc_lrPI);
	END_IF
	rHypotenuse_L0:=rPrRadius+rBrRadius + i_lrCurPos_mm; //计算原始斜边
	rHypotenuse:=(*3*)i_rPos_press_dn_PrnRoller_Pressure_MM+rHypotenuse_L0;	//斜边
	rCathetus:=SQRT(ABS((rHypotenuse_L0*rHypotenuse_L0) -(i_rFix_Horizontal_Edge_X*i_rFix_Horizontal_Edge_X)) );//竖直边
	rPos_press_dn_PrnRoller_Pressure_MM:=ABS(SQRT(ABS(rHypotenuse*rHypotenuse-i_rFix_Horizontal_Edge_X*i_rFix_Horizontal_Edge_X))-rCathetus);
	o_rProportion := rPos_press_dn_PrnRoller_Pressure_MM/i_rPos_press_dn_PrnRoller_Pressure_MM;
ELSE
	o_rProportion := 1;
END_IF