/*
 * gt_rn_struct_motion.h
 *
 *  Created on: Jul 31, 2024
 *      Author: 17500
 */

#ifndef GT_RN_STRUCT_MOTION_H_
#define GT_RN_STRUCT_MOTION_H_

#define MC_NONE                         -1

#define MC_LIMIT_POSITIVE               0
#define MC_LIMIT_NEGATIVE               1
#define MC_ALARM                        2
#define MC_HOME                         3
#define MC_GPI                          4
#define MC_ARRIVE                       5
#define MC_EGPI0                        6
#define MC_EGPI1                        7
#define MC_EGPI2                        8

#define MC_ENABLE                       10
#define MC_CLEAR                        11
#define MC_GPO                          12
#define MC_EGPO0                        13
#define MC_EGPO1                        14

#define MC_DAC                          20
#define MC_STEP                         21
#define MC_PULSE                        22
#define MC_ENCODER                      23
#define MC_ADC                          24

//Add 2014.01.02 by wu.jr
#define MC_AXIS                         30
#define MC_PROFILE                      31
#define MC_CONTROL                      32


#define MC_FULL_CLOSE_MODE              40
#define MC_SEMI_CLOSE_MODE              41
#define MC_HYBRID_CLOSE_MODE			42

// 捕获
#define CAPTURE_HOME                    1
#define CAPTURE_INDEX                   2
#define CAPTURE_PROBE                   3
#define CAPTURE_HSIO0                   6
#define CAPTURE_HSIO1                   7
#define CAPTURE_SOFT_PROBE0             8
#define CAPTURE_SOFT_PROBE1             9

#define PULSE_COUNT						10
#define ENCODER_COUNT					11


#define WATCH_LIST_MAX                  8
#define WATCH_LENGTH_MAX                32
#define WATCH_FIFO_SIZE                 0x1E0       // 480 word

#define WATCH_ADDRESS_TYPE_PRF_POS      (0)                           // 规划器规划位置,32.16
#define WATCH_ADDRESS_TYPE_PRF_VEL      (1)                           // 规划器规划速度,16.16
#define WATCH_ADDRESS_TYPE_ENC_POS      (2)                           // 编码器位置,32.0
#define WATCH_ADDRESS_TYPE_ENC_VEL      (3)                           // 编码器速度,16.16
#define WATCH_ADDRESS_TYPE_AXIS_PRF_POS (4)                           // axis规划位置,32.16
#define WATCH_ADDRESS_TYPE_AXIS_PRF_VEL (5)                           // axis规划速度,16.16
#define WATCH_ADDRESS_TYPE_AXIS_ENC_POS (6)                           // axis编码器位置,32.16
#define WATCH_ADDRESS_TYPE_AXIS_ENC_VEL (7)                           // axis编码器速度,16.16
#define WATCH_ADDRESS_TYPE_DAC          (8)                           // DAC输出,16.0
#define WATCH_ADDRESS_TYPE_LMT_POS      (9)                           // 正限位,16.0
#define WATCH_ADDRESS_TYPE_LMT_NEG      (10)                          // 负限位,16.0
#define WATCH_ADDRESS_TYPE_ALARM        (11)                          // 报警信号,16.0
#define WATCH_ADDRESS_TYPE_HOME         (12)                          // HOME信号,16.0
#define WATCH_ADDRESS_TYPE_GPI          (13)                          // 通用数字量输入,16.0
#define WATCH_ADDRESS_TYPE_ENABLE       (14)                          // 使能信号,16.0
#define WATCH_ADDRESS_TYPE_CLEAR        (15)                          // 报警清除信号,16.0
#define WATCH_ADDRESS_TYPE_GPO          (16)                          // 通用数字量输出,16.0
#define WATCH_ADDRESS_TYPE_CLOCK        (17)                          // 时钟,32.0
#define WATCH_ADDRESS_TYPE_FLASH_BUFFER (18)
#define WATCH_ADDRESS_TYPE_CRD_VEL      (19)                          // 坐标系合成规划速度,16.16
#define WATCH_ADDRESS_TYPE_ARRIVE       (20)                          // 电机到位信号,16.0
#define WATCH_ADDRESS_TYPE_POS_LOOP_ERROR (21)                        // 位置环跟随误差,32.16
#define WATCH_ADDRESS_TYPE_POS_LOOP_OUTPUT (22)                       // 位置环输出,16.0
#define WATCH_ADDRESS_TYPE_POS_LOOP_INTERGRAL (23)                    // 位置环积分值,32.16
#define WATCH_ADDRESS_TYPE_VEL_LOOP_ERROR (24)                        // 速度环跟随误差,32.16
#define WATCH_ADDRESS_TYPE_VEL_LOOP_INTERGRAL (25)                    // 速度环积分值,32.16
#define WATCH_ADDRESS_TYPE_SPRING_OFFSET (26)                         // 弹簧力补偿值,32.16
#define WATCH_ADDRESS_TYPE_BEFORE_SPRING (27)                         // 弹簧力补偿前控制量,32.16
#define WATCH_ADDRESS_TYPE_AFTER_SPRING (28)                          // 弹簧力补偿后控制量,32.16
#define WATCH_ADDRESS_TYPE_OBSERVER_LOWPASS_OUTPUT (29)               // 观测器低通滤波输出值,32.16
#define WATCH_ADDRESS_TYPE_OBSERVER_OUTPUT_PRE (30)                   // 观测器上一次输出值,32.32
#define WATCH_ADDRESS_TYPE_OBSERVER_TORQUE_CMD_PRE (31)               // 观测器扭矩输入上一次值,32.16
#define WATCH_ADDRESS_TYPE_OBSERVER_VEL_FEEDBACK_INTERGRAL (32)       // 观测器速度反馈积分值,32.32
#define WATCH_ADDRESS_TYPE_OBSERVER_VEL_ERR_FEEDBACK_INTERGRAL (33)   // 观测器速度偏差积分值,32.32

#define WATCH_ADDRESS_TYPE_POS_LOOP_REF_POS			(34)			  // 32.16

#define WATCH_ADDRESS_TYPE_ADC						(40)			  // 模拟量通道0的值 16.0
#define WATCH_ADDRESS_TYPE_POS_LOOP_REF_VEL			(41)			  // control的规划速度,16.16
#define WATCH_ADDRESS_TYPE_PRF_PRESS		   		(42)			  // 规划压力 16.0
#define WATCH_ADDRESS_TYPE_ATL_PRESS			   	(43)			  // 反馈压力 16.0
#define WATCH_ADDRESS_TYPE_PRF_SPEED		   		(44)			  // 速度环指令 16.0
#define WATCH_ADDRESS_TYPE_ATL_SPEED			   	(45)			  // 速度环速度反馈 16.0
#define WATCH_ADDRESS_TYPE_PRF_TORQUE          		(46)			  // 电流环指令 16.0
#define WATCH_ADDRESS_TYPE_ATL_TORQUE              	(47)			  // 电流环反馈 16.0

#define WATCH_ADDRESS_TYPE_PROFILE_LOOP             (50)			  // 规划周期数 16.0 驱控一体

#define WATCH_ADDRESS_TYPE_PRF_FORWARD_TORQUE         (55)			  // 电流前馈 16.16
/*驱动相关 watch 数据*/
#define WATCH_ADDRESS_TYPE_DRV_PRESS_REF				(1000)
#define WATCH_ADDRESS_TYPE_DRV_PRESS_FB					(1001)
#define WATCH_ADDRESS_TYPE_DRV_SPEED_REF				(1002)
#define WATCH_ADDRESS_TYPE_DRV_SPEED_FB					(1003)

#ifndef COMMAND_DATA_LEN
#define COMMAND_DATA_LEN	32
#endif

typedef struct Watch
{
	short count;
	short interval;
	unsigned long address[WATCH_LIST_MAX];
	short length[WATCH_LIST_MAX];
	unsigned long threshold;
} TWatch;


//////////////////////////////////////////////////////////////////////////
#define FOLLOW_MASTER_ENCODER           1
#define FOLLOW_MASTER_PROFILE           2
#define FOLLOW_MASTER_AXIS              3

#define FOLLOW_EVENT_START              1
#define FOLLOW_EVENT_PASS               2
#define FOLLOW_EVENT_HOME				3
#define	FOLLOW_EVENT_INDEX				4

#define FOLLOW_SEGMENT_NORMAL           0
#define FOLLOW_SEGMENT_EVEN             1
#define FOLLOW_SEGMENT_STOP             2
#define FOLLOW_SEGMENT_CONTINUE         3
//////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------
// PT模式相关函数
//----------------------------------------------------------
#define PT_MODE_STATIC                  (0)
#define PT_MODE_DYNAMIC                 (1)

#define PT_SEGMENT_NORMAL               (0)
#define PT_SEGMENT_EVEN                 (1)
#define PT_SEGMENT_STOP                 (2)

//#endif //RING_NET_RESOURCE


#endif /* GT_RN_STRUCT_MOTION_H_ */
