/*
 * led.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#include "led.h"
#include "main.h"

void MX_LED_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();   //使能GPIOC时钟

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_0|GPIO_PIN_1, GPIO_PIN_SET); // 默认PC0、PC1电平为高电平

  //GPIOC0,C1初始化设置
  GPIO_InitStruct.Pin = GPIO_PIN_0 | GPIO_PIN_1;      // LED对应引脚
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;         //推完输出模式
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;       //高速
  GPIO_InitStruct.Pull = GPIO_NOPULL;			      //上拉
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);              //初始化
}
