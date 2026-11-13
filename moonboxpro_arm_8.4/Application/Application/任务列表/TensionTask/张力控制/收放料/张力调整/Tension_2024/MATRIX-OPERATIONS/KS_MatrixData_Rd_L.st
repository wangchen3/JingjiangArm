(*@CES
Name=KS_MatrixData_Rd_L
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=75198746-c7fb-4d37-84b0-2e92b8a87338
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_MatrixData_Rd_L : INT
(*矩阵按照二维数组存放*)
(*
-1 指针非法
-2 行列式非法
-3 数组溢出(矩阵数据大于写入的数组长度了)*)
VAR_INPUT
	i_byRow:BYTE;(*行数*)
	i_byColumn:BYTE;(*列*)
	i_parMatrixValue:POINTER TO ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF LREAL;(*矩阵值|MATRIX_ROW_MAX x MATRIX_COLUMN_MAX*)
	i_iArrLen:INT;(*将被写入的数组长度(LREAL数据类型)|防止溢出。*)
	i_dwArrAdr:DWORD;(*将矩阵值数据写入的数组地址(REAL数据类型)|写入的数据大小为i_byRow*i_byColumn*)
END_VAR
VAR
	iRtn: INT;
	prTemp: POINTER TO LREAL;
	iN: INT;
	iM: INT;
	iDataNum: INT;
END_VAR
{IMPLEMENTATION}
IF i_dwArrAdr<>0 AND
	i_parMatrixValue<>0 THEN;
ELSE
	iRtn:=-1;
END_IF

IF i_byRow>0 AND
	i_byColumn>0 THEN;
ELSE
	iRtn:=-2;
END_IF

IF iRtn=0 THEN
	IF i_iArrLen<i_byRow*i_byColumn THEN
		iRtn:=-3;
	END_IF
END_IF

(*参数都正常了|*)
IF iRtn=0 THEN
	prTemp:=i_dwArrAdr;
	SYSMEMSET(i_dwArrAdr,0,i_iArrLen*8);(*清零写入的数组*)
	FOR iN:=1 TO i_byRow BY 1 DO
		FOR iM:=1 TO i_byColumn BY 1 DO
			prTemp^:=i_parMatrixValue^[iN,iM];
			prTemp:=prTemp+SIZEOF(prTemp^);(*切换到写个地址*)
			iDataNum:=iDataNum+1;
			IF iDataNum>=i_iArrLen THEN(*溢出了不能再写了*)
				EXIT;
			END_IF
		END_FOR
	END_FOR
END_IF