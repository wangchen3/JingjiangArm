/*
 * gt_rn_struct_exta.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef GT_RN_STRUCT_EXTA_H_
#define GT_RN_STRUCT_EXTA_H_

#include "gt_rn_struct.h"
//////////////////////////////////////////////////////////////////////////
#define			USER_MAX_STATION_NUM_V1		(256)
#define			USER_IDLINK_NUM_MAX_V1		(128) /*每个驱控一体上能带的模块最大数目*/
#define			USER_IDLINK_SET_ID_MAX_V1		(128) /*每个扩展模块上的最大的地址值个数*/

#define                USER_ILINK_NUM_AI_CHANNL_V1          (32)
#define                USER_ILINK_NUM_AO_CHANNL_V1           (32)
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
typedef struct
{
	unsigned char m_master_flag;//	: 1;
	unsigned char m_port_link_up_a ;//	: 1;
	unsigned char m_port_link_up_b ;//	: 1;
	unsigned char m_id_auto_set	;//	: 1;

	unsigned char m_sync_status;//		: 1;
	unsigned char m_dc_status;//			: 2;

	unsigned char m_device_num;//			: 8;
	unsigned char m_device_id;//			: 8;

	unsigned short m_sync_cycle;//			: 16;
	unsigned short rsvd0;//			: 16;

	unsigned char m_station_id_list[USER_MAX_STATION_NUM_V1] ;
	unsigned char m_station_ready[USER_MAX_STATION_NUM_V1];
	//add by luo.mj
	unsigned long m_crc_ok_cnt_a  ;
	unsigned long m_crc_err_cn_a   ;
	unsigned long m_crc_ok_cn_b   ;
	unsigned long m_crc_err_cn_b   ;
}StRingInfVer1;

typedef struct
{
	unsigned long uiRingNetSts;   //bit0：0：网络初始化失败，1：网络初始化成功；
	//bit1：0：环网，1：非环网。
	unsigned long uiDeviceNum; //等环网上站点个数，包括主站
	unsigned long uiMessage[USER_MAX_STATION_NUM_V1];//[MAX_STATION_NUM];//站点信息，数组下标为DMA配置的序号
	///be care. the uiMessage[0] is the local message.  the others not local message.
}StRntMapVer1;
#pragma pack()

typedef struct
{
	IdLinkAoChannle iLink_AO_Channl[USER_ILINK_NUM_AO_CHANNL_V1];
}IdLinkAoCfgVer1;

typedef struct
{
	IdLinkAiChannle		iLink_AI_Channl[USER_ILINK_NUM_AI_CHANNL_V1];
}IdLinkAiCfgVer1;

typedef struct
{
	unsigned char				m_device_type;
	unsigned char				port0_status;//		: 1;
	unsigned char				port1_status	;//	: 1;
	unsigned char				device_err	;//		: 1;
	unsigned char				com_err		;//		: 1;
	unsigned char				type_err		;//	: 1;
	unsigned char				resp_ok		;//		: 1;
	unsigned char				port2_status	;//	: 1;
	unsigned char				m_sub_type;
	unsigned char				resd[3];
	IdLinkAoCfgVer1			m_device_AO_cfg;
	IdLinkAiCfgVer1			m_device_AI_cfg;
	StVersion						m_net_version;
	StVersion						m_app_version;
	StDescription				m_description;
}StIlinkDeviceInfVer1;

typedef struct
{
	unsigned short m_module_id;
	unsigned short m_module_type;
	IdLinkAoCfgVer1   m_device_AO_cfg;
	IdLinkAiCfgVer1   m_device_AI_cfg;
	unsigned short       m_DO_Val; //the default_value IO value
}StIlinkDeviceDescriptionVer1;

typedef struct
{
	unsigned short m_module_num;
	StIlinkDeviceDescriptionVer1 m_module[USER_IDLINK_NUM_MAX_V1];
}StIlinkDescriptionVer1;

typedef struct
{
	unsigned short m_station_id;
	unsigned short m_station_msg;
	StIlinkDescriptionVer1 m_ilink;
}StRingNetDescriptionVer1;

typedef struct
{
	unsigned short m_station_num;
	StRingNetDescriptionVer1 m_station[USER_MAX_STATION_NUM_V1];
}StTopDescriptionVer1;


typedef struct
{
	//////////////////////////////////
	unsigned char				rd_en				: 1; // this bit must be 1 now
	unsigned char				rd_delta			: 1; //
	unsigned char				rd_cmd				: 2; //
	unsigned char				rsvd_bit4			: 1;
	unsigned char				rd_num_src		: 1;// 0 decide by inner, 1: by outside
	unsigned char				rd_num_bit8		: 1;
	unsigned char				rsvd_bit7			: 1;
	unsigned char				rd_num_low		: 8;
	unsigned short				rd_start_addr;
	//////////////////////////////////////////////////////////////////////////
	unsigned char				checksum			;// this var isn't used in rx/tx packet, except pdu dma cfg
	unsigned char				des_id;             //数据源ID/目标ID。

	unsigned char				len_bit8				: 1;//数据区的数据长度1位
	unsigned char				des_ch				: 3;//the ch which  访问FPGA DMA通道，user[2:0]必须为0。	user[5:3]根据DSP通道决定。
	unsigned char				src_ch				: 3;//访问FPGA DMA通道，user[2:0]必须为0。	user[5:3]根据DSP通道决定。
	unsigned char				rsvd_bit7_a		: 1;//

	unsigned char				len_low				: 8;//数据区的数据长度低8位
	//////////////////////////////////
	unsigned char				cmd					: 3;
	unsigned char				delta					: 1;//delta[0:0]DMA访问地址增量值 0：每次访问同一个地址；	1：每次访问都累加1
	unsigned char				resp_req			: 1;//resp_req =0:不需要返回应答。	resp_req =1:需要返回应答。当cmd=4,5,6,7,resp_req必须为1.
	unsigned char				resp					: 1;//
	unsigned char				num_bit8			: 1;//
	unsigned char				resp_ok				: 1;//

	unsigned char				num_low			: 8;//DMA寻址次数
	unsigned short				start_addr;             //DMA启动地址
//////////////////////////////////////////////////////////////////////////
}TRnPduDmaCfg;

//
// typedef struct
// {
// 	//////////////////////////////////
// 	unsigned long				rd_delta			; //
// 	unsigned long				rd_cmd				 ;//cmd=0(LWR):逻辑寻址写
// 																//cmd=1(AWR):绝对寻址写
// 																//cmd=2(LMWR):逻辑地址映射区寻址写
// 																//cmd=3(TCWR):报文发送配置区寻址写
// 																//cmd=4(LRD):逻辑寻址读
// 																//cmd=5(ARD):绝对寻址读
// 																//cmd=6(LMRD):逻辑地址映射区寻址读
// 																//cmd=7(TCRD):报文发送配置区寻址读*/
// 	unsigned long				rd_num_src		;// 0 decide by inner, 1: by outside
//
// 	unsigned long				rd_num		;
// 	unsigned long				rd_start_addr;
// 	unsigned long				rsvd_bit7		;
// 	//////////////////////////////////////////////////////////////////////////
// 	unsigned long				des_id;             //目标ID。
// 	unsigned long				des_ch	;//the ch which  访问FPGA DMA通道，user[2:0]必须为0。	user[5:3]根据DSP通道决定。
// //	unsigned long				src_ch	;//访问FPGA DMA通道，user[2:0]必须为0。	user[5:3]根据DSP通道决定。
// 	unsigned long				rsvd_a		;//
// 	//////////////////////////////////
// 	unsigned long				cmd	;/*cmd=0(LWR):逻辑寻址写
// 														cmd=1(AWR):绝对寻址写
// 														cmd=2(LMWR):逻辑地址映射区寻址写
// 														cmd=3(TCWR):报文发送配置区寻址写
// 														cmd=4(LRD):逻辑寻址读
// 														cmd=5(ARD):绝对寻址读
// 														cmd=6(LMRD):逻辑地址映射区寻址读
// 														cmd=7(TCRD):报文发送配置区寻址读*/
// 	unsigned long				delta				;//delta[0:0]DMA访问地址增量值 0：每次访问同一个地址；	1：每次访问都累加1
// 	unsigned long				resp_req		;//resp_req =0:不需要返回应答。	resp_req =1:需要返回应答。当cmd=4,5,6,7,resp_req必须为1.
// 	unsigned long				num			;//
//
// 	unsigned long			start_addr;             //DMA启动地址
// //////////////////////////////////////////////////////////////////////////
// }TRnPduDmaCfg;
//////////////////////////////////////////////////////////////////////////
//#endif //RING_NET_RESOURCE


#endif /* GT_RN_STRUCT_EXTA_H_ */
