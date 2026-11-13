/*
 * markDetection.h
 *
 *  Created on: Jan 9, 2026
 *      Author: 11744
 */
#ifndef MARKDETECTION_H_
#define MARKDETECTION_H_
#include <string.h>
#include <math.h>
//#include "KS_FB_RoundSample.h"
//#include "modbus485.h"
#include "calcerr.h"
#include "KS_FB_VISU.h"
#include "StSample.h"

/* 全自动套印色标检测(markDetection)总开关(编译期)
 * 1 = 启用:编译本模块,main.c每周期调用KsAutoFindSignal(入口i_xEn守卫已被原作者
 *     注释,实际门控在nMainMatlabInterfaceFixed_New内的xFlag_AutoAdj_En状态机)
 * 0 = 屏蔽:本模块整体不编译(零代码/零RAM),main.c的include与调用点一并剔除,
 *     完全回退原行为(仅少了对xFlag_FindFirstSuccess/xFlag_FindPreSuccess的持续清零,
 *     两标志本就保持初值0,行为等价);启用时本宏改1重新编译即可,代码完整保留未删除
 * |Yang.zj+markDetection封编译宏 2026.11.13.120400 */
#define USE_MARK_DETECTION	0

//#define SAMPLE_POINTS 4000
#define MAX_SIGNALS 30 //信号个数
#define MAX_CLUSTERS 30 //簇个数 注意，使用位域，6位最大到63，不可大于63
//#define MAX_CLUSTER_SIZE 12 //簇大小
#define CLUSTER_RADIUSMM 3.0 //聚类半径mm
#define MIN_NEIGHBORS 1 //最小聚类点数,因为代码逻辑不包含当前点，设置成1时核心点的最少点数是2
#define MARKTEMP_COUNT 4//模版色标个数，目前为4 原因是，三个标为引导标，另外一个为三角标
#define REPEAT_SEARCH_ROUNDS 4//重复寻找圈数
// 在文件开头添加定义
#define AMPLITUDE_TOLERANCE 0.3f  // 幅值相对容差，30%
#define USE_NEW_DBSCAN
#define DEBUG_Mode
#define RSDATADEAL(VALUE) ((int8_t)VALUE + 128) //双极性粗采样处理@byte型数据
// ================== 调试开关 ==================
//#ifdef DEBUG_PRINT
//#define PRINT_INFO(...) printf("[INFO] " __VA_ARGS__)
//#define PRINT_DEBUG(...) printf("[DEBUG] " __VA_ARGS__)
//#define PRINT_ERROR(...) printf("[ERROR] " __VA_ARGS__)
//#define PRINT_WARNING(...) printf("[WARNING] " __VA_ARGS__)
//#else
//#define PRINT_INFO(...)
//#define PRINT_DEBUG(...)
//#define PRINT_ERROR(...)
//#define PRINT_WARNING(...)
//#endif

#pragma pack(1)

// ================== 类型定义 ==================
// 信号检测状态枚举：定义状态机可能的状态
typedef enum
{
    STATE_IDLE = 0,// 空闲状态，等待信号开始
    STATE_IN_SIGNAL, // 处于信号内部
    STATE_SIGNAL_END, // 信号刚结束，短暂停留状态
    STATE_IN_GAP, // 在信号间隔中
} SignalStateEnum;

// 状态机结构体
typedef struct
{
    SignalStateEnum eState;// 当前状态机状态
    short nSignalStart;// 当前信号的起始位置索引
    short nSignalEnd;// 当前信号的结束位置索引
    short nSignalCenter; // 当前信号的中心位置索引
    short nSignalWidth;  // 当前信号的宽度（单位：采样点数）
    unsigned char bSignalValid; // 当前信号是否有效（宽度满足要求）
    unsigned char bySignalCount;// 已检测到的有效信号数量

    // 信号幅值统计
    unsigned char bySignalStartValue;  // 信号起始点的值
    unsigned char bySignalEndValue;    // 信号结束点的值
    unsigned char bySignalMinValue;    // 信号区间内的最小值
    short nSignalMinPos;      // 最小值位置
    unsigned char bySignalAmplitude;            // 信号有效幅值

    // 内外窗口统计
    unsigned int unInnerWindowSum;   // 内部窗口和
    unsigned int unOuterWindowSum;   // 外部窗口和
    unsigned int unInnerWindowCount; // 内部窗口计数
    unsigned int unOuterWindowCount; // 外部窗口计数


    unsigned int unBackgroundCount; // 背景点数计数
} SignalStateMachineT;

// 信号信息结构体
typedef struct
{
    short nStart; // 信号起始位置索引
    short nEnd; // 信号结束位置索引
    short nCenter; // 信号中心位置索引
    short nWidth; // 信号宽度（单位：采样点数）
    short nRadius; // 信号半径（宽度的一半）
    unsigned char bySignalMinValue;//信号极值
    short nSignalMinValueId; // 信号极值索引起始位置索引
    unsigned char byAmplitude;//信号幅值
    unsigned char bValid; // 是否有效（通过宽度过滤）
} SignalInfoT;

// 信号列表结构体
typedef struct
{
    SignalInfoT astSignals[MAX_SIGNALS];// 信号数组，最多存储MAX_SIGNALS
    unsigned char byCount; // 实际有效的信号数量
} SignalListT;

// 轻量级DBSCAN节点结构
typedef struct {
    short nPoint;               // 点的位置索引
    float fScore;              // 匹配分数
    unsigned char bCore : 1;   // 是否为核心点
    unsigned char bVisited : 1; // 是否已访问
    unsigned char byCluster : 6; // 所属簇ID (0-31, 0表示噪声点)
} LightDbscanNodeT;

// 簇统计信息结构
typedef struct {
    unsigned char bySize;      // 簇大小
	short nCenter;            // 计算得到的中心点
	unsigned char bValid;      // 簇是否有效
	float fAverageScore;       // 平均分数
} ClusterStatT;

// 轻量级DBSCAN结构体
typedef struct {
    LightDbscanNodeT astNodes[MAX_SIGNALS];  // 所有节点数组
    ClusterStatT astClusterStats[MAX_CLUSTERS];  // 簇统计信息
    short nClusterRadiusPoint;       // 聚类半径点数
    unsigned char byNodeCount;       // 节点总数
    unsigned char byClusterCount;    // 簇总数
    unsigned char byBestCluster;     // 最佳簇索引
} LightDbscanT;

// 标记模板结构体
typedef struct
{
    unsigned char byMarkType; // 标记类型（顺/逆序等）
    unsigned char byColorId;// 颜色ID
    float fSimilarityThreshold;// 相似度阈值，低于此值不考虑匹配

    unsigned char bySignalCount; // 模板中信号总数量
    short anMidPoints[MARKTEMP_COUNT]; // 信号中点位置数组MAX_SIGNALS
    short anRadii[MARKTEMP_COUNT]; // 信号半径数组MAX_SIGNALS
    unsigned char abyPercentages[MARKTEMP_COUNT];// 宽度百分比数组MAX_SIGNALS
    short nTotalWidth;// 模板总宽度

    //signed char achMarkIds[5]; // 标记点ID（对应模板中的索引，-1表示无效）
    short anRelativePos[MARKTEMP_COUNT];// 相对于第一个信号的偏移量MAX_SIGNALS

    short anLabelPos[MARKTEMP_COUNT];// 检测到的标记点位置MAX_SIGNALS
    short anLabelRadius[MARKTEMP_COUNT]; // 检测到的标记点半径MAX_SIGNALS
    unsigned char abySignalMinValue[MARKTEMP_COUNT]; //信号极值
    short anSignalMinValueId[MARKTEMP_COUNT]; //信号极值位置
    char cFound;// 是否成功找到标记（1=成功，-1=失败，0=未处理）
} MarkTemplateT;

// 信号检测器结构体
typedef struct
{
    float fGirth;  // 版周（单位：mm）
    char cMeanOffset; // 均值偏移量
    short nMinWidth; // 最小信号宽度（过滤用）
    short nMaxWidth;// 最大信号宽度（过滤用）
    short nMaxGap;// 最大信号间隔

    // 窗口大小
    short nInnerWindowSize; // 内部窗口大小
    short nOuterWindowSize; // 外部窗口大小

    SignalStateMachineT stStateMachine; // 信号检测状态机
    SignalListT stSignalList;// 检测到的信号列表
    double dBackgroundStd;   // 背景标准差
    unsigned char bNeedRecalc; // 是否需要重新计算参数
    short anCurLabelPosTemp[REPEAT_SEARCH_ROUNDS];//存储本色四圈位置
    short anPreLabelPosTemp[REPEAT_SEARCH_ROUNDS];//存储本色四圈位置
    float rOuterCoff; // 外滑窗系数
    float rInnerCoff;// 内滑窗系数
    float rSpotWidth;//光斑宽度
} SignalDetectorT;

// 输入参数结构体
typedef struct
{
    unsigned char *pabyImageData; // 图像数据指针
    int nDataLength;// 数据长度

    float fGirth; // 版周
    char cMeanOffset;// 均值偏移
    short nMinWidth;// 最小宽度
    short nMaxWidth;// 最大宽度
    short nMaxGap;// 最大间隙
    float fBaseLine; //当前通道基线

    unsigned char byCurMarkType;// 当前颜色标记类型
    unsigned char byCurColorId;// 当前颜色ID
    signed char byCurTriangleMarkId;// 当前颜色三角形标记ID
    signed char byCurSpecialMarkId;//  当前颜色特殊标记ID
    float fCurSimilarityThreshold;// 当前颜色相似度阈值
    unsigned char byCurSignalCount;// 当前颜色信号数量
    short *paiCurModeMidPoint;// 当前颜色位置中心位置点数数组
    unsigned char*pabyCurModeRadius;// 当前颜色半径数组
    unsigned char *pabyCurPercentages;// 当前颜色百分比数组
    //signed char *pachCurMarkIds; // 当前颜色标记点ID数组

    unsigned char byPreMarkType;// 前一个颜色标记类型
    unsigned char byPreColorId; // 前一个颜色ID
    signed char byPreTriangleMarkId;// 前一个颜色三角形标记ID
    signed char byPreSpecialMarkId;// 前一个颜色特殊标记ID
    float fPreSimilarityThreshold; // 前一个颜色相似度阈值
    unsigned char byPreSignalCount;// 前一个颜色信号数量
    short *paiPreModeMidPoint;// 前一颜色位置中心位置点数数组
    unsigned char*pabyPreModeRadius;// 前一颜色半径数组
    unsigned char *pabyPrePercentages;// 前一个颜色百分比数组
   // signed char *pachPreMarkIds; // 前一个颜色标记点ID数组
} MatlabInputT;

// 输出结果结构体
typedef struct
{
	WORD uiRSampleCounter;//当前使用的粗采样计数
    short anCurLabelPos;// 当前颜色标记点位置
    short anCurLabelRadius; // 当前颜色标记点半径
    char cCurFound; // 当前颜色是否找到标记

    short anPreLabelPos;// 前一个颜色标记点位置
    short anPreLabelRadius;// 前一个颜色标记点半径
    char cPreFound; // 前一个颜色是否找到标记

    unsigned char byDetectedSignalCount;// 检测到的信号数量
} MatlabOutputT;

#pragma pack()
//状态机处理单个采样点
void vProcessSample(SignalStateMachineT* pstStateMachine, unsigned char bySample, unsigned char byPreSignalData,
                   unsigned char bIsSignal, short nPosition,
                   short nMinWidth, short nMaxWidth, short nMaxGap,unsigned char xFlag_SlaveUseCmm_Pro,unsigned char xInclNegative10vSignal);
//内外滑窗二值化处理
unsigned char bDualWindowBinarization(SignalDetectorT *pstDetector,
                                      const unsigned char *pabyData,
                                      short nPosition,
									  unsigned char xFlag_SlaveUseCmm_Pro,
									  unsigned char xInclNegative10vSignal,
                                      unsigned char bUpdateWindows);
//内外滑窗处理信号帧
void vProcessDualWindowFrame(SignalDetectorT *pstDetector, const unsigned char *pabyData ,unsigned char xFlag_SlaveUseCmm_Pro,unsigned char xInclNegative10vSignal);
// 初始化内外滑窗检测器
void vInitDualWindowDetector(SignalDetectorT *pstDetector,
                             float fGirth, char cMeanOffset,
                             short nMinWidth, short nMaxWidth, short nMaxGap);
//初始化标记模板
void vInitMarkTemplate(MarkTemplateT *pstTemplate,
                       unsigned char byMarkType, unsigned char byColorId,
                       float fSimilarityThreshold);
//添加模板信号
unsigned char bAddTemplateSignal(MarkTemplateT *pstTemplate,
                                 short nStart, short nEnd,
                                 unsigned char byPercentage,
								 unsigned char byAmendmentTemp);
// 预计算相对位置
void vPrecomputeRelativePositions(MarkTemplateT *pstTemplate);

//构建标记位置
void vBuildMarkPositions(const MarkTemplateT *pstTemplate, short nBasePosition,
                         short *panPositions);
//查询模板与检测信号的重叠度
short nQueryOverlap(const SignalListT *pstSignals, short nCenter, short nRadius);
//计算模板匹配度
float fCalculateTemplateMatchNew(const MarkTemplateT *pstTemplate,
                                 short nTestCenter,
                                 const SignalListT *pstSignals);
//计算单个模板信号与检测信号的重叠度
short nCalculateSingleSignalOverlap(short nTmplCenter, short nTmplRadius,
                                    short nOffset, const SignalListT* pstSignals);
//计算模板整体重叠度
float fCalculateTemplateOverallOverlap(const MarkTemplateT* pstTemplate,
                                      short nOffset,
                                      const SignalListT* pstSignals);
//检测标记
void vDetectMarksWithNewMatching(const SignalDetectorT* pstDetector,
                                const unsigned char* pabyData,
                                MarkTemplateT* pstTemplate,
                                MarkTemplateT* pstResult);
// 从MATLAB输入创建模板
void vCreateTemplateFromMatlabInputFixed(const MatlabInputT *pstInput,
                                         unsigned char bIsCurrent,
                                         float fGirth,
                                         MarkTemplateT *pstTemplate,
										 unsigned char byAmendmentTemp);
//主MATLAB接口函数
int nMainMatlabInterfaceFixed(const MatlabInputT *pstInput, MatlabOutputT *pstOutput ,StGlobalParam* i_pstStGlobalParam,uint8_t byArcSensorType);

/**
 * @brief 独立运行主函数
 * @param argc 参数个数
 * @param argv 参数数组
 * @return 返回码
 */
int KsAutoFindSignal(uint8_t* pbyRoundData1,				//粗采样T1_R起始地址
		uint8_t* pbyRoundData2,				//粗采样T2_R起始地址
		uint8_t* pbyRoundData3,				//粗采样T1_G起始地址
		uint8_t* pbyRoundData4,				//粗采样T2_G起始地址
		uint8_t* pbyRoundData5,				//粗采样T1_B起始地址
		uint8_t* pbyRoundData6,				//粗采样T2_B起始地址
		unsigned char i_xEn,
		REAL i_alrBase[2],
		uint8_t bySignalSelect,
		StAxisParam* i_pstStAxisParam,
		uint8_t byArcSensorType //传感器类型
			);
#endif /* MARKDETECTION_H_ */

