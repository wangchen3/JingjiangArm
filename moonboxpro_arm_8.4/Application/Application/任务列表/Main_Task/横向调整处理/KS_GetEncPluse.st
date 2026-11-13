(*@CES
Name=KS_GetEncPluse
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2bf59e22-f994-4ac5-8b2b-a54b74aea4c6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetEncPluse : BOOL
VAR_INPUT
	i_pastStDigitalMicroStepDrive :POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
	i_pastStEnc0410R:POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StEnc0410R;
END_VAR
VAR
	iN: INT;
END_VAR

{IMPLEMENTATION}
IF i_pastStDigitalMicroStepDrive<>0 AND i_pastStEnc0410R<>0 THEN
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO(*针对所有轴进行读取*)
		i_pastStEnc0410R^[iN].wInputEncValue:=
		i_pastStDigitalMicroStepDrive^[iN].wStepDriveModuleIOData_Rd;(*读取回来的编码器脉冲个数，和数字量模块输入公用地址*)

		KS_GetPulse_Act(ADR(i_pastStEnc0410R^[iN].wInputEncValue),
						ADR(i_pastStEnc0410R^[iN].wInputEncValue_Bak),
						ADR(i_pastStEnc0410R^[iN].diInputEncValue_Total) );
	END_FOR
END_IF