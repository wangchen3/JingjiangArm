(*@CES
Name=KS_GetAbsPos_0Rad
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6804038e-cb39-41e6-bf94-3a2690a56994
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetAbsPos_0Rad : DWORD(*获取0弧度对应的*)
VAR_INPUT
	i_xGetAbsPos:BOOL;
	i_dwAbsPos_Cur:DWORD;(*当前绝对位置*)
	i_pdwAbsPos_0Rad:POINTER TO DWORD;(*写入0弧度对应的绝对值位置*)
END_VAR
VAR
END_VAR
{IMPLEMENTATION}
IF i_xGetAbsPos THEN
	IF i_pdwAbsPos_0Rad<>0 THEN
		i_pdwAbsPos_0Rad^:=i_dwAbsPos_Cur;
	END_IF
END_IF