(*@CES
Name=KS_HY_UINT_TO_STRING
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e624a904-2250-46e3-9cf7-e5a73eed6aa1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_HY_UINT_TO_STRING : STRING
VAR_INPUT
	i_uiNum: UINT;(* 传入数值 *)
	i_uiLen_fixedwidth: UINT;(* 固定长度 *)
END_VAR
VAR
	uiN: UINT;
	sPrefix: STRING := '0';
	sResult: STRING := '';
	sTmp_raw: STRING := '';
	uiLen_raw: UINT;
END_VAR

{IMPLEMENTATION}
IF i_uiLen_fixedwidth>0 THEN
	sTmp_raw:= UINT_TO_STRING(i_uiNum);(* 原始数值直接转STRING *)
	uiLen_raw:= UDINT_TO_UINT(LEN(sTmp_raw));(* 看转换后长度是否满足 *)
	IF uiLen_raw>i_uiLen_fixedwidth THEN(* 原始数据超过了宽度 *)
		sResult:= MID(sTmp_raw, i_uiLen_fixedwidth, uiLen_raw-i_uiLen_fixedwidth+1);
	ELSIF uiLen_raw<i_uiLen_fixedwidth THEN(* 原始数据不够宽度 *)
		FOR uiN:=1 TO (i_uiLen_fixedwidth-uiLen_raw) BY 1 DO
			sResult:= CONCAT(sResult, sPrefix);
		END_FOR
		sResult:= CONCAT(sResult, sTmp_raw);
	ELSE(* 宽度匹配 *)
		sResult:= sTmp_raw;
	END_IF
END_IF

KS_HY_UINT_TO_STRING:= sResult;
