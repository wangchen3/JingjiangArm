#include "ks_somefunc.h"


//计算实际走的脉冲个数@累计输入的增量pulse
void KS_GetPulse_Act(WORD wPulse_Act_Rd,//(*读取到的脉冲数*)
					WORD* pwPulse_Act_Rd_Bak,//(*上个周期读到的脉冲数*)
					DINT* pdiPulse_Act)//(*实际走的脉冲数*)
{
	INT iTmp1 = (INT)wPulse_Act_Rd;
	INT iTmp2 = (INT)*pwPulse_Act_Rd_Bak;
	INT iTmp = iTmp1 - iTmp2;//增量
	if(iTmp != 0)
		*pdiPulse_Act += iTmp;
	
	*pwPulse_Act_Rd_Bak = wPulse_Act_Rd;//更新
}

//(*重新处理控制命令@因为位置模式有最大值的限制,这里将位置模式的控制拆分为先速度模式在位置模式输出控制*)
//有静态变量的函数不能多次被调用
void KS_ReDealCtlCommand(Lp_StInkGrooveCtl i_pstStInkGrooveCtl,
							BYTE i_byPulseOutSts,//(*反馈的输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
							//输出
							BYTE* i_pxPulseOutEn,//(*使能输出*)
							BYTE* i_pxMoveDir,//(*运动方向*)
							BYTE* i_pxPulseCtlMode,//(*控制模式|=false速度模式|=true 位置模式*)
							BYTE* i_pxVelMod_Run,//(*速度控制模式下|速度使能标志*)
							REAL* i_prVelMod_Vel,//(*速度控制模式下的速度*)
							WORD* i_pwPosMod_Pulse,//(*位置控制模式下的脉冲数*)
							BYTE* i_pxPosMod_InPos)//(*位置模式到位标志*)
							
{
	//定义
	static BYTE byPosModeSts;//(*位置模式的状态机
							//				|=1 位置模式
							//				|=2 速度模式+位置模式下的速度模式
							//				|=3 取消输出使能
							//				|=10切换为位置模式
							//				|=100等待结束
							//		*)

	Lp_StInkGrooveCtl pstStInkGrooveCtl = i_pstStInkGrooveCtl;

	BYTE xPulseOutEn = FALSE;//:BOOL;(*脉冲输出使能*)
	//TypeEnumStepDriveStat iPulseOutState = STEPDRIVE_IDLE;//:TypeEnumStepDriveStat;(*脉冲控制状态@状态机标志*)
	BYTE byOutSts = i_byPulseOutSts;//: BYTE;(*反馈的输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
	BYTE xVelMod_Run = FALSE;//: BOOL;(*速度模式.控制使能标志*)
	BYTE xCtlMode = FALSE;//: BOOL;(*控制模式*)
	REAL rSetVel = 0;//: REAL;(*速度模式的速度*)
	static WORD wSetPulse = 0;//:WORD;(*设置的脉冲数|控制过程中保持当前设置值*)
	static DINT diMovePulse_VelMod = 0;//速度模式下移动的脉冲数@速度+位置模式下
	
	BYTE xMoveDir = FALSE;//: BOOL;(*运动的方向*)
	DINT diDeltaPulse = 0;//: DINT;
	BYTE xInPos = FALSE;//: BOOL;(*位置到位*)
	

	//(*对于速度模式和位置模式做一些处理*)
	//(*对使能和控制方式做了重新处理*)
	if (pstStInkGrooveCtl->byMovingSts != 0)//(*可以运动了*)
	{
		xMoveDir = pstStInkGrooveCtl->xMoveDir;
		rSetVel = pstStInkGrooveCtl->rVel;
		xVelMod_Run = FALSE;
		if(pstStInkGrooveCtl->xCtlMode)//(*位置模式的时候|按照速度模式+位置模式实现*)
		{
			switch(byPosModeSts)
			{
				case 0:
					//(*判断留点余量*)
					if(ABS(pstStInkGrooveCtl->diMoveDis_Pulse)<65000)//(*65535*) THEN(*未超限|直接使用位置模式模块位置模式最大65535脉冲*)
						byPosModeSts = 1;
					else
						byPosModeSts = 2;
					
					wSetPulse = 0;//(*设置的脉冲值先写0*)
					diMovePulse_VelMod = 0;//速度+位置时记录的脉冲值需要值清零
					break;
				case 1://(*位置模式*)
					xPulseOutEn = TRUE;
					xCtlMode = TRUE;//(*按照位置模式*)
					wSetPulse = (WORD)(pstStInkGrooveCtl->diMoveDis_Pulse);
					byPosModeSts = 100;
					break;
				case 2://(*速度模式+位置模式下的速度模式*)
					xPulseOutEn = TRUE;
					xCtlMode = FALSE;
					xVelMod_Run = TRUE;
				
					if(byOutSts!=0)//需要用到diThisMovedPulse值,该值在KS_PulseOutCtl中清零累加,需要保证已经运动开始才能运算
					{
						diDeltaPulse = ABS(pstStInkGrooveCtl->diMoveDis_Pulse)-ABS(pstStInkGrooveCtl->diThisMovedPulse);
						if(diDeltaPulse<65535 && diDeltaPulse>0)
							byPosModeSts = 3;//(*先退出速度模式再进入位置模式*)
						else if (diDeltaPulse<0)
						{
							byPosModeSts = 110;//(*直接结束吧*)
							xInPos = TRUE;//(*到位标志*)
						}
						else
						{
							if(byOutSts==3)//(*速度模式运动异常*)
							{
								byPosModeSts = 110;//(*直接结束吧*)
								xInPos = TRUE;//(*到位标志*)
							}
						}
					}
					break;
				case 3://(*退出速度模式*)
					xPulseOutEn = FALSE;
					if(byOutSts==0 || byOutSts==3)//(*停止运动了*)
					{
						if(byOutSts==0)
							byPosModeSts = 4;//10;//(*重新进入位置模式*) //=4多等待一个周期
						else//(*速度模式运动长时间没反应
						{
							byPosModeSts = 110;
							xInPos = TRUE;//(*到位标志*)
						}
					}
					break;
				case 4://退出速度模式后等待脉冲输出函数真正退出
						//切换到位置模式的时候@记录速度模式下走的脉冲数
						//diThisMovedPulse该值在切换模式的时候会清零,故作记录
						diMovePulse_VelMod = ABS(pstStInkGrooveCtl->diThisMovedPulse);
						byPosModeSts = 10;
				case 10://(*后半程进入位置模式\并未退出运动控制case@本次运动脉冲不会清除*)
					xPulseOutEn = TRUE;
					xCtlMode = TRUE;//(*按照位置模式*)
					diDeltaPulse = ABS(pstStInkGrooveCtl->diMoveDis_Pulse) - diMovePulse_VelMod;//实际还需要运动的距离
					if(diDeltaPulse>65535)
						diDeltaPulse = 65535;
					
					else if(diDeltaPulse>0);
					
					else
						diDeltaPulse = 0;
					
					wSetPulse = (WORD)(diDeltaPulse);
					byPosModeSts = 100;

					break;
				case 100://(*等待结束*)
					xPulseOutEn = TRUE;
					xCtlMode = TRUE;//(*按照位置模式*)
					if(ABS(pstStInkGrooveCtl->diThisMovedPulse) + diMovePulse_VelMod >= ABS(pstStInkGrooveCtl->diMoveDis_Pulse))//(*本次运动的+速度模式运动的超过了需要运动的*)
					{
						byPosModeSts = 110;
						xInPos = TRUE;//(*到位标志*)
					}
					break;
				case 110://(*到位了*)
					xInPos = TRUE;//(*到位标志*)
					break;
				default:
					byPosModeSts = 0;
					wSetPulse = 0;
					break;
			
			}
		}
		else//(*速度模式*)
		{
			wSetPulse = 0;//(*设置的脉冲值先写0*)
			byPosModeSts = 0;
			xPulseOutEn = TRUE;
			xCtlMode = FALSE;
			//(*速度模式,停止就减速停吧*)
			xVelMod_Run = TRUE;
		}
	}
	else//(*停止运动了*)
	{
		byPosModeSts = 0;
		wSetPulse = 0;//(*设置的脉冲值先写0*)
	}

	
	if(i_pxPulseOutEn!=0)
		*i_pxPulseOutEn = xPulseOutEn;
	
	if(i_pxMoveDir!=0)
		*i_pxMoveDir = xMoveDir;
	
	if(i_pxPulseCtlMode!=0)
		*i_pxPulseCtlMode = xCtlMode;
	
	if(i_pxVelMod_Run!=0)
		*i_pxVelMod_Run = xVelMod_Run;
	
	if(i_prVelMod_Vel!=0)
		*i_prVelMod_Vel = rSetVel;

	if(i_pwPosMod_Pulse!=0)
		*i_pwPosMod_Pulse = wSetPulse;
	
	if(i_pxPosMod_InPos!=0)
		*i_pxPosMod_InPos = xInPos;
	
}

//(*2025.2.19.105619 脉冲输出控制函数@主要针对1610模块以及新款16d驱动器io*)
//(*切换模式的话,需要取消使能|i_pbyOutSts^=3只有速度模式才会被写入*)
//有静态变量的函数不能多次被调用
INT KS_PulseOutCtl(BYTE i_xEn,//:BOOL;(*控制使能了*)
					BYTE i_xIOUsePulseOut,//IO使用脉冲输出@控制驱动器的io输出形式@主站通讯下来
					BYTE i_xClrPulse_Act_Rd,//:BOOL;(*清理实际的脉冲数*)
					BYTE i_byJudgeOutsts_WaitNum,//:BYTE:=10;(*等待周期数@超过该值强制清除输出中标志|时间=i_byJudgeOutsts_WaitNum*执行周期*)
					DWORD i_dwPulse_1r,//:DWORD;(*一圈的脉冲数*)
					BYTE i_xCtlMode,//:BOOL;(*控制模式@=false 速度模式|=true 位置模式*)
					BYTE i_xVelMod_Run,//:BOOL;(*速度模式下,启动运动标志@前提是状态机已经启动到了脉冲输出case*)
					BYTE i_xDir,//:BOOL;(*输出的方向@false=正向|=true 反向*)
//2025.6.16.191123  在stm32cube环境下这两个数会异常|问题未知,修改为word输入
/*
					REAL i_rVel_Sa,//:REAL;(*起始速度@r/min*)
					REAL i_rVel,//l:REAL;(*速度值@速度模式 r/min*)
*/
					WORD i_wVel_Sa,//:REAL;(*起始速度@r/min*)
					WORD i_wVel,//l:REAL;(*速度值@速度模式 r/min*)
					INT i_iAccTime_ms,//:INT;(*加速时间@100*)(*ms*)
					WORD* i_pwPulse,//(*输出的脉冲个数-写入后就清零了@位置模式*)
					//状态输出
					WORD* i_pwPulse_Act_Rd,//获取的脉冲个数
					BYTE* i_xPulseOutting_Rd,//获取的脉冲输出中标志
					BYTE* i_pbyOutSts,//(*输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
					BYTE* i_pxCtlMod_Cur,//(*当前控制模式@=false 速度模式|=true 位置模式*)
					DINT* i_pdiPluse_Act)//(*实际的脉冲数@开始的时候会清除*)

{
	static TypeEnumStepDriveStat iState = STEPDRIVE_IDLE;//(*控制状态机*)
	static BYTE byWaitCnt = 0;
	static DINT diPluse_Act = 0;//:DINT;(*实际的脉冲数*)
	static WORD wLastPulse_Act_Rd = 0;//(*实际读取的脉冲数记录@上一拍*)
	static BYTE xCtlMod_Cur = FALSE;//: BOOL;(*当前控制模式@=false 速度模式|=true 位置模式*)
	
	
	LREAL lrTemp = 0;//:LREAL;
	//DWORD dwPulse_Pos = 0;//:DWORD;(*目前只取了word@因为模块和驱动器都只支持到word类型*)
	LREAL lrFreq_Sa = 0;//: LREAL;(*起始频率@P/S*)
	LREAL lrFreq_Tar = 0;//: LREAL;(*目标频率@P/S*)
	LREAL lrAccSaToTar = 0;//:LREAL;(*起始频率加速到目标频率的加速度@hz/s*)
	WORD wFre_Sa_Wr = 0;//: WORD;(*起始频率写入到模块或者驱动器的值*)
	WORD wFreq_Tar_Wr = 0;//: WORD;(*目标频率写入到模块或者驱动器的值*)
	WORD wAccSaToTar_Wr = 0;//: WORD;(*频率加速度写入到模块或者驱动器的值*)
	static WORD wPrevPulse_Pos = 0;//:WORD;(*输入的脉冲数*)
	static WORD wPulse_Pos_Wr = 0;//:WORD;(*脉冲数写入到模块或者驱动器的值*)
	BYTE byOutSts = 0;//(*输出状态|=0 不输出|=1 输出|=2异常*)
	
	WORD wCTLBit = 0;//: WORD;(*控制位*)
	INT iAccTime_ms = 0;//: INT;
	BYTE xPulseOutting_Rd = FALSE;//获取的脉冲输出标志
	WORD wPulse_Act_Rd = 0;//(*读取的脉冲输出个数*)
	
	//BYTE xFreq_Sa_Wr = FALSE;//:BOOL;(*启动频率写入标志*)
	//BYTE xFreq_Tar_Wr = FALSE;//:BOOL;(*目标频率写入标志*)
	//BYTE xFreq_AccSaToTar_Wr = FALSE;//:BOOL;(*加速度频率写入标志*)
	BYTE xFreq_Pulse_Pos_Wr = FALSE;//:BOOL;(*脉冲写入标志*)

	if(i_pbyOutSts!=0)
		byOutSts = *i_pbyOutSts;//: BYTE;(*输出状态|=0 不输出|=1 输出|=2异常*)
	
	//读取状态
	KS_IoCtlInfRd(i_xIOUsePulseOut,&wPulse_Act_Rd,&xPulseOutting_Rd);
	
		
	if(i_xEn && i_xIOUsePulseOut)//控制使能的时候,脉冲控制输出也有效
	{
		//(*写入到模块或者驱动器的值*)
		if(i_pwPulse!=0)//(*写入的脉冲数*)
		{
			if(wPrevPulse_Pos != *i_pwPulse)//输入的脉冲变了
			{
				wPulse_Pos_Wr = *i_pwPulse;//赋值给写入的脉冲值
				wPrevPulse_Pos = *i_pwPulse;
			}
		}
		
		if(i_iAccTime_ms!=0)
			iAccTime_ms = ABS(i_iAccTime_ms);
		else
			iAccTime_ms = 100;

		//lrTemp = EXPT(2,12)/EXPT(5,6);//(*由EXPT(2,18)/EXPT(10,6)化简而来*)
		lrTemp = 0.262144;
		//(*将起始速度转换为频率*)
		//lrFreq_Sa = (LREAL)(i_dwPulse_1r*ABS(i_rVel_Sa)/60.0);//(*pul/s*)
		//i_rVel_Sa 修改为word@2025.6.16.191333
		lrFreq_Sa = (LREAL)(i_dwPulse_1r*ABS((LREAL)i_wVel_Sa)/60.0);//(*pul/s*)
		//(*将目标速度转换为频率*)
		//i_rVel 修改为word@2025.6.16.191333
		lrFreq_Tar = (LREAL)(i_dwPulse_1r*ABS((LREAL)i_wVel)/60.0);//(*pul/s*)

		//(*起始频率大于目标频率时 让起始频率等于目标频率*)
		if(lrFreq_Sa>lrFreq_Tar)
			lrFreq_Sa = lrFreq_Tar;
		
		//(*计算起始频率应该写入的值*)
		wFre_Sa_Wr = (WORD)(lrFreq_Sa*lrTemp);//(*计算写入模块中的值*)

		//(*计算目标频率应该写入的值*)
		wFreq_Tar_Wr = (WORD)(lrFreq_Tar*lrTemp);//(*计算写入模块中的值*)

		//(*计算加速度*)
		//lrTemp = EXPT(2,22)/EXPT(5,12);(*EXPT(2,32)/EXPT(10,12)化简得到的*)(*计算出的加速度*该值就是需要写入模块中的值*)
		lrTemp = 0.01718;
		//(*计算加速度@从起始频率到目标频率的加速度*)
		lrAccSaToTar = ABS(lrFreq_Tar-lrFreq_Sa)*1000/iAccTime_ms;//(*HZ/S*)
		//(*需要写入到模块中的加速度值*)
		wAccSaToTar_Wr = (WORD)(lrAccSaToTar*lrTemp);

		//(*启动case*)
		if(iState == STEPDRIVE_IDLE)
			iState = STEPDRIVE_RUN;
		
		wCTLBit = 0;//(*清零该控制位*)
		//xFreq_Sa_Wr = FALSE;
		//xFreq_Tar_Wr = FALSE;
		//xFreq_AccSaToTar_Wr = FALSE;
		xFreq_Pulse_Pos_Wr = FALSE;
		switch(iState)
		{
			case STEPDRIVE_IDLE:
				break;
			case STEPDRIVE_RUN:
			case STEPDRIVE_CLR:
				if(i_xClrPulse_Act_Rd)
					wCTLBit = POSBAK_CLEAR;
				
				iState = STEPDRIVE_WAITING;
				//(*放在这个周期是希望在计数清零执行后*)
				diPluse_Act = 0;//(*初始化脉冲计数值*)
				wLastPulse_Act_Rd = wPulse_Act_Rd;//(*初始化上个周期的值*)
				byOutSts = 255;
				xCtlMod_Cur = i_xCtlMode;
				byWaitCnt = 0;
				break;
			case STEPDRIVE_WAITING://(*等一个周期*)
				iState = STEPDRIVE_MODULE_VALID;
				break;
			case STEPDRIVE_MODULE_VALID://(*模块使能*)
				//(*放在这个周期是希望在计数清零执行后*)
				diPluse_Act = 0;//(*初始化脉冲计数值*)
				wLastPulse_Act_Rd = wPulse_Act_Rd;//(*初始化上个周期的值*)

				wCTLBit = AIMODULE_VALID;
				if(xCtlMod_Cur)//(*位置模式*)
					wCTLBit = wCTLBit+POSMODE;
				else//(*速度模式*)
					wCTLBit = wCTLBit;
				
				if(i_xDir)//(*步进电机方向*)
					wCTLBit = wCTLBit+STEPDRIVE_DIR;
				else;//(*默认方向*)
				
				//(*2022.11.19.160459 从case-STEPDRIVE_PULSEOUT复制到此处 提前写入一个周期
				//@发现手动有时候脉冲输出不对
				//@发现手动有时候会步输出。测试复制到此处出现的概率小很多了*)
				//(*写入启动频率 目标频率 加速度值*)
				//xFreq_Sa_Wr = TRUE;//(*启动频率写入标志*)
				//xFreq_Tar_Wr = TRUE;//(*目标频率写入标志*)
				//xFreq_AccSaToTar_Wr = TRUE;//(*加速度值写入标志*)
				iState = STEPDRIVE_PULSEOUT;//(*进入脉冲输出逻辑*)
				break;
			case STEPDRIVE_PULSEOUT://(*脉冲输出*)(*脉冲输出比电机方向配置晚一个周期*)
				//(*写入启动频率 目标频率 加速度值*)
				//xFreq_Sa_Wr = TRUE;//(*启动频率写入标志*)
				//xFreq_Tar_Wr = TRUE;//(*目标频率写入标志*)
				//xFreq_AccSaToTar_Wr = TRUE;//(*加速度值写入标志*)

				if(xCtlMod_Cur)//(*位置模式*)
				{
					wCTLBit = AIMODULE_VALID+POSMODE;
					//(*写入脉冲数*)
					if(byOutSts==255)//(*未输出的时候才能写入*)
					{
						if (wPulse_Pos_Wr!=0)
						{
							xFreq_Pulse_Pos_Wr = TRUE;//(*脉冲数写入标志*)
							wCTLBit = wCTLBit+POSMODE_OUTCTL;//(*有效之后输出脉冲*)(*上升沿触发*)
							byOutSts = 1;//(*置位输出中标志*)
							byWaitCnt = 0;
						}
					}
					else if(byOutSts==1)//(*输出中*)
					{
						if(byWaitCnt>=i_byJudgeOutsts_WaitNum)//(*超过计时@判断是否结束|认为超过这个时间肯定运动了*)
						{
							if (!xPulseOutting_Rd)
								byOutSts = 255;
						}	
						else//(*等待*)
						{
							byWaitCnt = byWaitCnt+1;
							if(xPulseOutting_Rd)
								byOutSts = 2;
						}	
					}
					else if(byOutSts==2)//(*实际也运行了*)
					{
						if (!xPulseOutting_Rd)
							byOutSts = 255;
					}
				}
				else//(*速度模式*)(*该模式启动之后就不能更改参数，除非重新开始*)
				{
					wCTLBit = AIMODULE_VALID;
					if(byOutSts==255)//(*未输出的时候才能写入*)
					{
						if(i_xVelMod_Run)
						{
							wCTLBit = wCTLBit+SPEEDMODE_OUTCTL;//(*有效之后输出脉冲*)
							byOutSts = 1;//(*置位输出中标志*)
							byWaitCnt = 0;
						}
					}
					else
					{
						wCTLBit = wCTLBit+SPEEDMODE_OUTCTL;
						if(byOutSts==1)//(*输出中*)
							if(byWaitCnt>=i_byJudgeOutsts_WaitNum)//(*超过计时@判断是否结束|认为超过这个时间肯定运动了*)
								if (xPulseOutting_Rd)//(*实际运动了*)
									byOutSts = 2;
								else
								{
									if(!i_xVelMod_Run)//(*退出运动了*)
										byOutSts = 255;
									else//(*还未执行运动则报错*)
										byOutSts = 3;
									
								}
							else//(*等待*)
							{
								byWaitCnt = byWaitCnt+1;
								if(xPulseOutting_Rd)//(*已经再运行了*)
									byOutSts = 2;
							}
						else if(byOutSts==2)//(*实际确实再运行了*)
						{
							if(!i_xVelMod_Run && !xPulseOutting_Rd)//(*退出运动了*)
								byOutSts = 255;
						}
						else//(*byOutSts=3*)
						{
							if(!i_xVelMod_Run)//(*退出运动了*)
								byOutSts = 255;
						}
					}
				}



				if(i_xDir)// (*步进电机方向*)
					wCTLBit = wCTLBit+STEPDRIVE_DIR;
				else;//(*默认方向*)
				break;
			case STEPDRIVE_ALARM:;//(*报警步*)
				default:break;
		}

		//(*计算本次实际走的脉冲数*)
		KS_GetPulse_Act(wPulse_Act_Rd,
						&wLastPulse_Act_Rd,
						&diPluse_Act);
		
	}
	else//(*不使能*)
	{
		iState = STEPDRIVE_IDLE;
		wPulse_Pos_Wr = 0;//(*写入的脉冲为0*)
		wPrevPulse_Pos = 0;
		if(xPulseOutting_Rd)
			byOutSts = 1;
		else
			byOutSts = 0;
	}
	
	//写入到寄存器中
	KS_IoCtlInfWr(i_xIOUsePulseOut,wFre_Sa_Wr,wFreq_Tar_Wr,wAccSaToTar_Wr,wPulse_Pos_Wr,wCTLBit);
	
	if(xFreq_Pulse_Pos_Wr)//需要写入标志|执行写入函数后写入值清零
		wPulse_Pos_Wr = 0;
	
//上面修改了位置脉冲值0->非零才写入
/*
	if(i_pwPulse!=0)
		*i_pwPulse = wPulse_Pos_Wr;
*/
	
	if(i_pwPulse_Act_Rd!=0)
		*i_pwPulse_Act_Rd = wPulse_Act_Rd;
	
	if(i_xPulseOutting_Rd!=0)
		*i_xPulseOutting_Rd = xPulseOutting_Rd;
	
	if(i_pdiPluse_Act!=0)
		*i_pdiPluse_Act= diPluse_Act;

	if(i_pbyOutSts!=0)
		*i_pbyOutSts = byOutSts;

	if(i_pxCtlMod_Cur!=0)
		*i_pxCtlMod_Cur = xCtlMod_Cur;
	
	return 0;
}

//IO控制信息写入@用于脉冲控制输出
void KS_IoCtlInfWr(BYTE xPulseOut,
				WORD wFre_Sa,//(*起始频率写入到模块或者驱动器的值*)
				WORD wFreq_Tar,//(*目标频率写入到模块或者驱动器的值*)
				WORD wAccSaToTar,//(*频率加速度写入到模块或者驱动器的值*)
				WORD wPulse_Pos,//(*脉冲数写入到模块或者驱动器的值*)
				WORD wCTLBit)//: WORD;(*控制位*)
{
	WORD awData_Wr[6] = {0};//定义一个写入数组

	if(xPulseOut)//按照脉冲输出
	{
		awData_Wr[0] = wFre_Sa; // (*起始频率写入到模块或者驱动器的值*)
		awData_Wr[1] = wFreq_Tar; // (*目标频率写入到模块或者驱动器的值*)
		awData_Wr[2] = wAccSaToTar; //(*频率加速度写入到模块或者驱动器的值*)
		awData_Wr[3] = wPulse_Pos; // (*脉冲数写入到模块或者驱动器的值*)
		awData_Wr[4] = wCTLBit; // (*控制位*)
		awData_Wr[5] = OUTTYPE_PULSE; // 输出脉冲标志位
	//	awData_Wr[5] = 0xAA55; // 输出脉冲标志位
		GT_RN_SetPulseParam(awData_Wr);//命令写入
	}
	else
	{
		awData_Wr[5] = OUTTYPE_IO; // io输出标志位
		GT_RN_SetPulseParam(awData_Wr);
	}
}

//IO控制信息读取@用于脉冲控制时候才获取
void KS_IoCtlInfRd(BYTE xPulseOut,WORD* wPulse_Act_Rd,BYTE* xPulseOutting_Rd)
{
	WORD awData_Wr[6] = {0};//定义一个写入数组
	if(xPulseOut)//按照脉冲输出
	{
		GT_RN_GetPulseParam(awData_Wr);//数据获取
	}
	
	*wPulse_Act_Rd = awData_Wr[3];
	*xPulseOutting_Rd = GetBit(awData_Wr[4],10);
}



/*


//2024.12.09.110454 /wei.n/欧诺油墨槽升降功能
void KS_FB_InkPlate_UpDn(StAxisParam* i_pstStAxisParam)
{
	unsigned short ipDateWr[6]= {0};
	unsigned short ipDateRd[6]= {0};
	INT iTemp1;
	INT iTemp2;
	INT iAccTime_ms = 1000;              // 加速时间
	
	ipDateWr[0] = (INT)(200*0.262144);  //启动频率 F = F0*POW(2^18/10^6) = F0*0.262144     输出频率F0=200HZ=0.2kHZ
	ipDateWr[1] = i_pstStAxisParam->wTaget_freq;  // 目标频率
	iTemp1 = (INT)((i_pstStAxisParam->wTaget_freq - 0.2)*1000 * 0.01718);  //加速度(HZ/s)A = A0*POW(2^34/10^12) = (目标频率-启动频率)(单位:HZ/s)*0.017118 
	ipDateWr[2] = iTemp1; 
	ipDateWr[3] = i_pstStAxisParam->wPls_Num;       // 脉冲个数
	ipDateWr[4] = i_pstStAxisParam->wPlate_statues; // 模块状态位
	if(GetBit(ipDateWr[4],15)) // 模块使能
	{	
		ipDateWr[5] = 0xAA55; // 输出脉冲标志位
		GT_RN_SetPulseParam(ipDateWr);
		GT_RN_GetPulseParam(ipDateRd); //读取脉冲
		i_pstStAxisParam->wExPulse = ipDateRd[3];
		iTemp2 = GetBit(ipDateRd[4],10);
		i_pstStAxisParam->byDriverWorking_Flag = iTemp2;
	}
	else
	{
		ipDateWr[5] = 0x55AA; // io输出标志位
		GT_RN_SetPulseParam(ipDateWr);
	}
}





*/
