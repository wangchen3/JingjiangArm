(*@CES
Name=KS_PulseOutCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=26372ce9-281b-45a3-9b8d-535af9137d46
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PulseOutCtl : INT
(*2025.2.19.105619 脉冲输出控制函数@主要针对1610模块以及新款16d驱动器io*)
(*切换模式的话,需要取消使能|i_pbyOutSts^=3只有速度模式才会被写入*)
VAR_INPUT
	i_xEn:BOOL;(*控制使能了*)
	i_xClrPulse_Act_Rd:BOOL;(*清理实际的脉冲数*)
	i_byJudgeOutsts_WaitNum:BYTE:=10;(*等待周期数@超过该值强制清除输出中标志|时间=i_byJudgeOutsts_WaitNum*执行周期*)
	i_dwPulse_1r:DWORD;(*一圈的脉冲数*)
	i_xCtlMode:BOOL;(*控制模式@=false 速度模式|=true 位置模式*)
	i_xVelMod_Run:BOOL;(*速度模式下,启动运动标志@前提是状态机已经启动到了脉冲输出case*)
	i_xDir:BOOL;(*输出的方向@false=正向|=true 反向*)
	i_rVel_Sa:REAL;(*起始速度@r/min*)
	i_rVel:REAL;(*速度值@速度模式 r/min*)
	i_iAccTime_ms:INT;(*加速时间@100*)(*ms*)
	i_pwPulse:POINTER TO WORD;(*输出的脉冲个数-写入后就清零了@位置模式*)
	(*反馈信号*)
	i_xPulseOutting_Rd:BOOL;(*读取到的脉冲输出中标志*)
	i_wPulse_Act_Rd:WORD;(*读取的脉冲输出个数*)
	(*输出*)
	i_piState			:POINTER TO TypeEnumStepDriveStat;(*控制状态@状态机标志*)
	i_pwCtlBit_Wr		:POINTER TO WORD;(*控制bit写入*)
	i_pwFre_Sa_Wr		:POINTER TO WORD;(*起始频率写入到模块或者驱动器的值*)
	i_pwFreq_Tar_Wr		:POINTER TO WORD;(*目标频率写入到模块或者驱动器的值*)
	i_pwAccSaToTar_Wr	:POINTER TO WORD;(*频率加速度写入到模块或者驱动器的值*)
	i_pwPulse_Pos_Wr	:POINTER TO WORD;(*脉冲数写入到模块或者驱动器的值*)
	i_pdiPluse_Act		:POINTER TO DINT;(*实际的脉冲数@开始的时候会清除*)
	i_pwLastPulse_Act_Rd:POINTER TO WORD;(*实际读取的脉冲数记录@上一拍*)
	i_pbyOutSts			:POINTER TO BYTE;(*输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
	i_pxCtlMod_Cur		:POINTER TO BOOL;(*当前控制模式@=false 速度模式|=true 位置模式*)
	i_pbyWaitCnt		:POINTER TO BYTE;(*周期等待计数@根据程序周期计算等待时间*)
END_VAR
VAR
	lrTemp:LREAL;
	dwPulse_Pos:DWORD;(*目前只取了word@因为模块和驱动器都只支持到word类型*)
	lrFreq_Sa: LREAL;(*起始频率@P/S*)
	lrFreq_Tar: LREAL;(*目标频率@P/S*)
	lrAccSaToTar:LREAL;(*起始频率加速到目标频率的加速度@hz/s*)
	wFre_Sa_Wr: WORD;(*起始频率写入到模块或者驱动器的值*)
	wFreq_Tar_Wr: WORD;(*目标频率写入到模块或者驱动器的值*)
	wAccSaToTar_Wr: WORD;(*频率加速度写入到模块或者驱动器的值*)
	wPulse_Pos_Wr:WORD;(*脉冲数写入到模块或者驱动器的值*)
	iState: TypeEnumStepDriveStat;(*控制状态机*)
	wCTLBit: WORD;(*控制位*)
	diPluse_Act:DINT;(*实际的脉冲数*)
	wLastPulse_Act_Rd:WORD;(*实际读取的脉冲数记录@上一拍*)
	iAccTime_ms: INT;
	byOutSts: BYTE;(*输出状态|=0 不输出|=1 输出|=2异常*)
	xCtlMod_Cur: BOOL;(*当前控制模式@=false 速度模式|=true 位置模式*)
	byWaitCnt: BYTE;(*周期等待计数*)

	xFreq_Sa_Wr:BOOL;(*启动频率写入标志*)
	xFreq_Tar_Wr:BOOL;(*目标频率写入标志*)
	xFreq_AccSaToTar_Wr:BOOL;(*加速度频率写入标志*)
	xFreq_Pulse_Pos_Wr:BOOL;(*脉冲写入标志*)
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
IF i_pdiPluse_Act<>0 THEN
	diPluse_Act:=i_pdiPluse_Act^;
END_IF
IF i_pwLastPulse_Act_Rd<>0 THEN
	wLastPulse_Act_Rd:=i_pwLastPulse_Act_Rd^;
END_IF

IF i_xEn THEN
	(*写入到模块或者驱动器的值*)
	IF i_pwPulse<>0 THEN(*写入的脉冲数*)
		wPulse_Pos_Wr:=i_pwPulse^;
	END_IF
	IF i_piState<>0 THEN
		iState:=i_piState^;
	END_IF
	IF i_pbyOutSts<>0 THEN
		byOutSts:=i_pbyOutSts^;
	END_IF
	IF i_pxCtlMod_Cur<>0 THEN
		xCtlMod_Cur:=i_pxCtlMod_Cur^;
	END_IF
	IF i_pbyWaitCnt<>0 THEN
		byWaitCnt:=i_pbyWaitCnt^;
	END_IF


	IF i_iAccTime_ms<>0 THEN
		iAccTime_ms:=ABS(i_iAccTime_ms);
	ELSE
		iAccTime_ms:=100;
	END_IF
	lrTemp:=EXPT(2,12)/EXPT(5,6);(*由EXPT(2,18)/EXPT(10,6)化简而来*)
	(*将起始速度转换为频率*)
	lrFreq_Sa:=i_dwPulse_1r*ABS(i_rVel_Sa)/60.0;(*pul/s*)
	(*将目标速度转换为频率*)
	lrFreq_Tar:=i_dwPulse_1r*ABS(i_rVel)/60.0;(*pul/s*)

	(*起始频率大于目标频率时 让起始频率等于目标频率*)
	IF lrFreq_Sa>lrFreq_Tar THEN
		lrFreq_Sa:=lrFreq_Tar;
	END_IF
	(*计算起始频率应该写入的值*)
	wFre_Sa_Wr:=LREAL_TO_WORD(lrFreq_Sa*lrTemp);(*计算写入模块中的值*)

	(*计算目标频率应该写入的值*)
	wFreq_Tar_Wr:=LREAL_TO_WORD(lrFreq_Tar*lrTemp);(*计算写入模块中的值*)

(*计算加速度*)
	lrTemp:=EXPT(2,22)/EXPT(5,12);(*EXPT(2,32)/EXPT(10,12)化简得到的*)(*计算出的加速度*该值就是需要写入模块中的值*)
	(*计算加速度@从起始频率到目标频率的加速度*)
	lrAccSaToTar:=ABS(lrFreq_Tar-lrFreq_Sa)*1000/iAccTime_ms;(*HZ/S*)
	(*需要写入到模块中的加速度值*)
	wAccSaToTar_Wr:=LREAL_TO_WORD(lrAccSaToTar*lrTemp);

	(*启动case*)
	IF iState = STEPDRIVE_IDLE THEN
		iState:=STEPDRIVE_RUN;
	END_IF
	wCTLBit:=0;(*清零该控制位*)
	xFreq_Sa_Wr:=FALSE;
	xFreq_Tar_Wr:=FALSE;
	xFreq_AccSaToTar_Wr:=FALSE;
	xFreq_Pulse_Pos_Wr:=FALSE;
	CASE iState OF
	STEPDRIVE_IDLE:;
	STEPDRIVE_RUN,STEPDRIVE_CLR:
		IF i_xClrPulse_Act_Rd THEN
			wCTLBit:=c_wPosbak_Clear;
		END_IF
		iState:=STEPDRIVE_WAITING;
		(*放在这个周期是希望在计数清零执行后*)
		diPluse_Act:=0;(*初始化脉冲计数值*)
		wLastPulse_Act_Rd:=i_wPulse_Act_Rd;(*初始化上个周期的值*)
		byOutSts:=255;
		xCtlMod_Cur:=i_xCtlMode;
		byWaitCnt:=0;
	STEPDRIVE_WAITING:(*等一个周期*)
		iState:=STEPDRIVE_MODULE_VALID;
	STEPDRIVE_MODULE_VALID:(*模块使能*)
		(*放在这个周期是希望在计数清零执行后*)
		diPluse_Act:=0;(*初始化脉冲计数值*)
		wLastPulse_Act_Rd:=i_wPulse_Act_Rd;(*初始化上个周期的值*)

		wCTLBit:=c_wAIModule_Valid;
		IF xCtlMod_Cur THEN (*位置模式*)
			wCTLBit:=wCTLBit+c_wPosMode;
		ELSE(*速度模式*)
			wCTLBit:=wCTLBit;
		END_IF

		IF i_xDir THEN (*步进电机方向*)
			wCTLBit:=wCTLBit+c_wStepDrive_Dir;
		ELSE;(*默认方向*)
		END_IF
		(*2022.11.19.160459 从case-STEPDRIVE_PULSEOUT复制到此处 提前写入一个周期
		@发现手动有时候脉冲输出不对
		@发现手动有时候会步输出。测试复制到此处出现的概率小很多了*)
		(*写入启动频率 目标频率 加速度值*)
		xFreq_Sa_Wr:=TRUE;(*启动频率写入标志*)
		xFreq_Tar_Wr:=TRUE;(*目标频率写入标志*)
		xFreq_AccSaToTar_Wr:=TRUE;(*加速度值写入标志*)
		iState:=STEPDRIVE_PULSEOUT;(*进入脉冲输出逻辑*)
	STEPDRIVE_PULSEOUT:(*脉冲输出*)(*脉冲输出比电机方向配置晚一个周期*)
		(*写入启动频率 目标频率 加速度值*)
		xFreq_Sa_Wr:=TRUE;(*启动频率写入标志*)
		xFreq_Tar_Wr:=TRUE;(*目标频率写入标志*)
		xFreq_AccSaToTar_Wr:=TRUE;(*加速度值写入标志*)

		IF xCtlMod_Cur THEN (*位置模式*)
			wCTLBit:=c_wAIModule_Valid+c_wPosMode;
			(*写入脉冲数*)
			IF byOutSts=255 THEN(*未输出的时候才能写入*)
				IF wPulse_Pos_Wr<>0 THEN
					xFreq_Pulse_Pos_Wr:=TRUE;(*脉冲数写入标志*)
					wCTLBit:=wCTLBit+c_wPosMode_OutCtl;(*有效之后输出脉冲*)(*上升沿触发*)
					byOutSts:=1;(*置位输出中标志*)
					byWaitCnt:=0;
				END_IF
			ELSIF byOutSts=1 THEN(*输出中*)
				IF byWaitCnt>=i_byJudgeOutsts_WaitNum THEN(*超过计时@判断是否结束|认为超过这个时间肯定运动了*)
					IF NOT i_xPulseOutting_Rd THEN
						byOutSts:=255;
					END_IF
				ELSE(*等待*)
					byWaitCnt:=byWaitCnt+1;
					IF i_xPulseOutting_Rd THEN
						byOutSts:=2;
					END_IF
				END_IF
			ELSIF byOutSts=2 THEN(*实际也运行了*)
				IF NOT i_xPulseOutting_Rd THEN
					byOutSts:=255;
				END_IF
			END_IF
		ELSE(*速度模式*)(*该模式启动之后就不能更改参数，除非重新开始*)
			wCTLBit:=c_wAIModule_Valid;
			IF byOutSts=255 THEN(*未输出的时候才能写入*)
				IF i_xVelMod_Run THEN
					wCTLBit:=wCTLBit+c_wSpeedMode_OutCtl;(*有效之后输出脉冲*)
					byOutSts:=1;(*置位输出中标志*)
					byWaitCnt:=0;
				END_IF
			ELSE
				wCTLBit:=wCTLBit+c_wSpeedMode_OutCtl;
				IF byOutSts=1 THEN(*输出中*)
					IF byWaitCnt>=i_byJudgeOutsts_WaitNum THEN(*超过计时@判断是否结束|认为超过这个时间肯定运动了*)
						IF NOT i_xPulseOutting_Rd THEN
							IF NOT i_xVelMod_Run THEN(*退出运动了*)
								byOutSts:=255;
							ELSE(*还未执行运动则报错*)
								byOutSts:=3;
							END_IF
						ELSE(*实际运动了*)
							byOutSts:=2;
						END_IF
					ELSE(*等待*)
						byWaitCnt:=byWaitCnt+1;
						IF i_xPulseOutting_Rd THEN(*已经再运行了*)
							byOutSts:=2;
						END_IF
					END_IF
				ELSIF byOutSts=2 THEN(*实际确实再运行了*)
					IF NOT i_xVelMod_Run AND NOT i_xPulseOutting_Rd THEN(*退出运动了*)
						byOutSts:=255;
					END_IF
				ELSE(*byOutSts=3*)
					IF NOT i_xVelMod_Run THEN(*退出运动了*)
						byOutSts:=255;
					END_IF
				END_IF
			END_IF
		END_IF



		IF i_xDir THEN (*步进电机方向*)
			wCTLBit:=wCTLBit+c_wStepDrive_Dir;
		ELSE;(*默认方向*)
		END_IF
	STEPDRIVE_ALARM:;(*报警步*)
	ELSE;
	END_CASE

	(*计算本次实际走的脉冲数*)
	KS_GetPulse_Act(ADR(i_wPulse_Act_Rd),
				 	ADR(wLastPulse_Act_Rd),
					ADR(diPluse_Act));
ELSE(*不使能*)
	iState:=STEPDRIVE_IDLE;
	wPulse_Pos_Wr:=0;(*写入的脉冲为0*)
	IF i_xPulseOutting_Rd THEN
		byOutSts:=1;
	ELSE
		byOutSts:=0;
	END_IF
END_IF

(*输出*)
IF i_pwCtlBit_Wr<>0 THEN
	i_pwCtlBit_Wr^:=wCTLBit;
END_IF
IF i_piState<>0 THEN
	i_piState^:=iState;
END_IF
IF i_pwFre_Sa_Wr<>0 THEN
	IF xFreq_Sa_Wr THEN(*启动频率写入*)
		i_pwFre_Sa_Wr^:=wFre_Sa_Wr;
	ELSE
		i_pwFre_Sa_Wr^:=0;
	END_IF
END_IF
IF i_pwFreq_Tar_Wr<>0 THEN
	IF xFreq_Tar_Wr THEN(*目标频率写入*)
		i_pwFreq_Tar_Wr^:=wFreq_Tar_Wr;
	ELSE
		i_pwFreq_Tar_Wr^:=0;
	END_IF
END_IF
IF i_pwAccSaToTar_Wr<>0 THEN
	IF xFreq_AccSaToTar_Wr THEN(*加速度写入*)
		i_pwAccSaToTar_Wr^:=wAccSaToTar_Wr;
	ELSE
		i_pwAccSaToTar_Wr^:=0;
	END_IF
END_IF
IF i_pwPulse_Pos_Wr<>0 THEN
	IF xFreq_Pulse_Pos_Wr THEN(*脉冲写入*)
		i_pwPulse_Pos_Wr^:=wPulse_Pos_Wr;
		wPulse_Pos_Wr:=0;(*脉冲写入后就写0*)
	ELSE
		i_pwPulse_Pos_Wr^:=0;
	END_IF
END_IF

IF i_pdiPluse_Act<>0 THEN
	i_pdiPluse_Act^:=diPluse_Act;
END_IF
IF i_pwLastPulse_Act_Rd<>0 THEN
	i_pwLastPulse_Act_Rd^:=wLastPulse_Act_Rd;
END_IF
(*注意顺序i_pwPulse_Pos_Wr 写入之后*)
IF i_pwPulse<>0 THEN(*写入的脉冲数*)
	i_pwPulse^:=wPulse_Pos_Wr;
END_IF

IF i_pbyOutSts<>0 THEN
	i_pbyOutSts^:=byOutSts;
END_IF
IF i_pxCtlMod_Cur<>0 THEN
	i_pxCtlMod_Cur^:=xCtlMod_Cur;
END_IF
IF i_pbyWaitCnt<>0 THEN
	i_pbyWaitCnt^:=byWaitCnt;
END_IF