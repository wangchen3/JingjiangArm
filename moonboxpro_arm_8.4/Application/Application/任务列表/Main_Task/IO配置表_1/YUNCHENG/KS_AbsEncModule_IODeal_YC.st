(*@CES
Name=KS_AbsEncModule_IODeal_YC
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=0364d7b2-f644-4e42-9c39-590d5a538e10
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
FUNCTION_BLOCK KS_AbsEncModule_IODeal_YC
VAR_INPUT
	i_xInputEn:BOOL;
	i_xOutPutEn:BOOL;
	(*这些值的处理未考虑双收双放*)
	i_pdwAbsEncSinglePos_Uw:POINTER TO DWORD;
	i_pwAbsEncMultiPos_Uw:POINTER TO WORD;
	(*收料*)
	i_pdwAbsEncSinglePos_Rw:POINTER TO DWORD;
	i_pwAbsEncMultiPos_Rw:POINTER TO WORD;
	//2025.08.20.152113+
	i_pstStAbsEncIOModule_Uw:POINTER TO StAbsEncIOModule;
	i_pstStAbsEncIOModule_Rw:POINTER TO StAbsEncIOModule;
	
END_VAR
VAR
	wIWTest:WORD;
	wQWTest: WORD;
	byAbsEncSts: BOOL;
END_VAR

{IMPLEMENTATION}
