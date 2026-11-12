/*
 * bin_upgrade.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef BIN_UPGRADE_H_
#define BIN_UPGRADE_H_

#include "flash.h"

#define SOFT_VERSION 0x12

#define STAT_INIT        0xFFFF
#define STAT_RUN         0x0000
#define STAT_RUN_BEFORE  0xF00F //upgrade finish,before enter code
#define STAT_UPGRADE     0x5AA5

#define FRAME_HEAD 0xf0f0
#define FRAME_CRC 0X06

#define BIN_STORE_BASE_ADDR USER_CODE_ADDRESS_1

#define HTONS(x) ((((x)>>8)&0xff)|(((x)&0xff)<<8))

enum upgrade_err_list
{
   UPGRADE_ERR_NO = 0,
	 UPGRADE_ERR_START_FRAME_CRC   =1,
	 UPGRADE_ERR_START_FRAME_PARA  =2,
	 UPGRADE_ERR_PROCESS_FRAME_CRC =3,
	 UPGRADE_ERR_PROCESS_FRAME_START_CMD =4,
	 UPGRADE_ERR_PROCESS_FRAME_WRITE_FLASH =5,
	 UPGRADE_ERR_STOP_FRAME_CRC =6,
	 UPGRADE_ERR_STOP_FRAME_LOST_FLASH_SETOR =7,
	 UPGRADE_ERR_VERSION_FRAME_CRC = 8,

};


typedef enum  frame_format_analy_step
{
    STEP_HEAD  = 0,
	  STEP_CMD   = 2,
	  STEP_ADDR  = 4,
	  STEP_LEN   = 8,
	  STEP_DATA  = 10,
}Frame_Format_Analy_Step_Stype;

typedef enum start_frame_format_analy_step
{
    S_STEP_HEAD  = 0,
	  S_STEP_CMD   = 2,
	  S_STEP_LEN   = 4,
	  S_STEP_DATA  = 6,
}EnStart_Frame_Format_Analy_Step_Stype;



typedef enum Upgrade_Cmd_Analy_Step
{
    UPGRADE_START   = 0x0001,
	  UPGRADE_PROCESS = 0x0004,
	  UPGRADE_STOP    = 0x0008,
	  UPGRADE_VERSON  = 0x0010,
}Upgrade_Cmd_Analy_Step_Stype;

typedef struct
{
	 uint16_t Rec_Flash_Block_Cnt;
	 uint16_t Flash_Block_Size;
	 uint16_t Flash_Block_Num;
	 uint16_t Flag;
}StUpgrade_Para_Stype;


void Set_Iap_Flag(uint16_t Flag);
uint8_t Upgrade_Start_Handle(uint8_t*Data,uint16_t *Len);
uint8_t Upgrade_Process_Handle(uint8_t*Data,uint16_t* Len);
uint8_t Upgrade_Stop_Handle(uint8_t*Data,uint16_t* Len);
uint8_t Upgrade_Handle(uint8_t*Data,uint16_t* Len);
uint8_t Upgrade_Get_Version_Handle(uint8_t*Data,uint16_t* Len);
int16_t Generate_Check_Sum(uint8_t *Data, uint16_t Data_Len, int16_t *Check_Sum);
void Sys_Soft_Reset(void);

#endif /* BIN_UPGRADE_H_ */
