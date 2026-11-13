(*@CES
Name=KS_MatrixMul
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=298d1ddc-aa28-49fc-ac94-126ebbd0a009
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_MatrixMul : INT(*矩阵乘法|AxB*)
(*
-1 数据输入指针非法
-2 行列非法
-3 数组溢出(矩阵数据大于写入的数组长度了)
*)
VAR_INPUT
	i_byRow_A:BYTE;(*行数*)
	i_byColumn_A:BYTE;(*列*)
	i_dwMatrixDataAdr_A:DWORD;(*矩阵数据地址|A@数据顺序存放*)
	i_byRow_B:BYTE;(*行数*)
	i_byColumn_B:BYTE;(*列*)
	i_dwMatrixDataAdr_B:DWORD;(*矩阵数据地址|B@数据顺序存放*)
	i_pbyCalcValue_Row:POINTER TO BYTE;(*行数|计算后*)
	i_pbyCalcValue_Column:POINTER TO BYTE;(*列|计算后*)
	i_parCalcValue:POINTER TO ARRAY [1..MATRIX_ELEMENT_MAX] OF REAL;(*计算出的值按一维数组存放*)
	i_parCalcValue_Matrix:POINTER TO ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*一个MATRIX_ROW_MAX x MATRIX_COLUMN_MAX的矩阵|用于存放计算后的数据|AxB*)
END_VAR
VAR
	iRtn: INT;
	arMatrixData_A:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*A矩阵数据*)
	arMatrixData_B:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;(*b矩阵数据*)
	arCalcValue:ARRAY [1..MATRIX_ROW_MAX,1..MATRIX_COLUMN_MAX] OF REAL;
	dwHandle: DWORD;
	byCalcValue_Row:BYTE;(*行数|计算后的*)
	byCalcValue_Column:BYTE;(*列|计算后的*)
	iN: INT;
	iM: INT;
	iLp: INT;
	rTemp: REAL;
	rTemp_A: REAL;
	rTemp_B: REAL;
END_VAR
{IMPLEMENTATION}
(*判断数据的正确性*)
IF i_dwMatrixDataAdr_A=0 OR
	i_dwMatrixDataAdr_B=0 THEN
	iRtn:=-1;
END_IF

IF i_byColumn_A<>i_byRow_B OR
	i_byRow_A=0 OR
	i_byColumn_A=0 OR
	i_byRow_B=0 OR
	i_byColumn_B=0 THEN
	iRtn:=-2;
END_IF
IF i_parCalcValue<>0  THEN;
ELSE
	iRtn:=-3;
END_IF
(*
IF iRtn=0 THEN
	IF i_pparCalcValueAdr<>0 THEN
		dwHandle:=i_pparCalcValueAdr^;
		IF dwHandle<>0 THEN;
		ELSE(*地址错误|需要申请*)
			dwHandle:=SysMemAlloc(SIZEOF(i_pparCalcValueAdr^^));
(*测试使用*)
IF i_xTestEn THEN
	dwHandle:=i_parCalcValue_Test;
END_IF
			IF dwHandle<>0 THEN;(*申请成功*)
				(*内存清零*)
				SysMemSet(dwHandle,0,SIZEOF(i_pparCalcValueAdr^^));
			ELSE(*申请失败*)
				iRtn:=-4;
			END_IF
		END_IF
		i_pparCalcValueAdr^:=dwHandle;
	ELSE
		iRtn:=-3;
	END_IF
END_IF
*)

(*都准备好了|可以运算了*)
IF iRtn=0 THEN
	(*计算后的行列值*)
	byCalcValue_Row:=i_byRow_A;
	byCalcValue_Column:=i_byColumn_B;
	(*数据赋值|*)
	KS_MatrixData_Wr(i_byRow_A, i_byColumn_A, i_dwMatrixDataAdr_A,ADR(arMatrixData_A));
	KS_MatrixData_Wr(i_byRow_B, i_byColumn_B, i_dwMatrixDataAdr_B,ADR(arMatrixData_B));

	(*开始运算|AxB*)
	FOR iN:=1 TO byCalcValue_Row BY 1 DO(*A矩阵的行*)
		FOR iM:=1 TO byCalcValue_Column BY 1 DO(*B矩阵的列*)
			rTemp:=0;
			FOR iLp:=1 TO i_byColumn_A BY 1 DO(*A矩阵的列\B矩阵的行*)
				rTemp_A:=arMatrixData_A[iN,iLp];
				rTemp_B:=arMatrixData_B[iLp,iM];
				rTemp:=rTemp+rTemp_A*rTemp_B;
			END_FOR
			arCalcValue[iN,iM]:=rTemp;
		END_FOR
	END_FOR
END_IF

(*将矩阵写入到数组中|*)
KS_MatrixData_Rd(
	byCalcValue_Row,
	byCalcValue_Column,
	ADR(arCalcValue),
	SIZEOF(i_parCalcValue^)/SIZEOF(i_parCalcValue^[1]),
	i_parCalcValue);


IF i_parCalcValue_Matrix<>0 THEN
	i_parCalcValue_Matrix^:=arCalcValue;(*赋值*)
END_IF

IF i_pbyCalcValue_Row<>0 THEN
	i_pbyCalcValue_Row^:=byCalcValue_Row;
END_IF
IF i_pbyCalcValue_Column<>0 THEN
	i_pbyCalcValue_Column^:=byCalcValue_Column;
END_IF