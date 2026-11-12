/*
 * KS_FB_VISU.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */
#include "KS_FB_VISU.h"
#include "calcbase.h"
//#include "delay.h"
#include "stdafx.h"//memcpy
#include "led.h"
#include "stdio.h"
#include "tim.h"
#include "KesaiAPI.h"
#include "usart.h"
#include "base.h"
//双置信度/飞点两个运行时开关及置信度显示通讯(485对组态屏,开关位46059.02/.03/.04,
//s50=4WUB6060,显示6206,区域说明见下方注释块)|wang.c+双置信度融合 2026.11.10.090134
//|开关通讯接入 2026.11.10.160000|组态屏改版适配 2026.11.11
#include "ks_conf_err.h"
#include "ks_fly_remove.h"

/* ============================================================================
 * 【已接入】双置信度/飞点开关下发与置信度显示的485组态屏通讯(2026-11-10接入)
 * 4处挂接位置:①include块 ②读命令长度0x3C(2026-11-11组态屏改版后不需扩展,保持0x3C)
 * ③读响应解析(xHorMotorAlarm解析行之后) ④case3"写其余数据"帧aReturn[0]填置信度
 * |wang.c+双置信度融合 2026.11.10.090134|开关通讯接入 2026.11.10.160000
 * |组态屏改版适配(开关并入46059编码器位区,s50用6060,读长度回0x3C) 2026.11.11
 *
 * 寄存器区域(485对组态屏,ARM为Modbus主站,读基址0x1770=6000/写基址0x1838=6200;
 * 注意MCGS侧寄存器地址=协议地址+1,读响应帧数据自[3]起,数据区第k个寄存器(0基,自协议6000起)
 * 占[3+2k](高)+[4+2k](低),即MCGS寄存器R(=协议R-1,k=R-6001)占RX_BUFF[2R-11999](高)
 * +[2R-11998](低);0x3C读协议6000~6059=MCGS6001~6060,改版后所有新通道均在此范围内):
 *   屏→ARM(读区维持6000~6059不扩,读长度0x3C):
 *     MCGS46059(协议6058)=编码器/开关共用位区:低8位=RX_BUFF[120],
 *        bit0=横向编码器有效|bit1=横向电机报警(原有)|
 *        bit2=飞点开关xFlyRemoveEn(1=新Theil-Sen剔除默认|0=回退旧二阶差分)|
 *        bit3=置信度开关xConfErrEn(1=上报双置信度融合误差)|bit4=下发使能xSwitchWrEn
 *        ——bit4=0忽略bit2/bit3写入:屏幕未配置读回0,保护ARM默认行为(飞点=1/置信度=0)
 *     MCGS4WUB6060(协议6059)=s50输入wConfS50,单位0.001mm(20=0.02mm),
 *        有效范围1~1000,越界保持原值,下一圈生效——0x3C覆盖的最后一个寄存器
 *   ARM→屏(写其他帧,随每个通讯循环约600ms刷新,改版不影响):
 *     协议6206(MCGS 6207)=高8位纵向融合置信度F(0~100)|低8位横向F(0~100)
 *                          (原奥特马递墨辊自动频率2025.10起已注释弃用,寄存器释放使用)
 * 组态屏侧对应通道:开关位=46059.02/.03/.04,s50=4WUB6060(wConfS50),显示=4WUB6207(wConfPack,
 * 屏脚本拆字节:纵向F=wConfPack/256,横向F=wConfPack%256)
 * ============================================================================ */


//2024.02.01.110219 同步
extern EXCEPTION_OF_CRASH exception_crash;		// 2024.1.20.142820/defined in main.c
extern char g_send_crashinf_hmi;

//接收缓存区
//接收到的数据长度
BYTE byReceiveEnd;		//接收数据完成标志。不管接收到的是错误码还是响应码，只要字节数符合和CRC通过，认为接收完成，切换485主流程的STEP;
BYTE RS485_RX_BUFF[150];												//485接收缓存
BYTE RS485_TX_BUFF[250];												//485发送缓冲区，由原来的循环队列更改为固定数组
WORD wSendNum_Test;														//485发送计次
WORD wReadNum_Test;														//485接收计次
BYTE xReceiveSuccessful;												//接收完成标志，根据接收数据量与CRC校验判断
static BYTE bySendStep=1;												//switch(bySendStep)--1:判断发送双向通讯参数，只有主站进行修改才会下发一次||2:正常循环，双向参数主站未修改时
static BYTE byNormalStep=0;												//switch(byNormalStep)正常循环：1:读取双向参数2:发送T1数据3:读取双向参数4:发送T2和其余单向参数10寄存器
static BYTE byStepRec=1;												//控制接收的状态机

static DWORD dwPlateAdjustmentProf;										//485接收到的纵向快速对版量
static BYTE xFirstTime=1,xReset=0;										//首次通讯和复位标志
static WORD wResetNum;													//485重启计次//从站数据不对，有主站强制刷新参数一次
static BYTE byStep_Sample;												//
INT iN;																	//循环变量
St485_Format stSt485_Format;											//485通讯格式相关参数站号功能码等
WORD aTimeTest[3];
static WORD wTest_max=0;

extern short g_aiCfgH;
extern short g_aiCfgL;

/*
1.DR=0x01，进入case2
2.DR=03,进入case3-接收数据响应||DR=16-发送数据响应吗||0x83-03功能吗的错误码||0x90-16功能吗的错误码
if||DR=03，
执行case3.4.5
||case3.DR=16,进入case4-||站号，功能吗，字节数都正确，认为一帧数据开始接收
||case4.依次接收16个字节数据，进入case5-一帧数据接收完成
||case5.接收两个数据，默认为CRC值，比对CRC，CRC校验通过，接收完成，否则扔掉这次数据
结束

if||DR=16,进入case16-发送数据响应,
执行case16,17
||case16,接收4个字节-发送的起始地址和寄存器数量-case17
||case17,接收两个字节-CRC校验-响应成功
结束

if||DR=0x83--功能吗03的错误吗-case-83
执行case83
||case83---DR=01 | 02 | 03 | 04
01-功能吗错误
02-起始地址OK & 起始地址+寄存器数量OK
03-寄存器数量<=0x7B
04-读多个寄存器OK
+校验
结束

if||DR=0x90--功能吗16的错误码-case-90
执行case90
||case90--DR=01 |02 | 03| 04
01-功能吗错误
02-起始地址OK & 起始地址+寄存器数量OK
03-寄存器数量<=0x7B & 字节数=寄存器数量*2
04-写多个寄存器OK
+校验
结束
*/

//CRC校验表
const BYTE auchCRCHi[] = {
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
	0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
	0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40
};

const BYTE auchCRCLo[] = {
	0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2, 0xC6, 0x06,0x07, 0xC7, 0x05, 0xC5, 0xC4, 0x04, 0xCC, 0x0C, 0x0D, 0xCD,
	0x0F, 0xCF, 0xCE, 0x0E, 0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09,0x08, 0xC8, 0xD8, 0x18, 0x19, 0xD9, 0x1B, 0xDB, 0xDA, 0x1A,
	0x1E, 0xDE, 0xDF, 0x1F, 0xDD, 0x1D, 0x1C, 0xDC, 0x14, 0xD4,0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 0xD2, 0x12, 0x13, 0xD3,
	0x11, 0xD1, 0xD0, 0x10, 0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3,0xF2, 0x32, 0x36, 0xF6, 0xF7, 0x37, 0xF5, 0x35, 0x34, 0xF4,
	0x3C, 0xFC, 0xFD, 0x3D, 0xFF, 0x3F, 0x3E, 0xFE, 0xFA, 0x3A,0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38, 0x28, 0xE8, 0xE9, 0x29,
	0xEB, 0x2B, 0x2A, 0xEA, 0xEE, 0x2E, 0x2F, 0xEF, 0x2D, 0xED,0xEC, 0x2C, 0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26,
	0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 0xA0, 0x60,0x61, 0xA1, 0x63, 0xA3, 0xA2, 0x62, 0x66, 0xA6, 0xA7, 0x67,
	0xA5, 0x65, 0x64, 0xA4, 0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F,0x6E, 0xAE, 0xAA, 0x6A, 0x6B, 0xAB, 0x69, 0xA9, 0xA8, 0x68,
	0x78, 0xB8, 0xB9, 0x79, 0xBB, 0x7B, 0x7A, 0xBA, 0xBE, 0x7E,0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 0xB4, 0x74, 0x75, 0xB5,
	0x77, 0xB7, 0xB6, 0x76, 0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71,0x70, 0xB0, 0x50, 0x90, 0x91, 0x51, 0x93, 0x53, 0x52, 0x92,
	0x96, 0x56, 0x57, 0x97, 0x55, 0x95, 0x94, 0x54, 0x9C, 0x5C,0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E, 0x5A, 0x9A, 0x9B, 0x5B,
	0x99, 0x59, 0x58, 0x98, 0x88, 0x48, 0x49, 0x89, 0x4B, 0x8B,0x8A, 0x4A, 0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C,
	0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 0x82, 0x42,0x43, 0x83, 0x41, 0x81, 0x80, 0x40
};

BYTE GetBit(WORD wData,BYTE bitnum)									//unsigned short(WORD)取位
{
	BYTE byResult;
	byResult = (BYTE)((wData>>bitnum) & (WORD)0x01) ;
	return byResult;
}
WORD SetBit(BYTE byBit,WORD wData,BYTE bitnum)						//unsigned short(WORD)置位
{
	WORD wResult;
	if(byBit==0)
	{
		wResult = wData & (~(1<<bitnum));
	}
	else if(byBit==1)
	{
		wResult = wData | (1<<bitnum);
	}
	return wResult;
}

BYTE GetBit_DWORD(DWORD dwData,BYTE bitnum)							//unsigned int(DWORD)取位
{
	BYTE byResult;
	byResult = (BYTE)((dwData>>bitnum) & (DWORD)0x01) ;
	return byResult;
}
DWORD SetBit_DWORD(BYTE byBit,DWORD dwData,BYTE bitnum)				//unsigned int(DWORD)置位
{
	DWORD dwResult;
	if(byBit==0)
	{
		dwResult = dwData & (~(1<<bitnum));
	}
	else if(byBit==1)
	{
		dwResult = dwData | (1<<bitnum);
	}
	return dwResult;
}

//WORD CRC_Compute(BYTE i_abyData[QueueSize], INT i_iStart, INT i_iStop)	//该CRC计算仅用于发送数据时计算CRC，接收数据CRC每个字节单独算
WORD CRC_Compute(BYTE i_abyData[], INT i_iStart, INT i_iStop)	//该CRC计算仅用于发送数据时计算CRC，接收数据CRC每个字节单独算
{
	BYTE uchCRCHi = 0xFF ;
	BYTE uchCRCLo = 0xFF ;
	WORD usDataLen;
	DWORD uIndex ;
	if(i_iStart<i_iStop)
	{
		usDataLen=i_iStop-i_iStart;
	}
	else
	{
		usDataLen= QueueSize-i_iStart+i_iStop;
	}
	while (usDataLen>0)
	{
		usDataLen--;
		uIndex = uchCRCHi ^ i_abyData[i_iStart] ;
		uchCRCHi = uchCRCLo ^ auchCRCHi[uIndex] ;
		uchCRCLo = auchCRCLo[uIndex] ;
		i_iStart= (i_iStart+1) % QueueSize;
	}
	return ((uchCRCHi<< 8)  | (uchCRCLo)) ;
}

void USART2_IRQHandler(UART_HandleTypeDef *huart) //串口2-485中断服务函数-接收中断的处理
{
	WORD calCRC;															//计算的校验码
	WORD recCRC;															//接收到的校验码
	static BYTE rec_cnt;													//接收数据个数统计
	BYTE byRecBuff;															//记录本次接收的数据

	//CRC计算2021.8.23.175321-每收到一个字节算一次||不再全部收完计算，会导致最后一次进入中断时耗时过长
	static BYTE uchCRCHi_RX = 0xFF ;
	static BYTE uchCRCLo_RX = 0xFF ;
	static DWORD uIndex_RX=0 ;
	//BYTE ClearORE;

	//2025.11.3.184033取消
	//HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_RESET);  //LED0=1;

	aTimeTest[0]=htim3.Instance->CNT;   //定时器数值-计算最大中断耗时

	if(((huart2.Instance->SR>>5) & 0x1)==1)               //接收的数据
	{
		byRecBuff = huart2.Instance->DR;
		switch ( byStepRec )											//接收的状态控制
		{
		case 1: 														//1.DR=0x01，进入case2||数据起始值永远是1
			if( byRecBuff == stSt485_Format.byStationId ) 			//站号
			{
				RS485_RX_BUFF[0] = byRecBuff;
				byStepRec = 2;										//站号校验通过
				//2021.8.23.175619假如计算检验码过程
				uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[0] ;
				uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
				uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
			}
			else
			{
				byStepRec = 1;
			}
			break;

		case 2: 										//||2.DR=03,进入case3-||DR=16,进入case16||0x83-03功能吗的错误码-进入case83||0x90-16功能吗的错误码-进入case90
			if(byRecBuff== stSt485_Format.bycmd)							//判断功能码
			{
				RS485_RX_BUFF[1] = byRecBuff;
				//2021.8.23.175619假如计算检验码过程
				uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[1] ;
				uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
				uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
				if(stSt485_Format.bycmd==0x03)								//功能码03-读取数据
				{
					byStepRec = 03;
				}
				else if(stSt485_Format.bycmd==0x10)							//功能码16写入数据
				{
					byStepRec = 16;
				}
			}
			else if( byRecBuff == 0x83 ) 									//差错吗0x83-发送03功能吗时的错误码
			{
				byStepRec = 83;
				RS485_RX_BUFF[1] = byRecBuff;
				//2021.8.23.175619假如计算检验码过程
				uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[1] ;
				uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
				uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
			}
			else if( byRecBuff == 0x90 ) 									//差错吗0x90-发送16功能吗时的错误码
			{
				byStepRec = 90;
				RS485_RX_BUFF[1] = byRecBuff;
				//2021.8.23.175619假如计算检验码过程
				uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[1] ;
				uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
				uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
			}
			else
			{
				byStepRec = 1;												//以上都不是等待下一个0x01返回
			}
			break;

			//第一个读取到01，第二个读取到03时，执行case3,4,5--读取周期
		case 3:
			if( byRecBuff == stSt485_Format.byReadNum_Bytes) 				//2020.9.26.144817||niu.j||读取字节数增加100个字节。
			{
				byStepRec = 4;												//字节数校验通过
				RS485_RX_BUFF[2] = byRecBuff;
				//2021.8.23.175619假如计算检验码过程
				uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[2] ;
				uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
				uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
			}
			else
			{
				byStepRec = 1;												//字节数量返回不对-等待下一个0x01返回
			}
			break;

		case 4:																//4.依次接收16个字节数据，进入case5-一帧数据接收完成
			RS485_RX_BUFF[rec_cnt+3] = byRecBuff;
			//2021.8.23.175619假如计算检验码过程
			uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[rec_cnt+3] ;
			uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
			uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
			rec_cnt++;												//接收到的数据++，到字节数后-to-case 5
			if( rec_cnt == stSt485_Format.byReadNum_Bytes)			//接收到16个值后，跳入下一步
			{
				byStepRec = 5;										//数据接收完成
				rec_cnt = 0;
			}
			break;

		case 5:														//||case5.接收两个数据，默认为CRC值，比对CRC，CRC校验通过，接收完成，否则扔掉这次数据
			RS485_RX_BUFF[stSt485_Format.byReadNum_Bytes+3+rec_cnt] = byRecBuff;		//有效字节数+包头3+检验码2
			rec_cnt++;
			if( rec_cnt == 2 )										//接收两个字节的检验吗
			{
				//接收
				byReceiveEnd=1;										//接收完成，切换主流程step;
				calCRC =  ((uchCRCHi_RX<< 8)  | (uchCRCLo_RX)) ;
				recCRC = RS485_RX_BUFF[stSt485_Format.byReadNum_Bytes+4] | (((WORD)RS485_RX_BUFF[stSt485_Format.byReadNum_Bytes+3]) << 8 );	//接收到的CRC(低字节在前，高字节在后)
				byStepRec = 1;										//不管CRC校验是否成功，这帧数据处理完成，等待下一次
				rec_cnt = 0;										//接收完成后清除
				if( calCRC == recCRC )								//校验成功
				{
					xReceiveSuccessful = 1;							//置位接收完成标志
				}
				else																				//校验失败
				{
					;
				}
			}
			break;
			//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>end >>>>>>>>>>>>>>>>>>>>>>

			//第一个读取到01，第二个读取到16时，发送的响应返回，执行case16,17
		case 16:
			RS485_RX_BUFF[rec_cnt+2] = byRecBuff;
			//2021.8.23.175619假如计算检验码过程
			uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[rec_cnt+2] ;
			uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
			uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
			rec_cnt++;										//接收到的数据++，到字节数后-to-case 17
			if( rec_cnt == stSt485_Format.byReadNum_Bytes )	//接收到4个值后，跳入下一步
				//4个字节包括起始地址和寄存器数量
			{
				byStepRec = 17;								//数据接收完成
				rec_cnt = 0;
			}
			break;

		case 17:
			RS485_RX_BUFF[stSt485_Format.byReadNum_Bytes+2+rec_cnt] = byRecBuff;
			rec_cnt++;
			if( rec_cnt == 2 )																		//接收两个字节的检验吗
			{
				byReceiveEnd=1;																		//接收完成，切换主流程step;
				calCRC =  ((uchCRCHi_RX<< 8)  | (uchCRCLo_RX)) ;
				recCRC = RS485_RX_BUFF[stSt485_Format.byReadNum_Bytes+3] | (((WORD)RS485_RX_BUFF[stSt485_Format.byReadNum_Bytes+2]) << 8 );	//接收到的CRC(低字节在前，高字节在后)
				byStepRec = 1;																		//不管CRC校验是否成功，这帧数据处理完成，等待下一次
				rec_cnt = 0;																		//接收完成后清除
				if( calCRC == recCRC )																//	校验成功
				{
					xReceiveSuccessful = 1;															//置位接收完成标志//具体接收到是发送响应还是读取响应，主流程根据功能吗判断
				}
				else																				//校验失败
				{
					;
				}
			}
			break;
			//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>end >>>>>>>>>>>>>>>>>>>>>>>>>>>>.

			//第一个读取到01，第二个读取到0x83，发送功能吗03时的错误码返回，执行case83
		case 83:																					//83发送的错误码和异常吗及校验
			RS485_RX_BUFF[rec_cnt+2] = byRecBuff;													//异常吗+校验-3个字节
			rec_cnt++;
			if( rec_cnt == 3 )
			{
				uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[2] ;
				uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
				uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
				byReceiveEnd=1;																		//接收完成，切换主流程step;
				calCRC =  ((uchCRCHi_RX<< 8)  | (uchCRCLo_RX)) ;
				recCRC = RS485_RX_BUFF[4] | (((WORD)RS485_RX_BUFF[3]) << 8 );						//接收到的CRC(低字节在前，高字节在后)
				byStepRec = 1;																		//不管CRC校验是否成功，这帧数据处理完成，等待下一次
				rec_cnt = 0;																		//接收完成后清除
			}
			break;
			//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>end >>>>>>>>>>>>>>>>>>>>>>>>>........

			//第一个读到01，第二个读到0x90，发送功能吗16的错误吗返回，执行case90
		case 90:
			RS485_RX_BUFF[rec_cnt+2] = byRecBuff;													//异常吗+校验-3个字节
			rec_cnt++;
			if( rec_cnt == 3 )
			{
				uIndex_RX = uchCRCHi_RX ^ RS485_RX_BUFF[2] ;
				uchCRCHi_RX = uchCRCLo_RX ^ auchCRCHi[uIndex_RX] ;
				uchCRCLo_RX = auchCRCLo[uIndex_RX] ;
				byReceiveEnd=1;																		//接收完成，切换主流程step;
				calCRC =  ((uchCRCHi_RX<< 8)  | (uchCRCLo_RX)) ; 									//计算所接收数据的CRC
				recCRC = RS485_RX_BUFF[4] | (((WORD)RS485_RX_BUFF[3]) << 8 );						//接收到的CRC(低字节在前，高字节在后)
				byStepRec = 1;																		//不管CRC校验是否成功，这帧数据处理完成，等待下一次
				rec_cnt = 0;																		//接收完成后清除
			}
			break;
		default:
			byStepRec = 1;
			break;
			//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>end>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		}

		////>>>>>>>>>>>>>>>>>>>>>>>>switch结束》》》》》》》》》》》》》》》
		if( xReceiveSuccessful ==1)																//2021.7.16.145905增加如果三次读取响应未成功，就直接进行下一条指令
		{
			if( bySendStep == 1 )																//发送双向数据完成
			{
				bySendStep = 2;																	//切换到正常流程-读-发-发
			}
			else if( bySendStep == 2 )
			{
				byNormalStep = (byNormalStep+1) % 4;											//循环0-3
			}
			else
			{
				bySendStep = 1;
			}
		}
	}
	//////////////////////2020.04.02.142414循环队列发送数据
	else if(__HAL_UART_GET_FLAG( &huart2, UART_FLAG_TC) != RESET )  																	//发送完成中断
	{
		//HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);  //LED1=0;
		__HAL_UART_CLEAR_FLAG(&huart2, UART_FLAG_TC );
		static INT uiIndex_Send=1;

		if(uiIndex_Send== stSt485_Format.byNum_Bytes)																						//队列空，发送完成
		{
			wSendNum_Test++;
			RS485_TX_EN (0);																																	//切换到接收
			uiIndex_Send=1;    																																//清除发送缓冲区索引
			rec_cnt = 0;																																			//清除接收缓冲区索引
			//清除CRC相关
			uchCRCHi_RX = 0xFF ; 																															//初始化计算CRC变量
			uchCRCLo_RX = 0xFF ;
			uIndex_RX=0 ;
		}
		else
		{
			USART2->DR = RS485_TX_BUFF[uiIndex_Send];																					//发送数据
			uiIndex_Send++;
		}
	}

	else
	{
		if(__HAL_UART_GET_FLAG(&huart2, UART_FLAG_ORE)!= RESET)																//清除上溢中断|2020.6.6.160103
		{
			//2021.9.9.011336清除上溢中断
			__HAL_UART_CLEAR_FLAG(&huart2,UART_FLAG_ORE);
			//ClearORE= USART_ReceiveData(USART2);
			USART_ReceiveData(USART2);
		}
	}
	//2025.11.3.184033取消
	//HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_SET);  //LED0=0;
	//////////////////////////////////////////////////////////////////////
	aTimeTest[1]= TIM3->CNT;//测试代码
	aTimeTest[2]= aTimeTest[1]-aTimeTest[0];
	if(wTest_max<aTimeTest[2])
	{
		if(aTimeTest[2]>0 && aTimeTest[2]<9000)
		{
			wTest_max= aTimeTest[2];
		}
	}
}

//485初始化
//初始化IO 串口2
//bound:波特率
//void MX_USART2_UART_Init(void);

//2020.04.22.095708
//HMI显示处理
//485通讯处理
void KS_FB_VISU(
				StAxisParam* i_pstStAxisParam,										//轴参数
				StGlobalParam* i_pstStGlobalParam,									//整机参数
				StGrpParam* i_pstStGrpParam,										//系参数
				StPara_PduBroadcastUp* i_pstStPara_PduBroadcastUp,					//上行参数
				INT *i_piJourney_HorzRapidAdjust,									//横向对版量
				DWORD* i_pdwPlateAdjustmentProf,									//纵向对版量
				//INT i_aiError_V[50],												//纵向误差队列
				//INT i_aiError_H[50],												//横向误差队列
				INT i_aiError_V[],												//纵向误差队列
				INT i_aiError_H[],												//横向误差队列
				BYTE i_byLedSwitchTimeouts,											//屏保时间
				BYTE* i_pxOK_PosConfirmed,											//单标记误差确认
				BYTE* i_pxFlag_Mag,													//横向放大标志
				INT* i_piWave_offset_Temp,											//波形偏移量
				INT i_iWave_offset,													//2020.9.26.151110实际粗采样偏移
				BYTE i_bySample_Interval,											//采样间隔
				BYTE* i_pxRefresh_Flag,
				//BYTE i_abyRoundData_485[1600],										//两路波形数据
				BYTE i_abyRoundData_485[],										//两路波形数据
				//REAL i_alrBase_485[2],												//人机绘制波形需要的基线值
				REAL i_alrBase_485[],												//人机绘制波形需要的基线值
				WORD i_iCount_TimeOutNum,											//超时计次
				DINT i_diFineSampleStart,
				//BYTE i_abyMinData_Sample[2]
				BYTE i_abyMinData_Sample[])
{
	BYTE i_abyResultData_RS[500];													//2021.6.10.160425发送原始波形
	INT iN;																			//循环变量，两路信号循环
	BYTE bySlaveChangeFlag;															//从站参数修改记录
	WORD temp;																		//计算所用临时变量
	static INT iGateSa_Rec;															//前个周期的波门地址
	static REAL rAdjust_V_Rec;														//前个周期的纵向修正量
	static REAL rAdjust_H_Rec;														//前个周期的横向修正量
	static WORD wStatus_Rec;														//前个周期的手自动状态等
	static INT iAxisId_Rec;															//前个周期的轴号
	static BYTE byGrpId_Rec;														//前个周期的系号
	static BYTE byLanguageId_Rec;													//前个周期的语言选择
	static REAL lrAlarm_V_Rec;														//前个周期的纵向报警值
	static REAL lrAlarm_H_Rec;														//前个周期的横向报警值
	static INT iGateWidthPhy_Rec;													//前个周期的波门宽度
	static BYTE xPreFlag_Mag;
	static INT i_iWave_offset_Rec;
	static WORD wButtonFun_Rec;														//2020.12.5.134337按钮功能
	//2025.10.28.165757 屏蔽容易混淆的内容
	//static WORD wInkRoller_Fre_Rec;												//递墨辊频率Last
	static BYTE byUnLockHmi_UI_Rec;													//2026.1.31.154408+
	static WORD wAirInletWindDoorValue_Rec;											//进风口风门开度值|输入范围(0~100)Last
	static WORD wAirExhaustWindDoorValue_Rec;										//排风口风门开度值|输入范围(0~100)Last
	static WORD wAirReturnWindDoorValue_Rec;										//回风口风门开度值|输入范围(0~100)Last
	//2025.10.28.165757 屏蔽容易混淆的内容
	//static WORD wTemperature_Set_Rec;												//加热温度设置SV-Last
	static WORD bySampleSholdSwitch_Rec;											//阀值线选择开关-Last
	static BYTE byPowerOn_Flag=1;													//上电同步标志默认是1
	static WORD wPowerOnSync;														//上电同步更新的变量

	static INT 	iGateWidthRondPt_Rec;
	static BYTE  bySample_Interval_Rec;
	//2025.10.28.165757 屏蔽容易混淆的内容
	//static WORD wSV_TemCtrl;
	//static WORD wSV_TemCtrl_PreHot;
	//static BYTE byAxisRoller_UpperFrq_Rec;

	//2022.3.21.155833新增北人
	static WORD wHz_UnitInkRoller_ManuallySet_Rec;
	static WORD wCoeff_UnitInkRoller_Auto_Rec;
	static WORD wHz_UnitScraper_ManuallySet_Rec;
	static WORD wCoeff_UnitScraper_Auto_Rec;
	static WORD wHz_UnitHotWind_Rec;
	//2026.3.11.104423 替换为排风
	//static WORD wHz_UnitHotWind_2_Rec;
	static WORD wHz_UnitExhaust_ManuallySet_rec;
	static WORD wSV_UnitTemCtl_Rec;
	static DWORD dwCtlBits_UnitBaseCraft_Rec;
	static BYTE byLedSwitchTimeouts_Rec;//2022.5.12.143635
	WORD wStatus;

	//2023.11.08.102638 同步
	// 2023.10.14.85553/wei.n/7吋人机色组IO与ARM通讯
	static WORD wUnit_output_I_Rec;
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
	static WORD wUnit_output_II_Rec;
										//Bit0: o_xRel_CoolBlower; //冷风输出
										//Bit1: o_xRel_HotBlower; //热风输出
										//Bit2: o_wInExhaustAir; //色组排风输出
										//Bit3: o_xRel_Heating_I; //加热I输出
										//Bit4: o_xRel_Heating_II; //加热II输出
										//Bit5: o_xRel_Heating_III; //加热III输出
										//Bit6: o_xScraperOn; //刮刀使能
										//Bit7: o_xRel_InkRoller_CW; //递墨辊正转
										//Bit8: o_xRel_InkRoller_Up; //递墨辊上

	//手自动等状态
	//	INT iGate_Sa,iGate_Ed;								//波门起始点和结束点

	INT iGateSa_Rx;											//读取的波门地址
	REAL iAdjust_V_Rx;										//读取的纵向修正量
	REAL iAdjust_H_Rx;										//读取的横向修正量
	WORD wStatus_Rx;										//读取的手自动状态等
//	WORD wFlag_TwoWaycomm_Rx;								//读取的HMI修改标志
	static WORD wPlateAdjustmentProf_RX;
	WORD byErrUpdateNum;									//本次600ms误差刷新次数
	static BYTE byPreIndex;									//记录前次的精采样幅数
	BYTE bySendCnt_6;										//发送误差周期发送的总字节数

	INT iJourney_HorzRapidAdjust_HMI_Rx;
	BYTE xStartHorRun;
	static BYTE xStartPlateAdjustmentProf;
	static BYTE byScreen;									//当前屏保位图编号
	BYTE xLocalAxisRollerDn;								//该色组压辊状态
	BYTE xLocalAxisLinkage;									//色组联动状态
	BYTE xLocalAxisEstop;									//色组急停状态
	BYTE xAuto_V;											//纵向自动
	WORD aReturn[5]={0};										//预留5个WORD寄存器,只发送
	WORD aReturn_2[20]={0};										//2022.3.21.110603新增20个变量

	static WORD wProjectCount;								//程序计数
	static BYTE xRuning;
	REAL rAdjust_V_temp,rAdjust_H_temp;
	//程序计数，确认485通讯正常
	wProjectCount++;
	BYTE byTemp;
	BYTE Bitnum;
	static REAL rGirth_Rec;
	BYTE byGrpTemp;
	DWORD dwAlarmFlag;										//2020.7.2.152350||报警信息
	INT iPromptMsgId;																																				//提示信息2020.7.2.152617

	//static BYTE byOldNormalStep;

	INT iPlateAdjustmentProf_RX;
	REAL rPlateAdjustmentProf_Temp;
	DINT diPlateAdjustmentProf_Temp;
	WORD wButtonFun1;
	WORD wButtonFun1_RX;
	WORD wButtonFun;
	//2025.10.28.165757 屏蔽容易混淆的内容
	//WORD wInkRoller_Fre_RX;										//RX递墨辊频率
	WORD wAirInletWindDoorValue_RX;								//RX进风口风门开度值|输入范围(0~100)
	WORD wAirExhaustWindDoorValue_RX;							//RX排风口风门开度值|输入范围(0~100)
	WORD wAirReturnWindDoorValue_RX;							//RX回风口风门开度值|输入范围(0~100)
	//2025.10.28.165757 屏蔽容易混淆的内容
	//WORD wTemperature_Set_RX;									//RX加热温度设置PV
	BYTE bySampleSholdSwitch_RX;								//阀值线选择开关
	WORD wResetNum_RX;											//读取回的复位次数
	//2025.10.28.165757 屏蔽容易混淆的内容
	//WORD wSV_TemCtrl_RX;
	//WORD wSV_TemCtrl_PreHot_RX;

	//2022.3.21.155833新增北人
	WORD wHz_UnitInkRoller_ManuallySet_RX;
	WORD wCoeff_UnitInkRoller_Auto_RX;
	WORD wHz_UnitScraper_ManuallySet_RX;
	WORD wCoeff_UnitScraper_Auto_RX;
	WORD wHz_UnitHotWind_RX;
	//2026.3.11.103830+ 替换为排风
	//WORD wHz_UnitHotWind_2_RX;
	WORD wHz_UnitExhaust_ManuallySet_RX;
	WORD wSV_UnitTemCtl_RX;
	DWORD dwCtlBits_UnitBaseCraft_RX;

	//2023.11.08.102708 同步
	//2023.10.14.85733/wei.n/7吋人机色组IO与ARM通讯
	WORD wUnit_output_I_RX;
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

	WORD wUnit_output_II_RX;
											//Bit0: o_xRel_HotBlower; //热风输出
											//Bit1: o_wInExhaustAir; //色组排风输出
											//Bit2: o_xRel_Heating_I; //加热I输出
											//Bit3: o_xRel_Heating_II; //加热II输出
											//Bit4: o_xRel_Heating_III; //加热III输出
											//Bit5: o_xScraperOn; //刮刀使能
											//Bit6: o_xRel_InkRoller_CW; //递墨辊正转
											//Bit7: o_xRel_InkRoller_Up; //递墨辊上

	static INT iGateSaEx_Rec;
	INT iGateSaEx_RX;

	INT iAxisId_RX;							//回读变量
	static BYTE byErrNum;					//读取非常规参数个数
	INT iJ;

	//屏保当前位图显示处理
	//压辊状态获取
	if ( ( i_pstStGlobalParam->dwAxis_RollerDn & 1<<(i_pstStAxisParam->iAxisId-1 )) != 0 )
	{
		xLocalAxisRollerDn = 1;
	}
	else
	{
		xLocalAxisRollerDn = 0;
	}
	//联动状态
	if ( ( i_pstStGlobalParam->dwComplexFlag_AxisLinkage &
		1<<(i_pstStAxisParam->iAxisId-1 )) != 0 )
	{
		xLocalAxisLinkage = 1;
	}
	else
	{
		xLocalAxisLinkage = 0;
	}
	//急停状态
	if ( ( i_pstStGrpParam->dwAxisFlags_Estop &
		1<<(i_pstStAxisParam->iAxisId-1 )) != 0 )
	{
		xLocalAxisEstop = 1;
	}
	else
	{
		xLocalAxisEstop = 0;
	}

	xAuto_V = (BYTE)(i_pstStAxisParam->wStatusRef & 0x01);			//套色自动
	if(	xLocalAxisLinkage &&
		xLocalAxisRollerDn &&
		xAuto_V &&
		i_pstStGrpParam->lrVelocity>0)
	{
		if( (i_pstStPara_PduBroadcastUp->byStsV & 0x01) )
		{
			byScreen = 0;//报警
		}
		else if( (i_pstStPara_PduBroadcastUp->byStsV & 0x02)>>1 )
		{
			byScreen = 1;//丢失
		}
		else
		{
			byScreen = 2;//正常
		}
	}
	else
	{
		if(xLocalAxisEstop)
		{
			byScreen = 4;	//急停
		}
		else
		{
			byScreen = 3;	//停机
		}
	}

	////>>>>>>>>>>>>>>>>>>>>>>>>>>end

	bySlaveChangeFlag = 0;												//先清零再判断
	wStatus=0;
	byTemp = 0;
	byTemp = GetBit(i_pstStAxisParam->wStatusRef,0);					//获取bit0-纵向自动
	wStatus = SetBit(byTemp,wStatus,0);

	byTemp = 0;
	byTemp = GetBit(i_pstStAxisParam->wStatusRef,1);								//横向手自动
	wStatus = SetBit(byTemp,wStatus,1);

	byTemp = 0;
	byTemp = GetBit(i_pstStAxisParam->wStatusRef,8);								//纵向跟任意色
	wStatus = SetBit(byTemp,wStatus,14);

	byTemp = 0;
	byTemp = GetBit(i_pstStAxisParam->wStatusRef,9);								//横向跟任意色
	wStatus = SetBit(byTemp,wStatus,15);

	byTemp = 0;
	byTemp = GetBit(i_pstStAxisParam->wSwitchRef,0);								//横向开关
	wStatus = SetBit(byTemp,wStatus,3);

	byTemp = 0;
	byTemp = GetBit(i_pstStAxisParam->wSts_HorzManuPreReg,0);						//横向运行中
	wStatus = SetBit(byTemp,wStatus,4);

	wStatus = SetBit(*i_pxOK_PosConfirmed,wStatus,6);								//单标记位置确认按钮

	wStatus = SetBit(xStartPlateAdjustmentProf,wStatus,7);
	if(((xLocalAxisRollerDn==1)|(xStartPlateAdjustmentProf==1))&& (xLocalAxisLinkage==1)&&
		(i_pstStGrpParam->xFlag_Print==1)&& (i_pstStGrpParam->lrVelocity<=30))
	{
		wStatus = SetBit(1,wStatus,8);
	}
	else
	{
		wStatus = SetBit(0,wStatus,8);
	}

	//2020.6.29.170923||增加反极性切换从站通讯动作
	//bit9和bit10分别T1T2反极性
	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,5);
	wStatus = SetBit(byTemp, wStatus, 9);//bit9

	byTemp = GetBit_DWORD(i_pstStAxisParam->dwControlBits,6);						//T2反极性

	wStatus = SetBit(byTemp, wStatus, 10);//bit10

	wStatus = SetBit(*i_pxFlag_Mag, wStatus, 11);//bit11

//bit14更新到其他单向位置---
//	byTemp = GetBit_DWORD(i_pstStGlobalParam->dwControlComplexBits,30);				//显示原始波形/棍棍图切换---1棍棍图、、0原始波形2021.6.17.151429
//	wStatus = SetBit(byTemp, wStatus, 14);//bit14
	//---------------------------------------------------------------------------------
	//2020.7.2.141403||系号
	byTemp = GetBit(i_pstStGlobalParam->wMachineArchitectureRef,0);

	//2025.10.28.165757 屏蔽容易混淆的内容
	//i_pstStAxisParam->wInkRoller_Fre= (WORD)i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet;

	if(byTemp==0)
	{
		byGrpTemp = 0;
	}
	else
	{
		byGrpTemp = i_pstStAxisParam->byGrpId;
	}

	if( iGateSa_Rec != i_pstStAxisParam->iGateSa )											//波门位置
	{
		bySlaveChangeFlag = 1;
	}
	//2023.4.24.225233|双波门
	else if(iGateSaEx_Rec != i_pstStAxisParam->iGateSaEx)
	{
		bySlaveChangeFlag = 1;
	}
	else if( rAdjust_V_Rec != i_pstStAxisParam->lrAdjust_V )								//纵向修正量
	{
		bySlaveChangeFlag = 1;
	}
	else if( rAdjust_H_Rec != i_pstStAxisParam->lrAdjust_H )								//横向修正量
	{
		bySlaveChangeFlag = 1;
	}
	else if( wStatus_Rec != wStatus )														//状态
	{
		bySlaveChangeFlag = 1;
	}
	else if( iAxisId_Rec != i_pstStAxisParam->iAxisId )										//轴号
	{
		bySlaveChangeFlag = 1;
	}
	else if( byGrpId_Rec != byGrpTemp )														//系号
	{
		bySlaveChangeFlag = 1;
	}
	else if( byLanguageId_Rec != i_pstStGlobalParam->byLanguageId )							//语言选择
	{
		bySlaveChangeFlag = 1;
	}
	else if( lrAlarm_V_Rec != i_pstStAxisParam->lrAlarm_V )									//纵向报警值
	{
		bySlaveChangeFlag = 1;
	}
	else if( lrAlarm_H_Rec != i_pstStAxisParam->lrAlarm_H )									//横向报警值
	{
		bySlaveChangeFlag = 1;
	}
	else if( iGateWidthPhy_Rec != i_pstStAxisParam->iGateWidthPhy )							//波门宽度
	{
		bySlaveChangeFlag = 1;
	}
	else if( rGirth_Rec != i_pstStAxisParam->lrGirth)										//版周长
	{
		bySlaveChangeFlag = 1;
	}
	else if (xPreFlag_Mag != *i_pxFlag_Mag)
	{
		bySlaveChangeFlag = 1;
	}
	else if(i_iWave_offset_Rec != i_iWave_offset)
	{
		bySlaveChangeFlag = 1;
		*i_pxRefresh_Flag = 1;																//位移量变化，标志置1
	}
	else if(wButtonFun_Rec != i_pstStAxisParam->wButtonFun)
	{
		bySlaveChangeFlag = 1;
	}
	//2026.1.31.154420+
	else if(byUnLockHmi_UI_Rec != i_pstStGlobalParam->byUnLockHmi_UI)
	{
		bySlaveChangeFlag = 1;
	}
	//2025.10.28.165757 屏蔽容易混淆的内容
	/*
	else if(wInkRoller_Fre_Rec != i_pstStAxisParam->wInkRoller_Fre)
	{
		bySlaveChangeFlag = 1;
	}*/
	else if(wAirInletWindDoorValue_Rec != i_pstStAxisParam->wAirInletWindDoorValue)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wAirExhaustWindDoorValue_Rec != i_pstStAxisParam->wAirExhaustWindDoorValue)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wAirReturnWindDoorValue_Rec != i_pstStAxisParam->wAirReturnWindDoorValue)
	{
		bySlaveChangeFlag = 1;
	}
	//2025.10.28.165757 屏蔽容易混淆的内容
	/*
	else if(wTemperature_Set_Rec != i_pstStAxisParam->wTemperature_Set)
	{
		bySlaveChangeFlag = 1;
	}*/
	else if(bySampleSholdSwitch_Rec != i_pstStAxisParam->bySampleSholdSwitch)
	{
		bySlaveChangeFlag = 1;
	}
	//2021.6.25.105115新增
	else if( iGateWidthRondPt_Rec != i_pstStAxisParam->iGateWidthRondPt)
	{
		bySlaveChangeFlag = 1;
	}
	else if( bySample_Interval_Rec != i_bySample_Interval)
	{
		bySlaveChangeFlag = 1;
	}
	//2025.10.28.165757 屏蔽容易混淆的内容
	/*else if(wSV_TemCtrl_PreHot != i_pstStAxisParam->wSV_TemCtrl_PreHot)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wSV_TemCtrl != i_pstStAxisParam->wSV_TemCtrl)
	{
		bySlaveChangeFlag = 1;
	}
	else if(byAxisRoller_UpperFrq_Rec !=  i_pstStAxisParam->byAxisRoller_UpperFrq)
	{
		bySlaveChangeFlag = 1;
	}*/
	//2022.3.21.160213北人新增
	else if(wHz_UnitInkRoller_ManuallySet_Rec !=  i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wCoeff_UnitInkRoller_Auto_Rec !=  i_pstStAxisParam->wCoeff_UnitInkRoller_Auto)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wHz_UnitScraper_ManuallySet_Rec !=  i_pstStAxisParam->wHz_UnitScraper_ManuallySet)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wCoeff_UnitScraper_Auto_Rec !=  i_pstStAxisParam->wCoeff_UnitScraper_Auto)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wHz_UnitHotWind_Rec !=  i_pstStAxisParam->wHz_UnitHotWind)
	{
		bySlaveChangeFlag = 1;
	}
	//2026.3.11.104227 替换为排风
//	else if(wHz_UnitHotWind_2_Rec !=  i_pstStAxisParam->wHz_UnitHotWind_2)
//	{
//		bySlaveChangeFlag = 1;
//	}
	else if(wHz_UnitExhaust_ManuallySet_rec !=  i_pstStAxisParam->wHz_UnitExhaust_ManuallySet)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wSV_UnitTemCtl_Rec !=  i_pstStAxisParam->wSV_UnitTemCtl)
	{
		bySlaveChangeFlag = 1;
	}
	else if(dwCtlBits_UnitBaseCraft_Rec !=  i_pstStAxisParam->dwCtlBits_UnitBaseCraft)
	{
		bySlaveChangeFlag = 1;
	}
	//2022.3.21.160231
	else if(byLedSwitchTimeouts_Rec!=i_byLedSwitchTimeouts)//2022.5.12.143635
	{
		bySlaveChangeFlag = 1;
	}
	//2023.11.08.102739同步
	// 2023.10.14.91303/wei.n/7吋人机色组IO与ARM通讯
	else if(wUnit_output_I_Rec != i_pstStAxisParam->wUnit_output_I)
	{
		bySlaveChangeFlag = 1;
	}
	else if(wUnit_output_II_Rec != i_pstStAxisParam->wUnit_output_II)
	{
		bySlaveChangeFlag = 1;
	}
	else
	{
		bySlaveChangeFlag = 0;																							//没有参数改变，则不进入SendStep=1的逻辑
	}
	if( bySlaveChangeFlag != 0 )
	{
		bySendStep = 1;																									//直接进入发送双向参数逻辑
	}

	////////////////////////判断从站修改标志//////////////////////////
	if( bySlaveChangeFlag == 0 )																						//前提是主站参数未修改
	{
		if( xReceiveSuccessful )																						//接收数据完成校验通过
		{
			xReceiveSuccessful = 0;																						//清除标志
			if( RS485_RX_BUFF[1] == 0x03 )																				//功能码为03时，读取周期
			{
				//默认50个寄存器最后15个是只用来读的
				//2025.10.28.165757 屏蔽容易混淆的内容
				//wInkRoller_Fre_RX= ((WORD)(RS485_RX_BUFF[41]) << 8) + (WORD)(RS485_RX_BUFF[42]);						//递墨辊频率@6020
				wAirInletWindDoorValue_RX= ((WORD)(RS485_RX_BUFF[43]) << 8) + (WORD)(RS485_RX_BUFF[44]);				//RX进风口风门开度值|输入范围(0~100)
				wAirExhaustWindDoorValue_RX= ((WORD)(RS485_RX_BUFF[45]) << 8) + (WORD)(RS485_RX_BUFF[46]);				//RX排风口风门开度值|输入范围(0~100)
				wAirReturnWindDoorValue_RX= ((WORD)(RS485_RX_BUFF[47]) << 8) + (WORD)(RS485_RX_BUFF[48]);				//RX回风口风门开度值|输入范围(0~100)
				//读出风门及频率值进行判断合理性
				//相当于我们认为，人机同一个周期读到的值不应该是同时修改两个或者两个以上
				byErrNum=0;
				//2025.10.28.165757 屏蔽容易混淆的内容
				//if(wInkRoller_Fre_RX!=i_pstStAxisParam->wInkRoller_Fre)  byErrNum=byErrNum+1;
				if(wAirInletWindDoorValue_RX!=i_pstStAxisParam->wAirInletWindDoorValue)  byErrNum=byErrNum+1;
				if(wAirExhaustWindDoorValue_RX!=i_pstStAxisParam->wAirExhaustWindDoorValue)  byErrNum=byErrNum+1;
				if(wAirReturnWindDoorValue_RX!=i_pstStAxisParam->wAirReturnWindDoorValue)  byErrNum=byErrNum+1;

				wResetNum_RX= ((WORD)(RS485_RX_BUFF[81]) << 8) + (WORD)(RS485_RX_BUFF[82]);								//回读复位参数标志
				iAxisId_RX= (INT)((WORD)((RS485_RX_BUFF[19]) << 8) + (WORD)(RS485_RX_BUFF[20]));						//回读轴号同时进行判断
				if (wResetNum_RX<=0 || iAxisId_RX!=i_pstStAxisParam->iAxisId || byErrNum>=2)							//读取人机界面复位\\轴号异常\\同时变了两个变量
				{
					xReset=1;//复位标志置1，同时强制更新一次界面参数
					bySendStep = 1;//更新一次参数
				}
				else
				{
					wPlateAdjustmentProf_RX= ((WORD)(RS485_RX_BUFF[15]) << 8) + (WORD)(RS485_RX_BUFF[16]);				//读取到的快速对版量(0~800)||2020.6.18.133842
					iJourney_HorzRapidAdjust_HMI_Rx= ((WORD)(RS485_RX_BUFF[17]) << 8) + (WORD)(RS485_RX_BUFF[18]);		//读取到界面横向设定值
					iGateSa_Rx = ((WORD)(RS485_RX_BUFF[7]) << 8) + (WORD)(RS485_RX_BUFF[8]);							//读取的波门
					//2023.4.24.225233|双波门
					iGateSaEx_RX = ((WORD)(RS485_RX_BUFF[57]) << 8) + (WORD)(RS485_RX_BUFF[58]);						//第二路波门

					iAdjust_V_Rx = (INT)((WORD)((RS485_RX_BUFF[3]) << 8) + (WORD)(RS485_RX_BUFF[4]));					//读取的修正量
					iAdjust_H_Rx = (INT)((WORD)((RS485_RX_BUFF[5]) << 8) + (WORD)(RS485_RX_BUFF[6]));
					wStatus_Rx = ((WORD)(RS485_RX_BUFF[9]) << 8) + (WORD)(RS485_RX_BUFF[10]);										//读取的手自动状态

					wButtonFun1_RX= ((WORD)(RS485_RX_BUFF[13]) << 8) + (WORD)(RS485_RX_BUFF[14]);								//双向按钮

					wButtonFun=wButtonFun1_RX;
					i_pstStAxisParam->wButtonFun = wButtonFun;

					//2025.10.28.165757 屏蔽容易混淆的内容
					//wTemperature_Set_RX= ((WORD)(RS485_RX_BUFF[49]) << 8) + (WORD)(RS485_RX_BUFF[50]);						//RX加热温度设置SV
					//wSV_TemCtrl_PreHot_RX =  ((WORD)(RS485_RX_BUFF[39]) << 8) + (WORD)(RS485_RX_BUFF[40]);				//预加热温度设定
					//wSV_TemCtrl_RX =  ((WORD)(RS485_RX_BUFF[11]) << 8) + (WORD)(RS485_RX_BUFF[12]);				//加热温度设定

					wPowerOnSync=((WORD)(RS485_RX_BUFF[33]) << 8) + (WORD)(RS485_RX_BUFF[34]);
					byPowerOn_Flag = GetBit(wPowerOnSync, 15);

					bySampleSholdSwitch_RX = RS485_RX_BUFF[52];
					//最后15个指示用来读，单向往上发的
					i_pstStAxisParam->wUpAdjButton_Count =((WORD)(RS485_RX_BUFF[85]) << 8) + (WORD)(RS485_RX_BUFF[86]);//MCGS调整上按钮计数 71=34*2+3  6042
					i_pstStAxisParam->wDnAdjButton_Count =((WORD)(RS485_RX_BUFF[87]) << 8) + (WORD)(RS485_RX_BUFF[88]);//MCGS调整下按钮计数//6043
					i_pstStAxisParam->wLeftAdjButton_Count =((WORD)(RS485_RX_BUFF[89]) << 8) + (WORD)(RS485_RX_BUFF[90]);//MCGS调整左按钮计数//6044
					i_pstStAxisParam->wRightAdjButton_Count =((WORD)(RS485_RX_BUFF[91]) << 8) + (WORD)(RS485_RX_BUFF[92]);//MCGS调整右按钮计数//6045
					i_pstStAxisParam->wAlarmButton_Count =((WORD)(RS485_RX_BUFF[93]) << 8) + (WORD)(RS485_RX_BUFF[94]);//MCGS报警按钮计数//6046
					//2022.7.3.114632增加加减速按钮通寻
					i_pstStAxisParam->wAccButton_Count =((WORD)(RS485_RX_BUFF[111]) << 8) + (WORD)(RS485_RX_BUFF[112]);//MCGS报警按钮计数//6055
					i_pstStAxisParam->wDecButton_Count =((WORD)(RS485_RX_BUFF[113]) << 8) + (WORD)(RS485_RX_BUFF[114]);//MCGS报警按钮计数//6056

					//2022.3.21.155336读取返回值
					i_pstStAxisParam->rHz_UnitInkRoller_CurrRD =(REAL)(((WORD)(RS485_RX_BUFF[95]) << 8) + (WORD)(RS485_RX_BUFF[96]));//递墨辊实际频率//6047
					i_pstStAxisParam->wSTS_UnitInkRoller =((WORD)(RS485_RX_BUFF[97]) << 8) + (WORD)(RS485_RX_BUFF[98]);//递墨辊变频状态//6048
					i_pstStAxisParam->rHz_UnitScraper_CurrRD =(REAL)(((WORD)(RS485_RX_BUFF[99]) << 8) + (WORD)(RS485_RX_BUFF[100]));//刮刀实际频率//6049
					i_pstStAxisParam->wSTS_UnitScraper =((WORD)(RS485_RX_BUFF[101]) << 8) + (WORD)(RS485_RX_BUFF[102]);//刮刀状态//6050
					i_pstStAxisParam->wSTS_UnitHotWind =((WORD)(RS485_RX_BUFF[103]) << 8) + (WORD)(RS485_RX_BUFF[104]);//热风1状态//6051
					//2026.3.11.090516 替换为了排风
					//i_pstStAxisParam->wSTS_UnitHotWind_2 =((WORD)(RS485_RX_BUFF[105]) << 8) + (WORD)(RS485_RX_BUFF[106]);//热风2状态//6052
					i_pstStAxisParam->wSTS_UnitExhaust =((WORD)(RS485_RX_BUFF[105]) << 8) + (WORD)(RS485_RX_BUFF[106]);//热风2状态//6052

					i_pstStAxisParam->rHz_UnitHotWind_CurrRD =((WORD)(RS485_RX_BUFF[107]) << 8) + (WORD)(RS485_RX_BUFF[108]);//热风频率2022.3.31.111037//6053
					//i_pstStAxisParam->rHz_UnitHotWind2_CurrRD =((WORD)(RS485_RX_BUFF[109]) << 8) + (WORD)(RS485_RX_BUFF[110]);//热风频率2022.3.31.111037//6054
					//2026.3.11.085818 热风2地址替换为排风
					i_pstStAxisParam->wHz_UnitExhaust_CurrRD =((WORD)(RS485_RX_BUFF[109]) << 8) + (WORD)(RS485_RX_BUFF[110]);//热风频率2022.3.31.111037//6054

//					i_pstStAxisParam->rAxisRoller_Frq =((WORD)(RS485_RX_BUFF[85]) << 8) + (WORD)(RS485_RX_BUFF[86]);//当前预热温度6040

					i_pstStAxisParam->wMCGS_SingleSwitch = ((WORD)(RS485_RX_BUFF[53]) << 8) + (WORD)(RS485_RX_BUFF[54]);//单向按钮	2021.6.1.152150|||移到6025

					//2023.11.08.102930 同步
					// 2023.10.14.93553/wei.n/7吋人机色组IO与ARM通讯
					wUnit_output_I_RX = ((WORD)(RS485_RX_BUFF[59]) << 8) + (WORD)(RS485_RX_BUFF[60]);
					wUnit_output_II_RX = ((WORD)(RS485_RX_BUFF[61]) << 8) + (WORD)(RS485_RX_BUFF[62]);

					//2022.3.21.160743新增北人相关
					wHz_UnitInkRoller_ManuallySet_RX = ((WORD)(RS485_RX_BUFF[63]) << 8) + (WORD)(RS485_RX_BUFF[64]);//6031
					wCoeff_UnitInkRoller_Auto_RX = ((WORD)(RS485_RX_BUFF[65]) << 8) + (WORD)(RS485_RX_BUFF[66]);//6032
					wHz_UnitScraper_ManuallySet_RX = ((WORD)(RS485_RX_BUFF[67]) << 8) + (WORD)(RS485_RX_BUFF[68]);//6033
					wCoeff_UnitScraper_Auto_RX = ((WORD)(RS485_RX_BUFF[69]) << 8) + (WORD)(RS485_RX_BUFF[70]);//6034
					wHz_UnitHotWind_RX = ((WORD)(RS485_RX_BUFF[71]) << 8) + (WORD)(RS485_RX_BUFF[72]);//6035
					//2026.3.11.103949 替换为排风
					//wHz_UnitHotWind_2_RX = ((WORD)(RS485_RX_BUFF[73]) << 8) + (WORD)(RS485_RX_BUFF[74]);//6036
					wHz_UnitExhaust_ManuallySet_RX = ((WORD)(RS485_RX_BUFF[73]) << 8) + (WORD)(RS485_RX_BUFF[74]);//6036
					wSV_UnitTemCtl_RX = ((WORD)(RS485_RX_BUFF[75]) << 8) + (WORD)(RS485_RX_BUFF[76]);//6037
					dwCtlBits_UnitBaseCraft_RX = ((DWORD)(RS485_RX_BUFF[77]) << 24) + ((DWORD)(RS485_RX_BUFF[78]) << 16)//6038
						+ ((DWORD)(RS485_RX_BUFF[79]) << 8) + ((DWORD)(RS485_RX_BUFF[80]));


					//只读的数据|这里的数据索引是最后的@最大120@2025.10.17.142335+
					//2个word
					i_pstStAxisParam->dwEncValue_Hor =((DWORD)(RS485_RX_BUFF[115]) << 24) + ((DWORD)(RS485_RX_BUFF[116]) << 16) //6057->6058
								+ ((DWORD)(RS485_RX_BUFF[117]) << 8) + ((DWORD)(RS485_RX_BUFF[118]));
					//横向编码器值有效标志@位于第15bit
					//RS485_RX_BUFF[119] 6059中高8bit的数据|未处理
					i_pstStAxisParam->xEncValueIsValid_Hor  = GetBit(RS485_RX_BUFF[120],0);//6059中低8bit的数据//第0bit是横向有效
					i_pstStAxisParam->xHorMotorAlarm  = GetBit(RS485_RX_BUFF[120],1);//6059中低8bit的数据//第1bit是横向报警

				//双置信度/飞点开关位与s50输入解析(2026.11.11组态屏改版:开关并入46059编码器
				//位区,s50用4WUB6060;读命令维持0x3C不扩——0x3C读协议6000~6059=MCGS6001~6060,
				//46059/6060均在范围内,MCGS寄存器R(=协议R-1,k=R-6001)占RX_BUFF[2R-11999]高+[2R-11998]低);
				//开关位与编码器同字节:46059低8位=RX_BUFF[120],bit2=飞点|bit3=置信度|bit4=下发
				//使能(=0忽略位写入——屏幕未配置读回0,保护ARM默认行为飞点=1/置信度=0);
				//s50=4WUB6060→[121,122],单位0.001mm,范围1~1000,越界保持原值,写入下一圈生效;
				//短帧(双向参数0x28读)时这些字节为上一帧0x3C读的原值,重复赋值幂等无害
				//——与上方编码器解析同模式|wang.c+双置信度融合 2026.11.10.090134|组态屏改版适配 2026.11.11
				{
					BYTE bySwitchBits_RX;
					WORD wConfS50_RX;
					bySwitchBits_RX = RS485_RX_BUFF[120];//MCGS46059低8位(bit0/1编码器原有,bit2/3/4开关)
					wConfS50_RX = ((WORD)(RS485_RX_BUFF[121]) << 8) + (WORD)(RS485_RX_BUFF[122]);//MCGS4WUB6060=s50输入
					if (GetBit(bySwitchBits_RX, 4))//屏幕写入了使能位(xSwitchWrEn)才生效
					{
						xEnableNewFlyRemove = GetBit(bySwitchBits_RX, 2);//飞点开关:1=新Theil-Sen剔除(默认)|0=回退旧二阶差分(翻转触发剔除器复位)
						xEnableConfErr = GetBit(bySwitchBits_RX, 3);//置信度开关:1=上报双置信度融合误差|0=原每圈算一个(默认)
						if (wConfS50_RX >= 1 && wConfS50_RX <= 1000)
						{
							rConfS50Mm = (REAL)wConfS50_RX / 1000.0f;//s50输入mm(s=s50时CK置信度C=50%)
						}
					}
				}


					//if(( iGateSa_Rx >= 0 && iGateSa_Rx < 3999 ) &&
					if(( iGateSa_Rx >= 0 && iGateSa_Rx <= 3999 ) &&//偶发出现波门地址为3999时导致人机参数不能被修改|一直处于485写入。@2025.7.15.182902
						( iAdjust_V_Rx >= -6000 && iAdjust_V_Rx <= 6000 ) &&
						( iAdjust_H_Rx >= -6000 && iAdjust_H_Rx <= 6000 ))//接收的数据合理判断
					{
						if( (iGateSa_Rx != i_pstStAxisParam->iGateSa) ||
							//2023.4.24.225557双波门
							(iGateSaEx_RX != i_pstStAxisParam->iGateSaEx) ||
							(((iAdjust_V_Rx)) != (INT)(i_pstStAxisParam->lrAdjust_V*100)) ||
							(((iAdjust_H_Rx)) != (INT)(i_pstStAxisParam->lrAdjust_H*100)) ||
							(wStatus_Rx != wStatus)  ||
							//2025.10.28.165757 屏蔽容易混淆的内容
							//(wInkRoller_Fre_RX!=i_pstStAxisParam->wInkRoller_Fre)||
							(wAirInletWindDoorValue_RX!=i_pstStAxisParam->wAirInletWindDoorValue)||
							(wAirExhaustWindDoorValue_RX!=i_pstStAxisParam->wAirExhaustWindDoorValue)||
							(wAirReturnWindDoorValue_RX!=i_pstStAxisParam->wAirReturnWindDoorValue)||
							//2025.10.28.165757 屏蔽容易混淆的内容
							//(wTemperature_Set_RX!=i_pstStAxisParam->wTemperature_Set)||
							(bySampleSholdSwitch_RX!=i_pstStAxisParam->bySampleSholdSwitch) ||
							//2025.10.28.165757 屏蔽容易混淆的内容
							//2021.10.28.111005新增读取界面设定值
							//(wSV_TemCtrl_RX !=  i_pstStAxisParam->wSV_TemCtrl) ||
							//(wSV_TemCtrl_PreHot_RX !=  i_pstStAxisParam->wSV_TemCtrl_PreHot) ||
							//2022.3.21.161239新增北人
							(wHz_UnitInkRoller_ManuallySet_RX != i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet) ||
							(wCoeff_UnitInkRoller_Auto_RX != i_pstStAxisParam->wCoeff_UnitInkRoller_Auto) ||
							(wHz_UnitScraper_ManuallySet_RX != i_pstStAxisParam->wHz_UnitScraper_ManuallySet) ||
							(wCoeff_UnitScraper_Auto_RX != i_pstStAxisParam->wCoeff_UnitScraper_Auto) ||
							(wHz_UnitHotWind_RX != i_pstStAxisParam->wHz_UnitHotWind) ||
							//2026.3.11.104111 替换为排风
							//(wHz_UnitHotWind_2_RX != i_pstStAxisParam->wHz_UnitHotWind_2) ||
							(wHz_UnitExhaust_ManuallySet_RX != i_pstStAxisParam->wHz_UnitExhaust_ManuallySet) ||
							(wSV_UnitTemCtl_RX != i_pstStAxisParam->wSV_UnitTemCtl) ||
							(dwCtlBits_UnitBaseCraft_RX != i_pstStAxisParam->dwCtlBits_UnitBaseCraft)||
							//2023.11.08.103030 同步
							//2023.10.14.93931/wei.n/7吋人机色组IO与ARM通讯
							(wUnit_output_I_RX != i_pstStAxisParam->wUnit_output_I) ||
							(wUnit_output_II_RX != i_pstStAxisParam->wUnit_output_II)
							)
						{
							//2022.3.21.161750新增北人
							i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet	= wHz_UnitInkRoller_ManuallySet_RX;
							i_pstStAxisParam->wCoeff_UnitInkRoller_Auto		= wCoeff_UnitInkRoller_Auto_RX;
							i_pstStAxisParam->wHz_UnitScraper_ManuallySet	= wHz_UnitScraper_ManuallySet_RX;
							i_pstStAxisParam->wCoeff_UnitScraper_Auto		= wCoeff_UnitScraper_Auto_RX;
							i_pstStAxisParam->wHz_UnitHotWind				= wHz_UnitHotWind_RX;
							//2026.3.11.103804 替换为排风
							//i_pstStAxisParam->wHz_UnitHotWind_2				= wHz_UnitHotWind_2_RX;
							i_pstStAxisParam->wHz_UnitExhaust_ManuallySet	= wHz_UnitExhaust_ManuallySet_RX;
							i_pstStAxisParam->wSV_UnitTemCtl				= wSV_UnitTemCtl_RX;
							i_pstStAxisParam->dwCtlBits_UnitBaseCraft 		= dwCtlBits_UnitBaseCraft_RX;
							//2023.11.08.103110 同步
							//2023.10.14.94158/wei.n/7寸人机色组IO与ARM通讯
							i_pstStAxisParam->wUnit_output_I 				= wUnit_output_I_RX;
							i_pstStAxisParam->wUnit_output_II 				= wUnit_output_II_RX;

							//2025.10.28.165757 屏蔽容易混淆的内容
							//i_pstStAxisParam->wSV_TemCtrl					= wSV_TemCtrl_RX;

							//i_pstStAxisParam->wSV_TemCtrl_PreHot			= wSV_TemCtrl_PreHot_RX;
							i_pstStAxisParam->wButtonFun 					= wButtonFun;

							wButtonFun1 = wButtonFun1_RX;
							//2025.10.28.165757 屏蔽容易混淆的内容
							//i_pstStAxisParam->wInkRoller_Fre				= wInkRoller_Fre_RX;
							//i_pstStAxisParam->rHz_AxisInkRoller_ManuallySet	= (REAL)wInkRoller_Fre_RX;
							i_pstStAxisParam->wAirInletWindDoorValue		= wAirInletWindDoorValue_RX;
							i_pstStAxisParam->wAirExhaustWindDoorValue		= wAirExhaustWindDoorValue_RX;
							i_pstStAxisParam->wAirReturnWindDoorValue 		= wAirReturnWindDoorValue_RX;
							//2025.10.28.165757 屏蔽容易混淆的内容
							//i_pstStAxisParam->wTemperature_Set				= wTemperature_Set_RX;
							i_pstStAxisParam->bySampleSholdSwitch			= bySampleSholdSwitch_RX;
//							wFlag_TwoWaycomm_Rx = 0;//清除标志
							i_pstStAxisParam->iGateSaEx           			= iGateSaEx_RX;
							i_pstStAxisParam->iGateSa 						= iGateSa_Rx;//波门地址
							i_pstStAxisParam->lrAdjust_V 					= (REAL)(iAdjust_V_Rx) / 100;//纵向修正
							i_pstStAxisParam->lrAdjust_H 					= (REAL)(iAdjust_H_Rx) / 100;//横向修正
							//2020.5.28.162022|niu.j|新增Getbit和Setbit函数
							byTemp = 0;
							byTemp = GetBit(wStatus_Rx,0);//纵向手自动
							i_pstStAxisParam->wStatusRef = SetBit(byTemp,i_pstStAxisParam->wStatusRef,0);

							byTemp = 0;
							byTemp = GetBit(wStatus_Rx,1);//横向手自动
							i_pstStAxisParam->wStatusRef = SetBit(byTemp,i_pstStAxisParam->wStatusRef,1);

							//2020.6.29.170923||增加反极性切换从站通讯动作
							byTemp = 0;
							byTemp = GetBit(wStatus_Rx,9);//T1反极性

							i_pstStAxisParam->dwControlBits  = SetBit_DWORD(byTemp,i_pstStAxisParam->dwControlBits,5);

							byTemp = 0;
							byTemp = GetBit(wStatus_Rx,10);//T2反极性
							i_pstStAxisParam->dwControlBits  = SetBit_DWORD(byTemp,i_pstStAxisParam->dwControlBits,6);

							byTemp = 0;
							byTemp = GetBit(wStatus_Rx,14);//纵向跟任意色
							i_pstStAxisParam->wStatusRef = SetBit(byTemp,i_pstStAxisParam->wStatusRef,8);

							byTemp = 0;
							byTemp = GetBit(wStatus_Rx,15);//横向跟任意色
							i_pstStAxisParam->wStatusRef = SetBit(byTemp,i_pstStAxisParam->wStatusRef,9);

							//---------------------------------------------------------------------------------

							xStartPlateAdjustmentProf= GetBit(wStatus_Rx,7);
							if(xStartPlateAdjustmentProf)
							{
								if(wPlateAdjustmentProf_RX!=0)
								{
									//2020.11.19.132619@niu.j负调整量调整问题
									iPlateAdjustmentProf_RX= (INT)wPlateAdjustmentProf_RX;
									rPlateAdjustmentProf_Temp=(((REAL)(iPlateAdjustmentProf_RX)*i_pstStAxisParam->lrGirth*1000)/800);
									diPlateAdjustmentProf_Temp= (DINT)rPlateAdjustmentProf_Temp;
									dwPlateAdjustmentProf= (DWORD)diPlateAdjustmentProf_Temp;
									*i_pdwPlateAdjustmentProf=dwPlateAdjustmentProf;
									dwPlateAdjustmentProf=0;
									wPlateAdjustmentProf_RX=0;
								}
							}
							xStartHorRun = GetBit(wStatus_Rx,2);

							*i_pxOK_PosConfirmed = GetBit(wStatus_Rx,6);//单标记误差确认
							//处理横向运行
							if( xStartHorRun )
							{
								xStartHorRun = 0;
								xRuning = (BYTE)(i_pstStAxisParam->wSts_HorzManuPreReg & 0x01);
								if( !xRuning )
								{
									if( iJourney_HorzRapidAdjust_HMI_Rx != 0 &&
										iJourney_HorzRapidAdjust_HMI_Rx > -1000 &&
										iJourney_HorzRapidAdjust_HMI_Rx <1000)//读取 的横向运行值在合理范围
									{
										*i_piJourney_HorzRapidAdjust = iJourney_HorzRapidAdjust_HMI_Rx;
										iJourney_HorzRapidAdjust_HMI_Rx= 0;
									}
								}
								else
								{
									*i_piJourney_HorzRapidAdjust = -32767;
								}
								wStatus_Rx &= ~(1<<2);
							}

							byTemp = 0;
							byTemp = GetBit(i_pstStAxisParam->wSts_HorzManuPreReg,0);//横向运行中
							wStatus_Rx = SetBit(byTemp,wStatus_Rx,4);

							wStatus = wStatus_Rx;//状态

							//同时更新修改标志位
							bySendStep = 1;//更新一次参数
						}
					}
					else//如果读取的参数不合理，直接强制将主站参数刷新
					{
//						wFlag_TwoWaycomm_Rx = 0;
						bySendStep = 1;
					}
				}
			}
			else//功能吗不为03时不做处理
			{
				;
			}
		}
	}

	//********************************移动到此处|这样会保证不会因为接收到数据和备份值不同(_Rec)重新触发发送@2024.02.01.095148|Liu.yt
	iGateSa_Rec = i_pstStAxisParam->iGateSa;																							//波门位置
	rAdjust_V_Rec = i_pstStAxisParam->lrAdjust_V;																						//横向修正量
	rAdjust_H_Rec = i_pstStAxisParam->lrAdjust_H;																						//纵向修正量
	wStatus_Rec = wStatus;																														//纵向修正量
	iAxisId_Rec = i_pstStAxisParam->iAxisId;																								//轴号
	byGrpId_Rec = byGrpTemp;																													//系参数
	byLanguageId_Rec = i_pstStGlobalParam->byLanguageId;																		//语言选择
	lrAlarm_V_Rec = i_pstStAxisParam->lrAlarm_V;																						//纵向报警值
	lrAlarm_H_Rec = i_pstStAxisParam->lrAlarm_H;																						//横向报警值
	iGateWidthPhy_Rec = i_pstStAxisParam->iGateWidthPhy;																		//波门宽度
	rGirth_Rec = i_pstStAxisParam->lrGirth;																									//版周长更新了，波门占据的像素点需要刷新一次。2020.6.8.170304||niu.j
	xPreFlag_Mag = *i_pxFlag_Mag;
	i_iWave_offset_Rec = i_iWave_offset;
	wButtonFun_Rec = i_pstStAxisParam->wButtonFun;
	//2025.10.28.165757 屏蔽容易混淆的内容
	//wInkRoller_Fre_Rec = i_pstStAxisParam->wInkRoller_Fre;
	byUnLockHmi_UI_Rec = i_pstStGlobalParam->byUnLockHmi_UI;//2026.1.31.154312+
	wAirInletWindDoorValue_Rec = i_pstStAxisParam->wAirInletWindDoorValue;
	wAirExhaustWindDoorValue_Rec= i_pstStAxisParam->wAirExhaustWindDoorValue;
	wAirReturnWindDoorValue_Rec = i_pstStAxisParam->wAirReturnWindDoorValue;
	//2025.10.28.165757 屏蔽容易混淆的内容
	//wTemperature_Set_Rec = i_pstStAxisParam->wTemperature_Set;
	bySampleSholdSwitch_Rec = i_pstStAxisParam->bySampleSholdSwitch;
	//2025.10.28.165757 屏蔽容易混淆的内容
	//2021.10.27.213502||新增奥特马兼容
	//wSV_TemCtrl_PreHot = i_pstStAxisParam->wSV_TemCtrl_PreHot;
	//wSV_TemCtrl = i_pstStAxisParam->wSV_TemCtrl;
	//byAxisRoller_UpperFrq_Rec =  i_pstStAxisParam->byAxisRoller_UpperFrq;
	//2021.6.25.104829新增
	iGateWidthRondPt_Rec=i_pstStAxisParam->iGateWidthRondPt ;
	bySample_Interval_Rec= i_bySample_Interval;
	////2022.3.21.160351北人新增
	wHz_UnitInkRoller_ManuallySet_Rec=i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet ;
	wCoeff_UnitInkRoller_Auto_Rec=i_pstStAxisParam->wCoeff_UnitInkRoller_Auto ;
	wHz_UnitScraper_ManuallySet_Rec=i_pstStAxisParam->wHz_UnitScraper_ManuallySet ;
	wCoeff_UnitScraper_Auto_Rec=i_pstStAxisParam->wCoeff_UnitScraper_Auto ;
	wHz_UnitHotWind_Rec=i_pstStAxisParam->wHz_UnitHotWind ;
	//2026.3.11.104021 替换为排风
	//wHz_UnitHotWind_2_Rec=i_pstStAxisParam->wHz_UnitHotWind_2 ;
	wHz_UnitExhaust_ManuallySet_rec=i_pstStAxisParam->wHz_UnitExhaust_ManuallySet ;
	wSV_UnitTemCtl_Rec=i_pstStAxisParam->wSV_UnitTemCtl ;
	dwCtlBits_UnitBaseCraft_Rec =  i_pstStAxisParam->dwCtlBits_UnitBaseCraft;
	byLedSwitchTimeouts_Rec=i_byLedSwitchTimeouts;//2022.5.12.143635
	//2023.4.24.225233|双波门
	iGateSaEx_Rec= i_pstStAxisParam->iGateSaEx;
	//2023.11.08.102855 同步
	//2023.10.14.91426/wei.n/7吋人机色组IO与ARM通讯
	wUnit_output_I_Rec= i_pstStAxisParam->wUnit_output_I;
	wUnit_output_II_Rec= i_pstStAxisParam->wUnit_output_II;

	wButtonFun1= i_pstStAxisParam->wButtonFun;

	//2024.02.01.225516 增加了死机信息的485强制通讯机制
	if (g_send_crashinf_hmi == 0)//标志无效的时候进行之前的通讯
	{
		switch( bySendStep )//1：发送双向/变化很少数的变量；2：正常周期读取-发送-读取-发送
		{
		case 1:
			stSt485_Format.byStationId= 0x01;							//通讯站号
			stSt485_Format.bycmd= 0x10;									//通讯功能码
			stSt485_Format.wAddress= 0x1770;							//通讯起始地址
			if (xFirstTime || xReset)
			{
				stSt485_Format.wNum_Register= 0x0028;					//通讯寄存器数量和字节数
			}
			else
			{
				stSt485_Format.wNum_Register= 0x0027;//双向区域增加到40-2022.3.21.154308
			}
			stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;
			//数据包包头处理完成-填入发送缓冲区----------------------------2021.8.20.145114
			RS485_TX_BUFF[0]= stSt485_Format.byStationId;				//站号
			RS485_TX_BUFF[1]= stSt485_Format.bycmd;						//功能码
			RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;//寄存器地址高
			RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;	//寄存器地址低
			RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;	//寄存器数量高
			RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;		//寄存器数量低
			RS485_TX_BUFF[6]= stSt485_Format.bySendNum_Bytes;			//总字节数
			//接下来填入有效数据------------------------------------------2021.8.20.145122
			if(i_pstStAxisParam->lrAdjust_V>0)
			{
				rAdjust_V_temp= (float)(i_pstStAxisParam->lrAdjust_V+0.005);
			}
			else if(i_pstStAxisParam->lrAdjust_V<0)
			{
				rAdjust_V_temp=(float)(i_pstStAxisParam->lrAdjust_V-0.005);
			}
			else
			{
				rAdjust_V_temp=0;//2022.6.10.182219||未判断0//2022061001||2022.6.10.185058||修正量发送判0
			}
			RS485_TX_BUFF[7] = (BYTE)((WORD)(INT)((rAdjust_V_temp) * 100) >> 8);
			RS485_TX_BUFF[8] = (BYTE)((WORD)(INT)((rAdjust_V_temp) * 100));		//纵向修正量高低8位

			//6001
			//2020.5.28.110659|niu.j|防止修正量由于精度问题每次修改的值不是5
			if(i_pstStAxisParam->lrAdjust_H>0)
			{
				rAdjust_H_temp= (float)(i_pstStAxisParam->lrAdjust_H+0.005);
			}
			else if(i_pstStAxisParam->lrAdjust_H<0)
			{
				rAdjust_H_temp=(float)(i_pstStAxisParam->lrAdjust_H-0.005);
			}
			else
			{
				rAdjust_H_temp=0;//2022061001||2022.6.10.185058||修正量发送判0
			}
			RS485_TX_BUFF[9] = (BYTE)((WORD)(INT)((rAdjust_H_temp) * 100) >> 8);
			RS485_TX_BUFF[10] = (BYTE)((WORD)(INT)((rAdjust_H_temp) * 100));  	//横向修正量高低8位

			//6002
			RS485_TX_BUFF[11] = (BYTE)((WORD)(i_pstStAxisParam->iGateSa) >> 8);
			RS485_TX_BUFF[12] = (BYTE)((WORD)(i_pstStAxisParam->iGateSa));		//波门地址高低位

			//6003
			RS485_TX_BUFF[13] = (BYTE)((wStatus) >> 8);
			RS485_TX_BUFF[14] = (BYTE)((wStatus));								//状态-纵/横向手自动

			//2025.10.28.165757 屏蔽容易混淆的内容
			//6004
			//RS485_TX_BUFF[15] = (BYTE)((i_pstStAxisParam->wSV_TemCtrl) >> 8);
			//RS485_TX_BUFF[16] = (BYTE)((i_pstStAxisParam->wSV_TemCtrl));		//原本左波门位置-弃用//2021.10.27.205311兼容奥特马新增温度设定值双向通讯

			//6005
			RS485_TX_BUFF[17] = (BYTE)((wButtonFun1) >> 8);
			RS485_TX_BUFF[18] = (BYTE)((wButtonFun1));							//右波门的位置

			//6006
			RS485_TX_BUFF[19] = (BYTE)(wPlateAdjustmentProf_RX >> 8);
			RS485_TX_BUFF[20] = (BYTE)(wPlateAdjustmentProf_RX);				//波门修改标志位|修正标志

			//6007
			RS485_TX_BUFF[21] = (BYTE)((WORD)(*i_piJourney_HorzRapidAdjust)>>8);
			RS485_TX_BUFF[22] = (BYTE)((WORD)(*i_piJourney_HorzRapidAdjust));	//预留横向运行

			//6008
			RS485_TX_BUFF[23] = (BYTE)(i_pstStAxisParam->iAxisId >> 8);
			RS485_TX_BUFF[24] = (BYTE)(i_pstStAxisParam->iAxisId);				//轴号

			//6009
			RS485_TX_BUFF[25] = 0;
			RS485_TX_BUFF[26] = byGrpTemp;										//系号

			//6010
			RS485_TX_BUFF[27] = 0;
			RS485_TX_BUFF[28] = (BYTE)(i_pstStGlobalParam->byLanguageId);		//语言选择

			//6011
			temp=(WORD)(INT)(i_pstStAxisParam->lrAlarm_V * 100);				//纵向报警值
			RS485_TX_BUFF[29] = (BYTE)(temp >> 8);
			RS485_TX_BUFF[30] = (BYTE)(temp);									//纵向报警值

			//6012
			temp=(WORD)(INT)(i_pstStAxisParam->lrAlarm_H * 100);				//横向报警值
			RS485_TX_BUFF[31] = (BYTE)(temp >> 8);
			RS485_TX_BUFF[32] = (BYTE)(temp);									//横向报警值

			//6013
			temp=(WORD)(INT)(i_pstStAxisParam->iGateWidthRondPt / i_bySample_Interval );//波门宽度-像素
			RS485_TX_BUFF[33] = (BYTE)(temp >> 8);
			RS485_TX_BUFF[34] = (BYTE)(temp);	//波门宽度

			//屏保延时
			//6014
			RS485_TX_BUFF[35] = 0;
			RS485_TX_BUFF[36] = i_byLedSwitchTimeouts;
			//复位标志

			//6015*作为上电同步两档开关
			wPowerOnSync=i_pstStAxisParam->wMCGS_SingleSwitch;
			wPowerOnSync=SetBit(byPowerOn_Flag,wPowerOnSync,15);
			RS485_TX_BUFF[37] = (BYTE)(wPowerOnSync>>8);
			RS485_TX_BUFF[38] = (BYTE)(wPowerOnSync);

			//版本号年月日分//6016
			RS485_TX_BUFF[39] = (BYTE)((((DWORD)DWVERSION) & 0xFF000000)>>24);
			RS485_TX_BUFF[40] = (BYTE)((((DWORD)DWVERSION) & 0xFF0000)>>16);

			//6017
			RS485_TX_BUFF[41] = (BYTE)((((DWORD)DWVERSION) & 0xFF00)>>8);
			RS485_TX_BUFF[42] = (BYTE)((((DWORD)DWVERSION) & 0xFF));

			//2025.10.28.165757 屏蔽容易混淆的内容
			/*
			//6018
			RS485_TX_BUFF[43] = (BYTE)((i_pstStAxisParam->wSV_TemCtrl_PreHot) >> 8);
			RS485_TX_BUFF[44] = (BYTE)((i_pstStAxisParam->wSV_TemCtrl_PreHot));;	//原本左波门位置-弃用//2021.10.27.205311兼容奥特马新增温度设定值双向通讯

			//6019--递墨辊频率
			RS485_TX_BUFF[45] = (BYTE)(i_pstStAxisParam->wInkRoller_Fre>>8);
			RS485_TX_BUFF[46] = (BYTE)(i_pstStAxisParam->wInkRoller_Fre);
			*/
			//2026.1.31.151345+
			//6018使用@解锁ui位
			RS485_TX_BUFF[43] = 0;
			RS485_TX_BUFF[44] = i_pstStGlobalParam->byUnLockHmi_UI;


			//6019--未使用
			RS485_TX_BUFF[45] = 0;
			RS485_TX_BUFF[46] = 0;

			//6020--进风口开度
			RS485_TX_BUFF[47] = (BYTE)(i_pstStAxisParam->wAirInletWindDoorValue>>8);
			RS485_TX_BUFF[48] = (BYTE)(i_pstStAxisParam->wAirInletWindDoorValue);

			//6021--排风口开度
			RS485_TX_BUFF[49] = (BYTE)(i_pstStAxisParam->wAirExhaustWindDoorValue>>8);
			RS485_TX_BUFF[50] = (BYTE)(i_pstStAxisParam->wAirExhaustWindDoorValue);

			//6022--回风口开度
			RS485_TX_BUFF[51] = (BYTE)(i_pstStAxisParam->wAirReturnWindDoorValue>>8);
			RS485_TX_BUFF[52] = (BYTE)(i_pstStAxisParam->wAirReturnWindDoorValue);

			//2025.10.28.165757 屏蔽容易混淆的内容
			//6023--加热温度设置
			//RS485_TX_BUFF[53] = (BYTE)(i_pstStAxisParam->wTemperature_Set>>8);
			//RS485_TX_BUFF[54] = (BYTE)(i_pstStAxisParam->wTemperature_Set);

			//6024--低8位从站阀值选择，主8位预留
			RS485_TX_BUFF[55] = 0;
			RS485_TX_BUFF[56] = i_pstStAxisParam->bySampleSholdSwitch;

			//6025开关通讯
			RS485_TX_BUFF[57] = (BYTE)(i_pstStAxisParam->wMCGS_SingleSwitch>>8);
			RS485_TX_BUFF[58] = (BYTE)(i_pstStAxisParam->wMCGS_SingleSwitch);

			//2025.10.28.165757 屏蔽容易混淆的内容
			//2021.6.17.144859||||niu.j|||6026用于发送套色基线给从站
			//RS485_TX_BUFF[59] = 0;
			//RS485_TX_BUFF[60] = i_pstStAxisParam->byAxisRoller_UpperFrq;

			//第二路波门
			RS485_TX_BUFF[61] = (BYTE)((WORD)(i_pstStAxisParam->iGateSaEx) >> 8);
			RS485_TX_BUFF[62] = (BYTE)((WORD)(i_pstStAxisParam->iGateSaEx));	//波门地址高低位

			//2023.11.08.103229同步
			//6028预留/2023.10.14.94520/wei.n/7寸人机色组IO与ARM通讯
			RS485_TX_BUFF[63] = (BYTE)(i_pstStAxisParam->wUnit_output_I>>8)& 0xFF;
			RS485_TX_BUFF[64] = (BYTE)(i_pstStAxisParam->wUnit_output_I)& 0xFF;

			//6029
			RS485_TX_BUFF[65] = (BYTE)(i_pstStAxisParam->wUnit_output_II>>8)& 0xFF;
			RS485_TX_BUFF[66] = (BYTE)(i_pstStAxisParam->wUnit_output_II)& 0xFF;

			//6030
			RS485_TX_BUFF[67] = (i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet >> 8) & 0xFF;
			RS485_TX_BUFF[68] = (i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet) & 0xFF;

			//6031
			RS485_TX_BUFF[69] = (i_pstStAxisParam->wCoeff_UnitInkRoller_Auto >> 8) & 0xFF;
			RS485_TX_BUFF[70] = (i_pstStAxisParam->wCoeff_UnitInkRoller_Auto) & 0xFF;

			//6032
			RS485_TX_BUFF[71] = (i_pstStAxisParam->wHz_UnitScraper_ManuallySet >> 8) & 0xFF;
			RS485_TX_BUFF[72] = (i_pstStAxisParam->wHz_UnitScraper_ManuallySet) & 0xFF;

			//6033
			RS485_TX_BUFF[73] = (i_pstStAxisParam->wCoeff_UnitScraper_Auto >> 8) & 0xFF;
			RS485_TX_BUFF[74] = (i_pstStAxisParam->wCoeff_UnitScraper_Auto) & 0xFF;

			//6034
			RS485_TX_BUFF[75] = (i_pstStAxisParam->wHz_UnitHotWind >> 8) & 0xFF;
			RS485_TX_BUFF[76] = (i_pstStAxisParam->wHz_UnitHotWind) & 0xFF;
//
//			//6035
//			RS485_TX_BUFF[77] = (i_pstStAxisParam->wHz_UnitHotWind_2 >> 8) & 0xFF;
//			RS485_TX_BUFF[78] = (i_pstStAxisParam->wHz_UnitHotWind_2) & 0xFF;
			//2026.3.11.104047 替换为排风
			//6035
			RS485_TX_BUFF[77] = (i_pstStAxisParam->wHz_UnitExhaust_ManuallySet >> 8) & 0xFF;
			RS485_TX_BUFF[78] = (i_pstStAxisParam->wHz_UnitExhaust_ManuallySet) & 0xFF;


			//6036
			RS485_TX_BUFF[79] = (i_pstStAxisParam->wSV_UnitTemCtl >> 8) & 0xFF;
			RS485_TX_BUFF[80] = (i_pstStAxisParam->wSV_UnitTemCtl) & 0xFF;

			//6037
			RS485_TX_BUFF[81] = (BYTE)((((DWORD)i_pstStAxisParam->dwCtlBits_UnitBaseCraft) & 0xFF000000)>>24);
			RS485_TX_BUFF[82] = (BYTE)((((DWORD)i_pstStAxisParam->dwCtlBits_UnitBaseCraft) & 0xFF0000)>>16);

			//6038
			RS485_TX_BUFF[83] = (BYTE)((((DWORD)i_pstStAxisParam->dwCtlBits_UnitBaseCraft) & 0xFF00)>>8);
			RS485_TX_BUFF[84] = (BYTE)((((DWORD)i_pstStAxisParam->dwCtlBits_UnitBaseCraft) & 0xFF));

			//6039
			if (xFirstTime || xReset)//初始第一次通讯发送一个复位标志，当读取到的复位标志变为0时，认为人机复位，所有参数无效，发送一次参数给人机
			{
				wResetNum= wResetNum+1;
				RS485_TX_BUFF[85] = (wResetNum >> 8) & 0xFF;
				RS485_TX_BUFF[86] = (wResetNum) & 0xFF;

				//2022.3.21.162206新增北人
				stSt485_Format.wCRC = CRC_Compute(RS485_TX_BUFF, 0, 87);
				RS485_TX_BUFF[87] = (stSt485_Format.wCRC >> 8) & 0xFF;
				RS485_TX_BUFF[88] = (stSt485_Format.wCRC) & 0xFF;
				stSt485_Format.byNum_Bytes= 89;
			}
			else
			{
				//2022.3.21.162206新增北人
				stSt485_Format.wCRC = CRC_Compute(RS485_TX_BUFF, 0, 85);
				RS485_TX_BUFF[85] = (stSt485_Format.wCRC >> 8) & 0xFF;
				RS485_TX_BUFF[86] = (stSt485_Format.wCRC) & 0xFF;
				stSt485_Format.byNum_Bytes= 87;
			}

			if (xFirstTime)
			{
				xFirstTime=0;
			}
			if(xReset)
			{
				xReset=0;
			}
			stSt485_Format.byReadNum_Bytes = 4;	 																									//读取的有效字节数(写入数据就是响应的寄存器地址和数量)
			break;

		case 2:
			switch( byNormalStep )
			{
			case 0://读取周期，读取界面参数是否发生变化
				stSt485_Format.byStationId= 0x01;																									//通讯站号
				stSt485_Format.bycmd= 0x03;																											//通讯功能码
				stSt485_Format.wAddress= 0x1770;																									//通讯起始地址
				stSt485_Format.wNum_Register= 0x3C;																						//通讯寄存器数量和字节数|维持0x3C不扩:读协议6000~6059=MCGS6001~6060,改版后开关位46059(编码器同字节)/s50=4WUB6060(末寄存器)均在范围内(解析见xHorMotorAlarm解析行之后)|组态屏改版适配 2026.11.11
				stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;

				RS485_TX_BUFF[0]= stSt485_Format.byStationId;//站号，威纶人机设置为01
				RS485_TX_BUFF[1]= stSt485_Format.bycmd;//功能码0x03,读多个寄存器
				RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;//起始地址高位
				RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;//起始地址低位，地址6000地址6000
				RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;//寄存器数量高位
				RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;//寄存器数量低位
				stSt485_Format.wCRC= CRC_Compute(RS485_TX_BUFF,0,6);
				RS485_TX_BUFF[6]= (BYTE)(stSt485_Format.wCRC>>8) & 0xFF;//寄存器数量高位
				RS485_TX_BUFF[7]= (BYTE)(stSt485_Format.wCRC) & 0xFF;//寄存器数量低位
				stSt485_Format.byNum_Bytes= 8;
				stSt485_Format.byReadNum_Bytes= stSt485_Format.bySendNum_Bytes;
				break;

			case 1://发送周期，发送T1
				//发送T1只处理T1
				//2021.6.10.160013获取发送数据
				//发送原始波形2021.3.4.092213
				if (byStep_Sample>7)
				{
					byStep_Sample=0;
				}
				iJ=0;
				for(iN=0;iN<200;iN++)
				{
					iJ=iN+byStep_Sample*200;
					i_abyResultData_RS[iN]	=i_abyRoundData_485[iJ];
				}
				byStep_Sample= byStep_Sample+1;
				//获取发送数据的起始索引值0000000000000000000000-------------------------2021.8.20.150656
				stSt485_Format.byStationId= 0x01;																									//通讯站号
				stSt485_Format.bycmd= 0x10;																											//通讯功能码
				stSt485_Format.wAddress= 0x07D0+ (byStep_Sample-1)*100;																									//通讯起始地址
				stSt485_Format.wNum_Register= 0x0064;																						//通讯寄存器数量和字节数
				stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;
				RS485_TX_BUFF[0]= stSt485_Format.byStationId;																				//站号
				RS485_TX_BUFF[1]= stSt485_Format.bycmd;																						//功能码
				RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;													//寄存器地址高
				RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;														//寄存器地址低
				RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;											//寄存器数量高
				RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;												//寄存器数量低
				RS485_TX_BUFF[6]= stSt485_Format.bySendNum_Bytes;																	//总字节数
				//填有效波形发数据---------------------2021.8.20.150842

				for( iN=0; iN<200; iN++ )
				{
					RS485_TX_BUFF[7+iN] = i_abyResultData_RS[iN];
				}
				stSt485_Format.wCRC= CRC_Compute( RS485_TX_BUFF, 0, 207 );
				RS485_TX_BUFF[207] = (BYTE)(stSt485_Format.wCRC >> 8) & 0xFF;
				RS485_TX_BUFF[208] = (BYTE)(stSt485_Format.wCRC) & 0xFF;
				stSt485_Format.byNum_Bytes= 209;
				stSt485_Format.byReadNum_Bytes= 4;
				break;

			case 2://发送周期，发送T1
				//发送T1只处理T1
				//发送原始波形2021.3.4.092213
				if (byStep_Sample>7)
				{
					byStep_Sample=0;
				}
				iJ=0;
				for(iN=0;iN<200;iN++)
				{
					iJ=iN+byStep_Sample*200;
					i_abyResultData_RS[iN]	=i_abyRoundData_485[iJ];
				}
				byStep_Sample= byStep_Sample+1;

				//获取发送数据的起始索引值0000000000000000000000-------------------------2021.8.20.150656
				stSt485_Format.byStationId= 0x01;																									//通讯站号
				stSt485_Format.bycmd= 0x10;																											//通讯功能码
				stSt485_Format.wAddress= 0x07D0+ (byStep_Sample-1)*100;																									//通讯起始地址
				stSt485_Format.wNum_Register= 0x0064;																						//通讯寄存器数量和字节数
				stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;
				RS485_TX_BUFF[0]= stSt485_Format.byStationId;																				//站号
				RS485_TX_BUFF[1]= stSt485_Format.bycmd;																						//功能码
				RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;													//寄存器地址高
				RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;														//寄存器地址低
				RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;											//寄存器数量高
				RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;												//寄存器数量低
				RS485_TX_BUFF[6]= stSt485_Format.bySendNum_Bytes;																	//总字节数
				//填有效波形发数据---------------------2021.8.20.150842
				for( iN=0; iN<200; iN++ )
				{
					RS485_TX_BUFF[7+iN] = i_abyResultData_RS[iN];
				}
				stSt485_Format.wCRC= CRC_Compute( RS485_TX_BUFF, 0, 207 );
				RS485_TX_BUFF[207] = (BYTE)(stSt485_Format.wCRC >> 8) & 0xFF;
				RS485_TX_BUFF[208] = (BYTE)(stSt485_Format.wCRC) & 0xFF;
				stSt485_Format.byNum_Bytes= 209;
				stSt485_Format.byReadNum_Bytes= 4;
				break;

			case 3:
				//只处理T2和剩余数据
				//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
				//误差发送方法-每次进入发送误差逻辑，判断精采样计圈刷新次数，
				//由此为依据计算发送的字节数-地址6201、6202空闲
				//新增发送-6205|本次误差刷新幅数-6206+发送字节数==纵向误差队列|||和横向误差队列
				//当前幅的纵向和横向误差=6206和6206+误差个数
				//2020.05.04.174651|niu.j |修改发送误差方法
				//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

				if( i_pstStPara_PduBroadcastUp->byIndexV > byPreIndex )																	//精采样记幅的数据类型是单字节，存在过量程值的现象
				{
					byErrUpdateNum = i_pstStPara_PduBroadcastUp->byIndexV - byPreIndex;
				}
				else
				{
					byErrUpdateNum = 256 - byPreIndex + i_pstStPara_PduBroadcastUp->byIndexV ;
				}

				if( byErrUpdateNum >= 40 )																												//目前数组范围是20,超出20不计算，只发送当前幅误差
				{
					byErrUpdateNum = 1;
				}
				byPreIndex = i_pstStPara_PduBroadcastUp->byIndexV ;
				bySendCnt_6 = 5 + 1 + 5 + 20 + 2 * byErrUpdateNum;//新增20个单向下发内容
				//计算发送寄存器数量=100-100
				//(*T1T2总共100个寄存器，case1和case3发送了80个字节*) + 5(*5-其他数据*) +
				//1(*误差幅数*)+纵向误差队列+横向误差队列(寄存器数量)+1(屏保延时)+5(预留空间)

				stSt485_Format.byStationId= 0x01;																									//通讯站号
				stSt485_Format.bycmd= 0x10;																											//通讯功能码
				stSt485_Format.wAddress= 0x1838;																									//通讯起始地址
				stSt485_Format.wNum_Register= (WORD)bySendCnt_6;																		//通讯寄存器数量和字节数
				stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;
				RS485_TX_BUFF[0]= stSt485_Format.byStationId;																				//站号
				RS485_TX_BUFF[1]= stSt485_Format.bycmd;																						//功能码
				RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;													//寄存器地址高
				RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;														//寄存器地址低
				RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;											//寄存器数量高
				RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;												//寄存器数量低
				RS485_TX_BUFF[6]= stSt485_Format.bySendNum_Bytes;																	//总字节数
				//填有效波形发数据---------------------2021.8.20.150842
				//6200
				RS485_TX_BUFF[7] = 0;
				RS485_TX_BUFF[8] = i_pstStPara_PduBroadcastUp->byIndexV;															//采样计圈
				//6201
				//地址6201和6202目前空闲-预留后续的数据
				//2020.5.13.182359-------增加屏保切换
				RS485_TX_BUFF[9] = (BYTE)(((WORD)i_pstStAxisParam->iPos_HorzManuPreReg)>>8);
				RS485_TX_BUFF[10] = (BYTE)((WORD)i_pstStAxisParam->iPos_HorzManuPreReg);

				//6202
				//2020.5.13.182359-------增加屏保切换
				RS485_TX_BUFF[11] = 0;
				RS485_TX_BUFF[12] = byScreen;
				//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>end >>>>>>>>>>>>>>>>>>>>>
				//6203
				temp = (WORD)(INT)(i_pstStGrpParam->lrVelocity);																				//当前速度
				RS485_TX_BUFF[13] = (BYTE)(temp >> 8) & 0xFF;
				RS485_TX_BUFF[14] = (BYTE)(temp) & 0xFF;

				//6204//公司ID
				//公司名称和报警代码合并2020.7.2.152313||
				dwAlarmFlag = i_pstStAxisParam->dwAlarmDetail;
				if(dwAlarmFlag != 0)
				{
					for(iN=0 ; iN<16 ; iN++)
					{
						if((dwAlarmFlag & 1<<iN) != 0)
						{
							iPromptMsgId = 1500 + iN;
							break;
						}
					}
				}
				else
				{
					iPromptMsgId = 0;//报警细节与公司名称区分开
				}
				RS485_TX_BUFF[15] = (BYTE)(((WORD)(iPromptMsgId))>>8);
				RS485_TX_BUFF[16] = (BYTE)((WORD)(iPromptMsgId));

				//6205--记录本次600ms误差刷新次数
				RS485_TX_BUFF[17] = 0;
				RS485_TX_BUFF[18] = (BYTE)byErrUpdateNum;

				//2025.10.28.165757 屏蔽容易混淆的内容
				//aReturn[0] = (WORD)(INT)i_pstStAxisParam->rAxisRoller_Frq;																//2021.10.28.172518奥特马占用|当前递墨辊自动频率
				//6206=置信度显示(高8位纵向F|低8位横向F,0~100四舍五入钳位,随每个通讯循环约600ms
				//刷新;屏侧wConfPack拆字节显示:纵向F=wConfPack/256,横向F=wConfPack%256;
				//原奥特马递墨辊自动频率已弃用,寄存器释放使用)|wang.c+开关通讯接入 2026.11.10.160000
				temp = (WORD)(INT)(rConfLastRevV + 0.5f);
				if (temp > 100) temp = 100;
				aReturn[0] = (WORD)(temp << 8);
				temp = (WORD)(INT)(rConfLastRevH + 0.5f);
				if (temp > 100) temp = 100;
				aReturn[0] += temp;
				//6207
				//2020.5.30.144755|发送版周长和套色标记
				aReturn[1] = (WORD)(INT)(i_pstStAxisParam->lrGirth);
				//6208
				byTemp = 1;
				aReturn[2] = 0;
				Bitnum = i_pstStAxisParam->iMarkTypeId - 1;																						//标记形式占前bit7位//bit0-bit6
				aReturn[2] = SetBit(byTemp , aReturn[2] , Bitnum);
				Bitnum = i_pstStAxisParam->iMarkArrangeModal + 6;																			//bit7-bit11//标记顺序
				aReturn[2] = SetBit(byTemp , aReturn[2] , Bitnum);
				aReturn[2] = SetBit(xLocalAxisRollerDn, aReturn[2] , 12);																		//bit12压辊状态
				byTemp= i_pstStAxisParam->xFlag_Gate_double;
				aReturn[2] = SetBit(byTemp , aReturn[2] , 13);																		//bit12压辊状态

				byTemp = GetBit_DWORD(i_pstStGlobalParam->dwControlComplexBits,30);	//波形显示方式
				aReturn[2] = SetBit(byTemp , aReturn[2] , 14);	//bit14：																	//bit12压辊状态
				byTemp = GetBit(i_pstStAxisParam->wSwitchRef,10);		//波门锁
				aReturn[2] = SetBit(byTemp , aReturn[2] , 15);	//bit15:

				//2020.9.28.120015||niu.j||增加实际偏移量的值
				// 2021.9.29.154445|wang.st|屏蔽对aReturn[2]的复用操作

				aReturn[3] = (((WORD)(255-(BYTE)i_alrBase_485[0]))<<8) + (WORD)(255-(BYTE)i_alrBase_485[1]);
				//占用剩余发送空间发按钮功能
				//2021.9.16.131539更新改地址为波形显示最小值，用于从站人机显示波形纵向平移，波形接近下边界
				//2024.02.01.233114 括号处理了下优先级
				//2024.5.29.112519处理原始波形拉低问题||niu.j
				aReturn[4] = (((WORD)(i_abyMinData_Sample[0]))<<8) + (WORD)(i_abyMinData_Sample[1]);
				for(iN=0; iN<10; iN=iN+2)
				{
					RS485_TX_BUFF[19+iN] = (BYTE)((WORD)(aReturn[iN/2])>>8);														//纵向误差队列
					RS485_TX_BUFF[20+iN] = (BYTE)((WORD)(aReturn[iN/2]));																//纵向误差队列								}
				}

				//2022.3.21.111651新增20个预留空间-误差队列减小20纵横各减小10||aReturn_2
				aReturn_2[0] = (WORD)(i_pstStAxisParam->rHz_UnitInkRoller_CurrWR);//当前递墨辊频率-*10
				aReturn_2[1] = (WORD)(i_pstStAxisParam->rHz_UnitScraper_CurrWR);//当前刮刀频率-*10
				aReturn_2[2] = (WORD)(i_pstStAxisParam->rPV_UnitTemCtl*10);//当前读取的实时温度
				aReturn_2[3] = (i_pstStAxisParam->wSTS_UnitTemCtl);//当前温控运行状态
				aReturn_2[4] = (WORD)(i_pstStGlobalParam->iCompanyId);
				aReturn_2[5] = (WORD)(i_pstStAxisParam->rHz_UnitHotWind_CurrWR);//当前热风频率-*10
				//2026.3.11.090312 热风2替换为排风
				//aReturn_2[6] = (WORD)(i_pstStAxisParam->rHz_UnitHotWind2_CurrWR);//当前热风2频率-*10
				aReturn_2[6] = (WORD)(i_pstStAxisParam->wHz_UnitExhaust_CurrWR);//当前排风频率-*10
				//				WORD wSts_Print;//整机状态0:停机。1：运行；2：空转
	//	WORD wFlag_Estop;//0：急停 1；不急停
	//	WORD wLinkage_Print;//bit0_bit15对应1-16色
	//	WORD wHotWind_Print;//bit0_bit15对应1-16色
	//
				if(i_pstStGrpParam->bySts_Flag<3)
				{
					i_pstStGrpParam->wSts_Print= i_pstStGrpParam->bySts_Flag;
					i_pstStGrpParam->wFlag_Estop=1;
				}
				else//急停了
				{
					i_pstStGrpParam->wSts_Print= 0;		//停机
					i_pstStGrpParam->wFlag_Estop=0;		//急停
				}
				i_pstStGrpParam->wLinkage_Print= (WORD)i_pstStGlobalParam->dwComplexFlag_AxisLinkage;

				aReturn_2[7] = i_pstStGrpParam->wSts_Print;
				aReturn_2[8] = i_pstStGrpParam->wFlag_Estop;
				aReturn_2[9] = i_pstStGrpParam->wLinkage_Print;
				aReturn_2[10] = i_pstStGrpParam->wHotWind_Print;
				aReturn_2[11] = (WORD)i_pstStGrpParam->rGrp_Vel;
				//增加程序计数2023.5.18.155207
				i_pstStAxisParam->byCnt_VISU= i_pstStAxisParam->byCnt_VISU+1;
				aReturn_2[12] = (WORD)i_pstStAxisParam->byCnt_VISU;
				//2023.11.08.103349 同步
				//2023.10.14.85102/wei.n/7吋人机色组IO与ARM通讯
				aReturn_2[13] = i_pstStAxisParam->wUnit_input_I;
				aReturn_2[14] = i_pstStAxisParam->wUnit_input_II;
				aReturn_2[15] = i_pstStAxisParam->wUnit_input_III;
				//16--19是空余的@2024.12.16.095057
				//人机地址6228
				aReturn_2[16] = i_iCount_TimeOutNum;//增加了通讯超时的计数输出
				aReturn_2[17]= i_pstStGlobalParam->byCurrUsrLevel;//人机地址6229@权限的通讯
				aReturn_2[18]= i_pstStAxisParam->stStInkGrooveCtl.iMsg;//2025.6.18.094250+通讯油墨槽信息到7寸人机@6230
				//2025.9.26.112619+
				aReturn_2[19]= (WORD)i_pstStAxisParam->byDriverType_Hmi485;//只使用的一个字节

				for(iN=0; iN<40; iN=iN+2)
				{
					RS485_TX_BUFF[29+iN] = (BYTE)((WORD)(aReturn_2[iN/2])>>8);												//纵向误差队列
					RS485_TX_BUFF[30+iN] = (BYTE)((WORD)(aReturn_2[iN/2]));													//纵向误差队列								}
				}
				//误差队列发送
				for(iN=0; iN<byErrUpdateNum*4; iN=iN+2)
				{
					if(iN<byErrUpdateNum*2)
					{
						RS485_TX_BUFF[iN+69] = (BYTE)((WORD)(i_aiError_V[iN/2])>>8);										//纵向误差队列
						RS485_TX_BUFF[iN+70] = (BYTE)((WORD)(i_aiError_V[iN/2]));											//纵向误差队列
					}
					else
					{
						RS485_TX_BUFF[iN+69] = (BYTE)((WORD)(i_aiError_H[(iN-2*byErrUpdateNum)/2])>>8);				//纵向误差队列
						RS485_TX_BUFF[iN+70] = (BYTE)((WORD)(i_aiError_H[(iN-2*byErrUpdateNum)/2]));				//纵向误差队列
					}
				}
				stSt485_Format.wCRC =  CRC_Compute( RS485_TX_BUFF, 0, 69+byErrUpdateNum*4 );

				RS485_TX_BUFF[69+byErrUpdateNum*4] = (BYTE)(stSt485_Format.wCRC>>8)&0xFF;
				RS485_TX_BUFF[70+byErrUpdateNum*4] = (BYTE)(stSt485_Format.wCRC)&0xFF;
				stSt485_Format.byNum_Bytes= 71+byErrUpdateNum*4;
				stSt485_Format.byReadNum_Bytes= 4;

				break;
				//2020.9.30.085843||横向放大刷新慢问题
			}
			break;
		}
	}
	else//需要将死机信息发送到界面@2024.02.01.225819
	{

		//LP_EXCEPTION_OF_CRASH ptmp;
		//计算word个数
		int inf_lenth = sizeof(exception_crash);
		int inf_word_lenth ;

		if(inf_lenth % 2 !=0)
			inf_word_lenth = inf_lenth/2+1;
		else
			inf_word_lenth = inf_lenth/2;

		g_send_crashinf_hmi=0;//清除发送标志
		stSt485_Format.byStationId= 0x01;																									//通讯站号
		stSt485_Format.bycmd= 0x10;//写入多个寄存器																											//通讯功能码
		stSt485_Format.wAddress= 0x1388;//通讯起始地址
		stSt485_Format.wNum_Register= inf_word_lenth;//通讯寄存器数量@23个word@46个字节
		stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;
		RS485_TX_BUFF[0]= stSt485_Format.byStationId;																//站号
		RS485_TX_BUFF[1]= stSt485_Format.bycmd;																		//功能码
		RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;												//寄存器地址高
		RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;													//寄存器地址低
		RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;											//寄存器数量高
		RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;												//寄存器数量低
		RS485_TX_BUFF[6]= stSt485_Format.bySendNum_Bytes;															//总字节数
		//填有效数据---------------------2021.8.20.150842

		//通讯数据高低取反
		//********************************************************************************************************start
		ks_getmodbuscommdata((void*)&exception_crash.dwrunPostion,4,&(RS485_TX_BUFF[7]),1);//7--10

		ks_getmodbuscommdata((void*)&exception_crash.wYear,2,&(RS485_TX_BUFF[11]),1);//11--12
		ks_getmodbuscommdata((void*)&exception_crash.wMonth,2,&(RS485_TX_BUFF[13]),1);//13--14
		ks_getmodbuscommdata((void*)&exception_crash.wDay,2,&(RS485_TX_BUFF[15]),1);//15--16
		ks_getmodbuscommdata((void*)&exception_crash.wHour,2,&(RS485_TX_BUFF[17]),1);//17--18
		ks_getmodbuscommdata((void*)&exception_crash.wMinute,2,&(RS485_TX_BUFF[19]),1);//19--20
		ks_getmodbuscommdata((void*)&exception_crash.wSecond,2,&(RS485_TX_BUFF[21]),1);//21--22

		ks_getmodbuscommdata((void*)&exception_crash.dwCpuInf,4,&(RS485_TX_BUFF[23]),1);//23--26
		ks_getmodbuscommdata((void*)&exception_crash.dwMemoryLoad,4,&(RS485_TX_BUFF[27]),1);//27--30
		ks_getmodbuscommdata((void*)&exception_crash.dwTotalPhys,4,&(RS485_TX_BUFF[31]),1);//31--34
		ks_getmodbuscommdata((void*)&exception_crash.dwAvailPhys,4,&(RS485_TX_BUFF[35]),1);//35--38
		ks_getmodbuscommdata((void*)&exception_crash.dwTryLockNums,4,&(RS485_TX_BUFF[39]),1);//39--42
		ks_getmodbuscommdata((void*)&exception_crash.dwFileError,4,&(RS485_TX_BUFF[43]),1);//43--46
		ks_getmodbuscommdata((void*)&exception_crash.dwFileHandle,4,&(RS485_TX_BUFF[47]),1);//47--50

		ks_getmodbuscommdata((void*)&exception_crash.wMemOperation,2,&(RS485_TX_BUFF[51]),1);//51--52
		//********************************************************************************************************end

		//crc校验@2024.02.01.230605
		stSt485_Format.wCRC= CRC_Compute( RS485_TX_BUFF, 0, inf_lenth+7 );//结束是数据索引+1
		RS485_TX_BUFF[inf_lenth+7] = (BYTE)(stSt485_Format.wCRC >> 8) & 0xFF;
		RS485_TX_BUFF[inf_lenth+8] = (BYTE)(stSt485_Format.wCRC) & 0xFF;
		stSt485_Format.byNum_Bytes= inf_lenth+8+1;//从零开始的@2024.02.02.135107
		stSt485_Format.byReadNum_Bytes= 4;//????
	}

	if(USE_KEIL5_IDE)
	{
		//新增2020.04.02.141719|循环队列压数据
		//打开接收使能
		//取出循环队列的第一个值填入DR寄存器-触发发送完成中断，进入到中断发送中。
		//RS485_TX_EN = 1;									//切换485硬件使能为发送		在此处切换485硬件使能-清除485接收完成标志
		// HAL_GPIO_WritePin(RS485_TX_EN_GPIO_Port, RS485_TX_EN_Pin,GPIO_PIN_SET);
		//	for(iN=0;iN<150;iN++)							//清空485接收响应队列
		//	{
		//		RS485_RX_BUFF[iN]=0xFA;
		//	}
		//TIM_Cmd(TIM2,ENABLE);
	}
	else
	{
		// 2024.8.12.161735
		//打开发送使能
		RS485_TX_EN(1);                            //切换485硬件使能为发送		在此处切换485硬件使能-清除485接收完成标志
		for(iN=0;iN<150;iN++)                      //清空485接收响应队列
		{
			RS485_RX_BUFF[iN] = 0xFA;
		}
		__HAL_TIM_ENABLE(&htim2);				    //使能定时器2
	}
}

//定时器2判定接收空闲时间，当空闲时间大于指定时间,认为一帧数据结束
//定时器2中断服务函数@1ms
void TIM2_IRQHandler(void)
{
	//2025.11.5.125159+
	//获取更新中断宏使用错误@用成了更新中断使能标志获取宏
	//if(__HAL_TIM_GET_IT_SOURCE(&htim2,TIM_IT_UPDATE)!=RESET)
	if(__HAL_TIM_GET_FLAG(&htim2, TIM_FLAG_UPDATE))//更新中断有效
	{
		//2025.11.5.125950屏蔽更换宏
		//__HAL_TIM_CLEAR_IT(&htim2,TIM_IT_UPDATE);													//清除中断标志位
		//2025.11.5.125944+
		__HAL_TIM_CLEAR_FLAG(&htim2, TIM_FLAG_UPDATE);//清除更新中断标志
		HAL_TIM_IRQHandler(&htim2);
		__HAL_TIM_DISABLE(&htim2);
		huart2.Instance->DR = RS485_TX_BUFF[0];														//将发送队列第一个字节写入寄存器产生中断
	}

}


void KS_FB_VISU_IF(	StGlobalParam* i_pstStGlobalParam,
					StGrpParam* i_pstStGrpParam)
{
	//变量定义2022.6.20.180953
	static INT iGirth_Uw_A_Rec;//: INT; (*放A周长*)
	static INT iGirth_Uw_B_Rec;//: INT; (*放B周长*)
	static INT iGirth_Pu_Rec;//: INT;(*版周长*)
	static INT iVelocity_Tar_Rec;//: INT;(*目标速度*)
	static INT iAI_mid_Uw_Rec;//: INT;(*放料中位*)
	static INT iAI_mid_If_Rec;//: INT;(*放牵中位*)
	static BYTE byDir_Uw_If_AI_Rec;//: BYTE;(*放料放牵摆臂方向判断bit0:放料bit1:放牵*)
	static WORD wKp_Uw_Rec;//: WORD;(*放料P*)
	static WORD wKi_Uw_Rec;//: WORD;(*放料I*)
	static WORD wKd_Uw_Rec;//: WORD;(*放料D*)
	static WORD wKp_If_Rec;//: WORD;(*放牵P*)
	static WORD wKi_If_Rec;//: WORD;(*放牵i*)
	static WORD wKd_If_Rec;//: WORD;(*放牵d*)
	static BYTE bySwitch_AutoCut_Uw_Rec;//: BYTE;(*放料自动裁切使能开关bit0:使能；bit1:剩余卷径方式bit2:剩余米数方式*)
	static INT iDia_PaperRoller_Uw_Rec;//: INT;(*纸筒直径*10*)
	static INT iFilmThickNess_Rec;//: INT;(*料模厚度*1000*)
	static WORD wAutoMaticCutDia_Uw_Rec;//: WORD;(*剩余卷径方式卷径设定*)
	static WORD wAutoMaticCutMeters_Uw_Rec;//: WORD;(*剩余米数方式米数设定*)
	static WORD wActRemainFilmLenth_Uw_Rec;//: WORD;(*实际剩余料长-校正纸筒直径可用*)
	static INT iAlarm_Uw_Dia_Rec ;//: INT;(*放料报警卷径设置*)
	static INT iDelayMsec_CutterHolder_Rec;//: INT;(*刀架执行时间*)
	static INT iDelayMsec_RollerCylinder_Rec;//: INT;(*压辊执行时间*)
	static INT iDelayMsec_CutOffKnifeCylinder_Rec;//: INT;(*裁刀执行时间*)
	static WORD uiMM_Roller2GummedTape_Rec;//: WORD;(*压辊胶带距离*)
	static WORD uiMM_Roller2CutOfKnife_Rec;//: WORD;(*压辊裁刀距离*)
	static WORD uiMM_CutOfKnife2GummedTape_Rec;//: WORD;(*裁刀胶带距离*)
	static INT iCoefCut_FilmVolPerimeter_Uw_Rec;//:INT;(*放料裁切圈数*)
	static INT iStepVariation4ChangeTime_Rec;//		: INT; (* 2018.9.30.100457/用来步进胶辊延时和裁刀延时的变化量 *)
	static BYTE bySwitch_Compensate_Uw_Rec;//		: BYTE;(*放料翻转架补偿开关：Bit0:补偿开启,bit1:方向取反,bit2:0弧度确认*)
	static WORD wDiam_Tower_Uw_Rec					;//: WORD;(*放料翻转架的直径|mm*)
	static WORD wDiam_NextRoller_Uw_Rec				;//		: WORD;(*放料翻转架下个辊的直径|mm*)
	static WORD wXPos_NextRoller_Uw_Rec				;//		: WORD;(*放料翻转架下个辊的X位置|mm|翻转架中心作为坐标系0点*)
	static WORD wYPos_NextRoller_Uw_Rec				;//		: WORD;(*放料翻转架下个辊的Y位置|mm|翻转架中心作为坐标系0点*)
	static WORD wDiam_DeflectorRoller_Uw_Rec		;//		: WORD;(*翻料架上导向辊的直径|mm*)
	static WORD wDiam_DeflectorRollPos_Uw_Rec		;//		: WORD;(*ABjuli翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	static BYTE byDiamMeasureTypeId_Rec;//: BYTE;(*卷径测量方式=0：电位器=1*)
	static INT iStdVol_Diam_1_Rec;//: INT;
	static INT iStdVol_Diam_2_Rec;//: INT;
	static INT iStdVol_Diam_3_Rec;//: INT;
	static INT iStdVol_Diam_4_Rec;//: INT;
	static DWORD dwStdVol_Volt_AxisA_1_Rec;//: DWORD;
	static DWORD dwStdVol_Volt_AxisA_2_Rec;//: DWORD;
	static DWORD dwStdVol_Volt_AxisA_3_Rec;//: DWORD;
	static DWORD dwStdVol_Volt_AxisA_4_Rec;//: DWORD;
	static INT iStdVol_Coef_Axis_1_Rec;//: INT;(* 卷径测量系数*1000 *)
	static INT iStdVol_Coef_Axis_2_Rec;//: INT;
	static INT iStdVol_Coef_Axis_3_Rec;//: INT;
	static BYTE byIsDebug_DiaMeasureArea_Uw_Rec;//: BYTE;
	static BYTE bySwitch_DiaMeasure_Rec;//: byte;(*bit0:自动卷径开关bit1:双轴biw2:弧面bit3:调试模式*)
	static BYTE bySwitch_Enc_Uw_Rec;//: BYTE;(*放料编码器标定相关bit0:双轴系数bit1:调试模式
									//bit2:定位写入bit3:最小径写入*)
	static WORD wButton_Uw_Rec;		//2023.09.18.161503
		//以上为双向变量区域保留值-用于比对主站参数是否发生变化
	INT iGirth_Uw_A_RX;//: INT; (*放A周长*)
	INT iGirth_Uw_B_RX;//: INT; (*放B周长*)
	INT iGirth_Pu_RX;//: INT;(*版周长*)
	INT iVelocity_Tar_RX;//: INT;(*目标速度*)
	INT iAI_mid_Uw_RX;//: INT;(*放料中位*)
	INT iAI_mid_If_RX;//: INT;(*放牵中位*)
	BYTE byDir_Uw_If_AI_RX;//: BYTE;(*放料放牵摆臂方向判断bit0:放料bit1:放牵*)
	WORD wKp_Uw_RX;//: WORD;(*放料P*)
	WORD wKi_Uw_RX;//: WORD;(*放料I*)
	WORD wKd_Uw_RX;//: WORD;(*放料D*)
	WORD wKp_If_RX;//: WORD;(*放牵P*)
	WORD wKi_If_RX;//: WORD;(*放牵i*)
	WORD wKd_If_RX;//: WORD;(*放牵d*)
	BYTE bySwitch_AutoCut_Uw_RX;//: BYTE;(*放料自动裁切使能开关bit0:使能；bit1:剩余卷径方式bit2:剩余米数方式*)
	INT iDia_PaperRoller_Uw_RX;	//: INT;(*纸筒直径*10*)
	INT iFilmThickNess_RX;		//: INT;(*料模厚度*1000*)
	WORD wAutoMaticCutDia_Uw_RX;//: WORD;(*剩余卷径方式卷径设定*)
	WORD wAutoMaticCutMeters_Uw_RX;//: WORD;(*剩余米数方式米数设定*)
	WORD wActRemainFilmLenth_Uw_RX;//: WORD;(*实际剩余料长-校正纸筒直径可用*)
	INT iAlarm_Uw_Dia_RX ;		   //: INT;(*放料报警卷径设置*)
	INT iDelayMsec_CutterHolder_RX;//: INT;(*刀架执行时间*)
	INT iDelayMsec_RollerCylinder_RX;		//: INT;(*压辊执行时间*)
	INT iDelayMsec_CutOffKnifeCylinder_RX;  //: INT;(*裁刀执行时间*)
	WORD uiMM_Roller2GummedTape_RX;//: WORD;(*压辊胶带距离*)
	WORD uiMM_Roller2CutOfKnife_RX;//: WORD;(*压辊裁刀距离*)
	WORD uiMM_CutOfKnife2GummedTape_RX; //: WORD;(*裁刀胶带距离*)
	INT iCoefCut_FilmVolPerimeter_Uw_RX;//:INT;(*放料裁切圈数*)
	INT iStepVariation4ChangeTime_RX;//		: INT; (* 2018.9.30.100457/用来步进胶辊延时和裁刀延时的变化量 *)
	BYTE bySwitch_Compensate_Uw_RX;  //		: BYTE;(*放料翻转架补偿开关：Bit0:补偿开启,bit1:方向取反,bit2:0弧度确认*)
	WORD wDiam_Tower_Uw_RX					;//     : WORD;(*放料翻转架的直径|mm*)
	WORD wDiam_NextRoller_Uw_RX				;//		: WORD;(*放料翻转架下个辊的直径|mm*)
	WORD wXPos_NextRoller_Uw_RX				;//		: WORD;(*放料翻转架下个辊的X位置|mm|翻转架中心作为坐标系0点*)
	WORD wYPos_NextRoller_Uw_RX				;//		: WORD;(*放料翻转架下个辊的Y位置|mm|翻转架中心作为坐标系0点*)
	WORD wDiam_DeflectorRoller_Uw_RX		;//		: WORD;(*翻料架上导向辊的直径|mm*)
	WORD wDiam_DeflectorRollPos_Uw_RX		;//		: WORD;(*ABjuli翻料架的导向辊圆心运动直径|距离翻转架圆心=该值/2|mm*)
	BYTE byDiamMeasureTypeId_RX;//: BYTE;(*卷径测量方式=0：电位器=1*)
	INT iStdVol_Diam_1_RX;//: INT;
	INT iStdVol_Diam_2_RX;//: INT;
	INT iStdVol_Diam_3_RX;//: INT;
	INT iStdVol_Diam_4_RX;//: INT;
	DWORD dwStdVol_Volt_AxisA_1_RX;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_2_RX;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_3_RX;//: DWORD;
	DWORD dwStdVol_Volt_AxisA_4_RX;//: DWORD;
	INT iStdVol_Coef_Axis_1_RX;//: INT;(* 卷径测量系数*1000 *)
	INT iStdVol_Coef_Axis_2_RX;//: INT;
	INT iStdVol_Coef_Axis_3_RX;//: INT;
	BYTE byIsDebug_DiaMeasureArea_Uw_RX;//: BYTE;
	BYTE bySwitch_DiaMeasure_RX;//: byte;(*bit0:自动卷径开关bit1:双轴biw2:弧面bit3:调试模式*)
	BYTE bySwitch_Enc_Uw_RX;//: BYTE;(*放料编码器标定相关bit0:双轴系数bit1:调试模式
								//bit2:定位写入bit3:最小径写入*)
	WORD wButton_Uw_RX;

	//以上为读取回的人机参数判断从站是否变化

	BYTE bySlaveChangeFlag;
	//从站参数修改记录
	//定义变量结束2022.6.20.181321以下为程序区域

	bySlaveChangeFlag=0;
	if(iGirth_Uw_A_Rec!=i_pstStGrpParam->iGirth_Uw_A)
	{
		bySlaveChangeFlag=1;
	}

	else if(iGirth_Uw_B_Rec!=i_pstStGrpParam->iGirth_Uw_B)
	{
		bySlaveChangeFlag=1;
	}

	else if(iGirth_Pu_Rec!=i_pstStGrpParam->iGirth_Pu)
	{
		bySlaveChangeFlag=1;
	}
	else if(iVelocity_Tar_Rec!=i_pstStGrpParam->iVelocity_Tar)
	{
		bySlaveChangeFlag=1;
	}

	else if(iAI_mid_Uw_Rec!=i_pstStGrpParam->iAI_mid_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(iAI_mid_If_Rec!=i_pstStGrpParam->iAI_mid_If)
	{
		bySlaveChangeFlag=1;
	}

	else if(byDir_Uw_If_AI_Rec!=i_pstStGrpParam->byDir_Uw_If_AI)
	{
		bySlaveChangeFlag=1;
	}

	else if(wKp_Uw_Rec!=i_pstStGrpParam->wKp_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wKi_Uw_Rec!=i_pstStGrpParam->wKi_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wKd_Uw_Rec!=i_pstStGrpParam->wKd_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wKp_If_Rec!=i_pstStGrpParam->wKp_If)
	{
		bySlaveChangeFlag=1;
	}

	else if(wKi_If_Rec!=i_pstStGrpParam->wKi_If)
	{
		bySlaveChangeFlag=1;
	}

	else if(wKd_If_Rec!=i_pstStGrpParam->wKd_If)
	{
		bySlaveChangeFlag=1;
	}

	else if(bySwitch_AutoCut_Uw_Rec!=i_pstStGrpParam->bySwitch_AutoCut_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(iDia_PaperRoller_Uw_Rec!=i_pstStGrpParam->iDia_PaperRoller_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(iFilmThickNess_Rec!=i_pstStGrpParam->iFilmThickNess)
	{
		bySlaveChangeFlag=1;
	}

	else if(wAutoMaticCutDia_Uw_Rec!=i_pstStGrpParam->wAutoMaticCutDia_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wAutoMaticCutMeters_Uw_Rec!=i_pstStGrpParam->wAutoMaticCutMeters_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wActRemainFilmLenth_Uw_Rec!=i_pstStGrpParam->wActRemainFilmLenth_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(iAlarm_Uw_Dia_Rec!=i_pstStGrpParam->iAlarm_Uw_Dia)
	{
		bySlaveChangeFlag=1;
	}

	else if(iDelayMsec_CutterHolder_Rec!=i_pstStGrpParam->iDelayMsec_CutterHolder)
	{
		bySlaveChangeFlag=1;
	}

	else if(iDelayMsec_RollerCylinder_Rec!=i_pstStGrpParam->iDelayMsec_RollerCylinder)
	{
		bySlaveChangeFlag=1;
	}

	else if(iDelayMsec_CutOffKnifeCylinder_Rec!=i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder)
	{
		bySlaveChangeFlag=1;
	}

	else if(uiMM_Roller2GummedTape_Rec!=i_pstStGrpParam->uiMM_Roller2GummedTape)
	{
		bySlaveChangeFlag=1;
	}

	else if(uiMM_Roller2CutOfKnife_Rec!=i_pstStGrpParam->uiMM_Roller2CutOfKnife)
	{
		bySlaveChangeFlag=1;
	}

	else if(uiMM_CutOfKnife2GummedTape_Rec!=i_pstStGrpParam->uiMM_CutOfKnife2GummedTape)
	{
		bySlaveChangeFlag=1;
	}

	else if(iCoefCut_FilmVolPerimeter_Uw_Rec!=i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStepVariation4ChangeTime_Rec!=i_pstStGrpParam->iStepVariation4ChangeTime)
	{
		bySlaveChangeFlag=1;
	}

	else if(bySwitch_Compensate_Uw_Rec!=i_pstStGrpParam->bySwitch_Compensate_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wDiam_Tower_Uw_Rec!=i_pstStGrpParam->wDiam_Tower_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wDiam_NextRoller_Uw_Rec!=i_pstStGrpParam->wDiam_NextRoller_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wXPos_NextRoller_Uw_Rec!=i_pstStGrpParam->wXPos_NextRoller_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wYPos_NextRoller_Uw_Rec!=i_pstStGrpParam->wYPos_NextRoller_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wDiam_DeflectorRoller_Uw_Rec!=i_pstStGrpParam->wDiam_DeflectorRoller_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(wDiam_DeflectorRollPos_Uw_Rec!=i_pstStGrpParam->wDiam_DeflectorRollPos_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(byDiamMeasureTypeId_Rec!=i_pstStGrpParam->byDiamMeasureTypeId)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStdVol_Diam_1_Rec!=i_pstStGrpParam->iStdVol_Diam_1)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStdVol_Diam_2_Rec!=i_pstStGrpParam->iStdVol_Diam_2)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStdVol_Diam_3_Rec!=i_pstStGrpParam->iStdVol_Diam_3)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStdVol_Diam_4_Rec!=i_pstStGrpParam->iStdVol_Diam_4)
	{
		bySlaveChangeFlag=1;
	}

	else if(dwStdVol_Volt_AxisA_1_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_1)
	{
		bySlaveChangeFlag=1;
	}

	else if(dwStdVol_Volt_AxisA_2_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_2)
	{
		bySlaveChangeFlag=1;
	}

	else if(dwStdVol_Volt_AxisA_3_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_3)
	{
		bySlaveChangeFlag=1;
	}

	else if(dwStdVol_Volt_AxisA_4_Rec!=i_pstStGrpParam->dwStdVol_Volt_AxisA_4)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStdVol_Coef_Axis_1_Rec!=i_pstStGrpParam->iStdVol_Coef_Axis_1)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStdVol_Coef_Axis_2_Rec!=i_pstStGrpParam->iStdVol_Coef_Axis_2)
	{
		bySlaveChangeFlag=1;
	}

	else if(iStdVol_Coef_Axis_3_Rec!=i_pstStGrpParam->iStdVol_Coef_Axis_3)
	{
		bySlaveChangeFlag=1;
	}

	else if(byIsDebug_DiaMeasureArea_Uw_Rec!=i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else if(bySwitch_DiaMeasure_Rec!=i_pstStGrpParam->bySwitch_DiaMeasure)
	{
		bySlaveChangeFlag=1;
	}

	else if(bySwitch_Enc_Uw_Rec!=i_pstStGrpParam->bySwitch_Enc_Uw)
	{
		bySlaveChangeFlag=1;
	}
	else if(wButton_Uw_Rec!= i_pstStGrpParam->wButton_Uw)
	{
		bySlaveChangeFlag=1;
	}

	else
	{
		bySlaveChangeFlag=0;
	}
	if( bySlaveChangeFlag != 0 )
	{
		bySendStep = 1;																																//直接进入发送双向参数逻辑
	}
	iGirth_Uw_A_Rec						  =  i_pstStGrpParam->iGirth_Uw_A												;
	iGirth_Uw_B_Rec						  =  i_pstStGrpParam->iGirth_Uw_B						  ;
	iGirth_Pu_Rec						  =  i_pstStGrpParam->iGirth_Pu						  ;
	iVelocity_Tar_Rec					  =  i_pstStGrpParam->iVelocity_Tar					  ;
	iAI_mid_Uw_Rec						  =  i_pstStGrpParam->iAI_mid_Uw						 ;
	iAI_mid_If_Rec						  =  i_pstStGrpParam->iAI_mid_If						 ;
	byDir_Uw_If_AI_Rec					  =  i_pstStGrpParam->byDir_Uw_If_AI					 ;
	wKp_Uw_Rec							  =  i_pstStGrpParam->wKp_Uw							  ;
	wKi_Uw_Rec							  =  i_pstStGrpParam->wKi_Uw							  ;
	wKd_Uw_Rec							  =  i_pstStGrpParam->wKd_Uw							  ;
	wKp_If_Rec							  =  i_pstStGrpParam->wKp_If							  ;
	wKi_If_Rec							  =  i_pstStGrpParam->wKi_If							  ;
	wKd_If_Rec							  =  i_pstStGrpParam->wKd_If							  ;
	bySwitch_AutoCut_Uw_Rec				  =  i_pstStGrpParam->bySwitch_AutoCut_Uw				  ;
	iDia_PaperRoller_Uw_Rec				  =  i_pstStGrpParam->iDia_PaperRoller_Uw				 ;
	iFilmThickNess_Rec					  =  i_pstStGrpParam->iFilmThickNess					  ;
	wAutoMaticCutDia_Uw_Rec				  =  i_pstStGrpParam->wAutoMaticCutDia_Uw				  ;
	wAutoMaticCutMeters_Uw_Rec			  =  i_pstStGrpParam->wAutoMaticCutMeters_Uw			  ;
	wActRemainFilmLenth_Uw_Rec			  =  i_pstStGrpParam->wActRemainFilmLenth_Uw			 ;
	iAlarm_Uw_Dia_Rec 			  =  i_pstStGrpParam->iAlarm_Uw_Dia ;//: INT			 ;
	iDelayMsec_CutterHolder_Rec			  =  i_pstStGrpParam->iDelayMsec_CutterHolder					;
	iDelayMsec_RollerCylinder_Rec		  =  i_pstStGrpParam->iDelayMsec_RollerCylinder								;
	iDelayMsec_CutOffKnifeCylinder_Rec	  =  i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder	  ;
	uiMM_Roller2GummedTape_Rec			  =  i_pstStGrpParam->uiMM_Roller2GummedTape			  ;
	uiMM_Roller2CutOfKnife_Rec			  =  i_pstStGrpParam->uiMM_Roller2CutOfKnife			  ;
	uiMM_CutOfKnife2GummedTape_Rec		  =  i_pstStGrpParam->uiMM_CutOfKnife2GummedTape		 ;
	iCoefCut_FilmVolPerimeter_Uw_Rec	  =  i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw	 ;
	iStepVariation4ChangeTime_Rec		  =  i_pstStGrpParam->iStepVariation4ChangeTime		 ;
	bySwitch_Compensate_Uw_Rec			  =  i_pstStGrpParam->bySwitch_Compensate_Uw			  ;
	wDiam_Tower_Uw_Rec					  =  i_pstStGrpParam->wDiam_Tower_Uw					  ;
	wDiam_NextRoller_Uw_Rec				  =  i_pstStGrpParam->wDiam_NextRoller_Uw				  ;
	wXPos_NextRoller_Uw_Rec				  =  i_pstStGrpParam->wXPos_NextRoller_Uw				  ;
	wYPos_NextRoller_Uw_Rec				  =  i_pstStGrpParam->wYPos_NextRoller_Uw				  ;
	wDiam_DeflectorRoller_Uw_Rec		  =  i_pstStGrpParam->wDiam_DeflectorRoller_Uw		  ;
	wDiam_DeflectorRollPos_Uw_Rec		  =  i_pstStGrpParam->wDiam_DeflectorRollPos_Uw		  ;
	byDiamMeasureTypeId_Rec				  =  i_pstStGrpParam->byDiamMeasureTypeId				 ;
	iStdVol_Diam_1_Rec					  =  i_pstStGrpParam->iStdVol_Diam_1					  ;
	iStdVol_Diam_2_Rec					  =  i_pstStGrpParam->iStdVol_Diam_2					  ;
	iStdVol_Diam_3_Rec					  =  i_pstStGrpParam->iStdVol_Diam_3					  ;
	iStdVol_Diam_4_Rec					  =  i_pstStGrpParam->iStdVol_Diam_4					 ;
	dwStdVol_Volt_AxisA_1_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_1			 ;
	dwStdVol_Volt_AxisA_2_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_2					;
	dwStdVol_Volt_AxisA_3_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_3					;
	dwStdVol_Volt_AxisA_4_Rec			  =  i_pstStGrpParam->dwStdVol_Volt_AxisA_4					;
	iStdVol_Coef_Axis_1_Rec				  =  i_pstStGrpParam->iStdVol_Coef_Axis_1						;
	iStdVol_Coef_Axis_2_Rec				  =  i_pstStGrpParam->iStdVol_Coef_Axis_2						;
	iStdVol_Coef_Axis_3_Rec				  =  i_pstStGrpParam->iStdVol_Coef_Axis_3						;
	byIsDebug_DiaMeasureArea_Uw_Rec		  =  i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw				;
	bySwitch_DiaMeasure_Rec				  =  i_pstStGrpParam->bySwitch_DiaMeasure						;
	bySwitch_Enc_Uw_Rec					  =  i_pstStGrpParam->bySwitch_Enc_Uw							;
	wButton_Uw_Rec						  = i_pstStGrpParam->wButton_Uw;//2023.09.18.161643

	if( bySlaveChangeFlag == 0 )																																			//前提是主站参数未修改
	{
		if( xReceiveSuccessful )																																				//接收数据完成校验通过
		{
			xReceiveSuccessful = 0;																																		//清除标志
			if( RS485_RX_BUFF[1] == 0x03 )																															//功能码为03时，读取周期
			{
				//判断读取数据
				iGirth_Uw_A_RX						= ((WORD)(RS485_RX_BUFF[3]) << 8) + (WORD)(RS485_RX_BUFF[4]);
				iGirth_Uw_B_RX						= ((WORD)(RS485_RX_BUFF[5]) << 8) + (WORD)(RS485_RX_BUFF[6]) ;
				iGirth_Pu_RX						= ((WORD)(RS485_RX_BUFF[7]) << 8) + (WORD)(RS485_RX_BUFF[8]) ;
				iVelocity_Tar_RX					= ((WORD)(RS485_RX_BUFF[9]) << 8) + (WORD)(RS485_RX_BUFF[10]) ;
				iAI_mid_Uw_RX						= ((WORD)(RS485_RX_BUFF[11]) << 8) + (WORD)(RS485_RX_BUFF[12])  ;
				iAI_mid_If_RX						= ((WORD)(RS485_RX_BUFF[13]) << 8) + (WORD)(RS485_RX_BUFF[14]) ;
				 byDir_Uw_If_AI_RX					= ((WORD)(RS485_RX_BUFF[15]) << 8) + (WORD)(RS485_RX_BUFF[16]) ;
				 wKp_Uw_RX							= ((WORD)(RS485_RX_BUFF[17]) << 8) + (WORD)(RS485_RX_BUFF[18])  ;
				 wKi_Uw_RX							= ((WORD)(RS485_RX_BUFF[19]) << 8) + (WORD)(RS485_RX_BUFF[20])  ;
				 wKd_Uw_RX							= ((WORD)(RS485_RX_BUFF[21]) << 8) + (WORD)(RS485_RX_BUFF[22])  ;
				 wKp_If_RX							= ((WORD)(RS485_RX_BUFF[23]) << 8) + (WORD)(RS485_RX_BUFF[24])  ;
				 wKi_If_RX							= ((WORD)(RS485_RX_BUFF[25]) << 8) + (WORD)(RS485_RX_BUFF[26])  ;
				 wKd_If_RX							= ((WORD)(RS485_RX_BUFF[27]) << 8) + (WORD)(RS485_RX_BUFF[28]) ;
				 bySwitch_AutoCut_Uw_RX				= ((WORD)(RS485_RX_BUFF[29]) << 8) + (WORD)(RS485_RX_BUFF[30])  ;
				iDia_PaperRoller_Uw_RX				= ((WORD)(RS485_RX_BUFF[31]) << 8) + (WORD)(RS485_RX_BUFF[32])  ;
				iFilmThickNess_RX					= ((WORD)(RS485_RX_BUFF[33]) << 8) + (WORD)(RS485_RX_BUFF[34])  ;
				 wAutoMaticCutDia_Uw_RX				= ((WORD)(RS485_RX_BUFF[35]) << 8) + (WORD)(RS485_RX_BUFF[36])  ;
				 wAutoMaticCutMeters_Uw_RX			= ((WORD)(RS485_RX_BUFF[37]) << 8) + (WORD)(RS485_RX_BUFF[38])  ;
				 wActRemainFilmLenth_Uw_RX			= ((WORD)(RS485_RX_BUFF[39]) << 8) + (WORD)(RS485_RX_BUFF[40])  ;
				iAlarm_Uw_Dia_RX 					= ((WORD)(RS485_RX_BUFF[41]) << 8) + (WORD)(RS485_RX_BUFF[42]) ;
				iDelayMsec_CutterHolder_RX			= ((WORD)(RS485_RX_BUFF[43]) << 8) + (WORD)(RS485_RX_BUFF[44])	;
				iDelayMsec_RollerCylinder_RX		= ((WORD)(RS485_RX_BUFF[45]) << 8) + (WORD)(RS485_RX_BUFF[46]);
				iDelayMsec_CutOffKnifeCylinder_RX	= ((WORD)(RS485_RX_BUFF[47]) << 8) + (WORD)(RS485_RX_BUFF[48]) ;
				 uiMM_Roller2GummedTape_RX			= ((WORD)(RS485_RX_BUFF[49]) << 8) + (WORD)(RS485_RX_BUFF[50]) ;
				 uiMM_Roller2CutOfKnife_RX			= ((WORD)(RS485_RX_BUFF[51]) << 8) + (WORD)(RS485_RX_BUFF[52]) ;
				 uiMM_CutOfKnife2GummedTape_RX		= ((WORD)(RS485_RX_BUFF[53]) << 8) + (WORD)(RS485_RX_BUFF[54])  ;
				iCoefCut_FilmVolPerimeter_Uw_RX		= ((WORD)(RS485_RX_BUFF[55]) << 8) + (WORD)(RS485_RX_BUFF[56]) ;
				iStepVariation4ChangeTime_RX		= ((WORD)(RS485_RX_BUFF[57]) << 8) + (WORD)(RS485_RX_BUFF[58]) ;
				 bySwitch_Compensate_Uw_RX			= ((WORD)(RS485_RX_BUFF[59]) << 8) + (WORD)(RS485_RX_BUFF[60])  ;
				 wDiam_Tower_Uw_RX					= ((WORD)(RS485_RX_BUFF[61]) << 8) + (WORD)(RS485_RX_BUFF[62])  ;
				 wDiam_NextRoller_Uw_RX				= ((WORD)(RS485_RX_BUFF[63]) << 8) + (WORD)(RS485_RX_BUFF[64])  ;
				 wXPos_NextRoller_Uw_RX				= ((WORD)(RS485_RX_BUFF[65]) << 8) + (WORD)(RS485_RX_BUFF[66])  ;
				 wYPos_NextRoller_Uw_RX				= ((WORD)(RS485_RX_BUFF[67]) << 8) + (WORD)(RS485_RX_BUFF[68])  ;
				 wDiam_DeflectorRoller_Uw_RX		= ((WORD)(RS485_RX_BUFF[69]) << 8) + (WORD)(RS485_RX_BUFF[70]) ;
				 wDiam_DeflectorRollPos_Uw_RX		= ((WORD)(RS485_RX_BUFF[71]) << 8) + (WORD)(RS485_RX_BUFF[72])  ;
				 byDiamMeasureTypeId_RX				= ((WORD)(RS485_RX_BUFF[73]) << 8) + (WORD)(RS485_RX_BUFF[74])  ;
				iStdVol_Diam_1_RX					= ((WORD)(RS485_RX_BUFF[75]) << 8) + (WORD)(RS485_RX_BUFF[76])  ;
				iStdVol_Diam_2_RX					= ((WORD)(RS485_RX_BUFF[77]) << 8) + (WORD)(RS485_RX_BUFF[78])  ;
				iStdVol_Diam_3_RX					= ((WORD)(RS485_RX_BUFF[79]) << 8) + (WORD)(RS485_RX_BUFF[80])  ;
				iStdVol_Diam_4_RX					= ((WORD)(RS485_RX_BUFF[81]) << 8) + (WORD)(RS485_RX_BUFF[82])  ;
				 dwStdVol_Volt_AxisA_1_RX			= ((DWORD)(RS485_RX_BUFF[83]) << 24) + ((DWORD)(RS485_RX_BUFF[84]) << 16)
		+ ((DWORD)(RS485_RX_BUFF[85]) << 8) + ((DWORD)(RS485_RX_BUFF[86]));
				 dwStdVol_Volt_AxisA_2_RX			= ((DWORD)(RS485_RX_BUFF[87]) << 24) + ((DWORD)(RS485_RX_BUFF[88]) << 16)
		+ ((DWORD)(RS485_RX_BUFF[89]) << 8) + ((DWORD)(RS485_RX_BUFF[90]));
				 dwStdVol_Volt_AxisA_3_RX			= ((DWORD)(RS485_RX_BUFF[91]) << 24) + ((DWORD)(RS485_RX_BUFF[92]) << 16)
		+ ((DWORD)(RS485_RX_BUFF[93]) << 8) + ((DWORD)(RS485_RX_BUFF[94]));
				 dwStdVol_Volt_AxisA_4_RX			= ((DWORD)(RS485_RX_BUFF[95]) << 24) + ((DWORD)(RS485_RX_BUFF[96]) << 16)
		+ ((DWORD)(RS485_RX_BUFF[97]) << 8) + ((DWORD)(RS485_RX_BUFF[98]));
				iStdVol_Coef_Axis_1_RX				= ((WORD)(RS485_RX_BUFF[99]) << 8) + (WORD)(RS485_RX_BUFF[100]) ;
				iStdVol_Coef_Axis_2_RX				= ((WORD)(RS485_RX_BUFF[101]) << 8) + (WORD)(RS485_RX_BUFF[102]) ;
				iStdVol_Coef_Axis_3_RX				= ((WORD)(RS485_RX_BUFF[103]) << 8) + (WORD)(RS485_RX_BUFF[104])  ;
				 byIsDebug_DiaMeasureArea_Uw_RX		= ((WORD)(RS485_RX_BUFF[105]) << 8) + (WORD)(RS485_RX_BUFF[106]) ;
				 bySwitch_DiaMeasure_RX				= ((WORD)(RS485_RX_BUFF[107]) << 8) + (WORD)(RS485_RX_BUFF[108]) ;
				 bySwitch_Enc_Uw_RX					= ((WORD)(RS485_RX_BUFF[109]) << 8) + (WORD)(RS485_RX_BUFF[110])  ;
				 wButton_Uw_RX					= ((WORD)(RS485_RX_BUFF[111]) << 8) + (WORD)(RS485_RX_BUFF[112])  ;//2023.09.18.162230

				if( iGirth_Uw_A_RX!=0 &&
						iGirth_Uw_B_RX!=0 &&
						iGirth_Pu_RX!=0 &&
						iVelocity_Tar_RX!=0 &&  //2023.3.7.164229新增非0判断-防止人机重启等
					(	(iGirth_Uw_A_RX					  !=  i_pstStGrpParam->iGirth_Uw_A					) ||
						(iGirth_Uw_B_RX					  !=  i_pstStGrpParam->iGirth_Uw_B					) ||
						(iGirth_Pu_RX						  !=  i_pstStGrpParam->iGirth_Pu						) ||
						(iVelocity_Tar_RX					  !=  i_pstStGrpParam->iVelocity_Tar					) ||
						(iAI_mid_Uw_RX						  !=  i_pstStGrpParam->iAI_mid_Uw					) ||
						(iAI_mid_If_RX						  !=  i_pstStGrpParam->iAI_mid_If					) ||
						(byDir_Uw_If_AI_RX					  !=  i_pstStGrpParam->byDir_Uw_If_AI				) ||
						(wKp_Uw_RX							  !=  i_pstStGrpParam->wKp_Uw						) ||
						(wKi_Uw_RX							  !=  i_pstStGrpParam->wKi_Uw						) ||
						(wKd_Uw_RX							  !=  i_pstStGrpParam->wKd_Uw						) ||
						(wKp_If_RX							  !=  i_pstStGrpParam->wKp_If						) ||
						(wKi_If_RX							  !=  i_pstStGrpParam->wKi_If						) ||
						(wKd_If_RX							  !=  i_pstStGrpParam->wKd_If						) ||
						(bySwitch_AutoCut_Uw_RX			  !=  i_pstStGrpParam->bySwitch_AutoCut_Uw			) ||
						(iDia_PaperRoller_Uw_RX			  !=  i_pstStGrpParam->iDia_PaperRoller_Uw			) ||
						(iFilmThickNess_RX					  !=  i_pstStGrpParam->iFilmThickNess				) ||
						(wAutoMaticCutDia_Uw_RX			  !=  i_pstStGrpParam->wAutoMaticCutDia_Uw			) ||
						(wAutoMaticCutMeters_Uw_RX			  !=  i_pstStGrpParam->wAutoMaticCutMeters_Uw		) ||
						(wActRemainFilmLenth_Uw_RX			  !=  i_pstStGrpParam->wActRemainFilmLenth_Uw		) ||
						(iAlarm_Uw_Dia_RX 			  		  !=  i_pstStGrpParam->iAlarm_Uw_Dia 	) ||
						(iDelayMsec_CutterHolder_RX		  !=  i_pstStGrpParam->iDelayMsec_CutterHolder		) ||
						(iDelayMsec_RollerCylinder_RX		  !=  i_pstStGrpParam->iDelayMsec_RollerCylinder		) ||
						(iDelayMsec_CutOffKnifeCylinder_RX	  !=  i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder) ||
						(uiMM_Roller2GummedTape_RX			  !=  i_pstStGrpParam->uiMM_Roller2GummedTape		) ||
						(uiMM_Roller2CutOfKnife_RX			  !=  i_pstStGrpParam->uiMM_Roller2CutOfKnife		) ||
						(uiMM_CutOfKnife2GummedTape_RX		  !=  i_pstStGrpParam->uiMM_CutOfKnife2GummedTape	) ||
						(iCoefCut_FilmVolPerimeter_Uw_RX	  !=  i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw	) ||
						(iStepVariation4ChangeTime_RX		  !=  i_pstStGrpParam->iStepVariation4ChangeTime		) ||
						(bySwitch_Compensate_Uw_RX			  !=  i_pstStGrpParam->bySwitch_Compensate_Uw		) ||
						(wDiam_Tower_Uw_RX					  !=  i_pstStGrpParam->wDiam_Tower_Uw				) ||
						(wDiam_NextRoller_Uw_RX			  !=  i_pstStGrpParam->wDiam_NextRoller_Uw			) ||
						(wXPos_NextRoller_Uw_RX			  !=  i_pstStGrpParam->wXPos_NextRoller_Uw			) ||
						(wYPos_NextRoller_Uw_RX			  !=  i_pstStGrpParam->wYPos_NextRoller_Uw			) ||
						(wDiam_DeflectorRoller_Uw_RX		  !=  i_pstStGrpParam->wDiam_DeflectorRoller_Uw		) ||
						(wDiam_DeflectorRollPos_Uw_RX		  !=  i_pstStGrpParam->wDiam_DeflectorRollPos_Uw		) ||
						(byDiamMeasureTypeId_RX			  !=  i_pstStGrpParam->byDiamMeasureTypeId			) ||
						(iStdVol_Diam_1_RX					  !=  i_pstStGrpParam->iStdVol_Diam_1				) ||
						(iStdVol_Diam_2_RX					  !=  i_pstStGrpParam->iStdVol_Diam_2				) ||
						(iStdVol_Diam_3_RX					  !=  i_pstStGrpParam->iStdVol_Diam_3				) ||
						(iStdVol_Diam_4_RX					  !=  i_pstStGrpParam->iStdVol_Diam_4				) ||
						(dwStdVol_Volt_AxisA_1_RX			  !=  i_pstStGrpParam->dwStdVol_Volt_AxisA_1			) ||
						(dwStdVol_Volt_AxisA_2_RX			  !=  i_pstStGrpParam->dwStdVol_Volt_AxisA_2			) ||
						(dwStdVol_Volt_AxisA_3_RX			  !=  i_pstStGrpParam->dwStdVol_Volt_AxisA_3			) ||
						(dwStdVol_Volt_AxisA_4_RX			  !=  i_pstStGrpParam->dwStdVol_Volt_AxisA_4			) ||
						(iStdVol_Coef_Axis_1_RX			  !=  i_pstStGrpParam->iStdVol_Coef_Axis_1			) ||
						(iStdVol_Coef_Axis_2_RX			  !=  i_pstStGrpParam->iStdVol_Coef_Axis_2			) ||
						(iStdVol_Coef_Axis_3_RX			  !=  i_pstStGrpParam->iStdVol_Coef_Axis_3			) ||
						(byIsDebug_DiaMeasureArea_Uw_RX	  !=  i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw	) ||
						(bySwitch_DiaMeasure_RX			  !=  i_pstStGrpParam->bySwitch_DiaMeasure			) ||
						(bySwitch_Enc_Uw_RX				  !=  i_pstStGrpParam->bySwitch_Enc_Uw				) 	||
						(wButton_Uw_RX              	  != i_pstStGrpParam->wButton_Uw ) //2023.09.18.161740
					)
				)	//2022.6.20.184115
				{
					i_pstStGrpParam->iGirth_Uw_A					= iGirth_Uw_A_RX						  							;
					i_pstStGrpParam->iGirth_Uw_B					= iGirth_Uw_B_RX						  	  ;
					i_pstStGrpParam->iGirth_Pu						= iGirth_Pu_RX						    ;
					i_pstStGrpParam->iVelocity_Tar					= iVelocity_Tar_RX					    ;
					i_pstStGrpParam->iAI_mid_Uw					= iAI_mid_Uw_RX						  	 ;
					i_pstStGrpParam->iAI_mid_If					= iAI_mid_If_RX						  	 ;
					i_pstStGrpParam->byDir_Uw_If_AI				= byDir_Uw_If_AI_RX					  	 ;
					i_pstStGrpParam->wKp_Uw						= wKp_Uw_RX							  	  ;
					i_pstStGrpParam->wKi_Uw						= wKi_Uw_RX							  	  ;
					i_pstStGrpParam->wKd_Uw						= wKd_Uw_RX							  	  ;
					i_pstStGrpParam->wKp_If						= wKp_If_RX							  	  ;
					i_pstStGrpParam->wKi_If						= wKi_If_RX							  	  ;
					i_pstStGrpParam->wKd_If						= wKd_If_RX							  	  ;
					i_pstStGrpParam->bySwitch_AutoCut_Uw			= bySwitch_AutoCut_Uw_RX				  	  ;
					i_pstStGrpParam->iDia_PaperRoller_Uw			= iDia_PaperRoller_Uw_RX				  	 ;
					i_pstStGrpParam->iFilmThickNess				= iFilmThickNess_RX					  	  ;
					i_pstStGrpParam->wAutoMaticCutDia_Uw			= wAutoMaticCutDia_Uw_RX				  	  ;
					i_pstStGrpParam->wAutoMaticCutMeters_Uw		= wAutoMaticCutMeters_Uw_RX			  	  ;
					i_pstStGrpParam->wActRemainFilmLenth_Uw		= wActRemainFilmLenth_Uw_RX			  	 ;
					i_pstStGrpParam->iAlarm_Uw_Dia 		= iAlarm_Uw_Dia_RX 			  		  	 ;
					i_pstStGrpParam->iDelayMsec_CutterHolder		= iDelayMsec_CutterHolder_RX			  			;
					i_pstStGrpParam->iDelayMsec_RollerCylinder		= iDelayMsec_RollerCylinder_RX		  						;
					i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder= iDelayMsec_CutOffKnifeCylinder_RX	  	  ;
					i_pstStGrpParam->uiMM_Roller2GummedTape		= uiMM_Roller2GummedTape_RX			  	  ;
					i_pstStGrpParam->uiMM_Roller2CutOfKnife		= uiMM_Roller2CutOfKnife_RX			  	  ;
					i_pstStGrpParam->uiMM_CutOfKnife2GummedTape	= uiMM_CutOfKnife2GummedTape_RX		  	 ;
					i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw	= iCoefCut_FilmVolPerimeter_Uw_RX	  	 ;
					i_pstStGrpParam->iStepVariation4ChangeTime		= iStepVariation4ChangeTime_RX		  	 ;
					i_pstStGrpParam->bySwitch_Compensate_Uw		= bySwitch_Compensate_Uw_RX			  	  ;
					i_pstStGrpParam->wDiam_Tower_Uw				= wDiam_Tower_Uw_RX					  	  ;
					i_pstStGrpParam->wDiam_NextRoller_Uw			= wDiam_NextRoller_Uw_RX				  	  ;
					i_pstStGrpParam->wXPos_NextRoller_Uw			= wXPos_NextRoller_Uw_RX				  	  ;
					i_pstStGrpParam->wYPos_NextRoller_Uw			= wYPos_NextRoller_Uw_RX				  	  ;
					i_pstStGrpParam->wDiam_DeflectorRoller_Uw		= wDiam_DeflectorRoller_Uw_RX		    ;
					i_pstStGrpParam->wDiam_DeflectorRollPos_Uw		= wDiam_DeflectorRollPos_Uw_RX		    ;
					i_pstStGrpParam->byDiamMeasureTypeId			= byDiamMeasureTypeId_RX				  	 ;
					i_pstStGrpParam->iStdVol_Diam_1				= iStdVol_Diam_1_RX					  	  ;
					i_pstStGrpParam->iStdVol_Diam_2				= iStdVol_Diam_2_RX					  	  ;
					i_pstStGrpParam->iStdVol_Diam_3				= iStdVol_Diam_3_RX					  	  ;
					i_pstStGrpParam->iStdVol_Diam_4				= iStdVol_Diam_4_RX					  	 ;
					i_pstStGrpParam->dwStdVol_Volt_AxisA_1			= dwStdVol_Volt_AxisA_1_RX			  	 ;
					i_pstStGrpParam->dwStdVol_Volt_AxisA_2			= dwStdVol_Volt_AxisA_2_RX			  		;
					i_pstStGrpParam->dwStdVol_Volt_AxisA_3			= dwStdVol_Volt_AxisA_3_RX			  		;
					i_pstStGrpParam->dwStdVol_Volt_AxisA_4			= dwStdVol_Volt_AxisA_4_RX			  		;
					i_pstStGrpParam->iStdVol_Coef_Axis_1			= iStdVol_Coef_Axis_1_RX				  			;
					i_pstStGrpParam->iStdVol_Coef_Axis_2			= iStdVol_Coef_Axis_2_RX				  			;
					i_pstStGrpParam->iStdVol_Coef_Axis_3			= iStdVol_Coef_Axis_3_RX				  			;
					i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw	= byIsDebug_DiaMeasureArea_Uw_RX		  			;
					i_pstStGrpParam->bySwitch_DiaMeasure			= bySwitch_DiaMeasure_RX				  			;
					i_pstStGrpParam->bySwitch_Enc_Uw				= bySwitch_Enc_Uw_RX					  			;
					i_pstStGrpParam->wButton_Uw           =   wButton_Uw_RX ; //2023.09.18.162339

					bySendStep = 1;//更新一次参数

				}
			}
			else
			{
				;
			}
		}
	}
	switch( bySendStep )//1：发送双向/变化很少数的变量；2：正常周期读取-发送-读取-发送
	{
	case 1:
		stSt485_Format.byStationId= 0x01;																									//通讯站号
		stSt485_Format.bycmd= 0x10;																											//通讯功能码
		stSt485_Format.wAddress= 0x0;																									//通讯起始地址

		stSt485_Format.wNum_Register= 0x0064;//双向区域增加到40-2022.3.21.154308

		stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;

		//2024.04.14.193000 复位数组
		for(iN=0;iN<250;iN++)
		{
			RS485_TX_BUFF[iN]=0;
		}
		//数据包包头处理完成-填入发送缓冲区-----------------------------------------------2021.8.20.145114
		RS485_TX_BUFF[0]= stSt485_Format.byStationId;																				//站号
		RS485_TX_BUFF[1]= stSt485_Format.bycmd;																						//功能码
		RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;													//寄存器地址高
		RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;														//寄存器地址低
		RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;											//寄存器数量高
		RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;												//寄存器数量低
		RS485_TX_BUFF[6]= stSt485_Format.bySendNum_Bytes;																	//总字节数
		//接下来填入有效数据------------------------------------------------------------------------2021.8.20.145122
		RS485_TX_BUFF[7]= (BYTE)(((WORD)(i_pstStGrpParam->iGirth_Uw_A))>>8);
		RS485_TX_BUFF[8]= (BYTE)((WORD)(i_pstStGrpParam->iGirth_Uw_A));
		RS485_TX_BUFF[9]= (BYTE)(((WORD)(i_pstStGrpParam->iGirth_Uw_B))>>8);
		RS485_TX_BUFF[10]= (BYTE)((WORD)(i_pstStGrpParam->iGirth_Uw_B));
		RS485_TX_BUFF[11]= (BYTE)(((WORD)(i_pstStGrpParam->iGirth_Pu))>>8);
		RS485_TX_BUFF[12]= (BYTE)((WORD)(i_pstStGrpParam->iGirth_Pu));
		RS485_TX_BUFF[13]= (BYTE)(((WORD)(i_pstStGrpParam->iVelocity_Tar))>>8);
		RS485_TX_BUFF[14]= (BYTE)((WORD)(i_pstStGrpParam->iVelocity_Tar));
		RS485_TX_BUFF[15]= (BYTE)(((WORD)(i_pstStGrpParam->iAI_mid_Uw))>>8);
		RS485_TX_BUFF[16]= (BYTE)((WORD)(i_pstStGrpParam->iAI_mid_Uw));
		RS485_TX_BUFF[17]= (BYTE)(((WORD)(i_pstStGrpParam->iAI_mid_If))>>8);
		RS485_TX_BUFF[18]= (BYTE)((WORD)(i_pstStGrpParam->iAI_mid_If));
		RS485_TX_BUFF[19]= 0;
		RS485_TX_BUFF[20]= (i_pstStGrpParam->byDir_Uw_If_AI);
		RS485_TX_BUFF[21]= (BYTE)(((i_pstStGrpParam->wKp_Uw))>>8);
		RS485_TX_BUFF[22]= (BYTE)((i_pstStGrpParam->wKp_Uw));
		RS485_TX_BUFF[23]= (BYTE)(((i_pstStGrpParam->wKi_Uw))>>8);
		RS485_TX_BUFF[24]= (BYTE)((i_pstStGrpParam->wKi_Uw));
		RS485_TX_BUFF[25]= (BYTE)(((i_pstStGrpParam->wKd_Uw))>>8);
		RS485_TX_BUFF[26]= (BYTE)((i_pstStGrpParam->wKd_Uw));
		RS485_TX_BUFF[27]= (BYTE)(((i_pstStGrpParam->wKp_If))>>8);
		RS485_TX_BUFF[28]= (BYTE)((i_pstStGrpParam->wKp_If));
		RS485_TX_BUFF[29]= (BYTE)(((i_pstStGrpParam->wKi_If))>>8);
		RS485_TX_BUFF[30]= (BYTE)((i_pstStGrpParam->wKi_If));
		RS485_TX_BUFF[31]= (BYTE)(((i_pstStGrpParam->wKd_If))>>8);
		RS485_TX_BUFF[32]= (BYTE)((i_pstStGrpParam->wKd_If));
		RS485_TX_BUFF[33]= 0;
		RS485_TX_BUFF[34]= (i_pstStGrpParam->bySwitch_AutoCut_Uw);
		RS485_TX_BUFF[35]= (BYTE)(((WORD)(i_pstStGrpParam->iDia_PaperRoller_Uw))>>8);
		RS485_TX_BUFF[36]= (BYTE)((WORD)(i_pstStGrpParam->iDia_PaperRoller_Uw));
		RS485_TX_BUFF[37]= (BYTE)(((WORD)(i_pstStGrpParam->iFilmThickNess))>>8);
		RS485_TX_BUFF[38]= (BYTE)((WORD)(i_pstStGrpParam->iFilmThickNess));
		RS485_TX_BUFF[39]= (BYTE)(((i_pstStGrpParam->wAutoMaticCutDia_Uw))>>8);
		RS485_TX_BUFF[40]= (BYTE)((i_pstStGrpParam->wAutoMaticCutDia_Uw));
		RS485_TX_BUFF[41]= (BYTE)(((i_pstStGrpParam->wAutoMaticCutMeters_Uw))>>8);
		RS485_TX_BUFF[42]= (BYTE)((i_pstStGrpParam->wAutoMaticCutMeters_Uw));
		RS485_TX_BUFF[43]= (BYTE)(((i_pstStGrpParam->wActRemainFilmLenth_Uw))>>8);
		RS485_TX_BUFF[44]= (BYTE)((i_pstStGrpParam->wActRemainFilmLenth_Uw));
		RS485_TX_BUFF[45]= (BYTE)(((WORD)(i_pstStGrpParam->iAlarm_Uw_Dia))>>8);
		RS485_TX_BUFF[46]= (BYTE)((WORD)(i_pstStGrpParam->iAlarm_Uw_Dia));
		RS485_TX_BUFF[47]= (BYTE)(((WORD)(i_pstStGrpParam->iDelayMsec_CutterHolder))>>8);
		RS485_TX_BUFF[48]= (BYTE)((WORD)(i_pstStGrpParam->iDelayMsec_CutterHolder));
		RS485_TX_BUFF[49]= (BYTE)(((WORD)(i_pstStGrpParam->iDelayMsec_RollerCylinder))>>8);
		RS485_TX_BUFF[50]= (BYTE)((WORD)(i_pstStGrpParam->iDelayMsec_RollerCylinder));
		RS485_TX_BUFF[51]= (BYTE)(((WORD)(i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder))>>8);
		RS485_TX_BUFF[52]= (BYTE)((WORD)(i_pstStGrpParam->iDelayMsec_CutOffKnifeCylinder));
		RS485_TX_BUFF[53]= (BYTE)(((i_pstStGrpParam->uiMM_Roller2GummedTape))>>8);
		RS485_TX_BUFF[54]= (BYTE)((i_pstStGrpParam->uiMM_Roller2GummedTape));
		RS485_TX_BUFF[55]= (BYTE)(((i_pstStGrpParam->uiMM_Roller2CutOfKnife))>>8);
		RS485_TX_BUFF[56]= (BYTE)((i_pstStGrpParam->uiMM_Roller2CutOfKnife));
		RS485_TX_BUFF[57]= (BYTE)(((i_pstStGrpParam->uiMM_CutOfKnife2GummedTape))>>8);
		RS485_TX_BUFF[58]= (BYTE)((i_pstStGrpParam->uiMM_CutOfKnife2GummedTape));
		RS485_TX_BUFF[59]= (BYTE)(((WORD)(i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw))>>8);
		RS485_TX_BUFF[60]= (BYTE)((WORD)(i_pstStGrpParam->iCoefCut_FilmVolPerimeter_Uw));
		RS485_TX_BUFF[61]= (BYTE)(((WORD)(i_pstStGrpParam->iStepVariation4ChangeTime))>>8);
		RS485_TX_BUFF[62]= (BYTE)((WORD)(i_pstStGrpParam->iStepVariation4ChangeTime));
		RS485_TX_BUFF[63]= 0;
		RS485_TX_BUFF[64]= (i_pstStGrpParam->bySwitch_Compensate_Uw);
		RS485_TX_BUFF[65]= (BYTE)(((i_pstStGrpParam->wDiam_Tower_Uw))>>8);
		RS485_TX_BUFF[66]= (BYTE)((i_pstStGrpParam->wDiam_Tower_Uw));
		RS485_TX_BUFF[67]= (BYTE)(((i_pstStGrpParam->wDiam_NextRoller_Uw))>>8);
		RS485_TX_BUFF[68]= (BYTE)((i_pstStGrpParam->wDiam_NextRoller_Uw));
		RS485_TX_BUFF[69]= (BYTE)(((i_pstStGrpParam->wXPos_NextRoller_Uw))>>8);
		RS485_TX_BUFF[70]= (BYTE)((i_pstStGrpParam->wXPos_NextRoller_Uw));
		RS485_TX_BUFF[71]= (BYTE)(((i_pstStGrpParam->wYPos_NextRoller_Uw))>>8);
		RS485_TX_BUFF[72]= (BYTE)((i_pstStGrpParam->wYPos_NextRoller_Uw));
		RS485_TX_BUFF[73]= (BYTE)(((i_pstStGrpParam->wDiam_DeflectorRoller_Uw))>>8);
		RS485_TX_BUFF[74]= (BYTE)((i_pstStGrpParam->wDiam_DeflectorRoller_Uw));
		RS485_TX_BUFF[75]= (BYTE)(((i_pstStGrpParam->wDiam_DeflectorRollPos_Uw))>>8);
		RS485_TX_BUFF[76]= (BYTE)((i_pstStGrpParam->wDiam_DeflectorRollPos_Uw));
		RS485_TX_BUFF[77]= 0;
		RS485_TX_BUFF[78]= (i_pstStGrpParam->byDiamMeasureTypeId);
		RS485_TX_BUFF[79]= (BYTE)(((WORD)(i_pstStGrpParam->iStdVol_Diam_1))>>8);
		RS485_TX_BUFF[80]= (BYTE)((WORD)(i_pstStGrpParam->iStdVol_Diam_1));
		RS485_TX_BUFF[81]= (BYTE)(((WORD)(i_pstStGrpParam->iStdVol_Diam_2))>>8);
		RS485_TX_BUFF[82]= (BYTE)((WORD)(i_pstStGrpParam->iStdVol_Diam_2));
		RS485_TX_BUFF[83]= (BYTE)(((WORD)(i_pstStGrpParam->iStdVol_Diam_3))>>8);
		RS485_TX_BUFF[84]= (BYTE)((WORD)(i_pstStGrpParam->iStdVol_Diam_3));
		RS485_TX_BUFF[85]= (BYTE)(((WORD)(i_pstStGrpParam->iStdVol_Diam_4))>>8);
		RS485_TX_BUFF[86]= (BYTE)((WORD)(i_pstStGrpParam->iStdVol_Diam_4));
		RS485_TX_BUFF[87]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_1)) & 0xFF000000)>>24);
		RS485_TX_BUFF[88]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_1)) & 0xFF0000)>>16);
		RS485_TX_BUFF[89]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_1)) & 0xFF00)>>8);
		RS485_TX_BUFF[90]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_1)) & 0xFF));
		RS485_TX_BUFF[91]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_2)) & 0xFF000000)>>24);
		RS485_TX_BUFF[92]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_2)) & 0xFF0000)>>16);
		RS485_TX_BUFF[93]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_2)) & 0xFF00)>>8);
		RS485_TX_BUFF[94]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_2)) & 0xFF));
		RS485_TX_BUFF[95]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_3)) & 0xFF000000)>>24);
		RS485_TX_BUFF[96]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_3)) & 0xFF0000)>>16);
		RS485_TX_BUFF[97]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_3)) & 0xFF00)>>8);
		RS485_TX_BUFF[98]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_3)) & 0xFF));
		RS485_TX_BUFF[99]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_4)) & 0xFF000000)>>24);
		RS485_TX_BUFF[100]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_4)) & 0xFF0000)>>16);
		RS485_TX_BUFF[101]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_4)) & 0xFF00)>>8);
		RS485_TX_BUFF[102]= (BYTE)((((i_pstStGrpParam->dwStdVol_Volt_AxisA_4)) & 0xFF));
		RS485_TX_BUFF[103]= (BYTE)(((WORD)(i_pstStGrpParam->iStdVol_Coef_Axis_1))>>8);
		RS485_TX_BUFF[104]= (BYTE)((WORD)(i_pstStGrpParam->iStdVol_Coef_Axis_1));
		RS485_TX_BUFF[105]= (BYTE)(((WORD)(i_pstStGrpParam->iStdVol_Coef_Axis_2))>>8);
		RS485_TX_BUFF[106]= (BYTE)((WORD)(i_pstStGrpParam->iStdVol_Coef_Axis_2));
		RS485_TX_BUFF[107]= (BYTE)(((WORD)(i_pstStGrpParam->iStdVol_Coef_Axis_3))>>8);
		RS485_TX_BUFF[108]= (BYTE)((WORD)(i_pstStGrpParam->iStdVol_Coef_Axis_3));
		RS485_TX_BUFF[109]= 0;
		RS485_TX_BUFF[110]= (i_pstStGrpParam->byIsDebug_DiaMeasureArea_Uw);
		RS485_TX_BUFF[111]= 0;
		RS485_TX_BUFF[112]= (i_pstStGrpParam->bySwitch_DiaMeasure);
		RS485_TX_BUFF[113]= 0;
		RS485_TX_BUFF[114]= (i_pstStGrpParam->bySwitch_Enc_Uw);

		//2023.09.18.161936
		RS485_TX_BUFF[115]= (BYTE)(((WORD)(i_pstStGrpParam->wButton_Uw))>>8);
		RS485_TX_BUFF[116]= (BYTE)((WORD)(i_pstStGrpParam->wButton_Uw));

		//从代码上看是把115和116清零了-逻辑重新调整下@2024.04.14.192225
		//在上面直接初始化buff数组-使用日期搜索
//		for(iN=0;iN<92;iN++)
//		{
//			RS485_TX_BUFF[115+iN]= 0;
//		}
		stSt485_Format.wCRC = CRC_Compute(RS485_TX_BUFF, 0, 207);
		RS485_TX_BUFF[207] = (stSt485_Format.wCRC >> 8) & 0xFF;
		RS485_TX_BUFF[208] = (stSt485_Format.wCRC) & 0xFF;
		stSt485_Format.byNum_Bytes= 209;
		stSt485_Format.byReadNum_Bytes = 4;	 																									//读取的有效字节数(写入数据就是响应的寄存器地址和数量)
		break;

	case 2:
		switch( byNormalStep )
		{
		case 0://读取周期，读取界面参数是否发生变化
			stSt485_Format.byStationId= 0x01;																									//通讯站号
			stSt485_Format.bycmd= 0x03;																											//通讯功能码
			stSt485_Format.wAddress= 0x0;																									//通讯起始地址
			stSt485_Format.wNum_Register= 0x64;																						//通讯寄存器数量和字节数
			stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;

			RS485_TX_BUFF[0]= stSt485_Format.byStationId;//站号，威纶人机设置为01
			RS485_TX_BUFF[1]= stSt485_Format.bycmd;//功能码0x03,读多个寄存器
			RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;//起始地址高位
			RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;//起始地址低位，地址6000地址6000
			RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;//寄存器数量高位
			RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;//寄存器数量低位
			stSt485_Format.wCRC= CRC_Compute(RS485_TX_BUFF,0,6);
			RS485_TX_BUFF[6]= (BYTE)(stSt485_Format.wCRC>>8) & 0xFF;//寄存器数量高位
			RS485_TX_BUFF[7]= (BYTE)(stSt485_Format.wCRC) & 0xFF;//寄存器数量低位
			stSt485_Format.byNum_Bytes= 8;
			stSt485_Format.byReadNum_Bytes= stSt485_Format.bySendNum_Bytes;
			break;

		case 1:
			stSt485_Format.byStationId= 0x01;																									//通讯站号
			stSt485_Format.bycmd= 0x10;																											//通讯功能码
			stSt485_Format.wAddress= 0x0064;																									//通讯起始地址
			stSt485_Format.wNum_Register= 0x0064;																						//通讯寄存器数量和字节数
			stSt485_Format.bySendNum_Bytes= stSt485_Format.wNum_Register*2;

			//2024.04.14.193000 复位数组
			for(iN=0;iN<250;iN++)
			{
				RS485_TX_BUFF[iN]=0;
			}

			RS485_TX_BUFF[0]= stSt485_Format.byStationId;																				//站号
			RS485_TX_BUFF[1]= stSt485_Format.bycmd;																						//功能码
			RS485_TX_BUFF[2]= (BYTE)(stSt485_Format.wAddress>>8) & 0xFF;													//寄存器地址高
			RS485_TX_BUFF[3]= (BYTE)(stSt485_Format.wAddress) & 0xFF;														//寄存器地址低
			RS485_TX_BUFF[4]= (BYTE)(stSt485_Format.wNum_Register>>8) & 0xFF;											//寄存器数量高
			RS485_TX_BUFF[5]= (BYTE)(stSt485_Format.wNum_Register) & 0xFF;												//寄存器数量低
			RS485_TX_BUFF[6]= stSt485_Format.bySendNum_Bytes;																	//总字节数
			//填有效波形发数据---------------------2021.8.20.150842

			RS485_TX_BUFF[7]= (BYTE)(((i_pstStGrpParam->wFLAG_RUN))>>8);
			RS485_TX_BUFF[8]= (BYTE)((i_pstStGrpParam->wFLAG_RUN));
			RS485_TX_BUFF[9]= (BYTE)(((i_pstStGrpParam->wGRP_VEL))>>8);
			RS485_TX_BUFF[10]= (BYTE)((i_pstStGrpParam->wGRP_VEL));
			RS485_TX_BUFF[11]= (BYTE)(((WORD)(i_pstStGrpParam->iDIAM_UW))>>8);
			RS485_TX_BUFF[12]= (BYTE)((WORD)(i_pstStGrpParam->iDIAM_UW));
			RS485_TX_BUFF[13]= (BYTE)(((WORD)(i_pstStGrpParam->iDIAM_Pre_UW))>>8);
			RS485_TX_BUFF[14]= (BYTE)((WORD)(i_pstStGrpParam->iDIAM_Pre_UW));
			RS485_TX_BUFF[15]= (BYTE)(((WORD)(i_pstStGrpParam->iAI_IF))>>8);
			RS485_TX_BUFF[16]= (BYTE)((WORD)(i_pstStGrpParam->iAI_IF));
			RS485_TX_BUFF[17]= (BYTE)(((WORD)(i_pstStGrpParam->iAI_UW))>>8);
			RS485_TX_BUFF[18]= (BYTE)((WORD)(i_pstStGrpParam->iAI_UW));
			RS485_TX_BUFF[19]= (BYTE)(((WORD)(i_pstStGrpParam->iCur_Rad_Uw))>>8);
			RS485_TX_BUFF[20]= (BYTE)((WORD)(i_pstStGrpParam->iCur_Rad_Uw));
			RS485_TX_BUFF[21]= (BYTE)(((WORD)(i_pstStGrpParam->iAI_DIAMMEASURE_UW_CUR))>>8);
			RS485_TX_BUFF[22]= (BYTE)((WORD)(i_pstStGrpParam->iAI_DIAMMEASURE_UW_CUR));
			RS485_TX_BUFF[23]= (BYTE)((((DWORD)i_pstStGrpParam->dwEncode_value) & 0xFF000000)>>24);
			RS485_TX_BUFF[24]= (BYTE)((((DWORD)i_pstStGrpParam->dwEncode_value) & 0xFF0000)>>16);
			RS485_TX_BUFF[25]= (BYTE)((((DWORD)i_pstStGrpParam->dwEncode_value) & 0xFF00)>>8);
			RS485_TX_BUFF[26]= (BYTE)((((DWORD)i_pstStGrpParam->dwEncode_value) & 0xFF));
			RS485_TX_BUFF[27]= 0;
			RS485_TX_BUFF[28]= i_pstStGlobalParam->byCurrUsrLevel;
			RS485_TX_BUFF[29]= (BYTE)(((WORD)(i_pstStGrpParam->iCOMPANYID))>>8);
			RS485_TX_BUFF[30]= (BYTE)((WORD)(i_pstStGrpParam->iCOMPANYID));
			RS485_TX_BUFF[31]= (BYTE)(((i_pstStGrpParam->dwAxisALocation_Uw_U) & 0xFF000000)>>24);
			RS485_TX_BUFF[32]= (BYTE)(((i_pstStGrpParam->dwAxisALocation_Uw_U) & 0xFF0000)>>16);
			RS485_TX_BUFF[33]= (BYTE)(((i_pstStGrpParam->dwAxisALocation_Uw_U) & 0xFF00)>>8);
			RS485_TX_BUFF[34]= (BYTE)(((i_pstStGrpParam->dwAxisALocation_Uw_U) & 0xFF));
			RS485_TX_BUFF[35]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_U) & 0xFF000000)>>24);
			RS485_TX_BUFF[36]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_U) & 0xFF0000)>>16);
			RS485_TX_BUFF[37]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_U) & 0xFF00)>>8);
			RS485_TX_BUFF[38]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_U) & 0xFF));
			RS485_TX_BUFF[39]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_Uw_D) & 0xFF000000)>>24);
			RS485_TX_BUFF[40]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_Uw_D) & 0xFF0000)>>16);
			RS485_TX_BUFF[41]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_Uw_D) & 0xFF00)>>8);
			RS485_TX_BUFF[42]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_Uw_D) & 0xFF));
			RS485_TX_BUFF[43]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_D) & 0xFF000000)>>24);
			RS485_TX_BUFF[44]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_D) & 0xFF0000)>>16);
			RS485_TX_BUFF[45]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_D) & 0xFF00)>>8);
			RS485_TX_BUFF[46]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_Uw_D) & 0xFF));
			RS485_TX_BUFF[47]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_U) & 0xFF000000)>>24);
			RS485_TX_BUFF[48]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_U) & 0xFF0000)>>16);
			RS485_TX_BUFF[49]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_U) & 0xFF00)>>8);
			RS485_TX_BUFF[50]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_U) & 0xFF));
			RS485_TX_BUFF[51]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_U) & 0xFF000000)>>24);
			RS485_TX_BUFF[52]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_U) & 0xFF0000)>>16);
			RS485_TX_BUFF[53]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_U) & 0xFF00)>>8);
			RS485_TX_BUFF[54]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_U) & 0xFF));
			RS485_TX_BUFF[55]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_D) & 0xFF000000)>>24);
			RS485_TX_BUFF[56]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_D) & 0xFF0000)>>16);
			RS485_TX_BUFF[57]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_D) & 0xFF00)>>8);
			RS485_TX_BUFF[58]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisALocation_MinDia_Uw_D) & 0xFF));
			RS485_TX_BUFF[59]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_D) & 0xFF000000)>>24);
			RS485_TX_BUFF[60]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_D) & 0xFF0000)>>16);
			RS485_TX_BUFF[61]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_D) & 0xFF00)>>8);
			RS485_TX_BUFF[62]= (BYTE)((((DWORD)i_pstStGrpParam->dwAxisBLocation_MinDia_Uw_D) & 0xFF));
			RS485_TX_BUFF[63]= 0;
			RS485_TX_BUFF[64]= i_pstStGlobalParam->byLanguageId;//2025.2.8.100100|增加语言类型

			//2024.04.14.194738  屏蔽|上面重新处理
//			for(iN=0;iN<140;iN++)
//			{
//				RS485_TX_BUFF[67+iN]=0;
//			}
			stSt485_Format.wCRC= CRC_Compute( RS485_TX_BUFF, 0, 207 );
			RS485_TX_BUFF[207] = (BYTE)(stSt485_Format.wCRC >> 8) & 0xFF;
			RS485_TX_BUFF[208] = (BYTE)(stSt485_Format.wCRC) & 0xFF;
			stSt485_Format.byNum_Bytes= 209;
			stSt485_Format.byReadNum_Bytes= 4;
			break;
		}
		break;
	}
	//打开接收使能
	//取出循环队列的第一个值填入DR寄存器-触发发送完成中断，进入到中断发送中。
	RS485_TX_EN(1);																																			//切换485硬件使能为发送		在此处切换485硬件使能-清除485接收完成标志
	for(iN=0;iN<150;iN++)																																		//清空485接收响应队列
	{
		RS485_RX_BUFF[iN]=0xFA;
	}
	__HAL_TIM_ENABLE(&htim2);				    //使能定时器2
}

//2024.02.01.172124
void ks_getmodbuscommdata( void *pdata,  char data_lenth, unsigned char *commdata,unsigned char reverse)
{
	unsigned char commdatatmp[4]={0};//最大支持4个字节
	unsigned char (*a)[4];//定义指向数组的指针
	int i;
	//数据合法
	if(pdata !=0 && (data_lenth==2 || data_lenth==4) && commdata !=0)
	{
		if (data_lenth==2)
		{
			if(reverse)//颠倒
			{
				for(i=0;i<2;i++)
					commdatatmp[i]=((unsigned char*)pdata)[1-i];
			}
			else//不颠倒
			{
				for(i=0;i<2;i++)
					commdatatmp[i]=((unsigned char*)pdata)[i];
			}
		}
		else
		{
			if(reverse)//颠倒
			{
				for(i=0;i<4;i++)
					commdatatmp[i]=((unsigned char*)pdata)[3-i];
			}
			else//不颠倒
			{
				for(i=0;i<4;i++)
					commdatatmp[i]=((unsigned char*)pdata)[i];
			}

		}

		a = (unsigned char(*)[4])commdata;

		for (i=0;i<data_lenth;i++)
			(*a)[i]=commdatatmp[i];//输出
	}
}

