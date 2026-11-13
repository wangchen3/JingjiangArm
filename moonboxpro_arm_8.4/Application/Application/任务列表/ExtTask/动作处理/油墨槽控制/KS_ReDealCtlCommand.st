(*@CES
Name=KS_ReDealCtlCommand
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=29a1e171-811f-44f6-94ab-28798cfe2ff0
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ReDealCtlCommand : BOOL
(*重新处理控制命令@因为位置模式有最大值的限制,这里将位置模式的控制拆分为先速度模式在位置模式输出控制*)
VAR_INPUT
	i_pstStInkGrooveCtl:POINTER TO StInkGrooveCtl;(*输入的控制命令*)
	i_byPulseOutSts: BYTE;(*反馈的输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
	i_pbyPosModeSts:POINTER TO BYTE;(*位置模式的状态机
											|=1 位置模式
											|=2 速度模式+位置模式下的速度模式
											|=3 取消输出使能
											|=10切换为位置模式
											|=100等待结束
									*)

	i_pxPulseOutEn:POINTER TO BOOL;(*使能输出*)
	i_pxMoveDir:POINTER TO BOOL;(*运动方向*)
	i_pxPulseCtlMode:POINTER TO BOOL;(*控制模式|=false速度模式|=true 位置模式*)
	i_pxVelMod_Run:POINTER TO BOOL;(*速度控制模式下|速度使能标志*)
	i_prVelMod_Vel:POINTER TO REAL;(*速度控制模式下的速度*)
	i_pwPosMod_Pulse:POINTER TO WORD;(*位置控制模式下的脉冲数*)
	i_pxPosMod_InPos:POINTER TO BOOL;(*位置模式到位标志*)
END_VAR
VAR
	pstStInkGrooveCtl: POINTER TO StInkGrooveCtl;
	byPosModeSts: BYTE;(*位置模式的状态机	|=1 位置模式
											|=2 速度模式+位置模式下的速度模式
											|=3 取消输出使能
											|=10切换为位置模式
											|=100等待结束
								*)
	(*脉冲控制函数需要的输入处理@用于处理1色*)
	xPulseOutEn:BOOL;(*脉冲输出使能*)
	iPulseOutState:TypeEnumStepDriveStat;(*脉冲控制状态@状态机标志*)
(*	wLastPulse_Act_Rd_PulseOut: WORD;(*备份实际脉冲值*)*)
	byOutSts: BYTE;(*反馈的输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
(*	xCtlMod_Cur: BOOL;(*当前的控制模式*)*)
	xVelMod_Run: BOOL;(*速度模式.控制使能标志*)
	xCtlMode: BOOL;(*控制模式*)
	rSetVel: REAL;(*速度模式的速度*)
	wSetPulse:WORD;(*设置的脉冲*)
	xMoveDir: BOOL;(*运动的方向*)
	diDeltaPulse: DINT;
	xInPos: BOOL;(*位置到位*)
(*	wNeedMovePulse: WORD;(*需要运动的脉冲@不清除*)*)
END_VAR
{IMPLEMENTATION}
IF i_pbyPosModeSts<>0 THEN
	byPosModeSts:=i_pbyPosModeSts^;
END_IF
IF i_pwPosMod_Pulse<>0 THEN
	wSetPulse:=i_pwPosMod_Pulse^;
END_IF
(*对于速度模式和位置模式做一些处理*)
(*对使能和控制方式做了重新处理*)
pstStInkGrooveCtl:= i_pstStInkGrooveCtl;
byOutSts:=i_byPulseOutSts;
IF pstStInkGrooveCtl^.byMovingSts<>0  THEN(*可以运动了*)
	xMoveDir:=pstStInkGrooveCtl^.xMoveDir;
	rSetVel:=pstStInkGrooveCtl^.rVel;
	xVelMod_Run:=FALSE;
	IF pstStInkGrooveCtl^.xCtlMode THEN(*位置模式的时候|按照速度模式+位置模式实现*)
		CASE byPosModeSts OF
			0:
				(*判断留点余量*)
				IF ABS(pstStInkGrooveCtl^.diMoveDis_Pulse)<65000(*65535*) THEN(*未超限|直接使用位置模式模块位置模式最大65535脉冲*)
					byPosModeSts:=1;
				ELSE
					byPosModeSts:=2;
				END_IF
				wSetPulse:=0;(*设置的脉冲值先写0*)
			1:(*位置模式*)
				xPulseOutEn:=TRUE;
				xCtlMode:=TRUE;(*按照位置模式*)
				wSetPulse:=DINT_TO_WORD(pstStInkGrooveCtl^.diMoveDis_Pulse);
(*				wNeedMovePulse:=wSetPulse;*)
				byPosModeSts:=100;
			2:(*速度模式+位置模式下的速度模式*)
				xPulseOutEn:=TRUE;
				xCtlMode:=FALSE;
				xVelMod_Run:=TRUE;
				diDeltaPulse:=ABS(pstStInkGrooveCtl^.diMoveDis_Pulse)-ABS(pstStInkGrooveCtl^.diThisMovedPulse);
				IF (diDeltaPulse<65535 AND diDeltaPulse>0) THEN
					byPosModeSts:=3;(*先退出速度模式再进入位置模式*)
				ELSIF diDeltaPulse<0 THEN
					byPosModeSts:=110;(*直接结束吧*)
					xInPos:=TRUE;(*到位标志*)
				ELSE
					IF byOutSts=3 THEN(*速度模式运动异常*)
						byPosModeSts:=110;(*直接结束吧*)
						xInPos:=TRUE;(*到位标志*)
					END_IF
				END_IF
			3:(*退出速度模式*)
				xPulseOutEn:=FALSE;
				IF byOutSts=0 OR byOutSts=3 THEN(*停止运动了*)
					IF byOutSts=0 THEN
						byPosModeSts:=10;(*重新进入位置模式*)
					ELSE(*速度模式运动长时间没反应*)
						byPosModeSts:=110;
						xInPos:=TRUE;(*到位标志*)
					END_IF
				END_IF
			10:(*后半程进入位置模式\并未退出运动控制case@本次运动脉冲不会清除*)
				xPulseOutEn:=TRUE;
				xCtlMode:=TRUE;(*按照位置模式*)
				diDeltaPulse:=ABS(pstStInkGrooveCtl^.diMoveDis_Pulse)-ABS(pstStInkGrooveCtl^.diThisMovedPulse);
				IF diDeltaPulse>65535 THEN
					diDeltaPulse:=65535;
				ELSIF diDeltaPulse>0 THEN;
				ELSE
					diDeltaPulse:=0;
				END_IF
				wSetPulse:=DINT_TO_WORD(diDeltaPulse);
				byPosModeSts:=100;

			100:(*等待结束*)
				xPulseOutEn:=TRUE;
				xCtlMode:=TRUE;(*按照位置模式*)
				IF ABS(pstStInkGrooveCtl^.diThisMovedPulse) >= ABS(pstStInkGrooveCtl^.diMoveDis_Pulse) THEN(*本次运动的超过了需要运动的*)
					byPosModeSts:=110;
					xInPos:=TRUE;(*到位标志*)
				END_IF
			110:(*到位了*)
				xInPos:=TRUE;(*到位标志*)
		ELSE
			byPosModeSts:=0;
(*			wNeedMovePulse:=0;*)
			wSetPulse:=0;
		END_CASE
	ELSE(*速度模式*)
		wSetPulse:=0;(*设置的脉冲值先写0*)
		byPosModeSts:=0;
		xPulseOutEn:=TRUE;
		xCtlMode:=FALSE;
		(*速度模式,停止就减速停吧*)
		xVelMod_Run:=TRUE;
	END_IF
ELSE(*停止运动了*)
	byPosModeSts:=0;
	wSetPulse:=0;(*设置的脉冲值先写0*)
END_IF

IF i_pbyPosModeSts<>0 THEN
	i_pbyPosModeSts^:=byPosModeSts;
END_IF
IF i_pxPulseOutEn<>0 THEN
	i_pxPulseOutEn^:=xPulseOutEn;
END_IF
IF i_pxMoveDir<>0 THEN
	i_pxMoveDir^:=xMoveDir;
END_IF
IF i_pxPulseCtlMode<>0 THEN
	i_pxPulseCtlMode^:=xCtlMode;
END_IF
IF i_pxVelMod_Run<>0 THEN
	i_pxVelMod_Run^:=xVelMod_Run;
END_IF
IF i_prVelMod_Vel<>0 THEN
	i_prVelMod_Vel^:=rSetVel;
END_IF
IF i_pwPosMod_Pulse<>0 THEN
	i_pwPosMod_Pulse^:=wSetPulse;
END_IF
IF i_pxPosMod_InPos<>0 THEN
	i_pxPosMod_InPos^:=xInPos;
END_IF