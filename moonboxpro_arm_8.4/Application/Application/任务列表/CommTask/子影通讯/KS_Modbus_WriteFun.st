(*@CES
Name=KS_Modbus_WriteFun
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=be83f022-52ff-4e00-936a-c60d9b4ec08f
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Modbus_WriteFun : BOOL
VAR_INPUT
	i_xEn: BOOL;
	i_byType_RegisterorCoils: BYTE;(*操作对象选择|0：线圈1：寄存器*)
	i_xFlag_DataCmd: BOOL;(*false:读取数据指令|TRUE:发送数据指令*)
	i_iUnitId_Tar: INT;(*通讯目标色组*)
	i_wAddr_Comm: WORD;(*通讯目标站地址*)
	i_pData_Addrstart: POINTER TO BYTE;
	i_byLength_Data: BYTE;
	i_pDataSend: POINTER TO BYTE;
END_VAR
VAR
	xResult: BOOL;
	iN:INT;
	iM:INT;
	wCHK: WORD;
	pData: POINTER TO BYTE;
	byNum_Register: BYTE;
	abyData_WrBf: ARRAY [1..256] OF BYTE;
	bySendDataNum: BYTE;
END_VAR

{IMPLEMENTATION}
xResult:= FALSE;
IF i_xEn THEN
	IF KS_IsValidUnitNR(i_iUnitId_Tar) AND i_pData_Addrstart<>0 AND i_byLength_Data>0 AND i_byLength_Data<=240 THEN
		SysMemSet(ADR(abyData_WrBf),0,SIZEOF(abyData_WrBf));
		CASE i_byType_RegisterorCoils OF
			0:;(*线圈操作先不处理把*)
			1:
			IF i_xFlag_DataCmd THEN(*数据写入*)
				abyData_WrBf[1]:= INT_TO_BYTE(i_iUnitId_Tar);(*站号*)
				abyData_WrBf[2]:= SEMA_FUNCODE_485_MULT_WR;(*功能吗*)
				abyData_WrBf[3]:= WORD_TO_BYTE(SHR(i_wAddr_Comm,8));
				abyData_WrBf[4]:= WORD_TO_BYTE(i_wAddr_Comm);
				byNum_Register:= i_byLength_Data/2;
				abyData_WrBf[5]:= 16#00;
				abyData_WrBf[6]:= byNum_Register;
				abyData_WrBf[7]:= i_byLength_Data;
			
				SysMemCpy(ADR(abyData_WrBf[8]),i_pData_Addrstart,i_byLength_Data);			
				wCHK:= KS_CRC_16(ADR(abyData_WrBf),7+i_byLength_Data);
				iM:= 7+i_byLength_Data+1;
				abyData_WrBf[iM]:= WORD_TO_BYTE(SHR(wCHK,8));
				abyData_WrBf[iM+1]:= WORD_TO_BYTE(wCHK);		
				bySendDataNum:= 9+i_byLength_Data;(*发送的总字节数*)
				xResult:= TRUE;
			ELSE(*数据读取*)
				abyData_WrBf[1]:= INT_TO_BYTE(i_iUnitId_Tar);(*站号*)
				abyData_WrBf[2]:= SEMA_FUNCODE_485_MULT_RD;(*功能吗*)
				abyData_WrBf[3]:= WORD_TO_BYTE(SHR(i_wAddr_Comm,8));
				abyData_WrBf[4]:= WORD_TO_BYTE(i_wAddr_Comm);	
				byNum_Register:= i_byLength_Data/2;
				abyData_WrBf[5]:= 16#00;
				abyData_WrBf[6]:= byNum_Register;
				wCHK:= KS_CRC_16(ADR(abyData_WrBf),6);	
				abyData_WrBf[7]:= WORD_TO_BYTE(SHR(wCHK,8));
				abyData_WrBf[8]:= WORD_TO_BYTE(wCHK);		
				bySendDataNum:= 8;
			END_IF
		END_CASE
		SysMemCpy(i_pDataSend,ADR(abyData_WrBf),bySendDataNum);
		//i_pDataSend:= ADR(abyData_WrBf);
	END_IF
END_IF
KS_Modbus_WriteFun:= xResult;
