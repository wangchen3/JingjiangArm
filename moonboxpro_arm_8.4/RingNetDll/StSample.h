/*
 * StSample.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef STSAMPLE_H_
#define STSAMPLE_H_

#pragma once

#include "type_def.h"
#include "gt_rn_struct_private.h"

#define MAX_HMI_NUM 32

//优化粗采样实现的宏定义@2025.9.3.114307 by liu.yt
#define MAX_ROUND_CHANNEL 	3

//2025.7.22.103325|wei.n|添加
#define MAX_ROUND_DEVICE	1000
#define MAX_ROUND_POINT		4000
#define MAX_FINE_POINT		8000
//use for order sample data
#define	BUFFER_NUMBER				4095

//////////the max fine buffer
#define FINE_BUFFER_SIZE		512
//use for buffer full data
#define	BUFFER_FULL_NUMBER			8001

//for fine sample
#define FINE_SAMPLE_POINT			8000
#define	FINE_MAX_BUFFER_NUMBER		10*(8000)

//for fine sample
#define ROUND_SAMPLE_POINT			4000
#define	ROUND_MAX_BUFFER_NUMBER		10*(4000)

//for read pci limit

#define	READ_PCI_LIMIT				500
#define	CAN_READ_PCI_MAX			500
#define READ_PCI_TIMES				10

////-------------------This address is calc  by int32 in pc----------------------------------------------------
#define ADDR_SAMPLE_STATUS			0x0
#define ADDR_SAMPLE_CLR				0x1
#define ADDR_SAMPLE_MASK			0x2
#define ADDR_SAMPLE_VERSION			0x3
#define ADDR_SAMPLE_FINE_BASE		0x4
#define ADDR_SAMPLE_ROUND_BASE		0x0200

/////////////////////this addr is calc by int16 in net for sample
#define					ADDR_RN_SAMPLE_CFG					0x100
//-------------------------------------------------------------------

//  [7/1/2016 googol]
#define SAMPLE_ROUND_INNER		0
#define SAMPLE_ROUND_OUTSIED	1

////////////////REG_SAMPLE_STATUS////////////////////////////

typedef struct
{
	uint16				fine_cnt				: 10;
//	uint16				fine_rd_full			: 1;

	uint16				rvsd_bit10to12			: 3;

	uint16				ehmi_en_mask			: 1;
	uint16				ehmi_en					: 1;

	uint16				fine_rd_err				: 1;

	uint16				round_rd_cnt			: 11;
//	uint16				round_rd_full			: 1;

	uint16				round_remote_rd_en_mask	: 1;
	uint16				round_remote_rd_en		: 1;
	uint16				round_wr_src_mask		: 1;
	uint16				round_wr_src			: 1;

	uint16				round_rd_err			: 1;

}REG_SAMPLE_STATUS_BIT;

typedef union
{
	uint32 all;
	REG_SAMPLE_STATUS_BIT bit;
}REG_SAMPLE_STATUS;

////////////////REG_SAMPLE_MASK////////////////////////////
typedef struct
{
	uint32		wr_data_remote_mask			: 8;
	uint32		rvsd_bit8to31				: 24;
}REG_SAMPLE_MASK_BIT;

typedef union
{
	uint32 all;
	REG_SAMPLE_MASK_BIT bit;
}REG_SAMPLE_MASK;

////////////////NET_SAMPLE_CTRL/////////////////////
typedef struct
{
	//////////////////////////////////
	uint8				wr_data_remote_mask			: 8; //

	uint8				round_remote_rd_mask		: 1; //
	uint8				round_remote_rd_en			: 1; //

	uint8				round_wr_src_mask			: 1;
	uint8				round_wr_src				: 1;// 0 decide by inner, 1: by outside

	uint8				ehmi_en_mask				: 1;
	uint8				ehmi_en						: 1;

	uint8				rsvd_bit14to15				: 2;
}REG_NET_SAMPLE_CTRL_BIT;

typedef union
{
	uint16 all;
	REG_NET_SAMPLE_CTRL_BIT bit;

}REG_NET_SAMPLE_CTRL;

//////ROUND_DATA_FORM//////////////////
typedef struct
{
	uint8 round_flag		: 1;
	uint8 ad_data			: 7;
}ROUND_DATA_BIT;

typedef union
{
	uint8 all;
	ROUND_DATA_BIT bit;
}ROUND_DATA;

//2025.7.22.102911|wei.n|添加
typedef struct
{
	ROUND_DATA	ad_dataa_1;
	ROUND_DATA	ad_dataa_2;

	ROUND_DATA	ad_datab_1;
	ROUND_DATA	ad_datab_2;
}StRoundDataFormEx;

typedef struct
{
	ROUND_DATA	ad_dataa_low;
	ROUND_DATA	ad_datab_low;

	ROUND_DATA	ad_dataa_high;
	ROUND_DATA	ad_datab_high;
}StRoundDataForm;

//////FINE_DATA_FORM//////////////////
typedef struct
{
	uint16 flag		: 1;
	uint16 err		: 1;
	uint16 ad_data	: 14;
}FINE_DATA_BIT;

typedef union
{
	uint16 all;
	FINE_DATA_BIT bit;
}FINE_DATA;

typedef struct
{
	FINE_DATA	ad_dataa;
	FINE_DATA	ad_datab;
}StFineDataForm;

typedef struct CONFIGDATA
{
	int32 motorPulse;
	int32 printerN;
	int32 motorM;
	double rollorperimeter;
	int32 fineSampleDetaInter;
	int32 precisionbit;
	int32 periodA;
	int32 periodB;
	int32 periodATimes;
	int32 fineStartOffset;
	int32 secondStartOffset;
	double systemPrecision;
	double maxRollorSpeed;
	double maxSampleRate;
	int32 fineSamplePoint;
	int32 roundSamplePoint;
	int32 roundSampleDataInterH;
	int32 roundSampleDataInterL;
	int32 virtualPanPoint;
	int32 virtualSampleDataInterH;
	int32 virtualSampleDataInterL;
	int32 posVirtualPan;
	int32 correspond_rollerspd;
	int32 correspond_motorspd;
	int16 ctl;
}configData;

typedef struct ERRORCHECK
{
	int32 m_fine_com_err;
	int32 m_fine_sum_err;
	int32 m_fine_ad_err;
	int32 m_fine_check_err;
	int32 m_fine_success;
	int32 m_fine_startbit_times;
	int32 m_round_check_err;
	int32 m_round_startbit_err;
	int32 m_round_counter_err;
	int32 m_round_success;

}errorcheck;
//////////////////////////////////////////////////////////////////////////
//typedef struct
//{
////	uint32* PCI_BASE_ADDR;
//	StPci m_pci;
//
//	uint32 m_rx_packet_handle;
//	uint32 m_rx_packet_thread_status;
////--------------sample data declare//////
//	configData myConfig;
//
//	char	m_pRoundSampleBufferChA[MAX_ROUND_POINT];
//	char	m_pRoundSampleBufferChB[MAX_ROUND_POINT];
//
//	uint16  m_round_cnt;
//	int32	m_round_buffer[READ_PCI_LIMIT];
//	int16	m_round_status;
//
//	StSampleStatus	m_status;
//	uint16	m_fine_buffer_index;
//	uint16	m_fine_buffer_last;
//	int32  m_fine_buffer[FINE_BUFFER_SIZE];
//	uint16	m_fine_check_sum;
//
//	REG_SAMPLE_STATUS m_sample_pc_ctrl;
//	//////////////////////////////////////////
// 	double			pulse_delta ;//= 0; //理想增量delta
//
//} StSample;

//2025.7.22.103227|wei.n|移植
//六通道修改//xi.hy
//修改名称为_V0@2025.9.3.114137 by liu.yt
typedef struct
{
//	uint32* PCI_BASE_ADDR;
	StPci m_pci;

	uint32 m_rx_packet_handle;
	uint32 m_rx_packet_thread_status;
//--------------sample data declare//////
	configData myConfig;

	char	m_pRoundSampleBufferChA[10][MAX_ROUND_POINT];
	char	m_pRoundSampleBufferChB[10][MAX_ROUND_POINT];

	uint16  m_round_cnt[MAX_ROUND_DEVICE];
	int16   roundIndex;
	int16   roundDataStartBit;
	int32	m_round_buffer[READ_PCI_LIMIT];
	int16	m_round_status;

	StSampleStatus	m_status;
	uint16	m_fine_buffer_index;
	uint16	m_fine_buffer_last;
	int32  m_fine_buffer[FINE_BUFFER_SIZE];
	uint16	m_fine_check_sum;

	REG_SAMPLE_STATUS m_sample_pc_ctrl;
	//////////////////////////////////////////
 	double			pulse_delta ;//= 0; //理想增量delta

} StSample_V0;

//新的采样结构体同步@2025.9.3.114150 by liu.yt
typedef struct
{
	uint8 m_show_id;
	uint8 m_hmi_num;
	uint8 m_hmi_id[MAX_HMI_NUM];
//	uint32* PCI_BASE_ADDR;
	StPci m_pci;

	uint32 m_rx_packet_handle;
	uint32 m_rx_packet_thread_status;

//--------------sample data declare//////
	configData myConfig;
	char	m_pRoundSampleBufferChA[10][MAX_ROUND_POINT];
	char	m_pRoundSampleBufferChB[10][MAX_ROUND_POINT];
	uint16  m_round_cnt[MAX_ROUND_CHANNEL];
	int16   roundIndex;
	int16   roundOk[3];
	int16   roundDataStartBit;
	int32	m_round_buffer[READ_PCI_LIMIT];
	int16	m_round_status;

	StSampleStatus	m_status;
	uint16	m_fine_buffer_index;
	uint16	m_fine_buffer_last;
	int32		m_fine_buffer[FINE_BUFFER_SIZE];
	uint16	m_fine_check_sum;

	REG_SAMPLE_STATUS m_sample_pc_ctrl;
	//////////////////////////////////////////

	StCameraCfgSts m_camera;
	int16 m_socket_sts;

	uint8 m_hmi_num_overflow;

 	double			pulse_delta ;
	uint16 m_cur_stationMsg;
} StSample;

int16 SampleCreate(StSample* pSample);
int16 SampleDelete(StSample* pSample);
int16 SampleRst(StSample* pSample) ;
int16 SampleSetDataBaseAddr(StSample* pSample, uint32 pAddr, void* handle);
int16 SampleSetSampleParam(StSample* pSample,StSampleParam* param, int16* cfg_data);
int16 SampleSetLoalShowDeviceId(StSample* pSample,uint8 device_id);
int16 SampleGetRoundData(StSample* pSample);
int16 SampleGetFineDataFromBuffer(StSample* pSample,uint16* ch_a,uint16* ch_b, int16* pStatus);
int16 SampleGetFineData(StSample* pSample, void* ch_a,void* ch_b,int16* flag);
int16 SampleGetStatus(StSample* pSample, StSampleStatus* status);
int16 SampleRdRoundDataThread(StSample* m_app);


#endif /* STSAMPLE_H_ */
