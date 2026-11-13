/*
 * StFileOp.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef STFILEOP_H_
#define STFILEOP_H_

#pragma once


#include "stdafx.h"
#include "type_def.h"
#include "gt_rn_struct.h"

#define FN_PARAM_TYPE 0
#define FN_FILEOP_TYPE 1

#define FN_SYS_RESET					0x001
#define FN_GetDllVersion				0x002
#define FN_GeneralKesaiCmd				0x008

#define FN_FileOpFileOpen			100
#define FN_FileOpFileClose			101
#define FN_FileOpFileWrite			102
#define FN_FileOpFileRead			103
#define FN_FileOpFileCheckExsits	104
#define FN_FileOpFileDelete			105

#define FN_FileOpDirctoryCreate		106
#define FN_FileOpDirctoryDelete		107
#define FN_FileOpGetCrcResult		108

//////////////////////////////////////////////
#define FN_FileOpSetLockStatus		110
#define FN_FileOpFileSendResult		111

#define FN_FileOpFileReadReq		114
#define FN_FileOpFolderReadReq		115
#define FN_FileOpCtrlCfg			200

#define FN_TopologyWriteDeviceMsg	0x300
#define FN_TopologyReadDeviceMsg	0x301
#define FN_TopologyWriteCoreIDMsg	0x302
#define FN_TopologyReadCoreIDMsg	0x303
#define FN_TopologyWriteComRamMsg	0x304
#define FN_TopologyReadComRamMsg	0x305

#define FN_TopologySetStateMachine 	0x306
#define FN_TopologyGetStateMachine	0x307

#define FILE_LOCK_RESP_IDLE 0
#define FILE_LOCK_RESP_ING 1
#define FILE_LOCK_RESP_SEND_FIFE 2
#define FILE_LOCK_RESP_SEND_FOLDER 3
#define FILE_LOCK_RESP_OVER 5

#define FILE_LOCK_REQ_IDLE 0x10
#define FILE_LOCK_REQ_WAIT_RESULT 0x14
#define FILE_LOCK_REQ_OVER 0x15

#define GEN_KESAI_UPDATE_ENALBE 		0x100

#define GEN_KESAI_SAMPLE_UPDATE			0x102
#define GEN_KESAI_SET_SENCE_DO			0x103
#define GEN_KESAI_GET_VIRTUAL_STATUS 	0x104

typedef struct
{
	uint16 m_id;//函数ID
	uint16 m_rtn;//函数返回值
	uint16 m_param_num;//函数参数个数
	uint16 m_len;//数据长度
	uint8* m_pData;//数据指针
}StFunction;

typedef struct
{
	uint16 m_size;
	int16 revd0[3];
	char* m_pData;
}StFnSubParam;

//////////////////////////////////////////////////////////////////////////
#define MAX_FN_SUB_PARAM_NUM (8)
typedef struct
{
	StFnSubParam m_list[MAX_FN_SUB_PARAM_NUM];
	char*	m_pData;
	uint16 m_use_len;
	uint16 m_param_num;

}CLPBYTEList;
void CLPBYTEListCreate(CLPBYTEList* pList);
int16 CGetList(CLPBYTEList* pList, StFunction* param, char* pData);
int16 CClearPData(CLPBYTEList* pList, char* pData);
int16 CAddParam(CLPBYTEList* pList, uint16 len, char* pData);
int16 CSetStFunction(CLPBYTEList* pList, StFunction* param);
void CLPBYTEListDelete(CLPBYTEList* pList);

//////////////////////////////////////////////////////////////////////////
int16 StFnProcess(LPVOID lp, uint16 data_size_in, void* pData, uint16* data_size_out);
//////////////////////////////////////////////////////////////////////////
int16 RingNetFuctionDriver(LPVOID lp , StFunction* param, uint8 station_id, int32 resp_req);
//////////////////////////////////////////////////////////////////////////
int16 Fn_Real_GetDllVersion(LPVOID lp, StFunction* param, char* pData);
int16 Fn_Read_GeneralKesaiCmd(LPVOID lp, StFunction* param, char* pData);
//////////////////////////////////////////////////////////////////////////
int16 RingNetVersion(StVersion* dllVersion);
int16 RingNetGetVersion(char** msg);

#endif /* STFILEOP_H_ */
