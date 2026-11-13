(*@CES
Name=KS_Matrix_N
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=f9a2788c-346e-4eac-9aa1-38ed8042fd34
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Matrix_N : REAL
(*求n阶矩阵的n次方*)
VAR_INPUT
	i_byRow_A:BYTE;(*行数*)
	i_byColumn_A:BYTE;(*列*)
	i_iN:INT;(*矩阵的N次方*)
	i_dwMatrixDataAdr_A:DWORD;(*矩阵数据地址|A@数据顺序存放*)
	i_pbyCalcValue_Row:POINTER TO BYTE;(*行数|计算后*)
	i_pbyCalcValue_Column:POINTER TO BYTE;(*列|计算后*)
	i_parCalcValue:POINTER TO ARRAY [1..MATRIX_ELEMENT_MAX] OF REAL;(*计算出的值按一维数组存放*)
	i_parCalcValue_Matrix:POINTER TO ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*一个MATRIX_ROW_MAX x MATRIX_COLUMN_MAX的矩阵|用于存放计算后的数据|AxB*)
END_VAR

VAR
(*	arCalcValue:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*|用于存放计算后的数据|*)*)

	arMatrixData_A:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*A矩阵数据*)

(*	arCalValue_TMP1:ARRAY [1..MATRIX_ELEMENT_MAX] OF REAL;(*计算出的值按一维数组存放*)*)
	arCalValue_TMP2:ARRAY [1..MATRIX_ELEMENT_MAX] OF REAL;(*计算出的值按一维数组存放*)
	arMatrixData_TMP1:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*中间矩阵*)
	arMatrixData_TMP2:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*中间矩阵*)

	byCalcValue_Row_TMP1:BYTE;(*行数|计算后的*)
	byCalcValue_Column_TMP1:BYTE;(*列|计算后的*)

	byCalcValue_Row_TMP2:BYTE;(*行数|计算后的*)
	byCalcValue_Column_TMP2:BYTE;(*列|计算后的*)

	byCalcValue_Row:BYTE;(*行数|计算后的*)
	byCalcValue_Column:BYTE;(*列|计算后的*)
	iN: INT;(*矩阵的N次方*)

	iI: INT;
	iJ: INT;
	iK: INT;
END_VAR

{IMPLEMENTATION}
(*数据赋值|*)
(*计算后的行列值*)
byCalcValue_Row:=i_byRow_A;
byCalcValue_Column:=i_byColumn_A;
byCalcValue_Row_TMP1:=i_byRow_A;(*行数|计算后的*)
byCalcValue_Column_TMP1:=i_byColumn_A;(*列|计算后的*)

byCalcValue_Row_TMP2:=i_byRow_A;(*行数|计算后的*)
byCalcValue_Column_TMP2:=i_byColumn_A;(*列|计算后的*)
iN:=i_iN;
iJ:=i_byRow_A;

KS_MatrixData_Wr(i_byRow_A, i_byColumn_A, i_dwMatrixDataAdr_A,ADR(arMatrixData_A));
(*初始化中间矩阵为单位阵1*)
FOR iK:= 1 TO iJ BY 1 DO
		arMatrixData_TMP1[iK,iK]:=1;
END_FOR
(*初始化中间矩阵2*)
	KS_MatrixData_Wr(i_byRow_A, i_byColumn_A, i_dwMatrixDataAdr_A,ADR(arMatrixData_TMP2));
(*开始计算*)
IF iN=0 THEN
	arMatrixData_TMP2:=arMatrixData_TMP1;
ELSE
	FOR iI:=1 TO iN BY 1 DO
		KS_MatrixMul(INT_TO_BYTE(MATRIX_ROW_MAX),
				INT_TO_BYTE(MATRIX_COLUMN_MAX),
				ADR(arMatrixData_A),
				INT_TO_BYTE(MATRIX_ROW_MAX),
				INT_TO_BYTE(MATRIX_COLUMN_MAX),
				ADR(arMatrixData_TMP1),
				ADR(byCalcValue_Row_TMP2),
				ADR(byCalcValue_Column_TMP2),
				ADR(arCalValue_TMP2),
				ADR(arMatrixData_TMP2));
		arMatrixData_TMP1:=arMatrixData_TMP2;
	END_FOR
END_IF

(*将矩阵写入到数组中|*)
KS_MatrixData_Rd(
	byCalcValue_Row,
	byCalcValue_Column,
	ADR(arMatrixData_TMP2),
	SIZEOF(i_parCalcValue^)/SIZEOF(i_parCalcValue^[1]),
	i_parCalcValue);


IF i_parCalcValue_Matrix<>0 THEN
	i_parCalcValue_Matrix^:=arMatrixData_TMP2;(*赋值*)
END_IF

IF i_pbyCalcValue_Row<>0 THEN
	i_pbyCalcValue_Row^:=byCalcValue_Row;
END_IF
IF i_pbyCalcValue_Column<>0 THEN
	i_pbyCalcValue_Column^:=byCalcValue_Column;
END_IF