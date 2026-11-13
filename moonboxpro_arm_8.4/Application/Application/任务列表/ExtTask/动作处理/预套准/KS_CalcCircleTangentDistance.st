(*@CES
Name=KS_CalcCircleTangentDistance
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=1060efe6-291c-4829-ad87-f7b1dbfd88c0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_CalcCircleTangentDistance : LREAL(*计算两个圆的切线距离|*)
VAR_INPUT
	i_lrX_Circle0							: LREAL;(*圆1的圆心坐标x|*)
	i_lrY_Circle0							: LREAL;(*圆1的圆心坐标y|*)
	i_lrDiam_Circle0						: LREAL;(*圆1的直径|*)
	i_lrX_Circle1							: LREAL;(*圆2的圆心坐标x|*)
	i_lrY_Circle1							: LREAL;(*圆2的圆心坐标y|*)
	i_lrDiam_Circle1						: LREAL;(*圆2的直径|*)
	i_xAtSameSide							: BOOL;(*TRUE表示圆是在切线的同一边(外公切)|FALSE表示分别在切线的两边(内公切)|*)
END_VAR
VAR
	lrN										: LREAL;
	lrResult								: LREAL;
	lrCenterDistance						: LREAL;(*两个圆的圆心距|*)
END_VAR
{IMPLEMENTATION}
lrResult:= 0;

(*
/.圆心距|
/.直角三角形的斜边|
/.*)
lrCenterDistance:= SQRT((i_lrX_Circle0-i_lrX_Circle1)*(i_lrX_Circle0-i_lrX_Circle1)+(i_lrY_Circle0-i_lrY_Circle1)*(i_lrY_Circle0-i_lrY_Circle1));
IF i_xAtSameSide THEN
	(*
	/.外公切|
	/.外公切线的长=根号下[圆心距的平方-（大圆半径减小圆半径）的平方]|
	/.*)
	lrN:= (lrCenterDistance*lrCenterDistance)-(((i_lrDiam_Circle0-i_lrDiam_Circle1)/2)*((i_lrDiam_Circle0-i_lrDiam_Circle1)/2));
	IF lrN<0 THEN
		;
	ELSE
		lrResult:= SQRT(lrN);
	END_IF
ELSE
	(*
	/.内公切|
	/.内公切线的长=根号下[圆心距的平方-（大圆半径加小圆半径）的平方]|
	/.*)
	lrN:= (lrCenterDistance*lrCenterDistance)-(((i_lrDiam_Circle0+i_lrDiam_Circle1)/2)*((i_lrDiam_Circle0+i_lrDiam_Circle1)/2));
	IF lrN<0 THEN
		;
	ELSE
		lrResult:= SQRT(lrN);
	END_IF
END_IF
KS_CalcCircleTangentDistance:= lrResult;