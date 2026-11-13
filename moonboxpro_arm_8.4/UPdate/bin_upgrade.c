/*
 * bin_upgrade.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#include "bin_upgrade.h"
#include "stdio.h"
#include "led.h"
#include "stdint.h"

StUpgrade_Para_Stype StUpGrade_Info;
uint16_t Addr_Last = 0;

extern FLASH_EraseInitTypeDef EraseInitStruct;

void Set_Iap_Flag(uint16_t Flag)
{
	uint32_t SECTORError = 0;
	HAL_FLASH_Unlock();
	/* Fill EraseInit structure*/
	EraseInitStruct.TypeErase     = FLASH_TYPEERASE_SECTORS;
	EraseInitStruct.VoltageRange  = FLASH_VOLTAGE_RANGE_3;
	EraseInitStruct.Sector        = GetSector(IAP_FLAG_ADDR);
	EraseInitStruct.NbSectors     = 1;
	/* Note: If an erase operation in Flash memory also concerns data in the data or instruction cache,
	you have to make sure that these data are rewritten before they are accessed during code
	execution. If this cannot be done safely, it is recommended to flush the caches by setting the
	DCRST and ICRST bits in the FLASH_CR register. */
	HAL_FLASHEx_Erase(&EraseInitStruct, &SECTORError);
	HAL_FLASH_Program(FLASH_TYPEPROGRAM_HALFWORD,IAP_FLAG_ADDR,Flag);
	HAL_FLASH_Lock();
}

uint8_t Upgrade_Handle(uint8_t*Data,uint16_t* Len)
{
	uint8_t Err = 0;
	uint16_t Ugrade_Cmd = (uint16_t)Data[STEP_CMD+1]<<8|Data[STEP_CMD];
   switch(Ugrade_Cmd)
	 {
	   case UPGRADE_START:
			 Err = Upgrade_Start_Handle(Data,Len);
			 break;
		 case UPGRADE_PROCESS:
			 Err =Upgrade_Process_Handle(Data,Len);
			 break;
		 case UPGRADE_STOP:
			 Err = Upgrade_Stop_Handle(Data,Len);
			 break;
		 case UPGRADE_VERSON:
			 Err = Upgrade_Get_Version_Handle(Data,Len);
			 break;
		 default:
			 break;
	 }
	 return Err;
}

uint8_t Upgrade_Get_Version_Handle(uint8_t*Data,uint16_t* Len)
{
	uint8_t Err =0;
	int16_t Frame_CRC = 0;
	int16_t Caculate_CRC = 0;
	uint16_t Tmp_Len = 0;
	uint16_t Frame_Len = * Len;

	Frame_CRC = Data[Frame_Len-1]<<8|Data[Frame_Len-2];
	Generate_Check_Sum(Data,Frame_Len-2,&Caculate_CRC);
	if(Caculate_CRC!=Frame_CRC)
	{
		Err = UPGRADE_ERR_VERSION_FRAME_CRC;
	}
	Data[Tmp_Len++] = (uint8_t)FRAME_HEAD&0xff;
	Data[Tmp_Len++] = (uint16_t)FRAME_HEAD>>8;

	Data[Tmp_Len++] = (uint8_t)UPGRADE_STOP&0xff;
	Data[Tmp_Len++] = (uint16_t)UPGRADE_STOP>>8;

	Data[Tmp_Len++] = 6;  //datelen
	Data[Tmp_Len++] = 0;

	Data[Tmp_Len++] = Err;
	Data[Tmp_Len++] = 0;

	Data[Tmp_Len++] = SOFT_VERSION;
	Data[Tmp_Len++] = 0;

	Generate_Check_Sum(Data,Tmp_Len,&Caculate_CRC);
	Data[Tmp_Len++] = (uint8_t)Caculate_CRC&0xff;
	Data[Tmp_Len++] = (uint16_t)Caculate_CRC>>8;

	*Len= Tmp_Len;

	return 0;//2025.9.8.103143 消除警告
}

uint8_t Upgrade_Start_Handle(uint8_t*Data,uint16_t* Len)
{
	uint8_t Err = 0;
	int16_t Frame_CRC = 0;
	int16_t Caculate_CRC = 0;
	uint16_t Tmp_Len = 0;
	uint16_t Frame_Len = * Len;
	Frame_CRC = (uint16_t)Data[Frame_Len-1]<<8|Data[Frame_Len-2];
	Generate_Check_Sum(Data,Frame_Len-2,&Caculate_CRC);
	if(Caculate_CRC!=Frame_CRC)
	{
		 Err =  UPGRADE_ERR_START_FRAME_CRC;
	}

	StUpGrade_Info.Flash_Block_Num = (uint16_t)Data[S_STEP_DATA+1]<<8|Data[S_STEP_DATA+0];
	StUpGrade_Info.Flash_Block_Size= (uint16_t)Data[S_STEP_DATA+3]<<8|Data[S_STEP_DATA+2];

	if((StUpGrade_Info.Flash_Block_Num == 0)||(StUpGrade_Info.Flash_Block_Size == 0))
	{
	   Err =  UPGRADE_ERR_START_FRAME_PARA;
	}

	StUpGrade_Info.Rec_Flash_Block_Cnt = 0;
	StUpGrade_Info.Flag = 1;

	Data[Tmp_Len++] = (uint8_t)FRAME_HEAD&0xff;
	Data[Tmp_Len++] = (uint16_t)FRAME_HEAD>>8;
	Data[Tmp_Len++] = (uint8_t)UPGRADE_START&0xff;
	Data[Tmp_Len++] = (uint16_t)UPGRADE_START>>8;
	Data[Tmp_Len++] = 4;  //datelen
	Data[Tmp_Len++] = 0;
	Data[Tmp_Len++] = Err;
	Data[Tmp_Len++] = 0;
	Generate_Check_Sum(Data,Tmp_Len,&Caculate_CRC);
	Data[Tmp_Len++] = (uint8_t)Caculate_CRC&0xff;
	Data[Tmp_Len++] = (uint16_t)Caculate_CRC>>8;
	*Len= Tmp_Len;
	return Err;
}

uint8_t Upgrade_Process_Handle(uint8_t*Data,uint16_t* Len)
{
	uint8_t Err =0;
	int16_t Frame_CRC = 0;
	int16_t Caculate_CRC = 0;
	uint16_t Tmp_Len = 0;
	uint16_t Frame_Len = * Len;
	uint32_t Flash_Block_Addr = 0;
	uint32_t *Flash_Data;
	uint16_t Flash_Data_Num ;
	uint8_t Ret = 0;
	uint16_t i;
	uint32_t SECTORError = 0;
	if(StUpGrade_Info.Flag == 1) //
	{
		Frame_CRC = Data[Frame_Len-1]<<8|Data[Frame_Len-2];
		Generate_Check_Sum(Data,Frame_Len-2,&Caculate_CRC);
		if(Caculate_CRC!=Frame_CRC)
		{
			 Err = UPGRADE_ERR_PROCESS_FRAME_CRC;
		}
		//Flash_Block_Addr =(u32) Data[STEP_ADDR]<<8|Data[STEP_ADDR+1];
		Flash_Block_Addr =(uint32_t) Data[STEP_ADDR+3]<<24|Data[STEP_ADDR+2]<<16|Data[STEP_ADDR+1]<<8|Data[STEP_ADDR];
		Flash_Data =(uint32_t*)(Data+STEP_DATA);
		//Flash_Data_Num = (((uint16_t)Data[STEP_LEN+1]<<8) | Data[STEP_LEN]-1)*2/4;
		Flash_Data_Num = ((((uint16_t)Data[STEP_LEN+1]<<8) | Data[STEP_LEN])-1)*2/4;//2025.9.20.132239 优化警告，增加括号

		  StUpGrade_Info.Rec_Flash_Block_Cnt++;

		if(StUpGrade_Info.Rec_Flash_Block_Cnt == 2)
		{
		  StUpGrade_Info.Rec_Flash_Block_Cnt = StUpGrade_Info.Rec_Flash_Block_Cnt;
		}

		if(StUpGrade_Info.Rec_Flash_Block_Cnt == 0x01aa)
		{
		   StUpGrade_Info.Rec_Flash_Block_Cnt = StUpGrade_Info.Rec_Flash_Block_Cnt;
		}

		HAL_FLASH_Unlock();
		if(Flash_Block_Addr == 0)
		{
			// 2024.7.30.141333
			//Flash_Erase(BIN_STORE_BASE_ADDR);

			/* Fill EraseInit structure*/
			EraseInitStruct.TypeErase     = FLASH_TYPEERASE_SECTORS;
			EraseInitStruct.VoltageRange  = FLASH_VOLTAGE_RANGE_3;
			EraseInitStruct.Sector        = GetSector(BIN_STORE_BASE_ADDR);
			EraseInitStruct.NbSectors     = 1;
			/* Note: If an erase operation in Flash memory also concerns data in the data or instruction cache,
			you have to make sure that these data are rewritten before they are accessed during code
			execution. If this cannot be done safely, it is recommended to flush the caches by setting the
			DCRST and ICRST bits in the FLASH_CR register. */
			HAL_FLASHEx_Erase(&EraseInitStruct, &SECTORError);
		}

		for(i=0;i<Flash_Data_Num;i++)
		{
			// 2024.7.30.141554
			//Ret = Flash_Write_Word(BIN_STORE_BASE_ADDR+Flash_Block_Addr,i,Flash_Data[i]);
			Ret = HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD,BIN_STORE_BASE_ADDR + Flash_Block_Addr,Flash_Data[i]);
			Flash_Block_Addr = Flash_Block_Addr + 4;
			if(Ret!=0)
			{
				Err = UPGRADE_ERR_PROCESS_FRAME_WRITE_FLASH;
			}
		}
		HAL_FLASH_Lock();
	}
	else
	{
	      Err = UPGRADE_ERR_PROCESS_FRAME_START_CMD; //no receive upgrade start command
	}

	Data[Tmp_Len++] = (uint8_t)FRAME_HEAD&0xff;
	Data[Tmp_Len++] = (uint16_t)FRAME_HEAD>>8;

	Data[Tmp_Len++] = (uint8_t)UPGRADE_PROCESS&0xff;
	Data[Tmp_Len++] = (uint16_t)UPGRADE_PROCESS>>8;

	Data[Tmp_Len++] = 4;  //datelen
	Data[Tmp_Len++] = 0;

	Data[Tmp_Len++] = Err;
	Data[Tmp_Len++] = 0;

	Generate_Check_Sum(Data,Tmp_Len,&Caculate_CRC);

	Data[Tmp_Len++] = (uint8_t)Caculate_CRC&0xff;
	Data[Tmp_Len++] = (uint16_t)Caculate_CRC>>8;
	*Len= Tmp_Len;
	return Err;
}

uint8_t Upgrade_Stop_Handle(uint8_t*Data,uint16_t* Len)
{
	uint8_t Err =0;
	int16_t Frame_CRC = 0;
	int16_t Caculate_CRC = 0;
	uint16_t Tmp_Len = 0;
	uint16_t Frame_Len = * Len;

	if(StUpGrade_Info.Flash_Block_Num== StUpGrade_Info.Rec_Flash_Block_Cnt)
	{
		Frame_CRC = Data[Frame_Len-1]<<8|Data[Frame_Len-2];
		Generate_Check_Sum(Data,Frame_Len-2,&Caculate_CRC);
		if(Caculate_CRC!=Frame_CRC)
		{
			Err = UPGRADE_ERR_STOP_FRAME_CRC;
		}
	}
	else
	{
		Err = UPGRADE_ERR_STOP_FRAME_LOST_FLASH_SETOR;////flash block receive no enough
	}

	Data[Tmp_Len++] = (uint8_t)FRAME_HEAD&0xff;
	Data[Tmp_Len++] = (uint16_t)FRAME_HEAD>>8;

	Data[Tmp_Len++] = (uint8_t)UPGRADE_STOP&0xff;
	Data[Tmp_Len++] = (uint16_t)UPGRADE_STOP>>8;

	Data[Tmp_Len++] = 4;  //datelen
	Data[Tmp_Len++] = 0;

	Data[Tmp_Len++] = Err;
	Data[Tmp_Len++] = 0;

	Generate_Check_Sum(Data,Tmp_Len,&Caculate_CRC);
	Data[Tmp_Len++] = (int8_t)Caculate_CRC&0xff;
	Data[Tmp_Len++] = (int16_t)Caculate_CRC>>8;

	*Len= Tmp_Len;
	StUpGrade_Info.Flag = 0;//clear start upgrade flag

	Set_Iap_Flag(STAT_UPGRADE);
	return Err;
}

int16_t  Generate_Check_Sum(uint8_t *Data, uint16_t Data_Len, int16_t *Check_Sum)
{
	int16_t err = 0;
	uint16_t cy_k;
	uint32_t cSum = 0;
	for (cy_k = 0; cy_k<Data_Len; cy_k++)
	{
		cSum += Data[cy_k];
	}
	*Check_Sum = 0x0100 - (cSum & 0x00FF);
	return err;
}

void Sys_Soft_Reset(void)
{
	__set_FAULTMASK(1);				// mask all interrupts
	//NVIC_PriorityGroupConfig(0x04);	// system soft reset
	//HAL_NVIC_SetPriorityGrouping(NVIC_PRIORITYGROUP_4);
}
