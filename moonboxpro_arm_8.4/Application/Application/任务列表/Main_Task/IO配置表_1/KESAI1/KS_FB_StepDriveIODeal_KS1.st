(*@CES
Name=KS_FB_StepDriveIODeal_KS1
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=61a728a1-12ea-4f97-af25-7b7b77ea73c8
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_StepDriveIODeal_KS1
VAR_INPUT
	i_xInputEn:BOOL;
	i_xOutPutEn:BOOL;
	i_pastStDigitalMicroStepDrive :POINTER TO  ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
	i_pastStStepDriveIOModule:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StStepDriveIOModule;
	i_pastStEnc0410R:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StEnc0410R;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	wTest: WORD;
	afbKS_FB_StepDriveIOModule: ARRAY [1..MAX_UNIT_NUM] OF KS_FB_StepDriveIOModule;
END_VAR

{IMPLEMENTATION}
