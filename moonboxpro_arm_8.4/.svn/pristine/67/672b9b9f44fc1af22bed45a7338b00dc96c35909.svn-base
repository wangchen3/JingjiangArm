/*
 * modbus485.c
 *
 *  Created on: Jul 22, 2025
 *      Author: 17500
 */
#include "modbus485.h"
#include "usart.h"
#include "tim.h"
#include "string.h"//内存操作



//全局变量申请
uint8_t g_abySendDataBuff[SENDBUFF_NUM]={0};//发送buff
uint16_t g_iNeedSendNum = 0;//需要发送的个数
uint16_t g_iSendNum_Act = 0;//实际发送的个数_
uint8_t g_xDataSendDne = FALSE;//串口数据发送完成标志
uint8_t g_abyCycleQueue[CYCLEQUEUE_NUM] = {0};//队列大小@从sa下一个开始写最新的
int16_t g_iQueueSa = 0,g_iQueueEd = 0;//队列起始
//StData_Comm g_astStDataComm[MODBUSNUM_MAX];//每个站的通讯内容
//StModbusDataAdrList  g_stStModbusDataAdrList[MODBUSNUM_MAX][REGISTER_AREA_MAX];//每个站下每个寄存器区的通讯列表
VisuCommData g_stVisuCommData;//通讯的数据结构体
uint8_t g_xInitCycleQueue = FALSE;//初始化队列
uint8_t g_byCycleQueueFullCnt = 0;//队列满计数
uint16_t g_uiORECnt = 0;//上溢中断发生次数
uint16_t g_uiCycleCommTimer = 0,g_uiTimeOutTimer = 0;//循环通讯计时器(ms)、超时计时器(ms)@在时间中断中处理
uint16_t g_uiPollTimer = 0;//轮询计时器

uint8_t g_byCurModbusIdIndex = 0;
uint8_t g_byCurRegisterIndex = 0;

StData_Comm g_astStData[MODBUSNUM_MAX] = {0};
//2026.6.16.144203+屏蔽
//StModbusDataAdrList g_aStDataList[MODBUSNUM_MAX][REGISTER_AREA_MAX];
uint8_t g_abyModbusIdList[MODBUSNUM_MAX]={0};//modbusid列表
uint8_t g_axModbusCommEnList[MODBUSNUM_MAX] = {0};//modbus使能标志
uint8_t g_axRegisterAreaCommEnList[MODBUSNUM_MAX][REGISTER_AREA_MAX] = {0};//每个寄存器的使能标志
//一些输出内容
uint16_t g_auiSendDataCnt[MODBUSNUM_MAX] = {0};//发送的计数
uint16_t g_auiRecvDataCnt[MODBUSNUM_MAX] = {0};//接收的计数
uint16_t g_auiRecvErrDataCnt[MODBUSNUM_MAX] = {0};//接收出错的计数
uint16_t g_auiTimeOutDataCnt[MODBUSNUM_MAX] = {0};//超时计数
uint8_t g_axConnectOk[MODBUSNUM_MAX] = {0};//通讯正常标志
uint8_t g_abyErrCodeFrSlav[MODBUSNUM_MAX] = {0};/*(*设备返回错误码|响应功能码 = 请求功能码+0x80
																		01 非法功能码
																		02 非法地址
																		03 非法数据
																		04 服务器故障
																		05 确认
																		06 服务器繁忙
																		0A 0B 网关故障-具体信息详见Modbus协议中文版.pdf中113页*)
																		*/

int16_t g_aiErrCode[10] = {0};

//CRC校验表
static const uint8_t gc_auchCRCHi[256] = {
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
	0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
	0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
	0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,0x80, 0x41, 0x00, 0xC1, 0x81, 0x40
};

static const uint8_t gc_auchCRCLo[256] = {
	0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2, 0xC6, 0x06,0x07, 0xC7, 0x05, 0xC5, 0xC4, 0x04, 0xCC, 0x0C, 0x0D, 0xCD,
	0x0F, 0xCF, 0xCE, 0x0E, 0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09,0x08, 0xC8, 0xD8, 0x18, 0x19, 0xD9, 0x1B, 0xDB, 0xDA, 0x1A,
	0x1E, 0xDE, 0xDF, 0x1F, 0xDD, 0x1D, 0x1C, 0xDC, 0x14, 0xD4,0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 0xD2, 0x12, 0x13, 0xD3,
	0x11, 0xD1, 0xD0, 0x10, 0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3,0xF2, 0x32, 0x36, 0xF6, 0xF7, 0x37, 0xF5, 0x35, 0x34, 0xF4,
	0x3C, 0xFC, 0xFD, 0x3D, 0xFF, 0x3F, 0x3E, 0xFE, 0xFA, 0x3A,0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38, 0x28, 0xE8, 0xE9, 0x29,
	0xEB, 0x2B, 0x2A, 0xEA, 0xEE, 0x2E, 0x2F, 0xEF, 0x2D, 0xED,0xEC, 0x2C, 0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26,
	0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 0xA0, 0x60,0x61, 0xA1, 0x63, 0xA3, 0xA2, 0x62, 0x66, 0xA6, 0xA7, 0x67,
	0xA5, 0x65, 0x64, 0xA4, 0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F,0x6E, 0xAE, 0xAA, 0x6A, 0x6B, 0xAB, 0x69, 0xA9, 0xA8, 0x68,
	0x78, 0xB8, 0xB9, 0x79, 0xBB, 0x7B, 0x7A, 0xBA, 0xBE, 0x7E,0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 0xB4, 0x74, 0x75, 0xB5,
	0x77, 0xB7, 0xB6, 0x76, 0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71,0x70, 0xB0, 0x50, 0x90, 0x91, 0x51, 0x93, 0x53, 0x52, 0x92,
	0x96, 0x56, 0x57, 0x97, 0x55, 0x95, 0x94, 0x54, 0x9C, 0x5C,0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E, 0x5A, 0x9A, 0x9B, 0x5B,
	0x99, 0x59, 0x58, 0x98, 0x88, 0x48, 0x49, 0x89, 0x4B, 0x8B,0x8A, 0x4A, 0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C,
	0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 0x82, 0x42,0x43, 0x83, 0x41, 0x81, 0x80, 0x40
};


uint16_t KS_16CRC_OverWrite(
				uint32_t i_dwDataAdr,//(*数据起始地址*)
				int16_t i_iDataLen)//(*数据长度*)
{

	uint8_t* pbyData = 0;
	uint32_t dwDataAdr = 0;
	int16_t iDataLen =0;
	uint16_t wIndex = 0;
	uint8_t byCRCHi=0xFF;
	uint8_t byCRCLo=0xFF;

	if(i_dwDataAdr!=0 && i_iDataLen!=0)
	{
		dwDataAdr = i_dwDataAdr;
		iDataLen = i_iDataLen;
		pbyData = (uint8_t*)dwDataAdr;

		while(iDataLen>0)
		{
			pbyData = (uint8_t*)dwDataAdr;
			iDataLen = iDataLen-1;
			wIndex = byCRCHi ^ *pbyData;//异或
			byCRCHi = byCRCLo ^ gc_auchCRCHi[wIndex];//异或
			byCRCLo = gc_auchCRCLo[wIndex];
			dwDataAdr = dwDataAdr+1;
		}
	}
	return ((byCRCHi<< 8)  | (byCRCLo));
}

uint8_t KsGetRegisterNum(uint16_t length)
{
	uint16_t uiTmp = 0,uiTmp1 = 0;
	uiTmp = length % 2;//取余
	uiTmp1 = length / 2;//取整
	if (uiTmp==0)//能被整除
		;
	else//不能被整除
		uiTmp1 += 1;

	if(uiTmp1 > 120)
		uiTmp1 = 120;

	return (uint8_t)uiTmp1;
}

//获取bit@获取bit别写超了
uint8_t KSGetDataBit(void* pData,uint8_t BitId)
{
	uint8_t xBit = FALSE;
	uint32_t* p = (uint32_t*)pData;
	uint32_t uiData = *p;
	if (BitId>31);
	else//位置合法
		xBit = ((uiData>>BitId) & 0x00000001) ? TRUE:FALSE;//只取第0bit

	return xBit;
}
//设置bit@写入bit别写超了
//没写完 先不理了
void KSSetDataBit(void* pData,uint8_t value,uint8_t BitId)
{
	uint8_t xBit = value;
	uint32_t* p = (uint32_t*)pData;
	uint32_t uiData = *p ;//当前值
	uint32_t uiValue = (uint32_t)xBit;//要写入的值
	uint32_t uiTmp = 0;//临时值
	if (BitId>31);
	else//位置合法
	{
		uiTmp = (uiData >> BitId) & 0x00000001;//把需要写入到bit移动到最后
		if(uiTmp == uiValue)//写入的值是一样的就不做处理
			;
		else
		{
			if(uiValue == 0)//修改为0
				uiData = uiData & (~(0x1 << BitId));
			else//修改为1
				uiData = uiData | (0x1 << BitId);
		}
	}

	if(BitId < 8)//单字节
		*((uint8_t*)pData) = (uint8_t)uiData;//只修改单字节区域
	else if(BitId < 16)//双字节
		*((uint16_t*)pData) = (uint16_t)uiData;//只修改双字节区域
	else if(BitId < 32)//四字节
		*((uint32_t*)pData) = (uint32_t)uiData;//只修改四字节区域
	else//不做修改
		;
}

//(*将数据高低位按照byte颠倒,将颠倒后的值放置在原位置*)
//如果是奇数字节最后一个就不颠倒
//(*返回值-1 数据大小错误.-2 数据地址错误*)
int16_t KS_DataShift(uint32_t i_dwDataAdr,//(*数据的地址*)
					int16_t i_iDataSize)//(*数据长度*)
{
	uint8_t* pbyTemp = 0;
	int16_t iLp = 0;
	uint8_t abyData[2] = {0};
	int16_t rtn = 0;

	//if(i_iDataSize % 2 ==  0 && i_iDataSize!=0) //(*数据大小为不为0的偶数*)
	if(i_iDataSize>1)
	{
		if(i_dwDataAdr!=0)
		{
			for(iLp = 0;iLp < i_iDataSize / 2; iLp++)//(*将数据按2个字节为一组分配*)
			{
				//(*将数据按字节取出*)
				pbyTemp = (uint8_t*)(i_dwDataAdr + (iLp)*2);
				abyData[0] = *pbyTemp;
				pbyTemp = pbyTemp+1;
				abyData[1] = *pbyTemp;

				//(*进行交换*)
				pbyTemp = pbyTemp-1;
				*pbyTemp = abyData[1];
				pbyTemp = pbyTemp+1;
				*pbyTemp = abyData[0];
			}
		}
		else
			rtn = -2;
	}
	else
		rtn = -1;

	return rtn;
}

//(*将数据高低位按照byte颠倒,将颠倒后的值放置在原位置*)
//如果是奇数字节最后一个就不颠倒
//(*返回值-1 数据大小错误.-2 数据地址错误 -3参数非法*)
//增加输入参数控制控制颠倒的字节@支持双字节颠倒
int16_t KS_DataShift_V2(uint32_t i_dwDataAdr,//(*数据的地址*)
					int16_t i_iDataSize,//(*数据长度*)
					int8_t i_iShiftLenth)//颠倒的长度@=1 按照单字节|=2 按照双字节
{
	uint8_t* pbyTemp = 0;
	int16_t iLp = 0;
	uint8_t abyData[2] = {0};
	int16_t rtn = 0;
	uint16_t uishiftNum = 0;//颠倒的个数
	uint16_t* pwTemp = 0;
	uint16_t awData[2] = {0};

	//if(i_iDataSize % 2 ==  0 && i_iDataSize!=0) //(*数据大小为不为0的偶数*)
	if(i_iDataSize>1)
	{
		if(i_dwDataAdr!=0)
		{
			if(i_iShiftLenth == 1)//按照单字节颠倒
			{
				for(iLp = 0;iLp < i_iDataSize / 2; iLp++)//(*将数据按2个字节为一组分配*)
				{
					//(*将数据按字节取出*)
					pbyTemp = (uint8_t*)(i_dwDataAdr + (iLp)*2);
					abyData[0] = *pbyTemp;
					pbyTemp = pbyTemp+1;
					abyData[1] = *pbyTemp;

					//(*进行交换*)
					pbyTemp = pbyTemp-1;
					*pbyTemp = abyData[1];
					pbyTemp = pbyTemp+1;
					*pbyTemp = abyData[0];
				}
			}
			else if(i_iShiftLenth == 2)//按照双字节颠倒
			{
				uishiftNum = i_iDataSize / 2;//总共有多少个双字节数
				for(iLp = 0;iLp < uishiftNum / 2; iLp++)//(*将数据按2个双字节为一组分配*)
				{
					//(*将数据按字节取出*)
					pwTemp = (uint16_t*)(i_dwDataAdr + (iLp)*2);
					awData[0] = *pwTemp;
					pwTemp = pwTemp+1;
					awData[1] = *pwTemp;

					//(*进行交换*)
					pwTemp = pwTemp-1;
					*pwTemp = awData[1];
					pwTemp = pwTemp+1;
					*pwTemp = awData[0];
				}
			}
			else
				rtn = -3;

		}
		else
			rtn = -2;
	}
	else
		rtn = -1;

	return rtn;
}


//将2个byte拼成一个word@支持2个字节取反拼接
void KS_BYTE_TO_WORD(
		uint8_t i_xBigEndian,//(*高低字节取反标志|有效代表会先发高字节*)
		uint8_t i_abyData[],//2个元素
		uint16_t* i_pwData)
{
	uint8_t abyData[2] = {0};
	uint16_t* pwDataTmp = 0;

	abyData[0] = i_abyData[0];
	abyData[1] = i_abyData[1];
	if(i_pwData!=0){
		if(i_xBigEndian)//调换顺序
			KS_DataShift((uint32_t)abyData, 2);
		pwDataTmp = (uint16_t*)abyData;
		*i_pwData = *pwDataTmp;//写入到word里
	}
}

//(*word转换为2个字节*)
void KS_WORD_TO_BYTE(
		uint8_t i_xBigEndian,//(*高低字节取反标志|有效代表会先发高字节*)
		uint16_t i_wData,
		uint8_t abyData[])//输出2个元素
{
	uint8_t* pbyData = (uint8_t*)(&i_wData);//取输入wor的首地址|byte地址
	abyData[0] = *pbyData;
	abyData[1] = *(pbyData+1);
	if(i_xBigEndian)//(*需要高低取反*)
		KS_DataShift((uint32_t)abyData, 2);
}


void KS_InitQueue(uint32_t i_dwQueueAdrSa,//(*队列首地址*)
					int16_t i_iQueueLen,//(*队列长度@字节长度*)
					int16_t* i_piQueueSa,//(*队列开始*)
					int16_t* i_piQueueEd)//(*队列结束*)
{
	if( i_piQueueSa!=0 &&
		i_piQueueEd!=0 &&
		i_dwQueueAdrSa!=0 &&
		i_iQueueLen>0)
	{

		*i_piQueueSa = 0;
		*i_piQueueEd = 0;
		//KSMemSet((void*)i_dwQueueAdrSa,0,(int32_t)i_iQueueLen);
		memset((void*)i_dwQueueAdrSa,0,(int32_t)i_iQueueLen);
	}
}

//(*单个modbus设备*)
//增加初始化标志控制不变参数的单次更新|减少耗时
//周期更新使能标志@它是经常变化的值
//void KS_GetDataList_V2(uint8_t i_xInitData,//初始化标志@外部控制
//				LP_StData_Comm i_pstStData_Comm,//(*通讯的数据初始化*)
//				StModbusDataAdrList i_pastStDataList[REGISTER_AREA_MAX])//(*通讯的数据列表|为了方便循环处理|索引为寄存器区@多申请一个数组索引从1开始处理*)
//{
//
//	LP_StRegisterAreaAttibute pstStRegisterArea = 0;//寄存器区的属性
//	LP_StModbusDataAdrList pstStDataList = 0;//数据变量地址列表
//	int16_t i = 0,j = 0;
//	uint8_t xInitData = i_xInitData;
////	if(i_pxInitData!=0)
////		xInitData =*i_pxInitData;
//
//	if(!xInitData)
//	{
//		for(i=0;i<REGISTER_AREA_MAX;i++)
//		{
//
//			pstStDataList = &(i_pastStDataList[i]);
//			pstStRegisterArea = &(i_pstStData_Comm->astStRegisterArea[i]);
//			//(*初始化结构*)
//			pstStDataList->xCommEn = FALSE;
//			pstStDataList->wAdrSa = 0;
//			pstStDataList->iRegisterNum = 0;
//			pstStDataList->byType_Data = 4;//(*默认是读写寄存器*)
//			pstStDataList->byType_RW = 2;//(*默认是读写*)
//			pstStDataList->byFunCode = 0;
//			pstStDataList->dwxNeedReSendAdr = 0;
//
//			memset(&(pstStDataList->astDataAdrList),0,sizeof(pstStDataList->astDataAdrList));
//
//			//(*将配置的信息写入的列表中*)
//			pstStDataList->xCommEn = pstStRegisterArea->xCommEn;
//			pstStDataList->wAdrSa = pstStRegisterArea->wModbusAdr;
//			pstStDataList->iRegisterNum = pstStRegisterArea->iRegisterNum;
//			pstStDataList->byType_Data = pstStRegisterArea->byType_Data;
//			pstStDataList->dwxNeedReSendAdr = pstStRegisterArea->dwxNeedReSendAdr;
//			if(pstStDataList->byType_Data==0 || pstStDataList->byType_Data==4)//(*可以读写*)
//				pstStDataList->byType_RW = pstStRegisterArea->byType_RW;
//			else//(*只读*)
//				pstStDataList->byType_RW = 0;
//
//			//每个变量的配置
//			for(j=0;j<pstStDataList->iRegisterNum;j++)
//			{
//				if(j<MODBUS_VAR_MAX)//不能超过最大变量
//				{
//					//数据结构直接赋值,可不可以用还不太清楚
//					pstStDataList->astDataAdrList[j] = pstStRegisterArea->astRegisterDate[j];
//
//					if(pstStDataList->byType_RW==0 ||//  (*寄存器区只读或者只写|都按照寄存器区方式操作*)
//						pstStDataList->byType_RW==1)
//						pstStDataList->astDataAdrList[j].byType_RW = pstStDataList->byType_RW;
//					else;//(*寄存器读写|根据数据属性决定*);
//				}
//			}
//		}
//		//xInitData = TRUE;
//	}
//	else//初始化完成|周期更新使能标志
//	{
//		for(i=0;i<REGISTER_AREA_MAX;i++)
//		{
//
//			pstStDataList = &(i_pastStDataList[i]);
//			pstStRegisterArea = &(i_pstStData_Comm->astStRegisterArea[i]);
//			//(*将配置的信息写入的列表中*)
//			pstStDataList->xCommEn = pstStRegisterArea->xCommEn;
//		}
//	}
//
////	if(i_pxInitData!=0)
////		*i_pxInitData = xInitData;
//
//}

//(*单个modbus设备*)
//(*函数里面直接处理了所有寄存器区的数据列表@2022.10.22.124027*)
//将通讯变量写入到地址列表中|方便循环操作
//void KS_GetDataList(LP_StData_Comm i_pstStData_Comm,//(*通讯的数据初始化*)
//				StModbusDataAdrList i_pastStDataList[REGISTER_AREA_MAX])//(*通讯的数据列表|为了方便循环处理|索引为寄存器区@多申请一个数组索引从1开始处理*)
//{
//
//	LP_StRegisterAreaAttibute pstStRegisterArea = 0;//寄存器区的属性
//	LP_StModbusDataAdrList pstStDataList = 0;//数据变量地址列表
//	int16_t i = 0,j = 0;
//
//	for(i=0;i<REGISTER_AREA_MAX;i++)
//	{
//
//		pstStDataList = &(i_pastStDataList[i]);
//		pstStRegisterArea = &(i_pstStData_Comm->astStRegisterArea[i]);
//		//(*初始化结构*)
//		pstStDataList->xCommEn = FALSE;
//		pstStDataList->wAdrSa = 0;
//		pstStDataList->iRegisterNum = 0;
//		pstStDataList->byType_Data = 4;//(*默认是读写寄存器*)
//		pstStDataList->byType_RW = 2;//(*默认是读写*)
//		pstStDataList->byFunCode = 0;
//		pstStDataList->dwxNeedReSendAdr = 0;
//
//		memset(&(pstStDataList->astDataAdrList),0,sizeof(pstStDataList->astDataAdrList));
//
//		//(*将配置的信息写入的列表中*)
//		pstStDataList->xCommEn = pstStRegisterArea->xCommEn;
//		pstStDataList->wAdrSa = pstStRegisterArea->wModbusAdr;
//		pstStDataList->iRegisterNum = pstStRegisterArea->iRegisterNum;
//		pstStDataList->byType_Data = pstStRegisterArea->byType_Data;
//		pstStDataList->dwxNeedReSendAdr = pstStRegisterArea->dwxNeedReSendAdr;
//		if(pstStDataList->byType_Data==0 || pstStDataList->byType_Data==4)//(*可以读写*)
//			pstStDataList->byType_RW = pstStRegisterArea->byType_RW;
//		else//(*只读*)
//			pstStDataList->byType_RW = 0;
//
//		//每个变量的配置
//		for(j=0;j<pstStDataList->iRegisterNum;j++)
//		{
//			if(j<MODBUS_VAR_MAX)//不能超过最大变量
//			{
//				//数据结构直接赋值,可不可以用还不太清楚
//				pstStDataList->astDataAdrList[j] = pstStRegisterArea->astRegisterDate[j];
//
//				if(pstStDataList->byType_RW==0 ||//  (*寄存器区只读或者只写|都按照寄存器区方式操作*)
//					pstStDataList->byType_RW==1)
//					pstStDataList->astDataAdrList[j].byType_RW = pstStDataList->byType_RW;
//				else;//(*寄存器读写|根据数据属性决定*);
//			}
//		}
//	}
//
//}
/*检查是否需要进行写入或者读取动作
0无动作
1 写入
2 读取*/
//uint8_t KS_CheckRWSts(
//		uint8_t* i_pxWrInit,//(*写入未初始化|用于开机写1次*)
//		LP_StModbusDataAdrList i_pStDataList)//(*通讯的数据列表|一个区域一个区域看*))
//{
//
//	uint8_t byRWSts=0;
//	int16_t iN=0;
//	uint16_t wData=0;
//	uint16_t* pwData=0;
//	uint8_t* pxNeedReSend=0;
//	LP_StDataAttribute pstDataAttribute =0 ;
//
//
//	////(*检查是否有需要再次写入的数据*)
//	pxNeedReSend = (uint8_t*)i_pStDataList->dwxNeedReSendAdr;
//	if(pxNeedReSend!=0)
//	{
//		if(*pxNeedReSend)
//		{
//			*pxNeedReSend = FALSE;
//			if(i_pStDataList->byType_RW==1 ||//(*只写*)
//				i_pStDataList->byType_RW==2)//(*读写*)
//				byRWSts = 1;
//
//		}
//	}
//
//	//(*检查是否有需要写入的数据*)
//	if(byRWSts==0)//(*可以继续判断*)
//	{
//		for(iN=1;iN<=i_pStDataList->iRegisterNum;iN++)
//		{
//			pstDataAttribute = (LP_StDataAttribute)(&(i_pStDataList->astDataAdrList[iN-1]));//astDataAdrList索引从0开始
//			if(pstDataAttribute->byType_RW==1 ||//(*只写*)
//				pstDataAttribute->byType_RW==2)//(*读写*)
//			{
//				if(!(*i_pxWrInit))//(**没有写入初始化*)
//				{
//					*i_pxWrInit = TRUE;
//					byRWSts = 1;
//				}
//				else//(*正常初始化了|我们检查和备份数据的不同*)
//				{
//					pwData = (uint16_t*)pstDataAttribute->dwDataAdr;
//					if(pwData!=0)
//						wData = *pwData;//(*取通讯值*)
//
//					pwData = (uint16_t*)pstDataAttribute->dwDataBakAdr;
//					if(pwData!=0)
//					{
//						if(*pwData!=wData)
//							byRWSts = 1;
//					}
//				}
//			}
//			//(*已经决定了写入动作就不用循环了*)
//			if(byRWSts!=0)
//				break;
//
//		}
//	}
//
//	if(byRWSts==0)//(*没有需要写入|决定是否需要读取*)
//	{
//		for(iN=1;iN<=i_pStDataList->iRegisterNum;iN++)
//		{
//			pstDataAttribute = (LP_StDataAttribute)(&(i_pStDataList->astDataAdrList[iN-1]));//astDataAdrList索引从0开始
//			switch(pstDataAttribute->byType_RW)//(*检查读状态*)
//			{
//				case 0:
//				case 2://(*只读或者读写*)
//					byRWSts = 2;
//					break;
//				default:break;
//			}
//
//			//(*已经决定了写入动作就不用循环了*)
//			if(byRWSts!=0)//(**)
//				break;
//		}
//	}
//
//	return byRWSts;
//
//
//}
//}
//获取下个寄存器的索引@输出站号id+寄存器区索引id+读写状态
void KS_GetNextRegister(uint8_t i_xNextRegister,//(*切换下个寄存器标志|外部处理为沿*)
				StData_Comm i_pastStData_Comm[MODBUSNUM_MAX],//(*所有通讯的数据|*)
				//StModbusDataAdrList i_paStDataList[][REGISTER_AREA_MAX],//(*通讯的数据列表|[]=MODBUSNUM_MAX*)
				uint8_t* i_pbyCurModbusId,//(*当前modbusid|会被更新为下一个*)
				uint8_t* i_pbyCurRegisterIndex,//(*当前寄存器索引|会被更新为下一个*)
				uint8_t* i_pbyRWSts,//(*读写状态|0 不动作 1 写入 2 读取*)
				uint8_t i_byModbusNum_Max)//(*最大站数量*))
{
	uint8_t byCurModbusId;//索引值@从0开始
	uint8_t byCurRegisterId;//索引值@从0开始
	uint8_t byModBusId = 0;//其实是索引值从0开始的@索引的结构体数组中有真正站id
	uint16_t iRegisterIdSa = 0;//寄存器区起始id
	int16_t iN=0,iLp=0;
	int16_t iIndexTemp=0;
	uint8_t abyNeedCheckModbusIdList[MODBUSNUM_MAX]={0};//存储的是通讯数据的索引值从0开始
	uint8_t byRWSts=0;
	//uint8_t xWrInit_True=TRUE;
	//LP_StModbusDataAdrList pstDataList = 0;
	LP_StRegisterAreaAttibute pstStRegisterAreaTmp = 0;//2026.6.17.095437+
	//uint8_t xNeedReSend = 0;//需要重新发送标志


	//(*检查索引是否合法*)
	byCurModbusId = *i_pbyCurModbusId;
	byCurRegisterId = *i_pbyCurRegisterIndex;
	if(byCurModbusId==255 ||
		byCurRegisterId==255)//(*没事干的时候我们从初始开始处理*)
	{
		byCurModbusId = 0;
		byCurRegisterId = 0;
	}

	if(byCurModbusId>=0 &&
		byCurModbusId<i_byModbusNum_Max &&
		byCurRegisterId>=0 &&//(*寄存器索引有效值可以=0|用于初次开机时*)
		byCurRegisterId<=REGISTER_AREA_MAX)
	{
		//(*检查的站号列表*)
		for(iN=byCurModbusId;iN<i_byModbusNum_Max;iN++)//循环最小值
		{
			if(i_pastStData_Comm[iN].xCommEn)//(*通讯使能*)数组索引从0开始的
			{
				abyNeedCheckModbusIdList[iIndexTemp] = (uint8_t)(iN);
				iIndexTemp = iIndexTemp+1;
			}
		}
		for(iN=0;iN<byCurModbusId;iN++)
		{
			if(i_pastStData_Comm[iN].xCommEn)//(*通讯使能*)
			{
				abyNeedCheckModbusIdList[iIndexTemp] = (uint8_t)(iN);
				iIndexTemp = iIndexTemp+1;
			}
		}

		byRWSts = 0;
		if(i_xNextRegister)
		{
			for(iN=0;iN<iIndexTemp;iN++)//(*循环查看@iIndexTemp 一共统计了多少个*)
			{
				byModBusId = abyNeedCheckModbusIdList[iN];//索引也是从0开始的@数组值也是从0开始的
				//(*2022.6.14.115225  修改当前站判断条件bug*)
				if(byModBusId!=byCurModbusId)//(*不是当前站时 寄存器索引从0开始|循环就从0开始了*)
					iRegisterIdSa = 0;
				else
					iRegisterIdSa = (int16_t)(byCurRegisterId+1);

				//(*检查后面的寄存器是否需要操作|*)
				for(iLp=iRegisterIdSa;iLp<REGISTER_AREA_MAX;iLp++)
				{
					pstStRegisterAreaTmp = KS_GetRegAreaPointer(i_pastStData_Comm,byModBusId,iLp);
					if(pstStRegisterAreaTmp->xCommEn)//通讯使能了
					{
						byRWSts = KS_CheckRWSts_V2(pstStRegisterAreaTmp);
						if(byRWSts != 0 )//有读写操作
						{
							byCurModbusId = byModBusId;
							byCurRegisterId = (uint8_t)(iLp);
							break;//(*退出循环*)
						}
					}
				}

				if(byRWSts == 0 )//说明没找到,从第一个再次轮询。
				{
					for(iLp=0;iLp<iRegisterIdSa;iLp++)
					{
						pstStRegisterAreaTmp = KS_GetRegAreaPointer(i_pastStData_Comm,byModBusId,iLp);
						if(pstStRegisterAreaTmp->xCommEn)//通讯使能了
						{
							byRWSts = KS_CheckRWSts_V2(pstStRegisterAreaTmp);
							if(byRWSts != 0 )//有读写操作
							{
								byCurModbusId = byModBusId;
								byCurRegisterId = (uint8_t)(iLp);
								break;//(*退出循环*)
							}
						}
					}
				}
			}

			if(byRWSts!=0)//(*需要读写*)
			{
				*i_pbyCurModbusId = byCurModbusId;
				*i_pbyCurRegisterIndex = byCurRegisterId;
			}
			else//(*没事干了|赋值为最大值*)
			{
				*i_pbyCurModbusId = 255;
				*i_pbyCurRegisterIndex = 255;
			}
		}

		if(byRWSts!=0)
			*i_pbyRWSts = byRWSts;
	}
	else;
}

/*获取通讯数据|只处理的读写多个寄存器命令
	  1 写入的数据返回成功了！
	  2 读取的数据返回成功了!
	 -1 站号错误
	 -2 返回设备错误码
	 -3 功能吗错误
	 -4 读寄存器返回的字节个数错误
	 -5 写入多个寄存器 返回的地址不对
	 -6 CRC校验错误
	 -4 读多个线圈返回的字节个数错误
	 -15 写入多个线圈 返回的地址不对*/
//(*增加线圈获取处理@最小单位是一个寄存器即16个线圈@2023.4.6.141636*)
int16_t KS_GetRecvData_Comm(uint8_t i_pabyRecvData[RECEIVEBUFF_NUM],//(*收到的数据|根据通讯编码处理为正常顺序数据@0--254*)
						uint8_t i_byRecvDataNum,//(*需要接收的数据个数|用来判定是否接收完成*)
						int16_t* i_piQueueSa,//(*队列开始*)
						int16_t* i_piQueueEd,//(*队列结束*)
						uint8_t i_pabyCycleQueue[CYCLEQUEUE_NUM],//(*循环队列*)
						uint8_t* i_pbyErrCodeFrSlaver,//(*从站返回的错误码*)
						uint8_t* i_xRecvDataOk,//(*接收正确|用于反馈*)
						//(*通讯的信息*)
						uint8_t i_byModbusId,//(*id*)
						uint8_t i_byFunCode,//(*功能码*)
						uint16_t i_wAdrSa,//(*起始地址*)
						uint8_t i_byRegisterNum,//(*寄存器个数*)
						uint8_t i_xBigEndian,//(*编码顺序*)
						uint8_t i_pabyRecvDataAct[CYCLEQUEUE_NUM])//(*实际接收到的数据不分对错*))
{
	int16_t iRtnCode = 0;
	int16_t iQueueSa=*i_piQueueSa;//拿到队列头
	int16_t iQueueEd=*i_piQueueEd;//拿到队列尾
	uint32_t dwRecvDataNumAct = 0;//(*实际接收的字节*)
	uint8_t xRecvDataOk=FALSE,xBit=FALSE;
	uint16_t wTemp = 0;
	uint8_t abyRecvDataFrQueue[CYCLEQUEUE_NUM] = {0};
	uint8_t abyRecvData[RECEIVEBUFF_NUM] = {0};
	uint8_t byErrCodeFrSlaver =0 ,byDataNum_rd = 0 ;

	int16_t iCycleQueueNum_Total = CYCLEQUEUE_NUM;//(*队列大小*)
	//(*总共收到的数据个数*)
	dwRecvDataNumAct = (iQueueEd+iCycleQueueNum_Total-iQueueSa) % iCycleQueueNum_Total;
	if(dwRecvDataNumAct>RECEIVEBUFF_NUM)//超过fifo大小就不要了呗,别溢出
		dwRecvDataNumAct = RECEIVEBUFF_NUM;

	//(*取数据*)@2025.6.18.102343 获取足够了才能取数据
	for(int16_t iN = 0;iN<dwRecvDataNumAct;iN++)
	{
		iQueueSa = iQueueSa+1;
		if(iQueueSa>=iCycleQueueNum_Total)
			iQueueSa = 0;

		abyRecvDataFrQueue[iN] = i_pabyCycleQueue[iQueueSa];
	}

	if(dwRecvDataNumAct>=i_byRecvDataNum && i_byRecvDataNum!=0)//(*数据够了*)
	{
		xRecvDataOk = TRUE;


		//(*检查数据的正确性*)
		if(i_byModbusId==abyRecvDataFrQueue[0])//(*站号正确*)
		{
			//(*检查功能码*)
			//(*先检查最高位是否为1|为1代表返回错误*)
			xBit = KSGetDataBit(&abyRecvDataFrQueue[1],7);
			if(xBit)//(**)
			{
				iRtnCode = -2;
				byErrCodeFrSlaver = abyRecvDataFrQueue[2];
			}
			else
			{
				if((abyRecvDataFrQueue[1] & 0x7F)==i_byFunCode)
				{
					//(*功能吗不同返回的信息格式不同*)
					if(i_byFunCode==HOLDREGISTER_MULT_WR ||//(*写多个寄存器功能吗*)
						i_byFunCode==HOLDREGISTER_SINGLE_WR )//(*写单个寄存器*)
					{
						KS_BYTE_TO_WORD(i_xBigEndian,&(abyRecvDataFrQueue[2]), &(wTemp));//(*取地址值*)
						if(i_wAdrSa==wTemp)//(*地址相同|数据正确*);
							iRtnCode = 1;
						else
							iRtnCode = -5;
					}
					else if(i_byFunCode==HOLDREGISTER_RD)//(*读寄存器*)
					{
						byDataNum_rd = abyRecvDataFrQueue[2]; //(*返回的字节数*)
						if(byDataNum_rd==i_byRegisterNum*2)//(*读取的字节数正确*)
						{
							//(*将读取到的数据取出*)
							memcpy(&(abyRecvData),&(abyRecvDataFrQueue[3]),(int16_t)byDataNum_rd);
							if(i_xBigEndian)//(*高低取反@2023.4.6.154547*)
								KS_DataShift((uint32_t)&(abyRecvData),(int16_t)byDataNum_rd);

							iRtnCode = 2;
						}
						else//(*不正确报错*)
							iRtnCode = -4;
					}
					else if(i_byFunCode==COIL_MULT_RD)//(*读多个线圈@最小16个线圈*)
					{
						byDataNum_rd = abyRecvDataFrQueue[2]; //(*返回的字节数*)
						if(byDataNum_rd==i_byRegisterNum*2)//(*读取的字节数正确*)
						{
							//(*将读取到的数据取出*)
							memcpy(&(abyRecvData),&(abyRecvDataFrQueue[3]),byDataNum_rd);
							//(*线圈低字节在前@2023.4.6.154643*)

							iRtnCode = 2;
						}
						else//(*不正确报错*)
							iRtnCode = -14;

					}
					else if(i_byFunCode==COIL_MULT_WR)//(*写多个线圈@最小16个线圈*)
					{
						KS_BYTE_TO_WORD(i_xBigEndian,&(abyRecvDataFrQueue[2]), &(wTemp));//(*取地址值*)
						if(i_wAdrSa==wTemp)//(*地址相同|数据正确*);
							iRtnCode = 1;
						else
							iRtnCode = -15;
					}
				}
				else
					iRtnCode = -3;
			}
		}
		else
			iRtnCode = -1;
	}
	else if (dwRecvDataNumAct>=5)//(*检查返回的数据大于5个时|包含出错返回和crc校验*)//(*取数据*)
	{
		if(i_byModbusId==abyRecvDataFrQueue[0])//(*站号正确*)
		{
			//(*检查功能码*)
			//(*先检查最高位是否为1|为1代表返回错误*)
			xBit = KSGetDataBit(&abyRecvDataFrQueue[1],7);
			//2026.8.4.183349 处理要使用按位&
			//if(xBit && ((abyRecvDataFrQueue[1] && 0x7F)==i_byFunCode))//(*返回错误码*)
			if(xBit && ((abyRecvDataFrQueue[1] & 0x7F)==i_byFunCode))//(*返回错误码*)
			{
				iRtnCode = -2;
				byErrCodeFrSlaver = abyRecvDataFrQueue[2];
				xRecvDataOk = TRUE;
			}
		}
		else
			iRtnCode = -1;
	}

	//(*检查crc校验*)
	uint16_t wCrc = 0,wRecvCrc = 0;
	if(xRecvDataOk)//(*数据够了|检查crc*)
	{
		wCrc = KS_16CRC_OverWrite((uint32_t)&(abyRecvDataFrQueue),(int16_t)(dwRecvDataNumAct-2));
		KS_BYTE_TO_WORD(i_xBigEndian,&(abyRecvDataFrQueue[dwRecvDataNumAct-2]),&(wRecvCrc));
		if(wCrc==wRecvCrc)//(*校验码正确*)
			memcpy(i_pabyRecvData,abyRecvData,(int16_t)sizeof(abyRecvData));//写入到输出数组中
		else
			iRtnCode = -6;

	}

	if(xRecvDataOk)//(*数据接收成功了|更新队列起始位置*)
	{
		*i_piQueueSa = iQueueSa;
		*i_piQueueEd = iQueueEd;
	}



	if(i_pabyRecvDataAct!=0)//(*实际收到的数据*)
		memcpy(i_pabyRecvDataAct,abyRecvDataFrQueue,CYCLEQUEUE_NUM);


	if(i_xRecvDataOk!=0)
		*i_xRecvDataOk = xRecvDataOk;

	if(i_pbyErrCodeFrSlaver!=0)
		*i_pbyErrCodeFrSlaver = byErrCodeFrSlaver;


	return iRtnCode ;

}

//(*打包数据用于通过485发送|modbus协议-带crc校验
//只处理了操作寄存器功能码
//-1 指针错误
//-2 站号非法
//-3 写入寄存器个数非法
//-4 读取寄存器个数非法
//-13 写入线圈个数非法
//-14 读取线圈个数非法*)
//(*增加线圈处理@最小单位是寄存器个数-历史原因最少16个线圈@2023.4.6.130536*)
int16_t KS_PackDataToSend(uint8_t i_xFlag_DataCmd,//(*TRUE 写入数据命令标志|false代表读取数据命令*)
					uint8_t i_byType_RegisterOrCoils,//(*操作对象选择|0为线圈-1为寄存器*)
					uint8_t i_xBigEndian,//(*高低字节取反标志|有效代表会先发高字节*)
					uint8_t i_byModbusId,//(*通讯站号*)
					uint16_t i_wAdr_Rd,//(*读取寄存器的起始地址*)
					uint8_t i_byRegisterNum_Rd,//(*读取的寄存器数量@线圈个数=i_byRegisterNum_Rd*8*)
					uint16_t i_wAdr_Wr,//(*写入寄存器的起始地址*)
					uint8_t i_byRegisterNum_Wr,//(*写入的寄存器数量@线圈个数=i_byRegisterNum_Rd*8*)
					uint8_t i_pabyData_Wr[SENDBUFF_NUM],//(*写入的数据|未高低取反@包含线圈和寄存器*)
					uint8_t i_pabySendData_Buff[SENDBUFF_NUM],//(*发送的数据buff|可能为写入命令也可能为读取命令*)
					uint8_t* i_pbySendDataNum,//(*发送的字节个数*)
					uint8_t* i_pbyRecvDataNum,//(*接收到的字节个数|用于判定接收是否完成*)
					uint8_t* i_pbyFunCode)//(*功能码*)
{
	int16_t iRtn = 0 ,iFunCode = 0;
	uint8_t byRecvDataNum = 0,byDataBytes = 0,byBuffIndex = 0 ,bySendDataNum = 0;
	uint16_t wCoilsNum = 0,w16Crc =0;
	//uint32_t dwCpyNum = 0;
	uint8_t abyDataWr[SENDBUFF_NUM] = {0},abySendDataBuff[SENDBUFF_NUM] = {0};

	//(*站号合法性判断*)
	if(i_byModbusId>0 && i_byModbusId<255);
	else
		iRtn = -2;


	switch(i_byType_RegisterOrCoils)
	{
	case 0://(*操作线圈*)
		if(i_xFlag_DataCmd )//(*打包的命令为写入命令*)
		{
			if(i_byRegisterNum_Wr>0x78 || //(*超过了最大操作的线圈个数@换算成寄存器个数*)
				i_byRegisterNum_Wr==0)
				iRtn = -13;
			else
			{
				//(*操作多个线圈或者单个都是使用多个线圈命令*)
				iFunCode = COIL_MULT_WR;
				//(*返回的数据字节数|*)
				byRecvDataNum = 8;//(*响应码字节数=2(站号+功能码)+2(起始地址)+2(输出数量)+2(CRC校验码)*)

			}

			//(*拼接数据*)
			if(iFunCode==COIL_MULT_WR)//(*多个线圈的拼接*)
			{
				abySendDataBuff[0] = i_byModbusId;//(*站号*)
				abySendDataBuff[1] = (uint8_t)(iFunCode);//(**功能码*)
				//(*起始地址*)
				KS_WORD_TO_BYTE(i_xBigEndian,
								i_wAdr_Wr,
								&(abySendDataBuff[2]));//(*i_xBigEndian=FALSE [2]为低字节|[3]为高字节*)

				//(*输出数量*)
				//(*线圈个数*)
				wCoilsNum = i_byRegisterNum_Wr*2*8;//(*最小16个线圈*)
				KS_WORD_TO_BYTE(i_xBigEndian,
								wCoilsNum,
								&(abySendDataBuff[4]));//(*i_xBigEndian=FALSE [4]为低字节|[5]为高字节*)


				//(*字节个数*)
				byDataBytes = i_byRegisterNum_Wr*2;
				abySendDataBuff[6] = byDataBytes;
				//(*寄存器的值*)
				if(i_pabyData_Wr!=0 )
					memcpy(abyDataWr,i_pabyData_Wr,sizeof(abyDataWr));//(*取写入的值*)


				//(*数据拷贝到发送buff中*)
				memcpy(&(abySendDataBuff[7]),abyDataWr,byDataBytes);

				//(*CRC校验值*)
				byBuffIndex = 7+byDataBytes;
				w16Crc = KS_16CRC_OverWrite((uint32_t)abySendDataBuff,(int16_t)byBuffIndex);
				KS_WORD_TO_BYTE(i_xBigEndian,
								w16Crc,
								&(abySendDataBuff[byBuffIndex]));

				//(*发送的字节个数|包含crc*)
				bySendDataNum = byBuffIndex+2;//(*CRC存储的位置+1个字节+索引从0开始(+1)*)
				//(*数据拼接完成---------*)
			}
			else//(*else认为就是单个线圈的数据封装@未使用@最小单位是16个线圈*)
			{
				abySendDataBuff[0] = i_byModbusId;//(*站号*)
				abySendDataBuff[1] = (uint8_t)(iFunCode);//(**功能码*)
				//(*起始地址*)
				KS_WORD_TO_BYTE(i_xBigEndian,
								i_wAdr_Wr,
								&(abySendDataBuff[2]));//(*i_xBigEndian=FALSE [2]为低字节|[3]为高字节*)
				//(*寄存器的值*)
				if(i_pabyData_Wr!=0 )
					memcpy(abyDataWr,i_pabyData_Wr,sizeof(abyDataWr));//(*取写入的值*)


				//(*数据拷贝到发送buff中*)
				memcpy(&(abySendDataBuff[4]),abyDataWr,2);

				//(*CRC校验值*)
				byBuffIndex = 6;
				w16Crc = KS_16CRC_OverWrite((uint32_t)abySendDataBuff,byBuffIndex);
				KS_WORD_TO_BYTE(i_xBigEndian,
								w16Crc,
								&(abySendDataBuff[byBuffIndex]));//(*i_pabyData*));

				//(*发送的字节个数|包含crc*)
				bySendDataNum = byBuffIndex+2;//(*CRC存储的位置+1个字节+索引从0开始(+1)*)
				//(*数据拼接完成---------*)
			}
		}
		else//(*打包的命令为读取命令@最小16个线圈*)
		{
			if(i_byRegisterNum_Rd>0x78 || //(*超过了最大操作的线圈个数@换算成寄存器个数*)
				i_byRegisterNum_Rd==0 )
				iRtn = -14;
			else
			{
				iFunCode = COIL_MULT_RD;//(*都按照多个线圈处理*)
				byRecvDataNum = 5+i_byRegisterNum_Rd*2;//(*响应码字节数=3(站号+功能码+字节数)+(寄存器个数*2)+2(CRC校验码)*)
			}

			//(*拼接数据*)
			abySendDataBuff[0] = i_byModbusId;//(*站号*)
			abySendDataBuff[1] = (uint8_t)(iFunCode);//(**功能码*)
			//(*起始地址*)
			KS_WORD_TO_BYTE(i_xBigEndian,
							i_wAdr_Rd,
							&(abySendDataBuff[2]));//(*i_xBigEndian=FALSE [2]为低字节|[3]为高字节*)
			//(*线圈个数*)
			//(*线圈个数*)
			wCoilsNum = i_byRegisterNum_Rd*2*8;//(*最小16个线圈*)
			KS_WORD_TO_BYTE(i_xBigEndian,
							wCoilsNum,
							&(abySendDataBuff[4]));//(*i_xBigEndian=FALSE [4]为低字节|[5]为高字节*)

			//(*CRC校验值*)
			w16Crc = KS_16CRC_OverWrite((uint32_t)&(abySendDataBuff),6);
			KS_WORD_TO_BYTE(i_xBigEndian,
							w16Crc,
							&(abySendDataBuff[6]));
			//(*发送的字节个数|包含crc|0--7*)
			bySendDataNum = 8;
			//(*数据拼接完成---------*)
		}
		break;//2025.11.15.153626+
	default://(*操作寄存器*)
		if(i_xFlag_DataCmd)//(*打包的命令为写入命令*)
		{
			if(i_byRegisterNum_Wr>0x78 || //(*超过了最大操作的寄存器个数*)
				i_byRegisterNum_Wr==0)
				iRtn = -3;
			else
			{
				if(i_byRegisterNum_Wr==1)//(*写入单个寄存器*)
				{
					iFunCode = HOLDREGISTER_SINGLE_WR;
					byRecvDataNum = 8;//(*响应字节数=2(站号+功能码)+2(起始地址)+2个寄存器值+2(CRC校验码)*)
				}
				else
				{
					//(*操作单个和多个寄存器都是使用多个寄存器命令*)
					iFunCode = HOLDREGISTER_MULT_WR;
					//(*返回的数据字节数|*)
					byRecvDataNum = 8;//(*响应码字节数=2(站号+功能码)+2(起始地址)+2(寄存器个数)+2(CRC校验码)*)
				}
			}

			//(*拼接数据*)
			if(iFunCode==HOLDREGISTER_MULT_WR)//(*多个寄存器的拼接*)
			{
				abySendDataBuff[0] = i_byModbusId;//(*站号*)
				abySendDataBuff[1] = (uint8_t)(iFunCode);//(**功能码*)
				//(*起始地址*)
				KS_WORD_TO_BYTE(i_xBigEndian,
								i_wAdr_Wr,
								&(abySendDataBuff[2]));//(*i_xBigEndian=FALSE [2]为低字节|[3]为高字节*)
				//(*寄存器个数*)
				KS_WORD_TO_BYTE(i_xBigEndian,
								(uint16_t)(i_byRegisterNum_Wr),
								&(abySendDataBuff[4]));//(*i_xBigEndian=FALSE [4]为低字节|[5]为高字节*)
				//(*字节个数*)
				byDataBytes = i_byRegisterNum_Wr*2;
				abySendDataBuff[6] = byDataBytes;
				//(*寄存器的值*)
				if( i_pabyData_Wr!=0 )
					memcpy(abyDataWr,i_pabyData_Wr,sizeof(abyDataWr));//(*取写入的值*)

				if(i_xBigEndian )//(*高低取反*)
					KS_DataShift((uint32_t)&(abyDataWr), (uint16_t)byDataBytes);

				//(*数据拷贝到发送buff中*)
				memcpy(&(abySendDataBuff[7]),&(abyDataWr),byDataBytes);

				//(*CRC校验值*)
				byBuffIndex = 7+byDataBytes;
				w16Crc = KS_16CRC_OverWrite((uint32_t)abySendDataBuff,byBuffIndex);
				KS_WORD_TO_BYTE(i_xBigEndian,
								w16Crc,
								&(abySendDataBuff[byBuffIndex]));

				//(*发送的字节个数|包含crc*)
				bySendDataNum = byBuffIndex+2;//(*CRC存储的位置+1个字节+索引从0开始(+1)*)
				//(*数据拼接完成---------*)
			}
			else//(*else认为就是单个寄存器的数据封装*)
			{
				abySendDataBuff[0] = i_byModbusId;//(*站号*)
				abySendDataBuff[1] = (uint8_t)(iFunCode);//(**功能码*)
				//(*起始地址*)
				KS_WORD_TO_BYTE(i_xBigEndian,
								i_wAdr_Wr,
								&(abySendDataBuff[2]));//(*i_xBigEndian=FALSE [2]为低字节|[3]为高字节*)
				//(*寄存器的值*)
				if( i_pabyData_Wr!=0 )
					memcpy(abyDataWr,i_pabyData_Wr,sizeof(abyDataWr));//(*取写入的值*)

				if(i_xBigEndian )//(*高低取反*)
					KS_DataShift((uint32_t)&(abyDataWr), 2);

				//(*数据拷贝到发送buff中*)
				memcpy(&(abySendDataBuff[4]),abyDataWr,2);

				//(*CRC校验值*)
				byBuffIndex = 6;
				w16Crc = KS_16CRC_OverWrite((uint32_t)abySendDataBuff,(int16_t)byBuffIndex);
				KS_WORD_TO_BYTE(i_xBigEndian,
								w16Crc,
								&(abySendDataBuff[byBuffIndex]));

				//(*发送的字节个数|包含crc*)
				bySendDataNum = byBuffIndex+2;//(*CRC存储的位置+1个字节+索引从0开始(+1)*)
				//(*数据拼接完成---------*)
			}
		}
		else//(*打包的命令为读取命令*)
		{
			if(i_byRegisterNum_Rd>0x7D || //(*超过了最大操作的寄存器个数*)
				i_byRegisterNum_Rd==0 )
				iRtn = -4;
			else
			{
				iFunCode = HOLDREGISTER_RD;
				byRecvDataNum = 5+i_byRegisterNum_Rd*2;//(*响应码字节数=3(站号+功能码+字节数)+(寄存器个数*2)+2(CRC校验码)*)
			}

			//(*拼接数据*)
			abySendDataBuff[0] = i_byModbusId;//(*站号*)
			abySendDataBuff[1] = (uint8_t)(iFunCode);//(**功能码*)
			//(*起始地址*)
			KS_WORD_TO_BYTE(i_xBigEndian,
							i_wAdr_Rd,
							&(abySendDataBuff[2]));//(*i_xBigEndian=FALSE [2]为低字节|[3]为高字节*)
			//(*寄存器个数*)
			KS_WORD_TO_BYTE(i_xBigEndian,
							(uint16_t)(i_byRegisterNum_Rd),
							&(abySendDataBuff[4]));//(*i_xBigEndian=FALSE [4]为低字节|[5]为高字节*)

			//(*CRC校验值*)
			w16Crc = KS_16CRC_OverWrite((uint32_t)(abySendDataBuff),6);
			KS_WORD_TO_BYTE(i_xBigEndian,
							w16Crc,
							&(abySendDataBuff[6]));
			//(*发送的字节个数|包含crc|0--7*)
			bySendDataNum = 8;
			//(*数据拼接完成---------*)

		}
		break;
	}
	//(*赋值到输出buff中*)
	//i_pabySendData_Buff^ = abySendDataBuff;
	memcpy(i_pabySendData_Buff,abySendDataBuff,sizeof(abySendDataBuff));
	*i_pbySendDataNum = bySendDataNum;
	if( i_pbyFunCode!=0 )
		*i_pbyFunCode = (uint8_t)(iFunCode);

	if(i_pbyRecvDataNum!=0 )
		*i_pbyRecvDataNum = byRecvDataNum;
	return iRtn;
}

//检查数据,和备份数据对比
//返回1 有变化
//返回0 未变化
uint8_t KS_DataCmp(LP_StRegisterAreaAttibute pstStRegisterArea)
{
	uint16_t awDataTmp[MODBUS_VAR_MAX] = {0};//数据值
	uint16_t uiLenth1 = 0,uiLenth2 = 0 ,uiLenth = 0;
	uiLenth1 = sizeof(awDataTmp);//申请的数据内存大小
	uiLenth2 = pstStRegisterArea->iRegisterNum * 2;//最大要拷贝的数据
	uiLenth = uiLenth1 > uiLenth2 ? uiLenth2 : uiLenth1;//取小值@防止拷贝溢出

	memcpy(awDataTmp,(void*)pstStRegisterArea->dwDataAdrSa,uiLenth);//拷贝数据到临时数组中
	//比较
	int32_t rtn = memcmp(awDataTmp , (void*)pstStRegisterArea->awBackData , sizeof(awDataTmp));
	if(rtn)//数据有变化了
		return 1;
	else
		return 0;
}
//更新备份数据
void KS_UpdateBackData(LP_StRegisterAreaAttibute pstStRegisterArea)
{
	uint16_t uiLenth1 = 0,uiLenth2 = 0 ,uiLenth = 0;
	uiLenth1 = sizeof(pstStRegisterArea->awBackData);//备份的内存大小
	uiLenth2 = pstStRegisterArea->iRegisterNum * 2;//最大要拷贝的数据
	uiLenth = uiLenth1 > uiLenth2 ? uiLenth2 : uiLenth1;//取小值@防止拷贝溢出

	if(pstStRegisterArea != 0 )
		memcpy(&pstStRegisterArea->awBackData,(void*)pstStRegisterArea->dwDataAdrSa,uiLenth);
}

//获取寄存器区结构体地址
LP_StRegisterAreaAttibute KS_GetRegAreaPointer(StData_Comm i_pastStData[MODBUSNUM_MAX] ,uint8_t byModbusId,uint8_t byAreaId)
{
	LP_StRegisterAreaAttibute pstStRegisterAreaTmp = 0;

	if(i_pastStData != 0 &&
		byModbusId >= 0 &&
		byAreaId >= 0 && byAreaId <REGISTER_AREA_MAX)
	{
		pstStRegisterAreaTmp = &(i_pastStData[byModbusId].astStRegisterArea[byAreaId]);

		return pstStRegisterAreaTmp;
	}
	else//参数非法
		return 0;
}

//2026.6.17.102400 + 检查读写状态
/*检查是否需要进行写入或者读取动作
0无动作
1 写入
2 读取*/
uint8_t KS_CheckRWSts_V2(LP_StRegisterAreaAttibute pstStRegisterArea)//(*下标代表索引*))
{
	uint8_t rtn = 0,byRWSts = 0;
	////(*检查是否有需要再次写入的数据*)
	uint8_t* pxNeedReSend = (uint8_t*)pstStRegisterArea->dwxNeedReSendAdr;
	if(pxNeedReSend!=0)
	{
		if(*pxNeedReSend)
		{
			*pxNeedReSend = FALSE;
			if(pstStRegisterArea->byType_RW==1 ||//(*只写*)
				pstStRegisterArea->byType_RW==2)//(*读写*)
				byRWSts = 1;
		}
	}

	//(*检查是否有需要写入的数据*)
	if(byRWSts==0)//(*可以继续判断*)
	{
		if(pstStRegisterArea->byType_RW == 1 || pstStRegisterArea->byType_RW == 2)
		{
			rtn = KS_DataCmp(pstStRegisterArea);//检查寄存器数据是否发生变化
			if(rtn)//发生了变化
				byRWSts = 1;
			else;//未发生变化
		}

	}

	if(byRWSts==0)//(*没有需要写入|决定是否需要读取*)
	{
		switch(pstStRegisterArea->byType_RW)//(*检查读状态*)
		{
			case 0:
			case 2://(*只读或者读写*)
				byRWSts = 2;
				break;
			default:break;
		}
	}

	return byRWSts;
}
//485主站通讯实现函数
//输入数组加上个数，只是为了明确大小,对于实际实现没有帮助
void KSModbus485_Master(
		uint8_t i_xEn,//通讯使能
		StData_Comm i_pastStData[MODBUSNUM_MAX],//(*下标代表索引*)
		//(*数据地址列表|一维索引代表站号-二维索引为区块分类*)
		//StModbusDataAdrList i_paStDataList[MODBUSNUM_MAX][REGISTER_AREA_MAX],//所有通讯数据列表
		uint8_t i_byModbusNum_Max,//(*最大的设备个数|*)
		uint8_t i_pabyModbusIdList[MODBUSNUM_MAX],//(*modbusid列表|下标代表索引*)
		uint8_t i_paxModbusCommEnList[MODBUSNUM_MAX],//(*modbus站通讯使能列表|下标代表索引*)
		uint8_t i_paxRegisterAreaCommEnList[MODBUSNUM_MAX][REGISTER_AREA_MAX],//(*站的 寄存器区使能标志|最大5个区*)
		LP_VisuCommData i_pstVisuCommData,//通讯的数据

		//输出的数据
		//(*修改为数组变量-2021.7.16.170008*)
		uint16_t o_auiSendDataCnt[MODBUSNUM_MAX],//发送的计数
		uint16_t o_auiRecvDataCnt[MODBUSNUM_MAX],//接收的计数
		uint16_t o_auiRecvErrDataCnt[MODBUSNUM_MAX],//接收出错的计数
		uint16_t o_auiTimeOutDataCnt[MODBUSNUM_MAX],//超时计数
		uint8_t o_axConnectOk[MODBUSNUM_MAX],//通讯正常标志
		uint8_t o_abyErrCodeFrSlav[MODBUSNUM_MAX],/*(*设备返回错误码|响应功能码 = 请求功能码+0x80
																				01 非法功能码
																				02 非法地址
																				03 非法数据
																				04 服务器故障
																				05 确认
																				06 服务器繁忙
																				0A 0B 网关故障-具体信息详见Modbus协议中文版.pdf中113页*)
																				*/

		int16_t o_aiErrCode[10],//(*返回的错误码*)
		uint8_t* pbyCurModbusIdIndex,//当前的站id索引从0开始
		uint8_t* pbyCurRegisterIndex)//当前的寄存器索引从0开始
{
	//定义静态
	//static uint8_t axPrevModbusCommen[MODBUSNUM_MAX] = {0};//通讯使能打开备份值
	static uint8_t xQueueInitDne = FALSE;//(*复位初始化标志|在退出时重新初始化*)
	static uint8_t byRecvDataNum = 0,byCurModbusIdAct = 0,byFunCode = 0,byRegisterNum = 0;
	static uint8_t bySendNum = 0;
	static uint16_t wAdrSa = 0;
	static uint8_t xInit = FALSE;//参数初始化@2025.8.5.212837+

	//定义局部
	//LP_StModbusDataAdrList pstDataList = 0;
	//LP_StData_Comm 				pstStDataTmp = 0;//2026.6.17.083207+
	LP_StRegisterAreaAttibute 	pstStRegisterAreaTmp = 0;//2026.6.17.083336+

	uint8_t xWr = FALSE;//有效了只执行一次
	uint8_t xRd = FALSE;//有效了只执行一次
	static uint8_t xWring = FALSE;
	static uint8_t xRding = FALSE;
	static uint8_t byCurModbusIdIndex = 0;
	static uint8_t byCurRegisterIndex = 0;
	uint8_t xCanDealModbusData = FALSE;


	//uint8_t xModbusCommenTrig = FALSE;//通讯使能触发沿
	uint8_t axModbusCommen[MODBUSNUM_MAX] = {0},\
			abyModbusIdList[MODBUSNUM_MAX] = {0},\
			axRegisterAreaCommEnList[MODBUSNUM_MAX][REGISTER_AREA_MAX] = {0};
	uint8_t abyData_Wr[SENDBUFF_NUM] = {0};//写入的数据数组
	//uint8_t abySendDataBuff[SENDBUFF_NUM] = {0};//发送的数据buff
	uint8_t byModbusNum_Max = 0;
	uint16_t uiTimeOutTime = 0;//
//	uint16_t tTime_DelaySend = 0;//
	int16_t iModbusNumIndex = 0;//iRegisterAreaIndex = 0;
	//uint16_t* pwData = 0;
	//uint16_t* pwDataBack = 0;

	int16_t iRtn_RecvData = 0 ,iIndexWatch = 0 ;//iN = 0,iLp = 0 ,iDataIndex=0;
	uint8_t abyRecvData[RECEIVEBUFF_NUM] = {0},abyRecvDataAct[CYCLEQUEUE_NUM] = {0};
	static uint16_t auiRetainTimeOutCnt[MODBUSNUM_MAX]={0}/*,auiTimeOutDataCntBak[MODBUSNUM_MAX]={0}*/;
	uint8_t byErrCodeFrSlav = 0 ;//byType_RW = 0;
	uint8_t xBigEndian = TRUE,xThrowDataRdBack =FALSE ,xTimeOut = FALSE;
	uint8_t xDataRecvDne = FALSE;
	//uint16_t* pawRecvData;//word数据指针@按照数组访问
	//uint8_t xNextRegister_Delay = FALSE;
	static uint8_t xNextRegister = TRUE;
	uint8_t byRWSts = 0;
	uint32_t dwDataAdr = 0;
	uint8_t rtn = 0;

	//(*处理通讯的数据信息|Liu.yt*)
	uiTimeOutTime = TIME_TIMEOUT;

	if(i_xEn)
	{//else的时候需要axPrevModbusCommen = false
		//(*根据色组个数处理最大循环的MODBUSNUM*)
		byModbusNum_Max = i_byModbusNum_Max;
		if(i_byModbusNum_Max>MODBUSNUM_MAX)
			byModbusNum_Max = MODBUSNUM_MAX;

		//(*拿到使能标志*)
		memcpy(axModbusCommen,i_paxModbusCommEnList,sizeof(axModbusCommen));

		//(*拿到站号列表*)
		memcpy(abyModbusIdList,i_pabyModbusIdList,sizeof(abyModbusIdList));

		//拿到寄存器通讯使能标志
		memcpy(axRegisterAreaCommEnList,i_paxRegisterAreaCommEnList,sizeof(axRegisterAreaCommEnList));

		//(*通讯参数获取----------------------------------------*)
		//通讯使能打开了|
//		if(axModbusCommen[iModbusNumIndex] && !axPrevModbusCommen[iModbusNumIndex])
//		{
//			xModbusCommenTrig = TRUE;
//			xInit = FALSE;//在初始化一次
//		}
//
//		axPrevModbusCommen[iModbusNumIndex] = axModbusCommen[iModbusNumIndex];




		//(*数据初始化|Liu.yt---------------------------------------------------------------Start*)
		for( iModbusNumIndex = 0; iModbusNumIndex<byModbusNum_Max;iModbusNumIndex++)
		{
			KS_DataInit_Comm_485_V2(xInit,//&xInit,
						axModbusCommen[iModbusNumIndex],//通讯使能标志@写入到i_pastStData中
						abyModbusIdList[iModbusNumIndex],//id列表@写入到i_pastStData中
						axRegisterAreaCommEnList[iModbusNumIndex],//寄存器区使能标志
						&(i_pastStData[iModbusNumIndex]),//处理的通讯数据
						i_pstVisuCommData);//实际通讯的结构体@写入到i_pastStData中
	//
	//			KS_DataInit_Comm_485(axModbusCommen[iModbusNumIndex],//通讯使能标志@写入到i_pastStData中
	//						abyModbusIdList[iModbusNumIndex],//id列表@写入到i_pastStData中
	//						axRegisterAreaCommEnList[iModbusNumIndex],//寄存器区使能标志
	//						&(i_pastStData[iModbusNumIndex]),//处理的通讯数据
	//						i_pstVisuCommData);//实际通讯的结构体@写入到i_pastStData中
			//(*获取数据列表*)
			//pstDataList = &(i_paStDataList[iModbusNumIndex][0]);
			//KS_GetDataList_V2(xInit,&(i_pastStData[iModbusNumIndex]),pstDataList);//只有标志是周期性更新的
			//KS_GetDataList(&(i_pastStData[iModbusNumIndex]),pstDataList);

	//		if(xModbusCommenTrig)//(*通讯使能打开的时候再触发一次*)
	//		{
	//			for(iRegisterAreaIndex = 0;iRegisterAreaIndex< REGISTER_AREA_MAX ;iRegisterAreaIndex++)//(*寄存器区个数*)
	//			{
					//pstDataList = &(i_pastStData[iModbusNumIndex][iRegisterAreaIndex]);
					//(*对每一个需要写入的数据的备份值和实际值写不同，用来触发写入动作|+1*)
	//				for( iLp = 0 ;iLp < pstStRegisterAreaTmp->iRegisterNum;iLp++)
	//				{
	//					pwData = (uint16_t*)(pstDataList->astDataAdrList[iLp].dwDataAdr);
	//					pwDataBack = (uint16_t*)(pstDataList->astDataAdrList[iLp].dwDataBakAdr);
	//					if(pwData!=0 && pwDataBack!=0)
	//					{
	//						//(*有写动作的执行+1*)
	//						if(pstDataList->astDataAdrList[iLp].byType_RW==1 ||
	//							pstDataList->astDataAdrList[iLp].byType_RW==2 )
	//							*pwDataBack = *pwData+1;
	//
	//					}
	//				}

	//			}//内存for循环
	//		}
		}//外层for循环

		xInit = TRUE;//置位初始化标志@2025.8.7.145956+|保证初始化只执行一次

		//(*从循环队列中取出接收的完整数据*)
		iRtn_RecvData = KS_GetRecvData_Comm(abyRecvData,
										byRecvDataNum,
										&(g_iQueueSa),//队列起始
										&(g_iQueueEd),//队列结束
										g_abyCycleQueue,//队列中的数据
										&(byErrCodeFrSlav),
										&(xDataRecvDne),
										byCurModbusIdAct,
										byFunCode,
										wAdrSa,
										byRegisterNum,
										xBigEndian,
										abyRecvDataAct);

		if(xDataRecvDne)//(*数据成功接收了*)
		{
			if(byCurModbusIdIndex>=0 &&
				byCurModbusIdIndex<MODBUSNUM_MAX &&
				byCurRegisterIndex>=0 &&
				byCurRegisterIndex<REGISTER_AREA_MAX)
			{
				//pstDataList = &(i_paStDataList[byCurModbusIdIndex][byCurRegisterIndex]);
				pstStRegisterAreaTmp = KS_GetRegAreaPointer(i_pastStData,byCurModbusIdIndex,byCurRegisterIndex);
				if( iRtn_RecvData==1)//(*写入的数据返回来了，更新备份数据*)
				{
//					for(iN = 0;iN<pstDataList->iRegisterNum;iN++)
//					{
//						pwData = (uint16_t*)pstDataList->astDataAdrList[iN].dwDataAdr;
//						pwDataBack = (uint16_t*)pstDataList->astDataAdrList[iN].dwDataBakAdr;
//						if(pwData!=0 && pwDataBack!=0 )
//							*pwDataBack = pstDataList->awData_Wr[iN];//(*2023.7.20.191056|bug修复*)
//
//					}
					KS_UpdateBackData(pstStRegisterAreaTmp);//更新备份值
				}
				else if(iRtn_RecvData==2)//(*读取的数据返回来了，同时更新读写属性的备份数据*)
				{
					//(*检查备份值有没有发生变化|变化了认为上位机需要写入|则丢掉读回来的数据*)
//					for(iN=0;iN<pstDataList->iRegisterNum;iN++)
//					{
//						pwData = (uint16_t*)(pstDataList->astDataAdrList[iN].dwDataAdr);
//						pwDataBack = (uint16_t*)(pstDataList->astDataAdrList[iN].dwDataBakAdr);
//						byType_RW = pstDataList->astDataAdrList[iN].byType_RW;
//
//						if(byType_RW==1 || byType_RW==2)//(*只检查写和读写的数据*)
//						{
//							if(pwData!=0 && pwDataBack!=0)
//							{
//								if(*pwData!=*pwDataBack)//(*上位机需要写入*)
//									xThrowDataRdBack = TRUE;//(*扔掉读取回来的数据*)
//
//							}
//						}
//					}
					//只检查有写入需求的
					if(pstStRegisterAreaTmp->byType_RW == 1 || pstStRegisterAreaTmp->byType_RW == 2)
					{
						rtn = KS_DataCmp(pstStRegisterAreaTmp);//检查数据是否发生变化
						if(rtn)//数据发生变化了@上位机需要写入
							xThrowDataRdBack = TRUE;
						else;//数据未变化
					}

					//(*写入到备份数据中*)
					if(!xThrowDataRdBack)
					{
//						//memcpy(awDataRecv_RW,abyRecvData,pstDataList->iRegisterNum*2);
//						pawRecvData = (uint16_t*)abyRecvData;//按照word获取
//						//(*更新到实际变量中*)
//						for(iN=0;iN<pstDataList->iRegisterNum;iN++)
//						{
//							pwData = (uint16_t*)(pstDataList->astDataAdrList[iN].dwDataAdr);
//							pwDataBack = (uint16_t*)(pstDataList->astDataAdrList[iN].dwDataBakAdr);
//							//(*读写属性获取代码缺失@2024.11.6.135924*)
//							byType_RW = pstDataList->astDataAdrList[iN].byType_RW;
//							if(pwData!=0)
//							{
//								//(*2022.10.22.134713*)
//								if( byType_RW==0 || byType_RW==2)//(*只读和读写的更新*)
//									*pwData = pawRecvData[iN];
//
//							}
//							if(pwDataBack!=0)
//								*pwDataBack = pawRecvData[iN];
//
//						}
						//读取到的数据更新到本地
						memcpy((void*)pstStRegisterAreaTmp->dwDataAdrSa,abyRecvData,pstStRegisterAreaTmp->iRegisterNum * 2);

						KS_UpdateBackData(pstStRegisterAreaTmp);//更新备份值
					}
				}
				else if(iRtn_RecvData<0)
				{
					if(byCurModbusIdIndex>=0 && byCurModbusIdIndex<MODBUSNUM_MAX)
						o_auiRecvErrDataCnt[byCurModbusIdIndex] = o_auiRecvErrDataCnt[byCurModbusIdIndex]+1;

					//(*错误监控*)
					iIndexWatch = iIndexWatch+1;
					if(iIndexWatch>=10)
						iIndexWatch = 0;
					o_aiErrCode[iIndexWatch] = iRtn_RecvData;
				}
			}
		}


		//(*接收后执行下次动作逻辑|Liu.yt----------------------Start*)
		if(xWring || xRding)//(*处于读写过程中|未使用上面反馈的超时标志-重新处理超时*)
		{
			//(*超时处理*)
			if(g_uiTimeOutTimer > uiTimeOutTime)
			{
				xTimeOut = TRUE;//(*超时标志*)

			}


			if( xDataRecvDne ||//(*数据读取成功了*)
				xTimeOut)//(*超时了*)
			{
				g_uiTimeOutTimer = 0;//清除超时计数
				xWring = FALSE;//写入中
				xRding = FALSE;//读取中
				xNextRegister = TRUE;//(*切换*)
				g_xDataSendDne = FALSE;//(*接收完了|清除发送完成标志*)
				//xDataRecvDne = FALSE;//(*清除接收完成标志*)

				if(byCurModbusIdIndex>=0 &&
					byCurModbusIdIndex<byModbusNum_Max)
				{
					o_axConnectOk[byCurModbusIdIndex] = TRUE;
					if(xTimeOut)
					{
						o_auiTimeOutDataCnt[byCurModbusIdIndex] = o_auiTimeOutDataCnt[byCurModbusIdIndex]+1;
						if( auiRetainTimeOutCnt[byCurModbusIdIndex]>=10 )//(*连续10个数据都超时|我们认为断线了*)
							o_axConnectOk[byCurModbusIdIndex] = FALSE;
						else
							auiRetainTimeOutCnt[byCurModbusIdIndex] = auiRetainTimeOutCnt[byCurModbusIdIndex]+1;

					}
					else//(*没有超时*)
					{
						auiRetainTimeOutCnt[byCurModbusIdIndex] = 0;
						o_auiRecvDataCnt[byCurModbusIdIndex] = o_auiRecvDataCnt[byCurModbusIdIndex]+1;
						o_abyErrCodeFrSlav[byCurModbusIdIndex] = byErrCodeFrSlav;
					}
				}
			}
		}


		//(*通讯周期计时器处理*)
		xCanDealModbusData = FALSE;
		if((g_uiCycleCommTimer > TIME_COMMCYCLE && TIME_COMMCYCLE!=0) || (TIME_COMMCYCLE == 0))//(*时间到了干一次*)
		{
			//xCanDealModbusData = TRUE;//(*可以处理modbus数据了@2023.4.6.090731*)
			xCanDealModbusData = xNextRegister;
			if(xNextRegister)//通讯下一个
				g_uiCycleCommTimer = 0;//重新启动计时器
		}


		if(xCanDealModbusData)//(*处理数据@2023.4.6.090859*)
		{
			//(*顺序处理一个寄存器区*)
			 KS_GetNextRegister(
					xNextRegister,
					i_pastStData,
					//i_paStDataList,
					&(byCurModbusIdIndex),
					&(byCurRegisterIndex),
					&(byRWSts),
					(byModbusNum_Max));

			if(!(byCurModbusIdIndex==255 || byCurRegisterIndex==255))//(*2021.9.9.162213 增加有事情干的时候清除标志|
																//否则该标志一致保持|没有该条件可能会把标志清除而不会在进行通讯*)
			{
				//xNextRegister_Delay = FALSE;//(*有效一个周期*)
				xNextRegister = FALSE;
			}

			//(*取modbusid*)
			if(byCurModbusIdIndex>=0 && byCurModbusIdIndex<byModbusNum_Max)
				byCurModbusIdAct = abyModbusIdList[byCurModbusIdIndex];
			else//(*索引非法|实际站号也使用非法*)
				byCurModbusIdAct = 255;



			if(byCurModbusIdIndex==255 ||
				byCurRegisterIndex==255);//(*没有数据需要处理*);
			else//(*有数据需要处理*)
			{
				if(byRWSts==1)//(*执行写入*)
				{
					if(!xWring && !xRding)
					{
						xWring = TRUE;
						xWr = TRUE;
					}
				}
				else if (byRWSts==2)//(*执行读取*)
				{
					if(!xWring && ! xRding)
					{
						xRding = TRUE;
						xRd = TRUE;
					}
				}

				if(xWr || xRd)
					g_uiTimeOutTimer = 0;//读写数据的时候清除

			}
		}
		else;//(*不能处理数据@2023.4.6.091913*);


		//(*不使用下面的读取和写入数据逻辑
		//但是基本结构还是参照下面的！*)

		if(xWr)//(*写入*)
		{
			//pstDataList = &(i_paStDataList[byCurModbusIdIndex][byCurRegisterIndex]);
			pstStRegisterAreaTmp = KS_GetRegAreaPointer(i_pastStData,byCurModbusIdIndex,byCurRegisterIndex);
			wAdrSa = pstStRegisterAreaTmp->wModbusAdr;
			byRegisterNum = (uint8_t)(pstStRegisterAreaTmp->iRegisterNum);
			//(*处理写入的数据*)
			dwDataAdr = pstStRegisterAreaTmp->dwDataAdrSa;//把起始地址获取到
			memcpy(abyData_Wr,(void*)dwDataAdr,byRegisterNum * 2);//拷贝到目标数组中

			//拼包
			KS_PackDataToSend(
				TRUE,//(*i_xFlag_DataCmd*),
				1,//(*i_byType_RegisterOrCoils*),
				xBigEndian,//(*i_xBigEndian*),
				byCurModbusIdAct,//(*i_byModbusId*),
				0,//(*i_wAdr_Rd*),
				0,//(*i_byRegisterNum_Rd*),
				wAdrSa,//(*i_wAdr_Wr*),
				byRegisterNum,//(*i_byRegisterNum_Wr*),
				(abyData_Wr),//(*i_pabyData_Wr*),
				(g_abySendDataBuff),//(*i_pabySendData_Buff*),
				&(bySendNum),//(*i_pbySendDataNum*),
				&(byRecvDataNum),//(*i_pbyRecvDataNum*),
				&(byFunCode));//(*i_pbyFunCode*));
			g_iNeedSendNum = bySendNum;
			pstStRegisterAreaTmp->byFunCode = byFunCode;
			//(*实际发送和接收数据个数写入*)
		}
		else if(xRd)//(*读取*)
		{
			//pstDataList = &(i_paStDataList[byCurModbusIdIndex][byCurRegisterIndex]);
			pstStRegisterAreaTmp = KS_GetRegAreaPointer(i_pastStData,byCurModbusIdIndex,byCurRegisterIndex);
			wAdrSa = pstStRegisterAreaTmp->wModbusAdr;
			byRegisterNum = (uint8_t)(pstStRegisterAreaTmp->iRegisterNum);
			//拼包
			KS_PackDataToSend(
				FALSE,//(*i_xFlag_DataCmd*),
				1,//(*i_byType_RegisterOrCoils*),
				xBigEndian,//(*i_xBigEndian*),
				byCurModbusIdAct,//(*i_byModbusId*),
				wAdrSa,//(*i_wAdr_Rd*),
				byRegisterNum,//(*i_byRegisterNum_Rd*),
				0,//(*i_wAdr_Wr*),
				0,//(*i_byRegisterNum_Wr*),
				0,//(*i_pabyData_Wr*),
				(g_abySendDataBuff),//(*i_pabySendData_Buff*),
				&(bySendNum),//(*i_pbySendDataNum*),
				&(byRecvDataNum),//(*i_pbyRecvDataNum*),
				&(byFunCode));//(*i_pbyFunCode*));

			g_iNeedSendNum = bySendNum;
			pstStRegisterAreaTmp->byFunCode = byFunCode;
			//(*实际发送和接收数据个数写入*)
		}

		if(xWr || xRd)//只会有效一个周期
		{
			KSStartSendBuffByIRQ();//启动发送中断

			if(byCurModbusIdIndex>=0 && byCurModbusIdIndex<byModbusNum_Max)
				o_auiSendDataCnt[byCurModbusIdIndex] = o_auiSendDataCnt[byCurModbusIdIndex]+1;
		}
		else;

	}
	else
	{
		if(!xQueueInitDne)//(*未初始化完成了*)
		{
			KS_InitQueue((uint32_t)g_abyCycleQueue,//(*i_dwQueueAdrSa*),
						sizeof(g_abyCycleQueue),//(*i_iQueueLen*),
						&(g_iQueueSa),//(*i_piQueueSa*),
						&(g_iQueueEd));//(*i_piQueueEd*));
			xQueueInitDne = TRUE;
		}
	}

	*pbyCurModbusIdIndex = byCurModbusIdIndex;
	*pbyCurRegisterIndex = byCurRegisterIndex;


}


//2025.8.7.142316 通讯初始化-周期执行初始化使能标志@其他不变参数只执行一次
//所有内容周期执行耗时比较久
//2026.6.17.082713 修改为只处理连续区的数据通讯
void KS_DataInit_Comm_485_V2(
					uint8_t i_xInitData,//初始化标志|内部置位@控制固有参数只更新一次,使能参数周期更新
					uint8_t i_xCommEn,//通讯使能标志@写入到StData_Comm中
					uint8_t i_byModbusId,//通讯的站号@写入到StData_Comm中
					uint8_t i_paxRegisterAreaCommEn[REGISTER_AREA_MAX],//@写入到StData_Comm中
					StData_Comm* i_pstStData_Comm,//通讯的数据初始化|
					LP_VisuCommData pstVisuCommData)//这里只声明@实现还没做
{
	LP_StRegisterAreaAttibute pstStRegisterArea = 0;//寄存器区属性
	//LP_StDataAttribute pstStDataAttribute = 0;//寄存器区内每个寄存器的属性
	uint8_t xRegisterAreaEn = FALSE;
	uint16_t* pAdrSa=0;//首地址@通讯结构体的第一个变量地址
	uint16_t* pAdrSaTmp=0;//首地址临时变量@通讯结构体的第一个变量地址
	uint16_t uiRegisterNum=0,i = 0,j = 0,uiAreaId = 0;//寄存器个数
	uint16_t uiRegisterAdrSa = 0;//寄存器起始地址
	uint16_t uiRegisterAdrSaTmp = 0;//一个临时变量
	uint32_t dwReSendAllDataAdr = 0;
	uint8_t xInitData =  i_xInitData;//2025.8.7.143045+初始化标志
//	if(i_pxInitData !=0)
//		xInitData =  *i_pxInitData;
	//写入配置的站号
	i_pstStData_Comm->byModbusId = i_byModbusId;
	i_pstStData_Comm->xCommEn = i_xCommEn;


	if(!xInitData)
	{
		/***********************************************RW*****************************************************/
		//读写
		//寄存器区的内容获取
		//第一区@双向通讯
		pAdrSa = (uint16_t*)&pstVisuCommData->data_RW.byHMI_Cnt;//发送的数据起始地址
		uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->data_RW));//获取寄存器个数
		uiRegisterNum = 120;
		dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[0];
		uiAreaId = 0;//寄存器区id
		uiRegisterAdrSa = 3120;//寄存器起始地址


		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
		//寄存器区属性设置
		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
		pstStRegisterArea->byType_RW = 2;//读写方式
		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
		pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
		pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 2;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}



		/***********************************************WO-Dyan*****************************************************/
		//只写@变化频繁
		//寄存器区的内容获取
		//第二区
		pAdrSa = (uint16_t*)&pstVisuCommData->dynaData_WO.aiErrorBuff_V[0];
		uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->dynaData_WO));//获取寄存器个数
		dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[1];
		uiAreaId = 1;//寄存器区id
		uiRegisterAdrSa = 0;//寄存器起始地址


		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
		//寄存器区属性设置
		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
		pstStRegisterArea->byType_RW = 1;//读写方式
		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
		pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
		pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}


		/***********************************************WO-Std*****************************************************/
		//只写@变化不频繁
		//寄存器区的内容获取
		//第三区
		pAdrSa = (uint16_t*)&pstVisuCommData->stdData_WO.wGirth;
		uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->stdData_WO));//获取寄存器个数
		dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[2];
		uiAreaId = 2;//寄存器区id
		uiRegisterAdrSa = 360;//寄存器起始地址


		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
		//寄存器区属性设置
		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
		pstStRegisterArea->byType_RW = 1;//读写方式
		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
		pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
		pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}



		/***********************************************采样数据@第一路数据和第二路数据@需要7个包*****************************************************/
		//只写
		//寄存器区的内容获取
		//第四~十区@每个区刚好120word
		pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_1[0];
		for(j=0;j<7;j++)
		{
			uiRegisterNum = 120;
			uiAreaId = 3+j;//寄存器区id@3--9
			uiRegisterAdrSa = 600 + uiRegisterNum * j;//寄存器起始地址
			pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始


			pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
			xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
			//寄存器区属性设置
			pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
			pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
			pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
			pstStRegisterArea->byType_RW = 1;//读写方式
			pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
			pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
			pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
			//寄存器区内数据设置
//			for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//			{
//				pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//				pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//				pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//				pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//			}
		}

		/***********************************************采样数据@剩余4路数据轮询发送|每一路共4个包每个包按照100word封装*****************************************************/
		//可以再外围套4个循环,有点复杂就铺开写了
		//剩余第一路@四个区
		//第十一~十四区@每个区100word
		pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_3[0];
		//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
		uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
		for(j=0;j<4;j++)
		{
			uiRegisterNum = 100;//获取寄存器个数
			uiAreaId = 10 + j;//寄存器区id@10--13
			uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
			pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始


			pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
			xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
			//寄存器区属性设置
			pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
			pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
			pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
			pstStRegisterArea->byType_RW = 1;//读写方式
			pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
			pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
			pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
			//寄存器区内数据设置
//			for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//			{
//				pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//				pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//				pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//				pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//			}
		}

		//剩余第二路@四个区
		//第十五~十八区@每个区100word
		pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_4[0];
		//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
		uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
		for(j=0;j<4;j++)
		{
			uiRegisterNum = 100;//获取寄存器个数
			uiAreaId = 14 + j;//寄存器区id@14--17
			uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
			pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始

			pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
			xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
			//寄存器区属性设置
			pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
			pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
			pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
			pstStRegisterArea->byType_RW = 1;//读写方式
			pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
			pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
			pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
			//寄存器区内数据设置
//			for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//			{
//				pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//				pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//				pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//				pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//			}
		}

		//剩余第三路@四个区
		//第十九~二十二区@每个区100word
		pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_5[0];
		//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
		uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
		for(j=0;j<4;j++)
		{
			uiRegisterNum = 100;//获取寄存器个数
			uiAreaId = 18 + j;//寄存器区id@18--21
			uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
			pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始

			pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
			xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
			//寄存器区属性设置
			pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
			pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
			pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
			pstStRegisterArea->byType_RW = 1;//读写方式
			pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
			pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
			pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
			//寄存器区内数据设置
//			for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//			{
//				pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//				pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//				pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//				pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//			}
		}


		//剩余第四路@四个区
		//第二十三~二十六区@每个区100word
		pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_6[0];
		//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
		uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
		for(j=0;j<4;j++)
		{
			uiRegisterNum = 100;//获取寄存器个数
			uiAreaId = 22 + j;//寄存器区id@22--25
			uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
			pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始


			pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
			xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
			//寄存器区属性设置
			pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
			pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
			pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
			pstStRegisterArea->byType_RW = 1;//读写方式
			pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
			pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
			pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
			//寄存器区内数据设置
//			for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//			{
//				pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//				pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//				pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//				pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//			}
		}



		//2026.1.27.161522  再扩展一个区-快速变化的只写
		/***********************************************WO-Dyan*****************************************************/
		//只写@变化频繁
		//寄存器区的内容获取
		//第二十七区
		pAdrSa = (uint16_t*)&pstVisuCommData->dynaData_WO_Ex.wSa;
		uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->dynaData_WO_Ex));//获取寄存器个数
		dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[3];
		uiAreaId = 26;//寄存器区id@Id是数组索引
		uiRegisterAdrSa = 120;//寄存器起始地址


		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
		//寄存器区属性设置
		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
		pstStRegisterArea->byType_RW = 1;//读写方式
		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
		pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
		pstStRegisterArea->dwDataAdrSa = (uint32_t)pAdrSa;//数据的起始地址
		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}

		//xInitData = TRUE;
	}
	else//初始化完成@只更新标志通讯使能bit
	{
		for(i=0;i<REGISTER_AREA_MAX;i++)
		{
			pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[i];//寄存器区首地址
			xRegisterAreaEn = i_paxRegisterAreaCommEn[i];//寄存器区使能标志
			//寄存器区属性设置
			pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
		}
	}

//	//更新初始化
//	if(i_pxInitData !=0)
//		*i_pxInitData = xInitData;
}

////485通讯数据的初始化@单个站
////注意：里面的执行顺序不能随意调整
////一共配置了26个区
////只执行一次@耗时比较久
//void KS_DataInit_Comm_485(
//					uint8_t i_xCommEn,//通讯使能标志@写入到StData_Comm中
//					uint8_t i_byModbusId,//通讯的站号@写入到StData_Comm中
//					uint8_t i_paxRegisterAreaCommEn[REGISTER_AREA_MAX],//@写入到StData_Comm中
//					StData_Comm* i_pstStData_Comm,//通讯的数据初始化|
//					LP_VisuCommData pstVisuCommData)//这里只声明@实现还没做
//{
//
//	LP_StRegisterAreaAttibute pstStRegisterArea = 0;//寄存器区属性
//	LP_StDataAttribute pstStDataAttribute = 0;//寄存器区内每个寄存器的属性
//	uint8_t xRegisterAreaEn = FALSE;
//	uint16_t* pAdrSa=0;//首地址@通讯结构体的第一个变量地址
//	uint16_t* pAdrSaTmp=0;//首地址临时变量@通讯结构体的第一个变量地址
//	uint16_t uiRegisterNum=0,i = 0,j = 0,uiAreaId = 0;//寄存器个数
//	uint16_t uiRegisterAdrSa = 0;//寄存器起始地址
//	uint16_t uiRegisterAdrSaTmp = 0;//一个临时变量
//	uint32_t dwReSendAllDataAdr = 0;
//
//
//	//写入配置的站号
//	i_pstStData_Comm->byModbusId = i_byModbusId;
//	i_pstStData_Comm->xCommEn = i_xCommEn;
//
//
//
//	/***********************************************RW*****************************************************/
//	//读写
//	//寄存器区的内容获取
//	//第一区@双向通讯
//	pAdrSa = (uint16_t*)&pstVisuCommData->data_RW.byHMI_Cnt;//发送的数据起始地址
//	uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->data_RW));//获取寄存器个数
//	uiRegisterNum = 120;
//	dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[0];
//	uiAreaId = 0;//寄存器区id
//	uiRegisterAdrSa = 3120;//寄存器起始地址
//
//
//	pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//	xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//	//寄存器区属性设置
//	pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//	pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//	pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//	pstStRegisterArea->byType_RW = 2;//读写方式
//	pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//	pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
//	//寄存器区内数据设置
//	for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//	{
//		pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//		pstStDataAttribute->byType_RW = 2;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//		pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//		pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//	}
//
//
//
//	/***********************************************WO-Dyan*****************************************************/
//	//只写@变化频繁
//	//寄存器区的内容获取
//	//第二区
//	pAdrSa = (uint16_t*)&pstVisuCommData->dynaData_WO.aiErrorBuff_V[0];
//	uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->dynaData_WO));//获取寄存器个数
//	dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[1];
//	uiAreaId = 1;//寄存器区id
//	uiRegisterAdrSa = 0;//寄存器起始地址
//
//
//	pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//	xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//	//寄存器区属性设置
//	pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//	pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//	pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//	pstStRegisterArea->byType_RW = 1;//读写方式
//	pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//	pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
//	//寄存器区内数据设置
//	for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//	{
//		pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//		pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//		pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//		pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//	}
//
//
//	/***********************************************WO-Std*****************************************************/
//	//只写@变化不频繁
//	//寄存器区的内容获取
//	//第三区
//	pAdrSa = (uint16_t*)&pstVisuCommData->stdData_WO.wGirth;
//	uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->stdData_WO));//获取寄存器个数
//	dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[2];
//	uiAreaId = 2;//寄存器区id
//	uiRegisterAdrSa = 360;//寄存器起始地址
//
//
//	pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//	xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//	//寄存器区属性设置
//	pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//	pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//	pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//	pstStRegisterArea->byType_RW = 1;//读写方式
//	pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//	pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
//	//寄存器区内数据设置
//	for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//	{
//		pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//		pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//		pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//		pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//	}
//
//
//
//	/***********************************************采样数据@第一路数据和第二路数据@需要7个包*****************************************************/
//	//只写
//	//寄存器区的内容获取
//	//第四~十区@每个区刚好120word
//	pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_1[0];
//	for(j=0;j<7;j++)
//	{
//		uiRegisterNum = 120;
//		uiAreaId = 3+j;//寄存器区id@3--9
//		uiRegisterAdrSa = 600 + uiRegisterNum * j;//寄存器起始地址
//		pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始
//
//
//		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//		//寄存器区属性设置
//		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//		pstStRegisterArea->byType_RW = 1;//读写方式
//		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//		pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
//		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}
//	}
//
//	/***********************************************采样数据@剩余4路数据轮询发送|每一路共4个包每个包按照100word封装*****************************************************/
//	//可以再外围套4个循环,有点复杂就铺开写了
//	//剩余第一路@四个区
//	//第十一~十四区@每个区100word
//	pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_3[0];
//	//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
//	uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
//	for(j=0;j<4;j++)
//	{
//		uiRegisterNum = 100;//获取寄存器个数
//		uiAreaId = 10 + j;//寄存器区id@10--13
//		uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
//		pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始
//
//
//		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//		//寄存器区属性设置
//		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//		pstStRegisterArea->byType_RW = 1;//读写方式
//		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//		pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
//		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}
//	}
//
//	//剩余第二路@四个区
//	//第十五~十八区@每个区100word
//	pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_4[0];
//	//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
//	uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
//	for(j=0;j<4;j++)
//	{
//		uiRegisterNum = 100;//获取寄存器个数
//		uiAreaId = 14 + j;//寄存器区id@14--17
//		uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
//		pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始
//
//		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//		//寄存器区属性设置
//		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//		pstStRegisterArea->byType_RW = 1;//读写方式
//		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//		pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
//		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}
//	}
//
//	//剩余第三路@四个区
//	//第十九~二十二区@每个区100word
//	pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_5[0];
//	//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
//	uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
//	for(j=0;j<4;j++)
//	{
//		uiRegisterNum = 100;//获取寄存器个数
//		uiAreaId = 18 + j;//寄存器区id@18--21
//		uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
//		pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始
//
//		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//		//寄存器区属性设置
//		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//		pstStRegisterArea->byType_RW = 1;//读写方式
//		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//		pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
//		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}
//	}
//
//
//	//剩余第四路@四个区
//	//第二十三~二十六区@每个区100word
//	pAdrSaTmp = (uint16_t*)&pstVisuCommData->sampleData_WO.awSampleData_6[0];
//	//更新起始地址@存放到临时变量uiRegisterAdrSaTmp中
//	uiRegisterAdrSaTmp = uiRegisterAdrSa + uiRegisterNum;//上面逻辑的这两个值计算当前区的首地址@地址都是连续的
//	for(j=0;j<4;j++)
//	{
//		uiRegisterNum = 100;//获取寄存器个数
//		uiAreaId = 22 + j;//寄存器区id@22--25
//		uiRegisterAdrSa = uiRegisterAdrSaTmp + uiRegisterNum * j;//寄存器起始地址更新
//		pAdrSa = pAdrSaTmp + uiRegisterNum * j;//变量的起始
//
//
//		pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//		xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//		//寄存器区属性设置
//		pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//		pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//		pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//		pstStRegisterArea->byType_RW = 1;//读写方式
//		pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//		pstStRegisterArea->dwxNeedReSendAdr = 0;//重新发送标志地址
//		//寄存器区内数据设置
//		for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//		{
//			pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//			pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//			pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//			pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//		}
//	}
//
//
//	//2026.1.27.161522  再扩展一个区-快速变化的只写
//	/***********************************************WO-Dyan*****************************************************/
//	//只写@变化频繁
//	//寄存器区的内容获取
//	//第二十七区
//	pAdrSa = (uint16_t*)&pstVisuCommData->dynaData_WO_Ex.wSa;
//	uiRegisterNum = KsGetRegisterNum(sizeof(pstVisuCommData->dynaData_WO_Ex));//获取寄存器个数
//	dwReSendAllDataAdr = (uint32_t)&pstVisuCommData->axReSendAllData[3];
//	uiAreaId = 26;//寄存器区id@Id是数组索引
//	uiRegisterAdrSa = 120;//寄存器起始地址
//
//
//	pstStRegisterArea = &i_pstStData_Comm->astStRegisterArea[uiAreaId];//寄存器区首地址
//	xRegisterAreaEn = i_paxRegisterAreaCommEn[uiAreaId];//寄存器区使能标志
//	//寄存器区属性设置
//	pstStRegisterArea->xCommEn = xRegisterAreaEn;//通讯使能标志
//	pstStRegisterArea->wModbusAdr = uiRegisterAdrSa;//起始地址
//	pstStRegisterArea->iRegisterNum = uiRegisterNum;//寄存器个数
//	pstStRegisterArea->byType_RW = 1;//读写方式
//	pstStRegisterArea->byType_Data = 4;//数据格式@寄存器
//	pstStRegisterArea->dwxNeedReSendAdr = dwReSendAllDataAdr;//重新发送标志地址
//	//寄存器区内数据设置
//	for(i=0;i<pstStRegisterArea->iRegisterNum;i++)
//	{
//		pstStDataAttribute = &pstStRegisterArea->astRegisterDate[i];
//		pstStDataAttribute->byType_RW = 1;//(*读写属性|读写数据根据这个值处理@其他属性根据寄存器区属性自动配置*)
//		pstStDataAttribute->dwDataAdr = (uint32_t)&pAdrSa[i];//数据地址
//		pstStDataAttribute->dwDataBakAdr = (uint32_t)&pstStDataAttribute->wValueBak;//备份只@写属性使用
//	}
//}

//启动中断发送数据@往发送寄存器里写入一个
//只能被执行1次
void KSStartSendBuffByIRQ()
{
	int16_t i=0;
	RS485_TX_EN(TRANSMIT_EN_485);//切换为发送总线
	//启动计时器2@等待切换在发送
	__HAL_TIM_ENABLE(&htim2);

	//在中断中处理了
	//最好的方式是按照以前的,启动1ms计时中断,时间到了在执行DR写入动作。@等程序合并的时候再处理
	//for(i=0;i<15000;i++);//给切换预留点时间@没有专门确认过15000个循环的时间@只是使用19200波特率下试到发送不出错
	//huart2.Instance->DR = g_abySendDataBuff[0];
	if(g_abySendDataBuff[0] != 1)
		i++;

}

//定时器2@1ms
//定时器2判定接收空闲时间，当空闲时间大于指定时间,认为一数据结束
void TIM2_IRQHandler(void)
{
	//2025.11.5.125159+
	//获取更新中断宏使用错误@用成了更新中断使能标志获取宏
	//if(__HAL_TIM_GET_IT_SOURCE(&htim2,TIM_IT_UPDATE)!=RESET)
	if(__HAL_TIM_GET_IT_SOURCE(&htim2,TIM_IT_UPDATE)!=RESET &&//中断使能了
		__HAL_TIM_GET_FLAG(&htim2, TIM_FLAG_UPDATE))//更新中断有效
	{
		huart2.Instance->DR = g_abySendDataBuff[0];

		__HAL_TIM_DISABLE(&htim2);//计时器取消使能,等下次发送的时候在使能
		//2025.11.5.125944+
		__HAL_TIM_CLEAR_FLAG(&htim2, TIM_FLAG_UPDATE);//清除更新中断标志
		HAL_TIM_IRQHandler(&htim2);
	}
	//2025.11.5.125950屏蔽更换宏
	//__HAL_TIM_CLEAR_IT(&htim2, TIM_IT_UPDATE);  /* 清除中断标志�??? */
}


//串口中断函数
//在修改.IOC文件后会自动重新生成串口中断函数到stm32f4xx_it.c文件中，需要手动屏蔽
void USART2_IRQHandler() //串口2执行接收和发送中断|接收时先写入到队列中
{
	//io测试用于计算时间
	//HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_RESET);  //LED0=1;

	uint8_t byRecBuff;
	int16_t index = 0;

	//队列初始化,外部标记控制@主要用于接收
	if(g_xInitCycleQueue)
	{
		KS_InitQueue((uint32_t)g_abyCycleQueue,(sizeof(g_abyCycleQueue)),&g_iQueueSa,&g_iQueueEd);//初始化队列
		g_xInitCycleQueue = FALSE;
		g_byCycleQueueFullCnt = 0;
	}


	if(((huart2.Instance->SR>>5) & 0x1)==1)//接收有数据了
	{
		//将数据写入到循环队列中去
		//byRecBuff = huart2.Instance->DR;//从寄存器里把数据拿出来
		byRecBuff = (uint8_t)USART_ReceiveData(huart2.Instance);//2025.6.14.142945 使用专门的接收函数获取值
		index = g_iQueueEd + 1;//计算写入的位置
		if(index >= CYCLEQUEUE_NUM)//非法值处理
			index = 0;

		if(index == g_iQueueSa)//队列满了,不更新写入位置|增加一个满的计数
		{
			g_abyCycleQueue[index] = byRecBuff;//写入@最后一个值会被覆盖
			g_byCycleQueueFullCnt += 1;//记录满
			//不更新g_iQueueEd
		}
		else//还有地方
		{
			g_abyCycleQueue[index] = byRecBuff;//写入
			g_iQueueEd = index;//更新队列值
		}

	}

	else if(__HAL_UART_GET_FLAG( &huart2, UART_FLAG_TC) != RESET )//发送完成@至少已经发送了一个
	{
		//测试时间代码
		//HAL_GPIO_WritePin(LED1_GPIO_Port, LED1_Pin, GPIO_PIN_SET);  //LED1=0;

		//清除发送完成标志位@准备发送下一个
		__HAL_UART_CLEAR_FLAG(&huart2, UART_FLAG_TC);

		g_iSendNum_Act += 1;//统计实际发送的个数@第一次进入的时候，应该已经发送了一个了@找下一个索引，同时也能标记此时已经发送的个数

		if(g_iNeedSendNum <= g_iSendNum_Act)//队列空，发送完成
		{
			g_xDataSendDne = TRUE;//发送完成了
			RS485_TX_EN (RECEIVE_EN_485);//切换为接收状态
			g_iSendNum_Act = 0;//在发送完成的时候清除实际发送过程
		}
		else
		{
			if(g_iSendNum_Act>=0 && g_iSendNum_Act<SENDBUFF_NUM)//索引合法性判断
				huart2.Instance->DR = g_abySendDataBuff[g_iSendNum_Act];
				//USART2->DR = g_abySendDataBuff[g_iSendNum_Act];

		}
	}
	else//接收溢出中断
	{
		if(__HAL_UART_GET_FLAG(&huart2, UART_FLAG_ORE)!= RESET)	//清除上溢中断|2020.6.6.160103
		{
			//2021.9.9.011336清除上溢中断
			//清除方式-读入SR寄存器再读取DR寄存器
			__HAL_UART_CLEAR_FLAG(&huart2,UART_FLAG_ORE);//操作SR
			byRecBuff = USART_ReceiveData(huart2.Instance);//操作DR
			g_uiORECnt +=g_uiORECnt;
		}
	}

	//测试时间代码
	//HAL_GPIO_WritePin(LED0_GPIO_Port, LED0_Pin, GPIO_PIN_SET);  //LED0=0;
}

//获取屏保id@从站人机
void KSGetScreenSaverId(StAxisParam* i_pstStAxisParam,StGrpParam* i_pstStGrpParam,uint8_t byStsV)
{
	uint8_t byScreen = 3;//默认按照停机输出
	uint8_t xAuto_V = (BYTE)(i_pstStAxisParam->wStatusRef & 0x01);			//套色自动
	if(	i_pstStAxisParam->xLocalAxisLinkage &&
		i_pstStAxisParam->xLocalAxisRollerDn &&
		xAuto_V &&
		i_pstStGrpParam->lrVelocity>0)
	{
		if( (byStsV & 0x01) )
		{
			byScreen = 0;//报警
		}
		else if( (byStsV & 0x02)>>1 )
		{
			byScreen = 1;//丢失
		}
		else
		{
			byScreen = 2;//正常
		}
	}
	else
	{
		if(i_pstStAxisParam->xLocalAxisEstop)
		{
			byScreen = 4;	//急停
		}
		else
		{
			byScreen = 3;	//停机
		}
	}

	i_pstStAxisParam->byScreen =  byScreen;
}

void KSModbusHmiComm()
{
	int16_t i =0 ,j = 0;
	uint8_t* pTmp = 0;
	static uint8_t byPollIdGroup = 0;//轮询id组 = 0~3//共4组
	static uint8_t byPreCurRegisterIndex = 0;//上一拍的寄存器索引|用来判断是不是已经轮询完了|设计地址区的时候第一个区是肯定会通讯,所以我们只要确认他重新进入就好！
	uint8_t byPollIdSa = 0;//轮询id起始值
	uint8_t abyPollIdList[POLLNUM] = {0};//第几个@数组索引需要-1


	g_abyModbusIdList[0] = 1;//站号=1
	g_axModbusCommEnList[0] = TRUE;


	if (//g_uiPollTimer >= POLLTIME ||//轮询处理@500ms更新一次
		(g_byCurRegisterIndex==0 && byPreCurRegisterIndex!=0))//再次进入第一个寄存器区的时候就启动轮询
	{
		g_uiPollTimer = 0;//清零计时器
		byPollIdGroup += 1;//切换到下一组
		if (byPollIdGroup >= POLLNUM)//超过
			byPollIdGroup = 0;//重新开始
	}
	byPreCurRegisterIndex = g_byCurRegisterIndex;//更新当前寄存器的值

	//轮询区id 列表
	byPollIdSa = POLLID_SA + (byPollIdGroup * POLLNUM);
	for(i=0;i<POLLNUM;i++)
	{
		abyPollIdList[i] = byPollIdSa + i;//起始+索引
	}

	pTmp = g_axRegisterAreaCommEnList[0];//取数组指针[REGISTER_AREA_MAX]
	for(i=0;i<REGISTER_AREA_MAX;i++)
	{
		if(i<POLLID_SA || i > POLLID_ED)//前10个区一直通讯\从25以后
			pTmp[i] = TRUE;
		else//10--25@实际11--26区控制
		{
			for(j=0;j<POLLNUM;j++)//在轮询id列表里寻找是不是使用区
			{
				if(i == abyPollIdList[j])
				{
					pTmp[i] = TRUE;
					break;
				}
				else//不再就关闭
				{
					if(j == POLLNUM -1)//最后一个也不是@说明就没在
						pTmp[i] = FALSE;
				}
			}
		}
	}

	//重发处理
	if (!g_axConnectOk[0])//离线就启动重发
	{
		g_stVisuCommData.axReSendAllData[0]=TRUE;
		g_stVisuCommData.axReSendAllData[1]=TRUE;
		g_stVisuCommData.axReSendAllData[2]=TRUE;
		g_stVisuCommData.axReSendAllData[3]=TRUE;//2026.1.27.162956+
	}

	//485主站通讯实现函数
	//输入数组加上个数，只是为了明确大小,对于实际实现没有帮助
	KSModbus485_Master(
			TRUE,//通讯使能
			g_astStData,//(*下标代表索引*)
			//(*数据地址列表|一维索引代表站号-二维索引为区块分类*)
			//g_aStDataList,//所有通讯数据列表
			MODBUSNUM_MAX,//(*最大的设备个数|*)
			g_abyModbusIdList,//(*modbusid列表|下标代表索引*)
			g_axModbusCommEnList,//(*modbus站通讯使能列表|下标代表索引*)
			g_axRegisterAreaCommEnList,//(*站的 寄存器区使能标志*)
			&g_stVisuCommData,
			//输出的数据
			//(*修改为数组变量-2021.7.16.170008*)
			g_auiSendDataCnt,//发送的计数
			g_auiRecvDataCnt,//接收的计数
			g_auiRecvErrDataCnt,//接收出错的计数
			g_auiTimeOutDataCnt,//超时计数
			g_axConnectOk,//通讯正常标志
			g_abyErrCodeFrSlav,
			g_aiErrCode,//(*返回的错误码*)
			&g_byCurModbusIdIndex,
			&g_byCurRegisterIndex);
	//通讯计数发送到人机@@103--106

	g_stVisuCommData.dynaData_WO.uiSendDataCnt = g_auiSendDataCnt[0];
	g_stVisuCommData.dynaData_WO.uiRecvDataCnt = g_auiRecvDataCnt[0];
	g_stVisuCommData.dynaData_WO.uiRecvErrDataCnt = g_auiRecvErrDataCnt[0];
	g_stVisuCommData.dynaData_WO.uiTimeOutDataCnt = g_auiTimeOutDataCnt[0];
}


//485通讯数据的赋值
//更新读写数据
void KsUpdateDataRw(uint8_t xHmiToLocal,
		StGlobalParam* i_pstStGlobalParam,
		StAxisParam* i_pstStAxisParam,
		StGrpParam* i_pstStGrpParam,
		LP_VisuCommData i_pstVisuCommData)
{
	uint16_t uiTmp = 0;
	uint8_t byTmp = FALSE;
	int32_t diTmp = 0;
	//uint32_t dwTmp = 0;
	//uint8_t xRuning =0; //横向运行中标志
	float rTmp = 0;
	uint8_t xStartPlateAdjustmentProf = FALSE,xStartHorRun = FALSE;
	if(xHmiToLocal)//人机数据写入到本地
	{
		if(i_pstVisuCommData->data_RW.byAxisId != 0)//轴id不等于0 才更新了@为0认为是读取的无效数据
		{
			//													= i_pstVisuCommData->data_RW.byHMI_Cnt						;
			i_pstStAxisParam->iAxisId							= (int8_t)i_pstVisuCommData->data_RW.byAxisId						;
			i_pstStAxisParam->lrAdjust_V						= (float)i_pstVisuCommData->data_RW.iAdjust_V / 100.0		;
			i_pstStAxisParam->lrAdjust_H						= (float)i_pstVisuCommData->data_RW.iAdjust_H / 100.0		;
			i_pstStAxisParam->iGateSa							= i_pstVisuCommData->data_RW.iGateSa						;
			i_pstStAxisParam->iGateSaEx							= i_pstVisuCommData->data_RW.iGateSaEx						;
			//i_pstStAxisParam->wStatusRef						= i_pstVisuCommData->data_RW.wStatus						;
			uiTmp												= i_pstVisuCommData->data_RW.wStatus						;
			//界面内容按bit赋值@界面的位定义分散再不同的变量中
			byTmp = KSGetDataBit(&uiTmp,0);//获取套色纵向手自动
			KSSetDataBit(&i_pstStAxisParam->wStatusRef,byTmp,0);//写入到轴参数中

			byTmp = KSGetDataBit(&uiTmp,1);//获取套色横向手自动
			KSSetDataBit(&i_pstStAxisParam->wStatusRef,byTmp,1);//写入到轴参数中

			byTmp = KSGetDataBit(&uiTmp,9);//获取T1反极性
			KSSetDataBit(&i_pstStAxisParam->dwControlBits,byTmp,5);//写入到轴参数中
			byTmp = KSGetDataBit(&uiTmp,10);//获取T2反极性
			KSSetDataBit(&i_pstStAxisParam->dwControlBits,byTmp,6);//写入到轴参数中

			byTmp = KSGetDataBit(&uiTmp,14);//获取套色纵向跟任意色
			KSSetDataBit(&i_pstStAxisParam->wStatusRef,byTmp,8);//写入到轴参数中

			byTmp = KSGetDataBit(&uiTmp,15);//获取套色横向跟任意色
			KSSetDataBit(&i_pstStAxisParam->wStatusRef,byTmp,9);//写入到轴参数中

			i_pstStAxisParam->xOK_PosConfirmed = KSGetDataBit(&uiTmp,6);//获取单标记确认
			i_pstStAxisParam->xStartPlateAdjustmentProf = KSGetDataBit(&uiTmp,7);//获取快速对版
			i_pstStAxisParam->xStartHorRun = KSGetDataBit(&uiTmp,2);//横向运动标志
			//i_pstStAxisParam->iJourney_HorzRapidAdjust = i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust;//横向运动的量

			//2025.09.04.155839//xi.hy//新增
			//快速对版处理
			xStartPlateAdjustmentProf = KSGetDataBit(&uiTmp,7);
			if(xStartPlateAdjustmentProf)
			{
				if(i_pstVisuCommData->data_RW.iPlateAdjustmentProf!=0)//快速对版量不为0
				{
					//2020.11.19.132619@niu.j负调整量调整问题
					//这个600和界面的显示分辨率有关
					rTmp=(((REAL)(i_pstVisuCommData->data_RW.iPlateAdjustmentProf)*i_pstStAxisParam->lrGirth*1000)/600);
					diTmp= (DINT)rTmp;
					i_pstStAxisParam->dwPlateAdjustmentProf= (DWORD)diTmp;
					i_pstVisuCommData->data_RW.iPlateAdjustmentProf = 0;//清除快速对版量
				}
			}

			//横向运动处理
			xStartHorRun =KSGetDataBit(&uiTmp,2);
			if( xStartHorRun )
			{
				xStartHorRun = 0;
				uint8_t xRuning =KSGetDataBit(&i_pstStAxisParam->wSts_HorzManuPreReg,0);
				if( !xRuning )
				{
					if( i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust != 0 &&
						i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust > -1000 &&
						i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust <1000)//读取 的横向运行值在合理范围
					{
						i_pstStAxisParam->iJourney_HorzRapidAdjust = i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust;
					}
					i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust= 0;
				}
				else
				{
					i_pstStAxisParam->iJourney_HorzRapidAdjust = -32767;
				}

			}





			i_pstStAxisParam->wButtonFun						= i_pstVisuCommData->data_RW.wButtonFun						;
			//2026.01.06.140918//xi.hy//增加开关通讯
			i_pstStAxisParam->wMCGS_SingleSwitch				= i_pstVisuCommData->data_RW.wSwitchFun						;
			i_pstStAxisParam->wUnit_input_I						= i_pstVisuCommData->data_RW.wUnit_output_I					;
			i_pstStAxisParam->wUnit_input_II					= i_pstVisuCommData->data_RW.wUnit_output_II				;
			//i_pstStGlobalParam->								= i_pstVisuCommData->data_RW.iPlateAdjustmentProf			;
			//i_pstStGlobalParam->								= i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust		;
			i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet		= i_pstVisuCommData->data_RW.wHz_UnitInkRoller_ManuallySet	;
			i_pstStAxisParam->wCoeff_UnitInkRoller_Auto			= i_pstVisuCommData->data_RW.wCoeff_UnitInkRoller_Auto		;
			i_pstStAxisParam->wHz_UnitScraper_ManuallySet		= i_pstVisuCommData->data_RW.wHz_UnitScraper_ManuallySet	;
			i_pstStAxisParam->wCoeff_UnitScraper_Auto			= i_pstVisuCommData->data_RW.wCoeff_UnitScraper_Auto		;
			i_pstStAxisParam->wHz_UnitHotWind					= i_pstVisuCommData->data_RW.wHz_UnitHotWind				;
			i_pstStAxisParam->wHz_UnitHotWind_2					= i_pstVisuCommData->data_RW.wHz_UnitHotWind_2				;
			i_pstStAxisParam->wSV_UnitTemCtl					= i_pstVisuCommData->data_RW.wSV_UnitTemCtl					;
			//DWORD数据要按照word取反
			i_pstStAxisParam->dwCtlBits_UnitBaseCraft			= i_pstVisuCommData->data_RW.dwCtlBits_UnitBaseCraft		;
			KS_DataShift_V2((uint32_t)(&i_pstStAxisParam->dwCtlBits_UnitBaseCraft),4,2);

			i_pstStAxisParam->wAirInletWindDoorValue			= i_pstVisuCommData->data_RW.wAirInletWindDoorValue			;
			i_pstStAxisParam->wAirExhaustWindDoorValue			= i_pstVisuCommData->data_RW.wAirExhaustWindDoorValue		;
			i_pstStAxisParam->wAirReturnWindDoorValue			= i_pstVisuCommData->data_RW.wAirReturnWindDoorValue		;
			i_pstStGlobalParam->bySignalSelect					= i_pstVisuCommData->data_RW.byRGBChosse_Cur				;

			i_pstStGlobalParam->rOffset_T1 					  = i_pstVisuCommData->data_RW.uiOffset_T1 / 1000.0;				//T1路光纤偏移/1000
			i_pstStGlobalParam->rSource_Light_T1 			  = i_pstVisuCommData->data_RW.uiSource_Light_T1 / 1000.0;   	  	//T1路光纤光源/1000
			i_pstStGlobalParam->rBias_T1 					  = i_pstVisuCommData->data_RW.uiBias_T1 / 1000.0;			   	 	//T1路光纤电眼偏置/1000
			i_pstStGlobalParam->rBrightness_Light_T1		  = i_pstVisuCommData->data_RW.uiBrightness_Light_T1 / 1000.0;		//T1路光纤电眼亮度/1000
			i_pstStGlobalParam->rOffset_T2 					  = i_pstVisuCommData->data_RW.uiOffset_T2 / 1000.0;				//T2路光纤偏移/1000
			i_pstStGlobalParam->rSource_Light_T2 			  = i_pstVisuCommData->data_RW.uiSource_Light_T2 / 1000.0;   		//T2路光纤光源/1000
			i_pstStGlobalParam->rBias_T2 					  = i_pstVisuCommData->data_RW.uiBias_T2 / 1000.0;			   	  	//T2路光纤电眼偏置/1000
			i_pstStGlobalParam->rBrightness_Light_T2		  = i_pstVisuCommData->data_RW.uiBrightness_Light_T2 / 1000.0;		//T2路光纤电眼亮度/1000
			i_pstStGlobalParam->uiSomeCtlBit_RW		  		  =  i_pstVisuCommData->data_RW.uiSomeCtlBit;		//
			//展会波形处理
			if(i_pstVisuCommData->data_RW.uiRemainNum_F==0)
			{
				i_pstVisuCommData->data_RW.uiRemainNum_F=100;
			}
			if(i_pstVisuCommData->data_RW.uiRemainNum_B==0)
			{
				i_pstVisuCommData->data_RW.uiRemainNum_B=100;
			}
			i_pstStGlobalParam->uiRemainNum_F				=i_pstVisuCommData->data_RW.uiRemainNum_F;
			i_pstStGlobalParam->uiRemainNum_B				=i_pstVisuCommData->data_RW.uiRemainNum_B;

			//2025.10.24.094529+只读
			i_pstStAxisParam->wAccButton_Count				=i_pstVisuCommData->data_RW.wAccButton_Count;
			i_pstStAxisParam->wDecButton_Count				=i_pstVisuCommData->data_RW.wDecButton_Count;
			i_pstStAxisParam->wUpAdjButton_Count			= i_pstVisuCommData->data_RW.wUpAdjButton_Count;
			i_pstStAxisParam->wDnAdjButton_Count			= i_pstVisuCommData->data_RW.wDnAdjButton_Count;
			i_pstStAxisParam->wLeftAdjButton_Count		  	= i_pstVisuCommData->data_RW.wLeftAdjButton_Count;
			i_pstStAxisParam->wRightAdjButton_Count		  	= i_pstVisuCommData->data_RW.wRightAdjButton_Count;
			i_pstStAxisParam->wAlarmButton_Count			= i_pstVisuCommData->data_RW.wAlarmButton_Count;
			i_pstStAxisParam->rHz_UnitInkRoller_CurrRD		=i_pstVisuCommData->data_RW.wHz_UnitInkRoller_CurrRD;
			i_pstStAxisParam->wSTS_UnitInkRoller			=i_pstVisuCommData->data_RW.wSts_UnitInkRoller;
			i_pstStAxisParam->rHz_UnitHotWind_CurrRD		=i_pstVisuCommData->data_RW.wHz_UnitHotWind_CurrRD;
			i_pstStAxisParam->wSTS_UnitHotWind				=i_pstVisuCommData->data_RW.wSts_UnitHotWind;
			i_pstStAxisParam->rHz_UnitScraper_CurrRD		=i_pstVisuCommData->data_RW.wHz_UnitScraper_CurrRD;
			i_pstStAxisParam->wSTS_UnitScraper				=i_pstVisuCommData->data_RW.wSts_UnitScraper;

			i_pstStAxisParam->xEncValueIsValid_Hor 			=KSGetDataBit(&i_pstVisuCommData->data_RW.wStsBit_RO,0);
			i_pstStAxisParam->xHorMotorAlarm 				=KSGetDataBit(&i_pstVisuCommData->data_RW.wStsBit_RO,1);
			i_pstStAxisParam->dwEncValue_Hor				=i_pstVisuCommData->data_RW.dwEncValue_Hor;

		}//轴id被写0了不更新本地值
	}
	else//本地写入到人机
	{
		//读写变量
		//i_pstVisuCommData->data_RW.byHMI_Cnt						= ;
		i_pstVisuCommData->data_RW.byAxisId							=(uint8_t)i_pstStAxisParam->iAxisId;
		i_pstVisuCommData->data_RW.iAdjust_V						=(int16_t)(i_pstStAxisParam->lrAdjust_V*100);
		i_pstVisuCommData->data_RW.iAdjust_H						=(int16_t)(i_pstStAxisParam->lrAdjust_H*100);
		i_pstVisuCommData->data_RW.iGateSa							=i_pstStAxisParam->iGateSa;
		i_pstVisuCommData->data_RW.iGateSaEx						=i_pstStAxisParam->iGateSaEx;

		//界面内容按bit赋值@界面的位定义分散再不同的变量中
		byTmp = KSGetDataBit(&i_pstStAxisParam->wStatusRef,0);//获取套色纵向手自动
		KSSetDataBit(&uiTmp,byTmp,0);//写入到通讯参数中

		byTmp = KSGetDataBit(&i_pstStAxisParam->wStatusRef,1);//获取套色横向手自动
		KSSetDataBit(&uiTmp,byTmp,1);//写入到通讯参数中

		byTmp = KSGetDataBit(&i_pstStAxisParam->wStatusRef,8);//获取套色纵向跟任意色
		KSSetDataBit(&uiTmp,byTmp,14);//写入到通讯参数中

		byTmp = KSGetDataBit(&i_pstStAxisParam->wStatusRef,9);//获取套色横向跟任意色
		KSSetDataBit(&uiTmp,byTmp,15);//写入到通讯参数中


		byTmp = KSGetDataBit(&i_pstStAxisParam->wSwitchRef,0);//获取套色横向开关
		KSSetDataBit(&uiTmp,byTmp,3);//写入到通讯参数中

		byTmp = KSGetDataBit(&i_pstStAxisParam->dwControlBits,5);//获取T1反极性
		KSSetDataBit(&uiTmp,byTmp,9);//写入到通讯参数中
		byTmp = KSGetDataBit(&i_pstStAxisParam->dwControlBits,6);//获取T2反极性
		KSSetDataBit(&uiTmp,byTmp,10);//写入到通讯参数中

		byTmp = KSGetDataBit(&i_pstStAxisParam->wSts_HorzManuPreReg,0);//获取横向运行中
		KSSetDataBit(&uiTmp,byTmp,4);//写入到通讯参数中

		//快速对版轴标志
		if(((i_pstStAxisParam->xLocalAxisRollerDn==1)|(i_pstStAxisParam->xStartPlateAdjustmentProf==1))&&
			(i_pstStAxisParam->xLocalAxisLinkage==1)&&
			(i_pstStGrpParam->xFlag_Print==1)&&
			(i_pstStGrpParam->lrVelocity<=30))
		{
			//wStatus = SetBit(1,wStatus,8);
			KSSetDataBit(&uiTmp,1,8);//写入到通讯参数中@快速对版中
		}
		else
		{
			//wStatus = SetBit(0,wStatus,8);
			KSSetDataBit(&uiTmp,0,8);//写入到通讯参数中@快速对版中
		}


		KSSetDataBit(&uiTmp,i_pstStAxisParam->xOK_PosConfirmed,6);//写入到通讯参数中@单标记按钮
		KSSetDataBit(&uiTmp,i_pstStAxisParam->xStartPlateAdjustmentProf,7);//写入到通讯参数中@获取快速对版
		KSSetDataBit(&uiTmp,i_pstStAxisParam->xStartHorRun,2);//写入到通讯参数中@横向运动

		//i_pstVisuCommData->data_RW.wStatus						=i_pstStAxisParam->wStatusRef;
		i_pstVisuCommData->data_RW.wStatus							=uiTmp;

		i_pstVisuCommData->data_RW.wButtonFun						=i_pstStAxisParam->wButtonFun;
		//2026.01.06.141109//xi.hy//增加开关通讯
		i_pstVisuCommData->data_RW.wSwitchFun						=i_pstStAxisParam->wMCGS_SingleSwitch;
		i_pstVisuCommData->data_RW.wUnit_output_I					=i_pstStAxisParam->wUnit_input_I;
		i_pstVisuCommData->data_RW.wUnit_output_II					=i_pstStAxisParam->wUnit_input_II;
		//i_pstVisuCommData->data_RW.iPlateAdjustmentProf			=i_pstStGlobalParam->;
		//i_pstVisuCommData->data_RW.iJourney_HorzRapidAdjust		=i_pstStGlobalParam->;
		i_pstVisuCommData->data_RW.wHz_UnitInkRoller_ManuallySet	=i_pstStAxisParam->wHz_UnitInkRoller_ManuallySet ;
		i_pstVisuCommData->data_RW.wCoeff_UnitInkRoller_Auto		=i_pstStAxisParam->wCoeff_UnitInkRoller_Auto ;
		i_pstVisuCommData->data_RW.wHz_UnitScraper_ManuallySet		=i_pstStAxisParam->wHz_UnitScraper_ManuallySet ;
		i_pstVisuCommData->data_RW.wCoeff_UnitScraper_Auto			=i_pstStAxisParam->wCoeff_UnitScraper_Auto ;
		i_pstVisuCommData->data_RW.wHz_UnitHotWind					=i_pstStAxisParam->wHz_UnitHotWind ;
		i_pstVisuCommData->data_RW.wHz_UnitHotWind_2				=i_pstStAxisParam->wHz_UnitHotWind_2 ;
		i_pstVisuCommData->data_RW.wSV_UnitTemCtl					=i_pstStAxisParam->wSV_UnitTemCtl ;
		i_pstVisuCommData->data_RW.dwCtlBits_UnitBaseCraft			=i_pstStAxisParam->dwCtlBits_UnitBaseCraft;
		//DWORD数据要按照word取反
		KS_DataShift_V2((uint32_t)(&i_pstVisuCommData->data_RW.dwCtlBits_UnitBaseCraft),4,2);

		i_pstVisuCommData->data_RW.wAirInletWindDoorValue			=i_pstStAxisParam->wAirInletWindDoorValue;
		i_pstVisuCommData->data_RW.wAirExhaustWindDoorValue			=i_pstStAxisParam->wAirExhaustWindDoorValue;
		i_pstVisuCommData->data_RW.wAirReturnWindDoorValue			=i_pstStAxisParam->wAirReturnWindDoorValue;
		i_pstVisuCommData->data_RW.byRGBChosse_Cur					=i_pstStGlobalParam->bySignalSelect;


		//2025.09.20.131624//xi.hy//发送给人机的整数做四舍五入处理
		i_pstVisuCommData->data_RW.uiOffset_T1 						= (uint16_t)KS_ROUND((i_pstStGlobalParam->rOffset_T1*1000))	;//
		i_pstVisuCommData->data_RW.uiSource_Light_T1   				= (uint16_t)KS_ROUND((i_pstStGlobalParam->rSource_Light_T1*1000));
		i_pstVisuCommData->data_RW.uiBias_T1 			    		= (uint16_t)KS_ROUND((i_pstStGlobalParam->rBias_T1*1000));
		i_pstVisuCommData->data_RW.uiBrightness_Light_T1 			= (uint16_t)KS_ROUND((i_pstStGlobalParam->rBrightness_Light_T1*1000))	;
		i_pstVisuCommData->data_RW.uiOffset_T2 						= (uint16_t)KS_ROUND((i_pstStGlobalParam->rOffset_T2*1000))			;
		i_pstVisuCommData->data_RW.uiSource_Light_T2   				= (uint16_t)KS_ROUND((i_pstStGlobalParam->rSource_Light_T2*1000))		;
		i_pstVisuCommData->data_RW.uiBias_T2 			    		= (uint16_t)KS_ROUND((i_pstStGlobalParam->rBias_T2*1000))				;
		i_pstVisuCommData->data_RW.uiBrightness_Light_T2 			= (uint16_t)KS_ROUND((i_pstStGlobalParam->rBrightness_Light_T2*1000))	;
		i_pstVisuCommData->data_RW.uiSomeCtlBit		  		  		=  i_pstStGlobalParam->uiSomeCtlBit_RW;		//读写控制bit
		//展会波形处理
		if(i_pstStGlobalParam->uiRemainNum_F==0)
		{
			i_pstStGlobalParam->uiRemainNum_F=100;
		}
		if(i_pstStGlobalParam->uiRemainNum_B==0)
		{
			i_pstStGlobalParam->uiRemainNum_B=100;
		}
		i_pstVisuCommData->data_RW.uiRemainNum_F		  		  		=  i_pstStGlobalParam->uiRemainNum_F;
		i_pstVisuCommData->data_RW.uiRemainNum_B		  		  		=  i_pstStGlobalParam->uiRemainNum_B;
	}
}

void KS_SetData_485(
		uint8_t xRoundSampleFlag,//粗采样标志@有效才刷新粗采样通讯数据
		uint8_t bySignalSelect_Cur,//当前轮询RGB通道
		uint8_t byChannel_T1T2_Cur,//当前轮询T1 T2通道
		StGlobalParam* i_pstStGlobalParam,
		StAxisParam* i_pstStAxisParam,
		StGrpParam* i_pstStGrpParam,
		VisuCommData* i_pstVisuCommData,
		int16_t i_aiError_V[40],
		int16_t i_aiError_H[40])

{
	int16_t iN;
	int16_t iLenth=0;
	uint8_t aspace[2] = {0};
	uint16_t uiTmp = 0,uiBitId = 0;
	int16_t iPromptMsgId = 0;
	static uint16_t uiPrevFsCounter = 0;//精采样计数记录值
	static uint8_t byErrUpdateCnt = 0;//误差刷新索引@0--39


	/**************************************读写变量处理***********************************************************************************************/

	iLenth = sizeof(i_pstVisuCommData->data_RW_Bak);
	if(memcmp(&i_pstVisuCommData->data_RW_Bak,&i_pstVisuCommData->data_RW,iLenth) != 0)//数据有变化了@人机写入到本地
		KsUpdateDataRw(TRUE,i_pstStGlobalParam,i_pstStAxisParam,i_pstStGrpParam,i_pstVisuCommData);
	else//数据没变@本地写入到人机
		KsUpdateDataRw(FALSE,i_pstStGlobalParam,i_pstStAxisParam,i_pstStGrpParam,i_pstVisuCommData);
	//更新备份值
	memcpy(&i_pstVisuCommData->data_RW_Bak,&i_pstVisuCommData->data_RW,iLenth);


	/**************************************只写@变化比较频繁***********************************************************************************************/
	for(iN=0;iN<40;iN++)
	{
		i_pstVisuCommData->dynaData_WO.aiErrorBuff_V[iN]=i_aiError_V[iN];
		i_pstVisuCommData->dynaData_WO.aiErrorBuff_H[iN]=i_aiError_H[iN];
	}
	//6路基线值
	aspace[0] = (uint8_t)i_pstStGlobalParam->fBaseLine_T1R;
	aspace[1] = (uint8_t)i_pstStGlobalParam->fBaseLine_T2R;
	KS_BYTE_TO_WORD(TRUE,aspace,&i_pstVisuCommData->dynaData_WO.wBaseR_T1T2);
	aspace[0] = (uint8_t)i_pstStGlobalParam->fBaseLine_T1G;
	aspace[1] = (uint8_t)i_pstStGlobalParam->fBaseLine_T2G;
	KS_BYTE_TO_WORD(TRUE,aspace,&i_pstVisuCommData->dynaData_WO.wBaseG_T1T2);
	aspace[0] = (uint8_t)i_pstStGlobalParam->fBaseLine_T1B;
	aspace[1] = (uint8_t)i_pstStGlobalParam->fBaseLine_T2B;
	KS_BYTE_TO_WORD(TRUE,aspace,&i_pstVisuCommData->dynaData_WO.wBaseB_T1T2);

	//粗采样最小值
	aspace[0] = (uint8_t)i_pstStGlobalParam->byMinRsData_T1R;
	aspace[1] = (uint8_t)i_pstStGlobalParam->byMinRsData_T2R;
	KS_BYTE_TO_WORD(TRUE,aspace,&i_pstVisuCommData->dynaData_WO.wMinDataR_Sample);
	aspace[0] = (uint8_t)i_pstStGlobalParam->byMinRsData_T1G;
	aspace[1] = (uint8_t)i_pstStGlobalParam->byMinRsData_T2G;
	KS_BYTE_TO_WORD(TRUE,aspace,&i_pstVisuCommData->dynaData_WO.wMinDataG_Sample);
	aspace[0] = (uint8_t)i_pstStGlobalParam->byMinRsData_T1B;
	aspace[1] = (uint8_t)i_pstStGlobalParam->byMinRsData_T2B;
	KS_BYTE_TO_WORD(TRUE,aspace,&i_pstVisuCommData->dynaData_WO.wMinDataB_Sample);

	i_pstVisuCommData->dynaData_WO.iVel_Axis=(int16_t)i_pstStGrpParam->lrVelocity*10;
	i_pstVisuCommData->dynaData_WO.iVel_Grp=(int16_t)i_pstStGrpParam->rGrp_Vel*10;

	//粗采样计数
	KS_WORD_TO_BYTE(FALSE,i_pstStAxisParam->uiRSampleCounter,aspace);//将word写入到单字节数组里把[0]中的值写入到[1]中
	aspace[1] = aspace[0];
	//误差刷新幅数@精采样计数计算最大到40
	if (uiPrevFsCounter!=i_pstStAxisParam->uiFSampleCounter)
		byErrUpdateCnt = (uint8_t)(i_pstStAxisParam->uiFSampleCounter - uiPrevFsCounter);
	if (byErrUpdateCnt >= 40)//0--39变化
		byErrUpdateCnt = 0;
	uiPrevFsCounter = i_pstStAxisParam->uiFSampleCounter;
	aspace[0] = byErrUpdateCnt;//写入到低8bit

	KS_BYTE_TO_WORD(FALSE,aspace,&i_pstVisuCommData->dynaData_WO.wIndex_ErrNum);//wIndex_ErrNum 低8bit是0-39变化的误差刷新值|高8bit是精采样索引值

	//2025.9.28.110121 报警值*100缺失了！
	i_pstVisuCommData->dynaData_WO.iArcAlarm_V=(int16_t)(i_pstStAxisParam->lrAlarm_V * 100);
	i_pstVisuCommData->dynaData_WO.iArcAlarm_H=(int16_t)(i_pstStAxisParam->lrAlarm_H * 100);

	uiTmp = 0;//按bit写入
	uiBitId = i_pstStAxisParam->iMarkTypeId - 1;
	KSSetDataBit(&uiTmp,1,uiBitId);//写入到通讯参数中@标记形式
	uiBitId = i_pstStAxisParam->iMarkArrangeModal + 6;
	KSSetDataBit(&uiTmp,1,uiBitId);//写入到通讯参数中@标记排列形式
	KSSetDataBit(&uiTmp,i_pstStAxisParam->xLocalAxisRollerDn,12);//写入到通讯参数中@合压状态
	KSSetDataBit(&uiTmp,i_pstStAxisParam->xFlag_Gate_double,13);//写入到通讯参数中@双波门
	KSSetDataBit(&uiTmp,KSGetDataBit(&i_pstStGlobalParam->dwControlComplexBits,30),14);//写入到通讯参数中@波形显示方式
	KSSetDataBit(&uiTmp,KSGetDataBit(&i_pstStAxisParam->wSwitchRef,10),15);//写入到通讯参数中@波门锁
	i_pstVisuCommData->dynaData_WO.wFlag_Arc = uiTmp;//bit写入

	aspace[0] = 0;
	aspace[1] = i_pstStAxisParam->byScreen;
	KS_BYTE_TO_WORD(FALSE,aspace,&i_pstVisuCommData->dynaData_WO.wLED_485Cnt);//wLED_485Cnt 高8bit是屏保id|低8bit没处理

	i_pstVisuCommData->dynaData_WO.wUnit_input_I=i_pstStAxisParam->wUnit_input_I;
	i_pstVisuCommData->dynaData_WO.wUnit_input_II=i_pstStAxisParam->wUnit_input_II;
	i_pstVisuCommData->dynaData_WO.wUnit_input_III=i_pstStAxisParam->wUnit_input_III;
	i_pstVisuCommData->dynaData_WO.wHz_UnitInkRoller_CurrWR=i_pstStAxisParam->rHz_UnitInkRoller_CurrWR;
	i_pstVisuCommData->dynaData_WO.wHz_UnitScraper_CurrWR=i_pstStAxisParam->rHz_UnitScraper_CurrWR;
	i_pstVisuCommData->dynaData_WO.wHz_UnitHotWind_CurrWR=i_pstStAxisParam->rHz_UnitHotWind_CurrWR;
	i_pstVisuCommData->dynaData_WO.wHz_UnitHotWind2_CurrWR=i_pstStAxisParam->rHz_UnitHotWind2_CurrWR;
	i_pstVisuCommData->dynaData_WO.wPV_UnitTemCtl=i_pstStAxisParam->rPV_UnitTemCtl*10;
	i_pstVisuCommData->dynaData_WO.wSts_UnitTemCtl=i_pstStAxisParam->wSTS_UnitTemCtl;
	i_pstVisuCommData->dynaData_WO.uiRSampleCounter=i_pstStAxisParam->uiRSampleCounter;
	i_pstVisuCommData->dynaData_WO.uiFSampleCounter=i_pstStAxisParam->uiFSampleCounter;
	//2025.7.30.093243+
	i_pstVisuCommData->dynaData_WO.uiPeakValue_t1=i_pstStAxisParam->uiPeakValue_t1;
	i_pstVisuCommData->dynaData_WO.uiPeakValue_t2=i_pstStAxisParam->uiPeakValue_t2;
	i_pstVisuCommData->dynaData_WO.uiSource_Light_T1_Cur=(uint16_t)(i_pstStGlobalParam->rSource_Light_T1_Cur * 1000);
	i_pstVisuCommData->dynaData_WO.uiSource_Light_T2_Cur=(uint16_t)(i_pstStGlobalParam->rSource_Light_T2_Cur * 1000);
	//2025.09.05.164039//xi.hy+
	i_pstVisuCommData->dynaData_WO.iPos_HorzManuPreReg=i_pstStAxisParam->iPos_HorzManuPreReg;
	//2025.12.02.103119//自动聚焦中的当前峰值
	i_pstVisuCommData->dynaData_WO.uiPeakCur_AutoFocus=i_pstStAxisParam->uiPeakCur_AutoFocus;




	/**************************************只写@变化比较缓慢***********************************************************************************************/
	i_pstVisuCommData->stdData_WO.wGirth=(uint16_t)(i_pstStAxisParam->lrGirth*10);
	i_pstVisuCommData->stdData_WO.iCompanyId=i_pstStGlobalParam->iCompanyId;

	//6204//公司ID
	//公司名称和报警代码合并2020.7.2.152313||

	if(i_pstStAxisParam->dwAlarmDetail != 0)
	{
		for(iN=0 ; iN<16 ; iN++)
		{
			if((i_pstStAxisParam->dwAlarmDetail & 1<<iN) != 0)
			{
				iPromptMsgId = 1500 + iN;
				break;
			}
		}
	}
	else
	{
		iPromptMsgId = 0;//报警细节与公司名称区分开
	}
	
	i_pstVisuCommData->stdData_WO.iPromptMsgId = iPromptMsgId;
	i_pstVisuCommData->stdData_WO.wAxisId_GrpId=(uint16_t)i_pstStAxisParam->iAxisId<<8 | (uint16_t)i_pstStAxisParam->byGrpId;
	i_pstVisuCommData->stdData_WO.wLedtime_Language=(uint16_t)i_pstStGlobalParam->byMinutes_ScrAutoSleep<<8 | (uint16_t)i_pstStGlobalParam->byLanguageId;
	//2025.11.12.130250+ 版本号增加双字节颠倒！
	i_pstVisuCommData->stdData_WO.dwVersion=DWVERSION;
	KS_DataShift_V2((uint32_t)(&i_pstVisuCommData->stdData_WO.dwVersion),4,2);
	//人机显示的宽度.一圈是600个分辨率点@波门大小是和分辨率对应
	i_pstVisuCommData->stdData_WO.uiGateWhy=(uint16_t)i_pstStGlobalParam->iGateWidthRdPt_Hmi;
	//2025.9.26.124954+ 通讯
	i_pstVisuCommData->stdData_WO.byDriverType_Hmi485=(uint16_t)i_pstStAxisParam->byDriverType_Hmi485;




	/**************************************只写的采样数据***********************************************************************************************/
	//	static uint8_t byTmp = 0;
	//	byTmp  += 1;
	//	for(iN = 0 ;iN<800; iN++)
	//	{
	//		i_pstStGlobalParam->abyRSData_T1R[iN] = byTmp+(uint8_t)iN;
	//		i_pstStGlobalParam->abyRSData_T2R[iN] = byTmp+(uint8_t)iN;
	//	}

	uint8_t bySignalSelect_T1 = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,1);//T1当前通道选择
	uint8_t bySignalSelect_T2 = GET_CUR_CHANNEL_RGB(i_pstStGlobalParam->bySignalSelect,2);//T2当前通道选择


	//界面的波形顺序是|T1误差计算>T2误差计算>T1剩余(2路)>T2剩余(2路)|共6路
	//2025.8.9.110558  这些罗嗦的条件都只是为了减小程序执行时间
	if(xRoundSampleFlag)//粗采样有效了才更新@2025.8.5.214452+
	{
		for(iN = 0 ;iN<400; iN++)
		{
			//t1
			if(byChannel_T1T2_Cur == T1)
			{
				if(bySignalSelect_T1==CURR_VISU_G) //选择的是G通道
				{
					if(bySignalSelect_Cur == CURR_VISU_G)//当前轮询的是G通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1G[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_1[iN]);


					if(bySignalSelect_Cur == CURR_VISU_R)//当前轮询的是R通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1R[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_3[iN]);

					if(bySignalSelect_Cur == CURR_VISU_B)//当前轮询的是B通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1B[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_4[iN]);

				}
				else if(bySignalSelect_T1==CURR_VISU_B) //选择的是B通道
				{
					if(bySignalSelect_Cur == CURR_VISU_B)//当前轮询的是B通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1B[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_1[iN]);

					if(bySignalSelect_Cur == CURR_VISU_R)//当前轮询的是R通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1R[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_3[iN]);
					if(bySignalSelect_Cur == CURR_VISU_G)//当前轮询的是G通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1G[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_4[iN]);


				}
				else//(i_pstStGlobalParam->bySignalSelect==CURR_VISU_R) //选择的是R通道
				{

					if(bySignalSelect_Cur == CURR_VISU_R)//当前轮询的是R通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1R[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_1[iN]);

					if(bySignalSelect_Cur == CURR_VISU_G)//当前轮询的是G通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1G[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_3[iN]);
					if(bySignalSelect_Cur == CURR_VISU_B)//当前轮询的是B通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T1B[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_4[iN]);

				}
			}
			else//T2
			{
				//t2
				if(bySignalSelect_T2==CURR_VISU_G) //选择的是G通道
				{
					if(bySignalSelect_Cur == CURR_VISU_G)//当前轮询的是G通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2G[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_2[iN]);

					if(bySignalSelect_Cur == CURR_VISU_R)//当前轮询的是R通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2R[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_5[iN]);
					if(bySignalSelect_Cur == CURR_VISU_B)//当前轮询的是B通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2B[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_6[iN]);
				}
				else if(bySignalSelect_T2==CURR_VISU_B) //选择的是B通道
				{
					if(bySignalSelect_Cur == CURR_VISU_B)//当前轮询的是B通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2B[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_2[iN]);

					if(bySignalSelect_Cur == CURR_VISU_R)//当前轮询的是R通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2R[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_5[iN]);
					if(bySignalSelect_Cur == CURR_VISU_G)//当前轮询的是G通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2G[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_6[iN]);

				}
				else//(i_pstStGlobalParam->bySignalSelect==CURR_VISU_R) //选择的是R通道
				{
					if(bySignalSelect_Cur == CURR_VISU_R)//当前轮询的是R通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2R[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_2[iN]);

					if(bySignalSelect_Cur == CURR_VISU_G)//当前轮询的是G通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2G[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_5[iN]);
					if(bySignalSelect_Cur == CURR_VISU_B)//当前轮询的是B通道|就处理发送吧！
						KS_BYTE_TO_WORD(TRUE,&i_pstStGlobalParam->abyRSData_T2B[2 * iN],&i_pstVisuCommData->sampleData_WO.awSampleData_6[iN]);
				}
			}//T1 T2选择
		}//400个循环
	}//else
}
