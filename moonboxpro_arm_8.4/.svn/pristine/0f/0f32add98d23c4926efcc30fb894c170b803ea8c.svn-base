/*
 * flash.h
 *
 *  Created on: Jul 29, 2024
 *      Author: 17500
 */

#ifndef FLASH_H_
#define FLASH_H_

#include "sys.h"
#include "core_cm4.h"             /* Cortex-M4 processor and core peripherals */

#ifdef __cplusplus
extern "C" {
#endif

#define ADDR_FLASH_SECTOR_0     ((uint32_t)0x08000000) /* Base @ of Sector 0, 16 Kbytes */
#define ADDR_FLASH_SECTOR_1     ((uint32_t)0x08004000) /* Base @ of Sector 1, 16 Kbytes */
#define ADDR_FLASH_SECTOR_2     ((uint32_t)0x08008000) /* Base @ of Sector 2, 16 Kbytes */
#define ADDR_FLASH_SECTOR_3     ((uint32_t)0x0800C000) /* Base @ of Sector 3, 16 Kbytes */
#define ADDR_FLASH_SECTOR_4     ((uint32_t)0x08010000) /* Base @ of Sector 4, 64 Kbytes */
#define ADDR_FLASH_SECTOR_5     ((uint32_t)0x08020000) /* Base @ of Sector 5, 128 Kbytes */
#define ADDR_FLASH_SECTOR_6     ((uint32_t)0x08040000) /* Base @ of Sector 6, 128 Kbytes */
#define ADDR_FLASH_SECTOR_7     ((uint32_t)0x08060000) /* Base @ of Sector 7, 128 Kbytes */
#define ADDR_FLASH_SECTOR_8     ((uint32_t)0x08080000) /* Base @ of Sector 8, 128 Kbytes */
#define ADDR_FLASH_SECTOR_9     ((uint32_t)0x080A0000) /* Base @ of Sector 9, 128 Kbytes */
#define ADDR_FLASH_SECTOR_10    ((uint32_t)0x080C0000) /* Base @ of Sector 10, 128 Kbytes */
#define ADDR_FLASH_SECTOR_11    ((uint32_t)0x080E0000) /* Base @ of Sector 11, 128 Kbytes */

#define FLASH_Sector_0     ((uint16_t)0x0000) /*!< Sector Number 0 */
#define FLASH_Sector_1     ((uint16_t)0x0008) /*!< Sector Number 1 */
#define FLASH_Sector_2     ((uint16_t)0x0010) /*!< Sector Number 2 */
#define FLASH_Sector_3     ((uint16_t)0x0018) /*!< Sector Number 3 */
#define FLASH_Sector_4     ((uint16_t)0x0020) /*!< Sector Number 4 */
#define FLASH_Sector_5     ((uint16_t)0x0028) /*!< Sector Number 5 */
#define FLASH_Sector_6     ((uint16_t)0x0030) /*!< Sector Number 6 */
#define FLASH_Sector_7     ((uint16_t)0x0038) /*!< Sector Number 7 */
#define FLASH_Sector_8     ((uint16_t)0x0040) /*!< Sector Number 8 */
#define FLASH_Sector_9     ((uint16_t)0x0048) /*!< Sector Number 9 */
#define FLASH_Sector_10    ((uint16_t)0x0050) /*!< Sector Number 10 */
#define FLASH_Sector_11    ((uint16_t)0x0058) /*!< Sector Number 11 */

//FLASH起始地址
#define STM32_FLASH_BASE 0x08000000 			//STM32 FLASH的起始地址

#define USER_CODE_ADDRESS_0		0x08020000  	//第一个应用程序起始地址(存放在FLASH)
#define USER_CODE_ADDRESS_1		0x08040000  	//第二个应用程序起始地址(存放在FLASH)
#define USER_CODE_ADDRESS_2		0x08060000  	//第二个应用程序起始地址(存放在FLASH)
#define IAP_FLAG_ADDR  			0x08008000    	//IAP升级标志位存储地址
#define UPGRADE_INFO_ADDR  		0x0800C000    	//IAP升级标志位存储地址

#define FLASH_NO_ERR   0
#define FLASH_ADDR_ERR 1
#define FLASH_WT_ERR   2

uint32_t GetSector(uint32_t Address);
uint16_t Flash_Read_Buf(uint32_t ReadAddr,uint32_t *pBuffer,uint32_t NumToRead);
//int32_t Flash_Write_HalfWord(uint32_t addr, int32_t index, uint16_t data);
//int32_t Flash_Write_Word(uint32_t addr, int32_t index, uint32_t data);
uint32_t Flash_Read_Word(uint32_t faddr);
//int32_t Flash_Erase(uint32_t addr);
//FLASH_Status Flash_Erase_Page(uint16_t sector);
//uint16_t Flash_Get_FlashSector(uint32_t addr);
#ifdef __cplusplus
}
#endif

#endif /* FLASH_H_ */
