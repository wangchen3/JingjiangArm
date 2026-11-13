(*@CES
Name=KS_FB_InkGrooveCtl
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=49f5b0cb-8423-4005-950e-682392de8c5e
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_InkGrooveCtl
(*油墨槽升降功能块@控制1色(使用模块控制输出)*)
(*1色为主站时使用该功能块控制模块输出@目前还没支持io输出*)
VAR_INPUT
	i_xEn							: BOOL;(*功能块使能*)
	i_xCanMove						: BOOL;(*可以运动标志@例如非急停*)
	(*脉冲控制参数@主要用于1色为主站时的控制*)
	i_xMoveDirRev					: BOOL;(*方向取反*)
	i_dwPulse_1r					: DWORD;(*一圈的脉冲数*)
	i_rDis_1Pulse 					: REAL; (*单位脉冲距离mm/p*)
	i_iVel_Sa						: INT;(*脉冲输出的启动速度|r/min*)
	i_iSetVel 						: INT;(*运动速度|r/min*)
	i_iAccTime_ms					: INT;(*脉冲加速时间@100*)(*ms*)
	i_iMaxMoveDis					: INT;(*最大运动距离@mm*)
(*
	(*反馈参数@模块方式控制*)
	i_wPulse_Act_Rd_1U 				: WORD ; (*1色控制的脉冲输出值*)
	i_xPulseOutting_Rd_1U			: BOOL; (*1色控制的运动中标志*)
*)
	(*轴信息*)
	i_iGrpAxisNum_Pu						: INT; (*色组轴数*)
	i_aiGrpAxisList							: ARRAY [1..MAX_STATION_NUM] OF INT; (*系的轴列表*)
	i_auiStationTypeID						: ARRAY [0..MAX_STATION_NUM] OF UINT;(*驱动器类型字|索引为站号*)
	i_pastStAxisParam						: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StAxisParam;
	i_pastStIOMap_AxisBasic					: POINTER TO ARRAY [1..MAX_STATION_NUM] OF StIOMap_AxisBasic;
	i_pstInkGrooveInf_1U_Module				: POINTER TO StDigitalMicroStepDrive;(*模块方式下获取信息和写入信息*)
END_VAR
VAR_OUTPUT
	o_xEn:BOOL;
	o_xUseControllerIO_1U: BOOL;(*1色使用控制器io@逻辑还未实现1色按照驱动器io输出|1色控制默认使用模块输出*)
	o_stStPulseModuleInf_Wr_1U: StPulseModuleInf_Wr;(*主要是1色按照模块方式输出*)
END_VAR
VAR
	in: INT;
	iAxisId:INT;
	xClrMsg: BOOL;(*提示信息清除*)
	pstStAxisParam:POINTER TO StAxisParam;
	pstStIOMap_AxisBasic:POINTER TO StIOMap_AxisBasic;
	(*共享内存里的数据@测试还未替换*)
	(*功能块中的变量*)
	pstStInkGrooveCtl:POINTER TO StInkGrooveCtl;(*油墨槽控制参数结构体*)
	xInPos: BOOL;(*位置到位*)

	(*1色使用模块方式控制的变量*)
	xPulseOutEn_1U:BOOL;(*脉冲输出使能*)
	xInPos_1U: BOOL;(*位置到位@本地控制的*)
	xVelMod_Run_1U: BOOL;(*速度模式.控制使能标志*)
	xCtlMode_1U: BOOL;(*控制模式*)
	rSetVel_1U: REAL;(*速度模式的速度*)
	xMoveDir_1U: BOOL;(*运动的方向*)
	byPosModeSts_1U: BYTE;(*位置模式的状态机	|=1 位置模式
											|=2 速度模式+位置模式下的速度模式
											|=3 取消输出使能
											|=10切换为位置模式
											|=100等待结束
								*)
	byPulseOutSts_1U: BYTE;(*输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
	wNeedMovePulse_1U: WORD;(*需要运动的脉冲@不清除*)
	wPrevNeedMovePulse_1U: WORD;
	wSetPulse_1U:WORD;(*设置的脉冲数@获取后会清除*)
	(*模块脉冲控制输出*)
	xCtlMod_Cur_1U: BOOL;(*当前的控制模式*)
	iPulseOutState_1U:TypeEnumStepDriveStat;(*脉冲控制状态@状态机标志*)
	diThisMovePulse_1U: DINT;(*本地控制本次运动的脉冲@1色*)
	wLastPulse_Act_Rd_PulseOut: WORD;(*备份实际脉冲值*)
	byWaitCnt: BYTE;(*计时计数值*)
	(*反馈参数@模块方式控制*)
	wPulse_Act_Rd_1U 				: WORD ; (*1色控制的脉冲输出值*)
	xPulseOutting_Rd_1U			: BOOL; (*1色控制的运动中标志*)

	(*上升*)
	xClick_InkGroove_Up : BOOL ;	(*上升单击事件*)
	xDoubleClick_InkGroove_Up : BOOL ;(*上升双击事件*)
	xHold_InkGroove_Up : BOOL ;(*上升长按事件*)
	awCnt_InkGroove_Up : ARRAY [1..16] OF WORD ;(*上升状态*)

	(*下降*)
	xClick_InkGroove_Dn : BOOL ;	(*下降单击事件*)
	xDoubleClick_InkGroove_Dn : BOOL ;(*下降双击事件*)
	xHold_InkGroove_Dn : BOOL ;(*下降长按事件*)
	awCnt_InkGroove_Dn : ARRAY [1..16] OF WORD ;(*下降状态*)
	wPulse_Act_Rd: WORD;
	xMoving_Act: BOOL;(*实际运动中标志*)
	iStationId: INT;(*站号*)
	xCtlEn: BOOL;(*2025.6.6.114812 控制使能标志*)
	xIsMaster_1U: BOOL;(*1色是主站*)
	xUseModule: BOOL;(*使用过模块标志@用来清理数据*)
	xVelMode_MoveFailed: BOOL;(*速度模式运动失败*)
END_VAR
{IMPLEMENTATION}
IF i_pstInkGrooveInf_1U_Module<>0 AND
	i_pastStIOMap_AxisBasic<>0 AND
	i_pastStAxisParam<>0 THEN;
ELSE
	RETURN;
END_IF
(*动作控制@所有轴(1--16)*)
(*模块控制的时候获取反馈数据*)
IF o_xUseControllerIO_1U AND FALSE THEN(*还未实现|先强制false*)
	;
ELSE
	wPulse_Act_Rd_1U:=i_pstInkGrooveInf_1U_Module^.wStepDrivePulse_Act_Rd;
	xPulseOutting_Rd_1U:=i_pstInkGrooveInf_1U_Module^.xStepDriveWorking;
END_IF

xIsMaster_1U:=FALSE;
FOR in:=1 TO i_iGrpAxisNum_Pu BY 1 DO
	iAxisId:=i_aiGrpAxisList[in];
	IF iAxisId>0 AND iAxisId<=16 THEN
		pstStAxisParam:=ADR(i_pastStAxisParam^[iAxisId]);
		pstStIOMap_AxisBasic:=ADR(i_pastStIOMap_AxisBasic^[iAxisId]);
		pstStInkGrooveCtl:= ADR(pstStAxisParam^.stStInkGrooveCtl);
		iStationId:=pstStAxisParam^.iStationId;

		(*检查驱动器是不是支持|确认使能标志*)
		xCtlEn:=i_xEn;(*初始化为使能输入*)
		IF iStationId>=0 AND iStationId<=MAX_STATION_NUM THEN
			IF iStationId<>0 THEN(*从站*)
				IF i_auiStationTypeID[iStationId] = CONTROLLER_GTSD16D_AIO OR(*新款16d-1*)
					i_auiStationTypeID[iStationId] = CONTROLLER_GTSD16D_AIO_ISO OR(*新款16d-2*)
					i_auiStationTypeID[iStationId] = CONTROLLER_GTSD16M_AIO THEN(*新款16m*)

					IF iAxisId=1 THEN(*1#轴@从站*)
						o_xUseControllerIO_1U:=TRUE;
					END_IF
				ELSE
					xCtlEn:=FALSE;
					IF iAxisId=1 THEN(*1#轴@从站*)
						o_xUseControllerIO_1U:=FALSE;
					END_IF
				END_IF
			ELSE(*主站@肯定是色组轴|else里的逻辑可有可无*)
				IF iAxisId=1 THEN(*1#轴*)
					xIsMaster_1U:=TRUE;
					IF i_auiStationTypeID[iStationId] = CONTROLLER_GTSD16M_AIO THEN(*新款16m*)
						o_xUseControllerIO_1U:=TRUE;
					ELSE
						o_xUseControllerIO_1U:=FALSE;
					END_IF
				ELSE(*非1#轴就不理*)
					xCtlEn:=FALSE;
					o_xUseControllerIO_1U:=FALSE;
				END_IF
			END_IF
		END_IF

		(*一些反馈标志处理,有本地信息也有通讯讯息*)
		IF xCtlEn THEN(*使能了*)
			(*将保持的值写入到油墨槽变量|下面逻辑会继续更新*)
			pstStInkGrooveCtl^.diPulse_Moved:=pstStAxisParam^.diPulseValue_16D;
			IF iAxisId=1 THEN
				IF xIsMaster_1U THEN(*1色是主站@反馈信息都从本地获取*)
					xMoving_Act:=byPulseOutSts_1U<>0;
					wPulse_Act_Rd:=wPulse_Act_Rd_1U;
					xVelMode_MoveFailed:=byPulseOutSts_1U=3;
					xInPos:=xInPos_1U;
				ELSE(*不是主站|通讯获取*)
					xMoving_Act:=pstStAxisParam^.xPulse_Outing_16D;(*因为是通讯获取的，能不能可靠拿到标志|要注意*)
					wPulse_Act_Rd:=pstStAxisParam^.wPulse_Rd_16D;
					xVelMode_MoveFailed:=pstStAxisParam^.byInkGroovePulseOutSts = 3;
					xInPos:=pstStAxisParam^.xInkGroove_InPos;
				END_IF
			ELSE(*其他色组通讯获取信息|*)
				xMoving_Act:=pstStAxisParam^.xPulse_Outing_16D;
				wPulse_Act_Rd:=pstStAxisParam^.wPulse_Rd_16D;
				xVelMode_MoveFailed:=pstStAxisParam^.byInkGroovePulseOutSts = 3;
				xInPos:=pstStAxisParam^.xInkGroove_InPos;
			END_IF
		ELSE(*不使能*)
			xMoving_Act:=FALSE;
			wPulse_Act_Rd:=0;
			xVelMode_MoveFailed:=FALSE;
			xInPos:=TRUE;
		END_IF

		(*io处理*)
		IF NOT xCtlEn OR NOT i_xCanMove THEN
			pstStIOMap_AxisBasic^.i_xBtnInkGroove_Up:=FALSE;
			pstStIOMap_AxisBasic^.i_xBtnInkGroove_Dn:=FALSE;
		END_IF

		KS_BtnClick(
			pstStIOMap_AxisBasic^.i_xBtnInkGroove_Up(*i_xBtn*),(*上升信号*)
			300(*i_wTime_ms*),
			INT_TO_BYTE(gc_iCycleTime_Plc)(*i_byCycleTime_ms*),
			ADR(xClick_InkGroove_Up)(*i_pxClick*),
			ADR(xDoubleClick_InkGroove_Up)(*i_pxDoubleClick*),
			ADR(xHold_InkGroove_Up)(*i_pxHold*),
			ADR(awCnt_InkGroove_Up[iAxisId])(*i_pwCnt*));

		KS_BtnClick(
			pstStIOMap_AxisBasic^.i_xBtnInkGroove_Dn(*i_xBtn*),(*上升信号*)
			300(*i_wTime_ms*),
			INT_TO_BYTE(gc_iCycleTime_Plc)(*i_byCycleTime_ms*),
			ADR(xClick_InkGroove_Dn)(*i_pxClick*),
			ADR(xDoubleClick_InkGroove_Dn)(*i_pxDoubleClick*),
			ADR(xHold_InkGroove_Dn)(*i_pxHold*),
			ADR(awCnt_InkGroove_Dn[iAxisId])(*i_pwCnt*));

		KS_InkGrooveCtl_1Axis(
			xCtlEn(*i_xEn*),
			i_xCanMove(*i_xCanMove*),
			xClrMsg(*i_xClrMsg*),
			i_rDis_1Pulse(*i_lrDis_1Pulse*),
			INT_TO_BYTE(gc_iCycleTime_Plc)(*i_iCycleTime_Plc*),
			pstStAxisParam^.lrGirth(*i_rGirth*),
			pstStAxisParam^.xInkGroove_BaseInfValid(*i_xBaseInfValid*),
			pstStAxisParam^.rInkGroove_Girth_Base(*i_rGirth_Base*),
			pstStAxisParam^.rInkGroove_Pos_Base(*i_rPos_Base*),
			i_xMoveDirRev(*i_xMoveDirRev*),
			xHold_InkGroove_Up(*i_xUp*),
			pstStIOMap_AxisBasic^.i_xInkGrooveUplimt(*i_xUplimt*),
			xHold_InkGroove_Dn(*i_xDn*),
			xDoubleClick_InkGroove_Dn(*i_xDn_Auto*),
			pstStIOMap_AxisBasic^.i_xInkGrooveDnlimt(*i_xDnlimt*),
			xClick_InkGroove_Up, (*i_xUpClick*)
			xClick_InkGroove_Dn,(*i_xDnClick *)
			xDoubleClick_InkGroove_Up (*i_xToTarPos_Auto*),
			pstStIOMap_AxisBasic^.i_xInkGrooveDnlimt(*i_xZeroSig*),
			INT_TO_REAL(i_iSetVel)(*i_rSetVel*),
			INT_TO_REAL(i_iMaxMoveDis)(*i_rMaxMoveDis*),
			wPulse_Act_Rd(*i_wPulse_Act_Rd*),(*反馈*)
			xInPos(*i_xInPos*),(*反馈*)
			xMoving_Act(*i_xMoving_Act*),(*反馈*)
			xVelMode_MoveFailed(*i_xVelMode_MoveFailed*),
			pstStInkGrooveCtl(*i_pstStInkGrooveCtl*));


		(*获取自动的基础信息@1-16色*)
		KS_GetInkGrooveBaseInf(
			pstStInkGrooveCtl^.xZeroValid(*i_xEn*),
			pstStAxisParam^.xGetInkGoove_BaseInf(*i_xGetBtn*),
			pstStAxisParam^.lrGirth(*i_rGirth*),
			pstStInkGrooveCtl^.rPos_Cur(*i_rPos_Cur*),
			ADR(pstStAxisParam^.xInkGroove_BaseInfValid)(*i_pxBaseInfValid*),
			ADR(pstStAxisParam^.rInkGroove_Girth_Base)(*i_prGirth_Base*),
			ADR(pstStAxisParam^.rInkGroove_Pos_Base)(*i_prPos_Base*));
		pstStAxisParam^.xGetInkGoove_BaseInf:=FALSE;(*按钮复位*)

		(*从站通讯内容写入@2025.6.11.192921*)
		IF xCtlEn THEN(*使能了|处理通讯写入*)
			IF pstStInkGrooveCtl^.xCtlMode THEN(*位置模式*)
				pstStAxisParam^.wPulseCtlInf_16D:=REAL_TO_WORD(ABS(pstStInkGrooveCtl^.rMoveDis*100));
			ELSE(*速度模式*)
				pstStAxisParam^.wPulseCtlInf_16D:=REAL_TO_WORD(ABS(pstStInkGrooveCtl^.rVel*10));
			END_IF
			pstStAxisParam^.wPulse_1r_16D:=DWORD_TO_WORD(i_dwPulse_1r);
			pstStAxisParam^.byPulseCtl_DisPerPulse_16D:=REAL_TO_BYTE(i_rDis_1Pulse*100000);(*单位0.01um*)
			pstStAxisParam^.byPulseCtlBit_16D:=0;
			pstStAxisParam^.byPulseCtlBit_16D.0:=xCtlEn;(*使能@从站io才可以按照脉冲输出*)
			pstStAxisParam^.byPulseCtlBit_16D.1:=pstStInkGrooveCtl^.bySts<>0;(*运动使能*)
			pstStAxisParam^.byPulseCtlBit_16D.2:=pstStInkGrooveCtl^.xMoveDir;(*运动方向*)
			pstStAxisParam^.byPulseCtlBit_16D.3:=pstStInkGrooveCtl^.xCtlMode;(*控制模式*)
			pstStAxisParam^.diPulseValue_16D:=pstStInkGrooveCtl^.diPulse_Moved;(*已经运动的距离写入到保持变量里*)
		ELSE(*不使能*)
			IF pstStAxisParam^.byPulseCtlBit_16D.0 THEN(*作为取消使能清零的条件|在使能时候该bit会被置位*)
				pstStAxisParam^.byPulseCtlBit_16D:=0;
				pstStAxisParam^.wPulseCtlInf_16D:=0;
				pstStAxisParam^.diPulseValue_16D:=0;
			END_IF
		END_IF

	ELSE(*控制不使能*)
		;
	END_IF
END_FOR

(*模块写入信息处理@1色*)
(*对于速度模式和位置模式做一些处理*)
(*对使能和控制方式做了重新处理*)
pstStAxisParam:=ADR(i_pastStAxisParam^[1]);
pstStInkGrooveCtl:= ADR(pstStAxisParam^.stStInkGrooveCtl);
KS_ReDealCtlCommand(
	pstStInkGrooveCtl(*i_pstStInkGrooveCtl*),
	byPulseOutSts_1U(*i_byPulseOutSts*),
	ADR(byPosModeSts_1U)(*i_pbyPosModeSts*),
	ADR(xPulseOutEn_1U)(*i_pxPulseOutEn*),
	ADR(xMoveDir_1U)(*i_pxMoveDir*),
	ADR(xCtlMode_1U)(*i_pxPulseCtlMode*),
	ADR(xVelMod_Run_1U)(*i_pxVelMod_Run*),
	ADR(rSetVel_1U)(*i_prVelMod_Vel*),
	ADR(wNeedMovePulse_1U)(*i_pwPosMod_Pulse*),
	ADR(xInPos_1U)(*i_pxPosMod_InPos*));
(*设置的脉冲数@变为非0,写入到控制模块脉冲输出的函数变量*)
IF wSetPulse_1U=0 AND
	wNeedMovePulse_1U<>0 THEN
	wSetPulse_1U:=wNeedMovePulse_1U;(*wSetPulse_1U 由KS_PulseOutCtl清零*)
END_IF


IF o_xUseControllerIO_1U AND FALSE THEN(*1色使用驱动器io@还未实现-强制无效*)


	IF xUseModule THEN
		xUseModule:=FALSE;
		SysMemSet(ADR(o_stStPulseModuleInf_Wr_1U),0,SIZEOF(o_stStPulseModuleInf_Wr_1U));
		SysMemSet(ADR(i_pstInkGrooveInf_1U_Module^),0,SIZEOF(i_pstInkGrooveInf_1U_Module^));
		wLastPulse_Act_Rd_PulseOut:=wPulse_Act_Rd_1U;
		iPulseOutState_1U:=STEPDRIVE_IDLE;
		wSetPulse_1U:=0;
		diThisMovePulse_1U:=0;
		byPulseOutSts_1U:=0;
		byWaitCnt:=0;
	END_IF
ELSE(*1色使用模块*)
	(*模块控制脉冲*)
	KS_PulseOutCtl(
		xPulseOutEn_1U(*i_xEn*),
		FALSE(*i_xClrPulse_Act_Rd*),
		10(*i_byJudgeOutsts_WaitNum*),
		i_dwPulse_1r(*i_dwPulse_1r*),
		xCtlMode_1U(*i_xCtlMode*),
		xVelMod_Run_1U(*i_xVelMod_Run*),
		xMoveDir_1U(*i_xDir*),
		INT_TO_REAL(i_iVel_Sa)(*i_rVel_Sa*),
		rSetVel_1U(*i_rVel*),
		i_iAccTime_ms(*i_iAccTime_ms*),
		ADR(wSetPulse_1U)(*i_pwPulse*),
		xPulseOutting_Rd_1U(*i_xPulseOutting_Rd*),
		wPulse_Act_Rd_1U(*i_wPulse_Act_Rd*),
		ADR(iPulseOutState_1U)(*i_piState*),
		ADR(o_stStPulseModuleInf_Wr_1U.wCTL)(*i_pwCtlBit_Wr*),
		ADR(o_stStPulseModuleInf_Wr_1U.wPulseFre_Sa_Wr)(*i_pwFre_Sa_Wr*),
		ADR(o_stStPulseModuleInf_Wr_1U.wPulseFre_Tar_Wr)(*i_pwFreq_Tar_Wr*),
		ADR(o_stStPulseModuleInf_Wr_1U.wAcc_SaToTar_Wr)(*i_pwAccSaToTar_Wr*),
		ADR(o_stStPulseModuleInf_Wr_1U.wPulse_Wr)(*i_pwPulse_Pos_Wr*),
		ADR(diThisMovePulse_1U)(*i_pdiPluse_Act*),
		ADR(wLastPulse_Act_Rd_PulseOut)(*i_pwLastPulse_Act_Rd*),
		ADR(byPulseOutSts_1U)(*i_pbyOutSts*),
		ADR(xCtlMod_Cur_1U)(*i_pxCtlMod_Cur*),
		ADR(byWaitCnt)(*i_pbyWaitCnt*));

	(*写入到原来做的模块输出的结构体中去，代码好实现一些*)
	i_pstInkGrooveInf_1U_Module^.wStepDriveCTL:=o_stStPulseModuleInf_Wr_1U.wCTL;
	i_pstInkGrooveInf_1U_Module^.wStepDrivePulseFre_Sa_Wr:=o_stStPulseModuleInf_Wr_1U.wPulseFre_Sa_Wr;
	i_pstInkGrooveInf_1U_Module^.wStepDrivePulseFre_Tar_Wr:=o_stStPulseModuleInf_Wr_1U.wPulseFre_Tar_Wr;
	i_pstInkGrooveInf_1U_Module^.wStepDriveAcc_SaToTar_Wr:=o_stStPulseModuleInf_Wr_1U.wAcc_SaToTar_Wr;
	i_pstInkGrooveInf_1U_Module^.wStepDrivePulse_Wr:=o_stStPulseModuleInf_Wr_1U.wPulse_Wr;
	xUseModule:=TRUE;
END_IF