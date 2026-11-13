(*@CES
Name=KS_ExportDatasetARC2TravelData
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=eba4d0dc-1229-4580-87a3-c48a3cf2df9b
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_ExportDatasetARC2TravelData : INT (* 将套色数据导出到旅行日志中|用以保存成.mix文件|>0表示写入的数量/-1表示参数错误/0表示没有数据可写 *)
VAR_INPUT
	i_pstStDatasetARC: POINTER TO StDatasetARC;
	i_pstStTravelDataRec: POINTER TO StTravelDataRec;
END_VAR
VAR
	iN: INT;
	iResult: INT;
	byTmpIdx_R: BYTE;
	byTmpIdx_W: BYTE;
	uiIdxTravelData_W: UINT;
	uiMaxTravelDataItemNum: UINT;
	iMaxCarriedItems_SingleCycle: INT;
	dwAdrOffset: DWORD;
	puiPreambleMark: POINTER TO UINT; (* 16#55AA *)
	piLength_Payload: POINTER TO INT; (* 数据长度 *)
	pbyEndMark: POINTER TO BYTE; (* 16#FF *)
	pstStTravelDataItem: POINTER TO StTravelDataItem;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pstStDatasetARC<>0 AND
	i_pstStTravelDataRec<>0 THEN

	byTmpIdx_R:= i_pstStDatasetARC^.byIdxRd;
	byTmpIdx_W:= i_pstStDatasetARC^.byIdxWr;

	IF byTmpIdx_R<>byTmpIdx_W THEN
		iMaxCarriedItems_SingleCycle:= DWORD_TO_INT(SIZEOF(i_pstStDatasetARC^.astStRecord_A)/SIZEOF(i_pstStDatasetARC^.astStRecord_A[1]));
		iMaxCarriedItems_SingleCycle:= iMaxCarriedItems_SingleCycle/2;(*最大搬一半fifo|*)

		(*TravelDataRec中最大fifo的数量|*)
		uiMaxTravelDataItemNum:= DWORD_TO_UINT(SIZEOF(i_pstStTravelDataRec^.astStTravelDataItem)/SIZEOF(i_pstStTravelDataRec^.astStTravelDataItem[1]));
		uiIdxTravelData_W:= i_pstStTravelDataRec^.uiWr;
		IF uiIdxTravelData_W>=1 AND
			uiIdxTravelData_W<=uiMaxTravelDataItemNum THEN
			FOR iN:=1 TO iMaxCarriedItems_SingleCycle BY 1 DO
				pstStTravelDataItem:= ADR(i_pstStTravelDataRec^.astStTravelDataItem[uiIdxTravelData_W]);

				(*找到要写入的行首地址|*)
				dwAdrOffset:= ADR(i_pstStTravelDataRec^.astStTravelDataItem[uiIdxTravelData_W].abyPayload);
				pstStTravelDataItem^.uiValidBytesNum:= 0;

				(*前导码|*)
				puiPreambleMark:= dwAdrOffset;
				puiPreambleMark^:= 16#55AA;
				pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+DWORD_TO_UINT(SIZEOF(puiPreambleMark^));

				(*包长度|*)
				piLength_Payload:= dwAdrOffset+SIZEOF(puiPreambleMark^);
				piLength_Payload^:= DWORD_TO_INT(SIZEOF(i_pstStDatasetARC^.astStRecord_A[byTmpIdx_R]));
				pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+DWORD_TO_UINT(SIZEOF(piLength_Payload^));

				(*复制正文|*)
				SysMemCpy(
					dwAdrOffset+SIZEOF(puiPreambleMark^)+SIZEOF(piLength_Payload^),
					ADR(i_pstStDatasetARC^.astStRecord_A[byTmpIdx_R]),
					SIZEOF(i_pstStDatasetARC^.astStRecord_A[byTmpIdx_R]));
				pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+DWORD_TO_UINT(SIZEOF(i_pstStDatasetARC^.astStRecord_A[byTmpIdx_R]));

				(*结束码|*)
				pbyEndMark:= dwAdrOffset+SIZEOF(puiPreambleMark^)+SIZEOF(piLength_Payload^)+SIZEOF(i_pstStDatasetARC^.astStRecord_A[byTmpIdx_R]);
				pbyEndMark^:= 16#FF;
				pstStTravelDataItem^.uiValidBytesNum:= pstStTravelDataItem^.uiValidBytesNum+DWORD_TO_UINT(SIZEOF(pbyEndMark^));

				iResult:= iResult+1; (* 2020.7.25.171820|写入数量统计 *)

				(*下次要访问的数据位置|*)
				uiIdxTravelData_W:= uiIdxTravelData_W+1; (* 2020.7.27.105658|修复bug *)
				IF uiIdxTravelData_W>uiMaxTravelDataItemNum THEN
					uiIdxTravelData_W:= uiIdxTravelData_W-uiMaxTravelDataItemNum;
				END_IF
				byTmpIdx_R:= byTmpIdx_R+1;
				IF byTmpIdx_R=byTmpIdx_W THEN
					EXIT;
				END_IF
			END_FOR
			i_pstStTravelDataRec^.uiWr:= uiIdxTravelData_W;
		ELSE
			i_pstStTravelDataRec^.uiWr:= 1;
			i_pstStTravelDataRec^.uiRd:= 1;
		END_IF
		i_pstStDatasetARC^.byIdxRd:= byTmpIdx_R;
	END_IF
ELSE
	iResult:= -1;
END_IF
KS_ExportDatasetARC2TravelData:= iResult;