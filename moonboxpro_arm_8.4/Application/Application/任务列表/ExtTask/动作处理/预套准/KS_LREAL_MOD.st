(*@CES
Name=KS_LREAL_MOD
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d022a916-afa9-4b10-a8f8-a759c4e31692
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_LREAL_MOD : LREAL
VAR_INPUT
	i_lrData		: LREAL; (* 被模数 *)
	i_lrDividedBy	: LREAL; (* 模数 *)
END_VAR
VAR
	lrResult		: LREAL;
	diQuotient		: DINT; (* 整数的商/可能存在四舍五入 *)
	lrTmpValue		: LREAL;
END_VAR

{IMPLEMENTATION}
lrResult:= 0;
IF i_lrDividedBy<>0 AND i_lrData<>0 THEN
	diQuotient:= LREAL_TO_DINT(i_lrData/i_lrDividedBy); (* 由于LREAL_TO_DINT()会四舍五入,所以反算回去记得要考虑两边值 *)
	lrTmpValue:= i_lrDividedBy*diQuotient; (* 反算回去的结果 *)
	IF (i_lrData>0 AND lrTmpValue>i_lrData) OR
		(i_lrData<0 AND lrTmpValue<i_lrData) THEN
		(* 说明diQuotient被四舍五入了/比正值大/比负值小 *)
		IF diQuotient>0 THEN
			diQuotient:= diQuotient-1;
		ELSE
			diQuotient:= diQuotient+1;
		END_IF
	END_IF
	lrResult:= i_lrData-i_lrDividedBy*diQuotient;
END_IF
KS_LREAL_MOD:= lrResult;