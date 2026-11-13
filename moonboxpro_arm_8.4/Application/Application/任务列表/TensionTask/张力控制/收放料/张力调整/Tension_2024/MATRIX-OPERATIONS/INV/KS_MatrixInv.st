(*@CES
Name=KS_MatrixInv
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9a3488e5-91c1-4f64-9ccc-42c3c4a2f7c7
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_MatrixInv : BOOL
(*求n阶非奇异矩阵的逆*)
VAR_INPUT
	i_byRow_A:BYTE;(*行数*)
	i_byColumn_A:BYTE;(*列*)
	i_dwMatrixDataAdr_A:DWORD;(*矩阵数据地址|A@数据顺序存放*)
	i_pbyCalcValue_Row:POINTER TO BYTE;(*行数|计算后*)
	i_byCalcValue_Column:POINTER TO BYTE;(*列|计算后*)
	i_parCalcValue:POINTER TO ARRAY [1..MATRIX_ELEMENT_MAX] OF REAL;(*计算出的值按一维数组存放*)
	i_parCalcValue_Matrix:POINTER TO ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*一个MATRIX_ROW_MAX x MATRIX_COLUMN_MAX的矩阵|用于存放计算后的数据|AxB*)
END_VAR

VAR
	iRtn: INT;
	(*定义单位矩阵*)
	arI:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;
(*	arCalcValue:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*|用于存放计算后的数据|AxB*)*)
	arMatrixData_A:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*A矩阵数据*)
	arMatrixData_TMP:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*中间矩阵*)
	byCalcValue_Row:BYTE;(*行数|计算后的*)
	byCalcValue_Column:BYTE;(*列|计算后的*)
	iN: BYTE;
	iQ: INT;
	iI: INT;
	iK: INT;
	iJ: INT;
	iP:INT;
	rTemp: REAL;
	rTemp_A: REAL;
END_VAR
{IMPLEMENTATION}
	(*计算后的行列值*)
	byCalcValue_Row:=i_byRow_A;
	byCalcValue_Column:=i_byColumn_A;
	iN:=i_byRow_A;
	(*初始化单位矩阵*)
	FOR iI:= 1 TO iN BY 1 DO
		arI[iI,iI]:=1;
	END_FOR
	(*数据赋值|*)
	KS_MatrixData_Wr(i_byRow_A, i_byColumn_A, i_dwMatrixDataAdr_A,ADR(arMatrixData_A));
	(*初始化中间矩阵*)
	KS_MatrixData_Wr(i_byRow_A, i_byColumn_A, i_dwMatrixDataAdr_A,ADR(arMatrixData_TMP));
	(*开始计算*)
	(*化为上三角*)
	FOR iQ:=1 TO iN-1 BY 1 DO
		FOR iI:=iQ TO iN BY 1 DO
			rTemp:=arMatrixData_TMP[iI,iQ];
			FOR iJ:=1 TO iN BY 1 DO
				arMatrixData_TMP[iI,iJ]:=arMatrixData_TMP[iI,iJ]/rTemp;
				arI[iI,iJ]:=arI[iI,iJ]/rTemp;
			END_FOR
		END_FOR

		FOR iI:=1 TO iN-iQ BY 1 DO
			FOR iJ:=1 TO iN BY 1 DO
				arMatrixData_TMP[iI+iQ,iJ]:=arMatrixData_TMP[iI+iQ,iJ]-arMatrixData_TMP[iQ,iJ];
				arI[iI+iQ,iJ]:=arI[iI+iQ,iJ]-arI[iQ,iJ];
			END_FOR
		END_FOR
	END_FOR


	FOR iI:=iN TO iN BY 1 DO
		rTemp:=arMatrixData_TMP[iI,iN];
		FOR iJ:=1 TO iN BY 1 DO
			arMatrixData_TMP[iI,iJ]:=arMatrixData_TMP[iI,iJ]/rTemp;
			arI[iI,iJ]:=arI[iI,iJ]/rTemp;
		END_FOR
	END_FOR

	(*化为上三角矩阵*)

	FOR iI:=1 TO iN-1 BY 1 DO
		iK:=iN-iI;
		FOR iP := 1 TO iN-iK BY 1 DO
			rTemp:=arMatrixData_TMP[iK,iK+iP];
			FOR iJ:=1 TO iN BY 1 DO
				arMatrixData_TMP[iK,iJ]:=arMatrixData_TMP[iK,iJ]-arMatrixData_TMP[iK+iP,iJ]*rTemp;
				arI[iK,iJ]:=arI[iK,iJ]-arI[iK+iP,iJ]*rTemp;
			END_FOR
		END_FOR
	END_FOR

(*将矩阵写入到数组中|*)
KS_MatrixData_Rd(
	byCalcValue_Row,
	byCalcValue_Column,
	ADR(arI),
	SIZEOF(i_parCalcValue^)/SIZEOF(i_parCalcValue^[1]),
	i_parCalcValue);

IF i_parCalcValue_Matrix<>0 THEN
	i_parCalcValue_Matrix^:=arI;(*赋值*)
END_IF

IF i_pbyCalcValue_Row<>0 THEN
	i_pbyCalcValue_Row^:=byCalcValue_Row;
END_IF
IF i_byCalcValue_Column<>0 THEN
	i_byCalcValue_Column^:=byCalcValue_Column;
END_IF