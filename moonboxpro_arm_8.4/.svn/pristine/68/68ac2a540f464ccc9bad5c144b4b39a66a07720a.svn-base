/*
 * StPCComRam.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef STPCCOMRAM_H_
#define STPCCOMRAM_H_

#pragma once

#include "type_def.h"
#define PC_RAM_SIZE (1<<13)
typedef struct
{
	uint16 m_sem;
	uint8 m_pData[PC_RAM_SIZE];
	uint16 m_size;

}StPCComRam;

int16 PCComRamCreate(StPCComRam* pData);
int16 PCComRamDelete(StPCComRam* pData);
int16 PCComRamRst(StPCComRam* pData);
int16 PCComRamMalloc(StPCComRam* pData, uint16 size);
int16 PCComRamRd(StPCComRam* pRam, uint8* pData, uint16 addr, uint16 num);
int16 PCComRamWr(StPCComRam* pRam, uint8* pData, uint16 addr, uint16 num);

#endif /* STPCCOMRAM_H_ */
