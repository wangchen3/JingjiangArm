/*
 * KS_FB_VISU.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef KS_FB_VISU_H_
#define KS_FB_VISU_H_

#include "base.h"
#include "gt_rn_struct.h"
#include "comm.h"
#include "main.h"

//#define RS485_TX_EN		PAout(1)	//485模式控制.0,接收;1,发送.
// 2024.8.12.143329/wei.n/PA1引脚默认高电平-发送
#define RS485_TX_EN(x)   do{x?HAL_GPIO_WritePin(RS485_TX_EN_GPIO_Port,RS485_TX_EN_Pin,GPIO_PIN_SET) :\
						   HAL_GPIO_WritePin(RS485_TX_EN_GPIO_Port,RS485_TX_EN_Pin,GPIO_PIN_RESET);\
						  }while(0)			// 0, 接收  1,发送

//如果想串口中断接收，设置EN_USART2_RX为1，否则设置为0
#define EN_USART2_RX 	1			//0,不接收;1,接收.
#define QueueSize 500
#define HMI_Resolution 800  		//HMI显示分辨率800

#pragma pack(1)
typedef struct
{
	BYTE RS485_TX_BUFF[QueueSize];
	INT pStart;
	INT pStop;
} St485_Queue;
#pragma pack()

void KS_FB_VISU(
				StAxisParam* i_pstStAxisParam,
				StGlobalParam* i_pstStGlobalParam,
				StGrpParam* i_pstStGrpParam,
				StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,
				INT *i_piJourney_HorzRapidAdjust,
				DWORD* i_pdwPlateAdjustmentProf,
				//INT i_aiError_V[40],
				//INT i_aiError_H[],
				INT i_aiError_V[],
				INT i_aiError_H[],
				BYTE i_byLedSwitchTimeouts,
				BYTE* i_pxOK_PosConfirmed,
				BYTE* i_pxFlag_Mag,//横向放大标志
				INT* i_piWave_offset_Temp,
				INT i_iWave_offset,//2020.9.26.151110实际粗采样偏移
				BYTE i_bySample_Interval,//采样间隔
				BYTE* i_pxRefresh_Flag,
				//BYTE i_abyRoundData_485[1600],
				BYTE i_abyRoundData_485[],
				//REAL i_alrBase_485[2],
				REAL i_alrBase_485[],
				WORD i_iCount_TimeOutNum,
				DINT i_diFineSampleStart,
				//BYTE i_abyMinData_Sample[2]
				BYTE i_abyMinData_Sample[]);//精采样第二路信号地址

//WORD CRC_Compute(BYTE i_abyData[QueueSize], INT i_iStart, INT i_iStop);
WORD CRC_Compute(BYTE i_abyData[], INT i_iStart, INT i_iStop);

//void RS485_Send_Data(BYTE *buf,BYTE len);
//void RS485_Receive_Data(u8 *buf,u8 *len);
//void RS485_Init(DWORD bound);
//void RS485_Send_OneData(BYTE *buf);//设置为发送模式
//void RS485_TX_Init(St485_Queue *i_pstSt485_Queue);
//void Master_to_Slave_16(WORD i_wAddress,WORD i_wLength);
//void Master_to_Slave_03(WORD i_wAddress,WORD i_wLength);
BYTE GetBit(WORD wData,BYTE bitnum);
WORD SetBit(BYTE byBit,WORD wData,BYTE bitnum);

BYTE GetBit_DWORD(DWORD dwData,BYTE bitnum);
DWORD SetBit_DWORD(BYTE byBit,DWORD dwData,BYTE bitnum);

#pragma pack(1)
typedef struct
{
	BYTE byStationId; 			//站号
	BYTE bycmd;					//功能码
	WORD wAddress;				//寄存器地址
	WORD wNum_Register ;		//寄存器数量
	BYTE bySendNum_Bytes;		//发送字节数发送数据包里的字节数
	BYTE byReadNum_Bytes;		//接收字节数有效字节数
	BYTE byNum_Bytes;			//发送的数据包总长度
	WORD wCRC;					//CRC校验码
} St485_Format;
#pragma pack()

void KS_FB_VISU_IF(
			StGlobalParam* i_pstStGlobalParam,
			StGrpParam* i_pstStGrpParam);

//2024.02.01.172124
//函数实现word(2字节) /dword(4字节)数据 写入到单字节数组中。
//并支持针对modbus通讯的顺序颠倒|word 12-->21|dword 1234-->4321
// pdata 数据指针 只支持2字节和4字节
//data_lenth 数据指针指向的数据长度
//commdata 解析后单字节数据
//reverse 解析后的单字节数据顺序颠倒
void ks_getmodbuscommdata( void *pdata,  char data_lenth, unsigned char *commdata,unsigned char reverse);

#endif /* KS_FB_VISU_H_ */
