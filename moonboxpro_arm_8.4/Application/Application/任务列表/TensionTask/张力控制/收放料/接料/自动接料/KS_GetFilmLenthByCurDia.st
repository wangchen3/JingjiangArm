(*@CES
Name=KS_GetFilmLenthByCurDia
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=749eb407-376c-4b03-9520-854f60f16f91
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetFilmLenthByCurDia : REAL(*剩余料长|m*)
VAR_INPUT
	i_rDia_Cur:REAL;(*当前卷径|毫米*)
	i_rDia_Paper:REAL;(*纸筒卷径|毫米*)
	i_rThickNess:REAL;(*料膜厚度|毫米*)
END_VAR
VAR
	lrFilmLenth: LREAL;
	lrN: LREAL;
	lrpi: LREAL := 3.1415926;
	lrRadius_Cur: LREAL;
	lrRadius_Paper: LREAL;
END_VAR
{IMPLEMENTATION}
lrFilmLenth:=0;
IF i_rDia_Cur>i_rDia_Paper AND
	i_rThickNess>0 THEN
	lrRadius_Cur:=i_rDia_Cur/2;
	lrRadius_Paper:=i_rDia_Paper/2;

	(*求料膜层数|*)
	IF i_rThickNess<>0 THEN
		lrN:=(lrRadius_Cur-lrRadius_Paper)/i_rThickNess;
		lrFilmLenth:=2*lrN*lrpi*lrRadius_Paper+EXPT(lrN,2)*lrPI*i_rThickNess;
	END_IF
END_IF
KS_GetFilmLenthByCurDia:=LREAL_TO_REAL(lrFilmLenth/1000.0);