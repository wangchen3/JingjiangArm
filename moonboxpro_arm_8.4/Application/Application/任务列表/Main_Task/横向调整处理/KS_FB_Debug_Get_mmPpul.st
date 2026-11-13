(*@CES
Name=KS_FB_Debug_Get_mmPpul
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=61707722-1ee3-4896-b414-72dee3b67cb6
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_Debug_Get_mmPpul(*调试模式下计算出的每个脉冲对应的位置值单位mm/pul*)
VAR_INPUT
	i_xEn:BOOL;(*功能块使能*)
	i_xStartTrig:BOOL;(*启动步进电机*)
	i_xCalEn:BOOL;(*计算使能标志*)
	i_iNum:INT;(*执行该动作的色组号*)
	i_iStepDriveSa_Vel:INT;(*步进电机启动速度*)
	i_iStepDrivePreReg_Vel:INT;(*z步进电机预套速度R/MIN*)
	i_diPulse:DINT;(*执行的脉冲数pul*)
	i_lrPos_Act:LREAL;(*实际走的距离mm*)
	i_pastStDigitalMicroStepDrive :POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;(**)
	o_xDebugTestDone: BOOL;(*测试完成了*)
	o_lrResult:LREAL;(*计算出的结果*)(*只有效一个周期*)
	o_iErrCode: INT;(*-1 地址错误。-2 数组下标越界,-3 输入参数错误*)
END_VAR
VAR
	xPreStartTrig: BOOL;(*用来控制启动检测按钮的上升沿*)
	stStDigitalMicroStepDrive_Temp: StDigitalMicroStepDrive;
	lrTemp: LREAL;
	lrTemp1: LREAL;
	xDebugTesting: BOOL;(*处于测试状态中*)
	xPreStepDriveWorking: BOOL;(*用来检测脉冲输出下降沿*)
	xPreCalEn: BOOL;(*用于检测计算使能上升沿*)
END_VAR

{IMPLEMENTATION}
(*输入参数检查*)
o_iErrCode:=0;
o_lrResult:=0;
IF i_pastStDigitalMicroStepDrive<>0 THEN;
ELSE
	o_iErrCode:=-1;
	RETURN;
END_IF

IF i_iNum>=1 AND i_iNum<=MAX_UNIT_NUM THEN
;
ELSE
	i_iNum:=1;
	o_iErrCode:=-2;
END_IF

IF ABS(i_diPulse)>65535 AND i_diPulse<>0 THEN
	i_diPulse:=65535*i_diPulse/i_diPulse;
	o_iErrCode:=-3;
END_IF

IF i_lrPos_Act<0 THEN
	i_lrPos_Act:=ABS(i_lrPos_Act);
	o_iErrCode:=-3;
END_IF

IF i_iStepDriveSa_Vel<0 THEN
	i_iStepDriveSa_Vel:=ABS(i_iStepDriveSa_Vel);
	o_iErrCode:=-3;
END_IF

IF i_iStepDrivePreReg_Vel<0 THEN
	i_iStepDrivePreReg_Vel:=ABS(i_iStepDrivePreReg_Vel);
	o_iErrCode:=-3;
END_IF

stStDigitalMicroStepDrive_Temp:=i_pastStDigitalMicroStepDrive^[i_iNum];
IF i_xEn THEN(*使能计算*)
	IF i_xStartTrig  AND NOT xPreStartTrig THEN(*检测按钮上升沿*)
		IF NOT xDebugTesting THEN
			o_xDebugTestDone:=FALSE;
			lrTemp:=i_pastStDigitalMicroStepDrive^[i_iNum].iStepDrivePulsePRev*i_iStepDriveSa_Vel/60.0;(*pul/s*)
			lrTemp1:=i_pastStDigitalMicroStepDrive^[i_iNum].iStepDrivePulsePRev*i_iStepDrivePreReg_Vel/60.0;(*pul/s*)
			IF i_pastStDigitalMicroStepDrive^[i_iNum].iStepDriveState=STEPDRIVE_IDLE  THEN(*空闲状态*)
				i_pastStDigitalMicroStepDrive^[i_iNum].iStepDriveState:=STEPDRIVE_RUN;(*启动步进电机调整*)
				i_pastStDigitalMicroStepDrive^[i_iNum].wStepDrivePulseFre_Sa:=LREAL_TO_WORD(lrTemp);
				i_pastStDigitalMicroStepDrive^[i_iNum].wStepDrivePulseFre_Tar:=LREAL_TO_WORD(lrTemp1);
				i_pastStDigitalMicroStepDrive^[i_iNum].wStepDrivePulse:=DINT_TO_WORD(ABS(i_diPulse));(*写入的脉冲数*)
				i_pastStDigitalMicroStepDrive^[i_iNum].xStepDriveMode:=TRUE;(*位置模式*)
				i_pastStDigitalMicroStepDrive^[i_iNum].xStepDriveSpeedMode_Run:=FALSE;(*置位速度模式输出标志*)
				IF i_diPulse>0 THEN
					i_pastStDigitalMicroStepDrive^[i_iNum].xStepDriveDir:=TRUE;(*为正值的时候我们认为是向传动侧转动，由于默认方向是向操作侧转动，故写为true*)
				ELSE
					i_pastStDigitalMicroStepDrive^[i_iNum].xStepDriveDir:=FALSE;(*为负值的时候我们认为是向操作侧转动，由于默认方向是向操作侧转动，故写为false*)
				END_IF
			END_IF
		ELSE(*再次按下启动按钮我们就退出测试位置的状态*);
			i_pastStDigitalMicroStepDrive^[i_iNum].iStepDriveState:=STEPDRIVE_IDLE;(*先退出到空闲状态*)
		END_IF
		xDebugTesting:=NOT xDebugTesting;
	END_IF



	IF xDebugTesting THEN (*已经处于测试的状态了,这个时候需要一直检测是否执行完成了*)
		IF NOT i_pastStDigitalMicroStepDrive^[i_iNum].xStepDriveWorking AND  xPreStepDriveWorking THEN(*脉冲输出标志下降沿*)
			i_pastStDigitalMicroStepDrive^[i_iNum].iStepDriveState:=STEPDRIVE_IDLE;(*退出到空闲状态*)
			xDebugTesting:=FALSE;
			o_xDebugTestDone:=TRUE;
		END_IF
	ELSE;
	END_IF

	IF o_xDebugTestDone THEN (*测试完成 接着我们计算每个脉冲对应的位置值*)
		IF i_xCalEn AND NOT xPreCalEn THEN(*计算上升沿标志*)
			IF i_pastStDigitalMicroStepDrive^[i_iNum].diStepDrivePluse_Act<>0 THEN
				o_lrResult:=ABS(i_lrPos_Act/i_pastStDigitalMicroStepDrive^[i_iNum].diStepDrivePluse_Act);
			ELSE
				o_iErrCode:=-4;
			END_IF
		END_IF
	END_IF
ELSE
	xDebugTesting:=FALSE;
	o_xDebugTestDone:=FALSE;
END_IF
xPreStepDriveWorking:=i_pastStDigitalMicroStepDrive^[i_iNum].xStepDriveWorking;
xPreStartTrig:=i_xStartTrig;
xPreCalEn:=i_xCalEn;