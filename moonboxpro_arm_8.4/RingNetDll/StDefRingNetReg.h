/*
 * StDefRingNetReg.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef STDEFRINGNETREG_H_
#define STDEFRINGNETREG_H_

#include "type_def.h"

#define					RN_COM_PTC_MODEL_AUTO_END_TX					0
#define					RN_COM_PTC_MODEL_WAIT_ACTIVE					1
#define					RN_COM_PTC_MODEL_WAIT_SYNC						2
#define					RN_COM_PTC_MODEL_AUTO_TX						3

//PDU TX BIT

#define					RN_COM_PTC_SET_DATA_VALID_BIT					1
#define					RN_COM_PTC_CLR_DATA_VALID_BIT					0

#define					RN_COM_PTC_SET_ACTIVE_BIT						1
#define					RN_COM_PTC_CLR_ACTIVE_BIT						0

#define					RN_COM_PTC_SET_CLR_BIT							1
#define					RN_COM_PTC_CLR_CLR_BIT							0

//MAIL TX BIT

#define					RN_COM_MTC_SET_DATA_VALID_BIT					1
#define					RN_COM_MTC_CLR_DATA_VALID_BIT					0

#define					RN_COM_MTC_SET_MAIL_REQ_BIT						1
#define					RN_COM_MTC_CLR_MAIL_REQ_BIT						0

#define					RN_COM_MTC_SET_CLR_BIT							1
#define					RN_COM_MTC_CLR_CLR_BIT							0

//PDU RX BIT

#define					RN_COM_PRC_SET_RD_OVER_BIT						1
#define					RN_COM_PRC_CLR_RD_OVER_BIT						0

#define					RN_COM_PRC_SET_CLR_BIT							1
#define					RN_COM_PRC_CLR_CLR_BIT							0

//MAIL RX BIT

#define					RN_COM_MRC_SET_RD_OVER_BIT						1
#define					RN_COM_MRC_CLR_RD_OVER_BIT						0

#define					RN_COM_MRC_SET_CLR_BIT							1
#define					RN_COM_MRC_CLR_CLR_BIT							0


#define					RN_CNS_LOCAL_ID_SRC_AUTO			0
#define					RN_CNS_LOCAL_ID_SRC_LOCAL			1

#define					RN_CNS_SYNC_OFF						0
#define					RN_CNS_SYNC_ON						1

#define					RN_CNS_DEVICE_ID_UPLIMIT			255
#define					RN_CNS_DEVICE_ID_DOWNLIMIT			0

/////////////////////////////////////


/////////////REG_RN_PORT_STATUS//////////////////
typedef struct
{
	uint16				link_up_a				: 1;//status[0] = link_up; 链路通道1：连接；0：断开
	uint16				offset_valid_a			: 1;//status[1] = OFFSET_VALID;1：偏移量OK
	uint16				clock_speed_a			: 2;//status[3:2] = clock_speed; 2'b10 : 千兆；2'b01:百兆；2‘b11:485

	uint16				duplex_status_a			: 1;//status[4] = duplex_status;1：双工；0：单工
	uint16				link_status_a			: 1;//status[5] = link_status;物理通道1：连接0：断开
	uint16				overflow_a				: 1;//status[6]=overflow,数据溢出标志。该值需要clr才能清除
	uint16				rsvd_a					: 1;//

	uint16				link_up_b				: 1;//
	uint16				offset_valid_b			: 1;//
	uint16				clock_speed_b			: 2;//

	uint16				duplex_status_b			: 1;//
	uint16				link_status_b			: 1;//
	uint16				overflow_b				: 1;//
	uint16				rsvd_b					: 1;//

}REG_RN_PORT_STATUS_BIT;

typedef union
{
	uint16 all;
	REG_RN_PORT_STATUS_BIT bit;
}REG_RN_PORT_STATUS;

///////////////REG_RN_NET_RUN_STATUS//////////////////
typedef struct
{
	uint16				dc_status					: 2;//00：关闭状态 	01：正常状态		10：偏差过大		11：长期错误
	uint16				sync_on						: 1;//该值只有主站可以操作有效，其他站点修改该值无意义。主站写1使能系统的同步功能。	1：同步正常	0：没有同步
	uint16				mac_tx_overflow_a		: 1;//1:macport_a发生过读取fifo oveflow错误情况，clr清除

	uint16				mac_tx_underflow_a	: 1;//1:macport_a发生过读取fifo underflow错误情况，clr清除
	uint16				mac_tx_packet_err_a	: 1;//1:mac port_a发生过”组包"错误情况，clr清除
	uint16				local_id_src				: 1;//该值仅能在本地修改，且在网络没有构建前。0自动分配，1本地分配 0 : auto, 1 : local

	uint16				offset_calc_rst			: 1;//

	uint16				rsvd_bit8to9		: 2;

	uint16				rollback_valid		: 1;

	uint16				mac_tx_overflow_b	: 1;
	uint16				mac_tx_underflow_b	: 1;
	uint16				mac_tx_packet_err_b	: 1;

	uint16				station_ready		: 1;

	uint16				master_flag				: 1;//1：表示该站点为主站，否则为从站

	uint16				rsvd_bit16to31			: 16;//
}REG_RN_NET_RUN_STATUS_BIT;

typedef union
{
	uint16 all;
	REG_RN_NET_RUN_STATUS_BIT bit;
}REG_RN_NET_RUN_STATUS;


////////////////REG_RN_SYNC_CYCLE/////////////////////////////
typedef struct
{
	uint16				sync_cycle				: 16;//只能主站可以修改，其他站点只读。

}REG_RN_SYNC_CYCLE_BIT;


typedef union
{
	uint16 all;
	REG_RN_SYNC_CYCLE_BIT bit;
}REG_RN_SYNC_CYCLE;


////////////////REG_RN_ONLINE_MSG/////////////////////////////
typedef struct
{
	uint8				device_id				: 8;//当local_id_src为自动分配时，该值自动分配值，否则该值可写。	当自动分配时，auto_id = 8'hf0;表示还没有分配。

	uint8				device_num			: 8;//线上站点个数（包括自己）。

}REG_RN_ONLINE_MSG_BIT;

typedef union
{
	uint16 all;
	REG_RN_ONLINE_MSG_BIT bit;
}REG_RN_ONLINE_MSG;

////////////////REG_RN_CRC_OK_CNT_A_L/////////////////////////////
typedef struct
{
	uint16				crc_ok_cnt_a_l		: 16;//内部不保证crc_ok_cnt_a[15:0]和crc_ok_cnt_a[31:16]的一致性。

}REG_RN_CRC_OK_CNT_A_L_BIT;

typedef union
{
	uint16 all;
	REG_RN_CRC_OK_CNT_A_L_BIT bit;

}REG_RN_CRC_OK_CNT_A_L;


////////////////REG_RN_CRC_OK_CNT_A_H/////////////////////////////
typedef struct
{
	uint16				crc_ok_cnt_a_h		: 16;//内部不保证crc_ok_cnt_a[15:0]和crc_ok_cnt_a[31:16]的一致性。

}REG_RN_CRC_OK_CNT_A_H_BIT;


typedef union
{
	uint16 all;
	REG_RN_CRC_OK_CNT_A_H_BIT bit;

}REG_RN_CRC_OK_CNT_A_H;


////////////////REG_RN_CRC_ERR_CNT_A/////////////////////////////
typedef struct
{
	uint16				crc_err_cnt_a			: 16;//该值记录上电后的错误累计，不能清除

}REG_RN_CRC_ERR_CNT_A_BIT;

typedef union
{
	uint16 all;
	REG_RN_CRC_ERR_CNT_A_BIT bit;
}REG_RN_CRC_ERR_CNT_A;

///////////////REG_RN_STATION_MSG/////////////////////////////
typedef struct
{
	uint16				station_msg		: 16;

}REG_RN_STATION_MSG_BIT;

typedef union
{
	uint16 all;
	REG_RN_STATION_MSG_BIT bit;
}REG_RN_STATION_MSG;

////////////////REG_RN_CRC_OK_CNT_B_L/////////////////////////////
typedef struct
{
	uint16				crc_ok_cnt_b_l		: 16;//

}REG_RN_CRC_OK_CNT_B_L_BIT;

typedef union
{
	uint16 all;
	REG_RN_CRC_OK_CNT_B_L_BIT bit;

}REG_RN_CRC_OK_CNT_B_L;
////////////////REG_RN_CRC_OK_CNT_B_H/////////////////////////////
typedef struct
{
	uint16				crc_ok_cnt_b_h		: 16;

}REG_RN_CRC_OK_CNT_B_H_BIT;

typedef union
{
	uint16 all;
	REG_RN_CRC_OK_CNT_B_H_BIT bit;
}REG_RN_CRC_OK_CNT_B_H;


////////////////REG_RN_CRC_ERR_CNT_B/////////////////////////////
typedef struct
{
	uint16				crc_err_cnt_b		: 16;

}REG_RN_CRC_ERR_CNT_B_BIT;

typedef union
{
	uint16 all;
	REG_RN_CRC_ERR_CNT_B_BIT bit;

}REG_RN_CRC_ERR_CNT_B;

////////////////REG_RN_STATION_ID/////////////////////////////
typedef struct
{
	uint8				station_id_auto		: 8;
	uint8				station_id_set		: 8;

}REG_RN_STATION_ID_BIT;

typedef union
{
	uint16 all;
	REG_RN_STATION_ID_BIT bit;

}REG_RN_STATION_ID;

///////////////////FPGA DMA////////////////////////////
////////////////REG_RN_DMA_MAIN_CTRL_STATUS/////////////////////////////
typedef struct
{
	uint16				pdu_en							: 1;//当remote_cfg_en = 1时，该值可读可写，否者该值仅可读。
	uint16				remote_cfg_en				: 1;//该值仅本地配置
	uint16				clr									: 1;//当remote_cfg_en = 1,该值可读可写，否者仅可读。该值读为0，自清除。
	uint16				pdu_active_err				: 1;//1：表示上一个周期DMA每一执行完成，又发起新的请求。该值会被锁存。在clr写1清除。

	uint16				pdu_check_sum_err		: 1;//1：有请求发送PDU报文数据指令校验和错误，该报文不会被发送。该值会被锁存。写clr
	uint16				pdu_packet_size_zero		: 1;//1：有请求发送PDU报文数据长度为0，该报文不会被发送。该值会被锁存。写clr

	uint16				pdu_tx_map_model		: 1;//0:兼容原来模式；1：地址+长度
	uint16				pdu_rx_map_model		: 1;//0:兼容原来模式；1：地址+长度
//
	uint16				pdu_num						: 8;//表示每一个周期需要发送的PDU报文个数	当remote_cfg_en = 1时，该值可读可写，否者该值仅可读。

	uint16				rsvd_bit16to31				: 16;//
}REG_RN_DMA_MAIN_CTRL_STATUS_BIT;


typedef union
{
	uint16 all;
	REG_RN_DMA_MAIN_CTRL_STATUS_BIT bit;
}REG_RN_DMA_MAIN_CTRL_STATUS;

////////////////REG_RN_DMA_CFG_SET_ADDR/////////////////////////////
typedef struct
{
	uint16				cfg_addr				: 16;//当需要访问dma的cfg区时，该值未设定的地址初始值。而每一次	操作DMA_CFG_OP_DATA时，该地址会自动加1。

}REG_RN_DMA_CFG_SET_ADDR_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_DMA_CFG_SET_ADDR_BIT bit;
	}REG_RN_DMA_CFG_SET_ADDR;

////////////////REG_RN_DMA_CFG_OP_DATA/////////////////////////////
	typedef struct
	{
		uint16				cfg_data				: 16;//每一次读或者写操作DMA_CFG_OP_DATA时，cfg_addr会自加1。

	}REG_RN_DMA_CFG_OP_DATA_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_DMA_CFG_OP_DATA_BIT bit;
	}REG_RN_DMA_CFG_OP_DATA;


//////////////////MODAL CHANGE////////////////////////////
////////////////REG_RN_MODAL_CTRL_STATUS/////////////////////////////
	typedef struct
	{
		uint16				ctrl_src					: 1;//0 for local, 1 for remote该值仅本地配置。0：表示所有状态由本地址控制，1：表示所有状态由远程控制。
		uint16				ctrl_src_mask			: 1;//该值仅本地配置，只有该值为1时，ctrl_src才会被修改
		uint16				change_en				: 1;//当该值为1，模态切换才会有效。当state处于IDLE才有效。它不能停止切换
		uint16				change_en_mask	: 1;//当该值为1，change_en才会被修改

		uint16				state						: 3;//切换状态：		IDLE = 0,             WILL_CHANGE = 1,			WAIT_TIME = 2,       NORMAL_WAIT_SYNC = 3,      			FAST_WAIT_SYNC = 4   STOP = 5,                OVER = 6;
		uint16				change_stop			: 1;//当采用normal模式时，且status出于WILL_CHANGE或者WAIT_TIME时都可以停止切换，其他时刻无效。写1有效，该值自动清除。

		uint16				lock_sys_time			: 1;//写1锁存当前系统时间，存于sys_time.
		uint16				lock_type				: 1;//0：LOCK_NOW 1: LOCK_SYNC
		uint16				lock_type_mask		: 1;// this bit don't used any more

		uint16				rsvd_bit9to15			: 7;//

		//
	}REG_RN_MODAL_CTRL_STATUS_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_MODAL_CTRL_STATUS_BIT bit;

	}REG_RN_MODAL_CTRL_STATUS;
////////////////REG_RN_SYS_TMIE_L////////////////////////////
	typedef struct
	{
		uint32				sys_time_l			: 16;

		uint32				rsvd_bit16to31		: 16;
	}REG_RN_SYS_TMIE_L_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_SYS_TMIE_L_BIT bit;
	}REG_RN_SYS_TMIE_L;
////////////////REG_RN_SYS_TMIE_H////////////////////////////
	typedef struct
	{
		uint32				sys_time_h			: 16;

		uint32				rsvd_bit16to31		: 16;
	}REG_RN_SYS_TMIE_H_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_SYS_TMIE_H_BIT bit;

	}REG_RN_SYS_TMIE_H;

////////////////REG_RN_FAST_NEXT////////////////////////////
	typedef struct
	{
		uint16				fast_next			: 16;


	}REG_RN_FAST_NEXT_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_FAST_NEXT_BIT bit;

	}REG_RN_FAST_NEXT;

	////////////////REG_RN_NORMAL_NEXT////////////////////////////
	typedef struct
	{
		uint16				normal_next			: 16;


	}REG_RN_NORMAL_NEXT_BIT ;

	typedef union
	{
		uint16 all;
		REG_RN_NORMAL_NEXT_BIT bit;

	}REG_RN_NORMAL_NEXT;

	////////////////REG_RN_CHANGE_TIME_L////////////////////////////
	typedef struct
	{
		uint32				change_time_l			: 16;

		uint32				rsvd_bit16to31		: 16;
	}REG_RN_CHANGE_TIME_L_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_CHANGE_TIME_L_BIT bit;
	}REG_RN_CHANGE_TIME_L;

	////////////////REG_RN_CHANGE_TIME_H////////////////////////////
	typedef struct
	{
		uint32				change_time_h			: 16;

		uint32				rsvd_bit16to31		: 16;
	}REG_RN_CHANGE_TIME_H_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_CHANGE_TIME_H_BIT bit;

	}REG_RN_CHANGE_TIME_H;

	////////////////REG_RN_MODAL_NOW////////////////////////////
	typedef struct
	{
		uint16				modal_now			: 16;


	}REG_RN_MODAL_NOW_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_MODAL_NOW_BIT bit;
	}REG_RN_MODAL_NOW;

	////////////////REG_RN_T_SYS_TIME/////////////////////////////
	typedef struct
	{
		uint16				t_sys_time				: 16;//1表示8*128 = 1024ns。

	}REG_RN_T_SYS_TIME_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_T_SYS_TIME_BIT bit;
	}REG_RN_T_SYS_TIME;

	////////////////////REG_RN_SECONDARY_CTRL//////////////////////////////////////////////////////
	typedef struct
	{
		uint8				sync_src_id			: 8; //当前同步的站点
		uint8				secondary_sts		: 1;//0：关闭次主站模式 	1：使能次主站模式	如果是从站，该值在条件合适时会自动切换为1，但是不会自动切换为0。secondary_en为0时，该值清除。
		uint8				secondary_en		: 1;//0：关闭自动切换为次主站功能 1：使能自动切换为次主站功能 	当该值为1时，本设备会自动检测同步时钟信号，如果超时没有同步信号，则自动使能次主站模式。
		uint8				sync_src_id_valid  : 1;//当该为为1，sync_src_id有效，否则当前不会接收同步数据。
		uint8				rsvd_bit11to15		: 5;

	}REG_RN_SECONDARY_CTRL_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_SECONDARY_CTRL_BIT bit;
	}REG_RN_SECONDARY_CTRL;

	////////////////REG_RN_PDU_TX_CTRL////////////////////////////
	typedef struct
	{
		uint16				clr						: 1;//写1清除PDU_TX_STATUS所有状态位
		uint16				rsvd_bit1to11		: 11;//

		uint16				active				: 1;//用于WAIT_ACTIVE模式，写1有效，则启动一次发送，将buffer中所有完整的报文都发送出去。直接buffer空才停止
		uint16				data_valid			: 1;//写1：一个完整报文发已经送至FPGA

		uint16				model				: 2;


	}REG_RN_PDU_TX_CTRL_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_PDU_TX_CTRL_BIT bit;

	}REG_RN_PDU_TX_CTRL;

	////////////////REG_RN_PDU_TX_STATUS////////////////////////////
	typedef struct
	{
		uint16				bf_cnt				: 11;//当前buffer的使用状态
		uint16				rsvd_bit11			: 1;

		uint16				underflow			: 1;///1：报文往网络上送的时候出现错误
		uint16				overflow			: 1;//1：buffer overflow，clr清除

		uint16				model				: 2;


	}REG_RN_PDU_TX_STATUS_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_PDU_TX_STATUS_BIT bit;

	}REG_RN_PDU_TX_STATUS;

////////////////REG_RN_MAIL_TX_CTRL////////////////////////////
	typedef struct
	{
		uint16				clr							: 1;//写1清除所有MAIL_TX_STATUS状态位。
		uint16				rsvd_bit1to10			: 10;

		uint16				mail_req				: 1;//写1表示，请求发送一次mailbox数据
		uint16				rsvd_bit12				: 1;
		uint16				data_valid				: 1;//写1：一个完整报文发已经送至FPGA。

		uint16				rsvd_bit14to15		: 2;


	}REG_RN_MAIL_TX_CTRL_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_MAIL_TX_CTRL_BIT bit;

	}REG_RN_MAIL_TX_CTRL;


////////////////REG_RN_MAIL_TX_STATUS////////////////////////////
	typedef struct
	{
		uint16				rx_bus_arb			: 4;//当前rx bus的总线请求者。当rx_bus_arb最高位为1，是表示当前请求的是mailbox。否则为pdu。正常情况下，rx_bus_arb[2]恒为0

		uint16				rsvd_bit4			: 1;

		uint16				tx_bus_arb			: 2;
		uint16				tx_mail_bus_arb		: 2;
		uint16				tx_mail_req_ing		: 1;//当前通道正在申请tx mailbox总线

		uint16				mail_over			: 1;//1：该报文已经发送至网络。

		uint16				mail_ready			: 1;//1：获得mailbox权限，可以PFGA发送收。
		uint16				underflow			: 1;//1：报文往网络上送的时候出现错误
		uint16				overflow			: 1;//1：buffer overflow，clr清除


		uint16				rx_mail_bus_arb		: 2;//当前rx mailbox总线请求者


	}REG_RN_MAIL_TX_STATUS_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_MAIL_TX_STATUS_BIT bit;

	}REG_RN_MAIL_TX_STATUS;

	////////////////REG_RN_PDU_RX_CTRL////////////////////////////
	typedef struct
	{
		uint16				clr							: 1;//写1清除所有状态位，另外，如果buffer中有报文，则同时清除该报文
		uint16				rd_over					: 1;//

		uint16				rsvd_bit2to15			: 14;


	}REG_RN_PDU_RX_CTRL_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_PDU_RX_CTRL_BIT bit;
	}REG_RN_PDU_RX_CTRL;

	////////////////REG_RN_PDU_RX_STATUS////////////////////////////
	typedef struct
	{
		uint16				bf_cnt				: 11;//当前buffer的使用状态
		//  [4/5/2017 googol]
		uint16				packet_cnt			: 5;//当前buffer中有完整的完整报文个数
	// 	uint16				packet_cnt			: 4;//当前buffer中有完整的完整报文个数
	//
	// 	uint16				rsvd_bit15			: 1;


	}REG_RN_PDU_RX_STATUS_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_PDU_RX_STATUS_BIT bit;

	}REG_RN_PDU_RX_STATUS;

	////////////////REG_RN_MAIL_RX_CTRL////////////////////////////
	typedef struct
	{
		uint16				clr						: 1;//写1清除所有状态位，另外，如果buffer中有报文，则同时清除该报文
		uint16				rd_over				: 1;

		uint16				rsvd_bit2to15		: 14;
	}REG_RN_MAIL_RX_CTRL_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_MAIL_RX_CTRL_BIT bit;

	}REG_RN_MAIL_RX_CTRL;

	////////////////REG_RN_MAIL_RX_STATUS////////////////////////////
	typedef struct
	{
		uint16				rx_mail_valid		: 1;//指示是否有报文等待接收
		uint16				dll_rx_num			: 10;

		uint16				rsvd_bit11to15		: 5;
	}REG_RN_MAIL_RX_STATUS_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_MAIL_RX_STATUS_BIT bit;
	}REG_RN_MAIL_RX_STATUS;

	///////////////NET_VERSION/////////////////////////////
	typedef struct
	{
		uint16				net_version		: 16;

	}REG_RN_NET_VERSION_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_NET_VERSION_BIT bit;
	}REG_RN_NET_VERSION;
	//////////      end luo.mj       ////////////////////
	////////////////REG_RN_ATUO_ID_CTRL/////////////////////////////
	////////////////APP COM WATCH DOG/////////////////////
	typedef struct
	{
		uint8 auto_id_offset		: 8;
		uint8 rsvd_bit8				: 1;
		uint8 auto_id_rst				: 1;
		uint8 offset_model			: 1;
		uint8 auto_id_lock			: 1;
		uint8 auto_id_mode		: 1;
		uint8 rsvd_bit13to14		: 2;
		uint8 auto_id_type			: 1;


	}REG_RN_AUTO_ID_CTRL_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_AUTO_ID_CTRL_BIT bit;
	}REG_RN_AUTO_ID_CTRL;

	typedef struct
	{
		uint8 auto_id_mask		: 8;//wr 0x79 to force auto id. the pdu_en must be 0.
		uint8 rsvd_bit8to15				: 8;


	}REG_RN_AUTO_ID_FORCE_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_AUTO_ID_FORCE_BIT bit;
	}REG_RN_AUTO_ID_FORCE;
	//////////////////////////////////////
	typedef struct
	{
		REG_RN_ONLINE_MSG		m_online_msg;
		//////////////////////////////////////////////////////////////////////////
	}COMMON_NET_STATUS;

	struct FPGA_DMA
	{
		REG_RN_DMA_MAIN_CTRL_STATUS		m_dma_main_ctrl_status;
		REG_RN_DMA_CFG_SET_ADDR			m_dma_cfg_set_addr;
		REG_RN_DMA_CFG_OP_DATA			m_dma_cfg_op_data;
	};

	struct MODAL_CHANGE
	{
		REG_RN_MODAL_CTRL_STATUS		m_modal_ctrl_status;
		REG_RN_SYS_TMIE_L				m_sys_time_l;
		REG_RN_SYS_TMIE_H				m_sys_time_h;
		REG_RN_FAST_NEXT				m_fast_next;
		REG_RN_NORMAL_NEXT				m_normal_next;
		REG_RN_CHANGE_TIME_L			m_change_time_l;
		REG_RN_CHANGE_TIME_H			m_change_time_h;
		REG_RN_MODAL_NOW				m_modal_now;
	};

	//  [6/23/2016 googol]
	////
	//////////////////////INT_MSG////////////////////////////////////////////////////
	typedef struct
	{
		//////////////////////////////////
		uint8				pdu_rx_valid			: 1; //
		uint8				pdu_tx_valid			: 1;
		uint8				mail_rx_valid			: 1; //
		uint8				rsvd_bit3to7			: 5;

		uint8				round_valid				: 1;
		uint8				fine_valid				: 1;
		uint8				rsvd_bit10to15			: 6;

	}REG_NET_INT_MSG_BIT;


	typedef union
	{
		uint16 all;
		REG_NET_INT_MSG_BIT bit;

	}REG_NET_INT_MSG;
	//  [6/23/2016 googol]

	//////////////////////////////

	typedef struct
	{
		uint16 data0;
		uint16 data1;
		uint16 data2;
		uint16 data3;
	}PACKET_HEAD_ALL;

	typedef union
	{
		uint8			des_id				: 8;
		uint8			src_id				: 8;
	}PACKET_HEAD_ID;

	typedef struct
	{
		uint8				checksum			: 8;// this var isn't used in rx/tx packet, except pdu dma cfg
		PACKET_HEAD_ID		id;             //数据源ID/目标ID。

		uint8				len_bit8				: 1;//数据区的数据长度1位
		uint8				des_ch				: 3;//the ch which  访问FPGA DMA通道，user[2:0]必须为0。	user[5:3]根据DSP通道决定。
		uint8				src_ch				: 3;//访问FPGA DMA通道，user[2:0]必须为0。	user[5:3]根据DSP通道决定。
		uint8				rsvd_bit7_a		: 1;//

		uint8				len_low				: 8;//数据区的数据长度低8位
		//////////////////////////////////
		uint8				cmd					: 3;/*cmd=0(LWR):逻辑寻址写
															cmd=1(AWR):绝对寻址写
															cmd=2(LMWR):逻辑地址映射区寻址写
															cmd=3(TCWR):报文发送配置区寻址写
															cmd=4(LRD):逻辑寻址读
															cmd=5(ARD):绝对寻址读
															cmd=6(LMRD):逻辑地址映射区寻址读
															cmd=7(TCRD):报文发送配置区寻址读*/
		uint8				delta					: 1;//delta[0:0]DMA访问地址增量值 0：每次访问同一个地址；	1：每次访问都累加1
		uint8				resp_req			: 1;//resp_req =0:不需要返回应答。	resp_req =1:需要返回应答。当cmd=4,5,6,7,resp_req必须为1.
		uint8				resp					: 1;//
		uint8				num_bit8			: 1;//
		uint8				resp_ok				: 1;//

		uint8				num_low			: 8;//DMA寻址次数
		uint16			start_addr;             //DMA启动地址
	}PACKET_HEAD_BIT;

		typedef union
		{
			PACKET_HEAD_ALL all;
			PACKET_HEAD_BIT bit;
		}RN_PACKET_HEAD;

		typedef struct
		{
			uint8		packet_type; //
			// 								RN_PACKET_TX_MAIL_RD	0
			// 								RN_PACKET_TX_MAIL_WR	1
			//
			// 								RN_PACKET_RX_MAIL_WR	2
			// 								RN_PACKET_RX_MAIL_WR	3
			//
			// 								RN_PACKET_TX_PDU_WR		1
			// 								RN_PACKET_RX_PDU_WR		2

			RN_PACKET_HEAD* pHead;
			uint16		length;
			uint8		pData[512];
		}RN_PACKET;
	////////////////PDU DMA/////////////////////
		typedef struct
		{
			//////////////////////////////////
			uint8				rd_en				: 1; // this bit must be 1 now

			uint8				rd_delta				: 1; //
			uint8				rd_cmd				: 2; //
			uint8				rsvd_bit4			: 1;
			uint8				rd_num_src		: 1;// 0 decide by inner, 1: by outside
			uint8				rd_num_bit8		: 1;
			uint8				rsvd_bit7			: 1;

			uint8				rd_num_low		: 8;
			uint16			rd_start_addr;
		}RN_PACKET_PDU_DMA_CFG_HEAD_BIT;

		typedef union
		{
			uint32 data0;
			RN_PACKET_PDU_DMA_CFG_HEAD_BIT bit;
		}RN_PACKET_PDU_DMA_CFG_HEAD;

		typedef struct
		{
			RN_PACKET_PDU_DMA_CFG_HEAD dma_cfg_head;
			RN_PACKET_HEAD packet_head;
		}RN_PACKET_PDU_DMA_CFG;

		//////////////////////DMA_CFG_EXT////////////////////////////////////////////////////
		typedef struct
		{
			//////////////////////////////////
			uint32				int_id_sel			: 3; //
			uint32				rsvd_bit3to31			: 29;
		}RN_DMA_CFG_EXT_BIT;


		typedef union
		{
			uint16 all;
			RN_DMA_CFG_EXT_BIT bit;

		}RN_DMA_CFG_EXT;
	////////////////APP COM SAFE CTRL/////////////////////
	typedef struct
	{
		//////////////////////////////////
		uint8				station				: 8;

		uint8				rsvd0				: 5; //
		uint8				safe_self_clr_en : 1;

		uint8				safe_status_clr		: 1; //write 1 to clear the status
		uint8				safe_en				: 1;
	}REG_RN_SAFE_CTRL_BIT;

	typedef union
	{
		uint16 all;
		REG_RN_SAFE_CTRL_BIT bit;
	}REG_RN_SAFE_CTRL;
	////////////////APP COM WATCH DOG/////////////////////
	typedef struct
	{
		//////////////////////////////////
		uint16 watch_dog		: 16; //0：0ns无效, 1: 0~131072ns。 2：131072~131072*2ns  ,以131072ns位单位。默认100.
	}REG_RN_SAFE_WATCH_DOG;

#endif /* STDEFRINGNETREG_H_ */
