/*
 * PCIOperate.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef PCIOPERATE_H_
#define PCIOPERATE_H_

#pragma once

#include "type_def.h"
#include "gt_rn_struct_private.h"

#define PciReadData16(stPci, offset, pBuf) 	*pBuf = ((volatile uint16*)stPci.baseAddr)[offset]
#define PciReadData(stPci, offset, pBuf)  	*pBuf = ((volatile uint32*)stPci.baseAddr)[offset]
#define PciWriteData(stPci, offset, pBuf) 	((volatile uint32*)stPci.baseAddr)[offset] = pBuf
#define PciWriteData16(stPci, offset, pBuf)	((volatile uint16*)stPci.baseAddr)[offset] = pBuf

#endif /* PCIOPERATE_H_ */
