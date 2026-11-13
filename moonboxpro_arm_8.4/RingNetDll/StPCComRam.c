/*
 * StPCComRam.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#include "stdafx.h"
#include "gt_rtn_def.h"
#include "StPCComRam.h"
// #include "cmsis_gcc.h"

int16 PCComRamCreate(StPCComRam* pData)
{
	pData->m_sem = 0;
	pData->	m_size = 0;
	return RTN_SUCCESS;
}
int16 PCComRamDelete(StPCComRam* pData)
{
	pData->m_size = 0;
	return RTN_SUCCESS;
}

int16 PCComRamRst(StPCComRam* pData)
{
	return RTN_SUCCESS;
}

int16 PCComRamMalloc(StPCComRam* pData, uint16 size)
{
	uint16 i;
	pData->m_size = size;
	for (i = 0; i < size; i++)
	{
		pData->m_pData[i] = 0;
	}

	return RTN_SUCCESS;
}

int16 PCComRamRd(StPCComRam* pRam, uint8* pData, uint16 addr, uint16 num)
{
	const int32 MAX = 10000;
	int32 i = 0;

	if(i == MAX) return RTN_WAIT_OBJECT_OVERTIME;
	if(addr+num>=pRam->m_size)
	{
		return RTN_ACCESS_OVERFLOW;
	}
	_ENTER_CRITICAL_SECTION(&pRam->m_sem);
	memcpy(pData, (const void*)((lpoint)(pRam->m_pData)+addr), num);
	_EXIT_CTRITCAL_SECTION(&pRam->m_sem);
	return RTN_SUCCESS;

}

int16 PCComRamWr(StPCComRam* pRam, uint8* pData, uint16 addr, uint16 num)
{
	if(addr+num>=pRam->m_size)
	{
		return RTN_ACCESS_OVERFLOW;
	}
	// _ENTER_CRITICAL_SECTION(&pRam->m_sem);
	__disable_irq();
	memcpy((void*)((lpoint)(pRam->m_pData)+addr), pData, num);
	_EXIT_CTRITCAL_SECTION(&pRam->m_sem);
	return RTN_SUCCESS;
}

