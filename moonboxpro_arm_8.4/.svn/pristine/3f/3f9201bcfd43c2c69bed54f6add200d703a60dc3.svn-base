/*
 * StFileOp.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#include "stdafx.h"
#include "StFileOp.h"

#include "type_def.h"
#include "StRingNet.h"
#include "gt_rtn_def.h"

void CLPBYTEListCreate(CLPBYTEList* pList)
{
	pList->m_pData = NULL;
	pList->m_param_num = 0;
	pList->m_use_len = 0;
};

int16 CGetList(CLPBYTEList* pList, StFunction* param, char* pData)
{
	int32 i;
	pList->m_use_len = 0;
	if(param == NULL)
	{
		return 0;
	}
	if(param->m_param_num == 0)
	{
		return 0;
	}
	if(pData == NULL)
	{
		return 0;
	}
	//		printf(("m_list = new StFnSubParam[param->m_param_num] !\n"));
	if(param->m_param_num > MAX_FN_SUB_PARAM_NUM)
	{
		return RTN_ARRAY_SPACE_ERR;
	}
	//pList->m_list = new StFnSubParam[param->m_param_num];

	pList->m_list[0].m_size = *((uint16*)pData);
	pList->m_list[0].m_pData = pData+sizeof(uint16);
	pList->m_use_len = pList->m_use_len + sizeof(uint16) + pList->m_list[0].m_size;

	pList->m_param_num = param->m_param_num;
	pList->m_pData = pData;

	for (i = 1; i < param->m_param_num; i++)
	{
		pList->m_list[i].m_size = *((uint16*)(pList->m_list[i-1].m_pData+pList->m_list[i-1].m_size));
		pList->m_list[i].m_pData = (pList->m_list[i-1].m_pData + pList->m_list[i-1].m_size+sizeof(uint16));
		pList->m_use_len = pList->m_use_len + sizeof(uint16) + pList->m_list[i].m_size;
	}
	return 0;
};
int16 CClearPData(CLPBYTEList* pList, char* pData)
{
	pList->m_pData = pData;
	pList->m_use_len = 0;
	pList->m_param_num = 0;
	return 0;
}
int16 CAddParam(CLPBYTEList* pList, uint16 len, char* pData)
{
	pList->m_param_num++;
	pList->m_use_len +=sizeof(uint16);
	*((uint16*)pList->m_pData) = len;
	pList->m_pData = pList->m_pData + 2;

	pList->m_use_len +=len;
	memcpy(pList->m_pData, pData, len);
	pList->m_pData = pList->m_pData + len;
	return 0;
}
int16 CSetStFunction(CLPBYTEList* pList, StFunction* param)
{
	param->m_len =  pList->m_use_len;
	param->m_param_num = pList->m_param_num;
	return 0;
};
void CLPBYTEListDelete(CLPBYTEList* pList)
{
	pList->m_pData = NULL;
	pList->m_param_num = 0;
	pList->m_use_len = 0;
	pList->m_param_num =0;
};

int16 StFnProcess(LPVOID lp, uint16 data_size_in, void* pData, uint16* data_size_out)
{
	int16 rtn = RTN_FILE_FUNCTION_ID_MISMACH ;
	char* m_pData = (char*) pData;
	if (data_size_in < sizeof(uint16)*4)
	{
		return RTN_FILE_PARAM_ERR;
	}
	StFunction* pFn = (StFunction*)m_pData;
	m_pData = m_pData+sizeof(uint16)*4;//sizeof(StFunction);

	switch(pFn->m_id)
	{
	case FN_SYS_RESET:
//		rtn = Fn_Real_SysReset(lp,pFn, m_pData);
		break;
	case FN_GetDllVersion:
		rtn = Fn_Real_GetDllVersion(lp,pFn, m_pData);
		break;
	case FN_GeneralKesaiCmd:
		rtn = Fn_Read_GeneralKesaiCmd(lp,pFn, m_pData);
		break;
	default:
		{
			rtn =  RTN_PARAM_ERR;
			break;
		}
	}
	*data_size_out = pFn->m_len + sizeof(uint16)*4;
	return rtn;
}

//////////////////////////////////////////////////////////////////////////
int16 Fn_Real_GetDllVersion(LPVOID lp, StFunction* param, char* pData)
{
	if (param->m_param_num != 1)
	{
		return RTN_PARAM_ERR;
	}

	CLPBYTEList param_list;
	CGetList(&param_list, param,pData);
	if (param_list.m_use_len > param->m_len)
	{
		return RTN_PARAM_ERR;
	}
	uint16 dll_type = *(uint8*)(param_list.m_list[0].m_pData);
	//memcpy(&dll_type, param_list.m_list[0].m_pData, sizeof(dll_type));
	StVersion version;
	if (dll_type == 0)
	{
		param->m_rtn = RingNetVersion(&version);
	}
	else
	{
		param->m_rtn = (uint16)RTN_PARAM_ERR;
	}

	CClearPData(&param_list, pData);
	CAddParam(&param_list, sizeof(version), (char*)&version);
	CSetStFunction(&param_list, param);

	return RTN_SUCCESS;
}

int16 RingNetGeneralKesaiCmd(StRingNet* pRingNet, TPci* pTPci);
int16 Fn_Read_GeneralKesaiCmd(LPVOID lp, StFunction* param, char* pData)
{
	StRingNet* pRingNet = (StRingNet*)lp;
	TPci pci;
	if (param->m_param_num != 1)
	{
		return RTN_PARAM_ERR;
	}

	CLPBYTEList param_list;
	CGetList(&param_list, param,pData);
	if (param_list.m_use_len > param->m_len)
	{
		return RTN_PARAM_ERR;
	}

	memcpy(&pci, param_list.m_list[0].m_pData, param_list.m_use_len);

	param->m_rtn = RingNetGeneralKesaiCmd(pRingNet, &pci);


	CClearPData(&param_list, pData);
	CAddParam(&param_list, (pci.len+3)*sizeof(short), (char*)&pci);
	CSetStFunction(&param_list, param);

	return RTN_SUCCESS;
}
