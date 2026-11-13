(*@CES
Name=KS_FixedWidthStr
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=54bcfd76-1fab-4aff-97a7-749ae0439a1a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_FixedWidthStr : STRING
VAR_INPUT
	i_sInput: STRING;(* 输入的信息 *)
	i_iNeedWidth: INT;(* 需要的宽度 *)
END_VAR
VAR
	i: INT;
	iLen: INT;
	sResult: STRING;
END_VAR

{IMPLEMENTATION}
iLen:= LEN(i_sInput);
IF iLen>=i_iNeedWidth THEN
	sResult:= RIGHT(i_sInput, i_iNeedWidth);
ELSE
	sResult:= '';
	FOR i:=1 TO (i_iNeedWidth-iLen) BY 1 DO
		sResult:= CONCAT(sResult, '0');
	END_FOR
	sResult:= CONCAT(sResult, i_sInput);
END_IF
KS_FixedWidthStr:= sResult;