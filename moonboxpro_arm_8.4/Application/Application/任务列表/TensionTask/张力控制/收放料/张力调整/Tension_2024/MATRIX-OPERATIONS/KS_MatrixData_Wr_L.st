(*@CES
Name=KS_MatrixData_Wr_L
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=8b74f2b8-bd6d-4ba2-a26e-ef8a252a4b73
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_MatrixData_Wr_L : BOOL
(*矩阵按照二维数组存放*)
VAR_INPUT
	i_byRow:BYTE;(*行数*)
	i_byColumn:BYTE;(*列*)
	i_dwMatrixDataAdr:DWORD;(*矩阵数据地址(LREAL数据类型)|总数据个数为i_byRow*i_byColumn*)
	i_parMatrix_Wr:POINTER TO ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF LREAL;
END_VAR
VAR
	iN: INT;
	iM: INT;
	dwDataAdr_Sa: DWORD;
	dwDataAdr_Cur: DWORD;
	prTemp:POINTER TO LREAL;
	rTemp:LREAL;
(*	arMatrix_Wr:ARRAY [1..255,1..255] OF LREAL;*)
	iLen_SingleData: INT;
	dwLen_Data: DWORD;
END_VAR
{IMPLEMENTATION}
IF i_dwMatrixDataAdr<>0 AND
	i_parMatrix_Wr<>0 AND
	i_byRow>0 AND
	i_byColumn>0 THEN
	dwDataAdr_Sa:=i_dwMatrixDataAdr;
	dwLen_Data:=SIZEOF(i_parMatrix_Wr^);
	iLen_SingleData:=SIZEOF(i_parMatrix_Wr^[1,1]);

	SYSMEMSET(i_parMatrix_Wr,0,dwLen_Data);
	FOR iN:=1 TO i_byRow BY 1 DO
		FOR iM:=1 TO i_byColumn BY 1 DO
			dwDataAdr_Cur:=dwDataAdr_Sa+(iN-1)*(iLen_SingleData*i_byColumn)+(iM-1)*iLen_SingleData;(*地址偏移*)
			prTemp:=dwDataAdr_Cur;
			rTemp:=prTemp^;

			i_parMatrix_Wr^[iN,iM]:=rTemp;
		END_FOR
	END_FOR
END_IF