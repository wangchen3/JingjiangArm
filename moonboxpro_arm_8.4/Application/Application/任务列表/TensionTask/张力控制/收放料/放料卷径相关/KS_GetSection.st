(*@CES
Name=KS_GetSection
Type=FunctionBlock
TypeGuid=6f9dac99-8de1-4efc-8465-68ac443b7d08
Guid=9b736825-d0e2-4d8b-932c-489ff59f3a23
HasDeclaration=True
HasImplementation=True
*)
{DECLARATION}
FUNCTION KS_GetSection : INT(*获取此时卷径电压所在的标准卷径区间*)(*输入的数据是具有单调性的！*)
VAR_INPUT
	i_rAI_DiamMeasure_Uw_cur:REAL;(*新卷电压当前值*)
	i_prData : POINTER TO ARRAY [1..4] OF REAL;(*lreal标准电压数组的首地址*)
	i_piSectionIndexFrom:POINTER TO INT;(*标准卷径区间开始*)
	i_piSectionIndexTo:POINTER TO INT;(*标准卷径区间结束*)
	i_byDataNum:BYTE;(*数据个数，以lreal为一个单位*)
END_VAR
VAR
	iN: INT;
	dwDataAdr: DWORD;
	iMonotonous:INT;(*数据的单调性*)(*数据的单调性变量，1为单调递增，2为单调递减*)
	iTemp: INT;
END_VAR
{IMPLEMENTATION}
KS_GetSection:=0;

IF i_prData<>0 AND i_piSectionIndexFrom<>0 AND i_piSectionIndexTo<>0 THEN
	;
ELSE
	KS_GetSection:=-1;
	RETURN;
END_IF

iMonotonous:=0;
IF i_prData^[1]<i_prData^[2] THEN
	iMonotonous:=1;
ELSIF i_prData^[1]>i_prData^[2] THEN
	iMonotonous:=2;
END_IF

FOR iN:=1 TO i_byDataNum BY 1 DO(*iN=0 为第一个数据地址*)
	IF iMonotonous=1 THEN(*单调递增*)
		IF i_rAI_DiamMeasure_Uw_cur>i_prData^[iN]THEN
			IF iN=i_byDataNum THEN
				i_piSectionIndexFrom^:=i_byDataNum-1;
				i_piSectionIndexTo^:=i_byDataNum;
			ELSE
				i_piSectionIndexFrom^:=iN;
			END_IF
		ELSE
			IF iN=1 THEN
				i_piSectionIndexFrom^:=1;
				i_piSectionIndexTo^:=2;
			ELSE
				i_piSectionIndexTo^:=iN;
			END_IF
			EXIT;
		END_IF
	ELSIF  iMonotonous=2 THEN(*单调递减*)
		IF i_rAI_DiamMeasure_Uw_cur>i_prData^[iN]THEN
			IF iN=1 THEN
				i_piSectionIndexFrom^:=1;
				i_piSectionIndexTo^:=2;
			ELSE
				i_piSectionIndexFrom^:=iN;
			END_IF
			EXIT;
		ELSE
			IF iN=i_byDataNum THEN
				i_piSectionIndexFrom^:=i_byDataNum-1;
				i_piSectionIndexTo^:=i_byDataNum;
			ELSE
				i_piSectionIndexTo^:=iN;
			END_IF
		END_IF
	ELSE
		i_piSectionIndexFrom^:=1;
		i_piSectionIndexTo^:=2;
	END_IF
END_FOR

IF i_piSectionIndexFrom^>i_piSectionIndexTo^ THEN
	iTemp:=i_piSectionIndexTo^;
	i_piSectionIndexTo^:=i_piSectionIndexFrom^;
	i_piSectionIndexFrom^:=iTemp;
END_IF