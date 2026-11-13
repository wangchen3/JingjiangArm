#ifndef __KS_CALC_ARC_ERR_H
#define __KS_CALC_ARC_ERR_H



#include "ks_define.h"
#include "ks_arc_err_define.h"
#include "stdint.h"
#include "base.h"

#define GET_BIT16(v, b)   (((uint16_t)(v) >> (b)) & 0x01u)
#define GET_BIT32(v, b)   (((uint32_t)(v) >> (b)) & 0x01u)

//使用keil编译环境@结构体封装方式
//#define STM32_KEIL
#ifndef STM32_KEIL//c环境
	#pragma pack(1)//单字节封装
	#define __packed
#endif

//c环境编译
#ifdef __cplusplus
 extern "C" {
#endif

/*****************************************数据结构***********************************************************/

//套色状态bit
typedef __packed struct tagArcErrStsBit
{	
	uint16_t xLost:1;//丢失
	uint16_t xAlarm:1;//报警
	uint16_t xNormal:1;//正常
	uint16_t xFake:1;//飞点
	uint16_t reserved_1:12;
}ArcErrStsBit,*LP_ArcErrStsBit;

//套色误差计算结构体控制bit,标记按照那种方式计算误差-16bit
typedef __packed struct tagArcErrCtlBit
{	//低8bit 控制计算
	//单眼方式下@和原来波门正逆序保持一致,当前色所在的那路信号
	uint16_t calc_follow_any_eye1:1;//单眼跟踪任意色。
	//双眼方式下
	uint16_t calc_follow_pre_eye2:1;//双眼跟踪前一色
	uint16_t calc_follow_any_eye2:1;//双眼跟踪任意色@新方案
	uint16_t reserved_0:5;

	//高8bit 控制使用@只能有效一种
	//单眼方式下@和原来波门正逆序保持一致,当前色所在的那路信号
	uint16_t use_follow_any_eye1:1;//使用单眼跟踪任意色。
	//双眼方式下
	uint16_t use_follow_pre_eye2:1;//使用双眼跟踪前一色
	uint16_t use_follow_any_eye2:1;//使用双眼跟踪任意色@新方案
	uint16_t reserved_1:5;

}ArcErrCtlBit,*LP_ArcErrCtlBit;


//色标参数结构体
typedef __packed struct tagArcMarkParam
{
	uint8_t		uMarkType;//色标类型@梯形、矩形等
	uint8_t		uPolarityIsNegative;//正反信号标志@有效了为反信号，正极性@正常是1
	uint8_t		xInclNegative10vSignal;//双极性标志
	float		fMinimumSignalval;//信号最小值@v
	float		fSmallSignalval;//小信号的值@v
	float		fMinimumSignalval_Sample;//信号最小值@采样
	float		fSmallSignalval_Sample;//小信号的值@采样
	float		fSignalGate_Sample;//当前路用于小信号判断的采样阈值
	uint8_t     uScopeLevelNum;//默认=3
	float		afScopeLevelRatio[MAX_SCOPELEVEL_ARCMARK];//阀值比例,默认 0.25 0.5 0.7
	uint8_t		uFilterpoints;//数据滤波次数@默认=3
	
	uint8_t xUseInnerBase;        // 是否使用门内基线
	uint8_t xCalcBaselineTwice;   // 是否二次校准

	int      markHLen;          /* 梯形色标水平边长 */
	int      markVLen;          /* 梯形色标垂直边长 */

	uint8_t  uPolarityIsNeg_T1_Door1;   // bit5: T1在波门1中反极性
    uint8_t  uPolarityIsNeg_T2_Door1;   // bit6: T2在波门1中反极性
    uint8_t  uPolarityIsNeg_T1_Door2;   // bit15: T1在波门2中反极性
    uint8_t  uPolarityIsNeg_T2_Door2;   // bit16: T2在波门2中反极性
}ArcMarkParam,*LP_ArcMarkParam;

//色标信息结构体
typedef __packed struct tagArcMarkInf
{
	uint8_t		uId;//色序id@KSGetCurAndPrevDataInf逻辑获取(主要是跟踪色)
	float		fBaseLine;//基线值@用于运算误差
	float		fSignalEffectiveScope;//信号有效幅值
	float		fSignalGate_Sample;//当前路用于小信号判断的采样阈值
	int16_t		iPeakValuePos;//峰值位置
	uint16_t    uPeakRawValue; // 新增峰值，后续485要传wang.c 2026.4.22.192641
	uint16_t	uDataNum_Act;//实际使用的采样点数值@用实际精度和距离反算获得
	//(uint16_t* pauData)[MAX_FINESAMPLE_NUM];//采样数据指针@指向数组数据的首地址
	uint16_t	uDataIndex;//色标精采样数据的索引
	uint16_t*	puData;//采样数据指针@指向数组数据的首地址
	float       fDoorPosSa;//色标所在波门起始位置@mm|当前色和跟踪色必须相对同一个起点
	uint8_t		uIsT1T2Pos;//色标位置 T1/T2
	uint8_t     uPolarityIsNegative;  // 这一路实际使用的极性

	//3段阀值信息
	uint8_t		auFindIt_Frontedge[MAX_SCOPELEVEL_ARCMARK];//找到了前沿标志
	float		afPos_FrontEdge[MAX_SCOPELEVEL_ARCMARK];//前沿位置
	uint8_t		auFindIt_BackEdge[MAX_SCOPELEVEL_ARCMARK];//找到后沿标志
	float		afPos_BackEdge[MAX_SCOPELEVEL_ARCMARK];//后沿位置
	float		afWidth[MAX_SCOPELEVEL_ARCMARK];//色标宽度(位置差)
	float       horizontal_comp_ratio;//横向宽度补偿系数
	float       afWidthComp[MAX_SCOPELEVEL_ARCMARK];//补偿后的色标宽度




	//使用的阈值id
	uint8_t		uScopeLevelId;//阈值id
	uint8_t		uEdgeInf;//前后沿信息

	//滤波后数据
	uint16_t	auDataFilter[MAX_FINESAMPLE_NUM];//精采样数据数组@滤波后的值

}ArcMarkInf,*LP_ArcMarkInf;


//套色误差计算相关参数@正逆序、色标间隔……
//不区分纵横向
typedef __packed struct tagArcErrParam
{
	uint8_t				uMarkType;//色标类型@梯形、矩形等@整机
	uint8_t				uMarkArrangeType;//标记类型@顺序、逆序等@整机
	uint8_t				uMarkInterval;//色标间隔@默认20mm
	uint8_t				uArcDoorWidth;//套色波门宽度@mm
	float				fPrecision_Act;//计算误差使用的精采样精度@一个点对应的距离|mm
	uint16_t			(*pauFsDataSa1)[MAX_FINESAMPLE_NUM];//第一路精采样数据@数组指针
	uint16_t			(*pauFsDataSa2)[MAX_FINESAMPLE_NUM];//第二路精采样数据@数组指针
	float				fBase1,fBase2;//基线值
	//uint8_t				uCalcArcErrType;//计算套色误差的形式@判断计算纵向、横向、纵横向|逻辑获取
	uint8_t				uArcDoorType;//套色波门类型@单波门还是双波门|逻辑获取
	//float				fDoorInterval_mm;//标记所在波门的纵向间隔
	float				fGirth;//周长@mm
	//纵横向报警阈值@丝
	float				fAlarm_V;
	float				fAlarm_H;

	uint8_t             xSmallSignal_T1; // dwControlBits bit11
	uint8_t             xSmallSignal_T2; // dwControlBits bit12

	//从采样配置函数中获取
	uint16_t			auDoorPos[MAX_SAMPLE_DOOR_NUM];//波门位置值@采样设定的位置
	uint16_t			auDataNum[MAX_SAMPLE_DOOR_NUM];//数据点数@采样配置的值@精彩样点数|[0]代表第一波门|[1]代表第二波门(不使用则=0)
	//一些和横向相关的参数
	uint8_t				xCalcArcErrEn_H;//横向误差计算使能
	//纵向
	uint8_t				uArcId_V;//当前色id
	uint8_t				uArcFollowId_V;//跟踪色id@有可能会为0
	ArcErrCtlBit		stArcErrCtlBit_V;//套色误差跟踪方式
	//横向
	uint8_t				uArcId_H;//当前色id
	uint8_t				uArcFollowId_H;//跟踪色id@有可能会为0
	ArcErrCtlBit		stArcErrCtlBit_H;//套色误差跟踪方式

	uint8_t             xOMK_ReqCommit;   // 单标记确认按钮请求，由外部逻辑赋值

	
}ArcErrParam,*LP_ArcErrParam;


//套色误差计算相关信息@状态、误差值
//区分纵横向
typedef __packed struct tagArcErrInf{
	uint8_t				uFollowType;//跟踪方式
	int16_t				iArcErrCode;//套色误差计算错误码
	ArcErrStsBit		stArcSts;//状态
	int16_t				iErrValue;//误差值@对象是纵向变量,则为纵向误差|为横向变量,则为横向误差
	int16_t				iErrValue__;//误差值@对象是纵向变量,则为横向误差|为横向变量,则为纵向误差
}ArcErrInf,*LP_ArcErrInf;

typedef __packed struct{
	BYTE i_xIsValidError;
	INT i_iError_0_01mm;
	INT i_iVariationBaseValue;
	INT i_iBoundaryError_0_01mm;
	INT i_iErrorLevel_0_01mm;
	INT i_iVariationVariationMin;
	INT i_iVariationVariationMax;
}StPickOutFakePoint,*LP_StPickOutFakePoint;//飞点剔除输入变量

//恢复数据对齐方式
#ifndef STM32_KEIL//c环境
	#pragma pack()//
#endif
/*****************************************函数声明***********************************************************/
//结构体初始化
void KSInitArcMarkInf(LP_ArcMarkInf const pArcMarkInf);
void KSInitArcMarkParam(LP_ArcMarkParam const pArcMarkParam);
void KSInitArcErrInf(LP_ArcErrInf const pArcErrInf);
void KSInitArcErrParam(LP_ArcErrParam const pArcErrParam);
void KSInitArcErrStsBit(LP_ArcErrStsBit const pArcErrStsBit);
void KSInitArcErrCtlBit(LP_ArcErrCtlBit const pArcErrCtlBit);

//标记电压值转换为采样值
//2024.02.26.111525 小信号阀值
//008光电眼@10v供电	0--65535 对应0--10v
//012光电眼@+-10v供电，0--65535 对应-10v--10v
//使用双极性是否打开进行判断
float KSMarkVoltageToValue(float fVloltage,uint8_t uSignalType);

//整数循环取模@0---iMod变化
uint16_t KSLoopMod(int16_t iValue,int16_t iMod);


//获取精采样实际精度@丝
float KSGetActPrecision(const uint32_t sampleppr,//采样精度@4097152
						const float set_precision,//设置的精度值@默认0.02
						const float girth,//设置的周长@默认500mm
						const uint16_t n,//电机侧减速比|eg:5
						const uint16_t m);//版辊侧减速比|eg:1

//精采样数据滤波器@2024.8.26
void KSFsDataFilter_Copy(const ArcMarkParam* pArcMarkParam,LP_ArcMarkInf const pArcMarkInf);

//检查标记信息@返回标志指示是否相同色标
uint8_t KSCheckMarkInfIsSame(LP_ArcMarkInf const pstArcMarkInf_1,LP_ArcMarkInf const pstArcMarkInf_2);

//遍历采样数据获取阈值点
int16_t KSGetThresholdPosEx(const ArcMarkParam* pArcMarkParam,LP_ArcMarkInf const pArcMarkInf);

//获取色标的信息内容
void KSGetMarkInf(const ArcMarkParam* pArcMarkParam,LP_ArcMarkInf const pArcMarkInf);

//控制标志位获取
void KSArcErrCtlBitDeal(LP_ArcErrCtlBit const pArcErrCtlBit);

//获取实际使用的精彩样数据个数|返回实际使用的精彩样个数
//uDataSa 数据起始(从0开始)、uArcDoorWidth套色的波门宽度、fPrecision_Act实际精彩样精度值、uDataNum_Max 最大的数据个数
//int16_t KSGetDataNumAct(uint16_t uDataSa ,uint8_t uArcDoorWidth , float fPrecision_Act , uint16_t uDataNum_Max , uint16_t &uDataNum_Act);
int16_t KSGetDataNumAct(uint16_t uDataSa ,uint8_t uArcDoorWidth , float fPrecision_Act , uint16_t uDataNum_Max , uint16_t *puDataNum_Act);



//从精采样中获取当前色和跟踪色数据的信息
//色标位于哪路精彩样、精彩样地址、基线值、实际数据个数、使用的波门
int16_t KSGetCurAndPrevDataInf(uint8_t xIsHorInf,//获取横向计算的信息@否则获取纵向
	            LP_ArcMarkParam const pstArcMarkParam,
				LP_ArcErrParam  const pstArcErrParam,//套色误差计算参数
				//计算当前色和前一色的色标必要信息@精彩样数据指针
				LP_ArcErrInf	const pstArcErrInf,//只更新波门个数变量
				LP_ArcMarkInf	const pstArcMarkInf_Cur,
				LP_ArcMarkInf	const pstArcMarkInf_Follow);



//使用输入2个色标信息计算纵向偏差、横向偏差
//当前色和跟踪色做比较
//不计算就返回0,计算失败就返回丢失。
int16_t KSCalcErrByDataInf(
						//uint8_t xUseHorInf,//使用横向计算误差的色标信息|反之为纵向
						uint8_t xErrIsRev_V,//纵向误差取反
						uint8_t xErrIsRev_H,//横向误差取反
		
						LP_ArcErrParam pstArcErrParam,
						LP_ArcMarkParam pstArcMarkParam, 
						LP_ArcMarkInf pstArcMarkInf_Cur,
						LP_ArcMarkInf pstArcMarkInf_Follow,
						int16_t *piErr_V,//输出计算的纵向误差
						int16_t *piErr_H);//输出计算的横向误差

//根据输入的精采样数据进行套色误差计算
void KSCalcArcErr_VH(
				WORD* i_puiFineData1,
				WORD* i_puiFineData2,
				StAxisParam* i_pstStAxisParam,
				StGrpParam* i_pstStGrpParam,
				REAL i_alrBase[2],
				BYTE* i_pxOK_PosConfirmed,
				BYTE i_xOK_FromMaster,

				LP_ArcMarkParam const pstArcMarkParam,//套色标记的参数
				LP_ArcMarkInf	const pstArcMarkInf_Cur_V,//当前色标信息@纵向
				LP_ArcMarkInf	const pstArcMarkInf_Follow_V ,//跟踪色标信息@纵向
				LP_ArcMarkInf	const pstArcMarkInf_Cur_H,//当前色标信息@横向
				LP_ArcMarkInf	const pstArcMarkInf_Follow_H ,//跟踪色标信息@横向
				LP_ArcErrParam  const pstArcErrParam,//误差计算的参数
				LP_ArcErrInf	const pstArcErrInf_V,//纵向误差计算信息
				LP_ArcErrInf	const pstArcErrInf_H);//纵向误差计算信息

//套色参数获取函数
void KSCalcErrParamInter(
    WORD* i_puiFineData1,
    WORD* i_puiFineData2,
    StAxisParam* i_pstStAxisParam,
    StGrpParam* i_pstStGrpParam,
    REAL i_alrBase[2],
    BYTE* i_pxOK_PosConfirmed,
    BYTE i_xOK_FromMaster,
    LP_ArcMarkParam const pstArcMarkParam,
    LP_ArcErrParam  const pstArcErrParam);

float KSCalcBaseLineInner(
    const uint16_t* puiData,
    uint16_t uTotalPoints,
    uint8_t xIsNegPolarity,
    uint8_t xCalibrateTwice);

float KSGetBaseLineUse(
    const ArcMarkParam* pstArcMarkParam,
    const uint16_t* puiSampleData,
    uint16_t uTotalPoints,
    float fRawBase,
    uint8_t xIsNegPolarity);

	//飞点剔除
//增加横向飞点判断2023.5.24.103307

void KS_FB_PickOutFakePointV2_V(  StPickOutFakePoint stStPickOutFakePointIn,
	BYTE *o_pxFakeIsConfirmed);
//增加横向飞点判断2023.5.24.103307
void KS_FB_PickOutFakePointV2_H(  StPickOutFakePoint stStPickOutFakePointIn,
	BYTE *o_pxFakeIsConfirmed);
//平均
float KS_Average_copy(int8_t xAverageEn,
                      int16_t idata,
                      uint8_t byAverageNum,
                      int16_t aidatabuff[MAX_AVERAGE_NUM],
                      uint8_t* pbyCurIndex,
                      uint8_t* pxDataInitDne);

	
#ifdef __cplusplus
}
#endif


#endif



