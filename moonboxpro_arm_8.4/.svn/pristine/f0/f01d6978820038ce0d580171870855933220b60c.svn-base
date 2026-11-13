/*
 * sys.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */
#include "sys.h"

//THUMB指令不支持汇编内联
//采用如下方法实现执行汇编指令WFI
void WFI_SET(void)
{
	__asm volatile("WFI");
}
//关闭所有中断(但是不包括fault和NMI中断)
void INTX_DISABLE(void)
{
	__asm volatile("CPSID   I");
	__asm volatile("BX      LR");
}
//开启所有中断
void INTX_ENABLE(void)
{
	__asm volatile("CPSIE   I");
	__asm volatile("BX      LR");
}
//设置栈顶地址
//addr:栈顶地址
void MSR_MSP(uint32_t addr)
{
	__asm volatile("MSR MSP, r0 ");			//set Main Stack value
	__asm volatile("BX r14");
}
