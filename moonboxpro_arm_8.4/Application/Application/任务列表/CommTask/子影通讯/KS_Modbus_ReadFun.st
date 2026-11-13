(*@CES
Name=KS_Modbus_ReadFun
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6217ccde-5e96-48ff-a0d3-8af1ff6574e5
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Modbus_ReadFun : INT(*获取通讯数据|只处理的读写多个寄存器命令*)		
(*1:获取数据写入响应码成功
2:获取数据读取有效内容*)						
VAR_INPUT
	i_xEn: BOOL;
	i_byType_RegisterorCoils: BYTE;(*操作对象选择|0：线圈1：寄存器*)
	i_xFlag_DataCmd: BOOL;(*false:读取数据指令|TRUE:发送数据指令*)
	i_iUnitId_Tar: INT;(*通讯目标色组*)
	i_byRdDataNum: BYTE;(*获取数据的总大小*)
	i_pbyDataBf: POINTER TO BYTE;(*获取的数据量*)
	i_pbyDataRd_Use: POINTER TO BYTE;(*有效数据地址*)
END_VAR
VAR
	iResult: INT;
	iN:INT;
	abyData_RdBf: ARRAY [1..256] OF BYTE;
	wCHK: WORD;
	wCHK_Rd: WORD;
END_VAR
{IMPLEMENTATION}
iResult:= 0;
IF i_xEn THEN
	IF KS_IsValidUnitNR(i_iUnitId_Tar) AND i_pbyDataBf<>0 AND i_byRdDataNum>0 THEN
		SysMemCpy(ADR(abyData_RdBf),i_pbyDataBf,BYTE_TO_DWORD(i_byRdDataNum));(*这是所有的数据拿到了，开始处理获取的数据*)
		CASE i_byType_RegisterorCoils OF
			0:;(*线圈操作先不处理把*)
			1:
			IF i_xFlag_DataCmd THEN(*数据写入*)
				IF abyData_RdBf[1]=i_iUnitId_Tar THEN(*站号*)
					IF abyData_RdBf[2]= SEMA_FUNCODE_485_MULT_WR THEN(*功能码对应正确*)
						(*响应数据大小*)
						IF i_byRdDataNum= 8 THEN(*数据写入的响应码就是8个*)
							wCHK:= KS_CRC_16(ADR(abyData_RdBf),6);
							wCHK_Rd:= SHL(BYTE_TO_WORD(abyData_RdBf[7]),8)+BYTE_TO_WORD(abyData_RdBf[8]);
							IF wCHK= wCHK_Rd THEN
								(*数据获取成功*)
								iResult:= 1;
							END_IF
						END_IF
					ELSE;	(*功能码不对*)
					END_IF
				ELSE;(*站号不对*)
				END_IF
			ELSE
				IF abyData_RdBf[1]=i_iUnitId_Tar THEN(*站号*)
					IF abyData_RdBf[2]= SEMA_FUNCODE_485_MULT_RD THEN(*功能码对应正确*)		
						IF i_byRdDataNum= (abyData_RdBf[3]+5) THEN
							wCHK:= KS_CRC_16(ADR(abyData_RdBf),i_byRdDataNum-2);
							wCHK_Rd:= SHL(BYTE_TO_WORD(abyData_RdBf[abyData_RdBf[3]+4]),8)+
								BYTE_TO_WORD(abyData_RdBf[abyData_RdBf[3]+5]);
							IF wCHK = wCHK_Rd THEN
								IF i_pbyDataRd_Use<>0 THEN
									SysMemCpy(i_pbyDataRd_Use,ADR(abyData_RdBf[4]),abyData_RdBf[3]);
								
								ELSE
									iResult:= -3;
								END_IF
								(*数据获取成功*)
								iResult:= 2;
							END_IF
						END_IF
					END_IF
				END_IF		
			END_IF
		END_CASE		
	END_IF
END_IF