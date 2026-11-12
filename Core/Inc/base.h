/*
 * base.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef BASE_H_
#define BASE_H_

#include "sys.h"
//#include "arm_math.h"

//#define MAX_STATION_NUM 32
#define MAX_STATION_NUM_AOYIN 32 //凹印最大站个数
//BASE库全局常量
//(*系统中对PI的统一约定|*)
#define gc_lrPI	3.1415926																//: LREAL := 3.1415926;
//(*2019.4.8.140649|将固定的参数合并到库文件中|*)
#define gc_dwMotorPPR 2097152													//: DWORD := 2097152;(*电机每转的脉冲数|2^21|*)
#define gc_dwSamplePPR 4194304												//: DWORD := 4194304;(*采样脉冲数|2^22|*)
//(*有关通讯部分使用的标志约定||*)     								     //
#define gc_iMemNodeItemMax 512													//: INT := 512;(*主站与副主站通讯的最大内存区块节点数量|*)
#define gc_iMaxErrDataItemInList 100												//: INT := 100;(*误差传递功能的最大存储误差幅数数量|*)
#define gc_iMailboxBlockLen	128													//: INT := 128;(*Mailbox通讯单帧数据字节量大小|*)

#define gc_dwSemaphoreDownLink 0x12345678								//: DWORD := 16#12345678;(*下行旗语-数据来自主站|*)
#define gc_dwSemaphoreUpLink 0x87654321									//: DWORD := 16#87654321;(*上行旗语-数据来自副主或色组|*)
#define gc_dwSemaphoreRequestDispatch 0x51515151					//: DWORD := 16#51515151;(*请求旗语-请求主站重新派发指定数据包|*)
#define gc_dwSemaphoreDownloadCopy 0x13572468						//: DWORD := 16#13572468;(*状态旗语-下载副本数据中|*)
#define gc_dwSemaphoreDownloadCopiesDone 0xA1A2A3A4			//: DWORD := 16#A1A2A3A4;(*状态旗语-副本数据下载完成|*)
#define gc_dwSemaphorePlsDeputyRequestAgain 0xA781220A			//: DWORD := 16#A781220A;(*反向请求旗语-通知副主站重新提交下载数据请求|*)
#define gc_dwSemaphoreSpecialRequest 0x19781220						//: DWORD := 16#19781220;(*特定旗语-附加请求使用|*)
#define gc_iValueReferToLost -32768												//: INT := -32768;(*误差标识-丢失|*)
#define gc_iValueReferToFakePoint -32767										//: INT := -32767;(*误差标识-飞点|*)
#define gc_iValueReferToSkipTheHeader -32766								//: INT := -32766;(*误差标识-让料头|*)

//2024.06.05.091237 超时时间减短到200ms@宏定义的是次数，每次是10ms
//#define gc_485_TimeoutNum 20//50														//超时计次
//#define gc_Count_CommNum 2														//主从通讯执行周期
//#define gc_Count_CalcBaseNum 50												//计算基线周期计次

// 2025.7.22.101817|wei.n|移植
//2025.11.5.125359 验证了time3的周期为10ms,调整宏定义
//#define gc_485_TimeoutNum 20														//超时计次 100ms
//#define gc_Count_CommNum 4														//主从通讯执行周期 20ms
//#define gc_Count_CalcBaseNum 100												//计算基线周期计次 500ms
//#define gc_Count_FeedDogNum 100													//喂狗周期计次 500ms
//2025.11.5.125429 修改后
#define gc_485_TimeoutNum 			20														//超时计次 200ms
#define gc_Count_CommNum 			2														//主从通讯执行周期 20ms
#define gc_Count_CalcBaseNum 		50												//计算基线周期计次 500ms
#define gc_Count_FeedDogNum 		50													//喂狗周期计次 500ms


#define SMG_ADR 0x792											//数码管控制地址

//当前通道选择宏定义
//宏定义修改为0 1 2代表RGB@2025.7.26.160233+
#define CURR_VISU_R 0
#define CURR_VISU_G 1
#define CURR_VISU_B 2
#define T1 1
#define T2 2
//CHANNEL_RGB 通道选择信息@包含T1 T2
//ID =1获取T1当前通道 =2获取T2当前通道@a通道在高4bit|b通道在低4bit@我们定义T1是a通道(高4bit),T2是b通道(低4bit)
#define GET_CUR_CHANNEL_RGB(CHANNEL_RGB,ID) (ID==2 ? (CHANNEL_RGB & 0x0F) : ((CHANNEL_RGB & 0xF0) >> 4))

//#define DEBUG_TEMP
//重要~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//双波门
//还存在波门叠在一起的情况下，精采样起始地址获取有问题，误差计算也是有问题的！并不严重，后期更新。
//重要~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//重要~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//版本号命名规则：如1125020810
/////前两位10代表kill版本的arm，11代表stm32版本的arm
/////250208代表修改日期-25年2月8日10点
//重要~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#define DWVERSION 4126111212
//在0421版基础上移植新飞点剔除(Theil-Sen)+双置信度融合(wang.c/Yang.zj 2026.11.9~11.10)
//移植内容:Kesai_Process新增ks_fly_remove/ks_conf_err,calcerr/ProSample/VISU挂接(编译须用Release配置,镜像≤128KB)
//未移植:全自动套印(markDetection/36#37#通讯/模版)等6~8月改动

//#define DWVERSION 1126042115
//KS_CalcErr_ARC_New 函数屏蔽(.c .h)
//KS_Singal_Process 函数屏蔽(.c .h)
//KS_GetSignalDetails 函数屏蔽
//粗采样美化处理
//2026.4.23.150945+
//HAL_GPIO_WritePin(RS485_TX_EN_GPIO_Port, RS485_TX_EN_Pin, GPIO_PIN_RESET);
//默认接收使能@默认发送使能时会引起上电乱发数据
//arm支持对误差显示平均@2026.4.25.134939

//#define DWVERSION 1126031113
//替换热风2为排风控制,485通讯也按照热风2地址。增加排风mail的上行通讯

//#define DWVERSION 1126013114
//byUnLockHmi_UI主从通讯@35#命令,以及arm的通讯

//#define DWVERSION 1125120119
//增加arm升级中标志的pdu通讯@35#，用于控制关闭主mail的执行
//在主站不和我pdu通讯时 我把mail读写也关了@为了不影响arm升级
//mail不通讯使用stStGlobalParam->xStopMailComm变量控制
//副主站通讯中也增加了检查pdu是否通讯的处理,副主站也会led1闪烁,增加副主站的版本号mail通讯@2025.12.3.150139+

//#define DWVERSION 1125112916
//死循环检查主站dsp是否启动逻辑中增加1s sleep处理。在主程序未启动时候可能会引起arm升级失败

//#define DWVERSION 1125111716
//双波门采样配置bug修复

//#define DWVERSION 1125110513
//time3 time2中断函数针对错误的宏使用修改
//time2 为1ms中断
//time3 为10ms中断
//系统时钟APB1分频系数由原来的RCC_HCLK_DIV2->RCC_HCLK_DIV4
//系统时钟APB2 分频系数由原来的RCC_HCLK_DIV1->RCC_HCLK_DIV2

//#define DWVERSION 1125102809
//mailbox通讯删除容易混淆变量,轴参数同步删除,485通讯没用的变量也干掉了|如果存在问题则复现测试
//comm中KS_FB_SyncWithServer函数增加pdu下行通讯异常标志处理(共享内存参数中),他异常就认为整机通讯异常
//@控制取消485通讯|用于光电眼和光纤切换时人机指示区分
//对获取站号的函数增加延时,防止获取错误的站号240@这个站号现在是合法的.
//2025.10.31.100210 为了兼容光纤和光电眼的切换|16d驱动器站号会超过31,pdu上行的地址超限改为了轴id偏移
//2025.11.4.092703  GT_RN_SetSenceDO屏蔽设置

//#define DWVERSION 1125102408
//增加色标传感器类型选择mail通讯.人机通讯还未处理@只到arm处

//#define DWVERSION 1125101709
//StCMD_06 通讯获取的横向编码器值扩展为24bit
//警告优化

//#define DWVERSION 1125092611
//增加33#命令通讯从站485控制变频器类型字,人机通讯也已经处理
//和月光宝盒代码同步，尽可能保持一样。
//2025.9.24
//解决第一次上电时候,主站参数未全部更新,进入配置采样逻辑引起的配置采样异常问题。
//main函数中的结构体变量移动到全局！！！

//#define DWVERSION 1125072609
//采样配置函数中处理波门内精彩样个数统计
//main函数中双极性数据处理的精彩样循环个数优化

//#define DWVERSION 1125071518
//起始波门条件<3999 偶发出现波门地址为3999时导致人机参数不能被修改|一直处于485写入。
//正负10v信号精彩样处理的上限值从1000定值修改为变量

//#define DWVERSION 1125060514
//同步主站的33# 5# 6#命令的修改@comm.h
//通讯代码修改@comm.c
//油墨槽升降功能实现(主函数20ms周期任务执行)@2025.6.10-2025.6.12
//base.h中增加相关数据类型,增加ks_somefunc.c\.h文件

//#define DWVERSION 1125052014
//单标记误差确认非得大范围移动波门后才能再次确认。

//#define DWVERSION 1125042514
//增加权限的通讯获取以及人机的通讯

//#define DWVERSION 1125020810
//增加副主站中英文切换变量的通讯
//#define DWVERSION 2025010415
//取消KS_CfgAxisSampleParam_New的调用，将里面的内容同步到KS_CfgAxisSampleParam中,使用输入参数切换
//#define DWVERSION 2024121609
//通讯了周期超时计数到人机，用于监控！
//#define DWVERSION 2024112608
//2024.11.26.085654 调整串口2的优先级@提高抢断优先级
//#define DWVERSION 2024091914
//2024091914||这个版本主要确认了一些默认值，采样精度位，采样精度等，保证切换回原来的计算误差方法是可以直接用的不能影响正常功能；
//2024091409||恢复5#命令通讯版本号
//2024090215||2024.9.2.093340|峰值滤波方法
//485溢出中断2024.8.30.143909
//横向误差计算的严重bug
//增加了基线通讯给主站保存
//2024.8.24.163319飞点剔除问题bug修复
//2024.8.22.110150增加间接跟1色误差计算----------
//同步青岛华康的修改@通讯精采样点数、采样算法配置方式变量(还没使用)
//#define DWVERSION 2024073101
//增加飞点阈值的通讯,最大飞点阈值可以达到50

//#define DWVERSION 2024063001
//StGlobalParam 结构体中byCurrUsrLevel变量在31号副主站命令中赋值
//从站和上个版本逻辑未变

//#define DWVERSION 2024060701
//ks_get_prgcrash_inf中memset个数优化处理

//#define DWVERSION 2024060501
//485人机通讯超时从原来的500ms缩短到了200ms

//#define DWVERSION 2024052901
//2024052901||重新处理人机界面粗采样显示曲线拉低问题|niu.j
//comm.c中重新处理5 6 7号命令的轮询实现，并增加了6#命令的控制通讯标志位@dwControlComplexBits.27(全局状态)
//#define DWVERSION 2024041401
//副主站的485发送逻辑中增加了初始化buff处理,新增加的wButton_Uw未被成功通讯

//#define DWVERSION 2024031103
//单标记按下的时候，清零修正量@03是因为汇通韩利新材料同样的更新使用了01 02版本

//#define DWVERSION 2024022601
//修改小信号幅值大小-重新处理对应值。

//#define DWVERSION 2024021901
//2024.2.17.092907 王宁涛增加了跟踪某一色处理，以及跟踪某一色变量的通讯
//2024.02.19微调并增加注释

//#define DWVERSION 2024020101
//增加死机监控人机通讯以及抓取信息逻辑实现
//优化了485发送通讯备份值在读取后未更新的问题。

//#define DWVERSION 2024013001
//2024013001||2024.1.30.150324||niu.j||处理一下界面显示数字波形用的基线都用粗采样基线，防止打开门内基线后无显示波形问题
//20240111||看门狗计数值通讯取消@解决再初次因为该值变化触发的从站往主站写值的问题。有一定概率多个从站通讯导致mailbox通讯fifo满
//GT_RN_DevicePcMailComRd 函数返回值判断@主从通讯以及主和副主站

//#define DWVERSION 20231108
//处理io监控的通讯内容|主从通讯使用33#命令

//#define DWVERSION 2023101201
////2023.10.12.165703||niu.j|修复精采样基线bug
//优化了精采样计数值的赋值位置。在触发一次精采样的时候将计数值写入到轴参数中@由于增加了6号命令的轮询会导致计数值被修改
//5 6号命令都通讯精采样计数
//#define DWVERSION 20230918
//同步小吴的全自动套印代码@在华丰优化过的.并修改了接口,确保和套色动态库中的函数一致
//修改了05号命令的内容。wStatusRef.12作为了纵向使用跟踪第一色/前一色标计算误差-TRUE=跟踪第一色-FALSE=跟踪前一色
//增加放料屏按钮通讯
//#define DWVERSION 2023080701
//优化发现的获取采样函数有一定概率引起精采样数组越界引起死机的问题@根据黄工指示修改。
//#define DWVERSION 2023080302
//上个版本修改的内容遗漏了一个地方@2023.08.03.173658位置
//#define DWVERSION 2023080301
//将comm.c中计算实际采样距离的代码移动到双波门条件外，在使用单波门的时候也计算实际距离(单个采样点)
//#define DWVERSION 2023080201
//修复纵向跟踪第一色的时候波们重叠时计算出错处理。
//#define DWVERSION 2023070602
//同步全自动套印函数AutoFindTaps@小吴
//#define DWVERSION 2023070301
//2023.6.30.111009||更新采样配置，双波门时候第二个波门的精采样偏移计算不对，现已修正-后续更新内容请参考comm.c里KS_CfgAxisSampleParam函数的相关改动
//2023.5.18.171951||增加程序计数发于人机和主站
//2023.5.11.163528||全自动套印
//2023.4.27.143826||更新计算误差部分-增加计算任意色误差
//2023.3.29.175456||全部重新保存为UTF8格式||重新编译
//2023.3.7.164304}||新增放牵人机数据读取非0判断
//2022.12.6.111726重新处理副主站通讯2022120601
//2022.7.18.152417||横向跟随1色
//2022062101||2022.6.21.091520||增加副主站通讯-
//2022061001||2022.6.10.185058||修正量发送判0
//2022060801||计算色标间隔使用色序号，非轴号
//采样波形最小值2022.6.2.153056  2022060201
//2022052602||继续优化一键对版
//2022.5.23.112128||韩工优化计算粗采样误差
//2022.5.21.170457||增加一键对版保护
//2022.5.17.084656||单眼模式-计算粗采样误差
//2022.5.13.114600、|双极性波形
//2022.5.12.143607||判断LED屏保时间更新，同步下发485；
//2022041301|| 增加粗采样计算跟1色误差2022.4.13.151211

//2022033101||2022.3.31.143434||更新06和36里通讯变量类型
//2022032601||2022.3.26.111440||36#通讯出错
//2022032501||2022.3.25.095700北人相关通讯内容新增
//	2022030101		2022.3.1.111715增加计算完成后的阀值传到主站，不需要基线

//2021.10.28.084600||增加奥特马兼容相关协议以及通讯变量||2021102801
//2021.9.29.154445|wang.st|屏蔽对aReturn[2]的复用操作

//#define DWVERSION 2021090901
//2021.9.9.011336清除上溢中断
//2021.9.9.011142||循环执行三次配采样--  ||2021090901
//2021082401||2021.8.24.152011||整理从站程序
//1.发送取消循环队列形式
//2/接收数据CRC计算更新到每个字节
//3.标志切换
//4.数据填到软件发送缓冲区后，开始定时器1ms，定时到后发送第一个字节进入发送中断
//注4：根据Modbus手册提示，两个数据帧之间间隔必须大于3.5个字节，目前测试出来时间》800us，定时器定时1ms
//5.处理读取响应case增加default处理-跳转到case1;
//6.处理人机波形数据移除粗采样完成标志if，防止低速时候移动波形等操作必须等下一圈才处理，使反应变慢。
//7.485更新为取消100ms任务，有读取响应后就进入发送逻辑
//8.提高485中断优先级，降低外部中断优先级

//2021071601||2021.7.16.150041||取消超时逻辑--
//更改为100ms计时到，有响应就处理响应，发送下一条指令，如果没有响应，发送当前指令，连续三次未读到响应直接发送下一条指令
//2021062501||2021.6.25.105459||波门宽度更新
//2021062301||2021.6.23.094341||修复超时计算问题，原本判断==6，容易错过，改>=6
//2021061701||2021.6.17.151514||新增发送基线及切换原始波形显示到从站
//2021061601||2021.6.16.152817||修复发送原始波形中±10V信号处理。
//2021.6.16.152911||||||人机界面波形平移和放大不太正常，平移是相对波门中间位置，放大当基础设定波门32时，版周长增加，波门缩小方向不对，导致波门置位不对等
//2021061001||2021.6.10.162500原是波形
//2021030401||2021.3.4.094659测试发送原始波形
//2021010601||2021.1.6.111021||关于处理精采样基线以及小信号的波门内处理
//2020122101||2020.12.21.105842||波形左右移动移出范围处理
//2020121901||上电初始化一遍两档开关
//2020121801||重新处理MCGS按钮通讯逻辑
//2020121401||增加从站阀值每一色自己选择
//2020121101||增加昆仑通态相关温度设置，反馈，排风，回风，进风主-从-屏通讯相关逻辑
//2020120501||2020.12.5.170635||HMI按钮
//2020111902||2020.11.19.165220||负调整量计算整形处理
//2020111901||2020.11.19.132619快速对版负调整量问题
//2020110501||从站版本按通讯周期发往主站
//2020101501||反极性人机界面图标默认值
//2020092801||增加横向放大功能-待测试
//2020092401||更新黄工StSample.c库
//2020072001||下发压辊状态，配套威伦屏2020072001程序使用
//2020071601||//485单向通讯下发6208bit12压辊状态
//2020070202||报警信息通信2020.7.2.164824
//2020070201||2020.7.2.142004||485更新语言切换和系ID切换
//2020063001||增加看门狗喂狗逻辑和看门狗复位计数通过mailbox发往主站
//2020062901||2020.6.29.170923||增加反极性切换从站通讯动作
//2020062401||单元盒的单标记功能处理
//2020062302||画图指针不对
//2020062301||根据反极性判断采样波形显示0和1的条件选择
//2020062001||增加快速對版相關通訊邏輯
//2020061701||发送纵向快速对版量清零回返值
//2020061302||误差数组读取位置同样存在索引超限问题
//2020061301||2020.6.13.140431||数组超限，>20更改为>=20
//2020061002||横向开关关闭，误差上报0
//2020061001||反极性波形处理&单标记处理
//2020060902||修改单标记功能，增加单标记确认误差完成标志
//2020060901||前个周期波门位置为static静态变量
//2020060802||增加485通讯受主从通讯控制，只有从站接收到主站完整数据，刷新485人机界面
//2020060801||niu.j||版周长更新后，波门占据的像素点数更新，需要重新发送一次波门
//2020060603||重新修改上溢中断清除逻辑
//2020060602||出现485上溢中断监控other+1
//2020060601||修复上溢错误导致的485中断死循环；recivend标志清除问题；继续测试//超时标志
//2020060511//测试程序-测试死机问题，写本地内存，由9色读取
//2020060301Version:V1.0版本;
//2020060301Version:自动寻址、单标记相关修改;
//202053001|niu.j|发送版周长和套色标记形式等到界面 2020053001
//2020.5.28.162022|niu.j|新增Getbit和Setbit函数  2020052802
//2020.5.28.110659|niu.j|防止修正量由于精度问题每次修改的值不是5  2020052801
//2020052001VerSion:将从站版本号发往主站;
//2020052101VerSion:远程升级程序;
//2020052401Version:修改精采样保存按钮逻辑

#define CALCERR_TIME PFout(0)//bit0计算误差时间计算
#define TIME_ADJUST PFout(1)//1ms定时器时间检查
#define ABS(x) ((x)>=0?(x):-(x))
#define ABS_SUB(a,b) (((a)>(b)) ? ((a)-(b)) : ((b)-(a)))// 2022.5.23.103856/+

//2025.7.22.105410|wei.n
//VALUE_POSTIVE(正值) 四舍五入
#define KS_ROUND(VALUE_POSTIVE) 	((VALUE_POSTIVE - (uint32_t)VALUE_POSTIVE)>=0.5 ? \
								(uint32_t)VALUE_POSTIVE + 1 : (uint32_t)VALUE_POSTIVE)

#define USE_KEIL5_IDE 0
#ifndef FALSE
#define FALSE (0)
#endif
#ifndef TRUE
#define TRUE (1)
#endif
typedef unsigned long DWORD;
typedef unsigned short WORD;
typedef short INT;
typedef float REAL;
//尽量少用double,新增加的函数使用LREAL,将宏改成float
//typedef double LREAL;
typedef float LREAL;
typedef unsigned char BYTE;
typedef signed char SINT;
typedef signed int DINT;
typedef char STRING;

#pragma pack(1)


//2025.6.11.225858+

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

typedef enum {
	MSG_NONE=0,//(*无意义*)
	MSG_ZEROINVALID=1,//(*零点非法*)
	MSG_BASEINFINVALID,//(*基准信息未确认*)
	MSG_MOVEDIS_OUTLIMTIT,//(*运动距离超限*)
	MSG_UPLIMIT,//(*上限位*)
	MSG_DNLIMIT,//(*下限位*)
	MSG_MOVEFAILED,//(*运动失败=6*)

	MSG_UPING=200,//(*向上运动中*)
	MSG_DNING//(*向下运动中*)
}TypeEnumInkGrooveMsg;

//和主站相比较，做了删减，只把从站使用的封装起来了
typedef struct{
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

	TypeEnumInkGrooveMsg iMsg			;//(*信息 |=1 零点丢失
												//|=2 未确认基准
												//|=3 距离超限
												//|=4 上限位
												//|=5 下限位
												//|=6 速度模式下,运动异常*)
	DINT diThisMovedPulse				;//:DINT;(*本次运动的距离@脉冲*)
	REAL rThisMovedDis					;//:REAL;(*本次运动的距离@mm*)
	WORD wLastPulse_Act_Rd_1			;//:WORD;(*实际读取的脉冲数记录@上一拍|用于计算本次运动的而距离值*)
	BYTE abyReseved[11]					;//:ARRAY [1..11] OF BYTE;

}StInkGrooveCtl,*Lp_StInkGrooveCtl;



typedef struct{
	INT iStationId;					//站号
	INT iAxisId;				//轴ID
	//----------------------------------------------------//
	REAL lrAdjust_V;			//向版误差修正
	REAL lrAlarm_V;             //(*纵向报警值|*)
	INT iAverage_V;             //纵向平均值
	REAL lrDeadzone_V;          //纵向不工作区
	DWORD dwKpid_V;             //纵向PID
	//-----------------------------------------------//
	REAL lrAdjust_H;            //横向版误差修正
	REAL lrAlarm_H;             //横向报警值
	REAL lrDeadzoneMin_H;       //横向最小不工作区
	REAL lrDeadzoneMax_H;       //横向最大不工作区
	INT iAverage_H;             //横向平均值
	DWORD dwKpid_H;				//横向PID
	//-----------------------------------------------//
	INT iGateSa;                //(*波门地址0~3999|*)
	INT iGateSaEx;              //(*波门地址2|0~3999|*)
	WORD wStatusRef;            //(*bit0=1纵向自动;bit1=1横向自动*)
								/*
								(*
									bit0=1纵向自动;
									bit1=1横向自动
									bit2·bit7:预留
									bit8=1	纵向跟指定色开关
									bit9=1	横向跟指定色开关
									bit10=1 纵向单眼模式	@主要用于跟踪前一色|2023.6.6.105941
									bit11=1 横向单眼模式	@主要用于跟踪前一色|2023.6.6.105941

									bit12=1 纵向使用跟踪第一色色标计算误差-反之使用前一色色标计算|2023.09.14.102543
									bit13=1 横向使用跟踪第一色色标计算误差-反之使用前一色色标计算2023.09.14.102543
									//2024.8.22.094752增加
									bit14=1  纵向使用间接跟1色误差反之-默认使用前一色
									bit15=1  横向使用间接跟1色误差-
									*)
								*/
	DWORD dwControlBits;
//	(*控制位|
//														*特别声明:从2019.3.28.150846开始|这里所有的信息都是和色组进行双向通信控制的||
//														*.bit0: 2019.3.28.151420|保留(最早该位用来控制屏保开关|后改为时间0就是关闭屏保)||
//														(*2022.4.20.091520 将冷风和热风开关位移动到dwCtlBits_UnitBaseCraft中*)
//														//*.bit1: 2018.8.2.175203|冷风机开关使能位||
//														//*.bit2: 2018.8.10.090412|热风机开关使能位||
//														*.bit3: 2018.8.13.101534|轴刮刀使能||
//														*.bit4: (niu.j)GTSD16D-入门款单标记误差确认按钮
//														*.bit5: (niu.j)T1在波门1中反极性
//														*.bit6: (niu.j)T2在波门1中反极性
//														*.bit7: 2021.7.21.100506|加热开关使能位
//														*.bit8: 科赛精灵之眼do0|@2020.7.15.101238
//														*.bit9: 科赛精灵之眼do1|@2020.7.15.101238
//														*.bit10: 色组纵向修正量操作方向取反（纵向不区分自动和手动状态）/TRUE:取反生效（默认 FALSE 关闭）
//														*.bit11: T1要求处理小信号|@2020.11.6.161819
//														*.bit12: T2要求处理小信号|@2020.11.6.161819
//														*.bit13: 联动按钮|2021.10.18.091852
//														*.bit14: 色组横向修正量操作方向取反（横向打开且在横向自动状态时）/TRUE:取反生效（默认 FALSE 关闭）
//														*.bit15: T1在波门2中反极性|@2020.11.6.161603
//														*.bit16: T2在波门2中反极性|@2020.11.6.161603
//
//											./17~./20|取消原来的定义(原来的定义未使用)@2025.4.25.164130
//														*.bit17: 色组加速按钮|2021.7.28.085453
//														*.bit18: 色组减速按钮|2021.7.28.085453
//														*.bit19: 色组停机按钮|2021.7.28.085453
//														*.bit20: 色组预热温控通讯正常@Altma|2021.7.19.161824
//											2025.4.25.164146 新定义@控制从站界面是否显示:
//														*.bit17: 色组递墨辊界面控制使能
//														*.bit18: 色组刮刀界面控制使能
//														*.bit19: 色组热风界面控制使能
//														*.bit20: 色组加热界面控制使能
//
//
//														*.bit21: 色组递墨辊通讯正常@Altma|2021.7.19.161824
//														*.bit22: 色组递墨辊故障复位@Altma|2021.7.21.121745
//														*.bit23: 色组递墨辊正转@Altma|2021.7.21.114815
//														*.bit24: 色组递墨辊反转@Altma|2021.7.21.114823
//														*.bit25: 预热温控使能@Altma|2021.7.20.142146|当前色组连接预热温控标志
//														*.bit26: 轴modbus功能打开@Altma|2021.7.19.174852
//														*.bit27: 色组温控通讯正常@Altma|2021.7.19.161824
//														*.bit28: 温控开关@Altma|2021.7.19.161218-未使用
//														*.bit29: 色组递墨辊的运行中@Altma|变频返回(*2021.7.21.114802 修改*)
//														//*.bit30: 色组递墨辊手自动控制|源于博创色组的485控制递墨辊功能|@2020.11.5.110044
//														*.bit30: 温度取自pt1000传感器还是编码器选择标志@FALSE=PT1000@TRUE=编码器温度
//														*.bit31: 2020.5.19.111938|TRUE=桢正电机热敏电阻类型采用PT1000(宁波亿思特电子有限公司)|FALSE=NTC原||
//														|*)

	DWORD dwAlarmDetail;        //(*报警明细|*)(*将dwAlarmDetail分为两部分,High-2Bytes-做标志用;Low-2Bytes做报警码来用。*)
	BYTE byGrpId;               //(*1=A系;2=B系|*)
	WORD wSwitchRef;            //(*开关位|
									//*.bit0  横向开关
									//*.bit1  门内基线
									//*.bit2  T1在门1中的极性(FALSE正;TRUE反)
									//*.bit3  T2在门1中的极性(FALSE正;TRUE反)
									//*.bit4  纵向电机调整正反
									//*.bit5  横向电机调整正反
									//*.bit6  双波门
									//*.bit7  单标记电机调整正反
									//*.bit8  二次印刷
									//*.bit9  电眼信号-10V~+10V
									//*.bit10 波门锁定开关|
									//*.bit11 T1小信号
									//*.bit12 T2小信号
									//*.bit13 T1在门2中的极性(FALSE正;TRUE反)
									//*.bit14 T2在门2中的极性(FALSE正;TRUE反)
									//*.bit15 色组反印
									//|*)
	BYTE xThisUnitEna;          //(*本色组套色开*)
	BYTE iMarkTypeId;            //(*标记形式|见'ENUM_MarkType'*)
	BYTE iMarkArrangeModal;      //(*标记排列形式|见'ENUM_MarkArrange'*)
	REAL lrGirth;               //(*版周长*)
	INT iGateWidthPhy;          //(*波门宽度mm|*)
	INT iGateWidthRondPt;       //(*波门占据的粗采样点数|*)
	INT iGateWidthFinePt;       //(*波门占据的精采样点数|*)
	INT iGateWidthFinePt_Act;       //实际的波门内配置的精彩样点数@有可能会和设置的不一样在配置函数里会重写|2025.7.26.091904+
	WORD uiNum;                 //(*减速比分子(当前参与运算的)|*)
	WORD uiDen;                 //(*减速比分母(当前参与运算的)|*)
	WORD wSts_HorzManuPreReg;   //(*横向手动预套准状态标志|*)
	INT iPos_HorzManuPreReg;    //(*横向手动预套准位置|*)
	INT iSampleCfgParam_Ctl;		//采样控制位
	BYTE byColorIdCurrent;      //     当前色序
	WORD wButtonFun;//2020.12.5.134437ann ./15作为死机时获取信息标志@2024.02.01.153909
	WORD wButtonFunChoose;//按钮功能选择通讯35#
	//以下指示用来归类方便，与主站轴参数无任何关系2020.12.11.104812

	//2025.10.28.165322 屏蔽容易混淆的内容
	//WORD wInkRoller_Fre				;//递墨辊频率
	WORD wAirInletWindDoorValue		;//进风口风门开度值|输入范围(0~100)
	WORD wAirExhaustWindDoorValue	;//排风口风门开度值|输入范围(0~100)
	WORD wAirReturnWindDoorValue	;//回风口风门开度值|输入范围(0~100)
	//2025.10.28.165322 屏蔽容易混淆的内容
	//WORD wTemperature_Set           ;//加热温度设置PV
	//WORD wTemperature_Feedback          ;//加热温度反馈值|2020.12.11.094135
	BYTE bySampleSholdSwitch		;//从站阀值选择开关
	WORD wUpAdjButton_Count     ;//MCGS调整上按钮计数
	WORD wDnAdjButton_Count;//MCGS调整下按钮计数
	WORD wLeftAdjButton_Count;//MCGS调整左按钮计数
	WORD wRightAdjButton_Count;//MCGS调整右按钮计数
	WORD wAlarmButton_Count;//MCGS报警按钮计数
	WORD wMCGS_SingleSwitch;//MCGS单向开关

	//2025.10.28.165322 屏蔽容易混淆的内容
	//2021.10.27.093855新增奥特马兼容
	//REAL rHz_AxisInkRoller_ManuallySet		 ; //(* ?REAL|??????????|??:Hz|@2020.11.6.142249 *)
	//REAL rCoeff_AxisInkRoller_Automatic		 ; //(* ?REAL|?????????|@2020.11.6.142249 *)
	//REAL rHz_AxisAirBlowning_ManuallySet	 ; //(* ?REAL|???????????|??:Hz|@2020.11.6.142249 *)
	//REAL rHz_AxisAirExhaust_ManuallySet		 ; //(* ?REAL|???????????|??:Hz|@2020.11.6.142249 *)

	//(* 2021.4.5.135550/????????? *)
	WORD wRsved000								;// ;
	//WORD wSV_TemCtrl							;//	: ; (* ????/????? *)
	//(*2021.7.19.094259  word->int|Liu.yt*)
	//INT iPV_TemCtrl								;//; (* ????/??? *)
	//WORD wSTS_TemCtrl							;//: ; (* ????/???? *)

	//(*2021.7.20.143520|?????-?????-???????????? *)
	//WORD wSV_TemCtrl_PreHot						;// ; (* ????/????? *)
	//INT iPV_TemCtrl_PreHot						;//: ; (* ????/??? *)
	//WORD wSTS_TemCtrl_PreHot					;//	: ; (* ????/???? *)

	//WORD wAxisInkRollerErr_485						 ;//;(*2021.7.21.115419 ?????????|485????*)
	//BYTE byAxisRoller_UpperFrq						 ;//;
	//REAL rAxisRoller_Frq								 ;//;

	//2022.3.19.170115
	DWORD dwCtlBits_UnitBaseCraft;//对应StAxisParam.dwCtlBits_UnitBaseCraft
	WORD wHz_UnitInkRoller_ManuallySet;//StAxisParam.rHz_UnitInkRoller_ManuallySet*100
	WORD wCoeff_UnitInkRoller_Auto;//StAxisParam.rCoeff_UnitInkRoller_Auto*100
	WORD wHz_UnitScraper_ManuallySet;//StAxisParam.rHz_UnitScraper_ManuallySet*100
	WORD wCoeff_UnitScraper_Auto;//StAxisParam.rCoeff_UnitScraper_Auto*100
	WORD wHz_UnitHotWind;//StAxisParam.rHz_UnitHotWind*100
	//WORD wHz_UnitHotWind_2;//StAxisParam.rHz_UnitHotWind_2*100
	WORD wSV_UnitTemCtl;//StAxisParam.rSV_UnitTemCtl*100

	REAL rHz_UnitInkRoller_CurrRD;//上报的递墨辊当前频率/实际从变频器内读取的值
	WORD wSTS_UnitInkRoller;//上报的递墨辊变频状态
	REAL rHz_UnitScraper_CurrRD;//上报的刮刀当前频率/实际从变频器内读取的值
	WORD wSTS_UnitScraper;//上报的刮刀变频状态
	WORD wSTS_UnitHotWind;//热风1变频状态
	//2026.3.11.090457替换为排风
	//WORD wSTS_UnitHotWind_2;//热风2变频状态

	REAL rHz_UnitInkRoller_CurrWR;//递墨辊当前下发频率/是需要写到人机里的
	REAL rHz_UnitScraper_CurrWR;//刮刀当前下发频率/是需要写到人机里的
	REAL rPV_UnitTemCtl;//主站下发的该色组当前温度
	WORD wSTS_UnitTemCtl;//主站下发的改色组当前温控状态
	REAL rHz_UnitHotWind_CurrRD;
	REAL rHz_UnitHotWind_CurrWR;//热风当前下发频率/是需要写到人机里的
	//2026.3.11.085726屏蔽
	//REAL rHz_UnitHotWind2_CurrRD;
	//REAL rHz_UnitHotWind2_CurrWR;//热风当前下发频率/是需要写到人机里的
	//2026.3.11.085310+通讯获取的排风反馈变量
	WORD wSTS_UnitExhaust;//从站通过485获取反馈到主站
	WORD wHz_UnitExhaust_CurrRD;//从站通过485获取反馈到主站
	WORD wHz_UnitExhaust_CurrWR;//主站写入到从站
	WORD wHz_UnitExhaust_ManuallySet;//设置值

	//2022.4.26.183241全自动一键套印增加变量
	REAL rPos_1mm_Round;//1mm距离对应采样点数

	BYTE byTaps_Mark_1_2;//单位0.1mm引导标12间隔
	BYTE byTaps_Mark_2_3;//单位0.1mm引导标23间隔
	BYTE byTaps_Mark_Width;//单位0.1mm引导标宽度
	BYTE byKCode_1;//1色KCODE标1宽度
	BYTE byKCode_2;//1色KCODE标2宽度
	BYTE byKCode_3;//1色KCODE标3宽度
	BYTE byKCode_1_2;//1色KCODE标1和2间隔
	BYTE byKCode_2_3;//1色KCODE标2和3间隔
	BYTE xFlag_FindFirstMark;//开始寻找当前色色标位置标志//压辊后经过大约800mm时间可以开始
	BYTE xFlag_FindPreMark;//开始寻找qianyise 色标位置标志//前一色经过一个机组料长后开始
	BYTE xFlag_AutoAdjust_Start;//自动套印状态

	INT aiPos_Cur_AutoAdj[4];//自动套印当前色色标位置-及引导标
	INT aiPos_Pre_AutoAdj[4];//自动套印前一色色标位置
	INT iPos_Value;//自动套印最终结果
	BYTE xFlag_FindFirstSuccess;//寻找当前色成功
	BYTE xFlag_FindPreSuccess;//找到前一色
	INT iARMRunNum;
	INT iKcode_Mark_Interval;
	INT iTaps_Mark_Interval;

	WORD wAccButton_Count;
	WORD wDecButton_Count;

	//2022.9.23.105230增加一键对版相关
	BYTE byFlag_CommFromMaster;//(*	bit0:??????
								//; bit1:TAPS???? *)
	BYTE xFlag_AutoAdj_En;
	BYTE xFlag_AutoAdj_Taps;
	REAL rWidth_Mark_Max;//单个色标最大宽度
	REAL rWidth_Mark_Min;//单个色标最小宽度
	REAL arDistance[5];//标记间隔
					   //[0]三角标-十字线
					   //[1]十字线-圆形标
					   //[2]圆形标-TAPS/0
					   //[3]Taps-色标/圆形标到色标
					   //[4]色标到三角标

	BYTE byFlag_FindSuccessful;//=1单色色标找到  =2混合色标找到
	INT iError_Msg; //0=无错误
					//-1~-100单色色标失败原因
					//-101~混色色标失败原因
	INT iSign_Number;
	BYTE xFlag_Gate_double;
	DINT diArgumentToXW;	//双波门时需要知道色标间距2023.4.27.085833
	INT aiVerror_Gate[2];//计算所得的真实误差纵向-0-跟前色-1-跟任意色
	INT aiHerror_Gate[2];//计算所得的真实误差横向-0-跟前色-1-跟任意色
	BYTE xFlag_Comm_05;//切换5号命令通讯内容--
	REAL lrInversedPrecision;	//系统实际精度
	//2023.5.18.152126增加通讯周期计数
	BYTE byCnt_Comm;//主从通讯计数-置于
	BYTE byCnt_VISU;

	//2023.09.19.155724+
	WORD uiFSampleCounter;//						: UINT;(*精采样计数值*)
	WORD uiRSampleCounter;//2025.7.23.200658+粗采样计数

	//2023.11.08.102528 同步
	// 2023.10.14.84809/wei.n/7吋人机色组IO与ARM通讯
	WORD wUnit_input_I; 				 //色组I输入
										   //Bit0: i_xLinkage; //联动
										   //Bit1: i_xInch;//单运行
										   //Bit2: i_xEstop; //急停输入
										   //Bit3: i_xAlarmBell; //警报
										   //Bit4: i_xLittleAdj; //细调
										   //Bit5: i_xPressMode_Auto; //自动合压
										   //Bit6: i_xPress;  //合压输入
										   //Bit7: i_xUnPress; // 离压输入
										   //Bit8: i_xUnPress_Inching; //点动离压
										   //Bit9: i_xMove_Up; //纵向上
										   //Bit10: i_xMove_Down; //纵向下
										   //Bit11: i_xPosLimit_Left; //横向左限位
										   //Bit12: i_xMove_Left; //横向左
										   //Bit15: wU_IO_Monitoring_Flag; // IO监控标志位

	WORD wUnit_input_II;	      //色组II输入
											//Bit0: i_xMove_Right；// 横向右
											//Bit1: i_xPosLimit_Right; //横向右限位
											//Bit2: i_xHorzMotor_FastSpd; //横向电机快
											//Bit3: i_xCoolBlower; //冷风开关
											//Bit4: i_xCoolBlower_Button; //冷风按钮
											//Bit5: i_xHotBlower_Err; //热风报警
											//Bit6: i_xHotBlower; //热风开关
											//Bit7: i_xHotBlower_Button; //热风按钮
											//Bit8: i_xTemReachToTarget; //温度达到预设
											//Bit9: i_xHeating_I; //加热I档
											//Bit10: i_xHeating_II; //加热II档
											//Bit11: i_xHeating_III; //加热III档
											//Bit12: i_xHeating_Button; //加热按钮

	WORD wUnit_input_III;       //色组III输入
											//Bit0: i_xScraperInveterError; //刮刀变频报警
											//Bit1: i_xScraperOn; //刮刀开关
											//Bit2: i_xAirExhaustSwitch; //排风开关
											//Bit3: i_xInkRoller_CW; //递墨辊正转
											//Bit4: i_xInkRoller_Up; //递墨辊上
											//Bit5: i_xAirExhaustButton; //排风按钮
											//Bit6: i_xAcc; //加速
											//Bit7: i_xDec; //减速
											//Bit8: i_xStop; //停机
											//Bit9: i_xFastStop; //快停
											//Bit10: i_xPtcSignal; //PTC过温
											//Bit11: i_xLostPressure; //顶板松

	WORD wUnit_output_I;        //色组I输出
											//Bit0: o_xLamp_Linkage; //联动指示
											//Bit1: o_xLamp_Inch; //单运行指示
											//Bit2: o_xLamp_Estop; //急停灯输出
											//Bit3: o_xLamp_Normal; //套色正常
											//Bit4: o_xLamp_Warning; //套色报警
											//Bit5: o_xLamp_Lost; //套色丢失
											//Bit6: o_xHorzMotor_CW; //横向正转输出
											//Bit7: o_xRel_ArcAlarm_Unit; //本组套色报警
											//Bit8: o_xRel_Press; //和压输出
											//Bit9: o_xHorzMotor_CCW; //横向反转输出
											//Bit10: o_xLamp_AxisError; //轴故障指示
											//Bit11: o_xRel_UnPress; //离压输出
											//Bit12: o_xRel_CoolBlower; //冷风输出

	WORD wUnit_output_II;	      //色组II输出
											//Bit0: o_xRel_HotBlower; //热风输出
											//Bit1: o_wInExhaustAir; //色组排风输出
											//Bit2: o_xRel_Heating_I; //加热I输出
											//Bit3: o_xRel_Heating_II; //加热II输出
											//Bit4: o_xRel_Heating_III; //加热III输出
											//Bit5: o_xScraperOn; //刮刀使能
											//Bit6: o_xRel_InkRoller_CW; //递墨辊正转
											//Bit7: o_xRel_InkRoller_Up; //递墨辊上
	BYTE byFollowColorId;

	//2024.7.31.171935+
	BYTE byFakeThreshold_V		;//: BYTE;(*纵向飞点阈值@丝*)
	BYTE byFakeThreshold_H		;//: BYTE;(*横向飞点阈值@丝*)
	BYTE byAve_v_extra_V			;//: BYTE;(*套色误差显示平均次数*)//纵横向用同一个值
	//2024.8.14.093257
	BYTE bySysSamplePrecision;//	: BYTE;(*系统套色采样精度-单位是丝@2024.8.7.160236+*)
	BYTE byArcFineSampleType;//			: BYTE;(*套色采样方式@=0默认波门宽度mm|还没使用呢*)
	//2026.4.21.153930 屏蔽
	//unsigned char xFlag_CalcErr_New;
	//输出监控变量
	short iResult_V_Followpre;
	short iResult_H_Followpre;
	short iResult_V_Follow_1U;
	short iResult_H_Follow_1U;
	//2026.4.21.154350 屏蔽不使用的
	//short iResult_V_Follow_1U_New;
	//short iResult_H_Follow_1U_New;

	//增加了滤波次数下发2024.8.31.153159
	unsigned short byFilterNum_PeakValue_FineData;

	//2025.6.5.142145+

	//(*2025.6.5.095933+ 16d脉冲输出控制相关变量*)
	//(*主->arm*)
	WORD wPulseCtlInf						;//(*脉冲控制的信息@速度模式就是速度值(0.1r/min),位置模式就是距离(丝-最大655mm)*)
	WORD wPulse_1r							;//1圈的脉冲数
	BYTE byPulseCtl_DisPerPulse				;//: BYTE;(*单位脉冲的距离(最大2.5um)@0.01um/pulse|最大输入就是0.025mm/pulse*)
	BYTE byPulseCtlBit						;//: BYTE;(*脉冲控制bit@bit0:反馈脉冲数清零
															//bit1:运动使能@再次使能才能启动下次运动
															//bit2:电机方向
															//bit3: 0：速度模式，1：位置模式(超过最大位置值|使用先速度后位置的方式)

							        						//*)
	//(*arm->主*)
	WORD wPulse_Rd							;//: WORD;(*执行的脉冲数@arm->主*)
	BYTE xPulse_Outing						;//: BOOL;(*脉冲输出中*)
	BYTE xInkGrooveInPos					;//位置模式到位标志
	//取值为255时按照1通讯
	BYTE byPulseOutSts						;//(*输出状态|=0 不输出|=1 输出@逻辑|=2反馈正在运行|=3异常|=255 准备写入@进入case*)

	REAL rInkGroovePosPPulse				;//(*单位脉冲的距离@mm/puls*)
	StInkGrooveCtl stStInkGrooveCtl;

	//(*2025.6.5.102348+横向控制增加编码器反馈方式*)
	BYTE byDriverType_Hor					;//: BYTE;(*横向的驱动类型(都是需要arm->主站方式获得编码器值)
												//	|0:默认同步电机\步进电机(不带反馈)-也就是不要编码器值
												//	|1:步进电机(带反馈)
												//	|2:汇川*)
	BYTE xEncValueIsValid_Hor						;//: BOOL;(*编码器值有效@arm从人机通讯来的*)
	BYTE xHorMotorAlarm							;//横向电机报警标志@arm从人机通讯来的
	DWORD dwEncValue_Hor						;//横向编码器值@通讯获取|按照4字节获取@2025.10.17.092113

	//2025.7.24.132529+
	BYTE xOK_PosConfirmed;//单标记确认
	BYTE xStartPlateAdjustmentProf;//快速对版标志
	DWORD dwPlateAdjustmentProf;//纵向快速对版量@发送到主站执行
	BYTE xStartHorRun;//横向运动标志
	INT iJourney_HorzRapidAdjust;//横向快速对版量@发送到主站执行
	BYTE xLocalAxisRollerDn;//压辊合压状态
	BYTE xLocalAxisLinkage;//轴联动状态
	BYTE xLocalAxisEstop;//本地轴急停
	BYTE byScreen;//界面屏保id
	float arBase_use[2];//2路使用的基线值@2025.7.25.210235+
	uint16_t uiPeakValue_t1,uiPeakValue_t2;//t1 t2的峰值
	//2025.9.26.112659+
	BYTE byDriverType_Hmi485;//					: BYTE;(*从站人机485递墨辊和刮刀等驱动器类型|
							//					默认:吉泰科;
							//					= 1: 汇川;
							//					.....*)

	BYTE xRsMorphFilter;//粗采样美化标志@2026.4.21.165754+
}StAxisParam;

typedef struct{
	WORD wCtlSwitchRef;			//(*整机控制开关描述|
									//*.bit0: 套色报警开关
									//*.bit1: 波门锁|根据色组来更新
									//*.bit2: 整机纵向自动| 2018.3.23.145133| han.dp|
									//*.bit3: 整机横向自动| 2018.3.23.145153| han.dp|
									//*.bit4: 开机等料长\2018.5.27.153018|
									//*.bit5: han.dp\2018.6.19.172042\联动采用非两档开关|
									//*.bit6: 2018.7.13.081355\使能标准3''6''纸管选择|TRUE按标准纸管走 FALSE按屏幕输入走|
									//*.bit7: 2018.7.3.194246\色组单独减速比设置|
									//*.bit8: 2018.7.23.143553\刮刀使能开关|
									//*.bit9: 2018.7.28.102401\递墨辊三档有效标志|(TRUE有效)|
									//*.bit10: 2018.8.13.101345\预加热印刷使能|
									//*.bit11: 2018.8.13.164527\预加热印刷使能|
									//*.bit12: 2018.8.15.082652\放料表印选择\默认FALSE=里印|
									//*.bit13: 2018.8.15.082652\收料表印选择\默认FALSE=里印|
									//|*)
	BYTE xMachineRev;           //(*整机反转;默认FALSE*)
	BYTE xUnitRev;              //(*色组反转;默认FALSE*)
	WORD wUwRwAxisProf;         //(*放料\收料 轴描述|
								//*.bit0 |放料当前轴A轴(TRUE)
								//*.bit1 |收料当前轴A轴(TRUE)
								//|*)
	BYTE xFlag_Print;           //印刷标志
	BYTE xFlag_Ink;           //空转标志
	BYTE xFlag_Estop;           //急停标志
	BYTE xFlag_Stop;           //停止标志
	BYTE byTriMark_SideC;       //(*梯形色标直边|*)
	BYTE byTriMark_SideB;       //(*梯形色标底边|*)
	REAL lrVelocity;			//速度

	REAL rGrp_Vel;//系当前速度
	DWORD dwAxisFlags_Estop;	//(*2019.8.19.175603|轴急停标志|*)

	//2022.6.29.145820
	WORD wSts_Print;//整机状态0:停机。1：运行；2：空转
	WORD wFlag_Estop;//0：急停 1；不急停
	WORD wLinkage_Print;//bit0_bit15对应1-16色
	WORD wHotWind_Print;//bit0_bit15对应1-16色
	WORD wAlarm_Print;//	bit0_bit15对应1-16色
	WORD wFlag_Stop;//0不停机1停机

	WORD bySts_Flag;//主站通讯的整机状态

	//放牵通讯变量2022.6.20.160312||2022.12.5.163300

	INT iGirth_Uw_A;//: INT; (*放A周长*)
	INT iGirth_Uw_B;//: INT; (*放B周长*)
	INT iGirth_Pu;//: INT;(*版周长*)
	INT iVelocity_Tar;//: INT;(*目标速度*)
	INT iAI_mid_Uw;//: INT;(*放料中位*)
	INT iAI_mid_If;//: INT;(*放牵中位*)
	BYTE byDir_Uw_If_AI;//: BYTE;(*放料放牵摆臂方向判断bit0:放料bit1:放牵*)
	WORD wKp_Uw;//: WORD;(*放料P*)
	WORD wKi_Uw;//: WORD;(*放料I*)
	WORD wKd_Uw;//: WORD;(*放料D*)
	WORD wKp_If;//: WORD;(*放牵P*)
	WORD wKi_If;//: WORD;(*放牵i*)
	WORD wKd_If;//: WORD;(*放牵d*)
	BYTE bySwitch_AutoCut_Uw;//: BYTE;(*放料自动裁切使能开关bit0:使能；bit1:剩余卷径方式bit2:剩余米数方式*)
	INT iDia_PaperRoller_Uw;//: INT;(*纸筒直径*10*)
	INT iFilmThickNess;//: INT;(*料模厚度*1000*)
	WORD wAutoMaticCutDia_Uw;//: WORD;(*剩余卷径方式卷径设定*)
	WORD wAutoMaticCutMeters_Uw;//: WORD;(*剩余米数方式米数设定*)
	WORD wActRemainFilmLenth_Uw;//: WORD;(*实际剩余料长-校正纸筒直径可用*)
	INT iAlarm_Uw_Dia ;//: INT;(*放料报警卷径设置*)
	INT iDelayMsec_CutterHolder;//: INT;(*刀架执行时间*)
	INT iDelayMsec_RollerCylinder;//: INT;(*压辊执行时间*)
	INT iDelayMsec_CutOffKnifeCylinder;//: INT;(*裁刀执行时间*)
	WORD uiMM_Roller2GummedTape;//: WORD;(*压辊胶带距离*)
	WORD uiMM_Roller2CutOfKnife;//: WORD;(*压辊裁刀距离*)
	WORD uiMM_CutOfKnife2GummedTape;//: WORD;(*裁刀胶带距离*)
	INT iCoefCut_FilmVolPerimeter_Uw;//:INT;(*放料裁切圈数*)
	INT iStepVariation4ChangeTime;//		: INT; (* 2018.9.30.100457/用来步进胶辊延时和裁刀延时的变化量 *)
	BYTE bySwitch_Compensate_Uw;//		: BYTE;(*放料翻转架补偿开关：Bit0:补偿开启,bit1:方向取反,bit2:0弧度确认*)
	WORD wDiam_Tower_Uw							;//: WORD;(*放料翻转架的直径|mm*)
	WORD wDiam_NextRoller_Uw				;//		: WORD;(*放料翻转架下个辊的直径|mm*)
	WORD wXPos_NextRoller_Uw				;//		: WORD;(*放料翻转架下个辊的X位置|mm|翻转架中心作为坐标系0点*)
	WORD wYPos_NextRoller_Uw				;//		: WORD;(*放料翻转架下个辊的Y位置|mm|翻转架中心作为坐标系0点*)
	WORD wDiam_DeflectorRoller_Uw		;//		: WORD;(*翻料架上导向辊的直径|mm*)
	WORD wDiam_DeflectorRollPos_Uw	;//			: WORD;(*ABjuli翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	BYTE byDiamMeasureTypeId;//: BYTE;(*卷径测量方式=0：电位器=1*)
	INT iStdVol_Diam_1;//: INT;
	INT iStdVol_Diam_2;//: INT;
	INT iStdVol_Diam_3;//: INT;
	INT iStdVol_Diam_4;//: INT;
	DWORD dwStdVol_Volt_AxisA_1;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_2;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_3;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_4;//: DWORD;
	INT iStdVol_Coef_Axis_1;//: INT;(* 卷径测量系数*1000 *)
	INT iStdVol_Coef_Axis_2;//: INT;
	INT iStdVol_Coef_Axis_3;//: INT;
	BYTE byIsDebug_DiaMeasureArea_Uw;//: BYTE;
	BYTE bySwitch_DiaMeasure;//: byte;(*bit0:自动卷径开关bit1:双轴biw2:弧面bit3:调试模式*)
	BYTE bySwitch_Enc_Uw;//: BYTE;(*放料编码器标定相关bit0:双轴系数bit1:调试模式
								//bit2:定位写入bit3:最小径写入*)

	WORD wFLAG_RUN; 	//WORD;(*
						//	/ bit0: 运行状态-停机
						//	/ bit1: 运行状态-空转
						//	/ bit2: 运行状态-印刷
						//	/ bit3: 运行状态-故障
						//	/ bit4: 运行状态-急停
						//	/ bit5: 放料当前轴
						//	/ bit6: 放料上下裁
						//	*)
	WORD wGRP_VEL;// WORD;(* 系当前速度*10 *)
	INT iDIAM_UW;//: INT;(* 放料当前直径 *)
	INT iDIAM_Pre_UW;//: INT;(* 放料预驱轴直径 *)
	INT iAI_IF;//: INT;(* 放牵摆臂*10 *)
	INT iAI_UW;//: INT;(* 放料摆臂*10 *)

	INT iCur_Rad_Uw;//: INT;(*放料翻转架当前弧度*10*)
	INT iAI_DIAMMEASURE_UW_CUR;//: INT;(* 监控值-电压*100 *)

	DWORD dwEncode_value;//:DWORD;(*当前编码器值*)

	BYTE byCurrUsrLevel;//: BYTE;
	INT iCOMPANYID;//: INT;(* 客户名称 *)
	DWORD	dwAxisALocation_Uw_U;//:;(*编码器定位放A*)
	DWORD	dwAxisBLocation_Uw_U;//:;(*编码器定位放A*)
	DWORD	dwAxisALocation_Uw_D;//:;(*编码器定位放A*)
	DWORD	dwAxisBLocation_Uw_D;//:;(*编码器定位放A*)
	DWORD	dwAxisALocation_MinDia_Uw_U;//:;(*编码器定位放A*)
	DWORD	dwAxisBLocation_MinDia_Uw_U;//:;(*编码器定位放A*)
	DWORD	dwAxisALocation_MinDia_Uw_D;//:;(*编码器定位放A*)
	DWORD	dwAxisBLocation_MinDia_Uw_D;//:;(*编码器定位放A*)
	//2023.09.18.155837 同步
	WORD wButton_Uw ; //2023.9.9.140626||按钮通讯|./0 放料写入按钮
	DWORD dwSlaveVer;//2025.12.3.164214+

}StGrpParam;

typedef struct{
	INT iUId							;// INT;(*映射单元的Id*)
	DWORD dwComplexFlag_AxisInchRunning;    //(*2019.4.2.182326|所有轴的单运行状态|*)
	DWORD dwComplexFlag_AxisLinkage;		//(*2019.4.2.182326|所有轴的联动状态|*)
	DWORD dwAxis_SkipTheHeader		;//		: DWORD;(*让料头标志| 位标志bit0=机组1,...,bit31=机组32*)
	DWORD dwAxis_Alarm				;//		: DWORD;(*报警| 位标志bit0=机组1,...,bit31=机组32*)
	DWORD dwAxis_RollerDn			;//			: DWORD;(*压辊压下| 位标志bit0=机组1,...,bit31=机组32*)
	DWORD dwAxis_ServoOn			;//			: DWORD;(*伺服使能| 位标志bit0=机组1,...,bit31=机组32*)
	WORD wMachineArchitectureRef	;//			: WORD;(*机器架构描述*)
									 //		(*
									 //		*.bit0: 双收双放机型(TRUE);|标准机型就不用看astStGrpParam[2]了
									 //		*.bit1: 双收双放当成整机使用(TRUE)，综合参考bit0|
									 //		*.bit2: 包含副主站通讯
									 //		--------------------------------------------------|
									 //		*** 2019.10.29.162940_|<用于增加在系统配置中直接保存的量>
									 //		*.bit3: 反手机器(从右到左)|
									 //		*.bit4: 收放料同侧-内放外收|
									 //		*.bit5: 收放料同侧-外放内收|
									 //		|*)

	BYTE byLanguageId;
	INT iCompanyId;
	DWORD dwControlComplexBits;
	INT iUnitNum;//2022.6.20.225715轴数
	BYTE byCurrUsrLevel;//用户等级
//
//	//2025.7.22.185256+
//	//粗采样数据-本地只保留每个通道800点
//	uint8_t abyRSData_T1R[800];
//	uint8_t abyRSData_T1G[800];
//	uint8_t abyRSData_T1B[800];
//	uint8_t abyRSData_T2R[800];
//	uint8_t abyRSData_T2G[800];
//	uint8_t abyRSData_T2B[800];

	float fBaseLine_T1R;//T1_R的基线值
	float fBaseLine_T1G;//T1_G的基线值
	float fBaseLine_T1B;//T1_B的基线值
	float fBaseLine_T2R;//T2_R的基线值
	float fBaseLine_T2G;//T2_G的基线值
	float fBaseLine_T2B;//T2_B的基线值

	uint8_t byMinRsData_T1R;//T1_R的基线值@最小值
	uint8_t byMinRsData_T1G;//T1_G的基线值@最小值
	uint8_t byMinRsData_T1B;//T1_B的基线值@最小值
	uint8_t byMinRsData_T2R;//T2_R的基线值@最小值
	uint8_t byMinRsData_T2G;//T2_G的基线值@最小值
	uint8_t byMinRsData_T2B;//T2_B的基线值@最小值

	float fBaseLine_T1;//T1的基线值@用于误差计算|四舍五入后
	float fBaseLine_T2;//T2的基线值@用于误差计算|四舍五入后
//
//	uint16_t	auiFSDataT1[6000];	//精采样数据-本地需要保留全部
//	uint16_t	auiFSDataT2[6000];	//精采样数据-本地需要保留全部

	//2025.06.13.180456//xi.hy//新增
	float	rOffset_T1;			  	//T1路光纤偏移
	float 	rSource_Light_T1;        //T1路光纤光源
	float	rBias_T1;			  	//T1路光纤电眼偏置
	float	rBrightness_Light_T1; 	//T1路光纤电眼亮度
	float	rSource_Light_T1_Cur; 	//T1路光纤电眼亮度@当前值|2025.8.11.085206+

	float	rOffset_T2;			  	//T2路光纤偏移
	float 	rSource_Light_T2;        //T2路光纤光源
	float	rBias_T2;			  	//T2路光纤电眼偏置
	float	rBrightness_Light_T2; 	//T2路光纤电眼亮度
	float	rSource_Light_T2_Cur; 	//T2路光纤电眼亮度@当前值|2025.8.11.085206+
	//2025.07.17.093439//xi.hy//新增
	int16_t iScalPoints_HorScal;	//横向放大后的总点数
	int16_t iGateSa_Scale;	//横向放大后的波门起始值@2025.8.11.185803+

	uint8_t	bySignalSelect;	//低4bit是控制T1当前rgb(b通道)|高4bit是控制T2当前rgb(a通道)

	//人机读写控制bit@变化不能太快
	uint16_t 	uiSomeCtlBit_RW;//通讯一些控制位	//.0 有效屏蔽r通道
											//.1 有效屏蔽g通道
											//.2 有效屏蔽b通道
											//.3 有效波形横向放大
											//.4 有效 演示波形处理
	int16_t iGateWidthRdPt_Hmi;//界面显示的波门宽度
	//uint16_t	uiRSampleCounter;	//粗采样计数|换到轴参数中去了
	uint8_t byMinutes_ScrAutoSleep;//屏保延时
	uint16_t uiRemainNum_F;
	uint16_t uiRemainNum_B;

	//2025.10.24.084811 +
	uint8_t byArcSensorType;//:BYTE;(*套色传感器类型|=0 传统光电眼|=1 曜光接口(光纤电眼)*)
	//2025.10.29.113108+
	uint8_t xPduDnFailed;

	//(*2025.12.1.190530+*)
	uint8_t xArmUpdating;				//: BOOL;(*arm升级中标志,控制arm软件不再进行mail通讯|防止引起arm升级失败*)
	uint8_t xStopMailComm;//2025.12.1.092425|取消mail通讯标志
	uint8_t byUnLockHmi_UI;//2026.1.31.145610+	(*解锁ui界面	|/.0 heating_etc-刮刀界面
															//|/.1 heating_etc-递墨界面
															//|/.2 heating_etc-热风界面
															//|/.3 heating_etc-加热界面
															//|/.4 heating_etc-排风界面@.0~.4有一个有效，heating_etc界面可以进入
															//|/.5 主界面热风风门界面*)
}StGlobalParam;
#pragma pack()

#endif /* BASE_H_ */
