(*@CES
Name=KS_GenTxData_
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4f0cddb0-57bc-4748-9ef3-99d0df4ac11d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GenTxData_ : INT(*0无错误/-1参数非法/-100未支持的功能字/-200写多个寄存器范围无效*)
VAR_INPUT
	i_dwTxBuf: DWORD;
	i_pstStDataNode: POINTER TO StDataNode;
	i_dwBaseAdr: DWORD;
	i_uiInvocation: UINT;
	i_byFunctionId: BYTE;(*功能id/目前仅处理03和16*)
	i_piTxPayloadLen: POINTER TO INT;(*用于接收返回的实际tx数据数量/单位字节*)
	i_xOnlyWrite: BOOL;(*只写区域-16384*)
END_VAR
VAR
	iResult: INT := 0;
	uiTmp: UINT;
	pstStADU_tmp: POINTER TO StADU;
	pbyByteCount_tmp: POINTER TO BYTE;
	paiRegisters_tmp: POINTER TO ARRAY [1..MAX_PDU_REGISTERS] OF INT;
END_VAR
VAR CONSTANT
	MAX_PDU_REGISTERS: INT := 123;(*0X1~0X7B(最大)*)
	MB_FUNC_READ_MULTI_REGS: BYTE := 3;(*读多个寄存器*)
	MB_FUNC_WRITE_MULTI_REGS: BYTE := 16;(*写多个寄存器*)
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_dwTxBuf<>0 AND 
	i_pstStDataNode<>0 AND
	i_piTxPayloadLen<>0 THEN

	(*主要的输入参数合法*)
	pstStADU_tmp:= i_dwTxBuf;

	(*mbap*)
	pstStADU_tmp^.stStMBAP.uiInvocation:= bswap_16(i_uiInvocation);
	pstStADU_tmp^.stStMBAP.uiProtocol:= 0;
	pstStADU_tmp^.stStMBAP.uiLength:= 0;(*这个长度根据i_byFunctionId的类别最后再重新统计比较合适*)
	pstStADU_tmp^.stStMBAP.byUnit:= 1;(*按slaveID=1/2025.8.4.192327*)

	(*pdu*)
	pstStADU_tmp^.stStPDU_Header.byFunction:= i_byFunctionId;
	IF i_byFunctionId=MB_FUNC_READ_MULTI_REGS THEN(*读多个寄存器*)
		(*功能字/单字节/不需要字序处理*)
		pstStADU_tmp^.stStPDU_Header.byFunction:= i_byFunctionId;

		(*地址和寄存器数量/16bit/都需要做字序处理*)
		pstStADU_tmp^.stStPDU_Header.uiAddress:= bswap_16(i_pstStDataNode^.uiAddress);
		pstStADU_tmp^.stStPDU_Header.uiQuantity:= bswap_16(i_pstStDataNode^.uiQuantity);

		(*更新mbap中的uiLength/16bit/需要处理字序*)
		uiTmp:= SIZEOF(pstStADU_tmp^.stStMBAP.byUnit) + SIZEOF(pstStADU_tmp^.stStPDU_Header);
		pstStADU_tmp^.stStMBAP.uiLength:= bswap_16(uiTmp);

		(*实际数据量*)
		i_piTxPayloadLen^:= DWORD_TO_INT(SIZEOF(pstStADU_tmp^));

	ELSIF i_byFunctionId=MB_FUNC_WRITE_MULTI_REGS THEN(*写多个寄存器*)
		(*功能字/单字节/不需要字序处理*)
		pstStADU_tmp^.stStPDU_Header.byFunction:= i_byFunctionId;

		(*地址和寄存器数量/16bit/都需要做字序处理*)
		IF i_pstStDataNode^.uiQuantity>=1 AND i_pstStDataNode^.uiQuantity<=MAX_PDU_REGISTERS THEN
			(*增加1级判断/保证寄存器在合法范围*)

			pstStADU_tmp^.stStPDU_Header.uiAddress:= bswap_16(i_pstStDataNode^.uiAddress);
			pstStADU_tmp^.stStPDU_Header.uiQuantity:= bswap_16(i_pstStDataNode^.uiQuantity);

			(*填充字节数量/单字节不用做字序处理*)
			pbyByteCount_tmp:= i_dwTxBuf + SIZEOF(pstStADU_tmp^);
			pbyByteCount_tmp^:= UINT_TO_BYTE(i_pstStDataNode^.uiQuantity*2);

			(*将寄存器数据搬到要发送的区域/这里没有做大小端数据处理*)
			paiRegisters_tmp:= i_dwTxBuf + SIZEOF(pstStADU_tmp^) + SIZEOF(pbyByteCount_tmp^);
			IF i_xOnlyWrite THEN
				SysMemCpy(
					paiRegisters_tmp, 
					i_dwBaseAdr+(i_pstStDataNode^.uiAddress-PARAM_ZONE_C2S)*2, 
					i_pstStDataNode^.uiQuantity*2);
			ELSE
				SysMemCpy(
					paiRegisters_tmp, 
					i_dwBaseAdr+(i_pstStDataNode^.uiAddress-PARAM_ZONE_ALTERNATE_OFST)*2, 
					i_pstStDataNode^.uiQuantity*2);
			END_IF

			(*更新mbap中的uiLength/16bit/需要处理字序*)
			uiTmp:= SIZEOF(pstStADU_tmp^.stStMBAP.byUnit) + SIZEOF(pstStADU_tmp^.stStPDU_Header) + SIZEOF(pbyByteCount_tmp^) + i_pstStDataNode^.uiQuantity*2;
			pstStADU_tmp^.stStMBAP.uiLength:= bswap_16(uiTmp);

			(*实际数据量*)
			i_piTxPayloadLen^:= DWORD_TO_INT(SIZEOF(pstStADU_tmp^) + SIZEOF(pbyByteCount_tmp^) + i_pstStDataNode^.uiQuantity*2);
		ELSE
			iResult:= -200;
		END_IF
	ELSE
		iResult:= -100;(*未支持的功能字*)
	END_IF
ELSE
	iResult:= -1;
END_IF
KS_GenTxData_:= iResult;
