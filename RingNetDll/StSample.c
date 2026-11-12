/*
 * StSample.c
 *
 *  Created on: Jul 31, 2024
 *      Author: 17500
 */

#ifdef __LINUX
#include "linux_com.h"
#else
#include "stdafx.h"
#endif
#include "gt_rtn_def.h"
#include "StSample.h"
#include "PCIOperate.h"
#define max(a, b)  (a > b ? a : b)
int16 SampleCreate(StSample* pSample)
{
	pSample->m_rx_packet_handle = 0;//NULL;
	pSample->m_rx_packet_thread_status = 0;
	//------------------initial thc cfg//
	pSample->myConfig.motorPulse		= 4194304;//262144; //4194304
	pSample->myConfig.printerN			= 87;
	pSample->myConfig.motorM			= 34;
	pSample->myConfig.rollorperimeter	= 0.5;
	pSample->myConfig.fineSampleDetaInter= 0;
	pSample->myConfig.precisionbit		= 5;//0;//5
	pSample->myConfig.periodA			= 0;
	pSample->myConfig.periodB		    = 0;
	pSample->myConfig.periodATimes		= 0;
	pSample->myConfig.fineStartOffset	= 0;
	pSample->myConfig.secondStartOffset	= 0;
	pSample->myConfig.systemPrecision	= 0.01;
	pSample->myConfig.maxRollorSpeed		= 600;
	pSample->myConfig.maxSampleRate		= 0;
	pSample->myConfig.fineSamplePoint	= 8000;
	pSample->myConfig.roundSamplePoint	= 4000;
	pSample->myConfig.roundSampleDataInterH= 0;
	pSample->myConfig.roundSampleDataInterL= 0;
	pSample->myConfig.virtualPanPoint	  = 1024;
	pSample->myConfig.virtualSampleDataInterH = 0;
	pSample->myConfig.virtualSampleDataInterL = 0;
	pSample->myConfig.posVirtualPan			= 0;
	pSample->myConfig.correspond_rollerspd	= 0;
	pSample->myConfig.correspond_motorspd	= 0;
	pSample->pulse_delta			= ((double)(pSample->myConfig.motorPulse)) * ((double)(pSample->myConfig.printerN))/((double)pSample->myConfig.motorM);

	pSample->m_round_cnt = 0;
	pSample->m_round_status = 0;
	/////
	pSample->m_status.m_fine_num = 0;
	pSample->m_status.m_fine_rd_err = 0;
	pSample->m_status.m_fine_buffer_vaild_num = 0;
	pSample->m_status.m_fine_ad_err = 0;
	pSample->m_status.m_fine_check_err = 0;
	pSample->m_status.m_fine_com_err = 0;
	pSample->m_status.m_fine_startbit_times = 0;
	pSample->m_status.m_fine_success = 0;
	pSample->m_status.m_fine_sum_err = 0;

	pSample->m_status.m_round_rding = 0;
	pSample->m_status.m_round_ok = 0;
	pSample->m_status.m_round_err = 0;

	pSample->m_fine_check_sum = 0xFFFC;

	pSample->m_fine_buffer_index = 0;
	pSample->m_fine_buffer_last = 0;
	//////////////////////////////////////////////////////////////////////////
	return RTN_SUCCESS;
}
int16 SampleDelete(StSample* pSample)
{
	return SampleRst(pSample) ;
}
int16 SampleRst(StSample* pSample)
{
	pSample->m_round_cnt = 0;
	pSample->m_round_status = 0;
	/////
	pSample->m_status.m_fine_num = 0;
	pSample->m_status.m_fine_rd_err = 0;
	pSample->m_status.m_fine_buffer_vaild_num = 0;
	pSample->m_status.m_fine_ad_err = 0;
	pSample->m_status.m_fine_check_err = 0;
	pSample->m_status.m_fine_com_err = 0;
	pSample->m_status.m_fine_startbit_times = 0;
	pSample->m_status.m_fine_success = 0;
	pSample->m_status.m_fine_sum_err = 0;

	pSample->m_status.m_round_rding = 0;
	pSample->m_status.m_round_ok = 0;
	pSample->m_status.m_round_err = 0;


	pSample->m_fine_check_sum = 0xFFFC;

	pSample->m_fine_buffer_index = 0;
	pSample->m_fine_buffer_last = 0;
	return RTN_SUCCESS;
};

int16 SampleSetSampleParam(StSample* pSample,StSampleParam* param, int16* cfg_data)
{
	int16 rtn = 0;
	if (param == NULL) return RTN_NULL_POINT;

	pSample->myConfig.motorPulse	= param->motorPulse;

	pSample->myConfig.printerN		= param->printerN;

	pSample->myConfig.motorM		= param->motorM;

	pSample->myConfig.rollorperimeter	= param->rollorperimeter;

	pSample->myConfig.precisionbit = param->precisionbit;

	pSample->myConfig.systemPrecision = param->systemPrecision;

	pSample->myConfig.maxRollorSpeed = param->maxRollorSpeed;

	pSample->myConfig.fineSamplePoint = param->fineSamplePoint;

// 	//////////////////////////////////////////////////////////////////////////
	if (pSample->myConfig.roundSamplePoint>MAX_ROUND_POINT)
	{
		return RTN_PARAM_OVERFLOW;
	}

	pSample->myConfig.virtualPanPoint = param->virtualPanPoint;

	//step2:calc param
	if(pSample->myConfig.printerN == 0 || pSample->myConfig.motorM == 0
		|| pSample->myConfig.roundSamplePoint == 0 || pSample->myConfig.virtualPanPoint == 0)
		return RTN_PARAM_ERR;

	pSample->myConfig.periodA = (int32)((pSample->myConfig.motorPulse)*((double)pSample->myConfig.printerN)/((double)pSample->myConfig.motorM)/(1<<pSample->myConfig.precisionbit));

	pSample->myConfig.periodB = (pSample->myConfig.motorPulse>>pSample->myConfig.precisionbit)*pSample->myConfig.printerN - pSample->myConfig.periodA*(pSample->myConfig.motorM-1);

	pSample->myConfig.periodATimes = pSample->myConfig.motorM - 1;

	pSample->myConfig.roundSampleDataInterH = pSample->myConfig.periodA/pSample->myConfig.roundSamplePoint;

	pSample->myConfig.roundSampleDataInterL = (int32)((((double)(max(pSample->myConfig.periodA,pSample->myConfig.periodB)+2)/(double)pSample->myConfig.roundSamplePoint) - pSample->myConfig.roundSampleDataInterH)*65536);

	pSample->myConfig.virtualSampleDataInterH = pSample->myConfig.periodA/pSample->myConfig.virtualPanPoint;

	pSample->myConfig.virtualSampleDataInterL = (int32)((((double)(max(pSample->myConfig.periodA,pSample->myConfig.periodB)+2)/(double)pSample->myConfig.virtualPanPoint) - pSample->myConfig.virtualSampleDataInterH)*65536);

	pSample->myConfig.fineSampleDetaInter = (int32)((pSample->myConfig.systemPrecision/1000.0*pSample->myConfig.motorPulse*pSample->myConfig.printerN)/(pSample->myConfig.rollorperimeter*pSample->myConfig.motorM*(1<<pSample->myConfig.precisionbit)));

	pSample->myConfig.maxSampleRate = (pSample->myConfig.maxRollorSpeed/60.0)/(pSample->myConfig.systemPrecision/1000.0);

	pSample->myConfig.correspond_rollerspd = (int32)(pSample->myConfig.maxRollorSpeed/pSample->myConfig.rollorperimeter);

	pSample->myConfig.correspond_motorspd = (int32)((double)pSample->myConfig.correspond_rollerspd *((double)(pSample->myConfig.printerN)/(double)(pSample->myConfig.motorM)));

	//step3:display the data

	//check fine sample delta
	if ((pSample->myConfig.fineSampleDetaInter<0)||(pSample->myConfig.fineSampleDetaInter>=64))
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("精采样触发脉冲间隔超限，请重新选择控制精度位数并重新配置 \n")));
//		MessageBox(_T("精采样触发脉冲间隔超限，请重新选择控制精度位数并重新配置"),_T("notice"),MB_OK);
		rtn = RTN_PARAM_ERR;
	}
	pSample->myConfig.fineStartOffset = param->fineStartOffset ;
	pSample->myConfig.fineStartOffset = pSample->myConfig.fineStartOffset>>pSample->myConfig.precisionbit;

	pSample->myConfig.secondStartOffset = param->secondStartOffset;
	pSample->myConfig.secondStartOffset = pSample->myConfig.secondStartOffset>>pSample->myConfig.precisionbit;

//	pSample->myConfig.ctl = ( ((param->ctl & 0x1)<<9) | ((param->ctl & 0x2) << (14-1) ) | (1<<10) );
	pSample->myConfig.ctl = ( ((param->ctl & 0x1)<<9) | ((param->ctl & 0x2) << (14-1) ) | (1<<10) | (param->ctl & 0x8000) ) | ((param->ctl & 0x4) << (12-2) );
	//param bit0: param_ready
	//param bit1: dirc_reverse
	//param bit2: trig_out_src
	//param bit15 : ad_model
//	pSample->myConfig.ctl = param->ctl;
//////////////////////////////////////////////////////////////////////////
	if(cfg_data == NULL)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("Err!!  ----- Input var Err! \n")));
		rtn = RTN_NULL_POINT;
		return rtn;
	}
	cfg_data[0] =(uint16) (pSample->myConfig.fineStartOffset);
	cfg_data[1] =(uint16) ( pSample->myConfig.fineStartOffset>>16);
	cfg_data[2] =(uint16) ( pSample->myConfig.periodA);
	cfg_data[3] =(uint16) ( pSample->myConfig.periodA>>16);
	cfg_data[4] =(uint16) ( pSample->myConfig.periodB);
	cfg_data[5] =(uint16) ( pSample->myConfig.periodB>>16);
	cfg_data[6] =(uint16) ( pSample->myConfig.roundSampleDataInterL);
	cfg_data[7] =(uint16) ( pSample->myConfig.roundSampleDataInterH);
	cfg_data[8] =(uint16) ( pSample->myConfig.virtualSampleDataInterL);
	cfg_data[9] =(uint16) ( pSample->myConfig.virtualSampleDataInterH);
	cfg_data[10] = (uint16) (pSample->myConfig.periodATimes);
	cfg_data[11] = (uint16) ((pSample->myConfig.fineSampleDetaInter) | (pSample->myConfig.ctl));
	cfg_data[12] = (uint16) (pSample->myConfig.fineSamplePoint>>1);
	cfg_data[13] = (uint16) (pSample->myConfig.secondStartOffset);
	cfg_data[14] = (uint16) (pSample->myConfig.ctl>>9);//start from bit 9
	cfg_data[15] = (uint16) (pSample->myConfig.precisionbit);
	return rtn;
}

//////////////////////////////////////////////////////////////////////////
int16 SampleSetDataBaseAddr(StSample* pSample, uint32 pAddr, void* handle)
{
	pSample->m_pci.baseAddr = pAddr;
	return RTN_SUCCESS;
};

int16 SampleGetRoundData(StSample* pSample)
{
	int32 i = 0;
//	int32 j = 0;
//	int32 k = 0;

	REG_SAMPLE_STATUS status;
	StRoundDataForm *pRoundData;
	int16 less_num;
	int16 max_rd_num;
	int16 rd_num;
	//status.all = pSample->PCI_BASE_ADDR[ADDR_SAMPLE_STATUS];
	PciReadData(pSample->m_pci, ADDR_SAMPLE_STATUS, &status.all);
	less_num = (int16) (pSample->myConfig.roundSamplePoint - (pSample->m_round_cnt>>1) + 1);//calc how many point needed to form a packet
	max_rd_num = less_num > READ_PCI_LIMIT ? READ_PCI_LIMIT :  less_num;//the max data can be rd
	rd_num = max_rd_num > status.bit.round_rd_cnt ? status.bit.round_rd_cnt : max_rd_num;// the real num need to rd
	for (i = 0; i < rd_num; i++)
	{
		//pSample->m_round_buffer[i] = pSample->PCI_BASE_ADDR[ADDR_SAMPLE_ROUND_BASE+i];
		PciReadData(pSample->m_pci, ADDR_SAMPLE_ROUND_BASE+i, (uint32*)&pSample->m_round_buffer[i]);
	}
	pRoundData = (StRoundDataForm *)pSample->m_round_buffer;
	for (i = 0; i < rd_num;i++)
	{
		const int16 MAX_ERR = 3;
		if (pRoundData[i].ad_dataa_low.bit.round_flag == 1)//find the start///
		{
			int16 delta = pSample->m_round_cnt - pSample->myConfig.roundSamplePoint;
			delta = delta < 0 ? -delta : delta;
			if (delta <= MAX_ERR)//if (pSample->m_round_cnt == pSample->myConfig.roundSamplePoint) //if the num is right then ok!//allow  one point err;
			{
				pSample->m_round_status = 2;
				pSample->m_status.m_round_ok++;
			}
			else //the packet is wrong , then need to read from beg
			{
				pSample->m_round_status = 3;
				pSample->m_status.m_round_err++;
				RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("m_round_err at ad_dataa_low : %d Err \n"), pSample->m_round_cnt));
			}
			pSample->m_round_cnt = 0;
		}
		if(pSample->m_round_cnt >= (pSample->myConfig.roundSamplePoint + MAX_ERR) ) //allow  one point err;
		{
			pSample->m_status.m_round_err++;
			RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("m_round_err at ad_dataa_low : %d Err \n"), pSample->m_round_cnt));
			pSample->m_round_cnt = 0;
		}
		if(pSample->m_round_cnt < MAX_ROUND_POINT)
		{
			pSample->m_pRoundSampleBufferChA[pSample->m_round_cnt] = pRoundData[i].ad_dataa_low.all;
			pSample->m_pRoundSampleBufferChB[pSample->m_round_cnt] = pRoundData[i].ad_datab_low.all;
		}
		else
		{
			pSample->m_pRoundSampleBufferChA[MAX_ROUND_POINT-1] = pRoundData[i].ad_dataa_low.all;
			pSample->m_pRoundSampleBufferChB[MAX_ROUND_POINT-1] = pRoundData[i].ad_datab_low.all;
		}
		pSample->m_round_cnt++;

		//////////////////////////////////////////////////////////////////////////
		if (pRoundData[i].ad_dataa_high.bit.round_flag == 1)
		{
			int16 delta = pSample->m_round_cnt - pSample->myConfig.roundSamplePoint;
			delta = delta < 0 ? -delta : delta;
			if (delta <= MAX_ERR)//if (pSample->m_round_cnt == pSample->myConfig.roundSamplePoint)//allow  one point err;
			{
				pSample->m_round_status = 2;
				pSample->m_status.m_round_ok++;
			}
			else //the packet is wrong , then need to read from beg
			{
				pSample->m_round_status = 3;
				pSample->m_status.m_round_err++;
				RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("m_round_err at ad_dataa_high : %d Err \n"), pSample->m_round_cnt));
			}
			pSample->m_round_cnt = 0;
		}

		if(pSample->m_round_cnt >= (pSample->myConfig.roundSamplePoint+MAX_ERR)) //allow  one point err;
		{
			pSample->m_status.m_round_err++;
			RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("m_round_err at ad_dataa_high : %d Err \n"), pSample->m_round_cnt));
			pSample->m_round_cnt = 0;
		}

		if(pSample->m_round_cnt < MAX_ROUND_POINT)
		{
			pSample->m_pRoundSampleBufferChA[pSample->m_round_cnt] = pRoundData[i].ad_dataa_high.all;
			pSample->m_pRoundSampleBufferChB[pSample->m_round_cnt] = pRoundData[i].ad_datab_high.all;
		}
		else
		{
			pSample->m_pRoundSampleBufferChA[MAX_ROUND_POINT-1] = pRoundData[i].ad_dataa_high.all;
			pSample->m_pRoundSampleBufferChB[MAX_ROUND_POINT-1] = pRoundData[i].ad_datab_high.all;
		}
		pSample->m_round_cnt++;
	}
	return RTN_SUCCESS;
}

int16 SampleGetFineSampleNum(StSample* pSample, int16* number)
{
	REG_SAMPLE_STATUS status;
	//status.all = pSample->PCI_BASE_ADDR[ADDR_SAMPLE_STATUS];
	PciReadData(pSample->m_pci, ADDR_SAMPLE_STATUS, &status.all);
	*number = status.bit.fine_cnt;

	pSample->m_status.m_fine_rd_err = status.bit.fine_rd_err;
	pSample->m_status.m_fine_num = status.bit.fine_cnt;
	return RTN_SUCCESS;
}

int16 SampleClearFineStatus(StSample* pSample)
{
	pSample->m_status.m_fine_rd_err = 0;
	pSample->m_status.m_fine_buffer_vaild_num = 0;
	pSample->m_status.m_fine_ad_err = 0;
	pSample->m_status.m_fine_check_err = 0;
	pSample->m_status.m_fine_com_err = 0;
	pSample->m_status.m_fine_sum_err = 0;

	pSample->m_fine_check_sum = 0xFFFC;
	return RTN_SUCCESS;
}

int16 SampleGetFineDataFromBuffer(StSample* pSample,uint16* ch_a,uint16* ch_b, int16* pStatus)
{
	uint16 i;
	StFineDataForm *pFineData;
	pFineData = (StFineDataForm *)pSample->m_fine_buffer;

	while (pSample->m_fine_buffer_index != pSample->m_fine_buffer_last)
	{
		i = pSample->m_fine_buffer_index;
// 		if (pFineData[i].ad_datab.bit.flag)
// 		{
// 			RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("Err! \n")));
// 		}
		if(pFineData[i].ad_dataa.bit.flag) // fine_sample_fist
		{
			SampleClearFineStatus(pSample);
			pSample->m_status.m_fine_startbit_times++;
		}

		pSample->m_status.m_fine_ad_err += pFineData[i].ad_dataa.bit.err;// fine_ad_error++;
		pSample->m_status.m_fine_com_err += pFineData[i].ad_datab.bit.err;//fine_com_error++;

		if (pSample->m_status.m_fine_buffer_vaild_num == pSample->myConfig.fineSamplePoint)//the num is up
		{
			if (pFineData[i].ad_datab.bit.flag && (pSample->m_fine_check_sum == (pFineData[i].ad_dataa.all & 0xFFFC)) ) //type :  check_sum
			{
				pSample->m_fine_buffer_index = (pSample->m_fine_buffer_index+1)%FINE_BUFFER_SIZE;
				pSample->m_status.m_fine_success++;
				*pStatus = 1;//success
				return RTN_SUCCESS;
			}
			else
			{
				pSample->m_fine_buffer_index = (pSample->m_fine_buffer_index+1)%FINE_BUFFER_SIZE;
			}
		}
		//2023.08.07.095646 同步黄工针对pSample->m_status.m_fine_buffer_vaild_num在某种情况下越界引起的死机问题的新增加分支@Liu.yt

		else if (pSample->m_status.m_fine_buffer_vaild_num > pSample->myConfig.fineSamplePoint || pSample->m_status.m_fine_buffer_vaild_num==-1)
		{
			pSample->m_status.m_fine_buffer_vaild_num=-1;//-1表示数据无效，必须重新找到第一个采样点才能重新统计，这里避免很小概率校验和正确，但是数据却不合法情况
			pSample->m_fine_buffer_index = (pSample->m_fine_buffer_index+1)%FINE_BUFFER_SIZE;
		}
		else
		{
			ch_a[pSample->m_status.m_fine_buffer_vaild_num] = pFineData[i].ad_dataa.all & 0xFFFC;
			ch_b[pSample->m_status.m_fine_buffer_vaild_num] = pFineData[i].ad_datab.all & 0xFFFC;

			pSample->m_fine_check_sum += ch_a[pSample->m_status.m_fine_buffer_vaild_num];
			pSample->m_fine_check_sum += ch_b[pSample->m_status.m_fine_buffer_vaild_num];

			pSample->m_status.m_fine_buffer_vaild_num++;
			pSample->m_fine_buffer_index = (pSample->m_fine_buffer_index+1)%FINE_BUFFER_SIZE;
		}
	}
	if (pSample->m_fine_buffer_index != pSample->m_fine_buffer_last)
	{
		RETAILMSG(_GOOGOLTECH_RING_NET_DEBUG_,(TEXT("Err!! pSample->m_fine_buffer_index != pSample->m_fine_buffer_last! \n")));
		*pStatus = -1;
		return RTN_SUCCESS;
	}
	*pStatus = 0;
	return RTN_SUCCESS;
}

int16 SampleGetFineData(StSample* pSample, void* ch_a,void* ch_b,int16* flag)
{
	int32 i = 0;
//	int32 j = 0;
//	int32 k = 0;
	int16 rtn = 0;
	int32 get_cnt = 0;
	int16 sts;
	REG_SAMPLE_STATUS status;
	uint16 rd_num;

	*flag = 0;
	if (ch_a == NULL || ch_b == NULL)
	{
		return RTN_NULL_POINT;
	}

	rtn = SampleGetFineDataFromBuffer(pSample, (uint16*) ch_a, (uint16*) ch_b,&sts);
	if (rtn) return rtn;

	if(sts == 1)
	{
		*flag = 1;
		return RTN_SUCCESS;
	}
	else if (sts == -1) return RTN_PACKET_ERR;

	//////////////////////////////////
	rd_num = READ_PCI_LIMIT;
	for (get_cnt = 0; get_cnt < 17; get_cnt++)
	{
		pSample->m_fine_buffer_index = 0;
		pSample->m_fine_buffer_last = 0;

		//status.all = pSample->PCI_BASE_ADDR[ADDR_SAMPLE_STATUS];
		PciReadData(pSample->m_pci, ADDR_SAMPLE_STATUS, &status.all);
		pSample->m_status.m_fine_rd_err = status.bit.fine_rd_err;
		pSample->m_status.m_fine_num = status.bit.fine_cnt;
		if ((rd_num < 50 && pSample->m_status.m_fine_num < 50) || (pSample->m_status.m_fine_num == 0)) //the fifo data is too few
		{
			break;
		}
		rd_num = pSample->m_status.m_fine_num > READ_PCI_LIMIT ? READ_PCI_LIMIT : pSample->m_status.m_fine_num;
		pSample->m_fine_buffer_last = rd_num;

		for (i = 0; i < rd_num; i++)
		{
			//pSample->m_fine_buffer[i] = pSample->PCI_BASE_ADDR[ADDR_SAMPLE_FINE_BASE+i];
			PciReadData(pSample->m_pci, ADDR_SAMPLE_FINE_BASE+i, (uint32*)&pSample->m_fine_buffer[i]);
		}

		SampleGetFineDataFromBuffer(pSample, (uint16*) ch_a, (uint16*) ch_b,&sts);
		if(sts == 1)
		{
			*flag = 1;
			return RTN_SUCCESS;
		}
		else if (sts == -1) return RTN_PACKET_ERR;
	}
	return rtn;
}

int16 SampleGetStatus(StSample* pSample, StSampleStatus* status)
{
	*status = pSample->m_status;
	return RTN_SUCCESS;
}

int16 SampleRdRoundDataThread(StSample* m_app)
{
	int32 rtn = 0;
	if(m_app->m_rx_packet_thread_status == 0)
	{
		return RTN_SUCCESS;
	}
	rtn = SampleGetRoundData(m_app);
	if(rtn >= 0)
	{
		if(m_app->m_round_status == 2)//find the result
		{
			m_app->m_round_status = 1;
			m_app->m_rx_packet_thread_status = 0;
			m_app->m_status.m_round_rding = 0;
		}
	}
	return RTN_SUCCESS;
}
