/*
 * RingNet.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifdef __LINUX
#include "linux_com.h"
#else
#include "stdafx.h"
#endif
#include "type_def.h"
#include "gt_rtn_def.h"
#include "gt_rn_struct_private.h"
#include "StRingNet.h"
#include "PCIOperate.h"
#include "StFileOp.h"
//#include "cmsis_gcc.h"

StRingNet G_RingNet;
StRingNet* G_pRingNet = &G_RingNet;
short aiCfgData_Read1[32]				;//				: ARRAY [1..30] OF INT := 30(0);
short g_aiCfgH;
short g_aiCfgL;

int16 GTD_Open(uint32 pAddr)
{
	int16 rtn;
	rtn = RingNetCreate(G_pRingNet, 250, TRUE, FALSE);
	rtn = RingNetSetDataBaseAddr(G_pRingNet, pAddr, NULL, NULL);
	rtn = RingNetInitial(G_pRingNet);
	return rtn;
}
//
//void memcpy(void* a,  const void* b, int16 num)
//{
//	for(num = num - 1; num >= 0; num--)
//	{
//		((char*)a)[num] = ((char*)b)[num];
//	}
//}
int16 GT_RN_GetVersion(char** msg)
{
	return RingNetGetVersion(msg);
}
int16 GT_RN_GetLocalID(unsigned char* id)
{
	/////////////////////////////////////////
	PciReadData16(G_pRingNet->m_pci, ADDR_RN_CNS_ONLINE_MSG, &G_pRingNet->m_CNS.m_online_msg.all);
	*id = G_pRingNet->m_CNS.m_online_msg.bit.device_id;
	return RTN_SUCCESS;
}
//////////////////////////////////////////////////////////////////////////
 int16 GT_RN_SampleInitialCfg(uint8* hmi_id, uint8 hmi_num)
{
	return RTN_SUCCESS;
}
 int16 GT_RN_SampleSetSampleParam(StSampleParam* param, int16* cfg_data)
{
	return SampleSetSampleParam(&G_pRingNet->m_sample, param, cfg_data);
}

 //刷新采样参数
 int16 GTD_SampleParamUpda(short axis, short *cfg_data)
 {
	 StPci pci;
	 int16 i;
	_ENTER_CRITICAL_SECTION(NULL);
	 pci.baseAddr = G_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_KESAI_SAMPLE_DSP_BASE;
	 for(i = 0; i < 11; i++) //reference th document "GTSD13 register discription document"
	 {
		 PciWriteData16(pci, i, cfg_data[i]);
	 }
	 PciWriteData16(pci, 11, (cfg_data[11] | 0x0500) );
	 PciWriteData16(pci, 12, (cfg_data[12]) );
	 PciWriteData16(pci, 13, (cfg_data[13]) );
	 PciWriteData16(pci, 11, (cfg_data[14]<<9 |0x0400) );

	_EXIT_CTRITCAL_SECTION(NULL);

	 for(i = 0; i < 14; i++) //reference th document "GTSD13 register discription document"
	 {
		 PciReadData16(pci, i, &aiCfgData_Read1[i]);
	 }
	 g_aiCfgH= aiCfgData_Read1[0];
	 g_aiCfgL= aiCfgData_Read1[1];

	return RTN_SUCCESS;
 }

int16 GT_RN_GetVirtualStatus(int16* pStatus)
{
	 StPci pci;
	 int16 i;
   pci.baseAddr = G_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_KESAI_SAMPLE_DSP_BASE;
	 for(i = 0; i < 4; i++) //reference th document "GTSD13 register discription document"
	 {
		 PciReadData16(pci, 0x8+i, &pStatus[i]);
	 }
	return RTN_SUCCESS;
}

// int16 GT_RN_SampleGetRoundData(void** ch_a,void** ch_b, int16* flag)
//{
//	*flag = G_pRingNet->m_sample.m_round_status;
//	*ch_a = G_pRingNet->m_sample.m_pRoundSampleBufferChA;
//	*ch_b = G_pRingNet->m_sample.m_pRoundSampleBufferChB;
//	return RTN_SUCCESS;
//}
//2025.7.22.104119|wei.n|
int16 GT_RN_SampleGetRoundData(void** ch_a, void** ch_b, void** ch_c,void** ch_d, void** ch_e,void** ch_f, int16* flag)
{
	*flag = G_pRingNet->m_sample.m_round_status;
	*ch_a = &G_pRingNet->m_sample.m_pRoundSampleBufferChA[1];//R
	*ch_b = &G_pRingNet->m_sample.m_pRoundSampleBufferChB[1];
	*ch_c = &G_pRingNet->m_sample.m_pRoundSampleBufferChA[2];//G
	*ch_d = &G_pRingNet->m_sample.m_pRoundSampleBufferChB[2];
	*ch_e = &G_pRingNet->m_sample.m_pRoundSampleBufferChA[0];//B@过圈位在B中,斌朝处理的时候把B作为索引[0]|陈周林fpga中索引0是R
	*ch_f = &G_pRingNet->m_sample.m_pRoundSampleBufferChB[0];
	return RTN_SUCCESS;
}
 int16 GT_RN_SampleRoundUpdata(void)
{
	G_pRingNet->m_sample.m_round_status = 0;
	G_pRingNet->m_sample.m_rx_packet_thread_status = 1;
	G_pRingNet->m_sample.m_status.m_round_rding = 1;
	G_pRingNet->m_sample.m_status.m_round_err = 0;
//	SysTaskResume(G_pRingNet->m_sample.m_rx_packet_handle);
	return RTN_SUCCESS;
}
 int16 GT_RN_SampleGetFineData(void* ch_a,void* ch_b,int16* flag)
{
	return SampleGetFineData(&G_pRingNet->m_sample, ch_a, ch_b, flag);
}
 int16 GT_RN_SampleGetStatus(StSampleStatus* status)
{
	return SampleGetStatus(&G_pRingNet->m_sample,status);
}
 int16 GT_RN_SampleSetLocalShowDeviceId(uint8 device_id)
{
	return RN_SampleSetLocalShowDeviceId(G_pRingNet, device_id);
}
 int16 GT_RN_SampleSetRemoteRdEnable(uint8 device_id, int32 enble)
{
	return RTN_SUCCESS;
}
////////////////////pc to pc com//////////////////////////////////////////////////////
 int16 GT_RN_DevicePcMailComWr(uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num, uint8 cmd_type, uint8 resp_req)
{
	return RN_DevicePcMailComWr(G_pRingNet, pData, des_id, start_addr, dword_num, cmd_type, resp_req);
}
 int16 GT_RN_DevicePcMailComRd(uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num, uint8 cmd_type)
{
	return RN_DevicePcMailComRd(G_pRingNet, pData, des_id, start_addr, dword_num, cmd_type);
}

 int16 GT_RN_DeviceLocalPcRamWr(uint32* pData, uint16 start_addr, uint16 dword_num)
{
	return RN_DeviceLocalPcRamWr(G_pRingNet, pData, start_addr, dword_num);
}
 int16 GT_RN_DeviceLocalPcRamRd(uint32* pData, uint16 start_addr, uint16 dword_num)
{
	return RN_DeviceLocalPcRamRd(G_pRingNet, pData, start_addr, dword_num);
}
 int16 GT_RN_UserPCWrNetFPGA(uint32* pData, uint8 des_id, uint8 src_id, uint16 start_addr, uint16 dword_num)
{
	return RN_UserPCWrNetFPGA(G_pRingNet, pData, des_id, src_id, start_addr, dword_num);
}

 int16 GT_RN_UserPCRdLocalFPGA(uint32* pData, uint8 des_id, uint16 start_addr, uint16 dword_num)
{
	return RN_UserPCRdLocalFPGA(G_pRingNet, pData, des_id, start_addr, dword_num);
}
//////////////////////////////////////////////////////////////////////////
 int16 GT_RN_MailRdMultReg(uint16 addr, uint16* data,uint16 data_num, uint8 data_mode, uint8 des_id)
 {
 	return RingNetMailRdMultReg(G_pRingNet, addr, data, data_num, data_mode, des_id, RN_FPGA_CH_ID, TRUE);
 }

 int16 GT_RN_PCWatchCom(uint16* pData,uint16 word_num)
 {
	 return RingNetPCWatchCom(G_pRingNet, pData, word_num);
 }

 int16 GT_RN_SetSenceDO(int16 gpo_set)
 {
	 StPci pci;
	 pci.baseAddr = G_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_COMMON_IO_BASE;
	 PciWriteData16(pci, 0x10, gpo_set);//reference th document "gtn_sub axi6 RingNet address define document"
	 return RTN_SUCCESS;
 }


int16 RingNetGeneralKesaiCmd(StRingNet* pRingNet, TPci* pTPci)
{
	int16 i;
	uint16 checksum = 0;
	for(i = 0; i < pTPci->len + 3; i++)
	{
		checksum += ((uint16*)pTPci)[i];
	}
	if(checksum != 0xFFFF)
	{
		pTPci->data[0] = CMD_ERROR_READ_CHECKSUM;
		pTPci->len = 1;
	}
	else
	{
		switch(pTPci->data[0])
		{
			case GEN_KESAI_UPDATE_ENALBE 	: //		0x100
			{
				if(pTPci->len < 2)
				{
					pTPci->data[0] = CMD_ERROR_READ_LEN;
					pTPci->len = 1;
				}
				else
				{
					pRingNet->m_update_en = pTPci->data[1];
					pTPci->len = 1;
					pTPci->data[0] = CMD_SUCCESS;
				}
				break;
			}
			case GEN_KESAI_SAMPLE_UPDATE 	: //0x102
			{
				if(pTPci->len < 1+15)
				{
					pTPci->data[0] = CMD_ERROR_READ_LEN;
					pTPci->len = 1;
				}
				else
				{
					pTPci->data[0] = GTD_SampleParamUpda(1, &(pTPci->data[1]));
					pTPci->len = 1;
				}
				break;
			}
			case GEN_KESAI_SET_SENCE_DO		:	//0x103
			{
				if(pTPci->len < 2)
				{
					pTPci->data[0] = CMD_ERROR_READ_LEN;
					pTPci->len = 1;
				}
				else
				{
					pTPci->data[0] = GT_RN_SetSenceDO(pTPci->data[1]);
					pTPci->len = 1;
				}
				break;
			}
      case GEN_KESAI_GET_VIRTUAL_STATUS : //0x104
			{
				if(pTPci->len < 1)
				{
					pTPci->data[0] = CMD_ERROR_READ_LEN;
					pTPci->len = 1;
				}
				else
				{
					pTPci->data[0] = GT_RN_GetVirtualStatus(&pTPci->data[1]);
					pTPci->len = 1+4;
				}
				break;
			}
			default :
			{
				pTPci->data[0] = CMD_ERROR_UNKNOWN;
				pTPci->len = 1;
				break;
			}
		}
	}
	pTPci->flag = 4;
	pTPci->checksum = 0;
	checksum = 0xFFFF;
	for(i = 0; i < pTPci->len+3; i++)
	{
		checksum -= ((uint16*)pTPci)[i];
	}
	pTPci->checksum = checksum;
	return RTN_SUCCESS;
}

int16 GT_RN_WriteFPGA(unsigned short byte_addr, unsigned short* pData)
{
    StPci pci;
	pci.baseAddr = G_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_APP_COMMON_BYTE_BASE;
    PciWriteData16(pci, byte_addr>>1, *pData);
    return RTN_SUCCESS;
}
int16 GT_RN_ReadFPGA(unsigned short byte_addr, unsigned short* pData)
{
    StPci pci;
	pci.baseAddr = G_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_APP_COMMON_BYTE_BASE;
    PciReadData16(pci, byte_addr>>1, pData);
    return RTN_SUCCESS;
}


//2025.6.11.083414 同步
//2024.12.07.100019 /wei.n/欧诺油墨盘升降功能
int16 GT_RN_SetPulseParam(unsigned short* pData)
{
	//unsigned short base_addr = 0x400;
	StPci pci;
	pci.baseAddr = G_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_COMMON_IO_BASE;
	for(int i = 0; i < 6; i++)
	{
			PciWriteData16(pci, i, pData[i]);
	}
	return RTN_SUCCESS;
}

int16 GT_RN_GetPulseParam(unsigned short* pData)
{
	//unsigned short base_addr = 0x400;
	StPci pci;
	pci.baseAddr = G_pRingNet->m_pci.baseAddr - ADDR_GLINKII_BYTE_BASE + ADDR_COMMON_IO_BASE;
	for(int i = 0; i < 6; i++)
	{
			PciReadData16(pci, i, &pData[i]);
	}
	return RTN_SUCCESS;
}
