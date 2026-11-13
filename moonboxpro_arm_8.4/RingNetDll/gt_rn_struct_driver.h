/*
 * gt_rn_struct_driver.h
 *
 *  Created on: Jul 31, 2024
 *      Author: 17500
 */

#ifndef GT_RN_STRUCT_DRIVER_H_
#define GT_RN_STRUCT_DRIVER_H_

#pragma once


#define	MAX_PROFILE			3
#define	MAX_AXIS			3

#define	KTY84_TEMPER		4709			//KTY84的零温度DSP数值
#define	KTY84_RMP			41.5			//KTY84的温度上升斜率

typedef struct DRIVERMESSAGE
{
	float motor_temper;						//电机温度
	float motor_current_rms;				//电机电流有效值
	float motor_brake_time;					//制动时间
	float motor_brake_number;				//制动次数
}drivermessage;

typedef struct FRIMWAREVERSION
{
	short dsp_ver_year;
	short dsp_ver_md;
	short fpga_ver_year;
	short fpga_ver_md;
	short cpld_ver_year;
	short cpld_ver_md;
}firmwareversion;

typedef struct JogPrm
{
	double acc;
	double dec;
	double smooth;
} TJogPrm;

typedef struct TrapPrm
{
	double acc;
	double dec;
	double velStart;
	short  smoothTime;
} TTrapPrm;

typedef struct Pid
{
	double kp;
	double ki;
	double kd;
	double kvff;
	double kaff;
	long   integralLimit;
	long   derivativeLimit;
	short  limit;
} TPid;

typedef struct TPressPid
{
	double kp;
	double ki;
	double kd;
	double kvff;
	double kaff;
	double piConvertPara;
	long integralLimit;
	long derivativeLimit;
	short limitMax;
	short limitMin;
} TPressPid;
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
#define LOOP_MODE_POSITION               (0)
#define LOOP_MODE_PRESS                  (1)
#define LOOP_MODE_NONE                   (2)

typedef struct
{
	short loopMode;
	short pressProfileMode;
} TLoopMode;
//////////////////////////////////////////////////////////////////////////
// liang.jj 20131104 注塑机工艺相关
#define MC_ERULER                       25
#define MC_ENCODER                      23

typedef struct InjectPara
{
	double endPos;                                          // 目标位置
	short  maxP;                                            // 最大压力，即运动过程中的压力值
	short  maxQ;                                            // 最大流量，相当于梯形规划中的目标速度
	short  minQ;                                            // 最小流量，未到位前最小速度输出指令
	short  maxQAcc;                                         // 最大流量变化率
	long   valveDo;                                         // 运动过程中打开的DO，有效位为低8位，运动结束都输出取反并经过valveDoMask掩码后的valveDo值
	long   valveDoMask;                                     // 与ValveDo配合控制到位时需要关闭的DO，DoMask中非0的位代表该DO需要输出
	long   valveShutTime;                                   // 阀关闭的时间点
	long   deltaDecPos;										// 减速位置偏置量
	short  adjustType;										// 1 手动调整，2自动调整，0 锁定调整后的减速位置偏置
	double adjustCoeff;										// 调整系数。
	long   deltaPosInMinQ;                                  // 读取以最小流量运动的位移。
	long   posOffsetInMinQ;                                 // 设置最小流量运动的固定位移。
	double qKp;												// 兼容以前版本保留变量。
} TInjectPara;

typedef struct FeedbackPara
{
	short  fbType;                                          // 反馈通道，可选电子尺MC_ERULER或编码器MC_ENCODER
	short  fbIndex;                                         // 反馈通道的索引(0-5)
	short  fbFilterPara1;                                   // 反馈滤波系数1
	short  fbFilterPara2;                                   // 反馈滤波系数2
} TFeedbackPara;
//////////////////////////////////////////////////////////////////////////

#define PRESS_PROFILE_NONE                  (0)
#define PRESS_PROFILE_TARGET                (1)
#define PRESS_PROFILE_ARRAY                 (2)

#define PRESS_DIR_NONE                      (0)
#define PRESS_DIR_CROSS_POSITIVE            (1)
#define PRESS_DIR_CROSS_NEGATIVE            (2)
#define PRESS_DIR_CROSS_BOTH                (3)
#define PRESS_DIR_GE                        (4)
#define PRESS_DIR_LE                        (5)


#define PRESS_STOP_GREATER_THAN_LIMIT             (0)
#define PRESS_STOP_LESS_THAN_LIMIT                (1)

typedef struct
{
	short limit1;
	short limit2;
	short time;
	short triggerCondition;        // 压力急停触发条件，PRESS_GREATER_THAN_LIMIT,PRESS_LESS_THAN_LIMIT,
} TPressStop;

typedef struct
{
	double dec;
} TLoopSwitch;

typedef struct
{
	long t;
	double k;
} TPressFilter;

typedef struct
{
	double acc;				// 力矩加速度
	double dec;				// 力矩减速度
} TPressPrm;

typedef struct
{
	double pressTarget;
	long pressTime;
	double pressAcc;
} TPressArrayData;

typedef struct
{
	short count;
	TPressArrayData buffer[4];
	short exit;
} TPressArray;

//////////////////////////////////////////////////////////////////////////
typedef struct
{
	double k;
	short ignoreBit;
} TAdcFilter;


typedef struct ControlInfo
{
	double refPos;
	double refPosFilter;
	double refPosFilter2;
	double cntPos;
	double cntPosFilter;

	double error;
	double refVel;
	double refAcc;

	short value;
	short valueFilter;

	short offset;
} TControlInfo;


typedef struct DebugInfo
{
	long cntPos_Debug;
	long prfPos_Debug;
	long error_Debug;
	short encoder_Debug;

} TDebugInfo;

//////////////////////////////////////////////////////////////////////////

#define MOVE_DISTANCE_NONE                  (0)
#define MOVE_DISTANCE_PRESS                 (1)

typedef struct
{
	short enable;
	double value;
	long distance;
} TMoveDistancePress;


typedef struct
{
	long distance;
	double vel;
	double acc;
} TStopOffset;
//////////////////////////////////////////////////////////////////////////

typedef struct ThreadStatus
{
	short link;
	unsigned long  address;
	short size;
	unsigned long  page;
	short delay;
	short priority;
	short ptr;
	short status;
	short error;
	short result[4];
	short resultType;
	short breakpoint;
	short period;
	short count;
	short function;
} TThreadStatus;

typedef struct VarInfo
{
	short id;
	short dataType;
	char  name[32];
} TVarInfo;

typedef struct CompileInfo
{
	char  *pFileName;
	short *pLineNo;
	char  *pMessage;
} TCompileInfo;

typedef struct ThreadSts
{
	short  run;
	short  error;
	double result;
	short  line;
} TThreadSts;

#endif /* GT_RN_STRUCT_DRIVER_H_ */
