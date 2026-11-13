/*
 * KS_FB_DacOutCtl.h
 *
 *  Created on: Jul 22, 2025
 *      Author: 17500
 */

#ifndef KS_FB_DACOUTCTL_H_
#define KS_FB_DACOUTCTL_H_
#include "stdint.h"
#include "base.h"

//2025.11.5.102636 偏移地址研究院要求标准统一,在gtd库里做了这片地址访问区分@moonboxpro主站不访问这片地址
//主站定义的这片地址既是月光宝盒pro参数又是驱动器上的本地io中的io输出
//2025.7.22.113946|wei.n|移植
#define ADR_OFFSET_T1			0x3A0		//T1偏移
#define ADR_SOURCE_LIGHT_T1		0x3A8		//T1光源
#define ADR_BIAS_T1				0x3B0		//T1偏置
#define ADR_BRIGHTNESS_LIGHT_T1 0x3B8		//T1亮度

#define ADR_OFFSET_T2			0x3C0		//T2偏移
#define ADR_SOURCE_LIGHT_T2		0x3C8		//T2光源
#define ADR_BIAS_T2				0x3D0		//T2偏置
#define ADR_BRIGHTNESS_LIGHT_T2 0x3D8		//T2亮度

#define byDepthFilter_SourceLightCtl 5	//自动聚焦_光源自调整滤波深度



/*
//2025.11.1.145955 调整参数fpga地址@月光宝盒pro固件必须是2025.11.1后
#define ADR_OFFSET_T1			0x3C0		//T1偏移
#define ADR_SOURCE_LIGHT_T1		0x3C8		//T1光源
#define ADR_BIAS_T1				0x3D0		//T1偏置
#define ADR_BRIGHTNESS_LIGHT_T1 0x3D8		//T1亮度

#define ADR_OFFSET_T2			0x3E0		//T2偏移
#define ADR_SOURCE_LIGHT_T2		0x3E8		//T2光源
#define ADR_BIAS_T2				0x3F0		//T2偏置
#define ADR_BRIGHTNESS_LIGHT_T2 0x3F8		//T2亮度
*/

void KS_FB_DacOutCtl(float i_rOffSet_T1,			   //T1偏移
					float i_rSource_Light_T1,   		//T1光源
					float i_rBias_T1,					//T1偏置
					float i_rBrightness_Light_T1,		//T1亮度
					float i_rOffSet_T2,				   //T2偏移
					float i_rSource_Light_T2,   		//T2光源
					float i_rBias_T2,					//T2偏置
					float i_rBrightness_Light_T2)	;	//T2亮度


//2025.11.16.110525//xi.hy//自动聚焦_偏移自调整处理
void KS_OffsetAutoCtl(float i_rBase, //基线
						float* i_prOffset,//偏移
						float i_rBaseTar,//目标基线
						float i_rKp,
						float i_rKd,
						int16_t i_iTimeAdjust_ms,//调整周期
						int16_t* i_piError_Pre,//上一次的偏差
						uint8_t i_byMaxRsData,//粗采样最大值
						uint8_t i_xLimitOut,//是否需要处理输出值
						float i_fScale_Down//输出值缩小比例
						);

//2025.11.28.094727//自动聚焦_偏移自调整封装
void KS_OffsetAutoCtl_T1T2(uint8_t i_xEn,//调整使能
							uint8_t i_xLocalAxisRollerDn,//压辊状态
							uint16_t* i_puiSwitchAndState_OffsetCtl,//偏移自调的开关及状态
							uint8_t i_xFlag_Print,//印刷状态
							float i_rVel_Axis,//轴速度
							float i_fGirth,//版周长
							uint16_t* i_puiCtlTime_OffsetAutoCtl,//偏移自调控制时间计数
							uint8_t i_uiBase_Tar_OffsetCtl,//目标基线
							float i_fBaseLine_T1,//T1基线
							float i_fBaseLine_T2,//T2基线
							float* i_pfOffset_T1,//T1偏移
							float* i_pfOffset_T2,//T2偏移
							float i_fKp_T1,
							float i_fKd_T1,
							float i_fKp_T2,
							float i_fKd_T2,
							uint8_t i_byMinRsData_T1,//T1粗采样最小值
							uint8_t i_byMinRsData_T2,//T2粗采样最小值
							uint8_t i_byMaxRsData_T1,//T1粗采样最大值
							uint8_t i_byMaxRsData_T2,//T2粗采样最大值
							uint16_t* i_puiTime_xBaseDone_OffsetAutoCtl,//基线稳定多久计数
							uint32_t* i_pdwRemainTime_OffsetCtl//本次调整持续时间计数
							);

//2025.12.01.163024//xi.hy//自动聚焦_光源自调整处理
void KS_SourceLightAutoCtl(uint8_t i_xEn,//总使能
				uint16_t i_uiPeakValue_T1,//T1当前波门内峰值
				uint16_t i_uiPeakValue_T2,//T2当前波门内峰值
				float* i_pfSourceLight_T1,//T1光源地址
				float* i_pfSourceLight_T2,//T2光源地址
				uint8_t* i_pbyRoundData_T1,//T1粗采样数据地址
				uint8_t* i_pbyRoundData_T2,//T2粗采样数据地址
				uint16_t* i_puiCtlTime_SourceLightCtl,//光源控制时间计数地址
				float i_fGirth,//版周长
				int16_t i_iGateSa,//波门地址
				uint16_t i_uiGateWidthmm,//波门宽度
				uint16_t i_uiSearchWidthmm,//查找宽度，不包含波门
				uint8_t i_xFollowT1,//跟随T1有效幅值
				uint8_t i_byBaseLine_T1,//T1基线
				uint8_t i_byBaseLine_T2,//T2基线
				float i_fKp,//光源调整kp
				float i_fKd,//光源调整kd
				uint16_t* i_puiTime_PeakDone_SourceAutoCtl,//光源控制到目标时间计数地址
				uint32_t* i_pdwRemainTime_SourceCtl,//本次光源自调持续时间计数地址
				uint8_t i_xFlag_Print,//印刷状态
				uint16_t* i_puiResultFilter_PeakCur,//滤波后的当前峰值
				uint8_t* i_pxFindRSPeak_SourceLightCtl,//允许从粗采样中查找峰值标志/必须在粗采样有效之后
				uint16_t* i_puiSwitchAndState_SourceLightCtl//开关及状态地址
				);

//2025.11.28.161834//xi.hy//月光宝盒Pro 自动聚焦处理
void KS_AutoFocusCtl_MoonPro(uint8_t i_xEn,
							StGrpParam* i_pstStGrpParam,
							StAxisParam* i_pstStAxisParam,
							StGlobalParam* i_pstStGlobalParam,
							uint8_t* i_pbyRoundData1,				//粗采样T1_R起始地址
							uint8_t* i_pbyRoundData2,				//粗采样T2_R起始地址
							uint8_t* i_pbyRoundData3,				//粗采样T1_G起始地址
							uint8_t* i_pbyRoundData4,				//粗采样T2_G起始地址
							uint8_t* i_pbyRoundData5,				//粗采样T1_B起始地址
							uint8_t* i_pbyRoundData6,				//粗采样T2_B起始地址
							uint8_t* i_pxFindRSPeak_SourceLightCtl, //允许从粗采样中查找峰值标志/必须在粗采样有效之后
							uint16_t* i_puiCtlTime_OffsetAutoCtl,//偏移自调控制时间计数
							uint16_t* i_puiTime_xBaseDone_OffsetAutoCtl,//基线稳定多久计数
							uint32_t* i_pdwRemainTime_OffsetCtl,//本次调整持续时间计数
							uint16_t* i_puiCtlTime_SourceLightCtl,//光源控制时间计数地址
							uint16_t* i_puiTime_PeakDone_SourceAutoCtl,//光源控制到目标时间计数地址
							uint32_t* i_pdwRemainTime_SourceCtl//本次光源自调持续时间计数地址
							);
#endif /* KS_FB_DACOUTCTL_H_ */
