(*@CES
Name=KS_FB_FiltByAver
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=d55a5298-8c05-4803-b072-b92952ba6371
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION_BLOCK KS_FB_FiltByAver(*通过平均进行滤波|2020.10.8.140809更新。*)
(*2023.09.04.122927 为了减少空间利用-将最大滤波次数输出由60个修改到了30个|
滤波数组类型LREAL修改为了real*)
VAR_INPUT
	i_xEn					:BOOL;
	i_iFiltTimes			:INT;(*滤波次数，最大60*)
	i_dwDataAdr				:DWORD;(*需要滤波的数据地址*)
	i_byDataType			:TypEnumDataType;(*滤波的数据类型*)
	i_xFrom0Average			:BOOL;(*从0开始滤波@2024.05.21.163305*)
END_VAR
VAR_OUTPUT
	o_xEn					:BOOL;
(*	o_alrArrData			:ARRAY [1..60] OF LREAL;(*存放数据的数组，1是最新数据*)*)
	o_alrArrData			:ARRAY [1..30] OF LREAL;(*存放数据的数组，1是最新数据@2023.09.04.123126*)
	o_rFiltData			:REAL;(*滤波后的值*)
	o_iCode					:INT;
END_VAR
VAR
	plrData				:POINTER TO LREAL;
	prData				:POINTER TO REAL;
	pdiData				:POINTER TO DINT;
	pdwData				:POINTER TO DWORD;
	piData				:POINTER TO INT;
	pwData				:POINTER TO WORD;
	pbyData				:POINTER TO BYTE;
	pxData				:POINTER TO BOOL;

	lrData				:LREAL;(*进行滤波的数据*)
	iN					:INT;
	lrDataSum			:LREAL;(**)
	xArrInit			:BOOL;(*滤波数组初始化*)
	iInitCnt			:INT:=0;
	iPreFiltTimes		:INT;
	xPreFilterTimeInit	:BOOL:=FALSE;
END_VAR
{IMPLEMENTATION}
IF i_iFiltTimes>30 THEN i_iFiltTimes:=30;ELSIF i_iFiltTimes<=0 THEN i_iFiltTimes:=1;END_IF
o_xEn:=i_xEn;
IF NOT xPreFilterTimeInit THEN
	xPreFilterTimeInit:=TRUE;
	iPreFiltTimes:=i_iFiltTimes;
END_IF


plrData:=0;
plrData:=0;
prData:=0;
pdiData:=0;
pdwData:=0;
piData:=0;
pwData:=0;
pbyData:=0;
pxData:=0;
lrData:=0;
o_iCode:=0;
IF i_dwDataAdr<>0 THEN(*数据地址有效了 我们可以进行滤波*)
	CASE i_byDataType OF
	TYPE_LREAL:
		plrData:=i_dwDataAdr;
		lrData:=plrData^;
	TYPE_REAL:
		prData:=i_dwDataAdr;
		lrData:=REAL_TO_LREAL(prData^);
	TYPE_DINT:
		pdiData:=i_dwDataAdr;
		lrData:=DINT_TO_LREAL(pdiData^);
	TYPE_DWORD:
		pdwData:=i_dwDataAdr;
		lrData:=DWORD_TO_LREAL(pdwData^);
	TYPE_INT:
		piData:=i_dwDataAdr;
		lrData:=INT_TO_LREAL(piData^);
	TYPE_WORD:
		pwData:=i_dwDataAdr;
		lrData:=WORD_TO_LREAL(pwData^);
	TYPE_BYTE:
		pbyData:=i_dwDataAdr;
		lrData:=BYTE_TO_LREAL(pbyData^);
	TYPE_BOOL:
		pxData:=i_dwDataAdr;
		lrData:=BOOL_TO_LREAL(pxData^);
	ELSE
		o_iCode:=-2;
	END_CASE
ELSE
	o_iCode:=-1;
	RETURN;
END_IF

IF i_xEn THEN(*滤波使能*)
	IF i_iFiltTimes>iPreFiltTimes THEN(*滤波次数加大了 我们重新初始化数组*)
		xArrInit:=FALSE;
	ELSIF i_iFiltTimes<iPreFiltTimes THEN(*次数减小了 我们只更新数组初始计数值*)
		IF	xArrInit THEN
			iInitCnt:=i_iFiltTimes;
		END_IF
	END_IF

	IF NOT xArrInit THEN(*滤波数组初始化*)
	(*	iInitCnt:=iInitCnt+1;
		IF iInitCnt>=i_iFiltTimes THEN
			xArrInit:=TRUE;
		END_IF
*)		(*滤波初始化时，数据数组一次写入*)
		FOR iN:=1 TO i_iFiltTimes BY 1 DO
			IF i_xFrom0Average THEN
				o_alrArrData[iN]:=0;
			ELSE
				o_alrArrData[iN]:=lrData;
			END_IF
		END_FOR
		xArrInit:=TRUE;
	END_IF

	(*开始进行滤波*)
	IF i_iFiltTimes>=2 THEN
		FOR iN:=i_iFiltTimes TO 2 BY -1 DO
			o_alrArrData[iN]:=o_alrArrData[iN-1];
		END_FOR
	ELSE(*不进行滤波*);
	END_IF
	o_alrArrData[1]:=lrData;


	o_rFiltData:=0;
	IF xArrInit THEN
		lrDataSum:=0;
		FOR	 iN:=1 TO i_iFiltTimes BY 1 DO
			lrDataSum:=lrDataSum+o_alrArrData[iN];
		END_FOR

		o_rFiltData:=LREAL_TO_REAL(lrDataSum/i_iFiltTimes);
	END_IF
ELSE(*不滤波*)
	xArrInit:=FALSE;
	iInitCnt:=0;
	o_rFiltData:=LREAL_TO_REAL(lrData);
END_IF

iPreFiltTimes:=i_iFiltTimes;