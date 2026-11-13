(*@CES
Name=KS_FB_CacuHypotenuse_V3
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f624852b-9183-4541-83cd-e00bb1937fb0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_CacuHypotenuse_V3
VAR_INPUT
		i_xEn:BOOL;
		i_rPrRoller_Girth0:REAL;//确认合压位时的版辊周长
		i_rPrRoller_Girth:REAL;
		i_rBrRoller_Girth:REAL;
		i_rFilmThick_Confirm:REAL;//标定合压位时的料膜厚度
		i_rFilmThickNess_Using:REAL;//现在的料膜厚度
		i_rFix_Horizontal_Edge_X:REAL;
END_VAR
VAR_OUTPUT
		o_rCathetus_diff:REAL;
END_VAR
VAR
		rPrRadius0:REAL;//确认合压位时的版辊半径
		rPrRadius:REAL;//换版后的版辊半径
		rBrRadius:REAL;
		rHypotenuse_L0:REAL;//换版前的斜边
		rHypotenuse_L1:REAL;//换版后的斜边
		rCathetus0:REAL;//换版前直角边
		rCathetus1:REAL;//换版后直角边
		rCathetus_diff:REAL;
END_VAR

{IMPLEMENTATION}
IF i_xEn THEN
	IF i_rPrRoller_Girth0 > 0.0 THEN
		rPrRadius0 :=  i_rPrRoller_Girth0/ (2 * gc_lrPI);
	END_IF
	IF i_rPrRoller_Girth> 0.0 THEN
		rPrRadius := i_rPrRoller_Girth / (2 * gc_lrPI);
	END_IF
	
	IF i_rBrRoller_Girth > 0.0 THEN
		rBrRadius := i_rBrRoller_Girth / (2 * gc_lrPI);
	END_IF
	
	rHypotenuse_L0:=rPrRadius0+rBrRadius+i_rFilmThick_Confirm;
	rCathetus0:=SQRT(ABS((rHypotenuse_L0*rHypotenuse_L0) -(i_rFix_Horizontal_Edge_X*i_rFix_Horizontal_Edge_X)) );
	rHypotenuse_L1:=rPrRadius+rBrRadius+i_rFilmThickNess_Using;
	rCathetus1:=SQRT(ABS((rHypotenuse_L1*rHypotenuse_L1) -(i_rFix_Horizontal_Edge_X*i_rFix_Horizontal_Edge_X)) );
	rCathetus_diff:=rCathetus1-rCathetus0; //换版前和换版后合压位置的竖直位置差 mm
	o_rCathetus_diff:=rCathetus_diff;
	
END_IF