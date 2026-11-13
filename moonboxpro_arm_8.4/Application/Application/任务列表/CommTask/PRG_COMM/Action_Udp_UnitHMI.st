(*@CES
Name=Action_Udp_UnitHMI
Type=Action
TypeGuid=8ac092e5-3128-4e26-9e7e-11016c6684f2
Guid=cdb6e806-737e-4889-9ab9-78f8b741b17a
HasDeclaration=False
HasImplementation=True
*)
{DECLARATION}

{IMPLEMENTATION}
(*2025.6.23.144921|niu.j||子影人机通讯*)
(*先获取上次通讯的响应码*)
IF NOT xInit_Comm_HMI THEN
	xInit_Comm_HMI:= TRUE;
	(*初始化*)
	FOR iN:=1 TO MAX_UNIT_NUM BY 1 DO
		iUnitId:= iN;
		axFlag_Comm_ReadEn[iUnitId] := FALSE;
		(*初始化网络*)			
		aiStep_Comm[iUnitId]:= 3;		
	END_FOR
	iUnitId_To_Hmi:= 1;
	//g_abyStationList_CommHMI;
END_IF

IF iUnitId_To_Hmi>g_stStSysParam.stStSysParam_Save.iUnitMaxNum THEN(*只需要循环到最大色组*)
	iUnitId_To_Hmi:= 1;
END_IF
iUnitId:= iUnitId_To_Hmi;
SysMemSet(ADR(abyBuf_UDP_Unit_rcv[iUnitId,1]),0,MAILBOX_PKG_MAX_BYTES);

(*先同步一次参数后再开始读取响应*)
// 	iUnitNR:=1;		
// 	dwOFST:= INT_TO_DWORD((iUnitNR-1))*MAILBOX_PKG_MAX_BYTES;
dwOFST:= INT_TO_DWORD((iUnitId-1))*INT_TO_DWORD(MAILBOX_PKG_MAX_BYTES);
(*iStationId:= g_abyStationList_CommHMI[iN];*)
iStationId:= g_abyStationList_CommHMI[iUnitId];

SysMemSet(ADR(abyBuf_UDP_Unit_rcv_Use_Tmp[iUnitId]),0,SIZEOF(abyBuf_UDP_Unit_rcv_Use_Tmp[iUnitId]));
IF KS_IsValidStationNR(iStationId) AND KS_IsValidUnitNR(iUnitId) THEN
	(*GTN_RN_DevicePcMailRd(
		1,2,
		0,
		ADR(abyBuf_UDP_Unit_rcv[iUnitId,1]),
		DWORD_TO_UINT(dwOFST),
		KS_GetNumOfDwordUsed(MAILBOX_PKG_MAX_BYTES),
		RN_ARD
		);*)
	IF g_abyStationList_CommHMI[iUnitId]<=0 THEN
		iUnitId_To_Hmi:= iUnitId_To_Hmi+1;
		RETURN;
	END_IF
	iRtn1:=GTN_RN_DevicePcMailRd(
		1,2,
		iStationId,
		ADR(abyBuf_UDP_Unit_rcv[iUnitId,1]),
		0,//DWORD_TO_UINT(dwOFST),
		KS_GetNumOfDwordUsed(MAILBOX_PKG_MAX_BYTES),
		RN_ARD
		);
	IF aiStep_Comm[iUnitId]>2 THEN
		axFlag_DataCmd[iUnitId]:=TRUE;
	ELSE
		IF abyBuf_UDP_Unit_snd[iUnitId,2]= SEMA_FUNCODE_485_MULT_RD THEN
			axFlag_DataCmd[iUnitId]:=FALSE;
		ELSE
			axFlag_DataCmd[iUnitId]:=TRUE;
		END_IF
	END_IF
	//abyRdDataNum[iUnitId]:=word_to_byte(KS_GetNumOfDwordUsed(MAILBOX_PKG_MAX_BYTES));
	KS_Modbus_ReadFun(
		TRUE,(*i_xEn:= , *)
		1,(*i_byType_RegisterorCoils:= , *)
		axFlag_DataCmd[iUnitId],(*i_xFlag_DataCmd:= , *)
		iUnitId,(*i_iUnitId_Tar:= , *)
		abyRdDataNum[iUnitId],(*i_byRdDataNum:= , *)
		ADR(abyBuf_UDP_Unit_rcv[iUnitId,1]),(*i_pbyDataBf:= , *)
		ADR(abyBuf_UDP_Unit_rcv_Use_Tmp)(*i_pbyDataRd_Use:= *));
	(*根据收到的响应内容，-处理有效数据*)
	IF axFlag_Rd_OR_WrRd[iUnitId] THEN
		SysMemCpy(ADR(astStParam_UnitHMI485_WrRd[iUnitId]),//收到的数据
			ADR(abyBuf_UDP_Unit_rcv_Use_Tmp),
			SIZEOF(astStParam_UnitHMI485_WrRd[iUnitId]));
		SysMemCpy(ADR(astStParam_UnitHMI485_WrRd_Rec[iUnitId]),
			ADR(astStParam_UnitHMI485_WrRd[iUnitId]),
			SIZEOF(astStParam_UnitHMI485_WrRd_Rec[iUnitId]));
		axFlag_Rd_Or_WrRd[iUnitId]:= FALSE;				
	ELSE
		SysMemCpy(ADR(astStParam_UnitHMI485_Rd[iUnitId]),
			ADR(abyBuf_UDP_Unit_rcv_Use_Tmp),
			SIZEOF(astStParam_UnitHMI485_Rd[iUnitId]));			
	END_IF
	aiStep_Comm[iUnitId]:= aiStep_Comm[iUnitId]+1;
	IF aiStep_Comm[iUnitId]>5 THEN
		aiStep_Comm[iUnitId]:=1;
	END_IF
	(*响应码处理完成-处理写入数据*)
	(*先判断读写参数有没有变化*)
	diTemp:= 0;
	astStParam_UnitHMI485_WrRd[iUnitId].byAxisId:= INT_TO_BYTE(iUnitId);
	diTemp:=DWORD_TO_DINT(SysMemCmp(ADR(astStParam_UnitHMI485_WrRd_Rec[iUnitId]),
			ADR(astStParam_UnitHMI485_WrRd[iUnitId]),
			SIZEOF(astStParam_UnitHMI485_WrRd_Rec[iUnitId])));
	SysMemCpy(ADR(astStParam_UnitHMI485_WrRd_Rec[iUnitId]),
		ADR(astStParam_UnitHMI485_WrRd[iUnitId]),
		SIZEOF(astStParam_UnitHMI485_WrRd_Rec[iUnitId]));			
	IF diTemp=0 THEN
		CASE aiStep_Comm[iUnitId] OF
			(*写入数据流程-读-读-写-写*)
			1:
			KS_Modbus_WriteFun(
				TRUE,(*i_xEn:= , *)
				1,(*i_byType_RegisterorCoils:= , *)
				FALSE,(*i_xFlag_DataCmd:= , *)
				iUnitId,(*i_iUnitId_Tar:= , *)
				600,(*i_wAddr_Comm:= , *)(*双向数据的通讯地址*)
				ADR(astStParam_UnitHMI485_WrRd[iUnitId]),(*i_pData_Addrstart:= , *)
				240,(*i_byLength_Data:= *)
				ADR(abyBuf_UDP_Unit_snd[iUnitId,1]));
			abyRdDataNum[iUnitId]:= 245;
			axFlag_Rd_Or_WrRd[iUnitId]:= TRUE;
			2:
			KS_Modbus_WriteFun(
				TRUE,(*i_xEn:= , *)
				1,(*i_byType_RegisterorCoils:= , *)
				FALSE,(*i_xFlag_DataCmd:= , *)
				iUnitId,(*i_iUnitId_Tar:= , *)
				720,(*i_wAddr_Comm:= , *)(*双向数据的通讯地址*)
				ADR(astStParam_UnitHMI485_Rd[iUnitId]),(*i_pData_Addrstart:= , *)
				240,(*i_byLength_Data:= *)
				ADR(abyBuf_UDP_Unit_snd[iUnitId,1]));		
			abyRdDataNum[iUnitId]:= 245;
			3:
			KS_Modbus_WriteFun(
				TRUE,(*i_xEn:= , *)
				1,(*i_byType_RegisterorCoils:= , *)
				TRUE,(*i_xFlag_DataCmd:= , *)
				iUnitId,(*i_iUnitId_Tar:= , *)
				0,(*i_wAddr_Comm:= , *)(*双向数据的通讯地址*)
				ADR(astStParam_UnitHMI485_Wr_81[iUnitId]),(*i_pData_Addrstart:= , *)
				240,(*i_byLength_Data:= *)
				ADR(abyBuf_UDP_Unit_snd[iUnitId,1]));		
			abyRdDataNum[iUnitId]:= 8;
			4:
			KS_Modbus_WriteFun(
				TRUE,(*i_xEn:= , *)
				1,(*i_byType_RegisterorCoils:= , *)
				TRUE,(*i_xFlag_DataCmd:= , *)
				iUnitId,(*i_iUnitId_Tar:= , *)
				120,(*i_wAddr_Comm:= , *)(*双向数据的通讯地址*)
				ADR(astStParam_UnitHMI485_Wr_82[iUnitId]),(*i_pData_Addrstart:= , *)
				240,(*i_byLength_Data:= *)
				ADR(abyBuf_UDP_Unit_snd[iUnitId,1]));		
			abyRdDataNum[iUnitId]:= 8;
			5:
			KS_Modbus_WriteFun(
				TRUE,(*i_xEn:= , *)
				1,(*i_byType_RegisterorCoils:= , *)
				TRUE,(*i_xFlag_DataCmd:= , *)
				iUnitId,(*i_iUnitId_Tar:= , *)
				360,(*i_wAddr_Comm:= , *)(*双向数据的通讯地址*)
				ADR(astStParam_UnitHMI485_Wr_83[iUnitId]),(*i_pData_Addrstart:= , *)
				240,(*i_byLength_Data:= *)
				ADR(abyBuf_UDP_Unit_snd[iUnitId,1]));					
			abyRdDataNum[iUnitId]:= 8;
		END_CASE
	ELSE
		KS_Modbus_WriteFun(
			TRUE,(*i_xEn:= , *)
			1,(*i_byType_RegisterorCoils:= , *)
			TRUE,(*i_xFlag_DataCmd:= , *)
			iUnitId,(*i_iUnitId_Tar:= , *)
			600,(*i_wAddr_Comm:= , *)(*双向数据的通讯地址*)
			ADR(astStParam_UnitHMI485_WrRd[iUnitId]),(*i_pData_Addrstart:= , *)
			UINT_TO_BYTE(SIZEOF(astStParam_UnitHMI485_WrRd[iUnitId]))(*i_byLength_Data:= *),
			ADR(abyBuf_UDP_Unit_snd[iUnitId,1]));
		abyRdDataNum[iUnitId]:= 8;
	END_IF
	
	 iRtn2:=GTN_RN_DevicePcMailWr(
		1,2,
		iStationId,
		ADR(abyBuf_UDP_Unit_snd[iUnitId,1]),
		//abyBuf_UDP_Unit_snd[iUnitId,1],
		0,//DWORD_TO_UINT(dwOFST),
		KS_GetNumOfDwordUsed(MAILBOX_PKG_MAX_BYTES),
		RN_AWR,
		0
		);
END_IF
iUnitId_To_Hmi:= iUnitId_To_Hmi+1;(*循环下一个色组*)
