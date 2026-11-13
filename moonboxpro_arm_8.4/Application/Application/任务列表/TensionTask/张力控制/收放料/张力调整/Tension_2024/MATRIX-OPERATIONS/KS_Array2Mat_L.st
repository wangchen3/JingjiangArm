(*@CES
Name=KS_Array2Mat_L
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=48ed48f5-20a9-4e78-ab61-95ebf957d9fa
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_Array2Mat_L : REAL
VAR_INPUT
	i_byRow:BYTE;(*行数*)
	i_byColumn:BYTE;(*列*)
	i_dwMatrixDataAdr:DWORD;(*待写入的矩阵数据地址|A@数据顺序存放*)
	i_parCalcValue:POINTER TO ARRAY [1..MATRIX_ELEMENT_MAX] OF LREAL;(*存放数据的一维数组的指针*)
END_VAR
VAR
	prPtemp2:POINTER TO  LREAL;(*二维数组临时指针*)
	byRow:BYTE;
	byCol:BYTE;
	iN:INT;
	iM:INT;
	iK:INT:=1;
END_VAR
{IMPLEMENTATION}
byRow:=i_byRow;
byCol:=i_byColumn;

FOR iN:=0 TO byRow-1 BY +1 DO
	FOR iM:=0 TO byCol-1 BY +1 DO
		prPtemp2:=i_dwMatrixDataAdr+INT_TO_DWORD((iK-1)*8);(*指针指向下一个元素*)
		prPtemp2^:=i_parCalcValue^[iK];
		iK:=iK+1;
	END_FOR
END_FOR