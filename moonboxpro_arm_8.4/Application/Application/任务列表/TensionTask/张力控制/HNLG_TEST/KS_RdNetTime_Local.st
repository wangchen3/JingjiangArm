(*@CES
Name=KS_RdNetTime_Local
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eccfb541-0a7c-45b3-b3f8-2ddae0996625
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_RdNetTime_Local : INT(*2026.5.7.18293lhy+*)
VAR_INPUT
	i_pdwTime:POINTER TO DWORD;(*单位是8ns*)
END_VAR
VAR
	iFuncRtn: INT;
	uiAdrType:UINT := 16#C1FA;
	dwTime: DWORD;
	uiDataNum:UINT := 2;(* 对应1个32位 *)
	byMailRdMultRegDataMode:BYTE:=1;(*读取寄存函数的数据模式*)
	byStationId:BYTE:=0;(*站号*)
	wNetTime:WORD;
END_VAR

{IMPLEMENTATION}
(*iFuncRtn:=GT_RN_MailRdMultReg(addr:=uiAdrType,
							pData := ADR(dwTime),
							 dataNum := uiDataNum,
							dataMode := byMailRdMultRegDataMode,
							stationID := byStationId); *)
i_pdwTime^:=dwTime;(*返回的时间*)

KS_RdNetTime_Local:=iFuncRtn;(*返回值*)