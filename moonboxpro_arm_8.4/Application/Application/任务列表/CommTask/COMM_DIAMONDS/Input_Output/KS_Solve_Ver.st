(*@CES
Name=KS_Solve_Ver
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eb7c1164-08c4-4977-9280-cbaed44442c1
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Solve_Ver : BOOL(*版本号解析*)
VAR_INPUT
	i_sVersion: STRING;(*版本号*)
	i_pdwYMD: POINTER TO DWORD;
	i_pdwHMS: POINTER TO DWORD;
	i_pdwVer: POINTER TO DWORD;
END_VAR
VAR
END_VAR

{IMPLEMENTATION}
IF i_pdwYMD<>0 AND i_pdwHMS<>0 AND i_pdwVer<>0 THEN
	
END_IF