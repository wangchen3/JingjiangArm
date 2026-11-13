(*@CES
Name=KS_FB_StepDriveCTL
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=3753a5b1-b12f-402f-80a4-225f85f9de8f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_StepDriveCTL(*控制步进电机的模块参数配置*)
VAR_INPUT
	i_xEn:BOOL;(*控制使能了*)
	i_iUMax:INT;(*最大色组号*)
	i_pastStDigitalMicroStepDrive :POINTER TO ARRAY [1..MAX_UNIT_NUM] OF StDigitalMicroStepDrive;
	i_iAccTime_ms:INT;(*加速时间*)(*ms*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;(**)
	o_iErrCode: INT;(*-1指针地址错误，-2输入参数错误，-3变量溢出*)
END_VAR
VAR
	iN: INT;
	iAccTime_ms: INT;
	lrAccSaToTar: LREAL;(*从启动频率加速到目标频率的加速度*)
	wAccSaToTar: WORD;(*写入到目标模块的加速度值*)
	wStepDrivePulse: WORD;(*步进电机脉冲数*)
	wStepDriveFre_Sa: WORD;(*启动频率*)
	wStepDriveFre_Tar: WORD;(*目标频率*)
	lrTemp: LREAL;
	wStepDriveCTL: WORD;(*步进电机控制位*)
	iStepDriveState: INT;(*状态机*)
	xStepDriveMode: BOOL;(*电机速度位置模式TRUE 为位置模式，false为速度模式*)
	xStepDriveDir: BOOL;(*步进电机方向*)
	xStepDriveWorking: BOOL;(*步进电机工作中*)
	xStepDriveSpeedMode_Run: BOOL;(*步进电机速度模式启动标志*)
	udiStepDriveWorkingTime: UDINT;
	wStepDrivePulseFre_Limit: WORD:=(*5000*)0;(*目标频率限值暂时定为5khz|2019.4.24.154848 取消限值*)
END_VAR
VAR CONSTANT
(*
bit9:反馈脉冲数清零
bit10:脉冲输出标志，1：输出中
bit11:电机方向
bit12:速度模式时，高电平输出脉冲，低电平停止输出
bit13:位置模式时，上升沿开始输出脉冲，脉冲个数到达时停止输出
bit14:速度、位置模式 0：速度模式，1：位置模式
bit15:模块使能 0：脉冲输出无效，1：有效
*)
	c_wPosbak_Clear		:WORD:=16#0200;(*反馈脉冲数清零*)
	c_wStepDrive_Dir		:WORD:=16#0800;(*电机方向*)
	c_wSpeedMode_OutCtl	:WORD:=16#1000;(*速度模式输出控制*)
	c_wPosMode_OutCtl	:WORD:=16#2000;(*位置模式输出控制*)
	c_wPosMode			:WORD:=16#4000;(*默认为速度模式，有效为位置模式; 位置模式 速度模式选择，*)
	c_wAIModule_Valid		:WORD:=16#8000;(*模块使能*)
END_VAR

{IMPLEMENTATION}
o_iErrCode:=0;
IF i_pastStDigitalMicroStepDrive<>0  THEN;
ELSE
	o_iErrCode:=-1;
	RETURN;
END_IF

(*2024.01.16.123934*)
IF i_iUMax<=0 OR
	i_iUMax>MAX_UNIT_NUM THEN
	i_iUMax:=MAX_UNIT_NUM;
END_IF

IF i_xEn THEN
	o_xEn:=TRUE;
	FOR iN:=1 TO i_iUMax BY 1 DO(*2024.01.16.123939*)
		IF   i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse>65535 THEN
			wStepDrivePulse:=65535;
			o_iErrCode:=-2;
		ELSE
			wStepDrivePulse:= i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse;
		END_IF


		IF i_iAccTime_ms<>0 THEN
			iAccTime_ms:=ABS(i_iAccTime_ms);
		ELSE
			iAccTime_ms:=100;
			o_iErrCode:=-2;
		END_IF
		i_pastStDigitalMicroStepDrive^[iN].iStepDriveAccTime_ms:=iAccTime_ms;

(*起始频率大于目标频率时 让起始频率等于目标频率*)
		IF i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa>i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar THEN
			i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa:=i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar;
		END_IF
		wStepDriveFre_Sa:=i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa;
		lrTemp:=EXPT(2,12)/EXPT(5,6);(*由EXPT(2,18)/EXPT(10,6)化简而来*)
		wStepDriveFre_Sa:=LREAL_TO_WORD(wStepDriveFre_Sa*lrTemp);(*计算写入模块中的值*)



		IF i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar>=wStepDrivePulseFre_Limit AND
			wStepDrivePulseFre_Limit<>0 THEN(*目标频率不能溢出*)(*2019.4.19.091335|增加了目标频率不限制方式*)
			wStepDriveFre_Tar:=wStepDrivePulseFre_Limit;
		ELSE
			wStepDriveFre_Tar:=i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar;
		END_IF
		lrTemp:=EXPT(2,12)/EXPT(5,6);(*由EXPT(2,18)/EXPT(10,6)化简而来*)
		wStepDriveFre_Tar:=LREAL_TO_WORD(wStepDriveFre_Tar*lrTemp);(*计算写入模块中的值*)


		(*计算加速度*)
		lrTemp:=EXPT(2,22)/EXPT(5,12);(*EXPT(2,32)/EXPT(10,12)化简得到的*)(*计算出的加速度*该值就是需要写入模块中的值*)
		lrAccSaToTar:=ABS(WORD_TO_LREAL(i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar)-i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa)
					*1000/iAccTime_ms;(*HZ/S*)
		lrAccSaToTar:=lrAccSaToTar*lrTemp;
		wAccSaToTar:=LREAL_TO_WORD(lrAccSaToTar);(*需要写入到模块中的加速度值*)
		IF lrAccSaToTar>65535 THEN
			wAccSaToTar:=1000;
			o_iErrCode:=-3;
		END_IF



		i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa_Wr:=0;
		i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar_Wr:=0;
		i_pastStDigitalMicroStepDrive^[iN].wStepDriveAcc_SaToTar_Wr:=0;
		i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Wr:=0;

		wStepDriveCTL:=0;(*清零该控制位*)
		iStepDriveState:=i_pastStDigitalMicroStepDrive^[iN].iStepDriveState;
		xStepDriveMode:=i_pastStDigitalMicroStepDrive^[iN].xStepDriveMode;
		xStepDriveDir:=i_pastStDigitalMicroStepDrive^[iN].xStepDriveDir;
		xStepDriveWorking:=i_pastStDigitalMicroStepDrive^[iN].xStepDriveWorking;
		xStepDriveSpeedMode_Run:=i_pastStDigitalMicroStepDrive^[iN].xStepDriveSpeedMode_Run;
		CASE iStepDriveState OF
			STEPDRIVE_IDLE:;
			STEPDRIVE_RUN,STEPDRIVE_CLR:
				wStepDriveCTL:=c_wPosbak_Clear;
				iStepDriveState:=STEPDRIVE_WAITING;
(*2019.09.10.112334|liu.yt|初始化值放在两个CASE都执行|重复值时wStepDrivePulse_Act_Rd_Bak未初始化*)
			(*放在这个周期是希望在计数清零执行后*)
				i_pastStDigitalMicroStepDrive^[iN].diStepDrivePluse_Act:=0;(*初始化脉冲计数值*)
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Act_Rd_Bak:=i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Act_Rd;(*初始化上个周期的值*)

			STEPDRIVE_WAITING:(*等一个周期*)
				iStepDriveState:=STEPDRIVE_MODULE_VALID;
			STEPDRIVE_MODULE_VALID:(*模块使能*)
			(*放在这个周期是希望在计数清零执行后*)
				i_pastStDigitalMicroStepDrive^[iN].diStepDrivePluse_Act:=0;(*初始化脉冲计数值*)
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Act_Rd_Bak:=i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Act_Rd;(*初始化上个周期的值*)

				wStepDriveCTL:=c_wAIModule_Valid;
				IF xStepDriveMode THEN (*位置模式*)
					wStepDriveCTL:=wStepDriveCTL+c_wPosMode;
				ELSE(*速度模式*)
					wStepDriveCTL:=wStepDriveCTL;
				END_IF

				IF xStepDriveDir THEN (*步进电机方向*)
					wStepDriveCTL:=wStepDriveCTL+c_wStepDrive_Dir;
				ELSE;(*默认方向*)
				END_IF
				(*2022.11.19.160459 从case-STEPDRIVE_PULSEOUT复制到此处 提前写入一个周期
				@发现手动有时候脉冲输出不对
				@发现手动有时候会步输出。测试复制到此处出现的概率小很多了*)
				(*写入启动频率 目标频率 加速度值*)
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa_Wr:=wStepDriveFre_Sa;
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar_Wr:=wStepDriveFre_Tar;
				i_pastStDigitalMicroStepDrive^[iN].wStepDriveAcc_SaToTar_Wr:=wAccSaToTar;

				iStepDriveState:=STEPDRIVE_PULSEOUT;(*进入脉冲输出逻辑*)
			STEPDRIVE_PULSEOUT:(*脉冲输出*)(*脉冲输出比电机方向配置晚一个周期*)
				(*写入启动频率 目标频率 加速度值*)
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa_Wr:=wStepDriveFre_Sa;
				i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar_Wr:=wStepDriveFre_Tar;
				i_pastStDigitalMicroStepDrive^[iN].wStepDriveAcc_SaToTar_Wr:=wAccSaToTar;

				IF xStepDriveMode THEN (*位置模式*)
					wStepDriveCTL:=c_wAIModule_Valid+c_wPosMode;
				(*写入脉冲数*)
					IF wStepDrivePulse<>0 THEN
						i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Wr:=wStepDrivePulse;
						wStepDriveCTL:=wStepDriveCTL+c_wPosMode_OutCtl;(*有效之后输出脉冲*)(*上升沿触发*)
					END_IF
					i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse:=0;
				ELSE(*速度模式*)(*该模式启动之后就不能更改参数，除非重新开始*)
					wStepDriveCTL:=c_wAIModule_Valid;
					IF xStepDriveSpeedMode_Run THEN
						wStepDriveCTL:=wStepDriveCTL+c_wSpeedMode_OutCtl;(*有效之后输出脉冲*)
					END_IF
				END_IF

				IF xStepDriveDir THEN (*步进电机方向*)
					wStepDriveCTL:=wStepDriveCTL+c_wStepDrive_Dir;
				ELSE;(*默认方向*)
				END_IF


				(*计算脉冲输出的周期时间*)
				IF  xStepDriveWorking THEN
					udiStepDriveWorkingTime:=udiStepDriveWorkingTime+1;
				ELSE
					udiStepDriveWorkingTime:=0;
				END_IF
			STEPDRIVE_ALARM:(*报警了*)
				wStepDriveCTL:=0;
				o_iErrCode:=-110;

		ELSE;
		END_CASE

(*计算实际走的脉冲数*)
		KS_GetPulse_Act(ADR(i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Act_Rd),
				 ADR(i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Act_Rd_Bak), ADR(i_pastStDigitalMicroStepDrive^[iN].diStepDrivePluse_Act));
		IF udiStepDriveWorkingTime<>0 THEN(**统计脉冲执行的时间*)
			i_pastStDigitalMicroStepDrive^[iN].udiStepDriveWorkingTime:=udiStepDriveWorkingTime;
		END_IF
		i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=iStepDriveState;
		i_pastStDigitalMicroStepDrive^[iN].wStepDriveCTL:=wStepDriveCTL;(*写入到模块的数据*)
	END_FOR
ELSE
	IF o_xEn THEN
		o_xEn:=FALSE;
		FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
			i_pastStDigitalMicroStepDrive^[iN].iStepDriveState:=STEPDRIVE_IDLE;
			i_pastStDigitalMicroStepDrive^[iN].wStepDriveCTL:=0;
			i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Sa_Wr:=0;
			i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulseFre_Tar_Wr:=0;
			i_pastStDigitalMicroStepDrive^[iN].wStepDriveAcc_SaToTar_Wr:=0;
			i_pastStDigitalMicroStepDrive^[iN].wStepDrivePulse_Wr:=0;
		END_FOR
	END_IF
END_IF