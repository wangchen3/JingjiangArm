(*@CES
Name=KS_PseudoRandom
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9c33f8b8-e073-4809-951a-533a8c88d823
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_PseudoRandom : BOOL(*伪随机*)
VAR_INPUT
	i_xEn:BOOL;(*伪随机使能|功能使能*)
	i_xStart:BOOL;(*伪随机启动标志|开始执行输出@需要沿触发*)
	i_iSeries:INT:=9;(*伪随机测试级数*)
	i_rAmplitude:REAL;(*测试幅值*)
	i_byRoundTimes:BYTE;(*测试次数*)
	i_pxTesting:POINTER TO BOOL;(*测试中*)
	i_prCurAmplitude:POINTER TO REAL;(*当前幅值*)
	i_piCurIndex:POINTER TO INT;(*当前索引值*)
	i_pbyCurTimes:POINTER TO BYTE;(*当前测试次数*)
	
	(*2026.5.7.173646lhy+*)
	i_byPseudoRandomId:BYTE:=1;(*=0 放牵|=1 放料|=2 收料 |=3 收牵|=4色组*)
	i_xFlag_PTfifofull:BOOL;(*pt空间满标志@只针对伺服电机伪随机*)

END_VAR
VAR


	xTesting: BOOL;(*测试中*)
	rCurAmplitude: REAL;(*当前幅值*)
	byCurTimes: BYTE;(*当前测试次数*)
	iRandomDataNum: INT:=1023;
	iCurIndex: INT:=0;
	abyDataList:ARRAY [1..20] OF BYTE:=[20(1)];(*数据列表|初值=1*)
	abyDataCoeffList:ARRAY [1..20] OF BYTE:=[0,0,0,1,0,0,0,0,1,11(0)];(*数据系数列表|*)
	arRandomDataList:ARRAY [1..2000] OF REAL;(*产生的随机数|*)
	xUpdateIndex: BOOL; (*2026.5.7.173820lhy+*)
END_VAR
{IMPLEMENTATION}
IF i_pxTesting<>0 THEN
	xTesting:=i_pxTesting^;
END_IF
IF i_prCurAmplitude<>0 THEN
	rCurAmplitude:=i_prCurAmplitude^;
END_IF
IF i_pbyCurTimes<>0 THEN
	byCurTimes:=i_pbyCurTimes^;
END_IF
IF i_pbyCurTimes<>0 THEN
	iCurIndex:=i_piCurIndex^;
END_IF

rCurAmplitude:=0;(*默认一个特殊值*)
IF  i_xEn THEN(*功能使能*)
	IF i_xStart THEN(*按钮*)
		xTesting:=NOT xTesting;(*伪随机测试中*)
	END_IF

	IF xTesting THEN
		iRandomDataNum:=REAL_TO_INT(EXPT(2,i_iSeries))-1;
		KS_GetRandomData(
			i_iSeries,
			INT_TO_UINT(iRandomDataNum),
			i_rAmplitude,
			ADR(abyDataList),
			ADR(abyDataCoeffList),
			ADR(arRandomDataList));
	(*2026.5.7.173747lhy+*)
	IF i_byPseudoRandomId = 4 THEN(*色组伪随机@pt满的时候不更新索引*)
		IF NOT i_xFlag_PTfifofull THEN
			xUpdateIndex:=TRUE;
		END_IF
	ELSE
		xUpdateIndex:=TRUE;
	END_IF

	IF xUpdateIndex THEN (*2026.5.7.173957lhy+*)
		iCurIndex:=iCurIndex+1;
		IF iCurIndex>iRandomDataNum THEN
			iCurIndex:=1;
			byCurTimes:=byCurTimes+1;
		END_IF
	END_IF
		IF byCurTimes<i_byRoundTimes THEN
			rCurAmplitude:=arRandomDataList[iCurIndex];
		ELSE
			xTesting:=FALSE;(*结束测试*)
		END_IF
	ELSE
		iCurIndex:=0;
		byCurTimes:=0;
	END_IF
ELSE
	xTesting:=FALSE;
	iCurIndex:=0;
	byCurTimes:=0;
END_IF



IF i_pxTesting<>0 THEN
	i_pxTesting^:=xTesting;
END_IF
IF i_prCurAmplitude<>0 THEN
	i_prCurAmplitude^:=rCurAmplitude;
END_IF
IF i_pbyCurTimes<>0 THEN
	i_pbyCurTimes^:=byCurTimes;
END_IF
IF i_pbyCurTimes<>0 THEN
	i_piCurIndex^:=iCurIndex;
END_IF