/*
 * StRingNet.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef STRINGNET_H_
#define STRINGNET_H_

#pragma once

#include "StDefRingNetReg.h"
#include "StDefRingNetAddr.h"
#include "StPCComRam.h"
#include "StSample.h"
#include "type_def.h"
#define RING_NET_DEVICE_ID_AUTO_ONLY 1
//////////////////////////////////
#define		RN_LWR		0x0//逻辑寻址写（必须为该值）
#define		RN_AWR		0x1//绝对寻址写
#define		RN_LMWR		0x2//逻辑地址映射区寻址写
#define		RN_TCWR		0x3//报文发送配置区寻址写
#define		RN_LRD			0x4//逻辑寻址读（必须为该值)
#define		RN_ARD		0x5//绝对寻址读
#define		RN_LMRD		0x6//逻辑地址映射区寻址读
#define		RN_TCRD		0x7//报文发送配置区寻址读

//------------------------------------------------------------------------------
#define		RN_USER_PROTOCOL_DRIVER		0x0000		//gtsd41 and gtsd61 uesd the protocol cmd
//0x10
#define		RN_USER_PROTOCOL_MOTION		0x00FF		// which kesai gtsd13 used
#define		RN_USER_PROTOCOL_DEBUG		0x0001
#define		RN_USER_PROTOCOL_PLOT		0x0002

#define		RN_USER_PROTOCOL_PC			0x0010

#define		RN_FPGA_CH_ID		(0)
#define		RN_PCI_CH_ID			(1)
#define		RN_DSP_CH_ID		(2)
#define		RN_DSPEX_CH_ID		(3)
#define		RN_EXT_CH_ID			RN_DSPEX_CH_ID

#define		RN_PACKET_MAIL_RD_ASK	0
#define		RN_PACKET_MAIL_WR_ASK	1

#define		RN_PACKET_MAIL_RD_RESP	2
#define		RN_PACKET_MAIL_WR_RESP	3

#define		RN_PACKET_PDU_RD_ASK		4
#define		RN_PACKET_PDU_WR_ASK		5

#define		RN_PACKET_PDU_RD_RESP		6
#define		RN_PACKET_PDU_WR_RESP		7

#define		RN_PACKET_RX_PDU_WR		RN_PACKET_PDU_RD_ASK
#define		RN_PACKET_TX_PDU_WR		RN_PACKET_PDU_WR_ASK
///////////////////////////
#define ILINK_UPDATA_NUM (30)

#define SYS_CLK 125
#define SYNC_CYCLE 250
#define SYNC_CNT (SYS_CLK*SYNC_CYCLE)
#define MAIL_WAIT_TIME 500//200
#define MAIL_FPGA_WIAT_TIME 8
//#define PC_RAM_SIZE (1<<13)
#define COM_RAM_USER_SIZE 32 /*32 bytes*/

#define DSP_BF607_PACKET_SIAE         96/*96 bytes*/

#define COM_RAM_ILINK_MAX 0xC00 /*1024*3 bytes*/
#define COM_RAM_USER_BASE 0xC00 /*bytes address*/

#define RN_LOCK_TIME_NOW	0
#define RN_LOCK_TIME_SYNC	1

#define  GT_CMD_NORMAL_WAIT_CNT 500 //微秒
#define ALL_GT_CMD_TYP_TIME_MAX 80
#define SINGLE_GT_CMD_TYP_TIME_MAX 100


#define MAIL_FPGA_WIAT_TIME_TRY_MAX 4
//////
#ifdef KESAI
#define RN_MULIT_WAIT_CNT_UP 20
#else
#define RN_MULIT_WAIT_CNT_UP 2000
#endif

#define RN_MULIT_WAIT_SLEEP 50

#define THREAD_NORMAL_SLEEP  3
#define THREAD_FILE_OP_FAST_SLEEP  1

#define DSP_STORE_STATION_MASTER 0 /*主栈*/
#define DSP_STORE_STATION_SECOND 1 /*f副主站*/
#define DSP_STORE_STATION_SLAVER  2 /*从站*/


typedef struct
{
	//////////////base//////////////
#ifdef _WIN32_WCE
	volatile uint32*				PCI_BASE_ADDR;
#endif
	StPci m_pci;
	COMMON_NET_STATUS		m_CNS;
	/////////////packet base///////////////////////
	REG_RN_MAIL_TX_CTRL		mail_tx_ctrl;
	REG_RN_MAIL_TX_STATUS	mail_tx_status;

	REG_RN_MAIL_RX_CTRL		mail_rx_ctrl;
	REG_RN_MAIL_RX_STATUS	mail_rx_status;

	REG_RN_PDU_TX_CTRL		pdu_tx_ctrl;
	REG_RN_PDU_TX_STATUS	pdu_tx_status;

	REG_RN_PDU_RX_CTRL		pdu_rx_ctrl;
	REG_RN_PDU_RX_STATUS	pdu_rx_status;
	/////////////////////////////////////////////
	RN_PACKET m_rx_packet;//this packet just used for mailbox
	RN_PACKET_HEAD m_rx_head;

	///////////////////////////////////////////
	uint32 m_rx_pdu_err_cnt;
	uint32 m_rx_mail_err_cnt;

	StPCComRam	m_ram;
	////////////////////////

	uint32 m_pdu_resp_time;
	uint16 m_mail_pc_resp_time;
	uint16 m_mail_fpga_resp_time;
	///////////////////////
	StSample m_sample;

	uint8 m_Thread_sleep_time;

	uint16 m_dsp_all_pdu_try_time;
	uint16 m_dsp_single_pdu_try_time;

	uint16 m_mail_fpga_try_time;

	int16		m_enable_pc_sync_cycle;

	uint8		m_inital_flag;
	//////////////////////////////////////////////////////////////////////////
	uint8 	m_update_en;
	//////////////////////////////////////////////////////////////////////////
}StRingNet;
//////////////////base//////////////////////////
int16 RingNetSetDataBaseAddr(StRingNet* pRingNet, uint32 pAddr, void* hGexFile, void* handle);
int16 RingNetEncodeSyncCycle(StRingNet* pRingNet, uint16 sync_cycle_us);
int16 RingNetDecodeSyncCycle(StRingNet* pRingNet, uint16 sync_cycle_set);

int16 RingNetCreate(StRingNet* pRingNet, uint16 SyncCycle, int16 enable_pc_sync_cyle, int32 mutli_process_enable);
//////////////////////////////////////////////////////////////////////////
int16 RingNetInitial(StRingNet* pRingNet);
/////////////////////////////////////////////////////////////////////////////////////////////
int16 RingNetRequsetMailBus(StRingNet* pRingNet);
int16 RingNetTxMail(StRingNet* pRingNet, RN_PACKET* pData);
int16 RingNetRxMail(StRingNet* pRingNet, RN_PACKET* pData);
int16 RingNetTxPDU(StRingNet* pRingNet, RN_PACKET* pData);
int16 RingNetRxPDU(StRingNet* pRingNet, RN_PACKET* pData);
//////////////////////////////////////////////
int16 RingNetSetNormalWrPacket(RN_PACKET* packet, uint8 des_id, uint16 start_addr, uint16 byte_num, uint16 des_ch, uint8 resp_req);
int16 RingNetSetNormalRdPacket(RN_PACKET* packet, uint8 des_id, uint16 start_addr, uint16 byte_num, uint16 des_ch);
/////////////////////////////////////////////////
int16 RN_TxMail(StRingNet* pRingNet, RN_PACKET* pData);
int16 RN_RxMail(StRingNet* pRingNet, RN_PACKET* pData);
int16 RN_TxPDU(StRingNet* pRingNet, RN_PACKET* pData);
int16 RN_RxPDU(StRingNet* pRingNet, RN_PACKET* pData);

int16 RN_MailRespReq(StRingNet* pRingNet, RN_PACKET* pPacket);
int16 RN_PduRespReq(StRingNet* pRingNet, RN_PACKET* pPacket);

int16 RN_MailOpWaitEven(StRingNet* pRingNet, RN_PACKET* pData);
int16 RN_MailOp(StRingNet* pRingNet, RN_PACKET* pData, int32 fast_en);
int16 RN_PduOp(StRingNet* pRingNet, RN_PACKET* pData, int32 index_check_enable);//when index check enable, check the start address return

int16 RN_MailRdSingleReg(StRingNet* pRingNet, uint16 addr, uint16* data, uint8 des_id, uint8 des_ch, int32 fast_en);
int16 RN_MailWrSingleReg(StRingNet* pRingNet, uint16 addr, uint16* data, uint8 des_id, uint8 des_ch, uint8 resp_req, int32 fast_en);

////##############################################
int16 RN_GetLocalInf(StRingNet* pRingNet, StRingInfPrivate* inf);
////////////////////////////////
int16 RN_DevicePcMailComWr(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num, uint8 cmd_type, uint8 resp_req);
int16 RN_DevicePcMailComRd(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num, uint8 cmd_type);
int16 RN_DeviceLocalPcRamWr(StRingNet* pRingNet, uint32* pData, uint16 start_addr, uint16 dword_num);
int16 RN_DeviceLocalPcRamRd(StRingNet* pRingNet, uint32* pData, uint16 start_addr, uint16 dword_num);
////////////////////////////////////
int16 RN_UserPCWrNetFPGA(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint8 src_id, uint16 start_addr, uint16 dword_num);
int16 RN_UserPCRdLocalFPGA(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num);

/////////////////sample cfg/////////////////////////////////////////////////////////
int16 RN_SampleSetLocalShowDeviceId(StRingNet* pRingNet, uint8 device_id);
/////////////////////////////////////
int16 RingNetRstMasterReg(StRingNet* pRingNet);
int16 RingNetRstSlaverReg(StRingNet* pRingNet);
//////--------------------------------------------------------------
uint16 RingNetRxPacketThread(void* pParam);
//////////////////////////////////////////////////////////////////////////
int16 RingNetMailRdMultReg(StRingNet* pRingNet, uint16 addr, uint16* data,uint16 data_num, uint8 data_mode, uint8 des_id, uint8 des_ch, int32 fast_en);
// int16 RingNetMailWrMultReg(StRingNet* pRingNet, uint16 addr, uint16* data, uint16 data_num, uint8 data_mode,uint8 des_id = 0, uint8 des_ch = RN_FPGA_CH_ID, uint8 resp_req = 1, int32 fast_en = 0);
int16 RingNetPCWatchCom(StRingNet* pRingNet, uint16* pData,uint16 word_num);

#endif /* STRINGNET_H_ */
