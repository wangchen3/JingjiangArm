(*@CES
Name=KS_PushValueToList
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=e04ac46d-5d6b-4101-9912-eb5ef8957014
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PushValueToList : BOOL
(*将输入值写入到列表|最后一个数据为最新数据|只处理了int类型数据*)
VAR_INPUT
	i_rValue:REAL;(**)
	i_uiDataNum:UINT;(*数据个数*)
	i_iDataType:TypEnumDataType;(*数据类型*)
	i_dwListAdr:DWORD;(*数据的起始地址*)
END_VAR
VAR
	iN: INT;
	piTmp:POINTER TO INT;
	piTmp_Next:POINTER TO INT;
	iDeltaLenth: INT;
END_VAR
{IMPLEMENTATION}
IF i_uiDataNum>0 AND i_dwListAdr<>0 THEN
	CASE i_iDataType OF
		TYPE_INT:
			iDeltaLenth:=2;(*偏移2个字节*)

			piTmp:=i_dwListAdr;
			IF i_uiDataNum<>1 THEN
				FOR iN:=1 TO UINT_TO_INT(i_uiDataNum)-1 BY 1 DO
					piTmp_Next:=piTmp+INT_TO_DWORD(iDeltaLenth);
					piTmp^:=piTmp_Next^;(*将下一个数据写入到当前位置*)
					piTmp:=piTmp+INT_TO_DWORD(iDeltaLenth);
				END_FOR
				piTmp^:=REAL_TO_INT(i_rValue);
			ELSE(*只有一个数据*)
				piTmp^:=REAL_TO_INT(i_rValue);
			END_IF
	ELSE;
	END_CASE

ELSE;
END_IF