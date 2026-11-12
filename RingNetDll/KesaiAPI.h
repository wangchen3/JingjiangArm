/*
 * KesaiAPI.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef KESAIAPI_H_
#define KESAIAPI_H_

#pragma once

#include "gt_rn_struct_driver.h"
#include "gt_rn_struct_motion.h"
#include "gt_rn_struct.h"

#ifndef GTD_API
#define GTD_API short
#endif

/*
问题：
1、采样参数设置到FPGA方式不同。这个需要慎重考虑实现。
2、采样模块地址偏移量是否太大了，需要调整。
3、Getlocalinf函数是否需要支持
4、ARM的实现架构：外部中断+多个定时处理+后台处理？
*/

//////////////////////////////////////
//保留原运控打开PCI设备

GTD_API GTD_Open(unsigned long pAddr);
////////////////////////////
GTD_API GT_RN_GetVersion(char** msg);
//used the function to rd the station id ,
//if the statio is 0 < idf < 0xf0.
//then the station is valid. otherwise, keep waiting.
GTD_API GT_RN_GetLocalID(unsigned char* id);
//////////////网络初始化相关函数////////////////////////////////////////////////////////////
////////////////////pc to pc com//////////////////////////////////////////////////////
GTD_API GT_RN_DevicePcMailComWr(unsigned long* pData, unsigned char station_id, unsigned short start_addr, unsigned short dword_num, unsigned char cmd_type, unsigned char resp_req);
GTD_API GT_RN_DevicePcMailComRd(unsigned long* pData, unsigned char station_id, unsigned short start_addr, unsigned short dword_num, unsigned char cmd_type);
GTD_API GT_RN_DeviceLocalPcRamWr(unsigned long* pData, unsigned short start_addr, unsigned short dword_num);
GTD_API GT_RN_DeviceLocalPcRamRd(unsigned long* pData, unsigned short start_addr, unsigned short dword_num);
/////////////////PC和FPGA高速交互//////////////////////////////////////////////////////////
GTD_API GT_RN_UserPCWrNetFPGA(unsigned long* pData, unsigned char des_id, unsigned char src_id, unsigned short start_addr, unsigned short dword_num);
GTD_API GT_RN_UserPCRdLocalFPGA(unsigned long* pData, unsigned char des_id, unsigned short start_addr, unsigned short dword_num);

/////////////////////////////////////
GTD_API GT_RN_MailRdMultReg(unsigned short addr, unsigned short* data,unsigned short data_num, unsigned char data_mode, unsigned char des_id);
GTD_API GT_RN_MailWrMultReg(unsigned short addr, unsigned short* data, unsigned short data_num, unsigned char data_mode,unsigned char des_id);
GTD_API GT_RN_PCWatchCom(unsigned short* pData,unsigned short word_num);
//////////////////sample////////////////////////////////////////////////////////
GTD_API GT_RN_SampleInitialCfg(unsigned char* station_id, unsigned char hmi_num);
GTD_API GT_RN_SampleSetSampleParam(StSampleParam* param, short* cfg_data);
//刷新采样参数
GTD_API GTD_SampleParamUpda(short axis, short *cfg_data);
GTD_API GT_RN_SampleGetRoundData(void** ch_a,void** ch_b, short* flag);
GTD_API GT_RN_SampleRoundUpdata(void);
GTD_API GT_RN_SampleGetFineData(void* ch_a,void* ch_b,short* flag);
GTD_API GT_RN_SampleGetStatus(StSampleStatus* status);
GTD_API GT_RN_SampleSetLocalShowDeviceId(unsigned char station_id);
GTD_API GT_RN_SampleSetRemoteRdEnable(unsigned char station_id, long enble);
GTD_API GT_RN_SetSenceDO(unsigned short gpo_set);
/////////////
//FPGA WRITE READ
GTD_API GT_RN_WriteFPGA(unsigned short byte_addr, unsigned short* pData);
GTD_API GT_RN_ReadFPGA(unsigned short byte_addr, unsigned short* pData);

//2025.6.11.083328同步
//2024.12.07.95924 /wei.n/欧诺油墨盘升降功能
GTD_API GT_RN_SetPulseParam(unsigned short* pData);
GTD_API GT_RN_GetPulseParam(unsigned short* pData);

#endif /* KESAIAPI_H_ */
