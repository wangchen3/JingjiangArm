/*
 * StRingNetExta.c
 *
 *  Created on: Jul 31, 2024
 *      Author: 17500
 */

#ifndef __LINUX
#include "stdafx.h"
#endif

#include "StRingNet.h"
#include "gt_rtn_def.h"
#include "PCIOperate.h"
//////////////////////////////////////////////////////////////////////////
int16 RingNetInitialSlaver(StRingNet* pRingNet)
{
	int16 rtn = RingNetRstSlaverReg(pRingNet);
	if(rtn)
		return rtn;

	return RTN_SUCCESS;
}
//---------------------------------------///
int16 RingNetInitial(StRingNet* pRingNet)
{
	return RingNetInitialSlaver(pRingNet);
}
int16 RingNetRstSlaverReg(StRingNet* pRingNet)
{
	int16 rtn = 0;
	////////////set net work param///////////
	pRingNet->pdu_tx_ctrl.all = 0;
	pRingNet->pdu_tx_ctrl.bit.clr = 1;
	pRingNet->pdu_tx_ctrl.bit.model = 0;

	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_CTRL, pRingNet->pdu_tx_ctrl.all);
	pRingNet->pdu_tx_ctrl.bit.clr = 0;

	pRingNet->pdu_rx_ctrl.all = 0;
	pRingNet->pdu_rx_ctrl.bit.clr = 1;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_CTRL, pRingNet->pdu_rx_ctrl.all);
	pRingNet->pdu_rx_ctrl.bit.clr = 0;

	pRingNet->mail_tx_ctrl.all = 0;
	pRingNet->mail_tx_ctrl.bit.clr = 1;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_CTRL, pRingNet->mail_tx_ctrl.all);
	pRingNet->mail_tx_ctrl.bit.clr = 0;

	pRingNet->mail_rx_ctrl.all = 0;
	pRingNet->mail_rx_ctrl.bit.clr = 1;
	PciWriteData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_CTRL,  pRingNet->mail_rx_ctrl.all);
	pRingNet->mail_rx_ctrl.bit.clr = 0;
	////////////////////////////////////////////////////////////
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_TX_STATUS, &pRingNet->pdu_tx_status.all);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_PDU_RX_STATUS, &pRingNet->pdu_rx_status.all);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_TX_STATUS, &pRingNet->mail_tx_status.all);
	PciReadData16(pRingNet->m_pci, ADDR_RN_COM_MAIL_RX_STATUS,  &pRingNet->mail_rx_status.all);

	PciWriteData(pRingNet->m_sample.m_pci, ADDR_SAMPLE_CLR, 0x1);//clr buffer

	pRingNet->m_sample.m_sample_pc_ctrl.all = 0;
	pRingNet->m_sample.m_sample_pc_ctrl.bit.ehmi_en = 0;
	pRingNet->m_sample.m_sample_pc_ctrl.bit.ehmi_en_mask = 1;
	PciWriteData(pRingNet->m_sample.m_pci, ADDR_SAMPLE_STATUS, pRingNet->m_sample.m_sample_pc_ctrl.all);

	PciReadData(pRingNet->m_sample.m_pci, ADDR_SAMPLE_STATUS, &pRingNet->m_sample.m_sample_pc_ctrl.all);
	return rtn;
}

int16 RN_UserPCWrNetFPGA(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint8 src_id, uint16 start_addr, uint16 dword_num)
{
	RN_PACKET packet;
	RN_PACKET_HEAD head;

	uint16 byte_num;
	int16 i;
	byte_num = dword_num<<2;
	if (byte_num > COM_RAM_USER_SIZE)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCComFPGAPdu : dword_num  > USER_COM_SIZE  ERR ! \n")));
		return RTN_PARAM_ERR;
	}

	if (des_id >= MAX_STATION_NUM /*|| pRingNet->m_CNS.m_online_msg.bit.device_id == des_id*/)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCComFPGAPdu : des_id =< MAX_STATION_NUM \n")));
		return RTN_PARAM_ERR;
	}

	//2025.10.31.124124+ by liu.yt
	if (src_id >= MAX_STATION_NUM )
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCComFPGAPdu : src_id =< MAX_STATION_NUM \n")));
		return RTN_PARAM_ERR;
	}

	if ((start_addr&0x3) != 0x0 || (start_addr > (COM_RAM_USER_SIZE - 4)))
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCComFPGAPdu : start_addr  ERR ! \n")));
		return RTN_PARAM_ERR;
	}

	if (pData == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCComFPGAPdu : input pdata == NULL  ERR ! \n")));
		return RTN_NULL_POINT;
	}

	if (pRingNet->m_CNS.m_online_msg.bit.device_id >= MAX_STATION_NUM)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCComFPGAPdu : pRingNet->m_CNS.m_online_msg.bit.device_id >= MAX_STATION_NUM  ERR ! \n")));
		return RTN_PARAM_ERR;
	}


	packet.length = byte_num + 4;

	packet.packet_type = RN_PACKET_TX_PDU_WR;
	head.bit.cmd = RN_AWR;
	head.bit.delta = 1;
	head.bit.des_ch = RN_FPGA_CH_ID;
	head.bit.id.des_id = des_id;
	head.bit.len_low = packet.length;
	head.bit.len_bit8 = packet.length>>8;

	head.bit.num_bit8 = byte_num>>8;
	head.bit.num_low = byte_num;
	head.bit.resp_req = 0;
	head.bit.resp = 0;
	head.bit.start_addr = (ADDR_RN_NET_COM_RAM_BASE<<1) + COM_RAM_USER_BASE + COM_RAM_USER_SIZE*src_id/*pRingNet->m_CNS.m_online_msg.bit.device_id*/ + start_addr;

	packet.pHead = &head;

	memcpy((void*)(packet.pData), (void*)(pData), byte_num);

	for (i = 0; i < 2; i++)
	{
		RN_TxPDU(pRingNet, &packet);
	}
	return RTN_SUCCESS;
}

int16 RN_UserPCRdLocalFPGA(StRingNet* pRingNet, uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num)
{
	uint16 byte_num;
	int16 rtn = 0;
	int16 i;
	int32 offset;
	if (pData == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCRdLocalFPGA : input pdata == NULL  ERR ! \n")));
		return RTN_NULL_POINT;
	}

	if (des_id >= MAX_STATION_NUM)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCRdLocalFPGA : des_id >= MAX_STATION_NUM  ERR ! \n")));
		return RTN_PARAM_ERR;
	}
	//////////////////////////////////////////////////////////////////////////
	if (start_addr & 0x8000) ////special function
	{
 		if(start_addr == 0x8000)
		{
			PciReadData16(pRingNet->m_pci,  ADDR_RN_SYS_TIME, (uint16*)pData);
			return RTN_SUCCESS;
		}
		return RTN_SUCCESS;
	}
	//////////////////////////////////////////////////////////////////////////
	if ((start_addr&0x3) != 0x0 || (start_addr > (COM_RAM_USER_SIZE - 4)))
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCRdLocalFPGA : start_addr  ERR ! \n")));
		return RTN_PARAM_ERR;
	}

	byte_num = dword_num<<2;
	if (byte_num > COM_RAM_USER_SIZE)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RN_UserPCRdLocalFPGA : dword_num  > USER_COM_SIZE  ERR ! \n")));
		return RTN_PARAM_ERR;
	}

	//	uint32* PCI_BASE = (uint32*)((uint32)(pRingNet->PCI_BASE_ADDR) + (ADDR_RN_PC_COM_RAM_BASE<<2) + COM_RAM_USER_BASE + COM_RAM_USER_SIZE*pRingNet->m_CNS.m_online_msg.bit.device_id + start_addr);
	//uint32* PCI_BASE = (uint32*)((uint32)(pRingNet->PCI_BASE_ADDR) + (ADDR_RN_PC_COM_RAM_BASE<<2) + COM_RAM_USER_BASE + COM_RAM_USER_SIZE*des_id + start_addr);

	offset = (ADDR_COMMON_RAM_BASE - ADDR_GLINKII_BYTE_BASE + COM_RAM_USER_BASE + COM_RAM_USER_SIZE*des_id + start_addr) >> 2;
	//here is dword offset
	for (i = 0; i < dword_num; i++)
	{
		//pData[i] = PCI_BASE[i];
		PciReadData(pRingNet->m_pci,  (offset + i), &pData[i]);
		//pData[i] = pRingNet->PCI_BASE_ADDR[ADDR_RN_PC_COM_RAM_BASE+(COM_RAM_USER_BASE>>2)+(COM_RAM_USER_SIZE>>2)*pRingNet->m_CNS.m_online_msg.bit.device_id+i];
	}
	return rtn;
}


int16 RingNetPCWatchCom(StRingNet* pRingNet, uint16* pData,uint16 word_num)
{
	RN_PACKET packet;
	RN_PACKET_HEAD head;
	uint8 des_id;
	uint16 byte_num;
	int16 rtn;
	byte_num = word_num<<1;
	des_id = 0xf2;
//	if (des_id >= MAX_STATION_NUM /*|| pRingNet->m_CNS.m_online_msg.bit.device_id == des_id*/)
//	{
//		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RingNetMailRdMultReg : des_id =< MAX_STATION_NUM || local id ==  des_id ERR ! \n")));
//		return RTN_PARAM_ERR;
//	}

	if(byte_num > 480)
		return RTN_PARAM_OVERFLOW;

	if (pData == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RingNetMailRdMultReg : input pdata == NULL  ERR ! \n")));
		return RTN_NULL_POINT;
	}

//	if (pRingNet->m_CNS.m_online_msg.bit.device_id == des_id)
//	{
//		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RingNetMailRdMultReg : pRingNet->m_CNS.m_online_msg.bit.device_id == des_id  ERR ! \n")));
//		return RTN_PARAM_ERR;
//	}


	packet.length = 4 + byte_num;

	packet.packet_type = RN_PACKET_MAIL_RD_ASK;
	head.bit.cmd = RN_ARD;
	head.bit.delta = 1;
	head.bit.des_ch = RN_PCI_CH_ID;
	head.bit.id.des_id = des_id;
	head.bit.len_low = packet.length;
	head.bit.len_bit8 = packet.length>>8;

	head.bit.num_bit8 = byte_num>>8;
	head.bit.num_low = byte_num;
	head.bit.resp_req = 1;
	head.bit.resp = 0;
	head.bit.start_addr = RN_USER_PROTOCOL_PC;//0x8000;

	packet.pHead = &head;


	rtn = RN_MailOp(pRingNet, &packet, 1);
	if(rtn)
		return rtn;

	memcpy((void*)(pData), (void*)(packet.pData), byte_num);
	return RTN_SUCCESS;
}

int16 RingNetMailRdMultReg(StRingNet* pRingNet, uint16 addr, uint16* pData,uint16 word_num, uint8 data_mode, uint8 des_id, uint8 des_ch, int32 fast_en)
{
	RN_PACKET packet;
	RN_PACKET_HEAD head;

	uint16 byte_num;
	int16 rtn;
	byte_num = word_num<<1;

	if (des_id >= MAX_STATION_NUM /*|| pRingNet->m_CNS.m_online_msg.bit.device_id == des_id*/)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RingNetMailRdMultReg : des_id =< MAX_STATION_NUM || local id ==  des_id ERR ! \n")));
		return RTN_PARAM_ERR;
	}

	if (pData == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RingNetMailRdMultReg : input pdata == NULL  ERR ! \n")));
		return RTN_NULL_POINT;
	}

	if (pRingNet->m_CNS.m_online_msg.bit.device_id == des_id)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("RingNetMailRdMultReg : pRingNet->m_CNS.m_online_msg.bit.device_id == des_id  ERR ! \n")));
		return RTN_PARAM_ERR;
	}


	packet.length = 4;

	packet.packet_type = RN_PACKET_MAIL_RD_ASK;
	head.bit.cmd = RN_ARD;
	head.bit.delta = data_mode;
	head.bit.des_ch = RN_FPGA_CH_ID;
	head.bit.id.des_id = des_id;
	head.bit.len_low = packet.length;
	head.bit.len_bit8 = packet.length>>8;

	head.bit.num_bit8 = byte_num>>8;
	head.bit.num_low = byte_num;
	head.bit.resp_req = 1;
	head.bit.resp = 0;
	head.bit.start_addr = addr;

	packet.pHead = &head;


	rtn = RN_MailOp(pRingNet, &packet, fast_en);
	if(rtn)
		return rtn;

	memcpy((void*)(pData), (void*)(packet.pData), byte_num);
	return RTN_SUCCESS;
}
int16 RingNetVersion(StVersion* dllVersion)
{
	dllVersion->usDeviceMesg = 0x8031;
	dllVersion->usVersion = 0x0002;
	dllVersion->usYear = 0x2020;
	dllVersion->usMonthDay = 0x0521;
	dllVersion->usAddInfA = 0;
	dllVersion->usAddInfB = 0;
	return RTN_SUCCESS;
}

int16 RingNetGetVersion(char** msg)
{
	*msg = (char*)"GT_RN Version : GTN_20191108\r\n";
	return 0;
}
