/*
 * StRingNet.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */
#include "stdafx.h"
#include "type_def.h"
#include "gt_rtn_def.h"
#include "StRingNet.h"
#include "PCIOperate.h"
#include "StFileOp.h"
#include "bin_upgrade.h"
#include "string.h"


#define  SIZE_BAR5 (1<<18)
#define  RN_FIFO_ADDR_SIZE		    0xF               //FiFo size
extern StRingNet* G_pRingNet;
//
//void memset(void* des,const uint8 data, int32 size )
//{
//	while(size)
//	{
//		size--;
//		((uint8*)des)[size] = data;
//	}
//}

void Sleep(uint32 ms)
{
	return;
}


int16 RingNetCreate(StRingNet* pRingNet, uint16 SyncCycle, int16 enable_pc_sync_cycle, int32 mutli_process_enable)
{
	int16 rtn;
	memset(&pRingNet->m_pci, 0, sizeof(pRingNet->m_pci));


 	pRingNet->m_rx_pdu_err_cnt	= 0;
	pRingNet->m_rx_mail_err_cnt	= 0;

	pRingNet->m_rx_packet.pHead	= &pRingNet->m_rx_head;

	pRingNet->m_pdu_resp_time  = GT_CMD_NORMAL_WAIT_CNT;

	pRingNet->m_mail_pc_resp_time  = MAIL_WAIT_TIME;
	pRingNet->m_mail_fpga_resp_time = MAIL_FPGA_WIAT_TIME;//

	pRingNet->m_dsp_all_pdu_try_time = ALL_GT_CMD_TYP_TIME_MAX;//
	pRingNet->m_dsp_single_pdu_try_time = SINGLE_GT_CMD_TYP_TIME_MAX;
	pRingNet->m_mail_fpga_try_time = MAIL_FPGA_WIAT_TIME_TRY_MAX;

	pRingNet->mail_rx_ctrl.all = 0;
	pRingNet->mail_tx_ctrl.all = 0;
	pRingNet->pdu_tx_ctrl.all = 0;
	pRingNet->pdu_rx_ctrl.all = 0;


	rtn = PCComRamCreate(&(pRingNet->m_ram));
	if (rtn) return rtn;
	rtn = PCComRamMalloc(&(pRingNet->m_ram), PC_RAM_SIZE);
	if (rtn) return rtn;
	////////////////////////
	pRingNet->m_Thread_sleep_time = THREAD_NORMAL_SLEEP;
	rtn = SampleCreate(&pRingNet->m_sample);
	if (rtn)
		return rtn;

	pRingNet->m_update_en = 0;
	/////////////////////////////////
	Set_Iap_Flag(STAT_RUN);
	return RTN_SUCCESS;
}

int16 RingNetSetDataBaseAddr(StRingNet* pRingNet, uint32 pAddr, void *hGexFile, void* handle)
{
	int16 rtn = 0;
	pRingNet->m_pci.baseAddr = pAddr + ADDR_GLINKII_BYTE_BASE;
	rtn = SampleSetDataBaseAddr(&pRingNet->m_sample, pAddr + ADDR_KESAI_USER_DSP, pRingNet->m_pci.handle);
	return rtn;
}

//////////////////////////////////////////////////////////////////////////
int16 RingNetGetLoaclCNS(StRingNet* pRingNet, COMMON_NET_STATUS* pCNS)
{
	int16 rtn = 0;
	PciReadData16(pRingNet->m_pci, ADDR_RN_CNS_ONLINE_MSG, &pCNS->	m_online_msg.all);
	return rtn;
};
////////////////////////////////////////
int16 RingNetRequsetMailBus(StRingNet* pRingNet)
{
	const int32 CHECK_TIME = 2;
	int32 i = 0;
	pRingNet->mail_tx_ctrl.all = 0;
	for(i=0; i < CHECK_TIME ;i++)
	{
		PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_STATUS, &pRingNet->mail_tx_status.all);
		if(pRingNet->mail_tx_status.bit.mail_over) break;
		Sleep(1);
	}
	if(i == 2 || pRingNet->mail_tx_status.bit.overflow || pRingNet->mail_tx_status.bit.underflow)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("Last MailOp Tx Err or Last MailOp is'not finish. Err \n")));
		pRingNet->mail_tx_ctrl.bit.clr = 1;

	//	pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_TX_CTRL] = pRingNet->mail_tx_ctrl.all;
		PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_CTRL, pRingNet->mail_tx_ctrl.all);
		pRingNet->mail_tx_ctrl.bit.clr = 0;
	}

	pRingNet->mail_tx_ctrl.bit.mail_req = 1;
//	pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_TX_CTRL] = pRingNet->mail_tx_ctrl.all;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_CTRL, pRingNet->mail_tx_ctrl.all);
//	pRingNet->mail_tx_ctrl.bit.mail_req = 0;
	for(i=0; i < 2*CHECK_TIME ;i++)
	{
		//pRingNet->mail_tx_status.all = pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_TX_STATUS];
		PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_STATUS, &pRingNet->mail_tx_status.all);
		if(pRingNet->mail_tx_status.bit.mail_ready) break;
		Sleep(1);
	}
	if(i == 2*CHECK_TIME)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RequsetMailBus Err\n")));
		return RTN_REQUSET_MAIL_BUS_OVERTIME;
	}
	return RTN_SUCCESS;
}

int16 RingNetTxMail(StRingNet* pRingNet, RN_PACKET* pData)
{
	int32 n;
	uint16* pBuffer;
	int32 i;

	int16 rtn = RingNetRequsetMailBus(pRingNet);
	if(rtn) return rtn;

	/////////////wr data////////////////
// 	pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_TX_BUFFER_BASE] = pData->pHead->all.data0;
// 	pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_TX_BUFFER_BASE] = pData->pHead->all.data1;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_BUFFER_BASE + RN_FIFO_ADDR_SIZE -1, pData->pHead->all.data0);
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_BUFFER_BASE + RN_FIFO_ADDR_SIZE, pData->pHead->all.data1);
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_BUFFER_BASE + 2, pData->pHead->all.data2);
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_BUFFER_BASE + 3, pData->pHead->all.data3);

	n = (pData->length-4+1)>>1;
	pBuffer = (uint16*)pData->pData;

	for (i = 0; i < n; i++)
	{
		//pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_TX_BUFFER_BASE] = pBuffer[i];
		PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_BUFFER_BASE + (i & 0x7), pBuffer[i]);
	}

	pRingNet->mail_tx_ctrl.all = 0;
	pRingNet->mail_tx_ctrl.bit.data_valid = 1;
	//pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_TX_CTRL] = pRingNet->mail_tx_ctrl.all;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_CTRL, pRingNet->mail_tx_ctrl.all);
	pRingNet->mail_tx_ctrl.bit.data_valid = 0;

	return RTN_SUCCESS;
}
int16 RingNetRxMail(StRingNet* pRingNet, RN_PACKET* pData)
{
	int32 n;
	uint16* pBuffer;
	int32 i;
	//pRingNet->mail_rx_status.all = pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_RX_STATUS];
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_STATUS, &pRingNet->mail_rx_status.all);
	if(pRingNet->mail_rx_status.bit.rx_mail_valid == 0) return RTN_NO_MAIL_DATA ;// return -1;

	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_BUFFER_BASE + RN_FIFO_ADDR_SIZE - 1, &pData->pHead->all.data0);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_BUFFER_BASE + RN_FIFO_ADDR_SIZE, &pData->pHead->all.data1);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_BUFFER_BASE + 2, &pData->pHead->all.data2);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_BUFFER_BASE + 3, &pData->pHead->all.data3);

	////////////////////////////
	pData->length = (pData->pHead->bit.len_bit8<<8) | pData->pHead->bit.len_low;

	n = (pData->length-4+1)>>1;
	pBuffer = (uint16*)pData->pData;

	for (i = 0; i < n; i++)
	{
		//pBuffer[i] = pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_RX_BUFFER_BASE];
		PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_BUFFER_BASE + (i & 0x7), &pBuffer[i]);
	}

	///////////////////////////////////

	if(pData->pHead->bit.cmd>=4)
	{
		if (pData->pHead->bit.resp == 1)
		{
			pData->packet_type = RN_PACKET_MAIL_RD_RESP;
		}
		else
		{
			pData->packet_type = RN_PACKET_MAIL_RD_ASK;
		}
	}
	else
	{
		if (pData->pHead->bit.resp == 1)
		{
			pData->packet_type = RN_PACKET_MAIL_WR_RESP;
		}
		else
		{
			pData->packet_type = RN_PACKET_MAIL_WR_ASK;
		}
	}
	return RTN_SUCCESS;
}

int16 RingNetTxPDU(StRingNet* pRingNet, RN_PACKET* pData)
{
	uint16 n;
	uint16* pBuffer;
	//pRingNet->pdu_tx_status.all = pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_TX_STATUS];
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_STATUS, &pRingNet->pdu_tx_status.all );
	if(pRingNet->pdu_tx_status.bit.overflow || pRingNet->pdu_tx_status.bit.underflow)
	{
		pRingNet->pdu_tx_ctrl.bit.clr = 1;
		//pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_TX_CTRL] = pRingNet->pdu_tx_ctrl.all;
		PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_CTRL, pRingNet->pdu_tx_ctrl.all);
		pRingNet->pdu_tx_ctrl.bit.clr = 0;
	}

	///////////////wr data//////////////////////////////////////
// 	pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_TX_BUFFER_BASE] = pData->pHead->all.data0;
// 	pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_TX_BUFFER_BASE] = pData->pHead->all.data1;
// 	PciWriteData(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_BUFFER_BASE, pData->pHead->all.data0);
// 	PciWriteData(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_BUFFER_BASE,pData->pHead->all.data1 );

	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_BUFFER_BASE + RN_FIFO_ADDR_SIZE -1, pData->pHead->all.data0);
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_BUFFER_BASE + RN_FIFO_ADDR_SIZE, pData->pHead->all.data1);
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_BUFFER_BASE + 2, pData->pHead->all.data2);
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_BUFFER_BASE + 3, pData->pHead->all.data3);

	n = (pData->length-4+1)>>1;

	pBuffer = (uint16*)pData->pData;
	for (int32 i = 0; i < n; i++)
	{
		//pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_TX_BUFFER_BASE] = pBuffer[i];
		PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_BUFFER_BASE + (i & 0x7), pBuffer[i]);
	}


//	pRingNet->pdu_tx_status.all = pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_TX_STATUS];
	pRingNet->pdu_tx_ctrl.bit.data_valid = 1;
	//pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_TX_CTRL] = pRingNet->pdu_tx_ctrl.all;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_CTRL,  pRingNet->pdu_tx_ctrl.all);
	pRingNet->pdu_tx_ctrl.bit.data_valid = 0;
	return RTN_SUCCESS;
}
int16 RingNetRxPDU(StRingNet* pRingNet, RN_PACKET* pData)
{
	int32 n;
	uint16* pBuffer;
	int32 i;
	REG_RN_PDU_RX_CTRL rx_ctrl;

	//pRingNet->pdu_rx_status.all = pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_RX_STATUS];
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_STATUS, &pRingNet->pdu_rx_status.all );
	if(pRingNet->pdu_rx_status.bit.packet_cnt == 0)
		return RTN_NO_PDU_DATA;

	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_BUFFER_BASE + RN_FIFO_ADDR_SIZE - 1, &pData->pHead->all.data0);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_BUFFER_BASE + RN_FIFO_ADDR_SIZE, &pData->pHead->all.data1);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_BUFFER_BASE + 2, &pData->pHead->all.data2);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_BUFFER_BASE + 3, &pData->pHead->all.data3);

	pData->length = (pData->pHead->bit.len_bit8<<8) | pData->pHead->bit.len_low;


	n = (pData->length-4+1)>>1;

	pBuffer = (uint16*)pData->pData;
	for (i = 0; i < n; i++)
	{
		//pBuffer[i] = pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_RX_BUFFER_BASE];
		PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_BUFFER_BASE + (i & 0x7), &pBuffer[i]);
	}
	//////////////////////////////////////////////////////////////////////////
	rx_ctrl.all = 0;
	rx_ctrl.bit.clr = 1;
	//pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_PDU_RX_STATUS] = rx_ctrl.all;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_STATUS, rx_ctrl.all);
	//////////////////////////////////////////////////////////////////////////
	return RTN_SUCCESS;// (pRingNet->pdu_rx_status.bit.packet_cnt-1);
}


int16 RingNetSetNormalWrPacket(RN_PACKET* packet, uint8 des_id, uint16 start_addr, uint16 byte_num, uint16 des_ch, uint8 resp_req)
{
	RN_PACKET_HEAD* head = packet->pHead;
	//////////////////////////////////
	uint16 dword_num = (byte_num+3)>>2;
	packet->length = (dword_num<<2) + 4;

	packet->packet_type = RN_PACKET_MAIL_WR_ASK;
	head->bit.cmd = RN_AWR;
	head->bit.delta = 1;
	head->bit.des_ch = (uint8)des_ch;
	head->bit.id.des_id = des_id;
	head->bit.len_low = (uint8)packet->length;
	head->bit.len_bit8 = packet->length>>8;

	head->bit.num_bit8 = byte_num>>8;
	head->bit.num_low = (uint8)byte_num;
	head->bit.resp_req = resp_req;
	head->bit.resp = 0;
	head->bit.start_addr = start_addr;
	/////////////////////////////////////
	return RTN_SUCCESS;
}
//int16 RingNetSetNormalRdPacket(RN_PACKET* packet, uint8 des_id, uint16 start_addr, uint16 byte_num, uint16 des_ch)
//{
//	RN_PACKET_HEAD* head = packet->pHead;
//	////////////////////////////////
//	uint16 dword_num = (byte_num+3)>>2;
//	packet->length = 4;

//	packet->packet_type = RN_PACKET_MAIL_RD_ASK;
//	head->bit.cmd = RN_ARD;
//	head->bit.delta = 1;
//	head->bit.des_ch = (uint8)des_ch;
//	head->bit.id.des_id = des_id;
//	head->bit.len_low = 4;
//	head->bit.len_bit8 = 0;

//	head->bit.num_bit8 = byte_num>>8;
//	head->bit.num_low = (uint8)byte_num;
//	head->bit.resp_req = 1;
//	head->bit.resp = 0;
//	head->bit.start_addr = start_addr;

//	/////////////////////////////////////
//	return RTN_SUCCESS;
//}

/////////////////////////////////

int16 RN_TxMail(StRingNet* pRingNet, RN_PACKET* pData)
{
	int16 rtn = RingNetTxMail(pRingNet, pData);
	return rtn;
}
int16 RN_RxMail(StRingNet* pRingNet, RN_PACKET* pData)
{
	int16 rtn = RingNetRxMail(pRingNet, pData);
	REG_RN_MAIL_RX_CTRL mail_rx_ctrl;
	mail_rx_ctrl.all = 0;
	mail_rx_ctrl.bit.clr = 1;
	//pRingNet->PCI_BASE_ADDR[ADDR_RN_COM_MAIL_RX_CTRL] = mail_rx_ctrl.all;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_CTRL, mail_rx_ctrl.all);
	return rtn;
}

int16 RN_TxPDU(StRingNet* pRingNet, RN_PACKET* pData)
{
	int16 rtn = RingNetTxPDU(pRingNet, pData);
	return rtn;
}
int16 RN_RxPDU(StRingNet* pRingNet, RN_PACKET* pData)
{
	int16 rtn = RingNetRxPDU(pRingNet, pData);
	return rtn;
}

int16 RN_MailRespReq(StRingNet* pRingNet, RN_PACKET* pPacket)
{
#define		RN_LWR		0x0
#define		RN_AWR		0x1
#define		RN_LMWR		0x2
#define		RN_TCWR		0x3
#define		RN_LRD		0x4
#define		RN_ARD		0x5
#define		RN_LMRD		0x6
#define		RN_TCRD		0x7

	int16 rtn = 0;
	uint16 dword_num;
	uint16 i;
	uint16 byte_num;
	if(pPacket == NULL) return RTN_NULL_POINT;
	switch(pPacket->pHead->bit.cmd)
	{

//////////////RN_ARD////////////////////////////////////////////////////////////
	case RN_ARD:
		{
			pPacket->pHead->bit.des_ch		= pPacket->pHead->bit.src_ch;
			pPacket->pHead->bit.id.des_id		= pPacket->pHead->bit.id.src_id;
			pPacket->pHead->bit.resp_req	= 1;
			pPacket->pHead->bit.resp		= 1;
			//pPacket->length = (pPacket->pHead->bit.num_bit8<<8) | (pPacket->pHead->bit.num_low) + 4;
			pPacket->length = ((pPacket->pHead->bit.num_bit8<<8) | (pPacket->pHead->bit.num_low)) + 4;//2025.9.20.132239 优化警告，增加括号
			pPacket->pHead->bit.len_bit8 = (pPacket->length)>>8;
			pPacket->pHead->bit.len_low = (uint8)(pPacket->length);

			rtn = PCComRamRd(&(pRingNet->m_ram), pPacket->pData, pPacket->pHead->bit.start_addr, pPacket->length-4);
			pPacket->pHead->bit.resp_ok = rtn >= 0;
			rtn = RN_TxMail(pRingNet, pPacket);
			return rtn;

//			break;
		}
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
	case RN_LRD:
		{
			break;
		}
		//////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////////////////////////////
	case RN_LMRD :
		{
			break;
		}
		//////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////////////////////////////
	case RN_TCRD:
		{
			//////////////////////////////////////////////////////////////////////////
			//printf("Test Mailbox Resp err!\n");
			//////////////////////////////////////////////////////////////////////////
			pPacket->pHead->bit.des_ch		= pPacket->pHead->bit.src_ch;
			pPacket->pHead->bit.id.des_id		= pPacket->pHead->bit.id.src_id;
			pPacket->pHead->bit.resp_req	= 1;
			pPacket->pHead->bit.resp		= 1;
			//pPacket->length = (pPacket->pHead->bit.num_bit8<<8) | (pPacket->pHead->bit.num_low) + 4;
			pPacket->length = ((pPacket->pHead->bit.num_bit8<<8) | (pPacket->pHead->bit.num_low)) + 4;//2025.9.20.132239 优化警告，增加括号
			pPacket->pHead->bit.len_bit8 = (pPacket->length)>>8;
			pPacket->pHead->bit.len_low = (uint8)(pPacket->length);
			dword_num = (pPacket->length - 4)>>2;
			if ( (uint32)pPacket->pHead->bit.start_addr +  dword_num >= (SIZE_BAR5>>2) || dword_num > 120)
			{
				RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("(uint32)pPacket->pHead->bit.start_addr +  dword_num >= (SIZE_BAR5>>2) || dword_num > 120  ERR ! \n")));
				pPacket->pHead->bit.resp_ok = 0;
				return RN_TxMail(pRingNet, pPacket);
			}

			for (i = 0; i < dword_num; i++)
			{
				//((uint32*)pPacket->pData)[i] = pRingNet->PCI_BASE_ADDR[pPacket->pHead->bit.start_addr+i];
				PciReadData(pRingNet->m_pci, pPacket->pHead->bit.start_addr+i , ((uint32*)&(pPacket->pData)[i]));
			}

			pPacket->pHead->bit.resp_ok = 1;
			return RN_TxMail(pRingNet, pPacket);
//			break;
		}
//-------------------------------------------------------------------------
////////////////////////wr req//////////////////////////////////////////////////
	case RN_AWR:
		{
			byte_num = (pPacket->pHead->bit.num_bit8<<8) | (pPacket->pHead->bit.num_low);//
			rtn = PCComRamWr(&(pRingNet->m_ram), pPacket->pData, pPacket->pHead->bit.start_addr, byte_num);//pPacket->length-4);
			if(pRingNet->m_update_en)//
			{
				rtn = Upgrade_Handle(pRingNet->m_ram.m_pData,&byte_num);
			}

			if(pPacket->pHead->bit.resp_req == 1)
			{
				pPacket->pHead->bit.des_ch		= pPacket->pHead->bit.src_ch;
				pPacket->pHead->bit.id.des_id		= pPacket->pHead->bit.id.src_id;
				pPacket->pHead->bit.resp_req	= 1;
				pPacket->pHead->bit.resp		= 1;
				pPacket->length = 4;
				pPacket->pHead->bit.len_bit8 = (pPacket->length)>>8;
				pPacket->pHead->bit.len_low = (uint8)(pPacket->length);

				pPacket->pHead->bit.resp_ok = rtn >= 0;

				rtn = RN_TxMail(pRingNet, pPacket);
				return rtn;
			}
			return rtn;
//			break;
		}
		//////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////////////////////////////
	case RN_LWR:
		{

			break;
		}
		//////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////////////////////////////
	case RN_LMWR :
		{
			//  [8/24/2016 googol]
			pPacket->pHead->bit.resp_ok = 1;
			byte_num = (pPacket->pHead->bit.num_bit8<<8) | (pPacket->pHead->bit.num_low);//(pPacket->length - 4);
			if (byte_num > 480)
			{
				pPacket->pHead->bit.resp_ok = 0;
			}
			else
			{
				uint8 pData[480];
				uint16 byte_num_out;
				memcpy(pData, pPacket->pData,byte_num);
				rtn = StFnProcess(pRingNet, byte_num, pData, &byte_num_out);
				if (rtn != RTN_SUCCESS || byte_num_out > 480)
				{
					pPacket->pHead->bit.resp_ok = 0;
				}
				if (pPacket->pHead->bit.resp_ok == 1 && pPacket->pHead->bit.resp_req)
				{
					uint16 dword_num = (byte_num_out+3)>>2;
					byte_num = dword_num<<2;
					pPacket->pHead->bit.des_ch		= pPacket->pHead->bit.src_ch;
					pPacket->pHead->bit.id.des_id	= pPacket->pHead->bit.id.src_id;
					pPacket->pHead->bit.resp_req	= 1;
					pPacket->pHead->bit.resp		= 1;
					pPacket->pHead->bit.num_bit8 = byte_num>>8;
					pPacket->pHead->bit.num_low = (uint8)byte_num;
					pPacket->length = byte_num + 4;
					pPacket->pHead->bit.len_bit8 = (pPacket->length)>>8;
					pPacket->pHead->bit.len_low = (uint8)(pPacket->length);
					memcpy(pPacket->pData, pData,byte_num);
					return RN_TxMail(pRingNet, pPacket);
				}
			}
			//////////////////////////////////////////////////////////////////////////
			return RTN_SUCCESS;

// 			if ( (uint32)pPacket->pHead->bit.start_addr +  dword_num >= (SIZE_BAR5>>2) || dword_num > 120)
// 			{
// 				RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("(uint32)pPacket->pHead->bit.start_addr +  dword_num >= (SIZE_BAR5>>2) || dword_num > 120  ERR ! \n")));
// 				pPacket->pHead->bit.resp_ok = 0;
// 			}
//
// 			for (uint16 i = 0; i < dword_num; i++)
// 			{
// 				pRingNet->PCI_BASE_ADDR[pPacket->pHead->bit.start_addr+i] = ((uint32*)pPacket->pData)[i];
// 			}
//
// 			if(pPacket->pHead->bit.resp_req == 1)
// 			{
// 				pPacket->pHead->bit.des_ch		= pPacket->pHead->bit.src_ch;
// 				pPacket->pHead->bit.id.des_id	= pPacket->pHead->bit.id.src_id;
// 				pPacket->pHead->bit.resp_req	= 1;
// 				pPacket->pHead->bit.resp		= 1;
// 				pPacket->length = 4;
// 				pPacket->pHead->bit.len_bit8 = (pPacket->length)>>8;
// 				pPacket->pHead->bit.len_low = (pPacket->length);
//
// 				return RN_TxMail(pRingNet, pPacket);
// 			}
// 			return RTN_SUCCESS;

			//  [8/24/2016 googol]
//			break;
		}
		//////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////////////////////////////
	case RN_TCWR:
		{
			uint16 dword_num;
			uint16 i;
			//printf("Test Mailbox Resp err!\n");
			pPacket->pHead->bit.resp_ok = 1;

			dword_num = (pPacket->length - 4)>>2;
			if ( (uint32)pPacket->pHead->bit.start_addr +  dword_num >= (SIZE_BAR5>>2) || dword_num > 120)
			{
				RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("(uint32)pPacket->pHead->bit.start_addr +  dword_num >= (SIZE_BAR5>>2) || dword_num > 120  ERR ! \n")));
				pPacket->pHead->bit.resp_ok = 0;
			}

			for (i = 0; i < dword_num; i++)
			{
				//pRingNet->PCI_BASE_ADDR[pPacket->pHead->bit.start_addr+i] = ((uint32*)pPacket->pData)[i];
				PciWriteData(pRingNet->m_pci, pPacket->pHead->bit.start_addr+i,  ((uint32*)pPacket->pData)[i]);
			}

			if(pPacket->pHead->bit.resp_req == 1)
			{
				pPacket->pHead->bit.des_ch		= pPacket->pHead->bit.src_ch;
				pPacket->pHead->bit.id.des_id	= pPacket->pHead->bit.id.src_id;
				pPacket->pHead->bit.resp_req	= 1;
				pPacket->pHead->bit.resp		= 1;
				pPacket->length = 4;
				pPacket->pHead->bit.len_bit8 = (pPacket->length)>>8;
				pPacket->pHead->bit.len_low = (uint8)(pPacket->length);

				return RN_TxMail(pRingNet, pPacket);
			}
			return RTN_SUCCESS;

//			break;
		}
	}
	return RTN_MAIL_RESP_REQ_ERR;
}
int16 RN_PduRespReq(StRingNet* pRingNet, RN_PACKET* pPacket)
{
	if(pPacket == NULL)
	{
		pRingNet->m_rx_pdu_err_cnt++;
		return RTN_NULL_POINT;
	}
	if(pPacket->pHead->bit.cmd == RN_AWR)
	{
		if(pPacket->pHead->bit.src_ch == RN_PCI_CH_ID)
		{
			int16 rtn = PCComRamWr(&(pRingNet->m_ram), pPacket->pData, pPacket->pHead->bit.start_addr, pPacket->length-4);
			pRingNet->m_rx_pdu_err_cnt = rtn < 0 ? pRingNet->m_rx_pdu_err_cnt + 1 : pRingNet->m_rx_pdu_err_cnt;
			return rtn;
		}
	}
	pRingNet->m_rx_pdu_err_cnt++;
	return RTN_INSTRCTION_ERR;
}

int16 RN_MailOp(StRingNet* pRingNet, RN_PACKET* pData, int32 fast_en)
{
	int16 rtn = 0;
	if (fast_en)
	{
		pData->pHead->bit.des_ch = pData->pHead->bit.des_ch | 0x4;//switch to pdu acess
		rtn = RN_PduOp(pRingNet, pData, FALSE);
		return rtn;
	}
	return RTN_IMPOSSIBLE_ERR;
}

int16 RN_PduOp(StRingNet* pRingNet, RN_PACKET* pData, int32 index_check_enable)
{
	const int32 MAX_RETYR = 1;
	int32 i;
	int16 rtn;
	RN_PACKET rx_packet;
	RN_PACKET_HEAD rx_packet_head;
	RN_PACKET* packet;
	uint16 t_sys_start = 0, t_sys_now = 0;
//	int32 tTickStart=0;
	uint32 tTickDelta = 0;//ms
	uint16 t_sys_delta = 0;//us
	uint32 check;


	if(pData->pHead->bit.resp == 0 && pData->pHead->bit.num_bit8 == 0 && pData->pHead->bit.num_low == 0)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_PduOp req data num can't be 0. Err !\n")));
		return RTN_NET_REQ_DATA_NUM_ZERO;
	}
	///////////////////////////edited by huang.lz in 2018/3/27 fulsh last err///////////////////////////////////////////////

	rx_packet.pHead = &rx_packet_head;

	packet = &rx_packet;//(pRingNet->m_rx_packet);

	for ( i = 0; i < 100; i++)
	{
		rtn = RN_RxPDU(pRingNet, packet);
		if(rtn == RTN_SUCCESS)
		{
			if(packet->pHead->bit.resp_req == 1 && packet->pHead->bit.resp == 1) //resp packet
			{
				//////////////////////resp err//////////////////begin
				//////////////////////resp err//////////////////end
			}
			else
			{
				RN_PduRespReq(pRingNet, packet);
			}
		}
		else
		{
			break;
		}
	}

	//////////////////////////////////////////////////////////////////////////
	for (i = 0; i<MAX_RETYR; i++)
	{
		rtn = RN_TxPDU(pRingNet, pData);
		if(rtn == 0) break;
	}
	//////////////////////////////////////////////////////////////////////////
	if ( (pData->pHead->bit.resp_req == 0 && pData->pHead->bit.cmd == RN_AWR) || rtn < 0)
	{
		return rtn;
	}
	/////////wait resp//////////////////
	PciReadData16(pRingNet->m_pci, ADDR_RN_SYS_TIME, &t_sys_start);

	check = 1000000 >pRingNet->m_pdu_resp_time ? 1000000 : pRingNet->m_pdu_resp_time;
	for(check = 10000000;  check > 0; check--)
	{
//////////////////////////////check whether overtime ////////////////////////////////////////////
		PciReadData16(pRingNet->m_pci, ADDR_RN_SYS_TIME, &t_sys_now);
		t_sys_delta =(uint16) (t_sys_now - t_sys_start);

#ifdef _DEBUG_SIM_EN_
		if (tTickDelta > 3)
		{
			check = check > 2 ? 2 : check;
		}
#endif
		if((0x3 & pData->pHead->bit.des_ch) == RN_FPGA_CH_ID)
		{
			if (tTickDelta > 100 || t_sys_delta > 500)
			{
				check = check > 2 ? 2 : check;
			}
		}
		else if(pRingNet->m_pdu_resp_time < GT_CMD_NORMAL_WAIT_CNT)
		{
			if (tTickDelta > 2000 || t_sys_delta > 4000)
			{
				check = check > 2 ? 2 : check;
			}
		}
		else if(tTickDelta >= pRingNet->m_pdu_resp_time)
		{
			check = check > 2 ? 2 : check;
		}
//////////////////////////////////////////////////////////////////////////
		rtn = RN_RxPDU(pRingNet, packet);
		if(rtn == RTN_SUCCESS)
		{
			if(packet->pHead->bit.resp_req == 1 && packet->pHead->bit.resp == 1) //resp packet
			{
				//////////////////////resp err//////////////////begin
				if (  ( pData->pHead->bit.des_ch != rx_packet.pHead->bit.src_ch ) || //ch not match
					  (  pData->pHead->bit.id.des_id != 0xFF && rx_packet.pHead->bit.id.src_id != 0xFF && pData->pHead->bit.id.des_id != rx_packet.pHead->bit.id.src_id ) ||  // station not match
					  (  ( (0x3 & pData->pHead->bit.des_ch) == RN_FPGA_CH_ID ) && ( pData->pHead->bit.start_addr != rx_packet.pHead->bit.start_addr )  )  || //des addr not match
					  ( index_check_enable &&  (pData->pHead->bit.start_addr&0xFF) != (rx_packet.pHead->bit.start_addr&0xFF) ) // used the start address low byte to check retry. for other dsp_ch
					)
				{
					continue;
				}
				//////////////////////resp err//////////////////end

				pData->length = rx_packet.length;
//				pData->pHead->all = rx_packet.pHead->all;
				pData->pHead->all.data0 = rx_packet.pHead->all.data0;
				pData->pHead->all.data1 = rx_packet.pHead->all.data1;
				if(pData->length > 4)
				{
					uint16 byte_num = rx_packet.pHead->bit.num_low | (rx_packet.pHead->bit.num_bit8 <<8);
					memcpy(pData->pData, rx_packet.pData, byte_num);
				}

// 				if(is_acess_dsp_normal_pdu)
// 				{
// 					SingleDspPduCalcTryNum(pRingNet,  (uint16)(pRingNet->m_pdu_resp_time), (uint16)(1 + check / pRingNet->m_pdu_resp_time));
// 				}
				return RTN_SUCCESS;
			}
			else
			{
				RN_PduRespReq(pRingNet, packet);
			}
			continue;
		}
	}
	return RTN_WAIT_NET_PDU_RESP_OVERTIME;
}

// int16 RN_MailRdSingleReg(StRingNet* pRingNet, uint16 addr, uint16* data, uint8 des_id, uint8 des_ch, int32 fast_en)
// {
// 	int16 rtn = 0;
//
// 	RN_PACKET packet;
// 	RN_PACKET_HEAD head;
// 	packet.length = 4;
//
// 	packet.packet_type = RN_PACKET_MAIL_RD_ASK;
// 	head.bit.cmd = RN_ARD;
// 	head.bit.delta = 1;
// 	head.bit.des_ch = des_ch;
// 	head.bit.id.des_id = des_id;
// 	head.bit.len_low = packet.length;
// 	head.bit.len_bit8 = packet.length>>8;
// 	head.bit.num_bit8 = 0;
// 	head.bit.num_low = 2;
// 	head.bit.resp_req = 1;
// 	head.bit.resp = 0;
// 	head.bit.start_addr = addr;
// 	head.bit.resp_ok = 0;
//
// 	packet.pHead = &head;
// 	rtn = RN_MailOp(pRingNet, &packet, fast_en);
// 	if(rtn < 0 )
// 	{
// 		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RD Net Reg Message Err ! \n")));
// 	}
// 	if(packet.pData)
// 	{
// 		*data = *((uint16*)(packet.pData));
// 	}
// 	return rtn;
// }
// int16 RN_MailWrSingleReg(StRingNet* pRingNet, uint16 addr, uint16* data, uint8 des_id, uint8 des_ch, uint8 resp_req, int32 fast_en)
// {
// 	int16 rtn = 0;
//
// 	RN_PACKET packet;
// 	RN_PACKET_HEAD head;
// 	packet.length = 4+4;
//
// 	packet.packet_type = RN_PACKET_MAIL_WR_ASK;
// 	head.bit.cmd = RN_AWR;
// 	head.bit.delta = 1;
// 	head.bit.des_ch = des_ch;
// 	head.bit.id.des_id = des_id;
// 	head.bit.len_low = packet.length;
// 	head.bit.len_bit8 = packet.length>>8;
// 	head.bit.num_bit8 = 0;
// 	head.bit.num_low = 2;
// 	head.bit.resp_req = resp_req;
// 	head.bit.resp = 0;
// 	head.bit.start_addr = addr;
// 	head.bit.resp_ok = 0;
//
// 	packet.pHead = &head;
//
// 	*(uint16*)(packet.pData) = *data;
// 	rtn = RN_MailOp(pRingNet, &packet, fast_en);
// 	if(rtn < 0 )
// 	{
// 		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("Wr Net Reg Message Err ! \n")));
// 	}
// 	return rtn;
// }


/////////////////dsp cmd///////
//////////////////////////////////////////////////////////////////////////
int16 RN_SampleSetLocalShowDeviceId(StRingNet* pRingNet, uint8 device_id)
{
	//触发粗采样中断@原因未知，临时处理办法,在这里先读一下
	REG_NET_INT_MSG status;
	PciReadData16(pRingNet->m_sample.m_pci, ADDR_RN_INT_STATUS, &status.all);
	PciReadData(pRingNet->m_sample.m_pci, ADDR_SAMPLE_STATUS, &pRingNet->m_sample.m_sample_pc_ctrl.all);
//	if (device_id == pRingNet->m_CNS.m_online_msg.bit.device_id) //local data select
	{
		pRingNet->m_sample.m_sample_pc_ctrl.bit.ehmi_en_mask = 0;
		pRingNet->m_sample.m_sample_pc_ctrl.bit.round_remote_rd_en_mask  =0;
		pRingNet->m_sample.m_sample_pc_ctrl.bit.round_wr_src = SAMPLE_ROUND_INNER;
		pRingNet->m_sample.m_sample_pc_ctrl.bit.round_wr_src_mask = 1;

		PciWriteData(pRingNet->m_sample.m_pci, ADDR_SAMPLE_STATUS, pRingNet->m_sample.m_sample_pc_ctrl.all);
		pRingNet->m_sample.m_sample_pc_ctrl.bit.round_wr_src_mask = 0;
	}
	//////////////////////////////////////////////////////////////////////////
	return RTN_SUCCESS;
}

int16 RN_DevicePcMailComWr(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num, uint8 cmd_type, uint8 resp_req)
{
	RN_PACKET packet;
	RN_PACKET_HEAD head;
	uint16 byte_num;
	int16 rtn = 0;

	if (pData == NULL) return RTN_NULL_POINT;



	byte_num = dword_num<<2;
	if (byte_num > 480)
	{
		return RTN_PARAM_OVERFLOW;
	}

	if(cmd_type != RN_LWR && cmd_type != RN_AWR && cmd_type != RN_LMWR && cmd_type != RN_TCWR)
	{
		return RTN_PARAM_ERR;
	}

	if (pData == NULL)
	{
		return RTN_NULL_POINT;
	}
	packet.length = byte_num + 4;

	packet.packet_type = RN_PACKET_MAIL_WR_ASK;
	head.bit.cmd = cmd_type;
	head.bit.delta = 1;
	head.bit.des_ch = RN_PCI_CH_ID;
	head.bit.id.des_id = des_id;
	head.bit.len_low = packet.length;
	head.bit.len_bit8 = packet.length>>8;

	head.bit.num_bit8 = byte_num>>8;
	head.bit.num_low = byte_num;
	head.bit.resp_req = resp_req;
	head.bit.resp = 0;
	head.bit.start_addr = start_addr;

	packet.pHead = &head;

	memcpy((void*)(packet.pData), (void*)(pData), byte_num);

	rtn = RN_MailOp(pRingNet, &packet, 1);
	return rtn;
}

////////////////////////////////////////

int16 RN_DevicePcMailComRd(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num, uint8 cmd_type)
{
	RN_PACKET packet;
	RN_PACKET_HEAD head;

	uint16 byte_num;
	int16 rtn = 0;
	byte_num = dword_num<<2;
	if (byte_num > 480)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_DevicePcMailComRd : dword_num  > 120  ERR ! \n")));
		return RTN_PARAM_OVERFLOW;
	}

	if(cmd_type != RN_LRD && cmd_type != RN_ARD && cmd_type != RN_LMRD && cmd_type != RN_TCRD)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_DevicePcMailComRd : cmd_type  ERR ! \n")));
		return RTN_PARAM_ERR;
	}

	if (pData == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_DevicePcMailComRd : input pdata == NULL  ERR ! \n")));
		return RTN_NULL_POINT;
	}

	packet.length = 4;
	packet.packet_type = RN_PACKET_MAIL_RD_ASK;

	head.bit.cmd = cmd_type;
	head.bit.delta = 1;
	head.bit.des_ch = RN_PCI_CH_ID;
	head.bit.id.des_id = des_id;
	head.bit.len_low = packet.length;
	head.bit.len_bit8 = packet.length>>8;

	head.bit.num_bit8 = byte_num>>8;
	head.bit.num_low = byte_num;
	head.bit.resp_req = 1;
	head.bit.resp = 0;
	head.bit.start_addr = start_addr;

	packet.pHead = &head;

	rtn = RN_MailOp(pRingNet, &packet, 1);
	if(rtn)
		return rtn;

///////////////////////////////////////
	memcpy((void*)(pData), (void*)(packet.pData), byte_num);
	return rtn;
}
///////////////////////////////////////////////////////////
int16 RN_DeviceLocalPcRamWr(StRingNet* pRingNet, uint32* pData, uint16 start_addr, uint16 dword_num)
{
	if(pData == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_DeviceLocalPcRamWr Err! pData == NULL ! \n")));
		return RTN_NULL_POINT;
	}
	if(pRingNet->m_update_en)
	{
		return RTN_SUCCESS;
	}
	return PCComRamWr(&(pRingNet->m_ram), (uint8*)pData, start_addr, dword_num<<2);
}
int16 RN_DeviceLocalPcRamRd(StRingNet* pRingNet, uint32* pData, uint16 start_addr, uint16 dword_num)
{
	if(pData == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_DeviceLocalPcRamRd Err! pData == NULL ! \n")));
		return RTN_NULL_POINT;
	}
	return PCComRamRd(&(pRingNet->m_ram), (uint8*)pData, start_addr, dword_num<<2);
}

uint16 RingNetRxPacketThread(void* pParam)
{
	int16 rtn = 0;
	REG_NET_INT_MSG status;
	RN_PACKET* packet;
	StRingNet* pRignNet = (StRingNet*)G_pRingNet;
	if(G_pRingNet == NULL)
		return RTN_SUCCESS;
	packet = &(pRignNet->m_rx_packet);
	PciReadData16(pRignNet->m_sample.m_pci, ADDR_RN_INT_STATUS,(uint16*)&status.all);
	if (status.bit.mail_rx_valid == 0 && (status.bit.round_valid == 0 || pRignNet->m_sample.m_rx_packet_thread_status == 0))
	{
		return rtn;
	}
	else
	{
		if (status.bit.mail_rx_valid)
		{
			rtn = RN_RxMail(pRignNet, packet);
			if (rtn == RTN_SUCCESS)
			{
				if(packet->pHead->bit.resp_req == 1 && packet->pHead->bit.resp == 1)
				{
					//				RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RingNetRxPacketThread Rx Resp mail packet ! \n")));
				}
				else
				{
					RN_MailRespReq(pRignNet, packet);
					packet->pHead->all.data0 = 0xFFFF;
					packet->pHead->all.data1 = 0xFFFF;
					packet->pHead->all.data2 = 0xFFFF;
					packet->pHead->all.data3 = 0xFFFF;
				}
			}
		}
		if (status.bit.round_valid && pRignNet->m_sample.m_rx_packet_thread_status)
		{
			rtn = SampleRdRoundDataThread(&(pRignNet->m_sample));
		}
	}
	return RTN_SUCCESS;
}
