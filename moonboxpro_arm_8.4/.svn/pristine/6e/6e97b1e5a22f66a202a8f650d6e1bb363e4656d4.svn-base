/*
 * gt_rn_struct_private.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef GT_RN_STRUCT_PRIVATE_H_
#define GT_RN_STRUCT_PRIVATE_H_

#include "type_def.h"
#include "gt_rn_struct.h"
#include "gt_rn_struct_exta.h"

#define		RN_FPGA_CH_ID		(0)
#define		RN_PCI_CH_ID			(1)
#define		RN_DSP_CH_ID		(2)
#define		RN_DSPEX_CH_ID		(3)
#define		RN_EXT_CH_ID			RN_DSPEX_CH_ID


//////////////////////////////////////////////////////////////////////////
#define		RN_MODAL_PT_IDLE			0
#define		RN_MODAL_PT_RUN			1
#define		RN_MODAL_PT_SMOOTH	2
#define		RN_MODAL_PT_EMG			3

//////////////////////////////////////////////////////////////////////////
#define TOPOLOGY_RING					0
#define TOPOLOGY_NO_RING				1
#define TOPOLOGY_ID_CONFLICT			2
#define TOPOLOGY_UNKNOW					3
#define TOPOLOGY_RING_SCAN_NUM_WRONG	4

#ifdef RN_NETWORK
#define MAX_STATION_NUM		250
#else
#define MAX_STATION_NUM		250
#endif

#define IDLINK_NUM_MAX			128 /*每个驱控一体上能带的模块最大数目*/
#define IDLINK_SET_ID_MAX		128 /*每个扩展模块上的最大的地址值个数*/
//////////////////////////////////////////////////////////////////////////

#define                 ILINK_NUM_AI_CHANNL           (6)
#define                 ILINK_NUM_AO_CHANNL           (6)
#define                 ILINK_NUM_DO_EHMI_BYTE           (12)
#define                 ILINK_NUM_DI_EHMI_BYTE			 (12)


#define         PRIVATE_ILINK_NUM_AI_CHANNL          (32)
#define         PRIVATE_ILINK_NUM_AO_CHANNL         (32)


#define			PRIVATE_MAX_STATION_NUM		(MAX_STATION_NUM)
#define			PRIVATE_IDLINK_NUM_MAX		(IDLINK_NUM_MAX) /*每个驱控一体上能带的模块最大数目*/
#define			PRIVATE_IDLINK_SET_ID_MAX		(IDLINK_SET_ID_MAX) /*每个扩展模块上的最大的地址值个数*/


#define PCI_IDLE								0
#define PCI_PC_BUSY						1
#define PCI_PC_FINISH                    2
#define PCI_DSP_BUSY                    3
#define PCI_DSP_FINISH                  4

#define PCI_PC_FINISH_CORE0             10
#define PCI_PC_FINISH_CORE1             11

#define PCI_PC_FINISH_EX               (0x2D)
#define PCI_PC_FINISH_CORE0_EX         (0x5A)
#define PCI_PC_FINISH_CORE1_EX         (0xA5)

#ifndef COMMAND_DATA_LEN
#define COMMAND_DATA_LEN	32
#endif

typedef struct
{
	int16 dataLen;
	int16 data[32];

	int16 resultLen;
	int16 result[32];
	int16 resultIndex;
}TCommand;


typedef struct
{
	int16 flag;
	int16 len;
	int16 checksum;
	int16 data[128];
} TPci;


typedef struct
{
	uint16 barNo;
	uint16 rsvd0;
	LPoint baseAddr;
	void * hGexFile;
	void * handle;
}StPci;
//////////////////////////////////////////////////////////////////////////
typedef struct
{
	uint8 m_master_flag;//	: 1;
	uint8 m_port_link_up_a ;//	: 1;
	uint8 m_port_link_up_b ;//	: 1;
	uint8 m_id_auto_set	;//	: 1;

	uint8 m_sync_status;//		: 1;
	uint8 m_dc_status;//			: 2;

	uint8 m_device_num;//			: 8;
	uint8 m_device_id;//			: 8;

	uint16 m_sync_cycle;//			: 16;
	uint16 rsvd0;//			: 16;

	uint8 m_station_id_list[PRIVATE_MAX_STATION_NUM] ;
	uint8 m_station_ready[PRIVATE_MAX_STATION_NUM];
	//add by luo.mj
	uint32 m_crc_ok_cnt_a  ;
	uint32 m_crc_err_cn_a   ;
	uint32 m_crc_ok_cn_b   ;
	uint32 m_crc_err_cn_b   ;
}StRingInfPrivate;

typedef struct
{
	IdLinkAoChannle iLink_AO_Channl[PRIVATE_ILINK_NUM_AO_CHANNL];
}IdLinkAoCfgPrivate;


typedef struct
{
	IdLinkAiChannle		iLink_AI_Channl[PRIVATE_ILINK_NUM_AI_CHANNL];
}IdLinkAiCfgPrivate;

typedef struct
{
	uint8				m_device_type;
	uint8				port0_status;//		: 1;
	uint8				port1_status	;//	: 1;
	uint8				device_err	;//		: 1;
	uint8				com_err		;//		: 1;
	uint8				type_err		;//	: 1;
	uint8				resp_ok		;//		: 1;
	uint8				port2_status	;//	: 1;
	uint8				m_sub_type;
	uint8				resd[3];
	IdLinkAoCfgPrivate		m_device_AO_cfg;
	IdLinkAiCfgPrivate		m_device_AI_cfg;
	StVersion					m_net_version;
	StVersion					m_app_version;
	StDescription				m_description;
}StIlinkDeviceInfPrivate;

//  [11/26/2018 googol]
typedef struct
{
	uint16 m_module_id;
	uint16 m_module_type;
	IdLinkAoCfgPrivate   m_device_AO_cfg;
	IdLinkAiCfgPrivate   m_device_AI_cfg;
	uint16       m_DO_Val; //the default_value IO value
}StIlinkDeviceDescriptionPrivate;

typedef struct
{
	uint16 m_module_num;
	StIlinkDeviceDescriptionPrivate m_module[PRIVATE_IDLINK_NUM_MAX];
}StIlinkDescriptionPrivate;

typedef struct
{
	uint16 m_station_id;
	uint16 m_station_msg;
	StIlinkDescriptionPrivate m_ilink;
}StRingNetDescriptionPrivate;

typedef struct
{
	uint16 m_station_num;
	StRingNetDescriptionPrivate m_station[PRIVATE_MAX_STATION_NUM];
}StTopDescriptionPrivate;

typedef struct
{
	uint16 m_station_num;
	StStationInf m_station_inf[PRIVATE_MAX_STATION_NUM];
}StRingMultiInfPrivate;

#pragma pack(1)
typedef struct
{
	uint32 uiRingNetSts;   //bit0：0：网络初始化失败，1：网络初始化成功；
	//bit1：0：环网，1：非环网。
	uint32 uiDeviceNum; //等环网上站点个数，包括主站
	uint32 uiMessage[PRIVATE_MAX_STATION_NUM];//[MAX_STATION_NUM];//站点信息，数组下标为DMA配置的序号
	///be care. the uiMessage[0] is the local message.  the others not local message.
}StRntMapPrivate;
#pragma pack()

//////////////////////////////////////////////////////////////////////////

//#endif //RING_NET_RESOURCE


#endif /* GT_RN_STRUCT_PRIVATE_H_ */
