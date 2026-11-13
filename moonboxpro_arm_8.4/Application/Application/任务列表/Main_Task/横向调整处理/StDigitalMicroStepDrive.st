(*@CES
Name=StDigitalMicroStepDrive
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=10e217d5-ea4e-41f0-93bf-b76d90085cfe
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
TYPE StDigitalMicroStepDrive :(*步进电机结构体*)
STRUCT
	xStepDriveEn:BOOL;(*步进电机使能*)
	xStepDriveDir:BOOL;(*步进电机方向*)
	xStepDriveMode:BOOL;(*电机速度位置模式*)(*TRUE 为位置模式，false为速度模式*)
	xStepDriveSpeedMode_Run:BOOL;(*步进电机速度模式启动标志*)
	xStepDriveWorking:BOOL;(*脉冲输出中*)
	xStepDriveAlarm:BOOL;(*步进电机报警*)
	iStepDriveState:INT;(*步进电机状态机*)

	udiStepDriveWorkingTime:UDINT;(*步进电机执行时间*)
	iStepDrivePulsePRev:INT;(*步进电机每圈的脉冲数*)
	iStepDriveNum:INT;(*步进电机减速比分子*)
	iStepDriveDen:INT;(*步进电机减速比分母*)
	lrStepDrivePosPPulse:LREAL;(*步进电机每个脉冲对应的位置值，单位mm*)(*通过测量得到，或者通过计算得到*)
	iStepDriveAccTime_ms:INT;(*步进电机加速时间ms*)
	wStepDrivePulseFre_Sa:WORD;(*步进电机启动脉冲频率*)
	wStepDrivePulseFre_Tar:WORD;(*步进电机目标脉冲频率*)
	wStepDriveAcc_SaToTar:WORD;(*到达目标速度的加速度*)
	wStepDrivePulse:WORD;(*步进电机脉冲数*)
	diStepDrivePluse_Act:DINT;(*步进电机实际走的脉冲数*)
	wStepDrivePulse_Act_Rd_Bak:WORD;(*读取到的步进电机上个周期实际走的脉冲数*)


(*读取模块中的数据*)
	awSpace:ARRAY [1..3] OF WORD;(*W0,W1,W2*)
	wStepDrivePulse_Act_Rd:WORD;(*读取到的步进电机实际走的脉冲数*)(*W3*)
	wStepDriveModuleIOData_Rd:WORD;(*步进电机模块的io输入值*)(*W4*)
	wStepDriveCTL_Rd:WORD;(*读取到的模块的数据*)(*W5*)
(*写入到模块中的参数。规定使用数字量模块 但是plc配置的时候需要配置模拟量模块*)
	wStepDrivePulseFre_Sa_Wr:WORD;(*步进电机启动脉冲频率写入值*)(*W0*)
	wStepDrivePulseFre_Tar_Wr:WORD;(*步进电机目标脉冲频率写入值*)(*W1*)
	wStepDriveAcc_SaToTar_Wr:WORD;(*到达目标速度的加速度写入值*)(*W2*)
	wStepDrivePulse_Wr:WORD;(*步进电机脉冲数写入值*)(*W3*)
	wStepDriveModuleIOData_Wr:WORD;(*步进电机模块的io输出写入*)(*W4*)
	wStepDriveCTL:WORD;(*步进电机控制位*)(*bit9:反馈脉冲数清零(*W5*)
								bit10:脉冲输出标志，1：输出中
								bit11:电机方向
								bit12:速度模式时，高电平输出脉冲，低电平停止输出
								bit13:位置模式时，上升沿开始输出脉冲，脉冲个数到达时停止输出
								bit14:速度、位置模式 0：速度模式，1：位置模式
								bit15:模块使能 0：脉冲输出无效，1：有效
							        *)
END_STRUCT
END_TYPE

{IMPLEMENTATION}
