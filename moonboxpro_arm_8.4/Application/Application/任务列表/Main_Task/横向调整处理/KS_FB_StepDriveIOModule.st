(*@CES
Name=KS_FB_StepDriveIOModule
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2a257cb6-af09-4887-8b6d-a671211c237a
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_StepDriveIOModule(*使用控制步进电机的模块时 它的数字量输入在%IW4 0：15,输出在%QW4 2：9 位置*)
								(*模块的地址从W0开始。其他起始地址依次类推 如：模块起始地址为W10则数字量量输入输出位于W14位置*)
								(*以起始地址为0举例：启动频率位置W0，
								目标频率位于W1，
								加速度位于W2，
								脉冲个数（读取为执行的个数，写入是规划的个数）位于W3，
								IO（读取为输入，写入为输出）位于W4，
								状态位位于W5。
								其中读取为%IW，写入为%QW地址*)
								(*%%%%%%%%%%%%%必须保证IO输出位于程序执行末尾%%%%%%%%%%%%%%%*)
VAR_INPUT
	i_xInputEn: BOOL;
	i_xOutPutEn: BOOL;
	i_iModuleType:INT;(*编码器模块类型，0继电器数字量模块。1 ENC0410R模块*)
	i_dwAdr_IW0:DWORD;(*输入io第1个word的地址*)
	i_dwAdr_IW1:DWORD;(*输入io第2个word的地址*)
	i_dwAdr_IW2:DWORD;(*输入io第3个word的地址*)
	i_dwAdr_IW3:DWORD;(*输入io第4个word的地址*)
	i_dwAdr_IW4:DWORD;(*输入io第5个word的地址*)
	i_dwAdr_IW5:DWORD;(*输入io第6个word的地址*)

	i_dwAdr_QW0:DWORD;(*输出io第1个word的地址*)
	i_dwAdr_QW1:DWORD;(*输出io第2个word的地址*)
	i_dwAdr_QW2:DWORD;(*输出io第3个word的地址*)
	i_dwAdr_QW3:DWORD;(*输出io第4个word的地址*)
	i_dwAdr_QW4:DWORD;(*输出io第5个word的地址*)
	i_dwAdr_QW5:DWORD;(*输出io第6个word的地址*)
	i_pstStDigitalMicroStepDrive :POINTER TO  StDigitalMicroStepDrive;
	i_pstStStepDriveIOModule:POINTER TO  StStepDriveIOModule;
	i_pstStEnc0410R:POINTER TO StEnc0410R;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	dwRtn: DWORD;
END_VAR

{IMPLEMENTATION}
IF i_pstStDigitalMicroStepDrive<>0 AND i_dwAdr_IW0<>0 AND i_dwAdr_QW0<>0 AND i_pstStStepDriveIOModule<>0 AND
	i_pstStEnc0410R<>0 THEN;
ELSE
	RETURN;
END_IF
IF i_xInputEn THEN
	(*将输入的模块数据复制到输入结构体中*)
	dwRtn:=SysMemCpy(ADR(i_pstStDigitalMicroStepDrive^.awSpace),i_dwAdr_IW0,12);(*共有6个word数据*)
	i_pstStDigitalMicroStepDrive^.xStepDriveWorking:=i_pstStDigitalMicroStepDrive^.wStepDriveCTL_Rd.10;
	i_pstStStepDriveIOModule^.wIX:=i_pstStDigitalMicroStepDrive^.wStepDriveModuleIOData_Rd;(*将读到的IO输入数据赋值给相应IO结构体变量*)
END_IF

IF i_xOutPutEn THEN
	IF i_iModuleType=ENCMODULE_ENC0410R THEN(*ENC0410R模块*)
		i_pstStDigitalMicroStepDrive^.wStepDriveModuleIOData_Wr:=i_pstStEnc0410R^.wInputModeCfg;
	ELSE(*带继电器数字量模块*)
		i_pstStDigitalMicroStepDrive^.wStepDriveModuleIOData_Wr:=i_pstStStepDriveIOModule^.wQX;(*将输出数据写入到相应的输出结构体变量中*)
	END_IF
	dwRtn:=SysMemCpy(i_dwAdr_QW0,ADR(i_pstStDigitalMicroStepDrive^.wStepDrivePulseFre_Sa_Wr),12);(*共有6个word数据*)
END_IF