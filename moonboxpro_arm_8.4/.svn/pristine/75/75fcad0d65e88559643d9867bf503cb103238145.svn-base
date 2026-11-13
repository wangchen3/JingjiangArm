/*
 * gt_rtn_def.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef GT_RTN_DEF_H_
#define GT_RTN_DEF_H_

#pragma once

#define CMD_SUCCESS                     0

#define CMD_ERROR_READ_LEN             -2    /* 读取数据长度错误 */
#define CMD_ERROR_READ_CHECKSUM        -3    /* 读取数据校验和错误 */

#define CMD_ERROR_WRITE_BLOCK          -4    /* 写入数据块错误 */
#define CMD_ERROR_READ_BLOCK           -5    /* 读取数据块错误 */

#define CMD_ERROR_OPEN                 -6    /* 打开设备错误 */
#define CMD_ERROR_CLOSE                -6    /* 关闭设备错误 */
#define CMD_ERROR_DSP_BUSY             -7    /* DSP忙 */

#define CMD_LOCK_ERROR                 -8    /*多线程资源忙*/

#define CMD_ERROR_EXECUTE               1
#define CMD_ERROR_VERSION_NOT_MATCH     3
#define CMD_ERROR_PARAMETER             7
#define CMD_ERROR_UNKNOWN               8    /* 不支持的指令 */

#define CMD_PARAMETER_REPAIR            9

#define RTN_SUCCESS						0
#define RTN_MALLOC_FAIL					-100 /* malloc memory fail */
#define RTN_FREE_FAIL					-101 /* free memory or delete the object fail */
#define RTN_NULL_POINT					-102 /* the param point input is null */
#define RTN_ERR_ORDER					-103 /* call the function order is wrong, some msg isn't validable */
#define RTN_PCI_NULL					-104 /* the pci address is empty, can't access the pci device*/
#define RTN_PARAM_OVERFLOW				-105 /* the param input is too larget*/
#define RTN_LINK_FAIL					-106 /* the two ports both link fail*/
#define RTN_IMPOSSIBLE_ERR				-107 /* it means the system or same function work wrong*/
#define RTN_TOPOLOGY_CONFLICT			-108 /* the id conflict*/
#define RTN_TOPOLOGY_ABNORMAL			-109 /* scan the net abnormal*/
#define RTN_STATION_ALONE				-110 /* the device no id, it means the device id is 0xF0 */
#define RTN_WAIT_OBJECT_OVERTIME		-111 /* multi thread wait for object overtime */
#define RTN_ACCESS_OVERFLOW				-112 /* data[i];  i is larger than the define */
#define RTN_NO_STATION					-113 /* the station accessed not existent */
#define RTN_OBJECT_UNCREATED			-114 /* the object not created yet*/
#define RTN_PARAM_ERR					-115 /* the param input is wrong*/
#define RTN_PDU_CFG_ERR                 -116/*Pdu DMA Cfg Err*/
#define RTN_PCI_FPGA_ERR				-117 /*PCI op err or FPGA op err*/
#define RTN_CHECK_RW_ERR				-118	/*data write to reg, then rd out, and check err */
#define RTN_REMOTE_UNEABLE				-119 /*the device which will be ctrl by net can't be ctrl by net function*/

#define RTN_NET_REQ_DATA_NUM_ZERO		-120 /*mail op or pdu op req data num can't be 0*/
#define RTN_WAIT_NET_OBJECT_OVERTIME	-121 /* net op multi thread wait for object overtime */
#define RTN_WAIT_NET_RESP_OVERTIME		-122 /* Can't wait for resp */
#define RTN_WAIT_NET_RESP_ERR			-123 /*wait mailbox op err*/
#define RTN_INITIAL_ERR					-124 /*initial the device err*/
#define RTN_PC_NO_READY					-125 /*find the station'pc isn't work*/
#define RTN_STATION_NO_EXIST			-126
#define RTN_MASTER_FUNCTION				-127 /* this funciton only used by master */

#define RTN_NOT_ALL_RETURN							-128 /* the GT_RN_PtProcessData funciton fail return */
#define RTN_NUM_NOT_EQUAL							-129 /* the station number of RingNet do not equal  the station number of CFG */

#define RTN_CHECK_STATION_ONLINE_NUM_ERR		-130/*Check 模式下没有检测到站点*/
#define RTN_FILE_NULL_POINT							131 /*文件指针空*/
#define RTN_FILE_ERR_OPEN						-131/*文件打开失败*/
#define	RTN_FILE_OPEN_ERR						RTN_FILE_ERR_OPEN	////文件打开失败
#define RTN_FILE_ERR_FORMAT						-132/*文件解析出错*/
#define RTN_FILE_ERR_MISSMATCH					-133/*文件信息跟实际信息不匹配*/
#define RTN_DMALIST_ERR_MISSMATCH				-134/*在生成的DMA配置信息中没找到相应的站点*/

#define RTN_CHECK_NUM_ZERO						-135/*Check 模式下给的站点个数为0*/
#define RTN_INPUT_ERR_MISSMATCH				-136/*输入信息跟实际信息不匹配*/
#define RTN_FILE_ERR_IFO								-137/*文件内容不对*/
#define RTN_MAIN_STATION_NO_PROCESS		-138/*多组情况配置文件中主站点类型不是带处理器的站点*/

#define RTN_NO_PROCESS								-139/* 网络中没有带处理器的站点*/

#define RTN_GROUP_NO_MAIN_STATION			130/*多组情况下某一组中没有主站点*/
#define RTN_SECONDARY_CTRL_FAIL					131/*从站不支持次主功能，或者次主功能使能失败*/

#define RTN_DEVICENUM_ERR							-140/*机器人类的控制器只扫描到一个站点 */
#define RTN_DEVICENUM_NO_SAME					-141/*机器人类的控制器两次扫描到的站点数不一致 */
#define RTN_STATION_ID_INVALID					-142/*网络中存在站号为0xF0等非法设备*/

#define RTN_REQUSET_MAIL_BUS_OVERTIME		-150 /*Requset Mail Bus Err*/
#define RTN_INSTRCTION_ERR							-151 /*instrctions err*/
#define RTN_MAIL_RESP_REQ_ERR						-152 /*RN_MailRespReq  err*/
#define RTN_CTRL_SRC_ERR								-153 /* the controlled source  is error */
#define RTN_PACKET_ERR									-154 /*packet is error*/
#define RTN_STATION_ID_ERR							-155 /*the device id is not in the right rang*/
#define RTN_WAIT_NET_PDU_RESP_OVERTIME	- 156 /*net pdu op wait overtime*/
#define RTN_ETHCAT_ENC_POS_ERR					-157/**/
#define RTN_STATION_NUN_OVERFLOW		-158
#define RTN_DMA_NUM_OVERFLOW				-159
#define RTN_THREAD_CREATE_FAIL						-170 /* thread create fail*/

#define RTN_IDLINK_PACKET_ERR				-200 /*ilink master  decode err! packet_length is not match*/
#define RTN_IDLINK_PACKET_END_ERR		-201 /* the ending of ilink packet is not 0xFF*/
#define RTN_IDLINK_TYPER_ERR					-202 /* the type of ilink module is error*/
#define RTN_IDLINK_LOST_CNT 					-203 /* the ilink module has lost connection*/
#define RTN_IDLINK_CTRL_SRC_ERR			-204 /* the controlled source of ilink module is error */
#define RTN_IDLINK_UPDATA_ERR				-205 /* the ilink module updata error*/
#define RTN_IDLINK_NUM_ERR					-206 /* the ilink num larger the IDLINK_MAX_NUM(30) */
#define RTN_IDLINK_NUM_ZERO					-207 /* the ilink num is zero */

#define RTN_IDLINK_CHECK_ID_ERR			-208 /* the ilink set is not checked or check fail */
#define RTN_IDLINK_EHMI_ERR					-209/*非EHMI模块调用EHMI函数*/
//#define RTN_IDLINK_CTRL_SRC_ERR			-210/*iLink控制权不对*/

#define RTN_MUTLI_SRC_ERR					-220/*该函数只支持多主情况*/

#define RTN_ERROR_INF_FAIL					-230/*初始化返回值函数压数据失败*/
#define RTN_ERROR_INF_NULL					-231/*返回值中没有该值*/
#define RTN_LOAD_MOTION_ERROR         -232    /*等环网口调试库加载失败*/

#define RTN_NO_PACKET							301 /* no valid packet */
#define RTN_RX_ERR_PDU_PACKET				-302 /* ERR PDU PACKET */
#define RTN_STATE_MECHINE_ERR				-303
#define RTN_PCI_DSP_UN_FINISH				304
#define RTN_SEND_ALL_FAIL						-305
#define RTN_STATION_CLOSE					310
#define RTN_STATION_RESP_FAIL				311

#define RTN_UPDATA_MODAL_ERR			-330 /* update the modal in normal way fail*/
#define RTN_UPDATA_CPLD_CMP_ERR		-331 /* update the CPLD compare err*/

#define RTN_NO_MAIL_DATA						340 /*There is no mail data*/
#define RTN_NO_PDU_DATA						341 /*There is no pdu data*/

#define	RTN_VERSION_ERR_RN		-400	//	gt_rn.dll版本不对
#define	RTN_VERSION_ERR_GTS		-401	//	gts.dll版本不对
#define	RTN_VERSION_ERR_DMA		-402	//	dma的配置文件版本不对
#define	RTN_VERSION_ERR_MAP		-403	//	map的配置文件版本不对
#define	RTN_VERSION_ERR_FPGA	-404	//	FPGA固件版本不对
#define	RTN_VERSION_ERR_DSP		-405	//	DSP固件版本不对
#define	RTN_VERSION_ERR_CPLD	-406	//	CPLD固件版本版本不对
#define	RTN_VERSION_ERR_FILE	-407	//	加载的文件与所需文件不匹配


#define	RTN_SYNC_CYLE_LARGE		-410	//	配置的同步周期大于库支持的同步周期
#define	RTN_SYNC_CYLE_ERR		-411	//	网络中有的模块不支持同步周期设置为500微秒
#define	RTN_SYNC_CYLE_READ_ERR	-412	//	读到的同步周期超过了固件支持的值

#define	RTN_VERSION_WARING_RN	400	//gt_rn.dll版本不是最新
#define	RTN_VERSION_WARING_GTS	401	//gts.dll版本不是最新
#define	RTN_VERSION_WARING_DMA	402	//dma的配置文件版本不是最新
#define	RTN_VERSION_WARING_MAP	403	//map的配置文件版本不是最新
#define	RTN_VERSION_WARING_FPGA	404	//FPGA固件版本不是最新
#define	RTN_VERSION_WARING_DSP	405	//DSP固件版本不是最新
#define	RTN_VERSION_WARING_CPLD	406	//CPLD固件版本版本不是最新

#define RTN_FILE_PARAM_NUM_ERR					-500
#define RTN_FILE_PARAM_LEN_ERR					-501
#define RTN_FILE_MALLOC_FAIL					-502
#define RTN_FILE_FREE_FAIL						-503
#define RTN_FILE_PARAM_ERR						-504
#define RTN_FILE_NOT_EXSITS						505

#define RTN_FILE_CREATE_FAIL					510
#define RTN_FILE_DELETE_FAIL					511
#define RTN_FIFE_CRC_CHECK_ERR					-512
#define RTN_FILE_FORMAT_ERR						-513

#define RTN_FIFE_FUNCTION_ID_RETURN_ERR			-600
#define RTN_FILE_OP_BUSY					-601 /*the FILE OP is busy*/
#define RTN_FILE_OP_WRONG_ORDER - 602
#define RTN_FILE_PARAM_MISMACH	 -603
#define RTN_FILE_FUNCTION_ID_MISMACH	 -604

#define RTN_UPDATE_WAIT_OVERTIME				-700
#define RTN_UPDATE_FPGA_OP_ERR					-701
#define RTN_UPDATE_CAMPARE_ERR					-702

#define RTN_DLL_WINCE									-800
#define RTN_DLL_WIN32									-801

#define RTN_XML_STATION_ERR						-900//dma配置文件和站点类型不匹配

//---MULTI_PROCESS_ERR_RETURN--BEGIN//
/*#define RTN													-1000*/
#define RTN_MULTI_PROCESS_CHECK_BUSY	1001
#define RTN_MULTI_PROCESS_CHECK_FAIL		-1001
#define RTN_PC_RD_UPDATA_FAIL				1002

#define RTN_ST_SYS_CHECK_ERR						-1002
#define	RTN_ST_SYS_UPDATA_ERR					-1003
#define RTN_WAIT_STATE_TIMEOUT				-1004
#define RTN_ST_SYS_CHECH_ORDER_ERR		-1005
#define RTN_ST_SYS_CHECH_RESET_ING			-1006
#define	RTN_CHECK_GO_ON							1004
#define RTN_MASTER_NOT_EXSIT					-1010
//---MULTI_PROCESS_ERR_RETURN--END//

#define		RTN_SERVO_EXECUTE_FAIL  -1100//;							// 命令执行失败
#define		RTN_SERVO_EXECUTE_SUCCESS  -1101//;							// 命令执行成功
#define		RTN_SERVO_PARAMETER_INVALID  -1102//;							// 无效参数
#define		RTN_SERVO_INSTRUCTION_INVALID  -1103//;							// 非法指令
#define		RTN_SERVO_OTHER_ERR						-1104

#define RTN_ARRAY_SPACE_ERR  -1200 //输入的数据存储空间不满足要求
#define RTN_INDEX_ORDER_ERR  -1201 //index order err
//////////////////////////////////////////////////////////////////////////
//-PCI COＭ ERR
#define RTN_PCI_CMD_ERROR_WRITE_BLOCK -1404
#define RTN_PCI_CMD_ERROR_READ_BLOCK -1405
#define RTN_PCI_COMMUNICATE_ERROR   -1401

#endif /* GT_RTN_DEF_H_ */
