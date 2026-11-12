/*
 * gt_rn_struct.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef GT_RN_STRUCT_H_
#define GT_RN_STRUCT_H_

#define			USER_MAX_STATION_NUM_V0		(32)
#define			USER_IDLINK_NUM_MAX_V0		(30) /*每个驱控一体上能带的模块最大数目*/
#define			USER_IDLINK_SET_ID_MAX_V0		(100) /*每个扩展模块上的最大的地址值个数*/

#define                 USER_ILINK_NUM_AI_CHANNL_V0				 (6) //
#define                 USER_ILINK_NUM_AO_CHANNL_V0				 (6)//

#define                 USER_ILINK_NUM_DO_EHMI_BYTE_V0           (12)//
#define                 USER_ILINK_NUM_DI_EHMI_BYTE_V0			 (12)//

typedef struct
{
	unsigned short usDeviceMesg;
	unsigned short usVersion;
	unsigned short usYear;
	unsigned short usMonthDay;
	unsigned short usAddInfA;
	unsigned short usAddInfB;
	unsigned short usNetVersion;
}StVersion;

typedef struct
{
	unsigned short device_subtype	;
	unsigned short device_description1;
	unsigned short device_description2;
	unsigned short device_description3;
}StDescription;

typedef struct
{
	short dsp_ver_year;
	short dsp_ver_md;
	short fpga_ver_year;
	short fpga_ver_md;
	short cpld_ver_year;
	short cpld_ver_md;
}StFirmwareVersion;

#pragma pack(push,1)
typedef struct
{
	short rtn_sts;

	short pSpace;
	short temperature;
	unsigned long pfr;
	unsigned long enc;
	short vel;

	short driver_sts;
	short driver_err;

	short net_port_sts;
	short net_run_sts;
	short net_port_err_a;
	short net_port_err_b;

	unsigned long	motion_sts;
	unsigned short	modal;
	unsigned short  virtual_cnt;
	unsigned short	virtual_sts;
	//  [3/28/2017 googol]
	unsigned long trig_time;
	unsigned char  trig_cnt;
	unsigned short brake_cnt;
	unsigned short driver_current;
	unsigned short driver_temp;
	//  [3/28/2017 googol]
	//  [3/29/2017 googol]
	unsigned long rvs_data_0;
	unsigned long rvs_data_1;
	unsigned long rvs_data_2;
	unsigned long rvs_data_3;
	unsigned long rvs_data_4;
	unsigned long rvs_data_5;
	unsigned long rvs_data_6;
	unsigned long rvs_data_7;

}StPTSts;
#pragma pack(pop)

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

	unsigned char m_station_id_list[USER_MAX_STATION_NUM_V0] ;
	unsigned char m_station_ready[USER_MAX_STATION_NUM_V0];
	//add by luo.mj
	unsigned long m_crc_ok_cnt_a  ;
	unsigned long m_crc_err_cn_a   ;
	unsigned long m_crc_ok_cn_b   ;
	unsigned long m_crc_err_cn_b   ;
}StRingInf;

typedef struct
{
	unsigned char				m_device_num;
	unsigned char				port_err_cnt	;//		:  8;
	unsigned char				flag_crc_err	;//		:  1;
	unsigned char				flag_check_err;//		:  1;
	unsigned char				flag_head_err		;//	:  1;
	unsigned char				flag_empty_err;//			:  1;
	unsigned char				phy_rx_err			;//	:  1;
	unsigned char				phy_rx_overflow	;//		:  1;
	unsigned char				tx_overflow		;//		:  1;
	unsigned char				tx_underflow	;//		:  1;
	//0x0E
	unsigned char				auto_send_en		;//	:  1;//
	unsigned char				link_status			;//	:  1;//( 只读)
	unsigned char				ctrl_src_mask;//	:  1;
	unsigned char				ctrl_src;//		:  1;
	unsigned char				rx_ok			;//		:  1;//(只读)
}StIlinkInf;

typedef struct
{
	int			AO_Range;//8 模拟量通道输出
	int			AO_Offset;//16
	int			AO_Scaling;//16
	int			ErrMode	;//				:  8;//断线后的通信状态
	int			RrrVal;//16
	int			revsd0;//				:  8;//
	int			default_value;//:16;//
	int			revsd1;//:8;//
}IdLinkAoChannle;

typedef struct
{
	IdLinkAoChannle iLink_AO_Channl[USER_ILINK_NUM_AO_CHANNL_V0];
}IdLinkAoCfg;

typedef struct
{
	int		AI_Range;//8 模拟量通道输出
	int		AI_Offset;//16
	int		AI_Scaling;//16
	int		revsd0;//
	int		revsd1;//
}IdLinkAiChannle;

typedef struct
{
	IdLinkAiChannle		iLink_AI_Channl[USER_ILINK_NUM_AI_CHANNL_V0];
}IdLinkAiCfg;

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
	IdLinkAoCfg					m_device_AO_cfg;
	IdLinkAiCfg					m_device_AI_cfg;
	StVersion					m_net_version;
	StVersion					m_app_version;
	StDescription				m_description;
}StIlinkDeviceInf;

//////////////////////////////////////////////////////////////////////////

//#include "StIlinkCfg.h"
typedef struct
{
	unsigned char device_id;
	unsigned long addr;
	unsigned long data;
	unsigned long mask;
}StIlinkOpParam;

//  [11/26/2018 googol]
typedef struct
{
	unsigned short m_module_id;
	unsigned short m_module_type;
	IdLinkAoCfg   m_device_AO_cfg;
	IdLinkAiCfg   m_device_AI_cfg;
	unsigned short       m_DO_Val; //the default_value IO value
}StIlinkDeviceDescription;

typedef struct
{
	unsigned short m_module_num;
	StIlinkDeviceDescription m_module[USER_IDLINK_NUM_MAX_V0];
}StIlinkDescription;

typedef struct
{
	unsigned short m_station_id;
	unsigned short m_station_msg;
	StIlinkDescription m_ilink;
}StRingNetDescription;

typedef struct
{
	unsigned short m_station_num;
	StRingNetDescription m_station[USER_MAX_STATION_NUM_V0];
}StTopDescription;

//  [11/26/2018 googol] end
//////////////////////////////////////////////////////////////////////////
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
	StVersion			m_net_version;
}StIlinkModuleInf;
//  [6/28/2019 googol]

typedef struct
{
	unsigned char m_module_id;
	unsigned char m_module_type;
	unsigned char m_baudrate;
	unsigned char m_input_len;
	unsigned char m_output_len;
	unsigned char m_rvs;
}StGlink300ModuleCfg;

typedef struct
{
	unsigned short m_station_num;
	StGlink300ModuleCfg m_module_cfg[16];
}StGlink300Cfg;

//-------------------------sample cfg------------------------
typedef struct
{
	unsigned char param_ready : 1;
	unsigned char dirc_reverse : 1;
	unsigned char trig_out_src : 1;
	unsigned short rvs : 12;
	unsigned short ad_model : 1;
	//param bit0: param_ready
	//param bit1: dirc_reverse
	//param bit2: trig_out_src
	//param bit15 : ad_model
}StSampleCtrl;

typedef struct
{
	short ctl;
	short rsvd0;
	int motorPulse;
	int printerN;
	int motorM;
	int precisionbit;
	int fineStartOffset;
	int secondStartOffset;
	int fineSamplePoint;
	int roundSamplePoint;
	int virtualPanPoint;
	int posVirtualPan;
	int rsed1;
	double rollorperimeter;
	double systemPrecision;
	double maxRollorSpeed;
}StSampleParam;


typedef struct
{
	unsigned long		src_pfr_motorPulse; //不调整的电机，或者原计划出虚拟码盘站的电机规划脉冲，现在默认为2^21;
	unsigned long		src_pfr_printerN;//不调整的电机，或者原计划出虚拟码盘站的齿轮比;
	unsigned long		src_pfr_motorM;//不调整的电机，或者原计划出虚拟码盘站的齿轮比;
	unsigned long		src_pfr_id	;////不调整的电机，或者原计划出虚拟码盘的站站的站号;
	unsigned long		src_virtual_id;////可以出虚拟码盘的站点，参考该站点的虚拟码盘值为绝对值。
	//理论上该值等于src_pfr_id，但如果src_pfr_id不带虚拟码盘，则可以选择其他。
	//如果该值为0xf0.则表示不需要绝对位置。那么最后输出的值则以每一次配置的时刻为零点。
	unsigned long		src_virtualPanPoint;//参考站点输出虚拟码盘的点数
	unsigned long		des_virtualPanPoint;//目标站点输出虚拟码盘的点数

	unsigned long		des_id;					//目标站点ID
	unsigned long		des_dirc_reverse; //输出AB脉冲是否需要取反。
}StVirtualParam;

typedef struct
{
	//////////////////////////////
	void*  m_socket_handle;
	char*  m_pDataBuffer;
	//////////////////////////////////////////////////////////////////////////
	short m_protocol_type;//default 0.
	/////////////////////////////////////
	long m_start_packet_size; //default is 20
	//long m_normal_packet_size;//default is 1288
	long m_end_packet_size;//defualt 16
	long m_least_packet_num;//
	//////////////////////////////////////////////
	long m_width_max;
	long m_height_max;
	/////////////////////////////
	long m_height_index;
	long m_loop_max_time;//default value is 400
	long m_ok_cnt;
	long m_err_cnt;
}StCameraCfgSts;

typedef struct
{
	short	m_fine_rd_err	;//rd the empty fifo happen
	short	m_fine_num	;
	short	m_fine_buffer_vaild_num;
	short	m_round_rding;

	int m_fine_com_err;
	int m_fine_sum_err;
	int m_fine_ad_err;
	int m_fine_check_err;
	int m_fine_success;
	int m_fine_startbit_times;
	int m_round_ok;
	int m_round_err;
}StSampleStatus;

typedef struct
{
	unsigned short	station_type			;//0:主站；1:主显；2：从站
	unsigned short	id_auto_set_en			;
	unsigned short	master_flag		;
	unsigned short	ehmin_close				;
	//	unsigned short	sample_dir_rev			;
	unsigned short	station_id				;
}StStationCfgMsg;

typedef struct
{
	unsigned char m_station_id;
	unsigned char m_fun_pc;//支持PC通讯功能
	unsigned char m_fun_ref;//支持运控功能
	unsigned char m_fun_ilink;//支持500协议
	unsigned char m_fun;
}StStationInf;

typedef struct
{
	unsigned short m_station_num;
	StStationInf m_station_inf[USER_MAX_STATION_NUM_V0];
}StRingMultiInf;

typedef struct
{
	short encoder;
	short probeType;
	short probeIndex;
	short offset;
	short windowOnly;
	short rsvd0;
	unsigned long loop;
	long firstPosition;
	long lastPosition;
}StTrigger;

typedef struct
{
	short execute;
	short done;
	long position;
}StTriggerStatus;

#pragma pack(1)
typedef struct
{
	unsigned long uiRingNetSts;   //bit0：0：网络初始化失败，1：网络初始化成功；
	//bit1：0：环网，1：非环网。
	unsigned long uiDeviceNum; //等环网上站点个数，包括主站
	unsigned long uiMessage[USER_MAX_STATION_NUM_V0];//站点信息，数组下标为DMA配置的序号
	///be care. the uiMessage[0] is the local message.  the others not local message.
}StRntMap;
#pragma pack()


#endif /* GT_RN_STRUCT_H_ */
