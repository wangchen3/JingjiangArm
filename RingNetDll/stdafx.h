/*
 * stdafx.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */
#ifndef STDAFX_H_
#define STDAFX_H_

#pragma once
//#include "core_cmFunc.h"
//#include "targetver.h"
#include "stm32f4xx.h"
#include "string.h"

//#include <stdio.h>
//#include <tchar.h>
//void memcpy(void* a,  const void* b, short num);
#define RETAILMSG(cond,printf_exp)
#define _ENTER_CRITICAL_SECTION(a)   { __disable_irq();}
#define _EXIT_CTRITCAL_SECTION(a)  { __enable_irq();}

#endif /* STDAFX_H_ */
