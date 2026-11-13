//套色误差计算的宏定义
#ifndef __KS_ARC_ERR_DEFINE_H
#define __KS_ARC_ERR_DEFINE_H


#define MAX_FINESAMPLE_NUM	    3000//最大的精采样点数值@用于运算误差的
#define MAX_RSAMPLE_NUM			4000//最大粗采样点数
#define MAX_AVERAGE_NUM         20//环形缓存最大数量

//截尾平均总开关@2026.10.26(镜像自calcbase.h,本模块不包含该头文件,两处必须保持同值)
//1 = 平均改为截尾:选取"平均次数+2"个点(含当前值),去掉1个最大值和1个最小值后平均剩余点;
//    暖机期缓冲内有效值<4个时直接算术平均,>=4个即截尾(除以点数-2);作用于KS_Average_copy
//0 = 回退原算术平均|Yang.zj+ 2026.10.26.210016
#define KS_USE_TRIM_AVERAGE	1
#define MARK_TYPE_LINE			1//(*Line Mark|*)
#define MARK_TYPE_TRAPE_VFLP	2//(*Vert Forward Left Positive|*)
#define MARK_TYPE_TRAPE_VFLN	3//(*Vert Forward Left Negitive|*)
#define MARK_TYPE_TRAPE_VBLP	4//(*Vert Backward Left Positive|*)
#define MARK_TPYE_TRAPE_VBLN	5//(*Vert Backward Left Negitive|*)
#define MARK_TYPE_TRIANGLE_R	6//(*2018.8.28.135823\三角标-定点在右边|*)
#define MARK_TYPE_TRIANGLE_L	7//(*2018.8.28.135828\三角标-定点在左边|*)
//ENUM_MarkArrange
#define MARK_ARRANGE_VFOR	1//(*纵顺|*)
#define MARK_ARRANGE_VREV	2//(*纵逆|*)
#define MARK_ARRANGE_HFOR	3//(*横顺|*)
#define MARK_ARRANGE_HREV	4//(*横逆|*)
#define MARK_ARRANGE_OMK	5//(*单标记|*)

//2024.10.1.123414
#define SAMPLE_SINGLE_DOOR		0//单波门
#define SAMPLE_DOUBLE_DOOR		1//双波门
#define MAX_SAMPLE_DOOR_NUM		2//最大的采样波门个数@调整时需要确认初始化内容
#define SAMPLE_T1				1//T1信号
#define SAMPLE_T2				2//T2信号
#define SIGNAL_IS_NORMAL		0//正信号@反极性
#define SIGNAL_IS_NEGATIVE		1//反信号@正常信号
#define SIGNAL_VALUE_MIN		((float)0.2) //最小信号值@v
#define SIGNAL_VALUE_SMALL		((float)0.5) //小信号值@v
#define MARK_INTERVAL			20//色标间隔 20mm
#define MAX_SCOPELEVEL_ARCMARK	3//套色色标最大阈值个数@0.25 0.5 0.7|修改该值需要注意阈值数组的初始化
#define MAX_MARK_NUM			16//最大色标个数
#define UNCALC_ARCERR_VH        0//不计算纵横向误差
#define CALC_ARCERR_V			1//计算纵向误差
#define CALC_ARCERR_H			2//计算横向误差
#define CALC_ARCERR_VH			3//计算纵横向误差
//#define USE_MIDDLE_POS			0//使用中间位置
//#define USE_FRONT_POS			1//使用前沿位置
//#define USE_BACK_POS			2//使用后沿位置
#define ARC_ERR_LOST			-32768//丢失
#define ARC_ERR_FAKE			-32767//飞点
#define GET_MARKINF_VER			0//获取纵向标记的信息@当前色和跟踪色
#define GET_MARKINF_HOR			1//获取横向标记的信息@当前色和跟踪色
#define MARK_FRONTEDGE			0//前沿
#define MARK_MID				1//中部分
#define MARK_BACKEDGE			2//后沿

#define FOLLOW_PRE_EYE2			1//双眼跟踪前一色
#define FOLLOW_ANY_EYE1			2//单眼跟踪任意色
#define FOLLOW_ANY_EYE2			3//双眼跟踪任意色

#define MARK_IS_10VSIGNAL		0//单极性
#define MARK_IS_INCLNEGATIVE_10VSIGNAL  1//双极性


//使用距离计算精采样点数@定义成宏吧
#define KS_GET_FSPOINTS_BYDIS(DIS,RPRECISION_ACT)			((float)DIS/RPRECISION_ACT)//小心RPRECISION_ACT=0
//使用精采样点数计算距离@mm
#define KS_GET_DIS_BYFSPOINTS(FSPOINTS,RPRECISION_ACT)		(FSPOINTS * RPRECISION_ACT)
//使用粗采样点数计算距离@mm
#define KS_GET_DIS_BYRSPOINTS(RSPOINTS,GIRTH)				(GIRTH / MAX_RSAMPLE_NUM * RSPOINTS)
//根据双波门地址计算物理距离
//#define KS_GET_DIS_BYDOORPOS(DOOR_POS_CUR,DOOR2_POS_FOLLOW) ()

//错误信息记录
#define ARC_ERR_NONE						0     //没错误
#define NULL_POINTER						-1    //空指针
#define PARAM_INVALID						-2    //输入参数错误
#define ARC_ERR_CURID						-100  //色序id非法
#define ARC_ERR_FOLLOWID					-101  //跟踪色序id非法
#define ARC_ERR_FOLLOWTYPE					-102  //跟踪方式错误
#define ARC_ERR_MARKINTERVAL				-103  //色标间隔参数错误
#define ARC_ERR_PRECISION					-104  //色标采样精度错误
#define ARC_ERR_DOORNUM						-105  //波门个数错误
#define ARC_ERR_DATANUM_DOOR1				-106  //波门1中的数据个数错误
#define ARC_ERR_DATANUM_DOOR2				-106  //波门2中的数据个数错误
#define ARC_ERR_INVALIDFOLLOWTYPE			-107  //非法的跟踪方式
#define ARC_ERR_INVALID_MARK_ARRANGE		-108  //非法的标记顺序@
#define ARC_ERR_SAMPLEDATA_OVERFLOW			-109  //采样数据溢出

#define ARC_ERR_SIGNAL_SMALL				-200  //色标信号太小了
#endif
