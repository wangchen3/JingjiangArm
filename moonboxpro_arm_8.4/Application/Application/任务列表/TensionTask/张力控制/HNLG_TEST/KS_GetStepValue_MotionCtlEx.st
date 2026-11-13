(*@CES
Name=KS_GetStepValue_MotionCtlEx
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=c817077e-660c-4b01-b00d-05c15fb07d43
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetStepValue_MotionCtlEx : BOOL (*2026.5.8.090124*)
(*运动的阶跃值*)
(*输出的总时间单位修改为s,原来为ms@2024.12.6.155413
阶跃按钮改为,开始和停止*)
(*扩展为支持方波输出和伪随机输出*)
VAR_INPUT
	i_xEn:BOOL;
	(*测试代码未做保护,测试过程中不能切换输出方式*)
	i_byOutType:BYTE;(*输出类型@=0 阶跃一定时间|=1 方波输出|=2 伪随机输出@i_xStepBtn有效则接收伪随机量*)
	(*2026.1.9.164121 扩展为所有方式的按钮|函数内部清除*)
	i_pxStepBtn:POINTER TO BOOL;(*阶跃按钮@外部沿复位|沿点击作为开始和结束@扩展为方波输出或者伪随机输出的按钮*)
	i_rStepVel:REAL;(*阶跃速度@m/min*)
	i_uiAccDecTime:UINT:=0;(*加减速时间，简单点使用一个@ms*)
	i_uiTotalTime:UINT:=1;(*输出的总时间@s|默认1s*)
	i_rGirth:REAL;(*版辊周长@mm*)
	i_byNum:BYTE:=1;(*分子@电机侧*)
	i_byDen:BYTE:=1;(*分母@版辊侧*)
	i_dwMotorPPR:DWORD:=2097152;(*电机一圈的脉冲数*)
	i_byCycleTime_Motion:BYTE:=21;(*规划的时间增量@ms*)
	i_iCycleTime_Plc:INT:=20;
	i_pxStepping:POINTER TO BOOL;(*阶跃中*)
	i_prStepVel_Cur:POINTER TO REAL;(*阶跃的速度值*)
	i_prStepPos:POINTER TO REAL;(*阶跃的位置值@单位mm@用pt模式*)
	i_puiPrfTimeCnt:POINTER TO UINT;(*规划时间计数@最多累计20min*)
	(*新增控制方式|控制按钮为i_xStepBtn*)
	i_rVel_Cur:REAL;(*当前速度值*)
	i_xAccing:BOOL;(*加速中标志*)
	i_xDecing:BOOL;(*减速中标志*)
	i_iTestVelSa:INT;(*测试的启动速度@*)
	i_uiSquareNum:UINT;(*方波个数*)
	i_uiSquareCycle:UINT;(*方波周期@ms|不做占空比了,就按照50%占空比*)
(*	i_byDutyCycle:BYTE:=50;(*占空比@单位%-不能>=100*)*)
	i_piSquareCycleCnt:POINTER TO INT;(*计数器*)
	i_piSquareNum_Act:POINTER TO INT;(*实际方波个数*)
	i_prTarVel_Act:POINTER TO REAL;(*实际的目标速度*)
	(*伪随机输出|*)
	i_rPseudoRandomRoundAmplitude_Cur	:REAL;(*伪随机值@控制按钮为i_xStepBtn*)
	i_pxStartPseudoRandom:POINTER TO BOOL;(*启动伪随机*)
	i_xFlag_PTfifofull:BOOL;(*pt空间满标志@只针对伺服电机伪随机*)
	//2026.5.8.183821+
	i_pxSetTrapParam:POINTER TO BOOL;
END_VAR
VAR
	rPos2Pulse_Coeff: REAL;(*位置转脉冲系数pulse/mm*)
	rAccTime: REAL;(*加速时间@ms*)
	rDecTime: REAL;(*减速时间@ms*)
	xNeedSmooth: BOOL;(*需要平滑标志*)
	xNeedEvening: BOOL;(*有匀速段*)
	xAccing: BOOL;(*加速中*)
	xDecing: BOOL;(*减速中*)
	xEvening: BOOL;(*匀速中*)
	lrTmp: LREAL;
	xStepping: BOOL;(*阶跃中标志*)
	rStepVel_Cur: REAL;(*阶跃的速度*)
	rStepPos: REAL;(*阶跃位置*)
	rDelVel_Acc: REAL:=1;(*速度变化量*)
	rDelVel_Dec: REAL:=1;(*速度变化量*)
(*	fbTon:TON;(*计时器*)*)
	uiPrfTimeCnt:UINT;(*规划时间计数*)
	rStepVel_Tar: REAL;(*目标的速度*)
	lrTotalTime_ms: LREAL;(*运动的总时间@ms*)
	xStepBtn: BOOL;
	iCycleCnt: INT;
	rTarVel_Act:REAL;(*实际的目标速度*)
	iSquareCycleCnt: INT;
	iSquareNum_Act:INT;(*实际方波个数*)
	//2026.5.8.183900+
	xSetTrapParam:BOOL;
END_VAR
{IMPLEMENTATION}
(*参数处理*)
IF i_byNum=0 THEN i_byNum:=1;END_IF
IF i_byDen=0 THEN i_byDen:=1;END_IF
IF i_dwMotorPPR=0 THEN i_dwMotorPPR:=2097152;END_IF
IF i_rGirth=0 THEN i_rGirth:=500;END_IF

lrTotalTime_ms:=UINT_TO_LREAL(i_uiTotalTime)*1000;
IF lrTotalTime_ms=0 THEN
	lrTotalTime_ms:=1000;
END_IF
IF i_xEn THEN
	IF i_pxStepBtn<>0 THEN
		xStepBtn:=i_pxStepBtn^;
	END_IF
	IF i_pxStepping<>0 THEN
		xStepping:=i_pxStepping^;
	END_IF
	IF i_prStepVel_Cur<>0 THEN
		rStepVel_Cur:=ABS(i_prStepVel_Cur^);
	END_IF
	IF i_prStepPos<>0 THEN
		rStepPos:=i_prStepPos^;
	END_IF
	IF i_prTarVel_Act<>0 THEN
		rTarVel_Act:=i_prTarVel_Act^;
	END_IF
(*
	IF i_pfbTon<>0 THEN
		fbTon:=i_pfbTon^;
	END_IF
*)
	IF i_puiPrfTimeCnt<>0 THEN
		uiPrfTimeCnt:=i_puiPrfTimeCnt^;
	END_IF
	IF i_piSquareCycleCnt<>0 THEN
		iSquareCycleCnt:=i_piSquareCycleCnt^;
	END_IF
	IF i_piSquareNum_Act<>0 THEN
		iSquareNum_Act:=i_piSquareNum_Act^;
	END_IF

	(*计算位置和脉冲的转换系数*)
	lrTmp:=BYTE_TO_LREAL(i_byNum) / i_byDen;(*版辊转一圈，电机转动的圈速*)
	lrTmp:=lrTmp*i_dwMotorPPR;(*总共的脉冲数*)
	lrTmp:=lrTmp/i_rGirth;(*计算出系数|pulse/mm*)
	rPos2Pulse_Coeff:=lrTmp;
	(*计算加减速相关*)
	IF i_uiAccDecTime<>0 THEN(*需要平滑*)
		xNeedSmooth:=TRUE;
		IF i_uiAccDecTime*2+i_byCycleTime_Motion<lrTotalTime_ms THEN
			rAccTime:=i_uiAccDecTime;
			rDecTime:=i_uiAccDecTime;
			xNeedEvening:=TRUE;
		ELSE
			rAccTime:=(lrTotalTime_ms)/2;
			rDecTime:=(lrTotalTime_ms)/2;
			xNeedEvening:=FALSE;
		END_IF
	ELSE(*不要平滑*)
		xNeedSmooth:=FALSE;
		xNeedEvening:=FALSE;
	END_IF

	CASE i_byOutType OF
		1,(*方波输出*)
		2:(*伪随机输出*)
			IF xStepBtn THEN(*常有效*)
				IF NOT xStepping THEN(*启动后不再执行*)
					(*变量初始化*)
					rStepVel_Cur:=0;
					rStepPos:=0;
					uiPrfTimeCnt:=0;
					iSquareCycleCnt:=0;
					xSetTrapParam:=TRUE;//触发参数写入@2026.5.8.184135+
					IF i_xAccing THEN
						IF i_rVel_Cur >= i_iTestVelSa THEN(*到达速度测试点了*)
							xStepping:=TRUE;(*接收伪随机速度指令*)
						END_IF
					ELSIF i_xDecing THEN
						IF i_rVel_Cur <= i_iTestVelSa THEN(*到达速度测试点了*)
							xStepping:=TRUE;(*接收伪随机速度指令*)
						END_IF
					ELSE(*匀速中*)
						xStepping:=TRUE;(*接收伪随机速度指令*)
					END_IF

					(*需要运动了*)
					IF xStepping THEN
						IF i_byOutType=2 THEN(*伪随机输出标志处理*)
							i_pxStartPseudoRandom^:=TRUE;
						ELSE(*方波初值*)
							rTarVel_Act:=i_rStepVel;
						END_IF
					END_IF
				END_IF
			ELSE
				xStepping:=FALSE;(*取消接收伪随机\方波速度指令*)
			END_IF

			(*需要运动了*)
			IF xStepping THEN
				IF i_byOutType=1 THEN(*方波输出*)
					iCycleCnt:=i_uiSquareCycle / i_iCycleTime_Plc / 2;
					IF NOT i_xFlag_PTfifofull THEN
						iSquareCycleCnt:=iSquareCycleCnt+1;
					END_IF
					IF iSquareCycleCnt>iCycleCnt THEN(*时间到了*)
						xSetTrapParam:=TRUE;//触发参数写入@2026.5.8.184135+
						iSquareCycleCnt:=1;
						IF rTarVel_Act=i_rStepVel THEN(*当前速度不等于0.切换为输出0*)
							rTarVel_Act:=-i_rStepVel;
						ELSE(*从这里开始启动*)
							rTarVel_Act:=i_rStepVel;

							iSquareNum_Act:=iSquareNum_Act+1;
							IF iSquareNum_Act>=i_uiSquareNum THEN(*足够就结束了*)
								iSquareNum_Act:=0;
								rTarVel_Act:=0;
								xStepBtn:=FALSE;(*复位按钮*)
							END_IF
						END_IF
					END_IF

				ELSE(*伪随机输出*)
					rTarVel_Act:=i_rPseudoRandomRoundAmplitude_Cur;(*获取目标速度*)
				(*	IF iSquareNum_Act>=i_uiSquareNum THEN(*足够就结束了*)
						rTarVel_Act:=0;
						xStepBtn:=FALSE;(*复位按钮*)
					END_IF  *)
				END_IF
			END_IF

			xNeedSmooth:=FALSE;(*不用平滑*)
	ELSE(*默认时阶跃*)
		(*阶跃输出处理*)
		rTarVel_Act:=i_rStepVel;(*获取目标速度*)
		IF NOT xStepping THEN
			IF xStepBtn THEN
				rStepVel_Cur:=0;
				rStepPos:=0;
				uiPrfTimeCnt:=0;
				xSetTrapParam:=TRUE;//触发参数写入@2026.5.8.184135+

				IF i_xAccing THEN
					IF i_rVel_Cur >= i_iTestVelSa THEN(*到达速度测试点了*)
						xStepping:=TRUE;(*接收伪随机速度指令*)
					END_IF
				ELSIF i_xDecing THEN
					IF i_rVel_Cur <= i_iTestVelSa THEN(*到达速度测试点了*)
						xStepping:=TRUE;(*接收伪随机速度指令*)
					END_IF
				ELSE(*匀速中*)
					xStepping:=TRUE;(*接收伪随机速度指令*)
				END_IF
			END_IF
		ELSE;(*已经处于阶跃中*)
			IF NOT xStepBtn THEN
				xStepping:=FALSE;
			END_IF
		END_IF
(*
		xStepBtn:=FALSE;(*沿触发*)
*)
		iSquareCycleCnt:=0;
	END_CASE
	rStepVel_Tar:=ABS(rTarVel_Act);(*只有正值*)
	xAccing:=FALSE;
	xDecing:=FALSE;
	xEvening:=FALSE;
	IF xStepping THEN
		IF rAccTime<>0 THEN
			rDelVel_Acc:=rStepVel_Tar/rAccTime*i_byCycleTime_Motion;(*m/min/ms*)
		END_IF
		IF rAccTime<>0 THEN
			rDelVel_Dec:=rStepVel_Tar/rDecTime*i_byCycleTime_Motion;(*m/min/ms*)
		END_IF
		IF NOT i_xFlag_PTfifofull THEN
			uiPrfTimeCnt:=uiPrfTimeCnt+1;
		END_IF
		(*速度处理*)
		IF xNeedSmooth THEN(*使用平滑*)
			IF xNeedEvening THEN
				IF uiPrfTimeCnt*i_byCycleTime_Motion<=rAccTime THEN
					xAccing:=TRUE;
				ELSIF uiPrfTimeCnt*i_byCycleTime_Motion<=lrTotalTime_ms - rDecTime THEN
					xEvening:=TRUE;
				ELSIF uiPrfTimeCnt*i_byCycleTime_Motion<=lrTotalTime_ms THEN
					xDecing:=TRUE;
				END_IF
			ELSE(*不用匀速*)
				IF uiPrfTimeCnt*i_byCycleTime_Motion<=rAccTime THEN
					xAccing:=TRUE;
				ELSIF uiPrfTimeCnt*i_byCycleTime_Motion<=lrTotalTime_ms THEN
					xDecing:=TRUE;
				END_IF
			END_IF

			IF xAccing THEN
				rStepVel_Cur:=rStepVel_Cur+rDelVel_Acc;
				IF rStepVel_Cur>rStepVel_Tar THEN
					rStepVel_Cur:=rStepVel_Tar;
				END_IF
			ELSIF xEvening THEN
				rStepVel_Cur:=rStepVel_Tar;
			ELSIF xDecing THEN(*有点下次|三角形不太好保证减速从rStepVel_Tar开始|是用来测试的，就先不理会吧*)
				rStepVel_Cur:=rStepVel_Cur-rDelVel_Dec;
				IF rStepVel_Cur<0 THEN
					rStepVel_Cur:=0;
				END_IF
			ELSE
				rStepVel_Cur:=0;
			END_IF
		ELSE(*不用平滑*)
			rStepVel_Cur:=rStepVel_Tar;
		END_IF

		(*输入的速度如果是负值,变化量输出取反.上面的运算都是按照正速度计算的.*)
		IF rTarVel_Act<0 THEN
			rStepVel_Cur:=-rStepVel_Cur;
		END_IF
		(*计算位置*)
		lrTmp:=rStepVel_Cur;
		lrTmp:=lrTmp/60.0*i_byCycleTime_Motion;(*mm*)
(*		lrTmp:=lrTmp*rPos2Pulse_Coeff;(*pulse*)*)(*写入的地方会进行运算*)
		rStepPos:=lrTmp;(*输出*)
		IF i_byOutType = 1 OR i_byOutType =2 THEN;

		ELSE(*阶跃按照持续时间处理*)
			iCycleCnt:=LREAL_TO_INT(lrTotalTime_ms) / i_iCycleTime_Plc;
			IF (uiPrfTimeCnt) > iCycleCnt THEN(*持续的时间到了|取消输出*)
				rStepVel_Cur:=0;
				rStepPos:=0;
				xStepping:=FALSE;
				xStepBtn:=FALSE;(*沿触发*)
			END_IF
		END_IF
	END_IF
ELSE(*不使能*)
;
END_IF

(*输出*)
IF i_pxStepBtn<>0 THEN
	i_pxStepBtn^:=xStepBtn;
END_IF
IF i_pxStepping<>0 THEN
	i_pxStepping^:=xStepping;
END_IF
IF i_prStepVel_Cur<>0 THEN
	i_prStepVel_Cur^:=rStepVel_Cur;
END_IF
IF i_prStepPos<>0 THEN
	i_prStepPos^:=rStepPos;
END_IF
(*
IF i_pfbTon<>0 THEN
	i_pfbTon^:=fbTon;
END_IF
*)
IF i_puiPrfTimeCnt<>0 THEN
	i_puiPrfTimeCnt^:=uiPrfTimeCnt;
END_IF
IF i_prTarVel_Act<>0 THEN
	i_prTarVel_Act^:=rTarVel_Act;
END_IF
IF i_piSquareCycleCnt<>0 THEN
	i_piSquareCycleCnt^:=iSquareCycleCnt;
END_IF
IF i_piSquareNum_Act<>0 THEN
	i_piSquareNum_Act^:=iSquareNum_Act;
END_IF
//2026.5.8.184053+
i_pxSetTrapParam^:=xSetTrapParam;