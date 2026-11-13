(*@CES
Name=KS_GetRandomData
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=4159dbdc-a5eb-4e18-9494-07841ba68903
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetRandomData : BOOL(*产生随机数据信号|最大支持20级*)
(*2026.5.7.171822套色算法测试*)
VAR_INPUT
	i_iSeries:INT:=10;
	i_uiMaxRandomData:UINT:=1023;
	i_rAmplitude:REAL:=0.01;(*随机数对应的幅值*)
	i_pabyDataList:POINTER TO ARRAY [1..20] OF BYTE;(*数据列表|初值=1*)
	i_pabyDataCoeffList:POINTER TO ARRAY [1..20] OF BYTE;(*数据系数列表|*)
	i_parRandomDataList:POINTER TO ARRAY [1..2000] OF REAL;(*产生的随机数|*)
END_VAR
VAR
	iMaxSeries:INT:=20;(**最大级数*)
	iSeries: INT;(*数据级数*)
	abyDataList:ARRAY [1..20] OF BYTE:=[20(1)];(*数据列表|初值=1*)
	abyDataCoeffList:ARRAY [1..20] OF BYTE:=[0,0,1,0,0,0,0,0,0,1,10(0)];(*数据系数列表|*)
	
	(*2026.5.7.172008lhy+*)
	abyDataCoeffList_4 :ARRAY [1..20] OF BYTE:= [1,0,0,1,16(0)];
	abyDataCoeffList_5 :ARRAY [1..20] OF BYTE:= [1,1,1,0,1,15(0)];
	abyDataCoeffList_6 :ARRAY [1..20] OF BYTE:= [1,1,0,0,1,1,14(0)];
	abyDataCoeffList_7 :ARRAY [1..20] OF BYTE:= [1,1,1,1,1,0,1,13(0)];
	abyDataCoeffList_8 :ARRAY [1..20] OF BYTE:= [1,1,1,1,0,1,0,1,12(0)];
	abyDataCoeffList_9 :ARRAY [1..20] OF BYTE:= [0,0,0,1,0,0,0,0,1,11(0)];
	abyDataCoeffList_10:ARRAY [1..20] OF BYTE:=[1,0,0,1,1,1,1,1,1,1,1,9(0)];
	
	abyRandomData: ARRAY [1..2000] OF BYTE;
	iN: INT;
	iLp: INT;
	byTemp: BYTE;(*临时变量*)
	byRandomData: BYTE;(*随机数*)
	iLen: INT;
END_VAR
{IMPLEMENTATION}
iSeries:=i_iSeries;
IF i_iSeries<0 OR i_iSeries>iMaxSeries THEN
	iSeries:=iMaxSeries;
END_IF


(*取数据列表*)
IF i_pabyDataList<>0 THEN
	abyDataList:=i_pabyDataList^;
END_IF
(*取数据系数列表*)
IF i_pabyDataCoeffList<>0 THEN
	abyDataCoeffList:=i_pabyDataCoeffList^;
END_IF

(*2026.5.7.172517lhy+*)
IF i_iSeries =4  THEN
	abyDataCoeffList := abyDataCoeffList_4;
ELSIF i_iSeries = 5  THEN
	abyDataCoeffList := abyDataCoeffList_5;
ELSIF	 i_iSeries = 6  THEN
	abyDataCoeffList := abyDataCoeffList_6;
ELSIF	 i_iSeries = 7  THEN
	abyDataCoeffList := abyDataCoeffList_7;
ELSIF	 i_iSeries = 8  THEN
	abyDataCoeffList := abyDataCoeffList_8;
ELSIF	 i_iSeries = 9  THEN
	abyDataCoeffList := abyDataCoeffList_9;
ELSIF	 i_iSeries = 10 THEN
	abyDataCoeffList := abyDataCoeffList_10;
END_IF


(*清零随机数*)
IF i_parRandomDataList<>0 THEN
	SysMemSet(i_parRandomDataList,0,SIZEOF(i_parRandomDataList));
END_IF


FOR iN:=1 TO UINT_TO_INT(i_uiMaxRandomData) BY 1 DO
	byTemp:=0;
	FOR iLp:=iSeries TO 1 BY -1 DO
		byTemp:=(abyDataList[iLp])*abyDataCoeffList[iLp]+byTemp;
		IF iLp>1 THEN
			(*取出随机数*)
			IF iLp=iSeries THEN
				byRandomData:=abyDataList[iLp];
			END_IF
			abyDataList[iLp]:=abyDataList[iLp-1];
		ELSE(*最后一次循环|将新值写入到第一个位置中*)
			byTemp:=byTemp MOD 2;
			abyDataList[iLp]:=byTemp;
		END_IF
	END_FOR
	abyRandomData[iN]:=byRandomData;
	(*输出随机数*)
	IF i_parRandomDataList<>0 THEN
		i_parRandomDataList^[iN]:=(BYTE_TO_REAL(byRandomData)*2-1)*i_rAmplitude;
	END_IF
END_FOR

(*输出数据列表*)
IF i_pabyDataList<>0 THEN
	i_pabyDataList^:=abyDataList;
END_IF