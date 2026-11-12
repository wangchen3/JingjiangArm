#ifndef __KS_SOMEFUNC_H
#define __KS_SOMEFUNC_H

#include "base.h"
#include "KesaiAPI.h"
#include "KS_FB_VISU.h"

//宏定义

/*
bit9:反馈脉冲数清零
bit10:脉冲输出标志，1：输出中
bit11:电机方向
bit12:速度模式时，高电平输出脉冲，低电平停止输出
bit13:位置模式时，上升沿开始输出脉冲，脉冲个数到达时停止输出
bit14:速度、位置模式 0：速度模式，1：位置模式
bit15:模块使能 0：脉冲输出无效，1：有效
*/
#define POSBAK_CLEAR			0x0200//(*反馈脉冲数清零*)
#define STEPDRIVE_DIR			0x0800//(*电机方向*)
#define SPEEDMODE_OUTCTL		0x1000//(*速度模式输出控制*)
#define POSMODE_OUTCTL			0x2000//(*位置模式输出控制*)
#define POSMODE					0x4000//(*默认为速度模式，有效为位置模式; 位置模式 速度模式选择，*)
#define AIMODULE_VALID			0x8000//(*模块使能*)
#define OUTTYPE_IO				0x55AA//按照io输出
#define OUTTYPE_PULSE			0xAA55//按照脉冲输出


//油墨槽控制功能@类型声明放到base.h中
/*
//数据类型声明
typedef enum {
	STEPDRIVE_IDLE,
	STEPDRIVE_RUN,
	STEPDRIVE_CLR,
	STEPDRIVE_WAITING,
	STEPDRIVE_MODULE_VALID,
	STEPDRIVE_PULSEOUT,
	STEPDRIVE_ALARM
}TypeEnumStepDriveStat;

//和主站相比较，做了删减，只把从站使用的封装起来了
typedef __packed struct{
	BYTE byMovingSts					;//:BYTE;(*运动状态|=0 不运动|=1 上升|=2 下降*)
	BYTE xCtlMode						;//:BOOL;(*控制模式|=false速度模式|=true 位置模式*)
	BYTE xMoveDir						;//:BOOL;(*运动的方向*)
	REAL rVel							;//:REAL;(*速度值@r/min*)
	REAL rMoveDis						;//:REAL;(*需要运动的距离@mm(带方向)*)
	DINT diMoveDis_Pulse				;//:DINT;(*需要运动的距离(正值)@pulse*)
	WORD wLastPulse_Act_Rd				;//:WORD;(*实际读取的脉冲数记录@上一拍*)
	BYTE xZeroValid						;//:BOOL;(*零位有效*)
	DINT diPulse_Moved					;//:DINT;(*已经移动的脉冲|在原点处会更新为0*)
	REAL rPos_Cur						;//:REAL;(*当前位置@mm|经过下限位零点后才有值*)
	DINT diThisMovedPulse				;//:DINT;(*本次运动的距离@脉冲*)
	REAL rThisMovedDis					;//:REAL;(*本次运动的距离@mm*)
	WORD wLastPulse_Act_Rd_1			;//:WORD;(*实际读取的脉冲数记录@上一拍|用于计算本次运动的而距离值*)
	BYTE abyReseved[11]					;//:ARRAY [1..11] OF BYTE;

}StInkGrooveCtl,*Lp_StInkGrooveCtl;
*/

//函数声明

//计算实际走的脉冲个数@累计输入的增量pulse
void KS_GetPulse_Act(WORD wPulse_Act_Rd,//(*读取到的脉冲数*)
					WORD* pwPulse_Act_Rd_Bak,//(*上个周期读到的脉冲数*)
					DINT* pdiPulse_Act);//(*实际走的脉冲数*)


//(*重新处理控制命令@因为位置模式有最大值的限制,这里将位置模式的控制拆分为先速度模式在位置模式输出控制*)
void KS_ReDealCtlCommand(Lp_StInkGrooveCtl i_pstStInkGrooveCtl,
							BYTE i_byPulseOutSts,//(*反馈的输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)
							//输出
							BYTE* i_pxPulseOutEn,//(*使能输出*)
							BYTE* i_pxMoveDir,//(*运动方向*)
							BYTE* i_pxPulseCtlMode,//(*控制模式|=false速度模式|=true 位置模式*)
							BYTE* i_pxVelMod_Run,//(*速度控制模式下|速度使能标志*)
							REAL* i_prVelMod_Vel,//(*速度控制模式下的速度*)
							WORD* i_pwPosMod_Pulse,//(*位置控制模式下的脉冲数*)
							BYTE* i_pxPosMod_InPos);//(*位置模式到位标志*)
							

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
					DINT* i_pdiPluse_Act);//(*实际的脉冲数@开始的时候会清除*)
					
					
//IO控制信息写入@用于脉冲控制输出
void KS_IoCtlInfWr(BYTE xPulseOut,
				WORD wFre_Sa,//(*起始频率写入到模块或者驱动器的值*)
				WORD wFreq_Tar,//(*目标频率写入到模块或者驱动器的值*)
				WORD wAccSaToTar,//(*频率加速度写入到模块或者驱动器的值*)
				WORD wPulse_Pos,//(*脉冲数写入到模块或者驱动器的值*)
				WORD wCTLBit);//: WORD;(*控制位*)

//IO控制信息读取@用于脉冲控制时候才获取
void KS_IoCtlInfRd(BYTE xPulseOut,WORD* wPulse_Act_Rd,BYTE* xPulseOutting_Rd);

#endif
