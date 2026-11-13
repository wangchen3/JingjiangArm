(*@CES
Name=KS_UnPack_VisionERR
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=46688986-88ab-493d-84a0-0feefd58abe3
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_UnPack_VisionERR : INT
VAR_INPUT
	i_wERR: WORD;(*接收到的误差值-加密数据*)
	i_pxFlag_valid: POINTER TO BOOL;(*bit15/有效标志*)
	i_pxFlag_update: POINTER TO BOOL;(*bit14/更新标志*)
	i_pxFlag_bitchk: POINTER TO BOOL;(*bit13/校验位*)
	i_piErr: POINTER TO INT;(*bit12~0/误差*)
END_VAR
VAR
	iRtn: INT := 0;(*默认0*)
END_VAR

{IMPLEMENTATION}
IF i_pxFlag_valid<>0 AND
	i_pxFlag_update<>0 AND
	i_pxFlag_bitchk<>0 AND
	i_piErr<>0 THEN
	iRtn:= 0;
	i_pxFlag_valid^:= WORD_TO_BOOL(SHR(i_wERR, 15) AND 16#1);
	i_pxFlag_update^:= WORD_TO_BOOL(SHR(i_wERR, 14) AND 16#1);
	i_pxFlag_bitchk^:= WORD_TO_BOOL(SHR(i_wERR, 13) AND 16#1);
	i_piErr^:= SHR(WORD_TO_INT(SHL(i_wERR, 3)), 3);
ELSE
	iRtn:= -1;
END_IF
KS_UnPack_VisionERR:= iRtn;
