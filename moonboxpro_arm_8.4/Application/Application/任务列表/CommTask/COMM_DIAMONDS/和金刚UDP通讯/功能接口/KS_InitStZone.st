(*@CES
Name=KS_InitStZone
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=6a7c2e7c-7aa2-44cc-96e1-c1f696e3ee98
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_InitStZone : INT(*0表示无错误/bit0置位表示读写区域错误/bit1置位表示只写区域错误*)
VAR_INPUT
	i_pstStParam_Diamonds_WrRd: POINTER TO StParam_Diamonds_WrRd;(*读写区域数据地址*)
	i_pstStDataZone_RW: POINTER TO StDataZone;(*读写区域*)
	i_pstStParam_Diamonds_Wr: POINTER TO StParam_Diamonds_Wr;(*只写区域数据地址*)
	i_pstStDataZone_W: POINTER TO StDataZone;(*只写区域*)
END_VAR
VAR
	iN: INT;
	iResult: INT;
	dwDlen: DWORD;
	dwBlocklen: DWORD;
	uiAddress: UINT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;

(*读写区域*)
IF i_pstStParam_Diamonds_WrRd<>0 AND i_pstStDataZone_RW<>0 THEN
	i_pstStDataZone_RW^.uiNodeNum:= 0;
	dwDlen:= SIZEOF(i_pstStParam_Diamonds_WrRd^);
	dwBlocklen:= REGS_PER_DATA_NODE*2;
	uiAddress:= PARAM_ZONE_ALTERNATE_OFST;
	WHILE dwDlen>=dwBlocklen DO
		i_pstStDataZone_RW^.uiNodeNum:= i_pstStDataZone_RW^.uiNodeNum+1;
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].uiAddress:= uiAddress;
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].uiQuantity:= DWORD_TO_UINT(dwBlocklen/2);
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].bySynchronized:= 0;

		(*2025.8.5.094540/han.dp/+*)
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].xRd_ing:= FALSE;
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].xWr_ing:= FALSE;

		uiAddress:= uiAddress + i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].uiQuantity;
		dwDlen:= dwDlen-dwBlocklen;
	END_WHILE
	IF dwDlen>0 THEN
		i_pstStDataZone_RW^.uiNodeNum:= i_pstStDataZone_RW^.uiNodeNum+1;
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].uiAddress:= uiAddress;
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].uiQuantity:= DWORD_TO_UINT(dwDlen/2);
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].bySynchronized:= 0;

		(*2025.8.5.094540/han.dp/+*)
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].xRd_ing:= FALSE;
		i_pstStDataZone_RW^.astStDataNode[i_pstStDataZone_RW^.uiNodeNum].xWr_ing:= FALSE;
	END_IF
ELSE
	iResult:= iResult+1;
END_IF

(*只写区域*)
IF i_pstStParam_Diamonds_Wr<>0 AND i_pstStDataZone_W<>0 THEN
	i_pstStDataZone_W^.uiNodeNum:= 0;

	dwDlen:= SIZEOF(i_pstStParam_Diamonds_Wr^);
	dwBlocklen:= REGS_PER_DATA_NODE*2;
	uiAddress:= PARAM_ZONE_C2S;
	WHILE dwDlen>=dwBlocklen DO
		i_pstStDataZone_W^.uiNodeNum:= i_pstStDataZone_W^.uiNodeNum+1;
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].uiAddress:= uiAddress;
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].uiQuantity:= DWORD_TO_UINT(dwBlocklen/2);
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].bySynchronized:= 0;

		(*2025.8.5.094540/han.dp/+*)
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].xRd_ing:= FALSE;
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].xWr_ing:= FALSE;

		uiAddress:= uiAddress + i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].uiQuantity;
		dwDlen:= dwDlen-dwBlocklen;
	END_WHILE
	IF dwDlen>0 THEN
		i_pstStDataZone_W^.uiNodeNum:= i_pstStDataZone_W^.uiNodeNum+1;
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].uiAddress:= uiAddress;
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].uiQuantity:= DWORD_TO_UINT(dwDlen/2);
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].bySynchronized:= 0;

		(*2025.8.5.094540/han.dp/+*)
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].xRd_ing:= FALSE;
		i_pstStDataZone_W^.astStDataNode[i_pstStDataZone_W^.uiNodeNum].xWr_ing:= FALSE;
	END_IF

	iResult:= iResult+2;
END_IF

KS_InitStZone:= iResult;
