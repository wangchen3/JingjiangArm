(*@CES
Name=KS_InkGrooveCtl_1Axis
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=2dac3483-8274-459a-981e-f455ba92ec89
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InkGrooveCtl_1Axis : BOOL
(*油墨槽控制函数@单轴*)
(*根据按钮控制输出*)
(*走定位是按照速度模式+位置模式输出处理@因为位置模式目前架构只支持最多65535脉冲*)
(*我们定义正值是向上运动的|默认方式是向上运动的,可以通过i_xMoveDirRev输入切换方向*)
VAR_INPUT
	i_xEn:BOOL;(*控制使能*)
	i_xCanMove:BOOL;(*可以运动标志@例如非急停*)
	i_xClrMsg:BOOL;(*清除msg*)
	i_lrDis_1Pulse:REAL;(*单位脉冲对应的距离@mm/pulse*)
	i_iCycleTime_Plc:INT:=20;(*程序周期时间@ms*)
	i_rGirth:REAL;(*当前版周长@mm*)
	i_xBaseInfValid:BOOL;(*基准信息是有效的*)
	i_rGirth_Base:REAL;(*基准周长(mm)@以该周长作为基准,计算其他周长的变化量*)
	i_rPos_Base:REAL;(*基准位置(mm)@基准周长对应的位置*)
	i_xMoveDirRev:BOOL;(*运动方向取反*)
	i_xUp:BOOL;(*上升@长有效*)
	i_xUplimt:BOOL;(*上限位@硬件*)
	i_xDn:BOOL;(*下降@长有效*)
	i_xDn_Auto:BOOL;(*自动下降@沿触发(下降到i_xZeroSig位置)*)
	i_xDnlimt:BOOL;(*下限位@硬件|作为0点*)
	i_xUpClick : BOOL ;(*上升单击停止事件*)
	i_xDnClick : BOOL ;(*下降单击停止事件*)
	i_xToTarPos_Auto:BOOL;(*一键到位@沿触发*)
	i_xZeroSig:BOOL;(*零点信号(外部沿触发)@目前配置为下限位*)
	i_rSetVel:REAL;(*设置的运动速度@r/min*)
(*	i_diThisMovePulse:DINT;(*本次运动的脉冲@外部输入,就不在里面运算了*)*)
	i_rMaxMoveDis:REAL;(*最大运动距离@mm*)
	(*反馈*)
	i_wPulse_Act_Rd:WORD;(*读取的脉冲输出个数@用于计算当前位置*)
	i_xInPos:BOOL;(*到位标志@位置模式下反馈的标志*)
	i_xMoving_Act:BOOL;(*实际处于运动状态@再运动的时候就不能响应io*)
	i_xVelMode_MoveFailed:BOOL;(*速度模式下|运动失败了*)
	i_pstStInkGrooveCtl:POINTER TO StInkGrooveCtl;
(*
	(*输出@提供给脉冲输出函数处理*)
	i_pbySts:POINTER TO BYTE;(*状态@就不用枚举了|0 空闲
												|1 监控按钮*)
	i_pbyMovingSts:POINTER TO BYTE;(*运动状态|=0 不运动|=1 上升|=2 下降*)
	i_pxCtlMode:POINTER TO BOOL;(*控制模式|=false速度模式|=true 位置模式*)
	i_pxMoveDir:POINTER TO BOOL;(*运动的方向*)
	i_prVel:POINTER TO REAL;(*速度值@r/min*)
	i_prMoveDis:POINTER TO REAL;(*需要运动的距离@mm*)
	i_pwLastPulse_Act_Rd:POINTER TO WORD;(*实际读取的脉冲数记录@上一拍*)
	i_pxZeroValid:POINTER TO BOOL;(*零位有效*)
	i_pdiPulse_Moved:POINTER TO DINT;(*已经移动的脉冲|在原点处会更新为0*)
	i_prPos_Cur:POINTER TO REAL;(*当前位置@mm|经过下限位零点后才有值*)
	i_pbyMsg:POINTER TO BYTE;(*信息|=1 零点丢失
								   |=2 未确认基准
								   |=3 距离超限*)
*)
END_VAR
VAR
	lrPulse2Dis: LREAL;(*脉冲转换为距离系数@mm/pul*)
	bySts: BYTE;(*状态@就不用枚举了*)
	byMovingSts:BYTE;(*运动状态|=0 不运动|=1 上升|=2 下降*)
	xCtlMode:BOOL;(*控制模式|=FALSE速度模式|=TRUE 位置模式*)
	xMoveDir:BOOL;(*运动的方向*)
	rVel:REAL;(*速度值@r/min*)
	wPulseNum:WORD;(*位置模式脉冲个数@目前的逻辑只支持word输出*)
	rMoveDis:REAL;(*需要运动的距离@mm*)
	diMoveDis_Pulse: DINT;(*需要运动的距离@PULSE*)
	wLastPulse_Act_Rd:WORD;(*实际读取的脉冲数记录@上一拍*)
	diPulse_Moved:DINT;(*本次运动已经移动的脉冲|重新启动运动会更新*)
	rPos_Cur:REAL;(*当前位置@mm|经过下限位零点*)
	xZeroValid: BOOL;(*零位有效*)
	rSetVel:REAL;(*设置的运动速度@r/min*)
	rSetPos: REAL;(*设置的位置值mm*)
	xUpLimt_Use: BOOL;(*应用的上限位标志*)
	xDnLimt_Use: BOOL;(*应用的下限位标志*)
	diPluse_Act: DINT;(*相对零位走的脉冲数*)
(*	byMsg: BYTE;(*信息*)*)
	iMsg: TypeEnumInkGrooveMsg;(*信息*)
	diThisMovedPulse: DINT;(*本次运动的距离@脉冲*)
	wLastPulse_Act_Rd_1: WORD;(*用于计算本次运动距离*)
	rThisMovedDis: REAL;(*本次运动的距离@mm*)
	rPI:REAL:=3.1415926;
END_VAR
{IMPLEMENTATION}
IF i_pstStInkGrooveCtl<>0 THEN;
ELSE
	RETURN;
END_IF
IF i_xEn THEN

	bySts:=i_pstStInkGrooveCtl^.bySts;
	byMovingSts:=i_pstStInkGrooveCtl^.byMovingSts;
	rMoveDis:=i_pstStInkGrooveCtl^.rMoveDis;
	wLastPulse_Act_Rd:=i_pstStInkGrooveCtl^.wLastPulse_Act_Rd;
	diPulse_Moved:=i_pstStInkGrooveCtl^.diPulse_Moved;
	rPos_Cur:=i_pstStInkGrooveCtl^.rPos_Cur;
	xZeroValid:=i_pstStInkGrooveCtl^.xZeroValid;
	iMsg:=i_pstStInkGrooveCtl^.iMsg;

	diThisMovedPulse:=i_pstStInkGrooveCtl^.diThisMovedPulse;
	wLastPulse_Act_Rd_1:=i_pstStInkGrooveCtl^.wLastPulse_Act_Rd_1;


	(*脉冲转换为距离@mm*)
	IF i_lrDis_1Pulse<>0 THEN
		lrPulse2Dis:=i_lrDis_1Pulse;(*单个脉冲的距离@mm/pul*)
	ELSE
		lrPulse2Dis:=0.0002;
	END_IF

	(*计算本次走的脉冲数*)
	KS_GetPulse_ActEx(i_xMoveDirRev,
					ADR(i_wPulse_Act_Rd),
				 	ADR(wLastPulse_Act_Rd_1),
					ADR(diThisMovedPulse));
(*	diThisMovedPulse:=i_diThisMovePulse;*)
	rThisMovedDis:=diThisMovedPulse*lrPulse2Dis;

	(*距离计算*)
	(*计算实际走的脉冲数*)
	(*输出方向取反的时候 累计函数也要取反@2025.6.14.134430+*)
	KS_GetPulse_ActEx(i_xMoveDirRev,
					ADR(i_wPulse_Act_Rd),
				 	ADR(wLastPulse_Act_Rd),
					ADR(diPulse_Moved));


	(*零点信号检查*)
	IF i_xZeroSig THEN(*0点信号触发了*)
		xZeroValid:=TRUE;(*触发以后就不清除*)
		diPulse_Moved:=0;
		wLastPulse_Act_Rd:=i_wPulse_Act_Rd;
	END_IF

	IF xZeroValid THEN(*零位有效了@根据当前统计的脉冲数计算*)
		rPos_Cur:=diPulse_Moved*lrPulse2Dis;(*当前位置@mm*)
	ELSE(*没有零位的时候当前位置=0*)
		rPos_Cur:=0;
	END_IF



	(*动作实现*)
	rSetVel:=i_rSetVel;
	xUpLimt_Use:=i_xUplimt;
	xDnLimt_Use:=i_xDnlimt;

	IF NOT i_xCanMove THEN
		bySts:=0;(*空闲态*)
	ELSE(*可以运动的时候监控按钮*)
		IF bySts=0 THEN(*空闲时候检查*)
			IF i_xMoving_Act THEN(*处于运动中|不允许处理io信号*)
				i_xUp:=FALSE;
				i_xDn:=FALSE;
				i_xToTarPos_Auto:=FALSE;
				i_xDn_Auto:=FALSE;
			END_IF

			IF i_xUp THEN(*上升*)
				iMsg:=MSG_NONE;
				IF NOT xUpLimt_Use THEN(*未到限位*)
					bySts:=1;
				ELSE
					iMsg:=MSG_UPLIMIT;
				END_IF
			ELSIF i_xDn THEN(*下降*)
				iMsg:=MSG_NONE;
				IF NOT xDnLimt_Use THEN(*未到限位*)
					bySts:=2;
				ELSE
					iMsg:=MSG_DNLIMIT;
				END_IF
			ELSIF i_xToTarPos_Auto THEN(*一键自动到位*)
				iMsg:=MSG_NONE;
				IF xZeroValid THEN(*有0位才可以执行*)
					IF i_xBaseInfValid THEN
						rSetPos:=i_rGirth/2/rPI-i_rGirth_Base/2/rPI;(*和基准变化的位置-半径差@mm*)
						rSetPos:=-rSetPos;(*正值,需要油墨槽向下运动@处理方向*)
						rSetPos:=i_rPos_Base+rSetPos-rPos_Cur;(*计算相对当前位置的增量*)
						IF rSetPos>0 THEN(*正值@向上运动*)
							IF NOT xUpLimt_Use THEN(*未到限位*)
								bySts:=10;
							ELSE
								iMsg:=MSG_UPLIMIT;
							END_IF
						ELSIF rSetPos<0 THEN(*负值@向下运动*)
							IF NOT xDnLimt_Use THEN(*未到限位*)
								bySts:=10;
							ELSE
								iMsg:=MSG_DNLIMIT;
							END_IF
						END_IF
					ELSE(*未确认基准*)
						iMsg:=MSG_BASEINFINVALID;
					END_IF
				ELSE(*没有零位*)
					iMsg:=MSG_ZEROINVALID;
				END_IF
			ELSIF i_xDn_Auto THEN(*自动下降*)
				iMsg:=MSG_NONE;
				diThisMovedPulse:=0;(*本次运动的距离清零*)
				IF NOT xDnLimt_Use THEN(*未到限位*)
					bySts:=20;
				ELSE
					iMsg:=MSG_DNLIMIT;
				END_IF
			END_IF
		END_IF
	END_IF
	(*信息清理*)
	IF iMsg<>MSG_NONE THEN
		IF i_xClrMsg THEN
			iMsg:=MSG_NONE;
		END_IF
	END_IF

	rVel:=rSetVel;(*设置的速度值*)
	CASE bySts OF
		0:;(*空闲时候@啥都不干*)
			byMovingSts:=0;
			rMoveDis:=0;
		1,2:(*手动上升\下降*)
			xCtlMode:=FALSE;(*速度模式*)
			rMoveDis:=0;(*设置的位置值*)
			IF bySts=1 THEN
				IF NOT i_xUp THEN(*取消上升*)
					bySts:=0;
				END_IF
				byMovingSts:=1;(*上升*)
			ELSE
				IF NOT i_xDn THEN(*取消上升*)
					bySts:=0;
				END_IF
				byMovingSts:=2;(*下降*)
			END_IF

			diThisMovedPulse:=0;(*本次运动的距离清零*)
		10:(*一键到位@速度模式+位置模式|将速度参数和位置参数都下发下去*)
			xCtlMode:=TRUE;(*按照位置模式输出*)
			rMoveDis:=rSetPos;(*设置的位置值*)
			IF rMoveDis>0 THEN
				byMovingSts:=1;(*上升*)
			ELSE
				byMovingSts:=2;(*下降*)
			END_IF
			bySts:=11;
			diThisMovedPulse:=0;(*本次运动的距离清零*)
		11:(*等待运动完成*)
			xCtlMode:=TRUE;(*按照位置模式输出*)
			(*rMoveDis@保持case10中的值*)
			IF i_xInPos OR (*到位标志|退出case*)
				i_xUp OR i_xDn  OR i_xUpClick  THEN(*上升或者下降按钮被按下则取消运动*)
				bySts:=0;
			END_IF
			(*运动的距离超限了,就停止吧*)
			IF ABS(rThisMovedDis)>ABS(i_rMaxMoveDis) THEN
				bySts:=0;
			END_IF

		20:(*自动下降到下限位@按照速度模式一直向下运动直到触发限位或者运动了最大距离*)
			xCtlMode:=FALSE;(*按照速度模式输出*)
			rMoveDis:=0;(*设置的位置值*)
			byMovingSts:=2;(*下降*)
			IF xDnLimt_Use OR(*到达下限位了*)
				i_xUp OR i_xDn OR i_xDnClick THEN(*上升或者下降按钮被按下则取消运动*)
				bySts:=0;
			END_IF
			(*运动的距离超限了,就停止吧*)
			IF ABS(rThisMovedDis)>ABS(i_rMaxMoveDis) THEN
				bySts:=0;
			END_IF
	ELSE
		bySts:=0;
		byMovingSts:=0;
		rMoveDis:=0;
	END_CASE
	IF bySts = 0 THEN(*退出状态时候|复位运动状态@使用case清除会滞后一个周期*)
		byMovingSts:= 0;
	END_IF

	diMoveDis_Pulse:=LREAL_TO_DINT(rMoveDis/lrPulse2Dis);(*将位置转换为脉冲*)
	(*方向处理*)
	IF byMovingSts=1 THEN(*上升*)
		xMoveDir:=FALSE;
	ELSIF byMovingSts =2 THEN(*下降*)
		xMoveDir:=TRUE;
	ELSE;(*保持之前的*)
	END_IF
	(*方向取反控制*)
	IF i_xMoveDirRev THEN
		xMoveDir:=NOT xMoveDir;
	END_IF

	(*使能时限位处理@一直检查*)
	IF byMovingSts<>0 THEN
		IF byMovingSts=1 THEN(*上升检查一下上限位*)
			IF xUpLimt_Use THEN
				iMsg:=MSG_UPLIMIT;(*到限位信息提示*)
				byMovingSts:=0;
			ELSE
				iMsg:=MSG_UPING;(*输出上升中*)
			END_IF
		END_IF
		IF byMovingSts=2 THEN(*下降检查一下下限位*)
			IF xDnLimt_Use THEN
				iMsg:=MSG_DNLIMIT;(*到限位信息提示*)
				byMovingSts:=0;
			ELSE
				iMsg:=MSG_DNING;(*输出下降中*)
			END_IF
		END_IF

		(*2025.6.10.151223+*)
		IF i_xVelMode_MoveFailed THEN
			iMsg:=MSG_MOVEFAILED;
		END_IF
	ELSE;(*功能的特性,会将设置值全部清0*)
		(*如果处于运动中退出,就将信息清除*)
		IF iMsg=MSG_UPING OR iMsg=MSG_DNING THEN
			iMsg:=MSG_NONE;
		END_IF
	END_IF
ELSE
	wLastPulse_Act_Rd:=i_wPulse_Act_Rd;
	wLastPulse_Act_Rd_1:=i_wPulse_Act_Rd;
END_IF


(*指针处理*)
i_pstStInkGrooveCtl^.bySts:=bySts;
i_pstStInkGrooveCtl^.byMovingSts:=byMovingSts;
i_pstStInkGrooveCtl^.xCtlMode:=xCtlMode;
i_pstStInkGrooveCtl^.xMoveDir:=xMoveDir;
i_pstStInkGrooveCtl^.rVel:=rVel;
i_pstStInkGrooveCtl^.rMoveDis:=rMoveDis;
i_pstStInkGrooveCtl^.diMoveDis_Pulse:=ABS(diMoveDis_Pulse);(*只保留正值@方向由标志控制*)
i_pstStInkGrooveCtl^.wLastPulse_Act_Rd:=wLastPulse_Act_Rd;
i_pstStInkGrooveCtl^.diPulse_Moved:=diPulse_Moved;
i_pstStInkGrooveCtl^.rPos_Cur:=rPos_Cur;
i_pstStInkGrooveCtl^.xZeroValid:=xZeroValid;
i_pstStInkGrooveCtl^.iMsg:=iMsg;
i_pstStInkGrooveCtl^.diThisMovedPulse:=diThisMovedPulse;
i_pstStInkGrooveCtl^.wLastPulse_Act_Rd_1:=wLastPulse_Act_Rd_1;
i_pstStInkGrooveCtl^.rThisMovedDis:=rThisMovedDis;