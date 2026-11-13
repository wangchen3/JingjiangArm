(*@CES
Name=KS_Push2DatasetARC
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=683c72e4-00be-46c6-b743-dbd44ae0812d
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Push2DatasetARC : INT (* 将套色监测数据保存进套色数据集合中 *)
VAR_INPUT
	i_pstStDatasetARC: POINTER TO StDatasetARC;
	i_pstStRecord_A: POINTER TO StRecord_A;
END_VAR
VAR
	iResult: INT;
END_VAR

{IMPLEMENTATION}
iResult:= 0;
IF i_pstStDatasetARC<>0 AND i_pstStRecord_A<>0 THEN
	SysMemCpy(
		ADR(i_pstStDatasetARC^.astStRecord_A[i_pstStDatasetARC^.byIdxWr]),
		i_pstStRecord_A,
		SIZEOF(i_pstStRecord_A^));
	i_pstStDatasetARC^.byIdxWr:= i_pstStDatasetARC^.byIdxWr+1;
ELSE
	iResult:= -1;
END_IF
KS_Push2DatasetARC:= iResult;