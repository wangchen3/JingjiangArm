/*
 * AutoFindTaps.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef AUTOFINDTAPS_H_
#define AUTOFINDTAPS_H_

#include "base.h"

#define MAX_DATA_NUM_FINDTAPS 4000

#pragma pack(1)
typedef struct{
	uint8_t abyData_Sample_Temp[3];//用于滤波的临时数组
	short iStatue_Find_Signal_Step;//用于判断每个点处于上升沿还是下降沿等状态
	short iStep_Single_or_Double_Mark;//判断当前是出于什么位置
	short iNum_Positive;//统计上升沿的临时变量
	short iNum_Negative;//统计下降沿的临时变量
	short iNum_Mid;//统计顶部拐点的临时变量
	short byFlag_FirstSignal_Negative;//=0第一个标志未找到=1第一个是上升沿=2第一个是下降沿（有色标跨零位）
	uint8_t abySampData_Filtered[4000];//滤波过后的数据
	signed char asiSampData_FirstDerivative[4000];//一次求导结果
	short aiPosValue_Signal_Start[100];//找到的每个色标的起始位置
	short aiPosValue_Signal_End[100];//找到的每个色标的结束位置
	short aiPosValue_Signal_Width[100];//找到的每个色标的宽度
	short aiPosValue_Signal_Positive[100];//找到的每个色标的上升沿点数
	short aiPosValue_Signal_Negative[100];//找到的每个色标的下降沿点数
	short aiPosValue_Signal_Mid[100];//找到的每个色标的顶部点数
	uint8_t byNum_Signal;//找到的色标数目
	short aiDetal_Signal[100];//色标间隔

}StAutoFindSignalDetail;//(*两组波门内部信号的分析细节|*)

typedef struct{
	float i_rGirth;
	uint8_t i_byMarkTypeId;
	uint8_t i_byMarkArrangeModalId;
	uint8_t i_byColorId;
	uint8_t i_byFlag_AutoRun_Arc;/*
								bit0:全自动套印使能
								bit1:本色组是否有特殊标记
								bit2:本色组特殊标记是否与前面色组相同
							*/
	uint8_t i_bySpecialMark_1_Width;//特殊标记1宽度-单位：点数
	uint8_t i_bySpecialMark_2_Width;//特殊标记2宽度-单位：点数
	uint8_t i_bySpecialMark_3_Width;//特殊标记3宽度-单位：点数
	uint8_t i_bySpecialMark_1_2_Width;//特殊标记1-2宽度-单位：点数
	uint8_t i_bySpecialMark_2_3_Width;//特殊标记2-3宽度-单位：点数
	short i_iSpecialMark_3_Signal_Width;//特殊标记2-3宽度-单位：点数

	float arDetal_Signal_Input[3];//(*三角标-数字圆圈-色标-三角标两两间隔*)
}StAutoAlignment_Input;//(*两组波门内部信号的分析细节|*)

typedef struct{
	uint8_t o_iNum_Signal;//色标数量
	short o_iPos_Cur_Signal;//当前色位置
	short o_iPos_Pre_Signal;//前色位置
	uint8_t o_byFlag_FindSignal;//标志位bit0:单组色标位置找到了-第一组bit2:混色的位置找到
}StAutoAlignment_Output;//(*两组波门内部信号的分析细节|*)
#pragma pack()

void KS_FB_FindSignal(
		uint8_t* i_pbyData,//数据起始
		short i_iLength,//数据长度
		float i_rBase_Positive,//数据判断阀值
		StAutoFindSignalDetail* i_pstStAutoFindSignalDetail
);

#endif /* AUTOFINDTAPS_H_ */
