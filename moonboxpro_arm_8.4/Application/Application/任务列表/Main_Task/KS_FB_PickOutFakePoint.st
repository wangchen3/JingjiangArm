(*@CES
Name=KS_FB_PickOutFakePoint
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=a2f1e1a0-e198-4123-93c4-db1d31fdab22
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_PickOutFakePoint
VAR_INPUT
	i_xIsValidError							: BOOL; (*the error is valid or invalid; TRUE :is valid;*)
	i_iError_0_01mm							: INT; (*error value, unit in 0.01mm*)
	i_iVariationBaseValue					: INT  := 5; (*based variation threshold*)
	i_iBoundaryError_0_01mm					: INT  := 50; (*Boundary error*)
	i_iErrorLevel_0_01mm					: INT  := 25; (*error value per level when up than boundary error.*)
	i_iVariationVariationMin				: INT  := 5; (*minimized variation variation*)
	i_iVariationVariationMax				: INT  := 15; (*maximized variation variation*)
END_VAR
VAR_OUTPUT
	o_xFakeIsConfirmed						: BOOL; (*TRUE :confirm is fake error; FALSE :confirm is normal error*)
END_VAR
VAR
	iN										: INT;
	iUsedVariationMaxThreshold				: INT;
	aiBufferedError							: ARRAY [1..3] OF INT; (*buffered error list*)
	aiVariation								: ARRAY [1..2] OF INT; (*variation*)
	iVariationVariation						: INT; (*variation's variation*)
END_VAR

{IMPLEMENTATION}
IF NOT i_xIsValidError THEN (*invalid error process*)
	o_xFakeIsConfirmed:= TRUE;
	aiBufferedError[1]:= 0;
	aiBufferedError[2]:= 0;
	aiBufferedError[3]:= 0;
ELSE (*valid error process*)
	(*误差变化量的变化量不超出10|2016.10.14.120106_*)
	IF ABS(i_iError_0_01mm)<=i_iBoundaryError_0_01mm THEN (*0.5mm内的误差变化量的变化量不超过5不认为是飞点*)
		iUsedVariationMaxThreshold:= i_iVariationBaseValue;
	ELSE
		iUsedVariationMaxThreshold:= i_iVariationBaseValue+(ABS(i_iError_0_01mm)-i_iBoundaryError_0_01mm)/i_iErrorLevel_0_01mm; (*超过0.5mm的误差,每0.25mm一个档位递增变化量的变化量*)
		IF iUsedVariationMaxThreshold>i_iVariationVariationMax THEN (*upper limit*)
			iUsedVariationMaxThreshold:= i_iVariationVariationMax;
		ELSIF iUsedVariationMaxThreshold<i_iVariationVariationMin THEN (*lower limit*)
			iUsedVariationMaxThreshold:= i_iVariationVariationMin;
		END_IF
	END_IF

	(*存放规则:都是用下标1来记录当前误差|2017.3.31.145925_*)
	(*rolling the buffered error list*)
	FOR iN:=3 TO 2 BY -1 DO
		aiBufferedError[iN]:= aiBufferedError[iN-1];
	END_FOR
	aiBufferedError[1]:= i_iError_0_01mm; (*record the current error to buffered error list*)

	(*calculate error variation*)
	FOR iN:=3 TO 2 BY -1 DO
		aiVariation[iN-1]:= aiBufferedError[iN-1]-aiBufferedError[iN]; (*new - old*)
	END_FOR

	(*calculate error variation variation*)
	iVariationVariation:= aiVariation[1] - aiVariation[2];

	IF ABS(iVariationVariation)>ABS(iUsedVariationMaxThreshold) THEN
		o_xFakeIsConfirmed:= TRUE;
	ELSE
		o_xFakeIsConfirmed:= FALSE;
	END_IF
END_IF