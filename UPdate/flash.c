/*
 * flash.c
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */
#include "flash.h"
#include "stm32f4xx.h"
#include "stm32f4xx_hal_flash.h"
#include "stm32f4xx_hal_flash_ex.h"

FLASH_EraseInitTypeDef EraseInitStruct;

/**
  * @brief  Gets the sector of a given address
  * @param  None
  * @retval The sector of a given address
  */
uint32_t GetSector(uint32_t Address)
{
  uint32_t sector = 0;

  if((Address < ADDR_FLASH_SECTOR_1) && (Address >= ADDR_FLASH_SECTOR_0))
  {
    sector = FLASH_SECTOR_0;
  }
  else if((Address < ADDR_FLASH_SECTOR_2) && (Address >= ADDR_FLASH_SECTOR_1))
  {
    sector = FLASH_SECTOR_1;
  }
  else if((Address < ADDR_FLASH_SECTOR_3) && (Address >= ADDR_FLASH_SECTOR_2))
  {
    sector = FLASH_SECTOR_2;
  }
  else if((Address < ADDR_FLASH_SECTOR_4) && (Address >= ADDR_FLASH_SECTOR_3))
  {
    sector = FLASH_SECTOR_3;
  }
  else if((Address < ADDR_FLASH_SECTOR_5) && (Address >= ADDR_FLASH_SECTOR_4))
  {
    sector = FLASH_SECTOR_4;
  }
  else if((Address < ADDR_FLASH_SECTOR_6) && (Address >= ADDR_FLASH_SECTOR_5))
  {
    sector = FLASH_SECTOR_5;
  }
  else if((Address < ADDR_FLASH_SECTOR_7) && (Address >= ADDR_FLASH_SECTOR_6))
  {
    sector = FLASH_SECTOR_6;
  }
  else if((Address < ADDR_FLASH_SECTOR_8) && (Address >= ADDR_FLASH_SECTOR_7))
  {
    sector = FLASH_SECTOR_7;
  }
  else if((Address < ADDR_FLASH_SECTOR_9) && (Address >= ADDR_FLASH_SECTOR_8))
  {
    sector = FLASH_SECTOR_8;
  }
  else if((Address < ADDR_FLASH_SECTOR_10) && (Address >= ADDR_FLASH_SECTOR_9))
  {
    sector = FLASH_SECTOR_9;
  }
  else if((Address < ADDR_FLASH_SECTOR_11) && (Address >= ADDR_FLASH_SECTOR_10))
  {
    sector = FLASH_SECTOR_10;
  }
  else /* (Address < FLASH_END_ADDR) && (Address >= ADDR_FLASH_SECTOR_11) */
  {
    sector = FLASH_SECTOR_11;
  }
  return sector;
}

//int32_t Flash_Write_HalfWord(uint32_t addr, int32_t index, uint16_t data)
//{
//	FLASH_Status state = FLASH_COMPLETE_A;
//	HAL_FLASH_Unlock();
//	__HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR | FLASH_FLAG_PGPERR | FLASH_FLAG_PGSERR);
//	state = FLASH_ProgramHalfWord(addr+(index<<1), data);
//	HAL_FLASH_Lock();
//	return (FLASH_COMPLETE_A != state) ? 1 : 0;
//}
//
//int32_t Flash_Write_Word(uint32_t addr, int32_t index, uint32_t data)
//{
//	FLASH_Status state = FLASH_COMPLETE_A;
//	HAL_FLASH_Unlock();
//	__HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR | FLASH_FLAG_PGPERR | FLASH_FLAG_PGSERR);
//	state = FLASH_ProgramWord(addr+(index<<2), data);
//	HAL_FLASH_Lock();
//	return (FLASH_COMPLETE_A != state) ? 1 : 0;
//}
//
//int32_t Flash_Erase(uint32_t addr)
//{
//	FLASH_Status state = FLASH_COMPLETE_A;
//	uint32_t sector;
//	sector = Flash_Get_FlashSector(addr);
//	HAL_FLASH_Unlock();
//	__HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR | FLASH_FLAG_PGPERR | FLASH_FLAG_PGSERR);
//	state = FLASH_EraseSector(sector, VoltageRange_3);
//	HAL_FLASH_Lock();
//	return (FLASH_COMPLETE_A != state) ? 1 : 0;
//}
//
//FLASH_Status Flash_Erase_Page(uint16_t sector)
//{
//	FLASH_Status state = FLASH_COMPLETE_A;
//	HAL_FLASH_Unlock();
//	__HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR | FLASH_FLAG_PGPERR | FLASH_FLAG_PGSERR);
//	state = FLASH_EraseSector(sector, FLASH_VOLTAGE_RANGE_3);
//	HAL_FLASH_Lock();
//	return state;
//}


//读取指定地址的半字(16位数据)
//faddr:读地址
//返回值:对应数据.
uint32_t Flash_Read_Word(uint32_t faddr)
{
	return *(volatile uint32_t*)faddr;
}

//获取某个地址所在的flash扇区
//addr:flash地址
//返回值:0~11,即addr所在的扇区
//uint16_t Flash_Get_FlashSector(uint32_t addr)
//{
//	if(addr<ADDR_FLASH_SECTOR_1)return FLASH_Sector_0;
//	else if(addr<ADDR_FLASH_SECTOR_2)return FLASH_Sector_1;
//	else if(addr<ADDR_FLASH_SECTOR_3)return FLASH_Sector_2;
//	else if(addr<ADDR_FLASH_SECTOR_4)return FLASH_Sector_3;
//	else if(addr<ADDR_FLASH_SECTOR_5)return FLASH_Sector_4;
//	else if(addr<ADDR_FLASH_SECTOR_6)return FLASH_Sector_5;
//	else if(addr<ADDR_FLASH_SECTOR_7)return FLASH_Sector_6;
//	else if(addr<ADDR_FLASH_SECTOR_8)return FLASH_Sector_7;
//	else if(addr<ADDR_FLASH_SECTOR_9)return FLASH_Sector_8;
//	else if(addr<ADDR_FLASH_SECTOR_10)return FLASH_Sector_9;
//	else if(addr<ADDR_FLASH_SECTOR_11)return FLASH_Sector_10;
//	return FLASH_Sector_11;
//}

//从指定地址开始写入指定长度的数据
//特别注意:因为STM32F4的扇区实在太大,没办法本地保存扇区数据,所以本函数
//         写地址如果非0XFF,那么会先擦除整个扇区且不保存扇区数据.所以
//         写非0XFF的地址,将导致整个扇区数据丢失.建议写之前确保扇区里
//         没有重要数据,最好是整个扇区先擦除了,然后慢慢往后写.
//该函数对OTP区域也有效!可以用来写OTP区!
//OTP区域地址范围:0X1FFF7800~0X1FFF7A0F
//WriteAddr:起始地址(此地址必须为4的倍数!!)
//pBuffer:数据指针
//NumToWrite:字(32位)数(就是要写入的32位数据的个数.)
//uint8_t Flash_Write_Buf(uint32_t WriteAddr,uint32_t *pBuffer,uint32_t NumToWrite)
//{
//	// 2024.7.30.112113
//	//FLASH_Status status = FLASH_COMPLETE;
//	HAL_StatusTypeDef FlashStatus = HAL_OK;
//	uint32_t addrx=0;
//	uint32_t endaddr=0;
//	if(WriteAddr<STM32_FLASH_BASE||WriteAddr%4)return FLASH_ADDR_ERR;	//非法地址
//	HAL_FLASH_Unlock();		//解锁
//	// FLASH_DataCacheCmd(DISABLE);   //FLASH擦除期间,必须禁止数据缓存
//	__HAL_FLASH_DATA_CACHE_DISABLE(); //FLASH擦除期间,必须禁止数据缓存
//
// 	addrx=WriteAddr;				//写入的起始地址
//	endaddr=WriteAddr+NumToWrite*4;	//写入的结束地址
//
//	if(addrx<0X1FFF0000)			//只有主存储区,才需要执行擦除操作!!
//	{
//		while(addrx<endaddr)		//扫清一切障碍.(对非FFFFFFFF的地方,先擦除)
//		{
//			if(Flash_Read_Word(addrx)!=0XFFFFFFFF)//有非0XFFFFFFFF的地方,要擦除这个扇区
//			{
//
//				FlashStatus = Flash_Erase_Page(Flash_Get_FlashSector(addrx));
//				if(FlashStatus!=HAL_OK)break;	//发生错误了
//			}else addrx+=4;
//		}
//	}
//	if(FlashStatus==HAL_OK)
//	{
//		while(WriteAddr<endaddr)//写数据
//		{
//			FlashStatus = HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, WriteAddr, *pBuffer);
//			if(FlashStatus!=HAL_OK)//写入数据
//			{
//				break;	//写入异常
//			}
//			WriteAddr+=4;
//			pBuffer++;
//		}
//	}
//	__HAL_FLASH_DATA_CACHE_ENABLE();	//FLASH擦除结束,开启数据缓存
//	HAL_FLASH_Lock();//上锁
//
//	return (FlashStatus!=HAL_OK)?FLASH_WT_ERR:FLASH_NO_ERR;
//}

//从指定地址开始读出指定长度的数据
//ReadAddr:起始地址
//pBuffer:数据指针
//NumToRead:字(4位)数
uint16_t Flash_Read_Buf(uint32_t ReadAddr,uint32_t *pBuffer,uint32_t NumToRead)
{
	uint32_t i;
	uint16_t DatLenth = 0;
	for(i=0;i<NumToRead;i++)
	{
		pBuffer[i]=Flash_Read_Word(ReadAddr);//读取4个字节.
		ReadAddr+=4;//偏移4个字节.
		if(0xffffffff == pBuffer[i])
		{
			DatLenth++;
		}
		else
		{
		   DatLenth = 0;
		}
	}
	return DatLenth;
}
